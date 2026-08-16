-- ==========================================
-- PRO COMBAT MASTER KILL-FARM v20261
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("ProCheatGUI") then
	PlayerGui.ProCheatGUI:Destroy()
end

local Settings = {
	ESP_Enabled = true,
	KillFarm_Enabled = false,
	BypassAnti = true,
	SafeZoneCheck = true,
	AttackDelay = 0.3,
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProCheatGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.fromOffset(260, 260)
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
Title.Text = "من صنع almbjl_ (Killer)"
Title.Parent = MainFrame

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -10, 1, -45)
ScrollingFrame.Position = UDim2.new(0, 5, 0, 40)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 300)
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 6)
UIList.Parent = ScrollingFrame

local function CreateToggle(name, key)
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(1, -10, 0, 35)
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

CreateToggle("ESP + اسم السلاح بالشنطة", "ESP_Enabled")
CreateToggle("فارم قتل جماعي تلقائي", "KillFarm_Enabled")
CreateToggle("تخطي نظام الحماية (Anti-Cheat)", "BypassAnti")
CreateToggle("تجنب الـ Safe Zone", "SafeZoneCheck")

-- تجاوز نظام الحماية (Anti-Cheat Bypass) الأساسي
local function ApplyAntiBypass()
	if not Settings.BypassAnti then return end
	pcall(function()
		for _, v in ipairs(getconnections(Script.Error or gameScriptError)) do
			v:Disable()
		end
	end)
	pcall(function()
		local mt = getrawmetatable(game)
		setreadonly(mt, false)
		local old = mt.__namecall
		mt.__namecall = newcclosure(function(self, ...)
			local method = getnamecallmethod()
			if method == "Kick" or method == "Ban" then
				return nil
			end
			return old(self, ...)
		end)
	end)
end
task.spawn(ApplyAntiBypass)

-- ESP يوضح اسم اللاعب + الأسلحة اللي معه بالشنطة
local function AddESP(char, player)
	if char and char:FindFirstChild("Head") and not char.Head:FindFirstChild("KillESP") then
		local bg = Instance.new("BillboardGui")
		bg.Name = "KillESP"
		bg.Size = UDim2.new(7, 0, 8, 0)
		bg.StudsOffset = Vector3.new(0, 2, 0)
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
		infoText.Name = "WeaponInfo"
		infoText.Size = UDim2.new(1, 0, 0, 60)
		infoText.Position = UDim2.new(0, 0, 1, 0)
		infoText.BackgroundTransparency = 1
		infoText.TextColor3 = Color3.fromRGB(255, 255, 0)
		infoText.TextStrokeTransparency = 0
		infoText.Font = Enum.Font.GothamBold
		infoText.TextSize = 12
		infoText.Text = ""
		infoText.Parent = bg

		task.spawn(function()
			while char and char.Parent do
				pcall(function()
					local weapons = {}
					if player:FindFirstChild("Backpack") then
						for _, item in ipairs(player.Backpack:GetChildren()) do
							table.insert(weapons, item.Name)
						end
					end
					if char:FindFirstChildOfClass("Tool") then
						table.insert(weapons, char:FindFirstChildOfClass("Tool").Name)
					end
					infoText.Text = player.Name .. "\nالأسلحة: " .. (#weapons > 0 and table.concat(weapons, ", ") :sub(1, 45) or "لايوجد سلاح")
				end)
				task.wait(0.8)
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
		if obj.Name:lower():find("safe") or obj.Name:lower():find("zone") or obj.Name:lower():find("spawn") then
			if obj:IsA("BasePart") then
				if (targetPart.Position - obj.Position).Magnitude < (obj.Size.Magnitude / 2) then
					return true
				end
			end
		end
	end
	return false
end

-- نظام القتل التلقائي الجماعي (Kill Farm)
task.spawn(function()
	while true do
		if Settings.KillFarm_Enabled then
			pcall(function()
				local myChar = LocalPlayer.Character
				if myChar and myChar:FindFirstChild("HumanoidRootPart") then
					local hrp = myChar.HumanoidRootPart
					local originalPos = hrp.CFrame
					
					for _, player in ipairs(Players:GetPlayers()) do
						if player ~= LocalPlayer and player.Character then
							local enemyChar = player.Character
							local enemyHrp = enemyChar:FindFirstChild("HumanoidRootPart")
							local enemyHumanoid = enemyChar:FindFirstChildOfClass("Humanoid")
							
							if enemyHrp and enemyHumanoid and enemyHumanoid.Health > 0 then
								if not IsInSafeZone(enemyHrp) then
									-- الانتقال الفوري للعدو وتصفيته ثم العودة لتجنب الكشف
									hrp.CFrame = enemyHrp.CFrame + Vector3.new(0, 3, 0)
									
									-- محاولة تفعيل السلاح أو ضرب العدو تلقائياً
									local tool = myChar:FindFirstChildOfClass("Tool")
									if tool then
										tool:Activate()
									end
									
									task.wait(Settings.AttackDelay)
								end
							end
						end
					end
					hrp.CFrame = originalPos
				end
			end)
		end
		task.wait(1)
	end
end)
