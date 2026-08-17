--====================================================
-- Auto Farm • Fake Diamond Ring
-- By المبجّل • Discord: almbjl
--====================================================

---------------------------
-- ROUTE DATA
---------------------------
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

---------------------------
-- REMOTES
---------------------------
local RS = game:GetService("ReplicatedStorage")
local Remotes = RS:WaitForChild("__remotes")

local PurchaseWorldBuyableItem = Remotes.WorldBuyableItemService.PurchaseWorldBuyableItem
local GetVehicleState = Remotes.VehicleService.GetVehicleState
local SellSmuggledGoods = Remotes.SmuggleService.SellSmuggledGoods
local CanManageServer = Remotes.CustomServerService.CanManageServer

local WorldBuyableItems = workspace.WorldBuyableItems.CivilianArea
local Vehicles = workspace.Vehicles
local NPC = workspace.NPC

---------------------------
-- PLAYER / SERVICES
---------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

local function getRoot()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

---------------------------
-- GUI
---------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "AutoFarmGUI_almbjl"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(420, 260)
main.Position = UDim2.new(0.5, -210, 0.5, -130)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
main.BorderSizePixel = 0
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = main

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
header.BorderSizePixel = 0
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -120, 1, 0)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "Auto Farm • المبجّل"
title.TextColor3 = Color3.fromRGB(240, 240, 245)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local discord = Instance.new("TextLabel")
discord.Size = UDim2.new(0, 120, 1, 0)
discord.Position = UDim2.new(1, -120, 0, 0)
discord.BackgroundTransparency = 1
discord.Text = "Discord: almbjl"
discord.TextColor3 = Color3.fromRGB(180, 180, 190)
discord.TextSize = 11
discord.Font = Enum.Font.Gotham
discord.TextXAlignment = Enum.TextXAlignment.Right
discord.Parent = header

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -20, 1, -50)
content.Position = UDim2.fromOffset(10, 45)
content.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
content.BorderSizePixel = 0
content.Parent = main

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 8)
contentCorner.Parent = content

---------------------------
-- UI ELEMENTS
---------------------------
local autoFarmEnabled = false
local maxRings = 5
local flyHeight = 5
local flySpeed = 60

local function makeLabel(text, y)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -20, 0, 18)
    l.Position = UDim2.fromOffset(10, y)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(200, 200, 210)
    l.TextSize = 11
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = content
    return l
end

local function makeBox(y, default)
    local b = Instance.new("TextBox")
    b.Size = UDim2.fromOffset(120, 26)
    b.Position = UDim2.fromOffset(10, y)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    b.BorderSizePixel = 0
    b.Text = tostring(default)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 12
    b.Font = Enum.Font.Gotham
    b.ClearTextOnFocus = false
    b.Parent = content
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = b
    return b
end

local function makeButton(text, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(160, 28)
    b.Position = UDim2.fromOffset(200, y)
    b.BackgroundColor3 = Color3.fromRGB(55, 95, 180)
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.Parent = content
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = b
    return b
end

makeLabel("تشغيل الأوتو فارم", 8)
local autoBtn = makeButton("Auto Farm: OFF", 26)

makeLabel("عدد Fake Diamond Ring (1 - 8)", 60)
local ringsBox = makeBox(78, 5)

makeLabel("ارتفاع فوق الأرض", 112)
local heightBox = makeBox(130, 5)

makeLabel("سرعة الطيران", 164)
local speedBox = makeBox(182, 60)

local showRouteBtn = makeButton("إظهار المسار في الـ Output", 216)

autoBtn.MouseButton1Click:Connect(function()
    autoFarmEnabled = not autoFarmEnabled
    autoBtn.Text = autoFarmEnabled and "Auto Farm: ON" or "Auto Farm: OFF"
    autoBtn.BackgroundColor3 = autoFarmEnabled and Color3.fromRGB(55, 150, 90) or Color3.fromRGB(55, 95, 180)
end)

ringsBox.FocusLost:
