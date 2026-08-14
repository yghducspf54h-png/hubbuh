-- ==========================================
-- سكربت الصيد الذكي لـ BlockSpin (الإصدار الأسود المحاصر بـ #191A1C)
-- ==========================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera

local Settings = {
    AutoFish = true,
}

local isFishing = false

-- ==========================================
-- 1. دوال النقر الخفية (بدون تحكم في الماوس)
-- ==========================================
local function silentClick(x, y)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
    task.wait(0.01)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
end

local function silentHold(duration)
    VirtualInputManager:SendMouseButtonEvent(camera.ViewportSize.X/2, camera.ViewportSize.Y/2, 0, true, game, 1)
    task.wait(duration)
    VirtualInputManager:SendMouseButtonEvent(camera.ViewportSize.X/2, camera.ViewportSize.Y/2, 0, false, game, 1)
end

-- ==========================================
-- 2. دوال فحص الألوان (الأخضر والحواف الداكنة #191A1C)
-- ==========================================
local function isGreenColor(c)
    -- فحص الأخضر بجميع درجاته (الغالب هو الأخضر)
    if c and c.G > 0.4 and c.G > (c.R * 2) and c.G > (c.B * 2) then
        return true
    end
    return false
end

local function isDarkEdgeColor(c)
    -- فحص لون الحواف #191A1C (أحمر، أخضر، أزرمنخفضة جداً)
    if c and c.R <= 0.15 and c.G <= 0.15 and c.B <= 0.15 then
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
-- 🎣 نظام الصيد الذكي (المحاصر بالأسود)
-- ==========================================
local function startAutoFishingLoop()
    task.spawn(function()
        while task.wait(0.1) do
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
                                task.wait(1)
                            end
                        end

                        -- 2. الرمي البعيد
                        local lookVector = char.HumanoidRootPart.CFrame.LookVector
                        char.HumanoidRootPart.CFrame = CFrame.lookAt(char.HumanoidRootPart.Position, char.HumanoidRootPart.Position + Vector3.new(lookVector.X, 0, lookVector.Z))
                        
                        silentHold(1.5)
                        task.wait(0.5)
                        
                        -- 3. البحث عن المستطيل الأخضر المحاصر بـ #191A1C
                        local fished = false
                        local timeout = 0
                        
                        while task.wait(0.01) do 
                            timeout = timeout + 0.01
                            if timeout > 15 then break end
                            
                            local greenBar = nil
                            
                            for _, gui in pairs(playerGui:GetChildren()) do
                                if gui:IsA("ScreenGui") and gui.Enabled then
                                    for _, element in pairs(gui:GetDescendants()) do
                                        if element:IsA("Frame") and element.Visible then
                                            local c = element.BackgroundColor3
                                            local w = element.AbsoluteSize.X
                                            local h = element.AbsoluteSize.Y
                                            
                                            -- الشرط الأول: اللون أخضر
                                            if isGreenColor(c) then
                                                -- الشرط الثاني: الأبعاد صغيرة (مستطيل الصيد)
                                                if w > 5 and w < 80 and h > 5 and h < 80 then
                                                    -- الشرط الثالث (المحاصرة): يجب أن يكون له إخوة (Siblings) لونهم الحافة الداكنة
                                                    local hasDarkEdge = false
                                                    local parent = element.Parent
                                                    if parent then
                                                        for _, sibling in pairs(parent:GetChildren()) do
                                                            if sibling ~= element and sibling:IsA("Frame") and isDarkEdgeColor(sibling.BackgroundColor3) then
                                                                -- نتأكد أن الحافة طويلة (شريط الصيد)
                                                                if sibling.AbsoluteSize.X > 100 or sibling.AbsoluteSize.Y > 100 then
                                                                    hasDarkEdge = true
                                                                    break
                                                                end
                                                            end
                                                        end
                                                    end
                                                    
                                                    -- إذا تحققت كل الشروط، هو الخط المطلوب!
                                                    if hasDarkEdge then
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
                            
                            -- 4. النقر على الأخضر
                            if greenBar then
                                local greenX = greenBar.AbsolutePosition.X + (greenBar.AbsoluteSize.X / 2)
                                local greenY = greenBar.AbsolutePosition.Y + (greenBar.AbsoluteSize.Y / 2)
                                
                                silentClick(greenX, greenY)
                                fished = true
                                break
                            end
                        end
                        
                        -- 5. إعادة السنارة
                        tool:Deactivate()
                        task.wait(0.2)
                        
                        isFishing = false
                    end
                end
            end
        end
    end)
end

-- ==========================================
-- 🖥️ واجهة التحكم الأسود (بدون أي أخضر)
-- ==========================================
local function CreateGUI()
    local oldGui = playerGui:FindFirstChild("BlockSpin_BlackFish")
    if oldGui then oldGui:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BlockSpin_BlackFish"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 120)
    mainFrame.Position = UDim2.new(0.1, 0, 0.4, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- أسود بالكامل
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255) -- حواف بيضاء
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = mainFrame

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 30)
    topBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame
    
    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 8)
    topCorner.Parent = topBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.6, 0, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- نص أبيض
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.Text = "🎣 صيد تلقائي أسود"
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar

    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -60, 0, 0)
    minBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    minBtn.Text = "-"
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 18
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.Parent = topBar

    local maxBtn = Instance.new("TextButton")
    maxBtn.Size = UDim2.new(0, 30, 0, 30)
    maxBtn.Position = UDim2.new(1, -30, 0, 0)
    maxBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    maxBtn.Text = "+"
    maxBtn.Font = Enum.Font.GothamBold
    maxBtn.TextSize = 18
    maxBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    maxBtn.Parent = topBar

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 240, 0, 40)
    toggleBtn.Position = UDim2.new(0, 20, 0, 45)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 14
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Parent = mainFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = toggleBtn

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0, 240, 0, 20)
    statusLabel.Position = UDim2.new(0, 20, 0, 90)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12
    statusLabel.Text = "الحالة: متوقف"
    statusLabel.Parent = mainFrame

    -- منطق الأزرار (أحمر وأبيض فقط)
    local function updateToggleBtn()
        if Settings.AutoFish then
            toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- أبيض
            toggleBtn.TextColor3 = Color3.fromRGB(0, 0, 0) -- نص أسود
            toggleBtn.Text = "الصيد التلقائي: يعمل"
            statusLabel.Text = "الحالة: جاري الصيد..."
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- أسود
            toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255) -- نص أبيض
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

print("تم تحميل سكربت الصيد الأسود المحاصر لـ BlockSpin بنجاح!")
