--!strict
--========================================================
-- BLOCKSPIN AUTO FISHER
-- Single-file / Arabic GUI / Expand & Minimize
--========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
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

	FarCast = true,

	CastDistance = 1000,
	CatchTimeout = 30,

	Sell = {
		Brown = true,
		Green = true,
		Blue = true,
		Purple = true,
		Gold = true,
		Red = true,
	},
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

	FishCount = 0,
	LastRarity = "لا يوجد",
	Phase = "متوقف",
}

--========================================================
-- CHARACTER
--========================================================

local function RefreshCharacter()
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

Player.CharacterAdded:Connect(function()
	task.wait(1)
	RefreshCharacter()
end)

RefreshCharacter()

--========================================================
-- GUI
--========================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "BlockSpinAutoFarm"
Gui.ResetOnSpawn = false
Gui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(430, 560)
Main.Position = UDim2.new(0.5, -215, 0.5, -280)
Main.BackgroundColor3 = Color3.fromRGB(25, 27, 32)
Main.BorderSizePixel = 0
Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 1
Stroke.Color = Color3.fromRGB(80, 85, 95)
Stroke.Parent = Main

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 55)
Header.BackgroundColor3 = Color3.fromRGB(38, 41, 48)
Header.BorderSizePixel = 0
Header.Parent = Main

Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -150, 1, 0)
Title.Position = UDim2.fromOffset(15, 0)
Title.BackgroundTransparency = 1
Title.Text = "🎣 مزرعة الصيد"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Language = Instance.new("TextButton")
Language.Size = UDim2.fromOffset(65, 34)
Language.Position = UDim2.new(1, -140, 0, 10)
Language.BackgroundColor3 = Color3.fromRGB(55, 60, 70)
Language.Text = "عربي"
Language.TextColor3 = Color3.new(1, 1, 1)
Language.TextSize = 13
Language.Font = Enum.Font.GothamBold
Language.Parent = Header

Instance.new("UICorner", Language).CornerRadius = UDim.new(0, 8)

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.fromOffset(32, 34)
Minimize.Position = UDim2.new(1, -70, 0, 10)
Minimize.BackgroundColor3 = Color3.fromRGB(55, 60, 70)
Minimize.Text = "—"
Minimize.TextColor3 = Color3.new(1, 1, 1)
Minimize.TextSize = 20
Minimize.Font = Enum.Font.GothamBold
Minimize.Parent = Header

Instance.new("UICorner", Minimize).CornerRadius = UDim.new(0, 8)

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(32, 34)
Close.Position = UDim2.new(1, -35, 0, 10)
Close.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
Close.Text = "×"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.TextSize = 20
Close.Font = Enum.Font.GothamBold
Close.Parent = Header

Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 8)

-- Content
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -70)
Content.Position = UDim2.fromOffset(10, 65)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 7)
Layout.Parent = Content

local Padding = Instance.new("UIPadding")
Padding.PaddingLeft = UDim.new(0, 5)
Padding.PaddingRight = UDim.new(0, 5)
Padding.Parent = Content

--========================================================
-- GUI HELPERS
--========================================================

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 42)
Status.BackgroundColor3 = Color3.fromRGB(42, 45, 52)
Status.Text = "● متوقف"
Status.TextColor3 = Color3.fromRGB(255, 90, 90)
Status.TextSize = 14
Status.Font = Enum.Font.GothamBold
Status.Parent = Content

Instance.new("UICorner", Status).CornerRadius = UDim.new(0, 8)

local Stats = Instance.new("TextLabel")
Stats.Size = UDim2.new(1, 0, 0, 42)
Stats.BackgroundColor3 = Color3.fromRGB(42, 45, 52)
Stats.Text = "السمك: 0   |   آخر سمكة: لا يوجد"
Stats.TextColor3 = Color3.new(1, 1, 1)
Stats.TextSize = 13
Stats.Font = Enum.Font.Gotham
Stats.Parent = Content

Instance.new("UICorner", Stats).CornerRadius = UDim.new(0, 8)

local function Section(text)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 25)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(150, 155, 165)
	label.TextSize = 12
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = Content
end

