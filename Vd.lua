-- [[ VD TOOLS v6 — Bolong Style + Brutal Anti-Lag (FIXED) ]]

local env = (getgenv and getgenv()) or _G
for _, name in ipairs({"VDTools_v1", "VDTools_v2", "VDTools_v3", "VDTools_v4", "VDTools_v5", "VDTools_v6", "SimpleESP_KillerSurvivor"}) do
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
    brutalLagEnabled = false,
    brutalLagConn = nil,
}
env.VDTools_v6 = state

local C = {
    bg = Color3.fromRGB(14, 14, 18),
    panel = Color3.fromRGB(22, 22, 28),
    panelLight = Color3.fromRGB(30, 30, 38),
    sidebar = Color3.fromRGB(18, 18, 24),
    hover = Color3.fromRGB(38, 38, 48),
    text = Color3.fromRGB(240, 240, 245),
    textDim = Color3.fromRGB(140, 140, 155),
    accent = Color3.fromRGB(120, 130, 200),
    success = Color3.fromRGB(90, 200, 130),
    danger = Color3.fromRGB(220, 90, 90),
    warning = Color3.fromRGB(240, 180, 80),
    divider = Color3.fromRGB(40, 40, 50),
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
        local tn = player.Team.Name:lower()
        if tn:find("killer") or tn:find("murder") or tn:find("hunter") then return "killer" end
        if tn:find("survivor") or tn:find("innocent") or tn:find("runner") then return "survivor" end
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
            if myPos then distance = math.floor((hrp.Position - myPos).Magnitude) end
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
                if role == "killer" then data.RoleLabel.Text = "KILLER"
                elseif role == "survivor" then data.RoleLabel.Text = "SURVIVOR"
                else data.RoleLabel.Text = "UNKNOWN" end
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
-- BRUTAL ANTI-LAG (FIXED — HORMATI FULLBRIGHT & NO FOG)
-- ═══════════════════════════════════════════════════════

local function applyBrutalAntiLag()
    state.brutalLagEnabled = true
    print("[VD] Brutal Anti-Lag: APPLYING...")
    
    -- Step 1: Lighting (hormati Fullbright & No Fog)
    pcall(function()
        Lighting.GlobalShadows = false
        
        if SETTINGS.FullbrightEnabled then
            Lighting.Brightness = 3
            Lighting.ClockTime = 14
            Lighting.Ambient = Color3.fromRGB(180, 180, 180)
            Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
        else
            Lighting.Brightness = 0
            Lighting.Ambient = Color3.fromRGB(0, 0, 0)
            Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
        end
        
        if SETTINGS.NoFogEnabled then
            Lighting.FogEnd = 100000
            Lighting.FogStart = 0
        else
            Lighting.FogEnd = 100
            Lighting.FogStart = 0
        end
        
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
    end)
    
    pcall(function()
        if Camera then Camera.FarPlane = 150 end
    end)
    
    pcall(function()
        workspace.Terrain.WaterWaveSize = 0
        workspace.Terrain.WaterWaveSpeed = 0
        workspace.Terrain.WaterReflectance = 0
        workspace.Terrain.WaterTransparency = 1
        workspace.Terrain.Decoration = false
    end)
    
    -- Step 2: Cari karakter player (protected)
    local protectedParts = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            protectedParts[plr.Character] = true
            for _, part in ipairs(plr.Character:GetDescendants()) do
                protectedParts[part] = true
            end
        end
    end
    
    -- Step 3: Iterasi workspace (ASYNC biar gak freeze)
    task.spawn(function()
        local count = 0
        local batch = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            local isProtected = false
            local parent = obj
            while parent and parent ~= workspace do
                if protectedParts[parent] then isProtected = true break end
                parent = parent.Parent
            end
            
            if not isProtected then
                pcall(function()
                    if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                        obj.Enabled = false
                    elseif obj:IsA("Trail") or obj:IsA("Beam") then
                        obj.Enabled = false
                    elseif obj:IsA("Decal") or obj:IsA("Texture") then
                        obj.Transparency = 1
                    elseif obj:IsA("SurfaceAppearance") then
                        obj.AlphaMode = Enum.AlphaMode.Overlay
                        pcall(function() obj.ColorMap = "" end)
                        pcall(function() obj.NormalMap = "" end)
                    elseif obj:IsA("Sky") then
                        obj.Parent = nil
                    elseif obj:IsA("Atmosphere") then
                        obj.Density = 0
                        obj.Haze = 0
                        obj.Glare = 0
                    elseif obj:IsA("Clouds") then
                        obj.Cover = 0
                        obj.Density = 0
                    elseif obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("SunRaysEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("DepthOfFieldEffect") then
                        obj.Enabled = false
                    elseif obj:IsA("BasePart") then
                        obj.CastShadow = false
                        obj.Material = Enum.Material.SmoothPlastic
                    end
                end)
            end
            
            count = count + 1
            batch = batch + 1
            
            if batch >= 500 then
                batch = 0
                task.wait()
            end
        end
        print("[VD] Brutal Anti-Lag: Scanned", count, "objects ✅")
    end)
end

local function resetBrutalAntiLag()
    state.brutalLagEnabled = false
    if state.brutalLagConn then
        pcall(function() state.brutalLagConn:Disconnect() end)
        state.brutalLagConn = nil
    end
    
    pcall(function()
        Lighting.GlobalShadows = true
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
    end)
    
    if Camera then Camera.FarPlane = 100000 end
    
    pcall(function()
        workspace.Terrain.WaterWaveSize = 0.15
        workspace.Terrain.WaterWaveSpeed = 10
        workspace.Terrain.WaterReflectance = 0.1
        workspace.Terrain.WaterTransparency = 0.5
    end)
    
    -- Re-apply Fullbright & No Fog kalau masih aktif
    task.defer(function()
        if SETTINGS.FullbrightEnabled then
            pcall(function()
                Lighting.Brightness = 3
                Lighting.ClockTime = 14
                Lighting.Ambient = Color3.fromRGB(180, 180, 180)
                Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
            end)
        end
        if SETTINGS.NoFogEnabled then
            pcall(function()
                Lighting.FogEnd = 100000
                Lighting.FogStart = 0
            end)
        end
    end)
    
    print("[VD] Brutal Anti-Lag: RESET")
end

-- ═══════════════════════════════════════════════════════
-- SPEED BOOT
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
        local expected = ourSetSpeed or gameBaseSpeed
        if math.abs(current - expected) < 3 then return end
        gameBaseSpeed = current
        local newSpeed = gameBaseSpeed * SETTINGS.SpeedMultiplier
        if math.abs(newSpeed - current) < 0.5 then
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
    if not SETTINGS.SpeedEnabled then gameBaseSpeed = hum.WalkSpeed end
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
-- MISC (HORMATI ANTI-LAG)
-- ═══════════════════════════════════════════════════════

local function applyFullbright()
    if SETTINGS.FullbrightEnabled then
        pcall(function()
            Lighting.Brightness = 3
            Lighting.ClockTime = 14
            Lighting.Ambient = Color3.fromRGB(180, 180, 180)
            Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
        end)
    else
        if state.brutalLagEnabled then
            pcall(function()
                Lighting.Brightness = 0
                Lighting.Ambient = Color3.fromRGB(0, 0, 0)
                Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
            end)
        else
            pcall(function()
                Lighting.Brightness = 1
                Lighting.Ambient = Color3.fromRGB(70, 70, 70)
                Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            end)
        end
    end
end

local function applyNoFog()
    if SETTINGS.NoFogEnabled then
        pcall(function()
            Lighting.FogEnd = 100000
            Lighting.FogStart = 0
        end)
    else
        if state.brutalLagEnabled then
            pcall(function()
                Lighting.FogEnd = 100
                Lighting.FogStart = 0
            end)
        else
            pcall(function()
                Lighting.FogEnd = 1000
                Lighting.FogStart = 0
            end)
        end
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
MainFrame.Size = UDim2.fromOffset(420, 260)
MainFrame.Position = UDim2.fromOffset(40, 80)
MainFrame.BackgroundColor3 = C.bg
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = MainGui

local MFC = Instance.new("UICorner")
MFC.CornerRadius = UDim.new(0, 10)
MFC.Parent = MainFrame

local MFB = Instance.new("UIStroke")
MFB.Color = C.divider
MFB.Thickness = 1
MFB.Transparency = 0.3
MFB.Parent = MainFrame

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = C.panel
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HC = Instance.new("UICorner")
HC.CornerRadius = UDim.new(0, 10)
HC.Parent = Header

local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0, 15)
HeaderFix.Position = UDim2.new(0, 0, 1, -15)
HeaderFix.BackgroundColor3 = C.panel
HeaderFix.BorderSizePixel = 0
HeaderFix.Parent = Header

local LogoIcon = Instance.new("Frame")
LogoIcon.Size = UDim2.fromOffset(20, 20)
LogoIcon.Position = UDim2.fromOffset(10, 5)
LogoIcon.BackgroundColor3 = C.accent
LogoIcon.BorderSizePixel = 0
LogoIcon.Parent = Header

local LIC = Instance.new("UICorner")
LIC.CornerRadius = UDim.new(0, 4)
LIC.Parent = LogoIcon

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, 0, 1, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "V"
LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
LogoText.TextSize = 11
LogoText.Font = Enum.Font.GothamBold
LogoText.Parent = LogoIcon

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(0, 200, 1, 0)
HeaderTitle.Position = UDim2.fromOffset(38, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "VD TOOLS  |  v6"
HeaderTitle.TextColor3 = C.text
HeaderTitle.TextSize = 11
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = Header

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.fromOffset(20, 20)
MinimizeBtn.Position = UDim2.new(1, -60, 0.5, -10)
MinimizeBtn.BackgroundColor3 = C.panelLight
MinimizeBtn.BackgroundTransparency = 0.5
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Text = "−"
MinimizeBtn.TextColor3 = C.textDim
MinimizeBtn.TextSize = 13
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = Header

local MNC = Instance.new("UICorner")
MNC.CornerRadius = UDim.new(1, 0)
MNC.Parent = MinimizeBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.fromOffset(20, 20)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -10)
CloseBtn.BackgroundColor3 = C.danger
CloseBtn.BackgroundTransparency = 0.3
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = C.text
CloseBtn.TextSize = 10
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header

local CBC = Instance.new("UICorner")
CBC.CornerRadius = UDim.new(1, 0)
CBC.Parent = CloseBtn

local Body = Instance.new("Frame")
Body.Size = UDim2.new(1, 0, 1, -30)
Body.Position = UDim2.new(0, 0, 0, 30)
Body.BackgroundTransparency = 1
Body.Parent = MainFrame

local SearchFrame = Instance.new("Frame")
SearchFrame.Size = UDim2.new(0, 160, 0, 26)
SearchFrame.Position = UDim2.fromOffset(12, 12)
SearchFrame.BackgroundColor3 = C.panel
SearchFrame.BorderSizePixel = 0
SearchFrame.Parent = Body

local SFC = Instance.new("UICorner")
SFC.CornerRadius = UDim.new(0, 6)
SFC.Parent = SearchFrame

local SearchIcon = Instance.new("TextLabel")
SearchIcon.Size = UDim2.fromOffset(20, 26)
SearchIcon.Position = UDim2.fromOffset(6, 0)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Text = "🔍"
SearchIcon.TextColor3 = C.textDim
SearchIcon.TextSize = 10
SearchIcon.Font = Enum.Font.Gotham
SearchIcon.Parent = SearchFrame

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -30, 1, 0)
SearchBox.Position = UDim2.fromOffset(28, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.Text = ""
SearchBox.PlaceholderText = "Search..."
SearchBox.PlaceholderColor3 = C.textDim
SearchBox.TextColor3 = C.text
SearchBox.TextSize = 10
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = SearchFrame

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 110, 1, -50)
Sidebar.Position = UDim2.fromOffset(12, 50)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = Body

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -140, 1, -50)
ContentArea.Position = UDim2.fromOffset(128, 50)
ContentArea.BackgroundColor3 = C.panel
ContentArea.BorderSizePixel = 0
ContentArea.Parent = Body

