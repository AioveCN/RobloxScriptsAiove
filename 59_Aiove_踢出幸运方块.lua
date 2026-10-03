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

local get = cloneref or function(x) return x end
local players = get(game:GetService("Players"))
local lp = players.LocalPlayer
local rs = get(game:GetService("RunService"))
local vim = get(game:GetService("VirtualInputManager"))
local rep = get(game:GetService("ReplicatedStorage"))
local marketplace = get(game:GetService("MarketplaceService"))
local tweens = get(game:GetService("TweenService"))

local Handler
local success, err = pcall(function()
    Handler = require(rep.Modules.HandlerLoader.GameHandler)
end)
if not success then
    Handler = {}
    warn("Handler 加载失败: " .. tostring(err))
end

local Network
local success2, err2 = pcall(function()
    Network = rep["Shared"]["Packages"]["Network"]
end)
if not success2 then
    Network = {}
    warn("Network 获取失败: " .. tostring(err2))
end

local area
pcall(function()
    area = workspace:FindFirstChild("Areas") and workspace.Areas:FindFirstChild("KickReady")
end)

local waves
pcall(function()
    waves = workspace:FindFirstChild("Waves")
end)

local function _kick(strength)
    pcall(function()
        if Network and Network["rev_KickEvent"] then
            Network["rev_KickEvent"]:FireServer(strength or 1)
        end
    end)
end

local following
local noclipConnection

