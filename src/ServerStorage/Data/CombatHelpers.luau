--!strict
-- CombatHelpers — Утилиты боя (AddEXP, ApplyDamage)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local EXPManager = require(ReplicatedStorage.Modules.EXPManager)
local StatsHelper = require(ReplicatedStorage.Modules.StatsHelper)
local RemoteManager = require(ReplicatedStorage.Remotes.RemoteManager)

local CombatHelpers = {}

function CombatHelpers.AddEXP(player: Player, amount: number)
	EXPManager.AddEXP(player, amount)
end

function CombatHelpers.ApplyDamage(attacker: Player, damage: number, target: Model)
	local stats = target:FindFirstChild("Stats")
	if not stats then return end

	local hp = stats:FindFirstChild("HP")
	if not hp then return end

	hp.Value = math.max(hp.Value - damage, 0)
	
	if damage > 0 and attacker then
		CombatHelpers.AddEXP(attacker, math.max(1, math.floor(damage * 0.5)))
		ShowDamageNumber(target, damage)
	end

	if hp.Value <= 0 then
		local nh = target:FindFirstChildOfClass("Humanoid")
		if nh then nh.Health = 0 end
	end
end

function CombatHelpers.ApplyDamageToPlayer(targetModel: Model, damage: number, targetPlayer: Player)
	if not targetPlayer then return end
	local stats = targetPlayer:FindFirstChild("Stats")
	if not stats then return end

	local hp = stats:FindFirstChild("HP")
	if not hp then return end

	hp.Value = math.max(hp.Value - damage, 0)
	
	if damage > 0 and targetPlayer then
		CombatHelpers.AddEXP(targetPlayer, math.max(1, math.floor(damage * 0.5)))
		ShowDamageNumber(targetPlayer.Character, damage)
	end

	if hp.Value <= 0 and targetPlayer.Character then
		local nh = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
		if nh then nh.Health = 0 end
	end
end

function ShowDamageNumber(target: Model, damage: number)
	if not target then return end
	local hrp = target:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "DamageNumber"
	billboard.Size = UDim2.fromOffset(100, 40)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = hrp
	
	local text = Instance.new("TextLabel")
	text.Name = "Text"
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.GothamBlack
	text.TextSize = 26
	text.TextColor3 = Color3.fromRGB(255, 80, 80)
	text.TextStrokeTransparency = 0.5
	text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	text.TextScaled = true
	text.Text = tostring(damage)
	text.Parent = billboard
	
	TweenService:Create(billboard, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		StudsOffset = Vector3.new(0, 5, 0),
	}):Play()
	TweenService:Create(text, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0.8,
	}):Play()
	
	task.delay(0.8, function()
		if billboard and billboard.Parent then billboard:Destroy() end
	end)
end

return CombatHelpers
