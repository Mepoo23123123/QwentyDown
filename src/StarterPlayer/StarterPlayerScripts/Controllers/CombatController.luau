--!strict
-- CombatController — Combo counter display, input handling
-- Works with StarterGui.CombatUI

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Constants = require(ReplicatedStorage.Shared.Constants)
local RemoteManager = require(ReplicatedStorage.Remotes.RemoteManager)
local ItemData = require(ReplicatedStorage.Modules.ItemData)
local WeaponVFX = require(ReplicatedStorage.Modules.WeaponVFX)

local CombatController = {}
local player = Players.LocalPlayer

-- ═══ STATE ═══
local comboTimeoutTimer = 0
local comboDisplayActive = false

-- Animation state
local AnimationData = require(ReplicatedStorage.Modules.AnimationData)

local currentWeaponId: string? = nil
local comboAnimInstances: { [number]: Animation } = {}
local comboTracks: { [number]: AnimationTrack? } = {}
local blockAnim: Animation? = nil
local blockTrack: AnimationTrack? = nil

-- Weapon stance animations
local idleAnim: Animation? = nil
local idleTrack: AnimationTrack? = nil
local walkAnim: Animation? = nil
local walkTrack: AnimationTrack? = nil
local isWeaponEquipped = false
local nextLocalAttackTime = 0
local attackBuffered = false
local attackBufferLoopRunning = false

-- UI refs (from StarterGui)
local comboFrame: Frame? = nil
local comboText: TextLabel? = nil

local function SendAttackRequest()
	nextLocalAttackTime = os.clock() + Constants.COMBO_COOLDOWN
	RemoteManager.FireServer("CombatAction", "attack")
end

local function FlushBufferedAttackWhenReady()
	if attackBufferLoopRunning then return end
	attackBufferLoopRunning = true
	task.spawn(function()
		while attackBuffered do
			local waitTime = nextLocalAttackTime - os.clock()
			if waitTime > 0 then
				task.wait(waitTime)
			else
				break
			end
		end

		attackBufferLoopRunning = false
		if attackBuffered and os.clock() >= nextLocalAttackTime then
			attackBuffered = false
			SendAttackRequest()
		end
	end)
end

local function RequestAttack()
	if os.clock() >= nextLocalAttackTime then
		attackBuffered = false
		SendAttackRequest()
	else
		attackBuffered = true
		FlushBufferedAttackWhenReady()
	end
end

-- ═══ COMBO DISPLAY ═══

local function ShowCombo(count: number)
	if not comboFrame or not comboText then return end
	comboFrame.Visible = true
	comboText.Text = if count == 4 then "MAX!" else (count .. " COMBO")
	comboText.TextSize = 40
	comboText.Size = UDim2.fromScale(1.2, 1.2)
	comboTimeoutTimer = Constants.COMBO_TIMEOUT
	comboDisplayActive = true
	TweenService:Create(comboText, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		TextSize = 32, Size = UDim2.fromScale(1, 1)
	}):Play()
end

local function HideCombo()
	comboDisplayActive = false
	if comboFrame then comboFrame.Visible = false end
end

-- ═══ ANIMATIONS ═══

--- Получить текущие ID анимаций комбо (с учётом оружия)
local function GetComboAnimIds(): { string }
	if currentWeaponId then
		local itemDef = ItemData.GetItem(currentWeaponId)
		if itemDef and itemDef.Animations and itemDef.Animations.ComboAnims then
			return itemDef.Animations.ComboAnims :: { string }
		end
	end
	return AnimationData.ComboAnims
end

--- Получить текущий ID анимации блока (с учётом оружия)
local function GetBlockAnimId(): string
	if currentWeaponId then
		local itemDef = ItemData.GetItem(currentWeaponId)
		if itemDef and itemDef.Animations and itemDef.Animations.BlockAnim then
			return itemDef.Animations.BlockAnim :: string
		end
	end
	return AnimationData.BlockAnimId
end