local CAC = Instance.new("UICorner")
CAC.CornerRadius = UDim.new(0, 8)
CAC.Parent = ContentArea

local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(1, -10, 1, -10)
ContentScroll.Position = UDim2.fromOffset(5, 5)
ContentScroll.BackgroundTransparency = 1
ContentScroll.BorderSizePixel = 0
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 500)
ContentScroll.ScrollBarThickness = 3
ContentScroll.ScrollBarImageColor3 = C.accent
ContentScroll.Parent = ContentArea

local categories = {
    {name = "ESP", icon = "👁", id = "esp"},
    {name = "Lag Fix", icon = "⚡", id = "lag"},
    {name = "Player", icon = "🏃", id = "player"},
    {name = "Misc", icon = "⚙", id = "misc"},
}

local sidebarBtns = {}
local currentCat = "esp"

local catContents = {}
for _, cat in ipairs(categories) do
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 500)
    frame.BackgroundTransparency = 1
    frame.Visible = (cat.id == currentCat)
    frame.Parent = ContentScroll
    catContents[cat.id] = frame
end

for i, cat in ipairs(categories) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.fromOffset(0, (i-1) * 34)
    btn.BackgroundColor3 = (cat.id == currentCat) and C.panelLight or C.sidebar
    btn.BackgroundTransparency = (cat.id == currentCat) and 0.2 or 0.5
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.Parent = Sidebar
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.fromOffset(24, 30)
    icon.Position = UDim2.fromOffset(4, 0)
    icon.BackgroundTransparency = 1
    icon.Text = cat.icon
    icon.TextColor3 = (cat.id == currentCat) and C.accent or C.textDim
    icon.TextSize = 12
    icon.Font = Enum.Font.Gotham
    icon.Parent = btn
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.fromOffset(28, 0)
    label.BackgroundTransparency = 1
    label.Text = cat.name
    label.TextColor3 = (cat.id == currentCat) and C.text or C.textDim
    label.TextSize = 10
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = btn
    
    sidebarBtns[cat.id] = {btn = btn, icon = icon, label = label}
    
    btn.MouseButton1Click:Connect(function()
        currentCat = cat.id
        for id, data in pairs(sidebarBtns) do
            if id == cat.id then
                data.btn.BackgroundColor3 = C.panelLight
                data.btn.BackgroundTransparency = 0.2
                data.icon.TextColor3 = C.accent
                data.label.TextColor3 = C.text
                catContents[id].Visible = true
            else
                data.btn.BackgroundColor3 = C.sidebar
                data.btn.BackgroundTransparency = 0.5
                data.icon.TextColor3 = C.textDim
                data.label.TextColor3 = C.textDim
                catContents[id].Visible = false
            end
        end
        ContentScroll.CanvasPosition = Vector2.new(0, 0)
    end)
