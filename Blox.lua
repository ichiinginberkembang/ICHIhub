Config =
        Config or
        {
            Team = "Pirates",
            Configuration = {
                HideallPath = false,
                blackscreen = false,
                HideGui = false,
                HopWhenIdle = true,
                AutoHop = true,
                AutoHopDelay = 60 * 60,
                FpsBoost = true,
                ["IdleCheck"] = 150, -- every (x) seconds if not moving rejoin
            },
            Items = {
                -- Melees
                -- [FIX-27] TAM TAT cong tac cha: MeleesController.Refresh tra ve
                -- dung gia tri nay, va GodHumanFlag chi duoc bat tu Start cua no,
                -- nen false = khong con mua/nang cap melee, khong con farm
                -- Godhuman vo tan. Muon bat lai: doi false thanh true.
                -- [FIX-46] DA BAT LAI (user hoi "sao chi co farm ko vay ko co
                -- nhan vay"). Lenh thoat Godhuman vo tan cua [FIX-26] van con:
                -- khong doc duoc vat lieu thi tu tat flag + nghi 300s, khong
                -- farm vo tan nhu truoc day nua.
                AutoFullyMelees = true,
                -- Swords
                Saber = true,
                CursedDualKatana = false,
                -- Guns
                SoulGuitar = false,
                -- Upgrades

                RaceV2 = false,
                AutoFarmFruitMastery = false,
                AutoEatFruit = 1,
                Eatlist = {}
            },
            Settings = {
                StayInSea2UntilHaveDarkFragments = false, -- bat cai nay se hop tim darkbeard / turn this on to force hop for darkbeard ( for sg )
                ["Fragments"] = 5000 -- Auto farm fragments until you have 5000 fragments to buy the chip
            }
}
repeat
    task.wait(0.5)
until game:IsLoaded()

-- Volt Performance Optimization Setup
local Volt = nil
pcall(function()
    -- Try to load Volt if available
    if typeof(volt) == "table" then
        Volt = volt
        print("[Volt] Volt detected and loaded")
    elseif typeof(getgenv().volt) == "table" then
        Volt = getgenv().volt
        print("[Volt] Volt detected from getgenv()")
    end
end)

-- Performance optimization flags
local UseVoltActors = Volt ~= nil
local PerformanceCache = {}
-- task.spawn(function()
--     while true do
--         setfpscap(7)
--         task.wait(10)
--     end
-- end)

function CheckKick(v)
    if v.Name == 'ErrorPrompt' then
        task.wait(2)
        print(v.TitleFrame.ErrorTitle.Text)
        game:GetService("ReplicatedStorage"):WaitForChild("__ServerBrowser"):InvokeServer( "teleport",game.PlaceId)
        v:Destroy()
    end
end
-- print restored
repeat
    task.wait() 
    game.ReplicatedStorage.Remotes.CommF_:InvokeServer('SetTeam', 'Pirates')
until game.Players.LocalPlayer.Character
game:GetService('CoreGui').RobloxPromptGui.promptOverlay.ChildAdded:Connect(CheckKick)
    if os.time() >= 1756319996 then
    --  while true do end
    end
    
        local checkdone = false


    local LogService = game:GetService("LogService")
    local GameName = "Blox Fruit"

    pcall(
        function()
            GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
        end
    )
   -- -- print restored
    local StartTime = os.time()

    local Traces = {}

    function Build(Error)
        warn("Error\n\n", Error, "\n\n")
        local Result = {
            content = "<@12313> " .. tostring(Error) or " " .. tostring(LocalPlayer) or "",
            embeds = {
                {
                    title = GameName,
                    description = game.PlaceId .. " | " .. game.JobId,
                    color = 15642286,
                    fields = {
                        {
                            name = "Error Details",
                            value = Error
                        },
                        {
                            name = "Player Info",
                            value = "Level: " .. tostring((ScriptStorage and ScriptStorage.PlayerData and ScriptStorage.PlayerData.Level) or "n/a")
                        },
                        {
                            name = "Script Details",
                            value = GetCurrentDateTime() ..
                                " | " ..
                                    DispTime(os.time() - StartTime, true) ..
                                        " after execution\nMain task: " ..
                                            (ScriptStorage.Task.MainTask or "n/a") ..
                                                " ( " ..
                                                    (ScriptStorage.Task["MainTask-d"] and
                                                        DispTime(os.time() - ScriptStorage.Task["MainTask-d"], true) or
                                                        "n/a") ..
                                                        " ) \nSub task: " ..
                                                            (ScriptStorage.Task.SubTask or "n/a") ..
                                                                " ( " ..
                                                                    (ScriptStorage.Task["SubTask-d"] and
                                                                        DispTime(
                                                                            os.time() - ScriptStorage.Task["SubTask-d"],
                                                                            true
                                                                        ) or
                                                                        "n/a") ..
                                                                        " )"
                        },
                        {
                            name = "Traceback",
                            value = (function()
                                local Result = ""

                                for Index, Content in ScriptStorage.Tracebacks do
                                    if #ScriptStorage.Tracebacks > 20 then
                                        break
                                    end

                                    Result = Result .. (Content or "null") .. "\n"
                                end

                                return Result ~= "" and Result or "... ( empty list ) "
                            end)()
                        }
                    },
                    author = {
                        name = tostring(LocalPlayer)
                    }
                }
            },
            attachments = {}
        }

        for Index, Value in Result.embeds[1].fields do
            Value.value = "```" .. Value.value .. "```"
        end
        return Result
    end

    function Report(Message)
        -- [FIX-A] Truoc day ham nay RONG (webhook bi tat) nen moi loi cua ca script bi
        -- nuot: xpcall o cuoi file bat loi roi dua vao day -> khong in gi ra console.
        print("[ERROR]", Message)
    end

    function mmb()
    print("[BUILD-63]")
        local Orders = {"Task1", "Task2", "Currencies", "Melees", "LiveTime", "DebugLine"}
        local Interface = {
            Instances = {}
        }

        local isVisible = true
        local isToggleOpen = false
        local player = game.Players.LocalPlayer

        repeat
            task.wait()
        until game.CoreGui

        -- [FIX-11] PO tu sanglove-sea1.lua:249-272: chon cha cho ScreenGui sao cho
        -- nut an hien bam duoc tren moi executor.
        local getGuiParent = function()
            if typeof(gethui) == "function" then
                local ok, h = pcall(gethui)
                if ok and h then return h end
            end
            local okCg, cg = pcall(function() return game:GetService("CoreGui") end)
            if okCg and cg then
                local okWrite = pcall(function()
                    local t = Instance.new("Folder")
                    t.Parent = cg
                    t:Destroy()
                end)
                if okWrite then return cg end
            end
            local pg = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui", 5)
            return pg or cg
        end

        local parentGui = getGuiParent()
        print("[FIX-11] GUI parent = " .. tostring(parentGui and parentGui.ClassName))
        pcall(function()
            local old = parentGui:FindFirstChild("CyndralDev")
            if old then old:Destroy() end
        end)

        local HopGui = Instance.new("ScreenGui")
        local NameHub = Instance.new("TextLabel")
        local UIStroke = Instance.new("UIStroke")
        local StrokeBounty = Instance.new("UIStroke")
        local Bounty = Instance.new("TextLabel")
        local ToggleButton = Instance.new("ImageButton")
        local ToggleContainer = Instance.new("Frame")
        local ToggleUIStroke = Instance.new("UIStroke")
        local ToggleIcon = Instance.new("TextLabel")

        -- Create a table to store UI references for blurring
        local UIReferences = {}

        HopGui.Name = "CyndralDev"
        -- [FIX-11] PO tu sanglove-sea1.lua:249-272. Executor nay cho thread chinh tao
        -- Instance trong CoreGui nhung tu choi thread xu ly click doc no, nen nut an
        -- hien chi sang chu khong bam duoc. Thu lan luot gethui -> CoreGui (co write-test)
        -- -> PlayerGui. ResetOnSpawn=false de chet cung khong mat HUD.
        HopGui.ResetOnSpawn = false
        HopGui.Parent = parentGui
        HopGui.Enabled = not Config.Configuration.HideGui
        HopGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        HopGui.IgnoreGuiInset = true

        NameHub.Name = "NameHub"
        NameHub.Parent = HopGui
        NameHub.AnchorPoint = Vector2.new(0.5, 0.5)
        NameHub.Position = UDim2.new(0.5, 0, 0.3, 0)
        NameHub.Size = UDim2.new(1, 0, 0, 80)
        NameHub.BackgroundTransparency = 0.999
        NameHub.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        NameHub.BorderColor3 = Color3.fromRGB(0, 0, 0)
        NameHub.BorderSizePixel = 0
        NameHub.Font = Enum.Font.FredokaOne
        NameHub.Text = "sanglove v1.1"

        local UIStroke = Instance.new("UIStroke")
        UIStroke.Parent = NameHub
        UIStroke.Color = Color3.fromRGB(0, 0, 0)
        UIStroke.Thickness = 1

        NameHub.TextColor3 = Color3.fromRGB(9, 255, 248)
        NameHub.TextSize = 50

        -- Create Toggle Button Container
        ToggleContainer.Name = "ToggleContainer"
        ToggleContainer.Parent = HopGui
        ToggleContainer.AnchorPoint = Vector2.new(1, 0)
        ToggleContainer.Position = UDim2.new(1, -20, 0, 20)
        ToggleContainer.Size = UDim2.new(0, 50, 0, 50)
        ToggleContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        ToggleContainer.BackgroundTransparency = 0.2
        ToggleContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ToggleContainer.BorderSizePixel = 0
        ToggleContainer.ClipsDescendants = true
        -- Make it circular
        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(1, 0)
        UICorner.Parent = ToggleContainer

        -- Add stroke to toggle container
        ToggleUIStroke.Parent = ToggleContainer
        ToggleUIStroke.Color = Color3.fromRGB(9, 255, 248)
        ToggleUIStroke.Thickness = 2

        -- Create Toggle Button
        ToggleButton.Name = "ToggleButton"
        ToggleButton.Parent = ToggleContainer
        ToggleButton.AnchorPoint = Vector2.new(0.5, 0.5)
        ToggleButton.Position = UDim2.new(0.5, 0, 0.5, 0)
        ToggleButton.Size = UDim2.new(1, 0, 1, 0)
        ToggleButton.BackgroundTransparency = 1
        ToggleButton.BorderSizePixel = 0

        -- Add toggle icon
        ToggleIcon.Name = "ToggleIcon"
        ToggleIcon.Parent = ToggleContainer
        ToggleIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        ToggleIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
        ToggleIcon.Size = UDim2.new(0.7, 0, 0.7, 0)
        ToggleIcon.BackgroundTransparency = 1
        ToggleIcon.BorderSizePixel = 0
        ToggleIcon.Font = Enum.Font.GothamBold
        ToggleIcon.Text = "👁️"
        ToggleIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleIcon.TextSize = 24
        ToggleIcon.TextScaled = true

        local function createTextLabel(text, position, isImage)
            local StrokeBounty = Instance.new("UIStroke")
            local Bounty = Instance.new("TextLabel")
            Bounty.Name = "hmph ><"
            Bounty.Parent = HopGui
            Bounty.AnchorPoint = Vector2.new(0.5, 0.5)
            Bounty.Position = position
            Bounty.Size = UDim2.new(0, 200, 0, 30)
            Bounty.BackgroundTransparency = 0.999
            Bounty.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Bounty.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Bounty.BorderSizePixel = 0
            Bounty.Font = Enum.Font.FredokaOne
            Bounty.Text = text
            Bounty.TextColor3 = Color3.fromRGB(255, 255, 255)
            Bounty.TextSize = 13
            Bounty.RichText = true
            StrokeBounty.Parent = Bounty
            StrokeBounty.Color = Color3.fromRGB(0, 0, 0)
            StrokeBounty.Thickness = 1

            return Bounty
        end

        MainTextLabel = createTextLabel(" ", UDim2.new(0.5, 0, 0.4, 0))

        Interface.Instances.MainTextLabel = MainTextLabel

        for Index, OrderName in pairs(Orders) do
            Interface.Instances[OrderName] = createTextLabel("...", UDim2.new(0.5, 0, 0.45 + (.05 * Index), 0))
        end

        -- Custom blur effect that can blur other UIs
        local BlurManager = {}

        function BlurManager:Create()
            -- Create a new transparent frame that covers the screen
            local blurFrame = Instance.new("Frame")
            blurFrame.Name = "BlurFrame"
            blurFrame.Parent = HopGui
            blurFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            blurFrame.BackgroundTransparency = 1 -- Start fully transparent
            blurFrame.BorderSizePixel = 0
            blurFrame.Size = UDim2.new(1, 0, 1, 0)
            blurFrame.Position = UDim2.new(0, 0, 0, 0)
            blurFrame.ZIndex = 0 -- Behind everything

            -- Store the reference
            self.blurFrame = blurFrame
            self.blurIntensity = 0

            return self
        end

        function BlurManager:SetIntensity(intensity)
            -- Clamp intensity between 0 and 0.95 (0.95 is nearly opaque)
            intensity = math.clamp(intensity, 0, 0.95)
            self.blurIntensity = intensity

            -- Apply the intensity to our blur frame
            local tweenService = game:GetService("TweenService")
            local tweenInfo =
                TweenInfo.new(
                0.3, -- Time
                Enum.EasingStyle.Cubic, -- Easing style
                Enum.EasingDirection.Out -- Easing direction
            )

            local tween =
                tweenService:Create(
                self.blurFrame,
                tweenInfo,
                {
                    BackgroundTransparency = 1 - intensity
                }
            )

            tween:Play()

            -- Also apply the actual blur effect in lighting
            if not self.blurEffect then
                self.blurEffect = Instance.new("BlurEffect")
                self.blurEffect.Name = "CustomBlur"
                self.blurEffect.Parent = game.Lighting
                self.blurEffect.Enabled = true
            end

            local blurSizeTween =
                tweenService:Create(
                self.blurEffect,
                tweenInfo,
                {
                    Size = intensity * 30 -- Max blur size is 30
                }
            )

            blurSizeTween:Play()

            -- Apply blur to registered UI elements
            for _, uiElement in pairs(UIReferences) do
                if uiElement and uiElement.Parent then
                    local uiTween =
                        tweenService:Create(
                        uiElement,
                        tweenInfo,
                        {
                            BackgroundTransparency = uiElement._originalTransparency + (intensity * 0.5)
                        }
                    )
                    uiTween:Play()
                end
            end
        end

        function BlurManager:RegisterUI(uiElement)
            if uiElement and uiElement:IsA("GuiObject") then
                -- Store the original transparency
                uiElement._originalTransparency = uiElement.BackgroundTransparency
                table.insert(UIReferences, uiElement)
            end
        end

        -- Create our blur manager
        local blurEffect = BlurManager:Create()

        -- Improved Text Transition Animation
        function SetText(Name, Text)
            task.spawn(
                function()
                    local TextIns = Interface.Instances[Name]
                    if not TextIns then
                        return
                    end

                    if not isVisible then
                        TextIns.Text = Text
                        return
                    end

                    if TextIns.Text == Text then
                        return
                    end

                    -- Fade out with smoother animation
                    local tweenService = game:GetService("TweenService")
                    local fadeOutInfo =
                        TweenInfo.new(
                        0.3, -- Time
                        Enum.EasingStyle.Quad, -- Easing style
                        Enum.EasingDirection.Out -- Easing direction
                    )

                    local fadeOut =
                        tweenService:Create(
                        TextIns,
                        fadeOutInfo,
                        {
                            TextTransparency = 1,
                            TextStrokeTransparency = 1
                        }
                    )

                    fadeOut:Play()
                    fadeOut.Completed:Wait()

                    -- Change text while invisible
                    TextIns.Text = Text

                    -- Fade in with smoother animation
                    local fadeInInfo =
                        TweenInfo.new(
                        0.3, -- Time
                        Enum.EasingStyle.Quad, -- Easing style
                        Enum.EasingDirection.Out -- Easing direction
                    )

                    local fadeIn =
                        tweenService:Create(
                        TextIns,
                        fadeInInfo,
                        {
                            TextTransparency = 0,
                            TextStrokeTransparency = 0
                        }
                    )

                    fadeIn:Play()
                end
            )
        end

        local OldExposureCompensation = game:GetService("Lighting").ExposureCompensation
        -- Enhanced toggle function with improved animations
        function ToggleUI(State)
            isToggleOpen = State or not isToggleOpen

            -- game:GetService("Lighting").ExposureCompensation = State and -math.huge or OldExposureCompensation

            local contentLabels = {NameHub, MainTextLabel}
            for _, instance in pairs(Interface.Instances) do
                table.insert(contentLabels, instance)
            end

            local tweenService = game:GetService("TweenService")
            local tweenInfo =
                TweenInfo.new(
                0.5, -- Time
                Enum.EasingStyle.Quart, -- Easing style
                Enum.EasingDirection.InOut -- Easing direction
            )

            if isToggleOpen then
                -- Show UI
                ToggleIcon.Text = "🔍"

                -- Fancy rotation animation for toggle button
                local rotationTween =
                    tweenService:Create(
                    ToggleIcon,
                    TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                    {Rotation = 360}
                )
                rotationTween:Play()
                rotationTween.Completed:Connect(
                    function()
                        ToggleIcon.Rotation = 0
                    end
                )

                -- Animate all elements in
                for _, label in pairs(contentLabels) do
                    label.TextTransparency = 1

                    local tween =
                        tweenService:Create(
                        label,
                        tweenInfo,
                        {
                            TextTransparency = 0
                        }
                    )

                    if label:FindFirstChildOfClass("UIStroke") then
                        label:FindFirstChildOfClass("UIStroke").Transparency = 1

                        local strokeTween =
                            tweenService:Create(
                            label:FindFirstChildOfClass("UIStroke"),
                            tweenInfo,
                            {
                                Transparency = 0
                            }
                        )

                        strokeTween:Play()
                    end

                    tween:Play()
                end

                -- Apply blur effect
                blurEffect:SetIntensity(0.4) -- 40% blur intensity
            else
                -- Hide UI
                ToggleIcon.Text = "🔍"

                -- Fancy shrink animation for toggle button
                local shrinkTween =
                    tweenService:Create(
                    ToggleIcon,
                    TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
                    {Size = UDim2.new(0.3, 0, 0.3, 0)}
                )
                shrinkTween:Play()
                shrinkTween.Completed:Connect(
                    function()
                        local growTween =
                            tweenService:Create(
                            ToggleIcon,
                            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                            {Size = UDim2.new(0.7, 0, 0.7, 0)}
                        )
                        growTween:Play()
                    end
                )

                -- Animate all elements out
                for _, label in pairs(contentLabels) do
                    local tween =
                        tweenService:Create(
                        label,
                        tweenInfo,
                        {
                            TextTransparency = 1
                        }
                    )

                    if label:FindFirstChildOfClass("UIStroke") then
                        local strokeTween =
                            tweenService:Create(
                            label:FindFirstChildOfClass("UIStroke"),
                            tweenInfo,
                            {
                                Transparency = 1
                            }
                        )

                        strokeTween:Play()
                    end

                    tween:Play()
                end

                -- Remove blur effect
                blurEffect:SetIntensity(0) -- 0% blur intensity
            end

            isVisible = isToggleOpen
        end

        -- Function to register an external UI for blurring
        function Interface.RegisterForBlur(uiElement)
            blurEffect:RegisterUI(uiElement)
        end

        -- Configure toggle button click event
        ToggleButton.MouseButton1Click:Connect(
            function()
                ToggleUI()
            end
        )

        -- Add pulse animation to toggle button on hover
        ToggleButton.MouseEnter:Connect(
            function()
                local tweenService = game:GetService("TweenService")

                -- Pulse animation
                local pulseSequence = function()
                    local expandTween =
                        tweenService:Create(
                        ToggleContainer,
                        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {Size = UDim2.new(0, 55, 0, 55)}
                    )

                    local glowTween =
                        tweenService:Create(
                        ToggleUIStroke,
                        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {Color = Color3.fromRGB(0, 255, 255), Thickness = 3}
                    )

                    expandTween:Play()
                    glowTween:Play()
                end

                pulseSequence()
            end
        )

        ToggleButton.MouseLeave:Connect(
            function()
                local tweenService = game:GetService("TweenService")
                local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

                local shrinkTween =
                    tweenService:Create(
                    ToggleContainer,
                    tweenInfo,
                    {
                        Size = UDim2.new(0, 50, 0, 50)
                    }
                )

                local strokeTween =
                    tweenService:Create(
                    ToggleUIStroke,
                    tweenInfo,
                    {
                        Color = Color3.fromRGB(9, 255, 248),
                        Thickness = 2
                    }
                )

                shrinkTween:Play()
                strokeTween:Play()
            end
        )

        -- Original toggle interface function (for backward compatibility)
        function Interface.ToggleInterface(State)
            isToggleOpen = State

            local tweenService = game:GetService("TweenService")
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

            if State then
                HopGui.Enabled = true
                ToggleIcon.Text = "👁️"
                blurEffect:SetIntensity(0.4) -- 40% blur intensity
            else
                ToggleIcon.Text = "🔍"
                blurEffect:SetIntensity(0) -- 0% blur intensity
            end

            isVisible = State
        end

        -- Add a floating animation to the toggle button
        local function setupFloatingAnimation()
        end

        setupFloatingAnimation()

        ToggleUI(true)
        -- Export the SetText function and other functions
        Interface.SetText = SetText
        Interface.ToggleUI = ToggleUI
        Interface.BlurManager = blurEffect

        getgenv().alert = function(t1, t2)
            pcall(function() print("[Alert]", tostring(t1), tostring(t2)) end)
        end

        pcall(function()
            if not isfile("fluent.lua") then
                pcall(function()
                    writefile(
                        "fluent.lua",
                        game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua")
                    )
                end)
            end

            if isfile("fluent.lua") then
                local content = readfile("fluent.lua")
                if content and #content > 0 then
                    local okLoad, fluentLib = pcall(function() return loadstring(content)() end)
                    if okLoad and fluentLib then
                        local Fluent = fluentLib
                        getgenv().alert = function(t1, t2)
                            pcall(function()
                                Fluent:Notify({
                                    Title = t1 or "",
                                    Content = t2 or "",
                                    Duration = 5
                                })
                            end)
                        end
                    end
                end
            end
        end)
        alert("Cyndral", "Endpoint reached")

        local CDN_HOST = ""

        StartTime = os.time()

        OldSessionTime =
            isfile(".tdif-" .. game.Players.LocalPlayer.Name) and
            tonumber(readfile(".tdif-" .. game.Players.LocalPlayer.Name)) or
            0

           
        if Config.Configuration.blackscreen then 
        game:GetService("Lighting").ExposureCompensation = -math.huge
        end
        repeat
            wait()
        until game.Players.LocalPlayer.Character
        spawn(
            function()
                if true then return end
                game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("NewIslandLOD", 9999):Destroy()
                game:GetService("Players")
                LocalPlayer.PlayerScripts:WaitForChild("IslandLOD", 9999):Destroy()
            end
        )
        alert("wait 1", "ok")
        
        local Segmants = {
            "RawConstants",
            "Utilly",
            "QuestManager",
            "SpawnRegionLoader",
            "TweenController",
            "AttackController",
            "CombatController",
            "FunctionsHandler",
            "Hooks",
            "Debug",
            "Hop",
            "Storage"
        }

        -- Interface.ToggleDarkScreen(Config.Utilly.BlackScreen)

        StartTick = tick()
        repeat
            task.wait()
        until SetText
        alert("load 2")
        SetText("MainTextLabel", "Initalizing Script...")
        

        local FolderPath = "Rua_Hub/Blox_Fruit/Assets/"

        
        -- Safe Rejoin / Server Hop Helper (replaces raw Kick calls)
        local function SafeRejoinOrHop(reason)
            print("[Auto Rejoin/Hop] Triggered: " .. tostring(reason or "Stuck/Idle/Desync"))
            pcall(function()
                if typeof(Hop) == "function" then
                    Hop(reason or "SafeRejoin")
                else
                    local ts = game:GetService("TeleportService")
                    local lp = game:GetService("Players").LocalPlayer
                    ts:Teleport(game.PlaceId, lp)
                end
            end)
        end

ScriptStorage = {
            IsInitalized = false,
            PlayerData = {},
            Melees = {},
            CurrentMeleeData = {},
            Enemies = {},
            Tools = {},
            Backpack = {},
            IgnoreStoreFruits = {},
            Connections = {
                LocalPlayer = {}
            },
            Task = {},
            Tracebacks = {},
            TaskController = {},
            TracebackUpdater = {},
            Interface = Interface,
            NPCs = {}
        }
        -- [FIX-0] hookfunction/newcclosure la ham rieng cua executor. Thieu 1 trong 2
        -- la script chet ngay tai day, truoc khi kip in ra bat ky dau vet nao.
        pcall(
            function()
                if typeof(hookfunction) == "function" and typeof(newcclosure) == "function" then
                    hookfunction(require(game.ReplicatedStorage.Reparent).Unparent, newcclosure(function()
                        return function(...) end
                    end))
                else
                    print("[FIX-0] Executor khong co hookfunction/newcclosure -> bo qua hook Reparent")
                end
            end
        )
        Players = game.Players
        LocalPlayer = Players.LocalPlayer
        Character = LocalPlayer.Character

        Humanoid = Character:WaitForChild("Humanoid")
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

        PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
        Lighting = game:GetService("Lighting")

        Services = {}

        setmetatable(
            Services,
            {
                __index = function(_, Index)
                    return game:GetService(Index)
                end
            }
        )

        setmetatable(
            ScriptStorage.Enemies,
            {
                __index = function(_, Index)
                    return Services.Workspace.Enemies:FindFirstChild(Index) or
                        Services.ReplicatedStorage:FindFirstChild(Index)
                end
            }
        )

        setmetatable(
            ScriptStorage.Tools,
            {
                __index = function(Self, Index)
                    return LocalPlayer.Character:FindFirstChild(Index) or LocalPlayer.Backpack:FindFirstChild(Index)
                end
            }
        )

        setmetatable(
            ScriptStorage.NPCs,
            {
                __index = function(_, Index)
                    if not Index then return end 
                    return workspace.NPCs:FindFirstChild(Index) or game.ReplicatedStorage.NPCs:FindFirstChild(Index)
                end
            }
        )
        -- AFK Check System (Tối ưu hóa)
        task.spawn(function()
            local lastPosition = nil
            local idleStartTime = nil
            
            while task.wait(1) do
                if not _G.Stop and Config.Configuration.IdleCheck and Config.Configuration.IdleCheck > 0 then
                    pcall(function()
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local currentPosition = LocalPlayer.Character.HumanoidRootPart.Position
                            local currentTime = os.time()
                            
                            if lastPosition then
                                local distance = (currentPosition - lastPosition).Magnitude
                                
                                -- Check if player is moving (distance >= 5 studs)
                                if distance >= 5 then
                                    -- Player moved, reset idle timer
                                    idleStartTime = nil
                                else
                                    -- Player not moving
                                    if not idleStartTime then
                                        -- Start tracking idle time
                                        idleStartTime = currentTime
                                    else
                                        -- Check if idle time exceeds threshold
                                        if (currentTime - idleStartTime) >= Config.Configuration.IdleCheck then
                                            print("[AFK Check] Player is idle for " .. (currentTime - idleStartTime) .. " seconds, rejoining...")
                                            if Hop then
                                                Hop("Rejoin")
                                            else
                                                SafeRejoinOrHop("Rejoin")
                                            end
                                            return
                                        end
                                    end
                                end
                            end
                            
                            lastPosition = currentPosition
                        else
                            -- Character not loaded, reset tracking
                            lastPosition = nil
                            idleStartTime = nil
                        end
                    end)
                end
            end
        end)
        function CreateTraceback(Index, Value) -- i gave up
            table.insert(
                ScriptStorage.Tracebacks,
                (GetCurrentDateTime() ..
                    " ( " .. DispTime(os.time() - StartTime, true) .. " ) after execution | " .. Index .. " | " .. Value)
            )
        end

        function SetTask(Index, Value)
            if ScriptStorage.Task[Index] == Value then
                return
            end
            local Parser = {
                MainTask = "Task1",
                SubTask = "Task2"
            }
            if Parser[Index] then
                if SetText then
                    SetText(Parser[Index], Index .. " : " .. Value)
                end
            end
            ScriptStorage.Task[Index] = Value
            ScriptStorage.Task[Index .. "-d"] = os.time()
        end

        Remotes = {}
        BindedMeleeNPCNames = {
            DragonClaw = "Sabi",
            FishmanKarate = "Water Kung-fu Teacher",
            Electro = "Mad Scientist",
            BlackLeg = "Dark Step Teacher",
            DeathStep = "Phoeyu, the Reformed",
            SharkmanKarate = "Sharkman Teacher",
            DragonTalon = "Uzoth",
            ElectricClaw = "Previous Hero",
            Godhuman = "Ancient Monk",
            Superhuman = "Martial Arts Master"
        }
        local MeleeCanBuy = {}
        setmetatable(Remotes, {
            __index = function(Self, Key)
                if Key ~= "CommF_" then
                    print("captured unregistered signal", key)
                    return Services.ReplicatedStorage.Remotes[Key]
                end
        
                local tbl = {
                    InvokeServer = function(Self, ...)
                        print("remote fired", ...)
                        local RemoteAction, IsValidate = ...
                        -- warn(RemoteAction, IsValidate,string.gsub(RemoteAction, "Buy", ''))
                        -- if string.find(RemoteAction, "Buy") == 1 then 
                        --     warn(string.gsub(RemoteAction, "Buy", '')) 
                        -- end
                        if string.find(RemoteAction, "Buy") == 1 and not IsValidate then
                            local MeleeName = string.gsub(RemoteAction, "Buy", '')
                            warn(table.find(MeleeCanBuy, MeleeName), MeleeName, #MeleeCanBuy)
                            if BindedMeleeNPCNames then
                                if table.find(MeleeCanBuy, MeleeName) then
        
                                    local NPC = ScriptStorage.NPCs[BindedMeleeNPCNames[MeleeName]]
                                    if NPC then
                                        local NPCPos = NPC.WorldPivot
                                        SetTask("SubTask", "Buying Melee - " .. MeleeName)
                                        getgenv().anchored = true
                                        if CaculateDistance(NPCPos) > 10 then
                                            repeat
                                                wait()
                                                TweenController.Create(NPCPos.Position)
        
                                            until CaculateDistance(NPCPos) < 10
                                            task.wait(3)
                                            Services.ReplicatedStorage.Remotes.CommF_:InvokeServer(...)
                                        end
                                    end
                                end
                            end
                        end
                        return Services.ReplicatedStorage.Remotes.CommF_:InvokeServer(...)
        
                    end
                }
        
                return tbl
            end
        })
        

        Tasks = {}

        function AwaitUntilPlayerLoaded(Player, Timeout)
            repeat
                task.wait()
            until Player.Character

            Player.Character:WaitForChild("Humanoid")

            repeat
                task.wait()
            until Player.Character.Humanoid.Health > 0
        end

        function AddPoint()
            pcall(function()
                if not LocalPlayer or not LocalPlayer:FindFirstChild("Data") or not LocalPlayer.Data:FindFirstChild("Stats") then return end
                local PointsValue = {}
                local Result
                for _, CInst in pairs(LocalPlayer.Data.Stats:GetChildren()) do
                    if CInst and CInst:FindFirstChild("Level") then
                        PointsValue[CInst.Name] = CInst.Level.Value
                    end
                end
                local defense = PointsValue.Defense or 0
                local melee = PointsValue.Melee or 0
                local lvl = (ScriptStorage and ScriptStorage.PlayerData and ScriptStorage.PlayerData.Level) or 1
                if defense < MaxLevel and (defense < (lvl / 80) or MaxLevel - melee < 100) then
                    Result = "Defense"
                elseif melee < MaxLevel then
                    Result = "Melee"
                else
                    Result = "Sword"
                end
                if Remotes and Remotes.CommF_ then
                    Remotes.CommF_:InvokeServer("AddPoint", Result, 999)
                end
            end)
        end

        local Colors = {
            Currencies = {
                Level = "#00FF40",
                Beli = "#FF7800",
                Fragments = "#6600FF"
            },
            Races = {}
        }
        function RefreshPlayerData()
            pcall(function()
                if not LocalPlayer or not LocalPlayer:FindFirstChild("Data") then return end
                for _, ChildInstance in pairs(LocalPlayer.Data:GetChildren()) do
                    pcall(function()
                        local val = nil
                        if ChildInstance:IsA("IntValue") or ChildInstance:IsA("NumberValue") then
                            val = ChildInstance.Value
                        elseif ChildInstance:IsA("StringValue") then
                            val = ChildInstance.Value
                        elseif ChildInstance:IsA("BoolValue") then
                            val = ChildInstance.Value
                        end
                        if val == nil or val == 0 then
                            if ChildInstance:GetAttribute("Fragments") then
                                val = ChildInstance:GetAttribute("Fragments")
                            elseif ChildInstance:GetAttribute("Value") then
                                val = ChildInstance:GetAttribute("Value")
                            end
                        end
                        if val == nil and ChildInstance.Value ~= nil then
                            val = ChildInstance.Value
                        end
                        if ScriptStorage and ScriptStorage.PlayerData then
                            ScriptStorage.PlayerData[ChildInstance.Name] = val
                        end
                    end)
                end

                local Currencies = ""
                if ScriptStorage and ScriptStorage.PlayerData then
                    for Index, Value in pairs(ScriptStorage.PlayerData) do
                        local Color = Colors and Colors.Currencies and Colors.Currencies[Index]
                        if Color then
                            Currencies = Currencies .. '<font color="' .. Color .. '">' .. Index .. "</font>: " .. tostring(Value) .. " "
                        end
                    end
                end

                if ScriptStorage and ScriptStorage.Interface and type(ScriptStorage.Interface.SetText) == "function" then
                    pcall(function() SetText("Currencies", Currencies) end)
                end
            end)
        end

        function RefreshRace()
            local v27, v28 =
                Remotes.CommF_:InvokeServer("Alchemist", "1"),
                Remotes.CommF_:InvokeServer("Wenlocktoad", "1")
            ScriptStorage.PlayerData.RaceLevel = 1
            if LocalPlayer.Character:FindFirstChild("RaceTransformed") then
                ScriptStorage.PlayerData.RaceLevel = 4
            elseif v28 == -2 then
                ScriptStorage.PlayerData.RaceLevel = 3
            elseif v27 == -2 then
                ScriptStorage.PlayerData.RaceLevel = 2
            end
        end

        function RefreshInventory()
            -- [FIX-25] Loi cu: ca ham nam trong 1 pcall, va dong
            -- "ScriptStorage.Backpack = Backpack2" nam CUOI. Mot phan tu trai cay
            -- loi o vong lap 1 la toan bo ket qua bi bo, Backpack dung lai {} ->
            -- "Backpack has 0 items". Nay: bao loi co in ra, va Backpack2 duoc
            -- dang ngay sau vong getInventory de scan fruit khong the xoa duoc.
            local function Body()
                ScriptStorage.Backpack2 = {}
                if not Remotes or not Remotes.CommF_ then return end
                
                -- 1. Quét các vật phẩm & nguyên liệu thông thường
                local inv = nil
                pcall(function() inv = Remotes.CommF_:InvokeServer("getInventory") end)
                -- [FIX-23] [FIX-22] do ra "Backpack has 0 items" tuc la getInventory chay
                -- xong ma khong them duoc thu nao. Can biet no tra ve gi: khong phai bang,
                -- bang rong, hay cac phan tu khong co .Name.
                if not InventoryDumpTick or os.time() - InventoryDumpTick > 30 then
                    InventoryDumpTick = os.time()
                    print("[FIX-23] getInventory -> type=" .. type(inv) .. " n=" .. tostring(inv and #inv))
                    if type(inv) == "table" then
                        local shown = 0
                        for Key, Value in pairs(inv) do
                            if shown >= 6 then
                                break
                            end
                            shown = shown + 1
                            print(
                                "[FIX-23]  key=" .. tostring(Key) .. " valType=" .. type(Value) ..
                                    " Name=" .. tostring(type(Value) == "table" and Value.Name) ..
                                    " Type=" .. tostring(type(Value) == "table" and Value.Type) ..
                                    " Count=" .. tostring(type(Value) == "table" and Value.Count)
                            )
                        end
                    end
                end
                if type(inv) == "table" then
                    for _, Value in pairs(inv) do
                        if type(Value) == "table" and Value.Name then
                            -- [FIX-25] tung muc phai tu song duoc: loi 1 muc khong
                            -- duoc lam hong ca danh sach.
                            pcall(function()
                                if Value.Type == 'Blox Fruit' and game:GetService("Players").LocalPlayer:FindFirstChild("Data") and game:GetService("Players").LocalPlayer.Data:FindFirstChild("DevilFruit") and game:GetService("Players").LocalPlayer.Data.DevilFruit.Value == "" and table.find(Config.Items.Eatlist, Value.Name) then
                                    warn("Load fruit", Value.Name)
                                    Remotes.CommF_:InvokeServer("LoadFruit", Value.Name)
                                    task.wait(1)
                                    if FunctionsHandler and FunctionsHandler.LocalPlayerController and FunctionsHandler.LocalPlayerController.Methods and FunctionsHandler.LocalPlayerController.Methods.EquipTool then
                                        pcall(function() FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call(FruitIdToName(Value.Name)) end)
                                    end
                                end
                            end)
                            ScriptStorage.Backpack2[Value.Name] = Value
                        end
                    end
                end

                -- [FIX-25] dang ket qua TRUOC khi scan fruit
                ScriptStorage.Backpack = ScriptStorage.Backpack2

                -- 2. Quét toàn bộ Trái Ác Quỷ lưu trữ trong Treasure Inventory (getInventoryFruits)
                local fruits = nil
                pcall(function() fruits = Remotes.CommF_:InvokeServer("getInventoryFruits") end)
                if type(fruits) == "table" then
                    for _, Value in pairs(fruits) do
                        if type(Value) == "table" and Value.Name then
                            Value.Type = "Blox Fruit"
                            ScriptStorage.Backpack[Value.Name] = Value
                        end
                    end
                end
            end
            local ok, err = xpcall(Body, function(m) return debug.traceback(tostring(m), 2) end)
            if not ok then
                print("[FIX-25] RefreshInventory error: " .. tostring(err))
            end
        end


        -- [FIX-45] ---- Cay gate cat trai vao ruong (Treasure Inventory) ----
        -- Ba quy tac user da noi: (1) raid dang chay -> KHONG cat,
        -- (2) binh thuong nhan trai -> van cat, (3) ruong DA CO trai ->
        -- ngung cat va chuyen sang farm Fragments (raid diem F).
        -- Duoc dat o day vi RefreshPlayerData (1314) chay trong luc init,
        -- truoc khi vong quay 60s o cuoi file duoc khai bao.
        ChestFruitCache = {Count = nil, Until = 0}

        -- So trai trong ruong; nil = doc KHONG DUOC (khac voi 0 = ruong trong).
        function GetChestFruitCount()
            local now = os.clock()
            if ChestFruitCache.Count ~= nil and now < ChestFruitCache.Until then
                return ChestFruitCache.Count
            end
            local ok, fruits = pcall(
                function()
                    return Remotes.CommF_:InvokeServer("getInventoryFruits")
                end
            )
            if not ok or type(fruits) ~= "table" then
                return nil
            end
            local count = 0
            for _, fruit in pairs(fruits) do
                if type(fruit) == "table" and (fruit.Name or fruit.Id) then
                    count = count + 1
                end
            end
            ChestFruitCache.Count = count
            ChestFruitCache.Until = now + 3
            return count
        end

        function IsInRaidNow()
            local ok, val = pcall(
                function()
                    if not FunctionsHandler or not FunctionsHandler.RaidController then
                        return false
                    end
                    if FunctionsHandler.RaidController:Get("IsInRaidProcess") then
                        return true
                    end
                    return FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call() ~= nil
                end
            )
            if ok then
                return val == true
            end
            return false
        end

        function CanStoreFruit()
            if IsInRaidNow() then
                print("[FIX-45] bo qua cat trai: dang trong raid")
                return false
            end
            local count = GetChestFruitCount()
            if count ~= nil and count > 0 then
                print("[FIX-45] bo qua cat trai: ruong da co " .. tostring(count) .. " trai")
                return false
            end
            return true
        end

        -- Cat moi trai dang nam trong Backpack/Character. Port tu script
        -- standalone "TU DONG CAT RUONG", them pcall tung muc de 1 loi
        -- khong lam hong ca danh sach.
        function StoreCarriedFruits(tag)
            local list = {}
            pcall(
                function()
                    local backpack = LocalPlayer:FindFirstChild("Backpack")
                    if backpack then
                        for _, item in ipairs(backpack:GetChildren()) do
                            if item:IsA("Tool") and (string.find(item.Name, "Fruit") or item.ToolTip == "Blox Fruit") then
                                table.insert(list, item)
                            end
                        end
                    end
                    local char = LocalPlayer.Character
                    if char then
                        for _, item in ipairs(char:GetChildren()) do
                            if item:IsA("Tool") and (string.find(item.Name, "Fruit") or item.ToolTip == "Blox Fruit") then
                                table.insert(list, item)
                            end
                        end
                    end
                end
            )
            local stored = 0
            for _, tool in ipairs(list) do
                local fruitName = tool:GetAttribute("OriginalName") or tool.Name
                if not table.find(ScriptStorage.IgnoreStoreFruits, fruitName) then
                    local ok, res = pcall(
                        function()
                            return Remotes.CommF_:InvokeServer("StoreFruit", fruitName, tool)
                        end
                    )
                    if ok then
                        print("[FIX-45] " .. tag .. " stored " .. tostring(fruitName) .. " -> " .. tostring(res))
                        stored = stored + 1
                    else
                        print("[FIX-45] " .. tag .. " StoreFruit " .. tostring(fruitName) .. " error: " .. tostring(res))
                    end
                    task.wait(0.35)
                end
            end
            return stored
        end

        function ResearchMoves(Child)
            if Child and tostring(Child) == "V" then
                if ScriptStorage.Connections.BurstCheck then
                    ScriptStorage.Connections.BurstCheck:Disconnect()
                    task.wait(1)
                end
                print("[ Debug ] Registering burst", Child)
                ScriptStorage.Connections.BurstCheck =
                    Child.Cooldown:GetPropertyChangedSignal("AbsoluteSize"):Connect(
                    function()
                        if EnablingBurstDebounce and os.time() - EnablingBurstDebounce < 10 then
                            return
                        end
                        local Value = Child.Cooldown.AbsoluteSize.X
                        if Value < 3 then
                            EnablingBurstDebounce = os.time()
                            SendKey("V", 0)
                        end
                    end
                )
            end
        end

        function CheckMeleeBurstMove(Child)
            if Child.Name == "Black Leg" or Child.Name == "Death Step" then
                local UI = PlayerGui.Main.Skills:WaitForChild(Child.Name, 9)

                ResearchMoves(UI:WaitForChild("V"))
            end
        end

        function RefreshMelees(ReturnOrSet)
            local Result = ""

            for MeleeName, Level in ScriptStorage.Melees do
                Result = Result .. MeleeName .. ": " .. Level .. " "
            end
            Result = Result == "" and "[0]" or Result
            if ReturnOrSet then
                return Result
            end

            if ScriptStorage.Interface then
                SetText("Melees", Result)
            end
        end
        function MeleeCheck(Child)
            print("Melee check", Child)

            if Child and typeof(Child) == "Instance" and Child:IsA("Tool") then
                if Child.ToolTip == "Melee" then
                    -- task.spawn(function()
                    --   CheckMeleeBurstMove(Child)
                    -- end)

                    if ScriptStorage.Connections.Melees then
                        ScriptStorage.Connections.Melees:Disconnect()
                    end

                    ScriptStorage.CurrentMeleeData.Name = Child.Name
                    pcall(
                        function()
                            ScriptStorage.Connections.Melees:Destroy()
                        end
                    )

                    -- Check if Level property exists before accessing it
                    if Child:FindFirstChild("Level") then
                        ScriptStorage.Connections.Melees =
                            Child.Level.Changed:Connect(
                            function(Value)
                                ScriptStorage.Melees[Child.Name] = Value
                                RefreshMelees()
                            end
                        )
                        ScriptStorage.Melees[Child.Name] = Child.Level.Value
                        RefreshMelees()
                    else
                        -- Tool doesn't have Level property, skip
                        print("[MeleeCheck] Tool", Child.Name, "does not have Level property")
                    end
                elseif string.find(tostring(Child), "Fruit") then
                    task.spawn(
                        function()
                            -- Tạm thời disable store fruit khi đang load fruit cho Trevor
                            if FunctionsHandler.Trevor and FunctionsHandler.Trevor:Get("IsLoadingFruit") then
                                return
                            end
                            
                            if table.find(ScriptStorage.IgnoreStoreFruits, Child:GetAttribute("OriginalName")) then
                                return
                            end
                            if
                                Config.Items.AutoEatFruit and
                                    game:GetService("Players").LocalPlayer.Data.DevilFruit.Value == "" and
                                    table.find(Config.Items.Eatlist, Child:GetAttribute("OriginalName"))
                             then
                                while not LocalPlayer.Character:FindFirstChild(Child.Name) and
                                    game:GetService("Players").LocalPlayer.Data.DevilFruit.Value == "" and
                                    task.wait(3) do
                                    FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call(Child.Name)
                                end
                                LocalPlayer.Character:FindFirstChild(Child.Name).EatRemote:InvokeServer()
                            end
                            -- [FIX-45] gate: raid dang chay hoac ruong da co trai
                            -- thi de yen tool, khong goi StoreFruit.
                            if CanStoreFruit() then
                                local StoreResult =
                                    Remotes.CommF_:InvokeServer("StoreFruit", Child:GetAttribute("OriginalName"), Child)
                            end
                        end
                    )
                end
            end
        end
        print(0)
        SetText("MainTextLabel", "Refreshing Player Data 18219")
        print(-1)
        MeleeCheck(LocalPlayer.Character:FindFirstChildOfClass("Tool"))
        print(-2)
        RefreshPlayerData()
        print(-3)
        function RegisterLocalPlayerEventsConnection()
            task.spawn(
                function()
                    task.wait(2)
                    if LocalPlayer.Character:FindFirstChild("HasBuso") then
                        return
                    end
                    Remotes.CommF_:InvokeServer("Buso")
                end
            )

            for _, Connection in ScriptStorage.Connections.LocalPlayer do
                pcall(
                    function()
                        Connection:Disconnect()
                    end
                )
            end

            AwaitUntilPlayerLoaded(LocalPlayer)

            LocalPlayer:SetAttribute("IsAvailable", true)

            ScriptStorage.Connections.LocalPlayer["HealthCheck"] =
                LocalPlayer.Character:WaitForChild("Humanoid"):GetPropertyChangedSignal("Health"):Connect(
                function()
                    local Health = LocalPlayer.Character.Humanoid.Health

                    LocalPlayer:SetAttribute("IsAvailable", Health > 10)
                    ScriptStorage.LocalPlayerHealth = Health
                end
            )

            ScriptStorage.Connections.LocalPlayer["Melee"] = LocalPlayer.Character.ChildAdded:Connect(MeleeCheck)
            ScriptStorage.Connections.LocalPlayer["Fruit"] = LocalPlayer.Backpack.ChildAdded:Connect(MeleeCheck)

            table.foreach(
                LocalPlayer.Backpack:GetChildren(),
                function(_, Melee)
                    MeleeCheck(Melee)
                end
            )

            LastIdleCheck = os.time()
            ScriptStorage.Connections.LocalPlayer.PositionChecker =
                LocalPlayer.Character.HumanoidRootPart:GetPropertyChangedSignal("CFrame"):Connect(
                function()
                    if os.time() == LastIdleCheck then
                        return
                    end
                    LastIdleCheck = os.time()
                    if oldPos then
                        if (LocalPlayer.Character.HumanoidRootPart.CFrame.p - oldPos).magnitude < 2 then
                            return
                        end
                    end
                    oldPos = (LocalPlayer.Character.HumanoidRootPart.CFrame.p)
                    LastIdling = os.time()
                end
            )

            local PointsInstance = LocalPlayer.Data:WaitForChild("Points")
            ScriptStorage.Connections.LocalPlayer.PointConnection =
                PointsInstance:GetPropertyChangedSignal("Value"):Connect(
                function()
                    local CurrentValue = LocalPlayer.Data:WaitForChild("Points")
                    if OldPointValue == CurrentValue then
                        return
                    end

                    OldPointValue = CurrentValue
                    task.wait(1)
                    AddPoint()
                end
            )
        end
        RegisterLocalPlayerEventsConnection(LocalPlayer)

        print(-4)
        game.Players.LocalPlayer.CharacterAdded:Connect(
            function(Character)
                print("[ Debug ] re-registering events")
                RegisterLocalPlayerEventsConnection(LocalPlayer)
            end
        )

        task.spawn(
            function()
                if LocalPlayer.Character:FindFirstChild("HasBuso") then
                    return
                end
                Remotes.CommF_:InvokeServer("Buso")
            end
        )

        print(1)
        MeleesTable = {
            "Black Leg",
            "Electro",
            "Fishman Karate",
            "Dragon Claw",
            "Superhuman",
            "Death Step",
            "Electric Claw",
            "Sharkman Karate",
            "Dragon Talon",
            "Godhuman",
            "SanguineArt"
        }

        MeleesId = {
            "BlackLeg",
            "Electro",
            "FishmanKarate",
            "DragonClaw",
            "Superhuman",
            "DeathStep",
            "ElectricClaw",
            "SharkmanKarate",
            "DragonTalon",
            "Godhuman",
            "SanguineArt"
        }

        MeleePrices = {
            ["Black Leg"] = {
                Price = {
                    Beli = 150000
                },
                Id = "BlackLeg",
                NextLevelRequirement = 400,
                Requirements = function()
                    return true
                end,
                position = CFrame.new(),
                Buy = function(Check)
                  
                    return BuyMelee("BlackLeg", Check,"Dark Step Teacher")
                end
            },
            ["Electro"] = {
                Price = {
                    Beli = 500000
                },
                Id = "Electro",
                NextLevelRequirement = 400,
                Requirements = function()
                    return true
                end,
                Buy = function(Check)
                   
                    return BuyMelee("Electro", Check,"Mad Scientist")
                end
            },
            ["Fishman Karate"] = {
                Price = {
                    Beli = 750000
                },
                NextLevelRequirement = 400,
                Requirements = function()
                    return true
                end,
                Buy = function(Check)
                    
                    return BuyMelee("FishmanKarate", Check, "Water Kung-fu Teacher")
                end
            },
            ["Dragon Claw"] = {
                Price = {
                    Fragments = 1500
                },
                NextLevelRequirement = 400,
                Requirements = function()
                    return true
                end,
                Buy = function(Check)
                   
                    return BuyMelee("DragonClaw", Check, "Sabi")
                end
            },
            ["Superhuman"] = {
                Price = {
                    Beli = 3000000
                },
                NextLevelRequirement = 400,
                Requirements = function()
                    return true
                end,
                Buy = function(Check)
                    
                    return BuyMelee("Superhuman", Check,"Martial Arts Master")                    
                end
            },
            ["Death Step"] = {
                Price = {
                    Beli = 2500000,
                    Fragments = 5000
                },
                NextLevelRequirement = 400,
                Requirements = function()
                    return true
                end,
                Buy = function(Check)
                    
                    return BuyMelee("DeathStep", Check,"Phoeyu, the Reformed")
                end
            },
            ["Sharkman Karate"] = {
                Price = {
                    Beli = 2500000,
                    Fragments = 5000
                },
                NextLevelRequirement = 400,
                Requirements = function()
                    return true
                end,
                Buy = function(Check)
                   
                    return BuyMelee("SharkmanKarate", Check,"Sharkman Teacher")
                end
            },
            ["Dragon Talon"] = {
                Price = {
                    Beli = 2500000,
                    Fragments = 5000
                },
                NextLevelRequirement = 400,
                Requirements = function()
                    return true
                end,
                Buy = function(Check)
                  
                    return BuyMelee("DragonTalon", Check,"Uzoth")
                end
            },
            ["Electric Claw"] = {
                Price = {
                    Beli = 2500000,
                    Fragments = 5000
                },
                NextLevelRequirement = 400,
                Requirements = function()
                    return true
                end,
                Buy = function(Check)
                    
                    return BuyMelee("ElectricClaw", Check,"Previous Hero")
                end
            },
            
            
            ["Godhuman"] = {
                Price = {
                    Beli = 5000000,
                    Fragments = 5000
                },
                NextLevelRequirement = 350,
                Requirements = function()
                    return true
                end,
                Buy = function(Check)
                    
                    return BuyMelee("Godhuman", Check,"Ancient Monk")
                end
            }
        }

        DropItemData = {
            
        }

        GodhumanMaterials = {
            ["Fish Tail"] = {
                20,
                3,
                {
                    "Fishman Raider",
                    "Fishman Captain"
                },
                {
                    "DeepForestIsland3",
                    1,
                    1775,
                    "Turtle Adventure Quest Giver"
                }
            },
            ["Dragon Scale"] = {
                10,
                3,
                {
                    "Dragon Crew Warrior",
                    "Dragon Crew Archer"
                },
                {
                    "DragonCrewQuest",
                    1,
                    1575,
                    "Dragon Crew Quest Giver"
                }
            },
            ["Magma Ore"] = {
                20,
                2,
                {
                    "Magma Ninja"
                },
                {
                    "FireSideQuest",
                    1,
                    1100,
                    "Fire Quest Giver"
                }
            },
            ["Mystic Droplet"] = {
                10,
                2,
                {
                    "Sea Soldier",
                    "Water Fighter"
                },
                {
                    "ForgottenQuest",
                    2,
                    1425,
                    "Forgotten Quest Giver"
                }
            }
        }

        SeaIndexes = {"Main", "Dressrosa", "Zou"}

        TasksOrder = {
            "ExpRedeem",
            "SoulGuitar",
            "Tushita",
            "SpecialBossesTask",
            -- [FIX-28] RaidController la task dung im nay. No thang moi frame vi
            -- Fragments 7350 < 10000 va Beli >= 100k, con "BeliChipCooldownUntil"
            -- chi duoc DOC (4777) khong bao gio duoc GHI -> khong co cooldown nao
            -- chan. Start cua no tim workspace.Map["Boat Castle"] (Sea 3) de mua
            -- chip; model do khong ton tai -> task.wait(1) roi return, lap lai mai
            --, khong lenh di chuyen nao ca -> nhan vat dung im, console chi thay
            -- getInventory/getInventoryFruits (RefreshInventory 4813 chay moi lan
            -- thu). Tac gia sea3:1744 da tu bo raid khoi TasksOrder cho ban Sea 3.
            -- "RaidController",
            "Trevor",
            "UtillyItemsActivitation",
            "ColosseumPuzzle",
            "ThirdSeaPuzzle",
            -- [FIX-24] Yama bi bo khoi TasksOrder (tat tan goc, khong poll nua).
            -- [FIX-19] da chan bang Config.Items o trong Refresh Yama ma HUD van
            -- in "Yama" -> vong lap RefreshTasksData van goi no. Muon bat lai thi
            -- xoa dong comment duoi va giu nguyen [FIX-19]. Cung cach tat cho
            -- Tushita / Trevor / Saber / BossesTask...
            -- "Yama",
            "Saber",
            "PirateRaid",
            "SecondSeaPuzzle",
            "ThirdSeaPuzzle",
            "CollectDrops",
            "BossesTask",
            "LevelFarm"
        }

        MaxLevel = 2800

        placeId = game.PlaceId
        if placeId == 2753915549 or placeId == 85211729168715 then
            Sea = "Main"
            SeaIndex = 1
        elseif placeId == 4442272183 or placeId == 79091703265657 then
            Sea = "Dressrosa"
            SeaIndex = 2
        elseif placeId == 7449423635 or placeId == 100117331123089 then
            Sea = "Zou"
            SeaIndex = 3
        end
    --    if ScriptStorage.PlayerData.Level >= 1500 and (SeaIndex == 2) then
                               
    --         elseif ScriptStorage.PlayerData.Level >= 700 and (SeaIndex == 1 ) then
    --                            print("B")
    --                             game.ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelDressrosa")
    --                     end   
        
    
        Portals =
            (
           
                {
            {
                Vector3.new(-7894.6201171875, 5545.49169921875, -380.246346191406),
                Vector3.new(-4607.82275390625, 872.5422973632812, -1667.556884765625),
                Vector3.new(61163.8515625, 11.759522438049316, 1819.7841796875),
                Vector3.new(3876.280517578125, 35.10614013671875, -1939.3201904296875)
            },
            {
                Vector3.new(-288.46246337890625, 306.130615234375, 597.9988403320312),
                Vector3.new(2284.912109375, 15.152046203613281, 905.48291015625),
                Vector3.new(923.21252441406, 126.9760055542, 32852.83203125),
                Vector3.new(-6508.5581054688, 89.034996032715, -132.83953857422)
            },
            {}
        })[SeaIndex]

        BossesOrder = {
            "Awakened Ice Admiral", 
            "Tide Keeper", 
            "Deandre", 
            "Urban", 
            "Diablo", 
            "Soul Reaper", 
            "Cake Prince"
        }
        BossesOrderLevel = {
            ["Awakened Ice Admiral"] = 700,
            ["Tide Keeper"] = 700,
            ["Deandre"] = 1500,
            ["Urban"] = 1500,
            ["Diablo"] = 1500,
            ["Cake Prince"] = 1500,
            ["Soul Reaper"] = 1500
        }

        BossesOrderWL = {
            ["Deandre"] = 1500,
            ["Urban"] = 1500,
            ["Diablo"] = 1500,
            ["Cake Prince"] = 1500,
            ["Don Swan"] = 1100,
            ["Awakened Ice Admiral"] = 700,
            ["Tide Keeper"] = 700
        }

        SpecialBossesOrder = {
            ["Core"] = 700,
            ["Darkbeard"] = 700,
            ["rip_indra True Form"] = 1500,
            ["Dough King"] = 1500
        }

        BlankTablets = {
            "Segment6",
            "Segment2",
            "Segment8",
            "Segment9",
            "Segment5"
        }

        Trophy = {
            ["Segment1"] = "Trophy1",
            ["Segment3"] = "Trophy2",
            ["Segment4"] = "Trophy3",
            ["Segment7"] = "Trophy4",
            ["Segment10"] = "Trophy5"
        }

        Pipes = {
            ["Part1"] = "Really black",
            ["Part2"] = "Really black",
            ["Part3"] = "Dusty Rose",
            ["Part4"] = "Storm blue",
            ["Part5"] = "Really black",
            ["Part6"] = "Parsley green",
            ["Part7"] = "Really black",
            ["Part8"] = "Dusty Rose",
            ["Part9"] = "Really black",
            ["Part10"] = "Storm blue"
        }

        function ConvertTo(Type, Instance)
            return Type.new(Instance.X, Instance.Y, Instance.Z)
        end

        function CaculateDistance(Origin, Desnitation)
            if not Origin then
                return 0
            end

            Desnitation = Desnitation or game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            local Origin, Desnitation = ConvertTo(Vector3, Origin), ConvertTo(Vector3, Desnitation)

            return (Origin - Desnitation).magnitude
        end

        function DispTime(time, cc)
            time = tonumber(time)
            if not time then
                return "[err]"
            end
            local days = math.floor(time / 86400)
            local hours = math.floor(math.fmod(time, 86400) / 3600)
            local minutes = math.floor(math.fmod(time, 3600) / 60)
            local seconds = math.floor(math.fmod(time, 60))
            if cc then
                return (days .. "day, " .. hours .. "hrs, " .. minutes .. "min, " .. seconds .. "sec.")
            end
            return (days .. "day, " .. hours .. "hrs.")
        end

        function GetCurrentDateTime()
            local now = os.date("*t") -- Get the current time as a table

            local hour = now.hour
            local minute = now.min
            local day = now.day
            local month = now.month
            local year = now.year
            local weekday = now.wday -- Day of the week (1 = Sunday, 7 = Saturday)

            local formattedTime = string.format("%02d:%02d ", hour, minute) -- Format time HH:MM

            local weekdays = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}
            local formattedWeekday = weekdays[weekday]

            local months = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
            local formattedMonth = months[month]

            local formattedDate = string.format("%s, %s %d %d", formattedWeekday, formattedMonth, day, year)

            return formattedTime .. formattedDate -- Combine time and date
        end

    
        function RoundVector3Down(vec)
            return Vector3.new(math.floor(vec.X / 10) * 10, math.floor(vec.Y / 10) * 10, math.floor(vec.Z / 10) * 10)
        end

        local Angle = 30
        lastChange = tick()
        CaculateCircreDirection = function(Position)
            if Angle > 50000 then
                Angle = 60
            end

            Angle = Angle + ((tick() - lastChange) > .4 and 80 or 0)

            if tick() - lastChange > .4 then
                lastChange = tick()
            end

            local sum = Position + Vector3.new(math.cos(math.rad(Angle)) * 40, 0, math.sin(math.rad(Angle)) * 40)
            return CFrame.new(RoundVector3Down(sum.p))
        end

        function GetMonAsSortedRange()
            local Result = {}

            table.foreach(
                Services.Workspace.Enemies:GetChildren(),
                function(_, Mon)
                    if
                        Mon and Mon:FindFirstChild("Humanoid") and Mon:FindFirstChild("HumanoidRootPart") and
                            Mon.Humanoid.Health > 0
                     then
                        table.insert(Result, Mon)
                    end
                end
            )

            table.foreach(
                game.ReplicatedStorage:GetChildren(),
                function(_, Mon)
                    if
                        Mon and Mon:FindFirstChild("Humanoid") and Mon:FindFirstChild("HumanoidRootPart") and
                            Mon.Humanoid.Health > 0
                     then
                        table.insert(Result, Mon)
                    end
                end
            )

            table.sort(
                Result,
                function(C1, C2)
                    return CaculateDistance(C1.HumanoidRootPart.CFrame) < CaculateDistance(C2.HumanoidRootPart.CFrame)
                end
            )

            return Result
        end
        print(1.5)
        function GetMeleeIdByName(MeleeName)
            for Index, Melee in MeleesTable do
                if Melee == MeleeName then
                    return MeleesId[Index]
                end
            end
        end
        function getpos(npcname)
            for i,v in game:GetService("ReplicatedStorage").NPCs:GetChildren() do
                if v.Name == npcname then
                    return v.HumanoidRootPart.CFrame
                end
            end
            for i,v in workspace.NPCs:GetChildren() do
                if v.Name == npcname then
                    return v.HumanoidRootPart.CFrame
                end
            end
        end


        function SendKey(key, hold)
            (function()
                game:GetService("VirtualInputManager"):SendKeyEvent(true, key, false, game)
                task.wait(hold)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, key, false, game)
            end)()
        end

        function FruitIdToName(FruitId)
            local ParserResult = string.match(FruitId, "(((%u)%-?)([^-.]+))$")

            return ParserResult .. " Fruit"
        end

        function Split(inputstr, sep)
            if sep == nil then
                sep = "%s"
            end
            local t = {}
            for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
                table.insert(t, str)
            end
            return t
        end

        function FruitNameToId(FruitName)
            local Id = Split(FruitName)[1]
            return Id .. "-" .. Id
        end

        local QuestManager = {
            CurrentLevel = 2,
            DoubleQuest = true,
            CurrentQuests = {},
            BlacklistedQuestIds = {
                BartiloQuest = 1,
                CitizenQuest = 1,
                Trainees = 1,
                MarineQuest = 1,
                ImpelQuest = 1
            }
        }

        -- [FIX-4] Dong goc cua tac gia o day la:
--            local NpcList = require(game.ReplicatedStorage.GuideModule).Data.NPCList
        -- DA XOAN HAN, vi 2 ly do:
--            1- NpcList khong duoc BAT CU dong nao khac trong ca file doc lai, nen no
--               la bien chet - ket qua cua lan require nay khong ai dung.
--            2- require(GuideModule) treo VINH VIEN tren may nay: log co [BC-1] ma
--               khong co [BC-2], va cung khong co [ERROR] nao (pcall da bat loi neu co)
--               -> day la mot yield khong bao gio return, khong phai loi.
        -- Game co dung GuideModule thi no tu require, khong can minh cho no vao luc.
        -- [FIX-5] Thu pham that cua chuyen dung o 1.5 la require(GuideModule) o FIX-4
        -- ben tren, KHONG phai vong lap cho DataLoaded: log chung DataLoaded co ton tai
        -- (in ra "DataLoaded = DataLoaded") va os.clock van chay binh thuong. Nen o day
        -- khong can yield nua, chi can in nhan diem roi di tiep.
        local function DaNenData()
            local lp = game.Players.LocalPlayer
            return lp:FindFirstChild("DataLoaded") or lp:GetAttribute("DataLoaded")
        end
        print("[FIX-5] DataLoaded = " .. tostring(DaNenData()))

        -- [FIX-12] PO tu sanglove-sea1.lua:803. require() chay than module cua game,
        -- ma module do co the yield khong bao gio return (chinh la cach GuideModule
        -- gi ca script o FIX-4). Chay no o thread khac va chi cho toi da timeout giay.
        local function safe_require(module, timeout)
            if not module then return nil end
            local result, done = nil, false
            task.spawn(function()
                pcall(function() result = require(module) end)
                done = true
            end)
            local maxWait = math.floor((timeout or 1.5) * 10)
            local waited = 0
            while not done and waited < maxWait do
                task.wait(0.1)
                waited = waited + 1
            end
            return result
        end

        -- [FIX-6] That bai thi QuestManager.Quests van nil, ma noi doc no da co san
        -- "if QuestManager and QuestManager.Quests" nen chay tiep an toan.
        pcall(
            function()
                local quests = game.ReplicatedStorage:FindFirstChild("Quests")
                if quests then
                    QuestManager.GameQuests = safe_require(quests, 2)
                else
                    print("[FIX-6] Khong co ReplicatedStorage.Quests")
                end
            end
        )

        print("[BC-A] qua FIX-4/5/6, DataLoaded = " .. tostring(DaNenData()))
        -- [FIX-34] PORT NGUYEN KHOI quest cua script dang chay dc tren may ban
        -- (file 7795 dong dinh kem): bang quest + toa do NPC quest HARD-CODE.
        -- Bat buoc phai port: ban nay lay toa do NPC quest duy nhat tu
        -- require(ReplicatedStorage.GuideModule), ma require(GuideModule) treo VINH VIEN
        -- tren may nay (FIX-4/FIX-17) -> Self.CurrentNpc luon nil -> LevelFarm dung o
        -- dong 'elseif not NpcPosition', khong SetTask nao -> HUD MainTask : n/a va
        -- nhan vat dung im. Doan nay khong doc GuideModule luc sync nen khong treo.

        BuiltInQuests = { -- [FIX-34] global co y: tranh gioi han 200 local cua ham mmb
            -- Sea 1
            BanditQuest1 = { { Task = { ["Bandit"] = 5 }, LevelReq = 1, Name = "Bandit" } },
            JungleQuest = { { Task = { ["Monkey"] = 6 }, LevelReq = 10, Name = "Monkey" }, { Task = { ["Gorilla"] = 8 }, LevelReq = 15, Name = "Gorilla" } },
            BuggyQuest1 = { { Task = { ["Pirate"] = 8 }, LevelReq = 30, Name = "Pirate" }, { Task = { ["Brute"] = 8 }, LevelReq = 40, Name = "Brute" } },
            DesertQuest = { { Task = { ["Desert Bandit"] = 8 }, LevelReq = 60, Name = "Desert Bandit" }, { Task = { ["Desert Officer"] = 6 }, LevelReq = 75, Name = "Desert Officer" } },
            SnowQuest = { { Task = { ["Snow Bandit"] = 7 }, LevelReq = 90, Name = "Snow Bandit" }, { Task = { ["Snowman"] = 8 }, LevelReq = 100, Name = "Snowman" } },
            MarineQuest2 = { { Task = { ["Chief Petty Officer"] = 8 }, LevelReq = 120, Name = "Chief Petty Officer" } },
            SkyQuest = { { Task = { ["Sky Bandit"] = 7 }, LevelReq = 150, Name = "Sky Bandit" }, { Task = { ["Dark Master"] = 8 }, LevelReq = 175, Name = "Dark Master" } },
            PrisonerQuest = { { Task = { ["Prisoner"] = 8 }, LevelReq = 190, Name = "Prisoner" }, { Task = { ["Dangerous Prisoner"] = 8 }, LevelReq = 210, Name = "Dangerous Prisoner" } },
            ColosseumQuest = { { Task = { ["Toga Warrior"] = 7 }, LevelReq = 250, Name = "Toga Warrior" }, { Task = { ["Gladiator"] = 8 }, LevelReq = 275, Name = "Gladiator" } },
            MagmaQuest = { { Task = { ["Military Soldier"] = 8 }, LevelReq = 300, Name = "Military Soldier" }, { Task = { ["Military Spy"] = 8 }, LevelReq = 325, Name = "Military Spy" } },
            FishmanQuest = { { Task = { ["Fishman Warrior"] = 8 }, LevelReq = 375, Name = "Fishman Warrior" }, { Task = { ["Fishman Commando"] = 7 }, LevelReq = 400, Name = "Fishman Commando" } },
            SkyExp1Quest = { { Task = { ["Gods Guard"] = 7 }, LevelReq = 450, Name = "Gods Guard" }, { Task = { ["Shanda"] = 8 }, LevelReq = 475, Name = "Shanda" } },
            SkyExp2Quest = { { Task = { ["Royal Squad"] = 8 }, LevelReq = 525, Name = "Royal Squad" }, { Task = { ["Royal Soldier"] = 8 }, LevelReq = 550, Name = "Royal Soldier" } },
            FountainQuest = { { Task = { ["Galley Pirate"] = 8 }, LevelReq = 625, Name = "Galley Pirate" }, { Task = { ["Galley Captain"] = 8 }, LevelReq = 650, Name = "Galley Captain" } },

            -- Sea 2
            Area1Quest = { { Task = { ["Raider"] = 8 }, LevelReq = 700, Name = "Raider" }, { Task = { ["Mercenary"] = 8 }, LevelReq = 725, Name = "Mercenary" } },
            Area2Quest = { { Task = { ["Swan Pirate"] = 8 }, LevelReq = 775, Name = "Swan Pirate" }, { Task = { ["Factory Staff"] = 8 }, LevelReq = 800, Name = "Factory Staff" } },
            MarineQuest3 = { { Task = { ["Marine Lieutenant"] = 8 }, LevelReq = 875, Name = "Marine Lieutenant" }, { Task = { ["Marine Captain"] = 8 }, LevelReq = 900, Name = "Marine Captain" } },
            ZombieQuest = { { Task = { ["Zombie"] = 8 }, LevelReq = 950, Name = "Zombie" }, { Task = { ["Vampire"] = 8 }, LevelReq = 975, Name = "Vampire" } },
            SnowMountainQuest = { { Task = { ["Snow Trooper"] = 8 }, LevelReq = 1000, Name = "Snow Trooper" }, { Task = { ["Winter Warrior"] = 8 }, LevelReq = 1050, Name = "Winter Warrior" } },
            IceSideQuest = { { Task = { ["Lab Subordinate"] = 8 }, LevelReq = 1100, Name = "Lab Subordinate" }, { Task = { ["Horned Warrior"] = 8 }, LevelReq = 1125, Name = "Horned Warrior" } },
            FireSideQuest = { { Task = { ["Magma Ninja"] = 8 }, LevelReq = 1175, Name = "Magma Ninja" }, { Task = { ["Lava Pirate"] = 8 }, LevelReq = 1200, Name = "Lava Pirate" } },
            ShipQuest1 = { { Task = { ["Ship Deckhand"] = 8 }, LevelReq = 1250, Name = "Ship Deckhand" }, { Task = { ["Ship Engineer"] = 8 }, LevelReq = 1275, Name = "Ship Engineer" } },
            ShipQuest2 = { { Task = { ["Ship Steward"] = 8 }, LevelReq = 1300, Name = "Ship Steward" }, { Task = { ["Ship Officer"] = 8 }, LevelReq = 1325, Name = "Ship Officer" } },
            FrostQuest = { { Task = { ["Arctic Warrior"] = 8 }, LevelReq = 1350, Name = "Arctic Warrior" }, { Task = { ["Snow Lurker"] = 8 }, LevelReq = 1375, Name = "Snow Lurker" } },
            ForgottenQuest = { { Task = { ["Sea Soldier"] = 8 }, LevelReq = 1425, Name = "Sea Soldier" }, { Task = { ["Water Fighter"] = 8 }, LevelReq = 1450, Name = "Water Fighter" } },

            -- Sea 3
            PiratePortQuest = { { Task = { ["Pirate Millionaire"] = 8 }, LevelReq = 1500, Name = "Pirate Millionaire" }, { Task = { ["Pistol Billionaire"] = 8 }, LevelReq = 1525, Name = "Pistol Billionaire" } },
            AmazonQuest = { { Task = { ["Dragon Crew Warrior"] = 8 }, LevelReq = 1575, Name = "Dragon Crew Warrior" }, { Task = { ["Dragon Crew Archer"] = 8 }, LevelReq = 1600, Name = "Dragon Crew Archer" } },
            AmazonQuest2 = { { Task = { ["Female Islander"] = 8 }, LevelReq = 1625, Name = "Female Islander" }, { Task = { ["Giant Islander"] = 8 }, LevelReq = 1650, Name = "Giant Islander" } },
            MarineTreeIsland = { { Task = { ["Marine Commodore"] = 8 }, LevelReq = 1700, Name = "Marine Commodore" }, { Task = { ["Rear Admiral"] = 8 }, LevelReq = 1725, Name = "Rear Admiral" } },
            DeepForestIsland = { { Task = { ["Fishman Raider"] = 8 }, LevelReq = 1775, Name = "Fishman Raider" }, { Task = { ["Fishman Captain"] = 8 }, LevelReq = 1800, Name = "Fishman Captain" } },
            DeepForestIsland2 = { { Task = { ["Forest Pirate"] = 8 }, LevelReq = 1825, Name = "Forest Pirate" }, { Task = { ["Mythological Pirate"] = 8 }, LevelReq = 1850, Name = "Mythological Pirate" } },
            HauntedQuest1 = { { Task = { ["Reborn Skeleton"] = 8 }, LevelReq = 1975, Name = "Reborn Skeleton" }, { Task = { ["Living Zombie"] = 8 }, LevelReq = 2000, Name = "Living Zombie" } },
            HauntedQuest2 = { { Task = { ["Demonic Soul"] = 8 }, LevelReq = 2025, Name = "Demonic Soul" }, { Task = { ["Posessed Mummy"] = 8 }, LevelReq = 2050, Name = "Posessed Mummy" } },
            PeanutQuest = { { Task = { ["Peanut Scout"] = 8 }, LevelReq = 2075, Name = "Peanut Scout" }, { Task = { ["Peanut President"] = 8 }, LevelReq = 2100, Name = "Peanut President" } },
            IceCreamIslandQuest = { { Task = { ["Ice Cream Chef"] = 8 }, LevelReq = 2125, Name = "Ice Cream Chef" }, { Task = { ["Ice Cream Commander"] = 8 }, LevelReq = 2150, Name = "Ice Cream Commander" } },
            CakeQuest1 = { { Task = { ["Cookie Crafter"] = 8 }, LevelReq = 2200, Name = "Cookie Crafter" }, { Task = { ["Cake Guard"] = 8 }, LevelReq = 2225, Name = "Cake Guard" } },
            CakeQuest2 = { { Task = { ["Baking Staff"] = 8 }, LevelReq = 2275, Name = "Baking Staff" }, { Task = { ["Head Baker"] = 8 }, LevelReq = 2300, Name = "Head Baker" } },
            ChocQuest1 = { { Task = { ["Cocoa Warrior"] = 8 }, LevelReq = 2300, Name = "Cocoa Warrior" }, { Task = { ["Chocolate Bar Battler"] = 8 }, LevelReq = 2325, Name = "Chocolate Bar Battler" } },
            ChocQuest2 = { { Task = { ["Sweet Thief"] = 8 }, LevelReq = 2350, Name = "Sweet Thief" }, { Task = { ["Candy Rebel"] = 8 }, LevelReq = 2375, Name = "Candy Rebel" } },
            CandyQuest1 = { { Task = { ["Candy Pirate"] = 8 }, LevelReq = 2400, Name = "Candy Pirate" }, { Task = { ["Snow Demon"] = 8 }, LevelReq = 2425, Name = "Snow Demon" } },
            TikiQuest1 = { { Task = { ["Sun-kissed Warrior"] = 8 }, LevelReq = 2450, Name = "Sun-kissed Warrior" }, { Task = { ["Isle Outlaw"] = 8 }, LevelReq = 2475, Name = "Isle Outlaw" } },
            TikiQuest2 = { { Task = { ["Island Boy"] = 8 }, LevelReq = 2500, Name = "Island Boy" }, { Task = { ["Sun-kissed Champion"] = 8 }, LevelReq = 2525, Name = "Sun-kissed Champion" } },
            SubmergedQuest1 = { { Task = { ["Deepsea Raider"] = 8 }, LevelReq = 2550, Name = "Deepsea Raider" }, { Task = { ["Ocean Prophet"] = 8 }, LevelReq = 2575, Name = "Ocean Prophet" } },
            SubmergedQuest2 = { { Task = { ["Abyssal Sentinel"] = 8 }, LevelReq = 2600, Name = "Abyssal Sentinel" }, { Task = { ["Grand Devotee"] = 8 }, LevelReq = 2625, Name = "Grand Devotee" } }
        }
        BuiltInNpcPositions = { -- global co y (xem ghi chu tren)
            BanditQuest1 = Vector3.new(1060, 16, 1549),
            JungleQuest = Vector3.new(-1600, 37, 153),
            BuggyQuest1 = Vector3.new(-1140, 4, 3828),
            DesertQuest = Vector3.new(896, 6, 4390),
            SnowQuest = Vector3.new(1386, 87, -1298),
            MarineQuest2 = Vector3.new(-5035, 29, 4325),
            SkyQuest = Vector3.new(-4840, 718, -2620),
            PrisonerQuest = Vector3.new(4840, 6, 743),
            ColosseumQuest = Vector3.new(-1575, 7, -2985),
            MagmaQuest = Vector3.new(-5315, 9, 8515),
            FishmanQuest = Vector3.new(61122, 18, 1568),
            SkyExp1Quest = Vector3.new(-7720, 5545, -450),
            SkyExp2Quest = Vector3.new(-7780, 5607, -1450),
            FountainQuest = Vector3.new(5258, 39, 4050),
            Area1Quest = Vector3.new(-426, 73, 1836),
            Area2Quest = Vector3.new(634, 73, 918),
            MarineQuest3 = Vector3.new(-2443, 73, -3217),
            ZombieQuest = Vector3.new(-5492, 49, -795),
            SnowMountainQuest = Vector3.new(607, 401, -5371),
            IceSideQuest = Vector3.new(-6061, 16, -4904),
            FireSideQuest = Vector3.new(-5430, 16, -5296),
            ShipQuest1 = Vector3.new(1038, 125, 32911),
            ShipQuest2 = Vector3.new(969, 125, 33243),
            FrostQuest = Vector3.new(5668, 28, -6485),
            ForgottenQuest = Vector3.new(-3055, 237, -10145),
            PiratePortQuest = Vector3.new(-288, 44, 5580),
            AmazonQuest = Vector3.new(5833, 52, -1103),
            AmazonQuest2 = Vector3.new(5446, 602, 749),
            MarineTreeIsland = Vector3.new(2180, 29, -6737),
            DeepForestIsland = Vector3.new(-10582, 331, -8758),
            DeepForestIsland2 = Vector3.new(-13274, 332, -7628),
            HauntedQuest1 = Vector3.new(-9482, 142, 5565),
            HauntedQuest2 = Vector3.new(-9515, 142, 5520),
            PeanutQuest = Vector3.new(-2104, 38, -10193),
            IceCreamIslandQuest = Vector3.new(-822, 66, -10965),
            CakeQuest1 = Vector3.new(-2020, 38, -12025),
            CakeQuest2 = Vector3.new(-1928, 38, -12850),
            ChocQuest1 = Vector3.new(231, 25, -12200),
            ChocQuest2 = Vector3.new(151, 25, -12775),
            CandyQuest1 = Vector3.new(-1150, 14, -14445),
            TikiQuest1 = Vector3.new(-16540, 55, 1050),
            TikiQuest2 = Vector3.new(-16540, 55, 450),
            SubmergedQuest1 = Vector3.new(11450, -2138, 9700),
            SubmergedQuest2 = Vector3.new(11700, -2138, 10600)
        }
        Sea1Quests = {
            "BanditQuest1", "JungleQuest", "BuggyQuest1", "DesertQuest", "SnowQuest",
            "MarineQuest2", "SkyQuest", "ColosseumQuest", "MagmaQuest",
            "FishmanQuest", "SkyExp1Quest", "SkyExp2Quest", "FountainQuest"
        }
        Sea2Quests = {
            "Area1Quest", "Area2Quest", "MarineQuest3", "ZombieQuest", "SnowMountainQuest",
            "IceSideQuest", "FireSideQuest", "ShipQuest1", "ShipQuest2", "FrostQuest", "ForgottenQuest"
        }
        Sea3Quests = {
            "PiratePortQuest", "AmazonQuest", "AmazonQuest2", "MarineTreeIsland",
            "DeepForestIsland", "DeepForestIsland2", "HauntedQuest1", "HauntedQuest2",
            "PeanutQuest", "IceCreamIslandQuest", "CakeQuest1", "CakeQuest2",
            "ChocQuest1", "ChocQuest2", "CandyQuest1", "TikiQuest1", "TikiQuest2"
        }
        QuestNpcCandidateNames = {
            BanditQuest1 = {"Bandit Quest Giver", "Quest Giver"},
            JungleQuest = {"Jungle Quest Giver", "Quest Giver"},
            BuggyQuest1 = {"Pirate Quest Giver", "Buggy Quest Giver", "Quest Giver"},
            DesertQuest = {"Desert Quest Giver", "Quest Giver"},
            SnowQuest = {"Snow Quest Giver", "Quest Giver"},
            MarineQuest2 = {"Marine Quest Giver", "Quest Giver"},
            SkyQuest = {"Sky Quest Giver", "Sky Quest", "Quest Giver", "Sky Adventure"},
            PrisonerQuest = {"Prison Quest Giver", "Warden", "Quest Giver"},
            ColosseumQuest = {"Colosseum Quest Giver", "Quest Giver"},
            MagmaQuest = {"Magma Quest Giver", "Quest Giver"},
            FishmanQuest = {"Fishman Quest Giver", "Quest Giver"},
            SkyExp1Quest = {"Sky Quest Giver 1", "Sky Quest 1", "Sky Quest Giver", "Quest Giver"},
            SkyExp2Quest = {"Sky Quest Giver 2", "Sky Quest 2", "Sky Quest Giver", "Quest Giver"},
            FountainQuest = {"Fountain Quest Giver", "Quest Giver"},
            Area1Quest = {"Area 1 Quest Giver", "Area 1", "Quest Giver"},
            Area2Quest = {"Area 2 Quest Giver", "Area 2", "Quest Giver"},
            MarineQuest3 = {"Marine Quest Giver", "Quest Giver"},
            ZombieQuest = {"Zombie Quest Giver", "Quest Giver"},
            SnowMountainQuest = {"Snow Mountain Quest Giver", "Quest Giver"},
            IceSideQuest = {"Ice Side Quest Giver", "Quest Giver"},
            FireSideQuest = {"Fire Side Quest Giver", "Quest Giver"},
            ShipQuest1 = {"Ship Quest Giver 1", "Ship Quest 1", "Quest Giver"},
            ShipQuest2 = {"Ship Quest Giver 2", "Ship Quest 2", "Quest Giver"},
            FrostQuest = {"Frost Quest Giver", "Quest Giver"},
            ForgottenQuest = {"Forgotten Quest Giver", "Quest Giver"},
            PiratePortQuest = {"Pirate Port Quest Giver", "Quest Giver"},
            AmazonQuest = {"Amazon Quest Giver", "Quest Giver"},
            AmazonQuest2 = {"Amazon Quest Giver 2", "Quest Giver"},
            MarineTreeIsland = {"Marine Tree Quest Giver", "Marine Tree Island", "Quest Giver"},
            DeepForestIsland = {"Deep Forest Quest Giver", "Deep Forest Island", "Quest Giver"},
            DeepForestIsland2 = {"Deep Forest Quest Giver 2", "Deep Forest Island 2", "Quest Giver"},
            HauntedQuest1 = {"Haunted Quest Giver 1", "Haunted Quest Giver", "Quest Giver"},
            HauntedQuest2 = {"Haunted Quest Giver 2", "Quest Giver"},
            PeanutQuest = {"Peanut Quest Giver", "Quest Giver"},
            IceCreamIslandQuest = {"Ice Cream Quest Giver", "Quest Giver"},
            CakeQuest1 = {"Cake Quest Giver 1", "Quest Giver"},
            CakeQuest2 = {"Cake Quest Giver 2", "Quest Giver"},
            ChocQuest1 = {"Chocolate Quest Giver 1", "Quest Giver"},
            ChocQuest2 = {"Chocolate Quest Giver 2", "Quest Giver"},
            CandyQuest1 = {"Candy Quest Giver 1", "Quest Giver"},
            TikiQuest1 = {"Tiki Quest Giver 1", "Quest Giver"},
            TikiQuest2 = {"Tiki Quest Giver 2", "Quest Giver"},
            SubmergedQuest1 = {"Submerged Quest Giver 1", "Quest Giver"},
            SubmergedQuest2 = {"Submerged Quest Giver 2", "Quest Giver"}
        }
        function QuestManager.FindLiveNpc(Self, QuestId, TargetMobName)
            local foundPos = nil
            pcall(function()
                local wsNpcs = workspace:FindFirstChild("NPCs")
                local refPos = (QuestId and BuiltInNpcPositions[QuestId]) or nil
                if not refPos and TargetMobName then
                    if ScriptStorage.MobRegions and ScriptStorage.MobRegions[TargetMobName] and #ScriptStorage.MobRegions[TargetMobName] > 0 then
                        local r = ScriptStorage.MobRegions[TargetMobName][1]
                        refPos = (typeof(r) == "CFrame" and r.Position) or (typeof(r) == "Vector3" and r)
                    elseif MobPositionsFallback and MobPositionsFallback[TargetMobName] then
                        local r = MobPositionsFallback[TargetMobName]
                        refPos = (typeof(r) == "CFrame" and r.Position) or (typeof(r) == "Vector3" and r)
                    end
                end

                if not refPos then
                    return nil
                end

                -- Quét model trong workspace.NPCs để chọn đúng NPC đứng gần refPos trên cùng hòn đảo
                -- KHÔNG dùng wsNpcs:FindFirstChild vì các NPC đều bị đặt tên trùng nhau ("Quest Giver")
                -- CHỈ chấp nhận NPC model nằm trong bán kính 300 studs quanh refPos chuẩn!
                if wsNpcs then
                    local bestDist = 300
                    local bestNpcPos = nil
                    local candidateList = (QuestId and QuestNpcCandidateNames[QuestId]) or {"Quest Giver"}

                    for _, npcObj in ipairs(wsNpcs:GetChildren()) do
                        if npcObj:IsA("Model") then
                            local nName = npcObj.Name
                            local isGiver = string.find(nName, "Quest") or string.find(nName, "Giver") or table.find(candidateList, nName)
                            if isGiver then
                                local hrp = npcObj:FindFirstChild("HumanoidRootPart") or npcObj:FindFirstChild("Head") or npcObj.PrimaryPart or npcObj:FindFirstChildWhichIsA("BasePart")
                                local p = hrp and hrp.Position or (npcObj.GetPivot and npcObj:GetPivot().Position)
                                if p then
                                    local sameAltitude = true
                                    if refPos.Y > 4000 and p.Y < 4000 then sameAltitude = false end
                                    if refPos.Y < 2000 and p.Y > 4000 then sameAltitude = false end
                                    if refPos.X > 50000 and p.X < 20000 then sameAltitude = false end
                                    if refPos.X < 20000 and p.X > 50000 then sameAltitude = false end

                                    if sameAltitude then
                                        local d = (p - refPos).Magnitude
                                        if d < bestDist then
                                            bestDist = d
                                            bestNpcPos = p
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if bestNpcPos then
                        foundPos = bestNpcPos
                        return
                    end
                end

                -- Nếu không tìm thấy live model trong 300 studs, sử dụng chính xác refPos (BuiltInNpcPositions)
                foundPos = refPos
            end)
            return foundPos
        end
        QuestManager.Quests = BuiltInQuests
        -- Cong them du lieu quest cua chinh game neu require() keo ve duoc trong 2s.
        if QuestManager.GameQuests and type(QuestManager.GameQuests) == "table" then
            for k, v in pairs(QuestManager.GameQuests) do
                QuestManager.Quests[k] = v
            end
        end

        function QuestManager.Set(Self, Index, Value)
            Self[Index] = Value
        end

        function QuestManager.RefreshQuest(Self)
            pcall(function()
                local retries = 0
                while not (ScriptStorage and ScriptStorage.PlayerData and ScriptStorage.PlayerData.Level) do
                    pcall(RefreshPlayerData)
                    if not (ScriptStorage and ScriptStorage.PlayerData and ScriptStorage.PlayerData.Level) then
                        local lp = game:GetService("Players").LocalPlayer
                        if lp and lp:FindFirstChild("Data") and lp.Data:FindFirstChild("Level") then
                            if not ScriptStorage.PlayerData then ScriptStorage.PlayerData = {} end
                            ScriptStorage.PlayerData.Level = lp.Data.Level.Value
                        end
                    end
                    if ScriptStorage and ScriptStorage.PlayerData and ScriptStorage.PlayerData.Level then break end
                    task.wait(0.2)
                    retries = retries + 1
                    if retries > 15 then
                        if not ScriptStorage.PlayerData then ScriptStorage.PlayerData = {} end
                        ScriptStorage.PlayerData.Level = 1
                        break
                    end
                end

                local pLevel = ScriptStorage.PlayerData and ScriptStorage.PlayerData.Level or 1
                local allowedQuests = (SeaIndex == 1 and Sea1Quests) or (SeaIndex == 2 and Sea2Quests) or Sea3Quests
                local QuestLevelFlag = -1
                local CurrentQuestData = nil
                local BestQuestId = nil

                for _, QuestID in ipairs(allowedQuests) do
                    if not QuestManager.BlacklistedQuestIds or not QuestManager.BlacklistedQuestIds[QuestID] then
                        local QuestDatas = (QuestManager.Quests and QuestManager.Quests[QuestID]) or BuiltInQuests[QuestID]
                        if QuestDatas and QuestDatas[1] and QuestDatas[1].LevelReq then
                            if QuestDatas[1].LevelReq <= pLevel and QuestDatas[1].LevelReq > QuestLevelFlag then
                                QuestLevelFlag = QuestDatas[1].LevelReq
                                -- Make a shallow copy of table so modifications don't corrupt BuiltInQuests
                                local copied = {}
                                for idx, entry in ipairs(QuestDatas) do
                                    table.insert(copied, entry)
                                end
                                CurrentQuestData = copied
                                BestQuestId = QuestID
                            end
                        end
                    end
                end

                if BestQuestId then
                    Self.CurrentQuestId = BestQuestId
                end

                Self.CurrentNpc = nil

                if CurrentQuestData and #CurrentQuestData > 0 then
                    local LastQuest = CurrentQuestData[#CurrentQuestData]
                    if LastQuest and LastQuest.Task then
                        for _, Count in pairs(LastQuest.Task) do
                            if Count == 1 then
                                table.remove(CurrentQuestData, #CurrentQuestData)
                            end
                        end
                    end

                    -- Xác định quái mục tiêu cho quest hiện tại
                    local targetMobName = nil
                    for qIdx = #CurrentQuestData, 1, -1 do
                        local qData = CurrentQuestData[qIdx]
                        if qData and qData.LevelReq and qData.LevelReq <= pLevel then
                            if qData.Task then
                                for mName in pairs(qData.Task) do
                                    targetMobName = mName
                                    break
                                end
                            end
                            break
                        end
                    end

                    -- 1. ƯU TIÊN SỐ 1: Quét trực tiếp NPC Model đang spawn trong workspace.NPCs trên cùng hòn đảo
                    local liveNpcPos = QuestManager:FindLiveNpc(Self.CurrentQuestId, targetMobName)
                    if liveNpcPos then
                        Self.CurrentNpc = liveNpcPos
                    elseif Self.CurrentQuestId and BuiltInNpcPositions[Self.CurrentQuestId] then
                        Self.CurrentNpc = BuiltInNpcPositions[Self.CurrentQuestId]
                    end
                end

                Self.CurrentQuests = CurrentQuestData
            end)
        end

        function QuestManager.GetCurrentQuest(Self)
            if not Self.CurrentQuests or #Self.CurrentQuests == 0 then
                return nil, Self.CurrentNpc, Self.CurrentQuestId, 1, nil
            end
            local pLvl = (ScriptStorage.PlayerData and ScriptStorage.PlayerData.Level) or 1
            local QuestIndex = 1
            -- Chọn sub-quest cao nhất mà người chơi đã đủ cấp độ nhận
            for qIdx = #Self.CurrentQuests, 1, -1 do
                local qData = Self.CurrentQuests[qIdx]
                if qData and qData.LevelReq and qData.LevelReq <= pLvl then
                    QuestIndex = qIdx
                    break
                end
            end

            if Self.CurrentQuests[QuestIndex] and Self.CurrentQuests[QuestIndex].Task then
                for Name in pairs(Self.CurrentQuests[QuestIndex].Task) do
                    return Name, Self.CurrentNpc, Self.CurrentQuestId, QuestIndex, Self.CurrentQuests[QuestIndex].Name
                end
            end
            return nil, Self.CurrentNpc, Self.CurrentQuestId, 1, nil
        end

        function QuestManager.MarkAsCompleted(Self)
            Self.CurrentLevel = Self.CurrentLevel == 2 and 1 or 2
        end

        function QuestManager.AbandonQuest()
            print("Abandon quest")
            Remotes.CommF_:InvokeServer("AbandonQuest")
        end

        function QuestManager.GetCurrentClaimQuest(RawResponse)
            local QuestTitle =
                game.Players.LocalPlayer.PlayerGui.Main.Quest.Visible and
                game.Players.LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text:gsub(
                    "%s*Defeat%s*(%d*)%s*(.-)%s*%b()",
                    "%2"
                )
            return (type(QuestTitle) == "string" and string.gsub(QuestTitle, "Military ", "Mil. ") or QuestTitle), game.Players.LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
        end

        function QuestManager.StartQuest(QuestId, QuestLevel)
            return Remotes.CommF_:InvokeServer("StartQuest", QuestId, QuestLevel)
        end

        -- [FIX-35] Port QuestManager.HasActiveQuest tu script dang chay dc (2430).
        -- Trieu chung lan nay: log in "remote fired StartQuest TikiQuest2 2" sau
        -- 3 giay lai in nua, nhan mai ma khong danh. Ly do: LevelFarm hoi "da co
        -- quest chua" bang cach doc label tren HUD, ma HUD client nay tieng Viet
        -- va thu tu node khong giong gia dinh tac gia. Ban nay dung 2 thu:
        --  + LastQuestClaimTick: vua nhan xong thi COI NHU dang co quest trong
        --    khoang thoi gian an han (8s + thoi gian bay ra bai guai), nen khong
        --    bao gio nhan lai lien tuc.
        --  + Quet toan bo label trong frame Quest tim dinh dang "(X/Y)" -> khong
        --    can doc ten quest bang tieng Anh.
        function QuestManager.HasActiveQuest(MobHint)
            -- [FIX-37] Probe [FIX-36] tra loi quyet dinh:
            --   questFrame=Players.<you>.PlayerGui.Main.Quest visible=false
            -- tuc la frame do game AN (Visible=false) ngay khi ban DANG CO
            -- nhiem vu (panel "Isle Champion 0/8" ban nhin thay la mot GUI khac).
            -- Toan bo ban cua tac gia (va lan port truoc cua minh) lay
            -- "Main.Quest.Visible" lam dieu kien -> luon false -> luc nao cung
            -- bao "chua co quest" -> het an han lai StartQuest -> reset 0/8 ->
            -- bay ve NPC roi lai bay ra bai (dung cai ban goi la "bay di bay lai").
            -- Cach moi: khong tin ten node cung khong tin Visible cua frame.
            -- Tim TextLabel DANG RENDER THAT (AbsoluteSize > 0, tu do la an toan
            -- voi cha an) chua bo dem "x/y" (y <= 50). Co = dang co nhiem vu.
            -- Quet PlayerGui rat dat nen ket qua duoc cache 0.5 giay.
            local baseGracePeriod = (Config and Config.Settings and tonumber(Config.Settings.QuestGracePeriod)) or 8
            local gracePeriod = math.max(baseGracePeriod, tonumber(getgenv().DynamicQuestGracePeriod) or baseGracePeriod)
            local inGrace = (getgenv().LastQuestClaimTick and (tick() - getgenv().LastQuestClaimTick < gracePeriod)) and true or false

            local now = tick()
            local hint = MobHint and tostring(MobHint) or ""
            -- [FIX-40] Cache phai theo MobHint: doi bai guai (doi quest) thi ket
            -- qua cu khong con dung.
            if
                not QuestProgressCache or QuestProgressCache.Hint ~= hint or
                    now - (QuestProgressCache.Next or 0) >= 0.5
             then
                local has, cur, max, txt, mob = false, nil, nil, "", false
                pcall(function()
                    local pgui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
                    if not pgui then
                        return
                    end
                    local lowHint = hint ~= "" and string.lower(hint) or ""
                    for _, obj in pairs(pgui:GetDescendants()) do
                        if
                            (obj:IsA("TextLabel") or obj:IsA("TextButton")) and obj.Visible and
                                obj.AbsoluteSize.X > 0 and obj.AbsoluteSize.Y > 0 and
                                obj.Text and
                                obj.Text ~= ""
                         then
                            local t = obj.Text
                            if lowHint ~= "" and not mob and string.find(string.lower(t), lowHint, 1, true) then
                                mob = true
                            end
                            local isReward =
                                string.find(t, "Beli") or string.find(t, "beli") or string.find(t, "Exp") or
                                    string.find(t, "exp") or
                                    string.find(t, "Reward") or
                                    string.find(t, "%+") or
                                    string.find(t, "%$")
                            if not isReward then
                                -- [FIX-42] PHAI LA BO DEM TRON VEN "x/y". Probe
                                -- bat duoc canh sai:
                                --   txt="Region: US-W | Players: 17/20 | Total Bounty: 50,031,309"
                                -- tuc la chi can CHUA "x/y" thi no dem luon bo dem
                                -- so nguoi choi trong server bang. Panel nhiem vu
                                -- ghi dung "5/8" nen bat buoc ca chuoi.
                                local c, tt = string.match(t, "^%s*(%d+)%s*/%s*(%d+)%s*$")
                                if not c then
                                    c, tt = string.match(t, "^%s*%((%d+)%s*/%s*(%d+)%)%s*$")
                                end
                                c, tt = tonumber(c), tonumber(tt)
                                if c and tt and tt > 1 and tt <= 50 and c <= tt then
                                    -- [FIX-42] GIU CAI DAU TIEN: khi mobLabel false
                                    -- (panel tieng Viet) vong duyet khong break som
                                    -- nen neu gan lap lien thi bo dem cuoi cung
                                    -- (khong phai cua nhiem vu) se ghi de.
                                    if not has then
                                        has, cur, max, txt = true, c, tt, t
                                    end
                                    if mob or lowHint == "" then
                                        break
                                    end
                                end
                            end
                        end
                    end
                end)
                QuestProgressCache = {Next = now, Has = has, Cur = cur, Max = max, Txt = txt, Mob = mob, Hint = hint}
            end

            local cache = QuestProgressCache or {Has = false, Cur = nil, Max = nil, Mob = false, Hint = ""}
            -- [FIX-40] "Co bo dem x/y o dau do tren man hinh" KHONG dang voi "co
            -- nhiem vu dang chay": Blox Fruits con nhieu label x/y khac (style,
            -- race, do an...). Neu chi can bo dem thi questUI = true mai mai,
            -- LevelFarm khong bao gio vao nhanh nhan quest nua (ban bao "co nhan
            -- gi dau"). Dieu kien chat: bo dem VA label chua ten con guai cua
            -- chinh quest dang lam. Chua duoc MobHint (goi khong tham so) thi
            -- giung nguyen nhu cu.
            -- [FIX-42] Panel nhiem vu tren client nay la TIENG VIET ("Danh bai 8
            -- Nha Vo Dich Dao Tiki"), con MobHint lay tu du lieu game la TIENG
            -- ANH ("Isle Champion") -> mobLabel nhieu khi false. Van giu dieu kien
            -- ten de chong nhan dam bo dem khac, nhung sau khi vua nhan quest
            -- (inGrace) thi bo dem "x/y" du tin.
            local questUI = cache.Has and (hint == "" or cache.Mob == true or inGrace)
            local hasQuest = questUI or inGrace
            local currentKills, maxKills = cache.Cur, cache.Max

            -- [FIX-37] XONG NHIEM VU: duoc tinh la xong khi bo dem cham
            -- max (8/8) -> tra "khong con quest" de LevelFarm bay di nhan cai
            -- KE TIEP, thay vi danh mai mot bai da chet.
            if hasQuest and currentKills and maxKills and currentKills >= maxKills then
                hasQuest = false
                getgenv().LastQuestClaimTick = nil
            end

            if not QuestProbeNext or tick() >= QuestProbeNext then
                QuestProbeNext = tick() + 10
                print(
                    "[FIX-40] questUI=" ..
                        tostring(questUI) ..
                        " counter=" ..
                            tostring(cache.Has) ..
                            " mobLabel=" .. tostring(cache.Mob) .. " hint=" .. hint ..
                            " prog=" .. tostring(currentKills) .. "/" .. tostring(maxKills) ..
                            " grace=" .. string.format("%.1f", gracePeriod) .. " inGrace=" .. tostring(inGrace) ..
                            " txt=" .. tostring(cache.Txt)
                )
            end

            return hasQuest, currentKills, maxKills
        end

        ScriptStorage.MobRegions = {}
        -- [FIX-7] FortBuilder...Folder khong phai build nao cung co. Loi o day thi
        -- xpcall cuoi file bat ca mmb(), toan bo phan con lai khong chay.
        pcall(
            function()
                local folder = game:GetService("ReplicatedStorage"):FindFirstChild("FortBuilderReplicatedSpawnPositionsFolder")
                if folder then
                    for _, Region in folder:GetChildren() do
                        ScriptStorage.MobRegions[tostring(Region)] = ScriptStorage.MobRegions[tostring(Region)] or {}
                        table.insert(ScriptStorage.MobRegions[tostring(Region)], Region.CFrame)
                    end
                else
                    print("[FIX-7] Khong co FortBuilderReplicatedSpawnPositionsFolder -> MobRegions de trong")
                end
            end
        )

        TweenController = {}
        local LastestTeleportToHomePoint = 0
        local Entries = {}
        -- [FIX-8] ReplicatedStorage.NPCs that (que that) thi cham dc o day.
        pcall(
            function()
                local npcs = game.ReplicatedStorage:FindFirstChild("NPCs")
                if npcs then
                    for _, NPC in npcs:GetChildren() do
                        if NPC.Name == "Set Home Point" then
                            table.insert(Entries, NPC:GetModelCFrame())
                        end
                    end
                else
                    print("[FIX-8] Khong co ReplicatedStorage.NPCs -> bo qua Set Home Point")
                end
            end
        )
        print("[BC-B] qua MobRegions + ReplicatedStorage.NPCs")
        local function NoclipLoop()
            speaker = LocalPlayer
            if speaker.Character ~= nil then
                for _, child in pairs(speaker.Character:GetDescendants()) do
                    if child:IsA("BasePart") and child.CanCollide == true and child.Name ~= nil then
                        child.CanCollide = false
                    end
                end
            end
        end
        Noclipping = Services.RunService.Stepped:Connect(NoclipLoop)
        function GetPortal(Position)
            local Nearest, Current = 9e9, nil
            for _, Portal in Portals do
                local Dist1 = CaculateDistance(Portal, Position)
                if Dist1 < (CaculateDistance(Position) - 300) and Dist1 < Nearest then
                    Nearest = Dist1
                    Current = Portal
                end
            end
            if Current then
                Remotes.CommF_:InvokeServer("requestEntrance", Current)
                return task.wait()
            end
        end
        function GetEntries(Position)
            local Nearest, Current = 9e9, nil
            for _, Entry in Entries do
                local Dist1 = CaculateDistance(Entry, Position)
                if Dist1 < (CaculateDistance(Position) - 700) and Dist1 < Nearest then
                    Nearest = Dist1
                    Current = Entry
                end
            end
            if Current then
                if os.time() - LastestTeleportToHomePoint > 30 then
                    for i = 1, 10, 1 do
                        task.wait()
                    end
                end
            end
        end
        local lp = game.Players.LocalPlayer
        local usebypassteleport = true
        function CheckNearestTeleporter(vcs)
            vcspos = vcs.Position
            min = math.huge
            min2 = math.huge
            local placeId = game.PlaceId
            if placeId == 2753915549 then
                OldWorld = true
            elseif placeId == 4442272183 then
                NewWorld = true
            elseif placeId == 7449423635 then
                ThreeWorld = true
            end
            if ThreeWorld then
                TableLocations = {
                    ["Caslte On The Sea"] = Vector3.new(- 5058.77490234375, 314.5155029296875, - 3155.88330078125),
                    ["Hydra"] = Vector3.new(5756.83740234375, 610.4240112304688, - 253.9253692626953),
                    ["Mansion"] = Vector3.new(- 12463.8740234375, 374.9144592285156, - 7523.77392578125),
                    ["Temple of Time"] = Vector3.new(28282.5703125, 14896.8505859375, 105.1042709350586)
                    -- ["Great Tree"] = Vector3.new(2968.699951171875, 2284.286865234375, -7226.28662109375),
                }
            elseif NewWorld then
                TableLocations = {
                    ["122"] = Vector3.new(923.21252441406, 126.9760055542, 32852.83203125),
                    ["3032"] = Vector3.new(- 6508.5581054688, 150.034996032715, - 132.83953857422)
                }
            elseif OldWorld then
                TableLocations = {
                    ["1"] = Vector3.new(- 7894.6201171875, 5545.49169921875, - 380.2467346191406),
                    ["2"] = Vector3.new(- 4607.82275390625, 872.5422973632812, - 1667.556884765625),
                    ["3"] = Vector3.new(61163.8515625, 11.759522438049316, 1819.7841796875),
                    ["4"] = Vector3.new(3876.280517578125, 35.10614013671875, - 1939.3201904296875)
                }
            end
            TableLocations2 = {}
            if TableLocations then
                for i, v in pairs(TableLocations) do
                    TableLocations2[i] = (v - vcspos).Magnitude
                end
                for i, v in pairs(TableLocations2) do
                    if v < min then
                        min = v
                        min2 = v
                    end
                end
                for i, v in pairs(TableLocations2) do
                    if v < min then
                        min = v
                        min2 = v
                    end
                end
                for i, v in pairs(TableLocations2) do
                    if v <= min then
                        choose = TableLocations[i]
                    end
                end
                min3 = (vcspos - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if min2 <= min3 then
                    return choose
                end
            end
            return false
        end

        function requestEntrance(vector3)
            local args = {
                [1] = "requestEntrance",
                [2] = vector3
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
        end
        
        -- TweenController
        
        -- [FIX-53] Dao Nguoi Ca nam o X ~ 61122 (FishmanQuest / Water Kung-fu
        -- Teacher), tuc la cach Sea 1 hon 60000 studs: bay Thuong (100 st/giay)
        -- thi 10 phut moi toi, va 200s khong thay guai la hub bao "Error while
        -- farming, rejoin" roi hop sever. Cach cua game: cho nhan vat ngoi vung
        -- xoay nuoc o (4035.3, -4.0, -1857.0) roi server keo thang xuong dao.
        -- (Diem (3952.6, 7.0, -1666.5) gan do chi la moc ben bo.)
        FishmanWhirlpool = Vector3.new(4035.3, -4.0, -1857.0)
        FishmanIslandMinX = 50000
        
        -- [FIX-54] Chet roi bam nut Respawn cua game: Blox Fruits tra nhan vat ve
        -- diem spawn gan nhat (Sea 1), nhanh hon nhieu so voi bay 57000 studs
        -- nguoc ve bo. Co 3 lan va nghi 25s/lan de khong co chet lien hoi neu
        -- diem spawn cung nam duoi dao.
        function RespawnToLeaveFishman()
            local Now = os.clock()
            if LeaveFishmanAt and Now - LeaveFishmanAt < 25 then
                return
            end
            LeaveFishmanAt = Now
            LeaveFishmanTries = (LeaveFishmanTries or 0) + 1
            LastFound = os.time()
            print("[FIX-54] Roi dao Nguoi Ca bang respawn (lan " .. tostring(LeaveFishmanTries) .. ")")
            task.spawn(
                function()
                    local LP = game.Players.LocalPlayer
                    pcall(
                        function()
                            local Hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                            if Hum then
                                Hum.Health = 0
                            end
                        end
                    )
                    task.wait(1.5)
                    pcall(
                        function()
                            local Main = LP:FindFirstChild("PlayerGui") and LP.PlayerGui:FindFirstChild("Main")
                            if not Main then
                                return
                            end
                            for _, Obj in ipairs(Main:GetDescendants()) do
                                if
                                    Obj:IsA("TextButton") and
                                        (
                                            string.find(Obj.Name, "Respawn") or
                                                (Obj.Parent and string.find(Obj.Parent.Name, "Respawn"))
                                        )
                                 then
                                    Obj.MouseButton1Click:Fire()
                                    break
                                end
                            end
                        end
                    )
                end
            )
        end
        
        function TweenController.Create(Position)
            -- 1. KIỂM TRA CƠ BẢN
            local Character = game.Players.LocalPlayer.Character
            if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
            if not Position or TweenDebounce or TweenController._isCreating then return end
        
            -- Chuyển đổi Position sang CFrame nếu cần
            local TargetCFrame = typeof(Position) ~= "CFrame" and CFrame.new(Position) or Position
            -- Chỉ giữ lại tọa độ Position, loại bỏ Rotation để tránh xoay người ảo
            TargetCFrame = CFrame.new(TargetCFrame.Position)
        
            local RootPart = Character.HumanoidRootPart
            local CurrentDist = (RootPart.Position - TargetCFrame.Position).Magnitude
        
            -- [FIX-53] Dang o Sea 1 ma dich ben kia la dao Nguoi Ca (X > 50000):
            -- doi huong sang vung xoay nuoc va de cho do keo xuong. Khong tao
            -- Tween khi da ngoi trong xoay (5s/lan) vi Tween se keo nguoc len
            -- mat nuoc, de loi kep cua server bi ghi de; het 5s chua bi keo thi
            -- ngoi lai tam xoay 1 lan nua. Moi lan ngoi thi cap nhat LastFound de
            -- tinh tien trinh, khong bi "Error while farming, rejoin" hop sever.
            if
                SeaIndex == 1 and TargetCFrame.Position.X > FishmanIslandMinX and
                    RootPart.Position.X < FishmanIslandMinX
             then
                LeaveFishmanTries = 0
                local DistPool = (RootPart.Position - FishmanWhirlpool).Magnitude
                local PoolNow = os.clock()
                if DistPool > 120 then
                    FishmanDipUntil = nil
                    TargetCFrame = CFrame.new(FishmanWhirlpool)
                    CurrentDist = DistPool
                elseif not FishmanDipUntil or PoolNow < FishmanDipUntil then
                    FishmanDipUntil = FishmanDipUntil or (PoolNow + 5)
                    LastFound = os.time()
                    if TweenInstance then
                        TweenInstance:Cancel()
                    end
                    TweenController._isCreating = false
                    return
                else
                    FishmanDipUntil = PoolNow + 5
                    TargetCFrame = CFrame.new(FishmanWhirlpool)
                    CurrentDist = DistPool
                end
            end
        
            -- 2. CHỐNG GIẬT (Smarter Check)
            -- Nếu đang có Tween chạy và mục tiêu mới quá gần mục tiêu cũ, hoặc nhân vật đã gần đích -> Bỏ qua
            if TweenInstance and TweenInstance.PlaybackState == Enum.PlaybackState.Playing then
                if CurrentDist < 5 then return end -- Đã đủ gần, không cần tạo thêm
            end
        
            -- [FIX-51] DA HOAN TOAN [FIX-50]: hai chan (sticky target 1s/1.5s va
            -- tat BodyVelocity luc bay) khien viec di chuyen bi loi tren may ban,
            -- nen quay lai dung nhu ban dau: Create goi lan nao la Cancel tween cu
            -- mo tween moi, BodyVelocity "eltrul" luon gi MaxForce = math.huge.
        
            TweenController._isCreating = true
        
            -- 3. XỬ LÝ NOCLIP (Mượt hơn)
            pcall(function()
                for _, part in ipairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end)
        
            -- 4. GIỮ NHÂN VẬT TRÊN KHÔNG (BodyVelocity)
            local head = Character:FindFirstChild("Head")
            if head and not head:FindFirstChild("eltrul") then
                local bv = Instance.new("BodyVelocity")
                bv.Name = "eltrul"
                bv.MaxForce = Vector3.new(0, math.huge, 0)
                bv.Velocity = Vector3.zero
                bv.Parent = head
            end
        
            -- 5. LOGIC DI CHUYEN DAC BIET (Sea 3 Submarine / Portals)
            -- [FIX-54] DA TAT GetPortal/requestEntrance hoan toan. Ban cu moi lan
            -- mo lai la log "remote fired requestEntrance -4607.82, 872.54,
            -- -1667.55" chay lien tuc + hang tram warning "set the parent of
            -- Portal to NULL" -> lag may (ban bao "dung goi nua lagg qua"). Di
            -- xa thi bay Thuong hoac dung vong xoay [FIX-53], khong xin cong.
            if
                CurrentDist > 500 and SeaIndex == 1 and
                    RootPart.Position.X > FishmanIslandMinX and
                    TargetCFrame.Position.X < FishmanIslandMinX and (LeaveFishmanTries or 0) < 3
             then
                -- [FIX-54] Roi kho dao Nguoi Ca: bay nguoc 57000 studs thi 10
                -- phut moi ve, nen respawn de game tra ve diem spawn o Sea 1.
                RespawnToLeaveFishman()
                return
            end
        
            -- Kiểm tra di chuyển sang Submerged Island (Sea 3)
            if SeaIndex == 3 and TargetCFrame.Position.Y < -1500 then
                local SubmarinePos = CFrame.new(-16269, 23, 1371)
                if (RootPart.Position - SubmarinePos.Position).Magnitude > 60 then
                    TweenController._isCreating = false
                    TweenController.Create(SubmarinePos)
                    return
                end
                pcall(function()
                    require(game.ReplicatedStorage.Modules.Net):RemoteFunction("SubmarineWorkerSpeak"):InvokeServer("TravelToSubmergedIsland")
                end)
                TweenController._isCreating = false
                return
            end
        
            -- 6. THỰC THI TWEEN
            -- Hủy Tween cũ trước khi tạo mới
            if TweenInstance then
                TweenInstance:Cancel()
            end
        
            -- Tính toán tốc độ: Nếu gần thì đi chậm (25), nếu xa thì đi nhanh (100)
            local Speed = (CurrentDist < 18) and 25 or 100
            local Time = CurrentDist / Speed
        
            TweenInstance = Services.TweenService:Create(
                RootPart,
                TweenInfo.new(Time, Enum.EasingStyle.Linear),
                {CFrame = TargetCFrame}
            )
            
            TweenInstance:Play()
        
            -- Reset flag sau một khoảng thời gian ngắn để tránh spam
            task.delay(0.1, function()
                TweenController._isCreating = false
            end)
        end



        local AttackController = {}
        function BuyMelee(M1, Check, NPCName)
            -- Với Dragon Claw, cần tele tới NPC "Sabi" trước khi mua
            if M1 == "DragonClaw" then
                if Check then
                    -- Chỉ check fragments trong PlayerData, không gọi remote để tránh trừ fragments
                    RefreshPlayerData()
                    local PlayerData = ScriptStorage.PlayerData
                    local RequiredFragments = 1500
                    local HasEnoughFragments = PlayerData and PlayerData.Fragments and PlayerData.Fragments >= RequiredFragments

                    if HasEnoughFragments and not table.find(MeleeCanBuy, M1) then
                        warn("Inserted DragonClaw")
                        table.insert(MeleeCanBuy, M1)
                    end
                    return HasEnoughFragments
                end

                -- Sea 3: dùng tọa độ cố định cho Sabi
                if SeaIndex == 3 then
                    local SabiPos = CFrame.new(-4979.9091796875, 371.34295654296875, -3205.458251953125)
                    SetTask("SubTask", "Buying Melee - Dragon Claw (Sea 3)")
                    getgenv().anchored = true
                    if CaculateDistance(SabiPos) > 10 then
                        repeat
                            task.wait()
                            TweenController.Create(SabiPos)
                        until CaculateDistance(SabiPos) < 10
                        task.wait(3)
                    end
                    return Remotes.CommF_:InvokeServer("BlackbeardReward", "DragonClaw", "2")
                end

                -- Sea 2: dùng logic cũ tìm NPC trong workspace/replicated storage
                if NPCName and ScriptStorage.NPCs[NPCName] then
                    local NPC = ScriptStorage.NPCs[NPCName]
                    if NPC then
                        local NPCPos = nil
                        if NPC.WorldPivot then
                            NPCPos = NPC.WorldPivot
                        elseif NPC:FindFirstChild("HumanoidRootPart") then
                            NPCPos = NPC.HumanoidRootPart.CFrame
                        end

                        if NPCPos then
                            SetTask("SubTask", "Buying Melee - Dragon Claw (Sea 2)")
                            getgenv().anchored = true
                            local NPCPosition = NPCPos.Position or (NPCPos and NPCPos.Position)
                            if NPCPosition and CaculateDistance(NPCPosition) > 10 then
                                repeat
                                    task.wait()
                                    TweenController.Create(NPCPosition)
                                until CaculateDistance(NPCPosition) < 10
                                task.wait(3)
                            end
                        end
                    end
                end
                return Remotes.CommF_:InvokeServer("BlackbeardReward", "DragonClaw", "2")
            end 
            if Check then
                local Response_ = Remotes.CommF_:InvokeServer("Buy" .. M1, true)
                print("Response_", Response_ == 1, typeof(Response_))
                if type(Response_) == "number" and not table.find(MeleeCanBuy,M1) then
                    table.insert(MeleeCanBuy, M1)
                    warn("Inserted " .. M1)
                end
                return Response_ == 1
            end
            return Remotes.CommF_:InvokeServer("Buy" .. M1)
        end




        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Workspace = game:GetService("Workspace")
        local VirtualInputManager = game:GetService("VirtualInputManager")
        local Player = Players.LocalPlayer
        -- [FIX-9] WaitForChild KHONG hieu dau "/" nhu duong dan (chi FindFirstChild
        -- moi hieu). Goi WaitForChild("RE/RegisterAttack") la doi ten that cua mot con
        -- truc tiep cua Net, ma no khong co -> cho duyet 10s. Ca 7 cho nhu vay la gan
        -- 1 phut chay trong im lang, nhin giong het treo. Tim() thu FindFirstChild
        -- (hieu duong dan va khong yield) voi ca ten ngan truoc, chi cho 3s neu chua co.
        local function Tim(parent, name)
            local short = string.gsub(name, "^[^/]+/", "")
            return parent:FindFirstChild(name) or parent:FindFirstChild(short) or parent:WaitForChild(short, 3)
        end
        local Modules = Tim(ReplicatedStorage, "Modules")
        local Net = Modules and Tim(Modules, "Net")
        local RegisterAttack = Net and Tim(Net, "RE/RegisterAttack")
        local RegisterHit = Net and Tim(Net, "RE/RegisterHit")
        local ShootGunEvent = Net and Tim(Net, "RE/ShootGunEvent")
        local GunValidator = Tim(ReplicatedStorage, "Remotes")
        GunValidator = GunValidator and Tim(GunValidator, "Validator2")
        if not (Modules and Net and RegisterAttack and RegisterHit and ShootGunEvent and GunValidator) then
            print("[FIX-9] Thieu Modules/Net/RegisterAttack/RegisterHit/ShootGunEvent/Validator2 -> van chay tiep")
        end
        local Modules = game.ReplicatedStorage.Modules
        local Net = Modules and Modules.Net
        local Register_Hit = Net and Tim(Net, "RE/RegisterHit")
        local Register_Attack = Net and Tim(Net, "RE/RegisterAttack")
        local Funcs = {}
        -- [FIX-13] PO tu sanglove-sea1.lua:3194-3219. FastAttackLoop goi ham nay moi
        -- 0.06s; truoc day no quet workspace.Enemies khong cache va index truc tiep
        -- (khong co Enemies la loi). Nay cache 0.2s + FindFirstChild truoc.
        local lastBladeScan, cachedBladeHits = 0, {}
        function GetAllBladeHits()
            local now = tick()
            if now - lastBladeScan < 0.2 and #cachedBladeHits > 0 then
                return cachedBladeHits
            end
            lastBladeScan = now
            cachedBladeHits = {}
            local myChar = game.Players.LocalPlayer.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local myPos = myHrp and myHrp.Position
            if not myPos then return cachedBladeHits end
            local enemies = workspace:FindFirstChild("Enemies")
            if enemies then
                for _, v in pairs(enemies:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                        if (v.HumanoidRootPart.Position - myPos).Magnitude <= 65 then
                            table.insert(cachedBladeHits, v)
                        end
                    end
                end
            end
            return cachedBladeHits
        end
        function Getplayerhit()
            local bladehits = {}
            local myChar = game.Players.LocalPlayer.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local myPos = myHrp and myHrp.Position
            if not myPos then return bladehits end
            local chars = workspace:FindFirstChild("Characters")
            if chars then
                for _, v in pairs(chars:GetChildren()) do
                    if
                        v.Name ~= game.Players.LocalPlayer.Name and v:FindFirstChild("Humanoid") and
                            v:FindFirstChild("HumanoidRootPart") and
                            v.Humanoid.Health > 0 and
                            (v.HumanoidRootPart.Position - myPos).Magnitude <= 65
                     then
                        table.insert(bladehits, v)
                    end
                end
            end
            return bladehits
        end

        -- [FIX-20] Dong truoc day khai bao lai `local RegisterAttack, RegisterHit` o day,
        -- ma [FIX-9] da tim thay that o phia tren -> shadow bang nil, Funcs:Attack luc nao
        -- cung FireServer tren nil, loi bi pcall an -> danh khong mat mau. sea3:3361 chi
        -- dung require de LAP DAY khi con thieu, khong khai bao lai.
        pcall(
            function()
                if Net and Net:IsA("ModuleScript") and (not RegisterAttack or not RegisterHit) then
                    local netMod = safe_require(Net, 2)
                    if type(netMod) == "table" and type(netMod.RemoteEvent) == "function" then
                        if not RegisterAttack then
                            pcall(function() RegisterAttack = netMod:RemoteEvent("RegisterAttack", true) end)
                        end
                        if not RegisterHit then
                            pcall(function() RegisterHit = netMod:RemoteEvent("RegisterHit", true) end)
                        end
                    end
                end
            end
        )
        print(
            "[FIX-20] RegisterAttack = " ..
                tostring(RegisterAttack) .. " | RegisterHit = " .. tostring(RegisterHit)
        )

        print("[BC-C] qua Modules.Net + RegisterAttack/RegisterHit")
        -- [FIX-20] Than ham nay copy nguyen sanglove-sea3.lua:3374-3422 (ban dang danh
        -- mat mau dc): moi FireServer nam trong pcall + kiem tra nil, va no goi "Buso"
        -- (aura) truoc khi danh. Ban goc goi RegisterAttack:FireServer tran lang -> chi
        -- can nil la bi pcall ben FastAttackLoop an het, khong bao gio danh trung.
        function Funcs:Attack()
            pcall(
                function()
                    local char = game:GetService("Players").LocalPlayer.Character
                    if char and not char:FindFirstChild("HasBuso") then
                        local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                        if remotes and remotes:FindFirstChild("CommF_") then
                            remotes.CommF_:InvokeServer("Buso")
                        end
                    end
                end
            )

            local bladehits = {}
            for r, v in pairs(GetAllBladeHits()) do
                table.insert(bladehits, v)
            end
            for r, v in pairs(Getplayerhit()) do
                table.insert(bladehits, v)
            end

            if #bladehits == 0 then
                return
            end

            pcall(
                function()
                    if RegisterAttack then
                        RegisterAttack:FireServer(0)
                    end
                end
            )

            local targetHead = nil
            local targetsTable = {}
            for r, v in pairs(bladehits) do
                if not targetHead and v:FindFirstChild("Head") then
                    targetHead = v.Head
                end
                if v:FindFirstChild("HumanoidRootPart") then
                    table.insert(
                        targetsTable,
                        {
                            [1] = v,
                            [2] = v.HumanoidRootPart
                        }
                    )
                end
            end

            if RegisterHit and targetHead and #targetsTable > 0 then
                pcall(
                    function()
                        RegisterHit:FireServer(targetHead, targetsTable)
                    end
                )
            end
        end

        -- Optimized FastAttack loop with Volt Actor support
        local FastAttackLoop = function()
            while task.wait(.06) do
                if _G.FastAttack == os.time() then
                    pcall(
                        function()
                            Funcs:Attack()
                        end
                    )
                end
            end
        end
        
        if UseVoltActors and Volt and Volt.Actor then
            -- Use Volt Actor to run on separate thread (if available)
            pcall(function()
                local actor = Volt.Actor.new()
                actor:Call(FastAttackLoop)
            end)
        else
            task.spawn(FastAttackLoop)
        end

        function AttackController.Attack(MonResult)
            pcall(
                function()
                    _G.FastAttack = os.time()
                end
            )
        end

        -- [FIX-55] 3 dam may set cua vo dien (noi dung ban cap moi): 3 dam nam
        -- gan nhau va bat buoc danh M1 kiem, dung chieu se khong ton mau. Vi vay
        -- ham nay CHI goi Funcs:Attack (RegisterAttack + RegisterHit = M1 dam
        -- danh), khong bao gio cham toi skill/fruity/gun. Chi can lam 1 lan cho
        -- vo dien v1; xong thi gan co de nhung lan kiem tra sau bo qua.
        function KillThunderClouds()
            if getgenv().ElectricClawCloudsDone then
                return
            end
            local Started = os.time()
            local FirstSighting = nil
            local Equipped = false
            local EmptyRun = 0
            print("[FIX-55] Di tim 3 dam may set (danh M1 kiem)...")
            while os.time() - Started < 180 do
                task.wait(0.1)
                local Nearest, NearestHum = nil, nil
                local Live = 0
                pcall(
                    function()
                        local Roots = {workspace}
                        if workspace:FindFirstChild("Enemies") then
                            table.insert(Roots, workspace.Enemies)
                        end
                        if workspace:FindFirstChild("Map") then
                            table.insert(Roots, workspace.Map)
                        end
                        for _, Root in ipairs(Roots) do
                            for _, Obj in ipairs(Root:GetChildren()) do
                                if string.find(string.lower(Obj.Name), "cloud") then
                                    local Hum = Obj:FindFirstChildOfClass("Humanoid")
                                    local HRP = Obj:FindFirstChild("HumanoidRootPart")
                                    if Hum and HRP and Hum.Health > 0 then
                                        Live = Live + 1
                                        local D = CaculateDistance(HRP.Position)
                                        if not Nearest or D < Nearest then
                                            Nearest, NearestHum = D, HRP
                                        end
                                    end
                                end
                            end
                        end
                    end
                )
                if Nearest then
                    EmptyRun = 0
                    FirstSighting = os.time()
                    if not Equipped then
                        Equipped = true
                        pcall(
                            function()
                                FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Sword")
                            end
                        )
                    end
                    TweenController.Create(NearestHum.Position + Vector3.new(0, 5, 0))
                    if Nearest <= 60 then
                        _G.FastAttack = os.time()
                        pcall(function() Funcs:Attack() end)
                    end
                else
                    EmptyRun = EmptyRun + 1
                    -- Da tung thay may ma 1s lien tiep khong con con nao = diet
                    -- xong (dem lien tuc vi 1 lan an khong du, may co the chua
                    -- kip render).
                    if FirstSighting and EmptyRun >= 10 then
                        print("[FIX-55] 3 dam may set da bi diet het (" .. tostring(os.time() - FirstSighting) .. "s)")
                        getgenv().ElectricClawCloudsDone = true
                        return
                    end
                    -- 12s ma khong thay con nao: ten khong chua "Cloud" hoac may
                    -- chua spawn -> khong chan luong nhan nua.
                    if EmptyRun >= 120 then
                        print("[FIX-55] Khong tim thay dam may set nao trong workspace -> bo qua buoc danh may")
                        getgenv().ElectricClawCloudsDone = true
                        return
                    end
                end
            end
            print("[FIX-55] Het 180s ma dam may van con -> tiep tuc luong nhan vo")
        end

        
        -- Comprehensive Mob Spawn Coordinates Fallback (Chống kẹt/đứng im khi mob chưa render)
        local MobPositionsFallback = {
            -- Sea 3 Mobs
            ["Pirate Millionaire"] = Vector3.new(-373, 75, 5550),
            ["Pistol Billionaire"] = Vector3.new(-470, 75, 5950),
            ["Dragon Crew Warrior"] = Vector3.new(6500, 385, 140),
            ["Dragon Crew Archer"] = Vector3.new(6580, 385, 140),
            ["Female Islander"] = Vector3.new(4650, 745, 100),
            ["Giant Islander"] = Vector3.new(4650, 745, -450),
            ["Marine Commodore"] = Vector3.new(2450, 73, -6800),
            ["Rear Admiral"] = Vector3.new(3100, 73, -6800),
            ["Fishman Raider"] = Vector3.new(-10500, 332, -8700),
            ["Fishman Captain"] = Vector3.new(-10900, 332, -8900),
            ["Forest Pirate"] = Vector3.new(-13400, 332, -7900),
            ["Mythological Pirate"] = Vector3.new(-13550, 470, -6900),
            ["Jungle Pirate"] = Vector3.new(-12100, 332, -10500),
            ["Musketeer Pirate"] = Vector3.new(-13250, 395, -9750),
            ["Reborn Skeleton"] = Vector3.new(-8800, 142, 6000),
            ["Living Zombie"] = Vector3.new(-10150, 142, 5950),
            ["Demonic Soul"] = Vector3.new(-9500, 172, 6150),
            ["Posessed Mummy"] = Vector3.new(-9570, 6, 6150),
            ["Peanut Scout"] = Vector3.new(-2050, 38, -10450),
            ["Peanut President"] = Vector3.new(-2150, 38, -10650),
            ["Ice Cream Chef"] = Vector3.new(-650, 66, -11100),
            ["Ice Cream Commander"] = Vector3.new(-950, 66, -11250),
            ["Cookie Crafter"] = Vector3.new(-2350, 38, -12100),
            ["Cake Guard"] = Vector3.new(-1600, 38, -12300),
            ["Baking Staff"] = Vector3.new(-1850, 38, -13000),
            ["Head Baker"] = Vector3.new(-2200, 38, -12950),
            ["Cocoa Warrior"] = Vector3.new(200, 75, -12400),
            ["Chocolate Bar Battler"] = Vector3.new(650, 75, -12600),
            ["Sweet Thief"] = Vector3.new(-100, 75, -12600),
            ["Candy Rebel"] = Vector3.new(-350, 75, -12900),
            ["Candy Pirate"] = Vector3.new(-1350, 14, -14600),
            ["Snow Demon"] = Vector3.new(-950, 14, -14600),
            ["Sun-kissed Warrior"] = Vector3.new(-16250, 55, 1000),
            ["Isle Outlaw"] = Vector3.new(-16100, 55, -500),
            ["Island Boy"] = Vector3.new(-16800, 55, -1000),
            ["Sun-kissed Champion"] = Vector3.new(-17200, 55, 500),
            ["Deepsea Raider"] = Vector3.new(11500, -2138, 9500),
            ["Ocean Prophet"] = Vector3.new(11400, -2138, 10200),
            ["Abyssal Sentinel"] = Vector3.new(11600, -2138, 10600),
            ["Grand Devotee"] = Vector3.new(11850, -2138, 10800),
            -- Sea 2 Mobs
            ["Raider"] = Vector3.new(-760, 50, 2400),
            ["Mercenary"] = Vector3.new(-950, 50, 2600),
            ["Swan Pirate"] = Vector3.new(700, 120, 1200),
            ["Factory Staff"] = Vector3.new(400, 75, -300),
            ["Marine Lieutenant"] = Vector3.new(-2800, 75, -3000),
            ["Marine Captain"] = Vector3.new(-3100, 75, -3200),
            ["Zombie"] = Vector3.new(-5600, 50, -800),
            ["Vampire"] = Vector3.new(-6000, 50, -1200),
            ["Snow Trooper"] = Vector3.new(600, 400, -5300),
            ["Winter Warrior"] = Vector3.new(1200, 450, -5300),
            ["Lab Subordinate"] = Vector3.new(-5800, 50, -4500),
            ["Horned Warrior"] = Vector3.new(-6400, 50, -5800),
            ["Magma Ninja"] = Vector3.new(-5400, 50, -5900),
            ["Lava Pirate"] = Vector3.new(-5200, 50, -4800),
            ["Ship Deckhand"] = Vector3.new(1000, 130, 33000),
            ["Ship Engineer"] = Vector3.new(900, 130, 33000),
            ["Ship Steward"] = Vector3.new(900, 130, 33500),
            ["Ship Officer"] = Vector3.new(900, 180, 33300),
            ["Arctic Warrior"] = Vector3.new(6000, 30, -6200),
            ["Snow Lurker"] = Vector3.new(5500, 30, -6800),
            ["Sea Soldier"] = Vector3.new(-3000, 50, -10000),
            ["Water Fighter"] = Vector3.new(-3400, 50, -10500)
        }

CombatController = {
            GRAB = true,
            GRAB_DISTANCE = SeaIndex == 1 and 250 or 350,
            MAX_ATTACK_DURATION = 3,
            MAX_ATTACK_DURATION_2 = 60,
            LEVITATE_TIME = 1,
            CurrentIndex = 1
        }
        
        LastFound = os.time()
        -- save center pos vao attribute cua con mob r set de cho do bi move idk

        function CombatController.Grab(MobName)
            pcall(sethiddenproperty, game.Players.LocalPlayer, "SimulationRadius", math.huge)
            if not CombatController.GRAB or GrabDebounce == os.time() then
            end
            GrabDebounce = os.time()

            local MidPoint, Count = Vector3.zero, 0
            ForcePosition = nil
            local MobsTable = {}

            for _, Mon in Services.Workspace.Enemies:GetChildren() do
                if Mon.Name == MobName then
                    if --not Mon:GetAttribute("IsGrabbedreci") and
                        Mon:FindFirstChild("Humanoid") and Mon:FindFirstChild("HumanoidRootPart") and
                            Mon.Humanoid.Health > 0 then
                        local MonPosition = Mon.HumanoidRootPart.Position
                        --print("isnetworkowner", isnetworkowner(Mon.PrimaryPart))
                        if MonPosition and isnetworkowner(Mon.PrimaryPart) then
                            if
                                not ForcePosition or
                                    CaculateDistance(MonPosition, ForcePosition) < CombatController.GRAB_DISTANCE
                             then
                                Count = Count + 1
                                Mon:SetAttribute("OldPosition", Mon:GetAttribute("OldPosition") or MonPosition)
                                MidPoint = MidPoint + MonPosition
                                ForcePosition = ForcePosition or MonPosition

                                table.insert(MobsTable, Mon)
                            end
                        end
                    end
                end
            end
            MidPoint = CFrame.new(MidPoint / Count)

            table.foreach(
                MobsTable,
                function(_, ChildInstance)
                    (function()
                        if ChildInstance:GetAttribute("IgnoreGrab") then
                            return
                        end
                        if (ChildInstance:GetAttribute("FailureCount") or 0) > 7 then
                            return
                        end
                        --[[ChildInstance.Humanoid.PlatformStand = true
                ChildInstance.Humanoid.Sit = true
                ChildInstance.HumanoidRootPart.CanCollide = false ]]
                        local RootPart = ChildInstance:FindFirstChild("HumanoidRootPart")
                        local BodyVelocity = RootPart:FindFirstChild("FarmingVelocity")
                        if not BodyVelocity then
                            BodyVelocity = Instance.new("BodyVelocity")
                            BodyVelocity.Name = "FarmingVelocity"
                            BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                            BodyVelocity.Parent = RootPart
                        end

                        BodyVelocity.Velocity = Vector3.new(0, 0, 0)

                        local BodyPosition = RootPart:FindFirstChild("FarmingPosition")
                        if not BodyPosition then
                            BodyPosition = Instance.new("BodyPosition")
                            BodyPosition.Name = "FarmingPosition"
                            BodyPosition.MaxForce = Vector3.new(4000, 4000, 4000)
                            BodyPosition.P = 4.12
                            BodyPosition.D = 1000
                            BodyPosition.Parent = RootPart
                        end
                        ChildInstance:SetAttribute("IsGrabbed", true)
                        ChildInstance.HumanoidRootPart.CFrame = MidPoint

                        ChildInstance:SetAttribute("MidPoint", MidPoint)
                    end)()
                end
            )
        end


        function Sort1(N)
            return N and N:FindFirstChild("HumanoidRootPart") and
                math.floor(CaculateDistance(N.HumanoidRootPart.CFrame))
        end

        function CombatController.Search(MobTable)
            local Lists = {}
            local Found = false
            for _, ChildInstance in GetMonAsSortedRange() do
                if
                    table.find(MobTable, ChildInstance.Name) and ChildInstance:FindFirstChild("Humanoid") and
                        ChildInstance.Humanoid.Health > 0
                 then
                    if (ChildInstance:GetAttribute("FailureCount") or 0) < 3 then
                        Found = true
                        table.insert(Lists, ChildInstance)
                    end
                end
            end

            table.sort(
                Lists,
                function(a, b)
                    return Sort1(a) < Sort1(b)
                end
            )

            if Found then
                local Mon1 = Lists[1]
                return Mon1
            end

            for _, ChildName in MobTable do
                local MonResult2 = game.ReplicatedStorage:FindFirstChild(ChildName)
                if MonResult2 then
                    return MonResult2
                end
            end
        end

        function CombatController.Attack(MobTable, NearbyHit, Range, Callback)
            -- Cache GuideModule env để tránh gọi getsenv nhiều lần
            -- [FIX-49] Ban cu goi GetGuideEnv HAI lan moi frame (lan 1 trong
            -- pcall de thu, lan 2 de lay gia tri). Khong duoc bo pcall:
            -- GetGuideEnv la `local function` khai bao o 3639, TUC LA SAU ham
            -- Attack nay, nen tai day ten no van la GLOBAL = nil; goi thang
            -- khong pcall se "attempt to call a nil value" moi frame.
            local GuideEnv = nil
            pcall(function()
                GuideEnv = GetGuideEnv()
            end)

            if ScriptStorage.Tools["Sweet Chalice"] and GuideEnv and GuideEnv["_G"]["InCombat"] then
                TweenController.Create(Vector3.new(0, 0, 0))
                return
            end

            sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
            MobTable = type(MobTable) == "string" and {MobTable} or (MobTable or {})

            -- [FIX-60] MonResult KHONG co chu "local" o dau file -> no la bien
            -- TOAN CUC. Ma vong chinh chay RefreshTasksData roi MOI chay
            -- MeleesController.Start, va melee goi Attack("Electro") /
            -- Attack("Black Leg") - ten VO, khong phai ten guai -> Search tra
            -- nil -> ghi MonResult = nil xen vao giua luc coroutine dang farm
            -- (vong while task.wait(0.1) doc lai MonResult moi buoc) ->
            -- "attempt to index a nil value" lam chet coroutine cua quest ->
            -- nhan vat dung im, va DevConsole in ra xau loi. Gan "local" de moi
            -- lan Attack co target cua rieng no, lenh nay khong ghi de lenh kia.
            local MonResult

            for _, Child in (MobTable) do
                local ChildName = tostring(Child)
                if
                    ChildName == "Deandre" or ChildName == "Urban" or
                        ChildName == "Diablo" and (os.time() - (LastFire12 or 0)) > 180
                 then
                    LastFire12 = os.time()
                    Remotes.CommF_:InvokeServer("EliteHunter")
                end

                if NearbyHit then
                    local Mon = GetMonAsSortedRange()[1]

                    local MonPosition = Mon and Mon:FindFirstChild("HumanoidRootPart") and Mon.HumanoidRootPart.Position
                    if MonPosition and CaculateDistance(MonPosition) < Range then
                        MonResult = Mon
                    end
                else
                    MonResult = CombatController.Search(MobTable)
                end

                if MonResult then
                    LastFound = os.time()
                    local Count, Debounce = 0, os.time()
                    local Count2, Debounce = 0, os.time()
                    -- Optimize: Add delay to reduce FPS impact
                    while task.wait(0.1) do
                        if _G.Stop then
                            return
                        end

                        -- Cache lại InCombat mỗi lần loop để kiểm tra trạng thái combat
                        if ScriptStorage.Tools["Sweet Chalice"] and GuideEnv and GuideEnv["_G"]["InCombat"] then
                            TweenController.Create(Vector3.new(0, 0, 0))
                            return
                        end

                        local MobHumanoid = MonResult:FindFirstChild("Humanoid")
                        local MobHumanoidRootPart = MonResult:FindFirstChild("HumanoidRootPart")

                        if not MobHumanoid or MobHumanoid.Health <= 0 then
                            if MonResult.Name == "Don Swan" then
                                Storage:Set("SwanDefeated", true)
                                
                            end
                            break
                        end

                        TweenController.Create(
                            CaculateCircreDirection(MobHumanoidRootPart.CFrame) + Vector3.new(0, 35, 0)
                        )

                        if CaculateDistance(MobHumanoidRootPart.Position + Vector3.new(0, 35, 0)) < 150 then
                            CombatController.Grab(Child or "")
                            if MonResult.Name ~= "Core" then
                                if
                                    ScriptStorage.PlayerData.Level > 100 and
                                        Count2 >= CombatController.MAX_ATTACK_DURATION_2 and
                                        MobHumanoid.Health - MobHumanoid.MaxHealth == 0
                                 then
                                    SetTask(
                                        "SubTask",
                                        "Hop Server - Mob Health Unchanged ( " ..
                                            MobHumanoid.Health .. " / " .. MobHumanoid.MaxHealth .. ")"
                                    )
                                    alert("Stuck", "Mob health unchanged")
                                    _G.Stop = true
                                    SafeRejoinOrHop("Rejoin")
                                    -- [FIX-44] _G.Stop trong ca file CHI duoc BAT
                                    -- (o day), khong co bat ky cho nao TAT no. Ma
                                    -- RefreshTasksData (6811) mo dau bang
                                    -- `if _G.Stop then return end` -> toan bo hub
                                    -- dung han. SafeRejoinOrHop chi la
                                    -- TeleportService:Teleport trong pcall: neu no
                                    -- bi chan thi khong co load lai nao ca, va
                                    -- nhan vat dung im mai mai = "danh xong het
                                    -- nhiem vu do la ko thay nhan nua". Cho no 15s
                                    -- roi tu hoi, farm tiep.
                                    task.spawn(
                                        function()
                                            task.wait(15)
                                            if _G.Stop then
                                                _G.Stop = false
                                                print("[FIX-44] Rejoin khong xay ra -> mo khoa _G.Stop, farm tiep")
                                            end
                                        end
                                    )
                                    return

                                end

                              
                                if
                                    Count >= CombatController.MAX_ATTACK_DURATION and
                                        MobHumanoid.Health - MobHumanoid.MaxHealth == 0
                                 then
                                    Count = 0

                                    local OldPosition = MonResult:GetAttribute("OldPosition")

                                    if OldPosition then
                                        MonResult:SetPrimaryPartCFrame(CFrame.new(OldPosition))
                                        MonResult:SetAttribute("IgnoreGrab", true)
                                        MonResult:SetAttribute(
                                            "FailureCount",
                                            (MonResult:GetAttribute("FailureCount") or 0) + 1
                                        )
                                        alert(
                                            "Failed to attack",
                                            "Returning to the old position ( #" ..
                                                MonResult:GetAttribute("FailureCount") .. " )"
                                        )
                                       MonResult.HumanoidRootPart.CFrame = (CFrame.new(OldPosition))
                                        task.wait()

                                        return
                                    end
                                end
                            end
                         
                            FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call(
                                    ScriptStorage.ForceToUseSword and "Sword" or "Melee"
                                )

                            AttackController:Attack(MonResult)
                            if os.time() ~= Debounce then
                                Debounce = os.time()

                                Count = Count + 1
                                Count2 = Count2 + 1
                            end
                            if Count > 30 and MonResult.Name ~= "Core" then
                                alert("Take more than 30s to attack, cancelling")
                                break
                            end
                       
                        end
                    end
                elseif not NearbyHit then
                    if (os.time() - LastFound) > 200 then
                        alert("KUN", "Error while farming, rejoin")
                        SafeRejoinOrHop("Rejoin")
                        return
                    end

                    local Region = ScriptStorage.MobRegions[Child]

                    if not Region then
                        local Inst =
                            Services.Workspace.Enemies:FindFirstChild(Child) or
                            game.ReplicatedStorage:FindFirstChild(Child)

                        Region = Inst and {Inst:GetPrimaryPartCFrame().p}
                    end

                    if not Region and MobPositionsFallback and MobPositionsFallback[Child] then
                        Region = {MobPositionsFallback[Child]}
                    end

                    if not Region then
                        -- [FIX-49] Day la ly do lag thu hai: quet TOAN BO cay
                        -- workspace that `workspace:GetDescendants()` moi frame.
                        -- No chay lien tuc khi ten duoc truyen vao Attack khong
                        -- co trong MobRegions/MobPositionsFallback, ma
                        -- MeleesController thi goi Attack("Black Leg") - ten VO,
                        -- khong phai ten guai - nen khong bao gio thay, va lan
                        -- quet nao cung dat gia. Ket qua that bai duoc giu 15s.
                        local ProbeKey = tostring(Child)
                        MobSpawnProbeCache = MobSpawnProbeCache or {}
                        local ProbeNow = os.clock()
                        local Cached = MobSpawnProbeCache[ProbeKey]
                        if not Cached or ProbeNow - (Cached.At or 0) >= 15 then
                            Cached = {At = ProbeNow, Hit = nil}
                            MobSpawnProbeCache[ProbeKey] = Cached
                            pcall(function()
                                for _, spawnObj in pairs(workspace:GetDescendants()) do
                                    if spawnObj.Name == Child or (spawnObj:IsA("BasePart") and string.find(spawnObj.Name, Child)) then
                                        Cached.Hit = {spawnObj.Position}
                                        break
                                    end
                                end
                            end)
                        end
                        Region = Cached.Hit
                    end

                    if not Region then
                        -- Thay vì report và đứng im, tiếp tục thử quái tiếp theo trong list
                        return
                    end

                    local CurrentPosition

                    if not Region[CombatController.CurrentIndex] then
                        CombatController.CurrentIndex = 1
                    end

                    CurrentPosition = Region[CombatController.CurrentIndex]

                    local Count2 = os.time()
                    -- [FIX-41] BO buoc doi sang diem spawn ke tiep khi da toi noi.
                    -- Do chinh la "bay long vong chang mat" ban bao: bai guai da
                    -- chet het -> ve den diem 1 lai bi day sang diem 2, 3, ... roi
                    -- vong sau lai quay lai. Script dang chay dc luon gi
                    -- CurrentIndex o diem dau tien va chi bay lai DUNG mot cho do
                    -- (attachment 3853-3867), het guai thi dung cho respawn.
                    -- [FIX-43] Them buoc: da o trong bai guai thi HOAN TOAN khong
                    -- phat lenh bay nua. Ban cu moi vong khong tim thay con nao la
                    -- goi lai TweenController; lenh bay bi khoi dong lai lien tuc
                    -- nen nhan vat lac/loan bay khong dung trong bai (ban bao "cu
                    -- bay danh met"). Het guai thi DUNG IM cho respawn.
                    if CaculateDistance(CurrentPosition) > 300 then
                        TweenController.Create(CurrentPosition + Vector3.new(0, 35, 35))
                    end
                end
            end
        end

        LevelFarmTTL = 0
        LastTravel = os.time()

        
local function GetGuideEnv()
    local ok, env = pcall(function()
        if type(getsenv) == "function" then
            local lp = game:GetService("Players").LocalPlayer
            local clientGuide = lp and lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("Main") and lp.PlayerGui.Main:FindFirstChild("Guide")
            if clientGuide then
                return getsenv(clientGuide)
            end
        end
    end)
    return ok and env or nil
end

local function GetExpBoost()
    local env = GetGuideEnv()
    if env and env._G and env._G.ServerData and env._G.ServerData.ExpBoost then
        return env._G.ServerData.ExpBoost
    end
    return 0
end


FunctionsHandler = {
            Initalized = false
        }

        print(3000)
        setmetatable(
            FunctionsHandler,
            {
                __index = function(Self, Index)
                    QueryResult = rawget(Self, Index)

                    if not QueryResult then
                        return {
                            Register = function(Coditional)
                                if Coditional == false then
                                    return
                                end

                                Result = {
                                    CacheListener = {},
                                    RealCache = {},
                                    Methods = {},
                                    Constants = {},
                                    Events = {},
                                    Initalized = true
                                }

                                function Result.RegisterMethod(Self, Name, Function)
                                    Self.Methods[Name] = {
                                        Name = Name,
                                        Callback = Function,
                                        Call = function(Self, ...)
                                            return Self.Callback(...)
                                        end,
                                        Events = {}
                                    }
                                    return true
                                end

                                setmetatable(
                                    Result.Constants,
                                    {
                                        __newindex = function()
                                            assert(false, "cannot change constant value!")
                                        end
                                    }
                                )

                                if Self.Constants[Key] then
                                    function Result.SaveConstant(Self, Key, Value)
                                        return assert(false, "constant name was used before!")
                                    end

                                    rawset(Self.Constants, Key, Value)
                                end

                                function Result.Set(Self, Key, Value)
                                    Self.CacheListener[Key] = Value
                                    return Value
                                end

                                function Result.Get(Self, Index)
                                    return Self.Constants[Index] or Self.RealCache[Index]
                                end

                                function Result.AddVariableChangeListener(Self, Index, Callback)
                                    Self.Events[Index] = Callback
                                end

                                Result.CacheListener.__parent = Result

                                setmetatable(
                                    Result.CacheListener,
                                    {
                                        __newindex = function(Self, Key, Value)
                                            _ = Self.__parent.Events[Key] and Self.__parent.Events[Key](Key, Value)

                                            Self.__parent.RealCache[Key] = Value
                                        end
                                    }
                                )

                                FunctionsHandler[Index] = Result
                            end,
                            Initalized = false
                        }
                    end

                    return QueryResult
                end
            }
        )

        function FunctionsHandler.SynchorizeUntilModuleLoaded(Self, Timeout)
            local StartTime = os.time()

            while not Self.Initalized do
                task.wait()
                local Difference = os.time() - StartTime

                assert(not (Timeout and Difference > Timeout), "timed out")
            end
        end

        function GetCurrentClaimQuest(RawResponse)
            -- [FIX-32] Loi cu: ham nay index truc tiep
            -- PlayerGui.Main.Quest.Container.QuestTitle.Title, thieu 1 node la
            -- throw; ma RefreshTasksData goi Start trong pcall (6261) nen khong
            -- in ra gi ca -> nhan quest xong dung im, khong hieu tai sao.
            -- Nay tim bang FindFirstChild + pcall, khong doc chu tren HUD
            -- (client nay label la TIENG VIET nen moi so sanh voi chu TIENG
            -- ANH deu liu ra nil).
            local title, raw
            -- [FIX-33] Loc cua label (lay tu script dang chay dc, 2553): label
            -- "0/8" hoac "1500 Exp" KHONG phai ten quest. Neu khong loc thi
            -- FindFirstChildWhichIsA("TextLabel") hay cham trung label tien do,
            -- title luon truthy -> bot tuong la luk nao cung dang co quest ->
            -- chi Attack(MonName) roi dung im, khong bao gio di nhan.
            local function IsTitleText(t)
                if type(t) ~= "string" or t == "" then
                    return false
                end
                if string.match(t, "^%s*%(?%d+%s*/%s*%d+%)?%s*$") then
                    return false
                end
                if string.match(t, "^%d+$") then
                    return false
                end
                if string.match(t, "^%s*%$?[%d,]+%s*[Ee]xp") or string.match(t, "^%s*%$?[%d,]+%s*[Bb]eli") then
                    return false
                end
                return true
            end

            pcall(function()
                local pgui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
                local main = pgui and pgui:FindFirstChild("Main")
                local quest = main and main:FindFirstChild("Quest")
                if not quest or quest.Visible == false then
                    return
                end
                local container = quest:FindFirstChild("Container") or quest
                local titleNode = container:FindFirstChild("QuestTitle") or container
                -- Thu theo do tin cay (khongquet toan bo cay GUI vi ham nay
                -- duoc goi moi vong RefreshTasksData): Title -> chinh
                -- QuestTitle -> TextLabel dau tien cua QuestTitle -> cua
                -- Container.
                local candidates = {}
                if titleNode then
                    candidates[#candidates + 1] = titleNode:FindFirstChild("Title")
                    candidates[#candidates + 1] = titleNode
                    candidates[#candidates + 1] = titleNode:FindFirstChildWhichIsA("TextLabel")
                end
                candidates[#candidates + 1] = container:FindFirstChildWhichIsA("TextLabel")
                for _, lbl in candidates do
                    if lbl and lbl:IsA("TextLabel") and IsTitleText(lbl.Text) then
                        raw = lbl.Text
                        break
                    end
                end
                if raw then
                    -- Lay phan ten tru "(0/8)": chi de kiem co quest, khong so
                    -- sanh chu nghia la (HUD client nay la tieng Viet).
                    title = string.match(raw, "^%s*(.-)%s*%(%d+%s*/%s*%d+%)%s*$") or raw
                end
            end)
            if RawResponse then
                return raw
            end
            return title, raw
        end

 
        -- LP Controller

        FunctionsHandler.LocalPlayerController.Register()
        -- Exp Redeem

        FunctionsHandler.ExpRedeem:Register()

        -- Level Farm

        FunctionsHandler.LevelFarm:Register()

        -- Items / Sword

        FunctionsHandler.Saber:Register()
        FunctionsHandler.Rengoku:Register()
        FunctionsHandler.Yama:Register()
        FunctionsHandler.Tushita:Register()
        FunctionsHandler.SpikeyTrident:Register()
        FunctionsHandler.SharkAchor:Register()
        FunctionsHandler.Pole:Register()
        FunctionsHandler.FoxLamp:Register()
        FunctionsHandler.DarkDagger:Register()
        FunctionsHandler.Canvander:Register()
        FunctionsHandler.BuddySword:Register()
        FunctionsHandler.HallowScythe:Register()

        -- Items / Guns

        FunctionsHandler.AcidumRifle:Register()
        FunctionsHandler.Kabucha:Register()
        FunctionsHandler.VenomBow:Register()
        FunctionsHandler.SoulGuitar:Register()
        FunctionsHandler.DragonStorm:Register()

        -- Items / Etc

        FunctionsHandler.InsictV2:Register()
        FunctionsHandler.RainbowSaviour:Register()

        -- Puzzles / First Sea

        FunctionsHandler.DarkBladeV2:Register()
        FunctionsHandler.SecondSeaPuzzle:Register()

        -- Puzzles / Second Sea

        FunctionsHandler.ColosseumPuzzle:Register()
        FunctionsHandler.Trevor:Register()
        FunctionsHandler.EvoRace:Register()
        FunctionsHandler.Wenlocktoad:Register()
        FunctionsHandler.DarkBladeV3:Register()
        FunctionsHandler.ThirdSeaPuzzle:Register()

        -- Puzzles / Third Sea

        FunctionsHandler.DojoQuest:Register()
        FunctionsHandler.RaceAwakening:Register()
        FunctionsHandler.PirateRaid:Register()

        -- Functions / Raid
        

        FunctionsHandler.RaidController:Register()

        
        -- Functions / Auto Melees

        FunctionsHandler.MeleesController:Register()

        FunctionsHandler.Superhuman:Register()
        FunctionsHandler.DeathStep:Register()
        FunctionsHandler.SharkmanKarate:Register()
        FunctionsHandler.ElectricClaw:Register()
        FunctionsHandler.DragonTalon:Register()
        FunctionsHandler.Godhuman:Register()

        -- Functions / Boss Task

        FunctionsHandler.BossesTask:Register()
        FunctionsHandler.SpecialBossesTask:Register()
        -- Functions / CollectDrops
        FunctionsHandler.CollectDrops:Register()

        -- Functions / UtillyItemsActivitation

        FunctionsHandler.UtillyItemsActivitation:Register()

        -- Exp Redeem

        FunctionsHandler.ExpRedeem:RegisterMethod(
            "Refresh",
            function()
                --Report("Typeof: " .. typeof(Storage))

                return ScriptStorage.PlayerData.Level < MaxLevel and
                    GetExpBoost() == 0 and
                    not Storage.Get(Storage, "IsCodesRanOut")
            end
        )

        FunctionsHandler.ExpRedeem:RegisterMethod(
            "Start",
            function()
                local Code = ({
                    "BANEXPLOIT",
                    "NOMOREHACK",
                    "WildDares",
                    "BossBuild",
                    "GetPranked",
                    "EARN_FRUITS",
                    "Sub2UncleKizaru",
                    "FIGHT4FRUIT",
                    "kittgaming",
                    "TRIPLEABUSE",
                    "Sub2CaptainMaui",
                    "Sub2Fer999",
                    "Enyu_is_Pro",
                    "Magicbus",
                    "JCWK",
                    "Starcodeheo",
                    "Bluxxy",
                    "SUB2GAMERROBOT_EXP1",
                    "Sub2NoobMaster123",
                    "Sub2Daigrock",
                    "Axiore",
                    "TantaiGaming",
                    "StrawHatMaine",
                    "Sub2OfficialNoobie",
                    "TheGreatAce",
                    "SEATROLLING",
                    "24NOADMIN",
                    "ADMIN_TROLL",
                    "NEWTROLL",
                    "SECRET_ADMIN",
                    "staffbattle",
                    "NOEXPLOIT",
                    "NOOB2ADMIN",
                    "CODESLIDE",
                    "fruitconcepts"
                })

                for Index, Promo in Code do
                    SetTask("MainTask", "Code Redemption | " .. Promo .. " | Redeeming...")
                    local Response = (Remotes.Redeem:InvokeServer(Promo))
                    task.wait()
                    SetTask("MainTask", "Code Redemption | " .. Promo .. " | " .. (Response or "Failed"))
                    if GetExpBoost() == 0 then
                        if Response and string.find(Response, "SUCC") then
                            return SetTask("MainTask", "Code Redemption | X2 Exp Boost Activated!") and task.wait(1)
                        end
                    else
                        return
                    end
                end

                Storage:Set("IsCodesRanOut", 1)
                Storage:Save()
            end
        )

        -- Level Farm

        FunctionsHandler.LevelFarm:RegisterMethod(
            "Refresh",
            function()
                -- Don't run LevelFarm if currently in raid process
                if FunctionsHandler.RaidController:Get("IsInRaidProcess") then
                    return
                end
                
                local Level = ScriptStorage.PlayerData.Level
                if Level < 10 then
                    return 1
                elseif Level < 70 then
                    return 2
                else
                    return 4
                end
                return true
            end
        )

        FunctionsHandler.LevelFarm:RegisterMethod(
            "Start",
            function(Level)
                -- if SeaIndex == 1 then 
                --     if getrenv()._G.ServerData.ExpBoost - (tick() - getrenv()._G.ServerData.ExpBoostTick) < 60*60 then 
                --         local args = {
                --             [1] = "Purchase",
                --             [2] = "15minDouble"
                --         }
                        
                --         game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Celebration"):InvokeServer(unpack(args))
                --     end
                -- else 
                --     if getrenv()._G.ServerData.ExpBoost - (tick() - getrenv()._G.ServerData.ExpBoostTick) < 0 then 
                --         local args = {
                --             [1] = "Purchase",
                --             [2] = "15minDouble"
                --         }
                        
                --         game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Celebration"):InvokeServer(unpack(args))
                --     end
                -- end
                    
                -- Don't buy bones if currently in raid process
                if SeaIndex == 3 then
                    if (ScriptStorage.Backpack.Bones or {Count = 0}).Count >= 50 then
                        if os.time() > (BonesCooldown or 0) then
                            local _, _, State, Message = Remotes.CommF_:InvokeServer("Bones", "Check")
                            print("State", State, "Message", Message)
                            if tonumber(State or 1) == 0 then
                                local SplitedNum = Split(Message, ":")
                                local SecondsLeft = ((tonumber(SplitedNum[1]) * 60) + tonumber(SplitedNum[2])) * 60
                                BonesCooldown = os.time() + SecondsLeft
                                print("Next", BonesCooldown)
                            else
                                print("Roll")
                                if CaculateDistance(Vector3.new(-8727, 143, 6249)) > 30 then
                                    TweenController.Create(Vector3.new(-8727, 143, 6249))
                                    return task.wait(2)
                                end
                                Remotes.CommF_:InvokeServer("Bones", "Buy", 1, 1)
                            end
                        end
                    end
                end

                local PlayerLevel = ScriptStorage.PlayerData.Level
                if GodHumanFlag then
                    -- [FIX-22] [FIX-21] do ra "Magma Ore=nil/20 | Fish Tail=nil/20 | ..."
                    -- tuc la ScriptStorage.Backpack KHONG CO ten nao trong 4 thu nguyen
                    -- lieu, du UI Stash cua ban dang hien 43/99/28/99. Lenh getInventory chi
                    -- duoc goi DUNG 1 LAN luc init (6165) va khi CommE bao "Item", nen no
                    -- luon la {} -> Dieu kien < 20 thoa man mai mai, bot farm Godhuman
                    -- vo tan va nhay qua lai Sea 2 <-> Sea 3. Nay nap lai toi da 1 lan
                    -- / 20s va in ra de do.
                    if not GodHumanDump or os.time() - GodHumanDump > 20 then
                        GodHumanDump = os.time()
                        pcall(RefreshInventory)
                        local Parts, Count = {}, 0
                        for _ in pairs(ScriptStorage.Backpack or {}) do
                            Count = Count + 1
                        end
                        for Name, Data in GodhumanMaterials do
                            local Item = ScriptStorage.Backpack and ScriptStorage.Backpack[Name]
                            Parts[#Parts + 1] =
                                Name .. "=" .. tostring(Item and Item.Count) .. "/" .. tostring(Data[1])
                        end
                        print("[FIX-22] Backpack has " .. Count .. " items | " .. table.concat(Parts, " | "))
                    end

                    local Material, MaterialData
                    -- [FIX-26] Cach cu: "khong doc duoc" bi hieu la "thieu".
                    -- Tren client nay getInventory khong tra ve muc nao, ca 4 thu
                    -- vat luon bi coi la thieu -> bot farm Godhuman vo tan va nhay
                    -- Sea 2 <-> Sea 3, trong khi Stash da du (43/99/28/99).
                    -- Nay chi duoc farm khi THUC SU doc duoc danh sach nguyen lieu;
                    -- khong doc duoc thi bo qua Godhuman 5 phut roi thu lai,
                    -- tra quyen cho LevelFarm.
                    local Readable = 0
                    for MaterialName in GodhumanMaterials do
                        if ScriptStorage.Backpack and ScriptStorage.Backpack[MaterialName] then
                            Readable = Readable + 1
                        end
                    end

                    if Readable == 0 then
                        GodHumanRetryAt = os.time() + 300
                        GodHumanFlag = false
                        print(
                            "[FIX-26] getInventory khong doc duoc nguyen lieu -> bo qua Godhuman den " ..
                                tostring(GodHumanRetryAt) .. ", quay lai LevelFarm"
                        )
                        return
                    end

                    getgenv()["     mphm >< <3"] = {}
                    for Mat, MatData in GodhumanMaterials do
                        if (ScriptStorage.Backpack[Mat] or {Count = 0}).Count < MatData[1] then
                            getgenv()["     mphm >< <3"] = {Mat, MatData}
                        end
                    end
                    Material, MaterialData = unpack(getgenv()["     mphm >< <3"])

                    if Material then
                        if SeaIndex ~= MaterialData[2] then
                            alert("Material - " .. Material, "Travelling sea " .. MaterialData[2])
                            SetTask(
                                "MainTask",
                                "Sea Travel | Godhuman Materials | Travelling to Sea " .. MaterialData[2]
                            )

                            Remotes.CommF_:InvokeServer("Travel" .. SeaIndexes[MaterialData[2]])
                            return
                        end

                        SetTask("MainTask", "Material Farming | Godhuman | " .. Material .. " | In Progress" )

                        if PlayerLevel >= MaterialData[4][3] then
                            CombatController.Attack(MaterialData[3])
                        end

                        CombatController.Attack(MaterialData[3])
                    end

                    BuyMelee("Godhuman", true,"Ancient Monk")

                    GodHumanFlag = false
                    return true
                end

                    LastTravel = os.time()
                    if PlayerLevel >= 1500 and (SeaIndex == 2) then
                        
                        if not Services.Workspace.Map.IceCastle.Hall.LibraryDoor:FindFirstChild("PhoeyuDoor")  then
                            

                            Remotes.CommF_:InvokeServer("TravelZou")

                            SetTask("MainTask", "Sea Travel | Teleporting to Third Sea")
                             
                        end
                    elseif PlayerLevel >= 700 and (SeaIndex == 1)  then
                        SetTask("MainTask", "Sea Travel | Teleporting to Second Sea")
                        Remotes.CommF_:InvokeServer("TravelDressrosa")
                    end
                

                if ScriptStorage.Tools["God's Chalice"] and not ScriptStorage.Tools["Mirror Fractal"] then
                    if (ScriptStorage.Backpack["Conjured Cocoa"] or {Count = 0}).Count < 10 then
                        SetTask("MainTask", "Material Farming | Conjured Cocoa | Need 10x | Farming...")
                        CombatController.Attack({"Cocoa Warrior", "Chocolate Bar Battler"})
                        return
                    end
                    Remotes.CommF_:InvokeServer("SweetChaliceNpc")
                end

                if
                    ScriptStorage.Tools["Sweet Chalice"] or
                        (PlayerLevel == MaxLevel and (ScriptStorage.Backpack.Bones or {Count = 0}).Count >= 500)
                 then
                    SetTask("MainTask", "Fragments Farming | Cake Prince | Dough King")

                    if (ScriptStorage.Tools["Sweet Chalice"]) and (not SpawnReflect or os.time() - SpawnReflect > 10) then
                        task.spawn(
                            function()
                                while not ScriptStorage.Enemies["Dough King"] and task.wait() and
                                    ScriptStorage.Tools["Sweet Chalice"] do
                                    SpawnReflect = os.time()
                                    Remotes.CommF_:InvokeServer("CakePrinceSpawner")
                                end
                            end
                        )
                    end

                    CombatController.Attack(
                        {
                            "Head Baker",
                            "Baking Staff",
                            "Cookie Crafter",
                            "Cake Guard"
                        }
                    )

                    if PlayerLevel >= 2200 then
                        local IsAvailabe, CurrentClaimQuest2 = GetCurrentClaimQuest()

                        if IsAvailabe then
                            if not string.find(CurrentClaimQuest2, "Cookie") then
                                QuestManager.AbandonQuest()
                            else
                                Remotes.CommF_:InvokeServer("CakePrinceSpawner")
                                return
                            end
                        else
                            print("Start Quest")

                            local cakeNpc = ScriptStorage.NPCs["Cake Quest Giver 1"] or workspace.NPCs:FindFirstChild("Cake Quest Giver 1") or game.ReplicatedStorage.NPCs:FindFirstChild("Cake Quest Giver 1")
                            local NpcPosition1 = cakeNpc and cakeNpc:GetModelCFrame() or CFrame.new(-2020, 38, -12025)

                            TweenController.Create(NpcPosition1 + Vector3.new(0, 5, 3))
                            if CaculateDistance(NpcPosition1) < 25 then
                                task.wait(0.5)
                                QuestManager.StartQuest("CakeQuest1", 1)
                                task.wait(0.5)
                            end
                            return
                        end
                    end
                    print("attack ohoo")

                    return
                end
                if PlayerLevel == MaxLevel and SeaIndex == 3 then
              if
                    
                        (PlayerLevel == MaxLevel and (ScriptStorage.Backpack.Bones or {Count = 0}).Count >= 500)
                 then
                    SetTask("MainTask", "Fragments Farming | Cake Prince | Dough King")

                    if (not SpawnReflect or os.time() - SpawnReflect > 10) then
                        task.spawn(
                            function()
                                while not ScriptStorage.Enemies["Cake Prince"] and task.wait()  do
                                    SpawnReflect = os.time()
                                    Remotes.CommF_:InvokeServer("CakePrinceSpawner")
                                end
                            end
                        )
                    end

                    CombatController.Attack(
                        {
                            "Head Baker",
                            "Baking Staff",
                            "Cookie Crafter",
                            "Cake Guard"
                        }
                    )

                    
                    print("attack ohoo")

                    return
                end
            end
                -- [FIX-30] DA CAT nhanh "Resource Farming | Bones" (gate cu:
                -- PlayerLevel >= 2025 ... SeaIndex == 3). Ly do:
                --  + Script ban dang chay tren may nay KHONG co nhanh nay. No chi
                --    TIEU Bones (>= 50 -> tween -8727,143,6249 -> InvokeServer
                --    "Bones","Buy",1,1); phan do van con nguyen o 3414-3434.
                --  + Nhanh bi cat nam TRUOC chuoi "if Level == 1/2/4" va ca hai
                --    nhanh con cua no deu `return`, nen no an sat LevelFarm: lv
                --    2721 bi git o day, bay toi NPC Haunted Castle roi dung im
                --    (HUD "Resource Farming | Bones" + DebugLine LevelFarm).
                --  + No nhan HauntedQuest2 roi so title TIENG ANH voi HUD tieng
                --    Viet -> khong bao gio khop nen khong bao gio danh.

                if Level == 1 then
                    SetTask("MainTask", "Level Farming | Skip Mode | Floor " .. Level)
                    CombatController.Attack("Sky Bandit")
                elseif Level == 2 then
                    SetTask("MainTask", "Level Farming | Skip Mode | Floor " .. Level)
                     CombatController.Attack({"Royal Soldier", "Royal Squad"})
                elseif Level == 3 then
                    SetTask("MainTask", "Level Farming | Skip Mode | Floor " .. Level)
                    CombatController.Attack({"Royal Soldier", "Royal Squad"})
                elseif Level == 4 then
                    local MonName, NpcPosition, QuestId, QuestIndex, QuestTitle = QuestManager:GetCurrentQuest()
                    -- [FIX-35] Dung HasActiveQuest (co thoi gian an han sau khi
                    -- nhan) thay vi chi doc ten quest tren HUD: ban cu in
                    -- "remote fired StartQuest TikiQuest2 2" moi 3 giay va khong
                    -- bao gio danh.
                    local hasQuestNow = QuestManager.HasActiveQuest(MonName)
                    if hasQuestNow then
                        SetTask("MainTask", "Level Farming | " .. tostring(MonName) .. " | Defeating Enemies")
                        if MonName then
                            CombatController.Attack(MonName)
                            return
                        end
                        -- Co quest ma khong biet danh con nao (du lieu quest chua
                        -- nap) -> nap lai roi vong sau danh, khong Attack(nil).
                        return QuestManager:RefreshQuest()
                    end

                    -- [FIX-41] Khi CHUA co quest active: nap lai du lieu quest theo
                    -- cap hien tai ROI, sau do moi chon quest (giong script dang
                    -- chay dc). NpcPosition cache co the nil nen cung cap nhat o
                    -- day chu khong thoat som nhu ban cu.
                    -- Neu bo buoc RefreshQuest nay thi sau khi xong quest no lai
                    -- nhan dung quest cu (du lieu cache), khong tien sang muc tiep.
                    QuestManager:RefreshQuest()
                    MonName, NpcPosition, QuestId, QuestIndex, QuestTitle = QuestManager:GetCurrentQuest()
                    -- [FIX-41] Khong con chan o day bang NpcPosition: nhan quest da
                    -- la "instant" nen toa do NPC khong can nua; dung QuestId/
                    -- QuestIndex ben duoi de chan.

                    -- [FIX-38] Thu tu moi: KIEM TRA CHAN TRUOC, BAY DI SAU.
                    -- [FIX-36] dat TweenController Create o TRUOC lenh chan, nen
                    -- moi vong bi chan van lenh bay ve NPC -> trieu chung ban gui
                    -- "danh tai o bay ve vi tri cu quest lai". Gio vong bi chan
                    -- khong con lenh di chuyen nao, no o lai bai guai va danh.
                    if not QuestId or not QuestIndex then
                        QuestManager:RefreshQuest()
                        return
                    end

                    local claimKey = tostring(QuestId) .. "_" .. tostring(QuestIndex)
                    if QuestClaimKey == claimKey and tick() - (QuestClaimTick or 0) < 25 then
                        SetTask("MainTask", "Level Farming | " .. tostring(MonName) .. " | Defeating Enemies")
                        if MonName then
                            CombatController.Attack(MonName)
                        end
                        return
                    end

                    -- [FIX-41] NHAN QUEST KHONG CAN BAY: script dang chay dc goi
                    -- StartQuest ngay tai bai guai (attachment 4515: "Claiming
                    -- Quest (Instant at Mob Area)") va van duoc server chap nhan.
                    -- Ban cu buoc phai bay toi NPC va dung o trong ban kinh 10
                    -- studs: khi toa do NPC lay tu BuiltInNpcPositions cu hoac NPC
                    -- khong o dung cho do thi khong bao gio du gan -> vong lap nao
                    -- cung phat lai lenh bay ve do = HUD ding o "Claiming Quest"
                    -- (dung cai ban mo ta) va nhan luon quest ke tiep.
                    SetTask("MainTask", "Level Farming | " .. tostring(MonName) .. " | Claiming Quest")

                    local mobPos = nil
                    pcall(function()
                        local region = MonName and ScriptStorage.MobRegions and ScriptStorage.MobRegions[MonName]
                        local r = (region and region[1]) or (MonName and MobPositionsFallback and MobPositionsFallback[MonName])
                        if r then
                            mobPos = (typeof(r) == "CFrame" and r.Position) or (typeof(r) == "Vector3" and r)
                        end
                    end)
                    -- [FIX-41] An han tinh tu CHO DANG DUNG ra bai guai (truoc day
                    -- tinh tu NPC), vi bay gio khong con di chuyen khi nhan nua.
                    local distToMob = (mobPos and CaculateDistance(mobPos)) or 0
                    getgenv().DynamicQuestGracePeriod = 8 + math.clamp(distToMob / 160, 0, 30)

                    QuestClaimKey = claimKey
                    QuestClaimTick = tick()
                    getgenv().LastQuestClaimTick = tick()

                    LevelFarmTTL = 0
                    QuestManager.StartQuest(QuestId, QuestIndex)
                    -- [FIX-42] Khong con wait 2s truoc khi nhan (do la cho bay toi
                    -- NPC, ma bay gio nhan tai cho). Va HUD phai ghi "Defeating
                    -- Enemies" ngay khi bat dau vong farm: ban nay de SetTask do
                    -- SAU vong lap nen su that la no dang danh (panel 5/8) ma HUD
                    -- van ghi "Claiming Quest" suot 300 giay.
                    SetTask("MainTask", "Level Farming | " .. tostring(MonName) .. " | Defeating Enemies")

                    -- [FIX-38] SAU KHI NHAN QUEST: O LAI BAI GUAI. Vong nay chi goi
                    -- CombatController.Attack (tu no di chuyen den con guai gan
                    -- nhat), tuyet doi khong co lenh bay ve NPC, nen het trieu
                    -- chung "bay di bay lai". Thoat vong khi:
                    --  + tien do du X/X (xong nhiem vu) -> vong ngoai thay khong con
                    --    quest nen se bay den NPC nhan nhiem vu ke tiep;
                    --  + hoac UI mat hon 2s khi da den bai guai du lau;
                    --  + hoac an toan 300s.
                    local farmStart = os.time()
                    local arrivedAtMob = false
                    local lastCur, lastMax = nil, nil
                    local goneSince = nil
                    while task.wait(0.05) do
                        if _G.Stop then
                            break
                        end

                        -- [FIX-47] Vong nay giu thread cua vong lap CHINH (no nam
                        -- trong LevelFarm.Start, duoc goi boi RefreshTasksData).
                        -- Ma MeleesController.Start lai duoc goi SAU
                        -- RefreshTasksData o cung vong lap do -> trong luc vong nay
                        -- chay thi khong co bat ky lan goi nao cho melee, tuc la
                        -- "tien du ma khong di mua vo". Cho no chay toi da 10s roi
                        -- tra dieu khien ve vong chinh; viec danh xong nhiem vu van
                        -- do nhanh ben ngoai xu ly (HasActiveQuest that thi nhan
                        -- quest khac, con quest active thi Attack tai cho).
                        if os.time() - farmStart >= 10 then
                            break
                        end

                        if
                            not arrivedAtMob and
                                ((mobPos and CaculateDistance(mobPos) <= 350) or os.time() - farmStart >= 15)
                     then
                            arrivedAtMob = true
                        end

                        local isActive, cK, tK = QuestManager.HasActiveQuest(MonName)
                        if isActive then
                            goneSince = nil
                            if cK and tK and tK > 0 then
                                lastCur, lastMax = cK, tK
                                if cK >= tK then
                                    break
                                end
                            end
                        elseif arrivedAtMob and os.time() - farmStart >= 20 then
                            if not goneSince then
                                goneSince = os.clock()
                            elseif
                                os.clock() - goneSince >= 2 and
                                    (
                                        not lastCur or not lastMax or lastCur >= lastMax or
                                            -- [FIX-43] Diem nan cua "ko di nhan nua
                                            -- ma cu bay danh mai: panel bien mat
                                            -- luc tien do con 5/8 (game an panel
                                            -- ngay khi xong / doi quest) thi dieu
                                            -- kien cu khong cho thoat, vong nay keo
                                            -- dai het 300s danh lai. Gio giu toi da
                                            -- 20s mat UI roi van coi la xong.
                                            os.clock() - goneSince >= 20
                                     )
                             then
                                break
                            end
                        else
                            goneSince = nil
                        end

                        local AttackTime1 = os.time()
                        CombatController.Attack(MonName)
                        LevelFarmTTL = LevelFarmTTL + os.time() - AttackTime1

                        if os.time() - farmStart > 300 then
                            break
                        end
                    end

                    -- Xoa an han de vong ngoai doc dung trang thai quest vua xong.
                    getgenv().LastQuestClaimTick = nil
                    getgenv().DynamicQuestGracePeriod = nil
                    SetTask("MainTask", "Level Farming | " .. tostring(MonName) .. " | Defeating Enemies")
                    return
                end
            end
        )
        -- LP Controller

        FunctionsHandler.LocalPlayerController:RegisterMethod(
            "EquipTool",
            function(Tool)
                if not Humanoid then
                    return
                end

                for _, Item in LocalPlayer.Backpack:GetChildren() do
                    if
                        Item:IsA("Tool") and Item.Name ~= "Tool" and
                            (Item.Name == tostring(Tool) or Item.ToolTip == Tool)
                     then
                        LocalPlayer.Character:WaitForChild "Humanoid":EquipTool(Item)
                    end
                end
            end
        )

        FunctionsHandler.LocalPlayerController:RegisterMethod(
            "ToggleAbilities",
            function(Ability, State)
                if Ability == "Buso" then
                    if  LocalPlayer.Character:FindFirstChild('HasBuso') == nil or State then
                        Remotes.CommF_:InvokeServer("Buso")
                    end
                elseif Ability == "Observation" then
                end
            end
        )

        FunctionsHandler.LocalPlayerController:RegisterMethod(
            "ConfigurationAbilitiesToggle",
            function()
                FunctionsHandler.LocalPlayerController.Methods.ToggleAbilities:Call("Buso", SCRIPT_CONFIG.BUSO)
                FunctionsHandler.LocalPlayerController.Methods.ToggleAbilities:Call(
                    "Observation",
                    SCRIPT_CONFIG.OBSERVATION
                )
            end
        )
        print(3)

        -- Items / Saber

        FunctionsHandler.Saber:RegisterMethod(
            "Refresh",
            function()
                if not Config.Items.Saber then
                    return
                end

                if not Config.Items.Saber then
                    return
                end
                if SeaIndex ~= 1 then
                    return
                end

                local Result
                if ScriptStorage.Backpack.Saber then
                    return
                end

                if ScriptStorage.PlayerData.Level < 200 then
                    return
                end

                local Tasks = Remotes.CommF_:InvokeServer("ProQuestProgress")
                for _, Value in Tasks.Plates do
                    if Value == false then
                        Result = 1
                    end
                end

                if not Result then
                    if not Tasks.UsedTorch then
                        Result = 2
                    elseif not Tasks.UsedCup then
                        Result = 3
                    elseif not Tasks.TalkedSon then
                        Result = 4
                    elseif not Tasks.KilledMob then
                        Result = 5
                    elseif not Tasks.UsedRelic then
                        Result = 6
                    elseif not Tasks.KilledShanks and ScriptStorage.Enemies["Saber Expert"] then
                        Result = 7
                    end
                end

                FunctionsHandler.Saber:Set("CurrentProgressLevel", Result)
                FunctionsHandler.Saber:Set("LastestRefreshSenque", os.time())

                return Result
            end
        )

        FunctionsHandler.Saber:RegisterMethod(
            "GetQuestplates",
            function()
                local CachedData = FunctionsHandler.Saber:Get("QuestplatesCache")

                if CachedData then
                    return CachedData
                end

                local Jungle = Services.Workspace.Map.Jungle
                local Result = {}

                table.foreach(
                    Jungle.QuestPlates:GetChildren(),
                    function(_, Inst)
                        _ = Inst:FindFirstChild("Button") and table.insert(Result, Inst)
                    end
                )

                FunctionsHandler.Saber:Get("QuestplatesCache", Result)

                return Result
            end
        )

        FunctionsHandler.Saber:RegisterMethod(
            "Start",
            function()
                local Progress, LastestRefreshSenque =
                    FunctionsHandler.Saber:Get("CurrentProgressLevel"),
                    FunctionsHandler.Saber:Get("LastestRefreshSenque")

                print("[ Debug ] Saber quest indexes", Progress)
                if not Progress then
                    FunctionsHandler.Saber.Methods.Refresh:Call()
                    return FunctionsHandler.Saber.Methods.Start:Call()
                elseif Progress == 0 then
                elseif os.time() - LastestRefreshSenque > 60 then
                    FunctionsHandler.Saber.Methods.Refresh:Call()

                    return FunctionsHandler.Saber.Methods.Start:Call()
                else
                    if Progress == 1 then
                        local Questplates = FunctionsHandler.Saber.Methods.GetQuestplates:Call()

                        for Index, Questplate in Questplates do
                            SetTask("MainTask", "Saber Quest | Quest Plates | Touching " .. Index .. "/5")
                            -- Safety check: Ensure Questplate and Button exist before loop
                            if Questplate and Questplate:FindFirstChild("Button") then
                                local LoopStartTime = os.time()
                                local MaxLoopDuration = 60  -- 1 minute max
                                while CaculateDistance(Questplate.Button.CFrame) > 20 do
                                    -- Timeout check to prevent infinite loop
                                    if os.time() - LoopStartTime > MaxLoopDuration then
                                        print("[Saber Quest] Loop timeout, breaking")
                                        break
                                    end
                                    
                                    -- Re-check Questplate exists
                                    if not Questplate or not Questplate:FindFirstChild("Button") then
                                        break
                                    end
                                    
                                    task.wait(0.5)  -- Added delay to reduce FPS impact
                                    TweenController.Create(Questplate.Button.CFrame)
                                end
                            else
                                print("[Saber Quest] Questplate.Button not found")
                            end
                            task.wait(1)
                        end
                    elseif Progress == 2 then
                        SetTask("MainTask", "Saber Quest | Torch Puzzle | Using Torch")
                        Remotes.CommF_:InvokeServer("ProQuestProgress", "GetTorch")
                        task.wait(1)
                        Remotes.CommF_:InvokeServer("ProQuestProgress", "DestroyTorch")
                    elseif Progress == 3 then
                        SetTask("MainTask", "Saber Quest | Sick Man | Helping with Cup")
                        Remotes.CommF_:InvokeServer("ProQuestProgress", "GetCup")

                        if ScriptStorage.Tools.Cup then
                            FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Cup")
                            task.wait(1)
                            Remotes.CommF_:InvokeServer("ProQuestProgress", "FillCup", LocalPlayer.Character.Cup)
                        end

                        Remotes.CommF_:InvokeServer("ProQuestProgress", "SickMan")
                    elseif Progress == 4 then
                        SetTask("MainTask", "Saber Quest | Rich Son | Getting Information")
                        Remotes.CommF_:InvokeServer("ProQuestProgress", "RichSon")
                    elseif Progress == 5 then
                        SetTask("MainTask", "Saber Quest | Mob Leader | Defeating Boss")
                        CombatController.Attack("Mob Leader")
                    elseif Progress == 6 then
                        SetTask("MainTask", "Saber Quest | Relic | Placing at Location")
                        Remotes.CommF_:InvokeServer("ProQuestProgress", "RichSon")
                        Remotes.CommF_:InvokeServer("ProQuestProgress", "PlaceRelic")
                    elseif Progress == 7 then
                        SetTask("MainTask", "Saber Quest | Saber Expert | Final Battle")
                        CombatController.Attack("Saber Expert")
                    end
                end
            end
        )

        Remotes.RefreshQuestPro.OnClientEvent:Connect(function(...) if FunctionsHandler.Saber.Methods.Refresh then FunctionsHandler.Saber.Methods.Refresh.Callback(...) end end)

        -- Auto Melees

        -- [FIX-14] XOAN TOAN BO hook __namecall cua ban goc. No thay metatable cua
        -- game (bang nhau cho MOI Instance) bang mot closure Lua, tuc la moi len goi
        -- FindFirstChild/FireServer/InvokeServer cua ca game lan script deu phai qua
        -- Lua + tao bang {...} + unpack -> client kien den noi phim cung khong vao
        -- (F9). Solara con khong co newcclosure (xem [FIX-0]) nen phep gan do loi,
        -- giu metatable o trang thai da bo setreadonly(false).
        -- Hon nua: no chi phuc vu LockAimPositionTo, ma ham do khong duoc goi o dau
        -- trong ca file -> getgenv().LockPosition vinh vien nil, hook chay khong cong
        -- viec. sanglove-sea1.lua (chay mong) cung khong he co cho nay.

        MeleeLastCursor = 1
        FirstCall = true
        CanPurchase = {}
        FruitDataCache = {}
        -- [FIX-16] Lai ban cua sanglove-sea1.lua:4855 (ham da chay mong o may nguoi dung).
        -- Lenh `require(DF.Data)` gia dinh Tool tim thay la Blox Fruit Tool co ModuleScript
        -- "Data". O day `Data.DevilFruit.Value` tra ve "T-Rex" (Tool race/gia cam), Tool do
        -- khong co con "Data" -> loi that bai `mmb()` truoc khi vong farm keo bat dau.
        function GetCurrentFruitMastery()
            local ok, level, maxLvl =
                pcall(
                function()
                    local CurrentPlayer = game.Players.LocalPlayer
                    if
                        not CurrentPlayer or not CurrentPlayer:FindFirstChild("Data") or
                            not CurrentPlayer.Data:FindFirstChild("DevilFruit")
                     then
                        return 0, 0
                    end
                    local CurrentFruit = CurrentPlayer.Data.DevilFruit.Value
                    local DF =
                        CurrentPlayer.Character and
                        (CurrentPlayer.Character:FindFirstChild(CurrentFruit) or
                            CurrentPlayer.Backpack:FindFirstChild(CurrentFruit))
                    local bfMaxLevel = 0

                    if DF and CurrentFruit and CurrentFruit ~= "" then
                        local Data = FruitDataCache[CurrentFruit]
                        if not Data and DF:FindFirstChild("Data") then
                            Data = safe_require(DF.Data, 1)
                        end
                        if Data then
                            FruitDataCache[CurrentFruit] = Data
                            for _, v in {"V", "C", "X", "F", "Z"} do
                                if Data.Lvl and Data.Lvl[v] then
                                    bfMaxLevel = Data.Lvl[v]
                                    break
                                end
                            end
                        end

                        return (DF:FindFirstChild("Level") and DF.Level.Value) or 0, bfMaxLevel
                    end
                    return 0, bfMaxLevel
                end
            )
            if ok and level then
                return level, maxLvl or 0
            end
            return 0, 0
        end

        -- [FIX-16] Ba code nay la code doi ban, server co the khong con nhan -> pcall
        -- nhu sea1:4893. Truoc day loi o day tung bi Report() an het.
        pcall(function() Remotes.Redeem:InvokeServer("KITT_RESET") end)
        pcall(function() Remotes.Redeem:InvokeServer("Sub2UncleKizaru") end)
        pcall(function() Remotes.Redeem:InvokeServer("SUB2GAMERROBOT_RESET1") end)

        function ResetStat(PrimaryPoint)
            if (LocalPlayer.Data.Stats:FindFirstChild(PrimaryPoint).Level.Value < 2000) then
                if ScriptStorage.PlayerData.StatRefunds > 0 then
                    Remotes.CommF_:InvokeServer("redeemRefundPoints", "Refund Points")
                elseif ScriptStorage.PlayerData.Fragments > 2500 then
                    game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Refund", "1")
                    game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Refund", "2")
                else
                    return false
                end

                Remotes.CommF_:InvokeServer("AddPoint", PrimaryPoint, 9999)
                Remotes.CommF_:InvokeServer("AddPoint", "Melee", 9999)
                Remotes.CommF_:InvokeServer("AddPoint", "Defense", 9999)
            end
            return true
        end
 
        print(GetCurrentFruitMastery())
        FunctionsHandler.MeleesController:RegisterMethod(
            "Refresh",
            function()
                return Config.Items.AutoFullyMelees
            end
        )

        FunctionsHandler.MeleesController:RegisterMethod(
            "Start",
            function()
                ScriptStorage.IsGettingMelee = false  -- luôn reset flag trước khi bắt đầu

                for Cursor, Melee in MeleesTable do
                    if Melee ~= "SanguineArt" then
                        if not Config.Items.AutoFullyMelees then
                            break
                        end
                        Data = MeleePrices[Melee]
                        local CanMeleePurchaseable = CanPurchase[Melee]
                        if not CanMeleePurchaseable then
                            -- [FIX-18] Dong truoc day goi Data.Buy(1) HAI lan: gan vao
                            -- CanPurchase[Melee] va in ra lenh. Data.Buy() la InvokeServer
                            -- that, nen khi ket qua = false thi no bi goi lai MOI frame,
                            -- MOI melee -> day la "quét kinh khung" trong log.
                            CanPurchase[Melee] = Data.Buy(1)
                        end
                        local CanMeleePurchaseable = CanPurchase[Melee]

                        if not Data then
                            print("no m1 data")
                            Data.Buy()
                            break
                        end

                        if Melee == "Dragon Talon" then
                            IsFireEssenceGave = (function()
                                if IsFireEssenceGave ~= nil then
                                    return IsFireEssenceGave
                                end

                                local PurchaseTestResult = Remotes.CommF_:InvokeServer("BuyDragonTalon", true)
                                alert("Dragon Talon Purchased", tostring(typeof(PurchaseTestResult) ~= "string"))
                                return typeof(PurchaseTestResult) ~= "string" and true or false
                            end)()

                            print("IsFireEssenceGave", IsFireEssenceGave)

                            if not IsFireEssenceGave then
                                print("no fire essence provided")
                                ScriptStorage.IsGettingMelee = false
                                break
                            end
                        end
                        if Melee == "Godhuman" and not (GodHumanRetryAt and os.time() < GodHumanRetryAt) then
                            -- [FIX-26] Server tra ve STRING moi lan khong mua duoc
                            -- (log: "Response_ false string"), nen dieu kien
                            -- type(...) == "string" o duoi bat GodHumanFlag = true
                            -- VINH VIEN. Cho den khi doc duoc nguyen lieu that,
                            -- GodHumanRetryAt giu cho no im lang.
                            if (ScriptStorage.Melees["Dragon Talon"] or 0) > 399 then
                                if not ScriptStorage.Melees.Godhuman then
                                    if SeaIndex == 3 then
                                        BuyMelee("Godhuman", true,"Ancient Monk")
                                    end
                                    FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Melee")

                                    if not ScriptStorage.Melees.Godhuman and type(game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyGodhuman", true)) == "string" then
                                        GodHumanFlag = true
                                        ScriptStorage.IsGettingMelee = false
                                        return
                                    end
                                end
                            end
                        end

                        if
                            not ScriptStorage.Melees[Melee] or
                                (ScriptStorage.Melees[Melee] or 0) < Data.NextLevelRequirement
                         then
                            local MeleeId = GetMeleeIdByName(Melee)
                            local PlayerData = ScriptStorage.PlayerData
                            local ValuementPassed = true

                            if not MeleeId then
                                ScriptStorage.IsGettingMelee = false
                                return print("[ Debug ] Failed to get melee id of", Melee)
                            end

                            MSet = false
                            if not CanMeleePurchaseable then
                                for Index, Value in Data.Price do
                                    if PlayerData[Index] < Value and not FirstCall then
                                        ValuementPassed = false

                                        if not ScriptStorage.Melees[Melee] then
                                            MSet = true
                                            SetTask(
                                                "SubTask",
                                                "Farming Until Enough " .. Index .. " ( " .. Value .. " ) For " .. Melee
                                            )
                                        end
                                        ScriptStorage.IsGettingMelee = false
                                        return
                                    end
                                end
                            end

                            if
                                not MSet and ScriptStorage.Melees[Melee] and
                                    ScriptStorage.Melees[Melee] < Data.NextLevelRequirement
                             then
                                SetTask(
                                    "SubTask",
                                    "Farming Until Enough Mastery For " ..
                                        Melee ..
                                            " ( " ..
                                                ScriptStorage.Melees[Melee] ..
                                                    " / " .. Data.NextLevelRequirement .. " )."
                                )
                                -- Luôn attack ĐỂ TĂNG MASTERY, bất kể đã sở hữu melee chưa
                                -- [FIX-57] DA HOAN TAC [FIX-56] (goi LevelFarm.Start o
                                -- day lam loi), quay lai dung nhu ban dau.
                                CombatController.Attack(Melee)
                                -- Chỉ mua nếu chưa có — KHÔNG block raid khi farm mastery
                                if not ScriptStorage.Tools[Melee] then
                                    print("no m1 found, buy")
                                    ScriptStorage.IsGettingMelee = true  -- block raid CHỈ khi đang mua
                                    Data.Buy()
                                    ScriptStorage.IsGettingMelee = false  -- clear ngay sau khi mua xong
                                end
                                -- KHÔNG set IsGettingMelee khi chỉ farm mastery — raid vẫn chạy bình thường
                                return
                            end

                            if not FirstCall then
                                if ValuementPassed and Data.Requirements() and not ScriptStorage.Tools[Melee] then
                                    if Melee == "Dragon Talon" and not IsFireEssenceGave then
                                        alert("IsFireEssenceGave", tostring(IsFireEssenceGave))
                                        ScriptStorage.IsGettingMelee = false
                                        return SetTask("SubTask", "Waiting until have fire essence for dragon talon.")
                                    end

                                    ScriptStorage.IsGettingMelee = true  -- Set flag to block raid
                                    Data.Buy()
                                    FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Melee")
                                    if not ScriptStorage.Tools[Melee] then
                                        task.wait()
                                        if not ScriptStorage.Tools[Melee] then
                                            if ((Melee == "Death Step" and game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyDeathStep", true) ==  3)  or
                                            (Melee == "Sharkman Karate" and
                                            type(game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySharkmanKarate", true)) == "string" or (
                                            type(game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySharkmanKarate", true)) == "number" and game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySharkmanKarate", true) == 3 ))) and SeaIndex ~= 2 then
                                                alert("Go Back To Second Sea", "Water Key / Library Key")

                                                Remotes.CommF_:InvokeServer("TravelDressrosa")
                                            end
                                            ScriptStorage.IsGettingMelee = false  -- Clear flag if failed
                                        else
                                            MeleeLastCursor = Cursor + 1
                                            ScriptStorage.IsGettingMelee = false  -- Clear flag on success
                                            return
                                        end
                                    else
                                        MeleeLastCursor = Cursor + 1
                                        ScriptStorage.IsGettingMelee = false  -- Clear flag on success
                                        return
                                    end
                                end
                            end
                        elseif not FirstCall then
                            MeleeLastCursor = Cursor + 1
                        end
                    end
                end
                if FirstCall then
                    FirstCall = false
                    return
                end

                checkdone = true
                ScriptStorage.IsGettingMelee = false  -- reset khi loop xong

            end
        )
        -- Second Sea

        FunctionsHandler.SecondSeaPuzzle:RegisterMethod(
            "Refresh",
            function()
                if ScriptStorage.PlayerData.Level < 700 or SeaIndex ~= 1 then
                    return
                end
                if FunctionsHandler.SecondSeaPuzzle:Get("IsCompleted") then
                    return
                end

                local Result = nil
                local ok, Response = pcall(function()
                    return Remotes.CommF_:InvokeServer("DressrosaQuestProgress")
                end)
                if ok and type(Response) == "table" then
                    print(959, Response.TalkedDetective, Response.KilledIceBoss)
                    if not Response.TalkedDetective then
                        Result = 1
                    elseif not Response.KilledIceBoss then
                        Result = 2
                    else
                        FunctionsHandler.SecondSeaPuzzle:Set("IsCompleted", true)
                    end
                end

                FunctionsHandler.SecondSeaPuzzle:Set("CurrentProgressLevel", Result)
                FunctionsHandler.SecondSeaPuzzle:Set("LastestRefreshSenque", os.time())

                return Result
            end
        )

        FunctionsHandler.SecondSeaPuzzle:RegisterMethod(
            "Start",
            function()
                local Progress, LastestRefreshSenque =
                    FunctionsHandler.SecondSeaPuzzle:Get("CurrentProgressLevel"),
                    FunctionsHandler.SecondSeaPuzzle:Get("LastestRefreshSenque")

                FunctionsHandler.SecondSeaPuzzle:Set("CurrentProgressLevel", nil)
                if not Progress then
                    return
                elseif Progress == 1 then
                    SetTask("MainTask", "Auto Second Sea - Talk To Detective")
                    Remotes.CommF_:InvokeServer("DressrosaQuestProgress", "Detective")

                    Remotes.CommF_:InvokeServer("DressrosaQuestProgress", "Detective")

                    task.wait(1)
                    Remotes.CommF_:InvokeServer("DressrosaQuestProgress", "UseKey")
                elseif Progress == 2 then
                    Remotes.CommF_:InvokeServer("DressrosaQuestProgress", "Detective")

                    Remotes.CommF_:InvokeServer("DressrosaQuestProgress", "Detective")

                    task.wait(1)
                    Remotes.CommF_:InvokeServer("DressrosaQuestProgress", "UseKey")
                    SetTask("MainTask", "Auto Second Sea - Defeating Ice Admiral")
                    CombatController.Attack("Ice Admiral")
                    alert("Traveling back to Dressrosa [ Ice Admiral ]")
                    Remotes.CommF_:InvokeServer("TravelDressrosa")
                end
            end
        )

        -- Bartilo

        FunctionsHandler.ColosseumPuzzle:RegisterMethod(
            "Refresh",
            function()
                if SeaIndex ~= 2 then
                    return
                end

                if ScriptStorage.PlayerData.Level < 850 or ScriptStorage.PlayerData.Level >= 1500 then
                    return
                end

                if ScriptStorage.Backpack["Warrior Helmet"] or (ScriptStorage.Inventory and ScriptStorage.Inventory["Warrior Helmet"]) or (ScriptStorage.Accessories and ScriptStorage.Accessories["Warrior Helmet"]) then
                    return
                end

                local Result = nil
                local ok, Response = pcall(function()
                    return Remotes.CommF_:InvokeServer("BartiloQuestProgress")
                end)

                if ok and type(Response) == "table" then
                    if not Response.KilledBandits then
                        Result = 1
                    elseif not Response.KilledSpring then
                        if ScriptStorage.Enemies.Jeremy then
                            Result = 2
                        end
                    elseif not Response.DidPlates then
                        Result = 3
                    end
                end

                FunctionsHandler.ColosseumPuzzle:Set("CurrentProgressLevel", Result)
                FunctionsHandler.ColosseumPuzzle:Set("LastestRefreshSenque", os.time())
                return Result
            end
        )
        print(4)
        FunctionsHandler.ColosseumPuzzle:RegisterMethod(
            "Start",
            function()
                local Progress, LastestRefreshSenque =
                    FunctionsHandler.ColosseumPuzzle:Get("CurrentProgressLevel"),
                    FunctionsHandler.ColosseumPuzzle:Get("LastestRefreshSenque")
                FunctionsHandler.ColosseumPuzzle:Set("CurrentProgressLevel", nil)
                print("Progress", Progress)
                if not Progress then
                    return
                elseif Progress == 1 then
                    SetTask("MainTask", "Auto Bartilo Quest - Defeating 50x Swan Pirate")
                    -- [FIX-63] CHI doi dong DOC HUD, giu nguyen cay quyet dinh cua
                    -- tac gia. Ham cu (2529) can PlayerGui.Main.Quest.Visible = true
                    -- va label TIENG ANH "Defeat N Mob (x)"; tren client nay frame do
                    -- an (probe [FIX-37]) nen no tra false mai -> nhanh Attack ben
                    -- duoi khong bao gio chay. HasActiveQuest dem bo dem "x/y" dang
                    -- render that; quest nay co max = 50 nen RawText duoc lap thanh
                    -- "50", dieu kien string.find ben duoi van dung nhu thiet ke.
                    local hasQuest, _, maxKills = QuestManager.HasActiveQuest()
                    local CurrentQuest, RawText = hasQuest, (hasQuest and tostring(maxKills) or "")

                    if CurrentQuest then
                        if not string.find(RawText, "50") then
                            QuestManager.AbandonQuest()
                        else
                            CombatController.Attack("Swan Pirate")
                        end
                    else
                        QuestManager.StartQuest("BartiloQuest", 1)
                    end
                elseif Progress == 2 then
                    SetTask("MainTask", "Auto Bartilo Quest - Defeating Jeremy")
                    CombatController.Attack("Jeremy")
                elseif Progress == 3 then
                    SetTask("MainTask", "Auto Bartilo Quest - Doing Puzzle")
                    if
                        CaculateDistance(
                            CFrame.new(
                                -1837.46155,
                                44.2921753,
                                1656.1987,
                                0.999881566,
                                -1.03885048e-22,
                                -0.0153914848,
                                1.07805858e-22,
                                1,
                                2.53909284e-22,
                                0.0153914848,
                                -2.55538502e-22,
                                0.999881566
                            )
                        ) > 10
                     then
                        alert("tween to")
                        TweenController.Create(
                            CFrame.new(
                                -1837.46155,
                                44.2921753,
                                1656.1987,
                                0.999881566,
                                -1.03885048e-22,
                                -0.0153914848,
                                1.07805858e-22,
                                1,
                                2.53909284e-22,
                                0.0153914848,
                                -2.55538502e-22,
                                0.999881566
                            )
                        )
                    else
                        LocalPlayer = game.Players.LocalPlayer
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1836, 11, 1714)
                        alert("1")
                        task.wait(.5)
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1850.49329, 13.1789551, 1750.89685)
                        alert("2")
                        task.wait(1)
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1858.87305, 19.3777466, 1712.01807)
                        alert("3")
                        task.wait(1)
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1803.94324, 16.5789185, 1750.89685)
                        task.wait(1)
                        alert("4")
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1858.55835, 16.8604317, 1724.79541)
                        task.wait(1)
                        alert("5")
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1869.54224, 15.987854, 1681.00659)
                        task.wait(1)
                        alert("6")
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1800.0979, 16.4978027, 1684.52368)
                        task.wait(1)
                        alert("7")
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1819.26343, 14.795166, 1717.90625)
                        task.wait(1)
                        alert("8")
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1813.51843, 14.8604736, 1724.79541)
                    end
                end
            end
        )

        -- Race v2

        FunctionsHandler.EvoRace:RegisterMethod(
            "Refresh",
            function()
                if not Config.Items.RaceV2 then
                    return
                end
                if SeaIndex ~= 2 then
                    return
                end
                if
                    GetExpBoost() ~= 0 or
                        ScriptStorage.PlayerData.Level < 900 or
                        ScriptStorage.PlayerData.Beli < 1000000 or
                        ScriptStorage.PlayerData.RaceLevel ~= 1
                 then
                    return
                end
                return true
            end
        )

        FunctionsHandler.EvoRace:RegisterMethod(
            "Start",
            function()
                Remotes.CommF_:InvokeServer("Alchemist", "1")
                Remotes.CommF_:InvokeServer("Alchemist", "2")

                for i = 1, 2, 1 do
                    local Check1 = ScriptStorage.Tools["Flower " .. i]
                    local Check2 = Services.Workspace:FindFirstChild("Flower" .. i)

                    if not Check1 then
                        if Check2 and Check2.Transparency == 0 then
                            SetTask("MainTask", "Auto Race V2 - Collecting Flower " .. i)
                            while not ScriptStorage.Tools["Flower " .. i] do
                                task.wait()
                                TweenController.Create(Check2.CFrame + Vector3.new(0, math.random(-1, 2), 0))
                            end
                        end
                    end
                end

                if not ScriptStorage.Tools["Flower 3"] then
                    SetTask("MainTask", "Auto Race V2 - Collecting Flower " .. 3)
                    CombatController.Attack("Swan Pirate")
                else
                    SetTask("MainTask", "Auto Race V2 - Idling")
                    if LocalPlayer.Character.HumanoidRootPart.CFrame.Y < 50000 then
                        TweenController.Create(LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 50, 0))
                    end

                    Remotes.CommF_:InvokeServer("Alchemist", "3")
                    RefreshRace()
                end
            end
        )

        -- BossesTask

        FunctionsHandler.BossesTask:RegisterMethod(
            "Refresh",
            function()
                local Boss
                for _, BossName in BossesOrder do
                    if BossName then 
                    local LevelReq = BossesOrderLevel[BossName]

                    if ScriptStorage.PlayerData.Level >= LevelReq then
                        local Result = ScriptStorage.Enemies[BossName]
                        if Result and Result:FindFirstChild("Humanoid") and Result.Humanoid.Health > 0 then
                            Boss = Result
                        end
                    end
                    end
                end

                if
                    Boss and
                        (CaculateDistance(Boss.HumanoidRootPart.CFrame) < (SeaIndex == 2 and 3000 or 5000) or
                            BossesOrderWL[tostring(Boss)] or
                            ScriptStorage.PlayerData.Level == MaxLevel)
                 then
                    return Boss
                end
            end
        )

        FunctionsHandler.BossesTask:RegisterMethod(
            "Start",
            function(Boss)
                if Boss then
                    SetTask("MainTask", "Auto Farm Boss - Defeating " .. Boss.Name)

                    CombatController.Attack(
                        tostring(Boss),
                        null,
                        null,
                        function()
                            SpecialItems = nil
                        end
                    )

                    SpecialItems = nil
                end
            end
        )

        FunctionsHandler.SpecialBossesTask:RegisterMethod(
            "Refresh",
            function()
                local Boss2

                for BossName, LevelReq in SpecialBossesOrder do
                    if ScriptStorage.PlayerData.Level >= LevelReq then
                        local Result = ScriptStorage.Enemies[BossName]
                        if Result and Result:FindFirstChild("Humanoid") and Result.Humanoid.Health > 0 then
                            Boss2 = Result
                        end
                    end
                end
                return Boss2
            end
        )

        FunctionsHandler.SpecialBossesTask:RegisterMethod(
            "Start",
            function(Boss)
                if FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call() then
                    pcall(
                        function()
                            LocalPlayer.Character.Humanoid.Health = 0
                        end
                    )
                end

                if Boss then
                    SetTask("MainTask", "Auto Farm Boss - Defeating " .. Boss.Name)
                    CombatController.Attack(tostring(Boss))
                end
            end
        )

        -- RaidController

        FunctionsHandler.RaidController:RegisterMethod(
            "RefreshRaidType",
            function()
                for _, Raid in require(game.ReplicatedStorage.Raids).raids do
                    if string.find(ScriptStorage.PlayerData.DevilFruit, Raid) then
                        FunctionsHandler.RaidController:Set("CurrentChip", Raid)
                        return
                    end
                end
                FunctionsHandler.RaidController:Set("CurrentChip", "Flame")
            end
        )

        FunctionsHandler.RaidController:RegisterMethod(
            "GetRaidableFruit",
            function()
                pcall(RefreshInventory)
                
                local TrashFruits = {
                    ["Rocket-Rocket"] = true, ["Spin-Spin"] = true, ["Blade-Blade"] = true, ["Chop-Chop"] = true,
                    ["Spring-Spring"] = true, ["Bomb-Bomb"] = true, ["Smoke-Smoke"] = true, ["Spike-Spike"] = true,
                    ["Flame-Flame"] = true, ["Falcon-Falcon"] = true, ["Ice-Ice"] = true, ["Sand-Sand"] = true,
                    ["Dark-Dark"] = true, ["Diamond-Diamond"] = true, ["Light-Light"] = true, ["Rubber-Rubber"] = true,
                    ["Barrier-Barrier"] = true, ["Ghost-Ghost"] = true, ["Magma-Magma"] = true, ["Quake-Quake"] = true
                }
                
                local HighFruits = {
                    "Kitsune", "Dragon", "Leopard", "Spirit", "Control", "Venom", "Shadow", "Dough", 
                    "T-Rex", "Mammoth", "Gravity", "Blizzard", "Pain", "Rumble", "Portal", "Phoenix", 
                    "Sound", "Spider", "Love", "Buddha"
                }

                -- 1. Kiểm tra trực tiếp qua getInventoryFruits
                local directFruits = nil
                pcall(function() directFruits = Remotes.CommF_:InvokeServer("getInventoryFruits") end)
                if type(directFruits) == "table" then
                    for _, Fruit in pairs(directFruits) do
                        if type(Fruit) == "table" and Fruit.Name then
                            local rawName = tostring(Fruit.Name)
                            local price = tonumber(Fruit.Price) or tonumber(Fruit.Value) or 0
                            local isTrash = TrashFruits[rawName] or (price > 0 and price < 1000000)
                            if not isTrash then
                                for tName, _ in pairs(TrashFruits) do
                                    local baseName = string.split(tName, "-")[1]
                                    if string.find(rawName, baseName) then
                                        isTrash = true
                                        break
                                    end
                                end
                            end
                            local isHighTier = false
                            for _, hName in ipairs(HighFruits) do
                                if string.find(rawName, hName) then
                                    isHighTier = true
                                    break
                                end
                            end
                            local isEatList = Config and Config.Items and Config.Items.Eatlist and table.find(Config.Items.Eatlist, rawName)
                            if (isTrash or (price > 0 and price < 1000000)) and not isHighTier and not isEatList then
                                Fruit.Type = "Blox Fruit"
                                return Fruit
                            end
                        end
                    end
                end

                -- 2. Kiểm tra trong ScriptStorage.Backpack
                for _, Fruit in pairs(ScriptStorage.Backpack or {}) do
                    if type(Fruit) == "table" and Fruit.Name then
                        local rawName = tostring(Fruit.Name)
                        local isBloxFruit = (Fruit.Type == "Blox Fruit") or string.find(rawName, "-") or string.find(rawName, "Fruit")
                        if isBloxFruit then
                            local price = tonumber(Fruit.Price) or tonumber(Fruit.Value) or 0
                            local isTrash = TrashFruits[rawName] or (price > 0 and price < 1000000)
                            if not isTrash then
                                for tName, _ in pairs(TrashFruits) do
                                    local baseName = string.split(tName, "-")[1]
                                    if string.find(rawName, baseName) then
                                        isTrash = true
                                        break
                                    end
                                end
                            end
                            local isHighTier = false
                            for _, hName in ipairs(HighFruits) do
                                if string.find(rawName, hName) then
                                    isHighTier = true
                                    break
                                end
                            end
                            local isEatList = Config and Config.Items and Config.Items.Eatlist and table.find(Config.Items.Eatlist, rawName)
                            if (isTrash or (price > 0 and price < 1000000)) and not isHighTier and not isEatList then
                                return Fruit
                            end
                        end
                    end
                end

                -- 3. Kiểm tra nếu người chơi đang cầm trái rác vật lý trong túi đồ Backpack/Character
                local lp = game:GetService("Players").LocalPlayer
                if lp then
                    local checkTools = {}
                    if lp.Character then
                        for _, tool in pairs(lp.Character:GetChildren()) do
                            if tool:IsA("Tool") and string.find(tool.Name, "Fruit") then table.insert(checkTools, tool) end
                        end
                    end
                    if lp:FindFirstChild("Backpack") then
                        for _, tool in pairs(lp.Backpack:GetChildren()) do
                            if tool:IsA("Tool") and string.find(tool.Name, "Fruit") then table.insert(checkTools, tool) end
                        end
                    end
                    for _, tool in ipairs(checkTools) do
                        local toolName = tool.Name
                        local isHighTier = false
                        for _, hName in ipairs(HighFruits) do
                            if string.find(toolName, hName) then
                                isHighTier = true
                                break
                            end
                        end
                        if not isHighTier then
                            return { Name = toolName, Type = "Blox Fruit", IsPhysical = true }
                        end
                    end
                end

                return nil
            end
        )

        FunctionsHandler.RaidController:RegisterMethod(
            "GetCurrentRaidIsland",
            function()
                PlayerPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
                IslandsList = {{}, {}, {}, {}, {}}

                for _, Island in workspace["_WorldOrigin"].Locations:GetChildren() do
                    if
                        string.find(Island.Name, "Island ") and
                            CaculateDistance(Island.Position, Vector3.new(0, 0, 0)) > 7000
                     then
                        (function()
                            local IslandIndex = string.gsub(Island.Name, "Island ", "")
                            local IslandIndex = tonumber(IslandIndex)
                            table.insert(IslandsList[IslandIndex], Island)
                        end)()
                    end
                end

                if true then
                    for Index = 5, 1, -1 do
                        for _, Island in IslandsList[Index] do
                            if CaculateDistance(Island.Position) < 2000 then
                                return Island
                            end
                        end
                    end
                end
            end
        )

        function CheckSpecialMicrochip()
            for _, v in {LocalPlayer.Character:GetChildren(), LocalPlayer.Backpack:GetChildren()} do
                for _, v in v do
                    if v.Name == "Special Microchip" then
                        return v
                    end
                end
            end
        end
     
    
        FunctionsHandler.RaidController:RegisterMethod("Refresh", function()
            if getgenv().IsCheckingMelees then return end
        
            local Level = (ScriptStorage.PlayerData and ScriptStorage.PlayerData.Level) or 0
            local Fragments = (ScriptStorage.PlayerData and ScriptStorage.PlayerData.Fragments) or 0
            local Beli = (ScriptStorage.PlayerData and ScriptStorage.PlayerData.Beli) or 0
        
            -- Điều kiện cơ bản: Raid mở từ Sea 2 (Lv 1100+) hoặc Sea 3
            if Level < 1100 or SeaIndex == 1 then return end
            if ScriptStorage.IsGettingMelee then return end
        
            -- 1. Check Melee: Chỉ chặn Raid nếu thực sự có thể mua NGAY LẬP TỨC
            if Config.Items.AutoFullyMelees then
                for Cursor, Melee in pairs(MeleesTable) do
                    if Melee ~= "SanguineArt" then
                        local Data = MeleePrices[Melee]
                        if Data then
                            local CanMeleePurchaseable = CanPurchase[Melee]
                            if not CanMeleePurchaseable and type(Data.Buy) == "function" then
                                CanMeleePurchaseable = Data.Buy(1)
                            end

                            local RequiredFragments = (Data.Price and Data.Price.Fragments) or 0
                            local CurrentFragments = Fragments

                            if CanMeleePurchaseable and Data.Requirements and Data.Requirements() and
                               (RequiredFragments == 0 or CurrentFragments >= RequiredFragments)
                            then
                                if not ScriptStorage.Melees[Melee] or ScriptStorage.Melees[Melee] == 0 then
                                    print("Da du dieu kien mua " .. Melee .. ". Dung Raid de di mua!")
                                    return
                                end
                            end
                        end
                    end
                end
            end

            -- 2. Logic tích luỹ Fragments:
            -- Nếu đang trên đảo Raid hoặc có Microchip sẵn -> LUÔN tiếp tục Raid!
            local inRaidIsland = FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call()
            local hasChip = CheckSpecialMicrochip()
            if inRaidIsland or hasChip then
                return true
            end

            -- Nếu Level chưa Max: farm tích luỹ đến 10k Fragments
            -- Nếu đã Max Level: farm tích luỹ đến 15k Fragments
            if Level < MaxLevel then
                if Fragments >= 10000 then return end 
            else
                if Fragments >= 15000 then return end 
            end
        
            -- 3. Thực hiện đi Raid (Hỗ trợ cả Fruit dưới 1M lẫn mua Chip bằng 100k Beli)
            local RaidFruit = FunctionsHandler.RaidController.Methods.GetRaidableFruit:Call()
            if RaidFruit then
                FunctionsHandler.RaidController:Set("CurrentProgressLevel", RaidFruit)
                return RaidFruit
            end
            
            -- Nếu không có Fruit nhưng có Beli -> Chỉ đi mua nếu không bị Cooldown 2 tiếng
            -- Nếu đang bị cooldown -> return false để LevelFarm đi làm nhiệm vụ / cày cấp!
            if Beli >= 100000 then
                if not (getgenv().BeliChipCooldownUntil and os.time() < getgenv().BeliChipCooldownUntil) then
                    return true
                end
            end
            
            return false
        end)
        
        
        
        FunctionsHandler.RaidController:RegisterMethod(
            "Start",
            function()
                if getgenv().IsRaidStarting then
                    return
                end
                
                -- 🔒 BẬT KHÓA TOÀN CỤC NGAY LẬP TỨC ĐỂ BLOCK LEVELFARM VÀ MELEE
                getgenv().IsRaidStarting = true
                getgenv().InRaidSafe = true 
                FunctionsHandler.RaidController:Set("IsInRaidProcess", true)
                
                -- Cooldown chống spam — kiểm tra NGOÀI pcall để không khóa script khi return
                if getgenv().RaidBuyingCooldown and os.clock() - getgenv().RaidBuyingCooldown < 30 then
                    getgenv().IsRaidStarting = false
                    return
                end

                -- Wrap toàn bộ logic trong pcall để đảm bảo các khóa (lock) luôn được xử lý kể cả khi lỗi
                local ok, err = pcall(function()
                    
                    if not FunctionsHandler.RaidController:Get("CurrentChip") then
                        FunctionsHandler.RaidController.Methods.RefreshRaidType:Call()
                    end

                    local CurrentIsland = FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call()
                    RefreshInventory()

                    FunctionsHandler.RaidController:Set("CurrentProgressLevel", nil)
                    
                    getgenv().anchored = true 

                    if not CurrentIsland then
                        SetTask(
                            "MainTask",
                            "Auto Raid - Buying Chip - " .. FunctionsHandler.RaidController:Get("CurrentChip")
                        )

                        local RootRaidIsland = ({nil, "CircleIsland", "Boat Castle"})[SeaIndex]
                        local RaidIsland = workspace.Map:FindFirstChild(RootRaidIsland) or workspace:FindFirstChild(RootRaidIsland)
                        
                        if not RaidIsland or not RaidIsland:FindFirstChild("RaidSummon2") then
                            task.wait(1)
                            return
                        end
                        
                        -- Lấy trực tiếp cái nút để sau này bấm hoặc bay tới (cho Sea 2)
                        local RaidButton = RaidIsland.RaidSummon2.Button.Main
                        
                        if not CheckSpecialMicrochip() then

                            local cRaidFruit = FunctionsHandler.RaidController.Methods.GetRaidableFruit:Call()
                            if not cRaidFruit then
                                warn("No raidable fruit found")
                                return
                            end

                            -- Chỉ thêm vào IgnoreStoreFruits nếu chưa có
                            if not table.find(ScriptStorage.IgnoreStoreFruits, cRaidFruit.Name) then
                                table.insert(ScriptStorage.IgnoreStoreFruits, cRaidFruit.Name)
                            end

                            -- Luôn lấy Fruit vật lý ra khỏi rương (LoadFruit)
                            if getgenv().LastLoadedFruit ~= cRaidFruit.Name then
                                getgenv().LastLoadedFruit = cRaidFruit.Name
                                alert("Load Fruit", cRaidFruit.Name)
                                Remotes.CommF_:InvokeServer("LoadFruit", cRaidFruit.Name)
                                task.wait(1.5)
                            end

                            Remotes.CommF_:InvokeServer(
                                "RaidsNpc",
                                "Select",
                                FunctionsHandler.RaidController:Get("CurrentChip")
                            )

                            -- Game tự cất fruit khi chọn chip → load lại fruit
                            task.wait(1)
                            Remotes.CommF_:InvokeServer("LoadFruit", cRaidFruit.Name)
                            task.wait(1)
                        end
                        
                        FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Special Microchip")
                        task.wait(2)
                        
                        if not CheckSpecialMicrochip() then
                            warn("Failed to get Special Microchip after buying")
                            return
                        end
                        
                        local lastTweenTime = 0
                        local tweenStartTime = os.time()
                        
                        -- 🔧 [ĐÃ SỬA]: Đặt mục tiêu kiểm tra khoảng cách là cái nút bấm, KHÔNG PHẢI NPC
                        local TargetPosition = (SeaIndex == 3) and Vector3.new(-5008.51, 313.85, -2817.10) or RaidButton.Position
                        
                        repeat task.wait() 
                            if os.time() - tweenStartTime > 60 then
                                warn("Tween to Raid Start timed out")
                                return
                            end
                            
                            if os.clock() - lastTweenTime > 0.5 then
                                if SeaIndex == 3 then
                                    TweenController.Create(CFrame.new(-5008.51, 313.85, -2817.10))
                                else
                                    -- Sea 2 bay thẳng vào nút bấm Raid dựa trên RootRaidIsland
                                    TweenController.Create(RaidButton.CFrame)
                                end
                                lastTweenTime = os.clock()
                            end
                            
                        -- Đo khoảng cách với TargetPosition (vị trí cái nút bấm)
                        until CaculateDistance(TargetPosition) <= 100
                        
                        pcall(function()
                            fireclickdetector((workspace.Map:FindFirstChild(RootRaidIsland) or
                                                  workspace:FindFirstChild(RootRaidIsland)).RaidSummon2.Button.Main
                                                  .ClickDetector)
                        end)

                        local RaidStartSenque = os.time()
                        SetTask("MainTask", "Auto Raid - Waiting Until Raid Is Started")

                        local RaidStarted = false
                        repeat
                            task.wait(0.5)
                            local CheckIsland = FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call()
                            if CheckIsland then
                                RaidStarted = true
                                break
                            end
                        until os.time() - RaidStartSenque > 30

                        if not RaidStarted then
                            SetTask("MainTask", "Auto Raid - Raid Is Not Started?")
                            Report("[ Raid Error ] Time Limit Reached - No Island Detected")
                            getgenv().LastLoadedFruit = nil
                            return
                        end

                        -- Chỉ set cooldown & block fruit KHI raid thực sự start thành công
                        getgenv().RaidBuyingCooldown = os.clock()

                        alert("Raid Started", "Entering raid island")
                        task.wait(1)
                        
                        CurrentIsland = FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call()
                    end
                    
                    if not CurrentIsland then
                        return
                    end
                    
                    if CurrentIsland then
                        FunctionsHandler.RaidController:Set("IsInRaidProcess", true)
                        
                        while true do
                            task.wait(1)
                            CurrentIsland = FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call()
                            
                            if not CurrentIsland then
                                SetTask("MainTask", "Auto Raid - Completed")
                                return
                            end
                            
                            SetTask("MainTask", "Auto Raid - " .. CurrentIsland.Name .. " / 5")
                            local Found = false
                            for _, Mon in GetMonAsSortedRange() do
                                local StartTick1 = os.time()
                                while Mon and Mon:FindFirstChild("HumanoidRootPart") and Mon.Humanoid.Health > 0 and
                                    CaculateDistance(Mon.HumanoidRootPart.Position) < 1000 and
                                    os.time() - StartTick1 < 60 and
                                    task.wait(.05) do
                                    Found = true
                                    CombatController.Attack(Mon.Name)
                                    
                                    local CheckIsland = FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call()
                                    if not CheckIsland then
                                        SetTask("MainTask", "Auto Raid - Completed")
                                        return
                                    end
                                end
                            end

                            if not Found then
                                TweenController.Create(CurrentIsland.Position + Vector3.new(0, 100, 0))
                            end
                        end
                    end
                end)
                
                -- 🔓 MỞ KHÓA BẢO VỆ — luôn reset IsRaidStarting
                getgenv().IsRaidStarting = false

                if not ok then
                    warn("[RaidController Start Error]", err)
                end

                -- Chỉ reset InRaidSafe/IsInRaidProcess khi raid đã thực sự kết thúc (không còn ở đảo raid)
                if not FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call() and not CheckSpecialMicrochip() then
                    getgenv().InRaidSafe = false
                    FunctionsHandler.RaidController:Set("IsInRaidProcess", false)
                end
            end
        )
        

        -- CollectDrops

        FunctionsHandler.CollectDrops:RegisterMethod(
            "Refresh",
            function()
                local FruitNames = {}

                for i in ScriptStorage.Backpack do
                    FruitNames[FruitIdToName(i)] = i
                end

                for _, Fruit in workspace:GetChildren() do
                    if
                        string.find(Fruit.Name, "Fruit") and not Players:FindFirstChild(Fruit.Name) and
                            Fruit:FindFirstChild("Handle") and
                            not FruitNames[tostring(Fruit)] and
                            not ScriptStorage.Backpack[FruitNameToId(tostring(Fruit))]
                     then
                        FunctionsHandler.CollectDrops:Set("CurrentProgressLevel", Fruit)
                        getgenv().anchored = true  
                        return Fruit
                    end
                end
            end
        )

        FunctionsHandler.CollectDrops:RegisterMethod(
            "Start",
            function()
                local Fruit = FunctionsHandler.CollectDrops:Get("CurrentProgressLevel")
                FunctionsHandler.CollectDrops:Set("CurrentProgressLevel", nil)
                if Fruit then
                    SetTask("MainTask", "Auto Collect Drop Items - " .. tostring(Fruit))
                    getgenv().anchored = true  
                    TweenController.Create(Fruit:GetModelCFrame())
                else
                    if not FunctionsHandler.RaidController.Methods.GetCurrentRaidIsland:Call() and 
                       not FunctionsHandler.RaidController.Methods.GetRaidableFruit:Call() then
                        getgenv().anchored = false
                    end
                end
            end
        )

        FunctionsHandler.UtillyItemsActivitation:RegisterMethod(
            "Refresh",
            function()
                if os.time() - StartTime < 20 then
                    return
                end
                if not SpecialItems then
                    SpecialItems = {}
                    local RemoveList = {}
                    IceAdmiralPassed = true

                    if SeaIndex == 2 and Services.Workspace.Map.IceCastle.Hall.LibraryDoor:FindFirstChild("PhoeyuDoor") then
                        table.insert(SpecialItems, "Library Key")
                        IceAdmiralPassed = false
                    end

                    if IceAdmiralPassed then
                        table.insert(RemoveList, "Awakened Ice Admiral")
                    end 
                    local Response =
                        not ScriptStorage.Melees["Sharkman Karate"] and
                        Remotes.CommF_:InvokeServer("BuySharkmanKarate", true)
                    SharkmanPassed = typeof(Response) == "string"
                    --   alert("SharkmanPassed", SharkmanPassed)
                    if typeof(Response) == "string" then
                        table.insert(SpecialItems, "Water Key")
                    else
                        TidePassed = true
                        table.insert(RemoveList, "Tide Keeper")
                    end
                    if ScriptStorage.Backpack.Yama then
                        print("Elite")
                        table.insert(RemoveList, "Deandre")
                        table.insert(RemoveList, "Urban")
                        table.insert(RemoveList, "Diablo")
                    end
                    local function GetResult()
                        local Result = {}
                        for _, Value in BossesOrder do
                            local Passed = true
                            for _, Name2 in RemoveList do
                                if Name2 == Value then
                                    Passed = false
                                end
                            end

                            if Passed then
                                table.insert(Result, Value)
                            end
                        end

                        local n = #Result
                        for i = 1, n - 1 do
                            for j = 1, n - i do
                                local a = key and tostring(Result[j][key]):lower() or tostring(Result[j]):lower()
                                local b =
                                    key and tostring(Result[j + 1][key]):lower() or tostring(Result[j + 1]):lower()
                                if a > b then
                                    Result[j], Result[j + 1] = Result[j + 1], Result[j]
                                end
                            end
                        end

                        return Result
                    end
                    BossesOrder = GetResult()
                    if #DropItemData > 0 then 
                    for ItemName, ItemData in DropItemData do
                        if not ScriptStorage.Backpack[ItemName] and SeaIndex == ItemData.Sea then
                            if ScriptStorage.PlayerData.Level >= ItemData.Level then
                                BossesOrderLevel[ItemData.Boss] = ItemData.Level
                                table.insert(BossesOrder, ItemData.Boss)
                            end
                        end
                    end
                end
                    if FunctionsHandler.Trevor:Get("IsCompleted") and not Storage:Get("SwanDefeated") then
                        print("Added Don Swan to boss orser list")
                        BossesOrderLevel["Don Swan"] = 1100
                        table.insert(BossesOrder, "Don Swan")
                        print(ScriptStorage.PlayerData.Level, ScriptStorage.Enemies["Don Swan"])
                        if
                            SeaIndex == 2 and ScriptStorage.PlayerData.Level > 1500 and
                                not ScriptStorage.Enemies["Don Swan"]
                         then
                            print("hop")
                        end
                    end
                end
                for Index, Value in SpecialItems do
                    if ScriptStorage.Tools[Value] then
                        FunctionsHandler.UtillyItemsActivitation:Set("CurrentProgressLevel", Value)
                        return Value
                    end
                end
                if
                    SeaIndex == 3 and (ScriptStorage.Melees["Death Step"] or 0) >= 400 and
                        (ScriptStorage.Melees["Black Leg"] or 0) >= 400 and
                        ScriptStorage.PlayerData.Beli >= 2500000 and
                        ScriptStorage.PlayerData.Fragments >= 5000 and
                        not ScriptStorage.Melees["Electric Claw"]
                 then
                    FunctionsHandler.UtillyItemsActivitation:Set("CurrentProgressLevel", "Previous Hero")
                    return "Previous Hero"
                end
                if ScriptStorage.Tools["Red Key"] then
                    FunctionsHandler.UtillyItemsActivitation:Set("CurrentProgressLevel", "Red Key")
                    return "Red Key"
                end
                if ScriptStorage.Tools["Hallow Essence"] then
                    FunctionsHandler.UtillyItemsActivitation:Set("CurrentProgressLevel", "Soul Reaper Spawner")
                    FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Hallow Essence")
                    return "Soul Reaper Spawner"
                end
                if ScriptStorage.Tools["Fire Essence"] then
                    FunctionsHandler.UtillyItemsActivitation:Set("CurrentProgressLevel", "Uzoth")

                    return "Uzoth"
                end
            end
        )

        FunctionsHandler.UtillyItemsActivitation:RegisterMethod(
            "Start",
            function()
                local Type = FunctionsHandler.UtillyItemsActivitation:Get("CurrentProgressLevel")
                if Type == "Hidden Key" then
                    Remotes.CommF_:InvokeServer("OpenRengoku")
                elseif Type == "Water Key" then
                    FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Water Key")
                    Remotes.CommF_:InvokeServer("BuySharkmanKarate", true)
                    Remotes.CommF_:InvokeServer("BuySharkmanKarate")
                elseif Type == "Library Key" then
                    Remotes.CommF_:InvokeServer("OpenLibrary")
                    local PhoeyuDoor = Services.Workspace.Map.IceCastle.Hall.LibraryDoor:FindFirstChild("PhoeyuDoor")
                    if PhoeyuDoor then
                        PhoeyuDoor:Destroy()
                    end
                elseif Type == "Red Key" then
                    alert("Red key", "Sumbitting red key to the scienctist.")
                    Remotes.CommF_:InvokeServer("CakeScientist", "Check")
                    if ScriptStorage.Tools["Red Key"] then
                        ScriptStorage.Tools["Red Key"]:Destroy()
                    end
                elseif Type == "Previous Hero" then
                    -- [FIX-55] "Start" chi lan dau: no sinh ra 3 dam may set. Da
                    -- diet xong thi lan sau kiem tra nhan thang, khong goi lai.
                    if not getgenv().ElectricClawCloudsDone then
                        Remotes.CommF_:InvokeServer("BuyElectricClaw", "Start")
                    end
                    task.wait(3)
                    -- [FIX-55] Gan co bay toi dai bang 20s: ban cu dung vong
                    -- repeat...until khong gioi han, neu toa do nay nam o bien
                    -- khac (Sea 1 vs Sea 2 la 2 server khac nhau) thi
                    -- DistanceFromCharacter khong bao gio < 30 -> thread ket hang
                    -- o day, khong bao gio toi buoc danh dam may.
                    local StageAt = os.time()
                    while
                        os.time() - StageAt < 20 and
                            game.Players.LocalPlayer:DistanceFromCharacter(Vector3.new(-12548, 332.378, -7617)) >=
                            30 do
                        task.wait()
                        TweenController.Create(CFrame.new(-12548, 332.378 + math.random(-2, 2), -7617))
                    end

                    -- [FIX-55] Den dai: diet 3 dam may set bang M1 kiem truoc khi
                    -- server cho Buy, neu khong BuyElectricClaw luong tra ve khac
                    -- 1 va vo dien v1 khong bao gio duoc nhan.
                    KillThunderClouds()

                    Data = MeleePrices["Electric Claw"]
                    Data.Buy(1)
                    FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Melee")
                elseif Type == "Uzoth" then
                    print("Use Fire Essence")
                    Remotes.CommF_:InvokeServer("BuyDragonTalon", true)
                    Remotes.CommF_:InvokeServer("BuyDragonTalon")
                    IsFireEssenceGave = true
                    print("Fire Essence Used")
                elseif Type == "Soul Reaper Spawner" then
                    print("Use Hallow Essence")

                    local HauntedCastle = workspace.Map:FindFirstChild("Haunted Castle")
                    if HauntedCastle and HauntedCastle:FindFirstChild("Summoner") and HauntedCastle.Summoner:FindFirstChild("Detection") then
                        if CaculateDistance(HauntedCastle.Summoner.Detection.CFrame) < 100 then
                            SpecialItems = nil
                        end
                        TweenController.Create(HauntedCastle.Summoner.Detection.CFrame)
                    else
                        print("[Soul Reaper Spawner] Haunted Castle not found or incomplete structure")
                    end
                end
            end
        )

        -- Trevor

        FunctionsHandler.Trevor:RegisterMethod(
            "GetFruit",
            function()
                for _, Fruit in ScriptStorage.Backpack do
                    if string.find(FruitIdToName(Fruit.Name), " Fruit") then
                        if Fruit.Value and Fruit.Value > 1000000 then
                            return Fruit
                        end
                    end
                end
            end
        )

        FunctionsHandler.Trevor:RegisterMethod(
            "Refresh",
            function()
                if FunctionsHandler.Trevor:Get("IsCompleted") or os.time() - StartTime < 1 then
                    return
                end

                if ScriptStorage.PlayerData.Level < 1100 then
                    return
                end

                local Fruit = FunctionsHandler.Trevor.Methods.GetFruit:Call()

                if Fruit then
                    FunctionsHandler.Trevor:Set("Fruit", Fruit)
                end

                TrevorDebounce = os.time()

                if not FunctionsHandler.Trevor:Get("IsCompleted") then
                    print("Update IsCompleted")
                    FunctionsHandler.Trevor:Set("IsCompleted", (Remotes.CommF_:InvokeServer("TalkTrevor", "1") == 0))
                    print(
                        "Update IsCompleted",
                        FunctionsHandler.Trevor:Get("IsCompleted"),
                        Remotes.CommF_:InvokeServer("TalkTrevor", "1"),
                        Remotes.CommF_:InvokeServer("TalkTrevor", "1") == 0
                    )
                end

                return not FunctionsHandler.Trevor:Get("IsCompleted") and Fruit
            end
        )

        FunctionsHandler.Trevor:RegisterMethod(
            "Start",
            function()
                alert("[ Cyndral ]", "Pulling fruit for trevor...")
                local Fruit = FunctionsHandler.Trevor:Get("Fruit")
                FunctionsHandler.Trevor:Set("Fruit", nil)
                if Fruit and not table.find(ScriptStorage.IgnoreStoreFruits, Fruit.Name) then
                    table.insert(ScriptStorage.IgnoreStoreFruits, Fruit.Name)
                end
                
                FunctionsHandler.Trevor:Set("IsLoadingFruit", true)
                
                Remotes.CommF_:InvokeServer("LoadFruit", Fruit.Name)
                task.wait(1) 
                FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call(FruitIdToName(Fruit.Name))
                task.wait(0.5) 
                FunctionsHandler.Trevor:Set("IsLoadingFruit", false)

                Remotes.CommF_:InvokeServer("TalkTrevor", "1")

                Remotes.CommF_:InvokeServer("TalkTrevor", "2")

                Remotes.CommF_:InvokeServer("TalkTrevor", "3")

                task.wait(1)
                FunctionsHandler.Trevor:Set("IsCompleted", true)
            end
        )

        print(4)
        -- Third Sea Puzzle
        FunctionsHandler.ThirdSeaPuzzle:RegisterMethod(
            "Refresh",
            function()
                if ScriptStorage.PlayerData.Level < 1500 or SeaIndex ~= 2 then
                    return
                end

                if nil == FunctionsHandler.ThirdSeaPuzzle:Get("State") then
                    ZQuestProgress = Remotes.CommF_:InvokeServer("ZQuestProgress", "Check")
                    print("ZQuestProgress", ZQuestProgress)
                    FunctionsHandler.ThirdSeaPuzzle:Set("State", ZQuestProgress == 0)
                end

                return FunctionsHandler.ThirdSeaPuzzle:Get("State")
            end
        )

        FunctionsHandler.ThirdSeaPuzzle:RegisterMethod(
            "Start",
            function()
                local State = FunctionsHandler.ThirdSeaPuzzle:Get("State")

                alert("1093", "start")
                if State then
                    alert("1095", "case test")
                    repeat
                        task.wait(1)
                        alert("1096", "fire")
                        print("StartResponse", Remotes.CommF_:InvokeServer("ZQuestProgress", "Begin"))
                    until CaculateDistance(Vector3.new(0, 0, 0)) > 20000

                    task.spawn(
                        function()
                            alert("1102", "rejoin")
                            task.wait(30)
                            SafeRejoinOrHop("Rejoin")
                       end
                    )

                    alert("attack")
                    while task.wait() do
                        CombatController.Attack("rip_indra")
                    end
                end
            end
        )

        FunctionsHandler.Yama:RegisterMethod(
            "Refresh",
            function()
                -- [FIX-19] sea1:6920 / sea2:7356 / sea3:7032 deu co chan nay, ban nay
                -- khong co -> tai Sea 3, khi EliteCount >= 30 Yama luon true va no dung
                -- truoc LevelFarm trong TasksOrder (11 vs 16), nen vong chinh call Start
                -- Yama moi frame. Start cua no chi fireclickdetector(SealedKatana) tu xa
                -- (server khong nhan click ngoai pham vi) va khong bao SetTask -> HUD
                -- "MainTask: n/a" va nhan vat dung im.
                if not Config.Items.CursedDualKatana and not Config.Items.Yama then
                    return
                end

                if SeaIndex ~= 3 then
                    return
                end

                if ScriptStorage.Backpack.Yama then
                    return
                end

                if not FunctionsHandler.Yama:Get("EliteCount") then
                    FunctionsHandler.Yama:Set("EliteCount", Remotes.CommF_:InvokeServer("EliteHunter", "Progress"))
                end

                if FunctionsHandler.Yama:Get("EliteCount") >= 30 then
                    return true
                end
            end
        )

        FunctionsHandler.Yama:RegisterMethod(
            "Start",
            function()
                if SeaIndex == 3 then 
                if
                    not workspace.Map:FindFirstChild("Waterfall") then
                         return TweenController.Create(CFrame.new(5251.89990234375, 37.18115234375, 453.6022644042969))
                    else
                        if not workspace.Map.Waterfall:FindFirstChild("SealedKatana") then
                         return TweenController.Create(CFrame.new(5251.89990234375, 37.18115234375, 453.6022644042969))

                        end
                 return                fireclickdetector(workspace.Map.Waterfall.SealedKatana.Hitbox.ClickDetector)

                end
            end
            end
        )

        FunctionsHandler.PirateRaid:RegisterMethod(
            "Refresh",
            function()
                local Senque = FunctionsHandler.PirateRaid:Get("Senque")

                return Senque and os.time() - Senque < 500
            end
        )

        FunctionsHandler.PirateRaid:RegisterMethod(
            "Start",
            function()
                local NearestMon = GetMonAsSortedRange()

                local SeaCastlePosition = Vector3.new(-5543.5327148438, 313.80062866211, -2964.2585449219)

                if NearestMon[1] then
                    local MonHumanoid, MonHumanoidRootPart =
                        NearestMon[1]:FindFirstChild("Humanoid"),
                        NearestMon[1]:FindFirstChild("HumanoidRootPart")

                    if
                        MonHumanoidRootPart and MonHumanoid and MonHumanoid.Health > 0 and
                            CaculateDistance(MonHumanoidRootPart.CFrame, SeaCastlePosition) < 500
                     then
                        CombatController.Attack(NearestMon[1].Name)
                        return
                    end
                end

                TweenController.Create(SeaCastlePosition)
            end
        )

        -- Soul guitar

        function CheckFullMoon()
           
            return Lighting:GetAttribute("MoonPhase") and (Lighting.ClockTime > 18 or Lighting.ClockTime < 5)
        end

        FunctionsHandler.SoulGuitar:RegisterMethod(
            "Refresh",
            function()
                if not Config.Items.SoulGuitar then
                    return
                end

                if ScriptStorage.Backpack["Skull Guitar"] or not ScriptStorage.Backpack["Dark Fragment"] then
                    return
                end

                if ScriptStorage.PlayerData.Level < 2300 then
                    return
                end

                local EctoplasmCount = (ScriptStorage.Backpack["Ectoplasm"] or {Count = 0})["Count"]
                local BonesCount = (ScriptStorage.Backpack["Bones"] or {Count = 0})["Count"]

                if EctoplasmCount < 250 then
                    return 1
                end

                if SeaIndex ~= 3 then
                    return
                end

                SoulGuitarProcess = Remotes.CommF_:InvokeServer("GuitarPuzzleProgress", "Check")

                if not SoulGuitarProcess then
                    Remotes.CommF_:InvokeServer("gravestoneEvent", 2)
                    if not CheckFullMoon() then
                        SetTask("MainTask", "Hopping for full moon ( soul guitar )")
                        -- Hop()
                    end
                    return 7
                end

                if not SoulGuitarProcess.Swamp then
                    return 2
                elseif not SoulGuitarProcess.Gravestones then
                    return 3
                elseif not SoulGuitarProcess.Ghost then
                    return 4
                elseif not SoulGuitarProcess.Trophies then
                    return 5
                elseif not SoulGuitarProcess.Pipes then
                    return 6
                elseif BonesCount >= 500 and not ScriptStorage.Backpack["Skull Guitar"] then
                    return 8
                end
            end
        )

        FunctionsHandler.SoulGuitar:RegisterMethod(
            "Start",
            function(State)
                if State == 7 then
                    while CaculateDistance(CFrame.new(-8654, 140, 6167)) > 5 do
                        task.wait()

                        TweenController.Create(CFrame.new(-8654, 140, 6167))
                    end
                    SoulGuitarProcess = Remotes.CommF_:InvokeServer("gravestoneEvent", 2, true)
                elseif State == 1 then
                    if SeaIndex ~= 2 then
                        SetTask("MainTask", "Teleport to second sea to farm ectoplasm")
                        return Remotes.CommF_:InvokeServer("TravelDressrosa")
                    else
                        SetTask("MainTask", "Farming ectoplasms for soul guitar")
                        CombatController.Attack({"Ship Deckhand", "Ship Engineer", "Ship Steward", "Ship Officer"})
                        return
                    end
                elseif State == 2 then
                    TTL9 = TTL9 or 0
                    if os.time() ~= LastestTime1 then
                        TTL9 = TTL9 + 1
                        LastestTime1 = os.time()
                    end

                    if TTL9 > 60 then
                        return 
                    end

                    local Objects = {}

                    for _, Entity in Services.Workspace.Enemies:GetChildren() do
                        if Entity.name == "Living Zombie" then
                            table.insert(Objects, Entity)
                        end
                    end

                    if #Objects < 6 then
                        SetTask("MainTask", "Soul Guitar task 1 / 5: waiting until entity spawn")
                        TweenController.Create(ScriptStorage.MobRegions["Living Zombie"][1] + Vector3.new(0, 30, 0))
                    else
                        local StartTime19 = os.time()
                        for Idx, Object in Objects do
                            while task.wait() and Object.Humanoid.Health > 7000 do
                                SetTask("MainTask", "Soul Guitar task 1 / 5: Hit mob " .. Idx .. " / 6")
                                FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Melee")
                                if os.time() - StartTime19 > 60 then
                                end

                                TweenController.Create(Object.HumanoidRootPart.CFrame + Vector3.new(0, 50, 0))
                                AttackController:Attack()
                            end
                        end
                        SetTask("MainTask", "Soul Guitar task 1 / 5: Attack")
                        while workspace.Enemies:FindFirstChild("Living Zombie") and task.wait() do
                            if os.time() - StartTime19 > 60 then
                            end

                            CombatController.Attack("Living Zombie")
                        end
                    end
                elseif State == 3 then
                    local HauntedIsland = workspace.Map:FindFirstChild("Haunted Castle")
                    if not HauntedIsland then
                        print("[Soul Guitar] Haunted Castle not found")
                        return
                    end
                    while CaculateDistance(CFrame.new(-8800, 178, 6033)) > 10 do
                        task.wait()
                        SetTask("MainTask", "Soul Guitar task 2 / 5: completing placards")
                        TweenController.Create(CFrame.new(-8800, 178, 6033))
                    end

                    for Placard, Side in {
                        Placard1 = "Right",
                        Placard2 = "Right",
                        Placard3 = "Left",
                        Placard4 = "Right",
                        Placard5 = "Left",
                        Placard6 = "Left",
                        Placard7 = "Left"
                    } do
                        fireclickdetector(HauntedIsland[Placard][Side].ClickDetector)
                    end
                elseif State == 4 then
                    Remotes.CommF_:InvokeServer("GuitarPuzzleProgress", "Ghost")
                elseif State == 5 then
                    if CaculateDistance(CFrame.new(-9530.0126953125, 6.104853630065918, 6054.83349609375)) > 30 then
                        TweenController.Create(CFrame.new(-9530.0126953125, 6.104853630065918, 6054.83349609375))
                    else
                        local HauntedCastle = workspace.Map:FindFirstChild("Haunted Castle")
                        if not HauntedCastle or not HauntedCastle:FindFirstChild("Tablet") then
                            print("[Soul Guitar] Haunted Castle or Tablet not found")
                            return
                        end
                        local DepTraiv4 = HauntedCastle.Tablet
                        for i, v in pairs(BlankTablets) do
                            local x = DepTraiv4[v]
                            if x.Line.Rotation.Z ~= 0 then
                                repeat
                                    task.wait()
                                    fireclickdetector(x.ClickDetector)
                                until x.Line.Rotation.Z == 0
                            end
                        end
                        for i, v in pairs(Trophy) do
                            local HauntedCastle = workspace.Map:FindFirstChild("Haunted Castle")
                            if not HauntedCastle or not HauntedCastle:FindFirstChild("Trophies") or not HauntedCastle.Trophies:FindFirstChild("Quest") or not HauntedCastle.Trophies.Quest:FindFirstChild(v) or not HauntedCastle.Trophies.Quest[v]:FindFirstChild("Handle") then
                                print("[Soul Guitar] Trophies structure not found for", v)
                                break
                            end
                            local x = HauntedCastle.Trophies.Quest[v].Handle.CFrame
                            x = tostring(x)
                            x = x:split(", ")[4]
                            local c = "180"
                            if x == "1" or x == "-1" then
                                c = "90"
                            end
                            if not string.find(tostring(DepTraiv4[i].Line.Rotation.Z), c) then
                                repeat
                                    task.wait()
                                    fireclickdetector(DepTraiv4[i].ClickDetector)
                                until string.find(tostring(DepTraiv4[i].Line.Rotation.Z), c)
                            end
                        end
                    end
                elseif State == 6 then
                    local HauntedCastle = workspace.Map:FindFirstChild("Haunted Castle")
                    if not HauntedCastle or not HauntedCastle:FindFirstChild("Lab Puzzle") or not HauntedCastle["Lab Puzzle"]:FindFirstChild("ColorFloor") or not HauntedCastle["Lab Puzzle"].ColorFloor:FindFirstChild("Model") then
                        print("[Soul Guitar] Lab Puzzle structure not found")
                        return
                    end
                    for i, v in pairs(Pipes) do
                        pcall(
                            function()
                                local x = HauntedCastle["Lab Puzzle"].ColorFloor.Model:FindFirstChild(i)
                                if not x then
                                    return
                                end
                                if x.BrickColor.Name ~= v then
                                    repeat
                                        task.wait()
                                        fireclickdetector(x.ClickDetector)
                                    until x.BrickColor.Name == v
                                end
                            end
                        )
                    end
                    Remotes.CommF_:InvokeServer("soulGuitarBuy")
                elseif State == 8 then
                    Remotes.CommF_:InvokeServer("soulGuitarBuy")
                end
            end
        )

        FunctionsHandler.Tushita:RegisterMethod(
            "Refresh",
            function()
                if ScriptStorage.Backpack.Tushita then
                    return
                end

                if ScriptStorage.PlayerData.Level < 2000 then
                    return
                end

                if SeaIndex ~= 3 then
                    return
                end

                TushitaProgress = TushitaProgress or Remotes.CommF_:InvokeServer("TushitaProgress")

                if not TushitaProgress.OpenedDoor then
                    if ScriptStorage.Enemies["rip_indra True Form"] then
                        TushitaProgress = nil
                        return 1
                    end
                else
                    if ScriptStorage.Enemies["Longma"] then
                        TushitaProgress = nil
                        return 2
                    end
                end
            end
        )

        FunctionsHandler.Tushita:RegisterMethod(
            "Start",
            function(State)
                if State == 1 then
                    alert("Auto Tushita", "Placing torches...")
                    if not ScriptStorage.Tools["Holy Torch"] then
                        FunctionsHandler.LocalPlayerController.Methods.EquipTool:Call("Holy Torch")
                        TweenController.Create(CFrame.new(5714, math.random(19, 21), 256)) -- Portal position
                        return
                    end

                    local TurtleMap = workspace.Map.Turtle.QuestTorches

                    for TorchIndex = 1, 5, 1 do
                        if TurtleMap:FindFirstChild("Torch" .. TorchIndex) then
                            repeat
                                task.wait()
                                TweenController.Create(TurtleMap:FindFirstChild("Torch" .. TorchIndex).CFrame)
                            until TurtleMap:FindFirstChild("Torch" .. TorchIndex).Particles.Main.Enabled
                        end
                    end
                elseif State == 2 then
                    alert("Auto Tushita", "Defeating Longma")
                    CombatController.Attack("Longma")
                end
            end
        )


        local Hooks = {
            Listeners = {}
        }

        TorchEnabledTime = 0
        DoneCdkTick = 0

        getgenv().NotificationCallBack = (function(Content)
            for ListenerContent, Callback in Hooks.Listeners do
                if string.find(string.lower(Content), string.lower(ListenerContent)) then
                    Callback(Content)
                end
            end
        end)

        function Hooks:RegisterNotifyListener(Senque, Callback)
            Hooks.Listeners[Senque] = Callback
        end

        Hooks:RegisterNotifyListener(
            "go!",
            function()
                LastRaidAlert = os.time()
            end
        )
        Hooks:RegisterNotifyListener(
            "oadi",
            function()
                LastRaidAlert2 = os.time()
            end
        )

        Hooks:RegisterNotifyListener(
            "been spotted approaching",
            function()
                FunctionsHandler.PirateRaid:Set("Senque", os.time())
            end
        )

        Hooks:RegisterNotifyListener(
            "job",
            function()
                FunctionsHandler.PirateRaid:Set("Senque", 0)
            end
        )

        Hooks:RegisterNotifyListener(
            "level",
            function()
                AddPoint()
            end
        )

        Hooks:RegisterNotifyListener(
            "torch",
            function()
                TorchEnabledTime = os.time()
            end
        )

        Hooks:RegisterNotifyListener(
            "scroll reacts",
            function()
                DoneCdkTick = os.time()
            end
        )

        Hooks:RegisterNotifyListener(
            "elite",
            function()
                FunctionsHandler.Yama:Set("EliteCount", Remotes.CommF_:InvokeServer("EliteHunter", "Progress"))

                alert(
                    "[ Bocchi Hub ] ",
                    "Elite defeated: " .. tostring(FunctionsHandler.Yama:Get("EliteCount") or "n/a")
                )
            end
        )

        Hooks:RegisterNotifyListener(
            "the raid with",
            function()
                if ScriptStorage.PlayerData.Level < MaxLevel then
                    return
                end
                Remotes.CommF_:InvokeServer("Awakener", "Awaken")
            end
        )

        Hooks:RegisterNotifyListener(
            "quest completed",
            function()
                QuestManager:RefreshQuest()
                task.wait()
                if not QuestManager:GetCurrentClaimQuest() then
                    QuestManager:MarkAsCompleted()
                end
            end
        )

        local old

        -- [FIX-15] PO guard tu sanglove-sea1.lua:7376. hookfunction/newcclosure khong
        -- ton tai tren Solara (xem [FIX-0]) nen phep gan o day lam chet ca mmb(), va
        -- Notification.new cua game thi doi khi cung khong co.
        pcall(
            function()
                local notifModule = game.ReplicatedStorage:FindFirstChild("Notification")
                if
                    typeof(hookfunction) == "function" and typeof(newcclosure) == "function" and
                        notifModule
                 then
                    local NotifNew = require(notifModule).new
                    if NotifNew then
                        old =
                            hookfunction(
                            NotifNew,
                            newcclosure(function(a, b)
                                v21 = tostring(tostring(a or "") .. tostring(b or "")) or ""
                                local cb = getgenv().NotificationCallBack
                                if type(cb) == "function" then
                                    cb(v21)
                                end
                                return {
                                    Display = function() end
                                }
                            end
                        ))
                    else
                        print("[FIX-15] Notification.new khong phai ham -> bo qua hook")
                    end
                else
                    print("[FIX-15] Thieu hookfunction/newcclosure/Notification -> bo qua hook")
                end
            end
        )

     
        if SeaIndex ~= 1 then
        end

        function IfTableHaveIndex(j)
            for _ in j do
                return true
            end
        end
        print(1)
        function GetServers()
            if LastServersDataPulled then
                if os.time() - LastServersDataPulled < 60 then
                    return CachedServers
                end
            end

            for i = 1, 100, 1 do
                local data = game:GetService("ReplicatedStorage"):WaitForChild("__ServerBrowser"):InvokeServer(i)
                if IfTableHaveIndex(data) then
                    LastServersDataPulled = os.time()
                    CachedServers = data
                    return data
                end
            end
        end

        spawn(
            function()
                GetServers()
                while task.wait(180) do
                    GetServers()
                end
            end
        )

        function Hop(Reason, MaxPlayers, ForcedRegion)
            local Servers = GetServers()
            local ArrayServers = {}

            for i, v in Servers do
                table.insert(
                    ArrayServers,
                    {
                        JobId = i,
                        Players = v.Count,
                        LastUpdate = v.__LastUpdate,
                        Region = v.Region
                    }
                )
            end
            print(#ArrayServers, "servers received")

            for i = 1, #ArrayServers do
                while task.wait() do
                    local Index = math.random(1, #ArrayServers)
                    ServerData = ArrayServers[Index]
                    if ServerData then
                        if not MaxPlayers or ServerData.Players < MaxPlayers then
                            if not ForcedRegion or ServerData.Region == ForcedRegion then
                                print(
                                    "Found Server:",
                                    ServerData.JobId,
                                    "Player Count:",
                                    ServerData.Players,
                                    "Region:",
                                    ServerData.Region
                                )
                                break
                            end
                        end
                    end
                end

                print("Teleporting to", ServerData.JobId, "...")
                game:GetService("ReplicatedStorage"):WaitForChild("__ServerBrowser"):InvokeServer(
                    "teleport",
                    ServerData.JobId
                )
            end
        end
        

        LowHop = function(Reason, PlayerLimit)
            local servers = {}
            local Limit = PlayerLimit or 5
            local req =
                game:HttpGet(
                "https://games.roblox.com/v1/games/" ..
                    game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true"
            )
            local body = game:GetService("HttpService"):JSONDecode(req)
        
            if body and body.data then
                for i, v in next, body.data do
                    if
                        type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < Limit and
                            v.id ~= JobId
                     then
                        table.insert(servers, 1, v.id)
                    end
                end
            end
        
            if #servers > 0 then
                local targetServer = servers[math.random(1, #servers)]
                local Remote = game:GetService("ReplicatedStorage"):FindFirstChild("__ServerBrowser")
                if Remote then
                    local success, err = pcall(function()
                        return Remote:InvokeServer("teleport", targetServer)
                    end)
                    if not success or err == false then
                        return alert("Serverhop", "Couldn't find a server.")
                    end
                -- Đã xóa bỏ phần else chứa code TeleportService ở đây
                else
                    return alert("Serverhop", "Couldn't teleport (No Remote found).")
                end
            else
                return alert("Serverhop", "Couldn't find a server.")
            end
        end



        Storage = {
            WRITE_DELAY = .5,
            Data = {}
        }

        Services = {}

        setmetatable(
            Services,
            {
                __index = function(_, Index)
                    return game:GetService(Index)
                end
            }
        )

        LocalPlayer = game.Players.LocalPlayer

        local StoragePath = ".storage_u_" .. tostring(LocalPlayer)

        function Decode(Content)
            return Services.HttpService:JSONDecode(Content)
        end

        function Encode(Content)
            return Services.HttpService:JSONEncode(Content)
        end

        print(5)
        function Storage.Set(Self, Key, Value)
            Self.Data[Key] = Value
        end

        function Storage.Get(Self, Key)
            --Report("Get: " .. tostring(Key or "n/a") .. " Value: " .. tostring(Self.Data[Key] or "n/") )
            return Self.Data[Key]
        end

        function Storage.Save(Self)
            pcall(function()
                writefile(StoragePath, Encode(Self.Data))
            end)
        end

        -- [FIX-1] isfile/writefile la ham cua executor, khong phai Lua. Thieu 1 trong 2
        -- la lenh nay lam chet ca script o top-level, khong loi bao truoc.
        pcall(function()
            if typeof(isfile) == "function" and typeof(writefile) == "function" and not isfile(StoragePath) then
                writefile(StoragePath, "{}")
                task.wait(1)
            end
        end)

        Storage.Data = {}

        --Report(readfile(StoragePath))
        pcall(
            function()
                Storage.Data = Decode(readfile(StoragePath) or "{}")
            end
        )

        spawn(
            function()
                while task.wait(Storage.WRITE_DELAY) do
                    Storage:Save()
                end
            end
        )
        CreateTraceback("Initalize", "Initalizing script...")
        -- [FIX-2] Chuoi index truc tiep PlayerGui.Main.SettingsMenu.Content.ScrollingFrame.
        -- FastMode.FirstButton: game doi ten menu thi nil giua chuoi -> script chet ngay
        -- tai day, va day la viec cuoi cung no kip lam (HUD dung o "Initalizing Script").
        pcall(
            function()
                if typeof(getconnections) ~= "function" then
                    return
                end
                local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
                local main = pg and pg:FindFirstChild("Main")
                local fast = main and main:FindFirstChild("SettingsMenu.Content.ScrollingFrame.FastMode")
                if not fast and main then
                    fast = main:FindFirstChild("FastMode", true)
                end
                local btn = fast and (fast:FindFirstChild("FirstButton") or fast:FindFirstChildOfClass("TextButton"))
                if not btn then
                    print("[FIX-2] Khong thay FastMode.FirstButton -> bo qua FastMode")
                    return
                end
                for _, Connection in getconnections(btn.Activated) do
                    Connection.Function()
                end
            end
        )
      
        function boostfps()
            local Terrain = workspace:FindFirstChildOfClass('Terrain')
            local ReplicatedStorage = game.ReplicatedStorage
            local Players = game.Players
            local Player = Players.LocalPlayer
            local RunService = game:GetService("RunService")
            local Lighting = game:GetService("Lighting")

            -- Tắt nước
            if Terrain then
                Terrain.WaterWaveSize = 0
                Terrain.WaterWaveSpeed = 0
                Terrain.WaterReflectance = 0
                Terrain.WaterTransparency = 1
            end

            -- Xóa map không cần thiết để tăng FPS
            pcall(function()
                -- Xóa clouds trong workspace
                for _, v in ipairs(workspace:GetChildren()) do
                    if v.Name == "Clouds" or v.Name == "Cloud" then
                        pcall(function() v:Destroy() end)
                    end
                end

                -- Xóa skybox/decoration trong lighting
                for _, v in ipairs(Lighting:GetChildren()) do
                    if v:IsA("Sky") or v:IsA("Decal") then
                        pcall(function() v:Destroy() end)
                    end
                end

                -- Xóa map decorations (part nằm trong Map folder)
                local Map = workspace:FindFirstChild("Map")
                if Map then
                    for _, v in ipairs(Map:GetChildren()) do
                        local name = v.Name:lower()
                        if name:find("tree") or name:find("plant") or name:find("rock") or
                           name:find("fence") or name:find("decoration") or name:find("grass") or
                           name:find("bush") or name:find("flower") or name:find("sign") then
                            pcall(function() v:Destroy() end)
                        end
                    end
                end

                -- Xóa spawn location effects
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("Sound") then
                        pcall(function() v:Destroy() end)
                    end
                end
            end)

            -- Tắt lighting
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.FogStart = 9e9

            -- Giảm quality level
            pcall(function()
                settings().Rendering.QualityLevel = 1
            end)

            -- Xóa lighting children
            pcall(function()
                Lighting:ClearAllChildren()
            end)

            -- Xóa effect particles cho non-character parts
            pcall(function()
                for _, v in ipairs(game:GetDescendants()) do
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") then
                        pcall(function() v.Lifetime = NumberRange.new(0) end)
                    elseif v:IsA("AnimationController") then
                        pcall(function() v:Destroy() end)
                    end
                end
            end)

            -- Xử lý existing characters
            for _, player1 in pairs(Players:GetChildren()) do
                if player1.Character then
                    task.spawn(function()
                        task.wait(0.5)
                        for _, part in pairs(player1.Character:GetChildren()) do
                            if part:IsA("Accessory") or part.Name == "Radio" then
                                pcall(function() part:Destroy() end)
                            end
                        end
                    end)
                end
                player1.CharacterAdded:Connect(function(char)
                    task.wait(0.5)
                    for _, part in pairs(char:GetChildren()) do
                        if part:IsA("Accessory") or part.Name == "Radio" then
                            pcall(function() part:Destroy() end)
                        end
                    end
                end)
            end

            -- Bug 1 FIX: Chỉ destroy thứ KHÔNG phải Model/Folder trong _WorldOrigin
            workspace._WorldOrigin.ChildAdded:Connect(function(child)
                pcall(function()
                    if not child:IsA("Model") and not child:IsA("Folder") then
                        child:Destroy()
                    end
                end)
            end)

            -- Xóa cache folder trong ReplicatedStorage
            pcall(function()
                local candelete = {"Cache", "Cache2"}
                for _, v in ipairs(ReplicatedStorage:GetChildren()) do
                    if table.find(candelete, v.Name) then
                        pcall(function() v:Destroy() end)
                    end
                end
            end)

            -- Camera và Terrain child cleanup
            workspace.Camera.ChildAdded:Connect(function(child)
                pcall(function() child:Destroy() end)
            end)

            if Terrain then
                Terrain.ChildAdded:Connect(function(child)
                    pcall(function() child:Destroy() end)
                end)
            end

            -- Bug 3 FIX: Thêm pcall cho DescendantAdded, bỏ qua character
            workspace.DescendantAdded:Connect(function(child)
                task.spawn(function()
                    pcall(function()
                        -- Chỉ xử lý effect, KHÔNG transparent player character
                        if child:IsA("ForceField") or child:IsA("Sparkles") or
                           child:IsA("Smoke") or child:IsA("Fire") or child:IsA("Beam") then
                            child:Destroy()
                            return
                        end

                        -- Bỏ qua character parts của player
                        local char = Player.Character
                        if char and (child:IsDescendantOf(char) or child == char) then
                            return
                        end

                        if child:IsA("BasePart") then
                            child.Material = "Plastic"
                            child.Reflectance = 0
                            child.BackSurface = "SmoothNoOutlines"
                            child.BottomSurface = "SmoothNoOutlines"
                            child.FrontSurface = "SmoothNoOutlines"
                            child.LeftSurface = "SmoothNoOutlines"
                            child.RightSurface = "SmoothNoOutlines"
                            child.TopSurface = "SmoothNoOutlines"
                            child.Transparency = 1
                            child.CastShadow = false
                        elseif child:IsA("Decal") then
                            child.Transparency = 1
                        elseif child:IsA("AnimationController") then
                            child:Destroy()
                        end
                    end)
                end)
            end)
        end  
        if Config.Configuration.FpsBoost then
            boostfps()
        end
        repeat wait() until game:IsLoaded() 
        spawn(function()
            while wait() do 
                    pcall(function()
                        repeat wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local old = tick()

                    local oldpos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position 
                    repeat wait() 
                    until tick() - old >= 5*60 or oldpos ~= game.Players.LocalPlayer.Character.HumanoidRootPart.Position 
                    if tick() - old >= 5*60 then 
                        Hop("Stuck start Rejoin")
                    end
                end)

            end
        end)
        
        local LogCache = {}
        SetTask("MainTask", "n/a")
        SetTask("SubTask", "n/a")
        ParsingTimes = 0 
        function RefreshTasksData()
            if _G.Stop then
                return
            end
            for _, TaskName in TasksOrder do
                local Task = FunctionsHandler[TaskName]
                if Task then
                    if not Task.Initalized then
                        if not LogCache[TaskName] then
                            print("[ Debug ] Task", TaskName, "is not registered yet")
                            LogCache[TaskName] = true
                        end
                    else
                        local Refresh = Task.Methods and Task.Methods.Refresh
                        local Start = Task.Methods and Task.Methods.Start

                        if Refresh then
                            local ok, RefreshValue = pcall(function()
                                return Refresh:Call(ParsingTimes < 100)
                            end)

                            ParsingTimes = ParsingTimes + 1
                            if ok and RefreshValue then
                                CurrentTask = TaskName
                                if ScriptStorage.Interface and type(ScriptStorage.Interface.SetText) == "function" then
                                    pcall(function() ScriptStorage.Interface.SetText("DebugLine", TaskName) end)
                                end
                                if Start then
                                    -- [FIX-32] pcall an cua ham Start la ly do moi
                                    -- lan "nhan quest xong dung im" khong co dong
                                    -- loi nao tren console. In ra ten task + loi.
                                    local okStart, errStart =
                                        pcall(
                                        function()
                                            Start:Call(RefreshValue)
                                        end
                                    )
                                    if not okStart then
                                        print("[FIX-32] Task '" .. tostring(TaskName) .. "' loi trong Start: " .. tostring(errStart))
                                    end
                                end
                                return
                            end
                        end
                    end
                end
            end
        end

        SetText("MainTextLabel", "Refreshing Player Items...")
        pcall(RefreshPlayerData)
        pcall(AddPoint)
        pcall(function() QuestManager:RefreshQuest() end)
        SetText("MainTextLabel", "Loading Inventory...")
        pcall(RefreshInventory)
        SetText("MainTextLabel", "Loading Race...")
        pcall(RefreshRace)
        Remotes.CommE.OnClientEvent:Connect(
            function(...)
                local data = {...}
                -- print(..., "additem")
                if string.find(data[1], "Item") then
                    RefreshInventory()
                end
            end
        )

        RefreshRace()

        Players.LocalPlayer.Idled:Connect(
            function()
                Services.VirtualUser:CaptureController()
                Services.VirtualUser:ClickButton2(Vector2.new())
            end
        )

        SetText("MainTextLabel", "Loaded In " .. tick() - StartTick .. "ms!")
        Loaded = 1
        QueueList = {}


        function NearbyHopHandler()
        -- Debounce: chỉ cho chạy 1 lần mỗi 10s
            local now = os.time()
            if NearbyHopHandlerDebounce and now - NearbyHopHandlerDebounce < 10 then
                return
            end
            NearbyHopHandlerDebounce = now
        
            -- Kiểm tra xem có đang đánh boss không
            local mainTask = ScriptStorage.Task.MainTask
            if type(mainTask) == "string" and (string.find(mainTask, "Auto Farm Boss") or string.find(mainTask, "Defeating Cake Prince")) then
                -- Đang đánh boss → không hop
                return
            end
        
            local localPlayer = Players.LocalPlayer
        
            for _, player in ipairs(Players:GetPlayers()) do
                -- Bỏ qua chính mình
                if player ~= localPlayer then
                    local char = player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local position = hrp.Position
        
                        local firstSeenTime = QueueList[player.Name]
                        if not firstSeenTime then
                            -- Lần đầu phát hiện player này
                            QueueList[player.Name] = now
                        else
                            -- Nếu đã thấy > 30s thì mới kiểm tra khoảng cách
                            if now - firstSeenTime > 30 then
                                if CaculateDistance(position) < 100 then
                                    -- Có player đứng gần quá 100 studs trong > 30s → hop
                                    LowHop("Nearby plr")
                                    task.wait(5)
                                    return -- hop rồi thì khỏi xử lý tiếp
                                else
                                    -- Không còn gần nữa → xoá khỏi queue
                                    QueueList[player.Name] = nil
                                end
                            end
                        end
                    end
                end
            end
        end

        -- Chạy NearbyHopHandler định kỳ để check players gần
        task.spawn(function()
            while task.wait(5) do
                if not _G.Stop then
                    pcall(NearbyHopHandler)
                end
            end
        end)
        
        if ScriptStorage.PlayerData.Level > 2000 then 
            game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyHaki", "Geppo")
            game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyHaki", "Buso")
            game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyHaki", "Soru")
            game.ReplicatedStorage.Remotes.CommF_:InvokeServer("KenTalk", "Buy") 
        end
        
         function getcandies()
            for i,v in game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("getInventory") do
                if v.Name ==  "Candy" then 
                    return v.Count
                end
            end
            return 0
         end
        -- Optimized refresh loop with delay to reduce FPS impact
        task.spawn(
            function()
                while task.wait(1) do  -- Changed from task.wait() to task.wait(1) to reduce FPS impact
                    if not _G.Stop then
                        
                        if LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Sit then
                            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end

                        if true or RefreshDebounce ~= os.time() then
                            pcall(RefreshPlayerData)
                            local Elapsed = os.time() - StartTime
                            local TotalElapsed = Elapsed + OldSessionTime

                            writefile(".tdif-" .. game.Players.LocalPlayer.Name, tostring(TotalElapsed))

                            if ScriptStorage.Interface then
                                SetText(
                                    "LiveTime",
                                    "Total Elapsed Time: " ..
                                        DispTime(TotalElapsed, true) .. " Elapsed Time: " .. DispTime(Elapsed, true)
                                )
                            end
                            RefreshDebounce = os.time()
                        end
                    end
                end
            end
            
        )

        -- [FIX-45] ---- Random trai moi 60s + dieu khien farm Fragments ----
        -- Port tu script standalone "RANDOM TRAI TU XA & TU DONG CAT RUONG",
        -- them 2 dieu kien user yeu cau: khong cat khi dang raid, va ruong da
        -- co trai thi ngung cat de di raid kiem Fragments (diem F).
        local CHECK_INTERVAL = 60
        local RAID_TASK = "RaidController"
        local RAID_ISLAND_NAMES = {nil, "CircleIsland", "Boat Castle"}

        -- Start cua RaidController tim "RaidSummon2" trong dao raid o tren; khong
        -- co no thi return lan luot moi ~1s ma khong phat lenh di chuyen nao =>
        -- nhan vat dung im (xem [FIX-28]). Chi bat task khi dao nay nam duoc.
        local function RaidIslandReady()
            local ok, ready = pcall(
                function()
                    local rootName = RAID_ISLAND_NAMES[SeaIndex]
                    if not rootName then
                        return false
                    end
                    local island =
                        (workspace.Map and workspace.Map:FindFirstChild(rootName)) or workspace:FindFirstChild(rootName)
                    return island ~= nil and island:FindFirstChild("RaidSummon2") ~= nil
                end
            )
            return (ok and ready) == true
        end

        -- [FIX-48] GachaNetworkRF tra ve BANG; in truc tiep thi log chi ra
        -- "table: 0x...", nen tom tat vai key dau tien ra chuoi de do.
        local function DescribeRoll(v)
            if type(v) ~= "table" then
                return tostring(v)
            end
            local parts, total = {}, 0
            for Key, Val in pairs(v) do
                total = total + 1
                if #parts < 6 and type(Val) ~= "table" then
                    parts[#parts + 1] = tostring(Key) .. "=" .. tostring(Val)
                end
            end
            return "table(n=" .. tostring(total) .. ") " .. table.concat(parts, ", ")
        end

        -- Dung dung thu tu cua ban paste: "Cousin" "Buy" truoc, chi khi no khong
        -- tra ve gia tri nao moi thu GachaNetworkRF (Context=Purchase,
        -- BoxName=ZiolesGacha) -> khong lo quay 2 lan trong cung 1 nhip.
        -- Khong dung WaitForChild o day: tren client nay no tung gay infinite
        -- yield (dong "HauntedPuzzle" trong log).
        local function RollFruit()
            local ok, res = pcall(
                function()
                    return Remotes.CommF_:InvokeServer("Cousin", "Buy")
                end
            )
            if ok and res ~= nil and res ~= false then
                return res, "Cousin"
            end

            local ok2, res2 = pcall(
                function()
                    local Modules = game:GetService("ReplicatedStorage"):FindFirstChild("Modules")
                    local Net = Modules and Modules:FindFirstChild("Net")
                    local GachaRF = Net and Net:FindFirstChild("RF/GachaNetworkRF")
                    if not GachaRF then
                        return nil
                    end
                    return GachaRF:InvokeServer({Context = "Purchase", BoxName = "ZiolesGacha"})
                end
            )
            if ok2 and res2 ~= nil then
                return res2, "GachaNetworkRF"
            end
            return nil, "Cousin"
        end

        task.spawn(
            function()
                task.wait(10)
                while true do
                    local ok, err = pcall(
                        function()
                            if not (Remotes and Remotes.CommF_) then
                                print("[FIX-45] chua co Remotes.CommF_ -> bo qua 1 lan quay")
                                return
                            end

                            if type(AddPoint) == "function" then
                                AddPoint()
                            end

                            -- Ruong da co trai => ngung cat va bat farm diem F.
                            local chestCount = GetChestFruitCount()
                            local orderIdx = table.find(TasksOrder, RAID_TASK)
                            if chestCount ~= nil and chestCount > 0 then
                                if not orderIdx then
                                    if RaidIslandReady() then
                                        table.insert(TasksOrder, table.find(TasksOrder, "LevelFarm") or (#TasksOrder + 1), RAID_TASK)
                                        print(
                                            "[FIX-45] ruong co " .. tostring(chestCount) ..
                                                " trai -> bat RaidController de farm diem F"
                                        )
                                    else
                                        print(
                                            "[FIX-45] ruong co trai nhung dao raid (" ..
                                                tostring(RAID_ISLAND_NAMES[SeaIndex]) ..
                                                ") khong ton tai -> van farm cap nhat, khong bat raid"
                                        )
                                    end
                                end
                            elseif orderIdx and not IsInRaidNow() then
                                table.remove(TasksOrder, orderIdx)
                                print("[FIX-45] ruong da trong -> tat RaidController, quay lai LevelFarm")
                            end

                            -- Cat trai dang mang TRUOC khi quay (duoc phep moi cat).
                            if CanStoreFruit() then
                                StoreCarriedFruits("pre-roll")
                            end

                            -- [FIX-48] Quay dung theo ban paste: "Cousin" truoc,
                            -- neu no khong tra ve gi thi moi thu GachaNetworkRF.
                            local result, via = RollFruit()
                            print("[FIX-48] random trai (" .. tostring(via) .. "): " .. DescribeRoll(result))
                            if result ~= nil and result ~= false then
                                task.wait(1.5)
                                if CanStoreFruit() then
                                    StoreCarriedFruits("post-roll")
                                else
                                    print("[FIX-45] trai quay duoc giu nguyen vi gate cat trai dang tat")
                                end
                            end
                        end
                    )
                    if not ok then
                        print("[FIX-45] vong quay 60s bi loi: " .. tostring(err))
                    end
                    task.wait(CHECK_INTERVAL)
                end
            end
        )

       
        while task.wait() do
            --[[
            if not SendDataDelay or os.time() - SendDataDelay > Config.Authorize.SendDelay then 
                SendDataDelay = os.time() 
                pcall(SendData)
            end ]]
            local success, response = xpcall(RefreshTasksData, debug.traceback)
            -- Chỉ chạy MeleesController khi KHÔNG đang trong raid
            local IsInRaid = FunctionsHandler.RaidController and FunctionsHandler.RaidController:Get("IsInRaidProcess")
            if not IsInRaid then
                -- [FIX-3] Nam NGOAI xpcall: thieu MeleesController la chet han vong chinh.
                -- [FIX-47] pcall AN loi cua melee chinh la ly do "tien du ma vo
                -- khong duoc mua" khong co dau vet tren console. In ra, toi da
                -- 1 lan / 10s de khong nghet log.
                local okMelee, errMelee = pcall(
                    function()
                        local melee = FunctionsHandler.MeleesController
                        if melee and melee.Methods and melee.Methods.Start then
                            melee.Methods.Start:Call()
                        end
                    end
                )
                if not okMelee and (not MeleeErrAt or os.time() - MeleeErrAt > 10) then
                    MeleeErrAt = os.time()
                    print("[FIX-47] MeleesController.Start bi loi: " .. tostring(errMelee))
                end
            end
            -- [FIX-18] Xoa 3 lenh print(0)/(1)/(2) ma tac gia de lai trong vong lap
            -- chay moi frame: no in ~180 dong/giay va lam nghet cua so log.
            if not success then
                Report(response)
            end
        end

    end
    -- Remote kunblox script removed
        
    local success2, response2 = xpcall(mmb, debug.traceback)
    if not success2 then
        Report(response2)
    end
