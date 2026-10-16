-- [[ VD TOOLS v3 — Multi-Feature Hub ]]
-- Fix: Speed Boot Infinite Loop

local env = (getgenv and getgenv()) or _G
for _, name in ipairs({"VDTools_v1", "VDTools_v2", "VDTools_v3", "SimpleESP_KillerSurvivor"}) do
    local old = env[name]
    if type(old) == "table" then
        old.running = false
        if old.connection then pcall(function() old.connection:Disconnect() end) end
        for _, c in ipairs(old.connections or {}) do
            pcall(function() c:Disconnect() end)
        end
        for _, obj in ipairs(old.guis or {}) do
            pcall(function() obj:Destroy() end)
        end
        for _, esp in pairs(old.esps or {}) do
            pcall(function() 
                if esp.Highlight then esp.Highlight:Destroy() end
                if esp.Billboard then esp.Billboard:Destroy() end
            end)
        end
    end
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local state = {
    running = true,
    espEnabled = true,
    connections = {},
    guis = {},
    esps = {},
    manualKiller = {},
    manualSurvivor = {},
    antiAfkEnabled = true,
    speedMonitorConn = nil,
}
env.VDTools_v3 = state

local COLORS = {
    bg = Color3.fromRGB(28, 32, 42),
    panel = Color3.fromRGB(38, 44, 58),
    panelHover = Color3.fromRGB(48, 56, 72),
    text = Color3.fromRGB(230, 235, 245),
    textDim = Color3.fromRGB(150, 160, 180),
    accent = Color3.fromRGB(120, 150, 220),
    success = Color3.fromRGB(95, 200, 130),
    danger = Color3.fromRGB(220, 100, 100),
    warning = Color3.fromRGB(240, 180, 80),
    divider = Color3.fromRGB(55, 62, 80),
    border = Color3.fromRGB(70, 80, 105),
}

local SETTINGS = {
    MaxDistance = 1000,
    SurvivorColor = Color3.fromRGB(80, 180, 255),
    KillerColor = Color3.fromRGB(255, 90, 90),
    UnknownColor = Color3.fromRGB(180, 180, 180),
    FillTransparency = 0.7,
    ShowBox = true,
    ShowRole = true,
    ShowName = true,
    ShowDistance = true,
    ShowHealth = true,
    FilterRole = "both",
    SpeedEnabled = false,
    SpeedMultiplier = 1.25,
    JumpPower = 50,
    InfJumpEnabled = false,
    AntiFlingEnabled = false,
    FullbrightEnabled = false,
    NoFogEnabled = false,
}

-- ═══════════════════════════════════════════════════════
-- ESP
-- ═══════════════════════════════════════════════════════

local function getRole(player)
    if state.manualKiller[player.Name] then return "killer" end
    if state.manualSurvivor[player.Name] then return "survivor" end
    
    if player.Team then
        local teamName = player.Team.Name:lower()
        if teamName:find("killer") or teamName:find("murder") or teamName:find("hunter") then return "killer" end
        if teamName:find("survivor") or teamName:find("innocent") or teamName:find("runner") then return "survivor" end
    end
    
    if player.TeamColor then
        local color = player.TeamColor.Color
        if color.R > 0.6 and color.G < 0.4 then return "killer" end
        if color.B > 0.6 and color.R < 0.4 then return "survivor" end
    end
    
    local ok, role = pcall(function()
        return player:GetAttribute("Role") or player:GetAttribute("role") or player:GetAttribute("Team")
    end)
    if ok and role then
        local r = tostring(role):lower()
        if r:find("killer") or r:find("murder") then return "killer" end
        if r:find("survivor") or r:find("innocent") then return "survivor" end
    end
    
    local char = player.Character
    if char then
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") then
                local name = child.Name:lower()
                if name:find("knife") or name:find("weapon") or name:find("sword") or 
                   name:find("gun") or name:find("bat") or name:find("axe") then
                    return "killer"
                end
            end
        end
    end
    return "unknown"
end

local function getColor(role)
    if role == "killer" then return SETTINGS.KillerColor end
    if role == "survivor" then return SETTINGS.SurvivorColor end
    return SETTINGS.UnknownColor
end

local function shouldShow(role)
    if SETTINGS.FilterRole == "both" then return true end
    if SETTINGS.FilterRole == "killer" then return role == "killer" end
    if SETTINGS.FilterRole == "survivor" then return role == "survivor" end
    return true
end

