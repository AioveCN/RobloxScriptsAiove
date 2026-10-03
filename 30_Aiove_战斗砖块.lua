-- This file has been deobfuscated Luraph using Hurricane https://discord.com/invite/AbeurBzKXe
local function safeLoad(url) local success, result = pcall(function() return loadstring(game:HttpGet(url))() end) if not success then warn("加载失败: " .. url) return nil end return result end local Library = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/黑曜石主库.ui") local ThemeManager = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/主题管理.ui") local SaveManager = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/配置管理.ui") if not Library then game:GetService("StarterGui"):SetCore("SendNotification", { Title = "错误", Text = "UI 库加载失败，请检查网络或脚本资源", Duration = 5, }) return end local Options = Library.Options local Toggles = Library.Toggles local Players = game:GetService("Players") local ReplicatedStorage = game:GetService("ReplicatedStorage") local player = Players.LocalPlayer local Window = Library:CreateWindow({ Title = "战斗砖块", Footer = "Aiove 制作\n漆维 定制", Icon = 131153193945220, NotifySide = "Right", ShowCustomCursor = true, }) Library:Notify({ Title = "战斗砖块", Description = "创作者：Aiove\n漆维 定制\n脚本已加载成功", Time = 5, }) local Tabs = { Notice = Window:AddTab("通知", "info"), Main = Window:AddTab("主要", "info"), Settings = Window:AddTab("设置", "settings"), } local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息") NoticeGroup:AddLabel('Aiove将持续更新此脚本') NoticeGroup:AddLabel('创作者：Aiove')

local Events = ReplicatedStorage:WaitForChild("Events")
local RF = Events:WaitForChild("RemoteFunction")
local RE = Events:WaitForChild("RemoteEvents")
local PlayerSpawnRF = RF:WaitForChild("PlayerSpawn")
local PlayerSpawnRE = RE:WaitForChild("PlayerSpawn")
local SandboxSpawnRF = RF:WaitForChild("SandboxSpawn")
local StartBattleRF = RF:WaitForChild("StartBattle")
local PurchaseUpgradeRF = RF:WaitForChild("PurchaseUpgrade")
local GetDailyBonusRF = RF:WaitForChild("GetDailyBonus")
local GetDateSinceClaimedRF = RF:WaitForChild("GetDateSinceClaimed")
local BadgeRewardClaimRF = RF:WaitForChild("BadgeRewardClaim")

local Slots = {"Slot1", "Slot2", "Slot3", "Slot4", "Slot5", "Slot6", "Slot7", "Slot8"}

local AutoSpawn = false
local SandboxSpam = false
local AutoStart = false
local AutoDaily = false
local AutoUpgrade = false

local SpawnGroup = Tabs.Main:AddLeftGroupbox("放兵功能")
SpawnGroup:AddToggle("AutoSpawnToggle", { Text = "自动放兵(连发无冷却尝试)", Default = false }):OnChanged(function(v)
    AutoSpawn = v
end)
SpawnGroup:AddToggle("SandboxSpamToggle", { Text = "沙盒放兵(无视花费尝试)", Default = false }):OnChanged(function(v)
    SandboxSpam = v
end)
SpawnGroup:AddLabel("两个开关可同时开,双通道一起发")

local BattleGroup = Tabs.Main:AddRightGroupbox("战斗功能")
BattleGroup:AddToggle("AutoStartToggle", { Text = "自动开始战斗", Default = false }):OnChanged(function(v)
    AutoStart = v
end)
BattleGroup:AddToggle("AutoUpgradeToggle", { Text = "自动升级基地(刷钱优先)", Default = false }):OnChanged(function(v)
    AutoUpgrade = v
end)
BattleGroup:AddLabel("顺序:银行收入>击杀赏金>开局经济")
BattleGroup:AddToggle("AutoDailyToggle", { Text = "自动领取每日奖励", Default = false }):OnChanged(function(v)
    AutoDaily = v
end)
BattleGroup:AddButton("手动领取每日奖励", function()
    pcall(function()
        GetDailyBonusRF:InvokeServer()
    end)
end)
BattleGroup:AddButton("领取徽章奖励", function()
    pcall(function()
        BadgeRewardClaimRF:InvokeServer()
    end)
end)

task.spawn(function()
    while true do
        if AutoSpawn then
            for _, slot in ipairs(Slots) do
                pcall(function()
                    PlayerSpawnRF:InvokeServer(slot)
                end)
                pcall(function()
                    PlayerSpawnRE:FireServer(slot)
                end)
            end
        end
        if SandboxSpam then
            for _, slot in ipairs(Slots) do
                pcall(function()
                    SandboxSpawnRF:InvokeServer(slot)
                end)
            end
        end
        task.wait(0.05)
    end
end)

task.spawn(function()
    while true do
        if AutoSpawn then
            local gui = player.PlayerGui:FindFirstChildOfClass("ScreenGui")
            if gui then
                for _, menuName in ipairs({"SpawnMenu", "MobileSpawnMenu"}) do
                    local menu = gui:FindFirstChild(menuName)
                    if menu then
                        for _, barName in ipairs({"Bar1", "Bar2"}) do
                            local bar = menu:FindFirstChild(barName)
                            if bar then
                                for _, btn in ipairs(bar:GetChildren()) do
                                    if btn:IsA("ImageButton") then
                                        btn.Active = true
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)

task.spawn(function()
    while true do
        if AutoStart then
            pcall(function()
                StartBattleRF:InvokeServer()
            end)
        end
        task.wait(1)
    end
end)

local MoneyUpgrades = {"BankIncome", "EnemyBounty", "EarlyEconomy"}
local UpgradePatterns = {
    function(name) return PurchaseUpgradeRF:InvokeServer("Base", name) end,
    function(name) return PurchaseUpgradeRF:InvokeServer(name) end,
}
local WorkingPattern = nil

local function GetUpgradeLevel(name)
    local ok, val = pcall(function()
        return player.PlayerData.Upgrades.Base[name].Value
    end)
    if ok then return val end
    return nil
end

task.spawn(function()
    while true do
        if AutoUpgrade then
            for _, name in ipairs(MoneyUpgrades) do
                local before = GetUpgradeLevel(name)
                if before then
                    if WorkingPattern then
                        pcall(WorkingPattern, name)
                    else
                        for _, pattern in ipairs(UpgradePatterns) do
                            pcall(pattern, name)
                            task.wait(0.2)
                            local after = GetUpgradeLevel(name)
                            if after and after > before then
                                WorkingPattern = pattern
                                break
                            end
                        end
                    end
                end
                task.wait(0.5)
            end
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        if AutoDaily then
            pcall(function()
                local days = GetDateSinceClaimedRF:InvokeServer()
                if days and tonumber(days) and tonumber(days) >= 1 then
                    GetDailyBonusRF:InvokeServer()
                end
            end)
        end
        task.wait(5)
    end
end)

local UnloadGroup = Tabs.Settings:AddLeftGroupbox("脚本管理") UnloadGroup:AddButton("卸载脚本", function() Library:Unload() end) if ThemeManager then ThemeManager:SetLibrary(Library) ThemeManager:SetFolder("MyScriptTheme") ThemeManager:ApplyToTab(Tabs.Settings) end if SaveManager then SaveManager:SetLibrary(Library) SaveManager:IgnoreThemeSettings() SaveManager:SetFolder("MyScriptConfig") SaveManager:BuildConfigSection(Tabs.Settings) end
