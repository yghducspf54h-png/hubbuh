--!strict
--============================================================
-- REMOTE SECURITY TESTER
-- LocalScript / LocalPlayer
--============================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")

if not RemotesFolder then
	warn("[SecurityTester] ReplicatedStorage.Remotes not found")
	return
end

--============================================================
-- CONFIG
--============================================================

local CONFIG = {
	WaitAfterRemote = 0.75,

	-- Values used for UpdateSpeed testing
	SpeedTests = {
		0,
		-50,
		50,
		100,
		500,
		999999,
	},

	-- Deliberately invalid identifiers
	InvalidTrail = "__SECURITY_TEST_INVALID_TRAIL__",
	InvalidCurrency = "__SECURITY_TEST_INVALID_CURRENCY__",
	InvalidAward = "__SECURITY_TEST_INVALID_AWARD__",
	InvalidShopCommand = "__SECURITY_TEST_INVALID_SHOP_COMMAND__",
}

--============================================================
-- STATE
--============================================================

local TestRunning = false
local TestCounter = 0

--============================================================
-- UTILITY
--============================================================

local function getHumanoid(): Humanoid?
	local character = Player.Character

	if not character then
		return nil
	end

	return character:FindFirstChildOfClass("Humanoid")
end

local function getValue(name: string)
	local leaderstats = Player:FindFirstChild("leaderstats")

	if leaderstats then
		local object = leaderstats:FindFirstChild(name)

		if object and object:IsA("ValueBase") then
			return object.Value
		end
	end

	-- Also check player directly.
	local direct = Player:FindFirstChild(name)

	if direct and direct:IsA("ValueBase") then
		return direct.Value
	end

	return nil
end

local function snapshot()
	local humanoid = getHumanoid()

	return {
		WalkSpeed = humanoid and humanoid.WalkSpeed or nil,

		Wins = getValue("Wins"),
		Level = getValue("Level"),
		XP = getValue("XP"),
		Rebirths = getValue("Rebirths"),

		-- Optional values if your game has them
		Multiplier = getValue("Multiplier"),
		CurrentSpeedTier = getValue("CurrentSpeedTier"),
	}
end

local function compareSnapshots(before, after)
	local changes = {}

	for key, oldValue in pairs(before) do
		local newValue = after[key]

		if oldValue ~= nil and newValue ~= nil then
			if oldValue ~= newValue then
				table.insert(
					changes,
					string.format(
						"%s: %s -> %s",
						key,
						tostring(oldValue),
						tostring(newValue)
					)
				)
			end
		end
	end

	return changes
end

local function getRemote(name: string)
	local remote = RemotesFolder:FindFirstChild(name)

	if not remote then
		return nil, "Remote not found"
	end

	return remote, nil
end

--============================================================
-- GUI
--============================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "RemoteSecurityTester"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(650, 650)
Main.Position = UDim2.new(0.5, -325, 0.5, -325)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Main.BorderSizePixel = 0
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = Main

--============================================================
-- TITLE
--============================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "REMOTE SECURITY TESTER"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 21
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Parent = Main

local Subtitle = Instance.new("TextLabel")
Subtitle.Position = UDim2.fromOffset(20, 42)
Subtitle.Size = UDim2.new(1, -40, 0, 30)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "LocalPlayer • Defensive Remote Validation"
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 13
Subtitle.TextColor3 = Color3.fromRGB(160, 160, 170)
Subtitle.Parent = Main

--============================================================
-- STATUS
--============================================================

local Status = Instance.new("TextLabel")
Status.Position = UDim2.fromOffset(20, 76)
Status.Size = UDim2.new(1, -40, 0, 30)
Status.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
Status.Text = "READY"
Status.Font = Enum.Font.GothamBold
Status.TextSize = 13
Status.TextColor3 = Color3.fromRGB(100, 220, 120)
Status.Parent = Main

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 7)
StatusCorner.Parent = Status

--============================================================
-- SPEED INPUT
--============================================================

