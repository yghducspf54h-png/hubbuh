-- ==============================================================================
-- Abu Annaz Hub V6 PRO | حقوق أبو عنّاز - MASTER ULTIMATE FISHING ENGINE
-- Game: BlockSpin (Roblox)
-- Fixes: Guaranteed Tool Equipping (Key '1' + Humanoid:EquipTool), 
--        Color/Image Color Detection for Needle & Green Zone, 
--        "Click Anywhere" Solver & Charge-and-Release Rod Casting Engine
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
if PlayerGui:FindFirstChild("AbuAnnazHubV6") then
    PlayerGui.AbuAnnazHubV6:Destroy()
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

local lastHitTick = 0
local lastCastTick = 0

-- ------------------------------------------------------------------------------
-- 1. GUARANTEED TOOL EQUIPPING SYSTEM (مسك السنارة بالتأكيد المباشر)
-- ------------------------------------------------------------------------------
local function equipRodTool()
    local char = LocalPlayer.Character
    if not char then return nil end

    local humanoid = char:FindFirstChildOfClass("Humanoid")

    -- Check if tool already equipped in hand
    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool then
        return currentTool
    end

    -- Check Backpack for fishing rod or any tool
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
            -- Method 1: Humanoid EquipTool
            if humanoid then
                pcall(function() humanoid:EquipTool(foundTool) end)
            end
            -- Method 2: Parent to Character
            foundTool.Parent = char

            -- Method 3: Press Hotbar Key '1' via Virtual Input
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
            task.wait(0.02)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)

            return foundTool
        end
    end

    -- Method 4: Press Hotbar Key '1' as fallback
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
    task.wait(0.02)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)

    return char:FindFirstChildOfClass("Tool")
end

