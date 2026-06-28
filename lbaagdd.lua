local Library = {
    Flags = {},
    Theme = {},
    Connections = {},
    Loaded = false,
    Toggled = true,
    AccentHue = 0.72
}

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

if getgenv then
    if getgenv().Library then
        pcall(function()
            getgenv().Library:Unload()
        end)
    end
    getgenv().Library = Library
end

local function Create(class, props)
    local inst = Instance.new(class)
    for prop, val in pairs(props or {}) do
        if prop ~= "Parent" then
            inst[prop] = val
        end
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

local function Tween(obj, time, props, style, dir)
    local tween = TweenService:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end

local function Clamp(val, min, max)
    return math.max(min, math.min(max, val))
end

local function Round(val, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(val * mult + 0.5) / mult
end

local function Lerp(a, b, t)
    return a + (b - a) * t
end

Library.Theme = {
    Accent = Color3.fromRGB(138, 100, 255),
    AccentDark = Color3.fromRGB(110, 75, 220),
    AccentLight = Color3.fromRGB(165, 130, 255),
    Background = Color3.fromRGB(15, 15, 18),
    BackgroundDark = Color3.fromRGB(10, 10, 12),
    BackgroundLight = Color3.fromRGB(22, 22, 26),
    BackgroundLighter = Color3.fromRGB(30, 30, 36),
    Sidebar = Color3.fromRGB(18, 18, 22),
    Section = Color3.fromRGB(24, 24, 28),
    SectionBorder = Color3.fromRGB(45, 45, 55),
    Text = Color3.fromRGB(250, 250, 255),
    TextDim = Color3.fromRGB(180, 180, 195),
    TextDimmer = Color3.fromRGB(110, 110, 125),
    ToggleOff = Color3.fromRGB(40, 40, 50),
    SliderBg = Color3.fromRGB(30, 30, 38),
    InputBg = Color3.fromRGB(28, 28, 34),
    DropdownBg = Color3.fromRGB(20, 20, 24),
    Hover = Color3.fromRGB(35, 35, 42),
    Outline = Color3.fromRGB(55, 55, 65),
    Danger = Color3.fromRGB(255, 95, 95),
    Success = Color3.fromRGB(100, 230, 140),
    Warning = Color3.fromRGB(255, 210, 80),
    Info = Color3.fromRGB(100, 180, 255),
}

local Theme = Library.Theme

local ScreenGui = Create("ScreenGui", {
    Name = "RufusUI",
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
})

local function GetParent()
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = CoreGui
    end
end

pcall(GetParent)

Library.ScreenGui = ScreenGui

local NotificationHolder = Create("Frame", {
    Name = "Notifications",
    Parent = ScreenGui,
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -20, 0, 20),
    Size = UDim2.new(0, 340, 1, -40),
})

Create("UIListLayout", {
    Parent = NotificationHolder,
    FillDirection = Enum.FillDirection.Vertical,
    VerticalAlignment = Enum.VerticalAlignment.Top,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 10),
})

function Library:Notification(data)
    local name = data.Name or data.name or "Notification"
    local desc = data.Description or data.description or ""
    local duration = data.Duration or data.duration or 5
    local iconColor = data.IconColor or data.iconcolor or Theme.Accent

    local Frame = Create("Frame", {
        Name = "Notification",
        Parent = NotificationHolder,
        BackgroundColor3 = Theme.BackgroundDark,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true,
    })

    Create("UICorner", {
        Parent = Frame,
        CornerRadius = UDim.new(0, 10),
    })

    local UIStroke = Create("UIStroke", {
        Parent = Frame,
        Color = Theme.Outline,
        Transparency = 1,
        Thickness = 1.5,
    })

    local AccentGradient = Create("Frame", {
        Parent = Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 4, 1, 0),
    })

    local AccentGrad = Create("UIGradient", {
        Parent = AccentGradient,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, iconColor),
            ColorSequenceKeypoint.new(1, iconColor:Lerp(Color3.fromRGB(255, 255, 255), 0.3)),
        }),
        Rotation = 90,
    })

    local Content = Create("Frame", {
        Name = "Content",
        Parent = Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -24, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
    })

    local Title = Create("TextLabel", {
        Name = "Title",
        Parent = Content,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.new(0, 0, 0, 10),
        Font = Enum.Font.GothamBold,
        Text = name,
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1,
    })

    local Description = Create("TextLabel", {
        Name = "Desc",
        Parent = Content,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 0, 32),
        Font = Enum.Font.Gotham,
        Text = desc,
        TextColor3 = Theme.TextDim,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1,
    })

    local ProgressBar = Create("Frame", {
        Name = "Progress",
        Parent = Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 3),
        Position = UDim2.new(0, 0, 1, -3),
    })

    local ProgressFill = Create("Frame", {
        Parent = ProgressBar,
        BackgroundColor3 = iconColor,
        Size = UDim2.new(1, 0, 1, 0),
    })

    Create("UICorner", {
        Parent = ProgressFill,
        CornerRadius = UDim.new(0, 2),
    })

    local ProgressGrad = Create("UIGradient", {
        Parent = ProgressFill,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, iconColor),
            ColorSequenceKeypoint.new(1, iconColor:Lerp(Color3.fromRGB(255, 255, 255), 0.4)),
        }),
    })

    local targetHeight = desc ~= "" and 65 or 45
    Frame.Size = UDim2.new(1, 0, 0, 0)

    Tween(Frame, 0.4, {Size = UDim2.new(1, 0, 0, targetHeight), BackgroundTransparency = 0})
    Tween(UIStroke, 0.4, {Transparency = 0})
    Tween(Title, 0.4, {TextTransparency = 0})
    Tween(Description, 0.4, {TextTransparency = 0})
    Tween(ProgressBar, 0.4, {BackgroundTransparency = 0})

    task.spawn(function()
        local elapsed = 0
        while elapsed < duration do
            local dt = RunService.RenderStepped:Wait()
            elapsed = elapsed + dt
            local progress = 1 - (elapsed / duration)
            ProgressFill.Size = UDim2.new(progress, 0, 1, 0)
        end
    end)

    task.delay(duration, function()
        Tween(Frame, 0.3, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1})
        Tween(UIStroke, 0.3, {Transparency = 1})
        Tween(Title, 0.3, {TextTransparency = 1})
        Tween(Description, 0.3, {TextTransparency = 1})
        Tween(ProgressBar, 0.3, {BackgroundTransparency = 1})

        task.wait(0.35)
        Frame:Destroy()
    end)
end

