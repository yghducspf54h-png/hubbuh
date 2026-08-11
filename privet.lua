-- Al-Mubajjil Hub - Private Build (Ultimate Edition)
-- Developed & Customized by: المبجل (Al-Mubajjil)
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenSvc = game:GetService("TweenService")
local RunSvc = game:GetService("RunSvc")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

local SystemSettings = {
    Active = false,
    AutoSell = true,
    AutoClean = true,
    TurboFPS = false,
    NoIdle = false,
    BlankRender = false,
    ShowTrack = true,
    LineWidth = 1.2,
    LineLength = 6.5,
    LineVel = 0
}

local UserConfig = {
    Velocity = 250,
    Altitude = 2.5,
    GoalLimit = 5,
    DelayTime = 0.1,
    TargetObj = "Fake Diamond Ring",
    SellObj = "Smuggle Goods Seller",
    CleanObj = "Launder Cash"
}

local IgnoredTools = {
    ["fists"] = true,
    ["passport"] = true
}

local function CheckIgnore(name)
    return IgnoredTools[string.lower(name)] == true
end

local ActiveTransport = nil
local RouteContainer = workspace:FindFirstChild("Mubajjil_RouteFolder") or Instance.new("Folder")
RouteContainer.Name = "Mubajjil_RouteFolder"
RouteContainer.Parent = workspace

local RouteObjects = {}
local BeamReferences = {}
local RouteLoop = nil

local function PurgeRoute()
    if RouteLoop then
        RouteLoop:Disconnect()
        RouteLoop = nil
    end
    for _, obj in ipairs(RouteObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    RouteObjects = {}
    BeamReferences = {}
    RouteContainer:ClearAllChildren()
end

local function RefreshBeams()
    for _, data in ipairs(BeamReferences) do
        if data.Beam and data.Beam.Parent then
            data.Beam.Width0 = SystemSettings.LineWidth
            data.Beam.Width1 = SystemSettings.LineWidth
            data.Beam.TextureLength = SystemSettings.LineLength
            data.Beam.TextureSpeed = SystemSettings.LineVel
        end
    end
end

local function BuildRouteLines(points, startIdx)
    PurgeRoute()
    if not SystemSettings.ShowTrack or not points or startIdx > #points then return end

    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local pathNodes = {root.Position}
    for i = startIdx, #points do
        table.insert(pathNodes, points[i])
    end

    BeamReferences = {}

    for i = 1, #pathNodes - 1 do
        local p1, p2 = pathNodes[i], pathNodes[i+1]

        local part1 = Instance.new("Part", RouteContainer)
        part1.Size = Vector3.new(0.1, 0.1, 0.1)
        part1.Position = p1
        part1.Anchored = true
        part1.CanCollide = false
        part1.Transparency = 1

        local part2 = Instance.new("Part", RouteContainer)
        part2.Size = Vector3.new(0.1, 0.1, 0.1)
        part2.Position = p2
        part2.Anchored = true
        part2.CanCollide = false
        part2.Transparency = 1

        local att1 = Instance.new("Attachment", part1)
        local att2 = Instance.new("Attachment", part2)

        local lineBeam = Instance.new("Beam", RouteContainer)
        lineBeam.Attachment0 = att1
        lineBeam.Attachment1 = att2
        lineBeam.Texture = "rbxassetid://446111271"
        lineBeam.TextureMode = Enum.TextureMode.Wrap
        lineBeam.TextureLength = SystemSettings.LineLength
        lineBeam.TextureSpeed = SystemSettings.LineVel
        lineBeam.Width0 = SystemSettings.LineWidth
        lineBeam.Width1 = SystemSettings.LineWidth
        lineBeam.Transparency = NumberSequence.new(0)
        lineBeam.FaceCamera = true
        lineBeam.LightEmission = 1
        lineBeam.LightInfluence = 0

        table.insert(RouteObjects, part1)
        table.insert(RouteObjects, part2)
        table.insert(RouteObjects, lineBeam)
        table.insert(BeamReferences, {Beam = lineBeam, Index = i})
    end

    RouteLoop = RunSvc.RenderStepped:Connect(function()
        local timeTick = (tick() * 0.5) % 1
        for _, data in ipairs(BeamReferences) do
            if data.Beam and data.Beam.Parent then
                local f1 = math.sin((timeTick + (data.Index * 0.1)) * math.pi * 2) * 0.5 + 0.5
                local f2 = math.sin((timeTick + ((data.Index + 1) * 0.1)) * math.pi * 2) * 0.5 + 0.5
                local c1 = Color3.fromRGB(0, 108, 53):Lerp(Color3.fromRGB(197, 160, 89), f1)
                local c2 = Color3.fromRGB(0, 108, 53):Lerp(Color3.fromRGB(197, 160, 89), f2)

                data.Beam.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, c1),
                    ColorSequenceKeypoint.new(1, c2)
                })
            end
        end
    end)