-- ------------------------------------------------------------------------------
-- 2. UNIVERSAL GREEN TARGET & NEEDLE SOLVER (كشف ألوان الصور والخلفيات)
-- ------------------------------------------------------------------------------
local function scanGuiForMinigame()
    if not State.AutoSolveGreen and not State.AutoFish then 
        State.MinigameActive = false
        return 
    end

    local minigameFound = false

    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AbuAnnazHubV6" then
            local needleObj = nil
            local greenObj = nil
            local hasMinigameText = false

            -- Scan for minigame UI Elements & ImageLabels
            for _, desc in ipairs(gui:GetDescendants()) do
                if desc:IsA("GuiObject") and desc.Visible and desc.AbsoluteSize.X > 0 and desc.AbsoluteSize.Y > 0 then
                    local bgCol = desc.BackgroundColor3
                    local imgCol = desc:IsA("ImageLabel") or desc:IsA("ImageButton") and desc.ImageColor3 or bgCol
                    local txtCol = desc:IsA("TextLabel") or desc:IsA("TextButton") and desc.TextColor3 or bgCol
                    local size = desc.AbsoluteSize
                    local name = desc.Name:lower()

                    -- Check Text for Minigame Confirmation
                    if desc:IsA("TextLabel") and desc.Text ~= "" then
                        local t = desc.Text:lower()
                        if t:find("needle") or t:find("green target") or t:find("click anywhere") or t:find("tries") then
                            hasMinigameText = true
                        end
                    end

                    -- Detect Needle (Vertical indicator line)
                    if (size.X <= 25 and size.Y >= 10) or name:find("needle") or name:find("line") or name:find("pointer") or name:find("indicator") then
                        local isWhiteBg = (bgCol.R > 0.7 and bgCol.G > 0.7 and bgCol.B > 0.7)
                        local isWhiteImg = (imgCol.R > 0.7 and imgCol.G > 0.7 and imgCol.B > 0.7)
                        if isWhiteBg or isWhiteImg or name:find("needle") or name:find("pointer") or name:find("line") then
                            needleObj = desc
                        end
                    end

                    -- Detect Green Target Zone
                    local isGreenBg = (bgCol.G > 0.45 and bgCol.R < 0.55)
                    local isGreenImg = (imgCol.G > 0.45 and imgCol.R < 0.55)
                    if isGreenBg or isGreenImg or name:find("green") or name:find("target") or name:find("zone") or name:find("goal") or name:find("fill") then
                        greenObj = desc
                    end
                end
            end

            -- Execute Click when Needle enters Green Target
            if (needleObj and greenObj) or (hasMinigameText and needleObj and greenObj) then
                minigameFound = true
                State.MinigameActive = true

                local needleX = needleObj.AbsolutePosition.X + (needleObj.AbsoluteSize.X / 2)
                local greenMinX = greenObj.AbsolutePosition.X
                local greenMaxX = greenMinX + greenObj.AbsoluteSize.X

                -- Overlap Detection
                if needleX >= greenMinX and needleX <= greenMaxX then
                    if tick() - lastHitTick >= 0.04 then
                        lastHitTick = tick()
                        State.HitCounter = State.HitCounter + 1

                        local cam = Workspace.CurrentCamera
                        local screenCenterX = cam and (cam.ViewportSize.X / 2) or 500
                        local screenCenterY = cam and (cam.ViewportSize.Y / 2) or 300

                        -- 1. Click Anywhere on Screen (As requested by the game text)
                        VirtualInputManager:SendMouseButtonEvent(screenCenterX, screenCenterY, 0, true, game, 1)
                        task.wait(0.005)
                        VirtualInputManager:SendMouseButtonEvent(screenCenterX, screenCenterY, 0, false, game, 1)

                        -- 2. Click Needle Position
                        local clickX = math.floor(needleX)
                        local clickY = math.floor(needleObj.AbsolutePosition.Y + (needleObj.AbsoluteSize.Y / 2))
                        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
                        task.wait(0.005)
                        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)

                        -- 3. Spacebar Key Fallback
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                        task.wait(0.005)
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
-- 3. AUTO CAST & BAIT MANAGEMENT ENGINE (رمي السنارة وتعبئة الطعم)
-- ------------------------------------------------------------------------------
task.spawn(function()
    while task.wait(0.3) do
        if State.AutoFish then
            local rod = equipRodTool()

            -- Auto Re-Bait Routine
            if State.AutoRebait and rod then
                for _, rName in ipairs({"EquipBait", "BaitRemote", "Rebait", "Bait"}) do
                    local remote = ReplicatedStorage:FindFirstChild(rName, true)
                    if remote and remote:IsA("RemoteEvent") then
                        pcall(function() remote:FireServer() end)
                    end
                end
            end

            -- Cast Line into Water (Charge & Release Mechanics)
            if rod and not State.MinigameActive and (tick() - lastCastTick >= 2.0) then
                lastCastTick = tick()

                -- Activate Tool
                pcall(function() rod:Activate() end)

                local cam = Workspace.CurrentCamera
                local cx = cam and (cam.ViewportSize.X / 2) or 500
                local cy = cam and (cam.ViewportSize.Y * 0.35) or 250

                -- Hold Left Click for 0.4s to Charge Power, Then Release to Throw Line Far
                VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
                task.wait(0.4)
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
-- 4. GUI INTERFACE - حقوق أبو الهول عنّاز PRO V6
-- ------------------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "AbuAnnazHubV6"
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
stroke.Color = Color3.fromRGB(230, 35, 50)
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
title.Text = "👑 سكريبت حقوق أبو عنّاز | PERFECT FISHING V6 PRO"
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
            t.Btn.TextColor3 = Color3.fromRGB(210, 210, 210)
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
local fishPage = createTab("🎣 صيد الأسماك PRO V6")

pages["🎣 صيد الأسماك PRO V6"].Page.Visible = true
pages["🎣 صيد الأسماك PRO V6"].Btn.BackgroundColor3 = Color3.fromRGB(220, 30, 45)

addToggle(fishPage, "🎯 حل الضغط على الأخضر تلقائياً (Auto Click Green)", "AutoSolveGreen")
addToggle(fishPage, "🎣 مسك السنارة والرمي البعيد (Auto Equip & Cast)", "AutoFish")
addToggle(fishPage, "🪱 تعبئة الطعم تلقائياً (Auto Re-Bait)", "AutoRebait")
addToggle(fishPage, "🐟 تصفية وتدمير القمامة", "FilterTrash")

print("ABU ANNAZ HUB PERFECT FISHING V6 PRO LOADED!")
