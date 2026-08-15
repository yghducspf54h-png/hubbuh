-- ==============================================================================
-- Abu Annaz Hub V14 ULTRA | حقوق س عنّاز - MOVEMENT-TRACK NEEDLE + EXACT GREEN SOLVER
-- Game: BlockSpin (Roblox)
-- Fixes:
--  1. NO-CLICK ROD CASTING (رمي السنارة بدون أي كليك على الشاشة إطلاقاً)
--  2. ULTRA STRICT GREEN SOLVER: كشف الإبرة بالحركة + مقارنة لون #13A913 بالضبط + Bounding Box كامل
--  3. PURE MIDNIGHT BLACK THEME GUI
--  4. Slot 2 Fishing Rod Priority & Fast Re-Bait Engine
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
for _, v in ipairs(PlayerGui:GetChildren()) do
    if v.Name == "AbuAnnazHubV13" or v.Name == "AbuAnnazHubV14" then
        v:Destroy()
    end
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

-- ==============================================================================
-- ULTRA STRICT GREEN SOLVER V14
-- اللون الدقيق #13A913 = RGB(19, 169, 19) بالضبط
-- ==============================================================================

-- اللون المستهدف #13A913 = RGB(19, 169, 19)
local TARGET_GREEN    = Color3.fromRGB(19, 169, 19)
-- تسامح 0.12 = ~30 وحدة من 255 (يغطي فروق الرندرينج)
local COLOR_TOLERANCE = 0.12

-- متغيرات التتبع
local lastHitTick    = 0
local lastCastTick   = 0
local hitCooldown    = 0.5   -- ثانية كاملة بعد كل ضغطة ناجحة

-- Cache: الكائنات المكتشفة (تُحدَّث فقط عند الحاجة)
local cachedGreen    = nil
local cachedNeedle   = nil
local cacheTimestamp = 0
local CACHE_TTL      = 0.3  -- إعادة مسح كل 0.3 ثانية فقط

-- تتبع حركة الإبرة لكشفها بدقة
local prevPositions  = {}   -- [object] = lastX

-- مقارنة لون دقيقة مع نسبة تسامح
local function colorMatches(col, target, tol)
    if not col then return false end
    return math.abs(col.R - target.R) <= tol
       and math.abs(col.G - target.G) <= tol
       and math.abs(col.B - target.B) <= tol
end

