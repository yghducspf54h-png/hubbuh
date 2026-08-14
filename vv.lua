--!strict

-- =====================================================================
-- BEHAVIOR RECONSTRUCTION ENGINE v14.0: FULL v12 ENGINE + v13 UI PIPELINE
-- =====================================================================

local Players = game("Players")
local CoreGui = game("CoreGui")

local player = Players.LocalPlayer
local guiParent = pcall(function() return CoreGui end) and CoreGui or (player and player("PlayerGui") or nil)

if not guiParent then
warn("لا يمكن العثور على حاوية مناسبة للـ GUI.")
return
end

-- إزالة أي نسخة سابقة منعاً للتداخل
local existingGui = guiParent("BehaviorAnalyzerUIv14")
if existingGui then
existingGui()
end

-- إنشاء الواجهة الرئيسية (ScreenGui)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BehaviorAnalyzerUIv14"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = guiParent

-- نافذة التطبيق الرئيسية (Main Frame)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 720, 0, 520)
mainFrame.Position = UDim2.new(0.5, -360, 0.5, -260)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

-- شريط العنوان (Title Bar)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.Code
titleLabel.Text = "Behavior Reconstruction Engine v14.0 [Full v12 Engine + Pipeline Dashboard]"
titleLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
titleLabel.TextSize = 13
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- =====================================================================
-- 1. TERMINAL VIEW (حاوية التيرمينال اللحظي لمراحل النظام)
-- =====================================================================
local terminalView = Instance.new("Frame")
terminalView.Name = "TerminalView"
terminalView.Size = UDim2.new(1, -30, 1, -65)
terminalView.Position = UDim2.new(0, 15, 0, 52)
terminalView.BackgroundTransparency = 1
terminalView.Parent = mainFrame

local termScroll = Instance.new("ScrollingFrame")
termScroll.Size = UDim2.new(1, 0, 1, 0)
termScroll.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
termScroll.BorderSizePixel = 0
termScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
termScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
termScroll.ScrollBarThickness = 6
termScroll.Parent = terminalView

local termCorner = Instance.new("UICorner")
termCorner.CornerRadius = UDim.new(0, 6)
termCorner.Parent = termScroll

local termLayout = Instance.new("UIListLayout")
termLayout.SortOrder = Enum.SortOrder.LayoutOrder
termLayout.Padding = UDim.new(0, 4)
termLayout.Parent = termScroll

-- =====================================================================
-- 2. RESULTS DASHBOARD VIEW (لوحة النتائج والإحصائيات الشاملة)
-- =====================================================================
local resultsView = Instance.new("Frame")
resultsView.Name = "ResultsView"
resultsView.Size = UDim2.new(1, -30, 1, -65)
resultsView.Position = UDim2.new(0, 15, 0, 52)
resultsView.BackgroundTransparency = 1
resultsView.Visible = false
resultsView.Parent = mainFrame

local resultsGrid = Instance.new("UIGridLayout")
resultsGrid.CellSize = UDim2.new(0, 218, 0, 72)
resultsGrid.CellPadding = UDim2.new(0, 12, 0, 12)
resultsGrid.Parent = resultsView

local function createStatCard(title: string): (Frame, TextLabel)
local card = Instance.new("Frame")
card.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
card.BorderSizePixel = 0

local cCorner = Instance.new("UICorner")
cCorner.CornerRadius = UDim.new(0, 6)
cCorner.Parent = card

local tLbl = Instance.new("TextLabel")
tLbl.Size = UDim2.new(1, 0, 0, 22)
tLbl.Position = UDim2.new(0, 0, 0, 8)
tLbl.BackgroundTransparency = 1
tLbl.Font = Enum.Font.SourceSansBold
tLbl.Text = title
tLbl.TextColor3 = Color3.fromRGB(150, 150, 180)
tLbl.TextSize = 13
tLbl.Parent = card

local vLbl = Instance.new("TextLabel")
vLbl.Name = "Value"
vLbl.Size = UDim2.new(1, 0, 0, 32)
vLbl.Position = UDim2.new(0, 0, 0, 28)
vLbl.BackgroundTransparency = 1
vLbl.Font = Enum.Font.Code
vLbl.Text = "0"
vLbl.TextColor3 = Color3.fromRGB(0, 255, 128)
vLbl.TextSize = 18
vLbl.Parent = card

