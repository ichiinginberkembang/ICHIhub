local env = (getgenv and getgenv()) or _G
for _, name in ipairs({"AutoJawabProMax"}) do
    local old = env[name]
    if type(old) == "table" then
        old.running = false
        if old.connection then pcall(function() old.connection:Disconnect() end) end
        for _, c in ipairs(old.connections or {}) do
            pcall(function() c:Disconnect() end)
        end
    end
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local state = {running = true, auto = false, connections = {}}
env.AutoJawabProMax = state

local settings = {mode = "fixed", fixed = 0.8, minimum = 0.8, maximum = 2.0}

local lastSoal = ""

local fractionMap = {
    ["½"]="(1/2)", ["⅓"]="(1/3)", ["⅔"]="(2/3)",
    ["¼"]="(1/4)", ["¾"]="(3/4)", ["⅕"]="(1/5)",
    ["⅖"]="(2/5)", ["⅗"]="(3/5)", ["⅘"]="(4/5)",
    ["⅙"]="(1/6)", ["⅚"]="(5/6)", ["⅐"]="(1/7)",
    ["⅛"]="(1/8)", ["⅜"]="(3/8)", ["⅝"]="(5/8)",
    ["⅞"]="(7/8)", ["⅑"]="(1/9)", ["⅒"]="(1/10)",
}

local smallDigits = {
    ["⁰"]="0", ["¹"]="1", ["²"]="2", ["³"]="3", ["⁴"]="4",
    ["⁵"]="5", ["⁶"]="6", ["⁷"]="7", ["⁸"]="8", ["⁹"]="9",
    ["₀"]="0", ["₁"]="1", ["₂"]="2", ["₃"]="3", ["₄"]="4",
    ["₅"]="5", ["₆"]="6", ["₇"]="7", ["₈"]="8", ["₉"]="9",
}

local function clean(text)
    local s = text:gsub("<[^>]*>", "")
        :gsub("−", "-"):gsub("–", "-")
        :gsub("×", "*"):gsub("÷", "/")
        :gsub("%?+", "?"):gsub("…", ""):gsub("%.%.%.", "")
    if s:find("⁄", 1, true) then
        for symbol, digit in pairs(smallDigits) do s = s:gsub(symbol, digit) end
        s = s:gsub("⁄", "/")
    else
        s = s:gsub("²", "^2"):gsub("³", "^3")
    end
    for symbol, value in pairs(fractionMap) do
        s = s:gsub("(%d+)%s+" .. symbol, function(whole) return "(" .. whole .. "+" .. value .. ")" end)
        s = s:gsub(symbol, value)
    end
    return s
end

local function close(a, b)
    return math.abs(a - b) <= 1e-7 * math.max(1, math.abs(a), math.abs(b))
end

local function calculate(text)
    local s = clean(text):gsub("%s+", ""):gsub("%%$", "/100")
    if #s == 0 or #s > 256 then return nil end
    local pos = 1
    local priority = {["+"]=10, ["-"]=10, ["*"]=20, ["/"]=20, ["^"]=30}
    local function peek() return s:sub(pos, pos) end
    local parse
    parse = function(minimum)
        local value, ch = nil, peek()
        if ch == "+" or ch == "-" then
            pos = pos + 1
            value = parse(25)
            if ch == "-" then value = -value end
        elseif ch == "(" then
            pos = pos + 1
            value = parse(0)
            if peek() ~= ")" then return nil end
            pos = pos + 1
        else
            local tail = s:sub(pos)
            local number = tail:match("^%d+%.?%d*") or tail:match("^%.%d+")
            if not number then return nil end
            value = tonumber(number)
            if not value then return nil end
            pos = pos + #number
        end
        while true do
            local op = peek()
            local p = priority[op]
            if not p or p < minimum then break end
            pos = pos + 1
            local right = parse(op == "^" and p or p + 1)
            if not right then return nil end
            if op == "+" then value = value + right
            elseif op == "-" then value = value - right
            elseif op == "*" then value = value * right
            elseif op == "/" then
                if right == 0 then return nil end
                value = value / right
            else value = value ^ right end
        end
        return value
    end
    local ok, value = pcall(function()
        local n = parse(0)
        if pos <= #s then return nil end
        return n
    end)
    if ok and type(value) == "number" and value == value and math.abs(value) < math.huge then
        return value
    end
    return nil
