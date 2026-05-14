--!strict
-- InventoryUIBuilder — UI-фабрика для инвентаря
-- Вынесена из InventoryController для разделения вёрстки и логики

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local InventoryUIBuilder = {}

local player = Players.LocalPlayer

-- ═══════════════════════════════════════════
-- PALETTE & CONFIG
-- ═══════════════════════════════════════════

local PALETTE = {
	Void = Color3.fromRGB(10, 10, 15),
	Ink = Color3.fromRGB(18, 16, 29),
	Deep = Color3.fromRGB(8, 7, 12),
	Panel = Color3.fromRGB(14, 12, 22),
	Panel2 = Color3.fromRGB(25, 21, 40),
	Rune = Color3.fromRGB(139, 92, 246),
	RuneDim = Color3.fromRGB(88, 28, 135),
	Text = Color3.fromRGB(230, 225, 240),
	Muted = Color3.fromRGB(120, 113, 144),
	Red = Color3.fromRGB(127, 29, 29),
	Green = Color3.fromRGB(21, 128, 61),
	Gold = Color3.fromRGB(251, 191, 36),
	Blue = Color3.fromRGB(30, 64, 175),
	Cyan = Color3.fromRGB(34, 211, 238),
	Purple = Color3.fromRGB(168, 85, 247),
}

-- ═══════════════════════════════════════════
-- UI FACTORY
-- ═══════════════════════════════════════════

function InventoryUIBuilder.make(className: string, props: { [string]: any }): Instance
	local object = Instance.new(className)
	for property, value in props do
		if property ~= "Parent" then
			(object :: any)[property] = value
		end
	end
	object.Parent = props.Parent
	return object
end

function InventoryUIBuilder.addCorner(parent: Instance, radius: number): UICorner
	return InventoryUIBuilder.make("UICorner", { CornerRadius = UDim.new(0, radius), Parent = parent }) :: UICorner
end

