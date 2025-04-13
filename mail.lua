--[[
    سكربت متكامل للعبة Farming with Friends
    مع واجهة تحكم للجوال وتفعيل/إيقاف جميع الميزات
    تم التحديث في 2023
]]

-- #################################################
-- ##               الجزء الأول: الواجهة           ##
-- #################################################

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "FarmingAutoGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- إنشاء الإطار الرئيسي
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.85, 0, 0.8, 0)
mainFrame.Position = UDim2.new(0.075, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BackgroundTransparency = 0.1
mainFrame.Parent = gui

-- إضافة تأثير ظل
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 10, 1, 10)
shadow.Position = UDim2.new(0, -5, 0, -5)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.Parent = mainFrame

-- عنوان الواجهة
local title = Instance.new("TextLabel")
title.Text = "Farming Automation"
title.Size = UDim2.new(1, 0, 0.1, 0)
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 18
title.BackgroundTransparency = 1
title.Parent = mainFrame

-- زر الإغلاق
local closeBtn = Instance.new("TextButton")
closeBtn.Text = "X"
closeBtn.Size = UDim2.new(0.12, 0, 0.12, 0)
closeBtn.Position = UDim2.new(0.88, 0, 0, 0)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Parent = mainFrame

-- قائمة الخيارات
local options = {
    {name = "حلب الأبقار", default = true, key = "milking", desc = "تفعيل الحلب التلقائي للأبقار"},
    {name = "تنظيف الحظيرة", default = false, key = "cleaning", desc = "تنظيف الأماكن قبل الحلب"},
    {name = "فلترة 300% فقط", default = true, key = "filter", desc = "حلب الأبقار الجاهزة فقط (300%)"},
    {name = "الإخراج التلقائي", default = true, key = "auto_exit", desc = "إخراج الأبقار بعد الحلب"},
    {name = "التأخير العشوائي", default = true, key = "random_delay", desc = "تفعيل تأخيرات عشوائية بين العمليات"}
}

local buttons = {}
local yOffset = 0.12

for i, option in ipairs(options) do
    local optionFrame = Instance.new("Frame")
    optionFrame.Size = UDim2.new(0.9, 0, 0.14, 0)
    optionFrame.Position = UDim2.new(0.05, 0, yOffset, 0)
    optionFrame.BackgroundTransparency = 1
    optionFrame.Parent = mainFrame
    
    local btn = Instance.new("TextButton")
    btn.Text = option.name
    btn.Size = UDim2.new(0.7, 0, 1, 0)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BackgroundTransparency = 1
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = optionFrame
    
    local status = Instance.new("TextLabel")
    status.Text = option.default and "✅ مفعل" or "❌ معطل"
    status.Size = UDim2.new(0.25, 0, 1, 0)
    status.Position = UDim2.new(0.75, 0, 0, 0)
    status.Font = Enum.Font.Gotham
    status.TextSize = 14
    status.BackgroundTransparency = 1
    status.TextColor3 = option.default and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    status.Parent = optionFrame
    
    -- إضافة وصف صغير
    local desc = Instance.new("TextLabel")
    desc.Text = option.desc
    desc.Size = UDim2.new(1, 0, 0.4, 0)
    desc.Position = UDim2.new(0, 0, 0.6, 0)
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 11
    desc.TextColor3 = Color3.fromRGB(180, 180, 180)
    desc.BackgroundTransparency = 1
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = optionFrame
    
    buttons[option.key] = {
        button = btn,
        status = status,
        value = option.default
    }
    
    yOffset = yOffset + 0.15
    
    btn.MouseButton1Click:Connect(function()
        buttons[option.key].value = not buttons[option.key].value
        status.Text = buttons[option.key].value and "✅ مفعل" or "❌ معطل"
        status.TextColor3 = buttons[option.key].value and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    end)
end

-- إعدادات التوقيت
local delayFrame = Instance.new("Frame")
delayFrame.Size = UDim2.new(0.9, 0, 0.12, 0)
delayFrame.Position = UDim2.new(0.05, 0, yOffset + 0.05, 0)
delayFrame.BackgroundTransparency = 1
delayFrame.Parent = mainFrame

local delayLabel = Instance.new("TextLabel")
delayLabel.Text = "مدة التأخير (ثانية):"
delayLabel.Size = UDim2.new(0.6, 0, 1, 0)
delayLabel.Font = Enum.Font.Gotham
delayLabel.TextSize = 14
delayLabel.TextColor3 = Color3.new(1, 1, 1)
delayLabel.TextXAlignment = Enum.TextXAlignment.Left
delayLabel.BackgroundTransparency = 1
delayLabel.Parent = delayFrame

local delayBox = Instance.new("TextBox")
delayBox.Text = "30"
delayBox.Size = UDim2.new(0.3, 0, 0.8, 0)
delayBox.Position = UDim2.new(0.65, 0, 0.1, 0)
delayBox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
delayBox.TextColor3 = Color3.new(1, 1, 1)
delayBox.Font = Enum.Font.Gotham
delayBox.TextSize = 14
delayBox.Parent = delayFrame

