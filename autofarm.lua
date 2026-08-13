-- ==========================================
-- BlockSpin ULTIMATE SCRIPT (Fishing & ATM AI Update)
-- ==========================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager") -- للنقر التلقائي الدقيق

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera

-- ==========================================
-- الإعدادات
-- ==========================================
local Settings = {
    MasterSwitch = true,
    
    AutoFish = true,            -- أوتو صيد ذكي (يشتري طعم، يرمي، يضغط الأخضر)
    AutoATM = true,             -- أوتو اختراق صرافيات (يضغط الأخضر)
    AutoJobs = true,            -- أوتو وظائف (تنظيف/طبخ)
    AutoCollectCash = true,     -- سحب الأموال
    AutoCollectLoot = true,     -- سحب المسروقات
    
    ESP = true,
    FOV_Offset = 15,
}

-- ==========================================
-- نظام ESP و FOV
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
                gui.Name = "BS_ESP"; gui.Adornee = head; gui.Size = UDim2.new(0, 100, 0, 50)
                gui.StudsOffset = Vector3.new(0, 2.5, 0); gui.AlwaysOnTop = true; gui.Parent = head
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, 0, 1, 0); frame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                frame.BackgroundTransparency = 0.5; frame.Parent = gui
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(1, 0, 1, 0); nameLabel.BackgroundTransparency = 1
                nameLabel.Text = otherPlayer.Name; nameLabel.TextColor3 = Color3.new(1, 1, 1)
                nameLabel.Font = Enum.Font.GothamBold; nameLabel.TextScaled = true; nameLabel.Parent = frame
                espObjects[gui] = gui
            end
        end
    end
end

local function ApplyFOV()
    local targetFOV = 90 + Settings.FOV_Offset
    if targetFOV > 120 then targetFOV = 120 end
    TweenService:Create(camera, TweenInfo.new(1), {FieldOfView = targetFOV}):Play()
end

-- ==========================================
-- دوال مساعدة
-- ==========================================
local function getCharacter()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        return char
    end
    return nil
end

-- دالة للنقر الفوري على الشاشة (للضرب في الصيد والـ ATM)
local function clickScreen()
    VirtualInputManager:SendMouseButtonEvent(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2, 0, true, game, 1)
    task.wait(0.01)
    VirtualInputManager:SendMouseButtonEvent(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2, 0, false, game, 1)
end

-- ==========================================
-- 🎣 نظام الصيد الذكي (Auto Bait + Mini-game Bot)
-- ==========================================
local isFishing = false

