--!strict
--========================================================
-- BLOCKSPIN FISHING AUTO FARM
-- Luau / Roblox Studio
--========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

--========================================================
-- SETTINGS
--========================================================

local Settings = {
	Enabled = false,

	DelayBetweenCasts = 2,

	AutoBait = true,
	AutoCast = true,
	AutoCatch = true,
	AutoSell = true,

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
	Phase = "Idle",
	Running = false,
	Busy = false,

	Catches = 0,
	LastFish = "None",

	RodEquipped = false,
	BaitAttached = false,
	RodInWater = false,

	MinigameActive = false,
	TargetSolved = false,
	FishCaught = false,
}

--========================================================
-- FISHING API
--
-- اربط هذه الدوال بنظام Fishing الحقيقي في لعبتك.
--========================================================

local FishingAPI = {}

function FishingAPI:HasRod(): boolean
	-- TODO:
	-- افحص وجود السنارة عند اللاعب.
	return true
end

function FishingAPI:EquipRod(): boolean
	-- TODO:
	-- تجهيز السنارة.
	State.RodEquipped = true
	return true
end

function FishingAPI:HasBait(): boolean
	-- TODO:
	-- فحص كمية الطعم.
	return true
end

function FishingAPI:RefillBait(): boolean
	-- TODO:
	-- شراء/تعبئة الطعم مرة واحدة.
	return true
end

function FishingAPI:AttachBait(): boolean
	-- TODO:
	-- تركيب الطعم على السنارة.
	State.BaitAttached = true
	return true
end

function FishingAPI:IsWaterPositionValid(): boolean
	-- TODO:
	-- فحص أن اللاعب في مكان يسمح بالصيد.
	return true
end

function FishingAPI:Cast(): boolean
	-- TODO:
	-- رمي السنارة.
	State.RodInWater = true
	return true
end

function FishingAPI:IsMinigameActive(): boolean
	-- TODO:
	-- هل اختبار الصيد ظاهر حاليًا؟
	return State.MinigameActive
end

function FishingAPI:GetTarget(): GuiObject?
	-- TODO:
	-- أرجع الـGreen Target الحالي.
	return nil
end

function FishingAPI:GetNeedle(): GuiObject?
	-- TODO:
	-- أرجع مؤشر الـNeedle الحالي.
	return nil
end

function FishingAPI:CatchClick(): boolean
	-- TODO:
	-- نفّذ نفس منطق نقرة اللاعب داخل الـMinigame.
	return true
end

function FishingAPI:IsCatchFinished(): boolean
	-- TODO:
	-- هل انتهى الاختبار؟
	return State.FishCaught
end

function FishingAPI:GetFishRarity(): string
	-- TODO:
	-- أرجع:
	-- Brown / Green / Blue / Purple / Gold / Red
	return "Unknown"
end

function FishingAPI:SellFish(): boolean
	-- TODO:
	-- بيع السمكة الحالية.
	return true
end

function FishingAPI:ResetAfterCatch()
	State.RodInWater = false
	State.BaitAttached = false
	State.MinigameActive = false
	State.TargetSolved = false
	State.FishCaught = false
end

--========================================================
-- GUI
--========================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "FishingAutoFarm"
Gui.ResetOnSpawn = false
Gui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(430, 570)
Main.Position = UDim2.new(.5, -215, .5, -285)
Main.BackgroundColor3 = Color3.fromRGB(25, 27, 32)
Main.BorderSizePixel = 0
Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 55)
Header.BackgroundColor3 = Color3.fromRGB(38, 41, 48)
Header.BorderSizePixel = 0
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.fromOffset(15, 0)
Title.BackgroundTransparency = 1
Title.Text = "🎣 مزرعة الصيد"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 19
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.fromOffset(32, 32)
Minimize.Position = UDim2.new(1, -72, 0, 11)
Minimize.Text = "—"
Minimize.TextSize = 20
Minimize.TextColor3 = Color3.new(1, 1, 1)
Minimize.BackgroundColor3 = Color3.fromRGB(60, 64, 73)
Minimize.Parent = Header

