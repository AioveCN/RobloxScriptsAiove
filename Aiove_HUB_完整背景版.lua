--Aiove HUB 开源版本
--请各位开发者不要用于付费项目

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	LocalPlayer = Players.LocalPlayer
end

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
do
	local ok, result = pcall(function()
		local source = game:HttpGet("https://raw.githubusercontent.com/LumiereSeren/UI/refs/heads/main/cyyWind.lua")
		local loader = loadstring(source)
		if type(loader) ~= "function" then
			error("WindUI 返回内容不是可执行 Lua")
		end
		return loader()
	end)
	if not ok or not result then
		warn("[Aiove HUB] WindUI 加载失败: " .. tostring(result))
		return
	end
	WindUI = result
end
local SETTINGS_FILE = "AioveHUB_Settings.txt"
local settings = {
	randomBg = true,
	borderColor = nil,
	isBorderRainbow = false,
	borderEnabled = true,
	theme = "Dark",
	windowTransparency = 15,
	panelBackground = true,
	resizable = true,
	windowSize = "中",
	textColor = "默认",
	totalUses = 0,
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
-- 每次真正载入 Aiove HUB 计为一次使用；次数保存在本地配置文件中，跨天/重启仍保留。
settings.totalUses = (tonumber(settings.totalUses) or 0) + 1
saveSettings()
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
local State = {
	stamina = false,
	food = false,
	combatBlock = false,
	ghost = false,
	noRagdoll = false,
	noFallDamage = false,
	antiPrisonPull = false,
	autoMoney = false,
	infiniteAmmo = false,
	rapidFire = false,
	farmer = false,
	taxi = false,
	bus = false,
	autoMission = false,
	autoHack = false,
	golf = false,
	autoCuff = false,
}
local CharacterModule
local CoreModule
local InventoryModule
local function loadFrameworkModules()
	if CharacterModule or CoreModule then return end
	local ps = LocalPlayer:FindFirstChild("PlayerScripts")
	local framework = ps and ps:FindFirstChild("Framework")
	if not framework then return end
	pcall(function()
		local characterModule = framework:FindFirstChild("Character")
		local coreModule = framework:FindFirstChild("Core")
		if characterModule then CharacterModule = require(characterModule) end
		if coreModule then CoreModule = require(coreModule) end
		local inv = framework:FindFirstChild("Character") and framework.Character:FindFirstChild("Inventory")
		if inv then InventoryModule = require(inv) end
	end)
end
task.defer(loadFrameworkModules)
local stateLoopStarted = false
local function setupMainStateLoops()
	if stateLoopStarted then return end
	stateLoopStarted = true
	task.spawn(function()
		while true do
			task.wait(0.2)
			if CoreModule then
				if State.stamina then pcall(function() CoreModule.stamina = 100 end) end
				if State.food then pcall(function() CoreModule.food = 100 end) end
			end
			if State.infiniteAmmo then
				local characters = Workspace:FindFirstChild("Characters")
				local characterFolder = characters and characters:FindFirstChild(LocalPlayer.Name)
				if characterFolder then
					for _, gun in ipairs(characterFolder:GetChildren()) do
						local config = gun:FindFirstChild("Config")
						if config then
							local ammo = config:FindFirstChild("Ammo")
							local total = config:FindFirstChild("TotalAmmo")
							if ammo then ammo.Value = math.huge end
							if total then total.Value = math.huge end
						end
					end
				end
			end
		end
	end)
end
-- 只有需要相关状态功能时才启动循环，避免 HUB 启动时白跑 Heartbeat。
local function ModifyWeaponStats()
	if not State.rapidFire or not getgc then
		return
	end
	for _, tbl in pairs(getgc(true)) do
		if type(tbl) == "table" then
			if rawget(tbl, "SHOOT_MODE") ~= nil then
				rawset(tbl, "SHOOT_MODE", 2)
			end
			if rawget(tbl, "RPM") ~= nil then
				rawset(tbl, "RPM", math.huge)
			end
		end
	end
end
local oldCombatNamecall
local function setCombatBlock(enabled)
	State.combatBlock = enabled
	if enabled and not oldCombatNamecall and hookmetamethod and newcclosure then
		oldCombatNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
			local args = {
				...
			}
			local method = getnamecallmethod()
			if State.combatBlock and method == "FireServer" and args[1] == "combatMode" then
				return nil
			end
			return oldCombatNamecall(self, ...)
		end))
	end
end
local ghostConnections = {}
local ghostRender
local ghostQuickGui
local ghostQuickButton
local ghostQuickRainbow
local ghostQuickLocked = false
local ghostQuickShown = false
local ghostQuickPos = UDim2.new(0, 100, 0.5, - 25)
local function clearGhostConnections()
	for _, conn in ipairs(ghostConnections) do
		pcall(function()
			conn:Disconnect()
		end)
	end
	ghostConnections = {}
end
local function setGhostVisuals(character, enabled)
	if not character then
		return
	end
	pcall(function()
		character:SetAttribute("Invisible", enabled or nil)
		for _, obj in ipairs(character:GetDescendants()) do
			if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
				obj.LocalTransparencyModifier = enabled and 0.55 or 0
				obj.Material = enabled and Enum.Material.ForceField or Enum.Material.SmoothPlastic
			elseif obj:IsA("Decal") and obj.Name == "face" then
				obj.Transparency = enabled and 0.55 or 0
			end
		end
	end)
end
local function updateGhostButton()
	if not ghostQuickButton then
		return
	end
	ghostQuickButton.Text = State.ghost and "隐身: 开" or "隐身: 关"
	ghostQuickButton.TextColor3 = State.ghost and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end
local function setGhostMode(enabled)
	State.ghost = enabled
	local character = LocalPlayer.Character
	if not character then
		return
	end
	if enabled then
		pcall(function()
			local stuff = ReplicatedStorage:FindFirstChild("Stuff")
			local locations = stuff and stuff:FindFirstChild("Locations")
			local target = locations and locations:GetChildren()[1] or nil
			if PlayerFunc then
				PlayerFunc:InvokeServer("hideCharacterLocation", target)
			end
		end)
		if InventoryModule and InventoryModule.canEquipSlot then
			pcall(function()
				InventoryModule.canEquipSlot(true)
			end)
		end
		if CharacterModule and CharacterModule.lockHumanoidState then
			pcall(function()
				CharacterModule.lockHumanoidState("ghostMode", nil)
			end)
		end
		pcall(function()
			GuiService.TouchControlsEnabled = true
			ContextActionService:UnbindAction("LoadingGuiNoResetOnDeath")
			ContextActionService:UnbindAction("DisableCameraMovementNoResetOnDeath")
		end)
		setGhostVisuals(character, true)
		clearGhostConnections()
		if ghostRender then
			ghostRender:Disconnect()
		end
		ghostRender = RunService.RenderStepped:Connect(function()
			if State.ghost and LocalPlayer.Character then
				setGhostVisuals(LocalPlayer.Character, true)
			end
		end)
	else
		if ghostRender then
			ghostRender:Disconnect();
			ghostRender = nil
		end
		clearGhostConnections()
		pcall(function()
			if PlayerFunc then
				PlayerFunc:InvokeServer("hideCharacterLocation", false)
			end
		end)
		setGhostVisuals(character, false)
	end
	updateGhostButton()
end
local function destroyGhostQuick()
	if ghostQuickRainbow then
		ghostQuickRainbow:Disconnect();
		ghostQuickRainbow = nil
	end
	if ghostQuickGui then
		ghostQuickGui:Destroy();
		ghostQuickGui = nil;
		ghostQuickButton = nil
	end
end
local function createGhostQuick()
	destroyGhostQuick()
	if not ghostQuickShown then
		return
	end
	ghostQuickGui = Instance.new("ScreenGui")
	ghostQuickGui.Name = "GhostQuickSwitch"
	ghostQuickGui.ResetOnSpawn = false
	ghostQuickGui.Parent = UI_PARENT or resolveGuiParent()
	ghostQuickButton = Instance.new("TextButton")
	ghostQuickButton.Size = UDim2.new(0, 80, 0, 35)
	ghostQuickButton.Position = ghostQuickPos
	ghostQuickButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	ghostQuickButton.BackgroundTransparency = 0.4
	ghostQuickButton.BorderSizePixel = 0
	ghostQuickButton.Font = Enum.Font.GothamSemibold
	ghostQuickButton.TextSize = 12
	ghostQuickButton.Parent = ghostQuickGui
	ghostQuickButton.Active = not ghostQuickLocked
	ghostQuickButton.Draggable = not ghostQuickLocked
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = ghostQuickButton
	local stroke = Instance.new("UIStroke")
	stroke.Name = "RainbowStroke"
	stroke.Thickness = 1.5
	stroke.Parent = ghostQuickButton
	updateGhostButton()
	ghostQuickRainbow = RunService.RenderStepped:Connect(function()
		if stroke.Parent then
			stroke.Color = GetRainbowColor(5)
		end
	end)
	ghostQuickButton.MouseButton1Click:Connect(function()
		setGhostMode(not State.ghost)
	end)
	ghostQuickButton:GetPropertyChangedSignal("Position"):Connect(function()
		if not ghostQuickLocked then
			ghostQuickPos = ghostQuickButton.Position
		end
	end)
end
local originalRagdollActivate
local originalRagdollActivateServer
pcall(function()
	local Ragdoll = require(ReplicatedStorage.Modules.Ragdoll)
	originalRagdollActivate = Ragdoll.activate
	originalRagdollActivateServer = Ragdoll.activateServer
	Ragdoll.activate = function(character, enable, duration, ...)
		if State.noRagdoll and enable then
			return
		end
		return originalRagdollActivate(character, enable, duration, ...)
	end
	if originalRagdollActivateServer then
		Ragdoll.activateServer = function(character, enable, duration, ...)
			if State.noRagdoll and enable then
				return
			end
			return originalRagdollActivateServer(character, enable, duration, ...)
		end
	end
end)
local oldDamageNamecall
pcall(function()
	local mt = getrawmetatable(game)
	oldDamageNamecall = mt.__namecall
	setreadonly(mt, false)
	mt.__namecall = newcclosure(function(self, ...)
		local args = {
			...
		}
		local method = getnamecallmethod()
		if State.noFallDamage and method == "FireServer" and tostring(self) == "PlayerEvent" and args[1] == "takeDamage" then
			return nil
		end
		return oldDamageNamecall(self, ...)
	end)
	setreadonly(mt, true)
end)
local originalCharPivotTo
local originalNotify
local function setAntiPrisonPull(enabled)
	State.antiPrisonPull = enabled
	pcall(function()
		local Algorithms = require(ReplicatedStorage.Modules.Algorithms)
		if enabled and not originalCharPivotTo then
			originalCharPivotTo = Algorithms.charPivotTo
			Algorithms.charPivotTo = function()
				return nil
			end
		elseif not enabled and originalCharPivotTo then
			Algorithms.charPivotTo = originalCharPivotTo
			originalCharPivotTo = nil
		end
	end)
	pcall(function()
		if not CoreModule then
			return
		end
		if enabled and not originalNotify then
			originalNotify = CoreModule.notify
			CoreModule.notify = function(config)
				if config and config.message and string.find(config.message, "You can't leave prison yet") then
					return nil
				end
				return originalNotify(config)
			end
		elseif not enabled and originalNotify then
			CoreModule.notify = originalNotify
			originalNotify = nil
		end
	end)
end
local function getPromptPosition(prompt)
	if not prompt or not prompt.Parent then
		return
	end
	local parent = prompt.Parent
	if parent:IsA("BasePart") then
		return parent.Position
	end
	if parent:IsA("Attachment") then
		return parent.WorldPosition
	end
	if parent:IsA("Model") then
		local part = parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart")
		if part then
			return part.Position
		end
	end
end
local function firePrompt(prompt)
	if not prompt then
		return
	end
	pcall(function()
		if fireproximityprompt then
			fireproximityprompt(prompt, 0)
		else
			prompt.HoldDuration = 0
			prompt:InputHoldBegin()
			task.wait(0.1)
			prompt:InputHoldEnd()
		end
	end)
end
local function teleportTo(pos)
	local character, _, root = GetCharacter(LocalPlayer)
	if not character or not root or not pos then
		return
	end
	local cf = CFrame.new(pos + Vector3.new(0, 3, 0))
	character:PivotTo(cf)
	pcall(function()
		if PlayerEvent then
			local id = ((character:GetAttribute("CharPivotToId") or 0) + 1) % 100
			character:SetAttribute("CharPivotToId", id)
			PlayerEvent:FireServer("charPivotTo", cf, character, id)
		end
	end)
end
local function startAutoMoneyLoop()
	task.spawn(function()
		while true do
			if State.autoMoney then
				local _, _, root = GetCharacter(LocalPlayer)
				if root then
					local bestPrompt, bestDist
					for _, obj in ipairs(Workspace:GetDescendants()) do
						if obj:IsA("ProximityPrompt") and (obj.Name == "CashDrop" or obj.Name == "GetItem") then
							local pos = getPromptPosition(obj)
							if pos then
								local dist = (root.Position - pos).Magnitude
								if not bestDist or dist < bestDist then
									bestDist = dist
									bestPrompt = obj
								end
							end
						end
					end
					if bestPrompt and bestDist and bestDist < 60 then
						if bestDist > 8 then
							teleportTo(getPromptPosition(bestPrompt))
							task.wait(0.3)
						end
						firePrompt(bestPrompt)
					end
				end
			end
			task.wait(0.3)
		end
	end)
end
startAutoMoneyLoop()
local MoneyConfig = {
	missionInterval = 2,
	priorityHighReward = false,
	taxiSafe = false,
	taxiDelayMode = "随机时间",
	taxiOrigin = nil,
}
local function getTeamJobs()
	if not getgc then
		return
	end
	for _, v in pairs(getgc(true)) do
		if type(v) == "table" and rawget(v, "teamJobs") then
			return v.teamJobs
		end
	end
end
local function hasActiveMission()
	if LocalPlayer:GetAttribute("Mission") then
		return true
	end
	local jobs = getTeamJobs()
	if jobs then
		for _, job in pairs(jobs) do
			if job.joined then
				return true
			end
		end
	end
	return false
end
local function getBestMission()
	local jobs = getTeamJobs()
	if not jobs then
		return
	end
	local bestId, bestScore = nil, - math.huge
	for id, job in pairs(jobs) do
		if not job.joined then
			if not MoneyConfig.priorityHighReward then
				return id
			end
			local score = (job.profitability or 1) * 1000000 + (job.reward or 0)
			if score > bestScore then
				bestScore = score
				bestId = id
			end
		end
	end
	return bestId
end
local function startMissionLoop()
	task.spawn(function()
		while true do
			if State.autoMission and PlayerFunc and not hasActiveMission() then
				local id = getBestMission()
				if id then
					pcall(function()
						PlayerFunc:InvokeServer("talkToMission", tostring(id) .. "join")
					end)
				end
			end
			task.wait(MoneyConfig.missionInterval)
		end
	end)
end
startMissionLoop()
local function getFarmerDropOff()
	local gameplay = ReplicatedStorage:FindFirstChild("Gameplay")
	local missions = gameplay and gameplay:FindFirstChild("Missions")
	local active = missions and missions:FindFirstChild("Active")
	if active then
		for _, mission in ipairs(active:GetChildren()) do
			if mission.Name:find("^Farmer") then
				for _, name in ipairs({
					"DropOff",
					"Target",
					"Goal"
				}) do
					local obj = mission:FindFirstChild(name)
					if obj and obj:IsA("BasePart") then
						return obj.Position
					end
					if obj and obj:IsA("ObjectValue") and obj.Value and obj.Value:IsA("BasePart") then
						return obj.Value.Position
					end
				end
			end
		end
	end
end
local function startFarmerLoop()
	task.spawn(function()
		while true do
			if State.farmer then
				local drop = getFarmerDropOff()
				if drop then
					teleportTo(drop)
					task.wait(0.4)
				end
				local _, _, root = GetCharacter(LocalPlayer)
				if root then
					local best, bestDist
					for _, obj in ipairs(Workspace:GetDescendants()) do
						if obj:IsA("ProximityPrompt") and obj.ActionText == "Pick Up" then
							local pos = getPromptPosition(obj)
							if pos then
								local dist = (root.Position - pos).Magnitude
								if not bestDist or dist < bestDist then
									bestDist, best = dist, obj
								end
							end
						end
					end
					if best then
						firePrompt(best)
					end
				end
			end
			task.wait(0.3)
		end
	end)
end
startFarmerLoop()
local function startTaxiLoop()
	task.spawn(function()
		local lastTargetPos
		while true do
			if State.taxi then
				local clientContent = Workspace:FindFirstChild("Gameplay")
				clientContent = clientContent and clientContent:FindFirstChild("Entities")
				clientContent = clientContent and clientContent:FindFirstChild("ClientContent")
				if clientContent and clientContent:IsA("Model") then
					local targetPart = clientContent.PrimaryPart or clientContent:FindFirstChildWhichIsA("BasePart")
					local _, _, root = GetCharacter(LocalPlayer)
					if targetPart and root then
						local currentPos = targetPart.Position
						local changed = lastTargetPos == nil or (currentPos - lastTargetPos).Magnitude > 5
						if changed then
							lastTargetPos = currentPos
							if MoneyConfig.taxiSafe and MoneyConfig.taxiOrigin then
								root.CFrame = CFrame.new(MoneyConfig.taxiOrigin)
								local distance = (MoneyConfig.taxiOrigin - currentPos).Magnitude
								local waitTime
								if MoneyConfig.taxiDelayMode == "距离测算" then
									local d = math.clamp(distance, 2000, 6000)
									waitTime = math.clamp(15 + (d - 2000) / 4000 * 30 + (math.random() * 2 - 1), 15, 45)
								else
									waitTime = distance > 2000 and math.random(15, 45) or 15
								end
								task.wait(waitTime)
							end
							root.CFrame = CFrame.new(currentPos)
						end
					end
				end
			end
			task.wait(0.5)
		end
	end)
