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
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Window = Library:CreateWindow({
    Title = "闪光",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify({
    Title = "闪光",
    Description = "创作者：Aiove\nQQ：3999698324\n脚本已加载成功",
    Time = 5,
})

local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Main = Window:AddTab("主要", "home"),
    Aim = Window:AddTab("自瞄", "crosshair"),
    Visual = Window:AddTab("透视", "eye"),
    Combat = Window:AddTab("战斗", "sword"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeLeft = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeLeft:AddLabel("Aiove将持续更新此脚本")
NoticeLeft:AddLabel("创作者：Aiove")
NoticeLeft:AddLabel("QQ：3999698324")

local espEnabled = false
local espBillboards = {}
local espConnections = {}

local function cleanupESP(plr)
    if espConnections[plr] then
        for _, conn in ipairs(espConnections[plr]) do
            pcall(function() conn:Disconnect() end)
        end
        espConnections[plr] = nil
    end
    local char = plr.Character
    if char then
        pcall(function()
            local hl = char:FindFirstChild("EspHighlight")
            if hl then hl:Destroy() end
        end)
        pcall(function()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bb = hrp:FindFirstChild("EspBillboard")
                if bb then bb:Destroy() end
            end
        end)
    end
    espBillboards[plr] = nil
end

local function createESP(plr)
    if plr == player then return end
    local char = plr.Character
    if not char then return end
    pcall(function()
        local hl = char:FindFirstChild("EspHighlight")
        if hl then hl:Destroy() end
    end)
    pcall(function()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bb = hrp:FindFirstChild("EspBillboard")
            if bb then bb:Destroy() end
        end
    end)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        task.spawn(function()
            local success = pcall(function() char:WaitForChild("HumanoidRootPart", 5) end)
            if success and espEnabled and plr.Parent then
                createESP(plr)
            end
        end)
        return
    end
    local highlight = Instance.new("Highlight")
    highlight.Name = "EspHighlight"
    highlight.Parent = char
    highlight.FillTransparency = 0.5
    highlight.FillColor = Color3.fromRGB(255, 255, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
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
    nameLabel.Text = plr.Name
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
    espBillboards[plr] = billboard
end

local function setupPlayerESP(plr)
    if plr == player then return end
    if espConnections[plr] then
        for _, conn in ipairs(espConnections[plr]) do
            pcall(function() conn:Disconnect() end)
        end
    end
    espConnections[plr] = {}
    table.insert(espConnections[plr], plr.CharacterAdded:Connect(function(char)
        task.spawn(function()
            pcall(function() char:WaitForChild("HumanoidRootPart", 5) end)
            if espEnabled then
                task.wait(0.1)
                createESP(plr)
            end
        end)
    end))
    table.insert(espConnections[plr], plr.CharacterRemoving:Connect(function()
        cleanupESP(plr)
    end))
    if plr.Character and espEnabled then
        createESP(plr)
    end
end

for _, plr in ipairs(Players:GetPlayers()) do
    setupPlayerESP(plr)
end

Players.PlayerAdded:Connect(function(plr)
    setupPlayerESP(plr)
end)

Players.PlayerRemoving:Connect(function(plr)
    cleanupESP(plr)
end)

RunService.RenderStepped:Connect(function()
    if not espEnabled then return end
    local myChar = player.Character
    local myPos = myChar and myChar:FindFirstChild("HumanoidRootPart") and myChar.HumanoidRootPart.Position
    for plr, billboard in pairs(espBillboards) do
        if plr.Parent and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and billboard and billboard.Parent then
            local distLabel = billboard:FindFirstChild("DistLabel")
            if distLabel and myPos then
                local dist = (plr.Character.HumanoidRootPart.Position - myPos).Magnitude
                distLabel.Text = string.format("%.0fm", dist)
            end
        else
            espBillboards[plr] = nil
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if not espEnabled then continue end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                local char = plr.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hasHighlight = char:FindFirstChild("EspHighlight")
                local hasBillboard = hrp and hrp:FindFirstChild("EspBillboard")
                if not hasHighlight or not hasBillboard then
                    pcall(function() createESP(plr) end)
                end
            end
        end
    end
end)

local InfiniteJumpEnabled = false
local JumpConnection = nil
local originalGravity = Workspace.Gravity
local SpeedValue = 16
local SpeedEnabled = false
local SpeedConnection = nil
local NightVisionEnabled = false
local originalBrightness = 1
local originalAmbient = Color3.new(0, 0, 0)

local function setupInfiniteJump()
    if JumpConnection then
        JumpConnection:Disconnect()
        JumpConnection = nil
    end
    if InfiniteJumpEnabled then
        JumpConnection = UserInputService.JumpRequest:Connect(function()
            pcall(function()
                local char = player.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid:ChangeState("Jumping")
                end
            end)
        end)
    end
end

local function setupSpeed()
    if SpeedConnection then
        SpeedConnection:Disconnect()
        SpeedConnection = nil
    end
    if SpeedEnabled then
        SpeedConnection = RunService.Heartbeat:Connect(function()
            pcall(function()
                local char = player.Character
                if char and char:FindFirstChild("Humanoid") then
                    local humanoid = char.Humanoid
                    if humanoid.MoveDirection.Magnitude > 0 then
                        char:TranslateBy(humanoid.MoveDirection * SpeedValue / 2)
                    end
                end
            end)
        end)
    end
end

local MainLeft = Tabs.Main:AddLeftGroupbox("移动功能")

MainLeft:AddToggle("InfiniteJump", { Text = "无限跳跃", Default = false, Callback = function(Value)
    InfiniteJumpEnabled = Value
    setupInfiniteJump()
    Library:Notify({ Title = "无限跳跃", Description = Value and "已开启" or "已关闭", Time = 3 })
end })

MainLeft:AddSlider("GravitySlider", { Text = "重力设置", Default = 196, Min = 0, Max = 500, Rounding = 0, Callback = function(Value)
    Workspace.Gravity = Value
    Library:Notify({ Title = "重力设置", Description = "重力已设置为: " .. tostring(Value), Time = 3 })
end })

MainLeft:AddSlider("SpeedSlider", { Text = "快速跑步速度", Default = 16, Min = 1, Max = 500, Rounding = 0, Callback = function(Value)
    SpeedValue = Value
    Library:Notify({ Title = "速度设置", Description = "速度已设置为: " .. tostring(Value), Time = 3 })
end })

MainLeft:AddToggle("SpeedRun", { Text = "开启快速跑步", Default = false, Callback = function(Value)
    SpeedEnabled = Value
    setupSpeed()
    Library:Notify({ Title = "快速跑步", Description = Value and "已开启" or "已关闭", Time = 3 })
end })

local MainRight = Tabs.Main:AddRightGroupbox("视觉功能")

MainRight:AddToggle("NightVision", { Text = "夜视", Default = false, Callback = function(Value)
    NightVisionEnabled = Value
    if Value then
        originalBrightness = Lighting.Brightness
        originalAmbient = Lighting.Ambient
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        Library:Notify({ Title = "夜视", Description = "夜视已开启", Time = 3 })
    else
        Lighting.Brightness = originalBrightness
        Lighting.Ambient = originalAmbient
        Lighting.OutdoorAmbient = Color3.fromRGB(0.5, 0.5, 0.5)
        Library:Notify({ Title = "夜视", Description = "夜视已关闭", Time = 3 })
    end
end })

local BackstabCheckEnabled = false
local BackstabCooldown = 0
local BACKSTAB_COOLDOWN_TIME = 3
local DeathCheckEnabled = false

local function CheckBackstabThreat()
    if not BackstabCheckEnabled then return end
    if BackstabCooldown > 0 then return end
    pcall(function()
        local myCharacter = player.Character
        local myHRP = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        local myPosition = myHRP.Position
        local myCFrame = myHRP.CFrame
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = plr.Character:FindFirstChild("Humanoid")
                if hrp and humanoid and humanoid.Health > 0 then
                    local enemyPosition = hrp.Position
                    local distance = (myPosition - enemyPosition).Magnitude
                    if distance < 30 then
                        local toEnemy = (enemyPosition - myPosition).Unit
                        local myForward = myCFrame.LookVector
                        local dotProduct = toEnemy:Dot(myForward)
                        if dotProduct < 0.5 then
                            Library:Notify({ Title = "有人偷袭", Description = "小心有人要偷袭你：" .. plr.Name, Time = 5 })
                            BackstabCooldown = BACKSTAB_COOLDOWN_TIME
                            break
                        end
                    end
                end
            end
        end
    end)
end

local function SetupDeathDetection()
    player.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        pcall(function()
            local humanoid = character:WaitForChild("Humanoid")
            humanoid.Died:Connect(function()
                if DeathCheckEnabled then
                    Library:Notify({ Title = "死亡提醒", Description = "受着", Time = 8 })
                end
            end)
        end)
    end)
    if player.Character then
        pcall(function()
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.Died:Connect(function()
                    if DeathCheckEnabled then
                        Library:Notify({ Title = "死亡提醒", Description = "受着", Time = 8 })
                    end
                end)
            end
        end)
    end
end

RunService.Heartbeat:Connect(function(deltaTime)
    if BackstabCooldown > 0 then
        BackstabCooldown = BackstabCooldown - deltaTime
    end
    CheckBackstabThreat()
end)

local originalFire = nil
local autoLobbyEnabled = false
local autoLobbyThread = nil
local ragebotConnection = nil
local currentTarget = nil
local lastShotTime = 0

local function getVisiblePart(targetCharacter)
    if not targetCharacter or not player.Character then return nil end
    local localCharacter = player.Character
    local humanoidRootPart = localCharacter:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return nil end
    local partNames = {"Head","UpperTorso","Torso","LowerTorso","HumanoidRootPart"}
    local bestPart = nil
    local bestPosition = nil
    local bestOrigin = nil
    local minDistance = math.huge
    for _, partName in ipairs(partNames) do
        local part = targetCharacter:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            local targetPosition = part.Position
            for height = 0, 10.5, 2 do
                local startPos = humanoidRootPart.Position + Vector3.new(0, height, 0)
                local direction = (targetPosition - startPos).Unit
                local forwardPos = startPos + direction * 2.5
                local rayParams = RaycastParams.new()
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                rayParams.FilterDescendantsInstances = {localCharacter, Camera}
                rayParams.IgnoreWater = true
                local ray = Workspace:Raycast(forwardPos, targetPosition - forwardPos, rayParams)
                if not ray or ray.Instance:IsDescendantOf(targetCharacter) or ray.Instance.Transparency >= 0.9 then
                    local distance = (targetPosition - forwardPos).Magnitude
                    if distance < minDistance then
                        minDistance = distance
                        bestPart = part
                        bestPosition = targetPosition
                        bestOrigin = forwardPos
                    end
                end
            end
        end
    end
    return bestPart, bestPosition, bestOrigin
end

local function isDead(plr)
    if not plr or not plr.Character then return true end
    local humanoid = plr.Character:FindFirstChild("Humanoid")
    return not humanoid or humanoid.Health <= 0
end

local function playShootSound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://6534948092"
    sound.Volume = 1
    sound.Parent = Camera
    sound.PlayOnRemove = true
    sound:Destroy()
end

local function createBeam(startPos, endPos)
    local part1 = Instance.new("Part")
    part1.Anchored = true
    part1.CanCollide = false
    part1.Transparency = 1
    part1.Size = Vector3.new(0.1, 0.1, 0.1)
    part1.Position = startPos
    part1.Parent = Workspace
    local part2 = Instance.new("Part")
    part2.Anchored = true
    part2.CanCollide = false
    part2.Transparency = 1
    part2.Size = Vector3.new(0.1, 0.1, 0.1)
    part2.Position = endPos
    part2.Parent = Workspace
    local attachment1 = Instance.new("Attachment")
    attachment1.Parent = part1
    local attachment2 = Instance.new("Attachment")
    attachment2.Parent = part2
    local beam1 = Instance.new("Beam")
    beam1.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
    beam1.Transparency = NumberSequence.new(0)
    beam1.Width0 = 0.25
    beam1.Width1 = 0.25
    beam1.Texture = "rbxassetid://7136858729"
    beam1.TextureSpeed = 0.8
    beam1.TextureMode = Enum.TextureMode.Wrap
    beam1.Brightness = 1
    beam1.LightEmission = 0
    beam1.FaceCamera = true
    beam1.Attachment0 = attachment1
    beam1.Attachment1 = attachment2
    beam1.Parent = part1
    local beam2 = Instance.new("Beam")
    beam2.Color = ColorSequence.new(Color3.fromRGB(180, 200, 255))
    beam2.Transparency = NumberSequence.new(0.4)
    beam2.Width0 = 0.12
    beam2.Width1 = 0.12
    beam2.Texture = "rbxassetid://7136858729"
    beam2.TextureSpeed = 1.2
    beam2.TextureMode = Enum.TextureMode.Wrap
    beam2.Brightness = 1.2
    beam2.LightEmission = 0.6
    beam2.FaceCamera = true
    beam2.Attachment0 = attachment1
    beam2.Attachment1 = attachment2
    beam2.Parent = part1
    local shaking = true
    task.spawn(function()
        while shaking and part1 and part1.Parent do
            attachment1.Position = Vector3.new(math.random(-3, 3) / 100, math.random(-3, 3) / 100, math.random(-3, 3) / 100)
            attachment2.Position = Vector3.new(math.random(-3, 3) / 100, math.random(-3, 3) / 100, math.random(-3, 3) / 100)
            task.wait(0.02)
        end
    end)
    task.delay(math.random(10, 40) / 10, function()
        shaking = false
        for i = 0, 1, 0.05 do
            if not part1 or not part1.Parent then break end
            beam1.Transparency = NumberSequence.new(i)
            beam2.Transparency = NumberSequence.new(0.4 + i * 0.6)
            task.wait(0.03)
        end
        pcall(function() part1:Destroy() end)
        pcall(function() part2:Destroy() end)
    end)
end

local function shoot(plr, targetPart, targetPos, origin)
    local currentTime = tick()
    if currentTime - lastShotTime < 0.56 then return false end
    local character = player.Character
    if not character or not targetPart or not origin then return false end
    local direction = (targetPos - origin).Unit
    local time = tick()
    local cframe = CFrame.lookAt(origin, targetPos)
    local clientRemotes = player:FindFirstChild("ClientRemotes")
    if clientRemotes then
        pcall(function() clientRemotes.CheckFire:FireServer(time, origin) end)
        pcall(function() clientRemotes.CheckShot:FireServer(0, 0, 1, 0.8, cframe, targetPos, targetPart, 11, time) end)
        pcall(function() clientRemotes.Reload:FireServer() end)
    end
    local gun = ReplicatedStorage:FindFirstChild("ModuleScripts")
    if gun then
        gun = gun:FindFirstChild("GunModules")
        if gun then
            gun = gun:FindFirstChild("Remote")
            if gun then
                pcall(function() gun.ProjectileRender:FireServer(time, character, origin, direction * 999999, 360, 0, Vector3.zero, 5, "Bullet") end)
                pcall(function() gun.ProjectileFinished:FireServer(time, CFrame.new(targetPos), "Gib_T", false, 15, "rbxassetid://2814354338") end)
            end
        end
    end
    createBeam(origin, targetPos)
    playShootSound()
    lastShotTime = currentTime
    return true
end

local function getVisibleTargets()
    local targets = {}
    local character = player.Character
    if not character then return targets end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return targets end
    local origin = humanoidRootPart.Position
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and not isDead(plr) and plr.Character then
            local visiblePart, visiblePos, originPos = getVisiblePart(plr.Character)
            if visiblePart and visiblePos and originPos then
                table.insert(targets, {
                    player = plr,
                    distance = (visiblePos - origin).Magnitude,
                    part = visiblePart,
                    position = visiblePos,
                    origin = originPos
                })
            end
        end
    end
    table.sort(targets, function(a, b) return a.distance < b.distance end)
    return targets
end

local AimLeft = Tabs.Aim:AddLeftGroupbox("自瞄功能")
AimLeft:AddButton("加载Aiove自瞄", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/kongbaNB/9178/refs/heads/main/自瞄"))()
    Library:Notify({ Title = "自瞄", Description = "Aiove自瞄已加载", Time = 5 })
end)

local VisualLeft = Tabs.Visual:AddLeftGroupbox("透视设置")
VisualLeft:AddToggle("PlayerESP", { Text = "玩家透视", Default = false, Callback = function(Value)
    espEnabled = Value
    if Value then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                setupPlayerESP(p)
            end
        end
        Library:Notify({ Title = "透视", Description = "玩家透视已开启", Time = 3 })
    else
        for _, p in ipairs(Players:GetPlayers()) do
            cleanupESP(p)
        end
        Library:Notify({ Title = "透视", Description = "玩家透视已关闭", Time = 3 })
    end
end })

local CombatLeft = Tabs.Combat:AddLeftGroupbox("战斗功能")

CombatLeft:AddToggle("BulletTrack", { Text = "子弹追踪", Default = false, Callback = function(state)
    local bullet_handler = require(game:GetService("ReplicatedStorage").ModuleScripts.GunModules.BulletHandler)
    if state then
        if not originalFire then
            originalFire = bullet_handler.Fire
        end
        local function get_closest_target(range)
            local local_player = Players.LocalPlayer
            local camera = Workspace.CurrentCamera
            local closest_part, closest_distance = nil, range
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= local_player then
                    local character = plr.Character
                    if character then
                        local humanoid = character:FindFirstChild("Humanoid")
                        local head = character:FindFirstChild("Head")
                        if head and humanoid and humanoid.Health > 0 then
                            local screen_position, on_screen = camera:WorldToViewportPoint(head.Position)
                            if on_screen then
                                local distance = (Vector2.new(screen_position.X, screen_position.Y) - camera.ViewportSize / 2).Magnitude
                                if distance < closest_distance then
                                    closest_part = head
                                    closest_distance = distance
                                end
                            end
                        end
                    end
                end
            end
            return closest_part
        end
        bullet_handler.Fire = function(data)
            local closest = get_closest_target(999)
            if closest then
                data.Force = data.Force * 1000
                data.Direction = (closest.Position - data.Origin).Unit
            end
            return originalFire(data)
        end
    else
        if originalFire then
            bullet_handler.Fire = originalFire
        end
    end
    Library:Notify({ Title = "子弹追踪", Description = state and "已开启" or "已关闭", Time = 3 })
end })

CombatLeft:AddToggle("AutoLobby", { Text = "自动加入对战", Default = false, Callback = function(state)
    autoLobbyEnabled = state
    if state and not autoLobbyThread then
        autoLobbyThread = coroutine.wrap(function()
            while autoLobbyEnabled do
                task.wait()
                local ok, viewModel = pcall(function()
                    return Workspace:FindFirstChild("ViewModel")
                end)
                if ok and viewModel == nil then
                    game:GetService("ReplicatedStorage").Remotes.Command:FireServer("Lobby")
                    task.wait(0.35)
                    game:GetService("ReplicatedStorage").Remotes.Command:FireServer("Play")
                    task.wait(0.35)
                end
            end
            autoLobbyThread = nil
        end)
        autoLobbyThread()
    elseif not state and autoLobbyThread then
        autoLobbyThread = nil
    end
    Library:Notify({ Title = "自动加入对战", Description = state and "已开启" or "已关闭", Time = 3 })
end })

CombatLeft:AddToggle("RageBot", { Text = "狂暴连杀", Default = false, Callback = function(state)
    if state then
        if not ragebotConnection then
            ragebotConnection = RunService.Heartbeat:Connect(function()
                pcall(function()
                    if currentTarget and not isDead(currentTarget) then
                        local targetChar = currentTarget.Character
                        if targetChar then
                            local visiblePart, visiblePos, origin = getVisiblePart(targetChar)
                            if visiblePart and visiblePos and origin then
                                shoot(currentTarget, visiblePart, visiblePos, origin)
                            else
                                currentTarget = nil
                            end
                        end
                    else
                        currentTarget = nil
                    end
                    if not currentTarget then
                        local targets = getVisibleTargets()
                        if #targets > 0 then
                            currentTarget = targets[1].player
                        end
                    end
                end)
            end)
        end
    else
        if ragebotConnection then
            ragebotConnection:Disconnect()
            ragebotConnection = nil
        end
        currentTarget = nil
        lastShotTime = 0
    end
    Library:Notify({ Title = "狂暴连杀", Description = state and "已开启" or "已关闭", Time = 3 })
end })

local CombatRight = Tabs.Combat:AddRightGroupbox("辅助提醒")

CombatRight:AddToggle("BackstabCheck", { Text = "偷袭检测", Default = false, Callback = function(Value)
    BackstabCheckEnabled = Value
    Library:Notify({ Title = "偷袭检测", Description = Value and "已开启" or "已关闭", Time = 3 })
end })

CombatRight:AddToggle("DeathCheck", { Text = "死亡提醒", Default = false, Callback = function(Value)
    DeathCheckEnabled = Value
    if Value then
        SetupDeathDetection()
    end
    Library:Notify({ Title = "死亡提醒", Description = Value and "已开启" or "已关闭", Time = 3 })
end })

local SettingsLeft = Tabs.Settings:AddLeftGroupbox("脚本管理")
SettingsLeft:AddButton("卸载脚本", function()
    Library:Unload()
end)

if ThemeManager then
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("闪光主题")
    ThemeManager:ApplyToTab(Tabs.Settings)
end

if SaveManager then
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetFolder("闪光配置")
    SaveManager:BuildConfigSection(Tabs.Settings)
end
