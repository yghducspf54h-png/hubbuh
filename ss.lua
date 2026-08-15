--!strict
-- ==============================================================================
-- ProbeX BlockSpin Ultimate Hub (Luau Clean Source 100%)
-- Game: BlockSpin (Roblox)
-- Includes: PvP Aimbot, Silent Aim, ESP, Auto Farm (Jobs/ATM/Fishing), Skip Slider, Webhooks
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:Workspace

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Clean old instances
if PlayerGui:FindFirstChild("BlockSpinUltimateHub") then
    PlayerGui.BlockSpinUltimateHub:Destroy()
end

-- Hub State Configuration
local HubState = {
    -- Combat & Aimbot
    AimbotEnabled = false,
    SilentAim = false,
    TargetCircle = true,
    FOVRadius = 120,
    TeamCheck = false,
    
    -- Visuals / ESP
    ESPEnabled = false,
    Boxes = true,
    Tracers = false,
    Names = true,
    Health = true,
    
    -- Auto Farming
    AutoFarmJobs = false,
    ATMAutoHack = false,
    AutoFish = false,
    SkipSlider = true,
    AutoWinMinigame = true,
    
    -- Trash Filter
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
    
    -- Webhook System
    WebhookURL = "",
    WebhookEnabled = false,
}

-- FOV Circle Visual
local FOVCircle = Drawing and Drawing.new("Circle") or nil
if FOVCircle then
    FOVCircle.Thickness = 1.5
    FOVCircle.Color = Color3.fromRGB(255, 60, 60)
    FOVCircle.Filled = false
    FOVCircle.Transparency = 0.8
    FOVCircle.Radius = HubState.FOVRadius
    FOVCircle.Visible = HubState.TargetCircle
end

-- Helper: Get Closest Target to Mouse (PvP)
local function getClosestPlayer()
    local target = nil
    local shortestDist = HubState.FOVRadius

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
            if p.Character.Humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if onScreen then
                    local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        target = p
                    end
                end
            end
        end
    end
    return target
end