-- أزرار التحكم
local startBtn = Instance.new("TextButton")
startBtn.Text = "بدء التشغيل"
startBtn.Size = UDim2.new(0.4, 0, 0.1, 0)
startBtn.Position = UDim2.new(0.1, 0, 0.88, 0)
startBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
startBtn.Font = Enum.Font.GothamBold
startBtn.TextColor3 = Color3.new(1, 1, 1)
startBtn.Parent = mainFrame

local stopBtn = Instance.new("TextButton")
stopBtn.Text = "إيقاف"
stopBtn.Size = UDim2.new(0.4, 0, 0.1, 0)
stopBtn.Position = UDim2.new(0.5, 0, 0.88, 0)
stopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextColor3 = Color3.new(1, 1, 1)
stopBtn.Parent = mainFrame

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- #################################################
-- ##             الجزء الثاني: السكربت           ##
-- #################################################

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Larry = Modules:WaitForChild("Larry")

local Animals = workspace:WaitForChild("Animals")
local Barn = workspace.Buildings.AutoWoodenBarn
local Spots = Barn.AnimalContainer.Spots

-- متغيرات التحكم
local isRunning = false
local cycleDelay = 30

-- دالة تنظيف المكان
local function CleanSpot(spotNumber)
    local spot = Spots:FindFirstChild(tostring(spotNumber))
    if spot then
        Larry.EVTFilthCleaning:FireServer(spot)
        print("✨ تم تنظيف المكان "..spotNumber)
        return true
    end
    return false
end

-- دالة معالجة البقرة
local function ProcessCow(cow, spotNumber)
    local spot = Spots:FindFirstChild(tostring(spotNumber))
    if not spot then return false end

    -- التحقق من الفلترة إذا كانت مفعلة
    if _G.FarmingSettings.filter then
        local production = cow:FindFirstChild("Configurations") and cow.Configurations.Production
        if not production or production.Value ~= 300 then
            print("⏭ تخطي البقرة "..cow.Name.." (الإنتاج: "..(production and production.Value or "N/A")..")")
            return false
        end
    end

    -- التنظيف إذا كان مفعلا
    if _G.FarmingSettings.cleaning then
        CleanSpot(spotNumber)
        if _G.FarmingSettings.random_delay then
            wait(math.random(1, 3))
        end
    end

    -- إدخال البقرة
    Larry.EVTAnimalInteraction:FireServer(cow, "Inspect")
    Larry.EVTHerdRequest:FireServer({cow}, Barn)
    
    if _G.FarmingSettings.random_delay then
        wait(math.random(2, 4))
    else
        wait(3)
    end

    -- الحلب إذا كان مفعلا
    if _G.FarmingSettings.milking then
        Larry.EVTCollectAnimalProduction:FireServer("Milk", cow)
        print("✅ حلب ناجح: "..cow.Name.." في المكان "..spotNumber)
    end

    -- الإخراج إذا كان مفعلا
    if _G.FarmingSettings.auto_exit then
        Larry.EVTOpenBarnGate:FireServer(spot.Gate)
    end

    return true
end

-- الدورة الرئيسية
local function MainCycle()
    while isRunning do
        local startTime = os.time()
        
        -- تنظيف جميع الأماكن إذا كان مفعلا
        if _G.FarmingSettings.cleaning then
            print("\n=== بدء التنظيف ===")
            for i = 1, 12 do
                CleanSpot(i)
                if _G.FarmingSettings.random_delay then
                    wait(math.random(1, 2))
                end
            end
        end

        -- معالجة الأبقار
        print("\n=== بدء الحلب ===")
        local cows = {}
        for _, cow in ipairs(Animals:GetChildren()) do
            if cow.Name == "Cow" then
                table.insert(cows, cow)
                if #cows >= 12 then break end
            end
        end

        for i, cow in ipairs(cows) do
            if not isRunning then break end
            ProcessCow(cow, i)
            
            if _G.FarmingSettings.random_delay then
                wait(math.random(2, 5))
            else
                wait(3)
            end
        end

        -- حساب وقت الانتظار للدورة التالية
        local currentDelay = tonumber(delayBox.Text) or 30
        local elapsed = os.time() - startTime
        local remaining = currentDelay - elapsed
        
        if remaining > 0 and isRunning then
            print("\n♻ الانتظار "..remaining.." ثانية للدورة التالية\n")
            wait(remaining)
        end
    end
end

-- أحداث الأزرار
startBtn.MouseButton1Click:Connect(function()
    if isRunning then return end
    
    _G.FarmingSettings = {
        milking = buttons["milking"].value,
        cleaning = buttons["cleaning"].value,
        filter = buttons["filter"].value,
        auto_exit = buttons["auto_exit"].value,
        random_delay = buttons["random_delay"].value
    }
    
    print("تم التشغيل مع الإعدادات:")
    for k,v in pairs(_G.FarmingSettings) do
        print(k..": "..tostring(v))
    end
    
    isRunning = true
    startBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    stopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    
    coroutine.wrap(MainCycle)()
end)

stopBtn.MouseButton1Click:Connect(function()
    isRunning = false
    startBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    stopBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    print("⏹ توقف السكربت")
end)

-- إعدادات أولية
_G.FarmingSettings = {
    milking = true,
    cleaning = false,
    filter = true,
    auto_exit = true,
    random_delay = true
}

print("تم تحميل سكربت Farming with Friends بنجاح")
