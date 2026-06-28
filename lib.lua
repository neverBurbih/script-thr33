--[[
    ██████╗ ██╗   ██╗███████╗███████╗████████╗
    ██╔══██╗██║   ██║██╔════╝██╔════╝╚══██╔══╝
    ██████╔╝██║   ██║█████╗  ███████╗   ██║   
    ██╔══██╗██║   ██║██╔══╝  ╚════██║   ██║   
    ██████╔╝╚██████╔╝███████╗███████║   ██║   
    ╚═════╝  ╚═════╝ ╚══════╝╚══════╝   ╚═╝   
                                              
    A modern Roblox UI library.
    
    Documentation:
    
    Library:Window({
        Name: string,
        Version: string,
        Logo: string (rbxassetid),
        Size: UDim2,
        FadeSpeed: number
    })
    
    Library:Watermark(Text: string, Logo: string)
    Library:KeybindsList()
    Library:Notification({
        Name: string,
        Description: string,
        Duration: number,
        Icon: string,
        IconColor: Color3
    })
    
    Window:Page({
        Name: string,
        Icon: string,
        Columns: number,
        SubPages: boolean
    })
    
    Page:SubPage({
        Name: string,
        Icon: string,
        Columns: number
    })
    
    Page/SubPage:Section({
        Name: string,
        Icon: string,
        Side: number
    })
    
    Section:Toggle({
        Name: string,
        Default: boolean,
        Flag: string,
        Callback: function
    })
    
    Toggle:Keybind({
        Name: string,
        Flag: string,
        Mode: string ("Toggle"/"Hold"),
        Default: Enum.KeyCode,
        Callback: function
    })
    
    Toggle:Colorpicker({
        Name: string,
        Default: Color3,
        Flag: string,
        Alpha: number,
        Callback: function
    })
    
    Section:Slider({
        Name: string,
        Min: number,
        Max: number,
        Default: number,
        Decimals: number,
        Flag: string,
        Suffix: string,
        Callback: function
    })
    
    Section:Textbox({
        Name: string,
        Default: string,
        Placeholder: string,
        Flag: string,
        Callback: function
    })
    
    Section:Dropdown({
        Name: string,
        Items: table,
        Default: string,
        MaxSize: number,
        Flag: string,
        Multi: boolean,
        Callback: function
    })
    
    Section:Button({
        Name: string,
        Callback: function
    })
    
    Section:Label(Name: string, Alignment: string)
    
    Label:Keybind({...})
    Label:Colorpicker({...})
]]

local Library = {
    Flags = {},
    Theme = {},
    Connections = {},
    Loaded = false
}

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

if getgenv().Library then
    pcall(function()
        getgenv().Library:Unload()
    end)
end

getgenv().Library = Library

local function SafeGet(obj, prop)
    local success, result = pcall(function()
        return obj[prop]
    end)
    return success and result or nil
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

local function Disconnect(conn)
    if conn and conn.Connected then
        conn:Disconnect()
    end
end

local function RGBToHSV(color)
    local h, s, v = Color3.toHSV(color)
    return h, s, v
end

local function Clamp(val, min, max)
    return math.max(min, math.min(max, val))
end

local function Round(val, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(val * mult + 0.5) / mult
end

local function DeepCopy(t)
    local copy = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            copy[k] = DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

-- Theme
Library.Theme = {
    Accent = Color3.fromRGB(120, 90, 255),
    AccentDark = Color3.fromRGB(95, 70, 210),
    Background = Color3.fromRGB(18, 18, 22),
    BackgroundDark = Color3.fromRGB(12, 12, 16),
    BackgroundLight = Color3.fromRGB(25, 25, 30),
    Sidebar = Color3.fromRGB(22, 22, 27),
    Section = Color3.fromRGB(28, 28, 34),
    SectionBorder = Color3.fromRGB(40, 40, 48),
    Text = Color3.fromRGB(240, 240, 245),
    TextDim = Color3.fromRGB(160, 160, 175),
    TextDimmer = Color3.fromRGB(100, 100, 115),
    ToggleOff = Color3.fromRGB(45, 45, 55),
    SliderBg = Color3.fromRGB(35, 35, 42),
    InputBg = Color3.fromRGB(32, 32, 38),
    DropdownBg = Color3.fromRGB(24, 24, 30),
    Hover = Color3.fromRGB(38, 38, 46),
    Outline = Color3.fromRGB(50, 50, 60),
    Danger = Color3.fromRGB(255, 80, 80),
    Success = Color3.fromRGB(80, 220, 120),
    Warning = Color3.fromRGB(255, 200, 60),
    Info = Color3.fromRGB(80, 160, 255),
}

local Theme = Library.Theme

-- ScreenGui setup
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

-- Utility objects
Library.ScreenGui = ScreenGui
Library.Window = nil
Library.WatermarkObj = nil
Library.KeybindsListObj = nil
Library.Notifications = {}
Library.Pages = {}
Library.CurrentPage = nil
Library.FadeSpeed = 0.35
Library.Toggled = true

-- Notification system
local NotificationHolder = Create("Frame", {
    Name = "Notifications",
    Parent = ScreenGui,
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -20, 0, 20),
    Size = UDim2.new(0, 320, 1, -40),
    AnchorPoint = Vector2.new(0, 0),
})

local NotificationLayout = Create("UIListLayout", {
    Parent = NotificationHolder,
    FillDirection = Enum.FillDirection.Vertical,
    VerticalAlignment = Enum.VerticalAlignment.Top,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 8),
})

