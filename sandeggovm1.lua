--[[
    AUTO FAR1M ROUTE BUILDER
    Recorder + Path Editor
    For your own Roblox game

    Features:
    - Action recording
    - Separate path recording
    - Custom categories
    - Custom names
    - Position + rotation capture
    - Drag window
    - Resize window
    - Minimize
    - Undo
    - Delete / reorder
    - Lua export
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

--------------------------------------------------
-- DATA
--------------------------------------------------

local Route = {
    name = "AutoFarm_Main",
    steps = {},
}

local Categories = {
    "Start",
    "Buy",
    "Sell",
    "Interact",
    "Pickup",
    "Dropoff",
    "Wait",
    "Bank",
    "Custom",
}

local selectedCategory = "Buy"
local selectedStep = nil

local recordingPath = false
local pathPoints = {}

local undoStack = {}

--------------------------------------------------
-- HELPERS
--------------------------------------------------

local function getCharacter()
    return Player.Character
end

local function getRoot()
    local character = getCharacter()
    if not character then
        return nil
    end

    return character:FindFirstChild("HumanoidRootPart")
end

local function getPosition()
    local root = getRoot()

    if not root then
        return nil
    end

    return root.Position
end

local function getCFrame()
    local root = getRoot()

    if not root then
        return nil
    end

    return root.CFrame
end

local function cloneSteps()
    local copy = {}

    for i, step in ipairs(Route.steps) do
        copy[i] = table.clone(step)
    end

    return copy
end

local function saveUndo()
    table.insert(undoStack, cloneSteps())

    if #undoStack > 50 then
        table.remove(undoStack, 1)
    end
end

local function formatVector(v)
    return string.format(
        "%.2f, %.2f, %.2f",
        v.X,
        v.Y,
        v.Z
    )
end

--------------------------------------------------
-- GUI
--------------------------------------------------

local Gui = Instance.new("ScreenGui")
Gui.Name = "AutoFarmRouteBuilder"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = Player:WaitForChild("PlayerGui")

--------------------------------------------------
-- MAIN WINDOW
--------------------------------------------------

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(760, 540)
Main.Position = UDim2.new(0.5, -380, 0.5, -270)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
Main.BorderSizePixel = 0
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

--------------------------------------------------
-- HEADER
--------------------------------------------------

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 48)
Header.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -150, 1, 0)
Title.Position = UDim2.fromOffset(15, 0)
Title.BackgroundTransparency = 1
Title.Text = "AUTO FARM  •  ROUTE BUILDER"
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Status = Instance.new("TextLabel")
Status.Size = UDim2.fromOffset(120, 48)
Status.Position = UDim2.new(1, -215, 0, 0)
Status.BackgroundTransparency = 1
Status.Text = "● READY"
Status.TextColor3 = Color3.fromRGB(100, 220, 130)
Status.TextSize = 12
Status.Font = Enum.Font.GothamBold
Status.Parent = Header

--------------------------------------------------
-- HEADER BUTTONS
--------------------------------------------------

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.fromOffset(35, 35)
Minimize.Position = UDim2.new(1, -115, 0, 7)
Minimize.Text = "—"
Minimize.TextSize = 20
Minimize.Font = Enum.Font.GothamBold
Minimize.TextColor3 = Color3.new(1,1,1)
Minimize.BackgroundColor3 = Color3.fromRGB(45,45,52)
Minimize.BorderSizePixel = 0
Minimize.Parent = Header

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0,7)
MinCorner.Parent = Minimize

local Maximize = Instance.new("TextButton")
Maximize.Size = UDim2.fromOffset(35, 35)
Maximize.Position = UDim2.new(1, -75, 0, 7)
Maximize.Text = "□"
Maximize.TextSize = 17
Maximize.Font = Enum.Font.GothamBold
Maximize.TextColor3 = Color3.new(1,1,1)
Maximize.BackgroundColor3 = Color3.fromRGB(45,45,52)
Maximize.BorderSizePixel = 0
Maximize.Parent = Header

local MaxCorner = Instance.new("UICorner")
MaxCorner.CornerRadius = UDim.new(0,7)
MaxCorner.Parent = Maximize

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(35, 35)
Close.Position = UDim2.new(1, -35, 0, 7)
Close.Text = "×"
Close.TextSize = 20
Close.Font = Enum.Font.GothamBold
Close.TextColor3 = Color3.new(1,1,1)
Close.BackgroundColor3 = Color3.fromRGB(150, 45, 55)
Close.BorderSizePixel = 0
Close.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0,7)
CloseCorner.Parent = Close

