-- ==========================================
-- BlockSpin Roblox - MASTER CHEAT 2026 (Fixed)
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- إعدادات السكربت
local Settings = {
	ESP = true,
	ESP_Color = Color3.fromRGB(0, 255, 0),
	FOV_Offset = 15,
	Janitor_Farm_Active = true,
	Cook_Farm_Active = true,
	ATM_Hack_Active = true,
	FishingFarm_Active = true,
	ItemBot_Active = true,
	Vehicle_Farm_Active = true,
}

-- ==========================================
-- بناء واجهة التحكم (GUI) بشكل صحيح
-- ==========================================
local function CreateGUI()
	if playerGui:FindFirstChild("BlockSpin_Master_Cheat_GUI") then
		playerGui.BlockSpin_Master_Cheat_GUI:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BlockSpin_Master_Cheat_GUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui
	
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.fromOffset(420, 500)
	mainFrame.Position = UDim2.new(0.5, -210, 0.5, -250)
	mainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
	mainFrame.BorderSizePixel = 0
	mainFrame.Active = true
	mainFrame.Draggable = true
	mainFrame.Parent = screenGui
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0, 45)
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 20
	titleLabel.Text = "BlockSpin Master Cheat 2026"
	titleLabel.Parent = mainFrame
	
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.fromOffset(30, 30)
	closeBtn.Position = UDim2.new(1, -40, 0, 8)
	closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.Text = "X"
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 16
	closeBtn.Parent = mainFrame
	
	closeBtn.MouseButton1Click:Connect(function()
		screenGui:Destroy()
	end)
	
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Size = UDim2.new(1, -20, 1, -60)
	scrollingFrame.Position = UDim2.new(0, 10, 0, 50)
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 450)
	scrollingFrame.ScrollBarThickness = 6
	scrollingFrame.Parent = mainFrame
	
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 8)
	uiListLayout.Parent = scrollingFrame
	
	local function CreateToggle(name, settingKey)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 40)
		btn.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 15
		btn.Text = name .. ": " .. (Settings[settingKey] and "ON" or "OFF")
		btn.Parent = scrollingFrame
		
		btn.MouseButton1Click:Connect(function()
			Settings[settingKey] = not Settings[settingKey]
			btn.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
			btn.Text = name .. ": " .. (Settings[settingKey] and "ON" or "OFF")
		end)
	end
	
	CreateToggle("ESP System", "ESP")
	CreateToggle("Janitor Farm", "Janitor_Farm_Active")
	CreateToggle("Cook Farm", "Cook_Farm_Active")
	CreateToggle("ATM Farm", "ATM_Hack_Active")
	CreateToggle("Fishing Farm", "FishingFarm_Active")
	CreateToggle("Item Bot", "ItemBot_Active")
	CreateToggle("Vehicle Farm", "Vehicle_Farm_Active")
end

-- ==========================================
-- نظام الـ ESP البسيط والمستقر
-- ==========================================
local function AddESP(char)
	if char:FindFirstChild("Head") and not char.Head:FindFirstChild("ESP_Box") then
		local bg = Instance.new("BillboardGui")
		bg.Name = "ESP_Box"
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
		stroke.Color = Settings.ESP_Color
		stroke.Parent = frame
	end
end

-- ==========================================
-- تشغيل الميزات الأساسية
-- ==========================================
RunService.RenderStepped:Connect(function()
	if Settings.ESP then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= player and p.Character then
				pcall(function()
					AddESP(p.Character)
				end)
			end
		end
	end
end)

-- تعديل الكاميرا (FOV)
pcall(function()
	local camera = workspace.CurrentCamera
	if camera then
		TweenService:Create(camera, TweenInfo.new(1), {FieldOfView = camera.FieldOfView + Settings.FOV_Offset}):Play()
	end
end)

-- تشغيل الواجهة
pcall(CreateGUI)

print("BlockSpin Master Cheat 2026 Loaded Successfully!")