end

local function makeRow(parent, y, labelText, subText, callback)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, -10, 0, 38)
    row.Position = UDim2.new(0, 5, 0, y)
    row.BackgroundColor3 = C.panelLight
    row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0
    row.Text = ""
    row.Parent = parent
    
    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(0, 6)
    rc.Parent = row
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 0, 18)
    label.Position = UDim2.fromOffset(12, 3)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = C.text
    label.TextSize = 10
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row
    
    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -50, 0, 14)
    sub.Position = UDim2.fromOffset(12, 20)
    sub.BackgroundTransparency = 1
    sub.Text = subText or ""
    sub.TextColor3 = C.textDim
    sub.TextSize = 8
    sub.Font = Enum.Font.Gotham
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Parent = row
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.fromOffset(20, 38)
    arrow.Position = UDim2.new(1, -24, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = ">"
    arrow.TextColor3 = C.textDim
    arrow.TextSize = 12
    arrow.Font = Enum.Font.GothamBold
    arrow.Parent = row
    
    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.fromOffset(8, 8)
    statusDot.Position = UDim2.new(1, -34, 0.5, -4)
    statusDot.BackgroundColor3 = C.textDim
    statusDot.BorderSizePixel = 0
    statusDot.Parent = row
    
    local SDC = Instance.new("UICorner")
    SDC.CornerRadius = UDim.new(1, 0)
    SDC.Parent = statusDot
    
    row.MouseButton1Click:Connect(function()
        if callback then callback(row, statusDot) end
    end)
    
    return {row = row, statusDot = statusDot}
end

-- ═══════════════════════════════════════════════════════
-- TAB: ESP
-- ═══════════════════════════════════════════════════════

local espFrame = catContents["esp"]
local espY = 5

local espToggle = makeRow(espFrame, espY, "ESP Aktif", "Nampilin kotak & info pemain", function(row, dot)
    state.espEnabled = not state.espEnabled
    dot.BackgroundColor3 = state.espEnabled and C.success or C.textDim
    if state.espEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then createESP(player) end
        end
    end
end)
espToggle.statusDot.BackgroundColor3 = state.espEnabled and C.success or C.textDim
espY = espY + 42

local boxToggle = makeRow(espFrame, espY, "Kotak Highlight", "Warna kotak di pemain", function(row, dot)
    SETTINGS.ShowBox = not SETTINGS.ShowBox
    dot.BackgroundColor3 = SETTINGS.ShowBox and C.success or C.textDim
end)
boxToggle.statusDot.BackgroundColor3 = SETTINGS.ShowBox and C.success or C.textDim
espY = espY + 42

local roleToggle = makeRow(espFrame, espY, "Role", "Tampilkan KILLER/SURVIVOR", function(row, dot)
    SETTINGS.ShowRole = not SETTINGS.ShowRole
    dot.BackgroundColor3 = SETTINGS.ShowRole and C.success or C.textDim
end)
roleToggle.statusDot.BackgroundColor3 = SETTINGS.ShowRole and C.success or C.textDim
espY = espY + 42

local nameToggle = makeRow(espFrame, espY, "Nama", "Tampilkan nama pemain", function(row, dot)
    SETTINGS.ShowName = not SETTINGS.ShowName
    dot.BackgroundColor3 = SETTINGS.ShowName and C.success or C.textDim
end)
nameToggle.statusDot.BackgroundColor3 = SETTINGS.ShowName and C.success or C.textDim
espY = espY + 42

local distToggle = makeRow(espFrame, espY, "Jarak", "Tampilkan jarak (meter)", function(row, dot)
    SETTINGS.ShowDistance = not SETTINGS.ShowDistance
    dot.BackgroundColor3 = SETTINGS.ShowDistance and C.success or C.textDim
end)
distToggle.statusDot.BackgroundColor3 = SETTINGS.ShowDistance and C.success or C.textDim
espY = espY + 42

local hpToggle = makeRow(espFrame, espY, "Darah", "Tampilkan HP pemain", function(row, dot)
    SETTINGS.ShowHealth = not SETTINGS.ShowHealth
    dot.BackgroundColor3 = SETTINGS.ShowHealth and C.success or C.textDim
end)
hpToggle.statusDot.BackgroundColor3 = SETTINGS.ShowHealth and C.success or C.textDim
espY = espY + 48

local filterLbl = Instance.new("TextLabel")
filterLbl.Size = UDim2.new(1, -10, 0, 16)
filterLbl.Position = UDim2.new(0, 5, 0, espY)
filterLbl.BackgroundTransparency = 1
filterLbl.Text = "FILTER ROLE"
filterLbl.TextColor3 = C.textDim
filterLbl.TextSize = 8
filterLbl.Font = Enum.Font.GothamBold
filterLbl.TextXAlignment = Enum.TextXAlignment.Left
filterLbl.Parent = espFrame
espY = espY + 20

local filterBtns = {}
local function updateFilterBtns()
    for role, btn in pairs(filterBtns) do
        if SETTINGS.FilterRole == role then
            btn.BackgroundColor3 = C.accent
            btn.BackgroundTransparency = 0.2
            btn.TextColor3 = C.text
        else
            btn.BackgroundColor3 = C.panelLight
            btn.BackgroundTransparency = 0.5
            btn.TextColor3 = C.textDim
        end
    end
end

local function makeFilterBtn(text, xPos, role)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.31, 0, 0, 24)
    btn.Position = UDim2.new(xPos, 0, 0, espY)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextSize = 8
    btn.Font = Enum.Font.GothamBold
    btn.Parent = espFrame
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 5)
    c.Parent = btn
    filterBtns[role] = btn
    btn.MouseButton1Click:Connect(function()
        SETTINGS.FilterRole = role
        updateFilterBtns()
    end)
