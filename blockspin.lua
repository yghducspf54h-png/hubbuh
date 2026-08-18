-- تحميل مكتبة الواجهات (Rayfield UI)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "almbjl | Max Edition - Combat System",
   LoadingTitle = "جاري تحميل النظام الأفضل...",
   LoadingSubtitle = "by almbjl",
   ConfigurationSaving = {
      Enabled = false,
   },
   KeySystem = false,
})

local Tab = Window:CreateTab("التحكم والقتال", 4483362458)

-- المتغيرات والخصائص
local _G_Settings = {
    SilentAimEnabled = true,
    WallCheck = true,
    ESPEnabled = true,
    TeamCheck = true
}

-- قسم الأيم بوت والطلقة التلقائية
Tab:CreateSection("إعدادات الطلقة والأيم بوت (Max)")

Tab:CreateToggle({
   Name = "تفعيل توجيه الطلقة لأقرب لاعب (Silent Aim)",
   CurrentValue = true,
   Flag = "SilentAimToggle",
   Callback = function(Value)
      _G_Settings.SilentAimEnabled = Value
   end,
})

Tab:CreateToggle({
   Name = "فحص الجدران (عدم كشف الأهداف خلف الجدران)",
   CurrentValue = true,
   Flag = "WallCheckToggle",
   Callback = function(Value)
      _G_Settings.WallCheck = Value
   end,
})

-- قسم الـ ESP
Tab:CreateSection("نظام الكشف (ESP)")

Tab:CreateToggle({
   Name = "تفعيل كشف اللاعبين (ESP)",
   CurrentValue = true,
   Flag = "ESPToggle",
   Callback = function(Value)
      _G_Settings.ESPEnabled = Value
      -- كود تفعيل/تعطيل الإي إس بي هنا
   end,
})

-- المنطق البرمجي للوظائف (الطلقة التلقائية مع فحص الجدران)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local function isVisible(targetPart, originPos)
    if not _G_Settings.WallCheck then return true end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.IgnoreWater = true
    
    local direction = targetPart.Position - originPos
    local result = Workspace:Raycast(originPos, direction, raycastParams)
    
    if result then
        -- لو العائق هو جزء من جسم اللاعب المستهدف نفسه أو موديل اللاعب تعتبر رؤية صحيحة
        local hitInstance = result.Instance
        if hitInstance:IsDescendantOf(targetPart.Parent) then
            return true
        end
        return false -- يوجد جدار يعيق الرؤية
    end
    
    return true
end

local function getBestTarget()
    local closestTarget = nil
    local shortestDistance = math.huge
    local character = LocalPlayer.Character
    
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    local myRoot = character.HumanoidRootPart
    local originPos = myRoot.Position + Vector3.new(0, 2, 0)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = player.Character.HumanoidRootPart
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            
            if humanoid and humanoid.Health > 0 then
                -- تطبيق فحص الجدران إذا كان مفعلًا
                if isVisible(targetRoot, originPos) then
                    local distance = (targetRoot.Position - myRoot.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestTarget = player
                    end
                end
            end
        end
    end
    
    return closestTarget
end

-- حلقة إطلاق النار التلقائية عند تفعيل الميزة
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G_Settings.SilentAimEnabled then
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            local weapon = backpack and backpack:FindFirstChild("AK47") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("AK47"))
            
            if weapon and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetPlayer = getBestTarget()
                
                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local targetRoot = targetPlayer.Character.HumanoidRootPart
                    local myRoot = LocalPlayer.Character.HumanoidRootPart
                    local originPos = myRoot.Position + Vector3.new(0, 2, 0)
                    
                    local initialDist = (targetRoot.Position - originPos).Magnitude
                    local predictionFactor = math.clamp(initialDist / 800, 0.015, 0.06)
                    local futurePos = targetRoot.Position + (targetRoot.AssemblyLinearVelocity * predictionFactor)
                    local direction = (futurePos - originPos).Unit
                    local distanceVal = (futurePos - originPos).Magnitude
                    local firedTime = tick()
                    
                    local bulletCounter = math.random(1000, 9999)
                    
                    -- إطلاق الحدث للسيرفر
                    local success, err = pcall(function()
                        local weaponsSystem = ReplicatedStorage:WaitForChild("WeaponsSystem", 2)
                        if weaponsSystem then
                            local net = weaponsSystem:WaitForChild("Network", 2)
                            if net then
                                net.WeaponFired:FireServer(weapon, {
                                    id = bulletCounter,
                                    charge = 0,
                                    origin = vector.create(originPos.X, originPos.Y, originPos.Z),
                                    dir = vector.create(direction.X, direction.Y, direction.Z)
                                })
                                
                                task.wait(distanceVal / 300)
                                
                                net.WeaponHit:FireServer(weapon, {
                                    p = vector.create(futurePos.X, futurePos.Y, futurePos.Z),
                                    pid = bulletCounter,
                                    part = targetRoot,
                                    d = distanceVal,
                                    maxDist = distanceVal * 1.1,
                                    h = targetPlayer.Character,
                                    m = targetRoot.Material,
                                    n = targetRoot.CFrame.UpVector,
                                    t = tick() - firedTime,
                                    sid = bulletCounter
                                })
                            end
                        end
                    end)
                end
            end
        end
    end
end)
