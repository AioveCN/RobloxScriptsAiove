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

local _ENV = getfenv()
local g = _ENV["game"]
local rs = g:GetService("ReplicatedStorage")
local ev = rs.Events.GameRemoteFunction
local pls = g:GetService("Players")
local me = pls.LocalPlayer
local m = math
local V3 = Vector3.new
local s = string
local c = s.char
local tsk = task
local ins = Instance.new

local e = c(65)..c(116)..c(116)..c(101)..c(109)..c(112)..c(116)..c(87)..c(101)..c(97)..c(112)..c(111)..c(110)..c(72)..c(105)..c(116)
local gacha = c(65)..c(116)..c(116)..c(101)..c(109)..c(112)..c(116)..c(82)..c(111)..c(108)..c(108)..c(71)..c(97)..c(99)..c(104)..c(97)..c(67)..c(104)..c(101)..c(115)..c(116)

local en = false
local rng = 200
local hgt = 200
local iv = 0.01

local basicChest = false
local divineChest = false
local chestIv = 0.5

local autoEquip = false

local showModels = false
local espEnabled = false

local function doHit()
    local ch = me.Character
    if not ch then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local myPos = hrp.Position
    local mx, my, mz = myPos.X, myPos.Y, myPos.Z
    local tool = ch:FindFirstChild("Steel")
    local tool = ch:FindFirstChild("Steel")

    local hits = {}
    local idx = 0

    for _, p in ipairs(pls:GetPlayers()) do
        if p ~= me then
            local tch = p.Character
            if tch then
                local thrp = tch:FindFirstChild("HumanoidRootPart")
                local hum = tch:FindFirstChild("Humanoid")
                if thrp and hum and hum.Health > 0 then
                    local tpos = thrp.Position
                    local tx, ty, tz = tpos.X, tpos.Y, tpos.Z
                    local hDist = m.sqrt((tx - mx)^2 + (tz - mz)^2)
                    local vDist = m.abs(ty - my)
                    if hDist <= rng and vDist <= hgt then
                        idx = idx + 1
                        local dx = tx - mx
                        local dy = ty - my
                        local dz = tz - mz
                        local mg = m.sqrt(dx*dx + dy*dy + dz*dz)
                        if mg < 0.001 then mg = 0.001 end
                        local dr = V3(dx/mg, dy/mg, dz/mg)
                        hits[idx] = {
                            ["knockback"] = 50,
                            ["isClosestEnemy"] = (idx == 1),
                            ["origin"] = tpos,
                            ["enemyModel"] = tch,
                            ["distance"] = mg,
                            ["direction"] = dr
                        }
                    end
                end
            end
        end
    end

    if idx == 0 then return end

    local t = {}
    t[1] = e
    t[2] = {}
    local w = t[2]
    w["hitboxOffset"] = V3(0, 0, -1.5)
    w["knockback"] = 50
    w["shouldLock"] = true
    w["shouldSlow"] = true
    local acd = {}
    acd["knockbackMul"] = 1
    acd["slowMult"] = 0.2
    acd["slowTime"] = 1.5
    acd["lungeMul"] = 1
    acd["attackTime"] = 0.65
    w["attackCycleData"] = acd
    w["isCritical"] = false

    local wd = {}
    local ac = {}
    ac["1"] = {["knockbackMul"]=1,["slowMult"]=0.2,["slowTime"]=1.5,["lungeMul"]=1,["attackTime"]=0.65}
    ac["4"] = {["lungeMult"]=2.25,["hitboxOffsetAdd"]=V3(0,0,-1.5),["slowMult"]=0.2,["slowTime"]=1.5,["hitboxSizeAdd"]=V3(0,0,3),["knockbackMult"]=2.25,["attackTime"]=0.9833333333333333}
    ac["3"] = {["lungeMult"]=0.75,["slowMult"]=0.2,["slowTime"]=1.5,["knockbackMult"]=1.5,["attackTime"]=0.7166666666666667}
    ac["2"] = {["lungeMult"]=1,["slowMult"]=0.2,["slowTime"]=1.5,["knockbackMult"]=1,["attackTime"]=0.65}
    wd["attackCycle"] = ac
    wd["attackOrder"] = {[1]="1",[2]="2",[3]="3",[4]="4"}
    w["weaponDefinition"] = wd

    w["attackCooldown"] = 0
    w["hitboxSize"] = V3(9, 14, 8)
    w["lungeKnockback"] = 55
    w["slowTime"] = 1.5
    w["slowMult"] = 0.2
    w["cycleIndex"] = 1
    w["damage"] = 100
    w["tool"] = tool
    w["shouldLunge"] = true

    t[3] = hits

    ev:InvokeServer(unpack(t))
