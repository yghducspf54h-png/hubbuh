-- واجهة سحب ونسخ جميع النصوص الظاهرة على الشاشة يدويًا
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- إزالة أي واجهة قديمة لو كانت موجودة
if CoreGui:FindFirstChild("FullTextDumperUI") then
    CoreGui.FullTextDumperUI:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FullTextDumperUI"
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 600, 0, 450)
frame.Position = UDim2.new(0.5, -300, 0.5, -225)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- صندوق النص اللي بيطلع فيه الـ 800 سطر وتنسخها منه
local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, -20, 1, -80)
textBox.Position = UDim2.new(0, 10, 0, 10)
textBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
textBox.TextColor3 = Color3.fromRGB(0, 255, 128)
textBox.TextSize = 13
textBox.Font = Enum.Font.Code
textBox.TextWrapped = false
textBox.ClearTextOnFocus = false
textBox.MultiLine = true
textBox.Text = "-- اضغط على زر (سحب النصوص) بالأسفل لجلب كل الكلام الموجود في الشاشة هنا..."
textBox.Parent = frame

-- زر السحب والتجميع
local dumpBtn = Instance.new("TextButton")
dumpBtn.Size = UDim2.new(0, 180, 0, 40)
dumpBtn.Position = UDim2.new(0, 10, 1, -55)
dumpBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
dumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dumpBtn.Font = Enum.Font.SourceSansBold
dumpBtn.TextSize = 14
dumpBtn.Text = "سحب جميع النصوص"
dumpBtn.Parent = frame

-- زر الإغلاق
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 100, 0, 40)
closeBtn.Position = UDim2.new(1, -110, 1, -55)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 14
closeBtn.Text = "إغلاق"
closeBtn.Parent = frame

-- برمجة زر السحب
dumpBtn.MouseButton1Click:Connect(function()
    local allText = ""
    local count = 0
    
    -- المرور على جميع عناصر واجهة اللاعب لجمع النصوص الظاهرة
    for _, obj in ipairs(PlayerGui:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            if obj.Text and obj.Text ~= "" then
                allText = allText .. "[" .. obj.Name .. "]: " .. obj.Text .. "\n--------------------\n"
                count = count + 1
            end
        end
    end
    
    if allText ~= "" then
        textBox.Text = allText
        dumpBtn.Text = "تم السحب (" .. count .. " عنصر) ✅"
    else
        textBox.Text = "-- لم يتم العثور على نص ظاهري في الـ PlayerGui، تأكد أن الواجهة مفتوحة."
    end
end)

-- برمجة زر الإغلاق
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)
