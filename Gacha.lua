--[[
    ================================================
    Blox Fruits - Auto Gacha (FINAL ULTIMATE + ANTI-BUG)
    Fitur: UI, Webhook High Tier, FPS Boost, Diffing Log
    ================================================
]]

local Players           = game:GetService("Players")
local LocalPlayer       = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService       = game:GetService("HttpService")
local UserInputService  = game:GetService("UserInputService")
local Remotes           = ReplicatedStorage:WaitForChild("Remotes")

---------- KONFIGURASI ----------
local WEBHOOK_URL = "https://discord.com/api/webhooks/1561728793226383510/PeYJqeHWViBXqs4M0VowG9xM-zk3Uupk2ta8UtWNUqh_R2IQaPIsxMIgZEXNnbRdJ2CM"
local COOLDOWN    = 20   
local MAX_HISTORY = 30   
local FPS_BOOST   = true 

-- DAFTAR BUAH HIGH TIER (Legendary & Mythical)
local HIGH_TIER_FRUITS = {
    ["Dragon"] = true, ["Leopard"] = true, ["Kitsune"] = true, ["Dough"] = true, 
    ["Venom"] = true, ["Shadow"] = true, ["Control"] = true, ["Spirit"] = true, 
    ["Mammoth"] = true, ["T-Rex"] = true, ["Gas"] = true, ["Yeti"] = true,
    ["Buddha"] = true, ["Portal"] = true, ["Rumble"] = true, ["Phoenix"] = true, 
    ["Blizzard"] = true, ["Gravity"] = true, ["Pain"] = true, ["Love"] = true, 
    ["Spider"] = true, ["Sound"] = true
}
-------------------------------

-- 1. CLEANUP GUI LAMA
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local oldGui = PlayerGui:FindFirstChild("AutoGachaUI")
if oldGui then oldGui:Destroy() end

print("[GACHA] Script berhasil dimuat. Menunggu game load...")
repeat task.wait(1) until game:IsLoaded() and LocalPlayer.Character

-------------------------------------------------
-- FUNGSI ANTI-LAG (FPS BOOST)
-------------------------------------------------
function boostfps()
    local Terrain = workspace:FindFirstChildOfClass('Terrain')
    local Lighting = game:GetService("Lighting")
    local Players = game:GetService("Players")

    if Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 1
    end

    pcall(function()
        local Map = workspace:FindFirstChild("Map")
        if Map then
            for _, v in ipairs(Map:GetChildren()) do
                local name = v.Name:lower()
                if name:find("tree") or name:find("plant") or name:find("rock") or
                   name:find("fence") or name:find("decoration") or name:find("grass") or
                   name:find("bush") or name:find("flower") then
                    pcall(function() v:Destroy() end)
                end
            end
        end
        for _, v in ipairs(workspace:GetChildren()) do
            if v.Name == "Clouds" or v.Name == "Cloud" then
                pcall(function() v:Destroy() end)
            end
        end
    end)

    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.FogStart = 9e9
    pcall(function() Lighting:ClearAllChildren() end)
    pcall(function() settings().Rendering.QualityLevel = 1 end)

    pcall(function()
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") then
                pcall(function() v.Lifetime = NumberRange.new(0) end)
            elseif v:IsA("Sound") then
                pcall(function() v:Destroy() end)
            end
        end
    end)
    print("[FPS BOOST] Grafik berhasil diturunkan ke mode kentang!")
end

if FPS_BOOST then boostfps() end

-------------------------------------------------
-- HELPER
-------------------------------------------------
local function Create(className, props)
    local inst = Instance.new(className)
    local parent = nil
    for k, v in pairs(props) do
        if k == "Parent" then parent = v else inst[k] = v end
    end
    if parent then inst.Parent = parent end
    return inst
end

local function GetRequestFn()
    if syn and syn.request then return syn.request end
    if type(request) == "function" then return request end
    if type(http_request) == "function" then return http_request end
    if type(getgenv) == "function" then
        local ok, fn = pcall(function() return getgenv().request end)
        if ok and type(fn) == "function" then return fn end
    end
    return nil
end