end

makeFilterBtn("SEMUA", 0.01, "both")
makeFilterBtn("KILLER", 0.345, "killer")
makeFilterBtn("SURVIVOR", 0.68, "survivor")
updateFilterBtns()
espY = espY + 30

local markBtn = Instance.new("TextButton")
markBtn.Size = UDim2.new(1, -10, 0, 30)
markBtn.Position = UDim2.new(0, 5, 0, espY)
markBtn.BackgroundColor3 = C.danger
markBtn.BackgroundTransparency = 0.3
markBtn.BorderSizePixel = 0
markBtn.Text = "TANDAI PEMAIN TERDEKAT"
markBtn.TextColor3 = C.text
markBtn.TextSize = 9
markBtn.Font = Enum.Font.GothamBold
markBtn.Parent = espFrame
local MBC = Instance.new("UICorner")
MBC.CornerRadius = UDim.new(0, 6)
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
-- TAB: LAG (ONE-CLICK BRUTAL)
-- ═══════════════════════════════════════════════════════

local lagFrame = catContents["lag"]

local infoBox = Instance.new("Frame")
infoBox.Size = UDim2.new(1, -10, 0, 70)
infoBox.Position = UDim2.new(0, 5, 0, 5)
infoBox.BackgroundColor3 = C.panelLight
infoBox.BackgroundTransparency = 0.3
infoBox.BorderSizePixel = 0
infoBox.Parent = lagFrame