end

tsk.spawn(function()
    while true do
        if en then
            tsk.spawn(function()
                pcall(doHit)
            end)
        end
        tsk.wait(iv)
    end
end)

tsk.spawn(function()
    while true do
        if basicChest then
            tsk.spawn(function()
                pcall(function()
                    ev:InvokeServer(gacha, "Basic")
                end)
            end)
        end
        tsk.wait(chestIv)
    end
end)

tsk.spawn(function()
    while true do
        if divineChest then
            tsk.spawn(function()
                pcall(function()
                    ev:InvokeServer(gacha, "Divine")
                end)
            end)
        end
        tsk.wait(chestIv)
    end
end)


tsk.spawn(function()
    while true do
        if autoEquip then
            local ch = me.Character
            if ch then
                local hum = ch:FindFirstChild("Humanoid")
                if hum then
                    local bp = me:FindFirstChild("Backpack")
                    if bp then
                        for _, v in ipairs(bp:GetChildren()) do
                            if v:IsA("Tool") then
                                pcall(function()
                                    hum:EquipTool(v)
                                end)
                                break
                            end
                        end
                    end
                end
            end
        end
        tsk.wait(0.1)
    end
end)

local espGui = ins("ScreenGui")
local espFolder = ins("Folder")
local espLabels = {}

pcall(function()
    espGui.Name = "ESP_Gui"
    espGui.ResetOnSpawn = false
    espGui.Parent = me:WaitForChild("PlayerGui")
    espFolder.Name = "ESP_Folder"
    espFolder.Parent = espGui
end)

pls.PlayerRemoving:Connect(function(p)
    if espLabels[p] then
        pcall(function() espLabels[p]:Destroy() end)
        espLabels[p] = nil
    end
end)

tsk.spawn(function()
    while true do
        if showModels then
            for _, p in ipairs(pls:GetPlayers()) do
                if p ~= me then
                    local tch = p.Character
                    if tch then
                        for _, obj in ipairs(tch:GetDescendants()) do
                            if obj:IsA("BasePart") then
                                pcall(function()
                                    obj.Transparency = 0
                                    obj.LocalTransparencyModifier = 0
                                    obj.CastShadow = true
                                end)
                            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                                pcall(function()
                                    obj.Transparency = 0
                                end)
                            elseif obj:IsA("ForceField") then
                                pcall(function()
                                    obj.Visible = true
                                end)
                            end
                        end
                        local hum = tch:FindFirstChildOfClass("Humanoid")
                        if hum then
                            pcall(function()
                                hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                            end)
                        end
                        pcall(function()
                            tch.PrimaryPart = tch:FindFirstChild("HumanoidRootPart")
                        end)
                    end
                end
            end
        end
        tsk.wait(0.1)
    end
end)

tsk.spawn(function()
    while true do
        if espEnabled then
            local myCh = me.Character
            local myHrp = nil
            if myCh then
                myHrp = myCh:FindFirstChild("HumanoidRootPart")
            end
            local myPos = nil
            if myHrp then
                myPos = myHrp.Position
            end

            for _, p in ipairs(pls:GetPlayers()) do
                if p ~= me then
                    local tch = p.Character
                    local thrp = nil
                    if tch then
                        thrp = tch:FindFirstChild("HumanoidRootPart")
                    end

                    if tch and thrp then
                        local bb = espLabels[p]
                        if not bb then
                            bb = ins("BillboardGui")
                            bb.Name = p.Name .. "_ESP"
                            bb.AlwaysOnTop = true
                            bb.Size = UDim2.new(0, 120, 0, 50)
                            bb.StudsOffset = Vector3.new(0, 3.5, 0)
                            bb.MaxDistance = 9999
                            bb.Parent = espFolder

                            local nameLabel = ins("TextLabel")
                            nameLabel.Name = "NameLabel"
                            nameLabel.Size = UDim2.new(1, 0, 0, 20)
                            nameLabel.Position = UDim2.new(0, 0, 0, 0)
                            nameLabel.BackgroundTransparency = 1
                            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                            nameLabel.TextStrokeTransparency = 0
                            nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                            nameLabel.Font = Enum.Font.GothamBold
                            nameLabel.TextSize = 14
                            nameLabel.Text = p.Name
                            nameLabel.Parent = bb

                            local distLabel = ins("TextLabel")
                            distLabel.Name = "DistLabel"
                            distLabel.Size = UDim2.new(1, 0, 0, 18)
                            distLabel.Position = UDim2.new(0, 0, 0, 20)
                            distLabel.BackgroundTransparency = 1
                            distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                            distLabel.TextStrokeTransparency = 0
                            distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                            distLabel.Font = Enum.Font.GothamBold
                            distLabel.TextSize = 12
                            distLabel.Parent = bb

                            espLabels[p] = bb
                        end

                        bb.Adornee = thrp
                        bb.Enabled = true
                        bb.NameLabel.Text = p.Name

                        if myPos then
                            local dist = (thrp.Position - myPos).Magnitude
                            bb.DistLabel.Text = s.format("%.1f m", dist)
                        else
                            bb.DistLabel.Text = "??? m"
                        end
                    else
                        if espLabels[p] then
                            pcall(function() espLabels[p]:Destroy() end)
                            espLabels[p] = nil
                        end
                    end
                end
            end
        else
            for p, gui in pairs(espLabels) do
                if gui then
                    pcall(function() gui:Destroy() end)
                end
                espLabels[p] = nil
            end
        end
        tsk.wait(0.1)
    end
end)