end
startTaxiLoop()
local function getBusArea()
	local gameplay = Workspace:FindFirstChild("Gameplay")
	local entities = gameplay and gameplay:FindFirstChild("Entities")
	local clientContent = entities and entities:FindFirstChild("ClientContent")
	local child = clientContent and clientContent:GetChildren()[1]
	return child and child:FindFirstChild("Area")
end
local function startBusLoop()
	task.spawn(function()
		while true do
			if State.bus then
				local area = getBusArea()
				local _, hum, root = GetCharacter(LocalPlayer)
				if area and hum and root then
					local seat = hum.SeatPart
					if seat then
						local newCF = ((area.CFrame * CFrame.new(17.5, 3, 6.5)) * CFrame.Angles(0, math.rad(270), 0)) * root.CFrame:ToObjectSpace(seat.CFrame)
						seat.CFrame = newCF
						seat.AssemblyLinearVelocity = Vector3.zero
						seat.AssemblyAngularVelocity = Vector3.zero
						task.wait(0.1)
						hum.Sit = false
					else
						root.CFrame = (area.CFrame * CFrame.new(17.5, 3, 6.5)) * CFrame.Angles(0, math.rad(270), 0)
					end
					task.wait(5)
				end
			end
			task.wait(1)
		end
	end)
end
startBusLoop()
local autoHackOriginal = {}
local function setAutoHack(enabled)
	State.autoHack = enabled
	pcall(function()
		local framework = LocalPlayer.PlayerScripts:FindFirstChild("Framework")
		local char = framework and require(framework:FindFirstChild("Character"))
		local rules = require(ReplicatedStorage.Modules.GameRules)
		if rules then
			rules.disableHacking = enabled
			rules.disableMinigames = enabled
		end
		if char then
			if not autoHackOriginal.hackingMinigame then
				autoHackOriginal.hackingMinigame = char.hackingMinigame
			end
			if not autoHackOriginal.startMinigame then
				autoHackOriginal.startMinigame = char.startMinigame
			end
			if enabled then
				char.hackingMinigame = function()
					return true
				end
				char.startMinigame = function()
					return true
				end
			else
				if autoHackOriginal.hackingMinigame then
					char.hackingMinigame = autoHackOriginal.hackingMinigame
				end
				if autoHackOriginal.startMinigame then
					char.startMinigame = autoHackOriginal.startMinigame
				end
			end
		end
	end)
end
local function startGolfLoop()
	task.spawn(function()
		local function findPath(parts)
			local obj = Workspace
			for _, name in ipairs(parts) do
				obj = obj and obj:FindFirstChild(name)
				if not obj then
					return
				end
			end
			return obj
		end
		while true do
			if State.golf and PlayerFunc then
				pcall(function()
					PlayerFunc:InvokeServer("miniGolf", "createLobby")
					task.wait(0.1)
					PlayerFunc:InvokeServer("miniGolf", "setLobbyBid", {
						bid = 500
					})
					task.wait(0.1)
					PlayerFunc:InvokeServer("miniGolf", "setLobbyReady")
					task.wait(4)
					PlayerFunc:InvokeServer("miniGolf", "shot")
					task.wait(0.5)
					local ball = findPath({
						"Gameplay",
						"Entities",
						"Content",
						LocalPlayer.Name
					})
					local target = findPath({
						"Gameplay",
						"Entities",
						"Content",
						"_Flag",
						"FlagPole",
						"Part"
					})
					if ball and target and ball:IsA("BasePart") then
						ball.Position = target.Position
					end
				end)
			end
			task.wait(State.golf and 5 or 1)
		end
	end)
end
startGolfLoop()
local CombatConfig = {
	auraEnabled = false,
	auraRange = 50,
	auraDamage = 5,
	auraInterval = 0.05,
	auraOnlyPolice = false,
	auraOnlyCivilian = false,
	auraCombatCheck = false,
	bulletEnabled = false,
	bulletFov = 360,
	bulletDistance = 300,
	bulletPart = "Head",
	bulletShowFov = true,
	bulletColor = "红色",
	bulletCombatCheck = false,
	bulletOnlyPolice = false,
	bulletOnlyCivilian = false,
}
local function targetAllowed(player, onlyPolice, onlyCivilian)
	if not player or player == LocalPlayer then
		return false
	end
	if onlyPolice then
		return player.Team and player.Team.Name == "Police"
	end
	if onlyCivilian then
		return player.Team and player.Team.Name == "Civilian"
	end
	return true
end
local function inCombat(player, enabled)
	if not enabled then
		return true
	end
	return player:GetAttribute("CombatMode") == true or player:GetAttribute("Pursuit") == true
end
local auraLast = 0
RunService.Heartbeat:Connect(function()
	if not CombatConfig.auraEnabled or not PlayerEvent then
		return
	end
	local now = tick()
	if now - auraLast < CombatConfig.auraInterval then
		return
	end
	local _, _, myRoot = GetCharacter(LocalPlayer)
	if not myRoot then
		return
	end
	local nearest, nearestDist
	for _, player in ipairs(Players:GetPlayers()) do
		if targetAllowed(player, CombatConfig.auraOnlyPolice, CombatConfig.auraOnlyCivilian) and IsAlive(player) and inCombat(player, CombatConfig.auraCombatCheck) then
			local _, _, root = GetCharacter(player)
			if root then
				local dist = (root.Position - myRoot.Position).Magnitude
				if dist <= CombatConfig.auraRange and (not nearestDist or dist < nearestDist) then
					nearestDist = dist
					nearest = player
				end
			end
		end
	end
	if nearest then
		local _, _, root = GetCharacter(nearest)
		local myPos = myRoot.Position
		pcall(function()
			PlayerEvent:FireServer("damage", {
				bodyParts = {
					{
						"Head",
						1
					}
				},
				shotCode = {
					myPos,
					(root.Position - myPos).Unit
				},
				pos = root.Position,
				target = nearest,
				damageFactor = CombatConfig.auraDamage,
				bulletProofTool = false,
			})
		end)
		auraLast = now
	end
end)
local BulletFOV = Drawing.new("Circle")
BulletFOV.Filled = false
BulletFOV.NumSides = 64
BulletFOV.Visible = false
local function getBulletTarget()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	local bestPos, bestFov = nil, CombatConfig.bulletFov
	for _, player in ipairs(Players:GetPlayers()) do
		if targetAllowed(player, CombatConfig.bulletOnlyPolice, CombatConfig.bulletOnlyCivilian) and IsAlive(player) and inCombat(player, CombatConfig.bulletCombatCheck) then
			local char = player.Character
			local part = char and (char:FindFirstChild(CombatConfig.bulletPart) or char:FindFirstChild("HumanoidRootPart"))
			if part then
				local dist = (part.Position - camera.CFrame.Position).Magnitude
				if dist <= CombatConfig.bulletDistance then
					local screen, onScreen = camera:WorldToScreenPoint(part.Position)
					if onScreen and screen.Z > 0 then
						local fov = (Vector2.new(screen.X, screen.Y) - center).Magnitude
						if fov < bestFov then
							bestFov = fov
							bestPos = part.Position
						end
					end
				end
			end
		end
	end
	return bestPos
end
pcall(function()
	local oldRaycast = Workspace.Raycast
	hookfunction(Workspace.Raycast, function(self, origin, direction, params)
		if CombatConfig.bulletEnabled and origin and direction then
			local _, _, root = GetCharacter(LocalPlayer)
			if root and (origin - root.Position).Magnitude < 15 then
				local target = getBulletTarget()
				if target then
					direction = (target - origin).Unit * direction.Magnitude
				end
			end
		end
		return oldRaycast(self, origin, direction, params)
	end)
end)
RunService.RenderStepped:Connect(function()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	BulletFOV.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	BulletFOV.Radius = CombatConfig.bulletFov
	BulletFOV.Thickness = 2
	BulletFOV.Color = GetColor(CombatConfig.bulletColor)
	BulletFOV.Visible = CombatConfig.bulletEnabled and CombatConfig.bulletShowFov
end)
local AimConfig = {
	enabled = false,
	prediction = false,
	teamCheck = false,
	wallCheck = false,
	showFov = false,
	showCrosshair = false,
	showTracer = false,
	friendCheck = false,
	onlyPolice = false,
	onlyCivilian = false,
	combatCheck = false,
	fov = 50,
	smoothness = 1,
	targetMode = "准心最近",
	targetPart = "头",
	color = "红色",
	fovThickness = 2,
}
local AimFOV = Drawing.new("Circle")
AimFOV.Filled = false
AimFOV.NumSides = 64
local AimTracer = Drawing.new("Line")
local AimCrosshair = {
	Top = Drawing.new("Line"),
	Bottom = Drawing.new("Line"),
	Left = Drawing.new("Line"),
	Right = Drawing.new("Line"),
	Center = Drawing.new("Line")
}
for _, line in pairs(AimCrosshair) do
	line.Thickness = 2;
	line.Visible = false
end
local PartMap = {
	["头"] = {
		"Head"
	},
	["胸"] = {
		"UpperTorso",
		"Torso"
	},
	["左手"] = {
		"LeftHand",
		"Left Arm"
	},
	["右手"] = {
		"RightHand",
		"Right Arm"
	},
	["左腿"] = {
		"LeftFoot",
		"Left Leg"
	},
	["右腿"] = {
		"RightFoot",
		"Right Leg"
	}
}
local function aimTargetPart(char)
	for _, name in ipairs(PartMap[AimConfig.targetPart] or {
		"Head"
	}) do
		local part = char:FindFirstChild(name)
		if part then
			return part
		end
	end
	return char:FindFirstChild("HumanoidRootPart")
end
local function aimVisible(part)
	if not AimConfig.wallCheck then
		return true
	end
	local camera = Workspace.CurrentCamera
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {
		LocalPlayer.Character,
		camera
	}
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = true
	local hit = Workspace:Raycast(camera.CFrame.Position, part.Position - camera.CFrame.Position, params)
	return not hit or hit.Instance:IsDescendantOf(part.Parent)
end
local function getBestAimTarget()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	local best, bestValue
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and IsAlive(player) and targetAllowed(player, AimConfig.onlyPolice, AimConfig.onlyCivilian) and inCombat(player, AimConfig.combatCheck) then
			if AimConfig.teamCheck and LocalPlayer.Team and player.Team == LocalPlayer.Team then
				continue
			end
			if AimConfig.friendCheck then
				local ok, friend = pcall(function()
					return LocalPlayer:IsFriendsWith(player.UserId)
				end)
				if ok and friend then
					continue
				end
			end
			local char = player.Character
			local part = char and aimTargetPart(char)
			local _, hum, root = GetCharacter(player)
			if part and hum and root and aimVisible(part) then
				local screen, onScreen = camera:WorldToViewportPoint(part.Position)
				if onScreen then
					local fov = (Vector2.new(screen.X, screen.Y) - center).Magnitude
					if fov <= AimConfig.fov then
						local score
						if AimConfig.targetMode == "距离最近" then
							local _, _, myRoot = GetCharacter(LocalPlayer)
							score = myRoot and (myRoot.Position - root.Position).Magnitude or math.huge
						elseif AimConfig.targetMode == "血量最低" then
							score = hum.Health
						else
							score = fov
						end
						if not bestValue or score < bestValue then
							bestValue = score
							best = {
								player = player,
								part = part,
								screen = screen
							}
						end
					end
				end
			end
		end
	end
	return best
end
RunService.RenderStepped:Connect(function(dt)
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	local color = GetColor(AimConfig.color)
	AimFOV.Position = center
	AimFOV.Radius = AimConfig.fov
	AimFOV.Thickness = AimConfig.fovThickness
	AimFOV.Color = color
	AimFOV.Visible = AimConfig.enabled and AimConfig.showFov
	local gap, size = 5, 15
	AimCrosshair.Top.From = Vector2.new(center.X, center.Y - gap)
	AimCrosshair.Top.To = Vector2.new(center.X, center.Y - gap - size)
	AimCrosshair.Bottom.From = Vector2.new(center.X, center.Y + gap)
	AimCrosshair.Bottom.To = Vector2.new(center.X, center.Y + gap + size)
	AimCrosshair.Left.From = Vector2.new(center.X - gap, center.Y)
	AimCrosshair.Left.To = Vector2.new(center.X - gap - size, center.Y)
	AimCrosshair.Right.From = Vector2.new(center.X + gap, center.Y)
	AimCrosshair.Right.To = Vector2.new(center.X + gap + size, center.Y)
	AimCrosshair.Center.From = Vector2.new(center.X - 2, center.Y)
	AimCrosshair.Center.To = Vector2.new(center.X + 2, center.Y)
	for _, line in pairs(AimCrosshair) do
		line.Color = color
		line.Visible = AimConfig.showCrosshair
	end
	AimTracer.Visible = false
	if AimConfig.enabled then
		local target = getBestAimTarget()
		if target then
			if AimConfig.showTracer then
				AimTracer.From = center
				AimTracer.To = Vector2.new(target.screen.X, target.screen.Y)
				AimTracer.Color = color
				AimTracer.Thickness = 2
				AimTracer.Transparency = 0.5
				AimTracer.Visible = true
			end
			local targetPos = target.part.Position
			if AimConfig.prediction then
				targetPos = targetPos + target.part.AssemblyLinearVelocity * dt * 1.5
			end
			local targetCF = CFrame.new(camera.CFrame.Position, targetPos)
			camera.CFrame = AimConfig.smoothness >= 1 and targetCF or camera.CFrame:Lerp(targetCF, AimConfig.smoothness)
		end
	end
end)
local RageConfig = {
	enabled = false,
	range = 150,
	interval = 0.05,
	bodyPart = "Head",
	jobCheck = false,
	wallCheck = false,
	aliveCheck = false,
	combatCheck = false,
	policeLock = false,
	civilianLock = false,
	beam = false,
}
local RageBodyParts = {
	["头部"] = "Head",
	["躯干"] = "Torso",
	["左臂"] = "LeftArm",
	["右臂"] = "RightArm",
	["左腿"] = "LeftLeg",
	["右腿"] = "RightLeg"
}
local function createBeam(startPos, endPos)
	local p1 = Instance.new("Part")
	local p2 = Instance.new("Part")
	for _, p in ipairs({
		p1,
		p2
	}) do
		p.Anchored = true;
		p.CanCollide = false;
		p.Transparency = 1;
		p.Size = Vector3.new(0.1, 0.1, 0.1);
		p.Parent = Workspace
	end
	p1.Position = startPos;
	p2.Position = endPos
	local a1 = Instance.new("Attachment", p1)
	local a2 = Instance.new("Attachment", p2)
	local beam = Instance.new("Beam", p1)
	beam.Attachment0 = a1;
	beam.Attachment1 = a2;
	beam.Width0 = 0.15;
	beam.Width1 = 0.15
	beam.Color = ColorSequence.new(Color3.fromRGB(180, 200, 255))
	task.delay(0.8, function()
		pcall(function()
			p1:Destroy();
			p2:Destroy()
		end)
	end)
end
task.spawn(function()
	while true do
		if RageConfig.enabled and PlayerEvent then
			local _, _, myRoot = GetCharacter(LocalPlayer)
			if myRoot then
				EquipWeapon()
				local myPos = myRoot.Position
				local myJob = GetPlayerJob(LocalPlayer)
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= LocalPlayer and targetAllowed(player, RageConfig.policeLock, RageConfig.civilianLock) and inCombat(player, RageConfig.combatCheck) then
						local char, hum, root = GetCharacter(player)
						if char and hum and root and hum.Health > 0 then
							if RageConfig.jobCheck and GetPlayerJob(player) == myJob then
								continue
							end
							if (root.Position - myPos).Magnitude <= RageConfig.range then
								if RageConfig.wallCheck then
									local params = RaycastParams.new()
									params.FilterDescendantsInstances = {
										LocalPlayer.Character,
										Workspace.CurrentCamera
									}
									params.FilterType = Enum.RaycastFilterType.Exclude
									local hit = Workspace:Raycast(Workspace.CurrentCamera.CFrame.Position, root.Position - Workspace.CurrentCamera.CFrame.Position, params)
									if hit and not hit.Instance:IsDescendantOf(char) then
										continue
									end
								end
								pcall(function()
									PlayerEvent:FireServer("damage", {
										bodyParts = {
											{
												RageConfig.bodyPart,
												1
											}
										},
										shotCode = {
											myPos,
											(root.Position - myPos).Unit
										},
										pos = root.Position,
										target = player,
										damageFactor = 1.5,
										bulletProofTool = false,
									})
									if RageConfig.beam then
										createBeam(myPos, root.Position)
									end
								end)
							end
						end
					end
				end
			end
		end
		task.wait(RageConfig.interval)
	end
end)
local HitboxConfig = {
	active = false,
	size = 10,
	transparency = 0.7,
	teamCheck = false,
	color = "红色",
	material = "Neon",
	rainbow = false,
	checkCorpses = false,
	outline = false,
	collision = false,
	glow = false,
	pulse = false,
	affectNPC = false,
}
local hitboxOriginal = {}
local function resetHitbox(char)
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local orig = hitboxOriginal[root]
	if orig then
		root.Size = orig.Size
		root.Transparency = orig.Transparency
		root.Material = orig.Material
		root.CanCollide = orig.CanCollide
		root.Color = orig.Color
	end
	local h = root:FindFirstChild("PY_HitboxHighlight")
	if h then
		h:Destroy()
	end
	local l = root:FindFirstChild("PY_HitboxLight")
	if l then
		l:Destroy()
	end