--- Получить IdleAnim ID оружия
local function GetIdleAnimId(): string?
	if currentWeaponId then
		local itemDef = ItemData.GetItem(currentWeaponId)
		if itemDef and itemDef.Animations and itemDef.Animations.IdleAnim then
			return itemDef.Animations.IdleAnim
		end
	end
	return nil
end

--- Получить WalkAnim ID оружия
local function GetWalkAnimId(): string?
	if currentWeaponId then
		local itemDef = ItemData.GetItem(currentWeaponId)
		if itemDef and itemDef.Animations and itemDef.Animations.WalkAnim then
			return itemDef.Animations.WalkAnim
		end
	end
	return nil
end

--- Получить UnsheathAnim ID оружия
local function GetUnsheathAnimId(): string?
	if currentWeaponId then
		local itemDef = ItemData.GetItem(currentWeaponId)
		if itemDef and itemDef.Animations and itemDef.Animations.UnsheathAnim then
			return itemDef.Animations.UnsheathAnim
		end
	end
	return nil
end

local function CreateComboAnims()
	local animIds = GetComboAnimIds()
	for i = 1, #animIds do
		local anim = Instance.new("Animation")
		anim.AnimationId = animIds[i]
		anim.Name = "ComboAnim" .. i
		comboAnimInstances[i] = anim
	end
end

local function GetAnimator(): Animator?
	local char = player.Character
	if not char then return nil end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return nil end
	return hum:FindFirstChild("Animator")
end

local function ResetAnimations()
	for i, track in comboTracks do
		if track then track:Stop(0) end
		comboTracks[i] = nil
	end
	if blockTrack then blockTrack:Stop(0); blockTrack = nil end
	blockAnim = nil

	-- Stop weapon stance anims
	if idleTrack then idleTrack:Stop(0.2); idleTrack = nil end
	if walkTrack then walkTrack:Stop(0.2); walkTrack = nil end
	idleAnim = nil
	walkAnim = nil
	isWeaponEquipped = false

	local animIds = GetComboAnimIds()
	for i = 1, #animIds do
		if comboAnimInstances[i] then comboAnimInstances[i]:Destroy() end
		local anim = Instance.new("Animation")
		anim.AnimationId = animIds[i]
		anim.Name = "ComboAnim" .. i
		comboAnimInstances[i] = anim
	end
end

-- ═══ ANIMATION MARKERS → TRAIL + VFX ═══

