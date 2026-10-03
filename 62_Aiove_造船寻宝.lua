-- This file has been deobfuscated Luraph using Hurricane https://discord.com/invite/AbeurBzKXe
local function safeLoad(url)
    local success, result = pcall(function() return loadstring(game:HttpGet(url))() end)
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
local localPlayer = Players.LocalPlayer
local goldBlockVal = localPlayer:WaitForChild("Data"):WaitForChild("GoldBlock")
local goldVal = localPlayer.Data:WaitForChild("Gold")
local claimRiverResultsGoldEvent = workspace:WaitForChild("ClaimRiverResultsGold")
local stagePositions = {}
local chestTrigger, chestTriggerOriginCFrame
local roundCount = 0

for _, stage in workspace:WaitForChild("BoatStages"):WaitForChild("NormalStages"):GetChildren() do
    local index = tonumber(stage.Name:match("%d+"))
    if index then stagePositions[index] = stage.DarknessPart.CFrame end
    if stage.Name == "TheEnd" then
        chestTrigger = stage.GoldenChest.Trigger
        chestTriggerOriginCFrame = chestTrigger.CFrame
    end
end

local goldFarming = false
local candyFarming = false
local connections = {}
local statusOverlay

local Window = Library:CreateWindow({
    Title = "造船寻宝",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify({
    Title = "造船寻宝",
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

local MainLeft = Tabs.Main:AddLeftGroupbox("功能")
local MainRight = Tabs.Main:AddRightGroupbox("统计")

local statsLabel = MainRight:AddLabel("已刷总轮数: 0")
local goldLabel = MainRight:AddLabel("当前金币: 加载中...")
local goldBlockLabel = MainRight:AddLabel("当前金块: 加载中...")

MainRight:AddButton("重置轮数", function()
    roundCount = 0
    statsLabel:SetText("已刷总轮数: 0")
    Library:Notify({ Title = "统计", Text = "轮数已清零", Duration = 2 })
end)

local function updateOverlay(text)
    if not statusOverlay then
        statusOverlay = Drawing.new("Text")
        statusOverlay.Outline = true
        statusOverlay.Color = Color3.new(1, 1, 1)
        statusOverlay.Position = Vector2.new(20, 40)
        statusOverlay.Size = 18
        statusOverlay.Visible = true
    end
    statusOverlay.Text = text
end

MainLeft:AddToggle("自动农场", {
    Text = "自动农场",
    Default = false,
    Callback = function(enabled)
        goldFarming = enabled
        if not enabled then
            for _, c in pairs(connections) do c:Disconnect() end
            if statusOverlay then statusOverlay.Visible = false end
            return
        end

        local startTime = time()
        if statusOverlay then statusOverlay.Visible = true end

        table.insert(connections, RunService.Heartbeat:Connect(function()
            local char = localPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end

            if _G.AtEnd then
                pcall(firetouchinterest, chestTrigger, root, 0)
            end

            root.CFrame = _G.TargetPos or stagePositions[1]
            root.Velocity = Vector3.zero

            updateOverlay("造船寻宝 挂机中...\n已运行: " .. math.floor(time() - startTime) .. "s\n已完成: " .. roundCount .. " 轮")
            statsLabel:SetText("已刷总轮数: " .. roundCount)
            goldLabel:SetText("当前金币: " .. goldVal.Value)
            goldBlockLabel:SetText("当前金块: " .. goldBlockVal.Value)
        end))

        table.insert(connections, localPlayer.CharacterRemoving:Connect(function()
            roundCount = roundCount + 1
            _G.AtEnd = false
            claimRiverResultsGoldEvent:FireServer()
        end))

        task.spawn(function()
            while goldFarming do
                for i = 1, 9 do
                    if not goldFarming then break end
                    _G.TargetPos = stagePositions[i]
                    task.wait(2)
                end
                _G.AtEnd = true
                task.wait(3)
                while _G.AtEnd and goldFarming do task.wait() end
            end
        end)
    end
})

MainLeft:AddToggle("自动刷糖果", {
    Text = "自动刷糖果",
    Default = false,
    Callback = function(enabled)
        candyFarming = enabled
        if enabled then
            task.spawn(function()
                while candyFarming do
                    task.wait(0.1)
                    local char = localPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root and workspace:FindFirstChild("Houses") then
                        for _, house in pairs(workspace.Houses:GetChildren()) do
                            local door = house:FindFirstChild("Door") and house.Door:FindFirstChild("DoorInnerTouch")
                            if door then
                                pcall(firetouchinterest, root, door, 0)
                            end
                        end
                    end
                end
            end)
            Library:Notify({ Title = "功能开启", Text = "开始自动收集全图糖果", Duration = 3 })
        end
    end
})

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
