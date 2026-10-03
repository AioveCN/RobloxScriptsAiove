-- This file has been deobfuscated Luraph using Hurricane https://discord.com/invite/AbeurBzKXe
game:GetService("StarterGui"):SetCore("SendNotification",{ Title = "doors", Text = "作者：Aiove\nQQ：3999698324\n持续更新中", Icon = "rbxthumb://type=Asset&id=5107182114&w=150&h=150" })

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")

local function Notify(msg, dur)
    dur = dur or 3
    if Library then pcall(function() Library:Notify(msg, dur) end)
    else game:GetService("StarterGui"):SetCore("SendNotification", {Title="", Text=msg, Duration=dur}) end
end

local function safeLoad(url)
    local s, r = pcall(function() return loadstring(game:HttpGet(url))() end)
    if not s then return nil end
    return r
end

local Library = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/黑曜石主库.ui")
local ThemeManager = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/主题管理.ui")
local SaveManager = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/配置管理.ui")

-- 全局变量
local desiredWalkSpeed = 16
local interactRange = 15
local flySpeed = 50
local ladderSpeedValue = 20
local healthValue = 100

local loops = {}
local function toggleLoop(name, active, func)
    if loops[name] then loops[name]:Disconnect(); loops[name] = nil end
    if active then loops[name] = RunService.Heartbeat:Connect(func) end
end

local espConnections = {}
local function clearESPGroup(name)
    if espConnections[name] then
        for _, v in ipairs(espConnections[name]) do
            pcall(function()
                if typeof(v) == "RBXScriptConnection" then v:Disconnect()
                elseif v:IsA("Highlight") then v:Destroy() end
            end)
        end
        espConnections[name] = nil
    end
end

local function enableESP(name, filterFunc, fillColor, outlineColor)
    clearESPGroup(name)
    local group = {}
    local HighlightColor = fillColor or Color3.fromRGB(255, 255, 255)
    local OutlineColor = outlineColor or HighlightColor
    local function add(obj)
        if not filterFunc(obj) then return end
        local h = Instance.new("Highlight")
        h.Adornee = obj
        h.FillColor = HighlightColor
        h.OutlineColor = OutlineColor
        h.FillTransparency = 0.5
        h.Parent = obj
        table.insert(group, h)
    end
    for _, o in ipairs(Workspace:GetDescendants()) do add(o) end
    local conn = Workspace.DescendantAdded:Connect(add)
    table.insert(group, conn)
    espConnections[name] = group
end

local function disableESP(name)
    clearESPGroup(name)
end

local doorNames = {["Door"] = true}
local fakeDoorNames = {["DoorFake"] = true}
local objectiveItems = {["KeyObtain"] = true, ["FuseObtain"] = true, ["LiveBreakerPolePickup"] = true}
local coinNames = {["GoldPile"] = true}
local genNames = {["MinesGenerator"] = true}
local leverNames = {["LeverForGate"] = true}
local itemNames = {
    AlarmClock=true, Aloe=true, BandagePack=true, Battery=true, BatteryPack=true,
    Candle=true, Compass=true, Crucifix=true, Flashlight=true, Glowstick=true,
    HolyHandGrenade=true, Lantern=true, LaserPointer=true, Lighter=true,
    Lockpick=true, LotusFlower=true, Multitool=true, NVCS3000=true,
    Shears=true, SkeletonKey=true, Smoothie=true, Vitamins=true
}
local closetNames = {Wardrobe=true, Toolshed=true, Locker_Large=true, Backdoor_Wardrobe=true}
local anchorNames = {MinesAnchor=true}
local bookNames = {LiveHintBook=true}
local chestNames = {ChestBox=true, ChestBoxLocked=true}
local entityNames = {
    SeekMoving=true, FigureRig=true, AmbushMoving=true, RushMoving=true,
    Snare=true, GiggleCeiling=true, EyestalkMoving=true, Mandrake=true,
    Groundskeeper=true, BackdoorRush=true
}

-- 规避相关函数
local function avoidScreech(enabled)
    if enabled then
        Workspace.DescendantAdded:Connect(function(x) if x.Name=="Screech" then x:Destroy() end end)
    end
end

local function avoidGloom(enabled)
    for _, v in ipairs(Workspace.CurrentRooms:GetDescendants()) do
        if v.Name == "GloomEgg" then
            local egg = v:FindFirstChild("Egg")
            if egg then egg.CanTouch = not enabled end
        end
    end
end

local function avoidDread(enabled)
    local mod = LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules:FindFirstChild("Dread") or LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules:FindFirstChild("_Dread")
    if mod then mod.Name = enabled and "_Dread" or "Dread" end
end

local function avoidGiggle(enabled)
    for _, v in ipairs(Workspace.CurrentRooms:GetDescendants()) do
        if v.Name == "GiggleCeiling" then
            local hit = v:FindFirstChild("Hitbox")
            if hit then hit.CanTouch = not enabled end
        end
    end
end

local function avoidFigureHearing(enabled)
    if enabled then
        RunService.Heartbeat:Connect(function()
            ReplicatedStorage.RemotesFolder.Crouch:FireServer(true)
        end)
    else
        ReplicatedStorage.RemotesFolder.Crouch:FireServer(false)
    end
end

local function avoidSurge(enabled)
    if enabled then
        local surge = ReplicatedStorage.FloorReplicated.ClientRemote:FindFirstChild("SurgeClient")
        if surge then surge:Destroy() end
    end
end

local function avoidHalt(enabled)
    local mod = ReplicatedStorage.ModulesClient.EntityModules:FindFirstChild("Shade") or ReplicatedStorage.ModulesClient.EntityModules:FindFirstChild("_Shade")
    if mod then mod.Name = enabled and "_Shade" or "Shade" end
end

local function avoidLookman(enabled)
    if enabled then
        ReplicatedStorage.RemotesFolder.MotorReplication:FireServer(-890)
    end
end

local function avoidSnare(enabled)
    for _, v in ipairs(Workspace.CurrentRooms:GetDescendants()) do
        if v.Name == "Snare" then
            local hit = v:FindFirstChild("Hitbox")
            if hit then hit.CanTouch = not enabled end
        end
    end
end

