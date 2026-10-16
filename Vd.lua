-- [[ SIMPLE ESP v3.1 — KILLER vs SURVIVOR ]]
-- Fitur: Compact UI, Anti-Rerun, Auto-Detect Role, Manual Mark, Fix Toggle OFF

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

local SETTINGS = {
    MaxDistance = 1000,
    UpdateRate = 0.1,
    SurvivorColor = Color3.fromRGB(0, 200, 255),
    KillerColor = Color3.fromRGB(255, 30, 30),
    UnknownColor = Color3.fromRGB(200, 200, 200),
    FillTransparency = 0.7,
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
    billboard.Size = UDim2.new(0, 180, 0, 56)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = highlight.Parent
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Parent = billboard
    
    local roleLabel = Instance.new("TextLabel")
    roleLabel.Size = UDim2.new(1, 0, 0, 16)
    roleLabel.Position = UDim2.new(0, 0, 0, 0)
    roleLabel.BackgroundTransparency = 1
    roleLabel.Text = "?"
    roleLabel.TextStrokeTransparency = 0
    roleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    roleLabel.TextSize = 12
    roleLabel.Font = Enum.Font.GothamBold
    roleLabel.Parent = container
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 16)
    nameLabel.Position = UDim2.new(0, 0, 0, 16)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextSize = 11
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = container
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(1, 0, 0, 12)
    distanceLabel.Position = UDim2.new(0, 0, 0, 32)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "0m"
    distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    distanceLabel.TextStrokeTransparency = 0
    distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distanceLabel.TextSize = 10
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.Parent = container
    
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Size = UDim2.new(1, 0, 0, 12)
    healthLabel.Position = UDim2.new(0, 0, 0, 44)
    healthLabel.BackgroundTransparency = 1
    healthLabel.Text = "100 HP"
    healthLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    healthLabel.TextStrokeTransparency = 0
    healthLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    healthLabel.TextSize = 10
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
            if state.esps[player] then
                removeESP(player)
            end
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
            local distance = 0
            if myPos then
                distance = math.floor((hrp.Position - myPos).Magnitude)
            end
            
            if distance > SETTINGS.MaxDistance then
                data.Highlight.Enabled = false
                data.Billboard.Enabled = false
            else
                local role = getRole(player)
                local color = getColor(role)
                
                data.Highlight.Enabled = true
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
                
                data.NameLabel.Text = player.Name
                data.NameLabel.TextColor3 = color
                
                data.DistanceLabel.Text = distance .. "m"
                
                data.HealthLabel.Text = math.floor(humanoid.Health) .. " HP"
                local hpPercent = humanoid.Health / humanoid.MaxHealth
                data.HealthLabel.TextColor3 = Color3.fromRGB(
                    255 * (1 - hpPercent),
                    255 * hpPercent,
                    100
                )
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
        if state.enabled then
            createESP(player)
        end
    end)
    if player.Character and state.enabled then createESP(player) end
end)

state.connections[#state.connections+1] = Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then createESP(player) end
end

-- ⭐ GUI COMPACT
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local oldGui = playerGui:FindFirstChild("ESPControlGui")
if oldGui then oldGui:Destroy() end

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "ESPControlGui"
MainGui.ResetOnSpawn = false
MainGui.DisplayOrder = 1000
MainGui.Parent = playerGui
state.guis[#state.guis+1] = MainGui

local ControlFrame = Instance.new("Frame")
ControlFrame.Size = UDim2.fromOffset(140, 80)
ControlFrame.Position = UDim2.fromOffset(18, 100)
ControlFrame.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
ControlFrame.BackgroundTransparency = 0.15
ControlFrame.BorderSizePixel = 0
ControlFrame.Active = true
ControlFrame.Draggable = true
ControlFrame.Parent = MainGui

local CF = Instance.new("UICorner")
CF.CornerRadius = UDim.new(0, 10)
CF.Parent = ControlFrame

local CF2 = Instance.new("UIStroke")
CF2.Color = Color3.fromRGB(62, 72, 104)
CF2.Thickness = 1
CF2.Transparency = 0.3
CF2.Parent = ControlFrame

local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, 0, 0, 20)
Header.BackgroundColor3 = Color3.fromRGB(100, 116, 255)
Header.BorderSizePixel = 0
Header.Text = "ESP"
Header.TextColor3 = Color3.fromRGB(255, 255, 255)
Header.TextSize = 10
Header.Font = Enum.Font.GothamBold
Header.Parent = ControlFrame

local HC = Instance.new("UICorner")
HC.CornerRadius = UDim.new(0, 10)
HC.Parent = Header

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 24)
ToggleBtn.Position = UDim2.new(0.05, 0, 0, 24)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Text = "ON"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 11
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Parent = ControlFrame

local TB = Instance.new("UICorner")
TB.CornerRadius = UDim.new(0, 5)
TB.Parent = ToggleBtn

local MarkBtn = Instance.new("TextButton")
MarkBtn.Size = UDim2.new(0.9, 0, 0, 22)
MarkBtn.Position = UDim2.new(0.05, 0, 0, 52)
MarkBtn.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
MarkBtn.BorderSizePixel = 0
MarkBtn.Text = "MARK KILLER"
MarkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MarkBtn.TextSize = 9
MarkBtn.Font = Enum.Font.GothamBold
MarkBtn.Parent = ControlFrame

local MB = Instance.new("UICorner")
MB.CornerRadius = UDim.new(0, 5)
MB.Parent = MarkBtn

local ShowBtn = Instance.new("TextButton")
ShowBtn.Size = UDim2.fromOffset(36, 36)
ShowBtn.Position = UDim2.fromOffset(18, 100)
ShowBtn.BackgroundColor3 = Color3.fromRGB(100, 116, 255)
ShowBtn.BorderSizePixel = 0
ShowBtn.Text = "ESP"
ShowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ShowBtn.TextSize = 10
ShowBtn.Font = Enum.Font.GothamBold
ShowBtn.Visible = false
ShowBtn.Active = true
ShowBtn.Draggable = true
ShowBtn.Parent = MainGui

local SB = Instance.new("UICorner")
SB.CornerRadius = UDim.new(1, 0)
SB.Parent = ShowBtn

local HideBtn = Instance.new("TextButton")
HideBtn.Size = UDim2.fromOffset(16, 16)
HideBtn.Position = UDim2.new(1, -20, 0, 2)
HideBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
HideBtn.BorderSizePixel = 0
HideBtn.Text = "X"
HideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HideBtn.TextSize = 10
HideBtn.Font = Enum.Font.GothamBold
HideBtn.Parent = Header

local HB = Instance.new("UICorner")
HB.CornerRadius = UDim.new(1, 0)
HB.Parent = HideBtn

state.connections[#state.connections+1] = ToggleBtn.MouseButton1Click:Connect(function()
    state.enabled = not state.enabled
    if state.enabled then
        ToggleBtn.Text = "ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                createESP(player)
            end
        end
    else
        ToggleBtn.Text = "OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        for _, player in ipairs(Players:GetPlayers()) do
            removeESP(player)
        end
    end
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

print("[ESP v3.1] Loaded! Fix Toggle OFF + Compact UI + Anti-Rerun")
print("[ESP v3.1] Killer: MERAH | Survivor: BIRU | Unknown: ABU")
