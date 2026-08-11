local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- إزالة الواجهة القديمة لمنع التكرار
if CoreGui:FindFirstChild("BlockSpinProHub") then
    CoreGui.BlockSpinProHub:Destroy()
end

-- إعدادات الميزات
local Settings = {
    SpeedEnabled = false,
    WalkSpeed = 30,
    ESPEnabled = false,
    AimbotEnabled = false,
    FOVEnabled = false,
    FOVRadius = 120
}

-- دائرة الـ FOV
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
ScreenGui.Name = "BlockSpinProHub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -175)
MainFrame.Size = UDim2.new(0, 320, 0, 350)
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
TitleLabel.Size = UDim2.new(0.8, 0, 1, 0)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = "Combat & Visuals Hub"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 15
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

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

-- وظيفة لإنشاء أزرار التفعيل داخل الواجهة
local function CreateToggle(name, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.Position = UDim2.new(0.07, 0, 0, yPos)
    btn.Size = UDim2.new(0.86, 0, 0, 40)
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = name .. ": متوقف"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
            btn.Text = name .. ": شغال"
        else
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            btn.Text = name .. ": متوقف"
        end
        callback(state)
    end)
end

-- أزرار القائمة
CreateToggle("تفعيل السرعة (Speed)", 50, function(state)
    Settings.SpeedEnabled = state
end)

CreateToggle("كشف اللاعبين (ESP & Names)", 100, function(state)
    Settings.ESPEnabled = state
end)

CreateToggle("الإيم بوت (Aimbot)", 150, function(state)
    Settings.AimbotEnabled = state
end)

CreateToggle("دائرة الرؤية (FOV)", 200, function(state)
    Settings.FOVEnabled = state
    FOVCircle.Visible = state
end)

-- دالة البحث عن أقرب هدف للايم بوت داخل الـ FOV
local function GetClosestPlayer()
    local target = nil
    local shortestDist = Settings.FOVRadius
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local hrp = player.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            
            if onScreen then
                local mousePos = UserInputService:GetMouseLocation()
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                
                if dist < shortestDist then
                    shortestDist = dist
                    target = player.Character.Head
                end
            end
        end
    end
    return target
end

-- الحلقة الرئيسية لتشغيل الميزات بسلاسة
RunService.RenderStepped:Connect(function()
    -- تطبيق السرعة
    if Settings.SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeed
    end
    
    -- تحديث دائرة الـ FOV
    if Settings.FOVEnabled then
        FOVCircle.Position = UserInputService:GetMouseLocation()
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
    
    -- تشغيل الإيم بوت عند الضغط المستمر على زر الفأرة الأيمن أو الزر الافتراضي
    if Settings.AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local aimTarget = GetClosestPlayer()
        if aimTarget then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimTarget.Position)
        end
    end
end)
