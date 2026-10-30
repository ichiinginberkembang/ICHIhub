--[[
  BloxFactory v24.0 (Android + Delta Executor)
  v24.0 = v23.1 (Vxeze branch) + v22.1 (Kaitun branch) in ONE script:
    * Hub switch (8): level < LEVEL_VXEZE_MIN -> BF-Kaitun, otherwise Vxeze (Cake preset). Decided once per boot, logged with the
      reason, CFG.HUB pins one hub. A hub cannot be unloaded from a running client, so a level-up takes effect at the next session.
    * Kaitun mode: our Stats / Codes / Sea guard / Start-Farm control are off (Kaitun owns those); Vxeze mode: v23.1 behaviour unchanged.
    * Kaitun weapon policy (8, 12e): Select Weapon = Melee, Farm Mastery.Weapon Farm = { "Melee" }, sword quest keys off, re-asserted
      every few seconds, plus a runtime Weapon Guard that acts on what the character actually holds (Yama / any "Sword" tool).
    * Kaitun config guard: weapon policy + Godhuman gate (GODHUMAN_BELOW) are re-forced in the live config (v22.1 gate, now every few seconds).
    * Swap enforcer (12d, from v22.1) kept; on Vxeze it is off by default (CFG.SWAP.ON_VXEZE) because Farm.stop works there.
    * Respawn recovery kept for both hubs; a Kaitun reload is opt-in (CFG.RESPAWN.KAITUN_RELOAD) because Kaitun's UI cannot be removed by name.
    * Idle verifier is hub aware: on Kaitun it observes and alerts, it never writes Vxeze keys into the Kaitun config.
  v23.1 changes (over v23.0):
    * Respawn recovery (12c): after a death the hub's farm loop can be left holding the dead character. The handler does NOT
      reload on every CharacterAdded. It waits until the new character is stable, watches for real progress (movement / exp /
      beli), and only then climbs a ladder: 1) cycle Start Farm  2) guarded hub reload  3) give up and let the idle verifier decide.
      Reloads are rate limited (cooldown + per-session cap), never happen during a death storm, and the old hub window is
      destroyed first so GUIs cannot stack.
  v23 changes (over v22.0):
    * Stats: the primary driver is now ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", <stat>, <n>).
      It takes the stat's internal English name, so the language of the game UI is irrelevant. The StatsFrame remote
      and the UI "+" buttons stay as fallbacks. UI fallback no longer reads text: it maps "+" buttons by position.
      The probe only needs 1 unspent point, and the dashboard now says WHY it has no remote (usually: no points).
    * Codes (13b): native auto-redeem through Remotes.Redeem, once per code per account, reset/refund codes never sent.
  v22 changes (over v21.2):
    * Vx config guard: deep (nested) forced values + "observation" kill-switch + hub-copy discovery, re-asserted every 3s
    * GodHuman / MainItem.GodHuman forced off below CFG.GODHUMAN_OFF_BELOW
    * Sea guard: correct sea order, readiness wait, async InvokeServer with result logging, hub assist, reload queue
    * Stats: probe tries an UNCAPPED stat first, logs every attempt to StatsProbe_<UID>.txt, UI-click fallback
    * Damage numbers: structural detection (BillboardGui/SurfaceGui with numeric text) on game.DescendantAdded
    * Webhook URL validation (fragments are rejected instead of failing silently forever)
  INTERFACES READ BY THE EXTERNAL SCHEDULER (unchanged):
    * Signal file : "<username>_winterswap.json"   containing {"status":"done"}
    * Session file: "SessionEnd_<Group>_<UID>.txt" containing a Unix timestamp
]]

