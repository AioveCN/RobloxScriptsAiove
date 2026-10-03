-- This file has been deobfuscated Luraph using Hurricane https://discord.com/invite/AbeurBzKXe
local function safeLoad(url)
    local success, result = pcall(function() return loadstring(game:HttpGet(url))() end)
    if not success then warn("加载失败: " .. url) return nil end
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
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local pgui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()

local Window = Library:CreateWindow({
    Title = "GB",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify({
    Title = "GB",
    Description = "创作者：Aiove\nQQ：3999698324\n脚本已加载成功",
    Time = 5,
})

local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Main = Window:AddTab("主要", "layout"),
    Combat = Window:AddTab("战斗", "swords"),
    ESP = Window:AddTab("透视", "eye"),
    Career = Window:AddTab("职业", "briefcase"),
    Anim = Window:AddTab("动画", "user"),
    Misc = Window:AddTab("杂项", "settings"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel("Aiove将持续更新此脚本")
NoticeGroup:AddLabel("创作者：Aiove")
NoticeGroup:AddLabel("QQ：3999698324")

local L = {}

L.ControlModule = require(player.PlayerScripts:WaitForChild("PlayerModule")):GetControls()

L.auraRangeHighFreq = 45
L.auraRangeWave = 45
L.auraRangeManual = 45
L.chainKillRange = 45
L.customAuraEnabled = false
L.customAttackThread = nil
L.customAttackCount = 1
L.customAttackRange = 45
L.customAttackDelay = 0.005
L.chainAuraEnabled = false
L.chainAttackThread = nil
L.autoBlackGunSmoothTime = 0.28
L.autoBlackGunCooldown = 0.1
L.autoBlackGunEquipDelay = 0.2
L.autoBlackGunBarrelDistance = 14
L.attackBarrelEnabled = false
L.ATTACK_RANGE = 45
L.ATTACK_SPEED = 2
L.ATTACK_MULTIPLIER = 1
L.DELAY_COMPENSATION = 0.005
L.auraEnabled = false
L.attackThread = nil
L.attackIndex = 1
L.killWaveEnabled = false
L.killWaveLoop = nil
L.killAnimEnabled = false
L.killAnimConnection = nil
L.headshotEnabled = false
L.originalBayonetHitCheck = nil
L.originalMeleeHitCheck = nil
L.bayonetHooked = false
L.meleeHooked = false
L.pvpBayonetActive = false
L.pvpMeleeActive = false
L.pvpHeartbeatConn = nil
L.attackedBayonetPlayers = {}
L.attackedMeleePlayers = {}
L.autoShootPlayerEnabled = false
L.autoShootPlayerThread = nil
L.autoShootRange = 200
L.zombieEspEnabled = { Axe = false, Eye = false, Sword = false, Barrel = false, FTorso = false, Normal = false }
L.ZOMBIE_ESP_RANGE = 200
L.zombieEffects = {}
L.playerHighlights = {}
L.playerNameTags = {}
L.espPlayerEnabled = false
L.espShowNames = false
L.espTeamCheckPlayer = false
L.engineerAutoRepairEnabled = false
L.autoRepairLoop = nil
L.repairCooldown = 0.1
L.engineerRecycleEnabled = false
L.engineerElbowEnabled = false
L.engineerAnimConnection = nil
L.elbowActive = false
L.elbowConnection = nil
L.lastElbowTime = 0
L.autoReloadEnabled = false
L.autoBlackGunEnabled = false
L.officerAutoJumpEnabled = false
L.autoShootBomber = false
L.autoShootCuirassier = false
L.autoShootRunner = false
L.autoShootElectrocutioner = false
L.wallCheckEnabled = true
L.maxTargetRange = 200
L.shootingLoopRunning = false
L.shootingThread = nil
L.doctorEnabled = false
L.doctorThreshold = 25
L.doctorRange = 10
L.doctorCooldown = 2
L.doctorLastRequest = {}
L.doctorThread = nil
L.chaplainEnabled = false
L.chaplainThreshold = 50
L.chaplainCooldown = 2
L.chaplainRange = 15
L.chaplainLastRequest = {}
L.chaplainThread = nil
L.bombRangeEnabled = false
L.bombRangeSpheres = {}
L.bombRangeDamageDisplay = nil
L.bombRangeConnection = nil
L.flyOffEnabled = false
L.flyOffTarget = nil
L.flyOffOriginalCFrame = nil
L.barrelCollisionRemovalActive = false
L.barrelOriginalCollisionStates = {}
L.barrelOriginalQueryStates = {}
L.barrelCollisionRemovalConn = nil
L.teleportEnabled = false
L.teleportScreenGui = nil
L.teleportButton = nil
L.teleportClickConnection = nil
L.teleportActive = false
L.speedEnabled = false
L.desiredSpeed = 25
L.speedHeartbeatConn = nil
L.speedHumPropConns = {}
L.jumpHeight = 60
L.cooldown = 0.6
L.lastJump = 0
L.jumpModEnabled = false
L.antiFallEnabled = false
L.antiFallConnection = nil
L.fallStartY = nil
L.autoFaceEnabled = false
L.autoFaceRange = 17
L.skipBarrel = false
L.autoFaceConnection = nil
L.autoJumpEnabled = false
L.autoJumpHeight = 60
L.autoJumpConn = nil
L.minorFeatures = {}
L.minorFeatures.noSlow = { active = false, walkSpeedConn = nil, charAddedConn = nil }
L.minorFeatures.noFall = { active = false, connection = nil }
L.backpackToggleConn = nil
L.originalLighting = nil
L.brightEnabled = false
L.autoDoorEnabled = false
L.processingDoors = {}
L.autoDoorThread = nil
L.autoFeatures = {}
L.isFlying_new = false
L.flySpeed_new = 40
L.isWallhack_new = false
L.flyTurner_new = nil
L.originalCollisions_new = {}
L.bv_new = nil
L.bg_new = nil
L.animCache_new = nil
L.hrp_new = nil
L.hum_new = nil
L.hitboxEnabled = false
L.hitboxSize = 10
L.hitboxAddedParts = {}
L.hitboxZombiesFolder = workspace:FindFirstChild("Zombies")
L.hitboxCameraFolder = workspace:FindFirstChild("Camera")
L.autoJumpAnimEnabled = false
L.autoJumpAnimMonitoring = false
L.autoJumpAnimHumanoid = nil
L.autoJumpAnimator = nil
L.autoJumpPlayedTracks = {}
L.fixFireConn = nil
L.customSpeed = 16
L.noSlowActive = false
L.noFallDamageActive = false
L.killAuraActive = false
L.attackDraculaEnabled = false
L.autoRotateEnabled = false
L.isAutoAttackingPlayers = false
L.autoLogEnabled = false
L.isAutoRepairing = false
L.repairOthers = false
L.repairConnection = nil
L.isAutoDigging = false
L.digConnection = nil
L.cannonHighlightEnabled = false
L.cannonHighlights = {}

local FALL_DISTANCE_THRESHOLD = 15
local ANTI_FALL_JUMP_HEIGHT = 25
local WAVE_ATTACK_INTERVAL = 0.8
local WAVE_MAX_TARGETS = 4
local BAYONET_RANGE = 17
local MELEE_RANGE_PVP = 45
local MELEE_ATTACK_MULTIPLIER_PVP = 1
local SPHERE_RADIUS = 10
local SPHERE_COLOR = Color3.fromRGB(255, 80, 80)
local SPHERE_TRANSPARENCY = 0.6
local DAMAGE_THRESHOLD = 20
local Y_OFFSET = -1.5
local STUN_RANGE = 50
local AXE_KEYWORDS = {"axe", "斧"}
local RECYCLE_ANIMATIONS = {"rbxassetid://114385794993502","rbxassetid://12638403582","rbxassetid://12638409326","rbxassetid://15345113937"}
local ELBOW_TRIGGER_ANIMATIONS = {"rbxassetid://15345113937"}
local ANIMATION_CONFIGS = {
    { AnimationId = "rbxassetid://12591932646", ActivationDelay = 0.2 },
    { AnimationId = "rbxassetid://12591945044", ActivationDelay = 0.27 },
    { AnimationId = "rbxassetid://12591944118", ActivationDelay = 0.4 },
    { AnimationId = "rbxassetid://12591941810", ActivationDelay = 0.2 },
    { AnimationId = "rbxassetid://12638403582", ActivationDelay = 0.65 },
    { AnimationId = "rbxassetid://114385794993502", ActivationDelay = 0.65 },
    { AnimationId = "rbxassetid://12638409326", ActivationDelay = 0.74 }
}
local TARGET_ANIM_IDS = {
    "rbxassetid://17406577733",
    "rbxassetid://15669224658",
    "rbxassetid://12591948314",
    "rbxassetid://12333491302",
}
local TARGETS = {}
for _, id in ipairs(TARGET_ANIM_IDS) do
    local normId = id:match("^%d+$") and ("rbxassetid://" .. id) or id
    TARGETS[normId] = true
end

local ZOMBIE_TYPES = {
    Axe    = { name = "斧头僵尸", color = Color3.fromRGB(180, 0, 250), highlightColor = Color3.fromRGB(220, 100, 255), part = "Axe" },
    Eye    = { name = "红眼",      color = Color3.fromRGB(255, 50, 50),  highlightColor = Color3.fromRGB(255, 100, 100),  part = "Eye" },
    Sword  = { name = "胸甲骑兵",  color = Color3.fromRGB(255, 0, 255),  highlightColor = Color3.fromRGB(255, 100, 255),  part = "Sword" },
    Barrel = { name = "自爆",      color = Color3.fromRGB(250, 250, 0),  highlightColor = Color3.fromRGB(255, 255, 100),  part = "Barrel" },
    FTorso = { name = "提灯人",    color = Color3.fromRGB(255, 120, 0),  highlightColor = Color3.fromRGB(255, 160, 80),   part = "FTorso" },
    Normal = { name = "山伯乐",  color = Color3.fromRGB(144, 238, 144), highlightColor = Color3.fromRGB(144, 238, 144), part = nil }
}

local ZombieTypeMatchers = {
    Bomber = function(model) return model:FindFirstChild("Barrel") ~= nil end,
    Cuirassier = function(model) return model:FindFirstChild("Sword") ~= nil end,
    Runner = function(model) return model:FindFirstChild("Eye") and not model:FindFirstChild("Axe") and model:FindFirstChild("Head") end,
    Electrocutioner = function(model) return model:FindFirstChild("Axe") and model:FindFirstChild("Head") end,
}

local DIGGABLE_PATHS = {
    "Vardohus Fortress/Modes/Objective/DoorSnow/Diggable",
    "Vardohus Fortress/Modes/Objective/Diggable",
    "OLD Vardohus Fortress/Modes/Objective/DigSnow/Diggable"
}

function L.getBodyParts(character)
    local parts = {}
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local success, rigParts = pcall(function() return humanoid:GetRigParts() end)
        if success and rigParts then
            for _, part in ipairs(rigParts) do
                if part:IsA("BasePart") then table.insert(parts, part) end
            end
        end
    end
    if #parts == 0 then
        local bodyNames = {"Head", "Torso", "UpperTorso", "LowerTorso", "HumanoidRootPart",
                           "Left Arm", "Right Arm", "Left Leg", "Right Leg",
                           "LeftUpperArm", "LeftLowerArm", "RightUpperArm", "RightLowerArm",
                           "LeftUpperLeg", "LeftLowerLeg", "RightUpperLeg", "RightLowerLeg"}
        for _, name in ipairs(bodyNames) do
            local part = character:FindFirstChild(name)
            if part and part:IsA("BasePart") then table.insert(parts, part) end
        end
    end
    return parts
end

L.SmoothTurner = {}
L.SmoothTurner.__index = L.SmoothTurner

function L.SmoothTurner.new(rootPart, camera, options)
    options = options or {}
    local self = setmetatable({}, L.SmoothTurner)
    self.RootPart = rootPart
    self.Camera = camera or workspace.CurrentCamera
    self.Enabled = false
    self.BodyGyro = nil
    self.P = options.P or 10000
    self.D = options.D or 50
    self.MaxTorque = options.MaxTorque or Vector3.new(math.huge, math.huge, math.huge)
    return self
end

function L.SmoothTurner:Start()
    if self.Enabled then return end
    if not self.RootPart or not self.RootPart.Parent then return end
    local gyro = Instance.new("BodyGyro")
    gyro.MaxTorque = self.MaxTorque
    gyro.P = self.P
    gyro.D = self.D
    gyro.CFrame = self.RootPart.CFrame
    gyro.Parent = self.RootPart
    self.BodyGyro = gyro
    self.Enabled = true
    self:_startHeartbeat()
end

function L.SmoothTurner:Stop()
    if self.BodyGyro then self.BodyGyro:Destroy() self.BodyGyro = nil end
    self.Enabled = false
    if self.HeartbeatConn then self.HeartbeatConn:Disconnect() self.HeartbeatConn = nil end
end

function L.SmoothTurner:SetDirection(direction)
    if not self.Enabled or not self.BodyGyro or not self.RootPart then return end
    local newCFrame = CFrame.lookAt(self.RootPart.Position, self.RootPart.Position + direction.Unit)
    self.BodyGyro.CFrame = newCFrame
end

function L.SmoothTurner:_startHeartbeat()
    if self.HeartbeatConn then self.HeartbeatConn:Disconnect() end
    self.HeartbeatConn = RunService.Heartbeat:Connect(function()
        if not self.Enabled or not self.BodyGyro or not self.RootPart or not self.Camera then return end
        local look = self.Camera.CFrame.LookVector
        self:SetDirection(look)
    end)
end

function L.SmoothTurner:Destroy()
    self:Stop()
    self.RootPart = nil
    self.Camera = nil
end

function L.clearFlyRes_new()
    local char = player.Character
    if char then
        local bodyParts = L.getBodyParts(char)
        for part, originalState in pairs(L.originalCollisions_new) do
            if part and part.Parent then
                for _, bp in ipairs(bodyParts) do
                    if bp == part then part.CanCollide = originalState break end
                end
            end
        end
        L.originalCollisions_new = {}
    end
    if L.animCache_new and player.Character then L.animCache_new.Parent = player.Character end
    if L.bv_new then L.bv_new:Destroy() end
    if L.bg_new then L.bg_new:Destroy() end
    L.bv_new, L.bg_new = nil, nil
    if L.flyTurner_new then L.flyTurner_new:Destroy() L.flyTurner_new = nil end
    if L.hum_new and L.hum_new.Parent then L.hum_new:ChangeState(Enum.HumanoidStateType.Running) end
end

function L.ensurePhysics_new(hrp, useGyro)
    if hrp:FindFirstChild("LeipzigBV_new") then hrp.LeipzigBV_new:Destroy() end
    if hrp:FindFirstChild("LeipzigBG_new") then hrp.LeipzigBG_new:Destroy() end
    L.bv_new = Instance.new("BodyVelocity", hrp)
    L.bv_new.Name = "LeipzigBV_new"
    L.bv_new.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    if useGyro then
        if L.flyTurner_new then L.flyTurner_new:Destroy() end
        L.flyTurner_new = L.SmoothTurner.new(hrp, workspace.CurrentCamera)
        L.flyTurner_new:Start()
    end
end

function L.applyWallhackState_new()
    local char = player.Character
    if not char then return end
    if L.isWallhack_new then
        local bodyParts = L.getBodyParts(char)
        L.originalCollisions_new = {}
        for _, part in ipairs(bodyParts) do
            L.originalCollisions_new[part] = part.CanCollide
            part.CanCollide = false
        end
    else
        for part, originalState in pairs(L.originalCollisions_new) do
            if part and part.Parent then part.CanCollide = originalState end
        end
        L.originalCollisions_new = {}
    end
end

function L.startFlyNormal_new()
    local char = player.Character
    if not char then return end
    L.hrp_new = char:WaitForChild("HumanoidRootPart")
    L.hum_new = char:WaitForChild("Humanoid")
    local ani = char:FindFirstChild("Animate")
    if ani then L.animCache_new = ani ani.Parent = nil end
    L.ensurePhysics_new(L.hrp_new, true)
    task.spawn(function()
        while L.isFlying_new and char.Parent do
            local mv = L.ControlModule:GetMoveVector()
            local cf = camera.CFrame
            local dir = (cf.LookVector * -mv.Z) + (cf.RightVector * mv.X)
            if mv.Magnitude > 0 then L.bv_new.Velocity = dir.Unit * L.flySpeed_new
            else L.bv_new.Velocity = Vector3.new(0,0.01,0) end
            L.hum_new:ChangeState(Enum.HumanoidStateType.Climbing)
            RunService.RenderStepped:Wait()
        end
        L.clearFlyRes_new()
    end)
end

function L.startFlyWallhack_new()
    local char = player.Character
    if not char then return end
    L.hrp_new = char:WaitForChild("HumanoidRootPart")
    L.hum_new = char:WaitForChild("Humanoid")
    local ani = char:FindFirstChild("Animate")
    if ani then L.animCache_new = ani ani.Parent = nil end
    L.applyWallhackState_new()
    L.ensurePhysics_new(L.hrp_new, true)
    task.spawn(function()
        local lastPos = L.hrp_new.Position
        local lastTime = tick()
        while L.isFlying_new and char.Parent do
            local dt = tick() - lastTime
            lastTime = tick()
            local mv = L.ControlModule:GetMoveVector()
            local cf = camera.CFrame
            local dir = (cf.LookVector * -mv.Z) + (cf.RightVector * mv.X)
            local targetVelocity
            if mv.Magnitude > 0 then targetVelocity = dir.Unit * L.flySpeed_new L.bv_new.Velocity = targetVelocity
            else L.bv_new.Velocity = Vector3.new(0,0.01,0) targetVelocity = Vector3.new(0,0.01,0) end
            L.hum_new:ChangeState(Enum.HumanoidStateType.Climbing)
            RunService.RenderStepped:Wait()
            local expectedPos = lastPos + targetVelocity * dt
            local actualPos = L.hrp_new.Position
            local deviation = actualPos - expectedPos
            if deviation.Magnitude > 0.00001 then
                L.hrp_new.CFrame = CFrame.new(expectedPos) * L.hrp_new.CFrame.Rotation
                L.bv_new.Velocity = targetVelocity
                lastPos = expectedPos
            else lastPos = actualPos end
        end
        L.clearFlyRes_new()
    end)
end

function L.startFly_new()
    if L.isFlying_new then return end
    L.isFlying_new = true
    if L.isWallhack_new then L.startFlyWallhack_new() else L.startFlyNormal_new() end
end

function L.stopFly_new()
    if not L.isFlying_new then return end
    L.isFlying_new = false
    L.clearFlyRes_new()
end

function L.bindCharacter_new()
    local char = player.Character or player.CharacterAdded:Wait()
    L.hrp_new = char:WaitForChild("HumanoidRootPart")
    L.hum_new = char:WaitForChild("Humanoid")
    L.clearFlyRes_new()
    char.AncestryChanged:Connect(function(_, parent)
        if not parent then L.clearFlyRes_new() L.bindCharacter_new() end
    end)
end
L.bindCharacter_new()

local function safeSetWalk(hum, sp)
    if hum and hum.Parent then pcall(function() hum.WalkSpeed = sp end) end
end

local function onWalkSpeedChanged(hum)
    return hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if L.speedEnabled then safeSetWalk(hum, L.desiredSpeed) end
    end)
end

local function attachToCharacter(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if L.speedHumPropConns[hum] then L.speedHumPropConns[hum]:Disconnect() end
        L.speedHumPropConns[hum] = onWalkSpeedChanged(hum)
        safeSetWalk(hum, L.desiredSpeed)
    end
end

local function startSpeedLoop()
    if L.speedHeartbeatConn then return end
    L.speedHeartbeatConn = RunService.Heartbeat:Connect(function()
        if not L.speedEnabled then return end
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                safeSetWalk(hum, L.desiredSpeed)
                if not L.speedHumPropConns[hum] then L.speedHumPropConns[hum] = onWalkSpeedChanged(hum) end
            end
        end
    end)
end

local function stopSpeedLoop()
    if L.speedHeartbeatConn then L.speedHeartbeatConn:Disconnect() L.speedHeartbeatConn = nil end
    for hum, conn in pairs(L.speedHumPropConns) do pcall(function() conn:Disconnect() end) end
    L.speedHumPropConns = {}
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then safeSetWalk(hum, 16) end
    end
end

function setWalkSpeedEnabled(state)
    L.speedEnabled = state
    if state then startSpeedLoop() if player.Character then attachToCharacter(player.Character) end
    else stopSpeedLoop() end
end

function setWalkSpeedValue(speed)
    L.desiredSpeed = math.clamp(speed, 16, 45)
    if L.speedEnabled then
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then safeSetWalk(hum, L.desiredSpeed) end
        end
    end
end

player.CharacterAdded:Connect(function(char)
    if L.speedEnabled then task.wait(0.1) attachToCharacter(char) end
end)

UserInputService.JumpRequest:Connect(function()
    if not L.jumpModEnabled then return end
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if hum and root and tick() - L.lastJump >= L.cooldown then
        L.lastJump = tick()
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        root.Velocity = Vector3.new(root.Velocity.X, L.jumpHeight, root.Velocity.Z)
    end
end)

RunService.RenderStepped:Connect(function()
    if not L.jumpModEnabled then return end
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if hum and root then
        local userStates = player:FindFirstChild("UserStates")
        if userStates then
            for _, s in pairs({"BrokenLegs", "Grabbed", "Pin"}) do
                if userStates:FindFirstChild(s) then userStates[s].Value = false end
            end
        end
        local animate = char:FindFirstChild("Animate")
        if animate then animate.Parent = nil end
        if root.Velocity.Y < -5 and not UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            hum:ChangeState(Enum.HumanoidStateType.Climbing)
        end
    end
end)

function L.startAntiFall()
    if L.antiFallConnection then L.antiFallConnection:Disconnect() end
    L.antiFallConnection = RunService.Heartbeat:Connect(function()
        if not L.antiFallEnabled then return end
        local char = player.Character
        if not char then L.fallStartY = nil return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid then return end
        local currentY = root.Position.Y
        local velocityY = root.Velocity.Y
        if velocityY < -0.1 then
            if not L.fallStartY then L.fallStartY = currentY
            else
                local fallDistance = L.fallStartY - currentY
                if fallDistance >= FALL_DISTANCE_THRESHOLD then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    root.Velocity = Vector3.new(root.Velocity.X, ANTI_FALL_JUMP_HEIGHT, root.Velocity.Z)
                    L.fallStartY = nil
                end
            end
        else L.fallStartY = nil end
    end)
end

function L.stopAntiFall()
    if L.antiFallConnection then L.antiFallConnection:Disconnect() end
    L.antiFallConnection = nil
    L.fallStartY = nil
end

player.CharacterAdded:Connect(function() L.stopAntiFall() L.fallStartY = nil end)

function L.getNearestZombieInRange()
    local char = player.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local playerPos = root.Position
    local nearest = nil
    local nearestDist = math.huge
    local zombiesFolder = workspace:FindFirstChild("Zombies")
    if zombiesFolder then
        for _, zombie in pairs(zombiesFolder:GetChildren()) do
            if zombie:IsA("Model") and zombie:FindFirstChild("HumanoidRootPart") then
                if L.skipBarrel and zombie:GetAttribute("Type") == "Barrel" then continue end
                local state = zombie:FindFirstChild("State")
                if state and state.Value == "Spawn" then continue end
                local targetRoot = zombie.HumanoidRootPart
                local dist = (targetRoot.Position - playerPos).Magnitude
                if dist <= L.autoFaceRange and dist < nearestDist then
                    nearestDist = dist
                    nearest = zombie
                end
            end
        end
    end
    return nearest
end

function L.faceZombie(zombie)
    if not zombie or not zombie:FindFirstChild("HumanoidRootPart") then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local wasAutoRotate = humanoid.AutoRotate
    humanoid.AutoRotate = false
    local targetPos = zombie.HumanoidRootPart.Position
    local lookAtPos = Vector3.new(targetPos.X, root.Position.Y, targetPos.Z)
    root.CFrame = CFrame.lookAt(root.Position, lookAtPos)
    humanoid.AutoRotate = wasAutoRotate
end

function L.autoFaceLoop()
    while L.autoFaceEnabled do
        local target = L.getNearestZombieInRange()
        if target then L.faceZombie(target) end
        task.wait(0.1)
    end
end

function L.startAutoFace()
    if L.autoFaceConnection then task.cancel(L.autoFaceConnection) L.autoFaceConnection = nil end
    if L.autoFaceEnabled then L.autoFaceConnection = task.spawn(L.autoFaceLoop) end
end

function L.stopAutoFace()
    if L.autoFaceConnection then task.cancel(L.autoFaceConnection) L.autoFaceConnection = nil end
end

player.CharacterAdded:Connect(function()
    if L.autoFaceEnabled then L.stopAutoFace() L.startAutoFace() end
end)

function L.startAutoJump()
    if L.autoJumpConn then return end
    L.autoJumpConn = RunService.Heartbeat:Connect(function()
        if not L.autoJumpEnabled then return end
        local char = player.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not humanoid or not root then return end
        local onGround = humanoid.FloorMaterial ~= Enum.Material.Air
        if onGround then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            root.Velocity = Vector3.new(root.Velocity.X, L.autoJumpHeight, root.Velocity.Z)
        end
    end)
end

function L.stopAutoJump()
    if L.autoJumpConn then L.autoJumpConn:Disconnect() L.autoJumpConn = nil end
end

function L.setupNoSlow()
    if not player.Character then return end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    if L.minorFeatures.noSlow.walkSpeedConn then L.minorFeatures.noSlow.walkSpeedConn:Disconnect() end
    L.minorFeatures.noSlow.walkSpeedConn = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if L.minorFeatures.noSlow.active and humanoid.WalkSpeed < 16 then humanoid.WalkSpeed = 16 end
    end)
    if L.minorFeatures.noSlow.active and humanoid.WalkSpeed < 16 then humanoid.WalkSpeed = 16 end
end

function L.preventFallDamage()
    while L.minorFeatures.noFall.active do
        if not player.Character then task.wait(1) continue end
        local health = player.Character:FindFirstChild("Health")
        if health then
            local forceSelfDamage = health:FindFirstChild("ForceSelfDamage")
            if forceSelfDamage then forceSelfDamage:FireServer(0) end
        end
        task.wait(1)
    end
end

function L.autoDoorLoop()
    while L.autoDoorEnabled do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            for _, item in pairs(Workspace:GetDescendants()) do
                if item.Name == "Main" and item:IsA("Model") then
                    if (root.Position - item:GetModelCFrame().Position).Magnitude <= 23 then
                        local isOpen = item:GetAttribute("Open")
                        if isOpen == nil then pcall(function() isOpen = item.Open end) end
                        if isOpen == false then
                            local mainPart = item:FindFirstChild("Main")
                            local remote = mainPart and mainPart:FindFirstChild("Interact")
                            if remote and remote:IsA("RemoteEvent") and not L.processingDoors[item] then
                                L.processingDoors[item] = true
                                task.spawn(function()
                                    remote:FireServer()
                                    task.wait(0.5)
                                    L.processingDoors[item] = nil
                                end)
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end

function L.getDiggingTool()
    local char = player.Character
    if not char then return nil end
    for _, tool in pairs(char:GetChildren()) do
        if (tool.Name == "Shovel" or tool.Name == "Spade") and tool:FindFirstChild("RemoteEvent") then return tool end
    end
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if (tool.Name == "Shovel" or tool.Name == "Spade") and tool:FindFirstChild("RemoteEvent") then return tool end
    end
    return nil
end

function L.findValidDiggable()
    for _, path in ipairs(DIGGABLE_PATHS) do
        local parts = path:split("/")
        local current = workspace
        for _, partName in ipairs(parts) do
            current = current:FindFirstChild(partName)
            if not current then break end
        end
        if current then return current end
    end
    return nil
end

function L.executeDig()
    if not L.autoFeatures.autoDig then return end
    local diggable = L.findValidDiggable()
    if not diggable then return end
    local tool = L.getDiggingTool()
    if not tool then return end
    if tool.Parent ~= player.Character then tool.Parent = player.Character task.wait(0.2) end
    local remoteEvent = tool:FindFirstChild("RemoteEvent")
    if remoteEvent then remoteEvent:FireServer("Dig", diggable, diggable.Position) end
end

function L.autoDigLoop()
    while L.autoFeatures.autoDig do L.executeDig() task.wait(0.05) end
end

function L.getNearestConstruct()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local root = char.HumanoidRootPart
    local bridge = workspace:FindFirstChild("Berezina") and workspace.Berezina:FindFirstChild("Modes") and workspace.Berezina.Modes:FindFirstChild("Holdout") and workspace.Berezina.Modes.Holdout:FindFirstChild("Bridge")
    if not bridge then return nil end
    local nearest, dist = nil, math.huge
    for _, section in ipairs(bridge:GetChildren()) do
        local posts = section:FindFirstChild("Posts")
        if posts then
            for _, part in ipairs(posts:GetChildren()) do
                if part:IsA("BasePart") and part:FindFirstChild("ConstructHealth") then
                    local d = (part.Position - root.Position).Magnitude
                    if d < dist then dist = d nearest = part.ConstructHealth end
                end
            end
        end
        local beam = section:FindFirstChild("Beam")
        if beam and beam:FindFirstChild("ConstructHealth") then
            local d = (beam.Position - root.Position).Magnitude
            if d < dist then dist = d nearest = beam.ConstructHealth end
        end
        for _, joists in ipairs(section:GetChildren()) do
            if joists.Name == "Joists" and joists:FindFirstChild("ConstructHealth") then
                local d = (joists.Position - root.Position).Magnitude
                if d < dist then dist = d nearest = joists.ConstructHealth end
            end
        end
    end
    return nearest
end

function L.doRepairBridge()
    local target = L.getNearestConstruct()
    if not target then return end
    local hammer = player.Backpack:FindFirstChild("Hammer") or player.Backpack:FindFirstChild("Claw Hammer")
    if not hammer or not hammer:FindFirstChild("RemoteEvent") then return end
    hammer.RemoteEvent:FireServer("Repair", target)
end

function L.setupKaubAutoCollect()
    L.autoFeatures.autoCollectKaubPrompts = {}
    for _, descendant in ipairs(workspace:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") then L.autoFeatures.autoCollectKaubPrompts[descendant] = true end
    end
    local descendantAddedConn = workspace.DescendantAdded:Connect(function(desc)
        if desc:IsA("ProximityPrompt") then L.autoFeatures.autoCollectKaubPrompts[desc] = true end
    end)
    L.autoFeatures.autoCollectKaubConnection = RunService.Heartbeat:Connect(function()
        if not L.autoFeatures.autoCollectKaub or not player.Character then return end
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for prompt, _ in pairs(L.autoFeatures.autoCollectKaubPrompts) do
            if prompt and prompt.Parent and prompt:IsA("ProximityPrompt") and prompt.Enabled then
                local part = prompt.Parent
                if part:IsA("BasePart") and (part.Position - hrp.Position).Magnitude <= prompt.MaxActivationDistance then
                    fireproximityprompt(prompt)
                end
            else L.autoFeatures.autoCollectKaubPrompts[prompt] = nil end
        end
    end)
    return descendantAddedConn
end

function L.getPurchaseEvent()
    local rs = game:GetService("ReplicatedStorage")
    local events = rs:FindFirstChild("Events")
    if not events then return nil end
    local customize = events:FindFirstChild("Customize")
    if not customize then return nil end
    return customize:FindFirstChild("PurchaseEvent")
end

function L.getEquipWeaponEvent()
    local rs = game:GetService("ReplicatedStorage")
    local events = rs:FindFirstChild("Events")
    if not events then return nil end
    return events:FindFirstChild("EquipWeapon")
end

function L.getHeldMelee()
    local character = player.Character
    if not character then return nil end
    for _, item in pairs(character:GetChildren()) do
        if item:IsA("Tool") and item:GetAttribute("Melee") then return item end
    end
    return nil
end

function L.distanceToZombie(zombie)
    local character = player.Character
    if not character then return math.huge end
    local myRoot = character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return math.huge end
    local targetRoot = zombie:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return math.huge end
    return (targetRoot.Position - myRoot.Position).Magnitude
end

function L.attackZombieOnce(zombie, weapon)
    if not weapon then return false end
    if L.distanceToZombie(zombie) > L.auraRangeHighFreq then return false end
    local remote = weapon:FindFirstChild("RemoteEvent")
    if not remote then return false end
    local head = zombie:FindFirstChild("Head")
    if not head then return false end
    if weapon.Name == "Axe" and zombie:FindFirstChild("State") and zombie.State.Value ~= "Stunned" then
        remote:FireServer("BraceBlock")
        remote:FireServer("StopBraceBlock")
        remote:FireServer("FeedbackStun", zombie, zombie.HumanoidRootPart.Position)
    end
    remote:FireServer("Swing", "Side")
    remote:FireServer("HitZombie", zombie, head.Position, true)
    return true
end

function L.attackLoop()
    while L.auraEnabled do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local weapon = L.getHeldMelee()
                if weapon then
                    local zombiesInRange = {}
                    local zombiesFolder = workspace:FindFirstChild("Zombies")
                    if zombiesFolder then
                        for _, zombie in pairs(zombiesFolder:GetChildren()) do
                            if zombie:IsA("Model") and zombie:FindFirstChild("HumanoidRootPart") then
                                if not L.attackBarrelEnabled and zombie:GetAttribute("Type") == "Barrel" then continue end
                                if zombie:FindFirstChild("State") and zombie.State.Value == "Spawn" then continue end
                                if L.distanceToZombie(zombie) <= L.auraRangeHighFreq then table.insert(zombiesInRange, zombie) end
                            end
                        end
                    end
                    local zombieCount = #zombiesInRange
                    if zombieCount > 0 then
                        if L.attackIndex > zombieCount then L.attackIndex = 1 end
                        local attackCount = math.min(L.ATTACK_SPEED, zombieCount)
                        local attacked = 0
                        local i = L.attackIndex
                        while attacked < attackCount do
                            local zombie = zombiesInRange[i]
                            if zombie then
                                for _ = 1, L.ATTACK_MULTIPLIER do L.attackZombieOnce(zombie, weapon) end
                                attacked = attacked + 1
                            end
                            i = i + 1
                            if i > zombieCount then i = 1 end
                        end
                        L.attackIndex = i
                    else L.attackIndex = 1 end
                end
            end
        end
        task.wait(L.DELAY_COMPENSATION)
    end
end

function L.startAura()
    if L.attackThread then return end
    L.auraEnabled = true
    L.attackIndex = 1
    L.attackThread = task.spawn(L.attackLoop)
end

function L.stopAura()
    L.auraEnabled = false
    if L.attackThread then task.cancel(L.attackThread) L.attackThread = nil end
    L.attackIndex = 1
end

function L.waveLoopFunc()
    while L.killWaveEnabled do
        local startTime = tick()
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local weapon = L.getHeldMelee()
                if weapon then
                    local zombiesInRange = {}
                    local zombiesFolder = workspace:FindFirstChild("Zombies")
                    if zombiesFolder then
                        for _, zombie in pairs(zombiesFolder:GetChildren()) do
                            if zombie:IsA("Model") and zombie:FindFirstChild("HumanoidRootPart") then
                                if not L.attackBarrelEnabled and zombie:GetAttribute("Type") == "Barrel" then continue end
                                if zombie.State and zombie.State.Value == "Spawn" then continue end
                                if L.distanceToZombie(zombie) <= L.auraRangeWave then table.insert(zombiesInRange, zombie) end
                            end
                        end
                    end
                    local attackCount = math.min(WAVE_MAX_TARGETS, #zombiesInRange)
                    for i = 1, attackCount do L.attackZombieOnce(zombiesInRange[i], weapon) end
                end
            end
        end
        local elapsed = tick() - startTime
        local waitTime = WAVE_ATTACK_INTERVAL - elapsed
        if waitTime > 0 then task.wait(waitTime) end
    end
end

function L.startWaveMode()
    if L.killWaveLoop then task.cancel(L.killWaveLoop) L.killWaveLoop = nil end
    if L.killWaveEnabled then L.killWaveLoop = task.spawn(L.waveLoopFunc) end
end

function L.performSingleAnimAttack()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    local weapon = L.getHeldMelee()
    if not weapon then return end
    local zombiesInRange = {}
    local zombiesFolder = workspace:FindFirstChild("Zombies")
    if zombiesFolder then
        for _, zombie in pairs(zombiesFolder:GetChildren()) do
            if zombie:IsA("Model") and zombie:FindFirstChild("HumanoidRootPart") then
                if not L.attackBarrelEnabled and zombie:GetAttribute("Type") == "Barrel" then continue end
                if zombie.State and zombie.State.Value == "Spawn" then continue end
                if L.distanceToZombie(zombie) <= L.auraRangeManual then table.insert(zombiesInRange, zombie) end
            end
        end
    end
    for _, zombie in ipairs(zombiesInRange) do L.attackZombieOnce(zombie, weapon) end
end

function L.onKillAnimationPlayed(animationTrack)
    if not L.killAnimEnabled then return end
    local animId = animationTrack.Animation.AnimationId
    for _, config in ipairs(ANIMATION_CONFIGS) do
        if config.AnimationId == animId then
            task.delay(config.ActivationDelay, function()
                if L.killAnimEnabled then L.performSingleAnimAttack() end
            end)
            break
        end
    end
end

function L.updateKillAnimConnection()
    if L.killAnimEnabled then
        if L.killAnimConnection then return end
        local char = player.Character
        if not char then
            player.CharacterAdded:Connect(function() task.wait(1) L.updateKillAnimConnection() end)
            return
        end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then L.killAnimConnection = humanoid.AnimationPlayed:Connect(L.onKillAnimationPlayed) end
    else
        if L.killAnimConnection then L.killAnimConnection:Disconnect() L.killAnimConnection = nil end
    end
end

player.CharacterAdded:Connect(L.updateKillAnimConnection)

local function getHeldMeleeChain()
    local char = player.Character
    if not char then return nil end
    for _, item in pairs(char:GetChildren()) do
        if item:IsA("Tool") and item:GetAttribute("Melee") then return item end
    end
    return nil
end

local function distanceToZombieChain(zombie)
    local char = player.Character
    if not char then return math.huge end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return math.huge end
    local targetRoot = zombie:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return math.huge end
    return (targetRoot.Position - myRoot.Position).Magnitude
end

local function getClosestZombieChain()
    local closest = nil
    local closestDist = math.huge
    local zombiesFolder = workspace:FindFirstChild("Zombies")
    if not zombiesFolder then return nil end
    for _, zombie in pairs(zombiesFolder:GetChildren()) do
        if zombie:IsA("Model") and zombie:FindFirstChild("HumanoidRootPart") then
            if not L.attackBarrelEnabled and zombie:GetAttribute("Type") == "Barrel" then continue end
            local state = zombie:FindFirstChild("State")
            if state and state.Value == "Spawn" then continue end
            local dist = distanceToZombieChain(zombie)
            if dist <= L.chainKillRange and dist < closestDist then
                closestDist = dist
                closest = zombie
            end
        end
    end
    return closest
end

local function attackZombieChain(zombie, weapon)
    if not weapon or not zombie then return end
    local remote = weapon:FindFirstChild("RemoteEvent")
    if not remote then return end
    local head = zombie:FindFirstChild("Head")
    if not head then return end
    remote:FireServer("Swing", "Side")
    remote:FireServer("HitZombie", zombie, head.Position, true)
end

local function chainAttackLoop()
    while L.chainAuraEnabled do
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local weapon = getHeldMeleeChain()
                if weapon then
                    local target = getClosestZombieChain()
                    if target then attackZombieChain(target, weapon) end
                end
            end
        end
        task.wait(0.005)
    end
end

function L.startChainAura()
    if L.chainAttackThread then return end
    L.chainAuraEnabled = true
    L.chainAttackThread = task.spawn(chainAttackLoop)
end

function L.stopChainAura()
    L.chainAuraEnabled = false
    if L.chainAttackThread then task.cancel(L.chainAttackThread) L.chainAttackThread = nil end
end

local Modules = ReplicatedStorage:FindFirstChild("Modules")
local Weapons = Modules and Modules:FindFirstChild("Weapons")
if not Weapons then
    Weapons = setmetatable({}, { __index = function() return nil end })
end

function L.customBayonetHitCheck(self, origin, direction, raycastParams, hitEntities)
    local rayResult = workspace:Raycast(origin, direction, raycastParams)
    if rayResult then
        local hitPart = rayResult.Instance
        local zombieModel = hitPart and hitPart.Parent
        if zombieModel and zombieModel.Name == "m_Zombie" then
            local orig = zombieModel:FindFirstChild("Orig")
            if orig then
                local head = nil
                for _, part in ipairs(zombieModel:GetChildren()) do
                    if part.Name == "Head" and (part:IsA("Part") or part:IsA("MeshPart")) then head = part break end
                end
                if head then
                    local zombieRef = orig.Value
                    local headPos = head.CFrame.Position
                    self.remoteEvent:FireServer("Bayonet_HitZombie", zombieRef, headPos, true, "Head")
                    zombieRef:SetAttribute("WepHitID", tick())
                    zombieRef:SetAttribute("WepHitDirection", direction * 10)
                    zombieRef:SetAttribute("WepHitPos", rayResult.Position)
                    task.delay(0.2, function()
                        if zombieRef:GetAttribute("WepHitID") == tick() then
                            zombieRef:SetAttribute("WepHitDirection", nil)
                            zombieRef:SetAttribute("WepHitPos", nil)
                            zombieRef:SetAttribute("WepHitID", nil)
                        end
                    end)
                    return 1
                end
            end
        end
        if L.originalBayonetHitCheck then return L.originalBayonetHitCheck(self, origin, direction, raycastParams, hitEntities) end
    end
    return 0
end

function L.customMeleeHitCheck(self, origin, direction, raycastParams, hitEntities, isCharge)
    local rayResult = workspace:Raycast(origin, direction, raycastParams)
    if rayResult then
        local hitPart = rayResult.Instance
        local zombieModel = hitPart and hitPart.Parent
        if zombieModel and zombieModel.Name == "m_Zombie" then
            local orig = zombieModel:FindFirstChild("Orig")
            if orig then
                local head = nil
                for _, part in ipairs(zombieModel:GetChildren()) do
                    if part.Name == "Head" and (part:IsA("Part") or part:IsA("MeshPart")) then head = part break end
                end
                if head then
                    local zombieRef = orig.Value
                    local headPos = head.CFrame.Position
                    if isCharge then
                        self.remoteEvent:FireServer("ThrustCharge", zombieRef, headPos, rayResult.Normal)
                    else
                        local hitDirection = (headPos - origin).Unit * 25
                        self.remoteEvent:FireServer("HitZombie", zombieRef, headPos, true, hitDirection, "Head", rayResult.Normal)
                        if not zombieRef:GetAttribute("WepHitDirection") then
                            local uid = tick()
                            zombieRef:SetAttribute("WepHitID", uid)
                            zombieRef:SetAttribute("WepHitDirection", hitDirection)
                            zombieRef:SetAttribute("WepHitPos", rayResult.Position)
                            task.delay(0.2, function()
                                if zombieRef:GetAttribute("WepHitID") == uid then
                                    zombieRef:SetAttribute("WepHitDirection", nil)
                                    zombieRef:SetAttribute("WepHitPos", nil)
                                    zombieRef:SetAttribute("WepHitID", nil)
                                end
                            end)
                        end
                    end
                    return 1
                end
            end
        end
        if L.originalMeleeHitCheck then return L.originalMeleeHitCheck(self, origin, direction, raycastParams, hitEntities, isCharge) end
    end
    return 0
end

function L.enableHeadshot()
    if not Weapons or not Weapons.FindFirstChild then return end
    if L.headshotEnabled then return end
    local flintlockSuccess, FlintLock = pcall(require, Weapons:FindFirstChild("Flintlock"))
    if flintlockSuccess and FlintLock and not L.bayonetHooked then
        L.originalBayonetHitCheck = FlintLock.BayonetHitCheck
        FlintLock.BayonetHitCheck = L.customBayonetHitCheck
        L.bayonetHooked = true
    end
    local meleeSuccess, MeleeBase = pcall(require, Weapons:FindFirstChild("MeleeBase"))
    if meleeSuccess and MeleeBase and not L.meleeHooked then
        L.originalMeleeHitCheck = MeleeBase.MeleeHitCheck
        MeleeBase.MeleeHitCheck = L.customMeleeHitCheck
        L.meleeHooked = true
    end
    L.headshotEnabled = true
end

function L.disableHeadshot()
    if not Weapons or not Weapons.FindFirstChild then return end
    if not L.headshotEnabled then return end
    if L.bayonetHooked then
        local flintlockSuccess, FlintLock = pcall(require, Weapons:FindFirstChild("Flintlock"))
        if flintlockSuccess and FlintLock and L.originalBayonetHitCheck then FlintLock.BayonetHitCheck = L.originalBayonetHitCheck end
        L.bayonetHooked = false
    end
    if L.meleeHooked then
        local meleeSuccess, MeleeBase = pcall(require, Weapons:FindFirstChild("MeleeBase"))
        if meleeSuccess and MeleeBase and L.originalMeleeHitCheck then MeleeBase.MeleeHitCheck = L.originalMeleeHitCheck end
        L.meleeHooked = false
    end
    L.headshotEnabled = false
    L.originalBayonetHitCheck = nil
    L.originalMeleeHitCheck = nil
end

local function onCharacterAddedForHeadshot()
    if L.headshotEnabled then task.wait(1) L.disableHeadshot() task.wait(0.1) L.enableHeadshot() end
end
player.CharacterAdded:Connect(onCharacterAddedForHeadshot)

function L.getPlayerTeam(player)
    if player.Team then return player.Team end
    local teamAttr = player:GetAttribute("Team")
    if teamAttr then return teamAttr end
    local char = player.Character
    if char then
        local teamTag = char:FindFirstChild("TeamTag") or char:FindFirstChild("Team")
        if teamTag then return teamTag.Value end
    end
    return nil
end

function L.pvpIsSameTeam(targetPlayer)
    local myTeam = L.getPlayerTeam(player)
    local theirTeam = L.getPlayerTeam(targetPlayer)
    if myTeam and theirTeam then return myTeam == theirTeam end
    return false
end

function L.isPlayerValidPVP(targetPlayer, myRoot, range)
    if not targetPlayer or targetPlayer == player then return false end
    if L.pvpIsSameTeam(targetPlayer) then return false end
    local char = targetPlayer.Character
    if not char then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    local targetRoot = char:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return false end
    local dx = math.abs(targetRoot.Position.X - myRoot.Position.X)
    local dz = math.abs(targetRoot.Position.Z - myRoot.Position.Z)
    return dx <= range and dz <= range
end

function L.getMusket()
    local char = player.Character
    if not char then return nil end
    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") and tool.Name == "Musket" then return tool end
    end
    return nil
end

function L.getMeleeWeaponPVP()
    local char = player.Character
    if not char then return nil end
    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("RemoteEvent") and tool.Name ~= "Musket" then return tool end
    end
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("RemoteEvent") and tool.Name ~= "Musket" then return tool end
    end
    return nil
end

function L.getClosestUnguardedPlayerBayonet(myRoot)
    local closest = nil
    local closestDistSq = math.huge
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if L.isPlayerValidPVP(targetPlayer, myRoot, BAYONET_RANGE) and not L.attackedBayonetPlayers[targetPlayer] then
            local char = targetPlayer.Character
            local targetRoot = char and char:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local dx = targetRoot.Position.X - myRoot.Position.X
                local dz = targetRoot.Position.Z - myRoot.Position.Z
                local distSq = dx*dx + dz*dz
                if distSq < closestDistSq then closestDistSq = distSq closest = targetPlayer end
            end
        end
    end
    return closest
end

function L.getClosestUnguardedPlayerMelee(myRoot)
    local closest = nil
    local closestDistSq = math.huge
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if L.isPlayerValidPVP(targetPlayer, myRoot, MELEE_RANGE_PVP) and not L.attackedMeleePlayers[targetPlayer] then
            local char = targetPlayer.Character
            local targetRoot = char and char:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local dx = targetRoot.Position.X - myRoot.Position.X
                local dz = targetRoot.Position.Z - myRoot.Position.Z
                local distSq = dx*dx + dz*dz
                if distSq < closestDistSq then closestDistSq = distSq closest = targetPlayer end
            end
        end
    end
    return closest
end

function L.attackWithBayonet(targetPlayer)
    local musket = L.getMusket()
    if not musket then return end
    local remote = musket:FindFirstChild("RemoteEvent")
    if not remote then return end
    local char = targetPlayer.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not head or not humanoid then return end
    remote:FireServer("ThrustBayonet")
    remote:FireServer("Bayonet_HitPlayer", humanoid, head.Position)
end

function L.attackWithMeleePVP(targetPlayer)
    local weapon = L.getMeleeWeaponPVP()
    if not weapon then return end
    local remote = weapon:FindFirstChild("RemoteEvent")
    if not remote then return end
    local char = targetPlayer.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not head or not humanoid then return end
    if weapon.Name == "Axe" then
        if humanoid and humanoid.Health > 0 then
            remote:FireServer("BraceBlock")
            remote:FireServer("StopBraceBlock")
            remote:FireServer("FeedbackStun", targetPlayer, head.Position)
        end
    end
    for _ = 1, MELEE_ATTACK_MULTIPLIER_PVP do
        remote:FireServer("PrepareSwing")
        remote:FireServer("Swing", "Side")
        remote:FireServer("HitPlayer", humanoid, head.Position)
    end
end

function L.cleanupBayonetList(myRoot)
    for target, _ in pairs(L.attackedBayonetPlayers) do
        if not L.isPlayerValidPVP(target, myRoot, BAYONET_RANGE) then L.attackedBayonetPlayers[target] = nil end
    end
end

function L.cleanupMeleeList(myRoot)
    for target, _ in pairs(L.attackedMeleePlayers) do
        if not L.isPlayerValidPVP(target, myRoot, MELEE_RANGE_PVP) then L.attackedMeleePlayers[target] = nil end
    end
end

function L.onPVPHeartbeat()
    local myChar = player.Character
    if not myChar then return end
    local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")
    if not myHumanoid or myHumanoid.Health <= 0 then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    if L.pvpBayonetActive then
        L.cleanupBayonetList(myRoot)
        local target = L.getClosestUnguardedPlayerBayonet(myRoot)
        if target then
            L.attackWithBayonet(target)
            L.attackedBayonetPlayers[target] = true
        else L.attackedBayonetPlayers = {} end
    end
    if L.pvpMeleeActive then
        L.cleanupMeleeList(myRoot)
        local target = L.getClosestUnguardedPlayerMelee(myRoot)
        if target then
            L.attackWithMeleePVP(target)
            L.attackedMeleePlayers[target] = true
        else L.attackedMeleePlayers = {} end
    end
end

function L.updatePVPHeartbeat()
    if L.pvpBayonetActive or L.pvpMeleeActive then
        if not L.pvpHeartbeatConn then L.pvpHeartbeatConn = RunService.Heartbeat:Connect(L.onPVPHeartbeat) end
    else
        if L.pvpHeartbeatConn then L.pvpHeartbeatConn:Disconnect() L.pvpHeartbeatConn = nil end
    end
end

local function onCharacterAddedForPVP()
    L.attackedBayonetPlayers = {}
    L.attackedMeleePlayers = {}
end
player.CharacterAdded:Connect(onCharacterAddedForPVP)
local function getCurrentGun()
    local char = player.Character
    if not char then return nil end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local animFolder = tool:FindFirstChild("Animations")
            if animFolder and (animFolder:FindFirstChild("Aim") or animFolder:FindFirstChild("Aiming")) then return tool end
        end
    end
    return nil
end

local function isObstructedBetween(origin, targetPos, targetPlayer)
    if not origin or not targetPos then return true end
    local dir = targetPos - origin
    local dist = dir.Magnitude
    if dist <= 0 then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local ignoreList = {}
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl.Character then table.insert(ignoreList, pl.Character) end
    end
    if targetPlayer and targetPlayer.Character then table.insert(ignoreList, targetPlayer.Character) end
    params.FilterDescendantsInstances = ignoreList
    local result = workspace:Raycast(origin, dir, params)
    if result then
        local hit = result.Instance
        if hit then return true end
    end
    return false
end

local function getNearestVisibleEnemyPlayer()
    local char = player.Character
    if not char then return nil, nil end
    local head = char:FindFirstChild("Head")
    if not head then return nil, nil end
    local origin = head.Position
    local bestPlayer, bestPart, bestDist = nil, nil, L.autoShootRange + 1
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local myTeam = L.getPlayerTeam and L.getPlayerTeam(player) or nil
            local theirTeam = L.getPlayerTeam and L.getPlayerTeam(plr) or nil
            if myTeam and theirTeam and myTeam == theirTeam then continue end
            local targetChar = plr.Character
            if targetChar then
                local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local targetPart = targetChar:FindFirstChild("Head") or targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Torso")
                    if targetPart and targetPart:IsA("BasePart") then
                        local dist = (targetPart.Position - origin).Magnitude
                        if dist <= L.autoShootRange and dist < bestDist then
                            if not isObstructedBetween(origin, targetPart.Position, plr) then
                                bestDist = dist
                                bestPlayer = plr
                                bestPart = targetPart
                            end
                        end
                    end
                end
            end
        end
    end
    return bestPlayer, bestPart
end

local function smoothAimToTarget(rootPart, getTargetPosFunc, duration)
    if not rootPart or not getTargetPosFunc then return end
    local startTime = tick()
    local startCF = rootPart.CFrame
    local ok, initPos = pcall(getTargetPosFunc)
    if not ok or not initPos then return end
    while tick() - startTime < duration do
        if not rootPart.Parent then return end
        local curPos = nil
        pcall(function() curPos = getTargetPosFunc() end)
        if not curPos then curPos = initPos end
        local desired = CFrame.new(rootPart.Position, Vector3.new(curPos.X, rootPart.Position.Y, curPos.Z))
        local t = math.clamp((tick() - startTime) / duration, 0, 1)
        local smooth = t * t * (3 - 2 * t)
        local lerped = startCF:Lerp(desired, smooth)
        rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + lerped.LookVector)
        RunService.RenderStepped:Wait()
    end
    local finalPos = nil
    pcall(function() finalPos = getTargetPosFunc() end)
    if finalPos then
        rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + CFrame.new(rootPart.Position, Vector3.new(finalPos.X, rootPart.Position.Y, finalPos.Z)).LookVector)
    end
end

local function shootAtTarget(targetPart, tool)
    if not targetPart or not targetPart.Parent or not tool or not tool.Parent then return end
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
    local animFolder = tool:FindFirstChild("Animations")
    local aimAnimId, aimingAnimId, fireAnimId
    if animFolder then
        local aim = animFolder:FindFirstChild("Aim")
        local aiming = animFolder:FindFirstChild("Aiming")
        local fire = animFolder:FindFirstChild("Fire")
        if aim and aim:IsA("Animation") then aimAnimId = aim.AnimationId end
        if aiming and aiming:IsA("Animation") then aimingAnimId = aiming.AnimationId end
        if fire and fire:IsA("Animation") then fireAnimId = fire.AnimationId end
    end
    aimAnimId = aimAnimId or "rbxassetid://83511222574103"
    aimingAnimId = aimingAnimId or "rbxassetid://136849639865723"
    local trackAim = nil
    if aimAnimId then
        local ok, tr = pcall(function()
            local anim = Instance.new("Animation")
            anim.AnimationId = aimAnimId
            return animator:LoadAnimation(anim)
        end)
        if ok and tr then trackAim = tr trackAim:Play(0.05, 1, 1) end
    end
    if trackAim then task.wait(math.min(trackAim.Length or 0.6, 0.6)) pcall(function() trackAim:Stop(0.05) end) end
    local trackAiming = nil
    if aimingAnimId then
        local ok, tr = pcall(function()
            local anim = Instance.new("Animation")
            anim.AnimationId = aimingAnimId
            return animator:LoadAnimation(anim)
        end)
        if ok and tr then trackAiming = tr trackAiming:Play(0.05, 1, 1) end
    end
    task.wait(0.02)
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        local function getTargetPos() return targetPart.Position end
        smoothAimToTarget(root, getTargetPos, 0.28)
    end
    local trackFire = nil
    if fireAnimId then
        local ok, tr = pcall(function()
            local anim = Instance.new("Animation")
            anim.AnimationId = fireAnimId
            return animator:LoadAnimation(anim)
        end)
        if ok and tr then trackFire = tr trackFire:Play(0.05, 1, 1) end
    end
    local remote = tool:FindFirstChild("RemoteEvent")
    if not remote then
        local wsPlayers = workspace:FindFirstChild("Players")
        if wsPlayers then
            local playerFolder = wsPlayers:FindFirstChild(player.Name)
            if playerFolder then
                local toolFolder = playerFolder:FindFirstChild(tool.Name)
                if toolFolder then remote = toolFolder:FindFirstChild("RemoteEvent") end
            end
        end
    end
    if remote then
        local modelRef = char:FindFirstChild("Model") or char
        local timestamp = workspace:GetServerTimeNow()
        pcall(function() remote:FireServer("Fire", modelRef, targetPart.Position, timestamp) end)
    end
    if trackFire then task.delay(0.35, function() pcall(function() trackFire:Stop(0.07) end) end) end
    if trackAiming then task.wait(0.05) pcall(function() trackAiming:Stop(0.1) end) end
end

local function autoShootPlayerLoop()
    while L.autoShootPlayerEnabled do
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local gun = getCurrentGun()
                if gun then
                    local _, targetPart = getNearestVisibleEnemyPlayer()
                    if targetPart then shootAtTarget(targetPart, gun) end
                end
            end
        end
        task.wait(0.1)
    end
end

function L.startAutoShootPlayer()
    if L.autoShootPlayerThread then return end
    L.autoShootPlayerEnabled = true
    L.autoShootPlayerThread = task.spawn(autoShootPlayerLoop)
end

function L.stopAutoShootPlayer()
    L.autoShootPlayerEnabled = false
    if L.autoShootPlayerThread then task.cancel(L.autoShootPlayerThread) L.autoShootPlayerThread = nil end
end

function L.getZombieTypeKey(zombie)
    for typeKey, config in pairs(ZOMBIE_TYPES) do
        if config.part and zombie:FindFirstChild(config.part) then return typeKey end
    end
    return "Normal"
end

function L.createTag(zombie, typeKey)
    local config = ZOMBIE_TYPES[typeKey]
    if not config then return nil end
    local attachPart = zombie.PrimaryPart or zombie:FindFirstChild("Head") or zombie:FindFirstChild("HumanoidRootPart")
    if not attachPart then return nil end
    local tag = Instance.new("BillboardGui")
    tag.Size = UDim2.new(0, 120, 0, 30)
    tag.StudsOffset = Vector3.new(0, 2.5, 0)
    tag.AlwaysOnTop = true
    tag.Adornee = attachPart
    tag.Parent = zombie
    local label = Instance.new("TextLabel")
    label.Text = config.name
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = config.highlightColor
    label.TextTransparency = 0.3
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextStrokeTransparency = 0.5
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Parent = tag
    return tag
end

function L.createHighlight(zombie, color)
    local hl = Instance.new("Highlight")
    hl.FillColor = color
    hl.FillTransparency = 0.7
    hl.OutlineColor = color
    hl.OutlineTransparency = 0.7
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = zombie
    hl.Parent = zombie
    return hl
end

function L.removeZombieEffects(zombie)
    local effects = L.zombieEffects[zombie]
    if effects then
        if effects.tag then effects.tag:Destroy() end
        if effects.highlight then effects.highlight:Destroy() end
        L.zombieEffects[zombie] = nil
    end
end

function L.clearAllZombieEffects()
    for zombie, _ in pairs(L.zombieEffects) do L.removeZombieEffects(zombie) end
end

function L.updateZombieESP()
    local anyEnabled = false
    for _, v in pairs(L.zombieEspEnabled) do if v then anyEnabled = true break end end
    if not anyEnabled then L.clearAllZombieEffects() return end
    local char = player.Character
    local rootPart = char and char:FindFirstChild("HumanoidRootPart")
    local playerPos = rootPart and rootPart.Position
    if not playerPos then L.clearAllZombieEffects() return end
    for zombie, _ in pairs(L.zombieEffects) do if not zombie.Parent then L.removeZombieEffects(zombie) end end
    local cameraFolder = workspace:FindFirstChild("Camera")
    if not cameraFolder then return end
    local zombies = cameraFolder:GetDescendants()
    for i = 1, #zombies do
        local zombie = zombies[i]
        if zombie:IsA("Model") and zombie.Name:find("Zombie") then
            local root = zombie:FindFirstChild("HumanoidRootPart") or zombie:FindFirstChild("Head") or zombie:FindFirstChild("Torso")
            if root then
                local dist = (root.Position - playerPos).Magnitude
                local typeKey = L.getZombieTypeKey(zombie)
                local enabled = L.zombieEspEnabled[typeKey]
                if enabled and dist <= L.ZOMBIE_ESP_RANGE then
                    if not L.zombieEffects[zombie] then
                        local config = ZOMBIE_TYPES[typeKey]
                        local tag = L.createTag(zombie, typeKey)
                        local highlight = L.createHighlight(zombie, config.highlightColor)
                        L.zombieEffects[zombie] = { tag = tag, highlight = highlight, typeKey = typeKey }
                    end
                else
                    if L.zombieEffects[zombie] then L.removeZombieEffects(zombie) end
                end
            end
        end
    end
end

L.lastZombieESPUpdate = 0
RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - L.lastZombieESPUpdate >= 0.2 then
        L.lastZombieESPUpdate = now
        L.updateZombieESP()
    end
end)

player.CharacterAdded:Connect(function() task.wait(0.5) L.updateZombieESP() end)

function L.isSameTeam(plr)
    local myTeam = L.getPlayerTeam(player)
    local theirTeam = L.getPlayerTeam(plr)
    if myTeam and theirTeam then return myTeam == theirTeam end
    return false
end

function L.updatePlayerESP(plr)
    if not L.espPlayerEnabled then
        if L.playerHighlights[plr] then L.playerHighlights[plr]:Destroy() L.playerHighlights[plr] = nil end
        if L.playerNameTags[plr] then L.playerNameTags[plr]:Destroy() L.playerNameTags[plr] = nil end
        return
    end
    local shouldShow = true
    if L.espTeamCheckPlayer then shouldShow = not L.isSameTeam(plr) end
    if plr == player then shouldShow = false end
    if shouldShow then
        local char = plr.Character
        if char and char.Parent then
            if not L.playerHighlights[plr] then
                local hl = Instance.new("Highlight")
                hl.Adornee = char
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.FillTransparency = 0.4
                hl.OutlineTransparency = 0.4
                hl.FillColor = Color3.fromRGB(255, 255, 255)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.Parent = char
                L.playerHighlights[plr] = hl
            end
            if L.espShowNames then
                if not L.playerNameTags[plr] then
                    local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                    if head then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = "PlayerNameTag"
                        billboard.Size = UDim2.new(0, 200, 0, 40)
                        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                        billboard.AlwaysOnTop = true
                        billboard.Adornee = head
                        billboard.MaxDistance = 100
                        billboard.Parent = char
                        local label = Instance.new("TextLabel")
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.Text = plr.Name
                        label.TextColor3 = Color3.fromRGB(255, 255, 255)
                        label.TextSize = 16
                        label.Font = Enum.Font.GothamBold
                        label.TextStrokeTransparency = 0.2
                        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        label.Parent = billboard
                        L.playerNameTags[plr] = billboard
                    end
                end
            else
                if L.playerNameTags[plr] then L.playerNameTags[plr]:Destroy() L.playerNameTags[plr] = nil end
            end
        else
            if L.playerHighlights[plr] then L.playerHighlights[plr]:Destroy() L.playerHighlights[plr] = nil end
            if L.playerNameTags[plr] then L.playerNameTags[plr]:Destroy() L.playerNameTags[plr] = nil end
        end
    else
        if L.playerHighlights[plr] then L.playerHighlights[plr]:Destroy() L.playerHighlights[plr] = nil end
        if L.playerNameTags[plr] then L.playerNameTags[plr]:Destroy() L.playerNameTags[plr] = nil end
    end
end

function L.refreshAllPlayersESP()
    for _, plr in ipairs(Players:GetPlayers()) do L.updatePlayerESP(plr) end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function() task.wait(0.2) L.updatePlayerESP(plr) end)
    plr.CharacterRemoving:Connect(function()
        if L.playerHighlights[plr] then L.playerHighlights[plr]:Destroy() L.playerHighlights[plr] = nil end
        if L.playerNameTags[plr] then L.playerNameTags[plr]:Destroy() L.playerNameTags[plr] = nil end
    end)
    L.updatePlayerESP(plr)