local function startAutoFishing()
    task.spawn(function()
        while task.wait(0.5) do
            if Settings.MasterSwitch and Settings.AutoFish and not isFishing then
                local char = getCharacter()
                if char then
                    local tool = char:FindFirstChildWhichIsA("Tool")
                    -- التأكد من أن اللاعب يمسك سنارة صيد
                    if tool and (tool.Name:lower():match("rod") or tool.Name:lower():match("fishing")) then
                        isFishing = true
                        
                        -- 1. فحص الطعم: إذا لم يكن لديك طعم، نحاول إستخدام الطعم من الحقيبة
                        local hasBait = player.Backpack:FindFirstChild("Wormtec") or player.Backpack:FindFirstChild("Prawntec") or char:FindFirstChild("Wormtec")
                        if not hasBait then
                            -- في حال كان السكربت يحتاج لشراء طعم (يمكنك تفعيل زر الشراء من المتجر يدوياً)
                            -- سنفترق أن اللاعب وضع الطعم في الحقيبة
                            print("No Bait detected. Please buy Wormtec from Jack's Hardware.")
                        end

                        -- 2. الرمي في البحيرة: تفعيل الأداة
                        tool:Activate()
                        task.wait(2) -- الانتظار حتى يرمي الصنارة وتظهر واجهة اللعبة
                        
                        -- 3. البحث عن واجهة الصيد (Mini-game)
                        local fished = false
                        local timeout = 0
                        while task.wait(0.1) do
                            timeout = timeout + 0.1
                            if timeout > 15 then break end -- خروج إذا لم يعلق سمك خلال 15 ثانية
                            
                            -- البحث عن الـ GUI الذي يحتوي على النص الأخضر (Needle / Green target)
                            local needleGui = nil
                            for _, gui in pairs(playerGui:GetChildren()) do
                                if gui:IsA("ScreenGui") then
                                    for _, frame in pairs(gui:GetDescendants()) do
                                        if frame:IsA("Frame") and frame.BackgroundColor3 == Color3.fromRGB(0, 255, 0) then
                                            needleGui = frame
                                            break
                                        end
                                    end
                                end
                            end
                            
                            -- 4. إذا وجد الخط الأخضر، نحسب موقعه وننقر
                            if needleGui then
                                -- ننتظر حتى يصبح حجم الخط الأخضر صغيراً (مما يعني أن المؤشر بداخله)
                                if needleGui.AbsoluteSize.X <= 30 or needleGui.AbsoluteSize.Y <= 30 then
                                    clickScreen()
                                    fished = true
                                    break
                                end
                            end
                        end
                        
                        -- إعادة السنارة
                        if fished then
                            task.wait(1)
                            tool:Deactivate()
                            task.wait(0.5)
                        else
                            tool:Deactivate()
                        end
                        
                        isFishing = false
                    end
                end
            end
        end
    end)
end

-- ==========================================
-- 💰 أوتو اختراق الصرافيات (ATM Bot)
-- ==========================================
local isHacking = false
local function startAutoATM()
    task.spawn(function()
        while task.wait(0.5) do
            if Settings.MasterSwitch and Settings.AutoATM and not isHacking then
                local char = getCharacter()
                if char then
                    local tool = char:FindFirstChildWhichIsA("Tool")
                    if tool and (tool.Name:lower():match("hack") or tool.Name:lower():match("laptop")) then
                        isHacking = true
                        
                        -- البحث عن أقرب صراف
                        local closestATM = nil
                        local shortestDist = 20
                        for _, obj in ipairs(Workspace:GetDescendants()) do
                            if obj:IsA("Model") or obj:IsA("BasePart") then
                                if obj.Name:lower():match("atm") then
                                    local part = obj:IsA("Model") and obj.PrimaryPart or obj
                                    if part then
                                        local dist = (char.HumanoidRootPart.Position - part.Position).Magnitude
                                        if dist < shortestDist then
                                            shortestDist = dist
                                            closestATM = part
                                        end
                                    end
                                end
                            end
                        end
                        
                        if closestATM then
                            char.Humanoid:MoveTo(closestATM.Position)
                            task.wait(1)
                            tool:Activate() -- بدء الاختراق
                            
                            -- لوب الضغط على الأخضر مشابه للصيد
                            local hacked = false
                            local timeout = 0
                            while task.wait(0.1) do
                                timeout = timeout + 0.1
                                if timeout > 20 then break end
                                
                                local greenBar = nil
                                for _, gui in pairs(playerGui:GetChildren()) do
                                    if gui:IsA("ScreenGui") then
                                        for _, frame in pairs(gui:GetDescendants()) do
                                            if frame:IsA("Frame") and frame.BackgroundColor3 == Color3.fromRGB(0, 255, 0) then
                                                greenBar = frame
                                                break
                                            end
                                        end
                                    end
                                end
                                
                                if greenBar then
                                    clickScreen()
                                    hacked = true
                                    task.wait(0.5)
                                end
                            end
                            
                            task.wait(2)
                            tool:Deactivate()
                            task.wait(5) -- انتظار قصير قبل المحاولة التالية
                        end
                        isHacking = false
                    end
                end
            end
        end
    end)
end