end

local RouteBuy = {
    Vector3.new(6837.8, 17.2, 30.7),
    Vector3.new(6843.8, 17.2, 101.4),
    Vector3.new(2785.6, 17.2, 94.8),
    Vector3.new(2669.2, 17.2, 111.6),
    Vector3.new(97.4, 17.2, 112.9),
    Vector3.new(54.6, 17.2, 341.1),
    Vector3.new(-124.1, 17.2, 394.1),
    Vector3.new(-101.3, 17.2, 505.4),
    Vector3.new(13.0, 17.2, 494.9),
    Vector3.new(44.5, 17.2, 431.0),
    Vector3.new(47.6, 33.3, 563.5),
    Vector3.new(29.3, 33.3, 424.0),
    Vector3.new(42.9, 49.3, 561.7),
    Vector3.new(-80.5, 49.3, 428.5)
}

local RouteSell = {
    Vector3.new(-33.5, 49.3, 429.2),
    Vector3.new(-24.6, 53.5, 405.4),
    Vector3.new(23.4, 17.2, 348.7),
    Vector3.new(169.1, 17.2, 148.7),
    Vector3.new(2848.5, 17.2, 159.6),
    Vector3.new(6867.7, 17.2, 133.0),
    Vector3.new(6832.1, 17.4, -41.5),
    Vector3.new(6805.6, 17.4, -34.4)
}

local function LocateTarget(nameKey)
    local targetKey = string.lower(nameKey)
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local objStr = string.lower(prompt.ObjectText or "")
            local actStr = string.lower(prompt.ActionText or "")
            local parentStr = string.lower(prompt.Parent and prompt.Parent.Name or "")
            if string.find(objStr, targetKey) or string.find(actStr, targetKey) or string.find(parentStr, targetKey) then
                local container = prompt:FindFirstAncestorWhichIsA("BasePart") or prompt.Parent
                if container:IsA("BasePart") then
                    return container, prompt
                elseif container:IsA("Model") then
                    local primary = container.PrimaryPart or container:FindFirstChildWhichIsA("BasePart", true)
                    if primary then return primary, prompt end
                end
            end
        end
    end
    return nil, nil
end

local function LocateNearest(nameKey, referencePos)
    local targetKey = string.lower(nameKey)
    local bestPart, bestPrompt = nil, nil
    local minDistance = math.huge
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local objStr = string.lower(prompt.ObjectText or "")
            local actStr = string.lower(prompt.ActionText or "")
            local parentStr = string.lower(prompt.Parent and prompt.Parent.Name or "")
            if string.find(objStr, targetKey) or string.find(actStr, targetKey) or string.find(parentStr, targetKey) then
                local container = prompt:FindFirstAncestorWhichIsA("BasePart") or prompt.Parent
                if container then
                    local part = container:IsA("BasePart") and container or container.PrimaryPart or container:FindFirstChildWhichIsA("BasePart", true)
                    if part then
                        local dist = (referencePos - part.Position).Magnitude
                        if dist < minDistance then
                            minDistance = dist
                            bestPart = part
                            bestPrompt = prompt
                        end
                    end
                end
            end
        end
    end
    return bestPart, bestPrompt
