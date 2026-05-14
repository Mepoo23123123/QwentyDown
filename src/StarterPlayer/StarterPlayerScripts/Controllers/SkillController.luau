--!strict
-- SkillController — Скилы (Z/X/C) + Script-Made ActionBar
-- Полностью скриптовый ActionBar с анимациями
-- luau-best-practices: Strict mode, typed API, Factory pattern

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SkillData = require(ReplicatedStorage.Modules.SkillData)
local ClassData = require(ReplicatedStorage.Modules.ClassData)
local RemoteManager = require(ReplicatedStorage.Remotes.RemoteManager)

local SkillController = {}
local player = Players.LocalPlayer

-- ═══════════════════════════════════════════
-- CONFIG
-- ═══════════════════════════════════════════

local PALETTE = {
	Background = Color3.fromRGB(8, 8, 10),
	Surface = Color3.fromRGB(19, 17, 19),
	SurfaceHover = Color3.fromRGB(30, 27, 29),
	Primary = Color3.fromRGB(146, 126, 96),
	Text = Color3.fromRGB(205, 197, 190),
	TextDark = Color3.fromRGB(125, 116, 108),
	Melee = Color3.fromRGB(144, 73, 69),
	Buff = Color3.fromRGB(113, 134, 96),
	Utility = Color3.fromRGB(95, 116, 142),
	Cooldown = Color3.fromRGB(4, 4, 6),
}

local SLOT_SIZE = 56
local SLOT_GAP = 10
local BORDER_RADIUS = 10
local SLOT_KEYS = {[1]="M1", [2]="Z", [3]="X", [4]="C"}
local VFX_MARKER_NAME = "VFXMAKINAME"

-- ═══════════════════════════════════════════
-- STATE
-- ═══════════════════════════════════════════

local screenGui: ScreenGui? = nil
local actionBar: Frame? = nil
local slotFrames: { [number]: Frame } = {}
local slotOverlays: { [number]: Frame } = {}
local slotTimers: { [number]: TextLabel } = {}
local slotIcons: { [number]: ImageLabel } = {}
local slotBorders: { [number]: UIStroke } = {}
local slotCooldowns: { [number]: boolean } = {}
local skillAnimations: { [number]: { Animation: Animation, Track: AnimationTrack?, MarkerName: string?, VFXTemplateName: string? } } = {}

-- ═══════════════════════════════════════════
-- UI FACTORY
-- ═══════════════════════════════════════════

