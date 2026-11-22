-- Zeus Menu v3
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ORANGE = Color3.fromRGB(255, 140, 0)
local DARK = Color3.fromRGB(18, 18, 22)
local DARK2 = Color3.fromRGB(28, 28, 34)
local OFF = Color3.fromRGB(45, 45, 52)

local PALETTE = {
    { name = "Preto",    color = Color3.fromRGB(0, 0, 0) },
    { name = "Vermelho", color = Color3.fromRGB(255, 40, 40) },
    { name = "Laranja",  color = Color3.fromRGB(255, 140, 0) },
}

-- 10 keys infinitas (nunca expiram)
local KEYS = {
    ["ZEUS-K7Q2-M9X4"] = true,
    ["ZEUS-R4T8-L2W6"] = true,
    ["ZEUS-N5V3-H8J1"] = true,
    ["ZEUS-P9D6-F2S7"] = true,
    ["ZEUS-B3Y8-G5Z4"] = true,
    ["ZEUS-W2C7-X6A9"] = true,
    ["ZEUS-T8U1-E4R5"] = true,
    ["ZEUS-J6M3-Q7N2"] = true,
    ["ZEUS-H4L9-V1K8"] = true,
    ["ZEUS-D5F2-Y3P6"] = true,
}
local KEY_FILE = "ZeusKey.txt"

-- estado
local skeletonOn = false
local skeletonColor = ORANGE
local dotOn = false
local dotColor = ORANGE
local shiftLockOn = false
local assistOn = false
local ignoreTeam = false
local ASSIST_FOV = 220        -- raio (pixels) em volta do centro da tela
local assistSmooth = 0.14     -- controlado pelo slider "Grude da mira"

------------------------------------------------------------
-- GUI base
------------------------------------------------------------
local function getParent()
    local ok, ui = pcall(function() return gethui and gethui() end)
    if ok and ui then return ui end
    return LocalPlayer:WaitForChild("PlayerGui")
end
local parent = getParent()
if parent:FindFirstChild("ZeusMenu") then parent.ZeusMenu:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "ZeusMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = parent

local function corner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = obj
    return c
end

local function stroke(obj, color, t)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = t
    s.Parent = obj
    return s
end

-- handle = area que recebe o toque, target = o que se move
local function makeDraggable(handle, target, onTap)
    local dragging, moved, dragStart, startPos = false, false, nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if not moved and onTap then onTap() end
                end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            if d.Magnitude > 6 then moved = true end
            if moved then
                target.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y
                )
            end
        end
    end)
end

------------------------------------------------------------
-- Ponto de mira (centro da tela)
------------------------------------------------------------
local dot = Instance.new("Frame")
dot.Name = "AimDot"
dot.AnchorPoint = Vector2.new(0.5, 0.5)
dot.Position = UDim2.new(0.5, 0, 0.5, 0)
dot.Size = UDim2.new(0, 6, 0, 6)
dot.BackgroundColor3 = dotColor
dot.BorderSizePixel = 0
dot.Visible = false
dot.Parent = gui
local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = dot

------------------------------------------------------------
-- Menu
------------------------------------------------------------
local menu = Instance.new("Frame")
menu.Name = "Menu"
menu.Size = UDim2.new(0, 300, 0, 420)
menu.Position = UDim2.new(0.5, -150, 0.5, -210)
menu.BackgroundColor3 = DARK
menu.Visible = false
menu.Active = true
menu.Parent = gui
corner(menu, 16)
stroke(menu, ORANGE, 1.5)

-- cabecalho (area para arrastar o menu)
local header = Instance.new("Frame")
header.BackgroundTransparency = 1
header.Active = true
header.Size = UDim2.new(1, -100, 0, 56)
header.Parent = menu

local title = Instance.new("TextLabel")
title.Text = "Zeus"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Position = UDim2.new(0, 18, 0, 14)
title.Size = UDim2.new(0, 70, 0, 30)
title.Parent = header

local badge = Instance.new("TextLabel")
badge.Text = "Key"
badge.Font = Enum.Font.GothamBold
badge.TextSize = 11
badge.TextColor3 = Color3.new(1, 1, 1)
badge.BackgroundColor3 = ORANGE
badge.Position = UDim2.new(0, 92, 0, 18)
badge.Size = UDim2.new(0, 50, 0, 22)
badge.Parent = header
corner(badge, 11)

