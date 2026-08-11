local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- إعدادات السكربت الشاملة
local Settings = {
    ActiveFarm = false,
    CurrentJob = "None",
    ESPEnabled = false,
    AimbotEnabled = false,
    FOVSize = 130
}

-- اسم عشوائي للواجهة لتجنب الحظر
local GUI_Name = HttpService:GenerateGUID(false)
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
if PlayerGui:FindFirstChild(GUI_Name) then PlayerGui[GUI_Name]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_Name
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- إطار الواجهة الرئيسي
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 420)
MainFrame.Position = UDim2.new(0.03, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- رأس الواجهة (العنوان)
local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, 0, 0.1, 0)
Header.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
Header.Text = "لوحة تحكم بلوك سبين الاحترافية"
Header.TextColor3 = Color3.fromRGB(255, 255, 255)
Header.TextSize, Header.Font = 13, Enum.Font.GothamBold
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

-- شريط حالة الوظيفة النشطة
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0.07, 0)
StatusLabel.Position = UDim2.new(0.05, 0, 0.11, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "الوظيفة الحالية: معطل"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
StatusLabel.TextSize, StatusLabel.Font = 11, Enum.Font.GothamBold
StatusLabel.Parent = MainFrame

-- محرك الفارم والتفاعل التلقائي مع جميع الوظائف
task.spawn(function()
    while true do
        if Settings.ActiveFarm and Settings.CurrentJob ~= "None" then
            pcall(function()
                for _, obj in pairs(workspace:GetDescendants()) do
                    local name = obj.Name:lower()
                    local matchTarget = false

                    if Settings.CurrentJob == "Cash" and (name:find("atm") or name:find("cash") or name:find("register") or name:find("money")) then
                        matchTarget = true
                    elseif Settings.CurrentJob == "Cases" and (name:find("case") or name:find("box") or name:find("drop") or name:find("crate")) then
                        matchTarget = true
                    elseif Settings.CurrentJob == "Jobs" and (name:find("job") or name:find("work") or name:find("task") or name:find("shift")) then
                        matchTarget = true
                    elseif Settings.CurrentJob == "All" then
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
        task.wait(0.5)
    end
end)

-- دالة لإنشاء أزرار الوظائف باللغة العربية
local function createJobButton(arabicText, jobName, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0.075, 0)
    btn.Position = UDim2.new(0.05, 0, yPos, 0)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.Text = arabicText .. " : [متوقف]"
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.TextSize, btn.Font = 11, Enum.Font.GothamMedium
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        if Settings.CurrentJob == jobName then
            Settings.CurrentJob = "None"
            Settings.ActiveFarm = false
            btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            btn.Text = arabicText .. " : [متوقف]"
            StatusLabel.Text = "الوظيفة الحالية: معطل"
        else
            Settings.CurrentJob = jobName
            Settings.ActiveFarm = true
            btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Text = arabicText .. " : [شغال]"
            StatusLabel.Text = "الوظيفة: " .. arabicText
        end
    end)
end

-- إضافة أزرار الوظائف الشاملة
createJobButton("فارم الكاش وصرافات الـ ATM", "Cash", 0.19)
createJobButton("فتح الصناديق واللوت (Cases)", "Cases", 0.28)
createJobButton("إنجاز المهام والوظائف العامة", "Jobs", 0.37)
createJobButton("فارم شامل (كل شيء في الماب)", "All", 0.46)

-- دالة الأزرار الإضافية (مثل الآيمبوت)
local function createToggle(arabicText, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0.075, 0)
    btn.Position = UDim2.new(0.05, 0, yPos, 0)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.Text = arabicText .. " : [متوقف]"
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
            btn.Text = arabicText .. " : [شغال]"
        else
            btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            btn.Text = arabicText .. " : [متوقف]"
        end
        callback(state)
    end)
end

-- تفعيل الآيمبوت التلقائي للدفاع
createToggle("التصويب التلقائي (Aimbot)", 0.58, function(val)
    Settings.AimbotEnabled = val
end)

-- نظام عمل الآيمبوت الذكي
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
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.Text = "إغلاق اللوحة بالكامل"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize, CloseBtn.Font = 11, Enum.Font.GothamBold
CloseBtn.Parent = MainFrame

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