local Window = Library:CreateWindow({
    Title = "沉默的刺客",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify("沉默的刺客 - 创作者：Aiove", 5)

local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Main = Window:AddTab("主要", "info"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel('Aiove将持续更新此脚本')
NoticeGroup:AddLabel('创作者：Aiove')

local AuraGroup = Tabs.Main:AddLeftGroupbox("杀戮光环")
AuraGroup:AddToggle('AuraToggle', {
    Text = '杀戮光环（必须拿刀且是初始刀）',
    Default = false,
    Callback = function(Value)
        en = Value
    end
})
AuraGroup:AddSlider('AuraRange', {
    Text = '范围半径（水平）',
    Default = 200,
    Min = 5,
    Max = 200,
    Rounding = 0,
    Suffix = " m",
    Callback = function(Value)
        rng = Value
    end
})
AuraGroup:AddSlider('AuraHeight', {
    Text = '高度范围（上下）',
    Default = 200,
    Min = 5,
    Max = 200,
    Rounding = 0,
    Suffix = " m",
    Callback = function(Value)
        hgt = Value
    end
})
AuraGroup:AddSlider('AuraInterval', {
    Text = '执行间隔',
    Default = 0.01,
    Min = 0.01,
    Max = 1,
    Rounding = 2,
    Suffix = " s",
    Callback = function(Value)
        iv = Value
    end
})

local ChestGroup = Tabs.Main:AddRightGroupbox("自动抽宝箱")
ChestGroup:AddToggle('BasicChestToggle', {
    Text = '自动抽取普通宝箱',
    Default = false,
    Callback = function(Value)
        basicChest = Value
    end
})
ChestGroup:AddToggle('DivineChestToggle', {
    Text = '自动抽取神圣宝箱',
    Default = false,
    Callback = function(Value)
        divineChest = Value
    end
})
ChestGroup:AddSlider('ChestInterval', {
    Text = '抽宝箱间隔',
    Default = 0.5,
    Min = 0.1,
    Max = 5,
    Rounding = 2,
    Suffix = " s",
    Callback = function(Value)
        chestIv = Value
    end
})

ChestGroup:AddToggle('AutoEquipToggle', {
    Text = '自动拿起刀',
    Default = false,
    Callback = function(Value)
        autoEquip = Value
    end
})

local VisualGroup = Tabs.Main:AddRightGroupbox("透视与显示")
VisualGroup:AddToggle('ShowModelsToggle', {
    Text = '显示人物建模（强制显现）',
    Default = false,
    Callback = function(Value)
        showModels = Value
    end
})
VisualGroup:AddToggle('ESPToggle', {
    Text = '透视（用户名+距离）',
    Default = false,
    Callback = function(Value)
        espEnabled = Value
    end
})

local SettingsGroup = Tabs.Settings:AddLeftGroupbox("菜单")
SettingsGroup:AddButton({ Text = '卸载脚本', Func = function()
    en = false
    basicChest = false
    divineChest = false
    autoEquip = false
    showModels = false
    espEnabled = false
    for p, gui in pairs(espLabels) do
        if gui then
            pcall(function() gui:Destroy() end)
        end
        espLabels[p] = nil
    end
    pcall(function() espGui:Destroy() end)
    Library:Unload()
end })

SettingsGroup:AddLabel('菜单快捷键'):AddKeyPicker('MenuKeybind', {
    Default = 'RightShift',
    NoUI = true,
    Text = 'Menu keybind'
})
Library.ToggleKeybind = Options.MenuKeybind

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