local function topButton(text, x)
    local b = Instance.new("TextButton")
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    b.TextColor3 = ORANGE
    b.BackgroundColor3 = DARK2
    b.AutoButtonColor = false
    b.Size = UDim2.new(0, 30, 0, 30)
    b.Position = UDim2.new(1, x, 0, 14)
    b.Parent = menu
    corner(b, 8)
    return b
end

local minBtn = topButton("-", -80)
local closeBtn = topButton("x", -44)

-- Aba unica: ESP
local tab = Instance.new("TextButton")
tab.Text = "ESP"
tab.Font = Enum.Font.GothamMedium
tab.TextSize = 13
tab.TextColor3 = Color3.new(1, 1, 1)
tab.BackgroundColor3 = ORANGE
tab.AutoButtonColor = false
tab.Position = UDim2.new(0, 14, 0, 58)
tab.Size = UDim2.new(1, -28, 0, 30)
tab.Parent = menu
corner(tab, 8)

-- Lista
local list = Instance.new("ScrollingFrame")
list.Position = UDim2.new(0, 14, 0, 98)
list.Size = UDim2.new(1, -28, 1, -148)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 3
list.ScrollBarImageColor3 = ORANGE
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.Parent = menu

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = list

local allToggles = {}

local function addSection(text)
    local s = Instance.new("TextLabel")
    s.Text = text
    s.Font = Enum.Font.GothamBold
    s.TextSize = 12
    s.TextColor3 = ORANGE
    s.BackgroundTransparency = 1
    s.TextXAlignment = Enum.TextXAlignment.Left
    s.Size = UDim2.new(1, -8, 0, 18)
    s.Parent = list
end

local function addToggle(text, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -8, 0, 44)
    row.BackgroundColor3 = DARK2
    row.Parent = list
    corner(row, 10)

    local d = Instance.new("Frame")
    d.Size = UDim2.new(0, 5, 0, 5)
    d.Position = UDim2.new(0, 12, 0.5, -2)
    d.BackgroundColor3 = Color3.fromRGB(90, 90, 98)
    d.Parent = row
    corner(d, 3)

    local lbl = Instance.new("TextLabel")
    lbl.Text = text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.fromRGB(225, 225, 230)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Position = UDim2.new(0, 26, 0, 0)
    lbl.Size = UDim2.new(0.65, 0, 1, 0)
    lbl.Parent = row

    local track = Instance.new("TextButton")
    track.Text = ""
    track.AutoButtonColor = false
    track.Size = UDim2.new(0, 44, 0, 24)
    track.Position = UDim2.new(1, -56, 0.5, -12)
    track.BackgroundColor3 = OFF
    track.Parent = row
    corner(track, 12)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.Parent = track
    corner(knob, 9)

    local on = false
    local obj = {}
    function obj.set(v)
        on = v
        local info = TweenInfo.new(0.15)
        TweenService:Create(knob, info, {
            Position = on and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        }):Play()
        TweenService:Create(track, info, {
            BackgroundColor3 = on and ORANGE or OFF
        }):Play()
        callback(on)
    end
    function obj.get() return on end

    track.MouseButton1Click:Connect(function() obj.set(not on) end)
    table.insert(allToggles, obj)
    return obj
end

