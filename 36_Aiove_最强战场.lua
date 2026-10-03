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
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local Window = Library:CreateWindow({
    Title = "最强战场",
    Footer = "终极战场 | Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify("最强战场脚本已加载 - 创作者：终极战场", 5)

local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Main = Window:AddTab("主要", "star"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel('终极战场 - 最强战场脚本')

local lockTargetPlayer = nil
local lockConnection = nil
local lockEnabled = false
local lockBackEnabled = false
local lockCircleEnabled = false
local lockLookAtEnabled = false
local lockUndergroundEnabled = false
local circleAngle = 0

local rangeParts = {}
local rangeConn = nil

local function stopLock()
    if lockConnection then
        lockConnection:Disconnect()
        lockConnection = nil
    end
end

local function startLock()
    stopLock()
    lockConnection = RunService.RenderStepped:Connect(function()
        if not lockEnabled or not lockTargetPlayer then return end
        local myChar = player.Character
        local targetChar = lockTargetPlayer.Character
        if not myChar or not targetChar then return end
        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
        if not myHRP or not targetHRP then return end

        local targetPos = targetHRP.Position
        local newPos

        if lockUndergroundEnabled then
            local behind = -targetHRP.CFrame.LookVector * 1.5
            newPos = targetPos + behind
            newPos = Vector3.new(newPos.X, targetPos.Y - 2.2, newPos.Z)
        elseif lockCircleEnabled then
            circleAngle = circleAngle + math.rad(4)
            local radius = 3
            newPos = targetPos + Vector3.new(math.cos(circleAngle) * radius, 0, math.sin(circleAngle) * radius)
        elseif lockBackEnabled then
            local backOffset = -targetHRP.CFrame.LookVector * 2.5
            newPos = targetPos + backOffset
        else
            newPos = targetPos + Vector3.new(0, 0, -2)
        end

        if lockLookAtEnabled then
            myHRP.CFrame = CFrame.lookAt(newPos, targetPos)
        else
            myHRP.CFrame = CFrame.new(newPos)
        end
    end)
end

local function clearRange()
    if rangeConn then
        rangeConn:Disconnect()
        rangeConn = nil
    end
    for _, part in ipairs(rangeParts) do
        if part then part:Destroy() end
    end
    rangeParts = {}
end

local HitboxGroup = Tabs.Main:AddLeftGroupbox("碰撞箱扩大")
HitboxGroup:AddToggle('HitboxExpand', {
    Text = '碰撞箱扩大',
    Default = false,
    Callback = function(state)
        local Core = require(ReplicatedStorage:WaitForChild("Core"))
        local orig = Core.Get("Combat", "Hit").Box
        if state then
            Core.Get("Combat", "Hit").Box = function(_, char, data)
                data = data or {}
                data.Size = Vector3.new(150, 150, 150)
                return orig(nil, char, data)
            end
        else
            Core.Get("Combat", "Hit").Box = orig
        end
    end
})
HitboxGroup:AddInput('HitboxX', {
    Text = '碰撞箱X轴',
    Default = "150",
    Callback = function(value)
    end
})
HitboxGroup:AddInput('HitboxY', {
    Text = '碰撞箱Y轴',
    Default = "150",
    Callback = function(value)
    end
})
HitboxGroup:AddInput('HitboxZ', {
    Text = '碰撞箱Z轴',
    Default = "150",
    Callback = function(value)
    end
})
HitboxGroup:AddToggle('ShowRange', {
    Text = '显示攻击碰撞箱范围',
    Default = false,
    Callback = function(state)
        clearRange()
        if state then
            local radius = 60
            local segments = 60
            for i = 1, segments do
                local part = Instance.new("Part")
                part.Anchored = true
                part.CanCollide = false
                part.Size = Vector3.new(0.2, 0.2, radius * 2 * math.pi / segments)
                part.Material = Enum.Material.Neon
                part.Color = Color3.fromRGB(255, 0, 0)
                part.Parent = workspace
                rangeParts[i] = part
            end
            rangeConn = RunService.RenderStepped:Connect(function()
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                local pos = hrp.Position - Vector3.new(0, 0.9, 0)
                for i, part in ipairs(rangeParts) do
                    if part then
                        local angle = (i / segments) * 2 * math.pi
                        part.Position = pos + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
                    end
                end
            end)
        end
    end
})

local LockGroup = Tabs.Main:AddRightGroupbox("锁人功能")

local lockDropdown = LockGroup:AddDropdown('LockTarget', {
    Text = '选择目标玩家',
    Values = { "无" },
    Default = "无",
    Callback = function(name)
        if name == "无" then
            lockTargetPlayer = nil
        else
            lockTargetPlayer = Players:FindFirstChild(name)
        end
        if lockEnabled then
            startLock()
        end
    end
})

LockGroup:AddToggle('LockMaster', {
    Text = '锁人总开关',
    Default = false,
    Callback = function(state)
        lockEnabled = state
        if state then
            startLock()
        else
            stopLock()
        end
    end
})

LockGroup:AddToggle('LockBack', {
    Text = '锁背',
    Default = false,
    Callback = function(state)
        lockBackEnabled = state
    end
})

LockGroup:AddToggle('Circle', {
    Text = '转圈',
    Default = false,
    Callback = function(state)
        lockCircleEnabled = state
    end
})

LockGroup:AddToggle('LookAt', {
    Text = '看着玩家',
    Default = false,
    Callback = function(state)
        lockLookAtEnabled = state
    end
})

LockGroup:AddToggle('Underground', {
    Text = '在地下打',
    Default = false,
    Callback = function(state)
        lockUndergroundEnabled = state
    end
})

LockGroup:AddButton({
    Text = '刷新玩家列表',
    Func = function()
        local names = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                table.insert(names, p.Name)
            end
        end
        if #names == 0 then
            names = { "无" }
        end
        pcall(function()
            lockDropdown:SetValues(names)
        end)
    end
})

Players.PlayerAdded:Connect(function()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            table.insert(names, p.Name)
        end
    end
    if #names == 0 then
        names = { "无" }
    end
    pcall(function()
        lockDropdown:SetValues(names)
    end)
end)

Players.PlayerRemoving:Connect(function()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            table.insert(names, p.Name)
        end
    end
    if #names == 0 then
        names = { "无" }
    end
    pcall(function()
        lockDropdown:SetValues(names)
    end)
end)

local ExtraLeft = Tabs.Main:AddLeftGroupbox("传送")
local TPYW = nil
ExtraLeft:AddDropdown('TeleportLocation', {
    Text = '传送位置',
    Values = { "地图", "山脉", "安全港", "秘密房间1", "秘密房间2" },
    Default = "地图",
    Callback = function(option)
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if option == "地图" then
            hrp.CFrame = CFrame.new(63.4928513, 440.505829, -92.9229507)
        elseif option == "山脉" then
            hrp.CFrame = CFrame.new(253.515198, 699.103455, 420.533813)
        elseif option == "安全港" then
            hrp.CFrame = CFrame.new(-774.454834, -137.237228, 126.384216)
        elseif option == "秘密房间1" then
            hrp.CFrame = CFrame.new(-62, 29, 20338)
        elseif option == "秘密房间2" then
            hrp.CFrame = CFrame.new(1068, 133, 23015)
        end
    end
})
ExtraLeft:AddButton({
    Text = '设置原位',
    Func = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            TPYW = hrp.CFrame
        end
    end
})
ExtraLeft:AddButton({
    Text = '传送原位',
    Func = function()
        if TPYW then
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = TPYW
            end
        end
    end
})

local ExtraRight = Tabs.Main:AddRightGroupbox("战斗辅助")
ExtraRight:AddToggle('AutoAttack', {
    Text = '自动攻击',
    Default = false,
    Callback = function(state)
        if state then
            task.spawn(function()
                while state do
                    task.wait(0.3)
                    local char = player.Character
                    if char then
                        local communicate = char:FindFirstChild("Communicate")
                        if communicate then
                            communicate:FireServer({ ["Goal"] = "LeftClick" })
                            task.wait(0.05)
                            communicate:FireServer({ ["Goal"] = "LeftClickRelease" })
                        end
                    end
                end
            end)
        end
    end
})
ExtraRight:AddToggle('AutoUltimate', {
    Text = '自动开大',
    Default = false,
    Callback = function(state)
        if state then
            task.spawn(function()
                while state do
                    task.wait(1)
                    pcall(function()
                        if (player:GetAttribute("Ultimate") or 0) >= 100 then
                            player.Character.Communicate:FireServer({
                                MoveDirection = Vector3.new(0, 0, 0),
                                Key = Enum.KeyCode.G,
                                Goal = "KeyPress"
                            })
                        end
                    end)
                end
            end)
        end
    end
})
ExtraRight:AddToggle('GrabToVoid', {
    Text = '抓人传虚空',
    Default = false,
    Callback = function(state)
        if state then
            player.Backpack.ChildAdded:Connect(function(tool)
                if tool:IsA("Tool") and tool.Name == "Lethal Whirlwind Stream" then
                    tool.Equipped:Connect(function()
                        local hrp = player.Character.HumanoidRootPart
                        local originalCF = hrp.CFrame
                        task.wait(1)
                        hrp.CFrame = CFrame.new(-62, 29, 20338)
                        task.wait(3)
                        hrp.CFrame = originalCF
                    end)
                end
            end)
        end
    end
})
ExtraRight:AddToggle('CancelDashEndlag', {
    Text = '取消冲刺后摇',
    Default = false,
    Callback = function(state)
        if state then
            local frontDashArgs = { [1] = { Dash = Enum.KeyCode.W, Key = Enum.KeyCode.Q, Goal = "KeyPress" } }
            local function frontDash()
                if player.Character then
                    local communicate = player.Character:FindFirstChild("Communicate")
                    if communicate then
                        communicate:FireServer(unpack(frontDashArgs))
                    end
                end
            end
            UIS.InputBegan:Connect(function(input, t)
                if t then return end
                if state and input.KeyCode == Enum.KeyCode.Q and not UIS:IsKeyDown(Enum.KeyCode.D) and not UIS:IsKeyDown(Enum.KeyCode.A) and not UIS:IsKeyDown(Enum.KeyCode.S) and player.Character and player.Character:FindFirstChild("UsedDash") then
                    frontDash()
                end
            end)
        end
    end
})
ExtraRight:AddToggle('AutoParry', {
    Text = '自动防御',
    Default = false,
    Callback = function(state)
        if state then
            task.spawn(function()
                while state do
                    task.wait(0.5)
                    pcall(function()
                        local char = player.Character
                        if char then
                            local communicate = char:FindFirstChild("Communicate")
                            if communicate then
                                communicate:FireServer({ ["Goal"] = "KeyPress", ["Key"] = Enum.KeyCode.F })
                                task.wait(0.1)
                                communicate:FireServer({ ["Goal"] = "KeyRelease", ["Key"] = Enum.KeyCode.F })
                            end
                        end
                    end)
                end
            end)
        end
    end
})
ExtraRight:AddToggle('RemoveFreeze', {
    Text = '移除定身',
    Default = false,
    Callback = function(state)
        if state then
            task.spawn(function()
                while state do
                    task.wait(0.1)
                    pcall(function()
                        local char = player.Character
                        if char then
                            local freeze = char:FindFirstChild("Freeze")
                            if freeze then
                                freeze:Destroy()
                            end
                            local comboStun = char:FindFirstChild("ComboStun")
                            if comboStun then
                                comboStun:Destroy()
                            end
                        end
                    end)
                end
            end)
        end
    end
})
local ExtraStats = Tabs.Main:AddLeftGroupbox("属性伪造")
ExtraStats:AddInput('FakeKills', {
    Text = '击杀数',
    Default = "",
    Callback = function(input)
        pcall(function()
            player.leaderstats.Kills.Value = tonumber(input) or 0
        end)
    end
})
ExtraStats:AddInput('FakeTotalKills', {
    Text = '总击杀数',
    Default = "",
    Callback = function(input)
        pcall(function()
            player.leaderstats["Total Kills"].Value = tonumber(input) or 0
        end)
    end
})

ExtraRight:AddToggle('AutoTrashMaster', {
    Text = '自动垃圾桶',
    Default = false,
    Callback = function(state)
        if state then
            task.spawn(function()
                local Workspace = game:GetService("Workspace")
                local TRASH_RANGE = 15
                local PLAYER_RANGE = 100
                local PICKUP_DISTANCE = 2
                local ATTACK_DISTANCE = 2
                local HEIGHT_OFFSET = 3
                local character, rootPart, humanoid
                local function update()
                    character = player.Character
                    if character then
                        rootPart = character:FindFirstChild("HumanoidRootPart")
                        humanoid = character:FindFirstChildOfClass("Humanoid")
                    else
                        rootPart = nil
                        humanoid = nil
                    end
                end
                update()
                player.CharacterAdded:Connect(update)
                while state and RunService.Heartbeat:Wait() do
                    pcall(function()
                        update()
                        if not character or not rootPart or not humanoid or humanoid.Health <= 0 then
                            task.wait(1)
                            return
                        end
                        if not character:GetAttribute("HasTrashcan") then
                            local trashFolder = Workspace:FindFirstChild("Trash") or (Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Trash"))
                            if not trashFolder then
                                task.wait(1)
                                return
                            end
                            local nearestTrash, nearestDist, trashPos
                            for _, trash in ipairs(trashFolder:GetChildren()) do
                                if trash:IsA("Model") then
                                    local part = trash:FindFirstChild("Handle") or trash:FindFirstChild("MainPart") or trash.PrimaryPart
                                    if part then
                                        local dist = (rootPart.Position - part.Position).Magnitude
                                        if dist <= TRASH_RANGE and (not nearestDist or dist < nearestDist) then
                                            nearestTrash = trash
                                            nearestDist = dist
                                            trashPos = part.Position
                                        end
                                    end
                                end
                            end
                            if nearestTrash then
                                local dir = (trashPos - rootPart.Position).Unit
                                dir = Vector3.new(dir.X, 0, dir.Z).Unit
                                local targetPos = trashPos + dir * PICKUP_DISTANCE
                                rootPart.CFrame = CFrame.new(targetPos)
                                task.wait(0.2)
                                dir = (trashPos - rootPart.Position).Unit
                                local look = Vector3.new(dir.X, 0, dir.Z).Unit
                                if look.Magnitude > 0.1 then
                                    rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + look)
                                end
                                local comm = character:FindFirstChild("Communicate")
                                if comm then
                                    comm:FireServer({ Goal = "LeftClick" })
                                    task.wait(0.15)
                                    comm:FireServer({ Goal = "LeftClickRelease" })
                                end
                                local t = 0
                                while t < 2 and state do
                                    if character:GetAttribute("HasTrashcan") then break end
                                    task.wait(0.1)
                                    t = t + 0.1
                                end
                            else
                                task.wait(1)
                            end
                        else
                            local nearestPlayer = nil
                            local minDist = PLAYER_RANGE
                            for _, p in ipairs(Players:GetPlayers()) do
                                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") and p.Character.Humanoid.Health > 0 then
                                    local dist = (rootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                                    if dist < minDist then
                                        nearestPlayer = p
                                        minDist = dist
                                    end
                                end
                            end
                            if nearestPlayer then
                                local targetRoot = nearestPlayer.Character.HumanoidRootPart
                                local behind = targetRoot.Position - (targetRoot.CFrame.LookVector * ATTACK_DISTANCE)
                                rootPart.CFrame = CFrame.new(behind)
                                task.wait(0.2)
                                local look = (targetRoot.Position - rootPart.Position).Unit
                                look = Vector3.new(look.X, 0, look.Z).Unit
                                if look.Magnitude > 0.1 then
                                    rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + look)
                                end
                                local comm = character:FindFirstChild("Communicate")
                                if comm then
                                    comm:FireServer({ Goal = "LeftClick" })
                                    task.wait(0.1)
                                    comm:FireServer({ Goal = "LeftClickRelease" })
                                end
                                task.wait(1.5)
                            else
                                task.wait(1)
                            end
                        end
                    end)
                end
            end)
        end
    end
})
ExtraRight:AddToggle('AutoTrashV2', {
    Text = '自动垃圾桶V2',
    Default = false,
    Callback = function(state)
        if state then
            task.spawn(function()
                local Workspace = game:GetService("Workspace")
                local RANGE = 5
                while state do
                    task.wait(0.1)
                    pcall(function()
                        local char = player.Character
                        if not char then return end
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if not root then return end
                        local folder = Workspace:FindFirstChild("Trash") or (Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Trash"))
                        if not folder then return end
                        local nearest, nearestDist
                        for _, trash in ipairs(folder:GetChildren()) do
                            if trash:IsA("Model") then
                                local part = trash:FindFirstChild("Handle") or trash:FindFirstChild("MainPart") or trash.PrimaryPart
                                if part then
                                    local dist = (root.Position - part.Position).Magnitude
                                    if dist <= RANGE and (not nearestDist or dist < nearestDist) then
                                        nearest = trash
                                        nearestDist = dist
                                    end
                                end
                            end
                        end
                        if nearest then
                            local pos = nearest:GetPivot().Position
                            local dir = (pos - root.Position).Unit
                            dir = Vector3.new(dir.X, 0, dir.Z).Unit
                            root.CFrame = CFrame.lookAt(root.Position, root.Position + dir)
                            if not char:GetAttribute("HasTrashcan") then
                                local comm = char:FindFirstChild("Communicate")
                                if comm then
                                    comm:FireServer({ Goal = "LeftClick" })
                                    task.wait(0.05)
                                    comm:FireServer({ Goal = "LeftClickRelease" })
                                end
                            end
                        end
                    end)
                end
            end)
        end
    end
})

local SetGroup = Tabs.Settings:AddLeftGroupbox("菜单")
SetGroup:AddButton({
    Text = '卸载脚本',
    Func = function()
        stopLock()
        clearRange()
        Library:Unload()
    end
})
SetGroup:AddButton({
    Text = '重载界面',
    Func = function()
        Library:Unload()
    end
})
SetGroup:AddLabel('菜单快捷键')
SetGroup:AddKeyPicker('MenuKeybind', {
    Default = 'RightShift',
    NoUI = true,
    Text = 'Menu keybind'
})
Library.ToggleKeybind = Options.MenuKeybind

if ThemeManager then
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("最强战场主题")
    ThemeManager:ApplyToTab(Tabs.Settings)
end
if SaveManager then
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetFolder("最强战场配置")
    SaveManager:BuildConfigSection(Tabs.Settings)
end

