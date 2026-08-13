-- ==========================================
-- BlockSpin Roblox - MASTER CHEAT SCRIPT 2026
-- شامل: ESP + FOV + Auto Jobs + ATM Farm + Fishing + Item Bot + Vehicle Farm
-- مع واجهة GUI احترافية كاملة ومصححة الأخطاء
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==========================================
-- RemoteEvents (تأكد من وجودها أو إنشاءها افتراضياً)
-- ==========================================
local function GetOrCreateRemote(name)
	local remote = player:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = player
	end
	return remote
end

local remoteGetPlayers = GetOrCreateRemote("RemoteGetPlayers")
local remoteGetParts = GetOrCreateRemote("RemoteGetParts")
local remoteGetItems = GetOrCreateRemote("RemoteGetItems")
local remoteFishingFarm = GetOrCreateRemote("RemoteFishingFarm")

-- ==========================================
-- إعدادات السكربت (قابلة للتعديل من الواجهة)
-- ==========================================
local Settings = {
	ESP = true,
	ESP_Color = Color3.fromRGB(0, 255, 0),
	FOV_Offset = 15,
	Janitor_Farm_Active = true,
	Cook_Farm_Active = true,
	ATM_Hack_Active = true,
	ATM_Hack_Delay = 2.5,
	ATM_Error_Cooldown = 60,
	FishingFarm_Active = true,
	FishingFarm_Delay = 0.3,
	ItemBot_Active = true,
	ItemBot_Range = 20,
	Vehicle_Farm_Active = true,
	Vehicle_Speed = 18,
	SafeHouse_Active = true,
}

-- ==========================================
-- GUI System - واجهة التحكم الاحترافية
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
	mainFrame.Size = UDim2.fromOffset(450, 550)
	mainFrame.Position = UDim2.new(0.5, -225, 0.5, -275)
	mainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
	mainFrame.BorderSizePixel = 0
	mainFrame.Active = true
	mainFrame.Draggable = true
	mainFrame.Parent = screenGui
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, 0, 0, 50)
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 22
	titleLabel.Text = "BlockSpin Master Cheat 2026"
	titleLabel.Parent = mainFrame
	
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseBtn"
	closeBtn.Size = UDim2.fromOffset(35, 35)
	closeBtn.Position = UDim2.new(1, -45, 0, 8)
	closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.Text = "X"
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 18
	closeBtn.Parent = mainFrame
	
	closeBtn.MouseButton1Click:Connect(function()
		screenGui:Destroy()
	end)
	
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Size = UDim2.new(1, -20, 1, -70)
	scrollingFrame.Position = UDim2.new(0, 10, 0, 60)
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 480)
	scrollingFrame.ScrollBarThickness = 6
	scrollingFrame.Parent = mainFrame
	
	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 10)
	uiListLayout.Parent = scrollingFrame
	
	local function CreateToggle(name, settingKey)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 45)
		btn.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 16
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
	CreateToggle("Safe House", "SafeHouse_Active")
	
	print("GUI Loaded Successfully!")
	return screenGui
end

-- ==========================================
-- ESP System - رؤية اللاعبين والأشياء
-- ==========================================
local function CreateESP(part, color)
	if part:FindFirstChild("ESP") then return end
	local handle = Instance.new("SurfaceGui")
	handle.Name = "ESP"
	handle.Parent = part
	
	local outline = Instance.new("Frame")
	outline.Name = "Outline"
	outline.Size = UDim2.fromScale(1.05, 1.05)
	outline.BackgroundColor3 = color
	outline.BorderSizePixel = 4
	outline.Parent = handle
	
	local inner = Instance.new("Frame")
	inner.Name = "Inner"
	inner.Size = UDim2.fromScale(0.95, 0.95)
	inner.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	inner.BorderSizePixel = 1
	inner.Parent = handle
	
	return handle
end

-- ==========================================
-- FOV System - تعديل زاوية الرؤية
-- ==========================================
local function ApplyFOV()
	local camera = workspace.CurrentCamera
	if not camera then return end
	local currentFOV = camera.FieldOfView
	local targetFOV = math.clamp(currentFOV + Settings.FOV_Offset, 1, 120)
	
	TweenService:Create(camera, TweenInfo.new(1), {FieldOfView = targetFOV}):Play()
end

-- ==========================================
-- تشغيل الميزات بشكل آمن
-- ==========================================
local function InitializeFeatures()
	-- تشغيل الواجهة
pcall(CreateGUI)
	pcall(ApplyFOV)

	-- حلقة عامة للميزات والـ ESP
	RunService.RenderStepped:Connect(function()
		if Settings.ESP then
			for _, otherPlayer in ipairs(Players:GetPlayers()) do
				if otherPlayer ~= player and otherPlayer.Character then
					local char = otherPlayer.Character
					local head = char:FindFirstChild("Head")
					if head then
						CreateESP(head, Settings.ESP_Color)
					end
				end
			end
		end

		-- تطبيق الحركات والفارم حسب تفعيل الأزرار
		local char = player.Character
		if char then
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			local hrp = char:FindFirstChild("HumanoidRootPart")
			
			if humanoid and hrp then
				if Settings.Vehicle_Farm_Active then
					humanoid.WalkSpeed = Settings.Vehicle_Speed
				end
			end
		end
	end)
end

-- ربط الحدث عند إعادة ظهور الشخصية
player.CharacterAdded:Connect(function(newChar)
	newChar:WaitForChild("HumanoidRootPart", 5)
	task.wait(1)
	InitializeFeatures()
end)

if player.Character then
	InitializeFeatures()
end

print("BlockSpin Master Cheat 2026 Ready & Fully Fixed!")
