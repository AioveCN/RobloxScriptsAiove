-- This file has been deobfuscated Luraph using Hurricane https://discord.com/invite/AbeurBzKXe
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/黑曜石主库.ui"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/主题管理.ui"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/配置管理.ui"))()
Library.AccentColor = Color3.fromRGB(0, 120, 255)
Library.MainColor = Color3.fromRGB(20, 25, 40)
Library.BackgroundColor = Color3.fromRGB(15, 18, 30)
Library.OutlineColor = Color3.fromRGB(40, 90, 180)
Library.FontColor = Color3.fromRGB(220, 235, 255)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer
local Character = LP.Character or LP.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")
local KillAura = {Enabled = false, Range = 50, Method = "范围"}
local ChopAura = {Enabled = false, Range = 30, Interval = 0.1, DamageMulti = 3}
local AutoFeed = {Enabled = false, Foods = {}, Threshold = 75}
local AutoCook = {Enabled = false, Items = {}}
local AutoCraft = {Enabled = false, ItemName = "Shelf", Interval = 5}
local AutoPlant = {Enabled = false, Shape = "square", Size = 80, Height = 3, Spacing = 1, Delay = 1}
local FunPattern = {Enabled = false, Pattern = "sphere", Speed = 5, Radius = 75}
local CollisionBox = {Show = false, Wolf = false, Bunny = false, Cultist = false, All = false, Size = 10}
local Fishing = {Auto = false, NoDelay = false, Instant = false}
local AutoStunDeer = false
local GodMode = false
local AutoPullRawMeat = false
local AutoSaveChild = false
local AutoOpenChest = false
local ChestAura = false
local ChestAuraRange = 50
local AutoEquipBest = false
local AutoEquipSelected = false
local SelectedWeapon = "Strong Axe"
local AutoToolSwitch = false
local BearTrapEnabled = false
local BearTrapTarget = "无"
local InstantInteract = false
local AntiAFKEnabled = false
local InfiniteJumpEnabled = false
local NightVisionEnabled = false
local FullbrightEnabled = false
local DisableFogEnabled = false
local DisableCampfireEffect = false
local mapLoadRunning = false
local MapLoadSpeed = 0.8
local SpeedEnabled = false
local SpeedValue = 16
local NoclipEnabled = false
local FlySpeed = 1
local IgnoreMobs = false
local godModeSpamActive = false
local PullConfig = {
    Enabled = false,
    Speed = 0.5,
    Target = "自己",
    SelectedFuel = {},
    SelectedScrap = {},
    SelectedEquip = {},
    SelectedFood = {},
    SelectedMed = {},
}
local ESP = {ItemsEnabled = false, MobsEnabled = false, SelectedItems = {}, SelectedMobs = {}}
local originalSizes = {}
local kidESPData = {}
local originalCharParent = nil
local ItemCN = {
    ["木头"]="Log", ["煤"]="Coal", ["油桶"]="Fuel Canister", ["椅子"]="Chair", ["生物燃料"]="Biofuel",
    ["螺栓"]="Bolt", ["破风扇"]="Broken Fan", ["坏微波炉"]="Broken Microwave", ["旧收音机"]="Old Radio",
    ["洗衣机"]="Washing Machine", ["旧汽车引擎"]="Old Car Engine", ["轮胎"]="Tyre", ["金属板"]="Sheet Metal",
    ["左轮手枪"]="Revolver", ["步枪"]="Rifle", ["皮革背心"]="Leather Body", ["铁甲"]="Iron Body",
    ["左轮弹药"]="Revolver Ammo", ["步枪弹药"]="Rifle Ammo", ["巨袋"]="Giant Sack", ["好的背包"]="Good Sack",
    ["强力斧头"]="Strong Axe", ["好的斧头"]="Good Axe", ["老斧头"]="Old Axe", ["电锯"]="Chainsaw", ["长矛"]="Spear",
    ["苹果"]="Apple", ["浆果"]="Berry", ["胡萝卜"]="Carrot", ["蛋糕"]="Cake", ["辣椒"]="Chili",
    ["熟肉块"]="Cooked Morsel", ["熟牛排"]="Cooked Steak", ["生肉块"]="Morsel", ["生牛排"]="Steak",
    ["绷带"]="Bandage", ["医疗包"]="MedKit", ["肋骨"]="Ribs", ["三文鱼"]="Salmon", ["鲭鱼"]="Mackerel",
}
local ToolsDamageIDs = {
    ["Old Axe"]="3_7367831688", ["Good Axe"]="112_7367831688", ["Strong Axe"]="116_7367831688",
    ["Chainsaw"]="647_8992824875", ["Infernal Sword"]="2_4340578793", ["Spear"]="196_8999010016"
}
local PlantShapeMap = {["正方形"]="square", ["圆形"]="circle", ["原地"]="original"}
local PatternMap = {["球形"]="sphere", ["项链"]="star", ["流星"]="meteor"}

local chopCount = 0
local chopStartTime = 0
local lastChopNotifyTime = 0
local lastNoToolNotifyTime = 0
local ignoreMobsConn = nil

local function getHRP()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getAnyTool(isChop)
    for name, _ in pairs(ToolsDamageIDs) do
        if isChop and name ~= "Old Axe" and name ~= "Good Axe" and name ~= "Strong Axe" and name ~= "Chainsaw" then continue end
        local inv = LP:FindFirstChild("Inventory")
        if inv and inv:FindFirstChild(name) then return inv[name] end
        local bp = LP:FindFirstChild("Backpack")
        if bp and bp:FindFirstChild(name) then return bp[name] end
        local char = LP.Character
        if char then
            local t = char:FindFirstChild(name)
            if t and t:IsA("Tool") then return t end
        end
    end
    return nil
end
local function equipTool(tool)
    if tool then
        pcall(function()
            ReplicatedStorage.RemoteEvents.EquipItemHandle:FireServer("FireAllClients", tool)
        end)
    end
end
local function unequipTool(tool)
    if tool then
        pcall(function()
            ReplicatedStorage.RemoteEvents.UnequipItemHandle:FireServer("FireAllClients", tool)
        end)
    end
end
local PullDelay = 0.1
local function moveItemToPos(item, pos)
    if not item or not item:IsDescendantOf(Workspace) then return end
    pcall(function()
        local hrp = getHRP()
        if hrp then
            if item:IsA("Model") then
                item:PivotTo(hrp.CFrame * CFrame.new(0, 0, -3))
            elseif item:IsA("BasePart") then
                item.CFrame = hrp.CFrame * CFrame.new(0, 0, -3)
            end
            task.wait(PullDelay)
        end
        ReplicatedStorage.RemoteEvents.RequestStartDraggingItem:FireServer(item)
        task.wait(0.1)
        if item:IsA("Model") then
            item:PivotTo(CFrame.new(pos))
        elseif item:IsA("BasePart") then
            item.CFrame = CFrame.new(pos)
        end
        task.wait(0.05)
        ReplicatedStorage.RemoteEvents.StopDraggingItem:FireServer(item)
    end)
end
local function getPullPos()
    if PullConfig.Target == "篝火" then
        return Vector3.new(-0.0967, 12, -0.178)
    elseif PullConfig.Target == "建造台" then
        return Vector3.new(21.67, 6.34, -4.05)
    else
        local hrp = getHRP()
        return hrp and (hrp.Position + Vector3.new(0, 2, 0)) or Vector3.new(0, 20, 0)
    end
end
local function getChildrenList()
    local list, names = {}, {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name:match("^Lost Child") or obj.Name:match("Dino Kid") or obj.Name:match("kraken kid") or obj.Name:match("Squid kid") or obj.Name:match("Koala")) then
            table.insert(list, obj)
            table.insert(names, obj.Name)
        end
    end
    return list, names
