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
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")

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
local walkSpeed = 22

--========================
-- حركة طبيعية بدون كشف
--========================
local function moveTo(pos)
    hum.WalkSpeed = walkSpeed
    hum:MoveTo(pos)

    while autoFarm and (char.PrimaryPart.Position - pos).Magnitude > 4 do
        task.wait()
    end
end

--========================
-- شراء حسب العدد
--========================
local function buyRings()
    for i = 1, maxRings do
        if not autoFarm then break end
        BuyRemote:FireServer(Items["Fake Diamond Ring"])
        AntiCheatRemote:InvokeServer()
        task.wait(0.15)
    end
end

--========================
-- سبام بيع لين يتأكد إنه انباع
--========================
local function sellSpam()
    local before = player.leaderstats.Money.Value

    for i = 1, 30 do
        SellRemote:FireServer(NPC["Seller4"])
        AntiCheatRemote:InvokeServer()
        task.wait(0.1)

        if player.leaderstats.Money.Value > before then
            print("✔ انباع فعليًا")
            break
        end
    end
end

--========================
-- اللوب الأساسي
--========================
task.spawn(function()
    while true do
        task.wait(0.2)
        if not autoFarm then continue end

        -- شراء
        moveTo(Route.BuyPos)
        buyRings()

        -- الذهاب للبائع
        for _, p in ipairs(Route.Points) do
            if not autoFarm then break end
            moveTo(p)
        end

        -- بيع سبام
        sellSpam()

        -- الرجوع
        for i = #Route.Points, 1, -1 do
            if not autoFarm then break end
            moveTo(Route.Points[i])
        end
    end
end)

--========================
-- واجهة
--========================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(220, 150)
frame.Position = UDim2.new(0.05, 0, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,35)
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.fromOffset(200, 35)
btn.Position = UDim2.fromOffset(10, 10)
btn.BackgroundColor3 = Color3.fromRGB(60,120,200)
btn.TextColor3 = Color3.new(1,1,1)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14
btn.Text = "Auto Farm: OFF"

btn.MouseButton1Click:Connect(function()
    autoFarm = not autoFarm
    btn.Text = autoFarm and "Auto Farm: ON" or "Auto Farm: OFF"
end)

local ringsBox = Instance.new("TextBox", frame)
ringsBox.Size = UDim2.fromOffset(80, 30)
ringsBox.Position = UDim2.fromOffset(10, 60)
ringsBox.BackgroundColor3 = Color3.fromRGB(45,45,50)
ringsBox.Text = tostring(maxRings)
ringsBox.TextColor3 = Color3.new(1,1,1)
ringsBox.Font = Enum.Font.Gotham
ringsBox.TextSize = 12
ringsBox.ClearTextOnFocus = false
Instance.new("UICorner", ringsBox).CornerRadius = UDim.new(0,6)

ringsBox.FocusLost:Connect(function()
    maxRings = math.clamp(tonumber(ringsBox.Text) or maxRings, 1, 10)
    ringsBox.Text = tostring(maxRings)
end)

local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.fromOffset(80, 30)
speedBox.Position = UDim2.fromOffset(110, 60)
speedBox.BackgroundColor3 = Color3.fromRGB(45,45,50)
speedBox.Text = tostring(walkSpeed)
speedBox.TextColor3 = Color3.new(1,1,1)
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 12
speedBox.ClearTextOnFocus = false
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0,6)

speedBox.FocusLost:Connect(function()
    walkSpeed = math.clamp(tonumber(speedBox.Text) or walkSpeed, 10, 40)
    speedBox.Text = tostring(walkSpeed)
end)
