-- [[ SIMPLE ESP v6 — KILLER vs SURVIVOR ]]
-- UI Redesign: Soft Color, Comfortable Font, Clean Layout

local env = (getgenv and getgenv()) or _G
for _, name in ipairs({"SimpleESP_KillerSurvivor"}) do
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
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local state = {
    running = true,
    enabled = true,
    connections = {},
    guis = {},
    esps = {},
    manualKiller = {},
    manualSurvivor = {},
}
env.SimpleESP_KillerSurvivor = state

-- ⭐ COLOR PALETTE (SOFT)
local COLORS = {
    bg = Color3.fromRGB(28, 32, 42),           -- Background gelap soft
    panel = Color3.fromRGB(38, 44, 58),        -- Panel
    panelHover = Color3.fromRGB(48, 56, 72),   -- Panel hover
    text = Color3.fromRGB(230, 235, 245),      -- Text putih soft
    textDim = Color3.fromRGB(150, 160, 180),   -- Text secondary
    accent = Color3.fromRGB(120, 150, 220),    -- Biru soft (bukan neon)
    success = Color3.fromRGB(95, 200, 130),    -- Hijau soft
    danger = Color3.fromRGB(220, 100, 100),    -- Merah soft
    warning = Color3.fromRGB(240, 180, 80),    -- Kuning soft
    divider = Color3.fromRGB(55, 62, 80),      -- Garis pemisah
    border = Color3.fromRGB(70, 80, 105),      -- Border
}

local SETTINGS = {
    MaxDistance = 1000,
    UpdateRate = 0.1,
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
}

local function getRole(player)
    if state.manualKiller[player.Name] then return "killer" end
    if state.manualSurvivor[player.Name] then return "survivor" end
    
    if player.Team then
        local teamName = player.Team.Name:lower()
        if teamName:find("killer") or teamName:find("murder") or teamName:find("hunter") then
            return "killer"
        end
        if teamName:find("survivor") or teamName:find("innocent") or teamName:find("runner") then
            return "survivor"
        end
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
        local ok2, role2 = pcall(function()
            return char:GetAttribute("Role") or char:GetAttribute("role")
        end)
        if ok2 and role2 then
            local r = tostring(role2):lower()
            if r:find("killer") or r:find("murder") then return "killer" end
            if r:find("survivor") or r:find("innocent") then return "survivor" end
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
    if data.Highlight then 
        pcall(function() 
            data.Highlight.Enabled = false
            data.Highlight.Adornee = nil
            data.Highlight:Destroy() 
        end) 
    end
    if data.Billboard then 
        pcall(function() 
            data.Billboard.Enabled = false
            data.Billboard.Adornee = nil
            data.Billboard:Destroy() 
        end) 
    end
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
    roleLabel.Position = UDim2.new(0, 0, 0, 0)
    roleLabel.BackgroundTransparency = 1
    roleLabel.Text = "?"
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
    distanceLabel.Text = "0m"
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
    healthLabel.Text = "100 HP"
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
    if not state.enabled then
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
                data.HealthLabel.TextColor3 = Color3.fromRGB(
                    255 * (1 - hpPercent),
                    255 * hpPercent,
                    100
                )
                data.HealthLabel.Visible = SETTINGS.ShowHealth
            end
        else
            data.Highlight.Enabled = false
            data.Billboard.Enabled = false
        end
    end
end

state.connections[#state.connections+1] = Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if state.enabled then createESP(player) end
    end)
    if player.Character and state.enabled then createESP(player) end
end)