local function CreateActionBar()
	local pg = player:WaitForChild("PlayerGui")
	
	-- Main ScreenGui
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SkillActionBar"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = 50
	screenGui.Parent = pg
	
	-- Background bar
	actionBar = Instance.new("Frame")
	actionBar.Name = "ActionBar"
	actionBar.Size = UDim2.fromOffset((SLOT_SIZE + SLOT_GAP) * 4 + SLOT_GAP, SLOT_SIZE + SLOT_GAP * 2 + 20)
	actionBar.Position = UDim2.new(0.5, 0, 1, -110)
	actionBar.AnchorPoint = Vector2.new(0.5, 0.5)
	actionBar.BackgroundColor3 = PALETTE.Background
	actionBar.BackgroundTransparency = 0.15
	actionBar.BorderSizePixel = 0
	actionBar.Parent = screenGui
	
	-- Bar corner
	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0, BORDER_RADIUS + 4)
	barCorner.Parent = actionBar
	
	-- Bar stroke (glow)
	local barStroke = Instance.new("UIStroke")
	barStroke.Color = PALETTE.Primary
	barStroke.Thickness = 1.5
	barStroke.Transparency = 0.5
	barStroke.Parent = actionBar
	
	-- Bar shadow
	local shadow = Instance.new("UIStroke")
	shadow.Color = Color3.new(0, 0, 0)
	shadow.Thickness = 4
	shadow.Transparency = 0.7
	shadow.Parent = actionBar
	
	-- Create 4 slots
	for i = 1, 4 do
		local slot = Instance.new("Frame")
		slot.Name = "SkillSlot" .. i
		slot.Size = UDim2.fromOffset(SLOT_SIZE, SLOT_SIZE)
		slot.Position = UDim2.fromOffset(SLOT_GAP + (i - 1) * (SLOT_SIZE + SLOT_GAP), SLOT_GAP)
		slot.BackgroundColor3 = PALETTE.Surface
		slot.BorderSizePixel = 0
		slot.Parent = actionBar
		
		-- Corner
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, BORDER_RADIUS)
		corner.Parent = slot
		
		-- Border
		local border = Instance.new("UIStroke")
		border.Color = PALETTE.Primary
		border.Thickness = 1.5
		border.Transparency = 0.4
		border.Parent = slot
		
		-- Icon (center)
		local icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.Size = UDim2.fromScale(0.7, 0.7)
		icon.Position = UDim2.fromScale(0.5, 0.45)
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.BackgroundTransparency = 1
		icon.Image = ""
		icon.Parent = slot
		
		-- Key label (bottom)
		local keyLabel = Instance.new("TextLabel")
		keyLabel.Name = "KeyLabel"
		keyLabel.Size = UDim2.new(1, 0, 0, 16)
		keyLabel.Position = UDim2.new(0, 0, 1, -16)
		keyLabel.BackgroundTransparency = 1
		keyLabel.Text = SLOT_KEYS[i]
		keyLabel.TextColor3 = PALETTE.TextDark
		keyLabel.Font = Enum.Font.Garamond
		keyLabel.TextSize = 10
		keyLabel.Parent = slot
		
		-- Cooldown overlay
		local overlay = Instance.new("Frame")
		overlay.Name = "CooldownOverlay"
		overlay.Size = UDim2.fromScale(1, 0)
		overlay.Position = UDim2.fromScale(0, 1)
		overlay.AnchorPoint = Vector2.new(0, 1)
		overlay.BackgroundColor3 = PALETTE.Cooldown
		overlay.BackgroundTransparency = 0.25
		overlay.BorderSizePixel = 0
		overlay.Visible = false
		overlay.ZIndex = 2
		overlay.Parent = slot
		
		local overlayCorner = Instance.new("UICorner")
		overlayCorner.CornerRadius = UDim.new(0, BORDER_RADIUS)
		overlayCorner.Parent = overlay
		
		-- Timer text
		local timer = Instance.new("TextLabel")
		timer.Name = "Timer"
		timer.Size = UDim2.fromScale(1, 1)
		timer.BackgroundTransparency = 1
		timer.Text = ""
		timer.TextColor3 = Color3.new(1, 1, 1)
		timer.Font = Enum.Font.Fantasy
		timer.TextSize = 20
		timer.TextStrokeTransparency = 0.3
		timer.TextStrokeColor3 = Color3.new(0, 0, 0)
		timer.ZIndex = 3
		timer.Parent = slot
		
		-- Hover effects
		slot.MouseEnter:Connect(function()
			if not slotCooldowns[i] then
				TweenService:Create(slot, TweenInfo.new(0.15), {
					BackgroundColor3 = PALETTE.SurfaceHover,
				}):Play()
				TweenService:Create(border, TweenInfo.new(0.15), {
					Transparency = 0.1,
				}):Play()
			end
		end)
		
		slot.MouseLeave:Connect(function()
			TweenService:Create(slot, TweenInfo.new(0.15), {
				BackgroundColor3 = PALETTE.Surface,
			}):Play()
			TweenService:Create(border, TweenInfo.new(0.15), {
				Transparency = 0.4,
			}):Play()
		end)
		
		-- Store refs
		slotFrames[i] = slot
		slotOverlays[i] = overlay
		slotTimers[i] = timer
		slotIcons[i] = icon
		slotBorders[i] = border
		slotCooldowns[i] = false
	end
	
	-- Intro animation
	actionBar.Size = UDim2.fromOffset(0, 0)
	actionBar.BackgroundTransparency = 1
	TweenService:Create(actionBar, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset((SLOT_SIZE + SLOT_GAP) * 4 + SLOT_GAP, SLOT_SIZE + SLOT_GAP * 2 + 20),
		BackgroundTransparency = 0.15,
	}):Play()
end

-- ═══════════════════════════════════════════
-- SKILL DATA UPDATE
-- ═══════════════════════════════════════════

