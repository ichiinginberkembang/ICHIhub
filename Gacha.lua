-- ==========================================
-- AUTO GACHA FRUIT ONLY (LIGHT VERSION - ANTI LAG)
-- ==========================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

print("[GACHA] Script berhasil dimuat. Menunggu game load...")
repeat task.wait(1) until game:IsLoaded() and LocalPlayer.Character

-- 1. FUNGSI BUAT GACHA
local function RollFruit()
    local ok, res = pcall(function()
        return Remotes.CommF_:InvokeServer("Cousin", "Buy")
    end)
    
    if ok and res ~= nil and res ~= false then
        return res
    end

    -- Fallback remote (Hanya dipanggil kalau cara pertama gagal total)
    local ok2, res2 = pcall(function()
        local Modules = game:GetService("ReplicatedStorage"):FindFirstChild("Modules")
        local Net = Modules and Modules:FindFirstChild("Net")
        local GachaRF = Net and Net:FindFirstChild("RF/GachaNetworkRF")
        if not GachaRF then return nil end
        return GachaRF:InvokeServer({Context = "Purchase", BoxName = "ZiolesGacha"})
    end)
    
    if ok2 and res2 ~= nil then
        return res2
    end
    return nil
end

-- 2. FUNGSI BUAT NYIMPEN BUAH KE CHEST
local function StoreFruit()
    task.wait(1.5) -- Tunggu animasi buah masuk tas
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local char = LocalPlayer.Character
    local list = {}

    -- Cari buah di tas
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") and (string.find(item.Name, "Fruit") or item.ToolTip == "Blox Fruit") then
                table.insert(list, item)
            end
        end
    end
    -- Cari buah di tangan
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") and (string.find(item.Name, "Fruit") or item.ToolTip == "Blox Fruit") then
                table.insert(list, item)
            end
        end
    end

    -- Proses simpen
    for _, tool in ipairs(list) do
        local fruitName = tool:GetAttribute("OriginalName") or tool.Name
        pcall(function()
            Remotes.CommF_:InvokeServer("StoreFruit", fruitName, tool)
            print("[GACHA] Berhasil menyimpan buah ke Chest: " .. fruitName)
        end)
        task.wait(0.5)
    end
end

-- 3. LOOP UTAMA
print("[GACHA] Mulai nyari buah...")

task.spawn(function()
    while true do
        -- Langsung tembak gacha
        local result = RollFruit()
        
        if result then
            print("[GACHA] BERHASIL DAPET BUAH! Memproses...")
            StoreFruit() -- Langsung simpen
        else
            print("[GACHA] Gagal roll (Mungkin cooldown / belum lv 50 / gak punya uang).")
        end
        
        -- KUNCI: Jeda 10 detik biar server gak nge-lag & gak kena anti-cheat
        task.wait(10) 
    end
end)
