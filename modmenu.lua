-- DELAYED SL - South London 2 Script Panel
-- Modern dark UI with sidebar navigation and all features

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local lplr = Players.LocalPlayer

-- State variables
local flyEnabled = false
local walkSpeedEnabled = false
local infiniteStaminaEnabled = false
local currentWalkSpeed = 32
local currentTab = "ESP"

-- Connections
local flyConn, noclipConn, walkSpeedConn, staminaConn

-- Color Scheme
-- Color Scheme
local Theme = {
    Background = Color3.fromHex("#0F0F12"),
    Card = Color3.fromHex("#0F0F14"),
    CardHover = Color3.fromHex("#19191E"),
    Sidebar = Color3.fromHex("#121216"),
    ContentBg = Color3.fromHex("#191923"),

    Accent = Color3.fromHex("#00960C"),
    AccentDark = Color3.fromHex("#0EB31B"),

    Text = Color3.fromHex("#ffffff"),
    TextDim = Color3.fromHex("#d8d8e2"),
    Border = Color3.fromHex("#282832"),
    ToggleOff = Color3.fromHex("#2D2D37"),
    ToggleKnob = Color3.fromHex("#464650"),
}

-- Locations
local locations = {
    {name = "Journal bancaire", pos = Vector3.new(-176.02, -0.44, 167.79)},
    {name = "Blanchiment", pos = Vector3.new(-195.02, 5.96, 254.57)},
    {name = "Blanchisserie", pos = Vector3.new(217.16, 4.18, 367.85)},
    {name = "Armurerie de Londres", pos = Vector3.new(40.74, 4.18, 369.31)},
    {name = "Munitions et armes", pos = Vector3.new(40.32, 4.28, -656.36)},
    {name = "Périphérie de la ville", pos = Vector3.new(-565.38, 3.50954, -9.9876)},
    {name = "École", pos = Vector3.new(-337.95, 3.52999, 0.78420)},
    {name = "Près de l'école", pos = Vector3.new(-399.46, 3.52999, 7.68115)},
    {name = "Point d'apparition", pos = Vector3.new(-285.35, 3.23000, -293.59)},
    {name = "Commissariat", pos = Vector3.new(-265.12, 3.47210, -145.16)},
    {name = "Près du parking Fairbank", pos = Vector3.new(-27.689, 3.37999, -488.01)},
    {name = "Armurerie clandestine", pos = Vector3.new(80.4551, 3.22999, -669.13)},
    {name = "Station-service", pos = Vector3.new(256.612, 3.52599, -746.32)},
    {name = "Près du terrain de football", pos = Vector3.new(-418.06, 3.52160, -216.62)},
    {name = "Derrière le parking Fairbank", pos = Vector3.new(215.989, 3.23000, -531.05)},
    {name = "Bloc P", pos = Vector3.new(-373.40, 3.43209, -133.33)},
    {name = "Chantier naval de Croydon", pos = Vector3.new(421.010, 3.22950, 37.0479)},
    {name = "BoxedIce", pos = Vector3.new(295.283, 3.52999, -278.96)},
    {name = "Près de l'Idea Store", pos = Vector3.new(277.346, 3.53000, -96.585)},
    {name = "Derrière l'Idea Store", pos = Vector3.new(205.483, 3.57210, -95.507)},
    {name = "Quartier Trap", pos = Vector3.new(203.675, 3.74238, -14.353)},
    {name = "Quartier 060", pos = Vector3.new(65.9189, 3.63000, -111.94)},
    {name = "Cimetière", pos = Vector3.new(180.165, 3.52949, -178.92)},
    {name = "Près du cimetière", pos = Vector3.new(111.219, 3.52949, -275.74)},
    {name = "Appartements Suite", pos = Vector3.new(-20.374, 3.37999, -196.23)},
    {name = "Hôpital", pos = Vector3.new(-442.34, 3.47160, 90.3315)},
    {name = "Quartier résidentiel", pos = Vector3.new(-99.284, 3.53386, 741.348)},
    {name = "Parc national", pos = Vector3.new(-499.76, 3.52999, 309.022)},
    {name = "Marché noir", pos = Vector3.new(236.746, 3.71305, 420.840)},
    {name = "Atelier de tuning", pos = Vector3.new(160.724, 3.23000, 704.394)},
}

-- ============================================================================
-- CORE FUNCTIONS
-- ============================================================================

local flyspeed = 200
local maxdistance = 1000
local keys = {}

local function GetVelocity(pos1, pos2, StudsPerSecond)
    local distance = (pos2 - pos1)
    local mag = distance.Magnitude
    if mag == 0 then return Vector3.new() end
    return (distance / mag) * StudsPerSecond
end

local function getkey(keycode)
    local key = tostring(keycode):lower()
    local _, a = key:find("keycode.")
    return key:sub(a + 1)
end

local function disconnectFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
end

local function startFly()
    disconnectFly()
    flyConn = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not lplr.Character or not lplr.Character:FindFirstChild("HumanoidRootPart") then return end
            local hrp = lplr.Character.HumanoidRootPart
            local camera = Workspace.CurrentCamera
            
            local frontPos = (hrp.CFrame * CFrame.new(0, 0, -maxdistance)).Position
            local backPos = (hrp.CFrame * CFrame.new(0, 0, maxdistance)).Position
            local leftPos = (hrp.CFrame * CFrame.new(-maxdistance, 0, 0)).Position
            local rightPos = (hrp.CFrame * CFrame.new(maxdistance, 0, 0)).Position
            local upPos = hrp.Position + Vector3.new(0, maxdistance, 0)
            local downPos = hrp.Position - Vector3.new(0, maxdistance, 0)
            
            local velocity = Vector3.new(0, 0, 0)
            
            if flyEnabled then
                if keys.w_active then velocity += GetVelocity(hrp.Position, frontPos, flyspeed) end
                if keys.s_active then velocity += GetVelocity(hrp.Position, backPos, flyspeed) end
                if keys.a_active then velocity += GetVelocity(hrp.Position, leftPos, flyspeed) end
                if keys.d_active then velocity += GetVelocity(hrp.Position, rightPos, flyspeed) end
                if keys.e_active then velocity += GetVelocity(hrp.Position, upPos, flyspeed) end
                if keys.q_active then velocity += GetVelocity(hrp.Position, downPos, flyspeed) end
                
                hrp.Velocity = velocity
                hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + camera.CFrame.LookVector)
                
                local moving = keys.w_active or keys.s_active or keys.a_active or keys.d_active or keys.q_active or keys.e_active
                hrp.Anchored = not moving
            end
        end)
    end)
