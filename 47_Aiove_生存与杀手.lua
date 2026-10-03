-- This file has been deobfuscated Luraph using Hurricane https://discord.com/invite/AbeurBzKXe
local env = (type(getgenv) == "function" or type(getgenv) == "table") and getgenv() or shared
local function safeLoad(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not success then
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "加载失败",
                Text = url,
                Duration = 5,
            })
        end)
        return nil
    end
    return result
end
local Library = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/黑曜石主库.ui")
local ThemeManager = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/主题管理.ui")
local SaveManager = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/配置管理.ui")
if not Library then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "错误",
            Text = "UI 库加载失败，请检查网络或脚本资源",
            Duration = 5,
        })
    end)
    return
end
local Options = Library.Options
local Toggles = Library.Toggles
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
env.AutoLootTeleport = false
env.KillAll = false
env.AutoBreakFree = false
env.ESP_Enabled = false
env.NightVisionEnabled = false
env.NoclipEnabled = false
env.InfiniteJumpEnabled = false
local Window = Library:CreateWindow({
    Title = "生存于杀手",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})
Library:Notify({
    Title = "生存于杀手",
    Description = "创作者：Aiove\nQQ：3999698324\n脚本已加载成功",
    Time = 5,
})
local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Main = Window:AddTab("主要", "info"),
    Visuals = Window:AddTab("透视", "eye"),
    Settings = Window:AddTab("设置", "settings"),
}
local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel("Aiove将持续更新此脚本")
NoticeGroup:AddLabel("创作者：Aiove")
local CombatGroup = Tabs.Main:AddLeftGroupbox("战斗功能")
local AssistGroup = Tabs.Main:AddLeftGroupbox("辅助功能")
local function teleportToPosition(position)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    pcall(function()
        local tween = TweenService:Create(hrp, TweenInfo.new(0.3), {CFrame = CFrame.new(position)})
        tween:Play()
        tween.Completed:Wait()
    end)