end)

Players.PlayerRemoving:Connect(function(plr)
    if L.playerHighlights[plr] then L.playerHighlights[plr]:Destroy() L.playerHighlights[plr] = nil end
    if L.playerNameTags[plr] then L.playerNameTags[plr]:Destroy() L.playerNameTags[plr] = nil end
end)

player.CharacterAdded:Connect(function() task.wait(0.5) L.refreshAllPlayersESP() end)

function L.getLookedStructure()
    local char = player.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local cam = workspace.CurrentCamera
    local origin = cam.CFrame.Position
    local direction = cam.CFrame.LookVector * 50
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(origin, direction, params)
    if not result then return nil end
    local hit = result.Instance
    local model = hit:FindFirstAncestorOfClass("Model")
    if not model then return nil end
    local buildHealth = model:FindFirstChild("BuildingHealth") or (model.Parent and model.Parent:FindFirstChild("BuildingHealth"))
    return buildHealth
end

function L.fireRepair(buildHealth)
    local char = player.Character
    if not char or not buildHealth then return end
    local hammer = char:FindFirstChild("Hammer")
    if not hammer or not hammer:FindFirstChild("RemoteEvent") then return end
    pcall(function() hammer.RemoteEvent:FireServer("Repair", buildHealth) end)
end

function L.autoRepairLoopFunc()
    while L.engineerAutoRepairEnabled do
        local buildHealth = L.getLookedStructure()
        if buildHealth then
            local currentHealth = buildHealth.Value
            local maxHealth = buildHealth:GetAttribute("MaxHealth")
            if maxHealth and currentHealth < maxHealth then L.fireRepair(buildHealth) end
        end
        task.wait(L.repairCooldown)
    end
