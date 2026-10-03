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
local Remotes = ReplicatedStorage.Assets.Remotes

local KillAura = {
    Enabled = false,
    Range = 12,
    Cooldown = 0.35,
    LastAttack = 0,
    Connection = nil,
    CurrentTarget = nil
}

local AutoKill = {
    Enabled = false,
    Connection = nil,
    CurrentTarget = nil,
    Blacklist = {},
    AttackCount = {},
    MaxAttempts = 15,
    ShieldCooldown = 17
}

local HIT_PARTS = {
    "Torso", "Head", "HumanoidRootPart",
    "Left Leg", "Right Leg", "Left Arm", "Right Arm"
}

local function IsRealPlayer(model)
    if not model then return false end
    local name = model.Name
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name == name and p ~= player then
            return true
        end
    end
    return false
end

local function GetNearbyTarget()
    local char = player.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local charsFolder = workspace:FindFirstChild("Characters")
    if not charsFolder then return nil end
    local bestTarget = nil
    local bestDist = KillAura.Range
    for _, model in ipairs(charsFolder:GetChildren()) do
        if model ~= char then
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            local targetHrp = model:FindFirstChild("HumanoidRootPart")
            if humanoid and targetHrp and humanoid.Health > 0 and IsRealPlayer(model) then
                local dist = (targetHrp.Position - hrp.Position).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    bestTarget = model
                end
            end
        end
    end
    return bestTarget
end

local function GetHitPart(target)
    for _, name in ipairs(HIT_PARTS) do
        local part = target:FindFirstChild(name)
        if part then return part end
    end
    return target:FindFirstChildWhichIsA("BasePart")
end

local function PlayHitEffects(target)
    local char = player.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    local success, AudioHandler = pcall(function()
        return require(ReplicatedStorage.Assets.Modules:WaitForChild("AudioHandler"))
    end)
    if success and AudioHandler then
        local torso = target:FindFirstChild("Torso") or target.PrimaryPart
        if torso then
            AudioHandler.playAudio(tool, torso, {type = "hit", pitch = 1}, true, true)
        end
    end
    local success2, Math = pcall(function()
        return require(ReplicatedStorage.Assets.Modules:WaitForChild("Math"))
    end)
    if success2 and Math then
        local controller = _G.WeaponController or getfenv(0).weaponController
        if controller and controller.springs then
            controller.springs.cameraShake:Impulse(Vector3.new(
                Math.Randomize2(-3.08, 3.08, 0.001),
                Math.Randomize2(-1.848, 1.848, 0.001),
                0
            ))
            controller.springs.cameraShakeRot:Impulse(Vector3.new(
                Math.Randomize2(-1.54, 1.54, 0.001),
                0,
                Math.Randomize2(-0.462, 0.462, 0.001)
            ))
        end
    end
end

local function DoAttack()
    if tick() - KillAura.LastAttack < KillAura.Cooldown then return end
    KillAura.LastAttack = tick()
    local char = player.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    local target = GetNearbyTarget()
    if not target then
        KillAura.CurrentTarget = nil
        return
    end
    KillAura.CurrentTarget = target
    local humanoid = target:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local hitPart = GetHitPart(target)
    if not hitPart then return end
    Remotes.MeleeHitVerification:FireServer(tool, target:FindFirstChildOfClass("Part"), 1)
    Remotes.meleeHit:FireServer(tool, humanoid, 1, hitPart, "false |none")
    PlayHitEffects(target)
end

local function OnHeartbeat()
    if not KillAura.Enabled then return end
    DoAttack()
end

function KillAura:Toggle(state)
    self.Enabled = state
    if state then
        if self.Connection then return end
        self.Connection = RunService.Heartbeat:Connect(OnHeartbeat)
    else
        if self.Connection then
            self.Connection:Disconnect()
            self.Connection = nil
        end
        self.CurrentTarget = nil
    end
end

local function TeleportToTarget(target)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local targetHrp = target:FindFirstChild("HumanoidRootPart")
    if not targetHrp then return end
    hrp.CFrame = CFrame.new(targetHrp.Position + Vector3.new(0, -2, 0))
end

local function IsTargetDead(target)
    if not target or not target.Parent then return true end
    local humanoid = target:FindFirstChildOfClass("Humanoid")
    if not humanoid then return true end
    return humanoid.Health <= 0
end

local function GetTargetHealth(target)
    if not target then return 0 end
    local humanoid = target:FindFirstChildOfClass("Humanoid")
    if not humanoid then return 0 end
    return humanoid.Health
end

local function CheckShield(target)
    local name = target.Name
    local currentHealth = GetTargetHealth(target)
    if not AutoKill.AttackCount[name] then
        AutoKill.AttackCount[name] = {count = 0, lastHealth = currentHealth, startTime = tick()}
    end
    local data = AutoKill.AttackCount[name]
    data.count = data.count + 1
    if data.count >= AutoKill.MaxAttempts then
        if currentHealth >= data.lastHealth then
            AutoKill.Blacklist[name] = tick()
            AutoKill.AttackCount[name] = nil
            Library:Notify("该玩家带有无敌护盾已跳到下一位玩家: " .. name, 3)
            return true
        else
            AutoKill.AttackCount[name] = nil
        end
    end
    return false
