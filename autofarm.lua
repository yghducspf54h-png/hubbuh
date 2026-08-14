-- ==========================================
-- سكربت الصيد الذكي لـ BlockSpin (الإصدار العربي النهائي)
-- ميزات: تعبئة طعم تلقائية، رمي بعيد بدون ماوس، دقة نقر 100% على الأخضر
-- ==========================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera

local Settings = {
    AutoFish = true, -- تشغيل الصيد
}

local isFishing = false

-- ==========================================
-- 1. دالة النقر المباشر على الإحداثيات
-- ==========================================
local function directClick(x, y)
    -- استخدام أوامر المنفذ المباشرة للنقر على الإحداثيات بسرعة خارقة
    if mouse1press and mouse1release then
        if mousemove then mousemove(x, y) end
        mouse1press()
        task.wait()
        mouse1release()
    elseif mouse1click then
        if mousemove then mousemove(x, y) end
        mouse1click()
    else
        -- طريقة VirtualInputManager الاحتياطية
        local VirtualInputManager = game:GetService("VirtualInputManager")
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
    end
end

-- ==========================================
-- 2. دوال فحص الألوان (للبني والأخضر)
-- ==========================================
-- دالة للتحقق من اللون البني (أطراف الشريط)
local function isBrownColor(color)
    if color and (color.R > 0.3 and color.R < 0.6) and (color.G > 0.2 and color.G < 0.5) and (color.B > 0.1 and color.B < 0.3) then
        return true
    end
    return false
end

-- دالة للتحقق من اللون الأخضر (المنتصف)
local function isGreenColor(color)
    if color and color.G > 0.5 and color.R < 0.6 and color.B < 0.6 then
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
-- 🎣 نظام الصيد الذكي
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
                        
                        -- 1. فحص وتعبئة الطعم (Bait)
                        local hasBait = char:FindFirstChild("Wormtec") or char:FindFirstChild("Prawntec") or char:FindFirstChild("Bait")
                        if not hasBait then
                            local bait = player.Backpack:FindFirstChild("Wormtec") or player.Backpack:FindFirstChild("Prawntec") or player.Backpack:FindFirstChild("Bait")
                            if bait then
                                bait.Parent = char
                                task.wait(1) -- انتظار تعبئة الطعم في السنارة
                            end
                        end

                        -- 2. الرمي البعيد بدون ماوس
                        -- تعديل زاوية الكاميرا للنظر للأمام مباشرة لضمان أقصى مسافة رمي
                        char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.Angles(0, 0, 0)
                        camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + Vector3.new(0, 0, -1))
                        
                        tool:Activate()
                        task.wait(3) -- الانتظار لوصول الطعم لأبعد نقطة
                        
                        -- 3. البحث عن واجهة الصيد (الشريط البني والأخضر)
                        local fished = false
                        local timeout = 0
                        
                        -- لوب سريع جداً لرصد الخط الأخضر
                        while task.wait(0.01) do 
                            timeout = timeout + 0.01
                            if timeout > 15 then break end -- خروج إذا لم يعلق سمك خلال 15 ثانية
                            
                            local greenBar = nil
                            local foundBrown = false
                            
                            -- البحث في جميع عناصر واجهة المستخدم
                            for _, gui in pairs(playerGui:GetChildren()) do
                                if gui:IsA("ScreenGui") and gui.Enabled then
                                    for _, element in pairs(gui:GetDescendants()) do
                                        -- البحث عن الأطراف البنية أولاً لنتأكد أنه الشريط المطلوب
                                        if element:IsA("Frame") and element.Visible and isBrownColor(element.BackgroundColor3) then
                                            -- نتأكد أنه شريط أفقي (عرضه أكبر من طوله)
                                            if element.AbsoluteSize.X > 100 and element.AbsoluteSize.Y < 50 then
                                                foundBrown = true
                                            end
                                        end
                                        
                                        -- البحث عن الجزء الأخضر
                                        if element:IsA("GuiObject") and element.Visible then
                                            if element.AbsoluteSize.X > 2 and element.AbsoluteSize.X < 300 and element.AbsoluteSize.Y > 2 and element.AbsoluteSize.Y < 300 then
                                                if isGreenColor(element.BackgroundColor3) or isGreenColor(element.ImageColor3) then
                                                    -- إذا وجدنا الأخضر وكان الشريط البني موجوداً معه
                                                    if foundBrown then
                                                        greenBar = element
                                                        break
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                                if greenBar then break end
                            end
                            
                            -- 4. إذا وجد الخط الأخضر، ننقر فوراً على منتصفه
                            if greenBar then
                                local greenX = greenBar.AbsolutePosition.X + (greenBar.AbsoluteSize.X / 2)
                                local greenY = greenBar.AbsolutePosition.Y + (greenBar.AbsoluteSize.Y / 2)
                                
                                -- النقر المباشر على الإحداثيات
                                directClick(greenX, greenY)
                                
                                fished = true
                                task.wait(1) -- انتظار سحب السمكة
                                break
                            end
                        end
                        
                        -- 5. إعادة السنارة للخلف
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
-- 🖥️ واجهة التحكم (عربي)
-- ==========================================
local function CreateGUI()
    local oldGui = playerGui:FindFirstChild("BlockSpin_Arabic_Fish")
    if oldGui then oldGui:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BlockSpin_Arabic_Fish"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 120)
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
    titleLabel.Text = "🎣 صيد تلقائي ذكي"
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
    toggleBtn.Size = UDim2.new(0, 240, 0, 40)
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
    statusLabel.Size = UDim2.new(0, 240, 0, 20)
    statusLabel.Position = UDim2.new(0, 20, 0, 90)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12
    statusLabel.Text = "الحالة: متوقف"
    statusLabel.Parent = mainFrame

    -- منطق الأزرار
    local function updateToggleBtn()
        if Settings.AutoFish then
            toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            toggleBtn.Text = "الصيد التلقائي: يعمل"
            statusLabel.Text = "الحالة: جاري الصيد..."
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            toggleBtn.Text = "الصيد التلقائي: متوقف"
            statusLabel.Text = "الحالة: متوقف"
        end
    end

    toggleBtn.MouseButton1Click:Connect(function()
        Settings.AutoFish = not Settings.AutoFish
        updateToggleBtn()
    end)

    local isMaximized = false
    maxBtn.MouseButton1Click:Connect(function()
        if isMaximized then
            TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 280, 0, 120)}):Play()
            isMaximized = false
        else
            TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 400, 0, 250)}):Play()
            isMaximized = true
        end
    end)

    local isMinimized = false
    minBtn.MouseButton1Click:Connect(function()
        if isMinimized then
            TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 280, 0, 120)}):Play()
            toggleBtn.Visible = true
            statusLabel.Visible = true
            isMinimized = false
        else
            TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 280, 0, 30)}):Play()
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

print("تم تحميل سكربت الصيد الذكي لـ BlockSpin بنجاح!")
