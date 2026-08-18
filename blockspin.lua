local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- عداد عشوائي لتوليد IDs متغيرة لكل طلقة
local bulletCounter = math.random(100, 999)

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local character = LocalPlayer.Character
    
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    local myRoot = character.HumanoidRootPart

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = player.Character.HumanoidRootPart
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            
            if humanoid and humanoid.Health > 0 then
                local distance = (targetRoot.Position - myRoot.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    return closestPlayer
end

local backpack = LocalPlayer:WaitForChild("Backpack")
local weapon = backpack:FindFirstChild("AK47") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("AK47"))

if not weapon then
    warn("سلاح AK47 غير موجود!")
    return
end

local targetPlayer = getClosestPlayer()

if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
    local targetRoot = targetPlayer.Character.HumanoidRootPart
    local targetCharacter = targetPlayer.Character
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    
    if myRoot then
        bulletCounter = bulletCounter + 1
        local originPos = myRoot.Position + Vector3.new(0, 2, 0)
        
        -- 1. تحسين معامل التوقع (predictionFactor) ليكون أكثر دقة ومرونة حسب المسافة
        local initialDist = (targetRoot.Position - originPos).Magnitude
        local predictionFactor = math.clamp(initialDist / 800, 0.015, 0.06)
        
        local futurePos = targetRoot.Position + (targetRoot.AssemblyLinearVelocity * predictionFactor)
        local direction = (futurePos - originPos).Unit
        
        local distanceVal = (futurePos - originPos).Magnitude
        local firedTime = tick()
        
        -- إرسال حدث إطلاق النار
        local argsFire = {
            weapon,
            {
                id = bulletCounter,
                charge = 0,
                origin = vector.create(originPos.X, originPos.Y, originPos.Z),
                dir = vector.create(direction.X, direction.Y, direction.Z)
            }
        }
