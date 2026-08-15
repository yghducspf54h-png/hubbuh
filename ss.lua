-- ==============================================================================
-- Abu Annaz Hub V4 | حقوق أبو عنّاز - ULTIMATE AUTO FISHING ENGINE
-- Game: BlockSpin (Roblox)
-- Dedicated Comprehensive Fishing Automation, Bait Engine & Dynamic Needle Solver
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

-- Clean previous instance
if PlayerGui:FindFirstChild("AbuAnnazHubV4") then
    PlayerGui.AbuAnnazHubV4:Destroy()
end

-- Global Configuration & States
local State = {
    AutoSolveGreen = true,
    AutoFish = true,
    AutoRebait = true,
    FilterTrash = true,
    CastPower = 0.8,
    NeedleSpeedFactor = 1.0,
    HitsCount = 0,
    SuccessfulCatches = 0,
}

local TrashItems = {
    ["Boot"] = true, ["Old Boot"] = true, ["Seaweed"] = true,
    ["Tin Can"] = true, ["Driftwood"] = true, ["Trash"] = true
}

local isMinigameActive = false
local lastCastTime = 0
local lastClickTick = 0

-- ------------------------------------------------------------------------------
-- 1. ADVANCED DYNAMIC GREEN NEEDLE SOLVER ENGINE
-- ------------------------------------------------------------------------------
local function findNeedleAndTarget(parentGui)
    local needle = nil
    local greenZone = nil

    for _, desc in ipairs(parentGui:GetDescendants()) do
        if desc:IsA("GuiObject") and desc.Visible then
            local col = desc.BackgroundColor3
            local size = desc.AbsoluteSize
            local name = desc.Name:lower()

            -- Detect Needle (Vertical white/light indicator)
            if size.X <= 16 and size.Y >= 14 then
                if (col.R > 0.75 and col.G > 0.75 and col.B > 0.75) or name:find("needle") or name:find("pointer") or name:find("line") or name:find("indicator") then
                    needle = desc
                end
            end

            -- Detect Green Target Box (Shrinking / Moving zone)
            if (col.G > 0.5 and col.R < 0.5) or name:find("green") or name:find("target") or name:find("zone") or name:find("goal") then
                greenZone = desc
            end
        end
    end

    return needle, greenZone
end

RunService.RenderStepped:Connect(function()
    if not State.AutoSolveGreen and not State.AutoFish then 
        isMinigameActive = false
        return 
    end

    local foundInFrame = false

    for _, guiObj in ipairs(PlayerGui:GetChildren()) do
        if guiObj:IsA("ScreenGui") and guiObj.Enabled and guiObj.Name ~= "AbuAnnazHubV4" then
            local needle, greenZone = findNeedleAndTarget(guiObj)

            if needle and greenZone then
                foundInFrame = true
                isMinigameActive = true

                -- Prevent rapid duplicate triggers within 0.05 seconds
                if tick() - lastClickTick >= 0.05 then
                    local needleCenterX = needle.AbsolutePosition.X + (needle.AbsoluteSize.X / 2)
                    local greenMinX = greenZone.AbsolutePosition.X
                    local greenMaxX = greenMinX + greenZone.AbsoluteSize.X

                    -- Dynamic safe padding calculated from green zone width
                    local padding = math.clamp(greenZone.AbsoluteSize.X * 0.05, 1, 4)

                    -- Trigger click when needle is inside green boundaries
                    if needleCenterX >= (greenMinX + padding) and needleCenterX <= (greenMaxX - padding) then
                        lastClickTick = tick()
                        State.HitsCount = State.HitsCount + 1

                        local clickX = math.floor(needleCenterX)
                        local clickY = math.floor(needle.AbsolutePosition.Y + (needle.AbsoluteSize.Y / 2))

                        -- Primary Mouse Click
                        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
                        task.wait(0.01)
                        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)

                        -- Secondary Remote Fire Fallback
                        local rem = ReplicatedStorage:FindFirstChild("FishingRemote", true) or ReplicatedStorage:FindFirstChild("MinigameRemote", true)
                        if rem and rem:IsA("RemoteEvent") then
                            pcall(function() rem:FireServer("Hit", needleCenterX) end)
                        end

                        -- Tertiary Key Fallback (Spacebar)
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                        task.wait(0.01)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                    end
                end
            end
        end
    end

    if not foundInFrame then
        isMinigameActive = false
    end
