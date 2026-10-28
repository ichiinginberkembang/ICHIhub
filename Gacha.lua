-- ==========================================
-- 0. PENGATURAN GLOBAL & AUTO GROUP ID
-- ==========================================
local LOCAL_UID       = game:GetService("Players").LocalPlayer.UserId
local KATUN_URL       = "https://raw.githubusercontent.com/Dev-BlueX/BlueX-Hub/refs/heads/main/KaitunBloxFruits.lua"
local LEVEL_VXEZE_MIN = 2200

-- ---------- AUTO GROUP_ID (slot lock per akun) ----------
local MAX_GROUPS   = 20
local LOCK_STALE   = 600
local LOCK_REFRESH = 60

local function ReadLock(n)
    local f = "Lock_" .. n .. ".txt"
    if not isfile(f) then return nil, nil end
    local ok, data = pcall(readfile, f)
    if not ok or type(data) ~= "string" then return nil, nil end
    local uid, ts = string.match(data, "^(%d+)|(%d+)")
    return uid, tonumber(ts)
end

local function AssignGroupNum()
    if type(isfile) ~= "function" or type(readfile) ~= "function" or type(writefile) ~= "function" then
        return 1
    end
    local me = tostring(LOCAL_UID)
    for n = 1, MAX_GROUPS do
        if ReadLock(n) == me then return n end
    end
    math.randomseed(LOCAL_UID % 2147483647)
    for n = 1, MAX_GROUPS do
        local uid, ts = ReadLock(n)
        if not uid or os.time() - (ts or 0) > LOCK_STALE then
            writefile("Lock_" .. n .. ".txt", me .. "|" .. os.time())
            task.wait(math.random(5, 15) / 10)
            if ReadLock(n) == me then return n end
        end
    end
    return 1
end

local GROUP_NUM = AssignGroupNum()
local GROUP_ID  = "Group" .. GROUP_NUM

task.spawn(function()
    local me = tostring(LOCAL_UID)
    while true do
        task.wait(LOCK_REFRESH)
        local uid = ReadLock(GROUP_NUM)
        if uid == nil or uid == me then
            pcall(writefile, "Lock_" .. GROUP_NUM .. ".txt", me .. "|" .. os.time())
        end
    end
end)
print("[GroupID] akun " .. LOCAL_UID .. " -> " .. GROUP_ID)

-- ==========================================
-- 1. KONFIGURASI SCRIPT (VXEZE & KAITUN)
-- ==========================================
local VXEZE_URL = "https://raw.githubusercontent.com/Dex-Bear/VxezeHubLoader/refs/heads/main/MainHub.lua"