local function IsHighTier(fruitName)
    local lowerName = string.lower(tostring(fruitName))
    for keyword, _ in pairs(HIGH_TIER_FRUITS) do
        if string.find(lowerName, string.lower(keyword)) then
            return true
        end
    end
    return false
end

-- Fungsi Snapshot (Mencatat isi tas)
local function GetBackpackFruits()
    local fruits = {}
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local char = LocalPlayer.Character
    
    local function scan(container)
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") and (string.find(item.Name, "Fruit") or item.ToolTip == "Blox Fruit") then
                    local name = item:GetAttribute("OriginalName") or item.Name
                    if not fruits[name] then
                        fruits[name] = {count = 0, tool = item}
                    end
                    fruits[name].count = fruits[name].count + 1
                end
            end
        end
    end
    scan(backpack)
    scan(char)
    return fruits
end

-------------------------------------------------
-- 2. UI RINGAN
-------------------------------------------------
local screenGui = Create("ScreenGui", {
    Name = "AutoGachaUI", ResetOnSpawn = false, IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = PlayerGui,
})

local main = Create("Frame", {
    Name = "Main", Size = UDim2.new(0, 270, 0, 360), Position = UDim2.new(0, 16, 0.5, -180),
    BackgroundColor3 = Color3.fromRGB(22, 22, 28), BorderSizePixel = 0, Parent = screenGui,
})
Create("UICorner", { CornerRadius = UDim.new(0, 10) }, main)
pcall(function() Create("UIStroke", { Color = Color3.fromRGB(70, 70, 95), Thickness = 1, Parent = main }) end)

local titleBar = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = Color3.fromRGB(30, 30, 40), BorderSizePixel = 0, Parent = main,
})
Create("UICorner", { CornerRadius = UDim.new(0, 10) }, titleBar)
Create("Frame", {
    Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 1, -10),
    BackgroundColor3 = Color3.fromRGB(30, 30, 40), BorderSizePixel = 0, Parent = titleBar,
})

Create("TextLabel", {
    BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -50, 1, 0),
    Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.fromRGB(255, 255, 255),
    TextXAlignment = Enum.TextXAlignment.Left, Text = "🍒 Auto Gacha (Filter)", Parent = titleBar,
})

local minBtn = Create("TextButton", {
    Position = UDim2.new(1, -30, 0, 5), Size = UDim2.new(0, 24, 0, 24),
    BackgroundColor3 = Color3.fromRGB(50, 50, 65), BorderSizePixel = 0,
    Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Color3.fromRGB(255, 255, 255),
    Text = "-", AutoButtonColor = true, Parent = titleBar,
})
Create("UICorner", { CornerRadius = UDim.new(0, 6) }, minBtn)

local statusLabel = Create("TextLabel", {
    Position = UDim2.new(0, 12, 0, 42), Size = UDim2.new(1, -24, 0, 36),
    BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, TextSize = 13,
    TextColor3 = Color3.fromRGB(160, 160, 180), TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
    Text = "Status: Menunggu...", Parent = main,
})

local STATUS_COLORS = { ok = Color3.fromRGB(80, 220, 130), fail = Color3.fromRGB(255, 90, 90), wait = Color3.fromRGB(255, 200, 80), info = Color3.fromRGB(140, 180, 255) }
local function SetStatus(state, text)
    statusLabel.Text = "Status: " .. text
    statusLabel.TextColor3 = STATUS_COLORS[state] or STATUS_COLORS.info
end

local webhookState = "OFF"
local historyCount = 0
local orderCounter = 0

local counterLabel = Create("TextLabel", {
    Position = UDim2.new(0, 12, 0, 80), Size = UDim2.new(1, -24, 0, 18),
    BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 11,
    TextColor3 = Color3.fromRGB(140, 140, 155), TextXAlignment = Enum.TextXAlignment.Left,
    Text = "Buah didapat: 0  |  Webhook: OFF", Parent = main,
})

local function UpdateCounter()
    counterLabel.Text = "Buah didapat: " .. historyCount .. "  |  Webhook: " .. webhookState
end

