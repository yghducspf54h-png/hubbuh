local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- إزالة الواجهة القديمة إذا كانت موجودة لمنع التكرار
if CoreGui:FindFirstChild("BlockSpinHubGui") then
    CoreGui.BlockSpinHubGui:Destroy()
end

-- بناء الواجهة الرئيسية (ScreenGui)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BlockSpinHubGui"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- الإطار الرئيسي
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
MainFrame.Size = UDim2.new(0, 450, 0, 300)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- شريط العنوان العلوي
local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BorderSizePixel = 0

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = TopBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0.03, 0, 0, 0)
TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = "BlockSpin Ultimate Hub"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- زر إغلاق الواجهة (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopBar
CloseBtn.BackgroundColor3 = Color3.fromRGB(230, 50, 50)
CloseBtn.Position = UDim2.new(1, -30, 0.15, 0)
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- شريط التبويبات الجانبي أو العلوي (Tabs)
local TabBar = Instance.new("Frame")
TabBar.Parent = MainFrame
TabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
TabBar.Position = UDim2.new(0, 0, 0, 35)
TabBar.Size = UDim2.new(0, 120, 1, -35)
TabBar.BorderSizePixel = 0

-- حاوية محتوى التبويبات
local Container = Instance.new("Frame")
Container.Parent = MainFrame
Container.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Container.Position = UDim2.new(0, 120, 0, 35)
Container.Size = UDim2.new(1, -120, 1, -35)
Container.BorderSizePixel = 0

local GroceryTabContent = Instance.new("ScrollingFrame")
GroceryTabContent.Parent = Container
GroceryTabContent.BackgroundTransparency = 1
GroceryTabContent.Size = UDim2.new(1, 0, 1, 0)
GroceryTabContent.CanvasSize = UDim2.new(0, 0, 0, 300)
GroceryTabContent.Visible = true
GroceryTabContent.BorderSizePixel = 0

local JobsTabContent = Instance.new("ScrollingFrame")
JobsTabContent.Parent = Container
JobsTabContent.BackgroundTransparency = 1
JobsTabContent.Size = UDim2.new(1, 0, 1, 0)
JobsTabContent.CanvasSize = UDim2.new(0, 0, 0, 300)
JobsTabContent.Visible = false
JobsTabContent.BorderSizePixel = 0

-- زر تبويب البقالة
local GroceryTabBtn = Instance.new("TextButton")
GroceryTabBtn.Parent = TabBar
GroceryTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
GroceryTabBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
GroceryTabBtn.Size = UDim2.new(0.9, 0, 0, 35)
GroceryTabBtn.Font = Enum.Font.SourceSansBold
GroceryTabBtn.Text = "البقالة (Stocker)"
GroceryTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GroceryTabBtn.TextSize = 13

local GCorner = Instance.new("UICorner")
GCorner.CornerRadius = UDim.new(0, 6)
GCorner.Parent = GroceryTabBtn

-- زر تبويب الوظائف الأخرى
local JobsTabBtn = Instance.new("TextButton")
JobsTabBtn.Parent = TabBar
JobsTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
JobsTabBtn.Position = UDim2.new(0.05, 0, 0.18, 0)
JobsTabBtn.Size = UDim2.new(0.9, 0, 0, 35)
JobsTabBtn.Font = Enum.Font.SourceSansBold
JobsTabBtn.Text = "وظائف أخرى"
JobsTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
JobsTabBtn.TextSize = 13

local JCorner = Instance.new("UICorner")
JCorner.CornerRadius = UDim.new(0, 6)
JCorner.Parent = JobsTabBtn

-- التبديل بين الشاشات
GroceryTabBtn.MouseButton1Click:Connect(function()
    GroceryTabContent.Visible = true
    JobsTabContent.Visible = false
    GroceryTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    GroceryTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    JobsTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    JobsTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
end)

JobsTabBtn.MouseButton1Click:Connect(function()
    GroceryTabContent.Visible = false
    JobsTabContent.Visible = true
    JobsTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    JobsTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    GroceryTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    GroceryTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
end)

-- محتوى قسم البقالة (Shelf Stocker Farm)
local GroceryTitle = Instance.new("TextLabel")
GroceryTitle.Parent = GroceryTabContent
GroceryTitle.BackgroundTransparency = 1
GroceryTitle.Position = UDim2.new(0.05, 0, 0.05, 0)
GroceryTitle.Size = UDim2.new(0.9, 0, 0, 30)
GroceryTitle.Font = Enum.Font.SourceSansBold
GroceryTitle.Text = "أتمتة وظيفة الصناديق (البقالة)"
GroceryTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
GroceryTitle.TextSize = 14
GroceryTitle.TextXAlignment = Enum.TextXAlignment.Left

local GroceryToggle = Instance.new("TextButton")
GroceryToggle.Parent = GroceryTabContent
GroceryToggle.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
GroceryToggle.Position = UDim2.new(0.05, 0, 0.2, 0)
GroceryToggle.Size = UDim2.new(0.9, 0, 0, 38)
GroceryToggle.Font = Enum.Font.SourceSansBold
GroceryToggle.Text = "تشغيل فارم البقالة: متوقف"
GroceryToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
GroceryToggle.TextSize = 14

local GTCorner = Instance.new("UICorner")
GTCorner.CornerRadius = UDim.new(0, 6)
GTCorner.Parent = GroceryToggle

local StatusDesc = Instance.new("TextLabel")
StatusDesc.Parent = GroceryTabContent
StatusDesc.BackgroundTransparency = 1
StatusDesc.Position = UDim2.new(0.05, 0, 0.38, 0)
StatusDesc.Size = UDim2.new(0.9, 0, 0, 50)
StatusDesc.Font = Enum.Font.SourceSans
StatusDesc.Text = "الحالة: جاهز للتشغيل (يقوم بالتقديم، حمل الصندوق، والتوصيل تلقائياً عند التفعيل)"
StatusDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusDesc.TextSize:gsub(12, 12)
StatusDesc.TextSize = 12
StatusDesc.TextWrapped = true
StatusDesc.TextXAlignment = Enum.TextXAlignment.Left

-- محتوى قسم الوظائف الأخرى
local OtherTitle = Instance.new("TextLabel")
OtherTitle.Parent = JobsTabContent
OtherTitle.BackgroundTransparency = 1
OtherTitle.Position = UDim2.new(0.05, 0, 0.05, 0)
OtherTitle.Size = UDim2.new(0.9, 0, 0, 30)
OtherTitle.Font = Enum.Font.SourceSansBold
OtherTitle.Text = "باقي الوظائف (قريباً / عام)"
OtherTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
OtherTitle.TextSize = 14
OtherTitle.TextXAlignment = Enum.TextXAlignment.Left

-- ربط زر التشغيل والإيقاف لمنطق البقالة
local groceryRunning = false
GroceryToggle.MouseButton1Click:Connect(function()
    groceryRunning = not groceryRunning
    if groceryRunning then
        GroceryToggle.Text = "تشغيل فارم البقالة: شغال"
        GroceryToggle.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        -- ضع كود اللوب أو السكربت الخاص بالفارم هنا أو شغله عبر task.spawn
    else
        GroceryToggle.Text = "تشغيل فارم البقالة: متوقف"
        GroceryToggle.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
    end
end)