local function avoidSeekObstacles(enabled)
    for _, v in ipairs(Workspace.CurrentRooms:GetDescendants()) do
        if v.Name == "Seek_Arm" then
            v.AnimatorPart.CanTouch = not enabled
        elseif v.Name == "ChandelierObstruction" then
            v.HurtPart.CanTouch = not enabled
        end
    end
end

local function avoidDupeDoors(enabled)
    for _, v in ipairs(Workspace.CurrentRooms:GetDescendants()) do
        if v.Name == "DoorFake" then
            v.Hidden.CanTouch = not enabled
        end
    end
end

local function avoidVoidArea(enabled)
    for _, v in ipairs(Workspace.CurrentRooms:GetDescendants()) do
        if v.Name == "SideroomSpace" then
            for _, p in ipairs(v:GetChildren()) do
                if p:IsA("BasePart") then
                    p.CanTouch = not enabled
                    p.CanCollide = enabled
                end
            end
        end
    end
end

local function avoidEyes(enabled)
    if enabled then
        RunService.RenderStepped:Connect(function()
            if not LocalPlayer.Character:GetAttribute("Hiding") then
                for _, e in ipairs(Workspace:GetChildren()) do
                    if e.Name == "Eyes" and e.Core.Ambience.Playing then
                        ReplicatedStorage.RemotesFolder.MotorReplication:FireServer(-650)
                    end
                end
            end
        end)
    end
end

local function avoidA90(enabled)
    local mod = LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules:FindFirstChild("A90") or LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules:FindFirstChild("_A90")
    if mod then mod.Name = enabled and "_A90" or "A90" end
end

local function avoidVoidEffect(enabled)
    local mod = ReplicatedStorage.ModulesClient.EntityModules:FindFirstChild("Void") or ReplicatedStorage.ModulesClient.EntityModules:FindFirstChild("_Void")
    if mod then mod.Name = enabled and "_Void" or "Void" end
end

local function avoidHaste(enabled)
    if enabled then
        ReplicatedStorage.FloorReplicated.ClientRemote.Haste.Ambience:GetPropertyChangedSignal("Playing"):Connect(function()
            if enabled then ReplicatedStorage.FloorReplicated.ClientRemote.Haste.Ambience.Playing = false end
        end)
    end
end

local function avoidFiredamp(enabled)
    if enabled then
        Workspace.Camera.ChildAdded:Connect(function(x)
            if x.Name == "LiveSantity" or x.Name == "LiveFiredamp" then x:Destroy() end
        end)
    end
end

local function avoidMineAtmosphere(enabled)
    if enabled then
        local cave = game:GetService("Lighting"):FindFirstChild("CaveAtmosphere")
        if cave then cave:Destroy() end
        local caves = game:GetService("Lighting"):FindFirstChild("Caves")
        if caves then caves:Destroy() end
    end
end

local function avoidOxygenSanity(enabled)
    if enabled then
        local sanity = game:GetService("Lighting"):FindFirstChild("Sanity")
        if sanity then sanity:Destroy() end
        local oxyCC = game:GetService("Lighting"):FindFirstChild("OxygenCC")
        if oxyCC then oxyCC:Destroy() end
        local oxyBlur = game:GetService("Lighting"):FindFirstChild("OxygenBlur")
        if oxyBlur then oxyBlur:Destroy() end
    end
end

local function setNoFog(enabled)
    if enabled then
        game:GetService("Lighting").FogStart = 1000000
        game:GetService("Lighting").FogEnd = 1000000
    else
        game:GetService("Lighting").FogStart = 150
        game:GetService("Lighting").FogEnd = 150
    end
end

local function setNoShake(enabled)
    local req = require(LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game)
    if enabled then
        task.spawn(function()
            while enabled do
                task.wait()
                req.csgo = CFrame.new()
            end
        end)
    end
end

local function setNoHeadBob(enabled)
    local req = require(LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game)
    if enabled then
        _G.HeadBobConn = RunService.RenderStepped:Connect(function()
            if req and req.spring then
                req.spring.Target = Vector3.zero
                req.spring.Position = Vector3.zero
            end
        end)
    else
        if _G.HeadBobConn then _G.HeadBobConn:Disconnect(); _G.HeadBobConn = nil end
    end
end

local function setNoCutscenes(enabled)
    local rl = LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener
    local cs = rl:FindFirstChild("Cutscenes") or rl:FindFirstChild("_Cutscenes")
    if cs then cs.Name = enabled and "_Cutscenes" or "Cutscenes" end
end

local function removeHideVignette(enabled)
    LocalPlayer.PlayerGui.MainUI.MainFrame.HideVignette.Image = enabled and "rbxassetid://0" or "rbxassetid://6100076320"
end

local function antiJam(enabled)
    local st = game.SoundService:FindFirstChild("Main")
    if st then
        local jam = st:FindFirstChild("Jamming")
        if jam then jam.Enabled = not enabled end
    end
end

local function antiBanana(enabled)
    for _, v in ipairs(Workspace.CurrentRooms:GetDescendants()) do
        if v.Name == "BananaPeel" then v.CanTouch = not enabled end
    end
end

local function antiJeff(enabled)
    for _, v in ipairs(Workspace.CurrentRooms:GetDescendants()) do
        if v.Name == "JeffTheKiller" then
            for _, p in ipairs(v:GetChildren()) do
                if p:IsA("BasePart") then p.CanTouch = not enabled end
            end
        end
    end
end