--------------------------------------------------
-- CONTENT
--------------------------------------------------

local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(10, 58)
Content.Size = UDim2.new(1, -20, 1, -68)
Content.BackgroundTransparency = 1
Content.Parent = Main

--------------------------------------------------
-- LEFT PANEL
--------------------------------------------------

local Left = Instance.new("Frame")
Left.Size = UDim2.fromOffset(210, 1)
Left.SizeConstraint = Enum.SizeConstraint.RelativeYY
Left.BackgroundColor3 = Color3.fromRGB(25,25,30)
Left.BorderSizePixel = 0
Left.Parent = Content

-- We'll manually size left panel based on window width.
Left.Size = UDim2.new(0, 210, 1, 0)

local LeftCorner = Instance.new("UICorner")
LeftCorner.CornerRadius = UDim.new(0,8)
LeftCorner.Parent = Left

local LeftTitle = Instance.new("TextLabel")
LeftTitle.Size = UDim2.new(1, -20, 0, 35)
LeftTitle.Position = UDim2.fromOffset(10, 5)
LeftTitle.BackgroundTransparency = 1
LeftTitle.Text = "ROUTE STEPS"
LeftTitle.TextColor3 = Color3.fromRGB(180,180,190)
LeftTitle.Font = Enum.Font.GothamBold
LeftTitle.TextSize = 12
LeftTitle.TextXAlignment = Enum.TextXAlignment.Left
LeftTitle.Parent = Left

local StepList = Instance.new("ScrollingFrame")
StepList.Position = UDim2.fromOffset(8, 42)
StepList.Size = UDim2.new(1, -16, 1, -50)
StepList.BackgroundTransparency = 1
StepList.BorderSizePixel = 0
StepList.ScrollBarThickness = 4
StepList.CanvasSize = UDim2.new()
StepList.Parent = Left

local StepLayout = Instance.new("UIListLayout")
StepLayout.Padding = UDim.new(0, 5)
StepLayout.Parent = StepList

--------------------------------------------------
-- RIGHT PANEL
--------------------------------------------------

local Right = Instance.new("Frame")
Right.Position = UDim2.fromOffset(220, 0)
Right.Size = UDim2.new(1, -220, 1, 0)
Right.BackgroundColor3 = Color3.fromRGB(25,25,30)
Right.BorderSizePixel = 0
Right.Parent = Content

local RightCorner = Instance.new("UICorner")
RightCorner.CornerRadius = UDim.new(0,8)
RightCorner.Parent = Right

--------------------------------------------------
-- TAB BUTTONS
--------------------------------------------------

local ActionTab = Instance.new("TextButton")
ActionTab.Size = UDim2.new(0.5, -7, 0, 38)
ActionTab.Position = UDim2.fromOffset(8, 8)
ActionTab.Text = "ACTION"
ActionTab.Font = Enum.Font.GothamBold
ActionTab.TextSize = 12
ActionTab.TextColor3 = Color3.new(1,1,1)
ActionTab.BackgroundColor3 = Color3.fromRGB(55,95,180)
ActionTab.BorderSizePixel = 0
ActionTab.Parent = Right

local ActionCorner = Instance.new("UICorner")
ActionCorner.CornerRadius = UDim.new(0,7)
ActionCorner.Parent = ActionTab

local PathTab = Instance.new("TextButton")
PathTab.Size = UDim2.new(0.5, -7, 0, 38)
PathTab.Position = UDim2.new(0.5, 0, 0, 8)
PathTab.Text = "PATH"
PathTab.Font = Enum.Font.GothamBold
PathTab.TextSize = 12
PathTab.TextColor3 = Color3.new(1,1,1)
PathTab.BackgroundColor3 = Color3.fromRGB(45,45,52)
PathTab.BorderSizePixel = 0
PathTab.Parent = Right

local PathCorner = Instance.new("UICorner")
PathCorner.CornerRadius = UDim.new(0,7)
PathCorner.Parent = PathTab

--------------------------------------------------
-- ACTION PANEL
--------------------------------------------------

local ActionPanel = Instance.new("Frame")
ActionPanel.Position = UDim2.fromOffset(10, 58)
ActionPanel.Size = UDim2.new(1, -20, 1, -68)
ActionPanel.BackgroundTransparency = 1
ActionPanel.Parent = Right

