-- // ====================================================== \\ --
-- //   Time Bomb Ultimate Pro System - Fixed & Optimized    \\ --
-- // ====================================================== --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

if getgenv().TimeBombCleanup then
    getgenv().TimeBombCleanup()
end

local Settings = {
    AutoChaseEnabled = true,
    NoclipEnabled = true,
    SpeedBoostEnabled = true,
    CustomSpeed = 35,
    ESPEnabled = true,
}

local ActiveConnections = {}
local ESPObjects = {}

local function Cleanup()
    for _, conn in ipairs(ActiveConnections) do
        if conn and conn.Connected then conn:Disconnect() end
    end
    ActiveConnections = {}

    for _, objs in pairs(ESPObjects) do
        if objs.Highlight then objs.Highlight:Destroy() end
        if objs.Billboard then objs.Billboard:Destroy() end
    end
    ESPObjects = {}

    if CoreGui:FindFirstChild("TimeBombProHub") then
        CoreGui.TimeBombProHub:Destroy()
    end

    getgenv().TimeBombCleanup = nil
    getgenv().TimeBombLoaded = false
end

getgenv().TimeBombCleanup = Cleanup
getgenv().TimeBombLoaded = true

-- // 1. نظام الـ Noclip (المشي من ورا الجدران) \\ --
table.insert(ActiveConnections, RunService.Stepped:Connect(function()
    if not Settings.NoclipEnabled then return end
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end))

-- // 2. نظام السرعة الفائقة \\ --
table.insert(ActiveConnections, RunService.RenderStepped:Connect(function()
    if not Settings.SpeedBoostEnabled then return end
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if humanoid and rootPart and humanoid.MoveDirection.Magnitude > 0 then
            rootPart.CFrame = rootPart.CFrame + (humanoid.MoveDirection * (Settings.CustomSpeed / 50))
        end
    end
end))

-- // 3. كشف اللاعبين (ESP) \\ --
local function RemoveESP(char)
    if ESPObjects[char] then
        if ESPObjects[char].Highlight then ESPObjects[char].Highlight:Destroy() end
        if ESPObjects[char].Billboard then ESPObjects[char].Billboard:Destroy() end
        ESPObjects[char] = nil
    end
end

local function SetupESP(char)
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    RemoveESP(char)

    local head = char:WaitForChild("Head", 3)
    if not head then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "TimeBombHL"
    highlight.FillColor = Color3.fromRGB(0, 150, 255)
    highlight.FillTransparency = 0.6
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.Enabled = Settings.ESPEnabled
    highlight.Parent = char

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "TimeBombTag"
    billboard.Size = UDim2.new(0, 200, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = Settings.ESPEnabled
    billboard.Parent = head

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 13
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextStrokeTransparency = 0
    
    local player = Players:GetPlayerFromCharacter(char)
    textLabel.Text = player and player.Name or "لاعب"
    textLabel.Parent = billboard

    ESPObjects[char] = {Highlight = highlight, Billboard = billboard, Text = textLabel}

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        table.insert(ActiveConnections, humanoid.Died:Connect(function()
            RemoveESP(char)
        end))
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        if p.Character then SetupESP(p.Character) end
        table.insert(ActiveConnections, p.CharacterAdded:Connect(SetupESP))
    end
end
table.insert(ActiveConnections, Players.PlayerAdded:Connect(function(p)
    table.insert(ActiveConnections, p.CharacterAdded:Connect(SetupESP))
end))
table.insert(ActiveConnections, Players.PlayerRemoving:Connect(function(p)
    if p.Character then RemoveESP(p.Character) end
end))

-- // 4. المطاردة والتتبع الآلي \\ --
local function GetClosestTarget()
    local closestTarget = nil
    local shortestDist = math.huge
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myRoot = myChar.HumanoidRootPart

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health > 0 then
                local dist = (char.HumanoidRootPart.Position - myRoot.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closestTarget = char.HumanoidRootPart
                end
            end
        end
    end
    return closestTarget
end

table.insert(ActiveConnections, RunService.RenderStepped:Connect(function()
    if not Settings.AutoChaseEnabled then return end
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local humanoid = myChar:FindFirstChildOfClass("Humanoid")

    local targetRoot = GetClosestTarget()
    if targetRoot and humanoid then
        humanoid:MoveTo(targetRoot.Position)
        
        for char, objs in pairs(ESPObjects) do
            if char == targetRoot.Parent then
                objs.Highlight.FillColor = Color3.fromRGB(255, 50, 50)
                objs.Text.Text = "[ الهدف ]"
            else
                objs.Highlight.FillColor = Color3.fromRGB(0, 150, 255)
            end
        end
    end
end))

-- // 5. واجهة التحكم (GUI) \\ --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TimeBombProHub"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 280, 0, 310)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
TopBar.BorderSizePixel = 0
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "Time Bomb Ultimate Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 12
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(Cleanup)

local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, -20, 1, -55)
Content.Position = UDim2.new(0, 10, 0, 48)
Content.BackgroundTransparency = 1

local yPos = 5
local function BuildToggle(name, initState, callback)
    local btn = Instance.new("TextButton", Content)
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = initState and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(35, 35, 45)
    btn.Font = Enum.Font.GothamBold
    btn.Text = name .. (initState and ": ON" or ": OFF")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local active = initState
    btn.MouseButton1Click:Connect(function()
        active = not active
        callback(active)
        btn.Text = name .. (active and ": ON" or ": OFF")
        btn.BackgroundColor3 = active and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(35, 35, 45)
    end)
    yPos = yPos + 46
end

BuildToggle("المطاردة الآلية", Settings.AutoChaseEnabled, function(state)
    Settings.AutoChaseEnabled = state
end)

BuildToggle("مشاهدة من ورا الجدران (Noclip)", Settings.NoclipEnabled, function(state)
    Settings.NoclipEnabled = state
end)

BuildToggle("السرعة الخارقة (Speed)", Settings.SpeedBoostEnabled, function(state)
    Settings.SpeedBoostEnabled = state
end)

BuildToggle("كشف اللاعبين (ESP)", Settings.ESPEnabled, function(state)
    Settings.ESPEnabled = state
    for _, objs in pairs(ESPObjects) do
        if objs.Highlight then objs.Highlight.Enabled = state end
        if objs.Billboard then objs.Billboard.Enabled = state end
    end
end)
