local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- إعدادات السكربت الافتراضية
local Settings = {
    ChamsEnabled = false,
    NamesEnabled = false,
    TeamCheck = false,
    AimbotEnabled = false,
    ShowFOV = false,
    FOVSize = 100,       -- نصف قطر الدائرة بالبكسل
    Smoothness = 0.15    -- نسبة سلاسة توجيه الكاميرا (كلما قلّ الرقم كان التصويب أسرع)
}

-- [نظام الحماية]: توليد أسماء عشوائية فريدة لمنع الكشف
local GUI_NAME = HttpService:GenerateGUID(false):sub(1, 8)
local HIGHLIGHT_NAME = HttpService:GenerateGUID(false):sub(1, 8)
local BILLBOARD_NAME = HttpService:GenerateGUID(false):sub(1, 8)
local FOV_GUI_NAME = HttpService:GenerateGUID(false):sub(1, 8)

local Connections = {}
local ActiveBillboards = {}

-- 1. إنشاء واجهة التحكم (Premium UI)
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local oldGui = PlayerGui:FindFirstChild(GUI_NAME)
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- إطار الواجهة الرئيسي
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 320)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- العنوان
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.12, 0)
Title.BackgroundTransparency = 1
Title.Text = "PREMIUM UTILITY PANEL"
Title.TextColor3 = Color3.fromRGB(0, 170, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- دالة مساعدة لإنشاء الأزرار التفاعلية
local function createButton(text, yPos, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0.1, 0)
    button.Position = UDim2.new(0.05, 0, yPos, 0)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.Text = text .. ": OFF"
    button.TextColor3 = Color3.fromRGB(200, 200, 200)
    button.TextSize = 11
    button.Font = Enum.Font.GothamMedium
    button.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button

    local active = false
    button.MouseButton1Click:Connect(function()
        active = not active
        if active then
            button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.Text = text .. ": ON"
        else
            button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            button.TextColor3 = Color3.fromRGB(200, 200, 200)
            button.Text = text .. ": OFF"
        end
        callback(active)
    end)
    return button
end

-- 2. إنشاء دائرة الـ FOV المرئية في منتصف الشاشة
local oldFov = PlayerGui:FindFirstChild(FOV_GUI_NAME)
if oldFov then oldFov:Destroy() end

local FovGui = Instance.new("ScreenGui")
FovGui.Name = FOV_GUI_NAME
FovGui.ResetOnSpawn = false
FovGui.Parent = PlayerGui

local FovFrame = Instance.new("Frame")
FovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FovFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FovFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FovFrame.BackgroundTransparency = 1 -- جعل الخلفية شفافة لرؤية اللعبة
FovFrame.Visible = false
FovFrame.Parent = FovGui

local FovCorner = Instance.new("UICorner")
FovCorner.CornerRadius = UDim.new(1, 0) -- دائرة كاملة
FovCorner.Parent = FovFrame

-- رسم خط الدائرة الخارجي
local FovStroke = Instance.new("UIStroke")
FovStroke.Color = Color3.fromRGB(0, 170, 255)
FovStroke.Thickness = 1.5
FovStroke.Transparency = 0.5
FovStroke.Parent = FovFrame

-- تحديث حجم ومكان الدائرة بناءً على الإعدادات
local function updateFOVVisual()
    FovFrame.Size = UDim2.new(0, Settings.FOVSize * 2, 0, Settings.FOVSize * 2)
    FovFrame.Visible = Settings.ShowFOV
end

-- 3. ميكانيكية الـ Aimbot والـ ESP

-- تنظيف مجسم لاعب معين
local function cleanCharacter(character)
    local hl = character:FindFirstChild(HIGHLIGHT_NAME)
    if hl then hl:Destroy() end
    local bb = character:FindFirstChild(BILLBOARD_NAME)
    if bb then bb:Destroy() end
end

-- إظهار اللاعبين وتأثيرات Chams والأسماء
local function updatePlayerESP(player)
    local char = player.Character
    if not char then return end

    if Settings.TeamCheck and player.Team == LocalPlayer.Team then
        cleanCharacter(char)
        return
    end

    if Settings.ChamsEnabled then
        local hl = char:FindFirstChild(HIGHLIGHT_NAME)
        if not hl then
            hl = Instance.new("Highlight")
            hl.Name = HIGHLIGHT_NAME
            hl.FillColor = Color3.fromRGB(0, 170, 255)
            hl.FillTransparency = 0.5
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.Parent = char
        end
    else
        local hl = char:FindFirstChild(HIGHLIGHT_NAME)
        if hl then hl:Destroy() end
    end

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
                textLabel.TextStrokeTransparency = 0
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

-- العثور على أقرب لاعب داخل حدود دائرة الـ FOV
local function getClosestPlayerInFOV()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            -- تخطي أعضاء الفريق إذا كانت الميزة مفعلة
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
            if player.Character.Humanoid.Health <= 0 then continue end

            local head = player.Character:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    -- حساب المسافة بين رأس اللاعب ومركز الشاشة (FOV)
                    local distanceToCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if distanceToCenter <= Settings.FOVSize and distanceToCenter < shortestDistance then
                        shortestDistance = distanceToCenter
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- تشغيل تتبع الكاميرا للهدف (Aimbot Loop)
local function startAimbotLoop()
    local conn = RunService.RenderStepped:Connect(function()
        -- تحديث المسافات للأسماء
        if Settings.NamesEnabled then
            for player, label in pairs(ActiveBillboards) do
                if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local myChar = LocalPlayer.Character
                    if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                        local dist = (myChar.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        label.Text = string.format("%s\n[%d Studs]", player.Name, math.floor(dist))
                    end
                end
            end
        end

        -- منطق الـ Aimbot
        if Settings.AimbotEnabled then
            local target = getClosestPlayerInFOV()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                -- توجيه الكاميرا بسلاسة (Smooth Lerping) نحو الرأس
                local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.Smoothness)
            end
        end
    end)
    table.insert(Connections, conn)
end

-- تفعيل المراقبة
local function initializeESP()
    for _, conn in ipairs(Connections) do conn:Disconnect() end
    Connections = {}

    local function monitorPlayer(player)
        if player == LocalPlayer then return end
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            updatePlayerESP(player)
        end)
        if player.Character then
            updatePlayerESP(player)
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do monitorPlayer(player) end
    table.insert(Connections, Players.PlayerAdded:Connect(monitorPlayer))
    
    startAimbotLoop()
