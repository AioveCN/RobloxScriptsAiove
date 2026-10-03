-- This file has been deobfuscated Luraph using Hurricane https://discord.com/invite/AbeurBzKXe
local function safeLoad(url)
    local success, result = pcall(function() return loadstring(game:HttpGet(url))() end)
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
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local function AddToArrayList(name, value) end
local function RemoveFromArrayList(name) end
local function UpdateModuleDisplay(name, value) end

local Window = Library:CreateWindow({
    Title = "最终战场",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify({
    Title = "最终战场",
    Description = "创作者：Aiove\nQQ：3999698324\n脚本已加载成功",
    Time = 5,
})

local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Main = Window:AddTab("主要", "info"),
    Violent = Window:AddTab("暴力功能", "info"),
    Hitbox = Window:AddTab("碰撞箱扩大", "info"),
    Lock = Window:AddTab("锁人", "info"),
    Emote = Window:AddTab("击杀表情", "info"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel('Aiove将持续更新此脚本')
NoticeGroup:AddLabel('创作者：Aiove')

local MainLeft1 = Tabs.Main:AddLeftGroupbox("基础功能")
local MainLeft2 = Tabs.Main:AddLeftGroupbox("战斗增强")
local MainLeft3 = Tabs.Main:AddLeftGroupbox("移动与属性")
local MainRight1 = Tabs.Main:AddRightGroupbox("视觉与特效")

local ViolentLeft1 = Tabs.Violent:AddLeftGroupbox("秒杀类")
local ViolentLeft2 = Tabs.Violent:AddLeftGroupbox("杀戮光环")
local ViolentRight1 = Tabs.Violent:AddRightGroupbox("墙打秒杀")

local HitboxLeft = Tabs.Hitbox:AddLeftGroupbox("碰撞箱设置")

local LockLeft = Tabs.Lock:AddLeftGroupbox("锁人设置")
local LockRight = Tabs.Lock:AddRightGroupbox("目标选择")

local EmoteLeft = Tabs.Emote:AddLeftGroupbox("表情选择")
local EmoteRight = Tabs.Emote:AddRightGroupbox("光环与快捷键")

local UnloadGroup = Tabs.Settings:AddLeftGroupbox("脚本管理")
UnloadGroup:AddButton("卸载脚本", function()
    Library:Unload()
end)

MainLeft1:AddButton("篡改", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/dream77239/ubg-script/refs/heads/main/%E6%8B%A6%E6%88%AA.txt"))()
end)

local fakeBlockEnabled = false
local loopRunning = false
MainLeft1:AddToggle("FakeBlock", {Text = "假防(关闭功能后按一次防御即可取消假防)", Default = false}):OnChanged(function(state)
    if state then AddToArrayList("假防") else RemoveFromArrayList("假防") end
    fakeBlockEnabled = state
    local BlockRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Combat"):WaitForChild("Block")
    local character = player.Character or player.CharacterAdded:Wait()
    local function enableBlock()
        pcall(function()
            BlockRemote:FireServer(true)
        end)
    end
    if fakeBlockEnabled then
        enableBlock()
    end
    if not loopRunning then
        loopRunning = true
        task.spawn(function()
            while true do
                task.wait(0.01)
                if fakeBlockEnabled then
                    local success, isBlocking = pcall(function()
                        return character:GetAttribute("IsBlocking")
                    end)
                    if success and not isBlocking then
                        enableBlock()
                    end
                end
            end
        end)
    end
end)

local defaultCooldown = ReplicatedStorage.Settings.Cooldowns.Dash.Value
MainLeft1:AddToggle("DashCooldown", {Text = "侧闪无冷却", Default = false}):OnChanged(function(state)
    if state then AddToArrayList("侧闪无冷却") else RemoveFromArrayList("侧闪无冷却") end
    local dashCooldown = ReplicatedStorage.Settings.Cooldowns.Dash
    if state then
        dashCooldown.Value = 1
    else
        dashCooldown.Value = defaultCooldown
    end
end)

local defaultMeleeCooldown = ReplicatedStorage.Settings.Cooldowns.Melee.Value
MainLeft1:AddToggle("MeleeCooldown", {Text = "近战无冷却", Default = false}):OnChanged(function(state)
    if state then AddToArrayList("近战无冷却") else RemoveFromArrayList("近战无冷却") end
    local meleeCooldown = ReplicatedStorage.Settings.Cooldowns.Melee
    if state then
        meleeCooldown.Value = 1
    else
        meleeCooldown.Value = defaultMeleeCooldown
    end
end)

local defaultAbility = ReplicatedStorage.Settings.Cooldowns.Ability.Value
MainLeft1:AddToggle("AbilityCooldown", {Text = "技能无冷却(仅宿傩角色)", Default = false}):OnChanged(function(state)
    if state then AddToArrayList("技能无冷却") else RemoveFromArrayList("技能无冷却") end
    ReplicatedStorage.Settings.Cooldowns.Ability.Value = state and 1 or defaultAbility
end)

local EmoteClaim = ReplicatedStorage.Remotes.Combat.EmoteClaim
local emoteClaimActive = false
local emoteClaimConnection = nil
local function startEmoteClaim()
    emoteClaimConnection = RunService.Heartbeat:Connect(function()
        if emoteClaimActive then
            EmoteClaim:FireServer()
        end
    end)
end
local function stopEmoteClaim()
    if emoteClaimConnection then
        emoteClaimConnection:Disconnect()
        emoteClaimConnection = nil
    end
end
MainLeft1:AddToggle("AutoEmote", {Text = "自动签到表情", Default = false}):OnChanged(function(state)
    if state then AddToArrayList("自动签到表情") else RemoveFromArrayList("自动签到表情") end
    emoteClaimActive = state
    if state then
        startEmoteClaim()
    else
        stopEmoteClaim()
    end
end)

local noSlowdownsToggle = ReplicatedStorage.Settings.Toggles.NoSlowdowns
local defaultNoSlowdowns = false
MainLeft2:AddToggle("NoSlowdowns", {Text = "无减速效果", Default = noSlowdownsToggle.Value}):OnChanged(function(state)
    if state then AddToArrayList("无减速") else RemoveFromArrayList("无减速") end
    if state then
        noSlowdownsToggle.Value = true
    else
        noSlowdownsToggle.Value = defaultNoSlowdowns
    end
end)

local settings = ReplicatedStorage.Settings
local defaultDisableHitStun = settings.Toggles.DisableHitStun.Value
MainLeft2:AddToggle("DisableHitStun", {Text = "取消被攻击硬直", Default = false}):OnChanged(function(state)
    if state then AddToArrayList("取消硬直") else RemoveFromArrayList("取消硬直") end
    settings.Toggles.DisableHitStun.Value = state
end)

local defaultDisableIntros = settings.Toggles.DisableIntros.Value
MainLeft2:AddToggle("DisableIntros", {Text = "跳过角色开场动作", Default = false}):OnChanged(function(state)
    if state then AddToArrayList("跳过开场") else RemoveFromArrayList("跳过开场") end
    settings.Toggles.DisableIntros.Value = state
end)

local defaultNoStunOnMiss = settings.Toggles.NoStunOnMiss.Value
MainLeft2:AddToggle("NoStunOnMiss", {Text = "普攻无僵直", Default = false}):OnChanged(function(state)
    if state then AddToArrayList("普攻无僵直") else RemoveFromArrayList("普攻无僵直") end
    settings.Toggles.NoStunOnMiss.Value = state
end)

local defaultRagdollTimer = settings.Multipliers.RagdollTimer.Value
MainLeft2:AddToggle("NoRagdoll", {Text = "被别人击倒不会变成布娃娃", Default = false}):OnChanged(function(state)
    if state then AddToArrayList("防布娃娃") else RemoveFromArrayList("防布娃娃") end
    settings.Multipliers.RagdollTimer.Value = state and 0.5 or defaultRagdollTimer
end)

local defaultUltimateTimer = settings.Multipliers.UltimateTimer.Value
MainLeft2:AddToggle("UltimateTimer", {Text = "延长大招时间", Default = false}):OnChanged(function(state)
    if state then AddToArrayList("无限大招") else RemoveFromArrayList("无限大招") end
    settings.Multipliers.UltimateTimer.Value = state and 100000 or defaultUltimateTimer
end)

local defaultInstantTransformation = settings.Toggles.InstantTransformation.Value
MainLeft2:AddToggle("InstantTransformation", {Text = "秒开大", Default = false}):OnChanged(function(state)
    if state then AddToArrayList("秒开大") else RemoveFromArrayList("秒开大") end
    settings.Toggles.InstantTransformation.Value = state
end)

local Ping = player:WaitForChild("Info"):WaitForChild("Ping")
local pingLoop = nil
MainLeft2:AddToggle("PingSpam", {Text = "ping乱码", Default = false}):OnChanged(function(state)
    if state then AddToArrayList("Ping乱码") else RemoveFromArrayList("Ping乱码") end
    if state then
        pingLoop = task.spawn(function()
            while true do
                for i = 0, 999, 25 do
                    Ping.Value = i
                    task.wait(0.03)
                end
                for i = 999, 0, -25 do
                    Ping.Value = i
                    task.wait(0.03)
                end
            end
        end)
    else
        if pingLoop then
            task.cancel(pingLoop)
            pingLoop = nil
        end
    end
end)

local MeleeDamage = ReplicatedStorage:WaitForChild("Settings"):WaitForChild("Multipliers"):WaitForChild("MeleeDamage")
MeleeDamage.Value = 100
MainLeft2:AddToggle("OnePunch", {Text = "一拳倒地", Default = false}):OnChanged(function(state)
    if state then AddToArrayList("一拳倒地") else RemoveFromArrayList("一拳倒地") end
    if state then
        MeleeDamage.Value = 1000000
    else
        MeleeDamage.Value = 100
    end
end)

local RagdollPower = ReplicatedStorage:WaitForChild("Settings"):WaitForChild("Multipliers"):WaitForChild("RagdollPower")
local flyPunchConnection = nil
MainLeft2:AddToggle("OnePunchFly", {Text = "一拳击飞", Default = false}):OnChanged(function(state)
    if state then AddToArrayList("一拳击飞") else RemoveFromArrayList("一拳击飞") end
    local LocalPlayer = player
    local maxTeleportDistance = 50
    local lastPosition = nil
    if state then
        RagdollPower.Value = 10000
        flyPunchConnection = RunService.RenderStepped:Connect(function()
            local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
            if not lastPosition then
                lastPosition = HumanoidRootPart.Position
            end
            local currentPos = HumanoidRootPart.Position
            local distance = (currentPos - lastPosition).Magnitude
            if distance > maxTeleportDistance then
                HumanoidRootPart.CFrame = CFrame.new(lastPosition)
            else
                lastPosition = currentPos
            end
        end)
    else
        RagdollPower.Value = 100
        if flyPunchConnection then
            flyPunchConnection:Disconnect()
            flyPunchConnection = nil
        end
    end
end)

local wallCombo = ReplicatedStorage.Settings.Cooldowns.WallCombo
MainLeft2:AddToggle("WallComboCooldown", {Text = "墙打无冷却", Default = false}):OnChanged(function(state)
    if state then AddToArrayList("墙打无冷却") else RemoveFromArrayList("墙打无冷却") end
    if state then
        wallCombo.Value = 0
    else
        wallCombo.Value = 100
    end
end)

local wall = nil
pcall(function()
    wall = workspace.Map.Structural.Terrain:GetChildren()[5]:GetChildren()[12]
end)
if not wall then
    wall = Instance.new("Part")
    wall.Parent = workspace
end
wall.Size = Vector3.new(12,6,2)
wall.Transparency = 0.6
wall.Material = Enum.Material.SmoothPlastic
wall.Anchored = true
wall.CanCollide = true
wall.CFrame = wall.CFrame or CFrame.new(0,5,0)
if getconnections then
    for _, conn in pairs(getconnections(wall.AncestryChanged)) do
        conn:Disable()
    end
end
local mt = getrawmetatable(game)
setreadonly(mt,false)
local old = mt.__namecall
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if self == wall and method == "Destroy" then
        return
    end
    return old(self, ...)
end)
setreadonly(mt,true)

local followConnection = nil
MainLeft2:AddToggle("FollowWall", {Text = "随处墙打", Default = false}):OnChanged(function(state)
    if state then AddToArrayList("随处墙打") else RemoveFromArrayList("随处墙打") end
    if state then
        if not followConnection then
            followConnection = RunService.RenderStepped:Connect(function()
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    wall.CFrame = hrp.CFrame * CFrame.new(0,0,-8)
                end
            end)
        end
    else
        if followConnection then
            followConnection:Disconnect()
            followConnection = nil
        end
    end
end)

local originalData = {}
local skyBackup = nil
MainRight1:AddToggle("AntiLag", {Text = "防卡", Default = false}):OnChanged(function(state)
    if state then AddToArrayList("防卡") else RemoveFromArrayList("防卡") end
    if state then
        originalData = {}
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Explosion") then
                originalData[v] = v.Enabled
                v.Enabled = false
            elseif v:IsA("Decal") or v:IsA("Texture") then
                originalData[v] = v.Transparency
                v.Transparency = 1
            elseif v:IsA("MeshPart") or v:IsA("UnionOperation") or v:IsA("Part") then
                if v.Name ~= "HumanoidRootPart" then
                    originalData[v] = v.Material
                    v.Material = Enum.Material.SmoothPlastic
                end
            elseif v:IsA("SurfaceGui") or v:IsA("BillboardGui") or v:IsA("Beam") then
                if v:IsA("Beam") then
                    originalData[v] = v.Enabled
                    v.Enabled = false
                else
                    originalData[v] = v.Enabled ~= nil and v.Enabled or true
                    if v.Enabled ~= nil then
                        v.Enabled = false
                    end
                end
            end
        end
        originalData["GlobalShadows"] = game.Lighting.GlobalShadows
        originalData["FogEnd"] = game.Lighting.FogEnd
        game.Lighting.GlobalShadows = false
        game.Lighting.FogEnd = 9e9
        local sky = game.Lighting:FindFirstChildOfClass("Sky")
        if sky then
            skyBackup = sky:Clone()
            sky:Destroy()
        end
        local newSky = Instance.new("Sky")
        newSky.SkyboxBk = ""
        newSky.SkyboxDn = ""
        newSky.SkyboxFt = ""
        newSky.SkyboxLf = ""
        newSky.SkyboxRt = ""
        newSky.SkyboxUp = ""
        newSky.SunAngularSize = 0
        newSky.MoonAngularSize = 0
        newSky.Parent = game.Lighting
        game.Lighting.Ambient = Color3.fromRGB(128,128,128)
        game.Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
    else
        for obj, value in pairs(originalData) do
            if typeof(obj) == "Instance" and obj.Parent then
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Explosion") then
                    obj.Enabled = value
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = value
                elseif obj:IsA("MeshPart") or obj:IsA("UnionOperation") or obj:IsA("Part") then
                    obj.Material = value
                elseif obj:IsA("SurfaceGui") or obj:IsA("BillboardGui") or obj:IsA("Beam") then
                    if obj:IsA("Beam") then
                        obj.Enabled = value
                    elseif obj.Enabled ~= nil then
                        obj.Enabled = value
                    end
                end
            elseif obj == "GlobalShadows" then
                game.Lighting.GlobalShadows = value
            elseif obj == "FogEnd" then
                game.Lighting.FogEnd = value
            end
        end
        if skyBackup then
            local currentSky = game.Lighting:FindFirstChildOfClass("Sky")
            if currentSky then
                currentSky:Destroy()
            end
            skyBackup.Parent = game.Lighting
            skyBackup = nil
        end
        originalData = {}
    end
end)

local clone, platform, originalCFrame
local Camera = workspace.CurrentCamera
local function CreatePlatform(position)
    local part = Instance.new("Part")
    part.Size = Vector3.new(10, 1, 10)
    part.Position = position - Vector3.new(0, 3, 0)
    part.Anchored = true
    part.CanCollide = true
    part.Transparency = 0.5
    part.Parent = workspace
    return part
end
local function CreateClone()
    local Character = player.Character or player.CharacterAdded:Wait()
    local newClone = Character:Clone()
    for _, v in ipairs(newClone:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Transparency = 0.5
        end
    end
    newClone.Parent = workspace
    return newClone
end
local function ToggleInvisibility(state)
    local Character = player.Character or player.CharacterAdded:Wait()
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    if state then
        originalCFrame = HumanoidRootPart.CFrame
        HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + Vector3.new(0, -50, 0)
        platform = CreatePlatform(HumanoidRootPart.Position)
        task.wait(1)
        clone = CreateClone()
        clone:MoveTo(originalCFrame.Position)
        Camera.CameraSubject = clone:FindFirstChildWhichIsA("Humanoid")
        player.Character = clone
    else
        if clone then
            clone:Destroy()
            clone = nil
        end
        if platform then
            platform:Destroy()
            platform = nil
        end
        if originalCFrame then
            HumanoidRootPart.CFrame = originalCFrame
            originalCFrame = nil
        end
        Camera.CameraSubject = Character:FindFirstChildWhichIsA("Humanoid")
        player.Character = Character
    end
end
MainRight1:AddToggle("Invisibility", {Text = "隐身", Default = false}):OnChanged(function(state)
    if state then AddToArrayList("隐身") else RemoveFromArrayList("隐身") end
    ToggleInvisibility(state)
end)

local CircleParts = {}
local CircleConnection
local function RainbowColor(t)
    local r = math.sin(t) * 40 + 180
    local g = math.sin(t + 2) * 40 + 180
    local b = math.sin(t + 4) * 40 + 180
    return Color3.fromRGB(r, g, b)
end
MainRight1:AddToggle("CircleDisplay", {Text = "墙打/杀戮光环范围显示", Default = false}):OnChanged(function(state)
    if state then AddToArrayList("范围显示") else RemoveFromArrayList("范围显示") end
    local function CreateCircle(radius, segments, thickness)
        local parts = {}
        for i = 1, segments do
            local part = Instance.new("Part")
            part.Anchored = true
            part.CanCollide = false
            part.Material = Enum.Material.Neon
            part.Size = Vector3.new(thickness, 0.2, radius * 2 * math.pi / segments)
            part.Color = Color3.fromRGB(180,180,180)
            part.Parent = workspace
            table.insert(parts, part)
        end
        return parts
    end
    local function DestroyCircle()
        if CircleConnection then
            CircleConnection:Disconnect()
            CircleConnection = nil
        end
        for _, part in ipairs(CircleParts) do
            if part and part.Parent then
                part:Destroy()
            end
        end
        CircleParts = {}
    end
    if state then
        DestroyCircle()
        local radius = 60
        local segments = 60
        local thickness = 0.2
        CircleParts = CreateCircle(radius, segments, thickness)
        local time = 0
        local updateAccumulator = 0
        local updateRate = 1/60
        CircleConnection = RunService.RenderStepped:Connect(function(dt)
            time = time + dt
            updateAccumulator = updateAccumulator + dt
            if updateAccumulator < updateRate then return end
            updateAccumulator = 0
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local rootPos = char.HumanoidRootPart.Position
                local humanoid = char:FindFirstChild("Humanoid")
                local heightOffset = humanoid and humanoid.HipHeight / 2 + 0.1 or 0.9
                local pos = rootPos - Vector3.new(0, heightOffset, 0)
                for i, part in ipairs(CircleParts) do
                    local angle = (i / #CircleParts) * 2 * math.pi
                    local x = pos.X + math.cos(angle) * radius
                    local z = pos.Z + math.sin(angle) * radius
                    part.Position = Vector3.new(x, pos.Y, z)
                    part.Orientation = Vector3.new(0, -math.deg(angle), 0)
                    part.Color = RainbowColor(time + i * 0.1)
                end
            end
        end)
    else
        DestroyCircle()
    end
end)

MainRight1:AddButton("删除墙打特效", function()
    local paths = {
        ReplicatedStorage.Characters.Gon.WallCombo.GonWallCombo.Center,
        ReplicatedStorage.Characters.Gon.WallCombo.GonWallCombo.Explosion,
        ReplicatedStorage.Characters.Gon.WallCombo.GonIntroHands,
        ReplicatedStorage.Characters.Mob.WallCombo.MobWallCombo.Center,
        ReplicatedStorage.Characters.Nanami.WallCombo.NanamiWallCombo.Center,
        ReplicatedStorage.Characters.Stark.WallCombo.StarkWallCombo.Center,
        ReplicatedStorage.Characters.Sukuna.WallCombo.SukunaTransformWallCombo,
        ReplicatedStorage.Characters.Sukuna.WallCombo.SukunaWallCombo
    }
    for _, obj in ipairs(paths) do
        if obj and obj:IsA("Instance") then
            for _, child in ipairs(obj:GetChildren()) do
                child:Destroy()
            end
        end
    end
end)

MainRight1:AddButton("删除击杀表情特效", function()
    local KillEmote = ReplicatedStorage:WaitForChild("Cosmetics"):WaitForChild("KillEmote")
    local function removeEffects(obj)
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("ParticleEmitter") or child:IsA("Trail") or child:IsA("Beam") or child:IsA("Fire") or child:IsA("Smoke") or child:IsA("Sparkles") or child:IsA("Light") then
                child:Destroy()
            else
                removeEffects(child)
            end
        end
    end
    removeEffects(KillEmote)
end)

local multiUseCutscenesToggle = ReplicatedStorage.Settings.Toggles.MultiUseCutscenes
local defaultMultiUse = false
MainRight1:AddToggle("MultiUseCutscenes", {Text = "艾斯帕大招技能多次使用(全角色通用)", Default = multiUseCutscenesToggle.Value}):OnChanged(function(state)
    if state then AddToArrayList("大招多次使用") else RemoveFromArrayList("大招多次使用") end
    if state then
        multiUseCutscenesToggle.Value = true
    else
        multiUseCutscenesToggle.Value = defaultMultiUse
    end
end)

local QEfly = true
local FLYING = false
local flyKeyDown, flyKeyUp, mobileFlyConn
local iyflyspeed = 2
local vehicleflyspeed = 2
local FLY_TOGGLE_STATE = false
local function getRoot(char)
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end
local function NOFLY()
    FLYING = false
    if flyKeyDown then flyKeyDown:Disconnect() flyKeyDown = nil end
    if flyKeyUp then flyKeyUp:Disconnect() flyKeyUp = nil end
    if mobileFlyConn then mobileFlyConn:Disconnect() mobileFlyConn = nil end
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local root = getRoot(char)
        if humanoid then humanoid.PlatformStand = false end
        if root then
            for _, v in pairs(root:GetChildren()) do
                if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then
                    v:Destroy()
                end
            end
        end
    end
    pcall(function()
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end)
end
local function sFLY(vfly)
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")
    local root = getRoot(char)
    if not root then return end
    if flyKeyDown then flyKeyDown:Disconnect() end
    if flyKeyUp then flyKeyUp:Disconnect() end
    if mobileFlyConn then mobileFlyConn:Disconnect() end
    local CONTROL = {F=0,B=0,L=0,R=0,Q=0,E=0}
    local BG = Instance.new("BodyGyro")
    local BV = Instance.new("BodyVelocity")
    BG.P = 9e4
    BG.MaxTorque = Vector3.new(9e9,9e9,9e9)
    BG.CFrame = root.CFrame
    BG.Parent = root
    BV.MaxForce = Vector3.new(9e9,9e9,9e9)
    BV.Velocity = Vector3.new(0,0,0)
    BV.Parent = root
    FLYING = true
    flyKeyDown = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.W then CONTROL.F = iyflyspeed end
            if input.KeyCode == Enum.KeyCode.S then CONTROL.B = -iyflyspeed end
            if input.KeyCode == Enum.KeyCode.A then CONTROL.L = -iyflyspeed end
            if input.KeyCode == Enum.KeyCode.D then CONTROL.R = iyflyspeed end
            if input.KeyCode == Enum.KeyCode.E and QEfly then CONTROL.Q = iyflyspeed*2 end
            if input.KeyCode == Enum.KeyCode.Q and QEfly then CONTROL.E = -iyflyspeed*2 end
        end
    end)
    flyKeyUp = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.W then CONTROL.F = 0 end
            if input.KeyCode == Enum.KeyCode.S then CONTROL.B = 0 end
            if input.KeyCode == Enum.KeyCode.A then CONTROL.L = 0 end
            if input.KeyCode == Enum.KeyCode.D then CONTROL.R = 0 end
            if input.KeyCode == Enum.KeyCode.E then CONTROL.Q = 0 end
            if input.KeyCode == Enum.KeyCode.Q then CONTROL.E = 0 end
        end
    end)
    mobileFlyConn = RunService.RenderStepped:Connect(function()
        if not FLYING then return end
        local camera = workspace.CurrentCamera
        local moveVector = Vector3.new(CONTROL.L+CONTROL.R, CONTROL.Q+CONTROL.E, CONTROL.F+CONTROL.B)
        local ok, controlModule = pcall(function()
            return require(player.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
        end)
        if ok and controlModule then
            local mv = controlModule:GetMoveVector()
            moveVector = Vector3.new(mv.X*(vfly and vehicleflyspeed or iyflyspeed), moveVector.Y, -mv.Z*(vfly and vehicleflyspeed or iyflyspeed))
        end
        BV.Velocity = (camera.CFrame.RightVector*moveVector.X + Vector3.new(0,moveVector.Y,0) + camera.CFrame.LookVector*moveVector.Z)*50
        BG.CFrame = camera.CFrame
        humanoid.PlatformStand = true
    end)
end
local function applyFly()
    sFLY()
    player.CharacterAdded:Connect(function()
        if FLY_TOGGLE_STATE then
            task.wait(0.5)
            sFLY()
        end
    end)
end
MainLeft3:AddToggle("Fly", {Text = "飞行", Default = false}):OnChanged(function(state)
    FLY_TOGGLE_STATE = state
    if state then AddToArrayList("飞行", iyflyspeed) else RemoveFromArrayList("飞行") end
    if state then
        applyFly()
    else
        NOFLY()
    end
end)
MainLeft3:AddSlider("FlySpeed", {Text = "飞行速度", Min = 1, Max = 10, Default = 2, Rounding = 0}):OnChanged(function(value)
    iyflyspeed = value
    vehicleflyspeed = value
    if FLY_TOGGLE_STATE then UpdateModuleDisplay("飞行", value) end
end)

local tpwalking = false
local tpwalkSpeed = 100
MainLeft3:AddToggle("Speed", {Text = "速度", Default = false}):OnChanged(function(state)
    tpwalking = state
    if state then AddToArrayList("速度", tpwalkSpeed) else RemoveFromArrayList("速度") end
    if state then
        spawn(function()
            while tpwalking do
                local chr = player.Character or player.CharacterAdded:Wait()
                local hrp = chr:FindFirstChild("HumanoidRootPart")
                local hum = chr:FindFirstChildWhichIsA("Humanoid")
                local delta = RunService.Heartbeat:Wait()
                if hrp and hum and hum.MoveDirection.Magnitude > 0 then
                    hrp.CFrame = hrp.CFrame + (hum.MoveDirection * tpwalkSpeed * delta)
                end
            end
        end)
    end
end)
MainLeft3:AddSlider("SpeedSlider", {Text = "速度调节", Min = 0, Max = 250, Default = 100, Rounding = 0}):OnChanged(function(value)
    tpwalkSpeed = value
    if tpwalking then UpdateModuleDisplay("速度", value) end
end)
MainLeft3:AddSlider("DashSpeed", {Text = "冲刺加速(默认值100)", Min = 0, Max = 1000, Default = 100, Rounding = 0}):OnChanged(function(value)
    ReplicatedStorage.Settings.Multipliers.DashSpeed.Value = value
end)
MainLeft3:AddSlider("JumpHeight", {Text = "跳跃增强(默认值100)", Min = 0, Max = 1000, Default = 100, Rounding = 0}):OnChanged(function(value)
    ReplicatedStorage.Settings.Multipliers.JumpHeight.Value = value
end)
MainLeft3:AddSlider("MeleeSpeed", {Text = "攻击加速(默认值100)", Min = 0, Max = 1000, Default = 100, Rounding = 0}):OnChanged(function(value)
    ReplicatedStorage.Settings.Multipliers.MeleeSpeed.Value = value
end)

local activeGod = false
local function getLocalPlayerCharacter()
    return player.Character
end
local function generateActionNumber()
    return "Action" .. math.random(1000, 9999)
end
local function getServerTime()
    return tick()
end
local function wallcomboveryud()
    local playerChar = getLocalPlayerCharacter()
    if not playerChar then return false end
    local head = playerChar:FindFirstChild("Head")
    if not head then return false end
    local charData = player:FindFirstChild("Data")
    local charValue = charData and charData:FindFirstChild("Character") and charData.Character.Value
    if not charValue then return false end
    local charsFolder = ReplicatedStorage:FindFirstChild("Characters")
    if not charsFolder or not charsFolder:FindFirstChild(charValue) then return false end
    local wallComboAbility = charsFolder[charValue]:FindFirstChild("WallCombo")
    if not wallComboAbility then return false end
    local targetCharacter = playerChar
    if not targetCharacter then return false end
    local actionNumber = generateActionNumber()
    local serverTime = getServerTime()
    local randomId = math.random(100000, 999999)
    local remoteArgs = {
        wallComboAbility,
        "Characters:" .. charValue .. ":WallCombo",
        1,
        randomId,
        {
            HitboxCFrames = {nil},
            BestHitCharacter = targetCharacter,
            HitCharacters = {targetCharacter},
            Ignore = {[actionNumber] = {targetCharacter}},
            DeathInfo = {},
            Actions = {[actionNumber] = {}},
            HitInfo = {
                Blocked = false,
                IsFacing = true,
                IsInFront = true
            },
            BlockedCharacters = {},
            ServerTime = serverTime,
            FromCFrame = nil
        },
        actionNumber
    }
    pcall(function()
        ReplicatedStorage.Remotes.Abilities.Ability:FireServer(wallComboAbility, randomId)
    end)
    pcall(function()
        ReplicatedStorage.Remotes.Combat.Action:FireServer(unpack(remoteArgs))
    end)
end
task.spawn(function()
    while task.wait(0.01) do
        if activeGod then
            pcall(wallcomboveryud)
        end
    end
end)
ViolentLeft1:AddToggle("GodMode", {Text = "无敌", Default = false}):OnChanged(function(state)
    if state then AddToArrayList("无敌") else RemoveFromArrayList("无敌") end
    activeGod = state
end)

ViolentLeft1:AddButton("卡服", function()
    local active = true
    local spawnedTasks = {}
    local function buildCombatArgs()
        return {
            [1] = ReplicatedStorage.Characters.Gon.WallCombo,
            [2] = "Characters:Gon:WallCombo",
            [3] = 1,
            [4] = 33036,
            [5] = {
                ["HitboxCFrames"] = {},
                ["BestHitCharacter"] = workspace.Characters.NPCs:FindFirstChild("The Ultimate Bum"),
                ["HitCharacters"] = {workspace.Characters.NPCs:FindFirstChild("The Ultimate Bum")},
                ["Ignore"] = {},
                ["DeathInfo"] = {},
                ["Actions"] = {},
                ["HitInfo"] = {
                    ["IsFacing"] = true,
                    ["IsInFront"] = true
                },
                ["BlockedCharacters"] = {},
                ["ServerTime"] = os.clock(),
                ["FromCFrame"] = CFrame.new(534.693, 5.532, 79.486)
            },
            [6] = "Action651",
            [7] = 0
        }
    end
    local abilityArgs = {
        [1] = ReplicatedStorage.Characters.Gon.WallCombo,
        [2] = 33036,
        [4] = workspace.Characters.NPCs:FindFirstChild("The Ultimate Bum"),
        [5] = Vector3.new(527.693, 4.532, 79.978)
    }
    for i = 1, 10000 do
        local t = task.spawn(function()
            if active then
                pcall(function()
                    local combatArgs = buildCombatArgs()
                    ReplicatedStorage.Remotes.Abilities.Ability:FireServer(unpack(abilityArgs))
                    ReplicatedStorage.Remotes.Combat.Action:FireServer(unpack(combatArgs))
                end)
            end
        end)
        table.insert(spawnedTasks, t)
    end
    task.delay(3, function()
        active = false
        for _, t in ipairs(spawnedTasks) do
            if task.cancel then
                task.cancel(t)
            end
        end
        spawnedTasks = {}
        local localContainers = workspace:FindFirstChild("Container(Drawing)")
        if localContainers then
            for _, v in ipairs(localContainers:GetChildren()) do
                if v.Name:match(tostring(player.UserId)) then
                    v:Destroy()
                end
            end
        end
    end)
end)
local KillAllF = {}
KillAllF.P = Players
KillAllF.R = RunService
KillAllF.RS = ReplicatedStorage
KillAllF.W = workspace
KillAllF.L = player
KillAllF.Cfg = {
    Enabled = false,
    Range = 67.5,
    Friends = true,
    Target = "Closest"
}
KillAllF.Data = {
    List = {},
    Idx = 1,
    FCon = nil,
    KCon = nil,
    OSub = nil,
    OType = nil,
    SCFrame = nil,
    SCCFrame = nil,
    SCType = nil
}
KillAllF.Dash = function()
    local char = KillAllF.L.Character or KillAllF.L.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        require(KillAllF.RS:WaitForChild("Core")).Library("Remote").Send("Dash", hrp.CFrame, "L", 1)
    end
end
KillAllF.HRP = function()
    local c = KillAllF.L.Character
    if c and c:FindFirstChild('Humanoid') and c.Humanoid.RootPart then
        return c.Humanoid.RootPart
    end
    return nil
end
KillAllF.IsF = function(p)
    if not p or p == KillAllF.L then return false end
    return KillAllF.L:IsFriendsWith(p.UserId)
end
KillAllF.GetT = function()
    local tgs = {}
    local root = KillAllF.HRP()
    if not root then return tgs end
    local pos = root.Position
    for _, v in ipairs(KillAllF.P:GetPlayers()) do
        local char = v.Character
        if char and v ~= KillAllF.L and char:FindFirstChild(' ') == nil then
            if KillAllF.Cfg.Friends and KillAllF.IsF(v) then continue end
            local hum = char:FindFirstChild('Humanoid')
            local hrp = char:FindFirstChild('HumanoidRootPart')
            if hum and hrp then
                local dist = (hrp.Position - pos).Magnitude
                if dist < KillAllF.Cfg.Range then
                    local lchar = KillAllF.L.Character
                    if lchar then
                        local lName = lchar.Name
                        local cs = char:GetAttribute("Cutscene")
                        local csV = not cs or cs == lchar:GetAttribute("Cutscene")
                        if hrp and not char:GetAttribute("Ignore") and csV and ((not char:GetAttribute("Grabbed") or char:GetAttribute("Grabbed") == lName) and (not char:GetAttribute("Victim") or char:GetAttribute("Victim") == lName)) and not char:GetAttribute("Invincible") and not char:GetAttribute("Grabbing") then
                            table.insert(tgs, {c = char, d = dist, h = hum:GetAttribute("Health") or hum.Health or 0})
                        end
                    end
                end
            end
        end
    end
    if KillAllF.Cfg.Target == "Closest" and #tgs > 0 then
        table.sort(tgs, function(a, b) return a.d < b.d end)
        return {tgs[1]}
    end
    return tgs
end
KillAllF.Aura = function(n)
    local root = KillAllF.HRP()
    if not root then return end
    local tgs = KillAllF.GetT()
    for _, data in ipairs(tgs) do
        if data.c then
            for i=1, n do
                KillAllF.Data.List[KillAllF.Data.Idx] = data.c
                KillAllF.Data.Idx = KillAllF.Data.Idx + 1
            end
        end
    end
    if KillAllF.Data.Idx > 1 then
        local name = KillAllF.L.Data.Character.Value
        local combo = KillAllF.RS.Characters[name].WallCombo
        KillAllF.RS.Remotes.Abilities.Ability:FireServer(combo, 69)
        KillAllF.RS.Remotes.Combat.Action:FireServer(combo, "", 4, 69, {BestHitCharacter=nil, HitCharacters=KillAllF.Data.List, Ignore={}, Actions={}})
        for k in pairs(KillAllF.Data.List) do KillAllF.Data.List[k] = nil end
        KillAllF.Data.Idx = 1
    end
end
KillAllF.GetR = function()
    local al = {}
    for _, p in ipairs(KillAllF.P:GetPlayers()) do
        if p ~= KillAllF.L and p.Character then
            local hu = p.Character:FindFirstChild("Humanoid")
            local hr = p.Character:FindFirstChild("HumanoidRootPart")
            if hu and hr and (hu:GetAttribute("Health") or 0) > 0 and not hu:GetAttribute("Godmode") then
                table.insert(al, p)
            end
        end
    end
    return #al > 0 and al[math.random(1, #al)] or nil
end
KillAllF.TP = function(p)
    if not p or not p.Character then return false end
    local hr = p.Character:FindFirstChild("HumanoidRootPart")
    if not hr then return false end
    pcall(function()
        require(KillAllF.L.PlayerScripts.Character.FullCustomReplication).Override(KillAllF.L.Character, CFrame.new(hr.Position - Vector3.new(0, 30, 0)))
    end)
    return true
end
KillAllF.Spec = function(p)
    local cam = KillAllF.W.CurrentCamera
    if cam and p and p.Character then
        local hu = p.Character:FindFirstChildOfClass("Humanoid")
        if hu then cam.CameraType = Enum.CameraType.Custom cam.CameraSubject = hu end
    end
end
KillAllF.Loop = function()
    local c = KillAllF.L.Character
    if not c or not c.Parent then return end
    local r = KillAllF.GetR()
    if r then
        KillAllF.TP(r)
        KillAllF.Spec(r)
        task.wait(0.5)
    end
end
KillAllF.Grav = function(b)
    local c = KillAllF.L.Character
    if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then
            p.Anchored = not b
            if not b then p.Velocity = Vector3.new(0,0,0) end
        end
    end
end
KillAllF.Save = function()
    local c = KillAllF.L.Character
    local hr = c and c:FindFirstChild("HumanoidRootPart")
    if not hr then return false end
    KillAllF.Data.SCFrame = hr.CFrame
    local cam = KillAllF.W.CurrentCamera
    if cam then
        KillAllF.Data.SCCFrame = cam.CFrame
        KillAllF.Data.SCType = cam.CameraType
    end
    return true
end
KillAllF.Rest = function()
    if not KillAllF.Data.SCFrame or not KillAllF.L.Character then return end
    pcall(function() require(KillAllF.L.PlayerScripts.Character.FullCustomReplication).Override(KillAllF.L.Character, KillAllF.Data.SCFrame) end)
    task.delay(0.1, function()
        local cam = KillAllF.W.CurrentCamera
        if cam and KillAllF.Data.SCCFrame then
            cam.CameraType = KillAllF.Data.SCType
            cam.CFrame = KillAllF.Data.SCCFrame
        end
    end)
end
KillAllF.Start = function()
    if not KillAllF.Save() then return end
    KillAllF.Grav(false)
    local cam = KillAllF.W.CurrentCamera
    if cam then
        KillAllF.Data.OSub = cam.CameraSubject
        KillAllF.Data.OType = cam.CameraType
    end
    KillAllF.Data.FCon = KillAllF.R.Heartbeat:Connect(KillAllF.Loop)
    KillAllF.Data.KCon = KillAllF.R.Heartbeat:Connect(function()
        KillAllF.Dash()
        local cn = KillAllF.L.Data.Character.Value
        KillAllF.Aura(cn == "Gon" and 20 or 50)
    end)
end
KillAllF.Stop = function()
    if KillAllF.Data.FCon then KillAllF.Data.FCon:Disconnect() KillAllF.Data.FCon = nil end
    if KillAllF.Data.KCon then KillAllF.Data.KCon:Disconnect() KillAllF.Data.KCon = nil end
    KillAllF.Rest()
    KillAllF.Grav(true)
    local cam = KillAllF.W.CurrentCamera
    if cam and KillAllF.Data.OSub then
        cam.CameraSubject = KillAllF.Data.OSub
        cam.CameraType = KillAllF.Data.OType
    end
end
ViolentLeft1:AddToggle("KillAll", {Text = "全图秒杀", Default = false}):OnChanged(function(state)
    KillAllF.Cfg.Enabled = state
    if KillAllF.Cfg.Enabled then
        KillAllF.Start()
    else
        KillAllF.Stop()
    end
end)
KillAllF.L.CharacterAdded:Connect(function()
    if KillAllF.Cfg.Enabled then
        KillAllF.Stop()
        KillAllF.Cfg.Enabled = false
    end
end)

local Configs = {
    IgnoreFriends = false,
    MaxDistance = 100,
    Damage = 9999,
    HealthLimit = 0,
    DashInterval = 0.7,
    AttackInterval = 0.001
}
local runningAura = false
local auraConn
local lastDash = 0
local lastAttack = 0
local data = player:WaitForChild("Data")
local charValue = data:WaitForChild("Character")
local localCharacterName = charValue.Value
local ability = ReplicatedStorage:WaitForChild("Characters"):WaitForChild(localCharacterName):WaitForChild("WallCombo")
local AbilitiesRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Abilities"):WaitForChild("Ability")
local CombatRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Combat"):WaitForChild("Action")
local function getLocalRootPart()
    local c = player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function triggerDash()
    if tick() - lastDash < Configs.DashInterval then return end
    lastDash = tick()
    local hrp = getLocalRootPart()
    if not hrp then return end
    local dashRemote = ReplicatedStorage.Remotes.Character:FindFirstChild("Dash")
    if dashRemote then
        pcall(function()
            dashRemote:FireServer(hrp.CFrame, "L", hrp.CFrame.LookVector, nil, tick())
        end)
    end
end
local function sendKillAura()
    if tick() - lastAttack < Configs.AttackInterval then return end
    lastAttack = tick()
    local localRootPart = getLocalRootPart()
    if not localRootPart then return end
    triggerDash()
    local maxDistSq = Configs.MaxDistance * Configs.MaxDistance
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= player then
            local targetChar = targetPlayer.Character
            if targetChar then
                local targetRootPart = targetChar:FindFirstChild("HumanoidRootPart")
                local targetHumanoid = targetChar:FindFirstChild("Humanoid")
                if targetRootPart and targetHumanoid and targetHumanoid.Health > Configs.HealthLimit then
                    if not (Configs.IgnoreFriends and player:IsFriendsWith(targetPlayer.UserId)) then
                        local delta = localRootPart.Position - targetRootPart.Position
                        if delta.Magnitude * delta.Magnitude <= maxDistSq then
                            pcall(function()
                                AbilitiesRemote:FireServer(ability, Configs.Damage, {}, targetRootPart.Position)
                            end)
                            pcall(function()
                                CombatRemote:FireServer(
                                    ability,
                                    localCharacterName .. ":WallCombo",
                                    2,
                                    Configs.Damage,
                                    {
                                        HitboxCFrames = {targetRootPart.CFrame, targetRootPart.CFrame},
                                        BestHitCharacter = targetChar,
                                        HitCharacters = {targetChar},
                                        Ignore = {},
                                        DeathInfo = {},
                                        BlockedCharacters = {},
                                        HitInfo = {IsFacing = false, IsInFront = true},
                                        ServerTime = os.time(),
                                        Actions = {
                                            ActionNumber1 = {
                                                [targetPlayer.Name] = {
                                                    StartCFrameStr = tostring(localRootPart.CFrame),
                                                    Local = true,
                                                    Collision = false,
                                                    Animation = "Punch1Hit",
                                                    Preset = "Punch",
                                                    Velocity = Vector3.zero,
                                                    FromPosition = targetRootPart.Position,
                                                    Seed = math.random(1,999999)
                                                }
                                            }
                                        },
                                        FromCFrame = targetRootPart.CFrame
                                    },
                                    "Action150",
                                    0
                                )
                            end)
                        end
                    end
                end
            end
        end
    end
end
local function startAura()
    if auraConn then auraConn:Disconnect() auraConn = nil end
    auraConn = RunService.Heartbeat:Connect(function()
        if runningAura then
            sendKillAura()
        end
    end)
end
local function stopAura()
    if auraConn then auraConn:Disconnect() auraConn = nil end
end
ViolentLeft2:AddToggle("KillAuraV1", {Text = "杀戮光环v1(慢)", Default = false}):OnChanged(function(state)
    if state then AddToArrayList("杀戮光环") else RemoveFromArrayList("杀戮光环") end
    runningAura = state
    if runningAura then
        startAura()
    else
        stopAura()
    end
end)

local enabledV2 = false
local connV2
local PlayersList = {}
local indexV2 = 1
local RANGE = 70
local DASH_INTERVAL = 0.25
local lastDashV2 = 0
local function C()
    return player.Character
end
local function HRP()
    if C() and C():FindFirstChild("Humanoid") then
        return C().Humanoid.RootPart
    end
end
local function isFriend(p)
    return player:IsFriendsWith(p.UserId)
end
local function triggerDashV2()
    local now = tick()
    if now - lastDashV2 < DASH_INTERVAL then return end
    lastDashV2 = now
    local hrp = HRP()
    if not hrp then return end
    local dashRemote = ReplicatedStorage.Remotes.Character:FindFirstChild("Dash")
    if dashRemote then
        pcall(function()
            dashRemote:FireServer(hrp.CFrame, "L", hrp.CFrame.LookVector, nil, now)
        end)
    end
end
local function getTargets()
    local targets = {}
    local hrp = HRP()
    if not hrp then return targets end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            if isFriend(p) then continue end
            local hum = p.Character:FindFirstChild("Humanoid")
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then
                if (root.Position - hrp.Position).Magnitude <= RANGE then
                    if not p.Character:GetAttribute("Invincible") then
                        table.insert(targets, p.Character)
                    end
                end
            end
        end
    end
    return targets
end
local function KillAuraV2(count)
    triggerDashV2()
    local targets = getTargets()
    for _, char in ipairs(targets) do
        for i = 1, count do
            PlayersList[indexV2] = char
            indexV2 = indexV2 + 1
        end
    end
    if indexV2 > 1 then
        local combo = ReplicatedStorage.Characters[player.Data.Character.Value].WallCombo
        ReplicatedStorage.Remotes.Abilities.Ability:FireServer(combo, 69)
        ReplicatedStorage.Remotes.Combat.Action:FireServer(
            combo,
            "",
            4,
            69,
            {
                BestHitCharacter = nil,
                HitCharacters = PlayersList,
                Ignore = {},
                Actions = {}
            }
        )
        table.clear(PlayersList)
        indexV2 = 1
    end
end
ViolentLeft2:AddToggle("KillAuraV2", {Text = "杀戮光环v2(快)", Default = false}):OnChanged(function(state)
    enabledV2 = state
    if enabledV2 then
        connV2 = RunService.Heartbeat:Connect(function()
            local count = (player.Data.Character.Value == "Gon") and 20 or 50
            KillAuraV2(count)
        end)
    else
        if connV2 then
            connV2:Disconnect()
            connV2 = nil
        end
    end
end)

ViolentLeft2:AddToggle("IgnoreFriends", {Text = "杀戮光环忽略好友", Default = false}):OnChanged(function(state)
    Configs.IgnoreFriends = state
end)

local Core = require(ReplicatedStorage:WaitForChild("Core"))
local charValueWC = player:WaitForChild("Data"):WaitForChild("Character").Value
local charsWC = ReplicatedStorage:WaitForChild("Characters")
local abilityWC = charsWC:WaitForChild(charValueWC):WaitForChild("WallCombo")
local wallComboCooldown = 0.05
local lastWallComboTime = 0
local wallComboKey = Enum.KeyCode.E
local lastDashTimeWC = 0
local wallComboEnabled = false
local ignoreFriendsWC = false
local wallComboConn = nil
local dashConnWC = nil
local function isFriendWC(targetPlayer)
    local ok, res = pcall(function() return player:IsFriendsWith(targetPlayer.UserId) end)
    return ok and res
end
local function shouldIgnorePlayerModel(model)
    if not model then return false end
    if ignoreFriendsWC then
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= player and pl.Character == model then
                if isFriendWC(pl) then
                    return true
                end
            end
        end
    end
    return false
end
local function getHeadWC()
    local character = player.Character
    if not character then return nil end
    return character:FindFirstChild("Head")
end
local function hasValidTargetsForWallCombo(range)
    local head = getHeadWC()
    if not head then return false end
    local hrpPos = head.Position
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= player and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
            if not shouldIgnorePlayerModel(pl.Character) then
                local d = (pl.Character.HumanoidRootPart.Position - hrpPos).Magnitude
                if d <= range then return true end
            end
        end
    end
    return false
end
local function executeWallCombo()
    local head = getHeadWC()
    if not head then return end
    local now = tick()
    if now - lastWallComboTime < wallComboCooldown then return end
    if not hasValidTargetsForWallCombo(100) then return end
    lastWallComboTime = now
    local res
    local success = pcall(function()
        res = Core.Get("Combat","Hit").Box(nil, player.Character, {Size = Vector3.new(100,100,100)})
    end)
    if not success or not res then return end
    pcall(function()
        Core.Get("Combat","Ability").Activate(charsWC[charValueWC].WallCombo, res, head.Position + Vector3.new(0,0,2.5))
    end)
end
local function fireDashWC()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local now = tick()
    if now - lastDashTimeWC < 0.1 then return end
    lastDashTimeWC = now
    local args = {
        [1] = hrp.CFrame,
        [2] = "F",
        [3] = hrp.CFrame.LookVector,
        [5] = now
    }
    if ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Character") and ReplicatedStorage.Remotes.Character:FindFirstChild("Dash") then
        ReplicatedStorage.Remotes.Character.Dash:FireServer(unpack(args))
    else
        pcall(function()
            ReplicatedStorage.Remotes.Character.Dash:FireServer(unpack(args))
        end)
    end
end
local function toggleWallCombo(state)
    wallComboEnabled = state
    if wallComboConn then wallComboConn:Disconnect(); wallComboConn = nil end
    if dashConnWC then dashConnWC:Disconnect(); dashConnWC = nil end
    if wallComboEnabled then
        wallComboConn = RunService.Heartbeat:Connect(function()
            executeWallCombo()
        end)
        dashConnWC = RunService.Heartbeat:Connect(function()
            fireDashWC()
        end)
    end
end
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == wallComboKey then
        executeWallCombo()
    end
end)
ViolentRight1:AddToggle("WallComboKill", {Text = "墙打秒杀", Default = false}):OnChanged(function(state)
    if state then AddToArrayList("墙打秒杀") else RemoveFromArrayList("墙打秒杀") end
    toggleWallCombo(state)
end)
ViolentRight1:AddToggle("WallComboIgnoreFriends", {Text = "墙打秒杀忽略好友", Default = false}):OnChanged(function(state)
    ignoreFriendsWC = state
end)

pcall(function()
    setthreadidentity(8)
end)
local HitboxS = {
    Players = Players,
    RunService = RunService,
    ReplicatedStorage = ReplicatedStorage,
    Cfg = {
        Hitbox = false,
        X = 150,
        Y = 150,
        Z = 150,
        Enhancer = false,
        Multi = 3
    },
    Cache = {},
    Conn = nil,
    DashT = 0
}
local LP = HitboxS.Players.LocalPlayer
getgenv().HitboxEnabled = false
function HitboxS:HRP()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
function HitboxS:GetCore()
    if self.Cache.Core then
        return self.Cache.Core
    end
    local ok, core = pcall(function()
        return require(self.ReplicatedStorage:WaitForChild("Core", 10))
    end)
    if ok then
        self.Cache.Core = core
        return core
    end
end
function HitboxS:ToggleHitbox(state)
    self.Cfg.Hitbox = state
    getgenv().HitboxEnabled = state
    local core = self:GetCore()
    if not core or not core.Get then return end
    local hit = core.Get("Combat", "Hit")
    if not hit or not hit.Box then return end
    if state then
        if not self.Cache.OrigBox then
            self.Cache.OrigBox = hit.Box
        end
        hit.Box = function(_, char, data)
            data = data or {}
            data.Size = Vector3.new(self.Cfg.X, self.Cfg.Y, self.Cfg.Z)
            return self.Cache.OrigBox(nil, char, data)
        end
    else
        if self.Cache.OrigBox then
            hit.Box = self.Cache.OrigBox
        end
    end
end
function HitboxS:Dash()
    if tick() - self.DashT < 0.18 then return end
    self.DashT = tick()
    local hrp = self:HRP()
    if not hrp then return end
    pcall(function()
        self:GetCore().Library("Remote").Send("Dash", hrp.CFrame, "L", 1)
    end)
end
function HitboxS:EnableEnhancer()
    if self.Cache.HitProc then return end
    local ok, hit = pcall(function()
        return require(LP.PlayerScripts:WaitForChild("Combat"):WaitForChild("Hit"))
    end)
    if not ok or not hit.Process then return end
    self.Cache.HitProc = hit.Process
    hit.Process = function(...)
        local best, targets, blocked = self.Cache.HitProc(...)
        if not targets or #targets == 0 then
            return best, targets, blocked
        end
        self:Dash()
        local r = self.ReplicatedStorage.Remotes.Combat.Action
        for _ = 1, self.Cfg.Multi do
            pcall(function()
                r:FireServer(nil, "", 4, 69, {BestHitCharacter=nil, HitCharacters=targets, Ignore={}, Actions={}})
            end)
        end
        return best, targets, blocked
    end
end
function HitboxS:DisableEnhancer()
    if not self.Cache.HitProc then return end
    local ok, hit = pcall(function()
        return require(LP.PlayerScripts.Combat.Hit)
    end)
    if ok then
        hit.Process = self.Cache.HitProc
    end
    self.Cache.HitProc = nil
end
function HitboxS:StartDashLoop()
    if self.Conn then return end
    self.Conn = self.RunService.Heartbeat:Connect(function()
        self:Dash()
    end)
end
function HitboxS:StopDashLoop()
    if self.Conn then
        self.Conn:Disconnect()
        self.Conn = nil
    end
end
HitboxLeft:AddToggle("HitboxExpand", {Text = "碰撞箱扩大", Default = false}):OnChanged(function(v)
    if v then
        HitboxS:ToggleHitbox(true)
        HitboxS:EnableEnhancer()
        HitboxS:StartDashLoop()
    else
        HitboxS:ToggleHitbox(false)
        HitboxS:DisableEnhancer()
        HitboxS:StopDashLoop()
    end
end)
HitboxLeft:AddInput("HitboxX", {Text = "碰撞箱X轴", Default = tostring(HitboxS.Cfg.X), Numeric = true}):OnChanged(function(v)
    v = tonumber(v)
    if v then
        HitboxS.Cfg.X = math.clamp(v, 10, 150)
    end
end)
HitboxLeft:AddInput("HitboxY", {Text = "碰撞箱Y轴", Default = tostring(HitboxS.Cfg.Y), Numeric = true}):OnChanged(function(v)
    v = tonumber(v)
    if v then
        HitboxS.Cfg.Y = math.clamp(v, 10, 150)
    end
end)
HitboxLeft:AddInput("HitboxZ", {Text = "碰撞箱Z轴", Default = tostring(HitboxS.Cfg.Z), Numeric = true}):OnChanged(function(v)
    v = tonumber(v)
    if v then
        HitboxS.Cfg.Z = math.clamp(v, 10, 150)
    end
end)

local LockS = {}
LockS.Players = Players
LockS.RunService = RunService
LockS.LocalPlayer = player
LockS.v3new = Vector3.new
LockS.cfnew = CFrame.new
LockS.mathcos = math.cos
LockS.mathsin = math.sin
LockS.tableinsert = table.insert
LockS.pairs = pairs
LockS.BEHIND_DISTANCE = 5
LockS.CIRCLE_RADIUS = 6
LockS.CIRCLE_SPEED = 13
LockS.followEnabled = false
LockS.circleEnabled = false
LockS.lookEnabled = false
LockS.selectedTargetName = nil
LockS.circleAngle = 0
LockS.mainConnection = nil
LockS.playerDropdown = nil
function LockS.getRoot(targetPlayer)
    if targetPlayer and targetPlayer.Character then
        return targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    end
end
function LockS.getPlayerByName(name)
    for _, p in LockS.pairs(LockS.Players:GetPlayers()) do
        if p.Name == name then
            return p
        end
    end
end
function LockS.getPlayerNames()
    local names = {}
    for _, p in LockS.pairs(LockS.Players:GetPlayers()) do
        if p ~= LockS.LocalPlayer then
            LockS.tableinsert(names, p.Name)
        end
    end
    return names
end
function LockS.updateLoop(dt)
    if not LockS.selectedTargetName then return end
    local target = LockS.getPlayerByName(LockS.selectedTargetName)
    local targetRoot = LockS.getRoot(target)
    local myRoot = LockS.getRoot(LockS.LocalPlayer)
    if not targetRoot or not myRoot then return end
    local targetPos = targetRoot.Position
    local finalPos = nil
    if LockS.circleEnabled then
        LockS.circleAngle = LockS.circleAngle + (LockS.CIRCLE_SPEED * dt)
        local x = LockS.mathcos(LockS.circleAngle) * LockS.CIRCLE_RADIUS
        local z = LockS.mathsin(LockS.circleAngle) * LockS.CIRCLE_RADIUS
        finalPos = targetPos + LockS.v3new(x, 0, z)
    elseif LockS.followEnabled then
        local offset = targetRoot.CFrame.LookVector * LockS.BEHIND_DISTANCE
        finalPos = targetPos - offset
    end
    if finalPos then
        if LockS.lookEnabled then
            myRoot.CFrame = LockS.cfnew(finalPos, LockS.v3new(targetPos.X, finalPos.Y, targetPos.Z))
        else
            myRoot.CFrame = LockS.cfnew(finalPos) * myRoot.CFrame.Rotation
        end
    elseif LockS.lookEnabled then
        local myPos = myRoot.Position
        myRoot.CFrame = LockS.cfnew(myPos, LockS.v3new(targetPos.X, myPos.Y, targetPos.Z))
    end
end
function LockS.toggleConnection()
    if LockS.followEnabled or LockS.circleEnabled or LockS.lookEnabled then
        if not LockS.mainConnection then
            LockS.mainConnection = LockS.RunService.RenderStepped:Connect(LockS.updateLoop)
        end
    else
        if LockS.mainConnection then
            LockS.mainConnection:Disconnect()
            LockS.mainConnection = nil
        end
    end
end
LockS.playerDropdown = LockRight:AddDropdown("LockTarget", {Text = "选择目标玩家", Values = LockS.getPlayerNames(), Multi = false, Default = nil}):OnChanged(function(name)
    LockS.selectedTargetName = name
end)
LockRight:AddButton("刷新玩家列表", function()
    LockS.selectedTargetName = nil
    local newNames = LockS.getPlayerNames()
    if LockS.playerDropdown then
        pcall(function()
            LockS.playerDropdown:SetValues(newNames)
        end)
    end
end)
LockLeft:AddToggle("LockBack", {Text = "锁背", Default = false}):OnChanged(function(state)
    LockS.followEnabled = state
    if state then LockS.circleEnabled = false end
    LockS.toggleConnection()
end)
LockLeft:AddToggle("LockCircle", {Text = "转圈", Default = false}):OnChanged(function(state)
    LockS.circleEnabled = state
    if state then LockS.followEnabled = false end
    LockS.toggleConnection()
end)
LockLeft:AddToggle("LockLook", {Text = "看着玩家(需要关移位锁)", Default = false}):OnChanged(function(state)
    LockS.lookEnabled = state
    LockS.toggleConnection()
end)

local EmoteT = {}
EmoteT.env = {
    ReplicatedStorage = ReplicatedStorage,
    Players = Players,
}
EmoteT.env.LocalPlayer = player
EmoteT.env.core = require(EmoteT.env.ReplicatedStorage:WaitForChild("Core"))
EmoteT.env.Character = player.Character or player.CharacterAdded:Wait()
EmoteT.env.HumanoidRootPart = EmoteT.env.Character:WaitForChild("HumanoidRootPart")
EmoteT.state = {
    killEmotes = {},
    aura = false,
    spam = false,
    auraDelay = 0.5,
    spamDelay = 0.5,
    selectedEmote = "",
    keybind = Enum.KeyCode.G,
    dropdown = nil,
    tmp = {}
}
EmoteT.services = {
    UserInputService = UserInputService
}
function EmoteT.getRoot(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end
function EmoteT.useEmote(name)
    local tmp = EmoteT.state.tmp
    tmp.emote = EmoteT.env.ReplicatedStorage:WaitForChild("Cosmetics"):WaitForChild("KillEmote"):FindFirstChild(name)
    tmp.myRoot = EmoteT.getRoot(EmoteT.env.LocalPlayer.Character)
    if not tmp.emote or not tmp.myRoot then return end
    tmp.closest = nil
    tmp.dist = math.huge
    for _, p in pairs(EmoteT.env.Players:GetPlayers()) do
        if p ~= EmoteT.env.LocalPlayer and p.Character then
            tmp.r = EmoteT.getRoot(p.Character)
            if tmp.r then
                tmp.d = (tmp.myRoot.Position - tmp.r.Position).Magnitude
                if tmp.d < tmp.dist then
                    tmp.dist = tmp.d
                    tmp.closest = p.Character
                end
            end
        end
    end
    if tmp.closest then
        task.spawn(function()
            _G.KillEmote = true
            pcall(function()
                EmoteT.env.core.Get("Combat", "Ability").Activate(tmp.emote, tmp.closest)
            end)
            _G.KillEmote = false
        end)
    end
end
function EmoteT.useRandom()
    local list = EmoteT.state.killEmotes
    if #list > 0 then
        EmoteT.useEmote(list[math.random(#list)])
    end
end
task.spawn(function()
    while true do
        if EmoteT.state.aura then
            EmoteT.useRandom()
            task.wait(EmoteT.state.auraDelay)
        else
            task.wait(0.1)
        end
    end
end)
task.spawn(function()
    while true do
        if EmoteT.state.spam and EmoteT.state.selectedEmote ~= "" then
            EmoteT.useEmote(EmoteT.state.selectedEmote)
            task.wait(EmoteT.state.spamDelay)
        else
            task.wait(0.1)
        end
    end
end)
EmoteT.services.UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == EmoteT.state.keybind and EmoteT.state.selectedEmote ~= "" then
        EmoteT.useEmote(EmoteT.state.selectedEmote)
    end
end)
function EmoteT.updateDropdown(list)
    local values = (#list > 0 and list) or { "No emotes found" }
    if EmoteT.state.dropdown then
        pcall(function()
            EmoteT.state.dropdown:SetValues(values)
        end)
    else
        EmoteT.state.dropdown = EmoteLeft:AddDropdown("KillEmoteSelect", {Text = "击杀表情功能(要靠近别人)", Values = values, Multi = false, Default = nil}):OnChanged(function(v)
            if v ~= "No emotes found" then
                EmoteT.state.selectedEmote = v
                EmoteT.useEmote(v)
            end
        end)
    end
end
EmoteLeft:AddButton("刷新击杀表情", function()
    table.clear(EmoteT.state.killEmotes)
    for _, e in pairs(EmoteT.env.ReplicatedStorage:WaitForChild("Cosmetics"):WaitForChild("KillEmote"):GetChildren()) do
        EmoteT.state.killEmotes[#EmoteT.state.killEmotes + 1] = e.Name
    end
    EmoteT.updateDropdown(EmoteT.state.killEmotes)
end)
for _, e in pairs(EmoteT.env.ReplicatedStorage:WaitForChild("Cosmetics"):WaitForChild("KillEmote"):GetChildren()) do
    EmoteT.state.killEmotes[#EmoteT.state.killEmotes + 1] = e.Name
end
EmoteT.updateDropdown(EmoteT.state.killEmotes)
EmoteRight:AddToggle("KillEmoteAura", {Text = "击杀表情光环", Default = false}):OnChanged(function(v)
    EmoteT.state.aura = v
end)
EmoteRight:AddSlider("AuraDelay", {Text = "击杀表情光环间隔", Min = 0.01, Max = 5, Default = 0.5, Rounding = 2}):OnChanged(function(v)
    EmoteT.state.auraDelay = v
end)
EmoteRight:AddToggle("KillEmoteSpam", {Text = "持续发送你选择的表情", Default = false}):OnChanged(function(v)
    EmoteT.state.spam = v
end)
EmoteRight:AddSlider("SpamDelay", {Text = "调整你选择的表情速度", Min = 0.01, Max = 5, Default = 0.5, Rounding = 2}):OnChanged(function(v)
    EmoteT.state.spamDelay = v
end)
EmoteT.keyMap = {
    G = Enum.KeyCode.G, F = Enum.KeyCode.F, H = Enum.KeyCode.H, J = Enum.KeyCode.J,
    K = Enum.KeyCode.K, L = Enum.KeyCode.L, Z = Enum.KeyCode.Z, X = Enum.KeyCode.X,
    C = Enum.KeyCode.C, V = Enum.KeyCode.V, B = Enum.KeyCode.B, N = Enum.KeyCode.N,
    M = Enum.KeyCode.M, Q = Enum.KeyCode.Q, E = Enum.KeyCode.E, R = Enum.KeyCode.R,
    T = Enum.KeyCode.T, Y = Enum.KeyCode.Y, U = Enum.KeyCode.U, I = Enum.KeyCode.I,
    O = Enum.KeyCode.O, P = Enum.KeyCode.P,
}
local keyList = {}
for k in pairs(EmoteT.keyMap) do
    keyList[#keyList + 1] = k
end
table.sort(keyList)
EmoteRight:AddDropdown("KillEmoteKey", {Text = "快捷键设置", Values = keyList, Default = "G"}):OnChanged(function(v)
    EmoteT.state.keybind = EmoteT.keyMap[v]
end)
EmoteRight:AddButton("随机用一个击杀表情", function()
    EmoteT.useRandom()
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