local function makeLabel(parent, text, y)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 24)
    label.Position = UDim2.fromOffset(5, y)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(175,175,185)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

local function makeBox(parent, y, placeholder)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -10, 0, 38)
    box.Position = UDim2.fromOffset(5, y)
    box.BackgroundColor3 = Color3.fromRGB(35,35,42)
    box.BorderSizePixel = 0
    box.PlaceholderText = placeholder or ""
    box.PlaceholderColor3 = Color3.fromRGB(100,100,110)
    box.TextColor3 = Color3.new(1,1,1)
    box.TextSize = 12
    box.Font = Enum.Font.Gotham
    box.ClearTextOnFocus = false
    box.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,7)
    c.Parent = box

    return box
end

makeLabel(ActionPanel, "CATEGORY", 5)

local CategoryButton = Instance.new("TextButton")
CategoryButton.Size = UDim2.new(1, -10, 0, 38)
CategoryButton.Position = UDim2.fromOffset(5, 29)
CategoryButton.BackgroundColor3 = Color3.fromRGB(35,35,42)
CategoryButton.BorderSizePixel = 0
CategoryButton.Text = "Buy"
CategoryButton.TextColor3 = Color3.new(1,1,1)
CategoryButton.Font = Enum.Font.Gotham
CategoryButton.TextSize = 12
CategoryButton.Parent = ActionPanel

local CategoryCorner = Instance.new("UICorner")
CategoryCorner.CornerRadius = UDim.new(0,7)
CategoryCorner.Parent = CategoryButton

makeLabel(ActionPanel, "NAME", 77)
local NameBox = makeBox(ActionPanel, 101, "مثال: Buy_Burger")

local PositionInfo = makeLabel(ActionPanel, "CURRENT POSITION", 153)

local PositionValue = Instance.new("TextLabel")
PositionValue.Size = UDim2.new(1, -10, 0, 38)
PositionValue.Position = UDim2.fromOffset(5, 177)
PositionValue.BackgroundColor3 = Color3.fromRGB(30,30,36)
PositionValue.BorderSizePixel = 0
PositionValue.Text = "—"
PositionValue.TextColor3 = Color3.fromRGB(200,200,210)
PositionValue.Font = Enum.Font.Code
PositionValue.TextSize = 11
PositionValue.Parent = ActionPanel

local PosCorner = Instance.new("UICorner")
PosCorner.CornerRadius = UDim.new(0,7)
PosCorner.Parent = PositionValue

local SaveAction = Instance.new("TextButton")
SaveAction.Size = UDim2.new(1, -10, 0, 48)
SaveAction.Position = UDim2.fromOffset(5, 230)
SaveAction.BackgroundColor3 = Color3.fromRGB(55,150,90)
SaveAction.BorderSizePixel = 0
SaveAction.Text = "📍  تسجيل النقطة"
SaveAction.TextColor3 = Color3.new(1,1,1)
SaveAction.Font = Enum.Font.GothamBold
SaveAction.TextSize = 13
SaveAction.Parent = ActionPanel

local SaveCorner = Instance.new("UICorner")
SaveCorner.CornerRadius = UDim.new(0,8)
SaveCorner.Parent = SaveAction

local CustomCategory = makeBox(ActionPanel, 300, "اسم تصنيف جديد")

local AddCategory = Instance.new("TextButton")
AddCategory.Size = UDim2.new(1, -10, 0, 38)
AddCategory.Position = UDim2.fromOffset(5, 344)
AddCategory.BackgroundColor3 = Color3.fromRGB(50,50,58)
AddCategory.BorderSizePixel = 0
AddCategory.Text = "+ إضافة تصنيف"
AddCategory.TextColor3 = Color3.new(1,1,1)
AddCategory.Font = Enum.Font.GothamBold
AddCategory.TextSize = 11
AddCategory.Parent = ActionPanel

local AddCatCorner = Instance.new("UICorner")
AddCatCorner.CornerRadius = UDim.new(0,7)
AddCatCorner.Parent = AddCategory

--------------------------------------------------
-- CATEGORY POPUP
--------------------------------------------------

