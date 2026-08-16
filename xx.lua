-- سكربت إنشاء نافذة نسخ يدوية (Text Selection Box)
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- إنشاء واجهة بسيطة تحتوي على صندوق نص قابل للتحديد
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomTextDumper"
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 500, 0, 400)
frame.Position = UDim2.new(0.5, -250, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Parent = screenGui

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, -20, 1, -60)
textBox.Position = UDim2.new(0, 10, 0, 10)
textBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox.TextWrapped = true
textBox.ClearTextOnFocus = false
textBox.MultiLine = true
textBox.Text = "-- الصق هنا أو اكتب النص اللي تبيه، أو استخدمه لتحديد النصوص الطويلة نسخ يدوي."
textBox.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 100, 0, 35)
closeBtn.Position = UDim2.new(0.5, -50, 1, -45)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Text = "إغلاق"
closeBtn.Parent = frame

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)