end

function L.toggleEngineerAutoRepair(state)
    L.engineerAutoRepairEnabled = state
    if state then
        if L.autoRepairLoop then task.cancel(L.autoRepairLoop) end
        L.autoRepairLoop = task.spawn(L.autoRepairLoopFunc)
    else
        if L.autoRepairLoop then task.cancel(L.autoRepairLoop) L.autoRepairLoop = nil end
    end
end

function L.hasAxe()
    local char = player.Character
    if not char then return false, nil end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return false, nil end
    local toolName = tool.Name:lower()
    for _, kw in ipairs(AXE_KEYWORDS) do
        if toolName:find(kw:lower()) then return true, tool end
    end
    return false, nil
end

function L.recycleAxe()
    if not L.engineerRecycleEnabled then return end
    local char = player.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    local toolName = tool.Name:lower()
    for _, kw in ipairs(AXE_KEYWORDS) do
        if toolName:find(kw:lower()) then
            tool.Parent = player:FindFirstChild("Backpack")
            task.wait(0.1)
            if L.engineerRecycleEnabled and char.Parent and tool and tool.Parent == player:FindFirstChild("Backpack") then
                tool.Parent = char
            end
            break
        end
    end
end

function L.stunAroundPlayer()
    if not L.engineerElbowEnabled then return end
    local char = player.Character
    if not char then return end
    local has, tool = L.hasAxe()
    if not has then return end
    local remote = tool:FindFirstChild("RemoteEvent")
    if not remote then return end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local playerPos = rootPart.Position
    local zombiesFolder = workspace:FindFirstChild("Zombies")
    if not zombiesFolder then return end
    for _, zombie in pairs(zombiesFolder:GetChildren()) do
        if zombie:IsA("Model") and zombie:FindFirstChild("HumanoidRootPart") then
            if zombie:GetAttribute("Type") == "Barrel" then continue end
            local state = zombie:FindFirstChild("State")
            if state and state.Value == "Spawn" then continue end
            local zombieRoot = zombie:FindFirstChild("HumanoidRootPart")
            if not zombieRoot then continue end
            if (zombieRoot.Position - playerPos).Magnitude <= STUN_RANGE then
                if zombie:FindFirstChild("State") and zombie.State.Value ~= "Stunned" then
                    remote:FireServer("BraceBlock")
                    remote:FireServer("StopBraceBlock")
                    remote:FireServer("FeedbackStun", zombie, zombieRoot.Position)
                end
            end
        end
    end
