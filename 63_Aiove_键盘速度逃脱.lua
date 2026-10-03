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
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local moveSpeed = 16
local customSpeedEnabled = false
local speedFluctuation = 5
local fluctuationToggle = false
local lastFluctuationUpdate = 0

local autoFarmEnabled = false
local autoFarmMoveSpeed = 80
local autoFarmTargetIndex = 1
local autoFarmPoints = {
    Vector3.new(-56.5, 9.1, 72.0),
    Vector3.new(69.2, 9.1, -13.8)
}

local autoWinEnabled = false
local autoWinPos = Vector3.new(-13998.3, 754.7, 3064.6)

local function getCurrentHumanoid()
    local char = player.Character
    if char then
        return char:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

local function cleanup()
    autoFarmEnabled = false
    autoWinEnabled = false
    customSpeedEnabled = false
    moveSpeed = 16
    speedFluctuation = 5
    local hum = getCurrentHumanoid()
    if hum then
        hum:Move(Vector3.zero, false)
        hum.WalkSpeed = 16
    end
end

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
end)

-- 每帧强制锁定速度 + 自动刷移动 + 自动刷胜利
RunService.RenderStepped:Connect(function(dt)
    local hum = getCurrentHumanoid()
    if not hum then return end
    
    local hrp = hum.Parent and hum.Parent:FindFirstChild("HumanoidRootPart")
    
    -- 优先级：自动刷胜利 > 自动刷速度 > 修改移速
    if autoWinEnabled then
        if hrp then
            local dist = (hrp.Position - autoWinPos).Magnitude
            if dist > 1 then
                hrp.CFrame = CFrame.new(autoWinPos)
            end
        end
    elseif autoFarmEnabled then
        hum.WalkSpeed = autoFarmMoveSpeed
        
        if hrp then
            local target = autoFarmPoints[autoFarmTargetIndex]
            local dist = (target - hrp.Position).Magnitude
            
            if dist < 5 then
                autoFarmTargetIndex = autoFarmTargetIndex == 1 and 2 or 1
            else
                local dir = (target - hrp.Position).Unit
                hum:Move(Vector3.new(dir.X, 0, dir.Z), false)
            end
        end
    elseif customSpeedEnabled then
        if speedFluctuation > 0 then
            local now = tick()
            if now - lastFluctuationUpdate >= 0.3 then
                lastFluctuationUpdate = now
                fluctuationToggle = not fluctuationToggle
            end
            hum.WalkSpeed = fluctuationToggle and (moveSpeed + speedFluctuation) or (moveSpeed - speedFluctuation)
        else
            hum.WalkSpeed = moveSpeed
        end
    end
end)

local Window = Library:CreateWindow({
    Title = "速度键盘逃脱",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify("速度键盘逃脱脚本 - 创作者：Aiove", 5)

local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Main = Window:AddTab("功能", "info"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel('Aiove将持续更新此脚本')
NoticeGroup:AddLabel('创作者：Aiove')

-- ==================== 玩家修改（左侧分组） ====================
local PlayerGroup = Tabs.Main:AddLeftGroupbox("玩家修改")

PlayerGroup:AddToggle('CustomSpeedToggle', {
    Text = '修改移速',
    Default = false,
    Tooltip = '开启后可自定义移动速度',
    Callback = function(Value)
        customSpeedEnabled = Value
        if not Value then
            local hum = getCurrentHumanoid()
            if hum then hum.WalkSpeed = 16 end
        end
    end
})

PlayerGroup:AddSlider('WalkSpeedSlider', {
    Text = '速度调整',
    Default = 16,
    Min = 0,
    Max = 200,
    Rounding = 0,
    Suffix = "",
    Callback = function(Value)
        moveSpeed = Value
    end
})

PlayerGroup:AddSlider('FluctuationSlider', {
    Text = '防检测波动',
    Default = 5,
    Min = 0,
    Max = 50,
    Rounding = 0,
    Suffix = "",
    Tooltip = '在设定速度上下波动，0为固定速度',
    Callback = function(Value)
        speedFluctuation = Value
    end
})

PlayerGroup:AddButton({ 
    Text = '召唤飞行脚本', 
    Func = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/kongbaNB/9178/refs/heads/main/fly.lua"))()
        end)
        if not success then
            Library:Notify("飞行脚本加载失败: " .. tostring(err), 3)
        else
            Library:Notify("飞行脚本已执行", 3)
        end
    end 
})

PlayerGroup:AddToggle('AutoFarmToggle', {
    Text = '自动刷速度',
    Default = false,
    Tooltip = '在两点之间平滑循环移动，人物处于走路状态',
    Callback = function(Value)
        autoFarmEnabled = Value
        if not Value then
            autoFarmTargetIndex = 1
            local hum = getCurrentHumanoid()
            if hum then
                hum:Move(Vector3.zero, false)
                hum.WalkSpeed = 16
            end
        end
    end
})

PlayerGroup:AddSlider('AutoFarmSpeedSlider', {
    Text = '自动刷速度',
    Default = 80,
    Min = 10,
    Max = 300,
    Rounding = 0,
    Suffix = " studs/s",
    Callback = function(Value)
        autoFarmMoveSpeed = Value
    end
})

-- ==================== 游戏修改（右侧分组） ====================
local GameGroup = Tabs.Main:AddRightGroupbox("游戏修改")

GameGroup:AddToggle('AutoWinToggle', {
    Text = '自动刷胜利（被检测了不要用）',
    Default = false,
    Tooltip = '锁定在胜利坐标，偏离后自动传送回去',
    Callback = function(Value)
        autoWinEnabled = Value
        if Value then
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(-13998.3, 754.7, 3064.6)
                end
            end
        end
    end
})

GameGroup:AddButton({ 
    Text = '传送到终点', 
    Func = function()
        local char = player.Character
        if not char then
            Library:Notify("角色不存在", 3)
            return
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            Library:Notify("未找到 HumanoidRootPart", 3)
            return
        end
        hrp.CFrame = CFrame.new(-14006.9, 750.8, 3083.6)
        Library:Notify("已传送到终点", 3)
    end 
})

-- ==================== 设置 ====================
local SettingsGroup = Tabs.Settings:AddLeftGroupbox("菜单")
SettingsGroup:AddButton({ Text = '卸载脚本', Func = function()
    cleanup()
    Library:Unload()
end })

SettingsGroup:AddButton({ Text = '重载界面', Func = function()
    cleanup()
    Library:Unload()
    loadstring(game:HttpGet(game:GetService("HttpService"):UrlEncode("https://pastebin.com/raw/你的脚本地址")))()
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