local CategoryPopup = Instance.new("Frame")
CategoryPopup.Visible = false
CategoryPopup.Position = UDim2.fromOffset(5, 67)
CategoryPopup.Size = UDim2.new(1, -10, 0, 180)
CategoryPopup.BackgroundColor3 = Color3.fromRGB(32,32,38)
CategoryPopup.BorderSizePixel = 0
CategoryPopup.ZIndex = 20
CategoryPopup.Parent = ActionPanel

local PopupCorner = Instance.new("UICorner")
PopupCorner.CornerRadius = UDim.new(0,8)
PopupCorner.Parent = CategoryPopup

local PopupList = Instance.new("UIListLayout")
PopupList.Padding = UDim.new(0,2)
PopupList.Parent = CategoryPopup

local function rebuildCategoryPopup()
    for _, child in ipairs(CategoryPopup:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    for _, category in ipairs(Categories) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -8, 0, 30)
        button.BackgroundColor3 = Color3.fromRGB(42,42,50)
        button.BorderSizePixel = 0
        button.Text = category
        button.TextColor3 = Color3.new(1,1,1)
        button.Font = Enum.Font.Gotham
        button.TextSize = 11
        button.ZIndex = 21
        button.Parent = CategoryPopup

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0,5)
        c.Parent = button

        button.MouseButton1Click:Connect(function()
            selectedCategory = category
            CategoryButton.Text = category
            CategoryPopup.Visible = false
        end)
    end
end

rebuildCategoryPopup()

CategoryButton.MouseButton1Click:Connect(function()
    CategoryPopup.Visible = not CategoryPopup.Visible
end)

AddCategory.MouseButton1Click:Connect(function()
    local value = CustomCategory.Text:gsub("^%s+", ""):gsub("%s+$", "")

    if value ~= "" then
        if not table.find(Categories, value) then
            table.insert(Categories, value)
            selectedCategory = value
            CategoryButton.Text = value
            rebuildCategoryPopup()
        end

        CustomCategory.Text = ""
    end
end)

--------------------------------------------------
-- PATH PANEL
--------------------------------------------------

local PathPanel = Instance.new("Frame")
PathPanel.Visible = false
PathPanel.Position = UDim2.fromOffset(10, 58)
PathPanel.Size = UDim2.new(1, -20, 1, -68)
PathPanel.BackgroundTransparency = 1
PathPanel.Parent = Right

makeLabel(PathPanel, "PATH NAME", 5)
local PathNameBox = makeBox(PathPanel, 29, "مثال: To_Sell")

local PathStatus = Instance.new("TextLabel")
PathStatus.Size = UDim2.new(1, -10, 0, 45)
PathStatus.Position = UDim2.fromOffset(5, 80)
PathStatus.BackgroundColor3 = Color3.fromRGB(30,30,36)
PathStatus.BorderSizePixel = 0
PathStatus.Text = "المسار غير مسجل"
PathStatus.TextColor3 = Color3.fromRGB(180,180,190)
PathStatus.Font = Enum.Font.Gotham
PathStatus.TextSize = 12
PathStatus.Parent = PathPanel

local PathStatusCorner = Instance.new("UICorner")
PathStatusCorner.CornerRadius = UDim.new(0,7)
PathStatusCorner.Parent = PathStatus

local StartPath = Instance.new("TextButton")
StartPath.Size = UDim2.new(1, -10, 0, 45)
StartPath.Position = UDim2.fromOffset(5, 140)
StartPath.BackgroundColor3 = Color3.fromRGB(55,95,180)
StartPath.BorderSizePixel = 0
StartPath.Text = "▶  بدء تسجيل المسار"
StartPath.TextColor3 = Color3.new(1,1,1)
StartPath.Font = Enum.Font.GothamBold
StartPath.TextSize = 12
StartPath.Parent = PathPanel

local StartPathCorner = Instance.new("UICorner")
StartPathCorner.CornerRadius = UDim.new(0,7)
StartPathCorner.Parent = StartPath

local AddPathPoint = Instance.new("TextButton")
AddPathPoint.Size = UDim2.new(1, -10, 0, 45)
AddPathPoint.Position = UDim2.fromOffset(5, 195)
AddPathPoint.BackgroundColor3 = Color3.fromRGB(50,130,80)
AddPathPoint.BorderSizePixel = 0
AddPathPoint.Text = "📍  تسجيل نقطة مسار"
AddPathPoint.TextColor3 = Color3.new(1,1,1)
AddPathPoint.Font = Enum.Font.GothamBold
AddPathPoint.TextSize = 12
AddPathPoint.Visible = false
AddPathPoint.Parent = PathPanel