end

local function ExtractVehicle(seatObj)
    if not seatObj then return nil end
    local currentObj = seatObj
    local modelFound = nil
    while currentObj and currentObj ~= workspace do
        if currentObj:IsA("Model") then modelFound = currentObj end
        currentObj = currentObj.Parent
    end
    return modelFound
end

local function LeaveVehicle()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    if humanoid and humanoid.SeatPart then
        ActiveTransport = ExtractVehicle(humanoid.SeatPart)
        if ActiveTransport then
            for _, part in ipairs(ActiveTransport:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.AssemblyLinearVelocity = Vector3.zero
                    part.AssemblyAngularVelocity = Vector3.zero
                end
            end
            local primaryPart = ActiveTransport.PrimaryPart or ActiveTransport:FindFirstChildWhichIsA("BasePart", true)
            if primaryPart then primaryPart.Anchored = true end
        end

        if root then
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end

        humanoid.Sit = false
        task.wait(0.1)

        if root and ActiveTransport then
            local primaryPart = ActiveTransport.PrimaryPart or ActiveTransport:FindFirstChildWhichIsA("BasePart", true)
            if primaryPart then
                root.CFrame = primaryPart.CFrame * CFrame.new(0, 5, 0)
            end
        end
    end
end

local function EnterVehicle()
    if not ActiveTransport or not ActiveTransport.Parent then return end
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root or not humanoid then return end

    local primaryPart = ActiveTransport.PrimaryPart or ActiveTransport:FindFirstChildWhichIsA("BasePart", true)
    if primaryPart then primaryPart.Anchored = false end

    if humanoid.SeatPart then return end

    local seat = ActiveTransport:FindFirstChildWhichIsA("VehicleSeat", true) or ActiveTransport:FindFirstChildWhichIsA("Seat", true)
    if seat then
        root.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
        task.wait(0.1)
        seat:Sit(humanoid)
        task.wait(0.2)
    end
end

local function GetClosestNodeIndex(pointsList, currentPos)
    local idx = 1
    local minVal = math.huge
    for i, pos in ipairs(pointsList) do
        local d = (Vector3.new(currentPos.X, pos.Y, currentPos.Z) - pos).Magnitude
        if d < minVal then
            minVal = d
            idx = i
        end
    end
    return idx
end

local function MoveToDestination(targetPos)
    local char = LocalPlayer.Character
    if not char then return false, false end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root or not humanoid then return false, false end

    local seat = humanoid.SeatPart
    local vehicle = ExtractVehicle(seat)
    local movingPart = (seat and vehicle) and (vehicle.PrimaryPart or seat) or root
    if not movingPart then return false, false end

    local floatingBase = Instance.new("Part", workspace)
    floatingBase.Name = "Mubajjil_Platform"
    floatingBase.Size = Vector3.new(30, 1, 30)
    floatingBase.Anchored = true
    floatingBase.CanCollide = true
    floatingBase.Transparency = 1

    local bodyVel = Instance.new("BodyVelocity", movingPart)
    bodyVel.MaxForce = Vector3.new(1e7, 1e7, 1e7)
    bodyVel.Velocity = Vector3.zero

    local bodyGyro = Instance.new("BodyGyro", movingPart)
    bodyGyro.MaxTorque = Vector3.new(1e7, 1e7, 1e7)
    bodyGyro.P = 10000
    bodyGyro.CFrame = movingPart.CFrame

    local noclipConn = RunSvc.Stepped:Connect(function()
        if not SystemSettings.Active then return end
        if movingPart and movingPart.Parent then
            floatingBase.CFrame = movingPart.CFrame * CFrame.new(0, -3.5, 0)
        end
        if LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part ~= floatingBase then part.CanCollide = false end
            end
        end
        if vehicle then
            for _, part in ipairs(vehicle:GetDescendants()) do
                if part:IsA("BasePart") and part ~= floatingBase then part.CanCollide = false end
            end
        end
    end)

    local destinationOffset = Vector3.new(targetPos.X, targetPos.Y + UserConfig.Altitude, targetPos.Z)
    local arrivedStatus = false
    local isRubberband = false
    local lastPos = movingPart.Position
    local thresholdLimit = math.clamp(UserConfig.Velocity * 0.04, 6, 15)

    local heartbeatConn = RunSvc.Heartbeat:Connect(function()
        if not SystemSettings.Active or not movingPart or not movingPart.Parent then arrivedStatus = false return end

        local curPos = movingPart.Position
        local displacement = (curPos - lastPos).Magnitude
        local distanceToDest = (destinationOffset - curPos).Magnitude

        if displacement > 45 and distanceToDest > 20 then
            isRubberband = true
            bodyVel.Velocity = Vector3.zero
            return
        end

        lastPos = curPos

        if distanceToDest <= thresholdLimit then
            arrivedStatus = true
            return
        end

        local factor = math.clamp(distanceToDest / 40, 0.25, 1)
        local curSpeed = UserConfig.Velocity * factor
        local directionVec = (destinationOffset - curPos)

        bodyVel.Velocity = directionVec.Unit * curSpeed
        bodyGyro.CFrame = CFrame.lookAt(curPos, Vector3.new(destinationOffset.X, curPos.Y, destinationOffset.Z))
    end)

    while SystemSettings.Active and not arrivedStatus and not isRubberband do
        task.wait(0.01)
    end

    if noclipConn then noclipConn:Disconnect() end
    if heartbeatConn then heartbeatConn:Disconnect() end
    bodyVel:Destroy()
    bodyGyro:Destroy()
    floatingBase:Destroy()

    if movingPart and movingPart.Parent then
        movingPart.AssemblyLinearVelocity = Vector3.zero
        movingPart.AssemblyAngularVelocity = Vector3.zero
    end

    if LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end

    return arrivedStatus, isRubberband
end

local function DriveThroughRoute(pointsList)
    local currentIndex = 1
    while SystemSettings.Active and currentIndex <= #pointsList do
        if currentIndex == 1 then EnterVehicle() end
        BuildRouteLines(pointsList, currentIndex)

        local targetCoord = pointsList[currentIndex]
        local reached, rubberband = MoveToDestination(targetCoord)

        if rubberband then
            task.wait(0.3)
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local nearestIdx = GetClosestNodeIndex(pointsList, root.Position)
                currentIndex = nearestIdx
                local safeSpot = pointsList[nearestIdx] + Vector3.new(0, UserConfig.Altitude, 0)
                local currentMover = root

                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.SeatPart then
                    local veh = ExtractVehicle(humanoid.SeatPart)
                    if veh then currentMover = veh.PrimaryPart or humanoid.SeatPart end
                end

                local tweenRestore = TweenSvc:Create(currentMover, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(safeSpot)})
                tweenRestore:Play()
                tweenRestore.Completed:Wait()
                task.wait(0.1)
            end
        elseif reached then
            currentIndex = currentIndex + 1
        end
    end
    PurgeRoute()