local function removeESP(player)
    local data = state.esps[player]
    if not data then return end
    if data.Highlight then pcall(function() data.Highlight:Destroy() end) end
    if data.Billboard then pcall(function() data.Billboard:Destroy() end) end
    state.esps[player] = nil
end

local function createESP(player)
    if player == LocalPlayer then return end
    if state.esps[player] then return end
    
    local espData = {}
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillTransparency = SETTINGS.FillTransparency
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
    
    espData.Highlight = highlight
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.Size = UDim2.new(0, 200, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 3.2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = highlight.Parent
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Parent = billboard
    
    local roleLabel = Instance.new("TextLabel")
    roleLabel.Size = UDim2.new(1, 0, 0, 18)
    roleLabel.BackgroundTransparency = 1
    roleLabel.TextStrokeTransparency = 0
    roleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    roleLabel.TextSize = 13
    roleLabel.Font = Enum.Font.GothamBold
    roleLabel.Parent = container
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 16)
    nameLabel.Position = UDim2.new(0, 0, 0, 18)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextSize = 12
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = container
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(1, 0, 0, 14)
    distanceLabel.Position = UDim2.new(0, 0, 0, 34)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    distanceLabel.TextStrokeTransparency = 0
    distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distanceLabel.TextSize = 11
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.Parent = container
    
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Size = UDim2.new(1, 0, 0, 14)
    healthLabel.Position = UDim2.new(0, 0, 0, 48)
    healthLabel.BackgroundTransparency = 1
    healthLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    healthLabel.TextStrokeTransparency = 0
    healthLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    healthLabel.TextSize = 11
    healthLabel.Font = Enum.Font.Gotham
    healthLabel.Parent = container
    
    espData.Billboard = billboard
    espData.RoleLabel = roleLabel
    espData.NameLabel = nameLabel
    espData.DistanceLabel = distanceLabel
    espData.HealthLabel = healthLabel
    
    state.esps[player] = espData
end

local function updateESP()
    if not state.espEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if state.esps[player] then removeESP(player) end
        end
        return
    end
    
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myPos = myHRP and myHRP.Position
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local data = state.esps[player]
        if not data then
            createESP(player)
            data = state.esps[player]
            if not data then continue end
        end
        
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        
        if hrp and humanoid and humanoid.Health > 0 then
            local role = getRole(player)
            
            if not shouldShow(role) then
                data.Highlight.Enabled = false
                data.Billboard.Enabled = false
                continue
            end
            
            local distance = 0
            if myPos then
                distance = math.floor((hrp.Position - myPos).Magnitude)
            end
            
            if distance > SETTINGS.MaxDistance then
                data.Highlight.Enabled = false
                data.Billboard.Enabled = false
            else
                local color = getColor(role)
                
                data.Highlight.Enabled = SETTINGS.ShowBox
                data.Highlight.Adornee = char
                data.Highlight.FillColor = color
                data.Highlight.OutlineColor = color
                data.Highlight.FillTransparency = SETTINGS.FillTransparency
                
                data.Billboard.Enabled = true
                data.Billboard.Adornee = hrp
                
                if role == "killer" then
                    data.RoleLabel.Text = "KILLER"
                elseif role == "survivor" then
                    data.RoleLabel.Text = "SURVIVOR"
                else
                    data.RoleLabel.Text = "UNKNOWN"
                end
                data.RoleLabel.TextColor3 = color
                data.RoleLabel.Visible = SETTINGS.ShowRole
                
                data.NameLabel.Text = player.Name
                data.NameLabel.TextColor3 = color
                data.NameLabel.Visible = SETTINGS.ShowName
                
                data.DistanceLabel.Text = distance .. "m"
                data.DistanceLabel.Visible = SETTINGS.ShowDistance
                
                data.HealthLabel.Text = math.floor(humanoid.Health) .. " HP"
                local hpPercent = humanoid.Health / humanoid.MaxHealth
                data.HealthLabel.TextColor3 = Color3.fromRGB(255 * (1 - hpPercent), 255 * hpPercent, 100)
                data.HealthLabel.Visible = SETTINGS.ShowHealth
            end
        else
            data.Highlight.Enabled = false
            data.Billboard.Enabled = false
        end
    end
end

-- ═══════════════════════════════════════════════════════
-- SPEED BOOT (FIXED — ANTI LOOP)
-- ═══════════════════════════════════════════════════════

local gameBaseSpeed = 16
local ourSetSpeed = nil
local isUpdatingSpeed = false

