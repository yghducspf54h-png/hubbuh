-- التأكد من تشغيل البيئة ودعمها للمكتبات الأساسية
if not Drawing or not syn and not PROTOSCREEN and not identifyexecutor then
    -- محاولة تشغيل بديلة للتوافقية القصوى
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- إعدادات السكربت القصوى (Max Settings)
local Settings = {
    ESPEnabled = false,
    NamesEnabled = false,
    TeamCheck = false,
    AimbotEnabled = false,
    ShowFOV = false,
    FOVSize = 130,
    Smoothness = 0.12, -- سلاسة فائقة وسريعة للتصويب
    BoxColor = Color3.fromRGB(0, 255, 200), -- لون نيون احترافي
    TextColor = Color3.fromRGB(255, 255, 255)
}

-- [نظام حماية متطور]: توليد هويات عشوائية بالكامل لمنع أي حظر برمجي
local GUI_NAME = HttpService:GenerateGUID(false)
local FOV_GUI_NAME = HttpService:GenerateGUID(false)

local ESPDrawings = {}

-- 1. بناء واجهة التحكم الاحترافية (Max UI Design)
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
if PlayerGui:FindFirstChild(GUI_NAME) then PlayerGui[GUI_NAME]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 340)
MainFrame.Position = UDim2.new(0.03, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- شريط علوي جمالي
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0.12, 0)
TopBar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "MAX PERFORMANCE HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.Parent = TopBar

-- إصلاح حواف الشريط العلوي السفلي
local FixCover = Instance.new("Frame")
FixCover.Size = UDim2.new(1, 0, 0.5, 0)
FixCover.Position = UDim2.new(0, 0, 0.5, 0)
FixCover.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
FixCover.BorderSizePixel = 0
FixCover.Parent = TopBar

local function createButton(text, yPos, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.92, 0, 0.09, 0)
    button.Position = UDim2.new(0.04, 0, yPos, 0)
    button.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    button.Text = text .. " : [OFF]"
    button.TextColor3 = Color3.fromRGB(180, 180, 180)
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
            button.Text = text .. " : [ON]"
        else
            button.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
            button.TextColor3 = Color3.fromRGB(180, 180, 180)
            button.Text = text .. " : [OFF]"
        end
        callback(active)
    end)
    return button
end

-- 2. دائرة الـ FOV الاحترافية
local FovGui = Instance.new("ScreenGui")
FovGui.Name = FOV_GUI_NAME
FovGui.ResetOnSpawn = false
FovGui.Parent = PlayerGui

local FovFrame = Instance.new("Frame")
FovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FovFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FovFrame.BackgroundTransparency = 1
FovFrame.Visible = false
FovFrame.Parent = FovGui

local FovCorner = Instance.new("UICorner")
FovCorner.CornerRadius = UDim.new(1, 0)
FovCorner.Parent = FovFrame

local FovStroke = Instance.new("UIStroke")
FovStroke.Color = Color3.fromRGB(0, 170, 255)
FovStroke.Thickness = 2
FovStroke.Transparency = 0.2
FovStroke.Parent = FovFrame

local function updateFOVVisual()
    FovFrame.Size = UDim2.new(0, Settings.FOVSize * 2, 0, Settings.FOVSize * 2)
    FovFrame.Visible = Settings.ShowFOV
end

-- 3. نظام الرسم المباشر (Drawing API المتقدم)
local function removeESP(player)
    if ESPDrawings[player] then
        pcall(function()
            ESPDrawings[player].Box:Remove()
            ESPDrawings[player].Name:Remove()
        end)
        ESPDrawings[player] = nil
    end
end

local function addESP(player)
    removeESP(player)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Settings.BoxColor
    box.Thickness = 1.5
    box.Filled = false

    local name = Drawing.new("Text")
    name.Visible = false
    name.Color = Settings.TextColor
    name.Size = 13
    name.Center = true
    name.Outline = true

    ESPDrawings[player] = {Box = box, Name = name}
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then addESP(p) end
end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then addESP(p) end end)
Players.PlayerRemoving:Connect(removeESP)

