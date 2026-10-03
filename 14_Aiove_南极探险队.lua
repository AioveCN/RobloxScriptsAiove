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
local player = Players.LocalPlayer

local Window = Library:CreateWindow({
    Title = "南极洲探险",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify({
    Title = "南极洲探险",
    Description = "创作者：Aiove\nQQ：3999698324\n脚本已加载成功",
    Time = 5,
})

local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Main = Window:AddTab("主要", "info"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel('Aiove将持续更新此脚本')
NoticeGroup:AddLabel('创作者：Aiove')
NoticeGroup:AddLabel('QQ：3999698324')

-- ======== 服务引用 ========
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local lplr = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera

-- ======== 状态变量 ========
local infiniteJumpEnabled = false
local noclipEnabled = false
local walkSpeedValue = 16
local espEnabled = false
local copiedPosition = nil
local teleportX = ""
local teleportY = ""
local teleportZ = ""
local teleportCoords = ""
local respawnAtPositionEnabled = false

-- ======== 无限跳 ========
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local char = lplr.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ======== 穿墙（使用他的逻辑） ========
local noclipConnection = nil

local function setNoclip(state)
    if state then
        noclipConnection = RunService.Stepped:Connect(function()
            local char = lplr.Character
            if not char then return end
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        local char = lplr.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                end
            end
        end
    end
end

-- ======== 透视（使用他的逻辑） ========
local espBillboards = {}
local espHighlights = {}
local espConnections = {}
local espRenderConn = nil

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
    espHighlights[targetPlayer] = nil
end

local function createESP(targetPlayer)
    if targetPlayer == lplr then return end
    local char = targetPlayer.Character
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
    espHighlights[targetPlayer] = highlight

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
    if targetPlayer == lplr then return end
    if espConnections[targetPlayer] then
        for _, conn in ipairs(espConnections[targetPlayer]) do
            pcall(function() conn:Disconnect() end)
        end
    end
    espConnections[targetPlayer] = {}

    local charAddedConn = targetPlayer.CharacterAdded:Connect(function(char)
        task.spawn(function()
            pcall(function() char:WaitForChild("HumanoidRootPart", 5) end)
            if espEnabled then
                task.wait(0.1)
                createESP(targetPlayer)
            end
        end)
    end)

    local charRemovingConn = targetPlayer.CharacterRemoving:Connect(function()
        cleanupESP(targetPlayer)
    end)

    table.insert(espConnections[targetPlayer], charAddedConn)
    table.insert(espConnections[targetPlayer], charRemovingConn)

    if targetPlayer.Character and espEnabled then
        createESP(targetPlayer)
    end
end

local function startESP()
    for _, p in ipairs(Players:GetPlayers()) do
        task.spawn(function()
            setupPlayerESP(p)
        end)
    end

    Players.PlayerAdded:Connect(function(p)
        task.spawn(function()
            setupPlayerESP(p)
        end)
    end)

    Players.PlayerRemoving:Connect(function(p)
        cleanupESP(p)
    end)

    local lastEspUpdate = 0
    local myLastPos = nil
    espRenderConn = RunService.RenderStepped:Connect(function()
        if not espEnabled then return end

        local now = tick()
        if now - lastEspUpdate < 0.5 then return end
        lastEspUpdate = now

        local myChar = lplr.Character
        local myPos = myChar and myChar:FindFirstChild("HumanoidRootPart") and myChar.HumanoidRootPart.Position

        if myLastPos and myPos and (myPos - myLastPos).Magnitude < 0.1 then
            return
        end
        myLastPos = myPos

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
end

local function stopESP()
    if espRenderConn then
        espRenderConn:Disconnect()
        espRenderConn = nil
    end
    for p, _ in pairs(espConnections) do
        cleanupESP(p)
    end
    espConnections = {}
    espBillboards = {}
    espHighlights = {}
end

-- ======== 修改移速 ========
local function updateWalkSpeed()
    local char = lplr.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = walkSpeedValue
    end
end

lplr.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    updateWalkSpeed()
    if noclipEnabled then
        setNoclip(true)
    end
end)

-- ======== 原地复活 ========
local respawnConnection = nil

local function respawnAtPosition()
    local char = lplr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local currentPos = hrp.CFrame
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Health = 0
    end
    lplr.CharacterAdded:Wait()
    task.wait(0.5)
    local newChar = lplr.Character
    if newChar then
        local newHrp = newChar:WaitForChild("HumanoidRootPart", 3)
        if newHrp then
            newHrp.CFrame = currentPos
        end
    end
end

local function setRespawnAtPosition(state)
    if state then
        respawnConnection = lplr.CharacterAdded:Connect(function(char)
            task.wait(0.3)
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and copiedPosition then
                hrp.CFrame = CFrame.new(copiedPosition)
            end
        end)
    else
        if respawnConnection then
            respawnConnection:Disconnect()
            respawnConnection = nil
        end
    end
end

-- ======== 主要页功能 ========
local MovementGroup = Tabs.Main:AddLeftGroupbox("移动")

MovementGroup:AddToggle("InfiniteJump", {
    Text = "无限跳",
    Default = false,
    Callback = function(state)
        infiniteJumpEnabled = state
    end
})

MovementGroup:AddButton("飞行", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/kongbaNB/9178/refs/heads/main/fly.lua"))()
    Library:Notify("飞行脚本已加载", 3)
end)

MovementGroup:AddSlider("WalkSpeed", {
    Text = "移动速度",
    Default = 16,
    Min = 1,
    Max = 200,
    Rounding = 0,
    Callback = function(value)
        walkSpeedValue = value
        updateWalkSpeed()
    end
})

local WorldGroup = Tabs.Main:AddRightGroupbox("世界")

WorldGroup:AddButton("自动垫圈", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/Zt4kkQG9"))()
    Library:Notify("自动垫圈脚本已加载", 3)
end)

WorldGroup:AddToggle("Noclip", {
    Text = "穿墙",
    Default = false,
    Callback = function(state)
        noclipEnabled = state
        setNoclip(state)
    end
})

WorldGroup:AddToggle("ESP", {
    Text = "玩家透视",
    Default = false,
    Callback = function(state)
        espEnabled = state
        if state then
            startESP()
        else
            stopESP()
        end
    end
})

-- ======== 传送功能 ========
local TeleportGroup = Tabs.Main:AddLeftGroupbox("传送")

TeleportGroup:AddButton("复制当前坐标", function()
    local char = lplr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local pos = hrp.Position
        local posStr = string.format("%.2f, %.2f, %.2f", pos.X, pos.Y, pos.Z)
        if setclipboard then
            setclipboard(posStr)
            Library:Notify("坐标已复制到剪贴板: " .. posStr, 3)
        else
            copiedPosition = pos
            Library:Notify("坐标已保存: " .. posStr, 3)
        end
    else
        Library:Notify("无法获取坐标", 3)
    end
end)

TeleportGroup:AddInput("TeleportCoords", {
    Text = "坐标输入",
    Default = "",
    Numeric = false,
    Finished = true,
    Placeholder = "例如: 123.45, 67.89, 90.12",
    Callback = function(value)
        teleportCoords = value
    end
})

TeleportGroup:AddButton("传送到指定坐标", function()
    if not teleportCoords or teleportCoords == "" then
        Library:Notify("请输入坐标", 3)
        return
    end
    local parts = {}
    for part in string.gmatch(teleportCoords, "[^,]+") do
        table.insert(parts, tonumber(part:match("%S+")))
    end
    if #parts >= 3 and parts[1] and parts[2] and parts[3] then
        local char = lplr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(parts[1], parts[2], parts[3])
            Library:Notify(string.format("已传送到: %.2f, %.2f, %.2f", parts[1], parts[2], parts[3]), 3)
        end
    else
        Library:Notify("坐标格式错误，请使用: X, Y, Z", 3)
    end
end)

TeleportGroup:AddButton("传送到营地一", function()
    local char = lplr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(-3645.38, 229.04, 227.99)
        Library:Notify("已传送到营地一", 3)
    end
end)

TeleportGroup:AddButton("传送到营地二", function()
    local char = lplr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(1796.10, 104.87, -126.17)
        Library:Notify("已传送到营地二", 3)
    end
end)

TeleportGroup:AddButton("传送到营地三", function()
    local char = lplr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(5872.28, 321.00, -52.60)
        Library:Notify("已传送到营地三", 3)
    end
end)

TeleportGroup:AddButton("传送到营地四", function()
    local char = lplr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(8991.69, 596.50, 92.92)
        Library:Notify("已传送到营地四", 3)
    end
end)

TeleportGroup:AddButton("传送到终点", function()
    local char = lplr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(10963.29, 549.00, 72.14)
        Library:Notify("已传送到终点", 3)
    end
end)

TeleportGroup:AddButton("设置重生点", function()
    local char = lplr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        copiedPosition = hrp.Position
        local posStr = string.format("%.2f, %.2f, %.2f", copiedPosition.X, copiedPosition.Y, copiedPosition.Z)
        Library:Notify("重生点已设置: " .. posStr, 3)
    else
        Library:Notify("无法获取当前位置", 3)
    end
end)

TeleportGroup:AddButton("传送到复制坐标", function()
    if copiedPosition then
        local char = lplr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(copiedPosition)
            Library:Notify("已传送到复制的坐标", 3)
        end
    else
        Library:Notify("没有复制的坐标", 3)
    end
end)

TeleportGroup:AddToggle("RespawnAtPosition", {
    Text = "原地复活",
    Default = false,
    Callback = function(state)
        respawnAtPositionEnabled = state
        setRespawnAtPosition(state)
    end
})

-- ======== 设置页 ========
local UnloadGroup = Tabs.Settings:AddLeftGroupbox("脚本管理")
UnloadGroup:AddButton("卸载脚本", function()
    if noclipConnection then noclipConnection:Disconnect() end
    if flyConnection then flyConnection:Disconnect() end
    if scaffoldConnection then scaffoldConnection:Disconnect() end
    if espRenderConn then espRenderConn:Disconnect() end
    if respawnConnection then respawnConnection:Disconnect() end
    for _, p in ipairs(scaffoldParts) do
        if p and p.Parent then p:Destroy() end
    end
    for p, _ in pairs(espConnections) do
        cleanupESP(p)
    end
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