local function disconnectSpeedMonitor()
    if state.speedMonitorConn then
        pcall(function() state.speedMonitorConn:Disconnect() end)
        state.speedMonitorConn = nil
    end
end

local function applySpeedBoot()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    disconnectSpeedMonitor()
    
    if not SETTINGS.SpeedEnabled then
        isUpdatingSpeed = true
        hum.WalkSpeed = gameBaseSpeed
        task.wait()
        isUpdatingSpeed = false
        ourSetSpeed = nil
        return
    end
    
    isUpdatingSpeed = true
    ourSetSpeed = gameBaseSpeed * SETTINGS.SpeedMultiplier
    hum.WalkSpeed = ourSetSpeed
    task.wait()
    isUpdatingSpeed = false
    
    state.speedMonitorConn = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if isUpdatingSpeed then return end
        if not SETTINGS.SpeedEnabled then return end
        if not hum or not hum.Parent then return end
        
        local current = hum.WalkSpeed
        
        if ourSetSpeed and math.abs(current - ourSetSpeed) < 0.01 then
            return
        end
        
        gameBaseSpeed = current
        
        local newSpeed = gameBaseSpeed * SETTINGS.SpeedMultiplier
        
        if math.abs(newSpeed - current) < 0.01 then
            ourSetSpeed = current
            return
        end
        
        isUpdatingSpeed = true
        ourSetSpeed = newSpeed
        hum.WalkSpeed = newSpeed
        task.wait()
        isUpdatingSpeed = false
    end)
end

local function initSpeedBoot()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    if not SETTINGS.SpeedEnabled then
        gameBaseSpeed = hum.WalkSpeed
    end
    
    applySpeedBoot()
end

local function applyPlayerMods()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    humanoid.JumpPower = SETTINGS.JumpPower
    humanoid.UseJumpPower = true
    
    initSpeedBoot()
end

-- ═══════════════════════════════════════════════════════
-- FIX LAG
-- ═══════════════════════════════════════════════════════

local lagFixes = {
    RemoveParticles = false,
    RemoveDecals = false,
    RemoveTextures = false,
    DisableShadows = false,
    LimitRenderDistance = false,
    ReduceTerrain = false,
}

local function applyLagFixes()
    if lagFixes.RemoveParticles then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Trail") then
                pcall(function() obj.Enabled = false end)
            end
        end
    end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if lagFixes.RemoveDecals and obj:IsA("Decal") then
            pcall(function() obj.Transparency = 1 end)
        end
        if lagFixes.RemoveTextures and obj:IsA("Texture") then
            pcall(function() obj.Transparency = 1 end)
        end
    end
    
    if lagFixes.DisableShadows then
        Lighting.GlobalShadows = false
    end
    
    if lagFixes.LimitRenderDistance and Camera then
        Camera.FarPlane = 200
    end
    
    if lagFixes.ReduceTerrain then
        pcall(function()
            workspace.Terrain.WaterWaveSize = 0
            workspace.Terrain.WaterWaveSpeed = 0
            workspace.Terrain.WaterReflectance = 0
            workspace.Terrain.WaterTransparency = 1
        end)
    end
end

local function resetLagFixes()
    Lighting.GlobalShadows = true
    if Camera then Camera.FarPlane = 100000 end
    pcall(function()
        workspace.Terrain.WaterWaveSize = 0.15
        workspace.Terrain.WaterWaveSpeed = 10
        workspace.Terrain.WaterReflectance = 0.1
        workspace.Terrain.WaterTransparency = 0.5
    end)
end

-- ═══════════════════════════════════════════════════════
-- MISC
-- ═══════════════════════════════════════════════════════

local function applyFullbright()
    if SETTINGS.FullbrightEnabled then
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.Ambient = Color3.fromRGB(180, 180, 180)
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = 1
        Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        Lighting.GlobalShadows = true
    end
end

local function applyNoFog()
    if SETTINGS.NoFogEnabled then
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
    else
        Lighting.FogEnd = 1000
        Lighting.FogStart = 0
    end
end

task.spawn(function()
    while state.running do
        task.wait(30)
        if state.antiAfkEnabled and state.running then
            pcall(function()
                game:GetService("VirtualUser"):CaptureController()
                game:GetService("VirtualUser"):ClickButton1(Vector2.new(0, 0))
            end)
        end
    end
end)

-- ═══════════════════════════════════════════════════════
-- GUI
-- ═══════════════════════════════════════════════════════

