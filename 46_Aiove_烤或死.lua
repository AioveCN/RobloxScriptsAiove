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

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

local Window = Library:CreateWindow({
    Title = "烤或死",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify({
    Title = "烤或死",
    Description = "创作者：Aiove\nQQ：3999698324\n脚本已加载成功",
    Time = 5,
})

local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Main = Window:AddTab("主要", "info"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel("Aiove将持续更新此脚本")
NoticeGroup:AddLabel("创作者：Aiove")

local translateCache = {}
local translatePending = {}

local function requestTranslate(text)
    if translateCache[text] or translatePending[text] then
        return
    end
    translatePending[text] = true
    task.spawn(function()
        local success, result = pcall(function()
            local url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=zh-CN&dt=t&q=" .. HttpService:UrlEncode(text)
            local response = game:HttpGet(url)
            local decoded = HttpService:JSONDecode(response)
            local merged = ""
            if decoded and decoded[1] then
                for _, seg in ipairs(decoded[1]) do
                    if seg[1] then
                        merged = merged .. seg[1]
                    end
                end
            end
            return merged
        end)
        if success and result and result ~= "" then
            translateCache[text] = result
        end
        translatePending[text] = nil
    end)
end

local lastTranslateTick = 0
RunService.Heartbeat:Connect(function()
    local now = os.clock()
    if now - lastTranslateTick < 0.1 then
        return
    end
    lastTranslateTick = now
    local folder = Workspace:FindFirstChild("Interactables")
    if folder then
        for _, obj in ipairs(folder:GetChildren()) do
            if obj:IsA("Model") then
                requestTranslate(obj.Name)
            end
        end
    end
end)

local function displayName(name)
    return translateCache[name] or name
end

local function getRootPart(model)
    if not model:IsA("Model") then
        return nil
    end
    return model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("Root")
        or model:FindFirstChild("Hitbox")
        or model.PrimaryPart
        or model:FindFirstChildWhichIsA("BasePart", true)
end

local CATEGORIES = {
    {
        name = "医疗类",
        items = {
            { "医疗包", "FirstAidKit" },
            { "绷带", "Bandage" },
            { "复活包", "ReviveKit" },
        },
    },
    {
        name = "食物类",
        items = {
            { "肉", "Meat" },
            { "仙人掌肉", "CactusMeat" },
            { "爆炸肉", "ExplosiveMeat" },
            { "老鼠肉", "RatMeat" },
            { "辐射老鼠肉", "RadioactiveRatMeat" },
        },
    },
    {
        name = "废品类",
        items = {
            { "压扁的罐子", "CrushedCan" },
            { "旧罐子", "OldCan" },
            { "金属齿轮", "MetalGear" },
            { "齿轮", "Gear" },
            { "钉子", "Nail" },
            { "螺母", "Nut" },
            { "破灯笼", "BrokenLantern" },
            { "破试管", "BrokenTestTube" },
            { "金属桶", "MetalBarrel" },
            { "轮子", "Wheel" },
            { "手推车", "WheelBarrow" },
        },
    },
    {
        name = "枪械类",
        items = {
            { "手枪", "Pistol" },
            { "左轮", "Revolver" },
            { "冲锋枪", "SMG" },
            { "泵动霰弹枪", "PumpShotgun" },
            { "步枪", "M4A1" },
            { "外骨骼步枪", "ExoRifle" },
            { "机枪", "Minigun" },
            { "屠夫刀", "ButcherKnife" },
            { "角斗士剑", "GladiatorSword" },
            { "爆炸发射器", "ExplosiveLauncher" },
        },
    },
    {
        name = "家具类",
        items = {
            { "木凳", "WoodStool" },
            { "台灯", "Lamp" },
            { "木椅", "WoodChair" },
            { "摇椅", "RockingChair" },
            { "老式电视", "VintageTV" },
            { "挂画", "Painting" },
            { "烤面包机", "Toaster" },
            { "茶壶", "Teapot" },
            { "裂开的钟", "CrackedBell" },
            { "头骨", "Skull" },
        },
    },
}

local function collectByPatterns(patterns)
    local list = {}
    local folder = Workspace:FindFirstChild("Interactables")
    if folder then
        for _, obj in ipairs(folder:GetChildren()) do
            if obj:IsA("Model") then
                for _, pat in ipairs(patterns) do
                    if string.find(obj.Name, pat) then
                        if getRootPart(obj) then
                            table.insert(list, obj)
                        end
                        break
                    end
                end
            end
        end
    end
    return list
end

local function collectAllItems()
    local list = {}
    local folder = Workspace:FindFirstChild("Interactables")
    if folder then
        for _, obj in ipairs(folder:GetChildren()) do
            if obj:IsA("Model") and getRootPart(obj) then
                table.insert(list, obj)
            end
        end
    end
    return list
end

local function pullModels(targets)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        Library:Notify({ Title = "烤或死", Description = "未找到你的角色", Time = 3 })
        return
    end
    if #targets == 0 then
        Library:Notify({ Title = "烤或死", Description = "没有找到可拉取的物品", Time = 3 })
        return
    end
    local basePos = hrp.Position + hrp.CFrame.LookVector * 4
    for i, model in ipairs(targets) do
        local root = getRootPart(model)
        if root then
            local angle = (i / #targets) * math.pi * 2
            local offset = Vector3.new(math.cos(angle) * 3, 0, math.sin(angle) * 3)
            model:PivotTo(CFrame.new(basePos + offset))
        end
    end
    Library:Notify({ Title = "烤或死", Description = "已拉取 " .. #targets .. " 个物品", Time = 3 })
end

local EspGroup = Tabs.Main:AddLeftGroupbox("透视")

local function makeEspToggle(name, collectFunc)
    local drawings = {}
    local conn = nil
    local function clearAll()
        for _, d in ipairs(drawings) do
            pcall(function()
                d:Remove()
            end)
        end
        drawings = {}
    end
    EspGroup:AddToggle(name, { Text = name, Default = false })
    Toggles[name]:OnChanged(function(v)
        if v then
            conn = RunService.RenderStepped:Connect(function()
                for _, d in ipairs(drawings) do
                    pcall(function()
                        d.Visible = false
                    end)
                end
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then
                    return
                end
                local cam = Workspace.CurrentCamera
                if not cam then
                    return
                end
                local i = 0
                for _, model in ipairs(collectFunc()) do
                    local root = getRootPart(model)
                    if root then
                        local pos, onScreen = cam:WorldToViewportPoint(root.Position)
                        if onScreen then
                            i = i + 1
                            local d = drawings[i]
                            if not d then
                                d = Drawing.new("Text")
                                d.Size = 16
                                d.Center = true
                                d.Outline = true
                                d.Color = Color3.fromRGB(255, 255, 255)
                                drawings[i] = d
                            end
                            local dist = (hrp.Position - root.Position).Magnitude
                            d.Text = displayName(model.Name) .. " [" .. math.floor(dist) .. "m]"
                            d.Position = Vector2.new(pos.X, pos.Y)
                            d.Visible = true
                        end
                    end
                end
            end)
        else
            if conn then
                conn:Disconnect()
                conn = nil
            end
            clearAll()
        end
    end)
end

makeEspToggle("透视物资", collectAllItems)

local PullAllGroup = Tabs.Main:AddRightGroupbox("拉取")
PullAllGroup:AddButton("拉取全部物品", function()
    pullModels(collectAllItems())
end)

local InteractGroup = Tabs.Main:AddRightGroupbox("交互")

local function getScanRoot()
    local runtime = Workspace:FindFirstChild("Runtime")
    if runtime and runtime:FindFirstChild("LootPoints") then
        return runtime:FindFirstChild("LootPoints")
    end
    return Workspace
end

local function fireAllPrompts(filterFunc)
    local char = player.Character
    if not char then
        return 0
    end
    local count = 0
    for _, obj in ipairs(getScanRoot():GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            if not filterFunc or filterFunc(obj) then
                count = count + 1
                pcall(function()
                    if obj.HoldDuration and obj.HoldDuration > 0 then
                        obj.HoldDuration = 0
                    end
                    fireproximityprompt(obj)
                end)
                pcall(function()
                    fireproximityprompt(obj, 1)
                end)
            end
        end
    end
    return count
end

local VirtualInputManager = game:GetService("VirtualInputManager")

InteractGroup:AddToggle("自动交互", { Text = "自动交互", Default = false })
InteractGroup:AddSlider("交互速度", { Text = "交互速度", Default = 0.5, Min = 0.1, Max = 5, Rounding = 1, Suffix = "秒" })

local autoInteractAcc = 0
RunService.Heartbeat:Connect(function(dt)
    if not Toggles["自动交互"].Value then
        return
    end
    autoInteractAcc = autoInteractAcc + dt
    if autoInteractAcc < Options["交互速度"].Value then
        return
    end
    autoInteractAcc = 0
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)
end)

local crateOpening = false
local instantEnabled = false
local holdOriginals = {}
local instantConn = nil

local function applyInstant(obj)
    if obj:IsA("ProximityPrompt") and obj.HoldDuration > 0 then
        if holdOriginals[obj] == nil then
            holdOriginals[obj] = obj.HoldDuration
        end
        pcall(function()
            obj.HoldDuration = 0
        end)
    end
end

local function setInstant(v)
    instantEnabled = v
    if v then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            applyInstant(obj)
        end
        instantConn = Workspace.DescendantAdded:Connect(function(obj)
            if instantEnabled then
                task.defer(applyInstant, obj)
            end
        end)
    else
        if instantConn then
            instantConn:Disconnect()
            instantConn = nil
        end
        for obj, dur in pairs(holdOriginals) do
            pcall(function()
                if obj and obj.Parent then
                    obj.HoldDuration = dur
                end
            end)
        end
        holdOriginals = {}
    end
end

InteractGroup:AddToggle("即时交互", { Text = "即时交互", Default = false })
Toggles["即时交互"]:OnChanged(function(v)
    if not v and crateOpening then
        Library:Notify({ Title = "烤或死", Description = "正在开箱中，关闭失败", Time = 3 })
        Toggles["即时交互"]:SetValue(true)
        return
    end
    setInstant(v)
end)

InteractGroup:AddButton("全图交互一次", function()
    local count = fireAllPrompts()
    Library:Notify({ Title = "烤或死", Description = "已交互 " .. count .. " 处", Time = 3 })
end)

local function openCratesSequentially(filterFunc, label)
    if crateOpening then
        Library:Notify({ Title = "烤或死", Description = "正在执行中，不要多点", Time = 3 })
        return
    end
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        Library:Notify({ Title = "烤或死", Description = "未找到你的角色", Time = 3 })
        return
    end
    local prompts = {}
    for _, obj in ipairs(getScanRoot():GetDescendants()) do
        if obj:IsA("ProximityPrompt") and filterFunc(obj) then
            local model = obj:FindFirstAncestorOfClass("Model")
            local root = model and getRootPart(model)
            if root then
                table.insert(prompts, { prompt = obj, root = root })
            end
        end
    end
    if #prompts == 0 then
        Library:Notify({ Title = "烤或死", Description = "没有找到" .. label, Time = 3 })
        return
    end
    crateOpening = true
    Toggles["即时交互"]:SetValue(true)
    local origin = hrp.CFrame
    local cam = Workspace.CurrentCamera
    local oldCamType = cam and cam.CameraType
    local oldCamCFrame = cam and cam.CFrame
    task.spawn(function()
        local count = 0
        for _, entry in ipairs(prompts) do
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                break
            end
            pcall(function()
                player.Character.HumanoidRootPart.CFrame = entry.root.CFrame + Vector3.new(0, 2, 0)
            end)
            task.wait(0.1)
            pcall(function()
                local cam2 = Workspace.CurrentCamera
                if cam2 then
                    cam2.CameraType = Enum.CameraType.Scriptable
                    local eyePos = entry.root.Position + Vector3.new(0, 6, 0)
                    cam2.CFrame = CFrame.lookAt(eyePos, entry.root.Position)
                end
            end)
            task.wait(0.1)
            pcall(function()
                if entry.prompt.HoldDuration and entry.prompt.HoldDuration > 0 then
                    entry.prompt.HoldDuration = 0
                end
                fireproximityprompt(entry.prompt)
            end)
            pcall(function()
                fireproximityprompt(entry.prompt, 1)
            end)
            count = count + 1
            task.wait(1)
        end
        pcall(function()
            local cam3 = Workspace.CurrentCamera
            if cam3 and oldCamType then
                cam3.CameraType = oldCamType
                if oldCamCFrame then
                    cam3.CFrame = oldCamCFrame
                end
            end
        end)
        pcall(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = origin
            end
        end)
        crateOpening = false
        Toggles["即时交互"]:SetValue(false)
        Library:Notify({ Title = "烤或死", Description = "已交互 " .. count .. " 个" .. label .. "，已回到原点", Time = 3 })
    end)
end

local function isCratePrompt(prompt)
    local model = prompt:FindFirstAncestorOfClass("Model")
    return model ~= nil and string.find(model.Name, "Crate") ~= nil
end

InteractGroup:AddButton("打开所有物资箱", function()
    openCratesSequentially(isCratePrompt, "物资箱")
end)

InteractGroup:AddButton("传送到最近的武器箱子", function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        Library:Notify({ Title = "烤或死", Description = "未找到你的角色", Time = 3 })
        return
    end
    local nearest = nil
    local nearestDist = math.huge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and string.find(obj.Name, "WeaponCrate") then
            local root = getRootPart(obj)
            if root then
                local dist = (root.Position - hrp.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = root
                end
            end
        end
    end
    if not nearest then
        Library:Notify({ Title = "烤或死", Description = "没有找到武器箱子", Time = 3 })
        return
    end
    hrp.CFrame = nearest.CFrame + Vector3.new(0, 3, 0)
    Library:Notify({ Title = "烤或死", Description = "已传送到最近的武器箱子", Time = 3 })
end)

for idx, category in ipairs(CATEGORIES) do
    local group = Tabs.Main:AddLeftGroupbox(category.name)
    local displayList = {}
    local nameMap = {}
    for _, pair in ipairs(category.items) do
        table.insert(displayList, pair[1])
        nameMap[pair[1]] = pair[2]
    end
    if category.name == "枪械类" then
        group:AddLabel("必须先打开全图武器箱")
        group:AddButton("打开全图武器箱", function()
            openCratesSequentially(function(prompt)
                local model = prompt:FindFirstAncestorOfClass("Model")
                return model ~= nil and string.find(model.Name, "WeaponCrate") ~= nil
            end, "武器箱")
        end)
    end
    group:AddDropdown("Category" .. idx, {
        Values = displayList,
        Default = 1,
        Multi = true,
        Text = "选择要拉取的物资",
    })
    group:AddButton("拉取选中物资", function()
        local selected = Options["Category" .. idx].Value
        local patterns = {}
        for display, picked in pairs(selected) do
            if picked and nameMap[display] then
                table.insert(patterns, nameMap[display])
            end
        end
        if #patterns == 0 then
            Library:Notify({ Title = "烤或死", Description = "请先在框里选定物资", Time = 3 })
            return
        end
        pullModels(collectByPatterns(patterns))
    end)
end

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