end

local function disconnectNoclip()
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    pcall(function()
        if lplr.Character then
            for _, part in ipairs(lplr.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                    part.Transparency = 0
                end
            end
        end
    end)
end

local function startNoclip()
    disconnectNoclip()
    noclipConn = RunService.Stepped:Connect(function()
        pcall(function()
            if flyEnabled and lplr.Character then
                for _, part in ipairs(lplr.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        if part.Name ~= "HumanoidRootPart" then
                            part.Transparency = 1
                        end
                    end
                end
            end
        end)
    end)
end

local function startWalkSpeed()
    if walkSpeedConn then walkSpeedConn:Disconnect() end
    walkSpeedConn = RunService.Heartbeat:Connect(function()
        pcall(function()
            if walkSpeedEnabled and lplr.Character then
                local humanoid = lplr.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = currentWalkSpeed
                end
            end
        end)
    end)
end

local function stopWalkSpeed()
    if walkSpeedConn then
        walkSpeedConn:Disconnect()
        walkSpeedConn = nil
    end
    pcall(function()
        if lplr.Character then
            local humanoid = lplr.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16
            end
        end
    end)
end

local function startInfiniteStamina()
    if staminaConn then staminaConn:Disconnect() end
    staminaConn = RunService.Heartbeat:Connect(function()
        pcall(function()
            if infiniteStaminaEnabled and lplr:FindFirstChild("Valuestats") then
                if lplr.Valuestats:FindFirstChild("Stamina") then
                    lplr.Valuestats.Stamina.Value = 100
                end
            end
        end)
    end)
end

local function stopInfiniteStamina()
    if staminaConn then
        staminaConn:Disconnect()
        staminaConn = nil
    end
end

local function teleportToPosition(position)
    pcall(function()
        local character = lplr.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(position)
        end
    end)
end

-- ============================================================================
-- UI CREATION
-- ============================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DelayedSLPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if lplr.PlayerGui:FindFirstChild("DelayedSLPanel") then
    lplr.PlayerGui.DelayedSLPanel:Destroy()
end

ScreenGui.Parent = lplr.PlayerGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
MainFrame.Size = UDim2.new(0, 800, 0, 600)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.BackgroundColor3 = Theme.Card
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.BackgroundColor3 = Theme.Card
TitleFix.BorderSizePixel = 0
TitleFix.Position = UDim2.new(0, 0, 1, -10)
TitleFix.Size = UDim2.new(1, 0, 0, 10)
TitleFix.Parent = TitleBar

-- Title accent line
local TitleAccent = Instance.new("Frame")
TitleAccent.BackgroundColor3 = Theme.Accent
TitleAccent.BorderSizePixel = 0
TitleAccent.Position = UDim2.new(0, 0, 1, -2)
TitleAccent.Size = UDim2.new(1, 0, 0, 2)
TitleAccent.Parent = TitleBar

-- Title Text
local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 20, 0, 8)
Title.Size = UDim2.new(0, 300, 0, 20)
Title.Font = Enum.Font.GothamBold
Title.Text = "Minwel Menu"
Title.TextColor3 = Theme.Text
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local Subtitle = Instance.new("TextLabel")
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.new(0, 20, 0, 28)
Subtitle.Size = UDim2.new(0, 300, 0, 16)
Subtitle.Font = Enum.Font.Gotham
Subtitle.Text = "Sud de Londres remastérisé"
Subtitle.TextColor3 = Theme.TextDim
Subtitle.TextSize = 11
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = TitleBar

-- Minimize Button
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Position = UDim2.new(1, -75, 0.5, -13)
MinimizeButton.Size = UDim2.new(0, 26, 0, 26)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Theme.Text
MinimizeButton.TextSize = 16
MinimizeButton.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeButton

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 60)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -40, 0.5, -13)
CloseButton.Size = UDim2.new(0, 26, 0, 26)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Position = UDim2.new(0, 0, 0, 50)
Sidebar.Size = UDim2.new(0, 230, 1, -50)
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 10)
SidebarCorner.Parent = Sidebar

local SidebarFix1 = Instance.new("Frame")
SidebarFix1.BackgroundColor3 = Theme.Sidebar
SidebarFix1.BorderSizePixel = 0
SidebarFix1.Position = UDim2.new(1, -10, 0, 0)
SidebarFix1.Size = UDim2.new(0, 10, 1, 0)
SidebarFix1.Parent = Sidebar

local SidebarFix2 = Instance.new("Frame")
SidebarFix2.BackgroundColor3 = Theme.Sidebar
SidebarFix2.BorderSizePixel = 0
SidebarFix2.Size = UDim2.new(1, 0, 0, 10)
SidebarFix2.Parent = Sidebar

local SidebarBorder = Instance.new("Frame")
SidebarBorder.BackgroundColor3 = Theme.Border
SidebarBorder.BorderSizePixel = 0
SidebarBorder.Position = UDim2.new(1, 0, 0, 0)
SidebarBorder.Size = UDim2.new(0, 1, 1, 0)
SidebarBorder.Parent = Sidebar

-- Sidebar Content
local SidebarContent = Instance.new("Frame")
SidebarContent.Name = "SidebarContent"
SidebarContent.BackgroundTransparency = 1
SidebarContent.Size = UDim2.new(1, 0, 1, 0)
SidebarContent.Parent = Sidebar

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 8)
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Parent = SidebarContent

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 15)
SidebarPadding.PaddingLeft = UDim.new(0, 10)
SidebarPadding.PaddingRight = UDim.new(0, 10)
SidebarPadding.Parent = SidebarContent

-- Content Area
local ContentArea = Instance.new("Frame")
ContentArea.BackgroundColor3 = Theme.ContentBg
ContentArea.BorderSizePixel = 0
ContentArea.Position = UDim2.new(0, 230, 0, 50)
ContentArea.Size = UDim2.new(1, -230, 1, -50)
ContentArea.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 10)
ContentCorner.Parent = ContentArea

local ContentFix1 = Instance.new("Frame")
ContentFix1.BackgroundColor3 = Theme.ContentBg
ContentFix1.BorderSizePixel = 0
ContentFix1.Size = UDim2.new(0, 10, 1, 0)
ContentFix1.Parent = ContentArea

local ContentFix2 = Instance.new("Frame")
ContentFix2.BackgroundColor3 = Theme.ContentBg
ContentFix2.BorderSizePixel = 0
ContentFix2.Size = UDim2.new(1, 0, 0, 10)
ContentFix2.Parent = ContentArea