local IBC = Instance.new("UICorner")
IBC.CornerRadius = UDim.new(0, 6)
IBC.Parent = infoBox

local infoTitle = Instance.new("TextLabel")
infoTitle.Size = UDim2.new(1, -20, 0, 18)
infoTitle.Position = UDim2.fromOffset(10, 6)
infoTitle.BackgroundTransparency = 1
infoTitle.Text = "BRUTAL ANTI-LAG"
infoTitle.TextColor3 = C.warning
infoTitle.TextSize = 11
infoTitle.Font = Enum.Font.GothamBold
infoTitle.TextXAlignment = Enum.TextXAlignment.Left
infoTitle.Parent = infoBox

local infoSub = Instance.new("TextLabel")
infoSub.Size = UDim2.new(1, -20, 0, 42)
infoSub.Position = UDim2.fromOffset(10, 24)
infoSub.BackgroundTransparency = 1
infoSub.Text = "Hapus semua efek, shadow, texture,\nparticle, decal. Khusus HP kentang.\nAnti-lag hormati Fullbright & No Fog."
infoSub.TextColor3 = C.textDim
infoSub.TextSize = 9
infoSub.Font = Enum.Font.Gotham
infoSub.TextXAlignment = Enum.TextXAlignment.Left
infoSub.TextYAlignment = Enum.TextYAlignment.Top
infoSub.TextWrapped = true
infoSub.Parent = infoBox

