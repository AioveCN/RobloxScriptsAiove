--Aiove HUB 开源版本
--请各位开发者不要用于付费项目

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local ContextActionService = game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	LocalPlayer = Players.LocalPlayer
end

-- =========================================================
-- 极轻量启动按钮：在加载其余模块前就显示
-- =========================================================
local createMainWindow
local aioveStartupGui
local aioveStartupOpened = false
local aioveStartupReady = false
local aioveStartupButton
local aioveStartupStatus = "正在加载 Aiove HUB..."
local loadWindUI

local function destroyAioveStartupGui()
	if aioveStartupGui then
		pcall(function() aioveStartupGui:Destroy() end)
		aioveStartupGui = nil
	end
end

local function setAioveStartupStatus(text)
	aioveStartupStatus = tostring(text or "")
	if aioveStartupButton then
		aioveStartupButton.Text = "［主人喵～点这里哟］\n" .. aioveStartupStatus
	end
end

local function openAioveHub()
	if aioveStartupOpened then return end
	if not aioveStartupReady or type(createMainWindow) ~= "function" then
		setAioveStartupStatus("主界面仍在加载，请稍候...")
		return
	end
	aioveStartupOpened = true
	setAioveStartupStatus("正在打开主界面...")
	local ok, err = pcall(createMainWindow)
	if ok then
		destroyAioveStartupGui()
		return
	end
	aioveStartupOpened = false
	setAioveStartupStatus("启动失败：" .. tostring(err or "CreateWindow 未返回窗口"))
	warn("[Aiove HUB] 主界面启动失败: " .. tostring(err or "CreateWindow 未返回窗口"))
end

local function -- 不再创建额外启动弹窗；使用 WindUI 原生主界面按钮。
	if aioveStartupGui then return end
	local parent
	pcall(function()
		if type(gethui) == "function" then parent = gethui() end
	end)
	if not parent then
		pcall(function() parent = game:GetService("CoreGui") end)
	end
	if not parent then
		parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 3)
	end
	if not parent then return end

	local gui = Instance.new("ScreenGui")
	gui.Name = "Aiove_HUB_Startup"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = parent
	aioveStartupGui = gui

	local card = Instance.new("Frame")
	card.Name = "StartupCard"
	card.AnchorPoint = Vector2.new(1, 0)
	card.Position = UDim2.new(1, -18, 0, 115)
	card.Size = UDim2.new(0, 270, 0, 76)
	card.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
	card.BackgroundTransparency = 0.06
	card.BorderSizePixel = 0
	card.ZIndex = 1000
	card.Parent = gui
	local cc = Instance.new("UICorner")
	cc.CornerRadius = UDim.new(0, 14)
	cc.Parent = card

	local button = Instance.new("TextButton")
	button.Name = "OpenButton"
	aioveStartupButton = button
	button.Position = UDim2.new(0, 14, 0, 14)
	button.Size = UDim2.new(1, -28, 0, 48)
	button.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
	button.BorderSizePixel = 0
	button.AutoButtonColor = true
	button.Font = Enum.Font.GothamBold
	button.Text = "［主人喵～点这里哟］\n" .. aioveStartupStatus
	button.TextSize = 14
	button.TextColor3 = Color3.new(1, 1, 1)
	button.ZIndex = 1001
	button.Parent = card
	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(0, 10)
	bc.Parent = button
	button.Activated:Connect(openAioveHub)
end

-- 不再创建额外启动弹窗；使用 WindUI 原生主界面按钮。

local function resolveGuiParent()
	local parent
	pcall(function()
		if type(gethui) == "function" then
			parent = gethui()
		end
	end)
	if parent then
		return parent
	end
	pcall(function()
		parent = game:FindService("CoreGui")
	end)
	if parent then
		return parent
	end
	pcall(function()
		parent = LocalPlayer:WaitForChild("PlayerGui", 5)
	end)
	if parent then
		return parent
	end
	pcall(function()
		parent = LocalPlayer:FindFirstChild("PlayerGui")
	end)
	return parent
end
local UI_PARENT = resolveGuiParent()
local RemoteFolder = ReplicatedStorage:FindFirstChild("Remote")
local PlayerEvent = RemoteFolder and RemoteFolder:FindFirstChild("PlayerEvent")
local PlayerFunc = RemoteFolder and RemoteFolder:FindFirstChild("PlayerFunc")
local function SafeCall(fn, ...)
	local args = {
		...
	}
	local ok, result = pcall(function()
		return fn(unpack(args))
	end)
	if ok then
		return result
	end