function Library:Watermark(text, logo)
    if Library.WatermarkObj then
        Library.WatermarkObj:Destroy()
    end

    local Frame = Create("Frame", {
        Name = "Watermark",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.BackgroundDark,
        Position = UDim2.new(0, 20, 0, 20),
        Size = UDim2.new(0, 0, 0, 32),
        ClipsDescendants = true,
    })

    Create("UICorner", {
        Parent = Frame,
        CornerRadius = UDim.new(0, 8),
    })

    Create("UIStroke", {
        Parent = Frame,
        Color = Theme.Outline,
        Thickness = 1.5,
    })

    local AccentBar = Create("Frame", {
        Parent = Frame,
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(0, 4, 1, 0),
    })

    local AccentGrad = Create("UIGradient", {
        Parent = AccentBar,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Accent),
            ColorSequenceKeypoint.new(1, Theme.AccentLight),
        }),
        Rotation = 90,
    })

    local Label = Create("TextLabel", {
        Parent = Frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -18, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = text or "Rufus",
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    Library.WatermarkObj = Frame

    local textBounds = Label.TextBounds
    Frame.Size = UDim2.new(0, textBounds.X + 28, 0, 32)

    return Frame
end

function Library:KeybindsList()
    if Library.KeybindsListObj then
        Library.KeybindsListObj:Destroy()
    end

    local Frame = Create("Frame", {
        Name = "KeybindsList",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.BackgroundDark,
        Position = UDim2.new(1, -230, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 210, 0, 34),
        ClipsDescendants = true,
    })

    Create("UICorner", {
        Parent = Frame,
        CornerRadius = UDim.new(0, 8),
    })

    Create("UIStroke", {
        Parent = Frame,
        Color = Theme.Outline,
        Thickness = 1.5,
    })

    local Header = Create("Frame", {
        Parent = Frame,
        BackgroundColor3 = Theme.Background,
        Size = UDim2.new(1, 0, 0, 32),
    })

    Create("UICorner", {
        Parent = Header,
        CornerRadius = UDim.new(0, 8),
    })

    Create("Frame", {
        Parent = Header,
        BackgroundColor3 = Theme.Background,
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
    })

    Create("TextLabel", {
        Parent = Header,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Font = Enum.Font.GothamBold,
        Text = "Keybinds",
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local AccentLine = Create("Frame", {
        Parent = Header,
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(0, 4, 0.65, 0),
        Position = UDim2.new(0, 0, 0.175, 0),
    })

    local AccentGrad = Create("UIGradient", {
        Parent = AccentLine,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Accent),
            ColorSequenceKeypoint.new(1, Theme.AccentLight),
        }),
        Rotation = 90,
    })

    local Content = Create("Frame", {
        Parent = Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, -36),
        Position = UDim2.new(0, 10, 0, 36),
    })

    local Layout = Create("UIListLayout", {
        Parent = Content,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
    })

    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Frame.Size = UDim2.new(0, 210, 0, 34 + Layout.AbsoluteContentSize.Y + 10)
    end)

    Library.KeybindsListObj = Frame
    Library.KeybindsListContent = Content

    return Frame
end

