-- Abu Annaz Hub V15 | BlockSpin Auto Fish - Built from scratch after research
-- Game: BlockSpin (Roblox) | حقوق أبو عنّاز
-- ==============================================================================
-- How BlockSpin Fishing Works:
--   1. Equip fishing rod (Tool in Character)
--   2. Click to cast line into water
--   3. Wait for fish to bite
--   4. Minigame: Green Zone + White moving needle
--   5. Click when needle center is inside Green Zone
-- ==============================================================================

local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local VIM             = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    repeat task.wait(0.1) until Players.LocalPlayer
    LocalPlayer = Players.LocalPlayer
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 30)
if not PlayerGui then warn("[V15] PlayerGui not found!") return end

for _, v in ipairs(PlayerGui:GetChildren()) do
    if v.Name:find("AbuAnnazHub") then v:Destroy() end
end

-- ============================================================
-- STATE
-- ============================================================
local State = {
    AutoFish       = true,
    AutoMinigame   = true,
    AutoRebait     = true,
    DebugMode      = true,
    MinigameActive = false,
    HitCount       = 0,
    CastCount      = 0,
}

-- ============================================================
-- HELPERS
-- ============================================================
local function log(msg)
    if State.DebugMode then print("[V15] " .. tostring(msg)) end
end

local function isDarkGreen(c)
    if not c then return false end
    local r, g, b = c.R * 255, c.G * 255, c.B * 255
    return g > 80 and r < 80 and b < 80 and g > r * 2 and g > b * 2
end

local function isLight(c)
    if not c then return false end
    return c.R > 0.55 and c.G > 0.55 and c.B > 0.55
end

local function isVisible(obj)
    local ok, vis = pcall(function() return obj.Visible end)
    if not ok or not vis then return false end
    local ok2, sz = pcall(function() return obj.AbsoluteSize end)
    if not ok2 then return false end
    return sz.X > 0 and sz.Y > 0
end

-- ============================================================
-- MINIGAME SCANNER
-- ============================================================
local cachedGreen   = nil
local cachedNeedle  = nil
local cacheTime     = 0
local CACHE_REFRESH = 0.2

local function scanAllGui()
    local fg = nil
    local fn = nil

    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if not (gui:IsA("ScreenGui") and gui.Enabled) then continue end
        if gui.Name:find("AbuAnnazHub") then continue end

        for _, obj in ipairs(gui:GetDescendants()) do
            if not (obj:IsA("GuiObject") and isVisible(obj)) then continue end
            local bg   = obj.BackgroundColor3
            local name = obj.Name:lower()
            local sx   = obj.AbsoluteSize.X
            local sy   = obj.AbsoluteSize.Y

            if not fg then
                if isDarkGreen(bg) then
                    fg = obj
                    log(("GREEN '%s' RGB(%d,%d,%d) %.0fx%.0f"):format(
                        obj.Name, bg.R*255, bg.G*255, bg.B*255, sx, sy))
                elseif name:find("green") or name:find("target") or name:find("zone")
                    or name:find("good") or name:find("hit") then
                    fg = obj
                    log("GREEN name: '" .. obj.Name .. "'")
                end
            end

            if not fn then
                local narrow  = sx <= 35 and sy >= 3 and sy <= 300
                local named   = name:find("needle") or name:find("pointer")
                             or name:find("cursor") or name:find("indicator")
                             or name:find("slider") or name:find("marker")
                             or name:find("bar") or name:find("arrow")
                if (narrow or named) and isLight(bg) then
                    fn = obj
                    log(("NEEDLE '%s' RGB(%d,%d,%d) %.0fx%.0f"):format(
                        obj.Name, bg.R*255, bg.G*255, bg.B*255, sx, sy))
                end
            end

            if fg and fn then break end
        end
        if fg and fn then break end
    end

    return fg, fn
end

-- ============================================================
-- MINIGAME SOLVER
-- ============================================================
local lastHit      = 0
local HIT_COOLDOWN = 0.4

local function solveMinigame()
    if not State.AutoMinigame then return end
    local now = tick()

    if now - cacheTime >= CACHE_REFRESH then
        cacheTime = now
        cachedGreen, cachedNeedle = scanAllGui()
    end

    if not cachedGreen or not cachedNeedle then
        if State.MinigameActive then
            log("Minigame ended")
            State.MinigameActive = false
        end
        return
    end

    if not isVisible(cachedGreen) or not isVisible(cachedNeedle) then
        cachedGreen = nil; cachedNeedle = nil
        State.MinigameActive = false
        return
    end

    if not State.MinigameActive then
        log("Minigame started!")
        State.MinigameActive = true
    end

    local nPos    = cachedNeedle.AbsolutePosition
    local nSize   = cachedNeedle.AbsoluteSize
    local gPos    = cachedGreen.AbsolutePosition
    local gSize   = cachedGreen.AbsoluteSize
    local nCenter = nPos.X + nSize.X * 0.5
    local gLeft   = gPos.X
    local gRight  = gPos.X + gSize.X

    if nCenter >= gLeft and nCenter <= gRight and now - lastHit >= HIT_COOLDOWN then
        lastHit = now
        State.HitCount = State.HitCount + 1
        local cx = math.floor(nCenter)
        local cy = math.floor(nPos.Y + nSize.Y * 0.5)
        log(("HIT #%d X=%.0f green=%.0f-%.0f"):format(State.HitCount, nCenter, gLeft, gRight))

        VIM:SendMouseButtonEvent(cx, cy, 0, true,  game, 1)
        task.wait(0.005)
        VIM:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
        VIM:SendKeyEvent(true,  Enum.KeyCode.Space, false, game)
        task.wait(0.005)
        VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)

        cachedGreen = nil; cachedNeedle = nil; cacheTime = 0
    end
