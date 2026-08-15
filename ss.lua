--!strict


local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player and player:WaitForChild("PlayerGui") or nil

if not playerGui then
    error("PlayerGui was not found.")
end

local function make(className, props)
    local instance = Instance.new(className)
    for key, value in pairs(props or {}) do
        if key ~= "Parent" then
            instance[key] = value
        end
    end
    return instance
end

local function padNumber(n)
    return tostring(n)
end

local function normalizeObfuscation(input)
    local output = input or ""

    output = output:gsub("0b([01]+)", function(value)
        return tostring(tonumber(value, 2))
    end)

    output = output:gsub("0x([0-9a-fA-F]+)", function(value)
        return tostring(tonumber(value, 16))
    end)

    output = output:gsub("x=%[%[1%]%=2,%[%[2%]%=x%]x%[3%]=x", "")
    output = output:gsub("y=%[%[1%]%=2,%[%[2%]%=y%]y%[3%]=y", "")
    output = output:gsub("w=%[%[1%]%=2,%[%[2%]%=w%]w%[3%]=w", "")
    output = output:gsub("u=%[%[1%]%=2,%[%[2%]%=u%]u%[3%]=u", "")
    output = output:gsub("h=%[%[1%]%=2,%[%[2%]%=h%]h%[3%]=h", "")
    output = output:gsub("q=%[%[1%]%=2,%[%[2%]%=q%]q%[3%]=q", "")
    output = output:gsub("l=%[%[1%]%=2,%[%[2%]%=l%]l%[3%]=l", "")
    output = output:gsub("c=%[%[1%]%=2,%[%[2%]%=c%]c%[3%]=c", "")

    return output
end

local function createDragBehavior(frame)
    local dragging = false
    local dragStart = nil
    local startPos = nil

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function createGui()
    local screenGui = make("ScreenGui", {
        Name = "ProbeX_Recover_GUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        Parent = playerGui,
    })

    local main = make("Frame", {
        Name = "Main",
        Parent = screenGui,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 630, 0, 450),
        BackgroundColor3 = Color3.fromRGB(16, 17, 26),
        BorderSizePixel = 0,
    })

    local corner = make("UICorner", { CornerRadius = UDim.new(0, 18), Parent = main })
    local stroke = make("UIStroke", { Thickness = 1, Color = Color3.fromRGB(96, 162, 255), Transparency = 0.2, Parent = main })

    local header = make("Frame", {
        Name = "Header",
        Parent = main,
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundColor3 = Color3.fromRGB(24, 27, 40),
        BorderSizePixel = 0,
    })

    local headerCorner = make("UICorner", { CornerRadius = UDim.new(0, 18), Parent = header })

    local title = make("TextLabel", {
        Name = "Title",
        Parent = header,
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        Text = "ProbeX Recovery",
        Font = Enum.Font.GothamBold,
        TextSize = 24,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local subtitle = make("TextLabel", {
        Name = "Subtitle",
        Parent = header,
        Size = UDim2.new(1, -30, 0, 20),
        Position = UDim2.new(0, 15, 0, 38),
        Text = "Luau-based deobfuscation view",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(170, 180, 220),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local closeButton = make("TextButton", {
        Name = "Close",
        Parent = header,
        Size = UDim2.new(0, 34, 0, 34),
        Position = UDim2.new(1, -42, 0.5, -17),
        Text = "X",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundColor3 = Color3.fromRGB(217, 71, 93),
        BorderSizePixel = 0,
    })
    make("UICorner", { CornerRadius = UDim.new(0, 12), Parent = closeButton })
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    local inputBox = make("TextBox", {
        Name = "InputBox",
        Parent = main,
        Position = UDim2.new(0, 20, 0, 100),
        Size = UDim2.new(1, -40, 0, 140),
        BackgroundColor3 = Color3.fromRGB(30, 32, 41),
        BorderSizePixel = 0,
        Text = "-- 67\nreturn({c=function(...)return{[1]={...},[0b10]=select(\"#\",...)}end,...})",
        Font = Enum.Font.Code,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(240, 240, 240),
        TextWrapped = true,
        MultiLine = true,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    })
    make("UICorner", { CornerRadius = UDim.new(0, 14), Parent = inputBox })
    make("UIStroke", { Thickness = 1, Color = Color3.fromRGB(74, 79, 100), Transparency = 0.2, Parent = inputBox })

    local outputBox = make("TextBox", {
        Name = "OutputBox",
        Parent = main,
        Position = UDim2.new(0, 20, 0, 270),
        Size = UDim2.new(1, -40, 0, 110),
        BackgroundColor3 = Color3.fromRGB(24, 26, 35),
        BorderSizePixel = 0,
        Text = "",
        Font = Enum.Font.Code,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(120, 230, 170),
        TextWrapped = true,
        MultiLine = true,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ReadOnly = true,
    })
    make("UICorner", { CornerRadius = UDim.new(0, 14), Parent = outputBox })
    make("UIStroke", { Thickness = 1, Color = Color3.fromRGB(74, 79, 100), Transparency = 0.2, Parent = outputBox })

    local statusLabel = make("TextLabel", {
        Name = "Status",
        Parent = main,
        Position = UDim2.new(0, 20, 0, 240),
        Size = UDim2.new(0, 220, 0, 20),
        BackgroundTransparency = 1,
        Text = "Ready",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(150, 210, 255),
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local decodeButton = make("TextButton", {
        Name = "Decode",
        Parent = main,
        Position = UDim2.new(1, -195, 1, -54),
        Size = UDim2.new(0, 120, 0, 34),
        Text = "Decode",
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundColor3 = Color3.fromRGB(73, 130, 255),
        BorderSizePixel = 0,
    })
    make("UICorner", { CornerRadius = UDim.new(0, 10), Parent = decodeButton })

    local exportButton = make("TextButton", {
        Name = "Export",
        Parent = main,
        Position = UDim2.new(1, -65, 1, -54),
        Size = UDim2.new(0, 120, 0, 34),
        Text = "Export",
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundColor3 = Color3.fromRGB(41, 182, 103),
        BorderSizePixel = 0,
    })
    make("UICorner", { CornerRadius = UDim.new(0, 10), Parent = exportButton })

    local function setStatus(text, color)
        statusLabel.Text = text
        statusLabel.TextColor3 = color or Color3.fromRGB(150, 210, 255)
    end

    decodeButton.MouseButton1Click:Connect(function()
        setStatus("Decoding...", Color3.fromRGB(255, 200, 100))
        local decoded = normalizeObfuscation(inputBox.Text)
        outputBox.Text = decoded
        setStatus("Decoded successfully", Color3.fromRGB(120, 230, 170))
    end)

    exportButton.MouseButton1Click:Connect(function()
        local text = outputBox.Text
        if text == "" then
            setStatus("Nothing to export", Color3.fromRGB(255, 140, 120))
            return
        end

        local exportFile = "ProbeX_Recovered.lua"
        if writefile then
            writefile(exportFile, text)
            setStatus("Exported to " .. exportFile, Color3.fromRGB(120, 230, 170))
        else
            setStatus("writefile unavailable", Color3.fromRGB(255, 140, 120))
        end
    end)

    local headerConnection
    createDragBehavior(main)

    return screenGui
end

local gui = createGui()
print("GUI created:", gui.Name)
