local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- إعدادات السكربت الشامل لماب BlockSpin
local Config = {
    SelectedJob = "None", -- الوظيفة المختارة
    ActiveFarm = false,
    ESPEnabled = false,
    AimbotEnabled = false,
    FOVSize = 130
}

-- واجهة تحكم مخفية وعشوائية لمنع الحماية
local GUI_Name = HttpService:GenerateGUID(false)
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
if PlayerGui:FindFirstChild(GUI_Name) then PlayerGui[GUI_Name]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_Name
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 360)
MainFrame.Position = UDim2.new(0.03, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- رأس الواجهة
local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, 0, 0.12, 0)
Header.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
Header.Text = "BLOCKSPIN - ULTIMATE HUB"
Header.TextColor3 = Color3.fromRGB(255, 255, 255)
Header.TextSize, Header.Font = 12, Enum.Font.GothamBold
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

-- دالة إنشاء أزرار الوظائف والفارم
local function createButton(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0.09, 0)
    btn.Position = UDim2.new(0.05, 0, yPos, 0)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.TextSize, btn.Font = 11, Enum.Font.GothamMedium
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        if active then
            btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
            btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        callback(active, btn)
    end)
    return btn
end

-- عرض حالة الوظيفة الحالية
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0.08, 0)
StatusLabel.Position = UDim2.new(0.05, 0, 0.14, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Active Job: None"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
StatusLabel.TextSize = 11
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.Parent = MainFrame

-- محرك التفاعل التلقائي مع الوظائف والفلوس في الماب
task.spawn(function()
    while true do
        if Config.ActiveFarm and Config.SelectedJob ~= "None" then
            pcall(function()
                for _, obj in pairs(workspace:GetDescendants()) do
                    local name = obj.Name:lower()
                    -- البحث عن الأهداف بناءً على الوظيفة المحددة
                    local targetFound = false
                    
                    if Config.SelectedJob == "Jobs / Cash Farm" and (name:find("job") or name:find("cash") or name:find("register") or name:find("atm")) then
                        targetFound = true
                    elseif Config.SelectedJob == "Boxes / Loot" and (name:find("case") or name:find("box") or name:find("drop")) then
                        targetFound = true
                    end
                    
                    if targetFound then
                        if obj:FindFirstChild("ProximityPrompt") then
                            fireproximityprompt(obj.ProximityPrompt)
                        elseif obj:IsA("BasePart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            -- انتقال سريع أو تفاعل مباشر إذا أتيح
                            LocalPlayer.Character.HumanoidRootPart.CFrame = obj.CFrame
                        end
                    end
                end
            end)
        end
        task.wait(0.8)
    end
end)

-- أزرار تحديد نوع الفارم والوظيفة
createButton("Job: General Cash / ATMs", 0.23, function(state, btn)
    if state then
        Config.SelectedJob = "Jobs / Cash Farm"
        Config.ActiveFarm = true
        StatusLabel.Text = "Active Job: Cash & ATMs"
    else
        Config.SelectedJob = "None"
        Config.ActiveFarm = false
        StatusLabel.Text = "Active Job: None"
    end
end)

createButton("Job: Cases & Loot Boxes", 0.33, function(state, btn)
    if state then
        Config.SelectedJob = "Boxes / Loot"
        Config.ActiveFarm = true
        StatusLabel.Text = "Active Job: Cases & Loot"
    else
        Config.SelectedJob = "None"
        Config.ActiveFarm = false
        StatusLabel.Text = "Active Job: None"
    end
end)

-- ميزة الـ ESP لكشف اللاعبين والمخاطر في الماب
createButton("Players ESP (Safe Guard)", 0.45, function(state)
    Config.ESPEnabled = state
end)

-- ميزة الـ Aimbot للدفاع عن النفس ضد العصابات واللاعبين الآخرين
createButton("Combat Aimbot (Lock)", 0.55, function(state)
    Config.AimbotEnabled = state
end)

-- حلقة التشغيل البصري والتصويب
RunService.RenderStepped:Connect(function()
    if Config.AimbotEnabled then
        local closest, dist = nil, math.huge
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local head = p.Character.Head
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mag < Config.FOVSize and mag < dist then
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

-- زر إغلاق الواجهة
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0.9, 0, 0.08, 0)
CloseBtn.Position = UDim2.new(0.05, 0, 0.88, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(160, 30, 30)
CloseBtn.Text = "Close Menu"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize, CloseBtn.Font = 11, Enum.Font.GothamBold
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