local function addColorRow(text, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -8, 0, 70)
    row.BackgroundColor3 = DARK2
    row.Parent = list
    corner(row, 10)

    local lbl = Instance.new("TextLabel")
    lbl.Text = text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextColor3 = Color3.fromRGB(225, 225, 230)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Position = UDim2.new(0, 14, 0, 6)
    lbl.Size = UDim2.new(1, -28, 0, 22)
    lbl.Parent = row

    local holder = Instance.new("Frame")
    holder.BackgroundTransparency = 1
    holder.Position = UDim2.new(0, 14, 0, 34)
    holder.Size = UDim2.new(1, -28, 0, 26)
    holder.Parent = row

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 6)
    layout.Parent = holder

    local buttons = {}
    local function select(i)
        for j, b in ipairs(buttons) do
            local active = (j == i)
            b.BackgroundColor3 = active and ORANGE or OFF
            b.TextColor3 = active and Color3.new(1, 1, 1) or Color3.fromRGB(190, 190, 195)
        end
        callback(PALETTE[i].color)
    end

    for i, opt in ipairs(PALETTE) do
        local btn = Instance.new("TextButton")
        btn.Text = opt.name
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 12
        btn.AutoButtonColor = false
        btn.Size = UDim2.new(1 / #PALETTE, -4, 1, 0)
        btn.Parent = holder
        corner(btn, 8)
        buttons[i] = btn
        btn.MouseButton1Click:Connect(function() select(i) end)
    end
    select(3) -- padrao: laranja
end

local function addSlider(text, min, max, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -8, 0, 62)
    row.BackgroundColor3 = DARK2
    row.Parent = list
    corner(row, 10)

    local lbl = Instance.new("TextLabel")
    lbl.Text = text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextColor3 = Color3.fromRGB(225, 225, 230)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Position = UDim2.new(0, 14, 0, 6)
    lbl.Size = UDim2.new(0.65, 0, 0, 22)
    lbl.Parent = row

    local valLbl = Instance.new("TextLabel")
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 13
    valLbl.TextColor3 = ORANGE
    valLbl.BackgroundTransparency = 1
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Position = UDim2.new(1, -64, 0, 6)
    valLbl.Size = UDim2.new(0, 50, 0, 22)
    valLbl.Parent = row

    local hit = Instance.new("TextButton")
    hit.Text = ""
    hit.AutoButtonColor = false
    hit.BackgroundTransparency = 1
    hit.Position = UDim2.new(0, 14, 0, 32)
    hit.Size = UDim2.new(1, -28, 0, 26)
    hit.Parent = row

    local track = Instance.new("Frame")
    track.AnchorPoint = Vector2.new(0, 0.5)
    track.Position = UDim2.new(0, 0, 0.5, 0)
    track.Size = UDim2.new(1, 0, 0, 8)
    track.BackgroundColor3 = OFF
    track.Parent = hit
    corner(track, 4)

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = ORANGE
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.Parent = track
    corner(fill, 4)

    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.Parent = track
    corner(knob, 8)

    local function setValue(v)
        local a = (v - min) / (max - min)
        fill.Size = UDim2.new(a, 0, 1, 0)
        knob.Position = UDim2.new(a, 0, 0.5, 0)
        valLbl.Text = tostring(v)
        callback(v)
    end

    local function update(input)
        local a = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        setValue(math.floor(min + a * (max - min) + 0.5))
    end

    local dragging = false
    hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            list.ScrollingEnabled = false
            update(input)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    list.ScrollingEnabled = true
                end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    setValue(default)
end

-- Conteudo
addSection("ESP")
addToggle("ESP Esqueleto", function(v) skeletonOn = v end)
addColorRow("Cor do esqueleto", function(c) skeletonColor = c end)

addSection("MIRA")
addToggle("Ponto de Mira", function(v)
    dotOn = v
    dot.Visible = v
end)
addColorRow("Cor do ponto", function(c)
    dotColor = c
    dot.BackgroundColor3 = c
end)
addSlider("Tamanho do ponto", 2, 20, 6, function(v)
    dot.Size = UDim2.new(0, v, 0, v)
end)

addSection("ASSISTÊNCIA")
addToggle("Assistência", function(v) assistOn = v end)
addSlider("Grude da mira", 1, 100, 30, function(v)
    assistSmooth = 0.02 + (v / 100) * 0.4 -- 0.02 (bem leve) ate 0.42 (forte)
end)
addToggle("Ignorar time", function(v) ignoreTeam = v end)

addSection("CAMERA")
addToggle("Trava Shift (estilo GTA)", function(v)
    shiftLockOn = v
    if not v then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.AutoRotate = true
            hum.CameraOffset = Vector3.new(0, 0, 0)
        end
        pcall(function() UIS.MouseBehavior = Enum.MouseBehavior.Default end)
    end
end)

addSection("GERAL")
do
    local btn = Instance.new("TextButton")
    btn.Text = "Desativar tudo"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BackgroundColor3 = Color3.fromRGB(200, 45, 45)
    btn.AutoButtonColor = false
    btn.Size = UDim2.new(1, -8, 0, 42)
    btn.Parent = list
    corner(btn, 10)
    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(allToggles) do
            if t.get() then t.set(false) end
        end
    end)
end