end
local CommonColors = {
	["红色"] = Color3.fromRGB(255, 0, 0),
	["黄色"] = Color3.fromRGB(255, 255, 0),
	["绿色"] = Color3.fromRGB(0, 255, 0),
	["蓝色"] = Color3.fromRGB(0, 150, 255),
	["紫色"] = Color3.fromRGB(150, 0, 255),
	["白色"] = Color3.fromRGB(255, 255, 255),
	["黑色"] = Color3.fromRGB(0, 0, 0),
	["青色"] = Color3.fromRGB(0, 255, 255),
	["橙色"] = Color3.fromRGB(255, 165, 0),
	["粉色"] = Color3.fromRGB(255, 105, 180),
}
local function GetRainbowColor(speed)
	speed = speed or 5
	return Color3.fromHSV((tick() % speed) / speed, 1, 1)
end
local function GetColor(name)
	if name == "彩虹色" then
		return GetRainbowColor()
	end
	return CommonColors[name] or Color3.fromRGB(255, 0, 0)
end
local function GetCharacter(player)
	player = player or LocalPlayer
	local character = player.Character
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	if not humanoid or not root then
		return
	end
	return character, humanoid, root
end
local function IsAlive(player)
	local _, humanoid = GetCharacter(player)
	return humanoid ~= nil and humanoid.Health > 0
end
local function GetPlayerJob(player)
	return player and player.Team and player.Team.Name or "Civilian"
end
local function EquipWeapon()
	local character, humanoid = GetCharacter(LocalPlayer)
	if not character or not humanoid then
		return
	end
	local current = character:FindFirstChildOfClass("Tool")
	if current then
		return current
	end
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	if not backpack then
		return
	end
	for _, item in ipairs(backpack:GetChildren()) do
		if item:IsA("Tool") then
			humanoid:EquipTool(item)
			task.wait(0.1)
			return character:FindFirstChildOfClass("Tool")
		end
	end
end
local WindUI
loadWindUI = function()
	-- 启动链路：缓存优先，缓存损坏自动回退远程；失败时不再直接 return 终止整个 Aiove.lua。
	local cacheFile = "AioveHUB_WindUI_Cache.lua"
	local source
	local cachedOk, cached = pcall(function() return readfile(cacheFile) end)
	if cachedOk and type(cached) == "string" and #cached > 1000 then
		source = cached
	else
		local httpOk, downloaded = pcall(function()
			return game:HttpGet("https://raw.githubusercontent.com/LumiereSeren/UI/refs/heads/main/cyyWind.lua")
		end)
		if httpOk and type(downloaded) == "string" and #downloaded > 1000 then
			source = downloaded
			pcall(function() writefile(cacheFile, downloaded) end)
		end
	end
	local ok, result = pcall(function()
		if type(source) ~= "string" then error("WindUI 源码不可用") end
		local loader = loadstring(source)
		if type(loader) ~= "function" then error("WindUI 返回内容不是可执行 Lua") end
		return loader()
	end)
	if (not ok or not result) and source ~= nil then
		local retryOk, retrySource = pcall(function()
			return game:HttpGet("https://raw.githubusercontent.com/LumiereSeren/UI/refs/heads/main/cyyWind.lua")
		end)
		if retryOk and type(retrySource) == "string" and #retrySource > 1000 then
			pcall(function() writefile(cacheFile, retrySource) end)
			ok, result = pcall(function()
				local loader = loadstring(retrySource)
				if type(loader) ~= "function" then error("WindUI 返回内容不是可执行 Lua") end
				return loader()
			end)
		end
	end
	if not ok or not result then
		WindUI = nil
		setAioveStartupStatus("WindUI 加载失败，可重新执行脚本")
		warn("[Aiove HUB] WindUI 加载失败: " .. tostring(result))
		return false, result
	end
	WindUI = result
	setAioveStartupStatus("加载完成，点击打开")
	return true
end

