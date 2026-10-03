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

if not game:IsLoaded() then
	game.Loaded:Wait()
end

if not isfolder("XA-Hub") then
	makefolder("XA-Hub")
end
if not isfolder("XA-Hub/Fluent") then
	makefolder("XA-Hub/Fluent")
end
if not isfile("XA-Hub/Fluent/AutoFindMoneyPrinter.txt") then
	writefile("XA-Hub/Fluent/AutoFindMoneyPrinter.txt", "false")
end

local autoFind = readfile("XA-Hub/Fluent/AutoFindMoneyPrinter.txt")
if autoFind == "true" then
	pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Xingtaiduan/Script/refs/heads/main/Games/俄亥俄州_印钞机.lua"))() end)
	return
end

local Options = Library.Options
local Toggles = Library.Toggles

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local lp = LocalPlayer
local plrs = Players
local ws = Workspace
local rs = ReplicatedStorage
local runService = RunService
local uis = UserInputService
local mouse = LocalPlayer:GetMouse()
local stepped = RunService.Stepped
local renderstepped = RunService.RenderStepped
local heartbeat = RunService.Heartbeat
local v3 = Vector3.new
local v3_0 = v3(0, 0, 0)
local cf = CFrame.new

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid", 5)
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 5)

local ESP
do
	local espOk, espRes = pcall(function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/Xingtaiduan/Script/refs/heads/main/ESPLibrary.lua"))()
	end)
	if espOk and espRes then
		ESP = espRes
	else
		local espFolder = Instance.new("Folder")
		espFolder.Name = "ESPFolder"
		ESP = {ESPFolder = espFolder}
		function ESP.Add(a, b, c, d, e)
			local obj, name, color, size, tag
			if type(a) == "table" then
				obj = a.Object
				name = a.Name
				color = a.Color
				size = a.TextSize
				tag = a.Tag
			else
				obj = a
				name = b
				color = c
				size = d
				tag = e
			end
			if not (typeof(obj) == "Instance" and obj.Parent) then return end
			local bb = Instance.new("BillboardGui")
			bb.Name = tag or "ESP"
			bb.Adornee = obj
			bb.AlwaysOnTop = true
			bb.Size = UDim2.new(0, 100, 0, 30)
			local tl = Instance.new("TextLabel")
			tl.BackgroundTransparency = 1
			tl.Size = UDim2.new(1, 0, 1, 0)
			tl.Text = tostring(name)
			tl.TextColor3 = color or Color3.new(1, 1, 1)
			tl.TextSize = size or 12
			tl.Font = Enum.Font.SourceSansBold
			tl.TextStrokeTransparency = 0.5
			tl.Parent = bb
			bb.Parent = espFolder
		end
		function ESP.Clear(tag)
			for _, v in pairs(espFolder:GetChildren()) do
				if v.Name == tag then
					v:Destroy()
				end
			end
		end
	end
end
ESP.ESPFolder.Parent = Workspace

local RemotesModule, Remotes, ClientReplicator, Inventory, dvvLoad, GUID
local ohioOk = pcall(function()
	RemotesModule = require(ReplicatedStorage.devv.client.Helpers.remotes.Signal)
	Remotes = debug.getupvalue(RemotesModule.FireServer, 1)
	ClientReplicator = require(ReplicatedStorage.devv.client.Helpers.objectProperties.ClientReplicator)
	Inventory = require(ReplicatedStorage.devv.client.Objects.v3item.modules.inventory)
	dvvLoad = require(ReplicatedStorage.devv).load
	GUID = dvvLoad("GUID")
end)

if not ohioOk then
	StarterGui:SetCore("SendNotification", {
		Title = "错误",
		Text = "当前游戏不是俄亥俄州，脚本已停止",
		Duration = 5,
	})
	return
end

local Window = Library:CreateWindow({
	Title = "俄亥俄州",
	Footer = "Aiove 制作",
	Icon = 131153193945220,
	NotifySide = "Right",
	ShowCustomCursor = true,
})

Library:Notify({
	Title = "俄亥俄州",
	Description = "创作者：Aiove\nQQ：3999698324\n脚本已加载成功",
	Time = 5,
})

local Tabs = {
	Notice = Window:AddTab("通知", "info"),
	Combat = Window:AddTab("战斗类", "info"),
	Items = Window:AddTab("物品", "info"),
	Auto = Window:AddTab("自动", "info"),
	Teleport = Window:AddTab("传送", "info"),
	Fun = Window:AddTab("娱乐", "info"),
	Player = Window:AddTab("玩家", "info"),
	Quick = Window:AddTab("快捷", "info"),
	Protect = Window:AddTab("防护", "info"),
	Bypass = Window:AddTab("绕过", "info"),
	Beautify = Window:AddTab("美化", "info"),
	Other = Window:AddTab("其他", "info"),
	Data = Window:AddTab("数据", "info"),
	Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel("Aiove将持续更新此脚本")
NoticeGroup:AddLabel("创作者：Aiove")
NoticeGroup:AddLabel("QQ：3999698324")

local function notify(msg)
	Library:Notify({
		Title = "俄亥俄州",
		Description = msg,
		Time = 3,
	})
end

local function gp(parent, name, className)
	local ret = nil
	pcall(function()
		for i, v in pairs(parent:GetChildren()) do
			if (v.Name == name) and v:IsA(className) then
				ret = v
				break
			end
		end
	end)
	return ret
end

local ancprt = nil
local function weldtp(part, cfr)
	if not (part and part.Parent and part:IsA("BasePart") and (not part:IsGrounded())) then
		return nil
	end
	if not (ancprt and ancprt.Parent and ancprt:IsA("BasePart") and ancprt:IsGrounded() and ancprt:IsDescendantOf(ws)) then
		for i, v in pairs(ws:GetDescendants()) do
			if v and v.Parent and v:IsA("BasePart") and v:IsGrounded() then
				ancprt = v
				break
			end
		end
	end
	if not ancprt then
		ancprt = Instance.new("Part", ws)
		ancprt.Anchored = true
		ancprt.Transparency = 1
		ancprt.CanCollide = false
		ancprt.Name = "weldtp part"
	end
	local weld = Instance.new("Weld")
	weld.Part0 = part
	weld.C0 = cfr:Inverse()
	weld.Part1 = ancprt
	weld.C1 = ancprt.CFrame:Inverse()
	weld.Parent = ws
	stepped:wait(0.1)
	pcall(function()
		weld:Destroy()
	end)
end

local SelectedTarget = nil
local Whitelist = {
	2953444466,
	5509421902
}
local ItemsOnSaleList = {}
local Locations = {
	["军械库"] = CFrame.new(671.68688964844, 6.2448601722717, -655.50268554688),
	["银行"] = CFrame.new(1091.5296630859, 6.0434188842773, -457.62033081055),
	["珠宝店"] = CFrame.new(1543.3168945312, 6.2433180809021, -682.63525390625),
	["警察局"] = CFrame.new(655.10638427734, 9.035834312439, -903.20697021484),
	["军事基地"] = CFrame.new(835.84875488281, 25.234800338745, -1327.0417480469),
	["医院"] = CFrame.new(1112.4508056641, 6.0434203147888, -973.91772460938),
	["游乐场"] = CFrame.new(1170.8796386719, 13.850684165955, -25.795112609863)
}

task.spawn(function()
	for _, item in pairs(Workspace.ItemsOnSale:GetChildren()) do
		ItemsOnSaleList[item.Name] = item.Name
	end

	for _, conn in pairs(getconnections(RunService.Heartbeat)) do
		local fn = conn.Function
		if fn and getfenv(fn).script == ReplicatedStorage.devv.client.Handlers.ClientValidate then
			conn:Disable()
			StarterGui:SetCore("SendNotification", {
				Title = "提示",
				Text = "飞行/速度封禁绕过成功"
			})
		end
	end

	getgenv().fixedremotes = {}
	for name, remote in next, RemotesModule do
		local upval = debug.getupvalue(remote, 1)
		if upval then
			getgenv().fixedremotes[name] = upval
		end
	end
end)

local function FindPlayer(input)
	local query = input:gsub("%s+", "")
	for _, player in pairs(Players:GetPlayers()) do
		if player.Name:lower():match("^" .. query:lower()) then
			return player
		end
		if player.DisplayName:lower():match("^" .. query:lower()) then
			return player
		end
	end
	StarterGui:SetCore("SendNotification", {
		Title = "错误",
		Text = "未找到玩家"
	})
	return nil
end

local function RefreshItemESP()
	for _, item in pairs(Workspace.Game.Entities.ItemPickup:GetChildren()) do
		for _, part in pairs(item:GetDescendants()) do
			if part:IsA("MeshPart") then
				for _, prompt in pairs(part:GetDescendants()) do
					if prompt:IsA("ProximityPrompt") then
						ESP.Add({
							Object = part,
							Name = prompt.ObjectText,
							Color = Color3.new(1, 1, 1),
							TextSize = 12,
							Tag = "ItemESP",
							ShowDistance = false
						})
					end
				end
			end
		end
	end
end

local OriginalNamecall
OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
	local args = {...}
	local method = getnamecallmethod()

	if checkcaller() then
		return OriginalNamecall(self, ...)
	end

	if method == "FireServer" and self == Remotes.meleeItemHit then
		if tostring(args[1]) == "player" and not table.find(Whitelist, args[2].hitPlayerId) then
			if Toggles.OnePunch and Toggles.OnePunch.Value then
				if not string.find(tostring(args[2].meleeType), "swing") then
					args[2].meleeType = "meleemegapunch"
				end
			end
			if Toggles.OneSwing and Toggles.OneSwing.Value then
				if string.find(tostring(args[2].meleeType), "swing") then
					args[2].meleeType = "meleemegaswing"
				end
			end
			return OriginalNamecall(self, unpack(args))
		end
	end

	if Toggles.Hitbox and Toggles.Hitbox.Value and method == "FireServer" and self == Remotes.projectileHit then
		local hitPart = args[2].hitPart
		local model = hitPart:FindFirstAncestorOfClass("Model")
		local hitPlayer = Players:GetPlayerFromCharacter(model)
		if model and hitPlayer then
			args[2].hitPart = model.Hitbox["Head_Hitbox"]
			args[2].hitPlayerId = hitPlayer.UserId
			args[2].hitSize = args[2].hitPart.Size
			args[2].pos = args[2].hitPart.Position
		end
		return OriginalNamecall(self, unpack(args))
	end

	return OriginalNamecall(self, ...)
end)

local WalkSpeedMoved = false
local JumpPowerMoved = false

LocalPlayer.CharacterAdded:Connect(function(char)
	Character = char
	Humanoid = char:WaitForChild("Humanoid")
	HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
	if Toggles.AutoEquip and Toggles.AutoEquip.Value then
		Remotes.FireServer("equip", Inventory.getFromName("Fists").guid)
	end
end)