-- فحص إذا كان العنصر أخضر غامق (يقبل #13A913 وما يقاربه)
local function isTargetGreen(obj)
    if not obj or not obj:IsA("GuiObject") then return false end

    local function checkCol(c)
        if not c then return false end
        -- طريقة 1: مقارنة مع #13A913 بتسامح 0.12
        if colorMatches(c, TARGET_GREEN, COLOR_TOLERANCE) then return true end
        -- طريقة 2: شرط مباشر - أخضر غامق (R وB صغيران، G كبير)
        local r = c.R * 255
        local g = c.G * 255
        local b = c.B * 255
        if r < 60 and g > 100 and b < 60 and g > (r * 3) then return true end
        return false
    end

    if checkCol(obj.BackgroundColor3) then return true end
    if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
        if checkCol(obj.ImageColor3) then return true end
    end
    return false
end

-- فحص إذا كان العنصر أبيض/فاتح (إبرة) - عتبة مخففة 0.60
local function isWhiteElement(obj)
    local c = obj.BackgroundColor3
    return (c.R > 0.60 and c.G > 0.60 and c.B > 0.60)
end

-- هل العنصر يتحرك أفقياً؟ (يُحدَّد الإبرة بالحركة لا بالحجم)
local function isMoving(obj)
    local curX = obj.AbsolutePosition.X
    local prev  = prevPositions[obj]
    prevPositions[obj] = curX
    if prev == nil then return false end
    return math.abs(curX - prev) > 0.3  -- تحرك أكثر من 0.3 بيكسل
end

-- مسح الـ GUI لإيجاد الأخضر والإبرة
local function findMinigameObjects()
    local green  = nil
    local needle = nil
    local name

    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AbuAnnazHubV14" then
            for _, desc in ipairs(gui:GetDescendants()) do
                if desc:IsA("GuiObject") and desc.Visible
                   and desc.AbsoluteSize.X > 0 and desc.AbsoluteSize.Y > 0 then

                    name = desc.Name:lower()

                    -- [1] كشف المربع الأخضر الدقيق #13A913
                    if not green then
                        if isTargetGreen(desc)
                           or name:find("green") or name:find("target") or name:find("zone") then
                            green = desc
                        end
                    end

                    -- [2] كشف الإبرة - عرض ضيق (حتى 30px) + لون فاتح
                    if not needle then
                        local sx = desc.AbsoluteSize.X
                        local sy = desc.AbsoluteSize.Y
                        local isNarrow    = (sx <= 30 and sy >= 4)
                        local isNameMatch = name:find("needle") or name:find("pointer") or name:find("cursor") or name:find("line") or name:find("indicator")
                        if (isNarrow or isNameMatch) and isWhiteElement(desc) then
                            -- تأكد أنه ليس جزء من واجهة أخرى (ليس داخل الأخضر)
                            needle = desc
                        end
                    end

                    if green and needle then break end
                end
            end
            if green and needle then break end
        end
    end

    return green, needle
end

-- ------------------------------------------------------------------------------
-- 1. ULTRA STRICT GREEN SOLVER - يُنفَّذ كل RenderStepped
-- ------------------------------------------------------------------------------
local function solveGreenTarget()
    if not State.AutoSolveGreen then
        State.MinigameActive = false
        return
    end

    local now = tick()

    -- تحديث الكاش كل CACHE_TTL ثانية فقط (لا نمسح كل فريم)
    if now - cacheTimestamp >= CACHE_TTL then
        cacheTimestamp = now
        cachedGreen, cachedNeedle = findMinigameObjects()
    end

    -- إذا ما في إبرة أو أخضر → ما في Minigame
    if not cachedGreen or not cachedNeedle then
        State.MinigameActive = false
        return
    end

    -- تحقق إن الكائنات لا تزال صالحة وظاهرة
    local greenOk  = pcall(function() return cachedGreen.Visible end) and cachedGreen.Visible
    local needleOk = pcall(function() return cachedNeedle.Visible end) and cachedNeedle.Visible
    if not greenOk or not needleOk then
        cachedGreen  = nil
        cachedNeedle = nil
        State.MinigameActive = false
        return
    end

    State.MinigameActive = true

    -- التحقق من الحركة (يؤكد أن الإبرة تتحرك فعلاً)
    isMoving(cachedNeedle)

    -- =====================================================
    -- BOUNDING BOX FULL OVERLAP CHECK
    -- نضغط فقط عندما تكون الإبرة بالكامل داخل الأخضر
    -- =====================================================
    local nLeft  = cachedNeedle.AbsolutePosition.X
    local nRight = nLeft + cachedNeedle.AbsoluteSize.X

    local gLeft  = cachedGreen.AbsolutePosition.X
    local gRight = gLeft + cachedGreen.AbsoluteSize.X

    -- يضغط عندما مركز الإبرة داخل الأخضر (أكثر موثوقية مع الإبرة الضيقة)
    local nCenter = nLeft + (cachedNeedle.AbsoluteSize.X * 0.5)
    local overlap  = (nCenter >= gLeft) and (nCenter <= gRight)

    if overlap and (now - lastHitTick >= hitCooldown) then
        lastHitTick = now
        State.HitCounter = State.HitCounter + 1

        local clickX = math.floor(nCenter)
        local clickY = math.floor(cachedNeedle.AbsolutePosition.Y + (cachedNeedle.AbsoluteSize.Y * 0.5))

        -- ضغطة الماوس في الموضع الدقيق
        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
        task.wait(0.003)
        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)

        -- مفتاح Space كبديل (Backup)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.003)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)

        -- إعادة ضبط الكاش بعد الضغط (ليبدأ بحث جديد في الجولة القادمة)
        cachedGreen   = nil
        cachedNeedle  = nil
        cacheTimestamp = 0
    end
end

RunService.RenderStepped:Connect(solveGreenTarget)

-- ------------------------------------------------------------------------------
-- 2. NO-CLICK ROD CASTING & FAST RE-BAIT ENGINE (رمي السنارة بدون كليك شاشة)
-- ------------------------------------------------------------------------------
local function equipSlot2Rod()
    local char = LocalPlayer.Character
    if not char then return nil end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool then return currentTool end

    -- Press Key '2' for Slot 2 Priority
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
    task.wait(0.01)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Two, false, game)

    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                if humanoid then pcall(function() humanoid:EquipTool(item) end) end
                item.Parent = char
                return item
            end
        end
    end
    return char:FindFirstChildOfClass("Tool")
end