card.Parent = resultsView
return card, vLbl

end

local _, statNodes = createStatCard("Total Nodes")
local _, statEdges = createStatCard("Structural Edges")
local _, statScripts = createStatCard("Indexed Scripts")
local _, statFlows = createStatCard("Behavior Flows")
local _, statErrors = createStatCard("Analysis Errors")
local _, statTime = createStatCard("Execution Time")

-- زر النسخ (Copy XML Report Button)
local downloadBtn = Instance.new("TextButton")
downloadBtn.Name = "CopyXMLButton"
downloadBtn.Size = UDim2.new(1, 0, 0, 42)
downloadBtn.Position = UDim2.new(0, 0, 1, -48)
downloadBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 90)
downloadBtn.Font = Enum.Font.SourceSansBold
downloadBtn.Text = "Copy Full XML Report to Clipboard"
downloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
downloadBtn.TextSize = 15
downloadBtn.Parent = resultsView

local dCorner = Instance.new("UICorner")
dCorner.CornerRadius = UDim.new(0, 6)
dCorner.Parent = downloadBtn

-- =====================================================================
-- 3. ERROR VIEW (نافذة إدارة الأخطاء والفشل)
-- =====================================================================
local errorView = Instance.new("Frame")
errorView.Name = "ErrorView"
errorView.Size = UDim2.new(1, -30, 1, -65)
errorView.Position = UDim2.new(0, 15, 0, 52)
errorView.BackgroundTransparency = 1
errorView.Visible = false
errorView.Parent = mainFrame

local errorTitle = Instance.new("TextLabel")
errorTitle.Size = UDim2.new(1, 0, 0, 35)
errorTitle.BackgroundTransparency = 1
errorTitle.Font = Enum.Font.SourceSansBold
errorTitle.Text = "❌ Pipeline Execution Failed"
errorTitle.TextColor3 = Color3.fromRGB(255, 80, 80)
errorTitle.TextSize = 18
errorTitle.TextXAlignment = Enum.TextXAlignment.Left
errorTitle.Parent = errorView

local errorMsgBox = Instance.new("TextBox")
errorMsgBox.Name = "ErrorMsgBox"
errorMsgBox.Size = UDim2.new(1, 0, 0, 180)
errorMsgBox.Position = UDim2.new(0, 0, 0, 45)
errorMsgBox.BackgroundColor3 = Color3.fromRGB(24, 15, 18)
errorMsgBox.ClearTextOnFocus = false
errorMsgBox.MultiLine = true
errorMsgBox.Font = Enum.Font.Code
errorMsgBox.Text = "Stage: [Unknown]\nError: [No message provided]"
errorMsgBox.TextColor3 = Color3.fromRGB(255, 180, 180)
errorMsgBox.TextSize = 13
errorMsgBox.TextXAlignment = Enum.TextXAlignment.Left
errorMsgBox.TextYAlignment = Enum.TextYAlignment.Top
errorMsgBox.Parent = errorView

local eBoxCorner = Instance.new("UICorner")
eBoxCorner.CornerRadius = UDim.new(0, 6)
eBoxCorner.Parent = errorMsgBox

local copyErrorBtn = Instance.new("TextButton")
copyErrorBtn.Size = UDim2.new(0.48, 0, 0, 42)
copyErrorBtn.Position = UDim2.new(0, 0, 1, -50)
copyErrorBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
copyErrorBtn.Font = Enum.Font.SourceSansBold
copyErrorBtn.Text = "Copy Error"
copyErrorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyErrorBtn.TextSize = 15
copyErrorBtn.Parent = errorView

local ceCorner = Instance.new("UICorner")
ceCorner.CornerRadius = UDim.new(0, 6)
ceCorner.Parent = copyErrorBtn

local retryBtn = Instance.new("TextButton")
retryBtn.Size = UDim2.new(0.48, 0, 0, 42)
retryBtn.Position = UDim2.new(0.52, 0, 1, -50)
retryBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
retryBtn.Font = Enum.Font.SourceSansBold
retryBtn.Text = "Retry Pipeline"
retryBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
retryBtn.TextSize = 15
retryBtn.Parent = errorView

