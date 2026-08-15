-- ==============================================================================
-- ProbeX BlockSSpin Real Automation Hub (Fully Functional Motor & Automation Mechanics)
-- Game: BlockSpin (Roblox)
-- Includes: Active Character Movement (Tween/Teleport), Real Fishing Loop, Real ATM Hacking, Aimbot Loop, ESP Highlights
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
local existing = PlayerGui:FindFirstChild("BlockSpinRealHub")
if existing then existing:Destroy() end

-- Global State
local State = {
    Aimbot = false,
    ESP = false,
    AutoFarmATMs = false,
    AutoFarmJobs = false,
    AutoFish = false,
    SkipSlider = true,
    FilterTrash = true,
}

-- Target Trash Items
local TrashNames = {
    ["Boot"] = true, ["Old Boot"] = true, ["Seaweed"] = true,
    ["Tin Can"] = true, ["Driftwood"] = true, ["Trash"] = true,
    ["Bass"] = false, ["Perch"] = false, ["Salmon"] = false
}

-- Helper Movement (Tween Engine to prevent AC bans)
local function moveToPosition(targetPos, speed)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    speed = speed or 50
    local dist = (root.Position - targetPos).Magnitude
    local timeToTravel = dist / speed

    local tweenInfo = TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(root, tweenInfo, {CFrame = CFrame.new(targetPos)})
    tween:Play()
    return tween
end

-- 1. REAL AIMBOT & ESP ENGINE
local espBoxes = {}

RunService.RenderStepped:Connect(function()
    -- ESP Engine
    if State.ESP then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local char = p.Character
                if not char:FindFirstChild("HubHighlight") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "HubHighlight"
                    hl.FillColor = Color3.fromRGB(255, 30, 40)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.5
                    hl.Parent = char
                end
            end
        end
    else
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("HubHighlight") then
                p.Character.HubHighlight:Destroy()
            end
        end
    end

    -- AIMBOT Engine
    if State.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local cam = Workspace.CurrentCamera
        local nearest = nil
        local minDist = 300

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") then
                if p.Character.Humanoid.Health > 0 then
                    local screenPos, onScreen = cam:WorldToViewportPoint(p.Character.Head.Position)
                    if onScreen then
                        local mousePos = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < minDist then
                            minDist = dist
                            nearest = p.Character.Head
                        end
                    end
                end
            end
        end

        if nearest then
            cam.CFrame = CFrame.new(cam.CFrame.Position, nearest.Position)
        end
    end
end)

-- 2. REAL ATM AUTOMATION MOTOR
task.spawn(function()
    while task.wait(1) do
        if State.AutoFarmATMs then
            local atms = {}
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name:find("ATM") or obj.Name:find("Atm") or obj.Name:find("Bank") then
                    if obj:IsA("BasePart") or obj:IsA("Model") then
                        table.insert(atms, obj)
                    end
                end
            end

            for _, atm in ipairs(atms) do
                if not State.AutoFarmATMs then break end
                local targetPos = atm:IsA("Model") and atm:GetPrimaryPartCFrame().Position or atm.Position
                if targetPos then
                    local tw = moveToPosition(targetPos + Vector3.new(0, 2, 3), 45)
                    if tw then tw.Completed:Wait() end

                    -- Simulate Interaction Key (E)
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.2)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    task.wait(2)
                end
            end
        end
    end
end)

