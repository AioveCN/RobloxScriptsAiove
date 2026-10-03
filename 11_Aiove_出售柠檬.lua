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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local Window = Library:CreateWindow({
    Title = "出售柠檬",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify({
    Title = "出售柠檬",
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

local AutoGroup = Tabs.Main:AddLeftGroupbox("自动功能")

local connections = {}

AutoGroup:AddToggle("AutoUpgradeLemonDash", {
    Text = "自动升级LemonDash",
    Default = false,
    Callback = function(Value)
        if connections.AutoUpgradeLemonDash then
            pcall(function() coroutine.close(connections.AutoUpgradeLemonDash) end)
            connections.AutoUpgradeLemonDash = nil
        end
        if Value then
            connections.AutoUpgradeLemonDash = task.spawn(function()
                while Toggles.AutoUpgradeLemonDash.Value do
                    local args = {[1] = 1}
                    pcall(function()
                        workspace.Tycoon8.Purchases.LemonDash.LemonDash.LemonDash.Upgrade:InvokeServer(unpack(args))
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end
})

AutoGroup:AddToggle("AutoUpgradeLemonRobotics", {
    Text = "自动升级LemonRobotics",
    Default = false,
    Callback = function(Value)
        if connections.AutoUpgradeLemonRobotics then
            pcall(function() coroutine.close(connections.AutoUpgradeLemonRobotics) end)
            connections.AutoUpgradeLemonRobotics = nil
        end
        if Value then
            connections.AutoUpgradeLemonRobotics = task.spawn(function()
                while Toggles.AutoUpgradeLemonRobotics.Value do
                    local args = {[1] = 1}
                    pcall(function()
                        workspace.Tycoon8.Purchases:FindFirstChild("Lemon Robotics"):FindFirstChild("Lemon Robotics"):FindFirstChild("Lemon Robotics").Upgrade:InvokeServer(unpack(args))
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end
})

AutoGroup:AddToggle("AutoUpgradeLemonRepublic", {
    Text = "自动升级LemonRepublic",
    Default = false,
    Callback = function(Value)
        if connections.AutoUpgradeLemonRepublic then
            pcall(function() coroutine.close(connections.AutoUpgradeLemonRepublic) end)
            connections.AutoUpgradeLemonRepublic = nil
        end
        if Value then
            connections.AutoUpgradeLemonRepublic = task.spawn(function()
                while Toggles.AutoUpgradeLemonRepublic.Value do
                    local args = {[1] = 1}
                    pcall(function()
                        workspace.Tycoon8.Purchases:FindFirstChild("Lemon Republic"):FindFirstChild("Lemon Republic"):FindFirstChild("Lemon Republic").Upgrade:InvokeServer(unpack(args))
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end
})

AutoGroup:AddToggle("AutoBuyHill", {
    Text = "自动购买山丘",
    Default = false,
    Callback = function(Value)
        if connections.AutoBuyHill then
            pcall(function() coroutine.close(connections.AutoBuyHill) end)
            connections.AutoBuyHill = nil
        end
        if Value then
            connections.AutoBuyHill = task.spawn(function()
                while Toggles.AutoBuyHill.Value do
                    pcall(function()
                        workspace.Tycoon8.Purchases.Hills.Buttons:FindFirstChild("Hill 1").Purchase:InvokeServer()
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end
})

AutoGroup:AddToggle("AutoBuyCashRegister", {
    Text = "自动购买收银机",
    Default = false,
    Callback = function(Value)
        if connections.AutoBuyCashRegister then
            pcall(function() coroutine.close(connections.AutoBuyCashRegister) end)
            connections.AutoBuyCashRegister = nil
        end
        if Value then
            connections.AutoBuyCashRegister = task.spawn(function()
                while Toggles.AutoBuyCashRegister.Value do
                    pcall(function()
                        workspace.Tycoon8.Purchases:FindFirstChild("Lemon Stand").Buttons.Other:FindFirstChild("Cash Register").Purchase:InvokeServer()
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end
})

AutoGroup:AddToggle("AutoBuyJuicer", {
    Text = "自动购买榨汁机",
    Default = false,
    Callback = function(Value)
        if connections.AutoBuyJuicer then
            pcall(function() coroutine.close(connections.AutoBuyJuicer) end)
            connections.AutoBuyJuicer = nil
        end
        if Value then
            connections.AutoBuyJuicer = task.spawn(function()
                while Toggles.AutoBuyJuicer.Value do
                    pcall(function()
                        workspace.Tycoon8.Purchases:FindFirstChild("Lemon Stand").Buttons.Multiplier.Juicer.Purchase:InvokeServer()
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end
})

AutoGroup:AddToggle("AutoSellLemon", {
    Text = "自动出售柠檬",
    Default = false,
    Callback = function(Value)
        if connections.AutoSellLemon then
            pcall(function() coroutine.close(connections.AutoSellLemon) end)
            connections.AutoSellLemon = nil
        end
        if Value then
            connections.AutoSellLemon = task.spawn(function()
                while Toggles.AutoSellLemon.Value do
                    local args = {[1] = "LemonStand"}
                    pcall(function()
                        workspace.Tycoon8.Remotes.WakeIncomeStream:InvokeServer(unpack(args))
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end
})

AutoGroup:AddToggle("AutoPickLemon", {
    Text = "自动摘柠檬",
    Default = false,
    Callback = function(Value)
        if connections.AutoPickLemon then
            pcall(function() coroutine.close(connections.AutoPickLemon) end)
            connections.AutoPickLemon = nil
        end
        if Value then
            connections.AutoPickLemon = task.spawn(function()
                local fruitBlacklist = {}

                while Toggles.AutoPickLemon.Value do
                    local allFruits = {}

                    for _, tycoon in pairs(workspace:GetChildren()) do
                        if tycoon.Name:match("Tycoon") then
                            local constant = tycoon:FindFirstChild("Constant")
                            if constant then
                                local trees = constant:FindFirstChild("Trees")
                                if trees then
                                    for _, tree in pairs(trees:GetChildren()) do
                                        if tree.Name == "LemonTree" then
                                            local fruitFolder = tree:FindFirstChild("Fruit")
                                            if fruitFolder then
                                                for _, fruit in pairs(fruitFolder:GetChildren()) do
                                                    if not table.find(fruitBlacklist, fruit) then
                                                        table.insert(allFruits, fruit)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end

                    if #allFruits == 0 then
                        fruitBlacklist = {}
                        task.wait(1)
                        continue
                    end

                    local nearestFruit = nil
                    local nearestDist = math.huge
                    for _, fruit in pairs(allFruits) do
                        local fruitPos = fruit:GetPivot().Position
                        local dist = (fruitPos - hrp.Position).Magnitude
                        if dist < nearestDist then
                            nearestDist = dist
                            nearestFruit = fruit
                        end
                    end

                    if not nearestFruit then
                        fruitBlacklist = {}
                        task.wait(1)
                        continue
                    end

                    table.insert(fruitBlacklist, nearestFruit)

                    local fruitPos = nearestFruit:GetPivot().Position
                    hrp.CFrame = CFrame.new(fruitPos - Vector3.new(0, 2, 0))
                    task.wait(0.3)

                    local args = {
                        [1] = character,
                        [2] = fruitPos
                    }
                    pcall(function()
                        ReplicatedStorage.Core.CharacterIK.UpdateLook:FireServer(unpack(args))
                    end)
                    task.wait(0.2)

                    local clickDetector = nearestFruit:FindFirstChild("ClickFruitPart", true)
                    if not clickDetector then
                        clickDetector = nearestFruit:FindFirstChild("ClickDetector", true)
                    end

                    if clickDetector then
                        local startTime = tick()
                        while nearestFruit.Parent and tick() - startTime < 3 and Toggles.AutoPickLemon.Value do
                            pcall(function()
                                if clickDetector:IsA("ClickDetector") then
                                    fireclickdetector(clickDetector)
                                elseif clickDetector:IsA("Part") and clickDetector:FindFirstChild("ClickDetector") then
                                    fireclickdetector(clickDetector.ClickDetector)
                                end
                            end)

                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                            task.wait(0.05)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                            task.wait(0.05)

                            local fruitScreenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(fruitPos)
                            if onScreen then
                                VirtualInputManager:SendMouseButtonEvent(fruitScreenPos.X, fruitScreenPos.Y, 0, true, game, 0)
                                task.wait(0.05)
                                VirtualInputManager:SendMouseButtonEvent(fruitScreenPos.X, fruitScreenPos.Y, 0, false, game, 0)
                                task.wait(0.05)
                            end
                        end
                    end

                    task.wait(0.3)
                end
            end)
        end
    end
})

local UnloadGroup = Tabs.Settings:AddLeftGroupbox("脚本管理")
UnloadGroup:AddButton("卸载脚本", function()
    for _, conn in pairs(connections) do
        if typeof(conn) == "thread" then
            pcall(function() coroutine.close(conn) end)
        end
    end
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
