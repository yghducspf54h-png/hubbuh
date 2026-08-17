-- ==========================================================
-- [!] سكربت الاستغلال والتحكم الشامل والمطور لأقصى حد (MAX UI)
-- ==========================================================
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- إزالة أي واجهة قديمة لمنع التكرار
if CoreGui:FindFirstChild("MaxCustomExploitUI") then
    CoreGui.MaxCustomExploitUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MaxCustomExploitUI"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 520)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- شريط العنوان
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Title.TextColor3 = Color3.fromRGB(0, 255, 128)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Text = "⚡ لوحة التحكم القصوى (MAX EXPLOIT CONTROL) ⚡"
Title.Parent = MainFrame

-- حاوية الأزرار والإعدادات (ScrollingFrame)
local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Size = UDim2.new(1, -20, 1, -60)
ScrollContainer.Position = UDim2.new(0, 10, 0, 50)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 750)
ScrollContainer.Parent = MainFrame

-- وظيفة مساعدة لإنشاء الأزرار والحقول المخصصة
local yPos = 10
local function createSectionTitle(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 30)
    lbl.Position = UDim2.new(0, 0, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(255, 200, 0)
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 14
    lbl.Text = text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = ScrollContainer
    yPos = yPos + 35
end

local function createButton(name, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Text = name
    btn.Parent = ScrollContainer
    
    btn.MouseButton1Click:Connect(callback)
    yPos = yPos + 45
end

-- ==================== [1. قسم الـ FunnelShop والـ Trails] ====================
createSectionTitle("--- [1] إدارة المتجر والـ Trails ---")

createButton("فتح FunnelShop (open)", Color3.fromRGB(0, 120, 215), function()
    local args = {"open"}
    pcall(function()
        ReplicatedStorage.Remotes.FunnelShop:FireServer(unpack(args))
        print("[+] تم فتح FunnelShop بنجاح")
    end)
end)

createButton("شراء GreenTrail (Wins)", Color3.fromRGB(0, 170, 120), function()
    local args = {"GreenTrail", "Wins"}
    pcall(function()
        ReplicatedStorage.Remotes.BuyTrail:InvokeServer(unpack(args))
        print("[+] تم شراء GreenTrail")
    end)
end)

createButton("شراء GodlikeTrail (Wins)", Color3.fromRGB(0, 170, 120), function()
    local args = {"GodlikeTrail", "Wins"}
    pcall(function()
        ReplicatedStorage.Remotes.BuyTrail:InvokeServer(unpack(args))
        print("[+] تم شراء GodlikeTrail")
    end)
end)

-- ==================== [2. قسم الخطوات والجوائز] ====================
createSectionTitle("--- [2] نظام الخطوات والجوائز ---")

createButton("تجهيز وتفعيل Award3 (EquipStepAward)", Color3.fromRGB(180, 50, 180), function()
    local args = {"Award3"}
    pcall(function()
        ReplicatedStorage.Remotes.EquipStepAward:FireServer(unpack(args))
        print("[+] تم تفعيل Award3")
    end)
end)

-- ==================== [3. قسم الـ Rebirth والـ Treadmill (مع التحكم بالعدد والكمية)] ====================
createSectionTitle("--- [3] التحكم بالـ Rebirth & Treadmill (أقصى حد) ---")

createButton("تنفيذ Rebirth (إرسال الأمر)", Color3.fromRGB(220, 50, 50), function()
    pcall(function()
        ReplicatedStorage.Remotes.Rebirth:FireServer()
        print("[+] تم تنفيذ Rebirth بنجاح")
    end)
end)

createButton("تفعيل TreadmillSignal (true)", Color3.fromRGB(50, 150, 220), function()
    local args = {true}
    pcall(function()
        ReplicatedStorage.Remotes.TreadmillSignal:FireServer(unpack(args))
        print("[+] تم تفعيل TreadmillSignal")
    end)
end)

createButton("تملك الجهاز (PromptOwnerTreadmill)", Color3.fromRGB(200, 120, 0), function()
    pcall(function()
        ReplicatedStorage.Remotes.PromptOwnerTreadmill:FireServer()
        print("[+] تم تملك جهاز الجري (PromptOwnerTreadmill)")
    end)
end)

-- ==================== [4. نظام التكرار الأقصى (Spam Loop)] ====================
createSectionTitle("--- [4] تكرار هجومي للريموتات (Custom Spam) ---")

local isSpamming = false
createButton("تبديل سبام Rebirth السريع (تشغيل / إيقاف)", Color3.fromRGB(100, 100, 100), function()
    isSpamming = not isSpamming
    if isSpamming then
        print("[!] بدأت عملية السبام الأقصى للـ Rebirth...")
        task.spawn(function()
            while isSpamming do
                pcall(function()
                    ReplicatedStorage.Remotes.Rebirth:FireServer()
                end)
                task.wait(0.1) -- التكرار بأقصى سرعة
            end
        end)
    else
        print("[!] توقف السبام.")
    end
end)

-- زر الإغلاق للواجهة
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(1, -20, 0, 35)
CloseBtn.Position = UDim2.new(0, 10, 0, yPos)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 20, 20)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 14
CloseBtn.Text = "إغلاق اللوحة بالكامل"
CloseBtn.Parent = ScrollContainer

CloseBtn.MouseButton1Click:Connect(function()
    isSpamming = false
    ScreenGui:Destroy()
end)

print("[+] تم تحميل لوحة التحكم القصوى (MAX EXPLOIT UI) بنجاح على الشاشة!")
