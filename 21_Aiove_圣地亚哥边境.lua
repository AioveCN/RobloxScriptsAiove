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
local player = Players.LocalPlayer

local isMoneyRunning = false
local isPunchRunning = false
local punchSpeed = 0.5
local noClipEnabled = false
local noclipConnection = nil

local espEnabled = false
local espBillboards = {}
local espConnections = {}

local flySpeed = 50
local flyActive = false
local flyConn = nil
local bodyVelocity = nil
local Camera = workspace.CurrentCamera

local BUY_COORDS = Vector3.new(6819.8, 17.5, 28.9)
local SELL_COORDS = Vector3.new(211.2, 17.4, -43.3)
local LAUNDER_COORDS = Vector3.new(6808.8, 17.6, -34.9)

local function getHRP()
    local char = player.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function teleportTo(position)
    local hrp = getHRP()
    if hrp then
        hrp.CFrame = CFrame.new(position)
    end
end

local function buyAvacados()
    local item = workspace.WorldBuyableItems:FindFirstChild("Crate Of Avacados")
    if item then
        local args = {[1] = item}
        ReplicatedStorage.__remotes.WorldBuyableItemService.PurchaseWorldBuyableItem:FireServer(unpack(args))
    end
end

local function sellAvacados()
    local sellArgs = {[1] = workspace.NPC.Seller4}
    ReplicatedStorage.__remotes.SmuggleService.SellSmuggledGoods:FireServer(unpack(sellArgs))
end

local function setBackpackOrder()
    local orderArgs = {
        [1] = {
            [1] = "name:Fists",
            [2] = "name:Passport",
            [3] = "name:Briefcase"
        }
    }
    ReplicatedStorage.__remotes.BackpackService.SetBackpackToolOrder:FireServer(unpack(orderArgs))
end

local function launderMoney()
    local trigger = workspace.LaunderPrompts:FindFirstChild("LaunderTrigger")
    if trigger then
        local part = trigger:FindFirstChild("PromptPart")
        if part then
            local args = {[1] = part}
            ReplicatedStorage.__remotes.SmuggleService.LaunderBriefcase:FireServer(unpack(args))
        end
    end
end

local function punch()
    ReplicatedStorage.__remotes.Fists.Punch:InvokeServer()
end

local function setNoclip(state)
    noClipEnabled = state
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    if state then
        noclipConnection = RunService.Stepped:Connect(function()
            local char = player.Character
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.CanCollide = false
                    end
                end
            end
        end)
    else
        local char = player.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = true
                end
            end
        end
    end
end

local function flyTo(targetPos)
    local hrp = getHRP()
    if not hrp then return false end

    local startPos = hrp.Position
    local distance = (targetPos - startPos).Magnitude
    local duration = distance / 150
    local startTime = tick()

    while true do
        if not isMoneyRunning then return false end

        local currentHRP = getHRP()
        if not currentHRP then return false end

        local elapsed = tick() - startTime
        if elapsed >= duration then
            currentHRP.CFrame = CFrame.new(targetPos)
            return true
        end

        local alpha = elapsed / duration
        local newPos = startPos:Lerp(targetPos, alpha)
        currentHRP.CFrame = CFrame.new(newPos)

        task.wait(0.03)
    end
end

local function wiggleInPlace(duration)
    local hrp = getHRP()
    if not hrp then return false end
    local basePos = hrp.Position
    local start = tick()
    while tick() - start < duration do
        if not isMoneyRunning then return false end
        local currentHRP = getHRP()
        if not currentHRP then return false end
        -- 改为极小幅随机偏移，避免反作弊检测
        local offsetX = math.sin(tick() * 2) * 0.1
        local offsetZ = math.cos(tick() * 2) * 0.1
        currentHRP.CFrame = CFrame.new(basePos.X + offsetX, basePos.Y, basePos.Z + offsetZ)
        task.wait(0.1)
    end
    return true
end

local function waitSeconds(seconds)
    local start = tick()
    while tick() - start < seconds do
        task.wait(0.1)
        if not isMoneyRunning then return false end
    end
    return true
