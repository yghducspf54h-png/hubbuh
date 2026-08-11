local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- متغيرات التحكم
local ESP_Active = false
local ConnectionList = {}
local Highlights = {}

-- [نظام الحماية 1]: توليد أسماء عشوائية فريدة (GUID) في كل مرة يتم فيها تشغيل السكربت
-- هذا يمنع أنظمة الحماية من التعرف على السكربت من خلال أسماء العناصر الثابتة (مثل ESP_GUI)
local GUI_NAME = HttpService:GenerateGUID(false):sub(1, 8)
local HIGHLIGHT_NAME = HttpService:GenerateGUID(false):sub(1, 8)

-- 1. إنشاء واجهة المستخدم (GUI)
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- حذف أي واجهة قديمة في حال تكرار التشغيل
local oldGui = PlayerGui:FindFirstChild(GUI_NAME)
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- إنشاء الإطار الرئيسي (قابل للسحب والتحريك)
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 180, 0, 80)
Frame.Position = UDim2.new(0.05, 0, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true -- تفعيل إمكانية تحريك الواجهة بالماوس
Frame.Parent = ScreenGui

-- زوايا دائرية للواجهة
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

-- عنوان الواجهة
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.4, 0)
Title.Text = "ESP Control"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.Parent = Frame

-- زر التشغيل والإيقاف
local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0.8, 0, 0.4, 0)
Button.Position = UDim2.new(0.1, 0, 0.45, 0)
Button.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- لون أحمر (إيقاف)
Button.Text = "ESP: OFF"
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.TextSize = 14
Button.Font = Enum.Font.SourceSansBold
Button.Parent = Frame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = Button

-- 2. دوال تشغيل وإلغاء تحديد اللاعبين
local function removeHighlight(character)
    local hl = character:FindFirstChild(HIGHLIGHT_NAME)
    if hl then
        hl:Destroy()
    end
end

local function addHighlight(character, player)
    if player == LocalPlayer then return end
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end

    removeHighlight(character)

    local highlight = Instance.new("Highlight")
    highlight.Name = HIGHLIGHT_NAME
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Adornee = character
    highlight.Parent = character
    
    Highlights[player] = highlight
end

local function clearAllESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            removeHighlight(player.Character)
        end
    end
    Highlights = {}
end

-- [نظام الحماية 2]: إدارة الاتصالات (Connections) لعدم تسريب الذاكرة
local function startESP()
    clearAllESP()
    
    local function setupPlayer(player)
        if player.Character then
            addHighlight(player.Character, player)
        end
        local conn = player.CharacterAdded:Connect(function(char)
            addHighlight(char, player)
        end)
        table.insert(ConnectionList, conn)
    end

    for _, player in ipairs(Players:GetPlayers()) do
        setupPlayer(player)
    end

    local connAdded = Players.PlayerAdded:Connect(function(player)
        setupPlayer(player)
    end)
    table.insert(ConnectionList, connAdded)
end

-- إيقاف السكربت وتنظيفه بالكامل
local function stopESP()
    -- قطع كافة الاتصالات بالأحداث لمنع تراكم العمليات في الخلفية وكشفها
    for _, conn in ipairs(ConnectionList) do
        if conn then
            conn:Disconnect()
        end
    end
    ConnectionList = {}
    clearAllESP()
end

-- 3. تفعيل الأزرار والتنقل بين الحالات
Button.MouseButton1Click:Connect(function()
    ESP_Active = not ESP_Active
    if ESP_Active then
        Button.BackgroundColor3 = Color3.fromRGB(50, 180, 50) -- لون أخضر (تشغيل)
        Button.Text = "ESP: ON"
        startESP()
    else
        Button.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- لون أحمر (إيقاف)
        Button.Text = "ESP: OFF"
        stopESP()
    end
end)
