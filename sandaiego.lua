--====================================================
-- Auto Farm - Fake Diamond Ring
-- By almbjl (المبجّل)
--====================================================

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Route = {
    name = "AutoFarm_Main",
    steps = {
        {
            type = "Action",
            category = "Buy",
            name = "Buy Fake Diamond Ring",
            position = Vector3.new(6820.941, 17.421, 20.054),
        },

        {
            type = "Path",
            category = "Path",
            name = "To sll",
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
            },
        },
    },
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("__remotes")

local PurchaseWorldBuyableItem = Remotes.WorldBuyableItemService.PurchaseWorldBuyableItem
local GetVehicleState = Remotes.VehicleService.GetVehicleState
local SellSmuggledGoods = Remotes.SmuggleService.SellSmuggledGoods
local CanManageServer = Remotes.CustomServerService.CanManageServer

local WorldBuyableItems = workspace.WorldBuyableItems.CivilianArea
local Vehicles = workspace.Vehicles
local NPC = workspace.NPC

local player = game.Players.LocalPlayer
local function getRoot()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

--====================================================
-- WindUI
--====================================================

local window = WindUI:CreateWindow({
    Title = "Auto Farm • Fake Diamond Ring | المبجّل",
    Subtitle = "Discord: almbjl",
    Theme = "Dark",
})

local mainTab = window:CreateTab("Auto Farm")

local autoFarmEnabled = false
local flyHeight = 5
local flySpeed = 60
local maxRings = 5

mainTab:CreateToggle({
    Name = "تشغيل الأوتو فارم",
    Default = false,
    Callback = function(v)
        autoFarmEnabled = v
    end,
})

mainTab:CreateSlider({
    Name = "عدد Fake Diamond Ring",
    Min = 1, Max = 8, Default = 5,
    Callback = function(v)
        maxRings = v
    end,
})

mainTab:CreateSlider({
    Name = "ارتفاع فوق الأرض",
    Min = 2, Max = 20, Default = 5,
    Callback = function(v)
        flyHeight = v
    end,
})

mainTab:CreateSlider({
    Name = "سرعة الطيران",
    Min = 20, Max = 120, Default = 60,
    Callback = function(v)
        flySpeed = v
    end,
})

mainTab:CreateButton({
    Name = "إظهار المسار",
    Callback = function()
        print("========== ROUTE ==========")
        for i, p in ipairs(Route.steps[2].points) do
            print(i, p.position)
        end
    end,
})

--====================================================
-- Anti-Stuck System
--====================================================

local function antiStuckCheck(root, lastPos)
    local moved = (root.Position - lastPos).Magnitude
    return moved >= 2
end

local function safeReset()
    local root = getRoot()
    local buyPos = Route.steps[1].position
    root.CFrame = CFrame.new(buyPos.X, buyPos.Y + flyHeight, buyPos.Z)
end

--====================================================
-- Movement
--====================================================

local TweenService = game:GetService("TweenService")

local function moveTo(targetPos)
    local root = getRoot()
    local lastPos = root.Position
    local stuckCount = 0

    local dist = (root.Position - targetPos).Magnitude
    local timeNeeded = dist / flySpeed

    local tween = TweenService:Create(
        root,
        TweenInfo.new(timeNeeded, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(targetPos)}
    )

    tween:Play()

    for i = 1, math.floor(timeNeeded * 2) do
        task.wait(0.5)

        if not autoFarmEnabled then return end

        if not antiStuckCheck(root, lastPos) then
            stuckCount += 1
            if stuckCount >= 3 then
                safeReset()
                return
            end
            tween:Cancel()
            tween:Play()
        else
            stuckCount = 0
        end

        lastPos = root.Position
    end

    tween.Completed:Wait()
end

local function moveAlongPath()
    for _, point in ipairs(Route.steps[2].points) do
        if not autoFarmEnabled then break end
        local pos = point.position
        moveTo(Vector3.new(pos.X, pos.Y + flyHeight, pos.Z))
    end
end

--====================================================
-- Actions
--====================================================

local function buyRing()
    PurchaseWorldBuyableItem:FireServer(WorldBuyableItems["Fake Diamond Ring"])
end

local function pingVehicle()
    GetVehicleState:InvokeServer(Vehicles["Dodge Durango RT"])
end

local function sellGoods()
    SellSmuggledGoods:FireServer(NPC.Seller4)
end

local function pingServer()
    pcall(function()
        CanManageServer:InvokeServer()
    end)
end

--====================================================
-- Auto Farm Loop
--====================================================

task.spawn(function()
    while true do
        task.wait(0.2)

        if not autoFarmEnabled then continue end

        local root = getRoot()

        -- 1) الذهاب لنقطة الشراء
        local buyPos = Route.steps[1].position
        moveTo(Vector3.new(buyPos.X, buyPos.Y + flyHeight, buyPos.Z))

        -- 2) شراء الخواتم
        for i = 1, maxRings do
            if not autoFarmEnabled then break end
            buyRing()
            pingVehicle()
            pingServer()
            task.wait(0.2)
        end

        -- 3) الذهاب لنقطة البيع عبر المسار
        moveAlongPath()

        -- 4) بيع البضاعة
        sellGoods()
        pingServer()
    end
end)