end

local function IsBlacklisted(name)
    if not AutoKill.Blacklist[name] then return false end
    if tick() - AutoKill.Blacklist[name] >= AutoKill.ShieldCooldown then
        AutoKill.Blacklist[name] = nil
        return false
    end
    return true
end

local function GetAllAliveRealPlayers()
    local char = player.Character
    if not char then return {} end
    local charsFolder = workspace:FindFirstChild("Characters")
    if not charsFolder then return {} end
    local list = {}
    for _, model in ipairs(charsFolder:GetChildren()) do
        if model ~= char then
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 and IsRealPlayer(model) then
                table.insert(list, model)
            end
        end
    end
    return list
end

local function HasNonBlacklistedTarget()
    local allPlayers = GetAllAliveRealPlayers()
    for _, model in ipairs(allPlayers) do
        if not IsBlacklisted(model.Name) then
            return true
        end
    end
    return false
end

local function AutoKillLoop()
    if not AutoKill.Enabled then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if AutoKill.CurrentTarget and not IsTargetDead(AutoKill.CurrentTarget) then
        if CheckShield(AutoKill.CurrentTarget) then
            AutoKill.CurrentTarget = nil
            return
        end
        TeleportToTarget(AutoKill.CurrentTarget)
        return
    end
    AutoKill.CurrentTarget = nil
    local allPlayers = GetAllAliveRealPlayers()
    local bestTarget = nil
    local bestDist = math.huge
    for _, model in ipairs(allPlayers) do
        if not IsBlacklisted(model.Name) then
            local targetHrp = model:FindFirstChild("HumanoidRootPart")
            if targetHrp then
                local dist = (targetHrp.Position - hrp.Position).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    bestTarget = model
                end
            end
        end
    end
    if not bestTarget then
        for _, model in ipairs(allPlayers) do
            if IsBlacklisted(model.Name) then
                local targetHrp = model:FindFirstChild("HumanoidRootPart")
                if targetHrp then
                    local dist = (targetHrp.Position - hrp.Position).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        bestTarget = model
                    end
                end
            end
        end
    end
    if bestTarget then
        AutoKill.CurrentTarget = bestTarget
        if not AutoKill.AttackCount[bestTarget.Name] then
            AutoKill.AttackCount[bestTarget.Name] = {count = 0, lastHealth = GetTargetHealth(bestTarget), startTime = tick()}
        end
        TeleportToTarget(bestTarget)
    end
end

local function OnAutoKillHeartbeat()
    if not AutoKill.Enabled then return end
    AutoKillLoop()
end

function AutoKill:Toggle(state)
    self.Enabled = state
    if state then
        KillAura:Toggle(true)
        if self.Connection then return end
        self.Connection = RunService.Heartbeat:Connect(OnAutoKillHeartbeat)
    else
        if self.Connection then
            self.Connection:Disconnect()
            self.Connection = nil
        end
        self.CurrentTarget = nil
        self.AttackCount = {}
    end
end

local Window = Library:CreateWindow({
    Title = "通用血布娃娃战斗",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify("通用血布娃娃战斗 - 创作者：Aiove", 5)

local Tabs = {
    General = Window:AddTab("通用", "info"),
    Main = Window:AddTab("战斗", "sword"),
    Settings = Window:AddTab("设置", "settings"),
}

local GeneralGroup = Tabs.General:AddLeftGroupbox("作者消息")
GeneralGroup:AddLabel('Aiove将持续更新此脚本')
GeneralGroup:AddLabel('创作者：Aiove')

local MainGroup = Tabs.Main:AddLeftGroupbox("近战辅助")

MainGroup:AddToggle("KillAuraToggle", {
    Text = "杀戮光环",
    Default = false,
    Tooltip = "开启后自动攻击附近的敌人",
    Callback = function(Value)
        KillAura:Toggle(Value)
    end
})

MainGroup:AddSlider("KillAuraRange", {
    Text = "攻击范围",
    Default = 12,
    Min = 4,
    Max = 30,
    Rounding = 0,
    Callback = function(Value)
        KillAura.Range = Value
    end
})

MainGroup:AddSlider("KillAuraCooldown", {
    Text = "攻击间隔",
    Default = 0.35,
    Min = 0.05,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        KillAura.Cooldown = Value
    end
})

MainGroup:AddToggle("AutoKillToggle", {
    Text = "自动杀人头（需开启杀戮光环）",
    Default = false,
    Tooltip = "开启后自动传送到最近真人脚下并击杀，目标死后换下一个",
    Callback = function(Value)
        AutoKill:Toggle(Value)
    end
})

local SettingsGroup = Tabs.Settings:AddLeftGroupbox("脚本管理")
SettingsGroup:AddButton("卸载脚本", function()
    KillAura:Toggle(false)
    AutoKill:Toggle(false)
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
