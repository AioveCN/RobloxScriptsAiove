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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local MeleeSpam = false
local SwingDelay = 0.05
local SwingsPerDelay = 2
local ClientMeleeHandler = nil
local originalHandler = nil
local currentMeleeTool = nil
local currentAttackTime = nil
local currentLookVector = nil
local swingThread = nil

local AutoAttack = false
local AutoAttackDelay = 0.05
local autoAttackThread = nil

local AutoInteract = false
local autoInteractThread = nil

local BringItems = false
local BringDelay = 0.1
local bringThread = nil
local collectedItems = {}
local totalItems = 0
local itemsBrought = 0
local cachedItems = {}
local cacheUpdateTime = 0

local InfiniteStamina = false
local staminaThread = nil

local DoubleJump = false
local jumpCount = 0
local lastJumpTime = 0

local WalkSpeed = 16
local speedThread = nil

local NightVision = false
local nightVisionThread = nil

local AutoStore = false
local autoStoreThread = nil

local AutoDrop = false
local autoDropThread = nil

local AutoBandage = false
local autoBandageThread = nil
local BandageHealth = 30

local AutoEndGame = false
local autoEndGameThread = nil

local AutoTrainHorn = false
local autoTrainHornThread = nil

local AutoWalkBond = false
local autoWalkBondThread = nil

local AutoCollectBond = false
local autoCollectBondThread = nil

local AutoCollectItem = false
local autoCollectItemThread = nil

local AutoCollectMoneybag = false
local autoCollectMoneybagThread = nil

local MonsterPredict = false
local monsterPredictThread = nil
local lastMonsterCount = 0

local FuelGuiEnabled = false
local fuelGui = nil
local fuelThread = nil

local InstantInteract = false
local RemoteInteract = false
local NoLOSInteract = false
local oldPromptDurations = {}
local oldPromptDistances = {}
local oldPromptLOS = {}

local DeleteDecor = false
local deleteDecorThread = nil

local DeleteLightning = false
local deleteLightningThread = nil

local ESPItems = false
local espItemsConn = nil
local ESPOre = false
local espOreConn = nil
local ESPNightEnemy = false
local espNightEnemyConn = nil
local ESPUnicorn = false
local espUnicornConn = nil
local ESPBuilding = false
local espBuildingConn = nil
local ESPZombie = false
local espZombieConn = nil
local ESPBank = false
local espBankConn = nil
local ESPOutlaw = false
local espOutlawConn = nil
local ESPBond = false
local espBondConn = nil

local TranslationEnabled = false
local TranslationSpeed = 5
local translatedTexts = {}
local heartbeatConnection = nil
local playerGuiConnection = nil
local coreGuiConnection = nil
local lastScanTime = 0
local scanInterval = 0.3

local modelInstanceNames = {
    "ModelInstance", "modelinstance", "MODELINSTANCE",
    "Modelinstance", "modelInstance", "Model_Instance",
    "model_instance", "MODEL_INSTANCE",
    "Model Instance", "model instance", "MODEL INSTANCE",
    "Model-Instance", "model-instance", "MODEL-INSTANCE",
    "ModelInstance1", "modelinstance1", "MODELINSTANCE1",
    "ModelInstace", "modelinstace", "MODELINSTACE",
    "ModelInstanse", "modelinstanse", "MODELINSTANSE",
    "ModelInstence", "modelinstence", "MODELINSTENCE",
    "ModelInstancee", "modelinstancee", "MODELINSTANCEE",
    "ModelInstanec", "modelinstanec", "MODELINSTANEC",
    "ModelInstanc", "modelinstanc", "MODELINSTANC",
    "ModelInstancE", "modelInstancE",
    "ModelIstance", "modelistance", "MODELISTANCE",
    "ModelIstanse", "modelistanse", "MODELISTANSE",
    "ModelIstence", "modelistence", "MODELISTENCE",
    "ModelIstanc", "modelistanc", "MODELISTANC",
}

local function isModelInstanceName(name)
    for _, variant in ipairs(modelInstanceNames) do
        if name == variant then return true end
    end
    return false
end

local function getItemPart(item)
    if item:IsA("BasePart") then
        return item
    end
    if item:IsA("Model") then
        if item.PrimaryPart then
            return item.PrimaryPart
        end
        for _, child in ipairs(item:GetDescendants()) do
            if child:IsA("BasePart") then
                return child
            end
        end
    end
    return nil
end

local function updateItemCache()
    cachedItems = {}
    local seen = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isModelInstanceName(obj.Name) then
            local item = nil
            if obj:IsA("Model") or obj:IsA("BasePart") then
                item = obj
            elseif obj.Parent and (obj.Parent:IsA("Model") or obj.Parent:IsA("BasePart")) then
                item = obj.Parent
            end
            if item and not seen[item] then
                seen[item] = true
                local part = getItemPart(item)
                if part then
                    table.insert(cachedItems, { Model = item, Part = part })
                end
            end
        end
    end
    cacheUpdateTime = tick()
end

local function getCachedItems()
    if tick() - cacheUpdateTime > 3 then
        updateItemCache()
    end
    return cachedItems
end

local function fireActionable(target)
    pcall(function()
        ReplicatedStorage.Shared.Universe.Network.RemoteEvent.Actionable:FireServer(418)
    end)
    if target then
        pcall(function()
            ReplicatedStorage.Shared.Universe.Network.RemoteEvent.Actionable:FireServer(418, target)
        end)
        pcall(function()
            ReplicatedStorage.Shared.Universe.Network.RemoteEvent.Actionable:FireServer(418, target.Name)
        end)
        pcall(function()
            ReplicatedStorage.Shared.Universe.Network.RemoteEvent.Actionable:FireServer(418, target.Position)
        end)
        pcall(function()
            ReplicatedStorage.Shared.Universe.Network.RemoteEvent.Actionable:FireServer(418, target.CFrame)
        end)
    end
end

local function fireStore(target)
    pcall(function()
        ReplicatedStorage.Shared.Universe.Network.RemoteEvent.Store:FireServer(397)
    end)
    if target then
        pcall(function()
            ReplicatedStorage.Shared.Universe.Network.RemoteEvent.Store:FireServer(397, target)
        end)
        pcall(function()
            ReplicatedStorage.Shared.Universe.Network.RemoteEvent.Store:FireServer(397, target.Name)
        end)
        pcall(function()
            ReplicatedStorage.Shared.Universe.Network.RemoteEvent.Store:FireServer(397, target.Position)
        end)
        pcall(function()
            ReplicatedStorage.Shared.Universe.Network.RemoteEvent.Store:FireServer(397, target.CFrame)
        end)
    end
end

