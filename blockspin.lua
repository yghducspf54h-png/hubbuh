-- إعداد Alanazi 💪2
-- أوتو فارم كامل بدون مشي (Teleport)

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

local autoFarm = false
local savedBoxPos = nil
local maxBoxes = 3

-- اللون اللي عطيتني: #0C6194 = (12, 97, 148)
local blueColor = Color3.fromRGB(12, 97, 148)

-- Teleport سريع
local function tp(pos)
    if pos then
        hrp.CFrame = CFrame.new(pos)
    end
end

-- إيجاد الدائرة الزرقاء
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

-- أخذ 3 صناديق
local function takeBoxes()
    for i = 1, maxBoxes do
        if not autoFarm then break end

        if savedBoxPos then
            tp(savedBoxPos + Vector3.new(0, 3, 0))
        end

        local box = workspace:FindFirstChild("Box")
        if box and box:FindFirstChild("ProximityPrompt") then
            fireproximityprompt(box.ProximityPrompt)
            task.wait(0.4)
        else
            break
        end
    end
end

-- تكديس الصناديق
local function stackBoxes()
    local circle = getBlueCircle()
    if circle then
        tp(circle.Position + Vector3.new(0, 4, 0)) -- فوق الدائرة
        task.wait(3)
    end
end

-- الحلقة الرئيسية
task.spawn(function()
    while task.wait(1) do
        if autoFarm then
            takeBoxes()
            stackBoxes()
        end
    end
end)

-- واجهة التحكم
local gui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(240, 200)
frame.Position = UDim2.new(0.05, 0, 0.05, 0)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.fromOffset(240, 30)
title.Text = "Alanazi Auto Farm"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.fromOffset(220, 40)
toggleBtn.Position = UDim2.new(0, 10, 0, 40)
toggleBtn.Text = "Auto Farm: OFF"
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14

local saveBtn = Instance.new("TextButton", frame)
saveBtn.Size = UDim2.fromOffset(220, 40)
saveBtn.Position = UDim2.new(0, 10, 0, 90)
saveBtn.Text = "Save Box Position"
saveBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
saveBtn.TextColor3 = Color3.new(1,1,1)
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 14

local colorBtn = Instance.new("TextButton", frame)
colorBtn.Size = UDim2.fromOffset(220, 40)
colorBtn.Position = UDim2.new(0, 10, 0, 140)
colorBtn.Text = "Blue Color: #0C6194"
colorBtn.BackgroundColor3 = blueColor
colorBtn.TextColor3 = Color3.new(1,1,1)
colorBtn.Font = Enum.Font.GothamBold
colorBtn.TextSize = 14

-- تشغيل الأوتو فارم صدق
toggleBtn.MouseButton1Click:Connect(function()
    autoFarm = not autoFarm
    toggleBtn.Text = autoFarm and "Auto Farm: ON" or "Auto Farm: OFF"
    toggleBtn.BackgroundColor3 = autoFarm and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(60, 120, 200)
end)

-- حفظ مكان الصناديق
saveBtn.MouseButton1Click:Connect(function()
    savedBoxPos = hrp.Position
    saveBtn.Text = "Saved!"
    task.delay(2, function()
        saveBtn.Text = "Save Box Position"
    end)
end)

-- زر اللون (عرض فقط)
colorBtn.MouseButton1Click:Connect(function()
    colorBtn.Text = "Blue Color: #0C6194"
end)