end

RunService.RenderStepped:Connect(solveMinigame)

-- ============================================================
-- AUTO CAST
-- ============================================================
local lastCast   = 0
local CAST_DELAY = 3.5

local function equipRod()
    local char = LocalPlayer.Character
    if not char then return nil end
    local inHand = char:FindFirstChildOfClass("Tool")
    if inHand then return inHand end
    local bp  = LocalPlayer:FindFirstChildOfClass("Backpack")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not bp then return nil end
    for _, item in ipairs(bp:GetChildren()) do
        if item:IsA("Tool") then
            if hum then pcall(function() hum:EquipTool(item) end) end
            task.wait(0.15)
            return item
        end
    end
    return nil
end

local function castRod()
    if tick() - lastCast < CAST_DELAY then return end
    if State.MinigameActive then return end
    local rod = equipRod()
    if not rod then log("No rod found") return end
    lastCast = tick()
    State.CastCount = State.CastCount + 1
    log(("CAST #%d rod=%s"):format(State.CastCount, rod.Name))

    pcall(function() rod:Activate() end)
    task.wait(0.05)

    local cam = workspace.CurrentCamera
    local vp  = cam.ViewportSize
    VIM:SendMouseButtonEvent(math.floor(vp.X*0.5), math.floor(vp.Y*0.5), 0, true,  game, 1)
    task.wait(0.09)
    VIM:SendMouseButtonEvent(math.floor(vp.X*0.5), math.floor(vp.Y*0.5), 0, false, game, 1)

    for _, r in ipairs(ReplicatedStorage:GetDescendants()) do
        local n = r.Name:lower()
        if r:IsA("RemoteEvent") and (n:find("cast") or n:find("fish") or n:find("throw")) then
            pcall(function() r:FireServer() end)
            log("Remote: " .. r.Name)
        end
    end
end

local lastRebait = 0
local function tryRebait()
    if not State.AutoRebait or tick() - lastRebait < 6 then return end
    lastRebait = tick()
    for _, r in ipairs(ReplicatedStorage:GetDescendants()) do
        local n = r.Name:lower()
        if r:IsA("RemoteEvent") and (n:find("bait") or n:find("equip")) then
            pcall(function() r:FireServer() end)
        end
    end
end

task.spawn(function()
    log("V15 STARTED - check Output for debug info")
    while task.wait(0.5) do
        if State.AutoFish then castRod() end
        tryRebait()
    end
end)

-- ============================================================
-- GUI
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "AbuAnnazHubV15"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = PlayerGui

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 290, 0, 310)
main.Position = UDim2.new(0, 16, 0.5, -155)
main.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
local brd = Instance.new("UIStroke", main)
brd.Color = Color3.fromRGB(180, 20, 30)
brd.Thickness = 1.5

local hdr = Instance.new("Frame", main)
hdr.Size = UDim2.new(1, 0, 0, 40)
hdr.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
hdr.BorderSizePixel = 0
Instance.new("UICorner", hdr).CornerRadius = UDim.new(0, 10)

local titleLbl = Instance.new("TextLabel", hdr)
titleLbl.Size = UDim2.new(1, -38, 1, 0)
titleLbl.Position = UDim2.new(0, 12, 0, 0)
titleLbl.Text = "👑 أبو عنّاز | Auto Fish V15"
titleLbl.TextColor3 = Color3.fromRGB(255, 215, 0)
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextSize = 13
titleLbl.BackgroundTransparency = 1
titleLbl.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", hdr)
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -28, 0.5, -11)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 40)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 11
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

local body = Instance.new("Frame", main)
body.Size = UDim2.new(1, -14, 1, -52)
body.Position = UDim2.new(0, 7, 0, 44)
body.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", body)
layout.Padding = UDim.new(0, 6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local statsLbl = Instance.new("TextLabel", body)
statsLbl.Size = UDim2.new(1, 0, 0, 30)
statsLbl.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
statsLbl.TextColor3 = Color3.fromRGB(150, 210, 255)
statsLbl.Font = Enum.Font.Gotham
statsLbl.TextSize = 11
statsLbl.Text = "Starting..."
statsLbl.BorderSizePixel = 0
Instance.new("UICorner", statsLbl).CornerRadius = UDim.new(0, 6)

local function addToggle(txt, key)
    local btn = Instance.new("TextButton", body)
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    local function rf()
        btn.BackgroundColor3 = State[key] and Color3.fromRGB(20,120,20) or Color3.fromRGB(25,25,30)
        btn.Text = txt .. (State[key] and "  ON" or "  OFF")
    end
    rf()
    btn.MouseButton1Click:Connect(function() State[key] = not State[key]; rf() end)
end

addToggle("🎣 Auto Cast", "AutoFish")
addToggle("🟢 Minigame Solver", "AutoMinigame")
addToggle("🪱 Auto Rebait", "AutoRebait")
addToggle("🔍 Debug (check Output)", "DebugMode")

task.spawn(function()
    while task.wait(1) do
        if not gui.Parent then break end
        local s = State.MinigameActive and "MINIGAME!" or "waiting..."
        statsLbl.Text = ("Cast:%d Hit:%d | %s"):format(State.CastCount, State.HitCount, s)
    end
end)

print("Abu Annaz V15 loaded! Turn on DebugMode and check Output tab.")
"""

with open("blockspin_ultimate_hub.lua", "w", encoding="utf-8") as f:
    f.write(content)

print("Done! File written successfully.")
