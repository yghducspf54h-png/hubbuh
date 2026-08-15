-- ==============================================================================
-- Abu Annaz Hub V10 PREDICTIVE VIP | حقوق أبو عنّاز - PREDICTIVE VELOCITY NEEDLE SOLVER
-- Game: BlockSpin (Roblox)
-- Features:
--  1. Pure Midnight Black Theme (GUI أسود فاخر بالكامل)
--  2. Predictive Needle Velocity & Lead-Offset Engine (حساب سرعة واتجاه الإبرة وتنبؤ الضرب في المركز بدون أي تفويت)
--  3. Slot 2 Fishing Rod Priority (مسك السنارة من الخانة 2 بدون تغيير)
--  4. Ultra-Fast Re-Bait & Trash Discard Systems (التعبئة السريعة وتدمير القمامة كما هي)
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    repeat task.wait() until Players.LocalPlayer
    LocalPlayer = Players.LocalPlayer
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
if not PlayerGui then return end

-- Clean previous instances
if PlayerGui:FindFirstChild("AbuAnnazHubV10") then
    PlayerGui.AbuAnnazHubV10:Destroy()
end

-- Configuration State
local State = {
    AutoSolveGreen = true,
    AutoFish = true,
    AutoRebait = true,
    FilterTrash = true,
    MinigameActive = false,
    HitCounter = 0,
}

local TrashItems = {
    ["Boot"] = true, ["Old Boot"] = true, ["Seaweed"] = true,
    ["Tin Can"] = true, ["Driftwood"] = true, ["Trash"] = true
}

-- Exact Target Color Filtering for Dark Green #13A913
local function isExactDarkGreen(col)
    if not col then return false end
    local r, g, b = math.floor(col.R * 255), math.floor(col.G * 255), math.floor(col.B * 255)
    return (r >= 2 and r <= 55) and (g >= 120 and g <= 220) and (b >= 2 and b <= 55)
end

-- Trackers for Predictive Velocity Calculation
local lastNeedleX = nil
local lastNeedleTick = nil
local needleVelocityX = 0 -- px per second
local lastHitTick = 0
local lastCastTick = 0

