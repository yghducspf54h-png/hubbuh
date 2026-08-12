-- // ==================================================================== \\ --
-- //   Time Bomb  - almbjl UI Style & Auto-Give Bomb Engine ادري ياقفطة ماني مشفره \\ --
-- // ==================================================================== --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

if getgenv().TimeBombCleanup then
    getgenv().TimeBombCleanup()
end

local Settings = {
    AutoGiveBomb = true,         -- إعطاء القنبلة تلقائياً لأقرب لاعب
    TeamCheck = true,            -- تحقق التيم التلقائي (تجنب أعضاء فريقك)
    Noclip = true,               -- المشي من ورا الجدران
    SpeedEnabled = true,         -- سرعة خفية وصعبة الكشف
    CustomSpeed = 24,            -- سرعة متوازنة لتفادي البان
    FlyEnabled = false,          -- طيران خفي
    FlySpeed = 30,
    ESPEnabled = true            -- كشف الأماكن والتيمات
}

local ActiveConnections = {}
local ESPObjects = {}
local BodyVelocity, BodyGyro

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

    if CoreGui:FindFirstChild("almbjl TimeBomb") then
        CoreGui.almbjl TimeBomb:Destroy()
    end

    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        for _, child in ipairs(char.HumanoidRootPart:GetChildren()) do
            if child.Name == "PB_Velocity" or child.Name == "PB_Gyro" then
                child:Destroy()
            end
        end
    end

    getgenv().TimeBombCleanup = nil
    getgenv().TimeBombLoaded = false
end

getgenv().TimeBombCleanup = Cleanup
getgenv().TimeBombLoaded = true

-- // 1. نظام الـ Noclip الاحترافي \\ --
table.insert(ActiveConnections, RunService.Stepped:Connect(function()
    if not Settings.Noclip then return end
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end))

-- // 2. نظام السرعة المخفي (صعب الكشف) \\ --
table.insert(ActiveConnections, RunService.RenderStepped:Connect(function()
    if not Settings.SpeedEnabled then return end
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if humanoid and rootPart and humanoid.MoveDirection.Magnitude > 0 then
            rootPart.CFrame = rootPart.CFrame + (humanoid.MoveDirection * (Settings.CustomSpeed / 60))
        end
    end
end))

-- // 3. نظام الطيران المخفي \\ --
local function UpdateFly(state)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local rootPart = char.HumanoidRootPart
    
    if state then
        BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.Name = "PB_Velocity"
        BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        BodyVelocity.Parent = rootPart

        BodyGyro = Instance.new("BodyGyro")
        BodyGyro.Name = "PB_Gyro"
        BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        BodyGyro.CFrame = rootPart.CFrame
        BodyGyro.Parent = rootPart
    else
        if BodyVelocity then BodyVelocity:Destroy() end
        if BodyGyro then BodyGyro:Destroy() end
    end
end

table.insert(ActiveConnections, RunService.RenderStepped:Connect(function()
    if not Settings.FlyEnabled then return end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") and BodyVelocity and BodyGyro then
        local camera = Workspace.CurrentCamera
        local moveDir = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
        
        BodyVelocity.Velocity = moveDir * Settings.FlySpeed
        BodyGyro.CFrame = camera.CFrame
    end
end))