Instance.new("UICorner", Minimize).CornerRadius = UDim.new(0, 8)

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(32, 32)
Close.Position = UDim2.new(1, -36, 0, 11)
Close.Text = "×"
Close.TextSize = 20
Close.TextColor3 = Color3.new(1, 1, 1)
Close.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
Close.Parent = Header

Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 8)

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -70)
Content.Position = UDim2.fromOffset(10, 65)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.ScrollBarThickness = 4
Content.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 7)
Layout.Parent = Content

local function Label(text: string, height: number)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, height)
	label.BackgroundColor3 = Color3.fromRGB(42, 45, 52)
	label.Text = text
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextSize = 13
	label.Font = Enum.Font.Gotham
	label.Parent = Content

	Instance.new("UICorner", label).CornerRadius = UDim.new(0, 8)

	return label
end

local Status = Label("● متوقف", 40)
local Stats = Label("الصيد: 0 | آخر سمكة: لا يوجد", 40)

local function Toggle(text: string, default: boolean, callback)
	local value = default

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, 38)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextSize = 13
	button.Font = Enum.Font.GothamBold
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.Parent = Content

	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

	local function update()
		button.Text = "   " .. text .. " [" .. (value and "ON" or "OFF") .. "]"
		button.BackgroundColor3 =
			value
			and Color3.fromRGB(30, 120, 55)
			or Color3.fromRGB(50, 53, 60)
	end

	update()

	button.MouseButton1Click:Connect(function()
		value = not value
		update()
		callback(value)
	end)
end

Toggle("تشغيل Auto Farm", false, function(v)
	Settings.Enabled = v
	State.Running = v
end)

Toggle("Auto Bait", true, function(v)
	Settings.AutoBait = v
end)

Toggle("Auto Catch", true, function(v)
	Settings.AutoCatch = v
end)

Toggle("Auto Sell", true, function(v)
	Settings.AutoSell = v
end)

--========================================================
-- SELL SETTINGS
--========================================================

Label("💰 إعدادات البيع", 30)

for _, rarity in ipairs({
	"Brown",
	"Green",
	"Blue",
	"Purple",
	"Gold",
	"Red",
}) do

	Toggle("بيع " .. rarity, true, function(v)
		Settings.Sell[rarity] = v
	end)
end

--========================================================
-- STATUS
--========================================================

local function SetPhase(name: string)
	State.Phase = name
	Status.Text = "● " .. name
end

local function UpdateStats()
	Stats.Text =
		"الصيد: "
		.. tostring(State.Catches)
		.. " | آخر سمكة: "
		.. State.LastFish
end

--========================================================
-- TARGET DETECTION
--========================================================

local function IsInside(
	needle: GuiObject,
	target: GuiObject
): boolean

	local needleCenter =
		needle.AbsolutePosition.X
		+ needle.AbsoluteSize.X / 2

	local left =
		target.AbsolutePosition.X

	local right =
		left + target.AbsoluteSize.X

	return needleCenter >= left
		and needleCenter <= right
end

--========================================================
-- MINIGAME
--========================================================

local function SolveMinigame(): boolean
	local timeout = os.clock() + 30

	while State.Running
		and os.clock() < timeout
	do

		if not FishingAPI:IsMinigameActive() then
			RunService.Heartbeat:Wait()
			continue
		end

		local target =
			FishingAPI:GetTarget()

		local needle =
			FishingAPI:GetNeedle()

		if target and needle then

			-- الأخضر يتغير حجمه بعد كل نجاح،
			-- لذلك نعيد البحث عنه باستمرار.

			if IsInside(needle, target) then

				if FishingAPI:CatchClick() then
					State.TargetSolved = true

					task.wait(0.03)

					if FishingAPI:IsCatchFinished() then
						return true
					end
				end
			end
		end

		if FishingAPI:IsCatchFinished() then
			return true
		end

		RunService.RenderStepped:Wait()
	end

	return FishingAPI:IsCatchFinished()