local AddPathCorner = Instance.new("UICorner")
AddPathCorner.CornerRadius = UDim.new(0,7)
AddPathCorner.Parent = AddPathPoint

local FinishPath = Instance.new("TextButton")
FinishPath.Size = UDim2.new(1, -10, 0, 45)
FinishPath.Position = UDim2.fromOffset(5, 250)
FinishPath.BackgroundColor3 = Color3.fromRGB(150,70,60)
FinishPath.BorderSizePixel = 0
FinishPath.Text = "■  إنهاء المسار"
FinishPath.TextColor3 = Color3.new(1,1,1)
FinishPath.Font = Enum.Font.GothamBold
FinishPath.TextSize = 12
FinishPath.Visible = false
FinishPath.Parent = PathPanel

local FinishCorner = Instance.new("UICorner")
FinishCorner.CornerRadius = UDim.new(0,7)
FinishCorner.Parent = FinishPath

--------------------------------------------------
-- STEP LIST REFRESH
--------------------------------------------------

local function refreshSteps()
    for _, child in ipairs(StepList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    for index, step in ipairs(Route.steps) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -4, 0, 52)
        button.BackgroundColor3 =
            selectedStep == index
            and Color3.fromRGB(50,80,130)
            or Color3.fromRGB(34,34,41)

        button.BorderSizePixel = 0
        button.Text = string.format(
            "%02d   %s\n       %s",
            index,
            step.category or step.type or "Path",
            step.name or "Unnamed"
        )

        button.TextColor3 = Color3.new(1,1,1)
        button.TextSize = 11
        button.Font = Enum.Font.Gotham
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.Parent = StepList

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0,6)
        c.Parent = button

        button.MouseButton1Click:Connect(function()
            selectedStep = index
            refreshSteps()
        end)
    end

    StepList.CanvasSize = UDim2.fromOffset(
        0,
        StepLayout.AbsoluteContentSize.Y + 10
    )
end

--------------------------------------------------
-- RECORD ACTION
--------------------------------------------------

