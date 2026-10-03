-- This file has been deobfuscated Luraph using Hurricane https://discord.com/invite/AbeurBzKXe
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera

local TEvent = require(ReplicatedStorage.Shared.Core.TEvent)
local InteractiveItems = workspace.GameSystem.InteractiveItem
local Value = require(ReplicatedStorage.Shared.Core.Value)
local MonstersFolder = workspace.GameSystem.Monsters
local NpcFolder = workspace.GameSystem.NPCModels
local WorldLoots = workspace.GameSystem.Loots.World

local function loadFlightScript()
	local success, err = pcall(function()
		local main = Instance.new("ScreenGui")
		local Frame = Instance.new("Frame")
		local up = Instance.new("TextButton")
		local down = Instance.new("TextButton")
		local onof = Instance.new("TextButton")
		local TextLabel = Instance.new("TextLabel")
		local plus = Instance.new("TextButton")
		local speed = Instance.new("TextLabel")
		local mine = Instance.new("TextButton")
		local closebutton = Instance.new("TextButton")
		local mini = Instance.new("TextButton")
		local mini2 = Instance.new("TextButton")

		main.Name = "main"
		main.Parent = LocalPlayer:WaitForChild("PlayerGui")
		main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		main.ResetOnSpawn = false

		Frame.Parent = main
		Frame.BackgroundColor3 = Color3.fromRGB(163, 255, 137)
		Frame.BorderColor3 = Color3.fromRGB(103, 221, 213)
		Frame.Position = UDim2.new(0.100320168, 0, 0.379746825, 0)
		Frame.Size = UDim2.new(0, 190, 0, 57)

		up.Name = "up"
		up.Parent = Frame
		up.BackgroundColor3 = Color3.fromRGB(79, 255, 152)
		up.Size = UDim2.new(0, 44, 0, 28)
		up.Font = Enum.Font.SourceSans
		up.Text = "上升"
		up.TextColor3 = Color3.fromRGB(0, 0, 0)
		up.TextSize = 14

		down.Name = "down"
		down.Parent = Frame
		down.BackgroundColor3 = Color3.fromRGB(215, 255, 121)
		down.Position = UDim2.new(0, 0, 0.491228074, 0)
		down.Size = UDim2.new(0, 44, 0, 28)
		down.Font = Enum.Font.SourceSans
		down.Text = "下落"
		down.TextColor3 = Color3.fromRGB(0, 0, 0)
		down.TextSize = 14

		onof.Name = "onof"
		onof.Parent = Frame
		onof.BackgroundColor3 = Color3.fromRGB(255, 249, 74)
		onof.Position = UDim2.new(0.702823281, 0, 0.491228074, 0)
		onof.Size = UDim2.new(0, 56, 0, 28)
		onof.Font = Enum.Font.SourceSans
		onof.Text = "飞"
		onof.TextColor3 = Color3.fromRGB(0, 0, 0)
		onof.TextSize = 14

		TextLabel.Parent = Frame
		TextLabel.BackgroundColor3 = Color3.fromRGB(242, 60, 255)
		TextLabel.Position = UDim2.new(0.469327301, 0, 0, 0)
		TextLabel.Size = UDim2.new(0, 100, 0, 28)
		TextLabel.Font = Enum.Font.SourceSans
		TextLabel.Text = "Aiove"
		TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
		TextLabel.TextScaled = true
		TextLabel.TextSize = 14
		TextLabel.TextWrapped = true

		plus.Name = "plus"
		plus.Parent = Frame
		plus.BackgroundColor3 = Color3.fromRGB(133, 145, 255)
		plus.Position = UDim2.new(0.231578946, 0, 0, 0)
		plus.Size = UDim2.new(0, 45, 0, 28)
		plus.Font = Enum.Font.SourceSans
		plus.Text = "+"
		plus.TextColor3 = Color3.fromRGB(0, 0, 0)
		plus.TextScaled = true
		plus.TextSize = 14
		plus.TextWrapped = true

		speed.Name = "speed"
		speed.Parent = Frame
		speed.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
		speed.Position = UDim2.new(0.468421042, 0, 0.491228074, 0)
		speed.Size = UDim2.new(0, 44, 0, 28)
		speed.Font = Enum.Font.SourceSans
		speed.Text = "1"
		speed.TextColor3 = Color3.fromRGB(0, 0, 0)
		speed.TextScaled = true
		speed.TextSize = 14
		speed.TextWrapped = true

		mine.Name = "mine"
		mine.Parent = Frame
		mine.BackgroundColor3 = Color3.fromRGB(123, 255, 247)
		mine.Position = UDim2.new(0.231578946, 0, 0.491228074, 0)
		mine.Size = UDim2.new(0, 45, 0, 29)
		mine.Font = Enum.Font.SourceSans
		mine.Text = "-"
		mine.TextColor3 = Color3.fromRGB(0, 0, 0)
		mine.TextScaled = true
		mine.TextSize = 14
		mine.TextWrapped = true

		closebutton.Name = "Close"
		closebutton.Parent = Frame
		closebutton.BackgroundColor3 = Color3.fromRGB(225, 25, 0)
		closebutton.Font = Enum.Font.SourceSans
		closebutton.Size = UDim2.new(0, 45, 0, 28)
		closebutton.Text = "X"
		closebutton.TextSize = 30
		closebutton.Position = UDim2.new(0, 0, -1, 27)

		mini.Name = "minimize"
		mini.Parent = Frame
		mini.BackgroundColor3 = Color3.fromRGB(192, 150, 230)
		mini.Font = Enum.Font.SourceSans
		mini.Size = UDim2.new(0, 45, 0, 28)
		mini.Text = "-"
		mini.TextSize = 40
		mini.Position = UDim2.new(0, 44, -1, 27)

		mini2.Name = "minimize2"
		mini2.Parent = Frame
		mini2.BackgroundColor3 = Color3.fromRGB(192, 150, 230)
		mini2.Font = Enum.Font.SourceSans
		mini2.Size = UDim2.new(0, 45, 0, 28)
		mini2.Text = "+"
		mini2.TextSize = 40
		mini2.Position = UDim2.new(0, 44, 0, 30)
		mini2.Visible = false

		local speeds = 1
		local speaker = LocalPlayer
		local chr = speaker.Character
		local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
		local nowe = false

		local Notify = function() end

		Frame.Active = true
		Frame.Draggable = true

		closebutton.MouseButton1Click:Connect(function()
			main:Destroy()
		end)

		up.MouseButton1Click:Connect(function()
			if chr and chr:FindFirstChild("HumanoidRootPart") then
				chr.HumanoidRootPart.CFrame = chr.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
			end
		end)

		down.MouseButton1Click:Connect(function()
			if chr and chr:FindFirstChild("HumanoidRootPart") then
				chr.HumanoidRootPart.CFrame = chr.HumanoidRootPart.CFrame + Vector3.new(0, -3, 0)
			end
		end)

		mini.MouseButton1Click:Connect(function()
			up.Visible = false
			down.Visible = false
			onof.Visible = false
			plus.Visible = false
			speed.Visible = false
			mine.Visible = false
			closebutton.Visible = false
			mini.Visible = false
			mini2.Visible = true
			Frame.Size = UDim2.new(0, 100, 0, 28)
			TextLabel.Position = UDim2.new(0, 0, 0, 0)
		end)

		mini2.MouseButton1Click:Connect(function()
			up.Visible = true
			down.Visible = true
			onof.Visible = true
			plus.Visible = true
			speed.Visible = true
			mine.Visible = true
			closebutton.Visible = true
			mini.Visible = true
			mini2.Visible = false
			Frame.Size = UDim2.new(0, 190, 0, 57)
			TextLabel.Position = UDim2.new(0.469327301, 0, 0, 0)
		end)

		plus.MouseButton1Click:Connect(function()
			speeds = speeds + 1
			speed.Text = tostring(speeds)
		end)

		mine.MouseButton1Click:Connect(function()
			if speeds > 1 then
				speeds = speeds - 1
				speed.Text = tostring(speeds)
			else
				speed.Text = "错误"
				task.wait(0.2)
				speed.Text = "1"
				speeds = 1
			end
		end)

		speaker.CharacterAdded:Connect(function(newChar)
			chr = newChar
			hum = chr:FindFirstChildOfClass("Humanoid")
		end)

		local function startFlight()
			nowe = true
			onof.Text = "飞"
			if hum then
				for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
					hum:SetStateEnabled(state, false)
				end
				hum:ChangeState(Enum.HumanoidStateType.Swimming)
			end
			if chr.Animate then
				chr.Animate.Disabled = true
			end
			if hum then
				for _, v in next, hum:GetPlayingAnimationTracks() do
					v:AdjustSpeed(0)
				end
			end

			task.spawn(function()
				while nowe and chr and hum do
					RunService.Heartbeat:Wait()
					if hum.MoveDirection.Magnitude > 0 then
						chr:TranslateBy(hum.MoveDirection * speeds)
					end
				end
			end)

			local rootPart
			if hum.RigType == Enum.HumanoidRigType.R6 then
				rootPart = chr.Torso
			else
				rootPart = chr.UpperTorso
			end
			if rootPart then
				local bg = Instance.new("BodyGyro", rootPart)
				bg.P = 9e4
				bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
				bg.CFrame = rootPart.CFrame
				local bv = Instance.new("BodyVelocity", rootPart)
				bv.Velocity = Vector3.new(0, 0, 0)
				bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)

				if nowe then
					LocalPlayer.Character.Humanoid.PlatformStand = true
				end

				while nowe and LocalPlayer.Character.Humanoid.Health > 0 do
					RunService.RenderStepped:Wait()
					bg.CFrame = workspace.CurrentCamera.CoordinateFrame
				end
				bg:Destroy()
				bv:Destroy()
				LocalPlayer.Character.Humanoid.PlatformStand = false
				LocalPlayer.Character.Animate.Disabled = false
			end
		end

		local function stopFlight()
			nowe = false
			onof.Text = "飞"
			if hum then
				for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
					hum:SetStateEnabled(state, true)
				end
				hum:ChangeState(Enum.HumanoidStateType.Running)
			end
			if chr.Animate then
				chr.Animate.Disabled = false
			end
		end

		onof.MouseButton1Click:Connect(function()
			if not nowe then
				startFlight()
			else
				stopFlight()
			end
		end)
	end)

	if not success then
		warn("飞行脚本加载失败：" .. tostring(err))
	end
