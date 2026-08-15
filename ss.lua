-- ==============================================================================
-- Abu Annaz Hub V5 | حقوق أبو الهول عنّاز - MASTER BLOCKSPIN FISHING AUTOMATION ENGINE
-- Game: BlockSpin (Roblox)
-- Includes:
--   1. Universal Green Target & Needle Recognition (Every UI Structure)
--   2. Direct Mouse / Touch / Input Tap Simulation (Guaranteed Click Pass)
--   3. Auto Throw & Cast Rod Engine (No Stuck Loop)
--   4. Re-Baiting & Trash Discard System
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
if PlayerGui:FindFirstChild("AbuAnnazHubV5") then
    PlayerGui.AbuAnnazHubV5:Destroy()
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
-- 1. UNIVERSAL GREEN TARGET & NEEDLE ENGINE (حل الضغط على الأخضر بدقة متناهية)
-- ------------------------------------------------------------------------------
local function processFishingMinigame()
    if not State.AutoSolveGreen and not State.AutoFish then 
        State.MinigameActive = false
        return 
    end

    local minigameFound = false

    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AbuAnnazHubV5" then
            local needleObj = nil
            local greenObj = nil

            -- Deep Tree Inspection for UI Elements
            for _, element in ipairs(gui:GetDescendants()) do
                if element:IsA("GuiObject") and element.Visible and element.AbsoluteSize.X > 0 and element.AbsoluteSize.Y > 0 then
                    local bg = element.BackgroundColor3
                    local size = element.AbsoluteSize
                    local name = element.Name:lower()

                    -- Needle Detection (Thin bar / Indicator / White-ish)
                    if (size.X <= 20 and size.Y >= 12) or name:find("needle") or name:find("line") or name:find("pointer") or name:find("indicator") then
                        if (bg.R > 0.7 and bg.G > 0.7 and bg.B > 0.7) or name:find("needle") or name:find("pointer") then
                            needleObj = element
                        end
                    end

                    -- Green Zone Detection (Target Box)
                    if (bg.G > 0.45 and bg.R < 0.55) or name:find("green") or name:find("target") or name:find("zone") or name:find("goal") then
                        greenObj = element
                    end
                end
            end

            -- Execute Hit when Needle Enters Green Zone Boundaries
            if needleObj and greenObj then
                minigameFound = true
                State.MinigameActive = true

                local needleCenter = needleObj.AbsolutePosition.X + (needleObj.AbsoluteSize.X / 2)
                local greenLeft = greenObj.AbsolutePosition.X
                local greenRight = greenLeft + greenObj.AbsoluteSize.X

                -- Add safe margin padding
                local margin = math.clamp(greenObj.AbsoluteSize.X * 0.04, 1, 6)

                if needleCenter >= (greenLeft + margin) and needleCenter <= (greenRight - margin) then
                    if tick() - lastHitTick >= 0.04 then
                        lastHitTick = tick()
                        State.HitCounter = State.HitCounter + 1

                        local clickX = math.floor(needleCenter)
                        local clickY = math.floor(needleObj.AbsolutePosition.Y + (needleObj.AbsoluteSize.Y / 2))

                        -- 1. Virtual Mouse Down & Up (Primary Click)
                        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
                        task.wait(0.005)
                        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)

                        -- 2. Touch Tap Simulation (Mobile/Touch compatibility)
                        VirtualInputManager:SendTouchEvent(1, Enum.UserInputState.Begin, Vector2.new(clickX, clickY), game)
                        task.wait(0.005)
                        VirtualInputManager:SendTouchEvent(1, Enum.UserInputState.End, Vector2.new(clickX, clickY), game)

                        -- 3. Spacebar Key Event
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

RunService.RenderStepped:Connect(processFishingMinigame)

-- ------------------------------------------------------------------------------
-- 2. RELIABLE AUTO-CAST & BAIT REPLACEMENT MOTOR (رمي السنارة والتعبئة التلقائية)
-- ------------------------------------------------------------------------------
local function getActiveRod()
    local char = LocalPlayer.Character
    if not char then return nil end

    local tool = char:FindFirstChildOfClass("Tool")
    if tool then return tool end

    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                item.Parent = char
                return item
            end
        end
    end
    return nil
end

task.spawn(function()
    while task.wait(0.3) do
        if State.AutoFish then
            local rod = getActiveRod()

            -- Auto Re-Bait Remote Triggers
            if State.AutoRebait and rod then
                for _, rName in ipairs({"EquipBait", "BaitRemote", "Rebait", "Bait"}) do
                    local remote = ReplicatedStorage:FindFirstChild(rName, true)
                    if remote and remote:IsA("RemoteEvent") then
                        pcall(function() remote:FireServer() end)
                    end
                end
            end

            -- Cast Line when Minigame is NOT active
            if rod and not State.MinigameActive and (tick() - lastCastTick >= 1.8) then
                lastCastTick = tick()

                -- Tool Activate
                pcall(function() rod:Activate() end)

                -- Mouse Cast Action
                local cam = Workspace.CurrentCamera
                local cx = cam and (cam.ViewportSize.X / 2) or 500
                local cy = cam and (cam.ViewportSize.Y * 0.35) or 250

                VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
                task.wait(0.08)
                VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
            end
        end

        -- Filter Trash Items
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
-- 3. GUI DESIGN - حقوق أبو عنّاز V5
-- ------------------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "AbuAnnazHubV5"
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
title.Text = "👑 سكريبت حقوق أبو عنّاز | MASTER FISHING HUB V5"
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
local fishPage = createTab("🎣 صيد الأسماك المباشر V5")

pages["🎣 صيد الأسماك المباشر V5"].Page.Visible = true
pages["🎣 صيد الأسماك المباشر V5"].Btn.BackgroundColor3 = Color3.fromRGB(220, 30, 45)

addToggle(fishPage, "🎯 الضغط على الأخضر تلقائياً (Auto Hit Green)", "AutoSolveGreen")
addToggle(fishPage, "🎣 رمي السنارة البعيد (Auto Cast Rod)", "AutoFish")
addToggle(fishPage, "🪱 تعبئة الطعم تلقائياً (Auto Re-Bait)", "AutoRebait")
addToggle(fishPage, "🐟 تصفية وتدمير القمامة", "FilterTrash")

print("ABU ANNAZ HUB MASTER FISHING V5 FULLY LOADED!")
