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

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

local Window = Library:CreateWindow({
    Title = "自然灾害",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify({
    Title = "自然灾害",
    Description = "创作者：Aiove\nQQ：3999698324\n脚本已加载成功",
    Time = 5,
})

local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Main = Window:AddTab("主要", "info"),
    BlackHole = Window:AddTab("黑洞", "zap"),
    Command = Window:AddTab("指令", "terminal"),
    MindPower = Window:AddTab("念力", "wind"),
    Teleport = Window:AddTab("传送", "map"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel("Aiove将持续更新此脚本")
NoticeGroup:AddLabel("创作者：Aiove")

local VirtualUserService = game:GetService("VirtualUser")
player.Idled:Connect(function()
    VirtualUserService:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUserService:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

local MainLeft = Tabs.Main:AddLeftGroupbox("灾害生存")
local MainRight = Tabs.Main:AddRightGroupbox("辅助功能")

MainLeft:AddToggle("AutoWin", {
    Text = "自动存活",
    Default = false,
    Callback = function(Value)
        _G.autowinfarm = Value
        task.spawn(function()
            while _G.autowinfarm do
                pcall(function()
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-236, 180, 360, 1, 0, 0, 0, 1, 0, 0, 0, 1)
                end)
                task.wait(0.1)
            end
        end)
    end
})

MainLeft:AddLabel("当前灾难: 无")

local DisasterDetectionEnabled = false
local LastDisasterType = ""

MainLeft:AddToggle("DisasterDetect", {
    Text = "预测灾害文字显示",
    Default = false,
    Callback = function(Value)
        DisasterDetectionEnabled = Value
        LastDisasterType = ""
        task.spawn(function()
            while DisasterDetectionEnabled do
                pcall(function()
                    local PlayerDisplayName = player.DisplayName
                    local PlayerWorkspaceModel = workspace:FindFirstChild(PlayerDisplayName)
                    if PlayerWorkspaceModel then
                        local SurvivalTagValue = PlayerWorkspaceModel:FindFirstChild("SurvivalTag")
                        if SurvivalTagValue then
                            local DisasterEnglishName = SurvivalTagValue.Value
                            local map = {
                                Blizzard = "暴风雪",
                                Sandstorm = "沙尘暴",
                                Tornado = "龙卷风",
                                ["Volcanic Eruption"] = "火山",
                                ["Flash Flood"] = "洪水",
                                ["Deadly Virus"] = "病毒",
                                Tsunami = "海啸",
                                ["Acid Rain"] = "酸雨",
                                Fire = "火焰",
                                ["Meteor Shower"] = "流星雨",
                                Earthquake = "地震",
                                ["Thunder Storm"] = "暴风雨",
                            }
                            local DisasterChineseName = map[DisasterEnglishName] or "未知灾难"
                            if DisasterEnglishName ~= LastDisasterType then
                                LastDisasterType = DisasterEnglishName
                            end
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    end
})

local NotificationDisasterEnabled = false
local LastNotificationDisaster = ""

MainLeft:AddToggle("DisasterNotify", {
    Text = "预测灾害通知提醒",
    Default = false,
    Callback = function(Value)
        NotificationDisasterEnabled = Value
        if Value then
            Library:Notify({
                Title = "自然灾害",
                Description = "预测灾害 已开启",
                Time = 3,
            })
        else
            Library:Notify({
                Title = "自然灾害",
                Description = "预测灾害 已关闭",
                Time = 3,
            })
        end
        LastNotificationDisaster = ""
        task.spawn(function()
            while NotificationDisasterEnabled do
                pcall(function()
                    local PlayerDisplayName = player.DisplayName
                    local PlayerWorkspaceModel = workspace:FindFirstChild(PlayerDisplayName)
                    local SurvivalTagValue = PlayerWorkspaceModel and PlayerWorkspaceModel:FindFirstChild("SurvivalTag")
                    if SurvivalTagValue then
                        local DisasterEnglishName = SurvivalTagValue.Value
                        local map = {
                            Blizzard = "本局灾害：暴风雪",
                            Sandstorm = "本局灾害：沙尘暴",
                            Tornado = "本局灾害：龙卷风",
                            ["Volcanic Eruption"] = "本局灾害：火山",
                            ["Flash Flood"] = "本局灾害：洪水",
                            ["Deadly Virus"] = "本局灾害：病毒",
                            Tsunami = "本局灾害：海啸",
                            ["Acid Rain"] = "本局灾害：酸雨",
                            Fire = "本局灾害：火焰",
                            ["Meteor Shower"] = "本局灾害：流星雨",
                            Earthquake = "本局灾害：地震",
                            ["Thunder Storm"] = "本局灾害：暴风雨",
                        }
                        local DisasterNotificationText = map[DisasterEnglishName] or ""
                        if DisasterNotificationText ~= "" and DisasterEnglishName ~= LastNotificationDisaster then
                            Library:Notify({
                                Title = "自然灾害",
                                Description = DisasterNotificationText,
                                Time = 3,
                            })
                            LastNotificationDisaster = DisasterEnglishName
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    end
})

local ChatDisasterEnabled = false
local LastChatDisaster = ""

local function SendChatMessage(MessageText)
    if TextChatService.ChatVersion ~= Enum.ChatVersion.TextChatService then
        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(MessageText, "All")
    else
        TextChatService.TextChannels.RBXGeneral:SendAsync(MessageText)
    end
end

MainLeft:AddToggle("DisasterChat", {
    Text = "预测灾害聊天通知",
    Default = false,
    Callback = function(Value)
        ChatDisasterEnabled = Value
        LastChatDisaster = ""
        task.spawn(function()
            while ChatDisasterEnabled do
                pcall(function()
                    local PlayerDisplayName = player.DisplayName
                    local PlayerWorkspaceModel = workspace:FindFirstChild(PlayerDisplayName)
                    local SurvivalTagValue = PlayerWorkspaceModel and PlayerWorkspaceModel:FindFirstChild("SurvivalTag")
                    if SurvivalTagValue then
                        local DisasterEnglishName = SurvivalTagValue.Value
                        local map = {
                            Blizzard = "暴风雪",
                            Sandstorm = "沙尘暴",
                            Tornado = "龙卷风",
                            ["Volcanic Eruption"] = "火山",
                            ["Flash Flood"] = "洪水",
                            ["Deadly Virus"] = "病毒",
                            Tsunami = "海啸",
                            ["Acid Rain"] = "酸雨",
                            Fire = "火焰",
                            ["Meteor Shower"] = "流星雨",
                            Earthquake = "地震",
                            ["Thunder Storm"] = "暴风雨",
                        }
                        local DisasterChineseName = map[DisasterEnglishName] or "未知灾难"
                        if DisasterEnglishName ~= LastChatDisaster then
                            SendChatMessage("当前灾难: " .. DisasterChineseName)
                            LastChatDisaster = DisasterEnglishName
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    end
})

local NoClipConnection = nil

MainLeft:AddToggle("NoClip", {
    Text = "防穿飞",
    Default = false,
    Callback = function(Value)
        if Value then
            NoClipConnection = RunService.Stepped:Connect(function()
                pcall(function()
                    for _, v in pairs(player.Character:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                end)
            end)
        else
            if NoClipConnection then
                NoClipConnection:Disconnect()
                NoClipConnection = nil
            end
            pcall(function()
                for _, v in pairs(player.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = true
                    end
                end
            end)
        end
    end
})

local FallDamageConnection = nil
local CharacterAddedConnection = nil

local function SetupFallDamageProtection(Character)
    pcall(function()
        local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        if FallDamageConnection then
            FallDamageConnection:Disconnect()
        end
        FallDamageConnection = RunService.Heartbeat:Connect(function()
            pcall(function()
                if HumanoidRootPart.Parent then
                    local CurrentVelocity = HumanoidRootPart.AssemblyLinearVelocity
                    HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                    RunService.RenderStepped:Wait()
                    HumanoidRootPart.AssemblyLinearVelocity = CurrentVelocity
                else
                    FallDamageConnection:Disconnect()
                    FallDamageConnection = nil
                end
            end)
        end)
    end)
end

MainLeft:AddToggle("FallDamage", {
    Text = "刹除跌落伤害",
    Default = false,
    Callback = function(Value)
        if Value then
            pcall(function()
                SetupFallDamageProtection(player.Character)
            end)
            if not CharacterAddedConnection then
                CharacterAddedConnection = player.CharacterAdded:Connect(SetupFallDamageProtection)
            end
            Library:Notify({
                Title = "自然灾害",
                Description = "刹除跌落伤害 已开启",
                Time = 3,
            })
        else
            if FallDamageConnection then
                FallDamageConnection:Disconnect()
                FallDamageConnection = nil
            end
            if CharacterAddedConnection then
                CharacterAddedConnection:Disconnect()
                CharacterAddedConnection = nil
            end
            Library:Notify({
                Title = "自然灾害",
                Description = "刹除跌落伤害 已关闭",
                Time = 3,
            })
        end
    end
})

local WeatherEffectConnection = nil

MainLeft:AddToggle("RemoveWeather", {
    Text = "刹除暴风雪和沙尘暴",
    Default = false,
    Callback = function(Value)
        if Value then
            pcall(function()
                if player.PlayerGui:FindFirstChild("BlizzardGui") then
                    player.PlayerGui.BlizzardGui:Destroy()
                end
                if player.PlayerGui:FindFirstChild("SandStormGui") then
                    player.PlayerGui.SandStormGui:Destroy()
                end
            end)
            WeatherEffectConnection = RunService.Heartbeat:Connect(function()
                pcall(function()
                    if player.PlayerGui:FindFirstChild("BlizzardGui") then
                        player.PlayerGui.BlizzardGui:Destroy()
                    end
                    if player.PlayerGui:FindFirstChild("SandStormGui") then
                        player.PlayerGui.SandStormGui:Destroy()
                    end
                end)
            end)
        else
            if WeatherEffectConnection then
                WeatherEffectConnection:Disconnect()
                WeatherEffectConnection = nil
            end
        end
    end
})

MainRight:AddToggle("WalkOnWater", {
    Text = "在水上行趋",
    Default = false,
    Callback = function(Value)
        pcall(function()
            if Value then
                Workspace.WaterLevel.CanCollide = true
                Workspace.WaterLevel.Size = Vector3.new(5000, 1, 5000)
            else
                Workspace.WaterLevel.CanCollide = false
                Workspace.WaterLevel.Size = Vector3.new(10, 1, 10)
            end
        end)
    end
})

MainRight:AddToggle("LowerRocks", {
    Text = "开启游戏岛悬崖碰撞体积",
    Default = false,
    Callback = function(Value)
        pcall(function()
            for _, v in pairs(Workspace:GetDescendants()) do
                if v.Name == "LowerRocks" then
                    v.CanCollide = Value
                end
            end
        end)
    end
})

MainRight:AddToggle("MapVoteUI", {
    Text = "地图投票用户界面",
    Default = false,
    Callback = function(Value)
        pcall(function()
            local MapVotePage = player.PlayerGui.MainGui.MapVotePage
            MapVotePage.Visible = Value
        end)
    end
})

MainRight:AddToggle("GodMode", {
    Text = "无敌",
    Default = false,
    Callback = function(Value)
        if Value then
            pcall(function()
                local lp = Players.LocalPlayer
                local char = lp.Character or lp.CharacterAdded:Wait()
                local hum = char:FindFirstChildOfClass("Humanoid")
                local rootpart = hum and hum.RootPart
                if not rootpart then return end
                local oldpos = rootpart.CFrame
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                rootpart.AssemblyLinearVelocity = Vector3.new(9e9, 9e9, 9e9)
                task.wait(.5)
                rootpart.AssemblyLinearVelocity = Vector3.zero
                rootpart.AssemblyAngularVelocity = Vector3.zero
                rootpart.CFrame = oldpos
            end)
            Library:Notify({
                Title = "通知",
                Description = "无敌已开启",
                Time = 1,
            })
        else
            Library:Notify({
                Title = "通知",
                Description = "无敌已关闭",
                Time = 1,
            })
        end
    end
})

MainRight:AddButton({
    Text = "指南针",
    Func = function()
        pcall(function()
            local r = ReplicatedStorage.Remotes.Compass
            local c = player.Backpack:WaitForChild("Compass")
            local h = player.Character:WaitForChild("Humanoid")
            h:EquipTool(c)
            task.wait()
            r:FireServer("Vote Map", 3)
            r:FireServer("Vote Map", 4)
            task.wait()
            h:UnequipTools()
        end)
        Library:Notify({
            Title = "通知",
            Description = "加载成功",
            Time = 1,
        })
    end
})

MainRight:AddButton({
    Text = "汉化祖国人",
    Func = function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/kongbaNB/-/refs/heads/main/祖国人汉化"))()
        end)
        Library:Notify({
            Title = "通知",
            Description = "加载成功",
            Time = 1,
        })
    end
})

local BlackHoleLeft = Tabs.BlackHole:AddLeftGroupbox("黑洞脚本")

BlackHoleLeft:AddButton({
    Text = "皮-黑洞脚本",
    Func = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaopi77/xiaopi77/refs/heads/main/%F0%9F%98%A1%F0%9F%98%A1%F0%9F%98%A1blackhole.lua"))()
    end
})

BlackHoleLeft:AddButton({
    Text = "辅助脚本1(可以让黑洞吸力更强)",
    Func = function()
        local _ = task.wait
        local GameRef = game
        loadstring(GameRef:HttpGet("https://glot.io/snippets/gzrux646yj/raw/main.ts"))()
    end
})

BlackHoleLeft:AddButton({
    Text = "辅助脚本2(可以切换黑洞模式)",
    Func = function()
        loadstring(game:HttpGet("https://gist.githubusercontent.com/AxolotlBmgo/8888080921c2b426a32dd9ff587baff1/raw/d45e03afed3c1716f36523bbf6dd741d3d2aad00/gistfile1.txt"))()
    end
})

BlackHoleLeft:AddButton({
    Text = "黑洞之祸(别人应该看不见)",
    Func = function()
        loadstring(game:HttpGet("https://pastefy.app/WkuiK8ul/raw"))()
    end
})

BlackHoleLeft:AddButton({
    Text = "最垃圾黑洞脚本(配合指令tpua使用)",
    Func = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/SAZXHUB/Control-update/main/README.md", true))()
    end
})

BlackHoleLeft:AddButton({
    Text = "黑洞脚本(E键控制)",
    Func = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/Sx6PY4gV"))()
    end
})

BlackHoleLeft:AddButton({
    Text = "点击即跟随型黑洞脚本",
    Func = function()
        loadstring(game:HttpGet("https://pastefy.app/BbXuvVkK/raw", true))()
    end
})

BlackHoleLeft:AddButton({
    Text = "吸力超强黑洞脚本(E键控制)",
    Func = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaopi77/xiaopi77/refs/heads/main/blackhole.lua"))()
    end
})

BlackHoleLeft:AddButton({
    Text = "黑洞",
    Func = function()
        pcall(function()
            loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Super-ring-Parts-V6-28581"))()
        end)
        Library:Notify({
            Title = "通知",
            Description = "加载成功",
            Time = 3,
        })
    end
})

BlackHoleLeft:AddButton({
    Text = "传送型黑洞脚本(别人看不见)",
    Func = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/U29jR1Cf"))()
    end
})

BlackHoleLeft:AddButton({
    Text = "黑洞环绕V2脚本",
    Func = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/BOOSBS/666/refs/heads/main/656"))()
    end
})

BlackHoleLeft:AddButton({
    Text = "黑洞环绕V3脚本",
    Func = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/BOOSBS/199/refs/heads/main/V3"))()
    end
})

local BlackHoleRight = Tabs.BlackHole:AddRightGroupbox("黑洞脚本(带数字)")

BlackHoleRight:AddButton({
    Text = "黑洞脚本1",
    Func = function()
        loadstring(game:HttpGet("https://pastefy.app/J21lpKbj/raw"))()
    end
})

BlackHoleRight:AddButton({
    Text = "黑洞脚本3",
    Func = function()
        loadstring(game:HttpGet("https://pastefy.app/EwpVHMPg/raw"))()
    end
})

BlackHoleRight:AddButton({
    Text = "黑洞脚本4",
    Func = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/BingusWR/BLACKHOLDSCRIPT/refs/heads/main/BLACK%20HOLD%20SCRIPT"))()
    end
})

BlackHoleRight:AddButton({
    Text = "黑洞脚本5",
    Func = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaopi77/xiaopi77/refs/heads/main/Blackholescript.lua"))()
    end
})

local CommandGroup = Tabs.Command:AddLeftGroupbox("指令")

CommandGroup:AddButton({
    Text = "指令脚本",
    Func = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", true))()
    end
})

CommandGroup:AddLabel("bang能够掐人")
CommandGroup:AddLabel("noface没有脸")
CommandGroup:AddLabel("headsit坐在玩家头上加玩家名字")
CommandGroup:AddLabel("float悬浮")
CommandGroup:AddLabel("re重置人物但位置不变")
CommandGroup:AddLabel("dance跳舞")
CommandGroup:AddLabel("nolegs没有腿")
CommandGroup:AddLabel("walltp碰到墙壁传送到墙壁顶部")
CommandGroup:AddLabel("bring+玩家名字可以让玩家吸到你手上但是只能用于一些服务器")
CommandGroup:AddLabel("carpet趴着走")
CommandGroup:AddLabel("infjump无限跳跃")
CommandGroup:AddLabel("xray透视地图所有物体变透明")
CommandGroup:AddLabel("bang玩家开头两个英文吸在玩家身后")
CommandGroup:AddLabel("noanim没有动作")
CommandGroup:AddLabel("spin人物旋转")
CommandGroup:AddLabel("sitwalk坐着走")
CommandGroup:AddLabel("trip让你的人物摔倒")
CommandGroup:AddLabel("antikick防踢")
CommandGroup:AddLabel("lay躺下")
CommandGroup:AddLabel("sit坐")
CommandGroup:AddLabel("god加衣")
CommandGroup:AddLabel("invisfling配合加衣可以旋转")
CommandGroup:AddLabel("goto+玩家名字传送")
CommandGroup:AddLabel("unxray关闭透视")
CommandGroup:AddLabel("noclip穿墙")
CommandGroup:AddLabel("有的可能不能用")

local MindPowerGroup = Tabs.MindPower:AddLeftGroupbox("念力")

MindPowerGroup:AddButton({
    Text = "获取念力工具",
    Func = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaopi77/xiaopi77/refs/heads/main/Mindpower.lua"))()
    end
})

MindPowerGroup:AddLabel("Q - 靠近")
MindPowerGroup:AddLabel("E - 禁远")
MindPowerGroup:AddLabel("Y - 投掷")
MindPowerGroup:AddLabel("J - 超级投掷")
MindPowerGroup:AddLabel("U - 使物体自转")
MindPowerGroup:AddLabel("P - 使物体悬浮在空中")
MindPowerGroup:AddLabel("X - 走得更远一点")
MindPowerGroup:AddLabel("L - 使方块变直并锁定在前部")

MindPowerGroup:AddButton({
    Text = "让手上的道具飞起来",
    Func = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/WmD8MuSx"))()
    end
})

MindPowerGroup:AddLabel("J - 飞起来")
MindPowerGroup:AddLabel("K - 回到手中")

local TeleportGroup = Tabs.Teleport:AddLeftGroupbox("传送功能")

TeleportGroup:AddButton({
    Text = "传送到灾害岛",
    Func = function()
        pcall(function()
            player.Character.HumanoidRootPart.CFrame = CFrame.new(-115.828506, 65.4863434, 18.8461514, 0.00697017973, 0.0789371505, -0.996855199, -3.13589936e-7, 0.996879458, 0.0789390653, 0.999975681, -0.000549906865, 0.00694845384)
        end)
    end
})

TeleportGroup:AddButton({
    Text = "传送到出生塔",
    Func = function()
        pcall(function()
            player.Character.HumanoidRootPart.CFrame = CFrame.new(-279.6720275878906, 180.40802001953125, 340.8188171386719)
        end)
    end
})

local UnloadGroup = Tabs.Settings:AddLeftGroupbox("脚本管理")
UnloadGroup:AddButton({
    Text = "卸载脚本",
    Func = function()
        if NoClipConnection then
            NoClipConnection:Disconnect()
            NoClipConnection = nil
        end
        if FallDamageConnection then
            FallDamageConnection:Disconnect()
            FallDamageConnection = nil
        end
        if CharacterAddedConnection then
            CharacterAddedConnection:Disconnect()
            CharacterAddedConnection = nil
        end
        if WeatherEffectConnection then
            WeatherEffectConnection:Disconnect()
            WeatherEffectConnection = nil
        end
        _G.autowinfarm = false
        DisasterDetectionEnabled = false
        NotificationDisasterEnabled = false
        ChatDisasterEnabled = false
        Library:Unload()
    end
})

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
