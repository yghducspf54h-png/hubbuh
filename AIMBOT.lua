-- // ========================================== \\ --
-- //          تم الصنع بواسطة: المبجّل            \\ --
-- // ========================================== \\ --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // إعدادات النظام \\ --
local Settings = {
    Aimbot = false,
    FOVSize = 120,
    ESP = false,
    Names = false,
    Smoothness = 5 -- سرعة السلاسة (كل ما زاد الرقم صار أبطأ وأعمم، الأفضل بين 3 إلى 8)
}

local LockedTarget = nil -- لتثبيت الإيم على نفس اللاعب وما يحول فجأة

-- // إنشاء دائرة الـ FOV \\ --
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Transparency = 0.7
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false

-- // إزالة الواجهة القديمة إن وجدت \\ --
if PlayerGui:FindFirstChild("AlMubajjalUI") then 
    PlayerGui.AlMubajjalUI:Destroy() 
end

local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "AlMubajjalUI"
ScreenGui.ResetOnSpawn = false

-- // النافذة الرئيسية \\ --
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 320, 0, 380)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

-- // الشريط العلوي \\ --
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TopBar.BorderSizePixel = 0

local TopCorner = Instance.new("UICorner", TopBar)
TopCorner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "لوحة المبجّل - الميزات الكاملة"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

-- // وظائف الـ ESP (الجدران والأسماء) \\ --
local function SetupPlayerESP(player)
    if player == LocalPlayer then return end

    local function applyVisuals(char)
        local hl = char:FindFirstChild("AlMubajjalHL") or Instance.new("Highlight", char)
        hl.Name = "AlMubajjalHL"
        hl.FillColor = Color3.fromRGB(255, 0, 0)
        hl.FillTransparency = 0.5
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.OutlineTransparency = 0
        hl.Enabled = Settings.ESP

        local head = char:WaitForChild("Head", 5)
        if head then
            local bill = head:FindFirstChild("AlMubajjalName") or Instance.new("BillboardGui", head)
            bill.Name = "AlMubajjalName"
            bill.Size = UDim2.new(0, 100, 0, 50)
            bill.StudsOffset = Vector3.new(0, 2.5, 0)
            bill.AlwaysOnTop = true
            
            local txt = bill:FindFirstChild("NameText") or Instance.new("TextLabel", bill)
            txt.Name = "NameText"
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1
            txt.Font = Enum.Font.GothamBold
            txt.TextSize = 14
            txt.TextColor3 = Color3.fromRGB(255, 255, 255)
            txt.TextStrokeTransparency = 0
            txt.Text = player.Name
            bill.Enabled = Settings.Names
        end
    end

    player.CharacterAdded:Connect(applyVisuals)
    if player.Character then applyVisuals(player.Character) end
end

for _, p in ipairs(Players:GetPlayers()) do SetupPlayerESP(p) end
Players.PlayerAdded:Connect(SetupPlayerESP)

-- // بناء الأزرار والتحكم داخل الواجهة \\ --
local yOffset = 55

-- 1. زر تفعيل الإيم بوت
local AimbotBtn = Instance.new("TextButton", MainFrame)
AimbotBtn.Size = UDim2.new(0.9, 0, 0, 40)
AimbotBtn.Position = UDim2.new(0.05, 0, 0, yOffset)
AimbotBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
AimbotBtn.Font = Enum.Font.GothamBold
AimbotBtn.Text = "الإيم بوت: OFF"
AimbotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotBtn.TextSize = 13
Instance.new("UICorner", AimbotBtn).CornerRadius = UDim.new(0, 6)

AimbotBtn.MouseButton1Click:Connect(function()
    Settings.Aimbot = not Settings.Aimbot
    FOVCircle.Visible = Settings.Aimbot
    if not Settings.Aimbot then LockedTarget = nil end
    AimbotBtn.Text = "الإيم بوت: " .. (Settings.Aimbot and "ON" or "OFF")
    AimbotBtn.BackgroundColor3 = Settings.Aimbot and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(50, 50, 60)
end)

yOffset = yOffset + 50

