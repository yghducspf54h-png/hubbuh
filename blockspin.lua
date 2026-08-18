-- تحميل مكتبة الواجهات (Rayfield UI)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "almbjl | Max Edition - Combat System",
   LoadingTitle = " 1جاري تحميل النظام الأفضل...",
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
    AimbotEnabled = true,
    WallCheck = true,
    ESPEnabled = true,
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
   Name = "تفعيل الأيم بوت (زر الماوس الأيمن)",
   CurrentValue = true,
   Flag = "AimbotToggle",
   Callback = function(Value)
      _G_Settings.AimbotEnabled = Value
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
      if not Value then
          -- إزالة الـ ESP فوراً عند الإيقاف
          for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
              if p.Character and p.Character:FindFirstChild("almbjl_ESP") then
                  p.Character.almbjl_ESP:Destroy()
              end
          end
      end
   end,
})

-- المنطق البرمجي
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera

-- دالة فحص الجدران (WallCheck)
local function isVisible(targetPart, originPos)
    if not _G_Settings.WallCheck then return true end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.IgnoreWater = true
    
    local direction = targetPart.Position - originPos
    local result = Workspace:Raycast(originPos, direction, raycastParams)
    
    if result then
        local hitInstance = result.Instance
        if hitInstance:IsDescendantOf(targetPart.Parent) then
            return true
        end
        return false -- يوجد جدار يعيق الرؤية
    end
    
    return true
end

-- دالة جلب أفضل وأقرب تارجت
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

-- 1. نظام الـ ESP المحدث باستمرار (يتعامل مع الموت والإحياء واللاعبين الجدد)
RunService.RenderStepped:Connect(function()
    if not _G_Settings.ESPEnabled then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local char = player.Character
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            
            if humanoid and humanoid.Health > 0 then
                if not char:FindFirstChild("almbjl_ESP") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "almbjl_ESP"
                    highlight.Adornee = char
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Parent = char
                end
            else
                -- لو اللاعب مات، احذف الإي إس بي عنه
                if char:FindFirstChild("almbjl_ESP") then
                    char.almbjl_ESP:Destroy()
                end
            end
        end
    end
end)

-- 2. نظام الأيم بوت (يعمل عند الضغط مطولاً على كلك يمين ويتخطى الجدران)
RunService.RenderStepped:Connect(function()
    if _G_Settings.AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getBestTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPart = target.Character.HumanoidRootPart
            -- توجيه الكاميرا بسلاسة نحو اللاعب المستهدف
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
        end
    end
end)

-- 3. حلقة السايلت آيم (إطلاق الطلقة التلقائية الموجهة لأقرب لاعب دون تعديل)
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
                    
                    pcall(function()
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