end

function L.onEngineerAnimationPlayed(animationTrack)
    if L.engineerRecycleEnabled then
        local animId = animationTrack.Animation.AnimationId
        for _, targetId in ipairs(RECYCLE_ANIMATIONS) do
            if animId == targetId then
                local delayTime = (animId == "rbxassetid://15345113937" and 0.2) or (animId == "rbxassetid://12638409326" and 0.9) or 0.85
                task.delay(delayTime, L.recycleAxe)
                break
            end
        end
    end
    if L.engineerElbowEnabled then
        local animId = animationTrack.Animation.AnimationId
        for _, targetId in ipairs(ELBOW_TRIGGER_ANIMATIONS) do
            if animId == targetId then L.stunAroundPlayer() break end
        end
    end
end

function L.updateEngineerAnimConnection()
    if L.engineerRecycleEnabled or L.engineerElbowEnabled then
        if L.engineerAnimConnection then return end
        local char = player.Character
        if not char then
            player.CharacterAdded:Connect(function() task.wait(1) L.updateEngineerAnimConnection() end)
            return
        end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then L.engineerAnimConnection = humanoid.AnimationPlayed:Connect(L.onEngineerAnimationPlayed) end
    else
        if L.engineerAnimConnection then L.engineerAnimConnection:Disconnect() L.engineerAnimConnection = nil end
    end
end

player.CharacterAdded:Connect(L.updateEngineerAnimConnection)

function L.getMelee()
    if not player.Character then return nil end
    for _, item in pairs(player.Character:GetChildren()) do
        if item:GetAttribute("Melee") then return item end
    end
    for _, item in pairs(player.Backpack:GetChildren()) do
        if item:GetAttribute("Melee") then return item end
    end
    return nil
end

function L.executeElbowStun(zombie)
    local weapon = L.getMelee()
    if not weapon or weapon.Name ~= "Axe" then return end
    if zombie.State.Value == "Stunned" then return end
    weapon.RemoteEvent:FireServer("BraceBlock")
    weapon.RemoteEvent:FireServer("StopBraceBlock")
    weapon.RemoteEvent:FireServer("FeedbackStun", zombie, zombie.HumanoidRootPart.Position)
end

function L.isGun(tool)
    if not tool or not tool:IsA("Tool") then return false end
    local animFolder = tool:FindFirstChild("Animations")
    if not animFolder then return false end
    if animFolder:FindFirstChild("Aim") then return true end
    if animFolder:FindFirstChild("Aiming") then return true end
    return false
end

function L.getShotsLoadedForTool(tool)
    if not tool then return 0 end
    local s = tool:FindFirstChild("ShotsLoaded")
    if s and (s:IsA("IntValue") or s:IsA("NumberValue")) then return s.Value end
    local wsPlayersFolder = Workspace:FindFirstChild("Players")
    if not wsPlayersFolder then return 0 end
    local playerFolder = wsPlayersFolder:FindFirstChild(player.Name)
    if not playerFolder then return 0 end
    local toolFolder = playerFolder:FindFirstChild(tool.Name)
    if not toolFolder then return 0 end
    local shots = toolFolder:FindFirstChild("ShotsLoaded")
    if shots and (shots:IsA("IntValue") or shots:IsA("NumberValue")) then return shots.Value end
    return 0
end

function L.findRemoteForTool(tool)
    if not tool then return nil end
    local remote = tool:FindFirstChild("RemoteEvent")
    if remote then return remote end
    local wsPlayersFolder = Workspace:FindFirstChild("Players")
    if not wsPlayersFolder then return nil end
    local playerFolder = wsPlayersFolder:FindFirstChild(player.Name)
    if not playerFolder then return nil end
    local toolFolder = playerFolder:FindFirstChild(tool.Name)
    if not toolFolder then return nil end
    return toolFolder:FindFirstChild("RemoteEvent")
end

function L.isObstructedBetween(origin, targetPos, targetModel)
    if not L.wallCheckEnabled then return false end
    if not origin or not targetPos then return false end
    local dir = targetPos - origin
    local dist = dir.Magnitude
    if dist <= 0 then return false end
    local function buildBaseIgnoreList()
        local ignoreList = {}
        local camFolder = Workspace:FindFirstChild("Camera")
        if camFolder then
            for _, desc in ipairs(camFolder:GetDescendants()) do
                if desc and desc:IsA("Model") and desc.Name == "m_Zombie" then table.insert(ignoreList, desc) end
            end
        end
        local zombiesFolder = Workspace:FindFirstChild("Zombies")
        if zombiesFolder then table.insert(ignoreList, zombiesFolder) end
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl and pl.Character and pl.Character:IsA("Model") then table.insert(ignoreList, pl.Character) end
        end
        if targetModel then table.insert(ignoreList, targetModel) end
        return ignoreList
    end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = buildBaseIgnoreList()
    local maxIterations = 12
    local remainingDistance = dist
    local originPos = origin
    local dirUnit = dir.Unit
    local epsilon = 0.2
    for i = 1, maxIterations do
        local ok, result = pcall(function() return Workspace:Raycast(originPos, dirUnit * remainingDistance, params) end)
        if not ok or not result then return false end
        local hitInst = result.Instance
        if not hitInst then return false end
        if targetModel and hitInst:IsDescendantOf(targetModel) then return false end
        local isBasePart = hitInst:IsA("BasePart")
        local canCollide = isBasePart and hitInst.CanCollide
        local transparency = isBasePart and hitInst.Transparency or 0
        local isEffectivelyInvisible = (isBasePart and transparency >= 0.95)
        if (not canCollide) or isEffectivelyInvisible then
            local advancePos = result.Position + dirUnit * epsilon
            local passed = (advancePos - origin).Magnitude
            if passed >= dist - 1e-4 then return false end
            originPos = advancePos
            remainingDistance = (targetPos - originPos).Magnitude
            local newFilter = params.FilterDescendantsInstances
            table.insert(newFilter, hitInst)
            params.FilterDescendantsInstances = newFilter
        else return true end
    end
    return true
end

function L.getNearestTargetHeadByMatcher(range, matcherFunc)
    local camFolder = Workspace:FindFirstChild("Camera")
    local cam = workspace.CurrentCamera
    local originPos = nil
    if player.Character and player.Character.Parent then
        local head = player.Character:FindFirstChild("Head")
        if head and head:IsA("BasePart") then originPos = head.Position end
    end
    if not originPos and cam then originPos = cam.CFrame.Position end
    if not originPos then return nil, nil end
    local bestPart, bestDist, bestModel = nil, range + 1e-4, nil
    if not camFolder then return nil, nil end
    for _, model in ipairs(camFolder:GetChildren()) do
        if model:IsA("Model") and model.Name == "m_Zombie" then
            if not matcherFunc(model) then continue end
            local head = model:FindFirstChild("Head")
            local barrel = model:FindFirstChild("Barrel")
            local torso = model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso") or model:FindFirstChild("HumanoidRootPart")
            local measurePart = barrel or head or torso
            if measurePart and measurePart:IsA("BasePart") then
                local okDist, d = pcall(function() return (measurePart.Position - originPos).Magnitude end)
                if okDist and d and d <= range + 1e-4 and d < bestDist then
                    local barrelVisible, headVisible, torsoVisible = false, false, false
                    if barrel and barrel:IsA("BasePart") then
                        local okVis, res = pcall(function() return not L.isObstructedBetween(originPos, barrel.Position, model) end)
                        if okVis and res then barrelVisible = true end
                    end
                    if head and head:IsA("BasePart") then
                        local okVis, res = pcall(function() return not L.isObstructedBetween(originPos, head.Position, model) end)
                        if okVis and res then headVisible = true end
                    end
                    if torso and torso:IsA("BasePart") then
                        local okVis, res = pcall(function() return not L.isObstructedBetween(originPos, torso.Position, model) end)
                        if okVis and res then torsoVisible = true end
                    end
                    local chosenPart = nil
                    if barrelVisible then chosenPart = barrel
                    elseif headVisible then chosenPart = head
                    elseif torsoVisible then chosenPart = torso end
                    if chosenPart and chosenPart:IsA("BasePart") then bestPart, bestDist, bestModel = chosenPart, d, model end
                end
            end
        end
    end
    return bestPart, bestModel
end

function L.smoothLookAtDynamic(rootPart, getPosFunc, duration)
    if not rootPart or not getPosFunc then return end
    local start = tick()
    local startCFrame = rootPart.CFrame
    local ok, initTarget = pcall(getPosFunc)
    if not ok or not initTarget then return end
    while tick() - start < duration do
        if not rootPart.Parent then return end
        local curPos = nil
        pcall(function() curPos = getPosFunc() end)
        if not curPos then curPos = initTarget end
        local desired = CFrame.new(rootPart.Position, Vector3.new(curPos.X, rootPart.Position.Y, curPos.Z))
        local t = math.clamp((tick() - start) / duration, 0, 1)
        local smoothT = t * t * (3 - 2 * t)
        local lerped = startCFrame:Lerp(desired, smoothT)
        local safeCFrame = CFrame.new(rootPart.Position, rootPart.Position + lerped.LookVector)
        pcall(function() rootPart.CFrame = safeCFrame end)
        RunService.RenderStepped:Wait()
    end
    local finalPos = nil
    pcall(function() finalPos = getPosFunc() end)
    if finalPos then
        pcall(function() rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + CFrame.new(rootPart.Position, Vector3.new(finalPos.X, rootPart.Position.Y, finalPos.Z)).LookVector) end)
    end
end

function L.playAnimation(animId, animator)
    if not animId or not animator then return nil end
    local ok, track = pcall(function()
        local anim = Instance.new("Animation")
        anim.AnimationId = animId
        return animator:LoadAnimation(anim)
    end)
    if not ok or not track then return nil end
    track.Priority = Enum.AnimationPriority.Action
    track:Play(0.05, 1, 1)
    return track
end

