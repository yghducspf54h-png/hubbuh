-- ==========================================
-- PRO COMBAT HUB - FIXED & MASTER AIMBOT 2026
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- إزالة الواجهة القديمة
if PlayerGui:FindFirstChild("ProCheatGUI") then
	PlayerGui.ProCheatGUI:Destroy()
end

local Settings = {
	ESP_Enabled = true,
	Aimbot_Enabled = true,
	WallCheck = true,
	AimSmoothness = 0.2 -- سرعة ودقة الملاحقة (كل ما قل صار أسرع)
}

-- واجهة المستخدم المتحركة
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProCheatGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.fromOffset(260, 180)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.Text = "Pro Combat Hub (Fixed)"
Title.Parent = MainFrame

local function CreateToggle(name, yPos, key)
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(1, -20, 0, 35)
	Btn.Position = UDim2.new(0, 10, 0, yPos)
	Btn.BackgroundColor3 = Settings[key] and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
	Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	Btn.Font = Enum.Font.GothamBold
	Btn.TextSize = 14
	Btn.Text = name .. ": " .. (Settings[key] and "ON" or "OFF")
	Btn.Parent = MainFrame
	
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 6)
	Corner.Parent = Btn
	
	Btn.MouseButton1Click:Connect(function()
		Settings[key] = not Settings[key]
		Btn.BackgroundColor3 = Settings[key] and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
		Btn.Text = name .. ": " .. (Settings[key] and "ON" or "OFF")
	end)
end

CreateToggle("ESP (Red)", 45, "ESP_Enabled")
CreateToggle("Aimbot (Right Click)", 90, "Aimbot_Enabled")
CreateToggle("Wall Check", 135, "WallCheck")

-- نظام الـ ESP الأحمر
local function AddESP(char)
	if char:FindFirstChild("Head") and not char.Head:FindFirstChild("RedESP") then
		local bg = Instance.new("BillboardGui")
		bg.Name = "RedESP"
		bg.Size = UDim2.new(4, 0, 5, 0)
		bg.StudsOffset = Vector3.new(0, 1, 0)
		bg.AlwaysOnTop = true
		bg.Parent = char.Head
		
		local frame = Instance.new("Frame")
		frame.Size = UDim2.fromScale(1, 1)
		frame.BackgroundTransparency = 1
		frame.Parent = bg
		
		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 2
		stroke.Color = Color3.fromRGB(255, 0, 0)
		stroke.Parent = frame
	end
end

-- إيجاد أقرب عدو في واجهة الكاميرا فقط
local function GetClosestTargetInView()
	local target = nil
	local shortestDist = math.huge
	local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local char = player.Character
			local head = char:FindFirstChild("Head")
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			
			if head and humanoid and humanoid.Health > 0 then
				local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
				
				-- شرط: يكون الشخص داخل الشاشة وفي واجهة الرؤية الأمامية
				if onScreen then
					local pos2D = Vector2.new(screenPos.X, screenPos.Y)
					local dist = (pos2D - mousePos).Magnitude
					
					-- الفحص بناء على مسافة المركز وزاوية الرؤية
					if dist < shortestDist then
						if Settings.WallCheck then
							local origin = Camera.CFrame.Position
							local direction = (head.Position - origin)
							local raycastParams = RaycastParams.new()
							raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
							raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
							
							local result = workspace:Raycast(origin, direction, raycastParams)
							-- إذا مافيه جدار عائق (أو جدار وراه هو العدو مباشرة)
							if not result or result.Instance:IsDescendantOf(char) then
								target = head
								shortestDist = dist
							end
						else
							target = head
							shortestDist = dist
						end
					end
				end
			end
		end
	end
	return target
end

-- حلقة التحديث المستمرة
RunService.RenderStepped:Connect(function()
	if Settings.ESP_Enabled then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character then
				pcall(function() AddESP(p.Character) end)
			end
		end
	end
	
	-- تفعيل الإيمبوت عند الضغط المستمر على زر الماوس الأيمن (عكس الكاميرا الحرة)
	if Settings.Aimbot_Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		local targetHead = GetClosestTargetInView()
		if targetHead then
			local targetCFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
			Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.AimSmoothness)
		end
	end
end)

print("Pro Combat Hub Loaded successfully!")
