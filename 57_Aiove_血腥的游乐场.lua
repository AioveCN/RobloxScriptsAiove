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

local Window = Library:CreateWindow({
    Title = "血腥的游乐场",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify({
    Title = "血腥的游乐场",
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
NoticeGroup:AddLabel('"红旗天下第一"定制')

local attackTP = false
local onlyPlayers = false
local lockOn = false
local antiRagdoll = false
local attackBusy = false
local lockedPlayer = nil
local tpDist = 1.2

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Swing = Remotes:WaitForChild("Swing")
local FireRemote = Remotes:WaitForChild("Fire")

local badStates = {
    [Enum.HumanoidStateType.Ragdoll] = true,
    [Enum.HumanoidStateType.FallingDown] = true,
    [Enum.HumanoidStateType.Physics] = true
}

local atkWords = {"dropkick", "stomp", "punch", "attack", "swing", "hit", "kick", "drag", "grab", "slash", "combat", "throw", "strike", "slam", "uppercut", "smash"}
local blockWords = {"block", "guard", "parry", "defend"}

local function hasWord(name, list)
    local n = string.lower(tostring(name))
    for _, w in ipairs(list) do
        if string.find(n, w, 1, true) then
            return true
        end
    end
    return false
end

local function getChar()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            return char
        end
    end
    return nil
end

local function isValidTarget(model)
    if not model or model == player.Character then return false end
    local root = model:FindFirstChild("HumanoidRootPart")
    local hum = model:FindFirstChildOfClass("Humanoid")
    return root ~= nil and hum ~= nil and hum.Health > 0
end

local function getNearest()
    local char = getChar()
    if not char then return nil end
    local myPos = char.HumanoidRootPart.Position
    local best, bestDist = nil, math.huge
    local seen = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            seen[p.Character] = true
            local sameTeam = player.Team ~= nil and p.Team ~= nil and p.Team == player.Team
            if not sameTeam and isValidTarget(p.Character) then
                local d = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
                if d < bestDist then
                    bestDist = d
                    best = p.Character
                end
            end
        end
    end
    if not onlyPlayers then
        local humans = workspace:FindFirstChild("Humans")
        if humans then
            for _, m in ipairs(humans:GetChildren()) do
                if m:IsA("Model") and not seen[m] and isValidTarget(m) then
                    local d = (m.HumanoidRootPart.Position - myPos).Magnitude
                    if d < bestDist then
                        bestDist = d
                        best = m
                    end
                end
            end
        end
        for _, m in ipairs(workspace:GetChildren()) do
            if m:IsA("Model") and not seen[m] and isValidTarget(m) then
                local d = (m.HumanoidRootPart.Position - myPos).Magnitude
                if d < bestDist then
                    bestDist = d
                    best = m
                end
            end
        end
    end
    return best
end

local function pickTarget()
    if lockOn then
        if lockedPlayer and lockedPlayer.Parent and lockedPlayer.Character and isValidTarget(lockedPlayer.Character) then
            return lockedPlayer.Character
        end
        return nil
    end
    return getNearest()
end

local function teleportBehind()
    local target = pickTarget()
    local char = getChar()
    if not target or not char then return nil, nil, nil end
    local tRoot = target:FindFirstChild("HumanoidRootPart")
    if not tRoot then return nil, nil, nil end
    local root = char.HumanoidRootPart
    local origin = root.CFrame
    root.CFrame = CFrame.new(tRoot.Position - tRoot.CFrame.LookVector * tpDist, tRoot.Position)
    return root, origin, tRoot
end

local function onAttack()
    if attackBusy then return end
    attackBusy = true
    task.spawn(function()
        local root, origin, tRoot = teleportBehind()
        if root and tRoot then
            local t = 0
            while t < 2 do
                if not root.Parent or not tRoot.Parent then break end
                root.CFrame = CFrame.new(tRoot.Position - tRoot.CFrame.LookVector * tpDist, tRoot.Position)
                local dt = task.wait()
                t = t + dt
            end
        else
            task.wait(2)
        end
        if root and root.Parent then
            root.CFrame = origin
        end
        attackBusy = false
    end)
end

pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        if attackTP and not checkcaller() and getnamecallmethod() == "FireServer" then
            if self == Swing or self == FireRemote then
                local isBlock = false
                for _, a in ipairs(args) do
                    if type(a) == "string" and hasWord(a, blockWords) then
                        isBlock = true
                        break
                    end
                end
                if not isBlock then
                    onAttack()
                end
            end
        end
        return oldNamecall(self, ...)
    end)
end)

local function hookChar(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    for state in pairs(badStates) do
        pcall(function() hum:SetStateEnabled(state, false) end)
    end
    hum.StateChanged:Connect(function(_, new)
        if antiRagdoll and badStates[new] then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end)
    local animator = hum:FindFirstChildOfClass("Animator")
    if animator then
        animator.AnimationPlayed:Connect(function(track)
            if attackTP and track.Animation then
                local n = track.Animation.Name
                if hasWord(n, atkWords) and not hasWord(n, blockWords) then
                    onAttack()
                end
            end
        end)
    end
    local function watchTool(tool)
        if tool:IsA("Tool") then
            tool.Activated:Connect(function()
                if attackTP then
                    onAttack()
                end
            end)
        end
    end
    for _, c in ipairs(char:GetChildren()) do
        watchTool(c)
    end
    char.ChildAdded:Connect(watchTool)
    char.DescendantAdded:Connect(function(obj)
        if attackTP and (obj:IsA("Folder") or obj:IsA("ParticleEmitter") or obj:IsA("Sound") or obj:IsA("Model")) and hasWord(obj.Name, atkWords) and not hasWord(obj.Name, blockWords) then
            onAttack()
        end
    end)
end
if player.Character then hookChar(player.Character) end
player.CharacterAdded:Connect(hookChar)

RunService.Heartbeat:Connect(function()
    if not antiRagdoll then return end
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if hum.PlatformStand then hum.PlatformStand = false end
        if badStates[hum:GetState()] then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
    local rc = char:FindFirstChild("RagdollConstraints")
    if rc then
        for _, v in ipairs(rc:GetDescendants()) do
            if v:IsA("BallSocketConstraint") and v.Enabled then
                v.Enabled = false
            end
        end
    end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root and root.Anchored then root.Anchored = false end
end)

local MainGroup = Tabs.Main:AddLeftGroupbox("攻击")
MainGroup:AddToggle("AttackTP", {
    Text = "攻击瞬移",
    Default = false,
    Callback = function(Value)
        attackTP = Value
    end
})
MainGroup:AddToggle("OnlyPlayers", {
    Text = "只锁真人",
    Default = false,
    Callback = function(Value)
        onlyPlayers = Value
    end
})

MainGroup:AddDropdown("PlayerPick", {
    Values = {},
    Multi = false,
    Text = "选定目标",
    Callback = function(Value)
    end
})

local function refreshPlayers()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            table.insert(names, p.Name)
        end
    end
    pcall(function()
        Options.PlayerPick:SetValues(names)
    end)
end
refreshPlayers()
Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(function(p)
    if lockedPlayer == p then
        lockedPlayer = nil
    end
    refreshPlayers()
end)

MainGroup:AddToggle("LockOn", {
    Text = "锁人",
    Default = false,
    Callback = function(Value)
        lockOn = Value
        if Value then
            local name = Options.PlayerPick.Value
            local p = name and Players:FindFirstChild(name)
            if p and p ~= player then
                lockedPlayer = p
            else
                lockedPlayer = nil
                Library:Notify({
                    Title = "锁人",
                    Description = "请先在选定框里选一个玩家",
                    Time = 3,
                })
            end
        else
            lockedPlayer = nil
        end
    end
})

MainGroup:AddSlider("TPDistance", {
    Text = "瞬移距离",
    Default = 1.2,
    Min = 0.5,
    Max = 5,
    Rounding = 1,
    Suffix = "米",
    Callback = function(Value)
        tpDist = Value
    end
})
MainGroup:AddLabel('攻击就瞬到背后并一直面朝他，两秒回原位，格挡不触发')

local ProtectGroup = Tabs.Main:AddRightGroupbox("保护")
ProtectGroup:AddToggle("AntiRagdoll", {
    Text = "防布娃娃摔倒",
    Default = false,
    Callback = function(Value)
        antiRagdoll = Value
    end
})

local UnloadGroup = Tabs.Settings:AddLeftGroupbox("脚本管理")
UnloadGroup:AddButton("卸载脚本", function()
    attackTP = false
    onlyPlayers = false
    lockOn = false
    lockedPlayer = nil
    antiRagdoll = false
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
