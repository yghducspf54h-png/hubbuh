local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- إعدادات السكربت
local Settings = {
    ESPEnabled = false,
    NamesEnabled = false,
    TeamCheck = false,
    AimbotEnabled = false,
    ShowFOV = false,
    FOVSize = 120,
    Smoothness = 0.2
}

-- [نظام الحماية]: أسماء عشوائية للواجهة لمنع الكشف
local GUI_NAME = HttpService:GenerateGUID(false):sub(1, 8)
local FOV_GUI_NAME = HttpService:GenerateGUID(false):sub(1, 8)

-- تخزين عناصر الرسم الخاصة بكل لاعب
local ESPDrawings = {}

-- 1. إنشاء واجهة التحكم (UI)
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
if PlayerGui:FindFirstChild(GUI_NAME) then PlayerGui[GUI_NAME]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 310)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.12, 0)
Title.BackgroundTransparency = 1
Title.Text = "UNIVERSAL DRAWING ESP"
Title.TextColor3 = Color3.fromRGB(0, 170, 255)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

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

-- 2. دائرة الـ FOV المرئية
if PlayerGui:FindFirstChild(FOV_GUI_NAME) then PlayerGui[FOV_GUI_NAME]:Destroy() end
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
FovStroke.Thickness = 1.5
FovStroke.Transparency = 0.3
FovStroke.Parent = FovFrame

local function updateFOVVisual()
    FovFrame.Size = UDim2.new(0, Settings.FOVSize * 2, 0, Settings.FOVSize * 2)
    FovFrame.Visible = Settings.ShowFOV
end

-- 3. نظام الرسم المباشر (Drawing API Boxes & Names)
local function removeESP(player)
    if ESPDrawings[player] then
        for _, obj in pairs(ESPDrawings[player]) do
            pcall(function() obj:Remove() end)
        end
        ESPDrawings[player] = nil
    end
end

local function addESP(player)
    removeESP(player)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(0, 170, 255)
    box.Thickness = 1.5
    box.Filled = false

    local name = Drawing.new("Text")
    name.Visible = false
    name.Color = Color3.fromRGB(255, 255, 255)
    name.Size = 14
    name.Center = true
    name.Outline = true

    ESPDrawings[player] = {Box = box, Name = name}
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then addESP(p) end
end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then addESP(p) end end)
Players.PlayerRemoving:Connect(removeESP)

-- 4. خوارزمية الـ Aimbot لاختيار أقرب هدف
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

-- 5. حلقة التحديث الشاملة (RenderStepped Loop)
RunService.RenderStepped:Connect(function()
    -- تحديث الـ ESP والكشف
    for player, drawings in pairs(ESPDrawings) do
        local char = player.Character
        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local humanoid = char and char:FindFirstChild("Humanoid")

        local showCondition = char and rootPart and head and humanoid and humanoid.Health > 0
        if Settings.TeamCheck and player.Team == LocalPlayer.Team then
            showCondition = false
        end

        if showCondition and Settings.ESPEnabled then
            local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            if onScreen then
                local scale = 1 / (pos.Z * math.tan(math.rad(Camera.FieldOfView / 2)) * 2) * 1000
                local w, h = math.floor(35 * scale), math.floor(50 * scale)
                
                drawings.Box.Size = Vector2.new(w, h)
                drawings.Box.Position = Vector2.new(pos.X - w / 2, pos.Y - h / 2)
                drawings.Box.Visible = true

                if Settings.NamesEnabled then
                    local myChar = LocalPlayer.Character
                    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    local dist = myRoot and math.floor((myRoot.Position - rootPart.Position).Magnitude) or 0
                    
                    drawings.Name.Text = string.format("%s [%dm]", player.Name, dist)
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

    -- تشغيل الـ Aimbot
    if Settings.AimbotEnabled then
        local target = getClosestPlayerInFOV()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local targetHead = target.Character.Head
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.Smoothness)
        end
    end
end)

-- 6. أزرار الواجهة
createButton("ESP Boxes", 0.15, function(val)
    Settings.ESPEnabled = val
end)

createButton("Player Names", 0.27, function(val)
    Settings.NamesEnabled = val
end)

createButton("Team Check", 0.39, function(val)
    Settings.TeamCheck = val
end)

createButton("Aimbot (Lock)", 0.51, function(val)
    Settings.AimbotEnabled = val
end)

createButton("Show FOV Circle", 0.63, function(val)
    Settings.ShowFOV = val
    updateFOVVisual()
end)

-- أزرار تحكم حجم الـ FOV
local FOVLabel = Instance.new("TextLabel")
FOVLabel.Size = UDim2.new(1, 0, 0.08, 0)
FOVLabel.Position = UDim2.new(0, 0, 0.75, 0)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Text = "FOV Size: " .. Settings.FOVSize
FOVLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
FOVLabel.TextSize = 11
FOVLabel.Font = Enum.Font.GothamMedium
FOVLabel.Parent = MainFrame

local decBtn = Instance.new("TextButton")
decBtn.Size = UDim2.new(0.4, 0, 0.08, 0)
decBtn.Position = UDim2.new(0.08, 0, 0.85, 0)
decBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
decBtn.Text = "-"
decBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
decBtn.Parent = MainFrame
Instance.new("UICorner", decBtn).CornerRadius = UDim.new(0, 4)

local incBtn = Instance.new("TextButton")
incBtn.Size = UDim2.new(0.4, 0, 0.08, 0)
incBtn.Position = UDim2.new(0.52, 0, 0.85, 0)
incBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
incBtn.Text = "+"
incBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
incBtn.Parent = MainFrame
Instance.new("UICorner", incBtn).CornerRadius = UDim.new(0, 4)

decBtn.MouseButton1Click:Connect(function()
    if Settings.FOVSize > 30 then
        Settings.FOVSize = Settings.FOVSize - 10
        FOVLabel.Text = "FOV Size: " .. Settings.FOVSize
        updateFOVVisual()
    end
end)

incBtn.MouseButton1Click:Connect(function()
    if Settings.FOVSize < 400 then
        Settings.FOVSize = Settings.FOVSize + 10
        FOVLabel.Text = "FOV Size: " .. Settings.FOVSize
        updateFOVVisual()
    end
end)

updateFOVVisual()