end
local function loadLuGuan()
    pcall(function()
        local name = "撸管（R15）"
        for _, c in ipairs({LP.Backpack, LP.Character}) do
            if c then
                local old = c:FindFirstChild(name)
                if old then old:Destroy() end
            end
        end
        if Workspace:FindFirstChild("animationContainer") then Workspace.animationContainer:Destroy() end
        local anim = Instance.new("Animation")
        anim.Name = "animationContainer"
        anim.AnimationId = "rbxassetid://507770453"
        anim.Parent = Workspace
        local tool = Instance.new("Tool")
        tool.Name = name
        tool.RequiresHandle = false
        tool.Parent = LP:WaitForChild("Backpack")
        task.delay(0.5, function()
            local c = LP.Character
            if c and c:FindFirstChild("Humanoid") then
                pcall(function() c.Humanoid:EquipTool(tool) end)
            end
        end)
        local active, track = false, nil
        tool.Equipped:Connect(function()
            local c = LP.Character
            local hum = c and c:FindFirstChild("Humanoid")
            local animator = hum and (hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator"))
            if not animator then return end
            active = true
            while active do
                if not track then track = animator:LoadAnimation(anim) end
                track:Play()
                track:AdjustSpeed(0.7)
                track.TimePosition = 0.6
                task.wait(0.1)
                while active and track and track.TimePosition < 0.7 do task.wait(0.05) end
                if track then track:Stop(); track:Destroy(); track = nil end
            end
        end)
        tool.Unequipped:Connect(function()
            active = false
            if track then track:Stop(); track:Destroy(); track = nil end
        end)
    end)
end
local saplingPositions = {}
local currentSaplingIndex = 1
local isPlanting = false
local function genPlantPos()
    local t = {}
    local half = AutoPlant.Size / 2
    local hrp = getHRP()
    local center = hrp and hrp.Position or Vector3.new(0, AutoPlant.Height, 0)
    local y = center.Y + AutoPlant.Height
    if AutoPlant.Shape == "square" then
        for x = -half, half, AutoPlant.Spacing do
            table.insert(t, Vector3.new(center.X + x, y, center.Z + half))
        end
        for z = half, -half, -AutoPlant.Spacing do
            table.insert(t, Vector3.new(center.X + half, y, center.Z + z))
        end
        for x = half, -half, -AutoPlant.Spacing do
            table.insert(t, Vector3.new(center.X + x, y, center.Z - half))
        end
        for z = -half, half, AutoPlant.Spacing do
            table.insert(t, Vector3.new(center.X - half, y, center.Z + z))
        end
    elseif AutoPlant.Shape == "circle" then
        local r = half
        local n = math.floor(2 * math.pi * r / AutoPlant.Spacing)
        for i = 1, n do
            local a = (i / n) * 2 * math.pi
            table.insert(t, Vector3.new(center.X + r * math.cos(a), y, center.Z + r * math.sin(a)))
        end
    else
        table.insert(t, Vector3.new(center.X, y, center.Z))
    end
    return t
end
local function doPlant()
    if isPlanting then return false end
    isPlanting = true
    local ok = false
    local sap = ReplicatedStorage:FindFirstChild("TempStorage") and ReplicatedStorage.TempStorage:FindFirstChild("Sapling")
    if not sap then
        sap = Workspace:FindFirstChild("Items") and Workspace.Items:FindFirstChild("Sapling")
    end
    if sap then
        local pos = saplingPositions[currentSaplingIndex]
        pcall(function()
            ReplicatedStorage.RemoteEvents.StopDraggingItem:FireServer(sap)
            task.wait(0.1)
            ReplicatedStorage.RemoteEvents.RequestPlantItem:InvokeServer(sap, pos)
            ok = true
        end)
        currentSaplingIndex += 1
        if currentSaplingIndex > #saplingPositions then currentSaplingIndex = 1 end
    end
    isPlanting = false
    return ok
end
local patternAngle = 0
local function genPattern(count)
    local t = {}
    patternAngle += FunPattern.Speed * 0.01
    local c = Vector3.new(0.649, 100, -3.8)
    local r = FunPattern.Radius
    if FunPattern.Pattern == "sphere" then
        for i = 1, count do
            local phi = math.acos(-1 + (2 * i - 1) / count)
            local theta = math.sqrt(count * math.pi) * phi
            t[i] = c + Vector3.new(
                r * math.cos(theta + patternAngle) * math.sin(phi),
                r * math.sin(theta + patternAngle) * math.sin(phi),
                r * math.cos(phi)
            )
        end
    elseif FunPattern.Pattern == "star" then
        for i = 1, count do
            local a = (i / count) * math.pi * 2 * 5 + patternAngle
            local rad = r * (i % 2 == 0 and 0.5 or 1)
            t[i] = c + Vector3.new(rad * math.cos(a), 0, rad * math.sin(a))
        end
    elseif FunPattern.Pattern == "meteor" then
        for i = 1, count do
            local a = (i / count) * math.pi * 2 + patternAngle
            t[i] = c + Vector3.new(
                r * math.cos(a),
                r * 0.5 * math.sin(a * 2),
                r * math.sin(a)
            )
        end
    end
    return t
end
local function updateHitbox(model)
    local root = model:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local n = model.Name:lower()
    if not originalSizes[model] then originalSizes[model] = root.Size end
    local should = CollisionBox.All or
        (CollisionBox.Wolf and (n:find("wolf") or n:find("alpha"))) or
        (CollisionBox.Bunny and n:find("bunny")) or
        (CollisionBox.Cultist and (n:find("cultist") or n:find("cross")))
    if should and CollisionBox.Show then
        root.Size = Vector3.new(CollisionBox.Size, CollisionBox.Size, CollisionBox.Size)
        root.Transparency = 0.5
        root.Color = Color3.new(1, 1, 1)
        root.Material = Enum.Material.Neon
        root.CanCollide = false
    else
        if originalSizes[model] then root.Size = originalSizes[model] end
        root.Transparency = 1
        root.Material = Enum.Material.Plastic
        root.CanCollide = true
    end
end
local function getChests()
    local c, n = {}, {}
    local idx = 1
    for _, item in ipairs(Workspace:WaitForChild("Items"):GetChildren()) do
        if item.Name:match("^Item Chest") and not item:GetAttribute("Opened") then
            table.insert(c, item)
            table.insert(n, "宝箱 " .. idx)
            idx += 1
        end
    end
    return c, n
end
local function chestPrompts(model)
    local t = {}
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("ProximityPrompt") then table.insert(t, d) end
    end
    return t
end
local function updateKidESP()
    local hrp = getHRP()
    if not hrp then return end
    local pos = hrp.Position
    for _, child in ipairs(Workspace:GetDescendants()) do
        if child:IsA("Model") and (child.Name:match("^Lost Child") or child.Name:match("Dino Kid") or child.Name:match("kraken") or child.Name:match("Squid") or child.Name:match("Koala")) then
            local part = child:FindFirstChild("HumanoidRootPart") or child.PrimaryPart
            if part and not kidESPData[child] then
                local gui = Instance.new("BillboardGui")
                gui.Name = "KidESP"
                gui.Adornee = part
                gui.Size = UDim2.new(0, 120, 0, 40)
                gui.AlwaysOnTop = true
                gui.MaxDistance = 10000
                local lbl = Instance.new("TextLabel", gui)
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = Color3.fromRGB(0, 255, 255)
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 16
                lbl.TextStrokeTransparency = 0.2
                gui.Parent = part
                kidESPData[child] = gui
                child.AncestryChanged:Connect(function(_, p)
                    if not p then
                        local g = part:FindFirstChild("KidESP")
                        if g then g:Destroy() end
                        kidESPData[child] = nil
                    end
                end)
            end
            if kidESPData[child] and part then
                local dist = math.floor((pos - part.Position).Magnitude)
                kidESPData[child].TextLabel.Text = "小孩 " .. dist .. "m"
            end
        end
    end
end
local function mapLoadLoop()
    task.spawn(function()
        local hrp = getHRP()
        if not hrp then return end
        local center = Vector3.new(-0.0967, 7.937, -0.178)
        local angle, radius, height = 0, 10, 400
        while mapLoadRunning do
            angle += 0.15 * MapLoadSpeed
            radius = math.min(radius + 2 * MapLoadSpeed, 4000)
            local p = Vector3.new(
                center.X + math.cos(angle) * radius,
                height + math.sin(angle * 0.3) * 60,
                center.Z + math.sin(angle) * radius
            )
            hrp.CFrame = CFrame.new(p)
            hrp.Velocity = Vector3.zero
            task.wait(0.03 / MapLoadSpeed)
        end
        hrp.CFrame = CFrame.new(center + Vector3.new(0, 5, 0))
    end)
end
local function autoFishingLoop()
    task.spawn(function()
        while Fishing.Auto do
            local gui = LP:FindFirstChild("PlayerGui") and LP.PlayerGui:FindFirstChild("Interface") and LP.PlayerGui.Interface:FindFirstChild("FishingCatchFrame")
            if gui and gui.Visible then
                local bar = gui:FindFirstChild("TimingBar") and gui.TimingBar:FindFirstChild("SuccessArea")
                local cur = gui.TimingBar and gui.TimingBar:FindFirstChild("Bar")
                local btn = LP.PlayerGui:FindFirstChild("MobileButtons") and LP.PlayerGui.MobileButtons:FindFirstChild("Frame") and LP.PlayerGui.MobileButtons.Frame:FindFirstChild("Button3")
                if bar and cur and btn then
                    local function overlap(f1, f2)
                        local p1, s1 = f1.AbsolutePosition, f1.AbsoluteSize
                        local p2, s2 = f2.AbsolutePosition, f2.AbsoluteSize
                        return not (p1.X + s1.X < p2.X or p2.X + s2.X < p1.X or p1.Y + s1.Y < p2.Y or p2.Y + s2.Y < p1.Y)
                    end
                    if overlap(bar, cur) then
                        for _, c in ipairs(getconnections(btn.MouseButton1Down)) do
                            pcall(function() c:Fire() end)
                        end
                    end
                end
            end
            task.wait(0.05)
        end
    end)
end
local function noDelayFishingLoop()
    task.spawn(function()
        while Fishing.NoDelay do
            local btn = LP.PlayerGui:FindFirstChild("MobileButtons") and LP.PlayerGui.MobileButtons:FindFirstChild("Frame") and LP.PlayerGui.MobileButtons.Frame:FindFirstChild("Button3")
            local gui = LP.PlayerGui:FindFirstChild("Interface") and LP.PlayerGui.Interface:FindFirstChild("FishingCatchFrame")
            if gui and gui.Visible and btn then
                for _, c in ipairs(getconnections(btn.MouseButton1Down)) do
                    pcall(function() c:Fire() end)
                end
            end
            task.wait(0)
        end
    end)
end
local function instantFishingLoop()
    task.spawn(function()
        while Fishing.Instant do
            pcall(function()
                local r = ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild("FinishFishing")
                if r then r:FireServer(true) end
            end)
            task.wait(0.1)
        end
    end)
end

task.spawn(function()
    while true do
        if KillAura.Enabled then
            local char = LP.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local tool = nil
                    for _, child in ipairs(char:GetChildren()) do
                        if child:IsA("Tool") then
                            tool = child
                            break
                        end
                    end
                    if not tool then
                        tool = getAnyTool(false)
                        if tool then
                            equipTool(tool)
                            task.wait(0.15)
                        end
                    end
                    if tool then
                        for _, target in ipairs(Workspace.Characters:GetChildren()) do
                            if target:IsA("Model") and target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("HitRegisters") and target ~= char then
                                local dist = (hrp.Position - target.HumanoidRootPart.Position).Magnitude
                                if KillAura.Method == "全图" or dist <= KillAura.Range then
                                    for i = 1, ChopAura.DamageMulti do
                                        pcall(function()
                                            ReplicatedStorage.RemoteEvents.ToolDamageObject:InvokeServer(target, tool, true, hrp.CFrame)
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.05)
    end
end)

task.spawn(function()
    while true do
        if ChopAura.Enabled then
            local char = LP.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local toolHandle = char:FindFirstChild("ToolHandle")
                if hrp and toolHandle then
                    local tool = toolHandle:FindFirstChild("OriginalItem") and toolHandle.OriginalItem.Value
                    if tool and ({["Old Axe"] = true, ["Good Axe"] = true, ["Strong Axe"] = true, ["Chainsaw"] = true, ["Stone Axe"] = true, ["Iron Axe"] = true})[tool.Name] then
                        if chopStartTime == 0 then chopStartTime = tick() end
                        local function chopFolder(folder)
                            if not folder then return end
                            for _, tree in next, folder:GetChildren() do
                                if tree:IsA("Model") and ({["Small Tree"] = true, ["TreeBig1"] = true, ["TreeBig2"] = true, ["TreeBig3"] = true})[tree.Name] and tree:FindFirstChild("HitRegisters") then
                                    local trunk = tree:FindFirstChild("Trunk") or tree:FindFirstChild("HumanoidRootPart") or tree.PrimaryPart
                                    if trunk and (hrp.Position - trunk.Position).Magnitude <= ChopAura.Range then
                                        for i = 1, ChopAura.DamageMulti do
                                            pcall(function()
                                                ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("ToolDamageObject"):InvokeServer(tree, tool, true, hrp.CFrame)
                                            end)
                                        end
                                    end
                                end
                            end
                        end
                        local map = Workspace:FindFirstChild("Map")
                        if map then
                            chopFolder(map:FindFirstChild("Foliage"))
                            chopFolder(map:FindFirstChild("Landmarks"))
                        end
                        chopCount = chopCount + 1
                        local now = tick()
                        if now - lastChopNotifyTime >= 2 then
                            Library:Notify("本次已砍 " .. chopCount .. " 次", 2)
                            lastChopNotifyTime = now
                        end
                    end
                else
                    local now = tick()
                    if now - lastNoToolNotifyTime >= 3 then
                        Library:Notify("请装备砍树工具！", 3)
                        lastNoToolNotifyTime = now
                    end
                    chopCount = 0
                    chopStartTime = 0
                end
            end
        else
            if chopCount > 0 then
                Library:Notify("本次共砍 " .. chopCount .. " 次", 3)
                chopCount = 0
                chopStartTime = 0
            end
        end
        task.wait(ChopAura.Interval)
    end
end)

RunService.Heartbeat:Connect(function()
    if SpeedEnabled and Humanoid and Humanoid.Parent then Humanoid.WalkSpeed = SpeedValue end
    if GodMode then
        pcall(function()
            ReplicatedStorage.RemoteEvents.DamagePlayer:FireServer(-math.huge)
        end)
    end
    if CollisionBox.Show then
        for _, m in ipairs(Workspace:GetDescendants()) do
            if m:IsA("Model") and m:FindFirstChild("HumanoidRootPart") then updateHitbox(m) end
        end
    end
    if ESP.MobsEnabled then updateKidESP() end
end)

task.spawn(function()
    while true do
        if AutoFeed.Enabled then
            local function getHunger()
                local gui = LP:FindFirstChild("PlayerGui") and LP.PlayerGui:FindFirstChild("Interface") and LP.PlayerGui.Interface:FindFirstChild("StatBars") and LP.PlayerGui.Interface.StatBars:FindFirstChild("HungerBar")
                return gui and math.floor(gui.Bar.Size.X.Scale * 100) or 100
            end
            if getHunger() <= AutoFeed.Threshold then
                for _, food in ipairs(AutoFeed.Foods) do
                    for _, item in ipairs(Workspace.Items:GetChildren()) do
                        if item.Name == food then
                            pcall(function()
                                ReplicatedStorage.RemoteEvents.RequestConsumeItem:InvokeServer(item)
                            end)
                            break
                        end
                    end
                end
            end
        end
        if AutoCook.Enabled then
            for _, item in ipairs(Workspace.Items:GetChildren()) do
                if table.find(AutoCook.Items, item.Name) then
                    moveItemToPos(item, Vector3.new(1.4, 25.9, -0.9))
                end
            end
        end
        if AutoCraft.Enabled then
            pcall(function()
                ReplicatedStorage.RemoteEvents.CraftItem:InvokeServer(AutoCraft.ItemName)
            end)
            task.wait(AutoCraft.Interval)
        end
        if PullConfig.Enabled then
            Library:Notify("拉取开始", 3)
            local all = {}
            local function gather(list)
                for _, en in ipairs(list) do
                    for _, item in ipairs(Workspace.Items:GetChildren()) do
                        if item.Name == en then table.insert(all, item) end
                    end
                end
            end
            gather(PullConfig.SelectedFuel)
            gather(PullConfig.SelectedScrap)
            gather(PullConfig.SelectedEquip)
            gather(PullConfig.SelectedFood)
            gather(PullConfig.SelectedMed)
            local total = #all
            local pulled = 0
            for _, item in ipairs(all) do
                if not PullConfig.Enabled then break end
                local target = getPullPos()
                moveItemToPos(item, target)
                pulled += 1
                if pulled % 10 == 0 then
                    Library:Notify("拉取进度: 已拉取 " .. pulled .. " / " .. total .. " 个物资", 3)
                end
                task.wait(math.max(0.05, PullConfig.Speed))
            end
            if total > 0 then
                Library:Notify("拉取完成: 共 " .. total .. " 个物资", 3)
            end
            task.wait(1)
        end
        if AutoPullRawMeat then
            for _, item in ipairs(Workspace.Items:GetChildren()) do
                if item.Name == "Morsel" or item.Name == "Steak" then
                    moveItemToPos(item, Vector3.new(1.4, 25.9, -0.9))
                end
            end
        end
        if AutoPlant.Enabled then
            if doPlant() then task.wait(AutoPlant.Delay) else task.wait(1) end
        end
        if FunPattern.Enabled then
            local logs = {}
            for _, item in ipairs(Workspace.Items:GetChildren()) do
                if item.Name:lower():find("log") and item:IsA("Model") then
                    table.insert(logs, item)
                end
            end
            if #logs > 0 then
                local poses = genPattern(#logs)
                for i, log in ipairs(logs) do
                    local main = log:FindFirstChildWhichIsA("BasePart")
                    if main then
                        pcall(function()
                            main.CFrame = CFrame.new(poses[i] or poses[1])
                            main.AssemblyLinearVelocity = Vector3.zero
                        end)
                    end
                end
            end
        end
        if InstantInteract then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then obj.HoldDuration = 0 end
            end
        end
        if AutoStunDeer then
            pcall(function()
                local remote = ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild("DeerHitByTorch")
                local deer = Workspace:FindFirstChild("Characters") and Workspace.Characters:FindFirstChild("Deer")
                if remote and deer then remote:InvokeServer(deer) end
            end)
        end
        if Fishing.Instant then
            pcall(function()
                local r = ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild("FinishFishing")
                if r then r:FireServer(true) end
            end)
        end
        if NoclipEnabled then
            local c = LP.Character
            if c then
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end
        if AutoSaveChild then
            local hrp = getHRP()
            if hrp then
                for _, child in ipairs(Workspace:GetDescendants()) do
                    if not AutoSaveChild then break end
                    if child:IsA("Model") and (child.Name:match("^Lost Child") or child.Name:match("Dino Kid") or child.Name:match("kraken") or child.Name:match("Squid") or child.Name:match("Koala")) then
                        local part = child:FindFirstChild("HumanoidRootPart") or child.PrimaryPart
                        if part then
                            hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0)
                            task.wait(2)
                        end
                    end
                end
            end
        end
        if AutoOpenChest then
            local hrp = getHRP()
            if hrp then
                local original = hrp.CFrame
                local chests = getChests()
                for _, chest in ipairs(chests) do
                    if not AutoOpenChest then break end
                    local part = chest.PrimaryPart or chest:FindFirstChildWhichIsA("BasePart")
                    if part then
                        hrp.CFrame = part.CFrame + Vector3.new(0, 6, 0)
                        for _, prompt in ipairs(chestPrompts(chest)) do
                            pcall(function() fireproximityprompt(prompt, math.huge) end)
                        end
                        local t = tick()
                        while AutoOpenChest and tick() - t < 3 do task.wait() end
                    end
                end
                hrp.CFrame = original
            end
        end
        if ChestAura then
            local hrp = getHRP()
            if hrp then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj.Name:match("^Item Chest") then
                        local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                        if part and (hrp.Position - part.Position).Magnitude <= ChestAuraRange then
                            for _, prompt in ipairs(obj:GetDescendants()) do
                                if prompt:IsA("ProximityPrompt") then
                                    pcall(function() fireproximityprompt(prompt, math.huge) end)
                                end
                            end
                        end
                    end
                end
            end
        end
        if BearTrapEnabled then
            if BearTrapTarget == "无" then
                BearTrapEnabled = false
            else
                local target = Players:FindFirstChild(BearTrapTarget)
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local tPos = target.Character.HumanoidRootPart.Position + Vector3.new(0, 1, 0)
                    local traps = {}
                    for _, s in ipairs(Workspace.Structures:GetChildren()) do
                        if s.Name:find("Bear Trap") then table.insert(traps, s) end
                    end
                    for _, i in ipairs(Workspace.Items:GetChildren()) do
                        if i.Name:find("Bear Trap") then table.insert(traps, i) end
                    end
                    for _, trap in ipairs(traps) do
                        if not BearTrapEnabled then break end
                        if not trap.PrimaryPart then
                            for _, p in ipairs(trap:GetChildren()) do
                                if p:IsA("BasePart") then trap.PrimaryPart = p; break end
                            end
                        end
                        if trap.PrimaryPart then
                            pcall(function()
                                ReplicatedStorage.RemoteEvents.RequestStartDraggingItem:FireServer(trap)
                                trap:SetPrimaryPartCFrame(CFrame.new(tPos))
                                ReplicatedStorage.RemoteEvents.StopDraggingItem:FireServer(trap)
                                ReplicatedStorage.RemoteEvents.RequestSetTrap:FireServer(trap)
                            end)
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

local Window = Library:CreateWindow({
    Title = "森林中的99夜",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})
Library:Notify("已加载", 5)
local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Combat = Window:AddTab("战斗", "sword"),
    Auto = Window:AddTab("自动", "cog"),
    Teleport = Window:AddTab("传送", "map-pin"),
    Pull = Window:AddTab("拉取物品", "truck"),
    Player = Window:AddTab("玩家", "user"),
    Visual = Window:AddTab("视觉", "eye"),
    Fun = Window:AddTab("趣味", "sparkles"),
    Map = Window:AddTab("地图加载", "globe"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者信息")
NoticeGroup:AddLabel("Aiove")
NoticeGroup:AddLabel("QQ: 3999698324")

local CombatGroup1 = Tabs.Combat:AddLeftGroupbox("攻击")
CombatGroup1:AddToggle('KillAuraToggle', {Text = '杀戮光环', Default = false, Callback = function(v) KillAura.Enabled = v end})
CombatGroup1:AddDropdown('KillAuraMethod', {Text = '攻击方式', Values = {'范围','全图'}, Default = '范围', Callback = function(v) KillAura.Method = v end})
CombatGroup1:AddSlider('KillAuraRange', {Text = '攻击范围', Default = 50, Min = 0, Max = 500, Rounding = 0, Callback = function(v) KillAura.Range = v end})
CombatGroup1:AddButton({Text = '显示当前武器', Func = function()
    local tool = getAnyTool(false)
    Library:Notify("当前武器: " .. (tool and tool.Name or "无"), 3)
end})
CombatGroup1:AddToggle('GodMode', {Text = '无敌（开了死）', Default = false, Callback = function(v) GodMode = v end})
CombatGroup1:AddToggle('IgnoreMobs', {Text = '上帝模式（不会死）', Default = false, Callback = function(v)
    IgnoreMobs = v
    godModeSpamActive = v
    if v then
        Library:Notify("上帝模式已开启", 3)
        local char = LP.Character
        if char and char.Parent then
            originalCharParent = char.Parent
            pcall(function() char.Parent = Workspace end)
        end
        if ignoreMobsConn then ignoreMobsConn:Disconnect() end
        ignoreMobsConn = RunService.Heartbeat:Connect(function()
            if not IgnoreMobs then return end
            local char = LP.Character
            if char and char.Parent ~= Workspace then
                originalCharParent = char.Parent
                pcall(function() char.Parent = Workspace end)
            end
            local charsFolder = Workspace:FindFirstChild("Characters")
            if charsFolder then
                for _, mob in ipairs(charsFolder:GetChildren()) do
                    if mob ~= LP.Character and mob:IsA("Model") then
                        pcall(function()
                            for _, desc in ipairs(mob:GetDescendants()) do
                                if desc:IsA("NumberValue") then
                                    local n = desc.Name:lower()
                                    if n:find("range") or n:find("distance") or n:find("aggro") or n:find("vision") or n:find("radius") or n:find("reach") or n:find("sight") or n:find("aware") then
                                        desc.Value = -999999
                                    end
                                end
                                if desc:IsA("ObjectValue") then
                                    local n = desc.Name:lower()
                                    if n:find("target") or n:find("focus") or n:find("enemy") or n:find("player") or n:find("victim") or n:find("prey") then
                                        if desc.Value == LP.Character or desc.Value == LP or (desc.Value and desc.Value:IsDescendantOf(LP.Character)) then
                                            desc.Value = nil
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
            end
        end)
    else
        Library:Notify("上帝模式已关闭", 3)
        if ignoreMobsConn then
            ignoreMobsConn:Disconnect()
            ignoreMobsConn = nil
        end
        local char = LP.Character
        if char and originalCharParent then
            pcall(function() char.Parent = originalCharParent end)
            originalCharParent = nil
        end
    end
end})

local CombatGroup2 = Tabs.Combat:AddRightGroupbox("碰撞箱")
CombatGroup2:AddToggle('CollisionShow', {Text = '显示碰撞箱', Default = false, Callback = function(v) CollisionBox.Show = v end})
CombatGroup2:AddToggle('CollisionWolf', {Text = '狼碰撞箱', Default = false, Callback = function(v) CollisionBox.Wolf = v end})
CombatGroup2:AddToggle('CollisionBunny', {Text = '兔子碰撞箱', Default = false, Callback = function(v) CollisionBox.Bunny = v end})
CombatGroup2:AddToggle('CollisionCultist', {Text = '邪教徒碰撞箱', Default = false, Callback = function(v) CollisionBox.Cultist = v end})
CombatGroup2:AddToggle('CollisionAll', {Text = '全部碰撞箱', Default = false, Callback = function(v) CollisionBox.All = v end})
CombatGroup2:AddSlider('CollisionSize', {Text = '碰撞箱大小', Default = 10, Min = 2, Max = 250, Rounding = 0, Callback = function(v) CollisionBox.Size = v end})

local CombatGroup3 = Tabs.Combat:AddLeftGroupbox("装备")
CombatGroup3:AddToggle('AutoEquipBest', {Text = '自动装备最佳武器', Default = false, Callback = function(v)
    AutoEquipBest = v
    if v then
        task.spawn(function()
            while AutoEquipBest do
                local c = LP.Character
                if c then
                    local best, bestDmg = nil, 0
                    for name, id in pairs(ToolsDamageIDs) do
                        local t = LP:FindFirstChild("Inventory") and LP.Inventory:FindFirstChild(name)
                        if t then
                            local dmg = tonumber(id:match("^(%d+)_")) or 0
                            if dmg > bestDmg then bestDmg = dmg; best = t end
                        end
                    end
                    if best then equipTool(best) end
                end
                task.wait(0.5)
            end
            local t = getAnyTool(false); unequipTool(t)
        end)
    end
end})
CombatGroup3:AddDropdown('SelectedWeapon', {Text = '选择武器', Values = {"Old Axe","Good Axe","Strong Axe","Chainsaw","Infernal Sword","Spear"}, Default = 'Strong Axe', Callback = function(v) SelectedWeapon = v end})
CombatGroup3:AddToggle('AutoEquipSelected', {Text = '自动装备选定武器', Default = false, Callback = function(v)
    AutoEquipSelected = v
    if v then
        task.spawn(function()
            while AutoEquipSelected do
                local c = LP.Character
                if c then
                    local t = LP:FindFirstChild("Inventory") and LP.Inventory:FindFirstChild(SelectedWeapon)
                    if t then equipTool(t) else
                        Library:Notify("武器未找到: " .. SelectedWeapon, 3)
                        AutoEquipSelected = false
                        break
                    end
                end
                task.wait(0.5)
            end
            local t = LP:FindFirstChild("Inventory") and LP.Inventory:FindFirstChild(SelectedWeapon); unequipTool(t)
        end)
    end
end})
CombatGroup3:AddToggle('AutoToolSwitch', {Text = '随机工具切换', Default = false, Callback = function(v)
    AutoToolSwitch = v
    if v then
        task.spawn(function()
            while AutoToolSwitch do
                local hrp = getHRP()
                if not hrp then task.wait(1); continue end
                local hasEnemy = false
                for _, mob in ipairs(Workspace.Characters:GetChildren()) do
                    if mob:IsA("Model") then
                        local p = mob:FindFirstChildWhichIsA("BasePart")
                        if p and (p.Position - hrp.Position).Magnitude <= 50 then hasEnemy = true; break end
                    end
                end
                local hasTree = false
                local map = Workspace:FindFirstChild("Map")
                if map then
                    for _, folder in ipairs({map:FindFirstChild("Foliage"), map:FindFirstChild("Landmarks")}) do
                        if folder then
                            for _, obj in ipairs(folder:GetChildren()) do
                                if obj:IsA("Model") and obj.Name:match("Tree") then
                                    local trunk = obj:FindFirstChild("Trunk")
                                    if trunk and (trunk.Position - hrp.Position).Magnitude <= 50 then hasTree = true; break end
                                end
                            end
                        end
                    end
                end
                if hasEnemy then
                    for _, n in ipairs({"Infernal Sword","Spear","Chainsaw","Strong Axe","Good Axe"}) do
                        local t = LP:FindFirstChild("Inventory") and LP.Inventory:FindFirstChild(n)
                        if t then equipTool(t); break end
                    end
                elseif hasTree then
                    for _, n in ipairs({"Chainsaw","Strong Axe","Good Axe","Old Axe"}) do
                        local t = LP:FindFirstChild("Inventory") and LP.Inventory:FindFirstChild(n)
                        if t then equipTool(t); break end
                    end
                else
                    local best, bestDmg = nil, 0
                    for name, id in pairs(ToolsDamageIDs) do
                        local t = LP:FindFirstChild("Inventory") and LP.Inventory:FindFirstChild(name)
                        if t then
                            local dmg = tonumber(id:match("^(%d+)_")) or 0
                            if dmg > bestDmg then bestDmg = dmg; best = t end
                        end
                    end
                    if best then equipTool(best) end
                end
                task.wait(1)
            end
            local t = getAnyTool(false); unequipTool(t)
        end)
    end
end})

local CombatGroup4 = Tabs.Combat:AddRightGroupbox("恶搞")
local bearTrapList = {"无"}
local bearTrapDropdown = CombatGroup4:AddDropdown('BearTrapTarget', {Text = '选择攻击玩家', Values = bearTrapList, Default = '无', Callback = function(v) BearTrapTarget = v end})
CombatGroup4:AddButton({Text = '刷新玩家列表', Func = function()
    local list = {"无"}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then table.insert(list, p.Name) end
    end
    bearTrapList = list
    bearTrapDropdown:SetValues(list)
    Library:Notify("已刷新: " .. #list .. "人", 2)
end})
CombatGroup4:AddToggle('BearTrapToggle', {Text = '自动捕兽夹攻击', Default = false, Callback = function(v) BearTrapEnabled = v end})

local AutoGroup1 = Tabs.Auto:AddLeftGroupbox("砍树与钓鱼")
AutoGroup1:AddLabel("[使用方式]拿起你要用来砍树的工具")
AutoGroup1:AddToggle('ChopAuraToggle', {Text = '砍树光环', Default = false, Callback = function(v) ChopAura.Enabled = v end})
AutoGroup1:AddLabel("[温馨提示]范围开的越大砍树越慢")
AutoGroup1:AddSlider('ChopAuraRange', {Text = '砍树范围', Default = 30, Min = 5, Max = 500, Rounding = 0, Callback = function(v) ChopAura.Range = v end})
AutoGroup1:AddSlider('ChopAuraInterval', {Text = '砍树频率(秒)', Default = 0.1, Min = 0.01, Max = 1, Rounding = 2, Callback = function(v) ChopAura.Interval = v end})
AutoGroup1:AddSlider('ChopAuraDamage', {Text = '伤害倍率', Default = 3, Min = 1, Max = 50, Rounding = 0, Callback = function(v) ChopAura.DamageMulti = v end})
AutoGroup1:AddToggle('FishingAuto', {Text = '自动钓鱼', Default = false, Callback = function(v) Fishing.Auto = v; if v then autoFishingLoop() end end})
AutoGroup1:AddToggle('FishingNoDelay', {Text = '无延迟钓鱼', Default = false, Callback = function(v) Fishing.NoDelay = v; if v then noDelayFishingLoop() end end})
AutoGroup1:AddToggle('FishingInstant', {Text = '秒钓鱼', Default = false, Callback = function(v) Fishing.Instant = v; if v then instantFishingLoop() end end})

local AutoGroup2 = Tabs.Auto:AddRightGroupbox("食物与烹饪")
AutoGroup2:AddToggle('AutoFeedToggle', {Text = '自动进食', Default = false, Callback = function(v) AutoFeed.Enabled = v end})
AutoGroup2:AddDropdown('AutoFeedFoods', {Text = '选择食物', Values = {"苹果","浆果","胡萝卜","蛋糕","辣椒","熟肉块","熟牛排"}, Multi = true, Callback = function(v)
    local en = {}
    for k, val in pairs(v) do
        local cn = type(k) == "number" and val or k
        if ItemCN[cn] then table.insert(en, ItemCN[cn]) end
    end
    AutoFeed.Foods = en
end})
AutoGroup2:AddSlider('AutoFeedThreshold', {Text = '饥饿阈值 %', Default = 75, Min = 0, Max = 100, Rounding = 0, Callback = function(v) AutoFeed.Threshold = v end})
AutoGroup2:AddDropdown('AutoCookItems', {Text = '烹饪食物', Values = {"生肉块","生牛排","肋骨","三文鱼","鲭鱼"}, Multi = true, Callback = function(v)
    local en = {}
    for k, val in pairs(v) do
        local cn = type(k) == "number" and val or k
        if ItemCN[cn] then table.insert(en, ItemCN[cn]) end
    end
    AutoCook.Items = en
end})
AutoGroup2:AddToggle('AutoCookToggle', {Text = '自动烹饪', Default = false, Callback = function(v) AutoCook.Enabled = v end})
AutoGroup2:AddToggle('AutoPullRawMeat', {Text = '自动拉生肉到篝火', Default = false, Callback = function(v) AutoPullRawMeat = v end})

local AutoGroup3 = Tabs.Auto:AddLeftGroupbox("制作与宝箱")
AutoGroup3:AddInput('CraftItemName', {Text = '制作物品名', Default = 'Shelf', Callback = function(v) AutoCraft.ItemName = v end})
AutoGroup3:AddSlider('CraftInterval', {Text = '制作间隔(秒)', Default = 5, Min = 1, Max = 60, Rounding = 0, Callback = function(v) AutoCraft.Interval = v end})
AutoGroup3:AddButton({Text = '制作一次', Func = function()
    pcall(function()
        ReplicatedStorage.RemoteEvents.CraftItem:InvokeServer(AutoCraft.ItemName)
        Library:Notify("已制作: " .. AutoCraft.ItemName, 2)
    end)
end})
AutoGroup3:AddToggle('AutoCraftToggle', {Text = '自动制作', Default = false, Callback = function(v) AutoCraft.Enabled = v end})
AutoGroup3:AddToggle('AutoOpenChest', {Text = '自动开全部宝箱', Default = false, Callback = function(v) AutoOpenChest = v end})
AutoGroup3:AddToggle('ChestAura', {Text = '宝箱光环', Default = false, Callback = function(v) ChestAura = v end})
AutoGroup3:AddSlider('ChestAuraRange', {Text = '光环范围', Default = 50, Min = 1, Max = 200, Rounding = 0, Callback = function(v) ChestAuraRange = v end})

local AutoGroup4 = Tabs.Auto:AddRightGroupbox("其它")
AutoGroup4:AddToggle('AutoStunDeerToggle', {Text = '自动眩晕鹿', Default = false, Callback = function(v) AutoStunDeer = v end})
AutoGroup4:AddToggle('AutoSaveChild', {Text = '自动救所有小孩[失效]', Default = false, Callback = function(v) AutoSaveChild = v end})

local TpGroup1 = Tabs.Teleport:AddLeftGroupbox("基础传送点")
TpGroup1:AddButton({Text = '传送到营火', Func = function()
    local hrp = getHRP()
    if hrp then hrp.CFrame = CFrame.new(0.431, 15.776, -1.886) end
end})
TpGroup1:AddButton({Text = '传送到安全区', Func = function()
    local part = Workspace:FindFirstChild("SafeZonePart") or Instance.new("Part")
    part.Anchored = true; part.Size = Vector3.new(30, 3, 30); part.Position = Vector3.new(0, 350, 0)
    part.Parent = Workspace
    local hrp = getHRP()
    if hrp then hrp.CFrame = CFrame.new(0, 360, 0) end
end})
TpGroup1:AddButton({Text = '传送到商人', Func = function()
    local hrp = getHRP()
    if hrp then hrp.CFrame = CFrame.new(-37.08, 3.98, -16.33) end
end})
TpGroup1:AddButton({Text = '传送回火旁', Func = function()
    local hrp = getHRP()
    if hrp then hrp.CFrame = CFrame.new(-0.0967, 7.937, -0.178) end
end})
TpGroup1:AddButton({Text = '传送到随机树', Func = function()
    local hrp = getHRP()
    if not hrp then return end
    local map = Workspace:FindFirstChild("Map")
    if not map then return end
    local trees = {}
    for _, f in ipairs({map:FindFirstChild("Foliage"), map:FindFirstChild("Landmarks")}) do
        if f then
            for _, obj in ipairs(f:GetChildren()) do
                if obj:IsA("Model") and obj.Name == "Small Tree" then
                    local trunk = obj:FindFirstChild("Trunk") or obj.PrimaryPart
                    if trunk then table.insert(trees, trunk) end
                end
            end
        end
    end
    if #trees > 0 then
        local t = trees[math.random(1, #trees)]
        hrp.CFrame = CFrame.new(t.Position + Vector3.new(3, 0, 3))
    end
end})

local TpGroup2 = Tabs.Teleport:AddRightGroupbox("目标传送")
local childList, childNames = getChildrenList()
local childDropdown = TpGroup2:AddDropdown('ChildSelect', {Text = '选择儿童', Values = childNames, Default = childNames[1] or "无"})
TpGroup2:AddButton({Text = '刷新儿童列表', Func = function()
    local list, names = getChildrenList()
    childDropdown:SetValues(names)
    Library:Notify("找到 " .. #names .. " 个小孩", 2)
end})
TpGroup2:AddButton({Text = '传送到选定儿童', Func = function()
    local selected = Library.Options.ChildSelect.Value
    if not selected or selected == "无" then Library:Notify("请先选择儿童", 3); return end
    local list, names = getChildrenList()
    for i, name in ipairs(names) do
        if name == selected then
            local part = list[i] and (list[i]:FindFirstChild("HumanoidRootPart") or list[i].PrimaryPart)
            if part then
                local hrp = getHRP()
                if hrp then hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0) end
            end
            break
        end
    end
end})
TpGroup2:AddButton({Text = '传送到最近宝箱', Func = function()
    local chests = getChests()
    local hrp = getHRP()
    if not hrp or #chests == 0 then Library:Notify("附近无宝箱", 2); return end
    local nearest, minDist = nil, math.huge
    for _, chest in ipairs(chests) do
        local part = chest.PrimaryPart or chest:FindFirstChildWhichIsA("BasePart")
        if part then
            local dist = (hrp.Position - part.Position).Magnitude
            if dist < minDist then minDist = dist; nearest = part end
        end
    end
    if nearest then hrp.CFrame = nearest.CFrame + Vector3.new(0, 5, 0) end
end})

local PullGroup1 = Tabs.Pull:AddLeftGroupbox("拉取设置")
PullGroup1:AddLabel("[温馨提示] 不要正面贴着火拉物品")
PullGroup1:AddSlider('PullDelaySlider', {Text = '物品停留时间(秒)', Default = 0.1, Min = 0.01, Max = 0.3, Rounding = 2, Callback = function(v) PullDelay = v end})
PullGroup1:AddDropdown('PullTarget', {Text = '拉取到', Values = {"自己", "篝火", "建造台"}, Default = "自己", Callback = function(v) PullConfig.Target = v end})
PullGroup1:AddSlider('PullSpeed', {Text = '拉取间隔(秒)', Default = 0.5, Min = 0.1, Max = 5, Rounding = 1, Callback = function(v) PullConfig.Speed = v end})
PullGroup1:AddToggle('PullToggle', {Text = '开始拉取', Default = false, Callback = function(v) PullConfig.Enabled = v if v then Library:Notify("拉取已启动", 3) else Library:Notify("拉取已停止", 3) end end})

local PullGroup2 = Tabs.Pull:AddRightGroupbox("选择物品")
PullGroup2:AddDropdown('PullFuel', {Text = '燃烧物', Values = {"木头","煤","油桶","椅子","生物燃料"}, Multi = true, Callback = function(v)
    local en = {}
    for k, val in pairs(v) do
        local cn = type(k) == "number" and val or k
        if ItemCN[cn] then table.insert(en, ItemCN[cn]) end
    end
    PullConfig.SelectedFuel = en
end})
PullGroup2:AddDropdown('PullScrap', {Text = '废品物', Values = {"螺栓","破风扇","坏微波炉","旧收音机","洗衣机","旧汽车引擎","轮胎","金属板"}, Multi = true, Callback = function(v)
    local en = {}
    for k, val in pairs(v) do
        local cn = type(k) == "number" and val or k
        if ItemCN[cn] then table.insert(en, ItemCN[cn]) end
    end
    PullConfig.SelectedScrap = en
end})
PullGroup2:AddDropdown('PullEquip', {Text = '装备物', Values = {"左轮手枪","步枪","皮革背心","铁甲","左轮弹药","步枪弹药","巨袋","好的背包","强力斧头","好的斧头"}, Multi = true, Callback = function(v)
    local en = {}
    for k, val in pairs(v) do
        local cn = type(k) == "number" and val or k
        if ItemCN[cn] then table.insert(en, ItemCN[cn]) end
    end
    PullConfig.SelectedEquip = en
end})
PullGroup2:AddDropdown('PullFood', {Text = '食物', Values = {"苹果","浆果","胡萝卜","蛋糕","辣椒","熟肉块","熟牛排","生肉块","生牛排"}, Multi = true, Callback = function(v)
    local en = {}
    for k, val in pairs(v) do
        local cn = type(k) == "number" and val or k
        if ItemCN[cn] then table.insert(en, ItemCN[cn]) end
    end
    PullConfig.SelectedFood = en
end})
PullGroup2:AddDropdown('PullMed', {Text = '药品', Values = {"绷带","医疗包"}, Multi = true, Callback = function(v)
    local en = {}
    for k, val in pairs(v) do
        local cn = type(k) == "number" and val or k
        if ItemCN[cn] then table.insert(en, ItemCN[cn]) end
    end
    PullConfig.SelectedMed = en
end})

local PlayerGroup1 = Tabs.Player:AddLeftGroupbox("移动与增强")
PlayerGroup1:AddToggle('SpeedToggle', {Text = '启用速度', Default = false, Callback = function(v)
    SpeedEnabled = v
    if not v and Humanoid then Humanoid.WalkSpeed = 16 end
end})
PlayerGroup1:AddSlider('SpeedSlider', {Text = '速度值', Default = 16, Min = 1, Max = 150, Rounding = 0, Callback = function(v) SpeedValue = v end})
PlayerGroup1:AddToggle('InfiniteJump', {Text = '无限跳', Default = false, Callback = function(v)
    InfiniteJumpEnabled = v
    if v then
        local conn = UIS.JumpRequest:Connect(function()
            local c = LP.Character
            if c then
                local r = c:FindFirstChild("HumanoidRootPart")
                if r then r.Velocity = Vector3.new(r.Velocity.X, 50, r.Velocity.Z) end
            end
        end)
        Toggles.InfiniteJump:SetCallback(function(v) if not v then conn:Disconnect() end end)
    end
end})
PlayerGroup1:AddToggle('NoclipToggle', {Text = '穿墙', Default = false, Callback = function(v) NoclipEnabled = v end})
PlayerGroup1:AddToggle('InstantInteract', {Text = '秒互动', Default = false, Callback = function(v) InstantInteract = v end})
PlayerGroup1:AddToggle('AntiAFK', {Text = '反挂机踢出', Default = false, Callback = function(v)
    AntiAFKEnabled = v
    if v then
        local conn = LP.Idled:Connect(function()
            local vu = game:GetService("VirtualUser")
            vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            wait(1)
            vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
    end
end})

local PlayerGroup2 = Tabs.Player:AddRightGroupbox("飞行")
PlayerGroup2:AddSlider('FlySpeed', {Text = '飞行速度', Default = 1, Min = 1, Max = 20, Rounding = 0, Callback = function(v) FlySpeed = v end})
PlayerGroup2:AddButton({Text = '加载外部飞行', Func = function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/kongbaNB/9178/refs/heads/main/fly.lua"))()
    end)
    Library:Notify("已尝试加载外部飞行", 2)
end})

local VisGroup1 = Tabs.Visual:AddLeftGroupbox("透视")
VisGroup1:AddToggle('ESPItemsToggle', {Text = '物品透视', Default = false, Callback = function(v) ESP.ItemsEnabled = v end})
VisGroup1:AddDropdown('ESPItems', {Text = '选择物品', Values = {"木头","螺栓","煤","宝箱","步枪","绷带","椅子","轮胎"}, Multi = true, Callback = function(v)
    ESP.SelectedItems = {}
    for k, val in pairs(v) do
        local cn = type(k) == "number" and val or k
        if ItemCN[cn] then ESP.SelectedItems[ItemCN[cn]] = true end
    end
end})
VisGroup1:AddToggle('ESPMobsToggle', {Text = '敌人/小孩透视', Default = false, Callback = function(v) ESP.MobsEnabled = v end})

local VisGroup2 = Tabs.Visual:AddRightGroupbox("环境")
VisGroup2:AddToggle('Fullbright', {Text = '全亮', Default = false, Callback = function(v)
    FullbrightEnabled = v
    if v then
        Lighting.Brightness = 2; Lighting.Ambient = Color3.new(1,1,1); Lighting.OutdoorAmbient = Color3.new(1,1,1)
        Lighting.ShadowSoftness = 0; Lighting.GlobalShadows = false
    else
        Lighting.Brightness = 1; Lighting.Ambient = Color3.new(0,0,0); Lighting.OutdoorAmbient = Color3.new(0.7,0.7,0.7)
        Lighting.GlobalShadows = true
    end
end})
VisGroup2:AddToggle('DisableFog', {Text = '关闭雾效', Default = false, Callback = function(v)
    DisableFogEnabled = v
    if v then Lighting.FogEnd = 100000 else Lighting.FogEnd = 1000 end
end})
VisGroup2:AddToggle('DisableCampfireEffect', {Text = '关闭篝火夜间效果', Default = false, Callback = function(v)
    DisableCampfireEffect = v
    local cc = Lighting:FindFirstChild("ColorCorrection")
    if cc then cc.Enabled = not v end
end})
VisGroup2:AddToggle('NightVision', {Text = '夜视', Default = false, Callback = function(v)
    NightVisionEnabled = v
    if v then
        Lighting.Ambient = Color3.new(1,1,1); Lighting.ColorShift_Bottom = Color3.new(1,1,1); Lighting.ColorShift_Top = Color3.new(1,1,1)
        Lighting.FogEnd = 100000; Lighting.FogStart = 100000; Lighting.Brightness = 1; Lighting.GlobalShadows = false; Lighting.OutdoorAmbient = Color3.new(1,1,1); Lighting.ClockTime = 12
    else
        Lighting.Ambient = Color3.new(0,0,0); Lighting.ColorShift_Bottom = Color3.new(0,0,0); Lighting.ColorShift_Top = Color3.new(0,0,0)
        Lighting.FogEnd = 1000; Lighting.FogStart = 0; Lighting.Brightness = 1; Lighting.GlobalShadows = true; Lighting.OutdoorAmbient = Color3.new(0.7,0.7,0.7)
    end
end})
VisGroup2:AddToggle('KidESP', {Text = '小孩透视', Default = false, Callback = function(v)
    if not v then
        for _, gui in pairs(kidESPData) do if gui then gui:Destroy() end end
        kidESPData = {}
    end
end})

local FunGroup1 = Tabs.Fun:AddLeftGroupbox("种植")
FunGroup1:AddDropdown('PlantShape', {Text = '种植形状', Values = {"正方形","圆形","原地"}, Default = "正方形", Callback = function(v) AutoPlant.Shape = PlantShapeMap[v] or "square" end})
FunGroup1:AddSlider('PlantSize', {Text = '种植范围', Default = 80, Min = 10, Max = 500, Rounding = 0, Callback = function(v) AutoPlant.Size = v end})
FunGroup1:AddSlider('PlantHeight', {Text = '种植高度', Default = 3, Min = 0, Max = 50, Rounding = 0, Callback = function(v) AutoPlant.Height = v end})
FunGroup1:AddSlider('PlantSpacing', {Text = '树苗间隔', Default = 1, Min = 0.5, Max = 10, Rounding = 1, Callback = function(v) AutoPlant.Spacing = v end})
FunGroup1:AddSlider('PlantDelay', {Text = '种植延迟(秒)', Default = 1, Min = 0.1, Max = 10, Rounding = 1, Callback = function(v) AutoPlant.Delay = v end})
FunGroup1:AddToggle('AutoPlantToggle', {Text = '自动种植', Default = false, Callback = function(v)
    AutoPlant.Enabled = v
    if v then saplingPositions = genPlantPos(); currentSaplingIndex = 1 end
end})

local FunGroup2 = Tabs.Fun:AddRightGroupbox("图案与娱乐")
FunGroup2:AddDropdown('PatternType', {Text = '图案类型', Values = {"球形","项链","流星"}, Default = "球形", Callback = function(v) FunPattern.Pattern = PatternMap[v] or "sphere" end})
FunGroup2:AddSlider('PatternRadius', {Text = '图案大小', Default = 75, Min = 10, Max = 500, Rounding = 0, Callback = function(v) FunPattern.Radius = v end})
FunGroup2:AddSlider('PatternSpeed', {Text = '旋转速度', Default = 5, Min = 1, Max = 20, Rounding = 0, Callback = function(v) FunPattern.Speed = v end})
FunGroup2:AddToggle('AutoPatternToggle', {Text = '自动形成图案', Default = false, Callback = function(v) FunPattern.Enabled = v end})
FunGroup2:AddButton({Text = '召唤撸管', Func = function()
    Library:Notify("生成中...", 2)
    loadLuGuan()
end})

local MapGroup = Tabs.Map:AddLeftGroupbox("地图加载")
MapGroup:AddLabel("从篝火开始高空螺旋扩大扫描")
MapGroup:AddLabel("自动加载所有未渲染区域")
MapGroup:AddSlider('MapLoadSpeedSlider', {Text = '加载速度', Default = 0.8, Min = 0.1, Max = 3, Rounding = 1, Callback = function(v) MapLoadSpeed = v end})
MapGroup:AddButton({Text = '开始自动加载地图', Func = function()
    if mapLoadRunning then Library:Notify("已经在加载中", 2); return end
    mapLoadRunning = true
    mapLoadLoop()
    Library:Notify("开始高空螺旋扫描", 3)
end})
MapGroup:AddButton({Text = '停止加载并落回篝火', Func = function()
    mapLoadRunning = false
    Library:Notify("已停止，返回篝火", 2)
end})

local SettGroup = Tabs.Settings:AddLeftGroupbox("菜单")
SettGroup:AddButton({Text = '卸载脚本', Func = function() Library:Unload() end})
SettGroup:AddLabel('菜单快捷键'):AddKeyPicker('MenuKeybind', {Default = 'RightShift', NoUI = true, Text = 'Menu keybind'})
Library.ToggleKeybind = Library.Options.MenuKeybind
if ThemeManager then
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("99NightsTheme")
    ThemeManager:ApplyToTab(Tabs.Settings)
end
if SaveManager then
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetFolder("99NightsConfig")
    SaveManager:BuildConfigSection(Tabs.Settings)
end

task.spawn(function()
    task.wait(2)
    local _, names = getChildrenList()
    childDropdown:SetValues(names)
end)

task.spawn(function()
    while true do
        if godModeSpamActive then
            pcall(function()
                ReplicatedStorage.RemoteEvents.DamagePlayer:FireServer(0/0)
            end)
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do
        if godModeSpamActive then
            pcall(function()
                ReplicatedStorage.RemoteEvents.AnalyticsTimeFirstPerson:FireServer(0, 60)
            end)
        end
        task.wait(1)
    end
end)

Library:Notify("已加载", 5)
