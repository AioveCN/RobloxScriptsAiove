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
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local autoBlastRunning = false
local autoBlastV2Running = false
local blastInterval = 15
local blastV2Interval = 1
local lastBlastTime = 0
local cooldownSeconds = 9
local blastPos = Vector3.new(-14.2, 1.3, 562.5)
local cultivationRunning = false
local cultivationInterval = 0.5

local function isAtBlastPos()
    local char = player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    return (hrp.Position - blastPos).Magnitude < 5
end

local function teleportToBlastPos()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = CFrame.new(blastPos)
end

local function doBlast()
    local now = tick()
    if now - lastBlastTime < cooldownSeconds then
        return
    end
    lastBlastTime = now

    teleportToBlastPos()
    task.wait(0.3)

    ReplicatedStorage.Remotes.RequestBlastStart:FireServer()
    task.wait(0.1)

    local args = { [1] = 4.5176430710125715 }
    ReplicatedStorage.Remotes.RequestBlastRelease:FireServer(unpack(args))
end

local function autoBlastLoop()
    while autoBlastRunning do
        doBlast()
        task.wait(blastInterval)
    end
end

local function autoBlastV2Loop()
    while autoBlastV2Running do
        if not isAtBlastPos() then
            teleportToBlastPos()
            task.wait(0.3)
        end
        local now = tick()
        if now - lastBlastTime >= cooldownSeconds then
            ReplicatedStorage.Remotes.RequestBlastStart:FireServer()
            task.wait(0.1)
            local args = { [1] = 4.5176430710125715 }
            ReplicatedStorage.Remotes.RequestBlastRelease:FireServer(unpack(args))
            lastBlastTime = now
        end
        task.wait(blastV2Interval)
    end
end

local function cultivationLoop()
    while cultivationRunning do
        local args1 = {
            [1] = "4818758418:44866.90683965:2537"
        }
        ReplicatedStorage.Remotes.AuraMultiplierClicked:FireServer(unpack(args1))
        task.wait(0.05)

        local args2 = {
            [1] = "get"
        }
        ReplicatedStorage.Remotes.PlayerSettings:InvokeServer(unpack(args2))
        task.wait(0.05)

        pcall(function()
            ReplicatedStorage.Remotes.GetIndexData:InvokeServer()
        end)

        task.wait(cultivationInterval)
    end
end

local Window = Library:CreateWindow({
    Title = "能量爆炸幸运方块",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify("爆炸幸运方块 - 创作者：Aiove", 5)

local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Main = Window:AddTab("功能", "info"),
    Cultivation = Window:AddTab("修炼", "info"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel('Aiove将持续更新此脚本')
NoticeGroup:AddLabel('创作者：Aiove')

local BlastGroup = Tabs.Main:AddLeftGroupbox("爆炸功能")

BlastGroup:AddSlider('BlastInterval', {
    Text = '自动爆炸间隔',
    Default = 15,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Suffix = " 秒",
    Callback = function(Value)
        blastInterval = Value
    end
})

BlastGroup:AddToggle('AutoBlast', {
    Text = '自动爆炸方块',
    Default = false,
    Tooltip = '开启后按设定间隔自动执行Blast',
}):OnChanged(function(value)
    if value then
        autoBlastRunning = true
        doBlast()
        task.spawn(autoBlastLoop)
        Library:Notify("自动爆炸已开启，间隔 " .. blastInterval .. " 秒", 3)
    else
        autoBlastRunning = false
        Library:Notify("自动爆炸已关闭", 3)
    end
end)

BlastGroup:AddSlider('BlastV2Interval', {
    Text = 'V2循环间隔',
    Default = 1,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Suffix = " 秒",
    Callback = function(Value)
        blastV2Interval = Value
    end
})

BlastGroup:AddToggle('AutoBlastV2', {
    Text = '自动爆炸方块V2',
    Default = false,
    Tooltip = '启动后自动传送到爆炸坐标，在坐标上自动爆炸，9秒内不会重复爆炸',
}):OnChanged(function(value)
    if value then
        autoBlastV2Running = true
        task.spawn(autoBlastV2Loop)
        Library:Notify("自动爆炸V2已开启，循环间隔 " .. blastV2Interval .. " 秒", 3)
    else
        autoBlastV2Running = false
        Library:Notify("自动爆炸V2已关闭", 3)
    end
end)

BlastGroup:AddButton({ Text = '手动执行Blast并传送', Func = function()
    doBlast()
    Library:Notify("已执行Blast并传送", 3)
end })

local CultivationGroup = Tabs.Cultivation:AddLeftGroupbox("提高修炼奖励概率")

CultivationGroup:AddSlider('CultivationInterval', {
    Text = '循环间隔',
    Default = 0.5,
    Min = 0.1,
    Max = 5,
    Rounding = 2,
    Suffix = " 秒",
    Callback = function(Value)
        cultivationInterval = Value
    end
})

CultivationGroup:AddToggle('AutoCultivation', {
    Text = '自动提高修炼奖励概率',
    Default = false,
    Tooltip = '开启后循环执行AuraMultiplierClicked、PlayerSettings和GetIndexData',
}):OnChanged(function(value)
    if value then
        cultivationRunning = true
        task.spawn(cultivationLoop)
        Library:Notify("自动提高修炼奖励概率已开启", 3)
    else
        cultivationRunning = false
        Library:Notify("自动提高修炼奖励概率已关闭", 3)
    end
end)

local SettingsGroup = Tabs.Settings:AddLeftGroupbox("菜单")
SettingsGroup:AddButton({ Text = '卸载脚本', Func = function()
    autoBlastRunning = false
    autoBlastV2Running = false
    cultivationRunning = false
    Library:Unload()
end })

SettingsGroup:AddButton({ Text = '重载界面', Func = function()
    autoBlastRunning = false
    autoBlastV2Running = false
    cultivationRunning = false
    Library:Unload()
    loadstring(game:HttpGet(game:GetService("HttpService"):UrlEncode("https://pastebin.com/raw/你的脚本地址")))()
end })

SettingsGroup:AddLabel('菜单快捷键'):AddKeyPicker('MenuKeybind', {
    Default = 'RightShift',
    NoUI = true,
    Text = 'Menu keybind'
})
Library.ToggleKeybind = Options.MenuKeybind

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
