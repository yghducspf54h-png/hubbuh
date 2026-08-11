local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- الحالات الافتراضية للميزات
local Settings = {
    ChamsEnabled = false,
    NamesEnabled = false,
    TeamCheck = false
}

-- [نظام الحماية]: توليد أسماء عشوائية فريدة لجميع العناصر لمنع تتبعها
local GUI_NAME = HttpService:GenerateGUID(false):sub(1, 8)
local HIGHLIGHT_NAME = HttpService:GenerateGUID(false):sub(1, 8)
local BILLBOARD_NAME = HttpService:GenerateGUID(false):sub(1, 8)

-- جداول لحفظ الاتصالات والعناصر النشطة
local Connections = {}
local ActiveBillboards = {}

-- 1. إنشاء واجهة مستخدم احترافية (Premium UI)
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local oldGui = PlayerGui:FindFirstChild(GUI_NAME)
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- الإطار الرئيسي (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 200)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- خلفية داكنة
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- شريط العنوان (Header)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.2, 0)
Title.BackgroundTransparency = 1
Title.Text = "PREMIUM ESP PANEL"
Title.TextColor3 = Color3.fromRGB(0, 170, 255) -- لون أزرق مضيء
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- دالة مساعدة لإنشاء الأزرار بشكل أنيق
local function createButton(text, yPos, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0.2, 0)
    button.Position = UDim2.new(0.05, 0, yPos, 0)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.Text = text .. ": OFF"
    button.TextColor3 = Color3.fromRGB(200, 200, 200)
    button.TextSize = 12
    button.Font = Enum.Font.GothamMedium
    button.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button

    local active = false
    button.MouseButton1Click:Connect(function()
        active = not active
        if active then
            button.BackgroundColor3 = Color3.fromRGB(0, 170, 255) -- أزرق عند التفعيل
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.Text = text .. ": ON"
        else
            button.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- رمادي عند الإيقاف
            button.TextColor3 = Color3.fromRGB(200, 200, 200)
            button.Text = text .. ": OFF"
        end
        callback(active)
    end)
    return button
end

-- 2. منطق البرمجة وتأثيرات ESP

-- إزالة التأثيرات من شخصية معينة
local function cleanCharacter(character)
    local hl = character:FindFirstChild(HIGHLIGHT_NAME)
    if hl then hl:Destroy() end
    
    local billboard = character:FindFirstChild(BILLBOARD_NAME)
    if billboard then billboard:Destroy() end
end

-- تحديث حالة لاعب معين
local function updatePlayerESP(player)
    local char = player.Character
    if not char then return end

    -- التحقق من الفريق إذا كانت ميزة TeamCheck مفعلة
    if Settings.TeamCheck and player.Team == LocalPlayer.Team then
        cleanCharacter(char)
        return
    end

    -- [تفعيل/تعطيل Chams]
    if Settings.ChamsEnabled then
        local hl = char:FindFirstChild(HIGHLIGHT_NAME)
        if not hl then
            hl = Instance.new("Highlight")
            hl.Name = HIGHLIGHT_NAME
            hl.FillColor = Color3.fromRGB(0, 170, 255)
            hl.FillTransparency = 0.5
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.OutlineTransparency = 0
            hl.Adornee = char
            hl.Parent = char
        end
    else
        local hl = char:FindFirstChild(HIGHLIGHT_NAME)
        if hl then hl:Destroy() end
    end

    -- [تفعيل/تعطيل الأسماء والمسافة]
    if Settings.NamesEnabled then
        local head = char:FindFirstChild("Head")
        if head then
            local billboard = char:FindFirstChild(BILLBOARD_NAME)
            if not billboard then
                billboard = Instance.new("BillboardGui")
                billboard.Name = BILLBOARD_NAME
                billboard.Size = UDim2.new(0, 150, 0, 30)
                billboard.AlwaysOnTop = true
                billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                billboard.Adornee = head
                
                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                textLabel.TextStrokeTransparency = 0 -- إطار أسود حول الخط لزيادة وضوحه
                textLabel.Font = Enum.Font.GothamBold
                textLabel.TextSize = 10
                textLabel.Parent = billboard
                
                billboard.Parent = char
                ActiveBillboards[player] = textLabel
            end
        end
    else
        local billboard = char:FindFirstChild(BILLBOARD_NAME)
        if billboard then billboard:Destroy() end
        ActiveBillboards[player] = nil
    end
end

-- تحديث المسافات في الوقت الفعلي بشكل مستمر
local function startDistanceUpdater()
    local conn = RunService.RenderStepped:Connect(function()
        if not Settings.NamesEnabled then return end
        
        for player, label in pairs(ActiveBillboards) do
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local myChar = LocalPlayer.Character
                if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                    local dist = (myChar.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    label.Text = string.format("%s \n[%d Studs]", player.Name, math.floor(dist))
                end
            end
        end
    end)
    table.insert(Connections, conn)
end

-- تفعيل المراقبة لجميع اللاعبين
local function initializeESP()
    -- تنظيف كافة الأحداث القديمة
    for _, conn in ipairs(Connections) do
        conn:Disconnect()
    end
    Connections = {}
    
    local function monitorPlayer(player)
        if player == LocalPlayer then return end
        
        player.CharacterAdded:Connect(function(char)
            task.wait(0.5) -- الانتظار نصف ثانية للتأكد من تحميل العناصر بالكامل
            updatePlayerESP(player)
        end)
        
        if player.Character then
            updatePlayerESP(player)
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        monitorPlayer(player)
    end
    
    local connAdded = Players.PlayerAdded:Connect(monitorPlayer)
    table.insert(Connections, connAdded)
    
    startDistanceUpdater()
end

-- دالة لتحديث حالة اللاعبين فوراً عند تغيير أي إعداد
local function refreshAll()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            updatePlayerESP(player)
        end
    end
end

-- 3. ربط أزرار التحكم
createButton("Chams (Wallhack)", 0.25, function(val)
    Settings.ChamsEnabled = val
    refreshAll()
end)

createButton("Player Names", 0.50, function(val)
    Settings.NamesEnabled = val
    refreshAll()
end)

createButton("Team Check", 0.75, function(val)
    Settings.TeamCheck = val
    refreshAll()
end)

-- بدء التشغيل
initializeESP()
