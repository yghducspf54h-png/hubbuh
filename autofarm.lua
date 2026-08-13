--!strict
--[[
    BlockSpin Fishing Automation
    Single-File Luau
    ============================
    GUI
    Auto Rod
    Auto Bait
    Auto Cast
    Auto Catch
    Rarity Detection
    Auto Sell
    Start / Stop
]]

--==================================================
-- SERVICES
--==================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Backpack = Player:WaitForChild("Backpack")

--==================================================
-- SETTINGS
--==================================================

local Settings = {
    AutoFarm = false,

    AutoEquipRod = true,
    AutoBait = true,
    AutoCast = true,
    AutoCatch = true,
    AutoSell = true,

    CatchDelay = 0.05,
    CastDelay = 0.5,
    RecastDelay = 0.4,
    SellDelay = 0.5,

    Keep = {
        Green = true,
        Blue = true,
        Purple = true,
        Gold = true,
        Red = true,
    },

    -- ألوان تقريبية للـFishing UI
    Colors = {
        Green = Color3.fromRGB(0, 255, 0),
        Blue = Color3.fromRGB(0, 120, 255),
        Purple = Color3.fromRGB(170, 0, 255),
        Gold = Color3.fromRGB(255, 200, 0),
        Red = Color3.fromRGB(255, 0, 0),
    },
}

--==================================================
-- STATE
--==================================================

local State = {
    Running = false,
    Busy = false,

    Character = nil :: Model?,
    Humanoid = nil :: Humanoid?,
    Root = nil :: BasePart?,

    Rod = nil :: Tool?,
    Bait = nil :: Tool?,

    LastFish = "Unknown",
    TotalFish = 0,

    Connections = {} :: {RBXScriptConnection},
}

--==================================================
-- UTILITIES
--==================================================

local function TrackConnection(connection: RBXScriptConnection)
    table.insert(State.Connections, connection)
    return connection
end

local function DisconnectAll()
    for _, connection in ipairs(State.Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    table.clear(State.Connections)
end

local function GetCharacter()
    local Character = Player.Character

    if not Character then
        return nil
    end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local Root = Character:FindFirstChild("HumanoidRootPart")

    if not Humanoid or not Root then
        return nil
    end

    State.Character = Character
    State.Humanoid = Humanoid
    State.Root = Root

    return Character
end

local function Lower(Text: string): string
    return string.lower(Text)
end

local function Contains(Text: string, Search: string): boolean
    return string.find(
        Lower(Text),
        Lower(Search),
        1,
        true
    ) ~= nil
end

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BlockSpinFishingGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(420, 520)
Main.Position = UDim2.new(0.5, -210, 0.5, -260)
Main.BackgroundColor3 = Color3.fromRGB(28, 29, 34)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(75, 77, 88)
Stroke.Thickness = 1
Stroke.Parent = Main

--==================================================
-- HEADER
--==================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 55)
Header.BackgroundColor3 = Color3.fromRGB(38, 40, 47)
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.fromOffset(18, 0)
Title.BackgroundTransparency = 1
Title.Text = "🎣 BlockSpin Fishing"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(35, 35)
Close.Position = UDim2.new(1, -45, 0, 10)
Close.BackgroundColor3 = Color3.fromRGB(190, 45, 45)
Close.Text = "X"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.TextSize = 18
Close.Font = Enum.Font.GothamBold
Close.Parent = Header

Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 8)

Close.MouseButton1Click:Connect(function()
    State.Running = false
    ScreenGui:Destroy()
end)

--==================================================
-- DRAG
--==================================================

local Dragging = false
local DragStart: Vector2
local StartPosition: UDim2

Header.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        DragStart = Input.Position
        StartPosition = Main.Position
    end
end)

Header.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = false
    end
end)

TrackConnection(
    UserInputService.InputChanged:Connect(function(Input)
        if not Dragging then
            return
        end

        if Input.UserInputType ~= Enum.UserInputType.MouseMovement then
            return
        end

        local Delta = Input.Position - DragStart

        Main.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )
    end)
)

--==================================================
-- CONTENT
--==================================================

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -70)
Content.Position = UDim2.fromOffset(10, 62)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.Parent = Content

local Padding = Instance.new("UIPadding")
Padding.PaddingLeft = UDim.new(0, 6)
Padding.PaddingRight = UDim.new(0, 6)
Padding.Parent = Content

--==================================================
-- STATUS
--==================================================

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -12, 0, 35)
Status.BackgroundColor3 = Color3.fromRGB(35, 37, 43)
Status.Text = "● STOPPED"
Status.TextColor3 = Color3.fromRGB(255, 80, 80)
Status.TextSize = 15
Status.Font = Enum.Font.GothamBold
Status.Parent = Content

