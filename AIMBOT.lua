-- // ====================================================== \\ --
-- //     نظام المبجّل المعماري الاحترافي - الإصدار 10/10    \\ --
-- // ====================================================== --

-- 1. منع تشغيل أكثر من نسخة وتنظيف النسخة السابقة مسبقاً
if getgenv().AlMubajjalSystemLoaded then
    if getgenv().AlMubajjalCleanup then
        getgenv().AlMubajjalCleanup()
    end
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- // 1. وحدة الإعدادات الموحدة (Unified Settings) \\ --
local Settings = {
    SystemEnabled = true,
    TeamCheck = false,
    TargetPart = "Head",
    FOVRadius = 150,
    MinFOV = 30,
    MaxFOV = 400,
    ESPEnabled = false,
    NamesEnabled = false,
    AimbotEnabled = false,
    DebugMode = false -- نظام الـ Logging اختياري
}

-- نظام الـ Debug / Logging
local function Log(message, level)
    if not Settings.DebugMode then return end
    level = level or "INFO"
    print(string.format("[AlMubajjal Debug][%s]: %s", level, tostring(message)))
end

-- // 2. وحدة التخزين والاتصالات ودورة الحياة (Lifecycle & Cleanup) \\ --
local ActiveConnections = {}
local ESPObjects = {}
local OldNamecall = nil

local function CleanupSystem()
    Log("بدء عملية التنظيف الشامل وإيقاف النظام...", "WARNING")
    
    -- استعادة الـ Hook القديم لمنع تداخله
    if OldNamecall then
        local success, err = pcall(function()
            local mt = getrawmetatable(game)
            setreadonly(mt, false)
            mt.__namecall = OldNamecall
            setreadonly(mt, true)
        end)
        if success then Log("تمت استعادة الـ Metamethod بنجاح.") else Log("فشل استعادة الـ Metamethod: " .. tostring(err), "ERROR") end
    end

    for _, conn in ipairs(ActiveConnections) do
        if conn and conn.Connected then conn:Disconnect() end
    end
    ActiveConnections = {}

    for char, objs in pairs(ESPObjects) do
        if objs.Highlight then objs.Highlight:Destroy() end
        if objs.Billboard then objs.Billboard:Destroy() end
    end
    ESPObjects = {}

    if CoreGui:FindFirstChild("AlMubajjalHub") then
        CoreGui.AlMubajjalHub:Destroy()
    end

    getgenv().AlMubajjalSystemLoaded = false
    getgenv().AlMubajjalCleanup = nil
    Log("تم تنظيف النظام بالكامل وإخلاء الذاكرة.", "INFO")
end

getgenv().AlMubajjalCleanup = CleanupSystem
getgenv().AlMubajjalSystemLoaded = true

-- // 3. وحدة الـ ESP وإدارة الشخصية (Character & ESP Management) \\ --
local function RemoveESP(character)
    if ESPObjects[character] then
        if ESPObjects[character].Highlight then ESPObjects[character].Highlight:Destroy() end
        if ESPObjects[character].Billboard then ESPObjects[character].Billboard:Destroy() end
        ESPObjects[character] = nil
        Log("تم إزالة عناصر الـ ESP للشخصية.")
    end
end

local function SetupESP(character)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    RemoveESP(character)

    local head = character:WaitForChild("Head", 3)
    if not head then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "AlMubajjalHL"
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Enabled = Settings.SystemEnabled and Settings.ESPEnabled
    highlight.Parent = character

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "AlMubajjalName"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = Settings.SystemEnabled and Settings.NamesEnabled
    billboard.Parent = head

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 14
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextStrokeTransparency = 0
    
    local player = Players:GetPlayerFromCharacter(character)
    textLabel.Text = player and player.Name or "اللاعب"
    textLabel.Parent = billboard

    ESPObjects[character] = {Highlight = highlight, Billboard = billboard}

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local diedConn
        diedConn = humanoid.Died:Connect(function()
            RemoveESP(character)
            if diedConn then diedConn:Disconnect() end
        end)
        table.insert(ActiveConnections, diedConn)
    end
end

local function RefreshESPStates()
    for _, objs in pairs(ESPObjects) do
        if objs.Highlight then objs.Highlight.Enabled = Settings.SystemEnabled and Settings.ESPEnabled end
        if objs.Billboard then objs.Billboard.Enabled = Settings.SystemEnabled and Settings.NamesEnabled end
    end
end

-- // 4. وحدة الاستهداف مع الفلاتر المعمارية المستقلة (Targeting & Filters) \\ --
local Filters = {
    IsAlive = function(player, character)
        local hum = character:FindFirstChildOfClass("Humanoid")
        return hum and hum.Health > 0
    end,
    
    PassTeamCheck = function(player)
        if not Settings.TeamCheck then return true end
        return player.Team and LocalPlayer.Team and player.Team ~= LocalPlayer.Team
    end,
    
    HasRequiredParts = function(character)
        return character:FindFirstChild(Settings.TargetPart) and character:FindFirstChild("HumanoidRootPart")
    end
}

local function GetClosestTarget()
    if not Settings.SystemEnabled or not Settings.AimbotEnabled then return nil end
    
    local closestTarget = nil
    local shortestDist = Settings.FOVRadius
    local currentCamera = workspace.CurrentCamera
    if not currentCamera then return nil end

    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char and Filters.PassTeamCheck(player) and Filters.IsAlive(player, char) and Filters.HasRequiredParts(char) then
                local targetPart = char[Settings.TargetPart]
                local screenPos, onScreen = currentCamera:WorldToViewportPoint(targetPart.Position)
                
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closestTarget = targetPart
                    end
                end
            end
        end
    end
    return closestTarget
