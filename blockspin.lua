-- تحميل مكتبة الواجهات (Rayfield UI)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "almbjl | Max Edition - Combat System",
   LoadingTitle = "جاري تحميل النظام الأفضل...",
   LoadingSubtitle = "by Discord almbjl",
   ConfigurationSaving = {
      Enabled = false,
   },
   KeySystem = false,
})

local Tab = Window:CreateTab("التحكم والقتال", 4483362458)

-- المتغيرات والخصائص
local _G_Settings = {
    SilentAimMode = "Closest", -- الخيارات: "Closest" (أقرب لاعب) أو "All" (كل اللاعبين) أو "Off"
    AimbotEnabled = true,
    WallCheck = true,
    ESPEnabled = true,
    FOvSize = 120,             -- حجم دائرة الـ FOV للجوال
}

-- قسم الأيم بوت والطلقة التلقائية
Tab:CreateSection("إعدادات الطلقة والأيم بوت (Max)")

Tab:CreateDropdown({
   Name = "نظام توجيه الطلقة (Silent Aim)",
   Options = {"أقرب لاعب فقط (Closest)", "كل اللاعبين في الماب (All)", "إيقاف (Off)"},
   CurrentOption = {"أقرب لاعب فقط (Closest)"},
   Flag = "SilentAimModeFlag",
   Callback = function(Option)
      local choice = Option[1]
      if string.find(choice, "Closest") then
          _G_Settings.SilentAimMode = "Closest"
      elseif string.find(choice, "All") then
          _G_Settings.SilentAimMode = "All"
      else
          _G_Settings.SilentAimMode = "Off"
      end
   end,
})

Tab:CreateToggle({
   Name = "تفعيل الأيم بوت (تلقائي: PC كلك يمين / Mobile دائرة FOV)",
   CurrentValue = true,
   Flag = "AimbotToggle",
   Callback = function(Value)
      _G_Settings.AimbotEnabled = Value
   end,
})

Tab:CreateSlider({
   Name = "حجم دائرة الـ FOV (للايباد والجوال)",
   Range = {50, 300},
   Increment = 5,
   CurrentValue = 120,
   Flag = "FOVSliderFlag",
   Callback = function(Value)
      _G_Settings.FOvSize = Value
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
          for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
              if p.Character and p.Character:FindFirstChild("almbjl_ESP") then
                  p.Character.almbjl_ESP:Destroy()
              end
          end
      end
   end,
})

-- الخدمات والمتغيرات الأساسية
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera

-- إنشاء دائرة الـ FOV المرئية للجوال/الآيباد
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Transparency = 0.7
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false

-- معرفة نوع الجهاز
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

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
        return false 
    end
    
    return true
end

-- دالة جلب أفضل تارجت للأيم بوت
local function getAimbotTarget()
    local bestTarget = nil
    local shortestDistance = math.huge
    local character = LocalPlayer.Character
    
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    local myRoot = character.HumanoidRootPart
    local originPos = myRoot.Position + Vector3.new(0, 2, 0)
    local mouseLocation = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = player.Character.HumanoidRootPart
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            
            if humanoid and humanoid.Health > 0 then
                if isVisible(targetRoot, originPos) then
                    if isMobile then
                        local screenPoint, onScreen = Camera:WorldToViewportPoint(targetRoot.Position)
                        if onScreen then
                            local screenDist = (Vector2.new(screenPoint.X, screenPoint.Y) - mouseLocation).Magnitude
                            if screenDist <= _G_Settings.FOvSize and screenDist < shortestDistance then
                                shortestDistance = screenDist
                                bestTarget = player
                            end
                        end
                    else
                        local distance = (targetRoot.Position - myRoot.Position).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            bestTarget = player
                        end
                    end
                end
            end
        end
    end
    
    return bestTarget
end

-- دالة جلب أهداف السايلنت آيم (مصححة ومحدثة لضمان عملها فوراً)
local function getSilentAimTargets()
    local targets = {}
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return targets end
    local myRoot = character.HumanoidRootPart
    local originPos = myRoot.Position + Vector3.new(0, 2, 0)

    if _G_Settings.SilentAimMode == "Closest" then
        local closest = nil
        local minDist = math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local targetRoot = player.Character.HumanoidRootPart
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    if isVisible(targetRoot, originPos) then
                        local dist = (targetRoot.Position - myRoot.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            closest = player
                        end
                    end
                end
            end
        end
        if closest then table.insert(targets, closest) end
    elseif _G_Settings.SilentAimMode == "All" then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local targetRoot = player.Character.HumanoidRootPart
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    if isVisible(targetRoot, originPos) then
                        table.insert(targets, player)
                    end
                end
            end
        end
    end
    
    return targets
end

-- نظام الـ ESP المحدث باستمرار
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
                if char:FindFirstChild("almbjl_ESP") then
                    char.almbjl_ESP:Destroy()
                end
            end
        end
    end
end)

-- نظام الأيم بوت (PC و Mobile)
RunService.RenderStepped:Connect(function()
    if isMobile then
        FOVCircle.Visible = _G_Settings.AimbotEnabled
        FOVCircle.Radius = _G_Settings.FOvSize
        FOVCircle.Position = UserInputService:GetMouseLocation()
    else
        FOVCircle.Visible = false
    end

    if _G_Settings.AimbotEnabled then
        local shouldAim = false
        if isMobile then
            shouldAim = true 
        else
            shouldAim = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) 
        end

        if shouldAim then
            local target = getAimbotTarget()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local targetPart = target.Character.HumanoidRootPart
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
            end
        end
    end
end)

-- حلقة السايلت آيم المصححة (تستدعي الأحداث بشكل مباشر وتضمن إرسال الطلقات)
task.spawn(function()
    while true do
        task.wait(0.05)
        if _G_Settings.SilentAimMode ~= "Off" then
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            local weapon = backpack and backpack:FindFirstChild("AK47") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("AK47"))
            
            if weapon and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targets = getSilentAimTargets()
                
                for _, targetPlayer in ipairs(targets) do
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
                        
                        local bulletCounter = math.random(10000, 99999)
                        
                        pcall(function()
                            local weaponsSystem = ReplicatedStorage:FindFirstChild("WeaponsSystem")
                            if weaponsSystem then
                                local net = weaponsSystem:FindFirstChild("Network")
                                if net then
                                    local firedEvent = net:FindFirstChild("WeaponFired")
                                    local hitEvent = net:FindFirstChild("WeaponHit")
                                    
                                    if firedEvent and hitEvent then
                                        firedEvent:FireServer(weapon, {
                                            id = bulletCounter,
                                            charge = 0,
                                            origin = vector.create(originPos.X, originPos.Y, originPos.Z),
                                            dir = vector.create(direction.X, direction.Y, direction.Z)
                                        })
                                        
                                        task.wait(distanceVal / 300)
                                        
                                        hitEvent:FireServer(weapon, {
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
                            end
                        end)
                    end
                end
            end
        end
    end
end)
