local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- إزالة الواجهة القديمة لمنع التكرار
if CoreGui:FindFirstChild("AlMubajilHub") then
    CoreGui.AlMubajilHub:Destroy()
end

-- إعدادات الميزات واللغة
local Settings = {
    SpeedEnabled = false,
    SpeedPower = 0.5,
    ESPEnabled = false,
    AimbotEnabled = false,
    FOVEnabled = false,
    FOVRadius = 120,
    Language = "AR" -- "AR" للعربية أو "EN" للإنجليزية
}

-- نصوص الواجهة باللغتين
local Texts = {
    AR = {
        Title = "سكربت المبجل",
        Speed = "السرعة الآمنة (Speed)",
        ESP = "كشف اللاعبين (ESP & Names)",
        Aimbot = "الإيم بوت (Aimbot)",
        FOV = "دائرة الرؤية (FOV)",
        LangBtn = "English",
        Running = "شغال",
        Stopped = "متوقف",
        Credits = "حقوق الملكية © المبجل"
    },
    EN = {
        Title = "AlMubajil Script",
        Speed = "Safe Speed",
        ESP = "ESP & Names",
        Aimbot = "Aimbot",
        FOV = "FOV Circle",
        LangBtn = "عربي",
        Running = "Running",
        Stopped = "Stopped",
        Credits = "Copyright © AlMubajil"
    }
}

-- دائرة الـ FOV في منتصف الشاشة تماماً
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Transparency = 0.7
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false

-- تخزين عناصر الـ ESP لكل لاعب
local ESPList = {}

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local espData = {
        NameTag = Drawing.new("Text"),
        Box = Drawing.new("Square")
    }
    
    espData.NameTag.Visible = false
    espData.NameTag.Center = true
    espData.NameTag.Outline = true
    espData.NameTag.Font = Drawing.Fonts.UI
    espData.NameTag.Size = 14
    espData.NameTag.Color = Color3.fromRGB(0, 255, 255)
    
    espData.Box.Visible = false
    espData.Box.Thickness = 1
    espData.Box.Color = Color3.fromRGB(255, 0, 0)
    espData.Box.Filled = false
    
    ESPList[player] = espData
end

local function RemoveESP(player)
    if ESPList[player] then
        ESPList[player].NameTag:Remove()
        ESPList[player].Box:Remove()
        ESPList[player] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- بناء واجهة المستخدم (GUI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AlMubajilHub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -185)
MainFrame.Size = UDim2.new(0, 320, 0, 380)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

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
TitleLabel.Position = UDim2.new(0.05, 0, 0, 0)
TitleLabel.Size = UDim2.new(0.6, 0, 1, 0)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = Texts[Settings.Language].Title
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
    FOVCircle:Remove()
    for _, data in pairs(ESPList) do
        data.NameTag:Remove()
        data.Box:Remove()
    end
end)

-- زر التكبير والتصغير (-)
local MinBtn = Instance.new("TextButton")
MinBtn.Parent = TopBar
MinBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
MinBtn.Position = UDim2.new(1, -60, 0.15, 0)
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 14

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinBtn

-- زر تغيير اللغة (AR / EN)
local LangBtn = Instance.new("TextButton")
LangBtn.Parent = TopBar
LangBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 180)
LangBtn.Position = UDim2.new(1, -115, 0.15, 0)
LangBtn.Size = UDim2.new(0, 50, 0, 25)
LangBtn.Font = Enum.Font.SourceSansBold
LangBtn.Text = Texts[Settings.Language].LangBtn
LangBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LangBtn.TextSize = 12

local LangCorner = Instance.new("UICorner")
LangCorner.CornerRadius = UDim.new(0, 6)
LangCorner.Parent = LangBtn

-- شريط حقوق المبجل في الأسفل
local CreditsLabel = Instance.new("TextLabel")
CreditsLabel.Parent = MainFrame
CreditsLabel.BackgroundTransparency = 1
CreditsLabel.Position = UDim2.new(0, 0, 1, -25)
CreditsLabel.Size = UDim2.new(1, 0, 0, 20)
CreditsLabel.Font = Enum.Font.SourceSansBold
CreditsLabel.Text = Texts[Settings.Language].Credits
CreditsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
CreditsLabel.TextSize = 12
CreditsLabel.TextAlignment = Enum.TextAlignment.Center

