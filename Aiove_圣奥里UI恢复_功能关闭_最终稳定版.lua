--AioveCN Hub 开源版本
--请各位开发者不要用于付费项目

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
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
		warn("[AioveCN Hub] WindUI 加载失败: " .. tostring(result))
		return
	end
	WindUI = result
end
local SETTINGS_FILE = "AioveCN_Hub_Settings.txt"
local settings = {
	randomBg = true,
	borderColor = nil,
	isBorderRainbow = true,
	borderEnabled = false,
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

local function addDisabledToggle(tab, title)
	tab:Toggle({
		Title = title,
		Default = false,
		Callback = function(_) end
	})
end
local function addDisabledSlider(tab, title, minValue, maxValue, defaultValue)
	tab:Slider({
		Title = title,
		Value = {Min = minValue, Max = maxValue, Default = defaultValue},
		Callback = function(_) end
	})
end

local function createMainWindow()
	if isWindowOpen and mainWindow then
		return
	end
	isWindowOpen = true
	mainWindow = WindUI:CreateWindow({
		Title = "欢迎您的使用",
		Icon = "zap",
		IconTransparency = 0.5,
		IconThemed = true,
		Author = "AioveCN",
		Folder = "AioveCNHub",
		Size = UDim2.fromOffset(640, 460),
		Transparent = true,
		Theme = "Dark",
		User = {Enabled = false, Callback = function() end, Anonymous = false},
		SideBarWidth = 200,
		ScrollBarEnabled = true,
		Background = getRandomBackground(),
		BackgroundImageTransparency = 0.4,
	})

	local InfoTab = mainWindow:Tab({Title = "信息", Icon = "info", Locked = false})
	local Info = InfoTab:Section({Title = "信息", Opened = true})
	Info:Paragraph({Title = "欢迎您的使用 Aiove HUB!", Desc = "本脚本仅供学习交流，请勿用于非法用途。", Image = "sparkles", ImageSize = 32})
	Info:Paragraph({Title = "QQ反馈：3593722551", Desc = "如有问题可以通过 QQ 反馈。", Image = "message-circle", ImageSize = 28})
	Info:Paragraph({Title = "当前服务器", Desc = "PlaceId：" .. tostring(game.PlaceId), Image = "server", ImageSize = 28})
	local InfoSettings = InfoTab:Section({Title = "UI设置", Opened = false})
	InfoSettings:Toggle({Title = "自定义光标", Value = false, Callback = function(v) pcall(function() mainWindow:ToggleCustomCursor(v) end) end})
	InfoSettings:Dropdown({Title = "通知位置", Values = {"左", "右"}, Value = "右", Callback = function(v) pcall(function() WindUI:SetNotifySide(v == "左" and "Left" or "Right") end) end})
	InfoSettings:Dropdown({Title = "DPI缩放", Values = {"75%", "100%", "125%", "150%"}, Value = "100%", Callback = function(v) local n = tonumber(v:gsub("%%", "")); if n then pcall(function() mainWindow:SetDPIScale(n / 100) end) end end})

	local GeneralTab = mainWindow:Tab({Title = "通用", Icon = "sliders-horizontal", Locked = false})
	local General = GeneralTab:Section({Title = "通用功能", Opened = true})
	General:Paragraph({Title = "通用功能", Desc = "当前版本仅保留 UI，功能默认全部关闭。", Image = "info", ImageSize = 28})
	addDisabledToggle(General, "无限体力")
	addDisabledToggle(General, "无限饥饿")
	addDisabledToggle(General, "无限跳跃")
	addDisabledToggle(General, "飞行")
	addDisabledToggle(General, "无碰撞")
	addDisabledToggle(General, "防挂机")
	addDisabledSlider(General, "移动速度", 16, 300, 16)
	addDisabledSlider(General, "跳跃高度", 50, 400, 50)

	-- 恢复圣奥里 UI，但不加载 99_Aiove_圣奥里.lua，也不启动其后台功能。
	local SaintTab = mainWindow:Tab({Title = "圣奥里", Icon = "map", Locked = false})
	local Saint = mainWindow:Section({Title = "圣奥里功能", Opened = true})
	Saint:Paragraph({Title = "Aiove · 圣奥里", Desc = "UI 已恢复；所有功能当前关闭。", Image = "map", ImageSize = 32})

	local Main = Saint:Tab({Title = "主要功能", Icon = "sliders-h"})
	addDisabledToggle(Main, "无限体力")
	addDisabledToggle(Main, "无限饥饿")
	addDisabledToggle(Main, "战斗拦截")
	addDisabledToggle(Main, "幽灵模式")
	addDisabledToggle(Main, "防倒地")
	addDisabledToggle(Main, "防摔伤")

	local Money = Saint:Tab({Title = "金钱", Icon = "dollar-sign"})
	addDisabledToggle(Money, "自动赚钱")
	addDisabledToggle(Money, "自动任务")
	addDisabledToggle(Money, "自动破解")
	addDisabledToggle(Money, "高尔夫循环")

	local Combat = Saint:Tab({Title = "Combat", Icon = "swords"})
	addDisabledToggle(Combat, "无限弹药")
	addDisabledToggle(Combat, "快速射击")
	addDisabledToggle(Combat, "范围攻击")
	addDisabledSlider(Combat, "攻击范围", 10, 500, 150)

	local Aim = Saint:Tab({Title = "Aim", Icon = "crosshair"})
	addDisabledToggle(Aim, "自瞄")
	addDisabledToggle(Aim, "显示 FOV")
	addDisabledToggle(Aim, "预测")
	addDisabledToggle(Aim, "墙壁检测")
	addDisabledSlider(Aim, "FOV圈大小", 1, 500, 50)

	local Rage = Saint:Tab({Title = "Ragebot", Icon = "bot"})
	addDisabledToggle(Rage, "Ragebot")
	addDisabledToggle(Rage, "职业检测")
	addDisabledToggle(Rage, "墙壁检测")
	addDisabledToggle(Rage, "活体检测")
	addDisabledToggle(Rage, "锁定警察")
	addDisabledToggle(Rage, "锁定平民")
	addDisabledSlider(Rage, "攻击距离", 10, 500, 150)

	local Hitbox = Saint:Tab({Title = "范围", Icon = "bullseye"})
	addDisabledToggle(Hitbox, "开启/关闭范围")
	addDisabledToggle(Hitbox, "NPC范围")
	addDisabledToggle(Hitbox, "队伍检测")
	addDisabledToggle(Hitbox, "显示轮廓")
	addDisabledToggle(Hitbox, "发光效果")
	addDisabledSlider(Hitbox, "范围大小", 1, 100, 10)

	local PlayerTab = Saint:Tab({Title = "玩家", Icon = "user"})
	addDisabledToggle(PlayerTab, "开启/关闭跳跃")
	addDisabledToggle(PlayerTab, "无限跳跃")
	addDisabledToggle(PlayerTab, "飞行")
	addDisabledSlider(PlayerTab, "设置跳跃高度", 50, 400, 50)
	addDisabledSlider(PlayerTab, "飞行速度", 10, 200, 50)

	local Police = Saint:Tab({Title = "警察功能", Icon = "handcuffs"})
	addDisabledToggle(Police, "自动铐")
	addDisabledToggle(Police, "自动传送")
	addDisabledToggle(Police, "战斗检测")
	addDisabledSlider(Police, "范围", 10, 500, 200)
	addDisabledSlider(Police, "间隔", 0.1, 3, 0.5)

	local EspTab = Saint:Tab({Title = "ESP", Icon = "eye"})
	addDisabledToggle(EspTab, "玩家透视总开关")
	addDisabledToggle(EspTab, "显示名字")
	addDisabledToggle(EspTab, "显示距离")
	addDisabledToggle(EspTab, "显示血量")
	addDisabledToggle(EspTab, "显示高亮")
	addDisabledToggle(EspTab, "显示追踪线")

	local OtherSaint = Saint:Tab({Title = "其他", Icon = "more-horizontal"})
	addDisabledToggle(OtherSaint, "自动铐")
	addDisabledToggle(OtherSaint, "自动任务")
	addDisabledToggle(OtherSaint, "隐身")

	local OtherTab = mainWindow:Tab({Title = "其他服务器脚本", Icon = "gamepad-2", Locked = false})
	local OtherSection = OtherTab:Section({Title = "其他服务器脚本", Opened = true})
	local GITHUB_RAW_BASE = "https://raw.githubusercontent.com/AioveCN/RobloxScriptsAiove/main/"
	local MODULE_DIR = ""
	local function encodePathPart(value)
		return tostring(value):gsub("[^%w%._%-]", function(c) return string.format("%%%02X", string.byte(c)) end)
	end
	local function runAioveModule(fileName, displayName)
		local url = GITHUB_RAW_BASE .. encodePathPart(fileName)
		local source
		local okHttp, result = pcall(function() return game:HttpGet(url) end)
		if okHttp and type(result) == "string" and result ~= "" then source = result end
		if not source and type(readfile) == "function" then
			local okRead, localSource = pcall(readfile, MODULE_DIR .. fileName)
			if okRead and type(localSource) == "string" and localSource ~= "" then source = localSource end
		end
		if not source then
			warn("[Aiove] 无法读取：" .. url)
			return
		end
		local fn, err = loadstring(source)
		if type(fn) ~= "function" then warn("[Aiove] 编译失败：" .. tostring(err)); return end
		local okRun, runErr = pcall(fn)
		if not okRun then warn("[Aiove] " .. tostring(displayName) .. " 运行错误：" .. tostring(runErr)) end
	end
	local function addOtherServerScript(parent, fileName, displayName)
		parent:Button({Title = displayName, Desc = "Aiove · 独立源码：" .. fileName, Icon = "play", Callback = function() runAioveModule(fileName, displayName) end})
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

	mainWindow:OnClose(function() isWindowOpen = false; mainWindow = nil end)
	mainWindow:OnDestroy(function() isWindowOpen = false; mainWindow = nil end)
end
WindUI:Popup({
	Title = "欢迎您的使用",
	Icon = "sparkles",
	Content = "Aiove 综合脚本中心\n反馈：QQ：3593722551",
	Buttons = {{Title = "打开脚本", Variant = "Primary", Callback = createMainWindow}}
})