-- 飞行脚本（参考自原版）
local function loadFlightScript()
    pcall(function()
        local main = Instance.new("ScreenGui", CoreGui)
        main.Name = "FlightGui_"..tostring(math.random())
        main.ResetOnSpawn = false
        local Frame = Instance.new("Frame", main)
        Frame.BackgroundColor3 = Color3.fromRGB(163,255,137)
        Frame.BorderColor3 = Color3.fromRGB(103,221,213)
        Frame.Position = UDim2.new(0.1,0,0.38,0)
        Frame.Size = UDim2.new(0,190,0,57)
        local function makeBtn(text,size,pos,bg)
            local btn = Instance.new("TextButton",Frame)
            btn.BackgroundColor3 = bg
            btn.Size = size
            btn.Position = pos
            btn.Font = Enum.Font.SourceSans
            btn.Text = text
            btn.TextColor3 = Color3.new(0,0,0)
            btn.TextSize = 14
            return btn
        end
        local up = makeBtn("上升",UDim2.new(0,44,0,28),UDim2.new(0,0,0,0),Color3.fromRGB(79,255,152))
        local down = makeBtn("下落",UDim2.new(0,44,0,28),UDim2.new(0,0,0.5,0),Color3.fromRGB(215,255,121))
        local onof = makeBtn("飞",UDim2.new(0,56,0,28),UDim2.new(0.7,0,0.5,0),Color3.fromRGB(255,249,74))
        local TextLabel = Instance.new("TextLabel",Frame)
        TextLabel.BackgroundColor3 = Color3.fromRGB(242,60,255)
        TextLabel.Position = UDim2.new(0.5,0,0,0)
        TextLabel.Size = UDim2.new(0,100,0,28)
        TextLabel.Font = Enum.Font.SourceSans
        TextLabel.Text = "Aiove"
        TextLabel.TextColor3 = Color3.new(0,0,0)
        TextLabel.TextScaled = true
        TextLabel.TextSize = 14
        local plus = makeBtn("+",UDim2.new(0,45,0,28),UDim2.new(0.23,0,0,0),Color3.fromRGB(133,145,255))
        local speed = Instance.new("TextLabel",Frame)
        speed.BackgroundColor3 = Color3.fromRGB(255,85,0)
        speed.Position = UDim2.new(0.47,0,0.5,0)
        speed.Size = UDim2.new(0,44,0,28)
        speed.Font = Enum.Font.SourceSans
        speed.Text = "1"
        speed.TextColor3 = Color3.new(0,0,0)
        speed.TextScaled = true
        speed.TextSize = 14
        local mine = makeBtn("-",UDim2.new(0,45,0,29),UDim2.new(0.23,0,0.5,0),Color3.fromRGB(123,255,247))
        local closeBtn = makeBtn("X",UDim2.new(0,45,0,28),UDim2.new(0,0,-1,27),Color3.fromRGB(225,25,0))
        closeBtn.TextSize = 30
        closeBtn.Font = Enum.Font.ArialBold
        local mini = makeBtn("-",UDim2.new(0,45,0,28),UDim2.new(0,44,-1,27),Color3.fromRGB(192,150,230))
        mini.TextSize = 40
        local mini2 = makeBtn("+",UDim2.new(0,45,0,28),UDim2.new(0,44,0,30),Color3.fromRGB(192,150,230))
        mini2.TextSize = 40
        mini2.Visible = false
        local speeds = 1
        local nowe = false
        local chr = LocalPlayer.Character
        local hum = chr and chr:FindFirstChildOfClass("Humanoid")
        Frame.Active = true
        Frame.Draggable = true
        closeBtn.MouseButton1Click:Connect(function() main:Destroy() end)
        up.MouseButton1Click:Connect(function()
            if chr and chr:FindFirstChild("HumanoidRootPart") then
                chr.HumanoidRootPart.CFrame = chr.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
            end
        end)
        down.MouseButton1Click:Connect(function()
            if chr and chr:FindFirstChild("HumanoidRootPart") then
                chr.HumanoidRootPart.CFrame = chr.HumanoidRootPart.CFrame + Vector3.new(0,-3,0)
            end
        end)
        mini.MouseButton1Click:Connect(function()
            up.Visible=false;down.Visible=false;onof.Visible=false;plus.Visible=false
            speed.Visible=false;mine.Visible=false;closeBtn.Visible=false;mini.Visible=false
            mini2.Visible=true
            Frame.Size = UDim2.new(0,100,0,28)
            TextLabel.Position = UDim2.new(0,0,0,0)
        end)
        mini2.MouseButton1Click:Connect(function()
            up.Visible=true;down.Visible=true;onof.Visible=true;plus.Visible=true
            speed.Visible=true;mine.Visible=true;closeBtn.Visible=true;mini.Visible=true
            mini2.Visible=false
            Frame.Size = UDim2.new(0,190,0,57)
            TextLabel.Position = UDim2.new(0.47,0,0,0)
        end)
        plus.MouseButton1Click:Connect(function() speeds=speeds+1 speed.Text=tostring(speeds) end)
        mine.MouseButton1Click:Connect(function()
            if speeds>1 then speeds=speeds-1 speed.Text=tostring(speeds)
            else speed.Text="错误" task.wait(0.2) speed.Text="1" end
        end)
        LocalPlayer.CharacterAdded:Connect(function(c) chr=c; hum=c:FindFirstChildOfClass("Humanoid") end)
        onof.MouseButton1Click:Connect(function()
            nowe = not nowe
            if nowe then
                if hum then
                    for _, s in pairs(Enum.HumanoidStateType:GetEnumItems()) do hum:SetStateEnabled(s,false) end
                    hum:ChangeState(Enum.HumanoidStateType.Swimming)
                end
                if chr.Animate then chr.Animate.Disabled=true end
                if hum then
                    for _, t in pairs(hum:GetPlayingAnimationTracks()) do t:AdjustSpeed(0) end
                end
                task.spawn(function()
                    while nowe and chr and hum do
                        RunService.Heartbeat:Wait()
                        if hum.MoveDirection.Magnitude>0 then chr:TranslateBy(hum.MoveDirection*speeds) end
                    end
                end)
                local root = hum.RigType == Enum.HumanoidRigType.R6 and chr.Torso or chr.UpperTorso
                local bg = Instance.new("BodyGyro",root)
                bg.P=9e4
                bg.MaxTorque=Vector3.new(9e9,9e9,9e9)
                bg.CFrame=root.CFrame
                local bv = Instance.new("BodyVelocity",root)
                bv.Velocity=Vector3.new(0,0,0)
                bv.MaxForce=Vector3.new(9e9,9e9,9e9)
                if nowe then chr.Humanoid.PlatformStand=true end
                while nowe and chr.Humanoid.Health>0 do
                    RunService.RenderStepped:Wait()
                    bg.CFrame = workspace.CurrentCamera.CoordinateFrame
                end
                bg:Destroy()
                bv:Destroy()
                chr.Humanoid.PlatformStand=false
                chr.Animate.Disabled=false
            else
                if hum then
                    for _, s in pairs(Enum.HumanoidStateType:GetEnumItems()) do hum:SetStateEnabled(s,true) end
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end
                if chr.Animate then chr.Animate.Disabled=false end
            end
        end)
        Notify("飞行脚本已加载")
    end)