local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local oldGui = playerGui:FindFirstChild("VDToolsGui")
if oldGui then oldGui:Destroy() end

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "VDToolsGui"
MainGui.ResetOnSpawn = false
MainGui.DisplayOrder = 1000
MainGui.Parent = playerGui
state.guis[#state.guis+1] = MainGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.fromOffset(240, 340)
MainFrame.Position = UDim2.fromOffset(16, 80)
MainFrame.BackgroundColor3 = COLORS.bg
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = MainGui

local MFC = Instance.new("UICorner")
MFC.CornerRadius = UDim.new(0, 12)
MFC.Parent = MainFrame

local MFB = Instance.new("UIStroke")
MFB.Color = COLORS.border
MFB.Thickness = 1
MFB.Transparency = 0.5
MFB.Parent = MainFrame

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = COLORS.panel
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HC = Instance.new("UICorner")
HC.CornerRadius = UDim.new(0, 12)
HC.Parent = Header

local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0, 15)
HeaderFix.Position = UDim2.new(0, 0, 1, -15)
HeaderFix.BackgroundColor3 = COLORS.panel
HeaderFix.BorderSizePixel = 0
HeaderFix.Parent = Header

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(1, -50, 1, 0)
HeaderTitle.Position = UDim2.fromOffset(14, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "VD TOOLS v3"
HeaderTitle.TextColor3 = COLORS.text
HeaderTitle.TextSize = 13
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = Header

local HideBtn = Instance.new("TextButton")
HideBtn.Size = UDim2.fromOffset(20, 20)
HideBtn.Position = UDim2.new(1, -26, 0.5, -10)
HideBtn.BackgroundColor3 = COLORS.panelHover
HideBtn.BackgroundTransparency = 0.3
HideBtn.BorderSizePixel = 0
HideBtn.Text = "−"
HideBtn.TextColor3 = COLORS.textDim
HideBtn.TextSize = 14
HideBtn.Font = Enum.Font.GothamBold
HideBtn.Parent = Header

local HBC = Instance.new("UICorner")
HBC.CornerRadius = UDim.new(1, 0)
HBC.Parent = HideBtn

local TabRow = Instance.new("Frame")
TabRow.Size = UDim2.new(1, -16, 0, 28)
TabRow.Position = UDim2.fromOffset(8, 36)
TabRow.BackgroundColor3 = COLORS.panel
TabRow.BackgroundTransparency = 0.4
TabRow.BorderSizePixel = 0
TabRow.Parent = MainFrame

local TRC = Instance.new("UICorner")
TRC.CornerRadius = UDim.new(0, 8)
TRC.Parent = TabRow

local tabs = {"ESP", "LAG", "PLAYER", "MISC"}
local tabBtns = {}
local currentTab = "ESP"

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -16, 1, -108)
ContentFrame.Position = UDim2.fromOffset(8, 70)
ContentFrame.BackgroundColor3 = COLORS.panel
ContentFrame.BackgroundTransparency = 0.4
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local CFC = Instance.new("UICorner")
CFC.CornerRadius = UDim.new(0, 8)
CFC.Parent = ContentFrame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -8, 1, -8)
Scroll.Position = UDim2.fromOffset(4, 4)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0, 0, 0, 500)
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = COLORS.accent
Scroll.Parent = ContentFrame

local tabContents = {}
for _, tabName in ipairs(tabs) do
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 500)
    frame.BackgroundTransparency = 1
    frame.Visible = (tabName == currentTab)
    frame.Parent = Scroll
    tabContents[tabName] = frame
end