SaveAction.MouseButton1Click:Connect(function()
    local cf = getCFrame()

    if not cf then
        Status.Text = "● NO CHARACTER"
        return
    end

    local name = NameBox.Text:gsub("^%s+", ""):gsub("%s+$", "")

    if name == "" then
        name = selectedCategory .. "_" .. tostring(#Route.steps + 1)
    end

    saveUndo()

    table.insert(Route.steps, {
        type = "Action",
        category = selectedCategory,
        name = name,
        position = cf.Position,
        rotation = cf - cf.Position,
        order = #Route.steps + 1,
    })

    NameBox.Text = ""

    selectedStep = #Route.steps

    Status.Text = "● SAVED"

    refreshSteps()
end)

--------------------------------------------------
-- PATH RECORDING
--------------------------------------------------

local function updatePathUI()
    if recordingPath then
        PathStatus.Text = string.format(
            "● تسجيل المسار الآن\nالنقاط المسجلة: %d",
            #pathPoints
        )

        StartPath.Visible = false
        AddPathPoint.Visible = true
        FinishPath.Visible = true

        Status.Text = "● PATH RECORDING"
    else
        PathStatus.Text = "المسار غير مسجل"

        StartPath.Visible = true
        AddPathPoint.Visible = false
        FinishPath.Visible = false
    end
end

StartPath.MouseButton1Click:Connect(function()
    if recordingPath then
        return
    end

    pathPoints = {}
    recordingPath = true

    updatePathUI()
end)

AddPathPoint.MouseButton1Click:Connect(function()
    if not recordingPath then
        return
    end

    local cf = getCFrame()

    if not cf then
        return
    end

    table.insert(pathPoints, {
        position = cf.Position,
        rotation = cf - cf.Position,
    })

    updatePathUI()
end)

FinishPath.MouseButton1Click:Connect(function()
    if not recordingPath then
        return
    end

    if #pathPoints == 0 then
        recordingPath = false
        updatePathUI()
        return
    end

    local name = PathNameBox.Text:gsub("^%s+", ""):gsub("%s+$", "")

    if name == "" then
        name = "Path_" .. tostring(#Route.steps + 1)
    end

    saveUndo()

    table.insert(Route.steps, {
        type = "Path",
        category = "Path",
        name = name,
        points = table.clone(pathPoints),
        order = #Route.steps + 1,
    })

    selectedStep = #Route.steps

    pathPoints = {}
    recordingPath = false

    PathNameBox.Text = ""

    Status.Text = "● PATH SAVED"

    updatePathUI()
    refreshSteps()
end)

--------------------------------------------------
-- TABS
--------------------------------------------------

ActionTab.MouseButton1Click:Connect(function()
    ActionPanel.Visible = true
    PathPanel.Visible = false

    ActionTab.BackgroundColor3 = Color3.fromRGB(55,95,180)
    PathTab.BackgroundColor3 = Color3.fromRGB(45,45,52)
end)

PathTab.MouseButton1Click:Connect(function()
    ActionPanel.Visible = false
    PathPanel.Visible = true

    ActionTab.BackgroundColor3 = Color3.fromRGB(45,45,52)
    PathTab.BackgroundColor3 = Color3.fromRGB(55,95,180)
end)

--------------------------------------------------
-- DELETE SELECTED
--------------------------------------------------

local DeleteButton = Instance.new("TextButton")
DeleteButton.Size = UDim2.fromOffset(100, 35)
DeleteButton.Position = UDim2.new(0, 225, 1, -43)
DeleteButton.BackgroundColor3 = Color3.fromRGB(135,50,55)
DeleteButton.BorderSizePixel = 0
DeleteButton.Text = "حذف المحدد"
DeleteButton.TextColor3 = Color3.new(1,1,1)
DeleteButton.Font = Enum.Font.GothamBold
DeleteButton.TextSize = 10
DeleteButton.Parent = Content

local DeleteCorner = Instance.new("UICorner")
DeleteCorner.CornerRadius = UDim.new(0,6)
DeleteCorner.Parent = DeleteButton

DeleteButton.MouseButton1Click:Connect(function()
    if not selectedStep then
        return
    end

    if not Route.steps[selectedStep] then
        selectedStep = nil
        return
    end

    saveUndo()

    table.remove(Route.steps, selectedStep)

    selectedStep = nil

    for i, step in ipairs(Route.steps) do
        step.order = i
    end

    refreshSteps()
end)

--------------------------------------------------
-- UNDO
--------------------------------------------------

local UndoButton = Instance.new("TextButton")
UndoButton.Size = UDim2.fromOffset(80, 35)
UndoButton.Position = UDim2.new(0, 330, 1, -43)
UndoButton.BackgroundColor3 = Color3.fromRGB(45,45,52)
UndoButton.BorderSizePixel = 0
UndoButton.Text = "↶ Undo"
UndoButton.TextColor3 = Color3.new(1,1,1)
UndoButton.Font = Enum.Font.GothamBold
UndoButton.TextSize = 10
UndoButton.Parent = Content

local UndoCorner = Instance.new("UICorner")
UndoCorner.CornerRadius = UDim.new(0,6)
UndoCorner.Parent = UndoButton

UndoButton.MouseButton1Click:Connect(function()
    local previous = table.remove(undoStack)

    if not previous then
        return
    end

    Route.steps = previous
    selectedStep = nil

    refreshSteps()

    Status.Text = "● UNDO"
end)

--------------------------------------------------
-- EXPORT WINDOW
--------------------------------------------------

local ExportWindow = Instance.new("Frame")
ExportWindow.Name = "ExportWindow"
ExportWindow.Visible = false
ExportWindow.Size = UDim2.fromOffset(680, 480)
ExportWindow.Position = UDim2.new(0.5, -340, 0.5, -240)
ExportWindow.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
ExportWindow.BorderSizePixel = 0
ExportWindow.ZIndex = 50
ExportWindow.Parent = Gui

local ExportCorner = Instance.new("UICorner")
ExportCorner.CornerRadius = UDim.new(0, 10)
ExportCorner.Parent = ExportWindow

--------------------------------------------------
-- EXPORT HEADER
--------------------------------------------------

local ExportHeader = Instance.new("Frame")
ExportHeader.Size = UDim2.new(1, 0, 0, 45)
ExportHeader.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
ExportHeader.BorderSizePixel = 0
ExportHeader.ZIndex = 51
ExportHeader.Parent = ExportWindow

local ExportHeaderCorner = Instance.new("UICorner")
ExportHeaderCorner.CornerRadius = UDim.new(0, 10)
ExportHeaderCorner.Parent = ExportHeader

local ExportTitle = Instance.new("TextLabel")
ExportTitle.Size = UDim2.new(1, -60, 1, 0)
ExportTitle.Position = UDim2.fromOffset(15, 0)
ExportTitle.BackgroundTransparency = 1
ExportTitle.Text = "EXPORT LUA"
ExportTitle.TextColor3 = Color3.fromRGB(240, 240, 245)
ExportTitle.Font = Enum.Font.GothamBold
ExportTitle.TextSize = 14
ExportTitle.TextXAlignment = Enum.TextXAlignment.Left
ExportTitle.ZIndex = 52
ExportTitle.Parent = ExportHeader

local ExportClose = Instance.new("TextButton")
ExportClose.Size = UDim2.fromOffset(35, 35)
ExportClose.Position = UDim2.new(1, -43, 0, 5)
ExportClose.BackgroundColor3 = Color3.fromRGB(150, 45, 55)
ExportClose.BorderSizePixel = 0
ExportClose.Text = "×"
ExportClose.TextColor3 = Color3.new(1, 1, 1)
ExportClose.Font = Enum.Font.GothamBold
ExportClose.TextSize = 20
ExportClose.ZIndex = 52
ExportClose.Parent = ExportHeader

local ExportCloseCorner = Instance.new("UICorner")
ExportCloseCorner.CornerRadius = UDim.new(0, 7)
ExportCloseCorner.Parent = ExportClose

--------------------------------------------------
-- CODE BOX
--------------------------------------------------

local ExportCode = Instance.new("TextBox")
ExportCode.Size = UDim2.new(1, -30, 1, -105)
ExportCode.Position = UDim2.fromOffset(15, 55)
ExportCode.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
ExportCode.BorderSizePixel = 0
ExportCode.Text = ""
ExportCode.TextColor3 = Color3.fromRGB(220, 220, 225)
ExportCode.PlaceholderText = "Lua export will appear here..."
ExportCode.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
ExportCode.Font = Enum.Font.Code
ExportCode.TextSize = 12
ExportCode.TextXAlignment = Enum.TextXAlignment.Left
ExportCode.TextYAlignment = Enum.TextYAlignment.Top
ExportCode.MultiLine = true
ExportCode.ClearTextOnFocus = false
ExportCode.TextEditable = true
ExportCode.ZIndex = 51
ExportCode.Parent = ExportWindow

local ExportCodeCorner = Instance.new("UICorner")
ExportCodeCorner.CornerRadius = UDim.new(0, 7)
ExportCodeCorner.Parent = ExportCode

--------------------------------------------------
-- CLOSE BUTTON
--------------------------------------------------

local ExportCloseBottom = Instance.new("TextButton")
ExportCloseBottom.Size = UDim2.fromOffset(100, 35)
ExportCloseBottom.Position = UDim2.new(1, -115, 1, -45)
ExportCloseBottom.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
ExportCloseBottom.BorderSizePixel = 0
ExportCloseBottom.Text = "Close"
ExportCloseBottom.TextColor3 = Color3.new(1, 1, 1)
ExportCloseBottom.Font = Enum.Font.GothamBold
ExportCloseBottom.TextSize = 11
ExportCloseBottom.ZIndex = 51
ExportCloseBottom.Parent = ExportWindow

local ExportBottomCorner = Instance.new("UICorner")
ExportBottomCorner.CornerRadius = UDim.new(0, 7)
ExportBottomCorner.Parent = ExportCloseBottom

--------------------------------------------------
-- EXPORT FUNCTION
--------------------------------------------------

local function buildExport()
    local export = {}

    table.insert(export, "-- AUTO FARM ROUTE")
    table.insert(export, "-- Generated by Auto Farm Route Builder")
    table.insert(export, "")
    table.insert(export, "local Route = {")

    for index, step in ipairs(Route.steps) do
        table.insert(export, "    [" .. index .. "] = {")

        table.insert(
            export,
            "        type = " .. serialize(step.type) .. ","
        )

        table.insert(
            export,
            "        category = " .. serialize(step.category) .. ","
        )

        table.insert(
            export,
            "        name = " .. serialize(step.name) .. ","
        )

        if step.position then
            table.insert(
                export,
                "        position = " ..
                serialize(step.position) ..
                ","
            )
        end

        if step.rotation then
            table.insert(
                export,
                "        rotation = " ..
                serialize(step.rotation) ..
                ","
            )
        end

        if step.points then
            table.insert(
                export,
                "        points = " ..
                serialize(step.points, 2) ..
                ","
            )
        end

        table.insert(export, "    },")
    end

    table.insert(export, "}")
    table.insert(export, "")
    table.insert(export, "return Route")

    return table.concat(export, "\n")
end

--------------------------------------------------
-- EXPORT BUTTON
--------------------------------------------------

ExportButton.MouseButton1Click:Connect(function()
    local code = buildExport()

    ExportCode.Text = code
    ExportWindow.Visible = true

    Status.Text = "● EXPORT READY"
end)

--------------------------------------------------
-- CLOSE EXPORT WINDOW
--------------------------------------------------

ExportClose.MouseButton1Click:Connect(function()
    ExportWindow.Visible = false
end)

ExportCloseBottom.MouseButton1Click:Connect(function()
    ExportWindow.Visible = false
end)

--------------------------------------------------
-- DRAG EXPORT WINDOW
--------------------------------------------------

local exportDragging = false
local exportDragStart
local exportStartPosition

ExportHeader.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        exportDragging = true
        exportDragStart = input.Position
        exportStartPosition = ExportWindow.Position
    end
end)

ExportHeader.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        exportDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not exportDragging then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local delta = input.Position - exportDragStart

    ExportWindow.Position = UDim2.new(
        exportStartPosition.X.Scale,
        exportStartPosition.X.Offset + delta.X,
        exportStartPosition.Y.Scale,
        exportStartPosition.Y.Offset + delta.Y
    )
end)