function InventoryUIBuilder.addStroke(parent: Instance, color: Color3, transparency: number, thickness: number): UIStroke
	return InventoryUIBuilder.make("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = color, Transparency = transparency, Thickness = thickness, Parent = parent }) :: UIStroke
end

function InventoryUIBuilder.addGradient(parent: Instance, top: Color3, bottom: Color3, rotation: number): UIGradient
	return InventoryUIBuilder.make("UIGradient", { Color = ColorSequence.new(top, bottom), Rotation = rotation, Parent = parent }) :: UIGradient
end

function InventoryUIBuilder.label(parent: Instance, textValue: string, size: number, color: Color3, align: Enum.TextXAlignment?): TextLabel
	return InventoryUIBuilder.make("TextLabel", {
		BackgroundTransparency = 1,
		Font = Enum.Font.Garamond,
		Text = textValue,
		TextColor3 = color,
		TextSize = size,
		TextStrokeColor3 = Color3.new(0, 0, 0),
		TextStrokeTransparency = 0.55,
		TextXAlignment = align or Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = parent,
	}) :: TextLabel
end

function InventoryUIBuilder.button(parent: Instance, textValue: string, size: UDim2, position: UDim2): TextButton
	local object = InventoryUIBuilder.make("TextButton", {
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
	InventoryUIBuilder.addCorner(object, 8)
	InventoryUIBuilder.addStroke(object, PALETTE.RuneDim, 0.45, 1)
	return object
end

-- ═══════════════════════════════════════════
-- BUILD INVENTORY GUI
-- ═══════════════════════════════════════════

export type InventoryUIRefs = {
	screenGui: ScreenGui,
	veil: Frame,
	shell: Frame,
	gridFrame: Frame,
	detailPanel: Frame,
	equipmentRing: Frame,
	goldLabel: TextLabel,
	capacityLabel: TextLabel,
	titleLabel: TextLabel,
	detailIconFrame: Frame,
	detailIcon: ImageLabel,
	detailIconGlyph: TextLabel,
	detailName: TextLabel,
	detailType: TextLabel,
	detailDesc: TextLabel,
	detailStats: TextLabel,
	detailValue: TextLabel,
	emptyGlyph: TextLabel,
	searchBox: TextBox,
	sortButton: TextButton,
	equipButton: TextButton,
	useButton: TextButton,
	deleteButton: TextButton,
	filterButtons: { [string]: TextButton },
	slotButtons: { TextButton },
	equipmentButtons: { [string]: TextButton },
	particles: { Frame },
}

function InventoryUIBuilder.build(): InventoryUIRefs
	local pg = player:WaitForChild("PlayerGui")

	-- ScreenGui
	local screenGui = InventoryUIBuilder.make("ScreenGui", {
		Name = "InventoryUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 60,
		Parent = pg,
	}) :: ScreenGui

	-- Veil
	local veil = InventoryUIBuilder.make("Frame", {
		Name = "Veil",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = PALETTE.Void,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = screenGui,
	}) :: Frame

	-- Shell
	local shell = InventoryUIBuilder.make("Frame", {
		Name = "Shell",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.52),
		Size = UDim2.fromOffset(1040, 620),
		BackgroundColor3 = PALETTE.Ink,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Parent = veil,
	}) :: Frame
	InventoryUIBuilder.addCorner(shell, 18)
	InventoryUIBuilder.addStroke(shell, PALETTE.RuneDim, 0.45, 2)
	InventoryUIBuilder.addGradient(shell, Color3.fromRGB(26, 16, 40), Color3.fromRGB(10, 10, 15), 90)

	-- Particles
	local particles: { Frame } = {}
	for i = 1, 18 do
		local p = InventoryUIBuilder.make("Frame", {
			Size = UDim2.fromOffset(2, 2),
			BackgroundColor3 = PALETTE.Purple,
			BackgroundTransparency = 0.7,
			BorderSizePixel = 0,
			Parent = shell,
		}) :: Frame
		InventoryUIBuilder.addCorner(p, 2)
		table.insert(particles, p)
	end

	-- Title
	local titleLabel = InventoryUIBuilder.label(shell, "ABYSS LEDGER", 30, PALETTE.Purple, Enum.TextXAlignment.Center)
	titleLabel.Position = UDim2.fromOffset(20, 12)
	titleLabel.Size = UDim2.new(0, 290, 0, 36)
	titleLabel.Font = Enum.Font.Fantasy

	-- Gold label
	local goldLabel = InventoryUIBuilder.label(shell, "0 G", 16, PALETTE.Gold, Enum.TextXAlignment.Right)
	goldLabel.Position = UDim2.new(1, -220, 0, 12)
	goldLabel.Size = UDim2.new(0, 200, 0, 28)

	-- Capacity
	local capacityLabel = InventoryUIBuilder.label(shell, "0 / 30", 14, PALETTE.Muted, Enum.TextXAlignment.Right)
	capacityLabel.Position = UDim2.new(1, -120, 0, 38)
	capacityLabel.Size = UDim2.new(0, 100, 0, 22)

	-- Left panel (equipment + filters)
	local leftPanel = InventoryUIBuilder.make("Frame", {
		BackgroundColor3 = PALETTE.Panel,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(8, 48),
		Size = UDim2.new(0.28, -12, 1, -56),
		Parent = shell,
	}) :: Frame
	InventoryUIBuilder.addCorner(leftPanel, 14)
	InventoryUIBuilder.addStroke(leftPanel, PALETTE.RuneDim, 0.55, 1)
	InventoryUIBuilder.addGradient(leftPanel, Color3.fromRGB(22, 16, 35), Color3.fromRGB(10, 8, 18), 90)

	-- Equipment ring
	local equipmentRing = InventoryUIBuilder.make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(8, 8),
		Size = UDim2.new(1, -16, 0, 292),
		Parent = leftPanel,
	}) :: Frame

	local ring = InventoryUIBuilder.make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = PALETTE.Deep,
		BackgroundTransparency = 0.22,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(178, 178),
		Parent = equipmentRing,
	}) :: Frame
	InventoryUIBuilder.addCorner(ring, 100)
	InventoryUIBuilder.addStroke(ring, PALETTE.Purple, 0.55, 2)

	local core = InventoryUIBuilder.label(ring, "VESSEL\nSEAL", 18, PALETTE.Purple, Enum.TextXAlignment.Center)
	core.Size = UDim2.fromScale(1, 1)
	core.TextYAlignment = Enum.TextYAlignment.Center

	-- Filter panel
	local filterPanel = InventoryUIBuilder.make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(8, 312),
		Size = UDim2.new(1, -16, 0, 180),
		Parent = leftPanel,
	}) :: Frame
	InventoryUIBuilder.make("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = filterPanel })

	local filterButtons: { [string]: TextButton } = {}
	local filterNames = { "All", "Weapon", "Armor", "Accessory", "Consumable", "Material" }
	for i, name in filterNames do
		local btn = InventoryUIBuilder.button(filterPanel, name, UDim2.new(1, 0, 0, 24), UDim2.fromOffset(0, 0))
		btn.LayoutOrder = i
		filterButtons[name] = btn
	end

	-- Center panel (grid)
	local centerPanel = InventoryUIBuilder.make("Frame", {
		BackgroundColor3 = PALETTE.Panel,
		BorderSizePixel = 0,
		Position = UDim2.new(0.28, 8, 0, 48),
		Size = UDim2.new(0.48, -14, 1, -56),
		Parent = shell,
	}) :: Frame
	InventoryUIBuilder.addCorner(centerPanel, 14)
	InventoryUIBuilder.addStroke(centerPanel, PALETTE.RuneDim, 0.55, 1)
	InventoryUIBuilder.addGradient(centerPanel, Color3.fromRGB(22, 16, 35), Color3.fromRGB(10, 8, 18), 90)

	-- Search and sort
	local searchBox = InventoryUIBuilder.make("TextBox", {
		BackgroundColor3 = PALETTE.Deep,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		PlaceholderText = "Search...",
		Position = UDim2.fromOffset(8, 8),
		Size = UDim2.new(1, -110, 0, 32),
		Font = Enum.Font.Garamond,
		Text = "",
		TextColor3 = PALETTE.Text,
		TextSize = 15,
		Parent = centerPanel,
	}) :: TextBox
	InventoryUIBuilder.addCorner(searchBox, 8)
	InventoryUIBuilder.addStroke(searchBox, PALETTE.RuneDim, 0.45, 1)

	local sortButton = InventoryUIBuilder.button(centerPanel, "SORT", UDim2.fromOffset(92, 32), UDim2.new(1, -102, 0, 8))

	-- Grid
	local gridFrame = InventoryUIBuilder.make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(8, 52),
		Size = UDim2.new(1, -16, 1, -52),
		Parent = centerPanel,
	}) :: Frame
	InventoryUIBuilder.make("UIGridLayout", { CellSize = UDim2.fromOffset(80, 80), CellPadding = UDim2.fromOffset(6, 6), Parent = gridFrame })

	-- Right panel (detail)
	local detailPanel = InventoryUIBuilder.make("Frame", {
		BackgroundColor3 = PALETTE.Panel,
		BorderSizePixel = 0,
		Position = UDim2.new(0.76, 8, 0, 48),
		Size = UDim2.new(0.24, -8, 1, -56),
		Parent = shell,
	}) :: Frame
	InventoryUIBuilder.addCorner(detailPanel, 14)
	InventoryUIBuilder.addStroke(detailPanel, PALETTE.RuneDim, 0.55, 1)
	InventoryUIBuilder.addGradient(detailPanel, Color3.fromRGB(22, 16, 35), Color3.fromRGB(10, 8, 18), 90)

	local sigil = InventoryUIBuilder.label(detailPanel, "☽", 72, Color3.fromRGB(60, 40, 80), Enum.TextXAlignment.Center)
	sigil.Position = UDim2.new(1, -98, 0, 0)
	sigil.Size = UDim2.fromOffset(90, 90)

	local detailIconFrame = InventoryUIBuilder.make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Color3.fromRGB(8, 7, 12),
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0, 22),
		Size = UDim2.fromOffset(128, 128),
		Parent = detailPanel,
	}) :: Frame
	InventoryUIBuilder.addCorner(detailIconFrame, 12)
	InventoryUIBuilder.addStroke(detailIconFrame, PALETTE.RuneDim, 0.25, 2)
	InventoryUIBuilder.addGradient(detailIconFrame, Color3.fromRGB(24, 13, 38), Color3.fromRGB(5, 5, 8), 90)

	local detailIcon = InventoryUIBuilder.make("ImageLabel", {
		BackgroundTransparency = 1,
		Image = "",
		ImageTransparency = 1,
		Position = UDim2.fromOffset(0, 0),
		ScaleType = Enum.ScaleType.Crop,
		Size = UDim2.fromScale(1, 1),
		Parent = detailIconFrame,
	}) :: ImageLabel
	InventoryUIBuilder.addCorner(detailIcon, 12)

	local detailIconGlyph = InventoryUIBuilder.label(detailIconFrame, "✦", 54, PALETTE.Muted, Enum.TextXAlignment.Center)
	detailIconGlyph.Size = UDim2.fromScale(1, 1)

	local detailName = InventoryUIBuilder.label(detailPanel, "Choose a relic", 24, PALETTE.Text, Enum.TextXAlignment.Left)
	detailName.Position = UDim2.fromOffset(16, 166)
	detailName.Size = UDim2.new(1, -34, 0, 34)
	detailName.TextWrapped = true

	local detailType = InventoryUIBuilder.label(detailPanel, "No item selected", 15, PALETTE.Muted, Enum.TextXAlignment.Left)
	detailType.Position = UDim2.fromOffset(16, 204)
	detailType.Size = UDim2.new(1, -34, 0, 24)

	local detailDesc = InventoryUIBuilder.label(detailPanel, "", 15, PALETTE.Text, Enum.TextXAlignment.Left)
	detailDesc.Position = UDim2.fromOffset(16, 244)
	detailDesc.Size = UDim2.new(1, -34, 0, 100)
	detailDesc.TextWrapped = true
	detailDesc.TextYAlignment = Enum.TextYAlignment.Top

	local detailStats = InventoryUIBuilder.label(detailPanel, "", 15, PALETTE.Gold, Enum.TextXAlignment.Left)
	detailStats.Position = UDim2.fromOffset(16, 354)
	detailStats.Size = UDim2.new(1, -34, 0, 54)
	detailStats.TextWrapped = true
	detailStats.TextYAlignment = Enum.TextYAlignment.Top

	local detailValue = InventoryUIBuilder.label(detailPanel, "", 15, PALETTE.Muted, Enum.TextXAlignment.Left)
	detailValue.Position = UDim2.fromOffset(16, 414)
	detailValue.Size = UDim2.new(1, -34, 0, 26)

	local equipButton = InventoryUIBuilder.button(detailPanel, "EQUIP", UDim2.new(1, -32, 0, 36), UDim2.new(0, 16, 1, -142))
	equipButton.BackgroundColor3 = PALETTE.Green
	local useButton = InventoryUIBuilder.button(detailPanel, "USE", UDim2.new(1, -32, 0, 36), UDim2.new(0, 16, 1, -98))
	useButton.BackgroundColor3 = PALETTE.Blue
	local deleteButton = InventoryUIBuilder.button(detailPanel, "DISCARD", UDim2.new(1, -32, 0, 36), UDim2.new(0, 16, 1, -54))
	deleteButton.BackgroundColor3 = PALETTE.Red

	return {
		screenGui = screenGui,
		veil = veil,
		shell = shell,
		gridFrame = gridFrame,
		detailPanel = detailPanel,
		equipmentRing = equipmentRing,
		goldLabel = goldLabel,
		capacityLabel = capacityLabel,
		titleLabel = titleLabel,
		detailIconFrame = detailIconFrame,
		detailIcon = detailIcon,
		detailIconGlyph = detailIconGlyph,
		detailName = detailName,
		detailType = detailType,
		detailDesc = detailDesc,
		detailStats = detailStats,
		detailValue = detailValue,
		emptyGlyph = nil,
		searchBox = searchBox,
		sortButton = sortButton,
		equipButton = equipButton,
		useButton = useButton,
		deleteButton = deleteButton,
		filterButtons = filterButtons,
		slotButtons = {},
		equipmentButtons = {},
		particles = particles,
	}