state.connections[#state.connections+1] = Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then createESP(player) end
end

-- ⭐ GUI REDESIGN
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local oldGui = playerGui:FindFirstChild("ESPControlGui")
if oldGui then oldGui:Destroy() end

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "ESPControlGui"
MainGui.ResetOnSpawn = false
MainGui.DisplayOrder = 1000
MainGui.Parent = playerGui
state.guis[#state.guis+1] = MainGui

-- ⭐ MAIN PANEL (compact + clean)
local ControlFrame = Instance.new("Frame")
ControlFrame.Size = UDim2.fromOffset(150, 92)
ControlFrame.Position = UDim2.fromOffset(16, 100)
ControlFrame.BackgroundColor3 = COLORS.bg
ControlFrame.BackgroundTransparency = 0.05
ControlFrame.BorderSizePixel = 0
ControlFrame.Active = true
ControlFrame.Draggable = true
ControlFrame.Parent = MainGui

local CF = Instance.new("UICorner")
CF.CornerRadius = UDim.new(0, 12)
CF.Parent = ControlFrame

local CF2 = Instance.new("UIStroke")
CF2.Color = COLORS.border
CF2.Thickness = 1
CF2.Transparency = 0.5
CF2.Parent = ControlFrame

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 26)
Header.BackgroundColor3 = COLORS.panel
Header.BorderSizePixel = 0
Header.Parent = ControlFrame

local HCR = Instance.new("UICorner")
HCR.CornerRadius = UDim.new(0, 12)
HCR.Parent = Header

-- Fix bottom corners of header
local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0, 12)
HeaderFix.Position = UDim2.new(0, 0, 1, -12)
HeaderFix.BackgroundColor3 = COLORS.panel
HeaderFix.BorderSizePixel = 0
HeaderFix.Parent = Header

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(1, -40, 1, 0)
HeaderTitle.Position = UDim2.fromOffset(12, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "ESP"
HeaderTitle.TextColor3 = COLORS.text
HeaderTitle.TextSize = 12
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = Header

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.fromOffset(8, 8)
StatusDot.Position = UDim2.new(1, -50, 0.5, -4)
StatusDot.BackgroundColor3 = COLORS.success
StatusDot.BorderSizePixel = 0
StatusDot.Parent = Header

local SDC = Instance.new("UICorner")
SDC.CornerRadius = UDim.new(1, 0)
SDC.Parent = StatusDot

local HideBtn = Instance.new("TextButton")
HideBtn.Size = UDim2.fromOffset(18, 18)
HideBtn.Position = UDim2.new(1, -24, 0.5, -9)
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

-- Toggle button (full width)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 26)
ToggleBtn.Position = UDim2.new(0.05, 0, 0, 32)
ToggleBtn.BackgroundColor3 = COLORS.success
ToggleBtn.BackgroundTransparency = 0.15
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Text = "AKTIF"
ToggleBtn.TextColor3 = COLORS.text
ToggleBtn.TextSize = 11
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Parent = ControlFrame

local TB = Instance.new("UICorner")
TB.CornerRadius = UDim.new(0, 8)
TB.Parent = ToggleBtn

-- Settings + Mark (row)
local SettingsBtn = Instance.new("TextButton")
SettingsBtn.Size = UDim2.new(0.43, 0, 0, 24)
SettingsBtn.Position = UDim2.new(0.05, 0, 0, 62)
SettingsBtn.BackgroundColor3 = COLORS.accent
SettingsBtn.BackgroundTransparency = 0.15
SettingsBtn.BorderSizePixel = 0
SettingsBtn.Text = "PENGATURAN"
SettingsBtn.TextColor3 = COLORS.text
SettingsBtn.TextSize = 8
SettingsBtn.Font = Enum.Font.GothamBold
SettingsBtn.Parent = ControlFrame

local STB = Instance.new("UICorner")
STB.CornerRadius = UDim.new(0, 7)
STB.Parent = SettingsBtn

local MarkBtn = Instance.new("TextButton")
MarkBtn.Size = UDim2.new(0.43, 0, 0, 24)
MarkBtn.Position = UDim2.new(0.52, 0, 0, 62)
MarkBtn.BackgroundColor3 = COLORS.danger
MarkBtn.BackgroundTransparency = 0.15
MarkBtn.BorderSizePixel = 0
MarkBtn.Text = "TANDAI"
MarkBtn.TextColor3 = COLORS.text
MarkBtn.TextSize = 8
MarkBtn.Font = Enum.Font.GothamBold
MarkBtn.Parent = ControlFrame

local MB = Instance.new("UICorner")
MB.CornerRadius = UDim.new(0, 7)
MB.Parent = MarkBtn

-- ⭐ SETTINGS PANEL (redesign)
local SettingsPanel = Instance.new("Frame")
SettingsPanel.Size = UDim2.fromOffset(190, 300)
SettingsPanel.Position = UDim2.fromOffset(180, 100)
SettingsPanel.BackgroundColor3 = COLORS.bg
SettingsPanel.BackgroundTransparency = 0.05
SettingsPanel.BorderSizePixel = 0
SettingsPanel.Visible = false
SettingsPanel.Active = true
SettingsPanel.Draggable = true
SettingsPanel.Parent = MainGui

local SPF = Instance.new("UICorner")
SPF.CornerRadius = UDim.new(0, 12)
SPF.Parent = SettingsPanel

local SPF2 = Instance.new("UIStroke")
SPF2.Color = COLORS.border
SPF2.Thickness = 1
SPF2.Transparency = 0.5
SPF2.Parent = SettingsPanel

-- Settings Header
local SPHeader = Instance.new("Frame")
SPHeader.Size = UDim2.new(1, 0, 0, 30)
SPHeader.BackgroundColor3 = COLORS.panel
SPHeader.BorderSizePixel = 0
SPHeader.Parent = SettingsPanel

