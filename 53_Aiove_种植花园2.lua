-- This file has been deobfuscated Luraph using Hurricane https://discord.com/invite/AbeurBzKXe
local function safeLoad(url) local success, result = pcall(function() return loadstring(game:HttpGet(url))() end) if not success then warn("加载失败: " .. url) return nil end return result end local Library = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/黑曜石主库.ui") local ThemeManager = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/主题管理.ui") local SaveManager = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/配置管理.ui") if not Library then game:GetService("StarterGui"):SetCore("SendNotification", { Title = "错误", Text = "UI 库加载失败，请检查网络或脚本资源", Duration = 5, }) return end
local Options = Library.Options local Toggles = Library.Toggles local Players = game:GetService("Players") local ReplicatedStorage = game:GetService("ReplicatedStorage") local player = Players.LocalPlayer local Window = Library:CreateWindow({ Title = "种植花园2", Footer = "Aiove 制作", Icon = 131153193945220, NotifySide = "Right", ShowCustomCursor = true, }) Library:Notify({ Title = "种植花园2", Description = "创作者：Aiove\nQQ：3999698324\n脚本已加载成功", Time = 5, }) local Tabs = { Notice = Window:AddTab("通知", "info"), Main = Window:AddTab("主要", "info"), Settings = Window:AddTab("设置", "settings"), }

local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local espEnabled = false
local espData = {}
local weightSources = {}
local scanFruits
local clearAll
local getWeight

local goldColor = Color3.fromRGB(255, 200, 40)

local translatedTexts = {}

local function translateText(text)
    if not text or text == "" or #text < 2 then
        return nil
    end
    local cached = translatedTexts[text]
    if cached ~= nil then
        if cached == false then return nil end
        return cached
    end
    local success, result = pcall(function()
        local url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=zh-CN&dt=t&q=" .. HttpService:UrlEncode(text)
        local response = game:HttpGet(url)
        local decoded = HttpService:JSONDecode(response)
        if decoded and decoded[1] and decoded[1][1] and decoded[1][1][1] then
            return decoded[1][1][1]
        end
        return nil
    end)
    if success and result then
        translatedTexts[text] = result
        return result
    end
    return nil
end

local function isEnglish(text)
    if not text or text == "" then
        return false
    end
    local englishCount = 0
    local totalCount = 0
    for char in text:gmatch(".") do
        local byte = string.byte(char)
        if byte then
            totalCount = totalCount + 1
            if (byte >= 65 and byte <= 90) or (byte >= 97 and byte <= 122) then
                englishCount = englishCount + 1
            end
        end
    end
    if totalCount == 0 then
        return false
    end
    return (englishCount / totalCount) > 0.5
end

local function toggleValue(key, default)
    local ok, v = pcall(function() return Toggles[key].Value end)
    if ok and v ~= nil then return v end
    return default
end

local function nameOn() return toggleValue("PlantESP_Name", true) end
local function weightOn() return toggleValue("PlantESP_Weight", true) end
local function distOn() return toggleValue("PlantESP_Dist", false) end
local function fillOn() return toggleValue("PlantESP_Fill", false) end

local function getMinKG()
    local ok, v = pcall(function() return Options.PlantESP_MinKG.Value end)
    if ok and type(v) == "number" then return v end
    return 0
end

local function passFilter(fruit)
    local w = getWeight(fruit)
    if w == nil then return true end
    return w >= getMinKG()
end

local function composeLabel(data)
    local parts = {}
    if nameOn() and data.name then
        table.insert(parts, data.name)
    end
    if weightOn() and data.weight then
        table.insert(parts, string.format("%.2fkg", data.weight))
    end
    if distOn() and data.dist then
        table.insert(parts, string.format("%.0f米", data.dist))
    end
    return table.concat(parts, "\n")
end

local function refreshLabel(data)
    if not data.label or not data.label.Parent then return end
    local text = composeLabel(data)
    if text ~= data.lastText then
        data.lastText = text
        data.label.Text = text
    end
    if data.billboard and data.billboard.Parent then
        data.billboard.Enabled = (text ~= "")
    end