-- // 4. كشف التيمات والأشخاص (ESP) \\ --
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
    highlight.Name = "PB_HL"
    highlight.FillColor = Color3.fromRGB(0, 160, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.Enabled = Settings.ESPEnabled
    highlight.Parent = char

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PB_Tag"
    billboard.Size = UDim2.new(0, 200, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = Settings.ESPEnabled
    billboard.Parent = head

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 12
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

-- // 5. النظام الخارق: إعطاء القنبلة لأقرب لاعب مع تحقق تيم تلقائي \\ --
local function GetClosestValidTarget()
    local closestTarget = nil
    local shortestDist = math.huge
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myRoot = myChar.HumanoidRootPart

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- تحقق التيم التلقائي
            local isSameTeam = false
            if Settings.TeamCheck and LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then
                isSameTeam = true
            end

            if not isSameTeam then
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
    end
    return closestTarget
end

table.insert(ActiveConnections, RunService.RenderStepped:Connect(function()
    if not Settings.AutoGiveBomb then return end
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local humanoid = myChar:FindFirstChildOfClass("Humanoid")

    local targetRoot = GetClosestValidTarget()
    if targetRoot and humanoid then
        -- الانتقال الملصق بالهدف تماماً لتسليم القنبلة بلمسة واحدة
        humanoid:MoveTo(targetRoot.Position)
        
        for char, objs in pairs(ESPObjects) do
            if char == targetRoot.Parent then
                objs.Highlight.FillColor = Color3.fromRGB(255, 40, 40)
                objs.Text.Text = "[ هدف القنبلة الأساسي ]"
            else
                objs.Highlight.FillColor = Color3.fromRGB(0, 160, 255)
            end
        end
    end
end))

-- // 6. واجهة مستخدم مشابهة تماماً لـ almbjl \\ --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "almbjlTimeBomb"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 640, 0, 420)
MainFrame.Position = UDim2.new(0.5, -320, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- شريط علوي
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
TopBar.BorderSizePixel = 0
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "almbjl"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local SubTitle = Instance.new("TextLabel", TopBar)
SubTitle.Size = UDim2.new(0, 150, 1, 0)
SubTitle.Position = UDim2.new(0, 125, 0, 3)
SubTitle.Font = Enum.Font.Gotham
SubTitle.Text = "By_Cypher (TimeBomb Edition)"
SubTitle.TextColor3 = Color3.fromRGB(140, 140, 160)
SubTitle.TextSize = 10
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -16)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 13
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(Cleanup)

-- محتوى القائمة الجانبية والوسطى
local ContentPanel = Instance.new("Frame", MainFrame)
ContentPanel.Size = UDim2.new(1, -20, 1, -60)
ContentPanel.Position = UDim2.new(0, 10, 0, 52)
ContentPanel.BackgroundTransparency = 1

local yPos = 10
local function BuildToggleSetting(name, desc, initState, callback)
    local btn = Instance.new("TextButton", ContentPanel)
    btn.Size = UDim2.new(1, 0, 0, 52)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.AutoButtonColor = false
    btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Position = UDim2.new(0, 15, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local descLbl = Instance.new("TextLabel", btn)
    descLbl.Size = UDim2.new(0.7, 0, 0, 15)
    descLbl.Position = UDim2.new(0, 15, 0, 28)
    descLbl.BackgroundTransparency = 1
    descLbl.Font = Enum.Font.Gotham
    descLbl.Text = desc
    descLbl.TextColor3 = Color3.fromRGB(150, 150, 170)
    descLbl.TextSize = 10
    descLbl.TextXAlignment = Enum.TextXAlignment.Left

    local indicator = Instance.new("Frame", btn)
    indicator.Size = UDim2.new(0, 44, 0, 22)
    indicator.Position = UDim2.new(1, -56, 0.5, -11)
    indicator.BackgroundColor3 = initState and Color3.fromRGB(0, 160, 255) or Color3.fromRGB(50, 50, 65)
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

    local dot = Instance.new("Frame", indicator)
    dot.Size = UDim2.new(0, 18, 0, 18)
    dot.Position = initState and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local active = initState
    btn.MouseButton1Click:Connect(function()
        active = not active
        callback(active)
        indicator.BackgroundColor3 = active and Color3.fromRGB(0, 160, 255) or Color3.fromRGB(50, 50, 65)
        dot:TweenPosition(active and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
    end)

    yPos = yPos + 60
end

BuildToggleSetting("اعطاء القنبلة لأقرب لاعب تلقائياً", "يتوجه فوراً لأقرب عدو لتسليم القنبلة وتحقيق الفوز", Settings.AutoGiveBomb, function(state)
    Settings.AutoGiveBomb = state
end)

BuildToggleSetting("تحقق التيم التلقائي", "يتجاهل أعضاء فريقك تماماً ولا يستهدفهم", Settings.TeamCheck, function(state)
    Settings.TeamCheck = state
end)

BuildToggleSetting("تخطي الجدران (Noclip)", "يمكّنك من المشي والاختراق عبر الجدران والعوائق", Settings.Noclip, function(state)
    Settings.Noclip = state
end)

BuildToggleSetting("السرعة الخفية (Speed)", "سرعة خارقة ومتوازنة مصممة خصيصاً لتفادي كشف الحماية", Settings.SpeedEnabled, function(state)
    Settings.SpeedEnabled = state
end)

BuildToggleSetting("الطيران المخفي (Fly)", "تفعيل الطيران الحر للتحكم الكامل في الخريطة", Settings.FlyEnabled, function(state)
    Settings.FlyEnabled = state
    UpdateFly(state)
end)

BuildToggleSetting("كشف اللاعبين (ESP)", "إظهار أسماء وتحديدات اللاعبين عبر الأسطح", Settings.ESPEnabled, function(state)
    Settings.ESPEnabled = state
    for _, objs in pairs(ESPObjects) do
        if objs.Highlight then objs.Highlight.Enabled = state end
        if objs.Billboard then objs.Billboard.Enabled = state end
    end
end)