local function safeGetMeleeHandler()
    local success, module = pcall(function()
        return require(ReplicatedStorage:WaitForChild("Client"):WaitForChild("Game"):WaitForChild("Melee"):WaitForChild("ClientMeleeHandler"))
    end)
    if success and module then
        ClientMeleeHandler = module
        originalHandler = module._meleeActionHandler
    end
end
safeGetMeleeHandler()

local function Swing()
    if not currentMeleeTool or not currentAttackTime or not currentLookVector then return end
    pcall(function()
        ReplicatedStorage.Shared.Universe.Network.RemoteEvent.SwingMelee:FireServer(
            currentMeleeTool, currentAttackTime, currentLookVector
        )
    end)
end

if ClientMeleeHandler then
    ClientMeleeHandler._meleeActionHandler = function(actionName, inputState, inputObject)
        if MeleeSpam then
            if inputState == Enum.UserInputState.Begin then
                local char = LocalPlayer.Character
                if char then
                    currentMeleeTool = char:FindFirstChildWhichIsA("Tool")
                    if currentMeleeTool then
                        currentAttackTime = workspace:GetServerTimeNow()
                        local mouse = LocalPlayer:GetMouse()
                        currentLookVector = (mouse.Hit and mouse.Hit.LookVector) or char:GetPivot().LookVector

                        swingThread = task.spawn(function()
                            while MeleeSpam and currentMeleeTool do
                                for i = 1, SwingsPerDelay do
                                    Swing()
                                    task.wait(SwingDelay)
                                end
                            end
                        end)
                    end
                end
            elseif inputState == Enum.UserInputState.End then
                if swingThread then
                    task.cancel(swingThread)
                    swingThread = nil
                end
            end
        end

        if not MeleeSpam and originalHandler then
            return originalHandler(actionName, inputState, inputObject)
        end
    end
end

local function translateText(text)
    if not text or text == "" or #text < 2 then
        return nil
    end
    if translatedTexts[text] then
        return translatedTexts[text]
    end
    local success, result = pcall(function()
        local url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=zh-CN&dt=t&q=" .. HttpService:UrlEncode(text)
        local response = game:HttpGet(url)
        local decoded = HttpService:JSONDecode(response)
        if decoded and decoded[1] and decoded[1][1] and decoded[1][1][1] then
            return decoded[1][1][1]
        end
        return nil
    end)
    if success and result then
        translatedTexts[text] = result
        return result
    end
    return nil
end

local function isEnglish(text)
    if not text or text == "" then
        return false
    end
    local englishCount = 0
    local totalCount = 0
    for char in text:gmatch(".") do
        local byte = string.byte(char)
        if byte then
            totalCount = totalCount + 1
            if (byte >= 65 and byte <= 90) or (byte >= 97 and byte <= 122) then
                englishCount = englishCount + 1
            end
        end
    end
    if totalCount == 0 then
        return false
    end
    return (englishCount / totalCount) > 0.5
end

local function processTextObject(textObject)
    if not TranslationEnabled then
        return
    end
    if not textObject:IsA("TextLabel") and not textObject:IsA("TextButton") and not textObject:IsA("TextBox") then
        return
    end
    local originalText = textObject.Text
    if not originalText or originalText == "" then
        return
    end
    if not isEnglish(originalText) then
        return
    end
    local translatedText = translateText(originalText)
    if translatedText and translatedText ~= originalText then
        textObject.Text = translatedText
    end
end

local function scanAndTranslate(parent)
    if not TranslationEnabled then
        return
    end
    for _, descendant in pairs(parent:GetDescendants()) do
        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
            task.spawn(function()
                processTextObject(descendant)
            end)
        end
    end
end

local function onDescendantAdded(descendant)
    if not TranslationEnabled then
        return
    end
    if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
        task.delay(0.1, function()
            processTextObject(descendant)
        end)
    end
end