local function GetVxezeConfig()
    return {
        ["Auto Fire Shoot Heart Leviathan"] = false,
        ["Noti Profile"] = false,
        ["Auto Finish Train Draco Quest"] = false,
        ["Auto Dodge Skill Seabeast"] = false,
        ["Account Help"] = false,
        ["Auto Reset When Complete Volcano"] = false,
        ["Ignore Craft Volcanic Magnet"] = false,
        ["Auto Trade Azure Ember"] = false,
        ["Value Speed Fly Boat"] = 3,
        ["Hop Find Full Moon"] = false,
        ["Auto Trial Draco"] = false,
        ["Auto Aimbot Gun"] = false,
        ["Fruits v2 Account Help"] = false,
        ["Auto New World"] = false,
        ["Drive Boat To Hydra"] = false,
        ["Auto Summon Soul Ember"] = false,
        ["Summon Dough King"] = false,
        ["Auto Store Fruit"] = false,
        ["Auto Sell Fishing"] = false,
        ["Auto Get Fully Cyborg"] = false,
        ["Use Click M1 Skull Guitar Leviathan"] = false,
        ["Walk On Water"] = true,
        ["ESP Island"] = false,
        ["Multi Find Leviathan"] = false,
        ["Auto Magnet Event"] = false,
        ["Auto Buy Boat Beast Hunter"] = false,
        ["Auto Get Rainbow Haki"] = false,
        ["Boost Fps"] = true,
        ["Auto Spawn Kitsune Island"] = false,
        ["Auto Dragon Talon"] = false,
        ["Change JumpPower"] = false,
        ["Skill X Melee"] = 0.5,
        ["Hop Server [ Haki Color / Legendary Sword ]"] = false,
        ["Hop Server Elite Hunter"] = false,
        ["Auto Upgrade Sword Inventory"] = false,
        ["Random Devil Fruit"] = false,
        ["Auto Secret Quest"] = false,
        ["Auto Aimbot"] = false,
        ["Select Mob"] = { ["Factory Staff [Lv. 800]"] = true },
        ["Auto God Human"] = false,
        ["Sharkman Need Fish"] = false,
        ["Auto Tween To Event Fishing Spot"] = false,
        ["Min Player Join Dungeon"] = 2,
        ["Auto Yoru Mini (Hop Server)"] = false,
        ["Auto Farm Observation"] = false,
        ["Use Dragonstorm For Sea Event"] = false,
        ["Auto Touch Pad Haki"] = false,
        ["Attack Dough King"] = false,
        ["Auto Yoru Mini"] = false,
        ["Setup Kaitun v4 [ Fully ]"] = false,
        ["Tween Safe if have Items"] = false,
        ["Kill Aura Only Raid And Volcano"] = false,
        ["Auto Get Ghoul"] = false,
        ["Auto Finish Train Quest"] = false,
        ["Skill F Blox Fruit"] = 0.5,
        ["Account Main"] = false,
        ["Auto Get Cyborg"] = false,
        ["Skill C Blox Fruit"] = 0.5,
        ["Auto Turn On V3 Near Door"] = false,
        ["Auto Factory"] = false,
        ["Interface Scale"] = 90,
        ["White Screen"] = false,
        ["Notify Event Auto Refresh"] = false,
        ["Auto Sharkman Karate V3"] = false,
        ["Auto Dodge Skill Terrorshark"] = false,
        ["Hop Find Boss [ Cake Prince / Tyrant of the Skies ]"] = false,
        ["Auto TTK"] = false,
        ["Use Click M1 Fruit Leviathan"] = false,
        ["Auto Change Dragonstorm With Kill Leviathan"] = false,
        ["Auto Raid"] = false,
        ["% Health Player"] = 71,
        ["Auto Craft Haki Color [ Fully ]"] = false,
        ["Auto Third World"] = false,
        ["Kill Boss"] = false,
        ["Auto Click"] = true,
        ["Teleport Boat Other CFrame if Rough Sea"] = false,
        ["Auto Electric Claw"] = false,
        ["Speed Boat Auto Drive"] = 349,
        ["Auto Shark Anchor [ Fully ]"] = false,
        ["Auto Pirate Raid"] = false,
        ["Accept Quest [ Cake / Bone / Tiki ]"] = true,
        ["Skill Z Sword"] = 0.5,
        ["Auto Collect Fruits"] = false,
        ["Teleport To Kitsune Island"] = false,
        ["Time Hop Server"] = 5,
        ["Will Back When over 10km"] = false,
        ["Skill Z Gun"] = 0.5,
        ["Auto Find Leviathan"] = false,
        ["Value Collect Chest to Hop"] = 20,
        ["Hop Find Fruits / Berries / Chests"] = false,
        ["Auto Sea Event"] = false,
        ["Auto Stats"] = false,
        ["Select Weapon"] = "Melee",
        ["Auto Sanguine Art"] = false,
        ["Kill Aura With DragonStorm"] = false,
        ["Auto Get Observation v1-2 [ Fully ]"] = false,
        ["Farm Mob"] = false,
        ["Use Click M1 Skull Guitar For Sea Event"] = false,
        ["Auto CDK"] = false,
        ["Auto Crafting Volcanic Magnet"] = false,
        ["Hop Sever Raid"] = false,
        ["Auto Turn On Observation"] = true,
        ["Speed Tween"] = 181,
        ["Auto Join Dungeon"] = false,
        ["Attack Darkbeard"] = false,
        ["Auto Dodge Skill Mobs"] = false,
        ["No Fog"] = false,
        ["Auto Change Dragonstorm When Kill Boat"] = false,
        ["Auto Turn On V3"] = false,
        ["Tween Boat To Frozen Dimension"] = false,
        ["Distance Teleport Y"] = 800,
        ["Skill Z Melee"] = 0.5,
        ["Select Method Farm"] = "Cake",
        ["Just Use Skill when Player Active Ken"] = false,
        ["Value Speed Tween Boat"] = 250,
        ["Dough King [ Fully ]"] = false,
        ["Auto Start Leviathan"] = false,
        ["ESP Berry"] = false,
        ["Ignore Collect Bone"] = false,
        ["Auto Advanced Combat"] = false,
        ["Change WalkSpeed"] = false,
        ["Auto Pull Lever"] = false,
        ["Auto Fishing"] = false,
        ["Auto Buy Spy"] = false,
        ["Auto Tushita"] = false,
        ["Ignore Craft Volcanic Magnet Draco"] = false,
        ["Auto Destroy IDK"] = false,
        ["Ignore Boss"] = true,
        ["Value Damage Multi Segments"] = 131411,
        ["Fully Trial Draco"] = false,
        ["Auto Dojo Trainer"] = false,
        ["Auto Trial"] = false,
        ["Account Buy Chip"] = false,
        ["Auto Get Cyborg Hop Collect Chest"] = false,
        ["Kill players When complete Trial"] = false,
        ["Time Delay Kill"] = 3,
        ["Use skill fast dont hold"] = false,
        ["Auto Collect Bone"] = false,
        ["Webhook Find Prehistoric Island"] = false,
        ["Auto Get Full Melee [ Fully ]"] = false,
        ["Use Click M1 Fruit For Sea Event"] = false,
        ["Skill X Sword"] = 0.5,
        ["Values Azure Ember"] = 10,
        ["Auto Turn On V4"] = false,
        ["Fps Cap"] = 10,
        ["Input WalkSpeed"] = 200,
        ["Hop Server Kitsune Island"] = false,
        ["Auto Pick Card Dungeon"] = false,
        ["Spam Join"] = false,
        ["Auto Farm Mastery 600 Sword In Inventory"] = false,
        ["Auto Collect Chests"] = false,
        ["Summon Soul Reaper"] = false,
        ["Auto Yama"] = false,
        ["Summon Darkbeard"] = false,
        ["Buy Blox Fruit Sniper Shop"] = false,
        ["Random Magnet Event"] = false,
        ["Auto Trade Bone"] = false,
        ["Hop Find Mirage Island [ Pull Lever ]"] = false,
        ["Auto Open Chest"] = false,
        ["Attack Multi Segments Leviathan"] = false,
        ["Auto Saber"] = false,
        ["Change Speed Boat"] = false,
        ["Auto Buy Chip and Attack Law"] = false,
        ["Auto Reset Vip Leviathan"] = false,
        ["Collect Chest When Server Spawn Legend Items"] = false,
        ["Distance Farm Aura"] = 5000,
        ["Auto Soul Guitar"] = false,
        ["Hop Find Darkbeard"] = false,
        ["Hop Server When Farm Observation"] = false,
        ["Value Speed Boat"] = 200,
        ["Interface Text Boost"] = 0,
        ["Auto Buy Chip For Account Select"] = false,
        ["Farm Mastery"] = false,
        ["Auto Upgrade Race V2-V3 Draco"] = false,
        ["Auto Death Step"] = false,
        ["Auto Load Script"] = true,
        ["Webhook Upgrade V4 + Train"] = false,
        ["Auto Upgrade Race V2-V3"] = false,
        ["Drive Boat To Tiki"] = false,
        ["Webhook Find Mirage"] = false,
        ["Auto Farm Mastery 600 Gun In Inventory"] = false,
        ["Auto Slap Battle"] = false,
        ["Webhook Find Leviathan"] = false,
        ["Auto Observation v2"] = false,
        ["Notify Event Only Current Sea"] = true,
        ["Select Skills Blox Fruit"] = { ["X"] = true, ["C"] = true, ["Z"] = true, ["F"] = true, ["V"] = true },
        ["Black Screen"] = false,
        ["Bring Mob Count"] = 6,
        ["Skill X Blox Fruit"] = 0.5,
        ["Change Size Reel"] = false,
        ["Skill C Melee"] = 0,
        ["Teleport Player"] = false,
        ["Auto Dragon Hunter"] = false,
        ["Input JumpPower"] = 251,
        ["Account Start Dungeon"] = false,
        ["Account Pick Slot Raid"] = false,
        ["Auto Multi Raid"] = false,
        ["Stack Train With Trial Race"] = false,
        ["Auto rejoin Disconnect"] = false,
        ["ESP Player"] = false,
        ["Auto Find Mirage"] = false,
        ["Bring Mob"] = true,
        ["Auto Sharkman Karate"] = false,
        ["Select Skills Sword"] = { ["X"] = true, ["Z"] = true },
        ["Fully Event Prehistoric Island"] = false,
        ["Darkbeard [ Fully ]"] = false,
        ["Attack No Animation"] = true,
        ["Start Farm"] = true,
        ["Auto Collect Egg"] = false,
        ["Hop Server Get Ghoul"] = false,
        ["Auto Awake Fruit"] = false,
        ["Auto Get Draco"] = false,
        ["Webhook Destroy IDK"] = false,
        ["Auto Upgrade Dragon Talon"] = false,
        ["Auto Choose Gears"] = false,
        ["Auto Attack Dungeon"] = false,
        ["Auto Upgrade Gun Inventory"] = false,
        ["Auto Buy Legendary Sword"] = false,
        ["ESP Fruit"] = false,
        ["Auto Farm Mastery 600 Melees"] = false,
        ["Auto Elite Hunter"] = false,
        ["Health %"] = 40,
        ["Auto Collect Soul Ember"] = false,
        ["Fly Boat"] = false,
        ["Auto Change Dragonstorm With Skull Guitar"] = false,
        ["Auto Reset Character"] = false,
        ["Select Skills Melee"] = { ["X"] = true, ["C"] = true, ["Z"] = true },
        ["Attack Rip Indra"] = false,
        ["Farm Material"] = false,
        ["Ping Discord"] = false,
        ["Use Portal Fruit Teleport"] = false,
        ["Noclip"] = false,
        ["Skill V Blox Fruit"] = 0.5,
        ["Reset Character Buy Boat"] = false,
        ["Skill X Gun"] = 0.5,
        ["Get Fruit In Inventory Low Beli"] = false,
        ["Use Your Boat Beast Hunter"] = false,
        ["Webhook Store Fruit"] = false,
        ["Auto Collect Berries"] = false,
        ["Auto Sea Event With Friend"] = false,
        ["Teleport Y"] = false,
        ["Auto Quest Fruits v2"] = false,
        ["Auto Summon Rip Indra"] = false,
        ["Tween Until Have Sea Event"] = false,
        ["Teleport Acient Clock"] = false,
        ["Prevent Security Kick"] = true,
        ["Auto Buy Gear Draco"] = false,
        ["Auto Event Prehistoric Island"] = false,
        ["Use Skill when Kill Player"] = false,
        ["Auto Repair Ur Ship"] = false,
        ["Auto Super Human"] = false,
        ["Auto Choose Gear Draco"] = false,
        ["Hidden Hop Dead Hour"] = true,
        ["Auto Turn On Buso"] = true,
        ["Select Zone"] = "Zone 3",
        ["Teleport Frozen Dimension"] = false,
        ["Auto Attack Leviathan"] = false,
        ["Attack Soul Reaper"] = false,
        ["Auto Return Dungeon"] = false,
        ["Auto Find Prehistoric Island"] = false,
        ["Auto Buy Gear"] = false,
        ["Select Skills Gun"] = { ["X"] = true, ["Z"] = true },
        ["Kill All Boss"] = false,
        ["Hop Find Dough King"] = false,
        ["Remove Notifications"] = true,
        ["Auto Buy Haki Color Recipe"] = false,
        ["Skill Z Blox Fruit"] = 0.5,
        ["Auto Accept Quest Fishing"] = false,
        ["Hop Server Find Boss"] = false
    }
