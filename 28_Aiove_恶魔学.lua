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
local LocalPlayer = Players.LocalPlayer

local Window = Library:CreateWindow({
    Title = "恶魔学",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify({
    Title = "恶魔学",
    Description = "创作者：Aiove\nQQ：3999698324\n脚本已加载成功",
    Time = 5,
})

local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Ghost = Window:AddTab("鬼魂功能", "info"),
    Player = Window:AddTab("玩家功能", "info"),
    Item = Window:AddTab("物品功能", "info"),
    Room = Window:AddTab("房间功能", "info"),
    Visual = Window:AddTab("视觉功能", "info"),
    Troll = Window:AddTab("恶搞功能", "info"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel("Aiove将持续更新此脚本")
NoticeGroup:AddLabel("创作者：Aiove")

local stuff = {
    SeeGhost = false,
    prints = nil,
    ghostSeePlayerDistance = 15,
    ghostSeePlayerEnabled = false,
    sayInchat = false,
    sayInchat2 = false,
    playerChatted = {},
    warningHunt = nil
}

local GhostGroup = Tabs.Ghost:AddLeftGroupbox("鬼魂功能")

GhostGroup:AddToggle("SeeGhost", {
    Text = "显示鬼魂",
    Default = false,
    Callback = function(Value)
        stuff.SeeGhost = Value
        task.spawn(function()
            while stuff.SeeGhost do
                task.wait()
                if workspace:WaitForChild("Ghost"):GetAttribute("VisualModel") == "Biter" and LocalPlayer:GetAttribute("TrypophobiaSafe") == true then
                    workspace:WaitForChild("Ghost"):WaitForChild("HumanoidRootPart"):WaitForChild("Cat"):WaitForChild("ImageLabel").ImageTransparency = 0.25
                else
                    local transparency = workspace:WaitForChild("Ghost"):GetAttribute("Transparency") or 0.25
                    transparency = transparency <= 0.25 and transparency or 0.25

                    for _, d in pairs(workspace:WaitForChild("Ghost").VisibleParts:GetDescendants()) do
                        if d:IsA("BasePart") then
                            d.Transparency = transparency
                        elseif d:IsA("ParticleEmitter") or d:IsA("Light") then
                            d.Enabled = true
                        end
                    end
                end
            end

            for _, d in pairs(workspace:WaitForChild("Ghost").VisibleParts:GetDescendants()) do
                if d:IsA("BasePart") then
                    d.Transparency = 1
                elseif d:IsA("ParticleEmitter") or d:IsA("Light") then
                    d.Enabled = false
                end
            end
        end)
    end,
})

GhostGroup:AddToggle("GhostPrints", {
    Text = "显示鬼魂手印",
    Default = false,
    Callback = function(Value)
        if stuff.prints then
            stuff.prints:Disconnect()
            stuff.prints = nil
        end

        if Value then
            for _, d in pairs(workspace.Handprints:GetChildren()) do
                d:FindFirstChildOfClass("Decal").Transparency = 0
            end

            stuff.prints = workspace.Handprints.ChildAdded:Connect(function(handprint)
                handprint:FindFirstChildOfClass("Decal").Transparency = 0
            end)
        else
            for _, d in pairs(workspace.Handprints:GetChildren()) do
                d:FindFirstChildOfClass("Decal").Transparency = 1
            end
        end
    end,
})

GhostGroup:AddButton("获取鬼魂信息", function()
    local Ghost = workspace:WaitForChild("Ghost")
    local info = {
        age = tostring(Ghost:GetAttribute("Age")),
        favroom = Ghost:GetAttribute("FavoriteRoom"),
        crntroom = Ghost:GetAttribute("CurrentRoom"),
        gender = Ghost:GetAttribute("Gender"),
        mdlName = Ghost:GetAttribute("VisualModel")
    }

    if stuff.sayInchat then
        ReplicatedStorage:WaitForChild("Events"):WaitForChild("AskSpiritBoxFromUI"):FireServer(
            "鬼魂是一个"..string.lower(info.gender)..", 年龄 "..info.age.." 它最喜欢的房间是 "..string.lower(info.favroom)
        )
    else
        Library:Notify({
            Title = "鬼魂信息",
            Description = info.gender.." | 年龄 "..info.age.."\n鬼魂房间 | "..info.favroom,
            Time = 5
        })
    end
end)

GhostGroup:AddButton("获取鬼魂当前房间", function()
    local crntroom = workspace:WaitForChild("Ghost"):GetAttribute("CurrentRoom")

    if stuff.sayInchat then
        ReplicatedStorage:WaitForChild("Events"):WaitForChild("AskSpiritBoxFromUI"):FireServer(
            "鬼魂在"..string.lower(crntroom)
        )
    else
        Library:Notify({
            Title = "鬼魂信息",
            Description = crntroom,
            Time = 5
        })
    end
end)

GhostGroup:AddToggle("SayInChat", {
    Text = "在聊天中显示鬼魂信息",
    Default = false,
    Callback = function(Value)
        stuff.sayInchat = Value
    end,
})

GhostGroup:AddToggle("GhostApproach", {
    Text = "鬼魂接近通知(仅在狩猎时有效)",
    Default = false,
    Callback = function(Value)
        stuff.ghostSeePlayerEnabled = Value

        task.spawn(function()
            while stuff.ghostSeePlayerEnabled do
                task.wait(1)
                local distanceGhost = (workspace:WaitForChild("Ghost"):WaitForChild("HumanoidRootPart").Position -
                    LocalPlayer.Character.HumanoidRootPart.Position).Magnitude

                if distanceGhost <= stuff.ghostSeePlayerDistance and distanceGhost >= 5 and
                    workspace:WaitForChild("Ghost"):GetAttribute("Hunting") then

                    Library:Notify({
                        Title = "鬼魂警告",
                        Description = "鬼魂距离你"..tostring(math.floor(distanceGhost)).."单位",
                        Time = 3.5
                    })
                end
            end
        end)
    end,
})

GhostGroup:AddToggle("HuntWarning", {
    Text = "鬼魂狩猎事件通知",
    Default = false,
    Callback = function(Value)
        if Value then
            stuff.warningHunt = workspace:WaitForChild("Ghost"):GetAttributeChangedSignal("Hunting"):Connect(function()
                if workspace:WaitForChild("Ghost"):GetAttribute("Hunting") == true then
                    Library:Notify({
                        Title = "狩猎警告",
                        Description = "鬼魂开始狩猎!",
                        Time = 5
                    })
                else
                    Library:Notify({
                        Title = "狩猎警告",
                        Description = "鬼魂结束狩猎!",
                        Time = 5
                    })
                end
            end)
        elseif stuff.warningHunt then
            stuff.warningHunt:Disconnect()
            stuff.warningHunt = nil
        end
    end,
})

GhostGroup:AddButton("触发所有盐堆", function()
    local SaltPiles = workspace.SaltPiles:GetChildren()
    local NormalPiles = {}

    for _, d in pairs(SaltPiles) do
        if d.Name == "SaltLine" then
            table.insert(NormalPiles, d)
        end
    end

    if #NormalPiles > 0 then
        for _, d in pairs(NormalPiles) do
            task.spawn(function()
                firetouchinterest(workspace.Ghost.Torso, d:WaitForChild("GhostTracker"), 0)
                firetouchinterest(workspace.Ghost.Torso, d:WaitForChild("GhostTracker"), 1)
            end)
        end
    else
        Library:Notify({
            Title = "盐堆触发",
            Description = "没有盐堆!",
            Time = 3.5
        })
    end
end)

GhostGroup:AddButton("检查是否为无头骑士", function()
    local isHeadless = workspace:WaitForChild("Ghost"):GetAttribute("Headless")

    Library:Notify({
        Title = "无头骑士检查",
        Description = isHeadless and "鬼魂是无头骑士!" or "鬼魂不是无头骑士",
        Time = 3.5
    })
end)

GhostGroup:AddButton("检查鬼魂球体", function()
    Library:Notify({
        Title = "鬼魂球体检查",
        Description = workspace:FindFirstChild("GhostOrb") and "有鬼魂球体" or "没有鬼魂球体",
        Time = 3.5
    })
end)

GhostGroup:AddButton("检查手印", function()
    Library:Notify({
        Title = "手印检查",
        Description = #workspace.Handprints:GetChildren() > 0 and "有手印" or "没有手印",
        Time = 3.5
    })
end)

GhostGroup:AddButton("检查激光可见性", function()
    local ghostLaserVisible = workspace:WaitForChild("Ghost"):GetAttribute("LaserVisible") and
        workspace:WaitForChild("Ghost"):GetAttribute("Transparency") < 1

    Library:Notify({
        Title = "激光可见性检查",
        Description = ghostLaserVisible and "鬼魂对激光可见!" or
            "鬼魂对激光不可见\n这可能是错误，请确保将激光投影仪放在鬼魂喜欢的房间",
        Time = ghostLaserVisible and 3.5 or 7.5
    })
end)

local PlayerGroup = Tabs.Player:AddLeftGroupbox("玩家功能")

PlayerGroup:AddToggle("ChatNotify", {
    Text = "通知聊天消息",
    Default = false,
    Callback = function(Value)
        if Value then
            for _, d in pairs(Players:GetChildren()) do
                if d ~= LocalPlayer then
                    stuff.playerChatted[d.Name] = d.Chatted:Connect(function(msg)
                        local topName = d.Name

                        if workspace:WaitForChild("Ragdolls"):FindFirstChild(d.Name) then
                            topName = topName.. " (死亡)"
                        end

                        Library:Notify({
                            Title = topName.." 说:",
                            Description = msg,
                            Time = 10
                        })

                        if stuff.sayInchat2 then
                            ReplicatedStorage:WaitForChild("Events"):WaitForChild("AskSpiritBoxFromUI"):FireServer(
                                topName.." 说: ".. msg
                            )
                        end
                    end)
                end
            end
        else
            for _, d in pairs(stuff.playerChatted) do
                d:Disconnect()
            end
            stuff.playerChatted = {}
        end
    end,
})

PlayerGroup:AddToggle("SayInChat2", {
    Text = "在聊天中通知消息",
    Default = false,
    Callback = function(Value)
        stuff.sayInchat2 = Value
    end,
})

local ItemGroup = Tabs.Item:AddLeftGroupbox("物品功能")

ItemGroup:AddButton("使用激光扫描仪", function()
    local function ridarScan()
        local v1 = game:GetService("ReplicatedStorage")
        local v2 = game:GetService("UserInputService")
        local u3 = game:GetService("RunService")
        local u4 = Players.LocalPlayer
        local v5 = u4:WaitForChild("PlayerScripts")
        local u8 = v5:WaitForChild("Events")
        local u9 = workspace:FindFirstChild("LIDAR_V2") or Instance.new("Folder")
        local u10 = workspace.CurrentCamera
        local u11 = nil
        local u12 = false

        u9.Name = "LIDAR_V2"
        u9.Parent = workspace

        local function GenerateScreenPoints(p13, p14, p15)
            local v16 = p14 * p15
            local v17 = v16 * p13
            local v18 = math.ceil(v17)
            local v19 = v16 / v18
            local v20 = math.sqrt(v19)
            local v21 = p15 / v20
            local v22 = math.floor(v21)
            local v23 = p14 / v20
            local v24 = math.floor(v23)
            local v25 = {}
            for v26 = 0, v22 - 1 do
                for v27 = 0, v24 - 1 do
                    if v18 <= #v25 then
                        break
                    end
                    local v28 = math.random
                    local v29 = v27 * v20
                    local v30 = (v27 + 1) * v20 - 1
                    local v31 = v28(v29, (math.min(v30, p14)))
                    local v32 = math.random
                    local v33 = v26 * v20
                    local v34 = (v26 + 1) * v20 - 1
                    local v35 = v32(v33, (math.min(v34, p15)))
                    local v36 = Vector2.new
                    table.insert(v25, v36(v31, v35))
                end
            end
            return v25
        end

        local function GetColorFromScreenPosition(p37)
            local v38 = Vector2.new(u10.ViewportSize.X / 2, u10.ViewportSize.Y / 2)
            local v39 = (p37 - v38).Magnitude / (v38.Magnitude * 0.7)
            local v40 = math.clamp(v39, 0, 1)
            local v41
            if v40 < 0.5 then
                local v42 = v40 * 2
                v41 = Color3.new(1 - v42, v42, 0)
            else
                local v43 = (v40 - 0.5) * 2
                v41 = Color3.new(v43, 1, v43)
            end
            local v44, v45, v46 = v41:ToHSV()
            return Color3.fromHSV(v44, v45, v46 * 0.7)
        end

        local function CreateLidarSpheres(p47, p48)
            local v49 = p48:ViewportPointToRay(p47.X, p47.Y)
            local v50 = RaycastParams.new()
            v50.FilterDescendantsInstances = { u4.Character }
            v50.FilterType = Enum.RaycastFilterType.Exclude
            local v51 = workspace:Raycast(v49.Origin, v49.Direction * 1000, v50)
            if v51 then
                local v52 = v5.ItemControllers:WaitForChild("LIDAR Scanner").Part:Clone()
                v52.Position = v51.Position
                v52.Color = GetColorFromScreenPosition(p47)
                v52.Parent = u9
            end
        end

        local function RenderLidarOutput()
            local v53 = u10.ViewportSize.X
            local v54 = u10.ViewportSize.Y
            local v55 = GenerateScreenPoints(0.001, v53, v54)
            workspace.LIDAR:ClearAllChildren()
            local v56 = workspace:FindFirstChild("Ghost"):Clone()
            for _, v57 in v56:GetDescendants() do
                if v57:IsA("BasePart") then
                    v57.CanCollide = false
                    v57.CanQuery = true
                    v57.Anchored = true
                    v57.CollisionGroup = "Default"
                    v57.Transparency = 1
                end
            end
            v56.Parent = workspace
            for v58, v59 in ipairs(v55) do
                if v58 % 100 == 0 then
                    u3.Heartbeat:Wait()
                end
                CreateLidarSpheres(v59, u10)
            end
            v56:Destroy()
        end

        RenderLidarOutput()
    end

    ridarScan()
end)

ItemGroup:AddButton("通知所有稀有物品", function()
    local found = false

    for _, d in pairs(workspace:WaitForChild("Items"):GetChildren()) do
        if d:GetAttribute("ItemName") then
            local NameItem = d:GetAttribute("ItemName")
            local er = true

            if d:GetAttribute("Uninteractable") == true or d:GetAttribute("Broken") == true then
                er = false
            end

            if er and (NameItem == "Energy Drink" or NameItem == "Music Box" or
                NameItem == "Umbra Board" or NameItem == "Energy Watch" or tonumber(d.Name) >= 100) then

                found = true
                Library:Notify({
                    Title = "稀有物品警告",
                    Description = "发现稀有物品 "..NameItem,
                    Time = 3.5
                })

                local hightlight = Instance.new("Highlight")
                hightlight.Parent = d
                hightlight.FillColor = Color3.fromRGB(37, 161, 255)
                game:GetService("Debris"):AddItem(hightlight,5)
            end
        end
    end

    if not found then
        Library:Notify({
            Title = "稀有物品警告",
            Description = "未找到稀有物品",
            Time = 3.5
        })
    end
end)

ItemGroup:AddButton("切换保险丝盒", function()
    ReplicatedStorage:WaitForChild("Events"):WaitForChild("ToggleFuseBox"):FireServer()
end)

local RoomGroup = Tabs.Room:AddLeftGroupbox("房间功能")

RoomGroup:AddButton("获取当前房间温度", function()
    local room = LocalPlayer:GetAttribute("CurrentRoom")

    if workspace:WaitForChild("Map"):WaitForChild("Rooms"):FindFirstChild(room) and
        workspace:WaitForChild("Map"):WaitForChild("Rooms"):WaitForChild(room):GetAttribute("Temperature") then

        Library:Notify({
            Title = "房间温度检查",
            Description = room.."的温度是 "..tostring(workspace:WaitForChild("Map"):WaitForChild("Rooms"):WaitForChild(room):GetAttribute("Temperature")),
            Time = 3.5
        })
    end
end)

RoomGroup:AddToggle("GhostRoomTemp", {
    Text = "通知鬼魂房间温度低于0°C",
    Default = false,
    Callback = function(Value)
        if Value then
            local room = workspace:WaitForChild("Ghost"):GetAttribute("FavoriteRoom")

            if workspace:WaitForChild("Map"):WaitForChild("Rooms"):WaitForChild(room):GetAttribute("Temperature") <= 0 then
                Library:Notify({
                    Title = "房间温度检查(鬼魂)",
                    Description = room.."的温度低于0°C!",
                    Time = 3.5
                })
            end

            workspace:WaitForChild("Map"):WaitForChild("Rooms"):WaitForChild(room):GetAttributeChangedSignal("Temperature"):Connect(function()
                if workspace:WaitForChild("Map"):WaitForChild("Rooms"):WaitForChild(room):GetAttribute("Temperature") <= 0 then
                    Library:Notify({
                        Title = "房间温度检查(鬼魂)",
                        Description = room.."的温度低于0°C!",
                        Time = 3.5
                    })
                end
            end)
        end
    end,
})

RoomGroup:AddToggle("DoorNoclip", {
    Text = "穿门无碰撞",
    Default = false,
    Callback = function(Value)
        for _, d in pairs(workspace.Doors:GetChildren()) do
            task.spawn(function()
                for _, d22 in pairs(d:WaitForChild("Door"):GetChildren()) do
                    if d22:IsA("BasePart") and d22.Name ~= "GhostTracker" then
                        d22.CanCollide = not Value
                    end
                end
            end)
        end
    end,
})

local VisualGroup = Tabs.Visual:AddLeftGroupbox("视觉功能")

VisualGroup:AddToggle("MaxBrightness", {
    Text = "最大亮度",
    Default = false,
    Callback = function(Value)
        if Value then
            game.Lighting.Brightness = 2
            game.Lighting.ClockTime = 14
            game.Lighting.GlobalShadows = false
            game.Lighting.OutdoorAmbient = Color3.fromRGB(209, 209, 209)
        else
            game.Lighting.Brightness = 0
            game.Lighting.ClockTime = 0
            game.Lighting.GlobalShadows = true
            game.Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
        end
    end,
})

local TrollGroup = Tabs.Troll:AddLeftGroupbox("恶搞功能")

TrollGroup:AddToggle("SpamDoors", {
    Text = "刷门(卡顿)",
    Default = false,
    Callback = function(Value)
        task.spawn(function()
            while Value do
                task.wait()
                for _, d in pairs(workspace.Doors:GetChildren()) do
                    if d:GetAttribute("Locked") ~= true then
                        ReplicatedStorage:WaitForChild("Events"):WaitForChild("ClientChangeDoorState"):FireServer(d:WaitForChild("Door"))
                    end
                end
            end
        end)
    end,
})

TrollGroup:AddToggle("SpamLights", {
    Text = "刷灯(卡顿)",
    Default = false,
    Callback = function(Value)
        task.spawn(function()
            while Value do
                task.wait()
                for _, d in pairs(workspace.Map.Rooms:GetChildren()) do
                    if d:FindFirstChild("LightSwitch") then
                        ReplicatedStorage:WaitForChild("Events"):WaitForChild("UseLightSwitch"):FireServer(d)
                    end
                end
            end
        end)
    end,
})

TrollGroup:AddButton("让所有物品消失", function()
    task.spawn(function()
        while task.wait() do
            for _, d in pairs(workspace.Items:GetChildren()) do
                if d.PrimaryPart then
                    local newForce = Instance.new("BodyPosition",d.PrimaryPart)
                    newForce.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
                    newForce.Position = Vector3.new(1000000,1000000,1000000)
                end
            end

            for _, d in pairs(Players:GetChildren()) do
                local Tools = d:WaitForChild("ToolsHolder")

                for _, d in pairs(Tools:GetChildren()) do
                    if d.PrimaryPart then
                        local newForce = Instance.new("BodyPosition",d.PrimaryPart)
                        newForce.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
                        newForce.Position = Vector3.new(1000000,1000000,1000000)
                    end
                end
            end
        end
    end)
end)

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