end
local function applyHitbox(char)
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	if not hitboxOriginal[root] then
		hitboxOriginal[root] = {
			Size = root.Size,
			Transparency = root.Transparency,
			Material = root.Material,
			CanCollide = root.CanCollide,
			Color = root.Color
		}
	end
	if not HitboxConfig.active then
		resetHitbox(char);
		return
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if HitboxConfig.checkCorpses and hum and hum.Health <= 0 then
		resetHitbox(char);
		return
	end
	local size = HitboxConfig.size
	if HitboxConfig.pulse then
		size = size * (math.sin(tick() * 2) * 0.2 + 1)
	end
	root.Size = Vector3.new(size, size, size)
	root.Transparency = HitboxConfig.transparency
	root.Material = Enum.Material[HitboxConfig.material] or Enum.Material.Neon
	root.CanCollide = HitboxConfig.collision
	root.Color = HitboxConfig.rainbow and GetRainbowColor(5) or GetColor(HitboxConfig.color)
	if HitboxConfig.outline then
		local hl = root:FindFirstChild("PY_HitboxHighlight") or Instance.new("Highlight")
		hl.Name = "PY_HitboxHighlight"
		hl.FillTransparency = 1
		hl.OutlineColor = root.Color
		hl.OutlineTransparency = HitboxConfig.transparency
		hl.Parent = root
	else
		local hl = root:FindFirstChild("PY_HitboxHighlight")
		if hl then
			hl:Destroy()
		end
	end
	if HitboxConfig.glow then
		local light = root:FindFirstChild("PY_HitboxLight") or Instance.new("PointLight")
		light.Name = "PY_HitboxLight"
		light.Brightness = 5
		light.Range = 15
		light.Color = root.Color
		light.Parent = root
	else
		local light = root:FindFirstChild("PY_HitboxLight")
		if light then
			light:Destroy()
		end
	end
end
RunService.Heartbeat:Connect(function()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			if HitboxConfig.teamCheck and LocalPlayer.Team and player.Team == LocalPlayer.Team then
				resetHitbox(player.Character)
			else
				applyHitbox(player.Character)
			end
		end
	end
	if HitboxConfig.affectNPC then
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
				applyHitbox(obj)
			end
		end
	end
end)
local ESP = {
	enabled = false,
	name = true,
	distance = true,
	health = true,
	highlight = true,
	tracer = false,
	tracerOrigin = "屏幕底部",
	maxDistance = 10000,
	showFugitive = true,
	selectedTeams = {},
	trackers = {},
}
local TeamNames = {
	Chef = "厨师", Civilian = "平民", Delivery = "配送员", Farmer = "农民", Fire = "消防员",
	Police = "警察", Medical = "医护人员", Prisoner = "囚犯", ["Road Service"] = "道路服务", Transit = "交通"
}
local TeamColors = {
	Chef = Color3.fromRGB(255, 200, 0), Civilian = Color3.fromRGB(100, 200, 255), Delivery = Color3.fromRGB(255, 150, 50),
	Farmer = Color3.fromRGB(50, 200, 50), Fire = Color3.fromRGB(255, 50, 50), Police = Color3.fromRGB(50, 100, 255),
	Medical = Color3.fromRGB(255, 50, 255), Prisoner = Color3.fromRGB(255, 150, 150), ["Road Service"] = Color3.fromRGB(255, 255, 100), Transit = Color3.fromRGB(100, 255, 255)
}
local function isFugitive(player)
	return player.Team and player.Team.Name == "Civilian" and (player:GetAttribute("CombatMode") or player:GetAttribute("Pursuit"))
end
local function espAllowed(player)
	if not (ESP.enabled and player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then return false end
	local _, _, myRoot = GetCharacter(LocalPlayer)
	local root = player.Character:FindFirstChild("HumanoidRootPart")
	if myRoot and root and (myRoot.Position - root.Position).Magnitude > (tonumber(ESP.maxDistance) or 10000) then return false end
	return true
end
local function removeESP(player)
	local t = ESP.trackers[player]
	if not t then return end
	if t.connections then for _, c in ipairs(t.connections) do pcall(function() c:Disconnect() end) end end
	if t.bill then pcall(function() t.bill:Destroy() end) end
	if t.highlight then pcall(function() t.highlight:Destroy() end) end
	if t.box then pcall(function() t.box:Destroy() end) end
	ESP.trackers[player] = nil
end
local function createESP(player)
	removeESP(player)
	if not espAllowed(player) then return end
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
	if not playerGui then return end

	-- 使用 Roblox 原生 Highlight + BillboardGui，避免旧 Drawing/GuiParent 在部分执行环境中不显示。
	local highlight = Instance.new("Highlight")
	highlight.Name = "AioveESP_Highlight_" .. player.UserId
	highlight.Adornee = char
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillTransparency = 0.78
	highlight.OutlineTransparency = 0
	highlight.Parent = char

	local bill = Instance.new("BillboardGui")
	bill.Name = "AioveESP_Label_" .. player.UserId
	bill.AlwaysOnTop = true
	bill.MaxDistance = 10000
	bill.Size = UDim2.fromOffset(220, 58)
	bill.StudsOffsetWorldSpace = Vector3.new(0, 3.5, 0)
	bill.Adornee = root
	bill.Parent = playerGui

	local name = Instance.new("TextLabel")
	name.BackgroundTransparency = 1
	name.Size = UDim2.new(1, 0, 0, 26)
	name.Font = Enum.Font.GothamBold
	name.TextSize = 14
	name.TextStrokeTransparency = 0.15
	name.Parent = bill
	local info = Instance.new("TextLabel")
	info.BackgroundTransparency = 1
	info.Position = UDim2.fromOffset(0, 25)
	info.Size = UDim2.new(1, 0, 0, 25)
	info.Font = Enum.Font.Gotham
	info.TextSize = 12
	info.TextStrokeTransparency = 0.15
	info.Parent = bill

	local box = Instance.new("BoxHandleAdornment")
	box.Name = "AioveESP_Box_" .. player.UserId
	box.Adornee = root
	box.AlwaysOnTop = true
	box.ZIndex = 5
	box.Transparency = 0.82
	box.Size = Vector3.new(4, 6, 2)
	box.Parent = root

	local connections = {}
	table.insert(connections, player.CharacterAdded:Connect(function()
		if ESP.enabled then
			task.wait(0.15)
			createESP(player)
		end
	end))
	ESP.trackers[player] = {bill=bill, highlight=highlight, box=box, nameLabel=name, infoLabel=info, connections=connections}
end
local function refreshESP()
	for player in pairs(ESP.trackers) do
		if not espAllowed(player) then removeESP(player) end
	end
	if not ESP.enabled then return end
	for _, player in ipairs(Players:GetPlayers()) do
		if espAllowed(player) and not ESP.trackers[player] then createESP(player) end
	end
end
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		if ESP.enabled then task.wait(0.15); createESP(player) end
	end)
end)
Players.PlayerRemoving:Connect(removeESP)
local espAccumulator = 0
RunService.Heartbeat:Connect(function(dt)
	if not ESP.enabled then return end
	espAccumulator += dt
	if espAccumulator < 0.12 then return end
	espAccumulator = 0
	for player, t in pairs(ESP.trackers) do
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not root or not hum or hum.Health <= 0 then
			if t.bill then t.bill.Enabled = false end
			if t.highlight then t.highlight.Enabled = false end
			if t.box then t.box.Visible = false end
		else
			local fug = ESP.showFugitive and isFugitive(player)
			local team = player.Team and player.Team.Name
			local color = fug and Color3.fromRGB(255, 60, 60) or TeamColors[team] or Color3.fromRGB(0, 255, 120)
			local teamName = fug and "逃犯" or TeamNames[team] or (team or "未知")
			local _, _, myRoot = GetCharacter(LocalPlayer)
			local distance = myRoot and math.floor((myRoot.Position - root.Position).Magnitude) or 0
			if t.bill then
				t.bill.Enabled = ESP.name or ESP.distance or ESP.health
				local n = t.nameLabel
				local inf = t.infoLabel
				if n then n.Text = "["..teamName.."] "..player.DisplayName; n.TextColor3=color; n.Visible=ESP.name end
				if inf then
					local parts={}
					if ESP.distance then parts[#parts+1]=distance.."m" end
					if ESP.health then parts[#parts+1]=math.floor(hum.Health).." HP" end
					inf.Text=table.concat(parts,"  "); inf.TextColor3=color; inf.Visible=(#parts>0)
				end
			end
			if t.highlight then t.highlight.FillColor=color; t.highlight.OutlineColor=color; t.highlight.Enabled=ESP.highlight end
			if t.box then t.box.Color3=color; t.box.Visible=ESP.highlight end
		end
	end
	refreshESP()
end)
local PoliceConfig = {
	range = 200,
	delay = 0.5,
	combatCheck = false,
	teleport = false
}
local autoCuffThread
local function startAutoCuff()
	if autoCuffThread then
		return
	end
	autoCuffThread = task.spawn(function()
		while State.autoCuff do
			local _, _, myRoot = GetCharacter(LocalPlayer)
			if myRoot and PlayerFunc then
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= LocalPlayer and IsAlive(player) and inCombat(player, PoliceConfig.combatCheck) then
						local _, _, root = GetCharacter(player)
						if root and (root.Position - myRoot.Position).Magnitude <= PoliceConfig.range then
							pcall(function()
								PlayerFunc:InvokeServer("handcuff", player, false)
							end)
						end
					end
				end
				if PoliceConfig.teleport then
					local nearest, nearestDist
					for _, player in ipairs(Players:GetPlayers()) do
						if player ~= LocalPlayer and player.Team and player.Team.Name == "Civilian" and (player:GetAttribute("WantedLevel") or 0) > 0 then
							local _, _, root = GetCharacter(player)
							if root then
								local d = (root.Position - myRoot.Position).Magnitude
								if d <= PoliceConfig.range and (not nearestDist or d < nearestDist) then
									nearest, nearestDist = player, d
								end
							end
						end
					end
					if nearest then
						local _, _, targetRoot = GetCharacter(nearest)
						if targetRoot then
							myRoot.CFrame = CFrame.new(targetRoot.Position - targetRoot.CFrame.LookVector * 3)
						end
					end
				end
			end
			task.wait(PoliceConfig.delay)
		end
		autoCuffThread = nil
	end)
end


-- ============================================================
-- 玩家功能
-- ============================================================
local PlayerConfig = {
	walkEnabled = false,
	walkSpeed = 200,
	jumpEnabled = false,
	jumpPower = 50,
	jumpMultiplier = 1,
	infiniteJump = false,
	flyEnabled = false,
	flySpeed = 30,
	flyVersion = "飞行 V1",
	flyMode = "物理",
	noclip = false,
}
local PlayerRuntime = {
	walkConn = nil,
	jumpConn = nil,
	flyConn = nil,
	bodyVelocity = nil,
	bodyGyro = nil,
	noclipConn = nil,
	collisionCache = {},
}
local playerQuickGui
local playerQuickButton
local playerQuickUpButton
local playerQuickDownButton
local playerQuickPanelVertical = 0
local playerQuickShown = false
local noclipQuickShown = false
local noclipQuickGui, noclipQuickButton, noclipQuickRainbow
local noclipQuickPos = UDim2.new(0, 20, 0.5, 45)
local playerQuickLocked = false
local playerQuickPos = UDim2.new(0, 100, 0.5, - 25)
local playerQuickRainbow
local playerFlyToggle
local PlayerControls = nil
pcall(function()
	PlayerControls = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
end)
local function stopWalkLoop()
	if PlayerRuntime.walkConn then
		PlayerRuntime.walkConn:Disconnect()
		PlayerRuntime.walkConn = nil
	end
end
local function startWalkLoop()
	stopWalkLoop()
	if not PlayerConfig.walkEnabled then
		return
	end
	PlayerRuntime.walkConn = RunService.Heartbeat:Connect(function()
		local _, hum = GetCharacter(LocalPlayer)
		if hum and PlayerConfig.walkEnabled then
			hum.WalkSpeed = PlayerConfig.walkSpeed
		end
	end)
end
local function isGrounded(hum)
	if not hum then
		return false
	end
	local state = hum:GetState()
	return state == Enum.HumanoidStateType.Landed or state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.RunningNoPhysics
end
local function stopJumpHandler()
	if PlayerRuntime.jumpConn then
		PlayerRuntime.jumpConn:Disconnect()
		PlayerRuntime.jumpConn = nil
	end
end
local function startJumpHandler()
	stopJumpHandler()
	if not PlayerConfig.jumpEnabled then
		return
	end
	PlayerRuntime.jumpConn = UserInputService.JumpRequest:Connect(function()
		if not PlayerConfig.jumpEnabled then
			return
		end
		local _, hum, root = GetCharacter(LocalPlayer)
		if not hum or not root or hum.Health <= 0 then
			return
		end
		if not PlayerConfig.infiniteJump and not isGrounded(hum) then
			return
		end
		local height = PlayerConfig.jumpPower * PlayerConfig.jumpMultiplier * 0.1
		root.CFrame = root.CFrame + Vector3.new(0, height, 0)
	end)
end
local function clearPhysicalFly()
	if PlayerRuntime.flyConn then
		PlayerRuntime.flyConn:Disconnect()
		PlayerRuntime.flyConn = nil
	end
	if PlayerRuntime.bodyVelocity then
		PlayerRuntime.bodyVelocity:Destroy()
		PlayerRuntime.bodyVelocity = nil
	end
	if PlayerRuntime.bodyGyro then
		PlayerRuntime.bodyGyro:Destroy()
		PlayerRuntime.bodyGyro = nil
	end
	local _, hum = GetCharacter(LocalPlayer)
	if hum then
		hum.PlatformStand = false
		hum.AutoRotate = true
	end
end

local function clearWarpFly()
	if PlayerRuntime.flyConn then
		PlayerRuntime.flyConn:Disconnect()
		PlayerRuntime.flyConn = nil
	end
	local _, hum = GetCharacter(LocalPlayer)
	if hum then
		hum.AutoRotate = true
	end
end

local function updatePlayerQuick()
	if not playerQuickButton then return end
	playerQuickButton.Text = PlayerConfig.flyEnabled and "飞行 V1: 开" or "飞行 V1: 关"
	playerQuickButton.TextColor3 = PlayerConfig.flyEnabled and Color3.fromRGB(0,255,120) or Color3.fromRGB(255,120,120)
end

local function stopPlayerFly()
	-- 先关闭飞行状态，再清理物理控制，避免结束飞行后 Humanoid 仍保持僵直。
	PlayerConfig.flyEnabled = false
	playerQuickPanelVertical = 0
	clearPhysicalFly()
	clearWarpFly()
	local _, hum = GetCharacter(LocalPlayer)
	if hum then
		hum.PlatformStand = false
		hum.AutoRotate = true
		pcall(function() hum.Sit = false end)
		pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
		task.defer(function()
			if hum.Parent and hum.Health > 0 then
				pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
			end
		end)
	end
	updatePlayerQuick()
end

-- V1：保留悬浮控制面板；摇杆负责前后左右，上/下由面板按钮控制。
local function startFlightV1()
	clearWarpFly()
	clearPhysicalFly()
	local _, hum, root = GetCharacter(LocalPlayer)
	if not root or not hum then return end

	PlayerConfig.flyEnabled = true
	hum.PlatformStand = true
	hum.AutoRotate = false

	local bv = Instance.new("BodyVelocity")
	bv.Name = "AioveFlightV1Velocity"
	bv.MaxForce = Vector3.new(9e9,9e9,9e9)
	bv.P = 50000
	bv.Velocity = Vector3.zero
	bv.Parent = root
	PlayerRuntime.bodyVelocity = bv

	local bg = Instance.new("BodyGyro")
	bg.Name = "AioveFlightV1Gyro"
	bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
	bg.P = 9e4
	bg.D = 1000
	bg.CFrame = root.CFrame
	bg.Parent = root
	PlayerRuntime.bodyGyro = bg

	PlayerRuntime.flyConn = RunService.RenderStepped:Connect(function()
		if not PlayerConfig.flyEnabled or PlayerConfig.flyVersion ~= "飞行 V1" then return end
		local _, currentHum, currentRoot = GetCharacter(LocalPlayer)
		local cam = Workspace.CurrentCamera
		if not currentRoot or not currentHum or not cam or not PlayerRuntime.bodyVelocity then return end

		local move = PlayerControls and PlayerControls:GetMoveVector() or Vector3.zero
		local horizontal = cam.CFrame.RightVector * move.X + cam.CFrame.LookVector * (-move.Z)
		horizontal = Vector3.new(horizontal.X,0,horizontal.Z)
		if horizontal.Magnitude > 1 then horizontal = horizontal.Unit end

		local velocity = horizontal * PlayerConfig.flySpeed
		velocity += Vector3.new(0, playerQuickPanelVertical * PlayerConfig.flySpeed, 0)
		PlayerRuntime.bodyVelocity.Velocity = velocity

		local look = cam.CFrame.LookVector
		local flatLook = Vector3.new(look.X,0,look.Z)
		if flatLook.Magnitude > 0.05 and PlayerRuntime.bodyGyro then
			PlayerRuntime.bodyGyro.CFrame = CFrame.lookAt(currentRoot.Position, currentRoot.Position + flatLook.Unit, Vector3.yAxis)
		end
	end)
	updatePlayerQuick()
end

-- V2：不使用控制面板，直接使用手机摇杆；镜头俯仰决定上升/下降。
local function startFlightV2()
	clearPhysicalFly()
	clearWarpFly()
	local _, hum, root = GetCharacter(LocalPlayer)
	if not root or not hum then return end

	PlayerConfig.flyEnabled = true
	hum.AutoRotate = false

	PlayerRuntime.flyConn = RunService.RenderStepped:Connect(function(dt)
		if not PlayerConfig.flyEnabled or PlayerConfig.flyVersion ~= "飞行 V2" then return end
		local _, currentHum, currentRoot = GetCharacter(LocalPlayer)
		local cam = Workspace.CurrentCamera
		if not currentRoot or not currentHum or not cam then return end

		-- V2：直接读取手机摇杆输入，并把摄像机俯仰纳入前后方向。
		-- 这样前推摇杆 + 抬头就是上升，前推摇杆 + 低头就是下降。
		local move = PlayerControls and PlayerControls:GetMoveVector() or Vector3.zero
		local direction = Vector3.zero
		if move.Magnitude > 0.01 then
			local look = cam.CFrame.LookVector
			local right = cam.CFrame.RightVector
			direction = right * move.X + look * (-move.Z)
			if direction.Magnitude > 1 then direction = direction.Unit end
		else
			-- PlayerModule 尚未就绪时使用 Humanoid.MoveDirection 作为回退。
			local worldMove = currentHum.MoveDirection
			if worldMove.Magnitude > 0.01 then
				direction = worldMove.Unit
			end
		end

		if direction.Magnitude > 0.01 then
			direction = direction.Unit
			local delta = direction * PlayerConfig.flySpeed * dt
			currentRoot.CFrame = currentRoot.CFrame + delta
		end
		currentRoot.AssemblyLinearVelocity = Vector3.zero
		currentRoot.AssemblyAngularVelocity = Vector3.zero
		currentHum.PlatformStand = false
		currentHum.AutoRotate = false
		currentHum:ChangeState(Enum.HumanoidStateType.Physics)
	end)
	updatePlayerQuick()
end

local destroyPlayerQuick
local playerV2QuickShown = false
local playerV2QuickGui = nil
local playerV2QuickButton = nil
local playerV2QuickPos = UDim2.new(0,20,0.55,0)
local createPlayerV2Quick
local destroyPlayerV2Quick
local updatePlayerV2Quick

local function startPlayerFly()
	if PlayerConfig.flyVersion == "飞行 V2" then
		if destroyPlayerQuick then destroyPlayerQuick() end
		startFlightV2()
		if playerV2QuickShown then createPlayerV2Quick() end
		task.defer(updatePlayerV2Quick)
	else
		destroyPlayerV2Quick()
		startFlightV1()
		if playerQuickShown then createPlayerQuick() end
	end
end

destroyPlayerQuick = function()
	if playerQuickRainbow then playerQuickRainbow:Disconnect(); playerQuickRainbow=nil end
	if playerQuickGui then playerQuickGui:Destroy(); playerQuickGui=nil end
	playerQuickButton=nil
	playerQuickUpButton=nil
	playerQuickDownButton=nil
end

destroyPlayerV2Quick = function()
	if playerV2QuickGui then
		playerV2QuickGui:Destroy()
		playerV2QuickGui=nil
	end
	playerV2QuickButton=nil
end

updatePlayerV2Quick = function()
	if not playerV2QuickButton then return end
	playerV2QuickButton.Text = PlayerConfig.flyEnabled and "飞行 V2：开" or "飞行 V2：关"
	playerV2QuickButton.TextColor3 = PlayerConfig.flyEnabled and Color3.fromRGB(0,255,120) or Color3.fromRGB(255,120,120)
end

createPlayerV2Quick = function()
	destroyPlayerV2Quick()
	if not playerV2QuickShown then return end
	playerV2QuickGui=Instance.new("ScreenGui")
	playerV2QuickGui.Name="PlayerFlyV2Control"
	playerV2QuickGui.ResetOnSpawn=false
	playerV2QuickGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
	playerV2QuickGui.Parent=UI_PARENT or resolveGuiParent()
	local panel=Instance.new("Frame")
	panel.Size=UDim2.new(0,118,0,48)
	panel.Position=playerV2QuickPos
	panel.BackgroundColor3=Color3.fromRGB(20,20,20)
	panel.BackgroundTransparency=0.18
	panel.BorderSizePixel=0
	panel.Active=true
	panel.Draggable=not playerQuickLocked
	panel.Parent=playerV2QuickGui
	local pc=Instance.new("UICorner",panel); pc.CornerRadius=UDim.new(0,12)
	local ps=Instance.new("UIStroke",panel); ps.Thickness=1.5
	playerV2QuickButton=Instance.new("TextButton")
	playerV2QuickButton.Size=UDim2.new(1,-12,1,-12)
	playerV2QuickButton.Position=UDim2.new(0,6,0,6)
	playerV2QuickButton.BackgroundColor3=Color3.fromRGB(35,35,35)
	playerV2QuickButton.BorderSizePixel=0
	playerV2QuickButton.Font=Enum.Font.GothamSemibold
	playerV2QuickButton.TextSize=12
	playerV2QuickButton.Parent=panel
	local bc=Instance.new("UICorner",playerV2QuickButton); bc.CornerRadius=UDim.new(0,8)
	playerV2QuickButton.MouseButton1Click:Connect(function()
		PlayerConfig.flyVersion="飞行 V2"
		if PlayerConfig.flyEnabled then stopPlayerFly() else startPlayerFly() end
		updatePlayerV2Quick()
	end)
	panel:GetPropertyChangedSignal("Position"):Connect(function()
		if not playerQuickLocked then playerV2QuickPos=panel.Position end
	end)
	updatePlayerV2Quick()
end

local function createPlayerQuick()
	destroyPlayerQuick()
	if PlayerConfig.flyVersion ~= "飞行 V1" then return end
	if not playerQuickShown then return end

	playerQuickGui=Instance.new("ScreenGui")
	playerQuickGui.Name="PlayerFlyV1Control"
	playerQuickGui.ResetOnSpawn=false
	playerQuickGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
	playerQuickGui.Parent=UI_PARENT or resolveGuiParent()

	local panel=Instance.new("Frame")
	panel.Size=UDim2.new(0,118,0,92)
	panel.Position=playerQuickPos
	panel.BackgroundColor3=Color3.fromRGB(20,20,20)
	panel.BackgroundTransparency=0.18
	panel.BorderSizePixel=0
	panel.Active=true
	panel.Draggable=not playerQuickLocked
	panel.Parent=playerQuickGui

	local panelCorner=Instance.new("UICorner")
	panelCorner.CornerRadius=UDim.new(0,12)
	panelCorner.Parent=panel

	local panelStroke=Instance.new("UIStroke")
	panelStroke.Thickness=1.5
	panelStroke.Parent=panel

	playerQuickButton=Instance.new("TextButton")
	playerQuickButton.Size=UDim2.new(1,-12,0,30)
	playerQuickButton.Position=UDim2.new(0,6,0,6)
	playerQuickButton.BackgroundColor3=Color3.fromRGB(35,35,35)
	playerQuickButton.BorderSizePixel=0
	playerQuickButton.Font=Enum.Font.GothamSemibold
	playerQuickButton.TextSize=12
	playerQuickButton.Parent=panel
	local bc=Instance.new("UICorner",playerQuickButton); bc.CornerRadius=UDim.new(0,8)

	playerQuickUpButton=Instance.new("TextButton")
	playerQuickUpButton.Size=UDim2.new(0.5,-8,0,34)
	playerQuickUpButton.Position=UDim2.new(0,6,0,48)
	playerQuickUpButton.Text="▲ 上升"
	playerQuickUpButton.BackgroundColor3=Color3.fromRGB(30,80,55)
	playerQuickUpButton.BorderSizePixel=0
	playerQuickUpButton.Font=Enum.Font.GothamSemibold
	playerQuickUpButton.TextSize=12
	playerQuickUpButton.Parent=panel
	local uc=Instance.new("UICorner",playerQuickUpButton); uc.CornerRadius=UDim.new(0,8)

	playerQuickDownButton=Instance.new("TextButton")
	playerQuickDownButton.Size=UDim2.new(0.5,-8,0,34)
	playerQuickDownButton.Position=UDim2.new(0.5,2,0,48)
	playerQuickDownButton.Text="▼ 下降"
	playerQuickDownButton.BackgroundColor3=Color3.fromRGB(80,45,45)
	playerQuickDownButton.BorderSizePixel=0
	playerQuickDownButton.Font=Enum.Font.GothamSemibold
	playerQuickDownButton.TextSize=12
	playerQuickDownButton.Parent=panel
	local dc=Instance.new("UICorner",playerQuickDownButton); dc.CornerRadius=UDim.new(0,8)

	playerQuickRainbow=RunService.RenderStepped:Connect(function()
		if panelStroke.Parent then panelStroke.Color=GetRainbowColor(5) end
	end)

	updatePlayerQuick()

	playerQuickButton.MouseButton1Click:Connect(function()
		if PlayerConfig.flyEnabled then stopPlayerFly() else startPlayerFly() end
		if playerFlyToggle and type(playerFlyToggle.SetState)=="function" then
			pcall(function() playerFlyToggle:SetState(PlayerConfig.flyEnabled) end)
		end
	end)

	local function bindVertical(button,value)
		button.MouseButton1Down:Connect(function() playerQuickPanelVertical=value end)
		button.MouseButton1Up:Connect(function() if playerQuickPanelVertical==value then playerQuickPanelVertical=0 end end)
		button.InputEnded:Connect(function(input)
			if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
				if playerQuickPanelVertical==value then playerQuickPanelVertical=0 end
			end
		end)
	end
	bindVertical(playerQuickUpButton,1)
	bindVertical(playerQuickDownButton,-1)

	panel:GetPropertyChangedSignal("Position"):Connect(function()
		if not playerQuickLocked then playerQuickPos=panel.Position end
	end)
end

local noclipPartConnections = {}
local function applyNoclipPart(part)
	if not part or not part:IsA("BasePart") then return end
	if PlayerRuntime.collisionCache[part] == nil then
		PlayerRuntime.collisionCache[part] = part.CanCollide
	end
	part.CanCollide = false
end
local function restoreNoclip()
	for part, old in pairs(PlayerRuntime.collisionCache) do
		if part and part.Parent then
			pcall(function() part.CanCollide = old end)
		end
	end
	PlayerRuntime.collisionCache = {}
	for _, c in ipairs(noclipPartConnections) do pcall(function() c:Disconnect() end) end
	table.clear(noclipPartConnections)
end
local function stopNoclip()
	PlayerRuntime.noclipConn = nil
	restoreNoclip()
end
local function startNoclip()
	stopNoclip()
	if not PlayerConfig.noclip then return end
	local char = LocalPlayer.Character
	if not char then return end
	for _, part in ipairs(char:GetDescendants()) do applyNoclipPart(part) end
	table.insert(noclipPartConnections, char.DescendantAdded:Connect(applyNoclipPart))
	-- 仅在物理状态可能被游戏脚本改回时低频校正，不再每帧遍历整个角色。
	PlayerRuntime.noclipConn = task.spawn(function()
		while PlayerConfig.noclip and LocalPlayer.Character == char and char.Parent do
			task.wait(0.25)
			for part in pairs(PlayerRuntime.collisionCache) do
				if part and part.Parent and part.CanCollide then part.CanCollide = false end
			end
		end
	end)
end
LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.5)
	PlayerRuntime.collisionCache = {}
	if PlayerConfig.walkEnabled then
		startWalkLoop()
	end
	if PlayerConfig.jumpEnabled then
		startJumpHandler()
	end
	if PlayerConfig.noclip then
		startNoclip()
	end
	if PlayerConfig.flyEnabled then
		local version = PlayerConfig.flyVersion
		PlayerConfig.flyEnabled = false
		task.wait(0.2)
		PlayerConfig.flyVersion = version
		startPlayerFly()
	end
end)
local function updateNoclipQuick()
	if not noclipQuickButton then return end
	noclipQuickButton.Text = PlayerConfig.noclip and "穿墙: 开" or "穿墙: 关"
	noclipQuickButton.TextColor3 = PlayerConfig.noclip and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 120, 120)