-- 2. خانة تغيير حجم الـ FOV
local FovBox = Instance.new("TextBox", MainFrame)
FovBox.Size = UDim2.new(0.9, 0, 0, 40)
FovBox.Position = UDim2.new(0.05, 0, 0, yOffset)
FovBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
FovBox.Font = Enum.Font.GothamBold
FovBox.PlaceholderText = "حجم الـ FOV (الافتراضي: 120)"
FovBox.Text = "120"
FovBox.TextColor3 = Color3.fromRGB(255, 255, 255)
FovBox.TextSize = 13
Instance.new("UICorner", FovBox).CornerRadius = UDim.new(0, 6)

FovBox.FocusLost:Connect(function()
    local num = tonumber(FovBox.Text)
    if num then
        Settings.FOVSize = num
    else
        FovBox.Text = tostring(Settings.FOVSize)
    end
end)

yOffset = yOffset + 50

-- 3. زر تفعيل الشوف من ورا الجدران (ESP)
local EspBtn = Instance.new("TextButton", MainFrame)
EspBtn.Size = UDim2.new(0.9, 0, 0, 40)
EspBtn.Position = UDim2.new(0.05, 0, 0, yOffset)
EspBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
EspBtn.Font = Enum.Font.GothamBold
EspBtn.Text = "الشوف من ورا الجدران: OFF"
EspBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EspBtn.TextSize = 13
Instance.new("UICorner", EspBtn).CornerRadius = UDim.new(0, 6)

EspBtn.MouseButton1Click:Connect(function()
    Settings.ESP = not Settings.ESP
    EspBtn.Text = "الشوف من ورا الجدران: " .. (Settings.ESP and "ON" or "OFF")
    EspBtn.BackgroundColor3 = Settings.ESP and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(50, 50, 60)
end)

yOffset = yOffset + 50

-- 4. زر تفعيل الأسماء
local NamesBtn = Instance.new("TextButton", MainFrame)
NamesBtn.Size = UDim2.new(0.9, 0, 0, 40)
NamesBtn.Position = UDim2.new(0.05, 0, 0, yOffset)
NamesBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
NamesBtn.Font = Enum.Font.GothamBold
NamesBtn.Text = "أسماء اللاعبين: OFF"
NamesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
NamesBtn.TextSize = 13
Instance.new("UICorner", NamesBtn).CornerRadius = UDim.new(0, 6)

NamesBtn.MouseButton1Click:Connect(function()
    Settings.Names = not Settings.Names
    NamesBtn.Text = "أسماء اللاعبين: " .. (Settings.Names and "ON" or "OFF")
    NamesBtn.BackgroundColor3 = Settings.Names and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(50, 50, 60)
end)


-- // حلقة التحديث المستمرة للوظائف \\ --
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius = Settings.FOVSize

    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local hl = p.Character:FindFirstChild("AlMubajjalHL")
            if hl then hl.Enabled = Settings.ESP end

            local head = p.Character:FindFirstChild("Head")
            if head then
                local bill = head:FindFirstChild("AlMubajjalName")
                if bill then bill.Enabled = Settings.Names end
            end
        end
    end

    if Settings.Aimbot then
        -- التأكد من أن الهدف الحالي ما زال صالحاً (حي وموجود ضمن نطاق الرؤية)
        if LockedTarget and LockedTarget.Parent and LockedTarget.Parent:FindFirstChild("Humanoid") and LockedTarget.Parent.Humanoid.Health > 0 then
            local screenPos, onScreen = Camera:WorldToViewportPoint(LockedTarget.Position)
            local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            
            -- إذا طلع الهدف برا الـ FOV أو اختفى، فك القفل عنه
            if not onScreen or dist > Settings.FOVSize * 1.5 then
                LockedTarget = nil
            end
        else
            LockedTarget = nil
        end

        -- إذا ما فيه هدف مقفول، ابحث عن أقرب لاعب داخل الـ FOV واقفل عليه
        if not LockedTarget then
            local shortestDist = Settings.FOVSize
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    local head = p.Character.Head
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)

                    if onScreen then
                        local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                        if dist < shortestDist then
                            shortestDist = dist
                            LockedTarget = head
                        end
                    end
                end
            end
        end

        -- التوجيه بسلاسة وثبات نحو الهدف المقفول بدون تنطيط
        if LockedTarget then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, LockedTarget.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / Settings.Smoothness)
        end
    else
        LockedTarget = nil
    end
end)
