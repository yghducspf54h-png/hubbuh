-- // ====================================================== \\ --
-- //     نظام المبجّل الاحترافي - Aimbot & ESP المباشر       \\ --
-- // ====================================================== --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- إزالة أي نسخة سابقة منعاً للتكرار
if getgenv().AlMubajjalCleanup then
    getgenv().AlMubajjalCleanup()
end

local Settings = {
    AimbotEnabled = true,
    ESPEnabled = true,
    NamesEnabled = true,
    TeamCheck = false,
    FOVRadius = 300, -- حجم دائرة الـ FOV كبير لضمان التقاط الهدف
    TargetPart = "Head"
}

local ActiveConnections = {}
local ESPObjects = {}
local LockedTarget = nil -- لتثبيت الهدف وعدم انتقاله لشخص آخر أثناء التصويب

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

-- // 1. رسم دائرة الـ FOV مرئية على الشاشة \\ --
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

-- // 3. اختيار الهدف وتثبيته (عدم الانتقال لشخص آخر) \\ --
local function GetTarget()
    -- إذا كان هناك هدف مسجل مسبقاً وما زال حياً، ابق عليه لكي لا ينط الأيم لشخص آخر
    if LockedTarget and LockedTarget.Parent and LockedTarget.Parent:FindFirstChildOfClass("Humanoid") then
        if LockedTarget.Parent.Humanoid.Health > 0 then
            return LockedTarget
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

-- إعادة تعيين الهدف عند إفلات زر الماوس أو النقر بزر الفأرة الأيمن/الأيسر
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        LockedTarget = nil -- إعادة التثبيت عند الضغط للبحث عن هدف جديد بدقة
    end
end)

-- // 4. توجيه الطلقة بشكل كامل بغض النظر عن مكان الهدف (Raycast & Namecall Hook) \\ --
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if Settings.AimbotEnabled and method == "FireServer" then
        local target = GetTarget()
        if target then
            for i, v in ipairs(args) do
                if typeof(v) == "Vector3" then
                    -- توجيه أي إحداثيات إطلاق نار مباشرة نحو رأس أو جسم الهدف مهما كان بعيداً
                    args[i] = target.Position
                    break
                elseif typeof(v) == "Instance" and v:IsA("BasePart") then
                    args[i] = target
                    break
                end
            end
        end
    end

    return oldNamecall(self, unpack(args))
end)
setreadonly(mt, true)

-- // 5. واجهة المستخدم (GUI) للتحكم الكامل \\ --
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
local function AddBtn(text, callback)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Text = text
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    y = y + 42
end

AddBtn("تشغيل/إيقاف الإيم بوت: ON", function()
    Settings.AimbotEnabled = not Settings.AimbotEnabled
    UpdateFOVCircle()
end)

AddBtn("تشغيل/إيقاف الـ ESP: ON", function()
    Settings.ESPEnabled = not Settings.ESPEnabled
    for _, objs in pairs(ESPObjects) do
        if objs.Highlight then objs.Highlight.Enabled = Settings.ESPEnabled end
    end
end)

AddBtn("تشغيل/إيقاف الأسماء: ON", function()
    Settings.NamesEnabled = not Settings.NamesEnabled
    for _, objs in pairs(ESPObjects) do
        if objs.Billboard then objs.Billboard.Enabled = Settings.NamesEnabled end
    end
end)

-- تحكم بحجم الـ FOV عبر الزر
local FovBox = Instance.new("TextBox", Frame)
FovBox.Size = UDim2.new(0.9, 0, 0, 35)
FovBox.Position = UDim2.new(0.05, 0, 0, y)
FovBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
FovBox.Font = Enum.Font.GothamBold
FovBox.TextColor3 = Color3.fromRGB(255, 255, 255)
FovBox.TextSize = 12
FovBox.Text = "حجم دائرة FOV: " .. Settings.FOVRadius
Instance.new("UICorner", FovBox).CornerRadius = UDim.new(0, 6)

FovBox.FocusLost:Connect(function()
    local val = tonumber(FovBox.Text:match("%d+"))
    if val then
        Settings.FOVRadius = val
        FovBox.Text = "حجم دائرة FOV: " .. Settings.FOVRadius
        UpdateFOVCircle()
    else
        FovBox.Text = "حجم دائرة FOV: " .. Settings.FOVRadius
    end
end)