-- ------------------------------------------------------------------------------
-- 1. PREDICTIVE VELOCITY & LEAD-OFFSET SOLVER (الخيار 1: التنبؤ بالسرعة والاتجاه)
-- ------------------------------------------------------------------------------
local function scanGuiForMinigame()
    if not State.AutoSolveGreen and not State.AutoFish then 
        State.MinigameActive = false
        lastNeedleX = nil
        return 
    end

    local minigameFound = false

    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AbuAnnazHubV10" then
            local needleObj = nil
            local greenObj = nil
            local hasMinigameText = false

            -- Scan UI Elements for Needle & Dark Green Box #13A913
            for _, desc in ipairs(gui:GetDescendants()) do
                if desc:IsA("GuiObject") and desc.Visible and desc.AbsoluteSize.X > 0 and desc.AbsoluteSize.Y > 0 then
                    local bgCol = desc.BackgroundColor3
                    local imgCol = desc:IsA("ImageLabel") or desc:IsA("ImageButton") and desc.ImageColor3 or bgCol
                    local size = desc.AbsoluteSize
                    local name = desc.Name:lower()

                    -- Confirm Minigame Text Indicator
                    if desc:IsA("TextLabel") and desc.Text ~= "" then
                        local t = desc.Text:lower()
                        if t:find("needle") or t:find("green target") or t:find("click anywhere") or t:find("tries") then
                            hasMinigameText = true
                        end
                    end

                    -- Detect Moving Needle Line
                    if (size.X <= 28 and size.Y >= 6) or name:find("needle") or name:find("line") or name:find("pointer") or name:find("indicator") then
                        local isWhiteBg = (bgCol.R > 0.6 and bgCol.G > 0.6 and bgCol.B > 0.6)
                        local isWhiteImg = (imgCol.R > 0.6 and imgCol.G > 0.6 and imgCol.B > 0.6)
                        if isWhiteBg or isWhiteImg or name:find("needle") or name:find("pointer") or name:find("line") then
                            needleObj = desc
                        end
                    end

                    -- Detect #13A913 Dark Green Target
                    if isExactDarkGreen(bgCol) or isExactDarkGreen(imgCol) or name:find("green") or name:find("target") or name:find("zone") then
                        greenObj = desc
                    end
                end
            end

            -- PREDICTIVE MATH ENGINE
            if (needleObj and greenObj) or (hasMinigameText and needleObj and greenObj) then
                minigameFound = true
                State.MinigameActive = true

                local currentNeedleX = needleObj.AbsolutePosition.X + (needleObj.AbsoluteSize.X / 2)
                local currentTick = tick()

                -- Calculate Velocity & Direction (dx / dt)
                if lastNeedleX and lastNeedleTick and (currentTick - lastNeedleTick) > 0 then
                    local dt = currentTick - lastNeedleTick
                    local dx = currentNeedleX - lastNeedleX
                    needleVelocityX = dx / dt
                end

                lastNeedleX = currentNeedleX
                lastNeedleTick = currentTick

                -- Predict Position ahead by latency offset (approx 0.02s lead)
                local predictedLeadTime = 0.02
                local predictedNeedleX = currentNeedleX + (needleVelocityX * predictedLeadTime)

                local greenMinX = greenObj.AbsolutePosition.X
                local greenMaxX = greenMinX + greenObj.AbsoluteSize.X

                -- Trigger Click when Predicted Position is inside #13A913 Bounds
                if (predictedNeedleX >= (greenMinX - 1) and predictedNeedleX <= (greenMaxX + 1)) 
                   or (currentNeedleX >= greenMinX and currentNeedleX <= greenMaxX) then
                    
                    if tick() - lastHitTick >= 0.008 then
                        lastHitTick = tick()
                        State.HitCounter = State.HitCounter + 1

                        local cam = Workspace.CurrentCamera
                        local screenCenterX = cam and (cam.ViewportSize.X / 2) or 500
                        local screenCenterY = cam and (cam.ViewportSize.Y / 2) or 300

                        -- 1. Click Screen Center (Primary Game Interaction)
                        VirtualInputManager:SendMouseButtonEvent(screenCenterX, screenCenterY, 0, true, game, 1)
                        task.wait(0.001)
                        VirtualInputManager:SendMouseButtonEvent(screenCenterX, screenCenterY, 0, false, game, 1)

                        -- 2. Click Directly at Needle Position
                        local clickX = math.floor(currentNeedleX)
                        local clickY = math.floor(needleObj.AbsolutePosition.Y + (needleObj.AbsoluteSize.Y / 2))
                        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
                        task.wait(0.001)
                        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)

                        -- 3. Spacebar Event Backup
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                        task.wait(0.001)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                    end
                end
            end
        end
    end

    if not minigameFound then
        State.MinigameActive = false
        lastNeedleX = nil
    end
end

RunService.RenderStepped:Connect(scanGuiForMinigame)

-- ------------------------------------------------------------------------------
-- 2. SLOT 2 ROD EQUIPPING & FAST RE-BAIT ENGINE (كما هي دون تغيير)
-- ------------------------------------------------------------------------------
local function equipSlot2Rod()
    local char = LocalPlayer.Character
    if not char then return nil end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool then return currentTool end

    -- Press Key '2' for Slot 2
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
    task.wait(0.01)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Two, false, game)

    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                if humanoid then pcall(function() humanoid:EquipTool(item) end) end
                item.Parent = char
                return item
            end
        end
    end
    return char:FindFirstChildOfClass("Tool")
end

