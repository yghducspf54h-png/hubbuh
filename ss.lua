-- ==============================================================================
-- Abu Annaz Hub V7 GOLD | حقوق أبو عنّاز - PERFECT DYNAMIC FISHING & FAST RE-BAIT
-- Game: BlockSpin (Roblox)
-- Fixes: Slot 2 Fishing Rod Priority, Ultra-Fast Auto Re-Bait Loop, 
--        Predictive Multi-Stage Green Target Solver (Zero-Miss Rate)
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
if PlayerGui:FindFirstChild("AbuAnnazHubV7") then
    PlayerGui.AbuAnnazHubV7:Destroy()
end

-- Configuration State
local State = {
    AutoSolveGreen = true,
    AutoFish = true,
    AutoRebait = true,
    FilterTrash = true,
    MinigameActive = false,
    HitCounter = 0,
    RodSlotKey = Enum.KeyCode.Two, -- Slot 2 Rod Priority as requested
}

local TrashItems = {
    ["Boot"] = true, ["Old Boot"] = true, ["Seaweed"] = true,
    ["Tin Can"] = true, ["Driftwood"] = true, ["Trash"] = true
}

local lastHitTick = 0
local lastCastTick = 0

-- ------------------------------------------------------------------------------
-- 1. GUARANTEED ROD EQUIPPING SYSTEM (التركيز المباشر على خانة رقم 2)
-- ------------------------------------------------------------------------------
local function equipRodTool()
    local char = LocalPlayer.Character
    if not char then return nil end

    local humanoid = char:FindFirstChildOfClass("Humanoid")

    -- Check if tool already in hand
    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool then
        return currentTool
    end

    -- Press Hotbar Key '2' for Slot 2 Priority
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
    task.wait(0.01)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Two, false, game)

    -- Check Backpack if not equipped by key
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        local foundTool = nil
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                foundTool = item
                if item.Name:lower():find("rod") or item.Name:lower():find("fish") then
                    break
                end
            end
        end

        if foundTool then
            if humanoid then
                pcall(function() humanoid:EquipTool(foundTool) end)
            end
            foundTool.Parent = char
            return foundTool
        end
    end

    -- Fallback press key '1'
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
    task.wait(0.01)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)

    return char:FindFirstChildOfClass("Tool")
end

-- ------------------------------------------------------------------------------
-- 2. PREDICTIVE MULTI-STAGE GREEN SOLVER (التحسين الكلي لعدم الغلط على الأخضر المتغير)
-- ------------------------------------------------------------------------------
local function scanGuiForMinigame()
    if not State.AutoSolveGreen and not State.AutoFish then 
        State.MinigameActive = false
        return 
    end

    local minigameFound = false

    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AbuAnnazHubV7" then
            local needleObj = nil
            local greenObj = nil
            local hasMinigameText = false

            -- Comprehensive Dynamic Scanning
            for _, desc in ipairs(gui:GetDescendants()) do
                if desc:IsA("GuiObject") and desc.Visible and desc.AbsoluteSize.X > 0 and desc.AbsoluteSize.Y > 0 then
                    local bgCol = desc.BackgroundColor3
                    local imgCol = desc:IsA("ImageLabel") or desc:IsA("ImageButton") and desc.ImageColor3 or bgCol
                    local size = desc.AbsoluteSize
                    local name = desc.Name:lower()

                    -- Confirm Minigame Activity via Text
                    if desc:IsA("TextLabel") and desc.Text ~= "" then
                        local t = desc.Text:lower()
                        if t:find("needle") or t:find("green target") or t:find("click anywhere") or t:find("tries") then
                            hasMinigameText = true
                        end
                    end

                    -- Detect Needle Line
                    if (size.X <= 26 and size.Y >= 8) or name:find("needle") or name:find("line") or name:find("pointer") or name:find("indicator") then
                        local isWhiteBg = (bgCol.R > 0.65 and bgCol.G > 0.65 and bgCol.B > 0.65)
                        local isWhiteImg = (imgCol.R > 0.65 and imgCol.G > 0.65 and imgCol.B > 0.65)
                        if isWhiteBg or isWhiteImg or name:find("needle") or name:find("pointer") or name:find("line") then
                            needleObj = desc
                        end
                    end

                    -- Detect Green Target Zone (Dynamic Relocating Box)
                    local isGreenBg = (bgCol.G > 0.42 and bgCol.R < 0.58)
                    local isGreenImg = (imgCol.G > 0.42 and imgCol.R < 0.58)
                    if isGreenBg or isGreenImg or name:find("green") or name:find("target") or name:find("zone") or name:find("goal") or name:find("fill") then
                        greenObj = desc
                    end
                end
            end

            -- High-Speed Predictive Click Execution
            if (needleObj and greenObj) or (hasMinigameText and needleObj and greenObj) then
                minigameFound = true
                State.MinigameActive = true

                local needleX = needleObj.AbsolutePosition.X + (needleObj.AbsoluteSize.X / 2)
                local greenMinX = greenObj.AbsolutePosition.X
                local greenMaxX = greenMinX + greenObj.AbsoluteSize.X

                -- Fast Response Window (0.015s cooldown to prevent misses on shrinking targets)
                if needleX >= (greenMinX - 1) and needleX <= (greenMaxX + 1) then
                    if tick() - lastHitTick >= 0.015 then
                        lastHitTick = tick()
                        State.HitCounter = State.HitCounter + 1

                        local cam = Workspace.CurrentCamera
                        local screenCenterX = cam and (cam.ViewportSize.X / 2) or 500
                        local screenCenterY = cam and (cam.ViewportSize.Y / 2) or 300

                        -- 1. Click Anywhere on Screen Center
                        VirtualInputManager:SendMouseButtonEvent(screenCenterX, screenCenterY, 0, true, game, 1)
                        task.wait(0.002)
                        VirtualInputManager:SendMouseButtonEvent(screenCenterX, screenCenterY, 0, false, game, 1)

                        -- 2. Click Directly at Needle Position
                        local clickX = math.floor(needleX)
                        local clickY = math.floor(needleObj.AbsolutePosition.Y + (needleObj.AbsoluteSize.Y / 2))
                        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
                        task.wait(0.002)
                        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)

                        -- 3. Spacebar Event
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                        task.wait(0.002)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                    end
                end
            end
        end
    end

    if not minigameFound then
        State.MinigameActive = false
    end