end

local function refreshESP()
    if espEnabled then
        clearAll()
        scanFruits()
    end
end

local filterPending = false
local function scheduleFilterRefresh()
    if filterPending then return end
    filterPending = true
    task.delay(0.4, function()
        filterPending = false
        refreshESP()
    end)
end

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息") NoticeGroup:AddLabel('Aiove将持续更新此脚本') NoticeGroup:AddLabel('创作者：Aiove') local UnloadGroup = Tabs.Settings:AddLeftGroupbox("脚本管理") UnloadGroup:AddButton("卸载脚本", function() Library:Unload() end)

local PlantGroup = Tabs.Main:AddLeftGroupbox("植物透视")
PlantGroup:AddToggle("PlantESP", {
    Text = "植物透视",
    Default = false,
    Tooltip = "轮廓透视总开关",
})
PlantGroup:AddToggle("PlantESP_Name", {
    Text = "透视名字",
    Default = true,
})
PlantGroup:AddToggle("PlantESP_Weight", {
    Text = "透视重量",
    Default = true,
})
PlantGroup:AddToggle("PlantESP_Dist", {
    Text = "透视与自己的距离",
    Default = false,
})
PlantGroup:AddToggle("PlantESP_Fill", {
    Text = "透视内填充物",
    Default = false,
})
PlantGroup:AddSlider("PlantESP_MinKG", {
    Text = "最低千克",
    Default = 0,
    Min = 0,
    Max = 1000,
    Rounding = 1,
    Suffix = "kg",
})
PlantGroup:AddInput("PlantESP_MinKG_Input", {
    Text = "精确最低千克",
    Default = "0",
    Placeholder = "输入0到1000的数字",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        pcall(function()
            local num = tonumber(Value)
            if num then
                if num < 0 then num = 0 end
                if num > 1000 then num = 1000 end
                Options.PlantESP_MinKG:SetValue(num)
            end
        end)
    end,
})
if Options.PlantESP_MinKG then
    Options.PlantESP_MinKG:OnChanged(function()
        pcall(function()
            local v = Options.PlantESP_MinKG.Value
            if Options.PlantESP_MinKG_Input and tostring(v) ~= Options.PlantESP_MinKG_Input.Value then
                Options.PlantESP_MinKG_Input:SetValue(tostring(v))
            end
        end)
        scheduleFilterRefresh()
    end)
end
if Toggles.PlantESP then
    Toggles.PlantESP:OnChanged(function()
        pcall(function()
            local Value = Toggles.PlantESP.Value
            espEnabled = Value
            if espEnabled then
                local count = scanFruits()
                Library:Notify({ Title = "植物透视", Description = "已开启，找到 " .. count .. " 个果实", Time = 3, })
            else
                clearAll()
                Library:Notify({ Title = "植物透视", Description = "已关闭", Time = 3, })
            end
        end)
    end)
end
for _, key in ipairs({"PlantESP_Name", "PlantESP_Weight", "PlantESP_Dist"}) do
    if Toggles[key] then
        Toggles[key]:OnChanged(function()
            pcall(function()
                for fruit, data in pairs(espData) do
                    refreshLabel(data)
                end
            end)
        end)
    end
end
if Toggles.PlantESP_Fill then
    Toggles.PlantESP_Fill:OnChanged(function()
        pcall(function()
            local transparency = 1
            if fillOn() then transparency = 0.65 end
            for fruit, data in pairs(espData) do
                if data.highlight and data.highlight.Parent then
                    data.highlight.FillTransparency = transparency
                end
            end
        end)
    end)
end

local followEnabled = false

local function getPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    if #names == 0 then
        table.insert(names, "没有其他玩家")
    end
    return names
end