local brutalBtn = Instance.new("TextButton")
brutalBtn.Size = UDim2.new(1, -10, 0, 60)
brutalBtn.Position = UDim2.new(0, 5, 0, 85)
brutalBtn.BackgroundColor3 = C.danger
brutalBtn.BackgroundTransparency = 0.2
brutalBtn.BorderSizePixel = 0
brutalBtn.Text = "⚡ BRUTAL ANTI-LAG: OFF ⚡"
brutalBtn.TextColor3 = C.text
brutalBtn.TextSize = 12
brutalBtn.Font = Enum.Font.GothamBold
brutalBtn.Parent = lagFrame

local BBC = Instance.new("UICorner")
BBC.CornerRadius = UDim.new(0, 8)
BBC.Parent = brutalBtn

local brutalSub = Instance.new("TextLabel")
brutalSub.Size = UDim2.new(1, -20, 0, 14)
brutalSub.Position = UDim2.new(0, 10, 1, -18)
brutalSub.BackgroundTransparency = 1
brutalSub.Text = "Klik 1x → semua lag fix nyala"
brutalSub.TextColor3 = C.textDim
brutalSub.TextSize = 8
brutalSub.Font = Enum.Font.Gotham
brutalSub.TextXAlignment = Enum.TextXAlignment.Left
brutalSub.Parent = brutalBtn

-- ⭐ TOGGLE FUNCTION
local toggleBrutal = function()
    if not state.brutalLagEnabled then
        -- Update UI DULU (instan)
        brutalBtn.Text = "⚡ BRUTAL ANTI-LAG: ON ⚡"
        brutalBtn.BackgroundColor3 = C.success
        brutalSub.Text = "SEMUA fix aktif — HP ringan"
        
        -- Apply di background
        task.spawn(function()
            pcall(applyBrutalAntiLag)
        end)
        
        print("[VD] Brutal: ON clicked")
    else
        brutalBtn.Text = "⚡ BRUTAL ANTI-LAG: OFF ⚡"
        brutalBtn.BackgroundColor3 = C.danger
        brutalSub.Text = "Klik 1x → semua lag fix nyala"
        
        task.spawn(function()
            pcall(resetBrutalAntiLag)
        end)
        
        print("[VD] Brutal: OFF clicked")
    end
end

-- ⭐ Pake Activated (mobile + PC)
brutalBtn.Activated:Connect(toggleBrutal)

local tipsBox = Instance.new("Frame")
tipsBox.Size = UDim2.new(1, -10, 0, 100)
tipsBox.Position = UDim2.new(0, 5, 0, 155)
tipsBox.BackgroundColor3 = C.panelLight
tipsBox.BackgroundTransparency = 0.5
tipsBox.BorderSizePixel = 0
tipsBox.Parent = lagFrame

local TBC = Instance.new("UICorner")
TBC.CornerRadius = UDim.new(0, 6)
TBC.Parent = tipsBox

local tipsLabel = Instance.new("TextLabel")
tipsLabel.Size = UDim2.new(1, -20, 1, -10)
tipsLabel.Position = UDim2.fromOffset(10, 5)
tipsLabel.BackgroundTransparency = 1
tipsLabel.Text = "TIPS HP KENTANG:\n• Matiin shadow device\n• Kecilin brightness HP\n• Tutup app lain\n• Wifi stabil > data\n• Jangan sampe baterai <20%"
tipsLabel.TextColor3 = C.textDim
tipsLabel.TextSize = 8
tipsLabel.Font = Enum.Font.Gotham
tipsLabel.TextXAlignment = Enum.TextXAlignment.Left
tipsLabel.TextYAlignment = Enum.TextYAlignment.Top
tipsLabel.TextWrapped = true
tipsLabel.Parent = tipsBox

-- ═══════════════════════════════════════════════════════
-- TAB: PLAYER
-- ═══════════════════════════════════════════════════════

local playerFrame = catContents["player"]
local playerY = 5