local function UpdateSkillDisplay(classId: string)
	local classDef = ClassData.GetClass(classId)
	if not classDef then return end
	
	skillAnimations = {}
	
	-- Slot 1 = Basic Attack (always)
	slotIcons[1].Image = "rbxassetid://75954734479098"
	slotBorders[1].Color = PALETTE.Melee
	
	-- Slots 2-4 = Class skills
	for slotNum = 2, 4 do
		local skillId = classDef.StartingSkills[slotNum - 1]
		local skill = SkillData.GetSkill(skillId)
		
		if skill then
			-- Set icon
			if skill.IconId then
				slotIcons[slotNum].Image = skill.IconId
			end
			
			-- Color by type
			if skill.Type == "melee" or skill.Type == "ranged" then
				slotBorders[slotNum].Color = PALETTE.Melee
			elseif skill.Type == "buff" then
				slotBorders[slotNum].Color = PALETTE.Buff
			elseif skill.Type == "utility" then
				slotBorders[slotNum].Color = PALETTE.Utility
			end
			
			-- Load animation
			if skill.AnimationId and skill.AnimationId > 0 then
				local anim = Instance.new("Animation")
				anim.AnimationId = "rbxassetid://" .. skill.AnimationId
				anim.Name = skill.Name .. "Anim"
				skillAnimations[slotNum] = {
					Animation = anim,
					Track = nil,
					MarkerName = skill.VFXMarkerName,
					VFXTemplateName = skill.VFXTemplateName,
				}
			end
		end
	end
end

-- ═══════════════════════════════════════════
-- COOLDOWN
-- ═══════════════════════════════════════════

local function ShowCooldown(slotNum: number, duration: number)
	local overlay = slotOverlays[slotNum]
	local timer = slotTimers[slotNum]
	local border = slotBorders[slotNum]
	if not overlay or not timer then return end
	
	overlay.Size = UDim2.fromScale(1, 0)
	overlay.Visible = true
	timer.Visible = true
	timer.Text = tostring(math.ceil(duration))
	slotCooldowns[slotNum] = true
	
	-- Flash border white
	local originalColor = border.Color
	border.Color = Color3.new(1, 1, 1)
	TweenService:Create(border, TweenInfo.new(0.3), {Color = originalColor}):Play()
	
	-- Animate overlay filling
	TweenService:Create(overlay, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		Size = UDim2.fromScale(1, 1),
	}):Play()
	
	-- Countdown
	task.spawn(function()
		local count = math.ceil(duration)
		while count > 0 do
			task.wait(1)
			count -= 1
			if timer and timer.Parent then
				timer.Text = count > 0 and tostring(count) or ""
			end
		end
		
		if overlay and overlay.Parent then
			overlay.Visible = false
		end
		if timer and timer.Parent then
			timer.Visible = false
		end
		slotCooldowns[slotNum] = false
	end)
end

-- ═══════════════════════════════════════════
-- ANIMATIONS
-- ═══════════════════════════════════════════

local function EmitSkillVFX(templateName: string?)
	local character = player.Character
	if not character then return end

	local vfxFolder = ReplicatedStorage:FindFirstChild("SkillVFX")
	if not vfxFolder then return end

	local chosenTemplateName = templateName or "Main"
	local templateSource = vfxFolder:FindFirstChild(chosenTemplateName)
		or ReplicatedStorage:FindFirstChild(chosenTemplateName)

	local template: Attachment? = nil
	if templateSource then
		if templateSource:IsA("Attachment") then
			template = templateSource
		else
			local mainAttachment = templateSource:FindFirstChild("Main")
			if mainAttachment and mainAttachment:IsA("Attachment") then
				template = mainAttachment
			end
		end
	end

	if not template then
		local fallbackMain = vfxFolder:FindFirstChild("Main")
		if fallbackMain and fallbackMain:IsA("Attachment") then
			template = fallbackMain
		end
	end

	if not template then return end

	local parentPart = character:FindFirstChild("HumanoidRootPart")
		or character:FindFirstChild("UpperTorso")
		or character:FindFirstChild("Torso")
	if not parentPart or not parentPart:IsA("BasePart") then return end

	local attachment = template:Clone()
	attachment.Parent = parentPart

	local maxLifetime = 0
	for _, descendant in attachment:GetDescendants() do
		if descendant:IsA("ParticleEmitter") then
			local customCount = descendant:GetAttribute("EmitCount")
			local emitCount = (typeof(customCount) == "number" and math.max(1, math.floor(customCount))) or 12
			descendant:Emit(emitCount)
			maxLifetime = math.max(maxLifetime, descendant.Lifetime.Max)
		end
	end

	task.delay(math.max(0.5, maxLifetime + 0.15), function()
		if attachment.Parent then
			attachment:Destroy()
		end
	end)