local function startTranslation()
    if playerGuiConnection then
        playerGuiConnection:Disconnect()
    end
    if coreGuiConnection then
        coreGuiConnection:Disconnect()
    end
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
    end
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    playerGuiConnection = PlayerGui.DescendantAdded:Connect(onDescendantAdded)
    coreGuiConnection = CoreGui.DescendantAdded:Connect(onDescendantAdded)
    lastScanTime = tick()
    scanInterval = 1.5 / TranslationSpeed
    heartbeatConnection = RunService.Heartbeat:Connect(function()
        if not TranslationEnabled then
            return
        end
        local currentTime = tick()
        if currentTime - lastScanTime >= scanInterval then
            lastScanTime = currentTime
            task.spawn(function()
                scanAndTranslate(PlayerGui)
            end)
            pcall(function()
                for _, gui in pairs(CoreGui:GetChildren()) do
                    if gui:IsA("ScreenGui") then
                        task.spawn(function()
                            scanAndTranslate(gui)
                        end)
                    end
                end
            end)
        end
    end)
    scanAndTranslate(PlayerGui)
    pcall(function()
        for _, gui in pairs(CoreGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                scanAndTranslate(gui)
            end
        end
    end)
end

local function stopTranslation()
    if playerGuiConnection then
        playerGuiConnection:Disconnect()
        playerGuiConnection = nil
    end
    if coreGuiConnection then
        coreGuiConnection:Disconnect()
        coreGuiConnection = nil
    end
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end
end

local Window = Library:CreateWindow({
    Title = "死铁轨",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify("死铁轨 - 创作者：Aiove | QQ：3999698324", 5)

local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Main = Window:AddTab("功能", "zap"),
    Auto = Window:AddTab("自动", "repeat"),
    ESP = Window:AddTab("透视", "eye"),
    Interact = Window:AddTab("交互", "mouse-pointer-2"),
    Bond = Window:AddTab("刷债券", "banknote"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel('Aiove将持续更新此脚本')
NoticeGroup:AddLabel('创作者：Aiove')
NoticeGroup:AddLabel('QQ：3999698324')

local MeleeGroup = Tabs.Main:AddLeftGroupbox("近战杀戮")
MeleeGroup:AddToggle('MeleeSpam', {
    Text = '极速连砍',
    Default = false,
}):OnChanged(function(value)
    if value then
        MeleeSpam = true
        Library:Notify("近战杀戮已启用", 2)
    else
        MeleeSpam = false
        if swingThread then
            task.cancel(swingThread)
            swingThread = nil
        end
        Library:Notify("近战杀戮已关闭", 2)
    end
end)

MeleeGroup:AddLabel('[使用说明] 长按攻击')

local AutoAttackGroup = Tabs.Main:AddLeftGroupbox("自动攻击")
AutoAttackGroup:AddToggle('AutoAttack', {
    Text = '自动攻击',
    Default = false,
}):OnChanged(function(value)
    if value then
        AutoAttack = true
        autoAttackThread = task.spawn(function()
            while AutoAttack do
                local char = LocalPlayer.Character
                if char then
                    local tool = char:FindFirstChildWhichIsA("Tool")
                    if tool then
                        local attackTime = workspace:GetServerTimeNow()
                        local lookVector = char:GetPivot().LookVector
                        pcall(function()
                            ReplicatedStorage.Shared.Universe.Network.RemoteEvent.SwingMelee:FireServer(
                                tool, attackTime, lookVector
                            )
                        end)
                    end
                end
                task.wait(AutoAttackDelay)
            end
        end)
        Library:Notify("自动攻击已启用", 2)
    else
        AutoAttack = false
        if autoAttackThread then
            task.cancel(autoAttackThread)
            autoAttackThread = nil
        end
        Library:Notify("自动攻击已关闭", 2)
    end
end)

AutoAttackGroup:AddSlider('AutoAttackDelay', {
    Text = '攻击频率',
    Default = 0.05,
    Min = 0.001,
    Max = 0.5,
    Rounding = 3,
}):OnChanged(function(value)
    AutoAttackDelay = value
end)

local StaminaGroup = Tabs.Main:AddLeftGroupbox("无限体力")
StaminaGroup:AddToggle('InfiniteStamina', {
    Text = '无限体力（回拉）',
    Default = false,
}):OnChanged(function(value)
    if value then
        InfiniteStamina = true
        staminaThread = task.spawn(function()
            while InfiniteStamina do
                pcall(function()
                    ReplicatedStorage.Remotes.RequestSprint:FireServer(false)
                end)
                task.wait(0.1)
            end
        end)
        Library:Notify("无限体力已启用", 2)
    else
        InfiniteStamina = false
        if staminaThread then
            task.cancel(staminaThread)
            staminaThread = nil
        end
        pcall(function()
            ReplicatedStorage.Remotes.RequestSprint:FireServer(true)
        end)
        Library:Notify("无限体力已关闭", 2)
    end
end)

local JumpGroup = Tabs.Main:AddLeftGroupbox("二段跳")
JumpGroup:AddToggle('DoubleJump', {
    Text = '二段跳（不回拉）',
    Default = false,
}):OnChanged(function(value)
    if value then
        DoubleJump = true
        jumpCount = 0
        lastJumpTime = 0
        Library:Notify("二段跳已启用", 2)
    else
        DoubleJump = false
        jumpCount = 0
        Library:Notify("二段跳已关闭", 2)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if not DoubleJump then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    local now = tick()
    if hum.FloorMaterial ~= Enum.Material.Air then
        jumpCount = 0
    end

    if jumpCount < 1 then
        jumpCount = jumpCount + 1
        lastJumpTime = now
    elseif jumpCount == 1 and (now - lastJumpTime) < 1.5 then
        jumpCount = jumpCount + 1
        hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z)
    end
end)

local BringGroup = Tabs.Main:AddRightGroupbox("拉取物品")
BringGroup:AddToggle('BringItems', {
    Text = '拉取全图物品（疑似没有用）',
    Default = false,
}):OnChanged(function(value)
    if value then
        BringItems = true
        collectedItems = {}
        itemsBrought = 0
        totalItems = 0
        updateItemCache()
        totalItems = #cachedItems

        bringThread = task.spawn(function()
            while BringItems do
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    local items = getCachedItems()
                    local closest = nil
                    local closestDist = math.huge

                    for _, item in ipairs(items) do
                        if not collectedItems[item.Model] then
                            local dist = (item.Part.Position - root.Position).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                closest = item
                            end
                        end
                    end

                    if closest then
                        collectedItems[closest.Model] = true
                        itemsBrought = itemsBrought + 1

                        for i = 1, 2 do
                            fireStore(closest.Part)
                            task.wait(0.05)
                        end

                        if itemsBrought % 10 == 0 then
                            Library:Notify(itemsBrought .. "/" .. totalItems, 2)
                        end
                    else
                        task.wait(0.5)
                    end
                else
                    task.wait(0.1)
                end
                task.wait(BringDelay)
            end
        end)

        Library:Notify("拉取全图物品已启用 发现" .. totalItems .. "个", 2)
    else
        BringItems = false
        if bringThread then
            task.cancel(bringThread)
            bringThread = nil
        end
        Library:Notify("拉取全图物品已关闭", 2)
    end
end)

BringGroup:AddSlider('BringDelay', {
    Text = '拉取速度',
    Default = 0.1,
    Min = 0.01,
    Max = 2,
    Rounding = 2,
}):OnChanged(function(value)
    BringDelay = value
end)

local InteractGroup = Tabs.Main:AddRightGroupbox("自动交互")
InteractGroup:AddToggle('AutoInteract', {
    Text = '自动交互（点购买）',
    Default = false,
}):OnChanged(function(value)
    if value then
        AutoInteract = true
        updateItemCache()
        autoInteractThread = task.spawn(function()
            while AutoInteract do
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local target = nil
                local closestDist = math.huge

                if root then
                    local items = getCachedItems()
                    for _, item in ipairs(items) do
                        local dist = (item.Part.Position - root.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            target = item.Part
                        end
                    end
                end

                fireActionable(target)
                task.wait(0.05)
            end
        end)
        Library:Notify("自动交互已启用", 2)
    else
        AutoInteract = false
        if autoInteractThread then
            task.cancel(autoInteractThread)
            autoInteractThread = nil
        end
        Library:Notify("自动交互已关闭", 2)
    end
end)

local ReviveGroup = Tabs.Main:AddRightGroupbox("复活")
ReviveGroup:AddButton("发起自我复活购买", function()
    pcall(function()
        ReplicatedStorage.Remotes.RevivePlayer:FireServer()
    end)
    Library:Notify("已发起自我复活购买", 2)
end)

local SpeedGroup = Tabs.Main:AddRightGroupbox("修改移速")
SpeedGroup:AddSlider('WalkSpeed', {
    Text = '移速',
    Default = 16,
    Min = 5,
    Max = 20,
    Rounding = 0,
}):OnChanged(function(value)
    WalkSpeed = value
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = value
        end
    end
    if speedThread then
        task.cancel(speedThread)
        speedThread = nil
    end
    speedThread = task.spawn(function()
        while true do
            local c = LocalPlayer.Character
            if c then
                local h = c:FindFirstChildOfClass("Humanoid")
                if h and h.WalkSpeed ~= WalkSpeed then
                    h.WalkSpeed = WalkSpeed
                end
            end
            task.wait(0.1)
        end
    end)
    Library:Notify("移速已设置为 " .. value, 2)
end)

local NightVisionGroup = Tabs.Main:AddRightGroupbox("夜视")
NightVisionGroup:AddToggle('NightVision', {
    Text = '夜视',
    Default = false,
}):OnChanged(function(value)
    if value then
        NightVision = true
        nightVisionThread = task.spawn(function()
            while NightVision do
                Lighting.Ambient = Color3.new(1, 1, 1)
                Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
                Lighting.ColorShift_Top = Color3.new(1, 1, 1)
                Lighting.FogEnd = 100000
                Lighting.FogStart = 100000
                Lighting.Brightness = 1
                Lighting.GlobalShadows = false
                Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
                Lighting.ClockTime = 12
                task.wait(0.5)
            end
        end)
        Library:Notify("夜视已启用", 2)
    else
        NightVision = false
        if nightVisionThread then
            task.cancel(nightVisionThread)
            nightVisionThread = nil
        end
        Lighting.Ambient = Color3.new(0, 0, 0)
        Lighting.ColorShift_Bottom = Color3.new(0, 0, 0)
        Lighting.ColorShift_Top = Color3.new(0, 0, 0)
        Lighting.FogEnd = 1000
        Lighting.FogStart = 0
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
        Lighting.OutdoorAmbient = Color3.new(0.7, 0.7, 0.7)
        Library:Notify("夜视已关闭", 2)
    end
end)

local FuelGroup = Tabs.Main:AddRightGroupbox("火车燃料")
FuelGroup:AddToggle('FuelGuiEnabled', {
    Text = '显示燃油状态',
    Default = false,
}):OnChanged(function(value)
    if value then
        FuelGuiEnabled = true
        if not fuelGui then
            fuelGui = Instance.new("ScreenGui")
            fuelGui.Name = "FuelGui"
            fuelGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            fuelGui.Parent = CoreGui
            local label = Instance.new("TextLabel")
            label.Name = "FuelLabel"
            label.BackgroundColor3 = Color3.new(1, 1, 1)
            label.BackgroundTransparency = 1
            label.BorderColor3 = Color3.new(0, 0, 0)
            label.Position = UDim2.new(0.5, 0, 0.5, -100)
            label.Size = UDim2.new(0, 200, 0, 50)
            label.Font = Enum.Font.GothamSemibold
            label.Text = "燃料: 0 / 240"
            label.TextColor3 = Color3.new(1, 1, 1)
            label.TextScaled = true
            label.TextSize = 14
            label.TextWrapped = true
            label.Parent = fuelGui
        end
        fuelGui.Enabled = true
        fuelThread = task.spawn(function()
            while FuelGuiEnabled do
                pcall(function()
                    local train = Workspace:FindFirstChild("Train")
                    if train then
                        local fuel = train:FindFirstChild("Fuel")
                        if fuel then
                            local fuelValue = fuel.Value
                            fuelGui.FuelLabel.Text = "燃料: " .. fuelValue .. " / 240"
                            if fuelValue <= 50 then
                                fuelGui.FuelLabel.TextColor3 = Color3.new(1, 0, 0)
                            elseif fuelValue <= 150 then
                                fuelGui.FuelLabel.TextColor3 = Color3.new(1, 165/255, 0)
                            else
                                fuelGui.FuelLabel.TextColor3 = Color3.new(0, 1, 0)
                            end
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
        Library:Notify("燃油状态显示已启用", 2)
    else
        FuelGuiEnabled = false
        if fuelThread then
            task.cancel(fuelThread)
            fuelThread = nil
        end
        if fuelGui then
            fuelGui.Enabled = false
        end
        Library:Notify("燃油状态显示已关闭", 2)
    end
end)

local MonsterGroup = Tabs.Main:AddRightGroupbox("怪物预知")
MonsterGroup:AddToggle('MonsterPredict', {
    Text = '预知今晚怪物',
    Default = false,
}):OnChanged(function(value)
    if value then
        MonsterPredict = true
        lastMonsterCount = 0
        monsterPredictThread = task.spawn(function()
            while MonsterPredict do
                local nightEnemies = Workspace:FindFirstChild("NightEnemies")
                local currentCount = 0
                local monsterName = "未知"
                if nightEnemies then
                    currentCount = #nightEnemies:GetChildren()
                    for _, v in ipairs(nightEnemies:GetChildren()) do
                        if v:IsA("Model") then
                            monsterName = v.Name
                            break
                        end
                    end
                end
                if currentCount > 0 and lastMonsterCount == 0 then
                    local displayName = monsterName
                    if monsterName == "Wolf" then
                        displayName = "狼"
                    elseif monsterName == "Werewolf" then
                        displayName = "狼人"
                    elseif monsterName == "Vampire" then
                        displayName = "吸血鬼"
                    elseif monsterName == "Walker" then
                        displayName = "正常僵尸"
                    elseif monsterName == "Runner" then
                        displayName = "奔跑僵尸"
                    end
                    StarterGui:SetCore("SendNotification", {
                        Title = "怪物预知",
                        Text = "今晚的怪物是：" .. displayName,
                        Icon = "rbxthumb://type=Asset&id=17366451283&w=150&h=150",
                        Duration = 15,
                    })
                end
                lastMonsterCount = currentCount
                task.wait(2)
            end
        end)
        Library:Notify("怪物预知已启用", 2)
    else
        MonsterPredict = false
        if monsterPredictThread then
            task.cancel(monsterPredictThread)
            monsterPredictThread = nil
        end
        Library:Notify("怪物预知已关闭", 2)
    end
end)

local AutoLeft = Tabs.Auto:AddLeftGroupbox("自动收集")
local AutoRight = Tabs.Auto:AddRightGroupbox("自动操作")

AutoLeft:AddToggle('AutoStore', {
    Text = '自动收物品',
    Default = false,
}):OnChanged(function(value)
    if value then
        AutoStore = true
        autoStoreThread = task.spawn(function()
            while AutoStore do
                local runtimeItems = Workspace:FindFirstChild("RuntimeItems")
                if runtimeItems then
                    for _, item in ipairs(runtimeItems:GetChildren()) do
                        if item:IsA("Model") then
                            pcall(function()
                                ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StoreItem"):FireServer(item)
                            end)
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
        Library:Notify("自动收物品已启用", 2)
    else
        AutoStore = false
        if autoStoreThread then
            task.cancel(autoStoreThread)
            autoStoreThread = nil
        end
        Library:Notify("自动收物品已关闭", 2)
    end
end)

AutoLeft:AddToggle('AutoCollectBond', {
    Text = '自动收集债券',
    Default = false,
}):OnChanged(function(value)
    if value then
        AutoCollectBond = true
        autoCollectBondThread = task.spawn(function()
            while AutoCollectBond do
                local runtimeItems = Workspace:FindFirstChild("RuntimeItems")
                if runtimeItems then
                    for _, v in ipairs(runtimeItems:GetChildren()) do
                        if v.Name == "Bond" then
                            local char = LocalPlayer.Character
                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local dist = (hrp.Position - v.Position).Magnitude
                                if dist < 10 then
                                    pcall(function()
                                        ReplicatedStorage.Packages.ActivateObjectClient:FireServer(v)
                                    end)
                                end
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
        Library:Notify("自动收集债券已启用", 2)
    else
        AutoCollectBond = false
        if autoCollectBondThread then
            task.cancel(autoCollectBondThread)
            autoCollectBondThread = nil
        end
        Library:Notify("自动收集债券已关闭", 2)
    end
end)

AutoLeft:AddToggle('AutoCollectItem', {
    Text = '自动收集物品',
    Default = false,
}):OnChanged(function(value)
    if value then
        AutoCollectItem = true
        autoCollectItemThread = task.spawn(function()
            while AutoCollectItem do
                local runtimeItems = Workspace:FindFirstChild("RuntimeItems")
                if runtimeItems then
                    for _, v in ipairs(runtimeItems:GetChildren()) do
                        local char = LocalPlayer.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local dist = (hrp.Position - v.Position).Magnitude
                            if dist < 10 then
                                pcall(function()
                                    ReplicatedStorage.Remotes.Tool.PickUpTool:FireServer(v)
                                end)
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
        Library:Notify("自动收集物品已启用", 2)
    else
        AutoCollectItem = false
        if autoCollectItemThread then
            task.cancel(autoCollectItemThread)
            autoCollectItemThread = nil
        end
        Library:Notify("自动收集物品已关闭", 2)
    end
end)

AutoLeft:AddToggle('AutoCollectMoneybag', {
    Text = '自动收集钱袋',
    Default = false,
}):OnChanged(function(value)
    if value then
        AutoCollectMoneybag = true
        autoCollectMoneybagThread = task.spawn(function()
            while AutoCollectMoneybag do
                local runtimeItems = Workspace:FindFirstChild("RuntimeItems")
                if runtimeItems and runtimeItems:FindFirstChild("Moneybag") then
                    local moneybag = runtimeItems.Moneybag
                    local collectPrompt = moneybag:FindFirstChild("MoneyBag") and moneybag.MoneyBag:FindFirstChild("CollectPrompt")
                    if collectPrompt then
                        pcall(function()
                            fireproximityprompt(collectPrompt)
                        end)
                    end
                end
                task.wait(0.1)
            end
        end)
        Library:Notify("自动收集钱袋已启用", 2)
    else
        AutoCollectMoneybag = false
        if autoCollectMoneybagThread then
            task.cancel(autoCollectMoneybagThread)
            autoCollectMoneybagThread = nil
        end
        Library:Notify("自动收集钱袋已关闭", 2)
    end
end)

AutoLeft:AddToggle('AutoWalkBond', {
    Text = '自动走向债券',
    Default = false,
}):OnChanged(function(value)
    if value then
        AutoWalkBond = true
        autoWalkBondThread = task.spawn(function()
            while AutoWalkBond do
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    local runtimeItems = Workspace:FindFirstChild("RuntimeItems")
                    if runtimeItems then
                        for _, item in ipairs(runtimeItems:GetChildren()) do
                            if item.Name == "Bond" and item:IsA("Model") then
                                hum.WalkToPoint = Vector3.new(item.Position.X, item.Position.Y, item.Position.Z)
                                break
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
        Library:Notify("自动走向债券已启用", 2)
    else
        AutoWalkBond = false
        if autoWalkBondThread then
            task.cancel(autoWalkBondThread)
            autoWalkBondThread = nil
        end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hum.WalkToPoint = hrp.Position
            end
        end
        Library:Notify("自动走向债券已关闭", 2)
    end
end)

AutoRight:AddToggle('AutoDrop', {
    Text = '自动丢物品',
    Default = false,
}):OnChanged(function(value)
    if value then
        AutoDrop = true
        autoDropThread = task.spawn(function()
            while AutoDrop do
                pcall(function()
                    ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DropItem"):FireServer()
                end)
                task.wait(0.01)
            end
        end)
        Library:Notify("自动丢物品已启用", 2)
    else
        AutoDrop = false
        if autoDropThread then
            task.cancel(autoDropThread)
            autoDropThread = nil
        end
        Library:Notify("自动丢物品已关闭", 2)
    end
end)

AutoRight:AddToggle('AutoEndGame', {
    Text = '自动拉终点开关',
    Default = false,
}):OnChanged(function(value)
    if value then
        AutoEndGame = true
        autoEndGameThread = task.spawn(function()
            while AutoEndGame do
                pcall(function()
                    local baseplates = Workspace:FindFirstChild("Baseplates")
                    if not baseplates then return end
                    local final = baseplates:FindFirstChild("FinalBasePlate")
                    if not final then return end
                    local outlaw = final:FindFirstChild("OutlawBase")
                    if not outlaw then return end
                    local bridge = outlaw:FindFirstChild("Bridge")
                    if not bridge then return end
                    local control = bridge:FindFirstChild("BridgeControl")
                    if not control then return end
                    local crank = control:FindFirstChild("Crank")
                    if not crank then return end
                    local model = crank:FindFirstChild("Model")
                    if not model then return end
                    local mid = model:FindFirstChild("Mid")
                    if not mid then return end
                    local endGame = mid:FindFirstChild("EndGame")
                    if endGame and endGame:IsA("ProximityPrompt") then
                        endGame.MaxActivationDistance = math.huge
                        fireproximityprompt(endGame)
                    end
                end)
                task.wait(0.1)
            end
        end)
        Library:Notify("自动拉终点开关已启用", 2)
    else
        AutoEndGame = false
        if autoEndGameThread then
            task.cancel(autoEndGameThread)
            autoEndGameThread = nil
        end
        Library:Notify("自动拉终点开关已关闭", 2)
    end
end)

AutoRight:AddToggle('AutoTrainHorn', {
    Text = '自动火车鸣声',
    Default = false,
}):OnChanged(function(value)
    if value then
        AutoTrainHorn = true
        autoTrainHornThread = task.spawn(function()
            while AutoTrainHorn do
                pcall(function()
                    local train = Workspace:FindFirstChild("Train")
                    if not train then return end
                    local controls = train:FindFirstChild("TrainControls")
                    if not controls then return end
                    local lever = controls:FindFirstChild("Lever")
                    if not lever then return end
                    local hitbox = lever:FindFirstChild("HitBox")
                    if not hitbox then return end
                    local clickDetector = hitbox:FindFirstChild("ClickDetector")
                    if clickDetector then
                        clickDetector.MaxActivationDistance = math.huge
                        fireclickdetector(clickDetector)
                    end
                end)
                task.wait(0.1)
            end
        end)
        Library:Notify("自动火车鸣声已启用", 2)
    else
        AutoTrainHorn = false
        if autoTrainHornThread then
            task.cancel(autoTrainHornThread)
            autoTrainHornThread = nil
        end
        Library:Notify("自动火车鸣声已关闭", 2)
    end
end)

AutoRight:AddToggle('AutoBandage', {
    Text = '自动使用绷带',
    Default = false,
}):OnChanged(function(value)
    if value then
        AutoBandage = true
        autoBandageThread = task.spawn(function()
            while AutoBandage do
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health <= BandageHealth then
                    local backpack = LocalPlayer.Backpack
                    for _, v in ipairs(backpack:GetChildren()) do
                        if v.Name == "Bandage" then
                            pcall(function()
                                v.Parent = char
                                local bandage = char:FindFirstChild("Bandage")
                                if bandage and bandage:FindFirstChild("Use") then
                                    bandage.Use:FireServer()
                                end
                            end)
                            break
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
        Library:Notify("自动使用绷带已启用", 2)
    else
        AutoBandage = false
        if autoBandageThread then
            task.cancel(autoBandageThread)
            autoBandageThread = nil
        end
        Library:Notify("自动使用绷带已关闭", 2)
    end
end)

AutoRight:AddSlider('BandageHealth', {
    Text = '使用绷带血量',
    Default = 30,
    Min = 1,
    Max = 100,
    Rounding = 0,
}):OnChanged(function(value)
    BandageHealth = value
end)

local ESPLeft = Tabs.ESP:AddLeftGroupbox("环境透视")
local ESPRight = Tabs.ESP:AddRightGroupbox("敌人透视")

local function createBillboard(parent, text, color)
    if parent:FindFirstChild("BillboardGui") then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BillboardGui"
    billboard.Parent = parent
    billboard.Adornee = parent
    billboard.Size = UDim2.new(0, 20, 0, 20)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = billboard
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = text
    nameLabel.TextColor3 = color
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.TextScaled = true
end

ESPLeft:AddToggle('ESPItems', {
    Text = '透视物品',
    Default = false,
}):OnChanged(function(value)
    if value then
        ESPItems = true
        local runtimeItems = Workspace:FindFirstChild("RuntimeItems")
        if runtimeItems then
            for _, v in ipairs(runtimeItems:GetChildren()) do
                if v:IsA("Model") then
                    createBillboard(v, v.Name, Color3.new(255, 215, 0))
                end
            end
        end
        espItemsConn = Workspace.RuntimeItems.ChildAdded:Connect(function(v)
            if ESPItems and v:IsA("Model") then
                createBillboard(v, v.Name, Color3.new(255, 215, 0))
            end
        end)
        Library:Notify("透视物品已启用", 2)
    else
        ESPItems = false
        if espItemsConn then
            espItemsConn:Disconnect()
            espItemsConn = nil
        end
        local runtimeItems = Workspace:FindFirstChild("RuntimeItems")
        if runtimeItems then
            for _, v in ipairs(runtimeItems:GetChildren()) do
                local bill = v:FindFirstChild("BillboardGui")
                if bill then bill:Destroy() end
            end
        end
        Library:Notify("透视物品已关闭", 2)
    end
end)

ESPLeft:AddToggle('ESPOre', {
    Text = '透视矿石',
    Default = false,
}):OnChanged(function(value)
    if value then
        ESPOre = true
        local oreFolder = Workspace:FindFirstChild("Ore")
        if oreFolder then
            for _, v in ipairs(oreFolder:GetChildren()) do
                if v:IsA("Model") then
                    createBillboard(v, v.Name, Color3.new(0, 0, 255))
                end
            end
        end
        espOreConn = Workspace.Ore.ChildAdded:Connect(function(v)
            if ESPOre and v:IsA("Model") then
                createBillboard(v, v.Name, Color3.new(0, 0, 255))
            end
        end)
        Library:Notify("透视矿石已启用", 2)
    else
        ESPOre = false
        if espOreConn then
            espOreConn:Disconnect()
            espOreConn = nil
        end
        local oreFolder = Workspace:FindFirstChild("Ore")
        if oreFolder then
            for _, v in ipairs(oreFolder:GetChildren()) do
                local bill = v:FindFirstChild("BillboardGui")
                if bill then bill:Destroy() end
            end
        end
        Library:Notify("透视矿石已关闭", 2)
    end
end)

ESPLeft:AddToggle('ESPBuilding', {
    Text = '房子透视',
    Default = false,
}):OnChanged(function(value)
    if value then
        ESPBuilding = true
        local buildings = Workspace:FindFirstChild("RandomBuildings")
        if buildings then
            for _, v in ipairs(buildings:GetChildren()) do
                if v:IsA("Model") then
                    createBillboard(v, v.Name, Color3.new(0, 255, 0))
                end
            end
        end
        espBuildingConn = Workspace.RandomBuildings.ChildAdded:Connect(function(v)
            if ESPBuilding and v:IsA("Model") then
                createBillboard(v, v.Name, Color3.new(0, 255, 0))
            end
        end)
        Library:Notify("房子透视已启用", 2)
    else
        ESPBuilding = false
        if espBuildingConn then
            espBuildingConn:Disconnect()
            espBuildingConn = nil
        end
        local buildings = Workspace:FindFirstChild("RandomBuildings")
        if buildings then
            for _, v in ipairs(buildings:GetChildren()) do
                local bill = v:FindFirstChild("BillboardGui")
                if bill then bill:Destroy() end
            end
        end
        Library:Notify("房子透视已关闭", 2)
    end
end)

ESPLeft:AddToggle('ESPBank', {
    Text = '银行透视',
    Default = false,
}):OnChanged(function(value)
    if value then
        ESPBank = true
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name == "Bank" then
                createBillboard(v, v.Name, Color3.new(1, 0, 1))
            end
        end
        espBankConn = Workspace.DescendantAdded:Connect(function(v)
            if ESPBank and v:IsA("Model") and v.Name == "Bank" then
                task.wait()
                createBillboard(v, v.Name, Color3.new(1, 0, 1))
            end
        end)
        Library:Notify("银行透视已启用", 2)
    else
        ESPBank = false
        if espBankConn then
            espBankConn:Disconnect()
            espBankConn = nil
        end
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v.Name == "Bank" then
                local bill = v:FindFirstChild("BillboardGui")
                if bill then bill:Destroy() end
            end
        end
        Library:Notify("银行透视已关闭", 2)
    end
end)

ESPLeft:AddToggle('ESPBond', {
    Text = '透视债券',
    Default = false,
}):OnChanged(function(value)
    if value then
        ESPBond = true
        local runtimeItems = Workspace:FindFirstChild("RuntimeItems")
        if runtimeItems then
            for _, v in ipairs(runtimeItems:GetChildren()) do
                if v:IsA("Model") and v.Name == "Bond" then
                    createBillboard(v, v.Name, Color3.new(255, 215, 0))
                end
            end
        end
        espBondConn = Workspace.RuntimeItems.ChildAdded:Connect(function(v)
            if ESPBond and v:IsA("Model") and v.Name == "Bond" then
                createBillboard(v, v.Name, Color3.new(255, 215, 0))
            end
        end)
        Library:Notify("透视债券已启用", 2)
    else
        ESPBond = false
        if espBondConn then
            espBondConn:Disconnect()
            espBondConn = nil
        end
        local runtimeItems = Workspace:FindFirstChild("RuntimeItems")
        if runtimeItems then
            for _, v in ipairs(runtimeItems:GetChildren()) do
                if v.Name == "Bond" then
                    local bill = v:FindFirstChild("BillboardGui")
                    if bill then bill:Destroy() end
                end
            end
        end
        Library:Notify("透视债券已关闭", 2)
    end
end)

ESPLeft:AddToggle('ESPUnicorn', {
    Text = '独角兽透视',
    Default = false,
}):OnChanged(function(value)
    if value then
        ESPUnicorn = true
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v.Name == "Unicorn" then
                createBillboard(v, "独角兽", Color3.new(1, 1, 1))
            end
        end
        espUnicornConn = Workspace.DescendantAdded:Connect(function(v)
            if ESPUnicorn and v.Name == "Unicorn" then
                createBillboard(v, "独角兽", Color3.new(1, 1, 1))
            end
        end)
        Library:Notify("独角兽透视已启用", 2)
    else
        ESPUnicorn = false
        if espUnicornConn then
            espUnicornConn:Disconnect()
            espUnicornConn = nil
        end
        for _, v in ipairs(Workspace:GetChildren()) do
            local bill = v:FindFirstChild("BillboardGui")
            if bill and bill:FindFirstChild("TextLabel") and bill.TextLabel.Text == "独角兽" then
                bill:Destroy()
            end
        end
        Library:Notify("独角兽透视已关闭", 2)
    end
end)

ESPRight:AddToggle('ESPNightEnemy', {
    Text = '夜晚怪物透视',
    Default = false,
}):OnChanged(function(value)
    if value then
        ESPNightEnemy = true
        local nightEnemies = Workspace:FindFirstChild("NightEnemies")
        if nightEnemies then
            for _, v in ipairs(nightEnemies:GetChildren()) do
                if v:IsA("Model") then
                    createBillboard(v, v.Name, Color3.new(1, 0, 0))
                end
            end
        end
        espNightEnemyConn = Workspace.NightEnemies.ChildAdded:Connect(function(v)
            if ESPNightEnemy and v:IsA("Model") then
                createBillboard(v, v.Name, Color3.new(1, 0, 0))
            end
        end)
        Library:Notify("夜晚怪物透视已启用", 2)
    else
        ESPNightEnemy = false
        if espNightEnemyConn then
            espNightEnemyConn:Disconnect()
            espNightEnemyConn = nil
        end
        local nightEnemies = Workspace:FindFirstChild("NightEnemies")
        if nightEnemies then
            for _, v in ipairs(nightEnemies:GetChildren()) do
                local bill = v:FindFirstChild("BillboardGui")
                if bill then bill:Destroy() end
            end
        end
        Library:Notify("夜晚怪物透视已关闭", 2)
    end
end)

ESPRight:AddToggle('ESPZombie', {
    Text = '房子中的怪物透视',
    Default = false,
}):OnChanged(function(value)
    if value then
        ESPZombie = true
        local buildings = Workspace:FindFirstChild("RandomBuildings")
        if buildings then
            for _, building in ipairs(buildings:GetChildren()) do
                local standalone = building:FindFirstChild("StandaloneZombiePart")
                if standalone then
                    local zombies = standalone:FindFirstChild("Zombies")
                    if zombies then
                        for _, zombie in ipairs(zombies:GetChildren()) do
                            if zombie:IsA("Model") then
                                createBillboard(zombie, zombie.Name, Color3.new(0, 255, 0))
                            end
                        end
                    end
                end
            end
        end
        espZombieConn = Workspace.RandomBuildings.ChildAdded:Connect(function(building)
            if not ESPZombie then return end
            task.wait(0.5)
            local standalone = building:FindFirstChild("StandaloneZombiePart")
            if standalone then
                local zombies = standalone:FindFirstChild("Zombies")
                if zombies then
                    for _, zombie in ipairs(zombies:GetChildren()) do
                        if zombie:IsA("Model") then
                            createBillboard(zombie, zombie.Name, Color3.new(0, 255, 0))
                        end
                    end
                end
            end
        end)
        Library:Notify("房子中的怪物透视已启用", 2)
    else
        ESPZombie = false
        if espZombieConn then
            espZombieConn:Disconnect()
            espZombieConn = nil
        end
        local buildings = Workspace:FindFirstChild("RandomBuildings")
        if buildings then
            for _, building in ipairs(buildings:GetChildren()) do
                local standalone = building:FindFirstChild("StandaloneZombiePart")
                if standalone then
                    local zombies = standalone:FindFirstChild("Zombies")
                    if zombies then
                        for _, zombie in ipairs(zombies:GetChildren()) do
                            local bill = zombie:FindFirstChild("BillboardGui")
                            if bill then bill:Destroy() end
                        end
                    end
                end
            end
        end
        Library:Notify("房子中的怪物透视已关闭", 2)
    end
end)

ESPRight:AddToggle('ESPOutlaw', {
    Text = '猎人透视',
    Default = false,
}):OnChanged(function(value)
    if value then
        ESPOutlaw = true
        local outlawNames = { "TurretOutlaw", "RifleOutlaw", "ShotgunOutlaw", "RevolverOutlaw" }
        for _, v in ipairs(Workspace:GetDescendants()) do
            if table.find(outlawNames, v.Name) then
                createBillboard(v, v.Name, Color3.new(1, 1, 1))
            end
        end
        espOutlawConn = Workspace.DescendantAdded:Connect(function(v)
            if ESPOutlaw and table.find(outlawNames, v.Name) then
                createBillboard(v, v.Name, Color3.new(1, 1, 1))
            end
        end)
        Library:Notify("猎人透视已启用", 2)
    else
        ESPOutlaw = false
        if espOutlawConn then
            espOutlawConn:Disconnect()
            espOutlawConn = nil
        end
        local outlawNames = { "TurretOutlaw", "RifleOutlaw", "ShotgunOutlaw", "RevolverOutlaw" }
        for _, v in ipairs(Workspace:GetChildren()) do
            if table.find(outlawNames, v.Name) then
                local bill = v:FindFirstChild("BillboardGui")
                if bill then bill:Destroy() end
            end
        end
        Library:Notify("猎人透视已关闭", 2)
    end
end)

local InteractLeft = Tabs.Interact:AddLeftGroupbox("交互修改")
local InteractRight = Tabs.Interact:AddRightGroupbox("环境清理")

InteractLeft:AddToggle('InstantInteract', {
    Text = '秒交互',
    Default = false,
}):OnChanged(function(value)
    InstantInteract = value
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            if value then
                oldPromptDurations[v] = v.HoldDuration
                v.HoldDuration = 0
            else
                if oldPromptDurations[v] ~= nil then
                    v.HoldDuration = oldPromptDurations[v]
                end
            end
        end
    end
    if value then
        Library:Notify("秒交互已启用", 2)
    else
        Library:Notify("秒交互已关闭", 2)
    end
end)

InteractLeft:AddToggle('RemoteInteract', {
    Text = '远程交互',
    Default = false,
}):OnChanged(function(value)
    RemoteInteract = value
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            if value then
                oldPromptDistances[v] = v.MaxActivationDistance
                v.MaxActivationDistance = math.huge
            else
                if oldPromptDistances[v] ~= nil then
                    v.MaxActivationDistance = oldPromptDistances[v]
                end
            end
        end
    end
    if value then
        Library:Notify("远程交互已启用", 2)
    else
        Library:Notify("远程交互已关闭", 2)
    end
end)

InteractLeft:AddToggle('NoLOSInteract', {
    Text = '无视野互动',
    Default = false,
}):OnChanged(function(value)
    NoLOSInteract = value
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            if value then
                oldPromptLOS[v] = v.RequiresLineOfSight
                v.RequiresLineOfSight = false
            else
                if oldPromptLOS[v] ~= nil then
                    v.RequiresLineOfSight = oldPromptLOS[v]
                end
            end
        end
    end
    if value then
        Library:Notify("无视野互动已启用", 2)
    else
        Library:Notify("无视野互动已关闭", 2)
    end
end)

InteractRight:AddButton("删除杂物", function()
    local decor = Workspace:FindFirstChild("Decor")
    if decor then
        for _, v in ipairs(decor:GetChildren()) do
            v:Destroy()
        end
    end
    Library:Notify("杂物已删除", 2)
end)

InteractRight:AddToggle('DeleteDecor', {
    Text = '持续删除杂物',
    Default = false,
}):OnChanged(function(value)
    if value then
        DeleteDecor = true
        deleteDecorThread = task.spawn(function()
            while DeleteDecor do
                local decor = Workspace:FindFirstChild("Decor")
                if decor then
                    for _, v in ipairs(decor:GetChildren()) do
                        v:Destroy()
                    end
                end
                task.wait(1)
            end
        end)
        Library:Notify("持续删除杂物已启用", 2)
    else
        DeleteDecor = false
        if deleteDecorThread then
            task.cancel(deleteDecorThread)
            deleteDecorThread = nil
        end
        Library:Notify("持续删除杂物已关闭", 2)
    end
end)

InteractRight:AddButton("删除闪电", function()
    for _, v in ipairs(Workspace:GetChildren()) do
        if v.Name == "LightningModel" then
            v:Destroy()
        end
    end
    Library:Notify("闪电已删除", 2)
end)

InteractRight:AddToggle('DeleteLightning', {
    Text = '持续删除闪电',
    Default = false,
}):OnChanged(function(value)
    if value then
        DeleteLightning = true
        deleteLightningThread = task.spawn(function()
            while DeleteLightning do
                for _, v in ipairs(Workspace:GetChildren()) do
                    if v.Name == "LightningModel" then
                        v:Destroy()
                    end
                end
                task.wait(1)
            end
        end)
        Library:Notify("持续删除闪电已启用", 2)
    else
        DeleteLightning = false
        if deleteLightningThread then
            task.cancel(deleteLightningThread)
            deleteLightningThread = nil
        end
        Library:Notify("持续删除闪电已关闭", 2)
    end
end)

local BondGroup = Tabs.Bond:AddLeftGroupbox("刷债券")
BondGroup:AddButton("启动刷债券脚本", function()
    TranslationEnabled = true
    TranslationSpeed = 5
    scanInterval = 0.3
    startTranslation()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/afkar-gg/sc/refs/heads/main/auto-bond"))()
    end)
    Library:Notify("刷债券脚本已启动，自动翻译已开启（速度5）", 3)
end)

local AutoBondV2 = false
local autoBondV2Thread = nil

BondGroup:AddToggle('AutoBondV2', {
    Text = '刷债券脚本v2（不会死）',
    Default = false,
}):OnChanged(function(value)
    if value then
        AutoBondV2 = true
        autoBondV2Thread = task.spawn(function()
            local RS = game:GetService("ReplicatedStorage")
            local world = require(RS.Shared.Universe.ECS.world)
            local comps = require(RS.Shared.Universe.ECS.components)
            local replicator = require(RS.Client.Universe.Replication.clientReplicator)
            local Remotes = require(RS.Shared.Universe.Remotes)
            local PlayerData = require(RS.Client.Universe.PlayerDataController)
            local Event = game:GetService("ReplicatedStorage").Shared.Universe.Network.RemoteEvent.Actionable
            while AutoBondV2 do
                local char = world:get_resource(comps.ClientStateResource).localCharacter
                if char then
                    if not world:has(char, comps.Sack) then
                        world:add(char, comps.Sack)
                        world:set(char, comps.Sack, { contents = {}, maxContents = 10 })
                    end
                    for id = 1, 100000 do
                        if world:has(id, comps.Storable) and world:get(id, comps.ObjectId) == "bond" then
                            local sr = replicator:get_server_entity(id)
                            if sr and sr ~= id then
                                Remotes.Store:FireServer(sr)
                                Remotes.Store:FireServer()
                                Event:FireServer(sr)
                            end
                        end
                    end
                end
                task.wait(1)
            end
        end)
        Library:Notify("刷债券脚本v2已启动（不会死）", 3)
    else
        AutoBondV2 = false
        if autoBondV2Thread then
            task.cancel(autoBondV2Thread)
            autoBondV2Thread = nil
        end
        Library:Notify("刷债券脚本v2已关闭", 2)
    end
end)

local UnloadGroup = Tabs.Settings:AddLeftGroupbox("脚本管理")
UnloadGroup:AddButton("卸载脚本", function()
    Library:Unload()
end)

if ThemeManager then
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("DeadRailTheme")
    ThemeManager:ApplyToTab(Tabs.Settings)
end

if SaveManager then
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetFolder("DeadRailConfig")
    SaveManager:BuildConfigSection(Tabs.Settings)
end