-- Tabs Container
local TabsContainer = Instance.new("Frame")
TabsContainer.BackgroundTransparency = 1
TabsContainer.Size = UDim2.new(1, 0, 1, 0)
TabsContainer.Parent = ContentArea

-- ============================================================================
-- UI COMPONENTS
-- ============================================================================

local function createSidebarButton(text, icon, order, tabName)
    local Button = Instance.new("TextButton")
    Button.BackgroundColor3 = Theme.Card
    Button.BorderSizePixel = 0
    Button.Size = UDim2.new(1, 0, 0, 45)
    Button.Text = ""
    Button.LayoutOrder = order
    Button.AutoButtonColor = false
    Button.Parent = SidebarContent
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Button
    
    local Icon = Instance.new("TextLabel")
    Icon.BackgroundTransparency = 1
    Icon.Position = UDim2.new(0, 12, 0, 0)
    Icon.Size = UDim2.new(0, 30, 1, 0)
    Icon.Font = Enum.Font.GothamBold
    Icon.Text = icon
    Icon.TextColor3 = Theme.TextDim
    Icon.TextSize = 18
    Icon.Parent = Button
    
    local Label = Instance.new("TextLabel")
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 46, 0, 0)
    Label.Size = UDim2.new(1, -46, 1, 0)
    Label.Font = Enum.Font.GothamSemibold
    Label.Text = text
    Label.TextColor3 = Theme.TextDim
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Button
    
    local Indicator = Instance.new("Frame")
    Indicator.BackgroundColor3 = Theme.Accent
    Indicator.BorderSizePixel = 0
    Indicator.Position = UDim2.new(0, 0, 0.5, -12)
    Indicator.Size = UDim2.new(0, 4, 0, 24)
    Indicator.Visible = false
    Indicator.Parent = Button
    
    local IndCorner = Instance.new("UICorner")
    IndCorner.CornerRadius = UDim.new(0, 2)
    IndCorner.Parent = Indicator
    
    Button.MouseEnter:Connect(function()
        if currentTab ~= tabName then
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.CardHover}):Play()
        end
    end)
    
    Button.MouseLeave:Connect(function()
        if currentTab ~= tabName then
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Card}):Play()
        end
    end)
    
    return Button, Indicator, Icon, Label
end

local function createTabFrame(name)
    local Tab = Instance.new("ScrollingFrame")
    Tab.BackgroundTransparency = 1
    Tab.BorderSizePixel = 0
    Tab.Size = UDim2.new(1, 0, 1, 0)
    Tab.CanvasSize = UDim2.new(0, 0, 0, 0)
    Tab.ScrollBarThickness = 4
    Tab.ScrollBarImageColor3 = Theme.Accent
    Tab.Visible = false
    Tab.Parent = TabsContainer
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 12)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = Tab
    
    local Padding = Instance.new("UIPadding")
    Padding.PaddingTop = UDim.new(0, 15)
    Padding.PaddingBottom = UDim.new(0, 15)
    Padding.PaddingLeft = UDim.new(0, 15)
    Padding.PaddingRight = UDim.new(0, 15)
    Padding.Parent = Tab
    
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Tab.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 30)
    end)
    
    return Tab
end

local function createCard(parent, title, height)
    local Card = Instance.new("Frame")
    Card.BackgroundColor3 = Theme.Card
    Card.BorderSizePixel = 0
    Card.Size = UDim2.new(1, 0, 0, height or 100)
    Card.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Card
    
    local Border = Instance.new("UIStroke")
    Border.Color = Theme.Border
    Border.Thickness = 1
    Border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Border.Parent = Card
    
    if title then
        local CardTitle = Instance.new("TextLabel")
        CardTitle.BackgroundTransparency = 1
        CardTitle.Position = UDim2.new(0, 18, 0, 15)
        CardTitle.Size = UDim2.new(1, -36, 0, 22)
        CardTitle.Font = Enum.Font.GothamBold
        CardTitle.Text = title
        CardTitle.TextColor3 = Theme.Text
        CardTitle.TextSize = 15
        CardTitle.TextXAlignment = Enum.TextXAlignment.Left
        CardTitle.Parent = Card
    end
    
    return Card
end

local function createToggle(parent, name, yPos, callback)
    local Frame = Instance.new("Frame")
    Frame.BackgroundTransparency = 1
    Frame.Position = UDim2.new(0, 18, 0, yPos)
    Frame.Size = UDim2.new(1, -36, 0, 38)
    Frame.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, -65, 1, 0)
    Label.Font = Enum.Font.Gotham
    Label.Text = name
    Label.TextColor3 = Theme.Text
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local ToggleBg = Instance.new("Frame")
    ToggleBg.BackgroundColor3 = Theme.ToggleOff
    ToggleBg.BorderSizePixel = 0
    ToggleBg.Position = UDim2.new(1, -52, 0.5, -11)
    ToggleBg.Size = UDim2.new(0, 52, 0, 22)
    ToggleBg.Parent = Frame
    
    local BgCorner = Instance.new("UICorner")
    BgCorner.CornerRadius = UDim.new(1, 0)
    BgCorner.Parent = ToggleBg
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.BackgroundColor3 = Theme.ToggleKnob
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Position = UDim2.new(0, 3, 0.5, -8)
    ToggleBtn.Size = UDim2.new(0, 16, 0, 16)
    ToggleBtn.Text = ""
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.Parent = ToggleBg
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(1, 0)
    BtnCorner.Parent = ToggleBtn
    
    local state = false
    
    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        
        if state then
            TweenService:Create(ToggleBg, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
                Position = UDim2.new(1, -19, 0.5, -8),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        else
            TweenService:Create(ToggleBg, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ToggleOff}):Play()
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 3, 0.5, -8),
                BackgroundColor3 = Theme.ToggleKnob
            }):Play()
        end
        
        callback(state)
    end)
    
    return Frame
end

local function createButton(parent, name, yPos, callback)
    local Button = Instance.new("TextButton")
    Button.BackgroundColor3 = Theme.Accent
    Button.BorderSizePixel = 0
    Button.Position = UDim2.new(0, 18, 0, yPos)
    Button.Size = UDim2.new(1, -36, 0, 36)
    Button.Font = Enum.Font.GothamSemibold
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 13
    Button.AutoButtonColor = false
    Button.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Button
    
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.AccentDark}):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
    end)
    
    Button.MouseButton1Click:Connect(callback)
    
    return Button
end