end

local function PlaySkillAnim(slotNum: number)
	local animData = skillAnimations[slotNum]
	if not animData or not player.Character then return end
	
	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	
	if animData.Track and animData.Track.IsPlaying then
		animData.Track:Stop(0.1)
	end
	
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	animData.Track = animator:LoadAnimation(animData.Animation)
	animData.Track.Priority = Enum.AnimationPriority.Action4
	animData.Track.Looped = false

	local track = animData.Track
	local didEmitVFX = false
	local function triggerVFX(source: string)
		if didEmitVFX then return end
		didEmitVFX = true
		print("[SkillController] VFX trigger via", source)
		EmitSkillVFX(animData.VFXTemplateName)
	end

	local markerName = animData.MarkerName or VFX_MARKER_NAME
	track:GetMarkerReachedSignal(markerName):Connect(function()
		triggerVFX("marker:" .. markerName)
	end)

	track:Play(0.1)
	
	-- Pulse slot
	local slot = slotFrames[slotNum]
	if slot then
		local originalSize = slot.Size
		TweenService:Create(slot, TweenInfo.new(0.1), {
			Size = UDim2.fromOffset(SLOT_SIZE + 4, SLOT_SIZE + 4),
		}):Play()
		task.wait(0.1)
		TweenService:Create(slot, TweenInfo.new(0.1), {
			Size = originalSize,
		}):Play()
	end
end

-- ═══════════════════════════════════════════
-- LIFECYCLE
-- ═══════════════════════════════════════════

function SkillController:Init()
	CreateActionBar()
end

local function CheckMenusOpen(): boolean
	local pg = player:FindFirstChild("PlayerGui")
	if not pg then return false end
	
	-- Check WheelOfStats
	local statsGui = pg:FindFirstChild("WheelOfStats")
	if statsGui and statsGui.Enabled then
		local mainFrame = statsGui:FindFirstChild("WheelFrame")
		if mainFrame and mainFrame.Visible then return true end
	end
	
	return false
end

local function UpdateVisibility()
	if screenGui then
		screenGui.Enabled = not CheckMenusOpen()
	end
end

function SkillController:Start()
	-- Monitor other menus
	local pg = player:FindFirstChild("PlayerGui")
	if pg then
		pg.ChildAdded:Connect(function(child)
			if child:IsA("ScreenGui") then
				child:GetPropertyChangedSignal("Enabled"):Connect(UpdateVisibility)
			end
		end)
		for _, gui in pg:GetChildren() do
			if gui:IsA("ScreenGui") then
				gui:GetPropertyChangedSignal("Enabled"):Connect(UpdateVisibility)
			end
		end
	end
	
	-- Input
	UserInputService.InputBegan:Connect(function(input: InputObject, gp: boolean)
		if gp then return end
		if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		
		local slotMap = {[Enum.KeyCode.Z]=2, [Enum.KeyCode.X]=3, [Enum.KeyCode.C]=4}
		local slotNum = slotMap[input.KeyCode]
		if not slotNum then return end
		if slotCooldowns[slotNum] then return end
		
		PlaySkillAnim(slotNum)
		RemoteManager.FireServer("SkillCast", slotNum)
	end)
	
	-- Server cooldown
	RemoteManager.OnClientEvent("SkillCooldown", function(slotNum: number, duration: number)
		ShowCooldown(slotNum, duration)
	end)
	
	-- Class changes
	player:GetAttributeChangedSignal("ClassId"):Connect(function()
		local classId = player:GetAttribute("ClassId") or "warrior"
		UpdateSkillDisplay(classId)
	end)
	
	player.CharacterAdded:Connect(function()
		task.wait(0.5)
		local classId = player:GetAttribute("ClassId") or "warrior"
		UpdateSkillDisplay(classId)
	end)
	
	-- Initial
	local initialClass = player:GetAttribute("ClassId") or "maki_zenin"
	UpdateSkillDisplay(initialClass)
	
	print("[SkillController] Started with Script-Made ActionBar")
end

return SkillController
