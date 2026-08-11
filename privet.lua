local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- إزالة الواجهة القديمة لمنع التكرار
if CoreGui:FindFirstChild("BlockSpinHubGui") then
    CoreGui.BlockSpinHubGui:Destroy()
end

-- بناء الواجهة الرئيسية
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BlockSpinHubGui"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
MainFrame.Size = UDim2.new(0, 450, 0, 300)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BorderSizePixel = 0

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = TopBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0.03, 0, 0, 0)
TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = "BlockSpin Ultimate Hub"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopBar
CloseBtn.BackgroundColor3 = Color3.fromRGB(230, 50, 50)
CloseBtn.Position = UDim2.new(1, -30, 0.15, 0)
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local TabBar = Instance.new("Frame")
TabBar.Parent = MainFrame
TabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
TabBar.Position = UDim2.new(0, 0, 0, 35)
TabBar.Size = UDim2.new(0, 120, 1, -35)
TabBar.BorderSizePixel = 0

local Container = Instance.new("Frame")
Container.Parent = MainFrame
Container.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Container.Position = UDim2.new(0, 120, 0, 35)
Container.Size = UDim2.new(1, -120, 1, -35)
Container.BorderSizePixel = 0

local GroceryTabContent = Instance.new("ScrollingFrame")
GroceryTabContent.Parent = Container
GroceryTabContent.BackgroundTransparency = 1
GroceryTabContent.Size = UDim2.new(1, 0, 1, 0)
GroceryTabContent.CanvasSize = UDim2.new(0, 0, 0, 300)
GroceryTabContent.Visible = true
GroceryTabContent.BorderSizePixel = 0

local GroceryTabBtn = Instance.new("TextButton")
GroceryTabBtn.Parent = TabBar
GroceryTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
GroceryTabBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
GroceryTabBtn.Size = UDim2.new(0.9, 0, 0, 35)
GroceryTabBtn.Font = Enum.Font.SourceSansBold
GroceryTabBtn.Text = "البقالة (Stocker)"
GroceryTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GroceryTabBtn.TextSize = 13

local GCorner = Instance.new("UICorner")
GCorner.CornerRadius = UDim.new(0, 6)
GCorner.Parent = GroceryTabBtn

local GroceryTitle = Instance.new("TextLabel")
GroceryTitle.Parent = GroceryTabContent
GroceryTitle.BackgroundTransparency = 1
GroceryTitle.Position = UDim2.new(0.05, 0, 0.05, 0)
GroceryTitle.Size = UDim2.new(0.9, 0, 0, 30)
GroceryTitle.Font = Enum.Font.SourceSansBold
GroceryTitle.Text = "أتمتة وظيفة الصناديق (البقالة)"
GroceryTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
GroceryTitle.TextSize = 14
GroceryTitle.TextXAlignment = Enum.TextXAlignment.Left

local GroceryToggle = Instance.new("TextButton")
GroceryToggle.Parent = GroceryTabContent
GroceryToggle.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
GroceryToggle.Position = UDim2.new(0.05, 0, 0.2, 0)
GroceryToggle.Size = UDim2.new(0.9, 0, 0, 38)
GroceryToggle.Font = Enum.Font.SourceSansBold
GroceryToggle.Text = "تشغيل فارم البقالة: متوقف"
GroceryToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
GroceryToggle.TextSize = 14

local GTCorner = Instance.new("UICorner")
GTCorner.CornerRadius = UDim.new(0, 6)
GTCorner.Parent = GroceryToggle

local StatusDesc = Instance.new("TextLabel")
StatusDesc.Parent = GroceryTabContent
StatusDesc.BackgroundTransparency = 1
StatusDesc.Position = UDim2.new(0.05, 0, 0.38, 0)
StatusDesc.Size = UDim2.new(0.9, 0, 0, 50)
StatusDesc.Font = Enum.Font.SourceSans
StatusDesc.Text = "الحالة: جاهز للتشغيل"
StatusDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusDesc.TextSize = 12
StatusDesc.TextWrapped = true
StatusDesc.TextXAlignment = Enum.TextXAlignment.Left

-- نظام تشغيل الفارم البرمجي المربوط بالزر
local groceryRunning = false

GroceryToggle.MouseButton1Click:Connect(function()
    groceryRunning = not groceryRunning
    
    if groceryRunning then
        GroceryToggle.Text = "تشغيل فارم البقالة: شغال"
        GroceryToggle.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        StatusDesc.Text = "الحالة: يعمل (يتم أخذ الوظيفة، حمل الصندوق، والتوصيل تلقائياً)"
        
        -- حلقة التنفيذ (Farm Loop)
        task.spawn(function()
            while groceryRunning do
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local humanoid = char and char:FindFirstChild("Humanoid")
                
                if not hrp or not humanoid then
                    task.wait(1)
                    continue
                end
                
                -- الخطوة 1: التقديم على الوظيفة إذا ظهر البرومبت الخاص بها
                local promptApply = workspace:FindFirstChild("Apply", true)
                if promptApply and promptApply:IsA("ProximityPrompt") then
                    if (promptApply.Parent.Position - hrp.Position).Magnitude < 25 then
                        humanoid:MoveTo(promptApply.Parent.Position)
                        task.wait(0.5)
                        pcall(function() fireproximityprompt(promptApply) end)
                    end
                end
                
                -- الخطوة 2: فحص هل الشخصية حاملة لصندوق أم لا
                local carryingBox = char:FindFirstChild("Box") or LocalPlayer.Backpack:FindFirstChild("Box")
                
                if not carryingBox then
                    -- البحث عن صندوق والتقاطه
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if not groceryRunning then break end
                        if obj:IsA("ProximityPrompt") and (obj.ActionText:lower():find("pick") or obj.ObjectText:lower():find("box")) then
                            if obj.Parent and (obj.Parent.Position - hrp.Position).Magnitude < 30 then
                                humanoid:MoveTo(obj.Parent.Position)
                                task.wait(0.5)
                                pcall(function() fireproximityprompt(obj) end)
                                task.wait(1)
                                break
                            end
                        end
                    end
                else
                    -- الخطوة 3: التوجه نحو السهم أو هدف التوصيل
                    local targetIndicator = workspace:FindFirstChild("Arrow") or workspace:FindFirstChild("TargetShelf", true)
                    
                    if targetIndicator then
                        local targetPos = targetIndicator.Position or (targetIndicator.PrimaryPart and targetIndicator.PrimaryPart.Position)
                        if targetPos then
                            humanoid:MoveTo(targetPos)
                            if (hrp.Position - targetPos).Magnitude < 6 then
                                task.wait(0.3)
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                task.wait(0.1)
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                            end
                        end
                    end
                end
                
                task.wait(1)
            end
        end)
    else
        GroceryToggle.Text = "تشغيل فارم البقالة: متوقف"
        GroceryToggle.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
        StatusDesc.Text = "الحالة: متوقف"
    end
end)
