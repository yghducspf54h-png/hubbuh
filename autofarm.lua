-- ==========================================
-- BlockSpin AI FISHING BOT (Godlike Precision)
-- دقة خارقة + رمي بعيد + أداة طعم تلقائية
-- ==========================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera

local Settings = {
    AutoFish = true,
}

local isFishing = false

-- ==========================================
-- 1. دالة النقر الخارقة (أسرع من العين)
-- ==========================================
local mouse = player:GetMouse()

local function instantClick()
    -- إرسال أمر النقر للواجهة بشكل فوري جداً بدون تأخير الإطارات
    if mouse1press then
        mouse1press()
        task.wait()
        mouse1release()
    else
        -- طريقة احتياطية للمنفذات التي لا تدعم mouse1press
        mouse1click()
    end
end

-- ==========================================
-- 2. دالة للتحقق من اللون الأخضر (مهما كانت درجته)
-- ==========================================
local function isGreenColor(color)
    -- الأخضر النقي يكون R=0, G=255, B=0. 
    -- في BlockSpin الأخضر قد يكون فاتحاً (G=200 وأكثر، وR و B أقل من 100)
    if color.G > 0.5 and color.R < 0.5 and color.B < 0.5 then
        return true
    end
    return false
end

-- ==========================================
-- دالة مساعدة لجلب الشخصية
-- ==========================================
local function getCharacter()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        return char
    end
    return nil
end

-- ==========================================
-- 🎣 نظام الصيد الذكي (Godlike AI)
-- ==========================================
local function startAutoFishingLoop()
    task.spawn(function()
        while task.wait(0.5) do
            if Settings.AutoFish and not isFishing then
                local char = getCharacter()
                if char then
                    local tool = char:FindFirstChildWhichIsA("Tool")
                    
                    if tool and (tool.Name:lower():match("rod") or tool.Name:lower():match("fishing")) then
                        isFishing = true
                        
                        -- 1. فحص الطعم (Bait) وتجهيزه
                        local hasBait = char:FindFirstChild("Wormtec") or char:FindFirstChild("Prawntec") or char:FindFirstChild("Bait")
                        if not hasBait then
                            local bait = player.Backpack:FindFirstChild("Wormtec") or player.Backpack:FindFirstChild("Prawntec") or player.Backpack:FindFirstChild("Bait")
                            if bait then
                                bait.Parent = char
                                task.wait(0.5)
                            end
                        end

                        -- 2. الرمي البعيد في البحيرة
                        -- رمي الصنارة
                        tool:Activate()
                        -- الانتظار 3 ثوانٍ لضمان وصول الطعم لأبعد نقطة في الماء
                        task.wait(1)
                        
                        -- 3. البحث عن واجهة الصيد (الخط الأخضر) والنقر الفوري
                        local fished = false
                        local timeout = 0
                        
                        while task.wait(0.03) do -- لوب سريع جداً لرصد الخط
                            timeout = timeout + 0.03
                            if timeout > 15 then break end -- خروج إذا لم يعلق سمك خلال 15 ثانية
                            
                            local greenBar = nil
                            
                            -- البحث في واجهة المستخدم
                            for _, gui in pairs(playerGui:GetChildren()) do
                                if gui:IsA("ScreenGui") and gui.Enabled then
                                    for _, element in pairs(gui:GetDescendants()) do
                                        -- البحث عن إطار أو شريط أخضر مرئي
                                        if element:IsA("GuiObject") and element.Visible then
                                            if isGreenColor(element.BackgroundColor3) and element.AbsoluteSize.X > 0 and element.AbsoluteSize.Y > 0 then
                                                -- تأكد أنه ليس شيئاً كبيراً جداً (مثل خلفية الشاشة)
                                                if element.AbsoluteSize.X < 300 and element.AbsoluteSize.Y < 300 then
                                                    greenBar = element
                                                    break
                                                end
                                            end
                                        end
                                    end
                                end
                                if greenBar then break end
                            end
                            
                            -- 4. إذا وجد الخط الأخضر، ننقر فوراً
                            if greenBar then
                                -- تحريك الماوس الوهمي فوق الخط الأخضر مباشرة
                                local greenX = greenBar.AbsolutePosition.X + (greenBar.AbsoluteSize.X / 2)
                                local greenY = greenBar.AbsolutePosition.Y + (greenBar.AbsoluteSize.Y / 2)
                                
                                -- تحديث موقع الماوس
                                mouse.X = greenX
                                mouse.Y = greenY
                                if mousemove then 
                                    mousemove(greenX, greenY) 
                                end
                                
                                -- النقر الخارق السرعة
                                instantClick()
                                fished = true
                                task.wait(1) -- انتظار سحب السمكة
                                break
                            end
                        end
                        
                        -- 5. إعادة السنارة للخلف (Deactivate)
                        tool:Deactivate()
                        task.wait(0.5)
                        
                        isFishing = false
                    end
                end
            end
        end
    end)
