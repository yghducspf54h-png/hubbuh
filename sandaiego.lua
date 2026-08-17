--====================================================
-- Auto Farm • Fake Diamond Ring (Speed Mode)
-- By المبجّل • Discord: almbjl
--====================================================

local RS = game:GetService("ReplicatedStorage")
local Remotes = RS:WaitForChild("__remotes")
local BuyRemote = Remotes.WorldBuyableItemService.PurchaseWorldBuyableItem
local SellRemote = Remotes.SmuggleService.SellSmuggledGoods
local AntiCheatRemote = Remotes.CustomServerService.CanManageServer

local Items = workspace.WorldBuyableItems.CivilianArea
local NPC = workspace.NPC
local player = game.Players.LocalPlayer

--========================
-- المسار
--========================
local Route = {
    BuyPos = Vector3.new(6820.766, 17.421, 19.468),
    Points = {
        Vector3.new(6842.128, 17.223, 19.321),
        Vector3.new(6841.736, 17.223, 142.829),
        Vector3.new(5904.539, 17.223, 146.274),
        Vector3.new(4561.280, 17.223, 147.949),
        Vector3.new(3010.252, 17.223, 150.880),
        Vector3.new(2779.545, 17.223, 148.855),
        Vector3.new(2550.742, 17.223, 142.769),
        Vector3.new(1900.172, 17.223, 140.795),
        Vector3.new(720.947, 17.223, 137.434),
        Vector3.new(196.229, 17.223, 134.763),
        Vector3.new(193.469, 17.223, -34.899),
        Vector3.new(192.914, 17.223, -54.420),
        Vector3.new(206.688, 17.082, -53.580),
        Vector3.new(207.952, 17.244, -44.035),
    }
}

local autoFarm = false
local maxRings = 10
local speed = 150

--========================
-- نظام الحركة الجديد (بدون طيران)
--========================
local function Root()
    return player.Character:WaitForChild("HumanoidRootPart")
end

local function floatMode()
    local root = Root()

    if not root:FindFirstChild("BV") then
        local bv = Instance.new("BodyVelocity", root)
        bv.Name = "BV"
        bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        bv.Velocity = Vector3.new(0, 0, 0)
    end

    if not root:FindFirstChild("BG") then
        local bg = Instance.new("BodyGyro", root)
        bg.Name = "BG"
        bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        bg.CFrame = root.CFrame
    end
end

local function stopMovement()
    local root = Root()
    if root:FindFirstChild("BV") then
        root.BV.Velocity = Vector3.new(0,0,0)
    end
end

local function moveTo(pos)
    floatMode()
    local root = Root()

    while autoFarm and (root.Position - pos).Magnitude > 3 do
        root.BV.Velocity = (pos - root.Position).Unit * speed
        task.wait()
    end

    stopMovement()
end

--========================
-- شراء حسب العدد
--========================
local function buyRings()
    for i = 1, maxRings do
        if not autoFarm then break end
        BuyRemote:FireServer(Items["Fake Diamond Ring"])
        AntiCheatRemote:InvokeServer()
        task.wait(0.2)
    end
end

--========================
-- بيع سبام لين يتأكد إنه انباع
--========================
local function sellSpam()
    local root = Root()
    stopMovement()

    local stats = player:FindFirstChild("leaderstats")
    if not stats then
        repeat
            task.wait(0.2)
            stats = player:FindFirstChild("leaderstats")
        until stats
    end

    local moneyStat = stats:FindFirstChild("Money")
    local before = moneyStat and moneyStat.Value or 0

    local seller = NPC:FindFirstChild("Seller4")
    if not seller then return end

    for i = 1, 100 do
        SellRemote:FireServer(seller)
        AntiCheatRemote:InvokeServer()
        task.wait(0.05)

        if moneyStat and moneyStat.Value > before then
            print("✔ انباع فعليًا")
            break
        end
    end

    task.wait(3)
end

--========================
-- اللوب الأساسي
--========================
task.spawn(function()
    while true do
        task.wait(0.2)
        if not autoFarm then continue end

        moveTo(Route.BuyPos)
        buyRings()

        for _, p in ipairs(Route.Points) do
            if not autoFarm then break end
            moveTo(p)
        end

        sellSpam()

        for i = #Route.Points, 1, -1 do
            if not autoFarm then break end
            moveTo(Route.Points[i])
        end
    end
end)

--========================
-- واجهة زر واحد فقط
--========================
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.fromOffset(160, 40)
btn.Position = UDim2.new(0.05, 0, 0.05, 0)
btn.BackgroundColor3 = Color3.fromRGB(60,120,200)
btn.TextColor3 = Color3.new(1,1,1)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14
btn.Text = "Auto Farm: OFF"

btn.MouseButton1Click:Connect(function()
    autoFarm = not autoFarm
    btn.Text = autoFarm and "Auto Farm: ON" or "Auto Farm: OFF"
end)