end

local function ExecuteInteraction(targetPart, promptObj)
    local prompt = promptObj 
        or (targetPart and targetPart:FindFirstChildOfClass("ProximityPrompt")) 
        or (targetPart and targetPart.Parent and targetPart.Parent:FindFirstChildOfClass("ProximityPrompt")) 
        or (targetPart and targetPart:FindFirstChildWhichIsA("ProximityPrompt", true))

    if prompt then
        prompt.HoldDuration = 0
        if fireproximityprompt then
            fireproximityprompt(prompt)
        else
            pcall(function()
                prompt:InputHoldBegin()
                task.wait(0.01)
                prompt:InputHoldEnd()
            end)
        end
        return true
    end

    local clickDet = (targetPart and targetPart:FindFirstChildOfClass("ClickDetector")) 
        or (targetPart and targetPart.Parent and targetPart.Parent:FindFirstChildOfClass("ClickDetector")) 
        or (targetPart and targetPart:FindFirstChildWhichIsA("ClickDetector", true))

    if clickDet and fireclickdetector then
        fireclickdetector(clickDet)
        return true
    end

    return false
end

local function CountItems(nameKey)
    local count = 0
    local key = string.lower(nameKey)
    if LocalPlayer:FindFirstChild("Backpack") then
        for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if string.find(string.lower(item.Name), key) then count = count + 1 end
        end
    end
    local char = LocalPlayer.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if string.find(string.lower(item.Name), key) then count = count + 1 end
        end
    end
    return count