local SpeedBox = Instance.new("TextBox")
SpeedBox.Position = UDim2.fromOffset(20, 120)
SpeedBox.Size = UDim2.fromOffset(300, 42)
SpeedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.PlaceholderText = "Speed value"
SpeedBox.Text = "10000"
SpeedBox.Font = Enum.Font.Code
SpeedBox.TextSize = 15
SpeedBox.ClearTextOnFocus = false
SpeedBox.Parent = Main

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 7)
SpeedCorner.Parent = SpeedBox

--============================================================
-- LOG
--============================================================

local LogFrame = Instance.new("ScrollingFrame")
LogFrame.Position = UDim2.fromOffset(20, 350)
LogFrame.Size = UDim2.fromOffset(610, 280)
LogFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
LogFrame.BorderSizePixel = 0
LogFrame.ScrollBarThickness = 6
LogFrame.CanvasSize = UDim2.fromOffset(0, 0)
LogFrame.Parent = Main

local LogCorner = Instance.new("UICorner")
LogCorner.CornerRadius = UDim.new(0, 8)
LogCorner.Parent = LogFrame

local LogText = Instance.new("TextLabel")
LogText.Position = UDim2.fromOffset(12, 10)
LogText.Size = UDim2.new(1, -24, 0, 0)
LogText.AutomaticSize = Enum.AutomaticSize.Y
LogText.BackgroundTransparency = 1
LogText.Text = ""
LogText.TextColor3 = Color3.fromRGB(220, 220, 220)
LogText.Font = Enum.Font.Code
LogText.TextSize = 13
LogText.TextWrapped = true
LogText.TextXAlignment = Enum.TextXAlignment.Left
LogText.TextYAlignment = Enum.TextYAlignment.Top
LogText.Parent = LogFrame

local function log(message: string)
	print("[SecurityTester] " .. message)

	if LogText.Text == "" then
		LogText.Text = message
	else
		LogText.Text ..= "\n" .. message
	end

	task.defer(function()
		LogFrame.CanvasPosition = Vector2.new(
			0,
			math.max(
				0,
				LogText.AbsoluteSize.Y - LogFrame.AbsoluteSize.Y
			)
		)
	end)
end

local function clearLog()
	LogText.Text = ""
end

--============================================================
-- BUTTON CREATOR
--============================================================

local function createButton(
	text: string,
	position: UDim2,
	callback
)
	local button = Instance.new("TextButton")

	button.Size = UDim2.fromOffset(295, 42)
	button.Position = position
	button.BackgroundColor3 = Color3.fromRGB(42, 42, 50)
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = Color3.fromRGB(235, 235, 235)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 13
	button.Parent = Main

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = button

	button.MouseButton1Click:Connect(callback)

	return button
end

--============================================================
-- TEST ENGINE
--============================================================

local function beginTest(name: string)
	if TestRunning then
		log("[BUSY] Another test is already running.")
		return false
	end

	TestRunning = true
	TestCounter += 1

	Status.Text = "RUNNING: " .. name
	Status.TextColor3 = Color3.fromRGB(255, 210, 80)

	log("")
	log("================================================")
	log("TEST #" .. TestCounter .. " : " .. name)
	log("================================================")

	return true
end

local function finishTest()
	TestRunning = false
	Status.Text = "READY"
	Status.TextColor3 = Color3.fromRGB(100, 220, 120)
end

local function reportChanges(before, after)
	local changes = compareSnapshots(before, after)

	if #changes == 0 then
		log("[PASS] No monitored state changed.")
	else
		log("[WARNING] State changed:")

		for _, change in ipairs(changes) do
			log("  " .. change)
		end
	end
end

--============================================================
-- UPDATE SPEED
--============================================================