loadWindUI()
local SETTINGS_FILE = "AioveHUB_Settings.txt"
local settings = {
	randomBg = true,
	borderColor = nil,
	isBorderRainbow = false,
	borderEnabled = true,
}
local function loadSettings()
	local ok, data = pcall(function()
		return readfile(SETTINGS_FILE)
	end)
	if ok and data then
		local ok2, decoded = pcall(function()
			return HttpService:JSONDecode(data)
		end)
		if ok2 and type(decoded) == "table" then
			for k, v in pairs(decoded) do
				settings[k] = v
			end
		end
	end
end
local function saveSettings()
	pcall(function()
		writefile(SETTINGS_FILE, HttpService:JSONEncode(settings))
	end)
end
loadSettings()
local backgroundImages = {
	-- 原有 24 张背景
	"https://raw.githubusercontent.com/951357nvjn/background/refs/heads/main/1.jpg",
	"https://raw.githubusercontent.com/951357nvjn/background/refs/heads/main/2.jpg",
	"https://raw.githubusercontent.com/951357nvjn/background/refs/heads/main/3.jpg",
	"https://raw.githubusercontent.com/951357nvjn/background/refs/heads/main/4.jpg",
	"https://raw.githubusercontent.com/951357nvjn/background/refs/heads/main/5.jpg",
	"https://raw.githubusercontent.com/951357nvjn/background/refs/heads/main/6.jpg",
	"https://raw.githubusercontent.com/951357nvjn/background/refs/heads/main/7.jpg",
	"https://raw.githubusercontent.com/951357nvjn/background/refs/heads/main/8.jpg",
	"https://raw.githubusercontent.com/951357nvjn/background/refs/heads/main/9.jpg",
	"https://raw.githubusercontent.com/951357nvjn/background/refs/heads/main/10.jpg",
	"https://raw.githubusercontent.com/951357nvjn/background/refs/heads/main/11.jpg",
	"https://raw.githubusercontent.com/951357nvjn/background/refs/heads/main/12.jpg",
	"https://raw.githubusercontent.com/951357nvjn/background/refs/heads/main/13.jpg",
	"https://raw.githubusercontent.com/951357nvjn/background/refs/heads/main/14.jpg",
	"https://raw.githubusercontent.com/951357nvjn/background/refs/heads/main/15.jpg",
	"https://raw.githubusercontent.com/951357nvjn/background/refs/heads/main/16.jpg",
	"https://raw.githubusercontent.com/xiaopi77/xiaopi77/refs/heads/main/Image_1787322992460.jpg",
	"https://raw.githubusercontent.com/951357nvjn/background/refs/heads/main/18.jpg",
	"https://raw.githubusercontent.com/951357nvjn/background/refs/heads/main/19.jpg",
	"https://raw.githubusercontent.com/951357nvjn/background/refs/heads/main/20.jpg",
	"https://raw.githubusercontent.com/951357nvjn/background/refs/heads/main/21.jpg",
	"https://raw.githubusercontent.com/951357nvjn/background/refs/heads/main/22.jpg",
	"https://raw.githubusercontent.com/951357nvjn/background/refs/heads/main/23.jpg",
	"https://raw.githubusercontent.com/951357nvjn/background/refs/heads/main/24.jpg",
	-- GitHub 仓库中的 8 张自定义背景
	"https://raw.githubusercontent.com/AioveCN/RobloxScripts/main/bg1.jpg",
	"https://raw.githubusercontent.com/AioveCN/RobloxScripts/main/bg2.jpg",
	"https://raw.githubusercontent.com/AioveCN/RobloxScripts/main/bg3.png",
	"https://raw.githubusercontent.com/AioveCN/RobloxScripts/main/bg4.png",
	"https://raw.githubusercontent.com/AioveCN/RobloxScripts/main/bg5.png",
	"https://raw.githubusercontent.com/AioveCN/RobloxScripts/main/bg6.png",
	"https://raw.githubusercontent.com/AioveCN/RobloxScripts/main/bg7.jpg",
	"https://raw.githubusercontent.com/AioveCN/RobloxScripts/main/bg8.jpg",
}
local function getRandomBackground()
	if not settings.randomBg or # backgroundImages == 0 then
		return ""
	end
	return backgroundImages[math.random(1, # backgroundImages)]
end
local mainWindow
local rainbowTextConnection
local borderRainbowConnection
local isWindowOpen = false
local selectedTextColor = nil
local function applyBorderColor(color, rainbow)
	local mainFrame = mainWindow and mainWindow.UIElements and mainWindow.UIElements.Main
	if not mainFrame then
		return
	end
	local stroke = mainFrame:FindFirstChild("MainBorder")
	if not stroke then
		return
	end
	local gradient = stroke:FindFirstChild("BorderGradient")
	if not gradient then
		return
	end
	stroke.Enabled = settings.borderEnabled
	if borderRainbowConnection then
		borderRainbowConnection:Disconnect()
		borderRainbowConnection = nil
	end
	if rainbow then
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("FF0000")),
			ColorSequenceKeypoint.new(0.16, Color3.fromHex("FFA500")),
			ColorSequenceKeypoint.new(0.33, Color3.fromHex("FFFF00")),
			ColorSequenceKeypoint.new(0.5, Color3.fromHex("00FF00")),
			ColorSequenceKeypoint.new(0.66, Color3.fromHex("0000FF")),
			ColorSequenceKeypoint.new(0.83, Color3.fromHex("4B0082")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("EE82EE")),
		})
		borderRainbowConnection = RunService.Heartbeat:Connect(function()
			if gradient.Parent then
				gradient.Rotation = (gradient.Rotation + 1.5) % 360
			end
		end)
		settings.isBorderRainbow = true
		settings.borderColor = nil
	else
		local c = color or Color3.new(1, 1, 1)
		stroke.Color = c
		gradient.Color = ColorSequence.new(c)
		gradient.Rotation = 0
		settings.isBorderRainbow = false
		settings.borderColor = nil
	end
	saveSettings()
