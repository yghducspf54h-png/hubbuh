local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- إزالة الواجهة القديمة لمنع التداخل
if CoreGui:FindFirstChild("AlMubajilGui") then
    CoreGui.AlMubajilGui:Destroy()
end

-- إعدادات السكربت
local Settings = {
    SpeedEnabled = false,
    WalkSpeedValue = 40,
    ESPEnabled = false,
    AimbotEnabled = false,
    FOVEnabled = false,
    FOVRadius = 130,
    Language = "AR"
}

local Texts = {
    AR = {
        Title = "سكربت المبجل",
        Speed = "السرعة الآمنة",
        ESP = "كشف اللاعبين والأسماء",
        Aimbot = "التصويب التلقائي (Aimbot)",
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
        Running = "ON",
        Stopped = "OFF",
        Credits = "Copyright © AlMubajil"
    }
}

-- إنشاء دائرة FOV باستخدام ScreenGui مدمج لضمان الظهور
local FOVGui = Instance.new("ScreenGui")
FOVGui.Name = "AlMubajilFOV"
FOVGui.Parent = CoreGui
FOVGui.ResetOnSpawn = false

local FOVFrame = Instance.new("Frame")
FOVFrame.Parent = FOVGui
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVFrame.Size = UDim2.new(0, Settings.FOVRadius * 2, 0, Settings.FOVRadius * 2)
FOVFrame.BackgroundTransparency = 1
FOVFrame.Visible = false

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVFrame

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Parent = FOVFrame
FOVStroke.Color = Color3.fromRGB(255, 255, 255)
FOVStroke.Thickness = 1.5
FOVStroke.Transparency = 0.3

-- نظام ESP المدمج (Highlight + NameTags)
local function ApplyESP(player)
    if player == LocalPlayer then return end
    
    local function CharacterAdded(char)
        if not char then return end
        
        -- إزالة القديم إن وجد
        if char:FindFirstChild("AlMubajilHighlight") then char.AlMubajilHighlight:Destroy() end
        
        -- إنشاء التظليل من خلف الجدران
        local highlight = Instance.new("Highlight")
        highlight.Name = "AlMubajilHighlight"
        highlight.Parent = char
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0
        highlight.Enabled = Settings.ESPEnabled
        
        -- إظهار الاسم فوق الراس
        local head = char:WaitForChild("Head", 5)
        if head and not head:FindFirstChild("AlMubajilName") then
            local bb = Instance.new("BillboardGui")
            bb.Name = "AlMubajilName"
            bb.Parent = head
            bb.Adornee = head
            bb.Size = UDim2.new(0, 100, 0, 30)
            bb.StudsOffset = Vector3.new(0, 2, 0)
            bb.AlwaysOnTop = true
            bb.Enabled = Settings.ESPEnabled
            
            local lbl = Instance.new("TextLabel")
            lbl.Parent = bb
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = player.Name
            lbl.TextColor3 = Color3.fromRGB(0, 255, 255)
            lbl.TextStrokeTransparency = 0
            lbl.Font = Enum.Font.SourceSansBold
            lbl.TextSize = 14
        end
    end
    
    if player.Character then CharacterAdded(player.Character) end
    player.CharacterAdded:Connect(CharacterAdded)
end

for _, p in ipairs(Players:GetPlayers()) do ApplyESP(p) end
Players.PlayerAdded:Connect(ApplyESP)

-- بناء واجهة المستخدم الرئيسية
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "AlMubajilGui"
MainGui.Parent = CoreGui
MainGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = MainGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -170)
MainFrame.Size = UDim2.new(0, 300, 0, 340)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
TopBar.Size = UDim2.new(1, 0, 0, 35)

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = TopBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0.04, 0, 0, 0)
TitleLabel.Size = UDim2.new(0.5, 0, 1, 0)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = Texts[Settings.Language].Title
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 15
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- الأزرار العلويّة
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopBar
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseBtn.Position = UDim2.new(1, -28, 0.15, 0)
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 12

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainGui:Destroy()
    FOVGui:Destroy()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            if p.Character:FindFirstChild("AlMubajilHighlight") then p.Character.AlMubajilHighlight:Destroy() end
            if p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("AlMubajilName") then
                p.Character.Head.AlMubajilName:Destroy()
            end
        end
    end
