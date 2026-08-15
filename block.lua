local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("ProCheatGUI") then
	PlayerGui.ProCheatGUI:Destroy()
end

local Settings = {
	ESP_Enabled = true,
	Aimbot_Enabled = true,
	TeamCheck = true,
	WallCheck = true,
	FOV_Radius = 150
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProCheatGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.fromOffset(260, 210)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -105)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
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
Title.TextSize = 16
Title.Text = "Pro Combat Hub"
Title.Parent = MainFrame

local function CreateToggle(name, yPos, key)
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(1, -20, 0, 35)
	Btn.Position = UDim2.new(0, 10, 0, yPos)
	Btn.BackgroundColor3 = Settings[key] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
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
		Btn.BackgroundColor3 = Settings[key] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
		Btn.Text = name .. ": " .. (Settings[key] and "ON" or "OFF")
	end)
end

CreateToggle("ESP (Red)", 45, "ESP_Enabled")
CreateToggle("Smart Aimbot", 90, "Aimbot_Enabled")
CreateToggle("Wall Check", 135, "WallCheck")

local FOVCircle = Drawing.new("Circle")
FOVCircle.Transparency = 0.7
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Radius = Settings.FOV_Radius
FOVCircle.Visible = true

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

local function GetClosestTarget()
	local closestTarget = nil
	local shortestDist = Settings.FOV_Radius
	local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			if not Settings.TeamCheck or player.Team ~= LocalPlayer.Team then
				local char = player.Character
				if char and char:FindFirstChild("Head") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
					local head = char.Head
					local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
					
					if onScreen then
						local pos2D = Vector2.new(screenPos.X, screenPos.Y)
						local dist = (pos2D - mousePos).Magnitude
						
						if dist < shortestDist then
							if Settings.WallCheck then
								local origin = Camera.CFrame.Position
								local direction = (head.Position - origin)
								local raycastParams = RaycastParams.new()
								raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
								raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
								
								local result = workspace:Raycast(origin, direction, raycastParams)
								if not result or result.Instance:IsDescendantOf(char) then
									closestTarget = head
									shortestDist = dist
								end
							else
								closestTarget = head
								shortestDist = dist
							end
						end
					end
				end
			end
		end
	end
	return closestTarget
end

RunService.RenderStepped:Connect(function()
	FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	FOVCircle.Visible = Settings.Aimbot_Enabled
	
	if Settings.ESP_Enabled then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character then
				pcall(function() AddESP(p.Character) end)
			end
		end
	end
	
	if Settings.Aimbot_Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		local target = GetClosestTarget()
		if target then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
		end
	end
end)
