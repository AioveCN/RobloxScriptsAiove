-- This file has been deobfuscated Luraph using Hurricane https://discord.com/invite/AbeurBzKXe
local a = game:GetService("Players").LocalPlayer
local b = a.Character or a.CharacterAdded:Wait()
local c = game:GetService("ReplicatedStorage")
local sbns = { c = false, s = false, p = false }
local buySeed = false
local buyGear = false

local seeds = {}
local selectseed = ""
pcall(function()
    for _,v in next, a.PlayerGui.Seed_Shop.Frame.ScrollingFrame:GetChildren() do
        if v.ClassName == "Frame" and not v.Name:find("Padding") then
            table.insert(seeds, v.Name)
        end
    end
end)

local gear = {}
local selectgear = ""
pcall(function()
    for _,v in next, a.PlayerGui.Gear_Shop.Frame.ScrollingFrame:GetChildren() do
        if v.ClassName == "Frame" and not v.Name:find("_") then
            table.insert(gear, v.Name)
        end
    end
end)

pcall(function()
    hookfunction(require(c.Modules.PlayerLuck).GetLuck, function() return math.huge end)
    hookfunction(require(c.Modules.PlayerLuck).GetModifiers, function()
        return {{ Name = "Fake_Luck", Modifier = math.huge }}
    end)
    for _,v in ipairs(require(c.Data.SessionTimeLuckData).Timer) do
        if v.Luck then v.Luck = math.huge end
    end
    hookfunction(require(c.Modules.SessionTimeLuckController).GetCurrentLuck, function() return math.huge end)
end)

local HttpService = game:GetService("HttpService")
local translatedTexts = {}
local function translate(name)
    if translatedTexts[name] then return translatedTexts[name] end
    local ok, result = pcall(function()
        local url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=zh-CN&dt=t&q=" .. HttpService:UrlEncode(name)
        local response = game:HttpGet(url)
        local decoded = HttpService:JSONDecode(response)
        if decoded and decoded[1] and decoded[1][1] and decoded[1][1][1] then
            return decoded[1][1][1]
        end
        return nil
    end)
    if ok and result and result ~= name then
        translatedTexts[name] = result
        return result
    end
    translatedTexts[name] = name
    return name
end

local seedReverse = {}
local gearReverse = {}
for _, name in ipairs(seeds) do seedReverse[name] = name end
for _, name in ipairs(gear) do gearReverse[name] = name end

if #seeds == 0 then table.insert(seeds, "暂无种子") end
if #gear == 0 then table.insert(gear, "暂无工具") end

local seedDisp = {}
for _, name in ipairs(seeds) do
    if name == "暂无种子" then
        table.insert(seedDisp, name)
    else
        local t = translate(name)
        if t ~= name then seedReverse[t] = name end
        table.insert(seedDisp, t)
    end
end

local gearDisp = {}
for _, name in ipairs(gear) do
    if name == "暂无工具" then
        table.insert(gearDisp, name)
    else
        local t = translate(name)
        if t ~= name then gearReverse[t] = name end
        table.insert(gearDisp, t)
    end
end

local function safeLoad(url) local success, result = pcall(function() return loadstring(game:HttpGet(url))() end) if not success then warn("加载失败: " .. url) return nil end return result end
local Library = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/黑曜石主库.ui")
local ThemeManager = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/主题管理.ui")
local SaveManager = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/配置管理.ui")
if not Library then game:GetService("StarterGui"):SetCore("SendNotification", { Title = "错误", Text = "UI 库加载失败，请检查网络或脚本资源", Duration = 5, }) return end
local Options = Library.Options
local Toggles = Library.Toggles
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local Window = Library:CreateWindow({
    Title = "种植花园",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})
Library:Notify({
    Title = "种植花园",
    Description = "创作者：Aiove\nQQ：3999698324\n脚本已加载成功",
    Time = 5,
})
local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Main = Window:AddTab("主要", "info"),
    Teleport = Window:AddTab("传送", "map-pin"),
    Settings = Window:AddTab("设置", "settings"),
}
local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel('Aiove将持续更新此脚本')
NoticeGroup:AddLabel('创作者：Aiove')
local UnloadGroup = Tabs.Settings:AddLeftGroupbox("脚本管理")
UnloadGroup:AddButton("卸载脚本", function() Library:Unload() end)
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

local GearGroup = Tabs.Main:AddLeftGroupbox("购买工具")

GearGroup:AddToggle("AutoBuyGear", {
    Text = "自动购买工具",
    Default = false,
    Callback = function(state)
        buyGear = state
        spawn(function()
            while wait() and buyGear do
                if selectgear ~= "" then
                    c.GameEvents.BuyGearStock:FireServer(unpack({[1] = selectgear}))
                end
            end
        end)
    end
})

