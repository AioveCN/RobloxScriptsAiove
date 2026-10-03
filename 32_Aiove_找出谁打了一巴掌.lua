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
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

local Window = Library:CreateWindow({
    Title = "找出谁打了你一巴掌",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify({
    Title = "找出谁打了你一巴掌",
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

local Events = ReplicatedStorage:WaitForChild("Events")
local GroupRewardEvent = Events:WaitForChild("GroupReward")
local SlapEvent = Events:WaitForChild("Slap")
local HitEvent = Events:WaitForChild("Hit")
local ChooseSlapperEvent = Events:WaitForChild("ChooseSlapper")

local MainLeft = Tabs.Main:AddLeftGroupbox("功能")

MainLeft:AddButton("免费领取群组奖励", function()
    local success = pcall(function()
        GroupRewardEvent:FireServer()
    end)
    if success then
        Library:Notify({
            Title = "成功",
            Description = "群组奖励领取请求已发送",
            Time = 3,
        })
    end
end)

local AutoSlapToggle = MainLeft:AddToggle("AutoSlap", {
    Text = "抢扇巴掌",
    Default = false,
    Tooltip = "开启后自动抢扇巴掌",
})

local AutoMaxToggle = MainLeft:AddToggle("AutoMaxPower", {
    Text = "自动打人（可能没伤害）",
    Default = false,
    Tooltip = "开启后自动打人，可能没伤害",
})

local HitModeDropdown = MainLeft:AddDropdown("HitMode", {
    Text = "打人模式（菜鸟模式最稳）",
    Default = "中等",
    Values = {"完美", "中等", "菜鸟"},
    Tooltip = "选择打人时机，菜鸟模式最稳",
})

local AutoDodgeToggle = MainLeft:AddToggle("AutoDodge", {
    Text = "自动闪避",
    Default = false,
    Tooltip = "开启后自动闪避",
})

local DodgeModeDropdown = MainLeft:AddDropdown("DodgeMode", {
    Text = "闪避模式（菜鸟模式最稳）",
    Default = "中等",
    Values = {"完美", "中等", "菜鸟"},
    Tooltip = "选择闪避时机，菜鸟模式最稳",
})

local ShowAttackerToggle = MainLeft:AddToggle("ShowAttacker", {
    Text = "显示最近攻击者",
    Default = false,
    Tooltip = "开启后右上角显示最近的人",
})

local AutoSlapConnection = nil
local AutoSlapHitConnection = nil
local AutoMaxConnection = nil
local AutoDodgeConnection = nil
local AttackerConnection = nil
local LastSlapTime = 0
local AutoSlapPending = false

local AttackerGui = Instance.new("ScreenGui")
AttackerGui.Name = "AttackerAlert"
AttackerGui.ResetOnSpawn = false
AttackerGui.Parent = player:WaitForChild("PlayerGui")

local AttackerFrame = Instance.new("Frame")
AttackerFrame.Name = "AttackerFrame"
AttackerFrame.Size = UDim2.new(0, 250, 0, 70)
AttackerFrame.Position = UDim2.new(1, -260, 0, 10)
AttackerFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
AttackerFrame.BackgroundTransparency = 0.2
AttackerFrame.BorderSizePixel = 0
AttackerFrame.Visible = false
AttackerFrame.Parent = AttackerGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 8)
FrameCorner.Parent = AttackerFrame

local AttackerImage = Instance.new("ImageLabel")
AttackerImage.Name = "AttackerImage"
AttackerImage.Size = UDim2.new(0, 55, 0, 55)
AttackerImage.Position = UDim2.new(0, 7, 0, 7)
AttackerImage.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AttackerImage.BackgroundTransparency = 0.3
AttackerImage.BorderSizePixel = 0
AttackerImage.Image = ""
AttackerImage.Parent = AttackerFrame

local ImageCorner = Instance.new("UICorner")
ImageCorner.CornerRadius = UDim.new(0, 6)
ImageCorner.Parent = AttackerImage

local AttackerText = Instance.new("TextLabel")
AttackerText.Name = "AttackerText"
AttackerText.Size = UDim2.new(0, 175, 0, 60)
AttackerText.Position = UDim2.new(0, 68, 0, 5)
AttackerText.BackgroundTransparency = 1
AttackerText.Text = ""
AttackerText.TextColor3 = Color3.fromRGB(255, 0, 0)
AttackerText.TextSize = 16
AttackerText.Font = Enum.Font.SourceSansBold
AttackerText.TextWrapped = true
AttackerText.TextStrokeTransparency = 0
AttackerText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
AttackerText.TextXAlignment = Enum.TextXAlignment.Left
AttackerText.TextYAlignment = Enum.TextYAlignment.Center
AttackerText.Parent = AttackerFrame

local function GetCharacterPos(plr)
    local char = plr.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        return char.HumanoidRootPart.Position
    end
    return nil
end

local function GetMyPos()
    return GetCharacterPos(player)
end

local function GetDistanceToPlayer(plr)
    local myPos = GetMyPos()
    local theirPos = GetCharacterPos(plr)
    if myPos and theirPos then
        return (myPos - theirPos).Magnitude
    end
    return math.huge
end

local function GetNearestPlayer()
    local nearest = nil
    local minDist = math.huge
    for _, plr in Players:GetPlayers() do
        if plr ~= player then
            local dist = GetDistanceToPlayer(plr)
            if dist < minDist then
                minDist = dist
                nearest = plr
            end
        end
    end
    return nearest, minDist
end

local function getCurrentArena()
    local arenaName = player:GetAttribute("Arena")
    if arenaName then
        return workspace.Arenas:FindFirstChild(arenaName)
    end
    return nil
end

local function isInGame()
    return player:GetAttribute("InGame") == true
end

local function UpdateAttackerDisplay()
    local nearest, dist = GetNearestPlayer()
    if nearest and dist <= 4 then
        AttackerFrame.Visible = true
        AttackerText.Text = "最有可能打到你的人\n" .. nearest.Name .. " (" .. math.floor(dist) .. "米)"
        local success, image = pcall(function()
            return Players:GetUserThumbnailAsync(nearest.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        end)
        if success and image then
            AttackerImage.Image = image
        end
    else
        AttackerFrame.Visible = false
    end
end

local function FireHitAllWays(pos)
    pcall(function()
        HitEvent:FireServer(pos)
    end)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
    pcall(function()
        if UserInputService.TouchEnabled then
            VirtualInputManager:SendTouchEvent(0, 0, 0, true, game, 0)
            task.wait(0.05)
            VirtualInputManager:SendTouchEvent(0, 0, 0, false, game, 0)
        end
    end)
end

local function GetModeDelay(mode)
    if mode == "菜鸟" then
        return 0
    elseif mode == "中等" then
        return 0.3
    elseif mode == "完美" then
        return 0.55
    end
    return 0.3
end

local function SetupAutoMaxPower()
    if AutoMaxConnection then
        AutoMaxConnection:Disconnect()
        AutoMaxConnection = nil
    end
    if not Toggles.AutoMaxPower.Value then return end
    local mode = Options.HitMode.Value
    AutoMaxConnection = SlapEvent.OnClientEvent:Connect(function(arena, timestamp)
        if typeof(timestamp) ~= "number" then
            timestamp = workspace:GetServerTimeNow()
        end
        local delay = GetModeDelay(mode)
        task.delay(delay, function()
            local currentArena = getCurrentArena()
            if currentArena and arena and currentArena.Name == arena.Name then
                if currentArena:GetAttribute("Slapper") ~= "" then
                    if mode == "菜鸟" then
                        FireHitAllWays(1)
                    else
                        pcall(function()
                            HitEvent:FireServer(1)
                        end)
                    end
                end
            end
        end)
    end)
end

local function SetupAutoDodge()
    if AutoDodgeConnection then
        AutoDodgeConnection:Disconnect()
        AutoDodgeConnection = nil
    end
    if not Toggles.AutoDodge.Value then return end
    local mode = Options.DodgeMode.Value
    AutoDodgeConnection = SlapEvent.OnClientEvent:Connect(function(arena, timestamp)
        if typeof(timestamp) ~= "number" then
            timestamp = workspace:GetServerTimeNow()
        end
        local delay = GetModeDelay(mode)
        task.delay(delay, function()
            local currentArena = getCurrentArena()
            if currentArena and arena and currentArena.Name == arena.Name then
                if currentArena:GetAttribute("Slapper") ~= "" then
                    if mode == "菜鸟" then
                        FireHitAllWays(1)
                    else
                        pcall(function()
                            HitEvent:FireServer(1)
                        end)
                    end
                end
            end
        end)
    end)
end

Toggles.AutoSlap:OnChanged(function()
    if Toggles.AutoSlap.Value then
        if AutoSlapConnection then
            AutoSlapConnection:Disconnect()
            AutoSlapConnection = nil
        end
        if AutoSlapHitConnection then
            AutoSlapHitConnection:Disconnect()
            AutoSlapHitConnection = nil
        end
        AutoSlapHitConnection = SlapEvent.OnClientEvent:Connect(function(arena, timestamp)
            if not AutoSlapPending then return end
            AutoSlapPending = false
            local currentArena = getCurrentArena()
            if currentArena and arena and currentArena.Name == arena.Name then
                if currentArena:GetAttribute("Slapper") ~= "" then
                    local mode = Options.HitMode.Value
                    local delay = GetModeDelay(mode)
                    task.delay(delay, function()
                        if mode == "菜鸟" then
                            FireHitAllWays(1)
                        else
                            pcall(function()
                                HitEvent:FireServer(1)
                            end)
                        end
                    end)
                end
            end
        end)
        AutoSlapConnection = RunService.Heartbeat:Connect(function()
            if not isInGame() then return end
            local now = tick()
            if now - LastSlapTime < 1.5 then return end
            local arena = getCurrentArena()
            if arena and arena:GetAttribute("Slapper") == "" then
                LastSlapTime = now
                AutoSlapPending = true
                local nearest, dist = GetNearestPlayer()
                if nearest and dist <= 15 then
                    pcall(function()
                        ChooseSlapperEvent:FireServer(nearest.Name)
                    end)
                    task.wait(0.1)
                end
                pcall(function()
                    SlapEvent:FireServer()
                end)
            end
        end)
        Library:Notify({
            Title = "抢扇巴掌",
            Description = "已开启",
            Time = 2,
        })
    else
        if AutoSlapConnection then
            AutoSlapConnection:Disconnect()
            AutoSlapConnection = nil
        end
        if AutoSlapHitConnection then
            AutoSlapHitConnection:Disconnect()
            AutoSlapHitConnection = nil
        end
        AutoSlapPending = false
        Library:Notify({
            Title = "抢扇巴掌",
            Description = "已关闭",
            Time = 2,
        })
    end
end)

Toggles.AutoMaxPower:OnChanged(function()
    if Toggles.AutoMaxPower.Value then
        SetupAutoMaxPower()
        Library:Notify({
            Title = "自动打人（可能没伤害）",
            Description = "已开启，模式：" .. Options.HitMode.Value,
            Time = 2,
        })
    else
        if AutoMaxConnection then
            AutoMaxConnection:Disconnect()
            AutoMaxConnection = nil
        end
        Library:Notify({
            Title = "自动打人（可能没伤害）",
            Description = "已关闭",
            Time = 2,
        })
    end
end)

HitModeDropdown:OnChanged(function()
    if Toggles.AutoMaxPower.Value then
        SetupAutoMaxPower()
        Library:Notify({
            Title = "自动打人（可能没伤害）",
            Description = "模式切换为：" .. Options.HitMode.Value,
            Time = 2,
        })
    end
    if Toggles.AutoSlap.Value then
        Library:Notify({
            Title = "抢扇巴掌",
            Description = "打人模式切换为：" .. Options.HitMode.Value,
            Time = 2,
        })
    end
end)

Toggles.AutoDodge:OnChanged(function()
    if Toggles.AutoDodge.Value then
        SetupAutoDodge()
        Library:Notify({
            Title = "自动闪避",
            Description = "已开启，模式：" .. Options.DodgeMode.Value,
            Time = 2,
        })
    else
        if AutoDodgeConnection then
            AutoDodgeConnection:Disconnect()
            AutoDodgeConnection = nil
        end
        Library:Notify({
            Title = "自动闪避",
            Description = "已关闭",
            Time = 2,
        })
    end
end)

DodgeModeDropdown:OnChanged(function()
    if Toggles.AutoDodge.Value then
        SetupAutoDodge()
        Library:Notify({
            Title = "自动闪避",
            Description = "模式切换为：" .. Options.DodgeMode.Value,
            Time = 2,
        })
    end
end)

Toggles.ShowAttacker:OnChanged(function()
    if Toggles.ShowAttacker.Value then
        if AttackerConnection then
            AttackerConnection:Disconnect()
            AttackerConnection = nil
        end
        AttackerConnection = RunService.Heartbeat:Connect(function()
            UpdateAttackerDisplay()
        end)
        Library:Notify({
            Title = "显示最近攻击者",
            Description = "已开启",
            Time = 2,
        })
    else
        if AttackerConnection then
            AttackerConnection:Disconnect()
            AttackerConnection = nil
        end
        AttackerFrame.Visible = false
        Library:Notify({
            Title = "显示最近攻击者",
            Description = "已关闭",
            Time = 2,
        })
    end
end)

local UnloadGroup = Tabs.Settings:AddLeftGroupbox("脚本管理")
UnloadGroup:AddButton("卸载脚本", function()
    if AutoSlapConnection then AutoSlapConnection:Disconnect() end
    if AutoSlapHitConnection then AutoSlapHitConnection:Disconnect() end
    if AutoMaxConnection then AutoMaxConnection:Disconnect() end
    if AutoDodgeConnection then AutoDodgeConnection:Disconnect() end
    if AttackerConnection then AttackerConnection:Disconnect() end
    if AttackerGui then AttackerGui:Destroy() end
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
