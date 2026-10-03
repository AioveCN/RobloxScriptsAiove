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

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local Camera = Workspace.CurrentCamera

-- ==================== 连接与循环管理 ====================
local AllConnections = {}
local ActiveLoops = {}

local function SafeConnect(event, callback)
    local conn = event:Connect(callback)
    table.insert(AllConnections, conn)
    return conn
end

local function SafeLoop(id, interval, callback)
    if ActiveLoops[id] then return end
    ActiveLoops[id] = true
    task.spawn(function()
        while ActiveLoops[id] and not Library.Unloaded do
            local success, err = pcall(callback)
            if not success then
                warn("[" .. id .. "] 错误: " .. tostring(err))
            end
            task.wait(interval)
        end
        ActiveLoops[id] = nil
    end)
end

local function StopLoop(id)
    ActiveLoops[id] = nil
end

local function DisconnectAll()
    for _, conn in ipairs(AllConnections) do
        if conn and conn.Disconnect then
            pcall(function() conn:Disconnect() end)
        end
    end
    AllConnections = {}
    for id, _ in pairs(ActiveLoops) do
        ActiveLoops[id] = nil
    end
end

-- ==================== 窗口 ====================
local Window = Library:CreateWindow({
    Title = "墨水游戏",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Game = Window:AddTab("游戏", "info"),
    Misc = Window:AddTab("杂项", "list"),
    Guard = Window:AddTab("守卫", "shield"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("公告")
NoticeGroup:AddLabel("Aiove持续更新此脚本")
NoticeGroup:AddLabel("QQ3999698324")
NoticeGroup:AddLabel("安全版: 去掉了Hook和PlatformStand")

-- ==================== 传送 ====================
local function smoothTeleport(targetPos)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local startPos = root.Position
    local distance = (targetPos - startPos).Magnitude
    if distance < 1 then
        root.CFrame = CFrame.new(targetPos)
        return
    end
    local duration = math.clamp(distance / 200, 0.3, 1.5)
    local startTime = tick()
    while tick() - startTime < duration do
        if not root.Parent then return end
        local progress = (tick() - startTime) / duration
        local eased = 1 - (1 - progress) * (1 - progress)
        pcall(function()
            root.CFrame = CFrame.new(startPos:Lerp(targetPos, eased))
        end)
        task.wait(0.03)
    end
    if root.Parent then
        root.CFrame = CFrame.new(targetPos)
    end
end

local function fireWoodEvents()
    task.wait(0.5)
    pcall(function()
        ReplicatedStorage.Remotes.TemporaryReachedBindable:FireServer(nil, {})
    end)
    pcall(function()
        ReplicatedStorage.Remotes.Miau:FireServer({
            "C[Y@W\\RW\B\PW_\2\5",
            "CYTOVA\RPJBQ^U_\6\3",
            "CTXLW]YPOE@]WU]\7\n",
            "D^T@TV\SWAZPWW\\t\0",
            "G^QHVZ[TOKFXRQZ\t\5",
            "D^T@TV\SWAZPWW\\t\0"
        })
    end)
end

-- ==================== 木头人 ====================
local WoodGroup = Tabs.Game:AddLeftGroupbox("木头人")
WoodGroup:AddButton({
    Text = '木头人传送到终点',
    Func = function()
        smoothTeleport(Vector3.new(-37.0, 1023.1, 158.9))
        fireWoodEvents()
    end,
})
WoodGroup:AddButton({
    Text = '传送到终点后面墙壁',
    Func = function()
        smoothTeleport(Vector3.new(114.6, 1023.1, 168.0))
        fireWoodEvents()
    end,
})

local godModeEnabled = false
WoodGroup:AddToggle('GodMode', {
    Text = '防子弹打死防受伤',
    Default = false,
    Callback = function(Value) godModeEnabled = Value end
})

-- 移除子弹：改为事件驱动，不再遍历整个workspace
local removeBulletsEnabled = false
local bulletConnection = nil
WoodGroup:AddToggle('RemoveBullets', {
    Text = '移除子弹（仅视觉 不卡）',
    Default = false,
    Callback = function(Value)
        removeBulletsEnabled = Value
        if Value then
            -- 先清理现有的
            pcall(function()
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") then
                        local name = v.Name:lower()
                        if name:find("bullet") or name:find("projectile") or name:find("ammo") then
                            v.Transparency = 1
                            v.CanCollide = false
                        end
                    end
                end
            end)
            -- 监听新创建的
            if bulletConnection then pcall(function() bulletConnection:Disconnect() end) end
            bulletConnection = workspace.DescendantAdded:Connect(function(v)
                if not removeBulletsEnabled then return end
                if v:IsA("BasePart") then
                    local name = v.Name:lower()
                    if name:find("bullet") or name:find("projectile") or name:find("ammo") then
                        v.Transparency = 1
                        v.CanCollide = false
                    end
                end
            end)
            table.insert(AllConnections, bulletConnection)
        else
            if bulletConnection then
                pcall(function() bulletConnection:Disconnect() end)
                bulletConnection = nil
            end
        end
    end
})

-- 红绿灯无敌：去掉__namecall Hook，改为纯客户端位置冻结
local redLightGodmodeEnabled = false
local redLightConnection = nil
local isGreenLight = true
local lastRootPartCFrame = nil
local redLightLoopId = "RedLightTrack"
local lastSignalTime = tick()

WoodGroup:AddToggle('RedLightGodmode', {
    Text = '红绿灯无敌模式(安全版)',
    Default = false,
    Callback = function(Value)
        redLightGodmodeEnabled = Value
        if Value then
            isGreenLight = true
            if redLightConnection then pcall(function() redLightConnection:Disconnect() end) end
            redLightConnection = ReplicatedStorage.Remotes.Effects.OnClientEvent:Connect(function(data)
                if type(data) == "table" and data.EffectName == "TrafficLight" then
                    isGreenLight = data.GreenLight == true
                    lastSignalTime = tick()
                end
            end)
            table.insert(AllConnections, redLightConnection)

            SafeLoop(redLightLoopId, 0.05, function()
                if not redLightGodmodeEnabled then return end
                if tick() - lastSignalTime > 10 then
                    isGreenLight = true
                end
                local char = LocalPlayer.Character
                if not char then return end
                local root = char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                if isGreenLight then
                    lastRootPartCFrame = root.CFrame
                else
                    -- 红灯时强制保持位置，不拦截远程事件
                    if lastRootPartCFrame then
                        pcall(function()
                            root.CFrame = lastRootPartCFrame
                        end)
                    end
                end
            end)
            Library:Notify("红绿灯无敌已开启(纯客户端模式)", 3)
        else
            if redLightConnection then
                pcall(function() redLightConnection:Disconnect() end)
                redLightConnection = nil
            end
            StopLoop(redLightLoopId)
            Library:Notify("红绿灯无敌已关闭", 3)
        end
    end
})

-- ==================== 抠糖饼 ====================
local CandyGroup = Tabs.Game:AddLeftGroupbox("抠糖饼")
local candyPatterns = {
    ["Pig"] = {
        "B^XLQ]]VQBZZPT^\2\n\7",
        "I_UM[A\SQFA_PUW\0\5",
        "B_UIPY\[XGZPPW^\3\4\0",
        "HXSJWXZQSGZQVQY\2\7",
        "DYQITXYRXEZPSU\\t\n",
        "DXVK[]^[VJZ\TVY\7\5"
    },
}
local keywordMap = {
    Pig = {"pig","porco","cerdo","cochon","schwein","maiale","piggy","piglet","豚","돼지","ブタ","свинья"},
    Star = {"star","estrella","estrela","étoile","stern","stella","звезда","별","星","ster"},
    Umbrella = {"umbrella","paraguas","guarda-chuva","parapluie","regenschirm","ombrello","зонтик","傘","우산","ombrel","parasol"}
}
local function scanGUI(gui, pattern)
    if not gui then return false end
    if gui:IsA("TextLabel") then
        local text = gui.Text:lower()
        for _, kw in ipairs(keywordMap[pattern]) do
            if text:find(kw, 1, true) then return true end
        end
    elseif gui:IsA("ImageLabel") then
        local img = gui.Image:lower()
        for _, kw in ipairs(keywordMap[pattern]) do
            if img:find(kw, 1, true) then return true end
        end
    end
    for _, child in ipairs(gui:GetChildren()) do
        if scanGUI(child, pattern) then return true end
    end
    return false
end
local function detectPattern()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for name, _ in pairs(keywordMap) do
            if scanGUI(playerGui, name) then return name end
        end
    end
    local coreGui = game:GetService("CoreGui")
    if coreGui then
        for name, _ in pairs(keywordMap) do
            if scanGUI(coreGui, name) then return name end
        end
    end
    return nil
end

CandyGroup:AddButton({
    Text = '一键抠糖饼（等动画后）',
    Func = function()
        task.wait(3)
        local pattern = detectPattern() or "Pig"
        if not candyPatterns[pattern] then
            Library:Notify("图案 " .. pattern .. " 密文未添加，请抓包", 5)
            return
        end
        local miauData = candyPatterns[pattern]
        pcall(function() ReplicatedStorage.Remotes.RandomOtherRemotes:FireServer(nil, {}) end)
        task.wait(0.05)
        pcall(function() ReplicatedStorage.Remotes.JoeGurtEvent:FireServer({}) end)
        task.wait(0.05)
        pcall(function() ReplicatedStorage.Replication.Event:FireServer("Clicked") end)
        task.wait(0.05)
        pcall(function() ReplicatedStorage.Remotes.Miau:FireServer(miauData) end)
        task.wait(0.1)
        pcall(function() ReplicatedStorage.Remotes.DALGONATEMPREMTE:FireServer({Completed = true}) end)
        task.wait(0.1)
        pcall(function()
            local DalgonaRemote = ReplicatedStorage.Remotes:FindFirstChild("DALGONATEMPREMTE")
            if DalgonaRemote then
                DalgonaRemote:FireServer({ Success = true })
            end
        end)
        pcall(function()
            local kill = ReplicatedStorage.Remotes:FindFirstChild("KillRemote")
            if kill then kill:FireServer({}) end
        end)
    end,
})

-- 糖饼不破：去掉Hook，改为定时发送修复包
local unbreakableEnabled = false
CandyGroup:AddToggle('UnbreakableDalgona', {
    Text = '糖饼不破(安全版)',
    Default = false,
    Callback = function(Value)
        unbreakableEnabled = Value
        if Value then
            Library:Notify("糖饼不破已开启", 3)
            SafeLoop("Unbreakable", 0.3, function()
                if not unbreakableEnabled then return end
                pcall(function()
                    ReplicatedStorage.Remotes.DALGONATEMPREMTE:FireServer({
                        CrackAmount = 0,
                        FullyCracked = false,
                        ShapeName = detectPattern() or "Pig"
                    })
                end)
            end)
        else
            Library:Notify("糖饼不破已关闭", 3)
            StopLoop("Unbreakable")
        end
    end
})

CandyGroup:AddButton({
    Text = '死亡（点一下就死，不要随便点）',
    Func = function()
        pcall(function()
            local kill = ReplicatedStorage.Remotes:FindFirstChild("KillRemote")
            if kill then kill:InvokeServer({}) end
        end)
    end,
})

-- ==================== 拔河 ====================
local TugGroup = Tabs.Game:AddLeftGroupbox("拔河")
local autoPullEnabled = false
TugGroup:AddToggle('AutoPull', {
    Text = '自动拉绳',
    Default = false,
    Callback = function(Value)
        autoPullEnabled = Value
        if Value then
            SafeLoop("AutoPull", 0.1, function()
                if not autoPullEnabled then return end
                pcall(function()
                    ReplicatedStorage.Remotes.TemporaryReachedBindable:FireServer({PerfectQTE = true})
                end)
            end)
        else
            StopLoop("AutoPull")
        end
    end
})

-- ==================== 玻璃桥 ====================
local GlassGroup = Tabs.Game:AddLeftGroupbox("玻璃桥")
local revealGlassEnabled = false
local glassConnection = nil
GlassGroup:AddToggle('RevealGlass', {
    Text = '显示安全玻璃(事件驱动)',
    Default = false,
    Callback = function(Value)
        revealGlassEnabled = Value
        if Value then
            -- 先处理现有的
            pcall(function()
                local glassHolder = workspace:FindFirstChild("GlassBridge") and workspace.GlassBridge:FindFirstChild("GlassHolder")
                if glassHolder then
                    for _, tilePair in pairs(glassHolder:GetChildren()) do
                        for _, tileModel in pairs(tilePair:GetChildren()) do
                            if tileModel:IsA("Model") and tileModel.PrimaryPart then
                                local primaryPart = tileModel.PrimaryPart
                                local isBreakable = primaryPart:GetAttribute("exploitingisevil") == true
                                local targetColor = isBreakable and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                                for _, part in pairs(tileModel:GetDescendants()) do
                                    if part:IsA("BasePart") then
                                        part.Color = targetColor
                                        part.Transparency = 0.5
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            -- 监听新的
            if glassConnection then pcall(function() glassConnection:Disconnect() end) end
            glassConnection = workspace.DescendantAdded:Connect(function(v)
                if not revealGlassEnabled then return end
                if v:IsA("Model") and v:FindFirstChild("PrimaryPart") then
                    local parent = v.Parent
                    if parent and parent.Parent and parent.Parent.Name == "GlassBridge" then
                        local primaryPart = v.PrimaryPart
                        local isBreakable = primaryPart:GetAttribute("exploitingisevil") == true
                        local targetColor = isBreakable and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                        for _, part in pairs(v:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.Color = targetColor
                                part.Transparency = 0.5
                            end
                        end
                    end
                end
            end)
            table.insert(AllConnections, glassConnection)
        else
            if glassConnection then
                pcall(function() glassConnection:Disconnect() end)
                glassConnection = nil
            end
        end
    end
})
GlassGroup:AddButton({
    Text = '传送到终点',
    Func = function()
        smoothTeleport(Vector3.new(-203.9, 520.7, -1534.35))
    end,
})

-- ==================== 熄灯 ====================
local DarkGroup = Tabs.Game:AddRightGroupbox("熄灯")
DarkGroup:AddButton({
    Text = '传送到安全点',
    Func = function()
        smoothTeleport(Vector3.new(334.5, 50.8, -20.9))
    end,
})

-- ==================== 捉迷藏 ====================
local HideSeekGroup = Tabs.Game:AddRightGroupbox("捉迷藏")
HideSeekGroup:AddButton({
    Text = '传送到躲藏者',
    Func = function()
        local hider = nil
        for _, plr in pairs(Players:GetPlayers()) do
            if plr == LocalPlayer then continue end
            if plr:GetAttribute("IsHider") and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                hider = plr.Character
                break
            end
        end
        if hider then
            smoothTeleport(hider.HumanoidRootPart.Position)
        else
            Library:Notify("未找到躲藏者", 3)
        end
    end,
})

local seekerESPEnabled = false
local seekerESPObjects = {}
local hiderESPEnabled = false
local hiderESPObjects = {}
local keyESPEnabled = false
local keyESPObjects = {}
local seekerESPPlayerAdded = nil
local hiderESPPlayerAdded = nil
local keyESPChildAdded = nil
local keyESPChildRemoved = nil

local function addSeekerESP(player)
    if seekerESPObjects[player] then return end
    local character = player.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 200, 0, 50)
    bill.AlwaysOnTop = true
    bill.StudsOffset = Vector3.new(0, 3, 0)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Text = player.Name .. " (抓捕者)"
    label.TextColor3 = Color3.fromRGB(255, 100, 100)
    label.Parent = bill
    bill.Parent = root
    seekerESPObjects[player] = bill
end

local function removeSeekerESP(player)
    if seekerESPObjects[player] then
        seekerESPObjects[player]:Destroy()
        seekerESPObjects[player] = nil
    end
end

local function addHiderESP(player)
    if hiderESPObjects[player] then return end
    local character = player.Character
    if not character then return end
    local head = character:FindFirstChild("Head")
    if not head then return end
    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 200, 0, 50)
    bill.AlwaysOnTop = true
    bill.StudsOffset = Vector3.new(0, 2.5, 0)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Text = player.Name .. " (躲藏者)"
    label.TextColor3 = Color3.fromRGB(100, 255, 100)
    label.Parent = bill
    bill.Parent = head
    hiderESPObjects[player] = bill
end

local function removeHiderESP(player)
    if hiderESPObjects[player] then
        hiderESPObjects[player]:Destroy()
        hiderESPObjects[player] = nil
    end
end

local function addKeyESP(key)
    if not key:IsA("Model") or not key.PrimaryPart then return end
    if keyESPObjects[key] then return end
    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 200, 0, 50)
    bill.AlwaysOnTop = true
    bill.StudsOffset = Vector3.new(0, 1, 0)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Text = key.Name .. " (钥匙)"
    label.TextColor3 = Color3.fromRGB(255, 255, 100)
    label.Parent = bill
    bill.Parent = key.PrimaryPart
    keyESPObjects[key] = bill
end

local function removeKeyESP(key)
    if keyESPObjects[key] then
        keyESPObjects[key]:Destroy()
        keyESPObjects[key] = nil
    end
end

HideSeekGroup:AddToggle('SeekerESP', {
    Text = '透视抓捕者',
    Default = false,
    Callback = function(Value)
        seekerESPEnabled = Value
        if Value then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr:GetAttribute("IsHunter") and plr.Character then
                    addSeekerESP(plr)
                end
            end
            if seekerESPPlayerAdded then pcall(function() seekerESPPlayerAdded:Disconnect() end) end
            seekerESPPlayerAdded = Players.PlayerAdded:Connect(function(plr)
                plr.CharacterAdded:Connect(function()
                    if seekerESPEnabled and plr:GetAttribute("IsHunter") then
                        addSeekerESP(plr)
                    end
                end)
                if plr:GetAttribute("IsHunter") and plr.Character then
                    addSeekerESP(plr)
                end
            end)
            table.insert(AllConnections, seekerESPPlayerAdded)
        else
            for plr, _ in pairs(seekerESPObjects) do
                removeSeekerESP(plr)
            end
            if seekerESPPlayerAdded then pcall(function() seekerESPPlayerAdded:Disconnect() end) end
            seekerESPPlayerAdded = nil
        end
    end
})

HideSeekGroup:AddToggle('HiderESP', {
    Text = '透视躲藏者',
    Default = false,
    Callback = function(Value)
        hiderESPEnabled = Value
        if Value then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr:GetAttribute("IsHider") and plr.Character then
                    addHiderESP(plr)
                end
            end
            if hiderESPPlayerAdded then pcall(function() hiderESPPlayerAdded:Disconnect() end) end
            hiderESPPlayerAdded = Players.PlayerAdded:Connect(function(plr)
                plr.CharacterAdded:Connect(function()
                    if hiderESPEnabled and plr:GetAttribute("IsHider") then
                        addHiderESP(plr)
                    end
                end)
                if plr:GetAttribute("IsHider") and plr.Character then
                    addHiderESP(plr)
                end
            end)
            table.insert(AllConnections, hiderESPPlayerAdded)
        else
            for plr, _ in pairs(hiderESPObjects) do
                removeHiderESP(plr)
            end
            if hiderESPPlayerAdded then pcall(function() hiderESPPlayerAdded:Disconnect() end) end
            hiderESPPlayerAdded = nil
        end
    end
})

HideSeekGroup:AddToggle('KeyESP', {
    Text = '透视钥匙',
    Default = false,
    Callback = function(Value)
        keyESPEnabled = Value
        if Value then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj.Name:lower():find("key") and obj.PrimaryPart then
                    addKeyESP(obj)
                end
            end
            if keyESPChildAdded then pcall(function() keyESPChildAdded:Disconnect() end) end
            keyESPChildAdded = Workspace.DescendantAdded:Connect(function(obj)
                if keyESPEnabled and obj:IsA("Model") and obj.Name:lower():find("key") and obj.PrimaryPart then
                    addKeyESP(obj)
                end
            end)
            if keyESPChildRemoved then pcall(function() keyESPChildRemoved:Disconnect() end) end
            keyESPChildRemoved = Workspace.DescendantRemoving:Connect(function(obj)
                removeKeyESP(obj)
            end)
            table.insert(AllConnections, keyESPChildAdded)
            table.insert(AllConnections, keyESPChildRemoved)
        else
            for key, _ in pairs(keyESPObjects) do
                removeKeyESP(key)
            end
            if keyESPChildAdded then pcall(function() keyESPChildAdded:Disconnect() end) end
            if keyESPChildRemoved then pcall(function() keyESPChildRemoved:Disconnect() end) end
            keyESPChildAdded = nil
            keyESPChildRemoved = nil
        end
    end
})

-- ==================== 反叛 ====================
local RebelGroup = Tabs.Game:AddRightGroupbox("反叛")
local expandHitboxEnabled = false
RebelGroup:AddToggle('ExpandHitbox', {
    Text = '扩大守卫碰撞箱',
    Default = false,
    Callback = function(Value)
        expandHitboxEnabled = Value
        if Value then
            SafeLoop("ExpandHitbox", 3, function()
                if not expandHitboxEnabled then return end
                local liveFolder = workspace:FindFirstChild("Live")
                if liveFolder then
                    for _, model in pairs(liveFolder:GetChildren()) do
                        if model:IsA("Model") and model.Name:find("Guard") then
                            local head = model:FindFirstChild("Head")
                            if head and head:IsA("BasePart") then
                                head.Size = Vector3.new(4, 4, 4)
                                head.CanCollide = false
                            end
                        end
                    end
                end
            end)
        else
            StopLoop("ExpandHitbox")
        end
    end
})

-- ==================== 旋转木马 ====================
local CarouselGroup = Tabs.Game:AddRightGroupbox("旋转木马")
CarouselGroup:AddToggle('CarouselQTE', {
    Text = '自动QTE',
    Default = false,
    Callback = function(Value)
        if Value then
            SafeLoop("CarouselQTE", 0.5, function()
                if not (Toggles.CarouselQTE and Toggles.CarouselQTE.Value) then return end
                pcall(function()
                    local char = LocalPlayer.Character
                    if char then
                        local remote = char:FindFirstChild("RemoteForQTE")
                        if remote and remote:IsA("RemoteEvent") then
                            remote:FireServer()
                        else
                            ReplicatedStorage.Replication.Event:FireServer("Clicked")
                        end
                    end
                end)
            end)
        else
            StopLoop("CarouselQTE")
        end
    end
})

-- ==================== 做任务 ====================
local TaskGroup = Tabs.Misc:AddLeftGroupbox("做任务")
TaskGroup:AddButton({
    Text = '一秒拍照（过完木头人休息阶段用）',
    Func = function()
        smoothTeleport(Vector3.new(-206.6, 187.3, 332.9))
    end,
})

local holdJumpEnabled = false
local autoJump5Enabled = false
local autoJump1Enabled = false
local autoJumpConnection = nil

local function updateAutoJump()
    if autoJumpConnection then
        pcall(function() autoJumpConnection:Disconnect() end)
        autoJumpConnection = nil
    end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if autoJump5Enabled or autoJump1Enabled then
        local power = autoJump5Enabled and 5 or 1
        hum.JumpPower = power
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        autoJumpConnection = hum.StateChanged:Connect(function(oldState, newState)
            if newState == Enum.HumanoidStateType.Landed or newState == Enum.HumanoidStateType.Running then
                local currentChar = LocalPlayer.Character
                local currentHum = currentChar and currentChar:FindFirstChildOfClass("Humanoid")
                if currentHum and currentHum.Health > 0 then
                    if autoJump5Enabled then
                        currentHum.JumpPower = 5
                        currentHum:ChangeState(Enum.HumanoidStateType.Jumping)
                    elseif autoJump1Enabled then
                        currentHum.JumpPower = 1
                        currentHum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end
        end)
        table.insert(AllConnections, autoJumpConnection)
    else
        hum.JumpPower = 50
    end
end

TaskGroup:AddToggle('HoldJump', {
    Text = '按住连跳(5)',
    Default = false,
    Callback = function(Value)
        holdJumpEnabled = Value
        if Value then
            SafeLoop("HoldJump", 0.05, function()
                if not holdJumpEnabled then return end
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    hum.JumpPower = 5
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            StopLoop("HoldJump")
        end
    end
})
TaskGroup:AddToggle('AutoJump5', {
    Text = '自动跳(5)',
    Default = false,
    Callback = function(Value)
        autoJump5Enabled = Value
        updateAutoJump()
    end
})
TaskGroup:AddToggle('AutoJump1', {
    Text = '高度1自动跳',
    Default = false,
    Callback = function(Value)
        autoJump1Enabled = Value
        updateAutoJump()
    end
})

-- ==================== 自定义标签 ====================
local customTagConnections = {}
local customTagCharacterAdded = nil
local customTagRenderLoops = {}

local function clearAllCustomTags()
    for char, conns in pairs(customTagConnections) do
        for _, conn in ipairs(conns) do
            if conn and conn.Disconnect then
                pcall(function() conn:Disconnect() end)
            end
        end
    end
    for char, thread in pairs(customTagRenderLoops) do
        if thread then
            pcall(function() task.cancel(thread) end)
        end
    end
    customTagConnections = {}
    customTagRenderLoops = {}
end

local function applyCustomTag(character)
    if customTagConnections[character] then
        for _, conn in ipairs(customTagConnections[character]) do
            if conn and conn.Disconnect then
                pcall(function() conn:Disconnect() end)
            end
        end
        if customTagRenderLoops[character] then
            pcall(function() task.cancel(customTagRenderLoops[character]) end)
        end
    end

    local torso = character:WaitForChild("Torso", 5)
    if not torso then return end
    local nametag = torso:WaitForChild("Player_Nametag", 5)
    if not nametag then return end
    local levelText = nametag:WaitForChild("LevelText", 5)
    local displayName = nametag:WaitForChild("DisplayName", 5)
    if not levelText or not displayName then return end

    local player = Players.LocalPlayer
    local isOwner = (player.Name == "Yolmar_43")

    levelText.Text = isOwner and "[ RTaOHUB - OWNER ]" or "[ RTaOHUB - MEMBER ]"

    local wave = 0
    local rainbowHue = 0
    local messages = {
        "RTaO THE BEST (dsc.gg/rtao_rs)",
        "@" .. player.Name .. " (dsc.gg/rtao_rs)"
    }
    local msgIndex = 1
    displayName.Text = messages[msgIndex]

    local messageThread = task.spawn(function()
        while character.Parent do
            task.wait(2)
            if not character.Parent then break end
            msgIndex = (msgIndex % #messages) + 1
            pcall(function() displayName.Text = messages[msgIndex] end)
        end
    end)
    customTagRenderLoops[character] = messageThread

    local renderConn = RunService.RenderStepped:Connect(function(deltaTime)
        wave = (wave + deltaTime * 2) % (2 * math.pi)
        rainbowHue = (rainbowHue + deltaTime * 0.2) % 1
        pcall(function()
            if isOwner then
                local brightness = (math.sin(wave) + 1) / 2
                levelText.TextColor3 = Color3.new(1, brightness, brightness)
            else
                local brightness = (math.sin(wave) + 1) / 2
                levelText.TextColor3 = Color3.new(brightness, 1, brightness)
            end
            displayName.TextColor3 = Color3.fromHSV(rainbowHue, 1, 1)
        end)
    end)

    local textConn = levelText:GetPropertyChangedSignal("Text"):Connect(function()
        local correctText = isOwner and "[ RTaOHUB - OWNER ]" or "[ RTaOHUB - MEMBER ]"
        if levelText.Text ~= correctText then
            levelText.Text = correctText
        end
    end)

    local ancestryConn = character.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if customTagConnections[character] then
                for _, conn in ipairs(customTagConnections[character]) do
                    if conn and conn.Disconnect then
                        pcall(function() conn:Disconnect() end)
                    end
                end
                customTagConnections[character] = nil
            end
            if customTagRenderLoops[character] then
                pcall(function() task.cancel(customTagRenderLoops[character]) end)
                customTagRenderLoops[character] = nil
            end
        end
    end)

    customTagConnections[character] = {renderConn, textConn, ancestryConn}
    table.insert(AllConnections, renderConn)
    table.insert(AllConnections, textConn)
    table.insert(AllConnections, ancestryConn)
end

-- ==================== 玩家功能 ====================
local PlayerGroup = Tabs.Misc:AddLeftGroupbox("玩家")
local noclipEnabled = false
local flyEnabled = false
local flySpeed = 50
local infiniteJumpEnabled = false
local walkSpeedEnabled = false
local walkSpeedValue = 50
local flyBodyVelocity = nil
local flyBodyGyro = nil
local flyThread = nil

PlayerGroup:AddToggle('Noclip', {
    Text = '穿墙',
    Default = false,
    Callback = function(Value)
        noclipEnabled = Value
        if Value then
            SafeLoop("Noclip", 0.1, function()
                if not noclipEnabled then return end
                local char = LocalPlayer.Character
                if char then
                    for _, child in pairs(char:GetDescendants()) do
                        if child:IsA("BasePart") and child.CanCollide then
                            child.CanCollide = false
                        end
                    end
                end
            end)
        else
            StopLoop("Noclip")
            local char = LocalPlayer.Character
            if char then
                for _, child in pairs(char:GetDescendants()) do
                    if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
                        child.CanCollide = true
                    end
                end
            end
        end
    end
})

-- 飞行：去掉PlatformStand，改用BodyGyro保持姿态
PlayerGroup:AddToggle('Fly', {
    Text = '飞行(安全版)',
    Default = false,
    Callback = function(Value)
        flyEnabled = Value
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end

        -- 清理旧的
        if flyBodyVelocity then
            pcall(function() flyBodyVelocity:Destroy() end)
            flyBodyVelocity = nil
        end
        if flyBodyGyro then
            pcall(function() flyBodyGyro:Destroy() end)
            flyBodyGyro = nil
        end
        if flyThread then
            pcall(function() task.cancel(flyThread) end)
            flyThread = nil
        end

        if Value then
            -- 不修改PlatformStand，避免冻结输入
            flyBodyGyro = Instance.new("BodyGyro")
            flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            flyBodyGyro.P = 9e4
            flyBodyGyro.CFrame = root.CFrame
            flyBodyGyro.Parent = root

            flyBodyVelocity = Instance.new("BodyVelocity")
            flyBodyVelocity.Velocity = Vector3.zero
            flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            flyBodyVelocity.Parent = root

            flyThread = task.spawn(function()
                local camera = workspace.CurrentCamera
                while flyEnabled and not Library.Unloaded do
                    local moveDir = Vector3.zero
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end

                    if flyBodyVelocity and flyBodyVelocity.Parent then
                        if moveDir.Magnitude > 0 then
                            flyBodyVelocity.Velocity = moveDir.Unit * flySpeed
                        else
                            flyBodyVelocity.Velocity = Vector3.zero
                        end
                    end
                    if flyBodyGyro and flyBodyGyro.Parent then
                        flyBodyGyro.CFrame = camera.CFrame
                    end
                    task.wait(0.05)
                end
                if flyBodyVelocity then
                    pcall(function() flyBodyVelocity:Destroy() end)
                    flyBodyVelocity = nil
                end
                if flyBodyGyro then
                    pcall(function() flyBodyGyro:Destroy() end)
                    flyBodyGyro = nil
                end
            end)
        else
            -- 恢复状态
            if flyBodyVelocity then
                pcall(function() flyBodyVelocity:Destroy() end)
                flyBodyVelocity = nil
            end
            if flyBodyGyro then
                pcall(function() flyBodyGyro:Destroy() end)
                flyBodyGyro = nil
            end
        end
    end
})

PlayerGroup:AddToggle('InfiniteJump', {
    Text = '无限跳',
    Default = false,
    Callback = function(Value) infiniteJumpEnabled = Value end
})

PlayerGroup:AddToggle('WalkSpeed', {
    Text = '加快移速',
    Default = false,
    Callback = function(Value)
        walkSpeedEnabled = Value
    end
})
PlayerGroup:AddSlider('WalkSpeedValue', {
    Text = '移动速度',
    Default = 50,
    Min = 16,
    Max = 300,
    Rounding = 0,
    Callback = function(Value) walkSpeedValue = Value end
})

PlayerGroup:AddToggle('AutoQTE', {
    Text = '自动QTE',
    Default = false,
    Callback = function(Value)
        if Value then
            SafeLoop("AutoQTE", 0.5, function()
                if not (Toggles.AutoQTE and Toggles.AutoQTE.Value) then return end
                pcall(function()
                    local char = LocalPlayer.Character
                    if char then
                        local remote = char:FindFirstChild("RemoteForQTE")
                        if remote and remote:IsA("RemoteEvent") then
                            remote:FireServer()
                        else
                            ReplicatedStorage.Replication.Event:FireServer("Clicked")
                        end
                    end
                end)
            end)
        else
            StopLoop("AutoQTE")
        end
    end
})

PlayerGroup:AddToggle('CustomNameTag', {
    Text = '自定义玩家标签',
    Default = false,
    Callback = function(Value)
        if Value then
            if LocalPlayer.Character then
                applyCustomTag(LocalPlayer.Character)
            end
            if customTagCharacterAdded then
                pcall(function() customTagCharacterAdded:Disconnect() end)
            end
            customTagCharacterAdded = LocalPlayer.CharacterAdded:Connect(function(char)
                applyCustomTag(char)
            end)
            table.insert(AllConnections, customTagCharacterAdded)
        else
            if customTagCharacterAdded then
                pcall(function() customTagCharacterAdded:Disconnect() end)
                customTagCharacterAdded = nil
            end
            clearAllCustomTags()
        end
    end
})

PlayerGroup:AddToggle('KillauraInkGame', {
    Text = '杀戮光环',
    Default = false,
    Callback = function(Value)
        if Value then
            SafeLoop("Killaura", 0.5, function()
                if not (Toggles.KillauraInkGame and Toggles.KillauraInkGame.Value) then return end
            end)
        else
            StopLoop("Killaura")
        end
    end
})

-- 防眩晕
local antiRagdollEnabled = false
local antiRagdollConnection = nil

local function bypassRagdoll(character)
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    humanoid.PlatformStand = false
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    for _, folderName in pairs({"Ragdoll", "Stun", "RotateDisabled"}) do
        local folder = character:FindFirstChild(folderName)
        if folder then folder:Destroy() end
    end
end

PlayerGroup:AddToggle('AntiRagdoll', {
    Text = '防眩晕',
    Default = false,
    Callback = function(Value)
        antiRagdollEnabled = Value
        if Value then
            if LocalPlayer.Character then
                bypassRagdoll(LocalPlayer.Character)
            end
            if antiRagdollConnection then
                pcall(function() antiRagdollConnection:Disconnect() end)
            end
            antiRagdollConnection = LocalPlayer.CharacterAdded:Connect(function(char)
                if antiRagdollEnabled then
                    bypassRagdoll(char)
                end
            end)
            table.insert(AllConnections, antiRagdollConnection)
        else
            if antiRagdollConnection then
                pcall(function() antiRagdollConnection:Disconnect() end)
                antiRagdollConnection = nil
            end
        end
    end
})

PlayerGroup:AddToggle('SpectateModeToggler', {
    Text = '开启旁观模式',
    Default = false,
    Callback = function(Value)
        local values = workspace:FindFirstChild("Values")
        if values then
            local canSpectate = values:FindFirstChild("CanSpectateIfWonGame")
            if canSpectate then
                canSpectate.Value = Value
            end
        end
    end
})

-- ==================== 移动 ====================
local MoveGroup = Tabs.Misc:AddRightGroupbox("移动")
local ghostStepEnabled = false
MoveGroup:AddToggle('GhostStep', {
    Text = '解锁幽灵步（会死）',
    Default = false,
    Callback = function(Value)
        ghostStepEnabled = Value
        if Value then
            SafeLoop("GhostStep", 0.08, function()
                if not ghostStepEnabled then return end
                pcall(function()
                    ReplicatedStorage.Remotes.RandomOtherRemotes:FireServer(nil, {})
                    ReplicatedStorage.Remotes.DashRequest:FireServer()
                end)
            end)
        else
            StopLoop("GhostStep")
        end
    end
})

-- ==================== 守卫透视 ====================
local GuardESPGroup = Tabs.Guard:AddLeftGroupbox("透视选项")
local playerESPEnabled = false
local playerESPColor = Color3.fromRGB(255, 255, 255)
local healthESPEnabled = false
local healthESPColor = Color3.fromRGB(0, 255, 0)
local distanceESPEnabled = false
local distanceESPColor = Color3.fromRGB(255, 255, 0)

local playerHighlights = {}
local playerHealthGUIs = {}
local playerDistanceGUIs = {}

local function clearESP(player)
    if playerHighlights[player] then pcall(function() playerHighlights[player]:Destroy() end) playerHighlights[player] = nil end
    if playerHealthGUIs[player] then pcall(function() playerHealthGUIs[player].bill:Destroy() end) playerHealthGUIs[player] = nil end
    if playerDistanceGUIs[player] then pcall(function() playerDistanceGUIs[player].bill:Destroy() end) playerDistanceGUIs[player] = nil end
end

local function clearAllESP()
    for player, _ in pairs(playerHighlights) do clearESP(player) end
    for player, _ in pairs(playerHealthGUIs) do clearESP(player) end
    for player, _ in pairs(playerDistanceGUIs) do clearESP(player) end
end

local function createBillboardGui(parent)
    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 200, 0, 50)
    bill.AlwaysOnTop = true
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Parent = bill
    bill.Parent = parent
    return bill, label
end

local function setupCharacterESP(player, character)
    clearESP(player)
    local head = character:FindFirstChild("Head")
    if not head then return end
    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = playerESPColor
    highlight.Adornee = character
    highlight.Parent = character
    highlight.Enabled = playerESPEnabled
    playerHighlights[player] = highlight

    local healthBill, healthLabel = createBillboardGui(head)
    healthBill.StudsOffset = Vector3.new(0, 4, 0)
    healthLabel.TextColor3 = healthESPColor
    healthBill.Enabled = healthESPEnabled
    playerHealthGUIs[player] = { bill = healthBill, label = healthLabel }

    local distBill, distLabel = createBillboardGui(head)
    distBill.StudsOffset = Vector3.new(0, 2.5, 0)
    distLabel.TextColor3 = distanceESPColor
    distBill.Enabled = distanceESPEnabled
    playerDistanceGUIs[player] = { bill = distBill, label = distLabel }

    local conn = character.AncestryChanged:Connect(function(_, parent)
        if not parent then clearESP(player) end
    end)
    table.insert(AllConnections, conn)
end

local function updateAllHighlights()
    for player, hl in pairs(playerHighlights) do
        if hl and hl.Parent then
            hl.Enabled = playerESPEnabled
            hl.OutlineColor = playerESPColor
        end
    end
end

local function updateAllHealthGUIs()
    for player, data in pairs(playerHealthGUIs) do
        if data and data.bill and data.bill.Parent then
            data.bill.Enabled = healthESPEnabled
            data.label.TextColor3 = healthESPColor
        end
    end
end

local function updateAllDistanceGUIs()
    for player, data in pairs(playerDistanceGUIs) do
        if data and data.bill and data.bill.Parent then
            data.bill.Enabled = distanceESPEnabled
            data.label.TextColor3 = distanceESPColor
        end
    end
end

local function updateHealthTexts()
    if not healthESPEnabled then return end
    for player, data in pairs(playerHealthGUIs) do
        local char = player.Character
        if char and data and data.bill and data.bill.Parent then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then data.label.Text = tostring(math.floor(hum.Health)) else data.label.Text = "?" end
        end
    end
end

local function updateDistanceTexts()
    if not distanceESPEnabled then return end
    local localChar = LocalPlayer.Character
    if not localChar then return end
    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end
    for player, data in pairs(playerDistanceGUIs) do
        local char = player.Character
        if char and data and data.bill and data.bill.Parent then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local dist = (localRoot.Position - root.Position).Magnitude
                data.label.Text = string.format("%.1fm", dist)
            else
                data.label.Text = "?m"
            end
        end
    end
end

local function onCharacterAdded(player, character) setupCharacterESP(player, character) end
local function onPlayerAdded(player)
    if player == LocalPlayer then return end
    if player.Character then onCharacterAdded(player, player.Character) end
    local conn = player.CharacterAdded:Connect(function(char) onCharacterAdded(player, char) end)
    table.insert(AllConnections, conn)
end
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then onPlayerAdded(player) end
end
local playerAddedConn = Players.PlayerAdded:Connect(onPlayerAdded)
table.insert(AllConnections, playerAddedConn)

local playerESP = GuardESPGroup:AddToggle('PlayerESP', {
    Text = '人物透视',
    Default = false,
    Callback = function(Value) playerESPEnabled = Value; updateAllHighlights() end
})
if playerESP and playerESP.AddColorPicker then
    playerESP:AddColorPicker('PlayerESPColor', {
        Default = Color3.fromRGB(255, 255, 255), Title = '人物透视颜色',
        Callback = function(Value) playerESPColor = Value; if playerESPEnabled then updateAllHighlights() end end
    })
else
    GuardESPGroup:AddColorPicker('PlayerESPColor', {
        Default = Color3.fromRGB(255, 255, 255), Title = '人物透视颜色',
        Callback = function(Value) playerESPColor = Value; if playerESPEnabled then updateAllHighlights() end end
    })
end

local healthESP = GuardESPGroup:AddToggle('HealthESP', {
    Text = '血量透视', Default = false,
    Callback = function(Value) healthESPEnabled = Value; updateAllHealthGUIs() end
})
if healthESP and healthESP.AddColorPicker then
    healthESP:AddColorPicker('HealthESPColor', {
        Default = Color3.fromRGB(0, 255, 0), Title = '血量透视颜色',
        Callback = function(Value) healthESPColor = Value; if healthESPEnabled then updateAllHealthGUIs() end end
    })
else
    GuardESPGroup:AddColorPicker('HealthESPColor', {
        Default = Color3.fromRGB(0, 255, 0), Title = '血量透视颜色',
        Callback = function(Value) healthESPColor = Value; if healthESPEnabled then updateAllHealthGUIs() end end
    })
end

local distanceESP = GuardESPGroup:AddToggle('DistanceESP', {
    Text = '距离透视', Default = false,
    Callback = function(Value) distanceESPEnabled = Value; updateAllDistanceGUIs() end
})
if distanceESP and distanceESP.AddColorPicker then
    distanceESP:AddColorPicker('DistanceESPColor', {
        Default = Color3.fromRGB(255, 255, 0), Title = '距离透视颜色',
        Callback = function(Value) distanceESPColor = Value; if distanceESPEnabled then updateAllDistanceGUIs() end end
    })
else
    GuardESPGroup:AddColorPicker('DistanceESPColor', {
        Default = Color3.fromRGB(255, 255, 0), Title = '距离透视颜色',
        Callback = function(Value) distanceESPColor = Value; if distanceESPEnabled then updateAllDistanceGUIs() end end
    })
end

-- ==================== 守卫功能 ====================
local GuardAimGroup = Tabs.Guard:AddRightGroupbox("守卫功能")
local aimNearestPlayerEnabled = false
local aimNearestViolatorEnabled = false
local violationKeywords = {
    "违规", "处罚", "惩罚", "violation", "penalty", "punish", "infraction",
    "нарушение", "наказание", "штраф", "infracción", "castigo", "multa",
    "infraction", "sanction", "strafe", "suspensión", "expulsión"
}

local function getNearestPlayerTarget()
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local nearest, minDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local dist = (root.Position - targetRoot.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = targetRoot
                end
            end
        end
    end
    return nearest
end

local function getNearestViolatorTarget()
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local nearest, minDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local guiText = ""
            pcall(function()
                if plr.PlayerGui then
                    for _, screen in ipairs(plr.PlayerGui:GetChildren()) do
                        for _, obj in ipairs(screen:GetDescendants()) do
                            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                                guiText = guiText .. obj.Text
                            end
                        end
                    end
                end
            end)
            local isViolator = false
            for _, kw in ipairs(violationKeywords) do
                if guiText:lower():find(kw:lower(), 1, true) then
                    isViolator = true
                    break
                end
            end
            if isViolator then
                local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    local dist = (root.Position - targetRoot.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        nearest = targetRoot
                    end
                end
            end
        end
    end
    return nearest
end

GuardAimGroup:AddToggle('AimNearestPlayer', {
    Text = '自瞄最近的玩家',
    Default = false,
    Callback = function(Value)
        aimNearestPlayerEnabled = Value
    end
})

GuardAimGroup:AddToggle('AimNearestViolator', {
    Text = '自瞄最近的违规玩家',
    Default = false,
    Callback = function(Value)
        aimNearestViolatorEnabled = Value
    end
})

local aimRenderConn = RunService.RenderStepped:Connect(function()
    if aimNearestPlayerEnabled then
        local targetRoot = getNearestPlayerTarget()
        if targetRoot then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetRoot.Position)
        end
    elseif aimNearestViolatorEnabled then
        local targetRoot = getNearestViolatorTarget()
        if targetRoot then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetRoot.Position)
        end
    end
end)
table.insert(AllConnections, aimRenderConn)

local autoAttackEnabled = false
GuardAimGroup:AddToggle('AutoAttack', {
    Text = '自动攻击',
    Default = false,
    Callback = function(Value)
        autoAttackEnabled = Value
        if Value then
            SafeLoop("AutoAttack", 0.1, function()
                if not autoAttackEnabled then return end
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        pcall(function()
                            local remote = ReplicatedStorage.Remotes:FindFirstChild("DamageRemote") or ReplicatedStorage.Remotes:FindFirstChild("Attack")
                            if remote then
                                remote:FireServer(plr.Character)
                            end
                        end)
                    end
                end
            end)
        else
            StopLoop("AutoAttack")
        end
    end
})

-- ==================== 投掷光环（不禁用Main脚本） ====================
local flingAuraActive = false
local flingAuraThread = nil

local function getRoot(character)
    return character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso"))
end

local function startFlingAura()
    if flingAuraActive then return end
    flingAuraActive = true
    Library:Notify("投掷光环已启用(安全模式)", 3)
    flingAuraThread = task.spawn(function()
        while flingAuraActive and not Library.Unloaded do
            local character = LocalPlayer.Character
            local root = getRoot(character)
            if character and root and root.Parent then
                local originalVel = root.Velocity
                root.Velocity = originalVel * 300 + Vector3.new(0, 300, 0)
                task.wait(0.05)
                if character and root and root.Parent then
                    root.Velocity = originalVel
                end
                task.wait(0.05)
                if character and root and root.Parent then
                    root.Velocity = originalVel + Vector3.new(0, 0.3, 0)
                end
            end
            task.wait(0.1)
        end
    end)
end

local function stopFlingAura()
    flingAuraActive = false
    if flingAuraThread then
        pcall(function() task.cancel(flingAuraThread) end)
        flingAuraThread = nil
    end
    Library:Notify("投掷光环已禁用", 3)
end

GuardAimGroup:AddToggle('FlingAura', {
    Text = '投掷光环',
    Default = false,
    Callback = function(Value)
        if Value then
            startFlingAura()
        else
            stopFlingAura()
        end
    end
})

-- ==================== 性能 ====================
local PerformanceGroup = Tabs.Misc:AddRightGroupbox("性能")
PerformanceGroup:AddToggle('LowGFX', {
    Text = '降低画质',
    Default = false,
    Callback = function(Value)
        if Value then
            if workspace:FindFirstChild("Effects") then
                workspace.Effects:ClearAllChildren()
            end
        end
    end
})

local disableEffectsEnabled = false
local disableEffectsConnection = nil
PerformanceGroup:AddToggle('DisableEffects', {
    Text = '禁用特效',
    Default = false,
    Callback = function(Value)
        disableEffectsEnabled = Value
        if Value then
            if workspace:FindFirstChild("Effects") then
                workspace.Effects:ClearAllChildren()
                if disableEffectsConnection then
                    pcall(function() disableEffectsConnection:Disconnect() end)
                end
                disableEffectsConnection = workspace.Effects.ChildAdded:Connect(function(child)
                    child:Destroy()
                end)
                table.insert(AllConnections, disableEffectsConnection)
            end
        else
            if disableEffectsConnection then
                pcall(function() disableEffectsConnection:Disconnect() end)
                disableEffectsConnection = nil
            end
        end
    end
})

-- ==================== 安全 ====================
local SafetyGroup = Tabs.Misc:AddRightGroupbox("安全")
local safe1Enabled = true
local safe2Enabled = true

local antiAfkConnection = nil
local function enableAntiAfk()
    if antiAfkConnection then return end
    antiAfkConnection = LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(0.1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
    table.insert(AllConnections, antiAfkConnection)
end
local function disableAntiAfk()
    if antiAfkConnection then
        pcall(function() antiAfkConnection:Disconnect() end)
        antiAfkConnection = nil
    end
end

local staffDetectorConnections = {}
local detectedStaff = {}
local STAFF_GROUP_ID = 12398672
local STAFF_MIN_RANK = 120
local staffRoles = {
    [120] = "moderator",
    [254] = "dev",
    [255] = "owner"
}

local function checkPlayerStaff(player)
    local success, rank = pcall(function()
        return player:GetRankInGroup(STAFF_GROUP_ID)
    end)
    if success and rank and rank >= STAFF_MIN_RANK then
        local roleName = staffRoles[rank] or ("rank " .. tostring(rank))
        Library:Notify("[安全] 管理员进入: " .. player.Name .. " (" .. roleName .. ")", 10)
        detectedStaff[player.UserId] = {Name = player.Name, Role = roleName}
        return true
    end
    return false
end

local function enableStaffDetector()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            checkPlayerStaff(player)
        end
    end
    if staffDetectorConnections.PlayerAdded then
        pcall(function() staffDetectorConnections.PlayerAdded:Disconnect() end)
    end
    if staffDetectorConnections.PlayerRemoving then
        pcall(function() staffDetectorConnections.PlayerRemoving:Disconnect() end)
    end
    staffDetectorConnections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            task.wait(1)
            checkPlayerStaff(player)
        end
    end)
    staffDetectorConnections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
        local staffInfo = detectedStaff[player.UserId]
        if staffInfo then
            Library:Notify("[安全] 管理员离开: " .. staffInfo.Name .. " (" .. staffInfo.Role .. ")", 10)
            detectedStaff[player.UserId] = nil
        end
    end)
    table.insert(AllConnections, staffDetectorConnections.PlayerAdded)
    table.insert(AllConnections, staffDetectorConnections.PlayerRemoving)
end

local function disableStaffDetector()
    for _, conn in pairs(staffDetectorConnections) do
        pcall(function() conn:Disconnect() end)
    end
    staffDetectorConnections = {}
    detectedStaff = {}
end

SafetyGroup:AddToggle('Safe1', {
    Text = '安全1（别关）',
    Default = true,
    Callback = function(Value)
        safe1Enabled = Value
        if Value then
            enableAntiAfk()
        else
            disableAntiAfk()
        end
    end
})

SafetyGroup:AddToggle('Safe2', {
    Text = '安全2（别关）',
    Default = true,
    Callback = function(Value)
        safe2Enabled = Value
        if Value then
            enableStaffDetector()
        else
            disableStaffDetector()
        end
    end
})

enableAntiAfk()
enableStaffDetector()

SafeLoop("SafeHeartbeat", 2, function()
    if safe1Enabled then
        pcall(function()
            ReplicatedStorage.Replication.Event:FireServer("Clicked")
            ReplicatedStorage.Remotes.JoeGurtEvent:FireServer({})
        end)
    end
end)

-- ==================== 全局心跳 ====================
local heartbeatConn = RunService.Heartbeat:Connect(function()
    updateHealthTexts()
    updateDistanceTexts()
    if godModeEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
        end
    end
end)
table.insert(AllConnections, heartbeatConn)

local steppedConn = RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if walkSpeedEnabled then
                hum.WalkSpeed = walkSpeedValue
            else
                hum.WalkSpeed = 16
            end
        end
    end
end)
table.insert(AllConnections, steppedConn)

