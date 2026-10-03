-- This file has been deobfuscated Luraph using Hurricane https://discord.com/invite/AbeurBzKXe
local function safeLoad(url)
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not ok then
        return nil, result
    end
    return result
end

local Library, libErr = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/黑曜石主库.ui")
if not Library then
    local plr = game:GetService("Players").LocalPlayer
    local sg = Instance.new("ScreenGui")
    sg.Name = "LoadError"
    sg.ResetOnSpawn = false
    pcall(function() sg.Parent = game:GetService("CoreGui") end)
    if not sg.Parent then sg.Parent = plr:WaitForChild("PlayerGui", 3) end
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 400, 0, 100)
    lbl.Position = UDim2.new(0.5, -200, 0.5, -50)
    lbl.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
    lbl.TextColor3 = Color3.fromRGB(255, 100, 100)
    lbl.TextSize = 16
    lbl.Font = Enum.Font.GothamBold
    lbl.TextWrapped = true
    lbl.Text = "UI库加载失败\n" .. tostring(libErr)
    lbl.Parent = sg
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local Window = Library:CreateWindow({
    Title = "变形升级",
    Footer = "Aiove 制作",
})

Library:Notify({
    Title = "变形升级",
    Description = "脚本已加载成功",
    Time = 5,
})

local Tabs = {
    Notice = Window:AddTab("通知", "rbxassetid://7733911621"),
    Main = Window:AddTab("主要", "rbxassetid://7733960981"),
    Settings = Window:AddTab("设置", "rbxassetid://7734053426"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel("Aiove将持续更新此脚本")
NoticeGroup:AddLabel("QQ：3676064581老板定制")
NoticeGroup:AddLabel("创作者：Aiove")

local function getChar()
    return player.Character
end

local function getHrp()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = getChar()
    return c and c:FindFirstChild("Humanoid")
end

local eating = false
local eatHb = nil
local eatCam = nil
local eatNoclip = nil

local function startNoclip()
    if eatNoclip then return end
    eatNoclip = RunService.Stepped:Connect(function()
        local c = getChar()
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                end
            end
        end
    end)
end

local function stopNoclip()
    if eatNoclip then
        eatNoclip:Disconnect()
        eatNoclip = nil
    end
    local c = getChar()
    if c then
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = true
            end
        end
    end
end

local function startTopView()
    if eatCam then return end
    local camera = workspace.CurrentCamera
    eatCam = RunService.RenderStepped:Connect(function()
        local h = getHrp()
        if h then
            camera.CFrame = CFrame.new(h.Position + Vector3.new(0, 80, 0), h.Position)
        end
    end)
end

local function stopTopView()
    if eatCam then
        eatCam:Disconnect()
        eatCam = nil
    end
end

local function getNearestBerry()
    local h = getHrp()
    if not h then return nil end
    local nearest = nil
    local minDist = math.huge
    local f = workspace:FindFirstChild("Berries")
    if f then
        for _, v in ipairs(f:GetDescendants()) do
            if v:IsA("BasePart") and v.Name == "Berry" and v.Parent then
                local dist = (v.Position - h.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = v
                end
            end
        end
    end
    return nearest
end

local function startEat()
    if eating then return end
    eating = true
    startNoclip()
    startTopView()
    local lastTarget = nil
    eatHb = RunService.Heartbeat:Connect(function()
        if not eating then return end
        local h = getHrp()
        local hm = getHum()
        if not h or not hm then return end
        local target = getNearestBerry()
        if not target then
            pcall(function() hm:MoveTo(h.Position) end)
            return
        end
        if target ~= lastTarget then
            pcall(function() hm:MoveTo(target.Position) end)
            lastTarget = target
        end
    end)
end

local function stopEat()
    if not eating then return end
    eating = false
    if eatHb then
        eatHb:Disconnect()
        eatHb = nil
    end
    local hm = getHum()
    if hm then
        local rp = hm.RootPart
        if rp then
            pcall(function() hm:MoveTo(rp.Position) end)
        end
    end
    stopNoclip()
    stopTopView()
end

local EatGroup = Tabs.Main:AddLeftGroupbox("自动吃经验球")
EatGroup:AddToggle("AutoEat", {
    Text = "自动吃经验球",
    Default = false,
    Callback = function(Value)
        if Value then
            startEat()
        else
            stopEat()
        end
    end,
})

local SpeedGroup = Tabs.Main:AddLeftGroupbox("移速修改")
SpeedGroup:AddSlider("WalkSpeed", {
    Text = "移速",
    Default = 16,
    Min = 16,
    Max = 150,
    Rounding = 0,
    Callback = function(Value)
        local hm = getHum()
        if hm then
            hm.WalkSpeed = Value
        end
    end,
})

local followTarget = nil
local followConn = nil
local followEnabled = false
local followDistance = 4
local followYOffset = -3

local LockGroup = Tabs.Main:AddRightGroupbox("锁定玩家")

local function getPlayerNames()
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            table.insert(names, plr.Name)
        end
    end
    return names
end

local playerNames = getPlayerNames()
if #playerNames == 0 then
    playerNames = {"暂无其他玩家"}
end

local targetDropdown = LockGroup:AddDropdown("TargetPlayer", {
    Text = "选择玩家",
    Values = playerNames,
    Callback = function(Value)
        followTarget = Players:FindFirstChild(Value)
    end,
})

LockGroup:AddButton("刷新玩家列表", function()
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            table.insert(names, plr.Name)
        end
    end
    if #names == 0 then
        names = {"暂无其他玩家"}
    end
    targetDropdown.Values = names
    targetDropdown:SetValue()
    Library:Notify({
        Title = "刷新成功",
        Description = "已更新玩家列表",
        Time = 3,
    })
end)

LockGroup:AddSlider("FollowDistance", {
    Text = "跟随距离",
    Default = 4,
    Min = 1,
    Max = 20,
    Rounding = 0,
    Callback = function(Value)
        followDistance = Value
    end,
})

LockGroup:AddSlider("FollowHeight", {
    Text = "陷地板高度",
    Default = -3,
    Min = -10,
    Max = 5,
    Rounding = 1,
    Callback = function(Value)
        followYOffset = Value
    end,
})

LockGroup:AddToggle("LockPlayer", {
    Text = "锁定这个人",
    Default = false,
    Callback = function(Value)
        followEnabled = Value
        if followConn then
            followConn:Disconnect()
            followConn = nil
        end
        if Value then
            local targetPlayer = followTarget
            if not targetPlayer then return end
            local name = targetPlayer.Name
            if name == "UchihaBan91Edition" or name == "Ooosleoekeird" then
                Library:Notify({
                    Title = "锁定失败",
                    Description = "他为定制者无法锁定",
                    Time = 5,
                })
                followEnabled = false
                return
            end
            followConn = RunService.Heartbeat:Connect(function()
                if not followEnabled then return end
                local selfHrp = getHrp()
                if not selfHrp then return end
                local tp = followTarget
                if not tp then return end
                local targetChar = tp.Character
                if not targetChar then return end
                local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
                if not targetHrp then return end
                local lookVector = targetHrp.CFrame.LookVector
                local behindPos = targetHrp.Position - (lookVector * followDistance)
                behindPos = Vector3.new(behindPos.X, targetHrp.Position.Y + followYOffset, behindPos.Z)
                selfHrp.CFrame = CFrame.new(behindPos, targetHrp.Position)
            end)
        end
    end,
})

task.delay(3, function()
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            table.insert(names, plr.Name)
        end
    end
    if #names > 0 then
        targetDropdown.Values = names
        targetDropdown:SetValue()
    end
end)

local UnloadGroup = Tabs.Settings:AddLeftGroupbox("脚本管理")
UnloadGroup:AddButton("卸载脚本", function()
    stopEat()
    if followConn then
        followConn:Disconnect()
        followConn = nil
    end
    Library:Unload()
end)

local ThemeManager = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/主题管理.ui")
local SaveManager = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/配置管理.ui")

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