local historyScroll = Create("ScrollingFrame", {
    Position = UDim2.new(0, 6, 0, 102), Size = UDim2.new(1, -12, 1, -112),
    BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4,
    ScrollBarImageColor3 = Color3.fromRGB(90, 90, 110), CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = main,
})
Create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = historyScroll })

local function AddHistory(fruitName, isHigh)
    orderCounter = orderCounter - 1
    historyCount = historyCount + 1

    local entry = Create("Frame", {
        Name = "Entry", Size = UDim2.new(1, -6, 0, 30),
        BackgroundColor3 = Color3.fromRGB(33, 33, 45), BorderSizePixel = 0, LayoutOrder = orderCounter,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6) }, entry)

    local barColor = isHigh and Color3.fromRGB(80, 220, 130) or Color3.fromRGB(100, 100, 100)
    local bar = Create("Frame", {
        Size = UDim2.new(0, 4, 1, -8), Position = UDim2.new(0, 4, 0, 4),
        BackgroundColor3 = barColor, BorderSizePixel = 0, Parent = entry,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0) }, bar)

    Create("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(1, -80, 1, 0),
        Font = Enum.Font.GothamSemibold, TextSize = 13, TextColor3 = isHigh and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180),
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
        Text = tostring(fruitName), Parent = entry,
    })

    Create("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(1, -62, 0, 0), Size = UDim2.new(0, 52, 1, 0),
        Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Color3.fromRGB(150, 150, 165),
        TextXAlignment = Enum.TextXAlignment.Right, Text = os.date("%H:%M:%S"), Parent = entry,
    })

    entry.Parent = historyScroll
    UpdateCounter()

    if historyCount > MAX_HISTORY then
        local oldest, oldestOrder = nil, -math.huge
        for _, child in ipairs(historyScroll:GetChildren()) do
            if child:IsA("Frame") and child.LayoutOrder > oldestOrder then
                oldest, oldestOrder = child, child.LayoutOrder
            end
        end
        if oldest then oldest:Destroy() historyCount = historyCount - 1 UpdateCounter() end
    end
end

local toggleBtn = Create("TextButton", {
    Position = UDim2.new(0, 16, 0, 16), Size = UDim2.new(0, 40, 0, 40),
    BackgroundColor3 = Color3.fromRGB(30, 30, 40), BorderSizePixel = 0,
    Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = Color3.fromRGB(255, 255, 255),
    Text = "🍒", Visible = false, AutoButtonColor = true, Parent = screenGui,
})
Create("UICorner", { CornerRadius = UDim.new(1, 0) }, toggleBtn)
pcall(function() Create("UIStroke", { Color = Color3.fromRGB(70, 70, 95), Thickness = 1, Parent = toggleBtn }) end)

minBtn.MouseButton1Click:Connect(function() main.Visible = false toggleBtn.Visible = true end)
toggleBtn.MouseButton1Click:Connect(function() main.Visible = true toggleBtn.Visible = false end)

local dragging, dragStart, startPos = false, nil, nil
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

local requestFn = GetRequestFn()
if WEBHOOK_URL == nil or WEBHOOK_URL == "" then webhookState = "OFF"
elseif not requestFn then webhookState = "TANPA request"
else webhookState = "ON" end
UpdateCounter()
SetStatus("info", "Script aktif. Menunggu roll...")