end

local AutoTranslateEnabled = false
local translateLoop = false
local translatedTexts = {}

local function isEnglish(text)
	if not text or text == "" then return false end
	local englishCount, totalCount = 0, 0
	for char in text:gmatch(".") do
		local byte = string.byte(char)
		if byte then
			totalCount = totalCount + 1
			if (byte >= 65 and byte <= 90) or (byte >= 97 and byte <= 122) then
				englishCount = englishCount + 1
			end
		end
	end
	if totalCount == 0 then return false end
	return (englishCount / totalCount) > 0.5
end

local function translateText(text)
	if not text or text == "" or #text < 2 then return nil end
	if translatedTexts[text] then return translatedTexts[text] end
	local success, result = pcall(function()
		local url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=zh-CN&dt=t&q=" .. HttpService:UrlEncode(text)
		local response = game:HttpGet(url)
		local decoded = HttpService:JSONDecode(response)
		if decoded and decoded[1] and decoded[1][1] and decoded[1][1][1] then
			return decoded[1][1][1]
		end
		return nil
	end)
	if success and result then
		translatedTexts[text] = result
		return result
	end
	return nil
end

local function processTextObject(obj)
	if not AutoTranslateEnabled then return end
	if not obj:IsA("TextLabel") and not obj:IsA("TextButton") and not obj:IsA("TextBox") then return end
	local originalText = obj.Text
	if not originalText or originalText == "" then return end
	if not isEnglish(originalText) then return end
	local translated = translateText(originalText)
	if translated and translated ~= originalText then
		obj.Text = translated
	end
end

local function scanAndTranslate(container, maxCount)
	local count = 0
	for _, obj in ipairs(container:GetDescendants()) do
		if count >= maxCount then break end
		if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
			if isEnglish(obj.Text) then
				processTextObject(obj)
				count = count + 1
			end
		end
	end
end

local function startAutoTranslate()
	AutoTranslateEnabled = true
	if translateLoop then return end
	translateLoop = true
	task.spawn(function()
		while translateLoop and AutoTranslateEnabled do
			local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
			if PlayerGui then
				scanAndTranslate(PlayerGui, 5)
			end
			pcall(function()
				for _, gui in ipairs(CoreGui:GetChildren()) do
					if gui:IsA("ScreenGui") then
						scanAndTranslate(gui, 5)
					end
				end
			end)
			task.wait(0.1)
		end
	end)
end

local function stopAutoTranslate()
	AutoTranslateEnabled = false
	translateLoop = false
end

local function InteractWithItem(item)
	if (item:IsA("Model") or item:IsA("Tool")) and item:HasTag("Interactable") and item:GetAttribute("en") then
		TEvent.FireRemote("Interactable", item)
	end
end

local autoOpenEnabled = false
local autoOpenConn = nil

local function SetAutoOpen(state)
	autoOpenEnabled = state
	if state then
		for _, item in pairs(InteractiveItems:GetChildren()) do
			InteractWithItem(item)
		end
		autoOpenConn = InteractiveItems.ChildAdded:Connect(InteractWithItem)
	else
		if autoOpenConn then
			autoOpenConn:Disconnect()
			autoOpenConn = nil
		end
	end
end

local function ForceOpenAllContainersOnce()
	for _, item in pairs(InteractiveItems:GetChildren()) do
		InteractWithItem(item)
	end
end

local infiniteStamina = false
local staminaConnection = nil

local function setInfiniteStamina(state)
	infiniteStamina = state
	if state then
		for _, conn in pairs(getconnections(RunService.PreRender)) do
			local src = debug.info(conn.Function, "s")
			if src == "ReplicatedStorage.Client.System.Property.StaminaHandle" then
				conn:Disconnect()
			end
		end
		staminaConnection = RunService.PreRender:Connect(function()
			if infiniteStamina then
				Value.Stamina = 100
			end
		end)
	else
		if staminaConnection then
			staminaConnection:Disconnect()
			staminaConnection = nil
		end
	end
end

local function getColorByPrice(price)
	if price <= 15 then return Color3.new(1, 1, 1)
	elseif price <= 120 then return Color3.new(0, 1, 0)
	elseif price <= 338 then return Color3.new(0, 0, 1)
	elseif price <= 1000 then return Color3.new(0.5, 0, 0.5)
	elseif price <= 10000 then return Color3.new(1, 0.84, 0)
	else return Color3.new(1, 0, 0) end
end

local itemConfig = {
	Enabled = false,
	Tracer = false,
	Name = true,
	Distance = true,
	Price = true,
	MinPrice = 0
}

local ItemEspCache = {}
local Tracers = {}
local ItemChildrenCache = {}
local ItemRenderConn = nil
local ItemChildAddedConn = nil

local function createTracer()
	local line = Drawing.new("Line")
	line.Thickness = 3
	line.Transparency = 0.15
	line.Visible = false
	return line
end

local function getPriceColor(price)
	if price >= 10000 then
		return Color3.fromRGB(255, 215, 0)
	elseif price >= 5000 then
		return Color3.fromRGB(255, 165, 0)
	elseif price >= 2000 then
		return Color3.fromRGB(50, 205, 50)
	elseif price >= 1000 then
		return Color3.fromRGB(135, 206, 250)
	else
		return Color3.fromRGB(255, 255, 255)
	end
end

