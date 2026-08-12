-- // ========================================== \\ --
-- //          تم الصنع بواسطة: المبجّل            \\ --
-- // ========================================== \\ --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = game:GetService("Workspace").CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // إعدادات الميزات \\ --
local Settings = {
    Aimbot = false,
    FOVSize = 120,
    ESP = false,
    NameTags = false
}

-- // إنشاء الواجهة (GUI) \\ --
if PlayerGui:FindFirstChild("AlMubajjalUI") then PlayerGui.AlMubajjalUI:Destroy() end

local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "AlMubajjalUI"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 350)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)

-- // الدوال الوظيفية \\ --
local function CreateESP(player)
    local highlight = Instance.new("Highlight", player.Character)
    highlight.Name = "EspHighlight"
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.Enabled = Settings.ESP
end

-- // أزرار التفعيل \\ --
local function CreateToggle(name, settingKey, yPos)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.8, 0, 0, 40)
    btn.Position = UDim2.new(0.1, 0, 0, yPos)
    btn.Text = name .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    btn.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        btn.Text = name .. ": " .. (Settings[settingKey] and "ON" or "OFF")
        btn.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(50, 50, 60)
    end)
end

CreateToggle("إيم بوت", "Aimbot", 50)
CreateToggle("جدران (ESP)", "ESP", 100)
CreateToggle("الأسماء", "NameTags", 150)

-- // تحديثات مستمرة (Loop) \\ --
RunService.RenderStepped:Connect(function()
    -- وظيفة الايم بوت
    if Settings.Aimbot then
        -- (هنا يوضع كود البحث عن أقرب لاعب وتوجيه الكاميرا)
    end
    
    -- وظيفة ESP
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("EspHighlight") then
            p.Character.EspHighlight.Enabled = Settings.ESP
        end
    end
end)

-- إضافة إمكانية التحريك للواجهة (تم اختصارها للاختصار)
MainFrame.Active = true
MainFrame.Draggable = true