local function createSmallButton(parent, name, callback)
    local Button = Instance.new("TextButton")
    Button.BackgroundColor3 = Theme.Card
    Button.BorderSizePixel = 0
    Button.Size = UDim2.new(1, 0, 0, 32)
    Button.Font = Enum.Font.Gotham
    Button.Text = name
    Button.TextColor3 = Theme.Text
    Button.TextSize = 12
    Button.AutoButtonColor = false
    Button.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button
    
    local Border = Instance.new("UIStroke")
    Border.Color = Theme.Border
    Border.Thickness = 1
    Border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Border.Parent = Button
    
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.CardHover}):Play()
        TweenService:Create(Border, TweenInfo.new(0.2), {Color = Theme.Accent}):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Card}):Play()
        TweenService:Create(Border, TweenInfo.new(0.2), {Color = Theme.Border}):Play()
    end)
    
    Button.MouseButton1Click:Connect(callback)
    
    return Button
end

-- ============================================================================
-- CREATE TABS
-- ============================================================================

-- Movement Tab
local MovementTab = createTabFrame("Movement")
local MovementCard = createCard(MovementTab, "Movement Controls", 240)

createToggle(MovementCard, "Fly + Noclip (Ctrl+F)", 50, function(state)
    flyEnabled = state
    if flyEnabled then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        startNoclip()
        startFly()
    else
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        disconnectNoclip()
        disconnectFly()
        if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
            lplr.Character.HumanoidRootPart.Anchored = false
        end
    end
end)

createToggle(MovementCard, "WalkSpeed Boost (x2)", 93, function(state)
    walkSpeedEnabled = state
    if walkSpeedEnabled then
        startWalkSpeed()
    else
        stopWalkSpeed()
    end
end)

createToggle(MovementCard, "Infinite Stamina", 136, function(state)
    infiniteStaminaEnabled = state
    if infiniteStaminaEnabled then
        startInfiniteStamina()
    else
        stopInfiniteStamina()
    end
end)

local InfoLabel = Instance.new("TextLabel")
InfoLabel.BackgroundTransparency = 1
InfoLabel.Position = UDim2.new(0, 18, 0, 185)
InfoLabel.Size = UDim2.new(1, -36, 0, 45)
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.Text = "Use WASD to move, Q/E for up/down\nCtrl+F to toggle fly on/off"
InfoLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
InfoLabel.TextSize = 12
InfoLabel.TextWrapped = true
InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
InfoLabel.Parent = MovementCard

-- Teleport Tab
local TeleportTab = createTabFrame("Teleport")

for i, location in ipairs(locations) do
    createSmallButton(TeleportTab, location.name, function()
        teleportToPosition(location.pos)
    end)
end

-- Game Tab
local GameTab = createTabFrame("Game")
local GameCard = createCard(GameTab, "Actions", 170)

createButton(GameCard, "Skip Swipe Loading", 50, function()
    pcall(function()
        game.ReplicatedStorage.UI.SwipeLog:FireServer()
    end)
end)

createButton(GameCard, "Rejoin Server", 138, function()
    pcall(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, lplr)
    end)
end)

-- ============================================================================
-- TAB SWITCHING
-- ============================================================================

local ESPTab = createTabFrame("ESP")
local AimTab = createTabFrame("Aim Assist")

local tabs = {
    {name = "ESP", icon = "🧬", frame = ESPTab},
    {name = "Aim Assist", icon = "🎯", frame = AimTab},
    {name = "Mouvement", icon = "🚀", frame = MovementTab},
    {name = "Téléportation", icon = "📍", frame = TeleportTab},
    {name = "Jeu", icon = "⚙️", frame = GameTab},
}

local sidebarButtons = {}

for i, tab in ipairs(tabs) do
    local btn, indicator, icon, label = createSidebarButton(tab.name, tab.icon, i, tab.name)
    
    sidebarButtons[tab.name] = {
        button = btn,
        indicator = indicator,
        icon = icon,
        label = label
    }
    
    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(tabs) do
            t.frame.Visible = false
        end
        
        for _, sb in pairs(sidebarButtons) do
            sb.indicator.Visible = false
            TweenService:Create(sb.button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Card}):Play()
            TweenService:Create(sb.icon, TweenInfo.new(0.2), {TextColor3 = Theme.TextDim}):Play()
            TweenService:Create(sb.label, TweenInfo.new(0.2), {TextColor3 = Theme.TextDim}):Play()
        end
        
        currentTab = tab.name
        tab.frame.Visible = true
        sidebarButtons[tab.name].indicator.Visible = true
        TweenService:Create(sidebarButtons[tab.name].button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.CardHover}):Play()
        TweenService:Create(sidebarButtons[tab.name].icon, TweenInfo.new(0.2), {TextColor3 = Theme.Accent}):Play()
        TweenService:Create(sidebarButtons[tab.name].label, TweenInfo.new(0.2), {TextColor3 = Theme.Text}):Play()
    end)
end

-- Activate first tab
-- Activate first tab
ESPTab.Visible = true

local movementButton = sidebarButtons["ESP"]

if movementButton then
    if movementButton.indicator then
        movementButton.indicator.Visible = true
    end

    if movementButton.button then
        movementButton.button.BackgroundColor3 = Theme.CardHover
    end

    if movementButton.icon then
        movementButton.icon.TextColor3 = Theme.Accent
    end

    if movementButton.label then
        movementButton.label.TextColor3 = Theme.Text
    end
end

-- ============================================================================
-- MINIMIZE & CLOSE
-- ============================================================================

local minimized = false
local originalSize = MainFrame.Size
local originalPos = MainFrame.Position

MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    
    if minimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 300, 0, 50),
            Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset, 1, -70)
        }):Play()
        
        Sidebar.Visible = false
        ContentArea.Visible = false
        MinimizeButton.Text = "□"
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = originalSize,
            Position = originalPos
        }):Play()
        
        task.wait(0.15)
        Sidebar.Visible = true
        ContentArea.Visible = true
        MinimizeButton.Text = "_"
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)


--==================================================
-- PLAYER ESP - ROBLOX STUDIO
-- A placer dans un LocalScript
-- GameTab doit déjà exister
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CONFIGURATION
local ESPSettings = {
    Box = false,
    Corner = false,
    Line = false,
    Skeleton = false,
    Name = false,
    Distance = false,
    Health = false,
    TeamCheck = false
}

local ESPColor = Color3.fromRGB(255, 55, 55)

--==================================================
-- INTERFACE
--==================================================

