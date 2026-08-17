--====================================================
-- Auto Farm • Fake Diamond Ring
-- By المبجّل • Discord: almbjl
--====================================================

---------------------------
-- ROUTE DATA
---------------------------
local Route = {
    steps = {
        {
            position = Vector3.new(6820.941, 17.421, 20.054),
        },

        {
            points = {
                {position = Vector3.new(6854.121, 17.223, 20.914)},
                {position = Vector3.new(6844.108, 17.223, 142.581)},
                {position = Vector3.new(6795.110, 17.223, 142.215)},
                {position = Vector3.new(4754.197, 16.411, 143.214)},
                {position = Vector3.new(3793.107, 16.413, 144.526)},
                {position = Vector3.new(2780.473, 17.248, 149.317)},
                {position = Vector3.new(1549.154, 16.410, 135.654)},
                {position = Vector3.new(1400.638, 16.388, 135.813)},
                {position = Vector3.new(1378.808, 16.373, 105.375)},
                {position = Vector3.new(262.297, 17.223, 94.578)},
                {position = Vector3.new(259.445, 17.244, -40.166)},
                {position = Vector3.new(215.130, 17.244, -39.732)},
            }
        }
    }
}

---------------------------
-- REMOTES
---------------------------
local RS = game:GetService("ReplicatedStorage")
local Remotes = RS:WaitForChild("__remotes")

local BuyRemote = Remotes.WorldBuyableItemService.PurchaseWorldBuyableItem
local VehicleRemote = Remotes.VehicleService.GetVehicleState
local SellRemote = Remotes.SmuggleService.SellSmuggledGoods
local AntiCheatRemote = Remotes.CustomServerService.CanManageServer

local Items = workspace.WorldBuyableItems.CivilianArea
local Vehicles = workspace.Vehicles
local NPC = workspace.NPC

---------------------------
-- PLAYER
---------------------------
local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local function getRoot()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

---------------------------
-- GUI
---------------------------
local gui = Instance.new("ScreenGui")
gui.Parent = player.PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(420, 260)
main.Position = UDim2.new(0.5, -210, 0.5, -130)
main.BackgroundColor3 = Color3.fromRGB(20,20,24)
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,10)
corner.Parent = main

local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0,40)
header.BackgroundColor3 = Color3.fromRGB(28,28,34)
header.Parent = main

local hcorner = Instance.new("UICorner")
hcorner.CornerRadius = UDim.new(0,10)
hcorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-120,1,0)
title.Position = UDim2.fromOffset(10,0)
title.BackgroundTransparency = 1
title.Text = "Auto Farm • المبجّل"
title.TextColor3 = Color3.fromRGB(240,240,245)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = header

local discord = Instance.new("TextLabel")
discord.Size = UDim2.new(0,120,1,0)
discord.Position = UDim2.new(1,-120,0,0)
discord.BackgroundTransparency = 1
discord.Text = "Discord: almbjl"
discord.TextColor3 = Color3.fromRGB(180,180,190)
discord.Font = Enum.Font.Gotham
discord.TextSize = 11
discord.Parent = header

local content = Instance.new("Frame")
content.Size = UDim2.new(1,-20,1,-50)
content.Position = UDim2.fromOffset(10,45)
content.BackgroundColor3 = Color3.fromRGB(25,25,30)
content.Parent = main

local ccorner = Instance.new("UICorner")
ccorner.CornerRadius = UDim.new(0,8)
ccorner.Parent = content

---------------------------
-- UI ELEMENTS
---------------------------
local autoFarm = false
local maxRings = 5
local flyHeight = 5
local flySpeed = 60

local function label(txt,y)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,-20,0,18)
    l.Position = UDim2.fromOffset(10,y)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = Color3.fromRGB(200,200,210)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.Parent = content
end

local function box(y,default)
    local b = Instance.new("TextBox")
    b.Size = UDim2.fromOffset(120,26)
    b.Position = UDim2.fromOffset(10,y)
    b.BackgroundColor3 = Color3.fromRGB(35,35,42)
    b.Text = tostring(default)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    b.Parent = content
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,6)
    c.Parent = b
    return b