end

local function doOneCycle()
    setNoclip(true)

    -- 购买阶段
    if not flyTo(BUY_COORDS) then return false end
    wiggleInPlace(3)
    buyAvacados()
    buyAvacados()
    buyAvacados()
    if not waitSeconds(5) then return false end

    -- 设置背包顺序（只执行一次，把Briefcase放第3位）
    setBackpackOrder()
    task.wait(1)

    -- 售卖阶段
    if not flyTo(SELL_COORDS) then return false end
    wiggleInPlace(3)
    sellAvacados()
    task.wait(1)
    sellAvacados()
    task.wait(1)
    sellAvacados()
    if not waitSeconds(5) then return false end

    -- 洗钱阶段
    if not flyTo(LAUNDER_COORDS) then return false end
    wiggleInPlace(3)
    launderMoney()
    task.wait(1)
    launderMoney()
    task.wait(1)
    launderMoney()
    if not waitSeconds(5) then return false end

    setNoclip(false)
    return true
end

local function moneyLoop()
    while isMoneyRunning do
        local success = doOneCycle()
        if not success then break end
        if not waitSeconds(3) then break end
    end
    setNoclip(false)
end

local function punchLoop()
    while isPunchRunning do
        punch()
        task.wait(punchSpeed)
    end
end

-- 飞车
local function startFly()
    local hrp = getHRP()
    if not hrp then return end
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bodyVelocity.P = 1250
    bodyVelocity.Parent = hrp
    flyConn = RunService.RenderStepped:Connect(function()
        local camLook = Camera.CFrame.LookVector
        bodyVelocity.Velocity = camLook * flySpeed
    end)
end

local function stopFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
end

-- ESP
local function cleanupESP(targetPlayer)
    if espConnections[targetPlayer] then
        for _, conn in ipairs(espConnections[targetPlayer]) do
            pcall(function() conn:Disconnect() end)
        end
        espConnections[targetPlayer] = nil
    end
    local char = targetPlayer.Character
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
    espBillboards[targetPlayer] = nil
end