local SPHC = Instance.new("UICorner")
SPHC.CornerRadius = UDim.new(0, 12)
SPHC.Parent = SPHeader

local SPHeaderFix = Instance.new("Frame")
SPHeaderFix.Size = UDim2.new(1, 0, 0, 15)
SPHeaderFix.Position = UDim2.new(0, 0, 1, -15)
SPHeaderFix.BackgroundColor3 = COLORS.panel
SPHeaderFix.BorderSizePixel = 0
SPHeaderFix.Parent = SPHeader

local SPHeaderTitle = Instance.new("TextLabel")
SPHeaderTitle.Size = UDim2.new(1, -16, 1, 0)
SPHeaderTitle.Position = UDim2.fromOffset(14, 0)
SPHeaderTitle.BackgroundTransparency = 1
SPHeaderTitle.Text = "PENGATURAN TAMPILAN"
SPHeaderTitle.TextColor3 = COLORS.text
SPHeaderTitle.TextSize = 10
SPHeaderTitle.Font = Enum.Font.GothamBold
SPHeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
SPHeaderTitle.Parent = SPHeader

-- ⭐ TOGGLE HELPER (clean design)
local function makeToggle(y, labelText, key)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.88, 0, 0, 28)
    Btn.Position = UDim2.new(0.06, 0, 0, y)
    Btn.BackgroundColor3 = SETTINGS[key] and COLORS.success or COLORS.panel
    Btn.BackgroundTransparency = SETTINGS[key] and 0.2 or 0.3
    Btn.BorderSizePixel = 0
    Btn.Text = ""
    Btn.Parent = SettingsPanel
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = Btn
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.fromOffset(12, 0)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.TextColor3 = COLORS.text
    Label.TextSize = 10
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Btn
    
    local StateLabel = Instance.new("TextLabel")
    StateLabel.Size = UDim2.fromOffset(36, 16)
    StateLabel.Position = UDim2.new(1, -42, 0.5, -8)
    StateLabel.BackgroundColor3 = SETTINGS[key] and COLORS.success or COLORS.divider
    StateLabel.BackgroundTransparency = 0.2
    StateLabel.BorderSizePixel = 0
    StateLabel.Text = SETTINGS[key] and "ON" or "OFF"
    StateLabel.TextColor3 = COLORS.text
    StateLabel.TextSize = 8
    StateLabel.Font = Enum.Font.GothamBold
    StateLabel.Parent = Btn
    
    local SLC = Instance.new("UICorner")
    SLC.CornerRadius = UDim.new(0, 4)
    SLC.Parent = StateLabel
    
    Btn.MouseButton1Click:Connect(function()
        SETTINGS[key] = not SETTINGS[key]
        Btn.BackgroundColor3 = SETTINGS[key] and COLORS.success or COLORS.panel
        Btn.BackgroundTransparency = SETTINGS[key] and 0.2 or 0.3
        StateLabel.Text = SETTINGS[key] and "ON" or "OFF"
        StateLabel.BackgroundColor3 = SETTINGS[key] and COLORS.success or COLORS.divider
    end)
end

makeToggle(38, "Kotak Highlight", "ShowBox")
makeToggle(70, "Role (Killer/Survivor)", "ShowRole")
makeToggle(102, "Nama Pemain", "ShowName")
makeToggle(134, "Jarak", "ShowDistance")
makeToggle(166, "Darah (HP)", "ShowHealth")

-- Divider
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0.88, 0, 0, 1)
Divider.Position = UDim2.new(0.06, 0, 0, 202)
Divider.BackgroundColor3 = COLORS.divider
Divider.BorderSizePixel = 0
Divider.Parent = SettingsPanel

-- Filter Label
local FilterLabel = Instance.new("TextLabel")
FilterLabel.Size = UDim2.new(0.88, 0, 0, 16)
FilterLabel.Position = UDim2.new(0.06, 0, 0, 210)
FilterLabel.BackgroundTransparency = 1
FilterLabel.Text = "FILTER ROLE"
FilterLabel.TextColor3 = COLORS.textDim
FilterLabel.TextSize = 9
FilterLabel.Font = Enum.Font.GothamBold
FilterLabel.TextXAlignment = Enum.TextXAlignment.Left
FilterLabel.Parent = SettingsPanel

-- Filter buttons
local FilterBtns = {}
local function updateFilterButtons()
    for role, btn in pairs(FilterBtns) do
        if SETTINGS.FilterRole == role then
            btn.BackgroundColor3 = COLORS.accent
            btn.BackgroundTransparency = 0.15
            btn.TextColor3 = COLORS.text
        else
            btn.BackgroundColor3 = COLORS.panel
            btn.BackgroundTransparency = 0.4
            btn.TextColor3 = COLORS.textDim
        end
    end
