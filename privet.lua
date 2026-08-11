local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer

local FarmEngine = {
    Running = false,
    CurrentTarget = nil,
    TargetMeta = {},        
    State = "Searching",    -- Searching | Moving | Repathing | Interacting
    Metrics = {
        Success = 0,
        Failed = {
            Pathfinding = 0,
            Movement = 0,
            Interaction = 0,
            Verification = 0
        }
    },
    TargetCache = {},       
    GlobalConnections = {}, 
    InitialValues = {}
}

local function CaptureState(statName)
    if not statName then return {} end
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local stat = leaderstats:FindFirstChild(statName)
        if stat and (stat:IsA("IntValue") or stat:IsA("NumberValue")) then
            return { [statName] = stat.Value }
        end
    end
    return {}
end

local function CleanPromptConnection(meta)
    if meta and meta.PromptConn then
        meta.PromptConn:Disconnect()
        meta.PromptConn = nil
    end
end

local function ClearTargetMeta(obj)
    local meta = FarmEngine.TargetMeta[obj]
    if meta then
        CleanPromptConnection(meta)
        if meta.BaseConn then
            meta.BaseConn:Disconnect()
            meta.BaseConn = nil
        end
        if meta.DescendantRemoveConn then
            meta.DescendantRemoveConn:Disconnect()
            meta.DescendantRemoveConn = nil
        end
        FarmEngine.TargetMeta[obj] = nil
    end
end

local function AttachTargetListeners(obj, profile)
    local meta = FarmEngine.TargetMeta[obj]
    if not meta then
        meta = {
            Retries = 0, 
            BlacklistUntil = nil, 
            PromptConn = nil,
            BaseConn = nil,
            DescendantRemoveConn = nil,
            MoveStartTime = 0,
            JourneyStartTime = 0,
            LastPos = Vector3.new(),
            CurrentPath = nil,
            WaypointIndex = 1,
            PathRetries = 0,
            LastTargetPos = Vector3.new(),
            TriedRecomputingOnStuck = false,
            FallbackCount = 0,
            WaypointTime = 0
        }
        FarmEngine.TargetMeta[obj] = meta
    end

    local function evaluatePrompt()
        local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
        CleanPromptConnection(meta)
        
        if prompt and profile.Validator(obj) and prompt.Enabled then
            FarmEngine.TargetCache[obj] = true
            
            meta.PromptConn = prompt:GetPropertyChangedSignal("Enabled"):Connect(function()
                if not prompt.Enabled or not prompt.Parent then
                    FarmEngine.TargetCache[obj] = nil
                    CleanPromptConnection(meta)
                    if FarmEngine.CurrentTarget == obj then
                        FarmEngine.CurrentTarget = nil
                        FarmEngine.State = "Searching"
                    end
                else
                    if profile.Validator(obj) then
                        FarmEngine.TargetCache[obj] = true
                    end
                end
            end)
        else
            FarmEngine.TargetCache[obj] = nil
        end
    end

    evaluatePrompt()

    if not meta.BaseConn then
        meta.BaseConn = obj.DescendantAdded:Connect(function(child)
            if child:IsA("ProximityPrompt") then
                evaluatePrompt()
            end
        end)
    end

    if not meta.DescendantRemoveConn then
        meta.DescendantRemoveConn = obj.DescendantRemoving:Connect(function(child)
            if child:IsA("ProximityPrompt") then
                task.defer(evaluatePrompt)
            end
        end)
    end
end