local jumpConn = UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)
table.insert(AllConnections, jumpConn)

local charAddedConn = LocalPlayer.CharacterAdded:Connect(function()
    holdJumpEnabled = false
    updateAutoJump()
end)
table.insert(AllConnections, charAddedConn)

-- ==================== 设置 ====================
local MenuGroup = Tabs.Settings:AddLeftGroupbox('菜单')
MenuGroup:AddButton('卸载脚本', function()
    clearAllESP()
    clearAllCustomTags()
    DisconnectAll()

    if flyBodyVelocity then
        pcall(function() flyBodyVelocity:Destroy() end)
    end
    if flyBodyGyro then
        pcall(function() flyBodyGyro:Destroy() end)
    end
    if flyThread then
        pcall(function() task.cancel(flyThread) end)
    end

    stopFlingAura()
    Library:Unload()
end)

MenuGroup:AddButton('重载界面', function()
    loadstring(game:HttpGet("https://pastebin.com/raw/你的脚本地址"))()
end)
MenuGroup:AddLabel('菜单快捷键'):AddKeyPicker('MenuKeybind', {
    Default = 'RightShift', NoUI = true, Text = 'Menu keybind'
})
Library.ToggleKeybind = Library.Options.MenuKeybind

if ThemeManager then
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("墨水游戏脚本_主题")
    ThemeManager:ApplyToTab(Tabs.Settings)
end
if SaveManager then
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetFolder("墨水游戏脚本_配置")
    SaveManager:BuildConfigSection(Tabs.Settings)
end