for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1/#tabs, -2, 1, -4)
    btn.Position = UDim2.new((i-1)/#tabs, 1, 0, 2)
    btn.BackgroundColor3 = (tabName == currentTab) and COLORS.accent or COLORS.panel
    btn.BackgroundTransparency = (tabName == currentTab) and 0.1 or 0.6
    btn.BorderSizePixel = 0
    btn.Text = tabName
    btn.TextColor3 = (tabName == currentTab) and COLORS.text or COLORS.textDim
    btn.TextSize = 9
    btn.Font = Enum.Font.GothamBold
    btn.Parent = TabRow
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    
    tabBtns[tabName] = btn
    
    btn.MouseButton1Click:Connect(function()
        currentTab = tabName
        for tn, tb in pairs(tabBtns) do
            if tn == tabName then
                tb.BackgroundColor3 = COLORS.accent
                tb.BackgroundTransparency = 0.1
                tb.TextColor3 = COLORS.text
                tabContents[tn].Visible = true
            else
                tb.BackgroundColor3 = COLORS.panel
                tb.BackgroundTransparency = 0.6
                tb.TextColor3 = COLORS.textDim
                tabContents[tn].Visible = false
            end
        end
        Scroll.CanvasPosition = Vector2.new(0, 0)
    end)
end

local function makeToggle(parent, y, labelText, key, table, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.94, 0, 0, 30)
    container.Position = UDim2.new(0.03, 0, 0, y)
    container.BackgroundColor3 = COLORS.panel
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    container.Parent = parent
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.fromOffset(12, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = COLORS.text
    label.TextSize = 10
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local stateBtn = Instance.new("TextButton")
    stateBtn.Size = UDim2.fromOffset(46, 20)
    stateBtn.Position = UDim2.new(1, -54, 0.5, -10)
    stateBtn.BackgroundColor3 = table[key] and COLORS.success or COLORS.divider
    stateBtn.BackgroundTransparency = 0.15
    stateBtn.BorderSizePixel = 0
    stateBtn.Text = table[key] and "ON" or "OFF"
    stateBtn.TextColor3 = COLORS.text
    stateBtn.TextSize = 9
    stateBtn.Font = Enum.Font.GothamBold
    stateBtn.Parent = container
    
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 5)
    bc.Parent = stateBtn
    
    stateBtn.MouseButton1Click:Connect(function()
        table[key] = not table[key]
        stateBtn.Text = table[key] and "ON" or "OFF"
        stateBtn.BackgroundColor3 = table[key] and COLORS.success or COLORS.divider
        if callback then pcall(callback) end
    end)
    
    return container
end

local function makeSlider(parent, y, labelText, min, max, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.94, 0, 0, 48)
    container.Position = UDim2.new(0.03, 0, 0, y)
    container.BackgroundColor3 = COLORS.panel
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    container.Parent = parent
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 16)
    label.Position = UDim2.fromOffset(12, 4)
    label.BackgroundTransparency = 1
    label.Text = labelText .. ": " .. tostring(default)
    label.TextColor3 = COLORS.text
    label.TextSize = 10
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -24, 0, 6)
    sliderBg.Position = UDim2.new(0, 12, 0, 26)
    sliderBg.BackgroundColor3 = COLORS.divider
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = container
    
    local sbc = Instance.new("UICorner")
    sbc.CornerRadius = UDim.new(1, 0)
    sbc.Parent = sliderBg
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = COLORS.accent
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(1, 0)
    fc.Parent = fill
    
    local knob = Instance.new("TextButton")
    knob.Size = UDim2.fromOffset(16, 16)
    knob.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    knob.BackgroundColor3 = COLORS.text
    knob.BorderSizePixel = 0
    knob.Text = ""
    knob.Parent = sliderBg
    
    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1, 0)
    kc.Parent = knob
    
    local dragging = false
    local function updateFromInput(input)
        local pos = sliderBg.AbsolutePosition.X
        local size = sliderBg.AbsoluteSize.X
        local percent = math.clamp((input.Position.X - pos) / size, 0, 1)
        local value = math.floor(min + percent * (max - min))
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -8, 0.5, -8)
        label.Text = labelText .. ": " .. tostring(value)
        if callback then pcall(callback, value) end
    end
    
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateFromInput(input)
        end
    end)
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateFromInput(input)
        end
    end)
    
    state.connections[#state.connections+1] = UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            updateFromInput(input)
        end
    end)
    
    state.connections[#state.connections+1] = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return container
end

-- ═══════════════════════════════════════════════════════
-- TAB: ESP
-- ═══════════════════════════════════════════════════════

local espFrame = tabContents["ESP"]

makeToggle(espFrame, 8, "ESP Aktif", "espEnabled", state, function()
    if state.espEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then createESP(player) end
        end
    end
end)

makeToggle(espFrame, 44, "Kotak Highlight", "ShowBox", SETTINGS)
makeToggle(espFrame, 80, "Role (Killer/Survivor)", "ShowRole", SETTINGS)
makeToggle(espFrame, 116, "Nama", "ShowName", SETTINGS)
makeToggle(espFrame, 152, "Jarak", "ShowDistance", SETTINGS)
makeToggle(espFrame, 188, "Darah (HP)", "ShowHealth", SETTINGS)

local filterLabel = Instance.new("TextLabel")
filterLabel.Size = UDim2.new(0.94, 0, 0, 16)
filterLabel.Position = UDim2.new(0.03, 0, 0, 228)
filterLabel.BackgroundTransparency = 1
filterLabel.Text = "FILTER ROLE"
filterLabel.TextColor3 = COLORS.textDim
filterLabel.TextSize = 9
filterLabel.Font = Enum.Font.GothamBold
filterLabel.TextXAlignment = Enum.TextXAlignment.Left
filterLabel.Parent = espFrame

local filterBtns = {}
local function updateFilterBtns()
    for role, btn in pairs(filterBtns) do
        if SETTINGS.FilterRole == role then
            btn.BackgroundColor3 = COLORS.accent
            btn.BackgroundTransparency = 0.1
            btn.TextColor3 = COLORS.text
        else
            btn.BackgroundColor3 = COLORS.panel
            btn.BackgroundTransparency = 0.3
            btn.TextColor3 = COLORS.textDim
        end
    end
end

local function makeFilterBtn(text, xPos, role)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.29, 0, 0, 26)
    btn.Position = UDim2.new(xPos, 0, 0, 250)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextSize = 9
    btn.Font = Enum.Font.GothamBold
    btn.Parent = espFrame
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = btn
    
    filterBtns[role] = btn
    
    btn.MouseButton1Click:Connect(function()
        SETTINGS.FilterRole = role
        updateFilterBtns()
    end)
