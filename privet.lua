local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer

-- إحداثيات أو أسماء الأماكن والوظائف بناءً على خريطة ودليل BlockSpin
local JobLocations = {
    ["Burger Place (مطعم البرجر)"] = {Name = "Burger Place", Pos = Vector3.new(-50, 3, -20)},
    ["Butcher’s Cut (اللحام)"] = {Name = "Butcher’s Cut", Pos = Vector3.new(40, 3, 60)},
    ["Barbershop (الحلاق)"] = {Name = "Barbershop", Pos = Vector3.new(10, 3, 50)},
    ["Car Wash (غسيل السيارات)"] = {Name = "Car Wash", Pos = Vector3.new(20, 3, -10)},
    ["Gas Station (محطة الوقود)"] = {Name = "Gas Station", Pos = Vector3.new(0, 3, 0)},
    ["Pawn Shop (البون شوب)"] = {Name = "Pawn Shop", Pos = Vector3.new(-120, 3, -120)},
}

local selectedJob = "Burger Place (مطعم البرجر)"

-- ========================================================
-- بناء واجهة المستخدم (UI) مع قائمة اختيار الوظائف
-- ========================================================
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local ToggleButton = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")
local DropdownButton = Instance.new("TextButton")
local DropdownList = Instance.new("ScrollingFrame")

ScreenGui.Name = "BlockSpinJobHub"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
MainFrame.Size = UDim2.new(0, 240, 0, 190)
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

TitleLabel.Parent = MainFrame
TitleLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleLabel.Size = UDim2.new(1, 0, 0, 35)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = "BlockSpin Job Selector"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 15

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleLabel

-- زر اختيار الوظيفة
DropdownButton.Parent = MainFrame
DropdownButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
DropdownButton.Position = UDim2.new(0.08, 0, 0.25, 0)
DropdownButton.Size = UDim2.new(0, 200, 0, 30)
DropdownButton.Font = Enum.Font.SourceSans
DropdownButton.Text = "Job: Burger Place"
DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DropdownButton.TextSize = 13

-- قائمة الوظائف المنسدلة
DropdownList.Parent = MainFrame
DropdownList.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
DropdownList.Position = UDim2.new(0.08, 0, 0.42, 0)
DropdownList.Size = UDim2.new(0, 200, 0, 0) -- مخفية بالبداية
DropdownList.CanvasSize = UDim2.new(0, 0, 0, 200)
DropdownList.Visible = false
DropdownList.BorderSizePixel = 0

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = DropdownList
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

for jobName, data in pairs(JobLocations) do
    local optBtn = Instance.new("TextButton")
    optBtn.Parent = DropdownList
    optBtn.Size = UDim2.new(1, 0, 0, 30)
    optBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    optBtn.BorderSizePixel = 0
    optBtn.Font = Enum.Font.SourceSans
    optBtn.Text = jobName
    optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    optBtn.TextSize = 12
    
    optBtn.MouseButton1Click:Connect(function()
        selectedJob = jobName
        DropdownButton.Text = "Job: " .. data.Name
        DropdownList.Visible = false
        DropdownList.Size = UDim2.new(0, 200, 0, 0)
    end)
end

DropdownButton.MouseButton1Click:Connect(function()
    DropdownList.Visible = not DropdownList.Visible
    if DropdownList.Visible then
        DropdownList.Size = UDim2.new(0, 200, 0, 90)
    else
        DropdownList.Size = UDim2.new(0, 200, 0, 0)
    end
end)

-- زر التشغيل
ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
ToggleButton.Position = UDim2.new(0.08, 0, 0.68, 0)
ToggleButton.Size = UDim2.new(0, 200, 0, 32)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "Start Working"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 15

StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0.08, 0, 0.86, 0)
StatusLabel.Size = UDim2.new(0, 200, 0, 20)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.TextSize = 13

-- ========================================================
-- محرك تنفيذ الوظيفة المحددة
-- ========================================================
local FarmEngine = { Running = false }

function FarmEngine:Start()
    if self.Running then return end
    self.Running = true
    
    task.spawn(function()
        local path = PathfindingService:CreatePath({ AgentCanJump = true })

        while self.Running do
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local humanoid = char and char:FindFirstChild("Humanoid")
            
            if not hrp or not humanoid then
                task.wait(1)
                continue
            }
            
            local targetData = JobLocations[selectedJob]
            if targetData then
                StatusStatus = targetData.Name
                StatusLabel.Text = "Working at: " .. targetData.Name
                
                -- التوجه لموقع الوظيفة المختار بدقة عبر Pathfinding
                local success, err = pcall(function()
                    path:ComputeAsync(hrp.Position, targetData.Pos)
                end)
                
                if success and path.Status == Enum.PathStatus.Success then
                    for _, waypoint in ipairs(path:GetWaypoints()) do
                        if not self.Running then break end
                        humanoid:MoveTo(waypoint.Position)
                        if waypoint.Action == Enum.PathWaypointAction.Jump then
                            humanoid.Jump = true
                        end
                        humanoid.MoveFinished:Wait()
                    end
                else
                    humanoid:MoveTo(targetData.Pos)
                end
                
                -- محاكاة التفاعل مع الوظيفة بمكانها المخصص
                local targetObj = workspace:FindFirstChild(targetData.Name, true)
                if targetObj then
                    local prompt = targetObj:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt then
                        pcall(function() fireproximityprompt(prompt) end)
                    end
                end
            end
            
            task.wait(2)
        end
    end)
end

function FarmEngine:Stop()
    self.Running = false
    StatusLabel.Text = "Status: Stopped"
end

local isExecuting = false
ToggleButton.MouseButton1Click:Connect(function()
    isExecuting = not isExecuting
    if isExecuting then
        ToggleButton.Text = "Stop Working"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        FarmEngine:Start()
    else
        ToggleButton.Text = "Start Working"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
        FarmEngine:Stop()
    end
end)