function L.aimThenShootGun(targetModel, initialPart, tool)
    if not targetModel or not targetModel.Parent then return end
    if not initialPart or not initialPart.Parent or not initialPart:IsA("BasePart") then return end
    if not tool or not tool.Parent or not tool:IsDescendantOf(player.Character) then return end
    if not L.isGun(tool) then return end
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
    local remote = tool:FindFirstChild("RemoteEvent") or nil
    local animFolder = tool:FindFirstChild("Animations")
    local animAId, animBId
    if animFolder then
        local aim = animFolder:FindFirstChild("Aim")
        local aiming = animFolder:FindFirstChild("Aiming")
        if aim and aim:IsA("Animation") then animAId = aim.AnimationId end
        if aiming and aiming:IsA("Animation") then animBId = aiming.AnimationId end
    end
    animAId = animAId or "rbxassetid://83511222574103"
    animBId = animBId or "rbxassetid://136849639865723"
    local fireAnimId = nil
    if animFolder then
        local fire = animFolder:FindFirstChild("Fire")
        if fire and fire:IsA("Animation") then fireAnimId = fire.AnimationId end
    end
    local trackA = L.playAnimation(animAId, animator)
    if trackA then
        task.wait(math.min(trackA.Length or 0.6, 0.6))
        pcall(function() trackA:Stop(0.05) end)
    end
    local trackB = L.playAnimation(animBId, animator)
    task.wait(0.02)
    local function getAimOrigin()
        if player.Character and player.Character.Parent then
            local head = player.Character:FindFirstChild("Head")
            if head and head:IsA("BasePart") then return head.Position end
        end
        local cam = workspace.CurrentCamera
        if cam then return cam.CFrame.Position end
        return nil
    end
    local currentTargetPart = initialPart
    local function isPartVisible(part)
        if not part or not part.Parent or not part:IsA("BasePart") then return false end
        local origin = getAimOrigin()
        if not origin then return false end
        local ok, res = pcall(function() return not L.isObstructedBetween(origin, part.Position, targetModel) end)
        return ok and res
    end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root and targetModel and targetModel.Parent then
        local function getPosFunc()
            if not currentTargetPart or not currentTargetPart.Parent then
                local barrel = targetModel:FindFirstChild("Barrel")
                local head = targetModel:FindFirstChild("Head")
                local torso = targetModel:FindFirstChild("Torso") or targetModel:FindFirstChild("UpperTorso") or targetModel:FindFirstChild("HumanoidRootPart")
                if barrel and isPartVisible(barrel) then currentTargetPart = barrel return barrel.Position end
                if head and isPartVisible(head) then currentTargetPart = head return head.Position end
                if torso and isPartVisible(torso) then currentTargetPart = torso return torso.Position end
                return nil
            end
            if currentTargetPart and currentTargetPart.Parent then return currentTargetPart.Position end
            return nil
        end
        pcall(function() L.smoothLookAtDynamic(root, getPosFunc, L.autoBlackGunSmoothTime) end)
    else
        if trackB then pcall(function() trackB:Stop(0.1) end) end
        return
    end
    local WAIT_TIMEOUT = 3.0
    local waited = 0
    local POLL_INTERVAL = 0.05
    local shotsNow = L.getShotsLoadedForTool(tool)
    while (not shotsNow or shotsNow < 1) and waited < WAIT_TIMEOUT do
        if not tool or not tool.Parent or not tool:IsDescendantOf(player.Character) then
            if trackB then pcall(function() trackB:Stop(0.1) end) end
            return
        end
        if not L.autoBlackGunEnabled then
            if trackB then pcall(function() trackB:Stop(0.1) end) end
            return
        end
        if currentTargetPart and (not isPartVisible(currentTargetPart)) then
            local barrel = targetModel:FindFirstChild("Barrel")
            local head = targetModel:FindFirstChild("Head")
            local torso = targetModel:FindFirstChild("Torso") or targetModel:FindFirstChild("UpperTorso") or targetModel:FindFirstChild("HumanoidRootPart")
            local switched = false
            if barrel and barrel ~= currentTargetPart and isPartVisible(barrel) then currentTargetPart = barrel switched = true
            elseif head and head ~= currentTargetPart and isPartVisible(head) then currentTargetPart = head switched = true
            elseif torso and torso ~= currentTargetPart and isPartVisible(torso) then currentTargetPart = torso switched = true end
            if not switched then
                if trackB then pcall(function() trackB:Stop(0.1) end) end
                return
            end
        end
        task.wait(POLL_INTERVAL)
        waited = waited + POLL_INTERVAL
        shotsNow = L.getShotsLoadedForTool(tool)
    end
    if not shotsNow or shotsNow < 1 then
        if trackB then pcall(function() trackB:Stop(0.1) end) end
        return
    end
    task.wait(0.03)
    if not currentTargetPart or not currentTargetPart.Parent or (not isPartVisible(currentTargetPart)) then
        local barrel = targetModel:FindFirstChild("Barrel")
        local head = targetModel:FindFirstChild("Head")
        local torso = targetModel:FindFirstChild("Torso") or targetModel:FindFirstChild("UpperTorso") or targetModel:FindFirstChild("HumanoidRootPart")
        if barrel and isPartVisible(barrel) then currentTargetPart = barrel
        elseif head and isPartVisible(head) then currentTargetPart = head
        elseif torso and isPartVisible(torso) then currentTargetPart = torso
        else
            if trackB then pcall(function() trackB:Stop(0.1) end) end
            return
        end
    end
    local fireTrack = nil
    if fireAnimId then pcall(function() fireTrack = L.playAnimation(fireAnimId, animator) end) end
    pcall(function()
        local modelRef = char:FindFirstChild("Model") or char
        local t = workspace:GetServerTimeNow()
        remote = remote or tool:FindFirstChild("RemoteEvent")
        if remote and currentTargetPart and currentTargetPart.Parent then
            remote:FireServer("Fire", modelRef, currentTargetPart.Position, t)
        end
    end)
    if fireTrack then task.delay(0.35, function() pcall(function() fireTrack:Stop(0.07) end) end) end
    if trackB then task.wait(0.05) pcall(function() trackB:Stop(0.1) end) end
end

function L.isAnyOtherPlayerNearZombie(zombie, range)
    if not zombie or not zombie:FindFirstChild("HumanoidRootPart") then return false end
    local zombiePos = zombie.HumanoidRootPart.Position
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local playerPos = plr.Character.HumanoidRootPart.Position
            if (playerPos - zombiePos).Magnitude <= range then return true end
        end
    end
    return false
end

function L.processBlackGunShoot()
    if not L.autoBlackGunEnabled then return end
    local equippedTool = player.Character and player.Character:FindFirstChildOfClass("Tool")
    local equippedIsGun = equippedTool and L.isGun(equippedTool)
    local shotsForEquipped = (equippedTool and equippedIsGun) and L.getShotsLoadedForTool(equippedTool) or 0
    local effectiveAutoShoot = (equippedTool ~= nil) and equippedIsGun and (shotsForEquipped >= 1)
    if not effectiveAutoShoot then return end
    local part, model = L.getNearestTargetHeadByMatcher(L.maxTargetRange, ZombieTypeMatchers.Bomber)
    if part and model then
        local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local barrelPos = model:FindFirstChild("HumanoidRootPart") and model.HumanoidRootPart.Position
        if playerRoot and barrelPos then
            local dist = (playerRoot.Position - barrelPos).Magnitude
            if dist > L.autoBlackGunBarrelDistance then return end
        else return end
        if L.isAnyOtherPlayerNearZombie(model, 14) then
            if L.autoBlackGunEquipDelay > 0 then task.wait(L.autoBlackGunEquipDelay) end
            if equippedTool and equippedTool.Parent and model and model.Parent and L.isGun(equippedTool) then
                local currentTool = player.Character and player.Character:FindFirstChildOfClass("Tool")
                if currentTool and currentTool == equippedTool then L.aimThenShootGun(model, part, currentTool) end
            end
        end
    end
end

function L.processAutoShootForType(isEnabled, matcherFunc)
    if not isEnabled then return end
    local equippedTool = player.Character and player.Character:FindFirstChildOfClass("Tool")
    local equippedIsGun = equippedTool and L.isGun(equippedTool)
    local shotsForEquipped = (equippedTool and equippedIsGun) and L.getShotsLoadedForTool(equippedTool) or 0
    local effectiveAutoShoot = isEnabled and (equippedTool ~= nil) and equippedIsGun and (shotsForEquipped >= 1)
    if effectiveAutoShoot then
        local part, model = L.getNearestTargetHeadByMatcher(L.maxTargetRange, matcherFunc)
        if part and model then
            task.wait(0.5)
            if equippedTool and equippedTool.Parent and model and model.Parent and L.isGun(equippedTool) then
                local currentTool = player.Character and player.Character:FindFirstChildOfClass("Tool")
                if currentTool and currentTool == equippedTool then L.aimThenShootGun(model, part, currentTool) end
            end
        end
    end
end

function L.shootingLoop()
    while L.shootingLoopRunning do
        if L.autoShootBomber then L.processAutoShootForType(L.autoShootBomber, ZombieTypeMatchers.Bomber) end
        if L.autoShootCuirassier then L.processAutoShootForType(L.autoShootCuirassier, ZombieTypeMatchers.Cuirassier) end
        if L.autoShootRunner then L.processAutoShootForType(L.autoShootRunner, ZombieTypeMatchers.Runner) end
        if L.autoShootElectrocutioner then L.processAutoShootForType(L.autoShootElectrocutioner, ZombieTypeMatchers.Electrocutioner) end
        if L.autoBlackGunEnabled then L.processBlackGunShoot() end
        task.wait(L.autoBlackGunCooldown)
    end
end

function L.watchShotsForTool(tool)
    if not tool or not L.isGun(tool) then return end
    local function attach(shotsObj, reloadRemote)
        if not shotsObj then return end
        local prevVal = shotsObj.Value or 0
        local reloadDebounce = false
        local conn = shotsObj.Changed:Connect(function()
            local v = shotsObj.Value
            if L.autoReloadEnabled and type(v) == "number" and v == 0 and reloadRemote and not reloadDebounce then
                reloadDebounce = true
                pcall(function() reloadRemote:FireServer("Reload") end)
                task.delay(1.2, function() reloadDebounce = false end)
            end
            prevVal = v
        end)
        tool.AncestryChanged:Connect(function(_, parent) if not parent and conn then conn:Disconnect() end end)
    end
    local shotsInst = tool:FindFirstChild("ShotsLoaded")
    local remoteInst = tool:FindFirstChild("RemoteEvent")
    if shotsInst and (shotsInst:IsA("IntValue") or shotsInst:IsA("NumberValue")) then attach(shotsInst, remoteInst) return end
    local wsPlayersFolder = Workspace:FindFirstChild("Players")
    if not wsPlayersFolder then return end
    local playerFolder = wsPlayersFolder:FindFirstChild(player.Name)
    if not playerFolder then return end
    local toolFolder = playerFolder:FindFirstChild(tool.Name)
    if not toolFolder then return end
    local shots = toolFolder:FindFirstChild("ShotsLoaded")
    local serverRemote = toolFolder:FindFirstChild("RemoteEvent") or remoteInst
    if shots and (shots:IsA("IntValue") or shots:IsA("NumberValue")) then attach(shots, serverRemote) end
end

function L.monitorCharacterTools(char)
    if not char then return end
    for _, c in ipairs(char:GetChildren()) do
        if c:IsA("Tool") and L.isGun(c) then pcall(function() L.watchShotsForTool(c) end) end
    end
    char.ChildAdded:Connect(function(child) if child and child:IsA("Tool") and L.isGun(child) then pcall(function() L.watchShotsForTool(child) end) end end)
end

function L.startShooting()
    if L.shootingThread then return end
    L.shootingLoopRunning = true
    L.shootingThread = task.spawn(L.shootingLoop)
    L.monitorCharacterTools(player.Character)
    player.CharacterAdded:Connect(L.monitorCharacterTools)
end

function L.stopShooting()
    L.shootingLoopRunning = false
    if L.shootingThread then task.cancel(L.shootingThread) L.shootingThread = nil end
end

function L.updateShootingState()
    if L.autoShootBomber or L.autoShootCuirassier or L.autoShootRunner or L.autoShootElectrocutioner or L.autoBlackGunEnabled then
        L.startShooting()
    else L.stopShooting() end
end

local function normalizeAnimId(id)
    if not id then return nil end
    local s = tostring(id)
    if s:match("^%d+$") then return "rbxassetid://" .. s end
    return s
end

local function trackIsTarget(track)
    if not track or not track.IsPlaying then return false end
    local anim = track.Animation
    if not anim or not anim.AnimationId then return false end
    return TARGETS[normalizeAnimId(anim.AnimationId)]
end

local function doJumpAnim()
    if not L.autoJumpAnimHumanoid or not L.autoJumpAnimHumanoid.Parent then return end
    task.spawn(function()
        pcall(function()
            local start = os.clock()
            while os.clock() - start < 1 do
                local state = L.autoJumpAnimHumanoid:GetState()
                if state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.Landed or state == Enum.HumanoidStateType.RunningNoPhysics or state == Enum.HumanoidStateType.Climbing then break end
                task.wait(0.05)
            end
            local root = L.autoJumpAnimHumanoid.RootPart or L.autoJumpAnimHumanoid.Parent:FindFirstChild("HumanoidRootPart")
            if root then
                local gravity = workspace.Gravity
                local jumpVelocity = math.sqrt(2 * gravity * 7.2)
                root.Velocity = Vector3.new(root.Velocity.X, jumpVelocity, root.Velocity.Z)
            end
        end)
    end)
end

local function startAnimMonitoring()
    if L.autoJumpAnimMonitoring then return end
    L.autoJumpAnimMonitoring = true
    task.spawn(function()
        while L.autoJumpAnimMonitoring do
            if L.autoJumpAnimator and L.autoJumpAnimEnabled then
                local ok, tracks = pcall(L.autoJumpAnimator.GetPlayingAnimationTracks, L.autoJumpAnimator)
                if ok and tracks then
                    for _, track in ipairs(tracks) do
                        if trackIsTarget(track) and not L.autoJumpPlayedTracks[track] then
                            L.autoJumpPlayedTracks[track] = true
                            doJumpAnim()
                            track.Stopped:Connect(function() L.autoJumpPlayedTracks[track] = nil end)
                        end
                    end
                end
            end
            task.wait(0.08)
        end
    end)
end

local function stopAnimMonitoring()
    L.autoJumpAnimMonitoring = false
    L.autoJumpPlayedTracks = {}
end

local function refreshAnimCharacter(char)
    L.autoJumpAnimHumanoid = char and char:FindFirstChildOfClass("Humanoid")
    L.autoJumpAnimator = nil
    if L.autoJumpAnimHumanoid then
        L.autoJumpAnimator = L.autoJumpAnimHumanoid:FindFirstChildOfClass("Animator")
        if not L.autoJumpAnimator then
            L.autoJumpAnimator = Instance.new("Animator")
            L.autoJumpAnimator.Name = "AutoJumpAnimator"
            L.autoJumpAnimator.Parent = L.autoJumpAnimHumanoid
        end
    end
    L.autoJumpPlayedTracks = {}
end

function setAutoJumpAnimEnabled(state)
    L.autoJumpAnimEnabled = state
    if state then
        if not L.autoJumpAnimHumanoid then refreshAnimCharacter(player.Character) end
        startAnimMonitoring()
    else stopAnimMonitoring() end
end

refreshAnimCharacter(player.Character)
player.CharacterAdded:Connect(function(char)
    task.wait(0.2)
    refreshAnimCharacter(char)
    if L.autoJumpAnimEnabled then startAnimMonitoring() end
end)

local function doctorRequestHealForPlayer(plr, humanoid)
    if not plr or not humanoid then return end
    local healthPercent = (humanoid.Health / humanoid.MaxHealth) * 100
    if healthPercent > L.doctorThreshold then return end
    local now = tick()
    if (L.doctorLastRequest[plr] or 0) + L.doctorCooldown > now then return end
    L.doctorLastRequest[plr] = now
    local localChar = player.Character
    if not localChar then return end
    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end
    local targetRoot = humanoid.Parent:FindFirstChild("HumanoidRootPart") or humanoid.Parent:FindFirstChild("Torso")
    if not targetRoot then return end
    if (localRoot.Position - targetRoot.Position).Magnitude > L.doctorRange then return end
    local medSupplies = localChar:FindFirstChild("Medical Supplies")
    if not medSupplies then return end
    local remote = medSupplies:FindFirstChild("RemoteEvent")
    if not remote then return end
    pcall(function() remote:FireServer("SendRequest", humanoid) end)
end

local function doctorLoop()
    while L.doctorEnabled do
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then pcall(doctorRequestHealForPlayer, plr, humanoid) end
            end
        end
        task.wait(0.5)
    end
end

local function getPlayerInfectionValue(plr)
    local infection = 0
    pcall(function()
        local wsPlayers = workspace:FindFirstChild("Players")
        if wsPlayers then
            local folder = wsPlayers:FindFirstChild(plr.Name)
            if folder and folder:FindFirstChild("UserStates") then
                local val = folder.UserStates:FindFirstChild("Infected")
                if val then infection = tonumber(val.Value) or 0 return end
            end
        end
        if plr:FindFirstChild("UserStates") then
            local val = plr.UserStates:FindFirstChild("Infected")
            if val then infection = tonumber(val.Value) or 0 end
        end
    end)
    return infection
end

local function getBlessRemote()
    local char = player.Character
    if not char then return nil end
    local tool = char:FindFirstChild("Blessing")
    if tool and tool:FindFirstChild("RemoteEvent") then return tool.RemoteEvent end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") and child.Name:lower():find("bless") and child:FindFirstChild("RemoteEvent") then return child.RemoteEvent end
    end
    return nil
end

local function inBlessRange(plr)
    local localChar = player.Character
    if not localChar then return false end
    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return false end
    if not plr.Character then return false end
    local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChild("Torso")
    if not targetRoot then return false end
    return (localRoot.Position - targetRoot.Position).Magnitude <= L.chaplainRange
end

local function sendBless(plr, humanoid)
    if not plr or not humanoid then return end
    local infection = getPlayerInfectionValue(plr)
    if infection < L.chaplainThreshold then return end
    local now = tick()
    if (L.chaplainLastRequest[plr] or 0) + L.chaplainCooldown > now then return end
    if not inBlessRange(plr) then return end
    local remote = getBlessRemote()
    if not remote then return end
    pcall(function()
        remote:FireServer("SendRequest", humanoid)
        L.chaplainLastRequest[plr] = now
    end)
end

local function chaplainLoop()
    while L.chaplainEnabled do
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then pcall(sendBless, plr, humanoid) end
            end
        end
        task.wait(0.5)
    end
end

local function setFireEnabled(enabled)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") and obj.Name:lower():find("fire") then
            obj.Enabled = enabled
            if not enabled then obj.Rate = 0 else obj.Rate = 20 end
        end
    end
end

local function toggleFixFire(enable)
    if enable then
        setFireEnabled(false)
        if not L.fixFireConn then
            L.fixFireConn = workspace.DescendantAdded:Connect(function(desc)
                if desc:IsA("ParticleEmitter") and desc.Name:lower():find("fire") then
                    desc.Enabled = false
                    desc.Rate = 0
                end
            end)
        end
    else
        if L.fixFireConn then L.fixFireConn:Disconnect() L.fixFireConn = nil end
        setFireEnabled(true)
    end
end

function L.getBarrelZombies()
    local barrels = {}
    local zombiesFolder = Workspace:FindFirstChild("Zombies")
    if not zombiesFolder then return barrels end
    for _, zombie in pairs(zombiesFolder:GetChildren()) do
        if zombie:IsA("Model") and zombie:GetAttribute("Type") == "Barrel" then table.insert(barrels, zombie) end
    end
    return barrels
end

function L.getSphereCenter(zombie)
    local root = zombie:FindFirstChild("HumanoidRootPart") or zombie:FindFirstChild("Torso") or zombie:FindFirstChild("Head")
    if root then return root.Position + Vector3.new(0, Y_OFFSET, 0) end
    return nil
end

function L.createSphere(zombie)
    local center = L.getSphereCenter(zombie)
    if not center then return nil end
    local sphere = Instance.new("Part")
    sphere.Name = "BombRangeSphere"
    sphere.Shape = Enum.PartType.Ball
    sphere.Size = Vector3.new(SPHERE_RADIUS * 2, SPHERE_RADIUS * 2, SPHERE_RADIUS * 2)
    sphere.BrickColor = BrickColor.new(SPHERE_COLOR)
    sphere.Color = SPHERE_COLOR
    sphere.Material = Enum.Material.Neon
    sphere.Transparency = SPHERE_TRANSPARENCY
    sphere.Anchored = true
    sphere.CanCollide = false
    sphere.CanQuery = false
    sphere.CanTouch = false
    sphere.CastShadow = false
    sphere.Position = center
    sphere.Parent = workspace
    return sphere
end

function L.updateSphere(sphere, zombie)
    if not sphere or not zombie then return end
    local center = L.getSphereCenter(zombie)
    if center then
        sphere.Position = center
        if sphere.Size.X ~= SPHERE_RADIUS * 2 then sphere.Size = Vector3.new(SPHERE_RADIUS * 2, SPHERE_RADIUS * 2, SPHERE_RADIUS * 2) end
    end
end

function L.updateAllSpheres()
    if not L.bombRangeEnabled then return end
    local barrels = L.getBarrelZombies()
    local currentBarrelSet = {}
    for _, z in ipairs(barrels) do currentBarrelSet[z] = true end
    for zombie, sphere in pairs(L.bombRangeSpheres) do
        if not zombie.Parent or not currentBarrelSet[zombie] then
            if sphere then sphere:Destroy() end
            L.bombRangeSpheres[zombie] = nil
        end
    end
    for _, zombie in ipairs(barrels) do
        if not L.bombRangeSpheres[zombie] then
            local sphere = L.createSphere(zombie)
            if sphere then L.bombRangeSpheres[zombie] = sphere end
        else L.updateSphere(L.bombRangeSpheres[zombie], zombie) end
    end