RunService.RenderStepped:Connect(function()
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local char = player.Character
			if char then
				local hum = char:FindFirstChildOfClass("Humanoid")
				local hrp = char:FindFirstChild("HumanoidRootPart")
				if hum and hrp and not char:FindFirstChild("ForceField") and not table.find(Whitelist, player.UserId) then
					if Toggles.KillAura and Toggles.KillAura.Value then
						local dist = (HumanoidRootPart.Position - hrp.Position).Magnitude
						if dist < 35 and hum.Health > 5 then
							Remotes.FireServer("meleeItemHit", "player", {
								meleeType = "meleemegapunch",
								hitPlayerId = player.UserId
							})
						end
					end

					if Toggles.StompAura and Toggles.StompAura.Value then
						if ClientReplicator.Get(player, "knocked") then
							local dist = (HumanoidRootPart.Position - hrp.Position).Magnitude
							if dist < 30 then
								Remotes.FireServer("stomp", player)
							end
						end
					end

					if Toggles.GrabAura and Toggles.GrabAura.Value then
						if ClientReplicator.Get(player, "knocked") then
							local dist = (HumanoidRootPart.Position - hrp.Position).Magnitude
							if dist < 35 then
								Remotes.FireServer("grabPlayer", player)
							end
						end
					end
				end
			end
		end
	end

	if Toggles.Godmode and Toggles.Godmode.Value then
		if ClientReplicator.Get(LocalPlayer, "knocked") then
			ClientReplicator.Set(LocalPlayer, "knocked", false)
		end
	end

	if WalkSpeedMoved and Humanoid then
		Humanoid.WalkSpeed = Options.WalkSpeed.Value
	end
	if JumpPowerMoved and Humanoid then
		Humanoid.JumpPower = Options.JumpPower.Value
		Humanoid.UseJumpPower = true
	end

	if Toggles.Noclip and Toggles.Noclip.Value and Character then
		for _, part in pairs(Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end

	if Toggles.Fullbright and Toggles.Fullbright.Value then
		Lighting.Ambient = Color3.new(1, 1, 1)
	else
		Lighting.Ambient = Color3.new(0, 0, 0)
	end
end)

UserInputService.JumpRequest:Connect(function()
	if Toggles.InfJump and Toggles.InfJump.Value and Humanoid then
		Humanoid:ChangeState("Jumping")
	end
end)

local AirdropCallback = Instance.new("BindableFunction")

Workspace.Game.Entities.ItemPickup.DescendantAdded:Connect(function(obj)
	if Toggles.SItemsFarm and Toggles.SItemsFarm.Value and obj:IsA("ProximityPrompt") then
		local v = Options.SelectedItems.Value
		local match = (v["红卡"] and obj.ObjectText == "Military Armory Keycard")
			or (v["蓝卡"] and obj.ObjectText == "Police Armory Keycard")
			or (v["印钞机"] and obj.ObjectText == "Money Printer")
			or (v["气球"] and obj.ObjectText:match("Balloon"))
		if match then
			local savedCF = HumanoidRootPart.CFrame
			Character:PivotTo(obj.Parent:GetPivot())
			task.wait()
			for i = 1, 5 do
				fireproximityprompt(obj)
				task.wait(0.1)
			end
			if Toggles.ReturnOnTeleport and Toggles.ReturnOnTeleport.Value then
				Character:PivotTo(savedCF)
			end
		end
	end
end)

Workspace.Game.Entities.ItemPickup.ChildAdded:Connect(function()
	if Toggles.ItemESP and Toggles.ItemESP.Value then
		ESP.Clear("ItemESP")
		RefreshItemESP()
	end
end)

Workspace.Game.Airdrops.ChildAdded:Connect(function(airdrop)
	if not (Toggles.NotifyAirdrop and Toggles.NotifyAirdrop.Value) then return end
	StarterGui:SetCore("SendNotification", {
		Title = "空投已刷新",
		Text = "是否传送到空投？",
		Duration = 5,
		Button1 = "是",
		Button2 = "否",
		Callback = AirdropCallback
	})
	AirdropCallback.OnInvoke = function(response)
		if response == "是" then
			Character:PivotTo(airdrop:GetPivot())
		end
	end
end)

Workspace.Game.Entities.CashBundle.ChildAdded:Connect(function(obj)
	if not (Toggles.CashESP and Toggles.CashESP.Value) then return end
	task.delay(0.2, function()
		local intVal = obj:FindFirstChildOfClass("IntValue")
		if intVal then
			ESP.Add(obj, intVal.Value, Color3.fromRGB(23, 255, 42), 10, "CashESP")
		end
	end)
end)

getgenv().TrailColors = {
	StartColor = Color3.fromRGB(200, 180, 255),
	EndColor = Color3.fromRGB(140, 100, 220),
	MiddleColor1 = Color3.fromRGB(180, 150, 240),
	MiddleColor2 = Color3.fromRGB(160, 130, 230)
}

local function createBeautifulTrail(origin, targetPos)
	local trailContainer = Instance.new("Folder")
	trailContainer.Name = "MagicTrail"
	trailContainer.Parent = Workspace

	local midPoint = (origin + targetPos) / 2
	local direction = (targetPos - origin).Unit
	local perpendicular = Vector3.new(-direction.Z, direction.Y, direction.X) * 3
	local controlPoint = midPoint + perpendicular + Vector3.new(0, math.random(-3, 3), 0)

	local function createBezierCurve(p0, p1, p2, t)
		return (1 - t)^2 * p0 + 2 * (1 - t) * t * p1 + t^2 * p2
	end

	local curvePoints = {}
	local numSegments = 20

	for i = 0, numSegments do
		local t = i / numSegments
		local point = createBezierCurve(origin, controlPoint, targetPos, t)
		table.insert(curvePoints, point)
	end

	for i = 1, #curvePoints - 1 do
		local startPoint = curvePoints[i]
		local endPoint = curvePoints[i + 1]
		local distance = (endPoint - startPoint).Magnitude

		local beamPart = Instance.new("Part")
		beamPart.Size = Vector3.new(0.15, 0.15, distance)
		beamPart.Anchored = true
		beamPart.CanCollide = false
		beamPart.Material = Enum.Material.Neon
		beamPart.Transparency = 0.3
		beamPart.CFrame = CFrame.new(startPoint, endPoint) * CFrame.new(0, 0, -distance / 2)
		beamPart.Parent = trailContainer

		local t = i / (#curvePoints - 1)
		local color
		if t < 0.3 then
			color = getgenv().TrailColors.StartColor or Color3.fromRGB(200, 180, 255)
		elseif t < 0.6 then
			color = getgenv().TrailColors.MiddleColor1 or Color3.fromRGB(180, 150, 240)
		elseif t < 0.9 then
			color = getgenv().TrailColors.MiddleColor2 or Color3.fromRGB(160, 130, 230)
		else
			color = getgenv().TrailColors.EndColor or Color3.fromRGB(140, 100, 220)
		end

		beamPart.Color = color

		local pointLight = Instance.new("PointLight")
		pointLight.Brightness = 5
		pointLight.Range = 3
		pointLight.Color = color
		pointLight.Parent = beamPart

		local particles = Instance.new("ParticleEmitter")
		particles.Size = NumberSequence.new(0.1, 0.3)
		particles.Transparency = NumberSequence.new(0.3, 0.8)
		particles.Lifetime = NumberRange.new(0.5, 1)
		particles.Rate = 50
		particles.Speed = NumberRange.new(1, 2)
		particles.VelocitySpread = 180
		particles.Color = ColorSequence.new(color)
		particles.Parent = beamPart
	end

	task.delay(1.5, function()
		if trailContainer and trailContainer.Parent then
			trailContainer:Destroy()
		end
	end)

	return trailContainer
end

local dvv = require(rs.devv)
local sig = dvv.load("Signal")
local guid = dvv.load("GUID")
local inv = dvv.load("v3item").inventory

local dartOn = false
local dartTeleportTargets = false
local dartCachedHitId = nil
local dartCurrentTarget = nil
local dartHeartConnections = {}
local dartNinjaStarBuyThread = nil

local function dartCleanupConnections()
	for _, conn in ipairs(dartHeartConnections) do
		if conn then conn:Disconnect() end
	end
	dartHeartConnections = {}
end

local function dartEquipNinjaStar()
	local itm = inv.getItems and inv.getItems() or inv.items or {}
	for _, v in next, itm do
		if v.name == "Ninja Star" then
			sig.FireServer("equip", v.guid)
			return v.guid
		end
	end
	return nil
end

local function dartInitThrow()
	local sg = dartEquipNinjaStar()
	if not sg then return end

	local c = lp.Character
	if not c then return end

	local rh = c:FindFirstChild("RightHand")
	local hrp = c:FindFirstChild("HumanoidRootPart")
	if not rh or not hrp then return end

	local mp = rh.Position + Vector3.new(0, 0.5, 0)
	local tp = mp + Vector3.new(50, 0, 0)
	local vel = (tp - mp).Unit * 150

	createBeautifulTrail(mp, tp)

	local ok, r1, hid = pcall(function()
		return sig.InvokeServer("throwSticky", guid(), "Ninja Star", sg, vel, tp)
	end)

	if ok and r1 and hid then
		dartCachedHitId = hid
	end
end

local function dartHasShield(targetPlayer)
	if not targetPlayer or not targetPlayer.Character then return false end

	local char = targetPlayer.Character
	local humanoid = char:FindFirstChild("Humanoid")
	if not humanoid then return false end

	for _, desc in pairs(char:GetDescendants()) do
		if desc:IsA("ForceField") then
			return true
		end
	end

	return false
end

local function dartFindValidTarget()
	local closest = nil
	local minDist = math.huge
	local myPos = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and lp.Character.HumanoidRootPart.Position

	if not myPos then return nil end

	for _, player in ipairs(plrs:GetPlayers()) do
		if player ~= lp and player.Character then
			local char = player.Character
			local humanoid = char:FindFirstChild("Humanoid")
			local head = char:FindFirstChild("Head")
			local hrp = char:FindFirstChild("HumanoidRootPart")

			if humanoid and head and hrp and humanoid.Health > 0 and not dartHasShield(player) then
				local dist = (hrp.Position - myPos).Magnitude
				if dist < minDist and dist <= 50 then
					minDist = dist
					closest = {player = player, head = head}
				end
			end
		end
	end
	return closest
end

local function dartRapidThrowAttack()
	if not dartOn or not dartCachedHitId then return end

	local targetData = dartFindValidTarget()
	if not targetData then return end

	local head = targetData.head
	local tp = head.Position
	local wcf = CFrame.new(tp, tp + Vector3.new(0, 1, 0))
	local rcf = CFrame.new(0, 0, 0)

	local c = lp.Character
	if c and c:FindFirstChild("RightHand") then
		local rh = c:FindFirstChild("RightHand")
		createBeautifulTrail(rh.Position, tp)
	end

	for i = 1, 15 do
		sig.InvokeServer("hitSticky", dartCachedHitId, head, rcf, wcf)
	end
end

local function dartFindNextTeleportTarget()
	local players = plrs:GetPlayers()

	for _, player in ipairs(players) do
		if player ~= lp and player.Character then
			local humanoid = player.Character:FindFirstChild("Humanoid")
			if humanoid and humanoid.Health > 0 and not dartHasShield(player) then
				return player
			end
		end
	end
	return nil
end

local function dartFastTeleport()
	if not dartTeleportTargets or not dartOn then return end

	if not dartCurrentTarget then
		dartCurrentTarget = dartFindNextTeleportTarget()
		if not dartCurrentTarget then return end
	end

	if not dartCurrentTarget.Character then
		dartCurrentTarget = dartFindNextTeleportTarget()
		if not dartCurrentTarget then return end
	end

	local humanoid = dartCurrentTarget.Character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health <= 0 or dartHasShield(dartCurrentTarget) then
		dartCurrentTarget = dartFindNextTeleportTarget()
		if not dartCurrentTarget then return end
	end

	local char = lp.Character
	if not char or not char.PrimaryPart then return end

	local targetChar = dartCurrentTarget.Character
	local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
	if not targetHRP then return end

	char.PrimaryPart.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 1.5)
end

local devv = ReplicatedStorage:WaitForChild("devv")
local load = require(devv).load
local FireServer = load("Signal").FireServer
local InvokeServer = load("Signal").InvokeServer
local Raycast = load("Raycast")
local v3item = load("v3item")
local inventory = v3item.inventory

_G.TargetId = nil
_G.AuraEnabled = false
_G.BladeAuraEnabled = false
_G.HealthThreshold = 0
local lastAttack = 0
local lastAmmo = 0

local function getTarget()
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return nil end

	local target, dist = nil, 150
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
			local tHum = plr.Character:FindFirstChildOfClass("Humanoid")
			if tRoot and tHum and tHum.Health >= _G.HealthThreshold then
				local d = (root.Position - tRoot.Position).Magnitude
				if d < dist then
					dist = d
					target = plr
				end
			end
		end
	end
	return target
end

local function hackthrow(plr, itemname, itemguid, velocity, epos)
	if plr ~= LocalPlayer then
		return
	end
	task.spawn(function()
		local throwGuid = GUID()
		local char = plr.Character
		if char and char:FindFirstChild("RightHand") then
			local hand = char:FindFirstChild("RightHand")
			createBeautifulTrail(hand.Position, epos)
		end

		local success, stickyId = InvokeServer("throwSticky", throwGuid, itemname, itemguid, velocity, epos)
		if not success then
			return
		end
		local dummyPart = Instance.new("Part")
		dummyPart.Size = Vector3.new(2, 2, 2)
		dummyPart.Position = epos
		dummyPart.Anchored = true
		dummyPart.Transparency = 1
		dummyPart.CanCollide = true
		dummyPart.Parent = Workspace
		local rayParams = RaycastParams.new()
		rayParams.FilterType = Enum.RaycastFilterType.Blacklist
		rayParams.FilterDescendantsInstances = { plr.Character, Workspace.Game.Local, Workspace.Game.Drones }
		local dist = (epos - plr.Character.Head.Position).Magnitude
		local rayResult = Workspace:Raycast(
			plr.Character.Head.Position,
			(epos - plr.Character.Head.Position).Unit * (dist + 5),
			rayParams
		)
		if rayResult and rayResult.Instance then
			local hitPart = rayResult.Instance
			local relativeHitCFrame = hitPart.CFrame:ToObjectSpace(CFrame.new(rayResult.Position, rayResult.Position + rayResult.Normal))
			local stickyCFrame = CFrame.new(rayResult.Position)
			if dummyPart.Parent then
				dummyPart:Destroy()
			end
			_G.throwargs = {
				"hitSticky",
				stickyId or throwGuid,
				hitPart,
				relativeHitCFrame,
				stickyCFrame,
			}
			InvokeServer("hitSticky", stickyId or throwGuid, hitPart, relativeHitCFrame, stickyCFrame)
		else
			if dummyPart.Parent then
				dummyPart:Destroy()
			end
		end
	end)
end

local function getinventory()
	return inventory.items
end

local function finditem(string)
	for guid2, data in next, getinventory() do
		if data.name == string or data.type == string or data.subtype == string then
			return data
		end
	end
end

local function executebladekill(plr, head)
	local item = finditem("Tomahawk")
	if item then
		FireServer("equip", item.guid)

		if not _G.throwargs then
			local char = LocalPlayer.Character
			if not char then return end
			local hand = char:FindFirstChild("RightHand")
			if not hand then return end

			local spos = hand.Position
			local epos = head.Position
			local velocity = (epos - spos).Unit * ((spos - epos).Magnitude * 15)
			createBeautifulTrail(spos, epos)
			task.spawn(InvokeServer, "attemptPurchaseAmmo", "Tomahawk")
			hackthrow(LocalPlayer, "Tomahawk", item.guid, velocity, epos)
		end

		if _G.throwargs then
			_G.throwargs[3] = head
			task.spawn(InvokeServer, unpack(_G.throwargs))
		end
	else
		task.spawn(InvokeServer, "attemptPurchase", "Tomahawk")
	end
end

local function attack(plr)
	local now = tick()
	if now - lastAttack < 0.03 then return end
	lastAttack = now

	local tChar = plr.Character
	local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
	local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
	if not tRoot or not tHum or tHum.Health < 15 then return end

	task.spawn(function()
		local items = inventory.items or {}
		local banana = nil
		for _, v in next, items do
			if v.name == "Banana Peel" then
				banana = v
				break
			end
		end

		if not banana then
			pcall(function() InvokeServer("attemptPurchase", "Banana Peel") end)
			return
		end

		FireServer("equip", banana.guid)

		local pred = tRoot.AssemblyLinearVelocity * 0.2
		local cf2 = tRoot.CFrame * CFrame.new(0, -1, 0) + pred
		local rcf = tRoot.CFrame:ToObjectSpace(cf2)

		local char = LocalPlayer.Character
		if char and char:FindFirstChild("RightHand") then
			local hand = char:FindFirstChild("RightHand")
			createBeautifulTrail(hand.Position, cf2.Position)
		end

		if not _G.TargetId then
			local ok, _, id = pcall(function()
				return InvokeServer("throwSticky", GUID(), "Banana Peel", banana.guid, Vector3.new(0, 100, 0), cf2.Position)
			end)
			if ok and id then _G.TargetId = id end
		end

		if _G.TargetId then
			pcall(function()
				InvokeServer("hitSticky", _G.TargetId, tRoot, rcf, cf2)
			end)
		end
	end)
end

RunService.Heartbeat:Connect(function()
	if _G.AuraEnabled then
		local target = getTarget()
		if target then
			attack(target)
		end

		if tick() - lastAmmo > 0.5 then
			lastAmmo = tick()
			task.spawn(function()
				pcall(function() InvokeServer("attemptPurchaseAmmo", "Banana Peel") end)
			end)
		end
	end

	if _G.BladeAuraEnabled and HumanoidRootPart then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer then
				local char = plr.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				local head = char and char:FindFirstChild("Head")
				if head then
					local dist = (HumanoidRootPart.Position - head.Position).Magnitude
					if hum and hum.Health > 0 and dist < 190 then
						executebladekill(plr, head)
						break
					end
				end
			end
		end
	end
end)

local CombatLeft = Tabs.Combat:AddLeftGroupbox("战斗")

CombatLeft:AddToggle("OnePunch", {
	Text = "一拳秒杀",
	Default = false
})

CombatLeft:AddToggle("OneSwing", {
	Text = "其他近战武器秒杀",
	Default = false
})

CombatLeft:AddToggle("KillAura", {
	Text = "杀戮光环",
	Default = false,
	Callback = function(val)
		if val then
			Remotes.FireServer("equip", Inventory.getFromName("Fists").guid)
		end
	end
})

CombatLeft:AddToggle("StompAura", {
	Text = "踩人光环",
	Default = false
})

CombatLeft:AddToggle("GrabAura", {
	Text = "抓人光环",
	Default = false
})

CombatLeft:AddToggle("Killall", {
	Text = "杀死全部",
	Default = false,
	Callback = function(val)
		if val then
			Remotes.FireServer("equip", Inventory.getFromName("Fists").guid)
		end
		HumanoidRootPart.Anchored = val
		task.spawn(function()
			while Toggles.Killall.Value do
				task.wait()
				for _, player in pairs(Players:GetPlayers()) do
					if not Toggles.Killall.Value then break end
					if player == LocalPlayer then continue end
					if table.find(Whitelist, player.UserId) then continue end
					local char = player.Character
					if not char then continue end
					local hum = char:FindFirstChildOfClass("Humanoid")
					if not hum then continue end
					if char:FindFirstChild("ForceField") then continue end
					if hum.Health <= 5 then continue end
					task.wait()
					Humanoid.Sit = false
					Character:PivotTo(char.HumanoidRootPart.CFrame)
					Remotes.FireServer("meleeItemHit", "player", {
						meleeType = "meleemegapunch",
						hitPlayerId = player.UserId
					})
					Remotes.FireServer("stomp", player)
					task.wait(0.7)
				end
			end
			HumanoidRootPart.Anchored = false
		end)
	end
})

CombatLeft:AddToggle("AutoEquip", {
	Text = "死亡自动装备拳头",
	Default = false
})

CombatLeft:AddToggle("Godmode", {
	Text = "防倒地",
	Default = false
})

CombatLeft:AddToggle("Invisible", {
	Text = "隐身",
	Default = false,
	Callback = function(val)
		if val then
			local savedCF = HumanoidRootPart.CFrame
			Character:MoveTo(Vector3.new(-25.95, 84, 3537.55))
			task.wait(0.15)
			local chair = Instance.new("Seat", Workspace)
			chair.Anchored = false
			chair.CanCollide = false
			chair.Name = "invischair"
			chair.Transparency = 1
			chair.Position = Vector3.new(-25.95, 84, 3537.55)
			local weld = Instance.new("Weld", chair)
			weld.Part0 = chair
			local torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
			if torso then
				weld.Part1 = torso
				task.wait()
				Instance.new("Seat", Workspace).CFrame = savedCF
			end
		else
			local chair = Workspace:FindFirstChild("invischair")
			if chair then chair:Remove() end
		end
	end
})

CombatLeft:AddToggle("RPGBomb", {
	Text = "RPG全图轰炸",
	Default = false,
	Callback = function(val)
		if not val then return end
		if not Inventory.getFromName("RPG") then
			Remotes.InvokeServer("attemptPurchase", "RPG")
		end
		local equip = Inventory.getEquippedItem()
		if equip and equip.name ~= "RPG" then return end
		if equip then
			Remotes.FireServer("replicateProjectiles", equip.guid, {
				{ "AmmoGuid", HumanoidRootPart.CFrame }
			}, "semi")
		end
		task.spawn(function()
			while Toggles.RPGBomb.Value do
				task.wait()
				local item = Inventory.getEquippedItem()
				if not item or item.name ~= "RPG" then continue end
				for _, player in pairs(Players:GetPlayers()) do
					if not Toggles.RPGBomb.Value then break end
					if player == LocalPlayer then continue end
					if table.find(Whitelist, player.UserId) then continue end
					local char = player.Character
					if not char then continue end
					local hum = char:FindFirstChildOfClass("Humanoid")
					if not hum or hum.Health <= 10 then continue end
					if char:FindFirstChild("ForceField") then continue end
					Remotes.FireServer("rocketHit", "AmmoGuid", "explosionGUID", char.HumanoidRootPart.Position)
				end
			end
		end)
	end
})

CombatLeft:AddToggle("AutoArmor", {
	Text = "自动穿甲",
	Default = false,
	Callback = function()
		task.spawn(function()
			while Toggles.AutoArmor.Value do
				task.wait()
				if not Character then continue end
				local armor = LocalPlayer:GetAttribute("armor")
				if not armor or armor <= 0 then
					Remotes.InvokeServer("attemptPurchase", "Light Vest")
					local guid3 = Inventory.getFromName("Light Vest").guid
					Remotes.FireServer("equip", guid3)
					Remotes.FireServer("useConsumable", guid3)
					Remotes.FireServer("removeItem", guid3)
				end
			end
		end)
	end
})

local DartGroup = Tabs.Combat:AddRightGroupbox("飞镖光环")

DartGroup:AddLabel("使用须知：忍者飞镖光环需使用的时候 先将原来的忍者飞镖丢弃 然后再点击自动购买 再开启其余功能 即可使用")

DartGroup:AddToggle("DartAura", {
	Text = "忍者飞镖光环",
	Default = false,
	Callback = function(state)
		dartOn = state
		dartCleanupConnections()

		if state then
			dartEquipNinjaStar()
			task.wait(0.1)
			dartInitThrow()

			local fastAttackConn = runService.RenderStepped:Connect(function()
				if not dartOn then return end
				dartRapidThrowAttack()
			end)
			table.insert(dartHeartConnections, fastAttackConn)
		end
	end
})

DartGroup:AddToggle("DartTP", {
	Text = "传送攻击(需打开忍者飞镖光环)",
	Default = false,
	Callback = function(state)
		dartTeleportTargets = state

		if state and dartOn then
			local fastTeleportConn = runService.RenderStepped:Connect(function()
				dartFastTeleport()
			end)
			table.insert(dartHeartConnections, fastTeleportConn)

			Library:Notify({
				Title = "传送攻击",
				Description = "已开启",
				Time = 2,
			})
		elseif state then
			local checkConnection
			checkConnection = runService.Heartbeat:Connect(function()
				if dartOn then
					checkConnection:Disconnect()
					local fastTeleportConn = runService.RenderStepped:Connect(function()
						dartFastTeleport()
					end)
					table.insert(dartHeartConnections, fastTeleportConn)
				elseif not dartTeleportTargets then
					checkConnection:Disconnect()
				end
			end)
		end
	end
})

DartGroup:AddToggle("DartBuy", {
	Text = "自动购买忍者飞镖",
	Default = false,
	Callback = function(state)
		if dartNinjaStarBuyThread then
			dartNinjaStarBuyThread:Disconnect()
			dartNinjaStarBuyThread = nil
		end
		if state then
			dartNinjaStarBuyThread = heartbeat:Connect(function()
				sig.InvokeServer("attemptPurchase", "Ninja Star")
				for _, v in next, inv.items do
					if v.name == "Ninja Star" then
						break
					end
				end
			end)
		end
	end
})

DartGroup:AddToggle("BananaAura", {
	Text = "香蕉光环",
	Default = false,
	Callback = function(state)
		_G.AuraEnabled = state
		if not state then _G.TargetId = nil end
	end
})

DartGroup:AddToggle("BladeAura", {
	Text = "战斧光环",
	Default = false,
	Callback = function(state)
		_G.BladeAuraEnabled = state
	end
})

DartGroup:AddSlider("HealthThreshold", {
	Text = "不攻击生命值",
	Default = 0,
	Min = 0,
	Max = 25,
	Rounding = 0,
	Callback = function(value)
		_G.HealthThreshold = value
	end
})

pcall(function()
	Library:OnUnload(function()
		dartCleanupConnections()
		if dartNinjaStarBuyThread then
			dartNinjaStarBuyThread:Disconnect()
			dartNinjaStarBuyThread = nil
		end
	end)
end)

local HitboxGroup = Tabs.Combat:AddLeftGroupbox("子弹范围")

local HitboxConnection
HitboxGroup:AddToggle("Hitbox", {
	Text = "开关",
	Default = false,
	Callback = function(val)
		if val then
			HitboxConnection = RunService.RenderStepped:Connect(function()
				for _, player in next, Players:GetPlayers() do
					pcall(function()
						local size = tonumber(Options.HitboxSize.Value) or 15
						local trans = tonumber(Options.HitboxTransparency.Value) or 0.8
						player.Character.HumanoidRootPart.Size = Vector3.new(size, size, size)
						player.Character.HumanoidRootPart.Transparency = trans
						player.Character.HumanoidRootPart.Color = Color3.fromRGB(0, 0, 0)
						player.Character.HumanoidRootPart.Material = "Neon"
						player.Character.HumanoidRootPart.CanCollide = false
					end)
				end
			end)
		else
			if HitboxConnection then HitboxConnection:Disconnect() end
			task.wait()
			for _, player in next, Players:GetPlayers() do
				pcall(function()
					player.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
					player.Character.HumanoidRootPart.Transparency = 1
					player.Character.HumanoidRootPart.Color = Color3.fromRGB(163, 162, 165)
					player.Character.HumanoidRootPart.BrickColor = BrickColor.new("Medium stone grey")
					player.Character.HumanoidRootPart.Material = "Plastic"
					player.Character.HumanoidRootPart.CanCollide = false
				end)
			end
		end
	end
})

HitboxGroup:AddInput("HitboxSize", {
	Text = "输入大小",
	Default = "15",
	Numeric = false,
	Finished = true
})

HitboxGroup:AddInput("HitboxTransparency", {
	Text = "输入透明度",
	Default = "0.8",
	Numeric = false,
	Finished = true
})

HitboxGroup:AddDropdown("HitboxHitPart", {
	Text = "攻击部位",
	Values = { "头部", "身体" },
	Multi = false,
	Default = 1,
	Callback = function(val)
	end
})

local WhitelistGroup = Tabs.Combat:AddRightGroupbox("白名单")

WhitelistGroup:AddInput("WhitelistInput", {
	Text = "输入名称",
	Default = "",
	Numeric = false,
	Finished = true,
	Callback = function(val)
		local found = FindPlayer(val)
		if found then
			SelectedTarget = found
			notify("当前目标：" .. found.Name)
		else
			SelectedTarget = nil
		end
	end
})

WhitelistGroup:AddButton("添加至白名单", function()
	if SelectedTarget then
		if not table.find(Whitelist, SelectedTarget.UserId) then
			table.insert(Whitelist, SelectedTarget.UserId)
			notify("已将 " .. SelectedTarget.Name .. " 添加至白名单")
		else
			notify("该玩家已经在白名单中")
		end
	else
		notify("请先输入名称")
	end
end)

WhitelistGroup:AddButton("移除白名单", function()
	if SelectedTarget then
		local idx = table.find(Whitelist, SelectedTarget.UserId)
		if idx then
			table.remove(Whitelist, idx)
			notify("已将 " .. SelectedTarget.Name .. " 移除白名单")
		else
			notify("该玩家没有白名单，无法移除")
		end
	else
		notify("请先输入名称")
	end
end)

WhitelistGroup:AddButton("清空白名单", function()
	table.clear(Whitelist)
	notify("白名单已清空")
end)

local ItemsLeft = Tabs.Items:AddLeftGroupbox("购买")
local SelectedItem = nil

ItemsLeft:AddDropdown("SelectItem", {
	Text = "选择物品",
	Values = (function()
		local list = {}
		for k in pairs(ItemsOnSaleList) do
			table.insert(list, k)
		end
		table.sort(list)
		return list
	end)(),
	Multi = false,
	Callback = function(val)
		SelectedItem = val
	end
})

ItemsLeft:AddButton("购买", function()
	if SelectedItem then
		Remotes.InvokeServer("attemptPurchase", SelectedItem)
	else
		notify("请先选择物品")
	end
end)

ItemsLeft:AddButton("购买子弹", function()
	if SelectedItem then
		Remotes.InvokeServer("attemptPurchaseAmmo", SelectedItem)
	else
		notify("请先选择物品")
	end
end)

ItemsLeft:AddToggle("ShowBuyUI", {
	Text = "显示购买界面",
	Default = false,
	Callback = function()
		if not SelectedItem then return end
		task.spawn(function()
			while Toggles.ShowBuyUI.Value do
				task.wait()
				local itemNode = Workspace.ItemsOnSale:FindFirstChild(SelectedItem)
				if itemNode then
					local td = itemNode:FindFirstChildOfClass("TouchDetector")
					if td then
						firetouchinterest(td.Parent, HumanoidRootPart, 0)
						firetouchinterest(td.Parent, HumanoidRootPart, 1)
					end
				end
			end
		end)
	end
})

local ItemsRight = Tabs.Items:AddRightGroupbox("互动")

ItemsRight:AddToggle("BlackMarket", {
	Text = "远程黑市",
	Default = false,
	Callback = function(val)
		Workspace.BlackMarket.Dealer.Dealer.ProximityPrompt.MaxActivationDistance = val and 10000 or 20
	end
})

ItemsRight:AddToggle("Locker", {
	Text = "远程储物柜",
	Default = false,
	Callback = function(val)
		LocalPlayer.PlayerGui.Backpack.Holder.Locker.Visible = val
	end
})

local FastInteractConn
ItemsRight:AddToggle("FastInteract", {
	Text = "快速互动",
	Default = false,
	Callback = function(val)
		if val then
			FastInteractConn = ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
				fireproximityprompt(prompt)
			end)
		else
			if FastInteractConn then FastInteractConn:Disconnect() end
		end
	end
})