Instance.new("UICorner", Status).CornerRadius = UDim.new(0, 8)

local FishStatus = Instance.new("TextLabel")
FishStatus.Size = UDim2.new(1, -12, 0, 35)
FishStatus.BackgroundColor3 = Color3.fromRGB(35, 37, 43)
FishStatus.Text = "Fish: 0 | Last: None"
FishStatus.TextColor3 = Color3.fromRGB(220, 220, 220)
FishStatus.TextSize = 14
FishStatus.Font = Enum.Font.Gotham
FishStatus.Parent = Content

Instance.new("UICorner", FishStatus).CornerRadius = UDim.new(0, 8)

--==================================================
-- BUTTON FACTORY
--==================================================

local function CreateToggle(
    Name: string,
    Initial: boolean,
    Callback: (boolean) -> ()
)
    local Button = Instance.new("TextButton")

    Button.Size = UDim2.new(1, -12, 0, 42)
    Button.BackgroundColor3 = Initial
        and Color3.fromRGB(25, 125, 50)
        or Color3.fromRGB(55, 57, 64)

    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.TextSize = 14
    Button.Font = Enum.Font.GothamBold
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Parent = Content

    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)

    local Enabled = Initial

    local function Refresh()
        Button.Text =
            "   " .. Name ..
            (Enabled and "                         ON"
                or "                         OFF")

        Button.BackgroundColor3 = Enabled
            and Color3.fromRGB(25, 125, 50)
            or Color3.fromRGB(55, 57, 64)
    end

    Refresh()

    Button.MouseButton1Click:Connect(function()
        Enabled = not Enabled
        Refresh()
        Callback(Enabled)
    end)

    return Button
end

local function CreateSection(Text: string)
    local Label = Instance.new("TextLabel")

    Label.Size = UDim2.new(1, -12, 0, 28)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Color3.fromRGB(150, 155, 170)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Content
end

--==================================================
-- MAIN TOGGLES
--==================================================

CreateSection("AUTOMATION")

CreateToggle(
    "Auto Farm",
    false,
    function(Value)
        State.Running = Value

        if Value then
            Status.Text = "● RUNNING"
            Status.TextColor3 = Color3.fromRGB(50, 255, 90)
        else
            Status.Text = "● STOPPED"
            Status.TextColor3 = Color3.fromRGB(255, 80, 80)
        end
    end
)

CreateToggle(
    "Auto Equip Rod",
    Settings.AutoEquipRod,
    function(Value)
        Settings.AutoEquipRod = Value
    end
)

CreateToggle(
    "Auto Bait",
    Settings.AutoBait,
    function(Value)
        Settings.AutoBait = Value
    end
)

CreateToggle(
    "Auto Cast",
    Settings.AutoCast,
    function(Value)
        Settings.AutoCast = Value
    end
)

CreateToggle(
    "Auto Catch",
    Settings.AutoCatch,
    function(Value)
        Settings.AutoCatch = Value
    end
)

CreateToggle(
    "Auto Sell",
    Settings.AutoSell,
    function(Value)
        Settings.AutoSell = Value
    end
)

--==================================================
-- RARITY
--==================================================

CreateSection("KEEP FISH")

local RarityButtons = {}

local function AddRarity(Name: string)
    RarityButtons[Name] = CreateToggle(
        "Keep " .. Name,
        Settings.Keep[Name],
        function(Value)
            Settings.Keep[Name] = Value
        end
    )
end

AddRarity("Green")
AddRarity("Blue")
AddRarity("Purple")
AddRarity("Gold")
AddRarity("Red")

--==================================================
-- ROD FINDER
--==================================================

local function FindRod(): Tool?
    GetCharacter()

    local Character = State.Character

    if Character then
        for _, Object in ipairs(Character:GetChildren()) do
            if Object:IsA("Tool") then
                local Name = Lower(Object.Name)

                if
                    Contains(Name, "rod")
                    or Contains(Name, "fishing")
                    or Contains(Name, "pole")
                then
                    return Object
                end
            end
        end
    end

    for _, Object in ipairs(Backpack:GetChildren()) do
        if Object:IsA("Tool") then
            local Name = Lower(Object.Name)

            if
                Contains(Name, "rod")
                or Contains(Name, "fishing")
                or Contains(Name, "pole")
            then
                return Object
            end
        end
    end

    return nil
end