end

local function GetKaitunConfig()
    return {
        ["Setting"] = { ["UiCheckItem"] = false, ["White Screen"] = false },       
        ["MainItem"] = {
            ["Saber"] = true, ["Get 3 Legendary Colors Haki"] = true, ["Hallow Scythe"] = true,
            ["GodHuman"] = true, ["Skull Guitar"] = true, ["Cursed Dual Katana"] = true
        },
        ["MiscItem"] = {
            ["Feathered Visage"] = true, ["Pole1st"] = true, ["Dragon Trident"] = true,
            ["Rengoku"] = true, ["Spikey Trident"] = true, ["Buddy"] = true, ["Canvander"] = true,
            ["Twin Hooks"] = true, ["Gravity Blade"] = true, ["Venom Bow"] = true
        },
        ["Fruits"] = { ["Fruits Eat"] = {"Gravity-Gravity","Pain-Pain"}, ["Auto Eat Fruits"] = false, ["Farm Mastery Fruits"] = true },
        ["Quest"] = { ["Race V2-V3"] = true, ["Haki Rainbow"] = true },
        ["Webhook"] = { ["Enable"] = false, ["UrlWebhook"] = "" }
    }
end

-- ==========================================
-- 1b. SEA GUARD
-- ==========================================
do
    local PLACE = { [2753915549] = 1, [4442272183] = 2, [7449423635] = 3 }
    getgenv().BloxSea = { sea = PLACE[game.PlaceId], level = nil }
end

-- ==========================================
-- 1c. LEVEL GUARD & SCRIPT LOADER
-- ==========================================
do
    local BS = getgenv().BloxSea
    local function ReadLevel()
        local ok, v = pcall(function()
            local d = game:GetService("Players").LocalPlayer:FindFirstChild("Data")
            local l = d and d:FindFirstChild("Level")
            return l and tonumber(l.Value)
        end)
        return ok and v or nil
    end
    local function Run(url, name)
        task.spawn(function()
            local ok, e = pcall(function() loadstring(game:HttpGet(url))() end)
            if not ok then warn("[Level Guard] " .. name .. " gagal dimuat: " .. tostring(e)) end
        end)
    end
    local function Launch(lv)
        if lv >= LEVEL_VXEZE_MIN then
            BS.mode = "vxeze"
            print("[Level Guard] Level " .. lv .. " detected. Loading Vxeze...")
            getgenv().Config = GetVxezeConfig()
            Run(VXEZE_URL, "Vxeze")
        else
            BS.mode = "kaitun"
            print("[Level Guard] Level " .. lv .. " detected. Loading Kaitun...")
            getgenv().Config = GetKaitunConfig()
            Run(KATUN_URL, "Kaitun")
        end
    end
    task.spawn(function()
        local lv = ReadLevel()
        while not lv do
            task.wait(3)
            lv = ReadLevel()
        end
        BS.level = lv
        Launch(lv)
    end)
