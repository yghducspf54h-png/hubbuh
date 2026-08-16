local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("ProCheatGUI") then
	PlayerGui.ProCheatGUI:Destroy()
end

local Settings = {
	ESP_Enabled = true,
	Aimbot_Enabled = true,
	WallCheck = true,
	AimSmoothness = 0.2,
	Fly_Enabled = false,
	Fly_Speed = 50,
	Teleport_Air = false,
	AutoLoot = false,
	SafeZoneCheck = true,
	Speed_Enabled = false,
	WalkSpeed = 30
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProCheatGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.fromOffset(280, 360)
MainFrame.Position = UDim2.new(0, 20, 0, 20)
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
Title.Text = "من صنع almbjl_"
Title.Parent = MainFrame

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -10, 1, -45)
ScrollingFrame.Position = UDim2.new(0, 5, 0, 40)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 420)
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 6)
UIList.Parent = ScrollingFrame

local function CreateToggle(name, key)
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(1, -10, 0, 32)
	Btn.BackgroundColor3 = Settings[key] and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
	Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	Btn.Font = Enum.Font.GothamBold
	Btn.TextSize = 13
	Btn.Text = name .. ": " .. (Settings[key] and "ON" or "OFF")
	Btn.Parent = ScrollingFrame
	
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 6)
	Corner.Parent = Btn
	
	Btn.MouseButton1Click:Connect(function()
		Settings[key] = not Settings[key]
		Btn.BackgroundColor3 = Settings[key] and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
		Btn.Text = name .. ": " .. (Settings[key] and "ON" or "OFF")
	end)
end

CreateToggle("ESP (Red)", "ESP_Enabled")
CreateToggle("ايم بوت", "Aimbot_Enabled")
CreateToggle("مايلقط الي ورا الجدران", "WallCheck")
CreateToggle("تفعيل الطيران", "Fly_Enabled")
CreateToggle("الطيران فوق بالهواء", "Teleport_Air")
CreateToggle("تعديل السرعة", "Speed_Enabled")
CreateToggle("سحب اللوت المؤقت", "AutoLoot")
CreateToggle("منع الايمبوت ع SafeZone", "SafeZoneCheck")

-- نظام الـ ESP مع محتوى الشنطة (Inventory)
local function AddESP(char, player)
	if char and char:FindFirstChild("Head") and not char.Head:FindFirstChild("RedESP") then
		local bg = Instance.new("BillboardGui")
		bg.Name = "RedESP"
		bg.Size = UDim2.new(6, 0, 7, 0)
		bg.StudsOffset = Vector3.new(0, 1.5, 0)
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

		local infoText = Instance.new("TextLabel")
		infoText.Name = "InfoText"
		infoText.Size = UDim2.new(1, 0, 0, 50)
		infoText.Position = UDim2.new(0, 0, 1, 0)
		infoText.BackgroundTransparency = 1
		infoText.TextColor3 = Color3.fromRGB(255, 255, 255)
		infoText.TextStrokeTransparency = 0
		infoText.Font = Enum.Font.GothamBold
		infoText.TextSize = 12
		infoText.Text = ""
		infoText.Parent = bg

		-- تحديث محتوى الشنطة
		task.spawn(function()
			while char and char.Parent do
				pcall(function()
					local items = {}
					if player:FindFirstChild("Backpack") then
						for _, item in ipairs(player.Backpack:GetChildren()) do
							table.insert(items, item.Name)
						end
					end
					if char:FindFirstChildOfClass("Tool") then
						table.insert(items, char:FindFirstChildOfClass("Tool").Name)
					end
					infoText.Text = "الشنطة: " .. (#items > 0 and table.concat(items, ", ") :sub(1, 40) or "فارغة")
				end)
				task.wait(1)
			end
		end)
	end
end

local function SetupPlayerESP(player)
	if player ~= LocalPlayer then
		player.CharacterAdded:Connect(function(char)
			if Settings.ESP_Enabled then
				task.wait(0.5)
				AddESP(char, player)
			end
		end)
		if player.Character then
			AddESP(player.Character, player)
		end
	end
end

for _, p in ipairs(Players:GetPlayers()) do
	SetupPlayerESP(p)
end
Players.PlayerAdded:Connect(SetupPlayerESP)

-- التحقق من مناطق الأمان SafeZone
local function IsInSafeZone(targetPart)
	if not Settings.SafeZoneCheck then return false end
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj.Name:lower():find("safe") or obj.Name:lower():find("zone") then
			if obj:IsA("BasePart") then
				if (targetPart.Position - obj.Position).Magnitude < (obj.Size.Magnitude / 2) then
					return true
				end
			end
		end
	end
	return false
end

-- فحص أقرب هدف للايمبوت مع شروط الجدران والـ SafeZone
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
				if not IsInSafeZone(head) then
					local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
					if onScreen then
						local pos2D = Vector2.new(screenPos.X, screenPos.Y)
						local dist = (pos2D - mousePos).Magnitude
						
						if dist < shortestDist then
							if Settings.WallCheck then
								local origin = Camera.CFrame.Position
								local direction = (head.Position - origin)
								local raycastParams = RaycastParams.new()
								raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
								raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
								
								local result = Workspace:Raycast(origin, direction, raycastParams)
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
	end
	return target
end

-- نظام اللوت السريع المؤقت
local function TriggerAutoLoot()
	if not Settings.AutoLoot then return end
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local hrp = char.HumanoidRootPart
	local originalPos = hrp.CFrame
	
	pcall(function()
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("TouchTransmitter") and obj.Parent and (obj.Parent:IsA("BasePart") or obj.Parent:IsA("Model")) then
				local part = obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildWhichIsA("BasePart")
				if part and (part.Position - hrp.Position).Magnitude < 250 then
					hrp.CFrame = part.CFrame + Vector3.new(0, 2, 0)
					task.wait(0.1)
				end
			end
		end
	end)
	task.wait(0.2)
	hrp.CFrame = originalPos
	Settings.AutoLoot = false
end

-- حلقة التحديث المستمرة للوظائف
RunService.RenderStepped:Connect(function()
	local char = LocalPlayer.Character
	if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") then
		local hrp = char.HumanoidRootPart
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		
		-- السرعة
		if Settings.Speed_Enabled then
			humanoid.WalkSpeed = Settings.WalkSpeed
		else
			humanoid.WalkSpeed = 16
		end
		
		-- الانتقال فوق بالهواء
		if Settings.Teleport_Air then
			hrp.CFrame = hrp.CFrame + Vector3.new(0, 50, 0)
			Settings.Teleport_Air = false
		end
		
		-- الطيران
		if Settings.Fly_Enabled then
			local moveDir = humanoid.MoveDirection
			hrp.Velocity = Vector3.new(moveDir.X * Settings.Fly_Speed, 1, moveDir.Z * Settings.Fly_Speed)
		end
	end
	
	-- سحب اللوت
	if Settings.AutoLoot then
		task.spawn(TriggerAutoLoot)
	end
	
	-- الإيمبوت
	if Settings.Aimbot_Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		local targetHead = GetClosestTargetInView()
		if targetHead then
			local targetCFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
			Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.AimSmoothness)
		end
	end
end)