-- Rodape
local footer = Instance.new("TextLabel")
footer.Text = "Zeus | v3.0"
footer.Font = Enum.Font.Gotham
footer.TextSize = 11
footer.TextColor3 = Color3.fromRGB(130, 130, 140)
footer.BackgroundColor3 = DARK2
footer.TextXAlignment = Enum.TextXAlignment.Left
footer.Position = UDim2.new(0, 14, 1, -42)
footer.Size = UDim2.new(1, -28, 0, 28)
footer.Parent = menu
corner(footer, 8)
local pad = Instance.new("UIPadding")
pad.PaddingLeft = UDim.new(0, 10)
pad.Parent = footer

makeDraggable(header, menu)

------------------------------------------------------------
-- Bolinha
------------------------------------------------------------
local ball = Instance.new("Frame")
ball.Name = "Ball"
ball.Size = UDim2.new(0, 46, 0, 46)
ball.Position = UDim2.new(0, 20, 0.5, -23)
ball.BackgroundColor3 = Color3.new(0, 0, 0)
ball.Active = true
ball.Visible = false -- aparece depois da key
ball.Parent = gui
corner(ball, 23)
stroke(ball, ORANGE, 2.5)

makeDraggable(ball, ball, function() menu.Visible = not menu.Visible end)
minBtn.MouseButton1Click:Connect(function() menu.Visible = false end)
closeBtn.MouseButton1Click:Connect(function() menu.Visible = false end)

------------------------------------------------------------
-- Tela de Key
------------------------------------------------------------
local function unlock()
    ball.Visible = true
end

local function normalize(k)
    return (tostring(k or ""):gsub("%s", ""):upper())
end

local savedOk = false
pcall(function()
    if isfile and readfile and isfile(KEY_FILE) then
        if KEYS[normalize(readfile(KEY_FILE))] then savedOk = true end
    end
end)

if savedOk then
    unlock()
else
    local keyFrame = Instance.new("Frame")
    keyFrame.Size = UDim2.new(0, 290, 0, 200)
    keyFrame.Position = UDim2.new(0.5, -145, 0.5, -100)
    keyFrame.BackgroundColor3 = DARK
    keyFrame.Active = true
    keyFrame.Parent = gui
    corner(keyFrame, 16)
    stroke(keyFrame, ORANGE, 1.5)

    local kTitle = Instance.new("TextLabel")
    kTitle.Text = "Zeus"
    kTitle.Font = Enum.Font.GothamBold
    kTitle.TextSize = 22
    kTitle.TextColor3 = ORANGE
    kTitle.BackgroundTransparency = 1
    kTitle.Position = UDim2.new(0, 0, 0, 14)
    kTitle.Size = UDim2.new(1, 0, 0, 30)
    kTitle.Parent = keyFrame

    local kSub = Instance.new("TextLabel")
    kSub.Text = "Digite sua key para continuar"
    kSub.Font = Enum.Font.Gotham
    kSub.TextSize = 12
    kSub.TextColor3 = Color3.fromRGB(150, 150, 160)
    kSub.BackgroundTransparency = 1
    kSub.Position = UDim2.new(0, 0, 0, 44)
    kSub.Size = UDim2.new(1, 0, 0, 18)
    kSub.Parent = keyFrame

    local box = Instance.new("TextBox")
    box.PlaceholderText = "ZEUS-XXXX-XXXX"
    box.PlaceholderColor3 = Color3.fromRGB(110, 110, 120)
    box.Text = ""
    box.ClearTextOnFocus = false
    box.Font = Enum.Font.GothamMedium
    box.TextSize = 14
    box.TextColor3 = Color3.new(1, 1, 1)
    box.BackgroundColor3 = DARK2
    box.Position = UDim2.new(0, 20, 0, 74)
    box.Size = UDim2.new(1, -40, 0, 38)
    box.Parent = keyFrame
    corner(box, 10)

    local status = Instance.new("TextLabel")
    status.Text = ""
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextColor3 = Color3.fromRGB(255, 70, 70)
    status.BackgroundTransparency = 1
    status.Position = UDim2.new(0, 0, 0, 116)
    status.Size = UDim2.new(1, 0, 0, 18)
    status.Parent = keyFrame

    local verify = Instance.new("TextButton")
    verify.Text = "Verificar"
    verify.Font = Enum.Font.GothamBold
    verify.TextSize = 14
    verify.TextColor3 = Color3.new(1, 1, 1)
    verify.BackgroundColor3 = ORANGE
    verify.AutoButtonColor = false
    verify.Position = UDim2.new(0, 20, 0, 142)
    verify.Size = UDim2.new(1, -40, 0, 40)
    verify.Parent = keyFrame
    corner(verify, 10)

    verify.MouseButton1Click:Connect(function()
        local k = normalize(box.Text)
        if KEYS[k] then
            pcall(function() if writefile then writefile(KEY_FILE, k) end end)
            status.TextColor3 = Color3.fromRGB(80, 220, 110)
            status.Text = "Key válida!"
            task.wait(0.5)
            keyFrame:Destroy()
            unlock()
        else
            status.TextColor3 = Color3.fromRGB(255, 70, 70)
            status.Text = "Key inválida"
        end
    end)

    makeDraggable(keyFrame, keyFrame)