end
local function readRoleInfo()
	local character, hum, root = GetCharacter(LocalPlayer)
	local pos = root and root.Position
	local team = LocalPlayer.Team and LocalPlayer.Team.Name or "无"
	local charName = character and character.Name or "无角色"
	local hp = hum and string.format("%.0f/%.0f", hum.Health, hum.MaxHealth) or "未知"
	local position = pos and string.format("%.0f, %.0f, %.0f", pos.X, pos.Y, pos.Z) or "未知"
	return string.format("角色: %s\n队伍: %s  血量: %s\n位置: %s", charName, team, hp, position)
end
-- 传送系统：基于公开 Roblox CFrame/PivotTo 思路，提供单次与循环传送。
local TeleportPlayerConfig = {
    targetName = "",
    offsetMode = "后方",
    offsetDistance = 3,
    loopEnabled = false,
    loopInterval = 0.35,
}
local teleportLoopToken = 0

local function getTeleportPlayers()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.Name)
        end
    end
    table.sort(list)
    return list
end

local function findTeleportTarget(name)
    if name and name ~= "" then
        local exact = Players:FindFirstChild(name)
        if exact and exact ~= LocalPlayer then return exact end
        local low = string.lower(name)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and string.find(string.lower(p.Name), low, 1, true) then
                return p
            end
        end
    end
    return nil
end

local function getTeleportTargetCFrame(target, mode, distance)
    if not target or not target.Character then return nil end
    local root = target.Character:FindFirstChild("HumanoidRootPart")
    local head = target.Character:FindFirstChild("Head")
    if not root then return nil end
    distance = math.clamp(tonumber(distance) or 3, 1, 100)
    if mode == "头顶" then
        return CFrame.new((head and head.Position or root.Position) + Vector3.new(0, distance, 0)) * CFrame.Angles(0, root.Orientation.Y * math.pi / 180, 0)
    elseif mode == "前方" then
        return root.CFrame * CFrame.new(0, 0, -distance)
    else
        return root.CFrame * CFrame.new(0, 0, distance)
    end
end

local function teleportNearPlayer(target, mode, distance)
    local char = LocalPlayer.Character
    if not char or not char.Parent then return false end
    local cf = getTeleportTargetCFrame(target, mode, distance)
    if not cf then return false end
    local ok = pcall(function() char:PivotTo(cf) end)
    return ok
end

local function stopTeleportLoop()
    TeleportPlayerConfig.loopEnabled = false
    teleportLoopToken += 1
end

local function startTeleportLoop()
    stopTeleportLoop()
    TeleportPlayerConfig.loopEnabled = true
    teleportLoopToken += 1
    local token = teleportLoopToken
    task.spawn(function()
        while TeleportPlayerConfig.loopEnabled and token == teleportLoopToken do
            local target = findTeleportTarget(TeleportPlayerConfig.targetName)
            if target then
                teleportNearPlayer(target, TeleportPlayerConfig.offsetMode, TeleportPlayerConfig.offsetDistance)
            end
            task.wait(math.clamp(tonumber(TeleportPlayerConfig.loopInterval) or 0.35, 0.1, 3))
        end
    end)