end

-- ==========================================
-- 2. BLOXFACTORY (GACHA + ROTATION + KILL SWITCH v15)
-- ==========================================
local WEBHOOK_FRUIT    = "https://discord.com/api/webhooks/1561728793226383510/PeYJqeHWViBXqs4M0VowG9xM-zk3Uupk2ta8UtWNUqh_R2IQaPIsxMIgZEXNnbRdJ2CM"
local WEBHOOK_BELI     = "https://discord.com/api/webhooks/1564228949033222204/E2n26s5XvL45E4c6Ylnozwb3cyi03QOyinAcltbcrKyAjzj8bLCGMVeDo4IR3mSeOCwd"

local RENDER_OFF       = true    
local FPS_CAP          = 10       
local ROLL_INTERVAL    = 7200    
local ACCOUNT_TIME     = 960    
local ACCOUNT_TIME_MAX = 2400   
local ROLL_MARGIN      = 60     
local MIN_VALID_P      = 1200   
local ROT_MAX_STEP     = 180    
local SLACK_DECAY      = 1800   
local SESSION_GRACE    = 180     
local PREFERRED_TEAM   = "Pirates"  

local HIGH_TIER = { 
    "dragon", "leopard", "kitsune", "dough", "venom", "shadow", "control", "spirit", 
    "mammoth", "t-rex", "trex", "gas", "yeti", "tiger", "magnet", "celestial", "oni",
    "crimson", "skins", "gold", "kitsune", "east", "west", 
    "buddha", "portal", "rumble", "lightning", "phoenix", "blizzard", "gravity", 
    "pain", "love", "spider", "sound", "soul", "quake", "creation" 
}

local Players, RS, RunService = game:GetService("Players"), game:GetService("ReplicatedStorage"), game:GetService("RunService")
local HttpService, VirtualUser = game:GetService("HttpService"), game:GetService("VirtualUser")
local LP = Players.LocalPlayer
repeat task.wait(1) until game:IsLoaded()
local PG = LP:WaitForChild("PlayerGui")
local Remotes = RS:WaitForChild("Remotes")
local env = getgenv()

local UID       = tostring(LP.UserId)
local LAST_FILE = "GachaLast_" .. UID .. ".txt"
local SESSION_FILE = "SessionEnd_" .. UID .. ".txt"

if env.BloxSM and env.BloxSM.Unload then pcall(env.BloxSM.Unload) end
local S = { alive = true, started = false, nextRoll = 0, fails = 0, lastStatus = "", conns = {}, sessionEnd = 0, signaled = false, farmStopped = false, farmTries = 0, farmRetryAt = 0 }
env.BloxSM = { Unload = function() S.alive = false end }

local gui = Instance.new("ScreenGui")
gui.Name = "BloxFactoryUI" gui.ResetOnSpawn = false gui.DisplayOrder = 999
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 230, 0, 32) frame.Position = UDim2.new(0, 6, 0, 40)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30) frame.BackgroundTransparency = 0.2
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(1, -16, 0, 30) btn.Position = UDim2.new(0, 8, 0, 6)
btn.BackgroundColor3 = Color3.fromRGB(60, 160, 90) btn.Text = "START"
btn.TextColor3 = Color3.new(1, 1, 1) btn.Font = Enum.Font.GothamBold btn.TextSize = 14
btn.Visible = false
local lbl = Instance.new("TextLabel", frame)
lbl.Size = UDim2.new(1, -16, 0, 22) lbl.Position = UDim2.new(0, 8, 0, 5) lbl.BackgroundTransparency = 1
lbl.TextColor3 = Color3.new(1, 1, 1) lbl.TextSize = 12 lbl.Font = Enum.Font.Gotham
lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.Text = "Menunggu spawn..."
pcall(function() local old = PG:FindFirstChild("BloxFactoryUI") if old then old:Destroy() end gui.Parent = PG end)
local function SetStatus(t)
    if t ~= S.lastStatus then S.lastStatus = t lbl.Text = t print("[BloxSM] " .. t) end
end

local GuiService, VIM = game:GetService("GuiService"), game:GetService("VirtualInputManager")
local TEAM = (PREFERRED_TEAM == "Marines") and "Marines" or "Pirates"
local STEM = (TEAM == "Pirates") and "pirate" or "marin"
local bootClock = os.clock()

local function ClickButton(b)
    if not b then return false end
    local fired = false
    if type(getconnections) == "function" then
        for _, sn in ipairs({ "MouseButton1Click", "Activated", "MouseButton1Down", "MouseButton1Up", "TouchTap" }) do
            local ok, sig = pcall(function() return b[sn] end)
            if ok and sig then
                local ok2, cs = pcall(getconnections, sig)
                if ok2 then for _, c in ipairs(cs) do
                    if pcall(function() c:Fire() end) then fired = true end
                end end
            end
        end
    end
    if not fired and type(firesignal) == "function" then
        for _, sn in ipairs({ "MouseButton1Click", "Activated" }) do
            if pcall(function() firesignal(b[sn]) end) then fired = true end
        end
    end
    return fired
end

local function HasHRP() local c = LP.Character return (c and c:FindFirstChild("HumanoidRootPart")) and true or false end
local function Shown(g)
    local cur = g
    while cur and cur ~= PG do
        if cur:IsA("GuiObject") and not cur.Visible then return false end
        if cur:IsA("ScreenGui") and not cur.Enabled then return false end
        cur = cur.Parent
    end
    return true
end
local cachedCt, lastScan = nil, 0
local function TeamUI()
    local main = PG:FindFirstChild("Main")
    local ct = main and main:FindFirstChild("ChooseTeam")
    if not ct and cachedCt and cachedCt.Parent then ct = cachedCt end
    if not ct and os.clock() - lastScan >= 5 then
        lastScan = os.clock()
        ct = PG:FindFirstChild("ChooseTeam", true)
        if not ct then
            for _, d in ipairs(PG:GetDescendants()) do
                if d:IsA("TextLabel") and string.find(string.lower(d.Text), "pick a side", 1, true) then
                    ct = d
                    while ct.Parent and ct.Parent ~= PG and not ct:FindFirstChild(TEAM, true) do ct = ct.Parent end
                    break
                end
            end
        end
        cachedCt = ct
    end
    return ct
