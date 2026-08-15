-- ==============================================================================
-- Abu Annaz Hub V3 | حقوق أبو العم عنّاز - DYNAMIC MULTI-STAGE GREEN NEEDLE SOLVER & FAR CAST
-- Game: BlockSpin (Roblox)
-- Features: 
--  1. Far Cast & Long Distance Rod Throw (رمي السنارة بعيداً في البحيرة)
--  2. Dynamic Dynamic Multi-Stage Shrinking Green Box Tracking (تتبع تغير وتصاغر المربع الأخضر تلقائياً)
--  3. Non-Blocking Non-Stuck Loop Engine (حل التعليق وإعادة الصيد بسلاسة)
--  4. Auto Re-Bait & Trash Filter
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
if PlayerGui:FindFirstChild("AbuAnnazHub") then
    PlayerGui.AbuAnnazHub:Destroy()
end

-- Global Configuration
local State = {
    AutoSolveGreen = true,
    AutoFish = false,
    AutoRebait = true,
    CastDistance = 250, -- Distance to cast line far into the water
    FilterTrash = true,
    Aimbot = false,
    ESP = false,
}

local TrashItems = {
    ["Boot"] = true, ["Old Boot"] = true, ["Seaweed"] = true,
    ["Tin Can"] = true, ["Driftwood"] = true, ["Trash"] = true
}

-- Global Trackers for Minigame State
local isMinigameActive = false
local lastClickTick = 0

-- 1. REAL-TIME DYNAMIC MULTI-STAGE SHRINKING GREEN ZONE SOLVER
RunService.RenderStepped:Connect(function()
    if not State.AutoSolveGreen and not State.AutoFish then 
        isMinigameActive = false
        return 
    end

    local minigameFoundThisFrame = false

    for _, guiObj in ipairs(PlayerGui:GetChildren()) do
        if guiObj:IsA("ScreenGui") and guiObj.Enabled and guiObj.Name ~= "AbuAnnazHub" then
            local needle = nil
            local greenZone = nil

            -- Dynamic Element Scanner
            for _, desc in ipairs(guiObj:GetDescendants()) do
                if desc:IsA("GuiObject") and desc.Visible then
                    local col = desc.BackgroundColor3
                    local absSize = desc.AbsoluteSize
                    local name = desc.Name:lower()

                    -- Detect Needle (White / Moving Vertical Line)
                    if absSize.X <= 14 and absSize.Y >= 18 then
                        if (col.R > 0.8 and col.G > 0.8 and col.B > 0.8) or name:find("needle") or name:find("pointer") or name:find("line") then
                            needle = desc
                        end
                    end

                    -- Detect Green Target (Shrinking / Relocating Green Box)
                    if (col.G > 0.5 and col.R < 0.45) or name:find("green") or name:find("target") or name:find("zone") then
                        greenZone = desc
                    end
                end
            end

            -- High-Precision Dynamic Bound Checking
            if needle and greenZone then
                minigameFoundThisFrame = true
                isMinigameActive = true

                -- Avoid rapid double-click on the same frame (minimum 0.08s gap)
                if tick() - lastClickTick >= 0.08 then
                    local needleX = needle.AbsolutePosition.X + (needle.AbsoluteSize.X / 2)
                    local greenMinX = greenZone.AbsolutePosition.X
                    local greenMaxX = greenMinX + greenZone.AbsoluteSize.X

                    -- Calculate margin padding based on shrinking green zone size
                    local padding = math.clamp(greenZone.AbsoluteSize.X * 0.08, 1, 5)

                    -- Check if needle currently sits inside the relocated green zone
                    if needleX >= (greenMinX + padding) and needleX <= (greenMaxX - padding) then
                        lastClickTick = tick()

                        -- Fire Direct Click Interaction
                        local clickX = math.floor(needleX)
                        local clickY = math.floor(needle.AbsolutePosition.Y + (needle.AbsoluteSize.Y / 2))

                        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
                        task.wait(0.01)
                        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)

                        -- Fallback Spacebar
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                        task.wait(0.01)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                    end
                end
            end
        end
    end

    if not minigameFoundThisFrame then
        isMinigameActive = false
    end
end)