end


-- ============================================================
-- 最小标点传送模块：仅使用基础 Roblox API，优先保证 HUB 启动稳定
-- ============================================================
local AioveWaypoint = {
    positions = {},
    loopEnabled = false,
    loopSlot = 1,
    loopInterval = 0.5,
    loopToken = 0,
    tool = nil,
    toolConnection = nil,
    count = 0,
}

local function aioveWaypointRoot()
    local char = LocalPlayer.Character
    if not char or not char.Parent then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function aioveAddWaypoint()
    local root = aioveWaypointRoot()
    if not root then return nil end
    local slot = AioveWaypoint.count + 1
    AioveWaypoint.positions[slot] = root.CFrame
    AioveWaypoint.count = slot
    return slot
end

local function aioveTeleportWaypoint(slot)
    slot = tonumber(slot) or 1
    if slot < 1 or slot > AioveWaypoint.count then return false end
    local cf = AioveWaypoint.positions[slot]
    local char = LocalPlayer.Character
    if not cf or not char or not char.Parent then return false end
    return pcall(function()
        char:PivotTo(cf)
    end)
end

local function aioveStopWaypointLoop()
    AioveWaypoint.loopEnabled = false
    AioveWaypoint.loopToken += 1
end

local function aioveStartWaypointLoop()
    aioveStopWaypointLoop()
    local slot = AioveWaypoint.loopSlot
    if not AioveWaypoint.positions[slot] then return false end
    AioveWaypoint.loopEnabled = true
    AioveWaypoint.loopToken += 1
    local token = AioveWaypoint.loopToken
    task.spawn(function()
        while AioveWaypoint.loopEnabled and token == AioveWaypoint.loopToken do
            aioveTeleportWaypoint(AioveWaypoint.loopSlot)
            task.wait(math.clamp(tonumber(AioveWaypoint.loopInterval) or 0.5, 0.1, 5))
        end
    end)
    return true
end

local function aioveDestroyWaypointTool()
    if AioveWaypoint.toolConnection then
        pcall(function() AioveWaypoint.toolConnection:Disconnect() end)
        AioveWaypoint.toolConnection = nil
    end
    if AioveWaypoint.tool then
        pcall(function() AioveWaypoint.tool:Destroy() end)
        AioveWaypoint.tool = nil
    end
end

local function aioveCreateWaypointTool()
    aioveDestroyWaypointTool()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not backpack then return false end
    local tool = Instance.new("Tool")
    tool.Name = "标点传送"
    tool.ToolTip = "装备后点击地图进行传送"
    tool.RequiresHandle = false
    tool.CanBeDropped = false
    AioveWaypoint.tool = tool
    AioveWaypoint.toolConnection = tool.Activated:Connect(function()
        local mouse = LocalPlayer:GetMouse()
        local hit = mouse and mouse.Hit
        if not hit then return end
        local char = LocalPlayer.Character
        if not char or not char.Parent then return end
        pcall(function()
            char:PivotTo(CFrame.new(hit.Position + Vector3.new(0, 3, 0)))
        end)
    end)
    tool.Parent = backpack
    return true
end


-- ============================================================
-- 新增通用功能：悬空走 / 防甩飞
-- ============================================================
local AioveHoverWalk = {enabled=false, connection=nil, y=nil}
local function stopHoverWalk()
    AioveHoverWalk.enabled=false
    if AioveHoverWalk.connection then pcall(function() AioveHoverWalk.connection:Disconnect() end); AioveHoverWalk.connection=nil end
    AioveHoverWalk.y=nil
end
local function startHoverWalk()
    stopHoverWalk()
    local char=LocalPlayer.Character
    local root=char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    AioveHoverWalk.enabled=true
    AioveHoverWalk.y=root.Position.Y
    AioveHoverWalk.connection=RunService.Heartbeat:Connect(function()
        if not AioveHoverWalk.enabled then return end
        local c=LocalPlayer.Character
        local r=c and c:FindFirstChild("HumanoidRootPart")
        if not r then return end
        local pos=r.Position
        local vel=r.AssemblyLinearVelocity
        r.AssemblyLinearVelocity=Vector3.new(vel.X,0,vel.Z)
        r.CFrame=CFrame.new(pos.X,AioveHoverWalk.y,pos.Z) * r.CFrame.Rotation
    end)
    return true