----------------------------------------------------------------
-- 0. CONFIG
----------------------------------------------------------------
local CFG = {
    VERSION = "v24.0",
    WEBHOOKS = { 
        fruit = "https://discord.com/api/webhooks/1561728793226383510/PeYJqeHWViBXqs4M0VowG9xM-zk3Uupk2ta8UtWNUqh_R2IQaPIsxMIgZEXNnbRdJ2CM", 
        report = "https://discord.com/api/webhooks/1564228949033222204/E2n26s5XvL45E4c6Ylnozwb3cyi03QOyinAcltbcrKyAjzj8bLCGMVeDo4IR3mSeOCwd" 
    },
    VXEZE_URL       = "https://raw.githubusercontent.com/Dex-Bear/VxezeHubLoader/refs/heads/main/MainHub.lua",
    LEVEL_VXEZE_MIN = 2200,
    -- v24 hub switch. "auto": level < LEVEL_VXEZE_MIN -> BF-Kaitun, otherwise Vxeze. "kaitun" / "vxeze" pin one hub at every level.
    HUB             = "auto",
    KAITUN_URL      = "https://raw.githubusercontent.com/Dex-Bear/VxezeHubLoader/refs/heads/main/BF-Kaitun.lua",
    GODHUMAN_BELOW  = 2200,        -- Kaitun: Godhuman / Superhuman are ON only below this level, forced off in the live config at or above it
    KAITUN = {
        MASTERY = true,            -- Farm Mastery.Enabled; false = Godhuman chain only
        WEAPON  = "Melee",         -- Select Weapon, and the ONLY entry of Farm Mastery.Weapon Farm
        ADD_SELECT_WEAPON_KEY = true,   -- the v22.1 Kaitun schema has no "Select Weapon" key; adding a scalar key is harmless
        -- Forced to false wherever they EXIST in Get Items. Names the schema does not contain are only added when ADD_MISSING_SWORD_KEYS = true:
        -- an unknown key is harmless if the hub looks keys up by name, but it could raise if the hub iterates Get Items and indexes its own table.
        SWORD_KEYS = { "Saber", "Yama", "Cursed Dual Katana", "Hallow Scythe", "Tushita", "Dark Blade", "Buddy Sword", "Triple Katana" },
        ADD_MISSING_SWORD_KEYS = false,
        GUARD = {                  -- runtime Weapon Guard (12e): looks at what the character actually holds
            ENABLED = true, CHECK = 1,
            FORBID_TIPS  = { "Sword" },     -- Tool.ToolTip values that must never stay equipped (add "Gun" for a melee-only run)
            FORBID_NAMES = { "Yama", "Tushita", "Saber", "Cursed Dual Katana", "Hallow Scythe", "Dark Blade" },   -- backup when ToolTip is missing
            MELEE_PREFER = { "Godhuman", "Sanguine Art", "Dragon Talon", "Superhuman", "Death Step", "Sharkman Karate", "Electric Claw", "Dragon Claw", "Electro", "Black Leg", "Combat" },
            EQUIP_MELEE = true,
            STASH = true,                     -- escalation: the hub keeps re-equipping -> move forbidden tools out of the Backpack on THIS client
            FIGHT_LIMIT = 4, FIGHT_WINDOW = 30,
        },
        IDLE_GIVEUP = false,       -- idle stage 3 on Kaitun: false = alert only (long quest travel looks idle), true = mark the session dead
        IDLE_ALERT_GAP = 1800,     -- minimum seconds between two "Kaitun idle" alerts
    },
    SWAP = {
        ENABLED = true,
        ON_VXEZE = false,          -- Vxeze can be stopped through Farm.stop, so only Kaitun needs the enforcer by default
        QUIESCE = true,            -- on signal: switch every option in the live Kaitun config off (only effective if the hub reads it live)
        ACK_GRACE = 60,            -- scheduler consumed the signal but the client is still alive this long after: close it
        FORCE_AFTER = 300,         -- signal NOT consumed this long after writing: close it (0 = never, alert only)
        ACTION = "shutdown",       -- "shutdown" (game:Shutdown, then Kick as fallback) | "kick" | "none" (monitor only)
        FLUSH_WAIT = 6,            -- seconds to let the webhook queue drain before closing
        RETRY = 120,               -- if the client survived every close attempt, try again after this long
    },
    PREFERRED_TEAM  = "Pirates",
    BELI_KEEP_LEGACY_UI = false,
    -- v22 config guard (see Vx.enforceAll)
    GODHUMAN_OFF_BELOW = 0,                 -- below this level MainItem.GodHuman / "Auto God Human" are forced to false
    FORCE_OFF_PATTERNS = { "observation" },    -- any boolean key containing one of these words is forced to false, at ANY depth
    FORCE_GUARD_FAST = 3, FORCE_GUARD_SLOW = 15, FORCE_GUARD_FAST_FOR = 600,
    KEN_RUNTIME_OFF = false,                   -- ASSUMED remote signature (CommE:FireServer("Ken", false)); off unless you test it
    -- v22 sea guard
    SEA = { READY_WAIT = 20, TRY_GAP = 45, MAX_TRIES = 8, HUB_ASSIST_AFTER = 2, DIAG_ZQUEST = true, RELOAD_FILE = "BloxFactory.lua" },
    -- v22 damage numbers
    DMG = { ENABLED = true, NAMES = { "damage", "dmg" }, PROBE_SECONDS = 25, PROBE_MAX = 40 },
    IDLE = { ENABLED = true, CHECK = 5, GRACE = 90, AFTER = 90, STAGE_WAIT = 90, MOVE_STUDS = 12, FALLBACK_METHODS = { "Bone" }, GIVEUP_DEAD = true, DRIFT_AFTER = 45 },
    ROLL_INTERVAL = 7200, ROLL_MARGIN = 60, LOW_BELI = 5000000,
    SESSION_BASE = 960, SESSION_MAX = 2400, SESSION_GRACE = 180, MIN_VALID_P = 1200, ROT_MAX_STEP = 180,
    SLACK_DECAY = 1800, BOOTSTRAP_CYCLES = 3, SIGNAL_ALERT_AFTER = 600, SIGNAL_WRITE_TRIES = 3,
    ROT_BAD_LIMIT = 3, START_MAX_WAIT = 120, GROUP_WAIT_MAX = 40,
    DEAD_NO_CHAR = 240, DEAD_ON_ERROR = true, AUTO_REJOIN = true, REJOIN_AFTER = 150,
    FARM_STOP_BEFORE = 120, FARM_ON_MAX = 3,
    MAX_GROUPS = 20, LOCK_REFRESH = 10, LOCK_STALE = 120, PROBE_WAIT = 25, LOCK_RETRY_MAX = 300,
    WH_BURST = 5, WH_PER_MIN = 20, WH_QUEUE_MAX = 40, WH_MAX_TRIES = 6, WH_ORPHAN_AFTER = 180,
    VX_MAX_ATTEMPTS = 6, VX_UI_TIMEOUT = 150, VX_MAX_RELOADS = 3,
    NOTI_BLOCK_ALL  = true, NOTI_PATTERNS = { "kill", "boss" }, NOTI_NAME_KEYS = { "noti", "toast", "popup" }, NOTI_DISABLE_KEYS = { "Noti Profile" },
    STATS = {
        ENABLED = true,
        PRIORITY = { { stat = "Melee", cap = 2550 }, { stat = "Defense", cap = 2550 }, { stat = "Sword", cap = 2550 }, { stat = "Gun", cap = 2550 }, { stat = "Demon Fruit", cap = 2550 } },
        RESERVE = 0, BATCH_MAX = 25, SEND_DELAY = 0.15, VERIFY_TIMEOUT = 3, PAUSE_FOREIGN = 600, ARG_NAMES = {},
        REMOTE_FILE = "BloxStatsRemote.json", AUTO_PROBE = true,
        REMOTE_PATH = "Backpack.BackpackFrame.StatsFrame.AddingPoints.LocalScript.RemoteEvent",
        PROBE_CODES = { "Str", "Vit", "Int", "SP", "Agi" },
        PROBE_SHAPES = { { "AddPoints", 0.5, "{stat}" }, { "AddPoints", 1, "{stat}" }, { "AddPoints", "{stat}", 1 } },
        -- WHY first: the long-standing Blox Fruits remote. {stat} = "Melee"/"Defense"/"Sword"/"Gun"/"Demon Fruit", {n} = points.
        COMMF_SHAPES = { { "AddPoint", "{stat}", "{n}" }, { "AddPoint", "{stat}" } },
        WATCH_REMOTE = false, LEARN_SECONDS = 120,
        PROBE_MIN_POINTS = 1, UI_FALLBACK = true,
    },
    RESPAWN = {
        ENABLED = true,
        SETTLE = 10,            -- seconds the new character must be alive (team chosen) before anything is judged
        WATCH = 45,             -- seconds without progress per rung before climbing to the next one
        RELOAD_COOLDOWN = 60,   -- hard floor between two hub reloads: death spam can never stack GUIs
        MAX_RELOADS = 3,        -- hub reloads per session, respawn recovery only
        STORM_COUNT = 4,        -- this many respawns within 3 minutes = death storm (alert, no extra reloads)
        KAITUN_RELOAD = false,  -- Kaitun: allow the hub reload rungs. Off by default: its window cannot be removed first, so a reload can stack loops
    },
    CODES = {
        ENABLED = true,
        -- Seed list: codes can be dead by the time you run this, the server just answers "invalid" and the code is not retried.
        LIST = { "EASTEREXP", "LIGHTNINGABUSE", "Sub2Fer999", "Enyu_is_Pro", "Magicbus", "Starcodeheo", "Bluxxy", "fudd10",
                 "JCWK", "kittgaming", "Axiore", "TantaiGaming", "Sub2Daigrock", "StrawHatMaine", "Sub2CaptainMaui",
                 "Sub2OfficialNoobie", "Bignews", "SUB2GAMERROBOT_EXP1" },
        -- Optional: a raw text URL you control (one code per line, # = comment). Lets you add new codes without editing the script.
        FEED_URL = "",
        -- WHY a block list: stat reset / refund codes would erase the points the Stats module just spent.
        SKIP = { "SUB2GAMERROBOT_RESET1", "Sub2UncleKizaru", "Sub2NoobMaster123", "KITT_RESET" },
        SKIP_PATTERNS = { "reset", "refund" },
        START_DELAY = 10, GAP = 3, REPLY_TIMEOUT = 12, MAX_TRIES = 3,
    },
    SEA_GUARD = true, RENDER_OFF = true, FPS_CAP = 10, LOG_MAX_BYTES = 65536, STALL_AFTER = 120,
}

local HIGH_TIER = { "dragon","leopard","kitsune","dough","venom","shadow","control","spirit","mammoth","t-rex","trex",
    "gas","yeti","tiger","magnet","celestial","oni","crimson","skins","gold","east","west","buddha","portal","rumble",
    "lightning","phoenix","blizzard","gravity","pain","love","spider","sound","soul","quake","creation" }

local function GetKaitunConfig()
    return { ["Blox Fruits"] = {
        ["Hide UI"] = false, ["Select Weapon"] = "Melee", ["Select Team"] = "Pirates", ["White Screen"] = false, ["Speed Tween"] = 200,
        ["Lock Fps"] = { ["Enabled"] = true, ["FPS"] = 30 },
        ["Get Items"] = { ["Saber"] = true, ["Godhuman"] = true, ["Skull Guitar"] = true, ["Mirror Fractal"] = true,
            ["Cursed Dual Katana"] = true, ["Shark Anchor"] = true },
        ["Get Rare Items"] = { ["Rengoku"] = false, ["Dragon Trident"] = false, ["Pole (1st Form)"] = false, ["Gravity Blade"] = false },
        ["Get Race"] = { ["Race Quest"] = { ["Enabled"] = false, ["Race"] = { "Ghoul" } }, ["Pull Lever"] = true },
        ["Auto Awaken Fruit"] = false,
        ["Farm Fragments"] = { ["Enabled"] = false, ["Fragment"] = 50000 },
        ["Summon Rip Indra"] = true,
        ["Select Hop"] = { ["Hop If Found Near Exploiter"] = false, ["Hop Find rip_indra True Form"] = false,
            ["Hop Find Dough King"] = false, ["Hop Find Raids Castle"] = false, ["Hop Find Cake Queen"] = false,
            ["Hop Find Soul Reaper"] = false, ["Hop Find Darkbeard"] = false, ["Hop Find Mirage"] = false },
        ["Farm Mastery"] = { ["Enabled"] = false, ["Mode"] = "Bone", ["Weapon Farm"] = { "Melee" } },
        ["Sniper Fruit Shop"] = { ["Enabled"] = true, ["Fruit"] = { "Leopard-Leopard", "Kitsune-Kitsune", "Dragon-Dragon", "Yeti-Yeti", "Gas-Gas" } },
        ["Lock Fruit"] = {},
        ["Secret Quest"] = { ["Enabled"] = false },
        ["Webhook"] = { ["Enabled"] = false, ["Ping Discord"] = "<@>", ["Url"] = "" },
    } }
end

local function GetVxezeLevelConfig()
    return {
        ["Auto Fire Shoot Heart Leviathan"]=false,["Auto Farm Mastery 600 Gun In Inventory"]=false,["Auto Finish Train Draco Quest"]=false,["Auto Dodge Skill Seabeast"]=false,["Account Help"]=false,["Auto Reset When Complete Volcano"]=false,["Ignore Craft Volcanic Magnet"]=false,["Auto Trade Azure Ember"]=false,["Quest"]={["Race V2-V3"]=true,["Haki Rainbow"]=true},["Value Speed Fly Boat"]=3,["Hop Find Full Moon"]=false,["Auto Trial Draco"]=false,["Auto Aimbot Gun"]=false,["Fruits v2 Account Help"]=false,["Auto New World"]=false,["Drive Boat To Hydra"]=false,["Auto Summon Soul Ember"]=false,["Summon Dough King"]=false,["Auto Store Fruit"]=false,["Auto Sell Fishing"]=false,["Auto Get Fully Cyborg"]=false,["Use Click M1 Skull Guitar Leviathan"]=false,["Walk On Water"]=true,["ESP Island"]=false,["Multi Find Leviathan"]=false,["Auto Magnet Event"]=false,["Auto Buy Boat Beast Hunter"]=false,["Auto Get Rainbow Haki"]=false,["Boost Fps"]=false,["Fruits"]={["Farm Mastery Fruits"]=true,["Fruits Eat"]={"Gravity-Gravity","Pain-Pain"},["Auto Eat Fruits"]=false},["Auto Spawn Kitsune Island"]=false,["Auto Dragon Talon"]=false,["Change JumpPower"]=false,["Skill X Melee"]=0.5,["Hop Server [ Haki Color / Legendary Sword ]"]=false,["Hop Server Elite Hunter"]=false,["Auto Upgrade Sword Inventory"]=false,["Random Devil Fruit"]=false,["Auto Secret Quest"]=false,["Auto Aimbot"]=false,["Kill All Boss"]=false,["Sharkman Need Fish"]=false,["Use Your Boat Beast Hunter"]=false,["Min Player Join Dungeon"]=2,["Auto Yoru Mini (Hop Server)"]=false,["Auto Farm Observation"]=false,["Use Dragonstorm For Sea Event"]=false,["Auto Touch Pad Haki"]=false,["Attack Dough King"]=false,["Auto Yoru Mini"]=false,["Setup Kaitun v4 [ Fully ]"]=false,["Tween Safe if have Items"]=false,["Kill Aura Only Raid And Volcano"]=false,["Auto Get Ghoul"]=false,["Auto Finish Train Quest"]=false,["Skill F Blox Fruit"]=0.5,["Account Main"]=false,["Auto Get Cyborg"]=false,["Skill C Blox Fruit"]=0.5,["Auto Turn On V3 Near Door"]=false,["Auto Factory"]=false,["White Screen"]=false,["Notify Event Auto Refresh"]=false,["Auto Sharkman Karate V3"]=false,["Auto Dodge Skill Terrorshark"]=false,["Hop Find Boss [ Cake Prince / Tyrant of the Skies ]"]=false,["Auto TTK"]=false,["Use Click M1 Fruit Leviathan"]=false,["Auto Change Dragonstorm With Kill Leviathan"]=false,["Auto Raid"]=false,["% Health Player"]=40,["Auto Craft Haki Color [ Fully ]"]=false,["Auto Third World"]=false,["MiscItem"]={["Pole1st"]=true,["Dragon Trident"]=true,["Rengoku"]=true,["Spikey Trident"]=true,["Buddy"]=true,["Feathered Visage"]=true,["Gravity Blade"]=true,["Venom Bow"]=true,["Canvander"]=true,["Twin Hooks"]=true},["Kill Boss"]=false,["Auto Click"]=true,["Teleport Boat Other CFrame if Rough Sea"]=false,["Auto Electric Claw"]=false,["Speed Boat Auto Drive"]=300,["Auto Shark Anchor [ Fully ]"]=false,["Auto Pirate Raid"]=false,["Accept Quest [ Cake / Bone / Tiki ]"]=false,["Skill Z Sword"]=0.5,["Auto Collect Fruits"]=false,["Teleport To Kitsune Island"]=false,["Time Hop Server"]=5,["Will Back When over 10km"]=false,["Skill Z Gun"]=0.5,["Auto Find Leviathan"]=false,["Value Collect Chest to Hop"]=20,["Hop Find Fruits / Berries / Chests"]=false,["Auto Sea Event"]=false,["Auto Stats"]=false,["Auto Redeem Code"]=true,["Select Weapon"]="Melee",["Auto Sanguine Art"]=false,["Kill Aura With DragonStorm"]=false,["Auto Get Observation v1-2 [ Fully ]"]=false,["Farm Mob"]=false,["Use Click M1 Skull Guitar For Sea Event"]=false,["Auto CDK"]=false,["Auto Crafting Volcanic Magnet"]=false,["Hop Sever Raid"]=false,["Auto Turn On Observation"]=true,["Speed Tween"]=177,["Auto Join Dungeon"]=false,["Setting"]={["White Screen"]=false,["UiCheckItem"]=false},["Attack Darkbeard"]=false,["Auto Dodge Skill Mobs"]=false,["No Fog"]=false,["Auto Change Dragonstorm When Kill Boat"]=false,["Auto Turn On V3"]=false,["Tween Boat To Frozen Dimension"]=false,["Distance Teleport Y"]=0,["Skill Z Melee"]=0.5,["Select Method Farm"]="Level",["Just Use Skill when Player Active Ken"]=false,["Value Speed Tween Boat"]=250,["Dough King [ Fully ]"]=false,["Auto Start Leviathan"]=false,["ESP Berry"]=false,["Auto Multi Raid"]=false,["Auto Advanced Combat"]=false,["Change WalkSpeed"]=false,["Auto Pull Lever"]=false,["Auto Sharkman Karate"]=false,["Auto Buy Spy"]=false,["Auto Tushita"]=false,["Ignore Craft Volcanic Magnet Draco"]=false,["Auto Destroy IDK"]=false,["Ignore Boss"]=false,["Value Damage Multi Segments"]=30000,["Fully Trial Draco"]=false,["Auto Dojo Trainer"]=false,["Auto Trial"]=false,["Account Buy Chip"]=false,["Auto Get Cyborg Hop Collect Chest"]=false,["Kill players When complete Trial"]=false,["Time Delay Kill"]=5,["Use skill fast dont hold"]=false,["Auto Collect Bone"]=false,["Webhook Find Prehistoric Island"]=false,["Auto Get Full Melee [ Fully ]"]=false,["Use Click M1 Fruit For Sea Event"]=false,["Notify Event Only Current Sea"]=true,["Values Azure Ember"]=10,["Auto Turn On V4"]=false,["Input WalkSpeed"]=200,["Hop Server Kitsune Island"]=false,["Auto Pick Card Dungeon"]=false,["Spam Join"]=false,["Auto Farm Mastery 600 Sword In Inventory"]=false,["Auto Collect Chests"]=false,["Summon Soul Reaper"]=false,["Auto Yama"]=false,["Summon Darkbeard"]=false,["Buy Blox Fruit Sniper Shop"]=false,["Random Magnet Event"]=false,["Auto Trade Bone"]=false,["Hop Find Mirage Island [ Pull Lever ]"]=false,["Auto Open Chest"]=false,["Attack Multi Segments Leviathan"]=false,["Auto Saber"]=false,["Change Speed Boat"]=false,["Auto Buy Chip and Attack Law"]=false,["Auto Reset Vip Leviathan"]=false,["Collect Chest When Server Spawn Legend Items"]=false,["Distance Farm Aura"]=5000,["Auto Soul Guitar"]=false,["Hop Find Darkbeard"]=false,["Hop Server When Farm Observation"]=false,["Hop Server Find Boss"]=false,["Remove Notifications"]=true,["Auto Buy Chip For Account Select"]=false,["Farm Mastery"]=false,["Skill Z Blox Fruit"]=0.5,["Webhook Upgrade V4 + Train"]=false,["Auto Load Script"]=false,["Teleport Y"]=false,["Auto Upgrade Race V2-V3"]=false,["Drive Boat To Tiki"]=false,["Hop Find Dough King"]=false,["Auto Return Dungeon"]=false,["Select Skills Melee"]={["X"]=true,["C"]=true,["Z"]=true},["Skill X Blox Fruit"]=0.5,["Auto Observation v2"]=false,["Auto Slap Battle"]=false,["Select Skills Blox Fruit"]={["X"]=true,["C"]=true,["Z"]=true,["V"]=true,["F"]=true},["Skill C Melee"]=0.5,["Bring Mob Count"]=6,["Teleport Frozen Dimension"]=false,["Auto Awake Fruit"]=false,["Black Screen"]=false,["Auto Collect Soul Ember"]=false,["Auto Repair Ur Ship"]=false,["Attack Soul Reaper"]=false,["Account Start Dungeon"]=false,["Auto Dragon Hunter"]=false,["Auto Attack Leviathan"]=false,["Stack Train With Trial Race"]=false,["Auto rejoin Disconnect"]=false,["Fly Boat"]=false,["Auto Find Mirage"]=false,["Bring Mob"]=true,["Teleport Player"]=false,["Account Pick Slot Raid"]=false,["Attack No Animation"]=true,["Darkbeard [ Fully ]"]=false,["Auto Fishing"]=false,["Auto Choose Gear Draco"]=false,["Tween Until Have Sea Event"]=false,["Start Farm"]=true,["Auto Buy Gear Draco"]=false,["Auto Get Draco"]=false,["Webhook Destroy IDK"]=false,["Hop Server Get Ghoul"]=false,["Auto Choose Gears"]=false,["Teleport Acient Clock"]=false,["Auto Summon Rip Indra"]=false,["Auto Reset Character"]=false,["Auto Attack Dungeon"]=false,["Skill X Gun"]=0.5,["Auto Elite Hunter"]=false,["Auto Tween To Event Fishing Spot"]=false,["ESP Fruit"]=false,["Auto Buy Legendary Sword"]=false,["Auto Change Dragonstorm With Skull Guitar"]=false,["Noclip"]=false,["Get Fruit In Inventory Low Beli"]=false,["Attack Rip Indra"]=false,["Farm Material"]=false,["Ping Discord"]=false,["Use Portal Fruit Teleport"]=false,["Select Skills Gun"]={["Z"]=true,["X"]=true},["Skill X Sword"]=0.5,["Reset Character Buy Boat"]=false,["Auto Collect Berries"]=false,["Auto Turn On Buso"]=true,["Health %"]=40,["Webhook Store Fruit"]=false,["Auto Quest Fruits v2"]=false,["Auto Sea Event With Friend"]=false,["Auto Upgrade Dragon Talon"]=false,["Auto Farm Mastery 600 Melees"]=false,["Auto Upgrade Gun Inventory"]=false,["Auto God Human"]=true,["Select Skills Sword"]={["Z"]=true,["X"]=true},["Prevent Security Kick"]=true,["Auto Event Prehistoric Island"]=false,["Hidden Hop Dead Hour"]=true,["Use Skill when Kill Player"]=false,["Fully Event Prehistoric Island"]=false,["Auto Super Human"]=false,["Auto Collect Egg"]=false,["Auto Death Step"]=false,["ESP Player"]=false,["Change Size Reel"]=false,["Webhook"]={["Enable"]=false,["UrlWebhook"]=""},["Input JumpPower"]=200,["Ignore Collect Bone"]=false,["MainItem"]={["Hallow Scythe"]=true,["Get 3 Legendary Colors Haki"]=true,["Skull Guitar"]=true,["Cursed Dual Katana"]=true,["GodHuman"]=true,["Saber"]=true},["Auto Find Prehistoric Island"]=false,["Auto Buy Gear"]=false,["Noti Profile"]=false,["Skill V Blox Fruit"]=0.5,["Webhook Find Leviathan"]=false,["Webhook Find Mirage"]=false,["Auto Buy Haki Color Recipe"]=false,["Auto Upgrade Race V2-V3 Draco"]=false,["Auto Accept Quest Fishing"]=false,["Value Speed Boat"]=200
    }
end

local BELI_OVERRIDES = {
    ["Select Method Farm"] = "Cake", ["Accept Quest [ Cake / Bone / Tiki ]"] = true, ["Ignore Boss"] = true,
    ["% Health Player"] = 71, ["Time Delay Kill"] = 3, ["Speed Tween"] = 181, ["Input JumpPower"] = 251,
    ["Value Damage Multi Segments"] = 131411, ["Speed Boat Auto Drive"] = 349, ["Skill C Melee"] = 0, ["Distance Teleport Y"] = 800,
    ["Auto God Human"] = false,
    ["Auto Redeem Code"] = true,
}

local BELI_LEGACY_UI = {
    ["Boost Fps"] = true, ["Fps Cap"] = 10, ["Interface Scale"] = 90, ["Interface Text Boost"] = 0, ["Select Zone"] = "Zone 3"
}

----------------------------------------------------------------
-- 1. GLOBALS
----------------------------------------------------------------
local Players, RS, RunService = game:GetService("Players"), game:GetService("ReplicatedStorage"), game:GetService("RunService")
local HttpService, VirtualUser = game:GetService("HttpService"), game:GetService("VirtualUser")
local GuiService, VIM = game:GetService("GuiService"), game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local LP = Players.LocalPlayer
local env = getgenv()
local UID = tostring(LP.UserId)

repeat task.wait(1) until game:IsLoaded()
local PG = LP:WaitForChild("PlayerGui")
local Remotes = RS:WaitForChild("Remotes", 30)

if env.BloxSM and env.BloxSM.Unload then pcall(env.BloxSM.Unload) end

local S = { alive = true, conns = {}, beats = {} }
local Log, FS, Task, WH, Group, Store, Rot, Sess, Dead = {}, {}, {}, {}, {}, {}, {}, {}, {}
local Vx, Noti, Input, Team, Farm, Gacha, Sea, UI, Watch, Stats = {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
local Codes = {}
local Resp = {}
local Swap, Weapon = {}, {}

local function clamp(x, lo, hi) if x < lo then return lo elseif x > hi then return hi end return x end
local function hasHRP() local c = LP.Character return (c and c:FindFirstChild("HumanoidRootPart")) and true or false end
local function commF() return Remotes and Remotes:FindFirstChild("CommF_") end

----------------------------------------------------------------
-- 2. CORE
----------------------------------------------------------------
function FS.ok() return type(isfile) == "function" and type(readfile) == "function" and type(writefile) == "function" end
function FS.exists(p) if type(isfile) ~= "function" then return false end local ok, r = pcall(isfile, p) return ok and r and true or false end
function FS.read(p)
    if not FS.exists(p) then return nil end
    local ok, d = pcall(readfile, p)
    if ok and type(d) == "string" then return d end
end
function FS.write(p, d) if type(writefile) ~= "function" then return false end return (pcall(writefile, p, d)) end
function FS.delete(p) if type(delfile) == "function" and FS.exists(p) then pcall(delfile, p) end end
function FS.readJSON(p)
    local d = FS.read(p)
    if not d then return nil end
    local ok, t = pcall(HttpService.JSONDecode, HttpService, d)
    if ok and type(t) == "table" then return t end
end
function FS.writeJSON(p, t)
    local ok, s = pcall(HttpService.JSONEncode, HttpService, t)
    if ok then return FS.write(p, s) end
    return false
end

Log.path, Log.buf, Log.size = "BloxLog_" .. UID .. ".txt", {}, 0
Log.size = FS.ok() and #(FS.read(Log.path) or "") or 0
function Log.add(level, msg)
    local line = os.date("%H:%M:%S") .. " [" .. level .. "] " .. tostring(msg)
    Log.buf[#Log.buf + 1] = line
    if #Log.buf > 300 then table.remove(Log.buf, 1) end
    if level == "I" then print("[BloxSM] " .. tostring(msg)) else warn("[BloxSM] " .. tostring(msg)) end
end
function Log.flush()
    if #Log.buf == 0 or not FS.ok() then return end
    local chunk = table.concat(Log.buf, "\n") .. "\n"
    Log.buf = {}
    if type(appendfile) == "function" then pcall(appendfile, Log.path, chunk)
    else FS.write(Log.path, (FS.read(Log.path) or "") .. chunk) end
    Log.size = Log.size + #chunk
    if Log.size > CFG.LOG_MAX_BYTES then
        local cur = FS.read(Log.path)
        if cur then FS.write(Log.path .. ".1", cur) end
        FS.write(Log.path, "")
        Log.size = 0
    end
end

function Task.spawn(name, fn, ...)
    local args = table.pack(...)
    return task.spawn(function()
        local ok, err = xpcall(function() return fn(table.unpack(args, 1, args.n)) end, debug.traceback)
        if not ok then Log.add("E", name .. " crashed: " .. tostring(err)) end
    end)
end
function Task.service(name, interval, fn)
    Task.spawn(name, function()
        local failures = 0
        while S.alive do
            S.beats[name] = os.clock()
            local ok, res = pcall(fn)
            local d = interval
            if ok then
                failures = 0
                if res == false then break end
                if type(res) == "number" then d = res end
            else
                failures = failures + 1
                d = math.min(60, interval * (2 ^ failures))
                Log.add("E", name .. " error: " .. tostring(res))
            end
            task.wait(math.max(0.2, d))
        end
        S.beats[name] = nil
    end)
end

----------------------------------------------------------------
-- 3. WEBHOOK
----------------------------------------------------------------
WH.queues = { fruit = {}, report = {} }
WH.tokens = { fruit = CFG.WH_BURST, report = CFG.WH_BURST }
WH.lastRefill, WH.dirty, WH.touchedAt = {}, false, 0
WH.outbox = "BloxOutbox_" .. UID .. ".json"
WH.ITEM_TTL = { [1] = 6 * 3600, [2] = 24 * 3600, [3] = 72 * 3600 }

WH.warned = {}
function WH.url(target)
    local u = CFG.WEBHOOKS[target]
    if type(u) ~= "string" or u == "" or u == "REPLACE_ME" then return nil end
    -- v22: a fragment / non-Discord string used to be queued, retried 6 times and dropped, forever and silently.
    local good = u:find("^https://[%w%.%-]*discord%.com/api/webhooks/%d+/[%w%-_]+") or u:find("^https://[%w%.%-]*discordapp%.com/api/webhooks/%d+/[%w%-_]+")
    if not good then
        if not WH.warned[target] then
            WH.warned[target] = true
            Log.add("W", "webhook '" .. target .. "' is not a full https://discord.com/api/webhooks/<id>/<token> URL, target disabled")
        end
        return nil
    end
    return u
end
function WH.pending() local n = 0 for _, q in pairs(WH.queues) do n = n + #q end return n end

function WH.send(target, title, desc, color, prio)
    if not WH.url(target) then return false end
    local q = WH.queues[target]
    if not q then return false end
    prio = prio or 1
    if #q >= CFG.WH_QUEUE_MAX then
        local idx = 1
        for i, it in ipairs(q) do if it.prio < 2 then idx = i break end end
        table.remove(q, idx)
    end
    q[#q + 1] = {
        prio = prio, tries = 0, notBefore = 0, ts = os.time(),
        payload = { username = "Fruit Factory", embeds = { {
            title = title, description = desc, color = color,
            footer = { text = "Account: " .. LP.Name }, timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") } } },
    }
    WH.dirty = true
    if prio >= 3 then WH.saveOutbox() end
    return true
end

local function headerGet(h, name)
    if type(h) ~= "table" then return nil end
    for k, v in pairs(h) do if string.lower(tostring(k)) == name then return v end end
end
function WH.post(url, payload)
    local req = (syn and syn.request) or request or http_request
    if not req then return nil end
    local okb, body = pcall(HttpService.JSONEncode, HttpService, payload)
    if not okb then return 400 end
    local ok, res = pcall(req, { Url = url, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
    if not ok or type(res) ~= "table" then return nil end
    local status = tonumber(res.StatusCode or res.Status)
    local retry
    if status == 429 then
        retry = tonumber(headerGet(res.Headers, "retry-after"))
        if not retry then
            local okj, b = pcall(HttpService.JSONDecode, HttpService, res.Body or "{}")
            if okj and type(b) == "table" then retry = tonumber(b.retry_after) end
        end
        if retry and retry > 600 then retry = retry / 1000 end
    end
    return status, retry
end

function WH.snapshot()
    local items = {}
    for target, q in pairs(WH.queues) do
        for _, it in ipairs(q) do
            if #items < CFG.WH_QUEUE_MAX then items[#items + 1] = { target = target, prio = it.prio, ts = it.ts, payload = it.payload } end
        end
    end
    return items
end
function WH.saveOutbox()
    WH.dirty = false
    WH.touchedAt = os.time()
    local items = WH.snapshot()
    if #items == 0 then FS.delete(WH.outbox) else FS.writeJSON(WH.outbox, { owner = UID, savedAt = os.time(), items = items }) end
end
function WH.import(items)
    local n, now = 0, os.time()
    for _, it in ipairs(items or {}) do
        if type(it) == "table" and WH.queues[it.target] and type(it.payload) == "table" and WH.url(it.target) then
            local prio, ts = tonumber(it.prio) or 1, tonumber(it.ts) or now
            if now - ts <= (WH.ITEM_TTL[prio] or 3600) and #WH.queues[it.target] < CFG.WH_QUEUE_MAX then
                table.insert(WH.queues[it.target], { prio = prio, tries = 0, notBefore = 0, ts = ts, payload = it.payload })
                n = n + 1
            end
        end
    end
    return n
end
function WH.loadOutbox()
    local d = FS.readJSON(WH.outbox)
    local items = d and (d.items or d)
    if type(items) ~= "table" then return end
    local n = WH.import(items)
    if n > 0 then Log.add("I", "outbox restored: " .. n .. " message(s)") WH.dirty = true end
end

function WH.adopt()
    if type(listfiles) ~= "function" then return end
    local ok, files = pcall(listfiles, "")
    if not ok or type(files) ~= "table" then return end
    for _, f in ipairs(files) do
        local name = tostring(f):match("([^/\\]+)$") or ""
        if name:match("^BloxOutbox_%d+%.json$") and name ~= WH.outbox then
            local d = FS.readJSON(name)
            if type(d) == "table" and d.owner and tostring(d.owner) ~= UID and os.time() - (tonumber(d.savedAt) or 0) > CFG.WH_ORPHAN_AFTER then
                FS.writeJSON(name, { owner = UID, savedAt = os.time(), items = d.items })
                task.wait(0.5 + math.random())
                local chk = FS.readJSON(name)
                if chk and tostring(chk.owner) == UID then
                    local n = WH.import(d.items)
                    FS.delete(name)
                    WH.dirty = true
                    Log.add("I", "adopted " .. n .. " orphaned message(s) from " .. name)
                end
            end
        end
    end
end

function WH.pump(target)
    local q = WH.queues[target]
    local clock, now = os.clock(), os.time()
    local last = WH.lastRefill[target] or clock
    WH.lastRefill[target] = clock
    WH.tokens[target] = math.min(CFG.WH_BURST, WH.tokens[target] + (clock - last) * CFG.WH_PER_MIN / 60)
    local item = q[1]
    if item and now >= item.notBefore and WH.tokens[target] >= 1 then
        local holdFile = "BloxWHHold_" .. target .. ".txt"
        local hold = tonumber(FS.read(holdFile)) or 0
        local url = WH.url(target)
        if not url then
            table.remove(q, 1)
        elseif now >= hold then
            WH.tokens[target] = WH.tokens[target] - 1
            local status, retry = WH.post(url, item.payload)
            if status and status >= 200 and status < 300 then
                table.remove(q, 1)
                WH.dirty = true
            elseif status == 429 then
                local wait = (retry or 5) + math.random() * 2
                FS.write(holdFile, tostring(math.ceil(os.time() + wait)))
                item.notBefore = os.time() + wait
                item.tries = item.tries + 1
            elseif status and status >= 400 and status < 500 then
                table.remove(q, 1)
                Log.add("W", "webhook " .. target .. " rejected with HTTP " .. status .. ", message dropped")
                WH.dirty = true
            else
                item.tries = item.tries + 1
                item.notBefore = os.time() + math.min(300, 5 * 2 ^ item.tries)
            end
            if item.tries >= CFG.WH_MAX_TRIES and q[1] == item then
                table.remove(q, 1)
                Log.add("W", "webhook " .. target .. ": gave up after " .. item.tries .. " tries")
                WH.dirty = true
            end
        end
    end
    if WH.dirty then WH.saveOutbox()
    elseif WH.pending() > 0 and now - WH.touchedAt >= 30 then WH.saveOutbox() end
    return 1
end

----------------------------------------------------------------
-- 4. GROUP LOCK
----------------------------------------------------------------
Group.token = string.sub((HttpService:GenerateGUID(false):gsub("%-", "")), 1, 16)
Group.id, Group.num, Group.ready, Group.lockOk, Group.lost, Group.seq = nil, nil, false, false, false, 0
Group.waiters, Group.changeHooks, Group.acquiring, Group.provisionalUsed = {}, {}, false, nil
Group.homePath = "BloxHome_" .. UID .. ".txt"

local function lockPath(n) return "Lock_" .. n .. ".txt" end
function Group.readLock(n)
    local d = FS.read(lockPath(n))
    if not d then return nil end
    local uid, token, seq, ts = string.match(d, "^(%d+)|(%x+)|(%d+)|(%d+)")
    if not uid then return nil end
    return { uid = uid, token = token, seq = tonumber(seq), ts = tonumber(ts) }
end
function Group.writeLock(n, seq, ts) FS.write(lockPath(n), UID .. "|" .. Group.token .. "|" .. seq .. "|" .. (ts or os.time())) end

function Group.currentId()
    if Group.id then return Group.id end
    local home = tonumber(FS.read(Group.homePath))
    local id = "Group" .. ((home and home >= 1 and home <= CFG.MAX_GROUPS) and home or 1)
    Group.provisionalUsed = id
    return id
end
function Group.whenReady(fn) if Group.ready then Task.spawn("group-waiter", fn) else Group.waiters[#Group.waiters + 1] = fn end end

local function claimable(n, dead)
    local L = Group.readLock(n)
    if not L or L.token == Group.token then return true end
    if dead and L.token == dead.token and L.seq == dead.seq then return true end
    return os.time() - L.ts > CFG.LOCK_STALE
end
local function tryClaim(n, dead)
    if not claimable(n, dead) then return false end
    task.wait(math.random() * 0.4)
    if not claimable(n, dead) then return false end
    Group.writeLock(n, 0)
    task.wait(1 + math.random())
    local L = Group.readLock(n)
    if L and L.token == Group.token then
        task.wait(1)
        L = Group.readLock(n)
        if L and L.token == Group.token then return true end
    end
    return false
end

function Group.pickSlot()
    if not FS.ok() then return 1, false end
    local now = os.time()
    local home = tonumber(FS.read(Group.homePath))
    local order = {}
    if home and home >= 1 and home <= CFG.MAX_GROUPS then order[#order + 1] = home end
    for n = 1, CFG.MAX_GROUPS do if n ~= home then order[#order + 1] = n end end
    local free, fresh = {}, {}
    for _, n in ipairs(order) do
        local L = Group.readLock(n)
        if (not L) or now - L.ts > CFG.LOCK_STALE then free[#free + 1] = n else fresh[#fresh + 1] = { n = n, seq = L.seq, token = L.token } end
    end
    if home and free[1] == home and tryClaim(home) then return home, true end
    local dead = {}
    if #fresh > 0 then
        task.wait(CFG.PROBE_WAIT)
        local usable = {}
        for _, n in ipairs(free) do usable[n] = true end
        for _, f in ipairs(fresh) do
            local L = Group.readLock(f.n)
            if (not L) or (L.token == f.token and L.seq == f.seq) then usable[f.n] = true dead[f.n] = { token = f.token, seq = f.seq } end
        end
        free = {}
        for _, n in ipairs(order) do if usable[n] then free[#free + 1] = n end end
    end
    for _, n in ipairs(free) do
        if tryClaim(n, dead[n]) then return n, true end
    end
    return 1, false
end

function Group.acquire()
    if Group.acquiring then return end
    Group.acquiring = true
    Task.spawn("group-acquire", function()
        local oldId = Group.id
        local okp, n, ok = pcall(Group.pickSlot)
        if not okp then Log.add("E", "slot selection crashed: " .. tostring(n)) n, ok = nil, false end
        Group.acquiring = false
        if ok then
            Group.num, Group.lockOk, Group.lost, Group.seq, Group.attempts = n, true, false, 0, 0
            Group.id = "Group" .. n
            FS.write(Group.homePath, tostring(n))
        else
            Group.lockOk = false
            if not Group.id then Group.num, Group.id = 1, "Group1" end
            Group.attempts = (Group.attempts or 0) + 1
        end
        Group.retryAt = os.time() + math.min(CFG.LOCK_RETRY_MAX, 15 * 2 ^ math.min(Group.attempts or 0, 5))
        Log.add(ok and "I" or "W", "group " .. Group.id .. (ok and "" or " (NO LOCK - retrying in the background)"))
        local prev = oldId or Group.provisionalUsed
        if prev and prev ~= Group.id then for _, fn in ipairs(Group.changeHooks) do pcall(fn, prev, Group.id) end end
        if not Group.ready then
            Group.ready = true
            for _, fn in ipairs(Group.waiters) do Task.spawn("group-waiter", fn) end
            Group.waiters = {}
        end
    end)
end

function Group.refresh()
    if not Group.ready or Group.acquiring then return end
    if not Group.lockOk then
        if os.time() >= (Group.retryAt or 0) then Log.add("I", "retrying group lock") Group.acquire() end
        return
    end
    local L = Group.readLock(Group.num)
    if L == nil or L.token == Group.token then
        Group.seq = Group.seq + 1
        Group.writeLock(Group.num, Group.seq)
    else
        Group.lost = true
        Log.add("W", "lock on " .. Group.id .. " was taken by another instance, re-acquiring")
        Group.lockOk = false
        Group.retryAt = 0
        Group.acquire()
    end
end

function Group.release()
    if Group.ready and Group.lockOk and Group.num then
        local L = Group.readLock(Group.num)
        if L and L.token == Group.token then Group.writeLock(Group.num, Group.seq, 0) end
    end
end

----------------------------------------------------------------
-- 5. STATE STORE
----------------------------------------------------------------
Store.path = "BloxState_" .. UID .. ".json"
Store.data = { lastRoll = 0, bootCount = 0, rolls = 0, highTier = 0, codes = {} }   -- codes: per-account redeem results
Store.dirty = false
function Store.set(k, v) Store.data[k] = v Store.dirty = true end
function Store.load()
    local d = FS.readJSON(Store.path)
    if d then for k, v in pairs(Store.data) do if type(d[k]) == type(v) then Store.data[k] = d[k] end end end
    if Store.data.lastRoll == 0 then
        local best = 0
        for n = 0, CFG.MAX_GROUPS do
            local p = (n == 0) and ("GachaLast_" .. UID .. ".txt") or ("GachaLast_Group" .. n .. "_" .. UID .. ".txt")
            local t = tonumber(FS.read(p))
            if t and t > best then best = t end
        end
        if best > 0 then Store.data.lastRoll = best Log.add("I", "migrated last roll time from v19 files") end
    end
    Store.data.bootCount = Store.data.bootCount + 1
    Store.dirty = true
end
function Store.save(force)
    if not (Store.dirty or force) then return end
    Store.dirty = false
    FS.writeJSON(Store.path, Store.data)
end

----------------------------------------------------------------
-- 6. ROTATION + SESSION
----------------------------------------------------------------
Rot.id = nil
function Rot.path() return "RotationState_" .. (Rot.id or Group.currentId()) .. ".txt" end
function Rot.accPath() return "RotAcc_" .. (Rot.id or Group.currentId()) .. "_" .. UID .. ".txt" end
function Rot.load()
    local st = { t = CFG.SESSION_BASE, adj = 0, exit = 0, exit_by = "", oh = 90, n = 0, bad = 0 }
    local d = FS.readJSON(Rot.path())
    if d then for k, v in pairs(st) do if type(d[k]) == type(v) then st[k] = d[k] end end end
    st.t = clamp(st.t, CFG.SESSION_BASE, CFG.SESSION_MAX)
    return st
end
function Rot.save(st) FS.writeJSON(Rot.path(), st) end
function Rot.markExit() local st = Rot.load() st.exit, st.exit_by = os.time(), LP.Name Rot.save(st) end

function Rot.learn(now)
    local st = Rot.load()
    local accStart = tonumber(FS.read(Rot.accPath()))
    local P = accStart and (now - accStart) or nil
    local gap = st.exit > 0 and (now - st.exit) or nil
    if gap and st.exit_by ~= LP.Name and gap > 0 and gap < 900 then
        st.oh = math.floor(0.8 * st.oh + 0.2 * gap)
    end
    if P and Store.data.lastRoll > 0 and P >= CFG.MIN_VALID_P and Group.lockOk then
        st.n = st.n + 1
        local boot = st.n <= CFG.BOOTSTRAP_CYCLES
        local alive = clamp(math.floor(P / (st.t + st.oh) + 0.5), 1, CFG.MAX_GROUPS)
        local epoch = alive * (st.t + st.oh)
        local cooled = boot or (now - st.adj) >= 0.8 * epoch
        local R = (Store.data.lastRoll + CFG.ROLL_INTERVAL) - now + CFG.ROLL_MARGIN
        local step = boot and CFG.ROT_MAX_STEP * 2 or CFG.ROT_MAX_STEP
        if R > 0 then st.bad = st.bad + 1 else st.bad = 0 end
        if R > 0 then
            if st.bad >= CFG.ROT_BAD_LIMIT and st.t < CFG.SESSION_MAX then
                local old = st.t
                st.t = clamp(math.ceil((CFG.ROLL_INTERVAL + CFG.ROLL_MARGIN) / alive) - st.oh, st.t, CFG.SESSION_MAX)
                st.adj, st.bad = now, 0
                Log.add("W", string.format("timer did not converge after %d short cycles, jumping to %.1f min (was %.1f)", CFG.ROT_BAD_LIMIT, st.t / 60, old / 60))
            elseif st.t >= CFG.SESSION_MAX then
                Log.add("W", "gacha cooldown not over (" .. R .. "s) but session length is already at the maximum")
                if st.bad == CFG.ROT_BAD_LIMIT then
                    WH.send("report", "Rotation cannot satisfy the cooldown",
                        Group.currentId() .. ": " .. st.bad .. " cycles in a row with ~" .. alive .. " live accounts. Remove dead accounts from the rotation.", 15158332, 3)
                end
            elseif cooled then
                local old = st.t
                st.t = math.min(CFG.SESSION_MAX, st.t + math.min(step, math.ceil(R / alive)))
                st.adj = now
                Log.add("W", string.format("rotation too short (~%d live accounts, short %ds): session %.1f -> %.1f min",
                    alive, R, old / 60, st.t / 60))
            end
        elseif not boot and R < -CFG.SLACK_DECAY and st.t > CFG.SESSION_BASE and cooled then
            local old = st.t
            st.t = math.max(CFG.SESSION_BASE, st.t - 60)
            st.adj = now
            Log.add("I", string.format("rotation loose: session %.1f -> %.1f min", old / 60, st.t / 60))
        end
    end
    Rot.save(st)
    FS.write(Rot.accPath(), tostring(now))
    return st.t
end

Sess.active, Sess.endAt, Sess.startedAt, Sess.signaledAt, Sess.rejoinTried = false, 0, 0, nil, false
Sess.monoEnd, Sess.fileId, Sess.state, Sess.acked, Sess.alerted, Sess.signalFails = math.huge, nil, "idle", false, false, 0
function Sess.filePath(id) return "SessionEnd_" .. (id or Group.currentId()) .. "_" .. UID .. ".txt" end
function Sess.signalPath() return LP.Name .. "_winterswap.json" end
Sess.SIGNAL_BODY = '{"status":"done"}'

local function validEnd(t, now) return t ~= nil and t > 1000000000 and t <= now + CFG.SESSION_MAX + 60 end

function Sess.findExisting(id, now)
    local t = tonumber(FS.read(Sess.filePath(id)))
    if t then return t, id end
    local bestT, bestId
    for n = 1, CFG.MAX_GROUPS do
        local gid = "Group" .. n
        local v = tonumber(FS.read(Sess.filePath(gid)))
        if validEnd(v, now) and (not bestT or v > bestT) then bestT, bestId = v, gid end
    end
    return bestT, bestId
end

function Sess.migrate()
    if not Sess.active or not Sess.fileId or not Group.id or Sess.fileId == Group.id then return end
    local body = tostring(Sess.endAt)
    FS.write(Sess.filePath(Group.id), body)
    if FS.read(Sess.filePath(Group.id)) == body then
        FS.delete(Sess.filePath(Sess.fileId))
        Log.add("I", "session file migrated " .. Sess.fileId .. " -> " .. Group.id)
        Sess.fileId = Group.id
    end
end

function Sess.resetCounters()
    Farm.reset() Sea.reset() Gacha.resetSession() Resp.reset()
    Dead.reason, Dead.noCharSince = nil, nil
    Sess.signaledAt, Sess.rejoinTried, Sess.acked, Sess.alerted, Sess.signalFails = nil, false, false, false, 0
    Sess.ackedAt = nil
    Swap.reset()
end

function Sess.start()
    if Sess.active then return end
    local now = os.time()
    local id = Group.currentId()
    Rot.id = id
    local endAt, foundId = Sess.findExisting(id, now)
    if endAt and not validEnd(endAt, now) and endAt > now then
        Log.add("W", "session file end time is implausible (" .. math.floor(endAt - now) .. "s ahead), starting a new session")
        endAt = nil
    end
    local fresh = true
    if endAt then
        if now < endAt then fresh = false Log.add("I", "resuming session, " .. math.ceil((endAt - now) / 60) .. " min left")
        elseif now - endAt <= CFG.SESSION_GRACE then fresh = false Log.add("I", "session just expired, signalling") end
    end
    if fresh then
        endAt = now + Rot.learn(now)
        FS.delete(Sess.signalPath())
        Log.add("I", "new session, " .. math.floor((endAt - now) / 60) .. " min")
    end
    if fresh or (foundId and foundId ~= id) then
        local body = tostring(endAt)
        FS.write(Sess.filePath(id), body)
        if FS.read(Sess.filePath(id)) ~= body then
            Log.add("E", "session file could not be written")
            WH.send("report", "Session file write failed", "Account " .. LP.Name .. " cannot write " .. Sess.filePath(id), 15158332, 3)
        end
        if foundId and foundId ~= id then FS.delete(Sess.filePath(foundId)) end
    end
    Sess.resetCounters()
    Sess.endAt, Sess.startedAt, Sess.active, Sess.fileId = endAt, now, true, id
    Sess.monoEnd = os.clock() + math.max(0, endAt - now)
    Sess.state = "active"
    UI.showButton(false)
end
function Sess.stop() Sess.active = false Sess.state = "stopped" UI.showButton(true) UI.status("Stopped manually") end

function Sess.writeSignal()
    for _ = 1, CFG.SIGNAL_WRITE_TRIES do
        FS.write(Sess.signalPath(), Sess.SIGNAL_BODY)
        if FS.read(Sess.signalPath()) == Sess.SIGNAL_BODY then return true end
        task.wait(0.3)
    end
    return false
end
function Sess.signal(reason)
    if Sess.signaledAt then return end
    if not Sess.writeSignal() then
        Sess.signalFails = Sess.signalFails + 1
        Log.add("E", "signal file could not be written (" .. Sess.signalFails .. ")")
        if Sess.signalFails == 3 then
            WH.send("report", "Signal write failing", "Account " .. LP.Name .. " cannot write " .. Sess.signalPath(), 15158332, 3)
        end
        return
    end
    Sess.signaledAt, Sess.state = os.time(), "signaled"
    Rot.markExit()
    Log.add("I", "session end signal written (" .. reason .. ")")
    UI.status("Done (" .. reason .. "), waiting for account switch")
end

function Sess.guard()
    if not Sess.active then return 3 end
    Sess.migrate()
    local now = os.time()
    if not Sess.signaledAt then
        if Dead.reason then Sess.signal("dead: " .. Dead.reason)
        elseif now >= Sess.endAt or os.clock() >= Sess.monoEnd then Sess.signal("timeout") end
    else
        if not Sess.acked then
            if not FS.exists(Sess.signalPath()) then
                Sess.acked, Sess.ackedAt = true, now
                Log.add("I", "signal consumed by the scheduler")
            elseif now - Sess.signaledAt >= CFG.SIGNAL_ALERT_AFTER and not Sess.alerted then
                Sess.alerted = true
                Log.add("W", "signal file not consumed after " .. CFG.SIGNAL_ALERT_AFTER .. "s")
                WH.send("report", "Signal not consumed", "Account " .. LP.Name .. ": the scheduler has not picked up the session-end signal", 15158332, 3)
            end
        end
        if Dead.reason and CFG.AUTO_REJOIN and not Sess.rejoinTried and not Sess.acked and now - Sess.signaledAt >= CFG.REJOIN_AFTER then
            Sess.rejoinTried = true
            Log.add("W", "still alive after dead-session signal, trying to rejoin")
            pcall(function() TeleportService:Teleport(game.PlaceId, LP) end)
        end
    end
    return 3
end

----------------------------------------------------------------
-- 7. DEAD-SESSION
----------------------------------------------------------------
Dead.reason, Dead.noCharSince = nil, nil
function Dead.mark(r)
    if Dead.reason then return end
    Dead.reason = r
    Log.add("E", "dead session: " .. r)
    WH.send("report", "Dead session", "Account " .. LP.Name .. ": " .. r, 16711680, 3)
end
function Dead.watch()
    if not Sess.active or Sess.signaledAt then Dead.noCharSince = nil return 10 end
    if hasHRP() then Dead.noCharSince = nil
    else
        Dead.noCharSince = Dead.noCharSince or os.clock()
        if os.clock() - Dead.noCharSince > CFG.DEAD_NO_CHAR then Dead.mark("no character for " .. CFG.DEAD_NO_CHAR .. "s") end
    end
    return 10
end

----------------------------------------------------------------
-- 8. VXEZE LOADER
----------------------------------------------------------------
local CONFLICT_KEYWORDS = { "hop", "rejoin", "load script", "webhook", "spam join", "store fruit", "reset character", "white screen", "black screen" }
local function words(s) return " " .. (string.lower(tostring(s)):gsub("[^%w]+", " ")) .. " " end
local function hasWord(key, kw) return string.find(words(key), words(kw), 1, true) ~= nil end

function Vx.sanitize(cfg)
    local n = 0
    for k, v in pairs(cfg) do
        if type(k) == "string" and v == true then
            for _, kw in ipairs(CONFLICT_KEYWORDS) do
                if hasWord(k, kw) then cfg[k] = false n = n + 1 break end
            end
        end
    end
    if type(cfg["Webhook"]) == "table" then cfg["Webhook"]["Enable"] = false end
    return n
end
function Vx.applyOverrides(cfg)
    cfg["Start Farm"], cfg["Remove Notifications"] = true, true
    cfg["Auto Load Script"] = false
    for _, k in ipairs(CFG.NOTI_DISABLE_KEYS) do if type(cfg[k]) == "boolean" then cfg[k] = false end end
end

-- v22: nested-path helpers (MainItem.GodHuman lives one level down, the v21 snapshot only covered top-level keys)
local function pathGet(root, path)
    local t = root
    for i = 1, #path - 1 do
        if type(t) ~= "table" then return nil end
        t = t[path[i]]
    end
    if type(t) ~= "table" then return nil end
    return t[path[#path]]
end
local function pathSet(root, path, value)
    local t = root
    for i = 1, #path - 1 do
        if type(t) ~= "table" then return false end
        t = t[path[i]]
    end
    if type(t) ~= "table" then return false end
    t[path[#path]] = value
    return true
end

-- Force every boolean key whose name contains one of `patterns` to false, at any depth. Appends changed paths to `out`.
function Vx.forceOffDeep(tbl, patterns, prefix, out, depth)
    out, prefix, depth = out or {}, prefix or "", depth or 0
    if depth > 4 or type(tbl) ~= "table" then return out end
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            Vx.forceOffDeep(v, patterns, prefix .. tostring(k) .. ".", out, depth + 1)
        elseif v == true and type(k) == "string" then
            local name = string.lower(k)
            for _, p in ipairs(patterns) do
                if string.find(name, p, 1, true) then tbl[k] = false out[#out + 1] = prefix .. k break end
            end
        end
    end
    return out
end

-- Absolute forced values, evaluated once per boot from the account level.
Vx.forced = {}
function Vx.buildForced(lv)
    local f = { { { "Auto Load Script" }, false } }
    if lv < CFG.GODHUMAN_OFF_BELOW then
        f[#f + 1] = { { "MainItem", "GodHuman" }, false }
        f[#f + 1] = { { "Auto God Human" }, false }
    end
    Vx.forced = f
end

-- Apply forced values + observation kill-switch + protected top-level keys to ONE config table.
function Vx.enforceOne(cfg)
    local changed = {}
    for _, f in ipairs(Vx.forced) do
        local cur = pathGet(cfg, f[1])
        if cur ~= nil and cur ~= f[2] and pathSet(cfg, f[1], f[2]) then changed[#changed + 1] = table.concat(f[1], ".") end
    end
    Vx.forceOffDeep(cfg, CFG.FORCE_OFF_PATTERNS, "", changed)
    if Vx.snap then
        for _, k in ipairs(Vx.PROTECT) do
            if Vx.snap[k] ~= nil and cfg[k] ~= Vx.snap[k] then cfg[k] = Vx.snap[k] changed[#changed + 1] = k end
        end
    end
    return changed
end

-- The hub may keep its own copy of the config (getgenv().<something>.Config). Find config-shaped tables so the guard
-- covers them too. Scanned at most every 30s, budgeted, and every iteration is pcall-protected.
Vx.copiesAt, Vx.copiesCache = 0, {}
function Vx.copies()
    if os.time() - Vx.copiesAt < 30 then return Vx.copiesCache end
    Vx.copiesAt = os.time()
    local main = type(env.Config) == "table" and env.Config or nil
    local out, seen, budget = {}, {}, 20000
    if main then seen[main] = true end
    local function consider(t)
        if type(t) == "table" and not seen[t] and rawget(t, "Select Method Farm") ~= nil then
            seen[t] = true
            out[#out + 1] = t
            return true
        end
        return false
    end
    local function scanInner(t)
        pcall(function()
            for _, v2 in next, t do
                budget = budget - 1
                if budget <= 0 then return end
                consider(v2)
            end
        end)
    end
    for _, root in ipairs({ env, _G }) do
        pcall(function()
            for _, v in next, root do
                budget = budget - 1
                if budget <= 0 then return end
                if type(v) == "table" and v ~= env and v ~= _G and not seen[v] then
                    if not consider(v) then scanInner(v) end
                end
            end
        end)
    end
    Vx.copiesCache = out
    return out
end

Vx.flipSeen = {}
function Vx.enforceAll()
    if Vx.hub == "kaitun" then return Vx.kaitunEnforceLive() end   -- v24: the Kaitun config has a different shape
    local total = 0
    local targets = {}
    if type(env.Config) == "table" then targets[1] = { env.Config, "env.Config" } end
    for i, t in ipairs(Vx.copies()) do targets[#targets + 1] = { t, "copy#" .. i } end
    for _, tg in ipairs(targets) do
        local ok, changed = pcall(Vx.enforceOne, tg[1])
        if ok and #changed > 0 then
            total = total + #changed
            local fresh, now = {}, os.time()
            for _, p in ipairs(changed) do
                local id = tg[2] .. ":" .. p
                if (Vx.flipSeen[id] or 0) + 60 <= now then Vx.flipSeen[id] = now fresh[#fresh + 1] = p end
            end
            if #fresh > 0 then Log.add("W", "config guard (" .. tg[2] .. ") re-forced: " .. table.concat(fresh, ", ", 1, math.min(#fresh, 10))) end
        end
    end
    return total
end

-- OPTIONAL (CFG.KEN_RUNTIME_OFF): ASSUMED signature CommE:FireServer("Ken", false). Fired twice per character.
function Vx.kenTick()
    if not CFG.KEN_RUNTIME_OFF or not hasHRP() then return end
    local ch = LP.Character
    if ch ~= Vx.kenChar then Vx.kenChar, Vx.kenDue = ch, { os.clock() + 10, os.clock() + 45 } end
    local due = Vx.kenDue
    if due and due[1] and os.clock() >= due[1] then
        table.remove(due, 1)
        local ce = Remotes and Remotes:FindFirstChild("CommE")
        if ce and ce:IsA("RemoteEvent") then
            pcall(function() ce:FireServer("Ken", false) end)
            Log.add("I", "ken: sent CommE Ken=false (assumed signature)")
        end
    end
end

function Vx.buildConfig(lv)
    local cfg = GetVxezeLevelConfig()
    if lv < CFG.LEVEL_VXEZE_MIN then return cfg, "leveling" end
    for k, v in pairs(BELI_OVERRIDES) do cfg[k] = v end
    if CFG.BELI_KEEP_LEGACY_UI then for k, v in pairs(BELI_LEGACY_UI) do cfg[k] = v end end
    return cfg, "beli"
end

Vx.PROTECT = { "Auto Load Script", "Select Method Farm" }
function Vx.snapshot(cfg)
    local s = {}
    for k, v in pairs(cfg) do if type(v) ~= "table" then s[k] = v end end
    Vx.snap = s
end
function Vx.reassert() return Vx.enforceAll() end
function Vx.drift()
    local cfg = type(env.Config) == "table" and env.Config or nil
    if not (cfg and Vx.snap) then return end
    local diffs = {}
    for k, v in pairs(Vx.snap) do
        if k ~= Farm.KEY and cfg[k] ~= v then diffs[#diffs + 1] = k .. ": " .. tostring(v) .. " -> " .. tostring(cfg[k]) end
    end
    table.sort(diffs)
    if #diffs > 0 then
        Log.add("W", "hub changed " .. #diffs .. " config key(s) after load: " .. table.concat(diffs, "; ", 1, math.min(#diffs, 12)))
        FS.write("BloxConfigDrift_" .. UID .. ".txt", table.concat(diffs, "\n"))
        local fixed = Vx.reassert()
        if fixed > 0 then Log.add("W", "re-asserted " .. fixed .. " protected key(s)") end
    else
        Log.add("I", "config check: the hub left our config untouched")
    end
end
function Vx.driftTickVxeze()
    if not (Vx.loaded and Vx.loadedAt and Vx.snap) then return 5 end
    local age = os.time() - Vx.loadedAt
    Vx.enforceAll()          -- v22: runs every few seconds, not just at 45s / 300s
    Vx.kenTick()
    Vx.driftDone = Vx.driftDone or 0
    if Vx.driftDone == 0 and age >= CFG.IDLE.DRIFT_AFTER then
        Vx.driftDone = 1
        Vx.drift()
    elseif Vx.driftDone == 1 and age >= 300 then
        Vx.driftDone = 2
        Vx.drift()
    end
    return age < CFG.FORCE_GUARD_FAST_FOR and CFG.FORCE_GUARD_FAST or CFG.FORCE_GUARD_SLOW
end

Vx.mode, Vx.level, Vx.loaded, Vx.failed, Vx.running, Vx.attempts, Vx.reloads = nil, nil, false, false, false, 0, 0
function Vx.readLevel()
    local ok, v = pcall(function()
        local d = LP:FindFirstChild("Data")
        local l = d and d:FindFirstChild("Level")
        return l and tonumber(l.Value)
    end)
    return ok and v or nil
end
-- ---- v24: hub selection + Kaitun config (from v22.1) --------------------------------------------------------------
function Vx.pickHub(lv)
    local h = CFG.HUB
    if h == "kaitun" or h == "vxeze" then return h, "pinned by CFG.HUB" end
    if lv >= CFG.LEVEL_VXEZE_MIN then return "vxeze", string.format("level %d >= %d", lv, CFG.LEVEL_VXEZE_MIN) end
    return "kaitun", string.format("level %d < %d", lv, CFG.LEVEL_VXEZE_MIN)
end
function Vx.url() return Vx.hub == "kaitun" and CFG.KAITUN_URL or CFG.VXEZE_URL end

local function sameList1(t, v) return type(t) == "table" and #t == 1 and t[1] == v end

-- Weapon policy + Godhuman gate on ONE Kaitun "Blox Fruits" table. Used at build time and every few seconds on the live config.
-- Appends the path of every key it had to change to `out`.
function Vx.kaitunForce(bf, lv, out)
    local K = CFG.KAITUN
    local W = K.WEAPON
    if bf["Select Weapon"] ~= W and (bf["Select Weapon"] ~= nil or K.ADD_SELECT_WEAPON_KEY) then
        bf["Select Weapon"] = W out[#out + 1] = "Select Weapon"
    end
    local fm = bf["Farm Mastery"]
    if type(fm) == "table" and not sameList1(fm["Weapon Farm"], W) then
        fm["Weapon Farm"] = { W } out[#out + 1] = "Farm Mastery.Weapon Farm"
    end
    local gi = bf["Get Items"]
    if type(gi) == "table" then
        for _, k in ipairs(K.SWORD_KEYS) do
            if gi[k] ~= nil then
                if gi[k] ~= false then gi[k] = false out[#out + 1] = "Get Items." .. k end
            elseif K.ADD_MISSING_SWORD_KEYS then
                gi[k] = false out[#out + 1] = "Get Items." .. k .. " (added)"
            end
        end
        -- WHY a hard level gate: from GODHUMAN_BELOW up the account is a beli farmer, the Godhuman chain only burns time there.
        -- Superhuman is only a prerequisite of it, so it follows the same gate.
        if lv >= CFG.GODHUMAN_BELOW then
            for _, k in ipairs({ "Godhuman", "Superhuman" }) do
                if gi[k] == true then gi[k] = false out[#out + 1] = "Get Items." .. k .. " (level gate)" end
            end
        end
    end
    local gr = bf["Get Rare Items"]      -- Rengoku / Dragon Trident / Pole / Gravity Blade: weapons, never wanted here
    if type(gr) == "table" then
        for k, v in pairs(gr) do if v == true then gr[k] = false out[#out + 1] = "Get Rare Items." .. tostring(k) end end
    end
    return out
end

-- Kaitun: only Beli / Mastery / Godhuman. Every other quest, race, hop, shop and webhook switch is forced off.
function Vx.applyKaitun(cfg, lv)
    local bf = cfg["Blox Fruits"]
    bf["Select Team"] = CFG.PREFERRED_TEAM
    local function off(tbl) for k, v in pairs(tbl) do if v == true then tbl[k] = false elseif type(v) == "table" then off(v) end end end
    for _, k in ipairs({ "Get Rare Items", "Get Race", "Farm Fragments", "Select Hop", "Sniper Fruit Shop", "Secret Quest", "Webhook" }) do
        if type(bf[k]) == "table" then off(bf[k]) end
    end
    bf["Auto Awaken Fruit"], bf["Summon Rip Indra"] = false, false
    local gi = bf["Get Items"]
    if type(gi) == "table" then
        for k in pairs(gi) do gi[k] = false end
        local wantGod = (tonumber(lv) or 0) < CFG.GODHUMAN_BELOW
        gi["Godhuman"] = wantGod
        if gi["Superhuman"] ~= nil then gi["Superhuman"] = wantGod end
        Log.add("I", string.format("kaitun: Godhuman=%s (level %s, gate %d)", tostring(wantGod), tostring(lv), CFG.GODHUMAN_BELOW))
    end
    if type(bf["Farm Mastery"]) == "table" then bf["Farm Mastery"]["Enabled"] = CFG.KAITUN.MASTERY and true or false end
    local forced = Vx.kaitunForce(bf, tonumber(lv) or 0, {})
    local present = {}
    for _, k in ipairs(CFG.KAITUN.SWORD_KEYS) do if type(gi) == "table" and gi[k] ~= nil then present[#present + 1] = k end end
    Log.add("I", string.format("kaitun weapon policy: Select Weapon=%s, Weapon Farm={%s}, %d key(s) forced at build [%s], sword keys present in Get Items: [%s]",
        tostring(bf["Select Weapon"]), tostring(type(bf["Farm Mastery"]) == "table" and bf["Farm Mastery"]["Weapon Farm"] and bf["Farm Mastery"]["Weapon Farm"][1]),
        #forced, table.concat(forced, ", ", 1, math.min(#forced, 6)), table.concat(present, ", ")))
end

-- Live config: the hub (or another script) may flip a key back after load. Logged once per key per minute, evidence instead of guessing.
function Vx.kaitunEnforceLive()
    local cfg = type(env.Config) == "table" and env.Config or nil
    local bf = cfg and cfg["Blox Fruits"]
    if type(bf) ~= "table" then return 0 end
    local lv = Vx.readLevel() or Vx.level or 0
    local changed = Vx.kaitunForce(bf, lv, {})
    if #changed > 0 then
        local fresh, now = {}, os.time()
        for _, p in ipairs(changed) do
            local id = "kaitun:" .. p
            if (Vx.flipSeen[id] or 0) + 60 <= now then Vx.flipSeen[id] = now fresh[#fresh + 1] = p end
        end
        if #fresh > 0 then Log.add("W", "kaitun config guard re-forced: " .. table.concat(fresh, ", ", 1, math.min(#fresh, 10))) end
    end
    return #changed
end

function Vx.driftTick()
    if not (Vx.loaded and Vx.loadedAt) then return 5 end
    if Vx.hub == "kaitun" then
        Vx.kaitunEnforceLive()
        return (os.time() - Vx.loadedAt) < CFG.FORCE_GUARD_FAST_FOR and CFG.FORCE_GUARD_FAST or CFG.FORCE_GUARD_SLOW
    end
    return Vx.driftTickVxeze()
end

-- A level-up past the threshold cannot swap the hub inside a running client (no hub can be unloaded). Say so once, then the
-- next session boots into the other hub by itself.
function Vx.levelWatch()
    if Vx.hub ~= "kaitun" or CFG.HUB ~= "auto" or Vx.switchNoted then return 30 end
    local lv = Vx.readLevel()
    if lv and lv >= CFG.LEVEL_VXEZE_MIN then
        Vx.switchNoted = true
        Log.add("W", string.format("level %d >= %d: Vxeze takes over at the next session start (a running hub cannot be unloaded)", lv, CFG.LEVEL_VXEZE_MIN))
        WH.send("report", "Hub switch pending", string.format("Account %s reached level %d. Kaitun keeps running until this session ends, the next session boots Vxeze.", LP.Name, lv), 3447003, 2)
    end
    return 30
end

function Vx.load()
    -- WHY not Farm.toggle() for Kaitun: it has no "Start Farm" row, so the check would always fail and load a second copy of the hub.
    if env.BloxVxJob == game.JobId and env.BloxVxHub == Vx.hub and (Vx.hub == "kaitun" or Farm.toggle()) then
        Vx.loaded, Vx.loadedAt = true, os.time()
        Log.add("W", "hub " .. tostring(Vx.hub) .. " already running in this server, not loading again")
        return true
    end
    local delay = 5
    for attempt = 1, CFG.VX_MAX_ATTEMPTS do
        if not S.alive then return false end
        Vx.attempts, Vx.running = attempt, true
        local okc, fn = pcall(function()
            local f, cerr = loadstring(game:HttpGet(Vx.url()))
            if not f then error(cerr or "compile failed") end
            return f
        end)
        local ok, err = okc, fn
        if okc then ok, err = pcall(fn) end
        if ok then
            Vx.loaded, Vx.loadedAt = true, os.time()
            env.BloxVxJob, env.BloxVxHub = game.JobId, Vx.hub
            Log.add("I", tostring(Vx.hub) .. " hub loaded (attempt " .. attempt .. ")")
            return true
        end
        Log.add("W", tostring(Vx.hub) .. " hub load failed (attempt " .. attempt .. "): " .. tostring(err))
        if okc and Vx.hub == "kaitun" then
            -- the hub's main chunk started and then raised: it may already run loops, loading it again would duplicate them
            Vx.loaded, Vx.loadedAt = true, os.time()
            env.BloxVxJob, env.BloxVxHub = game.JobId, Vx.hub
            Log.add("W", "kaitun raised while starting, treating it as running (a retry could stack a second copy)")
            return true
        end
        if Vx.hub == "vxeze" and Farm.toggle() then
            Vx.loaded, Vx.loadedAt = true, os.time()
            Log.add("W", "hub UI is already present, not retrying")
            return true
        end
        task.wait(delay)
        delay = math.min(120, delay * 2)
    end
    Vx.failed = true
    Log.add("E", tostring(Vx.hub) .. " hub could not be loaded, giving up")
    WH.send("report", "Hub load failed", "Account " .. LP.Name .. " could not load the " .. tostring(Vx.hub) .. " hub", 16711680, 3)
    return false
end

function Vx.boot()
    Task.spawn("hub-boot", function()
        local lv = Vx.readLevel()
        while not lv and S.alive do task.wait(3) lv = Vx.readLevel() end
        if not S.alive then return end
        local hub, why = Vx.pickHub(lv)
        -- a hub that is already running in THIS server cannot be unloaded: stay with it instead of starting a second one
        if env.BloxVxJob == game.JobId and (env.BloxVxHub == "kaitun" or env.BloxVxHub == "vxeze") and env.BloxVxHub ~= hub then
            Log.add("W", "hub " .. hub .. " wanted (" .. why .. ") but " .. env.BloxVxHub .. " is already running in this server, keeping it")
            hub, why = env.BloxVxHub, "already running"
        end
        Vx.hub, Vx.hubWhy = hub, why
        local cfg, mode, removed
        if hub == "kaitun" then
            cfg, mode, removed = GetKaitunConfig(), "kaitun", 0
            Vx.applyKaitun(cfg, lv)
            env.Premium, env.FpsBoost, env.Key = false, true, env.Key or ""
            Vx.snap = nil
        else
            cfg, mode = Vx.buildConfig(lv)
            removed = Vx.sanitize(cfg)
            Vx.applyOverrides(cfg)
            Vx.buildForced(lv)
            local forcedNow = Vx.enforceOne(cfg)
            Vx.snapshot(cfg)
            local nkeys = 0
            for _ in pairs(cfg) do nkeys = nkeys + 1 end
            Log.add("I", string.format("config: method=%s autoLoad=%s startFarm=%s keys=%d", tostring(cfg["Select Method Farm"]), tostring(cfg["Auto Load Script"]), tostring(cfg["Start Farm"]), nkeys))
            Log.add("I", string.format("config guard: %d key(s) forced at build [%s] | MainItem.GodHuman=%s | Auto Turn On Observation=%s",
                #forcedNow, table.concat(forcedNow, ", ", 1, math.min(#forcedNow, 8)), tostring(pathGet(cfg, { "MainItem", "GodHuman" })), tostring(cfg["Auto Turn On Observation"])))
        end
        Vx.mode, Vx.level = mode, lv
        env.Config = cfg
        FS.writeJSON("BloxConfigDump_" .. UID .. ".json", cfg)
        env.BloxSea = { sea = ({ [2753915549] = 1, [4442272183] = 2, [7449423635] = 3 })[game.PlaceId], level = lv, mode = mode, hub = hub }
        Log.add("I", string.format("hub %s (%s), level %d -> mode %s (%d conflicting features disabled)", hub, why, lv, mode, removed))
        Noti.installHook()
        Vx.load()
    end)
end

----------------------------------------------------------------
-- 9. NOTIFICATION FILTER
----------------------------------------------------------------
function Noti.match(text)
    local t = string.lower(tostring(text or ""))
    for _, p in ipairs(CFG.NOTI_PATTERNS) do if string.find(t, p, 1, true) then return true end end
    return false
end
function Noti.installHook()
    env.BloxNotiRule = function(name, data)
        if name == "SendNotification" then
            local txt = type(data) == "table" and (data.Text or data.Title) or data
            return CFG.NOTI_BLOCK_ALL or Noti.match(txt)
        elseif name == "ChatMakeSystemMessage" then
            return Noti.match(type(data) == "table" and data.Text or data)
        end
        return false
    end
    if env.BloxNotiHooked then return end
    if type(hookfunction) ~= "function" or type(newcclosure) ~= "function" then Log.add("W", "hookfunction unavailable, GUI sweep only") return end
    local SG = game:GetService("StarterGui")
    local ok, err = pcall(function()
        local old
        old = hookfunction(SG.SetCore, newcclosure(function(self, name, data)
            local rule = env.BloxNotiRule
            if rule and rule(name, data) then return end
            return old(self, name, data)
        end))
    end)
    if ok then env.BloxNotiHooked = true else Log.add("W", "notification hook failed: " .. tostring(err)) end
end

Noti.SKIP_GUI = { RobloxGui = true, PlayerList = true, Chat = true, TopBarApp = true, BubbleChat = true, PurchasePrompt = true, ThemeProvider = true, ControlGui = true, TouchGui = true, Main = true, BloxFactoryUI = true, RobloxNetworkPauseNotification = true, DevConsoleMaster = true, ScreenshotHud = true }

function Noti.check(d)
    if not d:IsA("GuiObject") or d:IsA("GuiButton") or not d.Visible then return end
    local n = string.lower(d.Name)
    for _, k in ipairs(CFG.NOTI_NAME_KEYS) do
        if string.find(n, k, 1, true) then d.Visible = false return end
    end
    if d:IsA("TextLabel") then
        local t = string.lower(d.Text)
        if string.sub(t, 1, 5) == "kill " and (string.find(t, "[", 1, true) or string.sub(t, -3) == "...") then d.Visible = false end
    end
end
function Noti.attach(g)
    if not g:IsA("ScreenGui") or Noti.SKIP_GUI[g.Name] then return end
    local ok, c = pcall(function()
        return g.DescendantAdded:Connect(function(d)
            Noti.check(d)
            if d:IsA("TextLabel") then task.delay(0.2, function() pcall(Noti.check, d) end) end
        end)
    end)
    if ok then S.conns[#S.conns + 1] = c end
    Task.spawn("noti-initial", function()
        local i = 0
        for _, d in ipairs(g:GetDescendants()) do
            i = i + 1
            if i % 300 == 0 then task.wait() end
            pcall(Noti.check, d)
        end
    end)
end
function Noti.boot()
    local roots = { PG }
    local okh, hui = pcall(function() return gethui and gethui() end)
    if okh and hui then roots[#roots + 1] = hui end
    pcall(function() roots[#roots + 1] = game:GetService("CoreGui") end)
    for _, root in ipairs(roots) do
        for _, g in ipairs(root:GetChildren()) do Noti.attach(g) end
        local ok, c = pcall(function() return root.ChildAdded:Connect(Noti.attach) end)
        if ok then S.conns[#S.conns + 1] = c end
    end
end

----------------------------------------------------------------
-- 9b. DAMAGE NUMBERS (v22): structural detection instead of name matching
--   WHY: v21 matched names ("damage"/"hit"/...). The game's names are unknown, so numbers kept coming. Here a BillboardGui /
--   SurfaceGui is removed when (a) its name says damage/dmg OR (b) it contains a TextLabel whose text is purely numeric
--   (health bars have "/", name tags have letters). BloxDamageProbe_<UID>.txt records what was actually created so the
--   rules can be corrected from real data.
----------------------------------------------------------------
local Dmg = { killed = 0, trash = {}, probeLines = {}, probeUntil = 0, probed = false, dead = setmetatable({}, { __mode = "k" }) }

local function isNumericText(t)
    if type(t) ~= "string" or t == "" or #t > 14 then return false end
    return string.find(t, "^[%+%-]?[%d,%.]+[kKmMbB]?!?$") ~= nil
end
local function dmgNameHit(name)
    local n = string.lower(tostring(name))
    for _, p in ipairs(CFG.DMG.NAMES) do if string.find(n, p, 1, true) then return true end end
    return false
end
function Dmg.note(d, why)
    if os.clock() > Dmg.probeUntil or #Dmg.probeLines >= CFG.DMG.PROBE_MAX then return end
    local chain, cur = {}, d
    for _ = 1, 6 do
        if not cur or cur == game then break end
        chain[#chain + 1] = cur.ClassName .. ":" .. cur.Name
        cur = cur.Parent
    end
    local txt = (d:IsA("TextLabel") or d:IsA("TextBox")) and d.Text or ""
    Dmg.probeLines[#Dmg.probeLines + 1] = string.format("%s | text=%q | chain(up)= %s", why, txt, table.concat(chain, " < "))
end
function Dmg.kill(gui)
    if Dmg.dead[gui] then return end
    Dmg.dead[gui] = true
    Dmg.killed = Dmg.killed + 1
    pcall(function() gui.Enabled = false end)     -- stops rendering at once; Destroy is batched in Dmg.tick
    Dmg.trash[#Dmg.trash + 1] = gui
end
function Dmg.inspect(gui)
    if not S.alive or not gui or not gui.Parent or Dmg.dead[gui] then return end
    local why
    if dmgNameHit(gui.Name) then why = "name" end
    if not why then
        local n = 0
        for _, x in ipairs(gui:GetDescendants()) do
            n = n + 1
            if n > 30 then break end
            if x:IsA("TextLabel") and isNumericText(x.Text) then why = "numeric text" break end
        end
    end
    if not why then return end
    Dmg.note(gui, why)
    Dmg.kill(gui)
end
function Dmg.onAdded(d)
    local cn = d.ClassName
    if cn == "BillboardGui" or cn == "SurfaceGui" then
        task.delay(0.12, Dmg.inspect, d)         -- children / text are often filled in right after parenting
        task.delay(0.6, Dmg.inspect, d)
    elseif cn == "TextLabel" and Dmg.probeUntil > 0 and isNumericText(d.Text) then
        Dmg.note(d, "numeric TextLabel")         -- 2D candidates are only logged, never removed
    end
end
-- Disable BillboardGui templates in ReplicatedStorage whose name says damage, so clones start disabled (best effort).
function Dmg.disableTemplates()
    local n, found = 0, {}
    for _, d in ipairs(RS:GetDescendants()) do
        n = n + 1
        if n % 500 == 0 then task.wait() end
        if d:IsA("BillboardGui") and dmgNameHit(d.Name) then
            pcall(function() d.Enabled = false end)
            if #found < 5 then found[#found + 1] = d:GetFullName() end
        end
    end
    Log.add("I", "damage: " .. #found .. " template(s) disabled" .. (#found > 0 and (" (" .. table.concat(found, ", ") .. ")") or ""))
end
function Dmg.startProbe(secs)
    Dmg.probeLines, Dmg.probeUntil = {}, os.clock() + (secs or CFG.DMG.PROBE_SECONDS)
    Log.add("I", "damage probe running for " .. (secs or CFG.DMG.PROBE_SECONDS) .. "s")
end
function Dmg.writeProbe()
    local out = { "killed so far: " .. Dmg.killed, "-- created during the probe window (newest last):" }
    for _, l in ipairs(Dmg.probeLines) do out[#out + 1] = l end
    if #Dmg.probeLines == 0 then out[#out + 1] = "(nothing numeric was created: damage numbers are either not GUI based or already removed before the probe)" end
    FS.write("BloxDamageProbe_" .. UID .. ".txt", table.concat(out, "\n"))
    Log.add("I", "damage probe written (" .. #Dmg.probeLines .. " line(s), " .. Dmg.killed .. " removed in total)")
end
function Dmg.tick()
    local t = Dmg.trash
    if #t > 0 then
        Dmg.trash = {}
        for _, g in ipairs(t) do pcall(function() g:Destroy() end) end
    end
    if CFG.DMG.PROBE_SECONDS > 0 and not Dmg.probed and Sess.active and hasHRP() then
        Dmg.armAt = Dmg.armAt or (os.clock() + 60)
        if os.clock() >= Dmg.armAt then Dmg.probed = true Dmg.startProbe() end
    end
    if Dmg.probeUntil > 0 and os.clock() > Dmg.probeUntil then
        Dmg.probeUntil = 0
        Dmg.writeProbe()
    end
    return 1
end

----------------------------------------------------------------
-- 10. INPUT HELPERS
----------------------------------------------------------------
function Input.click(b)
    if not b then return false end
    local fired = false
    if type(getconnections) == "function" then
        for _, sn in ipairs({ "MouseButton1Click", "Activated", "MouseButton1Down", "MouseButton1Up", "TouchTap" }) do
            local ok, sig = pcall(function() return b[sn] end)
            if ok and sig then
                local ok2, cs = pcall(getconnections, sig)
                if ok2 then for _, c in ipairs(cs) do if pcall(function() c:Fire() end) then fired = true end end end
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
function Input.vim(b, mode)
    local sg = b:FindFirstAncestorOfClass("ScreenGui")
    local inset = (sg and sg.IgnoreGuiInset) and Vector2.zero or GuiService:GetGuiInset()
    local p = b.AbsolutePosition + b.AbsoluteSize / 2 + inset
    pcall(function()
        if mode == "mouse" then
            VIM:SendMouseButtonEvent(p.X, p.Y, 0, true, game, 0) task.wait(0.08) VIM:SendMouseButtonEvent(p.X, p.Y, 0, false, game, 0)
        else
            VIM:SendTouchEvent(1, 0, p.X, p.Y) task.wait(0.08) VIM:SendTouchEvent(1, 2, p.X, p.Y)
        end
    end)
end
function Input.shown(g)
    local cur = g
    while cur and cur ~= PG do
        if cur:IsA("GuiObject") and not cur.Visible then return false end
        if cur:IsA("ScreenGui") and not cur.Enabled then return false end
        cur = cur.Parent
    end
    return true
end

----------------------------------------------------------------
-- 11. TEAM SELECTION
----------------------------------------------------------------
Team.NAME = (CFG.PREFERRED_TEAM == "Marines") and "Marines" or "Pirates"
Team.STEM = (Team.NAME == "Pirates") and "pirate" or "marin"
Team.cached, Team.lastScan, Team.lastTry, Team.fails, Team.doneStreak, Team.bootClock, Team.dumped = nil, 0, 0, 0, 0, os.clock(), false

function Team.ui()
    local main = PG:FindFirstChild("Main")
    local ct = main and main:FindFirstChild("ChooseTeam")
    if not ct and Team.cached and Team.cached.Parent then ct = Team.cached end
    if not ct and os.clock() - Team.lastScan >= 5 then
        Team.lastScan = os.clock()
        ct = PG:FindFirstChild("ChooseTeam", true)
        if not ct then
            for _, d in ipairs(PG:GetDescendants()) do
                if d:IsA("TextLabel") and string.find(string.lower(d.Text), "pick a side", 1, true) then
                    ct = d
                    while ct.Parent and ct.Parent ~= PG and not ct:FindFirstChild(Team.NAME, true) do ct = ct.Parent end
                    break
                end
            end
        end
        Team.cached = ct
    end
    return ct
end
function Team.done()
    local t = LP.Team
    if t and (t.Name == "Pirates" or t.Name == "Marines") then return true end
    local ct = Team.ui()
    if ct then return not Input.shown(ct) end
    return hasHRP()
end
function Team.findButton(ct)
    local c = ct:FindFirstChild("Container") or ct
    local t = c:FindFirstChild(Team.NAME) or ct:FindFirstChild(Team.NAME, true)
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
                if p and p ~= ct and string.find(string.lower(p.Name), Team.STEM, 1, true) then hit = true break end
                p = p and p.Parent
            end
            if not hit and d:IsA("TextButton") and string.find(string.lower(d.Text), Team.STEM, 1, true) then hit = true end
            if hit then return d end
        end
    end
end
function Team.dump()
    if Team.dumped or not FS.ok() then return end
    Team.dumped = true
    local out = {}
    for _, d in ipairs(PG:GetDescendants()) do
        local txt = (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Text or ""
        local s = string.lower(d.Name .. " " .. txt)
        if s:find("team", 1, true) or s:find("pirate", 1, true) or s:find("marin", 1, true) or s:find("side", 1, true) then
            out[#out + 1] = d:GetFullName() .. " [" .. d.ClassName .. "] " .. txt
        end
    end
    FS.write("TeamDebug_" .. UID .. ".txt", table.concat(out, "\n"))
end
function Team.try()
    UI.status("Choosing team: " .. Team.NAME)
    local cf = commF()
    if cf then pcall(function() cf:InvokeServer("SetTeam", Team.NAME) end) end
    task.wait(1.5)
    if Team.done() then return true, "remote" end
    local ct = Team.ui()
    local b = ct and Team.findButton(ct)
    if not b then Team.dump() return false end
    Input.click(b) task.wait(1)
    if Team.done() then return true, "getconnections" end
    Input.vim(b, "mouse") task.wait(1.2)
    if Team.done() then return true, "vim-mouse" end
    Input.vim(b, "touch") task.wait(1.2)
    if Team.done() then return true, "vim-touch" end
    return false
end
function Team.tick()
    if Team.done() and hasHRP() then
        Team.doneStreak = Team.doneStreak + 1
        if Team.doneStreak >= 3 then return false end
        return 1
    end
    Team.doneStreak = 0
    local ct = Team.ui()
    local need = (ct and Input.shown(ct)) or (LP.Team == nil and not hasHRP() and os.clock() - Team.bootClock > 20)
    local cd = math.min(30, 5 * 2 ^ Team.fails)
    if need and os.clock() - Team.lastTry >= cd then
        Team.lastTry = os.clock()
        local ok, how = Team.try()
        if ok then Team.fails = 0 UI.status("Team chosen (" .. how .. ")") else Team.fails = Team.fails + 1 UI.status("Team selection failed #" .. Team.fails) end
    end
    return 1
end

----------------------------------------------------------------
-- 12. FARM CONTROL
----------------------------------------------------------------
Farm.TEXTS    = { "mulai bertani", "start farming", "start farm" }
Farm.PATTERNS = { "farm", "bertani" }
Farm.ATTRS    = { "Value", "Toggled", "State", "Enabled", "On", "Active" }
Farm.KEY      = "Start Farm"

function Farm.reset()
    Farm.onTries, Farm.onNext, Farm.warnAt = 0, 0, 0
    Farm.stopTries, Farm.stopNext, Farm.stopped = 0, 0, false
    Farm.scanBackoff, Farm.sw, Farm.row, Farm.seenUI = 5, nil, nil, false
    Farm.watch, Farm.methodIdx = nil, 0
end
Farm.reset()

local function textMatch(s) s = string.lower(s) for _, t in ipairs(Farm.TEXTS) do if s:find(t, 1, true) then return true end end return false end
local function nameIsFarm(k) k = string.lower(k) for _, p in ipairs(Farm.PATTERNS) do if k:find(p, 1, true) then return true end end return false end
function Farm.envFlags()
    local list = {}
    for _, tbl in ipairs({ env, _G }) do
        local n = 0
        for k, v in next, tbl do
            n = n + 1
            if n > 1500 then break end
            if type(k) == "string" and v == true and nameIsFarm(k) then list[#list + 1] = { tbl = tbl, key = k } end
        end
    end
    return list
end
function Farm.cfgOff(cfg)
    local n = 0
    pcall(function()
        if cfg[Farm.KEY] ~= false then cfg[Farm.KEY] = false n = n + 1 end
        local seen = 0
        for k, v in next, cfg do
            seen = seen + 1
            if seen > 600 then break end
            if type(k) == "string" and v == true and k ~= Farm.KEY and nameIsFarm(k) then cfg[k] = false n = n + 1 end
        end
    end)
    return n
end
function Farm.roots()
    local roots = {}
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then roots[#roots + 1] = hui end
    pcall(function() roots[#roots + 1] = game:GetService("CoreGui") end)
    roots[#roots + 1] = PG
    return roots
end
function Farm.scanGui(g)
    local n = 0
    for _, d in ipairs(g:GetDescendants()) do
        n = n + 1
        if n % 400 == 0 then task.wait() end
        local cn = d.ClassName
        if (cn == "TextLabel" or cn == "TextButton") and textMatch(d.Text) then
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
function Farm.toggle()
    if Farm.sw and Farm.sw.Parent then return Farm.sw, Farm.row end
    Farm.sw, Farm.row = nil, nil
    local named, other = {}, {}
    for _, root in ipairs(Farm.roots()) do
        for _, g in ipairs(root:GetChildren()) do
            if g:IsA("ScreenGui") and not Noti.SKIP_GUI[g.Name] then
                if string.find(string.lower(g.Name), "vxeze", 1, true) then named[#named + 1] = g else other[#other + 1] = g end
            end
        end
    end
    for _, list in ipairs({ named, other }) do
        for _, g in ipairs(list) do
            local sw, row = Farm.scanGui(g)
            if sw then Farm.sw, Farm.row, Farm.seenUI = sw, row, true return sw, row end
        end
    end
end
function Farm.isOn(sw, row)
    for _, inst in ipairs({ sw, row }) do
        local ok, attrs = pcall(function() return inst:GetAttributes() end)
        if ok then for _, k in ipairs(Farm.ATTRS) do if type(attrs[k]) == "boolean" then return attrs[k] end end end
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

function Farm.start()
    if not Team.done() or not hasHRP() then return 3 end
    local sw, row = Farm.toggle()
    if not sw then
        Farm.scanBackoff = math.min(60, Farm.scanBackoff * 2)
        return Farm.scanBackoff
    end
    Farm.scanBackoff = 5
    local cfgT = type(env.Config) == "table" and env.Config or nil
    if cfgT and cfgT[Farm.KEY] ~= true then cfgT[Farm.KEY] = true Log.add("W", "Start Farm was false in the config while the UI looked on, re-enabled it") end
    if os.time() < Farm.onNext then return 3 end
    if Farm.isOn(sw, row) then Farm.onTries = 0 Farm.onNext = os.time() + 15 return 5 end
    if Farm.onTries >= CFG.FARM_ON_MAX then
        Farm.onTries, Farm.onNext = 0, os.time() + 120
        if os.time() - Farm.warnAt >= 120 then Farm.warnAt = os.time() UI.status("Farm auto-start failed, check the Vxeze toggle") end
        return 10
    end
    Farm.onTries = Farm.onTries + 1
    Farm.onNext = os.time() + 8
    UI.status("Auto-start farm (" .. Farm.onTries .. "/" .. CFG.FARM_ON_MAX .. ")")
    if type(env.Config) == "table" then env.Config[Farm.KEY] = true end
    Input.click(sw) task.wait(1.2)
    if not Farm.isOn(sw, row) then Input.vim(sw, "mouse") task.wait(1) end
    if Farm.isOn(sw, row) then UI.status("Farm on (auto-start)") end
    return 5
end

function Farm.stopOnce()
    local cfg = type(env.Config) == "table" and env.Config or nil
    local wasOn = cfg ~= nil and cfg[Farm.KEY] == true
    local changed = cfg and Farm.cfgOff(cfg) or 0
    local flags = Farm.envFlags()
    for _, f in ipairs(flags) do f.tbl[f.key] = false end
    local sw, row = Farm.toggle()
    local clicked = false
    if sw and Farm.isOn(sw, row) then
        Input.click(sw) task.wait(0.8) clicked = true
        if Farm.isOn(sw, row) then Input.vim(sw, "mouse") task.wait(0.8) end
        if cfg then Farm.cfgOff(cfg) end
    end
    if cfg then task.wait(0.3) if cfg[Farm.KEY] ~= false then cfg[Farm.KEY] = false end end
    if sw and Farm.isOn(sw, row) then
        if cfg or #flags > 0 then return "off", "config (UI still looks ON)" end
        return "stuck"
    end
    if clicked then return "off", cfg and "config+ui" or "ui" end
    if wasOn or changed > 0 or #flags > 0 then return "off", cfg and "config" or "env-flag" end
    if cfg then return "alreadyoff", "config" end
    if sw then return "alreadyoff", "ui" end
    return "notfound"
end
function Farm.stop()
    if os.time() < Farm.stopNext then return 3 end
    UI.status("Stopping farm...")
    local ok, r, how = pcall(Farm.stopOnce)
    if not ok then r, how = "error", tostring(r) end
    Farm.stopTries = Farm.stopTries + 1
    if r == "off" or r == "alreadyoff" or Farm.stopTries >= 4 then
        Farm.stopped = true
        UI.status("Farm " .. (r == "off" and "stopped" or r == "alreadyoff" and "already off" or ("stop gave up: " .. tostring(r))) .. " (" .. tostring(how) .. ")")
        return 10
    end
    Farm.stopNext = os.time() + 10
    UI.status("Farm stop: " .. tostring(r) .. ", retrying in 10s (" .. Farm.stopTries .. "/4)")
    return 3
end
function Farm.tick()
    if Vx.hub == "kaitun" then return 30 end   -- Kaitun runs its own farm loop; there is no Start Farm toggle to reconcile
    if not Sess.active or Sess.signaledAt or not Vx.mode then return 5 end
    local left = Sess.endAt - os.time()
    if left <= CFG.FARM_STOP_BEFORE then
        if Farm.stopped then return 10 end
        return Farm.stop()
    end
    if left <= CFG.FARM_STOP_BEFORE + 30 then return 5 end
    return Farm.start()
end

function Farm.note(msg)
    Log.add("W", "farm-verify: " .. msg)
    local ev = Farm.events or {}
    ev[#ev + 1] = os.date("%H:%M:%S") .. " " .. msg
    if #ev > 20 then table.remove(ev, 1) end
    Farm.events = ev
    FS.write("BloxFarmEvents_" .. UID .. ".txt", table.concat(ev, "\n"))
end
function Farm.probe()
    local ch = LP.Character
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local d = LP:FindFirstChild("Data")
    local function val(n)
        local v = d and d:FindFirstChild(n)
        return (v and v:IsA("ValueBase")) and tonumber(v.Value) or nil
    end
    local p = hrp.Position
    return { x = p.X, y = p.Y, z = p.Z, beli = val("Beli"), exp = val("Exp"), level = val("Level") }
end
function Farm.progressed(a, b, studs)
    local dx, dy, dz = a.x - b.x, a.y - b.y, a.z - b.z
    if math.sqrt(dx * dx + dy * dy + dz * dz) >= studs then return true end
    for _, k in ipairs({ "beli", "exp", "level" }) do
        if a[k] ~= nil and b[k] ~= nil and a[k] ~= b[k] then return true end
    end
    return false
end
function Farm.stageFor(idle, I)
    if idle < I.AFTER then return 0 end
    return math.min(3, 1 + math.floor((idle - I.AFTER) / I.STAGE_WAIT))
end
function Farm.escalate(stage, idle)
    local I = CFG.IDLE
    local cfg = type(env.Config) == "table" and env.Config or nil
    if Vx.hub == "kaitun" then
        -- Vxeze keys (Start Farm, Select Method Farm) mean nothing in the Kaitun config, so none are written. Kaitun walks long
        -- distances for quests, which is why the default is "alert", not "kill the session".
        Farm.note(string.format("kaitun: no progress for %ds (stage %d, level %s)", idle, stage, tostring(Vx.level)))
        if stage == 1 then
            local n = Vx.kaitunEnforceLive()
            if n > 0 then Farm.note("kaitun config guard re-forced " .. n .. " key(s)") end
        elseif stage >= 3 then
            local K = CFG.KAITUN
            if K.IDLE_GIVEUP then
                Dead.mark(string.format("kaitun idle %ds at level %s", idle, tostring(Vx.level)))
            elseif os.time() - (Farm.lastKaitunAlert or 0) >= K.IDLE_ALERT_GAP then
                Farm.lastKaitunAlert = os.time()
                WH.send("report", "Kaitun idle", string.format("Account %s: no progress for %ds at level %s", LP.Name, idle, tostring(Vx.level)), 15158332, 3)
            end
        end
        return
    end
    Farm.note(string.format("no progress for %ds, stage %d (mode %s, method %s)", idle, stage, tostring(Vx.mode), tostring(cfg and cfg["Select Method Farm"])))
    if stage == 1 then
        local fixed = Vx.reassert()
        if cfg then cfg[Farm.KEY] = false task.wait(1.5) cfg[Farm.KEY] = true end
        Farm.note("stage 1 done: Start Farm toggled off/on in the config" .. (fixed > 0 and (", re-asserted " .. fixed .. " key(s)") or ""))
    elseif stage == 2 then
        Farm.methodIdx = Farm.methodIdx + 1
        local m = (I.FALLBACK_METHODS or {})[Farm.methodIdx]
        if cfg and m then
            cfg["Select Method Farm"] = m
            if Vx.snap then Vx.snap["Select Method Farm"] = m end
            cfg[Farm.KEY] = false task.wait(1.5) cfg[Farm.KEY] = true
            Farm.note("stage 2 done: Select Method Farm -> " .. tostring(m))
        else
            Farm.note("stage 2: no fallback method configured")
        end
    else
        local why = string.format("farm idle %ds in %s mode at level %s despite recovery attempts", idle, tostring(Vx.mode), tostring(Vx.level))
        Farm.note("stage 3: " .. why)
        if I.GIVEUP_DEAD then Dead.mark(why) else WH.send("report", "Farm idle", "Account " .. LP.Name .. ": " .. why, 15158332, 3) end
    end
end
function Farm.verify()
    local I = CFG.IDLE
    local ready = I.ENABLED and Sess.active and not Sess.signaledAt and Vx.mode and Vx.loaded and Vx.loadedAt and Team.done() and hasHRP() and not Farm.stopped and not Resp.pending and (Sess.endAt - os.time()) > CFG.FARM_STOP_BEFORE + 30
    if not ready then Farm.watch = nil return I.CHECK end
    local cur = Farm.probe()
    if not cur then return I.CHECK end
    local now, w = os.time(), Farm.watch
    if not w or now < Vx.loadedAt + I.GRACE then Farm.watch = { prev = cur, last = now, stage = 0 } return I.CHECK end
    if Farm.progressed(w.prev, cur, I.MOVE_STUDS) then
        if w.stage > 0 then Farm.note("progress resumed after stage " .. w.stage) end
        Farm.watch = { prev = cur, last = now, stage = 0 }
        return I.CHECK
    end
    local idle = now - w.last
    local want = Farm.stageFor(idle, I)
    if want > w.stage then w.stage = want Farm.escalate(want, idle) end
    return I.CHECK
end

function Farm.hubWatch()
    if Vx.hub ~= "vxeze" then return 15 end   -- the UI-missing reload is built around the Vxeze window
    if not Vx.loaded or Farm.seenUI or Vx.failed then Vx.uiDeadline = nil return 15 end
    if not (Team.done() and hasHRP()) then Vx.uiDeadline = nil return 15 end
    Vx.uiDeadline = Vx.uiDeadline or (os.time() + CFG.VX_UI_TIMEOUT * (2 ^ Vx.reloads))
    if os.time() >= Vx.uiDeadline then
        Vx.uiDeadline = nil
        if Farm.toggle() then return 15 end
        if Vx.reloads >= CFG.VX_MAX_RELOADS then
            Vx.failed = true
            Log.add("E", "Vxeze UI never appeared after " .. Vx.reloads .. " reload(s), giving up")
            WH.send("report", "Vxeze UI missing", "Account " .. LP.Name .. ": hub loaded but no UI after " .. Vx.reloads .. " reloads", 16711680, 3)
        else
            Vx.reloads = Vx.reloads + 1
            Log.add("W", "Vxeze UI not seen, reload " .. Vx.reloads .. "/" .. CFG.VX_MAX_RELOADS)
            Task.spawn("vxeze-reload", Vx.load)
        end
    end
    return 15
end

----------------------------------------------------------------
-- 12c. RESPAWN RECOVERY (v23.1)
--   Problem: after a death the character stands still. Whether the hub UI died (ResetOnSpawn) or its loop kept a
--   reference to the dead character, the fix is the same: get a loop bound to the NEW character.
--   Why not "reload on every CharacterAdded": the hub's threads cannot be killed, so a reload on top of a LIVE loop gives
--   two loops (the old idle bug) and a death streak would stack windows. So: judge by evidence, climb a ladder, rate limit.
--   Ladder per respawn: 1) cycle Start Farm (UI present) or reload at once (UI gone)  2) guarded reload  3) give up and
--   hand over to the idle verifier (which can mark the session dead so the scheduler rotates away).
----------------------------------------------------------------
function Resp.reset()
    Resp.pending, Resp.stage, Resp.watch, Resp.base = false, 0, nil, nil
    Resp.spawnAt, Resp.hadFarm, Resp.storm = 0, false, false
    Resp.spawns = {}
    Vx.sessReloads, Vx.reloading = 0, false
end
Resp.reset()

-- Removes the old hub window so a reload cannot stack a second one on top of it.
function Vx.dropHubGui()
    local function drop(g) if g and g:IsA("ScreenGui") then pcall(function() g:Destroy() end) end end
    local sw = Farm.sw
    if sw and sw.Parent then drop(sw:FindFirstAncestorOfClass("ScreenGui")) end
    for _, root in ipairs(Farm.roots()) do
        for _, g in ipairs(root:GetChildren()) do
            if g:IsA("ScreenGui") and string.find(string.lower(g.Name), "vxeze", 1, true) then drop(g) end
        end
    end
    Farm.sw, Farm.row, Farm.seenUI = nil, nil, false
end

-- Deliberate, rate-limited hub reload. Returns ok, reasonIfNot.
function Vx.reloadNow(reason)
    local R = CFG.RESPAWN
    if Vx.hub == "kaitun" and not R.KAITUN_RELOAD then return false, "kaitun reload disabled (CFG.RESPAWN.KAITUN_RELOAD)" end
    if Vx.reloading then return false, "reload in progress" end
    if os.time() - (Vx.lastReload or 0) < R.RELOAD_COOLDOWN then return false, "cooldown" end
    if (Vx.sessReloads or 0) >= R.MAX_RELOADS then return false, "max reloads this session" end
    Vx.lastReload, Vx.sessReloads, Vx.reloading = os.time(), (Vx.sessReloads or 0) + 1, true
    Log.add("W", string.format("hub reload (%s) %d/%d", reason, Vx.sessReloads, R.MAX_RELOADS))
    Vx.dropHubGui()
    env.BloxVxJob = nil   -- WHY: this reload is deliberate, the "already running" guard in Vx.load must not short-circuit it
    Task.spawn("vxeze-respawn-reload", function()
        pcall(Vx.load)
        Vx.reloading = false   -- WHY outside the pcall: a crash in Vx.load must not leave the flag stuck forever
    end)
    return true
end

-- CharacterAdded only records facts. All decisions are made by Resp.tick, so a death streak cannot trigger a burst of actions.
function Resp.onSpawn()
    local now = os.clock()
    Resp.spawnAt = now
    local list = Resp.spawns
    list[#list + 1] = now
    while #list > 0 and now - list[1] > 180 do table.remove(list, 1) end
    if not Resp.hadFarm then return end   -- first spawn of the run, or the farm never ran: team/idle watchers own that case
    if not Resp.pending then Resp.pending, Resp.stage, Resp.watch = true, 0, nil end
    -- already pending: spawnAt moved, so the settle timer restarts; the rung we are on is kept (no extra reloads)
    if #list >= CFG.RESPAWN.STORM_COUNT and not Resp.storm then
        Resp.storm = true
        Log.add("W", string.format("death storm: %d respawns in 3 minutes", #list))
        WH.send("report", "Death storm", string.format("Account %s respawned %d times in 3 minutes", LP.Name, #list), 15158332, 2)
    end
end

function Resp.tick()
    local R = CFG.RESPAWN
    if not R.ENABLED then return 10 end
    local active = Sess.active and not Sess.signaledAt and Vx.loaded and not Vx.failed and Vx.mode
    if not active or Farm.stopped or (Sess.endAt - os.time()) <= CFG.FARM_STOP_BEFORE + 30 then
        Resp.pending, Resp.watch, Resp.base = false, nil, nil
        return 3
    end
    local now, cur = os.time(), Farm.probe()      -- nil while there is no HumanoidRootPart (dead / respawning)
    if Resp.storm and #Resp.spawns < R.STORM_COUNT then Resp.storm = false end

    if not Resp.pending then
        -- WHY learn hadFarm from evidence: only a farm that demonstrably worked can have been killed by a death
        if cur and Resp.base and Farm.progressed(Resp.base, cur, CFG.IDLE.MOVE_STUDS) then Resp.hadFarm = true end
        Resp.base = cur
        return 3
    end

    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if not cur or not hum or hum.Health <= 0 or not Team.done() then Resp.watch = nil return 3 end
    if os.clock() - Resp.spawnAt < R.SETTLE then Resp.watch = nil return 3 end

    local w = Resp.watch
    if not w then Resp.watch = { prev = cur, since = now } return 3 end
    if Farm.progressed(w.prev, cur, CFG.IDLE.MOVE_STUDS) then
        Log.add("I", string.format("respawn: farm resumed (rung %d)", Resp.stage))
        Resp.pending, Resp.watch, Resp.stage, Resp.base = false, nil, 0, cur
        return 3
    end
    if now - w.since < R.WATCH then return 3 end

    -- a full WATCH window without progress: climb one rung
    Resp.stage, Resp.watch = Resp.stage + 1, nil
    local sw = Farm.toggle()
    if Resp.stage == 1 and sw and Vx.hub ~= "kaitun" then
        local cfg = type(env.Config) == "table" and env.Config or nil
        Vx.reassert()
        if cfg then cfg[Farm.KEY] = false task.wait(1.5) cfg[Farm.KEY] = true end
        Farm.note("respawn: no progress, cycled Start Farm")
    elseif Resp.stage <= 2 then
        local ok, why = Vx.reloadNow("respawn rung " .. Resp.stage .. (sw and "" or ", hub UI missing"))
        if not ok then
            Farm.note("respawn: reload skipped (" .. tostring(why) .. ")")
            if why == "cooldown" then Resp.stage = Resp.stage - 1 end   -- not a real attempt, retry on the next window
        end
    else
        Farm.note("respawn: recovery failed, handing over to the idle verifier")
        WH.send("report", "Respawn recovery failed", "Account " .. LP.Name .. ": farm did not resume after a respawn (cycle + reload tried)", 15158332, 3)
        Resp.pending, Resp.watch, Resp.stage = false, nil, 0
    end
    return 3
end

----------------------------------------------------------------
-- 12d. SWAP ENFORCER (from v22.1)
--   Problem: Kaitun runs its own farm loop that this script cannot stop, so after the session-end signal the account just
--   keeps farming and the scheduler never completes the swap.
--   Design: stop trying to stop Kaitun. A swap needs this client to go away, so we make sure it does, in two cases:
--     A) the scheduler consumed the signal (file deleted) but we are still alive ACK_GRACE seconds later,
--     B) the signal was never consumed for FORCE_AFTER seconds (scheduler down/stuck); set FORCE_AFTER = 0 to only alert.
--   Why not kill the character (BreakJoints): Kaitun respawns and keeps farming, and a death streak has its own costs.
--   Why not close immediately: the scheduler may still be about to read the signal; closing first could make it treat the
--   account as crashed instead of finished. The grace times give it the chance to do its own, cleaner swap first.
----------------------------------------------------------------
function Swap.reset() Swap.closing, Swap.quiesced, Swap.lastClose = false, false, nil end
Swap.reset()

-- Best effort: if Kaitun reads its config live, this stops farming. If it copied the config at load, it is a no-op.
function Swap.quiesce()
    local bf = type(env.Config) == "table" and env.Config["Blox Fruits"] or nil
    if type(bf) ~= "table" then return 0 end
    local n = 0
    local function off(t, depth)
        if depth > 6 then return end
        for k, v in pairs(t) do
            if v == true then t[k] = false n = n + 1
            elseif type(v) == "table" then off(v, depth + 1) end
        end
    end
    off(bf, 0)
    return n
end

function Swap.close(reason)
    if Swap.closing then return end
    Swap.closing = true
    Log.add("W", "swap enforcer: closing the client (" .. reason .. ")")
    WH.send("report", "Closing client", "Account " .. LP.Name .. ": " .. reason, 15158332, 3)
    -- the process is about to die: let the webhook post and the files reach disk first
    local t0 = os.clock()
    while os.clock() - t0 < CFG.SWAP.FLUSH_WAIT and WH.pending() > 0 do task.wait(0.5) end
    pcall(function() Log.flush() Store.save(true) WH.saveOutbox() end)
    if CFG.SWAP.ACTION == "shutdown" then
        pcall(function() game:Shutdown() end)
        task.wait(5)
    end
    -- still here (Shutdown unavailable or ACTION = "kick"): the disconnect prompt is something every scheduler must handle anyway
    pcall(function() LP:Kick("BloxFactory: session over, switching account") end)
    task.wait(8)
    Swap.closing, Swap.lastClose = false, os.time()    -- survived everything: allow a retry after RETRY seconds
    Log.add("E", "swap enforcer: client is still running after every close attempt")
end

function Swap.tick()
    local W = CFG.SWAP
    if not W.ENABLED or not Sess.signaledAt then return 5 end
    -- v24: on Vxeze the farm can be stopped cleanly, so the scheduler normally closes the client itself
    if Vx.hub == "vxeze" and not W.ON_VXEZE then return 5 end
    local now = os.time()
    if W.QUIESCE and not Swap.quiesced then
        Swap.quiesced = true
        Log.add("I", "swap enforcer: " .. Swap.quiesce() .. " config switch(es) turned off after the session-end signal")
    end
    if Swap.closing or W.ACTION == "none" then return 5 end
    if Swap.lastClose and now - Swap.lastClose < W.RETRY then return 5 end
    if Sess.acked then
        if now - (Sess.ackedAt or now) >= W.ACK_GRACE then
            Swap.close("the scheduler consumed the signal " .. W.ACK_GRACE .. "s ago but the client is still running")
        end
    elseif W.FORCE_AFTER > 0 and now - Sess.signaledAt >= W.FORCE_AFTER then
        Swap.close("signal not consumed after " .. W.FORCE_AFTER .. "s")
    end
    return 5
end

----------------------------------------------------------------
-- 12e. WEAPON GUARD (v24, Kaitun only)
--   Why this exists: the Kaitun schema offers "Farm Mastery"."Weapon Farm" = { "Sword", "Melee" } by default, and with a Yama /
--   Saber in the inventory the hub's mastery loop equips it. The config is fixed in Vx.kaitunForce, but the hub's source is not
--   visible from here, so the config is not trusted to be enough: this guard looks at what the character actually holds.
--   Ladder: 1) unequip the forbidden tool and equip a Melee tool   2) if the hub keeps putting it back (FIGHT_LIMIT times within
--   FIGHT_WINDOW seconds) move the forbidden tools out of the Backpack on THIS client only (the server keeps them) so the hub has
--   nothing to pick. Undone by Weapon.restore() on unload / env.BloxSM.WeaponRestore().
----------------------------------------------------------------
Weapon.hits, Weapon.total, Weapon.lastLog = {}, 0, -1000
Weapon.stash, Weapon.stashed, Weapon.stashMode = nil, {}, false

local function toolTip(t) local ok, v = pcall(function() return t.ToolTip end) return ok and v or nil end

function Weapon.isForbidden(tool)
    local G = CFG.KAITUN.GUARD
    local tip = toolTip(tool)
    if tip then for _, t in ipairs(G.FORBID_TIPS) do if tip == t then return true end end end
    local nm = string.lower(tool.Name)
    for _, n in ipairs(G.FORBID_NAMES) do if nm == string.lower(n) then return true end end
    return false
end
function Weapon.pickMelee()
    local best, rank
    for _, holder in ipairs({ LP:FindFirstChild("Backpack"), LP.Character }) do
        if holder then
            for _, t in ipairs(holder:GetChildren()) do
                if t:IsA("Tool") and toolTip(t) == "Melee" then
                    local r = 99
                    for i, n in ipairs(CFG.KAITUN.GUARD.MELEE_PREFER) do if t.Name == n then r = i break end end
                    if not rank or r < rank then best, rank = t, r end
                end
            end
        end
    end
    return best
end
function Weapon.stashTool(t)
    Weapon.stash = Weapon.stash or Instance.new("Folder")
    local ok = pcall(function() t.Parent = Weapon.stash end)
    if ok then Weapon.stashed[#Weapon.stashed + 1] = t end
    return ok
end
function Weapon.sweep()
    local n = 0
    local ch = LP.Character
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum:UnequipTools() end) end
    for _, holder in ipairs({ LP:FindFirstChild("Backpack"), ch }) do
        if holder then
            for _, t in ipairs(holder:GetChildren()) do
                if t:IsA("Tool") and Weapon.isForbidden(t) and Weapon.stashTool(t) then n = n + 1 end
            end
        end
    end
    return n
end
function Weapon.restore()
    local n = 0
    local bp = LP:FindFirstChild("Backpack")
    for _, t in ipairs(Weapon.stashed) do
        if bp and t.Parent == Weapon.stash and pcall(function() t.Parent = bp end) then n = n + 1 end
    end
    Weapon.stashed, Weapon.stashMode, Weapon.hits = {}, false, {}
    return n
end
function Weapon.tick()
    local G = CFG.KAITUN.GUARD
    if not G.ENABLED or Vx.hub ~= "kaitun" or not Sess.active then return 5 end
    local ch = LP.Character
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return 2 end
    local bad
    for _, t in ipairs(ch:GetChildren()) do
        if t:IsA("Tool") and Weapon.isForbidden(t) then bad = t break end
    end
    if not bad then
        if Weapon.stashMode then      -- a respawn gives the Backpack fresh copies: keep them out of reach
            local bp = LP:FindFirstChild("Backpack")
            for _, t in ipairs(bp and bp:GetChildren() or {}) do
                if t:IsA("Tool") and Weapon.isForbidden(t) and Weapon.stashTool(t) then
                    Log.add("I", "weapon guard: stashed a new copy of " .. t.Name)
                end
            end
        end
        return G.CHECK
    end
    local now = os.clock()
    local hits = Weapon.hits
    hits[#hits + 1] = now
    while #hits > 0 and now - hits[1] > G.FIGHT_WINDOW do table.remove(hits, 1) end
    Weapon.total = Weapon.total + 1
    if now - Weapon.lastLog >= 30 then
        Weapon.lastLog = now
        Log.add("W", string.format("weapon guard: %s (%s) was equipped by the hub, back to melee (%d in %ds, %d total)",
            bad.Name, tostring(toolTip(bad)), #hits, G.FIGHT_WINDOW, Weapon.total))
    end
    pcall(function() hum:UnequipTools() end)
    if G.EQUIP_MELEE then
        local m = Weapon.pickMelee()
        if m then pcall(function() hum:EquipTool(m) end) end
    end
    if G.STASH and not Weapon.stashMode and #hits >= G.FIGHT_LIMIT then
        Weapon.hits = {}
        local n = Weapon.sweep()
        Weapon.stashMode = true
        Log.add("W", string.format("weapon guard: the hub re-equipped a forbidden weapon %d times in %ds, %d tool(s) moved out of the Backpack on this client", G.FIGHT_LIMIT, G.FIGHT_WINDOW, n))
        WH.send("report", "Weapon guard escalated", string.format("Account %s: Kaitun kept re-equipping %s, %d tool(s) hidden client-side", LP.Name, bad.Name, n), 16776960, 2)
    end
    return G.CHECK
end
function Weapon.statusText()
    return string.format("hits=%d stash=%s hidden=%d", Weapon.total, tostring(Weapon.stashMode), #Weapon.stashed)
end

----------------------------------------------------------------
-- 13. GACHA
----------------------------------------------------------------
local HIGH_NORM = {}
for _, k in ipairs(HIGH_TIER) do HIGH_NORM[#HIGH_NORM + 1] = words(k) end
local function splitCamel(s) return (tostring(s):gsub("(%l)(%u)", "%1 %2")) end
local function IsHighTier(name)
    local w = words(splitCamel(name))
    for _, k in ipairs(HIGH_NORM) do if string.find(w, k, 1, true) then return true end end
    return false
end
Gacha.IsHighTier = IsHighTier

local function formatNum(n)
    local s = string.format("%d", math.floor(tonumber(n) or 0))
    while true do
        local r, i = s:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
        s = r
        if i == 0 then break end
    end
    return s
end
function Gacha.getBeli()
    local ok, v = pcall(function()
        local d = LP:FindFirstChild("Data")
        local b = d and d:FindFirstChild("Beli")
        return (b and b:IsA("ValueBase")) and b.Value or 0
    end)
    return ok and v or 0
end
function Gacha.snapshot()
    local out = {}
    for _, cont in ipairs({ LP:FindFirstChild("Backpack"), LP.Character }) do
        if cont then
            for _, it in ipairs(cont:GetChildren()) do
                if it:IsA("Tool") then
                    local n = it:GetAttribute("OriginalName") or it.Name
                    out[n] = out[n] or { count = 0, tool = it }
                    out[n].count = out[n].count + 1
                end
            end
        end
    end
    return out
end
function Gacha.rollRemote()
    local cf = commF()
    local ok, res = pcall(function() return cf and cf:InvokeServer("Cousin", "Buy") end)
    if ok and res ~= nil and res ~= false then return res end
    local ok2, res2 = pcall(function()
        local net = RS:FindFirstChild("Modules") and RS.Modules:FindFirstChild("Net")
        local rf = net and net:FindFirstChild("RF/GachaNetworkRF")
        return rf and rf:InvokeServer({ Context = "Purchase", BoxName = "ZiolesGacha" })
    end)
    if ok2 and res2 ~= nil and res2 ~= false then return res2 end
end
function Gacha.resetSession() Gacha.fails, Gacha.retryAt, Gacha.reportedStuck = 0, 0, false end
Gacha.resetSession()

function Gacha.store(name, tool)
    for attempt = 1, 3 do
        local cf = commF()
        pcall(function() if cf then cf:InvokeServer("StoreFruit", name, tool) end end)
        task.wait(1)
        if not tool:IsDescendantOf(game) then return true end
        task.wait(1)
    end
    return false
end

function Gacha.roll()
    UI.status("Rolling gacha...")
    local before = Gacha.snapshot()
    Gacha.rollRemote()
    task.wait(2.5)
    local rawBeli = Gacha.getBeli()
    local low = rawBeli < CFG.LOW_BELI
    local beliText = low and ("LOW BELI: " .. formatNum(rawBeli)) or ("Beli left: " .. formatNum(rawBeli))
    local got, highs = false, {}
    for name, info in pairs(Gacha.snapshot()) do
        if info.count > ((before[name] and before[name].count) or 0) then
            got = true
            if IsHighTier(name) then highs[#highs + 1] = { name = name, tool = info.tool } else UI.status("Ignored low-tier item: " .. name) end
        end
    end
    for _, h in ipairs(highs) do
        UI.status("HIGH TIER: " .. h.name .. " - storing")
        local stored = Gacha.store(h.name, h.tool)
        Store.set("highTier", Store.data.highTier + 1)
        UI.status(stored and ("Stored in chest: " .. h.name) or ("STORE FAILED: " .. h.name))
        WH.send("fruit", "HIGH TIER OBTAINED",
            string.format("GOT A HIGH TIER: **%s** %s\n%s", h.name, stored and "(Stored in Chest)" or "(Store FAILED - still in Backpack)", beliText),
            low and 16711680 or 16776960, 2)
    end
    if got then
        Gacha.fails = 0
        Store.set("lastRoll", os.time())
        Store.set("rolls", Store.data.rolls + 1)
        Store.save(true)
        WH.send("report", "Roll Report", "Status: new item received\n" .. beliText, low and 16711680 or 3447003, 1)
    else
        Gacha.fails = Gacha.fails + 1
        local delay = math.min(300, 45 * 2 ^ (Gacha.fails - 1))
        Gacha.retryAt = os.time() + delay
        UI.status("No new item (cooldown?), retry in " .. delay .. "s")
        if Gacha.fails == 3 and not Gacha.reportedStuck then
            Gacha.reportedStuck = true
            WH.send("report", "Roll not succeeding", "3 failed rolls in a row on " .. LP.Name .. " (" .. beliText .. ")", 15158332, 1)
        end
    end
end
function Gacha.tick()
    if not Sess.active or Sess.signaledAt then return 5 end
    if not Team.done() or not hasHRP() then return 3 end
    local due = math.max(Store.data.lastRoll + CFG.ROLL_INTERVAL, Gacha.retryAt)
    local rem = due - os.time()
    if rem > 0 then return math.min(rem, 20) end
    if Sess.endAt - os.time() < 5 then return 5 end
    Gacha.roll()
    return 1
end

----------------------------------------------------------------
-- 13b. CODES (v23): native auto-redeem
--   WHY native: Vxeze has no such feature, an unknown key in the injected config is simply ignored.
--   * Remote: ReplicatedStorage.Remotes.Redeem (RemoteFunction), the argument is the code. The reply format is not
--     documented, so every raw reply is logged; a code counts as processed once the server answered at all.
--   * Results live in Store.data.codes (per account): an XP code that is sent twice is wasted, a dead one is just noise.
--   * Reset/refund codes are never sent: they would wipe the points the Stats module allocated.
----------------------------------------------------------------
Codes.queue, Codes.i, Codes.started, Codes.t0, Codes.noRemote = nil, 1, false, 0, 0
Codes.done = false
Codes.counts = { ok = 0, used = 0, dead = 0, unknown = 0, failed = 0, skipped = 0 }

function Codes.blocked(code)
    local l = string.lower(code)
    for _, s in ipairs(CFG.CODES.SKIP) do if string.lower(s) == l then return true end end
    for _, p in ipairs(CFG.CODES.SKIP_PATTERNS) do if l:find(p, 1, true) then return true end end
    return false
end

function Codes.build()
    local seen, list = {}, {}
    local function add(c)
        c = tostring(c or ""):match("^%s*(.-)%s*$")
        -- WHY the charset check: the feed is plain text from a URL, only plausible code strings may reach the remote
        if c ~= "" and #c <= 40 and c:match("^[%w_%-]+$") and not seen[string.lower(c)] then
            seen[string.lower(c)] = true
            list[#list + 1] = c
        end
    end
    for _, c in ipairs(CFG.CODES.LIST) do add(c) end
    local url = CFG.CODES.FEED_URL
    if type(url) == "string" and url:match("^https?://") then
        local ok, body = pcall(function() return game:HttpGet(url) end)
        if ok and type(body) == "string" then
            for line in body:gmatch("[^\r\n]+") do
                if not line:match("^%s*[#%-]") then add((line:gsub("[,;].*$", ""))) end
            end
        else
            Log.add("W", "codes: feed url could not be fetched")
        end
    end
    return list
end

-- InvokeServer yields until the server answers; a code must never be able to stall the whole service.
local function invokeWithTimeout(remote, timeout, ...)
    local args, n = { ... }, select("#", ...)
    local finished, ok, res = false, false, nil
    task.spawn(function()
        ok, res = pcall(function() return remote:InvokeServer(table.unpack(args, 1, n)) end)
        finished = true
    end)
    local t0 = os.clock()
    while not finished and os.clock() - t0 < timeout do task.wait(0.2) end
    if not finished then return false, "timeout" end
    return ok, res
end

local function replyText(r)
    if type(r) == "string" then return r end
    if type(r) == "table" then
        local ok, j = pcall(function() return HttpService:JSONEncode(r) end)
        return ok and j or tostring(r)
    end
    return tostring(r)
end

function Codes.classify(text)
    local l = string.lower(text)
    if l == "" or l == "nil" then return "unknown" end
    if l:find("already", 1, true) or l:find("used", 1, true) then return "used" end
    if l:find("invalid", 1, true) or l:find("expire", 1, true) or l:find("not valid", 1, true) or l:find("wrong", 1, true) then return "dead" end
    return "ok"
end

function Codes.finish()
    Codes.done = true
    local n = Codes.counts
    local line = string.format("codes: ok=%d used=%d dead=%d unknown=%d failed=%d skipped=%d", n.ok, n.used, n.dead, n.unknown, n.failed, n.skipped)
    Log.add("I", line)
    UI.status(line)
end

-- One code per call, so the service heartbeat keeps ticking and a slow server never blocks anything else.
function Codes.tick()
    local c = CFG.CODES
    if not c.ENABLED or Codes.done then return false end
    if Vx.hub ~= "vxeze" then return 10 end   -- v24: auto redeem is a Vxeze-mode feature (returning false would stop the service for good)
    if not (Sess.active and not Sess.signaledAt) then return 5 end
    if not (Team.done() and hasHRP()) then return 5 end
    local folder = RS:FindFirstChild("Remotes")
    local remote = folder and folder:FindFirstChild("Redeem")
    if not remote then
        Codes.noRemote = Codes.noRemote + 1
        if Codes.noRemote >= 12 then Log.add("W", "codes: Remotes.Redeem not found, giving up") Codes.done = true return false end
        return 5
    end
    if not Codes.started then Codes.started, Codes.t0 = true, os.clock() end
    -- WHY a short delay: the XP boost timer starts at redeem, so wait until the character is actually farming
    if os.clock() - Codes.t0 < c.START_DELAY then return 2 end
    Codes.queue = Codes.queue or Codes.build()

    local rec = Store.data.codes
    while Codes.i <= #Codes.queue do
        local code = Codes.queue[Codes.i]
        Codes.i = Codes.i + 1
        local e = rec[code]
        if Codes.blocked(code) then
            Codes.counts.skipped = Codes.counts.skipped + 1
        elseif type(e) == "table" and (e.done or (e.tries or 0) >= c.MAX_TRIES) then
            Codes.counts.skipped = Codes.counts.skipped + 1    -- handled on an earlier run
        else
            local ok, res = invokeWithTimeout(remote, c.REPLY_TIMEOUT, code)
            e = type(e) == "table" and e or {}
            if ok then
                local text = replyText(res)
                local kind = Codes.classify(text)
                rec[code] = { done = true, kind = kind, reply = string.sub(text, 1, 80), at = os.time() }
                Codes.counts[kind] = Codes.counts[kind] + 1
                Log.add("I", string.format("codes: %s -> %s (%s)", code, kind, string.sub(text, 1, 80)))
            else
                e.tries, e.last = (e.tries or 0) + 1, string.sub(tostring(res), 1, 80)
                rec[code] = e
                Codes.counts.failed = Codes.counts.failed + 1
                Log.add("W", string.format("codes: %s failed (%s), try %d/%d", code, tostring(res), e.tries, c.MAX_TRIES))
            end
            Store.set("codes", rec)
            return c.GAP
        end
    end
    Codes.finish()
    return false
end

-- Manual re-run (env.BloxSM.CodesRun), e.g. after editing CFG.CODES.LIST or pointing FEED_URL at a new list.
function Codes.rerun()
    Codes.queue, Codes.i, Codes.started, Codes.done, Codes.noRemote = nil, 1, false, false, 0
    Codes.counts = { ok = 0, used = 0, dead = 0, unknown = 0, failed = 0, skipped = 0 }
    Task.service("codes-manual", 3, Codes.tick)
end

----------------------------------------------------------------
-- 14. SEA GUARD
----------------------------------------------------------------
Sea.PLACES = { [2753915549] = 1, [4442272183] = 2, [7449423635] = 3 }
Sea.cur = Sea.PLACES[game.PlaceId]
function Sea.reset() Sea.tries, Sea.nextAt, Sea.busy, Sea.busyAt, Sea.readySince = 0, 0, false, 0, nil end
Sea.reset()

-- Keep the script alive across the teleport. ASSUMED: Delta exposes queue_on_teleport and the script is saved as
-- workspace/<CFG.SEA.RELOAD_FILE>. Without either, the scheduler / Delta autoexec must re-run the script in the new server.
function Sea.queueReload()
    local c = CFG.SEA
    if env.BloxReloadQueued == game.JobId then return end
    local q = queue_on_teleport or (syn and syn.queue_on_teleport)
    if type(q) ~= "function" or type(c.RELOAD_FILE) ~= "string" or not FS.exists(c.RELOAD_FILE) then
        Log.add("W", "sea: no reload queued (needs queue_on_teleport + file '" .. tostring(c.RELOAD_FILE) .. "'), relying on autoexec / scheduler")
        return
    end
    if pcall(q, 'loadstring(readfile("' .. c.RELOAD_FILE .. '"))()') then
        env.BloxReloadQueued = game.JobId
        Log.add("I", "sea: reload queued from " .. c.RELOAD_FILE)
    end
end
-- Let the hub run its own sea quest chain (Ice Admiral / Don Swan style requirements cannot be done by one remote call).
function Sea.hubAssist()
    local key = (Sea.cur == 1) and "Auto New World" or "Auto Third World"
    local targets = {}
    if type(env.Config) == "table" then targets[1] = env.Config end
    local okc, copies = pcall(Vx.copies)
    if okc then for _, t in ipairs(copies) do targets[#targets + 1] = t end end
    local flipped = false
    for _, t in ipairs(targets) do
        if t[key] ~= true then t[key] = true flipped = true end
    end
    if flipped then Log.add("W", "sea: hub assist ON (" .. key .. "), the hub runs the sea quest chain itself") end
end
function Sea.tick()
    local c = CFG.SEA
    if Vx.hub == "kaitun" then return 30 end   -- Kaitun handles sea travel itself
    if not CFG.SEA_GUARD or not Sess.active or Sess.signaledAt then return 10 end
    if Sea.cur == nil or Sea.cur == 3 then return 30 end
    if Sea.busy and os.clock() - Sea.busyAt < 30 then return 3 end
    if Sea.tries >= c.MAX_TRIES or os.time() < Sea.nextAt then return 10 end
    -- WHY: v21 fired the remote as soon as Sess.active was set, i.e. possibly during loading / team select where the
    -- server ignores it. Wait until the character exists, the team is chosen, and a few seconds have passed.
    if not (game:IsLoaded() and Team.done() and hasHRP()) then Sea.readySince = nil return 5 end
    Sea.readySince = Sea.readySince or os.clock()
    if os.clock() - Sea.readySince < c.READY_WAIT then return 5 end
    local lv = Vx.readLevel()
    if not lv then return 10 end
    -- WHY: v21 checked "lv >= 1500" first, so a level-1500+ account standing in SEA 1 fired TravelZou (Sea 2 only). Order is by current sea.
    local remote, label
    if Sea.cur == 1 and lv >= 700 then remote, label = "TravelDressrosa", "Sea 2"
    elseif Sea.cur == 2 and lv >= 1500 then remote, label = "TravelZou", "Sea 3" end
    if not remote then
        UI.status("Sea guard: level " .. lv .. " too low for the next sea (Sea " .. Sea.cur .. ")")
        return 120
    end
    Sea.tries = Sea.tries + 1
    Sea.nextAt = os.time() + c.TRY_GAP
    Sea.busy, Sea.busyAt = true, os.clock()
    UI.status("Sea guard: travelling to " .. label .. " (" .. Sea.tries .. "/" .. c.MAX_TRIES .. ")")
    if Sea.tries > c.HUB_ASSIST_AFTER then Sea.hubAssist() end
    -- WHY async: InvokeServer yields until the server answers; run inline it froze this service (watchdog "STALL:sea-guard").
    Task.spawn("sea-travel", function()
        local cf = commF()
        if not cf then Log.add("W", "sea: CommF_ not found") Sea.busy = false return end
        if Sea.cur == 2 and c.DIAG_ZQUEST then   -- ASSUMED read-only check; only logged, never acted on
            local okq, rq = pcall(function() return cf:InvokeServer("ZQuestProgress", "Check") end)
            Log.add("I", "sea: ZQuestProgress/Check -> " .. (okq and (type(rq) .. ":" .. tostring(rq)) or ("error " .. tostring(rq))))
        end
        Sea.queueReload()
        local ok, res = pcall(function() return cf:InvokeServer(remote) end)
        Log.add(ok and "I" or "W", "sea: " .. remote .. " -> " .. (ok and (type(res) .. ":" .. tostring(res)) or ("error " .. tostring(res))))
        Sea.busy = false
    end)
    return 5
end

----------------------------------------------------------------
-- 14b. STATS
----------------------------------------------------------------
Stats.NAMES = { "Melee", "Defense", "Sword", "Gun", "Demon Fruit" }
Stats.ALIAS = { Fruit = "Demon Fruit", ["Blox Fruit"] = "Demon Fruit" }
Stats.CODES = { Str = "Melee", Vit = "Defense", Int = "Demon Fruit", SP = "Sword", Agi = "Gun" }
Stats.CODE_OF = { Melee = "Str", Defense = "Vit", ["Demon Fruit"] = "Int", Sword = "SP", Gun = "Agi" }
Stats.remote, Stats.tpl, Stats.vals, Stats.last = nil, nil, nil, nil
Stats.pausedUntil, Stats.pauseWhy, Stats.busy, Stats.learnState = 0, nil, false, nil
Stats.fails, Stats.bindFails, Stats.expectUntil, Stats.amountOk, Stats.dumped, Stats.state = 0, 0, 0, true, false, "off"
Stats.bad, Stats.zero, Stats.uiMap = {}, {}, nil

local function statKey(name) return Stats.ALIAS[name] or name end

function Stats.bind()
    local data = LP:FindFirstChild("Data")
    local pts = data and data:FindFirstChild("Points")
    local folder = data and data:FindFirstChild("Stats")
    if not (pts and pts:IsA("ValueBase") and folder) then return false end
    local lv, count = {}, 0
    for _, name in ipairs(Stats.NAMES) do
        local node = folder:FindFirstChild(name)
        local v = node and (node:IsA("ValueBase") and node or node:FindFirstChild("Level"))
        if v and v:IsA("ValueBase") then lv[name] = v count = count + 1 end
    end
    if count == 0 then return false end
    Stats.vals = { points = pts, lv = lv }
    return true
end
function Stats.read()
    local v = Stats.vals
    if not v or not v.points.Parent then return nil end
    local levels = {}
    for name, obj in pairs(v.lv) do levels[name] = tonumber(obj.Value) or 0 end
    return tonumber(v.points.Value) or 0, levels
end
function Stats.remember(points, levels)
    local copy = {}
    for k, x in pairs(levels) do copy[k] = x end
    Stats.last = { points = points, levels = copy }
end

function Stats.plan(points, levels, priority, reserve)
    local plan, left = {}, math.max(0, points - (reserve or 0))
    for _, p in ipairs(priority) do
        if left <= 0 then break end
        local stat = statKey(p.stat)
        local cur = levels[stat]
        if cur then
            local need = math.min(left, math.max(0, (p.cap or 2550) - cur))
            if need > 0 then plan[#plan + 1] = { stat = stat, n = need } left = left - need end
        end
    end
    return plan, left
end
function Stats.pause(why, secs)
    Stats.pausedUntil = os.time() + secs
    if Stats.pauseWhy ~= why then Log.add("W", "stats paused: " .. why .. " (" .. secs .. "s)") end
    Stats.pauseWhy = why
end

function Stats.configForeign()
    local cfg = type(env.Config) == "table" and env.Config or nil
    if not cfg then return false end
    for k, v in next, cfg do
        if v == true and type(k) == "string" then
            local l = string.lower(k)
            if l:find("stat", 1, true) or l:find("point", 1, true) then return true, k end
        end
    end
    return false
end
function Stats.valueForeign(points, levels)
    local last = Stats.last
    if not last or os.time() < Stats.expectUntil then return false end
    for stat, lv in pairs(levels) do
        if lv > (last.levels[stat] or lv) then return true end
    end
    return points < last.points
end

function Stats.installHook()
    env.BloxStatsSpy = Stats.onCall
    if type(newcclosure) ~= "function" then return false end
    if not env.BloxStatsFnHooked and type(hookfunction) == "function" then
        local good = true
        local function hook(fn, kind)
            local ok = pcall(function()
                local old
                old = hookfunction(fn, newcclosure(function(self, ...)
                    if env.BloxStatsHot then local spy = env.BloxStatsSpy if spy then spy(self, kind, ...) end end
                    return old(self, ...)
                end))
            end)
            if not ok then good = false end
        end
        hook(Instance.new("RemoteEvent").FireServer, "FireServer")
        hook(Instance.new("RemoteFunction").InvokeServer, "InvokeServer")
        env.BloxStatsFnHooked = good
    end
    if not env.BloxStatsNsHooked and type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" then
        local ok = pcall(function()
            local old
            old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                if not env.BloxStatsHot then return old(self, ...) end
                local m = getnamecallmethod()
                if m == "FireServer" or m == "InvokeServer" then
                    local spy = env.BloxStatsSpy
                    if spy then spy(self, m, ...) end
                    if setnamecallmethod then setnamecallmethod(m) end
                end
                return old(self, ...)
            end))
        end)
        env.BloxStatsNsHooked = ok
    end
    return (env.BloxStatsFnHooked or env.BloxStatsNsHooked) and true or false
end
function Stats.onCall(remote, kind, ...)
    local L, T = Stats.learnState, Stats.testCount
    local isTest = T ~= nil and remote == Stats.testRemote
    if not L and not isTest and not (Stats.remote and remote == Stats.remote) then return end
    local args = table.pack(...)
    pcall(function()
        if isTest then T[T.mode] = (T[T.mode] or 0) + 1 return end
        if L then
            L.seen = L.seen + 1
            L.remotes[remote] = (L.remotes[remote] or 0) + 1
            Stats.record(remote, kind, args)
            return
        end
        if not Stats.busy then Stats.pause("another script fired the stats remote", CFG.STATS.PAUSE_FOREIGN) end
    end)
end

function Stats.dumpLayout()
    if Stats.dumped or not FS.ok() then return end
    Stats.dumped = true
    local out = { "== replicated values under Data ==" }
    local data = LP:FindFirstChild("Data")
    if data then
        for _, d in ipairs(data:GetDescendants()) do
            if d:IsA("ValueBase") then out[#out + 1] = d:GetFullName() .. " = " .. tostring(d.Value) end
        end
    end
    out[#out + 1] = "== candidate remotes =="
    for _, d in ipairs(RS:GetDescendants()) do
        if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
            local n = string.lower(d.Name)
            if n:find("point", 1, true) or n:find("stat", 1, true) or n:find("upgrade", 1, true) or n:find("alloc", 1, true) then
                out[#out + 1] = d:GetFullName() .. " [" .. d.ClassName .. "]"
            end
        end
    end
    if type(getconnections) == "function" and type(debug.getconstants) == "function" then
        out[#out + 1] = "== stat button callbacks (string constants) =="
        local main, count = PG:FindFirstChild("Main"), 0
        for _, d in ipairs(main and main:GetDescendants() or {}) do
            if count >= 40 then break end
            if d:IsA("GuiButton") and string.find(string.lower(d:GetFullName()), "stat", 1, true) then
                count = count + 1
                local ok, cs = pcall(getconnections, d.Activated)
                for _, c in ipairs(ok and cs or {}) do
                    local f = c.Function
                    if type(f) == "function" then
                        local okc, consts = pcall(debug.getconstants, f)
                        if okc and type(consts) == "table" then
                            local keep = {}
                            for _, v in ipairs(consts) do if type(v) == "string" then keep[#keep + 1] = v end end
                            out[#out + 1] = d:GetFullName() .. " -> " .. table.concat(keep, ", ")
                        end
                    end
                end
            end
        end
    end
    FS.write("StatsLayout_" .. UID .. ".txt", table.concat(out, "\n"))
    Log.add("I", "stats layout written to StatsLayout_" .. UID .. ".txt")
end

function Stats.learn()
    if not Stats.vals and not Stats.bind() then Stats.dumpLayout() UI.status("LEARN: stat values not found, see StatsLayout file") return false end
    if not Stats.installHook() then UI.status("LEARN: no usable hook on this executor (hookfunction / hookmetamethod)") return false end
    local secs = CFG.STATS.LEARN_SECONDS or 90
    Stats.learnState = { samples = {}, deadline = os.clock() + secs, remote = nil, seen = 0, remotes = {} }
    env.BloxStatsHot = true
    UI.status("LEARN: press + on one stat, then + on a DIFFERENT stat (" .. secs .. "s)")
    return true
end
function Stats.hookTest()
    if not Stats.installHook() then UI.status("HOOKTEST: no usable hook on this executor") return false end
    local r = Instance.new("RemoteEvent")
    local t = { colon = 0, dot = 0, mode = "colon" }
    Stats.testRemote, Stats.testCount = r, t
    local wasHot = env.BloxStatsHot
    env.BloxStatsHot = true
    pcall(function() r:FireServer("hooktest") end)
    t.mode = "dot"
    pcall(function() r.FireServer(r, "hooktest") end)
    env.BloxStatsHot = wasHot
    Stats.testRemote, Stats.testCount = nil, nil
    UI.status(string.format("HOOKTEST: colon-call seen %d/1, dot-call seen %d/1 (function hook %s, namecall hook %s)", t.colon, t.dot, tostring(env.BloxStatsFnHooked), tostring(env.BloxStatsNsHooked)))
    return t.colon == 1 and t.dot == 1
end
function Stats.record(remote, kind, args)
    local L = Stats.learnState
    local stat
    for i = 1, args.n do
        local a = args[i]
        if type(a) == "string" then
            for _, name in ipairs(Stats.NAMES) do if a == name or Stats.ALIAS[a] == name or Stats.CODES[a] == name then stat = name end end
        end
    end
    if not stat then return end
    for i = 1, args.n do
        local t = type(args[i])
        if t ~= "string" and t ~= "number" and t ~= "boolean" then return end
    end
    if L.remote and L.remote ~= remote then return end
    for _, s in ipairs(L.samples) do if s.stat == stat then return end end
    L.remote = remote
    local p, lv = Stats.read()
    local sample = { stat = stat, kind = kind, args = args, before = lv and lv[stat], done = false }
    L.samples[#L.samples + 1] = sample
    UI.status("LEARN: captured " .. stat .. " (" .. #L.samples .. "/2)")
    task.delay(1.5, function()
        local _, lv2 = Stats.read()
        sample.delta = (lv2 and sample.before) and (lv2[stat] - sample.before) or nil
        sample.done = true
    end)
end
function Stats.derive(L)
    local s1, s2 = L.samples[1], L.samples[2]
    if s1.args.n ~= s2.args.n then return false, "argument count differs between the two clicks" end
    if not (s1.delta and s1.delta > 0 and s2.delta and s2.delta > 0) then return false, "stat level did not increase (values not replicated?)" end
    local n = s1.args.n
    local full = L.remote:GetFullName()
    local rel = full:match("^Players%.[^%.]+%.PlayerGui%.(.+)$")
    local tpl = { path = rel or full, gui = rel ~= nil, kind = s1.kind, n = n, args = {}, statArg = {} }
    for i = 1, n do
        local a, b = s1.args[i], s2.args[i]
        tpl.args[i] = a
        if type(a) == "string" and type(b) == "string" and a ~= b then
            tpl.statSlot = i
            tpl.statArg[s1.stat], tpl.statArg[s2.stat] = a, b
        elseif type(a) == "number" and a == b and s1.delta == a and s2.delta == a then
            tpl.amountSlot = i
        end
    end
    if not tpl.statSlot then return false, "could not find the stat argument" end
    if not FS.writeJSON(CFG.STATS.REMOTE_FILE, tpl) then return false, "could not write " .. CFG.STATS.REMOTE_FILE end
    Stats.tpl, Stats.remote = tpl, L.remote
    return true
end
function Stats.learnTick()
    local L = Stats.learnState
    local function cool() env.BloxStatsHot = (CFG.STATS.WATCH_REMOTE and Stats.remote ~= nil) or false end
    if os.clock() > L.deadline then
        local names, n = {}, 0
        for r, cnt in pairs(L.remotes) do
            n = n + 1
            if n <= 6 then
                local ok, nm = pcall(r.GetFullName, r)
                names[#names + 1] = (ok and nm or "?") .. " x" .. cnt
            end
        end
        Stats.learnState = nil
        cool()
        UI.status(string.format("LEARN: timed out, hooks saw %d remote call(s) [function hook %s, namecall hook %s] %s", L.seen, tostring(env.BloxStatsFnHooked), tostring(env.BloxStatsNsHooked), table.concat(names, ", ")))
        return 30
    end
    if #L.samples >= 2 and L.samples[1].done and L.samples[2].done then
        local ok, err = Stats.derive(L)
        Stats.learnState = nil
        cool()
        UI.status(ok and "LEARN: remote saved, set CFG.STATS.ENABLED = true" or ("LEARN failed: " .. tostring(err)))
        return 10
    end
    return 1
end
function Stats.resolve()
    local tpl = FS.readJSON(CFG.STATS.REMOTE_FILE)
    if tpl and tpl.kind == "ui" then          -- v22: the "+" buttons are the driver, mapped by label every time PlayerGui is rebuilt
        Stats.uiReverse = tpl.reverse == true
        local map = Stats.uiMapButtons()
        if map and next(map) then
            local any
            for _, b in pairs(map) do any = b break end
            Stats.uiMap, Stats.tpl, Stats.remote = map, tpl, any
            return true
        end
        return false
    end
    if not tpl or type(tpl.path) ~= "string" or type(tpl.args) ~= "table" then return false end
    local inst = tpl.gui and PG or game
    for seg in string.gmatch(tpl.path, "[^%.]+") do inst = inst and inst:FindFirstChild(seg) end
    if inst and inst ~= game and inst ~= PG and (inst:IsA("RemoteEvent") or inst:IsA("RemoteFunction")) then
        Stats.tpl, Stats.remote = tpl, inst
        return true
    end
    return false
end

function Stats.findRemote()
    local rel = CFG.STATS.REMOTE_PATH
    if rel and rel ~= "" then
        local inst = PG
        for seg in string.gmatch(rel, "[^%.]+") do inst = inst and inst:FindFirstChild(seg) end
        if inst and inst ~= PG and (inst:IsA("RemoteEvent") or inst:IsA("RemoteFunction")) then return inst end
    end
    local box = PG:FindFirstChild("AddingPoints", true)
    for _, d in ipairs(box and box:GetDescendants() or {}) do
        if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then return d end
    end
end
function Stats.remoteCandidates()
    local out = {}
    -- WHY CommF_ first: it is the remote every Blox Fruits stat script has used for years and it takes the stat's internal
    -- English name, so the language of the game UI does not matter.
    local folder = RS:FindFirstChild("Remotes")
    local cf = folder and folder:FindFirstChild("CommF_")
    if cf then out[#out + 1] = { remote = cf, tag = "CommF_", style = "name", shapes = CFG.STATS.COMMF_SHAPES } end
    local r = Stats.findRemote()
    if r then out[#out + 1] = { remote = r, tag = "StatsFrame", style = "code", shapes = CFG.STATS.PROBE_SHAPES } end
    return out
end
local function fillShape(shape, code, amount)
    local out = {}
    for i, v in ipairs(shape) do
        if v == "{stat}" then out[i] = code
        elseif v == "{n}" then out[i] = amount or 1
        else out[i] = v end
    end
    return out
end
-- ---- v22 probe: every attempt is logged to StatsProbe_<UID>.txt so a failure explains itself ----
function Stats.logProbe(line)
    Stats.probeLog = Stats.probeLog or {}
    local pl = Stats.probeLog
    pl[#pl + 1] = os.date("%H:%M:%S") .. " " .. line
    if #pl > 120 then table.remove(pl, 1) end
    FS.write("StatsProbe_" .. UID .. ".txt", table.concat(pl, "\n"))
end
function Stats.snapData()
    local out, n = {}, 0
    local data = LP:FindFirstChild("Data")
    if not data then return out end
    for _, d in ipairs(data:GetDescendants()) do
        if d:IsA("ValueBase") then
            n = n + 1
            if n > 400 then break end
            local ok, v = pcall(function() return d.Value end)
            if ok then out[d:GetFullName()] = v end
        end
    end
    return out
end
function Stats.diffData(a, b)
    local d = {}
    for k, v in pairs(b) do
        if a[k] ~= v then
            local short = (k:gsub("^.-%.Data%.", ""))
            d[#d + 1] = short .. ": " .. tostring(a[k]) .. " -> " .. tostring(v)
        end
    end
    table.sort(d)
    return d
end
-- Run `fire`, then watch the replicated values. Returns gainedStat|nil, pointsDelta|nil, changedList, errorText|nil.
function Stats.attempt(fire)
    local c = CFG.STATS
    local before = Stats.snapData()
    local p0, l0 = Stats.read()
    l0 = l0 or {}
    Stats.expectUntil = os.time() + c.VERIFY_TIMEOUT + 5
    Stats.busy = true
    local ok, err = pcall(fire)
    Stats.busy = false
    local gained, t0 = nil, os.clock()
    repeat
        task.wait(0.25)
        local _, l1 = Stats.read()
        for name, lv in pairs(l1 or {}) do if lv > (l0[name] or lv) then gained = name end end
    until gained or os.clock() - t0 > c.VERIFY_TIMEOUT
    local p1 = Stats.read()
    local diff = Stats.diffData(before, Stats.snapData())
    return gained, (p0 and p1) and (p0 - p1) or nil, diff, (not ok) and tostring(err) or nil
end

function Stats.uiRoot()
    local root = PG:FindFirstChild("StatsFrame", true)
    if not root then
        local box = PG:FindFirstChild("AddingPoints", true)
        root = box and box.Parent
    end
    return root
end
function Stats.dumpUi()
    if not FS.ok() then return end
    local root = Stats.uiRoot()
    local out = { "root: " .. (root and root:GetFullName() or "NOT FOUND") }
    if root then
        local n = 0
        for _, d in ipairs(root:GetDescendants()) do
            n = n + 1
            if n > 300 then out[#out + 1] = "... truncated" break end
            local txt = (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Text or ""
            local vis = d:IsA("GuiObject") and tostring(d.Visible) or "-"
            out[#out + 1] = string.format("%s [%s] vis=%s text=%q", (d:GetFullName():gsub("^.-PlayerGui%.", "")), d.ClassName, vis, txt)
        end
    end
    FS.write("StatsUiDump_" .. UID .. ".txt", table.concat(out, "\n"))
    Log.add("I", "stats UI layout written to StatsUiDump_" .. UID .. ".txt")
end
-- Language-independent mapping: "+" is not localised, and the five stat rows are stacked in the game's fixed order
-- (Melee, Defense, Sword, Gun, Demon Fruit). probeUi verifies the first click and flips the order if the layout is reversed.
Stats.uiReverse = false
function Stats.mapByOrder()
    local root = Stats.uiRoot() or PG
    local rows, n = {}, 0
    for _, d in ipairs(root:GetDescendants()) do
        n = n + 1
        if n > 8000 then break end
        if d:IsA("GuiButton") then
            local t = d:IsA("TextButton") and (d.Text or ""):match("^%s*(.-)%s*$") or ""
            local nm = string.lower(d.Name)
            if t == "+" or nm == "plus" or nm == "add" or nm == "addpoint" or nm == "addpoints" then
                local under, p = (root ~= PG), d.Parent
                for _ = 1, 8 do
                    if under or not p or p == PG then break end
                    if string.lower(p.Name):find("stat", 1, true) then under = true end
                    p = p.Parent
                end
                if under then rows[#rows + 1] = { b = d, idx = n } end
            end
        end
    end
    -- WHY idx as last tie-break: AbsolutePosition can be zero while the menu is closed, then DOM order is all we have
    table.sort(rows, function(a, b)
        local ay, by = a.b.AbsolutePosition.Y, b.b.AbsolutePosition.Y
        if math.abs(ay - by) > 4 then return ay < by end
        local ax, bx = a.b.AbsolutePosition.X, b.b.AbsolutePosition.X
        if math.abs(ax - bx) > 4 then return ax < bx end
        return a.idx < b.idx
    end)
    if #rows ~= #Stats.NAMES then
        Stats.logProbe("ui order map: found " .. #rows .. " plus buttons, expected " .. #Stats.NAMES)
        return nil
    end
    local map, ordered = {}, {}
    for i, r in ipairs(rows) do
        ordered[i] = r.b
        map[Stats.NAMES[Stats.uiReverse and (#rows + 1 - i) or i]] = r.b
    end
    Stats.uiOrder = ordered
    return map
end
-- Map stat -> "+" button by reading the labels around each GuiButton. A stat is only accepted when exactly ONE stat
-- identifier (melee/str, defense/vit, sword/sp, gun/agi, fruit/int) appears at the closest container level.
function Stats.uiMapButtons()
    Stats.uiOrder = nil
    local root = Stats.uiRoot()
    if not root then
        local m = Stats.mapByOrder()
        if m and next(m) then return m end
        return nil, "StatsFrame not found"
    end
    local ids = {}
    for stat, code in pairs(Stats.CODE_OF) do ids[string.lower(stat)] = stat ids[string.lower(code)] = stat end
    ids["fruit"], ids["demon"] = "Demon Fruit", "Demon Fruit"
    ids["serangan"], ids["dekat"] = "Melee", "Melee"
    ids["pertahanan"] = "Defense"
    ids["senjata"] = "Sword"
    ids["buah"], ids["blox"] = "Demon Fruit", "Demon Fruit"
    local function statsIn(text)
        local found, count = {}, 0
        for w in string.gmatch(string.lower(splitCamel(tostring(text))), "%a+") do
            local st = ids[w]
            if st and not found[st] then found[st] = true count = count + 1 end
        end
        return found, count
    end
    local best, n = {}, 0
    for _, b in ipairs(root:GetDescendants()) do
        if b:IsA("GuiButton") then
            n = n + 1
            if n > 200 then break end
            local owner, level = nil, b
            for _ = 1, 4 do
                if not level then break end
                local texts = { level.Name }
                if level:IsA("TextButton") then texts[#texts + 1] = level.Text end
                for _, ch in ipairs(level:GetChildren()) do
                    texts[#texts + 1] = ch.Name
                    if ch:IsA("TextLabel") or (ch:IsA("TextButton") and ch ~= b) then texts[#texts + 1] = ch.Text end
                end
                local found, count = statsIn(table.concat(texts, " "))
                if count == 1 then owner = next(found) break end
                if count > 1 then break end
                level = level.Parent
            end
            if owner then
                local score = 0
                local label = b:IsA("TextButton") and b.Text or ""
                local nm = string.lower(b.Name)
                if label:find("+", 1, true) then score = score + 3 end
                if nm:find("add", 1, true) or nm:find("plus", 1, true) then score = score + 2 end
                if label:find("-", 1, true) or nm:find("minus", 1, true) or nm:find("max", 1, true) or nm:find("reset", 1, true) then score = score - 3 end
                if not best[owner] or score > best[owner].score then best[owner] = { btn = b, score = score } end
            end
        end
    end
    local map = {}
    for stat, e in pairs(best) do map[stat] = e.btn end
    if not next(map) then map = Stats.mapByOrder() or {} end    -- labels did not match (localised UI): fall back to position
    return map
end

function Stats.probeRemote(remote, cand, opts)
    opts = opts or {}
    local c = CFG.STATS
    local isFn = remote:IsA("RemoteFunction")
    local shapes = opts.shapes or c.PROBE_SHAPES
    local style = opts.style or "code"        -- "code": Str/Vit/... | "name": Melee/Defense/... (display names, UI language independent)
    Stats.logProbe("remote " .. remote:GetFullName() .. " [" .. remote.ClassName .. "] style=" .. style)
    for si, shape in ipairs(shapes) do
        local slot, nslot
        for i, v in ipairs(shape) do if v == "{stat}" then slot = i elseif v == "{n}" then nslot = i end end
        if slot then
            local stat = cand[1]                   -- first stat that is NOT at its cap (a capped stat can never prove a shape)
            local code = (style == "name") and stat or Stats.CODE_OF[stat]
            local args = fillShape(shape, code, 1)
            local parts = {}
            for i = 1, #shape do parts[i] = tostring(args[i]) end
            local gained, dPts, diff, err = Stats.attempt(function()
                if isFn then
                    -- WHY spawn: InvokeServer yields until the server answers; the verification must not wait on it forever
                    task.spawn(function()
                        local ok, e = pcall(remote.InvokeServer, remote, table.unpack(args, 1, #shape))
                        if not ok then Stats.logProbe("invoke error: " .. tostring(e)) end
                    end)
                else
                    remote:FireServer(table.unpack(args, 1, #shape))
                end
            end)
            Stats.logProbe(string.format("shape#%d (%s) stat=%s -> gained=%s pointsDelta=%s err=%s changed={%s}",
                si, table.concat(parts, ", "), stat, tostring(gained), tostring(dPts), tostring(err), table.concat(diff, "; ", 1, math.min(#diff, 8))))
            if gained or (dPts and dPts > 0) then
                if not gained then
                    Stats.dumpLayout()
                    return false, "call shape #" .. si .. " works (points dropped by " .. tostring(dPts) .. ") but no bound stat value moved, see StatsProbe / StatsLayout files"
                end
                local map = {}
                for st, cd in pairs(Stats.CODE_OF) do map[st] = (style == "name") and st or cd end   -- other stats are INFERRED; allocate() drops any that prove wrong
                map[gained] = code
                local full = remote:GetFullName()
                local rel = full:match("^Players%.[^%.]+%.PlayerGui%.(.+)$")
                local tpl = { path = rel or full, gui = rel ~= nil, kind = isFn and "InvokeServer" or "FireServer", n = #shape,
                    args = fillShape(shape, code, 1), statSlot = slot, amountSlot = nslot, statArg = map, probed = true }
                if not FS.writeJSON(c.REMOTE_FILE, tpl) then Log.add("W", "stats: could not write " .. c.REMOTE_FILE .. ", template kept in memory only") end
                Stats.tpl, Stats.remote, Stats.bad, Stats.zero = tpl, remote, {}, {}
                Stats.amountOk = true
                local p, lv = Stats.read()
                if p then Stats.remember(p, lv) end
                Log.add("I", "stats probe ok: " .. (opts.tag or remote.Name) .. " shape #" .. si .. " (" .. table.concat(parts, ", ") .. ")")
                return true
            end
        end
    end
    return false, "no call shape produced a verified level gain"
end
function Stats.probeUi(cand)
    local map, why = Stats.uiMapButtons()
    if not map or not next(map) then
        Stats.dumpUi()
        return false, "ui: " .. tostring(why or "no stat buttons recognised") .. " (see StatsUiDump file)"
    end
    local names = {}
    for st, b in pairs(map) do names[#names + 1] = st .. "=" .. (b:GetFullName():gsub("^.-PlayerGui%.", "")) end
    table.sort(names)
    Stats.logProbe("ui map: " .. table.concat(names, " | "))
    for _, stat in ipairs(cand) do
        local b = map[stat]
        if b then
            local gained, dPts, diff, err = Stats.attempt(function()
                if not Input.click(b) then error("no connection fired on the button") end
            end)
            Stats.logProbe(string.format("ui click %s -> gained=%s pointsDelta=%s err=%s changed={%s}", stat, tostring(gained), tostring(dPts), tostring(err), table.concat(diff, "; ", 1, math.min(#diff, 8))))
            if gained and gained ~= stat and Stats.uiOrder and not Stats.uiReverse then
                -- WHY: the order map assumed Melee on top. If the click raised another stat the layout is reversed.
                Stats.uiReverse = true
                local m2 = Stats.mapByOrder()
                if m2 and m2[gained] == b then
                    map = m2
                    Stats.logProbe("ui order map was reversed, corrected")
                else
                    Stats.uiReverse, gained = false, nil
                    Stats.logProbe("ui order map does not match what the click did, giving up on it")
                end
            end
            if gained then
                local tpl = { kind = "ui", n = 0, path = "", args = {}, probed = true, statArg = {}, reverse = Stats.uiReverse }
                for st in pairs(map) do tpl.statArg[st] = true end
                if not FS.writeJSON(CFG.STATS.REMOTE_FILE, tpl) then Log.add("W", "stats: could not write " .. CFG.STATS.REMOTE_FILE) end
                Stats.uiMap, Stats.tpl, Stats.remote, Stats.bad, Stats.zero = map, tpl, b, {}, {}
                local p, lv = Stats.read()
                if p then Stats.remember(p, lv) end
                Log.add("I", "stats probe ok: UI driver (" .. #names .. " button(s) mapped)")
                return true
            end
            break      -- one verification click only: every attempt that works costs a point
        end
    end
    Stats.dumpUi()
    return false, "ui: click produced no verified level gain (see StatsProbe / StatsUiDump files)"
end

function Stats.probe()
    local c = CFG.STATS
    if Stats.busy then return false, "busy" end
    if not Stats.vals and not Stats.bind() then return false, "stat values (Data.Points / Data.Stats) not found" end
    local points, levels = Stats.read()
    local need = c.PROBE_MIN_POINTS or 2
    if not points or points < need then return false, "need at least " .. need .. " unspent points (have " .. tostring(points) .. ")" end
    -- WHY: v21 always started with "Str" (Melee). At level 2800 Melee is usually at its cap, the server refuses, no level
    -- moves, and EVERY shape looked wrong. Candidates are therefore the stats still below their cap, in priority order.
    local cand = {}
    for _, p in ipairs(c.PRIORITY) do
        local stat = statKey(p.stat)
        local lv = levels[stat]
        if lv and Stats.CODE_OF[stat] and lv < (p.cap or 2550) then cand[#cand + 1] = stat end
    end
    if #cand == 0 then return false, "every stat is at its cap, nothing to allocate" end
    Stats.logProbe(string.format("probe start: points=%s candidates=%s", tostring(points), table.concat(cand, ",")))
    local tried = 0
    for _, cd in ipairs(Stats.remoteCandidates()) do
        tried = tried + 1
        local ok, err = Stats.probeRemote(cd.remote, cand, cd)
        if ok then return true end
        Stats.logProbe(cd.tag .. " probe: " .. tostring(err))
        if err and err:find("works", 1, true) then return false, err end    -- the call works; the problem is the value binding, do not spend more points
    end
    if tried == 0 then Stats.logProbe("no stats remote found (Remotes.CommF_ / PlayerGui)") end
    if c.UI_FALLBACK then
        local ok, err = Stats.probeUi(cand)
        if ok then return true end
        return false, err or "ui probe failed"
    end
    return false, "no call shape produced a verified level gain"
end
function Stats.autoProbe()
    local ok, err = Stats.probe()
    if ok then
        Stats.state = "probed"
        UI.status("STATS: remote calibrated by probe")
        return 5
    end
    Stats.probeFails = (Stats.probeFails or 0) + 1
    Stats.lastErr = err
    local wait
    if err and err:find("need at least", 1, true) then wait = 120
    elseif err and err:find("at its cap", 1, true) then wait = 600
    else wait = math.min(1800, 60 * 2 ^ Stats.probeFails) end
    Stats.probeAt = os.time() + wait
    Stats.state = "probe failed"
    UI.status("STATS: probe failed (" .. tostring(err) .. "), retry in " .. wait .. "s")
    return 30
end
-- One-shot diagnosis (env.BloxSM.StatsWhy): prints everything that decides whether stats can work on this account.
function Stats.why()
    local lines = {}
    local function add(s) lines[#lines + 1] = s end
    add("values bound: " .. tostring(Stats.vals ~= nil or Stats.bind()))
    local p, lv = Stats.read()
    add("unspent points: " .. tostring(p) .. "  (probe needs >= " .. tostring(CFG.STATS.PROBE_MIN_POINTS) .. "; 0 means nothing to allocate, not a bug)")
    if lv then for _, nm in ipairs(Stats.NAMES) do add("  " .. nm .. " = " .. tostring(lv[nm])) end end
    local folder = RS:FindFirstChild("Remotes")
    add("Remotes.CommF_: " .. tostring(folder ~= nil and folder:FindFirstChild("CommF_") ~= nil))
    add("StatsFrame remote: " .. tostring(Stats.findRemote() ~= nil))
    add("plus buttons (position map): " .. tostring(Stats.mapByOrder() ~= nil))
    add("driver bound: " .. tostring(Stats.remote ~= nil) .. "  state: " .. tostring(Stats.state) .. "  lastErr: " .. tostring(Stats.lastErr))
    for _, l in ipairs(lines) do print("[BloxSM] " .. l) Log.add("I", "stats why: " .. l) end
end
function Stats.probeNow()
    Task.spawn("stats-probe", function()
        local ok, err = Stats.probe()
        UI.status(ok and "PROBE: calibrated and saved" or ("PROBE failed: " .. tostring(err)))
    end)
end
function Stats.usablePriority(prio)
    local tpl = Stats.tpl
    local out = {}
    for _, p in ipairs(prio) do
        local st = statKey(p.stat)
        local t = Stats.bad[st]
        if t and os.time() - t > 1800 then Stats.bad[st], Stats.zero[st], t = nil, 0, nil end   -- give a dropped stat another chance after 30 min
        local ok = not t
        if ok and tpl and tpl.kind == "ui" then ok = Stats.uiMap ~= nil and Stats.uiMap[st] ~= nil end
        if ok then out[#out + 1] = p end
    end
    return out
end

function Stats.fire(args)
    local r, tpl = Stats.remote, Stats.tpl
    Stats.busy = true
    local ok = pcall(function()
        if tpl.kind == "InvokeServer" then r:InvokeServer(table.unpack(args, 1, tpl.n)) else r:FireServer(table.unpack(args, 1, tpl.n)) end
    end)
    Stats.busy = false
    return ok
end
function Stats.buildArgs(stat, amount)
    local tpl = Stats.tpl
    local name = CFG.STATS.ARG_NAMES[stat] or (tpl.statArg and tpl.statArg[stat]) or Stats.CODE_OF[stat] or stat
    local args = {}
    for i = 1, tpl.n do
        if i == tpl.statSlot then args[i] = name
        elseif i == tpl.amountSlot then args[i] = amount
        else args[i] = tpl.args[i] end
    end
    return args
end
function Stats.sendStat(stat, n, budget)
    local tpl = Stats.tpl
    if tpl.kind == "ui" then                  -- v22 UI driver: click the game's own "+" button (correct args by construction)
        local b = Stats.uiMap and Stats.uiMap[stat]
        if not (b and b.Parent) then return 0 end
        local sent = 0
        for _ = 1, math.min(n, budget) do
            Stats.busy = true
            local fired = Input.click(b)
            Stats.busy = false
            if not fired then break end
            sent = sent + 1
            task.wait(CFG.STATS.SEND_DELAY)
        end
        return sent
    end
    if tpl.amountSlot and Stats.amountOk then
        -- WHY clamp: one huge amount is the first thing a server-side sanity check rejects
        local amt = math.max(1, math.min(n, budget))
        Stats.fire(Stats.buildArgs(stat, amt))
        return amt
    end
    local sent = 0
    for _ = 1, math.min(n, budget) do
        if not Stats.fire(Stats.buildArgs(stat, tpl.amountSlot and 1 or nil)) then break end
        sent = sent + 1
        task.wait(CFG.STATS.SEND_DELAY)
    end
    return sent
end
function Stats.allocate(stat, n, budget)
    local p0, l0 = Stats.read()
    if not p0 then return 0, 0, nil end
    local before = l0[stat] or 0
    Stats.expectUntil = os.time() + CFG.STATS.VERIFY_TIMEOUT + 5
    local sent = Stats.sendStat(stat, n, budget)
    local t0, gained = os.clock(), 0
    repeat
        task.wait(0.25)
        local _, l1 = Stats.read()
        gained = ((l1 and l1[stat]) or before) - before
    until gained >= sent or os.clock() - t0 > CFG.STATS.VERIFY_TIMEOUT
    local p1, l1 = Stats.read()
    if p1 then Stats.remember(p1, l1) end
    if Stats.tpl.amountSlot and Stats.amountOk and sent > 1 and gained == 1 then
        Stats.amountOk = false
        Log.add("W", "stats: the server ignored the amount argument, switching to single-point calls")
    end
    return gained, sent, p0 and p1 and (p0 - p1) or nil
end
function Stats.statusText()
    if Vx.hub == "kaitun" then return "native (kaitun)" end
    if Stats.learnState then return "learning" end
    if not CFG.STATS.ENABLED then return "off" end
    if os.time() < Stats.pausedUntil then return "paused: " .. tostring(Stats.pauseWhy) end
    if not Stats.remote then return "no remote: " .. tostring(Stats.lastErr or "probe pending") end
    return Stats.state
end
function Stats.tick()
    local c = CFG.STATS
    -- v24: Kaitun allocates stats itself; ours must not compete with it (and must not touch the remote before the hub is known)
    if Vx.hub ~= "vxeze" then Stats.state = Vx.hub == "kaitun" and "native (kaitun)" or "waiting for hub" return Vx.hub == "kaitun" and 30 or 5 end
    if Stats.learnState then return Stats.learnTick() end
    if not c.ENABLED then return 30 end
    if not Sess.active or Sess.signaledAt then return 10 end
    if not (Team.done() and hasHRP()) then return 5 end
    if not Stats.vals and not Stats.bind() then
        Stats.bindFails = Stats.bindFails + 1
        Stats.state = "waiting for Data"
        if Stats.bindFails == 12 then Stats.dumpLayout() end
        return math.min(60, 5 * Stats.bindFails)
    end
    Stats.bindFails = 0
    if not (Stats.remote and Stats.remote:IsDescendantOf(game)) then
        Stats.remote = nil
        if not Stats.resolve() then
            if c.AUTO_PROBE and os.time() >= (Stats.probeAt or 0) then return Stats.autoProbe() end
            Stats.state = "waiting for remote"
            return 30
        end
        if c.WATCH_REMOTE and Stats.installHook() then env.BloxStatsHot = true end
    end
    local points, levels = Stats.read()
    if not points then Stats.vals = nil return 5 end
    local why
    if Stats.valueForeign(points, levels) then why = "stat values changed outside this script" end
    local cfgHit, key = Stats.configForeign()
    if cfgHit then why = "config key '" .. tostring(key) .. "' is on" end
    if why then Stats.pause(why, c.PAUSE_FOREIGN) Stats.remember(points, levels) return 30 end
    if os.time() < Stats.pausedUntil then return 10 end
    Stats.pauseWhy = nil
    if not Stats.last then Stats.remember(points, levels) end
    if points <= c.RESERVE then Stats.remember(points, levels) Stats.state = "idle" return 15 end
    -- v22: drop stats that proved unusable BEFORE planning; otherwise a dead stat still swallows the whole point budget
    local plan = Stats.plan(points, levels, Stats.usablePriority(c.PRIORITY), c.RESERVE)
    if #plan == 0 then
        Stats.remember(points, levels)
        if #Stats.plan(points, levels, c.PRIORITY, c.RESERVE) > 0 then
            local bad = {}
            for st in pairs(Stats.bad) do bad[#bad + 1] = st end
            table.sort(bad)
            Stats.state = "no usable stat (dropped: " .. table.concat(bad, ",") .. ")"
            return 300
        end
        Stats.state = "all caps reached"
        return 60
    end
    local budget, anyGain, anyTry = c.BATCH_MAX, false, false
    for _, step in ipairs(plan) do
        if budget <= 0 then break end
        local gained, sent = Stats.allocate(step.stat, step.n, budget)
        budget = budget - ((Stats.tpl.amountSlot and Stats.amountOk) and 1 or sent)
        if sent > 0 then anyTry = true end
        if gained > 0 then anyGain = true Stats.zero[step.stat] = 0
        elseif sent > 0 then
            -- v22: a stat that ignores us twice in a row (wrong inferred code / hidden cap) is dropped instead of poisoning the whole cycle
            Stats.zero[step.stat] = (Stats.zero[step.stat] or 0) + 1
            if Stats.zero[step.stat] >= 2 and not Stats.bad[step.stat] then
                Stats.bad[step.stat] = os.time()
                Log.add("W", "stats: '" .. step.stat .. "' ignored " .. Stats.zero[step.stat] .. " attempts in a row, skipping it (cap reached or wrong code)")
            end
        end
        Log.add("I", string.format("stats: %s +%d sent, +%d confirmed", step.stat, sent, gained))
        if os.time() < Stats.pausedUntil then break end
    end
    if anyGain then Stats.fails, Stats.state = 0, "ok"
    elseif anyTry then
        Stats.fails = Stats.fails + 1
        Stats.state = "no effect x" .. Stats.fails
        if Stats.fails >= 5 then
            -- WHY: a template that stopped working (game update, stale file) must not be trusted for 30 minutes: forget it and re-probe
            FS.delete(CFG.STATS.REMOTE_FILE)
            Stats.remote, Stats.tpl, Stats.probeAt = nil, nil, 0
            Stats.pause("remote has no effect, re-probing", 120)
            WH.send("report", "Stats allocation has no effect", "Account " .. LP.Name .. ": 5 attempts changed nothing", 15158332, 2)
            Stats.fails = 0
        end
        return math.min(90, 5 * 2 ^ Stats.fails)
    end
    return 5
end

----------------------------------------------------------------
-- 15. DASHBOARD
----------------------------------------------------------------
UI.last, UI.text = "Booting...", ""
function UI.status(t)
    if t ~= UI.last then UI.last = t Log.add("I", t) end
end
function UI.build()
    local gui = Instance.new("ScreenGui")
    gui.Name, gui.ResetOnSpawn, gui.DisplayOrder = "BloxFactoryUI", false, 999

    -- Frame utama (Diperbesar dari 250x96 jadi 340x160)
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 340, 0, 160)
    frame.Position = UDim2.new(0, 15, 0, 30)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0

    -- Ujung melengkung
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    -- Garis pinggir (Stroke) warna neon
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(0, 255, 170) -- Warna Cyan/Neon Green
    stroke.Thickness = 1.5
    stroke.Transparency = 0.2

    -- Top Bar (Header)
    local topBar = Instance.new("Frame", frame)
    topBar.Size = UDim2.new(1, 0, 0, 30)
    topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    topBar.BorderSizePixel = 0
    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)

    -- Penutup ujung bawah topbar biar rata
    local topFix = Instance.new("Frame", topBar)
    topFix.Size = UDim2.new(1, 0, 0, 10)
    topFix.Position = UDim2.new(0, 0, 1, -10)
    topFix.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    topFix.BorderSizePixel = 0

    -- Judul di Top Bar
    local title = Instance.new("TextLabel", topBar)
    title.Size = UDim2.new(1, -20, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "BloxFactory " .. CFG.VERSION .. " | " .. LP.Name
    title.TextColor3 = Color3.fromRGB(0, 255, 170)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left

    -- Text Utama (Status)
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -20, 1, -60)
    lbl.Position = UDim2.new(0, 10, 0, 35)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Top
    lbl.TextWrapped = true

    -- Tombol START (Lebih gede & ada animasi hover)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 1, -45)
    btn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    btn.Text = "▶ START SESSION"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.Visible = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    -- Efek tombol pas disentuh
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(0, 220, 120) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(0, 180, 100) end)
    btn.MouseButton1Click:Connect(function() Sess.start() end)

    pcall(function() local old = PG:FindFirstChild("BloxFactoryUI") if old then old:Destroy() end gui.Parent = PG end)
    UI.gui, UI.lbl, UI.btn = gui, lbl, btn
end
function UI.showButton(show) if UI.btn then UI.btn.Visible = show end end

function Watch.health()
    local issues = {}
    if Group.ready and not Group.lockOk then issues[#issues + 1] = "NO LOCK" end
    if Group.lost then issues[#issues + 1] = "LOCK LOST" end
    if Vx.failed then issues[#issues + 1] = "HUB FAILED" end
    if Dead.reason then issues[#issues + 1] = "DEAD" end
    if WH.pending() > 20 then issues[#issues + 1] = "WEBHOOK BACKLOG" end
    for name, t in pairs(S.beats) do
        if os.clock() - t > CFG.STALL_AFTER then issues[#issues + 1] = "STALL:" .. name end
    end
    return #issues == 0 and "OK" or table.concat(issues, ", ")
end
local function mins(sec) return math.max(0, math.ceil(sec / 60)) end
function UI.render()
    if not UI.lbl then return 3 end
    local now = os.time()
    local sessLeft = Sess.active and mins(Sess.endAt - now) or 0
    local roll = mins(math.max(Store.data.lastRoll + CFG.ROLL_INTERVAL, Gacha.retryAt) - now)

    -- Nambahin enter (\\n) biar teksnya renggang
    local txt = string.format("%s | %s | %s | Lv %s\n\nSession: %dm left | Next roll: %dm\nFarm: %s | Stats: %s\nWH Queue: %d | Health: %s\n\nStatus: %s",
        CFG.VERSION, Group.id or "Group?", (Vx.hub or "?") .. "/" .. (Vx.mode or "?"), tostring(Vx.level or "?"), sessLeft, roll,
        Farm.stopped and "stopped" or "running", Stats.statusText(), WH.pending(), Watch.health(), UI.last)

    if txt ~= UI.text then UI.text = txt UI.lbl.Text = txt end
    return 2
end
function Watch.statusFile()
    if not Group.ready then return 15 end
    FS.writeJSON("Status_" .. Group.id .. "_" .. UID .. ".json", {
        name = LP.Name, state = Sess.state, group = Group.id, mode = Vx.mode, hub = Vx.hub, level = Vx.level, sessionEnd = Sess.endAt,
        nextRoll = Store.data.lastRoll + CFG.ROLL_INTERVAL, signaled = Sess.signaledAt, health = Watch.health(), ts = os.time() })
    return 15
end

----------------------------------------------------------------
-- 16. WATCHDOG
----------------------------------------------------------------
Watch.warned = {}
function Watch.tick()
    for name, t in pairs(S.beats) do
        local age = os.clock() - t
        if age > CFG.STALL_AFTER and not Watch.warned[name] then
            Watch.warned[name] = true
            Log.add("E", "service '" .. name .. "' has not reported for " .. math.floor(age) .. "s")
        elseif age <= CFG.STALL_AFTER then Watch.warned[name] = nil end
    end
    Log.flush()
    Store.save()
    return 15
end

----------------------------------------------------------------
-- 17. BOOT
----------------------------------------------------------------
local function Unload()
    if not S.alive then return end
    S.alive = false
    Group.release()
    env.BloxStatsHot, env.BloxStatsSpy = false, nil
    pcall(Weapon.restore)
    Log.add("I", "unloading")
    Log.flush() Store.save(true) WH.saveOutbox()
    for _, c in ipairs(S.conns) do pcall(function() c:Disconnect() end) end
    pcall(function() UI.gui:Destroy() end)
    if CFG.RENDER_OFF then pcall(function() RunService:Set3dRenderingEnabled(true) end) end
end

env.BloxSM = {
    Version = CFG.VERSION, Unload = Unload, Start = Sess.start, Stop = Sess.stop,
    ResetSession = function() FS.delete(Sess.filePath()) Log.add("I", "session file deleted") end,
    Status = function() print(UI.text) return UI.text end,
    StatsLearn = Stats.learn,
    StatsProbe = Stats.probeNow,
    StatsUiDump = Stats.dumpUi,
    DmgProbe = function() Dmg.startProbe() end,
    GuardNow = function() return Vx.enforceAll() end,
    StatsHookTest = function() Task.spawn("stats-hooktest", Stats.hookTest) end,
    StatsDump = function() Stats.dumped = false Stats.dumpLayout() end,
    StatsWhy = function() Task.spawn("stats-why", Stats.why) end,
    CodesRun = function() Codes.rerun() end,
    Hub = function() print(string.format("[BloxSM] hub=%s (%s) mode=%s level=%s url=%s", tostring(Vx.hub), tostring(Vx.hubWhy), tostring(Vx.mode), tostring(Vx.level), tostring(Vx.hub and Vx.url()))) end,
    WeaponStatus = function() print("[BloxSM] weapon guard: " .. Weapon.statusText()) end,
    WeaponRestore = function() print("[BloxSM] weapon guard: restored " .. Weapon.restore() .. " tool(s)") end,
    RespawnStatus = function()
        print(string.format("[BloxSM] respawn: pending=%s rung=%d hadFarm=%s storm=%s spawns(3m)=%d reloads=%d/%d",
            tostring(Resp.pending), Resp.stage, tostring(Resp.hadFarm), tostring(Resp.storm), #Resp.spawns, Vx.sessReloads or 0, CFG.RESPAWN.MAX_RELOADS))
    end,
    CodesForget = function() Store.set("codes", {}) Log.add("I", "redeemed-codes memory cleared") end,
    StatsPlan = function()
        local p, lv = Stats.read()
        if not p and Stats.bind() then p, lv = Stats.read() end
        if not p then print("[BloxSM] stats values not found") return end
        local plan, left = Stats.plan(p, lv, CFG.STATS.PRIORITY, CFG.STATS.RESERVE)
        for _, s in ipairs(plan) do print("[BloxSM] plan: " .. s.stat .. " +" .. s.n) end
        print("[BloxSM] points " .. p .. ", unspent after plan " .. left)
    end,
}

UI.build()
Store.load()
WH.loadOutbox()
Group.changeHooks[#Group.changeHooks + 1] = Sess.migrate
Log.add("I", CFG.VERSION .. " booting for " .. LP.Name)

if CFG.RENDER_OFF then
    pcall(function() RunService:Set3dRenderingEnabled(false) end)
    pcall(function() if setfpscap then setfpscap(CFG.FPS_CAP) end end)
    pcall(function() settings().Rendering.QualityLevel = 1 end)
end
S.conns[#S.conns + 1] = LP.CharacterAdded:Connect(function() pcall(Resp.onSpawn) end)
S.conns[#S.conns + 1] = LP.Idled:Connect(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end)
if CFG.DEAD_ON_ERROR then
    S.conns[#S.conns + 1] = GuiService.ErrorMessageChanged:Connect(function()
        local m = GuiService:GetErrorMessage()
        if m and m ~= "" then Dead.mark("error prompt: " .. m) end
    end)
end

Group.acquire()
Noti.boot()
if CFG.DMG.ENABLED then
    pcall(function() S.conns[#S.conns + 1] = game.DescendantAdded:Connect(Dmg.onAdded) end)
    Task.spawn("dmg-templates", Dmg.disableTemplates)
end
Vx.boot()
Task.service("team", 1, Team.tick)
Task.service("group-lock", CFG.LOCK_REFRESH, function() Group.refresh() end)
for target in pairs(WH.queues) do Task.service("webhook-" .. target, 1, function() return WH.pump(target) end) end
Task.service("webhook-adopt", 60, function() WH.adopt() end)
Task.service("session-guard", 3, Sess.guard)
Task.service("dead-watch", 10, Dead.watch)
Task.service("farm", 3, Farm.tick)
Task.service("hub-watch", 15, Farm.hubWatch)
Task.service("farm-verify", CFG.IDLE.CHECK, Farm.verify)
Task.service("respawn", 3, Resp.tick)
Task.service("cfg-drift", 10, Vx.driftTick)
Task.service("hub-level", 30, Vx.levelWatch)
Task.service("swap", 5, Swap.tick)
Task.service("weapon-guard", CFG.KAITUN.GUARD.CHECK, Weapon.tick)
Task.service("gacha", 3, Gacha.tick)
Task.service("sea-guard", 10, Sea.tick)
Task.service("dmg", 1, Dmg.tick)
Task.service("stats", 5, Stats.tick)
Task.service("codes", 5, Codes.tick)
Task.service("ui", 2, UI.render)
Task.service("status-file", 15, Watch.statusFile)
Task.service("watchdog", 15, Watch.tick)

Task.spawn("session-boot", function()
    local t0 = os.clock()
    while S.alive and not hasHRP() and os.clock() - t0 < CFG.START_MAX_WAIT do task.wait(1) end
    task.wait(5)
    local g0 = os.clock()
    while S.alive and not Group.ready and os.clock() - g0 < CFG.GROUP_WAIT_MAX do task.wait(0.5) end
    if S.alive then Sess.start() end
end)
