local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local COLORS = {
    Background = Color3.fromRGB(8, 11, 20),
    Panel = Color3.fromRGB(18, 23, 38),
    PanelSoft = Color3.fromRGB(27, 34, 54),
    Card = Color3.fromRGB(24, 31, 50),
    CardHover = Color3.fromRGB(34, 43, 68),
    Accent = Color3.fromRGB(94, 234, 212),
    AccentAlt = Color3.fromRGB(129, 140, 248),
    Gold = Color3.fromRGB(251, 191, 36),
    Red = Color3.fromRGB(248, 113, 113),
    Green = Color3.fromRGB(74, 222, 128),
    Text = Color3.fromRGB(241, 245, 249),
    Muted = Color3.fromRGB(148, 163, 184),
    Stroke = Color3.fromRGB(51, 65, 85),
}

local stats = {
    { name = "Сила", value = 42, bonus = "+8", color = COLORS.Red, icon = "⚔" },
    { name = "Ловкость", value = 31, bonus = "+4", color = COLORS.Green, icon = "➤" },
    { name = "Интеллект", value = 27, bonus = "+6", color = COLORS.AccentAlt, icon = "✦" },
    { name = "Выносливость", value = 55, bonus = "+11", color = COLORS.Gold, icon = "◆" },
}

local derivedStats = {
    { label = "Урон", value = "128-156" },
    { label = "Крит", value = "18%" },
    { label = "Защита", value = "94" },
    { label = "Скорость", value = "112%" },
}

local function make(className, props)
    local instance = Instance.new(className)

    for property, value in pairs(props or {}) do
        if property ~= "Parent" then
            instance[property] = value
        end
    end

    instance.Parent = props.Parent
    return instance
end

local function addCorner(parent, radius)
    return make("UICorner", {
        CornerRadius = UDim.new(0, radius),
        Parent = parent,
    })
end

local function addStroke(parent, color, transparency, thickness)
    return make("UIStroke", {
        Color = color,
        Transparency = transparency,
        Thickness = thickness,
        Parent = parent,
    })
end

local function addGradient(parent, colorSequence, rotation)
    return make("UIGradient", {
        Color = colorSequence,
        Rotation = rotation,
        Parent = parent,
    })
end

local function createText(parent, text, size, color, font, align)
    return make("TextLabel", {
        BackgroundTransparency = 1,
        Font = font or Enum.Font.GothamMedium,
        Text = text,
        TextColor3 = color or COLORS.Text,
        TextSize = size,
        TextXAlignment = align or Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = parent,
    })
end

local screenGui = make("ScreenGui", {
    Name = "StatMenuPrototype",
    DisplayOrder = 50,
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = playerGui,
})

local overlay = make("Frame", {
    Name = "Overlay",
    BackgroundColor3 = COLORS.Background,
    BackgroundTransparency = 0.18,
    BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1),
    Parent = screenGui,
})

local panel = make("Frame", {
    Name = "Panel",
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = COLORS.Panel,
    BorderSizePixel = 0,
    Position = UDim2.fromScale(0.5, 0.52),
    Size = UDim2.fromScale(0.54, 0.68),
    Parent = overlay,
})

addCorner(panel, 24)
addStroke(panel, COLORS.Stroke, 0.25, 1)
addGradient(panel, ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(23, 30, 52)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 13, 24)),
}), 90)

make("UISizeConstraint", {
    MinSize = Vector2.new(520, 430),
    MaxSize = Vector2.new(820, 620),
    Parent = panel,
})

make("UIPadding", {
    PaddingTop = UDim.new(0, 24),
    PaddingBottom = UDim.new(0, 24),
    PaddingLeft = UDim.new(0, 26),
    PaddingRight = UDim.new(0, 26),
    Parent = panel,
})

local header = make("Frame", {
    Name = "Header",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 76),
    Parent = panel,
})

local title = createText(header, "СТАТИСТИКА", 28, COLORS.Text, Enum.Font.GothamBlack)
title.Size = UDim2.new(1, -160, 0, 34)
title.Position = UDim2.fromOffset(0, 0)