local speedToggle = makeRow(playerFrame, playerY, "Speed Boot", "Boost " .. string.format("%.2fx", SETTINGS.SpeedMultiplier), function(row, dot)
    SETTINGS.SpeedEnabled = not SETTINGS.SpeedEnabled
    dot.BackgroundColor3 = SETTINGS.SpeedEnabled and C.success or C.textDim
    applyPlayerMods()
end)
speedToggle.statusDot.BackgroundColor3 = SETTINGS.SpeedEnabled and C.success or C.textDim
playerY = playerY + 46

local presetLbl = Instance.new("TextLabel")
presetLbl.Size = UDim2.new(1, -10, 0, 16)
presetLbl.Position = UDim2.new(0, 5, 0, playerY)
presetLbl.BackgroundTransparency = 1
presetLbl.Text = "MULTIPLIER"
presetLbl.TextColor3 = C.textDim
presetLbl.TextSize = 8
presetLbl.Font = Enum.Font.GothamBold
presetLbl.TextXAlignment = Enum.TextXAlignment.Left
presetLbl.Parent = playerFrame
playerY = playerY + 20

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
            data.btn.BackgroundColor3 = C.accent
            data.btn.BackgroundTransparency = 0.2
            data.btn.TextColor3 = C.text
        else
            data.btn.BackgroundColor3 = C.panelLight
            data.btn.BackgroundTransparency = 0.5
            data.btn.TextColor3 = C.textDim
        end
    end
end

for i, data in ipairs(presets) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.235, 0, 0, 24)
    btn.Position = UDim2.new(0.01 + (i-1) * 0.245, 0, 0, playerY)
    btn.BorderSizePixel = 0
    btn.Text = data.label
    btn.TextSize = 8
    btn.Font = Enum.Font.GothamBold
    btn.Parent = playerFrame
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 5)
    c.Parent = btn
    table.insert(presetBtns, {btn = btn, value = data.value})
    btn.MouseButton1Click:Connect(function()
        SETTINGS.SpeedMultiplier = data.value
        updatePresetHighlight()
        applyPlayerMods()
    end)
end
updatePresetHighlight()
playerY = playerY + 32

local jumpContainer = Instance.new("Frame")
jumpContainer.Size = UDim2.new(1, -10, 0, 40)
jumpContainer.Position = UDim2.new(0, 5, 0, playerY)
jumpContainer.BackgroundColor3 = C.panelLight
jumpContainer.BackgroundTransparency = 0.3
jumpContainer.BorderSizePixel = 0
jumpContainer.Parent = playerFrame

local JCC = Instance.new("UICorner")
JCC.CornerRadius = UDim.new(0, 6)
JCC.Parent = jumpContainer

local jumpLabel = Instance.new("TextLabel")
jumpLabel.Size = UDim2.new(1, -20, 0, 16)
jumpLabel.Position = UDim2.fromOffset(12, 4)
jumpLabel.BackgroundTransparency = 1
jumpLabel.Text = "Jump Power: " .. SETTINGS.JumpPower
jumpLabel.TextColor3 = C.text
jumpLabel.TextSize = 9
jumpLabel.Font = Enum.Font.Gotham
jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
jumpLabel.Parent = jumpContainer

local jumpSliderBg = Instance.new("Frame")
jumpSliderBg.Size = UDim2.new(1, -24, 0, 6)
jumpSliderBg.Position = UDim2.new(0, 12, 0, 24)
jumpSliderBg.BackgroundColor3 = C.divider
jumpSliderBg.BorderSizePixel = 0
jumpSliderBg.Parent = jumpContainer

local JSBC = Instance.new("UICorner")
JSBC.CornerRadius = UDim.new(1, 0)
JSBC.Parent = jumpSliderBg

local jumpFill = Instance.new("Frame")
jumpFill.Size = UDim2.new((SETTINGS.JumpPower - 50) / 150, 0, 1, 0)
jumpFill.BackgroundColor3 = C.accent
jumpFill.BorderSizePixel = 0
jumpFill.Parent = jumpSliderBg

local JFC = Instance.new("UICorner")
JFC.CornerRadius = UDim.new(1, 0)
JFC.Parent = jumpFill

local jumpKnob = Instance.new("TextButton")
jumpKnob.Size = UDim2.fromOffset(14, 14)
jumpKnob.Position = UDim2.new((SETTINGS.JumpPower - 50) / 150, -7, 0.5, -7)
jumpKnob.BackgroundColor3 = C.text
jumpKnob.BorderSizePixel = 0
jumpKnob.Text = ""
jumpKnob.Parent = jumpSliderBg

local JKC = Instance.new("UICorner")
JKC.CornerRadius = UDim.new(1, 0)
JKC.Parent = jumpKnob