end

--========================================================
-- SINGLE FARM CYCLE
--========================================================

local function FarmCycle()
	if State.Busy then
		return
	end

	State.Busy = true

	--------------------------------------------------------
	-- 1. ROD
	--------------------------------------------------------

	SetPhase("فحص السنارة")

	if not FishingAPI:HasRod() then
		SetPhase("لا توجد سنارة")
		State.Busy = false
		task.wait(1)
		return
	end

	if not FishingAPI:EquipRod() then
		SetPhase("فشل تجهيز السنارة")
		State.Busy = false
		task.wait(1)
		return
	end

	--------------------------------------------------------
	-- 2. BAIT
	--------------------------------------------------------

	if Settings.AutoBait then

		SetPhase("فحص الطعم")

		if not FishingAPI:HasBait() then
			SetPhase("تعبئة الطعم")

			if not FishingAPI:RefillBait() then
				SetPhase("فشل تعبئة الطعم")
				State.Busy = false
				task.wait(1)
				return
			end
		end

		SetPhase("تركيب الطعم")

		if not FishingAPI:AttachBait() then
			SetPhase("فشل تركيب الطعم")
			State.Busy = false
			task.wait(1)
			return
		end
	end

	--------------------------------------------------------
	-- 3. WATER
	--------------------------------------------------------

	SetPhase("فحص البحيرة")

	if not FishingAPI:IsWaterPositionValid() then
		SetPhase("لا يوجد مكان صيد صالح")
		State.Busy = false
		task.wait(1)
		return
	end

	--------------------------------------------------------
	-- 4. CAST
	--------------------------------------------------------

	SetPhase("رمي السنارة")

	if not FishingAPI:Cast() then
		SetPhase("فشل الرمي")
		State.Busy = false
		task.wait(1)
		return
	end

	State.RodInWater = true

	--------------------------------------------------------
	-- 5. WAIT MINIGAME
	--------------------------------------------------------

	SetPhase("انتظار اختبار الصيد")

	local deadline = os.clock() + 30

	while State.Running
		and os.clock() < deadline
	do

		if FishingAPI:IsMinigameActive() then
			break
		end

		RunService.Heartbeat:Wait()
	end

	--------------------------------------------------------
	-- 6. CATCH
	--------------------------------------------------------

	if Settings.AutoCatch then

		SetPhase("حل الاختبار")

		if not SolveMinigame() then
			SetPhase("فشل الصيد")
			FishingAPI:ResetAfterCatch()
			State.Busy = false
			task.wait(1)
			return
		end
	end

	--------------------------------------------------------
	-- 7. FISH
	--------------------------------------------------------

	SetPhase("قراءة السمكة")

	local rarity =
		FishingAPI:GetFishRarity()

	State.LastFish = rarity
	State.Catches += 1

	UpdateStats()

	--------------------------------------------------------
	-- 8. SELL
	--------------------------------------------------------

	if Settings.AutoSell
		and Settings.Sell[rarity] == true
	then

		SetPhase("بيع " .. rarity)

		FishingAPI:SellFish()
	end

	--------------------------------------------------------
	-- 9. RESET
	--------------------------------------------------------

	FishingAPI:ResetAfterCatch()

	--------------------------------------------------------
	-- 10. TWO SECOND DELAY
	--------------------------------------------------------

	SetPhase("انتظار 2 ثانية")

	local endTime =
		os.clock() + Settings.DelayBetweenCasts

	while State.Running
		and os.clock() < endTime
	do
		RunService.Heartbeat:Wait()
	end

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
local normalSize = UDim2.fromOffset(430, 570)

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
-- CLOSE
--========================================================

Close.MouseButton1Click:Connect(function()
	State.Running = false
	Gui:Destroy()
end)

print("[Fishing AutoFarm] Loaded")
