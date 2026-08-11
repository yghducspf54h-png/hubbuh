local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- إعدادات نظام BlockSpin الأساسية
local Settings = {
    ActiveFarm = false,
    CurrentJob = "None",
    ESPEnabled = false,
    AimbotEnabled = false,
    FOVSize = 130
}

local GUI_Name = HttpService:GenerateGUID(false)
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
if PlayerGui:FindFirstChild(GUI_Name) then PlayerGui[GUI_Name]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_Name
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 270, 0, 390)
MainFrame.Position = UDim2.new(0.03, 0, 0.18, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- عنوان الواجهة
local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, 0, 0.1, 0)
Header.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
Header.Text = "BLOCKSPIN - MAX JOB HUB"
Header.TextColor3 = Color3.fromRGB(255, 255, 255)
Header.TextSize, Header.Font = 12, Enum.Font.GothamBold
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

-- شاشة عرض الوظيفة النشطة حالياً
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0.07, 0)
StatusLabel.Position = UDim2.new(0.05, 0, 0.12, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Selected Job: None"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
StatusLabel.TextSize = 11
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.Parent = MainFrame

-- محرك التفاعل الفارم الذكي الخاص بـ BlockSpin
task.spawn(function()
    while true do
        if Settings.ActiveFarm and Settings.CurrentJob ~= "None" then
            pcall(function()
                for _, obj in pairs(workspace:GetDescendants()) do
                    local name = obj.Name:lower()
                    local matchTarget = false

                    if Settings.CurrentJob == "Cash & ATMs" and (name:find("atm") or name:find("cash") or name:find("register")) then
                        matchTarget = true
                    elseif Settings.CurrentJob == "Cases & Loot" and (name:find("case") or name:find("box") or name:find("drop")) then
                        matchTarget = true
                    elseif Settings.CurrentJob == "Jobs / Tasks" and (name:find("job") or name:find("work") or name:find("task") or name:find("clean")) then
                        matchTarget = true
                    end

                    if matchTarget then
                        if obj:FindFirstChild("ProximityPrompt") then
                            fireproximityprompt(obj.ProximityPrompt)
                        elseif obj:IsA("BasePart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 2, 0)
                        end
                    end
                end
            end)
        end
        task.wait(0.6)
    end
end)

-- دالة صناعة أزرار اختيار الوظائف
local function createJobButton(text, jobName, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0.08, 0)
    btn.Position = UDim2.new(0.05, 0, yPos, 0)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    btn.Text = text .. " : [OFF]"
    btn.TextColor3 = Color3.fromRGB(170, 170, 170)
    btn.TextSize, btn.Font = 11, Enum.Font.GothamMedium
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        if Settings.CurrentJob == jobName then
            -- إيقاف إذا كان هو المختار
            Settings.CurrentJob = "None"
            Settings.ActiveFarm = false
            btn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
            btn.TextColor3 = Color3.fromRGB(170, 170, 170)
            btn.Text = text .. " : [OFF]"
            StatusLabel.Text = "Selected Job: None"
        else
            Settings.CurrentJob = jobName
            Settings.ActiveFarm = true
            btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Text = text .. " : [ON]"
            StatusLabel.Text = "Selected Job: " .. jobName
        end
    end)
end

-- إنشاء أزرار الوظائف المحددة بدقة لماب BlockSpin
createJobButton("Farm: Cash & ATMs", "Cash & ATMs", 0.21)
createJobButton("Farm: Cases & Loot", "Cases & Loot", 0.31)
createJobButton("Farm: General Jobs", "Jobs / Tasks", 0.41)

-- أزرار إضافية للحماية والقتال (Aimbot & ESP)
local function createToggle(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0.08, 0)
    btn.Position = UDim2.new(0.05, 0, yPos, 0)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    btn.Text = text .. " : [OFF]"
    btn.TextColor3 = Color3.fromRGB(170, 170, 170)
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
            btn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
            btn.TextColor3 = Color3.fromRGB(170, 170, 170)
            btn.Text = text .. " : [OFF]"
        end
        callback(state)
    end)
end

createToggle("Combat Aimbot", 0.53, function(val)
    Settings.AimbotEnabled = val
end)

-- نظام التشغيل البصري للآيمبوت
RunService.RenderStepped:Connect(function()
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
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, closest.Character.Head.Position), 0.15)
        end
    end
end)

-- زر إغلاق الواجهة بالكامل
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0.9, 0, 0.08, 0)
CloseBtn.Position = UDim2.new(0.05, 0, 0.88, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(160, 35, 35)
CloseBtn.Text = "Close Menu"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize, CloseBtn.Font = 11, Enum.Font.GothamBold
CloseBtn.Parent = MainFrame

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
