-- This file has been deobfuscated Luraph using Hurricane https://discord.com/invite/AbeurBzKXe
local function safeLoad(url)
    local s, r = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not s then
        warn("加载失败: " .. url)
        return nil
    end
    return r
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

local V = {}
V.Players = game:GetService("Players")
V.ReplicatedStorage = game:GetService("ReplicatedStorage")
V.RunService = game:GetService("RunService")
V.Workspace = game:GetService("Workspace")
V.player = V.Players.LocalPlayer

local conns = {}
local origObs = {}
local coinData = {}
local coinLoop = false
local coinThread = nil
local coinAddedConn = nil

local function addConn(c)
    table.insert(conns, c)
end

local function isObstacle(d)
    if not d:IsA("BasePart") then return false end
    local n = d.Name
    if n == "stumbleOnly" or n == "Col" or n == "bushCol" or n == "powerBoxCol" or n == "camCol" or n == "nohit" or n == "cargoHitbox" or n:find("blocker_") or n:find("Blocker") then
        return true
    end
    if n == "Col" or n == "stumbleOnly" then
        local p = d.Parent
        if p and (p.Name:find("Train") or p.Name:find("train") or p.Name:find("subway")) then
            return true
        end
    end
    return false
end

local function isCoin(d)
    if not d:IsA("BasePart") then return false end
    local n = d.Name:lower()
    return n == "coin" or n == "coinjump"
end

local function stripCoin(coin)
    local data = coinData[coin]
    if not data then
        data = { children = {}, canTouch = coin.CanTouch, canQuery = coin.CanQuery, canCollide = coin.CanCollide }
        coinData[coin] = data
        coin.CanTouch = false
        coin.CanQuery = false
        coin.CanCollide = false
    end
    for _, child in ipairs(coin:GetChildren()) do
        if not child:IsA("SpecialMesh") and not data.children[child] then
            data.children[child] = true
            child.Parent = V.ReplicatedStorage
        end
    end
end

local function restoreAllCoins()
    for coin, data in pairs(coinData) do
        if coin and coin.Parent then
            for child, _ in pairs(data.children) do
                if child and child.Parent == V.ReplicatedStorage then
                    child.Parent = coin
                end
            end
            coin.CanTouch = data.canTouch
            coin.CanQuery = data.canQuery
            coin.CanCollide = data.canCollide
        end
    end
    coinData = {}
end

