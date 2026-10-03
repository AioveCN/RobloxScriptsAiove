-- This file has been deobfuscated Luraph using Hurricane https://discord.com/invite/AbeurBzKXe
local function safeLoad(url)
    local success, result = pcall(function() return loadstring(game:HttpGet(url))() end)
    if not success then warn("加载失败: " .. url) return nil end
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
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

Library.AccentColor = Color3.fromRGB(0, 170, 255)
Library.MainColor = Color3.fromRGB(25, 25, 25)
Library.BackgroundColor = Color3.fromRGB(20, 20, 20)
Library.OutlineColor = Color3.fromRGB(40, 40, 40)

local Window = Library:CreateWindow({
    Title = "被遗弃",
    Footer = "创作者：Aiove",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify("被遗弃 - 创作者：Aiove", 5)

local Tabs = {
    Notice = Window:AddTab("公告", "info"),
    Main = Window:AddTab("功能", "info"),
    ESP = Window:AddTab("透视", "info"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者")
NoticeGroup:AddLabel('Aiove将持续更新此脚本')
NoticeGroup:AddLabel('创作者：Aiove')

local AutoGroup = Tabs.Main:AddLeftGroupbox("自动功能")

local lastAutoFix = 0
local lastAutoFixTP = 0
local autoFixConn = nil
AutoGroup:AddToggle('AutoFix', {
    Text = '自动修机',
    Default = false,
    Tooltip = '打开电机就自动修',
    Callback = function(Value)
        if Value then
            autoFixConn = RunService.Heartbeat:Connect(function()
                if tick() - lastAutoFix < 1.2 then return end
                lastAutoFix = tick()
                local map = Workspace:FindFirstChild("Map")
                if not map then return end
                local ingame = map:FindFirstChild("Ingame")
                if not ingame then return end
                local mapFolder = ingame:FindFirstChild("Map")
                if not mapFolder then return end
                for _, gen in pairs(mapFolder:GetChildren()) do
                    if gen.Name == "Generator" then
                        local remotes = gen:FindFirstChild("Remotes")
                        local re = remotes and remotes:FindFirstChild("RE")
                        if re then
                            pcall(function() re:FireServer() end)
                        end
                    end
                end
            end)
        else
            if autoFixConn then autoFixConn:Disconnect() autoFixConn = nil end
        end
    end
})

local autoFixTPConn = nil
AutoGroup:AddToggle('AutoFixTP', {
    Text = '自动修机2（传送）',
    Default = false,
    Tooltip = '传送到发电机修',
    Callback = function(Value)
        if Value then
            autoFixTPConn = RunService.Heartbeat:Connect(function()
                if tick() - lastAutoFixTP < 1.2 then return end
                lastAutoFixTP = tick()
                local char = player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local hrp = char.HumanoidRootPart
                local map = Workspace:FindFirstChild("Map")
                if not map then return end
                local ingame = map:FindFirstChild("Ingame")
                if not ingame then return end
                local mapFolder = ingame:FindFirstChild("Map")
                if not mapFolder then return end
                local nearest = nil
                local minDist = math.huge
                for _, gen in pairs(mapFolder:GetChildren()) do
                    if gen.Name == "Generator" and gen:FindFirstChild("Main") then
                        local dist = (gen.Main.Position - hrp.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            nearest = gen
                        end
                    end
                end
                if nearest and nearest:FindFirstChild("Main") then
                    hrp.CFrame = CFrame.new(nearest.Main.Position + Vector3.new(0, 3, 0))
                    local remotes = nearest:FindFirstChild("Remotes")
                    local re = remotes and remotes:FindFirstChild("RE")
                    if re then
                        pcall(function() re:FireServer() end)
                    end
                end
            end)
        else
            if autoFixTPConn then autoFixTPConn:Disconnect() autoFixTPConn = nil end
        end
    end
})

local blockConn = nil
local lastBlock = 0
AutoGroup:AddToggle('AutoBlock', {
    Text = '自动格挡',
    Default = false,
    Tooltip = '自动格挡杀手攻击',
    Callback = function(Value)
        if Value then
            local RemoteEvent = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")
            blockConn = RunService.Stepped:Connect(function()
                local killersFolder = Workspace:FindFirstChild("Players") and Workspace.Players:FindFirstChild("Killers")
                if not killersFolder then return end
                local char = player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local myPos = char.HumanoidRootPart.Position
                for _, killer in ipairs(killersFolder:GetChildren()) do
                    if killer:FindFirstChild("HumanoidRootPart") then
                        local dist = (killer.HumanoidRootPart.Position - myPos).Magnitude
                        if dist <= 15 then
                            if tick() - lastBlock >= 0.5 then
                                pcall(function() RemoteEvent:FireServer("UseActorAbility", "Block") end)
                                lastBlock = tick()
                            end
                        end
                    end
                end
            end)
        else
            if blockConn then blockConn:Disconnect() blockConn = nil end
        end
    end
})

local autoItemConn = nil
AutoGroup:AddToggle('AutoItem', {
    Text = '自动捡道具',
    Default = false,
    Tooltip = '自动传送并拾取医疗包和可乐',
    Callback = function(Value)
        if Value then
            autoItemConn = RunService.Heartbeat:Connect(function()
                local char = player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local hrp = char.HumanoidRootPart
                local map = Workspace:FindFirstChild("Map")
                if not map then return end
                local ingame = map:FindFirstChild("Ingame")
                if not ingame then return end
                local function pickup(name)
                    local item = ingame:FindFirstChild(name)
                    if item then
                        local itemRoot = item:FindFirstChild("ItemRoot")
                        if itemRoot then
                            itemRoot.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 3
                            local prompt = itemRoot:FindFirstChildOfClass("ProximityPrompt")
                            if prompt then
                                pcall(function() fireproximityprompt(prompt) end)
                            end
                        end
                    end
                end
                pickup("Medkit")
                pickup("BloxyCola")
            end)
        else
            if autoItemConn then autoItemConn:Disconnect() autoItemConn = nil end
        end
    end
})

local autoPizzaConn = nil
AutoGroup:AddToggle('AutoPizza', {
    Text = '自动吃披萨',
    Default = false,
    Tooltip = '生命值低于50时自动吃披萨',
    Callback = function(Value)
        if Value then
            autoPizzaConn = RunService.Heartbeat:Connect(function()
                local char = player.Character
                if not char or not char:FindFirstChild("Humanoid") or not char:FindFirstChild("HumanoidRootPart") then return end
                local humanoid = char.Humanoid
                if humanoid.Health >= 50 then return end
                local hrp = char.HumanoidRootPart
                local pizzaFolder = Workspace:FindFirstChild("Pizzas") or (Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Ingame"))
                if not pizzaFolder then return end
                local closest, minDist = nil, math.huge
                for _, pizza in ipairs(pizzaFolder:GetDescendants()) do
                    if pizza:IsA("BasePart") and pizza.Name == "Pizza" then
                        local dist = (pizza.Position - hrp.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            closest = pizza
                        end
                    end
                end
                if closest then
                    closest.CFrame = hrp.CFrame * CFrame.new(0, 0, -2)
                end
            end)
        else
            if autoPizzaConn then autoPizzaConn:Disconnect() autoPizzaConn = nil end
        end
    end
})

local BoostGroup = Tabs.Main:AddRightGroupbox("角色增强")

local staminaConn = nil
BoostGroup:AddToggle('InfiniteStamina', {
    Text = '无限体力',
    Default = false,
    Tooltip = '体力不会消耗',
    Callback = function(Value)
        local sprintingModule = ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Character"):WaitForChild("Game"):WaitForChild("Sprinting")
        local function getModule()
            local success, mod = pcall(function() return require(sprintingModule) end)
            if success then return mod end
            return nil
        end
        if Value then
            staminaConn = RunService.Heartbeat:Connect(function()
                local m = getModule()
                if m then
                    m.StaminaLoss = 0
                    m.StaminaGain = 9999
                end
            end)
        else
            if staminaConn then staminaConn:Disconnect() staminaConn = nil end
            local m = getModule()
            if m then
                m.StaminaLoss = 10
                m.StaminaGain = 25
            end
        end
    end
})


local jumpFloatGui, jumpFloatBtn, jumpPanel, jumpHeight = nil, nil, nil, 24
local jumpEnabled = false

local function createJumpFloat()
	if jumpFloatGui then jumpFloatGui:Destroy() end
	jumpFloatGui = Instance.new("ScreenGui", CoreGui)
	jumpFloatGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	jumpFloatBtn = Instance.new("TextButton", jumpFloatGui)
	jumpFloatBtn.Size = UDim2.new(0,60,0,60)
	jumpFloatBtn.Position = UDim2.new(1,-80,1,-80)
	jumpFloatBtn.BackgroundColor3 = Color3.new(0,0.5,1)
	jumpFloatBtn.Text = "↑"
	jumpFloatBtn.TextColor3 = Color3.new(1,1,1)
	jumpFloatBtn.TextSize = 40
	jumpFloatBtn.Font = Enum.Font.SourceSansBold
	Instance.new("UICorner", jumpFloatBtn).CornerRadius = UDim.new(1,0)
	local gearBtn = Instance.new("TextButton", jumpFloatGui)
	gearBtn.Size = UDim2.new(0,24,0,24)
	gearBtn.Position = UDim2.new(1,-86,1,-86)
	gearBtn.BackgroundColor3 = Color3.new(0.2,0.2,0.2)
	gearBtn.Text = "⚙"
	gearBtn.TextColor3 = Color3.new(1,1,1)
	gearBtn.TextSize = 18
	gearBtn.Font = Enum.Font.SourceSansBold
	Instance.new("UICorner", gearBtn).CornerRadius = UDim.new(1,0)
	jumpPanel = Instance.new("Frame", jumpFloatGui)
	jumpPanel.Size = UDim2.new(0,220,0,140)
	jumpPanel.Position = UDim2.new(1,-240,1,-160)
	jumpPanel.BackgroundColor3 = Color3.fromRGB(30,30,30)
	jumpPanel.Visible = false
	Instance.new("UICorner", jumpPanel).CornerRadius = UDim.new(0,8)
	local closeBtn = Instance.new("TextButton", jumpPanel)
	closeBtn.Size = UDim2.new(0,20,0,20)
	closeBtn.Position = UDim2.new(1,-25,0,5)
	closeBtn.BackgroundColor3 = Color3.new(0.8,0.2,0.2)
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.new(1,1,1)
	closeBtn.Font = Enum.Font.SourceSansBold
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1,0)
	closeBtn.MouseButton1Click:Connect(function() jumpPanel.Visible = false end)
	local heightLabel = Instance.new("TextLabel", jumpPanel)
	heightLabel.Size = UDim2.new(1,-30,0,30)
	heightLabel.Position = UDim2.new(0,10,0,5)
	heightLabel.BackgroundTransparency = 1
	heightLabel.Text = "跳跃高度：" .. jumpHeight
	heightLabel.TextColor3 = Color3.new(1,1,1)
	heightLabel.Font = Enum.Font.SourceSansBold
	local inputBox = Instance.new("TextBox", jumpPanel)
	inputBox.Size = UDim2.new(0.6,0,0,30)
	inputBox.Position = UDim2.new(0.2,0,0,50)
	inputBox.BackgroundColor3 = Color3.new(0.2,0.2,0.2)
	inputBox.Text = tostring(jumpHeight)
	inputBox.TextColor3 = Color3.new(1,1,1)
	inputBox.Font = Enum.Font.SourceSansBold
	Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0,6)
	local confirmBtn = Instance.new("TextButton", jumpPanel)
	confirmBtn.Size = UDim2.new(0.4,0,0,30)
	confirmBtn.Position = UDim2.new(0.1,0,0,90)
	confirmBtn.BackgroundColor3 = Color3.new(0,0.6,0)
	confirmBtn.Text = "确认"
	confirmBtn.TextColor3 = Color3.new(1,1,1)
	confirmBtn.Font = Enum.Font.SourceSansBold
	Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0,6)
	confirmBtn.MouseButton1Click:Connect(function()
		local num = tonumber(inputBox.Text)
		if num and num >= 16 and num <= 100 then
			jumpHeight = num
			heightLabel.Text = "跳跃高度：" .. jumpHeight
		end
	end)
	local resetBtn = Instance.new("TextButton", jumpPanel)
	resetBtn.Size = UDim2.new(0.4,0,0,30)
	resetBtn.Position = UDim2.new(0.5,0,0,90)
	resetBtn.BackgroundColor3 = Color3.new(0.8,0.4,0)
	resetBtn.Text = "默认"
	resetBtn.TextColor3 = Color3.new(1,1,1)
	resetBtn.Font = Enum.Font.SourceSansBold
	Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0,6)
	resetBtn.MouseButton1Click:Connect(function()
		jumpHeight = 24
		inputBox.Text = "24"
		heightLabel.Text = "跳跃高度：" .. jumpHeight
	end)
	gearBtn.MouseButton1Click:Connect(function() jumpPanel.Visible = not jumpPanel.Visible end)
	local function performJump()
		if not jumpEnabled then return end
		local char = player.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hrp and hum and hum.Health > 0 and hum.FloorMaterial ~= Enum.Material.Air then
			hrp.Velocity = Vector3.new(hrp.Velocity.X, jumpHeight, hrp.Velocity.Z)
		end
	end
	jumpFloatBtn.MouseButton1Click:Connect(performJump)
end

local function destroyJumpFloat()
	if jumpFloatGui then jumpFloatGui:Destroy() jumpFloatGui = nil jumpPanel = nil jumpFloatBtn = nil end
end

BoostGroup:AddToggle('JumpToggle', {
	Text = '显示跳跃按钮',
	Default = false,
	Tooltip = '在屏幕右下角显示跳跃按钮',
	Callback = function(Value)
		jumpEnabled = Value
		if Value then
			if not jumpFloatGui then createJumpFloat() end
		else
			destroyJumpFloat()
		end
	end
})

local ESPGroup = Tabs.ESP:AddLeftGroupbox("玩家透视")

local killerAddedConn = nil

local function addKillerESP(killer)
    if not killer:IsA("Model") then return end
    if killer:FindFirstChild("KillerESP_Highlight") then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "KillerESP_Highlight"
    highlight.FillColor = Color3.new(1, 0, 0)
    highlight.OutlineColor = Color3.new(1, 0, 0)
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0.1
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = killer
    local head = killer:FindFirstChild("Head")
    if head then
        local bill = Instance.new("BillboardGui")
        bill.Name = "KillerESP_Billboard"
        bill.Adornee = head
        bill.AlwaysOnTop = true
        bill.Size = UDim2.new(0, 40, 0, 15)
        bill.StudsOffset = Vector3.new(0, 2, 0)
        bill.MaxDistance = 99999
        bill.Parent = head
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Text = "杀手"
        text.TextColor3 = Color3.new(1, 0, 0)
        text.TextScaled = true
        text.TextSize = 12
        text.Parent = bill
    end
end

local function clearKillerESP()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Highlight") and v.Name == "KillerESP_Highlight" then
            v:Destroy()
        end
        if v:IsA("BillboardGui") and v.Name == "KillerESP_Billboard" then
            v:Destroy()
        end
    end
end

ESPGroup:AddToggle('KillerESP', {
    Text = '透视杀手',
    Default = false,
    Tooltip = '高亮显示杀手',
    Callback = function(Value)
        if Value then
            local killersFolder = Workspace:FindFirstChild("Players") and Workspace.Players:FindFirstChild("Killers")
            if killersFolder then
                for _, v in pairs(killersFolder:GetDescendants()) do
                    if v:IsA("Model") then addKillerESP(v) end
                end
            end
            killerAddedConn = Workspace.DescendantAdded:Connect(function(v)
                task.wait(0.1)
                if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
                    local killersFolder = Workspace:FindFirstChild("Players") and Workspace.Players:FindFirstChild("Killers")
                    if killersFolder and v:IsDescendantOf(killersFolder) then
                        addKillerESP(v)
                    end
                end
            end)
        else
            clearKillerESP()
            if killerAddedConn then killerAddedConn:Disconnect() killerAddedConn = nil end
        end
    end
})

local survivorAddedConn = nil

local function addSurvivorESP(survivor)
    if not survivor:IsA("Model") then return end
    if survivor:FindFirstChild("SurvivorESP_Highlight") then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "SurvivorESP_Highlight"
    highlight.FillColor = Color3.new(0, 1, 1)
    highlight.OutlineColor = Color3.new(0, 1, 1)
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0.1
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = survivor
    local head = survivor:FindFirstChild("Head")
    if head then
        local bill = Instance.new("BillboardGui")
        bill.Name = "SurvivorESP_Billboard"
        bill.Adornee = head
        bill.AlwaysOnTop = true
        bill.Size = UDim2.new(0, 40, 0, 15)
        bill.StudsOffset = Vector3.new(0, 2, 0)
        bill.MaxDistance = 99999
        bill.Parent = head
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Text = "幸存者"
        text.TextColor3 = Color3.new(0, 1, 1)
        text.TextScaled = true
        text.TextSize = 12
        text.Parent = bill
    end
end

local function clearSurvivorESP()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Highlight") and v.Name == "SurvivorESP_Highlight" then
            v:Destroy()
        end
        if v:IsA("BillboardGui") and v.Name == "SurvivorESP_Billboard" then
            v:Destroy()
        end
    end
end

ESPGroup:AddToggle('SurvivorESP', {
    Text = '透视幸存者',
    Default = false,
    Tooltip = '高亮显示幸存者',
    Callback = function(Value)
        if Value then
            local survivorsFolder = Workspace:FindFirstChild("Players") and Workspace.Players:FindFirstChild("Survivors")
            if survivorsFolder then
                for _, v in pairs(survivorsFolder:GetDescendants()) do
                    if v:IsA("Model") then addSurvivorESP(v) end
                end
            end
            survivorAddedConn = Workspace.DescendantAdded:Connect(function(v)
                task.wait(0.1)
                if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
                    local survivorsFolder = Workspace:FindFirstChild("Players") and Workspace.Players:FindFirstChild("Survivors")
                    if survivorsFolder and v:IsDescendantOf(survivorsFolder) then
                        addSurvivorESP(v)
                    end
                end
            end)
        else
            clearSurvivorESP()
            if survivorAddedConn then survivorAddedConn:Disconnect() survivorAddedConn = nil end
        end
    end
})

local ItemESPGroup = Tabs.ESP:AddRightGroupbox("道具透视")

local genAddedConn = nil
local generatorData = {}

local function createGeneratorESP(gen)
    if not gen or not gen:FindFirstChild("Main") then return end
    if generatorData[gen] then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "GeneratorESP"
    billboard.Size = UDim2.new(4, 0, 1, 0)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.Adornee = gen.Main
    billboard.Parent = gen.Main
    billboard.AlwaysOnTop = true
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 0.5, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "电机"
    textLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    textLabel.Font = Enum.Font.Arcade
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.TextSize = 14
    textLabel.Parent = billboard
    local highlight = Instance.new("Highlight")
    highlight.Name = "GeneratorESP_Highlight"
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.OutlineColor = Color3.fromRGB(0, 255, 255)
    highlight.FillColor = Color3.fromRGB(0, 255, 255)
    highlight.FillTransparency = 0.9
    highlight.OutlineTransparency = 0
    highlight.Parent = gen
    generatorData[gen] = {billboard = billboard, highlight = highlight}
end

local function clearGeneratorESP()
    for gen, data in pairs(generatorData) do
        if data.billboard then data.billboard:Destroy() end
        if data.highlight then data.highlight:Destroy() end
    end
    generatorData = {}
end

ItemESPGroup:AddToggle('GeneratorESP', {
    Text = '发电机透视',
    Default = false,
    Tooltip = '显示发电机位置',
    Callback = function(Value)
        if Value then
            for _, gen in pairs(Workspace:GetDescendants()) do
                if gen:IsA("Model") and gen.Name == "Generator" and gen:FindFirstChild("Main") then
                    createGeneratorESP(gen)
                end
            end
            genAddedConn = Workspace.DescendantAdded:Connect(function(v)
                if v:IsA("Model") and v.Name == "Generator" and v:FindFirstChild("Main") then
                    task.wait(0.1)
                    createGeneratorESP(v)
                end
            end)
        else
            clearGeneratorESP()
            if genAddedConn then genAddedConn:Disconnect() genAddedConn = nil end
        end
    end
})

local itemEspData = {}

local function createItemESP(item, name, color)
    if not item or not item:FindFirstChild("ItemRoot") then return end
    if itemEspData[item] then return end
    local root = item.ItemRoot
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ItemESP"
    billboard.Size = UDim2.new(3, 0, 1, 0)
    billboard.StudsOffset = Vector3.new(0, 1.5, 0)
    billboard.Adornee = root
    billboard.Parent = root
    billboard.AlwaysOnTop = true
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = name
    textLabel.TextColor3 = color
    textLabel.Font = Enum.Font.Arcade
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.TextSize = 14
    textLabel.Parent = billboard
    itemEspData[item] = billboard
end

local function clearItemESP()
    for item, billboard in pairs(itemEspData) do
        if billboard then billboard:Destroy() end
    end
    itemEspData = {}
end

ItemESPGroup:AddToggle('ItemESP', {
    Text = '透视道具',
    Default = false,
    Tooltip = '显示医疗包和可乐',
    Callback = function(Value)
        if Value then
            local map = Workspace:FindFirstChild("Map")
            if map then
                local ingame = map:FindFirstChild("Ingame")
                if ingame then
                    local medkit = ingame:FindFirstChild("Medkit")
                    if medkit then createItemESP(medkit, "医疗包", Color3.fromRGB(0, 255, 255)) end
                    local cola = ingame:FindFirstChild("BloxyCola")
                    if cola then createItemESP(cola, "可乐", Color3.fromRGB(131, 111, 255)) end
                end
            end
        else
            clearItemESP()
        end
    end
})

local SettingsGroup = Tabs.Settings:AddLeftGroupbox("菜单")

SettingsGroup:AddButton({ Text = '卸载脚本', Func = function()
    if autoFixConn then autoFixConn:Disconnect() end
    if autoFixTPConn then autoFixTPConn:Disconnect() end
    if blockConn then blockConn:Disconnect() end
    if autoItemConn then autoItemConn:Disconnect() end
    if autoPizzaConn then autoPizzaConn:Disconnect() end
    if staminaConn then staminaConn:Disconnect() end
    if killerAddedConn then killerAddedConn:Disconnect() end
    if survivorAddedConn then survivorAddedConn:Disconnect() end
    if genAddedConn then genAddedConn:Disconnect() end
    clearKillerESP()
    clearSurvivorESP()
    clearGeneratorESP()
    clearItemESP()
    destroyJumpFloat()
    Library:Unload()
end })

SettingsGroup:AddLabel('菜单快捷键'):AddKeyPicker('MenuKeybind', { Default = 'RightShift', NoUI = true, Text = 'Menu keybind' })
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
