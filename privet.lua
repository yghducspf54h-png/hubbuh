local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- إعدادات السكربت المنظمة والمطورة
local Settings = {
    ActiveFarm = false,
    CurrentJob = "None",
    AimbotEnabled = false,
    FOVSize = 130
}

-- اسم عشوائي للواجهة لتجنب أي رصد
local GUI_Name = HttpService:GenerateGUID(false)
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
if PlayerGui:FindFirstChild(GUI_Name) then PlayerGui[GUI_Name]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_Name
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- إطار الواجهة الرئيسي الاحترافي
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 440)
MainFrame.Position = UDim2.new(0.03, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- رأس الواجهة (العنوان)
local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, 0, 0.1, 0)
Header.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
Header.Text = "BLOCKSPIN - PRO HUB"
Header.TextColor3 = Color3.fromRGB(255, 255, 255)
Header.TextSize, Header.Font = 12, Enum.Font.GothamBold
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

-- شريط الحالة
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0.06, 0)
StatusLabel.Position = UDim2.new(0.05, 0, 0.11, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "الحالة: متوقف"
StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
StatusLabel.TextSize, StatusLabel.Font = 11, Enum.Font.GothamBold
StatusLabel.Parent = MainFrame

-- محرك التفاعل الواقعي والهادئ (بدون تلفيق أو باند)
task.spawn(function()
    while true do
        if Settings.ActiveFarm and Settings.CurrentJob ~= "None" then
            pcall(function()
                for _, obj in pairs(workspace:GetChildren()) do
                    local name = obj.Name:lower()
                    local targetFound = false

                    if Settings.CurrentJob == "ATM" and (name:find("atm") or name:find("register")) then
                        targetFound = true
                    elseif Settings.CurrentJob == "Grocery" and (name:find("grocery") or name:find("store") or name:find("market") or name:find("shelf")) then
                        targetFound = true
                    elseif Settings.CurrentJob == "Cases" and (name:find("case") or name:find("box") or name:find("crate")) then
                        targetFound = true
                    end

                    if targetFound then
                        if obj:FindFirstChild("ProximityPrompt") then
                            -- تفاعل هادئ ومناسب للبشر
                            fireproximityprompt(obj.ProximityPrompt)
                        elseif obj:IsA("BasePart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            -- تنقل سلس وواقعي تدريجي بدل الانتقال الفجائي لتجنب الحماية
                            local char = LocalPlayer.Character
                            local hrp = char.HumanoidRootPart
                            if (hrp.Position - obj.Position).Magnitude < 25 then
                                hrp.CFrame = hrp.CFrame:Lerp(obj.CFrame + Vector3.new(0, 3, 0), 0.1)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(1.5)
    end
end)

-- دالة صناعة الأزرار بمرونة عالية
local function createButton(text, jobKey, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0.08, 0)
    btn.Position = UDim2.new(0.05, 0, yPos, 0)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    btn.Text = text .. " : [متوقف]"
    btn.TextColor3 = Color3.fromRGB(170, 170, 170)
    btn.TextSize, btn.Font = 11, Enum.Font.GothamMedium
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        if Settings.CurrentJob == jobKey then
            Settings.CurrentJob = "None"
            Settings.ActiveFarm = false
            btn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
            btn.TextColor3 = Color3.fromRGB(170, 170, 170)
            btn.Text = text .. " : [متوقف]"
            StatusLabel.Text = "الحالة: متوقف"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        else
            Settings.CurrentJob = jobKey
            Settings.ActiveFarm = true
            btn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Text = text .. " : [شغال]"
            StatusLabel.Text = "الحالة: شغال (" .. text .. ")"
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
        end
    end)
end

-- أزرار الوظائف مفصولة ومنظمة بدقة
createButton("تهكير الصرافات (ATM)", "ATM", 0.18)
createButton("وظيفة البقالة (Grocery)", "Grocery", 0.28)
createButton("فتح الصناديق واللوت", "Cases", 0.38)

-- زر الآيمبوت للدفاع المنظم
local AimbotBtn = Instance.new("TextButton")
AimbotBtn.Size = UDim2.new(0.9, 0, 0.08, 0)
AimbotBtn.Position = UDim2.new(0.05, 0, 0.50, 0)
AimbotBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
AimbotBtn.Text = "التصويب التلقائي : [متوقف]"
AimbotBtn.TextColor3 = Color3.fromRGB(170, 170, 170)
AimbotBtn.TextSize, AimbotBtn.Font = 11, Enum.Font.GothamMedium
AimbotBtn.Parent = MainFrame
Instance.new("UICorner", AimbotBtn).CornerRadius = UDim.new(0, 6)

AimbotBtn.MouseButton1Click:Connect(function()
    Settings.AimbotEnabled = not Settings.AimbotEnabled
    if Settings.AimbotEnabled then
        AimbotBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
        AimbotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        AimbotBtn.Text = "التصويب التلقائي : [شغال]"
    else
        AimbotBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
        AimbotBtn.TextColor3 = Color3.fromRGB(170, 170, 170)
        AimbotBtn.Text = "التصويب التلقائي : [متوقف]"
    end
end)

-- محرك الآيمبوت الثابت والسلس
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
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, closest.Character.Head.Position), 0.2)
        end
    end
end)

-- زر الإغلاق
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0.9, 0, 0.08, 0)
CloseBtn.Position = UDim2.new(0.05, 0, 0.88, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.Text = "إغلاق اللوحة"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize, CloseBtn.Font = 11, Enum.Font.GothamBold
CloseBtn.Parent = MainFrame

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