function Library:Notification(data)
    local name = data.Name or data.name or "Notification"
    local desc = data.Description or data.description or ""
    local duration = data.Duration or data.duration or 5
    local icon = data.Icon or data.icon or ""
    local iconColor = data.IconColor or data.iconcolor or Theme.Accent

    local notif = {}
    
    local Frame = Create("Frame", {
        Name = "Notification",
        Parent = NotificationHolder,
        BackgroundColor3 = Theme.BackgroundDark,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true,
    })
    
    local UICorner = Create("UICorner", {
        Parent = Frame,
        CornerRadius = UDim.new(0, 8),
    })
    
    local UIStroke = Create("UIStroke", {
        Parent = Frame,
        Color = Theme.Outline,
        Transparency = 1,
        Thickness = 1,
    })
    
    local AccentLine = Create("Frame", {
        Name = "Accent",
        Parent = Frame,
        BackgroundColor3 = iconColor,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 3, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
    })
    
    local Content = Create("Frame", {
        Name = "Content",
        Parent = Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
    })
    
    local Title = Create("TextLabel", {
        Name = "Title",
        Parent = Content,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 8),
        Font = Enum.Font.GothamBold,
        Text = name,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1,
    })
    
    local Description = Create("TextLabel", {
        Name = "Desc",
        Parent = Content,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 0, 28),
        Font = Enum.Font.Gotham,
        Text = desc,
        TextColor3 = Theme.TextDim,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1,
    })
    
    local ProgressBar = Create("Frame", {
        Name = "Progress",
        Parent = Frame,
        BackgroundColor3 = iconColor,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
    })
    
    local ProgressCorner = Create("UICorner", {
        Parent = ProgressBar,
        CornerRadius = UDim.new(0, 1),
    })
    
    -- Animate in
    local targetHeight = desc ~= "" and 58 or 42
    Frame.Size = UDim2.new(1, 0, 0, 0)
    
    Tween(Frame, 0.3, {Size = UDim2.new(1, 0, 0, targetHeight), BackgroundTransparency = 0})
    Tween(UIStroke, 0.3, {Transparency = 0})
    Tween(AccentLine, 0.3, {BackgroundTransparency = 0})
    Tween(Title, 0.3, {TextTransparency = 0})
    Tween(Description, 0.3, {TextTransparency = 0})
    Tween(ProgressBar, 0.3, {BackgroundTransparency = 0.3})
    
    -- Progress animation
    task.spawn(function()
        local elapsed = 0
        while elapsed < duration do
            local dt = RunService.RenderStepped:Wait()
            elapsed = elapsed + dt
            local progress = 1 - (elapsed / duration)
            ProgressBar.Size = UDim2.new(progress, 0, 0, 2)
        end
    end)
    
    -- Auto dismiss
    task.delay(duration, function()
        Tween(Frame, 0.25, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1})
        Tween(UIStroke, 0.25, {Transparency = 1})
        Tween(AccentLine, 0.25, {BackgroundTransparency = 1})
        Tween(Title, 0.25, {TextTransparency = 1})
        Tween(Description, 0.25, {TextTransparency = 1})
        Tween(ProgressBar, 0.25, {BackgroundTransparency = 1})
        
        task.wait(0.3)
        Frame:Destroy()
    end)
    
    return notif
end