end)

local MinBtn = Instance.new("TextButton")
MinBtn.Parent = TopBar
MinBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
MinBtn.Position = UDim2.new(1, -54, 0.15, 0)
MinBtn.Size = UDim2.new(0, 22, 0, 22)
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 12

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 4)
MinCorner.Parent = MinBtn

local LangBtn = Instance.new("TextButton")
LangBtn.Parent = TopBar
LangBtn.BackgroundColor3 = Color3.fromRGB(40, 90, 160)
LangBtn.Position = UDim2.new(1, -105, 0.15, 0)
LangBtn.Size = UDim2.new(0, 46, 0, 22)
LangBtn.Font = Enum.Font.SourceSansBold
LangBtn.Text = Texts[Settings.Language].LangBtn
LangBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LangBtn.TextSize = 11

local LangCorner = Instance.new("UICorner")
LangCorner.CornerRadius = UDim.new(0, 4)
LangCorner.Parent = LangBtn

local CreditsLabel = Instance.new("TextLabel")
CreditsLabel.Parent = MainFrame
CreditsLabel.BackgroundTransparency = 1
CreditsLabel.Position = UDim2.new(0, 0, 1, -22)
CreditsLabel.Size = UDim2.new(1, 0, 0, 18)
CreditsLabel.Font = Enum.Font.SourceSansBold
CreditsLabel.Text = Texts[Settings.Language].Credits
CreditsLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
CreditsLabel.TextSize = 11

local toggles = {}

local function CreateToggle(key, textKey, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    btn.Position = UDim2.new(0.06, 0, 0, yPos)
    btn.Size = UDim2.new(0.88, 0, 0, 38)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    
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
    table.insert(toggles, {Update = updateText, Button = btn})
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(40, 160, 70) or Color3.fromRGB(35, 35, 45)
        updateText()
        callback(state)
    end)
end

CreateToggle("Speed", "Speed", 48, function(state) Settings.SpeedEnabled = state end)
CreateToggle("ESP", "ESP", 96, function(state)
    Settings.ESPEnabled = state
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local h = p.Character:FindFirstChild("AlMubajilHighlight")
            if h then h.Enabled = state end
            if p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("AlMubajilName") then
                p.Character.Head.AlMubajilName.Enabled = state
            end
        end
    end
end)
CreateToggle("Aimbot", "Aimbot", 144, function(state) Settings.AimbotEnabled = state end)
CreateToggle("FOV", "FOV", 192, function(state)
    Settings.FOVEnabled = state
    FOVFrame.Visible = state
end)

LangBtn.MouseButton1Click:Connect(function()
    Settings.Language = Settings.Language == "AR" and "EN" or "AR"
    TitleLabel.Text = Texts[Settings.Language].Title
    LangBtn.Text = Texts[Settings.Language].LangBtn
    CreditsLabel.Text = Texts[Settings.Language].Credits
    for _, t in ipairs(toggles) do t.Update() end
end)

local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    MainFrame:TweenSize(isMinimized and UDim2.new(0, 300, 0, 35) or UDim2.new(0, 300, 0, 340), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
    MinBtn.Text = isMinimized and "+" or "-"
    for _, t in ipairs(toggles) do t.Button.Visible = not isMinimized end
    CreditsLabel.Visible = not isMinimized
end)

-- البحث عن أقرب لاعب للإيم بوت
local function GetClosestPlayer()
    local target = nil
    local shortestDist = Settings.FOVRadius
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            
            if onScreen then
                local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
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

-- الحلقة التشغيلية الرئيسية
RunService.RenderStepped:Connect(function()
    -- سرعة حركة آمنة ومباشرة
    if Settings.SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeedValue
    end
    
    -- الإيم بوت عند الضغط المطول على زر الماوس الأيمن
    if Settings.AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local targetHead = GetClosestPlayer()
        if targetHead then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
        end
    end
end)