end

-- ═══════════════════════════════════════════
-- SLOT CREATION
-- ═══════════════════════════════════════════

function InventoryUIBuilder.createSlot(parent: Frame, index: number): TextButton
	local slot = InventoryUIBuilder.make("TextButton", {
		Name = "Slot" .. index,
		AutoButtonColor = false,
		Size = UDim2.fromOffset(72, 72),
		BackgroundColor3 = Color3.fromRGB(9, 8, 14),
		BorderSizePixel = 0,
		Text = "",
		Parent = parent,
	}) :: TextButton
	InventoryUIBuilder.addCorner(slot, 10)
	InventoryUIBuilder.addStroke(slot, Color3.fromRGB(55, 65, 81), 0.45, 2)
	InventoryUIBuilder.addGradient(slot, Color3.fromRGB(21, 13, 32), Color3.fromRGB(5, 5, 8), 90)

	InventoryUIBuilder.make("Frame", {
		Name = "Rarity",
		BackgroundColor3 = PALETTE.RuneDim,
		BackgroundTransparency = 0.65,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 6, 1, -6),
		Size = UDim2.new(1, -12, 0, 3),
		Parent = slot,
	})

	local glyph = InventoryUIBuilder.label(slot, "", 34, PALETTE.Muted, Enum.TextXAlignment.Center)
	glyph.Size = UDim2.fromScale(1, 1)
	glyph.Name = "Glyph"

	local icon = InventoryUIBuilder.make("ImageLabel", {
		Name = "Icon",
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromOffset(0, 0),
		BackgroundTransparency = 1,
		Image = "",
		ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Crop,
		Parent = slot,
	})
	InventoryUIBuilder.addCorner(icon, 10)

	local qty = InventoryUIBuilder.label(slot, "", 13, PALETTE.Text, Enum.TextXAlignment.Right)
	qty.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	qty.BackgroundTransparency = 0.2
	qty.Position = UDim2.new(1, -26, 1, -20)
	qty.Size = UDim2.fromOffset(22, 16)
	InventoryUIBuilder.addCorner(qty, 4)
	qty.Name = "Qty"

	local equipped = InventoryUIBuilder.label(slot, "BOUND", 9, PALETTE.Gold, Enum.TextXAlignment.Center)
	equipped.Position = UDim2.fromOffset(5, 4)
	equipped.Size = UDim2.new(1, -10, 0, 12)
	equipped.Name = "Equipped"
	equipped.Visible = false

	return slot
