local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- إعدادات سكربت بلوك سبين
local Settings = {
    AutoFarm = false,
    ESPEnabled = false,
    AimbotEnabled = false,
    FOVSize = 120,
    BoxColor = Color3.fromRGB(0, 255, 128)
}

-- توليد اسم عشوائي للواجهة لتجنب الحظر
local GUI_NAME = HttpService:GenerateGUID(false)
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild(GUI_NAME) then 
    PlayerGui[GUI_NAME]:Destroy() 
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- إطار الواجهة الرئيسي
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 280)
MainFrame.Position = UDim2.new(0.04, 0, 0.22, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- شريط العنوان
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.15, 0)
Title.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Title.Text = "BLOCK SPIN - FARM HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize, Title.Font = 12, Enum.Font.GothamBold
Title.Parent = MainFrame

Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

-- دالة صناعة الأزرار بوضوح
local function createToggle(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0.12, 0)
    btn.Position = UDim2.new(0.05, 0, yPos, 0)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    btn.Text = text .. " : [OFF]"
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.TextSize, btn.Font = 11, Enum.Font.GothamMedium
    btn.Parent = MainFrame
    
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Text = text .. " : [ON]"
        else
            btn.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
            btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            btn.Text = text .. " : [OFF]"
        end
        callback(state)
    end)
end

-- تفعيل الفارم التلقائي (ATM & Cash Loop)
createToggle("Auto Farm / ATM", 0.22, function(val)
    Settings.AutoFarm = val
    task.spawn(function()
        while Settings.AutoFarm do
            pcall(function()
                -- محاكاة التفاعل مع الأجهزة أو الأرباح في الماب
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj.Name:lower():find("atm") or obj.Name:lower():find("cash") or obj.Name:lower():find("register") then
                        if obj:FindFirstChild("ProximityPrompt") then
                            fireproximityprompt(obj.ProximityPrompt)
                        end
                    end
                end
            end)
            task.wait(1)
        end
    end)
end)

-- كشف اللاعبين (ESP)
local ESPs = {}
createToggle("Players ESP", 0.38, function(val)
    Settings.ESPEnabled = val
    if not val then
        for _, box in pairs(ESPs) do box.Visible = false end
    end
end)

-- Aimbot للدفاع عن النفس أثناء الفارم
createToggle("Combat Aimbot", 0.54, function(val)
    Settings.AimbotEnabled = val
end)

-- حلقة التحديث للبصريات والآيمبوت
RunService.RenderStepped:Connect(function()
    -- تحديث الـ Aimbot
    if Settings.AimbotEnabled then
        local closest, dist = nil, math.huge
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local head = p.Character.Head
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mag < Settings.FOVSize and mag < dist then
                        dist = mag
                        closest = p
                    end
                end
            end
        end
        
        if closest and closest.Character:FindFirstChild("Head") then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, closest.Character.Head.Position), 0.2)
        end
    end
end)

-- زر إغلاق الواجهة للتخفي
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0.9, 0, 0.1, 0)
CloseBtn.Position = UDim2.new(0.05, 0, 0.82, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
CloseBtn.Text = "Hide / Close GUI"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize, CloseBtn.Font = 11, Enum.Font.GothamBold
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