local subtitle = createText(header, "Профиль героя • прототип интерфейса", 14, COLORS.Muted, Enum.Font.GothamMedium)
subtitle.Size = UDim2.new(1, -160, 0, 24)
subtitle.Position = UDim2.fromOffset(1, 38)

local closeButton = make("TextButton", {
    Name = "CloseButton",
    AnchorPoint = Vector2.new(1, 0),
    AutoButtonColor = false,
    BackgroundColor3 = COLORS.PanelSoft,
    BorderSizePixel = 0,
    Font = Enum.Font.GothamBold,
    Position = UDim2.new(1, 0, 0, 0),
    Size = UDim2.fromOffset(44, 44),
    Text = "×",
    TextColor3 = COLORS.Text,
    TextSize = 28,
    Parent = header,
})

addCorner(closeButton, 14)
addStroke(closeButton, COLORS.Stroke, 0.35, 1)

local content = make("Frame", {
    Name = "Content",
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(0, 86),
    Size = UDim2.new(1, 0, 1, -86),
    Parent = panel,
})

local leftColumn = make("Frame", {
    Name = "LeftColumn",
    BackgroundTransparency = 1,
    Size = UDim2.new(0.48, -10, 1, 0),
    Parent = content,
})

local rightColumn = make("Frame", {
    Name = "RightColumn",
    AnchorPoint = Vector2.new(1, 0),
    BackgroundTransparency = 1,
    Position = UDim2.fromScale(1, 0),
    Size = UDim2.new(0.52, -10, 1, 0),
    Parent = content,
})

local portraitCard = make("Frame", {
    Name = "PortraitCard",
    BackgroundColor3 = COLORS.Card,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 150),
    Parent = leftColumn,
})

addCorner(portraitCard, 20)
addStroke(portraitCard, COLORS.Stroke, 0.35, 1)

local avatar = make("Frame", {
    Name = "Avatar",
    BackgroundColor3 = COLORS.PanelSoft,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(18, 18),
    Size = UDim2.fromOffset(86, 86),
    Parent = portraitCard,
})

addCorner(avatar, 24)
addGradient(avatar, ColorSequence.new(COLORS.AccentAlt, COLORS.Accent), 45)

