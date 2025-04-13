--[[
    سكربت متكامل للعبة Farming with Friends
    مع واجهة Rayfield قابلة للإغلاق وإعادة الفتح
]]

-- #################################################
-- ##               الجزء الأول: إعداد Rayfield    ##
-- #################################################

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

local Window = Rayfield:CreateWindow({
    Name = "Farming Automation",
    LoadingTitle = "جار التحميل...",
    LoadingSubtitle = "بواسطة AI Assistant",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "FarmingScript",
        FileName = "Config"
    },
    KeySystem = false
})

-- #################################################
-- ##               الجزء الثاني: العناصر         ##
-- #################################################

-- تبويب الإعدادات الرئيسية
local MainTab = Window:CreateTab("الإعدادات الرئيسية", 4483362458)

-- قسم الحلب
local MilkingSection = MainTab:CreateSection("إعدادات الحلب")

local MilkingToggle = MainTab:CreateToggle({
    Name = "حلب الأبقار",
    CurrentValue = true,
    Flag = "MilkingToggle",
    Callback = function(Value)
        _G.Settings.Milking = Value
    end,
})

local FilterToggle = MainTab:CreateToggle({
    Name = "فلترة 300% فقط",
    CurrentValue = true,
    Flag = "FilterToggle",
    Callback = function(Value)
        _G.Settings.Filter = Value
    end,
})

-- قسم التنظيف
local CleaningSection = MainTab:CreateSection("إعدادات التنظيف")

local CleaningToggle = MainTab:CreateToggle({
    Name = "تنظيف الحظيرة",
    CurrentValue = false,
    Flag = "CleaningToggle",
    Callback = function(Value)
        _G.Settings.Cleaning = Value
    end,
})

-- قسم التوقيت
local TimingSection = MainTab:CreateSection("إعدادات التوقيت")

local DelaySlider = MainTab:CreateSlider({
    Name = "مدة التأخير (ثانية)",
    Range = {10, 60},
    Increment = 5,
    Suffix = "ثانية",
    CurrentValue = 30,
    Flag = "DelaySlider",
    Callback = function(Value)
        _G.Settings.Delay = Value
    end,
})

local RandomDelayToggle = MainTab:CreateToggle({
    Name = "تأخيرات عشوائية",
    CurrentValue = true,
    Flag = "RandomDelayToggle",
    Callback = function(Value)
        _G.Settings.RandomDelay = Value
    end,
})

-- #################################################
-- ##               الجزء الثالث: التحكم          ##
-- #################################################

local ControlTab = Window:CreateTab("التحكم", 4483362458)

local StartButton = ControlTab:CreateButton({
    Name = "بدء التشغيل",
    Callback = function()
        StartFarming()
    end,
})

local StopButton = ControlTab:CreateButton({
    Name = "إيقاف التشغيل",
    Callback = function()
        StopFarming()
    end,
})

-- زر إظهار/إخفاء الواجهة
local ToggleUIButton = ControlTab:CreateButton({
    Name = "إظهار/إخفاء الواجهة",
    Callback = function()
        Rayfield:Toggle()
    end,
})

-- #################################################
-- ##               الجزء الرابع: السكربت         ##
-- #################################################

-- إعدادات أولية
_G.Settings = {
    Milking = true,
    Filter = true,
    Cleaning = false,
    Delay = 30,
    RandomDelay = true,
    Running = false
}

-- متغيرات السكربت
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Larry = Modules:WaitForChild("Larry")

local Animals = workspace:WaitForChild("Animals")
local Barn = workspace.Buildings.AutoWoodenBarn
local Spots = Barn.AnimalContainer.Spots

-- دالة تنظيف المكان
local function CleanSpot(spotNumber)
    local spot = Spots:FindFirstChild(tostring(spotNumber))
    if spot then
        Larry.EVTFilthCleaning:FireServer(spot)
        Rayfield:Notify({
            Title = "التنظيف",
            Content = "تم تنظيف المكان " .. spotNumber,
            Duration = 3,
            Image = 4483362458
        })
        return true
    end
    return false
end

-- دالة معالجة البقرة
local function ProcessCow(cow, spotNumber)
    local spot = Spots:FindFirstChild(tostring(spotNumber))
    if not spot then return false end

    -- التحقق من الفلترة إذا كانت مفعلة
    if _G.Settings.Filter then
        local production = cow:FindFirstChild("Configurations") and cow.Configurations.Production
        if not production or production.Value ~= 300 then
            return false
        end
    end

    -- التنظيف إذا كان مفعلا
    if _G.Settings.Cleaning then
        CleanSpot(spotNumber)
        if _G.Settings.RandomDelay then
            wait(math.random(1, 3))
        end
    end

    -- إدخال البقرة
    Larry.EVTAnimalInteraction:FireServer(cow, "Inspect")
    Larry.EVTHerdRequest:FireServer({cow}, Barn)
    
    if _G.Settings.RandomDelay then
        wait(math.random(2, 4))
    else
        wait(3)
    end

    -- الحلب إذا كان مفعلا
    if _G.Settings.Milking then
        Larry.EVTCollectAnimalProduction:FireServer("Milk", cow)
    end

    -- الإخراج
    Larry.EVTOpenBarnGate:FireServer(spot.Gate)

    return true
end

-- دالة البدء الرئيسية
function StartFarming()
    if _G.Settings.Running then return end
    _G.Settings.Running = true
    
    Rayfield:Notify({
        Title = "بدء التشغيل",
        Content = "جار بدء عملية الحلب التلقائي...",
        Duration = 3,
        Image = 4483362458
    })

    while _G.Settings.Running do
        local startTime = os.time()
        
        -- تنظيف جميع الأماكن إذا كان مفعلا
        if _G.Settings.Cleaning then
            for i = 1, 12 do
                if not _G.Settings.Running then break end
                CleanSpot(i)
                if _G.Settings.RandomDelay then
                    wait(math.random(1, 2))
                end
            end
        end

        -- معالجة الأبقار
        local cows = {}
        for _, cow in ipairs(Animals:GetChildren()) do
            if cow.Name == "Cow" then
                table.insert(cows, cow)
                if #cows >= 12 then break end
            end
        end

        for i, cow in ipairs(cows) do
            if not _G.Settings.Running then break end
            ProcessCow(cow, i)
            
            if _G.Settings.RandomDelay then
                wait(math.random(2, 5))
            else
                wait(3)
            end
        end

        -- حساب وقت الانتظار للدورة التالية
        local elapsed = os.time() - startTime
        local remaining = _G.Settings.Delay - elapsed
        
        if remaining > 0 and _G.Settings.Running then
            wait(remaining)
        end
    end
end

-- دالة الإيقاف
function StopFarming()
    _G.Settings.Running = false
    Rayfield:Notify({
        Title = "الإيقاف",
        Content = "تم إيقاف التشغيل التلقائي",
        Duration = 3,
        Image = 4483362458
    })
end

-- #################################################
-- ##               الجزء الخامس: الإغلاق         ##
-- #################################################

-- إضافة زر الإغلاق في القائمة الرئيسية
Window:Prompt({
    Title = "Farming Automation",
    SubTitle = "سكربت حلب تلقائي للأبقار",
    Content = "هل تريد إغلاق الواجهة؟",
    Actions = {
        Accept = {
            Name = "إغلاق",
            Callback = function()
                Rayfield:Destroy()
            end
        },
        Decline = {
            Name = "البقاء",
            Callback = function()
                -- لا تفعل شيئا
            end
        }
    }
})

print("تم تحميل سكربت Farming with Friends بنجاح")