local FollowGroup = Tabs.Main:AddRightGroupbox("贴背跟随")
FollowGroup:AddDropdown("FollowTarget", {
    Text = "选定玩家",
    Values = getPlayerNames(),
    Default = 1,
    Multi = false,
})
FollowGroup:AddButton("刷新玩家列表", function()
    pcall(function()
        Options.FollowTarget:SetValues(getPlayerNames())
        Library:Notify({ Title = "贴背跟随", Description = "玩家列表已刷新", Time = 2, })
    end)
end)
FollowGroup:AddToggle("FollowBack", {
    Text = "开启跟随",
    Default = false,
    Tooltip = "平滑跟随在选定玩家身后一米",
})
if Toggles.FollowBack then
    Toggles.FollowBack:OnChanged(function()
        pcall(function()
            followEnabled = Toggles.FollowBack.Value
            if followEnabled then
                local targetName = Options.FollowTarget.Value
                Library:Notify({ Title = "贴背跟随", Description = "已开启，目标：" .. tostring(targetName), Time = 3, })
            else
                Library:Notify({ Title = "贴背跟随", Description = "已关闭", Time = 3, })
            end
        end)
    end)
end

local antiTheftEnabled = false
local antiTheftTarget = nil
local VirtualInputManager = game:GetService("VirtualInputManager")

local function getAntiTheftRadius()
    local ok, v = pcall(function() return Options.AntiTheft_Radius.Value end)
    if ok and type(v) == "number" then return v end
    return 30
end

local AntiTheftGroup = Tabs.Main:AddRightGroupbox("防偷反击")
AntiTheftGroup:AddToggle("AntiTheft", {
    Text = "防偷反击",
    Default = false,
    Tooltip = "有人靠近时自动贴到他背后按E攻击",
})
AntiTheftGroup:AddSlider("AntiTheft_Radius", {
    Text = "检测半径",
    Default = 30,
    Min = 5,
    Max = 100,
    Rounding = 0,
    Suffix = "米",
})
if Toggles.AntiTheft then
    Toggles.AntiTheft:OnChanged(function()
        pcall(function()
            antiTheftEnabled = Toggles.AntiTheft.Value
            if not antiTheftEnabled then
                antiTheftTarget = nil
            end
            Library:Notify({ Title = "防偷反击", Description = antiTheftEnabled and "已开启" or "已关闭", Time = 3, })
        end)
    end)
end

local function pressE()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)
end

task.spawn(function()
    while true do
        if antiTheftEnabled then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    local radius = getAntiTheftRadius()
                    local nearest, nearestDist = nil, radius
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer then
                            local c = p.Character
                            local r = c and c:FindFirstChild("HumanoidRootPart")
                            local h = c and c:FindFirstChildOfClass("Humanoid")
                            if r and h and h.Health > 0 then
                                local d = (root.Position - r.Position).Magnitude
                                if d <= nearestDist then
                                    nearest = p
                                    nearestDist = d
                                end
                            end
                        end
                    end
                    if nearest ~= antiTheftTarget then
                        antiTheftTarget = nearest
                        if nearest then
                            Library:Notify({ Title = "防偷反击", Description = "检测到 " .. nearest.Name .. " 靠近，已贴到背后", Time = 3, })
                        end
                    end
                end
            end)
        else
            antiTheftTarget = nil
        end
        task.wait(0.25)
    end
end)

RunService.Heartbeat:Connect(function(dt)
    if not antiTheftEnabled then return end
    if not antiTheftTarget then return end
    pcall(function()
        local tchar = antiTheftTarget.Character
        local troot = tchar and tchar:FindFirstChild("HumanoidRootPart")
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if troot and root then
            local backCF = troot.CFrame * CFrame.new(0, 0, 1)
            local goal = CFrame.lookAt(backCF.Position, backCF.Position + troot.CFrame.LookVector)
            local alpha = math.clamp(dt * 12, 0, 1)
            root.CFrame = root.CFrame:Lerp(goal, alpha)
        end
    end)
end)

task.spawn(function()
    while true do
        if antiTheftEnabled and antiTheftTarget then
            pressE()
            task.wait(0.25)
        else
            task.wait(0.3)
        end
    end
end)