local avatarText = createText(avatar, "Q", 42, Color3.fromRGB(5, 10, 20), Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
avatarText.Size = UDim2.fromScale(1, 1)

local heroName = createText(portraitCard, "Qwenty Hero", 20, COLORS.Text, Enum.Font.GothamBlack)
heroName.Position = UDim2.fromOffset(122, 20)
heroName.Size = UDim2.new(1, -140, 0, 28)

local heroClass = createText(portraitCard, "Уровень 24 • Wanderer", 14, COLORS.Muted, Enum.Font.GothamMedium)
heroClass.Position = UDim2.fromOffset(122, 50)
heroClass.Size = UDim2.new(1, -140, 0, 22)

local powerLabel = createText(portraitCard, "БОЕВАЯ МОЩЬ", 12, COLORS.Muted, Enum.Font.GothamBold)
powerLabel.Position = UDim2.fromOffset(18, 112)
powerLabel.Size = UDim2.fromOffset(130, 20)

local powerValue = createText(portraitCard, "3 842", 24, COLORS.Gold, Enum.Font.GothamBlack, Enum.TextXAlignment.Right)
powerValue.AnchorPoint = Vector2.new(1, 0)
powerValue.Position = UDim2.new(1, -18, 0, 106)
powerValue.Size = UDim2.fromOffset(150, 30)

local progressCard = make("Frame", {
    Name = "ProgressCard",
    BackgroundColor3 = COLORS.Card,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(0, 166),
    Size = UDim2.new(1, 0, 0, 122),
    Parent = leftColumn,
})

addCorner(progressCard, 20)
addStroke(progressCard, COLORS.Stroke, 0.35, 1)

local expTitle = createText(progressCard, "Опыт до уровня", 15, COLORS.Text, Enum.Font.GothamBold)
expTitle.Position = UDim2.fromOffset(18, 16)
expTitle.Size = UDim2.new(1, -36, 0, 24)

local expValue = createText(progressCard, "7 450 / 10 000", 13, COLORS.Muted, Enum.Font.GothamMedium, Enum.TextXAlignment.Right)
expValue.AnchorPoint = Vector2.new(1, 0)
expValue.Position = UDim2.new(1, -18, 0, 18)
expValue.Size = UDim2.fromOffset(140, 22)

local expBarBack = make("Frame", {
    Name = "ExpBarBackground",
    BackgroundColor3 = Color3.fromRGB(12, 17, 30),
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(18, 52),
    Size = UDim2.new(1, -36, 0, 16),
    Parent = progressCard,
})

addCorner(expBarBack, 8)

local expBar = make("Frame", {
    Name = "ExpBar",
    BackgroundColor3 = COLORS.Accent,
    BorderSizePixel = 0,
    Size = UDim2.fromScale(0.745, 1),
    Parent = expBarBack,
})

addCorner(expBar, 8)
addGradient(expBar, ColorSequence.new(COLORS.AccentAlt, COLORS.Accent), 0)

local pointsBadge = make("Frame", {
    Name = "PointsBadge",
    BackgroundColor3 = Color3.fromRGB(37, 46, 71),
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(18, 82),
    Size = UDim2.new(1, -36, 0, 28),
    Parent = progressCard,
})

addCorner(pointsBadge, 10)

local pointsText = createText(pointsBadge, "Свободные очки: 5", 14, COLORS.Accent, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
pointsText.Size = UDim2.fromScale(1, 1)

local derivedCard = make("Frame", {
    Name = "DerivedStatsCard",
    BackgroundColor3 = COLORS.Card,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(0, 304),
    Size = UDim2.new(1, 0, 1, -304),
    Parent = leftColumn,
})

addCorner(derivedCard, 20)
addStroke(derivedCard, COLORS.Stroke, 0.35, 1)

make("UIPadding", {
    PaddingTop = UDim.new(0, 16),
    PaddingBottom = UDim.new(0, 16),
    PaddingLeft = UDim.new(0, 18),
    PaddingRight = UDim.new(0, 18),
    Parent = derivedCard,
})

local derivedLayout = make("UIGridLayout", {
    CellPadding = UDim2.fromOffset(10, 10),
    CellSize = UDim2.new(0.5, -5, 0, 54),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = derivedCard,
})

for _, item in ipairs(derivedStats) do
    local chip = make("Frame", {
        BackgroundColor3 = Color3.fromRGB(17, 23, 39),
        BorderSizePixel = 0,
        Parent = derivedCard,
    })

    addCorner(chip, 14)

    local chipLabel = createText(chip, item.label, 12, COLORS.Muted, Enum.Font.GothamMedium, Enum.TextXAlignment.Center)
    chipLabel.Position = UDim2.fromOffset(0, 7)
    chipLabel.Size = UDim2.new(1, 0, 0, 18)

    local chipValue = createText(chip, item.value, 17, COLORS.Text, Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
    chipValue.Position = UDim2.fromOffset(0, 26)
    chipValue.Size = UDim2.new(1, 0, 0, 22)
end

local statList = make("Frame", {
    Name = "StatList",
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    Parent = rightColumn,
})

local statLayout = make("UIListLayout", {
    Padding = UDim.new(0, 12),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = statList,
})

for index, stat in ipairs(stats) do
    local card = make("Frame", {
        Name = stat.name .. "Card",
        BackgroundColor3 = COLORS.Card,
        BorderSizePixel = 0,
        LayoutOrder = index,
        Size = UDim2.new(1, 0, 0, 88),
        Parent = statList,
    })

    addCorner(card, 18)
    addStroke(card, COLORS.Stroke, 0.4, 1)

    local icon = make("TextLabel", {
        BackgroundColor3 = Color3.fromRGB(13, 18, 31),
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBlack,
        Position = UDim2.fromOffset(16, 16),
        Size = UDim2.fromOffset(56, 56),
        Text = stat.icon,
        TextColor3 = stat.color,
        TextSize = 25,
        Parent = card,
    })

    addCorner(icon, 16)

    local statName = createText(card, stat.name, 17, COLORS.Text, Enum.Font.GothamBlack)
    statName.Position = UDim2.fromOffset(86, 14)
    statName.Size = UDim2.new(1, -210, 0, 26)

    local statBonus = createText(card, "Бонус экипировки " .. stat.bonus, 12, stat.color, Enum.Font.GothamBold)
    statBonus.Position = UDim2.fromOffset(86, 42)
    statBonus.Size = UDim2.new(1, -210, 0, 20)

    local statValue = createText(card, tostring(stat.value), 28, COLORS.Text, Enum.Font.GothamBlack, Enum.TextXAlignment.Right)
    statValue.AnchorPoint = Vector2.new(1, 0.5)
    statValue.Position = UDim2.new(1, -70, 0.5, 0)
    statValue.Size = UDim2.fromOffset(80, 34)

    local addButton = make("TextButton", {
        Name = "AddButton",
        AnchorPoint = Vector2.new(1, 0.5),
        AutoButtonColor = false,
        BackgroundColor3 = stat.color,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBlack,
        Position = UDim2.new(1, -16, 0.5, 0),
        Size = UDim2.fromOffset(38, 38),
        Text = "+",
        TextColor3 = Color3.fromRGB(5, 10, 20),
        TextSize = 24,
        Parent = card,
    })

    addCorner(addButton, 12)

    card.MouseEnter:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.12), {
            BackgroundColor3 = COLORS.CardHover,
        }):Play()
    end)

    card.MouseLeave:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.12), {
            BackgroundColor3 = COLORS.Card,
        }):Play()
    end)