end
local function TeamDone()
    local t = LP.Team
    if t and (t.Name == "Pirates" or t.Name == "Marines") then return true end
    local ct = TeamUI()
    if ct then return not Shown(ct) end
    return HasHRP()
end
local function FindTeamButton(ct)
    local c = ct:FindFirstChild("Container") or ct
    local t = c:FindFirstChild(TEAM) or ct:FindFirstChild(TEAM, true)
    if t then
        local f = t:FindFirstChild("Frame")
        local b = f and f:FindFirstChild("TextButton")
        if b then return b end
        b = t:FindFirstChildWhichIsA("GuiButton", true)
        if b then return b end
        if t:IsA("GuiButton") then return t end
    end
    for _, d in ipairs(ct:GetDescendants()) do
        if d:IsA("GuiButton") then
            local p, hit = d, false
            for _ = 1, 4 do
                if p and p ~= ct and string.find(string.lower(p.Name), STEM, 1, true) then hit = true break end
                p = p and p.Parent
            end
            if not hit and d:IsA("TextButton") and string.find(string.lower(d.Text), STEM, 1, true) then hit = true end
            if hit then return d end
        end
    end
end
local dumped = false
local function DumpTeamDebug()
    if dumped or type(writefile) ~= "function" then return end
    dumped = true
    local out = {}
    for _, d in ipairs(PG:GetDescendants()) do
        local txt = (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Text or ""
        local s = string.lower(d.Name .. " " .. txt)
        if s:find("team", 1, true) or s:find("pirate", 1, true) or s:find("marin", 1, true) or s:find("side", 1, true) then
            out[#out + 1] = d:GetFullName() .. " [" .. d.ClassName .. "] " .. txt
        end
    end
    pcall(writefile, "TeamDebug_" .. UID .. ".txt", table.concat(out, "\n"))
end
local function ViaVIM(b, mode)
    local sg = b:FindFirstAncestorOfClass("ScreenGui")
    local inset = (sg and sg.IgnoreGuiInset) and Vector2.zero or GuiService:GetGuiInset()
    local p = b.AbsolutePosition + b.AbsoluteSize / 2 + inset
    pcall(function()
        if mode == "mouse" then
            VIM:SendMouseButtonEvent(p.X, p.Y, 0, true, game, 0) task.wait(0.08)
            VIM:SendMouseButtonEvent(p.X, p.Y, 0, false, game, 0)
        else
            VIM:SendTouchEvent(1, 0, p.X, p.Y) task.wait(0.08)
            VIM:SendTouchEvent(1, 2, p.X, p.Y)
        end
    end)
end
local function TrySelectTeam()
    SetStatus("Pilih team: " .. TEAM)
    pcall(function() Remotes.CommF_:InvokeServer("SetTeam", TEAM) end)
    task.wait(1.5)
    if TeamDone() then return true, "remote" end
    local ct = TeamUI()
    local b = ct and FindTeamButton(ct)
    if not b then DumpTeamDebug() return false end
    ClickButton(b) task.wait(1)
    if TeamDone() then return true, "getconnections" end
    ViaVIM(b, "mouse") task.wait(1.2)
    if TeamDone() then return true, "vim-mouse" end
    ViaVIM(b, "touch") task.wait(1.2)
    if TeamDone() then return true, "vim-touch" end
    return false
end

local lastTry, teamFails = 0, 0
task.spawn(function()
    while S.alive do
        pcall(function()
            local ct = TeamUI()
            local need = (ct and Shown(ct)) or (LP.Team == nil and not HasHRP() and os.clock() - bootClock > 20)
            local cd = math.min(30, 5 * 2 ^ teamFails)
            if need and os.clock() - lastTry >= cd then
                lastTry = os.clock()
                local ok, how = TrySelectTeam()
                if ok then teamFails = 0 SetStatus("Team dipilih (" .. how .. "): " .. TEAM)
                else teamFails += 1 SetStatus("Pilih team gagal #" .. teamFails) end
            end
        end)
        task.wait(1)
    end
end)

local function IsHighTier(name)
    local l = string.lower(tostring(name))
    for _, k in ipairs(HIGH_TIER) do if string.find(l, k, 1, true) then return true end end
    return false
end

local function formatNum(n)
    n = tonumber(n) or 0
    local formatted = string.format("%d", math.floor(n))
    while true do
        local i
        formatted, i = formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
        if i == 0 then break end
    end
    return formatted
end

local function GetBeli()
    local ok, beli = pcall(function()
        local data = LP:FindFirstChild("Data")
        local beliVal = data and data:FindFirstChild("Beli")
        if beliVal and beliVal:IsA("ValueBase") then return beliVal.Value end
        return 0
    end)
    return ok and beli or 0
end

local function Snapshot()
    local out = {}
    for _, cont in ipairs({ LP:FindFirstChild("Backpack"), LP.Character }) do
        if cont then
            for _, it in ipairs(cont:GetChildren()) do
                if it:IsA("Tool") then
                    local n = it:GetAttribute("OriginalName") or it.Name
                    out[n] = out[n] or { count = 0, tool = it }
                    out[n].count += 1
                end
            end
        end
    end
    return out
end

local function SendWebhook(url, title, desc, color)
    if url == "" then return end
    local req = (syn and syn.request) or request or http_request
    if req then
        local payload = {
            username = "Fruit Factory",
            embeds = {{
                title = title,
                description = desc,
                color = color,
                footer = { text = "Akun: " .. LP.Name },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }
        pcall(req, { Url = url, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = HttpService:JSONEncode(payload) })
    end
end

local function RollFruit()
    local ok, res = pcall(function() return Remotes.CommF_:InvokeServer("Cousin", "Buy") end)
    if ok and res ~= nil and res ~= false then return res end
    local ok2, res2 = pcall(function()
        local net = RS:FindFirstChild("Modules") and RS.Modules:FindFirstChild("Net")
        local rf = net and net:FindFirstChild("RF/GachaNetworkRF")
        return rf and rf:InvokeServer({ Context = "Purchase", BoxName = "ZiolesGacha" })
    end)
    if ok2 and res2 ~= nil and res2 ~= false then return res2 end
end

local function DoRoll()
    SetStatus("Roll gacha...")
    local before = Snapshot()
    RollFruit()
    task.wait(2.5)
    
    local got = false
    local rawBeli = GetBeli()
    local currentBeli = formatNum(rawBeli)
    
    local isLowBeli = rawBeli < 5000000
    local beliText = isLowBeli and ("⚠️ **LOW BELI:** " .. currentBeli) or ("Sisa Beli: " .. currentBeli)
    local embedColor = isLowBeli and 16711680 or 3447003

    for name, info in pairs(Snapshot()) do
        if info.count > ((before[name] and before[name].count) or 0) then
            got = true
            if IsHighTier(name) then
                SetStatus("HIGH TIER: " .. name .. " - simpan ke Chest")
                pcall(function() Remotes.CommF_:InvokeServer("StoreFruit", name, info.tool) end)
                task.wait(1)
                local stored = not info.tool:IsDescendantOf(game)
                SetStatus(stored and ("Tersimpan di Chest: " .. name) or ("STORE GAGAL (masih di tas): " .. name))
                SendWebhook(WEBHOOK_FRUIT, "🔥 HIGH TIER OBTAINED 🔥",
                    string.format("GOT A HIGH TIER: **%s** %s\n%s", name, stored and "(Stored in Chest)" or "(Store GAGAL - masih di Backpack)", beliText),
                    isLowBeli and 16711680 or 16776960)
            else
                SetStatus("Item jelek diabaikan: " .. name)
            end
        end
    end
    
    SendWebhook(WEBHOOK_BELI, "📊 Roll Report", string.format("Status: %s\n%s", got and "Dapet buah baru" or "Zonk/Cooldown", beliText), embedColor)

    if got then
        S.fails = 0
        S.nextRoll = os.time() + ROLL_INTERVAL
        if type(writefile) == "function" then pcall(writefile, LAST_FILE, tostring(os.time())) end
    else
        S.fails += 1
        local delay = math.min(300, 45 * 2 ^ (S.fails - 1))
        S.nextRoll = os.time() + delay
        SetStatus("Belum dapat item (cooldown?), coba lagi " .. delay .. "s")
    end
end

local FARM_STOP_BEFORE = 120
local FARM_TEXTS    = { "mulai bertani", "start farming", "start farm" }
local FARM_PATTERNS = { "farm", "bertani" }
local ATTR_KEYS     = { "Value", "Toggled", "State", "Enabled", "On", "Active" }
local SKIP_GUI = { RobloxGui = true, PlayerList = true, Chat = true, TopBarApp = true, BubbleChat = true,
    PurchasePrompt = true, ThemeProvider = true, ControlGui = true, TouchGui = true, Main = true,
    BloxFactoryUI = true, ["RobloxNetworkPauseNotification"] = true, DevConsoleMaster = true, ScreenshotHud = true }
local farmSw, farmRow

local function FarmTextMatch(s)
    s = string.lower(s)
    for _, t in ipairs(FARM_TEXTS) do if s:find(t, 1, true) then return true end end
    return false
end
local function NameIsFarm(k)
    k = string.lower(k)
    for _, p in ipairs(FARM_PATTERNS) do if k:find(p, 1, true) then return true end end
    return false
end

local function EnvFarmFlags()
    local list = {}
    for _, tbl in ipairs({ env, _G }) do
        local n = 0
        for k, v in next, tbl do
            n += 1
            if n > 1500 then break end
            if type(k) == "string" and v == true and NameIsFarm(k) then list[#list + 1] = { tbl = tbl, key = k } end
        end
    end
    return list
end

local function FarmRoots()
    local roots = {}
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then roots[#roots + 1] = hui end
    pcall(function() roots[#roots + 1] = game:GetService("CoreGui") end)
    roots[#roots + 1] = PG
    return roots
end

local function ScanGui(g)
    local n = 0
    for _, d in ipairs(g:GetDescendants()) do
        n += 1
        if n % 400 == 0 then task.wait() end
        local cn = d.ClassName
        if (cn == "TextLabel" or cn == "TextButton") and FarmTextMatch(d.Text) then
            if cn == "TextButton" then return d, d.Parent or d end
            local a = d.Parent
            for _ = 1, 5 do
                if not a or a == g then break end
                local best, area
                for _, x in ipairs(a:GetDescendants()) do
                    if x:IsA("GuiButton") and x ~= d then
                        local ar = x.AbsoluteSize.X * x.AbsoluteSize.Y
                        if not area or ar < area then best, area = x, ar end
                    end
                end
                if best then return best, a end
                a = a.Parent
            end
        end
    end
end
local function GetFarmToggle()
    if farmSw and farmSw.Parent then return farmSw, farmRow end
    farmSw, farmRow = nil, nil
    local named, other = {}, {}
    for _, root in ipairs(FarmRoots()) do
        for _, g in ipairs(root:GetChildren()) do
            if g:IsA("ScreenGui") and not SKIP_GUI[g.Name] then
                if string.find(string.lower(g.Name), "vxeze", 1, true) then named[#named + 1] = g else other[#other + 1] = g end
            end
        end
    end
    for _, list in ipairs({ named, other }) do
        for _, g in ipairs(list) do
            local sw, row = ScanGui(g)
            if sw then farmSw, farmRow = sw, row return sw, row end
        end
    end
end

local function FarmIsOn(sw, row)
    for _, inst in ipairs({ sw, row }) do
        local ok, attrs = pcall(function() return inst:GetAttributes() end)
        if ok then for _, k in ipairs(ATTR_KEYS) do if type(attrs[k]) == "boolean" then return attrs[k] end end end
    end
    local scope = (sw.AbsoluteSize.X > 160) and row or sw
    local list = { scope }
    for _, d in ipairs(scope:GetDescendants()) do list[#list + 1] = d end
    for _, x in ipairs(list) do
        if x:IsA("GuiObject") and x.Visible and x.BackgroundTransparency < 0.9 then
            local _, s, v = x.BackgroundColor3:ToHSV()
            if s > 0.4 and v > 0.5 then return true end
        end
    end
    return false
end

local FARM_UI_SYNC = true 
local CFG_KEY = "Start Farm"
local function CfgTable()
    local c = env.Config
    if type(c) == "table" then return c end
end
local function CfgFarmOff(cfg)
    local n = 0
    pcall(function()
        if cfg[CFG_KEY] ~= false then cfg[CFG_KEY] = false n += 1 end
        local seen = 0
        for k, v in next, cfg do
            seen += 1
            if seen > 600 then break end
            if type(k) == "string" and v == true and k ~= CFG_KEY and NameIsFarm(k) then cfg[k] = false n += 1 end
        end
    end)
    return n
end

local function StopVxezeFarm()
    local ok, r, how = pcall(function()
        local bs = getgenv().BloxSea
        if bs and bs.mode == "kaitun" then
            local f = getgenv().KaitunStop
            if type(f) == "function" then pcall(f) end
            for _, fl in ipairs(EnvFarmFlags()) do fl.tbl[fl.key] = false end
            return "off", "kaitun (hook/flag, belum terverifikasi)"
        end
        local cfg = CfgTable()
        local wasOn = cfg ~= nil and cfg[CFG_KEY] == true
        local changed = cfg and CfgFarmOff(cfg) or 0
        local flags = EnvFarmFlags()
        for _, f in ipairs(flags) do f.tbl[f.key] = false end
        local sw, row, clicked
        if FARM_UI_SYNC or not cfg then
            sw, row = GetFarmToggle()
            if sw and FarmIsOn(sw, row) then
                ClickButton(sw) task.wait(0.8) clicked = true
                if FarmIsOn(sw, row) then ViaVIM(sw, "mouse") task.wait(0.8) end
                if cfg then CfgFarmOff(cfg) end
            end
        end
        if cfg then task.wait(0.3) if cfg[CFG_KEY] ~= false then cfg[CFG_KEY] = false end end
        local uiOn = sw and FarmIsOn(sw, row)
        if uiOn then
            if cfg or #flags > 0 then return "off", "config (UI masih tampak ON)" end
            return "stuck"
        end
        if clicked then return "off", cfg and "config+ui" or "ui" end
        if wasOn or changed > 0 or #flags > 0 then return "off", cfg and "config" or "env-flag" end
        if cfg then return "alreadyoff", "config" end
        if sw then return "alreadyoff", "ui" end
        return "notfound"
    end)
    if ok then return r, how end
    return "error"
end

local SEA_PLACES = { [2753915549] = 1, [4442272183] = 2, [7449423635] = 3 }
local CUR_SEA = SEA_PLACES[game.PlaceId]
local seaTries, seaNext = 0, 0
local function SeaGuard()
    if CUR_SEA == nil or CUR_SEA == 3 or seaTries >= 6 or os.time() < seaNext then return end
    local bs = getgenv().BloxSea
    if not bs or bs.mode ~= "vxeze" then return end
    local d = LP:FindFirstChild("Data")
    local l = d and d:FindFirstChild("Level")
    local lv = l and tonumber(l.Value)
    if not lv then return end
    local remote, label
    if lv >= 1500 then remote, label = "TravelZou", "Sea 3"
    elseif lv >= 700 and CUR_SEA == 1 then remote, label = "TravelDressrosa", "Sea 2" end
    if not remote then seaTries = 99 SetStatus("Sea guard: level " .. lv .. " belum cukup") return end
    seaTries += 1
    seaNext = os.time() + 45
    SetStatus("Sea guard: travel ke " .. label .. " (" .. seaTries .. "/6)")
    pcall(function() Remotes.CommF_:InvokeServer(remote) end)
end

local ROT_FILE = "RotationState_" .. GROUP_ID .. ".txt"
local ACC_FILE = "RotAcc_" .. GROUP_ID .. "_" .. UID .. ".txt"
local function LoadRot()
    local st = { t = ACCOUNT_TIME, adj = 0, exit = 0, exit_by = "", oh = 90 }
    if type(isfile) == "function" and isfile(ROT_FILE) then
        local ok, d = pcall(function() return HttpService:JSONDecode(readfile(ROT_FILE)) end)
        if ok and type(d) == "table" then
            for k in pairs(st) do if type(d[k]) == type(st[k]) then st[k] = d[k] end end
        end
    end
    st.t = math.clamp(st.t, ACCOUNT_TIME, ACCOUNT_TIME_MAX)
    return st
end
local function SaveRot(st)
    if type(writefile) == "function" then pcall(writefile, ROT_FILE, HttpService:JSONEncode(st)) end
end
local function MarkExit()
    local st = LoadRot()
    st.exit, st.exit_by = os.time(), LP.Name
    SaveRot(st)
end
local function RotationLearn(now)
    local st = LoadRot()
    local hasFS = type(isfile) == "function"
    local accStart = hasFS and isfile(ACC_FILE) and tonumber(readfile(ACC_FILE)) or nil
    local P = accStart and (now - accStart) or nil
    local hasLast = hasFS and isfile(LAST_FILE)
    local gap = st.exit > 0 and (now - st.exit) or nil
    if gap and st.exit_by ~= LP.Name and gap > 0 and gap < 900 then
        st.oh = math.floor(0.8 * st.oh + 0.2 * gap)
    end
    if P and hasLast and P >= MIN_VALID_P then
        local alive = math.clamp(math.floor(P / (st.t + st.oh) + 0.5), 1, 20)
        local epoch = alive * (st.t + st.oh)
        local cooled = (now - st.adj) >= 0.8 * epoch
        local R = S.nextRoll - now + ROLL_MARGIN
        if R > 0 then
            if st.t >= ACCOUNT_TIME_MAX then
                warn("[Rotation:" .. GROUP_ID .. "] cooldown belum habis tapi ACCOUNT_TIME max")
            elseif cooled then
                local old = st.t
                st.t = math.min(ACCOUNT_TIME_MAX, st.t + math.min(ROT_MAX_STEP, math.ceil(R / alive)))
                st.adj = now
                local msg = string.format("Skip terdeteksi (~%d akun hidup, kurang %ds): %.1f -> %.1f menit", alive, R, old / 60, st.t / 60)
                warn("[Rotation:" .. GROUP_ID .. "] " .. msg) SetStatus(msg)
            end
        elseif R < -SLACK_DECAY and st.t > ACCOUNT_TIME and cooled then
            local old = st.t
            st.t = math.max(ACCOUNT_TIME, st.t - 60)
            st.adj = now
            local msg = string.format("Putaran longgar: %.1f -> %.1f menit", old / 60, st.t / 60)
            warn("[Rotation:" .. GROUP_ID .. "] " .. msg) SetStatus(msg)
        end
    end
    SaveRot(st)
    if type(writefile) == "function" then pcall(writefile, ACC_FILE, tostring(now)) end
    return st.t
end

local ACTIVE_FILE = "Active_" .. GROUP_ID .. ".txt"
local lastHb, hbHits = 0, 0
local function Heartbeat()
    if type(isfile) ~= "function" or os.time() - lastHb < 30 then return end
    lastHb = os.time()
    pcall(function()
        if isfile(ACTIVE_FILE) then
            local uid, ts = string.match(readfile(ACTIVE_FILE), "^(%d+)|(%d+)$")
            if uid and uid ~= UID and os.time() - tonumber(ts) < 45 then
                hbHits += 1
                if hbHits >= 2 then
                    local msg = "GROUP_ID '" .. GROUP_ID .. "' dipakai tab lain! Ganti GROUP_ID per tab"
                    warn("[Rotation:" .. GROUP_ID .. "] " .. msg) SetStatus(msg)
                end
            else hbHits = 0 end
        end
        writefile(ACTIVE_FILE, UID .. "|" .. os.time())
    end)
end
local lvWatchNext, lvNotified = 0, false
local function LevelWatch()
    local bs = getgenv().BloxSea
    if lvNotified or not bs or bs.mode ~= "kaitun" or os.time() < lvWatchNext then return end
    lvWatchNext = os.time() + 60
    local d = LP:FindFirstChild("Data")
    local l = d and d:FindFirstChild("Level")
    local lv = l and tonumber(l.Value)
    if lv and lv >= LEVEL_VXEZE_MIN then
        lvNotified = true
        local msg = "Level " .. lv .. " >= " .. LEVEL_VXEZE_MIN .. ": Vxeze aktif di sesi berikutnya"
        print("[Level Guard] " .. msg) SetStatus(msg)
    end
end

local function Tick()
    if not S.started then return 1 end
    Heartbeat()
    LevelWatch()
    if S.signaled then return 10 end
    SeaGuard()
    local timeLeft = S.sessionEnd - os.time()
    if timeLeft <= FARM_STOP_BEFORE and not S.farmStopped and os.time() >= S.farmRetryAt then
        SetStatus("Matikan farm...")
        local r, how = StopVxezeFarm()
        S.farmTries += 1
        if r == "off" or r == "alreadyoff" or S.farmTries >= 4 then
            S.farmStopped = true
            SetStatus(r == "off" and ("Farm dimatikan (" .. tostring(how) .. ")") or r == "alreadyoff" and ("Farm sudah mati (" .. tostring(how) .. ")") or ("Farm: " .. tostring(r) .. " (menyerah)"))
        else
            S.farmRetryAt = os.time() + 10
            SetStatus("Farm: " .. r .. ", coba lagi 10s (" .. S.farmTries .. "/4)")
        end
    end
    if os.time() >= S.sessionEnd then
        S.signaled = true
        MarkExit()
        if type(writefile) == "function" then pcall(writefile, LP.Name .. "_winterswap.json", '{"status":"done"}') end
        SetStatus("Selesai! Menunggu WinterHub ganti akun...")
        return 10
    end
    local rem = S.nextRoll - os.time()
    if rem <= 0 then DoRoll() return 1 end
    if S.fails == 0 then SetStatus("Next Roll in: " .. math.ceil(rem / 60) .. " minutes | Sesi: " .. math.ceil((S.sessionEnd - os.time()) / 60) .. "m | " .. ((getgenv().BloxSea and getgenv().BloxSea.mode) or "?")) end
    return math.min(rem, 20)
end

local function Start()
    if S.started then return end
    btn.Visible = false
    frame.Size = UDim2.new(0, 230, 0, 32) lbl.Position = UDim2.new(0, 8, 0, 5)
    local now = os.time()
    local endAt
    if type(isfile) == "function" and isfile(SESSION_FILE) then
        endAt = tonumber(readfile(SESSION_FILE))
    end
    local newSession = true
    if endAt then
        if now < endAt then
            newSession = false
            SetStatus("Lanjut sesi, sisa " .. math.ceil((endAt - now) / 60) .. " menit")
        elseif now - endAt <= SESSION_GRACE then
            newSession = false
            SetStatus("Sesi sudah habis, kirim sinyal")
        end
    end
    if newSession then
        endAt = now + RotationLearn(now)
        if type(writefile) == "function" then pcall(writefile, SESSION_FILE, tostring(endAt)) end
        pcall(function() local f = LP.Name .. "_winterswap.json" if isfile(f) then delfile(f) end end)
    end
    S.sessionEnd = endAt
    S.signaled = false
    S.farmStopped, S.farmTries, S.farmRetryAt = false, 0, 0
    S.started = true
end
btn.MouseButton1Click:Connect(Start)
local function Stop()
    S.started = false
    btn.Visible = true
    frame.Size = UDim2.new(0, 230, 0, 70) lbl.Position = UDim2.new(0, 8, 0, 42)
    SetStatus("Dihentikan manual. Klik START untuk lanjut")
end
env.BloxSM.Start = Start
env.BloxSM.ResetSession = function() if type(delfile) == "function" and isfile(SESSION_FILE) then delfile(SESSION_FILE) end end
env.BloxSM.Stop = Stop

if type(isfile) == "function" and isfile(LAST_FILE) then
    S.nextRoll = (tonumber(readfile(LAST_FILE)) or 0) + ROLL_INTERVAL
else
    S.nextRoll = os.time()
end
if RENDER_OFF then
    pcall(function() RunService:Set3dRenderingEnabled(false) end)
    pcall(function() if setfpscap then setfpscap(FPS_CAP) end end)
    pcall(function() settings().Rendering.QualityLevel = 1 end)
end
S.conns[1] = LP.Idled:Connect(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end)

task.spawn(function()
    repeat task.wait(1) until LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    LP:WaitForChild("Backpack")
    task.wait(5)
    Start()
    while S.alive do
        local ok, r = pcall(Tick)
        if not ok then warn("[BloxSM] " .. tostring(r)) r = 5 end
        task.wait(tonumber(r) or 1)
    end
    for _, c in ipairs(S.conns) do pcall(function() c:Disconnect() end) end
    pcall(function() gui:Destroy() end)
    if RENDER_OFF then pcall(function() RunService:Set3dRenderingEnabled(true) end) end
end)