--- Подключить все маркеры (Trail + VFX) к AnimationTrack
local function ConnectAllMarkers(track: AnimationTrack, weaponId: string, comboHit: number)
	print("[CombatController] ConnectAllMarkers for " .. weaponId)
	-- Trail маркеры
	local startMarker, endMarker = WeaponVFX.GetMarkerNames(weaponId)
	print("[CombatController] Trail markers: " .. tostring(startMarker) .. " / " .. tostring(endMarker))
	if startMarker then
		track:GetMarkerReachedSignal(startMarker):Connect(function()
			print("[CombatController] Marker HIT: " .. startMarker .. " → EnableTrail")
			WeaponVFX.EnableTrail(weaponId)
		end)
	end
	if endMarker then
		track:GetMarkerReachedSignal(endMarker):Connect(function()
			print("[CombatController] Marker HIT: " .. endMarker .. " → DisableTrail")
			WeaponVFX.DisableTrail(weaponId)
		end)
	end

	-- VFX маркеры (Slash/Hit)
	local vfxMap = WeaponVFX.GetVFXMarkerMap(weaponId)
	local vfxCount = 0
	for markerName, entries in vfxMap do
		vfxCount += 1
		print("[CombatController] VFX marker: " .. markerName .. " (" .. #entries .. " entries)")
		track:GetMarkerReachedSignal(markerName):Connect(function()
			print("[CombatController] Marker HIT: " .. markerName .. " → SpawnVFX (comboHit=" .. comboHit .. ")")
			local char = player.Character
			if not char then return end
			for _, entry in entries do
				if entry.ComboHit == nil or entry.ComboHit == comboHit then
					WeaponVFX.SpawnVFX(char, entry)
				end
			end
		end)
	end
	print("[CombatController] Total VFX markers connected: " .. vfxCount)
end

local function PlayComboAnim(comboCount: number)
	local idx = math.clamp(comboCount, 1, 4)
	local animator = GetAnimator()
	if not animator then return end

	for trackIndex, track in comboTracks do
		if track and track.IsPlaying then
			track:Stop(if trackIndex == idx then 0 else 0.05)
		end
	end

	if not comboTracks[idx] then
		comboTracks[idx] = animator:LoadAnimation(comboAnimInstances[idx])
		comboTracks[idx].Priority = Enum.AnimationPriority.Action4

		-- Подключаем все маркеры (trail + VFX) при первой загрузке трека
		if currentWeaponId then
			ConnectAllMarkers(comboTracks[idx] :: AnimationTrack, currentWeaponId, idx)
		end
	end

	comboTracks[idx]:Play(0.1)
	task.delay(0.5, function()
		if comboTracks[idx] and comboTracks[idx].IsPlaying then
			comboTracks[idx]:Stop(0.2)
		end
	end)
end

local function PlayBlockStart()
	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local animator = hum:FindFirstChild("Animator")
	if not animator then return end

	if blockAnim == nil then
		blockAnim = Instance.new("Animation")
		blockAnim.AnimationId = AnimationData.BlockAnimId
		blockAnim.Name = "BlockAnim"
		blockTrack = nil
	end

	if blockTrack == nil then
		blockTrack = animator:LoadAnimation(blockAnim)
		blockTrack.Priority = Enum.AnimationPriority.Action3
		blockTrack.Looped = true
	end
	if not blockTrack.IsPlaying then blockTrack:Play() end
end

local function PlayBlockEnd()
	if blockTrack and blockTrack.IsPlaying then blockTrack:Stop() end
end

-- ═══ WEAPON STANCE ANIMATIONS ═══

--- Запустить idle/walk анимации оружия
local function StartWeaponStance()
	local animator = GetAnimator()
	if not animator then return end

	local idleId = GetIdleAnimId()
	if idleId then
		idleAnim = Instance.new("Animation")
		idleAnim.AnimationId = idleId
		idleAnim.Name = "WeaponIdle"
		idleTrack = animator:LoadAnimation(idleAnim)
		idleTrack.Priority = Enum.AnimationPriority.Action
		idleTrack.Looped = true
		idleTrack:Play(0.2)
	end

	local walkId = GetWalkAnimId()
	if walkId then
		walkAnim = Instance.new("Animation")
		walkAnim.AnimationId = walkId
		walkAnim.Name = "WeaponWalk"
		walkTrack = animator:LoadAnimation(walkAnim)
		walkTrack.Priority = Enum.AnimationPriority.Action
		walkTrack.Looped = true
	end

	isWeaponEquipped = true
end

--- Остановить idle/walk анимации оружия
local function StopWeaponStance()
	if idleTrack then idleTrack:Stop(0.2); idleTrack = nil end
	if walkTrack then walkTrack:Stop(0.2); walkTrack = nil end
	idleAnim = nil
	walkAnim = nil
	isWeaponEquipped = false
end

--- Проиграть анимацию доставания оружия (один раз)
local function PlayUnsheath()
	local unsheathId = GetUnsheathAnimId()
	if not unsheathId then
		StartWeaponStance()
		return
	end

	local animator = GetAnimator()
	if not animator then return end

	local anim = Instance.new("Animation")
	anim.AnimationId = unsheathId
	anim.Name = "WeaponUnsheath"
	local track = animator:LoadAnimation(anim)
	track.Priority = Enum.AnimationPriority.Action2
	track.Looped = false

	track:GetMarkerReachedSignal("UnsheathDone"):Connect(function()
		StartWeaponStance()
	end)

	track.Stopped:Connect(function()
		if isWeaponEquipped == false then
			StartWeaponStance()
		end
	end)

	track:Play(0.1)
	task.delay(track.Length + 0.1, function()
		if anim and anim.Parent then anim:Destroy() end
	end)
end

--- Управление walk-анимацией по скорости персонажа
local function UpdateWalkAnimation()
	if not isWeaponEquipped or not walkTrack then return end
	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	if hum.MoveDirection.Magnitude > 0.1 then
		if not walkTrack.IsPlaying then walkTrack:Play(0.2) end
		if idleTrack and idleTrack.IsPlaying then idleTrack:Stop(0.2) end
	else
		if walkTrack.IsPlaying then walkTrack:Stop(0.2) end
		if idleTrack and not idleTrack.IsPlaying then idleTrack:Play(0.2) end
	end
end

-- ═══ LIFECYCLE ═══

function CombatController:Init()
	-- Find UI from StarterGui (cloned to PlayerGui)
	local playerGui = player:WaitForChild("PlayerGui")
	local combatUI = playerGui:WaitForChild("CombatUI", 10)
	if combatUI then
		comboFrame = combatUI:FindFirstChild("ComboCounter")
		if comboFrame then
			comboText = comboFrame:FindFirstChild("ComboText")
		end
	end

	CreateComboAnims()
end

function CombatController:Start()
	-- Input
	UserInputService.InputBegan:Connect(function(input: InputObject, gp: boolean)
		if gp then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			RequestAttack()
		elseif input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.R then
				RemoteManager.FireServer("CombatAction", "dash")
			elseif input.KeyCode == Enum.KeyCode.F then
				PlayBlockStart()
				RemoteManager.FireServer("CombatAction", "block_start")
			end
		end
	end)

	UserInputService.InputEnded:Connect(function(input: InputObject, gp: boolean)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.F then
			PlayBlockEnd()
			RemoteManager.FireServer("CombatAction", "block_end")
		end
	end)

	-- Combo timer tick + walk animation update
	RunService.Heartbeat:Connect(function(dt: number)
		if comboDisplayActive then
			comboTimeoutTimer -= dt
			if comboTimeoutTimer <= 0 then HideCombo() end
		end
		UpdateWalkAnimation()
	end)

	-- Server events
	RemoteManager.OnClientEvent("ComboUpdated", function(c: number)
		if c and c > 0 then
			ShowCombo(c)
			PlayComboAnim(c)
		end
	end)

	-- Weapon equip tracking — обновляем анимации при смене оружия
	RemoteManager.OnClientEvent("InventoryUpdate", function(_invList: any, equipList: any)
		if typeof(equipList) == "table" then
			local weaponEntry = equipList.Weapon
			local newWeaponId = if weaponEntry and weaponEntry.Id then weaponEntry.Id else nil
			if newWeaponId ~= currentWeaponId then
				-- Сняли оружие
				if currentWeaponId and not newWeaponId then
					StopWeaponStance()
					WeaponVFX.CleanupAll(currentWeaponId)
				end
				currentWeaponId = newWeaponId
				ResetAnimations()
				-- Экипировали оружие
				if newWeaponId then
					task.delay(0.1, function()
						local char = player.Character
						if char then
							WeaponVFX.SetupTrail(char, newWeaponId)
						end
						PlayUnsheath()
					end)
				end
			end
		end
	end)
	
	-- HitVFX: сервер присылает позицию попадания
	RemoteManager.OnClientEvent("HitVFX", function(hitCFrame: CFrame)
		if not currentWeaponId then return end
		local char = player.Character
		if not char then return end

		local itemDef = ItemData.GetItem(currentWeaponId)
		if not itemDef or not itemDef.VFX or not itemDef.VFX.HitVFX then return end

		for _, entry in itemDef.VFX.HitVFX do
			WeaponVFX.SpawnVFX(char, entry, hitCFrame)
		end
	end)

	player.CharacterAdded:Connect(function()
		task.wait(0.5)
		ResetAnimations()
	end)

	print("[CombatController] Started")
end

return CombatController