end

local footer = make("Frame", {
    Name = "Footer",
    AnchorPoint = Vector2.new(0, 1),
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 1, 0),
    Size = UDim2.new(1, 0, 0, 42),
    Parent = rightColumn,
})

local hint = createText(footer, "N — открыть/закрыть • Esc — закрыть", 13, COLORS.Muted, Enum.Font.GothamMedium, Enum.TextXAlignment.Right)
hint.Size = UDim2.fromScale(1, 1)

local VFX_MARKER_NAME = "VFXMAKINAME"
local VFX_FALLBACK_TIME_SEC = 19 / 60
local openPosition = UDim2.fromScale(0.5, 0.52)
local closedPosition = UDim2.fromScale(0.5, 0.58)
local tweenInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local function setOpen(open)
    isOpen = open
    overlay.Visible = true

    TweenService:Create(overlay, tweenInfo, {
        BackgroundTransparency = open and 0.18 or 1,
    }):Play()

    local panelTween = TweenService:Create(panel, tweenInfo, {
        Position = open and openPosition or closedPosition,
        BackgroundTransparency = open and 0 or 1,
    })

    panelTween:Play()

    if not open then
        panelTween.Completed:Once(function()
            if not isOpen then
                overlay.Visible = false
            end
        end)
    end
end

closeButton.MouseEnter:Connect(function()
    TweenService:Create(closeButton, TweenInfo.new(0.1), {
        BackgroundColor3 = Color3.fromRGB(55, 65, 90),
    }):Play()
end)

closeButton.MouseLeave:Connect(function()
    TweenService:Create(closeButton, TweenInfo.new(0.1), {
        BackgroundColor3 = COLORS.PanelSoft,
    }):Play()
end)

closeButton.MouseButton1Click:Connect(function()
    setOpen(false)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == Enum.KeyCode.N then
        setOpen(not isOpen)
    elseif input.KeyCode == Enum.KeyCode.Escape and isOpen then
        setOpen(false)
    end
end)

panel.Position = closedPosition
panel.BackgroundTransparency = 1
overlay.BackgroundTransparency = 1
setOpen(true)
