--!strict

--========================================================
-- BLOCKSPIN AUTO FISHER
-- Single-file Luau
--========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Backpack = Player:WaitForChild("Backpack")

--========================================================
-- SETTINGS
--========================================================

local Settings = {
	Enabled = false,

	AutoRod = true,
	AutoBait = true,
	AutoCast = true,
	AutoCatch = true,
	AutoSell = true,

	CastDistance = 500,
	WaterSamples = 72,

	CatchTolerance = 0.15,
	CatchTimeout = 20,

	AfterCatchDelay = 0.4,
	RecastDelay = 0.5,

	Sell = {
		Brown = true,
		Green = true,
		Blue = true,
		Gold = true,
		Red = true,
	},

	Debug = false,
}

--========================================================
-- STATE
--========================================================

local State = {
	Running = false,
	Busy = false,

	Character = nil :: Model?,
	Humanoid = nil :: Humanoid?,
	Root = nil :: BasePart?,

	Rod = nil :: Tool?,
	Bait = nil :: Tool?,

	LastRarity = "None",
	FishCount = 0,

	CurrentTarget = nil :: GuiObject?,
	CurrentNeedle = nil :: GuiObject?,

	Connections = {} :: {RBXScriptConnection},
}

--========================================================
-- UTIL
--========================================================

local function Log(...)
	if Settings.Debug then
		print("[AutoFish]", ...)
	end
end

local function Lower(text: string): string
	return string.lower(text)
end

local function Has(text: string, value: string): boolean
	return string.find(Lower(text), Lower(value), 1, true) ~= nil
end

local function RefreshCharacter(): boolean
	local character = Player.Character
	if not character then
		return false
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")

	if not humanoid or not root then
		return false
	end

	State.Character = character
	State.Humanoid = humanoid
	State.Root = root

	return true
end

--========================================================
-- GUI
--========================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "BlockSpinAutoFish"
Gui.ResetOnSpawn = false
Gui.Parent = PlayerGui

local Window = Instance.new("Frame")
Window.Size = UDim2.fromOffset(400, 480)
Window.Position = UDim2.new(0.5, -200, 0.5, -240)
Window.BackgroundColor3 = Color3.fromRGB(25, 27, 32)
Window.BorderSizePixel = 0
Window.Parent = Gui

Instance.new("UICorner", Window).CornerRadius = UDim.new(0, 14)

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(70, 75, 85)
Stroke.Thickness = 1
Stroke.Parent = Window

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 55)
Header.BackgroundColor3 = Color3.fromRGB(35, 38, 45)
Header.BorderSizePixel = 0
Header.Parent = Window

Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.fromOffset(16, 0)
Title.BackgroundTransparency = 1
Title.Text = "🎣 BLOCKSPIN AUTO FISH"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(35, 35)
Close.Position = UDim2.new(1, -45, 0, 10)
Close.BackgroundColor3 = Color3.fromRGB(190, 45, 45)
Close.Text = "×"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.TextSize = 24
Close.Font = Enum.Font.GothamBold
Close.Parent = Header

Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 8)

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -70)
Content.Position = UDim2.fromOffset(10, 62)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.Parent = Window

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 7)
Layout.Parent = Content

local Padding = Instance.new("UIPadding")
Padding.PaddingLeft = UDim.new(0, 5)
Padding.PaddingRight = UDim.new(0, 5)
Padding.Parent = Content

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 38)
Status.BackgroundColor3 = Color3.fromRGB(40, 43, 50)
Status.Text = "● IDLE"
Status.TextColor3 = Color3.fromRGB(255, 90, 90)
Status.TextSize = 14
Status.Font = Enum.Font.GothamBold
Status.Parent = Content

Instance.new("UICorner", Status).CornerRadius = UDim.new(0, 8)

local Stats = Instance.new("TextLabel")
Stats.Size = UDim2.new(1, 0, 0, 38)
Stats.BackgroundColor3 = Color3.fromRGB(40, 43, 50)
Stats.Text = "Fish: 0  |  Last: None"
Stats.TextColor3 = Color3.fromRGB(220, 220, 220)
Stats.TextSize = 13
Stats.Font = Enum.Font.Gotham
Stats.Parent = Content

Instance.new("UICorner", Stats).CornerRadius = UDim.new(0, 8)

local function Section(text: string)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 25)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(140, 145, 155)
	label.TextSize = 12
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = Content
end

