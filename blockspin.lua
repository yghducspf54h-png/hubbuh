-- سكربت أوتو فارم لتكديس الصناديق
-- إعداد Alanazi 💪

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- الريموتات اللي اكتشفتها من SimpleSpy
local inv = game:GetService("ReplicatedStorage"):WaitForChild("Inventory")
local getSlots = inv:WaitForChild("GetStorageSlots")
local getItems = inv:WaitForChild("GetStoredItems")

-- دالة للبحث عن أقرب صندوق
local function getNearestBox()
    local nearest, dist = nil, math.huge
    for _, box in pairs(workspace:GetChildren()) do
        if box.Name == "Box" and box:FindFirstChild("Handle") then
            local d = (hrp.Position - box.Handle.Position).Magnitude
            if d < dist then
                dist = d
                nearest = box
            end
        end
    end
    return nearest
end

-- دالة للبحث عن الدائرة الزرقاء (المكان العشوائي)
local function getBlueCircle()
    local nearest, dist = nil, math.huge
    for _, part in pairs(workspace:GetChildren()) do
        if part:IsA("Part") and part.Color == Color3.fromRGB(0, 85, 255) then
            local d = (hrp.Position - part.Position).Magnitude
            if d < dist then
                dist = d
                nearest = part
            end
        end
    end
    return nearest
end

-- دالة للتحرك نحو الهدف
local function moveTo(target)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid and target then
        humanoid:MoveTo(target.Position)
        humanoid.MoveToFinished:Wait()
    end
end

-- الحلقة الرئيسية للأوتو فارم
while task.wait(2) do
    local box = getNearestBox()
    if box then
        moveTo(box)
        fireproximityprompt(box.ProximityPrompt) -- أخذ الصندوق
        task.wait(1)
        
        local circle = getBlueCircle()
        if circle then
            moveTo(circle)
            task.wait(3) -- وقت الانتظار لتكديس الصندوق
        end
    end
end
