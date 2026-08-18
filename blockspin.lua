-- سكربت أوتو فارم لتكديس الصناديق
-- إعداد Alanazi 💪

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- الريموتات اللي اكتشفتها من SimpleSpy (لو احتجتها لاحقًا)
local inv = game:GetService("ReplicatedStorage"):WaitForChild("Inventory")
local getSlots = inv:WaitForChild("GetStorageSlots")
local getItems = inv:WaitForChild("GetStoredItems")

-- إعدادات
local autoFarm = false
local savedBoxPos = nil
local maxBoxes = 3

-- لون الدائرة الزرقاء من كلامك: #0C6194 = (12, 97, 148)
local blueColor = Color3.fromRGB(12, 97, 148)

-- دالة للتحرك
local function moveToPosition(pos)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid and pos then
        humanoid:MoveTo(pos)
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

-- دالة لأخذ الصناديق (3 مرات)
local function takeBoxes()
    for i = 1, maxBoxes do
        if not autoFarm then break end

        if savedBoxPos then
            moveToPosition(savedBoxPos)
        end

        local box = workspace:FindFirstChild("Box")
        if box and box:FindFirstChild("ProximityPrompt") then
            fireproximityprompt(box.ProximityPrompt)
            task.wait(0.5)
        else
            break
        end
    end
end

-- دالة لتكديس الصناديق عند الدائرة الزرقاء
local function stackBoxes()
    local circle = getBlueCircle()
    if circle then
        -- يروح لنص أو فوق الدائرة شوي
        local targetPos = circle.Position + Vector3.new(0, 3, 0)
        moveToPosition(targetPos)
        task.wait(3)
    end
end

-- الحلقة الرئيسية للأوتو فارم
task.spawn(function()
    while true do
        task.wait(1)
        if autoFarm then
            takeBoxes()
            stackBoxes()
        end
    end
end)

-- واجهة التحكم
local gui = Instance.new("ScreenGui")
gui.Name = "AlanaziAutoFarmGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(220, 180)
frame.Position = UDim2.new(0.05, 0, 0.05, 0)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.fromOffset(220, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "Alanazi Auto Farm"
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
colorBtn.Text = "Blue Color: #0C6194"
colorBtn.BackgroundColor3 = blueColor
colorBtn.TextColor3 = Color3.new(1,1,1)
colorBtn.Font = Enum.Font.GothamBold
colorBtn.TextSize = 14

-- زر تشغيل/إيقاف الأوتو فارم (يشتغل صدق)
toggleBtn.MouseButton1Click:Connect(function()
    autoFarm = not autoFarm
    toggleBtn.Text = autoFarm and "Auto Farm: ON" or "Auto Farm: OFF"
    toggleBtn.BackgroundColor3 = autoFarm and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(60, 120, 200)
end)

-- زر حفظ مكان الصناديق
saveBtn.MouseButton1Click:Connect(function()
    savedBoxPos = hrp.Position
    saveBtn.Text = "Box Position Saved!"
    task.delay(2, function()
        saveBtn.Text = "Save Box Position"
    end)
end)

-- زر لون الدائرة (بس يعرض اللون اللي حددته)
colorBtn.MouseButton1Click:Connect(function()
    colorBtn.Text = "Blue Color: #0C6194"
end)
