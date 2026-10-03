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
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

local NukeRemotes = ReplicatedStorage:WaitForChild("NukeRemotes")
local RequestLockBase = NukeRemotes:WaitForChild("RequestLockBase")
local PurchaseUpgrade = NukeRemotes:WaitForChild("PurchaseUpgrade")
local LockStateUpdate = NukeRemotes:WaitForChild("LockStateUpdate")
local PickUp = NukeRemotes:WaitForChild("PickUp")
local Drop = NukeRemotes:WaitForChild("Drop")

local MergeRequest = nil
pcall(function()
    local Remotes = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Remotes"))
    MergeRequest = Remotes.MergeRequest
end)

local Window = Library:CreateWindow({
    Title = "合成一个核弹",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify({
    Title = "合成一个核弹",
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

local AutoLockConnection = nil
local AutoMaxConnection = nil
local AutoMaxCountConnection = nil
local AutoLockBaseConnection = nil
local AutoMergeConnection = nil
local AutoPickUpDropRunning = false
local AutoTeleportRunning = false
local AutoCombineRunning = false
local AutoCombineMergeConnection = nil
local AntiAfkRunning = false
local defaultWalkSpeed = 16

local MainGroup = Tabs.Main:AddLeftGroupbox("主要")

MainGroup:AddLabel("[说明]开启自动升级和自动锁基地会降低合并效率")

MainGroup:AddToggle("AutoLockBase", {
    Text = "自动锁定基地",
    Default = false,
    Tooltip = "开启后锁一次，之后每30秒锁一次",
    Callback = function(Value)
        if Value then
            task.spawn(function()
                RequestLockBase:FireServer()
                while Toggles.AutoLockBase.Value do
                    task.wait(30)
                    if Toggles.AutoLockBase.Value then
                        RequestLockBase:FireServer()
                    end
                end
            end)
        end
    end
})

MainGroup:AddToggle("AutoMaxUpgrade", {
    Text = "自动升级核弹初始等级",
    Default = false,
    Tooltip = "开启后每5秒发送一次升级请求",
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while Toggles.AutoMaxUpgrade.Value do
                    PurchaseUpgrade:FireServer("TIER")
                    task.wait(5)
                end
            end)
        end
    end
})

MainGroup:AddToggle("AutoMaxCount", {
    Text = "自动升级核弹最大数量",
    Default = false,
    Tooltip = "开启后每5秒发送一次升级请求",
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while Toggles.AutoMaxCount.Value do
                    PurchaseUpgrade:FireServer("MAX")
                    task.wait(5)
                end
            end)
        end
    end
})

MainGroup:AddToggle("AutoLockBaseTime", {
    Text = "自动升级锁定基地时间",
    Default = false,
    Tooltip = "开启后每5秒发送一次升级请求",
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while Toggles.AutoLockBaseTime.Value do
                    PurchaseUpgrade:FireServer("LOCKBASE")
                    task.wait(5)
                end
            end)
        end
    end
})

MainGroup:AddToggle("AutoPickUpDrop", {
    Text = "自动拿放",
    Default = false,
    Tooltip = "开启后拿起核弹等待0.5秒放下，循环执行",
    Callback = function(Value)
        if Value then
            AutoPickUpDropRunning = true
            task.spawn(function()
                while AutoPickUpDropRunning do
                    local bases = Workspace:FindFirstChild("Bases")
                    if bases then
                        for _, base in ipairs(bases:GetChildren()) do
                            local nukes = base:FindFirstChild("Nukes")
                            if nukes then
                                for _, nuke in ipairs(nukes:GetChildren()) do
                                    if not AutoPickUpDropRunning then
                                        return
                                    end
                                    PickUp:FireServer(nuke)
                                    task.wait(0.5)
                                    local char = player.Character
                                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                                    local cf = hrp and hrp.CFrame or CFrame.new()
                                    Drop:FireServer(cf)
                                    task.wait(0.5)
                                end
                            end
                        end
                    end
                    task.wait(5)
                end
            end)
        else
            AutoPickUpDropRunning = false
        end
    end
})

MainGroup:AddToggle("AutoTeleport", {
    Text = "自动传送到每一个核弹底下",
    Default = false,
    Tooltip = "开启后循环传送到自己所有核弹下方",
    Callback = function(Value)
        if Value then
            AutoTeleportRunning = true
            task.spawn(function()
                while AutoTeleportRunning do
                    local bases = Workspace:FindFirstChild("Bases")
                    if bases then
                        for _, base in ipairs(bases:GetChildren()) do
                            local nukes = base:FindFirstChild("Nukes")
                            if nukes then
                                for _, nuke in ipairs(nukes:GetChildren()) do
                                    if not AutoTeleportRunning then
                                        return
                                    end
                                    if nuke:GetAttribute("OwnerUserId") == player.UserId then
                                        local char = player.Character
                                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                                        if hrp then
                                            local nukePos
                                            if nuke:IsA("BasePart") then
                                                nukePos = nuke.Position
                                            elseif nuke:IsA("Model") then
                                                nukePos = nuke:GetPivot().Position
                                            end
                                            if nukePos then
                                                hrp.CFrame = CFrame.new(nukePos.X, nukePos.Y - 3, nukePos.Z)
                                            end
                                        end
                                        task.wait(0.5)
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        else
            AutoTeleportRunning = false
        end
    end
})

MainGroup:AddToggle("AutoMergeNukes", {
    Text = "极速合成",
    Default = false,
    Tooltip = "开启后每5秒发送一轮合并请求",
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while Toggles.AutoMergeNukes.Value do
                    if MergeRequest then
                        local bases = Workspace:FindFirstChild("Bases")
                        if bases then
                            for _, base in ipairs(bases:GetChildren()) do
                                local nukes = base:FindFirstChild("Nukes")
                                if nukes then
                                    for _, nuke in ipairs(nukes:GetChildren()) do
                                        if nuke:GetAttribute("OwnerUserId") == player.UserId then
                                            MergeRequest:FireServer(nuke)
                                        end
                                    end
                                end
                            end
                        end
                    end
                    task.wait(5)
                end
            end)
        end
    end
})

MainGroup:AddToggle("AutoCombine", {
    Text = "自动合并",
    Default = false,
    Tooltip = "开启后同时执行自动拿放、自动传送、极速合成逻辑",
    Callback = function(Value)
        if Value then
            AutoCombineRunning = true
            if AutoCombineMergeConnection then
                AutoCombineMergeConnection:Disconnect()
            end
            AutoCombineMergeConnection = RunService.Heartbeat:Connect(function()
                if not AutoCombineRunning then
                    return
                end
                if MergeRequest then
                    local bases = Workspace:FindFirstChild("Bases")
                    if bases then
                        for _, base in ipairs(bases:GetChildren()) do
                            local nukes = base:FindFirstChild("Nukes")
                            if nukes then
                                for _, nuke in ipairs(nukes:GetChildren()) do
                                    if nuke:GetAttribute("OwnerUserId") == player.UserId then
                                        MergeRequest:FireServer(nuke)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            task.spawn(function()
                while AutoCombineRunning do
                    local bases = Workspace:FindFirstChild("Bases")
                    if bases then
                        for _, base in ipairs(bases:GetChildren()) do
                            local nukes = base:FindFirstChild("Nukes")
                            if nukes then
                                for _, nuke in ipairs(nukes:GetChildren()) do
                                    if not AutoCombineRunning then
                                        return
                                    end
                                    if nuke:GetAttribute("OwnerUserId") == player.UserId then
                                        local char = player.Character
                                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                                        if hrp then
                                            local nukePos
                                            if nuke:IsA("BasePart") then
                                                nukePos = nuke.Position
                                            elseif nuke:IsA("Model") then
                                                nukePos = nuke:GetPivot().Position
                                            end
                                            if nukePos then
                                                hrp.CFrame = CFrame.new(nukePos.X, nukePos.Y - 3, nukePos.Z)
                                            end
                                        end
                                        PickUp:FireServer(nuke)
                                        task.wait(0.5)
                                        local cf = hrp and hrp.CFrame or CFrame.new()
                                        Drop:FireServer(cf)
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.01)
                end
            end)
        else
            AutoCombineRunning = false
            if AutoCombineMergeConnection then
                AutoCombineMergeConnection:Disconnect()
                AutoCombineMergeConnection = nil
            end
        end
    end
})

local GeneralGroup = Tabs.Main:AddRightGroupbox("通用功能")

GeneralGroup:AddToggle("AntiAfk", {
    Text = "反挂机踢出",
    Default = false,
    Tooltip = "每19分钟模拟按一次键盘，防止被踢出",
    Callback = function(Value)
        if Value then
            AntiAfkRunning = true
            task.spawn(function()
                while AntiAfkRunning do
                    task.wait(1140)
                    if not AntiAfkRunning then
                        return
                    end
                    local vim = game:GetService("VirtualInputManager")
                    vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.1)
                    vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                end
            end)
        else
            AntiAfkRunning = false
        end
    end
})

