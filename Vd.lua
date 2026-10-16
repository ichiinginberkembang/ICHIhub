local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local SETTINGS = {
    Enabled = true,
    ShowBox = true,
    ShowName = true,
    ShowDistance = true,
    ShowHealth = true,
    ShowRole = true,
    MaxDistance = 1000,
    TextSize = 14,
    UpdateRate = 0.1,
    SurvivorColor = Color3.fromRGB(0, 200, 255),
    KillerColor = Color3.fromRGB(255, 30, 30),
    UnknownColor = Color3.fromRGB(200, 200, 200),
    FillTransparency = 0.7,
}

local MANUAL_KILLER = {}
local MANUAL_SURVIVOR = {}

local ESP_OBJECTS = {}

local function getRole(player)
    if MANUAL_KILLER[player.Name] then return "killer" end
    if MANUAL_SURVIVOR[player.Name] then return "survivor" end
    
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

local function createESP(player)
    if player == LocalPlayer then return end
    if ESP_OBJECTS[player] then return end
    
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
    billboard.Size = UDim2.new(0, 200, 0, 70)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
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
    roleLabel.TextSize = 14
    roleLabel.Font = Enum.Font.GothamBold
    roleLabel.Parent = container
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 18)
    nameLabel.Position = UDim2.new(0, 0, 0, 18)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = container
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(1, 0, 0, 14)
    distanceLabel.Position = UDim2.new(0, 0, 0, 36)
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
    healthLabel.Position = UDim2.new(0, 0, 0, 50)
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
    
    ESP_OBJECTS[player] = espData
end

local function removeESP(player)
    local data = ESP_OBJECTS[player]
    if not data then return end
    if data.Highlight then data.Highlight:Destroy() end
    if data.Billboard then data.Billboard:Destroy() end
    ESP_OBJECTS[player] = nil
end

local function updateESP()
    if not SETTINGS.Enabled then
        for _, data in pairs(ESP_OBJECTS) do
            if data.Highlight then data.Highlight.Enabled = false end
            if data.Billboard then data.Billboard.Enabled = false end
        end
        return
    end
    
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myPos = myHRP and myHRP.Position
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local data = ESP_OBJECTS[player]
        if not data then continue end
        
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
                
                data.Highlight.Enabled = SETTINGS.ShowBox
                data.Highlight.Adornee = char
                data.Highlight.FillColor = color
                data.Highlight.OutlineColor = color
                data.Highlight.FillTransparency = SETTINGS.FillTransparency
                
                data.Billboard.Enabled = true
                data.Billboard.Adornee = hrp
                
                if role == "killer" then
                    data.RoleLabel.Text = "KILLER"
                    data.RoleLabel.TextColor3 = color
                    data.RoleLabel.Visible = SETTINGS.ShowRole
                elseif role == "survivor" then
                    data.RoleLabel.Text = "SURVIVOR"
                    data.RoleLabel.TextColor3 = color
                    data.RoleLabel.Visible = SETTINGS.ShowRole
                else
                    data.RoleLabel.Text = "UNKNOWN"
                    data.RoleLabel.TextColor3 = color
                    data.RoleLabel.Visible = SETTINGS.ShowRole
                end
                
                data.NameLabel.Text = player.Name
                data.NameLabel.TextColor3 = color
                data.NameLabel.Visible = SETTINGS.ShowName
                
                data.DistanceLabel.Text = distance .. "m"
                data.DistanceLabel.Visible = SETTINGS.ShowDistance
                
                data.HealthLabel.Text = math.floor(humanoid.Health) .. " / " .. math.floor(humanoid.MaxHealth) .. " HP"
                data.HealthLabel.Visible = SETTINGS.ShowHealth
                
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

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        createESP(player)
    end)
    if player.Character then createESP(player) end
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "ESPControlGui"
MainGui.ResetOnSpawn = false
MainGui.DisplayOrder = 1000
MainGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ControlFrame = Instance.new("Frame")
ControlFrame.Size = UDim2.fromOffset(200, 130)
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

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 28)
ToggleBtn.Position = UDim2.new(0.05, 0, 0, 8)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Text = "ESP: ON"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 12
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Parent = ControlFrame

local TB = Instance.new("UICorner")
TB.CornerRadius = UDim.new(0, 6)
TB.Parent = ToggleBtn

local MarkKillerBtn = Instance.new("TextButton")
MarkKillerBtn.Size = UDim2.new(0.9, 0, 0, 24)
MarkKillerBtn.Position = UDim2.new(0.05, 0, 0, 40)
MarkKillerBtn.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
MarkKillerBtn.BorderSizePixel = 0
MarkKillerBtn.Text = "MARK TERDEKAT KILLER"
MarkKillerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MarkKillerBtn.TextSize = 9
MarkKillerBtn.Font = Enum.Font.GothamBold
MarkKillerBtn.Parent = ControlFrame

local MKB = Instance.new("UICorner")
MKB.CornerRadius = UDim.new(0, 6)
MKB.Parent = MarkKillerBtn

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(0.9, 0, 0, 50)
InfoLabel.Position = UDim2.new(0.05, 0, 0, 68)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Warna auto-deteksi.\nKalau salah, klik MARK\nuntuk mark manual."
InfoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
InfoLabel.TextSize = 9
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextWrapped = true
InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
InfoLabel.Parent = ControlFrame

ToggleBtn.MouseButton1Click:Connect(function()
    SETTINGS.Enabled = not SETTINGS.Enabled
    if SETTINGS.Enabled then
        ToggleBtn.Text = "ESP: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        ToggleBtn.Text = "ESP: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        for _, data in pairs(ESP_OBJECTS) do
            if data.Highlight then data.Highlight.Enabled = false end
            if data.Billboard then data.Billboard.Enabled = false end
        end
    end
end)

MarkKillerBtn.MouseButton1Click:Connect(function()
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
        if MANUAL_KILLER[closest.Name] then
            MANUAL_KILLER[closest.Name] = nil
            MANUAL_SURVIVOR[closest.Name] = true
            print("[ESP] Marked as SURVIVOR:", closest.Name)
        else
            MANUAL_KILLER[closest.Name] = true
            MANUAL_SURVIVOR[closest.Name] = nil
            print("[ESP] Marked as KILLER:", closest.Name)
        end
    end
end)

task.spawn(function()
    while task.wait(SETTINGS.UpdateRate) do
        pcall(updateESP)
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not ESP_OBJECTS[player] then
            createESP(player)
        end
    end
end)

print("[ESP v2] Loaded!")
print("[ESP v2] Killer: MERAH | Survivor: BIRU | Unknown: ABU")