local function testUpdateSpeed(value: number)
	local remote, errorMessage = getRemote("UpdateSpeed")

	if not remote then
		log("[ERROR] UpdateSpeed: " .. tostring(errorMessage))
		return
	end

	if not remote:IsA("RemoteEvent") then
		log("[ERROR] UpdateSpeed is not RemoteEvent.")
		return
	end

	local before = snapshot()

	log("")
	log("[UpdateSpeed]")
	log("Requested = " .. tostring(value))
	log("Before WalkSpeed = " .. tostring(before.WalkSpeed))

	local success, err = pcall(function()
		remote:FireServer(value)
	end)

	if not success then
		log("[REMOTE ERROR] " .. tostring(err))
		return
	end

	task.wait(CONFIG.WaitAfterRemote)

	local after = snapshot()

	log("After WalkSpeed = " .. tostring(after.WalkSpeed))

	if before.WalkSpeed == after.WalkSpeed then
		log("[PASS] WalkSpeed unchanged.")
	else
		log("[WARNING] WalkSpeed changed.")
	end

	reportChanges(before, after)
end

--============================================================
-- INVALID BUY TRAIL
--============================================================

local function testBuyTrail()
	local remote, errorMessage = getRemote("BuyTrail")

	if not remote then
		log("[ERROR] BuyTrail: " .. tostring(errorMessage))
		return
	end

	if not remote:IsA("RemoteFunction") then
		log("[ERROR] BuyTrail is not RemoteFunction.")
		return
	end

	local before = snapshot()

	log("")
	log("[BuyTrail]")
	log("Trail = " .. CONFIG.InvalidTrail)
	log("Currency = " .. CONFIG.InvalidCurrency)

	local success, result = pcall(function()
		return remote:InvokeServer(
			CONFIG.InvalidTrail,
			CONFIG.InvalidCurrency
		)
	end)

	log("Invoke success = " .. tostring(success))
	log("Server return = " .. tostring(result))

	task.wait(CONFIG.WaitAfterRemote)

	local after = snapshot()

	reportChanges(before, after)
end

--============================================================
-- INVALID EQUIP AWARD
--============================================================

local function testEquipAward()
	local remote, errorMessage = getRemote("EquipStepAward")

	if not remote then
		log("[ERROR] EquipStepAward: " .. tostring(errorMessage))
		return
	end

	if not remote:IsA("RemoteEvent") then
		log("[ERROR] EquipStepAward is not RemoteEvent.")
		return
	end

	local before = snapshot()

	log("")
	log("[EquipStepAward]")
	log("Award = " .. CONFIG.InvalidAward)

	local success, err = pcall(function()
		remote:FireServer(CONFIG.InvalidAward)
	end)

	if not success then
		log("[REMOTE ERROR] " .. tostring(err))
	end

	task.wait(CONFIG.WaitAfterRemote)

	local after = snapshot()

	reportChanges(before, after)
end

--============================================================
-- INVALID TREADMILL SIGNAL
--============================================================

local function testTreadmillSignal()
	local remote, errorMessage = getRemote("TreadmillSignal")

	if not remote then
		log("[ERROR] TreadmillSignal: " .. tostring(errorMessage))
		return
	end

	if not remote:IsA("RemoteEvent") then
		log("[ERROR] TreadmillSignal is not RemoteEvent.")
		return
	end

	local before = snapshot()

	log("")
	log("[TreadmillSignal]")
	log("Testing invalid argument.")

	local success, err = pcall(function()
		remote:FireServer(
			"__INVALID_SECURITY_TEST__"
		)
	end)

	if not success then
		log("[REMOTE ERROR] " .. tostring(err))
	end

	task.wait(CONFIG.WaitAfterRemote)

	local after = snapshot()

	reportChanges(before, after)
end

--============================================================
-- INVALID FUNNEL SHOP
--============================================================

local function testFunnelShop()
	local remote, errorMessage = getRemote("FunnelShop")

	if not remote then
		log("[ERROR] FunnelShop: " .. tostring(errorMessage))
		return
	end

	if not remote:IsA("RemoteEvent") then
		log("[ERROR] FunnelShop is not RemoteEvent.")
		return
	end

	local before = snapshot()

	log("")
	log("[FunnelShop]")
	log("Testing invalid command.")

	local success, err = pcall(function()
		remote:FireServer(
			CONFIG.InvalidShopCommand
		)
	end)

	if not success then
		log("[REMOTE ERROR] " .. tostring(err))
	end

	task.wait(CONFIG.WaitAfterRemote)

	local after = snapshot()

	reportChanges(before, after)