end

-- // 5. وحدة التحكم المركزية (Controller API) \\ --
local Controller = {}

function Controller.ToggleSystem(state)
    Settings.SystemEnabled = state
    RefreshESPStates()
    Log("حالة النظام العامة: " .. tostring(state))
end

function Controller.ToggleESP(state)
    Settings.ESPEnabled = state
    RefreshESPStates()
end

function Controller.ToggleNames(state)
    Settings.NamesEnabled = state
    RefreshESPStates()
end

function Controller.ToggleAimbot(state)
    Settings.AimbotEnabled = state
end

function Controller.ToggleTeamCheck(state)
    Settings.TeamCheck = state
end

function Controller.SetFOV(value)
    Settings.FOVRadius = math.clamp(value, Settings.MinFOV, Settings.MaxFOV)
    return Settings.FOVRadius
end

-- // 6. واجهة المستخدم المنفصلة (Modern GUI Architecture) \\ --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AlMubajjalHub"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 420)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- شريط العنوان والتحكم بالتصغير وإغلاق النافذة
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
TopBar.BorderSizePixel = 0
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "لوحة المبجّل الاحترافية 10/10"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 12
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(CleanupSystem)

local Content = Instance.new("ScrollingFrame", MainFrame)
Content.Size = UDim2.new(1, -20, 1, -55)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1
Content.CanvasSize = UDim2.new(0, 0, 0, 380)
Content.ScrollBarThickness = 3

local yPos = 10
local function BuildToggle(name, callback)
    local btn = Instance.new("TextButton", Content)
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.Font = Enum.Font.GothamBold
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        callback(active)
        btn.Text = name .. ": " .. (active and "ON" or "OFF")
        btn.BackgroundColor3 = active and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(40, 40, 50)
    end)
    yPos = yPos + 46
end

BuildToggle("حالة النظام الأساسية (System)", Controller.ToggleSystem)
BuildToggle("الإيم بوت الصامت (Silent Aim)", Controller.ToggleAimbot)
BuildToggle("الشوف من ورا الجدران (ESP)", Controller.ToggleESP)
BuildToggle("عرض أسماء اللاعبين", Controller.ToggleNames)
BuildToggle("فلترة الفريق (Team Check)", Controller.ToggleTeamCheck)

local FovLabel = Instance.new("TextLabel", Content)
FovLabel.Size = UDim2.new(1, 0, 0, 20)
FovLabel.Position = UDim2.new(0, 0, 0, yPos)
FovLabel.Font = Enum.Font.GothamSemibold
FovLabel.Text = "حجم دائرة الـ FOV: " .. Settings.FOVRadius
FovLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
FovLabel.TextSize = 12
FovLabel.TextXAlignment = Enum.TextXAlignment.Left
FovLabel.BackgroundTransparency = 1
yPos = yPos + 22

local FovBox = Instance.new("TextBox", Content)
FovBox.Size = UDim2.new(1, 0, 0, 35)
FovBox.Position = UDim2.new(0, 0, 0, yPos)
FovBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
FovBox.Font = Enum.Font.GothamBold
FovBox.Text = tostring(Settings.FOVRadius)
FovBox.TextColor3 = Color3.fromRGB(255, 255, 255)
FovBox.TextSize = 12
Instance.new("UICorner", FovBox).CornerRadius = UDim.new(0, 6)

FovBox.FocusLost:Connect(function()
    local num = tonumber(FovBox.Text)
    if num then
        local validNum = Controller.SetFOV(num)
        FovBox.Text = tostring(validNum)
        FovLabel.Text = "حجم دائرة الـ FOV: " .. validNum
    else
        FovBox.Text = tostring(Settings.FOVRadius)
    end
end)

-- // 7. معالجة ارتباطات اللاعبين ديناميكياً \\ --
local function InitPlayer(player)
    if player == LocalPlayer then return end
    local charConn = player.CharacterAdded:Connect(SetupESP)
    table.insert(ActiveConnections, charConn)
    if player.Character then SetupESP(player.Character) end
end

for _, p in ipairs(Players:GetPlayers()) do InitPlayer(p) end
table.insert(ActiveConnections, Players.PlayerAdded:Connect(InitPlayer))
table.insert(ActiveConnections, Players.PlayerRemoving:Connect(function(p)
    if p.Character then RemoveESP(p.Character) end
end))

-- // 8. تأمين الـ Hook الصامت وإدارته بشكل آمن \\ --
local mt = getrawmetatable(game)
OldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if Settings.SystemEnabled and Settings.AimbotEnabled and method == "FireServer" then
        if type(args[1]) == "string" and (args[1]:lower():find("shoot") or args[1]:lower():find("fire")) then
            local targetPart = GetClosestTarget()
            if targetPart then
                for i, v in ipairs(args) do
                    if typeof(v) == "Vector3" then
                        args[i] = targetPart.Position
                        break
                    end
                end
            end
        end
    end
    
    return OldNamecall(self, unpack(args))
end)
setreadonly(mt, true)
Log("تم تحميل النظام المعماري بنجاح تامن.")