ItemsRight:AddToggle("ItemESP", {
	Text = "透视物品",
	Default = false,
	Callback = function(val)
		if val then
			RefreshItemESP()
		else
			ESP.Clear("ItemESP")
		end
	end
})

ItemsRight:AddInput("ItemSlots", {
	Text = "设置物品栏数量",
	Numeric = true,
	Finished = true,
	Callback = function(val)
		Inventory.numSlots = tonumber(val)
	end
})

local AutoLeft = Tabs.Auto:AddLeftGroupbox("自动刷钱")

AutoLeft:AddToggle("ATMFarm", {
	Text = "自动打ATM",
	Default = false,
	Callback = function(val)
		if val then
			Remotes.FireServer("equip", Inventory.getFromName("Fists").guid)
		end
		task.spawn(function()
			while Toggles.ATMFarm.Value do
				task.wait()
				for _, atm in pairs(Workspace.Game.Props.ATM:GetChildren()) do
					if not Toggles.ATMFarm.Value then break end
					if atm:GetAttribute("state") ~= "destroyed" then
						while atm:GetAttribute("state") ~= "destroyed" and Toggles.ATMFarm.Value do
							task.wait()
							Character:PivotTo(atm:GetPivot())
							Remotes.FireServer("meleeItemHit", "prop", {
								meleeType = "meleepunch",
								guid = atm:GetAttribute("guid")
							})
						end
						task.wait(1)
						for _, bundle in pairs(Workspace.Game.Entities.CashBundle:GetChildren()) do
							local cd = bundle:FindFirstChildOfClass("ClickDetector")
							if cd and (HumanoidRootPart.Position - bundle:GetPivot().Position).Magnitude <= cd.MaxActivationDistance then
								fireclickdetector(cd)
								task.wait(0.5)
							end
						end
					end
				end
			end
		end)
	end
})

AutoLeft:AddToggle("RegisterFarm", {
	Text = "自动打收银机",
	Default = false,
	Callback = function(val)
		if val then
			Remotes.FireServer("equip", Inventory.getFromName("Fists").guid)
		end
		task.spawn(function()
			while Toggles.RegisterFarm.Value do
				task.wait()
				for _, reg in pairs(Workspace.Game.Props.CashRegister:GetChildren()) do
					if not Toggles.RegisterFarm.Value then break end
					if reg:GetAttribute("state") ~= "destroyed" then
						while reg:GetAttribute("state") ~= "destroyed" and Toggles.RegisterFarm.Value do
							task.wait()
							Character:PivotTo(reg:GetPivot())
							Remotes.FireServer("meleeItemHit", "prop", {
								meleeType = "meleepunch",
								guid = reg:GetAttribute("guid")
							})
						end
						task.wait(1)
						for _, bundle in pairs(Workspace.Game.Entities.CashBundle:GetChildren()) do
							local cd = bundle:FindFirstChildOfClass("ClickDetector")
							if cd and (HumanoidRootPart.Position - bundle:GetPivot().Position).Magnitude <= cd.MaxActivationDistance then
								fireclickdetector(cd)
								task.wait(0.5)
							end
						end
					end
				end
			end
		end)
	end
})

AutoLeft:AddToggle("AutoRobBank", {
	Text = "自动抢银行",
	Default = false,
	Callback = function()
		task.spawn(function()
			while Toggles.AutoRobBank.Value do
				local cash = Workspace.BankRobbery.BankCash.Cash
				repeat task.wait() until #cash:GetChildren() ~= 0 or not Toggles.AutoRobBank.Value
				if not Toggles.AutoRobBank.Value then break end
				pcall(function()
					HumanoidRootPart.CFrame = Workspace.BankRobbery.VaultDoor.Door.CFrame
					fireproximityprompt(Workspace.BankRobbery.VaultDoor.Door.Attachment.ProximityPrompt)
					task.wait(0.5)
				end)
				repeat task.wait() until not Workspace.BankRobbery.VaultDoor.Door.Attachment.ProximityPrompt.Enabled or not Toggles.AutoRobBank.Value
				if not Toggles.AutoRobBank.Value then break end
				HumanoidRootPart.CFrame = Workspace.BankRobbery.BankCash.Pallet.CFrame
				fireproximityprompt(Workspace.BankRobbery.BankCash.Main.Attachment.ProximityPrompt)
				task.wait(0.5)
				task.wait()
			end
		end)
	end
})

AutoLeft:AddToggle("CashFarm", {
	Text = "自动捡钱(未测试)",
	Default = false,
	Callback = function()
		task.spawn(function()
			while Toggles.CashFarm.Value do
				task.wait()
				for _, bundle in pairs(Workspace.Game.Entities.CashBundle:GetChildren()) do
					if not Toggles.CashFarm.Value then break end
					local cd = bundle:FindFirstChildOfClass("ClickDetector")
					if cd then
						Character:PivotTo(bundle:GetPivot())
						task.wait(0.5)
						fireclickdetector(cd)
						task.wait(1)
					end
				end
			end
		end)
	end
})

AutoLeft:AddToggle("CashAura", {
	Text = "捡钱光环",
	Default = false,
	Callback = function()
		task.spawn(function()
			while Toggles.CashAura.Value do
				for _, bundle in pairs(Workspace.Game.Entities.CashBundle:GetChildren()) do
					local cd = bundle:FindFirstChildOfClass("ClickDetector")
					if cd and (HumanoidRootPart.Position - bundle:GetPivot().Position).Magnitude <= cd.MaxActivationDistance then
						fireclickdetector(cd)
					end
				end
				task.wait(0.25)
			end
		end)
	end
})

AutoLeft:AddToggle("ItemFarm", {
	Text = "自动捡物品",
	Default = false,
	Callback = function()
		task.spawn(function()
			while Toggles.ItemFarm.Value do
				task.wait()
				for _, item in pairs(Workspace.Game.Entities.ItemPickup:GetChildren()) do
					if not Toggles.ItemFarm.Value then break end
					local cd = item:FindFirstChildWhichIsA("ClickDetector", true)
					if cd then
						Character:PivotTo(cd.Parent.CFrame)
						task.wait(0.5)
						fireclickdetector(cd)
						task.wait(1.5)
					end
				end
			end
		end)
	end
})

AutoLeft:AddToggle("ItemAura", {
	Text = "捡物品光环",
	Default = false,
	Callback = function()
		task.spawn(function()
			while Toggles.ItemAura.Value do
				for _, item in pairs(Workspace.Game.Entities.ItemPickup:GetChildren()) do
					if not Toggles.ItemAura.Value then
						task.wait(0.25)
						continue
					end
					pcall(function()
						local cd = item:FindFirstChildWhichIsA("ClickDetector", true)
						if cd and (HumanoidRootPart.Position - item:GetPivot().Position).Magnitude <= cd.MaxActivationDistance then
							fireclickdetector(cd)
						end
					end)
				end
				task.wait(0.25)
			end
		end)
	end
})

AutoLeft:AddDropdown("SelectedItems", {
	Text = "选择物品",
	Values = { "红卡", "蓝卡", "印钞机", "气球" },
	Multi = true,
	AllowNull = true,
	Callback = function()
	end
})

AutoLeft:AddToggle("SItemsFarm", {
	Text = "自动捡选中的物品",
	Default = false,
	Callback = function(val)
		if not val then return end
		task.spawn(function()
			local v = Options.SelectedItems.Value
			for _, item in pairs(Workspace.Game.Entities.ItemPickup:GetDescendants()) do
				if item:IsA("ProximityPrompt") then
					local match = (v["红卡"] and item.ObjectText == "Military Armory Keycard")
						or (v["蓝卡"] and item.ObjectText == "Police Armory Keycard")
						or (v["印钞机"] and item.ObjectText == "Money Printer")
						or (v["气球"] and item.ObjectText:match("Balloon"))
					if match then
						local savedCF = HumanoidRootPart.CFrame
						Character:PivotTo(item.Parent:GetPivot())
						task.wait()
						for i = 1, 5 do
							fireproximityprompt(item)
							task.wait(0.1)
						end
						Character:PivotTo(savedCF)
						task.wait(1.5)
					end
				end
			end
		end)
	end
})

AutoLeft:AddToggle("ReturnOnTeleport", {
	Text = "是否回传",
	Default = false
})

AutoLeft:AddToggle("NotifyAirdrop", {
	Text = "空投刷新提示",
	Default = false
})

AutoLeft:AddButton("自动换服寻找印钞机", function()
	Library:Notify({
		Title = "使用说明",
		Description = "如果您的注入器不受脚本支持\n请在手机目录/" .. identifyexecutor() .. "/Autoexec文件夹添加脚本 以便脚本自动执行",
		Time = 5,
	})
	task.wait(3)
	writefile("XA-Hub/Fluent/AutoFindMoneyPrinter.txt", "true")
	pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Xingtaiduan/Script/refs/heads/main/Games/俄亥俄州_印钞机.lua"))() end)
end)

local AutoRight = Tabs.Auto:AddRightGroupbox("自动银行农场")

local autobank = false
local bankTeleportCFrame = CFrame.new(1112.12671, 10.1856346, -324.815613)
local originalPosition = nil

local function robBankAndReturn()
	if not autobank then return end

	local character = LocalPlayer.Character
	if not character then return end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	originalPosition = rootPart.CFrame

	rootPart.CFrame = bankTeleportCFrame
	task.wait(0.1)

	local waitTime = 0.1
	local maxWait = 10.0

	local startTime = tick()
	while autobank and (tick() - startTime) < maxWait do
		sig.FireServer("stealBankCash")
		task.wait(waitTime)
	end

	if autobank and originalPosition then
		rootPart.CFrame = originalPosition
		task.wait(0.1)
	end

	originalPosition = nil
end

local bankThread = nil

AutoRight:AddToggle("BankAura", {
	Text = "银行光环",
	Default = false,
	Callback = function(state)
		autobank = state
		if autobank then
			if not bankThread then
				bankThread = task.spawn(function()
					while autobank do
						robBankAndReturn()
						task.wait(0.5)
					end
					bankThread = nil
				end)
			end
		end
	end
})

AutoRight:AddToggle("ATMFarm2", {
	Text = "ATM农场",
	Default = false,
	Callback = function(Value)
		if Value then
			task.spawn(function()
				local function collectCash()
					local cashSize = Vector3.new(2, 0.2499999850988388, 1)
					for _, part in ipairs(Workspace.Game.Entities.CashBundle:GetDescendants()) do
						if part:IsA("BasePart") and part.Size == cashSize then
							LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame
							task.wait()
						end
					end
				end

				while Toggles.ATMFarm2.Value and task.wait() do
					local ATMsFolder = Workspace:FindFirstChild("ATMs")
					local hasActiveATM = false

					if ATMsFolder and LocalPlayer.Character then
						for _, atm in ipairs(ATMsFolder:GetChildren()) do
							if atm:IsA("Model") then
								local hp = atm:GetAttribute("health")
								if hp ~= 0 then
									hasActiveATM = true
									for _, part in ipairs(atm:GetChildren()) do
										if part.Name == "Main" and part:IsA("BasePart") then
											LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame
											task.wait()
											atm:SetAttribute("health", 0)
											break
										end
									end
									task.wait()
								end
							end
						end
					end

					if hasActiveATM then
						task.wait(0.1)
					else
						collectCash()
						task.wait()
					end
				end
			end)
		end
	end
})

AutoRight:AddToggle("AutoCraft", {
	Text = "自动制作萝莉",
	Default = false,
	Callback = function(state)
	end
})

AutoRight:AddToggle("AutoClaim", {
	Text = "自动领取萝莉",
	Default = false,
	Callback = function(state)
	end
})

RunService.Heartbeat:Connect(function()
	if Toggles.AutoCraft and Toggles.AutoCraft.Value then
		sig.InvokeServer("beginCraft", "RollieCraft")
	end
	if Toggles.AutoClaim and Toggles.AutoClaim.Value then
		sig.InvokeServer("claimCraft", "RollieCraft")
	end
end)

local PickGroup = Tabs.Auto:AddLeftGroupbox("自动拾取")

PickGroup:AddToggle("AutoBankFDP", {
	Text = "自动银行",
	Default = false,
	Callback = function(val)
		if val then
			task.spawn(function()
				while Toggles.AutoBankFDP.Value do
					task.wait(0.3)
					pcall(function()
						local BankDoor = Workspace.BankRobbery.VaultDoor
						local BankCashs = Workspace.BankRobbery.BankCash
						local epoh3 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
						if not epoh3 then return end
						if BankDoor.Door.Attachment.ProximityPrompt.Enabled == true then
							BankDoor.Door.Attachment.ProximityPrompt.HoldDuration = 0
							BankDoor.Door.Attachment.ProximityPrompt.MaxActivationDistance = 20
							epoh3.CFrame = CFrame.new(1071.955810546875, 9, -343.80816650390625)
							task.wait(0.3)
							BankDoor.Door.Attachment.ProximityPrompt:InputHoldBegin()
							task.wait(0.3)
							BankDoor.Door.Attachment.ProximityPrompt:InputHoldEnd()
						else
							if BankCashs.Cash:FindFirstChild("Bundle") then
								epoh3.CFrame = CFrame.new(1055.94153, 15.11950874, -344.58374)
								BankCashs.Main.Attachment.ProximityPrompt.MaxActivationDistance = 20
								BankCashs.Main.Attachment.ProximityPrompt:InputHoldBegin()
							end
							if not BankCashs.Cash:FindFirstChild("Bundle") then
								BankCashs.Main.Attachment.ProximityPrompt:InputHoldEnd()
							end
						end
					end)
				end
			end)
		end
	end
})

local function makeAutoPickToggle(key, text, matchFn)
	local running = false
	PickGroup:AddToggle(key, {
		Text = text,
		Default = false,
		Callback = function(val)
			running = val
			if val then
				task.spawn(function()
					while running do
						task.wait(0.1)
						pcall(function()
							local epoh3 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
							if not epoh3 then return end
							for i, l in pairs(Workspace.Game.Entities.ItemPickup:GetChildren()) do
								for i2, v in pairs(l:GetChildren()) do
									if v.ClassName == "MeshPart" or v.ClassName == "Part" then
										for i3, e in pairs(v:GetChildren()) do
											if e.ClassName == "ProximityPrompt" then
												if matchFn(e.ObjectText) then
													epoh3.CFrame = v.CFrame * CFrame.new(0, 2, 0)
													task.wait(0.1)
													e:InputHoldBegin()
													e:InputHoldEnd()
												end
											end
										end
									end
								end
							end
						end)
					end
				end)
			end
		end
	})
