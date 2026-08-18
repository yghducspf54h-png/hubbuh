-- إعداد Alanazi 💪
-- 1أوتو فارم لتكديس الصناديق مع واجهة تحكم وحفظ المواقع

-- المتغيرات الأساسية
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local inv = game:GetService("ReplicatedStorage"):WaitForChild("Inventory")
local getSlots = inv:WaitForChild("GetStorageSlots")
local getItems = inv:WaitForChild("GetStoredItems")

-- إعدادات المستخدم
local autoFarm = false
local savedBoxPos = nil
local blueColor = Color3.fromRGB(0, 85, 255)
local maxBoxes = 3

-- دالة للتحرك
local function moveTo(target)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid and target then
        humanoid:MoveTo(target.Position)
        humanoid.MoveToFinished:Wait()
    end
end

-- دالة للبحث عن الدائرة الزرقاء
local function getBlueCircle()
    local nearest, dist = nil, math.huge
    for _, part in pairs(workspace:GetChildren()) do
        if part:IsA("Part") and part.Color == blueColor then
            local d = (hrp.Position - part.Position).Magnitude
            if d < dist then
                dist = d
                nearest = part
            end
        end
    end
    return nearest
end

-- دالة لأخذ الصناديق
local function takeBoxes()
    for i = 1, maxBoxes do
        if not autoFarm then break end
        if savedBoxPos then
            moveTo(savedBoxPos)
        end
        local box = workspace:FindFirstChild("Box")
        if box and box:FindFirstChild("ProximityPrompt") then
            fireproximityprompt(box.ProximityPrompt)
            task.wait(0.5)
        end
    end
end

-- دالة لتكديس الصناديق
local function stackBoxes()
    local circle = getBlueCircle()
    if circle then
        moveTo(circle)
        task.wait(3)
    end
end

-- الحلقة الرئيسية
task.spawn(function()
    while task.wait(2) do
        if autoFarm then
            takeBoxes()
            stackBoxes()
        end
    end
end)

-- واجهة التحكم
local gui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(220, 180)
frame.Position = UDim2.new(0.05, 0, 0.05, 0)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.fromOffset(220, 30)
title.Text = "Auto Farm Control"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.fromOffset(200, 40)
toggleBtn.Position = UDim2.new(0, 10, 0, 40)
toggleBtn.Text = "Auto Farm: OFF"
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14

local saveBtn = Instance.new("TextButton", frame)
saveBtn.Size = UDim2.fromOffset(200, 40)
saveBtn.Position = UDim2.new(0, 10, 0, 90)
saveBtn.Text = "Save Box Position"
saveBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
saveBtn.TextColor3 = Color3.new(1,1,1)
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 14

local colorBtn = Instance.new("TextButton", frame)
colorBtn.Size = UDim2.fromOffset(200, 40)
colorBtn.Position = UDim2.new(0, 10, 0, 140)
colorBtn.Text = "Copy Blue Circle Color"
colorBtn.BackgroundColor3 = Color3.fromRGB(200, 160, 60)
colorBtn.TextColor3 = Color3.new(1,1,1)
colorBtn.Font = Enum.Font.GothamBold
colorBtn.TextSize = 14

-- وظائف الأزرار
toggleBtn.MouseButton1Click:Connect(function()
    autoFarm = not autoFarm
    toggleBtn.Text = autoFarm and "Auto Farm: ON" or "Auto Farm: OFF"
end)

saveBtn.MouseButton1Click:Connect(function()
    savedBoxPos = hrp.Position
    saveBtn.Text = "Box Position Saved!"
end)

colorBtn.MouseButton1Click:Connect(function()
    local circle = getBlueCircle()
    if circle then
        blueColor = circle.Color
        colorBtn.Text = "Color Copied!"
    else
        colorBtn.Text = "No Blue Circle Found!"
    end
end)