end

-- 通用函数
local function safeFireProximityPrompt(prompt)
    pcall(function() if fireproximityprompt then fireproximityprompt(prompt) end end)
end

local function tp(pos)
    local char = LocalPlayer.Character
    if not char then return end
    if typeof(pos) == "CFrame" then char:SetPrimaryPartCFrame(pos)
    elseif typeof(pos) == "Vector3" then char:MoveTo(pos) end
end

-- 穿墙
local noclipConn
local function toggleNoclip(enabled)
    if enabled then
        noclipConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    end
end

-- 爬梯加速
local ladderConn
local function toggleFastLadder(enabled)
    if enabled then
        ladderConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum:GetState() == Enum.HumanoidStateType.Climbing then
                hrp.Velocity = Vector3.new(hrp.Velocity.X, ladderSpeedValue, hrp.Velocity.Z)
            end
        end)
    else
        if ladderConn then ladderConn:Disconnect(); ladderConn = nil end
    end
end

-- 无障碍跳跃
local function toggleAlwaysJump(enabled)
    local function apply(c)
        if c then c:SetAttribute("CanJump", enabled) end
    end
    apply(LocalPlayer.Character)
    LocalPlayer.CharacterAdded:Connect(function(c) task.wait(1.5); apply(c) end)
end

-- 头部发光
local function toggleHeadLight(enabled)
    local head = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
    if enabled then
        if head and not head:FindFirstChild("bai") then
            local light = Instance.new("PointLight")
            light.Name = "bai"; light.Range = 150; light.Brightness = 1.7; light.Parent = head
        end
    else
        if head then
            local light = head:FindFirstChild("bai")
            if light then light:Destroy() end
        end
    end
end

-- 十字架
local function getCrucifix()
    local tool = game:GetObjects("rbxassetid://11498423088")[1]
    tool.Parent = LocalPlayer.Backpack
    Notify("十字架已添加")
end

-- 血量锁定
local healthConn
local function toggleHealthLock(enabled)
    if enabled then
        healthConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                char:FindFirstChildOfClass("Humanoid").Health = healthValue
            end
        end)
    else
        if healthConn then healthConn:Disconnect(); healthConn = nil end
    end
end

-- 反作弊
local function disableAntiCheat()
    local lp = LocalPlayer
    if lp:GetAttribute("CurrentRoom") == 0 then
        if replicatesignal then replicatesignal(lp.Kill) end
        Notify("反作弊已尝试禁用")
    else
        Notify("请在电梯中使用")
    end
end

-- 自动互动
local function autoInteractLoop()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
            local part = prompt.Parent
            if part and part:IsA("BasePart") and (root.Position - part.Position).Magnitude < 10 then
                safeFireProximityPrompt(prompt)
            end
        end
    end
end

local function autoOpenDoorsLoop()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, door in ipairs(Workspace.CurrentRooms:GetChildren()) do
        local doorModel = door:FindFirstChild("Door")
        if doorModel and door:FindFirstChild("ClientOpen") then
            door.ClientOpen:FireServer()
        end
    end
end