local function EquipRod(): Tool?
    local Character = GetCharacter()

    if not Character then
        return nil
    end

    local Humanoid = State.Humanoid

    if not Humanoid then
        return nil
    end

    local Rod = FindRod()

    if not Rod then
        return nil
    end

    if Rod.Parent ~= Character then
        Humanoid:EquipTool(Rod)
        task.wait(0.2)
    end

    State.Rod = Rod

    return Rod
end

--==================================================
-- BAIT FINDER
--==================================================

local function FindBait(): Tool?
    local Character = State.Character

    if Character then
        for _, Object in ipairs(Character:GetChildren()) do
            if Object:IsA("Tool") then
                local Name = Lower(Object.Name)

                if
                    Contains(Name, "bait")
                    or Contains(Name, "worm")
                    or Contains(Name, "prawn")
                then
                    return Object
                end
            end
        end
    end

    for _, Object in ipairs(Backpack:GetChildren()) do
        if Object:IsA("Tool") then
            local Name = Lower(Object.Name)

            if
                Contains(Name, "bait")
                or Contains(Name, "worm")
                or Contains(Name, "prawn")
            then
                return Object
            end
        end
    end

    return nil
end

--==================================================
-- BAIT
--==================================================

local function AttachBait()
    local Rod = State.Rod

    if not Rod then
        return false
    end

    local Bait = FindBait()

    if not Bait then
        return false
    end

    State.Bait = Bait

    -- دعم الأنظمة التي تستخدم Attributes
    if Rod:GetAttribute("Bait") == nil then
        pcall(function()
            Rod:SetAttribute("Bait", Bait.Name)
        end)
    end

    -- إذا كان الـBait نفسه يحتاج Activate
    if Bait.Parent == State.Character then
        pcall(function()
            Bait:Activate()
        end)
    end

    return true
end

--==================================================
-- CAST
--==================================================

local function CastRod()
    local Rod = State.Rod

    if not Rod then
        return false
    end

    pcall(function()
        Rod:Activate()
    end)

    return true
end

--==================================================
-- MINIGAME DETECTION
--==================================================

local function IsGreen(Color: Color3): boolean
    return
        Color.G > Color.R * 1.35
        and Color.G > Color.B * 1.15
        and Color.G > 0.35
end

local function FindFishingGui(): GuiObject?
    local Best: GuiObject? = nil

    for _, Object in ipairs(PlayerGui:GetDescendants()) do
        if Object:IsA("GuiObject") and Object.Visible then
            local Name = Lower(Object.Name)

            if
                Contains(Name, "fishing")
                or Contains(Name, "fish")
                or Contains(Name, "catch")
                or Contains(Name, "reel")
                or Contains(Name, "minigame")
            then
                Best = Object
            end
        end
    end

    return Best
end

--==================================================
-- GREEN TARGET
--==================================================

local function FindGreenTarget(): GuiObject?
    for _, Object in ipairs(PlayerGui:GetDescendants()) do
        if Object:IsA("GuiObject") and Object.Visible then

            local Color = Object.BackgroundColor3

            if IsGreen(Color) then
                local Size = Object.AbsoluteSize

                if Size.X > 15 and Size.Y > 5 then
                    return Object
                end
            end
        end
    end

    return nil
end

--==================================================
-- NEEDLE DETECTION
--==================================================

local function GetGuiCenter(Object: GuiObject): Vector2
    return Object.AbsolutePosition + Object.AbsoluteSize / 2
end

local function IsInsideTarget(
    Needle: GuiObject,
    Target: GuiObject
): boolean

    local NeedleCenter = GetGuiCenter(Needle)

    local Position = Target.AbsolutePosition
    local Size = Target.AbsoluteSize

    return
        NeedleCenter.X >= Position.X
        and NeedleCenter.X <= Position.X + Size.X
        and NeedleCenter.Y >= Position.Y
        and NeedleCenter.Y <= Position.Y + Size.Y
end

local function FindNeedle(Target: GuiObject): GuiObject?
    local TargetCenter = GetGuiCenter(Target)

    local Best: GuiObject? = nil
    local BestDistance = math.huge

    for _, Object in ipairs(PlayerGui:GetDescendants()) do
        if Object:IsA("GuiObject")
            and Object.Visible
            and Object ~= Target
        then
            local Center = GetGuiCenter(Object)

            local Distance = math.abs(
                Center.X - TargetCenter.X
            )

            if Distance < BestDistance
                and Object.AbsoluteSize.X <= 30
                and Object.AbsoluteSize.Y >= Target.AbsoluteSize.Y * 0.5
            then
                Best = Object
                BestDistance = Distance
            end
        end
    end

    return Best
end

--==================================================
-- CLICK MINIGAME
--==================================================