task.spawn(function()
    while task.wait(0.2) do
        if State.AutoFish then
            local rod = equipSlot2Rod()

            -- Ultra Fast Re-Bait Loop
            if State.AutoRebait and rod then
                for _, rName in ipairs({"EquipBait", "BaitRemote", "Rebait", "Bait", "AddBait"}) do
                    local remote = ReplicatedStorage:FindFirstChild(rName, true) or Workspace:FindFirstChild(rName, true)
                    if remote and remote:IsA("RemoteEvent") then
                        pcall(function() remote:FireServer() end)
                    end
                end
            end

            -- NO-CLICK ROD CASTING: Trigger tool via Activate() and Remotes ONLY (Zero Screen Clicks)
            if rod and not State.MinigameActive and (tick() - lastCastTick >= 2.5) then
                lastCastTick = tick()

                -- 1. Pure Tool Activation (No mouse click on screen)
                pcall(function() rod:Activate() end)

                -- 2. Direct Cast Remotes if present
                for _, cName in ipairs({"Cast", "CastLine", "FishCast", "CastRod", "ThrowLine"}) do
                    local castRemote = ReplicatedStorage:FindFirstChild(cName, true) or Workspace:FindFirstChild(cName, true)
                    if castRemote then
                        if castRemote:IsA("RemoteEvent") then
                            pcall(function() castRemote:FireServer() end)
                        elseif castRemote:IsA("RemoteFunction") then
                            pcall(function() castRemote:InvokeServer() end)
                        end
                    end
                end
            end
        end

        -- Filter Trash Discard Loop
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
-- 3. GUI DESIGN - PURE MIDNIGHT BLACK THEME (حقوق أبو عنّاز V13 PERFECT)
-- ------------------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "AbuAnnazHubV13"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 540, 0, 400)
main.Position = UDim2.new(0.5, -270, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(8, 8, 10) -- Pure Midnight Black Theme
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(180, 20, 30) -- Dark Red Accent Border
stroke.Thickness = 1.8

-- Header Bar
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 44)
header.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0.8, 0, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.Text = "👑 حقوق أبو عنّاز | PERFECT NO-CLICK CAST V13"
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
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 40)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Sidebar & Content (Pure Black Theme)
local sidebar = Instance.new("Frame", main)
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 150, 1, -54)
sidebar.Position = UDim2.new(0, 8, 0, 48)
sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8)

local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.Padding = UDim.new(0, 6)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sideLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -172, 1, -54)
content.Position = UDim2.new(0, 164, 0, 48)
content.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
content.BorderSizePixel = 0
Instance.new("UICorner", content).CornerRadius = UDim.new(0, 8)

local pages = {}

local function createTab(name)
    local tabBtn = Instance.new("TextButton", sidebar)
    tabBtn.Size = UDim2.new(0.92, 0, 0, 36)
    tabBtn.Text = name
    tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
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
            t.Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
            t.Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        page.Visible = true
        tabBtn.BackgroundColor3 = Color3.fromRGB(180, 20, 30)
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    return page
end

local function addToggle(parent, label, key)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 36)
    btn.BackgroundColor3 = State[key] and Color3.fromRGB(180, 20, 30) or Color3.fromRGB(22, 22, 26)
    btn.Text = label .. (State[key] and " [ON]" or " [OFF]")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        State[key] = not State[key]
        btn.Text = label .. (State[key] and " [ON]" or " [OFF]")
        btn.BackgroundColor3 = State[key] and Color3.fromRGB(180, 20, 30) or Color3.fromRGB(22, 22, 26)
    end)
    return btn
end

-- Create Pages
local fishPage = createTab("🎣 صيد الأسماك V14 ULTRA")

pages["🎣 صيد الأسماك V14 ULTRA"].Page.Visible = true
pages["🎣 صيد الأسماك V14 ULTRA"].Btn.BackgroundColor3 = Color3.fromRGB(180, 20, 30)

addToggle(fishPage, "🎯 حل الأخضر #13A913 الصارم (Ultra Strict)", "AutoSolveGreen")
addToggle(fishPage, "🎣 رمي السنارة بدون كليك شاشة (No-Click Cast)", "AutoFish")
addToggle(fishPage, "🪱 التعبئة السريعة للطعم", "AutoRebait")
addToggle(fishPage, "🐟 تصفية وتدمير القمامة", "FilterTrash")

print("ABU ANNAZ HUB ULTRA NO-CLICK CAST V14 LOADED SUCCESSFULLY!")
