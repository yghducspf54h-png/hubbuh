-- ========================================================
-- Skip Bad Fish GUI & Webhook Logger (Luau Source)
-- ========================================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- حذف الواجهة القديمة إن وجدت
if PlayerGui:FindFirstChild("SkipBadFishGui") then
    PlayerGui.SkipBadFishGui:Destroy()
end

-- 1. الإعدادات وقائمة الأسماك
local Settings = {
    GlobalSkip = true,
    WebhookURL = "",
    FishList = {
        ["Bass"]          = { Skip = true,  Webhook = false, Color = Color3.fromRGB(200, 200, 200) },
        ["Perch"]         = { Skip = true,  Webhook = false, Color = Color3.fromRGB(200, 200, 200) },
        ["Salmon"]        = { Skip = true,  Webhook = false, Color = Color3.fromRGB(200, 200, 200) },
        ["Northern Pike"] = { Skip = true,  Webhook = false, Color = Color3.fromRGB(0, 255, 100) },
        ["Dolphinfish"]   = { Skip = true,  Webhook = false, Color = Color3.fromRGB(0, 255, 100) },
        ["Coelacanth"]    = { Skip = true,  Webhook = false, Color = Color3.fromRGB(0, 150, 255) },
        ["Tuna"]          = { Skip = true,  Webhook = false, Color = Color3.fromRGB(200, 50, 255) },
        ["Sailfish"]      = { Skip = true,  Webhook = false, Color = Color3.fromRGB(255, 200, 0) },
        ["Marlin"]        = { Skip = true,  Webhook = false, Color = Color3.fromRGB(255, 50, 50) },
    }
}

-- 2. دالة إرسال الـ Webhook إلى Discord
local function sendWebhook(fishName)
    if Settings.WebhookURL == "" or not Settings.WebhookURL:find("http") then return end
    
    local request = (syn and syn.request) or (http and http.request) or http_request or request
    if not request then return end
    
    local payload = {
        ["content"] = "",
        ["embeds"] = {{
            ["title"] = "🎣 Caught Fish Notification!",
            ["description"] = "Caught Fish: **" .. fishName .. "**",
            ["color"] = 65280,
            ["footer"] = { ["text"] = "Skip Bad Fish System" }
        }}
    }
    
    pcall(function()
        request({
            Url = Settings.WebhookURL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload)
        })
    end)
end

-- 3. بناء واجهة المستخدم (GUI)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SkipBadFishGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 480)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -240)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(130, 0, 0)
header.Text = "تصفية الأسماك الخايسة/ skip bad fish"
header.TextColor3 = Color3.fromRGB(255, 255, 255)
header.Font = Enum.Font.GothamBold
header.TextSize = 14
header.Parent = mainFrame

local webhookInput = Instance.new("TextBox")
webhookInput.Size = UDim2.new(0.9, 0, 0, 30)
webhookInput.Position = UDim2.new(0.05, 0, 0, 48)
webhookInput.PlaceholderText = "Paste Webhook URL here..."
webhookInput.Text = ""
webhookInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
webhookInput.TextColor3 = Color3.fromRGB(255, 255, 255)
webhookInput.Font = Enum.Font.Gotham
webhookInput.TextSize = 12
webhookInput.Parent = mainFrame

local saveWebhookBtn = Instance.new("TextButton")
saveWebhookBtn.Size = UDim2.new(0.9, 0, 0, 30)
saveWebhookBtn.Position = UDim2.new(0.05, 0, 0, 84)
saveWebhookBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 0)
saveWebhookBtn.Text = "Save Webhook"
saveWebhookBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveWebhookBtn.Font = Enum.Font.GothamBold
saveWebhookBtn.TextSize = 13
saveWebhookBtn.Parent = mainFrame

saveWebhookBtn.MouseButton1Click:Connect(function()
    Settings.WebhookURL = webhookInput.Text
    saveWebhookBtn.Text = "Webhook Saved!"
    task.wait(1.5)
    saveWebhookBtn.Text = "Save Webhook"
end)

local globalSkipBtn = Instance.new("TextButton")
globalSkipBtn.Size = UDim2.new(0.9, 0, 0, 32)
globalSkipBtn.Position = UDim2.new(0.05, 0, 0, 120)
globalSkipBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
globalSkipBtn.Text = "Skip / تخطي: ON"
globalSkipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
globalSkipBtn.Font = Enum.Font.GothamBold
globalSkipBtn.TextSize = 14
globalSkipBtn.Parent = mainFrame

globalSkipBtn.MouseButton1Click:Connect(function()
    Settings.GlobalSkip = not Settings.GlobalSkip
    globalSkipBtn.Text = Settings.GlobalSkip and "Skip / تخطي: ON" or "Skip / تخطي: OFF"
    globalSkipBtn.BackgroundColor3 = Settings.GlobalSkip and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(60, 60, 60)
end)

-- قائمة التمرير للأسماك (Scrolling Frame)
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(0.9, 0, 0, 310)
scrollFrame.Position = UDim2.new(0.05, 0, 0, 160)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 4
scrollFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = scrollFrame
listLayout.Padding = UDim.new(0, 6)

-- إضافة أزرار كل سمكة
for fishName, data in pairs(Settings.FishList) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundTransparency = 1
    row.Parent = scrollFrame
    
    local fishBtn = Instance.new("TextButton")
    fishBtn.Size = UDim2.new(0.68, 0, 1, 0)
    fishBtn.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
    fishBtn.Text = fishName .. ": ON"
    fishBtn.TextColor3 = data.Color
    fishBtn.Font = Enum.Font.GothamBold
    fishBtn.TextSize = 13
    fishBtn.Parent = row
    
    local webhookBtn = Instance.new("TextButton")
    webhookBtn.Size = UDim2.new(0.3, 0, 1, 0)
    webhookBtn.Position = UDim2.new(0.7, 0, 0, 0)
    webhookBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 220)
    webhookBtn.Text = "🔔 Webhook"
    webhookBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    webhookBtn.Font = Enum.Font.GothamBold
    webhookBtn.TextSize = 11
    webhookBtn.Parent = row

    -- أحداث الضغط على أزرار الأسماك
    fishBtn.MouseButton1Click:Connect(function()
        data.Skip = not data.Skip
        fishBtn.Text = fishName .. (data.Skip and ": ON" or ": OFF")
        fishBtn.BackgroundColor3 = data.Skip and Color3.fromRGB(140, 0, 0) or Color3.fromRGB(50, 50, 50)
    end)
    
    webhookBtn.MouseButton1Click:Connect(function()
        data.Webhook = not data.Webhook
        webhookBtn.BackgroundColor3 = data.Webhook and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(0, 110, 220)
    end)
end
