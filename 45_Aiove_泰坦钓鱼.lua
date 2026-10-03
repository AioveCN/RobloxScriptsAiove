-- This file has been deobfuscated Luraph using Hurricane https://discord.com/invite/AbeurBzKXe
local function safeLoad(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not success then
        warn("加载失败: " .. url)
        return nil
    end
    return result
end

local Library = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/黑曜石主库.ui")
local ThemeManager = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/主题管理.ui")
local SaveManager = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/配置管理.ui")

if not Library then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "错误",
        Text = "UI 库加载失败，请检查网络或脚本资源",
        Duration = 5,
    })
    return
end

local Options = Library.Options
local Toggles = Library.Toggles

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local Window = Library:CreateWindow({
    Title = "泰坦钓鱼",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify({
    Title = "泰坦钓鱼",
    Description = "创作者：Aiove\nQQ：3999698324\n脚本已加载成功",
    Time = 5,
})

local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Main = Window:AddTab("主要", "info"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel('Aiove将持续更新此脚本')
NoticeGroup:AddLabel('创作者：Aiove')
NoticeGroup:AddLabel('QQ：3999698324')

-- ======== 辅助变量和函数 ========
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lplr = Players.LocalPlayer
local Lighting = game:GetService("Lighting")

local sellThreshold = 5
local autoSellEnabled = false
local AutoTPBoss = false
local isTeleporting = false
local isBossTeleporting = false
local bossActive = false
local originalLocation = nil
local fishOriginalLocation = nil

local sellPoints = {
    Vector3.new(1753.58508, 24.244154, -396.541931),
    Vector3.new(1139.21008, 70.4045868, 1475.69507),
    Vector3.new(-846.960144, 27.6607056, -225.477127),
    Vector3.new(-538.224976, 28.2181206, 1161.66272),
    Vector3.new(493.731262, 33.1211739, -1135.01453),
    Vector3.new(-516.820435, 62.4082184, -1261.70251),
    Vector3.new(171.133942, 22.7074032, 74.2732925)
}

local islandPositions = {
    ["岛1"] = Vector3.new(43.646328, 61.3580856, -11.8101273),
    ["岛2"] = Vector3.new(1687.81897, 109.880562, -348.565186),
    ["岛3"] = Vector3.new(1018.59784, 137.382126, 1577.11279),
    ["岛4"] = Vector3.new(503.149841, 33.047657, -1124.02405),
    ["岛5"] = Vector3.new(-415.077667, 29.3026218, 1203.13782),
    ["岛6"] = Vector3.new(-778.700623, 27.1415901, -286.575745),
    ["岛7"] = Vector3.new(-574.526306, 65.7370377, -1464.41028)
}

local function findBossZone()
    local bossZonesFolder = workspace:FindFirstChild("BossZones")
    if not bossZonesFolder then return nil end
    for _, folder in ipairs(bossZonesFolder:GetChildren()) do
        local zone = folder:FindFirstChild("BossSpawnZone")
        if zone then return zone end
    end
    return nil
end

local function getClosestSellPoint(hrpPosition)
    local closestPoint, shortestDistance = nil, math.huge
    for _, point in ipairs(sellPoints) do
        local dist = (hrpPosition - point).Magnitude
        if dist < shortestDistance then
            shortestDistance = dist
            closestPoint = point
        end
    end
    return closestPoint
end

local function getInventoryCount()
    local count = 0
    local bp = lplr:FindFirstChild("Backpack")
    local char = lplr.Character
    if bp then count = count + #bp:GetChildren() end
    if char then
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("Tool") then count = count + 1 end
        end
    end
    return count
end

local function smoothTween(targetCFrame, speedOverride)
    local character = lplr.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local speed = speedOverride or 150
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local duration = distance / speed
    local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    local noclip = RunService.Stepped:Connect(function()
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end)
    tween:Play()
    tween.Completed:Wait()
    noclip:Disconnect()
end

-- ======== 自动农场 ========
local AutoFarmGroup = Tabs.Main:AddLeftGroupbox("自动农场")

local AutoFram = false

AutoFarmGroup:AddToggle("AutoCast", {
    Text = "自动抛竿",
    Default = false,
    Tooltip = "完美抛竿",
    Callback = function(state)
        AutoFram = state
        if AutoFram then
            task.spawn(function()
                local rg
                for _,v in next,getgc(true) do
                    if type(v)=="table" then
                        pcall(function()
                            local n=0
                            for _,k in next,{"RodController","SkillClient","Inventory","SellClient"} do
                                if rawget(v,k) then n=n+1 end
                            end
                            if n>=3 then rg=v end
                        end)
                    end
                end
                local nt=rg.SkillClient.Shared.Network
                while AutoFram do
                    pcall(nt.FireServer,nt,"StartCharge")
                    task.wait(0.08)
                    if not AutoFram then break end
                    pcall(nt.FireServer,nt,"ReleaseCharge")
                    task.wait(0.08)
                end
            end)
        end
    end
})

local AutoAttack = false

AutoFarmGroup:AddToggle("AutoAttack", {
    Text = "自动拉杆",
    Default = false,
    Callback = function(state)
        AutoAttack = state
        if AutoAttack then
            task.spawn(function()
                local rg
                for _,v in next,getgc(true) do
                    if type(v)=="table" then
                        pcall(function()
                            local n=0
                            for _,k in next,{"RodController","SkillClient","Inventory","SellClient"} do
                                if rawget(v,k) then n=n+1 end
                            end
                            if n>=3 then rg=v end
                        end)
                    end
                end
                local nt=rg.SkillClient.Shared.Network
                while AutoAttack do
                    pcall(nt.FireServer,nt,"ApplyDamage")
                    task.wait(0.08)
                end
            end)
        end
    end
})

local AutoSkill = false

AutoFarmGroup:AddToggle("AutoSkill", {
    Text = "自动技能",
    Default = false,
    Callback = function(state)
        AutoSkill = state
        if AutoSkill then
            task.spawn(function()
                local rg
                for _,v in next, getgc(true) do
                    if type(v) == "table" then
                        pcall(function()
                            local n = 0
                            for _,k in next, {"RodController","SkillClient","Inventory","SellClient"} do
                                if rawget(v,k) then n = n + 1 end
                            end
                            if n >= 3 then rg = v end
                        end)
                    end
                end
                if not rg then return end
                local nt = rg.SkillClient.Shared.Network
                local lplr = game:GetService("Players").LocalPlayer
                while AutoSkill do
                    pcall(function()
                        local fullText = lplr.PlayerGui.RodGUI.Main.Mastery.NameRod.Text
                        local rodName = string.gsub(fullText, "%s*%(.-%)", "")
                        for i = 1, 4 do
                            if not AutoSkill then break end
                            pcall(nt.FireServer, nt, "CastSkill", rodName, tostring(i))
                        end
                    end)
                    task.wait(0.4)
                end
            end)
        end
    end
})

AutoFarmGroup:AddSlider("SellThreshold", {
    Text = "检测数量",
    Default = 5,
    Min = 5,
    Max = 60,
    Rounding = 0,
    Compact = false,
    Callback = function(value)
        sellThreshold = value
    end
})

AutoFarmGroup:AddToggle("AutoSell", {
    Text = "自动卖鱼",
    Default = false,
    Tooltip = "达到数量自动往返（Boss优先）",
    Callback = function(state)
        autoSellEnabled = state
        if state then
            task.spawn(function()
                while autoSellEnabled do
                    task.wait(1)
                    if not isTeleporting and not isBossTeleporting and not bossActive then
                        if getInventoryCount() >= sellThreshold then
                            local hrp = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                fishOriginalLocation = hrp.CFrame
                                local targetPos = getClosestSellPoint(hrp.Position)
                                if targetPos then
                                    isTeleporting = true
                                    smoothTween(CFrame.new(targetPos))
                                    repeat task.wait(0.5) until getInventoryCount() < sellThreshold or not autoSellEnabled or bossActive
                                    if not bossActive and autoSellEnabled then
                                        smoothTween(fishOriginalLocation)
                                    end
                                    isTeleporting = false
                                end
                            end
                        end
                    end
                end
            end)
            task.spawn(function()
                local rg
                for _,v in next,getgc(true) do
                    if type(v)=="table" then
                        pcall(function()
                            local n=0
                            for _,k in next,{"RodController","SkillClient","Inventory","SellClient"} do
                                if rawget(v,k) then n=n+1 end
                            end
                            if n>=3 then rg = v end
                        end)
                    end
                end
                if rg and rg.SkillClient.Shared.Network then
                    local nt = rg.SkillClient.Shared.Network
                    while autoSellEnabled do
                        pcall(nt.InvokeServer, nt, "SellFishingEverything")
                        task.wait(0.5)
                    end
                end
            end)
        end
    end
})

AutoFarmGroup:AddToggle("AutoTPBoss", {
    Text = "自动传送Boss点",
    Default = false,
    Tooltip = "优先级最高，强制中断其他传送",
    Callback = function(state)
        AutoTPBoss = state
        if state then
            task.spawn(function()
                while AutoTPBoss do
                    task.wait(0.5)
                    local zone = findBossZone()
                    if zone and not bossActive then
                        bossActive = true
                        local hrp = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            originalLocation = hrp.CFrame
                            isBossTeleporting = true
                            smoothTween(zone:IsA("Model") and zone:GetModelCFrame() or zone.CFrame, 200)
                            isBossTeleporting = false
                        end
                    elseif not zone and bossActive then
                        if originalLocation then
                            isBossTeleporting = true
                            smoothTween(originalLocation)
                            isBossTeleporting = false
                            originalLocation = nil
                        end
                        bossActive = false
                    end
                end
            end)
        else
            bossActive = false
            originalLocation = nil
        end
    end
})

-- ======== 光环类 ========
local AuraGroup = Tabs.Main:AddRightGroupbox("光环类")

AuraGroup:AddToggle("SellAura", {
    Text = "售卖光环",
    Default = false,
    Callback = function(state)
        getfenv().SellAuraEnabled = state
        if state then
            task.spawn(function()
                local rg
                for _,v in next,getgc(true) do
                    if type(v)=="table" then
                        pcall(function()
                            local n=0
                            for _,k in next,{"RodController","SkillClient","Inventory","SellClient"} do
                                if rawget(v,k) then n=n+1 end
                            end
                            if n>=3 then rg=v end
                        end)
                    end
                end
                local nt=rg.SkillClient.Shared.Network
                while getfenv().SellAuraEnabled do
                    pcall(nt.InvokeServer,nt,"SellFishingEverything")
                    task.wait(0.08)
                end
            end)
        end
    end
})

-- ======== 传送 ========
local TeleportGroup = Tabs.Main:AddLeftGroupbox("传送")

local selectedIsland = "岛1"

TeleportGroup:AddDropdown("IslandSelect", {
    Values = { "岛1", "岛2", "岛3", "岛4", "岛5", "岛6", "岛7" },
    Default = 1,
    Multi = false,
    Text = "选择岛屿",
    Callback = function(option)
        selectedIsland = option
    end
})

TeleportGroup:AddButton("传送", function()
    local character = lplr.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart
        local targetPos = islandPositions[selectedIsland]
        local targetCFrame = CFrame.new(targetPos)
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        local speed = 140
        local tweenTime = distance / speed
        local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
        local noclipLoop
        noclipLoop = RunService.Stepped:Connect(function()
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
        tween.Completed:Connect(function()
            noclipLoop:Disconnect()
        end)
        tween:Play()
    end
end)

TeleportGroup:AddButton("卖鱼", function()
    local character = lplr.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart
        local targetCFrame = CFrame.new(171.133942, 22.7074032, 74.2732925)
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        local speed = 160
        local tweenTime = distance / speed
        local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
        local noclipLoop
        noclipLoop = RunService.Stepped:Connect(function()
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
        tween.Completed:Connect(function()
            noclipLoop:Disconnect()
        end)
        tween:Play()
    end
end)

-- ======== 太极活动 ========
local EventGroup = Tabs.Main:AddRightGroupbox("太极活动")

EventGroup:AddToggle("AutoEventFish", {
    Text = "自动钓活动鱼",
    Default = false,
    Tooltip = "记得打开自动农场的功能",
    Callback = function(state)
        getfenv().AutoEventFish = state
        if state then
            task.spawn(function()
                local targetCFrame = CFrame.new(
                    567.262146, 17.524271, 687.860291,
                    -0.587829351, -3.01715697e-09, 0.808984995,
                    -5.33817524e-09, 1, -1.49297186e-10,
                    -0.808984995, -4.40626469e-09, -0.587829351
                )

                while getfenv().AutoEventFish do
                    local character = lplr.Character
                    local hrp = character and character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local dist = (hrp.Position - targetCFrame.Position).Magnitude
                        if dist > 1 then
                            local tween = TweenService:Create(hrp, TweenInfo.new(dist / 160, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
                            local noclip = RunService.Stepped:Connect(function()
                                for _, v in pairs(character:GetDescendants()) do
                                    if v:IsA("BasePart") then v.CanCollide = false end
                                end
                            end)
                            tween:Play()
                            tween.Completed:Wait()
                            noclip:Disconnect()
                        else
                            hrp.CFrame = targetCFrame
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

EventGroup:AddToggle("AutoSubmitTaiji", {
    Text = "自动提交太极鱼",
    Default = false,
    Tooltip = "没有太极鱼开启后会有大量垃圾提示",
    Callback = function(state)
        if state then
            local rg
            for _,v in next,getgc(true) do
                if type(v)=="table" then
                    pcall(function()
                        local n=0
                        for _,k in next,{"RodController","SkillClient","Inventory","SellClient"} do
                            if rawget(v,k) then n=n+1 end
                        end
                        if n>=3 then rg=v end
                    end)
                end
            end

            if rg then
                local nt=rg.SkillClient.Shared.Network
                getfenv().AutoSubmitTaiji = true
                task.spawn(function()
                    while getfenv().AutoSubmitTaiji do
                        pcall(nt.FireServer,nt,"SubmitAllTaijiFish")
                        task.wait(0.08)
                    end
                end)
            end
        else
            getfenv().AutoSubmitTaiji = false
        end
    end
})

-- ======== 杂项 ========
local MiscGroup = Tabs.Main:AddLeftGroupbox("杂项")

MiscGroup:AddToggle("AntiAFK", {
    Text = "反挂机",
    Default = true,
    Callback = function(state)
        getfenv().AntiAFK = state
        if state then
            task.spawn(function()
                local VirtualUser = game:GetService("VirtualUser")
                while getfenv().AntiAFK do
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                    task.wait(60)
                end
            end)
        end
    end
})

MiscGroup:AddToggle("LockPos", {
    Text = "锁定当前位置",
    Default = false,
    Tooltip = "不会和任何传送功能冲突",
    Callback = function(state)
        getfenv().LockPos = state
        if state then
            task.spawn(function()
                local lockedCFrame = nil
                local conn
                conn = RunService.Heartbeat:Connect(function()
                    if not getfenv().LockPos then
                        conn:Disconnect()
                        return
                    end
                    if (isTeleporting or isBossTeleporting or bossActive
                        or getfenv().AutoEventFish or autoSellEnabled or AutoTPBoss) then
                        lockedCFrame = nil
                        return
                    end
                    local char = lplr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        if not lockedCFrame then
                            lockedCFrame = hrp.CFrame
                        end
                        hrp.CFrame = lockedCFrame
                        hrp.Velocity = Vector3.zero
                        hrp.AssemblyLinearVelocity = Vector3.zero
                    end
                end)
            end)
        end
    end
})

-- ======== 设置页 ========
local UnloadGroup = Tabs.Settings:AddLeftGroupbox("脚本管理")
UnloadGroup:AddButton("卸载脚本", function()
    Library:Unload()
end)

if ThemeManager then
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("MyScriptTheme")
    ThemeManager:ApplyToTab(Tabs.Settings)
end

if SaveManager then
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetFolder("MyScriptConfig")
    SaveManager:BuildConfigSection(Tabs.Settings)
end

