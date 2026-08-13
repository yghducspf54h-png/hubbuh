-- ==========================================
-- BlockSpin ULTIMATE SCRIPT (V9 - Full Wiki Edition)
-- مبني بالكامل على معلومات BlockSpin Wiki
-- ==========================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==========================================
-- 1️⃣ الإعدادات (Settings)
-- ==========================================
local Settings = {
    ESP = true,
    FOV_Offset = 15,
    
    Janitor_Farm_Active = true,
    Cook_Farm_Active = true,
    
    ATM_Hack_Active = true,
    ATM_Hack_Delay = 2.5,
    ATM_Error_Cooldown = 60,
    
    FishingFarm_Active = true,
    FishingFarm_Delay = 0.3,
    
    ItemBot_Active = true,
    ItemBot_Range = 20,
    
    Vehicle_Farm_Active = true,
    Vehicle_Speed = 18,
    
    SafeHouse_Active = true,
}

-- ==========================================
-- 2️⃣ نظام ESP (إطار أخضر واسم اللاعب)
-- ==========================================
local espObjects = {}
local function clearESP()
    for _, obj in pairs(espObjects) do if obj and obj.Parent then obj:Destroy() end end
    espObjects = {}
end
local function updateESP()
    if not Settings.ESP then clearESP() return end
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Head") then
            local head = otherPlayer.Character.Head
            if not head:FindFirstChild("BS_ESP") then
                local gui = Instance.new("BillboardGui")
                gui.Name = "BS_ESP"
                gui.Adornee = head
                gui.Size = UDim2.new(0, 100, 0, 50)
                gui.StudsOffset = Vector3.new(0, 2.5, 0)
                gui.AlwaysOnTop = true
                gui.Parent = head
                
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, 0, 1, 0)
                frame.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- أخضر
                frame.BackgroundTransparency = 0.5
                frame.Parent = gui
                
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(1, 0, 1, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = otherPlayer.Name
                nameLabel.TextColor3 = Color3.new(1, 1, 1)
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextScaled = true
                nameLabel.Parent = frame
                
                espObjects[gui] = gui
            end
        end
    end
end

-- ==========================================
-- 3️⃣ نظام FOV Boost (90 → 105 بأسلوب ناعم)
-- ==========================================
local function ApplyFOV()
    local camera = Workspace.CurrentCamera
    if not camera then return end
    local targetFOV = 90 + Settings.FOV_Offset
    if targetFOV > 120 then targetFOV = 120 end
    TweenService:Create(camera, TweenInfo.new(1), {FieldOfView = targetFOV}):Play()
end

-- ==========================================
-- دوال مساعدة (Helper Functions)
-- ==========================================
local function getCharacter()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        return char
    end
    return nil
end

local function getClosestPart(name, maxDistance)
    local char = getCharacter()
    if not char then return nil, math.huge end
    local rootPart = char.HumanoidRootPart
    local closestPart, shortestDistance = nil, maxDistance
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and string.match(obj.Name:lower(), name) then
            local dist = (rootPart.Position - obj.Position).Magnitude
            if dist < shortestDistance then
                shortestDistance = dist
                closestPart = obj
            end
        end
    end
    return closestPart, shortestDistance
end

-- ==========================================
-- 4️⃣ & 5️⃣ Job Farming (Janitor + Cook) + ATM Hack
-- تم دمجها في لوب ذكي يفحص الأداة الممسوكة
-- ==========================================
task.spawn(function()
    while task.wait(0.2) do
        local char = getCharacter()
        if char then
            local tool = char:FindFirstChildWhichIsA("Tool")
            if tool then
                local toolName = tool.Name:lower()
                
                -- 4. وظيفة التنظيف (Janitor - Mop)
                if Settings.Janitor_Farm_Active and (toolName:match("mop") or toolName:match("broom")) then
                    tool:Activate() -- نقر سريع لتنظيف البقع
                    task.wait(0.1)
                
                -- 5. وظيفة الطبخ (Cook - Skillet)
                elseif Settings.Cook_Farm_Active and (toolName:match("skillet") or toolName:match("pan") or toolName:match("knife")) then
                    tool:Activate() -- نقر لطهي الطعام
                    task.wait(0.5)
                
                -- 6. اختراق الصرافيات (ATM Hack - Hack Tool)
                elseif Settings.ATM_Hack_Active and (toolName:match("hack") or toolName:match("laptop")) then
                    local closestATM, dist = getClosestPart("atm", 100)
                    if closestATM then
                        char.Humanoid:MoveTo(closestATM.Position)
                        if dist <= 4 then
                            -- محاولة الاختراق (الشريط الأخضر 3 مرات)
                            tool:Activate()
                            task.wait(Settings.ATM_Hack_Delay)
                            
                            -- انتظار وقت التعطل (Cooldown)
                            task.wait(Settings.ATM_Error_Cooldown)
                        end
                    end
                
                -- 7. وظيفة الصيد (Fishing - FishingRod)
                elseif Settings.FishingFarm_Active and (toolName:match("rod") or toolName:match("fishing")) then
                    tool:Activate()
                    task.wait(2) -- الانتظار حتى يعلق السمك
                    tool:Deactivate()
                    task.wait(Settings.FishingFarm_Delay)
                end
            end
        end
    end
end)

-- ==========================================
-- 8️⃣ Item Bot (جمع الأشياء تلقائياً ضمن مدى 20م)
-- ==========================================
task.spawn(function()
    while task.wait(0.2) do
        if Settings.ItemBot_Active then
            local char = getCharacter()
            if char then
                local rootPart = char.HumanoidRootPart
                local humanoid = char.Humanoid
                
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if (obj:IsA("Tool") and obj:FindFirstChild("Handle")) or 
                       (obj:IsA("BasePart") and (obj.Name:lower():match("cash") or obj.Name:lower():match("money") or obj.Name:lower():match("loot"))) then
                        local part = obj:IsA("Tool") and obj.Handle or obj
                        local distance = (rootPart.Position - part.Position).Magnitude
                        
                        if distance <= Settings.ItemBot_Range then
                            humanoid:MoveTo(part.Position)
                            if distance <= 5 then
                                -- سحب الأداة نحو اللاعب لالتقاطها فوراً
                                part.CFrame = rootPart.CFrame
                            end
                            break -- نجمع عنصر واحد في كل دورة
                        end
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- 9️⃣ Vehicle Farm (تحسين سرعة السيارة)
-- ==========================================
task.spawn(function()
    while task.wait(1) do
        if Settings.Vehicle_Farm_Active then
            local char = getCharacter()
            if char and char:FindFirstChild("Humanoid") then
                local seat = char.Humanoid.SeatPart
                if seat and seat:IsA("VehicleSeat") then
                    -- تعديل سرعة السيارة إذا كان اللاعب يقودها
                    if seat:FindFirstChild("MaxSpeed") then
                        seat.MaxSpeed.Value = Settings.Vehicle_Speed * 1.5
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- 🔟 Safe House System (حماية المال عند نقص الدم)
-- ==========================================
task.spawn(function()
    while task.wait(1) do
        if Settings.SafeHouse_Active then
            local char = getCharacter()
            if char and char.Humanoid and char.Humanoid.Health < (char.Humanoid.MaxHealth * 0.3) then
                -- إذا نقص دم اللاعب لـ 30%، يحاول السكربت إيقاف الفارم للحظات لتجنب الموت وفقدان المال
                Settings.Janitor_Farm_Active = false
                Settings.Cook_Farm_Active = false
                Settings.ATM_Hack_Active = false
                Settings.FishingFarm_Active = false
            end
        end
    end
end)

-- لوب تحديث الـ ESP
task.spawn(function()
    while task.wait(1) do
        if Settings.ESP then updateESP() end
    end
end)

-- ==========================================
-- 🖥️ واجهة التحكم GUI
-- ==========================================
local function CreateGUI()
    local oldGui = playerGui:FindFirstChild("BlockSpin_Ultimate_GUI")
    if oldGui then oldGui:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BlockSpin_Ultimate_GUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 260, 0, 420)
    mainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 35)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextSize = 16
    titleLabel.Text = "BlockSpin Ultimate GUI"
    titleLabel.Parent = mainFrame

    local yOffset = 40
    local function createToggle(name, settingKey)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 220, 0, 30)
        btn.Position = UDim2.new(0, 20, 0, yOffset)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Parent = mainFrame
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = btn

        local function updateBtn()
            if Settings[settingKey] then
                btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                btn.Text = name .. ": ON"
            else
                btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
                btn.Text = name .. ": OFF"
            end
        end
        btn.MouseButton1Click:Connect(function()
            Settings[settingKey] = not Settings[settingKey]
            updateBtn()
        end)
        updateBtn()
        yOffset = yOffset + 33
    end

    -- إنشاء الأزرار حسب الطلب
    createToggle("ESP System", "ESP")
    createToggle("Janitor Farm", "Janitor_Farm_Active")
    createToggle("Cook Farm", "Cook_Farm_Active")
    createToggle("ATM Hack Farm", "ATM_Hack_Active")
    createToggle("Fishing Farm", "FishingFarm_Active")
    createToggle("Item Bot (20m)", "ItemBot_Active")
    createToggle("Vehicle Speed", "Vehicle_Farm_Active")
    createToggle("Safe House System", "SafeHouse_Active")
    
    -- زر FOV
    local fovBtn = Instance.new("TextButton")
    fovBtn.Size = UDim2.new(0, 220, 0, 30)
    fovBtn.Position = UDim2.new(0, 20, 0, yOffset)
    fovBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    fovBtn.Font = Enum.Font.GothamBold
    fovBtn.TextSize = 13
    fovBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    fovBtn.Text = "Apply FOV Boost (+15)"
    fovBtn.Parent = mainFrame
    local fovCorner = Instance.new("UICorner")
    fovCorner.CornerRadius = UDim.new(0, 5)
    fovCorner.Parent = fovBtn
    fovBtn.MouseButton1Click:Connect(ApplyFOV)
end

-- ==========================================
-- تشغيل السكربت
-- ==========================================
CreateGUI()
ApplyFOV()
print("BlockSpin Ultimate GUI Loaded Successfully!")
