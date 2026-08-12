-- // ========================================== \\ --
-- //          تم الصنع بواسطة: المبجّل            \\ --
-- // ========================================== \\ --

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- منع تكرار الواجهة إذا كانت مفتوحة مسبقاً
if PlayerGui:FindFirstChild("AlMubajjalUI") then
    PlayerGui.AlMubajjalUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AlMubajjalUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- النافذة الرئيسية
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 300)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- شريط العنوان العلوي
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -20, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "لوحة التحكم المركزية - صُنعت بواسطة المبجّل"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.BackgroundTransparency = 1
TitleLabel.Parent = TopBar

-- محتوى الواجهة الرئيسي
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -30, 1, -60)
ContentFrame.Position = UDim2.new(0, 15, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- قسم التحذير الأمني
local WarningBox = Instance.new("Frame")
WarningBox.Size = UDim2.new(1, 0, 0, 80)
WarningBox.BackgroundColor3 = Color3.fromRGB(50, 20, 20)
WarningBox.BorderSizePixel = 0
WarningBox.Parent = ContentFrame

local WarningCorner = Instance.new("UICorner")
WarningCorner.CornerRadius = UDim.new(0, 8)
WarningCorner.Parent = WarningBox

local WarningText = Instance.new("TextLabel")
WarningText.Size = UDim2.new(1, -20, 1, 0)
WarningText.Position = UDim2.new(0, 10, 0, 0)
WarningText.Font = Enum.Font.GothamSemibold
WarningText.Text = "⚠️ تحذير أمني هام:\nاستخدام الأدوات والسكربتات الخارجية قد يعرض حسابك للخطر أو الحظر النهائي من اللعبة. استخدمها على مسؤوليتك الخاصة."
WarningText.TextColor3 = Color3.fromRGB(255, 100, 100)
WarningText.TextSize = 12
WarningText.TextWrapped = true
WarningText.TextXAlignment = Enum.TextXAlignment.Right
WarningText.TextYAlignment = Enum.TextYAlignment.Center
WarningText.BackgroundTransparency = 1
WarningText.Parent = WarningBox

-- زر التفاعل (مثال)
local ActionButton = Instance.new("TextButton")
ActionButton.Size = UDim2.new(1, 0, 0, 45)
ActionButton.Position = UDim2.new(0, 0, 0, 100)
ActionButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
ActionButton.Font = Enum.Font.GothamBold
ActionButton.Text = "تفعيل الميزات الأساسية"
ActionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionButton.TextSize = 14
ActionButton.Parent = ContentFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = ActionButton

ActionButton.MouseButton1Click:Connect(function()
    print("تم تفعيل الخيارات بواسطة لوحة المبجّل!")
end)

-- خاصية تحريك النافذة بالماوس أو اللمس
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
