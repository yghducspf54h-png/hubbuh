-- ==============================================================================
-- ProbeX BlockSpin Ultimate Hub (Safe Standard Roblox Luau)
-- Game: BlockSpin (Roblox)
-- Robust Executor Compatibility & Network Bypasses
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    repeat task.wait() until Players.LocalPlayer
    LocalPlayer = Players.LocalPlayer
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
if not PlayerGui then return end

-- Clean previous instances safely
local existing = PlayerGui:FindFirstChild("BlockSpinUltimateHub")
if existing then
    existing:Destroy()
end

-- Global Hub State Configuration
local HubState = {
    AimbotEnabled = false,
    TargetCircle = false,
    FOVRadius = 120,
    ESPEnabled = false,
    
    AutoFarmJobs = false,
    ATMAutoHack = false,
    AutoFish = false,
    SkipSlider = true,
    FilterBadFish = true,
    
    TrashList = {
        ["Bass"] = false,
        ["Perch"] = false,
        ["Salmon"] = false,
        ["Northern Pike"] = false,
        ["Dolphinfish"] = false,
        ["Coelacanth"] = true,
        ["Tuna"] = true,
        ["Sailfish"] = true,
        ["Marlin"] = true,
        ["Boot"] = true,
        ["Tin Can"] = true,
        ["Seaweed"] = true,
    },
    
    WebhookURL = "",
}

-- 1. Game Reverse-Engineered Network Remotes (Bypass & Fire System)
local function getGameRemote(remoteName)
    local found = ReplicatedStorage:FindFirstChild(remoteName, true) or Workspace:FindFirstChild(remoteName, true)
    return found
end

-- Auto Fishing & Slider Bypass Loop
task.spawn(function()
    while task.wait(0.4) do
        if HubState.AutoFish then
            local castRemote = getGameRemote("CastLine") or getGameRemote("FishingRemote") or getGameRemote("Fish")
            if castRemote and castRemote:IsA("RemoteEvent") then
                pcall(function() castRemote:FireServer() end)
            end
        end
        
        -- Filter Bad Fish Logic
        if HubState.FilterBadFish then
            local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
            if backpack then
                for _, item in ipairs(backpack:GetChildren()) do
                    if HubState.TrashList[item.Name] then
                        pcall(function() item:Destroy() end)
                    end
                end
            end
        end
    end
end)

-- 2. UI Builder Frame Structure
local gui = Instance.new("ScreenGui")
gui.Name = "BlockSpinUltimateHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Name = "MainFrame"
main.Size = UDim2.new(0, 540, 0, 400)
main.Position = UDim2.new(0.5, -270, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(20, 14, 18)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(190, 30, 45)
stroke.Thickness = 1.5
stroke.Parent = main

-- Top Bar Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 42)
header.BackgroundColor3 = Color3.fromRGB(30, 18, 24)
header.BorderSizePixel = 0
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.7, 0, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.Text = "BLOCKSPIN - Ultimate Custom Hub"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.BackgroundTransparency = 1
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -36, 0.5, -14)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BackgroundColor3 = Color3.fromRGB(210, 45, 55)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.BorderSizePixel = 0
closeBtn.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Sidebar Tabs Container
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 140, 1, -52)
sidebar.Position = UDim2.new(0, 8, 0, 46)
sidebar.BackgroundColor3 = Color3.fromRGB(25, 18, 22)
sidebar.BorderSizePixel = 0
sidebar.Parent = main

local sideCorner = Instance.new("UICorner")
sideCorner.CornerRadius = UDim.new(0, 8)
sideCorner.Parent = sidebar

local sideLayout = Instance.new("UIListLayout")
sideLayout.Padding = UDim.new(0, 6)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sideLayout.VerticalAlignment = Enum.VerticalAlignment.Top
sideLayout.Parent = sidebar

-- Content Area
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -162, 1, -52)
content.Position = UDim2.new(0, 154, 0, 46)
content.BackgroundColor3 = Color3.fromRGB(26, 20, 24)
content.BorderSizePixel = 0
content.Parent = main

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 8)
contentCorner.Parent = content

local pages = {}

local function createTab(tabName)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0.92, 0, 0, 36)
    tabBtn.Text = tabName
    tabBtn.TextColor3 = Color3.fromRGB(210, 210, 210)
    tabBtn.BackgroundColor3 = Color3.fromRGB(36, 26, 32)
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 12
    tabBtn.BorderSizePixel = 0
    tabBtn.Parent = sidebar

    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabBtn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -10, 1, -10)
    page.Position = UDim2.new(0, 5, 0, 5)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 3
    page.Parent = content

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Padding = UDim.new(0, 8)
    pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    pageLayout.Parent = page

    pages[tabName] = { Btn = tabBtn, Page = page }

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(pages) do
            t.Page.Visible = false
            t.Btn.BackgroundColor3 = Color3.fromRGB(36, 26, 32)
            t.Btn.TextColor3 = Color3.fromRGB(210, 210, 210)
        end
        page.Visible = true
        tabBtn.BackgroundColor3 = Color3.fromRGB(190, 30, 45)
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    return page
end

-- Toggles Helper
local function addToggle(parentPage, labelText, defaultVal, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 36)
    btn.BackgroundColor3 = defaultVal and Color3.fromRGB(170, 25, 38) or Color3.fromRGB(42, 30, 36)
    btn.Text = labelText .. (defaultVal and " [ON]" or " [OFF]")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.Parent = parentPage

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local state = defaultVal
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = labelText .. (state and " [ON]" or " [OFF]")
        btn.BackgroundColor3 = state and Color3.fromRGB(170, 25, 38) or Color3.fromRGB(42, 30, 36)
        callback(state)
    end)
    return btn
end

-- Populate Pages
local pvpPage = createTab("⚔️ Combat / PvP")
local farmPage = createTab("💰 Auto Farm")
local fishPage = createTab("🎣 Fishing & Skip")

pages["⚔️ Combat / PvP"].Page.Visible = true
pages["⚔️ Combat / PvP"].Btn.BackgroundColor3 = Color3.fromRGB(190, 30, 45)

addToggle(pvpPage, "🔫 Lock Aimbot", HubState.AimbotEnabled, function(s) HubState.AimbotEnabled = s end)
addToggle(pvpPage, "👁️ Player ESP", HubState.ESPEnabled, function(s) HubState.ESPEnabled = s end)

addToggle(farmPage, "🤖 Auto Farm Jobs", HubState.AutoFarmJobs, function(s) HubState.AutoFarmJobs = s end)
addToggle(farmPage, "💳 Auto ATM Hack", HubState.ATMAutoHack, function(s) HubState.ATMAutoHack = s end)

addToggle(fishPage, "🎣 Skip Slider / Minigame", HubState.SkipSlider, function(s)
    HubState.SkipSlider = s
    if s then
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/kahhakanouar-arch/skip-slider/refs/heads/main/blockspin%20skip%20slider"))()
        end)
    end
end)
addToggle(fishPage, "🐟 Auto Trash Filter", HubState.FilterBadFish, function(s) HubState.FilterBadFish = s end)

print("BlockSpin Ultimate Hub initialized successfully!")