local function Toggle(
	text: string,
	value: boolean,
	callback: (boolean) -> ()
)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, 40)
	button.TextSize = 13
	button.Font = Enum.Font.GothamBold
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.Parent = Content

	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

	local enabled = value

	local function update()
		button.Text = "   " .. text .. "     [" .. (enabled and "ON" or "OFF") .. "]"

		button.BackgroundColor3 = enabled
			and Color3.fromRGB(30, 125, 55)
			or Color3.fromRGB(50, 53, 60)
	end

	update()

	button.MouseButton1Click:Connect(function()
		enabled = not enabled
		update()
		callback(enabled)
	end)

	return button
end

Section("AUTOMATION")

Toggle("Auto Farm", false, function(value)
	Settings.Enabled = value
	State.Running = value

	if value then
		Status.Text = "● RUNNING"
		Status.TextColor3 = Color3.fromRGB(50, 255, 90)
	else
		Status.Text = "● STOPPED"
		Status.TextColor3 = Color3.fromRGB(255, 90, 90)
	end
end)

Toggle("Auto Rod", true, function(v)
	Settings.AutoRod = v
end)

Toggle("Auto Bait", true, function(v)
	Settings.AutoBait = v
end)

Toggle("Auto Cast", true, function(v)
	Settings.AutoCast = v
end)

Toggle("Auto Catch", true, function(v)
	Settings.AutoCatch = v
end)

Toggle("Auto Sell", true, function(v)
	Settings.AutoSell = v
end)

Section("SELL / DISCARD")

for _, rarity in ipairs({
	"Brown",
	"Green",
	"Blue",
	"Gold",
	"Red",
}) do
	Toggle("Sell " .. rarity, true, function(v)
		Settings.Sell[rarity] = v
	end)
end

--========================================================
-- ROD
--========================================================

local function FindRod(): Tool?
	RefreshCharacter()

	if State.Character then
		for _, object in ipairs(State.Character:GetChildren()) do
			if object:IsA("Tool") then
				local name = Lower(object.Name)

				if Has(name, "rod")
					or Has(name, "fishing")
					or Has(name, "pole")
				then
					return object
				end
			end
		end
	end

	for _, object in ipairs(Backpack:GetChildren()) do
		if object:IsA("Tool") then
			local name = Lower(object.Name)

			if Has(name, "rod")
				or Has(name, "fishing")
				or Has(name, "pole")
			then
				return object
			end
		end
	end

	return nil
end

local function EquipRod(): boolean
	if not RefreshCharacter() then
		return false
	end

	local humanoid = State.Humanoid
	if not humanoid then
		return false
	end

	local rod = FindRod()

	if not rod then
		Log("No rod found")
		return false
	end

	if rod.Parent ~= State.Character then
		humanoid:EquipTool(rod)
		task.wait(0.2)
	end

	State.Rod = rod

	return true
end

--========================================================
-- BAIT
--========================================================

local function FindBait(): Tool?
	local function search(container: Instance): Tool?
		for _, object in ipairs(container:GetChildren()) do
			if object:IsA("Tool") then
				local name = Lower(object.Name)

				if Has(name, "bait")
					or Has(name, "worm")
					or Has(name, "prawn")
				then
					return object
				end
			end
		end

		return nil
	end

	if State.Character then
		local bait = search(State.Character)
		if bait then
			return bait
		end
	end

	return search(Backpack)
end

local function AttachBait(): boolean
	local rod = State.Rod

	if not rod then
		return false
	end

	local bait = FindBait()

	if not bait then
		Log("No bait found")
		return false
	end

	State.Bait = bait

	-- إذا كان نظام لعبتك يستخدم Tool لتجهيز الطعم
	if bait.Parent ~= State.Character then
		local humanoid = State.Humanoid

		if humanoid then
			humanoid:EquipTool(bait)
			task.wait(0.15)
		end
	end

	pcall(function()
		bait:Activate()
	end)

	-- بعض أنظمة الصيد تضع الـBait كـAttribute
	pcall(function()
		rod:SetAttribute("Bait", bait.Name)
	end)

	task.wait(0.15)

	return true
end

--========================================================
-- FIND FARTHEST WATER
--========================================================