end

function L.clearAllSpheres()
    for _, sphere in pairs(L.bombRangeSpheres) do if sphere then sphere:Destroy() end end
    L.bombRangeSpheres = {}
end

function L.getMinDistanceToBarrelCenter()
    local char = player.Character
    if not char then return math.huge end
    local playerPos = char:FindFirstChild("HumanoidRootPart")
    if not playerPos then return math.huge end
    local minDist = math.huge
    local barrels = L.getBarrelZombies()
    for _, zombie in ipairs(barrels) do
        local center = L.getSphereCenter(zombie)
        if center then
            local dist = (center - playerPos.Position).Magnitude
            if dist < minDist then minDist = dist end
        end
    end
    return minDist
end

function L.calculateDamage(distance)
    if distance >= SPHERE_RADIUS then return 0 end
    local factor = 1 - (distance / SPHERE_RADIUS)
    local damage = 10 + (100 - 10) * factor
    return math.floor(damage)
end

function L.updateDamageDisplay()
    if not L.bombRangeEnabled then
        if L.bombRangeDamageDisplay then L.bombRangeDamageDisplay:Destroy() L.bombRangeDamageDisplay = nil end
        return
    end
    local char = player.Character
    if not char then
        if L.bombRangeDamageDisplay then L.bombRangeDamageDisplay:Destroy() L.bombRangeDamageDisplay = nil end
        return
    end
    local minDistance = L.getMinDistanceToBarrelCenter()
    local damage = 0
    if minDistance <= SPHERE_RADIUS then damage = L.calculateDamage(minDistance) end
    if damage > 0 then
        if not L.bombRangeDamageDisplay then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "DamageDisplay"
            billboard.Size = UDim2.new(0, 100, 0, 40)
            billboard.StudsOffset = Vector3.new(0, 2.5, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = char
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextSize = 24
            label.Font = Enum.Font.GothamBold
            label.TextStrokeTransparency = 0.2
            label.TextStrokeColor3 = Color3.fromRGB(0,0,0)
            label.Parent = billboard
            L.bombRangeDamageDisplay = billboard
        end
        local label = L.bombRangeDamageDisplay:FindFirstChildOfClass("TextLabel")
        if label then
            label.Text = tostring(damage)
            if damage <= DAMAGE_THRESHOLD then label.TextColor3 = Color3.fromRGB(255, 255, 0)
            else label.TextColor3 = Color3.fromRGB(255, 0, 0) end
        end
    else
        if L.bombRangeDamageDisplay then L.bombRangeDamageDisplay:Destroy() L.bombRangeDamageDisplay = nil end
    end
end

function L.onBombRangeHeartbeat()
    if not L.bombRangeEnabled then return end
    L.updateAllSpheres()
    L.updateDamageDisplay()
end

function L.startBombRange()
    if L.bombRangeConnection then return end
    L.bombRangeConnection = RunService.Heartbeat:Connect(L.onBombRangeHeartbeat)
end

function L.stopBombRange()
    if L.bombRangeConnection then L.bombRangeConnection:Disconnect() L.bombRangeConnection = nil end
    L.clearAllSpheres()
    if L.bombRangeDamageDisplay then L.bombRangeDamageDisplay:Destroy() L.bombRangeDamageDisplay = nil end
end

function L.findPlayerByText(text)
    text = text:lower()
    for _, plr in pairs(Players:GetPlayers()) do
        if string.find(plr.Name:lower(), text) or string.find(plr.DisplayName:lower(), text) then return plr end
    end
    return nil
end

local chattedConn = player.Chatted:Connect(function(msg)
    if not L.flyOffEnabled then return end
    if msg:sub(1,6):lower() == ";kill " then
        local name = msg:sub(7)
        local plr = L.findPlayerByText(name)
        if plr and plr.Character and plr.Character:FindFirstChild("Humanoid") then
            L.flyOffTarget = plr
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                L.flyOffOriginalCFrame = player.Character.HumanoidRootPart.CFrame
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0) do
        if not L.flyOffEnabled then continue end
        if not L.flyOffTarget then continue end
        local char = L.flyOffTarget.Character
        if not char or not char:FindFirstChild("Humanoid") then L.flyOffTarget = nil continue end
        local hum = char.Humanoid
        if hum.Health <= 0 then L.flyOffTarget = nil continue end
        local myChar = player.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local targetHRP = char:FindFirstChild("HumanoidRootPart")
        if myHRP and targetHRP then
            local offset = targetHRP.Velocity.Magnitude < 0.1 and 0 or 7
            local goal = targetHRP.CFrame * CFrame.new(0,0,-offset) * CFrame.Angles(0, math.rad(-3), 0)
            myHRP.CFrame = myHRP.CFrame:Lerp(goal, 0.4)
            myHRP.Velocity = Vector3.new(0,0,0)
            myHRP.RotVelocity = Vector3.new(0,0,0)
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if not L.flyOffEnabled then continue end
        local hum = player.Character and player.Character:FindFirstChild("Humanoid")
        if hum then hum:Move(Vector3.one * 1e31) end
    end
end)

player.CharacterAdded:Connect(function()
    if L.flyOffEnabled then L.flyOffTarget = nil L.flyOffOriginalCFrame = nil end
end)

function L.getAllParts(model)
    local parts = {}
    for _, descendant in pairs(model:GetDescendants()) do
        if descendant:IsA("BasePart") then table.insert(parts, descendant) end
    end
    return parts
end

function L.setBarrelCollisionEffect(zombie, enabled)
    if not zombie or not zombie.Parent then return end
    if zombie:GetAttribute("Type") ~= "Barrel" and not zombie:FindFirstChild("Barrel") then return end
    local parts = L.getAllParts(zombie)
    for _, part in ipairs(parts) do
        if enabled then
            if L.barrelOriginalCollisionStates[part] == nil then L.barrelOriginalCollisionStates[part] = part.CanCollide end
            if L.barrelOriginalQueryStates[part] == nil then L.barrelOriginalQueryStates[part] = part.CanQuery end
            part.CanCollide = false
            part.CanQuery = false
        else
            if L.barrelOriginalCollisionStates[part] ~= nil then part.CanCollide = L.barrelOriginalCollisionStates[part] else part.CanCollide = true end
            if L.barrelOriginalQueryStates[part] ~= nil then part.CanQuery = L.barrelOriginalQueryStates[part] else part.CanQuery = true end
        end
    end
end

function L.applyToAllBarrels(disable)
    local zombiesFolder = Workspace:FindFirstChild("Zombies")
    if not zombiesFolder then return end
    for _, zombie in pairs(zombiesFolder:GetChildren()) do
        if zombie:IsA("Model") and (zombie:GetAttribute("Type") == "Barrel" or zombie:FindFirstChild("Barrel")) then
            L.setBarrelCollisionEffect(zombie, disable)
        end
    end
end

function L.onBarrelZombieAdded(zombie)
    if L.barrelCollisionRemovalActive and zombie:IsA("Model") and (zombie:GetAttribute("Type") == "Barrel" or zombie:FindFirstChild("Barrel")) then
        L.setBarrelCollisionEffect(zombie, true)
    end
end

function L.startBarrelCollisionRemoval()
    if L.barrelCollisionRemovalConn then L.barrelCollisionRemovalConn:Disconnect() end
    L.barrelCollisionRemovalConn = Workspace.DescendantAdded:Connect(function(desc)
        if desc:IsA("Model") and desc.Parent and desc.Parent.Name == "Zombies" then L.onBarrelZombieAdded(desc) end
    end)
    L.applyToAllBarrels(true)
end

function L.stopBarrelCollisionRemoval()
    if L.barrelCollisionRemovalConn then L.barrelCollisionRemovalConn:Disconnect() L.barrelCollisionRemovalConn = nil end
    L.applyToAllBarrels(false)
    L.barrelOriginalCollisionStates = {}
    L.barrelOriginalQueryStates = {}
end

local function teleportTo(position)
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local adjustedPos = position + Vector3.new(0, 2.5, 0)
        rootPart.CFrame = CFrame.new(adjustedPos)
    end
end

local function createTeleportUI()
    if L.teleportScreenGui then L.teleportScreenGui:Destroy() end
    L.teleportScreenGui = Instance.new("ScreenGui")
    L.teleportScreenGui.Name = "TeleportGUI"
    L.teleportScreenGui.ResetOnSpawn = false
    L.teleportScreenGui.Parent = pgui
    L.teleportButton = Instance.new("TextButton")
    L.teleportButton.Size = UDim2.new(0, 60, 0, 60)
    L.teleportButton.Position = UDim2.new(0.5, -30, 0.3, 0)
    L.teleportButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    L.teleportButton.BackgroundTransparency = 0.2
    L.teleportButton.BorderSizePixel = 0
    L.teleportButton.Text = "关"
    L.teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    L.teleportButton.TextSize = 24
    L.teleportButton.Font = Enum.Font.GothamBold
    L.teleportButton.Parent = L.teleportScreenGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = L.teleportButton
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 200, 255)
    stroke.Thickness = 2.5
    stroke.Transparency = 0.3
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = L.teleportButton
    L.teleportButton.Active = true
    L.teleportButton.Draggable = true
    L.teleportActive = false
    L.teleportButton.MouseButton1Click:Connect(function()
        L.teleportActive = not L.teleportActive
        if L.teleportActive then
            L.teleportButton.Text = "开"
            L.teleportButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
            if not L.teleportClickConnection then
                L.teleportClickConnection = mouse.Button1Down:Connect(function()
                    if L.teleportActive then
                        local clickPos = mouse.Hit.p
                        if clickPos then teleportTo(clickPos) end
                    end
                end)
            end
        else
            L.teleportButton.Text = "关"
            L.teleportButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            if L.teleportClickConnection then L.teleportClickConnection:Disconnect() L.teleportClickConnection = nil end
        end
    end)
end

local function destroyTeleportUI()
    if L.teleportScreenGui then L.teleportScreenGui:Destroy() L.teleportScreenGui = nil end
    if L.teleportClickConnection then L.teleportClickConnection:Disconnect() L.teleportClickConnection = nil end
    L.teleportActive = false
    L.teleportButton = nil
end

local function safeDestroy(obj)
    if obj and obj.Parent then pcall(function() obj:Destroy() end) end
end

local function addHitboxesToZombie(zombie)
    if not zombie or not zombie.Parent then return end
    if L.hitboxAddedParts[zombie] then return end
    local hrp = zombie:FindFirstChild("HumanoidRootPart")
    local head = zombie:FindFirstChild("Head")
    if not hrp or not head then return end
    local outer = Instance.new("Part")
    outer.Name = "Ziaan_OuterHitbox"
    outer.Size = Vector3.new(L.hitboxSize, L.hitboxSize, L.hitboxSize)
    outer.Transparency = 1
    outer.CanCollide = false
    outer.CanTouch = true
    outer.Massless = true
    outer.Anchored = false
    outer.CFrame = hrp.CFrame
    outer.Parent = zombie
    local weldOuter = Instance.new("WeldConstraint")
    weldOuter.Part0 = hrp
    weldOuter.Part1 = outer
    weldOuter.Parent = outer
    local headBox = Instance.new("Part")
    headBox.Name = "Ziaan_HeadHitbox"
    headBox.Size = Vector3.new(L.hitboxSize/2, L.hitboxSize/2, L.hitboxSize/2)
    headBox.Transparency = 1
    headBox.CanCollide = false
    headBox.CanTouch = true
    headBox.Massless = true
    headBox.Anchored = false
    headBox.CFrame = head.CFrame
    headBox.Parent = zombie
    local weldHead = Instance.new("WeldConstraint")
    weldHead.Part0 = head
    weldHead.Part1 = headBox
    weldHead.Parent = headBox
    L.hitboxAddedParts[zombie] = { outer = outer, head = headBox }
end

local function removeHitboxesFromZombie(zombie)
    local parts = L.hitboxAddedParts[zombie]
    if parts then
        safeDestroy(parts.outer)
        safeDestroy(parts.head)
        L.hitboxAddedParts[zombie] = nil
    else
        for _, child in ipairs(zombie:GetChildren()) do
            if child.Name == "Ziaan_OuterHitbox" or child.Name == "Ziaan_HeadHitbox" then safeDestroy(child) end
        end
    end
end

local function refreshAllHitboxes()
    if not L.hitboxEnabled then return end
    for zombie, _ in pairs(L.hitboxAddedParts) do removeHitboxesFromZombie(zombie) end
    local allZombies = {}
    if L.hitboxZombiesFolder then
        for _, z in ipairs(L.hitboxZombiesFolder:GetChildren()) do
            if z:IsA("Model") and z.Name == "m_Zombie" then table.insert(allZombies, z) end
        end
    end
    if L.hitboxCameraFolder then
        for _, z in ipairs(L.hitboxCameraFolder:GetChildren()) do
            if z:IsA("Model") and z.Name == "m_Zombie" then table.insert(allZombies, z) end
        end
    end
    for _, z in ipairs(allZombies) do addHitboxesToZombie(z) end
end

local function disableHitboxExpander()
    L.hitboxEnabled = false
    for zombie, _ in pairs(L.hitboxAddedParts) do removeHitboxesFromZombie(zombie) end
    L.hitboxAddedParts = {}
end

local function enableHitboxExpander()
    if L.hitboxEnabled then return end
    L.hitboxEnabled = true
    refreshAllHitboxes()
end

local function setHitboxSize(newSize)
    L.hitboxSize = math.clamp(newSize, 1, 30)
    if L.hitboxEnabled then refreshAllHitboxes() end
end

local function onZombieAdded(zombie)
    if L.hitboxEnabled and zombie:IsA("Model") and zombie.Name == "m_Zombie" then
        task.wait(0.1)
        addHitboxesToZombie(zombie)
    end
end

if L.hitboxZombiesFolder then L.hitboxZombiesFolder.ChildAdded:Connect(onZombieAdded) end
if L.hitboxCameraFolder then L.hitboxCameraFolder.ChildAdded:Connect(onZombieAdded) end
local AnimationController = {
    ActiveButtons = {},
    DefaultAnimations = {},
    Character = nil,
    Humanoid = nil,
    Animator = nil,
    IsInitialized = false,
}

AnimationController.MainButtonConfigs = {
    { Name = "远古ZAPPER动画", IdleId = "12333488814", WalkId = "12333490576", Priority = Enum.AnimationPriority.Action2 },
    { Name = "超人", IdleId = "123279433658792", WalkId = "123279433658792", Priority = Enum.AnimationPriority.Action3, Callback = function(state) if state then AnimationController.Humanoid.WalkSpeed = 50 else AnimationController.Humanoid.WalkSpeed = 16 end end },
    { Name = "ZAPPER动画", IdleId = "14498563473", WalkId = "14498289874", Priority = Enum.AnimationPriority.Action3 },
    { Name = "ZAPPER特效", PlayOnceId = "14499470197", Priority = Enum.AnimationPriority.Action4 },
    { Name = "装死", PlayOnceId = "89945348540089", Priority = Enum.AnimationPriority.Action4 },
    { Name = "山伯乐吃播", PlayOnceId = "18339432914", StopAfter = 10, Priority = Enum.AnimationPriority.Action4 },
    { Name = "是多绝望的人能跳出这个舞步", PlayOnceId = "14860627011", StopAfter = 20, Priority = Enum.AnimationPriority.Action4 },
    { Name = "红眼", IdleId = "12581784105", WalkId = "12581785298", Priority = Enum.AnimationPriority.Action3, Callback = function(state) if state then AnimationController.Humanoid.WalkSpeed = 50 else AnimationController.Humanoid.WalkSpeed = 16 end end },
    { Name = "山伯乐动画", IdleId = "12333488814", WalkId = "14463730540", Priority = Enum.AnimationPriority.Action3 },
    { Name = "提灯人", IdleId = "14678879479", WalkId = "14678880308", Priority = Enum.AnimationPriority.Action3 },
    { Name = "无头士兵（美国）", IdleId = "107080941320600", WalkId = "74764025513892", Priority = Enum.AnimationPriority.Action3 },
    { Name = "胸甲僵尸", IdleId = "87579228279296", WalkId = "102081698785465", Priority = Enum.AnimationPriority.Action3 },
    { Name = "骑兵动画（刺）", Callback = function(state) end },
    { Name = "滑膛枪冲锋", IdleId = "14292935158", WalkId = "14292937831", Priority = Enum.AnimationPriority.Action3, Callback = function(state) if state then AnimationController.Humanoid.WalkSpeed = 24 else AnimationController.Humanoid.WalkSpeed = 16 end end },
    { Name = "重剑冲锋", IdleId = "14284611111", WalkId = "17406602570", Priority = Enum.AnimationPriority.Action3, Callback = function(state) if state then AnimationController.Humanoid.WalkSpeed = 24 else AnimationController.Humanoid.WalkSpeed = 16 end end },
    { Name = "自爆", IdleId = "13211198049", WalkId = "13211207597", Priority = Enum.AnimationPriority.Action3 },
    { Name = "爬尸", IdleId = "13726632691", WalkId = "13726634549", SitId = "130515356351734", Priority = Enum.AnimationPriority.Action3 },
}

AnimationController.SideButtonConfigs = {
    { Name = "拿破仑背手", IdleId = "103557875332543", WalkId = "103557875332543", Priority = Enum.AnimationPriority.Action4 },
    { Name = "寒冷", IdleId = "16863977222", WalkId = "16876434500", Priority = Enum.AnimationPriority.Action3 },
    { Name = "胸甲僵尸动画2", IdleId = "82800474630427", WalkId = "118210337289087", Priority = Enum.AnimationPriority.Action3 },
    { Name = "克劳福德", PlayOnceId = "77859967130018", Priority = Enum.AnimationPriority.Action4 },
    { Name = "十字架使用", PlayOnceId = "15210536563", Priority = Enum.AnimationPriority.Action4 },
    { Name = "雅各布", PlayOnceId = "12404717502", Priority = Enum.AnimationPriority.Action4 },
    { Name = "僵尸王", PlayOnceId = "13408244121", Priority = Enum.AnimationPriority.Action4 },
    { Name = "僵尸扒门", PlayOnceId = "15593727441", Priority = Enum.AnimationPriority.Action4 }
}

function AnimationController:RestoreDefaults()
    if self.Humanoid then
        self.Humanoid.WalkSpeed = 16
        if self.DefaultAnimations.Walk and not self.DefaultAnimations.Walk.IsPlaying then self.DefaultAnimations.Walk:Play() end
        if self.DefaultAnimations.Idle and not self.DefaultAnimations.Idle.IsPlaying then self.DefaultAnimations.Idle:Play() end
    end
end