local function MakeToggle(text, initial, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, 40)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextSize = 13
	button.Font = Enum.Font.GothamBold
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.Parent = Content

	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

	local value = initial

	local function Update()
		button.Text = "   " .. text .. "     [" .. (value and "ON" or "OFF") .. "]"
		button.BackgroundColor3 =
			value
			and Color3.fromRGB(30, 120, 55)
			or Color3.fromRGB(50, 53, 60)
	end

	Update()

	button.MouseButton1Click:Connect(function()
		value = not value
		Update()
		callback(value)
	end)

	return button
end

--========================================================
-- OPTIONS
--========================================================

Section("⚙️ التحكم")

MakeToggle("تشغيل Auto Farm", false, function(v)
	Settings.Enabled = v
	State.Running = v

	if v then
		Status.Text = "● يعمل"
		Status.TextColor3 = Color3.fromRGB(60, 255, 90)
	else
		Status.Text = "● متوقف"
		Status.TextColor3 = Color3.fromRGB(255, 90, 90)
	end
end)

MakeToggle("تركيب الطعم تلقائيًا", true, function(v)
	Settings.AutoBait = v
end)

MakeToggle("الرمي تلقائيًا", true, function(v)
	Settings.AutoCast = v
end)

MakeToggle("الرمي لأبعد نقطة", true, function(v)
	Settings.FarCast = v
end)

MakeToggle("الصيد التلقائي", true, function(v)
	Settings.AutoCatch = v
end)

MakeToggle("البيع التلقائي", true, function(v)
	Settings.AutoSell = v
end)

Section("💰 البيع")

for _, rarity in ipairs({
	"Brown",
	"Green",
	"Blue",
	"Purple",
	"Gold",
	"Red",
}) do
	MakeToggle("بيع " .. rarity, true, function(v)
		Settings.Sell[rarity] = v
	end)
end

--========================================================
-- ROD DETECTION
--========================================================

local function FindRod(): Tool?
	if State.Character then
		for _, object in ipairs(State.Character:GetChildren()) do
			if object:IsA("Tool") then
				local n = string.lower(object.Name)

				if string.find(n, "rod")
					or string.find(n, "fishing")
				then
					return object
				end
			end
		end
	end

	for _, object in ipairs(Backpack:GetChildren()) do
		if object:IsA("Tool") then
			local n = string.lower(object.Name)

			if string.find(n, "rod")
				or string.find(n, "fishing")
			then
				return object
			end
		end
	end

	return nil
end

local function EquipRod()
	if not RefreshCharacter() then
		return false
	end

	local rod = FindRod()

	if not rod then
		return false
	end

	State.Rod = rod

	if rod.Parent ~= State.Character then
		State.Humanoid:EquipTool(rod)
		task.wait(0.25)
	end

	return true
end

--========================================================
-- BAIT DETECTION
--========================================================

local function FindBait(): Tool?
	local containers = {
		State.Character,
		Backpack,
	}

	for _, container in ipairs(containers) do
		if container then
			for _, object in ipairs(container:GetChildren()) do
				if object:IsA("Tool") then
					local n = string.lower(object.Name)

					if string.find(n, "bait")
						or string.find(n, "worm")
						or string.find(n, "prawn")
					then
						return object
					end
				end
			end
		end
	end

	return nil
end

local function AttachBait()
	if not State.Rod then
		return false
	end

	local bait = FindBait()

	if not bait then
		return false
	end

	State.Bait = bait

	-- تجهيز الطعم
	if bait.Parent ~= State.Character then
		State.Humanoid:EquipTool(bait)
		task.wait(0.15)
	end

	-- تنفيذ Activate إذا كانت لعبتك تستخدم Tool activation
	pcall(function()
		bait:Activate()
	end)

	task.wait(0.15)

	return true
end

--========================================================
-- FAR CAST
--========================================================