end

local function button(txt,y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(160,28)
    b.Position = UDim2.fromOffset(200,y)
    b.BackgroundColor3 = Color3.fromRGB(55,95,180)
    b.Text = txt
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.Parent = content
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,6)
    c.Parent = b
    return b
end

label("تشغيل الأوتو فارم",8)
local autoBtn = button("Auto Farm: OFF",26)

label("عدد Fake Diamond Ring",60)
local ringsBox = box(78,5)

label("ارتفاع فوق الأرض",112)
local heightBox = box(130,5)

label("سرعة الطيران",164)
local speedBox = box(182,60)

local showRouteBtn = button("إظهار المسار",216)

autoBtn.MouseButton1Click:Connect(function()
    autoFarm = not autoFarm
    autoBtn.Text = autoFarm and "Auto Farm: ON" or "Auto Farm: OFF"
    autoBtn.BackgroundColor3 = autoFarm and Color3.fromRGB(55,150,90) or Color3.fromRGB(55,95,180)
end)

ringsBox.FocusLost:Connect(function()
    local n = tonumber(ringsBox.Text) or 5
    maxRings = math.clamp(n,1,8)
    ringsBox.Text = tostring(maxRings)
end)

heightBox.FocusLost:Connect(function()
    local n = tonumber(heightBox.Text) or 5
    flyHeight = math.clamp(n,1,30)
    heightBox.Text = tostring(flyHeight)
end)

speedBox.FocusLost:Connect(function()
    local n = tonumber(speedBox.Text) or 60
    flySpeed = math.clamp(n,10,200)
    speedBox.Text = tostring(flySpeed)
end)

showRouteBtn.MouseButton1Click:Connect(function()
    print("========== ROUTE ==========")
    for i,p in ipairs(Route.steps[2].points) do
        print(i,p.position)
    end
end)

---------------------------
-- MOVEMENT + ANTI-STUCK
---------------------------
local function antiStuck(root,lastPos)
    return (root.Position - lastPos).Magnitude >= 2
end

local function moveTo(pos)
    local root = getRoot()
    local target = Vector3.new(pos.X,pos.Y+flyHeight,pos.Z)
    local dist = (root.Position - target).Magnitude
    local t = dist / flySpeed

    local tween = TweenService:Create(root,TweenInfo.new(t,Enum.EasingStyle.Linear),{CFrame=CFrame.new(target)})
    tween:Play()

    local lastPos = root.Position
    for i=1,math.floor(t*2) do
        task.wait(0.5)
        if not autoFarm then return end
        if not antiStuck(root,lastPos) then
            tween:Cancel()
            tween:Play()
        end
        lastPos = root.Position
    end

    tween.Completed:Wait()
end

local function movePathForward()
    for _,point in ipairs(Route.steps[2].points) do
        if not autoFarm then break end
        moveTo(point.position)
    end
end

local function movePathBackward()
    for i=#Route.steps[2].points,1,-1 do
        if not autoFarm then break end
        moveTo(Route.steps[2].points[i].position)
    end
end

---------------------------
-- ACTIONS
---------------------------
local function buyRing()
    BuyRemote:FireServer(Items["Fake Diamond Ring"])
end

local function pingVehicle()
    VehicleRemote:InvokeServer(Vehicles["Dodge Durango RT"])
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
        moveTo(Route.steps[1].position)

        -- 2) شراء الخواتم
        for i=1,maxRings do
            if not autoFarm then break end
            buyRing()
            pingVehicle()
            antiCheat()
            task.wait(0.2)
        end

        -- 3) الذهاب لنقطة البيع
        movePathForward()

        -- 4) انتظار 3 ثواني قبل البيع
        task.wait(3)

        -- 5) بيع
        sellGoods()
        antiCheat()

        -- 6) الرجوع من الطريق بالعكس
        movePathBackward()
    end
end)
