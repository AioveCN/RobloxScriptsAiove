-- This file has been deobfuscated Luraph using Hurricane https://discord.com/invite/AbeurBzKXe
local function safeLoad(url)
    local s, r = pcall(function() return loadstring(game:HttpGet(url))() end)
    if not s then warn("加载失败: " .. url) return nil end
    return r
end

local Library = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/黑曜石主库.ui")
local ThemeManager = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/主题管理.ui")
local SaveManager = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/配置管理.ui")

if not Library then
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "错误", Text = "UI库加载失败", Duration = 5})
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local LP = Players.LocalPlayer
local Camera = WS.CurrentCamera

local Window = Library:CreateWindow({
    Title = "力量传奇",
    Footer = "持续更新中",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
    Background = "rbxassetid://11758447890",
})

local Tabs = {
    Notify = Window:AddTab("通知", "info"),
    Main = Window:AddTab("主要", "star"),
    Settings = Window:AddTab("设置", "settings"),
}

local NotifyGroup = Tabs.Notify:AddLeftGroupbox("信息")
NotifyGroup:AddLabel("作者：Aiove")
NotifyGroup:AddLabel("Aiove将持续更新此脚本")

local MainLeft = Tabs.Main:AddLeftGroupbox("自动训练与器材")
local MainRight = Tabs.Main:AddRightGroupbox("战斗、宠物、数据与增强")

MainLeft:AddToggle('AutoTrainTriple', {
    Text = '自动锻炼全部(防打)',
    Default = false,
    Callback = function(v)
        getgenv().AutoTrainTriple = v
        if v then
            task.spawn(function()
                local part = Instance.new('Part', WS)
                part.Size = Vector3.new(500,20,530.1)
                part.Position = Vector3.new(0,100000,133.15)
                part.Anchored = true
                while getgenv().AutoTrainTriple do
                    task.wait()
                    local char = LP.Character
                    if not char then continue end
                    char.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0,50,0)
                    for _,tool in ipairs(LP.Backpack:GetChildren()) do
                        if tool:IsA("Tool") and (tool.Name=="Handstands" or tool.Name=="Situps" or tool.Name=="Pushups" or tool.Name=="Weight") then
                            local nv = tool:FindFirstChildOfClass("NumberValue")
                            if nv then nv.Value = 0 end
                            repeat task.wait() until LP.Backpack:FindFirstChildOfClass("Tool")
                            char.Humanoid:EquipTool(tool)
                            LP.muscleEvent:FireServer("rep")
                        end
                    end
                end
                part:Destroy()
                pcall(function() LP.Character.Humanoid:UnequipTools() end)
            end)
        end
    end
})

MainLeft:AddToggle('AutoTrainMove', {
    Text = '自动锻炼全部(可移动)',
    Default = false,
    Callback = function(v)
        getgenv().AutoAllTrain = v
        task.spawn(function()
            while getgenv().AutoAllTrain do
                task.wait(0.1)
                pcall(function()
                    local char = LP.Character
                    if not char then return end
                    for _,tool in ipairs(LP.Backpack:GetChildren()) do
                        if tool:IsA("Tool") and (tool.Name=="Weight" or tool.Name=="Handstands" or tool.Name=="Pushups" or tool.Name=="Situps") then
                            tool.Parent = char
                            LP.muscleEvent:FireServer("rep")
                            task.wait(0.02)
                            tool.Parent = LP.Backpack
                            task.wait(0.2)
                        end
                    end
                end)
            end
        end)
    end
})

local trainMap = {["哑铃"]="Weight",["俯卧撑"]="Pushups",["仰卧起坐"]="Situps",["倒立"]="Handstands"}
for cn,tool in pairs(trainMap) do
    MainLeft:AddToggle('Auto'..cn, {
        Text = '自动'..cn,
        Default = false,
        Callback = function(v)
            getgenv()['Auto'..cn] = v
            task.spawn(function()
                while getgenv()['Auto'..cn] do
                    task.wait(0.2)
                    pcall(function()
                        local char = LP.Character
                        if not char then return end
                        local t = LP.Backpack:FindFirstChild(tool)
                        if t then
                            char.Humanoid:EquipTool(t)
                            LP.muscleEvent:FireServer("rep")
                        end
                    end)
                end
            end)
        end
    })