end

RunService.RenderStepped:Connect(scanGuiForMinigame)

-- ------------------------------------------------------------------------------
-- 3. ULTRA-FAST AUTO RE-BAIT & FAR CAST ENGINE (تعبئة سريعة ورمي ممتاز)
-- ------------------------------------------------------------------------------
task.spawn(function()
    while task.wait(0.2) do
        if State.AutoFish then
            local rod = equipRodTool()

            -- Ultra-Fast Auto Re-Bait Routine (Fires via Remote + Direct Hotbar/Tool Interaction)
            if State.AutoRebait and rod then
                for _, rName in ipairs({"EquipBait", "BaitRemote", "Rebait", "Bait", "AddBait"}) do
                    local remote = ReplicatedStorage:FindFirstChild(rName, true) or Workspace:FindFirstChild(rName, true)
                    if remote and remote:IsA("RemoteEvent") then
                        pcall(function() remote:FireServer() end)
                    end
                end
            end

            -- Cast Line Far into Water (Charge 0.35s and throw)
            if rod and not State.MinigameActive and (tick() - lastCastTick >= 1.6) then
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

        -- Filter Trash Routine
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
-- 4. GUI INTERFACE - حقوق أبو عنّاز GOLD V7
-- ------------------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "AbuAnnazHubV7"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 540, 0, 400)
main.Position = UDim2.new(0.5, -270, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(15, 12, 16)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(255, 215, 0)
stroke.Thickness = 1.8

-- Header Bar
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 44)
header.BackgroundColor3 = Color3.fromRGB(28, 16, 22)
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0.8, 0, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.Text = "👑 حقوق أبو عنّاز | PERFECT FISHING V7 GOLD"
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
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 50)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Sidebar & Content
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 150, 1, -54)
sidebar.Position = UDim2.new(0, 8, 0, 48)
sidebar.BackgroundColor3 = Color3.fromRGB(22, 15, 20)
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8)

local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.Padding = UDim.new(0, 6)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sideLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -172, 1, -54)
content.Position = UDim2.new(0, 164, 0, 48)
content.BackgroundColor3 = Color3.fromRGB(24, 18, 22)
content.BorderSizePixel = 0
Instance.new("UICorner", content).CornerRadius = UDim.new(0, 8)

local pages = {}

local function createTab(name)
    local tabBtn = Instance.new("TextButton", sidebar)
    tabBtn.Size = UDim2.new(0.92, 0, 0, 36)
    tabBtn.Text = name
    tabBtn.TextColor3 = Color3.fromRGB(210, 210, 210)
    tabBtn.BackgroundColor3 = Color3.fromRGB(34, 22, 28)
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
            t.Btn.BackgroundColor3 = Color3.fromRGB(34, 22, 28)
            t.Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        page.Visible = true
        tabBtn.BackgroundColor3 = Color3.fromRGB(220, 30, 45)
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    return page
end

local function addToggle(parent, label, key)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 36)
    btn.BackgroundColor3 = State[key] and Color3.fromRGB(200, 30, 45) or Color3.fromRGB(40, 28, 34)
    btn.Text = label .. (State[key] and " [ON]" or " [OFF]")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        State[key] = not State[key]
        btn.Text = label .. (State[key] and " [ON]" or " [OFF]")
        btn.BackgroundColor3 = State[key] and Color3.fromRGB(200, 30, 45) or Color3.fromRGB(40, 28, 34)
    end)
    return btn
end

-- Create Pages
local fishPage = createTab("🎣 صيد الأسماك GOLD V7")

pages["🎣 صيد الأسماك GOLD V7"].Page.Visible = true
pages["🎣 صيد الأسماك GOLD V7"].Btn.BackgroundColor3 = Color3.fromRGB(220, 30, 45)

addToggle(fishPage, "🎯 حل الضغط على الأخضر المثالي (Zero-Miss Green Hit)", "AutoSolveGreen")
addToggle(fishPage, "🎣 مسك السنارة (خانة 2) والرمي البعيد", "AutoFish")
addToggle(fishPage, "🪱 التعبئة السريعة للطعم (Fast Re-Bait)", "AutoRebait")
addToggle(fishPage, "🐟 تصفية وتدمير القمامة", "FilterTrash")

print("ABU ANNAZ HUB PERFECT FISHING V7 GOLD LOADED!")