local rCorner = Instance.new("UICorner")
rCorner.CornerRadius = UDim.new(0, 6)
rCorner.Parent = retryBtn

-- =====================================================================
-- FULL v12 ENGINE INTEGRATED INTO v14 PIPELINE CONTROLLER
-- =====================================================================
local function logToTerminal(message: string, typeColor: Color3?)
local lbl = Instance.new("TextLabel")
lbl.Size = UDim2.new(1, 0, 0, 20)
lbl.BackgroundTransparency = 1
lbl.Font = Enum.Font.Code
lbl.Text = message
lbl.TextColor3 = typeColor or Color3.fromRGB(200, 200, 220)
lbl.TextSize = 13
lbl.TextXAlignment = Enum.TextXAlignment.Left
lbl.Parent = termScroll
termScroll.CanvasPosition = Vector2.new(0, termScroll.AbsoluteCanvasSize.Y)
end

local generatedXMLFinal = ""

local function runPipeline()
-- مسح التيرمينال السابق
for _, child in ipairs(termScroll()) do
if child("TextLabel") then
child()
end
end

terminalView.Visible = true
resultsView.Visible = false
errorView.Visible = false

local startTime = os.clock()

local function executeStage(stageName: string, stageFunc: () -> ())
    logToTerminal(string.format("[>] Starting stage: %s ...", stageName), Color3.fromRGB(100, 200, 255))
    task.wait(0.1) -- السماح بتحديث الواجهة بصرياً
    
    local success, err = pcall(stageFunc)
    if not success then
        error(string.format("Stage [%s] Failed: %s", stageName, tostring(err)))
    else
        logToTerminal(string.format("[✓] Completed stage: %s", stageName), Color3.fromRGB(0, 255, 128))
    end
end

-- بيانات المحرك الشاملة (نسخة v12 كاملة غير منقوصة)
local nodes = {}
local edges = {}
local pendingRefs = {}
local behaviorFlows = {}

local instanceMap = {}
local scriptMap = {}
local interactionNodes = {}
local scriptsRegistry = {}
local errorRegistry = {}

local analysisRoots = {
    { name = "Workspace", instance = workspace },
    { name = "ReplicatedStorage", instance = game:GetService("ReplicatedStorage") },
    { name = "ServerScriptService", instance = game:GetService("ServerScriptService") }
}

local idCounter = 0
local function generateNodeId(): string
    idCounter += 1
    return string.format("NODE_%04d", idCounter)
end

local function escapeXML(value: any): string
    local str = tostring(value or "")
    return str:gsub("&", "&amp;")
              :gsub("<", "&lt;")
              :gsub(">", "&gt;")
              :gsub("\"", "&quot;")
              :gsub("'", "&apos;")
end

local function escapeCDATA(source: string): string
    return source:gsub("]]>", "]]]]><![CDATA[>")
end

local function categorizeInstance(instance: Instance): string
    if instance:IsA("ProximityPrompt") or instance:IsA("ClickDetector") then
        return "Interaction"
    elseif instance:IsA("Tool") then
        return "ToolContainer"
    elseif instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") or instance:IsA("BindableEvent") or instance:IsA("BindableFunction") then
        return "Communication"
    elseif instance:IsA("Script") or instance:IsA("LocalScript") or instance:IsA("ModuleScript") then
        return "Script"
    elseif instance:IsA("Constraint") or instance:IsA("Attachment") then
        return "Constraint"
    elseif instance:IsA("ValueBase") then
        return "Data"
    else
        return "Environment"
    end
end

local function extractBehavioralProperties(instance: Instance): {[string]: any}
    local props = {}
    pcall(function()
        if instance:IsA("ProximityPrompt") then
            props["HoldDuration"] = tostring(instance.HoldDuration)
            props["MaxActivationDistance"] = tostring(instance.MaxActivationDistance)
        elseif instance:IsA("BasePart") then
            props["CanCollide"] = tostring(instance.CanCollide)
            props["Transparency"] = tostring(instance.Transparency)
        end
    end)
    return props