local ESPFrame = Instance.new("Frame")
ESPFrame.Name = "ESPFrame"
ESPFrame.Size = UDim2.new(1, -20, 0, 300)
ESPFrame.Position = UDim2.new(0, 10, 0, 10)
ESPFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 27)
ESPFrame.BorderSizePixel = 0
ESPFrame.Parent = ESPTab

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = ESPFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "PLAYER ESP"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.Parent = ESPFrame

local options = {
    {"Box ESP", "Box"},
    {"Corner ESP", "Corner"},
    {"Line ESP", "Line"},
    {"Skeleton ESP", "Skeleton"},
    {"Name ESP", "Name"},
    {"Distance ESP", "Distance"},
    {"Health ESP", "Health"},
    {"Team Check", "TeamCheck"}
}

local buttons = {}

for i, option in ipairs(options) do
    local button = Instance.new("TextButton")
    button.Name = option[2] .. "Button"
    button.Size = UDim2.new(0.46, 0, 0, 30)
    button.Position = UDim2.new(
        (i % 2 == 0) and 0.51 or 0.03,
        0,
        0,
        40 + math.floor((i - 1) / 2) * 42
    )
    button.BackgroundColor3 = Color3.fromRGB(55, 55, 62)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.Text = option[1] .. " : OFF"
    button.Parent = ESPFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 5)
    btnCorner.Parent = button

    buttons[option[2]] = button

    button.MouseButton1Click:Connect(function()
        ESPSettings[option[2]] = not ESPSettings[option[2]]

        button.Text = option[1] ..
            (ESPSettings[option[2]] and " : ON" or " : OFF")

        button.BackgroundColor3 = ESPSettings[option[2]]
            and Color3.fromRGB(180, 35, 35)
            or Color3.fromRGB(55, 55, 62)
    end)
end

--==================================================
-- INTERFACE ESP SUR LES JOUEURS
--==================================================

local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "PlayerESP"
ESPGui.IgnoreGuiInset = true
ESPGui.ResetOnSpawn = false
ESPGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local visuals = {}

local function createLine(parent, thickness)
    local line = Instance.new("Frame")
    line.BorderSizePixel = 0
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BackgroundColor3 = ESPColor
    line.Size = UDim2.new(0, 0, 0, thickness or 2)
    line.Visible = false
    line.Parent = parent
    return line
end

local function updateLine(line, p1, p2)
    local difference = p2 - p1
    line.Position = UDim2.fromOffset(
        (p1.X + p2.X) / 2,
        (p1.Y + p2.Y) / 2
    )
    line.Size = UDim2.fromOffset(
        difference.Magnitude,
        line.Size.Y.Offset
    )
    line.Rotation = math.deg(
        math.atan2(difference.Y, difference.X)
    )
    line.Visible = true
end

local function createVisual(player)
    local folder = Instance.new("Folder")
    folder.Name = player.Name
    folder.Parent = ESPGui

    local box = Instance.new("Frame")
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Visible = false
    box.Parent = folder

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = ESPColor
    boxStroke.Thickness = 1.5
    boxStroke.Parent = box

    local corners = {}
    for i = 1, 8 do
        corners[i] = createLine(folder, 2)
    end

    local tracer = createLine(folder, 2)

    local name = Instance.new("TextLabel")
    name.BackgroundTransparency = 1
    name.TextColor3 = Color3.new(1, 1, 1)
    name.TextStrokeTransparency = 0
    name.Font = Enum.Font.GothamBold
    name.TextSize = 13
    name.Visible = false
    name.Parent = folder

    local distance = name:Clone()
    distance.TextSize = 11
    distance.Parent = folder

    local healthBG = Instance.new("Frame")
    healthBG.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    healthBG.BorderSizePixel = 0
    healthBG.Visible = false
    healthBG.Parent = folder

    local healthBar = Instance.new("Frame")
    healthBar.BackgroundColor3 = Color3.fromRGB(50, 220, 80)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = healthBG

    local skeleton = {}
    for i = 1, 15 do
        skeleton[i] = createLine(folder, 2)
    end

    visuals[player] = {
        Folder = folder,
        Box = box,
        Corners = corners,
        Tracer = tracer,
        Name = name,
        Distance = distance,
        HealthBG = healthBG,
        HealthBar = healthBar,
        Skeleton = skeleton
    }
end

--==================================================
-- SKELETON
--==================================================

local skeletonPairs = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

local function getBodyPart(character, partName)
    local part = character:FindFirstChild(partName)

    if not part and partName == "UpperTorso" then
        part = character:FindFirstChild("Torso")
    elseif not part and partName == "LowerTorso" then
        part = character:FindFirstChild("Torso")
    elseif not part and partName == "LeftUpperArm" then
        part = character:FindFirstChild("Left Arm")
    elseif not part and partName == "RightUpperArm" then
        part = character:FindFirstChild("Right Arm")
    elseif not part and partName == "LeftUpperLeg" then
        part = character:FindFirstChild("Left Leg")
    elseif not part and partName == "RightUpperLeg" then
        part = character:FindFirstChild("Right Leg")
    end

    return part
end