end

local function refreshAll()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then updatePlayerESP(player) end
    end
end

-- 4. أزرار التحكم بالواجهة
createButton("Chams (Wallhack)", 0.15, function(val)
    Settings.ChamsEnabled = val
    refreshAll()
end)

createButton("Player Names", 0.27, function(val)
    Settings.NamesEnabled = val
    refreshAll()
end)

createButton("Team Check", 0.39, function(val)
    Settings.TeamCheck = val
    refreshAll()
end)

createButton("Aimbot (Lock-On)", 0.51, function(val)
    Settings.AimbotEnabled = val
end)

createButton("Show FOV Circle", 0.63, function(val)
    Settings.ShowFOV = val
    updateFOVVisual()
end)

-- أزرار التحكم في حجم الـ FOV
local FOVLabel = Instance.new("TextLabel")
FOVLabel.Size = UDim2.new(1, 0, 0.08, 0)
FOVLabel.Position = UDim2.new(0, 0, 0.75, 0)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Text = "FOV Size: " .. Settings.FOVSize
FOVLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
FOVLabel.TextSize = 11
FOVLabel.Font = Enum.Font.GothamMedium
FOVLabel.Parent = MainFrame

local DecreaseBtn = Instance.new("TextButton")
DecreaseBtn.Size = UDim2.new(0.4, 0, 0.08, 0)
DecreaseBtn.Position = UDim2.new(0.08, 0, 0.85, 0)
DecreaseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
DecreaseBtn.Text = "-"
DecreaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DecreaseBtn.TextSize = 14
DecreaseBtn.Font = Enum.Font.GothamBold
DecreaseBtn.Parent = MainFrame

local DecreaseCorner = Instance.new("UICorner")
DecreaseCorner.CornerRadius = UDim.new(0, 4)
DecreaseCorner.Parent = DecreaseBtn

local IncreaseBtn = Instance.new("TextButton")
IncreaseBtn.Size = UDim2.new(0.4, 0, 0.08, 0)
IncreaseBtn.Position = UDim2.new(0.52, 0, 0.85, 0)
IncreaseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
IncreaseBtn.Text = "+"
IncreaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
IncreaseBtn.TextSize = 14
IncreaseBtn.Font = Enum.Font.GothamBold
IncreaseBtn.Parent = MainFrame

local IncreaseCorner = Instance.new("UICorner")
IncreaseCorner.CornerRadius = UDim.new(0, 4)
IncreaseCorner.Parent = IncreaseBtn

-- تفعيل أزرار تغيير الحجم
DecreaseBtn.MouseButton1Click:Connect(function()
    if Settings.FOVSize > 20 then
        Settings.FOVSize = Settings.FOVSize - 10
        FOVLabel.Text = "FOV Size: " .. Settings.FOVSize
        updateFOVVisual()
    end
end)

IncreaseBtn.MouseButton1Click:Connect(function()
    if Settings.FOVSize < 500 then
        Settings.FOVSize = Settings.FOVSize + 10
        FOVLabel.Text = "FOV Size: " .. Settings.FOVSize
        updateFOVVisual()
    end
end)

-- تشغيل السكربت
initializeESP()
updateFOVVisual()
