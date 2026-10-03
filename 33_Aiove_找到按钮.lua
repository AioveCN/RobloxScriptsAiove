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
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local moveSpeed = 16
local espEnabled = false
local espRange = 1000
local noRepeatTeleport = false
local visitedButtons = {}
local noClipEnabled = false
local infiniteJumpEnabled = false
local jumpRequest = false
local jumpConnections = {}

local function addTrueButtonMarker(part)
    if not part:IsA("BasePart") then return end
    if part:FindFirstChild("ButtonMarker") then return end
    if not part:FindFirstChildOfClass("ClickDetector") then return end
    pcall(function()
        local highlight = Instance.new("Highlight")
        highlight.Name = "ButtonMarker"
        highlight.FillColor = Color3.new(1, 1, 0)
        highlight.OutlineColor = Color3.new(1, 0.3, 0)
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0.1
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Enabled = false
        highlight.Parent = part

        local bill = Instance.new("BillboardGui")
        bill.Name = "ButtonText"
        bill.Adornee = part
        bill.AlwaysOnTop = true
        bill.Size = UDim2.new(0, 30, 0, 15)
        bill.StudsOffset = Vector3.new(0, 1, 0)
        bill.MaxDistance = 99999
        bill.Enabled = false
        bill.Parent = part

        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Text = "按钮"
        text.TextColor3 = Color3.new(1, 1, 0)
        text.TextScaled = true
        text.TextSize = 12
        text.Parent = bill
    end)
end

local function updateESP()
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    local unlimited = espRange >= 1000
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v:FindFirstChildOfClass("ClickDetector") then
            local marker = v:FindFirstChild("ButtonMarker")
            local textLabel = v:FindFirstChild("ButtonText")
            if marker and textLabel then
                local active = espEnabled
                if active and not unlimited and hrp then
                    local dist = (v.Position - hrp.Position).Magnitude
                    active = dist <= espRange
                end
                marker.Enabled = active
                textLabel.Enabled = active
            end
        end
    end
end

local function setAllESP(state)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local marker = v:FindFirstChild("ButtonMarker")
            local textLabel = v:FindFirstChild("ButtonText")
            if marker then marker.Enabled = state end
            if textLabel then textLabel.Enabled = state end
        end
    end
end

for _, v in pairs(workspace:GetDescendants()) do
    if v:IsA("BasePart") then addTrueButtonMarker(v) end
end
workspace.DescendantAdded:Connect(function(v)
    task.wait(0.1)
    if v:IsA("BasePart") then addTrueButtonMarker(v) end
end)

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    humanoid.WalkSpeed = moveSpeed
    if noClipEnabled then
        for _, p in ipairs(character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if espEnabled then updateESP() end
end)

local function teleportNearestButton()
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
    local nearest = nil
    local minDist = math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v:FindFirstChildOfClass("ClickDetector") then
            if noRepeatTeleport and visitedButtons[v] then
            else
                local dist = (v.Position - hrp.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = v
                end
            end
        end
    end
    if nearest then
        hrp.CFrame = CFrame.new(nearest.Position + Vector3.new(0, 3, 0))
        visitedButtons[nearest] = true
        Library:Notify("已传送到最近按钮", 2)
    else
        Library:Notify("附近没有按钮或所有按钮已访问", 3)
    end
end

local function getWebContent(url)
    return game:HttpGet(url)
end

local function runLuaCode(code)
    loadstring(code)()
end

local function cleanup()
    for _, conn in ipairs(jumpConnections) do
        conn:Disconnect()
    end
    jumpConnections = {}
    infiniteJumpEnabled = false
    noClipEnabled = false
    moveSpeed = 16
    if humanoid then humanoid.WalkSpeed = 16 end
    setAllESP(false)
    espEnabled = false
end

local Window = Library:CreateWindow({
    Title = "找到按钮",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify("找到按钮脚本 - 创作者：Aiove", 5)

local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Main = Window:AddTab("功能", "info"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel('Aiove将持续更新此脚本')
NoticeGroup:AddLabel('创作者：Aiove')

local FuncGroup = Tabs.Main:AddLeftGroupbox("按钮工具")
FuncGroup:AddToggle('ButtonESPToggle', {
    Text = '开启按钮透视',
    Default = false,
    Tooltip = '高亮并标注所有可点击按钮',
    Callback = function(Value)
        espEnabled = Value
        if not Value then setAllESP(false) end
    end
})

FuncGroup:AddSlider('ESPRange', {
    Text = '透视范围（拉满=全图）',
    Default = 1000,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Suffix = " m",
    Callback = function(Value)
        espRange = Value
    end
})

FuncGroup:AddButton({ Text = '传送最近按钮', Func = function()
    teleportNearestButton()
end })

FuncGroup:AddToggle('NoRepeatTeleport', {
    Text = '不再传送到传送过的按钮',
    Default = false,
    Tooltip = '开启后，已传送过的按钮将被忽略',
    Callback = function(Value)
        noRepeatTeleport = Value
        if not Value then
            table.clear(visitedButtons)
        end
    end
})

FuncGroup:AddButton({ Text = '召唤飞行脚本', Func = function()
    local success, err = pcall(function()
        local targetUrl = "https://pastebin.com/raw/dZNN3GhY"
        local codeContent = getWebContent(targetUrl)
        runLuaCode(codeContent)
    end)
    if not success then
        Library:Notify("加载飞行脚本失败", 3)
    else
        Library:Notify("飞行脚本已执行", 3)
    end
end })

local BoostGroup = Tabs.Main:AddRightGroupbox("角色增强")
BoostGroup:AddSlider('WalkSpeedSlider', {
    Text = '移动速度',
    Default = 16,
    Min = 0,
    Max = 200,
    Rounding = 0,
    Suffix = "",
    Callback = function(Value)
        moveSpeed = Value
        if humanoid then humanoid.WalkSpeed = Value end
    end
})

BoostGroup:AddToggle('InfiniteJumpToggle', {
    Text = '无限跳跃',
    Default = false,
    Tooltip = '按住空格可连续跳跃',
    Callback = function(Value)
        infiniteJumpEnabled = Value
        if Value then
            for _, conn in ipairs(jumpConnections) do
                conn:Disconnect()
            end
            jumpConnections = {}
            local conn1 = UIS.InputBegan:Connect(function(input, processed)
                if processed then return end
                if input.KeyCode == Enum.KeyCode.Space then
                    jumpRequest = true
                end
            end)
            local conn2 = UIS.InputEnded:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.Space then
                    jumpRequest = false
                end
            end)
            local conn3 = RunService.RenderStepped:Connect(function()
                if not infiniteJumpEnabled then return end
                if not humanoid or not character then return end
                if jumpRequest and humanoid:GetState() == Enum.HumanoidStateType.Landed then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
            table.insert(jumpConnections, conn1)
            table.insert(jumpConnections, conn2)
            table.insert(jumpConnections, conn3)
        else
            for _, conn in ipairs(jumpConnections) do
                conn:Disconnect()
            end
            jumpConnections = {}
        end
    end
})

BoostGroup:AddToggle('NoClipToggle', {
    Text = '穿墙',
    Default = false,
    Tooltip = '角色可穿越墙体，脚下保留站立',
    Callback = function(Value)
        noClipEnabled = Value
        local char = player.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    if p.Name == "HumanoidRootPart" then
                        p.CanCollide = true
                    else
                        p.CanCollide = not Value
                    end
                end
            end
        end
    end
})

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
