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
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local attackEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("AttackRemoteEvent")

local Window = Library:CreateWindow({
    Title = "吃掉其他人来成长",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify({
    Title = "吃掉其他人来成长",
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

local AutoGroup = Tabs.Main:AddLeftGroupbox("自动")

AutoGroup:AddToggle("AutoFarm", {
    Text = "自动农场",
    Default = false,
})

AutoGroup:AddSlider("FarmBiteSpeed", {
    Text = "自动农场咬的频率(秒)",
    Default = 0.1,
    Min = 0.05,
    Max = 1,
    Rounding = 2,
})

AutoGroup:AddToggle("OneBitePerItem", {
    Text = "每个物品咬一次换下一个",
    Default = false,
})

AutoGroup:AddToggle("EscapeOnPlayer", {
    Text = "人来了自动瞬移到下一个",
    Default = false,
})

AutoGroup:AddSlider("PlayerRange", {
    Text = "人来了检测范围",
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 0,
})

AutoGroup:AddToggle("SuperFastFarm", {
    Text = "极速自动农场",
    Default = false,
})

AutoGroup:AddToggle("AutoAttack", {
    Text = "自动咬",
    Default = false,
})

AutoGroup:AddToggle("AutoEatPlayer", {
    Text = "自动吃别人",
    Default = false,
})

AutoGroup:AddToggle("AutoCoins", {
    Text = "自动加金币",
    Default = false,
})

AutoGroup:AddSlider("CoinsSpeed", {
    Text = "自动加金币间隔(秒)",
    Default = 0.2,
    Min = 0.05,
    Max = 1,
    Rounding = 2,
})

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

task.spawn(function()
    while true do
        if Toggles.AutoAttack.Value then
            attackEvent:FireServer("Chomp")
        end
        task.wait(0.05)
    end
end)

local targetNames = {"Cola", "Fried Egg", "Hot Dog", "Cake Slice", "Beans", "Pizza", "Taco", "Milkshake", "Hill"}

local function getTargets()
    local targets = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            for _, name in ipairs(targetNames) do
                if obj.Name == name then
                    table.insert(targets, obj)
                    break
                end
            end
        end
    end
    return targets
end

local function getPart(obj)
    if obj:IsA("BasePart") then
        return obj
    end
    if obj:IsA("Model") then
        if obj.PrimaryPart then
            return obj.PrimaryPart
        end
        for _, child in ipairs(obj:GetDescendants()) do
            if child:IsA("BasePart") then
                return child
            end
        end
    end
    return nil
end

local function getNearbyPlayers(range)
    local nearby = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp and humanoidRootPart then
                local dist = (hrp.Position - humanoidRootPart.Position).Magnitude
                if dist <= range then
                    table.insert(nearby, p)
                end
            end
        end
    end
    return nearby
end

task.spawn(function()
    while true do
        if Toggles.AutoFarm.Value then
            local targets = getTargets()
            if #targets > 0 then
                for _, target in ipairs(targets) do
                    if not Toggles.AutoFarm.Value then break end
                    local part = getPart(target)
                    if part and humanoidRootPart then
                        humanoidRootPart.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
                        if Toggles.OneBitePerItem.Value then
                            attackEvent:FireServer("Chomp")
                            task.wait(0.2)
                        else
                            while Toggles.AutoFarm.Value and target and target.Parent do
                                if Toggles.EscapeOnPlayer.Value then
                                    local range = Options.PlayerRange.Value or 50
                                    local nearby = getNearbyPlayers(range)
                                    if #nearby > 0 then
                                        break
                                    end
                                end
                                attackEvent:FireServer("Chomp")
                                local speed = Options.FarmBiteSpeed.Value or 0.1
                                task.wait(speed)
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while true do
        if Toggles.SuperFastFarm.Value then
            local targets = getTargets()
            if #targets > 0 then
                for _, target in ipairs(targets) do
                    if not Toggles.SuperFastFarm.Value then break end
                    if not target or not target.Parent then
                        continue
                    end
                    local part = getPart(target)
                    if part and humanoidRootPart then
                        humanoidRootPart.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
                        attackEvent:FireServer("Chomp")
                        task.wait(0.1)
                        if not target or not target.Parent then
                            continue
                        end
                    end
                end
            end
            task.wait(0.1)
        else
            task.wait(0.5)
        end
    end
end)

local function getNearestAlivePlayer()
    local nearest = nil
    local minDist = math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local dist = (hrp.Position - humanoidRootPart.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = p
                end
            end
        end
    end
    return nearest
end

local currentEatTarget = nil
local eatConnection = nil

task.spawn(function()
    while true do
        if Toggles.AutoEatPlayer.Value then
            if not currentEatTarget or not currentEatTarget.Character or not currentEatTarget.Character.Parent then
                currentEatTarget = getNearestAlivePlayer()
                if currentEatTarget then
                    local startHealth = currentEatTarget.Character:FindFirstChild("Humanoid") and currentEatTarget.Character.Humanoid.Health or 0
                    local noDamageCount = 0
                    if eatConnection then eatConnection:Disconnect() end
                    eatConnection = RunService.Heartbeat:Connect(function()
                        if not Toggles.AutoEatPlayer.Value or not currentEatTarget or not currentEatTarget.Character or not currentEatTarget.Character.Parent then
                            return
                        end
                        local currentHrp = currentEatTarget.Character:FindFirstChild("HumanoidRootPart")
                        local currentHum = currentEatTarget.Character:FindFirstChild("Humanoid")
                        if not currentHrp or not currentHum or currentHum.Health <= 0 then
                            return
                        end
                        local behindPos = currentHrp.Position - currentHrp.CFrame.LookVector * 2
                        humanoidRootPart.CFrame = CFrame.new(behindPos, currentHrp.Position)
                    end)
                    while Toggles.AutoEatPlayer.Value and currentEatTarget and currentEatTarget.Character and currentEatTarget.Character.Parent do
                        local currentHrp = currentEatTarget.Character:FindFirstChild("HumanoidRootPart")
                        local currentHum = currentEatTarget.Character:FindFirstChild("Humanoid")
                        if not currentHrp or not currentHum or currentHum.Health <= 0 then
                            break
                        end
                        attackEvent:FireServer("Chomp")
                        task.wait(0.2)
                        local checkHum = currentEatTarget.Character:FindFirstChild("Humanoid")
                        if checkHum and checkHum.Health >= startHealth then
                            noDamageCount = noDamageCount + 1
                            if noDamageCount >= 3 then
                                break
                            end
                        else
                            noDamageCount = 0
                            startHealth = checkHum and checkHum.Health or startHealth
                        end
                    end
                    if eatConnection then
                        eatConnection:Disconnect()
                        eatConnection = nil
                    end
                    currentEatTarget = nil
                end
            end
        else
            if eatConnection then
                eatConnection:Disconnect()
                eatConnection = nil
            end
            currentEatTarget = nil
        end
        task.wait(0.3)
    end
end)

task.spawn(function()
    while true do
        if Toggles.AutoCoins.Value then
            local args = {
                [1] = "TriggerPickup",
                [2] = workspace.PickupItems.Coins.SilverCoin.AutoGeneratedPickupPart,
                [3] = {
                    ["HitboxName"] = "LocalHitbox",
                    ["PickupType"] = "Coins",
                    ["IsLocal"] = true
                },
                [4] = {
                    ["HitboxType"] = {
                        ["ScaleSize"] = true,
                        ["Attached"] = true,
                        ["Size"] = Vector3.new(3.25, 6.5, 1.75)
                    },
                    ["Player"] = game:GetService("Players").LocalPlayer,
                    ["Character"] = game:GetService("Players").LocalPlayer.Character,
                    ["LastContent"] = {
                        [1] = workspace.World.Baseplate.Grass
                    },
                    ["Parent"] = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart,
                    ["LastTime"] = tick(),
                    ["ExtraData"] = {
                        ["Player"] = game:GetService("Players").LocalPlayer,
                        ["IgnoreDescendants"] = game:GetService("Players").LocalPlayer.Character,
                        ["LocalMode"] = true,
                        ["Name"] = "LocalHitbox",
                        ["HipHeight"] = 1.8748564720153809
                    }
                }
            }
            game:GetService("ReplicatedStorage").Events.GeneralRemoteEvent:FireServer(unpack(args))
        end
        local speed = Options.CoinsSpeed.Value or 0.2
        task.wait(speed)
    end
end)

player.CharacterAdded:Connect(function(char)
    character = char
    humanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)