local function autoBreakDoorLoop()
    for _, part in ipairs(Workspace.CurrentRooms:GetDescendants()) do
        if part.Name == "DoorPieceBottom" or part.Name == "DoorPieceTop" then
            for _, prompt in ipairs(part:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                    safeFireProximityPrompt(prompt)
                end
            end
        end
    end
end

local function autoPickupDropsLoop()
    local drops = Workspace:FindFirstChild("Drops")
    if drops then
        for _, model in ipairs(drops:GetChildren()) do
            for _, prompt in ipairs(model:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                    safeFireProximityPrompt(prompt)
                end
            end
        end
    end
end

local function autoMinecartLoop()
    for _, obj in ipairs(Workspace.CurrentRooms:GetDescendants()) do
        if obj.Name == "MinecartMoving" then
            local prompt = obj:FindFirstChild("PushPrompt", true)
            if prompt then safeFireProximityPrompt(prompt) end
        end
    end
end

local function autoThrowablesLoop()
    local targets = {"WoodenCrate", "OilBarrel", "GarbageBag", "Trashcan", "CardboardBox_Normal", "Hat_Stand", "CardboardBox_Wide", "Office_Chair"}
    local bigProps = Workspace:FindFirstChild("BigProps")
    if bigProps then
        for _, name in ipairs(targets) do
            local prop = bigProps:FindFirstChild(name)
            if prop then
                for _, prompt in ipairs(prop:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then safeFireProximityPrompt(prompt) end
                end
            end
        end
    end
end

local autoFireConn
local function toggleAutoFire(enabled)
    if enabled then
        autoFireConn = RunService.RenderStepped:Connect(function()
            local lp = LocalPlayer
            local cam = workspace.CurrentCamera
            local char = lp.Character
            if not char then return end
            local look = cam.CFrame.LookVector
            local origin = cam.CFrame.Position
            local closest, bestDot = nil, 0.995
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local pos = plr.Character.HumanoidRootPart.Position
                    local dir = (pos - origin).Unit
                    local dot = look:Dot(dir)
                    if dot > bestDot and (pos - origin).Magnitude < 50 then
                        bestDot = dot
                        closest = plr
                    end
                end
            end
            if closest then
                pcall(function() mouse1press() end)
            else
                pcall(function() mouse1release() end)
            end
        end)
    else
        if autoFireConn then autoFireConn:Disconnect(); autoFireConn = nil end
        pcall(function() mouse1release() end)
    end
end

local function autoRoomsLoop()
    local gameData = ReplicatedStorage:WaitForChild("GameData")
    if gameData.Floor.Value ~= "Rooms" or gameData.LatestRoom.Value >= 1000 then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local entity = Workspace:FindFirstChild("A60") or Workspace:FindFirstChild("A120")
    if entity and entity.PrimaryPart then
        local best, bestDist = nil, math.huge
        for _, obj in ipairs(Workspace.CurrentRooms:GetDescendants()) do
            if obj.Name == "Rooms_Locker" or obj.Name == "Rooms_Locker_Fridge" then
                if obj.PrimaryPart then
                    local d = (hrp.Position - obj.PrimaryPart.Position).Magnitude
                    if d < bestDist then best, bestDist = obj, d end
                end
            end
        end
        if best then
            char:FindFirstChildOfClass("Humanoid"):MoveTo(best.PrimaryPart.Position)
            task.wait(0.5)
            local prompt = best:FindFirstChildOfClass("ProximityPrompt")
            if prompt then safeFireProximityPrompt(prompt) end
        end
    else
        local currentRoom = Workspace.CurrentRooms[gameData.LatestRoom.Value]
        if currentRoom then
            local door = currentRoom:FindFirstChild("Door", true)
            if door then char:FindFirstChildOfClass("Humanoid"):MoveTo(door.Position) end
        end
    end
end

local function autoHideSetup()
    Workspace.ChildAdded:Connect(function(inst)
        if inst.Name == "RushMoving" or inst.Name == "AmbushMoving" then
            task.wait(0.5)
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local closest, minDist = nil, math.huge
            for _, obj in ipairs(Workspace.CurrentRooms:GetDescendants()) do
                if obj:IsA("Model") and (obj.Name == "Wardrobe" or obj.Name == "Locker_Large")
                    and obj:FindFirstChild("HidePrompt") and not obj:FindFirstChild("HiddenPlayer").Value then
                    local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if part then
                        local dist = (hrp.Position - part.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            closest = obj
                        end
                    end
                end
            end
            if closest then
                char:FindFirstChildOfClass("Humanoid"):MoveTo(closest.PrimaryPart.Position)
                task.wait(0.3)
                safeFireProximityPrompt(closest.HidePrompt)
            end
        end
    end)
end

-- 提示实体列表
local entityNotifyList = {
    Screech = "尖啸者", Halt = "暂停实体", FigureRig = "雕像", Eyes = "眼睛",
    SeekMoving = "追逐者", RushMoving = "冲刺", AmbushMoving = "伏击",
    A60 = "A-60", A120 = "A-120", GiggleCeiling = "傻笑",
    GrumbleRig = "咕噜", GloombatSwarm = "暗影蝙蝠", Dread = "恐惧",
    BackdoorLookman = "观察者", Snare = "陷阱", WorldLotus = "世界莲花",
    Bramble = "荆棘", Caws = "乌鸦", Eyestalk = "眼柄",
    Grampy = "爷爷", Groundskeeper = "园丁", Mandrake = "曼德拉草",
    Monument = "纪念碑", Surge = "浪涌", BackdoorRush = "闪电"
}

local uiCreated = false

if Library then
    local success, err = pcall(function()
        local Window = Library:CreateWindow({
            Title = "doors",
            Footer = "Aiove 制作",
            Icon = 131153193945220,
            NotifySide = "Right",
            ShowCustomCursor = true,
        })

        local Tabs = {
            Info = Window:AddTab("通知", "info"),
            Player = Window:AddTab("玩家", "user"),
            Auto = Window:AddTab("自动", "robot"),
            Avoid = Window:AddTab("规避", "shield"),
            ESP = Window:AddTab("透视", "search"),
            NotifyTab = Window:AddTab("提示", "bell"),
            Settings = Window:AddTab("设置", "cog"),
        }

        -- 通知标签页
        Tabs.Info:AddLeftGroupbox("作者信息"):AddLabel("Aiove doors脚本")
        Tabs.Info:AddLeftGroupbox("联系方式"):AddLabel("QQ：3999698324")
        Tabs.Info:AddLeftGroupbox("状态"):AddLabel("持续更新中", true)

        -- 玩家标签页
        local Player1 = Tabs.Player:AddLeftGroupbox("移动与物理")
        Player1:AddToggle("SpeedToggle", {Text="自定义速度", Default=false, Callback=function(v)
            toggleLoop("speed", v, function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = desiredWalkSpeed end
            end)
            Notify(v and "速度锁定开启" or "速度锁定关闭")
        end})
        Player1:AddSlider("WalkSpeed", {Text="速度值", Default=16, Min=16, Max=100, Rounding=0, Suffix=" studs", Callback=function(v) desiredWalkSpeed = v end})
        Player1:AddToggle("InstantAccel", {Text="即时加速度", Default=false, Callback=function(v)
            local prop = v and PhysicalProperties.new(100,0,0,0,0) or PhysicalProperties.new(0.01,0.7,0,1,1)
            local function apply(c) if c and c:FindFirstChild("HumanoidRootPart") then c.HumanoidRootPart.CustomPhysicalProperties = prop end end
            apply(LocalPlayer.Character)
            LocalPlayer.CharacterAdded:Connect(function(c) task.wait(1.5); apply(c) end)
        end})
        Player1:AddToggle("Fly", {Text="飞行模式", Default=false, Callback=function(v)
            if v then loadFlightScript() end
        end})
        Player1:AddToggle("Noclip", {Text="穿墙模式", Default=false, Callback=toggleNoclip})
        Player1:AddToggle("FastLadder", {Text="更快爬梯", Default=false, Callback=toggleFastLadder})
        Player1:AddSlider("LadderSpeed", {Text="爬梯速度", Default=20, Min=0, Max=100, Suffix=" speed", Callback=function(v) ladderSpeedValue=v end})
        Player1:AddToggle("AlwaysJump", {Text="始终可跳跃", Default=false, Callback=toggleAlwaysJump})

        local Player2 = Tabs.Player:AddRightGroupbox("辅助")
        Player2:AddToggle("HeadLight", {Text="头部发光", Default=false, Callback=toggleHeadLight})
        Player2:AddButton("获得十字架", getCrucifix)
        Player2:AddToggle("HealthLock", {Text="血量锁定", Default=false, Callback=toggleHealthLock})
        Player2:AddSlider("HealthSlider", {Text="血量数值", Default=100, Min=1, Max=1000, Suffix=" HP", Callback=function(v) healthValue=v end})
        Player2:AddButton("禁用反作弊(电梯)", disableAntiCheat)

        -- 自动标签页
        local Auto1 = Tabs.Auto:AddLeftGroupbox("互动自动化")
        Auto1:AddToggle("InstantInteract", {Text="即时互动", Default=false, Callback=function(v)
            if v then
                game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(safeFireProximityPrompt)
            end
        end})
        Auto1:AddSlider("InteractRange", {Text="互动范围倍数", Default=1, Min=1, Max=5, Rounding=1, Suffix="x", Callback=function(mult)
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    local orig = v:GetAttribute("OriginalMaxDist") or v.MaxActivationDistance
                    v.MaxActivationDistance = orig * mult
                    if not v:GetAttribute("OriginalMaxDist") then v:SetAttribute("OriginalMaxDist", orig) end
                end
            end
        end})
        Auto1:AddToggle("AutoInteract", {Text="自动互动(捡物)", Default=false, Callback=function(v) toggleLoop("autoInteract", v, autoInteractLoop) end})
        Auto1:AddToggle("AutoDoorReach", {Text="自动门范围", Default=false, Callback=function(v) toggleLoop("autoDoorReach", v, autoOpenDoorsLoop) end})

        local Auto2 = Tabs.Auto:AddRightGroupbox("任务自动化")
        Auto2:AddToggle("AutoBreakDoor", {Text="自动破门", Default=false, Callback=function(v) toggleLoop("breakDoor", v, autoBreakDoorLoop) end})
        Auto2:AddToggle("AutoPickup", {Text="自动拾取掉落物", Default=false, Callback=function(v) toggleLoop("pickupDrops", v, autoPickupDropsLoop) end})
        Auto2:AddToggle("AutoMinecart", {Text="自动矿车推动", Default=false, Callback=function(v) toggleLoop("minecart", v, autoMinecartLoop) end})
        Auto2:AddToggle("AutoThrowables", {Text="自动拾取投掷物", Default=false, Callback=function(v) toggleLoop("throwables", v, autoThrowablesLoop) end})
        Auto2:AddToggle("AutoFire", {Text="自动开火", Default=false, Callback=toggleAutoFire})
        Auto2:AddToggle("AutoRooms", {Text="自动房间(Rooms)", Default=false, Callback=function(v) toggleLoop("autoRooms", v, autoRoomsLoop) end})
        Auto2:AddToggle("AutoAnchor", {Text="自动锚点代码求解", Default=false, Callback=function(v) end}) -- 占位
        Auto2:AddToggle("AutoBreaker", {Text="自动断路器游戏", Default=false, Callback=function(v) end})
        Auto2:AddToggle("AutoHide", {Text="自动隐藏(防怪物)", Default=false, Callback=function(v) if v then autoHideSetup() end end})
        Auto2:AddToggle("AntiAFK", {Text="反AFK", Default=false, Callback=function(v)
            if v then
                _G.AFKConn = LocalPlayer.Idled:Connect(function()
                    game:GetService("VirtualUser"):CaptureController()
                    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
                end)
            else
                if _G.AFKConn then _G.AFKConn:Disconnect(); _G.AFKConn = nil end
            end
        end})
        Auto2:AddButton("一键通关(测试)", function()
            Notify("开始一键通关")
            Workspace.CurrentRooms.ChildAdded:Connect(function(room)
                if room.Name == "51" then task.wait(12) end
                task.wait(0.3)
                local start = room:FindFirstChild("RoomStart") and room.RoomStart.CFrame
                local endPos = room:FindFirstChild("RoomEnd") and room.RoomEnd.CFrame
                local door = room:FindFirstChild("Door")
                if start then tp(start) end
                if door and door:FindFirstChild("ClientOpen") then door.ClientOpen:FireServer(); door.ClientOpen:FireServer() end
                if endPos then tp(endPos) end
                if door and door:FindFirstChild("ClientOpen") then door.ClientOpen:FireServer(); door.ClientOpen:FireServer() end
            end)
        end)

        -- 规避标签页
        local Avoid1 = Tabs.Avoid:AddLeftGroupbox("实体规避")
        local avoids = {
            {Name="Screech", Text="规避Screech", Func=avoidScreech},
            {Name="Gloom", Text="规避Gloom蛋", Func=avoidGloom},
            {Name="Dread", Text="规避Dread", Func=avoidDread},
            {Name="Giggle", Text="规避Giggle", Func=avoidGiggle},
            {Name="FigureHear", Text="规避Figure听觉", Func=avoidFigureHearing},
            {Name="Surge", Text="规避Surge", Func=avoidSurge},
            {Name="Halt", Text="规避Halt", Func=avoidHalt},
            {Name="Lookman", Text="规避Lookman", Func=avoidLookman},
            {Name="Snare", Text="规避Snare", Func=avoidSnare},
            {Name="SeekObs", Text="规避Seek障碍物", Func=avoidSeekObstacles},
            {Name="Dupe", Text="规避Dupe门", Func=avoidDupeDoors},
            {Name="VoidArea", Text="规避真空区域", Func=avoidVoidArea},
            {Name="Eyes", Text="规避Eyes", Func=avoidEyes},
            {Name="A90", Text="规避A-90", Func=avoidA90},
            {Name="VoidEffect", Text="规避虚空效果", Func=avoidVoidEffect},
            {Name="Haste", Text="规避Haste效果", Func=avoidHaste},
            {Name="Firedamp", Text="规避Firedamp", Func=avoidFiredamp},
            {Name="MineAtm", Text="规避矿井氛围", Func=avoidMineAtmosphere},
            {Name="OxygenSanity", Text="规避氧气/理智效果", Func=avoidOxygenSanity},
        }
        for _, v in ipairs(avoids) do
            Avoid1:AddToggle(v.Name.."Avoid", {Text=v.Text, Default=false, Callback=function(en) v.Func(en) end})
        end

        local Avoid2 = Tabs.Avoid:AddRightGroupbox("视觉效果")
        Avoid2:AddToggle("NoFog", {Text="无雾效果", Default=false, Callback=setNoFog})
        Avoid2:AddToggle("NoShake", {Text="无相机抖动", Default=false, Callback=setNoShake})
        Avoid2:AddToggle("NoHeadBob", {Text="无头部晃动", Default=false, Callback=setNoHeadBob})
        Avoid2:AddToggle("NoCutscenes", {Text="跳过过场动画", Default=false, Callback=setNoCutscenes})
        Avoid2:AddToggle("HideVignette", {Text="移除隐藏暗角", Default=false, Callback=removeHideVignette})
        Avoid2:AddToggle("AntiJam", {Text="防卡顿", Default=false, Callback=antiJam})
        Avoid2:AddToggle("AntiBanana", {Text="防香蕉皮", Default=false, Callback=antiBanana})
        Avoid2:AddToggle("AntiJeff", {Text="防Jeff杀手", Default=false, Callback=antiJeff})

        -- 透视标签页
        local ESPGroup1 = Tabs.ESP:AddLeftGroupbox("物体透视")
        local objects = {
            {Name="Door", Text="门透视", Func=function(en) if en then enableESP("door", function(o) return doorNames[o.Name] end, Color3.fromRGB(0,255,0)) else disableESP("door") end end},
            {Name="Objective", Text="目标物品", Func=function(en) if en then enableESP("obj", function(o) return objectiveItems[o.Name] end, Color3.fromRGB(255,255,0)) else disableESP("obj") end end},
            {Name="Coin", Text="金币", Func=function(en) if en then enableESP("coin", function(o) return coinNames[o.Name] end, Color3.fromRGB(255,255,0)) else disableESP("coin") end end},
            {Name="Gen", Text="发电机", Func=function(en) if en then enableESP("gen", function(o) return genNames[o.Name] end, Color3.fromRGB(0,255,255)) else disableESP("gen") end end},
            {Name="Lever", Text="杠杆", Func=function(en) if en then enableESP("lever", function(o) return leverNames[o.Name] end, Color3.fromRGB(255,165,0)) else disableESP("lever") end end},
            {Name="Item", Text="物品", Func=function(en) if en then enableESP("item", function(o) return itemNames[o.Name] end, Color3.fromRGB(0,0,255)) else disableESP("item") end end},
            {Name="Closet", Text="柜子", Func=function(en) if en then enableESP("closet", function(o) return closetNames[o.Name] end, Color3.fromRGB(255,192,203)) else disableESP("closet") end end},
            {Name="Anchor", Text="锚点", Func=function(en) if en then enableESP("anchor", function(o) return anchorNames[o.Name] end, Color3.fromRGB(255,192,203)) else disableESP("anchor") end end},
            {Name="Book", Text="书籍", Func=function(en) if en then enableESP("book", function(o) return bookNames[o.Name] end, Color3.fromRGB(0,255,255)) else disableESP("book") end end},
            {Name="Chest", Text="宝箱", Func=function(en) if en then enableESP("chest", function(o) return chestNames[o.Name] end, Color3.fromRGB(0,255,0)) else disableESP("chest") end end},
        }
        for _, v in ipairs(objects) do
            ESPGroup1:AddToggle(v.Name.."ESP", {Text=v.Text, Default=false, Callback=v.Func})
        end

        local ESPGroup2 = Tabs.ESP:AddRightGroupbox("实体透视")
        local entities = {
            {Name="Seek", Text="追逐者", Model="SeekMoving"},
            {Name="Figure", Text="雕像", Model="FigureRig"},
            {Name="Ambush", Text="伏击", Model="AmbushMoving"},
            {Name="Rush", Text="冲刺", Model="RushMoving"},
            {Name="Snare", Text="陷阱", Model="Snare"},
            {Name="Giggle", Text="傻笑", Model="GiggleCeiling"},
            {Name="Eyestalk", Text="眼柄", Model="EyestalkMoving"},
            {Name="Mandrake", Text="曼德拉草", Model="Mandrake"},
            {Name="Groundskeeper", Text="园丁", Model="Groundskeeper"},
            {Name="Blitz", Text="闪电", Model="BackdoorRush"},
        }
        for _, v in ipairs(entities) do
            ESPGroup2:AddToggle(v.Name.."EntityESP", {Text=v.Text, Default=false, Callback=function(en)
                if en then enableESP(v.Name.."Entity", function(o) return o.Name == v.Model end, Color3.fromRGB(255,0,0)) else disableESP(v.Name.."Entity") end
            end})
        end

        -- 提示标签页
        local NotifyGroup = Tabs.NotifyTab:AddLeftGroupbox("实体刷新提示")
        for name, desc in pairs(entityNotifyList) do
            NotifyGroup:AddToggle(name.."Notify", {Text=desc.."提示", Default=false, Callback=function(v)
                if v then
                    Workspace.ChildAdded:Connect(function(obj)
                        if obj.Name == name then Notify(desc.." 已出现", 5) end
                    end)
                end
            end})
        end

        -- 设置标签页
        local SettingsGroup = Tabs.Settings:AddLeftGroupbox("菜单")
        SettingsGroup:AddButton("卸载脚本", function() Library:Unload() end)
        SettingsGroup:AddLabel("菜单快捷键"):AddKeyPicker("MenuKey", {Default="RightShift", NoUI=true, Text="Menu keybind"})
        Library.ToggleKeybind = Library.Options.MenuKey

        if ThemeManager then
            ThemeManager:SetLibrary(Library)
            ThemeManager:SetFolder("DoorsScript")
            ThemeManager:ApplyToTab(Tabs.Settings)
        end
        if SaveManager then
            SaveManager:SetLibrary(Library)
            SaveManager:IgnoreThemeSettings()
            SaveManager:SetFolder("DoorsScript")
            SaveManager:BuildConfigSection(Tabs.Settings)
        end

        uiCreated = true
        Notify("doors脚本已就绪 - 按RightShift打开菜单")
    end)

    if not success then warn("Library UI 创建失败: "..tostring(err)) end
end

if not uiCreated then
    -- 备用UI（简化版）
    local sg = Instance.new("ScreenGui", CoreGui); sg.Name = "FallbackUI"; sg.ResetOnSpawn = false
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0,300,0,600)
    main.Position = UDim2.new(0.5,-150,0.5,-300)
    main.BackgroundColor3 = Color3.fromRGB(20,20,20)
    main.Active = true
    main.Draggable = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0,8)
    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1,0,0,30)
    title.BackgroundColor3 = Color3.fromRGB(30,30,30)
    title.Text = "doors脚本 Fallback"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 16
    local closeBtn = Instance.new("TextButton", main)
    closeBtn.Size = UDim2.new(0,30,0,30)
    closeBtn.Position = UDim2.new(1,-35,0,0)
    closeBtn.Text = "X"
    closeBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)
    closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)
    local scroll = Instance.new("ScrollingFrame", main)
    scroll.Size = UDim2.new(1,-10,1,-35)
    scroll.Position = UDim2.new(0,5,0,35)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 5
    scroll.CanvasSize = UDim2.new(0,0,0,10)
    local toggleStates = {}
    local function addToggle(text, y, callback)
        local btn = Instance.new("TextButton", scroll)
        btn.Size = UDim2.new(1,0,0,35)
        btn.Position = UDim2.new(0,0,0,y)
        btn.Text = text.." [关]"
        btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 14
        Instance.new("UICorner", btn)
        toggleStates[text] = false
        btn.MouseButton1Click:Connect(function()
            toggleStates[text] = not toggleStates[text]
            btn.Text = text..(toggleStates[text] and " [开]" or " [关]")
            callback(toggleStates[text])
        end)
    end
    local function addButton(text, y, callback)
        local btn = Instance.new("TextButton", scroll)
        btn.Size = UDim2.new(1,0,0,35)
        btn.Position = UDim2.new(0,0,0,y)
        btn.Text = text
        btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 14
        Instance.new("UICorner", btn)
        btn.MouseButton1Click:Connect(callback)
    end
    local y = 5
    addToggle("无敌模式", y, function(v) if v then EnableGodMode() else DisableGodMode() end end); y=y+40
    addButton("克隆全部道具", y, function() EnableItemSpawn(); Notify("道具已克隆") end); y=y+40
    addToggle("自动拾取", y, function(v) toggleLoop("pickup", v, autoPickupItems) end); y=y+40
    addToggle("自动捡金币", y, function(v) toggleLoop("coin", v, autoPickupCoins) end); y=y+40
    addToggle("自动开容器", y, function(v) toggleLoop("container", v, autoOpenContainers) end); y=y+40
    addToggle("自动开门", y, function(v) toggleLoop("dooropen", v, autoOpenDoorsLoop) end); y=y+40
    addToggle("透视真门", y, function(v) if v then EnableDoorESP() else DisableDoorESP() end end); y=y+40
    addToggle("透视假门", y, function(v) if v then EnableFakeDoorESP() else DisableFakeDoorESP() end end); y=y+40
    addToggle("透视怪物", y, function(v) if v then EnableMonsterESP() else DisableMonsterESP() end end); y=y+40
    addToggle("透视道具", y, function(v) if v then EnableItemESP() else DisableItemESP() end end); y=y+40
    addButton("传送到最近的门", y, teleportToNearestDoor); y=y+40
    addButton("召唤飞行脚本", y, loadFlightScript); y=y+40
    local speedLabel = Instance.new("TextLabel", scroll)
    speedLabel.Size = UDim2.new(1,0,0,25); speedLabel.Position = UDim2.new(0,0,0,y)
    speedLabel.BackgroundTransparency = 1; speedLabel.Text = "移动速度: 16"
    speedLabel.TextColor3 = Color3.new(1,1,1); speedLabel.Font = Enum.Font.SourceSans; speedLabel.TextSize = 14
    y=y+25
    local speedSlider = Instance.new("Frame", scroll)
    speedSlider.Size = UDim2.new(1,0,0,15); speedSlider.Position = UDim2.new(0,0,0,y)
    speedSlider.BackgroundColor3 = Color3.fromRGB(100,100,100)
    Instance.new("UICorner", speedSlider)
    local speedFill = Instance.new("Frame", speedSlider)
    speedFill.Size = UDim2.new(0,0,1,0); speedFill.BackgroundColor3 = Color3.fromRGB(0,255,0)
    local speedDragging = false
    speedSlider.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then speedDragging = true end end)
    speedSlider.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then speedDragging = false end end)
    UIS.InputChanged:Connect(function(input) if speedDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local relX = math.clamp(input.Position.X - speedSlider.AbsolutePosition.X, 0, speedSlider.AbsoluteSize.X)
        local ratio = relX / speedSlider.AbsoluteSize.X
        desiredWalkSpeed = math.floor(16 + ratio * (100 - 16))
        speedFill.Size = UDim2.new(ratio,0,1,0)
        speedLabel.Text = "移动速度: "..desiredWalkSpeed
    end end)
    y=y+20
    local rangeLabel = Instance.new("TextLabel", scroll)
    rangeLabel.Size = UDim2.new(1,0,0,25); rangeLabel.Position = UDim2.new(0,0,0,y)
    rangeLabel.BackgroundTransparency = 1; rangeLabel.Text = "交互范围: 15"
    rangeLabel.TextColor3 = Color3.new(1,1,1); rangeLabel.Font = Enum.Font.SourceSans; rangeLabel.TextSize = 14
    y=y+25
    local rangeSlider = Instance.new("Frame", scroll)
    rangeSlider.Size = UDim2.new(1,0,0,15); rangeSlider.Position = UDim2.new(0,0,0,y)
    rangeSlider.BackgroundColor3 = Color3.fromRGB(100,100,100)
    Instance.new("UICorner", rangeSlider)
    local rangeFill = Instance.new("Frame", rangeSlider)
    rangeFill.Size = UDim2.new(0,0,1,0); rangeFill.BackgroundColor3 = Color3.fromRGB(0,255,255)
    local rangeDragging = false
    rangeSlider.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then rangeDragging = true end end)
    rangeSlider.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then rangeDragging = false end end)
    UIS.InputChanged:Connect(function(input) if rangeDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local relX = math.clamp(input.Position.X - rangeSlider.AbsolutePosition.X, 0, rangeSlider.AbsoluteSize.X)
        local ratio = relX / rangeSlider.AbsoluteSize.X
        interactRange = math.floor(5 + ratio * (1000 - 5))
        rangeFill.Size = UDim2.new(ratio,0,1,0)
        rangeLabel.Text = "交互范围: "..interactRange
    end end)
    y=y+20
    scroll.CanvasSize = UDim2.new(0,0,0,y+10)
    Notify("已启用备用界面")
end