-- ==========================================
-- 👷 أوتو وظائف (Janitor + Cook)
-- ==========================================
task.spawn(function()
    while task.wait(0.2) do
        if Settings.MasterSwitch and Settings.AutoJobs then
            local char = getCharacter()
            if char then
                local tool = char:FindFirstChildWhichIsA("Tool")
                if tool then
                    local toolName = tool.Name:lower()
                    if toolName:match("mop") or toolName:match("broom") or toolName:match("skillet") or toolName:match("pan") then
                        tool:Activate()
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- 📦 سحب الأموال والمسروقات (Auto Collect)
-- ==========================================
task.spawn(function()
    while task.wait(0.1) do
        if Settings.MasterSwitch and (Settings.AutoCollectCash or Settings.AutoCollectLoot) then
            local char = getCharacter()
            if char then
                local rootPart = char.HumanoidRootPart
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        local name = obj.Name:lower()
                        if (Settings.AutoCollectCash and (name:match("cash") or name:match("money"))) or
                           (Settings.AutoCollectLoot and (name:match("loot") or name:match("item"))) then
                            if obj.Size.X < 5 then -- تأكد أنها أداة وليست جزء من ماب
                                obj.CFrame = rootPart.CFrame
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- لوب الـ ESP
task.spawn(function()
    while task.wait(1) do
        if Settings.ESP then updateESP() end
    end
end)

-- ==========================================
-- 🖥️ واجهة التحكم GUI
-- ==========================================
local function CreateGUI()
    local oldGui = playerGui:FindFirstChild("BlockSpin_Pro_GUI")
    if oldGui then oldGui:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BlockSpin_Pro_GUI"; screenGui.ResetOnSpawn = false; screenGui.Parent = playerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 260, 0, 250); mainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20); mainFrame.BorderSizePixel = 0
    mainFrame.Active = true; mainFrame.Draggable = true; mainFrame.Parent = screenGui
    
    local uiCorner = Instance.new("UICorner"); uiCorner.CornerRadius = UDim.new(0, 8); uiCorner.Parent = mainFrame
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 35); titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(0, 255, 150); titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextSize = 16; titleLabel.Text = "BlockSpin AI Script"; titleLabel.Parent = mainFrame

    local yOffset = 40
    local function createToggle(name, settingKey)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 220, 0, 30); btn.Position = UDim2.new(0, 20, 0, yOffset)
        btn.Font = Enum.Font.GothamBold; btn.TextSize = 13; btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Parent = mainFrame
        local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 5); corner.Parent = btn
        local function updateBtn()
            if Settings[settingKey] then btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0); btn.Text = name .. ": ON"
            else btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0); btn.Text = name .. ": OFF" end
        end
        btn.MouseButton1Click:Connect(function() Settings[settingKey] = not Settings[settingKey]; updateBtn() end)
        updateBtn(); yOffset = yOffset + 33
    end

    createToggle("AI Auto Fish (Mini-game)", "AutoFish")
    createToggle("AI Auto ATM Hack", "AutoATM")
    createToggle("Auto Jobs (Janitor/Cook)", "AutoJobs")
    createToggle("Auto Collect Cash/Loot", "AutoCollectCash")
    createToggle("Player ESP", "ESP")
    
    local fovBtn = Instance.new("TextButton")
    fovBtn.Size = UDim2.new(0, 220, 0, 30); fovBtn.Position = UDim2.new(0, 20, 0, yOffset)
    fovBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60); fovBtn.Font = Enum.Font.GothamBold
    fovBtn.TextSize = 13; fovBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    fovBtn.Text = "Apply FOV Boost"; fovBtn.Parent = mainFrame
    local fovCorner = Instance.new("UICorner"); fovCorner.CornerRadius = UDim.new(0, 5); fovCorner.Parent = fovBtn
    fovBtn.MouseButton1Click:Connect(ApplyFOV)
end

-- تشغيل السكربت
CreateGUI()
ApplyFOV()
startAutoFishing()
startAutoATM()

print("BlockSpin AI Script Loaded! (With Fishing & ATM Mini-game Solver)")