end

makeAutoPickToggle("AutoMoneyPrint", "自动捡印钞机", function(t)
	return t == "Money Printer"
end)

makeAutoPickToggle("AutoOre", "自动捡稀有珠宝", function(t)
	return t == "Diamond Ring" or t == "Diamond" or t == "Void Gem" or t == "Dark Matter Gem" or t == "Rollie"
end)

makeAutoPickToggle("AutoGoldGun", "自动捡黄金枪", function(t)
	return t == "Gold AK-47" or t == "Gold Deagle"
end)

makeAutoPickToggle("AutoAirdropMark", "自动捡空投、空袭标记", function(t)
	return t == "Airdrop Marker" or t == "Airstrike Marker"
end)

makeAutoPickToggle("AutoParts", "自动捡精致零件", function(t)
	return t == "Electronics" or t == "Weapon Parts"
end)

makeAutoPickToggle("AutoPresent", "自动捡礼物盒", function(t)
	return t == "Small Present"
end)

makeAutoPickToggle("AutoRedCard", "自动捡红卡", function(t)
	return t == "Military Armory Keycard"
end)

makeAutoPickToggle("AutoBalloonPick", "自动捡气球", function(t)
	return t == "Bunny Balloon" or t == "Ghost Balloon" or t == "Clover Balloon"
end)

makeAutoPickToggle("AutoCandy", "自动捡糖果棒", function(t)
	return t == "Bunny Balloon" or t == "Ghost Balloon" or t == "Clover Balloon"
end)

PickGroup:AddToggle("JewelNotify", {
	Text = "珠宝店提示",
	Default = false,
	Callback = function(val)
		if val then
			task.spawn(function()
				while Toggles.JewelNotify.Value do
					task.wait(0.1)
					local Ge = Workspace.GemRobbery:FindFirstChild("Rubble")
					if Ge then
						StarterGui:SetCore("SendNotification", {
							Title = "提示：",
							Text = "珠宝店已刷新",
							Duration = math.huge,
							Button1 = "好"
						})
						task.wait(30)
					end
				end
			end)
		end
	end
})

local TpLeft = Tabs.Teleport:AddLeftGroupbox("地点传送")
local SelectedLocation = nil

TpLeft:AddDropdown("SelectLocation", {
	Text = "选择地点",
	Values = (function()
		local list = {}
		for k in pairs(Locations) do
			table.insert(list, k)
		end
		return list
	end)(),
	Multi = false,
	Callback = function(val)
		SelectedLocation = val
	end
})

TpLeft:AddButton("传送", function()
	if SelectedLocation then
		Character:PivotTo(Locations[SelectedLocation])
	end
end)

local TpRight = Tabs.Teleport:AddRightGroupbox("地点")

local function maketpbutton(text, cframe)
	TpRight:AddButton(text, function()
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = cframe
		end
	end)
end

maketpbutton("银行", CFrame.new(1055.94153, 15.11950874, -344.58374))
maketpbutton("珠宝店", CFrame.new(1719.02637, 14.2831011, -714.293091))
maketpbutton("黑市", CFrame.new(690.499, -18.949, -115.453))
maketpbutton("沙滩", CFrame.new(998.4656372070312, 15, 395.9789733886719))
maketpbutton("武器店(撬锁)", CFrame.new(660.5284423828125, 6.4081127643585205, -716.489990234375))
maketpbutton("警局(M4A1)", CFrame.new(603.4676513671875, 25.662811279296875, -922.0442504882812))
maketpbutton("军事基地(军甲)", CFrame.new(563.4422607421875, 28.502071380615234, -1472.780517578125))
maketpbutton("武士刀", CFrame.new(175.191, 13.937, -132.69))
maketpbutton("锯掉", CFrame.new(1179.98523, 40, -436.812683))
maketpbutton("沙漠之鹰", CFrame.new(363.341461, 26.0798492, -259.681396))
maketpbutton("射线枪", CFrame.new(148.685471, -90, -529.280945))
maketpbutton("AUG", CFrame.new(1170.500244140625, 48.37138366699219, -772.55859375))
maketpbutton("军事基地(加特林)", CFrame.new(364.97076416015625, 0.764974117279053, -1447.3302001953125))

local TpBox = Tabs.Teleport:AddLeftGroupbox("瞬移开箱")

TpBox:AddButton("瞬移秒开金保险", function()
	task.spawn(function()
		local BankDoor = Workspace.BankRobbery.VaultDoor
		local epoh3 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not epoh3 then return end
		if BankDoor.Door.Attachment.ProximityPrompt.Enabled == true then
			BankDoor.Door.Attachment.ProximityPrompt.HoldDuration = 0
			BankDoor.Door.Attachment.ProximityPrompt.MaxActivationDistance = 20
			epoh3.CFrame = CFrame.new(1071.955810546875, 9, -343.80816650390625)
			task.wait(0.3)
			BankDoor.Door.Attachment.ProximityPrompt:InputHoldBegin()
			BankDoor.Door.Attachment.ProximityPrompt:InputHoldEnd()
		end
		local GoldJewelSafes = Workspace.Game.Entities.GoldJewelSafe
		for _, model in pairs(GoldJewelSafes:GetChildren()) do
			if model.ClassName == "Model" then
				epoh3.CFrame = model.WorldPivot * CFrame.new(0, 10, 0)
				model.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt.HoldDuration = 0
				model.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt.MaxActivationDistance = 20
				task.wait(0.3)
				if model.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt.Enabled == true then
					model.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt:InputHoldBegin()
					model.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt:InputHoldEnd()
					break
				end
			end
		end
	end)
end)

TpBox:AddButton("瞬移开黑保险", function()
	task.spawn(function()
		local BankDoor = Workspace.BankRobbery.VaultDoor
		local epoh3 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not epoh3 then return end
		if BankDoor.Door.Attachment.ProximityPrompt.Enabled == true then
			BankDoor.Door.Attachment.ProximityPrompt.HoldDuration = 0
			BankDoor.Door.Attachment.ProximityPrompt.MaxActivationDistance = 20
			epoh3.CFrame = CFrame.new(1071.955810546875, 9, -343.80816650390625)
			task.wait(0.3)
			BankDoor.Door.Attachment.ProximityPrompt:InputHoldBegin()
			BankDoor.Door.Attachment.ProximityPrompt:InputHoldEnd()
		end
		local JewelSafes = Workspace.Game.Entities.JewelSafe
		for _, model in pairs(JewelSafes:GetChildren()) do
			if model.ClassName == "Model" then
				epoh3.CFrame = model.WorldPivot * CFrame.new(0, 10, 0)
				model.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt.HoldDuration = 0
				model.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt.MaxActivationDistance = 20
				task.wait(0.3)
				if model.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt.Enabled == true then
					model.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt:InputHoldBegin()
					model.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt:InputHoldEnd()
					break
				end
			end
		end
	end)
end)

TpBox:AddButton("瞬移大宝箱", function()
	task.spawn(function()
		local LargeChes = Workspace.Game.Entities.LargeChest
		for _, model in pairs(LargeChes:GetChildren()) do
			if model.ClassName == "Model" then
				local epoh3 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if not epoh3 then return end
				epoh3.CFrame = model.WorldPivot * CFrame.new(0, 2, 0)
				task.wait(0.1)
				model.Door["Meshes/LargeSafe1_Cube.002_Cube.003_None (3)"].Attachment.ProximityPrompt:InputHoldBegin()
				model.Door["Meshes/LargeSafe1_Cube.002_Cube.003_None (3)"].Attachment.ProximityPrompt:InputHoldEnd()
				break
			end
		end
	end)
end)

TpBox:AddButton("瞬移开小宝箱", function()
	task.spawn(function()
		local SmallChes = Workspace.Game.Entities.SmallChest
		for _, model in pairs(SmallChes:GetChildren()) do
			if model.ClassName == "Model" then
				local epoh3 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if not epoh3 then return end
				epoh3.CFrame = model.WorldPivot * CFrame.new(0, 2, 0)
				task.wait(0.1)
				model.Lock["Meshes/untitled_chest.002_Material.009 (4)"].Attachment.ProximityPrompt:InputHoldBegin()
				model.Lock["Meshes/untitled_chest.002_Material.009 (4)"].Attachment.ProximityPrompt:InputHoldEnd()
				break
			end
		end
	end)
end)