function Library:Window(data)
    local window = {}
    local name = data.Name or data.name or "Rufus"
    local version = data.Version or data.version or "1.0.0"
    local logo = data.Logo or data.logo or ""
    local size = data.Size or data.size or UDim2.new(0, 650, 0, 460)
    Library.FadeSpeed = data.FadeSpeed or data.fadespeed or 0.35

    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Background,
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        ClipsDescendants = true,
    })

    Create("UICorner", {
        Parent = MainFrame,
        CornerRadius = UDim.new(0, 12),
    })

    Create("UIStroke", {
        Parent = MainFrame,
        Color = Theme.Outline,
        Thickness = 1.5,
    })

    local TitleBar = Create("Frame", {
        Name = "TitleBar",
        Parent = MainFrame,
        BackgroundColor3 = Theme.BackgroundDark,
        Size = UDim2.new(1, 0, 0, 40),
    })

    Create("UICorner", {
        Parent = TitleBar,
        CornerRadius = UDim.new(0, 12),
    })

    Create("Frame", {
        Parent = TitleBar,
        BackgroundColor3 = Theme.BackgroundDark,
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
    })

    if logo ~= "" then
        Create("ImageLabel", {
            Parent = TitleBar,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 22, 0, 22),
            Position = UDim2.new(0, 14, 0.5, -11),
            Image = logo,
            ScaleType = Enum.ScaleType.Fit,
        })
    end

    local TitleText = Create("TextLabel", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, logo ~= "" and 42 or 16, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = name,
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    Create("TextLabel", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, (logo ~= "" and 42 or 16) + TitleText.TextBounds.X + 8, 0, 5),
        Size = UDim2.new(0, 200, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "v" .. version,
        TextColor3 = Theme.TextDimmer,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local CloseBtn = Create("TextButton", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(1, -40, 0, 0),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = Theme.TextDim,
        TextSize = 20,
        AutoButtonColor = false,
    })

    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, 0.2, {TextColor3 = Theme.Danger})
    end)

    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, 0.2, {TextColor3 = Theme.TextDim})
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        Library:Unload()
    end)

    local MinBtn = Create("TextButton", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(1, -80, 0, 0),
        Font = Enum.Font.GothamBold,
        Text = "—",
        TextColor3 = Theme.TextDim,
        TextSize = 15,
        AutoButtonColor = false,
    })

    MinBtn.MouseEnter:Connect(function()
        Tween(MinBtn, 0.2, {TextColor3 = Theme.Text})
    end)

    MinBtn.MouseLeave:Connect(function()
        Tween(MinBtn, 0.2, {TextColor3 = Theme.TextDim})
    end)

    MinBtn.MouseButton1Click:Connect(function()
        Library.Toggled = not Library.Toggled
        if Library.Toggled then
            Tween(MainFrame, Library.FadeSpeed, {Size = size})
        else
            Tween(MainFrame, Library.FadeSpeed, {Size = UDim2.new(size.X.Scale, size.X.Offset, 0, 40)})
        end
    end)

    local dragging, dragInput, dragStart, startPos

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Sidebar,
        Size = UDim2.new(0, 170, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
    })

    Create("UICorner", {
        Parent = Sidebar,
        CornerRadius = UDim.new(0, 12),
    })

    Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = Theme.Sidebar,
        Size = UDim2.new(0, 12, 1, 0),
        Position = UDim2.new(1, -12, 0, 0),
    })

    Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = Theme.Sidebar,
        Size = UDim2.new(1, 0, 0, 12),
    })

    local TabHolder = Create("Frame", {
        Name = "TabHolder",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
    })

    Create("UIListLayout", {
        Parent = TabHolder,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 3),
    })

    local Content = Create("Frame", {
        Name = "Content",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -180, 1, -50),
        Position = UDim2.new(0, 180, 0, 40),
    })

    local PageHolder = Create("Frame", {
        Name = "PageHolder",
        Parent = Content,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
    })

    local AccentLine = Create("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 0, 40),
    })

    local AccentGrad = Create("UIGradient", {
        Parent = AccentLine,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Accent),
            ColorSequenceKeypoint.new(0.5, Theme.AccentLight),
            ColorSequenceKeypoint.new(1, Theme.Accent),
        }),
    })

    function window:Page(pageData)
        local page = {}
        local pageName = pageData.Name or pageData.name or "Page"
        local columns = pageData.Columns or pageData.columns or 2
        local hasSubPages = pageData.SubPages or pageData.subpages or false

        local Tab = Create("TextButton", {
            Name = pageName,
            Parent = TabHolder,
            BackgroundColor3 = Theme.Sidebar,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 36),
            Font = Enum.Font.GothamSemibold,
            Text = "",
            AutoButtonColor = false,
        })

        Create("UICorner", {
            Parent = Tab,
            CornerRadius = UDim.new(0, 8),
        })

        local TabIndicator = Create("Frame", {
            Parent = Tab,
            BackgroundColor3 = Theme.Accent,
            Size = UDim2.new(0, 4, 0, 0),
            Position = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
        })

        Create("UICorner", {
            Parent = TabIndicator,
            CornerRadius = UDim.new(0, 3),
        })

        local TabIndGrad = Create("UIGradient", {
            Parent = TabIndicator,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Theme.Accent),
                ColorSequenceKeypoint.new(1, Theme.AccentLight),
            }),
            Rotation = 90,
        })

        local TabText = Create("TextLabel", {
            Parent = Tab,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -28, 1, 0),
            Position = UDim2.new(0, 14, 0, 0),
            Font = Enum.Font.GothamSemibold,
            Text = pageName,
            TextColor3 = Theme.TextDim,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local PageFrame = Create("Frame", {
            Name = pageName,
            Parent = PageHolder,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
        })

        local SubPageHolder = nil
        local SubPageContent = nil
        local currentSubPage = nil

        if hasSubPages then
            SubPageHolder = Create("Frame", {
                Parent = PageFrame,
                BackgroundColor3 = Theme.BackgroundLight,
                Size = UDim2.new(1, 0, 0, 34),
            })

            Create("UICorner", {
                Parent = SubPageHolder,
                CornerRadius = UDim.new(0, 8),
            })

            local SubTabLayout = Create("UIListLayout", {
                Parent = SubPageHolder,
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 3),
            })

            SubTabLayout.VerticalAlignment = Enum.VerticalAlignment.Center

            Create("UIPadding", {
                Parent = SubPageHolder,
                PaddingLeft = UDim.new(0, 8),
            })

            SubPageContent = Create("Frame", {
                Parent = PageFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, -38),
                Position = UDim2.new(0, 0, 0, 38),
            })
        end

        local mainContentParent = hasSubPages and SubPageContent or PageFrame

        local function CreateColumns(parent)
            local cols = {}
            local colWidth = (1 / columns)

            for i = 1, columns do
                local col = Create("ScrollingFrame", {
                    Name = "Column" .. i,
                    Parent = parent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(colWidth, -6 - (i > 1 and 6 or 0), 1, 0),
                    Position = UDim2.new(colWidth * (i - 1), (i > 1 and 6 or 0), 0, 0),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                })

                Create("UIPadding", {
                    Parent = col,
                    PaddingTop = UDim.new(0, 5),
                    PaddingBottom = UDim.new(0, 5),
                    PaddingLeft = UDim.new(0, 5),
                    PaddingRight = UDim.new(0, 5),
                })

                local layout = Create("UIListLayout", {
                    Parent = col,
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 8),
                })

                layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    col.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
                end)

                cols[i] = col
            end

            return cols
        end

        local columnFrames = CreateColumns(mainContentParent)

        local function SelectTab()
            for _, child in pairs(TabHolder:GetChildren()) do
                if child:IsA("TextButton") and child ~= Tab then
                    local textLabel = child:FindFirstChildWhichIsA("TextLabel")
                    if textLabel then
                        Tween(textLabel, 0.25, {TextColor3 = Theme.TextDim})
                    end
                    local ind = child:FindFirstChildWhichIsA("Frame")
                    if ind then
                        Tween(ind, 0.25, {Size = UDim2.new(0, 4, 0, 0)})
                    end
                    for _, pg in pairs(PageHolder:GetChildren()) do
                        if pg:IsA("Frame") and pg ~= PageFrame then
                            pg.Visible = false
                        end
                    end
                end
            end

            Tween(TabText, 0.25, {TextColor3 = Theme.Text})
            Tween(TabIndicator, 0.25, {Size = UDim2.new(0, 4, 0.65, 0)})
            PageFrame.Visible = true
            Library.CurrentPage = pageName
        end

        Tab.MouseButton1Click:Connect(SelectTab)

        Tab.MouseEnter:Connect(function()
            if Library.CurrentPage ~= pageName then
                Tween(Tab, 0.2, {BackgroundTransparency = 0.6, BackgroundColor3 = Theme.Hover})
            end
        end)

        Tab.MouseLeave:Connect(function()
            if Library.CurrentPage ~= pageName then
                Tween(Tab, 0.2, {BackgroundTransparency = 1})
            end
        end)

        if not Library.CurrentPage then
            SelectTab()
        end

        function page:Section(sectionData)
            local section = {}
            local sectionName = sectionData.Name or sectionData.name or "Section"
            local side = sectionData.Side or sectionData.side or 1

            side = Clamp(side, 1, columns)
            local parent = columnFrames[side]

            local SectionFrame = Create("Frame", {
                Name = sectionName,
                Parent = parent,
                BackgroundColor3 = Theme.Section,
                Size = UDim2.new(1, 0, 0, 34),
                ClipsDescendants = true,
            })

            Create("UICorner", {
                Parent = SectionFrame,
                CornerRadius = UDim.new(0, 10),
            })

            Create("UIStroke", {
                Parent = SectionFrame,
                Color = Theme.SectionBorder,
                Thickness = 1.5,
            })

            Create("TextLabel", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -24, 0, 32),
                Position = UDim2.new(0, 12, 0, 0),
                Font = Enum.Font.GothamBold,
                Text = sectionName,
                TextColor3 = Theme.Text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
            })

            local SectionContent = Create("Frame", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 1, -36),
                Position = UDim2.new(0, 10, 0, 34),
            })

            local SectionLayout = Create("UIListLayout", {
                Parent = SectionContent,
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6),
            })

            SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionFrame.Size = UDim2.new(1, 0, 0, 36 + SectionLayout.AbsoluteContentSize.Y + 10)
            end)

            function section:Toggle(toggleData)
                local toggle = {}
                local tName = toggleData.Name or toggleData.name or "Toggle"
                local default = toggleData.Default or toggleData.default or false
                local flag = toggleData.Flag or toggleData.flag or tName
                local callback = toggleData.Callback or toggleData.callback or function() end

                local enabled = default

                local ToggleFrame = Create("Frame", {
                    Name = tName,
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 24),
                })

                Create("TextLabel", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -50, 1, 0),
                    Position = UDim2.new(0, 6, 0, 0),
                    Font = Enum.Font.Gotham,
                    Text = tName,
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })

                local ToggleBox = Create("Frame", {
                    Parent = ToggleFrame,
                    BackgroundColor3 = Theme.ToggleOff,
                    Size = UDim2.new(0, 36, 0, 18),
                    Position = UDim2.new(1, -40, 0.5, -9),
                })

                Create("UICorner", {
                    Parent = ToggleBox,
                    CornerRadius = UDim.new(1, 0),
                })

                local ToggleCircle = Create("Frame", {
                    Parent = ToggleBox,
                    BackgroundColor3 = Theme.TextDim,
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(0, 2, 0.5, -7),
                })

                Create("UICorner", {
                    Parent = ToggleCircle,
                    CornerRadius = UDim.new(1, 0),
                })

                local ToggleBtn = Create("TextButton", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                })

                local function SetState(state, noCallback)
                    enabled = state
                    if enabled then
                        Tween(ToggleBox, 0.25, {BackgroundColor3 = Theme.Accent})
                        Tween(ToggleCircle, 0.25, {Position = UDim2.new(1, -16, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
                    else
                        Tween(ToggleBox, 0.25, {BackgroundColor3 = Theme.ToggleOff})
                        Tween(ToggleCircle, 0.25, {Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Theme.TextDim})
                    end
                    Library.Flags[flag] = enabled
                    if not noCallback then
                        callback(enabled)
                    end
                end

                ToggleBtn.MouseButton1Click:Connect(function()
                    SetState(not enabled)
                end)

                function toggle:Set(state)
                    SetState(state)
                end

                function toggle:Get()
                    return enabled
                end

                function toggle:Keybind(kbData)
                    local kb = {}
                    local kbName = kbData.Name or kbData.name or "Keybind"
                    local kbFlag = kbData.Flag or kbData.flag or kbName
                    local kbMode = kbData.Mode or kbData.mode or "Toggle"
                    local kbDefault = kbData.Default or kbData.default or Enum.KeyCode.Unknown
                    local kbCallback = kbData.Callback or kbData.callback or function() end

                    local currentKey = kbDefault
                    local listening = false
                    local kbEnabled = false

                    local KeybindFrame = Create("Frame", {
                        Parent = ToggleFrame,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 65, 0, 18),
                        Position = UDim2.new(1, -110, 0.5, -9),
                    })

                    local KeybindBtn = Create("TextButton", {
                        Parent = KeybindFrame,
                        BackgroundColor3 = Theme.InputBg,
                        Size = UDim2.new(1, 0, 1, 0),
                        Font = Enum.Font.Gotham,
                        Text = currentKey ~= Enum.KeyCode.Unknown and currentKey.Name or "None",
                        TextColor3 = Theme.TextDim,
                        TextSize = 11,
                        AutoButtonColor = false,
                    })

                    Create("UICorner", {
                        Parent = KeybindBtn,
                        CornerRadius = UDim.new(0, 5),
                    })

                    Create("UIStroke", {
                        Parent = KeybindBtn,
                        Color = Theme.Outline,
                        Thickness = 1,
                    })

                    KeybindBtn.MouseButton1Click:Connect(function()
                        listening = true
                        KeybindBtn.Text = "..."
                        KeybindBtn.TextColor3 = Theme.Accent
                    end)

                    local inputConn
                    inputConn = UIS.InputBegan:Connect(function(input, processed)
                        if processed then return end

                        if listening then
                            if input.KeyCode ~= Enum.KeyCode.Unknown then
                                currentKey = input.KeyCode
                                KeybindBtn.Text = currentKey.Name
                                KeybindBtn.TextColor3 = Theme.TextDim
                                listening = false
                                Library.Flags[kbFlag] = currentKey
                            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                                currentKey = Enum.KeyCode.Unknown
                                KeybindBtn.Text = "None"
                                KeybindBtn.TextColor3 = Theme.TextDim
                                listening = false
                                Library.Flags[kbFlag] = currentKey
                            end
                            return
                        end

                        if input.KeyCode == currentKey and currentKey ~= Enum.KeyCode.Unknown then
                            if kbMode == "Toggle" then
                                kbEnabled = not kbEnabled
                                SetState(kbEnabled)
                                kbCallback(kbEnabled)
                            else
                                SetState(true)
                                kbCallback(true)
                            end
                        end
                    end)

                    if kbMode == "Hold" then
                        local endConn
                        endConn = UIS.InputEnded:Connect(function(input, processed)
                            if input.KeyCode == currentKey and currentKey ~= Enum.KeyCode.Unknown then
                                SetState(false)
                                kbCallback(false)
                            end
                        end)
                        table.insert(Library.Connections, endConn)
                    end

                    table.insert(Library.Connections, inputConn)

                    function kb:Set(key)
                        currentKey = key
                        KeybindBtn.Text = key ~= Enum.KeyCode.Unknown and key.Name or "None"
                        Library.Flags[kbFlag] = key
                    end

                    return kb
                end

                function toggle:Colorpicker(cpData)
                    local cp = {}
                    local cpName = cpData.Name or cpData.name or "Color"
                    local cpDefault = cpData.Default or cpData.default or Color3.fromRGB(255, 255, 255)
                    local cpFlag = cpData.Flag or cpData.flag or cpName
                    local cpAlpha = cpData.Alpha or cpData.alpha or 1
                    local cpCallback = cpData.Callback or cpData.callback or function() end

                    local currentColor = cpDefault
                    local open = false

                    local ColorBtn = Create("TextButton", {
                        Parent = ToggleFrame,
                        BackgroundColor3 = currentColor,
                        Size = UDim2.new(0, 20, 0, 16),
                        Position = UDim2.new(1, -24, 0.5, -8),
                        AutoButtonColor = false,
                        Text = "",
                    })

                    Create("UICorner", {
                        Parent = ColorBtn,
                        CornerRadius = UDim.new(0, 4),
                    })

                    Create("UIStroke", {
                        Parent = ColorBtn,
                        Color = Theme.Outline,
                        Thickness = 1.5,
                    })

                    local PickerFrame = Create("Frame", {
                        Parent = SectionContent,
                        BackgroundColor3 = Theme.BackgroundDark,
                        Size = UDim2.new(1, 0, 0, 0),
                        Visible = false,
                        ClipsDescendants = true,
                    })

                    Create("UICorner", {
                        Parent = PickerFrame,
                        CornerRadius = UDim.new(0, 8),
                    })

                    Create("UIStroke", {
                        Parent = PickerFrame,
                        Color = Theme.Outline,
                        Thickness = 1.5,
                    })

                    local SVPicker = Create("ImageLabel", {
                        Parent = PickerFrame,
                        BackgroundColor3 = currentColor,
                        Size = UDim2.new(1, -20, 0, 130),
                        Position = UDim2.new(0, 10, 0, 10),
                        Image = "rbxassetid://4155801252",
                    })

                    Create("UICorner", {
                        Parent = SVPicker,
                        CornerRadius = UDim.new(0, 6),
                    })

                    local SVPointer = Create("Frame", {
                        Parent = SVPicker,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Size = UDim2.new(0, 10, 0, 10),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                    })

                    Create("UICorner", {
                        Parent = SVPointer,
                        CornerRadius = UDim.new(1, 0),
                    })

                    Create("UIStroke", {
                        Parent = SVPointer,
                        Color = Color3.fromRGB(0, 0, 0),
                        Thickness = 1.5,
                    })

                    local HueBar = Create("Frame", {
                        Parent = PickerFrame,
                        Size = UDim2.new(1, -20, 0, 16),
                        Position = UDim2.new(0, 10, 0, 146),
                    })

                    Create("UIGradient", {
                        Parent = HueBar,
                        Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
                        }),
                    })

                    Create("UICorner", {
                        Parent = HueBar,
                        CornerRadius = UDim.new(0, 6),
                    })

                    local HuePointer = Create("Frame", {
                        Parent = HueBar,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Size = UDim2.new(0, 5, 1, 4),
                        Position = UDim2.new(0, 0, 0, -2),
                    })

                    Create("UICorner", {
                        Parent = HuePointer,
                        CornerRadius = UDim.new(0, 3),
                    })

                    local h, s, v = Color3.toHSV(currentColor)

                    local function UpdateColor(newH, newS, newV)
                        h = newH or h
                        s = newS or s
                        v = newV or v

                        currentColor = Color3.fromHSV(h, s, v)
                        ColorBtn.BackgroundColor3 = currentColor
                        SVPicker.BackgroundColor3 = Color3.fromHSV(h, 1, 1)

                        SVPointer.Position = UDim2.new(s, 0, 1 - v, 0)
                        HuePointer.Position = UDim2.new(h, 0, 0, -2)

                        Library.Flags[cpFlag] = {Color = currentColor, Transparency = cpAlpha}
                        cpCallback(currentColor, cpAlpha)
                    end

                    UpdateColor(h, s, v)

                    local svDragging = false
                    local hueDragging = false

                    SVPicker.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            svDragging = true
                            local pos = input.Position - SVPicker.AbsolutePosition
                            UpdateColor(nil, Clamp(pos.X / SVPicker.AbsoluteSize.X, 0, 1), Clamp(1 - pos.Y / SVPicker.AbsoluteSize.Y, 0, 1))
                        end
                    end)

                    HueBar.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            hueDragging = true
                            local pos = input.Position - HueBar.AbsolutePosition
                            UpdateColor(Clamp(pos.X / HueBar.AbsoluteSize.X, 0, 1))
                        end
                    end)

                    UIS.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement then
                            if svDragging then
                                local pos = input.Position - SVPicker.AbsolutePosition
                                UpdateColor(nil, Clamp(pos.X / SVPicker.AbsoluteSize.X, 0, 1), Clamp(1 - pos.Y / SVPicker.AbsoluteSize.Y, 0, 1))
                            end
                            if hueDragging then
                                local pos = input.Position - HueBar.AbsolutePosition
                                UpdateColor(Clamp(pos.X / HueBar.AbsoluteSize.X, 0, 1))
                            end
                        end
                    end)

                    UIS.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            svDragging = false
                            hueDragging = false
                        end
                    end)

                    ColorBtn.MouseButton1Click:Connect(function()
                        open = not open
                        PickerFrame.Visible = open
                        if open then
                            Tween(PickerFrame, 0.25, {Size = UDim2.new(1, 0, 0, 175)})
                        else
                            Tween(PickerFrame, 0.25, {Size = UDim2.new(1, 0, 0, 0)})
                            task.delay(0.25, function()
                                PickerFrame.Visible = false
                            end)
                        end
                    end)

                    function cp:Set(color)
                        local nh, ns, nv = Color3.toHSV(color)
                        UpdateColor(nh, ns, nv)
                    end

                    return cp
                end

                SetState(default, true)
                Library.Flags[flag] = enabled

                return toggle
            end

            function section:Slider(sliderData)
                local slider = {}
                local sName = sliderData.Name or sliderData.name or "Slider"
                local min = sliderData.Min or sliderData.min or 0
                local max = sliderData.Max or sliderData.max or 100
                local default = sliderData.Default or sliderData.default or min
                local decimals = sliderData.Decimals or sliderData.decimals or 0
                local flag = sliderData.Flag or sliderData.flag or sName
                local suffix = sliderData.Suffix or sliderData.suffix or ""
                local callback = sliderData.Callback or sliderData.callback or function() end

                local value = default

                local SliderFrame = Create("Frame", {
                    Name = sName,
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 40),
                })

                Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -70, 0, 18),
                    Font = Enum.Font.Gotham,
                    Text = sName,
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })

                local SliderValue = Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 65, 0, 18),
                    Position = UDim2.new(1, -65, 0, 0),
                    Font = Enum.Font.GothamBold,
                    Text = Round(value, decimals) .. suffix,
                    TextColor3 = Theme.Accent,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right,
                })

                local SliderBg = Create("Frame", {
                    Parent = SliderFrame,
                    BackgroundColor3 = Theme.SliderBg,
                    Size = UDim2.new(1, 0, 0, 8),
                    Position = UDim2.new(0, 0, 0, 26),
                })

                Create("UICorner", {
                    Parent = SliderBg,
                    CornerRadius = UDim.new(1, 0),
                })

                local SliderFill = Create("Frame", {
                    Parent = SliderBg,
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                })

                Create("UICorner", {
                    Parent = SliderFill,
                    CornerRadius = UDim.new(1, 0),
                })

                local SliderGrad = Create("UIGradient", {
                    Parent = SliderFill,
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Theme.Accent),
                        ColorSequenceKeypoint.new(1, Theme.AccentLight),
                    }),
                })

                local SliderCircle = Create("Frame", {
                    Parent = SliderBg,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new((value - min) / (max - min), -7, 0.5, -7),
                })

                Create("UICorner", {
                    Parent = SliderCircle,
                    CornerRadius = UDim.new(1, 0),
                })

                Create("UIStroke", {
                    Parent = SliderCircle,
                    Color = Theme.Accent,
                    Thickness = 2,
                })

                local dragging = false

                local function SetValue(val)
                    value = Clamp(Round(val, decimals), min, max)
                    local percent = (value - min) / (max - min)
                    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    SliderCircle.Position = UDim2.new(percent, -7, 0.5, -7)
                    SliderValue.Text = value .. suffix
                    Library.Flags[flag] = value
                    callback(value)
                end

                SliderBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        local pos = input.Position - SliderBg.AbsolutePosition
                        local percent = Clamp(pos.X / SliderBg.AbsoluteSize.X, 0, 1)
                        SetValue(min + (max - min) * percent)
                    end
                end)

                UIS.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local pos = input.Position - SliderBg.AbsolutePosition
                        local percent = Clamp(pos.X / SliderBg.AbsoluteSize.X, 0, 1)
                        SetValue(min + (max - min) * percent)
                    end
                end)

                UIS.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                SetValue(default)

                function slider:Set(val)
                    SetValue(val)
                end

                function slider:Get()
                    return value
                end

                return slider
            end

            function section:Dropdown(dropdownData)
                local dropdown = {}
                local dName = dropdownData.Name or dropdownData.name or "Dropdown"
                local items = dropdownData.Items or dropdownData.items or {}
                local default = dropdownData.Default or dropdownData.default or (items[1] and items[1] or "")
                local maxSize = dropdownData.MaxSize or dropdownData.maxsize or 5
                local flag = dropdownData.Flag or dropdownData.flag or dName
                local multi = dropdownData.Multi or dropdownData.multi or false
                local callback = dropdownData.Callback or dropdownData.callback or function() end

                local selected = multi and {} or default
                if multi and type(default) == "string" and default ~= "" then
                    selected = {default}
                elseif multi and type(default) == "table" then
                    selected = default
                end

                local open = false

                local DropdownFrame = Create("Frame", {
                    Name = dName,
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 44),
                })

                Create("TextLabel", {
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    Font = Enum.Font.Gotham,
                    Text = dName,
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })

                local DropdownBtn = Create("TextButton", {
                    Parent = DropdownFrame,
                    BackgroundColor3 = Theme.InputBg,
                    Size = UDim2.new(1, 0, 0, 22),
                    Position = UDim2.new(0, 0, 0, 22),
                    Font = Enum.Font.Gotham,
                    Text = "",
                    AutoButtonColor = false,
                })

                Create("UICorner", {
                    Parent = DropdownBtn,
                    CornerRadius = UDim.new(0, 6),
                })

                Create("UIStroke", {
                    Parent = DropdownBtn,
                    Color = Theme.Outline,
                    Thickness = 1.5,
                })

                local SelectedText = Create("TextLabel", {
                    Parent = DropdownBtn,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -28, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    Font = Enum.Font.Gotham,
                    Text = multi and (#selected > 0 and table.concat(selected, ", ") or "None") or (selected or "None"),
                    TextColor3 = Theme.TextDim,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                })

                local Arrow = Create("TextLabel", {
                    Parent = DropdownBtn,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 24, 1, 0),
                    Position = UDim2.new(1, -24, 0, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "▾",
                    TextColor3 = Theme.TextDim,
                    TextSize = 11,
                })

                local ListFrame = Create("ScrollingFrame", {
                    Parent = SectionContent,
                    BackgroundColor3 = Theme.DropdownBg,
                    Size = UDim2.new(1, 0, 0, 0),
                    Visible = false,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = Theme.Accent,
                    ClipsDescendants = true,
                    BorderSizePixel = 0,
                })

                Create("UICorner", {
                    Parent = ListFrame,
                    CornerRadius = UDim.new(0, 6),
                })

                Create("UIStroke", {
                    Parent = ListFrame,
                    Color = Theme.Outline,
                    Thickness = 1.5,
                })

                Create("UIListLayout", {
                    Parent = ListFrame,
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })

                local function UpdateText()
                    if multi then
                        SelectedText.Text = #selected > 0 and table.concat(selected, ", ") or "None"
                    else
                        SelectedText.Text = selected or "None"
                    end
                end

                local function BuildList()
                    for _, child in pairs(ListFrame:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end

                    for _, item in ipairs(items) do
                        local isSelected = multi and table.find(selected, item) or selected == item

                        local ItemBtn = Create("TextButton", {
                            Parent = ListFrame,
                            BackgroundColor3 = isSelected and Theme.Hover or Theme.DropdownBg,
                            BackgroundTransparency = isSelected and 0.4 or 1,
                            Size = UDim2.new(1, 0, 0, 24),
                            Font = Enum.Font.Gotham,
                            Text = "  " .. item,
                            TextColor3 = isSelected and Theme.Accent or Theme.TextDim,
                            TextSize = 12,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            AutoButtonColor = false,
                        })

                        ItemBtn.MouseEnter:Connect(function()
                            Tween(ItemBtn, 0.15, {BackgroundTransparency = 0.4, BackgroundColor3 = Theme.Hover})
                        end)

                        ItemBtn.MouseLeave:Connect(function()
                            local sel = multi and table.find(selected, item) or selected == item
                            if not sel then
                                Tween(ItemBtn, 0.15, {BackgroundTransparency = 1, BackgroundColor3 = Theme.DropdownBg})
                            end
                        end)

                        ItemBtn.MouseButton1Click:Connect(function()
                            if multi then
                                local idx = table.find(selected, item)
                                if idx then
                                    table.remove(selected, idx)
                                else
                                    table.insert(selected, item)
                                end
                                Library.Flags[flag] = selected
                                callback(selected)
                            else
                                selected = item
                                Library.Flags[flag] = selected
                                callback(selected)
                                open = false
                                Tween(ListFrame, 0.25, {Size = UDim2.new(1, 0, 0, 0)})
                                task.delay(0.25, function()
                                    ListFrame.Visible = false
                                end)
                                Tween(Arrow, 0.25, {Rotation = 0})
                            end
                            UpdateText()
                            BuildList()
                        end)
                    end

                    local itemCount = math.min(#items, maxSize)
                    ListFrame.CanvasSize = UDim2.new(0, 0, 0, itemCount * 24)
                end

                BuildList()

                DropdownBtn.MouseButton1Click:Connect(function()
                    open = not open
                    ListFrame.Visible = open
                    if open then
                        local itemCount = math.min(#items, maxSize)
                        Tween(ListFrame, 0.25, {Size = UDim2.new(1, 0, 0, itemCount * 24)})
                        Tween(Arrow, 0.25, {Rotation = 180})
                    else
                        Tween(ListFrame, 0.25, {Size = UDim2.new(1, 0, 0, 0)})
                        Tween(Arrow, 0.25, {Rotation = 0})
                        task.delay(0.25, function()
                            ListFrame.Visible = false
                        end)
                    end
                end)

                function dropdown:Set(val)
                    if multi then
                        selected = type(val) == "table" and val or {val}
                    else
                        selected = val
                    end
                    Library.Flags[flag] = selected
                    UpdateText()
                    BuildList()
                    callback(selected)
                end

                function dropdown:Get()
                    return selected
                end

                function dropdown:Refresh(newItems)
                    items = newItems
                    BuildList()
                end

                Library.Flags[flag] = selected

                return dropdown
            end

            function section:Button(buttonData)
                local button = {}
                local bName = buttonData.Name or buttonData.name or "Button"
                local callback = buttonData.Callback or buttonData.callback or function() end

                local ButtonFrame = Create("Frame", {
                    Name = bName,
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 28),
                })

                local Button = Create("TextButton", {
                    Parent = ButtonFrame,
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = bName,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 13,
                    AutoButtonColor = false,
                })

                Create("UICorner", {
                    Parent = Button,
                    CornerRadius = UDim.new(0, 7),
                })

                local ButtonGrad = Create("UIGradient", {
                    Parent = Button,
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Theme.Accent),
                        ColorSequenceKeypoint.new(1, Theme.AccentLight),
                    }),
                    Rotation = 90,
                })

                Button.MouseEnter:Connect(function()
                    Tween(Button, 0.2, {BackgroundColor3 = Theme.AccentDark})
                end)

                Button.MouseLeave:Connect(function()
                    Tween(Button, 0.2, {BackgroundColor3 = Theme.Accent})
                end)

                Button.MouseButton1Down:Connect(function()
                    Tween(Button, 0.1, {Size = UDim2.new(0.96, 0, 0.88, 0), Position = UDim2.new(0.02, 0, 0.06, 0)})
                end)

                Button.MouseButton1Up:Connect(function()
                    Tween(Button, 0.1, {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0)})
                end)

                Button.MouseButton1Click:Connect(function()
                    task.spawn(callback)
                end)

                function button:Fire()
                    task.spawn(callback)
                end

                return button
            end

            function section:Textbox(textboxData)
                local textbox = {}
                local tbName = textboxData.Name or textboxData.name or "Textbox"
                local default = textboxData.Default or textboxData.default or ""
                local placeholder = textboxData.Placeholder or textboxData.placeholder or ""
                local flag = textboxData.Flag or textboxData.flag or tbName
                local callback = textboxData.Callback or textboxData.callback or function() end

                local TBFrame = Create("Frame", {
                    Name = tbName,
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 44),
                })

                Create("TextLabel", {
                    Parent = TBFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    Font = Enum.Font.Gotham,
                    Text = tbName,
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })

                local InputBox = Create("TextBox", {
                    Parent = TBFrame,
                    BackgroundColor3 = Theme.InputBg,
                    Size = UDim2.new(1, 0, 0, 22),
                    Position = UDim2.new(0, 0, 0, 22),
                    Font = Enum.Font.Gotham,
                    Text = default,
                    PlaceholderText = placeholder,
                    PlaceholderColor3 = Theme.TextDimmer,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    ClearTextOnFocus = false,
                })

                Create("UICorner", {
                    Parent = InputBox,
                    CornerRadius = UDim.new(0, 6),
                })

                local InputStroke = Create("UIStroke", {
                    Parent = InputBox,
                    Color = Theme.Outline,
                    Thickness = 1.5,
                })

                Create("UIPadding", {
                    Parent = InputBox,
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10),
                })

                InputBox.Focused:Connect(function()
                    Tween(InputStroke, 0.25, {Color = Theme.Accent})
                end)

                InputBox.FocusLost:Connect(function(enterPressed)
                    Tween(InputStroke, 0.25, {Color = Theme.Outline})
                    Library.Flags[flag] = InputBox.Text
                    callback(InputBox.Text)
                end)

                Library.Flags[flag] = default

                function textbox:Set(text)
                    InputBox.Text = text
                    Library.Flags[flag] = text
                    callback(text)
                end

                function textbox:Get()
                    return InputBox.Text
                end

                return textbox
            end

            function section:Label(text, alignment)
                local label = {}

                local LabelFrame = Create("Frame", {
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                })

                local LabelText = Create("TextLabel", {
                    Parent = LabelFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text or "Label",
                    TextColor3 = Theme.TextDim,
                    TextSize = 13,
                    TextXAlignment = alignment == "Right" and Enum.TextXAlignment.Right or alignment == "Center" and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
                })

                function label:Set(newText)
                    LabelText.Text = newText
                end

                function label:Keybind(kbData)
                    local kb = {}
                    local kbName = kbData.Name or kbData.name or "Keybind"
                    local kbFlag = kbData.Flag or kbData.flag or kbName
                    local kbMode = kbData.Mode or kbData.mode or "Toggle"
                    local kbDefault = kbData.Default or kbData.default or Enum.KeyCode.Unknown
                    local kbCallback = kbData.Callback or kbData.callback or function() end

                    local currentKey = kbDefault
                    local listening = false
                    local kbEnabled = false

                    local KeybindBtn = Create("TextButton", {
                        Parent = LabelFrame,
                        BackgroundColor3 = Theme.InputBg,
                        Size = UDim2.new(0, 65, 0, 18),
                        Position = UDim2.new(1, -65, 0, 0),
                        Font = Enum.Font.Gotham,
                        Text = currentKey ~= Enum.KeyCode.Unknown and currentKey.Name or "None",
                        TextColor3 = Theme.TextDim,
                        TextSize = 11,
                        AutoButtonColor = false,
                    })

                    Create("UICorner", {
                        Parent = KeybindBtn,
                        CornerRadius = UDim.new(0, 5),
                    })

                    Create("UIStroke", {
                        Parent = KeybindBtn,
                        Color = Theme.Outline,
                        Thickness = 1,
                    })

                    KeybindBtn.MouseButton1Click:Connect(function()
                        listening = true
                        KeybindBtn.Text = "..."
                        KeybindBtn.TextColor3 = Theme.Accent
                    end)

                    local inputConn
                    inputConn = UIS.InputBegan:Connect(function(input, processed)
                        if processed then return end

                        if listening then
                            if input.KeyCode ~= Enum.KeyCode.Unknown then
                                currentKey = input.KeyCode
                                KeybindBtn.Text = currentKey.Name
                                KeybindBtn.TextColor3 = Theme.TextDim
                                listening = false
                                Library.Flags[kbFlag] = currentKey
                            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                                currentKey = Enum.KeyCode.Unknown
                                KeybindBtn.Text = "None"
                                KeybindBtn.TextColor3 = Theme.TextDim
                                listening = false
                                Library.Flags[kbFlag] = currentKey
                            end
                            return
                        end

                        if input.KeyCode == currentKey and currentKey ~= Enum.KeyCode.Unknown then
                            kbEnabled = not kbEnabled
                            kbCallback(kbEnabled)
                        end
                    end)

                    table.insert(Library.Connections, inputConn)

                    function kb:Set(key)
                        currentKey = key
                        KeybindBtn.Text = key ~= Enum.KeyCode.Unknown and key.Name or "None"
                        Library.Flags[kbFlag] = key
                    end

                    return kb
                end

                function label:Colorpicker(cpData)
                    local cp = {}
                    local cpDefault = cpData.Default or cpData.default or Color3.fromRGB(255, 255, 255)
                    local cpFlag = cpData.Flag or cpData.flag or "LabelColor"
                    local cpAlpha = cpData.Alpha or cpData.alpha or 1
                    local cpCallback = cpData.Callback or cpData.callback or function() end

                    local currentColor = cpDefault

                    local ColorBtn = Create("TextButton", {
                        Parent = LabelFrame,
                        BackgroundColor3 = currentColor,
                        Size = UDim2.new(0, 20, 0, 16),
                        Position = UDim2.new(1, -20, 0.5, -8),
                        AutoButtonColor = false,
                        Text = "",
                    })

                    Create("UICorner", {
                        Parent = ColorBtn,
                        CornerRadius = UDim.new(0, 4),
                    })

                    Create("UIStroke", {
                        Parent = ColorBtn,
                        Color = Theme.Outline,
                        Thickness = 1.5,
                    })

                    ColorBtn.MouseButton1Click:Connect(function()
                    end)

                    function cp:Set(color)
                        currentColor = color
                        ColorBtn.BackgroundColor3 = color
                        Library.Flags[cpFlag] = {Color = color, Transparency = cpAlpha}
                        cpCallback(color, cpAlpha)
                    end

                    Library.Flags[cpFlag] = {Color = currentColor, Transparency = cpAlpha}

                    return cp
                end

                return label
            end

            return section
        end

        function page:SubPage(subPageData)
            local subPage = {}
            local spName = subPageData.Name or subPageData.name or "SubPage"
            local spColumns = subPageData.Columns or subPageData.columns or 2

            local SubTabBtn = Create("TextButton", {
                Parent = SubPageHolder,
                BackgroundColor3 = Theme.BackgroundLight,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 90, 0, 26),
                Font = Enum.Font.GothamSemibold,
                Text = spName,
                TextColor3 = Theme.TextDim,
                TextSize = 12,
                AutoButtonColor = false,
            })

            Create("UICorner", {
                Parent = SubTabBtn,
                CornerRadius = UDim.new(0, 6),
            })

            local SubPageFrame = Create("Frame", {
                Parent = SubPageContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Visible = false,
            })

            local spCols = CreateColumns(SubPageFrame)

            local function SelectSubTab()
                for _, child in pairs(SubPageHolder:GetChildren()) do
                    if child:IsA("TextButton") and child ~= SubTabBtn then
                        Tween(child, 0.25, {TextColor3 = Theme.TextDim, BackgroundTransparency = 1})
                    end
                end
                for _, pg in pairs(SubPageContent:GetChildren()) do
                    if pg:IsA("Frame") and pg ~= SubPageFrame then
                        pg.Visible = false
                    end
                end
                Tween(SubTabBtn, 0.25, {TextColor3 = Theme.Text, BackgroundTransparency = 0.4, BackgroundColor3 = Theme.Hover})
                SubPageFrame.Visible = true
            end

            SubTabBtn.MouseButton1Click:Connect(SelectSubTab)

            if not currentSubPage then
                currentSubPage = spName
                SelectSubTab()
            end

            function subPage:Section(sectionData)
                local section = {}
                local sectionName = sectionData.Name or sectionData.name or "Section"
                local side = sectionData.Side or sectionData.side or 1

                side = Clamp(side, 1, spColumns)
                local parent = spCols[side]

                local SectionFrame = Create("Frame", {
                    Name = sectionName,
                    Parent = parent,
                    BackgroundColor3 = Theme.Section,
                    Size = UDim2.new(1, 0, 0, 34),
                    ClipsDescendants = true,
                })

                Create("UICorner", {
                    Parent = SectionFrame,
                    CornerRadius = UDim.new(0, 10),
                })

                Create("UIStroke", {
                    Parent = SectionFrame,
                    Color = Theme.SectionBorder,
                    Thickness = 1.5,
                })

                Create("TextLabel", {
                    Parent = SectionFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -24, 0, 32),
                    Position = UDim2.new(0, 12, 0, 0),
                    Font = Enum.Font.GothamBold,
                    Text = sectionName,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })

                local SectionContent = Create("Frame", {
                    Parent = SectionFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -20, 1, -36),
                    Position = UDim2.new(0, 10, 0, 34),
                })

                local SectionLayout = Create("UIListLayout", {
                    Parent = SectionContent,
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 6),
                })

                SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    SectionFrame.Size = UDim2.new(1, 0, 0, 36 + SectionLayout.AbsoluteContentSize.Y + 10)
                end)

                function section:Toggle(toggleData)
                    return page:Section({Name = sectionName, Side = side}):Toggle(toggleData)
                end

                function section:Slider(sliderData)
                    return page:Section({Name = sectionName, Side = side}):Slider(sliderData)
                end

                function section:Button(buttonData)
                    return page:Section({Name = sectionName, Side = side}):Button(buttonData)
                end

                function section:Label(text, alignment)
                    return page:Section({Name = sectionName, Side = side}):Label(text, alignment)
                end

                return section
            end

            return subPage
        end

        return page
    end

    local toggleConn
    toggleConn = UIS.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            Library.Toggled = not Library.Toggled
            MainFrame.Visible = Library.Toggled
        end
    end)
    table.insert(Library.Connections, toggleConn)

    Library.Loaded = true

    function Library:Unload()
        for _, conn in pairs(Library.Connections) do
            if conn and conn.Connected then
                conn:Disconnect()
            end
        end
        Library.Connections = {}
        ScreenGui:Destroy()
        Library.Loaded = false
        if getgenv then
            getgenv().Library = nil
        end
    end

    function Library:SetTheme(themeData)
        for key, value in pairs(themeData) do
            if Theme[key] then
                Theme[key] = value
            end
        end
    end

    function Library:GetConfig()
        local copy = {}
        for k, v in pairs(Library.Flags) do
            if type(v) == "table" then
                copy[k] = {}
                for k2, v2 in pairs(v) do
                    copy[k][k2] = v2
                end
            else
                copy[k] = v
            end
        end
        return copy
    end

    function Library:LoadConfig(config)
        for flag, value in pairs(config) do
            Library.Flags[flag] = value
        end
    end

    return window
end

return Library