function AnimationController:ToggleAnimation(config, buttonData, state)
    buttonData.IsActive = state
    if buttonData.IsActive then
        if not next(buttonData.Tracks) then
            if config.IdleId then
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://"..config.IdleId
                buttonData.Tracks.Idle = self.Animator:LoadAnimation(anim)
                buttonData.Tracks.Idle.Priority = config.Priority or Enum.AnimationPriority.Action4
            end
            if config.WalkId then
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://"..config.WalkId
                buttonData.Tracks.Walk = self.Animator:LoadAnimation(anim)
                buttonData.Tracks.Walk.Priority = config.Priority or Enum.AnimationPriority.Action4
            end
            if config.SitId then
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://"..config.SitId
                buttonData.Tracks.Sit = self.Animator:LoadAnimation(anim)
                buttonData.Tracks.Sit.Priority = config.Priority or Enum.AnimationPriority.Action2
                buttonData.Tracks.Sit.Looped = true
            end
            if config.PlayOnceId then
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://"..config.PlayOnceId
                buttonData.Tracks.PlayOnce = self.Animator:LoadAnimation(anim)
                buttonData.Tracks.PlayOnce.Priority = config.Priority or Enum.AnimationPriority.Action
                buttonData.Tracks.PlayOnce.Looped = false
            end
        end
        if config.PlayOnceId then
            if buttonData.Tracks.PlayOnce then
                buttonData.Tracks.PlayOnce:Play()
                if config.Callback then config.Callback(true) end
            end
        else
            if buttonData.Tracks.Sit then buttonData.Tracks.Sit:Play() end
            if self.Humanoid.MoveDirection.Magnitude > 0 then
                if buttonData.Tracks.Walk then buttonData.Tracks.Walk:Play() end
            else
                if buttonData.Tracks.Idle then buttonData.Tracks.Idle:Play() end
            end
            buttonData.Connections.Movement = self.Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
                if self.Humanoid.MoveDirection.Magnitude > 0 then
                    if buttonData.Tracks.Walk and not buttonData.Tracks.Walk.IsPlaying then buttonData.Tracks.Walk:Play() end
                    if buttonData.Tracks.Idle and buttonData.Tracks.Idle.IsPlaying then buttonData.Tracks.Idle:Stop() end
                else
                    if buttonData.Tracks.Idle and not buttonData.Tracks.Idle.IsPlaying then buttonData.Tracks.Idle:Play() end
                    if buttonData.Tracks.Walk and buttonData.Tracks.Walk.IsPlaying then buttonData.Tracks.Walk:Stop() end
                end
            end)
        end
        if config.Callback then config.Callback(true) end
    else
        for _, track in pairs(buttonData.Tracks) do if track then track:Stop() end end
        for _, conn in pairs(buttonData.Connections) do conn:Disconnect() end
        buttonData.Connections = {}
        if config.Callback then config.Callback(false) end
        self:RestoreDefaults()
    end
end

function AnimationController:Initialize()
    self.Character = player.Character or player.CharacterAdded:Wait()
    self.Humanoid = self.Character:WaitForChild("Humanoid")
    self.Animator = self.Humanoid:WaitForChild("Animator")
    self.DefaultAnimations = {}
    for _, track in pairs(self.Humanoid:GetPlayingAnimationTracks()) do
        if track.Name == "IdleAnimation" then self.DefaultAnimations.Idle = track
        elseif track.Name == "Walk" then self.DefaultAnimations.Walk = track end
    end
    self.Humanoid.Died:Connect(function() self:RestoreDefaults() end)
    self.IsInitialized = true
end

player.CharacterAdded:Connect(function() task.wait(1) AnimationController:Initialize() end)
if player.Character then AnimationController:Initialize() end

function AnimationController.CreateCannonHighlights()
    L.cannonHighlightEnabled = true
    L.cannonHighlights = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name:lower():find("cannon") or obj.Name:lower():find("artillery")) then
            local hl = Instance.new("Highlight")
            hl.Adornee = obj
            hl.FillColor = Color3.fromRGB(255, 200, 0)
            hl.OutlineColor = Color3.fromRGB(255, 150, 0)
            hl.Parent = obj
            table.insert(L.cannonHighlights, hl)
        end
    end
end

function AnimationController.RemoveCannonHighlights()
    L.cannonHighlightEnabled = false
    for _, hl in ipairs(L.cannonHighlights) do if hl then hl:Destroy() end end
    L.cannonHighlights = {}
end

local function loadOriginalFlight()
    if pgui:FindFirstChild("OriginalFlightUI") then pgui.OriginalFlightUI:Destroy() end
    local ControlModule = require(player.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
    local FlightSystem = {}
    FlightSystem.__index = FlightSystem
    function FlightSystem.new()
        local self = setmetatable({}, FlightSystem)
        self.isFlying = false
        self.flySpeed = 40
        self.bv = nil
        self.animCache = nil
        self.hrp = nil
        self.hum = nil
        return self
    end
    function FlightSystem:clearResources()
        local char = player.Character
        if self.animCache and char then self.animCache.Parent = char end
        if self.bv then self.bv:Destroy() end
        self.bv = nil
        if self.hum and self.hum.Parent then self.hum:ChangeState(Enum.HumanoidStateType.Running) end
    end
    function FlightSystem:startFly()
        if self.isFlying then return end
        local char = player.Character
        if not char then return end
        self.hrp = char:WaitForChild("HumanoidRootPart")
        self.hum = char:WaitForChild("Humanoid")
        local ani = char:FindFirstChild("Animate")
        if ani then self.animCache = ani ani.Parent = nil end
        if self.hrp:FindFirstChild("LeipzigBV") then self.hrp.LeipzigBV:Destroy() end
        self.bv = Instance.new("BodyVelocity", self.hrp)
        self.bv.Name = "LeipzigBV"
        self.bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        self.isFlying = true
        task.spawn(function()
            while self.isFlying and char.Parent do
                local mv = ControlModule:GetMoveVector()
                local cf = camera.CFrame
                local dir = (cf.LookVector * -mv.Z) + (cf.RightVector * mv.X)
                if mv.Magnitude > 0 then self.bv.Velocity = dir.Unit * self.flySpeed
                else self.bv.Velocity = Vector3.new(0, 0.01, 0) end
                self.hum:ChangeState(Enum.HumanoidStateType.Climbing)
                RunService.RenderStepped:Wait()
            end
            self:clearResources()
        end)
    end
    function FlightSystem:stopFly()
        if not self.isFlying then return end
        self.isFlying = false
        self:clearResources()
    end
    function FlightSystem:setSpeed(speed) self.flySpeed = math.clamp(speed, 10, 100) end
    local flight = FlightSystem.new()
    local function bindCharacter()
        local char = player.Character or player.CharacterAdded:Wait()
        flight.hrp = char:WaitForChild("HumanoidRootPart")
        flight.hum = char:WaitForChild("Humanoid")
        flight:clearResources()
        char.AncestryChanged:Connect(function(_, parent) if not parent then flight:clearResources() bindCharacter() end end)
    end
    bindCharacter()
    local UI_BG = Color3.fromRGB(200, 230, 255)
    local BTN_OFF = Color3.fromRGB(150, 200, 255)
    local BTN_ON = Color3.fromRGB(70, 150, 255)
    local DESTROY_BTN = Color3.fromRGB(110, 180, 255)
    local TEXT_COLOR = Color3.fromRGB(0, 60, 120)
    local SPEED_BG = Color3.fromRGB(180, 220, 255)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "OriginalFlightUI"
    ScreenGui.Parent = pgui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 999
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 150, 0, 145)
    MainFrame.Position = UDim2.new(0.5, -75, 0.3, 0)
    MainFrame.BackgroundColor3 = UI_BG
    MainFrame.BackgroundTransparency = 0.4
    MainFrame.Draggable = true
    MainFrame.Active = true
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", MainFrame)
    stroke.Color = Color3.fromRGB(120, 200, 255)
    stroke.Thickness = 3
    stroke.Transparency = 0.1
    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(1,0,0,20)
    Title.BackgroundTransparency = 1
    Title.Text = "飞行-无相机锁定"
    Title.TextColor3 = TEXT_COLOR
    Title.TextSize = 12
    Title.Font = Enum.Font.GothamBold
    local Tip = Instance.new("TextLabel", MainFrame)
    Tip.Size = UDim2.new(1,0,0,14)
    Tip.Position = UDim2.new(0,0,0,20)
    Tip.BackgroundTransparency = 1
    Tip.Text = "[无穿墙]"
    Tip.TextColor3 = Color3.new(0.9,0,0)
    Tip.TextSize = 8
    local SpeedInput = Instance.new("TextBox", MainFrame)
    SpeedInput.Size = UDim2.new(0,120,0,24)
    SpeedInput.Position = UDim2.new(0.5,-60,0, 38)
    SpeedInput.BackgroundColor3 = SPEED_BG
    SpeedInput.BackgroundTransparency = 0.3
    SpeedInput.Text = tostring(flight.flySpeed)
    SpeedInput.TextColor3 = TEXT_COLOR
    SpeedInput.TextSize = 11
    Instance.new("UICorner", SpeedInput).CornerRadius = UDim.new(0,7)
    local FlyBtn = Instance.new("TextButton", MainFrame)
    FlyBtn.Size = UDim2.new(0,120,0,26)
    FlyBtn.Position = UDim2.new(0.5,-60,0, 72)
    FlyBtn.BackgroundColor3 = BTN_OFF
    FlyBtn.BackgroundTransparency = 0.3
    FlyBtn.Text = "飞行"
    FlyBtn.TextColor3 = TEXT_COLOR
    FlyBtn.TextSize = 11
    Instance.new("UICorner", FlyBtn).CornerRadius = UDim.new(0,8)
    local DestroyUI = Instance.new("TextButton", MainFrame)
    DestroyUI.Size = UDim2.new(0,120,0,26)
    DestroyUI.Position = UDim2.new(0.5,-60,0, 108)
    DestroyUI.BackgroundColor3 = DESTROY_BTN
    DestroyUI.BackgroundTransparency = 0.3
    DestroyUI.Text = "销毁UI"
    DestroyUI.TextColor3 = TEXT_COLOR
    DestroyUI.TextSize = 11
    Instance.new("UICorner", DestroyUI).CornerRadius = UDim.new(0,8)
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    SpeedInput.FocusLost:Connect(function()
        local val = tonumber(SpeedInput.Text)
        if val then flight:setSpeed(val) else flight:setSpeed(40) end
        SpeedInput.Text = tostring(flight.flySpeed)
    end)
    FlyBtn.MouseButton1Click:Connect(function()
        if flight.isFlying then
            flight:stopFly()
            FlyBtn.Text = "飞行"
            FlyBtn.BackgroundColor3 = BTN_OFF
        else
            flight:startFly()
            FlyBtn.Text = "飞行开"
            FlyBtn.BackgroundColor3 = BTN_ON
        end
    end)
    DestroyUI.MouseButton1Click:Connect(function()
        flight:stopFly()
        ScreenGui:Destroy()
    end)
    MainFrame.Size = UDim2.new(0,0,0,0)
    MainFrame:TweenSize(UDim2.new(0,150,0,145), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.4, true)
end

local function loadNewFlight()
    if pgui:FindFirstChild("NewFlightUI") then pgui.NewFlightUI:Destroy() end
    task.wait(0.1)
    local UI_BG = Color3.fromRGB(200, 230, 255)
    local BTN_OFF = Color3.fromRGB(150, 200, 255)
    local BTN_ON = Color3.fromRGB(70, 150, 255)
    local DESTROY_BTN = Color3.fromRGB(110, 180, 255)
    local TEXT_COLOR = Color3.fromRGB(0, 60, 120)
    local SPEED_BG = Color3.fromRGB(180, 220, 255)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NewFlightUI"
    ScreenGui.Parent = pgui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 999
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 150, 0, 160)
    MainFrame.Position = UDim2.new(0.5, -75, 0.3, 0)
    MainFrame.BackgroundColor3 = UI_BG
    MainFrame.BackgroundTransparency = 0.4
    MainFrame.Draggable = true
    MainFrame.Active = true
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", MainFrame)
    stroke.Color = Color3.fromRGB(120, 200, 255)
    stroke.Thickness = 3
    stroke.Transparency = 0.1
    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(1,0,0,20)
    Title.BackgroundTransparency = 1
    Title.Text = "飞行-优化"
    Title.TextColor3 = TEXT_COLOR
    Title.TextSize = 12
    Title.Font = Enum.Font.GothamBold
    local SpeedInput = Instance.new("TextBox", MainFrame)
    SpeedInput.Size = UDim2.new(0,120,0,24)
    SpeedInput.Position = UDim2.new(0.5,-60,0, 30)
    SpeedInput.BackgroundColor3 = SPEED_BG
    SpeedInput.BackgroundTransparency = 0.3
    SpeedInput.Text = "40"
    SpeedInput.TextColor3 = TEXT_COLOR
    SpeedInput.TextSize = 11
    Instance.new("UICorner", SpeedInput).CornerRadius = UDim.new(0,7)
    local WallhackBtn = Instance.new("TextButton", MainFrame)
    WallhackBtn.Size = UDim2.new(0,120,0,26)
    WallhackBtn.Position = UDim2.new(0.5,-60,0, 64)
    WallhackBtn.BackgroundColor3 = BTN_OFF
    WallhackBtn.BackgroundTransparency = 0.3
    WallhackBtn.Text = "穿墙模式: 关闭"
    WallhackBtn.TextColor3 = TEXT_COLOR
    WallhackBtn.TextSize = 11
    Instance.new("UICorner", WallhackBtn).CornerRadius = UDim.new(0,8)
    local FlyBtn = Instance.new("TextButton", MainFrame)
    FlyBtn.Size = UDim2.new(0,120,0,26)
    FlyBtn.Position = UDim2.new(0.5,-60,0, 98)
    FlyBtn.BackgroundColor3 = BTN_OFF
    FlyBtn.BackgroundTransparency = 0.3
    FlyBtn.Text = "飞行"
    FlyBtn.TextColor3 = TEXT_COLOR
    FlyBtn.TextSize = 11
    Instance.new("UICorner", FlyBtn).CornerRadius = UDim.new(0,8)
    local DestroyUI = Instance.new("TextButton", MainFrame)
    DestroyUI.Size = UDim2.new(0,120,0,26)
    DestroyUI.Position = UDim2.new(0.5,-60,0, 132)
    DestroyUI.BackgroundColor3 = DESTROY_BTN
    DestroyUI.BackgroundTransparency = 0.3
    DestroyUI.Text = "销毁UI"
    DestroyUI.TextColor3 = TEXT_COLOR
    DestroyUI.TextSize = 11
    Instance.new("UICorner", DestroyUI).CornerRadius = UDim.new(0,8)
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    SpeedInput.FocusLost:Connect(function()
        local val = tonumber(SpeedInput.Text)
        if val then L.flySpeed_new = math.clamp(val, 10, 100) else L.flySpeed_new = 40 end
        SpeedInput.Text = tostring(L.flySpeed_new)
    end)
    WallhackBtn.MouseButton1Click:Connect(function()
        L.isWallhack_new = not L.isWallhack_new
        WallhackBtn.Text = "穿墙模式: " .. (L.isWallhack_new and "开启" or "关闭")
        WallhackBtn.BackgroundColor3 = L.isWallhack_new and BTN_ON or BTN_OFF
        if L.isFlying_new then
            L.stopFly_new()
            task.wait(0.05)
            L.startFly_new()
        else L.applyWallhackState_new() end
    end)
    FlyBtn.MouseButton1Click:Connect(function()
        if L.isFlying_new then
            L.stopFly_new()
            FlyBtn.Text = "飞行"
            FlyBtn.BackgroundColor3 = BTN_OFF
        else
            L.startFly_new()
            FlyBtn.Text = "飞行开"
            FlyBtn.BackgroundColor3 = BTN_ON
        end
    end)
    DestroyUI.MouseButton1Click:Connect(function()
        L.stopFly_new()
        L.applyWallhackState_new()
        ScreenGui:Destroy()
    end)
    MainFrame.Size = UDim2.new(0,0,0,0)
    MainFrame:TweenSize(UDim2.new(0,150,0,160), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.4, true)
end

local MainLeft = Tabs.Main:AddLeftGroupbox("移动")
MainLeft:AddToggle("速度调整", { Text = "速度调整", Default = false, Callback = function(state) setWalkSpeedEnabled(state) end })
MainLeft:AddSlider("速度值", { Text = "速度值", Default = 25, Min = 16, Max = 45, Rounding = 0, Callback = function(value) setWalkSpeedValue(value) end })
MainLeft:AddToggle("无限连跳", { Text = "无限连跳", Default = false, Callback = function(state) L.jumpModEnabled = state L.antiFallEnabled = state if state then L.startAntiFall() else L.stopAntiFall() end end })
MainLeft:AddSlider("跳跃高度", { Text = "跳跃高度", Default = 60, Min = 30, Max = 90, Rounding = 0, Callback = function(value) L.jumpHeight = value end })
MainLeft:AddToggle("无减速", { Text = "无减速", Default = false, Callback = function(state)
    L.minorFeatures.noSlow.active = state
    if state then
        L.setupNoSlow()
        L.minorFeatures.noSlow.charAddedConn = player.CharacterAdded:Connect(function() task.wait(1) L.setupNoSlow() end)
    else
        if L.minorFeatures.noSlow.walkSpeedConn then L.minorFeatures.noSlow.walkSpeedConn:Disconnect() end
        if L.minorFeatures.noSlow.charAddedConn then L.minorFeatures.noSlow.charAddedConn:Disconnect() end
    end
end })
MainLeft:AddToggle("移除摔伤", { Text = "移除摔伤", Default = false, Callback = function(state)
    L.minorFeatures.noFall.active = state
    if state then L.minorFeatures.noFall.connection = task.spawn(L.preventFallDamage)
    else if L.minorFeatures.noFall.connection then task.cancel(L.minorFeatures.noFall.connection) end end
end })
MainLeft:AddToggle("自动跳跃", { Text = "自动跳跃", Default = false, Callback = function(state)
    L.autoJumpEnabled = state
    if state then L.startAutoJump() else L.stopAutoJump() end
end })
MainLeft:AddSlider("自动跳跃高度", { Text = "自动跳跃高度", Default = 60, Min = 30, Max = 60, Rounding = 0, Callback = function(value) L.autoJumpHeight = value end })
MainLeft:AddToggle("自动转向僵尸", { Text = "自动转向僵尸", Default = false, Callback = function(state)
    L.autoFaceEnabled = state
    if state then L.startAutoFace() else L.stopAutoFace() end
end })
MainLeft:AddSlider("转向范围", { Text = "转向范围", Default = 17, Min = 5, Max = 30, Rounding = 0, Callback = function(value) L.autoFaceRange = value end })
MainLeft:AddToggle("跳过自爆", { Text = "跳过自爆", Default = false, Callback = function(state) L.skipBarrel = state end })

local MainRight = Tabs.Main:AddRightGroupbox("飞行")
MainRight:AddButton("飞行-无相机锁定", function() loadOriginalFlight() end)
MainRight:AddButton("飞行-优化", function() loadNewFlight() end)

local MainAuto = Tabs.Main:AddLeftGroupbox("自动化")
MainAuto:AddToggle("自动挖雪", { Text = "自动挖雪", Default = false, Callback = function(state)
    L.autoFeatures.autoDig = state
    if state then L.autoFeatures.autoDigConnection = task.spawn(L.autoDigLoop)
    else if L.autoFeatures.autoDigConnection then task.cancel(L.autoFeatures.autoDigConnection) end end
end })
MainAuto:AddToggle("自动拿木头", { Text = "自动拿木头", Default = false, Callback = function(state)
    L.autoFeatures.autoLog = state
    if state then
        L.autoFeatures.autoLogConnection = task.spawn(function()
            while L.autoFeatures.autoLog do
                local remoteEvent = workspace:FindFirstChild("Berezina") and workspace.Berezina:FindFirstChild("Modes") and workspace.Berezina.Modes:FindFirstChild("Holdout") and workspace.Berezina.Modes.Holdout:FindFirstChild("Log") and workspace.Berezina.Modes.Holdout.Log:FindFirstChild("Log") and workspace.Berezina.Modes.Holdout.Log.Log:FindFirstChild("Interact")
                if remoteEvent and remoteEvent:IsA("RemoteEvent") then pcall(function() remoteEvent:FireServer() end) end
                task.wait(0.05)
            end
        end)
    else if L.autoFeatures.autoLogConnection then task.cancel(L.autoFeatures.autoLogConnection) end end
end })
MainAuto:AddToggle("自动放置木头", { Text = "自动放置木头", Default = false, Callback = function(state)
    L.autoFeatures.autoPlace = state
    if state then
        L.autoFeatures.autoPlaceConnection = task.spawn(function()
            while L.autoFeatures.autoPlace do
                for _, prompt in pairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Name == "PlaceLogProximityPrompt" then
                        pcall(function() fireproximityprompt(prompt) end)
                    end
                end
                task.wait(0.1)
            end
        end)
    else if L.autoFeatures.autoPlaceConnection then task.cancel(L.autoFeatures.autoPlaceConnection) end end
end })
MainAuto:AddToggle("自动修桥", { Text = "自动修桥", Default = false, Callback = function(state)
    L.autoFeatures.autoRepairBridge = state
    if state then L.autoFeatures.autoRepairBridgeConnection = RunService.Heartbeat:Connect(L.doRepairBridge)
    else if L.autoFeatures.autoRepairBridgeConnection then L.autoFeatures.autoRepairBridgeConnection:Disconnect() end end
end })
MainAuto:AddToggle("自动收集", { Text = "自动收集", Default = false, Callback = function(state)
    L.autoFeatures.autoCollectKaub = state
    if state then
        local conn = L.setupKaubAutoCollect()
        L.autoFeatures.autoCollectKaubDescendantConn = conn
    else
        if L.autoFeatures.autoCollectKaubConnection then L.autoFeatures.autoCollectKaubConnection:Disconnect() end
        if L.autoFeatures.autoCollectKaubDescendantConn then L.autoFeatures.autoCollectKaubDescendantConn:Disconnect() end
        L.autoFeatures.autoCollectKaubPrompts = {}
    end
end })
MainAuto:AddToggle("自动开门", { Text = "自动开门", Default = false, Callback = function(state)
    L.autoDoorEnabled = state
    if state then
        if L.autoDoorThread then task.cancel(L.autoDoorThread) end
        L.autoDoorThread = task.spawn(L.autoDoorLoop)
    else
        if L.autoDoorThread then task.cancel(L.autoDoorThread) L.autoDoorThread = nil end
        L.processingDoors = {}
    end
end })