GearGroup:AddDropdown("SelectGear", {
    Text = "选择工具",
    Values = gearDisp,
    Default = 1,
    Multi = false,
    Callback = function(value)
        selectgear = gearReverse[value] or value
    end
})

local GearInfoLabel = GearGroup:AddLabel("工具信息: 等待选择...")

local MainGroup = Tabs.Main:AddLeftGroupbox("主要功能")

MainGroup:AddToggle("AutoCollect", {
    Text = "自动收集",
    Default = false,
    Callback = function(state)
        sbns.c = state
        spawn(function()
            while wait() and sbns.c do
                pcall(function()
                    for _, e in pairs(workspace.Farm:GetChildren()) do
                        if e:FindFirstChild("Important") and e.Important.Data.Owner.Value == a.Name then
                            for _, g in ipairs(e.Important.Plants_Physical:GetDescendants()) do
                                if g:IsA("ProximityPrompt") then
                                    b.Humanoid:MoveTo(g.Parent.Position)
                                    fireproximityprompt(g)
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end
})

MainGroup:AddToggle("AutoSell", {
    Text = "自动售卖",
    Default = false,
    Callback = function(state)
        sbns.s = state
        spawn(function()
            while wait() and sbns.s do
                if #a.Backpack:GetChildren() > 20 then
                    local h = b.HumanoidRootPart.CFrame
                    b.HumanoidRootPart.CFrame = workspace.NPCS["Sell Stands"]["Shop Stand"].CFrame * CFrame.new(0, 0, 3)
                    wait(0.5)
                    c.GameEvents.Sell_Item:FireServer()
                    c.GameEvents.Sell_Inventory:FireServer()
                    wait(1)
                    b.HumanoidRootPart.CFrame = h
                end
            end
        end)
    end
})

MainGroup:AddToggle("AutoPlant", {
    Text = "自动种植",
    Default = false,
    Callback = function(state)
        sbns.p = state
        spawn(function()
            while wait() and sbns.p do
                pcall(function()
                    local seedType, tool
                    local containers = {b, a.Backpack}
                    for _, cont in ipairs(containers) do
                        for _, i in ipairs(cont:GetChildren()) do
                            if i:IsA("Tool") and i.Name:find("Seed") then
                                seedType = i.Name:match("^(.-) Seed"); tool = i; break
                            end
                        end
                        if tool then break end
                    end
                    if tool and seedType then
                        if tool.Parent == a.Backpack then b.Humanoid:EquipTool(tool) end
                        c.GameEvents.Plant_RE:FireServer(Vector3.new(math.floor(b.HumanoidRootPart.Position.X), 0.1, math.floor(b.HumanoidRootPart.Position.Z)), seedType)
                    end
                end)
            end
        end)
    end
})

local SeedGroup = Tabs.Main:AddRightGroupbox("购买种子")

SeedGroup:AddToggle("AutoBuySeed", {
    Text = "自动购买种子",
    Default = false,
    Callback = function(state)
        buySeed = state
        spawn(function()
            while wait() and buySeed do
                if selectseed ~= "" then
                    c.GameEvents.BuySeedStock:FireServer("Tier 1", selectseed)
                end
            end
        end)
    end
})

SeedGroup:AddDropdown("SelectSeed", {
    Text = "选择种子",
    Values = seedDisp,
    Default = 1,
    Multi = false,
    Callback = function(value)
        selectseed = seedReverse[value] or value
    end
})

local SeedInfoLabel = SeedGroup:AddLabel("种子信息: 等待选择...")

task.spawn(function()
    while wait(1) do
        pcall(function()
            if selectseed ~= "" then
                local f = a.PlayerGui.Seed_Shop.Frame.ScrollingFrame:FindFirstChild(selectseed)
                if f then SeedInfoLabel:SetText("种子信息: 价格: " .. f.Main_Frame.Cost_Text.Text .. " | 数量: " .. f.Main_Frame.Stock_Text.Text) end
            end
            if selectgear ~= "" then
                local f = a.PlayerGui.Gear_Shop.Frame.ScrollingFrame:FindFirstChild(selectgear)
                if f then GearInfoLabel:SetText("工具信息: 价格: " .. f.Main_Frame.Cost_Text.Text .. " | 数量: " .. f.Main_Frame.Stock_Text.Text) end
            end
        end)
    end
end)

local TeleportGroup = Tabs.Teleport:AddLeftGroupbox("传送地点")

TeleportGroup:AddButton("传送到出售店", function()
    b.HumanoidRootPart.CFrame = CFrame.new(36.6, 3.0, 0.4)
end)

TeleportGroup:AddButton("传送到购买店", function()
    b.HumanoidRootPart.CFrame = CFrame.new(38.0, 3.0, -26.7)
end)

TeleportGroup:AddButton("传送到装备店", function()
    b.HumanoidRootPart.CFrame = CFrame.new(-237.5, 3.0, -5.0)
end)