end

local tmLoc = {
    ["沙滩跑步机10"] = CFrame.new(238.67,5.40,387.71),
    ["冰霜健身房2000"] = CFrame.new(-3005.38,14.32,-464.70),
    ["神话健身房2000"] = CFrame.new(2571.24,15.69,898.65),
    ["永恒健身房3500"] = CFrame.new(-7077.79,29.67,-1457.60),
    ["传奇健身房3000"] = CFrame.new(4370.83,999.36,-3621.43),
    ["丛林健身房20000"] = CFrame.new(-8138.68,28.27,2833.51),
}
MainLeft:AddDropdown('Treadmill', {
    Text = '跑步机选择',
    Values = {"沙滩跑步机10","冰霜健身房2000","神话健身房2000","永恒健身房3500","传奇健身房3000","丛林健身房20000"},
    Default = 1,
    Callback = function(v) getgenv().Treadmill = v end
})
MainLeft:AddToggle('AutoTreadmill', {
    Text = '自动跑步机',
    Default = false,
    Callback = function(v)
        getgenv().AutoTreadmill = v
        if v then
            task.spawn(function()
                while getgenv().AutoTreadmill do
                    task.wait()
                    pcall(function()
                        local char = LP.Character
                        if not char then return end
                        char.Humanoid.WalkSpeed = 10
                        local cf = tmLoc[getgenv().Treadmill]
                        if cf then char.HumanoidRootPart.CFrame = cf end
                        RunService:BindToRenderStep("Treadmill",1,function()
                            pcall(function() LP.Character.Humanoid:Move(Vector3.new(0,0,-1),true) end)
                        end)
                    end)
                end
            end)
        else
            RunService:UnbindFromRenderStep("Treadmill")
            pcall(function() LP.Character.Humanoid.WalkSpeed = 16 end)
        end
    end
})