local function FindCatchButton(): GuiButton?
    for _, Object in ipairs(PlayerGui:GetDescendants()) do
        if Object:IsA("GuiButton") and Object.Visible then
            local Name = Lower(Object.Name)
            local Text = Lower(Object.Text)

            if
                Contains(Name, "catch")
                or Contains(Name, "reel")
                or Contains(Name, "click")
                or Contains(Text, "click")
                or Contains(Text, "catch")
            then
                return Object
            end
        end
    end

    return nil
end

local function AutoCatch(): boolean
    local Timeout = os.clock() + 15

    while State.Running and os.clock() < Timeout do
        local Target = FindGreenTarget()

        if Target then
            local Needle = FindNeedle(Target)

            if Needle and IsInsideTarget(Needle, Target) then
                local Button = FindCatchButton()

                if Button then
                    pcall(function()
                        Button:Activate()
                    end)

                    task.wait(Settings.CatchDelay)

                    return true
                end
            end
        end

        RunService.RenderStepped:Wait()
    end

    return false
end

--==================================================
-- RARITY DETECTION
--==================================================

local RarityNames = {
    "Red",
    "Gold",
    "Purple",
    "Blue",
    "Green",
}

local function DetectRarity(): string
    task.wait(0.2)

    -- أولاً نبحث عن نصوص الواجهة
    for _, Object in ipairs(PlayerGui:GetDescendants()) do
        if Object:IsA("TextLabel") or Object:IsA("TextButton") then
            if Object.Visible then
                local Text = Object.Text

                for _, Rarity in ipairs(RarityNames) do
                    if Contains(Text, Rarity) then
                        return Rarity
                    end
                end
            end
        end
    end

    -- ثانياً Attributes
    local Character = State.Character

    if Character then
        local Fish = Character:FindFirstChild("Fish")

        if Fish then
            local Rarity = Fish:GetAttribute("Rarity")

            if typeof(Rarity) == "string" then
                return Rarity
            end
        end
    end

    return "Unknown"
end

--==================================================
-- SELL
--==================================================

local function ShouldKeep(Rarity: string): boolean
    if Settings.Keep[Rarity] ~= nil then
        return Settings.Keep[Rarity]
    end

    return true
end

local function FindSellButton(): GuiButton?
    for _, Object in ipairs(PlayerGui:GetDescendants()) do
        if Object:IsA("GuiButton") and Object.Visible then
            local Name = Lower(Object.Name)
            local Text = Lower(Object.Text)

            if
                Contains(Name, "sell")
                or Contains(Text, "sell")
                or Contains(Text, "discard")
            then
                return Object
            end
        end
    end

    return nil
end

local function SellFish()
    local Button = FindSellButton()

    if Button then
        pcall(function()
            Button:Activate()
        end)

        task.wait(Settings.SellDelay)
    end
end

--==================================================
-- FISHING CYCLE
--==================================================

local function FishingCycle()
    if State.Busy then
        return
    end

    State.Busy = true

    -- Character
    if not GetCharacter() then
        State.Busy = false
        return
    end

    -- Rod
    if Settings.AutoEquipRod then
        EquipRod()
    end

    if not State.Rod then
        State.Busy = false
        return
    end

    -- Bait
    if Settings.AutoBait then
        AttachBait()
    end

    task.wait(Settings.RecastDelay)

    -- Cast
    if Settings.AutoCast then
        CastRod()
    end

    task.wait(Settings.CastDelay)

    -- Catch
    if Settings.AutoCatch then
        AutoCatch()
    end

    -- Rarity
    local Rarity = DetectRarity()

    State.LastFish = Rarity
    State.TotalFish += 1

    FishStatus.Text =
        "Fish: "
        .. tostring(State.TotalFish)
        .. " | Last: "
        .. Rarity

    -- Sell
    if Settings.AutoSell then
        if not ShouldKeep(Rarity) then
            SellFish()
        end
    end

    State.Busy = false
end

--==================================================
-- FARM LOOP
--==================================================

task.spawn(function()
    while ScreenGui.Parent do
        if State.Running then
            FishingCycle()
        end

        task.wait(0.1)
    end
end)

--==================================================
-- CHARACTER RESET
--==================================================

TrackConnection(
    Player.CharacterAdded:Connect(function()
        task.wait(1)

        State.Character = nil
        State.Humanoid = nil
        State.Root = nil
        State.Rod = nil
        State.Bait = nil

        GetCharacter()
    end)
)

--==================================================
-- INITIALIZE
--==================================================

GetCharacter()

print("[BlockSpin] Fishing GUI loaded.")
print("[BlockSpin] Ready.")
