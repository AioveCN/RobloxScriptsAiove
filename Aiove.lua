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

local function createAioveStartupButton()
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

createAioveStartupButton()

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
local State = {
	stamina = false,
	food = false,
	combatBlock = false,
	ghost = false,
	noRagdoll = false,
	noFallDamage = false,
	antiPrisonPull = false,
	infiniteAmmo = false,
	rapidFire = false,
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
	if not CombatConfig.bulletEnabled or not CombatConfig.bulletShowFov then
		BulletFOV.Visible = false
		return
	end
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
	if not AimConfig.enabled and not AimConfig.showFov and not AimConfig.showCrosshair and not AimConfig.showTracer then
		AimFOV.Visible = false
		AimTracer.Visible = false
		return
	end
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
local hitboxAccumulator = 0
RunService.Heartbeat:Connect(function(dt)
	if not HitboxConfig.active then return end
	hitboxAccumulator += dt
	if hitboxAccumulator < 0.12 then return end
	hitboxAccumulator = 0
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
	showFugitive = true,
	team = true,
	onlyAlive = false,
	maxDistance = 1000,
	displayMode = "名称+距离+血量",
	teamColor = true,
	box = true,
	username = true,
	hideTeam = false,
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
	return ESP.enabled and player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
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
			local _, _, myRoot = GetCharacter(LocalPlayer)
			local distance = myRoot and math.floor((myRoot.Position - root.Position).Magnitude) or 0
			if ESP.onlyAlive and hum.Health <= 0 then if t.bill then t.bill.Enabled=false end; if t.highlight then t.highlight.Enabled=false end; if t.box then t.box.Visible=false end; continue end
			if distance > (ESP.maxDistance or 1000) then if t.bill then t.bill.Enabled=false end; if t.highlight then t.highlight.Enabled=false end; if t.box then t.box.Visible=false end; continue end
			local fug = ESP.showFugitive and isFugitive(player)
			local team = player.Team and player.Team.Name
			if ESP.hideTeam and LocalPlayer.Team and player.Team == LocalPlayer.Team then
				if t.bill then t.bill.Enabled=false end; if t.highlight then t.highlight.Enabled=false end; if t.box then t.box.Visible=false end; continue
			end
			local color = fug and Color3.fromRGB(255, 60, 60) or TeamColors[team] or Color3.fromRGB(0, 255, 120)
			local teamName = fug and "逃犯" or TeamNames[team] or (team or "未知")
			if t.bill then
				t.bill.Enabled = ESP.name or ESP.distance or ESP.health
				local n = t.nameLabel
				local inf = t.infoLabel
				if n then n.Text = (ESP.team and ("["..teamName.."] ") or "")..(ESP.username and player.Name or player.DisplayName); n.TextColor3=(ESP.teamColor and color or Color3.new(1,1,1)); n.Visible=ESP.name end
				if inf then
					local parts={}
					if ESP.displayMode == "名称+距离+血量" then if ESP.distance then parts[#parts+1]=distance.."m" end; if ESP.health then parts[#parts+1]=math.floor(hum.Health).." HP" end
					elseif ESP.displayMode == "仅距离" then parts[#parts+1]=distance.."m"
					elseif ESP.displayMode == "仅血量" then parts[#parts+1]=math.floor(hum.Health).." HP" end
					inf.Text=table.concat(parts,"  "); inf.TextColor3=(ESP.teamColor and color or Color3.new(1,1,1)); inf.Visible=(#parts>0)
				end
			end
			if t.highlight then t.highlight.FillColor=color; t.highlight.OutlineColor=color; t.highlight.Enabled=ESP.highlight end
			if t.box then t.box.Color3=color; t.box.Visible=(ESP.box == true) end
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
	clearPhysicalFly()
	clearWarpFly()
	PlayerConfig.flyEnabled = false
	playerQuickPanelVertical = 0
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
	-- 主窗口一次创建；各功能均由独立 UI 区块承载，圣奥里不在此初始化。
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
		Size = UDim2.fromOffset(760, 520),
		Transparent = true,
		Theme = "Dark",
		User = {
			Enabled = false,
			Callback = function()
			end,
			Anonymous = false
		},
		SideBarWidth = 185,
		ScrollBarEnabled = true,
		Background = getRandomBackground(),
		BackgroundImageTransparency = 0.56,
	})
	isWindowOpen = true
	local Gui = mainWindow.Parent
	-- 精简时间标签：只保留在主窗口标题区域，不再额外覆盖游戏画面。
	local TimeTag = mainWindow:Tag({
		Title = "当前时间: 00:00:00",
		Icon = "clock",
		Color = Color3.fromHex("#58E88A"),
		Border = true
	})
	local lastUpdate = 0
	local clockConnection
	clockConnection = RunService.Heartbeat:Connect(function()
		if not mainWindow or not isWindowOpen then
			if clockConnection then clockConnection:Disconnect() end
			return
		end
		if tick() - lastUpdate >= 0.25 then
			local currentTime = os.date("!%H:%M:%S", os.time() + 28800)
			pcall(function() TimeTag:SetTitle("当前时间: " .. currentTime) end)
			lastUpdate = tick()
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
	-- 顶层 UI 入口：信息、各功能独立入口、圣奥里（独立脚本）、其他服务器脚本。
	-- 所有其他服务器脚本继续保持独立文件，不拼接源码。
	local InfoTab = mainWindow:Tab({
		Title = "信息",
		Icon = "info",
		Locked = false
	})
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

	InfoTab:Paragraph({
		Title = "时间 / 安全状态",
		Desc = "当前时间：" .. os.date("%Y-%m-%d %H:%M:%S") .. "    |    当前脚本未加入 Bypass Anti-Cheat",
		Image = "clock",
		ImageSize = 24
	})

	-- 玩家资料信息块：直接显示，不使用可折叠 Section。
	-- 头像使用 Roblox 官方 GetUserThumbnailAsync 获取当前玩家的 AvatarThumbnail。
	local function getPlayerProfileInfo()
		local p = LocalPlayer
		local accountAge = tonumber(p.AccountAge) or 0
		local registrationTimestamp = os.time() - (accountAge * 86400)
		local registrationDate = os.date("%Y-%m-%d", registrationTimestamp)
		local membership = tostring(p.MembershipType or "未知"):gsub("Enum.MembershipType%.", "")
		local teamName = p.Team and p.Team.Name or "无队伍"
		local character = p.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local health = humanoid and math.floor(humanoid.Health + 0.5) or 0
		local maxHealth = humanoid and math.floor(humanoid.MaxHealth + 0.5) or 0
		local position = root and root.Position or nil
		local positionText = position and string.format("X %.1f / Y %.1f / Z %.1f", position.X, position.Y, position.Z) or "未生成角色"
		local rigType = humanoid and tostring(humanoid.RigType):gsub("Enum.HumanoidRigType%.", "") or "未知"
		local walkSpeed = humanoid and string.format("%.1f", humanoid.WalkSpeed) or "未知"
		local jumpPower = humanoid and string.format("%.1f", humanoid.JumpPower) or "未知"
		local platform = UserInputService.TouchEnabled and "移动触控" or (UserInputService.GamepadEnabled and "手柄" or "键鼠")
		return table.concat({
			"用户名：" .. tostring(p.Name),
			"显示名称：" .. tostring(p.DisplayName),
			"UserId：" .. tostring(p.UserId),
			"账号年龄：" .. tostring(accountAge) .. " 天（距离今天约 " .. tostring(accountAge) .. " 天）",
			"预计注册日期：" .. registrationDate .. "（按账号年龄估算）",
			"会员类型：" .. membership,
			"当前队伍：" .. teamName,
			"当前设备输入：" .. platform,
			"角色状态：" .. (character and "已生成" or "未生成"),
			"生命值：" .. tostring(health) .. " / " .. tostring(maxHealth),
			"角色类型：" .. rigType,
			"移动速度：" .. walkSpeed,
			"跳跃强度：" .. jumpPower,
			"当前位置：" .. positionText,
			"加入本服务器：" .. (p.Parent and "是" or "否")
		}, "\n")
	end

	local playerAvatarUrl = ""
	pcall(function()
		playerAvatarUrl = select(1, Players:GetUserThumbnailAsync(
			LocalPlayer.UserId,
			Enum.ThumbnailType.AvatarThumbnail,
			Enum.ThumbnailSize.Size420x420
		))
	end)

	-- 居中显示当前完整 Avatar 图片；不是折叠区域，也没有打开/关闭交互。
	if playerAvatarUrl and playerAvatarUrl ~= "" then
		pcall(function()
			InfoTab:Image({
				Image = playerAvatarUrl,
				AspectRatio = "1:1",
				Radius = 12
			})
		end)
	end

	local PlayerInfoBlock = InfoTab:Paragraph({
		Title = "玩家信息",
		Desc = getPlayerProfileInfo(),
		Image = "user",
		ImageSize = 24
	})

	-- 角色重生后自动刷新资料文本；头像无需反复请求。
	LocalPlayer.CharacterAdded:Connect(function()
		task.wait(0.5)
		pcall(function() PlayerInfoBlock:SetDesc(getPlayerProfileInfo()) end)
	end)

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

	local SettingsSection = InfoTab:Section({
		Title = "UI设置",
		Opened = false
	})
	SettingsSection:Toggle({
		Title = "自定义光标",
		Value = false,
		Callback = function(v) mainWindow:ToggleCustomCursor(v) end
	})
	SettingsSection:Dropdown({
		Title = "通知位置",
		Values = {"左", "右"},
		Value = "右",
		Callback = function(v) WindUI:SetNotifySide(v == "左" and "Left" or "Right") end
	})
	SettingsSection:Dropdown({
		Title = "DPI缩放",
		Values = {"50%", "75%", "100%", "125%", "150%", "175%", "200%"},
		Value = "100%",
		Callback = function(v)
			local n = tonumber(v:gsub("%%", ""))
			if n then mainWindow:SetDPIScale(n / 100) end
		end
	})
	SettingsSection:Keybind({
		Title = "菜单按键",
		Value = "RightShift",
		Callback = function(v) mainWindow:SetToggleKey(Enum.KeyCode[v]) end
	})
	SettingsSection:Toggle({
		Title = "随机背景图",
		Value = settings.randomBg,
		Callback = function(v) settings.randomBg = v; saveSettings(); createMainWindow() end
	})
	SettingsSection:Toggle({
		Title = "启用边框颜色",
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
		Values = {"旋转彩虹", "默认白色", "红色", "橙色", "黄色", "绿色", "青色", "蓝色", "紫色", "粉色"},
		Value = settings.isBorderRainbow and "旋转彩虹" or "默认白色",
		Callback = function(v)
			if v == "旋转彩虹" then applyBorderColor(nil, true)
			elseif v == "默认白色" then applyBorderColor(Color3.new(1,1,1), false)
			else applyBorderColor(GetColor(v), false) end
		end
	})
	SettingsSection:Dropdown({
		Title = "文字颜色",
		Values = {"默认", "青色", "粉色", "紫色", "橙色", "红色", "绿色", "蓝色", "黄色", "白色", "彩虹"},
		Value = "默认",
		Callback = function(v) selectedTextColor = v end
	})
	SettingsSection:Button({
		Title = "确认应用文字颜色",
		Icon = "check",
		Callback = function()
			local themes = WindUI.GetThemes()
			if not themes or not themes.Dark then return end
			if rainbowTextConnection then rainbowTextConnection:Disconnect(); rainbowTextConnection = nil end
			if selectedTextColor == "彩虹" then
				rainbowTextConnection = RunService.Heartbeat:Connect(function()
					local c = GetRainbowColor(5); themes.Dark.Text=c; themes.Dark.Placeholder=c; themes.Dark.Button=c; themes.Dark.TabTitle=c; WindUI:SetTheme("Dark")
				end)
			elseif selectedTextColor and selectedTextColor ~= "默认" then
				local c = GetColor(selectedTextColor); themes.Dark.Text=c; themes.Dark.Placeholder=c; themes.Dark.Button=c; themes.Dark.TabTitle=c; WindUI:SetTheme("Dark")
			else WindUI:SetTheme("Dark") end
		end
	})

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
				Title = "Aiove",
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
				Title = "Aiove",
				Content = tostring(displayName) .. " 已从 " .. tostring(loadedFrom) .. " 加载",
				Duration = 2.5
			})
		end)
	end

	-- 原“通用”页已拆分：每个功能区块直接成为左侧栏独立入口。

	-- 通用工具运行时：UI 已拆分到对应的左侧一级区块。
	-- ============================================================
	-- 通用增强：参考公开 Roblox 通用脚本的常见功能，自行实现
	-- 仅增加正常客户端工具；不包含反作弊绕过/检测规避。
	-- ============================================================

	local universalState = {
		antiAFK = false,
		fullBright = false,
		removeFog = false,
		clickTP = false,
		freecam = false,
		performance = false,
		crosshair = false,
		showStats = false,
	}
	local universalConnections = {}
	local savedLighting = {}
	local freecamCameraType
	local freecamConnection
	local statsGui
	local statsConnection
	local crosshairGui

	local function disconnectUniversal(name)
		local c = universalConnections[name]
		if c then pcall(function() c:Disconnect() end) end
		universalConnections[name] = nil
	end

	local function updateLighting()
		if universalState.fullBright then Lighting.Ambient=Color3.new(1,1,1); Lighting.Brightness=math.max(Lighting.Brightness,2); Lighting.ClockTime=14 end
		if universalState.removeFog then Lighting.FogStart=0; Lighting.FogEnd=1000000 end
	end
	universalConnections.lighting=RunService.Heartbeat:Connect(function() if universalState.fullBright or universalState.removeFog then updateLighting() end end)
	local function destroyStats() disconnectUniversal("stats"); if statsGui then statsGui:Destroy(); statsGui=nil end end
	local function createStats()
		destroyStats(); if not universalState.showStats then return end
		statsGui=Instance.new("ScreenGui"); statsGui.Name="AioveUniversalStats"; statsGui.ResetOnSpawn=false; statsGui.Parent=UI_PARENT or resolveGuiParent()
		local label=Instance.new("TextLabel"); label.Size=UDim2.new(0,190,0,42); label.Position=UDim2.new(0,10,0,10); label.BackgroundTransparency=.35; label.BackgroundColor3=Color3.fromRGB(15,15,15); label.TextColor3=Color3.new(1,1,1); label.Font=Enum.Font.GothamSemibold; label.TextSize=13; label.TextXAlignment=Enum.TextXAlignment.Left; label.Parent=statsGui
		local last=tick(); local frames=0
		universalConnections.stats=RunService.RenderStepped:Connect(function() frames+=1; local now=tick(); if now-last>=.5 then local fps=math.floor(frames/(now-last)+.5); frames=0; last=now; local ping="?"; pcall(function() ping=math.floor(LocalPlayer:GetNetworkPing()*1000+.5) end); label.Text=string.format("  FPS: %s   Ping: %sms",fps,ping) end end)
	end
	local function destroyCrosshair() if crosshairGui then crosshairGui:Destroy(); crosshairGui=nil end end
	local function createCrosshair()
		destroyCrosshair(); if not universalState.crosshair then return end
		crosshairGui=Instance.new("ScreenGui"); crosshairGui.Name="AioveUniversalCrosshair"; crosshairGui.ResetOnSpawn=false; crosshairGui.Parent=UI_PARENT or resolveGuiParent()
		local dot=Instance.new("TextLabel"); dot.Size=UDim2.new(0,30,0,30); dot.AnchorPoint=Vector2.new(.5,.5); dot.Position=UDim2.fromScale(.5,.5); dot.BackgroundTransparency=1; dot.Text="+"; dot.TextColor3=Color3.new(1,1,1); dot.TextStrokeTransparency=0; dot.Font=Enum.Font.GothamBold; dot.TextSize=20; dot.Parent=crosshairGui
	end
	local coordGui, coordConnection
	local function destroyCoordHUD() if coordConnection then coordConnection:Disconnect(); coordConnection=nil end; if coordGui then coordGui:Destroy(); coordGui=nil end end
	local function createCoordHUD()
		destroyCoordHUD(); coordGui=Instance.new("ScreenGui"); coordGui.Name="AioveCoordinateHUD"; coordGui.ResetOnSpawn=false; coordGui.Parent=UI_PARENT or resolveGuiParent()
		local label=Instance.new("TextLabel"); label.Size=UDim2.new(0,230,0,34); label.Position=UDim2.new(0,10,0,56); label.BackgroundTransparency=.35; label.BackgroundColor3=Color3.fromRGB(15,15,15); label.TextColor3=Color3.new(1,1,1); label.Font=Enum.Font.GothamSemibold; label.TextSize=12; label.TextXAlignment=Enum.TextXAlignment.Left; label.Parent=coordGui
		coordConnection=RunService.RenderStepped:Connect(function() local _,_,r=GetCharacter(LocalPlayer); if r and label.Parent then local pp=r.Position; label.Text=string.format("  XYZ: %.1f / %.1f / %.1f",pp.X,pp.Y,pp.Z) end end)
	end
	-- ============================================================
	-- 通用：道具工具
	-- 仅处理客户端当前可见/已复制到客户端的 Tool 实例。
	-- 不调用服务器权限接口，不尝试绕过游戏的服务器校验。
	-- ============================================================
	local ItemToolsTab = mainWindow:Tab({Title = "通用", Icon = "package", Locked = false})
	local ItemToolsSection = ItemToolsTab:Section({Title = "获取道具", Icon = "package", Opened = true})

	local function aioveGetLocalTools()
		local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
		if not backpack then
			pcall(function() WindUI:Notify({Title="获取道具",Content="找不到本地 Backpack",Duration=2.5}) end)
			return
		end
		local count = 0
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("Tool") and obj.Parent ~= backpack and not (LocalPlayer.Character and obj:IsDescendantOf(LocalPlayer.Character)) then
				local ok = pcall(function()
					local copy = obj:Clone()
					copy.Parent = backpack
				end)
				if ok then count += 1 end
			end
		end
		pcall(function() WindUI:Notify({Title="获取道具",Content="已获取本地可见道具："..tostring(count).." 个",Duration=3}) end)
	end

	local function aioveCopyOtherPlayerTools()
		local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
		if not backpack then return end
		local count = 0
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				local containers = {player:FindFirstChildOfClass("Backpack"), player.Character}
				for _, container in ipairs(containers) do
					if container then
						for _, obj in ipairs(container:GetChildren()) do
							if obj:IsA("Tool") then
								local ok = pcall(function()
									local copy = obj:Clone()
									copy.Parent = backpack
								end)
								if ok then count += 1 end
							end
						end
					end
				end
			end
		end
		pcall(function() WindUI:Notify({Title="其他人道具",Content="已复制客户端可见的道具："..tostring(count).." 个",Duration=3}) end)
	end

	local function aioveDeleteLocalWorldTools()
		local count = 0
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("Tool") and not (LocalPlayer.Character and obj:IsDescendantOf(LocalPlayer.Character)) then
				local ok = pcall(function() obj:Destroy() end)
				if ok then count += 1 end
			end
		end
		pcall(function() WindUI:Notify({Title="本地区块道具",Content="已删除本地可见世界道具："..tostring(count).." 个",Duration=3}) end)
	end

	ItemToolsSection:Button({
		Title="获取道具",
		Desc="复制当前地图中客户端可见的 Tool 到自己的背包",
		Icon="package-plus",
		Callback=function() aioveGetLocalTools() end
	})
	ItemToolsSection:Button({
		Title="获取其他人道具",
		Desc="仅复制客户端当前可见的其他玩家 Tool，不修改对方背包",
		Icon="copy",
		Callback=function() aioveCopyOtherPlayerTools() end
	})
	ItemToolsSection:Button({
		Title="删除本地区块道具",
		Desc="仅删除客户端当前 Workspace 中可见的世界 Tool",
		Icon="trash-2",
		Callback=function() aioveDeleteLocalWorldTools() end
	})

	
local GeneralExtra = ItemToolsTab:Section({Title="通用增强", Icon="shield", Opened=false})
GeneralExtra:Toggle({
    Title="悬空走",
    Default=false,
    Callback=function(v)
        if v then
            if not startHoverWalk() then pcall(function() WindUI:Notify({Title="悬空走",Content="角色尚未加载",Duration=2}) end) end
        else
            stopHoverWalk()
        end
    end
})
GeneralExtra:Toggle({
    Title="防甩飞",
    Default=false,
    Callback=function(v)
        if v then startAntiFling() else stopAntiFling() end
    end
})
GeneralExtra:Paragraph({Title="说明",Desc="悬空走保持角色在当前高度移动；防甩飞仅保护自己的角色，检测异常水平/旋转速度。"})

local MovementTab = mainWindow:Tab({Title = "飞行", Icon = "move", Locked = false})
	local Movement = MovementTab:Section({Title = "飞行与移动", Icon = "move", Opened = true})
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
	-- 移动区扩展
	Movement:Toggle({Title="Anti-AFK",Default=false,Callback=function(v) disconnectUniversal("afk"); if v then universalConnections.afk=LocalPlayer.Idled:Connect(function() pcall(function() if VirtualUser then VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end end) end) end end})
	Movement:Slider({Title="重力",Value={Min=0,Max=196,Default=Workspace.Gravity},Step=1,Callback=function(v) Workspace.Gravity=tonumber(v) or 196 end})
	Movement:Slider({Title="跳跃强度",Value={Min=0,Max=200,Default=50},Step=1,Callback=function(v) local _,h=GetCharacter(LocalPlayer); if h then h.JumpPower=tonumber(v) or 50 end end})
	Movement:Toggle({Title="无限跳跃",Default=false,Callback=function(v) disconnectUniversal("infJump"); if v then universalConnections.infJump=UserInputService.JumpRequest:Connect(function() local _,h=GetCharacter(LocalPlayer); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end) end end})
	Movement:Toggle({Title="移动加速增强",Default=false,Callback=function(v) local _,h=GetCharacter(LocalPlayer); if h then h.WalkSpeed=v and math.max(h.WalkSpeed,24) or PlayerConfig.walkSpeed end end})

	-- 移动扩展：补齐公开通用脚本常见的移动调节，同时保持手机可用。
	Movement:Toggle({Title="冲刺模式",Default=false,Callback=function(v) disconnectUniversal("sprint"); if v then universalConnections.sprint=RunService.Heartbeat:Connect(function() local _,h=GetCharacter(LocalPlayer); if h and h.MoveDirection.Magnitude>0 then h.WalkSpeed=math.max(PlayerConfig.walkSpeed or 16, 28) end end) else local _,h=GetCharacter(LocalPlayer); if h then h.WalkSpeed=PlayerConfig.walkSpeed or 16 end end end})
	Movement:Slider({Title="冲刺速度",Value={Min=16,Max=150,Default=28},Step=1,Callback=function(v) PlayerConfig.walkSpeed=math.max(16,tonumber(v) or 28) end})
	Movement:Toggle({Title="自动转向",Default=true,Callback=function(v) local _,h=GetCharacter(LocalPlayer); if h then h.AutoRotate=v end end})
	Movement:Slider({Title="角色高度",Value={Min=0,Max=10,Default=0},Step=0.5,Callback=function(v) local _,h=GetCharacter(LocalPlayer); if h then h.HipHeight=tonumber(v) or 0 end end})
	Movement:Toggle({Title="自动起跳",Default=false,Callback=function(v) disconnectUniversal("autoJump"); if v then universalConnections.autoJump=RunService.Heartbeat:Connect(function() local _,h=GetCharacter(LocalPlayer); if h and h.MoveDirection.Magnitude>0 and h.FloorMaterial~=Enum.Material.Air then h.Jump=true end end) end end})
	Movement:Toggle({Title="自动坐下",Default=false,Callback=function(v) local _,h=GetCharacter(LocalPlayer); if h then h.Sit=v end end})
	Movement:Toggle({Title="平台站立",Default=false,Callback=function(v) local _,h=GetCharacter(LocalPlayer); if h then h.PlatformStand=v end end})
	Movement:Toggle({Title="禁用自动旋转",Default=false,Callback=function(v) local _,h=GetCharacter(LocalPlayer); if h then h.AutoRotate=not v end end})
	Movement:Button({Title="恢复默认移动",Icon="rotate-ccw",Callback=function() Workspace.Gravity=196; local _,h=GetCharacter(LocalPlayer); if h then h.WalkSpeed=16; h.JumpPower=50; h.HipHeight=0; h.AutoRotate=true; h.PlatformStand=false end end})
	Movement:Button({Title="立即跳跃",Icon="arrow-up",Callback=function() local _,h=GetCharacter(LocalPlayer); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end})
	Movement:Toggle({Title="移动方向辅助",Default=false,Callback=function(v) disconnectUniversal("moveAssist"); if v then universalConnections.moveAssist=RunService.RenderStepped:Connect(function() local _,h=GetCharacter(LocalPlayer); if h and h.MoveDirection.Magnitude>0 then h:Move(h.MoveDirection,true) end end) end end})

	local VehicleTab = mainWindow:Tab({Title = "飞车", Icon = "car", Locked = false})
	local VehicleSection = VehicleTab:Section({Title = "飞车", Icon = "car", Opened = true})
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


	VehicleSection:Toggle({Title="飞车悬停",Default=false,Callback=function(v) end})
	VehicleSection:Toggle({Title="飞车快速模式",Default=false,Callback=function(v) if v then VehicleFly.speed=math.max(VehicleFly.speed,150) end end})
	VehicleSection:Toggle({Title="飞车悬浮窗",Default=vehicleQuickShown,Callback=function(v) vehicleQuickShown=v; if v then createVehicleQuick() else destroyVehicleQuick() end end})

	local WaypointTab = mainWindow:Tab({Title = "标点传送", Icon = "map-pin", Locked = false})
	local WaypointTools = WaypointTab:Section({Title = "标点传送", Icon = "map-pin", Opened = true})
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

	local VisualTab = mainWindow:Tab({Title = "ESP", Icon = "eye", Locked = false})
	local Visual = VisualTab:Section({Title = "ESP", Icon = "eye", Opened = true})
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

	-- ESP / 视觉扩展
	Visual:Toggle({Title="ESP 队伍",Default=true,Callback=function(v) ESP.team=v end})
	Visual:Toggle({Title="ESP 仅存活",Default=false,Callback=function(v) ESP.onlyAlive=v end})
	Visual:Toggle({Title="ESP 逃犯标记",Default=true,Callback=function(v) ESP.showFugitive=v end})
	Visual:Toggle({Title="ESP 队伍颜色",Default=true,Callback=function(v) ESP.teamColor=v end})
	Visual:Slider({Title="ESP 最大距离",Value={Min=50,Max=2000,Default=1000},Step=50,Callback=function(v) ESP.maxDistance=tonumber(v) or 1000 end})
	Visual:Dropdown({Title="ESP 信息模式",Values={"名称+距离+血量","仅距离","仅血量"},Value="名称+距离+血量",Callback=function(v) ESP.displayMode=v end})
	Visual:Toggle({Title="FullBright",Default=false,Callback=function(v) universalState.fullBright=v; if v then savedLighting.ambient=Lighting.Ambient; savedLighting.brightness=Lighting.Brightness; savedLighting.clockTime=Lighting.ClockTime end; if not v then pcall(function() if savedLighting.ambient then Lighting.Ambient=savedLighting.ambient end; if savedLighting.brightness then Lighting.Brightness=savedLighting.brightness end; if savedLighting.clockTime then Lighting.ClockTime=savedLighting.clockTime end end) end end})
	Visual:Toggle({Title="移除雾气",Default=false,Callback=function(v) universalState.removeFog=v; if v then savedLighting.fogStart=Lighting.FogStart; savedLighting.fogEnd=Lighting.FogEnd end end})
	Visual:Slider({Title="相机 FOV",Value={Min=40,Max=120,Default=70},Step=1,Callback=function(v) local c=Workspace.CurrentCamera; if c then c.FieldOfView=tonumber(v) or 70 end end})
	Visual:Button({Title="恢复默认 FOV",Icon="camera",Callback=function() local c=Workspace.CurrentCamera; if c then c.FieldOfView=70 end end})
	Visual:Toggle({Title="镜头缩放解锁",Default=false,Callback=function(v) LocalPlayer.CameraMaxZoomDistance=v and 1000 or 128 end})
	Visual:Toggle({Title="自定义准心",Default=false,Callback=function(v) universalState.crosshair=v; if v then createCrosshair() else destroyCrosshair() end end})
	Visual:Toggle({Title="FPS / Ping",Default=false,Callback=function(v) universalState.showStats=v; if v then createStats() else destroyStats() end end})
	Visual:Toggle({Title="性能模式",Default=false,Callback=function(v) universalState.performance=v; pcall(function() local t=Workspace:FindFirstChildOfClass("Terrain"); if t then t.Decoration=not v end end); if v then for _,o in ipairs(Workspace:GetDescendants()) do if o:IsA("ParticleEmitter") or o:IsA("Trail") then o.Enabled=false end end end end})
	Visual:Toggle({Title="坐标 HUD",Default=false,Callback=function(v) if v then createCoordHUD() else destroyCoordHUD() end end})

	Visual:Toggle({Title="Freecam",Default=false,Callback=function(v)
		universalState.freecam=v
		if freecamConnection then freecamConnection:Disconnect(); freecamConnection=nil end
		local cam=Workspace.CurrentCamera
		if not cam then return end
		if v then
			freecamCameraType=cam.CameraType; cam.CameraType=Enum.CameraType.Scriptable
			freecamConnection=RunService.RenderStepped:Connect(function(dt)
				if not universalState.freecam then return end
				local mv=Vector3.zero
				if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv+=cam.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv-=cam.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv-=cam.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv+=cam.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then mv+=Vector3.yAxis end
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then mv-=Vector3.yAxis end
				if mv.Magnitude>0 then cam.CFrame=cam.CFrame+mv.Unit*60*dt*2 end
			end)
		else
			cam.CameraType=freecamCameraType or Enum.CameraType.Custom; freecamCameraType=nil
		end
	end})
	Visual:Slider({Title="Freecam速度",Value={Min=1,Max=10,Default=2},Step=1,Callback=function(v) end})
	Visual:Button({Title="刷新视觉组件",Icon="refresh-cw",Callback=function() pcall(function() refreshESP() end); pcall(function() if universalState.crosshair then createCrosshair() end end); pcall(function() if universalState.showStats then createStats() end end) end})

	Visual:Toggle({Title="ESP 方框",Default=true,Callback=function(v) ESP.box=v end})
	Visual:Toggle({Title="ESP 用户名",Default=true,Callback=function(v) ESP.username=v end})
	Visual:Toggle({Title="ESP 只显示其他玩家",Default=true,Callback=function(v) ESP.excludeSelf=v end})
	Visual:Toggle({Title="ESP 隐藏队友",Default=false,Callback=function(v) ESP.hideTeam=v end})
	Visual:Toggle({Title="ESP 距离单位",Default=true,Callback=function(v) ESP.distanceUnit=v and "stud" or "" end})
	Visual:Toggle({Title="ESP 实时刷新",Default=true,Callback=function(v) ESP.liveRefresh=v end})
	Visual:Slider({Title="ESP 更新间隔",Value={Min=1,Max=10,Default=8},Step=1,Callback=function(v) ESP.updateRate=math.clamp(tonumber(v) or 8,1,10) end})
	Visual:Button({Title="清理 ESP",Icon="trash-2",Callback=function() for p in pairs(ESP.trackers) do removeESP(p) end end})

	-- ============================================================
	-- 音乐：客户端音乐执行器
	-- 参考 WindUI Input 与 Roblox SoundService 的公开用法。
	-- 仅播放当前客户端可访问的 Roblox 音频，不修改服务器音乐状态。
	-- ============================================================
	local MusicTab = mainWindow:Tab({Title = "音乐", Icon = "music", Locked = false})
	local MusicSection = MusicTab:Section({Title = "音乐执行器", Icon = "music", Opened = true})

	local MusicRuntime = {
		sound = nil,
		assetId = "",
		looped = false,
		volume = 0.5,
	}

	local function getMusicSound()
		if MusicRuntime.sound and MusicRuntime.sound.Parent then
			return MusicRuntime.sound
		end
		local sound = Instance.new("Sound")
		sound.Name = "AioveMusicExecutor"
		sound.Volume = MusicRuntime.volume
		sound.Looped = MusicRuntime.looped
		sound.Parent = SoundService
		MusicRuntime.sound = sound
		return sound
	end

	local function normalizeMusicId(value)
		value = tostring(value or ""):match("%S+") or ""
		local id = value:match("rbxassetid://(%d+)") or value:match("[?&]id=(%d+)") or value:match("(%d+)")
		return id and ("rbxassetid://" .. id) or nil
	end

	local function musicNotify(title, content)
		pcall(function()
			WindUI:Notify({Title=title, Content=content, Duration=2.5})
		end)
	end

	local function playMusic()
		local sound = getMusicSound()
		local id = normalizeMusicId(MusicRuntime.assetId)
		if not id then
			musicNotify("音乐执行器", "请输入有效的 Roblox 音频 ID")
			return
		end
		MusicRuntime.assetId = id
		sound.SoundId = id
		sound.Volume = MusicRuntime.volume
		sound.Looped = MusicRuntime.looped
		pcall(function()
			sound.TimePosition = 0
			sound:Play()
		end)
		musicNotify("音乐执行器", "已开始播放：" .. id:gsub("rbxassetid://", ""))
	end

	local function pauseMusic()
		local sound = MusicRuntime.sound
		if sound then pcall(function() sound:Pause() end) end
	end

	local function stopMusic()
		local sound = MusicRuntime.sound
		if sound then pcall(function() sound:Stop() end) end
	end

	MusicSection:Input({
		Title = "音乐 ID",
		Desc = "输入 Roblox 音频 ID，例如 1843463175",
		Value = "",
		InputIcon = "music",
		Type = "Input",
		Placeholder = "请输入Roblox音乐ID",
		Callback = function(value)
			MusicRuntime.assetId = tostring(value or "")
		end
	})

	MusicSection:Button({
		Title="播放音乐",
		Desc="执行当前输入的音频 ID",
		Icon="play",
		Callback=function() playMusic() end
	})
	MusicSection:Button({
		Title="暂停音乐",
		Icon="pause",
		Callback=function() pauseMusic() end
	})
	MusicSection:Button({
		Title="停止音乐",
		Icon="square",
		Callback=function() stopMusic() end
	})
	MusicSection:Toggle({
		Title="循环播放",
		Default=false,
		Callback=function(v)
			MusicRuntime.looped = v == true
			local sound = MusicRuntime.sound
			if sound then sound.Looped = MusicRuntime.looped end
		end
	})
	MusicSection:Slider({
		Title="音乐音量",
		Value={Min=0,Max=100,Default=50},
		Step=1,
		Callback=function(v)
			MusicRuntime.volume = math.clamp((tonumber(v) or 50)/100, 0, 1)
			local sound = MusicRuntime.sound
			if sound then sound.Volume = MusicRuntime.volume end
		end
	})

	MusicTab:Paragraph({
		Title="使用说明",
		Desc="输入音频 ID → 播放音乐。音乐通过 SoundService 在当前客户端播放；音频是否可用取决于 Roblox 的资源权限与可访问性。",
		Image="info",
		ImageSize=22
	})

	local CombatTab = mainWindow:Tab({Title = "战斗辅助", Icon = "crosshair", Locked = false})
	local CombatQuick = CombatTab:Section({Title = "战斗辅助", Icon = "crosshair", Opened = true})
	CombatQuick:Toggle({Title = "自瞄", Default = AimConfig.enabled, Callback = function(v) AimConfig.enabled = v end})
	CombatQuick:Toggle({Title = "自瞄 FOV", Default = AimConfig.showFov, Callback = function(v) AimConfig.showFov = v end})
	CombatQuick:Toggle({Title = "队伍检测", Default = AimConfig.teamCheck, Callback = function(v) AimConfig.teamCheck = v end})
	CombatQuick:Toggle({Title = "好友检测", Default = AimConfig.friendCheck, Callback = function(v) AimConfig.friendCheck = v end})
	CombatQuick:Toggle({Title = "墙壁检测", Default = AimConfig.wallCheck, Callback = function(v) AimConfig.wallCheck = v end})
	CombatQuick:Dropdown({Title = "瞄准部位", Values = {"头","胸","左手","右手","左腿","右腿"}, Value = AimConfig.targetPart, Callback = function(v) AimConfig.targetPart = v end})
	CombatQuick:Slider({Title = "FOV大小", Value = {Min = 1, Max = 500, Default = AimConfig.fov}, Step = 1, Callback = function(v) AimConfig.fov = v end})
	CombatQuick:Slider({Title = "平滑度", Value = {Min = 1, Max = 10, Default = math.floor(AimConfig.smoothness * 10)}, Step = 1, Callback = function(v) AimConfig.smoothness = v / 10 end})

	CombatQuick:Toggle({Title="预测",Default=AimConfig.prediction,Callback=function(v) AimConfig.prediction=v end})
	CombatQuick:Toggle({Title="自瞄追踪线",Default=AimConfig.showTracer,Callback=function(v) AimConfig.showTracer=v end})
	CombatQuick:Toggle({Title="自瞄准心",Default=AimConfig.showCrosshair,Callback=function(v) AimConfig.showCrosshair=v end})
	CombatQuick:Toggle({Title="仅警察",Default=AimConfig.onlyPolice,Callback=function(v) AimConfig.onlyPolice=v end})
	CombatQuick:Toggle({Title="仅平民",Default=AimConfig.onlyCivilian,Callback=function(v) AimConfig.onlyCivilian=v end})
	CombatQuick:Toggle({Title="战斗状态检测",Default=AimConfig.combatCheck,Callback=function(v) AimConfig.combatCheck=v end})
	CombatQuick:Dropdown({Title="目标模式",Values={"准心最近","距离最近","生命最低"},Value=AimConfig.targetMode,Callback=function(v) AimConfig.targetMode=v end})
	CombatQuick:Slider({Title="FOV线宽",Value={Min=1,Max=5,Default=AimConfig.fovThickness},Step=1,Callback=function(v) AimConfig.fovThickness=tonumber(v) or 2 end})

	local InteractionTab = mainWindow:Tab({Title = "快速交互", Icon = "hand", Locked = false})
	local Interaction = InteractionTab:Section({Title = "快速交互", Icon = "hand", Opened = true})
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

	Interaction:Toggle({Title="自动触发附近交互",Default=false,Callback=function(v) disconnectUniversal("prompt"); if v then universalConnections.prompt=ProximityPromptService.PromptShown:Connect(function(prompt) pcall(function() if prompt.Enabled then fireproximityprompt(prompt) end end) end) end end})
	Interaction:Button({Title="刷新交互状态",Icon="refresh-cw",Callback=function() pcall(function() WindUI:Notify({Title="快速交互",Content="已刷新当前场景交互状态",Duration=2}) end) end})

	Interaction:Toggle({Title="仅近距离自动交互",Default=true,Callback=function(v) FastInteractConfig.nearOnly=v end})
	Interaction:Slider({Title="自动交互冷却",Value={Min=0.1,Max=3,Default=0.5},Step=0.1,Callback=function(v) FastInteractConfig.cooldown=tonumber(v) or 0.5 end})
	Interaction:Button({Title="扫描附近交互",Icon="search",Callback=function() local n=0; for _,o in ipairs(Workspace:GetDescendants()) do if o:IsA("ProximityPrompt") and o.Enabled then n+=1 end end; pcall(function() WindUI:Notify({Title="交互扫描",Content="当前场景发现 "..n.." 个可用交互",Duration=3}) end) end})
	Interaction:Button({Title="关闭全部快速交互",Icon="x",Callback=function() disconnectUniversal("prompt"); FastInteractConfig.enabled=false; FastInteractConfig.instant=false end})

	local TeleportTab = mainWindow:Tab({Title = "传送", Icon = "map-pin", Locked = false})
	local TeleportTools = TeleportTab:Section({Title = "传送", Icon = "map-pin", Opened = true})
	
	local SpectateSection = TeleportTab:Section({Title="查看他人视野", Icon="eye", Opened=false})
	local SpectateDropdown = SpectateSection:Dropdown({
	    Title="选择玩家",
	    Values=(function() local t={}; for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then table.insert(t,p.Name) end end; if #t==0 then t={"暂无其他玩家"} end; return t end)(),
	    Value=(function() for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then return p.Name end end; return "暂无其他玩家" end)(),
	    SearchBarEnabled=true,
	    Callback=function(v) AioveSpectate.target=tostring(v or "") end
	})
	SpectateSection:Button({Title="刷新玩家列表",Icon="refresh-cw",Callback=function()
	    local t={}; for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then table.insert(t,p.Name) end end; if #t==0 then t={"暂无其他玩家"} end
	    pcall(function() SpectateDropdown:Refresh(t) end)
	end})
	SpectateSection:Toggle({Title="查看他人视野",Default=false,Callback=function(v)
	    if v then
	        if not startSpectate(AioveSpectate.target) then
	            pcall(function() WindUI:Notify({Title="查看他人视野",Content="目标不存在或角色尚未加载",Duration=2.5}) end)
	        end
	    else stopSpectate() end
	end})
	SpectateSection:Button({Title="停止查看",Icon="eye-off",Callback=function() stopSpectate() end})
	
	
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
			end
		end
	})
	TeleportTools:Slider({
		Title = "循环间隔（秒）",
		Value = {Min = 0.1, Max = 3, Default = TeleportPlayerConfig.loopInterval},
		Step = 0.1,
		Callback = function(v) TeleportPlayerConfig.loopInterval = math.clamp(tonumber(v) or 0.35, 0.1, 3) end
	})

	TeleportTools:Button({Title="传送到出生点",Icon="home",Callback=function() local c=LocalPlayer.Character; local r=c and c:FindFirstChild("HumanoidRootPart"); local sp=Workspace:FindFirstChildOfClass("SpawnLocation"); if r and sp then r.CFrame=sp.CFrame+Vector3.new(0,4,0) end end})
	TeleportTools:Button({Title="复制当前坐标",Icon="copy",Callback=function() local _,_,r=GetCharacter(LocalPlayer); if r and setclipboard then local p=r.Position; pcall(function() setclipboard(string.format("%.2f, %.2f, %.2f",p.X,p.Y,p.Z)) end) end end})
	TeleportTools:Button({Title="保存当前位置",Icon="bookmark",Callback=function() local _,_,r=GetCharacter(LocalPlayer); if r then RespawnConfig.lastCFrame=r.CFrame end end})

	TeleportTools:Toggle({Title="Click TP",Default=false,Callback=function(v)
		disconnectUniversal("clickTP")
		if v then universalConnections.clickTP=UserInputService.InputBegan:Connect(function(input,processed) if processed or input.UserInputType~=Enum.UserInputType.MouseButton1 then return end; local mouse=LocalPlayer:GetMouse(); if mouse and mouse.Hit then teleportTo(mouse.Hit.Position) end end) end
	end})
	TeleportTools:Toggle({Title="坐标 HUD",Default=false,Callback=function(v) if v then createCoordHUD() else destroyCoordHUD() end end})

	TeleportTools:Button({Title="传送到最近玩家",Icon="navigation",Callback=function() local best,dist=nil,math.huge; local _,_,me=GetCharacter(LocalPlayer); if me then for _,pl in ipairs(Players:GetPlayers()) do if pl~=LocalPlayer then local _,_,r=GetCharacter(pl); if r then local d=(me.Position-r.Position).Magnitude; if d<dist then dist=d; best=pl end end end end end; if best then teleportNearPlayer(best,"后方",3) end end})
	TeleportTools:Button({Title="传送到最远玩家",Icon="maximize",Callback=function() local best,dist=nil,-1; local _,_,me=GetCharacter(LocalPlayer); if me then for _,pl in ipairs(Players:GetPlayers()) do if pl~=LocalPlayer then local _,_,r=GetCharacter(pl); if r then local d=(me.Position-r.Position).Magnitude; if d>dist then dist=d; best=pl end end end end end; if best then teleportNearPlayer(best,"后方",3) end end})
	TeleportTools:Button({Title="返回上次位置",Icon="corner-left-up",Callback=function() if RespawnConfig.lastCFrame then local c=LocalPlayer.Character; if c then pcall(function() c:PivotTo(RespawnConfig.lastCFrame) end) end end end})
	TeleportTools:Button({Title="保存当前位置并复制",Icon="save",Callback=function() local _,_,r=GetCharacter(LocalPlayer); if r then RespawnConfig.lastCFrame=r.CFrame; if setclipboard then pcall(function() local q=r.Position; setclipboard(string.format("%.2f, %.2f, %.2f",q.X,q.Y,q.Z)) end) end end end})

	local PlayerTab = mainWindow:Tab({Title = "玩家功能", Icon = "user", Locked = false})
	local PlayerTools = PlayerTab:Section({Title = "玩家功能", Icon = "user", Opened = true})
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



	PlayerTools:Slider({Title="本地透明度",Value={Min=0,Max=100,Default=0},Step=5,Callback=function(v) local c=LocalPlayer.Character; if c then for _,o in ipairs(c:GetDescendants()) do if o:IsA("BasePart") then o.LocalTransparencyModifier=(tonumber(v) or 0)/100 end end end end})
	PlayerTools:Button({Title="刷新角色",Icon="refresh-cw",Callback=function() pcall(function() LocalPlayer:LoadCharacter() end) end})
	PlayerTools:Button({Title="显示玩家数量",Icon="users",Callback=function() pcall(function() WindUI:Notify({Title="玩家数量",Content=tostring(#Players:GetPlayers()).." 名玩家",Duration=3}) end) end})
	PlayerTools:Button({Title="显示本地坐标",Icon="map-pin",Callback=function() local _,_,r=GetCharacter(LocalPlayer); if r then local p=r.Position; pcall(function() WindUI:Notify({Title="坐标",Content=string.format("%.2f / %.2f / %.2f",p.X,p.Y,p.Z),Duration=3}) end) end end})

	PlayerTools:Button({Title="重置角色",Icon="refresh-cw",Callback=function() local _,h=GetCharacter(LocalPlayer); if h then pcall(function() h.Health=0 end) end end})
	PlayerTools:Button({Title="复制/显示当前坐标",Icon="map-pin",Callback=function() local _,_,r=GetCharacter(LocalPlayer); if r then local pp=r.Position; local text=string.format("X %.2f / Y %.2f / Z %.2f",pp.X,pp.Y,pp.Z); if setclipboard then pcall(function() setclipboard(string.format("%.2f, %.2f, %.2f",pp.X,pp.Y,pp.Z)) end) end; pcall(function() WindUI:Notify({Title="当前位置",Content=text,Duration=3}) end) end end})

	PlayerTools:Toggle({Title="锁定朝向",Default=false,Callback=function(v) disconnectUniversal("lockFacing"); if v then universalConnections.lockFacing=RunService.Heartbeat:Connect(function() local c=Workspace.CurrentCamera; local _,_,r=GetCharacter(LocalPlayer); if c and r then r.CFrame=CFrame.lookAt(r.Position,r.Position+c.CFrame.LookVector*Vector3.new(1,0,1)) end end) end end})
	PlayerTools:Toggle({Title="本地角色发光",Default=false,Callback=function(v) local c=LocalPlayer.Character; if c then local h=c:FindFirstChild("AioveLocalHighlight"); if v and not h then h=Instance.new("Highlight"); h.Name="AioveLocalHighlight"; h.Parent=c; elseif not v and h then h:Destroy() end end end})
	PlayerTools:Toggle({Title="隐藏本地名称",Default=false,Callback=function(v) local c=LocalPlayer.Character; local h=c and c:FindFirstChildOfClass("Humanoid"); if h then h.DisplayDistanceType=v and Enum.HumanoidDisplayDistanceType.None or Enum.HumanoidDisplayDistanceType.Viewer end end})
	PlayerTools:Button({Title="复制用户名",Icon="copy",Callback=function() if setclipboard then pcall(function() setclipboard(LocalPlayer.Name) end) end end})
	PlayerTools:Button({Title="复制 UserId",Icon="copy",Callback=function() if setclipboard then pcall(function() setclipboard(tostring(LocalPlayer.UserId)) end) end end})
	PlayerTools:Button({Title="复制显示名称",Icon="copy",Callback=function() if setclipboard then pcall(function() setclipboard(LocalPlayer.DisplayName) end) end end})
	PlayerTools:Button({Title="显示账号年龄",Icon="calendar",Callback=function() pcall(function() WindUI:Notify({Title="账号年龄",Content=tostring(LocalPlayer.AccountAge).." 天",Duration=3}) end) end})
	PlayerTools:Button({Title="显示当前队伍",Icon="users",Callback=function() pcall(function() WindUI:Notify({Title="当前队伍",Content=LocalPlayer.Team and LocalPlayer.Team.Name or "无队伍",Duration=3}) end) end})

	local ServerTab = mainWindow:Tab({Title = "网络 / 服务器", Icon = "server", Locked = false})
	local ServerTools = ServerTab:Section({Title = "网络 / 服务器", Icon = "server", Opened = true})

	ServerTools:Button({Title="显示游戏信息",Icon="info",Callback=function() local text=string.format("PlaceId: %s\\nJobId: %s\\n玩家: %d",tostring(game.PlaceId),tostring(game.JobId),#Players:GetPlayers()); pcall(function() WindUI:Notify({Title="游戏信息",Content=text,Duration=5}) end); if setclipboard then pcall(function() setclipboard(text) end) end end})
	ServerTools:Button({Title="统计场景对象",Icon="bar-chart-3",Callback=function() local c={parts=0,models=0,prompts=0}; for _,o in ipairs(Workspace:GetDescendants()) do if o:IsA("BasePart") then c.parts+=1 elseif o:IsA("Model") then c.models+=1 elseif o:IsA("ProximityPrompt") then c.prompts+=1 end end; pcall(function() WindUI:Notify({Title="场景统计",Content=string.format("Part %d | Model %d | Prompt %d",c.parts,c.models,c.prompts),Duration=5}) end) end})
	ServerTools:Button({Title="复制服务器 JobId",Icon="copy",Callback=function() if setclipboard then pcall(function() setclipboard(tostring(game.JobId)) end) end end})
	ServerTools:Button({Title="复制 PlaceId",Icon="copy",Callback=function() if setclipboard then pcall(function() setclipboard(tostring(game.PlaceId)) end) end end})
	ServerTools:Paragraph({Title = "说明", Desc = "部分功能依赖游戏自身的服务器权限；客户端功能无法保证绕过服务器校验。"})
	ServerTools:Button({Title = "重新加入当前服务器", Icon = "refresh-cw", Callback = function() pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end) end})
	ServerTools:Button({Title = "重新加入游戏", Icon = "rotate-ccw", Callback = function() pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end) end})


	-- 圣奥里仅保留独立脚本入口；本文件不包含其功能实现。
	local SAINT_SCRIPT_URL = "https://raw.githubusercontent.com/AioveCN/RobloxScripts/main/AioveCN_Hub_%E7%A8%B3%E5%AE%9A%E4%BF%AE%E6%AD%A3%E7%89%88.lua"
	local SAINT_LOADSTRING = 'loadstring(game:HttpGet("' .. SAINT_SCRIPT_URL .. '"))()'

	ServerTools:Button({Title="复制 JobId",Icon="copy",Callback=function() if setclipboard then pcall(function() setclipboard(tostring(game.JobId)) end) end end})
	ServerTools:Button({Title="复制 PlaceId",Icon="copy",Callback=function() if setclipboard then pcall(function() setclipboard(tostring(game.PlaceId)) end) end end})
	ServerTools:Button({Title="统计当前玩家",Icon="users",Callback=function() pcall(function() WindUI:Notify({Title="服务器玩家",Content=tostring(#Players:GetPlayers()).." 人",Duration=3}) end) end})
	ServerTools:Button({Title="统计场景对象",Icon="bar-chart-3",Callback=function() local parts,models,prompts=0,0,0; for _,o in ipairs(Workspace:GetDescendants()) do if o:IsA("BasePart") then parts+=1 elseif o:IsA("Model") then models+=1 elseif o:IsA("ProximityPrompt") then prompts+=1 end end; pcall(function() WindUI:Notify({Title="场景统计",Content=string.format("Part %d | Model %d | Prompt %d",parts,models,prompts),Duration=4}) end) end})

	local SaintTab = mainWindow:Tab({
		Title = "圣奥里",
		Icon = "zap",
		Locked = false
	})
	local SaintSection = SaintTab:Section({
		Title = "圣奥里 · 独立脚本",
		Icon = "external-link",
		Opened = true
	})
	SaintSection:Paragraph({
		Title = "独立脚本说明",
		Desc = "圣奥里不再并入 Aiove HUB；点击下方按钮可单独启动。\n源码地址：AioveCN/RobloxScripts"
	})
	SaintSection:Button({
		Title = "启动圣奥里脚本",
		Icon = "play",
		Callback = function()
			local ok, err = pcall(function()
				loadstring(game:HttpGet(SAINT_SCRIPT_URL))()
			end)
			if ok then
				pcall(function() WindUI:Notify({Title = "圣奥里", Content = "独立脚本已启动", Duration = 2.5}) end)
			else
				warn("[Aiove HUB] 圣奥里启动失败：", err)
				pcall(function() WindUI:Notify({Title = "圣奥里", Content = "启动失败：" .. tostring(err), Duration = 5}) end)
			end
		end
	})
	SaintSection:Button({
		Title = "一键复制圣奥里代码",
		Icon = "copy",
		Callback = function()
			if type(setclipboard) == "function" then
				local ok, err = pcall(function() setclipboard(SAINT_LOADSTRING) end)
				if ok then
					pcall(function() WindUI:Notify({Title = "复制成功", Content = "圣奥里 loadstring 已复制到剪切板", Duration = 2.5}) end)
				else
					pcall(function() WindUI:Notify({Title = "复制失败", Content = tostring(err), Duration = 4}) end)
				end
			else
				pcall(function() WindUI:Notify({Title = "无法复制", Content = "当前执行环境没有提供 setclipboard", Duration = 4}) end)
			end
		end
	})

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

	mainWindow:OnClose(function()
		-- 最小化/关闭主窗口时保留已启用的悬浮开关，避免悬浮窗跟着消失。
		isWindowOpen = false
	end)
	mainWindow:OnDestroy(function()
		stopTeleportLoop()
		aioveStopWaypointLoop()
		aioveDestroyWaypointTool()
		destroyPlayerQuick()
		destroyNoclipQuick()
		if clockConnection then pcall(function() clockConnection:Disconnect() end); clockConnection = nil end
		stopHoverWalk()
		stopAntiFling()
		stopSpectate()
		isWindowOpen = false
		mainWindow = nil
	end)
end
aioveStartupReady = type(createMainWindow) == "function"
if aioveStartupReady then
	setAioveStartupStatus("加载完成，点击打开")
else
	setAioveStartupStatus("主界面初始化失败，请重新执行")
end

-- 已移除第三方执行上报逻辑：脚本不再向外部服务器发送卡密、账号、JobId 或执行器信息。