local Window = Library:CreateWindow({
    Title = "地铁冲浪",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

pcall(function()
    Library:Notify({
        Title = "地铁冲浪",
        Description = "创作者：Aiove\nQQ：3999698324\n脚本已加载成功",
        Time = 5,
    })
end)

local Tabs = {}
Tabs.Notice = Window:AddTab("通知", "info")
Tabs.Main = Window:AddTab("主要", "info")
Tabs.Settings = Window:AddTab("设置", "settings")

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel("Aiove将持续更新此脚本")
NoticeGroup:AddLabel("创作者：Aiove")

local MainLeft = Tabs.Main:AddLeftGroupbox("跑酷功能")
local MainRight = Tabs.Main:AddRightGroupbox("道具获取")

local G = {}
G.RS = V.ReplicatedStorage
pcall(function()
    G.Modules = G.RS:WaitForChild("Modules", 5)
end)
G.SharedData = nil
pcall(function()
    if G.Modules then
        G.SharedData = require(G.Modules:WaitForChild("SharedData", 3))
    end
end)
G.PlayerData = nil
pcall(function()
    G.PlayerData = V.player:WaitForChild("PlayerData", 5)
end)
G.InTutorial = nil
pcall(function()
    if G.PlayerData then
        G.InTutorial = G.PlayerData:WaitForChild("InTutorial", 3)
    end
end)
G.CompleteTutorial = nil
pcall(function()
    G.CompleteTutorial = G.RS:WaitForChild("CompleteTutorial", 3)
end)

local F = {}
F.magnet = false
F.penetrate = false
F.fly = false
F.autoFarm = false
F.magnetConn = nil
F.superSpeed = false
F.superSpeedConn = nil
F.jetpackLock = false
F.jetpackLockConn = nil
F.jetpackLockBaseY = nil
F.jetpackVisual = false
F.jetpackVisualModel = nil
F.jetpackVisualCharConn = nil

local obsDescendantConn = nil
local obsRestoreConn = nil

local function findGameJetpack()
    local rs = game.ReplicatedStorage
    local searchNames = {"Jetpack", "FlyJetpack", "Backpack", "JetPack", "flyJetpack", "jetpack"}
    local function scanFolder(folder)
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("Model") or child:IsA("Part") or child:IsA("MeshPart") then
                local n = child.Name:lower()
                for _, sn in ipairs(searchNames) do
                    if n:find(sn:lower()) then
                        return child
                    end
                end
            end
            if child:IsA("Folder") or child:IsA("Model") then
                local found = scanFolder(child)
                if found then return found end
            end
        end
        return nil
    end
    local result = scanFolder(rs)
    if result then return result:Clone() end
    return nil
end

local function attachVisualJetpack(char)
    if not char then return end
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    if not torso then return end
    if F.jetpackVisualModel and F.jetpackVisualModel.Parent then
        F.jetpackVisualModel:Destroy()
    end
    local model = findGameJetpack()
    if not model then
        model = Instance.new("Part")
        model.Name = "JetpackVisual"
        model.Size = Vector3.new(1.2, 1.4, 0.7)
        model.CanCollide = false
        model.Anchored = false
        model.Transparency = 0.2
        model.Color = Color3.fromRGB(255, 80, 0)
        model.Material = Enum.Material.Neon
    end
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Anchored = false
        end
    end
    local weld = Instance.new("Weld")
    local primary = model:IsA("Model") and model.PrimaryPart or (model:IsA("BasePart") and model or model:FindFirstChildWhichIsA("BasePart"))
    if primary then
        weld.Part0 = torso
        weld.Part1 = primary
        weld.C0 = CFrame.new(0, 0.3, 0.7) * CFrame.Angles(0, math.pi, 0)
        weld.Parent = primary
    end
    model.Parent = char
    F.jetpackVisualModel = model
end

local function removeVisualJetpack()
    if F.jetpackVisualModel and F.jetpackVisualModel.Parent then
        F.jetpackVisualModel:Destroy()
    end
    F.jetpackVisualModel = nil
end

MainLeft:AddButton("一键完成新手教程", function()
    pcall(function()
        if G.CompleteTutorial then
            G.CompleteTutorial:FireServer()
        end
    end)
    pcall(function()
        if G.InTutorial then
            G.InTutorial.Value = false
        end
    end)
    pcall(function()
        if G.SharedData then
            G.SharedData.InTutorial = false
        end
    end)
    pcall(function()
        Library:Notify({
            Title = "教程",
            Description = "新手教程已完成",
            Time = 3,
        })
    end)
end)

MainLeft:AddToggle("MagnetCoins", {
    Text = "疯狂吸金币",
    Default = false,
    Callback = function(Value)
        F.magnet = Value
        if Value then
            task.spawn(function()
                while F.magnet do
                    local c = V.player.Character
                    if c and c:FindFirstChild("HumanoidRootPart") then
                        local h = c.HumanoidRootPart
                        for _, o in ipairs(V.Workspace:GetDescendants()) do
                            if o:IsA("BasePart") and (o.Name:lower():find("coin") or o.Name:lower():find("gold")) then
                                pcall(function()
                                    o.CFrame = h.CFrame
                                end)
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end,
})

MainLeft:AddToggle("InfiniteFly", {
    Text = "无限飞行",
    Default = false,
    Callback = function(Value)
        F.fly = Value
        if Value then
            task.spawn(function()
                while F.fly do
                    pcall(function()
                        if G.SharedData and G.SharedData.PickupEvent then
                            G.SharedData.PickupEvent:Fire("fly")
                        end
                    end)
                    task.wait(3)
                end
            end)
        end
    end,
})

MainLeft:AddToggle("AutoFarm", {
    Text = "刷金币",
    Default = false,
    Callback = function(Value)
        F.autoFarm = Value
        if Value then
            task.spawn(function()
                while F.autoFarm do
                    pcall(function()
                        if G.SharedData and G.SharedData.PickupEvent then
                            G.SharedData.PickupEvent:Fire("fly")
                        end
                    end)
                    task.wait(3)
                end
            end)
            task.spawn(function()
                while F.autoFarm do
                    local c = V.player.Character
                    if c and c:FindFirstChild("HumanoidRootPart") then
                        local h = c.HumanoidRootPart
                        for _, o in ipairs(V.Workspace:GetDescendants()) do
                            if o:IsA("BasePart") and (o.Name:lower():find("coin") or o.Name:lower():find("gold")) then
                                pcall(function()
                                    o.CFrame = h.CFrame
                                end)
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end,
})

MainLeft:AddToggle("ObstacleNoclip", {
    Text = "穿透障碍物",
    Default = false,
    Callback = function(v)
        if v then
            if obsRestoreConn then
                pcall(function() obsRestoreConn:Disconnect() end)
                obsRestoreConn = nil
            end
            origObs = {}
            for _, d in ipairs(V.Workspace:GetDescendants()) do
                if isObstacle(d) then
                    origObs[d] = d.CanCollide
                    d.CanCollide = false
                end
            end
            if obsDescendantConn then
                pcall(function() obsDescendantConn:Disconnect() end)
                obsDescendantConn = nil
            end
            obsDescendantConn = V.Workspace.DescendantAdded:Connect(function(d)
                if isObstacle(d) then
                    origObs[d] = d.CanCollide
                    d.CanCollide = false
                end
            end)
            addConn(obsDescendantConn)
        else
            if obsDescendantConn then
                pcall(function() obsDescendantConn:Disconnect() end)
                obsDescendantConn = nil
            end
            for d, state in pairs(origObs) do
                if d and d.Parent then d.CanCollide = state end
            end
            origObs = {}
            if obsRestoreConn then
                pcall(function() obsRestoreConn:Disconnect() end)
                obsRestoreConn = nil
            end
            obsRestoreConn = V.Workspace.DescendantAdded:Connect(function(d)
                if isObstacle(d) then
                    d.CanCollide = true
                end
            end)
            addConn(obsRestoreConn)
        end
    end,
})

MainLeft:AddToggle("CoinStrip", {
    Text = "穿透金币",
    Default = false,
    Callback = function(v)
        if v then
            coinLoop = true
            for _, d in ipairs(V.Workspace:GetDescendants()) do
                if isCoin(d) then
                    stripCoin(d)
                end
            end
            coinAddedConn = V.Workspace.DescendantAdded:Connect(function(d)
                if isCoin(d) then
                    stripCoin(d)
                end
            end)
            addConn(coinAddedConn)
            coinThread = task.spawn(function()
                while coinLoop do
                    for _, d in ipairs(V.Workspace:GetDescendants()) do
                        if isCoin(d) then
                            stripCoin(d)
                        end
                    end
                    task.wait(0.1)
                end
            end)
        else
            coinLoop = false
            if coinThread then
                coinThread = nil
            end
            if coinAddedConn then
                pcall(function() coinAddedConn:Disconnect() end)
                coinAddedConn = nil
            end
            restoreAllCoins()
        end
    end,
})

MainLeft:AddToggle("SuperSpeedBug", {
    Text = "超高移速bug",
    Default = false,
    Callback = function(Value)
        if Value then
            local s1, Modules = pcall(function()
                return game.ReplicatedStorage:WaitForChild("Modules", 3)
            end)
            local s2, SharedData = pcall(function()
                if Modules then return require(Modules:WaitForChild("SharedData", 3)) end
            end)
            local s3, Services = pcall(function()
                if Modules then return require(Modules:WaitForChild("Services", 3)) end
            end)
            local s4, UseHeadstart = pcall(function()
                if Services then return Services.RepStorage:WaitForChild("UseHeadstart", 3) end
            end)
            pcall(function()
                if UseHeadstart then
                    UseHeadstart:InvokeServer("MHeadstart")
                end
            end)
            pcall(function()
                if SharedData then
                    SharedData.PowerUps = SharedData.PowerUps or {}
                    SharedData.PowerUpsDuration = SharedData.PowerUpsDuration or {}
                    SharedData.PowerUps["headstart"] = true
                    SharedData.PowerUpsDuration["headstart"] = 9999
                    if SharedData.PowerUpChanged then
                        SharedData.PowerUpChanged:Fire("headstart", true)
                    end
                end
            end)
            F.superSpeed = true
            F.superSpeedConn = V.RunService.Heartbeat:Connect(function()
                pcall(function()
                    if SharedData then
                        SharedData.CurSpd = 999
                    end
                end)
            end)
            addConn(F.superSpeedConn)
            task.spawn(function()
                task.wait(0.2)
                pcall(function()
                    if SharedData then
                        SharedData.PowerUps = SharedData.PowerUps or {}
                        SharedData.PowerUpsDuration = SharedData.PowerUpsDuration or {}
                        SharedData.PowerUps["headstart"] = false
                        SharedData.PowerUpsDuration["headstart"] = 0
                        if SharedData.PowerUpChanged then
                            SharedData.PowerUpChanged:Fire("headstart", false)
                        end
                    end
                end)
                pcall(function()
                    if Toggles["SuperSpeedBug"] then
                        Toggles["SuperSpeedBug"]:SetValue(false)
                    end
                end)
            end)
        else
            F.superSpeed = false
            if F.superSpeedConn then
                pcall(function() F.superSpeedConn:Disconnect() end)
                F.superSpeedConn = nil
            end
        end
    end,
})

MainLeft:AddToggle("JetpackLock", {
    Text = "喷气背包锁高度飞",
    Default = false,
    Callback = function(Value)
        if Value then
            F.jetpackLock = true
            pcall(function()
                if G.SharedData and G.SharedData.PickupEvent then
                    G.SharedData.PickupEvent:Fire("fly")
                end
                if G.SharedData and G.SharedData.PowerUps then
                    G.SharedData.PowerUps["fly"] = true
                end
                if G.SharedData and G.SharedData.PowerUpsDuration then
                    G.SharedData.PowerUpsDuration["fly"] = 9999
                end
                if G.SharedData and G.SharedData.PowerUpChanged then
                    G.SharedData.PowerUpChanged:Fire("fly", true)
                end
            end)
            F.jetpackLockConn = V.RunService.Heartbeat:Connect(function()
                local char = V.player.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                if not F.jetpackLockBaseY then
                    F.jetpackLockBaseY = hrp.Position.Y
                end
                local pos = hrp.Position
                local rot = hrp.CFrame - hrp.CFrame.Position
                hrp.CFrame = CFrame.new(pos.X, F.jetpackLockBaseY, pos.Z) * rot
            end)
            addConn(F.jetpackLockConn)
        else
            F.jetpackLock = false
            F.jetpackLockBaseY = nil
            if F.jetpackLockConn then
                pcall(function() F.jetpackLockConn:Disconnect() end)
                F.jetpackLockConn = nil
            end
            pcall(function()
                if G.SharedData and G.SharedData.PowerUps then
                    G.SharedData.PowerUps["fly"] = false
                end
                if G.SharedData and G.SharedData.PowerUpsDuration then
                    G.SharedData.PowerUpsDuration["fly"] = 0
                end
                if G.SharedData and G.SharedData.PowerUpChanged then
                    G.SharedData.PowerUpChanged:Fire("fly", false)
                end
            end)
        end
    end,
})

MainLeft:AddToggle("JetpackVisual", {
    Text = "喷气背包",
    Default = false,
    Callback = function(Value)
        if Value then
            F.jetpackVisual = true
            attachVisualJetpack(V.player.Character)
            F.jetpackVisualCharConn = V.player.CharacterAdded:Connect(function(char)
                task.wait(0.5)
                if F.jetpackVisual then
                    attachVisualJetpack(char)
                end
            end)
            addConn(F.jetpackVisualCharConn)
        else
            F.jetpackVisual = false
            removeVisualJetpack()
            if F.jetpackVisualCharConn then
                pcall(function() F.jetpackVisualCharConn:Disconnect() end)
                F.jetpackVisualCharConn = nil
            end
        end
    end,
})

local function addItemButton(name, text, fireName)
    MainRight:AddButton(text, function()
        pcall(function()
            if G.SharedData and G.SharedData.PickupEvent then
                G.SharedData.PickupEvent:Fire(fireName)
            end
            if G.SharedData and G.SharedData.PowerUps then
                G.SharedData.PowerUps[fireName] = true
                if G.SharedData.PowerUpsDuration then
                    G.SharedData.PowerUpsDuration[fireName] = 9999
                end
            end
        end)
        pcall(function()
            Library:Notify({
                Title = "道具",
                Description = "已尝试获取" .. name,
                Time = 2,
            })
        end)
    end)
end

addItemButton("滑板", "获取滑板 (Hoverboard)", "hoverboard")
addItemButton("M超级起步", "获取超级起步 (M)", "headstart")
addItemButton("S超级起步", "获取超级起步 (S)", "headstart")
addItemButton("磁铁", "获取磁铁 (Magnet)", "magnet")
addItemButton("倍数", "获取倍数 (Multiplier)", "mult")
addItemButton("跳跃", "获取跳跃 (Jump)", "jumpBooster")
addItemButton("飞行器", "获取飞行器 (Fly)", "fly")

local UnloadGroup = Tabs.Settings:AddLeftGroupbox("脚本管理")
UnloadGroup:AddButton("卸载脚本", function()
    F.magnet = false
    F.penetrate = false
    F.fly = false
    F.autoFarm = false
    F.superSpeed = false
    F.jetpackLock = false
    F.jetpackLockBaseY = nil
    F.jetpackVisual = false
    removeVisualJetpack()
    coinLoop = false
    if coinAddedConn then
        pcall(function() coinAddedConn:Disconnect() end)
        coinAddedConn = nil
    end
    if obsDescendantConn then
        pcall(function() obsDescendantConn:Disconnect() end)
        obsDescendantConn = nil
    end
    if obsRestoreConn then
        pcall(function() obsRestoreConn:Disconnect() end)
        obsRestoreConn = nil
    end
    if F.magnetConn then
        pcall(function() F.magnetConn:Disconnect() end)
        F.magnetConn = nil
    end
    if F.superSpeedConn then
        pcall(function() F.superSpeedConn:Disconnect() end)
        F.superSpeedConn = nil
    end
    if F.jetpackLockConn then
        pcall(function() F.jetpackLockConn:Disconnect() end)
        F.jetpackLockConn = nil
    end
    if F.jetpackVisualCharConn then
        pcall(function() F.jetpackVisualCharConn:Disconnect() end)
        F.jetpackVisualCharConn = nil
    end
    restoreAllCoins()
    for d, state in pairs(origObs) do
        if d and d.Parent then d.CanCollide = state end
    end
    origObs = {}
    for _, c in ipairs(conns) do
        pcall(function() c:Disconnect() end)
    end
    conns = {}
    Library:Unload()
end)

if ThemeManager and type(ThemeManager) == "table" and ThemeManager.SetLibrary and ThemeManager.SetFolder and ThemeManager.ApplyToTab then
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("MyScriptTheme")
    ThemeManager:ApplyToTab(Tabs.Settings)
end

if SaveManager and type(SaveManager) == "table" and SaveManager.SetLibrary and SaveManager.IgnoreThemeSettings and SaveManager.SetFolder and SaveManager.BuildConfigSection then
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetFolder("MyScriptConfig")
    SaveManager:BuildConfigSection(Tabs.Settings)
end

