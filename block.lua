-- 1. Load Fluent Library & Addons
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- 2. Create Main Window
local Window = Fluent:CreateWindow({
    Title = "SAB KING LOADER V2 NEW",
    SubTitle = "by SAB KING Team",
    TabWidth = 150,
    Size = UDim2.fromOffset(540, 380),
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- 3. Create Tabs
local Tabs = {
    SAB = Window:AddTab({ Title = "BEST KING SAB", Icon = "flame" }),
    Duel = Window:AddTab({ Title = "BEST DUEL", Icon = "swords" }),
    Misc = Window:AddTab({ Title = "MISC", Icon = "box" }),
    Settings = Window:AddTab({ Title = "Settings & Community", Icon = "settings" })
}

----------------------------------------------------------------------
-- MOBILE FLOATING TOGGLE BUTTON (LOGO "K")
----------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "SABKingToggleGui"
ScreenGui.Parent = (game:GetService("CoreGui"):FindFirstChild("RobloxGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.ResetOnSpawn = false

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
ToggleButton.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "K"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 28
ToggleButton.Active = true
ToggleButton.Draggable = true

UICorner.CornerRadius = UDim.new(0.5, 0)
UICorner.Parent = ToggleButton

-- Toggle UI visibility when clicking the "K" button
ToggleButton.MouseButton1Click:Connect(function()
    if Window then
        Window:Minimize()
    end
end)

----------------------------------------------------------------------
-- TAB 1: BEST KING SAB SCRIPT
----------------------------------------------------------------------
Tabs.SAB:AddSection("Script List")

local SAB_Scripts = {
    ["Auto RNG machine beta"] = "https://pastebin.com/raw/vjAwx1jd",
    ["Chilin Auto Joiner"] = "https://pastebin.com/raw/Qv19kXGt",
    ["Best ALL hub"] = "https://pastebin.com/raw/90A03L8y",
    ["Gamma Auto Gift Code"] = "https://pastebin.com/raw/6DJnLV4H",
    ["Gift Code Snipe v1"] = "https://pastebin.com/raw/h15sLLSX",
    ["NEW Auto code Redemer"] = "https://pastebin.com/raw/h6v8HZaj",
    ["Gift Code Snipe v2"] = "https://pastebin.com/raw/2NzxTMZU",
    ["Amir hub Gift Code Snipe"] = "https://pastebin.com/raw/Am0pxziv",
    ["Anti Admin Panel"] = "https://pastebin.com/raw/kwucBwdW",
    ["FPS Booster"] = "https://pastebin.com/raw/Ng8mCw8A",
    ["Anti Bat"] = "https://pastebin.com/raw/a7zM4eAC",
    ["Fast Kick Rejoin"] = "https://pastebin.com/raw/xnPAfz2M",
    ["Worked Anti Ragdoll v1"] = "https://pastebin.com/raw/0bKbxNMv",
    ["Anti Die"] = "https://pastebin.com/raw/ZpNE636e",
    ["Auto Carry Speed"] = "https://pastebin.com/raw/EV3JZHtZ",
    ["Empty Map Finder"] = "https://pastebin.com/raw/1CeeY67A",
    ["Irish Hub V1.1"] = "https://pastebin.com/raw/HW6U98FR",
    ["Galaxy Ping Lagger"] = "https://pastebin.com/raw/crG7QHYF",
    ["ViolanceHub.CC"] = "https://pastebin.com/raw/c3U9pqfn",
    ["Auto Buy Carpet"] = "https://pastebin.com/raw/1vMhQL0U",
    ["Auto Grab V1"] = "https://pastebin.com/raw/Ncrn0NWs",
    ["Auto Steal + zeus gear"] = "https://pastebin.com/raw/Vt4QzvSX",
    ["Kanye Flash TP"] = "https://pastebin.com/raw/aG1ZZJau",
    ["FlashTP ice hub"] = "https://pastebin.com/raw/40vnSnnV",
    ["Nova FlashTP"] = "https://pastebin.com/raw/VmJEpDz1",
    ["Insta Reset"] = "https://pastebin.com/raw/tkUY2HJm",
    ["404 Auto Grab"] = "https://pastebin.com/raw/b6sir6sE"
}

local SAB_List = {}
for name, _ in pairs(SAB_Scripts) do
    table.insert(SAB_List, name)
end
table.sort(SAB_List)

local SelectedSAB = SAB_List[1]

local SABDropdown = Tabs.SAB:AddDropdown("SABSelector", {
    Title = "Select SAB Script",
    Values = SAB_List,
    Multi = false,
    Default = 1,
})

SABDropdown:OnChanged(function(Value)
    SelectedSAB = Value
end)

Tabs.SAB:AddButton({
    Title = "Execute Selected SAB Script",
    Description = "Run the chosen SAB script from the dropdown above",
    Callback = function()
        if SAB_Scripts[SelectedSAB] then
            Fluent:Notify({
                Title = "SAB Loader",
                Content = "Executing: " .. SelectedSAB,
                Duration = 3
            })
            task.spawn(function()
                loadstring(game:HttpGet(SAB_Scripts[SelectedSAB]))()
            end)
        end
    end
})

----------------------------------------------------------------------
-- TAB 2: BEST DUEL SCRIPT
----------------------------------------------------------------------
Tabs.Duel:AddSection("Script List")

local Duel_Scripts = {
    ["Larph Duel"] = "https://pastebin.com/raw/138HBiRK",
    ["Cryon Duel"] = "https://pastebin.com/raw/tZZk3wS7",
    ["Nail Hub Duel"] = "https://pastebin.com/raw/pMG73qbd",
    ["Five Duel"] = "https://pastebin.com/raw/cU3A8ERS",
    ["Crux Duel v3"] = "https://pastebin.com/raw/prDEZHJh",
    ["Crux Duel for Mobile"] = "https://pastebin.com/raw/nYuNj0MJ",
    ["Moon Duel"] = "https://pastebin.com/raw/pM6aVJHJ",
    ["OR.s Duel"] = "https://pastebin.com/raw/wgqE3MiN"
}

local Duel_List = {}
for name, _ in pairs(Duel_Scripts) do
    table.insert(Duel_List, name)
end
table.sort(Duel_List)

local SelectedDuel = Duel_List[1]

local DuelDropdown = Tabs.Duel:AddDropdown("DuelSelector", {
    Title = "Select Duel Script",
    Values = Duel_List,
    Multi = false,
    Default = 1,
})

DuelDropdown:OnChanged(function(Value)
    SelectedDuel = Value
end)

Tabs.Duel:AddButton({
    Title = "Execute Selected Duel Script",
    Description = "Run the chosen Duel script from the dropdown above",
    Callback = function()
        if Duel_Scripts[SelectedDuel] then
            Fluent:Notify({
                Title = "Duel Loader",
                Content = "Executing: " .. SelectedDuel,
                Duration = 3`
            })
            task.spawn(function()
                loadstring(game:HttpGet(Duel_Scripts[SelectedDuel]))()
            end)
        end
    end
})

----------------------------------------------------------------------
-- TAB 3: MISC SCRIPT
----------------------------------------------------------------------
Tabs.Misc:AddSection("Script List")

Tabs.Misc:AddButton({
    Title = "1. Best UGC Emote + Animation",
    Description = "Execute Emote & Animation GUI",
    Callback = function()
        Fluent:Notify({
            Title = "Misc Loader",
            Content = "Executing Emotes Script...",
            Duration = 3
        })
        task.spawn(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua"))()
        end)
    end
})

Tabs.Misc:AddButton({
    Title = "2. M7 ADMIN Script",
    Description = "Execute M7 Admin Loader",
    Callback = function()
        Fluent:Notify({
            Title = "Misc Loader",
            Content = "Executing M7 Admin...",
            Duration = 3
        })
        task.spawn(function()
            loadstring(game:HttpGet("https://mois7.xyz/loader"))()
        end)
    end
})

----------------------------------------------------------------------
-- TAB 4: SETTINGS & COMMUNITY DISCORD
----------------------------------------------------------------------
local DiscordLink = "https://discord.gg/ehfk7SdSTk"

Tabs.Settings:AddSection("Community")

Tabs.Settings:AddParagraph({
    Title = "Join Our Community!",
    Content = "Join our Discord server for more scripts, updates, and support:\n" .. DiscordLink
})

Tabs.Settings:AddButton({
    Title = "Title = "Copy Discord Invite Link",",
    Description = "Click to copy the Discord link to your clipboard",
    Callback = function()
        if setclipboard then
            setclipboard(DiscordLink)
            Fluent:Notify({
                Title = "Discord Link",
                Content = "Discord invite link copied to clipboard!",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Error",
                Content = "Your executor does not support clipboard copying.",
                Duration = 3
            })
        end
    end
})

-- UI Library Config & Settings Manager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

-- Welcome Notification
Fluent:Notify({
    Title = "SAB KING LOADER V2 NEW",
    Content = "Loader loaded successfully! Click the 'K' button to open/close menu.",
    Duration = 5
})

SaveManager:LoadAutoloadConfig()