end

local function sequence(text)
    if not text:find(",", 1, true) or not text:match("^[%d%s,%?%.%+%-]+$") then return nil end
    local known, missing, count = {}, nil, 0
    for part in (text..","):gmatch("(.-),") do
        count = count + 1
        if part:match("^%s*%?%s*$") then
            if missing then return nil end
            missing = count
        else
            local n = tonumber(part)
            if not n then return nil end
            known[#known+1] = {index=count, value=n}
        end
    end
    if #known < 3 or not missing then return nil end
    local first, second = known[1], known[2]
    local difference = (second.value - first.value) / (second.index - first.index)
    local arithmetic = true
    for _, item in ipairs(known) do
        local predicted = first.value + difference * (item.index - first.index)
        if not close(predicted, item.value) then arithmetic = false break end
    end
    local arithmeticValue = arithmetic and (first.value + difference * (missing - first.index)) or nil
    local ratio
    for i = 2, #known do
        local prev, cur = known[i-1], known[i]
        if cur.index - prev.index == 1 and prev.value ~= 0 then
            ratio = cur.value / prev.value
            break
        end
    end
    if not ratio or ratio == 0 then return arithmeticValue end
    for _, item in ipairs(known) do
        local predicted = first.value * ratio ^ (item.index - first.index)
        if not close(predicted, item.value) then return arithmeticValue end
    end
    local geometricValue = first.value * ratio ^ (missing - first.index)
    if arithmeticValue ~= nil and not close(arithmeticValue, geometricValue) then return nil end
    return geometricValue
end

local function findChild(root, path)
    for name in path:gmatch("[^.]+") do
        root = root and root:FindFirstChild(name)
        if not root then return nil end
    end
    return root
end

local function isVisible(obj)
    if not obj then return false end
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not obj:IsDescendantOf(pg) then return false end
    while obj and obj ~= pg do
        if obj:IsA("GuiObject") and not obj.Visible then return false end
        obj = obj.Parent
    end
    return true
end

local function bacaSoal()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return nil, nil, nil end
    local gameplay = pg:FindFirstChild("Gameplay")
    if not gameplay then return nil, nil, nil end
    local center, topic
    for _, name in ipairs({"TopicFrame", "TopicFrameBottom"}) do
        local candidateCenter = findChild(gameplay, "TopicGui." .. name .. ".CenterFrame")
        if isVisible(candidateCenter) then
            local main = candidateCenter:FindFirstChild("TopicLabel")
            local side = candidateCenter:FindFirstChild("SideTopicLabel")
            if isVisible(main) or isVisible(side) then
                center = candidateCenter
                topic = isVisible(main) and main or side
                break
            end
        end
    end
    if not topic then return nil, nil, nil end
    return topic.Text, center, gameplay
end

local function bacaTombol(gameplay)
    local list = {}
    if not gameplay then return list end
    local input = findChild(gameplay, "AnswerGui.AnswerFrame.CenterFrame.InputFrame")
    if not isVisible(input) then return list end
    for i = 1, 4 do
        local btn = findChild(input, "Answer" .. i .. ".TriggerBtn")
        if btn and btn:IsA("TextButton") and isVisible(btn) then
            local raw = btn.Text
            local cleanText = (raw:gsub("%s", "")):gsub("%%", "")
            local fa, fb = cleanText:match("^(%d+%.?%d*)/(%d+%.?%d*)$")
            if fa and fb then
                table.insert(list, {btn = btn, value = tonumber(fa)/tonumber(fb), raw = raw, index = i})
            else
                local num = tonumber(cleanText)
                if num then table.insert(list, {btn = btn, value = num, raw = raw, index = i}) end
            end
        end
    end
    return list
end

local function bacaGraphic(center)
    local data = {}
    if not center then return data end
    local content = center:FindFirstChild("ContentFrame")
    if not isVisible(content) then return data end
    for _, entry in ipairs({{"ShapeObject","rectangle"}, {"TriangleObject","triangle"}}) do
        local shape = content:FindFirstChild(entry[1])
        if isVisible(shape) then
            local w = findChild(shape, "WidthSizeFrame.SizeLabel")
            local h = findChild(shape, "HeightSizeFrame.SizeLabel")
            if isVisible(w) and isVisible(h) then
                data[entry[2]] = {width = calculate(w.Text), height = calculate(h.Text)}
            end
        end
    end
    local clock = content:FindFirstChild("AnalogClockFrame")
    if isVisible(clock) then
        local hour = clock:FindFirstChild("HOUR_HAND")
        local minute = clock:FindFirstChild("MINUTE_HAND")
        if isVisible(hour) and isVisible(minute) then
            data.clock = {hour = hour.Rotation, minute = minute.Rotation}
        end
    end
    return data
end

local function solve(question, answers, instruction, graphic)
    answers = answers or {}
    instruction = instruction or ""
    local text = clean(question)
    local wording = clean(question .. " " .. instruction)
    local english = wording:lower()
    
    if graphic then
        local area = english:find("area", 1, true) or instruction:find("luas", 1, true)
        local perimeter = english:find("perimeter", 1, true) or instruction:find("keliling", 1, true)
        if area or perimeter then
            local shape = graphic.triangle or graphic.rectangle
            if shape and shape.width and shape.height and shape.width > 0 and shape.height > 0 then
                if area then return shape.width * shape.height / (graphic.triangle and 2 or 1) end
                if graphic.rectangle and not graphic.triangle then return 2 * (shape.width + shape.height) end
            end
            return nil
        end
        if graphic.clock then
            local minuteAngle = graphic.clock.minute % 360
            local hourAngle = graphic.clock.hour % 360
            local minute = math.floor(minuteAngle/6 + 0.5) % 60
            local hour = math.floor(hourAngle/30 + 1e-5) % 12
            if hour == 0 then hour = 12 end
            return string.format("%d:%02d", hour, minute)
        end
    end
    
    local left, right = text:match("^(.-)%[%s*%?%s*%](.-)$")
    if not left then left, right = text:match("^(.-)%?(.-)$") end
    if left and not text:find("=", 1, true) then
        local a, b = calculate(left), calculate(right)
        if a and b then return close(a,b) and "=" or (a > b and ">" or "<") end
    end
    
    local nextNum = sequence(text)
    if nextNum ~= nil then return nextNum end
    
    if english:find("nearest whole") or english:find("nearest integer") then
        local numbers = {}
        for token in text:gsub(",", "."):gmatch("[+-]?%d+%.?%d*") do
            numbers[#numbers+1] = tonumber(token)
        end
        if #numbers == 1 then
            local n = numbers[1]
            return n >= 0 and math.floor(n + 0.5) or math.ceil(n - 0.5)
        end
        return nil
    end
    
    if english:find("odd or even") or english:find("even or odd") then
        local n = calculate(text) or tonumber(text:match("[+-]?%d+"))
        if n and n % 1 == 0 then return n % 2 == 0 and "even" or "odd" end
        return nil
    end
    
    left, right = text:match("^%s*(.-)%s*=%s*(.-)%s*$")
    if not left then return calculate(text:gsub("[xX]", "*")) end
    
    local percent = right:match("^%s*%?%s*%%%s*$")
    if right:match("^%s*%?%s*$") or percent then
        if not left:find("?", 1, true) then
            local n = calculate(left:gsub("[xX]", "*"))
            if n then return percent and tostring(n * 100) .. "%" or n end
        end
    end
    
    local hasQuestion = text:find("?", 1, true) ~= nil
    local hasX = text:find("[xX]") ~= nil
    if not hasQuestion and not hasX then return nil end
    
    local function difference(n)
        local replacement = "(" .. string.format("%.15f", n) .. ")"
        local function substitute(part)
            if hasQuestion then
                part = part:gsub("[xX]", "*"):gsub("%?", function() return replacement end)
            else
                part = part:gsub("[xX]", function() return replacement end)
            end
            return calculate(part)
        end
        local a, b = substitute(left), substitute(right)
        if a and b then return a - b end
    end
    
    local d0, d1, d2 = difference(0), difference(1), difference(2)
    if d0 and d1 and d2 then
        local slope = d1 - d0
        if not close(slope, 0) and close(d2 - d1, slope) then
            local n = -d0 / slope
            local check = difference(n)
            if check and close(check, 0) then return n end
        end
    end
    
    local result
    for _, answer in ipairs(answers) do
        local n = calculate(answer.raw)
        if n then
            local check = difference(n)
            if check and close(check, 0) then
                if result ~= nil and not close(result, n) then return nil end
                result = n
            end
        end
    end
    return result
end

local function klikTombol(btn)
    if not isVisible(btn) then return false end
    
    -- Metode 1: firesignal
    pcall(function() firesignal(btn.MouseButton1Click) end)
    task.wait(0.03)
    
    -- Metode 2: firesignal Down + Up
    pcall(function()
        firesignal(btn.MouseButton1Down)
        task.wait(0.02)
        firesignal(btn.MouseButton1Up)
    end)
    task.wait(0.03)
    
    -- Metode 3: Activate
    pcall(function() btn:Activate() end)
    
    return true
end

local function pickDelay()
    if settings.mode == "random" then
        return settings.minimum + (settings.maximum - settings.minimum) * math.random()
    end
    return settings.fixed
end

local pg = LocalPlayer:WaitForChild("PlayerGui")
local oldPanel = pg:FindFirstChild("AutoJawabProMaxGui")
if oldPanel then oldPanel:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoJawabProMaxGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 9999
ScreenGui.Parent = pg

local colors = {
    bg = Color3.fromRGB(20, 24, 34),
    card = Color3.fromRGB(30, 36, 52),
    text = Color3.fromRGB(232, 237, 248),
    muted = Color3.fromRGB(153, 166, 191),
    accent = Color3.fromRGB(100, 116, 255),
    green = Color3.fromRGB(94, 229, 171),
    red = Color3.fromRGB(220, 80, 80),
}

local function make(class, parent, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local function rounded(obj, r)
    make("UICorner", obj, {CornerRadius = UDim.new(0, r or 10)})
end

local MainFrame = make("Frame", ScreenGui, {
    Name = "Window",
    Position = UDim2.fromOffset(18, 150),
    Size = UDim2.fromOffset(280, 340),
    BackgroundColor3 = colors.bg,
    BorderSizePixel = 0,
})
rounded(MainFrame, 14)

local windowScale = make("UIScale", MainFrame, {Scale = 1})
make("UIStroke", MainFrame, {Color = Color3.fromRGB(62, 72, 104), Thickness = 1, Transparency = 0.3})

local Header = make("Frame", MainFrame, {
    Size = UDim2.new(1, 0, 0, 34),
    BackgroundColor3 = colors.accent,
    BorderSizePixel = 0,
    Active = true,
})
rounded(Header, 14)

make("TextLabel", Header, {
    Size = UDim2.new(1, -40, 1, 0),
    Position = UDim2.fromOffset(12, 0),
    BackgroundTransparency = 1,
    Text = "AUTO JAWAB PRO",
    TextColor3 = colors.text,
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local HideBtn = make("TextButton", Header, {
    Size = UDim2.fromOffset(24, 24),
    Position = UDim2.new(1, -28, 0, 5),
    BackgroundColor3 = colors.red,
    BorderSizePixel = 0,
    Text = "X",
    TextColor3 = colors.text,
    TextSize = 12,
    Font = Enum.Font.GothamBold,
})
rounded(HideBtn, 12)

local Body = make("Frame", MainFrame, {
    Position = UDim2.fromOffset(0, 34),
    Size = UDim2.new(1, 0, 1, -34),
    BackgroundTransparency = 1,
})

local ToggleBtn = make("TextButton", Body, {
    Size = UDim2.new(0.9, 0, 0, 38),
    Position = UDim2.new(0.05, 0, 0, 10),
    BackgroundColor3 = colors.red,
    BorderSizePixel = 0,
    Text = "OFF",
    TextColor3 = colors.text,
    TextSize = 15,
    Font = Enum.Font.GothamBold,
})
rounded(ToggleBtn, 8)

local RandomBtn = make("TextButton", Body, {
    Size = UDim2.new(0.9, 0, 0, 26),
    Position = UDim2.new(0.05, 0, 0, 54),
    BackgroundColor3 = colors.card,
    BorderSizePixel = 0,
    Text = "RANDOM DELAY: OFF",
    TextColor3 = colors.text,
    TextSize = 10,
    Font = Enum.Font.GothamBold,
})
rounded(RandomBtn, 6)

local SoalLabel = make("TextLabel", Body, {
    Size = UDim2.new(0.9, 0, 0, 16),
    Position = UDim2.new(0.05, 0, 0, 86),
    BackgroundTransparency = 1,
    Text = "Soal: -",
    TextColor3 = colors.muted,
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local JawabanLabel = make("TextLabel", Body, {
    Size = UDim2.new(0.9, 0, 0, 34),
    Position = UDim2.new(0.05, 0, 0, 104),
    BackgroundColor3 = colors.green,
    BackgroundTransparency = 0.3,
    Text = "-",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 20,
    Font = Enum.Font.GothamBold,
})
rounded(JawabanLabel, 8)

local SpeedTitle = make("TextLabel", Body, {
    Size = UDim2.new(0.9, 0, 0, 14),
    Position = UDim2.new(0.05, 0, 0, 146),
    BackgroundTransparency = 1,
    Text = "Delay: 0.8s",
    TextColor3 = colors.muted,
    TextSize = 10,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local SliderBg = make("Frame", Body, {
    Size = UDim2.new(0.9, 0, 0, 10),
    Position = UDim2.new(0.05, 0, 0, 164),
    BackgroundColor3 = Color3.fromRGB(60, 60, 60),
    BorderSizePixel = 0,
})
rounded(SliderBg, 5)

local SliderFill = make("Frame", SliderBg, {
    Size = UDim2.new(0.14, 0, 1, 0),
    BackgroundColor3 = colors.accent,
    BorderSizePixel = 0,
})
rounded(SliderFill, 5)

local SliderKnob = make("TextButton", SliderBg, {
    Size = UDim2.fromOffset(20, 20),
    Position = UDim2.new(0.14, -10, 0, -5),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BorderSizePixel = 0,
    Text = "",
})
rounded(SliderKnob, 10)

local StatusLabel = make("TextLabel", Body, {
    Size = UDim2.new(0.9, 0, 0, 14),
    Position = UDim2.new(0.05, 0, 0, 184),
    BackgroundTransparency = 1,
    Text = "Status: Idle",
    TextColor3 = colors.muted,
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local HintLabel = make("TextLabel", Body, {
    Size = UDim2.new(0.9, 0, 0, 12),
    Position = UDim2.new(0.05, 0, 0, 200),
    BackgroundTransparency = 1,
    Text = "Cepat | Natural | Lambat",
    TextColor3 = colors.muted,
    TextSize = 8,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Center,
})

local InfoLabel = make("TextLabel", Body, {
    Size = UDim2.new(0.9, 0, 0, 60),
    Position = UDim2.new(0.05, 0, 0, 218),
    BackgroundColor3 = colors.card,
    BackgroundTransparency = 0.5,
    Text = "Fitur:\nRecursive Parser | Sequence | Unicode\nGraphic (Luas/Jam) | Multi-Click",
    TextColor3 = colors.muted,
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextWrapped = true,
})
rounded(InfoLabel, 6)

local ShowBtn = make("TextButton", ScreenGui, {
    Size = UDim2.fromOffset(50, 50),
    Position = UDim2.fromOffset(18, 150),
    BackgroundColor3 = colors.accent,
    BorderSizePixel = 0,
    Text = "AJ",
    TextColor3 = colors.text,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    Visible = false,
    Active = true,
    Draggable = true,
})
rounded(ShowBtn, 25)

local sliderDragging = false
local headerDragging = false
local headerDragStart, headerStartPos, headerDragTouch

local function updateFromInput(input)
    local pos = SliderBg.AbsolutePosition.X
    local size = SliderBg.AbsoluteSize.X
    local percent = math.clamp((input.Position.X - pos) / size, 0, 1)
    settings.fixed = 0.1 + percent * 4.9
    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
    SliderKnob.Position = UDim2.new(percent, -10, 0, -5)
    if settings.mode == "random" then
        settings.minimum = settings.fixed
        settings.maximum = settings.fixed + 1.2
        SpeedTitle.Text = string.format("Delay: %.1fs - %.1fs", settings.minimum, settings.maximum)
    else
        SpeedTitle.Text = string.format("Delay: %.1fs", settings.fixed)
    end
end

SliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = true
        updateFromInput(input)
    end
end)

SliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = true
        updateFromInput(input)
    end
end)

Header.InputBegan:Connect(function(event)
    if event.UserInputType == Enum.UserInputType.MouseButton1 or event.UserInputType == Enum.UserInputType.Touch then
        headerDragging = true
        headerDragStart = event.Position
        headerStartPos = MainFrame.Position
        headerDragTouch = event.UserInputType == Enum.UserInputType.Touch and event or nil
    end
end)

state.connections[#state.connections+1] = UserInputService.InputChanged:Connect(function(input)
    if sliderDragging then
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            updateFromInput(input)
        end
    elseif headerDragging then
        if (not headerDragTouch and input.UserInputType == Enum.UserInputType.MouseMovement) or input == headerDragTouch then
            local delta = input.Position - headerDragStart
            MainFrame.Position = UDim2.fromOffset(headerStartPos.X.Offset + delta.X, headerStartPos.Y.Offset + delta.Y)
        end
    end
end)

state.connections[#state.connections+1] = UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = false
        headerDragging = false
        headerDragTouch = nil
    end
end)

local function fitWindow()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    windowScale.Scale = math.min(1, math.max(0.5, (viewport.X - 24) / 280))
    local w, h = 280 * windowScale.Scale, 340 * windowScale.Scale
    MainFrame.Position = UDim2.fromOffset(
        math.clamp(MainFrame.Position.X.Offset, 8, math.max(8, viewport.X - w - 8)),
        math.clamp(MainFrame.Position.Y.Offset, 8, math.max(8, viewport.Y - h - 8))
    )
end

fitWindow()
state.connections[#state.connections+1] = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitWindow)

local function notif(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title, Text = text, Duration = duration or 3,
        })
    end)
end

task.spawn(function()
    while state.running and MainFrame.Parent do
        task.wait(0.1)
        if not state.running then break end
        if not state.auto then continue end
        
        local ok, err = pcall(function()
            local soal, center, gameplay = bacaSoal()
            if not soal or soal == "" then
                SoalLabel.Text = "Soal: -"
                StatusLabel.Text = "Status: Nunggu soal..."
                return
            end
            
            SoalLabel.Text = "Soal: " .. soal:sub(1, 30)
            
            if soal == lastSoal then return end
            lastSoal = soal
            
            local answers = bacaTombol(gameplay)
            local graphic = bacaGraphic(center)
            
            local hint = ""
            local pg2 = LocalPlayer:FindFirstChild("PlayerGui")
            if pg2 then
                for _, gui in pairs(pg2:GetDescendants()) do
                    if gui:IsA("TextLabel") and gui.Visible and gui.Text:find("Petunjuk") then
                        hint = gui.Text
                        break
                    end
                end
            end
            
            local result = solve(soal, answers, hint, graphic)
            
            if result == nil then
                JawabanLabel.Text = "???"
                JawabanLabel.BackgroundColor3 = colors.red
                StatusLabel.Text = "Gak bisa hitung"
                return
            end
            
            local display
            if type(result) == "number" then
                if result == math.floor(result) then
                    display = tostring(math.floor(result))
                else
                    display = string.format("%.4g", result)
                end
            else
                display = tostring(result)
            end
            
            JawabanLabel.Text = display
            JawabanLabel.BackgroundColor3 = colors.green
            
            local target = nil
            local targetIdx = nil
            for _, t in ipairs(answers) do
                if type(result) == "number" then
                    if math.abs(t.value - result) < 0.01 then
                        target = t.btn
                        targetIdx = t.index
                        break
                    end
                else
                    local cleanRaw = t.raw:gsub("%s", ""):gsub("%%", ""):lower()
                    local cleanResult = tostring(result):gsub("%s", ""):gsub("%%", ""):lower()
                    if cleanRaw == cleanResult then
                        target = t.btn
                        targetIdx = t.index
                        break
                    end
                    if result:find("%%") then
                        local resNum = tonumber(result:match("(%d+%.?%d*)"))
                        if resNum and math.abs(t.value - resNum) < 0.01 then
                            target = t.btn
                            targetIdx = t.index
                            break
                        end
                    end
                end
            end
            
            if not target then
                StatusLabel.Text = "Tombol " .. display .. " gak ada"
                JawabanLabel.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
                return
            end
            
            local delay = pickDelay()
            StatusLabel.Text = string.format("Klik %.1fs (Btn %s)", delay, targetIdx)
            task.wait(delay)
            
            local soalCek = bacaSoal()
            if soalCek ~= soal then return end
            
            print("[AUTO] Jawab:", display, "| Delay:", delay)
            klikTombol(target)
        end)
        
        if not ok then
            StatusLabel.Text = "Error: " .. tostring(err):sub(1, 30)
        end
    end
end)

ToggleBtn.MouseButton1Click:Connect(function()
    state.auto = not state.auto
    if state.auto then
        ToggleBtn.Text = "ON"
        ToggleBtn.BackgroundColor3 = colors.green
        lastSoal = ""
        notif("Auto Jawab Pro Max", "ON", 2)
    else
        ToggleBtn.Text = "OFF"
        ToggleBtn.BackgroundColor3 = colors.red
        notif("Auto Jawab Pro Max", "OFF", 2)
    end
end)

RandomBtn.MouseButton1Click:Connect(function()
    if settings.mode == "fixed" then
        settings.mode = "random"
        settings.minimum = settings.fixed
        settings.maximum = settings.fixed + 1.2
        RandomBtn.Text = "RANDOM DELAY: ON"
        RandomBtn.BackgroundColor3 = colors.green
        SpeedTitle.Text = string.format("Delay: %.1fs - %.1fs", settings.minimum, settings.maximum)
    else
        settings.mode = "fixed"
        RandomBtn.Text = "RANDOM DELAY: OFF"
        RandomBtn.BackgroundColor3 = colors.card
        SpeedTitle.Text = string.format("Delay: %.1fs", settings.fixed)
    end
end)

HideBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ShowBtn.Visible = true
end)

ShowBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    ShowBtn.Visible = false
end)

LocalPlayer.CharacterAdded:Connect(function()
    if state.auto then
        state.auto = false
        ToggleBtn.Text = "OFF"
        ToggleBtn.BackgroundColor3 = colors.red
    end
end)

notif("Auto Jawab Pro Max", "Loaded! Recursive Parser + Sequence + Graphic", 5)
print("[AUTO JAWAB PRO MAX] Running...")