local function FindFarWater(): Vector3?
	if not State.Root then
		return nil
	end

	local origin = State.Root.Position
	local farthest = nil
	local maxDistance = 0

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {
		State.Character
	}

	for i = 0, 71 do
		local angle = (math.pi * 2 / 72) * i

		local direction = Vector3.new(
			math.cos(angle),
			0,
			math.sin(angle)
		)

		local result = Workspace:Raycast(
			origin + Vector3.new(0, 5, 0),
			direction * Settings.CastDistance,
			params
		)

		if result and result.Material == Enum.Material.Water then
			local distance =
				(result.Position - origin).Magnitude

			if distance > maxDistance then
				maxDistance = distance
				farthest = result.Position
			end
		end
	end

	return farthest
end

local function CastRod()
	if not State.Rod then
		return false
	end

	if Settings.FarCast then
		local water = FindFarWater()

		if water and State.Root then
			local look = Vector3.new(
				water.X,
				State.Root.Position.Y,
				water.Z
			)

			State.Root.CFrame =
				CFrame.lookAt(
					State.Root.Position,
					look
				)

			task.wait(0.15)
		end
	end

	pcall(function()
		State.Rod:Activate()
	end)

	return true
end

--========================================================
-- MINIGAME DETECTION
--========================================================

local function IsGreen(c: Color3)
	return c.G > 0.35
		and c.G > c.R * 1.3
		and c.G > c.B * 1.1
end

local function FindGreen(): GuiObject?
	local best = nil
	local smallest = math.huge

	for _, object in ipairs(PlayerGui:GetDescendants()) do
		if object:IsA("GuiObject") and object.Visible then
			local size = object.AbsoluteSize

			if size.X > 10 and size.Y > 5 then
				if IsGreen(object.BackgroundColor3) then
					local area = size.X * size.Y

					if area < smallest then
						smallest = area
						best = object
					end
				end
			end
		end
	end

	return best
end

local function FindNeedle(target: GuiObject): GuiObject?
	local targetCenter =
		target.AbsolutePosition
		+ target.AbsoluteSize / 2

	local nearest = nil
	local distance = math.huge

	for _, object in ipairs(PlayerGui:GetDescendants()) do
		if object:IsA("GuiObject")
			and object.Visible
			and object ~= target
		then

			local size = object.AbsoluteSize

			if size.X <= 12
				and size.Y >= 20
			then
				local center =
					object.AbsolutePosition
					+ size / 2

				local d =
					math.abs(center.X - targetCenter.X)

				if d < distance then
					distance = d
					nearest = object
				end
			end
		end
	end

	return nearest
end

local function NeedleOverTarget(
	needle: GuiObject,
	target: GuiObject
)
	local needleCenter =
		needle.AbsolutePosition.X
		+ needle.AbsoluteSize.X / 2

	local targetLeft =
		target.AbsolutePosition.X

	local targetRight =
		targetLeft + target.AbsoluteSize.X

	return needleCenter >= targetLeft
		and needleCenter <= targetRight
end

--========================================================
-- IMPORTANT
--========================================================
-- هذه الدالة هي النقطة الوحيدة التي تحتاج ربطها بمنطق
-- الـMinigame الحقيقي في لعبتك.
--
-- السبب:
-- الصورة تقول "Click anywhere"، أي أن اللعبة لا تستخدم
-- زر GUI عادي يمكن استدعاؤه بـ :Activate().
--
-- إذا كان نظام لعبتك يحتوي أصلًا على دالة لمعالجة نقرة
-- الـMinigame، استدعها هنا.
--========================================================

local function PerformCatchClick()
	-- مثال:
	--
	-- FishingSystem:Click()
	--
	-- أو:
	-- CatchEvent:Fire()
	--
	-- أو استدعاء دالة الـMinigame الموجودة عندك.
	--
	-- لا يمكن للـLocalScript القياسي إنشاء MouseClick
	-- حقيقي على Frame عشوائي.

	return false
end

--========================================================
-- AUTO CATCH
--========================================================

local function AutoCatch()
	local deadline =
		os.clock() + Settings.CatchTimeout

	while State.Running
		and Settings.AutoCatch
		and os.clock() < deadline
	do

		local target = FindGreen()

		if target then
			local needle = FindNeedle(target)

			if needle
				and NeedleOverTarget(needle, target)
			then

				local clicked =
					PerformCatchClick()

				if clicked then
					-- لا نستخدم انتظار ثابت.
					-- الهدف يصغر، لذلك نعيد اكتشافه.
					task.wait()
				end
			end
		end

		RunService.RenderStepped:Wait()
	end