local squatLoc = {
    ["沙滩"] = CFrame.new(232.63,3.68,96.30),
    ["霜冻"] = CFrame.new(-2629.14,3.37,-609.83),
    ["传奇"] = CFrame.new(4443.04,987.52,-4061.13),
    ["肌肉"] = CFrame.new(-8757.37,13.22,-6051.24),
    ["丛林"] = CFrame.new(-8383.45,83.43,2854.54),
}
MainLeft:AddDropdown('Squat', {
    Text = '深蹲选择',
    Values = {"沙滩","霜冻","传奇","肌肉","丛林"},
    Default = 1,
    Callback = function(v) getgenv().Squat = v end
})
MainLeft:AddToggle('AutoSquat', {
    Text = '自动深蹲',
    Default = false,
    Callback = function(v)
        getgenv().AutoSquat = v
        if v then
            task.spawn(function()
                while getgenv().AutoSquat do
                    pcall(function()
                        local char = LP.Character
                        if not char then return end
                        local cf = squatLoc[getgenv().Squat]
                        if cf then char.HumanoidRootPart.CFrame = cf end
                        task.wait(0.01)
                        VIM:SendKeyEvent(true,"E",false,nil)
                        task.wait(0.01)
                        VIM:SendKeyEvent(false,"E",false,nil)
                        LP.muscleEvent:FireServer("rep")
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

local benchLoc = {
    ["沙滩"] = CFrame.new(-241.83,7.91,346.32),
    ["冰霜"] = CFrame.new(-3020.70,32.57,-194.77),
    ["神话"] = CFrame.new(2363.95,42.21,1243.51),
    ["永恒"] = CFrame.new(-7172.77,48.39,-1105.06),
    ["传奇"] = CFrame.new(4109.81,1024.03,-3800.75),
    ["肌肉"] = CFrame.new(-8592.998,49.11,-6042.80),
}
MainLeft:AddDropdown('Bench', {
    Text = '卧推选择',
    Values = {"沙滩","冰霜","神话","永恒","传奇","肌肉"},
    Default = 1,
    Callback = function(v) getgenv().Bench = v end
})
MainLeft:AddToggle('AutoBench', {
    Text = '自动卧推',
    Default = false,
    Callback = function(v)
        getgenv().AutoBench = v
        if v then
            task.spawn(function()
                while getgenv().AutoBench do
                    pcall(function()
                        local char = LP.Character
                        if not char then return end
                        local cf = benchLoc[getgenv().Bench]
                        if cf then char.HumanoidRootPart.CFrame = cf end
                        task.wait(0.01)
                        VIM:SendKeyEvent(true,"E",false,nil)
                        task.wait(0.01)
                        VIM:SendKeyEvent(false,"E",false,nil)
                        LP.muscleEvent:FireServer("rep")
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

local pullupLoc = {
    ["沙滩"] = CFrame.new(-185.16,5.81,104.75),
    ["神话"] = CFrame.new(2315.82,5.81,847.15),
    ["传奇"] = CFrame.new(4305.08,989.96,-4118.45),
}
MainLeft:AddDropdown('Pullup', {
    Text = '引体向上选择',
    Values = {"沙滩","神话","传奇"},
    Default = 1,
    Callback = function(v) getgenv().Pullup = v end
})
MainLeft:AddToggle('AutoPullup', {
    Text = '自动引体向上',
    Default = false,
    Callback = function(v)
        getgenv().AutoPullup = v
        if v then
            task.spawn(function()
                while getgenv().AutoPullup do
                    pcall(function()
                        local char = LP.Character
                        if not char then return end
                        local cf = pullupLoc[getgenv().Pullup]
                        if cf then char.HumanoidRootPart.CFrame = cf end
                        task.wait(0.01)
                        VIM:SendKeyEvent(true,"E",false,nil)
                        task.wait(0.01)
                        VIM:SendKeyEvent(false,"E",false,nil)
                        LP.muscleEvent:FireServer("rep")
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

local throwLoc = {
    ["沙滩"] = CFrame.new(-91.67,3.68,-292.43),
    ["神话"] = CFrame.new(2486.02,3.68,1237.89),
    ["传奇"] = CFrame.new(4189.96,987.83,-3903.02),
    ["肌肉"] = CFrame.new(-8935.44,13.86,-5693.67),
    ["丛林"] = CFrame.new(-8620.99,89.81,2673.54),
}
MainLeft:AddDropdown('Throw', {
    Text = '投掷选择',
    Values = {"沙滩","神话","传奇","肌肉","丛林"},
    Default = 1,
    Callback = function(v) getgenv().Throw = v end
})
MainLeft:AddToggle('AutoThrow', {
    Text = '自动投掷',
    Default = false,
    Callback = function(v)
        getgenv().AutoThrow = v
        if v then
            task.spawn(function()
                while getgenv().AutoThrow do
                    pcall(function()
                        local char = LP.Character
                        if not char then return end
                        local cf = throwLoc[getgenv().Throw]
                        if cf then char.HumanoidRootPart.CFrame = cf end
                        task.wait(0.01)
                        VIM:SendKeyEvent(true,"E",false,nil)
                        task.wait(0.01)
                        VIM:SendKeyEvent(false,"E",false,nil)
                        LP.muscleEvent:FireServer("rep")
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

MainRight:AddDropdown('Rock', {
    Text = '选择石头',
    Values = {"Tiny Rock","Inferno Rock","Punching Rock","Rock Of Legends","Muscle King Mountain","Ancient Jungle Rock"},
    Default = 1,
    Callback = function(v) getgenv().Rock = v end
})
MainRight:AddToggle('AutoRock', {
    Text = '自动打石头(隔空)',
    Default = false,
    Callback = function(v)
        getgenv().AutoRock = v
        if v then
            task.spawn(function()
                while getgenv().AutoRock do
                    task.wait(0.2)
                    pcall(function()
                        local char = LP.Character
                        if not char then return end
                        local tool = char:FindFirstChild("Punch") or LP.Backpack:FindFirstChild("Punch")
                        if tool then char.Humanoid:EquipTool(tool) tool:Activate() end
                        local rock = WS.machinesFolder[getgenv().Rock].Rock
                        local lh = char:FindFirstChild("LeftHand")
                        if rock and lh then
                            firetouchinterest(rock,lh,0) task.wait(0.01)
                            firetouchinterest(rock,lh,1)
                        end
                    end)
                end
            end)
        end
    end
})
MainRight:AddToggle('AutoRockPull', {
    Text = '自动打石头(拉取)',
    Default = false,
    Callback = function(v)
        getgenv().AutoRockPull = v
        if v then
            task.spawn(function()
                while getgenv().AutoRockPull do
                    task.wait(0.5)
                    pcall(function()
                        local char = LP.Character
                        if not char then return end
                        local tool = char:FindFirstChild("Punch") or LP.Backpack:FindFirstChild("Punch")
                        if tool then char.Humanoid:EquipTool(tool) tool:Activate() end
                        local rock = WS.machinesFolder[getgenv().Rock].Rock
                        if rock then
                            rock.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0,0,-3)
                            rock.CanCollide = false
                        end
                    end)
                end
            end)
        end
    end
})

MainRight:AddToggle('AutoKill', {
    Text = '自动刷业报(v1)',
    Default = false,
    Callback = function(v)
        getgenv().AutoKill = v
        if v then
            task.spawn(function()
                while getgenv().AutoKill do
                    task.wait(0.1)
                    pcall(function()
                        local char = LP.Character
                        if not char then return end
                        local lh = char:FindFirstChild("LeftHand")
                        if not lh then return end
                        for _,p in ipairs(Players:GetPlayers()) do
                            if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
                                firetouchinterest(p.Character.Head,lh,0)
                                task.wait(0.01)
                                firetouchinterest(p.Character.Head,lh,1)
                            end
                        end
                    end)
                end
            end)
        end
    end
})

MainRight:AddToggle('AutoBrawl', {
    Text = '自动加入比赛',
    Default = false,
    Callback = function(v)
        getgenv().AutoBrawl = v
        if v then
            task.spawn(function()
                while getgenv().AutoBrawl do
                    task.wait(2)
                    pcall(function() RS.rEvents.brawlEvent:FireServer("joinBrawl") end)
                end
            end)
        end
    end
})

MainRight:AddToggle('AutoRebirth', {
    Text = '自动重生',
    Default = false,
    Callback = function(v)
        getgenv().AutoRebirth = v
        if v then
            task.spawn(function()
                while getgenv().AutoRebirth do
                    task.wait(0.5)
                    pcall(function() RS.rEvents.rebirthRemote:InvokeServer("rebirthRequest") end)
                end
            end)
        end
    end
})

MainRight:AddInput('RebirthCount', {
    Text = '自定义重生目标次数',
    Default = 100,
    Numeric = true,
    Finished = true,
    Callback = function(v) getgenv().RebirthGoal = tonumber(v) or 100 end
})
MainRight:AddToggle('AutoRebirthGoal', {
    Text = '重生到目标次数',
    Default = false,
    Callback = function(v)
        getgenv().AutoRebirthGoal = v
        if v then
            task.spawn(function()
                while getgenv().AutoRebirthGoal do
                    task.wait(0.5)
                    pcall(function()
                        if LP.leaderstats.Rebirths.Value >= (getgenv().RebirthGoal or 100) then
                            getgenv().AutoRebirthGoal = false
                        else
                            RS.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
                        end
                    end)
                end
            end)
        end
    end
})

MainRight:AddDropdown('EvolvePet', {
    Text = '进化宠物',
    Values = {"Muscle King","Darkstar Hunter","Neon Guardian","Cybernetic Showdown Dragon"},
    Default = 1,
    Callback = function(v) getgenv().EvolvePet = v end
})
MainRight:AddToggle('AutoEvolve', {
    Text = '自动进化',
    Default = false,
    Callback = function(v)
        getgenv().AutoEvolve = v
        if v then
            task.spawn(function()
                while getgenv().AutoEvolve do
                    task.wait(1)
                    pcall(function() RS.rEvents.petEvolveEvent:FireServer("evolvePet",getgenv().EvolvePet) end)
                end
            end)
        end
    end
})

MainRight:AddDropdown('Crystal', {
    Text = '水晶类型',
    Values = {"Blue Crystal","Green Crystal","Frost Crystal","Mythical Crystal","Inferno Crystal","Legends Crystal","Galaxy Oracle Crystal","Jungle Crystal"},
    Default = 1,
    Callback = function(v) getgenv().Crystal = v end
})
MainRight:AddToggle('AutoCrystal', {
    Text = '自动开水晶',
    Default = false,
    Callback = function(v)
        getgenv().AutoCrystal = v
        if v then
            task.spawn(function()
                while getgenv().AutoCrystal do
                    task.wait(0.5)
                    pcall(function() RS.rEvents.openCrystalRemote:InvokeServer("openCrystal",getgenv().Crystal) end)
                end
            end)
        end
    end
})

MainRight:AddToggle('AutoCollect', {
    Text = '自动使用消耗品',
    Default = false,
    Callback = function(v)
        getgenv().AutoCollect = v
        if v then
            task.spawn(function()
                while getgenv().AutoCollect do
                    task.wait(1)
                    pcall(function()
                        local char = LP.Character
                        if not char then return end
                        for _,t in ipairs(LP.Backpack:GetChildren()) do
                            if t:IsA("Tool") and (t.Name:find("Shake") or t.Name:find("Bar") or t.Name:find("Egg")) then
                                char.Humanoid:EquipTool(t)
                                t:Activate()
                                task.wait(0.1)
                            end
                        end
                    end)
                end
            end)
        end
    end
})

MainRight:AddButton({
    Text = '一键收宝石',
    Func = function()
        local chests = {}
        for _,v in ipairs(RS.chestRewards:GetDescendants()) do
            if v.Name ~= "Light Karma Chest" and v.Name ~= "Evil Karma Chest" then
                table.insert(chests,v.Name)
            end
        end
        for _,name in ipairs(chests) do
            task.wait(2)
            pcall(function() RS.rEvents.checkChestRemote:InvokeServer(name) end)
        end
    end
})

MainRight:AddButton({
    Text = '解锁通行证',
    Func = function()
        pcall(function()
            for _,v in ipairs(RS.gamepassIds:GetChildren()) do
                v.Parent = LP.ownedGamepasses
            end
        end)
    end
})

MainRight:AddLabel("数据修改")
local modifyStats = {"Strength","Durability","Agility","Rebirths","Gems","evilKarma","goodKarma","Kills"}
for _, stat in ipairs(modifyStats) do
    MainRight:AddInput('Modify'..stat, {
        Text = '修改'..stat,
        Default = 0,
        Numeric = true,
        Finished = true,
        Callback = function(v)
            local val = tonumber(v)
            if val then
                pcall(function()
                    if stat == "Strength" or stat == "Durability" or stat == "Agility" or stat == "Gems" then
                        LP[stat].Value = val
                    elseif stat == "Rebirths" or stat == "Kills" then
                        LP.leaderstats[stat].Value = val
                    elseif stat == "evilKarma" or stat == "goodKarma" then
                        LP[stat].Value = val
                    end
                end)
            end
        end
    })
end

MainRight:AddLabel("角色增强")
MainRight:AddSlider('WalkSpeed', {
    Text = '移动速度',
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 0,
    Suffix = " studs/s",
    Callback = function(v)
        getgenv().WalkSpeed = v
        pcall(function() if LP.Character and LP.Character.Humanoid then LP.Character.Humanoid.WalkSpeed = v end end)
    end
})
MainRight:AddSlider('JumpPower', {
    Text = '跳跃高度',
    Default = 50,
    Min = 50,
    Max = 300,
    Rounding = 0,
    Callback = function(v)
        getgenv().JumpPower = v
        pcall(function() if LP.Character and LP.Character.Humanoid then LP.Character.Humanoid.JumpPower = v end end)
    end
})
MainRight:AddToggle('InfJump', {
    Text = '无限跳跃',
    Default = false,
    Callback = function(v) getgenv().InfJump = v end
})
MainRight:AddToggle('Noclip', {
    Text = '穿墙',
    Default = false,
    Callback = function(v)
        getgenv().Noclip = v
        if v then
            task.spawn(function()
                while getgenv().Noclip do
                    task.wait(0.1)
                    pcall(function()
                        local char = LP.Character
                        if char then for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
                    end)
                end
                pcall(function()
                    local char = LP.Character
                    if char then for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end
                end)
            end)
        end
    end
})
MainRight:AddToggle('Fly', {
    Text = '飞行模式',
    Default = false,
    Callback = function(v)
        getgenv().Fly = v
        if v then
            task.spawn(function()
                local ctrl = require(LP.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
                local char = LP.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    local bv = Instance.new("BodyVelocity",hrp)
                    bv.Name = "FlyVel"; bv.MaxForce = Vector3.new(9e9,9e9,9e9)
                    local bg = Instance.new("BodyGyro",hrp)
                    bg.Name = "FlyGyro"; bg.MaxTorque = Vector3.new(9e9,9e9,9e9); bg.P = 1000; bg.D = 50
                    getgenv().FlyLoop = RunService.RenderStepped:Connect(function()
                        if not getgenv().Fly then return end
                        local c = LP.Character
                        if c and c:FindFirstChild("HumanoidRootPart") then
                            c.Humanoid.PlatformStand = true
                            hrp.Gyro.CFrame = Camera.CFrame
                            local dir = ctrl:GetMoveVector()
                            local speed = 150
                            hrp.Velocity = Camera.CFrame:VectorToWorldSpace(Vector3.new(dir.X,0,dir.Z)) * speed
                            if UIS:IsKeyDown(Enum.KeyCode.Space) then hrp.Velocity += Vector3.new(0,speed/2,0) end
                        end
                    end)
                end
            end)
        else
            if getgenv().FlyLoop then getgenv().FlyLoop:Disconnect() getgenv().FlyLoop = nil end
            pcall(function()
                local char = LP.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        if hrp:FindFirstChild("FlyVel") then hrp.FlyVel:Destroy() end
                        if hrp:FindFirstChild("FlyGyro") then hrp.FlyGyro:Destroy() end
                        char.Humanoid.PlatformStand = false
                    end
                end
            end)
        end
    end
})
MainRight:AddToggle('LockPos', {
    Text = '锁定位置',
    Default = false,
    Callback = function(v)
        getgenv().LockPos = v
        if v then
            local pos = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and LP.Character.HumanoidRootPart.Position or Vector3.zero
            task.spawn(function()
                while getgenv().LockPos do
                    task.wait(0.1)
                    pcall(function()
                        local char = LP.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            char.HumanoidRootPart.CFrame = CFrame.new(pos)
                        end
                    end)
                end
            end)
        end
    end
})

MainRight:AddToggle('AntiAFK', {
    Text = '反挂机',
    Default = false,
    Callback = function(v)
        getgenv().AntiAFK = v
        if v then
            LP.Idled:Connect(function()
                if getgenv().AntiAFK then
                    game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0),Camera.CFrame)
                    task.wait(1)
                    game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0),Camera.CFrame)
                end
            end)
        end
    end
})

local SetL = Tabs.Settings:AddLeftGroupbox("菜单")
local SetR = Tabs.Settings:AddRightGroupbox("主题与配置")

SetL:AddButton({
    Text = '卸载脚本',
    Func = function() Library:Unload() end,
})
SetL:AddButton({
    Text = '重载界面',
    Func = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/yourscript"))()
    end,
})
SetL:AddLabel('菜单快捷键')
local mk = SetL:AddKeyPicker('MenuKeybind', {Default = 'RightShift', NoUI = true, Text = 'Menu keybind'})
Library.ToggleKeybind = mk

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

getgenv().AutoTrainTriple = false
getgenv().AutoAllTrain = false
getgenv().AutoRock = false
getgenv().AutoRockPull = false
getgenv().Rock = "Tiny Rock"
getgenv().AutoKill = false
getgenv().AutoBrawl = false
getgenv().AutoRebirth = false
getgenv().AutoRebirthGoal = false
getgenv().RebirthGoal = 100
getgenv().AutoEvolve = false
getgenv().EvolvePet = "Muscle King"
getgenv().AutoCrystal = false
getgenv().Crystal = "Blue Crystal"
getgenv().AutoCollect = false
getgenv().WalkSpeed = 16
getgenv().JumpPower = 50
getgenv().InfJump = false
getgenv().Noclip = false
getgenv().Fly = false
getgenv().LockPos = false
getgenv().AntiAFK = false

LP.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = getgenv().WalkSpeed or 16
    hum.JumpPower = getgenv().JumpPower or 50
end)

UIS.JumpRequest:Connect(function()
    if getgenv().InfJump then
        pcall(function() if LP.Character and LP.Character.Humanoid then LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)
    end
end)
