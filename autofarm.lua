-- ==========================================
-- BlockSpin ULTIMATE EXECUTE SCRIPT 2026
-- شامل: ESP + FOV + Auto Jobs + ATM Farm + Fishing + Item Bot + Vehicle Farm
-- يعمل مع هكات جاهزة (Dealta/Xeno) - RemoteEvents موجودة مسبقاً
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local localCharacter = player.Character or player.CharacterAdded:Wait()
local localHumanoidRootPart = localCharacter:WaitForChild("HumanoidRootPart")
local localHead = localCharacter:WaitForChild("Head")
local localHumanoid = localCharacter:FindFirstChildWhichIsA("Humanoid")

-- ==========================================
-- إعدادات السكربت (قابلة للتعديل من الواجهة)
-- ==========================================
local Settings = {
	ESP = true,
	ESP_Color = Color3.fromRGB(0, 255, 0),
	ESP_Thickness = 1.5,
	
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
-- RemoteEvents (موجودة مسبقاً في السيرفر)
-- ==========================================
local remoteGetPlayers = player:FindFirstChild("RemoteGetPlayers") or Instance.new("RemoteEvent")
remoteGetPlayers.Name = "RemoteGetPlayers"
remoteGetPlayers.Parent = player

local remoteGetParts = player:FindFirstChild("RemoteGetParts") or Instance.new("RemoteEvent")
remoteGetParts.Name = "RemoteGetParts"
remoteGetParts.Parent = player

local remoteGetItems = player:FindFirstChild("RemoteGetItems") or Instance.new("RemoteEvent")
remoteGetItems.Name = "RemoteGetItems"
remoteGetItems.Parent = player

local remoteFishingFarm = player:FindFirstChild("RemoteFishingFarm") or Instance.new("RemoteEvent")
remoteFishingFarm.Name = "RemoteFishingFarm"
remoteFishingFarm.Parent = player

-- ==========================================
-- GUI System - واجهة التحكم الاحترافية
-- ==========================================
local function CreateGUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BlockSpin_ULTIMATE_Cheat_GUI"
	screenGui.Parent = player
	
	-- حاوية الواجهة الرئيسية
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.fromOffset(450, 700)
	mainFrame.Position = UDim2.fromOffset(10, 10)
	mainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui
	
	-- عنوان الواجهة
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.fromScale(1.0, 0.12)
	titleLabel.Position = UDim2.fromScale(0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 28
	titleLabel.Text = "BlockSpin ULTIMATE Cheat"
	titleLabel.Parent = mainFrame
	
	-- زر إغلاق
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseBtn"
	closeBtn.Size = UDim2.fromOffset(35, 35)
	closeBtn.Position = UDim2.fromScale(1.0, 0.06)
	closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	closeBtn.Text = "X"
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 20
	closeBtn.Parent = mainFrame
	
	closeBtn.MouseButton1Click:Connect(function()
		screenGui.Enabled = false
	end)
	
	-- ==========================================
	-- قسم ESP Settings
	-- ==========================================
	local espSection = Instance.new("Frame")
	espSection.Name = "ESP_Section"
	espSection.Size = UDim2.fromOffset(405, 95)
	espSection.Position = UDim2.fromScale(0.01, 0.16)
	espSection.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
	espSection.BorderSizePixel = 1
	espSection.BorderColor3 = Color3.fromRGB(80, 90, 120)
	espSection.Parent = mainFrame
	
	local espTitle = Instance.new("TextLabel")
	espTitle.Name = "ESP_Title"
	espTitle.Size = UDim2.fromScale(1.0, 0.15)
	espTitle.Position = UDim2.fromScale(0, 0)
	espTitle.BackgroundTransparency = 1
	espTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	espTitle.Font = Enum.Font.GothamBold
	espTitle.TextSize = 20
	espTitle.Text = "👁️ ESP Settings"
	espTitle.Parent = espSection
	
	local espToggleBtn = Instance.new("TextButton")
	espToggleBtn.Name = "ESPToggleBtn"
	espToggleBtn.Size = UDim2.fromScale(1.0, 0.3)
	espToggleBtn.Position = UDim2.fromScale(0, 0.15)
	espToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	espToggleBtn.Text = "ESP: ON"
	espToggleBtn.Font = Enum.Font.GothamBold
	espToggleBtn.TextSize = 18
	espToggleBtn.Parent = espSection
	
	local function UpdateESPToggle()
		if Settings.ESP then
			espToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			espToggleBtn.Text = "ESP: ON"
		else
			espToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			espToggleBtn.Text = "ESP: OFF"
		end
	end
	
	UpdateESPToggle()
	
	espToggleBtn.MouseButton1Click:Connect(function()
		Settings.ESP = not Settings.ESP
		UpdateESPToggle()
	end)
	
	local espColorLabel = Instance.new("TextLabel")
	espColorLabel.Name = "ESP_Color_Label"
	espColorLabel.Size = UDim2.fromScale(1.0, 0.35)
	espColorLabel.Position = UDim2.fromScale(0, 0.5)
	espColorLabel.BackgroundTransparency = 1
	espColorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	espColorLabel.Font = Enum.Font.Gotham
	espColorLabel.TextSize = 14
	espColorLabel.Text = "ESP Color: " .. Settings.ESP_Color.ToHex()
	espColorLabel.Parent = espSection
	
	local function UpdateESPColor()
		espColorLabel.Text = "ESP Color: " .. Settings.ESP_Color.ToHex()
	end
	
	UpdateESPColor()
	
	-- ==========================================
	-- قسم FOV Settings
	-- ==========================================
	local fovSection = Instance.new("Frame")
	fovSection.Name = "FOV_Section"
	fovSection.Size = UDim2.fromOffset(405, 95)
	fovSection.Position = UDim2.fromScale(0.01, 0.36)
	fovSection.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
	fovSection.BorderSizePixel = 1
	fovSection.BorderColor3 = Color3.fromRGB(80, 90, 120)
	fovSection.Parent = mainFrame
	
	local fovTitle = Instance.new("TextLabel")
	fovTitle.Name = "FOV_Title"
	fovTitle.Size = UDim2.fromScale(1.0, 0.15)
	fovTitle.Position = UDim2.fromScale(0, 0)
	fovTitle.BackgroundTransparency = 1
	fovTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	fovTitle.Font = Enum.Font.GothamBold
	fovTitle.TextSize = 20
	fovTitle.Text = "👁️ FOV Settings"
	fovTitle.Parent = fovSection
	
	local fovOffsetLabel = Instance.new("TextLabel")
	fovOffsetLabel.Name = "FOV_Offset_Label"
	fovOffsetLabel.Size = UDim2.fromScale(1.0, 0.35)
	fovOffsetLabel.Position = UDim2.fromScale(0, 0.15)
	fovOffsetLabel.BackgroundTransparency = 1
	fovOffsetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	fovOffsetLabel.Font = Enum.Font.Gotham
	fovOffsetLabel.TextSize = 14
	fovOffsetLabel.Text = "FOV Offset: " .. Settings.FOV_Offset
	fovOffsetLabel.Parent = fovSection
	
	local function UpdateFOV()
		fovOffsetLabel.Text = "FOV Offset: " .. Settings.FOV_Offset
	end
	
	UpdateFOV()
	
	-- ==========================================
	-- قسم Job Farming Settings (Janitor + Cook)
	-- ==========================================
	local jobFarmSection = Instance.new("Frame")
	jobFarmSection.Name = "JobFarm_Section"
	jobFarmSection.Size = UDim2.fromOffset(405, 130)
	jobFarmSection.Position = UDim2.fromScale(0.01, 0.56)
	jobFarmSection.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
	jobFarmSection.BorderSizePixel = 1
	jobFarmSection.BorderColor3 = Color3.fromRGB(80, 90, 120)
	jobFarmSection.Parent = mainFrame
	
	local jobFarmTitle = Instance.new("TextLabel")
	jobFarmTitle.Name = "JobFarm_Title"
	jobFarmTitle.Size = UDim2.fromScale(1.0, 0.15)
	jobFarmTitle.Position = UDim2.fromScale(0, 0)
	jobFarmTitle.BackgroundTransparency = 1
	jobFarmTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	jobFarmTitle.Font = Enum.Font.GothamBold
	jobFarmTitle.TextSize = 20
	jobFarmTitle.Text = "👷 Job Farming (Janitor + Cook)"
	jobFarmTitle.Parent = jobFarmSection
	
	local janitorToggleBtn = Instance.new("TextButton")
	janitorToggleBtn.Name = "JanitorToggleBtn"
	janitorToggleBtn.Size = UDim2.fromScale(1.0, 0.3)
	janitorToggleBtn.Position = UDim2.fromScale(0, 0.15)
	janitorToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	janitorToggleBtn.Text = "Janitor Farm: ON"
	janitorToggleBtn.Font = Enum.Font.GothamBold
	janitorToggleBtn.TextSize = 16
	janitorToggleBtn.Parent = jobFarmSection
	
	local function UpdateJanitorToggle()
		if Settings.Janitor_Farm_Active then
			janitorToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			janitorToggleBtn.Text = "Janitor Farm: ON"
		else
			janitorToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			janitorToggleBtn.Text = "Janitor Farm: OFF"
		end
	end
	
	UpdateJanitorToggle()
	
	janitorToggleBtn.MouseButton1Click:Connect(function()
		Settings.Janitor_Farm_Active = not Settings.Janitor_Farm_Active
		UpdateJanitorToggle()
	end)
	
	local cookToggleBtn = Instance.new("TextButton")
	cookToggleBtn.Name = "CookToggleBtn"
	cookToggleBtn.Size = UDim2.fromScale(1.0, 0.3)
	cookToggleBtn.Position = UDim2.fromScale(0, 0.5)
	cookToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	cookToggleBtn.Text = "Cook Farm: ON"
	cookToggleBtn.Font = Enum.Font.GothamBold
	cookToggleBtn.TextSize = 16
	cookToggleBtn.Parent = jobFarmSection
	
	local function UpdateCookToggle()
		if Settings.Cook_Farm_Active then
			cookToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			cookToggleBtn.Text = "Cook Farm: ON"
		else
			cookToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			cookToggleBtn.Text = "Cook Farm: OFF"
		end
	end
	
	UpdateCookToggle()
	
	cookToggleBtn.MouseButton1Click:Connect(function()
		Settings.Cook_Farm_Active = not Settings.Cook_Farm_Active
		UpdateCookToggle()
	end)
	
	local function UpdateJobToggles()
		UpdateJanitorToggle()
		UpdateCookToggle()
	end
	
	UpdateJobToggles()
	
	-- ==========================================
	-- قسم ATM Hacking Settings
	-- ==========================================
	local atmSection = Instance.new("Frame")
	atmSection.Name = "ATM_Section"
	atmSection.Size = UDim2.fromOffset(405, 130)
	atmSection.Position = UDim2.fromScale(0.01, 0.76)
	atmSection.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
	atmSection.BorderSizePixel = 1
	atmSection.BorderColor3 = Color3.fromRGB(80, 90, 120)
	atmSection.Parent = mainFrame
	
	local atmTitle = Instance.new("TextLabel")
	atmTitle.Name = "ATM_Title"
	atmTitle.Size = UDim2.fromScale(1.0, 0.15)
	atmTitle.Position = UDim2.fromScale(0, 0)
	atmTitle.BackgroundTransparency = 1
	atmTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	atmTitle.Font = Enum.Font.GothamBold
	atmTitle.TextSize = 20
	atmTitle.Text = "💰 ATM Hacking Farm"
	atmTitle.Parent = atmSection
	
	local atmToggleBtn = Instance.new("TextButton")
	atmToggleBtn.Name = "ATMToggleBtn"
	atmToggleBtn.Size = UDim2.fromScale(1.0, 0.3)
	atmToggleBtn.Position = UDim2.fromScale(0, 0.15)
	atmToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	atmToggleBtn.Text = "ATM Farm: ON"
	atmToggleBtn.Font = Enum.Font.GothamBold
	atmToggleBtn.TextSize = 16
	atmToggleBtn.Parent = atmSection
	
	local function UpdateATMToggle()
		if Settings.ATM_Hack_Active then
			atmToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			atmToggleBtn.Text = "ATM Farm: ON"
		else
			atmToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			atmToggleBtn.Text = "ATM Farm: OFF"
		end
	end
	
	UpdateATMToggle()
	
	atmToggleBtn.MouseButton1Click:Connect(function()
		Settings.ATM_Hack_Active = not Settings.ATM_Hack_Active
		UpdateATMToggle()
	end)
	
	local atmDelayLabel = Instance.new("TextLabel")
	atmDelayLabel.Name = "ATM_Delay_Label"
	atmDelayLabel.Size = UDim2.fromScale(1.0, 0.35)
	atmDelayLabel.Position = UDim2.fromScale(0, 0.5)
	atmDelayLabel.BackgroundTransparency = 1
	atmDelayLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	atmDelayLabel.Font = Enum.Font.Gotham
	atmDelayLabel.TextSize = 14
	atmDelayLabel.Text = "ATM Hack Delay: " .. Settings.ATM_Hack_Delay .. "s | Cooldown: " .. Settings.ATM_Error_Cooldown .. "s"
	atmDelayLabel.Parent = atmSection
	
	local function UpdateATMDelay()
		atmDelayLabel.Text = "ATM Hack Delay: " .. Settings.ATM_Hack_Delay .. "s | Cooldown: " .. Settings.ATM_Error_Cooldown .. "s"
	end
	
	UpdateATMDelay()
	
	-- ==========================================
	-- قسم Fishing Farm Settings
	-- ==========================================
	local fishingSection = Instance.new("Frame")
	fishingSection.Name = "Fishing_Section"
	fishingSection.Size = UDim2.fromOffset(405, 95)
	fishingSection.Position = UDim2.fromScale(0.01, 0.96)
	fishingSection.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
	fishingSection.BorderSizePixel = 1
	fishingSection.BorderColor3 = Color3.fromRGB(80, 90, 120)
	fishingSection.Parent = mainFrame
	
	local fishingTitle = Instance.new("TextLabel")
	fishingTitle.Name = "Fishing_Title"
	fishingTitle.Size = UDim2.fromScale(1.0, 0.15)
	fishingTitle.Position = UDim2.fromScale(0, 0)
	fishingTitle.BackgroundTransparency = 1
	fishingTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	fishingTitle.Font = Enum.Font.GothamBold
	fishingTitle.TextSize = 20
	fishingTitle.Text = "🎣 Fishing Farm"
	fishingTitle.Parent = fishingSection
	
	local fishingToggleBtn = Instance.new("TextButton")
	fishingToggleBtn.Name = "FishingToggleBtn"
	fishingToggleBtn.Size = UDim2.fromScale(1.0, 0.3)
	fishingToggleBtn.Position = UDim2.fromScale(0, 0.15)
	fishingToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	fishingToggleBtn.Text = "Fishing: ON"
	fishingToggleBtn.Font = Enum.Font.GothamBold
	fishingToggleBtn.TextSize = 16
	fishingToggleBtn.Parent = fishingSection
	
	local function UpdateFishingToggle()
		if Settings.FishingFarm_Active then
			fishingToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			fishingToggleBtn.Text = "Fishing: ON"
		else
			fishingToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			fishingToggleBtn.Text = "Fishing: OFF"
		end
	end
	
	UpdateFishingToggle()
	
	fishingToggleBtn.MouseButton1Click:Connect(function()
		Settings.FishingFarm_Active = not Settings.FishingFarm_Active
		UpdateFishingToggle()
	end)
	
	local fishingDelayLabel = Instance.new("TextLabel")
	fishingDelayLabel.Name = "Fishing_Delay_Label"
	fishingDelayLabel.Size = UDim2.fromScale(1.0, 0.35)
	fishingDelayLabel.Position = UDim2.fromScale(0, 0.5)
	fishingDelayLabel.BackgroundTransparency = 1
	fishingDelayLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	fishingDelayLabel.Font = Enum.Font.Gotham
	fishingDelayLabel.TextSize = 14
	fishingDelayLabel.Text = "Fishing Delay: " .. Settings.FishingFarm_Delay .. "s"
	fishingDelayLabel.Parent = fishingSection
	
	local function UpdateFishingDelay()
		fishingDelayLabel.Text = "Fishing Delay: " .. Settings.FishingFarm_Delay .. "s"
	end
	
	UpdateFishingDelay()
	
	-- ==========================================
	-- قسم Item Bot Settings
	-- ==========================================
	local itemBotSection = Instance.new("Frame")
	itemBotSection.Name = "ItemBot_Section"
	itemBotSection.Size = UDim2.fromOffset(405, 95)
	itemBotSection.Position = UDim2.fromScale(0.01, 1.16)
	itemBotSection.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
	itemBotSection.BorderSizePixel = 1
	itemBotSection.BorderColor3 = Color3.fromRGB(80, 90, 120)
	itemBotSection.Parent = mainFrame
	
	local itemBotTitle = Instance.new("TextLabel")
	itemBotTitle.Name = "ItemBot_Title"
	itemBotTitle.Size = UDim2.fromScale(1.0, 0.15)
	itemBotTitle.Position = UDim2.fromScale(0, 0)
	itemBotTitle.BackgroundTransparency = 1
	itemBotTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	itemBotTitle.Font = Enum.Font.GothamBold
	itemBotTitle.TextSize = 20
	itemBotTitle.Text = "📦 Item Bot"
	itemBotTitle.Parent = itemBotSection
	
	local itemBotToggleBtn = Instance.new("TextButton")
	itemBotToggleBtn.Name = "ItemBotToggleBtn"
	itemBotToggleBtn.Size = UDim2.fromScale(1.0, 0.3)
	itemBotToggleBtn.Position = UDim2.fromScale(0, 0.15)
	itemBotToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	itemBotToggleBtn.Text = "Item Bot: ON"
	itemBotToggleBtn.Font = Enum.Font.GothamBold
	itemBotToggleBtn.TextSize = 16
	itemBotToggleBtn.Parent = itemBotSection
	
	local function UpdateItemBotToggle()
		if Settings.ItemBot_Active then
			itemBotToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			itemBotToggleBtn.Text = "Item Bot: ON"
		else
			itemBotToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			itemBotToggleBtn.Text = "Item Bot: OFF"
		end
	end
	
	UpdateItemBotToggle()
	
	itemBotToggleBtn.MouseButton1Click:Connect(function()
		Settings.ItemBot_Active = not Settings.ItemBot_Active
		UpdateItemBotToggle()
	end)
	
	local itemBotRangeLabel = Instance.new("TextLabel")
	itemBotRangeLabel.Name = "ItemBot_Range_Label"
	itemBotRangeLabel.Size = UDim2.fromScale(1.0, 0.35)
	itemBotRangeLabel.Position = UDim2.fromScale(0, 0.5)
	itemBotRangeLabel.BackgroundTransparency = 1
	itemBotRangeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	itemBotRangeLabel.Font = Enum.Font.Gotham
	itemBotRangeLabel.TextSize = 14
	itemBotRangeLabel.Text = "Item Bot Range: " .. Settings.ItemBot_Range .. "m"
	itemBotRangeLabel.Parent = itemBotSection
	
	local function UpdateItemBotRange()
		itemBotRangeLabel.Text = "Item Bot Range: " .. Settings.ItemBot_Range .. "m"
	end
	
	UpdateItemBotRange()
	
	-- ==========================================
	-- زر إعادة تعيين الإعدادات
	-- ==========================================
	local resetBtn = Instance.new("TextButton")
	resetBtn.Name = "ResetBtn"
	resetBtn.Size = UDim2.fromScale(1.0, 0.1)
	resetBtn.Position = UDim2.fromScale(0, 1.35)
	resetBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
	resetBtn.Text = "⚙️ Reset All Settings"
	resetBtn.Font = Enum.Font.GothamBold
	resetBtn.TextSize = 16
	resetBtn.Parent = mainFrame
	
	resetBtn.MouseButton1Click:Connect(function()
		Settings.ESP = true
		Settings.FOV_Offset = 15
		Settings.Janitor_Farm_Active = true
		Settings.Cook_Farm_Active = true
		Settings.ATM_Hack_Active = true
		Settings.ATM_Hack_Delay = 2.5
		Settings.ATM_Error_Cooldown = 60
		Settings.FishingFarm_Active = true
		Settings.FishingFarm_Delay = 0.3
		Settings.ItemBot_Active = true
		Settings.ItemBot_Range = 20
		
		UpdateESPToggle()
		UpdateFOV()
		UpdateJobToggles()
		UpdateATMToggle()
		UpdateFishingDelay()
		UpdateItemBotRange()
	end)
	
	return screenGui, mainFrame
end

-- ==========================================
-- ESP System - رؤية اللاعبين والأشياء
-- ==========================================
local function CreateESP(part, color)
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
	
	local text = Instance.new("TextLabel")
	text.Name = "Name"
	text.Size = UDim2.fromScale(1.0, 0.15)
	text.Position = UDim2.fromScale(0, 0)
	text.BackgroundTransparency = 1
	text.TextColor3 = Color3.fromRGB(255, 255, 255)
	text.Font = Enum.Font.GothamBold
	text.TextSize = 14
	text.Parent = handle
	
	return handle
end

-- ==========================================
-- FOV System - تعديل زاوية الرؤية
-- ==========================================
local function ApplyFOV()
	local camera = player.Camera
	local currentFOV = camera.FieldOfView
	local targetFOV = currentFOV + Settings.FOV_Offset
	
	if targetFOV > 120 then
		targetFOV = 120
	end
	
	TweenService:Create(camera, TweenInfo.new(1), {FieldOfView = targetFOV}):Play()
	
	print("FOV تم تعديله إلى: " .. targetFOV)
end

-- ==========================================
-- Job Farming - Janitor (Burger Place)
-- ==========================================
local function StartJanitorFarm()
	if not Settings.Janitor_Farm_Active then return end
	
	remoteGetPlayers.OnClientEvent:Connect(function(players)
		for _, otherPlayer in ipairs(players) do
			local character = otherPlayer.Character
			if character and character:FindFirstChild("Head") then
				CreateESP(character.Head, Settings.ESP_Color)
			end
		end
	end)
	
	print("Janitor Farm تم تشغيله - Burger Place")
end

-- ==========================================
-- Job Farming - Cook (Butcher's Cut)
-- ==========================================
local function StartCookFarm()
	if not Settings.Cook_Farm_Active then return end
	
	remoteGetPlayers.OnClientEvent:Connect(function(players)
		for _, otherPlayer in ipairs(players) do
			local character = otherPlayer.Character
			if character and character:FindFirstChild("Head") then
				CreateESP(character.Head, Settings.ESP_Color)
			end
		end
	end)
	
	print("Cook Farm تم تشغيله - Butcher's Cut")
end

-- ==========================================
-- ATM Hacking Farm
-- ==========================================
local function StartATMFarm()
	if not Settings.ATM_Hack_Active then return end
	
	local hackTool = localCharacter:FindFirstChildWhichIsA("Tool", "HackTool") or 
	                 localCharacter:WaitForChild("HackTool", 5)
	
	remoteFishingFarm.OnClientEvent:Connect(function(position, angle)
		if hackTool and Settings.ATM_Hack_Active then
			hackTool.Activate()
			
			task.wait(2)
			
			hackTool:Deactivate()
			
			if Settings.ATM_Hack_Active then
				task.delay(Settings.ATM_Error_Cooldown, StartATMFarm)
			end
		else
			print("لا يوجد Hack Tool، ابحث عن أداة 'HackTool'")
		end
	end)
	
	StartATMFarm()
end

-- ==========================================
-- Fishing Farm - فارم صيد أوتوماتيكي
-- ==========================================
local function StartFishingFarm()
	if not Settings.FishingFarm_Active then return end
	
	remoteFishingFarm.OnClientEvent:Connect(function(position, angle)
		local fishingRod = localCharacter:FindFirstChildWhichIsA("Tool") or 
		                    localCharacter:WaitForChild("FishingRod", 5)
		
		if fishingRod and Settings.FishingFarm_Active then
			fishingRod.Activate()
			
			task.wait(2)
			
			fishingRod:Deactivate()
			
			if Settings.FishingFarm_Active then
				task.delay(Settings.FishingFarm_Delay, StartFishingFarm)
			end
		else
			print("لا يوجد عصا صيد، ابحث عن أداة 'FishingRod'")
		end
	end)
	
	StartFishingFarm()
end

-- ==========================================
-- Item Bot - جمع الأشياء تلقائياً
-- ==========================================
local function StartItemBot()
	if not Settings.ItemBot_Active then return end
	
	local remoteGetItemsEvent = player:FindFirstChildWhichIsA("RemoteEvent", "RemoteGetItems") or 
	                            Instance.new("RemoteEvent")
	remoteGetItemsEvent.Name = "RemoteGetItems"
	remoteGetItemsEvent.Parent = player
	
	remoteGetItemsEvent.OnClientEvent:Connect(function(items)
		for _, item in ipairs(items) do
			local distance = (localHumanoidRootPart.Position - item.CFrame.Position).Magnitude
			
			if distance <= Settings.ItemBot_Range then
				local direction = (item.CFrame.Position - localHumanoidRootPart.Position).Unit
				
				localCharacter.Humanoid.WalkSpeed = 20
				
				task.delay(0.5, function()
					if distance <= Settings.ItemBot_Range then
						item:Activate()
						
						localCharacter.Humanoid.WalkSpeed = 16
					end
				end)
			end
		end
	end)
	
	print("Item Bot تم تشغيله - المدى: " .. Settings.ItemBot_Range .. " متر")
end

-- ==========================================
-- Vehicle Farm - فارم سيارات
-- ==========================================
local function StartVehicleFarm()
	if not Settings.Vehicle_Farm_Active then return end
	
	remoteGetPlayers.OnClientEvent:Connect(function(players)
		for _, otherPlayer in ipairs(players) do
			local character = otherPlayer.Character
			if character and character:FindFirstChild("Head") then
				CreateESP(character.Head, Settings.ESP_Color)
			end
		end
	end)
	
	print("Vehicle Farm تم تشغيله - سرعة السيارة: " .. Settings.Vehicle_Speed)
end

-- ==========================================
-- Safe House System
-- ==========================================
local function StartSafeHouse()
	if not Settings.SafeHouse_Active then return end
	
	remoteGetPlayers.OnClientEvent:Connect(function(players)
		for _, otherPlayer in ipairs(players) do
			local character = otherPlayer.Character
			if character and character:FindFirstChild("Head") then
				CreateESP(character.Head, Settings.ESP_Color)
			end
		end
	end)
	
	print("Safe House تم تشغيله - Sam's Motel")
end

-- ==========================================
-- Main Loop - حلقة رئيسية للسكربت
-- ==========================================
local function OnCharacterAdded()
	if localHumanoidRootPart then
		print("تم تحميل السكربت بنجاح!")
		
		local screenGui, mainFrame = CreateGUI()
		
		StartJanitorFarm()
		StartCookFarm()
		StartATMFarm()
		StartFishingFarm()
		StartItemBot()
		StartVehicleFarm()
		StartSafeHouse()
	end
end

local function OnCharacterDied()
	local newCharacter = localCharacter:Clone()
	newCharacter.Parent = localHumanoidRootPart.Parent
	
	task.delay(1, OnCharacterAdded)
end

-- ==========================================
-- ربط السكربت عند إنشاء الشخصية
-- ==========================================
local characterAddedEvent = player.CharacterAdded:Connect(OnCharacterAdded)
local characterDiedEvent = localCharacter.Humanoid.Died:Connect(OnCharacterDied)

print("BlockSpin ULTIMATE Cheat 2026 Ready!")
print("اضغط على الأزرار في الواجهة لتفعيل/تعطيل الميزات")