end

-- ==========================================
-- 🖥️ واجهة التحكم GUI (احترافية + تكبير وتصغير)
-- ==========================================
local function CreateGUI()
    local oldGui = playerGui:FindFirstChild("BlockSpin_GodFish_AI")
    if oldGui then oldGui:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BlockSpin_GodFish_AI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 250, 0, 120)
    mainFrame.Position = UDim2.new(0.1, 0, 0.4, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = mainFrame

    -- شريط العنوان
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 30)
    topBar.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame
    
    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 8)
    topCorner.Parent = topBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.6, 0, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.Text = "🎣 Godlike AI Fishing"
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar

    -- زر التصغير
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -60, 0, 0)
    minBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
    minBtn.Text = "-"
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 18
    minBtn.TextColor3 = Color3.new(0, 0, 0)
    minBtn.Parent = topBar

    -- زر التكبير
    local maxBtn = Instance.new("TextButton")
    maxBtn.Size = UDim2.new(0, 30, 0, 30)
    maxBtn.Position = UDim2.new(1, -30, 0, 0)
    maxBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    maxBtn.Text = "+"
    maxBtn.Font = Enum.Font.GothamBold
    maxBtn.TextSize = 18
    maxBtn.TextColor3 = Color3.new(0, 0, 0)
    maxBtn.Parent = topBar

    -- زر التشغيل/الإيقاف
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 210, 0, 40)
    toggleBtn.Position = UDim2.new(0, 20, 0, 45)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 14
    toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleBtn.Parent = mainFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = toggleBtn

    -- نص الحالة
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0, 210, 0, 20)
    statusLabel.Position = UDim2.new(0, 20, 0, 90)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12
    statusLabel.Text = "Status: Idle"
    statusLabel.Parent = mainFrame

    -- منطق الأزرار
    local function updateToggleBtn()
        if Settings.AutoFish then
            toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            toggleBtn.Text = "Auto Fish: ON"
            statusLabel.Text = "Status: Fishing in progress..."
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            toggleBtn.Text = "Auto Fish: OFF"
            statusLabel.Text = "Status: Idle"
        end
    end

    toggleBtn.MouseButton1Click:Connect(function()
        Settings.AutoFish = not Settings.AutoFish
        updateToggleBtn()
    end)

    local isMaximized = false
    maxBtn.MouseButton1Click:Connect(function()
        if isMaximized then
            TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 250, 0, 120)}):Play()
            isMaximized = false
        else
            TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 400, 0, 250)}):Play()
            isMaximized = true
        end
    end)

    local isMinimized = false
    minBtn.MouseButton1Click:Connect(function()
        if isMinimized then
            TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 250, 0, 120)}):Play()
            toggleBtn.Visible = true
            statusLabel.Visible = true
            isMinimized = false
        else
            TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 250, 0, 30)}):Play()
            toggleBtn.Visible = false
            statusLabel.Visible = false
            isMinimized = true
        end
    end)

    updateToggleBtn()
end

-- تشغيل السكربت
CreateGUI()
startAutoFishingLoop()

print("BlockSpin Godlike AI Fishing Script Loaded Successfully!")
