--====================================================
-- Auto Farm - Fake Diamond Ring
-- By almbjl (المبجّل)
--====================================================

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
task.wait(1)

local window = WindUI:Window({
    Title = "Auto Farm • Fake Diamond Ring | المبجّل",
    Subtitle = "Discord: almbjl",
    Theme = "Dark",
})

local tab = window:Tab("Auto Farm")

local autoFarmEnabled = false
local flyHeight = 5
local flySpeed = 60
local maxRings = 5

tab:Toggle({
    Name = "تشغيل الأوتو فارم",
    Default = false,
    Callback = function(v)
        autoFarmEnabled = v
    end,
})

tab:Slider({
    Name = "عدد Fake Diamond Ring",
    Min = 1, Max = 8, Default = 5,
    Callback = function(v)
        maxRings = v
    end,
})

tab:Slider({
    Name = "ارتفاع فوق الأرض",
    Min = 2, Max = 20, Default = 5,
    Callback = function(v)
        flyHeight = v
    end,
})

tab:Slider({
    Name = "سرعة الطيران",
    Min = 20, Max = 120, Default = 60,
    Callback = function(v)
        flySpeed = v
    end,
})

tab:Button({
    Name = "إظهار المسار في الـ Output",
    Callback = function()
        print("========== ROUTE ==========")
        print("المسار جاهز ✅")
    end,
})

--====================================================
-- نظام Anti‑Stuck + الأوتو فارم
--====================================================

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
local TweenService = game:GetService("TweenService")

local function getRoot()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local function antiStuckCheck(root, lastPos)
    local moved = (root.Position - lastPos).Magnitude
    return moved >= 2
end

local function safeReset()
    local root = getRoot()
    root.CFrame = CFrame.new(6820.941, 17.421 + flyHeight, 20.054)
end

local function moveTo(targetPos)
    local root = getRoot()
    local lastPos = root.Position
    local stuckCount = 0

    local dist = (root.Position - targetPos).Magnitude
    local timeNeeded = dist / flySpeed

    local tween = TweenService:Create(root, TweenInfo.new(timeNeeded, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
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

task.spawn(function()
    while true do
        task.wait(0.2)
        if not autoFarmEnabled then continue end

        local root = getRoot()
        moveTo(Vector3.new(6820.941, 17.421 + flyHeight, 20.054))

        for i = 1, maxRings do
            if not autoFarmEnabled then break end
            buyRing()
            pingVehicle()
            pingServer()
            task.wait(0.2)
        end

        moveTo(Vector3.new(215.130, 17.244 + flyHeight, -39.732))
        sellGoods()
        pingServer()
    end
end)