--==================================================
-- CREATION DES ESP
--==================================================

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createVisual(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createVisual(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if visuals[player] then
        visuals[player].Folder:Destroy()
        visuals[player] = nil
    end
end)

local function hideVisual(v)
    v.Box.Visible = false
    v.Tracer.Visible = false
    v.Name.Visible = false
    v.Distance.Visible = false
    v.HealthBG.Visible = false

    for _, line in ipairs(v.Corners) do
        line.Visible = false
    end

    for _, line in ipairs(v.Skeleton) do
        line.Visible = false
    end
end

--==================================================
-- ACTUALISATION ESP
--==================================================

local espConnection

espConnection = RunService.RenderStepped:Connect(function()
    Camera = workspace.CurrentCamera

    for player, v in pairs(visuals) do
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")

        local valid = character and humanoid and root
            and humanoid.Health > 0

        if valid and ESPSettings.TeamCheck and LocalPlayer.Team
            and player.Team == LocalPlayer.Team then
            valid = false
        end

        if not valid then
            hideVisual(v)
            continue
        end

        local center, size = character:GetBoundingBox()
        local half = size / 2

        local points = {}
        local visible = false

        for x = -1, 1, 2 do
            for y = -1, 1, 2 do
                for z = -1, 1, 2 do
                    local worldPoint = center.Position +
                        center.RightVector * half.X * x +
                        center.UpVector * half.Y * y +
                        center.LookVector * half.Z * z

                    local screenPoint, onScreen =
                        Camera:WorldToViewportPoint(worldPoint)

                    if onScreen and screenPoint.Z > 0 then
                        visible = true
                    end

                    table.insert(points, Vector2.new(
                        screenPoint.X,
                        screenPoint.Y
                    ))
                end
            end
        end

        if not visible then
            hideVisual(v)
            continue
        end

        local minX, minY = math.huge, math.huge
        local maxX, maxY = -math.huge, -math.huge

        for _, point in ipairs(points) do
            minX = math.min(minX, point.X)
            minY = math.min(minY, point.Y)
            maxX = math.max(maxX, point.X)
            maxY = math.max(maxY, point.Y)
        end

        local width = maxX - minX
        local height = maxY - minY

        -- BOX ESP
        v.Box.Visible = ESPSettings.Box
        v.Box.Position = UDim2.fromOffset(minX, minY)
        v.Box.Size = UDim2.fromOffset(width, height)

        -- CORNER ESP
        for _, line in ipairs(v.Corners) do
            line.Visible = false
        end

        if ESPSettings.Corner then
            local w, h = width * 0.25, height * 0.2
            local x1, x2 = minX, maxX
            local y1, y2 = minY, maxY

            local segments = {
                {Vector2.new(x1,y1), Vector2.new(x1+w,y1)},
                {Vector2.new(x1,y1), Vector2.new(x1,y1+h)},
                {Vector2.new(x2,y1), Vector2.new(x2-w,y1)},
                {Vector2.new(x2,y1), Vector2.new(x2,y1+h)},
                {Vector2.new(x1,y2), Vector2.new(x1+w,y2)},
                {Vector2.new(x1,y2), Vector2.new(x1,y2-h)},
                {Vector2.new(x2,y2), Vector2.new(x2-w,y2)},
                {Vector2.new(x2,y2), Vector2.new(x2,y2-h)}
            }

            for i, segment in ipairs(segments) do
                updateLine(v.Corners[i], segment[1], segment[2])
            end
        end

        -- LINE ESP
        v.Tracer.Visible = false

        if ESPSettings.Line then
            local viewport = Camera.ViewportSize
            updateLine(
                v.Tracer,
                Vector2.new(viewport.X / 2, viewport.Y),
                Vector2.new((minX + maxX) / 2, maxY)
            )
        end

        -- NAME ESP
        v.Name.Visible = ESPSettings.Name
        v.Name.Text = player.DisplayName
        v.Name.Position = UDim2.fromOffset(minX, minY - 20)
        v.Name.Size = UDim2.fromOffset(width, 18)

        -- DISTANCE ESP
        local distanceValue = (root.Position -
            Camera.CFrame.Position).Magnitude

        v.Distance.Visible = ESPSettings.Distance
        v.Distance.Text = math.floor(distanceValue) .. " studs"
        v.Distance.Position = UDim2.fromOffset(minX, maxY + 2)
        v.Distance.Size = UDim2.fromOffset(width, 16)

        -- HEALTH ESP
        v.HealthBG.Visible = ESPSettings.Health
        v.HealthBG.Position = UDim2.fromOffset(minX - 6, minY)
        v.HealthBG.Size = UDim2.fromOffset(4, height)

        local healthPercent = math.clamp(
            humanoid.Health / humanoid.MaxHealth, 0, 1
        )

        v.HealthBar.Size = UDim2.new(1, 0, healthPercent, 0)
        v.HealthBar.Position = UDim2.new(
            0, 0, 1 - healthPercent, 0
        )

        -- SKELETON ESP
        for i, pair in ipairs(skeletonPairs) do
            local partA = getBodyPart(character, pair[1])
            local partB = getBodyPart(character, pair[2])
            local line = v.Skeleton[i]

            line.Visible = false

            if ESPSettings.Skeleton and partA and partB then
                local posA, onA = Camera:WorldToViewportPoint(partA.Position)
                local posB, onB = Camera:WorldToViewportPoint(partB.Position)

                if onA and onB and posA.Z > 0 and posB.Z > 0 then
                    updateLine(
                        line,
                        Vector2.new(posA.X, posA.Y),
                        Vector2.new(posB.X, posB.Y)
                    )
                end
            end
        end
    end
end)

--==================================================
-- CLEANUP
--==================================================

local function unloadESP()
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end

    ESPGui:Destroy()
    ESPFrame:Destroy()
end

local unloadButton = Instance.new("TextButton")
unloadButton.Name = "DisableESP"
unloadButton.Size = UDim2.new(0.94, 0, 0, 30)
unloadButton.Position = UDim2.new(0.03, 0, 0, 215)
unloadButton.BackgroundColor3 = Color3.fromRGB(190, 35, 35)
unloadButton.Text = "DISABLE ALL ESP"
unloadButton.TextColor3 = Color3.new(1, 1, 1)
unloadButton.Font = Enum.Font.GothamBold
unloadButton.TextSize = 13
unloadButton.Parent = ESPFrame

local unloadCorner = Instance.new("UICorner")
unloadCorner.CornerRadius = UDim.new(0, 5)
unloadCorner.Parent = unloadButton

unloadButton.MouseButton1Click:Connect(unloadESP)



-- ============================================================================
-- AIM ASSIST (joueurs de ta propre expérience Roblox)
-- Cette partie sélectionne un personnage joueur et oriente la caméra.
-- Elle ne modifie pas les dégâts ni la trajectoire serveur des projectiles.
-- ============================================================================

local AimConfig = {
    Enabled = false,
    SilentEnabled = false,
    Active = false,
    ToggleKey = Enum.KeyCode.G,
    FOV = 120,
    MaxDistance = 300,
    Smoothness = 0.18,
    TargetPart = "Head",
    WallCheck = true,
    ShowFOV = true,
    IgnoreTeam = false,
}

local waitingForAimKey = false
local AimCard = createCard(AimTab, "AIM ASSIST - JOUEURS", 450)

local AimInfo = Instance.new("TextLabel")
AimInfo.BackgroundTransparency = 1
AimInfo.Position = UDim2.new(0, 18, 0, 40)
AimInfo.Size = UDim2.new(1, -36, 0, 34)
AimInfo.Font = Enum.Font.Gotham
AimInfo.Text = "Cible les personnages des autres joueurs de cette partie."
AimInfo.TextColor3 = Theme.TextDim
AimInfo.TextSize = 11
AimInfo.TextWrapped = true
AimInfo.TextXAlignment = Enum.TextXAlignment.Left
AimInfo.Parent = AimCard

createToggle(AimCard, "Activer Aim Assist", 78, function(state)
    AimConfig.Enabled = state
    if not state then AimConfig.Active = false end
end)

createToggle(AimCard, "Afficher le cercle FOV", 119, function(state)
    AimConfig.ShowFOV = state
end)

createToggle(AimCard, "Vérifier les murs (Wall Check)", 160, function(state)
    AimConfig.WallCheck = state
end)

createToggle(AimCard, "Ignorer les coéquipiers", 201, function(state)
    AimConfig.IgnoreTeam = state
end)

local KeyButton = Instance.new("TextButton")
KeyButton.Name = "AimKeyButton"
KeyButton.Position = UDim2.new(0, 18, 0, 245)
KeyButton.Size = UDim2.new(0.46, 0, 0, 32)
KeyButton.BackgroundColor3 = Theme.CardHover
KeyButton.BorderSizePixel = 0
KeyButton.TextColor3 = Theme.Text
KeyButton.Font = Enum.Font.GothamSemibold
KeyButton.TextSize = 12
KeyButton.Text = "Touche : G"
KeyButton.Parent = AimCard
Instance.new("UICorner", KeyButton).CornerRadius = UDim.new(0, 6)

local TargetButton = Instance.new("TextButton")
TargetButton.Name = "AimTargetButton"
TargetButton.Position = UDim2.new(0.51, 0, 0, 245)
TargetButton.Size = UDim2.new(0.46, 0, 0, 32)
TargetButton.BackgroundColor3 = Theme.CardHover
TargetButton.BorderSizePixel = 0
TargetButton.TextColor3 = Theme.Text
TargetButton.Font = Enum.Font.GothamSemibold
TargetButton.TextSize = 12
TargetButton.Text = "Cible : Tête"
TargetButton.Parent = AimCard
Instance.new("UICorner", TargetButton).CornerRadius = UDim.new(0, 6)

KeyButton.MouseButton1Click:Connect(function()
    waitingForAimKey = true
    KeyButton.Text = "Appuie sur une touche..."
end)

TargetButton.MouseButton1Click:Connect(function()
    AimConfig.TargetPart = (AimConfig.TargetPart == "Head") and "HumanoidRootPart" or "Head"
    TargetButton.Text = (AimConfig.TargetPart == "Head") and "Cible : Tête" or "Cible : Torse"
end)

local function makeNumberSetting(labelText, y, defaultValue, minValue, maxValue, suffix, setter)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 18, 0, y)
    label.Size = UDim2.new(0.47, 0, 0, 28)
    label.Font = Enum.Font.Gotham
    label.Text = labelText
    label.TextColor3 = Theme.Text
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = AimCard

    local input = Instance.new("TextBox")
    input.Position = UDim2.new(0.51, 0, 0, y)
    input.Size = UDim2.new(0.46, 0, 0, 28)
    input.BackgroundColor3 = Theme.CardHover
    input.BorderSizePixel = 0
    input.Font = Enum.Font.Gotham
    input.Text = tostring(defaultValue)
    input.TextColor3 = Theme.Text
    input.TextSize = 12
    input.ClearTextOnFocus = false
    input.Parent = AimCard
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 5)

    input.FocusLost:Connect(function()
        local value = tonumber(input.Text)
        if not value then
            input.Text = tostring(defaultValue)
            return
        end
        value = math.clamp(value, minValue, maxValue)
        setter(value)
        input.Text = tostring(value) .. (suffix or "")
    end)