end

makeFilterBtn("SEMUA", 0.03, "both")
makeFilterBtn("KILLER", 0.355, "killer")
makeFilterBtn("SURVIVOR", 0.68, "survivor")
updateFilterBtns()

local markBtn = Instance.new("TextButton")
markBtn.Size = UDim2.new(0.94, 0, 0, 30)
markBtn.Position = UDim2.new(0.03, 0, 0, 286)
markBtn.BackgroundColor3 = COLORS.danger
markBtn.BackgroundTransparency = 0.15
markBtn.BorderSizePixel = 0
markBtn.Text = "TANDAI PEMAIN TERDEKAT"
markBtn.TextColor3 = COLORS.text
markBtn.TextSize = 10
markBtn.Font = Enum.Font.GothamBold
markBtn.Parent = espFrame

local MBC = Instance.new("UICorner")
MBC.CornerRadius = UDim.new(0, 8)
MBC.Parent = markBtn

markBtn.MouseButton1Click:Connect(function()
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    
    local closest, closestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local dist = (hrp.Position - myHRP.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = player
            end
        end
    end
    
    if closest then
        if state.manualKiller[closest.Name] then
            state.manualKiller[closest.Name] = nil
            state.manualSurvivor[closest.Name] = true
            print("[VD] Marked SURVIVOR:", closest.Name)
        else
            state.manualKiller[closest.Name] = true
            state.manualSurvivor[closest.Name] = nil
            print("[VD] Marked KILLER:", closest.Name)
        end
    end
end)

-- ═══════════════════════════════════════════════════════
-- TAB: LAG
-- ═══════════════════════════════════════════════════════

local lagFrame = tabContents["LAG"]

local lagInfo = Instance.new("TextLabel")
lagInfo.Size = UDim2.new(0.94, 0, 0, 40)
lagInfo.Position = UDim2.new(0.03, 0, 0, 8)
lagInfo.BackgroundColor3 = COLORS.panel
lagInfo.BackgroundTransparency = 0.3
lagInfo.BorderSizePixel = 0
lagInfo.Text = "Fitur ini bantu ngurangin lag.\nHasil tergantung device & game."
lagInfo.TextColor3 = COLORS.textDim
lagInfo.TextSize = 9
lagInfo.Font = Enum.Font.Gotham
lagInfo.TextWrapped = true
lagInfo.Parent = lagFrame

local LIC = Instance.new("UICorner")
LIC.CornerRadius = UDim.new(0, 8)
LIC.Parent = lagInfo

makeToggle(lagFrame, 56, "Hapus Partikel/Effect", "RemoveParticles", lagFixes, applyLagFixes)
makeToggle(lagFrame, 92, "Hapus Decals", "RemoveDecals", lagFixes, applyLagFixes)
makeToggle(lagFrame, 128, "Hapus Textures", "RemoveTextures", lagFixes, applyLagFixes)
makeToggle(lagFrame, 164, "Matikan Shadows", "DisableShadows", lagFixes, applyLagFixes)
makeToggle(lagFrame, 200, "Batasi Render Distance", "LimitRenderDistance", lagFixes, applyLagFixes)
makeToggle(lagFrame, 236, "Kurangi Detail Air", "ReduceTerrain", lagFixes, applyLagFixes)

local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(0.94, 0, 0, 30)
resetBtn.Position = UDim2.new(0.03, 0, 0, 280)
resetBtn.BackgroundColor3 = COLORS.warning
resetBtn.BackgroundTransparency = 0.15
resetBtn.BorderSizePixel = 0
resetBtn.Text = "RESET SEMUA LAG FIX"
resetBtn.TextColor3 = COLORS.text
resetBtn.TextSize = 10
resetBtn.Font = Enum.Font.GothamBold
resetBtn.Parent = lagFrame

local RBC = Instance.new("UICorner")
RBC.CornerRadius = UDim.new(0, 8)
RBC.Parent = resetBtn

resetBtn.MouseButton1Click:Connect(function()
    for k, _ in pairs(lagFixes) do lagFixes[k] = false end
    resetLagFixes()
    print("[VD] Lag fixes reset")
end)

-- ═══════════════════════════════════════════════════════
-- TAB: PLAYER
-- ═══════════════════════════════════════════════════════

local playerFrame = tabContents["PLAYER"]

local speedInfo = Instance.new("TextLabel")
speedInfo.Size = UDim2.new(0.94, 0, 0, 60)
speedInfo.Position = UDim2.new(0.03, 0, 0, 8)
speedInfo.BackgroundColor3 = COLORS.panel
speedInfo.BackgroundTransparency = 0.3
speedInfo.BorderSizePixel = 0
speedInfo.Text = "SPEED BOOT NATURAL\nBoost dari kecepatan asli game.\nKalau game slow → kita ikut slow."
speedInfo.TextColor3 = COLORS.textDim
speedInfo.TextSize = 9
speedInfo.Font = Enum.Font.Gotham
speedInfo.TextWrapped = true
speedInfo.TextYAlignment = Enum.TextYAlignment.Center
speedInfo.Parent = playerFrame

local SIC = Instance.new("UICorner")
SIC.CornerRadius = UDim.new(0, 8)
SIC.Parent = speedInfo

makeToggle(playerFrame, 76, "Speed Boot Aktif", "SpeedEnabled", SETTINGS, applyPlayerMods)

local multLabel = Instance.new("TextLabel")
multLabel.Size = UDim2.new(0.94, 0, 0, 16)
multLabel.Position = UDim2.new(0.03, 0, 0, 116)
multLabel.BackgroundTransparency = 1
multLabel.Text = "MULTIPLIER: " .. string.format("%.2fx", SETTINGS.SpeedMultiplier)
multLabel.TextColor3 = COLORS.textDim
multLabel.TextSize = 9
multLabel.Font = Enum.Font.GothamBold
multLabel.TextXAlignment = Enum.TextXAlignment.Left
multLabel.Parent = playerFrame

local presets = {
    {label = "1.10x", value = 1.10},
    {label = "1.25x", value = 1.25},
    {label = "1.50x", value = 1.50},
    {label = "2.00x", value = 2.00},
}

local presetBtns = {}
local function updatePresetHighlight()
    for _, data in ipairs(presetBtns) do
        if math.abs(data.value - SETTINGS.SpeedMultiplier) < 0.01 then
            data.btn.BackgroundColor3 = COLORS.accent
            data.btn.BackgroundTransparency = 0.1
            data.btn.TextColor3 = COLORS.text
        else
            data.btn.BackgroundColor3 = COLORS.panel
            data.btn.BackgroundTransparency = 0.3
            data.btn.TextColor3 = COLORS.textDim
        end
    end
end

for i, data in ipairs(presets) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.22, 0, 0, 26)
    btn.Position = UDim2.new(0.03 + (i-1) * 0.24, 0, 0, 136)
    btn.BorderSizePixel = 0
    btn.Text = data.label
    btn.TextSize = 9
    btn.Font = Enum.Font.GothamBold
    btn.Parent = playerFrame
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    
    table.insert(presetBtns, {btn = btn, value = data.value})
    
    btn.MouseButton1Click:Connect(function()
        SETTINGS.SpeedMultiplier = data.value
        multLabel.Text = "MULTIPLIER: " .. string.format("%.2fx", SETTINGS.SpeedMultiplier)
        updatePresetHighlight()
        applyPlayerMods()
    end)