end)

-- ------------------------------------------------------------------------------
-- 2. DEDICATED AUTO-CAST & BAIT MANAGEMENT MOTOR
-- ------------------------------------------------------------------------------
local function getFishingRod()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    local rod = char:FindFirstChildOfClass("Tool")
    if rod and (rod.Name:lower():find("rod") or rod.Name:lower():find("fish")) then
        return rod
    end

    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item.Name:lower():find("rod") or item.Name:lower():find("fish") then
                item.Parent = char
                return item
            end
        end
    end
    return nil
end

task.spawn(function()
    while task.wait(0.4) do
        if State.AutoFish then
            local rod = getFishingRod()

            -- Auto Re-Bait Routine
            if State.AutoRebait and rod then
                local baitRemote = ReplicatedStorage:FindFirstChild("EquipBait", true) or ReplicatedStorage:FindFirstChild("BaitRemote", true) or ReplicatedStorage:FindFirstChild("Rebait", true)
                if baitRemote and baitRemote:IsA("RemoteEvent") then
                    pcall(function() baitRemote:FireServer() end)
                end
            end

            -- Auto Cast Line (Far into Water)
            if rod and not isMinigameActive and (tick() - lastCastTime >= 2.2) then
                lastCastTime = tick()

                local cam = Workspace.CurrentCamera
                local castX = cam and (cam.ViewportSize.X / 2) or 500
                local castY = cam and (cam.ViewportSize.Y * 0.35) or 250

                -- Activate Rod Tool
                pcall(function() rod:Activate() end)

                -- Mouse Cast Interaction
                VirtualInputManager:SendMouseButtonEvent(castX, castY, 0, true, game, 1)
                task.wait(0.12)
                VirtualInputManager:SendMouseButtonEvent(castX, castY, 0, false, game, 1)
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
-- 3. USER INTERFACE (ABU ANNAZ HUB V4 PRO)
-- ------------------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "AbuAnnazHubV4"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 560, 0, 430)
main.Position = UDim2.new(0.5, -280, 0.5, -215)
main.BackgroundColor3 = Color3.fromRGB(16, 12, 16)
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
header.Size = UDim2.new(1, 0, 0, 46)
header.BackgroundColor3 = Color3.fromRGB(28, 16, 22)
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0.8, 0, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.Text = "👑 سكريبت حقوق أبو عنّاز | BLOCKSPIN AUTOMATION V4"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.BackgroundTransparency = 1

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -36, 0.5, -14)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 50)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Sidebar & Content
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 155, 1, -56)
sidebar.Position = UDim2.new(0, 8, 0, 50)
sidebar.BackgroundColor3 = Color3.fromRGB(22, 15, 20)
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8)

local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.Padding = UDim.new(0, 6)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sideLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -177, 1, -56)
content.Position = UDim2.new(0, 169, 0, 50)
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

-- Create Dedicated Tabs
local fishPage = createTab("🎣 صيد الأسماك التلقائي V4")

pages["🎣 صيد الأسماك التلقائي V4"].Page.Visible = true
pages["🎣 صيد الأسماك التلقائي V4"].Btn.BackgroundColor3 = Color3.fromRGB(220, 30, 45)

addToggle(fishPage, "🎯 حل الإبرة الخضراء المتغيرة (Green Needle Solver)", "AutoSolveGreen")
addToggle(fishPage, "🎣 رمي السنارة البعيد وصيد تلقائي (Auto Cast)", "AutoFish")
addToggle(fishPage, "🪱 تعبئة الطعم تلقائياً (Auto Re-Bait)", "AutoRebait")
addToggle(fishPage, "🐟 تصفية وتدمير القمامة", "FilterTrash")

print("ABU ANNAZ HUB V4 ENGINE FULLY LOADED!")
