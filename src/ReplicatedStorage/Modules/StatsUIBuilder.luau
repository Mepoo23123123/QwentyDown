--!strict
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local StatsUIBuilder = {}

StatsUIBuilder.PALETTE = {
	Void = Color3.fromRGB(2, 2, 4),
	Ink = Color3.fromRGB(7, 7, 10),
	Deep = Color3.fromRGB(12, 10, 15),
	Panel = Color3.fromRGB(17, 14, 19),
	Panel2 = Color3.fromRGB(25, 21, 29),
	Rune = Color3.fromRGB(146, 126, 96),
	RuneDim = Color3.fromRGB(62, 54, 46),
	Text = Color3.fromRGB(222, 214, 203),
	Muted = Color3.fromRGB(131, 121, 112),
	Gold = Color3.fromRGB(215, 168, 72),
	Green = Color3.fromRGB(76, 126, 91),
	Red = Color3.fromRGB(121, 45, 49),
	Blue = Color3.fromRGB(83, 116, 157),
}

local PALETTE = StatsUIBuilder.PALETTE
local fastTweenInfo = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local openTweenInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

export type StatsUIRefs = {
	screenGui: ScreenGui,
	veil: Frame,
	shell: Frame,
	leftPanel: Frame,
	centerPanel: Frame,
	rightPanel: Frame,
	contentScale: UIScale,
	pointsLabel: TextLabel,
	pendingLabel: TextLabel,
	classLabel: TextLabel,
	levelLabel: TextLabel,
	expLabel: TextLabel,
	hpLabel: TextLabel,
	mpLabel: TextLabel,
	detailTitle: TextLabel,
	detailText: TextLabel,
	confirmButton: TextButton,
	cancelButton: TextButton,
	resetButton: TextButton,
	closeButton: TextButton,
	derivedRowsContainer: Frame,
	particles: { Frame },
}

function StatsUIBuilder.make(className: string, props: { [string]: any }): Instance
	local object = Instance.new(className)
	for property, value in props do
		if property ~= "Parent" then
			(object :: any)[property] = value
		end
	end
	object.Parent = props.Parent
	return object
end

function StatsUIBuilder.addCorner(parent: Instance, radius: number): UICorner
	return StatsUIBuilder.make("UICorner", { CornerRadius = UDim.new(0, radius), Parent = parent }) :: UICorner
end

function StatsUIBuilder.addStroke(parent: Instance, color: Color3, transparency: number, thickness: number): UIStroke
	return StatsUIBuilder.make("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = color, Transparency = transparency, Thickness = thickness, Parent = parent }) :: UIStroke
end

function StatsUIBuilder.addGradient(parent: Instance, top: Color3, bottom: Color3, rotation: number): UIGradient
	return StatsUIBuilder.make("UIGradient", { Color = ColorSequence.new(top, bottom), Rotation = rotation, Parent = parent }) :: UIGradient
end

function StatsUIBuilder.label(parent: Instance, textValue: string, size: number, color: Color3, align: Enum.TextXAlignment?): TextLabel
	return StatsUIBuilder.make("TextLabel", {
		BackgroundTransparency = 1,
		Font = Enum.Font.Garamond,
		Text = textValue,
		TextColor3 = color,
		TextSize = size,
		TextStrokeColor3 = Color3.new(0, 0, 0),
		TextStrokeTransparency = 0.62,
		TextXAlignment = align or Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = parent,
	}) :: TextLabel
end

function StatsUIBuilder.button(parent: Instance, textValue: string, size: UDim2, position: UDim2): TextButton
	local object = StatsUIBuilder.make("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = PALETTE.Panel2,
		BorderSizePixel = 0,
		Font = Enum.Font.Garamond,
		Position = position,
		Size = size,
		Text = textValue,
		TextColor3 = PALETTE.Text,
		TextSize = 15,
		TextStrokeColor3 = Color3.new(0, 0, 0),
		TextStrokeTransparency = 0.62,
		Parent = parent,
	}) :: TextButton
	StatsUIBuilder.addCorner(object, 8)
	local stroke = StatsUIBuilder.addStroke(object, PALETTE.RuneDim, 0.2, 1)
	object.MouseEnter:Connect(function()
		TweenService:Create(object, fastTweenInfo, { BackgroundColor3 = Color3.fromRGB(32, 27, 36) }):Play()
		TweenService:Create(stroke, fastTweenInfo, { Color = PALETTE.Rune, Transparency = 0.05 }):Play()
	end)
	object.MouseLeave:Connect(function()
		TweenService:Create(object, fastTweenInfo, { BackgroundColor3 = PALETTE.Panel2 }):Play()
		TweenService:Create(stroke, fastTweenInfo, { Color = PALETTE.RuneDim, Transparency = 0.2 }):Play()
	end)
	return object