-------------------------------------------------
-- 3. DISCORD WEBHOOK
-------------------------------------------------
local function SendWebhook(fruitName)
    if WEBHOOK_URL == nil or WEBHOOK_URL == "" then return false end
    if not requestFn then return false end

    local playerName    = LocalPlayer.Name
    local displayName   = LocalPlayer.DisplayName
    local timestamp     = os.date("!%Y-%m-%dT%H:%M:%SZ")
    local waktuLokal    = os.date("%Y-%m-%d %H:%M:%S")

    local payload = {
        username = "Blox Gacha Bot",
        embeds = {{
            title = "🔥 HIGH TIER FRUIT OBTAINED! 🔥",
            description = "**" .. displayName .. "** (" .. playerName .. ") mendapatkan **" .. tostring(fruitName) .. "**",
            color = 16711680,
            fields = {
                { name = "Player",    value = displayName .. " (@" .. playerName .. ")", inline = false },
                { name = "Buah",      value = "**" .. tostring(fruitName) .. "**",       inline = true  },
                { name = "Timestamp", value = "`" .. waktuLokal .. "`",                 inline = true  },
            },
            timestamp = timestamp,
            footer = { text = "Auto Gacha - Blox Fruits" },
        }},
    }

    local okEnc, body = pcall(function() return HttpService:JSONEncode(payload) end)
    if not okEnc or type(body) ~= "string" then return false end

    pcall(function()
        requestFn({ Url = WEBHOOK_URL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
    end)
end

-------------------------------------------------
-- 4. FUNGSI GACHA
-------------------------------------------------
local function RollFruit()
    local ok, res = pcall(function() return Remotes.CommF_:InvokeServer("Cousin", "Buy") end)
    if ok and res ~= nil and res ~= false then return res end

    local ok2, res2 = pcall(function()
        local Modules = game:GetService("ReplicatedStorage"):FindFirstChild("Modules")
        local Net = Modules and Modules:FindFirstChild("Net")
        local GachaRF = Net and Net:FindFirstChild("RF/GachaNetworkRF")
        if not GachaRF then return nil end
        return GachaRF:InvokeServer({ Context = "Purchase", BoxName = "ZiolesGacha" })
    end)

    if ok2 and res2 ~= nil and res2 ~= false then return res2 end
    return nil
end

-------------------------------------------------
-- 5. LOOP UTAMA (DENGAN SISTEM DIFFING / SNAPSHOT)
-------------------------------------------------
local function CooldownWait(prefix)
    for i = COOLDOWN, 1, -1 do
        SetStatus("wait", prefix .. "  •  Cooldown (" .. i .. "s)")
        task.wait(1)
    end
end

print("[GACHA] Mulai nyari buah...")

task.spawn(function()
    while true do
        SetStatus("info", "Sedang roll gacha...")
        
        -- 1. FOTO TAS SEBELUM GACHA
        local preFruits = GetBackpackFruits() 
        
        -- 2. ROLL GACHA
        local result = RollFruit()

        if result then
            task.wait(2) -- Tunggu animasi buah masuk tas
            
            -- 3. FOTO TAS SESUDAH GACHA
            local postFruits = GetBackpackFruits()
            local newFruitsFound = {}
            local storedFruits = {}

            -- 4. BANDINGKAN: Cari buah yang nambah
            for fruitName, data in pairs(postFruits) do
                local preCount = preFruits[fruitName] and preFruits[fruitName].count or 0
                if data.count > preCount then
                    -- Berarti ini buah baru!
                    table.insert(newFruitsFound, fruitName)
                    
                    -- Simpan otomatis ke chest
                    local okStore = pcall(function() Remotes.CommF_:InvokeServer("StoreFruit", fruitName, data.tool) end)
                    if okStore then
                        table.insert(storedFruits, fruitName)
                        print("[GACHA] Disimpan ke Chest: " .. fruitName)
                    end
                end
            end

            -- 5. PROSES HASIL
            if #newFruitsFound > 0 then
                -- Gabungin nama buah (kalau misal dapet 2 sekaligus)
                local finalFruitName = table.concat(newFruitsFound, ", ")
                local isHigh = false
                
                -- Cek apakah ada yang High Tier
                for _, fName in ipairs(newFruitsFound) do
                    if IsHighTier(fName) then
                        isHigh = true
                        break
                    end
                end

                AddHistory(finalFruitName, isHigh)
                SetStatus("ok", "Berhasil: " .. finalFruitName)
                
                if isHigh then
                    print("[GACHA] 🔥 HIGH TIER! Mengirim ke Discord: " .. finalFruitName)
                    SendWebhook(finalFruitName)
                else
                    print("[GACHA] Buah biasa (" .. finalFruitName .. "), webhook dilewati.")
                end
            else
                print("[GACHA] Roll sukses, tapi tidak ada buah baru di tas (Mungkin tas penuh?).")
                SetStatus("fail", "Tas Penuh / Gagal Deteksi")
            end

            task.wait(1.5)
            CooldownWait("Berhasil")
        else
            print("[GACHA] Gagal roll.")
            CooldownWait("Gagal")
        end
    end
end)