local jumpDragging = false
local function updateJump(input)
    local pos = jumpSliderBg.AbsolutePosition.X
    local size = jumpSliderBg.AbsoluteSize.X
    local percent = math.clamp((input.Position.X - pos) / size, 0, 1)
    local value = math.floor(50 + percent * 150)
    SETTINGS.JumpPower = value
    jumpFill.Size = UDim2.new(percent, 0, 1, 0)
    jumpKnob.Position = UDim2.new(percent, -7, 0.5, -7)
    jumpLabel.Text = "Jump Power: " .. value
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.JumpPower = value
            hum.UseJumpPower = true
        end
    end
end

jumpKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        jumpDragging = true
        updateJump(input)
    end
end)

state.connections[#state.connections+1] = UserInputService.InputChanged:Connect(function(input)
    if jumpDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        updateJump(input)
    end
end)

state.connections[#state.connections+1] = UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        jumpDragging = false
    end
end)

playerY = playerY + 46

local antiFlingRow = makeRow(playerFrame, playerY, "Anti-Fling", "Cegah diputar/lempar", function(row, dot)
    SETTINGS.AntiFlingEnabled = not SETTINGS.AntiFlingEnabled
    dot.BackgroundColor3 = SETTINGS.AntiFlingEnabled and C.success or C.textDim
end)
antiFlingRow.statusDot.BackgroundColor3 = SETTINGS.AntiFlingEnabled and C.success or C.textDim
playerY = playerY + 42

local infJumpRow = makeRow(playerFrame, playerY, "Infinite Jump", "Lompat di udara", function(row, dot)
    SETTINGS.InfJumpEnabled = not SETTINGS.InfJumpEnabled
    dot.BackgroundColor3 = SETTINGS.InfJumpEnabled and C.success or C.textDim
end)
infJumpRow.statusDot.BackgroundColor3 = SETTINGS.InfJumpEnabled and C.success or C.textDim

-- ═══════════════════════════════════════════════════════
-- TAB: MISC
-- ═══════════════════════════════════════════════════════

local miscFrame = catContents["misc"]
local miscY = 5

local fbRow = makeRow(miscFrame, miscY, "Fullbright", "Terangin seluruh map", function(row, dot)
    SETTINGS.FullbrightEnabled = not SETTINGS.FullbrightEnabled
    dot.BackgroundColor3 = SETTINGS.FullbrightEnabled and C.success or C.textDim
    applyFullbright()
end)
fbRow.statusDot.BackgroundColor3 = SETTINGS.FullbrightEnabled and C.success or C.textDim
miscY = miscY + 42

local fogRow = makeRow(miscFrame, miscY, "No Fog", "Hilangkan kabut", function(row, dot)
    SETTINGS.NoFogEnabled = not SETTINGS.NoFogEnabled
    dot.BackgroundColor3 = SETTINGS.NoFogEnabled and C.success or C.textDim
    applyNoFog()
end)
fogRow.statusDot.BackgroundColor3 = SETTINGS.NoFogEnabled and C.success or C.textDim
miscY = miscY + 42

local afkRow = makeRow(miscFrame, miscY, "Anti-AFK", "Biar gak di-kick", function(row, dot)
    state.antiAfkEnabled = not state.antiAfkEnabled
    dot.BackgroundColor3 = state.antiAfkEnabled and C.success or C.textDim
end)
afkRow.statusDot.BackgroundColor3 = state.antiAfkEnabled and C.success or C.textDim

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

local minimized = false
state.connections[#state.connections+1] = MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Body.Visible = not minimized
    MainFrame.Size = minimized and UDim2.fromOffset(420, 30) or UDim2.fromOffset(420, 260)
    MinimizeBtn.Text = minimized and "+" or "−"
end)

state.connections[#state.connections+1] = CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    if not MainGui:FindFirstChild("ShowBtn") then
        local showBtn = Instance.new("TextButton")
        showBtn.Name = "ShowBtn"
        showBtn.Size = UDim2.fromOffset(44, 44)
        showBtn.Position = UDim2.fromOffset(40, 80)
        showBtn.BackgroundColor3 = C.bg
        showBtn.BorderSizePixel = 0
        showBtn.Text = "VD"
        showBtn.TextColor3 = C.accent
        showBtn.TextSize = 12
        showBtn.Font = Enum.Font.GothamBold
        showBtn.Active = true
        showBtn.Draggable = true
        showBtn.Parent = MainGui
        local sc = Instance.new("UICorner")
        sc.CornerRadius = UDim.new(0, 10)
        sc.Parent = showBtn
        local s = Instance.new("UIStroke")
        s.Color = C.accent
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

print("[VD TOOLS v6] Loaded!")
print("[VD TOOLS v6] Brutal Anti-Lag: 1 Click (Hormati Fullbright & No Fog)")
