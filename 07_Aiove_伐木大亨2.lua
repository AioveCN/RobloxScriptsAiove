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
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local ContextActionService = game:GetService("ContextActionService")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")
local player = Players.LocalPlayer
local lp = player
local Mouse = player:GetMouse()
local mouse = Mouse

local Window = Library:CreateWindow({
    Title = "伐木大亨二",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify({
    Title = "小布丁 定制",
    Description = "Aiove 制作",
    Time = 5,
})

local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Main = Window:AddTab("主要", "info"),
    AutoBuy = Window:AddTab("自动购买", "shopping-cart"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel('Aiove将持续更新此脚本')
NoticeGroup:AddLabel('小布丁 定制')
NoticeGroup:AddLabel('创作者：Aiove')

local TreeGroup = Tabs.Main:AddLeftGroupbox("砍树")
local LandGroup = Tabs.Main:AddLeftGroupbox("土地")
local AxeGroup = Tabs.Main:AddLeftGroupbox("斧头")
local BaseGroup = Tabs.Main:AddLeftGroupbox("基地")
local BringTreeGroup = Tabs.Main:AddLeftGroupbox("带来树")
local WoodGroup = Tabs.Main:AddLeftGroupbox("木头处理")
local ItemTpGroup = Tabs.Main:AddLeftGroupbox("传送物品")
local CarSpawnGroup = Tabs.Main:AddLeftGroupbox("刷粉车")
local OtherGroup = Tabs.Main:AddLeftGroupbox("其他功能")
local ChatGroup = Tabs.Main:AddLeftGroupbox("语言")
local FunGroup = Tabs.Main:AddLeftGroupbox("娱乐")
local PlankSortGroup = Tabs.Main:AddLeftGroupbox("整理木板")
local StackGroup = Tabs.Main:AddLeftGroupbox("整理")
local BlueprintGroup = Tabs.Main:AddLeftGroupbox("填充蓝图")

local PlayerGroup = Tabs.Main:AddRightGroupbox("玩家")
local EnvGroup = Tabs.Main:AddRightGroupbox("环境")
local TpGroup = Tabs.Main:AddRightGroupbox("普通传送")
local TreeTpGroup = Tabs.Main:AddRightGroupbox("传送到树")
local CarTpGroup = Tabs.Main:AddRightGroupbox("汽车传送")
local MoneyGroup = Tabs.Main:AddRightGroupbox("快速转钱")
local CarGroup = Tabs.Main:AddRightGroupbox("汽车")
local DevilGroup = Tabs.Main:AddRightGroupbox("魔鬼功能")

local autoChop = false
local sellingWood = false
local chopBlacklist = {}
local treeHits = {}
local treeList = {}
local lastScan = 0
local lastAxeNotify = 0

local specialDamage = {
    EndTimesAxe = {LoneCave = 10000000},
    OvergrownAxe = {GreenSwampy = 7, GoldSwampy = 5.35},
    FireAxe = {Volcano = 6.35},
    CaveAxe = {CaveCrawler = 7.2},
    IceAxe = {Frost = 6},
}

local function getAxeDamage(axe, treeClass)
    local tn = ""
    local tnv = axe:FindFirstChild("ToolName")
    if tnv then
        tn = tostring(tnv.Value)
    end
    local sp = specialDamage[tn]
    if sp and sp[treeClass] then
        return sp[treeClass]
    end
    local ok, dmg = pcall(function()
        local mod = require(ReplicatedStorage.AxeClasses["AxeClass_" .. tn])
        return mod.new().Damage
    end)
    if ok and type(dmg) == "number" and dmg > 0 then
        return dmg
    end
    return 1
end

local function isAxe(v)
    return v:IsA("Tool") and v.Name ~= "BlueprintTool" and (v:FindFirstChild("CuttingTool") or v:FindFirstChild("ToolName"))
end

local function getAxe()
    local char = player.Character
    if char then
        for _, v in ipairs(char:GetChildren()) do
            if isAxe(v) then
                return v
            end
        end
    end
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, v in ipairs(backpack:GetChildren()) do
            if isAxe(v) then
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:EquipTool(v)
                    task.wait(0.2)
                end
                return v
            end
        end
    end
    return nil
end

local function dragModel(model, cf)
    pcall(function()
        ReplicatedStorage.Interaction.ClientIsDragging:FireServer(model)
    end)
    if not model.PrimaryPart then
        model.PrimaryPart = model:FindFirstChildOfClass("Part")
    end
    pcall(function()
        model:PivotTo(cf)
    end)
end

local function teleportTo(cf)
    local char = player.Character
    if not char then
        return
    end
    for i = 1, 3 do
        dragModel(char, cf)
        task.wait()
    end
end

local function isTreeModel(model)
    return model:IsA("Model") and model:FindFirstChild("CutEvent") and model:FindFirstChild("WoodSection")
end

local function ownerBlocked(model)
    local owner = model:FindFirstChild("Owner")
    if not owner then
        return false
    end
    local ok, val = pcall(function()
        return owner.Value
    end)
    if ok and val ~= nil and val ~= player then
        return true
    end
    return false
end

local function refreshTrees(force)
    local now = tick()
    if not force and now - lastScan < 4 then
        return
    end
    lastScan = now
    treeList = {}
    local seen = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name == "TreeRegion" then
            for _, model in ipairs(v:GetChildren()) do
                if not seen[model] and isTreeModel(model) and not model:FindFirstChild("RootCut") and not ownerBlocked(model) then
                    seen[model] = true
                    table.insert(treeList, model)
                end
            end
        end
    end
    if #treeList == 0 then
        for _, model in ipairs(workspace:GetChildren()) do
            if not seen[model] and isTreeModel(model) and not model:FindFirstChild("RootCut") and not ownerBlocked(model) then
                seen[model] = true
                table.insert(treeList, model)
            end
        end
    end
end

local function getBaseSection(tree)
    local fallback = nil
    for _, v in ipairs(tree:GetDescendants()) do
        if v:IsA("BasePart") and v.Name == "WoodSection" then
            fallback = fallback or v
            local id = v:FindFirstChild("ID")
            if id and id.Value == 1 then
                return v
            end
        end
    end
    return fallback
end

local function getNearestTree()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then
        return nil, nil
    end
    local now = tick()
    local best, bestSection, bestDist = nil, nil, math.huge
    local alive = {}
    for _, tree in ipairs(treeList) do
        if tree:IsDescendantOf(workspace) and not tree:FindFirstChild("RootCut") then
            table.insert(alive, tree)
            if not (chopBlacklist[tree] and chopBlacklist[tree] > now) then
                local section = getBaseSection(tree)
                if section then
                    local d = (section.Position - root.Position).Magnitude
                    if d < bestDist then
                        bestDist = d
                        best = tree
                        bestSection = section
                    end
                end
            end
        end
    end
    treeList = alive
    return best, bestSection
end

TreeGroup:AddToggle("AutoChop", {
    Text = "自动砍树",
    Default = false,
    Tooltip = "自动传送到最近的树并快速砍倒",
    Callback = function(Value)
        autoChop = Value
        if Value then
            task.spawn(function()
                pcall(function()
                    refreshTrees(true)
                    Library:Notify({
                        Title = "自动砍树",
                        Description = "搜索完成，找到 " .. #treeList .. " 棵树",
                        Time = 4,
                    })
                end)
            end)
        end
    end,
})

Toggles.AutoChop:OnChanged(function(Value)
    autoChop = Value
end)

TreeGroup:AddButton("出售全部木头", function()
    if sellingWood then
        return
    end
    sellingWood = true
    task.spawn(function()
        pcall(function()
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then
                return
            end
            local oldpos = root.CFrame
            local sell = CFrame.new(315.12146, -0.190167814, 85.0448074)
            local logModels = workspace:FindFirstChild("LogModels")
            if logModels then
                for _, v in ipairs(logModels:GetDescendants()) do
                    if v:IsA("Model") and v:FindFirstChild("WoodSection") and not ownerBlocked(v) then
                        for i = 1, 20 do
                            dragModel(v, sell)
                            task.wait(0.1)
                        end
                    end
                end
            end
            teleportTo(oldpos)
        end)
        sellingWood = false
        Library:Notify({
            Title = "出售全部木头",
            Description = "处理完成",
            Time = 3,
        })
    end)
end)

LandGroup:AddButton("免费土地", function()
    task.spawn(function()
        pcall(function()
            local props = workspace:FindFirstChild("Properties")
            if not props then
                return
            end
            for _, v in ipairs(props:GetChildren()) do
                local owner = v:FindFirstChild("Owner")
                local square = v:FindFirstChild("OriginSquare")
                if owner and square then
                    local ok, val = pcall(function()
                        return owner.Value
                    end)
                    if ok and val == nil then
                        ReplicatedStorage.PropertyPurchasing.ClientPurchasedProperty:FireServer(v, square.OriginCFrame.Value.p + Vector3.new(0, 3, 0))
                        task.wait(0.5)
                        break
                    end
                end
            end
            for _, v in ipairs(props:GetChildren()) do
                local owner = v:FindFirstChild("Owner")
                if owner and v:FindFirstChild("OriginSquare") then
                    local ok, val = pcall(function()
                        return owner.Value
                    end)
                    if ok and val == player then
                        teleportTo(v.OriginSquare.CFrame + Vector3.new(0, 10, 0))
                        break
                    end
                end
            end
        end)
        Library:Notify({
            Title = "免费土地",
            Description = "处理完成",
            Time = 3,
        })
    end)
end)

LandGroup:AddButton("最大土地", function()
    task.spawn(function()
        pcall(function()
            local props = workspace:FindFirstChild("Properties")
            if not props then
                return
            end
            local base, square
            for _, v in ipairs(props:GetChildren()) do
                local owner = v:FindFirstChild("Owner")
                if owner then
                    local ok, val = pcall(function()
                        return owner.Value
                    end)
                    if ok and val == player then
                        base = v
                        square = v:FindFirstChild("OriginSquare")
                        break
                    end
                end
            end
            if not base or not square then
                return
            end
            local spos = square.Position
            local offsets = {
                {40, 0}, {-40, 0}, {0, 40}, {0, -40},
                {40, 40}, {40, -40}, {-40, 40}, {-40, -40},
                {80, 0}, {-80, 0}, {0, 80}, {0, -80},
                {80, 80}, {80, -80}, {-80, 80}, {-80, -80},
                {40, 80}, {-40, 80}, {80, 40}, {80, -40},
                {40, -80}, {-40, -80}, {-80, 40}, {-80, -40},
            }
            for _, o in ipairs(offsets) do
                ReplicatedStorage.PropertyPurchasing.ClientExpandedProperty:FireServer(base, CFrame.new(spos.X + o[1], spos.Y, spos.Z + o[2]))
                task.wait()
            end
        end)
        Library:Notify({
            Title = "最大土地",
            Description = "处理完成",
            Time = 3,
        })
    end)
end)

task.spawn(function()
    while true do
        task.wait(0.15)
        if not autoChop then
            continue
        end
        pcall(function()
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then
                return
            end
            local axe = getAxe()
            if not axe then
                if tick() - lastAxeNotify > 6 then
                    lastAxeNotify = tick()
                    Library:Notify({
                        Title = "自动砍树",
                        Description = "没有找到斧头，请确认斧头在背包里",
                        Time = 4,
                    })
                end
                return
            end
            local proxy = ReplicatedStorage.Interaction.RemoteProxy
            refreshTrees(false)
            local tree, section = getNearestTree()
            if not tree then
                refreshTrees(true)
                return
            end
            if (section.Position - root.Position).Magnitude > 8 then
                teleportTo(section.CFrame + Vector3.new(0, 2.5, 3.5))
                task.wait(0.2)
            end
            local treeClass = "Generic"
            local tc = tree:FindFirstChild("TreeClass")
            if tc then
                treeClass = tostring(tc.Value)
            end
            local damage = getAxeDamage(axe, treeClass)
            local sectionId = 1
            local idVal = section:FindFirstChild("ID")
            if idVal then
                sectionId = idVal.Value
            end
            local cut = tree:FindFirstChild("CutEvent")
            if not cut then
                return
            end
            local args = {
                ["tool"] = axe,
                ["faceVector"] = Vector3.new(1, 0, 0),
                ["height"] = 0.3,
                ["sectionId"] = sectionId,
                ["hitPoints"] = damage,
                ["cooldown"] = 0.01,
                ["cuttingClass"] = "Axe",
            }
            local fired = 0
            for i = 1, 25 do
                if not autoChop then
                    break
                end
                if not tree:IsDescendantOf(workspace) then
                    break
                end
                if tree:FindFirstChild("RootCut") then
                    break
                end
                proxy:FireServer(cut, args)
                fired = fired + 1
                task.wait(0.05)
            end
            if tree:FindFirstChild("RootCut") or not tree:IsDescendantOf(workspace) then
                treeHits[tree] = nil
            else
                treeHits[tree] = (treeHits[tree] or 0) + fired
                if treeHits[tree] >= 300 then
                    chopBlacklist[tree] = tick() + 60
                    treeHits[tree] = nil
                end
            end
        end)
    end
end)

PlayerGroup:AddSlider("WalkSpeedSlider", {
    Text = "步行速度",
    Default = 16,
    Min = 16,
    Max = 300,
    Rounding = 0,
    Callback = function(Value)
        pcall(function()
            player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Value
        end)
    end,
})

PlayerGroup:AddSlider("JumpPowerSlider", {
    Text = "跳跃力",
    Default = 50,
    Min = 50,
    Max = 300,
    Rounding = 0,
    Callback = function(Value)
        pcall(function()
            player.Character:FindFirstChildOfClass("Humanoid").JumpPower = Value
        end)
    end,
})

local infJump = false
local infJumpConn = nil
PlayerGroup:AddToggle("InfJump", {
    Text = "无限跳",
    Default = false,
    Callback = function(Value)
        infJump = Value
        if Value and not infJumpConn then
            infJumpConn = UserInputService.JumpRequest:Connect(function()
                if infJump then
                    pcall(function()
                        player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
                    end)
                end
            end)
        end
    end,
})

local noclip = false
PlayerGroup:AddToggle("Noclip", {
    Text = "穿墙",
    Default = false,
    Callback = function(Value)
        noclip = Value
    end,
})

task.spawn(function()
    while true do
        task.wait(0.1)
        if noclip then
            pcall(function()
                for _, p in ipairs(player.Character:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.CanCollide = false
                    end
                end
            end)
        end
    end
end)

local flying = false
local flySpeed = 4
local flyConn = nil

local function stopFly()
    if flyConn then
        flyConn:Disconnect()
        flyConn = nil
    end
    local char = player.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local bv = root:FindFirstChild("FlyVelocity")
            if bv then
                bv:Destroy()
            end
            local bg = root:FindFirstChild("FlyGyro")
            if bg then
                bg:Destroy()
            end
        end
    end
end

local function startFly()
    stopFly()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then
        return
    end
    local bv = Instance.new("BodyVelocity")
    bv.Name = "FlyVelocity"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = root
    local bg = Instance.new("BodyGyro")
    bg.Name = "FlyGyro"
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 10000
    bg.CFrame = root.CFrame
    bg.Parent = root
    flyConn = RunService.Heartbeat:Connect(function()
        if not flying then
            return
        end
        pcall(function()
            local cam = workspace.CurrentCamera
            local dir = hum.MoveDirection
            if dir.Magnitude > 0 then
                bv.Velocity = dir.Unit * (flySpeed * 16)
            else
                bv.Velocity = Vector3.new(0, 0, 0)
            end
            bg.CFrame = CFrame.new(root.Position, root.Position + cam.CFrame.LookVector)
        end)
    end)
end

PlayerGroup:AddToggle("Fly", {
    Text = "飞行",
    Default = false,
    Callback = function(Value)
        flying = Value
        if Value then
            startFly()
        else
            stopFly()
        end
    end,
})

PlayerGroup:AddSlider("FlySpeedSlider", {
    Text = "飞行速度",
    Default = 4,
    Min = 1,
    Max = 30,
    Rounding = 0,
    Callback = function(Value)
        flySpeed = Value
    end,
})

player.CharacterAdded:Connect(function()
    task.wait(1)
    if flying then
        startFly()
    end
end)

local dayOn = false
local nightOn = false
local noFog = false

EnvGroup:AddToggle("DayT", {
    Text = "白天",
    Default = false,
    Callback = function(Value)
        dayOn = Value
        if Value and nightOn then
            Toggles.NightT:SetValue(false)
        end
    end,
})

EnvGroup:AddToggle("NightT", {
    Text = "黑夜",
    Default = false,
    Callback = function(Value)
        nightOn = Value
        if Value and dayOn then
            Toggles.DayT:SetValue(false)
        end
    end,
})

EnvGroup:AddToggle("NoFog", {
    Text = "删除雾",
    Default = false,
    Callback = function(Value)
        noFog = Value
    end,
})

task.spawn(function()
    while true do
        task.wait(0.2)
        pcall(function()
            if dayOn then
                Lighting.ClockTime = 14
            end
            if nightOn then
                Lighting.ClockTime = 0
            end
            if noFog then
                Lighting.FogStart = 100000
                Lighting.FogEnd = 100000
            end
        end)
    end
end)


local bai = {
    autodropae = false,
    soltnumber = "1",
    waterwalk = false,
    awaysday = false,
    awaysdnight = false,
    nofog = false,
    axeflying = false,
    playernamedied = "",
    tptree = "",
    moneyaoumt = 1,
    moneytoplayername = "",
    donationRecipient = tostring(player),
    autodropae = false,
    farAxeEquip = nil,
    cuttreeselect = "Generic",
    autofarm = false,
    PlankToBlueprint = nil,
    plankModel = nil,
    blueprintModel = nil,
    saymege = "",
    autosay = false,
    saymount = 1,
    sayfast = false,
    autofarm1 = false,
    bringamount = 1,
    bringtree = false,
    dxmz = "",
    color = 0,
    zlwjia = "",
    mtwjia = nil,
    zix = 1,
    zlz = 3,
    axeFling = nil,
    itemtoopen = "",
    openItem = nil,
    car = nil,
    load = false,
    autobuyamount = 1,
    autopick = false,
    loaddupeaxewaittime = 3.1,
    walkspeed = 16,
    JumpPower = 50,
    pickupaxeamount = 1,
    whthmose = false,
    itemset = nil,
    LoneCaveAxeDetection = nil,
    cuttree = false,
    LoneCaveCharacterAddedDetection = nil,
    LoneCaveDeathDetection = nil,
    lovecavecutcframe = nil,
    lovecavepast = nil,
    zlmt = nil,
    shuzhe = false,
    modwood = false,
    tchonmt = nil,
    cskais = false,
    dledetree = false,
    delereeset = nil,
    treecutset = nil,
    autobuyset = nil,
    wood = 7,
    cswjia = nil,
    boxOpenConnection = nil,
    autobuystop = false,
    dropdown = {},
    autocsdx = nil,
    kuangxiu = nil,
    xzemuban = false,
    daiwp = false,
    stopcar = false,
}

local function droptool(Position)
    local aQ = player.Character
    if aQ:FindFirstChildOfClass "Tool" then
        local y = aQ:FindFirstChildOfClass "Tool"
        if y:FindFirstChild("ToolName") then
            ReplicatedStorage.Interaction.ClientInteracted:FireServer(y, "Drop tool", Position or player.Character.Head.CFrame)
        end
    end
    for a, b in pairs(player.Backpack:GetChildren()) do
        if b.Name == "Tool" and b.ClassName == "Tool" then
            ReplicatedStorage.Interaction.ClientInteracted:FireServer(b, "Drop tool", Position or player.Character.Head.CFrame)
        end
    end
end

local function gplr(String)
    local Found = {}
    local strl = String:lower()
    if strl == "all" then
        for i, v in pairs(Players:GetPlayers()) do
            table.insert(Found, v)
        end
    elseif strl == "others" then
        for i, v in pairs(Players:GetPlayers()) do
            if v.Name ~= lp.Name then
                table.insert(Found, v)
            end
        end
    elseif strl == "me" then
        for i, v in pairs(Players:GetPlayers()) do
            if v.Name == lp.Name then
                table.insert(Found, v)
            end
        end
    else
        for i, v in pairs(Players:GetPlayers()) do
            if v.Name:lower():sub(1, #String) == String:lower() then
                table.insert(Found, v)
            end
        end
    end
    return Found
end

function tools(plr)
    if plr:FindFirstChildOfClass("Backpack"):FindFirstChildOfClass('Tool') or plr.Character:FindFirstChildOfClass('Tool') then
        return true
    end
end

local function DragModel(...)
    local d = {...}
    pcall(function()
        ReplicatedStorage.Interaction.ClientIsDragging:FireServer(d[1])
    end)
    d[1]:PivotTo(d[2])
    return d
end

local function DragModelmain(...)
    local d = {...}
    pcall(function()
        ReplicatedStorage.Interaction.ClientIsDragging:FireServer(d[1])
    end)
    d[1].Main.CFrame = d[2]
    return d
end

local function DragModel2(...)
    local d = {...}
    pcall(function()
        ReplicatedStorage.Interaction.ClientIsDragging:FireServer(d[1])
        ReplicatedStorage.Interaction.ClientIsDragging:FireServer(d[1])
        ReplicatedStorage.Interaction.ClientIsDragging:FireServer(d[1])
        ReplicatedStorage.Interaction.ClientIsDragging:FireServer(d[1])
    end)
    d[1]:SetPrimaryPartCFrame(d[2])
    return d
end

local function DragModel1(...)
    local d = {...}
    pcall(function()
        ReplicatedStorage.Interaction.ClientIsDragging:FireServer(d[1])
        ReplicatedStorage.Interaction.ClientIsDragging:FireServer(d[1])
    end)
    d[1]:MoveTo(d[2])
    d[1]:MoveTo(d[2])
    return d
end

repeat wait(.1) until lp.Character
local Character0 = lp.Character
Character0.Archivable = true
local IsInvis = false
local IsRunning = true
local InvisibleCharacter = Character0:Clone()
InvisibleCharacter.Parent = game:GetService'Lighting'
local Void = workspace.FallenPartsDestroyHeight
InvisibleCharacter.Name = ""
local CF

lp.CharacterAdded:Connect(function()
    if lp.Character == InvisibleCharacter then return end
    repeat wait(.1) until lp.Character:FindFirstChildWhichIsA'Humanoid'
    if IsRunning == false then
        IsInvis = false
        IsRunning = true
        Character0 = lp.Character
        Character0.Archivable = true
        InvisibleCharacter = Character0:Clone()
        InvisibleCharacter.Name = ""
        InvisibleCharacter:FindFirstChildOfClass'Humanoid'.Died:Connect(function()
            Respawn()
        end)
        for i,v in pairs(InvisibleCharacter:GetDescendants())do
            if v:IsA("BasePart") then
                if v.Name == "HumanoidRootPart" then
                    v.Transparency = 1
                else
                    v.Transparency = .5
                end
            end
        end
    end
end)

local Fix = RunService.Stepped:Connect(function()
    pcall(function()
        local IsInteger
        if tostring(Void):find'-' then
            IsInteger = true
        else
            IsInteger = false
        end
        local Pos = lp.Character.HumanoidRootPart.Position
        local Pos_String = tostring(Pos)
        local Pos_Seperate = Pos_String:split(', ')
        local X = tonumber(Pos_Seperate[1])
        local Y = tonumber(Pos_Seperate[2])
        local Z = tonumber(Pos_Seperate[3])
        if IsInteger == true then
            if Y <= Void then
                Respawn()
            end
        elseif IsInteger == false then
            if Y >= Void then
                Respawn()
            end
        end
    end)
end)

for i,v in pairs(InvisibleCharacter:GetDescendants())do
    if v:IsA("BasePart") then
        if v.Name == "HumanoidRootPart" then
            v.Transparency = 1
        else
            v.Transparency = .5
        end
    end
end

function Respawn()
    IsRunning = false
    if IsInvis == true then
        pcall(function()
            lp.Character = Character0
            wait()
            Character0.Parent = workspace
            Character0:FindFirstChildWhichIsA'Humanoid':Destroy()
            IsInvis = false
            InvisibleCharacter.Parent = nil
        end)
    elseif IsInvis == false then
        pcall(function()
            lp.Character = Character0
            wait()
            Character0.Parent = workspace
            Character0:FindFirstChildWhichIsA'Humanoid':Destroy()
            IsInvis = false
        end)
    end
end

InvisibleCharacter:FindFirstChildOfClass'Humanoid'.Died:Connect(function()
    Respawn()
end)

function FixCam()
    workspace.CurrentCamera.CameraSubject = lp.Character:FindFirstChildWhichIsA'Humanoid'
    workspace.CurrentCamera.CFrame = CF
end

function freezecam(arg)
    if arg == true then
        workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
    else
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end
end

function TurnInvisible()
    if IsInvis == true then return end
    IsInvis = true
    CF = workspace.CurrentCamera.CFrame
    local CF_1 = lp.Character.HumanoidRootPart.CFrame
    lp.Character.HumanoidRootPart.CFrame=CFrame.new(9e9, 9e9, 9e9)
    freezecam(true)
    wait(.6)
    freezecam(false)
    InvisibleCharacter = InvisibleCharacter
    Character0.Parent = game:GetService'Lighting'
    InvisibleCharacter.Parent = workspace
    InvisibleCharacter.HumanoidRootPart.CFrame = CF_1
    lp.Character = InvisibleCharacter
    FixCam()
    lp.Character.Animate.Disabled = true
    lp.Character.Animate.Disabled = false
end

function TurnVisible()
    if IsInvis == false then return end
    CF = workspace.CurrentCamera.CFrame
    Character0 = Character0
    local CF_1 = lp.Character.HumanoidRootPart.CFrame
    Character0.HumanoidRootPart.CFrame = CF_1
    InvisibleCharacter.Parent = game:GetService'Lighting'
    lp.Character = Character0
    Character0.Parent = workspace
    IsInvis = false
    FixCam()
    lp.Character.Animate.Disabled = true
    lp.Character.Animate.Disabled = false
end

function getTieredAxe()
    return {
        ['Beesaxe'] = 13,
        ['AxeAmber'] = 12,
        ['ManyAxe'] = 15,
        ['BasicHatchet'] = 0,
        ['RustyAxe'] = -1,
        ['Axe1'] = 2,
        ['Axe2'] = 3,
        ['AxeAlphaTesters'] = 9,
        ['Rukiryaxe'] = 8,
        ['Axe3'] = 4,
        ['AxeBetaTesters'] = 10,
        ['FireAxe'] = 11,
        ['SilverAxe'] = 5,
        ['EndTimesAxe'] = 16,
        ['AxeChicken'] = 6,
        ['CandyCaneAxe'] = 1,
        ['AxeTwitter'] = 7,
        ['CandyCornAxe'] = 14
    }
end

function getAxeList()
    local aP = {}
    for J, v in pairs(player.Backpack:GetChildren()) do
        table.insert(aP, v)
    end
    local aQ = player.Character
    if aQ:FindFirstChildOfClass "Tool" then
        table.insert(aP, aQ:FindFirstChildOfClass("Tool"))
    end
    return aP
end

function getWorstAxe()
    local aQ = player.Character
    if aQ:FindFirstChildOfClass "Tool" then
        local y = aQ:FindFirstChildOfClass "Tool"
        if y:FindFirstChild("ToolName") then
            return y
        end
    end
    local aR = 9999
    local aS = nil
    local aT = getTieredAxe()
    for J, v in pairs(getAxeList()) do
        if v:FindFirstChild("ToolName") then
            if aT[v.ToolName.Value] < aR then
                aS = v
                aR = aT[v.ToolName.Value]
            end
        end
    end
    return aS
end

local function barkgetBestAxe()
    local aQ = player.Character
    if aQ:FindFirstChildOfClass "Tool" then
        local y = aQ:FindFirstChildOfClass "Tool"
        if y:FindFirstChild("ToolName") then
            return y
        end
    end
    local aU = -1
    local aV = nil
    local aT = getTieredAxe()
    for J, v in pairs(getAxeList()) do
        if v:FindFirstChild("ToolName") then
            if aT[v.ToolName.Value] > aU then
                aV = v
                aU = aT[v.ToolName.Value]
            end
        end
    end
    return aV
end

function getHitPointsTbl()
    return {
        ['Beesaxe'] = 1.4,
        ['AxeAmber'] = 3.39,
        ['ManyAxe'] = 10.2,
        ['BasicHatchet'] = 0.2,
        ['Axe1'] = 0.55,
        ['Axe2'] = 0.93,
        ['AxeAlphaTesters'] = 1.5,
        ['Rukiryaxe'] = 1.68,
        ['Axe3'] = 1.45,
        ['AxeBetaTesters'] = 1.45,
        ['FireAxe'] = 0.6,
        ['SilverAxe'] = 1.6,
        ['EndTimesAxe'] = 1.58,
        ['AxeChicken'] = 0.9,
        ['CandyCaneAxe'] = 0,
        ['AxeTwitter'] = 1.65,
        ['CandyCornAxe'] = 1.75,
        ["CaveAxe"] = 0.4
    }
end

local function getMouseTarget()
    local b2 = UserInputService:GetMouseLocation()
    return workspace:FindPartOnRayWithIgnoreList(Ray.new(workspace.CurrentCamera.CFrame.p, workspace.CurrentCamera:ViewportPointToRay(b2.x, b2.y, 0).Direction * 1000), player.Character:GetDescendants())
end

local function table_foreach(table, callback)
    for i = 1, #table do
        callback(i, table[i])
    end
end

local function getCFrame(part)
    local part = part or (lp.Character and lp.Character.HumanoidRootPart)
    if not part then
        return
    end
    return part.CFrame
end

local function tp(pos)
    local pos = pos or lp:GetMouse().Hit + Vector3.new(0, lp.Character.HumanoidRootPart.Size.Y, 0)
    if typeof(pos) == "CFrame" then
        lp.Character:SetPrimaryPartCFrame(pos)
    elseif typeof(pos) == "Vector3" then
        lp.Character:MoveTo(pos)
    end
end

require = getgenv().require

function get_axe_damage(tool, tree)
    local axe_class = require(game.ReplicatedStorage.AxeClasses['AxeClass_' .. tool.ToolName.Value])
    local axe_table = axe_class.new()
    if axe_table["SpecialTrees"] then
        if axe_table["SpecialTrees"][tree] then
            return axe_table["SpecialTrees"][tree].Damage
        else
            return axe_table.Damage
        end
    else
        return axe_table.Damage
    end
end

function get_axe_cooldown(tool)
    local success, return_value = pcall(function()
        local axe_class = require(game.ReplicatedStorage.AxeClasses['AxeClass_' .. tool.ToolName.Value])
        local axe_table = axe_class.new()
        return axe_table.SwingCooldown
    end)
    if success then
        return return_value
    else
        return 1
    end
end

function get_axe_swingdelay(tool)
    local axe_cooldown = get_axe_cooldown(tool)
    local start = tick()
    game.ReplicatedStorage.TestPing:InvokeServer()
    local ping = (tick() - start) / 2
    local swing_delay = 0.65 * axe_cooldown - ping
    return swing_delay
end

function getBestSawmill()
    local best = nil
    for i, v in pairs(game.Workspace.PlayerModels:GetChildren()) do
        if v:FindFirstChild("Owner") and v:FindFirstChild("ItemName") and v.Owner.Value == player and v.ItemName.Value:sub(1, 7) == "Sawmill" then
            if not best then
                best = v
            else
                if #v.ItemName.Value > #best.ItemName.Value then
                    best = v
                elseif tonumber(v.ItemName.Value:sub(8, 8)) > tonumber(best.ItemName.Value:sub(8, 8)) then
                    best = v
                end
            end
        end
    end
    return best
end

function barkgetBestAxe2()
    local pc = player.Character
    local axe_damage
    local best_axe
    for i, v in pairs(getAxeList()) do
        if v.name == "Tool" then
            local damage = get_axe_damage(v, "Generic")
            if best_axe == nil then
                best_axe = v
                axe_damage = damage
            elseif get_axe_damage(best_axe, "Generic") < damage then
                best_axe = v
                axe_damage = damage
            end
        end
    end
    return best_axe
end

local function getPosition(part)
    return getCFrame(part).Position
end

local function getTools()
    lp.Character.Humanoid:UnequipTools()
    local tools = {}
    table_foreach(lp.Backpack:GetChildren(), function(_, v)
        if v.Name ~= "BlueprintTool" then
            tools[#tools + 1] = v
        end
    end)
    return tools
end

local function getToolStats(toolName)
    if typeof(toolName) ~= "string" then
        toolName = toolName.ToolName.Value
    end
    return require(game:GetService("ReplicatedStorage").AxeClasses['AxeClass_' .. toolName]).new()
end

local getTool = function()
    return lp.Character:FindFirstChild("Tool") or lp.Backpack:FindFirstChild("Tool")
end

local function getBestAxe(treeClass)
    local tools = getTools()
    if #tools == 0 then
        return Library:Notify({Title = "白", Description = "你需要斧头", Time = 4})
    end
    local toolStats = {}
    local tool
    for _, v in next, tools do
        if treeClass == "LoneCave" and v.ToolName.Value == "EndTimesAxe" then
            tool = v
            break
        end
        local axeStats = getToolStats(v)
        if axeStats.SpecialTrees and axeStats.SpecialTrees[treeClass] then
            for i, v in next, axeStats.SpecialTrees[treeClass] do
                axeStats[i] = v
            end
        end
        table.insert(toolStats, {
            tool = v,
            damage = axeStats.Damage
        })
    end
    if not tool and treeClass == "LoneCave" then
        return Library:Notify({Title = "白", Description = "你需要末日斧头", Time = 4})
    end
    table.sort(toolStats, function(a, b)
        return a.damage > b.damage
    end)
    return true, tool or toolStats[1].tool
end

local function cutPart(event, section, height, tool, treeClass)
    local axeStats = getToolStats(tool)
    if axeStats.SpecialTrees and axeStats.SpecialTrees[treeClass] then
        for i, v in next, axeStats.SpecialTrees[treeClass] do
            axeStats[i] = v
        end
    end
    game:GetService('ReplicatedStorage').Interaction.RemoteProxy:FireServer(event, {
        tool = tool,
        faceVector = Vector3.new(-1, 0, 0),
        height = height or 0.3,
        sectionId = section or 1,
        hitPoints = axeStats.Damage,
        cooldown = axeStats.SwingCooldown,
        cuttingClass = "Axe"
    })
end

local treeListener = function(treeClass, callback)
    local childAdded
    childAdded = workspace.LogModels.ChildAdded:Connect(function(child)
        local owner = child:WaitForChild("Owner")
        if owner.Value == lp and child.TreeClass.Value == treeClass then
            childAdded:Disconnect()
            callback(child)
        end
    end)
end

local getBiggestTree = function(treeClass)
    for _, v in next, workspace:children() do
        if tostring(v) == "TreeRegion" then
            for _, g in next, v:children() do
                if g:FindFirstChild("TreeClass") and tostring(g.TreeClass.Value) == treeClass and g:FindFirstChild("Owner") then
                    if g.Owner.Value == nil or tostring(g.Owner.Value) == tostring(player) then
                        if #g:children() > 5 and g:FindFirstChild("WoodSection") then
                            for h, j in next, g:children() do
                                if j:FindFirstChild("ID") and j.ID.Value == 1 and j.Size.Y > .5 then
                                    return j
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end

local function bringTree(treeClass)
    local success, data = getBestAxe(treeClass)
    local axeStats = getToolStats(data)
    local treeCut = false
    treeListener(treeClass, function(tree)
        tree:WaitForChild('Owner', 60)
        tree.PrimaryPart = tree:FindFirstChild("WoodSection")
        treeCut = true
        task.spawn(function()
            for i = 1, 60 do
                game:GetService("ReplicatedStorage").Interaction.ClientIsDragging:FireServer(tree)
                game["Run Service"].Heartbeat:wait()
            end
        end)
        task.wait(0.1)
        tree.PrimaryPart = tree.WoodSection
        spawn(function()
            for i = 1, 60 do
                tree.PrimaryPart.Velocity = Vector3.new(0, 0, 0)
                tree:PivotTo(bai.treecutset)
                game["Run Service"].Heartbeat:wait()
            end
        end)
        wait(0.5)
        if treeClass == "LoneCave" then
            lp.Character.Head:Destroy()
            lp.CharacterAdded:Wait()
            wait(2)
        end
        tp(bai.treecutset)
    end)
    if treeClass == "LoneCave" then
        local GM = player.Character.HumanoidRootPart.RootJoint
        GM:Clone().Parent = player.Character.HumanoidRootPart
        GM:Destroy()
    end
    local tree = getBiggestTree(treeClass)
    if not tree then
        return Library:Notify({Title = "白", Description = "没有找到树", Time = 3})
    end
    spawn(function()
        repeat
            tp(tree.CFrame + Vector3.new(3, 3, 0))
            cutPart(tree.Parent.CutEvent, 1, 0.3, data, treeClass)
            game["Run Service"].Heartbeat:wait()
        until treeCut
    end)
end

local function autofarm(treeClass)
    local oldpos = lp.Character.HumanoidRootPart.CFrame
    local success, data = getBestAxe(treeClass)
    local axeStats = getToolStats(data)
    local tree = getBiggestTree(treeClass)
    if not tree then
        return Library:Notify({Title = "白", Description = "没有找到树", Time = 3})
    end
    local treeCut = false
    treeListener(treeClass, function(tree)
        tree.PrimaryPart = tree:FindFirstChild("WoodSection")
        treeCut = true
        for i = 1, 70 do
            game:GetService('ReplicatedStorage').Interaction.ClientIsDragging:FireServer(tree.WoodSection)
            tree:MoveTo(oldPosition)
            task.wait()
        end
    end)
    task.wait(0.15)
    task.spawn(function()
        repeat
            tp(tree.trunk.CFrame * CFrame.new(4, 3, 4))
            task.wait()
        until treeCut
    end)
    task.wait()
    repeat
        cutPart(tree.tree.CutEvent, 1, 0.3, data, treeClass)
        task.wait(axeStats.SwingCooldown - 14)
    until treeCut
    if bai.autofarm1 == false then
        Library:Notify({Title = "白", Description = "完成", Time = 3})
    end
    tp(oldPosition)
end

local function lowerBridge(value)
    if value == 'Higher' then
        for _, v in pairs(game.workspace.Bridge.VerticalLiftBridge.Lift:GetChildren()) do
            v.CFrame = v.CFrame + Vector3.new(0, 26, 0)
        end
    elseif value == 'Lower' then
        for _, v in pairs(game.workspace.Bridge.VerticalLiftBridge.Lift:GetChildren()) do
            v.CFrame = v.CFrame + Vector3.new(0, -26, 0)
        end
    end
end

local function OpenSelectedItem(item)
    local itemBox = item:FindFirstChild('BoxItemName') or item:FindFirstChild('PurchasedBoxItemName')
    if itemBox and item:FindFirstChild('Type') and item.Type.Value ~= 'Structure' then
        game:GetService('ReplicatedStorage').Interaction.ClientInteracted:FireServer(item, 'Open box')
        Library:Notify({Title = '白', Description = '成功打开', Time = 4})
    end
end

local function applyLight(value)
    if value then
        local light = Instance.new('PointLight', lp.Character.Head)
        light.Name = 'bai'
        light.Range = 150
        light.Brightness = 1.7
    else
        pcall(function()
            lp.Character.Head.bai:remove()
        end)
    end
end

local function carTeleport(cframe)
    if player.Character then
        local Character = player.Character
        if Character.Humanoid.SeatPart ~= nil then
            local Car = Character.Humanoid.SeatPart.Parent
            spawn(function()
                for i = 1, 5 do
                    wait()
                    Car:SetPrimaryPartCFrame(cframe * CFrame.Angles(math.rad(Character.HumanoidRootPart.Orientation.x), math.rad(Character.HumanoidRootPart.Orientation.y), 0))
                    game.ReplicatedStorage.Interaction.ClientRequestOwnership:FireServer(Car.Main)
                    game.ReplicatedStorage.Interaction.ClientIsDragging:FireServer(Car.Main)
                end
            end)
        end
    end
end

local function CheckIfSlotAvailable(Slot)
    for a, b in pairs(game.ReplicatedStorage.LoadSaveRequests.GetMetaData:InvokeServer(player)) do
        if a == Slot then
            for c, d in pairs(b) do
                if c == "NumSaves" and d ~= 0 then
                    return true
                else
                    return false
                end
            end
        end
    end
end

local function CheckSlotNumber()
    if bai.soltnumber == "1" or bai.soltnumber == "2" or bai.soltnumber == "3" or bai.soltnumber == "4" or bai.soltnumber == "5" or bai.soltnumber == "6" then
        local SlotNumber = tonumber(bai.soltnumber)
        return SlotNumber
    else
        return false
    end
end

local function getPlanks()
    local plankList = {}
    for _, plank in next, game:GetService('Workspace').PlayerModels:children() do
        if plank:FindFirstChild('WoodSection') and plank:FindFirstChild('Owner') and plank.Owner.Value == player and not table.find(plankList, plank) then
            table.insert(plankList, plank)
        end
    end
    return plankList
end

local function sellwood()
    local oldpos = lp.Character.HumanoidRootPart.CFrame
    for i, v in next, game:GetService("Workspace").LogModels:GetChildren() do
        if v:FindFirstChild("Owner") and v.Owner.Value == player then
            tp(v.WoodSection.CFrame)
            spawn(function()
                for i2, v2 in next, v:GetChildren() do
                    if v2.Name == "WoodSection" then
                        local FreezeWood = Instance.new("BodyVelocity", v2)
                        FreezeWood.Velocity = Vector3.new(0, 0, 0)
                        FreezeWood.P = 100000
                        spawn(function()
                            for i = 1, 50 do
                                game.ReplicatedStorage.Interaction.ClientIsDragging:FireServer(v)
                                v:PivotTo(CFrame.new(314.54, -0.5, 86.823))
                                v2.CFrame = CFrame.new(314.54, -0.5, 86.823)
                                game.ReplicatedStorage.Interaction.ClientIsDragging:FireServer(v)
                                game:GetService('RunService').Heartbeat:wait()
                            end
                        end)
                        task.wait(1)
                    end
                end
            end)
            task.wait(2)
        end
    end
    tp(oldpos)
end

local function PlankToBlueprint()
    local target
    Library:Notify({Title = '白', Description = '选择一个木头和蓝图', Time = 2})
    bai.PlankToBlueprint = player:GetMouse().Button1Down:Connect(function()
        if player:GetMouse().Target then
            target = player:GetMouse().Target
        end
        if target.Parent:FindFirstChild('Type') and target.Parent.Type.Value == 'Blueprint' then
            bai.blueprintModel = player:GetMouse().Parent
            Library:Notify({Title = '白', Description = '蓝图已选择', Time = 2})
        end
        if tostring(target.Parent) == 'Plank' and target.Parent:FindFirstChild('Owner') and tostring(target.Parent.Owner.Value) == tostring(lp) then
            bai.plankModel = target.Parent
            Library:Notify({Title = '白', Description = '木头已选择', Time = 2})
        end
    end)
    repeat
        wait()
    until bai.plankModel and bai.blueprintModel
    bai.PlankToBlueprint:Disconnect()
    bai.PlankToBlueprint = nil
    tp(CFrame.new(bai.plankModel:FindFirstChildOfClass('Part').CFrame.p + Vector3.new(0, 3, 4)))
    wait(.2)
    for i = 1, 30 do
        pcall(function()
            game:GetService('ReplicatedStorage').Interaction.ClientIsDragging:FireServer(bai.plankModel)
            bai.plankModel.WoodSection.CFrame = CFrame.new(bai.blueprintModel.Main.CFrame.p + Vector3.new(0, 1.5, 0))
            game:GetService('RunService').Stepped:wait()
        end)
    end
    Library:Notify({Title = '白', Description = '完成', Time = 2})
    bai.blueprintModel = nil
    bai.plankModel = nil
end

local function burnAllShopItems()
    local found = false
    for _, PressurePlate in pairs(game.Workspace.PlayerModels:children()) do
        if PressurePlate:FindFirstChild 'ItemName' and PressurePlate.ItemName.Value == 'PressurePlate' then
            if PressurePlate.Output.BrickColor ~= BrickColor.new 'Electric blue' then
                repeat
                    wait()
                    lp.Character.HumanoidRootPart.CFrame = CFrame.new(PressurePlate.Plate.CFrame.p + Vector3.new(0, .3, 0))
                until PressurePlate.Output.BrickColor == BrickColor.new 'Electric blue' or not PressurePlate
                found = true
            end
        end
    end
    if not found then
        Library:Notify({Title = '白', Description = '没有找到压力板', Time = 4})
        return
    end
end

function axefily()
    bai.axeFling = mouse.Button1Down:Connect(function()
        local axe = nil
        local axeConnection = workspace.PlayerModels.ChildAdded:connect(function(v)
            v:WaitForChild('Owner', 60)
            if v.Owner.Value == lp then
                axe = v
                wait(2)
                game.ReplicatedStorage.Interaction.ClientInteracted:FireServer(axe, 'Pick up tool')
            end
        end)
        local oldpos = lp.Character.HumanoidRootPart.CFrame
        droptool(oldpos)
        repeat
            task.wait(0.1)
        until axe ~= nil
        axeConnection:Disconnect()
        axeConnection = nil
        local fling = Instance.new('BodyPosition', axe.Main)
        fling.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        fling.P = 650000
        fling.Position = lp:GetMouse().Hit.p
        spawn(function()
            while bai.whthmose == true do
                task.wait(0.1)
                fling.Position = lp:GetMouse().Hit.p
            end
        end)
        local flingPower = 9e9
        axe.Main.CanCollide = false
        repeat
            task.wait()
            axe.Main.RotVelocity = Vector3.new(5, 5, 5) * flingPower
        until (axe.Main.CFrame.p - fling.Position).Magnitude < 1
        wait(7)
        fling:Destroy()
        axe.Main.CanCollide = true
    end)
end

local function Press(Button)
    game.ReplicatedStorage.Interaction.RemoteProxy:FireServer(Button)
end

function CanClientLoad()
    if not game:GetService("ReplicatedStorage").LoadSaveRequests.ClientMayLoad:InvokeServer(lp) then
        Library:Notify({Title = "白", Description = "等待加载时间,请耐心的等待", Time = 4})
        repeat
            game:GetService("RunService").Stepped:wait()
        until game:GetService("ReplicatedStorage").LoadSaveRequests.ClientMayLoad:InvokeServer(lp)
    end
    return true
end

function GetLoadedSlot()
    return lp.CurrentSaveSlot.Value
end

function LoadSlot(slot)
    local CheckLoad
    spawn(function()
        CheckLoad = game:GetService('ReplicatedStorage').LoadSaveRequests.ClientMayLoad:InvokeServer(lp)
        if not CheckLoad then
            repeat
                wait()
            until CheckLoad
        end
        game:GetService('ReplicatedStorage').LoadSaveRequests.RequestLoad:InvokeServer(slot, lp)
        return slot
    end)
end

local Teleport = function(...)
    local d = {...}
    for e = 1, 3 do
        task.wait()
        lp.Character.HumanoidRootPart.CFrame = d[1]
    end
    return d
end

local GetShopID = {
    ["WoodRus"] = {["Character"] = workspace.Stores.WoodRUs.Thom, ["Name"] = "Thom", ["ID"] = tonumber(7)},
    ["FurnitureStore"] = {["Character"] = workspace.Stores.FurnitureStore.Corey, ["Name"] = "Corey", ["ID"] = tonumber(8)},
    ["CarStore"] = {["Character"] = workspace.Stores.CarStore.Jenny, ["Name"] = "Jenny", ["ID"] = tonumber(9)},
    ["ShackShop"] = {["Character"] = workspace.Stores.ShackShop.Bob, ["Name"] = "Bob", ["ID"] = tonumber(10)},
    ["FineArt"] = {["Character"] = workspace.Stores.FineArt.Timothy, ["Name"] = "Timothy", ["ID"] = tonumber(11)},
    ["LogicStore"] = {["Character"] = workspace.Stores.LogicStore.Lincoln, ["Name"] = "Lincoln", ["ID"] = tonumber(12)},
}

local BuyItem = function(m)
    return game.ReplicatedStorage.NPCDialog.PlayerChatted:InvokeServer(m, "ConfirmPurchase")
end

function finditem(o)
    for e, h in next, workspace.Stores:children() do
        if h.Name == "ShopItems" and h:FindFirstChild "Box" then
            for i, j in next, h:children() do
                if j.BoxItemName.Value == o then
                    for i, w in next, h:children() do
                        local ID, Cashier, Counter
                        if w.BoxItemName.Value == "Bed1" or w.BoxItemName.Value == "Seat_Couch" then
                            ID = GetShopID.FurnitureStore
                            Cashier = workspace.Stores.FurnitureStore.Corey.HumanoidRootPart.CFrame
                            Counter = workspace.Stores.FurnitureStore.Counter.CFrame + Vector3.new(0, .4, 0)
                        elseif w.BoxItemName.Value == "Sawmill" or w.BoxItemName.Value == "Sawmill2" then
                            ID = GetShopID.WoodRus
                            Cashier = workspace.Stores.WoodRUs.Thom.HumanoidRootPart.CFrame
                            Counter = workspace.Stores.WoodRUs.Counter.CFrame + Vector3.new(0, .4, 0)
                        elseif w.BoxItemName.Value == "Trailer2" or w.BoxItemName.Value == "UtilityTruck2" then
                            ID = GetShopID.CarStore
                            Cashier = workspace.Stores.CarStore.Jenny.HumanoidRootPart.CFrame
                            Counter = workspace.Stores.CarStore.Counter.CFrame + Vector3.new(0, .4, 0)
                        elseif w.BoxItemName.Value == "CanOfWorms" or w.BoxItemName.Value == "Dynamite" then
                            ID = GetShopID.ShackShop
                            Cashier = workspace.Stores.ShackShop.Bob.HumanoidRootPart.CFrame
                            Counter = workspace.Stores.ShackShop.Counter.CFrame + Vector3.new(0, .4, 0)
                        elseif w.BoxItemName.Value == "Painting1" or w.BoxItemName.Value == "Painting2" then
                            ID = GetShopID.FineArt
                            Cashier = workspace.Stores.FineArt.Timothy.HumanoidRootPart.CFrame
                            Counter = workspace.Stores.FineArt.Counter.CFrame + Vector3.new(0, .4, 0)
                        elseif w.BoxItemName.Value == "GateXOR" or w.BoxItemName.Value == "NeonWireOrange" then
                            ID = GetShopID.LogicStore
                            Cashier = workspace.Stores.LogicStore.Lincoln.HumanoidRootPart.CFrame
                            Counter = workspace.Stores.LogicStore.Counter.CFrame + Vector3.new(0, .4, 0)
                        end
                        return {j, Cashier, ID, Counter}
                    end
                end
            end
        end
    end
end

function autobuyv2(o)
    local item = nil
    local ltem = nil
    item = finditem(o)
    if item == nil then
        Library:Notify({Title = "白", Description = "没有找到商品或者没有刷新，请你等待", Time = 4})
        repeat
            task.wait()
            item = finditem(o)
        until item ~= nil
    end
    ltem = item[1]
    Teleport(ltem.Main.CFrame)
    task.wait()
    game:GetService('RunService').Stepped:wait()
    for e = 1, 15 do
        game:GetService("ReplicatedStorage").Interaction.ClientIsDragging:FireServer(ltem)
        ltem:PivotTo(item[4])
        game:GetService("ReplicatedStorage").Interaction.ClientIsDragging:FireServer(ltem)
        game:GetService('RunService').Stepped:wait()
    end
    Teleport(item[4] + Vector3.new(5, 0, 5))
    repeat
        BuyItem(item[3])
        game:GetService('RunService').Stepped:wait()
    until tostring(ltem.Parent) ~= "ShopItems"
    return o
end

function autobuy(o, r)
    bai.autocsdx = game.Workspace.PlayerModels.ChildAdded:connect(function(v)
        v:WaitForChild('Owner', 60)
        if v.Owner.Value == lp then
            for i = 1, 20 do
                game:GetService("ReplicatedStorage").Interaction.ClientIsDragging:FireServer(v)
                v:PivotTo(bai.autobuyset)
                game:GetService("ReplicatedStorage").Interaction.ClientIsDragging:FireServer(v)
                game:GetService('RunService').Stepped:wait()
            end
        end
    end)
    for e = 1, r do
        if bai.autobuystop == false then
            autobuyv2(o)
            task.wait()
        end
    end
    spawn(function()
        wait(1)
        bai.autocsdx:Disconnect()
        bai.autocsdx = nil
    end)
    return o, r
end

local cashierIds = {}
spawn(function()
    local connection = game.ReplicatedStorage.NPCDialog.PromptChat.OnClientEvent:connect(function(ba, data)
        if cashierIds[data.Name] == nil then
            cashierIds[data.Name] = data.ID
        end
    end)
    game.ReplicatedStorage.NPCDialog.SetChattingValue:InvokeServer(1)
    wait(2)
    connection:Disconnect()
    connection = nil
    game.ReplicatedStorage.NPCDialog.SetChattingValue:InvokeServer(0)
end)

local function getSpecialID(Shop)
    return cashierIds[Shop]
end

function shuaxinlb(zji)
    bai.dropdown = {}
    if zji == true then
        for p, I in next, Players:GetChildren() do
            table.insert(bai.dropdown, I.Name)
        end
    else
        for p, I in next, Players:GetChildren() do
            if I ~= lp then
                table.insert(bai.dropdown, I.Name)
            end
        end
    end
end
shuaxinlb(true)

local function OwnerCheck(item)
    if item:FindFirstChild('Owner') then
        return tostring(item.Owner.Value)
    end
end

local function WhitelistCheck(player)
    return game:GetService('ReplicatedStorage').Interaction.ClientIsWhitelisted:InvokeServer(player) == true
end

local function farAxeEquip()
    local done = false
    if bai.farAxeEquip == nil then
        Library:Notify({Title = '白', Description = '选择一把斧头', Time = 4})
        bai.farAxeEquip = Mouse.Button1Down:connect(function()
            local target = Mouse.Target
            if target.Parent:IsA('Model') and target.Parent:FindFirstChild('ToolName') then
                if OwnerCheck(target.Parent) == tostring(lp) or WhitelistCheck(target.Parent.Owner.Value) then
                    game:GetService('ReplicatedStorage').Interaction.ClientInteracted:FireServer(target.Parent, 'Pick up tool')
                    done = true
                end
            end
        end)
        repeat
            wait()
        until done
        Library:Notify({Title = '白', Description = '已装备', Time = 4})
        if bai.farAxeEquip then
            bai.farAxeEquip:Disconnect()
            bai.farAxeEquip = nil
        end
    else
        Library:Notify({Title = '错误', Description = '已经激活', Time = 4})
    end
end

local function donate(plr, amount)
    local spawnf = function(func, ...)
        return coroutine.wrap(func)(...)
    end
    if tostring(plr) == tostring(lp) then
        Library:Notify({Title = '错误', Description = '请选择玩家', Time = 4})
        return
    end
    if bai.donationRecipient == nil or not Players:FindFirstChild(plr) then
        Library:Notify({Title = '错误', Description = '没有找到玩家', Time = 4})
        return
    end
    if tonumber(bai.moneyaoumt) >= 60000000 then
        Library:Notify({Title = '错误', Description = '数字太高', Time = 4})
        return
    end
    if tonumber(bai.moneyaoumt) <= 0 then
        Library:Notify({Title = '错误', Description = '数字太高', Time = 4})
        return
    end
    if lp.CurrentSaveSlot.Value <= 0 then
        Library:Notify({Title = '错误', Description = '基地没有加载', Time = 4})
        return
    end
    if not lp:FindFirstChild('CurrentlySavingOrLoading') then
        Library:Notify({Title = '错误', Description = '正在保存', Time = 4})
        return
    end
    if tonumber(bai.moneyaoumt) > lp.leaderstats.Money.Value then
        Library:Notify({Title = '错误', Description = '你没有足够的钱', Time = 4})
        return
    end
    local scr = getsenv(lp.PlayerGui.DonateGUI.DonateClient)
    local scr2 = getsenv(lp.PlayerGui.NoticeGUI.NoticeClient)
    scr.setPlatformControls = function() end
    scr.openWindow()
    game:GetService('RunService').Heartbeat:wait()
    local oldAmount = Players:FindFirstChild(plr).leaderstats.Money.Value
    local success, errormsg = spawnf(function()
        game:GetService('ReplicatedStorage').Transactions.ClientToServer.Donate:InvokeServer(Players:FindFirstChild(plr), tonumber(amount), tonumber(lp.CurrentSaveSlot.Value))
    end)
    game:GetService('RunService').Heartbeat:wait()
    for i, v in next, getupvalues(scr.sendDonation) do
        if i == 1 then
            debug.setupvalue(scr.sendDonation, i, Players:FindFirstChild(plr))
        end
    end
    scr.sendDonation()
    game:GetService('RunService').Heartbeat:wait()
    scr2.exitNotice()
    Library:Notify({Title = '白', Description = '正在尝试转钱', Time = 2})
    wait(6)
    if Players:FindFirstChild(plr).leaderstats.Money.Value ~= oldAmount + amount then
        Library:Notify({Title = '错误', Description = '错误可能需要冷却', Time = 4})
        scr2.exitNotice()
        return
    end
    Library:Notify({Title = '白', Description = '转钱' .. tostring(amount) .. ' 给 ' .. tostring(plr), Time = 4})
    scr2.exitNotice()
end

PlayerGroup:AddSlider("HipHeightSlider", {
    Text = "设置高度",
    Default = 0,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Callback = function(Value)
        pcall(function()
            player.Character.Humanoid.HipHeight = Value
        end)
    end,
})

PlayerGroup:AddSlider("GravitySlider", {
    Text = "设置重力",
    Default = 198,
    Min = -999,
    Max = 999,
    Rounding = 0,
    Callback = function(Value)
        pcall(function()
            workspace.Gravity = Value
        end)
    end,
})

PlayerGroup:AddSlider("CameraZoomSlider", {
    Text = "设置相机焦距",
    Default = 100,
    Min = 0,
    Max = 9999,
    Rounding = 0,
    Callback = function(Value)
        pcall(function()
            player.CameraMaxZoomDistance = Value
        end)
    end,
})

PlayerGroup:AddToggle("SelfLight", {
    Text = "自身发光",
    Default = false,
    Callback = function(Value)
        applyLight(Value)
    end,
})

PlayerGroup:AddToggle("Invisible", {
    Text = "隐身",
    Default = false,
    Callback = function(Value)
        if Value then
            TurnInvisible()
        else
            TurnVisible()
        end
    end,
})

PlayerGroup:AddButton("安全自杀", function()
    pcall(function()
        lp.Character.Head:Destroy()
    end)
end)

PlayerGroup:AddButton("解锁最大焦距", function()
    pcall(function()
        lp.CameraMaxZoomDistance = 9e9
    end)
end)

local tpLocations = {'出生点', '木材反斗城', '土地商店', '桥', '码头', '椰子岛', '洞穴', '鲨鱼斧合成', '火山', '沼泽', '家具店', '盒子车行', '连锁逻辑店', '鲍勃的小店', '画廊', '雪山', '灵视神殿', '怪人', '小绿盒', '滑雪小屋', '黄金木洞穴', '小鸟斧头', "灯塔", '回家'}
TpGroup:AddDropdown("TeleportDropdown", {
    Text = "普通传送",
    Default = 1,
    Values = tpLocations,
    Callback = function(Value)
        local loc = tpLocations[Value]
        if loc == '木材反斗城' then
            tp(CFrame.new(270, 4, 60))
        elseif loc == '出生点' then
            tp(CFrame.new(174, 10.5, 66))
        elseif loc == '土地商店' then
            tp(CFrame.new(270, 3, -98))
        elseif loc == '桥' then
            tp(CFrame.new(112, 37, -892))
        elseif loc == '码头' then
            tp(CFrame.new(1136, 0, -206))
        elseif loc == '椰子岛' then
            tp(CFrame.new(2614, -4, -34))
        elseif loc == '洞穴' then
            tp(CFrame.new(3590, -177, 415))
        elseif loc == '火山' then
            tp(CFrame.new(-1588, 623, 1069))
        elseif loc == '沼泽' then
            tp(CFrame.new(-1216, 131, -822))
        elseif loc == '家具店' then
            tp(CFrame.new(486, 3, -1722))
        elseif loc == '盒子车行' then
            tp(CFrame.new(509, 3, -1458))
        elseif loc == '雪山' then
            tp(CFrame.new(1487, 415, 3259))
        elseif loc == '连锁逻辑店' then
            tp(CFrame.new(4615, 7, -794))
        elseif loc == '鲍勃的小店' then
            tp(CFrame.new(292, 8, -2544))
        elseif loc == '画廊' then
            tp(CFrame.new(5217, -166, 721))
        elseif loc == '灵视神殿' then
            tp(CFrame.new(-1608, 195, 928))
        elseif loc == '怪人' then
            tp(CFrame.new(1071, 16, 1141))
        elseif loc == '小绿盒' then
            tp(CFrame.new(-1667, 349, 1474))
        elseif loc == '滑雪小屋' then
            tp(CFrame.new(1244, 59, 2290))
        elseif loc == '黄金木洞穴' then
            tp(CFrame.new(-1080, -5, -942))
        elseif loc == '鲨鱼斧合成' then
            tp(CFrame.new(330.259735, 45.7998505, 1943.30823, 0.972010553, -8.07546598e-08, 0.234937176, 7.63610259e-08, 1, 2.77986647e-08, -0.234937176, -9.08055142e-09, 0.972010553))
        elseif loc == '小鸟斧头' then
            tp(CFrame.new(4813.1, 33.5, -978.8))
        elseif loc == '灯塔' then
            tp(CFrame.new(1464.8, 356.3, 3257.2))
        elseif loc == '回家' then
            for i, v in pairs(workspace.Properties:GetChildren()) do
                if v.Owner.Value == player then
                    tp(v.OriginSquare.CFrame + Vector3.new(0, 10, 0))
                end
            end
        end
    end,
})

local treeTypes = {"普通树", "沼泽黄金", "樱花", "蓝木", "冰木", "火山木", "橡木", "巧克力木", "白桦木", "黄金木", "雪地松", "僵尸木", "大巧克力树", "椰子树", "幻影木"}
local treeTypeMap = {
    ["普通树"] = "Generic", ["沼泽黄金"] = "GoldSwampy", ["樱花"] = "Cherry", ["蓝木"] = "CaveCrawler",
    ["冰木"] = "Frost", ["火山木"] = "Volcano", ["橡木"] = "Oak", ["巧克力木"] = "Walnut",
    ["白桦木"] = "Birch", ["黄金木"] = "SnowGlow", ["雪地松"] = "Pine", ["僵尸木"] = "GreenSwampy",
    ["大巧克力树"] = "Koa", ["椰子树"] = "Palm", ["幻影木"] = "LoneCave"
}
TreeTpGroup:AddDropdown("TreeTpDropdown", {
    Text = "传送到树",
    Default = 1,
    Values = treeTypes,
    Callback = function(Value)
        local ttype = treeTypeMap[treeTypes[Value]]
        for i, v in pairs(workspace:GetChildren()) do
            if v.Name == "TreeRegion" then
                for j, k in ipairs(v:GetChildren()) do
                    if k:FindFirstChild("TreeClass") and k.TreeClass.Value == ttype then
                        player.Character:MoveTo(k.WoodSection.Position)
                        break
                    end
                end
            end
        end
    end,
})

CarTpGroup:AddDropdown("CarTpDropdown", {
    Text = "汽车传送",
    Default = 1,
    Values = tpLocations,
    Callback = function(Value)
        local loc = tpLocations[Value]
        if loc == '木材反斗城' then
            carTeleport(CFrame.new(270, 4, 60))
        elseif loc == '出生点' then
            carTeleport(CFrame.new(174, 10.5, 66))
        elseif loc == '土地商店' then
            carTeleport(CFrame.new(270, 3, -98))
        elseif loc == '桥' then
            carTeleport(CFrame.new(112, 37, -892))
        elseif loc == '码头' then
            carTeleport(CFrame.new(1136, 0, -206))
        elseif loc == '椰子岛' then
            carTeleport(CFrame.new(2614, -4, -34))
        elseif loc == '洞穴' then
            carTeleport(CFrame.new(3590, -177, 415))
        elseif loc == '火山' then
            carTeleport(CFrame.new(-1588, 623, 1069))
        elseif loc == '沼泽' then
            carTeleport(CFrame.new(-1216, 131, -822))
        elseif loc == '家具店' then
            carTeleport(CFrame.new(486, 3, -1722))
        elseif loc == '盒子车行' then
            carTeleport(CFrame.new(509, 3, -1458))
        elseif loc == '雪山' then
            carTeleport(CFrame.new(1487, 415, 3259))
        elseif loc == '连锁逻辑店' then
            carTeleport(CFrame.new(4615, 7, -794))
        elseif loc == '鲍勃的小店' then
            carTeleport(CFrame.new(292, 8, -2544))
        elseif loc == '画廊' then
            carTeleport(CFrame.new(5217, -166, 721))
        elseif loc == '灵视神殿' then
            carTeleport(CFrame.new(-1608, 195, 928))
        elseif loc == '怪人' then
            carTeleport(CFrame.new(1071, 16, 1141))
        elseif loc == '小绿盒' then
            carTeleport(CFrame.new(-1667, 349, 1474))
        elseif loc == '滑雪小屋' then
            carTeleport(CFrame.new(1244, 59, 2290))
        elseif loc == '黄金木洞穴' then
            carTeleport(CFrame.new(-1080, -5, -942))
        elseif loc == '鲨鱼斧合成' then
            carTeleport(CFrame.new(330.259735, 45.7998505, 1943.30823, 0.972010553, -8.07546598e-08, 0.234937176, 7.63610259e-08, 1, 2.77986647e-08, -0.234937176, -9.08055142e-09, 0.972010553))
        elseif loc == '小鸟斧头' then
            carTeleport(CFrame.new(4813.1, 33.5, -978.8))
        elseif loc == '灯塔' then
            carTeleport(CFrame.new(1464.8, 356.3, 3257.2))
        elseif loc == '回家' then
            for i, v in pairs(workspace.Properties:GetChildren()) do
                if v.Owner.Value == player then
                    carTeleport(v.OriginSquare.CFrame + Vector3.new(0, 10, 0))
                end
            end
        end
    end,
})

AxeGroup:AddToggle("AutoDropAxe", {
    Text = "自动扔斧头",
    Default = false,
    Callback = function(Value)
        bai.autodropae = Value
        if Value then
            task.spawn(function()
                while bai.autodropae do
                    task.wait()
                    pcall(function()
                        local oldpos = lp.Character.HumanoidRootPart.CFrame
                        droptool(oldpos)
                    end)
                end
            end)
        end
    end,
})

AxeGroup:AddToggle("AutoPickAxe", {
    Text = "自动捡斧头",
    Default = false,
    Callback = function(Value)
        bai.autopick = Value
        if Value then
            task.spawn(function()
                while bai.autopick do
                    task.wait(0.1)
                    pcall(function()
                        for a, b in pairs(workspace.PlayerModels:GetChildren()) do
                            if b:FindFirstChild("Owner") and b.Owner.Value == player then
                                if b:FindFirstChild("Type") and b.Type.Value == "Tool" then
                                    game:GetService('ReplicatedStorage').Interaction.ClientInteracted:FireServer(b, 'Pick up tool')
                                end
                            end
                        end
                    end)
                end
            end)
        end
    end,
})

AxeGroup:AddButton("加载复制斧头", function()
    task.spawn(function()
        CanClientLoad()
        wait(1)
        local oldpos = lp.Character.HumanoidRootPart.CFrame
        lp.Character.Head:Destroy()
        wait(tonumber(bai.loaddupeaxewaittime) or 3.1)
        LoadSlot(GetLoadedSlot())
        wait(6)
        lp.Character.HumanoidRootPart.CFrame = oldpos
    end)
end)

AxeGroup:AddButton("远程装备斧头", function()
    farAxeEquip()
end)

AxeGroup:AddToggle("AxeFollowMouse", {
    Text = "斧头跟随鼠标",
    Default = false,
    Callback = function(Value)
        bai.whthmose = Value
    end,
})

AxeGroup:AddToggle("AxeFling", {
    Text = "斧头炸家",
    Default = false,
    Callback = function(Value)
        if Value then
            axefily()
        else
            if bai.axeFling then
                bai.axeFling:Disconnect()
                bai.axeFling = nil
            end
        end
    end,
})

BaseGroup:AddButton("点击土地免费获得", function()
    task.spawn(function()
        local freeland = nil
        Library:Notify({Title = "白", Description = "请你点击一个空的土地", Time = 4})
        local ClickToSelectClick = Mouse.Button1Up:Connect(function()
            local Clicked = Mouse.Target
            if tostring(Clicked.Parent.Name) == "Property" then
                local v = Clicked.Parent
                if v:FindFirstChild("Owner") and v.Owner.Value == nil then
                    game.ReplicatedStorage.PropertyPurchasing.ClientPurchasedProperty:FireServer(v, v.OriginSquare.OriginCFrame.Value.p + Vector3.new(0, 3, 0))
                    wait(0.5)
                    freeland = true
                    Instance.new('RemoteEvent', game:service('ReplicatedStorage').Interaction).Name = "Ban"
                    player.Character.HumanoidRootPart.CFrame = v.OriginSquare.CFrame + Vector3.new(0, 10, 0)
                else
                    Library:Notify({Title = "白", Description = "这个土地有主人了", Time = 4})
                end
            end
        end)
        repeat task.wait() until freeland ~= nil
        ClickToSelectClick:Disconnect()
        ClickToSelectClick = nil
    end)
end)

BaseGroup:AddInput("SaveSlotInput", {
    Text = "选择存档",
    Default = "1",
    Callback = function(Value)
        bai.soltnumber = Value
    end,
})

BaseGroup:AddButton("加载", function()
    task.spawn(function()
        local CheckSlot = CheckSlotNumber()
        if CheckSlot ~= false then
            if CheckIfSlotAvailable(CheckSlot) == true then
                local LoadSlot = game.ReplicatedStorage.LoadSaveRequests.RequestLoad:InvokeServer(CheckSlot)
                if LoadSlot == false then
                    Library:Notify({Title = "白", Description = "有冷却现在不能加载!", Time = 1})
                end
                if LoadSlot == true then
                    Library:Notify({Title = "白", Description = "已加载!", Time = 2})
                end
            else
                Library:Notify({Title = "白", Description = "貌似不工作了", Time = 2})
            end
        else
            Library:Notify({Title = "白", Description = "请你填数字", Time = 2})
        end
    end)
end)

BaseGroup:AddButton("一键复制", function()
    task.spawn(function()
        local DupeSlot = tonumber(bai.soltnumber)
        local ItemAdded = workspace.PlayerModels.ChildAdded:Connect(function(v)
            if v:WaitForChild("Owner") and v.Owner.Value == player then
                game:GetService('RunService').Stepped:wait()
                game:Shutdown()
            end
        end)
        game:GetService("ReplicatedStorage").LoadSaveRequests.RequestLoad:InvokeServer(DupeSlot, player)
    end)
end)

BringTreeGroup:AddDropdown("TreeSelect", {
    Text = "选择树",
    Default = 1,
    Values = treeTypes,
    Callback = function(Value)
        bai.cuttreeselect = treeTypeMap[treeTypes[Value]]
    end,
})

BringTreeGroup:AddInput("BringAmount", {
    Text = "带来树数量",
    Default = "1",
    Callback = function(Value)
        bai.bringamount = tonumber(Value) or 1
    end,
})

BringTreeGroup:AddButton("带来树", function()
    task.spawn(function()
        bai.bringtree = true
        bai.treecutset = lp.Character.HumanoidRootPart.CFrame
        task.wait(0.2)
        for i = 1, bai.bringamount do
            if bai.bringtree == true then
                task.wait()
                bringTree(bai.cuttreeselect)
            end
        end
    end)
end)

BringTreeGroup:AddButton("停止", function()
    bai.bringtree = false
end)

BringTreeGroup:AddToggle("AutoBringTree", {
    Text = "自动砍树",
    Default = false,
    Callback = function(Value)
        bai.autofarm = Value
        if Value then
            task.spawn(function()
                while task.wait(0.3) do
                    if bai.autofarm == true then
                        bringTree(bai.cuttreeselect)
                    end
                end
            end)
        end
    end,
})

BringTreeGroup:AddToggle("AutoFarmMoney", {
    Text = "自动赚钱",
    Default = false,
    Callback = function(Value)
        bai.autofarm1 = Value
        if Value then
            task.spawn(function()
                while task.wait() do
                    if bai.autofarm1 == true then
                        pcall(function()
                            player.Character:MoveTo(Vector3.new(315, -0.296, 102.791))
                            autofarm(bai.cuttreeselect)
                            wait(1)
                            player.Character:MoveTo(Vector3.new(315, -0.296, 102.791))
                            wait(20)
                        end)
                    end
                end
            end)
        end
    end,
})

WoodGroup:AddButton("传送木头", function()
    task.spawn(function()
        local OldPos = player.Character.HumanoidRootPart.CFrame
        for i, v in next, game:GetService("Workspace").LogModels:GetChildren() do
            if v:FindFirstChild("Owner") and v.Owner.Value == player then
                if not v.PrimaryPart then
                    v.PrimaryPart = v:FindFirstChild("WoodSection")
                end
                player.Character.HumanoidRootPart.CFrame = CFrame.new(v:FindFirstChild("WoodSection").CFrame.p)
                spawn(function()
                    for i = 1, 50 do
                        game.ReplicatedStorage.Interaction.ClientIsDragging:FireServer(v)
                        task.wait()
                    end
                end)
                for i = 1, 50 do
                    task.wait()
                    v:PivotTo(OldPos)
                end
                task.wait()
            end
        end
        player.Character.HumanoidRootPart.CFrame = OldPos
    end)
end)

WoodGroup:AddButton("传送木板", function()
    task.spawn(function()
        local logFolder = getPlanks()
        local oldPos = player.Character.HumanoidRootPart.CFrame
        for _, log in next, logFolder do
            if log:FindFirstChild('WoodSection') then
                spawn(function()
                    for i = 1, 20 do
                        game:GetService('ReplicatedStorage').Interaction.ClientIsDragging:FireServer(log)
                        task.wait()
                    end
                end)
                wait(0.18)
                if not log.PrimaryPart then
                    log.PrimaryPart = log.WoodSection
                end
                log:SetPrimaryPartCFrame(oldPos)
            end
        end
    end)
end)

WoodGroup:AddButton("卖木板", function()
    task.spawn(function()
        for _, Plank in pairs(workspace.PlayerModels:GetChildren()) do
            if Plank.Name == "Plank" and Plank:findFirstChild("Owner") then
                if Plank.Owner.Value == player then
                    for i, v in pairs(Plank:GetChildren()) do
                        if v.Name == "WoodSection" then
                            spawn(function()
                                for i = 1, 100 do
                                    wait()
                                    v.CFrame = CFrame.new(Vector3.new(315, -0.296, 85.791)) * CFrame.Angles(math.rad(90), 0, 0)
                                end
                            end)
                        end
                    end
                    spawn(function()
                        for i = 1, 100 do
                            wait()
                            game.ReplicatedStorage.Interaction.ClientIsDragging:FireServer(Plank)
                        end
                    end)
                end
            end
        end
    end)
end)

WoodGroup:AddToggle("AutoSellPlank", {
    Text = "自动卖木板",
    Default = false,
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while task.wait() do
                    if not Toggles.AutoSellPlank.Value then break end
                    pcall(function()
                        for _, Plank in pairs(workspace.PlayerModels:GetChildren()) do
                            if Plank.Name == "Plank" and Plank:findFirstChild("Owner") then
                                if Plank.Owner.Value == player then
                                    for i, v in pairs(Plank:GetChildren()) do
                                        if v.Name == "WoodSection" then
                                            spawn(function()
                                                for i = 1, 10 do
                                                    wait()
                                                    v.CFrame = CFrame.new(Vector3.new(315, -0.296, 85.791)) * CFrame.Angles(math.rad(90), 0, 0)
                                                end
                                            end)
                                        end
                                    end
                                    spawn(function()
                                        for i = 1, 20 do
                                            wait()
                                            game.ReplicatedStorage.Interaction.ClientIsDragging:FireServer(Plank)
                                        end
                                    end)
                                end
                            end
                        end
                    end)
                end
            end)
        end
    end,
})

WoodGroup:AddButton("卖木头", function()
    task.spawn(function()
        sellwood()
    end)
end)

WoodGroup:AddToggle("AutoSellWood", {
    Text = "自动卖木头",
    Default = false,
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while task.wait() do
                    if not Toggles.AutoSellWood.Value then break end
                    pcall(function()
                        sellwood()
                    end)
                end
            end)
        end
    end,
})

WoodGroup:AddToggle("HardDrag", {
    Text = "拖拽器",
    Default = false,
    Callback = function(Value)
        if Value then
            workspace.ChildAdded:connect(function(Dragger)
                if tostring(Dragger) == 'Dragger' then
                    local BodyGyro = Dragger:WaitForChild 'BodyGyro'
                    local BodyPosition = Dragger:WaitForChild 'BodyPosition'
                    repeat game:GetService('RunService').Stepped:wait() until workspace:FindFirstChild 'Dragger'
                    BodyPosition.P = 120000
                    BodyPosition.D = 1000
                    BodyPosition.maxForce = Vector3.new(1, 1, 1) * 1000000
                    BodyGyro.maxTorque = Vector3.new(1, 1, 1) * 200
                    BodyGyro.P = 1200
                    BodyGyro.D = 140
                end
            end)
        else
            workspace.ChildAdded:connect(function(Dragger)
                if tostring(Dragger) == 'Dragger' then
                    local BodyGyro = Dragger:WaitForChild 'BodyGyro'
                    local BodyPosition = Dragger:WaitForChild 'BodyPosition'
                    repeat game:GetService('RunService').Stepped:wait() until workspace:FindFirstChild 'Dragger'
                    BodyPosition.P = 10000
                    BodyPosition.D = 800
                    BodyPosition.maxForce = Vector3.new(17000, 17000, 17000)
                    BodyGyro.maxTorque = Vector3.new(200, 200, 200)
                    BodyGyro.P = 1200
                    BodyGyro.D = 140
                end
            end)
        end
    end,
})

WoodGroup:AddButton("处理树半自动旧", function()
    task.spawn(function()
        wait(0.5)
        local oldPosition = getPosition()
        local oldpos = lp.Character.HumanoidRootPart.CFrame
        local wood
        local sell = CFrame.new(314.943634, -6, 82.8602905, -0.999041438, -0.00970918871, 0.0426843949, -0.00323261251, 0.988793433, 0.149255186, -0.0436551981, 0.148974136, -0.987876952)
        Library:Notify({Title = "半自动加工", Description = "请点击一颗树", Time = 4})
        local ModTree = Mouse.Button1Up:Connect(function()
            local obj = Mouse.Target.Parent
            if not obj:FindFirstChild "RootCut" and obj.Parent.Name == "TreeRegion" then
                return Library:Notify({Title = "错误!", Description = "这棵树还没有砍!", Time = 3})
            end
            if obj:FindFirstChild "Owner" and obj.Owner.Value == lp and obj:FindFirstChild "WoodSection" then
                wood = obj
                Library:Notify({Title = "半自动加工", Description = "已选择树!", Time = 3})
            end
        end)
        repeat task.wait(.01) until wood ~= nil
        ModTree:Disconnect()
        ModTree = nil
        tp(wood.WoodSection.CFrame)
        spawn(function()
            for i = 1, 20 do
                wood:PivotTo(sell)
                game.ReplicatedStorage.Interaction.ClientIsDragging:FireServer(wood)
                game:GetService('RunService').Stepped:wait()
            end
        end)
        task.wait(0.1)
        tp(wood.WoodSection.CFrame)
        task.wait(1.2)
        for i = 1, 20 do
            game.ReplicatedStorage.Interaction.ClientIsDragging:FireServer(wood)
            wood:MoveTo(oldPosition)
            game:GetService('RunService').Stepped:wait()
        end
        tp(oldpos)
    end)
end)

WoodGroup:AddButton("处理树半自动新", function()
    task.spawn(function()
        local oldpos = lp.Character.HumanoidRootPart.CFrame
        bai.modwood = true
        for _, Log in pairs(workspace.LogModels:GetChildren()) do
            if Log.Name:sub(1, 6) == "Loose_" and Log:findFirstChild("Owner") then
                if Log.Owner.Value == player then
                    for i, v in pairs(Log:GetChildren()) do
                        if v.Name == "WoodSection" then
                            if bai.modwood == true then
                                tp(v.CFrame)
                            end
                            wait(0.2)
                            spawn(function()
                                for i = 1, 20 do
                                    if bai.modwood == true then
                                        task.wait()
                                        v.CFrame = CFrame.new(330.98587, -0.574430406, 79.0872726, -6, 0.000781620154, -0.0201439466, 0.000569172669, 0.99994421, 0.0105500417, 0.0201510694, 0.0105364323, -0.999741435)
                                        game.ReplicatedStorage.Interaction.ClientIsDragging:FireServer(Log)
                                    end
                                end
                                wait(1)
                                for i = 1, 10 do
                                    task.wait()
                                    v.CFrame = oldpos
                                    game.ReplicatedStorage.Interaction.ClientIsDragging:FireServer(Log)
                                end
                                bai.modwood = false
                            end)
                        end
                    end
                end
            end
        end
        tp(oldpos)
    end)
end)

WoodGroup:AddButton("木板填充蓝图", function()
    task.spawn(function()
        PlankToBlueprint()
    end)
end)

WoodGroup:AddToggle("SeeLoneCave", {
    Text = "查看幻影",
    Default = false,
    Callback = function(Value)
        if Value then
            for i, v in pairs(workspace:GetChildren()) do
                if v.Name == "TreeRegion" and v:FindFirstChildOfClass("Model") then
                    if v.Model.TreeClass.Value == "LoneCave" then
                        workspace.Camera.CameraSubject = v.Model.WoodSection
                        task.wait()
                    end
                end
            end
        else
            workspace.Camera.CameraSubject = player.Character
        end
    end,
})

WoodGroup:AddButton("锯木机最大木头体型", function()
    task.spawn(function()
        local connection, sawmillModel
        Library:Notify({Title = '白', Description = '选择一个锯木机', Time = 4})
        connection = mouse.Button1Down:Connect(function(b)
            local target = mouse.Target
            if target then
                local sawmill = target.Parent
                if sawmill.Name:find('Sawmill') then
                    sawmillModel = sawmill
                    Library:Notify({Title = '白', Description = '锯木机已选择', Time = 4})
                elseif sawmill.Parent.Name:find('Sawmill') or sawmill.Parent:FindFirstChild 'BlockageAlert' then
                    sawmillModel = sawmill.Parent
                    Library:Notify({Title = '白', Description = '锯木机已选择', Time = 4})
                end
            end
        end)
        repeat wait() until sawmillModel ~= nil
        if connection then
            connection:Disconnect()
            connection = nil
        end
        spawn(function()
            for i = 1, 50 do
                game:GetService('ReplicatedStorage').Interaction.RemoteProxy:FireServer(sawmillModel:FindFirstChild 'ButtonRemote_XUp')
                task.wait(0.5)
                game:GetService('ReplicatedStorage').Interaction.RemoteProxy:FireServer(sawmillModel:FindFirstChild 'ButtonRemote_YUp')
            end
        end)
    end)
end)

WoodGroup:AddToggle("AutoCut1x1", {
    Text = "自动切成1单位",
    Default = false,
    Callback = function(Value)
        if Value then
            task.spawn(function()
                local oldpos = lp.Character.HumanoidRootPart.CFrame
                local PlankReAdded = workspace.PlayerModels.ChildAdded:Connect(function(v)
                    if v:WaitForChild("TreeClass") and v:WaitForChild("WoodSection") then
                        bai.SelTree = v
                        task.wait()
                    end
                end)
                local UnitCutterClick = Mouse.Button1Up:Connect(function()
                    local Clicked = Mouse.Target
                    if Clicked.Name == "WoodSection" then
                        bai.SelTree = Clicked.Parent
                        player.Character:MoveTo(Clicked.Position + Vector3.new(0, 3, -3))
                        local success, data = getBestAxe(bai.SelTree.TreeClass.Value)
                        repeat
                            if not Toggles.AutoCut1x1.Value then break end
                            cutPart(bai.SelTree.CutEvent, 1, 1, data, bai.SelTree.TreeClass.Value)
                            if bai.SelTree:FindFirstChild("Cut") then
                                player.Character:MoveTo(bai.SelTree:FindFirstChild("Cut").Position + Vector3.new(0, 3, -3))
                            end
                            task.wait()
                        until bai.SelTree.WoodSection.Size.X <= 1.88 and bai.SelTree.WoodSection.Size.Y <= 1.88 and bai.SelTree.WoodSection.Size.Z <= 1.88 or not Toggles.AutoCut1x1.Value
                    end
                end)
                repeat task.wait() until not Toggles.AutoCut1x1.Value
                pcall(function()
                    player.Character.HumanoidRootPart.CFrame = oldpos
                    UnitCutterClick:Disconnect()
                    PlankReAdded:Disconnect()
                end)
            end)
        end
    end,
})

WoodGroup:AddButton("分解树", function()
    task.spawn(function()
        local OldPos = player.Character.HumanoidRootPart.CFrame
        local LogChopped = false
        local branchadded = workspace.LogModels.ChildAdded:Connect(function(v)
            if v:WaitForChild("Owner") and v.Owner.Value == player then
                if v:WaitForChild("WoodSection") then
                    LogChopped = true
                end
            end
        end)
        Library:Notify({Title = "白", Description = "请你点击一棵树", Time = 4})
        local TreeToJointCut = nil
        local DismemberTreeC = Mouse.Button1Up:Connect(function()
            local Clicked = Mouse.Target
            if Clicked.Parent:FindFirstAncestor("LogModels") then
                if Clicked.Parent:FindFirstChild("Owner") and Clicked.Parent.Owner.Value == player then
                    TreeToJointCut = Clicked.Parent
                end
            end
        end)
        repeat task.wait() until tostring(TreeToJointCut) ~= "nil"
        for i, v in next, TreeToJointCut:GetChildren() do
            if v.Name == "WoodSection" then
                if v:FindFirstChild("ID") and v.ID.Value ~= 1 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(v.CFrame.p)
                    local success, data = getBestAxe(v.Parent:FindFirstChild("TreeClass").Value)
                    repeat
                        cutPart(v.Parent:FindFirstChild("CutEvent"), v.ID.Value, 0.2, data, v.Parent:FindFirstChild("TreeClass").Value)
                        task.wait()
                    until LogChopped == true
                    LogChopped = false
                    task.wait(1)
                end
            end
        end
        TreeToJointCut = nil
        branchadded:Disconnect()
        DismemberTreeC:Disconnect()
        player.Character.HumanoidRootPart.CFrame = OldPos
    end)
end)

WoodGroup:AddButton("处理树自动", function()
    task.spawn(function()
        local wood
        local Saw
        local sell = CFrame.new(315, -4, 84)
        Library:Notify({Title = "一键加工", Description = "请点击一颗树,再点击一个锯木机", Time = 4})
        wait(0.5)
        local oldPosition = getPosition()
        local oldpos = lp.Character.HumanoidRootPart.CFrame
        local ModTree = Mouse.Button1Up:Connect(function()
            local obj = Mouse.Target.Parent
            if not obj:FindFirstChild "RootCut" and obj.Parent.Name == "TreeRegion" then
                return Library:Notify({Title = "错误!", Description = "这棵树还没有砍!", Time = 3})
            end
            if obj:FindFirstChild "Owner" and obj.Owner.Value == lp and obj:FindFirstChild "WoodSection" then
                wood = obj
                Library:Notify({Title = "一键加工", Description = "已选择树!", Time = 3})
            end
            if obj.Name:find('Sawmill') then
                Saw = obj
                Library:Notify({Title = '白', Description = '锯木机已选择', Time = 4})
            elseif obj.Parent.Name:find('Sawmill') or obj.Parent:FindFirstChild 'BlockageAlert' then
                Saw = obj.Parent
                Library:Notify({Title = '白', Description = '锯木机已选择', Time = 4})
            end
        end)
        repeat task.wait(.01) until wood and Saw ~= nil
        ModTree:Disconnect()
        ModTree = nil
        local SawC = Saw.Particles.CFrame + Vector3.new(0.7, 0)
        tp(wood.WoodSection.CFrame)
        spawn(function()
            for i = 1, 20 do
                wood:SetPrimaryPartCFrame(sell)
                game.ReplicatedStorage.Interaction.ClientIsDragging:FireServer(wood)
                game:GetService('RunService').Stepped:wait()
            end
        end)
        task.wait(0.3)
        tp(wood.WoodSection.CFrame)
        task.wait(1)
        for i = 1, 20 do
            game.ReplicatedStorage.Interaction.ClientIsDragging:FireServer(wood)
            wood:MoveTo(oldPosition)
            game:GetService('RunService').Stepped:wait()
        end
        tp(oldpos)
        pcall(function()
            spawn(function()
                for i = 1, 200 do
                    game.ReplicatedStorage.Interaction.ClientIsDragging:FireServer(wood)
                    game.ReplicatedStorage.Interaction.ClientIsDragging:FireServer(wood)
                    wood:SetPrimaryPartCFrame(SawC)
                    game.ReplicatedStorage.Interaction.ClientIsDragging:FireServer(wood)
                    task.wait()
                end
            end)
        end)
        Teleport(oldpos)
    end)
end)

WoodGroup:AddButton("删除树/木板", function()
    task.spawn(function()
        local a = game:GetService("ReplicatedStorage")
        local b = player
        local c = b:GetMouse()
        local f = Instance.new("Tool", b.Backpack)
        f.Name = "点击你要删除的树或木板"
        f.RequiresHandle = false
        f.Activated:Connect(function()
            local g = c.Target.Parent
            local h = b.Character.HumanoidRootPart.CFrame
            if not g:FindFirstChild "WoodSection" then
                return
            end
            local i
            if g:FindFirstChild "Owner" and g.Owner.Value == b or g.Owner.Value == nil then
                if not g:FindFirstChild "RootCut" and g.Parent.Name == "TreeRegion" then
                    for e, j in next, g:children() do
                        if j.Name == "WoodSection" and j:FindFirstChild "ID" and j:FindFirstChild("ID").Value == tonumber(1) then
                            i = j
                        end
                    end
                else
                    i = g.WoodSection
                end
                tp(i.CFrame)
                for e = 1, 3 do
                    spawn(function()
                        for e = 1, 20 do
                            a.Interaction.ClientIsDragging:FireServer(g)
                            a.Interaction.DestroyStructure:FireServer(g)
                            game:GetService('RunService').Stepped:wait()
                        end
                    end)
                    task.wait(.1)
                end
            else
                return
            end
            task.wait()
            tp(h)
        end)
        f.Parent = player.Backpack
    end)
end)

MoneyGroup:AddDropdown("MoneyPlayerSelect", {
    Text = "选择玩家",
    Default = 1,
    Values = bai.dropdown,
    Callback = function(Value)
        bai.moneytoplayername = bai.dropdown[Value]
    end,
})

MoneyGroup:AddButton("刷新列表", function()
    shuaxinlb(true)
    Options.MoneyPlayerSelect:SetValues(bai.dropdown)
end)

MoneyGroup:AddInput("MoneyAmount", {
    Text = "转钱数量",
    Default = "1",
    Callback = function(Value)
        bai.moneyaoumt = tonumber(Value) or 1
    end,
})

MoneyGroup:AddButton("开始转钱", function()
    task.spawn(function()
        donate(bai.moneytoplayername, bai.moneyaoumt)
    end)
end)

CarGroup:AddInput("CarFlySpeed", {
    Text = "输入飞行速度",
    Default = "200",
    Callback = function(Value)
        local s = tonumber(Value) or 200
        task.spawn(function()
            while true do
                pcall(function()
                    player.Character.HumanoidRootPart.Anchored = false
                    local bv = player.Character.HumanoidRootPart:FindFirstChildOfClass("BodyVelocity")
                    local bg = player.Character.HumanoidRootPart:FindFirstChildOfClass("BodyGyro")
                    if bv then bv:Destroy() end
                    if bg then bg:Destroy() end
                end)
                wait()
                pcall(function()
                    local BV = Instance.new("BodyVelocity", player.Character.HumanoidRootPart)
                    local BG = Instance.new("BodyGyro", player.Character.HumanoidRootPart)
                    BG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                    BG.D = 5000
                    BG.P = 50000
                    BG.CFrame = workspace.CurrentCamera.CFrame
                    BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    BV.Velocity = workspace.CurrentCamera.CFrame.LookVector * s
                end)
            end
        end)
    end,
})

CarGroup:AddToggle("CarFly", {
    Text = "开始飞行",
    Default = false,
    Callback = function(Value)
        if Value then
            pcall(function()
                local BV = Instance.new("BodyVelocity", player.Character.HumanoidRootPart)
                local BG = Instance.new("BodyGyro", player.Character.HumanoidRootPart)
                BG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                BG.D = 5000
                BG.P = 50000
                BG.CFrame = workspace.CurrentCamera.CFrame
                BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            end)
        else
            pcall(function()
                local bv = player.Character.HumanoidRootPart:FindFirstChildOfClass("BodyVelocity")
                local bg = player.Character.HumanoidRootPart:FindFirstChildOfClass("BodyGyro")
                if bv then bv:Destroy() end
                if bg then bg:Destroy() end
            end)
        end
    end,
})

CarGroup:AddButton("飞行说明", function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "说明",
        Text = "1，飞行速度要超过200不超过就会往下掉2，要先开启飞行再输入速度，然后重新开启飞行",
        Button1 = "知道了",
        Duration = 30
    })
end)

CarGroup:AddToggle("CarNoclip", {
    Text = "汽车穿墙",
    Default = false,
    Callback = function(Value)
        if Value then
            local vnoclipParts = {}
            local seat = lp.Character:FindFirstChildOfClass('Humanoid').SeatPart
            if not seat then return end
            local vehicleModel = seat.Parent
            repeat
                if vehicleModel.ClassName ~= "Model" then
                    vehicleModel = vehicleModel.Parent
                end
            until vehicleModel.ClassName == "Model"
            wait(0.1)
            for i, v in pairs(vehicleModel:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then
                    table.insert(vnoclipParts, v)
                    v.CanCollide = false
                end
            end
        else
            pcall(function()
                for i, v in pairs(vnoclipParts or {}) do
                    v.CanCollide = true
                end
            end)
        end
    end,
})

CarGroup:AddSlider("CarSpeedSlider", {
    Text = "汽车速度",
    Default = 3,
    Min = 3,
    Max = 600,
    Rounding = 0,
    Callback = function(Value)
        for i, v in pairs(workspace.PlayerModels:GetChildren()) do
            if v:FindFirstChild("Seat") and v:FindFirstChild("Configuration") then
                v.Configuration.MaxSpeed.Value = Value
            end
        end
    end,
})

ItemTpGroup:AddDropdown("ItemTpPlayer", {
    Text = "选择玩家",
    Default = 1,
    Values = bai.dropdown,
    Callback = function(Value)
        bai.cswjia = bai.dropdown[Value]
    end,
})

ItemTpGroup:AddButton("重置玩家名称", function()
    shuaxinlb(true)
    Options.ItemTpPlayer:SetValues(bai.dropdown)
end)

ItemTpGroup:AddButton("设置传送点", function()
    pcall(function()
        if workspace:FindFirstChild("baiBasedropCord") then
            workspace.baiBasedropCord:Destroy()
        end
    end)
    local baiBasedropCord = Instance.new("Part", workspace)
    baiBasedropCord.CanCollide = false
    baiBasedropCord.Anchored = true
    baiBasedropCord.Shape = Enum.PartType.Ball
    baiBasedropCord.Color = Color3.fromRGB(0, 217, 255)
    baiBasedropCord.Transparency = 0
    baiBasedropCord.Size = Vector3.new(2, 2, 2)
    baiBasedropCord.CFrame = lp.Character.HumanoidRootPart.CFrame
    baiBasedropCord.Material = Enum.Material.Marble
    baiBasedropCord.Name = "baiBasedropCord"
    bai.itemset = lp.Character.HumanoidRootPart.CFrame
end)

ItemTpGroup:AddButton("删除传送点", function()
    pcall(function()
        if workspace:FindFirstChild("baiBasedropCord") then
            workspace.baiBasedropCord:Destroy()
        end
        bai.itemset = nil
    end)
end)

ItemTpGroup:AddButton("获得工具", function()
    if bai.itemset == nil then
        return Library:Notify({Title = "白", Description = "请你放传送点", Time = 4})
    end
    local Tool = Instance.new("Tool", player.Backpack)
    Tool.Name = "点击你想要传送的物品"
    Tool.RequiresHandle = false
    Tool.Activated:connect(function()
        bai.cskais = true
        if mouse.Target.Parent:FindFirstChild("PurchasedBoxItemName") then
            bai.dxmz = mouse.Target.Parent.PurchasedBoxItemName.Value
        elseif mouse.Target.Parent:FindFirstChild("ItemName") then
            bai.dxmz = mouse.Target.Parent.ItemName.Value
        end
        for _, v in next, workspace.PlayerModels:children() do
            local check = v:FindFirstChild('ItemName') or v:FindFirstChild('PurchasedBoxItemName')
            local check2 = v:FindFirstChild 'Type'
            if bai.cskais == true then
                if check and check.Value == bai.dxmz and v:FindFirstChild('Owner') and tostring(v.Owner.Value) == bai.cswjia or check2 and check2.Value == bai.dxmz and v:FindFirstChild('Owner') and tostring(v.Owner.Value) == bai.cswjia then
                    local main = v:FindFirstChild 'Main'
                    if main and (lp.Character.HumanoidRootPart.CFrame.p - main.CFrame.p).magnitude > 5 then
                        tp(v.Main.CFrame + Vector3.new(4, 0, 4))
                    end
                    for e = 1, 20 do
                        game:GetService("ReplicatedStorage").Interaction.ClientIsDragging:FireServer(v)
                        v.Main.CFrame = bai.itemset
                        game:GetService("ReplicatedStorage").Interaction.ClientIsDragging:FireServer(v)
                        game:GetService('RunService').Stepped:wait()
                    end
                end
            end
        end
    end)
    Tool.Parent = player.Backpack
end)

ItemTpGroup:AddToggle("ClickSelectItem", {
    Text = "点击选择传送物品",
    Default = false,
    Callback = function(Value)
        if Value then
            bai.ClickToSelectClick = Mouse.Button1Up:Connect(function()
                local Clicked = Mouse.Target
                if Clicked.Parent:FindFirstChild("Owner") and tostring(Clicked.Parent.Owner.Value) == bai.cswjia then
                    if Clicked.Parent:FindFirstAncestor("PlayerModels") then
                        if not Clicked.Parent:FindFirstChild("SelectionBox") then
                            local SB = Instance.new("SelectionBox", Clicked.Parent)
                            SB.Adornee = Clicked.Parent
                        else
                            Clicked.Parent:FindFirstChild("SelectionBox"):Destroy()
                        end
                    end
                end
            end)
        else
            pcall(function()
                bai.ClickToSelectClick:Disconnect()
            end)
        end
    end,
})

ItemTpGroup:AddButton("取消选择", function()
    for i, v in next, game:GetService("Workspace").PlayerModels:GetChildren() do
        if v:FindFirstChild("Owner") and tostring(v.Owner.Value) == bai.cswjia then
            if v:FindFirstChild("SelectionBox") then
                v.SelectionBox:Destroy()
            end
        end
    end
end)

ItemTpGroup:AddToggle("BoxSelect", {
    Text = "框选物品",
    Default = false,
    Callback = function(Value)
        if Value then
            local ScreenGui = Instance.new("ScreenGui")
            local Frame = Instance.new("Frame")
            ScreenGui.Parent = game.CoreGui
            ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            Frame.Parent = ScreenGui
            Frame.BackgroundColor3 = Color3.fromRGB(4, 0, 255)
            Frame.BackgroundTransparency = 0.8
            Frame.BorderColor3 = Color3.new(0.09, 0.137, 0.776)
            Frame.BorderSizePixel = 2
            Frame.Position = UDim2.new(0, 0, 0, 0)
            Frame.Size = UDim2.new(0, 0, 0, 0)
            local function is_in_frame(screenpos, frame)
                local xPos = frame.AbsolutePosition.X
                local yPos = frame.AbsolutePosition.Y
                local xSize = frame.AbsoluteSize.X
                local ySize = frame.AbsoluteSize.Y
                local check1 = screenpos.X >= xPos and screenpos.X <= xPos + xSize
                local check2 = screenpos.X <= xPos and screenpos.X >= xPos + xSize
                local check3 = screenpos.Y >= yPos and screenpos.Y <= yPos + ySize
                local check4 = screenpos.Y <= yPos and screenpos.Y >= yPos + ySize
                return (check1 and check3) or (check2 and check3) or (check1 and check4) or (check2 and check4)
            end
            bai.kuangxiu = UserInputService.InputBegan:Connect(function(cilk)
                if cilk.UserInputType == Enum.UserInputType.MouseButton1 then
                    Frame.Visible = true
                    Frame.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y)
                    while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                        game:GetService("RunService").RenderStepped:wait()
                        Frame.Size = UDim2.new(0, Mouse.X, 0, Mouse.Y) - Frame.Position
                        for i, v in pairs(workspace.PlayerModels:GetChildren()) do
                            if bai.xzemuban == true and v:FindFirstChild("Owner") and tostring(v.Owner.Value) == bai.cswjia and v:FindFirstChild("WoodSection") then
                                local screenpos, visible = workspace.CurrentCamera:WorldToScreenPoint(v.WoodSection.CFrame.p)
                                if visible then
                                    if is_in_frame(screenpos, Frame) then
                                        if not v:FindFirstChild("SelectionBox") then
                                            local SB = Instance.new("SelectionBox", v)
                                            SB.Adornee = v
                                        end
                                    end
                                end
                            end
                            if v:FindFirstChild("Owner") and tostring(v.Owner.Value) == bai.cswjia and v:FindFirstChild("Main") then
                                local screenpos, visible = workspace.CurrentCamera:WorldToScreenPoint(v.Main.CFrame.p)
                                if visible then
                                    if is_in_frame(screenpos, Frame) then
                                        if not v:FindFirstChild("SelectionBox") then
                                            local SB = Instance.new("SelectionBox", v)
                                            SB.Adornee = v
                                        end
                                    end
                                end
                            end
                        end
                    end
                    Frame.Size = UDim2.new(0, 1, 0, 1)
                    Frame.Visible = false
                end
            end)
        else
            pcall(function()
                bai.kuangxiu:Disconnect()
                bai.kuangxiu = nil
            end)
            for _, gui in pairs(game.CoreGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui:FindFirstChild("Frame") then
                    gui:Destroy()
                end
            end
        end
    end,
})

ItemTpGroup:AddToggle("WithPlank", {
    Text = "带木板",
    Default = false,
    Callback = function(Value)
        bai.xzemuban = Value
    end,
})

ItemTpGroup:AddButton("开始传送选择的物品", function()
    task.spawn(function()
        if bai.itemset == nil then
            return Library:Notify({Title = "白", Description = "请你放传送点", Time = 4})
        end
        bai.cskais = true
        local OldPos = player.Character.HumanoidRootPart.CFrame
        for i, v in next, game:GetService("Workspace").PlayerModels:GetChildren() do
            if bai.cskais == false then break end
            if v:FindFirstChild("Owner") and tostring(v.Owner.Value) == bai.cswjia then
                if v:FindFirstChild("SelectionBox") then
                    if v:FindFirstChild("Main") then
                        if (lp.Character.HumanoidRootPart.CFrame.p - v.Main.CFrame.p).magnitude > 5 then
                            tp(v.Main.CFrame + Vector3.new(4, 0, 4))
                        end
                        for e = 1, 30 do
                            if bai.cskais == false then break end
                            game:GetService("ReplicatedStorage").Interaction.ClientIsDragging:FireServer(v)
                            v:PivotTo(bai.itemset)
                            game:GetService("ReplicatedStorage").Interaction.ClientIsDragging:FireServer(v)
                            game:GetService('RunService').Stepped:wait()
                        end
                        v.SelectionBox:Destroy()
                        game:GetService('RunService').Stepped:wait()
                    elseif v:FindFirstChild("WoodSection") then
                        tp(v.WoodSection.CFrame + Vector3.new(4, 0, 4))
                        for e = 1, 70 do
                            if bai.cskais == false then break end
                            game:GetService("ReplicatedStorage").Interaction.ClientIsDragging:FireServer(v)
                            v.WoodSection.CFrame = bai.itemset * CFrame.Angles(math.rad(90), 0, 90)
                            game:GetService("ReplicatedStorage").Interaction.ClientIsDragging:FireServer(v)
                            game:GetService('RunService').Stepped:wait()
                        end
                        v.SelectionBox:Destroy()
                        game:GetService('RunService').Stepped:wait()
                    end
                end
            end
        end
        tp(OldPos)
    end)
end)

ItemTpGroup:AddButton("停止", function()
    bai.cskais = false
end)

CarSpawnGroup:AddButton("获得选择工具", function()
    local Identify = Instance.new("Tool")
    Identify.RequiresHandle = false
    Identify.Name = "点击汽车重生垫"
    Identify.Parent = player.Backpack
    Identify.Activated:connect(function()
        if Mouse.Target and Mouse.Target.Parent.Type and Mouse.Target.Parent.Type.Value == "Vehicle Spot" then
            if not Mouse.Target.Parent:FindFirstChild("SelectionBox") then
                bai.car = Mouse.Target.Parent:FindFirstChild("ButtonRemote_SpawnButton", true)
                local SB = Instance.new("SelectionBox", Mouse.Target.Parent)
                SB.Adornee = Mouse.Target.Parent
            else
                Mouse.Target.Parent.SelectionBox:Destroy()
            end
            Library:Notify({Title = "白", Description = "汽车已选择", Time = 4})
        end
    end)
end)

CarSpawnGroup:AddButton("开始", function()
    task.spawn(function()
        local C = nil
        local FP = nil
        bai.stopcar = false
        local a = workspace.PlayerModels.ChildAdded:connect(function(v)
            v:WaitForChild("Owner")
            if v:WaitForChild("PaintParts") then
                FP = v.PaintParts.Part
            end
        end)
        if bai.car ~= nil then
            repeat
                task.wait(0.45)
                Press(bai.car)
                repeat wait() until FP ~= C
                C = FP
            until FP.BrickColor.Name == "Hot pink" or bai.stopcar == true
            a:Disconnect()
            a = nil
        else
            Library:Notify({Title = "白", Description = "你暂时没有选择汽车", Time = 4})
        end
    end)
end)

CarSpawnGroup:AddButton("停止", function()
    bai.stopcar = true
    bai.car = nil
    for i, v in next, game:GetService("Workspace").PlayerModels:GetChildren() do
        if v:FindFirstChild("SelectionBox") and v:FindFirstChild("ButtonRemote_SpawnButton", true) then
            v.SelectionBox:Destroy()
        end
    end
end)

OtherGroup:AddButton("获得4个小工具", function()
    if lp.Backpack:FindFirstChildOfClass 'HopperBin' then
        return
    end
    for index = 1, 4 do
        Instance.new('HopperBin', lp.Backpack).BinType = index
    end
end)

OtherGroup:AddToggle("RemoteOpen", {
    Text = "远程打开东西",
    Default = false,
    Callback = function(Value)
        if Value then
            Library:Notify({Title = '白', Description = '选择一个东西去打开', Time = 4})
            bai.openItem = mouse.Button1Down:Connect(function()
                if mouse.Target then
                    bai.itemtoopen = mouse.Target
                end
                OpenSelectedItem(bai.itemtoopen.Parent)
            end)
        else
            if bai.openItem then
                bai.openItem:Disconnect()
                bai.openItem = nil
            end
            Library:Notify({Title = '白', Description = '打开东西已关闭', Time = 4})
        end
    end,
})

OtherGroup:AddButton("获得小绿盒", function()
    local greenBox = game:GetService('Workspace')['Region_Volcano'].VolcanoWin
    firetouchinterest(greenBox, lp.Character.HumanoidRootPart, 0)
    firetouchinterest(greenBox, lp.Character.HumanoidRootPart, 1)
end)

OtherGroup:AddButton("生成上火山捷径", function()
    local Model = Instance.new("Model", workspace)
    Model.Name = "Lumber"
    local Part1 = Instance.new("Part", Model)
    Part1.Name = "Bridge"
    Part1.Reflectance = 0
    Part1.Transparency = 0
    Part1.Anchored = true
    Part1.Archivable = true
    Part1.CanCollide = true
    Part1.Locked = false
    Part1.BrickColor = BrickColor.new("Medium green")
    Part1.Material = Enum.Material.Fabric
    Part1.Position = Vector3.new(4380.8090820313, -11.749999046326, -101.56007385254)
    Part1.Size = Vector3.new(254.85998535156, 0.10000000149012, 1012.0200805664)
    Part1.Rotation = Vector3.new(0, 0, 0)
    local Part2 = Instance.new("Part", Model)
    Part2.Name = "Part"
    Part2.Reflectance = 0
    Part2.Transparency = 0
    Part2.Anchored = true
    Part2.Archivable = true
    Part2.CanCollide = true
    Part2.Locked = false
    Part2.BrickColor = BrickColor.new("Medium green")
    Part2.Material = Enum.Material.Fabric
    Part2.Position = Vector3.new(-1498.7203369141, 628.11077880859, 1146.8332519531)
    Part2.Size = Vector3.new(54.889999389648, 0.38999998569489, 46.719993591309)
    Part2.Rotation = Vector3.new(0, 30, 0)
    local Part3 = Instance.new("Part", Model)
    Part3.Name = "RoadVol"
    Part3.Reflectance = 0
    Part3.Transparency = 0
    Part3.Anchored = true
    Part3.Archivable = true
    Part3.CanCollide = true
    Part3.Locked = false
    Part3.BrickColor = BrickColor.new("Medium green")
    Part3.Material = Enum.Material.Fabric
    Part3.Position = Vector3.new(-604.03656005859, 301.07205200195, 637.69116210938)
    Part3.Size = Vector3.new(40, 0.20000000298023, 2030.8299560547)
    Part3.Rotation = Vector3.new(147.75, 55.680000305176, -152.4700012207)
    local WedgePart8 = Instance.new("WedgePart", Model)
    WedgePart8.Name = "UP"
    WedgePart8.Reflectance = 0
    WedgePart8.Transparency = 0
    WedgePart8.Anchored = true
    WedgePart8.Archivable = true
    WedgePart8.CanCollide = true
    WedgePart8.Locked = false
    WedgePart8.BrickColor = BrickColor.new("Beige")
    WedgePart8.Material = Enum.Material.Fabric
    WedgePart8.Position = Vector3.new(341.31372070313, -5.8850064277649, -772.25903320313)
    WedgePart8.Size = Vector3.new(65.220001220703, 11.829997062683, 159.52000427246)
    WedgePart8.Rotation = Vector3.new(0, -21.549999237061, 0)
    local WedgePart9 = Instance.new("WedgePart", Model)
    WedgePart9.Name = "UP2"
    WedgePart9.Reflectance = 0
    WedgePart9.Transparency = 0
    WedgePart9.Anchored = true
    WedgePart9.Archivable = true
    WedgePart9.CanCollide = true
    WedgePart9.Locked = false
    WedgePart9.BrickColor = BrickColor.new("Beige")
    WedgePart9.Material = Enum.Material.Fabric
    WedgePart9.Position = Vector3.new(384.87704467773, -5.8850121498108, -1050.4354248047)
    WedgePart9.Size = Vector3.new(65.220001220703, 11.829997062683, 155.8099822998)
    WedgePart9.Rotation = Vector3.new(180, -25.35000038147, 180)
    local WedgePart10 = Instance.new("WedgePart", Model)
    WedgePart10.Name = "Vol1"
    WedgePart10.Reflectance = 0
    WedgePart10.Transparency = 0
    WedgePart10.Anchored = true
    WedgePart10.Archivable = true
    WedgePart10.CanCollide = true
    WedgePart10.Locked = false
    WedgePart10.BrickColor = BrickColor.new("Medium green")
    WedgePart10.Material = Enum.Material.Fabric
    WedgePart10.Position = Vector3.new(-1133.5314941406, 499.67663574219, 943.49224853516)
    WedgePart10.Size = Vector3.new(39.729999542236, 10.650003433228, 823.29010009766)
    WedgePart10.Rotation = Vector3.new(-32.25, -55.680000305176, -27.529998779297)
    local WedgePart11 = Instance.new("WedgePart", Model)
    WedgePart11.Name = "Vol2"
    WedgePart11.Reflectance = 0
    WedgePart11.Transparency = 0
    WedgePart11.Anchored = true
    WedgePart11.Archivable = true
    WedgePart11.CanCollide = true
    WedgePart11.Locked = false
    WedgePart11.BrickColor = BrickColor.new("Medium green")
    WedgePart11.Material = Enum.Material.Fabric
    WedgePart11.Position = Vector3.new(-1526.9182128906, 623.2353515625, 1112.2694091797)
    WedgePart11.Size = Vector3.new(33.96000289917, 10.470000267029, 43.559997558594)
    WedgePart11.Rotation = Vector3.new(0, 32.899997711182, 0)
    local WedgePart12 = Instance.new("WedgePart", Model)
    WedgePart12.Name = "Wedge2"
    WedgePart12.Reflectance = 0
    WedgePart12.Transparency = 0
    WedgePart12.Anchored = true
    WedgePart12.Archivable = true
    WedgePart12.CanCollide = true
    WedgePart12.Locked = false
    WedgePart12.BrickColor = BrickColor.new("Medium green")
    WedgePart12.Material = Enum.Material.Fabric
    WedgePart12.Position = Vector3.new(-580.31176757813, 50.62678527832, -2443.0573730469)
    WedgePart12.Size = Vector3.new(58.749996185303, 1, 69.490005493164)
    WedgePart12.Rotation = Vector3.new(-179.08000183105, 14.309999465942, -178.72999572754)
    local WedgePart13 = Instance.new("WedgePart", Model)
    WedgePart13.Name = "Wedge"
    WedgePart13.Reflectance = 0
    WedgePart13.Transparency = 0
    WedgePart13.Anchored = true
    WedgePart13.Archivable = true
    WedgePart13.CanCollide = true
    WedgePart13.Locked = false
    WedgePart13.BrickColor = BrickColor.new("Medium green")
    WedgePart13.Material = Enum.Material.Fabric
    WedgePart13.Position = Vector3.new(-554.13073730469, 37.368190765381, -2545.1484375)
    WedgePart13.Size = Vector3.new(59.18998336792, 30.919998168945, 140.86001586914)
    WedgePart13.Rotation = Vector3.new(0.91999995708466, -14.309999465942, -1.2699999809265)
    local Part14 = Instance.new("Part", Model)
    Part14.Name = "Wall"
    Part14.Reflectance = 0
    Part14.Transparency = 0.60000002384186
    Part14.Anchored = false
    Part14.Archivable = true
    Part14.CanCollide = true
    Part14.Locked = false
    Part14.BrickColor = BrickColor.new("Medium stone grey")
    Part14.Material = Enum.Material.Fabric
    Part14.Position = Vector3.new(-1522.0369873047, 632.79083251953, 1160.2779541016)
    Part14.Size = Vector3.new(46.590003967285, 8.9700002670288, 1.0400000810623)
    Part14.Rotation = Vector3.new(-180, 60, -180)
    local Part15 = Instance.new("Part", Model)
    Part15.Name = "Fence2"
    Part15.Reflectance = 0
    Part15.Transparency = 0.5
    Part15.Anchored = true
    Part15.Archivable = true
    Part15.CanCollide = true
    Part15.Locked = false
    Part15.BrickColor = BrickColor.new("Beige")
    Part15.Material = Enum.Material.Fabric
    Part15.Position = Vector3.new(-620.37908935547, 319.05871582031, 669.19006347656)
    Part15.Size = Vector3.new(2037.669921875, 16.129999160767, 2)
    Part15.Rotation = Vector3.new(0.0099999997764826, 30, -17.510000228882)
    local Part16 = Instance.new("Part", Model)
    Part16.Name = "Fence"
    Part16.Reflectance = 0
    Part16.Transparency = 0.5
    Part16.Anchored = true
    Part16.Archivable = true
    Part16.CanCollide = true
    Part16.Locked = false
    Part16.BrickColor = BrickColor.new("Beige")
    Part16.Material = Enum.Material.Fabric
    Part16.Position = Vector3.new(-639.38134765625, 319.06237792969, 636.27484130859)
    Part16.Size = Vector3.new(2037.669921875, 16.129999160767, 2)
    Part16.Rotation = Vector3.new(0.0099999997764826, 30, -17.510000228882)
end)

OtherGroup:AddButton("生成去椰子岛捷径", function()
    local palm1 = Instance.new("Part", workspace)
    palm1.Name = "K Truck's Goin' There"
    palm1.Position = Vector3.new(1753.475, -10, -45.351)
    palm1.Size = Vector3.new(1600, 1, 50)
    palm1.BrickColor = BrickColor.Random()
    palm1.Anchored = true
    palm1.CanCollide = true
end)

OtherGroup:AddButton("沼泽捷径", function()
    local part = Instance.new("Part", workspace)
    part.CFrame = CFrame.new(-499.196075, 155.460663, -166.186081, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    part.Size = Vector3.new(295.87, 1, 40.14)
    local part2 = Instance.new("Part", workspace)
    part2.CFrame = CFrame.new(-53.5482712, 75.8732529, -166.035767, 0.965925813, 0.258819044, 0, -0.258819044, 0.965925813, 0, 0, 0, 1)
    part2.Size = Vector3.new(617.23, 0.72, 40)
    part2.Rotation = Vector3.new(0, 0, -15)
    part.BrickColor = BrickColor.new(255, 255, 255)
    part.Material = Enum.Material.DiamondPlate
    part.Anchored = true
    part2.BrickColor = BrickColor.new(255, 255, 255)
    part2.Material = Enum.Material.DiamondPlate
    part2.Anchored = true
end)

OtherGroup:AddButton("黄金木捷径", function()
    local f0 = Instance.new("Folder", workspace)
    f0.Name = "SGlowPath"
    local part = Instance.new("Part", f0)
    part.CFrame = CFrame.new(8.54199982, -0.914913177, -812.122375, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    part.Size = Vector3.new(55, 1, 186)
    local part = Instance.new("Part", f0)
    part.CFrame = CFrame.new(-309.958008, -0.834023476, -879.710388, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    part.Size = Vector3.new(582, 1, 50)
    local part = Instance.new("Part", f0)
    part.CFrame = CFrame.new(-606.630554, -0.843258381, -748.689453, 0.965925813, 0, -0.258819044, 0, 1, 0, 0.258819044, 0, 0.965925813)
    part.Size = Vector3.new(47, 1, 246)
    part.Rotation = Vector3.new(0, -15, 0)
    local part = Instance.new("Part", f0)
    part.CFrame = CFrame.new(-763.458679, -0.723966122, -652.31958, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    part.Size = Vector3.new(227, 1, 38)
    local part = Instance.new("Part", f0)
    part.CFrame = CFrame.new(-842.989868, -0.602809906, -713.690918, 0.965925872, 0, -0.258818835, 0, 1, 0, 0.258818835, 0, 0.965925872)
    part.Size = Vector3.new(43, 1, 108)
    part.Rotation = Vector3.new(0, -15, 0)
    local part = Instance.new("Part", f0)
    part.CFrame = CFrame.new(-775.692932, -0.588047981, -815.868713, 0.707106829, 0, -0.707106769, 0, 1, 0, 0.707106769, 0, 0.707106829)
    part.Size = Vector3.new(42, 1, 170)
    part.Rotation = Vector3.new(0, -45, 0)
    local part = Instance.new("Part", f0)
    part.CFrame = CFrame.new(-728.159668, -0.591278076, -952.04364, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    part.Size = Vector3.new(55, 1, 182)
    local part = Instance.new("Part", f0)
    part.CFrame = CFrame.new(-864.098999, -0.257263005, -985.877014, 0.965925872, 0, 0.258818835, 0, 1, 0, -0.258818835, 0, 0.965925872)
    part.Size = Vector3.new(235, 1, 56)
    part.Rotation = Vector3.new(0, 15, 0)
    local part = Instance.new("Part", f0)
    part.CFrame = CFrame.new(-1015.87311, -11.1293316, -945.632751, 0.933012664, -0.258819044, 0.25, 0.267445326, 0.963572919, -0.000555455685, -0.240749463, 0.0673795789, 0.968245745)
    part.Size = Vector3.new(82, 1, 55)
    part.Rotation = Vector3.new(0.03, 14.48, 15.51)
    for J, v in pairs(f0:children()) do
        v.BrickColor = BrickColor.new(255, 255, 255)
        v.Material = Enum.Material.DiamondPlate
        v.Anchored = true
    end
end)

OtherGroup:AddButton("冰木捷径", function()
    local f0 = Instance.new("Folder", workspace)
    f0.Name = "FrostPath"
    local part = Instance.new("Part", f0)
    part.CFrame = CFrame.new(744.516663, 71.5780411, 861.148438, 1, -1.04308164e-07, -1.78813934e-07, 1.47034342e-07, 0.965925932, 0.258818656, 1.45724101e-07, -0.258818656, 0.965925932)
    part.Size = Vector3.new(40, 1, 202)
    part.Rotation = Vector3.new(-15, 0, 0)
    local part = Instance.new("Part", f0)
    part.CFrame = CFrame.new(744.273, 97.5341, 1003.82)
    part.Size = Vector3.new(41, 1, 90)
    local part = Instance.new("Part", f0)
    part.CFrame = CFrame.new(775.181458, 100.246162, 1027.58276, 0.965925813, -0.258819044, 0, 0.258819044, 0.965925813, 0, 0, 0, 1)
    part.Size = Vector3.new(46, 1, 43)
    part.Rotation = Vector3.new(0, 0, 15)
    local part = Instance.new("Part", f0)
    part.CFrame = CFrame.new(815.776672, 106.550224, 1027.4032, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    part.Size = Vector3.new(38, 1, 42)
    local part = Instance.new("Part", f0)
    part.CFrame = CFrame.new(815.849976, 257.424072, 1608.79456, 1, 0, 0, 0, 0.965925813, 0.258819044, 0, -0.258819044, 0.965925813)
    part.Size = Vector3.new(38, 1, 1164)
    part.Rotation = Vector3.new(-15, 0, 0)
    local part = Instance.new("Part", f0)
    part.CFrame = CFrame.new(900.612122, 407.759827, 2194.72363, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    part.Size = Vector3.new(208, 1, 50)
    local part = Instance.new("Part", f0)
    part.CFrame = CFrame.new(1268.40649, 407.26062, 2798.83594, 0.91354543, 0, 0.406736642, 0, 1, 0, -0.406736642, 0, 0.91354543)
    part.Size = Vector3.new(41, 2, 1364)
    part.Rotation = Vector3.new(0, 24, 0)
    for J, v in pairs(f0:children()) do
        v.BrickColor = BrickColor.new(255, 255, 255)
        v.Material = Enum.Material.DiamondPlate
        v.Anchored = true
    end
end)

OtherGroup:AddButton("更简单砍幻影", function()
    local yellow1 = Instance.new("Part", workspace)
    yellow1.Name = "Lol Truck There Easy"
    yellow1.Position = Vector3.new(-5.915, -217, -1250.256)
    yellow1.Size = Vector3.new(1207.06, 1, 1160.09)
    yellow1.BrickColor = BrickColor.Random()
    yellow1.Anchored = true
    yellow1.CanCollide = true
end)

OtherGroup:AddButton("点击传送", function()
    local tool = Instance.new("Tool")
    tool.RequiresHandle = false
    tool.Name = "点击传送工具"
    tool.Activated:connect(function()
        local pos = mouse.Hit + Vector3.new(0, 2.5, 0)
        pos = CFrame.new(pos.X, pos.Y, pos.Z)
        player.Character.HumanoidRootPart.CFrame = pos
    end)
    tool.Parent = player.Backpack
end)

OtherGroup:AddButton("重进服务器", function()
    TeleportService:Teleport(13822889)
end)

ChatGroup:AddInput("SayMessage", {
    Text = "你要说的话",
    Default = "",
    Callback = function(Value)
        bai.saymege = Value
    end,
})

ChatGroup:AddInput("SayCount", {
    Text = "说话次数",
    Default = "1",
    Callback = function(Value)
        bai.saymount = tonumber(Value) or 1
    end,
})

ChatGroup:AddButton("说话", function()
    task.spawn(function()
        bai.sayfast = true
        for i = 1, bai.saymount do
            if bai.sayfast == true then
                game:GetService('ReplicatedStorage').DefaultChatSystemChatEvents.SayMessageRequest:FireServer(bai.saymege, 'All')
            end
        end
    end)
end)

ChatGroup:AddButton("停止说话", function()
    bai.sayfast = false
end)

ChatGroup:AddToggle("AutoSay", {
    Text = "全自动说话",
    Default = false,
    Callback = function(Value)
        bai.autosay = Value
        if Value then
            task.spawn(function()
                while task.wait() do
                    if bai.autosay == true then
                        game:GetService('ReplicatedStorage').DefaultChatSystemChatEvents.SayMessageRequest:FireServer(bai.saymege, 'All')
                    end
                end
            end)
        end
    end,
})

FunGroup:AddButton("拿出可口可乐", function()
    loadstring(game:HttpGet('https://pastebin.com/raw/BEgB0gEJ', true))()
end)

FunGroup:AddButton("变成警察", function()
    loadstring(game:HttpGet('https://pastebin.com/raw/8wB54iNk', true))()
end)

FunGroup:AddButton("出现悬浮板", function()
    loadstring(game:HttpGet('https://pastebin.com/raw/MrfVCM9y', true))()
end)

FunGroup:AddButton("托马斯小火车", function()
    loadstring(game:HttpGet(('http://pastebin.com/raw/tMr759X7'), true))()
end)

FunGroup:AddButton("圆球", function()
    loadstring(game:HttpGet(('https://pastebin.com/raw/ZFSTSi9B'), true))()
end)

FunGroup:AddButton("喷漆", function()
    loadstring(game:HttpGet(('http://pastebin.com/raw/raYkCjyy'), true))()
end)

FunGroup:AddButton("安全自杀", function()
    pcall(function()
        lp.Character.Head:Destroy()
    end)
end)

PlankSortGroup:AddDropdown("SortPlayer", {
    Text = "选择玩家",
    Default = 1,
    Values = bai.dropdown,
    Callback = function(Value)
        bai.mtwjia = bai.dropdown[Value]
    end,
})

PlankSortGroup:AddButton("重置玩家名称", function()
    shuaxinlb(true)
    Options.SortPlayer:SetValues(bai.dropdown)
end)

local plankTreeTypes = {"普通树", "沼泽黄金", "樱花", "蓝木", "冰木", "火山木", "橡木", "巧克力木", "白桦木", "黄金木", "雪地松", "僵尸木", "大巧克力树", "椰子树", "幻影", "幽灵木", "南瓜木"}
local plankTreeMap = {
    ["普通树"] = "Generic", ["沼泽黄金"] = "GoldSwampy", ["樱花"] = "Cherry", ["蓝木"] = "CaveCrawler",
    ["冰木"] = "Frost", ["火山木"] = "Volcano", ["橡木"] = "Oak", ["巧克力木"] = "Walnut",
    ["白桦木"] = "Birch", ["黄金木"] = "SnowGlow", ["雪地松"] = "Pine", ["僵尸木"] = "GreenSwampy",
    ["大巧克力树"] = "Koa", ["椰子树"] = "Palm", ["幻影"] = "LoneCave", ["幽灵木"] = "Spooky", ["南瓜木"] = "SpookyNeon"
}

PlankSortGroup:AddDropdown("SortTreeType", {
    Text = "选择木头类型",
    Default = 1,
    Values = plankTreeTypes,
    Callback = function(Value)
        bai.zlmt = plankTreeMap[plankTreeTypes[Value]]
    end,
})

PlankSortGroup:AddToggle("SortVertical", {
    Text = "竖着整理",
    Default = false,
    Callback = function(Value)
        bai.shuzhe = Value
    end,
})

PlankSortGroup:AddButton("开始整理", function()
    task.spawn(function()
        if bai.zlmt == nil then
            return Library:Notify({Title = "白", Description = "你没有选择木头", Time = 4})
        end
        if bai.shuzhe == false then
            local oldpos = lp.Character.HumanoidRootPart.Position
            for _, Plank in pairs(game.Workspace.PlayerModels:GetChildren()) do
                if Plank.Name == "Plank" and Plank:findFirstChild("Owner") then
                    if Plank:FindFirstChild("Owner") and tostring(Plank.Owner.Value) == bai.mtwjia then
                        if Plank.TreeClass.Value == bai.zlmt then
                            tp(Plank.WoodSection.CFrame)
                            for i = 1, 50 do
                                game:GetService("ReplicatedStorage").Interaction.ClientIsDragging:FireServer(Plank)
                                Plank.WoodSection.Position = oldpos
                                game:GetService("ReplicatedStorage").Interaction.ClientIsDragging:FireServer(Plank)
                                game:GetService('RunService').Stepped:wait()
                            end
                        end
                    end
                end
            end
        else
            local oldpos = lp.Character.HumanoidRootPart.CFrame
            for _, Plank in pairs(game.Workspace.PlayerModels:GetChildren()) do
                if Plank.Name == "Plank" and Plank:findFirstChild("Owner") then
                    if Plank:FindFirstChild("Owner") and tostring(Plank.Owner.Value) == bai.mtwjia then
                        if Plank.TreeClass.Value == bai.zlmt then
                            tp(Plank.WoodSection.CFrame)
                            for i = 1, 50 do
                                game:GetService("ReplicatedStorage").Interaction.ClientIsDragging:FireServer(Plank)
                                Plank.WoodSection.CFrame = oldpos
                                game:GetService("ReplicatedStorage").Interaction.ClientIsDragging:FireServer(Plank)
                                game:GetService('RunService').Stepped:wait()
                            end
                        end
                    end
                end
            end
        end
    end)
end)

StackGroup:AddDropdown("StackPlayer", {
    Text = "选择玩家",
    Default = 1,
    Values = bai.dropdown,
    Callback = function(Value)
        bai.zlwjia = bai.dropdown[Value]
    end,
})

StackGroup:AddButton("重置玩家名称", function()
    shuaxinlb(true)
    Options.StackPlayer:SetValues(bai.dropdown)
end)

StackGroup:AddInput("StackX", {
    Text = "x轴",
    Default = "1",
    Callback = function(Value)
        bai.zix = tonumber(Value) or 1
    end,
})

StackGroup:AddInput("StackZ", {
    Text = "z轴",
    Default = "3",
    Callback = function(Value)
        bai.zlz = tonumber(Value) or 3
    end,
})

StackGroup:AddButton("获取整理工具", function()
    local Identify = Instance.new("Tool")
    Identify.RequiresHandle = false
    Identify.Name = "点击要整理的物品"
    Identify.Activated:connect(function()
        local Player = player.Character.HumanoidRootPart.Position - Vector3.new(0, 4, 0)
        local Items = {}
        if mouse.Target.Parent:FindFirstChild("PurchasedBoxItemName") then
            bai.dxmz = mouse.Target.Parent.PurchasedBoxItemName.Value
            function ItemStacker(ItemType, XAxis, ZAxis)
                for i, v in pairs(game:GetService("Workspace").PlayerModels:GetChildren()) do
                    if v:FindFirstChild("Owner") and tostring(v.Owner.Value) == bai.zlwjia then
                        if v:FindFirstChild("PurchasedBoxItemName") and tostring(v.PurchasedBoxItemName.Value) == ItemType then
                            table.insert(Items, v)
                        end
                    end
                end
                local Count = 0
                for Y = 1, math.ceil(#Items / (XAxis * ZAxis)) do
                    for X = 1, XAxis do
                        for Z = 1, ZAxis do
                            Count = Count + 1
                            tp(Items[Count].Main.CFrame + Vector3.new(3, 0, 3))
                            for e = 1, 40 do
                                game:GetService("ReplicatedStorage").Interaction.ClientIsDragging:FireServer(Items[Count])
                                Items[Count].Main.CFrame = CFrame.new(X * Items[1].Main.Size.X, Y * Items[1].Main.Size.Y, Z * Items[1].Main.Size.Z) + Player
                                game:GetService("ReplicatedStorage").Interaction.ClientIsDragging:FireServer(Items[Count])
                                game:GetService('RunService').Stepped:wait()
                            end
                        end
                    end
                end
            end
            ItemStacker(bai.dxmz, bai.zlz, bai.zix)
            Library:Notify({Title = '', Description = '' .. mouse.Target.Parent.PurchasedBoxItemName.Value, Time = 5})
        elseif mouse.Target.Parent:FindFirstChild("ItemName") then
            bai.dxmz = mouse.Target.Parent.ItemName.Value
            local Player = player.Character.HumanoidRootPart.Position - Vector3.new(0, 5.5, 0)
            function ItemStackerft(ItemType, XAxis, ZAxis)
                for i, v in pairs(game:GetService("Workspace").PlayerModels:GetChildren()) do
                    if v:FindFirstChild("Owner") and tostring(v.Owner.Value) == bai.zlwjia then
                        if (v:FindFirstChild 'DraggableItem' and tostring(v.DraggableItem.Parent) == ItemType) then
                            table.insert(Items, v)
                        end
                    end
                end
                local Count = 0
                for Y = 1, math.ceil(#Items / (XAxis * ZAxis)) do
                    for X = 1, XAxis do
                        for Z = 1, ZAxis do
                            Count = Count + 1
                            tp(Items[Count].Main.CFrame + Vector3.new(3, 0, 3))
                            for e = 1, 40 do
                                game:GetService("ReplicatedStorage").Interaction.ClientIsDragging:FireServer(Items[Count])
                                Items[Count].Main.CFrame = CFrame.new(X * Items[1].Main.Size.X, Y * Items[1].Main.Size.Y, Z * Items[1].Main.Size.Z) + Player
                                game:GetService("ReplicatedStorage").Interaction.ClientIsDragging:FireServer(Items[Count])
                                game:GetService('RunService').Stepped:wait()
                            end
                        end
                    end
                end
            end
            ItemStackerft(bai.dxmz, bai.zlz, bai.zix)
            Library:Notify({Title = '', Description = '' .. mouse.Target.Parent.ItemName.Value, Time = 5})
        end
    end)
    Identify.Parent = player.Backpack
end)

BlueprintGroup:AddDropdown("BlueprintTree", {
    Text = "选择木头类型",
    Default = 1,
    Values = treeTypes,
    Callback = function(Value)
        bai.tchonmt = treeTypeMap[treeTypes[Value]]
    end,
})

BlueprintGroup:AddButton("填充蓝图木头", function()
    task.spawn(function()
        local plr = player
        local tool = Instance.new("Tool", plr.Backpack)
        tool.RequiresHandle = false
        tool.Name = "点击一块蓝图"
        tool.Activated:Connect(function()
            local str = getMouseTarget().Parent
            if str:FindFirstChild("Type") and str.Type.Value == "Blueprint" and str:FindFirstChild("Owner") then
                lumbsmasher_legitpaint(bai.tchonmt, str, true)
            end
        end)
    end)
end)

BlueprintGroup:AddButton("填充蓝图全部", function()
    task.spawn(function()
        for i, v in pairs(game.Workspace.PlayerModels:GetChildren()) do
            if v:FindFirstChild("Type") and v.Type.Value == "Blueprint" and v:FindFirstChild("Owner") then
                if v.Owner.Value == lp then
                    lumbsmasher_legitpaint(bai.tchonmt, v, true)
                    task.wait()
                end
            end
        end
    end)
end)

EnvGroup:AddToggle("AlwaysDay", {
    Text = "终日白天",
    Default = false,
    Callback = function(Value)
        bai.awaysday = Value
        if Value then
            task.spawn(function()
                while task.wait() do
                    if bai.awaysday == true then
                        game:GetService('Lighting').TimeOfDay = '12:00:00'
                    end
                end
            end)
        end
    end,
})

EnvGroup:AddToggle("AlwaysNight", {
    Text = "终日黑天",
    Default = false,
    Callback = function(Value)
        bai.awaysdnight = Value
        if Value then
            task.spawn(function()
                while task.wait() do
                    if bai.awaysdnight == true then
                        game:GetService('Lighting').TimeOfDay = '2:00:00'
                    end
                end
            end)
        end
    end,
})

EnvGroup:AddToggle("NoShadows", {
    Text = "消除阴影",
    Default = false,
    Callback = function(Value)
        game:GetService("Lighting").GlobalShadows = not Value
    end,
})

EnvGroup:AddButton("圣诞节地图", function()
    for i, v in pairs(game:GetService("Workspace"):GetDescendants()) do
        if v.Name == "Ground" then
            v.BrickColor = BrickColor.new("White")
            v.Material = "Sand"
        end
        if v.Name == "Slate" then
            v.BrickColor = BrickColor.new("White")
        end
        if v.Name == "LeafPart" then
            v.BrickColor = BrickColor.new("White")
            v.Material = "Sand"
        end
        if v.Name == "Sand" then
            v.BrickColor = BrickColor.new("White")
        end
    end
end)

EnvGroup:AddButton("秋天地图", function()
    for i, v in pairs(game:GetService("Workspace"):GetDescendants()) do
        if v.Name == "Ground" then
            v.BrickColor = BrickColor.new("Burnt Sienna")
            v.Material = "Sand"
        end
        if v.Name == "Slate" then
            v.BrickColor = BrickColor.new("Burnt Sienna")
        end
        if v.Name == "LeafPart" then
            v.BrickColor = BrickColor.new("Burnt Sienna")
            v.Material = "Sand"
        end
    end
end)

EnvGroup:AddButton("万圣节地图", function()
    loadstring(game:HttpGet 'https://raw.githubusercontent.com/silentben8x/Silent/main/Halloween')()
end)

EnvGroup:AddButton("糖果地图", function()
    loadstring(game:HttpGet 'https://raw.githubusercontent.com/silentben9x/silentwinningmain/main/Willy%20Wonker%20Map%20Theme')()
end)

EnvGroup:AddButton("删除灵视神殿石头", function()
    pcall(function()
        workspace.Region_Mountainside.BoulderRegen.Boulder:Destroy()
        workspace.Region_Mountainside.Door.Door:Destroy()
    end)
end)

EnvGroup:AddToggle("NoLava", {
    Text = "删除岩浆",
    Default = false,
    Callback = function(Value)
        for i, v in pairs(game.Workspace.Region_Volcano:GetDescendants()) do
            if v.Name == "TouchInterest" then
                v:Destroy()
            elseif v.Name == "Lava" then
                for n, k in pairs(v:GetChildren()) do
                    if k:IsA("Part") then
                        if Value == true then
                            k.Transparency = 1
                        else
                            k.Transparency = 0
                        end
                    end
                end
            end
        end
    end,
})

EnvGroup:AddToggle("NoWater", {
    Text = "删除水",
    Default = false,
    Callback = function(Value)
        for _, v in pairs(game.Workspace.Water:GetChildren()) do
            if v.Name == "Water" then
                if Value then
                    v.Transparency = 1
                else
                    v.Transparency = 0
                end
            end
        end
    end,
})

EnvGroup:AddToggle("WaterWalk", {
    Text = "水上行走",
    Default = false,
    Callback = function(Value)
        for i, v in next, game.workspace.Water:children() do
            if v.ClassName == 'Part' then
                bai.waterwalk, v.CanCollide = Value, Value
            end
        end
        for i, v in next, game:GetService('Workspace').Bridge.VerticalLiftBridge.WaterModel:children() do
            if v:IsA('BasePart') then
                v.CanCollide = Value
            end
        end
    end,
})

EnvGroup:AddToggle("LowerBridge", {
    Text = "放下桥",
    Default = false,
    Callback = function(Value)
        if Value then
            lowerBridge("Lower")
        else
            lowerBridge("Higher")
        end
    end,
})

EnvGroup:AddButton("删除火山石头", function()
    for i, v in pairs(workspace["Region_Volcano"]:children()) do
        if v.Name == "PartSpawner" then
            v.Parent = game.Lighting
        end
    end
end)

EnvGroup:AddButton("删除雪山石头", function()
    for i, v in pairs(workspace["Region_Snow"]:children()) do
        if v.Name == "PartSpawner" then
            v.Parent = game.Lighting
        end
    end
end)

EnvGroup:AddButton("启动所有压力板", function()
    burnAllShopItems()
end)

EnvGroup:AddButton("船离开时间", function()
    if game.Workspace.Ferry.TimeToDeparture.Value == 0 then
        Library:Notify({Title = "白", Description = "船已离开", Time = 4})
    else
        Library:Notify({Title = "白", Description = "距离船离开时间有" .. game.Workspace.Ferry.TimeToDeparture.Value .. "秒", Time = 4})
    end
end)

EnvGroup:AddButton("桥上升时间", function()
    if game.Workspace.Bridge.DownTime.Value < 0 then
        Library:Notify({Title = "白", Description = "桥已上升", Time = 4})
    else
        Library:Notify({Title = "白", Description = "距离桥上升的时间有" .. game.Workspace.Bridge.DownTime.Value .. "秒", Time = 4})
    end
end)

EnvGroup:AddButton("查看游戏时间", function()
    Library:Notify({Title = "白", Description = "游戏时间为" .. tostring(game.Lighting.TimeOfDay):sub(1, -2):sub(1, -2):sub(1, -2), Time = 4})
end)

EnvGroup:AddInput("CustomBrightness", {
    Text = "自定义亮度",
    Default = "10",
    Callback = function(Value)
        local num = tonumber(Value) or 10
        game:GetService("Lighting").Brightness = num / 10
    end,
})

EnvGroup:AddButton("提高画质", function()
    local light = game.Lighting
    for i, v in pairs(light:GetChildren()) do
        v:Destroy()
    end
    local ter = workspace.Terrain
    local color = Instance.new("ColorCorrectionEffect")
    local bloom = Instance.new("BloomEffect")
    local sun = Instance.new("SunRaysEffect")
    local blur = Instance.new("BlurEffect")
    color.Parent = light
    bloom.Parent = light
    sun.Parent = light
    blur.Parent = light
    color.Enabled = false
    color.Contrast = 0.15
    color.Brightness = 0.1
    color.Saturation = 0.25
    color.TintColor = Color3.fromRGB(255, 222, 211)
    bloom.Enabled = false
    bloom.Intensity = 0.1
    sun.Enabled = false
    sun.Intensity = 0.2
    sun.Spread = 1
    bloom.Enabled = false
    bloom.Intensity = 0.05
    bloom.Size = 32
    bloom.Threshold = 1
    blur.Enabled = false
    blur.Size = 6
    color.Enabled = true
    sun.Enabled = true
    ter.WaterColor = Color3.fromRGB(10, 10, 24)
    ter.WaterWaveSize = 0.1
    ter.WaterWaveSpeed = 22
    ter.WaterTransparency = 0.9
    ter.WaterReflectance = 0.05
    light.Ambient = Color3.fromRGB(0, 0, 0)
    light.Brightness = 4
    light.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
    light.ColorShift_Top = Color3.fromRGB(0, 0, 0)
    light.ExposureCompensation = 0
    light.FogColor = Color3.fromRGB(132, 132, 132)
    light.GlobalShadows = true
    light.OutdoorAmbient = Color3.fromRGB(112, 117, 128)
    light.Outlines = false
end)

EnvGroup:AddButton("高清地图", function()
    _G.BlurSize = 3
    _G.ColorCorrectionBrightness = 0.03
    _G.ColorCorrectionContrast = 0.3
    _G.ColorCorrectionSaturation = 0.01
    _G.ColorCorrectionTintColor = Color3.fromRGB(244, 244, 244)
    _G.SunRaysIntensity = 0.2
    _G.SunRaysSpread = 1
    _G.GlobalShadows = true
    _G.Brightness = 0.9
    _G.GeographicLatitude = 350
    _G.TimeOfDay = 17
    _G.ExposureCompensation = 0.03
    spawn(function()
        _, i = pcall(function()
            local Lighting = game:GetService("Lighting")
            local Blur = Instance.new("BlurEffect", Lighting)
            local Color = Instance.new("ColorCorrectionEffect", Lighting)
            local Sun = Instance.new("SunRaysEffect", Lighting)
            Blur.Enabled = true
            Blur.Size = _G.BlurSize
            Color.Enabled = true
            Color.Brightness = _G.ColorCorrectionBrightness
            Color.Contrast = _G.ColorCorrectionContrast
            Color.Saturation = _G.ColorCorrectionSaturation
            Color.TintColor = _G.ColorCorrectionTintColor
            Sun.Enabled = true
            Sun.Intensity = _G.SunRaysIntensity
            Sun.Spread = _G.SunRaysSpread
            function loadLighting()
                Lighting.GlobalShadows = _G.GlobalShadows
                Lighting.Brightness = _G.Brightness
                Lighting.GeographicLatitude = _G.GeographicLatitude
                Lighting.TimeOfDay = _G.TimeOfDay
                Lighting.ExposureCompensation = _G.ExposureCompensation
            end
            loadLighting()
        end)
    end)
end)

EnvGroup:AddButton("开关家具店门", function()
    pcall(function()
        game:GetService('ReplicatedStorage').Interaction.RemoteProxy:FireServer(workspace.Stores.FurnitureStore.LDoor.ButtonRemote_Toggle)
        wait(0.5)
        game:GetService('ReplicatedStorage').Interaction.RemoteProxy:FireServer(workspace.Stores.FurnitureStore.RDoor.ButtonRemote_Toggle)
    end)
end)

EnvGroup:AddButton("删除迷宫门", function()
    for i = 0, 7 do
        spawn(function()
            pcall(function()
                local door = game:GetService('Workspace')['Region_MazeCave'].Blockade['Blockade' .. i]
                if door then door:Destroy() end
            end)
        end)
    end
end)

EnvGroup:AddButton("打开鲨鱼斧合成门", function()
    pcall(function()
        game:GetService('ReplicatedStorage').Interaction.RemoteProxy:FireServer(workspace.Region_Snow.Den.Hatch.ButtonRemote_Hinge)
    end)
end)

EnvGroup:AddButton("删除鲨鱼斧合成门", function()
    pcall(function()
        local door = game:GetService('Workspace')['Region_Snow'].Den.Hatch
        if door then door:Destroy() end
    end)
end)

EnvGroup:AddButton("开关连锁逻辑店门", function()
    pcall(function()
        game:GetService('ReplicatedStorage').Interaction.RemoteProxy:FireServer(workspace.Stores.LogicStore.LDoor.ButtonRemote_Toggle)
        wait(0.5)
        game:GetService('ReplicatedStorage').Interaction.RemoteProxy:FireServer(workspace.Stores.LogicStore.RDoor.ButtonRemote_Toggle)
    end)
end)

EnvGroup:AddButton("开关盒子车行门", function()
    pcall(function()
        game:GetService('ReplicatedStorage').Interaction.RemoteProxy:FireServer(workspace.Stores.CarStore.LDoor.ButtonRemote_Toggle)
        wait(0.5)
        game:GetService('ReplicatedStorage').Interaction.RemoteProxy:FireServer(workspace.Stores.CarStore.RDoor.ButtonRemote_Toggle)
    end)
end)

EnvGroup:AddButton("带来沼泽桥", function()
    task.spawn(function()
        local oldPos = lp.Character.HumanoidRootPart.CFrame
        local slab = game:GetService('Workspace')['Region_Mountainside'].SlabRegen:FindFirstChild('Slab')
        if slab and not slab.PrimaryPart then
            slab.PrimaryPart = slab.PushMe
        end
        tp(CFrame.new(slab.PrimaryPart.CFrame.p))
        wait(.2)
        spawn(function()
            for i = 1, 100 do
                slab:SetPrimaryPartCFrame(CFrame.new(oldPos.p))
                game:GetService('ReplicatedStorage').Interaction.ClientIsDragging:FireServer(slab)
                task.wait()
            end
        end)
        wait(1)
        tp(CFrame.new(oldPos.p))
    end)
end)

DevilGroup:AddDropdown("DevilPlayer", {
    Text = "选择玩家",
    Default = 1,
    Values = bai.dropdown,
    Callback = function(Value)
        bai.playernamedied = bai.dropdown[Value]
    end,
})

DevilGroup:AddButton("刷新列表", function()
    shuaxinlb(true)
    Options.DevilPlayer:SetValues(bai.dropdown)
end)

DevilGroup:AddButton("传送到玩家旁边", function()
    task.spawn(function()
        local HumRoot = player.Character.HumanoidRootPart
        local tp_player = Players[bai.playernamedied]
        if tp_player then
            for i = 1, 5 do
                wait()
                HumRoot.CFrame = tp_player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end)
end)

DevilGroup:AddButton("传送到玩家基地", function()
    task.spawn(function()
        local ME = player.Character.HumanoidRootPart
        for i, v in pairs(game.Workspace.Properties:GetChildren()) do
            if v.Owner.Value == Players[bai.playernamedied] then
                ME.CFrame = v.OriginSquare.CFrame + Vector3.new(0, 10, 0)
            end
        end
    end)
end)

DevilGroup:AddButton("汽车传送到玩家旁边", function()
    task.spawn(function()
        local tp_player = Players[bai.playernamedied]
        if tp_player then
            carTeleport(tp_player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0))
        end
    end)
end)

DevilGroup:AddButton("汽车传送到玩家基地", function()
    task.spawn(function()
        for i, v in pairs(game.Workspace.Properties:GetChildren()) do
            if v.Owner.Value == Players[bai.playernamedied] then
                carTeleport(v.OriginSquare.CFrame + Vector3.new(0, 10, 0))
            end
        end
    end)
end)

DevilGroup:AddButton("汽车踢人", function()
    task.spawn(function()
        local ME = player.Character.HumanoidRootPart
        local function callback(Text)
            if Text == "确定" then
                for i, v in pairs(game:GetService("Workspace").PlayerModels:GetChildren()) do
                    if v.Name == "Model" and v:FindFirstChild("DriveSeat") and v:FindFirstChild("ItemName") then
                        if v.ItemName.Value == "UtilityTruck_Vehicle" then
                            if v.Owner.OwnerString.Value == tostring(player) then
                                local Car = v
                                Car.DriveSeat:Sit(player.Character.Humanoid)
                                wait(0.5)
                                Car.PrimaryPart = v.Seat
                            end
                        end
                    end
                end
                spawn(function()
                    if not lp.Character.Humanoid.SeatPart then
                        return
                    end
                    if not Players[bai.playernamedied].Character.Humanoid.SeatPart then
                        repeat
                            task.wait()
                            carTeleport(Players[bai.playernamedied].Character.HumanoidRootPart.CFrame + Vector3.new(0, -2, 0))
                        until Players[bai.playernamedied].Character.Humanoid.SeatPart
                    end
                    while task.wait() do
                        for i, v in pairs(game.Workspace.Properties:GetChildren()) do
                            if v.Owner.Value == player then
                                carTeleport(v.OriginSquare.CFrame + Vector3.new(0, 10, 0))
                            end
                        end
                    end
                end)
            end
        end
        local NotificationBindable = Instance.new("BindableFunction")
        NotificationBindable.OnInvoke = callback
        game.StarterGui:SetCore("SendNotification", {
            Title = "白",
            Text = "使用此功能前请自己拉黑他,然后再打开让他可以坐副驾驶的功能",
            Icon = "",
            Duration = 5,
            Button1 = "确定",
            Button2 = "取消",
            Callback = NotificationBindable
        })
    end)
end)

DevilGroup:AddButton("斧头杀人", function()
    task.spawn(function()
        local tool = getTool()
        if not tool then
            return Library:Notify({Title = "白", Description = "你需要斧头", Time = 4})
        end
        local KillPlayer = bai.playernamedied
        local Player = gplr(KillPlayer)
        if Player[1] then
            Player = Player[1]
            local LocalPlayer = player
            if LocalPlayer.Character.PrimaryPart ~= nil then
                local Character = LocalPlayer.Character
                local previous = LocalPlayer.Character.PrimaryPart.CFrame
                Character.Archivable = true
                local Clone = Character:Clone()
                LocalPlayer.Character = Clone
                wait(0.5)
                LocalPlayer.Character = Character
                wait(0.2)
                if LocalPlayer.Character and Player.Character and Player.Character.PrimaryPart ~= nil then
                    if LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):Destroy()
                    end
                    local Humanoid = Instance.new("Humanoid")
                    Humanoid.Parent = LocalPlayer.Character
                    local Tool = nil
                    if LocalPlayer.Character:FindFirstChildOfClass("Tool") then
                        Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    elseif LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChildOfClass("Tool") then
                        Tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                    end
                    if Tool ~= nil then
                        Tool.Parent = LocalPlayer.Backpack
                        Player.Character.HumanoidRootPart.Anchored = true
                        local Arm = game.Players.LocalPlayer.Character['Right Arm'].CFrame * CFrame.new(0, -1, 0, 1, 0, 0, 0, 0, 1, 0, -1, 0)
                        Tool.Grip = Arm:ToObjectSpace(Player.Character.PrimaryPart.CFrame):Inverse()
                        Tool.Parent = LocalPlayer.Character
                        Workspace.CurrentCamera.CameraSubject = Tool.Handle
                        repeat
                            wait()
                        until not Tool or Tool and (Tool.Parent == Workspace or Tool.Parent == Player.Character)
                        Player.Character.HumanoidRootPart.Anchored = false
                        wait(0.1)
                        Humanoid.Health = 0
                        LocalPlayer.Character = nil
                    end
                end
                spawn(function()
                    LocalPlayer.CharacterAdded:Wait()
                    Player.Character.HumanoidRootPart.Anchored = false
                    if Player.Character.Humanoid.Health <= 15 then
                        Library:Notify({Title = "白", Description = "成功", Time = 4})
                        repeat
                            wait()
                        until LocalPlayer.Character.PrimaryPart ~= nil
                        wait(0.4)
                        LocalPlayer.Character:SetPrimaryPartCFrame(previous)
                    end
                end)
            end
        end
    end)
end)

DevilGroup:AddButton("斧头带人", function()
    task.spawn(function()
        local Target = bai.playernamedied
        local tool = getTool()
        if not tool then
            return Library:Notify({Title = "白", Description = "你需要斧头", Time = 4})
        end
        local NOW = player.Character.HumanoidRootPart.CFrame
        player.Character.Humanoid.Name = 1
        local l = player.Character["1"]:Clone()
        l.Parent = player.Character
        l.Name = "Humanoid"
        wait(0.1)
        player.Character["1"]:Destroy()
        workspace.CurrentCamera.CameraSubject = player.Character
        player.Character.Animate.Disabled = true
        wait(1.1)
        player.Character.Animate.Disabled = false
        player.Character.Humanoid.DisplayDistanceType = "None"
        for i, v in pairs(game:GetService 'Players'.LocalPlayer.Backpack:GetChildren()) do
            if v.Name:sub(1, 4) == "Tool" then
                player.Character.Humanoid:EquipTool(v)
            end
        end
        local function tp2(player1, player2)
            local char1, char2 = player1.Character, player2.Character
            if char1 and char2 then
                char1.HumanoidRootPart.CFrame = char2.HumanoidRootPart.CFrame
            end
        end
        local function getout(player1, player2)
            local char1, char2 = player1.Character, player2.Character
            if char1 and char2 then
                char1:MoveTo(char2.Head.Position)
            end
        end
        tp2(Players[Target], player)
        wait(0.1)
        tp2(Players[Target], player)
        wait(0.3)
        tp2(Players[Target], player)
        wait(0.3)
        for i = 1, 60 do
            getout(player, Players[Target])
            player.Character.HumanoidRootPart.CFrame = NOW
            task.wait(.1)
        end
    end)
end)

DevilGroup:AddButton("岩浆杀人", function()
    task.spawn(function()
        local tool = getTool()
        if not tool then
            return Library:Notify({Title = "白", Description = "你需要斧头", Time = 4})
        end
        local Target = bai.playernamedied
        local NOW = CFrame.new(-1685, 200, 1216)
        player.Character.Humanoid.Name = 1
        local l = player.Character["1"]:Clone()
        l.Parent = player.Character
        l.Name = "Humanoid"
        wait(0.1)
        player.Character["1"]:Destroy()
        workspace.CurrentCamera.CameraSubject = player.Character
        player.Character.Animate.Disabled = true
        wait(1.1)
        player.Character.Animate.Disabled = false
        player.Character.Humanoid.DisplayDistanceType = "None"
        for i, v in pairs(game:GetService 'Players'.LocalPlayer.Backpack:GetChildren()) do
            if v.Name:sub(1, 4) == "Tool" then
                player.Character.Humanoid:EquipTool(v)
            end
        end
        local function tp2(player1, player2)
            local char1, char2 = player1.Character, player2.Character
            if char1 and char2 then
                char1.HumanoidRootPart.CFrame = char2.HumanoidRootPart.CFrame
            end
        end
        local function getout(player1, player2)
            local char1, char2 = player1.Character, player2.Character
            if char1 and char2 then
                char1:MoveTo(char2.Head.Position)
            end
        end
        player.Character.HumanoidRootPart.CFrame = NOW
        wait(0.1)
        tp2(Players[Target], player)
        wait(0.1)
        tp2(Players[Target], player)
        wait(0.3)
        tp2(Players[Target], player)
        for i = 1, 20 do
            getout(player, Players[Target])
            player.Character.HumanoidRootPart.CFrame = NOW
        end
    end)
end)

DevilGroup:AddButton("虚空搞人", function()
    task.spawn(function()
        local tool = getTool()
        if not tool then
            return Library:Notify({Title = "白", Description = "你需要斧头", Time = 4})
        end
        local Target = bai.playernamedied
        local NOW = CFrame.new(9e9, 9e9, 9e9)
        player.Character.Humanoid.Name = 1
        local l = player.Character["1"]:Clone()
        l.Parent = player.Character
        l.Name = "Humanoid"
        wait(0.1)
        player.Character["1"]:Destroy()
        workspace.CurrentCamera.CameraSubject = player.Character
        player.Character.Animate.Disabled = true
        wait(1.1)
        player.Character.Animate.Disabled = false
        player.Character.Humanoid.DisplayDistanceType = "None"
        for i, v in pairs(game:GetService 'Players'.LocalPlayer.Backpack:GetChildren()) do
            if v.Name:sub(1, 4) == "Tool" then
                player.Character.Humanoid:EquipTool(v)
            end
        end
        local function tp2(player1, player2)
            local char1, char2 = player1.Character, player2.Character
            if char1 and char2 then
                char1.HumanoidRootPart.CFrame = char2.HumanoidRootPart.CFrame
            end
        end
        local function getout(player1, player2)
            local char1, char2 = player1.Character, player2.Character
            if char1 and char2 then
                char1:MoveTo(char2.Head.Position)
            end
        end
        player.Character.HumanoidRootPart.CFrame = NOW
        wait(0.1)
        tp2(Players[Target], player)
        wait(0.1)
        tp2(Players[Target], player)
        wait(0.3)
        tp2(Players[Target], player)
        for i = 1, 20 do
            getout(player, Players[Target])
            player.Character.HumanoidRootPart.CFrame = NOW
        end
    end)
end)

DevilGroup:AddButton("飞玩家", function()
    task.spawn(function()
        local Target = bai.playernamedied
        local tool = getTool()
        if not tool then
            return Library:Notify({Title = "白", Description = "你需要斧头", Time = 4})
        end
        local NOW = player.Character.HumanoidRootPart.CFrame
        local hrp = lp.Character.HumanoidRootPart
        player.Character.Humanoid.Name = 1
        local l = player.Character["1"]:Clone()
        l.Parent = player.Character
        l.Name = "Humanoid"
        wait(0.1)
        player.Character["1"]:Destroy()
        workspace.CurrentCamera.CameraSubject = player.Character
        player.Character.Animate.Disabled = true
        wait(1.1)
        player.Character.Animate.Disabled = false
        player.Character.Humanoid.DisplayDistanceType = "None"
        for i, v in pairs(game:GetService 'Players'.LocalPlayer.Backpack:GetChildren()) do
            if v.Name:sub(1, 4) == "Tool" then
                player.Character.Humanoid:EquipTool(v)
            end
        end
        local function tp2(player1, player2)
            local char1, char2 = player1.Character, player2.Character
            if char1 and char2 then
                char1.HumanoidRootPart.CFrame = char2.HumanoidRootPart.CFrame
            end
        end
        local function getout(player1, player2)
            local char1, char2 = player1.Character, player2.Character
            if char1 and char2 then
                char1:MoveTo(char2.Head.Position)
            end
        end
        local mag = 1000
        hrp.Velocity = Vector3.new(mag, mag, mag)
        hrp.RotVelocity = Vector3.new(mag, mag, mag)
        wait(0.2)
        tp2(Players[Target], player)
        wait(0.1)
        tp2(Players[Target], player)
        wait(0.3)
        tp2(Players[Target], player)
        wait(0.3)
        for i = 1, 20 do
            getout(player, Players[Target])
        end
    end)
end)

DevilGroup:AddToggle("WatchPlayer", {
    Text = "查看玩家",
    Default = false,
    Callback = function(Value)
        if Value then
            workspace.CurrentCamera.CameraSubject = Players:FindFirstChild(bai.playernamedied).Character.Humanoid
        else
            workspace.CurrentCamera.CameraSubject = lp.Character.Humanoid
        end
    end,
})

DevilGroup:AddToggle("WatchBase", {
    Text = "查看玩家基地",
    Default = false,
    Callback = function(Value)
        local see = nil
        for i, v in pairs(game.Workspace.Properties:GetChildren()) do
            if v.Owner.Value == Players[bai.playernamedied] then
                see = v.OriginSquare
            end
        end
        if Value then
            if see == nil then
                return Library:Notify({Title = "白", Description = "没有找到基地", Time = 4})
            end
            workspace.CurrentCamera.CameraSubject = see
        else
            workspace.CurrentCamera.CameraSubject = lp.Character.Humanoid
        end
    end,
})

local BuyGroup = Tabs.AutoBuy:AddLeftGroupbox("自动购买V2")
local BuyOtherGroup = Tabs.AutoBuy:AddLeftGroupbox("其他")

BuyGroup:AddInput("BuyAmount", {
    Text = "购买数量",
    Default = "1",
    Callback = function(Value)
        bai.autobuyamount = tonumber(Value) or 1
    end,
})

local buyItems = {'按钮', '控制杆', '电线', '4/4x1木楔', '3/4x1木楔', '2/4x1木楔', '1/4X1木楔', '3/3x1木楔', '2/3x1木楔', '1/3x1木楔', '2/2x1木楔', '1/2x1木楔', '1/1x1木楔', '篱笆', '压力板', '1/3木楔', '锯木机01', '锯木机02L', '波纹墙角立柱', '传送带', '普通凳子', '倾斜传送带', '3/4木楔', '2/3木楔', '光滑的墙', '光滑墙角', '普通锯木厂', '4/4木楔', '光滑墙立柱', '篱笆角', '矮篱笆角', '矮波纹墙', '长桌', '矮篱笆', '光滑墙角立柱', '破旧锯木厂', '普通门', '矮光滑墙', '工作灯', '弯传送带', '切换传送带', '宽敞门', '3/3木楔', '400元小汽车', '波纹墙立柱', '锯木机02', '漏斗式传送带', '小型地板', '小型瓷砖', '矮波纹墙角', '波纹墙', '大型地板', '微型瓷砖', '微型地板', '1/1木楔', '左转直式传送带', '银斧头', '切割机', '基础斧头', '右转传送带', '普通斧头', '转向传送带支架', '传送带支架', '波纹墙角立柱', '楼梯', '陡峭楼梯', '钢斧', '标志杆', '梯子', '大型瓷砖', '瓷砖', '硬化斧', '半截门', '木头清扫机', '光滑墙立柱', '沙子袋', '小型拖车', '531式拖车', '小汽车XL', '大卡车', '长沙发', '洗碗机', '薄柜子', '冰箱', '火炉', '马桶', '双人沙发', '床', '落地灯', '台灯', '微型玻璃板', '小型玻璃板', '玻璃板', '大型玻璃板', '玻璃门', '琥珀色冰柱灯串', '红色冰柱灯串', '绿色冰柱灯串', '蓝色冰柱灯串', '烟花发射器', '惊悚冰柱灯串', '单人沙发', '双人床', '灯泡', '工作台面', '薄工作台面', '带水槽的工作台面', '照明灯', '墙灯', '橱柜角', '宽橱柜角', '橱柜', '炸药', '毛毛虫软糖', '未知标题', '困扰装饰画', '户外水彩素描', '阴郁的黄昏海景', '北极灯串', '菠萝画', '孤独的长颈鹿', '信号维持器', '与门', '异与门', '木材检测器', '按钮', '压力板', 'OR门', '拉杆', '信号延时器', '信号变换器', '激光', '激光探测器', '舱门', '橙色发光线', '绿色发光线', '黄色发光线', '白色发光线', '紫色发光线', '红色发光线', '青色发光线', '蓝色发光线', '定时开关'}

local buyItemMap = {
    ['按钮'] = 'Button0', ['控制杆'] = 'Lever0', ['电线'] = 'Wire', ['4/4x1木楔'] = 'Wedge1_Thin', ['3/4x1木楔'] = 'Wedge2_Thin', ['2/4x1木楔'] = 'Wedge3_Thin', ['1/4X1木楔'] = 'Wedge4_Thin', ['3/3x1木楔'] = 'Wedge5_Thin', ['2/3x1木楔'] = 'Wedge6_Thin', ['1/3x1木楔'] = 'Wedge7_Thin', ['2/2x1木楔'] = 'Wedge8_Thin', ['1/2x1木楔'] = 'Wedge9_Thin', ['1/1x1木楔'] = 'Wedge10_Thin', ['篱笆'] = 'Wall3TallThin', ['压力板'] = 'PressurePlate', ['1/3木楔'] = 'Wedge7', ['锯木机01'] = 'Sawmill3', ['锯木机02L'] = 'Sawmill4L', ['波纹墙角立柱'] = 'Wall1ShortCorner', ['传送带'] = 'StraightConveyor', ['普通凳子'] = 'Chair1', ['倾斜传送带'] = 'TiltConveyor', ['3/4木楔'] = 'Wedge2', ['2/3木楔'] = 'Wedge6', ['光滑的墙'] = 'Wall2', ['光滑墙角'] = 'Wall2TallCorner', ['普通锯木厂'] = 'Sawmill2', ['4/4木楔'] = 'Wedge1', ['光滑墙立柱'] = 'Wall2Short', ['篱笆角'] = 'Wall3TallCorner', ['矮篱笆角'] = 'Wall3Corner', ['矮波纹墙'] = 'Wall1Thin', ['长桌'] = 'Table2', ['矮篱笆'] = 'Wall3', ['光滑墙角立柱'] = 'Wall2ShortCorner', ['破旧锯木厂'] = 'Sawmill', ['普通门'] = 'Door1', ['矮光滑墙'] = 'Wall2', ['工作灯'] = 'WorkLight', ['弯传送带'] = 'TightTurnConveyor', ['切换传送带'] = 'ConveyorSwitch', ['宽敞门'] = 'Door3', ['3/3木楔'] = 'Wedge5', ['400元小汽车'] = 'UtilityTruck', ['波纹墙立柱'] = 'Wall1ShortThin', ['锯木机02'] = 'Sawmill4L', ['漏斗式传送带'] = 'ConveyorFunnel', ['小型地板'] = 'Floor1Small', ['小型瓷砖'] = 'Floor2Small', ['矮波纹墙角'] = 'Wall1Corner', ['波纹墙'] = 'Wall1Tall', ['大型地板'] = 'Floor1Large', ['微型瓷砖'] = 'Floor2Tiny', ['微型地板'] = 'Floor1Tiny', ['1/1木楔'] = 'Wedge10', ['左转直式传送带'] = 'StraightSwitchConveyorLeft', ['银斧头'] = 'SilverAxe', ['切割机'] = 'ChopSaw', ['基础斧头'] = 'BasicHatchet', ['右转传送带'] = 'StraightSwitchConveyorRight', ['普通斧头'] = 'Axe1', ['转向传送带支架'] = 'TightTurnConveyorSupports', ['传送带支架'] = 'ConveyorSupports', ['波纹墙角立柱'] = 'Wall1ShortCorner', ['楼梯'] = 'Stair2', ['陡峭楼梯'] = 'Stair1', ['钢斧'] = 'Axe2', ['标志杆'] = 'Post', ['梯子'] = 'Ladder1', ['大型瓷砖'] = 'Floor2Large', ['瓷砖'] = 'Floor2', ['硬化斧'] = 'Axe3', ['半截门'] = 'Door2', ['木头清扫机'] = 'LogSweeper', ['光滑墙立柱'] = 'Wall2ShortThin', ['沙子袋'] = 'BagOfSand', ['小型拖车'] = 'SmallTrailer', ['531式拖车'] = 'Trailer2', ['小汽车XL'] = 'UtilityTruck2', ['大卡车'] = 'Pickup1', ['长沙发'] = 'Seat_Couch', ['洗碗机'] = 'Dishwasher', ['薄柜子'] = 'Cabinet1Thin', ['冰箱'] = 'Refridgerator', ['火炉'] = 'Toilet', ['双人沙发'] = 'Seat_Loveseat', ['床'] = 'Bed1', ['落地灯'] = 'FloorLamp1', ['台灯'] = 'Lamp1', ['微型玻璃板'] = 'GlassPane1', ['小型玻璃板'] = 'GlassPane2', ['玻璃板'] = 'GlassPane3', ['大型玻璃板'] = 'GlassPane4', ['玻璃门'] = 'GlassDoor1', ['琥珀色冰柱灯串'] = 'IcicleWireAmber', ['红色冰柱灯串'] = 'IcicleWireRed', ['绿色冰柱灯串'] = 'IcicleWireGreen', ['蓝色冰柱灯串'] = 'IcicleWireBlue', ['烟花发射器'] = 'FireworkLauncher', ['惊悚冰柱灯串'] = 'IcicleWireHalloween', ['单人沙发'] = 'Seat_Armchair', ['双人床'] = 'Bed2', ['灯泡'] = 'LightBulb', ['工作台面'] = 'CounterTop1', ['薄工作台面'] = 'CounterTop1Thin', ['带水槽的工作台面'] = 'CounterTop1Sink', ['照明灯'] = 'WallLight2', ['墙灯'] = 'WallLight1', ['橱柜角'] = 'Cabinet1CornerTight', ['宽橱柜角'] = 'Cabinet1CornerWide', ['橱柜'] = 'Cabinet1', ['炸药'] = 'Dynamite', ['毛毛虫软糖'] = 'CanOfWorms', ['未知标题'] = 'Painting1', ['困扰装饰画'] = 'Painting2', ['户外水彩素描'] = 'Painting3', ['阴郁的黄昏海景'] = 'Painting6', ['北极灯串'] = 'Painting7', ['菠萝画'] = 'Painting8', ['孤独的长颈鹿'] = 'Painting9', ['信号维持器'] = 'SignalSustain', ['与门'] = 'GateAND', ['异与门'] = 'GateXOR', ['木材检测器'] = 'WoodChecker', ['按钮'] = 'lutton0', ['压力板'] = 'PressurePlate', ['OR门'] = 'GateOR', ['拉杆'] = 'Lever0', ['信号延时器'] = 'SignalDelay', ['信号变换器'] = 'GateNOT', ['激光'] = 'Laser', ['激光探测器'] = 'LaserReceiver', ['舱门'] = 'Hatch', ['橙色发光线'] = 'NeonWireOrange', ['绿色发光线'] = 'NeonWireGreen', ['黄色发光线'] = 'NeonWireYellow', ['白色发光线'] = 'NeonWireWhite', ['紫色发光线'] = 'NeonWireViolet', ['红色发光线'] = 'NeonWireRed', ['青色发光线'] = 'NeonWireCyan', ['蓝色发光线'] = 'NeonWireBlue', ['定时开关'] = 'ClockSwitch'
}

local selectedBuyItem = buyItemMap[buyItems[1]]
BuyGroup:AddDropdown("BuyItemSelect", {
    Text = "自动购买的物品",
    Default = 1,
    Values = buyItems,
    Callback = function(Value)
        selectedBuyItem = buyItemMap[buyItems[Value]]
    end,
})

BuyGroup:AddButton("买", function()
    task.spawn(function()
        bai.autobuystop = false
        bai.autobuyset = lp.Character.HumanoidRootPart.CFrame
        autobuy(selectedBuyItem, bai.autobuyamount)
        task.wait()
        tp(bai.autobuyset)
    end)
end)

BuyGroup:AddButton("停止购买", function()
    bai.autobuystop = true
    pcall(function()
        bai.autocsdx:Disconnect()
        bai.autocsdx = nil
    end)
end)

BuyOtherGroup:AddButton("买黄金蓝图", function()
    task.spawn(function()
        local function callback(Text)
            if Text == "确定" then
                game.ReplicatedStorage.NPCDialog.PlayerChatted:InvokeServer({
                    ['Character'] = workspace.Region_Main['Strange Man'],
                    ['Name'] = 'Strange Man',
                    ['ID'] = getSpecialID('Strange Man'),
                    ['Dialog'] = workspace.Region_Main['Strange Man'].Dialog
                }, 'ConfirmPurchase')
            end
        end
        local NotificationBindable = Instance.new("BindableFunction")
        NotificationBindable.OnInvoke = callback
        game.StarterGui:SetCore("SendNotification", {
            Title = "白",
            Text = "确定购买？",
            Icon = "",
            Duration = 5,
            Button1 = "确定",
            Button2 = "取消",
            Callback = NotificationBindable
        })
    end)
end)

BuyOtherGroup:AddButton("买桥", function()
    game.ReplicatedStorage.NPCDialog.PlayerChatted:InvokeServer({
        ['Character'] = workspace.Bridge.TollBooth0.Seranok,
        ['Name'] = 'Seranok',
        ['ID'] = getSpecialID('Seranok'),
        ['Dialog'] = workspace.Bridge.TollBooth0.Seranok.Dialog
    }, 'ConfirmPurchase')
end)

BuyOtherGroup:AddButton("买船票", function()
    game.ReplicatedStorage.NPCDialog.PlayerChatted:InvokeServer({
        ['Character'] = workspace.Ferry.Ferry.Hoover,
        ['Name'] = 'Hoover',
        ['ID'] = getSpecialID('Hoover'),
        ['Dialog'] = workspace.Ferry.Ferry.Hoover.Dialog
    }, 'ConfirmPurchase')
end)

BuyOtherGroup:AddButton("买鲨鱼", function()
    task.spawn(function()
        local oldPos = lp.Character.HumanoidRootPart.CFrame.Position
        bai.autobuystop = false
        bai.autobuyset = CFrame.new(319, 43, 1914)
        autobuy("BagOfSand", 1)
        task.wait(0.1)
        bai.autobuyset = CFrame.new(317, 43, 1918)
        autobuy('CanOfWorms', 1)
        task.wait(0.1)
        bai.autobuyset = CFrame.new(322, 43, 1916)
        autobuy('LightBulb', 1)
        tp(bai.autobuyset)
        local axeConnection
        axeConnection = workspace.PlayerModels.ChildAdded:Connect(function(Child)
            local Main = Child:WaitForChild('Main', 60)
            if Main:FindFirstChild 'Mesh' and Main.Mesh.TextureId == 'rbxassetid://273892918' then
                repeat wait() until Child:FindFirstChild 'ToolName'
                tp(CFrame.new(Child.Main.CFrame.p))
                repeat
                    task.wait()
                    game:GetService('ReplicatedStorage').Interaction.ClientIsDragging:FireServer(Child)
                    game.ReplicatedStorage.Interaction.ClientInteracted:FireServer(Child, 'Pick up tool')
                until tostring(Child.Parent) ~= 'PlayerModels'
                tp(CFrame.new(oldPos))
                pcall(function()
                    axeConnection:Disconnect()
                    axeConnection = nil
                    bai.boxOpenConnection:Disconnect()
                    bai.boxOpenConnection = nil
                end)
            end
        end)
        bai.boxOpenConnection = workspace.PlayerModels.ChildAdded:Connect(function(Child)
            pcall(function()
                wait(.5)
                local Owner = Child:WaitForChild('Owner', 60)
                if tostring(Owner.Value) == tostring(lp) then
                    local itemName = Child:FindFirstChild 'ItemName' or Child:FindFirstChild 'PurchasedBoxItemName'
                    if itemName then
                        if tostring(itemName.Value) == 'BagOfSand' or tostring(itemName.Value) == 'CanOfWorms' or tostring(itemName.Value) == 'LightBulb' then
                            if Child:FindFirstChild 'ItemName' then
                                wait(0.1)
                                game:GetService("ReplicatedStorage").Interaction.ClientInteracted:FireServer(Child, 'Open box')
                            end
                        end
                    end
                end
            end)
        end)
    end)
end)
local UnloadGroup = Tabs.Settings:AddLeftGroupbox("脚本管理")
UnloadGroup:AddButton("卸载脚本", function()
    autoChop = false
    flying = false
    noclip = false
    infJump = false
    dayOn = false
    nightOn = false
    noFog = false
    stopFly()
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