local function FindFarthestWater(): Vector3?
	local root = State.Root

	if not root then
		return nil
	end

	local origin = root.Position
	local bestPosition: Vector3? = nil
	local bestDistance = 0

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {
		State.Character
	}

	for i = 0, Settings.WaterSamples - 1 do
		local angle = (math.pi * 2 / Settings.WaterSamples) * i

		local direction = Vector3.new(
			math.cos(angle),
			0,
			math.sin(angle)
		)

		local result = Workspace:Raycast(
			origin + Vector3.new(0, 3, 0),
			direction * Settings.CastDistance,
			rayParams
		)

		if result then
			if result.Material == Enum.Material.Water then
				local distance = (result.Position - origin).Magnitude

				if distance > bestDistance then
					bestDistance = distance
					bestPosition = result.Position
				end
			end
		end
	end

	return bestPosition
end

--========================================================
-- AIM + CAST
--========================================================

local function AimAt(position: Vector3)
	local root = State.Root

	if not root then
		return
	end

	local flatTarget = Vector3.new(
		position.X,
		root.Position.Y,
		position.Z
	)

	root.CFrame = CFrame.lookAt(
		root.Position,
		flatTarget
	)
end

local function Cast(): boolean
	local rod = State.Rod

	if not rod then
		return false
	end

	local water = FindFarthestWater()

	if water then
		AimAt(water)
		task.wait(0.15)
	end

	pcall(function()
		rod:Activate()
	end)

	return true
end

--========================================================
-- GREEN TARGET
--========================================================

local function IsGreen(color: Color3): boolean
	return color.G > 0.35
		and color.G > color.R * 1.35
		and color.G > color.B * 1.15
end

local function FindGreenTarget(): GuiObject?
	local best: GuiObject? = nil
	local bestArea = math.huge

	for _, object in ipairs(PlayerGui:GetDescendants()) do
		if object:IsA("GuiObject") and object.Visible then

			local color = object.BackgroundColor3

			if IsGreen(color) then
				local size = object.AbsoluteSize

				if size.X > 8 and size.Y > 8 then
					local area = size.X * size.Y

					if area < bestArea then
						bestArea = area
						best = object
					end
				end
			end
		end
	end

	return best
end

--========================================================
-- NEEDLE
--========================================================

local function FindNeedle(target: GuiObject): GuiObject?
	local targetCenter =
		target.AbsolutePosition
		+ target.AbsoluteSize / 2

	local best: GuiObject? = nil
	local bestDistance = math.huge

	for _, object in ipairs(PlayerGui:GetDescendants()) do
		if object:IsA("GuiObject")
			and object.Visible
			and object ~= target
		then

			local size = object.AbsoluteSize

			if size.X <= 20 or size.Y <= 20 then
				local center =
					object.AbsolutePosition
					+ size / 2

				local distance =
					math.abs(center.X - targetCenter.X)

				if distance < bestDistance then
					bestDistance = distance
					best = object
				end
			end
		end
	end

	return best
end

--========================================================
-- TARGET TEST
--========================================================

local function NeedleInside(
	needle: GuiObject,
	target: GuiObject
): boolean

	local point =
		needle.AbsolutePosition
		+ needle.AbsoluteSize / 2

	local pos = target.AbsolutePosition
	local size = target.AbsoluteSize

	local tolerance = size.X * Settings.CatchTolerance

	return point.X >= pos.X - tolerance
		and point.X <= pos.X + size.X + tolerance
end

--========================================================
-- CATCH BUTTON
--========================================================

local function FindCatchButton(): GuiButton?
	for _, object in ipairs(PlayerGui:GetDescendants()) do
		if object:IsA("GuiButton")
			and object.Visible
		then

			local name = Lower(object.Name)
			local text = Lower(object.Text)

			if Has(name, "catch")
				or Has(name, "reel")
				or Has(name, "fish")
				or Has(text, "catch")
				or Has(text, "click")
				or Has(text, "reel")
			then
				return object
			end
		end
	end

	return nil
end

local function PressCatch(): boolean
	local button = FindCatchButton()

	if button then
		pcall(function()
			button:Activate()
		end)

		return true
	end

	return false
end

--========================================================
-- AUTO CATCH
--========================================================