local function createItemEsp(item)
	local lootUI = item:FindFirstChild("LootUI", true)
	if not lootUI then return end
	local frame = lootUI:FindFirstChild("Frame")
	if not frame then return end
	local nameLbl = frame:FindFirstChild("ItemName")
	local priceLbl = frame:FindFirstChild("Price")
	if not nameLbl or not priceLbl then return end
	local price = tonumber(priceLbl.Text:match("%d+")) or 0
	if price < itemConfig.MinPrice then return end

	local adornPart = item:FindFirstChildWhichIsA("BasePart", true)
	if not adornPart then return end

	local itemColor = getColorByPrice(price)

	local highlight = Instance.new("Highlight")
	highlight.FillColor = itemColor
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.Parent = item

	local billboard = Instance.new("BillboardGui")
	billboard.Adornee = adornPart
	billboard.Size = UDim2.new(0, 150, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 2.5, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = adornPart

	local yPos = 0
	local lineH = 0.33

	local rawName = nameLbl.Text
	local displayName = translatedTexts[rawName] or rawName

	local txtName = Instance.new("TextLabel")
	txtName.Size = UDim2.new(1, 0, lineH, 0)
	txtName.Position = UDim2.new(0, 0, yPos, 0)
	txtName.BackgroundTransparency = 1
	txtName.Text = displayName
	txtName.TextColor3 = itemColor
	txtName.TextStrokeTransparency = 0
	txtName.TextSize = 10
	txtName.Font = Enum.Font.GothamBold
	txtName.Visible = itemConfig.Name
	txtName.Parent = billboard
	if itemConfig.Name then yPos = yPos + lineH end

	
	if not translatedTexts[rawName] and isEnglish(rawName) then
		task.spawn(function()
			local translated = translateText(rawName)
			if translated and txtName and txtName.Parent then
				txtName.Text = translated
			end
		end)
	end

	local txtPrice = Instance.new("TextLabel")
	txtPrice.Size = UDim2.new(1, 0, lineH, 0)
	txtPrice.Position = UDim2.new(0, 0, yPos, 0)
	txtPrice.BackgroundTransparency = 1
	txtPrice.Text = price .. "美元"
	txtPrice.TextColor3 = itemColor
	txtPrice.TextStrokeTransparency = 0
	txtPrice.TextSize = 10
	txtPrice.Font = Enum.Font.GothamBold
	txtPrice.Visible = itemConfig.Price
	txtPrice.Parent = billboard
	if itemConfig.Price then yPos = yPos + lineH end

	local txtDist = Instance.new("TextLabel")
	txtDist.Size = UDim2.new(1, 0, lineH, 0)
	txtDist.Position = UDim2.new(0, 0, yPos, 0)
	txtDist.BackgroundTransparency = 1
	txtDist.Text = "0m"
	txtDist.TextColor3 = itemColor
	txtDist.TextSize = 10
	txtDist.Font = Enum.Font.Gotham
	txtDist.Visible = itemConfig.Distance
	txtDist.Parent = billboard

	ItemEspCache[item] = {
		highlight = highlight,
		billboard = billboard,
		txtName = txtName,
		txtPrice = txtPrice,
		txtDist = txtDist,
		price = price
	}
end

local function updateItemEsp()
	local player = Players.LocalPlayer
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local rootPos = root and root.Position
	local cameraCFrame = Camera.CFrame
	local cameraPos = cameraCFrame.Position
	local viewportSize = Camera.ViewportSize

	if #ItemChildrenCache == 0 then
		for _, item in pairs(WorldLoots:GetChildren()) do
			if item:IsA("Tool") or item:IsA("Model") then
				table.insert(ItemChildrenCache, item)
			end
		end
	end

	for item, data in pairs(ItemEspCache) do
		if not item.Parent or (data.price and data.price < itemConfig.MinPrice) then
			if data.highlight then data.highlight:Destroy() end
			if data.billboard then data.billboard:Destroy() end
			ItemEspCache[item] = nil
		else
			if data.txtName then data.txtName.Visible = itemConfig.Name end
			if data.txtPrice then data.txtPrice.Visible = itemConfig.Price end
			if data.txtDist then
				data.txtDist.Visible = itemConfig.Distance
				if itemConfig.Distance and rootPos then
					local part = item:FindFirstChildWhichIsA("BasePart", true)
					if part then
						local dist = (rootPos - part.Position).Magnitude
						data.txtDist.Text = string.format("%.0fm", dist)
					end
				end
			end
		end
	end

	for i = #ItemChildrenCache, 1, -1 do
		local item = ItemChildrenCache[i]
		if not item.Parent then
			table.remove(ItemChildrenCache, i)
		elseif not ItemEspCache[item] then
			createItemEsp(item)
		end
	end

	for item, tracer in pairs(Tracers) do
		if not item.Parent or not item:IsDescendantOf(workspace) then
			tracer:Remove()
			Tracers[item] = nil
		else
			local part = item:FindFirstChildWhichIsA("BasePart", true)
			if part and itemConfig.Tracer then
				local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
				if onScreen then
					local diff = part.Position - cameraPos
					local price = ItemEspCache[item] and ItemEspCache[item].price or 0
					if price >= itemConfig.MinPrice then
						local color = getPriceColor(price)
						tracer.Color = color
						tracer.From = Vector2.new(viewportSize.X / 2, viewportSize.Y)
						tracer.To = Vector2.new(screenPos.X, screenPos.Y)
						tracer.Visible = true
					else
						tracer.Visible = false
					end
				else
					tracer.Visible = false
				end
			else
				tracer.Visible = false
			end
		end
	end
end

local function setItemEsp(state)
	itemConfig.Enabled = state
	if state then
		table.clear(ItemChildrenCache)
		for _, item in pairs(WorldLoots:GetChildren()) do
			if (item:IsA("Tool") or item:IsA("Model")) and not Tracers[item] then
				Tracers[item] = createTracer()
			end
		end
		ItemChildAddedConn = WorldLoots.ChildAdded:Connect(function(item)
			if item:IsA("Tool") or item:IsA("Model") then
				table.insert(ItemChildrenCache, item)
				if not Tracers[item] then
					Tracers[item] = createTracer()
				end
			end
		end)
		WorldLoots.ChildRemoved:Connect(function(item)
			for i = #ItemChildrenCache, 1, -1 do
				if ItemChildrenCache[i] == item then
					table.remove(ItemChildrenCache, i)
					break
				end
			end
		end)
		ItemRenderConn = RunService.Heartbeat:Connect(updateItemEsp)
	else
		if ItemRenderConn then
			ItemRenderConn:Disconnect()
			ItemRenderConn = nil
		end
		if ItemChildAddedConn then
			ItemChildAddedConn:Disconnect()
			ItemChildAddedConn = nil
		end
		for _, data in pairs(ItemEspCache) do
			if data.highlight then data.highlight:Destroy() end
			if data.billboard then data.billboard:Destroy() end
		end
		for item, tracer in pairs(Tracers) do
			tracer:Remove()
		end
		table.clear(ItemEspCache)
		table.clear(Tracers)
		table.clear(ItemChildrenCache)
	end
end

local teammateESPEnabled = false
local teammateLabels = {}

local elevatorESPEnabled = false
local elevatorLabels = {}

local elevatorKeywords = {"elevator", "lift", "电梯", "升降梯", "エレベーター", "엘리베이터", "ascenseur", "aufzug", "elevador", "лифт"}

local function isElevator(obj)
	if not obj:IsA("Model") and not obj:IsA("BasePart") then return false end
	local nameLower = obj.Name:lower()
	for _, kw in ipairs(elevatorKeywords) do
		if nameLower:find(kw:lower()) then return true end
	end
	return false
end

local function isTeammate(obj)
	if not obj:IsA("Model") then return false end
	if obj == LocalPlayer.Character then return false end
	local player = Players:GetPlayerFromCharacter(obj)
	return player ~= nil and player ~= LocalPlayer
end

local function getTargetPart(obj)
	if obj:IsA("BasePart") then return obj end
	if obj:IsA("Model") then
		local primary = obj.PrimaryPart
		if primary then return primary end
		for _, child in ipairs(obj:GetChildren()) do
			if child:IsA("BasePart") then return child end
		end
	end
	return obj
end

local function clearTeammateESP()
	for _, v in pairs(teammateLabels) do pcall(function() v:Destroy() end) end
	teammateLabels = {}
end

local function clearElevatorESP()
	for _, v in pairs(elevatorLabels) do pcall(function() v:Destroy() end) end
	elevatorLabels = {}
end

local containerEspCache = {}
local containerChildrenCache = {}
local containerConfig = { Enabled = false, Box = true, Name = true, Distance = true }

local function getContainerName(model)
	local name = model.Name
	local nameLower = name:lower()
	if nameLower:find("fridge") or nameLower:find("freezer") or nameLower:find("冰箱") or nameLower:find("冰柜") or nameLower:find("冷藏") or nameLower:find("холодильник") or nameLower:find("frigor") or nameLower:find("kühlschrank") or nameLower:find("frigo") then
		return "冰箱/冰柜"
	elseif nameLower:find("cabinet") or nameLower:find("drawer") or nameLower:find("cupboard") or nameLower:find("wardrobe") or nameLower:find("closet") or nameLower:find("柜") or nameLower:find("橱") or nameLower:find("衣柜") or nameLower:find("schrank") or nameLower:find("armadio") or nameLower:find("placard") or nameLower:find("armario") then
		return "柜子"
	elseif nameLower:find("box") or nameLower:find("crate") or nameLower:find("chest") or nameLower:find("箱") or nameLower:find("盒子") or nameLower:find("木箱") or nameLower:find("铁箱") or nameLower:find("caja") or nameLower:find("boîte") or nameLower:find("kiste") or nameLower:find("scatola") then
		return "箱子"
	elseif nameLower:find("barrel") or nameLower:find("drum") or nameLower:find("canister") or nameLower:find("桶") or nameLower:find("油桶") or nameLower:find("水桶") or nameLower:find("fass") or nameLower:find("barril") or nameLower:find("tonneau") then
		return "桶"
	elseif nameLower:find("shelf") or nameLower:find("rack") or nameLower:find("架") or nameLower:find("estante") or nameLower:find("étagère") or nameLower:find("regal") then
		return "架子"
	elseif nameLower:find("container") or nameLower:find("容器") or nameLower:find("コンテナ") or nameLower:find("контейнер") then
		return "容器"
	elseif nameLower:find("safe") or nameLower:find("金库") or nameLower:find("保险") or nameLower:find("cassaforte") or nameLower:find("cofre") then
		return "保险箱"
	end

	if string.match(name, "[\228-\233]") then
		return name
	end

	local translated = translateText(name)
	return translated or name
end

local function createContainerEsp(model)
	for _, existing in ipairs(model:GetChildren()) do
		if existing:IsA("BillboardGui") then
			existing:Destroy()
		end
	end
	for _, existing in ipairs(model:GetChildren()) do
		if existing:IsA("Highlight") then
			existing:Destroy()
		end
	end

	local root = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
	if not root then return end

	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(255, 255, 0)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.6
	highlight.OutlineTransparency = 0
	highlight.Enabled = containerConfig.Box
	highlight.Parent = model

	local billboard = Instance.new("BillboardGui")
	billboard.Adornee = root
	billboard.Size = UDim2.new(0, 150, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = root

	local txtName = Instance.new("TextLabel")
	txtName.Size = UDim2.new(1, 0, 0.5, 0)
	txtName.BackgroundTransparency = 1
	txtName.Text = getContainerName(model)
	txtName.TextColor3 = Color3.fromRGB(255, 255, 0)
	txtName.TextStrokeTransparency = 0
	txtName.TextSize = 12
	txtName.Font = Enum.Font.GothamBold
	txtName.Visible = containerConfig.Name
	txtName.Parent = billboard

	local txtDist = Instance.new("TextLabel")
	txtDist.Size = UDim2.new(1, 0, 0.5, 0)
	txtDist.Position = UDim2.new(0, 0, 0.5, 0)
	txtDist.BackgroundTransparency = 1
	txtDist.Text = "0m"
	txtDist.TextColor3 = Color3.fromRGB(255, 255, 0)
	txtDist.TextSize = 10
	txtDist.Font = Enum.Font.Gotham
	txtDist.Visible = containerConfig.Distance
	txtDist.Parent = billboard

	containerEspCache[model] = {
		highlight = highlight,
		billboard = billboard,
		txtName = txtName,
		txtDist = txtDist
	}
end

local function updateContainerEsp()
	local player = Players.LocalPlayer
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local rootPos = root and root.Position

	if #containerChildrenCache == 0 then
		for _, obj in pairs(InteractiveItems:GetChildren()) do
			if obj:IsA("Model") or obj:IsA("Tool") then
				table.insert(containerChildrenCache, obj)
			end
		end
	end

	for i = #containerChildrenCache, 1, -1 do
		local obj = containerChildrenCache[i]
		if not obj.Parent then
			table.remove(containerChildrenCache, i)
		elseif not containerEspCache[obj] then
			createContainerEsp(obj)
		end
	end

	for model, data in pairs(containerEspCache) do
		if not model.Parent then
			if data.highlight then data.highlight:Destroy() end
			if data.billboard then data.billboard:Destroy() end
			containerEspCache[model] = nil
		else
			if data.highlight then
				data.highlight.Enabled = containerConfig.Box
			end
			if data.txtName then
				data.txtName.Visible = containerConfig.Name
			end
			if data.txtDist then
				data.txtDist.Visible = containerConfig.Distance
				if containerConfig.Distance and rootPos then
					local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
					if part then
						local dist = (rootPos - part.Position).Magnitude
						data.txtDist.Text = string.format("%.0fm", dist)
					end
				end
			end
		end
	end
end

local containerRenderConn = nil
local containerChildAddedConn = nil

local function setContainerEsp(state)
	containerConfig.Enabled = state
	if state then
		table.clear(containerChildrenCache)
		containerChildAddedConn = InteractiveItems.ChildAdded:Connect(function(obj)
			if obj:IsA("Model") or obj:IsA("Tool") then
				table.insert(containerChildrenCache, obj)
			end
		end)
		InteractiveItems.ChildRemoved:Connect(function(obj)
			for i = #containerChildrenCache, 1, -1 do
				if containerChildrenCache[i] == obj then
					table.remove(containerChildrenCache, i)
					break
				end
			end
		end)
		containerRenderConn = RunService.Heartbeat:Connect(updateContainerEsp)
	else
		if containerRenderConn then
			containerRenderConn:Disconnect()
			containerRenderConn = nil
		end
		if containerChildAddedConn then
			containerChildAddedConn:Disconnect()
			containerChildAddedConn = nil
		end
		for _, data in pairs(containerEspCache) do
			if data.highlight then data.highlight:Destroy() end
			if data.billboard then data.billboard:Destroy() end
		end
		table.clear(containerEspCache)
		table.clear(containerChildrenCache)
	end
end

local monsterEspCache = {}
local monsterChildrenCache = {}
local monsterConfig = { Enabled = false, Box = true, Name = true, Distance = true }

local function getMonsterName(model)
	if model:FindFirstChild("BZ") and model:FindFirstChild("CBZ") and model:FindFirstChild("CBY") then
		return "火鸡"
	elseif model:FindFirstChild("none") and model:FindFirstChild("Y0") then
		return "坑虫"
	elseif model:FindFirstChild("Head") and model.Head:FindFirstChild("LayerCount") then
		return "模仿者"
	elseif model:FindFirstChild("1C1") and model:FindFirstChild("Door") then
		return "假冰箱"
	elseif model:FindFirstChild("LeLower_Leg") and model:FindFirstChild("HumanoidRootPart") then
		return "行走食物"
	elseif model:FindFirstChild("Waist1") and model:FindFirstChild("AnimSaves") then
		return "被遗忘者"
	elseif model:FindFirstChild("Bubble") and model:FindFirstChild("Mouth") then
		return "鳄鱼"
	elseif model:FindFirstChild("Tail") and model:FindFirstChild("WB2") then
		return "猫"
	elseif model:FindFirstChild("WB1") and model:FindFirstChild("YER") then
		return "偷袭鼠"
	elseif model:FindFirstChild("FullFace") and model:FindFirstChild("hat") then
		return "Guest666"
	end
	return model.Name
end

local function createMonsterEsp(model)
	local root = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart", true) or model:FindFirstChildWhichIsA("BasePart", true)
	if not root then return end

	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(255, 0, 0)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.6
	highlight.OutlineTransparency = 0
	highlight.Enabled = monsterConfig.Box
	highlight.Parent = model

	local billboard = Instance.new("BillboardGui")
	billboard.Adornee = root
	billboard.Size = UDim2.new(0, 150, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = root

	local txtName = Instance.new("TextLabel")
	txtName.Size = UDim2.new(1, 0, 0.5, 0)
	txtName.BackgroundTransparency = 1
	txtName.Text = getMonsterName(model)
	txtName.TextColor3 = Color3.fromRGB(255, 0, 0)
	txtName.TextStrokeTransparency = 0
	txtName.TextSize = 12
	txtName.Font = Enum.Font.GothamBold
	txtName.Visible = monsterConfig.Name
	txtName.Parent = billboard

	local txtDist = Instance.new("TextLabel")
	txtDist.Size = UDim2.new(1, 0, 0.5, 0)
	txtDist.Position = UDim2.new(0, 0, 0.5, 0)
	txtDist.BackgroundTransparency = 1
	txtDist.Text = "0m"
	txtDist.TextColor3 = Color3.fromRGB(255, 0, 0)
	txtDist.TextSize = 10
	txtDist.Font = Enum.Font.Gotham
	txtDist.Visible = monsterConfig.Distance
	txtDist.Parent = billboard

	monsterEspCache[model] = {
		highlight = highlight,
		billboard = billboard,
		txtName = txtName,
		txtDist = txtDist
	}
end

local function updateMonsterEsp()
	local player = Players.LocalPlayer
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local rootPos = root and root.Position

	if #monsterChildrenCache == 0 then
		for _, m in pairs(MonstersFolder:GetChildren()) do
			if m:IsA("Model") then
				table.insert(monsterChildrenCache, m)
			end
		end
	end

	for i = #monsterChildrenCache, 1, -1 do
		local m = monsterChildrenCache[i]
		if not m.Parent then
			table.remove(monsterChildrenCache, i)
		elseif not monsterEspCache[m] then
			createMonsterEsp(m)
		end
	end

	for model, data in pairs(monsterEspCache) do
		if not model.Parent then
			if data.highlight then data.highlight:Destroy() end
			if data.billboard then data.billboard:Destroy() end
			monsterEspCache[model] = nil
		else
			if data.highlight then
				data.highlight.Enabled = monsterConfig.Box
			end
			if data.txtName then
				data.txtName.Visible = monsterConfig.Name
			end
			if data.txtDist then
				data.txtDist.Visible = monsterConfig.Distance
				if monsterConfig.Distance and rootPos then
					local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
					if part then
						local dist = (rootPos - part.Position).Magnitude
						data.txtDist.Text = string.format("%.0fm", dist)
					end
				end
			end
		end
	end
end

local monsterRenderConn = nil
local monsterChildAddedConn = nil

local function setMonsterEsp(state)
	monsterConfig.Enabled = state
	if state then
		table.clear(monsterChildrenCache)
		monsterChildAddedConn = MonstersFolder.ChildAdded:Connect(function(m)
			if m:IsA("Model") then
				table.insert(monsterChildrenCache, m)
			end
		end)
		MonstersFolder.ChildRemoved:Connect(function(m)
			for i = #monsterChildrenCache, 1, -1 do
				if monsterChildrenCache[i] == m then
					table.remove(monsterChildrenCache, i)
					break
				end
			end
		end)
		monsterRenderConn = RunService.Heartbeat:Connect(updateMonsterEsp)
	else
		if monsterRenderConn then
			monsterRenderConn:Disconnect()
			monsterRenderConn = nil
		end
		if monsterChildAddedConn then
			monsterChildAddedConn:Disconnect()
			monsterChildAddedConn = nil
		end
		for _, data in pairs(monsterEspCache) do
			if data.highlight then data.highlight:Destroy() end
			if data.billboard then data.billboard:Destroy() end
		end
		table.clear(monsterEspCache)
		table.clear(monsterChildrenCache)
	end
end

local npcEspCache = {}
local npcChildrenCache = {}
local npcConfig = { Enabled = false, Box = true, Name = true, Distance = true }

local function createNpcEsp(model)
	for _, existing in ipairs(model:GetChildren()) do
		if existing:IsA("BillboardGui") then
			existing:Destroy()
		end
	end
	for _, existing in ipairs(model:GetChildren()) do
		if existing:IsA("Highlight") then
			existing:Destroy()
		end
	end

	local root = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart", true) or model:FindFirstChildWhichIsA("BasePart", true)
	if not root then return end

	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(0, 255, 0)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.6
	highlight.OutlineTransparency = 0
	highlight.Enabled = npcConfig.Box
	highlight.Parent = model

	local billboard = Instance.new("BillboardGui")
	billboard.Adornee = root
	billboard.Size = UDim2.new(0, 150, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = root

	local txtName = Instance.new("TextLabel")
	txtName.Size = UDim2.new(1, 0, 0.5, 0)
	txtName.BackgroundTransparency = 1
	txtName.Text = model.Name
	txtName.TextColor3 = Color3.fromRGB(0, 255, 0)
	txtName.TextStrokeTransparency = 0
	txtName.TextSize = 12
	txtName.Font = Enum.Font.GothamBold
	txtName.Visible = npcConfig.Name
	txtName.Parent = billboard

	local txtDist = Instance.new("TextLabel")
	txtDist.Size = UDim2.new(1, 0, 0.5, 0)
	txtDist.Position = UDim2.new(0, 0, 0.5, 0)
	txtDist.BackgroundTransparency = 1
	txtDist.Text = "0m"
	txtDist.TextColor3 = Color3.fromRGB(0, 255, 0)
	txtDist.TextSize = 10
	txtDist.Font = Enum.Font.Gotham
	txtDist.Visible = npcConfig.Distance
	txtDist.Parent = billboard

	npcEspCache[model] = {
		highlight = highlight,
		billboard = billboard,
		txtName = txtName,
		txtDist = txtDist
	}
end

local function updateNpcEsp()
	local player = Players.LocalPlayer
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local rootPos = root and root.Position

	if #npcChildrenCache == 0 then
		for _, npc in pairs(NpcFolder:GetChildren()) do
			if npc:IsA("Model") then
				table.insert(npcChildrenCache, npc)
			end
		end
	end

	for i = #npcChildrenCache, 1, -1 do
		local npc = npcChildrenCache[i]
		if not npc.Parent then
			table.remove(npcChildrenCache, i)
		elseif not npcEspCache[npc] then
			createNpcEsp(npc)
		end
	end

	for model, data in pairs(npcEspCache) do
		if not model.Parent then
			if data.highlight then data.highlight:Destroy() end
			if data.billboard then data.billboard:Destroy() end
			npcEspCache[model] = nil
		else
			if data.highlight then
				data.highlight.Enabled = npcConfig.Box
			end
			if data.txtName then
				data.txtName.Visible = npcConfig.Name
			end
			if data.txtDist then
				data.txtDist.Visible = npcConfig.Distance
				if npcConfig.Distance and rootPos then
					local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
					if part then
						local dist = (rootPos - part.Position).Magnitude
						data.txtDist.Text = string.format("%.0fm", dist)
					end
				end
			end
		end
	end
end

local npcRenderConn = nil
local npcChildAddedConn = nil

local function setNpcEsp(state)
	npcConfig.Enabled = state
	if state then
		table.clear(npcChildrenCache)
		npcChildAddedConn = NpcFolder.ChildAdded:Connect(function(npc)
			if npc:IsA("Model") then
				table.insert(npcChildrenCache, npc)
			end
		end)
		NpcFolder.ChildRemoved:Connect(function(npc)
			for i = #npcChildrenCache, 1, -1 do
				if npcChildrenCache[i] == npc then
					table.remove(npcChildrenCache, i)
					break
				end
			end
		end)
		npcRenderConn = RunService.Heartbeat:Connect(updateNpcEsp)
	else
		if npcRenderConn then
			npcRenderConn:Disconnect()
			npcRenderConn = nil
		end
		if npcChildAddedConn then
			npcChildAddedConn:Disconnect()
			npcChildAddedConn = nil
		end
		for _, data in pairs(npcEspCache) do
			if data.highlight then data.highlight:Destroy() end
			if data.billboard then data.billboard:Destroy() end
		end
		table.clear(npcEspCache)
		table.clear(npcChildrenCache)
	end
end

local function drawTeammateESP()
	clearTeammateESP()
	if not teammateESPEnabled then return end
	local handledModels = {}
	for _, v in pairs(Workspace:GetDescendants()) do
		pcall(function()
			if not isTeammate(v) then return end
			local target = getTargetPart(v)
			local model = v:IsA("Model") and v or v:FindFirstAncestorOfClass("Model")
			if model and handledModels[model] then return end
			if model then handledModels[model] = true end
			local hr = Instance.new("Highlight")
			hr.Adornee = target
			hr.Parent = target
			hr.FillColor = Color3.new(1, 1, 1)
			hr.OutlineColor = Color3.new(1, 1, 1)
			hr.FillTransparency = 0.7
			hr.OutlineTransparency = 0
			hr.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			table.insert(teammateLabels, hr)
		end)
	end
end

local function drawElevatorESP()
	clearElevatorESP()
	if not elevatorESPEnabled then return end
	local handledModels = {}
	for _, v in pairs(Workspace:GetDescendants()) do
		pcall(function()
			if not isElevator(v) then return end
			local target = getTargetPart(v)
			local model = v:IsA("Model") and v or v:FindFirstAncestorOfClass("Model")
			if model and handledModels[model] then return end
			if model then handledModels[model] = true end
			local hr = Instance.new("Highlight")
			hr.Adornee = target
			hr.Parent = target
			hr.FillColor = Color3.new(0, 1, 0)
			hr.OutlineColor = Color3.new(0, 1, 0)
			hr.FillTransparency = 0.3
			hr.OutlineTransparency = 0
			hr.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			table.insert(elevatorLabels, hr)
		end)
	end
end

local function startESPWatcher()
	Workspace.DescendantAdded:Connect(function(obj)
		if teammateESPEnabled and isTeammate(obj) then drawTeammateESP() end
		if elevatorESPEnabled and isElevator(obj) then drawElevatorESP() end
	end)
end

local monsterTrapActive = false
local monsterTrapConn = nil
local monsterSpawnCache = {}

local function trapMonster(model)
	pcall(function()
		if model == LocalPlayer.Character then return end
		if not model:IsA("Model") then return end
		local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
		if root then
			if not monsterSpawnCache[model.Name] then
				monsterSpawnCache[model.Name] = root.CFrame
			else
				root.CFrame = monsterSpawnCache[model.Name]
			end
		end
		local hum = model:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.Health = 0
			hum:ChangeState(Enum.HumanoidStateType.Dead)
		end
		task.delay(0.05, function()
			if model and model.Parent then
				model:Destroy()
			end
		end)
	end)
end

local function startMonsterTrap()
	monsterTrapActive = true
	for _, m in pairs(MonstersFolder:GetChildren()) do
		trapMonster(m)
	end
	monsterTrapConn = MonstersFolder.ChildAdded:Connect(function(m)
		if monsterTrapActive then
			task.wait(0.03)
			trapMonster(m)
		end
	end)
end

local function stopMonsterTrap()
	monsterTrapActive = false
	if monsterTrapConn then
		monsterTrapConn:Disconnect()
		monsterTrapConn = nil
	end
end

local freezeActive = false
local freezeConnection
local originalSpeeds = {}

local function freezeMonsters()
	for _, obj in pairs(Workspace:GetDescendants()) do
		pcall(function()
			if obj:IsA("BasePart") then
				local model = obj:FindFirstAncestorOfClass("Model")
				if model and model ~= LocalPlayer.Character then
					local hum = model:FindFirstChildOfClass("Humanoid")
					if hum and hum.Health > 0 then
						if not originalSpeeds[model] then
							originalSpeeds[model] = hum.WalkSpeed
							hum.WalkSpeed = 0
							hum.JumpPower = 0
							hum.PlatformStand = true
						end
					end
				end
			end
		end)
	end
end

local function unfreezeMonsters()
	for model, origSpeed in pairs(originalSpeeds) do
		pcall(function()
			local hum = model:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.WalkSpeed = origSpeed
				hum.JumpPower = 50
				hum.PlatformStand = false
			end
		end)
	end
	originalSpeeds = {}
end

local function toggleFreeze(state)
	freezeActive = state
	if state then
		freezeMonsters()
		if freezeConnection then freezeConnection:Disconnect() end
		freezeConnection = RunService.Heartbeat:Connect(freezeMonsters)
	else
		if freezeConnection then freezeConnection:Disconnect() freezeConnection = nil end
		unfreezeMonsters()
	end
end

local invincibleEnabled = false
local invincibleConnection = nil

local function enableInvincible()
	local character = LocalPlayer.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		local clone = character.HumanoidRootPart:Clone()
		clone.Parent = character
	end
end

local function onCharacterAddedForInvincible(character)
	task.wait(0.5)
	if invincibleEnabled then
		enableInvincible()
	end
end

local function findNearestElevator(pos)
	local nearest, minDist = nil, math.huge
	for _, part in pairs(Workspace:GetDescendants()) do
		if part:IsA("BasePart") then
			local nameLower = part.Name:lower()
			for _, kw in ipairs(elevatorKeywords) do
				if nameLower:find(kw) then
					local dist = (part.Position - pos).Magnitude
					if dist < minDist then minDist = dist; nearest = part end
					break
				end
			end
		end
	end
	return nearest
end

local function teleportToElevator()
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local hrp = char.HumanoidRootPart
	local elevator = findNearestElevator(hrp.Position)
	if elevator then hrp.CFrame = elevator.CFrame + Vector3.new(0, 2, 0) end
end

local function gatherLootToElevator()
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local elevator = findNearestElevator(char.HumanoidRootPart.Position)
	if not elevator then return end
	for _, obj in pairs(Workspace:GetDescendants()) do
		pcall(function()
			if obj:IsA("Model") and obj:FindFirstChild("LootUI") then
				local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
				if primary then
					primary.CFrame = CFrame.new(elevator.Position + Vector3.new(math.random(-2,2),2,math.random(-2,2)))
				end
			end
		end)
	end
end

local teleportedLoot = {}
local function cleanupInvalidMarks()
	for obj, _ in pairs(teleportedLoot) do
		if not obj.Parent or not obj:FindFirstChild("LootUI") then teleportedLoot[obj] = nil end
	end
end

local function teleportToNearestLoot()
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local hrp = char.HumanoidRootPart
	cleanupInvalidMarks()
	local candidates = {}
	for _, obj in pairs(Workspace:GetDescendants()) do
		pcall(function()
			if obj:IsA("Model") and obj:FindFirstChild("LootUI") and not teleportedLoot[obj] then
				local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
				if primary then
					table.insert(candidates, {obj=obj, primary=primary, dist=(primary.Position - hrp.Position).Magnitude})
				end
			end
		end)
	end
	if #candidates == 0 then teleportedLoot = {} return end
	table.sort(candidates, function(a,b) return a.dist < b.dist end)
	local target = candidates[1]
	hrp.CFrame = target.primary.CFrame + Vector3.new(0,2,0)
	teleportedLoot[target.obj] = true
end

local function teleportToNearestPlayer()
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local hrp = char.HumanoidRootPart
	local nearest, minDist = nil, math.huge
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
			if dist < minDist then minDist = dist; nearest = p.Character.HumanoidRootPart end
		end
	end
	if nearest then hrp.CFrame = nearest.CFrame + Vector3.new(0,2,0) end
end

local desiredWalkSpeed = 16
RunService.Heartbeat:Connect(function()
	local char = LocalPlayer.Character
	if char then
		local humanoid = char:FindFirstChild("Humanoid")
		if humanoid and humanoid.WalkSpeed ~= desiredWalkSpeed then
			humanoid.WalkSpeed = desiredWalkSpeed
		end
	end
end)
LocalPlayer.CharacterAdded:Connect(function(char)
	local humanoid = char:WaitForChild("Humanoid")
	humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if humanoid.WalkSpeed ~= desiredWalkSpeed then
			humanoid.WalkSpeed = desiredWalkSpeed
		end
	end)
end)

local noClipActive = false
local function setNoClip(state)
	noClipActive = state
	local char = LocalPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local minY = math.huge
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			local pos = part.Position
			if pos.Y < minY then minY = pos.Y end
		end
	end
	local threshold = minY + 1
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			if state then
				part.CanCollide = part.Position.Y <= threshold
			else
				part.CanCollide = true
			end
		end
	end
end

local nightVisionEnabled = false
local originalLighting = {}
local function enableNightVision()
	nightVisionEnabled = true
	originalLighting = {
		Brightness = Lighting.Brightness,
		Ambient = Lighting.Ambient,
		OutdoorAmbient = Lighting.OutdoorAmbient,
		ClockTime = Lighting.ClockTime,
		FogEnd = Lighting.FogEnd,
		FogStart = Lighting.FogStart,
		FogColor = Lighting.FogColor,
	}
	Lighting.Brightness = 3
	Lighting.Ambient = Color3.new(1,1,1)
	Lighting.OutdoorAmbient = Color3.new(1,1,1)
	Lighting.ClockTime = 12
	Lighting.FogEnd = 10000
	Lighting.FogStart = 5000
	Lighting.FogColor = Color3.new(1,1,1)
end
local function disableNightVision()
	nightVisionEnabled = false
	if originalLighting.Brightness then
		Lighting.Brightness = originalLighting.Brightness
		Lighting.Ambient = originalLighting.Ambient
		Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
		Lighting.ClockTime = originalLighting.ClockTime
		Lighting.FogEnd = originalLighting.FogEnd
		Lighting.FogStart = originalLighting.FogStart
		Lighting.FogColor = originalLighting.FogColor
	end
end

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
		local char = LocalPlayer.Character
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

local function showTimeWindow(mode)
	local g = Instance.new("ScreenGui", CoreGui)
	local f = Instance.new("Frame", g)
	f.Size = UDim2.new(0,200,0, mode=="both" and 55 or 30)
	f.Position = UDim2.new(0.5,-100,0,80)
	f.BackgroundColor3 = Color3.new(0,0,0)
	f.BackgroundTransparency = 0.3
	f.Active = true
	f.Draggable = true
	Instance.new("UICorner", f).CornerRadius = UDim.new(0,8)
	local t1 = Instance.new("TextLabel", f)
	t1.Size = UDim2.new(1,0,0,30)
	t1.BackgroundTransparency = 1
	t1.TextColor3 = Color3.new(1,1,1)
	t1.Font = Enum.Font.SourceSansBold
	t1.TextSize = 16
	local t2
	if mode == "both" then
		t2 = Instance.new("TextLabel", f)
		t2.Size = UDim2.new(1,0,0,25)
		t2.Position = UDim2.new(0,0,0,30)
		t2.BackgroundTransparency = 1
		t2.TextColor3 = Color3.new(1,0,0)
		t2.Font = Enum.Font.SourceSansBold
		t2.TextSize = 14
	end
	local startTime = tick()
	local conn; conn = g.AncestryChanged:Connect(function() if not g.Parent then conn:Disconnect() end end)
	task.spawn(function()
		while f.Parent do
			local now = os.date("*t")
			local nowStr = string.format("%02d:%02d:%02d", now.hour, now.min, now.sec)
			local elapsed = tick() - startTime
			local h = math.floor(elapsed/3600) local m = math.floor((elapsed%3600)/60) local s = math.floor(elapsed%60)
			local usedStr = string.format("已用 %02d:%02d:%02d", h,m,s)
			if mode == "now" then t1.Text = "现在时间："..nowStr
			elseif mode == "used" then t1.Text = usedStr
			elseif mode == "both" then t1.Text = nowStr if t2 then t2.Text = usedStr end end
			task.wait(1)
		end
	end)
end

local function safeLoad(url)
	local success, result = pcall(function() return loadstring(game:HttpGet(url))() end)
	if not success then warn("加载失败: "..url) return nil end
	return result
end

local Library = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/黑曜石主库.ui")
local ThemeManager = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/主题管理.ui")
local SaveManager = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/配置管理.ui")

if not Library then
	StarterGui:SetCore("SendNotification",{ Title="错误", Text="UI库加载失败", Duration=5 })
	return
end

local Notify = function(msg) Library:Notify(msg,3) end

local autoInteractEnabled = false
local autoInteractRange = 20
local autoInteractSpeed = 0.15
local autoInteractThread = nil
local autoCollectEnabled = false
local autoCollectThread = nil
local autoDiveAfterCollectEnabled = false

local ElevatorDropoff = nil
local PlayerLoots = nil
pcall(function() ElevatorDropoff = Workspace.GameSystem.Loots.ElevatorCollect.SoundPlay end)
pcall(function() PlayerLoots = Workspace.GameSystem.Loots.Player end)

local function pressE()
	pcall(function()
		if keypress and keyrelease then
			keypress(0x45)
			task.wait(0.05)
			keyrelease(0x45)
		else
			local VirtualInputManager = game:GetService("VirtualInputManager")
			VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
			task.wait(0.05)
			VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
		end
	end)
end

local function restoreCamera()
	pcall(function()
		local cam = Workspace.CurrentCamera
		if cam then cam.CameraType = Enum.CameraType.Custom end
	end)
end

local function switchToMobileMode()
	pcall(function()
		local VirtualInputManager = game:GetService("VirtualInputManager")
		VirtualInputManager:SendTouchEvent(1, Enum.TouchState.Began, Vector2.new(100, 100))
		task.wait(0.05)
		VirtualInputManager:SendTouchEvent(1, Enum.TouchState.Ended, Vector2.new(100, 100))
	end)
end

local function remoteInteractItem(item)
	if (item:IsA("Model") or item:IsA("Tool")) and item:HasTag("Interactable") and item:GetAttribute("en") then
		pcall(function()
			TEvent.FireRemote("Interactable", item)
			TEvent.FireBindable("Interactable", item)
		end)
	end
end

local function getLootsInRange(range)
	local results = {}
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return results end
	for _, item in pairs(WorldLoots:GetChildren()) do
		if item:IsA("Model") or item:IsA("Tool") then
			local part = item:FindFirstChildWhichIsA("BasePart", true)
			if part and (part.Position - hrp.Position).Magnitude <= range then
				table.insert(results, item)
			end
		end
	end
	return results
end

local function setAutoInteract(state)
	autoInteractEnabled = state
	if autoInteractThread then
		task.cancel(autoInteractThread)
		autoInteractThread = nil
	end
	if state then
		autoInteractThread = task.spawn(function()
			while autoInteractEnabled do
				for _, item in ipairs(getLootsInRange(autoInteractRange)) do
					remoteInteractItem(item)
				end
				local char = LocalPlayer.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if hrp then
					for _, item in pairs(InteractiveItems:GetChildren()) do
						if item:IsA("Model") or item:IsA("Tool") then
							local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart", true)
							if part and (part.Position - hrp.Position).Magnitude <= autoInteractRange then
								remoteInteractItem(item)
							end
						end
					end
				end
				task.wait(autoInteractSpeed)
			end
		end)
	end
end

local function setAnySell(state)
	anySellEnabled = state
	if state then
		pcall(function()
			if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
				TEvent.FireRemote("PlayerInElevator", true, LocalPlayer.Character.PrimaryPart.CFrame.Position, TEvent.UnixTimeMillis())
			end
		end)
		if anySellCharConn then anySellCharConn:Disconnect() end
		anySellCharConn = LocalPlayer.CharacterAdded:Connect(function()
			task.wait(0.5)
			if anySellEnabled then
				pcall(function()
					if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
						TEvent.FireRemote("PlayerInElevator", true, LocalPlayer.Character.PrimaryPart.CFrame.Position, TEvent.UnixTimeMillis())
					end
				end)
			end
		end)
		task.spawn(function()
			while anySellEnabled do
				task.wait(3)
				if not anySellEnabled then break end
				pcall(function()
					if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
						TEvent.FireRemote("PlayerInElevator", true, LocalPlayer.Character.PrimaryPart.CFrame.Position, TEvent.UnixTimeMillis())
					end
				end)
			end
		end)
	else
		if anySellCharConn then
			anySellCharConn:Disconnect()
			anySellCharConn = nil
		end
	end
end

local function setAutoCollect(state)
	autoCollectEnabled = state
	if autoCollectThread then
		task.cancel(autoCollectThread)
		autoCollectThread = nil
	end
	if not state then
		restoreCamera()
		switchToMobileMode()
	end
	if state then
		setAnySell(true)
		for _, item in pairs(InteractiveItems:GetChildren()) do
			remoteInteractItem(item)
		end
		autoCollectThread = task.spawn(function()
			local fails = {}
			local roundDone = false
			local lastDiveTime = 0
			while autoCollectEnabled do
				local char = LocalPlayer.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if not hrp then
					task.wait(0.5)
					continue
				end
				local targets = {}
				for _, item in pairs(WorldLoots:GetChildren()) do
					local part = item:FindFirstChildWhichIsA("BasePart", true)
					if (item:IsA("Model") or item:IsA("Tool")) and item:FindFirstChild("LootUI", true) and not (fails[item] and fails[item] >= 3) then
						if part then
							table.insert(targets, { item = item, part = part, dist = (part.Position - hrp.Position).Magnitude })
						end
					end
				end
				if #targets == 0 then
					if not roundDone then
						roundDone = true
						restoreCamera()
						Notify("本轮收集完成，等待新物资出现")
					end
					local char = LocalPlayer.Character
					local hrp = char and char:FindFirstChild("HumanoidRootPart")
					if hrp then
						hrp.CFrame = CFrame.new(-310.8, 323.8, 411.3)
					end
					if autoDiveAfterCollectEnabled then
						local char2 = LocalPlayer.Character
						local hrp2 = char2 and char2:FindFirstChild("HumanoidRootPart")
						if hrp2 then
							for _, item in pairs(WorldLoots:GetChildren()) do
								local part = item:FindFirstChildWhichIsA("BasePart", true)
								if part and (part.Position - hrp2.Position).Magnitude <= 10 then
									remoteInteractItem(item)
									pressE()
								end
							end
							for _, item in pairs(InteractiveItems:GetChildren()) do
								local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart", true)
								if part and (part.Position - hrp2.Position).Magnitude <= 10 then
									remoteInteractItem(item)
									pressE()
								end
							end
							task.wait(0.3)
							pcall(function() TEvent.FireRemote("SubmitVote", "continue") end)
							Notify("已自动深入")
						end
					end
					task.wait(1)
					continue
				end
				roundDone = false
				table.sort(targets, function(a, b) return a.dist < b.dist end)
				local target = targets[1]
				hrp.CFrame = target.part.CFrame + Vector3.new(0, 2, 0)
				local cam = Workspace.CurrentCamera
				pcall(function() cam.CameraType = Enum.CameraType.Scriptable end)
				local startTime = os.clock()
				while os.clock() - startTime < 1.2 and autoCollectEnabled do
					if not target.item.Parent or not target.item:FindFirstChild("LootUI", true) then break end
					pcall(function()
						cam.CFrame = CFrame.lookAt(hrp.Position + Vector3.new(0, 8, 0), hrp.Position)
					end)
					remoteInteractItem(target.item)
					pressE()
					task.wait(0.15)
				end
				if target.item.Parent and target.item:FindFirstChild("LootUI", true) then
					fails[target.item] = (fails[target.item] or 0) + 1
				end
				task.wait(0.1)
			end
			autoCollectEnabled = false
		end)
	end
end

StarterGui:SetCore("SendNotification",{
	Title = "亡命速递脚本",
	Text = "Aiove 持续更新\nQQ：3999698324",
	Icon = "rbxthumb://type=Asset&id=5107182114&w=150&h=150"
})

local Window = Library:CreateWindow({
	Title = "亡命速递",
	Footer = "Aiove 制作",
	Icon = 131153193945220,
	NotifySide = "Right",
	ShowCustomCursor = true,
})

local Tabs = {
	Notification = Window:AddTab("通知","info"),
	Main = Window:AddTab("主要功能","star"),
	ESP = Window:AddTab("透视","eye"),
	Settings = Window:AddTab("设置","settings"),
}

local NotifyGroup = Tabs.Notification:AddLeftGroupbox("作者通知")
NotifyGroup:AddLabel("Aiove 持续更新此脚本")
NotifyGroup:AddLabel("QQ：3999698324", true)

local MainLeft = Tabs.Main:AddLeftGroupbox("核心功能")
MainLeft:AddButton({ Text="召唤飞行脚本", Func=function()
	local success, err = pcall(loadFlightScript)
	if success then Notify("飞行脚本已加载") else Notify("飞行脚本加载失败: "..tostring(err)) end
end, DoubleClick=false })
MainLeft:AddToggle("AutoTranslate",{ Text="自动翻译界面", Default=false, Callback=function(v)
	if v then startAutoTranslate() Notify("自动翻译已开启") else stopAutoTranslate() Notify("自动翻译已关闭") end
end})
MainLeft:AddToggle("MonsterTrap",{ Text="困杀怪物（喝茶模式）", Default=false, Callback=function(v)
	if v then startMonsterTrap() Notify("困杀怪物已开启：出生点循环去世") else stopMonsterTrap() Notify("困杀怪物已关闭") end
end})
MainLeft:AddToggle("Freeze",{ Text="冻结怪物", Default=false, Callback=function(v)
	toggleFreeze(v) Notify("冻结怪物: "..(v and "开启" or "关闭"))
end})
MainLeft:AddToggle("AnySell",{ Text="随处出售", Default=false, Callback=function(v)
	anySellEnabled = v
	if v then
		pcall(function()
			if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
				TEvent.FireRemote("PlayerInElevator", true, LocalPlayer.Character.PrimaryPart.CFrame.Position, TEvent.UnixTimeMillis())
			end
		end)
		
		if anySellCharConn then anySellCharConn:Disconnect() end
		anySellCharConn = LocalPlayer.CharacterAdded:Connect(function()
			task.wait(0.5)
			if anySellEnabled then
				pcall(function()
					if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
						TEvent.FireRemote("PlayerInElevator", true, LocalPlayer.Character.PrimaryPart.CFrame.Position, TEvent.UnixTimeMillis())
					end
				end)
			end
		end)
		
		task.spawn(function()
			while anySellEnabled do
				task.wait(3)
				if not anySellEnabled then break end
				pcall(function()
					if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
						TEvent.FireRemote("PlayerInElevator", true, LocalPlayer.Character.PrimaryPart.CFrame.Position, TEvent.UnixTimeMillis())
					end
				end)
			end
		end)
		Notify("随处出售已开启（自动保持）")
	else
		if anySellCharConn then
			anySellCharConn:Disconnect()
			anySellCharConn = nil
		end
		Notify("随处出售已关闭")
	end
end})
MainLeft:AddToggle("Invincible",{ Text="无敌", Default=false, Callback=function(v)
	invincibleEnabled = v
	if v then
		enableInvincible()
		if invincibleConnection then invincibleConnection:Disconnect() end
		invincibleConnection = LocalPlayer.CharacterAdded:Connect(onCharacterAddedForInvincible)
		Notify("无敌已开启")
	else
		if invincibleConnection then
			invincibleConnection:Disconnect()
			invincibleConnection = nil
		end
		Notify("无敌已关闭")
	end
end})
MainLeft:AddButton({ Text="一键开启所有容器", Func=function()
	ForceOpenAllContainersOnce() Notify("已尝试开启所有容器")
end, DoubleClick=false })
MainLeft:AddButton({ Text="物资聚集到电梯", Func=function()
	gatherLootToElevator() Notify("物资已聚集到电梯")
end, DoubleClick=false })
MainLeft:AddButton({ Text="一键传送回电梯", Func=function()
	teleportToElevator() Notify("已传送回电梯")
end, DoubleClick=false })
MainLeft:AddButton({ Text="传送到最近物资", Func=function()
	teleportToNearestLoot() Notify("已传送至最近物资")
end, DoubleClick=false })

local Services = {
	RunService = game:GetService("RunService"),
	Players = game:GetService("Players"),
	Workspace = game:GetService("Workspace")
}

local PushMonsterToggle = false

task.spawn(function()
	while true do
		if PushMonsterToggle then
			pcall(function()
				local character = Services.Players.LocalPlayer.Character
				if not character then return end
				local root = character:FindFirstChild("HumanoidRootPart")
				if not root then return end
				local monsters = Services.Workspace.GameSystem.Monsters
				for _, monster in pairs(monsters:GetChildren()) do
					if not monster:IsA("Model") then continue end
					local monsterRoot = monster.PrimaryPart or monster:FindFirstChild("HumanoidRootPart", true) or monster:FindFirstChild("Checker", true) or monster:FindFirstChild("Hitbox", true) or monster:FindFirstChildOfClass("BasePart", true)
					if monsterRoot then
						local diff = monsterRoot.Position - root.Position
						if diff.Magnitude < 20 then
							local force = diff.Unit * 2000 + Vector3.new(0, 500, 0)
							monsterRoot:ApplyImpulse(force)
						end
					end
				end
			end)
		end
		task.wait(0.1)
	end
end)

local function PullAllItems()
	local character = Services.Players.LocalPlayer.Character
	if not character then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local WorldLoots = Services.Workspace.GameSystem.Loots.World
	for _, item in pairs(WorldLoots:GetChildren()) do
		if not (item:IsA("Tool") or item:IsA("Model")) then continue end
		local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart", true)
		if part then
			part.CFrame = CFrame.new(root.Position + Vector3.new(math.random(-5, 5), 2, math.random(-5, 5)))
		end
	end
end

local function KillAllMonsters()
	for _, monster in pairs(Services.Workspace.GameSystem.Monsters:GetChildren()) do
		pcall(function()
			if monster:IsA("Model") then
				local hum = monster:FindFirstChildOfClass("Humanoid")
				if hum then
					hum.Health = 0
				end
			end
		end)
	end
end

local function TeleportMonstersToElevator()
	local elevatorModel = Services.Workspace:FindFirstChild("电梯")
	if not elevatorModel then return end
	local targetPart = elevatorModel:FindFirstChildWhichIsA("BasePart")
	if not targetPart then return end
	for _, monster in pairs(Services.Workspace.GameSystem.Monsters:GetChildren()) do
		pcall(function()
			local root = monster.PrimaryPart or monster:FindFirstChild("HumanoidRootPart", true) or monster:FindFirstChild("Checker", true) or monster:FindFirstChild("Hitbox", true) or monster:FindFirstChildOfClass("BasePart", true)
			if root then
				root.CFrame = CFrame.new(targetPart.Position + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3)))
			end
		end)
	end
end

_G.AntiAFK = false

task.spawn(function()
	while true do
		if _G.AntiAFK then
			pcall(function()
				local vim = game:GetService("VirtualUser")
				vim:CaptureController()
				vim:ClickButton2(Vector2.new())
			end)
		end
		task.wait(300)
	end
end)

local AutoNextFloorEnabled = false
local AutoNextFloorConn = nil

local function CheckCashAndNextFloor()
	local plr = Services.Players.LocalPlayer
	local PlayerGui = plr:FindFirstChild("PlayerGui")
	if not PlayerGui then return end
	local Main = PlayerGui:FindFirstChild("Main")
	if not Main then return end
	local HomePage = Main:FindFirstChild("HomePage")
	if not HomePage then return end
	local Goal = HomePage:FindFirstChild("Goal")
	if not Goal then return end
	local GoalProgressBar = Goal:FindFirstChild("GoalProgressBar")
	if not GoalProgressBar then return end
	local GoalText = GoalProgressBar:FindFirstChild("GoalText")
	if not GoalText then return end
	local CashText = GoalText:FindFirstChild("Cash")
	local GoalNumText = GoalText:FindFirstChild("Goal")
	if not CashText or not GoalNumText then return end
	local currentCash = tonumber(CashText.Text:match("%d+")) or 0
	local goalNum = tonumber(GoalNumText.Text:match("/(%d+)")) or 0
	if currentCash >= goalNum then
		TEvent.FireRemote("SubmitVote", "continue")
		task.wait(1)
	end
end

AutoNextFloorConn = Services.RunService.Heartbeat:Connect(function()
	if AutoNextFloorEnabled then
		pcall(CheckCashAndNextFloor)
	end
end)

local function SetFullBright(state)
	local Lighting = game:GetService("Lighting")
	if state then
		local Atmosphere = Lighting:FindFirstChild("Atmosphere")
		if Atmosphere then Atmosphere.Density = 0 end
		Lighting.GlobalShadows = false
		Lighting.ClockTime = 12
		Lighting.Brightness = 4
		Lighting.FogEnd = 100000
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	else
		local Atmosphere = Lighting:FindFirstChild("Atmosphere")
		if Atmosphere then Atmosphere.Density = 0.3 end
		Lighting.GlobalShadows = true
		Lighting.ClockTime = 14
		Lighting.Brightness = 2
		Lighting.FogEnd = 5000
		Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
	end
end

local OtherGroup = Tabs.Main:AddLeftGroupbox("其他")
OtherGroup:AddToggle("PushMonster",{ Text="推开怪物", Default=false, Callback=function(v)
	PushMonsterToggle = v Notify("推开怪物: "..(v and "开启" or "关闭"))
end})
OtherGroup:AddButton({ Text="所有物品拉过来", Func=function()
	PullAllItems() Notify("已把所有物品拉到身边")
end, DoubleClick=false })
OtherGroup:AddButton({ Text="杀死所有怪物", Func=function()
	KillAllMonsters() Notify("已杀死所有怪物")
end, DoubleClick=false })
OtherGroup:AddButton({ Text="怪物传送到电梯", Func=function()
	TeleportMonstersToElevator() Notify("已把怪物传送到电梯")
end, DoubleClick=false })
OtherGroup:AddToggle("AntiAFK",{ Text="反挂机（防踢）", Default=false, Callback=function(v)
	_G.AntiAFK = v Notify("反挂机: "..(v and "开启" or "关闭"))
end})
OtherGroup:AddToggle("AutoNextFloor",{ Text="自动下一层", Default=false, Callback=function(v)
	AutoNextFloorEnabled = v Notify("自动下一层: "..(v and "开启" or "关闭"))
end})
OtherGroup:AddToggle("FullBright",{ Text="全亮", Default=false, Callback=function(v)
	SetFullBright(v) Notify("全亮: "..(v and "开启" or "关闭"))
end})

local MainRight = Tabs.Main:AddRightGroupbox("辅助与传送")
MainRight:AddButton({ Text="传送到最近玩家", Func=function()
	teleportToNearestPlayer() Notify("已传送至最近玩家")
end, DoubleClick=false })
MainRight:AddToggle("RemoteOpen",{ Text="远程打开所有容器 (持续)", Default=false, Callback=function(v)
	SetAutoOpen(v) Notify("远程打开容器: "..(v and "开启" or "关闭"))
end})
MainRight:AddToggle("AutoInteract",{ Text="自动交互", Default=false, Callback=function(v)
	setAutoInteract(v) Notify("自动交互: "..(v and "开启" or "关闭"))
end})
MainRight:AddSlider("AutoInteractRange",{ Text="自动交互距离", Default=20, Min=5, Max=200, Rounding=0, Suffix=" studs", Callback=function(v)
	autoInteractRange = v
end})
MainRight:AddSlider("AutoInteractSpeed",{ Text="自动交互速度", Default=0.15, Min=0.05, Max=1, Rounding=2, Suffix=" 秒", Callback=function(v)
	autoInteractSpeed = v
end})
MainRight:AddToggle("AutoCollect",{ Text="自动收集", Default=false, Callback=function(v)
	setAutoCollect(v) Notify("自动收集: "..(v and "开启" or "关闭"))
end})
MainRight:AddToggle("InfiniteStamina",{ Text="无限体力", Default=false, Callback=function(v)
	setInfiniteStamina(v) Notify("无限体力: "..(v and "开启" or "关闭"))
end})
MainRight:AddSlider("WalkSpeed",{ Text="移动速度 (防回拉)", Default=16, Min=16, Max=100, Rounding=0, Suffix=" studs", Callback=function(v)
	desiredWalkSpeed = v
	local char = LocalPlayer.Character
	if char then local hum = char:FindFirstChild("Humanoid") if hum then hum.WalkSpeed = v end end
	Notify("移动速度已设为 "..v)
end})
MainRight:AddButton({ Text="显示现在时间", Func=function() showTimeWindow("now") end, DoubleClick=false })
MainRight:AddButton({ Text="显示已用时长", Func=function() showTimeWindow("used") end, DoubleClick=false })
MainRight:AddButton({ Text="我全都要", Func=function() showTimeWindow("both") end, DoubleClick=false })
MainRight:AddToggle("JumpToggle",{ Text="显示跳跃按钮", Default=false, Callback=function(v)
	jumpEnabled = v
	if v then if not jumpFloatGui then createJumpFloat() end Notify("跳跃按钮已显示") else destroyJumpFloat() Notify("跳跃按钮已隐藏") end
end})
MainRight:AddToggle("NightVision",{ Text="夜视", Default=false, Callback=function(v)
	if v then enableNightVision() Notify("夜视已开启") else disableNightVision() Notify("夜视已关闭") end
end})
MainRight:AddToggle("NoClip",{ Text="穿墙", Default=false, Callback=function(v) setNoClip(v) end})

local ESPGroup = Tabs.ESP:AddLeftGroupbox("透视设置")
ESPGroup:AddToggle("ItemESP",{ Text="透视物资 (价格变色)", Default=false, Callback=function(v)
	setItemEsp(v)
	if v then Notify("物资透视已开启") else Notify("物资透视已关闭") end
end})
ESPGroup:AddToggle("ContainerESP",{ Text="透视容器 (黄色)", Default=false, Callback=function(v)
	setContainerEsp(v)
	if v then Notify("容器透视已开启") else Notify("容器透视已关闭") end
end})
ESPGroup:AddToggle("MonsterESP",{ Text="透视怪物 (红色)", Default=false, Callback=function(v)
	setMonsterEsp(v)
	if v then Notify("怪物透视已开启") else Notify("怪物透视已关闭") end
end})
ESPGroup:AddToggle("NPCESP",{ Text="透视NPC (绿色)", Default=false, Callback=function(v)
	setNpcEsp(v)
	if v then Notify("NPC透视已开启") else Notify("NPC透视已关闭") end
end})
ESPGroup:AddToggle("TeammateESP",{ Text="透视队友 (白色)", Default=false, Callback=function(v)
	teammateESPEnabled = v
	if v then drawTeammateESP() Notify("队友透视已开启") else clearTeammateESP() Notify("队友透视已关闭") end
end})
ESPGroup:AddToggle("ElevatorESP",{ Text="透视电梯 (绿色)", Default=false, Callback=function(v)
	elevatorESPEnabled = v
	if v then drawElevatorESP() Notify("电梯透视已开启") else clearElevatorESP() Notify("电梯透视已关闭") end
end})
ESPGroup:AddSlider("MinPrice",{ Text="物资最低价格过滤", Default=0, Min=0, Max=5000, Rounding=1, Suffix="$", Callback=function(v)
	itemConfig.MinPrice = v
end})

local SettingsGroup = Tabs.Settings:AddLeftGroupbox("全局设置")
SettingsGroup:AddButton({ Text="卸载脚本", Func=function() Library:Unload() end, DoubleClick=false })

if ThemeManager then
	ThemeManager:SetLibrary(Library)
	ThemeManager:SetFolder("DeadlyDelivery")
	ThemeManager:ApplyToTab(Tabs.Settings)
end
if SaveManager then
	SaveManager:SetLibrary(Library)
	SaveManager:IgnoreThemeSettings()
	SaveManager:SetFolder("DeadlyDelivery")
	SaveManager:BuildConfigSection(Tabs.Settings)
end

startESPWatcher()
Notify("亡命速递脚本已加载")
