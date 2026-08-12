-- // ====================================================== \\ --
-- //     نظام المبجّل المعماري - Camera Aimbot & ESP         \\ --
-- // ====================================================== --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

if getgenv().AlMubajjalCleanup then
    getgenv().AlMubajjalCleanup()
end

local Settings = {
    AimbotEnabled = false,
    ESPEnabled = true,
    NamesEnabled = true,
    TeamCheck = false,
    FOVRadius = 150,
    Smoothness = 4, -- سرعة سلاسة الإيم بوت
    TargetPart = "Head"
}

local ActiveConnections = {}
local ESPObjects = {}
local LockedTarget = nil

local function Cleanup()
    for _, conn in ipairs(ActiveConnections) do conn:Disconnect() end
    for _, objs in pairs(ESPObjects) do
        if objs.Highlight then objs.Highlight:Destroy() end
        if objs.Billboard then objs.Billboard:Destroy() end
    end
    if CoreGui:FindFirstChild("AlMubajjalHub") then CoreGui.AlMubajjalHub:Destroy() end
    if CoreGui:FindFirstChild("FOV_Drawing") then CoreGui.FOV_Drawing:Destroy() end
    getgenv().AlMubajjalCleanup = nil
end
getgenv().AlMubajjalCleanup = Cleanup

-- // 1. دائرة الـ FOV المرئية \\ --
local FOVGui = Instance.new("ScreenGui", CoreGui)
FOVGui.Name = "FOV_Drawing"
local FOVFrame = Instance.new("Frame", FOVGui)
FOVFrame.BackgroundTransparency = 1
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
local FOVStroke = Instance.new("UIStroke", FOVFrame)
FOVStroke.Color = Color3.fromRGB(255, 255, 255)
FOVStroke.Thickness = 1.5
local FOVCorner = Instance.new("UICorner", FOVFrame)
FOVCorner.CornerRadius = UDim.new(1, 0)

local function UpdateFOVCircle()
    FOVFrame.Size = UDim2.new(0, Settings.FOVRadius * 2, 0, Settings.FOVRadius * 2)
    FOVFrame.Visible = Settings.AimbotEnabled
end
UpdateFOVCircle()

-- // 2. نظام الـ ESP والأسماء \\ --
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

    local hl = Instance.new("Highlight", char)
    hl.Name = "EspHL"
    hl.FillColor = Color3.fromRGB(255, 0, 0)
    hl.FillTransparency = 0.5
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.Enabled = Settings.ESPEnabled

    local bb = Instance.new("BillboardGui", head)
    bb.Name = "NameTag"
    bb.Size = UDim2.new(0, 200, 0, 50)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = true
    bb.Enabled = Settings.NamesEnabled

    local txt = Instance.new("TextLabel", bb)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 14
    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
    txt.TextStrokeTransparency = 0
    local p = Players:GetPlayerFromCharacter(char)
    txt.Text = p and p.Name or "اللاعب"

    ESPObjects[char] = {Highlight = hl, Billboard = bb}

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        table.insert(ActiveConnections, hum.Died:Connect(function() RemoveESP(char) end))
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
end)))

-- // 3. اختيار الهدف الثابت داخل الـ FOV \\ --
local function GetClosestTarget()
    if LockedTarget and LockedTarget.Parent and LockedTarget.Parent:FindFirstChildOfClass("Humanoid") then
        if LockedTarget.Parent.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(LockedTarget.Position)
            local mousePos = UserInputService:GetMouseLocation()
            if onScreen and (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude <= Settings.FOVRadius * 1.5 then
                return LockedTarget
            end
        end
    end

    local closest = nil
    local shortestDist = Settings.FOVRadius
    local mousePos = UserInputService:GetMouseLocation()

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if not Settings.TeamCheck or (p.Team ~= LocalPlayer.Team) then
                local char = p.Character
                if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    local part = char:FindFirstChild(Settings.TargetPart) or char:FindFirstChild("HumanoidRootPart")
                    if part then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            if dist < shortestDist then
                                shortestDist = dist
                                closest = part
                            end
                        end
                    end
                end
            end
        end
    end

    LockedTarget = closest
    return LockedTarget
end

-- // 4. حلقة التوجيه السلس للكاميرا \\ --
table.insert(ActiveConnections, RunService.RenderStepped:Connect(function()
    if Settings.AimbotEnabled then
        local target = GetClosestTarget()
        if target then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / Settings.Smoothness)
        end
    else
        LockedTarget = nil
    end
end))

-- // 5. واجهة المستخدم (GUI) المنظمة \\ --
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "AlMubajjalHub"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 260, 0, 310)
Frame.Position = UDim2.new(0.05, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "لوحة التحكم - Aimbot & ESP"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

local y = 50
local function AddBtn(text, initState, callback)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = initState and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(40, 40, 50)
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Text = text .. (initState and ": ON" or ": OFF")
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        local state = callback()
        btn.Text = text .. (state and ": ON" or ": OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(40, 40, 50)
    end)
    y = y + 42
end

AddBtn("الإيم بوت", Settings.AimbotEnabled, function()
    Settings.AimbotEnabled = not Settings.AimbotEnabled
    UpdateFOVCircle()
    return Settings.AimbotEnabled
end)

AddBtn("الـ ESP", Settings.ESPEnabled, function()
    Settings.ESPEnabled = not Settings.ESPEnabled
    for _, objs in pairs(ESPObjects) do
        if objs.Highlight then objs.Highlight.Enabled = Settings.ESPEnabled end
    end
    return Settings.ESPEnabled
end)

AddBtn("الأسماء", Settings.NamesEnabled, function()
    Settings.NamesEnabled = not Settings.NamesEnabled
    for _, objs in pairs(ESPObjects) do
        if objs.Billboard then objs.Billboard.Enabled = Settings.NamesEnabled end
    end
    return Settings.NamesEnabled
end)

local FovBox = Instance.new("TextBox", Frame)
FovBox.Size = UDim2.new(0.9, 0, 0, 35)
FovBox.Position = UDim2.new(0.05, 0, 0, y)
FovBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
FovBox.Font = Enum.Font.GothamBold
FovBox.TextColor3 = Color3.fromRGB(255, 255, 255)
FovBox.TextSize = 12
FovBox.Text = tostring(Settings.FOVRadius)
FovBox.PlaceholderText = "حجم الـ FOV"
Instance.new("UICorner", FovBox).CornerRadius = UDim.new(0, 6)

FovBox.FocusLost:Connect(function()
    local val = tonumber(FovBox.Text)
    if val then
        Settings.FOVRadius = val
        UpdateFOVCircle()
    else
        FovBox.Text = tostring(Settings.FOVRadius)
    end
end)
