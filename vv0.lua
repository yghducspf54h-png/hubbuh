--!strict

type NodeData = {
    id: string,
    category: string,
    className: string,
    name: string,
    path: string,
    properties: {[string]: any}
}

type EdgeData = {
    sourceId: string,
    targetId: string,
    relationType: string
}

type PendingRef = {
    sourceId: string,
    targetInstance: Instance,
    relationType: string
}

type EvidenceRecord = {
    evidenceType: string,
    weight: number,
    description: string,
    sourceNodeId: string,
    targetNodeId: string,
    contextNote: string
}

type ScriptRegistryEntry = {
    id: string,
    name: string,
    path: string,
    scriptType: string,
    parentNodeId: string,
    rawSource: string,
    escapedSource: string,
    sourceAvailable: boolean
}

type BehaviorFlowLink = {
    interactionId: string,
    handlerScriptId: string,
    relationType: string,
    confidenceScore: number,
    confidenceLevel: string, -- "Low", "Medium", "High"
    evidenceRecords: {EvidenceRecord},
    detectedActions: {string},
    targetEndpointId: string
}

type ErrorEntry = {
    path: string,
    className: string,
    errorMsg: string
}

local function runBehaviorReconstructionEngineFinal()
    local startTime = os.clock()
    
    local nodes: {NodeData} = {}
    local edges: {EdgeData} = {}
    local pendingRefs: {PendingRef} = {}
    local behaviorFlows: {BehaviorFlowLink} = {}
    
    local instanceMap: {[Instance]: string} = {}
    local scriptMap: {[Instance]: ScriptRegistryEntry} = {}
    local interactionNodes: { {id: string, instance: Instance, parentNodeId: string, name: string} } = {}
    local scriptsRegistry: {ScriptRegistryEntry} = {}
    local errorRegistry: {ErrorEntry} = {}
    
    -- ترتيب Roots صارم لضمان الثبات المطلق
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
            
            local scrEntry: ScriptRegistryEntry = {
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

    -- تنفيذ التحليل المرتب للـ Roots
    for _, rootEntry in ipairs(analysisRoots) do
        if rootEntry.instance then
            traverse(rootEntry.instance, "", nil)
        end
    end

    -- حل المراجع المؤجلة
    for _, pref in ipairs(pendingRefs) do
        local targetNodeId = instanceMap[pref.targetInstance]
        if targetNodeId then
            table.insert(edges, { sourceId = pref.sourceId, targetId = targetNodeId, relationType = pref.relationType })
        else
            local targetType = (pref.targetInstance and typeof(pref.targetInstance) == "Instance") and ("EXTERNAL_" .. pref.targetInstance.ClassName) or "MISSING_OR_NULL_REFERENCE"
            table.insert(edges, { sourceId = pref.sourceId, targetId = targetType, relationType = pref.relationType })
        end
    end

    -- محرك إعادة بناء السلوك ودمج الأدلة المستقلة (v12 Final)
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
                    
                    local evidenceRecords: {EvidenceRecord} = {}
                    local totalScore = 0
                    
                    -- 1. دليل بعد النطاق (Scope Distance)
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
                    
                    -- 2. مطابقة الأسماء المتدرجة (Name Match Tiers)
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
                    
                    -- 3. دليل المصدر النصي الخام مع معالجة التضخيم المرتبط وصلاحية المصدر
                    if scrData.sourceAvailable and sourceLower:find(interNameLower) then
                        local sourceWeight = 3
                        if hasNameMatch then
                            sourceWeight = 2 -- Capping لمنع التضخيم المزدوج غير المستقل
                        end
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

                    -- تحديد الثقة والنوع
                    local confidenceLevel = "Low"
                    local relationType = "Candidate_By_Scope"
                    if totalScore >= 6 then
                        confidenceLevel = "High"
                        relationType = "High_Confidence_Candidate_Handler"
                    elseif totalScore >= 3 then
                        confidenceLevel = "Medium"
                        relationType = "Medium_Confidence_Candidate_Handler"
                    end

                    -- مؤشرات الأفعال والأهداف المحتملة (Action Footprints & Target Footprints)
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

    -- بناء التقرير النهائي (مع الترتيب الأبجدي للمفاتيح لضمان Reproducibility كاملة)
    local out = {}
    table.insert(out, "<!-- Behavior Reconstruction & Evidence Independence Engine v12.0 Final Baseline -->\n")
    table.insert(out, "<BehaviorReconstructionReport version=\"12.0\">\n")

    table.insert(out, "    <AnalysisScope>\n")
    for _, rootEntry in ipairs(analysisRoots) do
        table.insert(out, string.format("        <Root target=\"%s\"/>\n", escapeXML(rootEntry.name)))
    end
    table.insert(out, "    </AnalysisScope>\n")

    table.insert(out, "    <NodesSection>\n")
    for _, node in ipairs(nodes) do
        table.insert(out, string.format("        <Node id=\"%s\" category=\"%s\" class=\"%s\" name=\"%s\" path=\"%s\">\n", 
            escapeXML(node.id), escapeXML(node.category), escapeXML(node.className), escapeXML(node.name), escapeXML(node.path)))
        
        -- ترتيت مفاتيح الـ Properties لتثبيت المخرجات تماماً (Deterministic Sorting)
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

    local finalXML = table.concat(out)
    local duration = os.clock() - startTime

    print("========================================")
    print(" BEHAVIOR RECONSTRUCTION ENGINE v12.0   ")
    print("========================================")
    print(string.format("• إجمالي العقد: %d", #nodes))
    print(string.format("• الروابط الهيكلية: %d", #edges))
    print(string.format("• مسارات إعادة بناء السلوك: %d", #behaviorFlows))
    print(string.format("• السكريبتات المفهرسة: %d", #scriptsRegistry))
    print(string.format("• وقت التنفيذ: %.4f ثانية", duration))
    print("========================================")

    if writefile then
        writefile("BehaviorReconstructionReport_v12_Final.xml", finalXML)
        print("تم حفظ التقرير بنجاح باسم: BehaviorReconstructionReport_v12_Final.xml")
    else
        warn("دوال الكتابة غير متوفرة.")
    end
end

runBehaviorReconstructionEngineFinal()
