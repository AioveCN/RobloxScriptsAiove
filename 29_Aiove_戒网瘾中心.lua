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
local LocalPlayer = Players.LocalPlayer

local Window = Library:CreateWindow({
    Title = "戒网瘾中心",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify({
    Title = "戒网瘾中心",
    Description = "创作者：Aiove\nQQ：3999698324\n脚本已加载成功",
    Time = 5,
})

local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Main = Window:AddTab("主要", "info"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel("Aiove将持续更新此脚本")
NoticeGroup:AddLabel("创作者：Aiove")

local CombatEnabled = false
local targetCount = 1
local WalkSpeedValue = 16
local killRange = 20
local killDelay = 0.3

local RandomFollowEnabled = false
local currentTarget = nil
local followDistance = 4
local orbitSpeed = 20

local function getAllNilInstances(name, class)
    local found = {}
    if getnilinstances then
        for _, v in next, getnilinstances() do
            if v.Name == name and (not class or v.ClassName == class) then
                table.insert(found, v)
            end
        end
    end
    return found
end

local function getNearestPlayers(count)
    local targetList = {}
    local lChar = LocalPlayer.Character
    local lRoot = lChar and lChar:FindFirstChild("HumanoidRootPart")
    if not lRoot then return targetList end

    local playersWithDist = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local distance = (lRoot.Position - root.Position).Magnitude
                table.insert(playersWithDist, {player = player, dist = distance, root = root})
            end
        end
    end
    table.sort(playersWithDist, function(a, b) return a.dist < b.dist end)
    for i = 1, math.min(count, #playersWithDist) do
        table.insert(targetList, playersWithDist[i])
    end
    return targetList
end

local function getRandomPlayer()
    local allPlayers = Players:GetPlayers()
    local eligiblePlayers = {}
    for _, p in pairs(allPlayers) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(eligiblePlayers, p)
        end
    end
    if #eligiblePlayers > 0 then
        return eligiblePlayers[math.random(1, #eligiblePlayers)]
    else
        return nil
    end
end

local MainGroup = Tabs.Main:AddLeftGroupbox("主要功能")

MainGroup:AddToggle("KillAura", {
    Text = "杀戮光环",
    Default = false,
    Callback = function(Value)
        CombatEnabled = Value
    end,
})

MainGroup:AddSlider("KillRange", {
    Text = "杀戮距离",
    Default = 20,
    Min = 5,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        killRange = Value
    end,
})

MainGroup:AddSlider("KillDelay", {
    Text = "杀戮触发速度",
    Default = 0.3,
    Min = 0.1,
    Max = 2,
    Rounding = 1,
    Callback = function(Value)
        killDelay = Value
    end,
})

MainGroup:AddToggle("RandomFollow", {
    Text = "传送全部人",
    Default = false,
    Callback = function(Value)
        RandomFollowEnabled = Value
        if not Value then
            currentTarget = nil
        end
    end,
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
        task.wait(killDelay)
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed ~= WalkSpeedValue then
            hum.WalkSpeed = WalkSpeedValue
        end

        if CombatEnabled then
            if hum then
                local equippedTool = char:FindFirstChildOfClass("Tool")
                if not equippedTool then
                    local backpack = LocalPlayer:FindFirstChild("Backpack")
                    local firstTool = backpack and backpack:FindFirstChildOfClass("Tool")
                    if firstTool then
                        hum:EquipTool(firstTool)
                    end
                end
            end

            local targets = {}
            for _, t in ipairs(getNearestPlayers(10)) do
                if t.dist <= killRange and #targets < targetCount then
                    table.insert(targets, t)
                end
            end
            local nilParts = getAllNilInstances("Part", "Part")
            if #targets > 0 then
                local character = LocalPlayer.Character
                local fist = character and character:FindFirstChild("\230\139\179\229\164\180") or character:FindFirstChildOfClass("Tool")

                for i, part in ipairs(nilParts) do
                    local targetData = targets[(i % #targets) + 1]
                    if targetData and targetData.root then
                        if part:IsA("BasePart") then
                            part.CFrame = targetData.root.CFrame
                        elseif part:IsA("Model") then
                            part:SetPrimaryPartCFrame(targetData.root.CFrame)
                        end
                    end
                end

                if fist and fist:FindFirstChild("Attack") then
                    for _, targetData in ipairs(targets) do
                        fist.Attack:FireServer(targetData.player)
                    end
                end
            end
        end
    end
end)

RunService.Stepped:Connect(function()
    if RandomFollowEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

task.spawn(function()
    while true do
        if RandomFollowEnabled then
            local nextPlayer = getRandomPlayer()
            if nextPlayer then
                currentTarget = nextPlayer
            end
            task.wait(4)
        else
            task.wait(0.5)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if RandomFollowEnabled and currentTarget and currentTarget.Character then
        local targetRoot = currentTarget.Character:FindFirstChild("HumanoidRootPart")
        local myCharacter = LocalPlayer.Character
        local myRoot = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")

        if targetRoot and myRoot then
            local t = tick() * orbitSpeed
            local offsetX = math.cos(t) * followDistance
            local offsetZ = math.sin(t) * followDistance
            local orbitPosition = targetRoot.Position + Vector3.new(offsetX, 0, offsetZ)
            myRoot.CFrame = CFrame.new(orbitPosition, targetRoot.Position)
        end
    end
end)