end
local function destroyNoclipQuick()
	if noclipQuickRainbow then noclipQuickRainbow:Disconnect(); noclipQuickRainbow=nil end
	if noclipQuickGui then noclipQuickGui:Destroy(); noclipQuickGui=nil; noclipQuickButton=nil end
end
local function createNoclipQuick()
	destroyNoclipQuick()
	if not noclipQuickShown then return end
	noclipQuickGui=Instance.new("ScreenGui")
	noclipQuickGui.Name="NoclipQuickSwitch"
	noclipQuickGui.ResetOnSpawn=false
	noclipQuickGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
	noclipQuickGui.Parent=UI_PARENT or resolveGuiParent()
	noclipQuickButton=Instance.new("TextButton")
	noclipQuickButton.Size=UDim2.new(0,80,0,35)
	noclipQuickButton.Position=noclipQuickPos
	noclipQuickButton.BackgroundColor3=Color3.fromRGB(20,20,20)
	noclipQuickButton.BackgroundTransparency=0.4
	noclipQuickButton.BorderSizePixel=0
	noclipQuickButton.Font=Enum.Font.GothamSemibold
	noclipQuickButton.TextSize=12
	noclipQuickButton.Active=true
	noclipQuickButton.Draggable=true
	noclipQuickButton.Parent=noclipQuickGui
	local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,8); corner.Parent=noclipQuickButton
	local stroke=Instance.new("UIStroke"); stroke.Thickness=1.5; stroke.Parent=noclipQuickButton
	noclipQuickRainbow=RunService.RenderStepped:Connect(function()
		if stroke.Parent then stroke.Color=GetRainbowColor(5) end
	end)
	updateNoclipQuick()
	noclipQuickButton.MouseButton1Click:Connect(function()
		PlayerConfig.noclip=not PlayerConfig.noclip
		if PlayerConfig.noclip then startNoclip() else stopNoclip() end
		updateNoclipQuick()
		if noclipToggle and type(noclipToggle.SetState)=="function" then pcall(function() noclipToggle:SetState(PlayerConfig.noclip) end) end
	end)
	noclipQuickButton:GetPropertyChangedSignal("Position"):Connect(function() noclipQuickPos=noclipQuickButton.Position end)
end

local VehicleFly = {
	active = false,
	speed = 80,
	version = "飞车 V2",
	bv = nil,
	bg = nil,
	conn = nil,
	root = nil,
	lastVelocity = Vector3.zero,
}
local vehicleQuickGui
local vehicleQuickButton
local vehicleQuickShown = false
local vehicleQuickLocked = false
local vehicleQuickPos = UDim2.new(0, 10, 0.5, -25)
local vehicleQuickRainbow

local function updateVehicleQuick()
	if vehicleQuickButton then
		vehicleQuickButton.Text = VehicleFly.active and (VehicleFly.version .. ": 开") or (VehicleFly.version .. ": 关")
		vehicleQuickButton.TextColor3 = VehicleFly.active and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 120, 120)
	end
end

local function getVehicleRoot()
	local _, hum, charRoot = GetCharacter(LocalPlayer)
	-- 优先使用当前座位所属车辆；不再把“必须坐进车位”作为启动条件。
	if hum and hum.SeatPart and hum.SeatPart:IsA("BasePart") then
		local seat = hum.SeatPart
		local model = seat:FindFirstAncestorOfClass("Model")
		if model then
			if model.PrimaryPart and model.PrimaryPart:IsA("BasePart") then return model.PrimaryPart end
			if seat.AssemblyRootPart then return seat.AssemblyRootPart end
		end
		return seat.AssemblyRootPart or seat
	end
	-- 未坐车时：自动寻找玩家附近最合理的车辆模型。
	if charRoot then
		local nearest, nearestDist
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("Model") and obj ~= charRoot.Parent then
				local seat = obj:FindFirstChildWhichIsA("VehicleSeat", true) or obj:FindFirstChildWhichIsA("Seat", true)
				local root = obj.PrimaryPart or (seat and seat:IsA("BasePart") and seat.AssemblyRootPart)
				if root and root:IsA("BasePart") and not root.Anchored then
					local d=(root.Position-charRoot.Position).Magnitude
					if d <= 80 and (not nearestDist or d < nearestDist) then nearest,nearestDist=root,d end
				end
			end
		end
		if nearest then return nearest end
		-- 找不到车辆时退回角色根部，保证按钮不会因座位检测直接失效。
		return charRoot
	end
	return nil
end
local function stopVehicleFly()
	VehicleFly.active = false
	if VehicleFly.conn then VehicleFly.conn:Disconnect(); VehicleFly.conn = nil end
	if VehicleFly.bv then VehicleFly.bv:Destroy(); VehicleFly.bv = nil end
	if VehicleFly.bg then VehicleFly.bg:Destroy(); VehicleFly.bg = nil end
	VehicleFly.root = nil
	VehicleFly.lastVelocity = Vector3.zero
	updateVehicleQuick()
end
local function vehicleFlyV1Step(root, cam)
	local look=cam.CFrame.LookVector
	local flat=Vector3.new(look.X,0,look.Z)
	if flat.Magnitude<0.05 then flat=root.CFrame.LookVector end
	flat=flat.Unit
	local vertical=math.clamp(look.Y,-0.75,0.75)*VehicleFly.speed
	return flat*VehicleFly.speed+Vector3.new(0,vertical,0),CFrame.lookAt(root.Position,root.Position+flat,Vector3.yAxis)
end
local function vehicleFlyV2Step(root, cam)
	local direction=cam.CFrame.LookVector
	if direction.Magnitude<0.05 then direction=root.CFrame.LookVector end
	return direction.Unit*VehicleFly.speed,CFrame.lookAt(root.Position,root.Position+Vector3.new(direction.X,0,direction.Z),Vector3.yAxis)
end
local function vehicleFlyV3Step(root, cam)
	local direction=cam.CFrame.LookVector
	if direction.Magnitude<0.05 then direction=root.CFrame.LookVector end
	direction=direction.Unit
	local target=direction*VehicleFly.speed
	local alpha=math.clamp(0.12+VehicleFly.speed/2000,0.12,0.25)
	VehicleFly.lastVelocity=VehicleFly.lastVelocity:Lerp(target,alpha)
	local flat=Vector3.new(direction.X,0,direction.Z)
	if flat.Magnitude<0.05 then flat=root.CFrame.LookVector end
	return VehicleFly.lastVelocity,CFrame.lookAt(root.Position,root.Position+flat.Unit,Vector3.yAxis)
end
local function startVehicleFly()
	local root=getVehicleRoot()
	if not root then
		pcall(function() WindUI:Notify({Title="飞车",Content="附近没有可控制的车辆/物体",Duration=2.5}) end)
		return
	end
	stopVehicleFly()
	VehicleFly.active=true; VehicleFly.root=root; VehicleFly.lastVelocity=Vector3.zero
	VehicleFly.bv=Instance.new("BodyVelocity")
	VehicleFly.bv.Name="AioveVehicleFlyVelocity"
	VehicleFly.bv.MaxForce=Vector3.new(1e9,1e9,1e9); VehicleFly.bv.P=50000; VehicleFly.bv.Velocity=Vector3.zero; VehicleFly.bv.Parent=root
	VehicleFly.bg=Instance.new("BodyGyro")
	VehicleFly.bg.Name="AioveVehicleFlyGyro"
	VehicleFly.bg.MaxTorque=Vector3.new(1e9,1e9,1e9); VehicleFly.bg.P=50000; VehicleFly.bg.D=1000; VehicleFly.bg.CFrame=root.CFrame; VehicleFly.bg.Parent=root
	VehicleFly.conn=RunService.Heartbeat:Connect(function()
		if not VehicleFly.active or not VehicleFly.bv or not VehicleFly.bg then return end
		local currentRoot=VehicleFly.root
		if not currentRoot or not currentRoot.Parent then stopVehicleFly(); return end
		local cam=Workspace.CurrentCamera
		if not cam then return end
		local velocity,rotation
		if VehicleFly.version=="飞车 V1" then velocity,rotation=vehicleFlyV1Step(currentRoot,cam)
		elseif VehicleFly.version=="飞车 V3" then velocity,rotation=vehicleFlyV3Step(currentRoot,cam)
		else velocity,rotation=vehicleFlyV2Step(currentRoot,cam) end
		VehicleFly.bv.Velocity=velocity
		VehicleFly.bg.CFrame=rotation
	end)
	updateVehicleQuick()