end
updatePresetHighlight()

makeSlider(playerFrame, 174, "JumpPower", 50, 200, SETTINGS.JumpPower, function(v)
    SETTINGS.JumpPower = v
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.JumpPower = v
            hum.UseJumpPower = true
        end
    end
end)

makeToggle(playerFrame, 230, "Anti-Fling", "AntiFlingEnabled", SETTINGS)
makeToggle(playerFrame, 266, "Infinite Jump", "InfJumpEnabled", SETTINGS)

-- ═══════════════════════════════════════════════════════
-- TAB: MISC
-- ═══════════════════════════════════════════════════════

local miscFrame = tabContents["MISC"]

makeToggle(miscFrame, 8, "Fullbright (Terang)", "FullbrightEnabled", SETTINGS, applyFullbright)
makeToggle(miscFrame, 44, "No Fog (Hilangkan Kabut)", "NoFogEnabled", SETTINGS, applyNoFog)
makeToggle(miscFrame, 80, "Anti-AFK", "antiAfkEnabled", state)

local miscInfo = Instance.new("TextLabel")
miscInfo.Size = UDim2.new(0.94, 0, 0, 60)
miscInfo.Position = UDim2.new(0.03, 0, 0, 120)
miscInfo.BackgroundColor3 = COLORS.panel
miscInfo.BackgroundTransparency = 0.3
miscInfo.BorderSizePixel = 0
miscInfo.Text = "Anti-AFK otomatis aktif\nbiar gak di-kick pas AFK.\nFullbright bikin game gak gelap."
miscInfo.TextColor3 = COLORS.textDim
miscInfo.TextSize = 9
miscInfo.Font = Enum.Font.Gotham
miscInfo.TextWrapped = true
miscInfo.TextYAlignment = Enum.TextYAlignment.Top
miscInfo.Parent = miscFrame