TpBox:AddButton("瞬移开小保险", function()
	task.spawn(function()
		local SmallSaf = Workspace.Game.Entities.SmallSafe
		for _, model in pairs(SmallSaf:GetChildren()) do
			if model.ClassName == "Model" then
				local epoh3 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if not epoh3 then return end
				epoh3.CFrame = model.WorldPivot * CFrame.new(0, 2, 0)
				SmallSaf.SmallSafe.Door["Meshes/Safe1_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt.HoldDuration = 0
				task.wait(0.1)
				SmallSaf.SmallSafe.Door["Meshes/Safe1_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt:InputHoldBegin()
				SmallSaf.SmallSafe.Door["Meshes/Safe1_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt:InputHoldEnd()
				break
			end
		end
	end)
end)

TpBox:AddButton("瞬移挖宝藏", function()
	task.spawn(function()
		local Debri = Workspace.Game.Local.Debris
		if Debri.TreasureMarker then
			local epoh3 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if not epoh3 then return end
			epoh3.CFrame = Debri.TreasureMarker.CFrame * CFrame.new(0, 2, 0)
			Debri.TreasureMarker.ProximityPrompt.HoldDuration = 0
			Debri.TreasureMarker.ProximityPrompt.MaxActivationDistance = 40
			task.wait(0.1)
			Debri.TreasureMarker.ProximityPrompt:InputHoldBegin()
			Debri.TreasureMarker.ProximityPrompt:InputHoldEnd()
		end
	end)
end)

local FunLeft = Tabs.Fun:AddLeftGroupbox("轰炸")
local FunTarget = nil

FunLeft:AddInput("FunTargetInput", {
	Text = "输入名称",
	Default = "",
	Numeric = false,
	Finished = true,
	Callback = function(val)
		local found = FindPlayer(val)
		FunTarget = found
	end
})

FunLeft:AddInput("SpamMessage", {
	Text = "输入消息",
	Default = "俄亥俄州 No.1",
	Numeric = false,
	Finished = true
})

FunLeft:AddToggle("SpamPlayer", {
	Text = "消息轰炸",
	Default = false,
	Callback = function()
		if not FunTarget then
			notify("请先输入名称")
			return
		end
		task.spawn(function()
			while Toggles.SpamPlayer.Value do
				task.wait(0.2)
				Remotes.FireServer("sendMessage", FunTarget.UserId, Options.SpamMessage.Value)
			end
		end)
	end
})

FunLeft:AddToggle("SpamCall", {
	Text = "电话骚扰",
	Default = false,
	Callback = function()
		if not FunTarget then
			notify("请先输入名称")
			return
		end
		task.spawn(function()
			while Toggles.SpamCall.Value do
				task.wait(0.2)
				Remotes.InvokeServer("attemptCall", FunTarget.UserId)
			end
		end)
	end
})

FunLeft:AddToggle("SpamAll", {
	Text = "消息轰炸全体",
	Default = false,
	Callback = function()
		task.spawn(function()
			while Toggles.SpamAll.Value do
				task.wait(0.2)
				for _, player in pairs(Players:GetPlayers()) do
					if not Toggles.SpamAll.Value then break end
					Remotes.FireServer("sendMessage", player.UserId, Options.SpamMessage.Value)
				end
			end
		end)
	end
})

local PlayerLeft = Tabs.Player:AddLeftGroupbox("玩家")
local currentplayer = nil
local viewedPlayer = nil

local function getPlayerNames()
	local list = {}
	for _, v in pairs(Players:GetPlayers()) do
		table.insert(list, v.Name)
	end
	return list
end

PlayerLeft:AddDropdown("PlayerSelect", {
	Text = "选择玩家",
	Values = getPlayerNames(),
	Multi = false,
	Callback = function(val)
		currentplayer = Players:FindFirstChild(val)
	end
})

PlayerLeft:AddButton("刷新玩家列表", function()
	Options.PlayerSelect:SetValues(getPlayerNames())
end)

PlayerLeft:AddButton("传送到玩家", function()
	if not currentplayer then
		notify("请先选择玩家")
		return
	end
	local c = lp.Character
	if c and c.Parent then
		local tp = gp(c, "HumanoidRootPart", "BasePart") or gp(c, "Head", "BasePart") or c:FindFirstChildWhichIsA("BasePart")
		if tp then
			local c1 = currentplayer.Character
			if c1 and c1.Parent then
				local to = gp(c1, "HumanoidRootPart", "BasePart") or gp(c1, "Head", "BasePart") or c1:FindFirstChildWhichIsA("BasePart")
				if to then
					weldtp(tp, to.CFrame)
					notify("传送到: " .. currentplayer.Name)
				else
					notify("对方身体没找到")
				end
			else
				notify("对方角色不存在")
			end
		else
			notify("自己身体没找到")
		end
	else
		notify("自己角色不存在")
	end
end)

local viewConn = nil
PlayerLeft:AddToggle("ViewPlayer", {
	Text = "监视",
	Default = false,
	Callback = function(val)
		if val then
			if not currentplayer then
				notify("请先选择玩家")
				Toggles.ViewPlayer:SetValue(false)
				return
			end
			viewedPlayer = currentplayer
			viewConn = RunService.RenderStepped:Connect(function()
				if viewedPlayer and viewedPlayer.Character then
					local subject = viewedPlayer.Character:FindFirstChildOfClass("Humanoid") or viewedPlayer.Character:FindFirstChildWhichIsA("BasePart")
					if subject then
						ws.CurrentCamera.CameraType = Enum.CameraType.Custom
						ws.CurrentCamera.CameraSubject = subject
					end
				end
			end)
		else
			viewedPlayer = nil
			if viewConn then
				viewConn:Disconnect()
				viewConn = nil
			end
			local c = lp.Character
			if c and c.Parent then
				local subject = c:FindFirstChildOfClass("Humanoid") or c:FindFirstChildWhichIsA("BasePart")
				if subject then
					ws.CurrentCamera.CameraType = Enum.CameraType.Custom
					ws.CurrentCamera.CameraSubject = subject
				end
			end
		end
	end
})

local PlayerRight = Tabs.Player:AddRightGroupbox("把他传送过来")
local cbring = {}

PlayerRight:AddToggle("CbringPlayer", {
	Text = "把选中的传送过来",
	Default = false,
	Callback = function(val)
		if not currentplayer then
			notify("请先选择玩家")
			Toggles.CbringPlayer:SetValue(false)
			return
		end
		if val then
			if not table.find(cbring, currentplayer.Name) then
				table.insert(cbring, currentplayer.Name)
				notify("已添加 " .. currentplayer.Name)
			end
		else
			local idx = table.find(cbring, currentplayer.Name)
			if idx then
				table.remove(cbring, idx)
				notify("已移除 " .. currentplayer.Name)
			end
		end
	end
})

PlayerRight:AddButton("添加全部", function()
	for i, v in pairs(plrs:GetPlayers()) do
		if (v ~= lp) and v and v.Parent and (not table.find(cbring, v.Name)) then
			table.insert(cbring, v.Name)
		end
	end
	notify("已添加全部玩家")
end)

PlayerRight:AddButton("清空列表", function()
	table.clear(cbring)
	notify("列表已清空")
end)

task.spawn(function()
	while true do
		local waited = false
		local lpc = lp.Character
		if lpc and lpc.Parent then
			local part0 = gp(lpc, "Torso", "BasePart") or gp(lpc, "HumanoidRootPart", "BasePart") or gp(lpc, "Head", "BasePart") or lpc:FindFirstChildWhichIsA("BasePart")
			if part0 then
				for i, v in pairs(plrs:GetPlayers()) do
					if v ~= lp then
						local c = v.Character
						if c and c.Parent then
							if table.find(cbring, v.Name) then
								local part1 = gp(c, part0.Name, "BasePart") or gp(c, "Torso", "BasePart") or gp(c, "HumanoidRootPart", "BasePart") or gp(c, "Head", "BasePart") or c:FindFirstChildWhichIsA("BasePart")
								if part1 then
									local p1cf = part0.CFrame
									waited = true
									weldtp(part1, p1cf + p1cf.LookVector * 2)
								end
							end
						end
					end
				end
			end
		end
		if not waited then
			stepped:wait(0.1)
		end
	end
end)

local antifling = false
PlayerRight:AddToggle("AntiFling", {
	Text = "防甩飞",
	Default = false,
	Callback = function(val)
		antifling = val
	end
})

local function antiflingF()
	if antifling then
		for i, v in pairs(plrs:GetPlayers()) do
			if v ~= lp then
				local c = v.Character
				if c and c.Parent then
					for i1, v1 in pairs(c:GetDescendants()) do
						if v1:IsA("BasePart") then
							v1.CanCollide = false
							v1.Velocity = v3_0
							v1.RotVelocity = v3_0
						end
					end
				end
			end
		end
	end
end
stepped:Connect(antiflingF)
heartbeat:Connect(antiflingF)

local ctrltp = false
PlayerRight:AddToggle("CtrlTP", {
	Text = "按住CRTL时点击传送",
	Default = false,
	Callback = function(val)
		ctrltp = val
	end
})

mouse.Button1Down:Connect(function()
	if not ctrltp then
		return
	end
	if not (mouse.Target and uis:IsKeyDown(Enum.KeyCode.LeftControl)) then
		return
	end
	local to = mouse.Hit.Position + v3(0, 3, 0)
	to = cf(to, to + v3(-1, 0, -1) * ws.CurrentCamera.CFrame.LookVector)
	local c = lp.Character
	if not (c and c.Parent) then
		return
	end
	local hrp = gp(c, "HumanoidRootPart", "BasePart") or gp(c, "Torso", "BasePart") or gp(c, "UpperTorso", "BasePart") or gp(c, "Head", "BasePart") or c:FindFirstChildWhichIsA("BasePart")
	if hrp then
		weldtp(hrp, to)
	end
end)

local QuickLeft = Tabs.Quick:AddLeftGroupbox("秒开")

QuickLeft:AddButton("秒开银行", function()
	task.spawn(function()
		while true do
			task.wait(1)
			pcall(function()
				Workspace.BankRobbery.VaultDoor.Door.Attachment.ProximityPrompt.HoldDuration = 0
				Workspace.BankRobbery.BankCash.Main.Attachment.ProximityPrompt.MaxActivationDistance = 20
			end)
		end
	end)
end)

QuickLeft:AddButton("秒开金保险", function()
	task.spawn(function()
		while true do
			task.wait(1)
			pcall(function()
				local safe = Workspace.Game.Entities.GoldJewelSafe.GoldJewelSafe
				safe.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt.HoldDuration = 0
				safe.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt.MaxActivationDistance = 20
				safe.Name = "safeopen"
			end)
		end
	end)
end)

QuickLeft:AddButton("秒开黑保险", function()
	task.spawn(function()
		while true do
			task.wait(1)
			pcall(function()
				local safe2 = Workspace.Game.Entities.JewelSafe.JewelSafe
				safe2.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt.HoldDuration = 0
				safe2.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt.MaxActivationDistance = 20
				safe2.Name = "safeopen"
			end)
		end
	end)
end)

QuickLeft:AddButton("秒拿空投", function()
	task.spawn(function()
		while true do
			task.wait(1)
			pcall(function()
				Workspace.Game.Airdrops.Airdrop.Airdrop.ProximityPrompt.HoldDuration = 0
				Workspace.Game.Airdrops.Airdrop.Airdrop.ProximityPrompt.MaxActivationDistance = 20
				Workspace.Game.Airdrops.Airdrop.Airdrop.Name = "airdropopen"
			end)
		end
	end)
end)

QuickLeft:AddButton("秒拿珠宝", function()
	local function setZero(spawns)
		for _, obj in pairs(spawns:GetChildren()) do
			if obj.ClassName == "Model" then
				for _, innerObj in pairs(obj:GetChildren()) do
					if innerObj.ClassName == "Model" then
						if innerObj.Name == "Case" then
						elseif innerObj.Name == "Emerald" or innerObj.Name == "Sapphire" or innerObj.Name == "Amethyst" or innerObj.Name == "Topaz" or innerObj.Name == "Diamond" or innerObj.Name == "Gold Bar" or innerObj.Name == "Ruby" then
							if innerObj:FindFirstChild("Handle") and innerObj.Handle:FindFirstChild("ProximityPrompt") then
								innerObj.Handle.ProximityPrompt.HoldDuration = 0
							end
						else
							if innerObj:FindFirstChild("Box") and innerObj.Box:FindFirstChild("ProximityPrompt") then
								innerObj.Box.ProximityPrompt.HoldDuration = 0
							end
						end
					end
				end
			end
		end
	end
	setZero(Workspace.GemRobbery.JewelryCases.HighYieldSpawns)
	setZero(Workspace.GemRobbery.JewelryCases.LowYieldSpawns)
	notify("秒拿珠宝已开启")
end)

QuickLeft:AddButton("秒用弹药箱", function()
	for i = 1, 50 do
		local Ammo = Workspace.Game.Local.droppables["Ammo Box"]
		Ammo.Handle.ProximityPrompt.HoldDuration = 0
		Ammo.Name = "Ammo"
	end
	notify("秒用弹药箱已开启")
end)

QuickLeft:AddButton("原皮枪连发无后座", function()
	task.spawn(function()
		local gunNames = {"Raygun", "M1911", "Scar L", "Glock", "Mossberg", "RPG", "USP 45", "Sawn Off", "Minigun", "Stagecoach", "Deagle", "RPK", "Glock 18", "AK-47", "Tommy Gun", "M4A1", "Uzi", "MP7", "Python"}
		while true do
			task.wait(1)
			for _, gunName in pairs(gunNames) do
				pcall(function()
					local gun = ReplicatedStorage.Models.Items:FindFirstChild(gunName)
					if gun and gun.Handle.Muzzle:FindFirstChild("PointLight") then
						gun.Handle.Muzzle.PointLight.Name = "PointLight1"
					end
				end)
			end
		end
	end)
	notify("原皮枪连发无后座已开启")
end)

local QuickRight = Tabs.Quick:AddRightGroupbox("功能")

QuickRight:AddButton("快捷储物柜(快捷:Z)", function()
	LocalPlayer.PlayerGui.Backpack.Holder.Locker.Visible = true
end)

local hitbox123t = false
QuickRight:AddToggle("HitboxMelee", {
	Text = "近战范围",
	Default = false,
	Callback = function(val)
		hitbox123t = val
		if val then
			_G.HeadSize = 40
			_G.Disabled = true
			RunService.RenderStepped:Connect(function()
				if _G.Disabled then
					for i, v in next, Players:GetPlayers() do
						if v.Name ~= LocalPlayer.Name then
							pcall(function()
								v.Character.HumanoidRootPart.Size = Vector3.new(_G.HeadSize, _G.HeadSize, _G.HeadSize)
								v.Character.HumanoidRootPart.Transparency = 0.7
								v.Character.HumanoidRootPart.BrickColor = BrickColor.new("Really blue")
								v.Character.HumanoidRootPart.Material = "Neon"
								v.Character.HumanoidRootPart.CanCollide = false
							end)
						end
					end
				end
			end)
		else
			_G.Disabled = false
		end
	end
})

local espitemt = false
QuickRight:AddToggle("ItemESP2", {
	Text = "透视物品",
	Default = false,
	Callback = function(val)
		espitemt = val
		if val then
			task.spawn(function()
				while espitemt do
					task.wait(1)
					pcall(function()
						for i, l in pairs(Workspace.Game.Entities.ItemPickup:GetChildren()) do
							for i2, v in pairs(l:GetChildren()) do
								if v.ClassName == "MeshPart" or v.ClassName == "Part" then
									for i3, e in pairs(v:GetChildren()) do
										if e.ClassName == "ProximityPrompt" then
											if e.ObjectText == "Military Armory Keycard" or e.ObjectText == "Airdrop Marker" or e.ObjectText == "Diamond Ring" or e.ObjectText == "Money Printer" or e.ObjectText == "Diamond" or e.ObjectText == "Void Gem" or e.ObjectText == "Dark Matter Gem" or e.ObjectText == "Gold AK-47" or e.ObjectText == "Gold Deagle" or e.ObjectText == "Police Armory Keycard" or e.ObjectText == "Electronics" or e.ObjectText == "Weapon Parts" or e.ObjectText == "Rollie" then
												if not v:FindFirstChild("ItemESPBB") then
													local xd = Instance.new("BillboardGui")
													xd.Name = "ItemESPBB"
													xd.Parent = v
													xd.AlwaysOnTop = true
													xd.Size = UDim2.new(0, 100, 0, 25)
													local Frame2 = Instance.new("Frame")
													Frame2.Parent = xd
													Frame2.BackgroundColor3 = Color3.new(0, 255, 255)
													Frame2.Size = UDim2.new(1, 0, 1, 0)
													Frame2.BackgroundTransparency = 1
													local text2 = Instance.new("TextLabel")
													text2.TextScaled = true
													text2.BackgroundColor3 = Color3.new(0, 255, 255)
													text2.Parent = Frame2
													text2.Text = e.ObjectText
													text2.Size = UDim2.new(1, 0, 1, 0)
													text2.BackgroundTransparency = 1
													text2.TextColor3 = Color3.new(0, 255, 255)
												end
											end
										end
									end
								end
							end
						end
					end)
				end
			end)
		else
			for i, l in pairs(Workspace.Game.Entities.ItemPickup:GetDescendants()) do
				if l.Name == "ItemESPBB" then
					l:Destroy()
				end
			end
		end
	end
})

QuickRight:AddButton("按X隐身", function()
	local Keybind = "X"
	local Transparency = true
	local NoClip = false

	local Player = LocalPlayer
	local RealCharacter = Player.Character or Player.CharacterAdded:wait(0.1)

	local IsInvisible = false

	RealCharacter.Archivable = true
	local FakeCharacter = RealCharacter:Clone()
	local Part
	Part = Instance.new("Part", Workspace)
	Part.Anchored = true
	Part.Size = Vector3.new(200, 1, 200)
	Part.CFrame = CFrame.new(0, -500, 0)
	Part.CanCollide = true
	FakeCharacter.Parent = Workspace
	FakeCharacter.HumanoidRootPart.CFrame = Part.CFrame * CFrame.new(0, 5, 0)

	for i, v in pairs(RealCharacter:GetChildren()) do
		if v:IsA("LocalScript") then
			local clone = v:Clone()
			clone.Disabled = true
			clone.Parent = FakeCharacter
		end
	end
	if Transparency then
		for i, v in pairs(FakeCharacter:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Transparency = 0.7
			end
		end
	end
	local CanInvis = true
	local PseudoAnchor
	local function RealCharacterDied()
		CanInvis = false
		RealCharacter:Destroy()
		RealCharacter = Player.Character
		CanInvis = true
		IsInvisible = false
		FakeCharacter:Destroy()
		Workspace.CurrentCamera.CameraSubject = RealCharacter.Humanoid

		RealCharacter.Archivable = true
		FakeCharacter = RealCharacter:Clone()
		Part:Destroy()
		Part = Instance.new("Part", Workspace)
		Part.Anchored = true
		Part.Size = Vector3.new(200, 1, 200)
		Part.CFrame = CFrame.new(9999, 9999, 9999)
		Part.CanCollide = true
		FakeCharacter.Parent = Workspace
		FakeCharacter.HumanoidRootPart.CFrame = Part.CFrame * CFrame.new(0, 5, 0)

		for i, v in pairs(RealCharacter:GetChildren()) do
			if v:IsA("LocalScript") then
				local clone = v:Clone()
				clone.Disabled = true
				clone.Parent = FakeCharacter
			end
		end
		if Transparency then
			for i, v in pairs(FakeCharacter:GetDescendants()) do
				if v:IsA("BasePart") then
					v.Transparency = 0.7
				end
			end
		end
		RealCharacter.Humanoid.Died:Connect(function()
			RealCharacter:Destroy()
			FakeCharacter:Destroy()
		end)
		Player.CharacterAppearanceLoaded:Connect(RealCharacterDied)
	end
	RealCharacter.Humanoid.Died:Connect(function()
		RealCharacter:Destroy()
		FakeCharacter:Destroy()
	end)
	Player.CharacterAppearanceLoaded:Connect(RealCharacterDied)
	RunService.RenderStepped:Connect(function()
		if PseudoAnchor ~= nil then
			PseudoAnchor.CFrame = Part.CFrame * CFrame.new(0, 5, 0)
		end
		if NoClip then
			FakeCharacter.Humanoid:ChangeState(11)
		end
	end)

	PseudoAnchor = FakeCharacter.HumanoidRootPart
	local function Invisible()
		if IsInvisible == false then
			local StoredCF = RealCharacter.HumanoidRootPart.CFrame
			RealCharacter.HumanoidRootPart.CFrame = FakeCharacter.HumanoidRootPart.CFrame
			FakeCharacter.HumanoidRootPart.CFrame = StoredCF
			RealCharacter.Humanoid:UnequipTools()
			Player.Character = FakeCharacter
			Workspace.CurrentCamera.CameraSubject = FakeCharacter.Humanoid
			PseudoAnchor = RealCharacter.HumanoidRootPart
			for i, v in pairs(FakeCharacter:GetChildren()) do
				if v:IsA("LocalScript") then
					v.Disabled = false
				end
			end

			IsInvisible = true
		else
			local StoredCF = FakeCharacter.HumanoidRootPart.CFrame
			FakeCharacter.HumanoidRootPart.CFrame = RealCharacter.HumanoidRootPart.CFrame

			RealCharacter.HumanoidRootPart.CFrame = StoredCF

			FakeCharacter.Humanoid:UnequipTools()
			Player.Character = RealCharacter
			Workspace.CurrentCamera.CameraSubject = RealCharacter.Humanoid
			PseudoAnchor = FakeCharacter.HumanoidRootPart
			for i, v in pairs(FakeCharacter:GetChildren()) do
				if v:IsA("LocalScript") then
					v.Disabled = true
				end
			end
			IsInvisible = false
		end
	end

	UserInputService.InputBegan:Connect(function(key, gamep)
		if gamep then
			return
		end
		if key.KeyCode.Name:lower() == Keybind:lower() and CanInvis and RealCharacter and FakeCharacter then
			if RealCharacter:FindFirstChild("HumanoidRootPart") and FakeCharacter:FindFirstChild("HumanoidRootPart") then
				Invisible()
			end
		end
	end)
	notify("按X隐身已加载，按X切换隐身")
end)

QuickRight:AddButton("清除障碍", function()
	pcall(function() Workspace.InviteSigns:Destroy() end)
	pcall(function() Workspace.Game.Props["Trash Bag"]:Destroy() end)
	pcall(function() Workspace.Game.Props.Dumpster:Destroy() end)
	pcall(function() Workspace.Game.Props["Traffic Cone"]:Destroy() end)
	pcall(function() Workspace.Game.Props["Wire Fence"]:Destroy() end)
	pcall(function() Workspace.Game.Props["Wood Crate"]:Destroy() end)
	pcall(function() Workspace.Game.Props.Hydrant:Destroy() end)
	pcall(function() Workspace.Game.Props["Street Light"]:Destroy() end)
	pcall(function() Workspace.Game.Props["Power Line Pole"]:Destroy() end)
	pcall(function() Workspace.Game.Props["Wood Fence"]:Destroy() end)
	pcall(function() Workspace.Game.Props.BusStop:Destroy() end)
	pcall(function() Workspace.Game.Props.Roadblock:Destroy() end)
	pcall(function() Workspace.Game.Props.Bollard:Destroy() end)
	pcall(function() Workspace.Game.Props.Light:Destroy() end)
	pcall(function() Workspace.Game.Props.Glass:Destroy() end)
	pcall(function() Workspace.Game.Props.Bench:Destroy() end)
	pcall(function() Workspace.Game.Props["Trash Bin"]:Destroy() end)
	pcall(function() Workspace.Game.Props["Office Chair"]:Destroy() end)
	pcall(function() Workspace.Game.Props.Table:Destroy() end)
	pcall(function() Workspace.BankRobbery.BankWalls:Destroy() end)
	pcall(function() Workspace.BankRobbery.AlarmLightModel:Destroy() end)
	pcall(function() Workspace.BankRobbery.AlarmLights:Destroy() end)
	notify("障碍已清除")
end)

local ActGroup = Tabs.Quick:AddLeftGroupbox("活动")

local lanternEnabled = false
ActGroup:AddToggle("Lantern", {
	Text = "自动领取所有灯笼",
	Default = false,
	Callback = function(state)
		lanternEnabled = state
		if state then
			task.spawn(function()
				local char = lp.Character or lp.CharacterAdded:Wait()
				local root = char:WaitForChild("HumanoidRootPart")

				while lanternEnabled do
					local targetFolder = Workspace:FindFirstChild("LunarNewYear")
					if targetFolder then
						for _, obj in pairs(targetFolder:GetChildren()) do
							if not lanternEnabled then break end
							if obj:IsA("Model") or obj:IsA("BasePart") then
								local pos
								if obj:IsA("Model") and obj.PrimaryPart then
									pos = obj.PrimaryPart.Position
								elseif obj:IsA("BasePart") then
									pos = obj.Position
								end
								if pos then
									root.CFrame = CFrame.new(pos)
									task.wait(0.5)
									local prompt = obj:FindFirstChild("ProximityPrompt", true)
									if prompt then
										fireproximityprompt(prompt)
									end
									task.wait(0.5)
								end
							end
						end
					else
						task.wait(0.5)
					end
				end
			end)
		end
	end
})

ActGroup:AddButton("反挂机(必开)", function()
	pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/9fFu43FF"))() end)
end)

ActGroup:AddButton("全枪无限子弹", function()
	local function setInfiniteAmmo()
		for _, item in pairs(inventory.items) do
			if item and item.ammoManager then
				item.ammoManager:setAmmo(9999)
				item.ammoManager:setAmmoOut(9999)
			end
		end
	end

	setInfiniteAmmo()

	task.spawn(function()
		while true do
			pcall(setInfiniteAmmo)
			task.wait(25)
		end
	end)
	notify("全枪无限子弹已开启")
end)

ActGroup:AddButton("全枪射速提升", function()
	local function increaseFireRate()
		for _, item in pairs(inventory.items) do
			if item then
				item.fireDebounce = 0.01
				item.reloadTime = 0.1
				if item.ammoManager then
					item.ammoManager.ammo = 9999
				end
			end
		end
	end

	increaseFireRate()

	task.spawn(function()
		while true do
			pcall(increaseFireRate)
			task.wait(30)
		end
	end)
	notify("全枪射速提升已开启")
end)

ActGroup:AddButton("全枪无后坐力", function()
	local function removeRecoil()
		for _, item in pairs(inventory.items) do
			if item then
				item.recoilAdd = 0
				item.maxRecoil = 0
				item.recoilDiminishFactor = 0
				item.recoilFastDiminishFactor = 0
				item.baseSpread = 0
				item.baseAimSpread = 0
				item.spread = 0
				item.aimSpread = 0
			end
		end
	end

	removeRecoil()

	task.spawn(function()
		while true do
			pcall(removeRecoil)
			task.wait(30)
		end
	end)
	notify("全枪无后坐力已开启")
end)

local ProLeft = Tabs.Protect:AddLeftGroupbox("防护")

local AutoArmorPro = false
ProLeft:AddToggle("AutoArmorPro", {
	Text = "自动买护甲",
	Default = false,
	Callback = function(Value)
		AutoArmorPro = Value
		if Value then
			local connection
			connection = heartbeat:Connect(function()
				if not AutoArmorPro then
					connection:Disconnect()
					return
				end

				pcall(function()
					local humanoid = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
					if humanoid and humanoid.Health > 35 then
						local b1 = require(ReplicatedStorage.devv).load("v3item").inventory.items
						local hasLightVest = false

						for i, v in next, b1 do
							if v.name == "Light Vest" then
								hasLightVest = true
								local light = v.guid
								local armor = lp:GetAttribute("armor")
								if armor == nil or armor <= 0 then
									sig.FireServer("equip", light)
									sig.FireServer("useConsumable", light)
									sig.FireServer("removeItem", light)
								end
								break
							end
						end

						if not hasLightVest then
							sig.InvokeServer("attemptPurchase", "Light Vest")
						end
					end
				end)
			end)
		end
	end
})

local autokz = false
ProLeft:AddToggle("AutoMask", {
	Text = "自动购买面具",
	Default = false,
	Callback = function(state)
		autokz = state
		if autokz then
			task.spawn(function()
				while autokz and task.wait(1) do
					local character = lp.Character or lp.CharacterAdded:Wait()
					local Mask = character:FindFirstChild("Hockey Mask")
					local b1 = require(ReplicatedStorage.devv).load("v3item").inventory.items
					if not Mask then
						sig.InvokeServer("attemptPurchase", "Hockey Mask")
						for i, v in next, b1 do
							if v.name == "Hockey Mask" then
								local sugid = v.guid
								if not Mask then
									sig.FireServer("equip", sugid)
									sig.FireServer("wearMask", sugid)
								end
								break
							end
						end
					end
				end
			end)
		end
	end
})

local healThread = nil
ProLeft:AddToggle("AutoHeal", {
	Text = "自动恢复健康值(回血)",
	Default = false,
	Callback = function(Value)
		if healThread then
			healThread:Disconnect()
			healThread = nil
		end

		if Value then
			healThread = heartbeat:Connect(function()
				pcall(function()
					sig.InvokeServer("attemptPurchase", "Bandage")
					local inv2 = require(ReplicatedStorage.devv).load("v3item").inventory
					for _, v in next, inv2.items do
						if v.name == "Bandage" then
							local bande = v.guid
							local Character2 = lp.Character or lp.CharacterAdded:Wait()
							local Humanoid2 = Character2:WaitForChild("Humanoid")
							if Humanoid2.Health >= 5 and Humanoid2.Health < Humanoid2.MaxHealth then
								sig.FireServer("equip", bande)
								sig.FireServer("useConsumable", bande)
								sig.FireServer("removeItem", bande)
							end
							break
						end
					end
				end)
			end)
		end
	end
})

local melee = require(ReplicatedStorage.devv).load("ClientReplicator")
local AutoKnockReset = false
ProLeft:AddToggle("AntiKnock", {
	Text = "反立",
	Default = false,
	Callback = function(Value)
		AutoKnockReset = Value
		if Value then
			task.spawn(function()
				while AutoKnockReset do
					if lp.Character and lp.Character:FindFirstChild("Humanoid") then
						melee.Set(lp, "knocked", false)
						melee.Replicate("knocked")
					end
					task.wait()
				end
			end)
		end
	end
})

local antiKBEnabled = false
ProLeft:AddToggle("AntiKB", {
	Text = "反击退",
	Default = false,
	Callback = function(Value)
		antiKBEnabled = Value
		task.spawn(function()
			while antiKBEnabled and task.wait(0.1) do
				local character = lp.Character
				if character then
					for _, part in ipairs(character:GetDescendants()) do
						if part:IsA("BasePart") then
							part.CanCollide = false
						end
					end
				end
			end
		end)
	end
})

local BypassLeft = Tabs.Bypass:AddLeftGroupbox("绕过")

BypassLeft:AddButton("绕过移动经销商", function()
	local pjyd
	pjyd = hookmetamethod(game, "__namecall", function(self, ...)
		local args = {...}
		local method = getnamecallmethod()
		if method == "InvokeServer" and args[2] == true then
			args[2] = false
			return pjyd(self, unpack(args))
		end
		return pjyd(self, ...)
	end)
	lp:SetAttribute("mobileDealer", true)
	local mobileDealer = require(ReplicatedStorage.devv.shared.Indicies.mobileDealer)

	for category, items2 in pairs(mobileDealer) do
		for _, item in ipairs(items2) do
			item.stock = 999999
		end
	end

	table.insert(mobileDealer.Gun, {itemName = "Acid Gun", stock = 9999})
	table.insert(mobileDealer.Gun, {itemName = "Candy Bucket", stock = 9999})
	table.insert(mobileDealer.Gun, {itemName = "Golden Rose", stock = 9999})
	table.insert(mobileDealer.Gun, {itemName = "Black Rose", stock = 9999})
	table.insert(mobileDealer.Gun, {itemName = "Dollar Balloon", stock = 9999})
	table.insert(mobileDealer.Gun, {itemName = "Bat Balloon", stock = 9999})
	table.insert(mobileDealer.Gun, {itemName = "Bunny Balloon", stock = 9999})
	table.insert(mobileDealer.Gun, {itemName = "Clover Balloon", stock = 9999})
	table.insert(mobileDealer.Gun, {itemName = "Ghost Balloon", stock = 9999})
	table.insert(mobileDealer.Gun, {itemName = "Gold Clover Balloon", stock = 9999})
	table.insert(mobileDealer.Gun, {itemName = "Heart Balloon", stock = 9999})
	table.insert(mobileDealer.Gun, {itemName = "Skull Balloon", stock = 9999})
	table.insert(mobileDealer.Gun, {itemName = "Snowflake Balloon", stock = 9999})
	table.insert(mobileDealer.Gun, {itemName = "Admin AK-47", stock = 9999})
	table.insert(mobileDealer.Gun, {itemName = "Admin Nuke Launcher", stock = 9999})
	table.insert(mobileDealer.Gun, {itemName = "Admin RPG", stock = 9999})
	table.insert(mobileDealer.Gun, {itemName = "Void Gem", stock = 9999})
	table.insert(mobileDealer.Gun, {itemName = "Pulse Rifle", stock = 9999})
	table.insert(mobileDealer.Gun, {itemName = "Unusual Money Printer", stock = 9999})
	table.insert(mobileDealer.Gun, {itemName = "Money Printer", stock = 9999})
	table.insert(mobileDealer.Gun, {itemName = "Trident", stock = 9999})
	table.insert(mobileDealer.Gun, {itemName = "NextBot Grenade", stock = 9999})
	table.insert(mobileDealer.Gun, {itemName = "El Fuego", stock = 9999})
	notify("移动经销商已绕过")
end)

BypassLeft:AddButton("绕过高级动作", function()
	for _, v in pairs(lp.PlayerGui.Emotes.Frame.ScrollingFrame:GetDescendants()) do
		if v.Name == "Locked" then
			v.Visible = false
		end
	end
	notify("高级动作已绕过")
end)

BypassLeft:AddButton("绕过飞行封禁", function()
	if ReplicatedStorage:FindFirstChild("devv"):FindFirstChild("remoteStorage"):FindFirstChild("makeExplosion") then
		ReplicatedStorage:FindFirstChild("devv"):FindFirstChild("remoteStorage"):FindFirstChild("makeExplosion"):Destroy()
	end
	notify("飞行封禁已绕过")
end)

BypassLeft:AddButton("绕过物品栏封禁", function()
	if ReplicatedStorage:FindFirstChild("devv"):FindFirstChild("remoteStorage"):FindFirstChild("makeExplosion") then
		ReplicatedStorage:FindFirstChild("devv"):FindFirstChild("remoteStorage"):FindFirstChild("makeExplosion"):Destroy()
	end
	notify("物品栏封禁已绕过")
end)

BypassLeft:AddButton("绕过战斗状态", function()
	for _, func in pairs(getgc(true)) do
		if type(func) == "function" then
			local info = debug.getinfo(func)
			if info.name == "isInCombat" or (info.source and info.source:find("combatIndicator")) then
				hookfunction(func, function()
					return false
				end)
			end
		end
	end
	notify("战斗状态已绕过")
end)

local xeniox = {
	Data = {
		Identity = getidentity()
	},
	Helpers = {}
}

xeniox.Helpers.SetIdentity = function(self, identity)
	setidentity(identity)
end

xeniox.Helpers.CallFuncSec = function(self, func, waited)
	self:SetIdentity(2)
	local result, err = pcall(func)
	if not result then
		warn("函数执行错误:", err)
	end
	if waited then
		task.wait(waited)
	end
	self:SetIdentity(xeniox.Data.Identity)
end

local BeauLeft = Tabs.Beautify:AddLeftGroupbox("气球美化")

BeauLeft:AddToggle("AutoBuyBalloon", {
	Text = "自动购买气球",
	Default = false,
	Callback = function(state)
		if not state then return end

		local character = lp.Character or lp.CharacterAdded:Wait()

		if character:FindFirstChild("Balloon") then return end

		sig.InvokeServer("attemptPurchase", "Balloon")

		task.wait(0.5)

		local balloonItem = inventory.getFromName("Balloon")

		if balloonItem then
			xeniox.Helpers:CallFuncSec(function()
				balloonItem:SetEquipped(true)
			end)
		end
	end
})

BeauLeft:AddButton("美化美金(需普通气球)", function()
	for _, v in pairs(getgc(true)) do
		if type(v) == "table" and rawget(v, "name") == "Balloon" and rawget(v, "holdableType") == "Balloon" then
			v.name, v.cost, v.unpurchasable, v.multiplier, v.movespeedAdd, v.cannotDiscard = "Dollar Balloon", 200, true, 0.8, 8, true
			if v.TPSOffsets then v.TPSOffsets.hold = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.pi, 0) end
			if v.viewportOffsets and v.viewportOffsets.hotbar then v.viewportOffsets.hotbar.dist = 4 end
			v.canDrop, v.dropCooldown, v.craft = nil
			break
		end
	end

	for _, item in pairs(require(ReplicatedStorage.devv.client.Objects.v3item.modules.inventory).items) do
		if item.name == "Dollar Balloon" then
			for _, btn in pairs({item.button, item.backpackButton}) do
				if btn and btn.resetModelSkin then btn:resetModelSkin() end
			end
		end
	end
	notify("美化美金完成")
end)

BeauLeft:AddButton("美化黑玫瑰(需普通气球)", function()
	for _, v in pairs(getgc(true)) do
		if type(v) == "table" and rawget(v, "name") == "Balloon" and rawget(v, "holdableType") == "Balloon" then
			v.name, v.cost, v.unpurchasable, v.multiplier, v.movespeedAdd, v.cannotDiscard = "Black Rose", 200, true, 0.75, 12, true
			if v.TPSOffsets then v.TPSOffsets.hold = CFrame.new(0, 0.5, 0) end
			if v.viewportOffsets and v.viewportOffsets.hotbar then v.viewportOffsets.hotbar.dist = 3 end
			v.canDrop, v.dropCooldown, v.craft = nil
			break
		end
	end

	for _, item in pairs(require(ReplicatedStorage.devv.client.Objects.v3item.modules.inventory).items) do
		if item.name == "Black Rose" then
			for _, btn in pairs({item.button, item.backpackButton}) do
				if btn and btn.resetModelSkin then btn:resetModelSkin() end
			end
		end
	end
	notify("美化黑玫瑰完成")
end)

BeauLeft:AddButton("美化Kunai(需普通气球)", function()
	for _, v in pairs(getgc(true)) do
		if type(v) == "table" and rawget(v, "name") == "Balloon" and rawget(v, "holdableType") == "Balloon" then
			v.name = "Kunai"
			v.permanent = true
			v.canDrop = true
			v.dropCooldown = 120
			v.holdableType = "Balloon"
			v.movespeedAdd = 12
			if v.TPSOffsets then
				v.TPSOffsets.hold = CFrame.new(0, -0.3, 0)
			else
				v.TPSOffsets = {hold = CFrame.new(0, -0.3, 0)}
			end
			if v.viewportOffsets then
				if v.viewportOffsets.hotbar then
					v.viewportOffsets.hotbar.dist = 3
					v.viewportOffsets.hotbar.offset = CFrame.new(0, 0, 0)
					v.viewportOffsets.hotbar.rotoffset = CFrame.Angles(0, 1.5707963, 0)
				else
					v.viewportOffsets.hotbar = {dist = 3, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 1.5707963, 0)}
				end
				if v.viewportOffsets.ammoHUD then
					v.viewportOffsets.ammoHUD.dist = 2
					v.viewportOffsets.ammoHUD.offset = CFrame.new(-0.1, -0.2, 0)
					v.viewportOffsets.ammoHUD.rotoffset = CFrame.Angles(0, -1.3744468, 0)
				else
					v.viewportOffsets.ammoHUD = {dist = 2, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.3744468, 0)}
				end
				if v.viewportOffsets.slotButton then
					v.viewportOffsets.slotButton.dist = 1
					v.viewportOffsets.slotButton.offset = CFrame.new(-0.1, -0.2, 0)
					v.viewportOffsets.slotButton.rotoffset = CFrame.Angles(0, -1.5707963, 0)
				else
					v.viewportOffsets.slotButton = {dist = 1, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.5707963, 0)}
				end
			else
				v.viewportOffsets = {
					hotbar = {dist = 3, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 1.5707963, 0)},
					ammoHUD = {dist = 2, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.3744468, 0)},
					slotButton = {dist = 1, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.5707963, 0)}
				}
			end
			break
		end
	end
	for _, item in pairs(require(ReplicatedStorage.devv.client.Objects.v3item.modules.inventory).items) do
		if item.name == "Kunai" then
			for _, btn in pairs({item.button, item.backpackButton}) do
				if btn and btn.resetModelSkin then btn:resetModelSkin() end
			end
		end
	end
	notify("美化Kunai完成")
