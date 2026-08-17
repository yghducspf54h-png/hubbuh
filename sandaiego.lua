--====================================================
-- Auto Farm • Fake Diamond Ring
-- By المبجّل • Discord: almbjl 1
--====================================================

local RS = game:GetService("ReplicatedStorage")
local Remotes = RS:WaitForChild("__remotes")
local BuyRemote = Remotes.WorldBuyableItemService.PurchaseWorldBuyableItem
local SellRemote = Remotes.SmuggleService.SellSmuggledGoods
local AntiCheatRemote = Remotes.CustomServerService.CanManageServer

local Items = workspace.WorldBuyableItems.CivilianArea
local NPC = workspace.NPC
local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

--========================
-- المسار الجديد + حل مشكلة لمس الأرض
--========================
local Route = {
    BuyPos = Vector3.new(6820.766, 17.421, 19.468),
    Points = {
        Vector3.new(207.952, 17.244, -44.035),
        Vector3.new(206.688, 17.082, -53.580),
        Vector3.new(192.914, 17.223, -54.420),
        Vector3.new(193.469, 17.223, -34.899),
        Vector3.new(196.229, 17.223, 134.763),
        Vector3.new(720.947, 17.223, 137.434),
        Vector3.new(1900.172, 17.223, 140.795),
        Vector3.new(2550.742, 17.223, 142.769),
        Vector3.new(2779.545, 17.223, 148.855),
        Vector3.new(3010.252, 17.223, 150.880),
        Vector3.new(4561.280, 17.223, 147.949),
        Vector3.new(5904.539, 17.223, 146.274),
        Vector3.new(6841.736, 17.223, 142.829),
        Vector3.new(6842.128, 17.223, 19.321),

        -- ⭐ أهم نقطة: رفع آخر نقطة فوق الأرض حتى لا يلمس الأرض نهائيًا
        Vector3.new(6820.766, 17.421 + 1.5, 19.468),
    }
}

local autoFarm = false
local maxRings, flyHeight, flySpeed = 5, 0, 120
local activeTween = nil

local function Root()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local function stopAllMovement()
    if activeTween then
        activeTween:Cancel()
        activeTween = nil
    end
    Root().Anchored = false
end

local function antiCheat()
    pcall(function()
        AntiCheatRemote:InvokeServer()
    end)
end

local function buyRing()
    BuyRemote:FireServer(Items["Fake Diamond Ring"])
end

-- نظام بيع متحقق
local function sellGoods()
    local root = Root()
    root.CFrame = root.CFrame + Vector3.new(0, 0.8, 0)

    local success = false
    for attempt = 1, 5 do
        SellRemote:FireServer(NPC["Seller4"])
        antiCheat()
        task.wait(0.3)

        if player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Money") then
            success = true
            break
        end
    end

    if not success then
        print("⚠️ السيرفر ما قبل البيع، إعادة المحاولة لاحقًا")
    end
end

local function moveTo(pos)
    local root = Root()
    local target = Vector3.new(pos.X, pos.Y + flyHeight + 0.5, pos.Z)
    local dist = (root.Position - target).Magnitude
    local t = dist / flySpeed

    root.Anchored = true
    activeTween = TweenService:Create(root, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = CFrame.new(target)})
    activeTween:Play()

    local lastPos = root.Position
    local stuckTimer = 0

    while activeTween and activeTween.PlaybackState == Enum.PlaybackState.Playing do
        task.wait(0.2)
        if not autoFarm then
            stopAllMovement()
            return
        end

        local moved = (root.Position - lastPos).Magnitude
        if moved < 0.5 then
            stuckTimer += 0.2
            if stuckTimer >= 3 then
                print("⚠️ تجاوز الإحداثية بسبب التعليق")
                stopAllMovement()
                return
            end
        else
            stuckTimer = 0
        end

        lastPos = root.Position
    end

    root.CFrame = CFrame.new(target)
    root.Anchored = false
end

local function moveForward()
    for _, p in ipairs(Route.Points) do
        if not autoFarm then break end
        moveTo(p)
    end
end

local function moveBackward()
    for i = #Route.Points, 1, -1 do
        if not autoFarm then break end
        moveTo(Route.Points[i])
    end
end

local function safeBuyLoop()
    for i = 1, maxRings do
        if not autoFarm then break end
        buyRing()
        antiCheat()
        task.wait(0.4)
    end
end

task.spawn(function()
    while true do
        task.wait(0.2)
        if not autoFarm then continue end

        moveTo(Route.BuyPos)
        safeBuyLoop()
        moveForward()
        task.wait(3)

        for i = 1, 5 do
            if not autoFarm then break end
            sellGoods()
            task.wait(0.2)
        end

        moveBackward()
    end
end)

--========================
-- واجهة بسيطة متحركة
--========================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromOffset(260, 190)
main.Position = UDim2.new(0.5, -130, 0.4, -95)
main.BackgroundColor3 = Color3.fromRGB(25,25,30)
Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)

local header = Instance.new("TextLabel", main)
header.Size = UDim2.new(1,0,0,30)
header.BackgroundColor3 = Color3.fromRGB(35,35,40)
header.Text = "Auto Farm • المبجّل"
header.TextColor3 = Color3.new(1,1,1)
header.Font = Enum.Font.GothamBold
header.TextSize = 13
Instance.new("UICorner", header).CornerRadius = UDim.new(0,10)

local dragging, dragStart, startPos = false, nil, nil

header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = i.Position
        startPos = main.Position
    end
end)

header.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                  startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local function Label(txt, y)
    local l = Instance.new("TextLabel", main)
    l.Size = UDim2.new(1,-20,0,18)
    l.Position = UDim2.fromOffset(10,y)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = Color3.new(1,1,1)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    return l
end

local function Box(y, default)
    local b = Instance.new("TextBox", main)
    b.Size = UDim2.fromOffset(80,24)
    b.Position = UDim2.fromOffset(10,y)
    b.BackgroundColor3 = Color3.fromRGB(40,40,45)
    b.Text = tostring(default)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    b.ClearTextOnFocus = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    return b
end

local function Button(txt, y)
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.fromOffset(140,28)
    b.Position = UDim2.fromOffset(110,y)
    b.BackgroundColor3 = Color3.fromRGB(60,120,200)
    b.Text = txt
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    return b
end

Label("عدد الخواتم (1-8)", 40)
local ringsBox = Box(60, maxRings)

Label("ارتفاع الطيران (محاذاة الأرض = 0)", 90)
local heightBox = Box(110, flyHeight)

Label("سرعة الطيران", 140)
local speedBox = Box(160, flySpeed)

local autoBtn = Button("Auto Farm: OFF", 10)

autoBtn.MouseButton1Click:Connect(function()
    autoFarm = not autoFarm
    autoBtn.Text = autoFarm and "Auto Farm: ON" or "Auto Farm: OFF"
    if not autoFarm then
        stopAllMovement()
    end
end)

ringsBox.FocusLost:Connect(function()
    maxRings = math.clamp(tonumber(ringsBox.Text) or maxRings, 1, 8)
    ringsBox.Text = tostring(maxRings)
end)

heightBox.FocusLost:Connect(function()
    flyHeight = tonumber(heightBox.Text) or flyHeight
    heightBox.Text = tostring(flyHeight)
end)

speedBox.FocusLost:Connect(function()
    flySpeed = math.clamp(tonumber(speedBox.Text) or flySpeed, 20, 200)
    speedBox.Text = tostring(flySpeed)
end)