local MIC = Instance.new("UICorner")
MIC.CornerRadius = UDim.new(0, 8)
MIC.Parent = miscInfo

-- ═══════════════════════════════════════════════════════
-- EVENTS
-- ═══════════════════════════════════════════════════════

state.connections[#state.connections+1] = Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if state.espEnabled then createESP(player) end
    end)
    if player.Character and state.espEnabled then createESP(player) end
end)

state.connections[#state.connections+1] = Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

state.connections[#state.connections+1] = UserInputService.JumpRequest:Connect(function()
    if SETTINGS.InfJumpEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

task.spawn(function()
    while state.running do
        task.wait(0.1)
        if SETTINGS.AntiFlingEnabled then
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local vel = hrp.AssemblyLinearVelocity.Magnitude
                    if vel > 500 then
                        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while state.running and MainGui.Parent do
        task.wait(0.1)
        if not state.running then break end
        pcall(updateESP)
    end
end)

state.connections[#state.connections+1] = LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    disconnectSpeedMonitor()
    task.wait(0.5)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            gameBaseSpeed = hum.WalkSpeed
            applySpeedBoot()
        end
    end
    applyPlayerMods()
    if not state.espEnabled then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not state.esps[player] then
            createESP(player)
        end
    end
end)

state.connections[#state.connections+1] = HideBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    if not MainGui:FindFirstChild("ShowBtn") then
        local showBtn = Instance.new("TextButton")
        showBtn.Name = "ShowBtn"
        showBtn.Size = UDim2.fromOffset(44, 44)
        showBtn.Position = UDim2.fromOffset(16, 80)
        showBtn.BackgroundColor3 = COLORS.bg
        showBtn.BackgroundTransparency = 0.05
        showBtn.BorderSizePixel = 0
        showBtn.Text = "VD"
        showBtn.TextColor3 = COLORS.accent
        showBtn.TextSize = 12
        showBtn.Font = Enum.Font.GothamBold
        showBtn.Active = true
        showBtn.Draggable = true
        showBtn.Parent = MainGui
        
        local sc = Instance.new("UICorner")
        sc.CornerRadius = UDim.new(0, 12)
        sc.Parent = showBtn
        
        local s = Instance.new("UIStroke")
        s.Color = COLORS.accent
        s.Thickness = 1
        s.Transparency = 0.3
        s.Parent = showBtn
        
        showBtn.MouseButton1Click:Connect(function()
            MainFrame.Visible = true
            showBtn:Destroy()
        end)
    end
end)

applyPlayerMods()
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then createESP(player) end
end

print("[VD TOOLS v3] Loaded! Speed Boot FIXED")