end
CombatGroup:AddToggle("AutoLoot", {
    Text = "自动寻找物品",
    Default = false,
})
Toggles.AutoLoot:OnChanged(function()
    local state = Toggles.AutoLoot.Value
    env.AutoLootTeleport = state
    if state then
        Library:Notify({ Title = "自动传送", Description = "开始传送物品", Time = 2 })
        task.spawn(function()
            while env.AutoLootTeleport do
                local foundAny = false
                for _, child in ipairs(Workspace:GetChildren()) do
                    if not env.AutoLootTeleport then break end
                    if child:IsA("Model") or child:IsA("Folder") then
                        local lootSpawns = child:FindFirstChild("LootSpawns")
                        if lootSpawns then
                            foundAny = true
                            for _, lootModel in ipairs(lootSpawns:GetChildren()) do
                                if not env.AutoLootTeleport then break end
                                local targetPos
                                if lootModel:IsA("Model") then
                                    targetPos = lootModel.PrimaryPart and lootModel.PrimaryPart.Position
                                    if not targetPos then
                                        pcall(function()
                                            targetPos = lootModel:GetBoundingBox().Position
                                        end)
                                    end
                                elseif lootModel:IsA("BasePart") then
                                    targetPos = lootModel.Position
                                end
                                if targetPos then
                                    teleportToPosition(targetPos)
                                    task.wait(0.5)
                                end
                            end
                        end
                    end
                end
                task.wait(foundAny and 2 or 5)
            end
        end)
    end
end)
CombatGroup:AddToggle("KillAll", {
    Text = "全图杀戮",
    Default = false,
})
Toggles.KillAll:OnChanged(function()
    local state = Toggles.KillAll.Value
    env.KillAll = state
    if state then
        Library:Notify({ Title = "杀戮开启", Description = "正在自动锁定所有玩家", Time = 2 })
        task.spawn(function()
            while env.KillAll do
                pcall(function()
                    local knife = player.Character and player.Character:FindFirstChild("Knife")
                    local event = knife and knife:FindFirstChild("KnifeSlashEvent")
                    if event then event:FireServer() end
                end)
                task.wait(0.1)
            end
        end)
        task.spawn(function()
            while env.KillAll do
                for _, targetPlayer in ipairs(Players:GetPlayers()) do
                    if not env.KillAll then break end
                    if targetPlayer ~= player and targetPlayer.Character then
                        local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if rootPart and targetRoot then
                            pcall(function()
                                rootPart.CFrame = targetRoot.CFrame * CFrame.new(0, 2, 0)
                            end)
                            task.wait(0.5)
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)
CombatGroup:AddToggle("AutoBreakFree", {
    Text = "自动解陷阱",
    Default = false,
})
Toggles.AutoBreakFree:OnChanged(function()
    local state = Toggles.AutoBreakFree.Value
    env.AutoBreakFree = state
    if state then
        task.spawn(function()
            local breakFreeEvent = ReplicatedStorage:FindFirstChild("BreakFree")
            while env.AutoBreakFree do
                pcall(function()
                    if breakFreeEvent then breakFreeEvent:FireServer() end
                end)
                task.wait(0.1)
            end
        end)
    end
end)
AssistGroup:AddButton("传送回家", function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        pcall(function()
            hrp.CFrame = CFrame.new(19.7, 262.9, -90.6)
        end)
        Library:Notify({ Title = "传送回家", Description = "已传送到安全点", Time = 2 })
    end
end)
local originalLighting = {}
local function saveOriginalLighting()
    pcall(function()
        originalLighting.Ambient = Lighting.Ambient
        originalLighting.ColorShift_Bottom = Lighting.ColorShift_Bottom
        originalLighting.ColorShift_Top = Lighting.ColorShift_Top
        originalLighting.FogEnd = Lighting.FogEnd
        originalLighting.FogStart = Lighting.FogStart
        originalLighting.Brightness = Lighting.Brightness
        originalLighting.GlobalShadows = Lighting.GlobalShadows
        originalLighting.OutdoorAmbient = Lighting.OutdoorAmbient
        originalLighting.ClockTime = Lighting.ClockTime
    end)
end
local function enableNightVision()
    if not originalLighting.Ambient then saveOriginalLighting() end
    pcall(function()
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
        Lighting.ColorShift_Top = Color3.new(1, 1, 1)
        Lighting.FogEnd = 100000
        Lighting.FogStart = 100000
        Lighting.Brightness = 1
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.ClockTime = 12
    end)
end
local function disableNightVision()
    if originalLighting.Ambient then
        pcall(function()
            Lighting.Ambient = originalLighting.Ambient
            Lighting.ColorShift_Bottom = originalLighting.ColorShift_Bottom
            Lighting.ColorShift_Top = originalLighting.ColorShift_Top
            Lighting.FogEnd = originalLighting.FogEnd
            Lighting.FogStart = originalLighting.FogStart
            Lighting.Brightness = originalLighting.Brightness
            Lighting.GlobalShadows = originalLighting.GlobalShadows
            Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
            Lighting.ClockTime = originalLighting.ClockTime
        end)
    end
end
AssistGroup:AddToggle("NightVision", {
    Text = "夜视",
    Default = false,
})
Toggles.NightVision:OnChanged(function()
    local state = Toggles.NightVision.Value
    env.NightVisionEnabled = state
    if state then
        enableNightVision()
        Library:Notify({ Title = "夜视", Description = "已开启", Time = 3 })
    else
        disableNightVision()
        Library:Notify({ Title = "夜视", Description = "已关闭", Time = 3 })
    end
end)
local noclipConnection
local function startNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    noclipConnection = RunService.Stepped:Connect(function()
        if not env.NoclipEnabled then return end
        local char = player.Character
        if not char then return end
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end)
end
local function stopNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    noclipConnection = nil
    local char = player.Character
    if char then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") and not v.CanCollide then
                v.CanCollide = true
            end
        end
    end
end
AssistGroup:AddToggle("Noclip", {
    Text = "穿墙",
    Default = false,
})
Toggles.Noclip:OnChanged(function()
    local state = Toggles.Noclip.Value
    env.NoclipEnabled = state
    if state then
        startNoclip()
        Library:Notify({ Title = "穿墙", Description = "已开启", Time = 3 })
    else
        stopNoclip()
        Library:Notify({ Title = "穿墙", Description = "已关闭", Time = 3 })
    end
end)
UserInputService.JumpRequest:Connect(function()
    if env.InfiniteJumpEnabled then
        local char = player.Character
        if char then
            local HRP = char:FindFirstChild("HumanoidRootPart")
            if HRP then
                pcall(function()
                    HRP.Velocity = Vector3.new(HRP.Velocity.X, 50, HRP.Velocity.Z)
                end)
            end
        end
    end
end)
AssistGroup:AddToggle("InfiniteJump", {
    Text = "无限跳",
    Default = false,
})
Toggles.InfiniteJump:OnChanged(function()
    local state = Toggles.InfiniteJump.Value
    env.InfiniteJumpEnabled = state
    Library:Notify({ Title = "无限跳", Description = state and "已开启" or "已关闭", Time = 3 })
end)
AssistGroup:AddButton("飞行", function()
    Library:Notify({ Title = "飞行脚本", Description = "正在加载中...", Time = 5 })
    task.spawn(function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/kongbaNB/9178/refs/heads/main/fly.lua"))()
        end)
    end)
end)
local espBillboards = {}
local function enableESP(targetPlayer)
    if targetPlayer == player then return end
    local char = targetPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    pcall(function()
        if not char:FindFirstChild("EspHighlight") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "EspHighlight"
            highlight.Parent = char
            highlight.FillTransparency = 0.5
            highlight.FillColor = Color3.fromRGB(255, 255, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end
        if not hrp:FindFirstChild("EspBillboard") then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "EspBillboard"
            billboard.Parent = hrp
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Name = "NameLabel"
            nameLabel.Parent = billboard
            nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = targetPlayer.Name
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            nameLabel.TextStrokeTransparency = 0
            nameLabel.TextSize = 14
            nameLabel.Font = Enum.Font.SourceSansBold
            local distLabel = Instance.new("TextLabel")
            distLabel.Name = "DistLabel"
            distLabel.Parent = billboard
            distLabel.Size = UDim2.new(1, 0, 0.5, 0)
            distLabel.Position = UDim2.new(0, 0, 0.5, 0)
            distLabel.BackgroundTransparency = 1
            distLabel.Text = "0m"
            distLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            distLabel.TextStrokeTransparency = 0
            distLabel.TextSize = 12
            distLabel.Font = Enum.Font.SourceSans
            espBillboards[targetPlayer] = billboard
        end
    end)
end
local function disableESP(targetPlayer)
    pcall(function()
        local char = targetPlayer.Character
        if char then
            if char:FindFirstChild("EspHighlight") then
                char.EspHighlight:Destroy()
            end
            if char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart:FindFirstChild("EspBillboard") then
                char.HumanoidRootPart.EspBillboard:Destroy()
            end
        end
        espBillboards[targetPlayer] = nil
    end)
end
RunService.RenderStepped:Connect(function()
    if not env.ESP_Enabled then return end
    local myChar = player.Character
    local myPos = myChar and myChar:FindFirstChild("HumanoidRootPart") and myChar.HumanoidRootPart.Position
    for targetPlayer, billboard in pairs(espBillboards) do
        pcall(function()
            if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and billboard and billboard.Parent then
                local distLabel = billboard:FindFirstChild("DistLabel")
                if distLabel and myPos then
                    local dist = (targetPlayer.Character.HumanoidRootPart.Position - myPos).Magnitude
                    distLabel.Text = string.format("%.0fm", dist)
                end
            end
        end)
    end
end)
Players.PlayerAdded:Connect(function(targetPlayer)
    targetPlayer.CharacterAdded:Connect(function(char)
        char:WaitForChild("HumanoidRootPart")
        if env.ESP_Enabled then
            enableESP(targetPlayer)
        end
    end)
end)
Players.PlayerRemoving:Connect(function(targetPlayer)
    disableESP(targetPlayer)
end)
local VisualsGroup = Tabs.Visuals:AddLeftGroupbox("玩家透视")
VisualsGroup:AddToggle("ESP", {
    Text = "玩家透视",
    Default = false,
})
Toggles.ESP:OnChanged(function()
    local state = Toggles.ESP.Value
    env.ESP_Enabled = state
    if state then
        Library:Notify({ Title = "透视", Description = "已开启玩家透视", Time = 2 })
        for _, p in pairs(Players:GetPlayers()) do
            enableESP(p)
        end
    else
        for _, p in pairs(Players:GetPlayers()) do
            disableESP(p)
        end
    end
end)
local UnloadGroup = Tabs.Settings:AddLeftGroupbox("脚本管理")
UnloadGroup:AddButton("卸载脚本", function()
    Library:Unload()
end)
if ThemeManager then
    pcall(function()
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("MyScriptTheme")
        ThemeManager:ApplyToTab(Tabs.Settings)
    end)
end
if SaveManager then
    pcall(function()
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetFolder("MyScriptConfig")
        SaveManager:BuildConfigSection(Tabs.Settings)
    end)
end