local MainOther = Tabs.Main:AddRightGroupbox("其他")
MainOther:AddToggle("亮度提升", { Text = "亮度提升", Default = false, Callback = function(state)
    if state then
        if not L.originalLighting then
            L.originalLighting = { ClockTime = Lighting.ClockTime, Ambient = Lighting.Ambient, GlobalShadows = Lighting.GlobalShadows, OutdoorAmbient = Lighting.OutdoorAmbient }
        end
        Lighting.ClockTime = 14
        Lighting.Ambient = Color3.fromRGB(255,255,255)
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
        L.brightEnabled = true
    else
        if L.originalLighting then
            Lighting.ClockTime = L.originalLighting.ClockTime
            Lighting.Ambient = L.originalLighting.Ambient
            Lighting.GlobalShadows = L.originalLighting.GlobalShadows
            Lighting.OutdoorAmbient = L.originalLighting.OutdoorAmbient
        end
        L.brightEnabled = false
    end
end })
MainOther:AddToggle("显示物品栏", { Text = "显示物品栏", Default = false, Callback = function(state)
    if state then
        local backpackGui = player:WaitForChild("PlayerGui"):WaitForChild("BackpackGui")
        backpackGui.Enabled = true
        L.backpackToggleConn = backpackGui:GetPropertyChangedSignal("Enabled"):Connect(function()
            if not backpackGui.Enabled then backpackGui.Enabled = true end
        end)
    else if L.backpackToggleConn then L.backpackToggleConn:Disconnect() end end
end })
MainOther:AddToggle("点击传送", { Text = "点击传送", Default = false, Callback = function(state)
    L.teleportEnabled = state
    if state then createTeleportUI() else destroyTeleportUI() end
end })

local CombatLeft = Tabs.Combat:AddLeftGroupbox("杀戮光环")
CombatLeft:AddToggle("高频杀戮", { Text = "高频杀戮", Default = false, Callback = function(state) if state then L.startAura() else L.stopAura() end end })
CombatLeft:AddSlider("高频攻击距离", { Text = "高频攻击距离", Default = 45, Min = 10, Max = 45, Rounding = 0, Callback = function(value) L.auraRangeHighFreq = value end })
CombatLeft:AddToggle("连锁杀戮", { Text = "连锁杀戮", Default = false, Callback = function(state) if state then L.startChainAura() else L.stopChainAura() end end })
CombatLeft:AddSlider("连锁攻击距离", { Text = "连锁攻击距离", Default = 45, Min = 10, Max = 45, Rounding = 0, Callback = function(value) L.chainKillRange = value end })
CombatLeft:AddToggle("无尽专用", { Text = "无尽专用", Default = false, Callback = function(state) L.killWaveEnabled = state L.startWaveMode() end })
CombatLeft:AddSlider("无尽攻击距离", { Text = "无尽攻击距离", Default = 45, Min = 10, Max = 45, Rounding = 0, Callback = function(value) L.auraRangeWave = value end })
CombatLeft:AddToggle("手动杀戮", { Text = "手动杀戮", Default = false, Callback = function(state) L.killAnimEnabled = state L.updateKillAnimConnection() end })
CombatLeft:AddSlider("手动攻击距离", { Text = "手动攻击距离", Default = 45, Min = 10, Max = 45, Rounding = 0, Callback = function(value) L.auraRangeManual = value end })
CombatLeft:AddToggle("攻击自爆", { Text = "攻击自爆", Default = false, Callback = function(state) L.attackBarrelEnabled = state end })
CombatLeft:AddToggle("强制爆头", { Text = "强制爆头", Default = false, Callback = function(state) if state then L.enableHeadshot() else L.disableHeadshot() end end })

local CombatCustom = Tabs.Combat:AddLeftGroupbox("自定义杀戮")
CombatCustom:AddToggle("自定义杀戮", { Text = "自定义杀戮", Default = false, Callback = function(state)
    if state then
        if L.customAttackThread then return end
        L.customAuraEnabled = true
        L.customAttackThread = task.spawn(function()
            while L.customAuraEnabled do
                local char = player.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local weapon = L.getHeldMelee()
                        if weapon then
                            local zombiesInRange = {}
                            local zombiesFolder = workspace:FindFirstChild("Zombies")
                            if zombiesFolder then
                                for _, zombie in pairs(zombiesFolder:GetChildren()) do
                                    if zombie:IsA("Model") and zombie:FindFirstChild("HumanoidRootPart") then
                                        if not L.attackBarrelEnabled and zombie:GetAttribute("Type") == "Barrel" then continue end
                                        if zombie:FindFirstChild("State") and zombie.State.Value == "Spawn" then continue end
                                        if L.distanceToZombie(zombie) <= L.customAttackRange then table.insert(zombiesInRange, zombie) end
                                    end
                                end
                            end
                            local count = math.min(L.customAttackCount, #zombiesInRange)
                            for i = 1, count do
                                local zombie = zombiesInRange[i]
                                if zombie then
                                    local remote = weapon:FindFirstChild("RemoteEvent")
                                    local head = zombie:FindFirstChild("Head")
                                    if remote and head then
                                        remote:FireServer("Swing", "Side")
                                        remote:FireServer("HitZombie", zombie, head.Position, true)
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(L.customAttackDelay)
            end
        end)
    else
        L.customAuraEnabled = false
        if L.customAttackThread then task.cancel(L.customAttackThread) L.customAttackThread = nil end
    end
end })
CombatCustom:AddSlider("攻击数量", { Text = "攻击数量", Default = 1, Min = 1, Max = 5, Rounding = 0, Callback = function(v) L.customAttackCount = v end })
CombatCustom:AddSlider("攻击距离", { Text = "攻击距离", Default = 45, Min = 10, Max = 45, Rounding = 0, Callback = function(v) L.customAttackRange = v end })
CombatCustom:AddSlider("攻击频率", { Text = "攻击频率", Default = 0.005, Min = 0.005, Max = 1, Rounding = 3, Callback = function(v) L.customAttackDelay = v end })

local CombatHitbox = Tabs.Combat:AddLeftGroupbox("碰撞箱扩展")
CombatHitbox:AddToggle("启用碰撞箱扩展", { Text = "启用碰撞箱扩展", Default = false, Callback = function(state)
    if state then enableHitboxExpander() else disableHitboxExpander() end
end })
CombatHitbox:AddSlider("碰撞箱大小", { Text = "碰撞箱大小", Default = 10, Min = 1, Max = 30, Rounding = 0, Callback = function(value) setHitboxSize(value) end })

local CombatPVP = Tabs.Combat:AddRightGroupbox("PVP")
CombatPVP:AddToggle("刺刀杀戮", { Text = "刺刀杀戮", Default = false, Callback = function(state)
    L.pvpBayonetActive = state
    if not state then L.attackedBayonetPlayers = {} end
    L.updatePVPHeartbeat()
end })
CombatPVP:AddToggle("近战杀戮", { Text = "近战杀戮", Default = false, Callback = function(state)
    L.pvpMeleeActive = state
    if not state then L.attackedMeleePlayers = {} end
    L.updatePVPHeartbeat()
end })
CombatPVP:AddToggle("自动射击玩家", { Text = "自动射击玩家", Default = false, Callback = function(state)
    if state then L.startAutoShootPlayer() else L.stopAutoShootPlayer() end
end })
CombatPVP:AddSlider("射击距离", { Text = "射击距离", Default = 200, Min = 50, Max = 300, Rounding = 0, Callback = function(value) L.autoShootRange = value end })

local CombatOfficer = Tabs.Combat:AddRightGroupbox("军官射击")
CombatOfficer:AddToggle("自动换弹", { Text = "自动换弹", Default = false, Callback = function(state)
    L.autoReloadEnabled = state
    if state then
        local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
        if tool and L.isGun(tool) and L.getShotsLoadedForTool(tool) == 0 then
            local remote = L.findRemoteForTool(tool)
            if remote then pcall(function() remote:FireServer("Reload") end) end
        end
        L.monitorCharacterTools(player.Character)
    end
end })
CombatOfficer:AddToggle("自动黑枪", { Text = "自动黑枪", Default = false, Callback = function(state) L.autoBlackGunEnabled = state L.updateShootingState() end })
CombatOfficer:AddSlider("黑枪转向速度", { Text = "黑枪转向速度", Default = 0.28, Min = 0.01, Max = 50, Rounding = 2, Callback = function(value) L.autoBlackGunSmoothTime = value end })
CombatOfficer:AddSlider("黑枪射击速度", { Text = "黑枪射击速度", Default = 0.1, Min = 0.01, Max = 50, Rounding = 2, Callback = function(value) L.autoBlackGunCooldown = value end })
CombatOfficer:AddSlider("黑枪装备延迟", { Text = "黑枪装备延迟", Default = 0.2, Min = 0, Max = 50, Rounding = 2, Callback = function(value) L.autoBlackGunEquipDelay = value end })
CombatOfficer:AddSlider("自爆检测距离", { Text = "自爆检测距离", Default = 14, Min = 1, Max = 25, Rounding = 0, Callback = function(value) L.autoBlackGunBarrelDistance = value end })
CombatOfficer:AddToggle("自动跳刀", { Text = "自动跳刀", Default = false, Callback = function(state) setAutoJumpAnimEnabled(state) end })

local CombatAutoShoot = Tabs.Combat:AddRightGroupbox("自动射击僵尸")
CombatAutoShoot:AddToggle("自动射击自爆", { Text = "自动射击自爆", Default = false, Callback = function(state) L.autoShootBomber = state L.updateShootingState() end })
CombatAutoShoot:AddToggle("自动射击胸甲", { Text = "自动射击胸甲", Default = false, Callback = function(state) L.autoShootCuirassier = state L.updateShootingState() end })
CombatAutoShoot:AddToggle("自动射击红眼", { Text = "自动射击红眼", Default = false, Callback = function(state) L.autoShootRunner = state L.updateShootingState() end })
CombatAutoShoot:AddToggle("自动射击斧头", { Text = "自动射击斧头", Default = false, Callback = function(state) L.autoShootElectrocutioner = state L.updateShootingState() end })

local ESPL = Tabs.ESP:AddLeftGroupbox("僵尸透视")
ESPL:AddToggle("透视斧头僵尸", { Text = "透视斧头僵尸", Default = false, Callback = function(state) L.zombieEspEnabled.Axe = state L.updateZombieESP() end })
ESPL:AddToggle("透视红眼", { Text = "透视红眼", Default = false, Callback = function(state) L.zombieEspEnabled.Eye = state L.updateZombieESP() end })
ESPL:AddToggle("透视胸甲骑兵", { Text = "透视胸甲骑兵", Default = false, Callback = function(state) L.zombieEspEnabled.Sword = state L.updateZombieESP() end })
ESPL:AddToggle("透视自爆", { Text = "透视自爆", Default = false, Callback = function(state) L.zombieEspEnabled.Barrel = state L.updateZombieESP() end })
ESPL:AddToggle("透视提灯人", { Text = "透视提灯人", Default = false, Callback = function(state) L.zombieEspEnabled.FTorso = state L.updateZombieESP() end })
ESPL:AddToggle("透视山伯乐", { Text = "透视山伯乐", Default = false, Callback = function(state) L.zombieEspEnabled.Normal = state L.updateZombieESP() end })

local ESPR = Tabs.ESP:AddRightGroupbox("玩家透视")
ESPR:AddToggle("启用玩家透视", { Text = "启用玩家透视", Default = false, Callback = function(state) L.espPlayerEnabled = state L.refreshAllPlayersESP() end })
ESPR:AddToggle("显示玩家名称", { Text = "显示玩家名称", Default = false, Callback = function(state) L.espShowNames = state L.refreshAllPlayersESP() end })
ESPR:AddToggle("队伍检测", { Text = "队伍检测", Default = false, Callback = function(state) L.espTeamCheckPlayer = state L.refreshAllPlayersESP() end })

local ESPOther = Tabs.ESP:AddRightGroupbox("其他透视")
ESPOther:AddToggle("火炮物资透视", { Text = "火炮物资透视", Default = false, Callback = function(state)
    if state then AnimationController.CreateCannonHighlights() else AnimationController.RemoveCannonHighlights() end
end })
ESPOther:AddToggle("自爆范围显示", { Text = "自爆范围显示", Default = false, Callback = function(state)
    L.bombRangeEnabled = state
    if state then L.startBombRange() L.onBombRangeHeartbeat() else L.stopBombRange() end
end })

local CareerLeft = Tabs.Career:AddLeftGroupbox("工兵")
CareerLeft:AddToggle("自动修复建筑", { Text = "自动修复建筑", Default = false, Callback = function(state) L.toggleEngineerAutoRepair(state) end })
CareerLeft:AddToggle("攻击回收武器", { Text = "攻击回收武器", Default = false, Callback = function(state) L.engineerRecycleEnabled = state L.updateEngineerAnimConnection() end })
CareerLeft:AddToggle("肘击范围扩大", { Text = "肘击范围扩大", Default = false, Callback = function(state) L.engineerElbowEnabled = state L.updateEngineerAnimConnection() end })
CareerLeft:AddToggle("自动肘击", { Text = "自动肘击", Default = false, Callback = function(state)
    L.elbowActive = state
    if state then
        L.elbowConnection = RunService.Heartbeat:Connect(function()
            if not L.elbowActive or not player.Character then return end
            local now = tick()
            if now - L.lastElbowTime < 0.2 then return end
            L.lastElbowTime = now
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then return end
            for _, zombie in pairs(workspace.Zombies:GetChildren()) do
                if zombie:IsA("Model") and zombie:FindFirstChild("HumanoidRootPart") then
                    local distance = (zombie.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if distance <= 45 then L.executeElbowStun(zombie) end
                end
            end
        end)
    else if L.elbowConnection then L.elbowConnection:Disconnect() L.elbowConnection = nil end end
end })

local CareerRight = Tabs.Career:AddRightGroupbox("医疗与祝福")
CareerRight:AddToggle("自动治疗", { Text = "自动治疗", Default = false, Callback = function(state)
    L.doctorEnabled = state
    if state then
        if L.doctorThread then task.cancel(L.doctorThread) end
        L.doctorThread = task.spawn(doctorLoop)
    else
        if L.doctorThread then task.cancel(L.doctorThread) L.doctorThread = nil end
        L.doctorLastRequest = {}
    end
end })
CareerRight:AddSlider("治疗阈值", { Text = "治疗阈值", Default = 25, Min = 1, Max = 100, Rounding = 0, Callback = function(value) L.doctorThreshold = value end })
CareerRight:AddToggle("自动祝福", { Text = "自动祝福", Default = false, Callback = function(state)
    L.chaplainEnabled = state
    if state then
        if L.chaplainThread then task.cancel(L.chaplainThread) end
        L.chaplainThread = task.spawn(chaplainLoop)
    else
        if L.chaplainThread then task.cancel(L.chaplainThread) L.chaplainThread = nil end
        L.chaplainLastRequest = {}
    end
end })
CareerRight:AddSlider("祝福阈值", { Text = "祝福阈值", Default = 50, Min = 1, Max = 100, Rounding = 0, Callback = function(value) L.chaplainThreshold = value end })

local AnimMain = Tabs.Anim:AddLeftGroupbox("主要动画")
for _, config in ipairs(AnimationController.MainButtonConfigs) do
    local buttonData = { Tracks = {}, Connections = {} }
    AnimationController.ActiveButtons[config.Name] = buttonData
    AnimMain:AddToggle(config.Name, { Text = config.Name, Default = false, Callback = function(state)
        if config.Name == "骑兵动画（刺）" and state then
        else AnimationController:ToggleAnimation(config, buttonData, state) end
    end })
end

local AnimSide = Tabs.Anim:AddRightGroupbox("特殊动画")
for _, config in ipairs(AnimationController.SideButtonConfigs) do
    local buttonData = { Tracks = {}, Connections = {} }
    AnimationController.ActiveButtons[config.Name] = buttonData
    AnimSide:AddToggle(config.Name, { Text = config.Name, Default = false, Callback = function(state)
        AnimationController:ToggleAnimation(config, buttonData, state)
    end })
end

local MiscLeft = Tabs.Misc:AddLeftGroupbox("性能与防护")
MiscLeft:AddToggle("禁用火焰粒子", { Text = "禁用火焰粒子", Default = false, Callback = function(state) toggleFixFire(state) end })
MiscLeft:AddToggle("碰飞模式", { Text = "碰飞模式", Default = false, Callback = function(state)
    L.flyOffEnabled = state
    if not state then L.flyOffTarget = nil L.flyOffOriginalCFrame = nil end
end })
MiscLeft:AddToggle("移除自爆碰撞", { Text = "移除自爆碰撞", Default = false, Callback = function(state)
    L.barrelCollisionRemovalActive = state
    if state then L.startBarrelCollisionRemoval() else L.stopBarrelCollisionRemoval() end
end })
MiscLeft:AddToggle("解锁成就军团", { Text = "解锁成就军团", Default = false, Callback = function(state)
    if state then
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Events")
        if remote then remote = remote:FindFirstChild("UnlockAchievement") end
        if remote then remote:FireServer("Legion") end
    end
end })

local MiscRight = Tabs.Misc:AddRightGroupbox("传送与恶搞")
MiscRight:AddButton("莱比锡绕过大门传送", function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-588.65, 10.91, -109.46)
    end
end)
MiscRight:AddToggle("无敌飞雷神", { Text = "无敌飞雷神", Default = false, Callback = function(state) end })
MiscRight:AddToggle("黑皮体育生沉淀", { Text = "黑皮体育生沉淀", Default = false, Callback = function(state) end })

local MiscGet = Tabs.Misc:AddLeftGroupbox("武器获取")
MiscGet:AddButton("获取法棍", function()
    local purchase = L.getPurchaseEvent()
    if purchase then purchase:FireServer("Baguette") end
end)
MiscGet:AddButton("获取吸血鬼刀", function()
    local purchase = L.getPurchaseEvent()
    if purchase then purchase:FireServer("Voivode") end
end)
MiscGet:AddButton("获取铁桩", function()
    local purchase = L.getPurchaseEvent()
    if purchase then purchase:FireServer("Iron Stake") end
end)
MiscGet:AddButton("获取全部武器", function()
    local purchase = L.getPurchaseEvent()
    local equip = L.getEquipWeaponEvent()
    if not purchase or not equip then return end
    purchase:FireServer("Baguette")
    purchase:FireServer("Voivode")
    purchase:FireServer("Iron Stake")
    task.wait(0.2)
    local classes = {"LineInfantry", "Officer", "Seaman", "Musician", "Sapper", "Surgeon", "Chaplain"}
    for _, class in ipairs(classes) do
        if class == "Sapper" then equip:FireServer(class, "Baguette", false)
        elseif class == "Chaplain" then equip:FireServer(class, "Iron Stake", false)
        else equip:FireServer(class, "Voivode", false) end
    end
end)

local UnloadGroup = Tabs.Settings:AddLeftGroupbox("脚本管理")
UnloadGroup:AddButton("卸载脚本", function() Library:Unload() end)

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