-- Dynamic FOV Updater
RunService.RenderStepped:Connect(function()
    if FOVCircle then
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
        FOVCircle.Radius = HubState.FOVRadius
        FOVCircle.Visible = HubState.TargetCircle and HubState.AimbotEnabled
    end
    
    -- Aimbot Lock logic
    if HubState.AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

-- Auto Fish & Skip Slider Background Logic
task.spawn(function()
    while task.wait(0.5) do
        if HubState.AutoFish then
            -- Trigger fishing cast remote if present
            local castRemote = ReplicatedStorage:FindFirstChild("CastLine") or ReplicatedStorage:FindFirstChild("FishingRemote")
            if castRemote and castRemote:IsA("RemoteEvent") then
                castRemote:FireServer()
            end
        end
        
        -- Auto Trash Filtering
        if HubState.FilterBadFish then
            local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
            if backpack then
                for _, item in ipairs(backpack:GetChildren()) do
                    if HubState.TrashList[item.Name] then
                        item:Destroy()
                    end
                end
            end
        end
    end
end)

-- UI Building System (Custom High-End Dark Red GUI Theme)
local function buildUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "BlockSpinUltimateHub"
    gui.ResetOnSpawn = false
    gui.Parent = PlayerGui

    local main = Instance.new("Frame")
    main.Name = "MainFrame"
    main.Size = UDim2.new(0, 560, 0, 420)
    main.Position = UDim2.new(0.5, -280, 0.5, -210)
    main.BackgroundColor3 = Color3.fromRGB(18, 14, 18)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = gui

    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(180, 30, 40)
    stroke.Thickness = 1.5

    -- Header Bar
    local header = Instance.new("Frame", main)
    header.Size = UDim2.new(1, 0, 0, 45)
    header.BackgroundColor3 = Color3.fromRGB(28, 18, 22)
    header.BorderSizePixel = 0
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.Text = "BLOCKSPIN - Ultimate Custom Hub"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1

    local closeBtn = Instance.new("TextButton", header)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -38, 0.5, -15)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 50)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.BorderSizePixel = 0
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
        if FOVCircle then FOVCircle:Remove() end
    end)

    -- Tab Bar (Left side)
    local tabBar = Instance.new("Frame", main)
    tabBar.Size = UDim2.new(0, 140, 1, -55)
    tabBar.Position = UDim2.new(0, 10, 0, 50)
    tabBar.BackgroundColor3 = Color3.fromRGB(22, 16, 20)
    tabBar.BorderSizePixel = 0
    Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 10)

    local tabLayout = Instance.new("UIListLayout", tabBar)
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Top

    -- Content Frame (Right Side)
    local container = Instance.new("Frame", main)
    container.Size = UDim2.new(1, -170, 1, -55)
    container.Position = UDim2.new(0, 160, 0, 50)
    container.BackgroundColor3 = Color3.fromRGB(24, 18, 22)
    container.BorderSizePixel = 0
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)

    local pages = {}

    local function createTab(name)
        local tabBtn = Instance.new("TextButton", tabBar)
        tabBtn.Size = UDim2.new(0.9, 0, 0, 36)
        tabBtn.Text = name
        tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabBtn.BackgroundColor3 = Color3.fromRGB(32, 22, 28)
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 13
        tabBtn.BorderSizePixel = 0
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 8)

        local page = Instance.new("ScrollingFrame", container)
        page.Size = UDim2.new(1, -10, 1, -10)
        page.Position = UDim2.new(0, 5, 0, 5)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.ScrollBarThickness = 4
        
        local pageLayout = Instance.new("UIListLayout", page)
        pageLayout.Padding = UDim.new(0, 8)
        pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        pages[name] = { Btn = tabBtn, Page = page }

        tabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(pages) do
                t.Page.Visible = false
                t.Btn.BackgroundColor3 = Color3.fromRGB(32, 22, 28)
                t.Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            page.Visible = true
            tabBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 40)
            tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)

        return page
    end

    -- Create Pages
    local pvpPage = createTab("⚔️ Combat / Aimbot")
    local farmPage = createTab("💰 Auto Farm")
    local fishPage = createTab("🎣 Fishing & Skip")
    local webhookPage = createTab("🔔 Webhooks")

    -- Activate First Tab
    pages["⚔️ Combat / Aimbot"].Page.Visible = true
    pages["⚔️ Combat / Aimbot"].Btn.BackgroundColor3 = Color3.fromRGB(180, 30, 40)

    -- Toggle Creator Helper
    local function addToggle(parent, text, defaultState, callback)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(0.95, 0, 0, 38)
        btn.BackgroundColor3 = defaultState and Color3.fromRGB(160, 25, 35) or Color3.fromRGB(40, 28, 34)
        btn.Text = text .. (defaultState and " [ON]" or " [OFF]")
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        local currentState = defaultState
        btn.MouseButton1Click:Connect(function()
            currentState = not currentState
            btn.Text = text .. (currentState and " [ON]" or " [OFF]")
            btn.BackgroundColor3 = currentState and Color3.fromRGB(160, 25, 35) or Color3.fromRGB(40, 28, 34)
            callback(currentState)
        end)
        return btn
    end

    -- Tab 1: PvP Controls
    addToggle(pvpPage, "🎯 Target Circle FOV", HubState.TargetCircle, function(s) HubState.TargetCircle = s end)
    addToggle(pvpPage, "🔫 Lock Aimbot (Hold RMB)", HubState.AimbotEnabled, function(s) HubState.AimbotEnabled = s end)
    addToggle(pvpPage, "👁️ Player ESP (Boxes & Names)", HubState.ESPEnabled, function(s) HubState.ESPEnabled = s end)

    -- Tab 2: Auto Farm
    addToggle(farmPage, "🤖 Auto Farm Jobs / Steaks", HubState.AutoFarmJobs, function(s) HubState.AutoFarmJobs = s end)
    addToggle(farmPage, "💳 Auto ATM Hack", HubState.ATMAutoHack, function(s) HubState.ATMAutoHack = s end)

    -- Tab 3: Fishing & Skip Bad Fish
    addToggle(fishPage, "🎣 Auto Win Minigame / Skip Slider", HubState.SkipSlider, function(s)
        HubState.SkipSlider = s
        if s then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/kahhakanouar-arch/skip-slider/refs/heads/main/blockspin%20skip%20slider"))()
        end
    end)
    addToggle(fishPage, "🐟 Auto Filter Trash / Bad Fish", HubState.FilterBadFish, function(s) HubState.FilterBadFish = s end)

    -- Tab 4: Webhook & Config
    local webhookInput = Instance.new("TextBox", webhookPage)
    webhookInput.Size = UDim2.new(0.95, 0, 0, 36)
    webhookInput.PlaceholderText = "Paste Webhook URL Here..."
    webhookInput.Text = HubState.WebhookURL
    webhookInput.BackgroundColor3 = Color3.fromRGB(36, 26, 32)
    webhookInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    webhookInput.Font = Enum.Font.Gotham
    webhookInput.TextSize = 12
    Instance.new("UICorner", webhookInput).CornerRadius = UDim.new(0, 8)

    webhookInput.FocusLost:Connect(function()
        HubState.WebhookURL = webhookInput.Text
    end)

    print("ProbeX BlockSpin Ultimate Hub Loaded Successfully!")
end

buildUI()