end

--============================================================
-- BUTTONS
--============================================================

createButton(
	"TEST CUSTOM SPEED",
	UDim2.fromOffset(20, 175),
	function()
		if not beginTest("CUSTOM SPEED") then
			return
		end

		local value = tonumber(SpeedBox.Text)

		if not value then
			log("[ERROR] Invalid numeric value.")
			finishTest()
			return
		end

		testUpdateSpeed(value)

		finishTest()
	end
)

createButton(
	"TEST EXTREME SPEED",
	UDim2.fromOffset(335, 175),
	function()
		if not beginTest("EXTREME SPEED") then
			return
		end

		testUpdateSpeed(999999)

		finishTest()
	end
)

createButton(
	"TEST NEGATIVE SPEED",
	UDim2.fromOffset(20, 225),
	function()
		if not beginTest("NEGATIVE SPEED") then
			return
		end

		testUpdateSpeed(-999999)

		finishTest()
	end
)

createButton(
	"TEST INVALID TRAIL",
	UDim2.fromOffset(335, 225),
	function()
		if not beginTest("INVALID TRAIL") then
			return
		end

		testBuyTrail()

		finishTest()
	end
)

createButton(
	"TEST INVALID AWARD",
	UDim2.fromOffset(20, 275),
	function()
		if not beginTest("INVALID AWARD") then
			return
		end

		testEquipAward()

		finishTest()
	end
)

createButton(
	"TEST INVALID TREADMILL",
	UDim2.fromOffset(335, 275),
	function()
		if not beginTest("INVALID TREADMILL") then
			return
		end

		testTreadmillSignal()

		finishTest()
	end
)

createButton(
	"TEST INVALID SHOP COMMAND",
	UDim2.fromOffset(20, 320),
	function()
		if not beginTest("INVALID SHOP COMMAND") then
			return
		end

		testFunnelShop()

		finishTest()
	end
)

createButton(
	"CLEAR LOG",
	UDim2.fromOffset(335, 320),
	function()
		clearLog()
		Status.Text = "READY"
	end
)

--============================================================
-- CURRENT STATE ON START
--============================================================

task.defer(function()
	log("Remote Security Tester initialized.")
	log("Player = " .. Player.Name)
	log("Remotes folder = " .. RemotesFolder:GetFullName())

	local expectedRemotes = {
		"FunnelShop",
		"BuyTrail",
		"EquipStepAward",
		"Rebirth",
		"TreadmillSignal",
		"PromptOwnerTreadmill",
		"UpdateSpeed",
	}

	log("")
	log("Detected remotes:")

	for _, name in ipairs(expectedRemotes) do
		local remote = RemotesFolder:FindFirstChild(name)

		if remote then
			log(
				"  [FOUND] "
					.. name
					.. " ("
					.. remote.ClassName
					.. ")"
			)
		else
			log("  [MISSING] " .. name)
		end
	end

	local state = snapshot()

	log("")
	log("===== INITIAL STATE =====")
	log("WalkSpeed = " .. tostring(state.WalkSpeed))
	log("Wins = " .. tostring(state.Wins))
	log("Level = " .. tostring(state.Level))
	log("XP = " .. tostring(state.XP))
	log("Rebirths = " .. tostring(state.Rebirths))
end)

--============================================================
-- DRAG WINDOW
--============================================================

local Dragging = false
local DragStart: Vector2
local StartPosition: UDim2

Title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		Dragging = true
		DragStart = input.Position
		StartPosition = Main.Position
	end
end)

Title.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		Dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not Dragging then
		return
	end

	if input.UserInputType ~= Enum.UserInputType.MouseMovement then
		return
	end

	local Delta = input.Position - DragStart

	Main.Position = UDim2.new(
		StartPosition.X.Scale,
		StartPosition.X.Offset + Delta.X,
		StartPosition.Y.Scale,
		StartPosition.Y.Offset + Delta.Y
	)
end)