end)

BeauLeft:AddButton("美化Spirit Kunai(需普通Kunai)", function()
	for _, v in pairs(getgc(true)) do
		if type(v) == "table" and rawget(v, "name") == "Kunai" and rawget(v, "holdableType") == "Kunai" then
			v.name = "Spirit Kunai"
			v.permanent = true
			v.canDrop = true
			v.dropCooldown = 120
			v.holdableType = "Kunai"
			v.movespeedAdd = 12
			if v.TPSOffsets then
				v.TPSOffsets.hold = CFrame.new(0, -0.3, 0)
			else
				v.TPSOffsets = {hold = CFrame.new(0, -0.3, 0)}
			end
			if v.viewportOffsets then
				if v.viewportOffsets.hotbar then
					v.viewportOffsets.hotbar.dist = 3
					v.viewportOffsets.hotbar.offset = CFrame.new(0, 0, 0)
					v.viewportOffsets.hotbar.rotoffset = CFrame.Angles(0, 1.5707963, 0)
				else
					v.viewportOffsets.hotbar = {dist = 3, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 1.5707963, 0)}
				end
				if v.viewportOffsets.ammoHUD then
					v.viewportOffsets.ammoHUD.dist = 2
					v.viewportOffsets.ammoHUD.offset = CFrame.new(-0.1, -0.2, 0)
					v.viewportOffsets.ammoHUD.rotoffset = CFrame.Angles(0, -1.3744468, 0)
				else
					v.viewportOffsets.ammoHUD = {dist = 2, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.3744468, 0)}
				end
				if v.viewportOffsets.slotButton then
					v.viewportOffsets.slotButton.dist = 1
					v.viewportOffsets.slotButton.offset = CFrame.new(-0.1, -0.2, 0)
					v.viewportOffsets.slotButton.rotoffset = CFrame.Angles(0, -1.5707963, 0)
				else
					v.viewportOffsets.slotButton = {dist = 1, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.5707963, 0)}
				end
			else
				v.viewportOffsets = {
					hotbar = {dist = 3, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 1.5707963, 0)},
					ammoHUD = {dist = 2, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.3744468, 0)},
					slotButton = {dist = 1, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.5707963, 0)}
				}
			end
			break
		end
	end
	for _, item in pairs(require(ReplicatedStorage.devv.client.Objects.v3item.modules.inventory).items) do
		if item.name == "Spirit Kunai" then
			for _, btn in pairs({item.button, item.backpackButton}) do
				if btn and btn.resetModelSkin then btn:resetModelSkin() end
			end
		end
	end
	notify("美化Spirit Kunai完成")
end)

local BeauRight = Tabs.Beautify:AddRightGroupbox("枪械皮肤")

local function makeSkinToggle(key, text, skinName)
	BeauRight:AddToggle(key, {
		Text = text,
		Default = false,
		Callback = function(start)
			if start then
				local it = require(ReplicatedStorage.devv).load("v3item").inventory
				local b1 = require(ReplicatedStorage.devv).load("v3item").inventory.items
				for i, item in next, b1 do
					if item.type == "Gun" then
						table.insert(require(ReplicatedStorage.devv.shared.Indicies.skins.bin.Special.Void).compatabilities, item.name)
						it.skinUpdate(item.name, skinName)
					end
				end
			end
		end
	})
end

makeSkinToggle("SkinVoid", "背包枪械美化虚空", "Void")
makeSkinToggle("SkinTactical", "背包枪械美化战术", "Tactical")
makeSkinToggle("SkinCyber", "背包枪械美化赛博", "Cyberpunk")
makeSkinToggle("SkinObsidian", "背包枪械美化黑曜石", "Obsidian")

local skinsec = ""
BeauRight:AddDropdown("SkinSelect", {
	Text = "选择美化皮肤",
	Values = {
		"烟火", "虚空", "纯金", "暗物质", "反物质", "神秘", "虚空神秘", "战术", "纯金战术",
		"白未来", "黑未来", "圣诞未来", "礼物包装", "猩红", "收割者", "虚空收割者", "圣诞玩具",
		"荒地", "隐形", "像素", "钻石像素", "黄金零下", "绿水晶", "生物", "樱花", "精英",
		"黑樱花", "彩虹激光", "蓝水晶", "紫水晶", "红水晶", "零下", "虚空射线", "冰冻钻石",
		"虚空梦魇", "金雪", "爱国者", "MM2", "声望", "酷化", "蒸汽", "海盗", "玫瑰", "黑玫瑰",
		"激光", "烟花", "诅咒背瓜", "大炮", "财富", "黄金大炮", "四叶草", "自由", "黑曜石", "赛博朋克"
	},
	Multi = false,
	Callback = function(Value)
		if Value == "烟火" then
			skinsec = "Sparkler"
		elseif Value == "虚空" then
			skinsec = "Void"
		elseif Value == "纯金" then
			skinsec = "Solid Gold"
		elseif Value == "暗物质" then
			skinsec = "Dark Matter"
		elseif Value == "反物质" then
			skinsec = "Anti Matter"
		elseif Value == "神秘" then
			skinsec = "Hystic"
		elseif Value == "虚空神秘" then
			skinsec = "Void Mystic"
		elseif Value == "战术" then
			skinsec = "Tactical"
		elseif Value == "纯金战术" then
			skinsec = "Solid Gold Tactical"
		elseif Value == "白未来" then
			skinsec = "Future White"
		elseif Value == "黑未来" then
			skinsec = "Future Black"
		elseif Value == "圣诞未来" then
			skinsec = "Christmas Future"
		elseif Value == "礼物包装" then
			skinsec = "Gift Wrapped"
		elseif Value == "猩红" then
			skinsec = "Crimson Blood"
		elseif Value == "收割者" then
			skinsec = "Reaper"
		elseif Value == "虚空收割者" then
			skinsec = "Void Reaper"
		elseif Value == "圣诞玩具" then
			skinsec = "Christmas Toy"
		elseif Value == "荒地" then
			skinsec = "Wasteland"
		elseif Value == "隐形" then
			skinsec = "Invisible"
		elseif Value == "像素" then
			skinsec = "Pixel"
		elseif Value == "钻石像素" then
			skinsec = "Diamond Pixel"
		elseif Value == "黄金零下" then
			skinsec = "Frozen-Gold"
		elseif Value == "绿水晶" then
			skinsec = "Atomic Nature"
		elseif Value == "生物" then
			skinsec = "Biohazard"
		elseif Value == "樱花" then
			skinsec = "Sakura"
		elseif Value == "精英" then
			skinsec = "Elite"
		elseif Value == "黑樱花" then
			skinsec = "Death Blossom-Gold"
		elseif Value == "彩虹激光" then
			skinsec = "Rainbowlaser"
		elseif Value == "蓝水晶" then
			skinsec = "Atomic Water"
		elseif Value == "紫水晶" then
			skinsec = "Atomic Amethyst"
		elseif Value == "红水晶" then
			skinsec = "Atomic Flame"
		elseif Value == "零下" then
			skinsec = "Sub-Zero"
		elseif Value == "虚空射线" then
			skinsec = "Void-Ray"
		elseif Value == "冰冻钻石" then
			skinsec = "Frozen Diamond"
		elseif Value == "虚空梦魇" then
			skinsec = "Void Nightmare"
		elseif Value == "金雪" then
			skinsec = "Golden Snow"
		elseif Value == "爱国者" then
			skinsec = "Patriot"
		elseif Value == "MM2" then
			skinsec = "MM2 Barrett"
		elseif Value == "声望" then
			skinsec = "Prestige Barnett"
		elseif Value == "酷化" then
			skinsec = "Skin Walter"
		elseif Value == "蒸汽" then
			skinsec = "Steampunk"
		elseif Value == "海盗" then
			skinsec = "Pirate"
		elseif Value == "玫瑰" then
			skinsec = "Rose"
		elseif Value == "黑玫瑰" then
			skinsec = "Black Rose"
		elseif Value == "激光" then
			skinsec = "Hyperlaser"
		elseif Value == "烟花" then
			skinsec = "Firework"
		elseif Value == "诅咒背瓜" then
			skinsec = "Cursed Pumpkin"
		elseif Value == "大炮" then
			skinsec = "Cannon"
		elseif Value == "财富" then
			skinsec = "Firework"
		elseif Value == "黄金大炮" then
			skinsec = "Gold Cannon"
		elseif Value == "四叶草" then
			skinsec = "Lucky Clover"
		elseif Value == "自由" then
			skinsec = "Freedom"
		elseif Value == "黑曜石" then
			skinsec = "Obsidian"
		elseif Value == "赛博朋克" then
			skinsec = "Cyberpunk"
		end
	end
})

