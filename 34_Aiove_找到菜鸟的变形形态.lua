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
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local Window = Library:CreateWindow({
    Title = "找到菜鸟的变形形态",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify({
    Title = "找到菜鸟的变形形态",
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

local function getNoobies()
    local list = {}
    local folder = Workspace:FindFirstChild("AllNoobies")
    if folder then
        for _, v in ipairs(folder:GetChildren()) do
            if v:IsA("Model") and v.Name:find("Noobie") and not v.Name:find("Coin") and v:FindFirstChildOfClass("Humanoid") then
                table.insert(list, v)
            end
        end
    end
    if #list == 0 then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name:find("Noobie") and not v.Name:find("Coin") and v:FindFirstChildOfClass("Humanoid") then
                table.insert(list, v)
            end
        end
    end
    return list
end

local function getCoins()
    local list = {}
    local folder = Workspace:FindFirstChild("Coins")
    if folder then
        for _, v in ipairs(folder:GetChildren()) do
            if v.Name == "Noobie Coin" and v:IsA("BasePart") then
                table.insert(list, v)
            end
        end
    end
    if #list == 0 then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v.Name == "Noobie Coin" and v:IsA("BasePart") then
                table.insert(list, v)
            end
        end
    end
    return list
end

local function getRoot()
    local char = player.Character
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function teleportTo(cf)
    local char = player.Character
    if char then
        char:PivotTo(cf + Vector3.new(0, 3, 0))
    end
end

local espObjects = {}

local function clearESP(kind)
    for i = #espObjects, 1, -1 do
        local obj = espObjects[i]
        if obj.Kind == kind then
            if obj.Highlight and obj.Highlight.Parent then obj.Highlight:Destroy() end
            if obj.Billboard and obj.Billboard.Parent then obj.Billboard:Destroy() end
            table.remove(espObjects, i)
        end
    end
end

local function addESP(target, kind, labelText, outlineColor, fillColor, adorneePart)
    if not target or not target.Parent then return end
    for _, obj in ipairs(espObjects) do
        if obj.Target == target then return end
    end
    local highlight = Instance.new("Highlight")
    highlight.OutlineColor = outlineColor
    highlight.FillColor = fillColor
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = target
    highlight.Parent = target
    local attachPart = adorneePart
    if not attachPart then
        if target:IsA("Model") then
            attachPart = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head") or target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart", true)
        else
            attachPart = target
        end
    end
    if not attachPart then
        highlight:Destroy()
        return
    end
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = attachPart
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = fillColor
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 16
    label.Text = labelText
    label.Parent = billboard
    billboard.Parent = attachPart
    table.insert(espObjects, {
        Target = target,
        Part = attachPart,
        Kind = kind,
        Label = label,
        LabelText = labelText,
        Highlight = highlight,
        Billboard = billboard,
    })
end

RunService.Heartbeat:Connect(function()
    local root = getRoot()
    if not root then return end
    for i = #espObjects, 1, -1 do
        local obj = espObjects[i]
        if not obj.Target or not obj.Target.Parent or not obj.Part or not obj.Part.Parent then
            if obj.Highlight and obj.Highlight.Parent then obj.Highlight:Destroy() end
            if obj.Billboard and obj.Billboard.Parent then obj.Billboard:Destroy() end
            table.remove(espObjects, i)
        else
            local dist = (root.Position - obj.Part.Position).Magnitude
            obj.Label.Text = string.format("%s\n距离: %.1f", obj.LabelText, dist)
        end
    end
end)

local noobESPEnabled = false
local coinESPEnabled = false

local function refreshNoobESP()
    clearESP("Noob")
    if not noobESPEnabled then return end
    for _, noob in ipairs(getNoobies()) do
        local pose = noob.Name:gsub("%s*Noobie%s*$", "")
        addESP(noob, "Noob", noob.Name .. "\n姿势: " .. pose, Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 255, 0))
    end
end

local function refreshCoinESP()
    clearESP("Coin")
    if not coinESPEnabled then return end
    for _, coin in ipairs(getCoins()) do
        addESP(coin, "Coin", "金币", Color3.fromRGB(255, 215, 0), Color3.fromRGB(255, 215, 0), coin)
    end
end

task.spawn(function()
    while true do
        task.wait(3)
        if noobESPEnabled then
            local known = {}
            for _, obj in ipairs(espObjects) do
                if obj.Kind == "Noob" then known[obj.Target] = true end
            end
            for _, noob in ipairs(getNoobies()) do
                if not known[noob] then
                    local pose = noob.Name:gsub("%s*Noobie%s*$", "")
                    addESP(noob, "Noob", noob.Name .. "\n姿势: " .. pose, Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 255, 0))
                end
            end
        end
        if coinESPEnabled then
            local known = {}
            for _, obj in ipairs(espObjects) do
                if obj.Kind == "Coin" then known[obj.Target] = true end
            end
            for _, coin in ipairs(getCoins()) do
                if not known[coin] then
                    addESP(coin, "Coin", "金币", Color3.fromRGB(255, 215, 0), Color3.fromRGB(255, 215, 0), coin)
                end
            end
        end
    end
end)

local function nearestNoobie()
    local root = getRoot()
    if not root then return nil end
    local best, bestDist = nil, math.huge
    for _, noob in ipairs(getNoobies()) do
        local part = noob:FindFirstChild("HumanoidRootPart") or noob.PrimaryPart or noob:FindFirstChildWhichIsA("BasePart", true)
        if part then
            local d = (root.Position - part.Position).Magnitude
            if d < bestDist then
                bestDist = d
                best = part
            end
        end
    end
    return best
end

local function nearestCoin()
    local root = getRoot()
    if not root then return nil end
    local best, bestDist = nil, math.huge
    for _, coin in ipairs(getCoins()) do
        local d = (root.Position - coin.Position).Magnitude
        if d < bestDist then
            bestDist = d
            best = coin
        end
    end
    return best
end

local NoobGroup = Tabs.Main:AddLeftGroupbox("菜鸟")

NoobGroup:AddToggle("NoobESP", {
    Text = "透视菜鸟",
    Default = false,
    Callback = function(v)
        noobESPEnabled = v
        refreshNoobESP()
    end,
})

NoobGroup:AddButton("传送到最近的菜鸟", function()
    local part = nearestNoobie()
    if part then
        teleportTo(part.CFrame)
    else
        Library:Notify({ Title = "提示", Description = "没有找到菜鸟", Time = 3 })
    end
end)

local noobBlacklist = {}
local autoNoobRunning = false

NoobGroup:AddToggle("AutoNoob", {
    Text = "自动收集菜鸟",
    Default = false,
    Callback = function(v)
        if v and not autoNoobRunning then
            autoNoobRunning = true
            task.spawn(function()
                while Toggles.AutoNoob.Value do
                    local didSomething = false
                    for _, noob in ipairs(getNoobies()) do
                        if not Toggles.AutoNoob.Value then break end
                        if not noobBlacklist[noob] and noob.Parent then
                            local part = noob:FindFirstChild("HumanoidRootPart") or noob.PrimaryPart or noob:FindFirstChildWhichIsA("BasePart", true)
                            if part then
                                teleportTo(part.CFrame)
                                noobBlacklist[noob] = true
                                didSomething = true
                                task.wait(1)
                            end
                        end
                    end
                    if not didSomething then
                        task.wait(2)
                    end
                end
                autoNoobRunning = false
            end)
        end
    end,
})

NoobGroup:AddButton("清除不会再传送黑名单", function()
    noobBlacklist = {}
    Library:Notify({ Title = "提示", Description = "黑名单已清除，所有菜鸟可重新传送", Time = 3 })
end)

local poseValues = {}
local poseMap = {}
for _, noob in ipairs(getNoobies()) do
    local pose = noob.Name:gsub("%s*Noobie%s*$", "")
    if not poseMap[pose] then
        poseMap[pose] = {}
        table.insert(poseValues, pose)
    end
    table.insert(poseMap[pose], noob)
end
table.sort(poseValues)
if #poseValues == 0 then
    poseValues = { "未找到" }
end

NoobGroup:AddDropdown("PoseSelect", {
    Values = poseValues,
    Default = 1,
    Multi = false,
    Text = "选定姿势传送",
    Callback = function(v) end,
})

NoobGroup:AddButton("传送到选定姿势的菜鸟", function()
    local pose = Options.PoseSelect.Value
    local list = poseMap[pose]
    if list then
        local root = getRoot()
        local best, bestDist = nil, math.huge
        for _, noob in ipairs(list) do
            if noob.Parent then
                local part = noob:FindFirstChild("HumanoidRootPart") or noob.PrimaryPart or noob:FindFirstChildWhichIsA("BasePart", true)
                if part and root then
                    local d = (root.Position - part.Position).Magnitude
                    if d < bestDist then
                        bestDist = d
                        best = part
                    end
                end
            end
        end
        if best then
            teleportTo(best.CFrame)
            return
        end
    end
    Library:Notify({ Title = "提示", Description = "该姿势的菜鸟不存在", Time = 3 })
end)

local CoinGroup = Tabs.Main:AddRightGroupbox("金币")

CoinGroup:AddToggle("CoinESP", {
    Text = "透视金币",
    Default = false,
    Callback = function(v)
        coinESPEnabled = v
        refreshCoinESP()
    end,
})

CoinGroup:AddButton("传送到最近的金币", function()
    local coin = nearestCoin()
    if coin then
        teleportTo(coin.CFrame)
    else
        Library:Notify({ Title = "提示", Description = "没有找到金币", Time = 3 })
    end
end)

local autoCoinRunning = false

CoinGroup:AddToggle("AutoCoin", {
    Text = "自动收集金币",
    Default = false,
    Callback = function(v)
        if v and not autoCoinRunning then
            autoCoinRunning = true
            task.spawn(function()
                while Toggles.AutoCoin.Value do
                    local coins = getCoins()
                    if #coins == 0 then
                        task.wait(2)
                    else
                        for _, coin in ipairs(coins) do
                            if not Toggles.AutoCoin.Value then break end
                            if coin.Parent then
                                teleportTo(coin.CFrame)
                                task.wait(2)
                            end
                        end
                    end
                end
                autoCoinRunning = false
            end)
        end
    end,
})

local UnloadGroup = Tabs.Settings:AddLeftGroupbox("脚本管理")
UnloadGroup:AddButton("卸载脚本", function()
    noobESPEnabled = false
    coinESPEnabled = false
    clearESP("Noob")
    clearESP("Coin")
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