end



------------------------------------------------------------
-- ESP Esqueleto (Drawing API)
------------------------------------------------------------
local R15 = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
}
local R6 = {
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
    {"Torso", "Left Leg"}, {"Torso", "Right Leg"},
}

local hasDrawing = (typeof(Drawing) == "table" or typeof(Drawing) == "userdata") and Drawing.new ~= nil
local lines = {} -- [player] = { Line, ... }

local function getLines(plr)
    if not lines[plr] then
        lines[plr] = {}
        for i = 1, #R15 do
            local l = Drawing.new("Line")
            l.Thickness = 1.5
            l.Visible = false
            lines[plr][i] = l
        end
    end
    return lines[plr]
end

local function hidePlayer(plr)
    if lines[plr] then
        for _, l in ipairs(lines[plr]) do l.Visible = false end
    end
end

Players.PlayerRemoving:Connect(function(plr)
    if lines[plr] then
        for _, l in ipairs(lines[plr]) do pcall(function() l:Remove() end) end
        lines[plr] = nil
    end
end)

local function updateSkeleton(plr)
    local char = plr.Character
    local ls = getLines(plr)
    if not char then hidePlayer(plr) return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then hidePlayer(plr) return end

    local pairsList = char:FindFirstChild("UpperTorso") and R15 or R6
    for i = 1, #ls do
        local l = ls[i]
        local pr = pairsList[i]
        if pr then
            local a = char:FindFirstChild(pr[1])
            local b = char:FindFirstChild(pr[2])
            if a and b then
                local pa, va = Camera:WorldToViewportPoint(a.Position)
                local pb, vb = Camera:WorldToViewportPoint(b.Position)
                if va and vb then
                    l.From = Vector2.new(pa.X, pa.Y)
                    l.To = Vector2.new(pb.X, pb.Y)
                    l.Color = skeletonColor
                    l.Visible = true
                else
                    l.Visible = false
                end
            else
                l.Visible = false
            end
        else
            l.Visible = false
        end
    end
end

------------------------------------------------------------
-- Loop principal
------------------------------------------------------------
local function isTeammate(plr)
    return ignoreTeam and LocalPlayer.Team ~= nil and plr.Team == LocalPlayer.Team
end

RunService.RenderStepped:Connect(function()
    Camera = workspace.CurrentCamera

    -- Skeleton
    if hasDrawing then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                if skeletonOn then
                    pcall(updateSkeleton, plr)
                else
                    hidePlayer(plr)
                end
            end
        end
    end

    -- Assistencia de mira (so jogadores, ignora blocos/decoracao)
    if assistOn then
        local center = Camera.ViewportSize / 2
        local best, bestDist = nil, ASSIST_FOV
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and not isTeammate(plr) then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                local head = plr.Character:FindFirstChild("Head")
                if hum and hum.Health > 0 and head then
                    local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if d < bestDist then
                            best, bestDist = head, d
                        end
                    end
                end
            end
        end
        if best then
            local goal = CFrame.new(Camera.CFrame.Position, best.Position)
            Camera.CFrame = Camera.CFrame:Lerp(goal, assistSmooth)
        end
    end

    -- Trava Shift (personagem olha para onde a camera aponta + camera no ombro)
    if shiftLockOn then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if hum and root then
            hum.AutoRotate = false
            hum.CameraOffset = Vector3.new(1.75, 0.5, 0)
            local look = Camera.CFrame.LookVector
            root.CFrame = CFrame.new(root.Position, root.Position + Vector3.new(look.X, 0, look.Z))
            pcall(function() UIS.MouseBehavior = Enum.MouseBehavior.LockCenter end)
        end
    end
end)