end

-- ═══════════════════════════════════════════
-- EQUIPMENT BUTTON CREATION
-- ═══════════════════════════════════════════

function InventoryUIBuilder.createEquipmentButton(parent: Frame, slotName: string, angle: number): TextButton
	local radius = 112
	local x = math.cos(angle) * radius
	local y = math.sin(angle) * radius

	local btn = InventoryUIBuilder.button(
		parent,
		"",
		UDim2.fromOffset(82, 82),
		UDim2.new(0.5, x - 41, 0.5, y - 41)
	)
	btn.Name = slotName .. "Slot"
	btn.TextSize = 13
	btn.TextWrapped = true
	InventoryUIBuilder.addCorner(btn, 100)

	return btn
end

-- ═══════════════════════════════════════════
-- ANIMATION HELPERS
-- ═══════════════════════════════════════════

local openTweenInfo = TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

function InventoryUIBuilder.animateOpen(refs: InventoryUIRefs)
	refs.veil.BackgroundTransparency = 1
	refs.shell.Position = UDim2.fromScale(0.5, 0.55)
	refs.shell.BackgroundTransparency = 1
	TweenService:Create(refs.veil, openTweenInfo, { BackgroundTransparency = 0.18 }):Play()
	TweenService:Create(refs.shell, openTweenInfo, { Position = UDim2.fromScale(0.5, 0.52), BackgroundTransparency = 0 }):Play()
end

function InventoryUIBuilder.animateClose(refs: InventoryUIRefs, callback: () -> ())
	TweenService:Create(refs.veil, openTweenInfo, { BackgroundTransparency = 1 }):Play()
	local tween = TweenService:Create(refs.shell, openTweenInfo, { Position = UDim2.fromScale(0.5, 0.56), BackgroundTransparency = 1 })
	tween:Play()
	tween.Completed:Once(callback)
end

function InventoryUIBuilder.flashObject(object: GuiObject, color: Color3)
	local original = object.BackgroundColor3
	TweenService:Create(object, TweenInfo.new(0.08), { BackgroundColor3 = color }):Play()
	task.delay(0.09, function()
		if object.Parent then
			TweenService:Create(object, TweenInfo.new(0.18), { BackgroundColor3 = original }):Play()
		end
	end)
end

return InventoryUIBuilder