end

function StatsUIBuilder.line(parent: Instance, position: UDim2, size: UDim2, color: Color3?)
	StatsUIBuilder.make("Frame", { BackgroundColor3 = color or PALETTE.RuneDim, BorderSizePixel = 0, Position = position, Size = size, Parent = parent })
end

function StatsUIBuilder.addCornerGlyphs(parent: GuiObject)
	local glyphs = {
		{ "⌜", UDim2.fromOffset(2, -2) },
		{ "⌝", UDim2.new(1, -20, 0, -2) },
		{ "⌞", UDim2.new(0, 2, 1, -21) },
		{ "⌟", UDim2.new(1, -20, 1, -21) },
	}
	for _, item in glyphs do
		local glyph = StatsUIBuilder.label(parent, item[1], 20, PALETTE.Rune, Enum.TextXAlignment.Center)
		glyph.Position = item[2]
		glyph.Size = UDim2.fromOffset(18, 20)
		glyph.ZIndex = parent.ZIndex + 2
	end
end

function StatsUIBuilder.ornament(parent: Instance, textValue: string, position: UDim2, size: UDim2): Frame
	local holder = StatsUIBuilder.make("Frame", { BackgroundColor3 = PALETTE.Ink, BackgroundTransparency = 0.05, BorderSizePixel = 0, Position = position, Size = size, Parent = parent }) :: Frame
	StatsUIBuilder.addStroke(holder, PALETTE.RuneDim, 0.08, 1)
	local title = StatsUIBuilder.label(holder, textValue, 17, PALETTE.Text, Enum.TextXAlignment.Center)
	title.Size = UDim2.fromScale(1, 1)
	return holder
end

function StatsUIBuilder.createNoise(parent: Instance): { Frame }
	local particles: { Frame } = {}
	for i = 1, 52 do
		local x = ((i * 37) % 100) / 100
		local y = ((i * 61) % 100) / 100
		local particle = StatsUIBuilder.make("Frame", {
			BackgroundColor3 = if i % 2 == 0 then Color3.fromRGB(24, 22, 25) else Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.78 + (((i * 13) % 12) / 100),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(x, y),
			Size = UDim2.fromOffset((i % 4) + 1, (i % 8) + 2),
			Parent = parent,
		}) :: Frame
		table.insert(particles, particle)
	end
	return particles
end