local function createESP(targetPlayer)
    if targetPlayer == player then return end
    local char = targetPlayer.Character
    if not char then return end
    cleanupESP(targetPlayer)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        task.spawn(function()
            local success = pcall(function() char:WaitForChild("HumanoidRootPart", 5) end)
            if success and espEnabled and targetPlayer.Parent then
                createESP(targetPlayer)
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

local function setupPlayerESP(targetPlayer)
    if targetPlayer == player then return end
    if espConnections[targetPlayer] then
        for _, conn in ipairs(espConnections[targetPlayer]) do
            pcall(function() conn:Disconnect() end)
        end
    end
    espConnections[targetPlayer] = {}
    table.insert(espConnections[targetPlayer], targetPlayer.CharacterAdded:Connect(function(char)
        task.spawn(function()
            pcall(function() char:WaitForChild("HumanoidRootPart", 5) end)
            if espEnabled then
                task.wait(0.1)
                createESP(targetPlayer)
            end
        end)
    end))
    table.insert(espConnections[targetPlayer], targetPlayer.CharacterRemoving:Connect(function()
        cleanupESP(targetPlayer)
    end))
    if targetPlayer.Character and espEnabled then
        createESP(targetPlayer)
    end
end

RunService.RenderStepped:Connect(function()
    if not espEnabled then return end
    local myChar = player.Character
    local myPos = myChar and myChar:FindFirstChild("HumanoidRootPart") and myChar.HumanoidRootPart.Position
    for targetPlayer, billboard in pairs(espBillboards) do
        if targetPlayer.Parent and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and billboard and billboard.Parent then
            local distLabel = billboard:FindFirstChild("DistLabel")
            if distLabel and myPos then
                local dist = (targetPlayer.Character.HumanoidRootPart.Position - myPos).Magnitude
                distLabel.Text = string.format("%.0fm", dist)
            end
        else
            espBillboards[targetPlayer] = nil
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if not espEnabled then continue end
        for _, targetPlayer in ipairs(Players:GetPlayers()) do
            if targetPlayer ~= player and targetPlayer.Character then
                local char = targetPlayer.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hasHighlight = char:FindFirstChild("EspHighlight")
                local hasBillboard = hrp and hrp:FindFirstChild("EspBillboard")
                if not hasHighlight or not hasBillboard then
                    pcall(function() createESP(targetPlayer) end)
                end
            end
        end
    end
end)

for _, targetPlayer in ipairs(Players:GetPlayers()) do
    setupPlayerESP(targetPlayer)
end

Players.PlayerAdded:Connect(function(targetPlayer)
    setupPlayerESP(targetPlayer)
end)

Players.PlayerRemoving:Connect(function(targetPlayer)
    cleanupESP(targetPlayer)
end)

player.CharacterAdded:Connect(function(newChar)
    newChar:WaitForChild("Humanoid")
    newChar:WaitForChild("HumanoidRootPart")
end)

-- 无敌逻辑：伤害调为负数 + 强锁定回拉
local godModeEnabled = false
local godModeConnection = nil
local function setGodMode(state)
    godModeEnabled = state
    if godModeConnection then
        godModeConnection:Disconnect()
        godModeConnection = nil
    end
    if state then
        godModeConnection = RunService.Heartbeat:Connect(function()
            local char = player.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            -- 强锁定：血量一旦低于最大值就回拉
            if hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
            -- 拦截 TakeDamage
            pcall(function()
                hum:SetAttribute("GodMode", true)
            end)
        end)
        -- 监听 HealthChanged，掉血立即回满
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.HealthChanged:Connect(function(newHealth)
                    if godModeEnabled and newHealth < hum.MaxHealth then
                        hum.Health = hum.MaxHealth
                    end
                end)
            end
        end
    end
end

-- 无敌VR：血量设为极大负数
local vrGodModeEnabled = false
local vrGodConnection = nil
local function setVRGodMode(state)
    vrGodModeEnabled = state
    if vrGodConnection then
        vrGodConnection:Disconnect()
        vrGodConnection = nil
    end
    if state then
        vrGodConnection = RunService.Heartbeat:Connect(function()
            local char = player.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            -- 血量设为极大负数
            hum.MaxHealth = -999999999999
            hum.Health = -999999999999
        end)
    else
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.MaxHealth = 100
                hum.Health = 100
            end
        end
    end
end

-- 监听角色变化，自动应用无敌
player.CharacterAdded:Connect(function(newChar)
    local hum = newChar:WaitForChild("Humanoid")
    newChar:WaitForChild("HumanoidRootPart")
    if godModeEnabled then
        hum.HealthChanged:Connect(function(newHealth)
            if godModeEnabled and newHealth < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end)
    end
    if vrGodModeEnabled then
        task.wait(0.5)
        hum.MaxHealth = -999999999999
        hum.Health = -999999999999
    end
end)

local Window = Library:CreateWindow({
    Title = "圣地亚哥边境",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify("圣地亚哥边境 - 创作者：Aiove", 5)

local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Main = Window:AddTab("主要", "info"),
    Tools = Window:AddTab("工具", "settings"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel('Aiove将持续更新此脚本')
NoticeGroup:AddLabel('创作者：Aiove')

local TeleportGroup = Tabs.Main:AddLeftGroupbox("传送")

TeleportGroup:AddButton({ Text = '传送到购买点', Func = function()
    teleportTo(BUY_COORDS)
end })

TeleportGroup:AddButton({ Text = '传送到出售点', Func = function()
    teleportTo(SELL_COORDS)
end })

TeleportGroup:AddButton({ Text = '传送到洗钱点', Func = function()
    teleportTo(LAUNDER_COORDS)
end })

local EventGroup = Tabs.Main:AddLeftGroupbox("发送事件")

EventGroup:AddButton({ Text = '购买牛油果', Func = function()
    buyAvacados()
end })

EventGroup:AddButton({ Text = '出售牛油果', Func = function()
    sellAvacados()
end })

EventGroup:AddButton({ Text = '洗钱', Func = function()
    launderMoney()
end })

local AutoGroup = Tabs.Main:AddRightGroupbox("自动功能")

AutoGroup:AddToggle('AutoMoneyToggle', {
    Text = '自动刷钱',
    Default = false,
    Tooltip = '自动购买、出售、洗钱循环（穿墙平移）',
    Callback = function(Value)
        isMoneyRunning = Value
        if Value then
            task.spawn(moneyLoop)
        else
            setNoclip(false)
        end
    end,
})

AutoGroup:AddToggle('AutoPunchToggle', {
    Text = '自动挥拳',
    Default = false,
    Tooltip = '持续发送挥拳事件',
    Callback = function(Value)
        isPunchRunning = Value
        if Value then
            task.spawn(punchLoop)
        end
    end,
})

AutoGroup:AddSlider('PunchSpeed', {
    Text = '挥拳速度(秒)',
    Default = 0.5,
    Min = 0.1,
    Max = 5,
    Rounding = 1,
    Callback = function(Value)
        punchSpeed = Value
    end,
})

-- 工具页
local ToolsGroup = Tabs.Tools:AddLeftGroupbox("辅助功能")

ToolsGroup:AddToggle('ESPToggle', {
    Text = '透视',
    Default = false,
    Tooltip = '高亮显示所有玩家',
    Callback = function(Value)
        espEnabled = Value
        if Value then
            for _, p in ipairs(Players:GetPlayers()) do setupPlayerESP(p) end
        else
            for _, p in ipairs(Players:GetPlayers()) do cleanupESP(p) end
        end
    end,
})

ToolsGroup:AddToggle('FlyToggle', {
    Text = '飞车',
    Default = false,
    Tooltip = '开启后按视角方向飞行',
    Callback = function(Value)
        flyActive = Value
        if Value then
            startFly()
        else
            stopFly()
        end
    end,
})

ToolsGroup:AddSlider('FlySpeed', {
    Text = '飞车速度',
    Default = 50,
    Min = 1,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        flySpeed = Value
    end,
})

ToolsGroup:AddButton({ Text = '飞行', Func = function()
    Library:Notify("飞行脚本", "正在加载中...", 2)
    task.spawn(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/kongbaNB/9178/refs/heads/main/fly.lua"))()
    end)
end })

local speedValue = 16
ToolsGroup:AddSlider('SpeedSlider', {
    Text = '移速',
    Default = 16,
    Min = 0,
    Max = 150,
    Rounding = 0,
    Callback = function(Value)
        speedValue = Value
    end,
})

ToolsGroup:AddButton({ Text = '确定修改移速', Func = function()
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = speedValue
        end
    end
end })

ToolsGroup:AddToggle('GodModeToggle', {
    Text = '无敌',
    Default = false,
    Tooltip = '强锁定回拉，掉血立即回满',
    Callback = function(Value)
        setGodMode(Value)
    end,
})

ToolsGroup:AddToggle('VRGodModeToggle', {
    Text = '死亡',
    Default = false,
    Tooltip = '血量设为-999999999999',
    Callback = function(Value)
        setVRGodMode(Value)
    end,
})

local SettingsGroup = Tabs.Settings:AddLeftGroupbox("菜单")

SettingsGroup:AddButton({ Text = '卸载脚本', Func = function()
    isMoneyRunning = false
    isPunchRunning = false
    flyActive = false
    stopFly()
    setNoclip(false)
    espEnabled = false
    setGodMode(false)
    setVRGodMode(false)
    for _, p in ipairs(Players:GetPlayers()) do cleanupESP(p) end
    Library:Unload()
end })

SettingsGroup:AddLabel('菜单快捷键'):AddKeyPicker('MenuKeybind', {
    Default = 'RightShift',
    NoUI = true,
    Text = 'Menu keybind'
})
Library.ToggleKeybind = Options.MenuKeybind

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
