--====================================================
-- Custom GUI • Auto Farm Interface
-- By almbjl (المبجّل)
--====================================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "AutoFarmGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--====================================================
-- نافذة رئيسية
--====================================================
local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(760, 540)
main.Position = UDim2.new(0.5, -380, 0.5, -270)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = main

--====================================================
-- الهيدر
--====================================================
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
header.BorderSizePixel = 0
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -150, 1, 0)
title.Position = UDim2.fromOffset(15, 0)
title.BackgroundTransparency = 1
title.Text = "Auto Farm • Fake Diamond Ring | المبجّل"
title.TextColor3 = Color3.fromRGB(240, 240, 245)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

--====================================================
-- أزرار التحكم (تصغير، تكبير، إغلاق)
--====================================================
local function makeButton(parent, text, color, xOffset)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(35, 35)
    btn.Position = UDim2.new(1, xOffset, 0, 7)
    btn.Text = text
    btn.TextSize = 18
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Parent = parent
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,7)
    c.Parent = btn
    return btn
end

local minimize = makeButton(header, "—", Color3.fromRGB(45,45,52), -115)
local maximize = makeButton(header, "□", Color3.fromRGB(45,45,52), -75)
local close = makeButton(header, "×", Color3.fromRGB(150,45,55), -35)

--====================================================
-- نافذة تأكيد الإغلاق
--====================================================
local confirmFrame = Instance.new("Frame")
confirmFrame.Size = UDim2.fromOffset(300, 160)
confirmFrame.Position = UDim2.new(0.5, -150, 0.5, -80)
confirmFrame.BackgroundColor3 = Color3.fromRGB(25,25,30)
confirmFrame.Visible = false
confirmFrame.Parent = gui

local confirmCorner = Instance.new("UICorner")
confirmCorner.CornerRadius = UDim.new(0,10)
confirmCorner.Parent = confirmFrame

local confirmText = Instance.new("TextLabel")
confirmText.Size = UDim2.new(1, 0, 0, 60)
confirmText.Position = UDim2.fromOffset(0, 20)
confirmText.BackgroundTransparency = 1
confirmText.Text = "هل أنت متأكد أنك تريد الإغلاق؟"
confirmText.TextColor3 = Color3.fromRGB(230,230,235)
confirmText.Font = Enum.Font.GothamBold
confirmText.TextSize = 14
confirmText.Parent = confirmFrame

local yesBtn = makeButton(confirmFrame, "نعم", Color3.fromRGB(55,150,90), -180)
yesBtn.Position = UDim2.fromOffset(40, 90)
local noBtn = makeButton(confirmFrame, "لا", Color3.fromRGB(150,45,55), -80)
noBtn.Position = UDim2.fromOffset(180, 90)

yesBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

noBtn.MouseButton1Click:Connect(function()
    confirmFrame.Visible = false
end)

close.MouseButton1Click:Connect(function()
    confirmFrame.Visible = true
end)

--====================================================
-- محتوى داخلي منثقِب (نوافذ داخلية)
--====================================================
local content = Instance.new("Frame")
content.Position = UDim2.fromOffset(10, 58)
content.Size = UDim2.new(1, -20, 1, -68)
content.BackgroundColor3 = Color3.fromRGB(25,25,30)
content.BorderSizePixel = 0
content.Parent = main

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0,8)
contentCorner.Parent = content

-- نافذة داخلية منثقبة
local inner = Instance.new("Frame")
inner.Size = UDim2.new(1, -20, 1, -20)
inner.Position = UDim2.fromOffset(10, 10)
inner.BackgroundColor3 = Color3.fromRGB(30,30,36)
inner.BorderSizePixel = 0
inner.Parent = content

local innerCorner = Instance.new("UICorner")
innerCorner.CornerRadius = UDim.new(0,10)
innerCorner.Parent = inner

local innerLabel = Instance.new("TextLabel")
innerLabel.Size = UDim2.new(1, -20, 0, 40)
innerLabel.Position = UDim2.fromOffset(10, 10)
innerLabel.BackgroundTransparency = 1
innerLabel.Text = "واجهة المبجّل الاحترافية"
innerLabel.TextColor3 = Color3.fromRGB(200,200,210)
innerLabel.Font = Enum.Font.GothamBold
innerLabel.TextSize = 14
innerLabel.Parent = inner

--====================================================
-- حقوق واسم المستخدم
--====================================================
local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, 0, 0, 30)
footer.Position = UDim2.new(0, 0, 1, -30)
footer.BackgroundTransparency = 1
footer.Text = "Discord: almbjl  •  © المبجّل"
footer.TextColor3 = Color3.fromRGB(150,150,160)
footer.Font = Enum.Font.Gotham
footer.TextSize = 12
footer.Parent = main

--====================================================
-- وظائف التصغير والتكبير
--====================================================
local minimized = false
local maximized = false

minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    content.Visible = not minimized
    if minimized then
        main.Size = UDim2.fromOffset(main.Size.X.Offset, 48)
    else
        main.Size = UDim2.fromOffset(760, 540)
    end
end)

maximize.MouseButton1Click:Connect(function()
    maximized = not maximized
    if maximized then
        main.Size = UDim2.fromOffset(960, 640)
        main.Position = UDim2.new(0.5, -480, 0.5, -320)
    else
        main.Size = UDim2.fromOffset(760, 540)
        main.Position = UDim2.new(0.5, -380, 0.5, -270)
    end
end)