end

local AioveAntiFling = {enabled=false, connection=nil, threshold=85}
local function stopAntiFling()
    AioveAntiFling.enabled=false
    if AioveAntiFling.connection then pcall(function() AioveAntiFling.connection:Disconnect() end); AioveAntiFling.connection=nil end
end
local function startAntiFling()
    stopAntiFling()
    AioveAntiFling.enabled=true
    AioveAntiFling.connection=RunService.Heartbeat:Connect(function()
        if not AioveAntiFling.enabled then return end
        local char=LocalPlayer.Character
        local root=char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local v=root.AssemblyLinearVelocity
        local av=root.AssemblyAngularVelocity
        if math.max(math.abs(v.X),math.abs(v.Z)) > AioveAntiFling.threshold or av.Magnitude > 100 then
            root.AssemblyLinearVelocity=Vector3.new(0,math.clamp(v.Y,-35,35),0)
            root.AssemblyAngularVelocity=Vector3.zero
        end
    end)
end

-- ============================================================
-- 查看他人视野：仅切换本地 CameraSubject，不控制或修改目标玩家
-- ============================================================
local AioveSpectate={active=false,target=nil}
local function stopSpectate()
    AioveSpectate.active=false
    AioveSpectate.target=nil
    local cam=Workspace.CurrentCamera
    local char=LocalPlayer.Character
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    if cam then
        cam.CameraType=Enum.CameraType.Custom
        if hum then cam.CameraSubject=hum end
    end
end
local function startSpectate(targetName)
    local target=nil
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LocalPlayer and (p.Name==targetName or p.DisplayName==targetName) then target=p; break end
    end
    local char=target and target.Character
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    if not target or not hum then return false end
    local cam=Workspace.CurrentCamera
    if not cam then return false end
    AioveSpectate.active=true
    AioveSpectate.target=target
    cam.CameraType=Enum.CameraType.Custom
    cam.CameraSubject=hum
    return true
end

