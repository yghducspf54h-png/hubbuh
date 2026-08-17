--====================================================
-- Auto Farm • Fake Diamond Ring
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
local TweenService = game:GetService("TweenService")

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
local maxRings, flyHeight, flySpeed = 5, 5, 120
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

    activeTween = TweenService:Create(root, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = CFrame.new(target)})
    activeTween:Play()

    local lastPos = root.Position
    local stuckTimer = 0

    while activeTween and activeTween.PlaybackState == Enum.PlaybackState.Playing do
        task.wait(0.2)
        if not autoFarm then stopAllMovement() return end

        local moved = (root.Position - lastPos).Magnitude
        if moved < 1 then
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

task.spawn(function()
    while true do
        task.wait(0.2)
        if not autoFarm then continue end

        -- الذهاب لنقطة الشراء
        moveTo(Route.BuyPos)

        -- شراء حسب العدد
        for i = 1, maxRings do
            if not autoFarm then break end
            buyRing()
            antiCheat()
            task.wait(0.3)
        end

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

-- زر التشغيل والإيقاف
local gui = Instance.new("ScreenGui", player.PlayerGui)
local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.fromOffset(140, 40)
btn.Position = UDim2.new(0.05, 0, 0.05, 0)
btn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
btn.Text = "Auto Farm: OFF"
btn.TextColor3 = Color3.new(1,1,1)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14

btn.MouseButton1Click:Connect(function()
    autoFarm = not autoFarm
    btn.Text = autoFarm and "Auto Farm: ON" or "Auto Farm: OFF"
    if not autoFarm then
        stopAllMovement()
    end
end)