-- 2. NON-BLOCKING FAR-CASTING & AUTOMATION MOTOR
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoFish then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local rod = char and char:FindFirstChildOfClass("Tool")
            
            -- Auto Equip Rod if in Backpack
            if not rod then
                local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
                if backpack then
                    for _, t in ipairs(backpack:GetChildren()) do
                        if t.Name:find("Rod") or t.Name:find("Fish") or t.Name:find("Fishing") then
                            t.Parent = char
                            rod = t
                            break
                        end
                    end
                end
            end

            -- Auto Re-Bait Routine
            if State.AutoRebait and rod then
                local baitRemote = ReplicatedStorage:FindFirstChild("EquipBait") or ReplicatedStorage:FindFirstChild("BaitRemote")
                if baitRemote and baitRemote:IsA("RemoteEvent") then
                    pcall(function() baitRemote:FireServer() end)
                end
            end

            -- Cast Far into the Water ONLY when Minigame is NOT active (Prevents Sticking/Freezing)
            if rod and not isMinigameActive then
                -- Perform Far Cast Position Calculation
                local cam = Workspace.CurrentCamera
                local castScreenPos = cam and Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 3) or Vector2.new(600, 300)

                -- Simulate Long Distance Line Cast
                VirtualInputManager:SendMouseButtonEvent(castScreenPos.X, castScreenPos.Y, 0, true, game, 1)
                task.wait(0.08)
                VirtualInputManager:SendMouseButtonEvent(castScreenPos.X, castScreenPos.Y, 0, false, game, 1)
                
                -- Pause briefly before checking next loop
                task.wait(1.5)
            end
        end

        -- Filter Trash Routine
        if State.FilterTrash then
            local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
            if backpack then
                for _, item in ipairs(backpack:GetChildren()) do
                    if TrashItems[item.Name] then
                        item:Destroy()
                    end
                end
            end
        end
    end
end)

-- 3. ESP & AIMBOT ENGINE
RunService.RenderStepped:Connect(function()
    if State.ESP then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local char = p.Character
                if not char:FindFirstChild("AnnazHighlight") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "AnnazHighlight"
                    hl.FillColor = Color3.fromRGB(0, 230, 130)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.4
                    hl.Parent = char
                end
            end
        end
    else
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("AnnazHighlight") then
                p.Character.AnnazHighlight:Destroy()
            end
        end
    end

    if State.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local cam = Workspace.CurrentCamera
        local targetHead = nil
        local minDist = 350

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") then
                if p.Character.Humanoid.Health > 0 then
                    local sPos, onScreen = cam:WorldToViewportPoint(p.Character.Head.Position)
                    if onScreen then
                        local mPos = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
                        local dist = (Vector2.new(sPos.X, sPos.Y) - mPos).Magnitude
                        if dist < minDist then
                            minDist = dist
                            targetHead = p.Character.Head
                        end
                    end
                end
            end
        end

        if targetHead then
            cam.CFrame = CFrame.new(cam.CFrame.Position, targetHead.Position)
        end
    end
end)

-- 4. UI CREATION SYSTEM - حقوق أبو عنّاز (ABU ANNAZ HUB V3 DYNAMIC)
local gui = Instance.new("ScreenGui")
gui.Name = "AbuAnnazHub"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 560, 0, 420)
main.Position = UDim2.new(0.5, -280, 0.5, -210)
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
header.Size = UDim2.new(1, 0, 0, 46)
header.BackgroundColor3 = Color3.fromRGB(28, 16, 22)
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0.8, 0, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.Text = "👑 حقوق أبو عنّاز | DYNAMIC FISHING & FAR CAST V3"
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
sidebar.Size = UDim2.new(0, 150, 1, -56)
sidebar.Position = UDim2.new(0, 8, 0, 50)
sidebar.BackgroundColor3 = Color3.fromRGB(22, 15, 20)
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8)

local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.Padding = UDim.new(0, 6)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sideLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -172, 1, -56)
content.Position = UDim2.new(0, 164, 0, 50)
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

-- Tabs
local fishPage = createTab("🎣 صيد الأسماك المتقدم V3")
local pvpPage  = createTab("⚔️ Aimbot & ESP")

pages["🎣 صيد الأسماك المتقدم V3"].Page.Visible = true
pages["🎣 صيد الأسماك المتقدم V3"].Btn.BackgroundColor3 = Color3.fromRGB(220, 30, 45)

addToggle(fishPage, "🎯 حل الإبرة المتغيرة والصغيره (Dynamic Needle Solver)", "AutoSolveGreen")
addToggle(fishPage, "🎣 رمي السنارة بعيداً بالبحيرة (Far Cast & Reel)", "AutoFish")
addToggle(fishPage, "🪱 تعبئة الطعم تلقائياً (Auto Re-Bait)", "AutoRebait")
addToggle(fishPage, "🐟 تصفية وتدمير القمامة", "FilterTrash")

addToggle(pvpPage, "🔫 تثبيت الكاميرا Aimbot (RMB)", "Aimbot")
addToggle(pvpPage, "👁️ كشف اللاعبين ESP", "ESP")

print("ABU ANNAZ HUB DYNAMIC FISHING V3 LOADED SUCCESSFULLY!")