--------------------------------------------------
-- LIVE POSITION
--------------------------------------------------

task.spawn(function()
    while Gui.Parent do
        local pos = getPosition()

        if pos then
            PositionValue.Text = formatVector(pos)
        else
            PositionValue.Text = "—"
        end

        task.wait(0.1)
    end
end)

--------------------------------------------------
-- DRAG WINDOW
--------------------------------------------------

local dragging = false
local dragStart
local startPosition

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
    end
end)

Header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local delta = input.Position - dragStart

    Main.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )
end)

--------------------------------------------------
-- MINIMIZE
--------------------------------------------------

local minimized = false

Minimize.MouseButton1Click:Connect(function()
    minimized = not minimized

    Content.Visible = not minimized

    if minimized then
        Main.Size = UDim2.fromOffset(
            Main.Size.X.Offset,
            48
        )
    else
        Main.Size = UDim2.fromOffset(
            760,
            540
        )
    end
end)

--------------------------------------------------
-- MAXIMIZE / RESTORE
--------------------------------------------------

local maximized = false

Maximize.MouseButton1Click:Connect(function()
    maximized = not maximized

    if maximized then
        Main.Size = UDim2.new(0.9, 0, 0.85, 0)
        Main.Position = UDim2.new(0.05, 0, 0.075, 0)
    else
        Main.Size = UDim2.fromOffset(760, 540)
        Main.Position = UDim2.new(0.5, -380, 0.5, -270)
    end
end)

