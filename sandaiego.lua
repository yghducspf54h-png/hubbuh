--====================================================
-- Auto Farm • Fake Diamond Ring
-- By المبجّل • Discord: almbjl
--====================================================

---------------------------
-- ROUTE DATA (YOUR POINTS)
---------------------------
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

---------------------------
-- REMOTES
---------------------------
local RS = game:GetService("ReplicatedStorage")
local Remotes = RS:WaitForChild("__remotes")

local BuyRemote = Remotes.WorldBuyableItemService.PurchaseWorldBuyableItem
local SellRemote = Remotes.SmuggleService.SellSmuggledGoods
local AntiCheatRemote = Remotes.CustomServerService.CanManageServer

local Items = workspace.WorldBuyableItems.CivilianArea
local NPC = workspace.NPC

---------------------------
-- PLAYER
---------------------------
local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local function Root()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

---------------------------
-- GUI (SIMPLE MOVABLE)
---------------------------
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromOffset(300, 220)
main.Position = UDim2.new(0.5, -150, 0.5, -110)
main.BackgroundColor3 = Color3.fromRGB(25,25,30)

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0,10)

local header = Instance.new("TextLabel", main)
header.Size = UDim2.new(1,0,0,35)
header.BackgroundColor3 = Color3.fromRGB(35,35,40)
header.Text = "Auto Farm • المبجّل"
header.TextColor3 = Color3.new(1,1,1)
header.Font = Enum.Font.GothamBold
header.TextSize = 14

local hcorner = Instance.new("UICorner", header)
hcorner.CornerRadius = UDim.new(0,10)

-- Dragging
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

---------------------------
-- UI ELEMENTS
---------------------------
local autoFarm = false
local maxRings = 5
local flyHeight = 5
local flySpeed = 60

local function Label(txt, y)
    local l = Instance.new("TextLabel", main)
    l.Size = UDim2.new(1,-20,0,18)
    l.Position = UDim2.fromOffset(10,y)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = Color3.new(1,1,1)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
end

local function Box(y, default)
    local b = Instance.new("TextBox", main)
    b.Size = UDim2.fromOffset(80,26)
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
    b.Position = UDim2.fromOffset(150,y)
    b.BackgroundColor3 = Color3.fromRGB(60,120,200)
    b.Text = txt
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    local c = Instance.new("UICorner", b)
    c.CornerRadius = UDim.new(0,6)
    return b
end

Label("عدد الخواتم (1-8)", 45)
local ringsBox = Box(65, 5)

Label("ارتفاع الطيران", 95)
local heightBox = Box(115, 5)

Label("سرعة الطيران", 145)
local speedBox = Box(165, 60)

local autoBtn = Button("Auto Farm: OFF", 10)

autoBtn.MouseButton1Click:Connect(function()
    autoFarm = not autoFarm
    autoBtn.Text = autoFarm and "Auto Farm: ON" or "Auto Farm: OFF"
end)

ringsBox.FocusLost:Connect(function()
    maxRings = math.clamp(tonumber(ringsBox.Text) or 5, 1, 8)
    ringsBox.Text = tostring(maxRings)
end)

heightBox.FocusLost:Connect(function()
    flyHeight = math.clamp(tonumber(heightBox.Text) or 5, 1, 50)
    heightBox.Text = tostring(flyHeight)
end)

speedBox.FocusLost:Connect(function()
    flySpeed = math.clamp(tonumber(speedBox.Text) or 60, 10, 200)
    speedBox.Text = tostring(flySpeed)
end)

---------------------------
-- MOVEMENT + ANTI-STUCK
---------------------------
local function moveTo(pos)
    local root = Root()
    local target = Vector3.new(pos.X, pos.Y + flyHeight, pos.Z)
    local dist = (root.Position - target).Magnitude
    local t = dist / flySpeed

    local tween = TweenService:Create(root, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = CFrame.new(target)})
    tween:Play()

    local lastPos = root.Position
    for i = 1, math.floor(t * 2) do
        task.wait(0.5)
        if not autoFarm then return end

        if (root.Position - lastPos).Magnitude < 1 then
            tween:Cancel()
            tween:Play()
        end

        lastPos = root.Position
    end

    while (root.Position - target).Magnitude > 3 do
        root.CFrame = root.CFrame:Lerp(CFrame.new(target), 0.2)
        task.wait(0.05)
    end
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

---------------------------
-- ACTIONS
---------------------------
local function buyRing()
    BuyRemote:FireServer(Items["Fake Diamond Ring"])
end

local function sellGoods()
    SellRemote:FireServer(NPC["Seller4"])
end

local function antiCheat()
    pcall(function()
        AntiCheatRemote:InvokeServer()
    end)
end

---------------------------
-- AUTO FARM LOOP
---------------------------
task.spawn(function()
    while true do
        task.wait(0.2)
        if not autoFarm then continue end

        -- 1) الذهاب لنقطة الشراء
        moveTo(Route.BuyPos)

        -- 2) شراء حسب العدد
        for i = 1, maxRings do
            if not autoFarm then break end
            buyRing()
            antiCheat()
            task.wait(0.2)
        end

        -- 3) الذهاب للبائع
        moveForward()

        -- 4) انتظار 3 ثواني
        task.wait(3)

        -- 5) إرسال 5 أوامر بيع
        for i = 1, 5 do
            if not autoFarm then break end
            sellGoods()
            antiCheat()
            task.wait(0.2)
        end

        -- 6) الرجوع بنفس الطريق
        moveBackward()
    end
end)