end

local successPipeline, pipelineErr = pcall(function()
    -- 1. initialization
    executeStage("initialization", function()
        logToTerminal("-> Initializing analysis roots & state registries (v12 engine core)...", Color3.fromRGB(180, 180, 180))
    end)
    
    -- 2. scanning
    executeStage("scanning", function()
        local function traverse(instance: Instance, parentPath: string, parentId: string?)
            local currentPath = parentPath == "" and instance.Name or parentPath .. "." .. instance.Name
            local nodeId = generateNodeId()
            
            instanceMap[instance] = nodeId
            local category = categorizeInstance(instance)

            local nodeProps = {}
            local success, err = pcall(function()
                nodeProps = extractBehavioralProperties(instance)
            end)

            if not success then
                table.insert(errorRegistry, { path = currentPath, className = instance.ClassName, errorMsg = tostring(err) })
            end

            table.insert(nodes, {
                id = nodeId,
                category = category,
                className = instance.ClassName,
                name = instance.Name,
                path = currentPath,
                properties = nodeProps
            })

            if parentId then
                table.insert(edges, { sourceId = parentId, targetId = nodeId, relationType = "Hierarchy_Child" })
            end

            if instance:IsA("ObjectValue") then
                local successVal, targetInst = pcall(function() return instance.Value end)
                if successVal and targetInst then
                    table.insert(pendingRefs, { sourceId = nodeId, targetInstance = targetInst, relationType = "ObjectValue_Reference" })
                end
            elseif instance:IsA("Constraint") then
                for _, propName in ipairs({"Attachment0", "Attachment1"}) do
                    local successAtt, attInst = pcall(function() return (instance :: any)[propName] end)
                    if successAtt and attInst and typeof(attInst) == "Instance" then
                        table.insert(pendingRefs, { sourceId = nodeId, targetInstance = attInst, relationType = "Constraint_" .. propName })
                    end
                end
            end

            if category == "Interaction" or category == "ToolContainer" or category == "Communication" then
                table.insert(interactionNodes, {
                    id = nodeId,
                    instance = instance,
                    parentNodeId = parentId or "ROOT",
                    name = instance.Name
                })
            end

            if category == "Script" then
                local successSrc, source = pcall(function() return (instance :: any).Source end)
                local sourceAvailable = successSrc and (source ~= nil) and (source ~= "")
                local rawSrcText = sourceAvailable and source or ""
                
                local scrEntry = {
                    id = nodeId,
                    name = instance.Name,
                    path = currentPath,
                    scriptType = instance.ClassName,
                    parentNodeId = parentId or "ROOT",
                    rawSource = rawSrcText,
                    escapedSource = sourceAvailable and escapeCDATA(rawSrcText) or "[UNAVAILABLE_OR_RESTRICTED]",
                    sourceAvailable = sourceAvailable
                }
                
                scriptMap[instance] = scrEntry
                table.insert(scriptsRegistry, scrEntry)
            end

            for _, child in ipairs(instance:GetChildren()) do
                local childSuccess, childErr = pcall(function()
                    traverse(child, currentPath, nodeId)
                end)
                if not childSuccess then
                    table.insert(errorRegistry, {
                        path = currentPath .. "." .. child.Name,
                        className = "Traversal_Child_Error",
                        errorMsg = tostring(childErr)
                    })
                end
            end
        end

        for _, rootEntry in ipairs(analysisRoots) do
            if rootEntry.instance then
                traverse(rootEntry.instance, "", nil)
            end
        end
    end)
    
    -- 3. indexing
    executeStage("indexing", function()
        logToTerminal(string.format("-> Indexed %d nodes, %d scripts, %d errors logged.", #nodes, #scriptsRegistry, #errorRegistry), Color3.fromRGB(180, 180, 180))
    end)
    
    -- 4. reference resolution
    executeStage("reference resolution", function()
        for _, pref in ipairs(pendingRefs) do
            local targetNodeId = instanceMap[pref.targetInstance]
            if targetNodeId then
                table.insert(edges, { sourceId = pref.sourceId, targetId = targetNodeId, relationType = pref.relationType })
            else
                local targetType = (pref.targetInstance and typeof(pref.targetInstance) == "Instance") and ("EXTERNAL_" .. pref.targetInstance.ClassName) or "MISSING_OR_NULL_REFERENCE"
                table.insert(edges, { sourceId = pref.sourceId, targetId = targetType, relationType = pref.relationType })
            end
        end
    end)
    
    -- 5 & 6. behavior reconstruction & evidence fusion
    executeStage("behavior reconstruction & evidence fusion", function()
        for _, inter in ipairs(interactionNodes) do
            local container = inter.instance.Parent
            local foundCandidates = false
            local scopeDepth = 0
            
            while container and container ~= game do
                scopeDepth += 1
                for _, child in ipairs(container:GetChildren()) do
                    if scriptMap[child] then
                        foundCandidates = true
                        local scrData = scriptMap[child]
                        local scriptNameLower = scrData.name:lower()
                        local interNameLower = inter.name:lower()
                        local sourceLower = scrData.rawSource:lower()
                        
                        local evidenceRecords = {}
                        local totalScore = 0
                        
                        local scopeWeight = (scopeDepth == 1) and 3 or ((scopeDepth == 2) and 2 or 1)
                        totalScore += scopeWeight
                        table.insert(evidenceRecords, {
                            evidenceType = "ScopeAncestorDistance",
                            weight = scopeWeight,
                            description = string.format("Script discovered via ancestor container hierarchy at scope depth %d", scopeDepth),
                            sourceNodeId = inter.id,
                            targetNodeId = scrData.id,
                            contextNote = "Shared container scope proximity assessment."
                        })
                        
                        local hasNameMatch = false
                        if scriptNameLower == interNameLower then
                            hasNameMatch = true
                            local exactWeight = 3
                            totalScore += exactWeight
                            table.insert(evidenceRecords, {
                                evidenceType = "ExactNameMatch",
                                weight = exactWeight,
                                description = "Script name matches interaction name perfectly (case-insensitive).",
                                sourceNodeId = inter.id,
                                targetNodeId = scrData.id,
                                contextNote = string.format("Exact identifier match: '%s'", scrData.name)
                            })
                        elseif scriptNameLower:find(interNameLower) then
                            hasNameMatch = true
                            local subWeight = 1
                            totalScore += subWeight
                            table.insert(evidenceRecords, {
                                evidenceType = "NameSubstringMatch",
                                weight = subWeight,
                                description = "Script name contains interaction name as a substring.",
                                sourceNodeId = inter.id,
                                targetNodeId = scrData.id,
                                contextNote = string.format("Substring match in script '%s' for '%s'", scrData.name, inter.name)
                            })
                        end
                        
                        if scrData.sourceAvailable and sourceLower:find(interNameLower) then
                            local sourceWeight = hasNameMatch and 2 or 3
                            totalScore += sourceWeight
                            table.insert(evidenceRecords, {
                                evidenceType = "RawSourceTextualReference",
                                weight = sourceWeight,
                                description = "Interaction name textually appears inside script raw source code.",
                                sourceNodeId = inter.id,
                                targetNodeId = scrData.id,
                                contextNote = hasNameMatch and "Correlated textual reference (capped weight for independence)." or "Independent textual reference in source."
                            })
                        end

                        local confidenceLevel = "Low"
                        local relationType = "Candidate_By_Scope"
                        if totalScore >= 6 then
                            confidenceLevel = "High"
                            relationType = "High_Confidence_Candidate_Handler"
                        elseif totalScore >= 3 then
                            confidenceLevel = "Medium"
                            relationType = "Medium_Confidence_Candidate_Handler"
                        end

                        local detectedActions = {}
                        local targetEndpointId = "NONE_DETECTED"
                        
                        if scrData.sourceAvailable then
                            if sourceLower:find("fireserver") or sourceLower:find("fireclient") then
                                table.insert(detectedActions, "Indicator: Remote Communication")
                                targetEndpointId = "COMMUNICATION_ENDPOINT_REMOTE"
                            end
                            if sourceLower:find("tween") then
                                table.insert(detectedActions, "Indicator: Tween Animation")
                                targetEndpointId = "ENVIRONMENT_TWEEN_TARGET"
                            end
                            if sourceLower:find(".value") or sourceLower:find("value =") then
                                table.insert(detectedActions, "Indicator: State Data Modification")
                                targetEndpointId = "DATA_VALUE_BASE_TARGET"
                            end
                            if sourceLower:find("destroy") then
                                table.insert(detectedActions, "Indicator: Instance Destruction")
                                targetEndpointId = "INSTANCE_DESTRUCTION_TARGET"
                            end
                        end

                        if #detectedActions == 0 then
                            table.insert(detectedActions, "Indicator: General Execution Logic")
                        end

                        table.insert(behaviorFlows, {
                            interactionId = inter.id,
                            handlerScriptId = scrData.id,
                            relationType = relationType,
                            confidenceScore = totalScore,
                            confidenceLevel = confidenceLevel,
                            evidenceRecords = evidenceRecords,
                            detectedActions = detectedActions,
                            targetEndpointId = targetEndpointId
                        })
                    end
                end
                container = container.Parent
            end
            
            if not foundCandidates then
                table.insert(behaviorFlows, {
                    interactionId = inter.id,
                    handlerScriptId = "NONE_UNRESOLVED",
                    relationType = "Unresolved_Handler",
                    confidenceScore = 0,
                    confidenceLevel = "None",
                    evidenceRecords = {
                        { evidenceType = "None", weight = 0, description = "No scoped handler script discovered.", sourceNodeId = inter.id, targetNodeId = "NONE", contextNote = "Unresolved flow state." }
                    },
                    detectedActions = {"None"},
                    targetEndpointId = "NONE"
                })
            end
        end
    end)
    
    -- 7. XML generation (توليد تقرير v12 الكامل بجميع الأقسام بدون نقصان)
    executeStage("XML generation", function()
        local out = {}
        table.insert(out, "<!-- Behavior Reconstruction & Evidence Independence Engine v14.0 Report -->\n")
        table.insert(out, "<BehaviorReconstructionReport version=\"14.0\">\n")

        table.insert(out, "    <AnalysisScope>\n")
        for _, rootEntry in ipairs(analysisRoots) do
            table.insert(out, string.format("        <Root target=\"%s\"/>\n", escapeXML(rootEntry.name)))
        end
        table.insert(out, "    </AnalysisScope>\n")

        table.insert(out, "    <NodesSection>\n")
        for _, node in ipairs(nodes) do
            table.insert(out, string.format("        <Node id=\"%s\" category=\"%s\" class=\"%s\" name=\"%s\" path=\"%s\">\n", 
                escapeXML(node.id), escapeXML(node.category), escapeXML(node.className), escapeXML(node.name), escapeXML(node.path)))
            
            local propKeys = {}
            for k in pairs(node.properties) do
                table.insert(propKeys, k)
            end
            table.sort(propKeys)
            
            for _, k in ipairs(propKeys) do
                local v = node.properties[k]
                table.insert(out, string.format("            <Prop name=\"%s\">%s</Prop>\n", escapeXML(k), escapeXML(v)))
            end
            table.insert(out, "        </Node>\n")
        end
        table.insert(out, "    </NodesSection>\n")

        table.insert(out, "    <EdgesSection>\n")
        for _, edge in ipairs(edges) do
            table.insert(out, string.format("        <Edge source=\"%s\" target=\"%s\" type=\"%s\"/>\n", 
                escapeXML(edge.sourceId), escapeXML(edge.targetId), escapeXML(edge.relationType)))
        end
        table.insert(out, "    </EdgesSection>\n")

        table.insert(out, "    <BehaviorReconstructionFlowSection>\n")
        for _, flow in ipairs(behaviorFlows) do
            table.insert(out, string.format("        <Flow interactionId=\"%s\" handlerScriptId=\"%s\" type=\"%s\" score=\"%d\" confidence=\"%s\" targetEndpoint=\"%s\">\n", 
                escapeXML(flow.interactionId), escapeXML(flow.handlerScriptId), escapeXML(flow.relationType), flow.confidenceScore, escapeXML(flow.confidenceLevel), escapeXML(flow.targetEndpointId)))
            
            table.insert(out, "            <EvidenceRecords>\n")
            for _, rec in ipairs(flow.evidenceRecords) do
                table.insert(out, string.format("                <Evidence type=\"%s\" weight=\"%d\" source=\"%s\" target=\"%s\" note=\"%s\">%s</Evidence>\n", 
                    escapeXML(rec.evidenceType), rec.weight, escapeXML(rec.sourceNodeId), escapeXML(rec.targetNodeId), escapeXML(rec.contextNote), escapeXML(rec.description)))
            end
            table.insert(out, "            </EvidenceRecords>\n")

            table.insert(out, "            <ActionFootprints>\n")
            for _, act in ipairs(flow.detectedActions) do
                table.insert(out, string.format("                <Indicator>%s</Indicator>\n", escapeXML(act)))
            end
            table.insert(out, "            </ActionFootprints>\n")
            
            table.insert(out, "        </Flow>\n")
        end
        table.insert(out, "    </BehaviorReconstructionFlowSection>\n")

        table.insert(out, "    <ScriptInventorySection>\n")
        for _, scr in ipairs(scriptsRegistry) do
            table.insert(out, string.format("        <Script id=\"%s\" type=\"%s\" name=\"%s\" path=\"%s\" parentNodeId=\"%s\" sourceAvailable=\"%s\">\n", 
                escapeXML(scr.id), escapeXML(scr.scriptType), escapeXML(scr.name), escapeXML(scr.path), escapeXML(scr.parentNodeId), tostring(scr.sourceAvailable)))
            table.insert(out, string.format("            <Source><![CDATA[%s]]></Source>\n", scr.escapedSource))
            table.insert(out, "        </Script>\n")
        end
        table.insert(out, "    </ScriptInventorySection>\n")

        table.insert(out, "    <ErrorRegistrySection>\n")
        for _, errEntry in ipairs(errorRegistry) do
            table.insert(out, string.format("        <Error path=\"%s\" class=\"%s\">%s</Error>\n", 
                escapeXML(errEntry.path), escapeXML(errEntry.className), escapeXML(errEntry.errorMsg)))
        end
        table.insert(out, "    </ErrorRegistrySection>\n")

        table.insert(out, "</BehaviorReconstructionReport>")

        generatedXMLFinal = table.concat(out)
    end)
    
    -- 8. validation (تم تصحيح الإغلاق هنا من end() إلى end)
    executeStage("validation", function()
        if generatedXMLFinal == "" or not generatedXMLFinal:find("</BehaviorReconstructionReport>") then
            error("XML generation validation failed integrity check.")
        end
    end)
    
    -- تحديث واجهة الإحصائيات بالنتائج الفعلية
    statNodes.Text = tostring(#nodes)
    statEdges.Text = tostring(#edges)
    statScripts.Text = tostring(#scriptsRegistry)
    statFlows.Text = tostring(#behaviorFlows)
    statErrors.Text = tostring(#errorRegistry)
    statTime.Text = string.format("%.4fs", os.clock() - startTime)
    
    task.wait(0.4)
    terminalView.Visible = false
    resultsView.Visible = true
end)

if not successPipeline then
    terminalView.Visible = false
    errorView.Visible = true
    errorMsgBox.Text = tostring(pipelineErr)
end

end

-- أزرار التحكم والنسخ
retryBtn.MouseButton1Click(function()
runPipeline()
end)

copyErrorBtn.MouseButton1Click(function()
if setclipboard then
setclipboard(errorMsgBox.Text)
copyErrorBtn.Text = "Copied!"
task.wait(1)
copyErrorBtn.Text = "Copy Error"
end
end)

downloadBtn.MouseButton1Click(function()
if setclipboard then
setclipboard(generatedXMLFinal)
downloadBtn.Text = "XML Copied to Clipboard Successfully!"
task.wait(1.5)
downloadBtn.Text = "Copy Full XML Report to Clipboard"
else
print(generatedXMLFinal)
downloadBtn.Text = "Printed to Developer Console!"
task.wait(1.5)
downloadBtn.Text = "Copy Full XML Report to Clipboard"
end
end)

-- بدء التشغيل التلقائي للـ Pipeline
runPipeline()