end

local function makeFilterBtn(text, xPos, role)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.28, 0, 0, 26)
    Btn.Position = UDim2.new(xPos, 0, 0, 230)
    Btn.BorderSizePixel = 0
    Btn.Text = text
    Btn.TextSize = 9
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = SettingsPanel
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = Btn
    
    FilterBtns[role] = Btn
    
    Btn.MouseButton1Click:Connect(function()
        SETTINGS.FilterRole = role
        updateFilterButtons()
    end)
end

makeFilterBtn("SEMUA", 0.06, "both")
makeFilterBtn("KILLER", 0.36, "killer")
makeFilterBtn("SURVIVOR", 0.66, "survivor")

updateFilterButtons()

-- Info
local InfoFilter = Instance.new("TextLabel")
InfoFilter.Size = UDim2.new(0.88, 0, 0, 30)
InfoFilter.Position = UDim2.new(0.06, 0, 0, 262)
InfoFilter.BackgroundTransparency = 1
InfoFilter.Text = "Cuma nampilin role yang dipilih"
InfoFilter.TextColor3 = COLORS.textDim
InfoFilter.TextSize = 8
InfoFilter.Font = Enum.Font.Gotham
InfoFilter.TextWrapped = true
InfoFilter.TextYAlignment = Enum.TextYAlignment.Top
InfoFilter.TextXAlignment = Enum.TextXAlignment.Center
InfoFilter.Parent = SettingsPanel

-- Show button (mini)
local ShowBtn = Instance.new("TextButton")
ShowBtn.Size = UDim2.fromOffset(40, 40)
ShowBtn.Position = UDim2.fromOffset(16, 100)
ShowBtn.BackgroundColor3 = COLORS.bg
ShowBtn.BackgroundTransparency = 0.05
ShowBtn.BorderSizePixel = 0
ShowBtn.Text = "ESP"
ShowBtn.TextColor3 = COLORS.accent
ShowBtn.TextSize = 11
ShowBtn.Font = Enum.Font.GothamBold
ShowBtn.Visible = false
ShowBtn.Active = true
ShowBtn.Draggable = true
ShowBtn.Parent = MainGui

local SBC = Instance.new("UICorner")
SBC.CornerRadius = UDim.new(0, 12)
SBC.Parent = ShowBtn

local SBStroke = Instance.new("UIStroke")
SBStroke.Color = COLORS.accent
SBStroke.Thickness = 1
SBStroke.Transparency = 0.3
SBStroke.Parent = ShowBtn

-- Events
state.connections[#state.connections+1] = ToggleBtn.MouseButton1Click:Connect(function()
    state.enabled = not state.enabled
    if state.enabled then
        ToggleBtn.Text = "AKTIF"
        ToggleBtn.BackgroundColor3 = COLORS.success
        StatusDot.BackgroundColor3 = COLORS.success
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then createESP(player) end
        end
    else
        ToggleBtn.Text = "MATI"
        ToggleBtn.BackgroundColor3 = COLORS.danger
        StatusDot.BackgroundColor3 = COLORS.danger
        for _, player in ipairs(Players:GetPlayers()) do
            removeESP(player)
        end
    end
end)

state.connections[#state.connections+1] = SettingsBtn.MouseButton1Click:Connect(function()
    SettingsPanel.Visible = not SettingsPanel.Visible
end)

state.connections[#state.connections+1] = MarkBtn.MouseButton1Click:Connect(function()
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
            print("[ESP] Marked SURVIVOR:", closest.Name)
        else
            state.manualKiller[closest.Name] = true
            state.manualSurvivor[closest.Name] = nil
            print("[ESP] Marked KILLER:", closest.Name)
        end
    end
end)

state.connections[#state.connections+1] = HideBtn.MouseButton1Click:Connect(function()
    ControlFrame.Visible = false
    SettingsPanel.Visible = false
    ShowBtn.Visible = true
end)

state.connections[#state.connections+1] = ShowBtn.MouseButton1Click:Connect(function()
    ControlFrame.Visible = true
    ShowBtn.Visible = false
end)

task.spawn(function()
    while state.running and MainGui.Parent do
        task.wait(SETTINGS.UpdateRate)
        if not state.running then break end
        pcall(updateESP)
    end
end)

state.connections[#state.connections+1] = LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if not state.enabled then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not state.esps[player] then
            createESP(player)
        end
    end
end)

print("[ESP v6] Loaded! UI Redesign - Comfortable Color Scheme")
print("[ESP v6] Warna: Soft Blue | Font: Gotham | Layout: Clean")