local function SetupCacheListeners(profile)
    table.clear(FarmEngine.TargetCache)
    for obj, _ in pairs(FarmEngine.TargetMeta) do
        ClearTargetMeta(obj)
    end
    table.clear(FarmEngine.TargetMeta)
    
    local function evaluateAndAdd(obj)
        if obj:IsA("BasePart") or obj:IsA("Model") then
            if profile.Validator(obj) then
                AttachTargetListeners(obj, profile)
            end
        end
    end

    for _, obj in pairs(workspace:GetDescendants()) do
        evaluateAndAdd(obj)
    end

    local addConn = workspace.DescendantAdded:Connect(function(obj)
        evaluateAndAdd(obj)
    end)
    
    local removeConn = workspace.DescendantRemoving:Connect(function(obj)
        if obj:IsA("ProximityPrompt") then
            local parentObj = obj.Parent
            while parentObj and parentObj ~= workspace do
                if FarmEngine.TargetCache[parentObj] then
                    FarmEngine.TargetCache[parentObj] = nil
                    local meta = FarmEngine.TargetMeta[parentObj]
                    if meta then CleanPromptConnection(meta) end
                    if FarmEngine.CurrentTarget == parentObj then
                        FarmEngine.CurrentTarget = nil
                        FarmEngine.State = "Searching"
                    end
                    break
                end
                parentObj = parentObj.Parent
            end
        elseif FarmEngine.TargetCache[obj] or FarmEngine.TargetMeta[obj] then
            FarmEngine.TargetCache[obj] = nil
            ClearTargetMeta(obj)
            if FarmEngine.CurrentTarget == obj then
                FarmEngine.CurrentTarget = nil
                FarmEngine.State = "Searching"
            end
        end
    end)
    
    table.insert(FarmEngine.GlobalConnections, addConn)
    table.insert(FarmEngine.GlobalConnections, removeConn)
end

local function ComputePathSafe(pathObj, startPos, targetPos, meta)
    meta.CurrentPath = nil
    local success, err = pcall(function()
        pathObj:ComputeAsync(startPos, targetPos)
    end)
    
    if success and pathObj.Status == Enum.PathStatus.Success then
        meta.CurrentPath = pathObj:GetWaypoints()
        meta.WaypointIndex = 2
        meta.PathRetries = 0
        return true, "Success"
    else
        meta.PathRetries = (meta.PathRetries or 0) + 1
        return false, err or tostring(pathObj.Status)
    end
end

local function VerifySuccessWithRetry(oldState, target, profile)
    local targetStatName = profile.TargetStat
    local maxWait = profile.VerificationTimeout or 1.5
    local interval = 0.25
    local elapsed = 0

    while elapsed < maxWait do
        if targetStatName then
            local currentState = CaptureState(targetStatName)
            if currentState[targetStatName] and oldState[targetStatName] then
                if currentState[targetStatName] > oldState[targetStatName] then
                    return true 
                end
            end
        else
            if not target or not target.Parent then return true end
            local prompt = target:FindFirstChildWhichIsA("ProximityPrompt", true)
            if not prompt or not prompt.Enabled then
                return true
            end
        end
        
        task.wait(interval)
        elapsed += interval
    end
    
    return false
end

