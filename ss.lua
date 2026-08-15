-- ==============================================================================
-- Abu Annaz Hub | حقوق أبو عنّاز - BLOCKSPIN ULTIMATE AUTOMATION
-- Game: BlockSpin (Roblox)
-- Features: Precise Needle-to-Green Hit Motor (Multi-stage shrinking bar solver),
--           Auto Fishing, Real ATM Teleport & Hack, Aimbot, Player ESP, Webhook System
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

-- Global Hub Configuration
local State = {
    AutoSolveGreen = true, -- Auto click when needle is over green target
    AutoFish = false,
    AutoFarmATMs = false,
    Aimbot = false,
    ESP = false,
    FilterTrash = true,
    WebhookURL = "",
}

local TrashItems = {
    ["Boot"] = true, ["Old Boot"] = true, ["Seaweed"] = true,
    ["Tin Can"] = true, ["Driftwood"] = true, ["Trash"] = true
}

-- Helper Movement (Smooth Waypoint Tween)
local function moveToPos(targetPos, speed)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    speed = speed or 45
    local dist = (root.Position - targetPos).Magnitude
    local tween = TweenService:Create(root, TweenInfo.new(dist / speed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
    tween:Play()
    return tween
end

-- 1. REAL-TIME GREEN NEEDLE MINIGAME SOLVER (حل اختبار الإبرة الخضراء التلقائي)
RunService.RenderStepped:Connect(function()
    if not State.AutoSolveGreen and not State.AutoFish then return end

    -- Scan for Needle Minigame UI elements in PlayerGui
    for _, guiObj in ipairs(PlayerGui:GetChildren()) do
        if guiObj:IsA("ScreenGui") and guiObj.Enabled then
            -- Search for Needle (White line) and Green Target Bar
            local needle = nil
            local greenTarget = nil

            for _, desc in ipairs(guiObj:GetDescendants()) do
                if desc:IsA("Frame") or desc:IsA("ImageLabel") or desc:IsA("TextLabel") then
                    local name = desc.Name:lower()
                    local col = desc.BackgroundColor3

                    -- Identify Needle (White Line)
                    if name:find("needle") or name:find("pointer") or name:find("bar") or (col.R > 0.9 and col.G > 0.9 and col.B > 0.9 and desc.Size.X.Offset <= 6) then
                        needle = desc
                    end

                    -- Identify Green Target (Green Shrinking Zone)
                    if name:find("green") or name:find("target") or name:find("zone") or (col.G > 0.6 and col.R < 0.3) then
                        greenTarget = desc
                    end
                end
            end

            -- If Needle & Green Target are detected, calculate overlap
            if needle and greenTarget then
                local needleX = needle.AbsolutePosition.X + (needle.AbsoluteSize.X / 2)
                local greenMinX = greenTarget.AbsolutePosition.X
                local greenMaxX = greenMinX + greenTarget.AbsoluteSize.X

                -- Trigger Click when Needle is within the Green Zone
                if needleX >= (greenMinX + 2) and needleX <= (greenMaxX - 2) then
                    VirtualInputManager:SendMouseButtonEvent(needleX, needle.AbsolutePosition.Y, 0, true, game, 1)
                    task.wait(0.02)
                    VirtualInputManager:SendMouseButtonEvent(needleX, needle.AbsolutePosition.Y, 0, false, game, 1)
                    task.wait(0.15) -- Anti-spam delay between multi-stage hits
                end
            end
        end
    end
end)

-- 2. REAL AIMBOT & HIGHLIGHT ESP ENGINE
RunService.RenderStepped:Connect(function()
    -- ESP Engine
    if State.ESP then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local char = p.Character
                if not char:FindFirstChild("AnnazHighlight") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "AnnazHighlight"
                    hl.FillColor = Color3.fromRGB(0, 220, 120)
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

    -- Camera Aimbot
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

-- 3. ATM FARMING & FISHING LOOPS
task.spawn(function()
    while task.wait(1.2) do
        if State.AutoFarmATMs then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if not State.AutoFarmATMs then break end
                if obj.Name:find("ATM") or obj.Name:find("Atm") then
                    local pos = obj:IsA("Model") and obj:GetPrimaryPartCFrame().Position or (obj:IsA("BasePart") and obj.Position or nil)
                    if pos then
                        local tw = moveToPos(pos + Vector3.new(0, 2, 3), 40)
                        if tw then tw.Completed:Wait() end
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        task.wait(0.1)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        task.wait(2)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.6) do
        if State.AutoFish then
            local char = LocalPlayer.Character
            local rod = char and char:FindFirstChildOfClass("Tool")
            if not rod then
                local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
                if backpack then
                    for _, t in ipairs(backpack:GetChildren()) do
                        if t.Name:find("Rod") or t.Name:find("Fish") then
                            t.Parent = char
                            break
                        end
                    end
                end
            end
            
            -- Cast Rod
            VirtualInputManager:SendMouseButtonEvent(400, 400, 0, true, game, 1)
            task.wait(0.1)
            VirtualInputManager:SendMouseButtonEvent(400, 400, 0, false, game, 1)
        end

        -- Auto Trash Clean
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

-- 4. UI DESIGN SYSTEM - حقوق أبو عنّاز (ABU ANNAZ HUB)
local gui = Instance.new("ScreenGui")
gui.Name = "AbuAnnazHub"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 550, 0, 410)
main.Position = UDim2.new(0.5, -275, 0.5, -205)
main.BackgroundColor3 = Color3.fromRGB(16, 12, 16)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(220, 30, 45)
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
title.Text = "👑 سكريبت حقوق أبو عنّاز | BLOCKSPIN HUB"
title.TextColor3 = Color3.fromRGB(255, 220, 50)
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
sidebar.Size = UDim2.new(0, 145, 1, -56)
sidebar.Position = UDim2.new(0, 8, 0, 50)
sidebar.BackgroundColor3 = Color3.fromRGB(22, 15, 20)
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8)

local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.Padding = UDim.new(0, 6)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sideLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -167, 1, -56)
content.Position = UDim2.new(0, 159, 0, 50)
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
local fishPage = createTab("🎣 اختبار الإبرة والخضراء")
local farmPage = createTab("💰 أوتوفارم الـ ATMs")
local pvpPage  = createTab("⚔️ القتال Aimbot & ESP")

pages["🎣 اختبار الإبرة والخضراء"].Page.Visible = true
pages["🎣 اختبار الإبرة والخضراء"].Btn.BackgroundColor3 = Color3.fromRGB(220, 30, 45)

addToggle(fishPage, "🎯 حل الإبرة الخضراء تلقائياً (Minigame Solver)", "AutoSolveGreen")
addToggle(fishPage, "🎣 صيد أسماك تلقائي (Auto Cast)", "AutoFish")
addToggle(fishPage, "🐟 تصفية وتدمير القمامة", "FilterTrash")

addToggle(farmPage, "💳 أوتوفارم وتنقل الـ ATMs تلقائياً", "AutoFarmATMs")

addToggle(pvpPage, "🔫 تثبيت الكاميرا Aimbot (RMB)", "Aimbot")
addToggle(pvpPage, "👁️ كشف اللاعبين ESP", "ESP")

print("حقوق أبو عنّاز | ABU ANNAZ HUB LOADED SUCCESSFULLY!")