local autoskin = false
BeauRight:AddToggle("SkinAll", {
	Text = "全部枪械美化",
	Default = false,
	Callback = function(start)
		autoskin = start
		if autoskin then
			local it = require(ReplicatedStorage.devv).load("v3item").inventory
			local b1 = require(ReplicatedStorage.devv).load("v3item").inventory.items
			for i, item in next, b1 do
				if item.type == "Gun" then
					it.skinUpdate(item.name, skinsec)
				end
			end
		end
	end
})

local FreeGroup = Tabs.Beautify:AddLeftGroupbox("免费物品")

local items = {
	"Golden Rose", "Black Rose", "Dollar Balloon", "Bat Balloon", "Bunny Balloon", "Clover Balloon",
	"Ghost Balloon", "Gold Clover Balloon", "Heart Balloon", "Skull Balloon", "Snowflake Balloon",
	"Admin AK-47", "Admin Nuke Launcher", "Admin RPG", "Void Gem", "Pulse Rifle", "Unusual Money Printer",
	"Money Printer", "Trident", "NextBot Grenade", "El Fuego", "Kunai", "Spirit Kunai"
}
local itemDisplayNames = {
	["Golden Rose"] = "金玫瑰", ["Black Rose"] = "黑玫瑰", ["Dollar Balloon"] = "美元气球",
	["Bat Balloon"] = "蝙蝠气球", ["Bunny Balloon"] = "兔子气球", ["Clover Balloon"] = "三叶草气球",
	["Ghost Balloon"] = "幽灵气球", ["Gold Clover Balloon"] = "金三叶草气球", ["Heart Balloon"] = "爱心气球",
	["Skull Balloon"] = "骷髅气球", ["Snowflake Balloon"] = "雪花气球", ["Admin AK-47"] = "管理员黄金AK-47",
	["Admin Nuke Launcher"] = "管理员核弹发射器", ["Admin RPG"] = "管理员RPG", ["Void Gem"] = "虚空宝石",
	["Pulse Rifle"] = "脉冲步枪", ["Unusual Money Printer"] = "异常印钞机", ["Money Printer"] = "印钞机",
	["Trident"] = "三叉戟", ["NextBot Grenade"] = "NextBot手榴弹", ["El Fuego"] = "烈焰喷射器",
	["Kunai"] = "苦无", ["Spirit Kunai"] = "灵魂苦无"
}
local itemData = {}

itemData["Bat Balloon"] = {name = "Bat Balloon", cost = 0, unpurchasable = true, multiplier = 0.625, holdableType = "Balloon", canDrop = true, dropCooldown = 120, permanent = true, TPSOffsets = {hold = CFrame.new(0, 0, 0)}, viewportOffsets = {hotbar = {dist = 5.5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, math.pi, 0)}, ammoHUD = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}}}
itemData["Bunny Balloon"] = {name = "Bunny Balloon", cost = 0, unpurchasable = true, multiplier = 0.61, holdableType = "Balloon", canDrop = true, dropCooldown = 120, permanent = true, TPSOffsets = {hold = CFrame.new(0, 0, 0)}, viewportOffsets = {hotbar = {dist = 4.75, offset = CFrame.new(0, -0.25, 0), rotoffset = CFrame.Angles(0, 4.71238898038469, 0)}, ammoHUD = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}}}
itemData["Clover Balloon"] = {name = "Clover Balloon", cost = 200, unpurchasable = true, multiplier = 0.625, holdableType = "Balloon", canDrop = true, dropCooldown = 120, permanent = true, TPSOffsets = {hold = CFrame.new(0, 0, 0)}, viewportOffsets = {hotbar = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}, ammoHUD = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}}}
itemData["Ghost Balloon"] = {name = "Ghost Balloon", cost = 0, unpurchasable = true, multiplier = 0.625, holdableType = "Balloon", canDrop = true, dropCooldown = 120, permanent = true, TPSOffsets = {hold = CFrame.new(0, 0, 0)}, viewportOffsets = {hotbar = {dist = 3.5, offset = CFrame.new(0, 0.5, 0), rotoffset = CFrame.Angles(0, math.pi, 0)}, ammoHUD = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}}}
itemData["Gold Clover Balloon"] = {name = "Gold Clover Balloon", cost = 250000, unpurchasable = true, multiplier = 0.6, holdableType = "Balloon", canDrop = true, dropCooldown = 120, permanent = true, TPSOffsets = {hold = CFrame.new(0, 0, 0)}, viewportOffsets = {hotbar = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}, ammoHUD = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}}}
itemData["Heart Balloon"] = {name = "Heart Balloon", cost = 200, multiplier = 0.6, holdableType = "Balloon", unpurchasable = true, canDrop = true, dropCooldown = 120, permanent = true, TPSOffsets = {hold = CFrame.new(0, 0, 0)}, viewportOffsets = {hotbar = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}, ammoHUD = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}}}
itemData["Skull Balloon"] = {name = "Skull Balloon", cost = 0, unpurchasable = true, multiplier = 0.625, holdableType = "Balloon", canDrop = true, dropCooldown = 120, permanent = true, TPSOffsets = {hold = CFrame.new(0, 0, 0)}, viewportOffsets = {hotbar = {dist = 5.5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, -270, 0)}, ammoHUD = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}}}
itemData["Snowflake Balloon"] = {name = "Snowflake Balloon", cost = 0, unpurchasable = true, multiplier = 0.625, holdableType = "Balloon", canDrop = true, dropCooldown = 120, permanent = true, TPSOffsets = {hold = CFrame.new(0, 0, 0)}, viewportOffsets = {hotbar = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, (math.pi/2), 0)}, ammoHUD = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}}}
itemData["Golden Rose"] = {name = "Golden Rose", guid = "golden_rose_"..tostring(tick()), permanent = true, canDrop = true, dropCooldown = 120, multiplier = 0.625, holdableType = "Balloon", movespeedAdd = 5, TPSOffsets = {hold = CFrame.new(0, 0.5, 0)}, viewportOffsets = {hotbar = {dist = 3, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, (math.pi/2), 0)}, ammoHUD = {dist = 2, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.3744467859455345, 0)}, slotButton = {dist = 1, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, (-math.pi/2), 0)}}}
itemData["Black Rose"] = {name = "Black Rose", guid = "black_rose_"..tostring(tick()), permanent = true, canDrop = true, dropCooldown = 120, multiplier = 0.75, holdableType = "Balloon", movespeedAdd = 12, TPSOffsets = {hold = CFrame.new(0, 0.5, 0)}, viewportOffsets = {hotbar = {dist = 3, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, (math.pi/2), 0)}, ammoHUD = {dist = 2, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.3744467859455345, 0)}, slotButton = {dist = 1, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, (-math.pi/2), 0)}}}
itemData["Dollar Balloon"] = {name = "Dollar Balloon", cost = 100000000000, unpurchasable = true, multiplier = 0.8, holdableType = "Balloon", movespeedAdd = 8, cannotDiscard = true, TPSOffsets = {hold = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.pi, 0)}, viewportOffsets = {hotbar = {dist = 4, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}, ammoHUD = {dist = 5, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 0, 0)}}}
itemData["Admin AK-47"] = {name = "Admin AK-47", modelName = "Gold AK-47", subtype = "AK-47", adminOnly = true, canDrop = false, unpurchasable = true, damage = 10, ammo = 999999999, startAmmo = -1, maxAmmo = -1, firemode = "auto", numProjectiles = 8, fireDebounce = 0.01}
itemData["Admin Nuke Launcher"] = {name = "Admin Nuke Launcher", modelName = "Nuke Launcher", subtype = "Nuke Launcher", adminOnly = true, canDrop = false, unpurchasable = true, ammo = 99999999, startAmmo = -1, maxAmmo = -1, overrideProjectileProperties = {disableNukeFlash = true}, reloadTime = 0, reloadType = "mag", firemode = "auto", numProjectiles = 1, fireDebounce = 0.2}
itemData["Admin RPG"] = {canDrop = false, unpurchasable = true, name = "Admin RPG", modelName = "RPG", subtype = "RPG", adminOnly = true, ammo = 99999999, startAmmo = -1, maxAmmo = -1, reloadTime = 0, reloadType = "mag", firemode = "auto", numProjectiles = 1, fireDebounce = 0.02, recoilAdd = 0, maxRecoil = 0, recoilDiminishFactor = 0, recoilFastDiminishFactor = 0}
itemData["Void Gem"] = {name = "Void Gem", subtype = "gem", maxAmmo = 3, adminLimit = 1, sellPrice = 25000, canDrop = true, dropCooldown = 300}
itemData["Pulse Rifle"] = {name = "Pulse Rifle", subtype = "Raygun", unpurchasable = true, damage = 22, headshotMultiplier = 1.5, ammo = 50, startAmmo = -1, maxAmmo = -1, reloadTime = 3.5, reloadType = "mag", firemode = "auto", numProjectiles = 1, fireDebounce = 0.04, projectileLength = 20, projectileLifetime = 200, speedDropoff = 0.04, speedMax = 5, baseSpread = 3, baseAimSpread = 0.8, spread = 11, aimSpread = 2.4, recoilAdd = 0.05, maxRecoil = 0.4, recoilDiminishFactor = 0.95, recoilFastDiminishFactor = 0.85}
itemData["Unusual Money Printer"] = {name = "Unusual Money Printer", cost = 500, ammo = 1, startAmmo = -1, maxAmmo = 1, hint = {computer = "Click to Place", console = "Click to Place"}, canDrop = true, dropCooldown = 600, isConsumable = true, TPSOffsets = {hold = CFrame.new(-0.1, 0, -0.75) * CFrame.Angles(0, 0, 0)}, viewportOffsets = {hotbar = {dist = 5, offset = CFrame.new(0, 0.15, 0), rotoffset = CFrame.Angles(0, (-math.pi/2), 0)}, ammoHUD = {dist = 3.25, offset = CFrame.new(0, 1, 0), rotoffset = CFrame.Angles(0, (math.pi/2), 0)}}}
itemData["Money Printer"] = {name = "Money Printer", ammo = 1, startAmmo = -1, maxAmmo = 1, adminLimit = 10, hint = {computer = "Click to Place", console = "Click to Place"}, canDrop = true, dropCooldown = 600, isConsumable = true, permanent = true, TPSOffsets = {hold = CFrame.new(-0.1, 0, -0.75) * CFrame.Angles(0, 0, 0)}, viewportOffsets = {hotbar = {dist = 5, offset = CFrame.new(0, 0.15, 0), rotoffset = CFrame.Angles(0, (-math.pi/2), 0)}, ammoHUD = {dist = 3.25, offset = CFrame.new(0, 1, 0), rotoffset = CFrame.Angles(0, (-math.pi/2), 0)}}}
itemData["Trident"] = {name = "Trident", subtype = "RPG", unpurchasable = true, ammo = 1, startAmmo = 12, maxAmmo = 12, firemode = "semi", numProjectiles = 3, fireDebounce = 0.5, projectileLength = 4, projectileLifetime = 1000, speedDropoff = 0.04, speedMax = 5, baseSpread = 5, baseAimSpread = 1, spread = 10, aimSpread = 6, recoilAdd = 1, maxRecoil = 1.25, recoilDiminishFactor = 0.9, recoilFastDiminishFactor = 0.66}
itemData["NextBot Grenade"] = {name = "NextBot Grenade", isNade = true, bounceSFX = "nadeBounce", canDrop = true, dropCooldown = 600, thrownOffset = CFrame.Angles(0, (math.pi/2), 0), ammo = 1, startAmmo = -1, maxAmmo = 1, permanent = true, throwDist = 50, TPSOffsets = {hold = CFrame.new(-0.1, 0.25, -0.125)}, viewportOffsets = {hotbar = {dist = 2.75, offset = CFrame.new(0, -0.125, 0), rotoffset = CFrame.Angles(0, 1.8849555921538759, 0)}, ammoHUD = {dist = 2, offset = CFrame.new(0, 0.1, 0), rotoffset = CFrame.Angles(0, (math.pi/2), 0)}}}
itemData["El Fuego"] = {name = "El Fuego", modelName = "El Fuego", subtype = "Flamethrower", unpurchasable = true, ammo = 600, startAmmo = 0, maxAmmo = 600, reloadTime = 6, reloadType = "mag", firemode = "auto", damage = 6, numProjectiles = 3, fireDebounce = 0.05, projectileLength = 4, projectileLifetime = 60, speedDropoff = 0.04, speedMax = 5, baseSpread = 4, baseAimSpread = 2, spread = 12, aimSpread = 6, recoilAdd = 0.1, maxRecoil = 1, recoilDiminishFactor = 0.95, recoilFastDiminishFactor = 0.8}
itemData["Kunai"] = {name = "Kunai", permanent = true, canDrop = true, dropCooldown = 120, holdableType = "Kunai", movespeedAdd = 12, TPSOffsets = {hold = CFrame.new(0, -0.3, 0)}, viewportOffsets = {hotbar = {dist = 3, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 1.5707963, 0)}, ammoHUD = {dist = 2, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.3744468, 0)}, slotButton = {dist = 1, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.5707963, 0)}}}
itemData["Spirit Kunai"] = {name = "Spirit Kunai", permanent = true, canDrop = true, dropCooldown = 120, holdableType = "Kunai", movespeedAdd = 12, TPSOffsets = {hold = CFrame.new(0, -0.3, 0)}, viewportOffsets = {hotbar = {dist = 3, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 1.5707963, 0)}, ammoHUD = {dist = 2, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.3744468, 0)}, slotButton = {dist = 1, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.5707963, 0)}}}

local function getItemList()
	local itemList = {}
	for _, itemName in ipairs(items) do
		local displayName = itemDisplayNames[itemName] or itemName
		table.insert(itemList, displayName)
	end
	return itemList
end

local selectedFreeItem = ""
FreeGroup:AddDropdown("FreeItem", {
	Text = "选择物品",
	Values = getItemList(),
	Multi = false,
	Callback = function(value)
		if value and value ~= "" then
			selectedFreeItem = value
		else
			selectedFreeItem = ""
		end
	end
})

local function getItemNameByDisplayName(displayName)
	for itemName, dispName in pairs(itemDisplayNames) do
		if dispName == displayName then return itemName end
	end
	return displayName
end

local function addItem(itemName)
	pcall(function()
		local itemSystem = require(ReplicatedStorage.devv).load("v3item")
		local inventory2 = itemSystem.inventory
		if not itemData[itemName] then return end
		local itemConfig = itemData[itemName]
		local itemToAdd = {
			name = itemConfig.name,
			guid = itemName:lower():gsub(" ", "_").."_"..tostring(tick()),
			permanent = itemConfig.permanent or true,
			canDrop = itemConfig.canDrop or true,
			dropCooldown = itemConfig.dropCooldown or 120,
			multiplier = itemConfig.multiplier or 0.625,
			holdableType = itemConfig.holdableType or "Balloon",
			movespeedAdd = itemConfig.movespeedAdd or 0,
			cannotDiscard = itemConfig.cannotDiscard or false,
			TPSOffsets = itemConfig.TPSOffsets or {hold = CFrame.new(0, 0.5, 0)},
			viewportOffsets = itemConfig.viewportOffsets or {
				hotbar = {dist = 3, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, (math.pi/2), 0)},
				ammoHUD = {dist = 2, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.3744467859455345, 0)},
				slotButton = {dist = 1, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, (-math.pi/2), 0)}
			}
		}
		if itemConfig.subtype then itemToAdd.subtype = itemConfig.subtype end
		if itemConfig.modelName then itemToAdd.modelName = itemConfig.modelName end
		if itemConfig.adminOnly then itemToAdd.adminOnly = itemConfig.adminOnly end
		if itemConfig.damage then itemToAdd.damage = itemConfig.damage end
		if itemConfig.ammo then itemToAdd.ammo = itemConfig.ammo end
		if itemConfig.startAmmo then itemToAdd.startAmmo = itemConfig.startAmmo end
		if itemConfig.maxAmmo then itemToAdd.maxAmmo = itemConfig.maxAmmo end
		if itemConfig.reloadTime then itemToAdd.reloadTime = itemConfig.reloadTime end
		if itemConfig.reloadType then itemToAdd.reloadType = itemConfig.reloadType end
		if itemConfig.firemode then itemToAdd.firemode = itemConfig.firemode end
		if itemConfig.numProjectiles then itemToAdd.numProjectiles = itemConfig.numProjectiles end
		if itemConfig.fireDebounce then itemToAdd.fireDebounce = itemConfig.fireDebounce end
		if itemConfig.projectileLength then itemToAdd.projectileLength = itemConfig.projectileLength end
		if itemConfig.projectileLifetime then itemToAdd.projectileLifetime = itemConfig.projectileLifetime end
		if itemConfig.headshotMultiplier then itemToAdd.headshotMultiplier = itemConfig.headshotMultiplier end
		if itemConfig.hint then itemToAdd.hint = itemConfig.hint end
		if itemConfig.isConsumable then itemToAdd.isConsumable = itemConfig.isConsumable end
		if itemConfig.isNade then itemToAdd.isNade = itemConfig.isNade end
		if itemConfig.throwDist then itemToAdd.throwDist = itemConfig.throwDist end
		if itemConfig.sellPrice then itemToAdd.sellPrice = itemConfig.sellPrice end
		if itemConfig.adminLimit then itemToAdd.adminLimit = itemConfig.adminLimit end
		if itemConfig.overrideProjectileProperties then itemToAdd.overrideProjectileProperties = itemConfig.overrideProjectileProperties end
		if itemConfig.recoilAdd then itemToAdd.recoilAdd = itemConfig.recoilAdd end
		if itemConfig.maxRecoil then itemToAdd.maxRecoil = itemConfig.maxRecoil end
		if itemConfig.recoilDiminishFactor then itemToAdd.recoilDiminishFactor = itemConfig.recoilDiminishFactor end
		if itemConfig.recoilFastDiminishFactor then itemToAdd.recoilFastDiminishFactor = itemConfig.recoilFastDiminishFactor end
		if inventory2.add then
			inventory2.add(itemToAdd, false)
			if inventory2.currentItemsData then
				table.insert(inventory2.currentItemsData, itemToAdd)
			end
		end
		if inventory2.rerender then
			inventory2:rerender()
		end
	end)