end

local function CountCleanable()
    local total = 0
    if LocalPlayer:FindFirstChild("Backpack") then
        for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if item:IsA("Tool") and not CheckIgnore(item.Name) then total = total + 1 end
        end
    end
    local char = LocalPlayer.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") and not CheckIgnore(item.Name) then total = total + 1 end
        end
    end
    return total
end

local function MainOperationLoop()
    local savedPart, savedPrompt = nil, nil

    while SystemSettings.Active do
        if CountItems(UserConfig.TargetObj) < UserConfig.GoalLimit then
            if not savedPart or not savedPart.Parent then
                savedPart, savedPrompt = LocateTarget(UserConfig.TargetObj)
            end

            if savedPart then
                EnterVehicle()
                local reachedTarget, _ = MoveToDestination(savedPart.Position)
                if reachedTarget then
                    local timeoutCount = 0
                    while SystemSettings.Active and CountItems(UserConfig.TargetObj) < UserConfig.GoalLimit and timeoutCount < 40 do
                        ExecuteInteraction(savedPart, savedPrompt)
                        task.wait(0.05)
                        timeoutCount = timeoutCount + 1
                    end
                    EnterVehicle()
                end
            else
                task.wait(0.5)
            end
        end

        if not SystemSettings.Active then break end
        DriveThroughRoute(RouteBuy)
        if not SystemSettings.Active then break end

        if SystemSettings.AutoSell and CountItems(UserConfig.TargetObj) > 0 then
            local lastPos = RouteBuy[#RouteBuy]
            local sellPart, sellPrompt = LocateNearest(UserConfig.SellObj, lastPos)
            if not sellPart then sellPart, sellPrompt = LocateNearest("Smuggle", lastPos) end

            if sellPart then
                EnterVehicle()
                local reachedSell, _ = MoveToDestination(sellPart.Position)
                if reachedSell then
                    local sellTries = 0
                    while SystemSettings.Active and CountItems(UserConfig.TargetObj) > 0 and sellTries < 35 do
                        ExecuteInteraction(sellPart, sellPrompt)
                        task.wait(0.08)
                        sellTries = sellTries + 1
                    end
                    EnterVehicle()
                end
            else
                task.wait(0.5)
            end
        end

        if not SystemSettings.Active then break end
        DriveThroughRoute(RouteSell)
        if not SystemSettings.Active then break end

        if SystemSettings.AutoClean then
            local cleanPart, cleanPrompt = LocateTarget(UserConfig.CleanObj)
            if cleanPart then
                EnterVehicle()
                local reachedClean, _ = MoveToDestination(cleanPart.Position)
                if reachedClean then
                    local cleanTries = 0
                    while SystemSettings.Active and CountCleanable() > 0 and cleanTries < 40 do
                        ExecuteInteraction(cleanPart, cleanPrompt)
                        task.wait(0.08)
                        cleanTries = cleanTries + 1
                    end
                    task.wait(0.1)
                    EnterVehicle()
                end
            else
                task.wait(0.5)
            end
        end

        task.wait(0.1)
    end
    PurgeRoute()
end

-- واجهة مستخدم خاصة ومطورة | Al-Mubajjil Hub Interface
local Window = OrionLib:MakeWindow({
    Name = "🌴 Al-Mubajjil Ultimate Hub | سكريبت المبجل",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "AlMubajjilHubConfig",
    IntroText = "Welcome Al-Mubajjil (المبجل)",
    IntroEnabled = true
})

local TabInfo = Window:MakeTab({
    Name = "الإشعارات / Notes",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local TabMain = Window:MakeTab({
    Name = "التجميع / Automation",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local TabExtras = Window:MakeTab({
    Name = "التحسينات / Enhancements",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

TabInfo:AddParagraph("⚠️ تنبيه مهم / Important Notice", "تم تطوير وبرمجة هذا السكريبت بالكامل بواسطة (المبجل). جميع الحقوق محفوظة.\nThis script is fully developed by Al-Mubajjil. All rights reserved.")
TabInfo:AddParagraph("⚡ ملاحظة الأداء / Performance Note", "تأكد من استقرار اللعبة وقوة جهازك لتفادي أي مشاكل في الحركة السريعة.\nEnsure your device is capable to avoid fast-movement issues.")

TabMain:AddToggle({
    Name = "تشغيل التجميع الآلي / Auto Farm",
    Default = SystemSettings.Active,
    Callback = function(state)
        SystemSettings.Active = state
        if SystemSettings.Active then
            task.spawn(MainOperationLoop)
        else
            PurgeRoute()
        end
    end
})

TabMain:AddToggle({
    Name = "البيع التلقائي / Auto Sell",
    Default = SystemSettings.AutoSell,
    Callback = function(state)
        SystemSettings.AutoSell = state
    end
})

TabMain:AddToggle({
    Name = "غسيل الأموال التلقائي / Auto Launder",
    Default = SystemSettings.AutoClean,
    Callback = function(state)
        SystemSettings.AutoClean = state
    end
})

TabMain:AddSlider({
    Name = "سرعة الحركة / Speed",
    Min = 150,
    Max = 300,
    Default = UserConfig.Velocity,
    Color = Color3.fromRGB(0, 108, 53),
    Increment = 5,
    ValueName = "Speed",
    Callback = function(val)
        UserConfig.Velocity = val
    end
})

TabMain:AddSlider({
    Name = "ارتفاع التوين / Height",
    Min = 1,
    Max = 5,
    Default = UserConfig.Altitude,
    Color = Color3.fromRGB(197, 160, 89),
    Increment = 0.1,
    ValueName = "Studs",
    Callback = function(val)
        UserConfig.Altitude = val
    end
})

TabMain:AddSlider({
    Name = "الكمية المطلوبة / Target Count",
    Min = 1,
    Max = 5,
    Default = UserConfig.GoalLimit,
    Color = Color3.fromRGB(0, 108, 53),
    Increment = 1,
    ValueName = "Items",
    Callback = function(val)
        UserConfig.GoalLimit = val
    end
})

TabMain:AddDropdown({
    Name = "اختيار الغرض / Select Item",
    Default = UserConfig.TargetObj,
    Options = {
        "Crate Of Avacados",
        "Wagyu Beef",
        "Witches Brew",
        "Fake Designer Sneakers",
        "Fake Diamond Ring"
    },
    Callback = function(choice)
        UserConfig.TargetObj = choice
    end
})

TabExtras:AddToggle({
    Name = "تعزيز الفريمات / Boost FPS",
    Default = SystemSettings.TurboFPS,
    Callback = function(state)
        SystemSettings.TurboFPS = state
        if state then
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
        else
            Lighting.GlobalShadows = true
        end
    end
})

TabExtras:AddToggle({
    Name = "منع الخمول / Anti Idle",
    Default = SystemSettings.NoIdle,
    Callback = function(state)
        SystemSettings.NoIdle = state
        if state then
            pcall(function()
                local core = CoreGui:FindFirstChild("RobloxGui")
                if core then
                    local pauseScript = core:FindFirstChild("CoreScripts/NetworkPause")
                    if pauseScript then pauseScript:Destroy() end
                end
            end)
        end
    end
})

TabExtras:AddToggle({
    Name = "إظهار مسار الخطوط / Show Route",
    Default = SystemSettings.ShowTrack,
    Callback = function(state)
        SystemSettings.ShowTrack = state
        if not state then PurgeRoute() end
    end
})

OrionLib:Init()