end
local function destroyVehicleQuick()
	if vehicleQuickRainbow then vehicleQuickRainbow:Disconnect(); vehicleQuickRainbow = nil end
	if vehicleQuickGui then
		vehicleQuickGui:Destroy()
		vehicleQuickGui = nil
		vehicleQuickButton = nil
	end
end

local function createVehicleQuick()
	destroyVehicleQuick()
	if not vehicleQuickShown then return end
	vehicleQuickGui = Instance.new("ScreenGui")
	vehicleQuickGui.Name = "VehicleFlyQuickSwitch"
	vehicleQuickGui.ResetOnSpawn = false
	vehicleQuickGui.Parent = UI_PARENT or resolveGuiParent()

	vehicleQuickButton = Instance.new("TextButton")
	vehicleQuickButton.Size = UDim2.new(0, 92, 0, 36)
	vehicleQuickButton.Position = vehicleQuickPos
	vehicleQuickButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	vehicleQuickButton.BackgroundTransparency = 0.25
	vehicleQuickButton.BorderSizePixel = 0
	vehicleQuickButton.Font = Enum.Font.GothamSemibold
	vehicleQuickButton.TextSize = 12
	vehicleQuickButton.Parent = vehicleQuickGui
	vehicleQuickButton.Active = not vehicleQuickLocked
	vehicleQuickButton.Draggable = not vehicleQuickLocked
	local c = Instance.new("UICorner", vehicleQuickButton)
	c.CornerRadius = UDim.new(0, 10)
	local stroke = Instance.new("UIStroke", vehicleQuickButton)
	stroke.Thickness = 1.5

	vehicleQuickRainbow = RunService.RenderStepped:Connect(function()
		if stroke.Parent then stroke.Color = GetRainbowColor(5) end
	end)
	updateVehicleQuick()

	vehicleQuickButton.MouseButton1Click:Connect(function()
		if VehicleFly.active then stopVehicleFly() else startVehicleFly() end
	end)
	vehicleQuickButton:GetPropertyChangedSignal("Position"):Connect(function()
		if not vehicleQuickLocked then vehicleQuickPos = vehicleQuickButton.Position end
	end)
end

local speedLimitEnabled = false
local originalGetSpeedLimit
pcall(function()
	local Algorithms = require(ReplicatedStorage.Modules.Algorithms)
	originalGetSpeedLimit = Algorithms.getSpeedLimitAtPos
	Algorithms.getSpeedLimitAtPos = function(...)
		if speedLimitEnabled then
			return 9999
		end
		return originalGetSpeedLimit(...)
	end
end)

-- ============================================================
-- 通用增强：角色读取 / 原地复活 / 快速交互范围
-- ============================================================
local FastInteractConfig = {
	enabled = false,
	distance = 25,
	instant = false,
	original = {},
	connection = nil,
}
local ProximityPromptService = game:GetService("ProximityPromptService")
local function applyPromptSettings(prompt)
	if not prompt or not prompt:IsA("ProximityPrompt") then return end
	if FastInteractConfig.enabled then
		if FastInteractConfig.original[prompt] == nil then
			FastInteractConfig.original[prompt] = {
				distance = prompt.MaxActivationDistance,
				hold = prompt.HoldDuration,
			}
		end
		prompt.MaxActivationDistance = FastInteractConfig.distance
		if FastInteractConfig.instant then
			prompt.HoldDuration = 0
		end
	end
end
local function restorePromptSettings()
	for prompt, old in pairs(FastInteractConfig.original) do
		if prompt and prompt.Parent then
			pcall(function()
				prompt.MaxActivationDistance = old.distance
				prompt.HoldDuration = old.hold
			end)
		end
	end
	FastInteractConfig.original = {}
end
local function setFastInteract(enabled, distance, instant)
	FastInteractConfig.enabled = enabled
	FastInteractConfig.distance = math.clamp(tonumber(distance) or 25, 5, 200)
	FastInteractConfig.instant = instant == true
	if not enabled then
		restorePromptSettings()
		if FastInteractConfig.connection then
			FastInteractConfig.connection:Disconnect()
			FastInteractConfig.connection = nil
		end
		return
	end
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("ProximityPrompt") then
			applyPromptSettings(obj)
		end
	end
	if not FastInteractConfig.connection then
		FastInteractConfig.connection = Workspace.DescendantAdded:Connect(function(obj)
			if obj:IsA("ProximityPrompt") then
				task.defer(function() applyPromptSettings(obj) end)
			end
		end)
	end
end

local RespawnConfig = {
	enabled = false,
	lastCFrame = nil,
	connection = nil,
}
local function captureLastPosition()
	local _, hum, root = GetCharacter(LocalPlayer)
	if hum and root and hum.Health > 0 then
		RespawnConfig.lastCFrame = root.CFrame
	end
end
RunService.Heartbeat:Connect(function()
	if RespawnConfig.enabled then
		captureLastPosition()
	end
end)
local function setLocalRespawn(enabled)
	RespawnConfig.enabled = enabled == true
	if RespawnConfig.connection then
		RespawnConfig.connection:Disconnect()
		RespawnConfig.connection = nil
	end
	if not RespawnConfig.enabled then return end
	RespawnConfig.connection = LocalPlayer.CharacterAdded:Connect(function(character)
		task.spawn(function()
			local root = character:WaitForChild("HumanoidRootPart", 8)
			if root and RespawnConfig.lastCFrame then
				task.wait(0.15)
				pcall(function() character:PivotTo(RespawnConfig.lastCFrame) end)
			end
		end)
	end)
	captureLastPosition()
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
    cycleEnabled = false,
    cycleToken = 0,
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
    AioveWaypoint.cycleEnabled = false
    AioveWaypoint.cycleToken += 1
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

local function createMainWindow()
	if mainWindow then
		pcall(function()
			mainWindow:Destroy()
		end)
		mainWindow = nil
	end
	mainWindow = WindUI:CreateWindow({
		Title = "欢迎您的使用",
		Icon = "zap",
		IconTransparency = 0.5,
		IconThemed = true,
		Author = "Aiove HUB",
		Folder = "AioveHUB",
		Size = ({
			["小"] = UDim2.fromOffset(680, 480),
			["中"] = UDim2.fromOffset(760, 520),
			["大"] = UDim2.fromOffset(840, 560),
		})[settings.windowSize or "中"] or UDim2.fromOffset(760, 520),
		Transparent = true,
		Theme = settings.theme or "Dark",
		User = {
			Enabled = false,
			Callback = function()
			end,
			Anonymous = false
		},
		SideBarWidth = 185,
		ScrollBarEnabled = true,
		Resizable = true,
		HidePanelBackground = false,
		Topbar = {Height = 44, ButtonsType = "Mac"},
		IgnoreAlerts = true,
		Background = getRandomBackground(),
		BackgroundImageTransparency = 0.56,
	})
	isWindowOpen = true
	local Gui = mainWindow.Parent
	-- Mac 顶栏：左侧红色=删除/关闭窗口，黄色=最小化窗口；不在其它位置新增按钮。
	pcall(function()
		mainWindow:DisableTopbarButtons({"Close", "Minimize", "Fullscreen"})
		mainWindow:CreateTopbarButton("AioveMinimize", "circle", function()
			pcall(function() mainWindow:Close() end)
		end, 997, false, Color3.fromRGB(255, 190, 0), 12)
		mainWindow:CreateTopbarButton("AioveClose", "circle", function()
			pcall(function() mainWindow:Destroy() end)
		end, 998, false, Color3.fromRGB(255, 60, 60), 12)
		-- WindUI 的 CreateTopbarButton 默认挂在 Topbar.Right；这里仅把两个按钮移动到左侧，
		-- 保持 Mac 风格的“左上角红色关闭、黄色最小化”，不增加其它装饰。
		local topbar = mainWindow.UIElements.Main.Main.Topbar
		local leftBar = topbar and topbar:FindFirstChild("Left")
		local rightBar = topbar and topbar:FindFirstChild("Right")
		if leftBar and rightBar then
			local closeBtn = rightBar:FindFirstChild("AioveClose")
			local minimizeBtn = rightBar:FindFirstChild("AioveMinimize")
			if closeBtn then
				closeBtn.LayoutOrder = 1
				closeBtn.Parent = leftBar
				closeBtn.Size = UDim2.fromOffset(14, 14)
				closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
				closeBtn.BackgroundTransparency = 0
				closeBtn.BorderSizePixel = 0
				Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
			end
			if minimizeBtn then
				minimizeBtn.LayoutOrder = 2
				minimizeBtn.Parent = leftBar
				minimizeBtn.Size = UDim2.fromOffset(14, 14)
				minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 190, 0)
				minimizeBtn.BackgroundTransparency = 0
				minimizeBtn.BorderSizePixel = 0
				Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(1, 0)
			end
		end
	end)
	-- 精简时间标签：只保留在主窗口标题区域，不再额外覆盖游戏画面。
	local TimeTag = mainWindow:Tag({
		Title = "当前时间: 00:00:00",
		Icon = "clock",
		Color = Color3.fromHex("#58E88A"),
		Border = true
	})
	local clockConnection
	local lastClockText = ""
	clockConnection = RunService.Heartbeat:Connect(function()
		if not mainWindow then
			if clockConnection then clockConnection:Disconnect() end
			return
		end
		-- WindUI Tag 支持 SetTitle；每秒按本机实际时间刷新。
		local currentTime = os.date("%H:%M:%S")
		if currentTime ~= lastClockText then
			lastClockText = currentTime
			pcall(function() TimeTag:SetTitle("当前时间: " .. currentTime) end)
		end
	end)
	mainWindow:EditOpenButton({
		Title = "Aiove HUB",
		Icon = "zap",
		CornerRadius = UDim.new(1, 16),
		StrokeThickness = 1.5,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 180, 70)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 120)),
		}),
		Draggable = true,
	})
	local mainFrame = mainWindow.UIElements.Main
	if mainFrame then
		local stroke = Instance.new("UIStroke")
		stroke.Name = "MainBorder"
		stroke.Thickness = 3
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.LineJoinMode = Enum.LineJoinMode.Round
		stroke.Enabled = settings.borderEnabled
		stroke.Parent = mainFrame
		local gradient = Instance.new("UIGradient")
		gradient.Name = "BorderGradient"
		gradient.Parent = stroke
		applyBorderColor(settings.isBorderRainbow and nil or Color3.fromRGB(0, 230, 110), settings.isBorderRainbow == true)
		-- 圆角主窗口：保留 WindUI 原生结构，只增加圆角和裁剪，避免破坏现有布局。
		pcall(function()
			local corner = mainFrame:FindFirstChild("AioveMainCorner") or Instance.new("UICorner")
			corner.Name = "AioveMainCorner"
			corner.CornerRadius = UDim.new(0, 18)
			corner.Parent = mainFrame
			mainFrame.ClipsDescendants = true
		end)
	end
	-- 顶层 UI 入口：信息、通用、圣奥里（独立脚本）、其他服务器脚本。
	-- 所有其他服务器脚本继续保持独立文件，不拼接源码。
	local InfoTab = mainWindow:Tab({
		Title = "信息",
		Icon = "info",
		Locked = false
	})
	local InfoTopSection = InfoTab:Section({Title = "［左上角小圆圈红色删除 黄色最小化］", Icon = "smile", Opened = true})
	InfoTopSection:Paragraph({Title = "😎 Aiove HUB", Desc = "😎 实时信息中心 · 每秒自动更新"})
	InfoTab:Paragraph({
		Title = "Aiove HUB",
		Desc = "通用移动 · 视觉辅助 · 快速交互 · 玩家工具",
		Image = "zap",
		ImageSize = 28
	})
	InfoTab:Paragraph({
		Title = "投稿开源与反馈",
		Desc = "3593722551",
		Image = "message-circle",
		ImageSize = 24
	})
