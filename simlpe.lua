--!strict
-- Remote Security Tester
-- LocalScript
-- ضع السكربت في StarterPlayer > StarterPlayerScripts
-- للاختبار داخل Roblox Studio

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local function getCharacter()
	return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHumanoid()
	local character = getCharacter()
	return character:FindFirstChildOfClass("Humanoid")
end

local function getValue(name: string)
	local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
	if not leaderstats then
		return nil
	end

	local obj = leaderstats:FindFirstChild(name)

	if obj and obj:IsA("ValueBase") then
		return obj.Value
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
	}
end

local function compare(before, after)
	local changes = {}

	for key, oldValue in pairs(before) do
		local newValue = after[key]

		if oldValue ~= nil
			and newValue ~= nil
			and oldValue ~= newValue then

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

	return changes
end

-- =========================================================
-- GUI
-- =========================================================

local gui = Instance.new("ScreenGui")
gui.Name = "RemoteSecurityTester"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(520, 520)
main.Position = UDim2.new(0.5, -260, 0.5, -260)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "REMOTE SECURITY TESTER"
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = main

local subtitle = Instance.new("TextLabel")
subtitle.Position = UDim2.fromOffset(15, 45)
subtitle.Size = UDim2.new(1, -30, 0, 30)
subtitle.BackgroundTransparency = 1
subtitle.Text = "LocalPlayer • Studio Security Audit"
subtitle.TextSize = 13
subtitle.Font = Enum.Font.Gotham
subtitle.TextColor3 = Color3.fromRGB(170, 170, 170)
subtitle.Parent = main

local valueBox = Instance.new("TextBox")
valueBox.Position = UDim2.fromOffset(25, 90)
valueBox.Size = UDim2.fromOffset(470, 45)
valueBox.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
valueBox.TextColor3 = Color3.new(1, 1, 1)
valueBox.PlaceholderText = "Enter speed value..."
valueBox.Text = "16"
valueBox.TextSize = 16
valueBox.Font = Enum.Font.Gotham
valueBox.ClearTextOnFocus = false
valueBox.Parent = main

local valueCorner = Instance.new("UICorner")
valueCorner.CornerRadius = UDim.new(0, 8)
valueCorner.Parent = valueBox

local testButton = Instance.new("TextButton")
testButton.Position = UDim2.fromOffset(25, 150)
testButton.Size = UDim2.fromOffset(225, 45)
testButton.BackgroundColor3 = Color3.fromRGB(55, 100, 180)
testButton.Text = "TEST UPDATE SPEED"
testButton.TextColor3 = Color3.new(1, 1, 1)
testButton.TextSize = 14
testButton.Font = Enum.Font.GothamBold
testButton.Parent = main

local testCorner = Instance.new("UICorner")
testCorner.CornerRadius = UDim.new(0, 8)
testCorner.Parent = testButton

local snapshotButton = Instance.new("TextButton")
snapshotButton.Position = UDim2.fromOffset(270, 150)
snapshotButton.Size = UDim2.fromOffset(225, 45)
snapshotButton.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
snapshotButton.Text = "CURRENT STATE"
snapshotButton.TextColor3 = Color3.new(1, 1, 1)
snapshotButton.TextSize = 14
snapshotButton.Font = Enum.Font.GothamBold
snapshotButton.Parent = main

local log = Instance.new("TextLabel")
log.Position = UDim2.fromOffset(25, 215)
log.Size = UDim2.fromOffset(470, 270)
log.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
log.TextColor3 = Color3.fromRGB(220, 220, 220)
log.TextSize = 13
log.Font = Enum.Font.Code
log.TextXAlignment = Enum.TextXAlignment.Left
log.TextYAlignment = Enum.TextYAlignment.Top
log.TextWrapped = true
log.Text = "Waiting for test...\n"
log.Parent = main

local logCorner = Instance.new("UICorner")
logCorner.CornerRadius = UDim.new(0, 8)
logCorner.Parent = log

local function write(text: string)
	log.Text ..= "\n" .. text
end

local function clearLog()
	log.Text = ""
end

-- =========================================================
-- Current State
-- =========================================================

snapshotButton.MouseButton1Click:Connect(function()
	clearLog()

	local state = snapshot()

	write("===== CURRENT STATE =====")
	write("WalkSpeed: " .. tostring(state.WalkSpeed))
	write("Wins: " .. tostring(state.Wins))
	write("Level: " .. tostring(state.Level))
	write("XP: " .. tostring(state.XP))
	write("Rebirths: " .. tostring(state.Rebirths))
end)

-- =========================================================
-- UpdateSpeed Security Test
-- =========================================================

testButton.MouseButton1Click:Connect(function()
	local remote = Remotes:FindFirstChild("UpdateSpeed")

	if not remote then
		clearLog()
		write("[ERROR] UpdateSpeed not found.")
		return
	end

	if not remote:IsA("RemoteEvent") then
		clearLog()
		write("[ERROR] UpdateSpeed is not a RemoteEvent.")
		return
	end

	local value = tonumber(valueBox.Text)

	if value == nil then
		clearLog()
		write("[ERROR] Enter a numeric value.")
		return
	end

	clearLog()

	write("===== UPDATE SPEED TEST =====")
	write("Requested value: " .. tostring(value))

	local before = snapshot()

	local ok, err = pcall(function()
		remote:FireServer(value)
	end)

	if not ok then
		write("[ERROR] Remote rejected locally:")
		write(tostring(err))
		return
	end

	task.wait(0.75)

	local after = snapshot()

	write("Server response observed.")
	write("WalkSpeed before: " .. tostring(before.WalkSpeed))
	write("WalkSpeed after:  " .. tostring(after.WalkSpeed))

	local changes = compare(before, after)

	if #changes == 0 then
		write("")
		write("[PASS]")
		write("No unauthorized state change detected.")
	else
		write("")
		write("[WARNING]")
		write("State changed after the request:")

		for _, change in ipairs(changes) do
			write("• " .. change)
		end

		write("")
		write("Review server-side validation.")
	end
end)

-- =========================================================
-- Drag Window
-- =========================================================

local UserInputService = game:GetService("UserInputService")

local dragging = false
local dragStart: Vector2
local startPosition: UDim2

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPosition = main.Position
	end
end)

title.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then
		return
	end

	if input.UserInputType ~= Enum.UserInputType.MouseMovement then
		return
	end

	local delta = input.Position - dragStart

	main.Position = UDim2.new(
		startPosition.X.Scale,
		startPosition.X.Offset + delta.X,
		startPosition.Y.Scale,
		startPosition.Y.Offset + delta.Y
	)
end)
