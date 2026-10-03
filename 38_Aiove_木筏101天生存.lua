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

local plrs = game:GetService("Players")
local rep = game:GetService("ReplicatedStorage")
local lighting = game:GetService("Lighting")
local run = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local tween = game:GetService("TweenService")
local LocalPlayer = plrs.LocalPlayer

local Window = Library:CreateWindow({
    Title = "木筏101天生存",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify({
    Title = "木筏101天生存",
    Description = "创作者：Aiove\nQQ：3999698324\n脚本已加载成功",
    Time = 5,
})

local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Char = Window:AddTab("角色", "info"),
    Feature = Window:AddTab("特色", "info"),
    Attack = Window:AddTab("战斗采集", "info"),
    ESP = Window:AddTab("ESP透视", "info"),
    Env = Window:AddTab("环境系统", "info"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel("Aiove将持续更新此脚本")
NoticeGroup:AddLabel("创作者：Aiove")

local AxeHit = rep:WaitForChild("AxeHit")
local carryablesFolder = workspace:FindFirstChild("_Carryables")
local debrisFolder = workspace:FindFirstChild("_Debris")
local npcsFolder = debrisFolder and debrisFolder:FindFirstChild("NPCs")
local islandsFolder = debrisFolder and debrisFolder:FindFirstChild("Islands")
local cratesFolder = workspace:FindFirstChild("_Crates")
local counter = 0

if not carryablesFolder then
    Library:Notify({Title = "错误", Description = "请先进入游戏", Time = 4})
    return
end

local GameplayEvents = rep:FindFirstChild("Events") and rep.Events:FindFirstChild("Gameplay")
local PickUpEvent = GameplayEvents and GameplayEvents:FindFirstChild("PickUpCarryable")
local DropEvent = GameplayEvents and GameplayEvents:FindFirstChild("DropCarryable")
local ClaimLootEvent = rep:WaitForChild("ClaimLootEvent")

local function getCampfirePosition()
    local raft = workspace:FindFirstChild("_Raft")
    if not raft then return nil end
    local campfire = raft:FindFirstChild("Campfire")
    if not campfire then return nil end
    if campfire:IsA("BasePart") then return campfire.Position
    elseif campfire:IsA("Model") then
        local primary = campfire.PrimaryPart
        if primary then return primary.Position end
        for _, part in ipairs(campfire:GetDescendants()) do
            if part:IsA("BasePart") then return part.Position end
        end
    end
    return nil
end

local function teleportToPosition(pos)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and pos then
        hrp.CFrame = CFrame.new(pos)
        return true
    end
    return false
end

local function teleportToInstance(inst, yOffset)
    if not inst then return end
    yOffset = yOffset or 3
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if inst:IsA("Model") and inst:GetPivot() then
        hrp.CFrame = inst:GetPivot() * CFrame.new(0, yOffset, 0)
    elseif inst:IsA("BasePart") then
        hrp.CFrame = inst.CFrame * CFrame.new(0, yOffset, 0)
    end
end

local espHighlights = { Items = {}, NPCs = {} }
local itemESPEnabled = false
local npcESPEnabled = false

local function createESP(obj, color, name)
    if not obj or not obj:IsA("PVInstance") then return nil, nil end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0.2
    highlight.Adornee = obj
    highlight.Parent = obj

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Name"
    billboard.Adornee = obj
    billboard.Size = UDim2.new(0, 100, 0, 20)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = obj

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = name
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextStrokeTransparency = 0.5
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 12
    textLabel.TextScaled = true
    textLabel.Parent = billboard

    return highlight, billboard
end

local function clearItemESP()
    for _, data in ipairs(espHighlights.Items) do
        if data.highlight and data.highlight.Parent then data.highlight:Destroy() end
        if data.billboard and data.billboard.Parent then data.billboard:Destroy() end
    end
    espHighlights.Items = {}
end

local function clearNPCESP()
    for _, data in ipairs(espHighlights.NPCs) do
        if data.highlight and data.highlight.Parent then data.highlight:Destroy() end
        if data.billboard and data.billboard.Parent then data.billboard:Destroy() end
    end
    espHighlights.NPCs = {}
end

local function refreshItemESP()
    if not itemESPEnabled then return end
    clearItemESP()
    for _, obj in ipairs(carryablesFolder:GetChildren()) do
        local highlight, billboard = createESP(obj, Color3.fromRGB(0, 255, 0), obj.Name)
        if highlight then table.insert(espHighlights.Items, {highlight = highlight, billboard = billboard}) end
    end
end

local function refreshNPCESP()
    if not npcESPEnabled or not npcsFolder then return end
    clearNPCESP()
    for _, obj in ipairs(npcsFolder:GetChildren()) do
        local animalType = obj:GetAttribute("AnimalType")
        local displayName = animalType or "未知生物"
        local highlight, billboard = createESP(obj, Color3.fromRGB(255, 0, 0), displayName)
        if highlight then table.insert(espHighlights.NPCs, {highlight = highlight, billboard = billboard}) end
    end
end

carryablesFolder.ChildAdded:Connect(function() if itemESPEnabled then refreshItemESP() end end)
carryablesFolder.ChildRemoved:Connect(function() if itemESPEnabled then refreshItemESP() end end)
if npcsFolder then
    npcsFolder.ChildAdded:Connect(function() if npcESPEnabled then refreshNPCESP() end end)
    npcsFolder.ChildRemoved:Connect(function() if npcESPEnabled then refreshNPCESP() end end)
end
task.spawn(function()
    while true do
        if itemESPEnabled then refreshItemESP() end
        if npcESPEnabled then refreshNPCESP() end
        task.wait(1)
    end
end)

local autoPickupRunning, autoPickupThread = false, nil
local tpDelay, maxPickWaitTime, maxTeleWaitTime, campfireIgnoreDistance = 0.1, 0.5, 0.3, 10

local function stopAutoPickup()
    autoPickupRunning = false
    if autoPickupThread then autoPickupThread = nil end
    Library:Notify({Title = "自动拾取关闭", Description = "已停止物品拾取", Time = 2})
end

local function startAutoPickup()
    if autoPickupRunning then return end
    if not PickUpEvent or not DropEvent then
        Library:Notify({Title = "错误", Description = "未找到拾取/放下远程事件", Time = 3})
        return
    end
    autoPickupRunning = true
    autoPickupThread = task.spawn(function()
        while autoPickupRunning do
            local items = carryablesFolder:GetChildren()
            local raft = workspace:FindFirstChild("_Raft")
            local campfirePos = getCampfirePosition()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if #items > 0 and raft and hrp and campfirePos then
                local targetItem = nil
                for _, item in ipairs(items) do
                    if not autoPickupRunning then break end
                    if item:IsA("Model") or (item:IsA("BasePart") and item:IsDescendantOf(workspace)) then
                        local itemPos = item:GetPivot().Position
                        local distToCampfire = (Vector3.new(itemPos.X, 0, itemPos.Z) - Vector3.new(campfirePos.X, 0, campfirePos.Z)).Magnitude
                        if distToCampfire >= campfireIgnoreDistance then
                            targetItem = item
                            break
                        end
                    end
                end
                if targetItem and autoPickupRunning then
                    teleportToInstance(targetItem)
                    task.wait(tpDelay)
                    if not autoPickupRunning then break end
                    pcall(function() PickUpEvent:FireServer(targetItem) end)
                    local pickSuccess = false
                    local waitStart = tick()
                    while tick() - waitStart < maxPickWaitTime do
                        if not autoPickupRunning then break end
                        if not targetItem:IsDescendantOf(workspace) then pickSuccess = true break end
                        task.wait(0.02)
                    end
                    if not pickSuccess then task.wait(tpDelay); continue end
                    task.wait(tpDelay)
                    if not autoPickupRunning then break end
                    teleportToInstance(raft)
                    local teleSuccess = false
                    local teleStart = tick()
                    local raftPos = raft:GetPivot().Position
                    while tick() - teleStart < maxTeleWaitTime do
                        if not autoPickupRunning then break end
                        local currentPos = hrp.Position
                        local distance = (Vector3.new(currentPos.X, 0, currentPos.Z) - Vector3.new(raftPos.X, 0, raftPos.Z)).Magnitude
                        if distance <= 2 then teleSuccess = true break end
                        task.wait(0.02)
                    end
                    if not teleSuccess then task.wait(tpDelay); continue end
                    task.wait(tpDelay)
                    if not autoPickupRunning then break end
                    pcall(function() DropEvent:FireServer() end)
                    task.wait(tpDelay * 2)
                else
                    task.wait(0.5)
                end
            else
                task.wait(0.5)
            end
        end
        autoPickupThread = nil
    end)
    Library:Notify({Title = "自动拾取开启", Description = "已启动物品自动拾取（跳过篝火附近）", Time = 2})
end

local function equipAnyTool()
    pcall(function()
        local backpack = LocalPlayer.Backpack
        if backpack then
            local tool = backpack:FindFirstChildOfClass("Tool")
            if tool and LocalPlayer.Character then
                LocalPlayer.Character.Humanoid:EquipTool(tool)
            end
        end
    end)
end

local CharGroup = Tabs.Char:AddLeftGroupbox("角色")

local speedEnabled, speedValue, speedThread = false, 35, nil
local function updateSpeed()
    while speedEnabled do
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = speedValue end
        task.wait(0.5)
    end
end

CharGroup:AddToggle("SpeedToggle", {
    Text = "加速",
    Default = false,
    Callback = function(Value)
        speedEnabled = Value
        if Value then
            if speedThread then task.cancel(speedThread) end
            speedThread = task.spawn(updateSpeed)
        else
            if speedThread then task.cancel(speedThread); speedThread = nil end
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.WalkSpeed = 16 end
        end
    end,
})

CharGroup:AddSlider("SpeedValue", {
    Text = "速度值",
    Default = 35,
    Min = 20,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        speedValue = Value
    end,
})

local flightEnabled, flightSpeed, flightConnection = false, 2, nil
local function startFlight()
    if flightConnection then flightConnection:Disconnect(); flightConnection = nil end
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local head = char:FindFirstChild("Head")
    if not humanoid or not head then return end
    humanoid.PlatformStand = true
    head.Anchored = true
    local camera = workspace.CurrentCamera
    flightConnection = run.Heartbeat:Connect(function(deltaTime)
        if not flightEnabled or not LocalPlayer.Character then stopFlight(); return end
        local c = LocalPlayer.Character
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        local hd = c and c:FindFirstChild("Head")
        if not hum or not hd then stopFlight(); return end
        local moveDir = hum.MoveDirection * (flightSpeed * deltaTime * 50)
        local headCF = hd.CFrame
        local camCF = camera.CFrame
        local camOffset = headCF:ToObjectSpace(camCF).Position
        local adjustedCamCF = camCF * CFrame.new(-camOffset.X, -camOffset.Y, -camOffset.Z + 1)
        local camPos = adjustedCamCF.Position
        local headPos = headCF.Position
        local objSpaceVelocity = CFrame.new(camPos, Vector3.new(headPos.X, camPos.Y, headPos.Z)):VectorToObjectSpace(moveDir)
        hd.CFrame = CFrame.new(headPos) * (adjustedCamCF - camPos) * CFrame.new(objSpaceVelocity)
    end)
end
function stopFlight()
    if flightConnection then flightConnection:Disconnect(); flightConnection = nil end
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local head = char:FindFirstChild("Head")
        if humanoid then humanoid.PlatformStand = false end
        if head then head.Anchored = false end
    end
end

CharGroup:AddToggle("FlightToggle", {
    Text = "飞行",
    Default = false,
    Callback = function(Value)
        flightEnabled = Value
        if Value then startFlight() else stopFlight() end
    end,
})

CharGroup:AddSlider("FlightSpeed", {
    Text = "飞行速度",
    Default = 2,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Callback = function(Value)
        flightSpeed = Value
    end,
})

local invincibleEnabled, invincibleHeight, invincibleThread, anchorY = false, 1, nil, 0
local function recalcAnchor()
    if not invincibleEnabled then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local raycastResult = workspace:Raycast(hrp.Position + Vector3.new(0, 5, 0), Vector3.new(0, -100, 0))
    anchorY = (raycastResult and raycastResult.Position.Y or hrp.Position.Y) + invincibleHeight
end
local function startInvincible()
    if invincibleEnabled then return end
    invincibleEnabled = true
    recalcAnchor()
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then char:FindFirstChildOfClass("Humanoid").PlatformStand = true end
    invincibleThread = task.spawn(function()
        while invincibleEnabled do
            local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if h then
                h.CFrame = CFrame.new(h.Position.X, anchorY, h.Position.Z) * CFrame.Angles(0, math.atan2(h.CFrame.LookVector.X, h.CFrame.LookVector.Z), 0)
                h.Velocity = Vector3.new(h.Velocity.X, 0, h.Velocity.Z)
            end
            task.wait(0.03)
        end
        invincibleThread = nil
    end)
end
local function stopInvincible()
    invincibleEnabled = false
    if invincibleThread then invincibleThread = nil end
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then char:FindFirstChildOfClass("Humanoid").PlatformStand = false end
end

CharGroup:AddToggle("InvincibleToggle", {
    Text = "无敌 (悬浮)",
    Default = false,
    Callback = function(Value)
        if Value then startInvincible() else stopInvincible() end
    end,
})

CharGroup:AddSlider("InvincibleHeight", {
    Text = "悬浮高度",
    Default = 1,
    Min = 1,
    Max = 3,
    Rounding = 0,
    Callback = function(Value)
        invincibleHeight = Value
        recalcAnchor()
    end,
})

CharGroup:AddButton("传送到火堆", function()
    local firePos = getCampfirePosition()
    if firePos then
        teleportToPosition(firePos)
        Library:Notify({Title = "传送成功", Description = "已传送到火堆", Time = 2})
    else
        Library:Notify({Title = "传送失败", Description = "未找到火堆位置", Time = 2})
    end
end)

local FeatureGroup = Tabs.Feature:AddLeftGroupbox("特色")

FeatureGroup:AddToggle("AutoPickup", {
    Text = "自动拿取物品",
    Default = false,
    Callback = function(Value)
        if Value then startAutoPickup() else stopAutoPickup() end
    end,
})

local autoCrateRunning, autoCrateThread = false, nil
local function openCrate(crate)
    if not crate or not crate.Parent then return false end
    local promptPart = crate:FindFirstChild("PromptPart")
    if not promptPart then return false end
    local openCratePrompt = promptPart:FindFirstChild("OpenCrate")
    if not openCratePrompt or not openCratePrompt:IsA("ProximityPrompt") then
        for _, child in ipairs(promptPart:GetChildren()) do
            if child:IsA("ProximityPrompt") then openCratePrompt = child break end
        end
    end
    if not openCratePrompt then return false end
    local originalHoldDuration = openCratePrompt.HoldDuration
    openCratePrompt.HoldDuration = 0
    teleportToInstance(crate, 3)
    task.wait(0.2)
    openCratePrompt:InputHoldBegin()
    task.wait(0.1)
    openCratePrompt:InputHoldEnd()
    openCratePrompt.HoldDuration = originalHoldDuration
    return true
end
local function stopAutoCrate()
    autoCrateRunning = false
    if autoCrateThread then autoCrateThread = nil end
    Library:Notify({Title = "自动开箱关闭", Description = "已停止自动开箱", Time = 2})
end
local function startAutoCrate()
    if autoCrateRunning then return end
    if not cratesFolder then Library:Notify({Title = "错误", Description = "未找到箱子文件夹", Time = 3}); return end
    autoCrateRunning = true
    autoCrateThread = task.spawn(function()
        while autoCrateRunning do
            local crates = cratesFolder:GetChildren()
            if #crates > 0 then
                for _, crate in ipairs(crates) do
                    if not autoCrateRunning then break end
                    if openCrate(crate) then
                        Library:Notify({Title = "自动开箱", Description = "已开启: " .. crate.Name, Time = 1.5})
                        task.wait(0.5)
                        ClaimLootEvent:InvokeServer(crate)
                        task.wait(1)
                    else task.wait(0.5) end
                end
            else task.wait(1) end
            task.wait(1)
        end
        autoCrateThread = nil
    end)
    Library:Notify({Title = "自动开箱开启", Description = "已启动自动开箱", Time = 2})
end

FeatureGroup:AddToggle("AutoCrate", {
    Text = "自动开箱",
    Default = false,
    Callback = function(Value)
        if Value then startAutoCrate() else stopAutoCrate() end
    end,
})

FeatureGroup:AddButton("拾取所有贝壳", function()
    if not islandsFolder then Library:Notify({Title = "错误", Description = "未找到岛屿文件夹", Time = 3}); return end
    local total = 0
    for _, island in ipairs(islandsFolder:GetChildren()) do
        if not island:IsA("Model") then continue end
        local seashells = island:FindFirstChild("Objects") and island.Objects:FindFirstChild("Seashells")
        if not seashells then continue end
        for _, shell in ipairs(seashells:GetChildren()) do
            local part = shell:IsA("BasePart") and shell or (shell:IsA("Model") and (shell:FindFirstChild("Base") or shell:FindFirstChildWhichIsA("BasePart")))
            if part and part:FindFirstChildOfClass("ClickDetector") then
                fireclickdetector(part:FindFirstChildOfClass("ClickDetector"))
                total = total + 1
            end
        end
    end
    if total == 0 then
        Library:Notify({Title = "提示", Description = "没有可拾取的贝壳", Time = 2})
    else
        Library:Notify({Title = "拾取贝壳", Description = "已拾取 " .. total .. " 个贝壳", Time = 2})
    end
end)

local AttackGroup = Tabs.Attack:AddLeftGroupbox("战斗采集")

local attackAuraRunning, attackAuraThread, attackRange = false, nil, 400
local function getTargetType(model)
    if model:GetAttribute("NPCHealth") ~= nil then return "npc_attribute"
    elseif model:FindFirstChildOfClass("Humanoid") and not plrs:GetPlayerFromCharacter(model) then return "npc_humanoid" end
    if npcsFolder and model:IsDescendantOf(npcsFolder) then return "npc_humanoid" end
    return nil
end
local function startAttackAura()
    if attackAuraRunning then return end
    attackAuraRunning = true
    attackAuraThread = task.spawn(function()
        while attackAuraRunning do
            if not LocalPlayer.Character:FindFirstChildOfClass("Tool") then equipAnyTool() end
            task.wait(0.1)
            if attackAuraRunning and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local myPos = LocalPlayer.Character.HumanoidRootPart.Position
                local hitList = {}
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if not attackAuraRunning then break end
                    if obj:IsA("Model") then
                        local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                        if root and (root.Position - myPos).Magnitude <= attackRange then
                            local targetType = getTargetType(obj)
                            if targetType and not hitList[obj] then
                                hitList[obj] = true
                                counter = counter + 1
                                pcall(function() AxeHit:FireServer(obj, targetType, counter) end)
                            end
                        end
                    end
                end
            end
        end
        attackAuraThread = nil
    end)
    Library:Notify({Title = "光环", Description = "生物杀戮光环已开启", Time = 2})
end
local function stopAttackAura()
    attackAuraRunning = false
    if attackAuraThread then attackAuraThread = nil end
    Library:Notify({Title = "光环", Description = "生物杀戮光环已停止", Time = 2})
end

AttackGroup:AddToggle("AttackAura", {
    Text = "生物杀戮光环",
    Default = false,
    Callback = function(Value)
        if Value then startAttackAura() else stopAttackAura() end
    end,
})

AttackGroup:AddSlider("AttackRange", {
    Text = "生物杀戮距离",
    Default = 400,
    Min = 50,
    Max = 2000,
    Rounding = 0,
    Callback = function(Value)
        attackRange = Value
    end,
})

local lumberAuraRunning, lumberAuraThread, lumberRange = false, nil, 400
local function startLumberAura()
    if lumberAuraRunning then return end
    lumberAuraRunning = true
    lumberAuraThread = task.spawn(function()
        while lumberAuraRunning do
            if not LocalPlayer.Character:FindFirstChildOfClass("Tool") then equipAnyTool() end
            task.wait(0.1)
            if lumberAuraRunning and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local myPos = LocalPlayer.Character.HumanoidRootPart.Position
                local hitTrees = {}
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if not lumberAuraRunning then break end
                    if obj:IsA("Model") and obj:GetAttribute("TreeHealth") ~= nil then
                        local root = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                        if root and (root.Position - myPos).Magnitude <= lumberRange and not hitTrees[obj] then
                            hitTrees[obj] = true
                            counter = counter + 1
                            pcall(function() AxeHit:FireServer(obj, "tree", counter) end)
                        end
                    end
                end
            end
        end
        lumberAuraThread = nil
    end)
    Library:Notify({Title = "光环", Description = "伐木光环已开启", Time = 2})
end
local function stopLumberAura()
    lumberAuraRunning = false
    if lumberAuraThread then lumberAuraThread = nil end
    Library:Notify({Title = "光环", Description = "伐木光环已停止", Time = 2})
end

AttackGroup:AddToggle("LumberAura", {
    Text = "伐木光环",
    Default = false,
    Callback = function(Value)
        if Value then startLumberAura() else stopLumberAura() end
    end,
})

AttackGroup:AddSlider("LumberRange", {
    Text = "伐木距离",
    Default = 400,
    Min = 50,
    Max = 2000,
    Rounding = 0,
    Callback = function(Value)
        lumberRange = Value
    end,
})

local ESPGroup = Tabs.ESP:AddLeftGroupbox("ESP透视")

ESPGroup:AddToggle("ItemESP", {
    Text = "物品透视",
    Default = false,
    Callback = function(Value)
        itemESPEnabled = Value
        if Value then refreshItemESP() else clearItemESP() end
    end,
})

ESPGroup:AddToggle("NPCESP", {
    Text = "生物透视",
    Default = false,
    Callback = function(Value)
        npcESPEnabled = Value
        if Value then refreshNPCESP() else clearNPCESP() end
    end,
})

local EnvGroup = Tabs.Env:AddLeftGroupbox("环境系统")

EnvGroup:AddButton("除雾", function()
    if lighting:FindFirstChild("Atmosphere") then lighting:FindFirstChild("Atmosphere"):Destroy() end
    if lighting:FindFirstChild("Sky") then lighting:FindFirstChild("Sky"):Destroy() end
    Library:Notify({Title = "视觉", Description = "已移除大气和天空效果", Time = 2})
end)

local origBrightness, origAmbient, origOutdoorAmbient, origFogEnd, origAtmoDensity = lighting.Brightness, lighting.Ambient, lighting.OutdoorAmbient, lighting.FogEnd, nil
local atmosphere = lighting:FindFirstChild("Atmosphere")
if atmosphere then origAtmoDensity = atmosphere.Density end

EnvGroup:AddToggle("NightVision", {
    Text = "夜视仪",
    Default = false,
    Callback = function(Value)
        if Value then
            origBrightness, origAmbient, origOutdoorAmbient, origFogEnd = lighting.Brightness, lighting.Ambient, lighting.OutdoorAmbient, lighting.FogEnd
            if lighting:FindFirstChild("Atmosphere") then origAtmoDensity = lighting:FindFirstChild("Atmosphere").Density end
            lighting.Brightness = 3
            lighting.Ambient = Color3.new(1, 1, 1)
            lighting.OutdoorAmbient = Color3.new(1, 1, 1)
            lighting.FogEnd = 100000
            if lighting:FindFirstChild("Atmosphere") then lighting:FindFirstChild("Atmosphere").Density = 0 end
        else
            lighting.Brightness, lighting.Ambient, lighting.OutdoorAmbient, lighting.FogEnd = origBrightness, origAmbient, origOutdoorAmbient, origFogEnd
            if lighting:FindFirstChild("Atmosphere") and origAtmoDensity then lighting:FindFirstChild("Atmosphere").Density = origAtmoDensity end
        end
    end,
})

EnvGroup:AddButton("优化FPS", function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    lighting.FogEnd = 9e9
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Part") or v:IsA("MeshPart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
    end
    Library:Notify({Title = "优化", Description = "已应用最低图形设置", Time = 2})
end)

local islandMonitorEnabled, latestIsland, islandMonitorConnection = false, nil, nil

EnvGroup:AddToggle("IslandMonitor", {
    Text = "岛屿监测",
    Default = false,
    Callback = function(Value)
        islandMonitorEnabled = Value
        if Value then
            if not islandsFolder then Library:Notify({Title = "错误", Description = "未找到岛屿文件夹", Time = 3}); return end
            islandMonitorConnection = islandsFolder.ChildAdded:Connect(function(newIsland)
                latestIsland = newIsland
                Library:Notify({Title = "新岛屿刷新", Description = "发现新岛屿: " .. newIsland.Name, Time = 3})
            end)
            Library:Notify({Title = "岛屿监测", Description = "已启动监测", Time = 2})
        else
            if islandMonitorConnection then islandMonitorConnection:Disconnect(); islandMonitorConnection = nil end
            Library:Notify({Title = "岛屿监测", Description = "已关闭", Time = 2})
        end
    end,
})

EnvGroup:AddButton("传送到最新岛屿", function()
    if not islandMonitorEnabled then Library:Notify({Title = "传送失败", Description = "你还没有开启岛屿监测", Time = 2}); return end
    if not latestIsland or not latestIsland.Parent then Library:Notify({Title = "传送失败", Description = "尚未发现新岛屿", Time = 2}); return end
    teleportToInstance(latestIsland, 5)
    Library:Notify({Title = "传送成功", Description = "已传送到 " .. latestIsland.Name, Time = 2})
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