\tInfoTab:Paragraph({
		Title = "Aiove HUB主脚本",
		Desc = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/AioveCN/RobloxScriptsAiove/main/Aiove.lua"))()',
		Image = "code",
		ImageSize = 24
	})
	local InfoFeatures = InfoTab:Section({
		Title = "功能",
		Icon = "settings",
		Opened = true
	})
	InfoFeatures:Paragraph({
		Title = "当前服务器",
		Desc = "PlaceId: " .. tostring(game.PlaceId) .. "\nJobId: " .. tostring(game.JobId ~= "" and game.JobId or "未知")
	})
	InfoFeatures:Button({
		Title = "读取角色信息",
		Icon = "user",
		Callback = function()
			pcall(function() WindUI:Notify({Title="角色读取", Content=readRoleInfo(), Duration=3}) end)
		end
	})

	-- 实时玩家/账号/服务器信息：每秒刷新；所有内容均来自当前客户端可读的 Roblox 属性。
	local PlayerInfoSection = InfoTab:Section({Title = "玩家信息", Icon = "users", Opened = true})
	local PlayerInfoParagraph = PlayerInfoSection:Paragraph({
		Title = "读取玩家",
		Desc = "正在读取..."
	})
	local SessionStart = os.clock()
	local TotalUseCount = tonumber(settings.totalUses) or 1

	local cachedRegion = "未知"
	task.spawn(function()
		pcall(function()
			local LocalizationService = game:GetService("LocalizationService")
			cachedRegion = tostring(LocalizationService:GetCountryRegionForPlayerAsync(LocalPlayer) or "未知")
		end)
	end)
	local function getLocalRegion()
		return cachedRegion
	end
	local function getExecutorDisplay()
		-- Roblox 标准 API 没有可靠的执行器名称字段；无法读取时明确显示未知。
		return "未知（Roblox 标准 API 不提供）"
	end
	local function getLocalPlatform()
		if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled then
			return "移动端（Android / iOS，无法仅凭 Roblox API 区分商店来源）"
		elseif UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled then
			return "游戏主机 / 手柄"
		elseif UserInputService.KeyboardEnabled or UserInputService.MouseEnabled then
			return "电脑（Windows / macOS 等，无法仅凭 Roblox API 精确区分）"
		end
		return "未知"
	end
	local function getRobloxStoreSource()
		-- Roblox 游戏内标准 API 不提供可靠的 Google Play / App Store 安装来源字段。
		return "无法可靠判断（官方 Roblox API 不提供）"
	end
	local function getPlayerDevice(player)
		-- 只能读取游戏/服务器主动写入的公开属性；不会读取其他玩家私人设备数据。
		local attr = player:GetAttribute("DeviceType") or player:GetAttribute("Platform") or player:GetAttribute("Device")
		if attr ~= nil and tostring(attr) ~= "" then
			return tostring(attr)
		end
		if player == LocalPlayer then
			return getLocalPlatform()
		end
		return "未知（其他玩家设备未公开）"
	end
	local function getPlayerSnapshot(player)
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local pos = root and root.Position
		local maxHealth = hum and hum.MaxHealth or 0
		local maxSpeed = hum and hum.WalkSpeed or 0
		local maxZoom = player.CameraMaxZoomDistance or 0
		local team = player.Team and player.Team.Name or "无"
		local accountAge = tonumber(player.AccountAge) or 0
		local registered = os.date("%Y-%m-%d", os.time() - accountAge * 86400)
		return table.concat({
			"玩家信息：" .. tostring(player.DisplayName),
			"用户名：" .. tostring(player.Name),
			"玩家ID：" .. tostring(player.UserId),
			"最大血量：" .. tostring(maxHealth),
			"最大移速：" .. tostring(maxSpeed),
			string.format("当前位置：%.2f, %.2f, %.2f", pos and pos.X or 0, pos and pos.Y or 0, pos and pos.Z or 0),
			"当前队伍：" .. team,
			"最大视野：" .. tostring(maxZoom),
			"账号注册时间（估算）：" .. registered,
			"账号存活时间：" .. tostring(accountAge) .. " 天",
			"设备：" .. getPlayerDevice(player),
		}, "\n")
	end
	local function getAllInfoText()
		local elapsed = math.floor(os.clock() - SessionStart)
		local h = math.floor(elapsed / 3600); local m = math.floor((elapsed % 3600) / 60); local sec = elapsed % 60
		local now = os.date("%Y-%m-%d %H:%M:%S")
		local lines = {
			"当前时间：" .. now,
			"服务器ID：" .. tostring(game.JobId ~= "" and game.JobId or "未知"),
			"地区：" .. getLocalRegion(),
			"执行器：" .. getExecutorDisplay(),
			"本机设备：" .. getLocalPlatform(),
			"Roblox 商店来源：" .. getRobloxStoreSource(),
			"累计使用脚本次数：" .. tostring(TotalUseCount),
			string.format("启动脚本到现在时间：%02d:%02d:%02d", h, m, sec),
			"账号存活时间：" .. tostring(LocalPlayer.AccountAge) .. " 天",
			"账号注册时间（估算）：" .. os.date("%Y-%m-%d", os.time() - LocalPlayer.AccountAge * 86400),
			"玩家总数：" .. tostring(#Players:GetPlayers()),
			"",
		}
		for _, plr in ipairs(Players:GetPlayers()) do
			table.insert(lines, "【" .. tostring(plr.DisplayName) .. "】")
			table.insert(lines, getPlayerSnapshot(plr))
			table.insert(lines, "")
		end
		return table.concat(lines, "\n")
	end
	local function refreshPlayerInfo()
		local ok, text = pcall(getAllInfoText)
		if ok then
			pcall(function() PlayerInfoParagraph:SetDesc(text) end)
			return text
		end
		return "读取失败：" .. tostring(text)
	end
	PlayerInfoSection:Button({
		Title = "读取全部玩家",
		Icon = "refresh-cw",
		Callback = function()
			local text = refreshPlayerInfo()
			pcall(function() WindUI:Notify({Title="玩家信息", Content="已刷新，共 " .. tostring(#Players:GetPlayers()) .. " 名玩家", Duration=2}) end)
		end
	})
	PlayerInfoSection:Button({
		Title = "复制全部玩家信息",
		Icon = "copy",
		Callback = function()
			local text = refreshPlayerInfo()
			if type(setclipboard) == "function" then pcall(setclipboard, text); pcall(function() WindUI:Notify({Title="玩家信息", Content="完整信息已复制", Duration=2}) end) else pcall(function() WindUI:Notify({Title="复制失败", Content="当前环境没有 setclipboard", Duration=3}) end) end
		end
	})
	PlayerInfoSection:Button({
		Title = "复制当前玩家信息",
		Icon = "user",
		Callback = function()
			local text = getPlayerSnapshot(LocalPlayer)
			if type(setclipboard) == "function" then pcall(setclipboard, text); pcall(function() WindUI:Notify({Title="玩家信息", Content="当前玩家信息已复制", Duration=2}) end) else pcall(function() WindUI:Notify({Title="复制失败", Content="当前环境没有 setclipboard", Duration=3}) end) end
		end
	})
	local nextInfoRefresh = 0
	local InfoLiveConnection = RunService.Heartbeat:Connect(function()
		if not mainWindow then pcall(function() InfoLiveConnection:Disconnect() end); return end
		local now = os.clock()
		if now >= nextInfoRefresh then
			nextInfoRefresh = now + 1
			refreshPlayerInfo()
		end
	end)
	local ServerInfoSection = InfoTab:Section({Title = "服务器与账号", Icon = "server", Opened = true})
	local ServerInfoParagraph = ServerInfoSection:Paragraph({Title = "实时信息", Desc = "正在读取..."})
	ServerInfoSection:Button({
		Title = "复制完整信息",
		Icon = "copy",
		Callback = function()
			local text = getAllInfoText()
			if type(setclipboard) == "function" then pcall(setclipboard, text); pcall(function() WindUI:Notify({Title="信息", Content="完整信息已复制", Duration=2}) end) end
		end
	})
	local nextServerRefresh = 0
	local ServerLiveConnection = RunService.Heartbeat:Connect(function()
		if not mainWindow then pcall(function() ServerLiveConnection:Disconnect() end); return end
		local now = os.clock()
		if now >= nextServerRefresh then
			nextServerRefresh = now + 1
			local elapsed = math.floor(os.clock() - SessionStart)
			local h = math.floor(elapsed / 3600); local m = math.floor((elapsed % 3600) / 60); local sec = elapsed % 60
			local text = table.concat({
				"服务器ID：" .. tostring(game.JobId ~= "" and game.JobId or "未知"),
				"地区：" .. getLocalRegion(),
				"执行器：" .. getExecutorDisplay(),
				"本机设备：" .. getLocalPlatform(),
				"Roblox 商店来源：" .. getRobloxStoreSource(),
				"当前时间：" .. os.date("%Y-%m-%d %H:%M:%S"),
				"账号注册时间（估算）：" .. os.date("%Y-%m-%d", os.time() - LocalPlayer.AccountAge * 86400),
				"账号存活时间：" .. tostring(LocalPlayer.AccountAge) .. " 天",
				"累计使用脚本次数：" .. tostring(TotalUseCount),
				string.format("启动脚本到现在时间：%02d:%02d:%02d", h, m, sec),
			}, "\n")
			pcall(function() ServerInfoParagraph:SetDesc(text) end)
		end
	end)

	local SettingsSection = InfoTab:Section({
		Title = "UI设置",
		Opened = false
	})
	SettingsSection:Dropdown({
		Title = "主题",
		Values = {"Dark", "Light"},
		Value = settings.theme or "Dark",
		Callback = function(v)
			settings.theme = v
			saveSettings()
			pcall(function() WindUI:SetTheme(v) end)
		end
	})
	SettingsSection:Slider({
		Title = "窗口透明度",
		Value = {Min = 0, Max = 100, Default = tonumber(settings.windowTransparency) or 15},
		Step = 5,
		Callback = function(v)
			settings.windowTransparency = tonumber(v) or 15
			saveSettings()
			local n = math.clamp((tonumber(v) or 15) / 100, 0, 1)
			pcall(function() mainWindow:SetBackgroundTransparency(n) end)
			pcall(function() mainWindow:SetBackgroundImageTransparency(n) end)
		end
	})
	SettingsSection:Toggle({
		Title = "面板背景",
		Value = settings.panelBackground ~= false,
		Callback = function(v)
			settings.panelBackground = v
			saveSettings()
			pcall(function() mainWindow:SetPanelBackground(v) end)
		end
	})
	SettingsSection:Toggle({
		Title = "允许调整窗口大小",
		Value = settings.resizable ~= false,
		Callback = function(v)
			settings.resizable = v
			saveSettings()
			pcall(function() mainWindow:IsResizable(v) end)
		end
	})
	SettingsSection:Dropdown({
		Title = "窗口大小",
		Values = {"小", "中", "大"},
		Value = settings.windowSize or "中",
		Callback = function(v)
			local size = ({
				["小"] = UDim2.fromOffset(680, 480),
				["中"] = UDim2.fromOffset(760, 520),
				["大"] = UDim2.fromOffset(840, 560),
			})[v]
			settings.windowSize = v
			saveSettings()
			if size then pcall(function() mainWindow:SetSize(size) end) end
		end
	})
	SettingsSection:Toggle({
		Title = "随机背景图",
		Value = settings.randomBg,
		Callback = function(v)
			settings.randomBg = v
			saveSettings()
			pcall(function() mainWindow:SetBackgroundImage(v and getRandomBackground() or "") end)
		end
	})
	SettingsSection:Toggle({
		Title = "启用边框",
		Value = settings.borderEnabled,
		Callback = function(v)
			settings.borderEnabled = v; saveSettings()
			local mf = mainWindow and mainWindow.UIElements and mainWindow.UIElements.Main
			local st = mf and mf:FindFirstChild("MainBorder")
			if st then st.Enabled = v end
		end
	})
	SettingsSection:Dropdown({
		Title = "边框颜色",
		Values = {"默认", "红色", "橙色", "黄色", "绿色", "青色", "蓝色", "紫色", "粉色", "彩虹"},
		Value = settings.borderColor or (settings.isBorderRainbow and "彩虹" or "默认"),
		Callback = function(v)
			settings.isBorderRainbow = (v == "彩虹")
			settings.borderColor = v
			saveSettings()
			if v == "彩虹" then applyBorderColor(nil, true)
			elseif v == "默认" then applyBorderColor(Color3.fromRGB(0, 230, 110), false)
			else applyBorderColor(GetColor(v), false) end
		end
	})
	SettingsSection:Dropdown({
		Title = "文字颜色",
		Values = {"默认", "青色", "粉色", "紫色", "橙色", "红色", "绿色", "蓝色", "黄色", "白色", "彩虹"},
		Value = settings.textColor or "默认",
		Callback = function(v)
			selectedTextColor = v
			settings.textColor = v
			saveSettings()
		end
	})
	local function applySavedTextColor()
		local themes = WindUI.GetThemes()
		if not themes or not themes.Dark then return end
		if rainbowTextConnection then rainbowTextConnection:Disconnect(); rainbowTextConnection = nil end
		if selectedTextColor == "彩虹" then
			rainbowTextConnection = RunService.Heartbeat:Connect(function()
				local c = GetRainbowColor(5)
				local currentTheme = themes[settings.theme or "Dark"] or themes.Dark
				currentTheme.Text=c; currentTheme.Placeholder=c; currentTheme.Button=c; currentTheme.TabTitle=c
				WindUI:SetTheme(settings.theme or "Dark")
			end)
		elseif selectedTextColor and selectedTextColor ~= "默认" then
			local c = GetColor(selectedTextColor)
			local currentTheme = themes[settings.theme or "Dark"] or themes.Dark
			currentTheme.Text=c; currentTheme.Placeholder=c; currentTheme.Button=c; currentTheme.TabTitle=c
			WindUI:SetTheme(settings.theme or "Dark")
		else
			WindUI:SetTheme(settings.theme or "Dark")
		end
	end
	SettingsSection:Button({
		Title = "应用文字颜色",
		Icon = "check",
		Callback = applySavedTextColor
	})

	-- 启动时恢复上次保存的 UI 状态。使用本地配置文件保存；没有文件 API 时仅保留本次会话。
	pcall(function()
		WindUI:SetTheme(settings.theme or "Dark")
		mainWindow:SetBackgroundTransparency(math.clamp((tonumber(settings.windowTransparency) or 15) / 100, 0, 1))
		mainWindow:SetBackgroundImageTransparency(math.clamp((tonumber(settings.windowTransparency) or 15) / 100, 0, 1))
		mainWindow:SetPanelBackground(settings.panelBackground ~= false)
		mainWindow:IsResizable(settings.resizable ~= false)
		local savedSize = ({["小"] = UDim2.fromOffset(680, 480), ["中"] = UDim2.fromOffset(760, 520), ["大"] = UDim2.fromOffset(840, 560)})[settings.windowSize or "中"]
		if savedSize then mainWindow:SetSize(savedSize) end
		if settings.isBorderRainbow then
			applyBorderColor(nil, true)
		elseif settings.borderColor and settings.borderColor ~= "默认" then
			applyBorderColor(GetColor(settings.borderColor), false)
		else
			applyBorderColor(Color3.fromRGB(0, 230, 110), false)
		end
		selectedTextColor = settings.textColor or "默认"
		applySavedTextColor()
	end)

	-- Aiove 游戏脚本列表：每个源码保持独立文件，不拼接源码。
	-- 主仓库：AioveCN/RobloxScriptsAiove
	local GITHUB_RAW_BASE = "https://raw.githubusercontent.com/AioveCN/RobloxScriptsAiove/main/"
	local MODULE_DIR = "" -- 本地文件作为备用来源

	local function encodePathPart(value)
		value = tostring(value)
		return (value:gsub("[^%w%._%-]", function(c)
			return string.format("%%%02X", string.byte(c))
		end))
	end

	local function notifyLoadError(displayName, detail)
		warn("[Aiove] " .. tostring(displayName) .. " 加载失败：" .. tostring(detail))
		pcall(function()
			WindUI:Notify({
				Title = "Aiove HUB",
				Content = tostring(displayName) .. " 加载失败\n" .. tostring(detail),
				Duration = 5
			})
		end)
	end

	local function runAioveModule(fileName, displayName)
		local source
		local loadedFrom

		-- 第一优先：GitHub Raw，不要求 65 个 Lua 文件和 Aiove.lua 在本地同一目录。
		local encodedName = encodePathPart(fileName)
		local url = GITHUB_RAW_BASE .. encodedName
		local okHttp, result = pcall(function()
			return game:HttpGet(url)
		end)
		if okHttp and type(result) == "string" and result ~= "" then
			source = result
			loadedFrom = "GitHub"
		else
			-- GitHub 失败时再尝试本地文件。
			if type(readfile) == "function" then
				local path = MODULE_DIR .. fileName
				local okRead, localSource = pcall(readfile, path)
				if okRead and type(localSource) == "string" and localSource ~= "" then
					source = localSource
					loadedFrom = "本地文件"
				end
			end
		end

		if type(source) ~= "string" or source == "" then
			notifyLoadError(displayName, "无法读取：" .. url)
			return
		end

		local fn, compileErr = loadstring(source)
		if type(fn) ~= "function" then
			notifyLoadError(displayName, "源码编译失败：" .. tostring(compileErr))
			return
		end

		local okRun, runErr = pcall(fn)
		if not okRun then
			notifyLoadError(displayName, "运行错误：" .. tostring(runErr))
			return
		end

		pcall(function()
			WindUI:Notify({
				Title = "Aiove HUB",
				Content = tostring(displayName) .. " 已从 " .. tostring(loadedFrom) .. " 加载",
				Duration = 2.5
			})
		end)
	end

	-- ============================================================
	-- 通用 / 获取：仅操作本地客户端可见对象，不修改服务器数据
	-- ============================================================
	-- 踏空行走：水平空气平面；每次正常跳跃都会把“空气平面”整体抬高一层。
	-- 不会持续升空，也不会强制把角色锁在空中。
	local AirWalkConfig = {
		enabled = false, part = nil, conn = nil, stateConn = nil, targetY = nil,
		stepHeight = 5, jumping = false, jumpStartY = nil, lastState = nil,
	}
	local function stopAirWalk()
		AirWalkConfig.enabled = false
		if AirWalkConfig.conn then pcall(function() AirWalkConfig.conn:Disconnect() end); AirWalkConfig.conn = nil end
		if AirWalkConfig.stateConn then pcall(function() AirWalkConfig.stateConn:Disconnect() end); AirWalkConfig.stateConn = nil end
		if AirWalkConfig.part then pcall(function() AirWalkConfig.part:Destroy() end); AirWalkConfig.part = nil end
		AirWalkConfig.targetY = nil
		AirWalkConfig.jumping = false
		AirWalkConfig.jumpStartY = nil
		AirWalkConfig.lastState = nil
	end
	local function startAirWalk()
		stopAirWalk()
		local char = LocalPlayer.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not root or not hum then return false end
		local platform = Instance.new("Part")
		platform.Name = "Aiove_LocalAirWalk"
		platform.Size = Vector3.new(14, 0.5, 14)
		platform.Transparency = 1
		platform.CanCollide = true
		platform.CanTouch = false
		platform.CanQuery = false
		platform.Anchored = true
		platform.CastShadow = false
		platform.Parent = Workspace
		AirWalkConfig.part = platform
		AirWalkConfig.enabled = true
		AirWalkConfig.targetY = root.Position.Y - 3.15
		AirWalkConfig.lastState = hum:GetState()

		-- 不在“起跳瞬间”移动平台：先让玩家完整跳起并下降，接近原空气平面时才抬升。
		AirWalkConfig.stateConn = hum.StateChanged:Connect(function(_, newState)
			if not AirWalkConfig.enabled then return end
			if newState == Enum.HumanoidStateType.Jumping or newState == Enum.HumanoidStateType.Freefall then
				if not AirWalkConfig.jumping then
					AirWalkConfig.jumping = true
					AirWalkConfig.jumpStartY = root.Position.Y
				end
			elseif newState == Enum.HumanoidStateType.Landed then
				-- Landed 仅作为保险信号；真正抬升由 Heartbeat 在下降阶段完成，避免事件顺序造成坠落。
				AirWalkConfig.jumping = false
				AirWalkConfig.jumpStartY = nil
			end
			AirWalkConfig.lastState = newState
		end)

		AirWalkConfig.conn = RunService.Heartbeat:Connect(function()
			local c = LocalPlayer.Character
			local r = c and c:FindFirstChild("HumanoidRootPart")
			local h = c and c:FindFirstChildOfClass("Humanoid")
			if not AirWalkConfig.enabled or not r or not h or not platform.Parent then
				stopAirWalk()
				return
			end

			-- 平台始终跟随玩家水平移动，Y 高度只在一次完整跳跃结束时增加。
			platform.CFrame = CFrame.new(r.Position.X, AirWalkConfig.targetY, r.Position.Z)

			if AirWalkConfig.jumping then
				local vy = r.AssemblyLinearVelocity.Y
				local platformTop = AirWalkConfig.targetY + platform.Size.Y * 0.5
				-- 玩家已经从跳跃最高点开始下降，并接近空气平面时，抬高整个平面。
				if vy <= 0 and r.Position.Y <= platformTop + 3.9 then
					local lift = AirWalkConfig.stepHeight
					AirWalkConfig.targetY += lift
					platform.CFrame = CFrame.new(r.Position.X, AirWalkConfig.targetY, r.Position.Z)
					r.CFrame = r.CFrame + Vector3.new(0, lift, 0)
					r.AssemblyLinearVelocity = Vector3.zero
					AirWalkConfig.jumping = false
					AirWalkConfig.jumpStartY = nil
				end
			end
		end)
		return true
	end

	-- 本地区块选择/删除/恢复：只把对象从当前客户端 Workspace 暂时移出，不删除服务器对象。
	local LocalBlockState = {selecting = false, connection = nil, removed = {}}
	local function restoreLocalBlocks()
		local restored = 0
		for i = #LocalBlockState.removed, 1, -1 do
			local item = LocalBlockState.removed[i]
			if item and item.object and item.object.Parent == nil and item.parent then
				local ok = pcall(function() item.object.Parent = item.parent end)
				if ok then restored += 1 end
			end
			table.remove(LocalBlockState.removed, i)
		end
		return restored
	end
	local function stopLocalBlockSelection()
		LocalBlockState.selecting = false
		if LocalBlockState.connection then pcall(function() LocalBlockState.connection:Disconnect() end); LocalBlockState.connection = nil end
	end
	local function getLocalBlockTarget(hit)
		if not hit or not hit:IsDescendantOf(Workspace) then return nil end
		local obj = hit
		while obj.Parent and obj.Parent ~= Workspace and not obj.Parent:IsA("Model") do obj = obj.Parent end
		if obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("Tool") then return obj end
		return hit:IsA("BasePart") and hit or nil
	end
	local function startLocalBlockSelection()
		stopLocalBlockSelection()
		LocalBlockState.selecting = true
		LocalBlockState.connection = UserInputService.InputBegan:Connect(function(input, processed)
			if processed or not LocalBlockState.selecting then return end
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
			local cam = Workspace.CurrentCamera
			if not cam then return end
			local pos = input.Position
			local ray = cam:ViewportPointToRay(pos.X, pos.Y)
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = {LocalPlayer.Character}
			local hitResult = Workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
			local target = getLocalBlockTarget(hitResult and hitResult.Instance)
			if target then
				local parent = target.Parent
				local ok = pcall(function() target.Parent = nil end)
				if ok then
					LocalBlockState.removed[#LocalBlockState.removed + 1] = {object = target, parent = parent}
					notifyGeneral("已删除选中位置的本地区块对象")
				else
					notifyGeneral("删除失败：该对象不允许本地移除")
				end
			else
				notifyGeneral("没有选中可删除的场景对象")
			end
			stopLocalBlockSelection()
		end)
	end

	local function notifyGeneral(msg)
		pcall(function() WindUI:Notify({Title="通用", Content=tostring(msg), Duration=2.2}) end)
	end
	local function getVisibleTools()
		local list = {}
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("Tool") then list[#list+1] = obj end
		end
		return list
	end
	local function collectNearestTool()
		local char = LocalPlayer.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
		if not root or not backpack then return false, "角色或背包未加载" end
		local best, bestDist
		for _, tool in ipairs(getVisibleTools()) do
			local handle = tool:FindFirstChild("Handle")
			if handle and handle:IsA("BasePart") then
				local d = (handle.Position - root.Position).Magnitude
				if d <= 60 and (not bestDist or d < bestDist) then best, bestDist = tool, d end
			end
		end
		if not best then return false, "附近没有可获取的掉落道具" end
		local ok = pcall(function() best.Parent = backpack end)
		return ok, ok and ("已尝试获取：" .. best.Name) or "获取失败"
	end
	local function cloneOwnToolLocal()
		local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
		local char = LocalPlayer.Character
		local source = backpack and backpack:FindFirstChildOfClass("Tool") or (char and char:FindFirstChildOfClass("Tool"))
		if not source then return false, "没有找到自己当前可见的道具" end
		local ok = pcall(function()
			local clone = source:Clone()
			clone.Name = source.Name .. "_Aiove本地复制"
			clone.Parent = backpack
		end)
		return ok, ok and "已创建本地复制品（服务器未获得新物品）" or "复制失败"
	end
	local function cloneNearestVisibleToolLocal()
		local char = LocalPlayer.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
		if not root or not backpack then return false, "角色或背包未加载" end
		local best, bestDist
		for _, tool in ipairs(getVisibleTools()) do
			local handle = tool:FindFirstChild("Handle")
			if handle and handle:IsA("BasePart") then
				local d = (handle.Position - root.Position).Magnitude
				if d <= 60 and (not bestDist or d < bestDist) then best, bestDist = tool, d end
			end
		end
		if not best then return false, "附近没有可复制的可见道具" end
		local ok = pcall(function()
			local clone = best:Clone()
			clone.Name = best.Name .. "_Aiove本地复制"
			clone.Parent = backpack
		end)
		return ok, ok and ("已本地复制：" .. best.Name .. "（服务器未获得新物品）") or "复制失败"
	end
	local function clearLocalVisibleTools()
		local char = LocalPlayer.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not root then return 0 end
		local count = 0
		for _, obj in ipairs(getVisibleTools()) do
			local handle = obj:FindFirstChild("Handle")
			if handle and handle:IsA("BasePart") and (handle.Position - root.Position).Magnitude <= 60 then
				local ok = pcall(function() obj:Destroy() end)
				if ok then count += 1 end
			end
		end
		return count
	end

	local GeneralTab = mainWindow:Tab({
		Title = "通用",
		Icon = "sliders-horizontal",
		Locked = false
	})
	local Movement = GeneralTab:Section({Title = "飞行与移动", Icon = "move", Opened = false})
	Movement:Toggle({
		Title = "飞行",
		Default = PlayerConfig.flyEnabled,
		Callback = function(v)
			PlayerConfig.flyEnabled = v
			if v then startPlayerFly() else stopPlayerFly() end
		end
	})
	Movement:Slider({
		Title = "飞行速度",
		Value = {Min = 10, Max = 1000, Default = math.clamp(PlayerConfig.flySpeed, 10, 1000)},
		Step = 1,
		Callback = function(v) PlayerConfig.flySpeed = math.clamp(v, 10, 1000) end
	})
	Movement:Dropdown({
		Title = "飞行版本",
		Values = {"飞行 V1", "飞行 V2"},
		Value = PlayerConfig.flyVersion,
		Callback = function(v)
			local wasFlying = PlayerConfig.flyEnabled
			stopPlayerFly()
			PlayerConfig.flyVersion = v
			if v == "飞行 V2" then
				destroyPlayerQuick()
				if playerV2QuickShown then createPlayerV2Quick() end
			elseif playerQuickShown then
				destroyPlayerV2Quick()
				createPlayerQuick()
			else
				destroyPlayerV2Quick()
			end
			if wasFlying then
				startPlayerFly()
			end
		end
	})
	Movement:Toggle({
		Title = "V1 控制面板",
		Default = playerQuickShown,
		Callback = function(v)
			playerQuickShown = v
			if PlayerConfig.flyVersion == "飞行 V1" then createPlayerQuick() end
		end
	})
	Movement:Toggle({
		Title = "V2 悬浮窗",
		Default = playerV2QuickShown,
		Callback = function(v)
			playerV2QuickShown = v
			if PlayerConfig.flyVersion == "飞行 V2" then
				if v then createPlayerV2Quick() else destroyPlayerV2Quick() end
			end
		end
	})
	Movement:Paragraph({
		Title = "飞行版本说明",
		Desc = "V1：摇杆控制方向＋悬浮面板控制上升/下降。\nV2：完全使用手机摇杆，镜头俯仰控制上升/下降；可选飞行 V2 悬浮窗。"
	})
	local VehicleSection = GeneralTab:Section({Title = "飞车", Icon = "car", Opened = false})
	VehicleSection:Dropdown({
		Title = "飞车版本",
		Values = {"飞车 V1", "飞车 V2", "飞车 V3"},
		Value = VehicleFly.version,
		Callback = function(v)
			VehicleFly.version = v
			if VehicleFly.active then
				startVehicleFly()
			else
				updateVehicleQuick()
			end
		end
	})
	VehicleSection:Toggle({
		Title = "启动飞车",
		Default = VehicleFly.active,
		Callback = function(v)
			if v then startVehicleFly() else stopVehicleFly() end
		end
	})
	VehicleSection:Slider({
		Title = "飞车速度",
		Value = {Min = 20, Max = 2000, Default = math.clamp(VehicleFly.speed, 20, 2000)},
		Step = 1,
		Callback = function(v) VehicleFly.speed = math.clamp(v, 20, 2000) end
	})
	VehicleSection:Toggle({
		Title = "显示飞车控制面板",
		Default = vehicleQuickShown,
		Callback = function(v)
			vehicleQuickShown = v
			createVehicleQuick()
		end
	})
	VehicleSection:Paragraph({
		Title = "版本说明",
		Desc = "V1 经典兼容｜V2 相机直控｜V3 加速减速。无需强制检测座位，优先控制当前/附近车辆。"
	})
	noclipToggle = Movement:Toggle({
		Title = "穿墙",
		Default = PlayerConfig.noclip,
		Callback = function(v)
			PlayerConfig.noclip = v
			if v then startNoclip() else stopNoclip() end
			updateNoclipQuick()
		end
	})
	Movement:Toggle({
		Title = "显示穿墙控制面板",
		Default = noclipQuickShown,
		Callback = function(v)
			noclipQuickShown = v
			createNoclipQuick()
		end
	})
	Movement:Paragraph({
		Title = "穿墙",
		Desc = "开关式穿墙；采用角色部件缓存和低频校正，避免每帧遍历整个角色。"
	})
	Movement:Toggle({
		Title = "WalkSpeed",
		Default = PlayerConfig.walkEnabled,
		Callback = function(v) PlayerConfig.walkEnabled = v; if v then startWalkLoop() else stopWalkLoop() end end
	})
	Movement:Slider({
		Title = "移动速度",
		Value = {Min = 16, Max = 500, Default = math.clamp(PlayerConfig.walkSpeed, 16, 500)},
		Step = 1,
		Callback = function(v) PlayerConfig.walkSpeed = v end
	})
	Movement:Toggle({
		Title = "无限跳跃",
		Default = PlayerConfig.infiniteJump,
		Callback = function(v) PlayerConfig.infiniteJump = v end
	})

	Movement:Toggle({
		Title = "疾跑",
		Default = false,
		Callback = function(v)
			if v then
				PlayerConfig.walkEnabled = true
				PlayerConfig.walkSpeed = math.max(PlayerConfig.walkSpeed, 300)
				startWalkLoop()
			else
				PlayerConfig.walkEnabled = false
				stopWalkLoop()
			end
		end
	})
	Movement:Slider({
		Title = "重力",
		Value = {Min = 0, Max = 300, Default = math.clamp(tonumber(workspace.Gravity) or 196.2, 0, 300)},
		Step = 1,
		Callback = function(v) workspace.Gravity = math.clamp(tonumber(v) or 196.2, 0, 300) end
	})


	local GetSection = GeneralTab:Section({Title = "获取", Icon = "package", Opened = false})
	GetSection:Toggle({
		Title = "踏空行走",
		Default = false,
		Callback = function(v)
			if v then
				if not startAirWalk() then notifyGeneral("角色尚未加载") end
			else stopAirWalk() end
		end
	})
	GetSection:Button({
		Title = "复制道具",
		Icon = "copy",
		Callback = function()
			local ok, msg = cloneNearestVisibleToolLocal(); notifyGeneral(msg)
		end
	})
	GetSection:Button({
		Title = "复制自己的道具（本地）",
		Icon = "copy",
		Callback = function()
			local ok, msg = cloneOwnToolLocal(); notifyGeneral(msg)
		end
	})
	GetSection:Button({
		Title = "复制附近可见道具（本地）",
		Icon = "copy",
		Callback = function()
			local ok, msg = cloneNearestVisibleToolLocal(); notifyGeneral(msg)
		end
	})
	GetSection:Button({
		Title = "复制他人可见道具",
		Icon = "copy",
		Callback = function()
			local ok, msg = cloneNearestVisibleToolLocal(); notifyGeneral(msg)
		end
	})
	GetSection:Button({
		Title = "删除本地区块 · 选择位置",
		Icon = "mouse-pointer-2",
		Callback = function()
			startLocalBlockSelection()
			notifyGeneral("请点击要删除的本地区块/对象")
		end
	})
	GetSection:Button({
		Title = "取消删除选择",
		Icon = "x",
		Callback = function()
			stopLocalBlockSelection(); notifyGeneral("已取消选择")
		end
	})
	GetSection:Button({
		Title = "恢复本地区块",
		Icon = "undo-2",
		Callback = function()
			stopLocalBlockSelection()
			local count = restoreLocalBlocks()
			notifyGeneral("已恢复 " .. tostring(count) .. " 个本地对象")
		end
	})
	GetSection:Paragraph({
		Title = "说明",
		Desc = "复制、删除和恢复均为客户端本地操作，不修改服务器库存，也不删除服务器地图数据。"
	})


	local WaypointTools = GeneralTab:Section({Title = "标点传送", Icon = "map-pin", Opened = false})
	WaypointTools:Paragraph({
		Title = "标点传送",
		Desc = "点击“增加标点位置”会保存当前坐标，并按增加次数依次生成：传送标点1、传送标点2、传送标点3……"
	})
	local waypointButtons = {}

	local function waypointNotify(msg)
		pcall(function() WindUI:Notify({Title="标点传送", Content=msg, Duration=2}) end)
	end

	local function addWaypointTeleportButton(slot)
		local button = WaypointTools:Button({
			Title = "传送标点" .. tostring(slot),
			Icon = "map-pin",
			Callback = function()
				if aioveTeleportWaypoint(slot) then
					waypointNotify("已传送到标点" .. tostring(slot))
				else
					waypointNotify("标点" .. tostring(slot) .. "不存在")
				end
			end
		})
		waypointButtons[slot] = button
	end

	WaypointTools:Button({
		Title = "增加标点位置",
		Icon = "plus",
		Callback = function()
			local slot = aioveAddWaypoint()
			if not slot then
				waypointNotify("当前角色未加载")
				return
			end
			addWaypointTeleportButton(slot)
			waypointNotify("已增加标点" .. tostring(slot))
		end
	})

	WaypointTools:Button({
		Title = "清空全部标点",
		Icon = "trash-2",
		Callback = function()
			AioveWaypoint.positions = {}
			AioveWaypoint.count = 0
			aioveStopWaypointLoop()
			waypointNotify("已清空全部标点")
		end
	})

	WaypointTools:Slider({
		Title = "循环间隔（秒）",
		Value = {Min = 0.1, Max = 5, Default = 0.5},
		Step = 0.1,
		Callback = function(v)
			AioveWaypoint.loopInterval = math.clamp(tonumber(v) or 0.5, 0.1, 5)
		end
	})

	WaypointTools:Toggle({
		Title = "循环所有标点",
		Default = false,
		Callback = function(v)
			if v then
				aioveStopWaypointLoop()
				if AioveWaypoint.count < 1 then
					waypointNotify("请先增加至少一个标点")
					return
				end
				AioveWaypoint.cycleEnabled = true
				AioveWaypoint.cycleToken += 1
				local token = AioveWaypoint.cycleToken
				task.spawn(function()
					local index = 1
					while AioveWaypoint.cycleEnabled and token == AioveWaypoint.cycleToken do
						if AioveWaypoint.count < 1 then break end
						if index > AioveWaypoint.count then index = 1 end
						if not aioveTeleportWaypoint(index) then break end
						index += 1
						task.wait(math.clamp(tonumber(AioveWaypoint.loopInterval) or 0.5, 0.1, 5))
					end
				end)
			else
				AioveWaypoint.cycleEnabled = false
				AioveWaypoint.cycleToken += 1
			end
		end
	})

	WaypointTools:Button({
		Title = "获取标点传送道具",
		Icon = "mouse-pointer",
		Callback = function()
			if aioveCreateWaypointTool() then
				waypointNotify("已获取道具，装备后点击地图即可传送")
			else
				waypointNotify("背包尚未加载")
			end
		end
	})

	local Interaction = GeneralTab:Section({Title = "快速交互", Icon = "hand", Opened = false})
	Interaction:Toggle({
		Title = "扩大交互范围",
		Default = false,
		Callback = function(v) setFastInteract(v, FastInteractConfig.distance, FastInteractConfig.instant) end
	})
	Interaction:Slider({
		Title = "交互范围",
		Value = {Min = 5, Max = 200, Default = FastInteractConfig.distance},
		Step = 1,
		Callback = function(v)
			FastInteractConfig.distance = v
			if FastInteractConfig.enabled then setFastInteract(true, v, FastInteractConfig.instant) end
		end
	})
	Interaction:Toggle({
		Title = "快速交互（取消等待）",
		Default = false,
		Callback = function(v)
			FastInteractConfig.instant = v
			if FastInteractConfig.enabled then setFastInteract(true, FastInteractConfig.distance, v) end
		end
	})

	local TeleportTools = GeneralTab:Section({Title = "传送", Icon = "map-pin", Opened = false})
	local TeleportTargetDropdown = TeleportTools:Dropdown({
		Title = "选择玩家",
		Values = (function()
			local values = getTeleportPlayers()
			if #values == 0 then values = {"暂无其他玩家"} end
			return values
		end)(),
		Value = (function()
			local values = getTeleportPlayers()
			return values[1] or "暂无其他玩家"
		end)(),
		SearchBarEnabled = true,
		Callback = function(v)
			TeleportPlayerConfig.targetName = tostring(v or "")
		end
	})
	TeleportTools:Button({
		Title = "刷新玩家列表",
		Icon = "refresh-cw",
		Callback = function()
			local values = getTeleportPlayers()
			if #values == 0 then values = {"暂无其他玩家"} end
			pcall(function() TeleportTargetDropdown:Refresh(values) end)
			local first = getTeleportPlayers()[1]
			if first then
				TeleportPlayerConfig.targetName = first
				pcall(function() TeleportTargetDropdown:Select(first) end)
			end
		end
	})
	TeleportTools:Dropdown({
		Title = "传送位置",
		Values = {"后方", "头顶", "前方"},
		Value = TeleportPlayerConfig.offsetMode,
		Callback = function(v) TeleportPlayerConfig.offsetMode = tostring(v or "后方") end
	})
	TeleportTools:Slider({
		Title = "距离",
		Value = {Min = 1, Max = 20, Default = TeleportPlayerConfig.offsetDistance},
		Step = 1,
		Callback = function(v) TeleportPlayerConfig.offsetDistance = math.clamp(tonumber(v) or 3, 1, 20) end
	})
	TeleportTools:Button({
		Title = "传送到玩家",
		Icon = "move",
		Callback = function()
			local target = findTeleportTarget(TeleportPlayerConfig.targetName)
			if target and teleportNearPlayer(target, TeleportPlayerConfig.offsetMode, TeleportPlayerConfig.offsetDistance) then
				pcall(function() WindUI:Notify({Title="传送", Content="已传送到 " .. target.Name .. " 附近", Duration=2}) end)
			else
				pcall(function() WindUI:Notify({Title="传送", Content="找不到目标玩家或目标未加载", Duration=2.5}) end)
			end
		end
	})
	TeleportTools:Toggle({
		Title = "循环传送",
		Default = false,
		Callback = function(v)
			if v then
				startTeleportLoop()
			else
				stopTeleportLoop()
		stopAirWalk()
		stopLocalBlockSelection()
			end
		end
	})
	TeleportTools:Slider({
		Title = "循环间隔（秒）",
		Value = {Min = 0.1, Max = 3, Default = TeleportPlayerConfig.loopInterval},
		Step = 0.1,
		Callback = function(v) TeleportPlayerConfig.loopInterval = math.clamp(tonumber(v) or 0.35, 0.1, 3) end
	})

	local PlayerTools = GeneralTab:Section({Title = "玩家功能", Icon = "user", Opened = false})
	PlayerTools:Toggle({
		Title = "原地复活",
		Default = false,
		Callback = function(v) setLocalRespawn(v) end
	})
	PlayerTools:Button({
		Title = "立即读取角色",
		Icon = "scan",
		Callback = function()
			local info = readRoleInfo()
			pcall(function() WindUI:Notify({Title="角色读取", Content=info, Duration=3}) end)
		end
	})
	PlayerTools:Button({
		Title = "传送到自己保存的位置",
		Icon = "map-pin",
		Callback = function()
			if RespawnConfig.lastCFrame then
				local char = LocalPlayer.Character
				if char then pcall(function() char:PivotTo(RespawnConfig.lastCFrame) end) end
			end
		end
	})

	local ServerTools = GeneralTab:Section({Title = "网络 / 服务器", Icon = "server", Opened = true})
	ServerTools:Paragraph({Title = "说明", Desc = "部分功能依赖游戏自身的服务器权限；客户端功能无法保证绕过服务器校验。"})
	ServerTools:Button({Title = "重新加入当前服务器", Icon = "refresh-cw", Callback = function() pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end) end})
	ServerTools:Button({Title = "重新加入游戏", Icon = "rotate-ccw", Callback = function() pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end) end})



	local FPSTab = mainWindow:Tab({
		Title = "FPS",
		Icon = "crosshair",
		Locked = false
	})
	local Visual = FPSTab:Section({Title = "视觉", Icon = "eye", Opened = false})
	Visual:Toggle({
		Title = "ESP 总开关",
		Default = ESP.enabled,
		Callback = function(v)
			ESP.enabled = v
			if not v then for p in pairs(ESP.trackers) do removeESP(p) end else refreshESP() end
		end
	})
	Visual:Toggle({Title = "ESP 名字", Default = ESP.name, Callback = function(v) ESP.name = v end})
	Visual:Toggle({Title = "ESP 距离", Default = ESP.distance, Callback = function(v) ESP.distance = v end})
	Visual:Toggle({Title = "ESP 血量", Default = ESP.health, Callback = function(v) ESP.health = v end})
	Visual:Toggle({Title = "ESP 高亮", Default = ESP.highlight, Callback = function(v) ESP.highlight = v end})
	Visual:Toggle({Title = "ESP 追踪线", Default = ESP.tracer, Callback = function(v) ESP.tracer = v end})

	local RangeSection = FPSTab:Section({Title = "范围", Icon = "scan", Opened = false})
	local function setESPRange(v)
		ESP.maxDistance = math.clamp(tonumber(v) or 10000, 50, 10000)
		refreshESP()
	end
	RangeSection:Dropdown({
		Title = "范围预设",
		Values = {"范围超级大", "范围大", "范围中", "范围小", "范围级小"},
		Value = "范围超级大",
		Callback = function(v)
			local map = { ["范围超级大"] = 10000, ["范围大"] = 2000, ["范围中"] = 800, ["范围小"] = 300, ["范围级小"] = 100 }
			setESPRange(map[v] or 10000)
		end
	})
	RangeSection:Slider({
		Title = "修改范围大小",
		Value = {Min = 50, Max = 10000, Default = ESP.maxDistance},
		Step = 50,
		Callback = function(v) setESPRange(v) end
	})
	RangeSection:Paragraph({
		Title = "范围说明",
		Desc = "这里调整的是 ESP 的显示/追踪范围，不修改攻击距离或服务器判定。"
	})


	local CombatQuick = FPSTab:Section({Title = "战斗辅助", Icon = "crosshair", Opened = false})
	CombatQuick:Toggle({Title = "自瞄", Default = AimConfig.enabled, Callback = function(v) AimConfig.enabled = v end})
	CombatQuick:Toggle({Title = "自瞄 FOV", Default = AimConfig.showFov, Callback = function(v) AimConfig.showFov = v end})
	CombatQuick:Toggle({Title = "队伍检测", Default = AimConfig.teamCheck, Callback = function(v) AimConfig.teamCheck = v end})
	CombatQuick:Toggle({Title = "好友检测", Default = AimConfig.friendCheck, Callback = function(v) AimConfig.friendCheck = v end})
	CombatQuick:Toggle({Title = "墙壁检测", Default = AimConfig.wallCheck, Callback = function(v) AimConfig.wallCheck = v end})
	CombatQuick:Dropdown({Title = "瞄准部位", Values = {"头","胸","左手","右手","左腿","右腿"}, Value = AimConfig.targetPart, Callback = function(v) AimConfig.targetPart = v end})
	CombatQuick:Slider({Title = "FOV大小", Value = {Min = 1, Max = 500, Default = AimConfig.fov}, Step = 1, Callback = function(v) AimConfig.fov = v end})
	CombatQuick:Slider({Title = "平滑度", Value = {Min = 1, Max = 10, Default = math.floor(AimConfig.smoothness * 10)}, Step = 1, Callback = function(v) AimConfig.smoothness = v / 10 end})


	local OtherTab = mainWindow:Tab({
		Title = "其他服务器脚本",
		Icon = "gamepad-2",
		Locked = false
	})
	local OtherSection = OtherTab:Section({
		Title = "其他服务器脚本",
		Opened = true
	})

	local function addOtherServerScript(parent, fileName, displayName)
		parent:Button({
			Title = displayName,
			Desc = "Aiove · 独立源码：" .. fileName,
			Icon = "play",
			Callback = function()
				runAioveModule(fileName, displayName)
			end
		})
	end

	addOtherServerScript(OtherSection, "01_Aiove_DOORS.lua", "DOORS")
	addOtherServerScript(OtherSection, "02_Aiove_GB.lua", "GB")
	addOtherServerScript(OtherSection, "03_Aiove_七日生存.lua", "七日生存")
	addOtherServerScript(OtherSection, "04_Aiove_不要离开圈子.lua", "不要离开圈子")
	addOtherServerScript(OtherSection, "05_Aiove_中国人能飞.lua", "中国人能飞")
	addOtherServerScript(OtherSection, "06_Aiove_亡命速递.lua", "亡命速递")
	addOtherServerScript(OtherSection, "07_Aiove_伐木大亨2.lua", "伐木大亨2")
	addOtherServerScript(OtherSection, "08_Aiove_俄亥俄州.lua", "俄亥俄州")
	addOtherServerScript(OtherSection, "09_Aiove_偷一个蛋.lua", "偷一个蛋")
	addOtherServerScript(OtherSection, "10_Aiove_决斗场.lua", "决斗场")
	addOtherServerScript(OtherSection, "11_Aiove_出售柠檬.lua", "出售柠檬")
	addOtherServerScript(OtherSection, "12_Aiove_力量传奇.lua", "力量传奇")
	addOtherServerScript(OtherSection, "13_Aiove_动物医院.lua", "动物医院")
	addOtherServerScript(OtherSection, "14_Aiove_南极探险队.lua", "南极探险队")
	addOtherServerScript(OtherSection, "15_Aiove_变形升级.lua", "变形升级")
	addOtherServerScript(OtherSection, "16_Aiove_变身躲猫猫.lua", "变身躲猫猫")
	addOtherServerScript(OtherSection, "17_Aiove_吃吃世界.lua", "吃吃世界")
	addOtherServerScript(OtherSection, "18_Aiove_吃掉其他人来成长.lua", "吃掉其他人来成长")
	addOtherServerScript(OtherSection, "19_Aiove_合成一个核弹.lua", "合成一个核弹")
	addOtherServerScript(OtherSection, "20_Aiove_国人电梯.lua", "国人电梯")
	addOtherServerScript(OtherSection, "21_Aiove_圣地亚哥边境.lua", "圣地亚哥边境")
	addOtherServerScript(OtherSection, "22_Aiove_在末日中生存.lua", "在末日中生存")
	addOtherServerScript(OtherSection, "23_Aiove_在超市生活一周.lua", "在超市生活一周")
	addOtherServerScript(OtherSection, "24_Aiove_地铁冲浪.lua", "地铁冲浪")
	addOtherServerScript(OtherSection, "25_Aiove_墨水游戏.lua", "墨水游戏")
	addOtherServerScript(OtherSection, "26_Aiove_巨剑骑士.lua", "巨剑骑士")
	addOtherServerScript(OtherSection, "27_Aiove_忍者传奇.lua", "忍者传奇")
	addOtherServerScript(OtherSection, "28_Aiove_恶魔学.lua", "恶魔学")
	addOtherServerScript(OtherSection, "29_Aiove_戒网瘾中心.lua", "戒网瘾中心")
	addOtherServerScript(OtherSection, "30_Aiove_战斗砖块.lua", "战斗砖块")
	addOtherServerScript(OtherSection, "31_Aiove_手枪竞技场.lua", "手枪竞技场")
	addOtherServerScript(OtherSection, "32_Aiove_找出谁打了一巴掌.lua", "找出谁打了一巴掌")
	addOtherServerScript(OtherSection, "33_Aiove_找到按钮.lua", "找到按钮")
	addOtherServerScript(OtherSection, "34_Aiove_找到菜鸟的变形形态.lua", "找到菜鸟的变形形态")
	addOtherServerScript(OtherSection, "35_Aiove_捕捉并驯服吧.lua", "捕捉并驯服吧")
	addOtherServerScript(OtherSection, "36_Aiove_最强战场.lua", "最强战场")
	addOtherServerScript(OtherSection, "37_Aiove_最终战场.lua", "最终战场")
	addOtherServerScript(OtherSection, "38_Aiove_木筏101天生存.lua", "木筏101天生存")
	addOtherServerScript(OtherSection, "39_Aiove_极速传奇.lua", "极速传奇")
	addOtherServerScript(OtherSection, "40_Aiove_森林中的99夜.lua", "森林中的99夜")
	addOtherServerScript(OtherSection, "41_Aiove_模仿者.lua", "模仿者")
	addOtherServerScript(OtherSection, "42_Aiove_死亡避难所.lua", "死亡避难所")
	addOtherServerScript(OtherSection, "43_Aiove_死铁轨.lua", "死铁轨")
	addOtherServerScript(OtherSection, "44_Aiove_沉默的刺客.lua", "沉默的刺客")
	addOtherServerScript(OtherSection, "45_Aiove_泰坦钓鱼.lua", "泰坦钓鱼")
	addOtherServerScript(OtherSection, "46_Aiove_烤或死.lua", "烤或死")
	addOtherServerScript(OtherSection, "47_Aiove_生存与杀手.lua", "生存与杀手")
	addOtherServerScript(OtherSection, "48_Aiove_画我.lua", "画我")
	addOtherServerScript(OtherSection, "49_Aiove_疯狂电梯.lua", "疯狂电梯")
	addOtherServerScript(OtherSection, "50_Aiove_盲射.lua", "盲射")
	addOtherServerScript(OtherSection, "51_Aiove_破坏者谜团2.lua", "破坏者谜团2")
	addOtherServerScript(OtherSection, "52_Aiove_种植花园.lua", "种植花园")
	addOtherServerScript(OtherSection, "53_Aiove_种植花园2.lua", "种植花园2")
	addOtherServerScript(OtherSection, "54_Aiove_紧急汉堡.lua", "紧急汉堡")
	addOtherServerScript(OtherSection, "55_Aiove_能量爆炸幸运方块.lua", "能量爆炸幸运方块")
	addOtherServerScript(OtherSection, "56_Aiove_自然灾害.lua", "自然灾害")
	addOtherServerScript(OtherSection, "57_Aiove_血腥的游乐场.lua", "血腥的游乐场")
	addOtherServerScript(OtherSection, "58_Aiove_被遗弃.lua", "被遗弃")
	addOtherServerScript(OtherSection, "59_Aiove_踢出幸运方块.lua", "踢出幸运方块")
	addOtherServerScript(OtherSection, "60_Aiove_通用血布娃娃战斗.lua", "通用血布娃娃战斗")
	addOtherServerScript(OtherSection, "61_Aiove_通缉.lua", "通缉")
	addOtherServerScript(OtherSection, "62_Aiove_造船寻宝.lua", "造船寻宝")
	addOtherServerScript(OtherSection, "63_Aiove_键盘速度逃脱.lua", "键盘速度逃脱")
	addOtherServerScript(OtherSection, "64_Aiove_闪光.lua", "闪光")
	addOtherServerScript(OtherSection, "65_Aiove_鲨口求生.lua", "鲨口求生")


	local ExecuteTab = mainWindow:Tab({
		Title = "执行其它脚本",
		Icon = "terminal",
		Locked = false
	})
	local ExecuteSection = ExecuteTab:Section({Title = "独立脚本", Icon = "play", Opened = true})

	local function addExternalScript(parent, displayName, code)
		local source = tostring(code)
		parent:Button({
			Title = displayName .. " · 执行",
			Icon = "play",
			Callback = function()
				local fn, compileErr = loadstring(source)
				if type(fn) ~= "function" then
					pcall(function() WindUI:Notify({Title="执行失败", Content=displayName .. "：" .. tostring(compileErr), Duration=4}) end)
					return
				end
				local ok, err = pcall(fn)
				pcall(function() WindUI:Notify({Title=displayName, Content=ok and "独立脚本已执行" or ("执行失败：" .. tostring(err)), Duration=3}) end)
			end
		})
		parent:Button({
			Title = displayName .. " · 复制",
			Icon = "copy",
			Callback = function()
				if type(setclipboard) ~= "function" then
					pcall(function() WindUI:Notify({Title="复制失败", Content="当前环境没有 setclipboard", Duration=3}) end)
					return
				end
				local ok, err = pcall(function() setclipboard(source) end)
				pcall(function() WindUI:Notify({Title=displayName, Content=ok and "完整代码已复制" or ("复制失败：" .. tostring(err)), Duration=2.5}) end)
			end
		})
	end

	addExternalScript(ExecuteSection, "Bs脚本", [[BS="\104\116\116\112\115\58\47\47\103\105\116\101\101\46\99\111\109\47\66\83\95\115\99\114\105\112\116\47\115\99\114\105\112\116\47\114\97\119\47\109\97\115\116\101\114\47\66\83\95\83\99\114\105\112\116\46\76\117\97\117"
loadstring(game:HttpGet(BS))()]])
	addExternalScript(ExecuteSection, "Bs黑洞中心", [[loadstring(utf8.char((function() return table.unpack({108,111,97,100,115,116,114,105,110,103,40,103,97,109,101,58,72,116,116,112,71,101,116,40,34,104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,67,104,105,110,97,81,89,47,45,47,109,97,105,110,47,37,69,54,37,56,51,37,56,53,37,69,52,37,66,65,37,57,49,34,41,41,40,41})end)()))() ]])
	addExternalScript(ExecuteSection, "夜脚本", [[loadstring(game:HttpGet("https://raw.githubusercontent.com/ylt410/roblox-Script/refs/heads/main/yejiaoben"))()]])
	addExternalScript(ExecuteSection, "roblox沙脚本", [[loadstring(game:HttpGet("https://raw.githubusercontent.com/114514lzkill/ShaHUB/refs/heads/main/ShaHUB"))()]])
	addExternalScript(ExecuteSection, "圣奥里", [[loadstring(game:HttpGet("https://raw.githubusercontent.com/AioveCN/RobloxScripts/main/AioveCN_Hub_%E7%A8%B3%E5%AE%9A%E4%BF%AE%E6%AD%A3%E7%89%88.lua"))()]])
	addExternalScript(ExecuteSection, "［开采一座山］", [[loadstring(game:HttpGet("https://gist.githubusercontent.com/2RanmaChan2/d85484e7ff26eadee63e20f9069d8581/raw/16e477562ae8918a8471b7dcf23700f048d045c9/Mine%2520a%2520Mountain%2520by%2520DonnieAzoff"))()]])
	addExternalScript(ExecuteSection, "自瞄", [[loadstring(game:HttpGet("https://raw.githubusercontent.com/kongbaNB/9178/refs/heads/main/自瞄"))()]])
	addExternalScript(ExecuteSection, "［XC脚本］", [[loadstring(game:HttpGet("\104\116\116\112\115\58\47\47\112\97\115\116\101\98\105\110\46\99\111\109\47\114\97\119\47\103\101\109\120\72\119\65\49"))()]])
	addExternalScript(ExecuteSection, "Tx翻译（下面的全段都要复制）", [[TX = "TX Script"
Script = "全自动翻译"
loadstring(game:HttpGet("https://raw.githubusercontent.com/JsYb666/Item/refs/heads/main/Auto-language"))()]])
	addExternalScript(ExecuteSection, "［Vape］", [[loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VWRewrite/main/NewMainScript.lua", true))()]])
	addExternalScript(ExecuteSection, "［LSH］", [[loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-LuaSploit-Script-Hub-48779"))()]])
	addExternalScript(ExecuteSection, "［皮脚本］", [[loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/QQ1002100032-Roblox-Pi-script.lua"))()]])
	addExternalScript(ExecuteSection, "黑白脚本", [[loadstring(game:HttpGet('https://raw.githubusercontent.com/tfcygvunbind/Apple/main/黑白脚本加载器'))()]])

	-- 打开脚本后默认显示“信息”一级分类。
	pcall(function() mainWindow:SelectTab(1) end)

	mainWindow:OnClose(function()
		-- 只同步状态；WindUI 原生 Mac 红色按钮负责真正关闭，黄色按钮负责最小化。
		isWindowOpen = false
	end)
	mainWindow:OnDestroy(function()
		stopTeleportLoop()
		aioveStopWaypointLoop()
		aioveStopWaypointCycle()
		aioveDestroyWaypointTool()
		destroyPlayerQuick()
		destroyNoclipQuick()
		if clockConnection then pcall(function() clockConnection:Disconnect() end); clockConnection = nil end
		pcall(function() if InfoLiveConnection then InfoLiveConnection:Disconnect() end end)
		pcall(function() if ServerLiveConnection then ServerLiveConnection:Disconnect() end end)
		stopAirWalk()
		isWindowOpen = false
		mainWindow = nil
	end)
end
WindUI:Popup({
	Title = "Aiove HUB",
	Icon = "sparkles",
	Content = "欢迎使用 Aiove HUB\n反馈与投稿QQ:3593722551\n感谢🙏PY HUB的开源",
	Buttons = {
		{
			Title = "点这里喵～",
			Variant = "Primary",
			Callback = createMainWindow,
		}
	}
})
-- 已移除第三方执行上报逻辑：脚本不再向外部服务器发送卡密、账号、JobId 或执行器信息。