GeneralGroup:AddSlider("WalkSpeedSlider", {
    Text = "移速设置",
    Default = 16,
    Min = 16,
    Max = 500,
    Rounding = 0,
    Compact = false,
})

GeneralGroup:AddButton("确定修改", function()
    local char = player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = Options.WalkSpeedSlider.Value
    end
end)

GeneralGroup:AddToggle("ModifyWalkSpeed", {
    Text = "修改移速",
    Default = false,
    Tooltip = "关闭后恢复默认移速16",
    Callback = function(Value)
        if not Value then
            local char = player.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = defaultWalkSpeed
            end
        end
    end
})

local UnloadGroup = Tabs.Settings:AddLeftGroupbox("脚本管理")
UnloadGroup:AddButton("卸载脚本", function()
    if AutoLockConnection then
        AutoLockConnection:Disconnect()
        AutoLockConnection = nil
    end
    if AutoMaxConnection then
        AutoMaxConnection:Disconnect()
        AutoMaxConnection = nil
    end
    if AutoMaxCountConnection then
        AutoMaxCountConnection:Disconnect()
        AutoMaxCountConnection = nil
    end
    if AutoLockBaseConnection then
        AutoLockBaseConnection:Disconnect()
        AutoLockBaseConnection = nil
    end
    if AutoMergeConnection then
        AutoMergeConnection:Disconnect()
        AutoMergeConnection = nil
    end
    if AutoCombineMergeConnection then
        AutoCombineMergeConnection:Disconnect()
        AutoCombineMergeConnection = nil
    end
    AntiAfkRunning = false
    AutoPickUpDropRunning = false
    AutoTeleportRunning = false
    AutoCombineRunning = false
    local char = player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = defaultWalkSpeed
    end
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