local function AutoCatch(): boolean
	local timeout = os.clock() + Settings.CatchTimeout

	while State.Running
		and Settings.AutoCatch
		and os.clock() < timeout
	do

		-- نعيد البحث كل Frame لأن الـGreen يصغر ويتغير
		local target = FindGreenTarget()

		if target then
			State.CurrentTarget = target

			local needle = FindNeedle(target)

			if needle then
				State.CurrentNeedle = needle

				if NeedleInside(needle, target) then
					local clicked = PressCatch()

					if clicked then
						-- لا ننتظر وقتًا ثابتًا.
						-- نرجع مباشرة نبحث عن Green الجديد.
						task.wait(0.025)
					end
				end
			end
		end

		RunService.RenderStepped:Wait()
	end

	return true
end

--========================================================
-- RARITY
--========================================================

local function DetectFishRarity(): string
	task.wait(Settings.AfterCatchDelay)

	-- أولوية للنصوص التي تظهر بعد الصيد
	for _, object in ipairs(PlayerGui:GetDescendants()) do
		if object:IsA("TextLabel")
			or object:IsA("TextButton")
		then
			if object.Visible then
				local text = object.Text

				for _, rarity in ipairs({
					"Brown",
					"Green",
					"Blue",
					"Purple",
					"Gold",
					"Red",
				}) do
					if Has(text, rarity) then
						return rarity
					end
				end
			end
		end
	end

	-- دعم Attributes لو كانت لعبتك تستخدمها
	if State.Character then
		for _, object in ipairs(State.Character:GetDescendants()) do
			local rarity = object:GetAttribute("Rarity")

			if typeof(rarity) == "string" then
				return rarity
			end
		end
	end

	return "Unknown"
end

--========================================================
-- SELL
--========================================================

local function SellFish()
	local button: GuiButton? = nil

	for _, object in ipairs(PlayerGui:GetDescendants()) do
		if object:IsA("GuiButton") and object.Visible then
			local name = Lower(object.Name)
			local text = Lower(object.Text)

			if Has(name, "sell")
				or Has(name, "discard")
				or Has(text, "sell")
				or Has(text, "discard")
			then
				button = object
				break
			end
		end
	end

	if button then
		pcall(function()
			button:Activate()
		end)
	end
end

--========================================================
-- FISH CYCLE
--========================================================

local function RunCycle()
	if State.Busy then
		return
	end

	State.Busy = true

	Status.Text = "● PREPARING"
	Status.TextColor3 = Color3.fromRGB(255, 210, 70)

	if not RefreshCharacter() then
		State.Busy = false
		return
	end

	-- Rod
	if Settings.AutoRod then
		if not EquipRod() then
			State.Busy = false
			task.wait(1)
			return
		end
	end

	-- Bait
	if Settings.AutoBait then
		AttachBait()
	end

	task.wait(0.2)

	-- Cast
	if Settings.AutoCast then
		Status.Text = "● CASTING"
		Cast()
	end

	-- Catch
	if Settings.AutoCatch then
		Status.Text = "● CATCHING"
		AutoCatch()
	end

	-- Result
	local rarity = DetectFishRarity()

	State.LastRarity = rarity
	State.FishCount += 1

	Stats.Text =
		"Fish: "
		.. tostring(State.FishCount)
		.. "  |  Last: "
		.. rarity

	-- Sell only selected rarities
	if Settings.AutoSell
		and Settings.Sell[rarity] == true
	then

		Status.Text = "● SELLING"
		SellFish()
	end

	task.wait(Settings.RecastDelay)

	State.Busy = false
end

--========================================================
-- MAIN LOOP
--========================================================

task.spawn(function()
	while Gui.Parent do

		if State.Running then
			RunCycle()
		end

		task.wait(0.05)
	end
end)

--========================================================
-- CHARACTER RESET
--========================================================

Player.CharacterAdded:Connect(function()
	task.wait(1)

	State.Character = nil
	State.Humanoid = nil
	State.Root = nil
	State.Rod = nil
	State.Bait = nil
	State.Busy = false

	RefreshCharacter()
end)

--========================================================
-- DRAG
--========================================================

local dragging = false
local dragStart: Vector2
local startPosition: UDim2

Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPosition = Window.Position
	end
end)

Header.InputEnded:Connect(function(input)
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

	Window.Position = UDim2.new(
		startPosition.X.Scale,
		startPosition.X.Offset + delta.X,
		startPosition.Y.Scale,
		startPosition.Y.Offset + delta.Y
	)
end)

Close.MouseButton1Click:Connect(function()
	State.Running = false
	Gui:Destroy()
end)

--========================================================
-- START
--========================================================

RefreshCharacter()

print("[BlockSpin] Auto Fisher loaded.")