end

makeNumberSetting("FOV (pixels)", 287, AimConfig.FOV, 30, 500, "", function(v)
    AimConfig.FOV = v
end)
makeNumberSetting("Distance max (studs)", 322, AimConfig.MaxDistance, 25, 2000, "", function(v)
    AimConfig.MaxDistance = v
end)
makeNumberSetting("Lissage (1-100)", 357, 18, 1, 100, "%", function(v)
    AimConfig.Smoothness = v / 100
end)

createToggle(AimCard, "Activer Silent Aim (SimpleCast)", 405, function(state)
    AimConfig.SilentEnabled = state
end)

local AimOverlay = Instance.new("ScreenGui")
AimOverlay.Name = "MinwelAimOverlay"
AimOverlay.IgnoreGuiInset = true
AimOverlay.ResetOnSpawn = false
AimOverlay.DisplayOrder = 20
AimOverlay.Parent = lplr:WaitForChild("PlayerGui")

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.fromScale(0.5, 0.5)
FOVCircle.Size = UDim2.fromOffset(AimConfig.FOV * 2, AimConfig.FOV * 2)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = false
FOVCircle.Parent = AimOverlay

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Color3.fromRGB(0, 220, 110)
FOVStroke.Thickness = 1.5
FOVStroke.Transparency = 0.15
FOVStroke.Parent = FOVCircle

local function isVisibleToCamera(targetCharacter, targetPart, camera)
    if not AimConfig.WallCheck then return true end
    local origin = camera.CFrame.Position
    local direction = targetPart.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = lplr.Character and {lplr.Character} or {}
    local result = Workspace:Raycast(origin, direction, params)
    return result ~= nil and result.Instance:IsDescendantOf(targetCharacter)
end

-- Silent Aim : redirige la direction transmise à SimpleCast.Fire sans déplacer la caméra.
-- Le module SimpleCast doit être présent dans ReplicatedStorage et utilisé par les armes.
local SimpleCastModule
local originalSimpleCastFire
do
    local simpleCastObject = game:GetService("ReplicatedStorage"):FindFirstChild("SimpleCast")
    local ok, moduleOrError = pcall(function()
        if not simpleCastObject then
            error("ModuleScript SimpleCast absent de ReplicatedStorage")
        end
        return require(simpleCastObject)
    end)
    if ok and type(moduleOrError) == "table" and type(moduleOrError.Fire) == "function" then
        SimpleCastModule = moduleOrError
        originalSimpleCastFire = moduleOrError.Fire

        local function getSilentAimTarget(origin)
            local camera = Workspace.CurrentCamera
            local myCharacter = lplr.Character
            local myRoot = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")
            if not camera or not myRoot then return nil end

            local center = UserInputService:GetMouseLocation()
            local bestPart = nil
            local bestScreenDistance = AimConfig.FOV

            for _, targetPlayer in ipairs(Players:GetPlayers()) do
                if targetPlayer ~= lplr then
                    local sameTeam = lplr.Team ~= nil and targetPlayer.Team == lplr.Team
                    if not (AimConfig.IgnoreTeam and sameTeam) then
                        local character = targetPlayer.Character
                        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                        local root = character and character:FindFirstChild("HumanoidRootPart")
                        local targetPart = character and (character:FindFirstChild(AimConfig.TargetPart) or root)

                        if humanoid and humanoid.Health > 0 and root and targetPart then
                            local worldDistance = (root.Position - myRoot.Position).Magnitude
                            if worldDistance <= AimConfig.MaxDistance then
                                local screenPosition, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                                if onScreen and screenPosition.Z > 0 then
                                    local screenDistance = (Vector2.new(screenPosition.X, screenPosition.Y) - center).Magnitude
                                    if screenDistance < bestScreenDistance and isVisibleToCamera(character, targetPart, camera) then
                                        bestScreenDistance = screenDistance
                                        bestPart = targetPart
                                    end
                                end
                            end
                        end
                    end
                end
            end

            return bestPart
        end

        moduleOrError.Fire = function(self, origin, direction, speed, options, ...)
            if AimConfig.SilentEnabled then
                local targetPart = getSilentAimTarget(origin)
                if targetPart then
                    local offset = targetPart.Position - origin
                    if offset.Magnitude > 0 then
                        direction = offset.Unit
                    end
                end
            end
            return originalSimpleCastFire(self, origin, direction, speed, options, ...)
        end
    else
        warn("[Minwel] Silent Aim indisponible : ReplicatedStorage.SimpleCast.Fire introuvable.")
    end