-- حاوية الأزرار للتحكم في التكبير والتصغير
local ContentHolder = Instance.new("Folder")
ContentHolder.Parent = MainFrame

local toggles = {}

local function CreateToggle(key, textKey, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.Position = UDim2.new(0.07, 0, 0, yPos)
    btn.Size = UDim2.new(0.86, 0, 0, 40)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    local state = false
    
    local function updateText()
        local t = Texts[Settings.Language][textKey]
        local s = state and Texts[Settings.Language].Running or Texts[Settings.Language].Stopped
        btn.Text = t .. ": " .. s
    end
    
    updateText()
    table.insert(toggles, {Update = updateText, GetState = function() return state end, TextKey = textKey, Button = btn})
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
        else
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        end
        updateText()
        callback(state)
    end)
end

-- إنشاء الأزرار
CreateToggle("Speed", "Speed", 50, function(state) Settings.SpeedEnabled = state end)
CreateToggle("ESP", "ESP", 100, function(state) Settings.ESPEnabled = state end)
CreateToggle("Aimbot", "Aimbot", 150, function(state) Settings.AimbotEnabled = state end)
CreateToggle("FOV", "FOV", 200, function(state) Settings.FOVEnabled = state; FOVCircle.Visible = state end)

-- منطق تغيير اللغة
LangBtn.MouseButton1Click:Connect(function()
    if Settings.Language == "AR" then
        Settings.Language = "EN"
    else
        Settings.Language = "AR"
    end
    
    TitleLabel.Text = Texts[Settings.Language].Title
    LangBtn.Text = Texts[Settings.Language].LangBtn
    CreditsLabel.Text = Texts[Settings.Language].Credits
    
    for _, t in ipairs(toggles) do
        t.Update()
    end
end)

-- منطق تكبير وتصغير الواجهة (Collapse/Expand)
local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame:TweenSize(UDim2.new(0, 320, 0, 35), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
        MinBtn.Text = "+"
        for _, t in ipairs(toggles) do t.Button.Visible = false end
        CreditsLabel.Visible = false
    else
        MainFrame:TweenSize(UDim2.new(0, 320, 0, 380), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
        MinBtn.Text = "-"
        for _, t in ipairs(toggles) do t.Button.Visible = true end
        CreditsLabel.Visible = true
    end
end)

-- دالة البحث عن أقرب هدف للايم بوت داخل الـ FOV
local function GetClosestPlayer()
    local target = nil
    local shortestDist = Settings.FOVRadius
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            
            if onScreen then
                local viewportSize = Camera.ViewportSize
                local centerScreen = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - centerScreen).Magnitude
                
                if dist < shortestDist then
                    shortestDist = dist
                    target = head
                end
            end
        end
    end
    return target
end

-- الحلقة الرئيسية لتشغيل الميزات بسلاسة
RunService.RenderStepped:Connect(function()
    -- تطبيق السرعة الآمنة (CFrame) لتجنب حماية الماب
    if Settings.SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid and humanoid.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (humanoid.MoveDirection * Settings.SpeedPower)
        end
    end
    
    -- تثبيت دائرة الـ FOV في منتصف الشاشة بدقة
    if Settings.FOVEnabled then
        local viewportSize = Camera.ViewportSize
        FOVCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
        FOVCircle.Radius = Settings.FOVRadius
    end
    
    -- تحديث الـ ESP (الأسماء واماكن اللاعبين من ورا الجدران)
    for player, data in pairs(ESPList) do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChild("Humanoid")
        
        if Settings.ESPEnabled and char and hrp and humanoid and humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                data.NameTag.Text = player.Name
                data.NameTag.Position = Vector2.new(pos.X, pos.Y - 40)
                data.NameTag.Visible = true
                
                data.Box.Size = Vector2.new(2000 / pos.Z, 3000 / pos.Z)
                data.Box.Position = Vector2.new(pos.X - data.Box.Size.X / 2, pos.Y - data.Box.Size.Y / 2)
                data.Box.Visible = true
            else
                data.NameTag.Visible = false
                data.Box.Visible = false
            end
        else
            data.NameTag.Visible = false
            data.Box.Visible = false
        end
    end
    
    -- تشغيل الإيم بوت عند الضغط المستمر على زر الماوس الأيمن
    if Settings.AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local aimTarget = GetClosestPlayer()
        if aimTarget then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimTarget.Position)
        end
    end
end)