task.spawn(function()
    while task.wait(0.18) do
        if State.AutoFish then
            local rod = equipSlot2Rod()

            -- Ultra Fast Re-Bait Loop
            if State.AutoRebait and rod then
                for _, rName in ipairs({"EquipBait", "BaitRemote", "Rebait", "Bait", "AddBait"}) do
                    local remote = ReplicatedStorage:FindFirstChild(rName, true) or Workspace:FindFirstChild(rName, true)
                    if remote and remote:IsA("RemoteEvent") then
                        pcall(function() remote:FireServer() end)
                    end
                end
            end

            -- Cast Line Far into Water
            if rod and not State.MinigameActive and (tick() - lastCastTick >= 1.4) then
                lastCastTick = tick()

                pcall(function() rod:Activate() end)

                local cam = Workspace.CurrentCamera
                local cx = cam and (cam.ViewportSize.X / 2) or 500
                local cy = cam and (cam.ViewportSize.Y * 0.35) or 250

                VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
                task.wait(0.35)
                VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
            end
        end

        -- Filter Trash Discard Loop
        if State.FilterTrash then
            local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
            if backpack then
                for _, item in ipairs(backpack:GetChildren()) do
                    if TrashItems[item.Name] then
                        pcall(function() item:Destroy() end)
                    end
                end
            end
        end
    end
end)

-- ------------------------------------------------------------------------------
-- 3. GUI DESIGN - PURE MIDNIGHT BLACK THEME (حقوق أبو الهول عنّاز V10 PREDICTIVE)
-- ------------------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "AbuAnnazHubV10"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 540, 0, 400)
main.Position = UDim2.new(0.5, -270, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(8, 8, 10) -- Pure Midnight Black Theme
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(180, 20, 30) -- Dark Red Accent Border
stroke.Thickness = 1.8

-- Header Bar
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 44)
header.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0.8, 0, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.Text = "👑 حقوق أبو عنّاز | PREDICTIVE FISHING V10"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.BackgroundTransparency = 1

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -34, 0.5, -13)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 40)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Sidebar & Content (Pure Black Theme)
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 150, 1, -54)
sidebar.Position = UDim2.new(0, 8, 0, 48)
sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8)

local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.Padding = UDim.new(0, 6)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sideLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -172, 1, -54)
content.Position = UDim2.new(0, 164, 0, 48)
content.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
content.BorderSizePixel = 0
Instance.new("UICorner", content).CornerRadius = UDim.new(0, 8)

local pages = {}

local function createTab(name)
    local tabBtn = Instance.new("TextButton", sidebar)
    tabBtn.Size = UDim2.new(0.92, 0, 0, 36)
    tabBtn.Text = name
    tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 12
    tabBtn.BorderSizePixel = 0
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)

    local page = Instance.new("ScrollingFrame", content)
    page.Size = UDim2.new(1, -10, 1, -10)
    page.Position = UDim2.new(0, 5, 0, 5)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 3
    
    local pageLayout = Instance.new("UIListLayout", page)
    pageLayout.Padding = UDim.new(0, 8)
    pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    pageLayout.Parent = page

    pages[name] = { Btn = tabBtn, Page = page }

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(pages) do
            t.Page.Visible = false
            t.Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
            t.Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        page.Visible = true
        tabBtn.BackgroundColor3 = Color3.fromRGB(180, 20, 30)
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    return page
end

local function addToggle(parent, label, key)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 36)
    btn.BackgroundColor3 = State[key] and Color3.fromRGB(180, 20, 30) or Color3.fromRGB(22, 22, 26)
    btn.Text = label .. (State[key] and " [ON]" or " [OFF]")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        State[key] = not State[key]
        btn.Text = label .. (State[key] and " [ON]" or " [OFF]")
        btn.BackgroundColor3 = State[key] and Color3.fromRGB(180, 20, 30) or Color3.fromRGB(22, 22, 26)
    end)
    return btn
end

-- Create Pages
local fishPage = createTab("🎣 صيد الأسماك V10 PREDICTIVE")

pages["🎣 صيد الأسماك V10 PREDICTIVE"].Page.Visible = true
pages["🎣 صيد الأسماك V10 PREDICTIVE"].Btn.BackgroundColor3 = Color3.fromRGB(180, 20, 30)

addToggle(fishPage, "🎯 حل التنبؤ بالسرعة والاتجاه على #13A913", "AutoSolveGreen")
addToggle(fishPage, "🎣 مسك السنارة (خانة 2) والرمي البعيد", "AutoFish")
addToggle(fishPage, "🪱 التعبئة السريعة للطعم", "AutoRebait")
addToggle(fishPage, "🐟 تصفية وتدمير القمامة", "FilterTrash")

print("ABU ANNAZ HUB PREDICTIVE V10 LOADED SUCCESSFULLY!")