end

FreeGroup:AddButton("免费获得选择的物品", function()
	if selectedFreeItem and selectedFreeItem ~= "" then
		local itemName = getItemNameByDisplayName(selectedFreeItem)
		if itemName then
			addItem(itemName)
			notify("已获得：" .. selectedFreeItem)
		end
	else
		notify("请先选择物品")
	end
end)

local OtherLeft = Tabs.Other:AddLeftGroupbox("通用")

OtherLeft:AddSlider("WalkSpeed", {
	Text = "移动速度",
	Default = 16,
	Min = 0,
	Max = 500,
	Rounding = 1,
	Callback = function()
		WalkSpeedMoved = true
	end
})

OtherLeft:AddSlider("JumpPower", {
	Text = "跳跃高度",
	Default = 50,
	Min = 0,
	Max = 500,
	Rounding = 1,
	Callback = function()
		JumpPowerMoved = true
	end
})

local sudu = nil
local Speed = 1
OtherLeft:AddToggle("SpeedMod", {
	Text = "移速修改",
	Default = false,
	Callback = function(v)
		if v == true then
			sudu = heartbeat:Connect(function()
				if lp.Character and lp.Character:FindFirstChild("Humanoid") and lp.Character.Humanoid.Parent then
					if lp.Character.Humanoid.MoveDirection.Magnitude > 0 then
						lp.Character:TranslateBy(lp.Character.Humanoid.MoveDirection * Speed / 10)
					end
				end
			end)
		elseif not v and sudu then
			sudu:Disconnect()
			sudu = nil
		end
	end
})

OtherLeft:AddSlider("SpeedSet", {
	Text = "速度设置",
	Default = 1,
	Min = 1,
	Max = 100,
	Rounding = 1,
	Callback = function(Value)
		Speed = Value
	end
})

OtherLeft:AddButton("飞行", function()
	pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Xingtaiduan/Script/main/Content/FlyGuiV3"))() end)
end)

OtherLeft:AddToggle("Noclip", {
	Text = "穿墙",
	Default = false,
	Callback = function(val)
		if not val and Humanoid then
			Humanoid:ChangeState("Flying")
		end
	end
})

OtherLeft:AddToggle("Fullbright", {
	Text = "夜视",
	Default = false,
	Callback = function(val)
		if not val then
			Lighting.Ambient = Color3.new(0, 0, 0)
		end
	end
})

OtherLeft:AddToggle("InfJump", {
	Text = "无限跳",
	Default = false
})

local OtherRight = Tabs.Other:AddRightGroupbox("杂项")

OtherRight:AddToggle("ShowChat", {
	Text = "显示聊天框",
	Default = false,
	Callback = function(val)
		game:GetService("TextChatService").ChatWindowConfiguration.Enabled = val
	end
})

OtherRight:AddToggle("CashESP", {
	Text = "透视钱",
	Default = false,
	Callback = function(val)
		if val then
			for _, bundle in pairs(Workspace.Game.Entities.CashBundle:GetChildren()) do
				local intVal = bundle:FindFirstChildOfClass("IntValue")
				if intVal then
					ESP.Add(bundle, intVal.Value, Color3.fromRGB(23, 255, 42), 10, "CashESP")
				end
			end
		else
			ESP.Clear("CashESP")
		end
	end
})

local espEnabled = false
local espBillboards = {}
local espConnections = {}
local espHighlights = {}

local function cleanupESP(player)
	if espConnections[player] then
		for _, conn in ipairs(espConnections[player]) do
			pcall(function() conn:Disconnect() end)
		end
		espConnections[player] = nil
	end
	local char = player.Character
	if char then
		pcall(function()
			local hl = char:FindFirstChild("EspHighlight")
			if hl then hl:Destroy() end
		end)
		pcall(function()
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp then
				local bb = hrp:FindFirstChild("EspBillboard")
				if bb then bb:Destroy() end
			end
		end)
	end
	espBillboards[player] = nil
	espHighlights[player] = nil
end

local function createESP(player)
	if player == LocalPlayer then return end
	local char = player.Character
	if not char then return end
	pcall(function()
		local hl = char:FindFirstChild("EspHighlight")
		if hl then hl:Destroy() end
	end)
	pcall(function()
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			local bb = hrp:FindFirstChild("EspBillboard")
			if bb then bb:Destroy() end
		end
	end)
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		task.spawn(function()
			local success = pcall(function() char:WaitForChild("HumanoidRootPart", 5) end)
			if success and espEnabled and player.Parent then
				createESP(player)
			end
		end)
		return
	end
	local highlight = Instance.new("Highlight")
	highlight.Name = "EspHighlight"
	highlight.Parent = char
	highlight.FillTransparency = 0.5
	highlight.FillColor = Color3.fromRGB(255, 255, 0)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	espHighlights[player] = highlight
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "EspBillboard"
	billboard.Parent = hrp
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Parent = billboard
	nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = player.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
	nameLabel.TextStrokeTransparency = 0
	nameLabel.TextSize = 14
	nameLabel.Font = Enum.Font.SourceSansBold
	local distLabel = Instance.new("TextLabel")
	distLabel.Name = "DistLabel"
	distLabel.Parent = billboard
	distLabel.Size = UDim2.new(1, 0, 0.5, 0)
	distLabel.Position = UDim2.new(0, 0, 0.5, 0)
	distLabel.BackgroundTransparency = 1
	distLabel.Text = "0m"
	distLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
	distLabel.TextStrokeTransparency = 0
	distLabel.TextSize = 12
	distLabel.Font = Enum.Font.SourceSans
	espBillboards[player] = billboard
end

local function setupPlayerESP(player)
	if player == LocalPlayer then return end
	if espConnections[player] then
		for _, conn in ipairs(espConnections[player]) do
			pcall(function() conn:Disconnect() end)
		end
	end
	espConnections[player] = {}
	local charAddedConn = player.CharacterAdded:Connect(function(char)
		task.spawn(function()
			pcall(function() char:WaitForChild("HumanoidRootPart", 5) end)
			if espEnabled then
				task.wait(0.1)
				createESP(player)
			end
		end)
	end)
	local charRemovingConn = player.CharacterRemoving:Connect(function()
		cleanupESP(player)
	end)
	table.insert(espConnections[player], charAddedConn)
	table.insert(espConnections[player], charRemovingConn)
	if player.Character and espEnabled then
		createESP(player)
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(function()
		setupPlayerESP(player)
	end)
end

Players.PlayerAdded:Connect(function(player)
	task.spawn(function()
		setupPlayerESP(player)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	cleanupESP(player)
end)

task.spawn(function()
	while true do
		task.wait(0.1)
		if espEnabled then
			for player, billboard in pairs(espBillboards) do
				if not (player.Parent and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and billboard and billboard.Parent) then
					espBillboards[player] = nil
				end
			end
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if not espEnabled then return end
	local myChar = LocalPlayer.Character
	local myPos = myChar and myChar:FindFirstChild("HumanoidRootPart") and myChar.HumanoidRootPart.Position
	if not myPos then return end
	for player, billboard in pairs(espBillboards) do
		if player.Parent and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and billboard and billboard.Parent then
			local distLabel = billboard:FindFirstChild("DistLabel")
			if distLabel then
				local dist = (player.Character.HumanoidRootPart.Position - myPos).Magnitude
				distLabel.Text = string.format("%.0fm", dist)
			end
		end
	end
end)

OtherRight:AddToggle("PlayerESP", {
	Text = "透视玩家",
	Default = false,
	Callback = function(val)
		espEnabled = val
		if val then
			for _, player in ipairs(Players:GetPlayers()) do
				task.spawn(function()
					createESP(player)
				end)
			end
		else
			for _, player in ipairs(Players:GetPlayers()) do
				cleanupESP(player)
			end
		end
	end
})

local DataLeft = Tabs.Data:AddLeftGroupbox("封禁信息")
DataLeft:AddLabel("是否被封禁：否")
DataLeft:AddLabel("封禁开始期：无")
DataLeft:AddLabel("封禁结束期：无")
DataLeft:AddLabel("剩余封禁时间：无")
DataLeft:AddLabel("封禁原因：无")
DataLeft:AddLabel("历史封禁次数：0")

pcall(function()
	local pg2 = lp:FindFirstChildOfClass("PlayerGui")
	pg2.Chat.Frame.ChatChannelParentFrame.Visible = true
	pg2.Chat.Frame.ChatChannelParentFrame.Position = UDim2.new(0, 0, 0, 40)
	pg2.Money.Container.premium.Shadow.Visible = false
	pg2.Money.Container["2x cash"].Shadow.Visible = false
	pg2.Money.Container.premium.Visible = true
	pg2.Money.Container.premium.TextLabel.Text = "俄亥俄州"
	pg2.Money.Container["2x cash"].Visible = true
	pg2.Money.Container["2x cash"].TextLabel.Text = "Aiove"
end)
pcall(function()
	Workspace.BlackMarket.Dealer.Dealer.ProximityPrompt.HoldDuration = 0
	Workspace.BlackMarket.BlackMarketBillboard.TopLabel.Text = "黑市"
	Workspace.BlackMarket.BlackMarketBillboard.BottomLabel.Text = "向黑商出售物品以获得钱!"
end)
pcall(function()
	Workspace.OhioSign.Screen.SurfaceGui.Frame.Population.Text = "俄亥俄州"
end)

pcall(function()
	local Teams = game:GetService("Teams")
	local newTeam = Instance.new("Team")
	newTeam.Name = "俄亥俄州"
	newTeam.Parent = Teams
	lp.Team = newTeam
end)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if input.KeyCode == Enum.KeyCode.Z then
		pcall(function()
			lp.PlayerGui.Backpack.Holder.Locker.Visible = true
		end)
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if input.KeyCode == Enum.KeyCode.E then
		pcall(function()
			Workspace.BankRobbery.VaultDoor.Door.Attachment.ProximityPrompt.HoldDuration = 0
			Workspace.BankRobbery.VaultDoor.Door.Attachment.ProximityPrompt.MaxActivationDistance = 20
			Workspace.BankRobbery.BankCash.Main.Attachment.ProximityPrompt.MaxActivationDistance = 20
		end)
		pcall(function()
			local safe = Workspace.Game.Entities.GoldJewelSafe.GoldJewelSafe
			safe.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt.HoldDuration = 0
			safe.Name = "safeopen"
		end)
		pcall(function()
			local safe2 = Workspace.Game.Entities.JewelSafe.JewelSafe
			safe2.Door["Meshes/LargeSafe_Cube.002_Cube.003_None (1)"].Attachment.ProximityPrompt.HoldDuration = 0
			safe2.Name = "safeopen"
		end)
		pcall(function()
			Workspace.Game.Airdrops.Airdrop.Airdrop.ProximityPrompt.HoldDuration = 0
		end)
	end
end)

for i = 1, 20 do
	pcall(function()
		if Workspace.ToSort:FindFirstChild("Tunnel") then
			Workspace.ToSort.Tunnel:Destroy()
		end
	end)
end

pcall(function()
	local road = Instance.new("Part")
	road.Size = Vector3.new(760.364, 1.001, 46.918)
	road.Anchored = true
	road.Archivable = true
	road.Position = Vector3.new(-255.446, -9.808, -350.11)
	road.Parent = Workspace
	road.Color = Color3.new(0.223529, 0.223529, 0.223529)
	road.Material = "Concrete"
	local road2 = Instance.new("Part")
	road2.Size = Vector3.new(766.188, 5.496, 16.4)
	road2.Anchored = true
	road2.Archivable = true
	road2.Position = Vector3.new(-252.73, -11.793, -379.689)
	road2.Parent = Workspace
	road2.Material = "Concrete"
	road2.Color = Color3.new(0.529412, 0.529412, 0.529412)
	local road3 = Instance.new("Part")
	road3.Size = Vector3.new(563.051, 1.796, 19.772)
	road3.Anchored = true
	road3.Archivable = true
	road3.Position = Vector3.new(-354.694, -9.944, -322.653)
	road3.Parent = Workspace
	road3.Material = "Concrete"
	road3.Color = Color3.new(0.529412, 0.529412, 0.529412)
	local road4 = Instance.new("Part")
	road4.Size = Vector3.new(19.773, 1.796, 239.333)
	road4.Anchored = true
	road4.Archivable = true
	road4.Position = Vector3.new(-83.056, -20.395, -194.468)
	road4.Orientation = Vector3.new(5, 0, 0)
	road4.Parent = Workspace
	road4.Material = "Concrete"
	road4.Color = Color3.new(0.529412, 0.529412, 0.529412)
	local road5 = Instance.new("Part")
	road5.Size = Vector3.new(19.773, 1.796, 239.333)
	road5.Anchored = true
	road5.Archivable = true
	road5.Position = Vector3.new(-19.256, -20.395, -194.468)
	road5.Orientation = Vector3.new(5, 0, 0)
	road5.Parent = Workspace
	road5.Material = "Concrete"
	road5.Color = Color3.new(0.529412, 0.529412, 0.529412)
	local road6 = Instance.new("Part")
	road6.Size = Vector3.new(179.456, 1.796, 19.772)
	road6.Anchored = true
	road6.Archivable = true
	road6.Position = Vector3.new(60.439, -9.944, -322.653)
	road6.Orientation = Vector3.new(0, 0, 0)
	road6.Parent = Workspace
	road6.Material = "Concrete"
	road6.Color = Color3.new(0.529412, 0.529412, 0.529412)
	local road7 = Instance.new("Part")
	road7.Size = Vector3.new(47.792, 1.001, 60.939)
	road7.Anchored = true
	road7.Archivable = true
	road7.Position = Vector3.new(-51.234, -9.808, -343.099)
	road7.Orientation = Vector3.new(0, 0, 0)
	road7.Parent = Workspace
	road7.Material = "Concrete"
	road7.Color = Color3.new(0.223529, 0.223529, 0.223529)
	local road8 = Instance.new("Part")
	road8.Size = Vector3.new(47.792, 1.001, 262.574)
	road8.Anchored = true
	road8.Archivable = true
	road8.Position = Vector3.new(-51.234, -21.234, -181.97)
	road8.Orientation = Vector3.new(5, 0, 0)
	road8.Parent = Workspace
	road8.Material = "Concrete"
	road8.Color = Color3.new(0.223529, 0.223529, 0.223529)
	local rt = Instance.new("Part")
	rt.Size = Vector3.new(47.792, 1.001, 262.574)
	rt.Anchored = true
	rt.Archivable = true
	rt.Position = Vector3.new(-193.438, 46.016, -490.664)
	rt.Orientation = Vector3.new(25, 0, 0)
	rt.Parent = Workspace
	rt.Material = "Concrete"
	rt.Color = Color3.new(0.223529, 0.223529, 0.223529)
	local rt2 = Instance.new("Part")
	rt2.Size = Vector3.new(0.965, 4.432, 262.5)
	rt2.Anchored = true
	rt2.Archivable = true
	rt2.Position = Vector3.new(-216.854, 48.471, -489.503)
	rt2.Orientation = Vector3.new(25, 0, 0)
	rt2.Parent = Workspace
	rt2.Material = "Concrete"
	local rt3 = Instance.new("Part")
	rt3.Size = Vector3.new(0.965, 4.432, 262.5)
	rt3.Anchored = true
	rt3.Archivable = true
	rt3.Position = Vector3.new(-170.157, 48.471, -489.503)
	rt3.Orientation = Vector3.new(25, 0, 0)
	rt3.Parent = Workspace
	rt3.Material = "Concrete"
	local rt4 = Instance.new("Part")
	rt4.Size = Vector3.new(47.792, 1.001, 92.834)
	rt4.Anchored = true
	rt4.Archivable = true
	rt4.Position = Vector3.new(-193.404, 101.593, -655.732)
	rt4.Orientation = Vector3.new(0, 0, 0)
	rt4.Parent = Workspace
	rt4.Material = "Concrete"
	rt4.Color = Color3.new(0.223529, 0.223529, 0.223529)
	local rt5 = Instance.new("Part")
	rt5.Size = Vector3.new(1853.465, 1.001, 44.169)
	rt5.Anchored = true
	rt5.Archivable = true
	rt5.Position = Vector3.new(695.76, 254.199, -680.065)
	rt5.Orientation = Vector3.new(0, 0, 10)
	rt5.Parent = Workspace
	rt5.Material = "Concrete"
	rt5.Color = Color3.new(0.223529, 0.223529, 0.223529)
end)

task.spawn(function()
	while true do
		task.wait(0.1)
		pcall(function()
			local players = Players:GetPlayers()
			for _, player in pairs(players) do
				if not player:FindFirstChild("leaderstats") then
					local leaderstats = Instance.new("IntValue")
					leaderstats.Name = "leaderstats"
					leaderstats.Value = player.stats.Money.Value

					local Rank = Instance.new("NumberValue")
					Rank.Name = "全服金钱"
					Rank.Value = player.stats.Money.Value

					local Health = Instance.new("NumberValue")
					Health.Name = "血量"
					Health.Value = player.Character.Humanoid.Health

					leaderstats.Parent = player
					Rank.Parent = leaderstats
					Health.Parent = leaderstats
				end
			end
		end)
	end
end)

task.spawn(function()
	while true do
		task.wait(0.1)
		pcall(function()
			for _, player in pairs(Players:GetPlayers()) do
				local character = player.Character
				if character then
					local gta = character:FindFirstChild("grabPrompt")
					if gta then
						gta.ClickablePrompt = true
						gta.MaxActivationDistance = 35
						gta.RequiresLineOfSight = false
						gta.HoldDuration = 0
						gta.ActionText = "你可以把Ta抓起来，或者踩死"
					end
				end
			end
		end)
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