function StatsUIBuilder.build(): StatsUIRefs
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local existing = playerGui:FindFirstChild("WheelOfStats")
	if existing then
		existing:Destroy()
	end

	local screenGui = StatsUIBuilder.make("ScreenGui", { Name = "WheelOfStats", DisplayOrder = 62, IgnoreGuiInset = true, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = playerGui }) :: ScreenGui
	local veil = StatsUIBuilder.make("Frame", { BackgroundColor3 = PALETTE.Void, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Visible = false, Parent = screenGui }) :: Frame
	local particles = StatsUIBuilder.createNoise(veil)
	local shell = StatsUIBuilder.make("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = PALETTE.Panel, BorderSizePixel = 0, Position = UDim2.fromScale(0.5, 0.52), Size = UDim2.fromScale(0.78, 0.78), Visible = false, Parent = veil }) :: Frame
	StatsUIBuilder.make("UISizeConstraint", { MinSize = Vector2.new(860, 590), MaxSize = Vector2.new(1060, 720), Parent = shell })
	local contentScale = StatsUIBuilder.make("UIScale", { Scale = 0.94, Parent = shell }) :: UIScale
	StatsUIBuilder.addCorner(shell, 14)
	StatsUIBuilder.addStroke(shell, PALETTE.RuneDim, 0.18, 1)
	StatsUIBuilder.addGradient(shell, Color3.fromRGB(18, 15, 21), Color3.fromRGB(4, 4, 6), 90)
	StatsUIBuilder.make("UIPadding", { PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), Parent = shell })
	StatsUIBuilder.addCornerGlyphs(shell)
	StatsUIBuilder.ornament(shell, "Attribute Ritual", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 30))
	StatsUIBuilder.line(shell, UDim2.fromOffset(0, 38), UDim2.new(1, 0, 0, 1), PALETTE.RuneDim)
	local closeButton = StatsUIBuilder.button(shell, "×", UDim2.fromOffset(28, 30), UDim2.new(1, -28, 0, 0))
	closeButton.TextSize = 20

	local leftPanel = StatsUIBuilder.make("Frame", { BackgroundColor3 = PALETTE.Panel, BorderSizePixel = 0, Position = UDim2.new(0, 0, 0, 48), Size = UDim2.new(0.27, -8, 1, -48), Parent = shell }) :: Frame
	StatsUIBuilder.addCorner(leftPanel, 14)
	StatsUIBuilder.addStroke(leftPanel, PALETTE.RuneDim, 0.35, 1)
	StatsUIBuilder.addGradient(leftPanel, Color3.fromRGB(19, 16, 22), Color3.fromRGB(5, 5, 8), 90)

	local classLabel = StatsUIBuilder.label(leftPanel, "MAKI ZENIN", 19, PALETTE.Text, Enum.TextXAlignment.Center)
	classLabel.Position = UDim2.fromOffset(12, 196)
	classLabel.Size = UDim2.new(1, -24, 0, 26)
	local levelLabel = StatsUIBuilder.label(leftPanel, "LVL 1", 18, PALETTE.Gold, Enum.TextXAlignment.Center)
	levelLabel.Position = UDim2.fromOffset(12, 222)
	levelLabel.Size = UDim2.new(1, -24, 0, 24)
	local expLabel = StatsUIBuilder.label(leftPanel, "EXP 0 / 0", 14, PALETTE.Muted, Enum.TextXAlignment.Center)
	expLabel.Position = UDim2.fromOffset(12, 250)
	expLabel.Size = UDim2.new(1, -24, 0, 22)
	StatsUIBuilder.line(leftPanel, UDim2.fromOffset(18, 288), UDim2.new(1, -36, 0, 1), PALETTE.RuneDim)
	local hpLabel = StatsUIBuilder.label(leftPanel, "HP 0 / 0", 17, Color3.fromRGB(184, 91, 86), Enum.TextXAlignment.Center)
	hpLabel.Position = UDim2.fromOffset(12, 304)
	hpLabel.Size = UDim2.new(1, -24, 0, 28)
	local mpLabel = StatsUIBuilder.label(leftPanel, "MP 0 / 0", 17, Color3.fromRGB(109, 136, 186), Enum.TextXAlignment.Center)
	mpLabel.Position = UDim2.fromOffset(12, 334)
	mpLabel.Size = UDim2.new(1, -24, 0, 28)
	local pointsBox = StatsUIBuilder.make("Frame", { BackgroundColor3 = PALETTE.Ink, BackgroundTransparency = 0.05, BorderSizePixel = 0, Position = UDim2.new(0, 16, 1, -138), Size = UDim2.new(1, -32, 0, 84), Parent = leftPanel }) :: Frame
	StatsUIBuilder.addCorner(pointsBox, 10)
	StatsUIBuilder.addStroke(pointsBox, PALETTE.RuneDim, 0.25, 1)
	local pointsLabel = StatsUIBuilder.label(pointsBox, "0", 34, PALETTE.Gold, Enum.TextXAlignment.Center)
	pointsLabel.Position = UDim2.fromOffset(0, 22)
	pointsLabel.Size = UDim2.new(1, 0, 0, 38)
	local pendingLabel = StatsUIBuilder.label(pointsBox, "+0 pending", 13, PALETTE.Muted, Enum.TextXAlignment.Center)
	pendingLabel.Position = UDim2.fromOffset(0, 61)
	pendingLabel.Size = UDim2.new(1, 0, 0, 18)

	local centerPanel = StatsUIBuilder.make("Frame", { BackgroundColor3 = PALETTE.Panel, BorderSizePixel = 0, Position = UDim2.new(0.27, 8, 0, 48), Size = UDim2.new(0.45, -14, 1, -48), Parent = shell }) :: Frame
	StatsUIBuilder.addCorner(centerPanel, 14)
	StatsUIBuilder.addStroke(centerPanel, PALETTE.RuneDim, 0.35, 1)
	StatsUIBuilder.addGradient(centerPanel, Color3.fromRGB(17, 15, 21), Color3.fromRGB(5, 5, 8), 90)
	local detailTitle = StatsUIBuilder.label(centerPanel, "", 20, PALETTE.Text, Enum.TextXAlignment.Center)
	detailTitle.Position = UDim2.new(0, 20, 1, -98)
	detailTitle.Size = UDim2.new(1, -40, 0, 28)
	local detailText = StatsUIBuilder.label(centerPanel, "", 15, PALETTE.Muted, Enum.TextXAlignment.Center)
	detailText.Position = UDim2.new(0, 38, 1, -68)
	detailText.Size = UDim2.new(1, -76, 0, 44)
	detailText.TextWrapped = true

	local rightPanel = StatsUIBuilder.make("Frame", { BackgroundColor3 = PALETTE.Panel, BorderSizePixel = 0, Position = UDim2.new(0.72, 8, 0, 48), Size = UDim2.new(0.28, -8, 1, -48), Parent = shell }) :: Frame
	StatsUIBuilder.addCorner(rightPanel, 14)
	StatsUIBuilder.addStroke(rightPanel, PALETTE.RuneDim, 0.35, 1)
	StatsUIBuilder.addGradient(rightPanel, Color3.fromRGB(20, 16, 23), Color3.fromRGB(5, 4, 7), 90)
	local rows = StatsUIBuilder.make("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 92), Size = UDim2.new(1, -32, 0, 286), Parent = rightPanel }) :: Frame
	StatsUIBuilder.make("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder, Parent = rows })
	local confirmButton = StatsUIBuilder.button(rightPanel, "Bind Attribute", UDim2.new(1, -32, 0, 36), UDim2.new(0, 16, 1, -142))
	local cancelButton = StatsUIBuilder.button(rightPanel, "Clear Offering", UDim2.new(1, -32, 0, 36), UDim2.new(0, 16, 1, -98))
	local resetButton = StatsUIBuilder.button(rightPanel, "Reset All Stats", UDim2.new(1, -32, 0, 36), UDim2.new(0, 16, 1, -54))
	confirmButton.BackgroundColor3 = Color3.fromRGB(45, 81, 55)
	resetButton.BackgroundColor3 = Color3.fromRGB(53, 22, 26)

	return {
		screenGui = screenGui,
		veil = veil,
		shell = shell,
		leftPanel = leftPanel,
		centerPanel = centerPanel,
		rightPanel = rightPanel,
		contentScale = contentScale,
		pointsLabel = pointsLabel,
		pendingLabel = pendingLabel,
		classLabel = classLabel,
		levelLabel = levelLabel,
		expLabel = expLabel,
		hpLabel = hpLabel,
		mpLabel = mpLabel,
		detailTitle = detailTitle,
		detailText = detailText,
		confirmButton = confirmButton,
		cancelButton = cancelButton,
		resetButton = resetButton,
		closeButton = closeButton,
		derivedRowsContainer = rows,
		particles = particles,
	}
end

function StatsUIBuilder.animateOpen(refs: StatsUIRefs)
	refs.veil.Visible = true
	refs.shell.Visible = true
	refs.veil.BackgroundTransparency = 1
	refs.shell.Position = UDim2.fromScale(0.5, 0.55)
	refs.shell.BackgroundTransparency = 1
	refs.contentScale.Scale = 0.92
	TweenService:Create(refs.veil, openTweenInfo, { BackgroundTransparency = 0.18 }):Play()
	TweenService:Create(refs.shell, openTweenInfo, { Position = UDim2.fromScale(0.5, 0.52), BackgroundTransparency = 0 }):Play()
	TweenService:Create(refs.contentScale, openTweenInfo, { Scale = 1 }):Play()
end

function StatsUIBuilder.animateClose(refs: StatsUIRefs, callback: () -> ())
	TweenService:Create(refs.veil, openTweenInfo, { BackgroundTransparency = 1 }):Play()
	TweenService:Create(refs.contentScale, openTweenInfo, { Scale = 0.94 }):Play()
	local tween = TweenService:Create(refs.shell, openTweenInfo, { Position = UDim2.fromScale(0.5, 0.56), BackgroundTransparency = 1 })
	tween:Play()
	tween.Completed:Once(callback)
end

return StatsUIBuilder