-- Watermark
function Library:Watermark(text, logo)
    if Library.WatermarkObj then
        Library.WatermarkObj:Destroy()
    end
    
    local Frame = Create("Frame", {
        Name = "Watermark",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.BackgroundDark,
        Position = UDim2.new(0, 15, 0, 15),
        Size = UDim2.new(0, 0, 0, 28),
        ClipsDescendants = true,
    })
    
    local UICorner = Create("UICorner", {
        Parent = Frame,
        CornerRadius = UDim.new(0, 6),
    })
    
    local UIStroke = Create("UIStroke", {
        Parent = Frame,
        Color = Theme.Outline,
        Thickness = 1,
    })
    
    local AccentBar = Create("Frame", {
        Parent = Frame,
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(0, 3, 1, 0),
    })
    
    local Label = Create("TextLabel", {
        Parent = Frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -16, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = text or "Rufus",
        TextColor3 = Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
    Library.WatermarkObj = Frame
    
    -- Size to fit
    local textBounds = Label.TextBounds
    Frame.Size = UDim2.new(0, textBounds.X + 24, 0, 28)
    
    return Frame
end

-- Keybinds List
function Library:KeybindsList()
    if Library.KeybindsListObj then
        Library.KeybindsListObj:Destroy()
    end
    
    local Frame = Create("Frame", {
        Name = "KeybindsList",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.BackgroundDark,
        Position = UDim2.new(1, -220, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 200, 0, 30),
        ClipsDescendants = true,
    })
    
    local UICorner = Create("UICorner", {
        Parent = Frame,
        CornerRadius = UDim.new(0, 6),
    })
    
    local UIStroke = Create("UIStroke", {
        Parent = Frame,
        Color = Theme.Outline,
        Thickness = 1,
    })
    
    local Header = Create("Frame", {
        Parent = Frame,
        BackgroundColor3 = Theme.Background,
        Size = UDim2.new(1, 0, 0, 28),
    })
    
    local HeaderCorner = Create("UICorner", {
        Parent = Header,
        CornerRadius = UDim.new(0, 6),
    })
    
    local HeaderFix = Create("Frame", {
        Parent = Header,
        BackgroundColor3 = Theme.Background,
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.new(0, 0, 1, -8),
    })
    
    local Title = Create("TextLabel", {
        Parent = Header,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        Font = Enum.Font.GothamBold,
        Text = "Keybinds",
        TextColor3 = Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
    local AccentLine = Create("Frame", {
        Parent = Header,
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(0, 3, 0.6, 0),
        Position = UDim2.new(0, 0, 0.2, 0),
    })
    
    local Content = Create("Frame", {
        Parent = Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 1, -32),
        Position = UDim2.new(0, 8, 0, 32),
    })
    
    local Layout = Create("UIListLayout", {
        Parent = Content,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
    })
    
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Frame.Size = UDim2.new(0, 200, 0, 30 + Layout.AbsoluteContentSize.Y + 8)
    end)
    
    Library.KeybindsListObj = Frame
    Library.KeybindsListContent = Content
    
    return Frame
end

-- Window
function Library:Window(data)
    local window = {}
    local name = data.Name or data.name or "Rufus"
    local version = data.Version or data.version or "1.0.0"
    local logo = data.Logo or data.logo or ""
    local size = data.Size or data.size or UDim2.new(0, 620, 0, 440)
    Library.FadeSpeed = data.FadeSpeed or data.fadespeed or 0.35
    
    -- Main frame
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Background,
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        ClipsDescendants = true,
    })
    
    local MainCorner = Create("UICorner", {
        Parent = MainFrame,
        CornerRadius = UDim.new(0, 10),
    })
    
    local MainStroke = Create("UIStroke", {
        Parent = MainFrame,
        Color = Theme.Outline,
        Thickness = 1,
    })
    
    -- Title bar
    local TitleBar = Create("Frame", {
        Name = "TitleBar",
        Parent = MainFrame,
        BackgroundColor3 = Theme.BackgroundDark,
        Size = UDim2.new(1, 0, 0, 36),
    })
    
    local TitleCorner = Create("UICorner", {
        Parent = TitleBar,
        CornerRadius = UDim.new(0, 10),
    })
    
    local TitleFix = Create("Frame", {
        Parent = TitleBar,
        BackgroundColor3 = Theme.BackgroundDark,
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
    })
    
    -- Logo
    if logo ~= "" then
        local Logo = Create("ImageLabel", {
            Parent = TitleBar,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 12, 0.5, -10),
            Image = logo,
            ScaleType = Enum.ScaleType.Fit,
        })
    end
    
    local TitleText = Create("TextLabel", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, logo ~= "" and 38 or 14, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = name,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
    local VersionText = Create("TextLabel", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, logo ~= "" and 38 or 14, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "v" .. version,
        TextColor3 = Theme.TextDimmer,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        AnchorPoint = Vector2.new(0, 0),
        Position = UDim2.new(0, (logo ~= "" and 38 or 14) + TitleText.TextBounds.X + 6, 0, 4),
    })
    
    -- Close button
    local CloseBtn = Create("TextButton", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(1, -36, 0, 0),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = Theme.TextDim,
        TextSize = 18,
        AutoButtonColor = false,
    })
    
    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, 0.15, {TextColor3 = Theme.Danger})
    end)
    
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, 0.15, {TextColor3 = Theme.TextDim})
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        Library:Unload()
    end)
    
    -- Minimize button
    local MinBtn = Create("TextButton", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(1, -72, 0, 0),
        Font = Enum.Font.GothamBold,
        Text = "—",
        TextColor3 = Theme.TextDim,
        TextSize = 14,
        AutoButtonColor = false,
    })
    
    MinBtn.MouseEnter:Connect(function()
        Tween(MinBtn, 0.15, {TextColor3 = Theme.Text})
    end)
    
    MinBtn.MouseLeave:Connect(function()
        Tween(MinBtn, 0.15, {TextColor3 = Theme.TextDim})
    end)
    
    MinBtn.MouseButton1Click:Connect(function()
        Library.Toggled = not Library.Toggled
        if Library.Toggled then
            Tween(MainFrame, Library.FadeSpeed, {Size = size})
        else
            Tween(MainFrame, Library.FadeSpeed, {Size = UDim2.new(size.X.Scale, size.X.Offset, 0, 36)})
        end
    end)
    
    -- Dragging
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
    
    -- Sidebar
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Sidebar,
        Size = UDim2.new(0, 160, 1, -36),
        Position = UDim2.new(0, 0, 0, 36),
    })
    
    local SidebarCorner = Create("UICorner", {
        Parent = Sidebar,
        CornerRadius = UDim.new(0, 10),
    })
    
    local SidebarFix = Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = Theme.Sidebar,
        Size = UDim2.new(0, 10, 1, 0),
        Position = UDim2.new(1, -10, 0, 0),
    })
    
    local SidebarFix2 = Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = Theme.Sidebar,
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 0, 0),
    })
    
    local TabHolder = Create("Frame", {
        Name = "TabHolder",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 1, -16),
        Position = UDim2.new(0, 8, 0, 8),
    })
    
    local TabLayout = Create("UIListLayout", {
        Parent = TabHolder,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
    })
    
    -- Content area
    local Content = Create("Frame", {
        Name = "Content",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -168, 1, -44),
        Position = UDim2.new(0, 168, 0, 36),
    })
    
    local PageHolder = Create("Frame", {
        Name = "PageHolder",
        Parent = Content,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
    })
    
    -- Accent line under title bar
    local AccentLine = Create("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 36),
    })
    
    Library.Window = {
        MainFrame = MainFrame,
        TitleBar = TitleBar,
        Sidebar = Sidebar,
        TabHolder = TabHolder,
        Content = PageHolder,
    }
    
    -- Page function
    function window:Page(data)
        local page = {}
        local pageName = data.Name or data.name or "Page"
        local icon = data.Icon or data.icon or ""
        local columns = data.Columns or data.columns or 2
        local hasSubPages = data.SubPages or data.subpages or false
        
        -- Tab button
        local Tab = Create("TextButton", {
            Name = pageName,
            Parent = TabHolder,
            BackgroundColor3 = Theme.Sidebar,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 32),
            Font = Enum.Font.GothamSemibold,
            Text = "",
            AutoButtonColor = false,
        })
        
        local TabCorner = Create("UICorner", {
            Parent = Tab,
            CornerRadius = UDim.new(0, 6),
        })
        
        local TabIndicator = Create("Frame", {
            Parent = Tab,
            BackgroundColor3 = Theme.Accent,
            Size = UDim2.new(0, 3, 0, 0),
            Position = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
        })
        
        local TabIndicatorCorner = Create("UICorner", {
            Parent = TabIndicator,
            CornerRadius = UDim.new(0, 2),
        })
        
        local TabText = Create("TextLabel", {
            Parent = Tab,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -24, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            Font = Enum.Font.GothamSemibold,
            Text = pageName,
            TextColor3 = Theme.TextDim,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        
        -- Page content
        local PageFrame = Create("Frame", {
            Name = pageName,
            Parent = PageHolder,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
        })
        
        -- SubPage tabs if needed
        local SubPageHolder = nil
        local SubPageContent = nil
        local subPages = {}
        local currentSubPage = nil
        
        if hasSubPages then
            local SubTabBar = Create("Frame", {
                Parent = PageFrame,
                BackgroundColor3 = Theme.BackgroundLight,
                Size = UDim2.new(1, 0, 0, 30),
            })
            
            local SubTabCorner = Create("UICorner", {
                Parent = SubTabBar,
                CornerRadius = UDim.new(0, 6),
            })
            
            local SubTabLayout = Create("UIListLayout", {
                Parent = SubTabBar,
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 2),
            })
            
            SubTabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            
            local SubTabPadding = Create("UIPadding", {
                Parent = SubTabBar,
                PaddingLeft = UDim.new(0, 6),
            })
            
            SubPageHolder = SubTabBar
            
            SubPageContent = Create("Frame", {
                Parent = PageFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, -34),
                Position = UDim2.new(0, 0, 0, 34),
            })
        end
        
        -- Columns
        local columnFrames = {}
        local mainContentParent = hasSubPages and SubPageContent or PageFrame
        
        local function CreateColumns(parent)
            local cols = {}
            local colWidth = (1 / columns)
            
            for i = 1, columns do
                local col = Create("ScrollingFrame", {
                    Name = "Column" .. i,
                    Parent = parent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(colWidth, -4 - (i > 1 and 4 or 0), 1, 0),
                    Position = UDim2.new(colWidth * (i - 1), (i > 1 and 4 or 0), 0, 0),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                })
                
                local padding = Create("UIPadding", {
                    Parent = col,
                    PaddingTop = UDim.new(0, 4),
                    PaddingBottom = UDim.new(0, 4),
                    PaddingLeft = UDim.new(0, 4),
                    PaddingRight = UDim.new(0, 4),
                })
                
                local layout = Create("UIListLayout", {
                    Parent = col,
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 6),
                })
                
                layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    col.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
                end)
                
                cols[i] = col
            end
            
            return cols
        end
        
        columnFrames = CreateColumns(mainContentParent)
        
        -- Tab selection
        local function SelectTab()
            for _, child in pairs(TabHolder:GetChildren()) do
                if child:IsA("TextButton") and child ~= Tab then
                    Tween(child:FindFirstChild("TextLabel") or child, 0.2, {TextColor3 = Theme.TextDim})
                    local ind = child:FindFirstChild("Frame")
                    if ind then
                        Tween(ind, 0.2, {Size = UDim2.new(0, 3, 0, 0)})
                    end
                    for _, pg in pairs(PageHolder:GetChildren()) do
                        if pg:IsA("Frame") and pg ~= PageFrame then
                            pg.Visible = false
                        end
                    end
                end
            end
            
            Tween(TabText, 0.2, {TextColor3 = Theme.Text})
            Tween(TabIndicator, 0.2, {Size = UDim2.new(0, 3, 0.6, 0)})
            PageFrame.Visible = true
            Library.CurrentPage = pageName
        end
        
        Tab.MouseButton1Click:Connect(SelectTab)
        
        Tab.MouseEnter:Connect(function()
            if Library.CurrentPage ~= pageName then
                Tween(Tab, 0.15, {BackgroundTransparency = 0.7, BackgroundColor3 = Theme.Hover})
            end
        end)
        
        Tab.MouseLeave:Connect(function()
            if Library.CurrentPage ~= pageName then
                Tween(Tab, 0.15, {BackgroundTransparency = 1})
            end
        end)
        
        -- Auto select first tab
        if not Library.CurrentPage then
            SelectTab()
        end
        
        -- Section function
        local function CreateSectionFunc(contentParent, cols)
            return function(self, data)
                local section = {}
                local sectionName = data.Name or data.name or "Section"
                local side = data.Side or data.side or 1
                
                side = Clamp(side, 1, columns)
                local parent = cols[side]
                
                local SectionFrame = Create("Frame", {
                    Name = sectionName,
                    Parent = parent,
                    BackgroundColor3 = Theme.Section,
                    Size = UDim2.new(1, 0, 0, 30),
                    ClipsDescendants = true,
                })
                
                local SectionCorner = Create("UICorner", {
                    Parent = SectionFrame,
                    CornerRadius = UDim.new(0, 8),
                })
                
                local SectionStroke = Create("UIStroke", {
                    Parent = SectionFrame,
                    Color = Theme.SectionBorder,
                    Thickness = 1,
                })
                
                local SectionTitle = Create("TextLabel", {
                    Parent = SectionFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -20, 0, 28),
                    Position = UDim2.new(0, 10, 0, 0),
                    Font = Enum.Font.GothamBold,
                    Text = sectionName,
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                
                local SectionContent = Create("Frame", {
                    Parent = SectionFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -16, 1, -32),
                    Position = UDim2.new(0, 8, 0, 30),
                })
                
                local SectionLayout = Create("UIListLayout", {
                    Parent = SectionContent,
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 5),
                })
                
                SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    SectionFrame.Size = UDim2.new(1, 0, 0, 32 + SectionLayout.AbsoluteContentSize.Y + 8)
                })
                
                -- Toggle
                function section:Toggle(data)
                    local toggle = {}
                    local tName = data.Name or data.name or "Toggle"
                    local default = data.Default or data.default or false
                    local flag = data.Flag or data.flag or tName
                    local callback = data.Callback or data.callback or function() end
                    
                    local enabled = default
                    
                    local ToggleFrame = Create("Frame", {
                        Name = tName,
                        Parent = SectionContent,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 22),
                    })
                    
                    local ToggleLabel = Create("TextLabel", {
                        Parent = ToggleFrame,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, -44, 1, 0),
                        Position = UDim2.new(0, 4, 0, 0),
                        Font = Enum.Font.Gotham,
                        Text = tName,
                        TextColor3 = Theme.Text,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })
                    
                    local ToggleBox = Create("Frame", {
                        Parent = ToggleFrame,
                        BackgroundColor3 = Theme.ToggleOff,
                        Size = UDim2.new(0, 32, 0, 16),
                        Position = UDim2.new(1, -36, 0.5, -8),
                    })
                    
                    local ToggleCorner = Create("UICorner", {
                        Parent = ToggleBox,
                        CornerRadius = UDim.new(1, 0),
                    })
                    
                    local ToggleCircle = Create("Frame", {
                        Parent = ToggleBox,
                        BackgroundColor3 = Theme.TextDim,
                        Size = UDim2.new(0, 12, 0, 12),
                        Position = UDim2.new(0, 2, 0.5, -6),
                    })
                    
                    local CircleCorner = Create("UICorner", {
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
                            Tween(ToggleBox, 0.2, {BackgroundColor3 = Theme.Accent})
                            Tween(ToggleCircle, 0.2, {Position = UDim2.new(1, -14, 0.5, -6), BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
                        else
                            Tween(ToggleBox, 0.2, {BackgroundColor3 = Theme.ToggleOff})
                            Tween(ToggleCircle, 0.2, {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Theme.TextDim})
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
                    
                    -- Keybind sub-element
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
                            Size = UDim2.new(0, 60, 0, 16),
                            Position = UDim2.new(1, -100, 0.5, -8),
                        })
                        
                        local KeybindBtn = Create("TextButton", {
                            Parent = KeybindFrame,
                            BackgroundColor3 = Theme.InputBg,
                            Size = UDim2.new(1, 0, 1, 0),
                            Font = Enum.Font.Gotham,
                            Text = currentKey ~= Enum.KeyCode.Unknown and currentKey.Name or "None",
                            TextColor3 = Theme.TextDim,
                            TextSize = 10,
                            AutoButtonColor = false,
                        })
                        
                        local KeybindCorner = Create("UICorner", {
                            Parent = KeybindBtn,
                            CornerRadius = UDim.new(0, 4),
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
                    
                    -- Colorpicker sub-element
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
                            Size = UDim2.new(0, 18, 0, 14),
                            Position = UDim2.new(1, -22, 0.5, -7),
                            AutoButtonColor = false,
                            Text = "",
                        })
                        
                        local ColorCorner = Create("UICorner", {
                            Parent = ColorBtn,
                            CornerRadius = UDim.new(0, 3),
                        })
                        
                        local ColorStroke = Create("UIStroke", {
                            Parent = ColorBtn,
                            Color = Theme.Outline,
                            Thickness = 1,
                        })
                        
                        local PickerFrame = Create("Frame", {
                            Parent = SectionContent,
                            BackgroundColor3 = Theme.BackgroundDark,
                            Size = UDim2.new(1, 0, 0, 0),
                            Visible = false,
                            ClipsDescendants = true,
                        })
                        
                        local PickerCorner = Create("UICorner", {
                            Parent = PickerFrame,
                            CornerRadius = UDim.new(0, 6),
                        })
                        
                        local PickerStroke = Create("UIStroke", {
                            Parent = PickerFrame,
                            Color = Theme.Outline,
                            Thickness = 1,
                        })
                        
                        -- SV picker
                        local SVPicker = Create("ImageLabel", {
                            Parent = PickerFrame,
                            BackgroundColor3 = currentColor,
                            Size = UDim2.new(1, -16, 0, 120),
                            Position = UDim2.new(0, 8, 0, 8),
                            Image = "rbxassetid://4155801252",
                        })
                        
                        local SVC = Create("UICorner", {
                            Parent = SVPicker,
                            CornerRadius = UDim.new(0, 4),
                        })
                        
                        local SVPointer = Create("Frame", {
                            Parent = SVPicker,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            Size = UDim2.new(0, 8, 0, 8),
                            AnchorPoint = Vector2.new(0.5, 0.5),
                        })
                        
                        local SVPC = Create("UICorner", {
                            Parent = SVPointer,
                            CornerRadius = UDim.new(1, 0),
                        })
                        
                        local SVStroke = Create("UIStroke", {
                            Parent = SVPointer,
                            Color = Color3.fromRGB(0, 0, 0),
                            Thickness = 1,
                        })
                        
                        -- Hue slider
                        local HueBar = Create("Frame", {
                            Parent = PickerFrame,
                            Size = UDim2.new(1, -16, 0, 14),
                            Position = UDim2.new(0, 8, 0, 134),
                        })
                        
                        local HueGrad = Create("UIGradient", {
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
                        
                        local HueC = Create("UICorner", {
                            Parent = HueBar,
                            CornerRadius = UDim.new(0, 4),
                        })
                        
                        local HuePointer = Create("Frame", {
                            Parent = HueBar,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            Size = UDim2.new(0, 4, 1, 2),
                            Position = UDim2.new(0, 0, 0, -1),
                        })
                        
                        local HuePC = Create("UICorner", {
                            Parent = HuePointer,
                            CornerRadius = UDim.new(0, 2),
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
                            HuePointer.Position = UDim2.new(h, 0, 0, -1)
                            
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
                                Tween(PickerFrame, 0.2, {Size = UDim2.new(1, 0, 0, 160)})
                            else
                                Tween(PickerFrame, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
                                task.delay(0.2, function()
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
                
                -- Slider
                function section:Slider(data)
                    local slider = {}
                    local sName = data.Name or data.name or "Slider"
                    local min = data.Min or data.min or 0
                    local max = data.Max or data.max or 100
                    local default = data.Default or data.default or min
                    local decimals = data.Decimals or data.decimals or 0
                    local flag = data.Flag or data.flag or sName
                    local suffix = data.Suffix or data.suffix or ""
                    local callback = data.Callback or data.callback or function() end
                    
                    local value = default
                    
                    local SliderFrame = Create("Frame", {
                        Name = sName,
                        Parent = SectionContent,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 36),
                    })
                    
                    local SliderLabel = Create("TextLabel", {
                        Parent = SliderFrame,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, -60, 0, 16),
                        Font = Enum.Font.Gotham,
                        Text = sName,
                        TextColor3 = Theme.Text,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })
                    
                    local SliderValue = Create("TextLabel", {
                        Parent = SliderFrame,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 56, 0, 16),
                        Position = UDim2.new(1, -56, 0, 0),
                        Font = Enum.Font.GothamSemibold,
                        Text = Round(value, decimals) .. suffix,
                        TextColor3 = Theme.Accent,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Right,
                    })
                    
                    local SliderBg = Create("Frame", {
                        Parent = SliderFrame,
                        BackgroundColor3 = Theme.SliderBg,
                        Size = UDim2.new(1, 0, 0, 6),
                        Position = UDim2.new(0, 0, 0, 22),
                    })
                    
                    local SliderBgCorner = Create("UICorner", {
                        Parent = SliderBg,
                        CornerRadius = UDim.new(1, 0),
                    })
                    
                    local SliderFill = Create("Frame", {
                        Parent = SliderBg,
                        BackgroundColor3 = Theme.Accent,
                        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                    })
                    
                    local SliderFillCorner = Create("UICorner", {
                        Parent = SliderFill,
                        CornerRadius = UDim.new(1, 0),
                    })
                    
                    local SliderCircle = Create("Frame", {
                        Parent = SliderBg,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Size = UDim2.new(0, 12, 0, 12),
                        Position = UDim2.new((value - min) / (max - min), -6, 0.5, -6),
                    })
                    
                    local SliderCircleCorner = Create("UICorner", {
                        Parent = SliderCircle,
                        CornerRadius = UDim.new(1, 0),
                    })
                    
                    local dragging = false
                    
                    local function SetValue(val)
                        value = Clamp(Round(val, decimals), min, max)
                        local percent = (value - min) / (max - min)
                        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                        SliderCircle.Position = UDim2.new(percent, -6, 0.5, -6)
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
                
                -- Dropdown
                function section:Dropdown(data)
                    local dropdown = {}
                    local dName = data.Name or data.name or "Dropdown"
                    local items = data.Items or data.items or {}
                    local default = data.Default or data.default or (items[1] and items[1] or "")
                    local maxSize = data.MaxSize or data.maxsize or 5
                    local flag = data.Flag or data.flag or dName
                    local multi = data.Multi or data.multi or false
                    local callback = data.Callback or data.callback or function() end
                    
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
                        Size = UDim2.new(1, 0, 0, 40),
                    })
                    
                    local DropdownLabel = Create("TextLabel", {
                        Parent = DropdownFrame,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 16),
                        Font = Enum.Font.Gotham,
                        Text = dName,
                        TextColor3 = Theme.Text,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })
                    
                    local DropdownBtn = Create("TextButton", {
                        Parent = DropdownFrame,
                        BackgroundColor3 = Theme.InputBg,
                        Size = UDim2.new(1, 0, 0, 20),
                        Position = UDim2.new(0, 0, 0, 20),
                        Font = Enum.Font.Gotham,
                        Text = "",
                        AutoButtonColor = false,
                    })
                    
                    local DropdownBtnCorner = Create("UICorner", {
                        Parent = DropdownBtn,
                        CornerRadius = UDim.new(0, 4),
                    })
                    
                    local DropdownBtnStroke = Create("UIStroke", {
                        Parent = DropdownBtn,
                        Color = Theme.Outline,
                        Thickness = 1,
                    })
                    
                    local SelectedText = Create("TextLabel", {
                        Parent = DropdownBtn,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, -24, 1, 0),
                        Position = UDim2.new(0, 8, 0, 0),
                        Font = Enum.Font.Gotham,
                        Text = multi and (#selected > 0 and table.concat(selected, ", ") or "None") or (selected or "None"),
                        TextColor3 = Theme.TextDim,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                    })
                    
                    local Arrow = Create("TextLabel", {
                        Parent = DropdownBtn,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 20, 1, 0),
                        Position = UDim2.new(1, -20, 0, 0),
                        Font = Enum.Font.GothamBold,
                        Text = "▾",
                        TextColor3 = Theme.TextDim,
                        TextSize = 10,
                    })
                    
                    local ListFrame = Create("ScrollingFrame", {
                        Parent = SectionContent,
                        BackgroundColor3 = Theme.DropdownBg,
                        Size = UDim2.new(1, 0, 0, 0),
                        Visible = false,
                        CanvasSize = UDim2.new(0, 0, 0, 0),
                        ScrollBarThickness = 2,
                        ScrollBarImageColor3 = Theme.Accent,
                        ClipsDescendants = true,
                        BorderSizePixel = 0,
                    })
                    
                    local ListCorner = Create("UICorner", {
                        Parent = ListFrame,
                        CornerRadius = UDim.new(0, 4),
                    })
                    
                    local ListStroke = Create("UIStroke", {
                        Parent = ListFrame,
                        Color = Theme.Outline,
                        Thickness = 1,
                    })
                    
                    local ListLayout = Create("UIListLayout", {
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
                                BackgroundTransparency = isSelected and 0.5 or 1,
                                Size = UDim2.new(1, 0, 0, 22),
                                Font = Enum.Font.Gotham,
                                Text = "  " .. item,
                                TextColor3 = isSelected and Theme.Accent or Theme.TextDim,
                                TextSize = 11,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                AutoButtonColor = false,
                            })
                            
                            ItemBtn.MouseEnter:Connect(function()
                                Tween(ItemBtn, 0.1, {BackgroundTransparency = 0.5, BackgroundColor3 = Theme.Hover})
                            end)
                            
                            ItemBtn.MouseLeave:Connect(function()
                                local sel = multi and table.find(selected, item) or selected == item
                                if not sel then
                                    Tween(ItemBtn, 0.1, {BackgroundTransparency = 1, BackgroundColor3 = Theme.DropdownBg})
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
                                    Tween(ListFrame, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
                                    task.delay(0.2, function()
                                        ListFrame.Visible = false
                                    end)
                                    Tween(Arrow, 0.2, {Rotation = 0})
                                end
                                UpdateText()
                                BuildList()
                            end)
                        end
                        
                        local itemCount = math.min(#items, maxSize)
                        ListFrame.CanvasSize = UDim2.new(0, 0, 0, itemCount * 22)
                    end
                    
                    BuildList()
                    
                    DropdownBtn.MouseButton1Click:Connect(function()
                        open = not open
                        ListFrame.Visible = open
                        if open then
                            local itemCount = math.min(#items, maxSize)
                            Tween(ListFrame, 0.2, {Size = UDim2.new(1, 0, 0, itemCount * 22)})
                            Tween(Arrow, 0.2, {Rotation = 180})
                        else
                            Tween(ListFrame, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
                            Tween(Arrow, 0.2, {Rotation = 0})
                            task.delay(0.2, function()
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
                
                -- Button
                function section:Button(data)
                    local button = {}
                    local bName = data.Name or data.name or "Button"
                    local callback = data.Callback or data.callback or function() end
                    
                    local ButtonFrame = Create("Frame", {
                        Name = bName,
                        Parent = SectionContent,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 24),
                    })
                    
                    local Button = Create("TextButton", {
                        Parent = ButtonFrame,
                        BackgroundColor3 = Theme.Accent,
                        Size = UDim2.new(1, 0, 1, 0),
                        Font = Enum.Font.GothamSemibold,
                        Text = bName,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = 12,
                        AutoButtonColor = false,
                    })
                    
                    local ButtonCorner = Create("UICorner", {
                        Parent = Button,
                        CornerRadius = UDim.new(0, 5),
                    })
                    
                    Button.MouseEnter:Connect(function()
                        Tween(Button, 0.15, {BackgroundColor3 = Theme.AccentDark})
                    end)
                    
                    Button.MouseLeave:Connect(function()
                        Tween(Button, 0.15, {BackgroundColor3 = Theme.Accent})
                    end)
                    
                    Button.MouseButton1Down:Connect(function()
                        Tween(Button, 0.08, {Size = UDim2.new(0.97, 0, 0.9, 0), Position = UDim2.new(0.015, 0, 0.05, 0)})
                    end)
                    
                    Button.MouseButton1Up:Connect(function()
                        Tween(Button, 0.08, {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0)})
                    end)
                    
                    Button.MouseButton1Click:Connect(function()
                        task.spawn(callback)
                    end)
                    
                    function button:Fire()
                        task.spawn(callback)
                    end
                    
                    return button
                end
                
                -- Textbox
                function section:Textbox(data)
                    local textbox = {}
                    local tbName = data.Name or data.name or "Textbox"
                    local default = data.Default or data.default or ""
                    local placeholder = data.Placeholder or data.placeholder or ""
                    local flag = data.Flag or data.flag or tbName
                    local callback = data.Callback or data.callback or function() end
                    
                    local TBFrame = Create("Frame", {
                        Name = tbName,
                        Parent = SectionContent,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 40),
                    })
                    
                    local TBLabel = Create("TextLabel", {
                        Parent = TBFrame,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 16),
                        Font = Enum.Font.Gotham,
                        Text = tbName,
                        TextColor3 = Theme.Text,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })
                    
                    local InputBox = Create("TextBox", {
                        Parent = TBFrame,
                        BackgroundColor3 = Theme.InputBg,
                        Size = UDim2.new(1, 0, 0, 20),
                        Position = UDim2.new(0, 0, 0, 20),
                        Font = Enum.Font.Gotham,
                        Text = default,
                        PlaceholderText = placeholder,
                        PlaceholderColor3 = Theme.TextDimmer,
                        TextColor3 = Theme.Text,
                        TextSize = 11,
                        ClearTextOnFocus = false,
                    })
                    
                    local InputCorner = Create("UICorner", {
                        Parent = InputBox,
                        CornerRadius = UDim.new(0, 4),
                    })
                    
                    local InputStroke = Create("UIStroke", {
                        Parent = InputBox,
                        Color = Theme.Outline,
                        Thickness = 1,
                    })
                    
                    local InputPadding = Create("UIPadding", {
                        Parent = InputBox,
                        PaddingLeft = UDim.new(0, 8),
                        PaddingRight = UDim.new(0, 8),
                    })
                    
                    InputBox.Focused:Connect(function()
                        Tween(InputStroke, 0.2, {Color = Theme.Accent})
                    end)
                    
                    InputBox.FocusLost:Connect(function(enterPressed)
                        Tween(InputStroke, 0.2, {Color = Theme.Outline})
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
                
                -- Label
                function section:Label(text, alignment)
                    local label = {}
                    
                    local LabelFrame = Create("Frame", {
                        Parent = SectionContent,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 16),
                    })
                    
                    local LabelText = Create("TextLabel", {
                        Parent = LabelFrame,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Font = Enum.Font.Gotham,
                        Text = text or "Label",
                        TextColor3 = Theme.TextDim,
                        TextSize = 12,
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
                            Size = UDim2.new(0, 60, 0, 16),
                            Position = UDim2.new(1, -60, 0, 0),
                            Font = Enum.Font.Gotham,
                            Text = currentKey ~= Enum.KeyCode.Unknown and currentKey.Name or "None",
                            TextColor3 = Theme.TextDim,
                            TextSize = 10,
                            AutoButtonColor = false,
                        })
                        
                        local KeybindCorner = Create("UICorner", {
                            Parent = KeybindBtn,
                            CornerRadius = UDim.new(0, 4),
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
                            Size = UDim2.new(0, 18, 0, 14),
                            Position = UDim2.new(1, -18, 0.5, -7),
                            AutoButtonColor = false,
                            Text = "",
                        })
                        
                        local ColorCorner = Create("UICorner", {
                            Parent = ColorBtn,
                            CornerRadius = UDim.new(0, 3),
                        })
                        
                        local ColorStroke = Create("UIStroke", {
                            Parent = ColorBtn,
                            Color = Theme.Outline,
                            Thickness = 1,
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
        end
        
        local sectionFunc = CreateSectionFunc(mainContentParent, columnFrames)
        
        function page:Section(data)
            return sectionFunc(page, data)
        end
        
        -- SubPage
        function page:SubPage(data)
            local subPage = {}
            local spName = data.Name or data.name or "SubPage"
            local spIcon = data.Icon or data.icon or ""
            local spColumns = data.Columns or data.columns or 2
            
            local SubTabBtn = Create("TextButton", {
                Parent = SubPageHolder,
                BackgroundColor3 = Theme.BackgroundLight,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 80, 0, 24),
                Font = Enum.Font.GothamSemibold,
                Text = spName,
                TextColor3 = Theme.TextDim,
                TextSize = 11,
                AutoButtonColor = false,
            })
            
            local SubTabCorner = Create("UICorner", {
                Parent = SubTabBtn,
                CornerRadius = UDim.new(0, 4),
            })
            
            local SubPageFrame = Create("Frame", {
                Parent = SubPageContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Visible = false,
            })
            
            local spCols = CreateColumns(SubPageFrame)
            local spSectionFunc = CreateSectionFunc(SubPageFrame, spCols)
            
            local function SelectSubTab()
                for _, child in pairs(SubPageHolder:GetChildren()) do
                    if child:IsA("TextButton") and child ~= SubTabBtn then
                        Tween(child, 0.2, {TextColor3 = Theme.TextDim, BackgroundTransparency = 1})
                    end
                end
                for _, pg in pairs(SubPageContent:GetChildren()) do
                    if pg:IsA("Frame") and pg ~= SubPageFrame then
                        pg.Visible = false
                    end
                end
                Tween(SubTabBtn, 0.2, {TextColor3 = Theme.Text, BackgroundTransparency = 0.5, BackgroundColor3 = Theme.Hover})
                SubPageFrame.Visible = true
            end
            
            SubTabBtn.MouseButton1Click:Connect(SelectSubTab)
            
            if not currentSubPage then
                currentSubPage = spName
                SelectSubTab()
            end
            
            function subPage:Section(data)
                return spSectionFunc(subPage, data)
            end
            
            return subPage
        end
        
        table.insert(Library.Pages, page)
        return page
    end
    
    -- Toggle UI keybind (RightShift)
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
            Disconnect(conn)
        end
        Library.Connections = {}
        ScreenGui:Destroy()
        Library.Loaded = false
        getgenv().Library = nil
    end
    
    function Library:SetTheme(data)
        for key, value in pairs(data) do
            if Theme[key] then
                Theme[key] = value
            end
        end
    end
    
    function Library:GetConfig()
        return DeepCopy(Library.Flags)
    end
    
    function Library:LoadConfig(config)
        for flag, value in pairs(config) do
            Library.Flags[flag] = value
        end
    end
    
    return window
end

--[[
    EXAMPLE USAGE:
    
    local Library = loadstring(game:HttpGet("YOUR_URL_HERE"))()
    
    local Window = Library:Window({
        Name = "Rufus",
        Version = "2.0.0",
        Logo = "rbxassetid://123456789",
        Size = UDim2.new(0, 620, 0, 440),
    })
    
    Library:Watermark("Rufus | Premium", "")
    Library:KeybindsList()
    
    Library:Notification({
        Name = "Welcome",
        Description = "Library loaded successfully!",
        Duration = 5,
        IconColor = Color3.fromRGB(120, 90, 255),
    })
    
    -- Main tab
    local MainTab = Window:Page({
        Name = "Main",
        Icon = "",
        Columns = 2,
    })
    
    local LeftSection = MainTab:Section({
        Name = "Combat",
        Side = 1,
    })
    
    local Aimbot = LeftSection:Toggle({
        Name = "Aimbot",
        Default = false,
        Flag = "Aimbot",
        Callback = function(state)
            print("Aimbot:", state)
        end,
    })
    
    Aimbot:Keybind({
        Name = "Aimbot Key",
        Flag = "AimbotKey",
        Mode = "Hold",
        Default = Enum.KeyCode.MouseButton2,
    })
    
    Aimbot:Colorpicker({
        Name = "Aimbot Color",
        Default = Color3.fromRGB(255, 0, 0),
        Flag = "AimbotColor",
    })
    
    LeftSection:Slider({
        Name = "FOV",
        Min = 10,
        Max = 500,
        Default = 150,
        Decimals = 0,
        Flag = "FOV",
        Suffix = "°",
        Callback = function(value)
            print("FOV:", value)
        end,
    })
    
    LeftSection:Dropdown({
        Name = "Aim Part",
        Items = {"Head", "Torso", "Random"},
        Default = "Head",
        MaxSize = 5,
        Flag = "AimPart",
        Multi = false,
        Callback = function(selected)
            print("Aim Part:", selected)
        end,
    })
    
    local RightSection = MainTab:Section({
        Name = "Visuals",
        Side = 2,
    })
    
    RightSection:Toggle({
        Name = "ESP",
        Default = true,
        Flag = "ESP",
        Callback = function(state)
            print("ESP:", state)
        end,
    })
    
    RightSection:Button({
        Name = "Reload Config",
        Callback = function()
            print("Config reloaded!")
        end,
    })
    
    RightSection:Textbox({
        Name = "Config Name",
        Default = "default",
        Placeholder = "Enter config name...",
        Flag = "ConfigName",
        Callback = function(text)
            print("Config:", text)
        end,
    })
    
    RightSection:Label("Status: Active", "Left")
    
    -- Settings tab with subpages
    local SettingsTab = Window:Page({
        Name = "Settings",
        Icon = "",
        Columns = 2,
        SubPages = true,
    })
    
    local GeneralSub = SettingsTab:SubPage({
        Name = "General",
        Columns = 2,
    })
    
    local GeneralSection = GeneralSub:Section({
        Name = "General Settings",
        Side = 1,
    })
    
    GeneralSection:Toggle({
        Name = "Auto Save",
        Default = true,
        Flag = "AutoSave",
    })
    
    local UISub = SettingsTab:SubPage({
        Name = "UI",
        Columns = 2,
    })
    
    local UISection = UISub:Section({
        Name = "UI Settings",
        Side = 1,
    })
    
    UISection:Slider({
        Name = "UI Scale",
        Min = 0.5,
        Max = 2,
        Default = 1,
        Decimals = 1,
        Flag = "UIScale",
        Suffix = "x",
    })
    
    -- Toggle UI with RightShift
    -- Press RightShift to show/hide the UI
]]

return Library