createMainWindow = function()
	if not WindUI then return end
	if mainWindow then pcall(function() mainWindow:Destroy() end) end
	mainWindow = WindUI:CreateWindow({Title="欢迎使用 Aiove HUB",Icon="zap",IconTransparency=0.5,IconThemed=true,Author="Aiove HUB",Folder="AioveHUB",Size=UDim2.fromOffset(760,520),Transparent=true,Theme="Dark",User={Enabled=false},SideBarWidth=185,ScrollBarEnabled=true,Background=getRandomBackground(),BackgroundImageTransparency=0.56})
	isWindowOpen=true
	local ok=function(fn) local a,b=pcall(fn); if not a then warn("[Aiove UI]",b) end; task.wait() end

	-- 信息：最近确定的“两格”布局。只保留信息内容，不再塞入额外启动弹窗。
	ok(function()
		local tab=mainWindow:Tab({Title="信息",Icon="info",Locked=false})
		local p=LocalPlayer
		local char,hum,root=GetCharacter(p)
		local team=p.Team and p.Team.Name or "无队伍"
		local hp=hum and string.format("%.0f / %.0f",hum.Health,hum.MaxHealth) or "未知"
		local pos=root and string.format("%.1f / %.1f / %.1f",root.Position.X,root.Position.Y,root.Position.Z) or "未生成角色"
		local rig=hum and tostring(hum.RigType):gsub("Enum.HumanoidRigType%.","") or "未知"
		local device=UserInputService.TouchEnabled and "移动触控" or (UserInputService.GamepadEnabled and "手柄" or "键鼠")

		-- 第一格：玩家信息
		local playerInfo=tab:Section({Title="👤 玩家信息",Icon="user",Opened=true})
		playerInfo:Paragraph({Title="账号",Desc="用户名："..tostring(p.Name).."\n显示名称："..tostring(p.DisplayName).."\nUserId："..tostring(p.UserId).."\n账号年龄："..tostring(p.AccountAge).." 天"})
		playerInfo:Paragraph({Title="角色",Desc="队伍："..team.."\n角色类型："..rig.."\n生命值："..hp.."\n移动速度："..(hum and tostring(hum.WalkSpeed) or "未知").."\n跳跃强度："..(hum and tostring(hum.JumpPower) or "未知")})
		playerInfo:Paragraph({Title="设备 / 位置",Desc="设备："..device.."\n坐标："..pos})

		-- 第二格：普通信息
		local normalInfo=tab:Section({Title="ℹ 普通信息",Icon="info",Opened=true})
		normalInfo:Paragraph({Title="Aiove HUB",Desc="通用移动 · 视觉辅助 · 快速交互 · 玩家工具"})
		normalInfo:Paragraph({Title="脚本信息",Desc="版本：当前稳定版\n当前游戏："..tostring(game.Name).."\nPlaceId："..tostring(game.PlaceId).."\n玩家数量："..tostring(#Players:GetPlayers())})
		normalInfo:Paragraph({Title="运行状态",Desc="当前时间："..os.date("%Y-%m-%d %H:%M:%S").."\n当前脚本未加入 Bypass Anti-Cheat\n反馈 QQ：3593722551"})
	end)

	-- 玩家读取：单独一级入口，避免和大量功能一起初始化
	ok(function()
		local tab=mainWindow:Tab({Title="玩家功能",Icon="user",Locked=false})
		local sec=tab:Section({Title="玩家读取",Icon="users",Opened=true})
		local function notify() pcall(function() WindUI:Notify({Title="玩家读取",Content="当前服务器共有 "..tostring(#Players:GetPlayers()).." 名玩家",Duration=3}) end) end
		sec:Button({Title="读取玩家列表",Icon="users",Callback=notify})
		sec:Button({Title="立即读取角色",Icon="scan",Callback=function() pcall(function() WindUI:Notify({Title="角色读取",Content=readRoleInfo(),Duration=4}) end) end})
		sec:Button({Title="显示本地坐标",Icon="map-pin",Callback=function() local _,_,r=GetCharacter(LocalPlayer); if r then local q=r.Position; pcall(function() WindUI:Notify({Title="坐标",Content=string.format("%.2f / %.2f / %.2f",q.X,q.Y,q.Z),Duration=3}) end) end end})
		sec:Button({Title="复制用户名",Icon="copy",Callback=function() if setclipboard then pcall(function() setclipboard(LocalPlayer.Name) end) end end})
		sec:Button({Title="复制 UserId",Icon="copy",Callback=function() if setclipboard then pcall(function() setclipboard(tostring(LocalPlayer.UserId)) end) end end})
	end)

	-- 圣奥里只保留独立入口，不加载本体
	ok(function()
		local tab=mainWindow:Tab({Title="圣奥里",Icon="zap",Locked=false}); local sec=tab:Section({Title="圣奥里 · 独立脚本",Icon="external-link",Opened=true})
		local url="https://raw.githubusercontent.com/AioveCN/RobloxScripts/main/AioveCN_Hub_%E7%A8%B3%E5%AE%9A%E4%BF%AE%E6%AD%A3%E7%89%88.lua"
		sec:Paragraph({Title="独立脚本说明",Desc="圣奥里不并入 Aiove HUB，点击下方按钮单独启动。"})
		sec:Button({Title="启动圣奥里脚本",Icon="play",Callback=function() local a,b=pcall(function() loadstring(game:HttpGet(url))() end); pcall(function() WindUI:Notify({Title="圣奥里",Content=a and "独立脚本已启动" or ("启动失败："..tostring(b)),Duration=4}) end) end})
	end)

	-- 使用原来的 WindUI 开关按钮，不创建新的执行弹窗；仅将原“开始脚本”名称改为“加入游戏”。
	pcall(function()
		mainWindow:EditOpenButton({
			Title="加入游戏",
			Icon="play",
			CornerRadius=UDim.new(1,16),
			StrokeThickness=1.5,
			Draggable=true,
		})
	end)

	pcall(function() if type(mainWindow.Open)=="function" then mainWindow:Open() end end)
end

aioveStartupReady = type(createMainWindow) == "function"
if aioveStartupReady then
	setAioveStartupStatus("加载完成，点击打开")
else
	setAioveStartupStatus("主界面初始化失败，请重新执行")
end

-- 已移除第三方执行上报逻辑：脚本不再向外部服务器发送卡密、账号、JobId 或执行器信息。