local function setNoClip(enabled)
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    if enabled then
        noclipConnection = rs.Stepped:Connect(function()
            local character = lp.Character
            if not character then return end
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        local character = lp.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end
end

local function getFinishArea()
    local finish = workspace:FindFirstChild("Areas") and workspace.Areas:FindFirstChild("Finish")
    if not finish then finish = workspace:FindFirstChild("Finish") end
    if not finish then finish = workspace:FindFirstChild("FinishLine") end
    if not finish then finish = workspace:FindFirstChild("End") end
    if not finish then finish = workspace:FindFirstChild("EndZone") end
    return finish
end

local function tryJump()
    local humanoid = lp.Character and lp.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

local function FollowWave_V1()
    if not waves then return end
    if following then following:Disconnect() end
    setNoClip(false)
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local jumpCount = 0
    local lastJumpTime = 0
    local lastWavePos = nil
    local stopFrames = 0

    following = rs.RenderStepped:Connect(function()
        if not Handler.Status or Handler.Status ~= "Tsunami" then
            if following then following:Disconnect(); following = nil end
            return
        end
        local wave = waves:FindFirstChildWhichIsA("Model") and waves:FindFirstChildWhichIsA("Model"):FindFirstChildWhichIsA("Part")
        if not wave then return end

        hrp.CFrame = CFrame.new(wave.Position + Vector3.new(400, 0, 0), wave.Position)

        if jumpCount < 2 then
            local shouldJump = false
            local finishArea = getFinishArea()
            if finishArea then
                if (hrp.Position - finishArea.Position).Magnitude < 60 then
                    shouldJump = true
                end
            else
                if lastWavePos then
                    local moved = (wave.Position - lastWavePos).Magnitude
                    if moved < 0.2 then
                        stopFrames = stopFrames + 1
                        if stopFrames >= 3 then
                            shouldJump = true
                        end
                    else
                        stopFrames = 0
                    end
                end
                lastWavePos = wave.Position
            end

            if shouldJump then
                local now = tick()
                if jumpCount == 0 or (now - lastJumpTime >= 0.25) then
                    tryJump()
                    jumpCount = jumpCount + 1
                    lastJumpTime = now
                end
            end
        end
    end)
end

local function FollowWave_V2()
    if not waves then return end
    if following then following:Disconnect() end
    setNoClip(false)
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local jumpCount = 0
    local lastJumpTime = 0
    local lastWavePos = nil
    local stopFrames = 0

    following = rs.RenderStepped:Connect(function()
        if not Handler.Status or Handler.Status ~= "Tsunami" then
            if following then following:Disconnect(); following = nil end
            return
        end
        local waveModel = waves:FindFirstChildWhichIsA("Model")
        if not waveModel then return end
        local wave = waveModel:FindFirstChildWhichIsA("Part")
        if not wave then return end
        local wavePos = wave.Position
        local targetPos = Vector3.new(wavePos.X + 400, 4, wavePos.Z)
        local smoothPos = hrp.Position:Lerp(targetPos, 0.08)
        hrp.CFrame = CFrame.new(smoothPos)
        hrp.Velocity = Vector3.new(0, 0, 0)

        if jumpCount < 2 then
            local shouldJump = false
            local finishArea = getFinishArea()
            if finishArea then
                if (hrp.Position - finishArea.Position).Magnitude < 60 then
                    shouldJump = true
                end
            else
                if lastWavePos then
                    local moved = (wavePos - lastWavePos).Magnitude
                    if moved < 0.2 then
                        stopFrames = stopFrames + 1
                        if stopFrames >= 3 then
                            shouldJump = true
                        end
                    else
                        stopFrames = 0
                    end
                end
                lastWavePos = wavePos
            end

            if shouldJump then
                local now = tick()
                if jumpCount == 0 or (now - lastJumpTime >= 0.25) then
                    tryJump()
                    jumpCount = jumpCount + 1
                    lastJumpTime = now
                end
            end
        end
    end)
end

local kupg = nil
local gui = lp:FindFirstChild("PlayerGui")
if gui then
    local success3, result = pcall(function()
        kupg = gui:WaitForChild("KickUpgrades", 10)
    end)
    if not success3 or not result then
        kupg = nil
        warn("KickUpgrades 未找到，奖励功能将禁用")
    end
end

local function find()
    if not kupg then return end
    for _, item in ipairs(kupg:GetChildren()) do
        if item:IsA("ImageButton") and item.Name == "Bonus" and item.Visible then
            local pos = item.AbsolutePosition + (item.AbsoluteSize / 2)
            vim:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
            vim:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
            break
        end
    end
end

local function claim()
    local plot
    for _, item in ipairs(workspace.Plots:GetChildren()) do
        if item:GetAttribute("Owner") == lp.Name then
            plot = item
            break
        end
    end
    if not plot then return end
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, slot in ipairs(plot.Buttons:GetChildren()) do
        firetouchinterest(hrp, slot, true)
        firetouchinterest(hrp, slot, false)
    end
end

local Options = Library.Options
local Window = Library:CreateWindow({
    Title = "踢出幸运方块",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})
Library:Notify("踢出幸运方块 - 创作者：Aiove", 5)

local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Main = Window:AddTab("主要", "info"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者信息")
NoticeGroup:AddLabel('踢出幸运方块')
NoticeGroup:AddLabel('Aiove 制作')

local SettingsGroup = Tabs.Settings:AddLeftGroupbox("菜单")
SettingsGroup:AddButton({
    Text = '卸载脚本',
    Func = function()
        Library:Unload()
    end
})
SettingsGroup:AddButton({
    Text = '重载界面',
    Func = function()
        Library:Notify("重载功能未配置脚本地址", 3)
    end
})
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

local KickGroup = Tabs.Main:AddLeftGroupbox("踢击")

KickGroup:AddButton({
    Text = '全力踢击',
    Func = function()
        _kick()
    end
})

local autoKick = false
KickGroup:AddToggle('AutoKick', {
    Text = '自动踢击',
    Default = false,
    Callback = function(v)
        autoKick = v
        if not v then return end
        spawn(function()
            while wait(0.4) and autoKick do
                if Handler.InGame then continue end
                local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end
                if area then
                    hrp.CFrame = area.CFrame
                end
                _kick(1)
            end
        end)
    end
})

local ExerciseGroup = Tabs.Main:AddLeftGroupbox("锻炼")

ExerciseGroup:AddButton({
    Text = '手动积攒锻炼奖励',
    Func = function()
        spawn(function()
            for i = 1, 50 do
                pcall(function()
                    if Network and Network["rev_TaviMishkal"] then
                        Network["rev_TaviMishkal"]:FireServer()
                    end
                end)
                task.wait(0.02)
            end
            Library:Notify("手动积攒锻炼奖励 执行完毕", 2)
        end)
    end
})

local autoTavi = false
ExerciseGroup:AddToggle('AutoTaviMishkal', {
    Text = '积攒锻炼奖励',
    Default = false,
    Callback = function(v)
        autoTavi = v
        if not v then return end
        spawn(function()
            while wait(0.05) and autoTavi do
                pcall(function()
                    if Network and Network["rev_TaviMishkal"] then
                        Network["rev_TaviMishkal"]:FireServer()
                    end
                end)
            end
        end)
    end
})

local SellGroup = Tabs.Main:AddRightGroupbox("出售")

SellGroup:AddButton({
    Text = '出售全部物品栏脑腐',
    Func = function()
        pcall(function()
            rep.Shared.Packages.Network.ref_B_SellAll:InvokeServer()
        end)
    end
})

local InteractGroup = Tabs.Main:AddRightGroupbox("交互")

InteractGroup:AddButton({
    Text = '拿下全部脑腐',
    Func = function()
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            Library:Notify("角色未准备好", 3)
            return
        end
        local count = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                pcall(function()
                    fireproximityprompt(obj)
                    count = count + 1
                end)
            end
        end
        Library:Notify("已交互 " .. tostring(count) .. " 个目标", 3)
    end
})

local WaveGroup = Tabs.Main:AddRightGroupbox("跑到终点")

local autoHomeV1 = false
local autoHomeV2 = false
local toggleV1, toggleV2

toggleV1 = WaveGroup:AddToggle('AutoHomeV1', {
    Text = '自动回家V1',
    Default = false,
    Callback = function(v)
        autoHomeV1 = v
        if v and toggleV2 then
            toggleV2:SetValue(false)
        end
        if v then
            if Handler.Status == "Tsunami" then
                FollowWave_V1()
            end
        else
            if following then following:Disconnect(); following = nil end
            setNoClip(false)
        end
    end
})

toggleV2 = WaveGroup:AddToggle('AutoHomeV2', {
    Text = '自动回家V2',
    Default = false,
    Callback = function(v)
        autoHomeV2 = v
        if v and toggleV1 then
            toggleV1:SetValue(false)
        end
        if v then
            if Handler.Status == "Tsunami" then
                FollowWave_V2()
            end
        else
            if following then following:Disconnect(); following = nil end
            setNoClip(false)
        end
    end
})

if Handler.StatusChanged then
    Handler.StatusChanged:Connect(function()
        if Handler.Status == "Tsunami" then
            if autoHomeV1 then
                FollowWave_V1()
            elseif autoHomeV2 then
                FollowWave_V2()
            end
        end
    end)
end

local BonusGroup = Tabs.Main:AddLeftGroupbox("奖励")
local WeightBonus
BonusGroup:AddToggle('AutoBonus', {
    Text = '自动领取重量奖励',
    Default = false,
    Callback = function(v)
        if v then
            if not WeightBonus and kupg then
                WeightBonus = kupg.DescendantAdded:Connect(find)
            end
            find()
        else
            if WeightBonus then
                WeightBonus:Disconnect()
                WeightBonus = nil
            end
        end
    end
})

local MiscGroup = Tabs.Main:AddRightGroupbox("杂项")

local autoJump = false
MiscGroup:AddToggle('AutoJump', {
    Text = '自动跳跃',
    Default = false,
    Callback = function(v)
        autoJump = v
        if not v then return end
        spawn(function()
            while wait(0.3) and autoJump do
                local humanoid = lp.Character and lp.Character:FindFirstChild("Humanoid")
                if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
})

MiscGroup:AddToggle('AutoRebirth', {
    Text = '自动转生',
    Default = false,
    Callback = function(v)
        spawn(function()
            while wait(6) do
                if not v then continue end
                if Network and Network["rev_RebirthRequest"] then
                    Network["rev_RebirthRequest"]:FireServer()
                end
            end
        end)
    end
})
MiscGroup:AddToggle('SpeedBoost', {
    Text = '移动加速',
    Default = false,
    Callback = function(v)
        local humanoid = lp.Character and lp.Character:FindFirstChild("Humanoid")
        if not humanoid then return end
        humanoid.WalkSpeed = v and humanoid.WalkSpeed * 2 or humanoid.WalkSpeed / 2
    end
})
MiscGroup:AddButton({
    Text = '手动领取金币',
    Func = claim
})
MiscGroup:AddToggle('AutoClaimGold', {
    Text = '自动领取金币',
    Default = false,
    Callback = function(v)
        spawn(function()
            while wait(6) do
                if not v then continue end
                claim()
            end
        end)
    end
})

local AntiAFKConnection
MiscGroup:AddToggle('AntiAFK', {
    Text = '防挂机踢出',
    Default = false,
    Callback = function(v)
        if v then
            if not AntiAFKConnection then
                local vu = get(game:GetService("VirtualUser"))
                AntiAFKConnection = lp.Idled:Connect(function()
                    vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                    wait(1)
                    vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                end)
            end
        else
            if AntiAFKConnection then
                AntiAFKConnection:Disconnect()
                AntiAFKConnection = nil
            end
        end
    end
})