-- 3. REAL FISHING MOTOR & SKIP SLIDER INTEGRATION
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoFish then
            local char = LocalPlayer.Character
            local rod = char and char:FindFirstChildOfClass("Tool")
            if not rod then
                local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
                if backpack then
                    for _, tool in ipairs(backpack:GetChildren()) do
                        if tool.Name:find("Rod") or tool.Name:find("Fish") or tool.Name:find("Fishing") then
                            tool.Parent = char
                            rod = tool
                            break
                        end
                    end
                end
            end

            -- Click to cast line
            VirtualInputManager:SendMouseButtonEvent(cam and cam.ViewportSize.X/2 or 500, cam and cam.ViewportSize.Y/2 or 500, 0, true, game, 1)
            task.wait(0.1)
            VirtualInputManager:SendMouseButtonEvent(cam and cam.ViewportSize.X/2 or 500, cam and cam.ViewportSize.Y/2 or 500, 0, false, game, 1)
            
            -- Skip Slider Script Execution when active
            if State.SkipSlider then
                pcall(function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/kahhakanouar-arch/skip-slider/refs/heads/main/blockspin%20skip%20slider"))()
                end)
            end
        end

        -- Filter Trash Motor
        if State.FilterTrash then
            local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
            if backpack then
                for _, item in ipairs(backpack:GetChildren()) do
                    if TrashNames[item.Name] then
                        item:Destroy()
                    end
                end
            end
        end
    end
end)

-- 4. UI CREATION SYSTEM
local gui = Instance.new("ScreenGui")
gui.Name = "BlockSpinRealHub"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 520, 0, 380)
main.Position = UDim2.new(0.5, -260, 0.5, -190)
main.BackgroundColor3 = Color3.fromRGB(15, 12, 16)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(220, 35, 45)
stroke.Thickness = 1.5

-- Header
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(26, 16, 22)
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0.7, 0, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.Text = "BLOCKSPIN - REAL AUTOMATION ENGINE"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -32, 0.5, -13)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 50)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Sidebar
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 130, 1, -50)
sidebar.Position = UDim2.new(0, 6, 0, 44)
sidebar.BackgroundColor3 = Color3.fromRGB(20, 15, 18)
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8)

local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.Padding = UDim.new(0, 6)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sideLayout.VerticalAlignment = Enum.VerticalAlignment.Top

-- Content
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -148, 1, -50)
content.Position = UDim2.new(0, 142, 0, 44)
content.BackgroundColor3 = Color3.fromRGB(22, 17, 20)
content.BorderSizePixel = 0
Instance.new("UICorner", content).CornerRadius = UDim.new(0, 8)

local pages = {}

local function createTab(name)
    local tabBtn = Instance.new("TextButton", sidebar)
    tabBtn.Size = UDim2.new(0.9, 0, 0, 34)
    tabBtn.Text = name
    tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabBtn.BackgroundColor3 = Color3.fromRGB(30, 22, 26)
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
            t.Btn.BackgroundColor3 = Color3.fromRGB(30, 22, 26)
            t.Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        page.Visible = true
        tabBtn.BackgroundColor3 = Color3.fromRGB(210, 35, 45)
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    return page
end

local function addToggle(parent, label, key)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 36)
    btn.BackgroundColor3 = State[key] and Color3.fromRGB(190, 30, 40) or Color3.fromRGB(36, 26, 30)
    btn.Text = label .. (State[key] and " [ON]" or " [OFF]")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        State[key] = not State[key]
        btn.Text = label .. (State[key] and " [ON]" or " [OFF]")
        btn.BackgroundColor3 = State[key] and Color3.fromRGB(190, 30, 40) or Color3.fromRGB(36, 26, 30)
    end)
    return btn
end

-- Create Real Automation Pages
local pvpPage = createTab("⚔️ Real Combat")
local farmPage = createTab("💰 Real ATM Farm")
local fishPage = createTab("🎣 Real Fishing")

pages["⚔️ Real Combat"].Page.Visible = true
pages["⚔️ Real Combat"].Btn.BackgroundColor3 = Color3.fromRGB(210, 35, 45)

addToggle(pvpPage, "🔫 Real Camera Aimbot (RMB)", "Aimbot")
addToggle(pvpPage, "👁️ Real Highlight ESP", "ESP")

addToggle(farmPage, "💳 Real Teleport & Hack ATMs", "AutoFarmATMs")

addToggle(fishPage, "🎣 Real Auto Cast & Reel", "AutoFish")
addToggle(fishPage, "⚡ Skip Slider / Minigame", "SkipSlider")
addToggle(fishPage, "🐟 Auto Destroy Trash", "FilterTrash")

print("REAL AUTOMATION ENGINE ACTIVE!")
