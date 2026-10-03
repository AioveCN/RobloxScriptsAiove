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
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local draggableFolder = Workspace:WaitForChild("DraggableFolder")

local Window = Library:CreateWindow({
    Title = "死亡避难所",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify({
    Title = "死亡避难所",
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

local ESPGroup = Tabs.Main:AddLeftGroupbox("物资透视")
local AimGroup = Tabs.Main:AddLeftGroupbox("子弹追踪")

local UnloadGroup = Tabs.Settings:AddLeftGroupbox("脚本管理")
UnloadGroup:AddButton("卸载脚本", function()
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

local espScreen = Instance.new("ScreenGui")
espScreen.Name = "ItemESP"
espScreen.ResetOnSpawn = false
espScreen.Parent = player:WaitForChild("PlayerGui")

local espContainer = Instance.new("Frame")
espContainer.Size = UDim2.new(1, 0, 1, 0)
espContainer.BackgroundTransparency = 1
espContainer.Parent = espScreen

local labelPool = {}
local allEspItems = {}
local itemLabelMap = {}

local function getLabel()
    if #labelPool > 0 then
        local lbl = table.remove(labelPool)
        lbl.Visible = false
        return lbl
    end
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    lbl.Parent = espContainer
    return lbl
end

local function recycleLabel(lbl)
    if lbl then
        lbl.Visible = false
        table.insert(labelPool, lbl)
    end
end

local function getPrimaryPart(item)
    if not item:IsA("Model") then return nil end
    if item:FindFirstChild("Primary") and item.Primary:IsA("BasePart") then
        return item.Primary
    end
    for _, child in ipairs(item:GetDescendants()) do
        if child:IsA("BasePart") then
            return child
        end
    end
    return nil
end

local function refreshEspList()
    for _, data in ipairs(allEspItems) do
        if data.hl then
            data.hl:Destroy()
        end
    end
    allEspItems = {}
    if not draggableFolder then return end
    for _, item in ipairs(draggableFolder:GetChildren()) do
        if item:IsA("Model") then
            local part = getPrimaryPart(item)
            if part then
                local hl = Instance.new("Highlight")
                hl.Name = "ItemHighlight"
                hl.Adornee = item
                hl.OutlineColor = Color3.fromRGB(255, 255, 0)
                hl.FillColor = Color3.fromRGB(255, 255, 0)
                hl.OutlineTransparency = 1
                hl.FillTransparency = 1
                hl.Parent = item
                table.insert(allEspItems, {item = item, part = part, hl = hl})
            end
        end
    end
end

local function updateEsp()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = player.Character.HumanoidRootPart
    local nameOn = Toggles.NameESP and Toggles.NameESP.Value
    local distOn = Toggles.DistESP and Toggles.DistESP.Value

    for item, ld in pairs(itemLabelMap) do
        recycleLabel(ld.nl)
        recycleLabel(ld.dl)
    end
    itemLabelMap = {}

    for _, data in ipairs(allEspItems) do
        if not data.item or not data.item.Parent or not data.part or not data.part.Parent then
            if data.hl then
                data.hl:Destroy()
            end
            continue
        end

        local outlineOn = Toggles.OutlineESP and Toggles.OutlineESP.Value
        local fillOn = Toggles.FillESP and Toggles.FillESP.Value
        if data.hl then
            data.hl.OutlineTransparency = outlineOn and 0 or 1
            data.hl.FillTransparency = fillOn and 0.7 or 1
        end

        local pos = data.part.Position + Vector3.new(0, 2.5, 0)
        local screenPos, onScreen = camera:WorldToViewportPoint(pos)
        if onScreen and screenPos.Z > 0 then
            local dist = (hrp.Position - data.part.Position).Magnitude
            local ld = {}
            if nameOn then
                local nl = getLabel()
                nl.Text = data.item.Name
                nl.TextColor3 = Color3.fromRGB(255, 255, 0)
                nl.TextSize = 12
                nl.Position = UDim2.new(0, screenPos.X - 100, 0, screenPos.Y - 20)
                nl.Visible = true
                ld.nl = nl
            end
            if distOn then
                local dl = getLabel()
                dl.Text = string.format("%.1fm", dist)
                dl.TextColor3 = Color3.fromRGB(0, 255, 255)
                dl.TextSize = 11
                dl.Position = UDim2.new(0, screenPos.X - 100, 0, screenPos.Y - 8)
                dl.Visible = true
                ld.dl = dl
            end
            if ld.nl or ld.dl then
                itemLabelMap[data.item] = ld
            end
        end
    end
end

local espEnabled = false
local espRunning = false

local function espLoop()
    if espRunning then return end
    espRunning = true
    task.spawn(function()
        while espEnabled do
            updateEsp()
            task.wait(0.2)
        end
        for item, ld in pairs(itemLabelMap) do
            recycleLabel(ld.nl)
            recycleLabel(ld.dl)
        end
        itemLabelMap = {}
        espRunning = false
    end)
end

ESPGroup:AddToggle("ItemESP", {
    Text = "物资透视总开关",
    Default = false,
    Callback = function(Value)
        espEnabled = Value
        if espEnabled then
            refreshEspList()
            espLoop()
        else
            for _, data in ipairs(allEspItems) do
                if data.hl then
                    data.hl:Destroy()
                end
            end
            allEspItems = {}
        end
    end
})

ESPGroup:AddToggle("NameESP", {
    Text = "透视名字",
    Default = true,
    Callback = function() end
})

ESPGroup:AddToggle("DistESP", {
    Text = "透视距离",
    Default = true,
    Callback = function() end
})

ESPGroup:AddToggle("OutlineESP", {
    Text = "透视轮廓",
    Default = false,
    Callback = function() end
})

ESPGroup:AddToggle("FillESP", {
    Text = "透视内填充",
    Default = false,
    Callback = function() end
})

ESPGroup:AddButton("刷新透视", function()
    if espEnabled then
        refreshEspList()
    end
end)

local function pullItems(names, categoryName)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        Library:Notify({Title = "拉取", Description = "角色未加载", Time = 3})
        return
    end
    local hrp = char.HumanoidRootPart
    local items = {}
    if draggableFolder then
        for _, item in ipairs(draggableFolder:GetChildren()) do
            if item:IsA("Model") then
                if not names then
                    table.insert(items, item)
                else
                    for _, n in ipairs(names) do
                        if item.Name == n then
                            table.insert(items, item)
                            break
                        end
                    end
                end
            end
        end
    end
    if #items == 0 then
        Library:Notify({Title = "拉取", Description = categoryName .. " 没有物资", Time = 3})
        return
    end
    Library:Notify({Title = "拉取", Description = categoryName .. " 已找到 " .. #items .. " 个，正在拉取", Time = 3})
    task.spawn(function()
        for i, item in ipairs(items) do
            pcall(function()
                local angle = (i - 1) * (math.pi * 2 / math.max(#items, 1))
                local ring = math.floor((i - 1) / 12)
                local dist = 4 + ring * 4
                local offset = CFrame.new(math.cos(angle) * dist, 0, math.sin(angle) * dist)
                item:PivotTo(hrp.CFrame * offset)
            end)
            if i % 10 == 0 then
                RunService.Heartbeat:Wait()
            end
        end
    end)
end

local PullAllGroup = Tabs.Main:AddRightGroupbox("全部拉取")
PullAllGroup:AddButton("拉取全部物资", function()
    pullItems(nil, "全部物资")
end)

local ValuableGroup = Tabs.Main:AddRightGroupbox("珍贵物品")
ValuableGroup:AddLabel("Gold Bar")
ValuableGroup:AddLabel("Silver Bar")
ValuableGroup:AddLabel("Silver Painting")
ValuableGroup:AddLabel("Silver Vase")
ValuableGroup:AddLabel("Laptop")
ValuableGroup:AddLabel("Wood Painting")
ValuableGroup:AddButton("拉取珍贵物品", function()
    pullItems({"Gold Bar", "Silver Bar", "Silver Painting", "Silver Vase", "Laptop", "Wood Painting"}, "珍贵物品")
end)

local MedicalGroup = Tabs.Main:AddRightGroupbox("医疗物品")
MedicalGroup:AddLabel("Bandage")
MedicalGroup:AddLabel("Defibrillator")
MedicalGroup:AddButton("拉取医疗物品", function()
    pullItems({"Bandage", "Defibrillator"}, "医疗物品")
end)

local WeaponGroup = Tabs.Main:AddRightGroupbox("枪械武器")
WeaponGroup:AddLabel("Glock")
WeaponGroup:AddLabel("Pistol Ammo")
WeaponGroup:AddLabel("Shotgun Ammo")
WeaponGroup:AddLabel("Rifle Ammo")
WeaponGroup:AddLabel("Katana")
WeaponGroup:AddLabel("Spiked Bat")
WeaponGroup:AddLabel("Repair Hammer")
WeaponGroup:AddLabel("Molotov")
WeaponGroup:AddLabel("Dynamite")
WeaponGroup:AddButton("拉取枪械武器", function()
    pullItems({"Glock", "Pistol Ammo", "Shotgun Ammo", "Rifle Ammo", "Katana", "Spiked Bat", "Repair Hammer", "Molotov", "Dynamite"}, "枪械武器")
end)

local BuildGroup = Tabs.Main:AddRightGroupbox("建筑材料")
BuildGroup:AddLabel("Sheet Metal")
BuildGroup:AddLabel("Long Sheet Metal")
BuildGroup:AddLabel("Big Sheet Metal")
BuildGroup:AddLabel("Bricks")
BuildGroup:AddLabel("Brick Wall")
BuildGroup:AddLabel("Wood Wall")
BuildGroup:AddLabel("Big Plank")
BuildGroup:AddLabel("Small Plank")
BuildGroup:AddLabel("Plank")
BuildGroup:AddLabel("Wood Pallet")
BuildGroup:AddLabel("Cardboard Box")
BuildGroup:AddLabel("Wood Barrel")
BuildGroup:AddLabel("Construction Barricade")
BuildGroup:AddLabel("Metal Fence")
BuildGroup:AddLabel("Barbed Wire")
BuildGroup:AddButton("拉取建筑材料", function()
    pullItems({"Sheet Metal", "Long Sheet Metal", "Big Sheet Metal", "Bricks", "Brick Wall", "Wood Wall", "Big Plank", "Small Plank", "Plank", "Wood Pallet", "Cardboard Box", "Wood Barrel", "Construction Barricade", "Metal Fence", "Barbed Wire"}, "建筑材料")
end)

local LightGroup = Tabs.Main:AddRightGroupbox("照明电力")
LightGroup:AddLabel("Lantern")
LightGroup:AddLabel("Torch")
LightGroup:AddLabel("Construction Lamp")
LightGroup:AddLabel("Power Generator")
LightGroup:AddLabel("Power Fuse")
LightGroup:AddLabel("Money Printer")
LightGroup:AddLabel("Auto Turret")
LightGroup:AddButton("拉取照明电力", function()
    pullItems({"Lantern", "Torch", "Construction Lamp", "Power Generator", "Power Fuse", "Money Printer", "Auto Turret"}, "照明电力")
end)

local ToolGroup = Tabs.Main:AddRightGroupbox("工具杂物")
ToolGroup:AddLabel("Green Keycard")
ToolGroup:AddLabel("Blue Keycard")
ToolGroup:AddLabel("Lockpick")
ToolGroup:AddLabel("Rusted Pipe")
ToolGroup:AddLabel("Vacuum Cleaner")
ToolGroup:AddLabel("Deadbuck")
ToolGroup:AddButton("拉取工具杂物", function()
    pullItems({"Green Keycard", "Blue Keycard", "Lockpick", "Rusted Pipe", "Vacuum Cleaner", "Deadbuck"}, "工具杂物")
end)

local bulletAimEnabled = false
local hookedTools = {}

local function getNearestEnemy()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = char.HumanoidRootPart
    local nearest = nil
    local minDist = math.huge
    for _, model in ipairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") then
            local isPlayer = false
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Character == model then
                    isPlayer = true
                    break
                end
            end
            if not isPlayer then
                local part = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head") or model:FindFirstChildWhichIsA("BasePart")
                if part then
                    local d = (part.Position - hrp.Position).Magnitude
                    if d < minDist then
                        minDist = d
                        nearest = part
                    end
                end
            end
        end
    end
    return nearest
end

local function hookTool(tool)
    if hookedTools[tool] then return end
    local events = tool:FindFirstChild("Events")
    if not events then return end
    local fireEvent = events:FindFirstChild("Fire")
    local readyEvent = events:FindFirstChild("Ready")
    if fireEvent and fireEvent:IsA("RemoteEvent") then
        local oldFire = fireEvent.FireServer
        fireEvent.FireServer = function(self, ...)
            if not bulletAimEnabled then
                return oldFire(self, ...)
            end
            local args = {...}
            if args[1] and typeof(args[1]) == "table" and args[1][1] and typeof(args[1][1]) == "table" then
                local target = getNearestEnemy()
                if target then
                    local origin = args[1][1].Origin
                    if not origin and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        origin = player.Character.HumanoidRootPart.Position
                    end
                    if origin then
                        args[1][1].HitInstance = target
                        args[1][1].HitPosition = target.Position
                        args[1][1].Direction = (target.Position - origin).Unit
                    end
                end
            end
            return oldFire(self, unpack(args))
        end
    end
    if readyEvent and readyEvent:IsA("RemoteEvent") then
        local oldReady = readyEvent.FireServer
        readyEvent.FireServer = function(self, ...)
            if bulletAimEnabled then
                return
            end
            return oldReady(self, ...)
        end
    end
    hookedTools[tool] = true
end

local function scanAndHookTools()
    local char = player.Character
    if not char then return end
    for _, tool in ipairs(char:GetDescendants()) do
        if tool:IsA("Tool") or tool:IsA("Model") then
            local events = tool:FindFirstChild("Events")
            if events and events:FindFirstChild("Fire") then
                hookTool(tool)
            end
        end
    end
end

player.CharacterAdded:Connect(function(char)
    hookedTools = {}
    char:WaitForChild("Humanoid")
    task.wait(0.5)
    scanAndHookTools()
    char.DescendantAdded:Connect(function(desc)
        if (desc:IsA("Tool") or desc:IsA("Model")) and desc:FindFirstChild("Events") and desc.Events:FindFirstChild("Fire") then
            task.wait(0.2)
            hookTool(desc)
        end
    end)
end)

if player.Character then
    scanAndHookTools()
    player.Character.DescendantAdded:Connect(function(desc)
        if (desc:IsA("Tool") or desc:IsA("Model")) and desc:FindFirstChild("Events") and desc.Events:FindFirstChild("Fire") then
            task.wait(0.2)
            hookTool(desc)
        end
    end)
end

AimGroup:AddToggle("BulletAim", {
    Text = "子弹追踪",
    Default = false,
    Callback = function(Value)
        bulletAimEnabled = Value
        if Value then
            scanAndHookTools()
            Library:Notify({Title = "子弹追踪", Description = "已开启", Time = 3})
        end
    end
})

if draggableFolder then
    draggableFolder.ChildAdded:Connect(function(child)
        if espEnabled and child:IsA("Model") then
            task.wait(0.3)
            local part = getPrimaryPart(child)
            if part then
                local hl = Instance.new("Highlight")
                hl.Name = "ItemHighlight"
                hl.Adornee = child
                hl.OutlineColor = Color3.fromRGB(255, 255, 0)
                hl.FillColor = Color3.fromRGB(255, 255, 0)
                hl.OutlineTransparency = 1
                hl.FillTransparency = 1
                hl.Parent = child
                table.insert(allEspItems, {item = child, part = part, hl = hl})
            end
        end
    end)
    draggableFolder.ChildRemoved:Connect(function(child)
        for i = #allEspItems, 1, -1 do
            if allEspItems[i].item == child then
                if allEspItems[i].hl then
                    allEspItems[i].hl:Destroy()
                end
                table.remove(allEspItems, i)
                break
            end
        end
        if itemLabelMap[child] then
            recycleLabel(itemLabelMap[child].nl)
            recycleLabel(itemLabelMap[child].dl)
            itemLabelMap[child] = nil
        end
    end)
end