-- 4. محرك الـ Aimbot الذكي والأسرع
local function getClosestPlayerInFOV()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local head = player.Character:FindFirstChild("Head")
            
            if humanoid and head and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local distToCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if distToCenter <= Settings.FOVSize and distToCenter < shortestDistance then
                        shortestDistance = distToCenter
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- 5. حلقة التحديث المستمرة (Max Performance Loop)
RunService.RenderStepped:Connect(function()
    -- تحديث الـ ESP بدقة عالية
    for player, drawings in pairs(ESPDrawings) do
        local char = player.Character
        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local humanoid = char and char:FindFirstChild("Humanoid")

        local isValid = char and rootPart and head and humanoid and humanoid.Health > 0
        if Settings.TeamCheck and player.Team == LocalPlayer.Team then
            isValid = false
        end

        if isValid and Settings.ESPEnabled then
            local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            if onScreen then
                local scale = 1 / (pos.Z * math.tan(math.rad(Camera.FieldOfView / 2)) * 2) * 1000
                local w, h = math.floor(36 * scale), math.floor(52 * scale)
                
                drawings.Box.Size = Vector2.new(w, h)
                drawings.Box.Position = Vector2.new(pos.X - w / 2, pos.Y - h / 2)
                drawings.Box.Visible = true

                if Settings.NamesEnabled then
                    local myChar = LocalPlayer.Character
                    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    local dist = myRoot and math.floor((myRoot.Position - rootPart.Position).Magnitude) or 0
                    
                    drawings.Name.Text = string.format("%s | [%dm]", player.Name, dist)
                    drawings.Name.Position = Vector2.new(pos.X, (pos.Y - h / 2) - 18)
                    drawings.Name.Visible = true
                else
                    drawings.Name.Visible = false
                end
            else
                drawings.Box.Visible = false
                drawings.Name.Visible = false
            end
        else
            drawings.Box.Visible = false
            drawings.Name.Visible = false
        end
    end

    -- تشغيل الـ Aimbot الفوري عند الضغط أو التفعيل
    if Settings.AimbotEnabled then
        local target = getClosestPlayerInFOV()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local targetHead = target.Character.Head
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.Smoothness)
        end
    end
end)

-- 6. أزرار التحكم المتكاملة في الواجهة
createButton("ESP Boxes", 0.16, function(val)
    Settings.ESPEnabled = val
end)

createButton("Player Names", 0.27, function(val)
    Settings.NamesEnabled = val
end)

createButton("Team Check", 0.38, function(val)
    Settings.TeamCheck = val
end)

createButton("Aimbot (Lock)", 0.49, function(val)
    Settings.AimbotEnabled = val
end)

createButton("Show FOV Circle", 0.60, function(val)
    Settings.ShowFOV = val
    updateFOVVisual()
end)

-- عناصر التحكم بحجم الـ FOV
local FOVLabel = Instance.new("TextLabel")
FOVLabel.Size = UDim2.new(1, 0, 0.08, 0)
FOVLabel.Position = UDim2.new(0, 0, 0.72, 0)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Text = "FOV Radius: " .. Settings.FOVSize
FOVLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
FOVLabel.TextSize = 11
FOVLabel.Font = Enum.Font.GothamMedium
FOVLabel.Parent = MainFrame

local decBtn = Instance.new("TextButton")
decBtn.Size = UDim2.new(0.4, 0, 0.08, 0)
decBtn.Position = UDim2.new(0.07, 0, 0.82, 0)
decBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
decBtn.Text = "- Size"
decBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
decBtn.Font = Enum.Font.GothamBold
decBtn.Parent = MainFrame
Instance.new("UICorner", decBtn).CornerRadius = UDim.new(0, 4)

local incBtn = Instance.new("TextButton")
incBtn.Size = UDim2.new(0.4, 0, 0.08, 0)
incBtn.Position = UDim2.new(0.53, 0, 0.82, 0)
incBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
incBtn.Text = "+ Size"
incBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
incBtn.Font = Enum.Font.GothamBold
incBtn.Parent = MainFrame
Instance.new("UICorner", incBtn).CornerRadius = UDim.new(0, 4)

decBtn.MouseButton1Click:Connect(function()
    if Settings.FOVSize > 30 then
        Settings.FOVSize = Settings.FOVSize - 15
        FOVLabel.Text = "FOV Radius: " .. Settings.FOVSize
        updateFOVVisual()
    end
end)

incBtn.MouseButton1Click:Connect(function()
    if Settings.FOVSize < 400 then
        Settings.FOVSize = Settings.FOVSize + 15
        FOVLabel.Text = "FOV Radius: " .. Settings.FOVSize
        updateFOVVisual()
    end
end)

updateFOVVisual()