end

--========================================================
-- RARITY
--========================================================

local function DetectRarity(): string
	task.wait(0.25)

	local names = {
		"Brown",
		"Green",
		"Blue",
		"Purple",
		"Gold",
		"Red",
	}

	for _, object in ipairs(PlayerGui:GetDescendants()) do
		if object:IsA("TextLabel")
			or object:IsA("TextButton")
		then

			if object.Visible then
				local text =
					string.lower(object.Text)

				for _, rarity in ipairs(names) do
					if string.find(
						text,
						string.lower(rarity)
					) then
						return rarity
					end
				end
			end
		end
	end

	return "Unknown"
end

--========================================================
-- SELL
--========================================================

local function SellFish()
	for _, object in ipairs(PlayerGui:GetDescendants()) do
		if object:IsA("GuiButton")
			and object.Visible
		then

			local name =
				string.lower(object.Name)

			local text =
				string.lower(object.Text)

			if string.find(name, "sell")
				or string.find(name, "discard")
				or string.find(text, "sell")
				or string.find(text, "discard")
			then

				pcall(function()
					object:Activate()
				end)

				return true
			end
		end
	end

	return false
end

--========================================================
-- ONE FULL CYCLE
--========================================================

local function FarmCycle()
	if State.Busy then
		return
	end

	State.Busy = true

	-- 1
	State.Phase = "تجهيز السنارة"
	Status.Text = "● تجهيز السنارة"

	if not EquipRod() then
		State.Busy = false
		task.wait(1)
		return
	end

	-- 2
	if Settings.AutoBait then
		State.Phase = "تركيب الطعم"
		Status.Text = "● تركيب الطعم"

		AttachBait()
	end

	-- 3
	if Settings.AutoCast then
		State.Phase = "الرمي"
		Status.Text = "● الرمي لأبعد نقطة"

		CastRod()
	end

	task.wait(0.2)

	-- 4
	if Settings.AutoCatch then
		State.Phase = "الصيد"
		Status.Text = "● تتبع الأخضر"

		AutoCatch()
	end

	-- 5
	State.Phase = "قراءة السمكة"

	local rarity =
		DetectRarity()

	State.LastRarity = rarity
	State.FishCount += 1

	Stats.Text =
		"السمك: "
		.. State.FishCount
		.. "   |   آخر سمكة: "
		.. rarity

	-- 6
	if Settings.AutoSell
		and Settings.Sell[rarity] == true
	then

		State.Phase = "بيع"
		Status.Text =
			"● بيع " .. rarity

		SellFish()
	end

	task.wait(0.5)

	State.Busy = false
end

--========================================================
-- MAIN LOOP
--========================================================

task.spawn(function()
	while Gui.Parent do

		if State.Running then
			FarmCycle()
		end

		task.wait(0.05)
	end
end)

--========================================================
-- MINIMIZE
--========================================================

local minimized = false
local normalSize = UDim2.fromOffset(430, 560)

Minimize.MouseButton1Click:Connect(function()
	minimized = not minimized

	if minimized then
		Content.Visible = false
		Main.Size = UDim2.fromOffset(430, 55)
		Minimize.Text = "+"
	else
		Content.Visible = true
		Main.Size = normalSize
		Minimize.Text = "—"
	end
end)

--========================================================
-- LANGUAGE
--========================================================

local arabic = true

Language.MouseButton1Click:Connect(function()
	arabic = not arabic

	if arabic then
		Language.Text = "عربي"
		Title.Text = "🎣 مزرعة الصيد"
	else
		Language.Text = "EN"
		Title.Text = "🎣 AUTO FISH"
	end
end)

--========================================================
-- CLOSE
--========================================================

Close.MouseButton1Click:Connect(function()
	State.Running = false
	Gui:Destroy()
end)

print("[BlockSpin] Auto Farm loaded.")