function FarmEngine:Start(profile)
    if self.Running then return end
    self.Running = true
    self.State = "Searching"
    
    SetupCacheListeners(profile)
    
    task.spawn(function()
        local path = PathfindingService:CreatePath({
            AgentRadius = profile.AgentRadius or 2,
            AgentHeight = profile.AgentHeight or 5,
            AgentCanJump = true
        })

        while self.Running do
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local humanoid = char and char:FindFirstChild("Humanoid")
            
            if not hrp or not humanoid or humanoid.Health <= 0 then
                self.State = "Searching"
                self.CurrentTarget = nil
                task.wait(1)
                continue
            end
            
            local currentTime = tick()
            
            if self.State == "Searching" then
                self.CurrentTarget = nil
                local bestTarget = nil
                local bestScore = math.huge
                local maxDist = profile.MaxDistance or 250
                local retryPenalty = profile.RetryPenaltyScore or 15
                
                for obj, _ in pairs(FarmEngine.TargetCache) do
                    if obj and obj.Parent then
                        local meta = FarmEngine.TargetMeta[obj]
                        
                        if meta and meta.BlacklistUntil and currentTime >= meta.BlacklistUntil then
                            meta.Retries = math.max(0, meta.Retries - 1)
                            meta.BlacklistUntil = nil
                        end
                        
                        local maxRetriesExceeded = meta and meta.Retries >= (profile.MaxRetries or 6)
                        
                        if not maxRetriesExceeded and (not meta or not meta.BlacklistUntil) then
                            local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if prompt and prompt.Enabled then
                                local targetPos = (obj:IsA("Model") and obj:GetPivot().Position) or obj.Position
                                local dist = (hrp.Position - targetPos).Magnitude
                                
                                if dist < maxDist then
                                    local score = dist + ((meta and meta.Retries or 0) * retryPenalty)
                                    if score < bestScore then
                                        bestScore = score
                                        bestTarget = obj
                                    end
                                end
                            end
                        end
                    end
                end
                
                if bestTarget then
                    self.CurrentTarget = bestTarget
                    self.State = "Moving"
                    local meta = self.TargetMeta[bestTarget]
                    if meta then
                        meta.MoveStartTime = currentTime
                        meta.JourneyStartTime = currentTime
                        meta.LastPos = hrp.Position
                        meta.TriedRecomputingOnStuck = false
                        meta.FallbackCount = 0
                        meta.PathRetries = 0
                        meta.WaypointTime = currentTime
                        
                        local targetPos = (bestTarget:IsA("Model") and bestTarget:GetPivot().Position) or bestTarget.Position
                        meta.LastTargetPos = targetPos
                        
                        local success, _ = ComputePathSafe(path, hrp.Position, targetPos, meta)
                        if not success then
                            self.Metrics.Failed.Pathfinding += 1
                        end
                    end
                else
                    task.wait(0.4)
                end
                
            elseif self.State == "Moving" then
                if not self.CurrentTarget or not self.CurrentTarget.Parent then
                    self.State = "Searching"
                    continue
                end
                
                local meta = self.TargetMeta[self.CurrentTarget]
                if not meta then
                    self.State = "Searching"
                    continue
                end
                
                local maxJourneyTime = profile.TotalJourneyTimeout or 45
                if currentTime - meta.JourneyStartTime > maxJourneyTime then
                    meta.Retries += 1
                    meta.BlacklistUntil = currentTime + 25
                    self.Metrics.Failed.Movement += 1
                    self.CurrentTarget = nil
                    self.State = "Searching"
                    continue
                end
                
                local targetPos = (self.CurrentTarget:IsA("Model") and self.CurrentTarget:GetPivot().Position) or self.CurrentTarget.Position
                
                if (targetPos - meta.LastTargetPos).Magnitude > 6 then
                    meta.LastTargetPos = targetPos
                    self.State = "Repathing"
                    continue
                end
                
                if meta.CurrentPath and meta.WaypointIndex <= #meta.CurrentPath then
                    local waypoint = meta.CurrentPath[meta.WaypointIndex]
                    humanoid:MoveTo(waypoint.Position)
                    
                    if waypoint.Action == Enum.PathWaypointAction.Jump then
                        humanoid.Jump = true
                    end
                    
                    local hPosPlayer = hrp.Position * Vector3.new(1, 0, 1)
                    local hPosWaypoint = waypoint.Position * Vector3.new(1, 0, 1)
                    
                    if (hPosPlayer - hPosWaypoint).Magnitude < 3.5 then
                        meta.WaypointIndex += 1
                        meta.WaypointTime = currentTime
                    else
                        if currentTime - meta.WaypointTime > 4.0 then
                            self.State = "Repathing"
                            continue
                        end
                    end
                else
                    self.State = "Repathing"
                    continue
                end
                
                local currentDist = (hrp.Position - targetPos).Magnitude
                if currentDist < 4.2 then
                    self.State = "Interacting"
                else
                    local timeElapsed = currentTime - meta.MoveStartTime
                    if timeElapsed > 5 then
                        local positionDelta = (hrp.Position - meta.LastPos).Magnitude
                        if positionDelta < 1.5 then
                            if not meta.TriedRecomputingOnStuck then
                                meta.TriedRecomputingOnStuck = true
                                self.State = "Repathing"
                                continue
                            else
                                meta.Retries += 1
                                self.Metrics.Failed.Movement += 1
                                local cooldown = math.min(meta.Retries * 10, 45)
                                meta.BlacklistUntil = currentTime + cooldown
                                self.CurrentTarget = nil
                                self.State = "Searching"
                            end
                        else
                            meta.LastPos = hrp.Position
                            meta.MoveStartTime = currentTime
                        end
                    end
                end
                
            elseif self.State == "Repathing" then
                if not self.CurrentTarget or not self.CurrentTarget.Parent then
                    self.State = "Searching"
                    continue
                end
                
                local meta = self.TargetMeta[self.CurrentTarget]
                if not meta then
                    self.State = "Searching"
                    continue
                end
                
                local targetPos = (self.CurrentTarget:IsA("Model") and self.CurrentTarget:GetPivot().Position) or self.CurrentTarget.Position
                
                local success, _ = ComputePathSafe(path, hrp.Position, targetPos, meta)
                if success then
                    meta.FallbackCount = 0
                    meta.TriedRecomputingOnStuck = false
                    meta.WaypointTime = currentTime
                    self.State = "Moving"
                else
                    self.Metrics.Failed.Pathfinding += 1
                    meta.FallbackCount = (meta.FallbackCount or 0) + 1
                    
                    if meta.FallbackCount <= 2 then
                        humanoid:MoveTo(targetPos)
                        self.State = "Moving"
                    else
                        meta.Retries += 1
                        meta.BlacklistUntil = currentTime + 20
                        self.CurrentTarget = nil
                        self.State = "Searching"
                    end
                end
                
            elseif self.State == "Interacting" then
                if self.CurrentTarget and self.CurrentTarget.Parent then
                    local targetPos = (self.CurrentTarget:IsA("Model") and self.CurrentTarget:GetPivot().Position) or self.CurrentTarget.Position
                    if (hrp.Position - targetPos).Magnitude > 6.5 then
                        self.State = "Moving"
                        continue
                    end
                    
                    local prompt = self.CurrentTarget:FindFirstChildWhichIsA("ProximityPrompt", true)
                    
                    if not prompt or not prompt.Enabled then
                        self.Metrics.Failed.Verification += 1
                        local meta = self.TargetMeta[self.CurrentTarget]
                        if meta then
                            meta.Retries += 1
                            meta.BlacklistUntil = currentTime + 15
                        end
                    else
                        self.InitialValues = CaptureState(profile.TargetStat)
                        
                        local successInteract, _ = pcall(function()
                            if profile.CustomInteraction then
                                profile.CustomInteraction(self.CurrentTarget, prompt)
                            else
                                fireproximityprompt(prompt)
                            end
                        end)
                        
                        if not successInteract then
                            self.Metrics.Failed.Interaction += 1
                            local meta = self.TargetMeta[self.CurrentTarget]
                            if meta then
                                meta.Retries += 1
                                local cooldown = math.min(meta.Retries * 8, 30)
                                meta.BlacklistUntil = currentTime + cooldown
                            end
                        else
                            if VerifySuccessWithRetry(self.InitialValues, self.CurrentTarget, profile) then
                                self.Metrics.Success += 1
                                local meta = self.TargetMeta[self.CurrentTarget]
                                if meta then
                                    meta.Retries = 0
                                    meta.BlacklistUntil = nil
                                    meta.PathRetries = 0
                                    meta.TriedRecomputingOnStuck = false
                                end
                            else
                                self.Metrics.Failed.Verification += 1
                                local meta = self.TargetMeta[self.CurrentTarget]
                                if meta then
                                    meta.Retries += 1
                                    local cooldown = math.min(meta.Retries * 8, 30)
                                    meta.BlacklistUntil = currentTime + cooldown
                                end
                            end
                        end
                    end
                end
                
                self.CurrentTarget = nil
                self.State = "Searching"
            end
            
            task.wait(0.1)
        end
    end)
end

function FarmEngine:Stop()
    self.Running = false
    self.State = "Searching"
    self.CurrentTarget = nil
    
    table.clear(self.TargetCache)
    table.clear(self.InitialValues)
    
    for obj, _ in pairs(self.TargetMeta) do
        ClearTargetMeta(obj)
    end
    table.clear(self.TargetMeta)
    
    for _, conn in ipairs(self.GlobalConnections) do
        conn:Disconnect()
    end
    table.clear(self.GlobalConnections)
    
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if humanoid and hrp then
            humanoid:MoveTo(hrp.Position)
        end
    end
end

-- كود التشغيل المباشر:
FarmEngine:Start({
    Validator = function(obj)
        -- استبدل "Coin" باسم الشيء أو الهدف في اللعبة لديك
        return obj.Name == "Coin" 
    end,
    MaxDistance = 300,
})