if ThemeManager then ThemeManager:SetLibrary(Library) ThemeManager:SetFolder("MyScriptTheme") ThemeManager:ApplyToTab(Tabs.Settings) end if SaveManager then SaveManager:SetLibrary(Library) SaveManager:IgnoreThemeSettings() SaveManager:SetFolder("MyScriptConfig") SaveManager:BuildConfigSection(Tabs.Settings) end

getWeight = function(fruit)
    local ok, result = pcall(function()
        local src = weightSources[fruit]
        if src then
            if src.kind == "nv" then
                if src.ref and src.ref.Parent then
                    return src.ref.Value
                end
            elseif src.kind == "attr" then
                local v = fruit:GetAttribute(src.key)
                if type(v) == "number" then
                    return v
                end
            end
            weightSources[fruit] = nil
        end
        local w = fruit:FindFirstChild("Weight")
        if w and w:IsA("NumberValue") then
            weightSources[fruit] = {kind = "nv", ref = w}
            return w.Value
        end
        local attrs = fruit:GetAttributes()
        if attrs then
            for key, value in pairs(attrs) do
                if type(value) == "number" and string.find(string.lower(key), "weight") then
                    weightSources[fruit] = {kind = "attr", key = key}
                    return value
                end
            end
            for key, value in pairs(attrs) do
                if type(value) == "number" and (string.find(string.lower(key), "kg") or string.find(string.lower(key), "mass")) then
                    weightSources[fruit] = {kind = "attr", key = key}
                    return value
                end
            end
            for key, value in pairs(attrs) do
                if type(value) == "number" and value > 0 and value < 100000 and value ~= math.floor(value) then
                    weightSources[fruit] = {kind = "attr", key = key}
                    return value
                end
            end
        end
        return nil
    end)
    if ok then return result end
    return nil
end

local function isFruit(inst)
    local ok, result = pcall(function()
        if not inst:IsA("Model") then return false end
        local parent = inst.Parent
        if not parent or parent.Name ~= "Fruits" then return false end
        local h = inst:FindFirstChild("HarvestPart")
        return h ~= nil and h:IsA("BasePart")
    end)
    if ok then return result end
    return false
end

local function isBadName(text)
    if type(text) ~= "string" then return true end
    if text == "" then return true end
    local lower = string.lower(text)
    if lower == "label" or lower == "textlabel" or lower == "text" or text == "标签" or lower == "name" or lower == "unknown" then return true end
    return false
end

local function getPlantName(fruit)
    local ok, result = pcall(function()
        local fruitName = fruit:GetAttribute("Name") or fruit:GetAttribute("FruitName") or fruit:GetAttribute("PlantName") or fruit:GetAttribute("SeedName")
        if type(fruitName) == "string" and not isBadName(fruitName) then
            return fruitName
        end
        local hp = fruit:FindFirstChild("HarvestPart")
        if hp then
            local pp = hp:FindFirstChild("HarvestPrompt")
            if pp and pp:IsA("ProximityPrompt") and not isBadName(pp.ObjectText) then
                return pp.ObjectText
            end
            local lbl = hp:FindFirstChild("HarvestPromptLabel")
            if lbl then
                local nameLabel = lbl:FindFirstChild("Name", true)
                if nameLabel and nameLabel:IsA("TextLabel") and not isBadName(nameLabel.Text) then
                    return nameLabel.Text
                end
            end
        end
        local fruitsFolder = fruit.Parent
        local plant = fruitsFolder and fruitsFolder.Parent
        if plant then
            local dg = plant:FindFirstChild("DebugGui")
            if dg then
                local tl = dg:FindFirstChildWhichIsA("TextLabel", true)
                if tl and not isBadName(tl.Text) then
                    return tl.Text
                end
            end
            local plantName = plant:GetAttribute("Name") or plant:GetAttribute("PlantName") or plant:GetAttribute("Seed_Name") or plant:GetAttribute("Plant") or plant:GetAttribute("SeedName")
            if type(plantName) == "string" and not isBadName(plantName) then
                return plantName
            end
        end
        return nil
    end)
    if ok and result then return result end
    return "未知植物"
end