end


local aimConnection
local aimInputConnection
aimConnection = RunService.RenderStepped:Connect(function()
    local camera = Workspace.CurrentCamera
    if not camera then
        FOVCircle.Visible = false
        return
    end

    FOVCircle.Size = UDim2.fromOffset(AimConfig.FOV * 2, AimConfig.FOV * 2)
    FOVCircle.Visible = AimConfig.Enabled and AimConfig.ShowFOV
    if not AimConfig.Enabled or not AimConfig.Active then return end

    local myCharacter = lplr.Character
    local myRoot = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local center = camera.ViewportSize / 2
    local bestPart = nil
    local bestScreenDistance = AimConfig.FOV

    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= lplr then
            local sameTeam = lplr.Team ~= nil and targetPlayer.Team == lplr.Team
            if not (AimConfig.IgnoreTeam and sameTeam) then
                local character = targetPlayer.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                local root = character and character:FindFirstChild("HumanoidRootPart")
                local targetPart = character and (character:FindFirstChild(AimConfig.TargetPart) or root)

                if humanoid and humanoid.Health > 0 and root and targetPart then
                    local worldDistance = (root.Position - myRoot.Position).Magnitude
                    if worldDistance <= AimConfig.MaxDistance then
                        local screenPosition, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen and screenPosition.Z > 0 then
                            local screenDistance = (Vector2.new(screenPosition.X, screenPosition.Y) - center).Magnitude
                            if screenDistance < bestScreenDistance and isVisibleToCamera(character, targetPart, camera) then
                                bestScreenDistance = screenDistance
                                bestPart = targetPart
                            end
                        end
                    end
                end
            end
        end
    end

    if bestPart then
        local goal = CFrame.lookAt(camera.CFrame.Position, bestPart.Position)
        camera.CFrame = camera.CFrame:Lerp(goal, math.clamp(AimConfig.Smoothness, 0.01, 1))
    end
end)

aimInputConnection = UserInputService.InputBegan:Connect(function(input, processed)
    if waitingForAimKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            AimConfig.ToggleKey = input.KeyCode
            KeyButton.Text = "Touche : " .. input.KeyCode.Name
            waitingForAimKey = false
        end
        return
    end
    if processed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == AimConfig.ToggleKey then
        if AimConfig.Enabled then AimConfig.Active = not AimConfig.Active end
    end
end)


-- ============================================================================
-- UNLOAD MENU 
-- ============================================================================

local UnloadButton = Instance.new("TextButton")
UnloadButton.Name = "UnloadButton"
UnloadButton.Text = "UNLOAD"
UnloadButton.Size = UDim2.new(0, 100, 0, 35)
UnloadButton.Position = UDim2.new(0, 10, 0, 10)
UnloadButton.BackgroundColor3 = Color3.fromRGB(200, 35, 35)
UnloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
UnloadButton.BorderSizePixel = 0
UnloadButton.Font = Enum.Font.GothamBold
UnloadButton.TextSize = 14
UnloadButton.Parent = GameTab

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 6)
Corner.Parent = UnloadButton

UnloadButton.MouseButton1Click:Connect(function()
    flyEnabled = false
    flyEnabled = false
    walkSpeedEnabled = false
    infiniteStaminaEnabled = false

    if flyConn then flyConn:Disconnect() flyConn = nil end
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    if walkSpeedConn then walkSpeedConn:Disconnect() walkSpeedConn = nil end
    if staminaConn then staminaConn:Disconnect() staminaConn = nil end
    if aimConnection then aimConnection:Disconnect() aimConnection = nil end
    if aimInputConnection then aimInputConnection:Disconnect() aimInputConnection = nil end
    if SimpleCastModule and originalSimpleCastFire then
        SimpleCastModule.Fire = originalSimpleCastFire
        SimpleCastModule = nil
        originalSimpleCastFire = nil
    end
    if AimOverlay then AimOverlay:Destroy() end

    ScreenGui:Destroy()
end)
-- ============================================================================
-- INPUT HANDLING
-- ============================================================================

UserInputService.InputBegan:Connect(function(key, processed)
    if processed then return end
    local keyStr = getkey(key.KeyCode)
    keys[keyStr .. "_active"] = true
    
    if key.KeyCode == Enum.KeyCode.F and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        flyEnabled = not flyEnabled
        if lplr.Character then
            if flyEnabled then
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
                startNoclip()
                startFly()
            else
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                disconnectNoclip()
                disconnectFly()
                if lplr.Character:FindFirstChild("HumanoidRootPart") then
                    lplr.Character.HumanoidRootPart.Anchored = false
                end
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(key)
    keys[getkey(key.KeyCode) .. "_active"] = false
end)

lplr.CharacterAdded:Connect(function()
    task.wait(1)
    if flyEnabled then startNoclip() end
    startFly()
    if walkSpeedEnabled then startWalkSpeed() end
    if infiniteStaminaEnabled then startInfiniteStamina() end
end)

if lplr.Character then
    startFly()
end

print("✓ Minwel Menu Loaded!")
print("✓ Press Ctrl+F to toggle fly")
print("ESPSettings :", ESPSettings)
print("MovementTab :", MovementTab)
print("TeleportTab :", TeleportTab)
print("GameTab :", GameTab)