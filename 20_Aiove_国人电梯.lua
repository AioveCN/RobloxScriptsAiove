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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local Window = Library:CreateWindow({
    Title = "国人电梯",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify({
    Title = "国人电梯",
    Description = "创作者：Aiove\nQQ：3999698324\n脚本已加载成功",
    Time = 5,
})

local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Main = Window:AddTab("主要", "info"),
    Map = Window:AddTab("地图", "info"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel("Aiove将持续更新此脚本")
NoticeGroup:AddLabel("创作者：Aiove")
NoticeGroup:AddLabel("QQ：3999698324")
NoticeGroup:AddLabel("感谢Rob的源码")

local MainGroup = Tabs.Main:AddLeftGroupbox("主要功能")
local MapGroup = Tabs.Map:AddLeftGroupbox("地图功能")

local autoTotem = false
MainGroup:AddToggle("AutoTotem", {
    Text = "自动装备图腾（背包内要有图腾）",
    Default = false,
    Callback = function(state)
        autoTotem = state
    end,
})

task.spawn(function()
    local toolName = "\228\184\141\230\173\187\229\155\190\232\133\190"
    while task.wait(0.01) do
        if autoTotem then
            local character = player.Character
            local backpack = player.Backpack
            if character and backpack then
                local tool = backpack:FindFirstChild(toolName)
                if tool and not character:FindFirstChild(toolName) then
                    tool.Parent = character
                end
            end
        end
    end
end)

local autoTeleportOnDeath = false
MainGroup:AddToggle("AutoTeleportOnDeath", {
    Text = "人物死亡自动传送回电梯",
    Default = false,
    Callback = function(state)
        autoTeleportOnDeath = state
    end,
})

local function handleCharacter(char)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        if not autoTeleportOnDeath then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(12.945096015930176, 5.054622173309326, -28.848831176757812)
        end
    end)
end
if player.Character then
    task.spawn(function() handleCharacter(player.Character) end)
end
player.CharacterAdded:Connect(handleCharacter)

MainGroup:AddButton("切换人物到r6体型", function()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local origin = hrp.CFrame
    hrp.CFrame = CFrame.new(3082.07958984375, 4.6649861335754395, 8.089847564697266)
    task.wait(0.01)
    hrp.CFrame = origin
end)

local function buyItem(remoteName)
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    local originalCF = hrp.CFrame
    hrp.CFrame = CFrame.new(3072.651123046875, 5.3547682762146, -22.37465476989746)
    task.wait(0.01)
    pcall(function()
        ReplicatedStorage.RemoteEvents[remoteName]:FireServer()
    end)
    task.wait(0.01)
    hrp.CFrame = originalCF
end

MainGroup:AddButton("购买一次音响", function()
    buyItem("SendItem")
end)

MainGroup:AddButton("买冰红茶", function()
    buyItem("SendItem2")
end)

MainGroup:AddButton("买玩具剑", function()
    buyItem("SendItem3")
end)

MainGroup:AddButton("买喷漆", function()
    buyItem("SendItem4")
end)

MainGroup:AddButton("买不死图腾", function()
    buyItem("SendItem5")
end)

MainGroup:AddButton("买旱厕里的蜗牛", function()
    buyItem("SendItem6")
end)

local collecting = false
MapGroup:AddToggle("CollectCoins", {
    Text = "捡金币",
    Default = false,
    Callback = function(state)
        collecting = state
    end,
})

task.spawn(function()
    local function getAllCoinParts()
        local parts = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:lower():find("coin") then
                table.insert(parts, obj)
            elseif obj:IsA("Model") and obj.Name:lower():find("coin") then
                local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if p then table.insert(parts, p) end
            end
        end
        return parts
    end
    while true do
        if collecting then
            local character = player.Character or player.CharacterAdded:Wait()
            local root = character:WaitForChild("HumanoidRootPart")
            local originCFrame = root.CFrame
            local coins = getAllCoinParts()
            for _, coin in ipairs(coins) do
                if collecting and coin and coin.Parent then
                    root.CFrame = CFrame.new(coin.Position)
                    task.wait()
                    root.CFrame = originCFrame
                end
            end
        end
        task.wait(0.01)
    end
end)

MapGroup:AddButton("传送奖杯", function()
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")
    local originalCFrame = root.CFrame
    local cup = workspace:FindFirstChild("Obby") and workspace.Obby:FindFirstChild("cup")
    if cup then
        if cup:IsA("BasePart") then
            root.CFrame = CFrame.new(cup.Position)
        else
            local part = cup:FindFirstChildWhichIsA("BasePart")
            if part then
                root.CFrame = CFrame.new(part.Position)
            end
        end
    end
    task.wait(0.1)
    root.CFrame = originalCFrame
end)

MapGroup:AddButton("海水上升地图传送到终点", function()
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")
    local originalCFrame = root.CFrame
    root.CFrame = CFrame.new(-2646.785888671875, 73.14339447021484, -1759.81982421875)
    task.wait(0.1)
    root.CFrame = originalCFrame
end)

MapGroup:AddButton("dream地图传送到安全区域", function()
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")
    local originalCFrame = root.CFrame
    root.CFrame = CFrame.new(346.2715759277344, -111.97982025146484, -1822.632568359375)
    task.wait(0.1)
    root.CFrame = originalCFrame
end)

MapGroup:AddButton("城门地图传送到诸葛亮头顶", function()
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")
    local originalCFrame = root.CFrame
    root.CFrame = CFrame.new(-85.7026596069336, 23.417531967163086, -23.862272262573242)
    task.wait(0.1)
    root.CFrame = originalCFrame
end)

local killAllActive = false
local killAllOrigin = nil

MapGroup:AddToggle("CFKillAll", {
    Text = "CF地图杀光所有人",
    Default = false,
    Callback = function(state)
        killAllActive = state
        if state then
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            killAllOrigin = hrp.CFrame
            local backpack = player.Backpack
            local tool = backpack:FindFirstChild("M200")
            if tool then
                tool.Parent = char
            end
        end
    end,
})

task.spawn(function()
    local function equipM200()
        if not killAllActive then return end
        local char = player.Character
        if not char then return end
        if char:FindFirstChild("M200") then return end
        local backpack = player:FindFirstChild("Backpack")
        if not backpack then return end
        local tool = backpack:FindFirstChild("M200")
        if tool then
            tool.Parent = char
        end
    end

    player.CharacterAdded:Connect(function(char)
        task.wait(0.3)
        equipM200()
    end)

    local function getFire()
        local char = player.Character
        if char then
            local tool = char:FindFirstChild("M200")
            if tool then
                return tool:FindFirstChild("Fire")
            end
        end
        return nil
    end

    while true do
        if killAllActive then
            equipM200()
            local event = getFire()
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if event and root then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if not killAllActive then break end
                    if plr ~= player then
                        local pchar = plr.Character
                        local proot = pchar and pchar:FindFirstChild("HumanoidRootPart")
                        if proot then
                            root.CFrame = CFrame.new(proot.Position + Vector3.new(0, 0, 3))
                            task.wait(0.05)
                            event:FireServer(root.Position, proot.Position)
                            task.wait(0.05)
                        end
                    end
                end
            end
        elseif killAllOrigin then
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = killAllOrigin
            end
            killAllOrigin = nil
        end
        task.wait(0.1)
    end
end)

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