local function removeESP(fruit)
    local data = espData[fruit]
    if data then
        pcall(function()
            if data.highlight and data.highlight.Parent then data.highlight:Destroy() end
            if data.billboard and data.billboard.Parent then data.billboard:Destroy() end
        end)
        espData[fruit] = nil
    end
end

local function addESP(fruit)
    if espData[fruit] then return end
    pcall(function()
        local hp = fruit:FindFirstChild("HarvestPart")
        if not hp then return end
        local name = getPlantName(fruit)
        local weight = getWeight(fruit)

        local hl = Instance.new("Highlight")
        hl.FillColor = goldColor
        hl.OutlineColor = goldColor
        if fillOn() then
            hl.FillTransparency = 0.65
        else
            hl.FillTransparency = 1
        end
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee = fruit
        hl.Parent = fruit

        local bb = Instance.new("BillboardGui")
        bb.Name = "PlantESP"
        bb.Size = UDim2.new(0, 160, 0, 60)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        bb.Parent = hp

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = goldColor
        label.Font = Enum.Font.GothamBold
        label.TextSize = 15
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.Parent = bb

        espData[fruit] = {highlight = hl, billboard = bb, label = label, name = name, weight = weight, dist = nil, lastText = ""}
        refreshLabel(espData[fruit])
    end)
end

clearAll = function()
    for fruit, _ in pairs(espData) do
        removeESP(fruit)
    end
    for fruit, _ in pairs(weightSources) do
        weightSources[fruit] = nil
    end
end

scanFruits = function()
    local count = 0
    pcall(function()
        local gardens = Workspace:FindFirstChild("Gardens")
        if gardens then
            for _, plot in ipairs(gardens:GetChildren()) do
                pcall(function()
                    local plants = plot:FindFirstChild("Plants")
                    if plants then
                        for _, plant in ipairs(plants:GetChildren()) do
                            pcall(function()
                                local fruitsFolder = plant:FindFirstChild("Fruits")
                                if fruitsFolder then
                                    for _, fruit in ipairs(fruitsFolder:GetChildren()) do
                                        if isFruit(fruit) then
                                            count = count + 1
                                            if passFilter(fruit) then
                                                addESP(fruit)
                                            end
                                        end
                                    end
                                end
                            end)
                        end
                    end
                end)
            end
        end
    end)
    return count
end

local translateCooldown = {}
local translating = {}

task.spawn(function()
    while true do
        if espEnabled and nameOn() then
            for fruit, data in pairs(espData) do
                local name = data.name
                if name and isEnglish(name) and translatedTexts[name] == nil and not translating[name] then
                    local failTime = translateCooldown[name]
                    if not failTime or (tick() - failTime) >= 10 then
                        translating[name] = true
                        task.spawn(function()
                            pcall(function()
                                local translated = translateText(name)
                                if translated and translated ~= name then
                                    for f, d in pairs(espData) do
                                        if d.name == name then
                                            d.name = translated
                                            refreshLabel(d)
                                        end
                                    end
                                else
                                    translateCooldown[name] = tick()
                                end
                            end)
                            translating[name] = nil
                        end)
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do
        if espEnabled and distOn() then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    for fruit, data in pairs(espData) do
                        pcall(function()
                            local hp = fruit:FindFirstChild("HarvestPart")
                            if hp then
                                data.dist = (root.Position - hp.Position).Magnitude
                                refreshLabel(data)
                            end
                        end)
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

RunService.Heartbeat:Connect(function(dt)
    if not followEnabled then return end
    pcall(function()
        local targetName = Options.FollowTarget.Value
        if not targetName then return end
        local target = Players:FindFirstChild(targetName)
        local tchar = target and target.Character
        local troot = tchar and tchar:FindFirstChild("HumanoidRootPart")
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if troot and root then
            local backCF = troot.CFrame * CFrame.new(0, 0, 1)
            local goal = CFrame.lookAt(backCF.Position, backCF.Position + troot.CFrame.LookVector)
            local alpha = math.clamp(dt * 12, 0, 1)
            root.CFrame = root.CFrame:Lerp(goal, alpha)
        end
    end)
end)