--------------------------------------------------
-- CLOSE
--------------------------------------------------

Close.MouseButton1Click:Connect(function()
    Gui:Destroy()
end)

--------------------------------------------------
-- RESIZE HANDLE
--------------------------------------------------

local ResizeHandle = Instance.new("TextButton")
ResizeHandle.Size = UDim2.fromOffset(18, 18)
ResizeHandle.Position = UDim2.new(1, -18, 1, -18)
ResizeHandle.BackgroundTransparency = 1
ResizeHandle.Text = "◢"
ResizeHandle.TextColor3 = Color3.fromRGB(130,130,140)
ResizeHandle.TextSize = 12
ResizeHandle.Parent = Main

local resizing = false
local resizeStart
local resizeSize

ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        resizing = true
        resizeStart = input.Position
        resizeSize = Main.AbsoluteSize
    end
end)

ResizeHandle.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        resizing = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not resizing then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local delta = input.Position - resizeStart

    local width = math.max(600, resizeSize.X + delta.X)
    local height = math.max(420, resizeSize.Y + delta.Y)

    Main.Size = UDim2.fromOffset(width, height)
end)

--------------------------------------------------
-- INITIALIZE
--------------------------------------------------

refreshSteps()
updatePathUI()

print("Auto Farm Route Builder loaded.")
