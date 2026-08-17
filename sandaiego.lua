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

local Route = {
    BuyPos = Vector3.new(6821.040, 20.140, 18.682),
    Points = {
        Vector3.new(6841.693, 17.223, 25.801),
        Vector3.new(6850.875, 17.223, 142.320),
        Vector3.new(6342.700, 17.223, 167.407),
        Vector3.new(5933.097, 50.792, 333.061),
        Vector3.new(5738.518, 51.052, 347.195),
        Vector3.new(5300.708, 17.223, 175.663),
        Vector3.new(4911.411, 17.223, 147.482),
        Vector3.new(3649.939, 17.223, 145.471),
        Vector3.new(2919.517, 17.223, 147.252),
        Vector3.new(2780.356, 17.223, 148.367),
        Vector3.new(2181.311, 17.223, 136.295),
        Vector3.new(802.107, 17.223, 142.386),
        Vector3.new(735.048, 17.223, 104.537),
        Vector3.new(259.627, 17.223, 88.264),
        Vector3.new(256.799, 17.244, -40.370),
        Vector3.new(209.160, 17.244, -43.283),
    }
}

local autoFarm = false
local maxRings, flyHeight, flySpeed = 5, 0, 120 -- ارتفاع 0 محاذاة للأرض
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
    local root = Root()
    root.Anchored = false
end

local function antiCheat()
    pcall(function()
        AntiCheatRemote:InvokeServer()
    end)
end

local function buyRing()
    BuyRemote:FireServer(Items["Fake Diamond Ring"])
end

local function sellGoods()
    SellRemote:FireServer(NPC["Seller4"])
end

local function moveTo(pos)
    local root = Root()
    local target = Vector3.new(pos.X, pos.Y + flyHeight, pos.Z)
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
    -- يحاول يوصل للعدد المطلوب، مع محاولات إضافية بسيطة
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

        -- الذهاب لنقطة الشراء
        moveTo(Route.BuyPos)

        -- شراء حسب العدد
        safeBuyLoop()

        -- الذهاب للبائع
        moveForward()

        -- انتظار 3 ثواني
        task.wait(3)

        -- إرسال 5 أوامر بيع
        for i = 1, 5 do
            if not autoFarm then break end
            sellGoods()
            antiCheat()
            task.wait(0.2)
        end

        -- الرجوع بنفس الطريق
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

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0,10)

local header = Instance.new("TextLabel", main)
header.Size = UDim2.new(1,0,0,30)
header.BackgroundColor3 = Color3.fromRGB(35,35,40)
header.Text = "Auto Farm • المبجّل"
header.TextColor3 = Color3.new(1,1,1)
header.Font = Enum.Font.GothamBold
header.TextSize = 13

local hcorner = Instance.new("UICorner", header)
hcorner.CornerRadius = UDim.new(0,10)

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
    local c = Instance.new("UICorner", b)
    c.CornerRadius = UDim.new(0,6)
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
    local c = Instance.new("UICorner", b)
    c.CornerRadius = UDim.new(0,6)
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
