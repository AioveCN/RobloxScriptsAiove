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

local Window = Library:CreateWindow({
    Title = "中国人能飞",
    Footer = "不知道，不知道，不知道",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify({
    Title = "中国人能飞",
    Description = "不知道，不知道，不知道\n不知道\n脚本已加载成功",
    Time = 5,
})

local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Main = Window:AddTab("主要", "info"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel('不知道，不知道，不知道')
NoticeGroup:AddLabel('不知道，不知道，不知道')

local MainLeft = Tabs.Main:AddLeftGroupbox("自动功能")

local autoFarmRunning = false
local autoFarmThread = nil
local espRunning = false
local espConnection = nil
local espHeartbeat = nil

local function getCoinsFolder()
    local world = workspace:FindFirstChild("World")
    return world and world:FindFirstChild("Coins")
end

local function getMapBounds()
    local map = workspace:FindFirstChild("Map City")
    if map then
        local ok, cf, size = pcall(function()
            return map:GetBoundingBox()
        end)
        if ok and cf then
            local p = cf.Position
            local h = size / 2
            return {minX = p.X - h.X, maxX = p.X + h.X, minZ = p.Z - h.Z, maxZ = p.Z + h.Z}
        end
    end
    local ok, cf, size = pcall(function()
        return workspace:GetBoundingBox()
    end)
    if ok and cf then
        local p = cf.Position
        local h = size / 2
        return {minX = p.X - h.X, maxX = p.X + h.X, minZ = p.Z - h.Z, maxZ = p.Z + h.Z}
    end
    return nil
end

local function getGridPoints(bounds, step)
    local pts = {}
    for x = bounds.minX, bounds.maxX, step do
        for z = bounds.minZ, bounds.maxZ, step do
            table.insert(pts, Vector3.new(x, 80, z))
        end
    end
    return pts
end

local function startAutoFarm()
    if autoFarmRunning then return end
    autoFarmRunning = true
    autoFarmThread = task.spawn(function()
        local bounds = getMapBounds()
        if not bounds then
            autoFarmRunning = false
            return
        end
        local pts = getGridPoints(bounds, 120)
        if #pts == 0 then
            autoFarmRunning = false
            return
        end
        local idx = 1
        local visited = {}
        setmetatable(visited, {__mode = "k"})

        while autoFarmRunning do
            local char = localPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local pt = pts[idx]
                if not pt then
                    idx = 1
                    pt = pts[1]
                    table.clear(visited)
                end
                if pt then
                    pcall(function()
                        hrp.CFrame = CFrame.new(pt)
                    end)
                end
                task.wait(0.15)

                local folder = getCoinsFolder()
                if folder then
                    local pos = hrp.Position
                    local coins = {}
                    for _, obj in ipairs(folder:GetChildren()) do
                        if obj:IsA("BasePart") and obj.Name == "Coin" and not visited[obj] then
                            if (obj.Position - pos).Magnitude <= 250 then
                                table.insert(coins, obj)
                            end
                        end
                    end

                    for _, coin in ipairs(coins) do
                        if not autoFarmRunning then break end
                        if coin and coin.Parent then
                            pcall(function()
                                hrp.CFrame = CFrame.new(coin.Position + Vector3.new(0, 1, 0))
                            end)
                            visited[coin] = true
                            pcall(function()
                                firetouchinterest(hrp, coin, 0)
                                firetouchinterest(hrp, coin, 1)
                            end)
                            task.wait(0.03)
                        end
                    end
                end

                idx = idx + 1
            else
                task.wait(0.3)
            end
        end
        autoFarmThread = nil
    end)
end

local function stopAutoFarm()
    autoFarmRunning = false
end

local function tagCoin(coin)
    if not coin:FindFirstChildOfClass("Highlight") then
        local hl = Instance.new("Highlight")
        hl.Name = "CoinESP"
        hl.FillColor = Color3.fromRGB(255, 215, 0)
        hl.OutlineColor = Color3.fromRGB(255, 140, 0)
        hl.FillTransparency = 0.3
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = coin
    end
    if not coin:FindFirstChild("CoinLabel") then
        local bg = Instance.new("BillboardGui")
        bg.Name = "CoinLabel"
        bg.Size = UDim2.new(0, 80, 0, 30)
        bg.StudsOffset = Vector3.new(0, 2, 0)
        bg.AlwaysOnTop = true
        bg.MaxDistance = 5000
        local tl = Instance.new("TextLabel")
        tl.Size = UDim2.new(1, 0, 1, 0)
        tl.BackgroundTransparency = 1
        tl.Text = "金币"
        tl.TextColor3 = Color3.fromRGB(255, 215, 0)
        tl.TextStrokeTransparency = 0
        tl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        tl.Font = Enum.Font.GothamBold
        tl.TextSize = 18
        tl.Parent = bg
        bg.Parent = coin
    end
end

local function scanAllCoins()
    local folder = getCoinsFolder()
    if not folder then return end
    for _, obj in ipairs(folder:GetChildren()) do
        if obj:IsA("BasePart") and obj.Name == "Coin" then
            tagCoin(obj)
        end
    end
end

local function startESP()
    if espRunning then return end
    espRunning = true
    scanAllCoins()
    local folder = getCoinsFolder()
    if folder then
        espConnection = folder.ChildAdded:Connect(function(child)
            if child:IsA("BasePart") and child.Name == "Coin" then
                tagCoin(child)
            end
        end)
    end
    espHeartbeat = RunService.Heartbeat:Connect(function()
        scanAllCoins()
    end)
end

local function stopESP()
    espRunning = false
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end
    if espHeartbeat then
        espHeartbeat:Disconnect()
        espHeartbeat = nil
    end
end

MainLeft:AddToggle("AutoFarm", {
    Text = "自动捡金币",
    Default = false,
    Tooltip = "开启后自动传送捡取金币",
    Callback = function(Value)
        if Value then
            startAutoFarm()
        else
            stopAutoFarm()
        end
    end
})

MainLeft:AddToggle("CoinESP", {
    Text = "金币透视",
    Default = false,
    Tooltip = "开启后透视显示金币位置",
    Callback = function(Value)
        if Value then
            startESP()
        else
            stopESP()
        end
    end
})

local UnloadGroup = Tabs.Settings:AddLeftGroupbox("脚本管理")
UnloadGroup:AddButton("卸载脚本", function()
    stopAutoFarm()
    stopESP()
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

