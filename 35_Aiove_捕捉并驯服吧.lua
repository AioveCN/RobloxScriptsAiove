-- This file has been deobfuscated Luraph using Hurricane https://discord.com/invite/AbeurBzKXe
local function safeLoad(url) local success, result = pcall(function() return loadstring(game:HttpGet(url))() end) if not success then warn("加载失败: " .. url) return nil end return result end local Library = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/黑曜石主库.ui") local ThemeManager = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/主题管理.ui") local SaveManager = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/配置管理.ui") if not Library then game:GetService("StarterGui"):SetCore("SendNotification", { Title = "错误", Text = "UI 库加载失败，请检查网络或脚本资源", Duration = 5, }) return end local Options = Library.Options local Toggles = Library.Toggles local Players = game:GetService("Players") local ReplicatedStorage = game:GetService("ReplicatedStorage") local Workspace = game:GetService("Workspace") local RunService = game:GetService("RunService") local HttpService = game:GetService("HttpService") local player = Players.LocalPlayer local PlayerGui = player:WaitForChild("PlayerGui") local Window = Library:CreateWindow({ Title = "捕捉并驯服", Footer = "Aiove 制作", Icon = 131153193945220, NotifySide = "Right", ShowCustomCursor = true, }) Library:Notify({ Title = "捕捉并驯服", Description = "创作者：Aiove\nQQ：3999698324\n脚本已加载成功", Time = 5, }) local Tabs = { Notice = Window:AddTab("通知", "info"), Main = Window:AddTab("主要", "info"), Settings = Window:AddTab("设置", "settings"), } local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息") NoticeGroup:AddLabel('Aiove将持续更新此脚本') NoticeGroup:AddLabel('创作者：Aiove') NoticeGroup:AddLabel('周大头 定制') local UnloadGroup = Tabs.Settings:AddLeftGroupbox("脚本管理") UnloadGroup:AddButton("卸载脚本", function() Library:Unload() end) if ThemeManager then ThemeManager:SetLibrary(Library) ThemeManager:SetFolder("MyScriptTheme") ThemeManager:ApplyToTab(Tabs.Settings) end if SaveManager then SaveManager:SetLibrary(Library) SaveManager:IgnoreThemeSettings() SaveManager:SetFolder("MyScriptConfig") SaveManager:BuildConfigSection(Tabs.Settings) end

local RarityColors = {
	common = Color3.fromRGB(0, 255, 0),
	uncommon = Color3.fromRGB(0, 170, 255),
	rare = Color3.fromRGB(170, 0, 255),
	epic = Color3.fromRGB(255, 200, 0),
	legendary = Color3.fromRGB(255, 140, 0),
	mythic = Color3.fromRGB(255, 0, 0),
	divine = Color3.fromRGB(255, 0, 0),
	secret = Color3.fromRGB(255, 0, 0)
}

local RarityRanks = {
	common = 2,
	uncommon = 3,
	rare = 4,
	epic = 5,
	legendary = 6,
	mythic = 7,
	divine = 7,
	secret = 7
}

local RarityChinese = {
	common = "普通",
	uncommon = "优秀",
	rare = "稀有",
	epic = "史诗",
	legendary = "传说",
	mythic = "神话",
	divine = "神圣",
	secret = "神秘"
}

local RarityFilterNames = {
	"白色(全部)",
	"绿色",
	"蓝色",
	"紫色",
	"金色",
	"橙色",
	"红色"
}

local DefaultColor = Color3.fromRGB(255, 255, 255)

local translatedTexts = {}
local petMap = {}
local selectedPetText = nil
local espEnabled = false
local tracked = {}
local watchedFolders = {}
local connections = {}
local heartbeatConn = nil
local heartbeatAcc = 0
local filterLevel = 0
local filterRarity = 1
local maxLevelSeen = 100

local function translateText(text)
	if not text or text == "" or #text < 2 then
		return nil
	end
	if translatedTexts[text] then
		return translatedTexts[text]
	end
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

local function isEnglish(text)
	if not text or text == "" then
		return false
	end
	local englishCount = 0
	local totalCount = 0
	for char in string.gmatch(text, ".") do
		local byte = string.byte(char)
		if byte then
			totalCount = totalCount + 1
			if (byte >= 65 and byte <= 90) or (byte >= 97 and byte <= 122) then
				englishCount = englishCount + 1
			end
		end
	end
	if totalCount == 0 then
		return false
	end
	return (englishCount / totalCount) > 0.5
end

local function getRarityColor(rarity)
	if not rarity then
		return DefaultColor
	end
	local key = string.lower(tostring(rarity))
	for name, color in pairs(RarityColors) do
		if string.find(key, name) then
			return color
		end
	end
	return DefaultColor
end

local function getRarityRank(rarity)
	if not rarity then
		return 2
	end
	local key = string.lower(tostring(rarity))
	for name, rank in pairs(RarityRanks) do
		if string.find(key, name) then
			return rank
		end
	end
	return 2
end

local function getRarityChinese(rarity)
	if not rarity then
		return nil
	end
	local key = string.lower(tostring(rarity))
	for name, cn in pairs(RarityChinese) do
		if string.find(key, name) then
			return cn
		end
	end
	return tostring(rarity)
end

local function getPetInfo(model)
	local info = {}
	local name = model:GetAttribute("Name")
	if name and tostring(name) ~= "" then
		info.Name = tostring(name)
	end
	local level = model:GetAttribute("Level")
	if level and tostring(level) ~= "" then
		info.Level = tostring(level)
	end
	local rarity = model:GetAttribute("Rarity")
	if rarity and tostring(rarity) ~= "" then
		info.Rarity = tostring(rarity)
	end
	if not info.Rarity then
		local folder = PlayerGui:FindFirstChild("PetInfoBillboardUIs")
		local bb = folder and folder:FindFirstChild(model.Name)
		local frame = bb and bb:FindFirstChild("Frame")
		if frame then
			local rarityLabel = frame:FindFirstChild("Rarity")
			if rarityLabel and rarityLabel:IsA("TextLabel") then
				if rarityLabel.Text ~= "" then
					info.Rarity = rarityLabel.Text
				else
					for _, c in ipairs(rarityLabel:GetChildren()) do
						if c:IsA("UIGradient") then
							info.Rarity = c.Name
							break
						end
					end
				end
			end
		end
	end
	return info
end

local function buildESPText(model)
	local data = tracked[model]
	if not data then
		return ""
	end
	local info = data.Info
	local lines = {}
	local nameLine = info.Name or "宠物"
	if info.Rarity then
		nameLine = nameLine .. " [" .. getRarityChinese(info.Rarity) .. "]"
	end
	table.insert(lines, nameLine)
	if info.Level then
		table.insert(lines, "等级: " .. info.Level)
	end
	table.insert(lines, "距离: " .. data.Distance .. "m")
	return table.concat(lines, "\n")
end

local function petPassesFilter(info)
	local lvl = tonumber(info.Level) or 0
	if filterLevel > 0 and lvl < filterLevel then
		return false
	end
	if filterRarity > 1 then
		local rank = getRarityRank(info.Rarity)
		if rank < filterRarity then
			return false
		end
	end
	return true
end

local function createVisuals(model)
	local data = tracked[model]
	if not data or data.Visible then
		return
	end
	local color = getRarityColor(data.Info.Rarity)
	local highlight = Instance.new("Highlight")
	highlight.Name = "PetESPHighlight"
	highlight.FillColor = color
	highlight.OutlineColor = color
	highlight.FillTransparency = 0.55
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Adornee = model
	highlight.Parent = model
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "PetESPBillboard"
	billboard.Size = UDim2.new(0, 220, 0, 60)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 3.5, 0)
	billboard.AlwaysOnTop = true
	billboard.Adornee = model
	billboard.Parent = model
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = color
	label.TextStrokeTransparency = 0.3
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.Text = buildESPText(model)
	label.Parent = billboard
	data.Highlight = highlight
	data.Billboard = billboard
	data.Label = label
	data.Visible = true
end

local function destroyVisuals(model)
	local data = tracked[model]
	if not data or not data.Visible then
		return
	end
	if data.Highlight then
		data.Highlight:Destroy()
	end
	if data.Billboard then
		data.Billboard:Destroy()
	end
	data.Highlight = nil
	data.Billboard = nil
	data.Label = nil
	data.Visible = false
end

local function reapplyFilters()
	for model, data in pairs(tracked) do
		if petPassesFilter(data.Info) then
			if not data.Visible then
				createVisuals(model)
			end
		else
			if data.Visible then
				destroyVisuals(model)
			end
		end
	end
end

local function addESP(model)
	if tracked[model] then
		return
	end
	if not model:IsA("Model") then
		return
	end
	local info = getPetInfo(model)
	local lvl = tonumber(info.Level)
	if lvl and lvl > maxLevelSeen then
		maxLevelSeen = lvl
		pcall(function()
			Options.LevelFilter:SetMax(maxLevelSeen)
		end)
	end
	tracked[model] = {
		Info = info,
		Distance = "?",
		Visible = false
	}
	if info.Name and isEnglish(info.Name) then
		task.spawn(function()
			local translated = translateText(info.Name)
			if translated and translated ~= info.Name and tracked[model] then
				tracked[model].Info.Name = translated
			end
		end)
	end
	if petPassesFilter(info) then
		createVisuals(model)
	end
	if not info.Name or not info.Rarity then
		task.delay(1, function()
			local data = tracked[model]
			if not data then
				return
			end
			local newInfo = getPetInfo(model)
			if not newInfo.Name and data.Info.Name then
				newInfo.Name = data.Info.Name
			end
			data.Info = newInfo
			if data.Visible then
				local color = getRarityColor(newInfo.Rarity)
				data.Highlight.FillColor = color
				data.Highlight.OutlineColor = color
				data.Label.TextColor3 = color
			else
				if petPassesFilter(newInfo) then
					createVisuals(model)
				end
			end
		end)
	end
end

local function removeESP(model)
	local data = tracked[model]
	if not data then
		return
	end
	destroyVisuals(model)
	tracked[model] = nil
end

local function isPetModel(obj)
	return obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") ~= nil
end

local function onFolderChild(obj)
	if isPetModel(obj) then
		addESP(obj)
	elseif obj:IsA("Folder") then
		watchFolder(obj)
	end
end

function watchFolder(folder)
	if watchedFolders[folder] then
		return
	end
	watchedFolders[folder] = true
	for _, child in ipairs(folder:GetChildren()) do
		onFolderChild(child)
	end
	table.insert(connections, folder.ChildAdded:Connect(onFolderChild))
	table.insert(connections, folder.ChildRemoved:Connect(function(obj)
		if tracked[obj] then
			removeESP(obj)
		end
	end))
end

local function scanContainers()
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("Folder") and string.find(string.lower(obj.Name), "pets") then
			watchFolder(obj)
		end
	end
end

local function startHeartbeat()
	if heartbeatConn then
		return
	end
	heartbeatConn = RunService.Heartbeat:Connect(function(dt)
		heartbeatAcc = heartbeatAcc + dt
		if heartbeatAcc < 0.15 then
			return
		end
		heartbeatAcc = 0
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then
			return
		end
		local myPos = hrp.Position
		for model, data in pairs(tracked) do
			if model.Parent then
				if data.Visible then
					local ok, pivot = pcall(function()
						return model:GetPivot()
					end)
					if ok and pivot then
						data.Distance = tostring(math.floor((pivot.Position - myPos).Magnitude))
						data.Label.Text = buildESPText(model)
					end
				end
			else
				removeESP(model)
			end
		end
	end)
end

local function stopAllESP()
	if heartbeatConn then
		heartbeatConn:Disconnect()
		heartbeatConn = nil
	end
	for _, conn in ipairs(connections) do
		conn:Disconnect()
	end
	table.clear(connections)
	table.clear(watchedFolders)
	for model in pairs(tracked) do
		removeESP(model)
	end
end

Workspace.DescendantAdded:Connect(function(obj)
	if espEnabled and obj:IsA("Folder") and string.find(string.lower(obj.Name), "pets") then
		watchFolder(obj)
	end
end)

local function scanPets()
	local pets = {}
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("Folder") and string.find(string.lower(obj.Name), "pets") then
			for _, child in ipairs(obj:GetChildren()) do
				if child:IsA("Model") and child:FindFirstChild("HumanoidRootPart") then
					table.insert(pets, child)
				elseif child:IsA("Folder") then
					for _, sub in ipairs(child:GetChildren()) do
						if sub:IsA("Model") and sub:FindFirstChild("HumanoidRootPart") then
							table.insert(pets, sub)
						end
					end
				end
			end
		end
	end
	return pets
end

local function buildDropdownValues(pets)
	petMap = {}
	local values = {}
	local nameCount = {}
	for _, model in ipairs(pets) do
		local engName = model:GetAttribute("Name") or model.Name
		local disp = translatedTexts[engName] or engName
		local level = model:GetAttribute("Level")
		local text = disp
		if level then
			text = text .. " Lv." .. tostring(level)
		end
		nameCount[text] = (nameCount[text] or 0) + 1
		if nameCount[text] > 1 then
			text = text .. " #" .. tostring(nameCount[text])
		end
		petMap[text] = model
		table.insert(values, text)
	end
	table.sort(values)
	Options.PetDropdown:SetValues(values)
end

local function refreshPetList()
	local pets = scanPets()
	if #pets == 0 then
		Library:Notify({ Title = "传送宠物", Description = "没有找到任何宠物", Time = 3 })
		return
	end
	for _, model in ipairs(pets) do
		local engName = model:GetAttribute("Name")
		if engName and isEnglish(engName) and not translatedTexts[engName] then
			task.spawn(function()
				translateText(engName)
			end)
		end
		local lvl = tonumber(model:GetAttribute("Level"))
		if lvl and lvl > maxLevelSeen then
			maxLevelSeen = lvl
		end
	end
	pcall(function()
		Options.LevelFilter:SetMax(maxLevelSeen)
	end)
	buildDropdownValues(pets)
	task.delay(2.5, function()
		local currentPets = {}
		for text, model in pairs(petMap) do
			if model.Parent then
				table.insert(currentPets, model)
			end
		end
		if #currentPets > 0 then
			buildDropdownValues(currentPets)
		end
	end)
	Library:Notify({ Title = "传送宠物", Description = "已刷新，共找到 " .. tostring(#pets) .. " 只宠物", Time = 3 })
end

local ESPGroup = Tabs.Main:AddLeftGroupbox("宠物透视")

ESPGroup:AddToggle("PetESP", {
	Text = "启用宠物透视",
	Default = false,
	Callback = function(value)
		espEnabled = value
		if espEnabled then
			scanContainers()
			startHeartbeat()
			Library:Notify({ Title = "宠物透视", Description = "透视已开启", Time = 3 })
		else
			stopAllESP()
			Library:Notify({ Title = "宠物透视", Description = "透视已关闭", Time = 3 })
		end
	end,
})

ESPGroup:AddSlider("LevelFilter", {
	Text = "等级过滤",
	Default = 0,
	Min = 0,
	Max = 100,
	Rounding = 0,
	Callback = function(value)
		filterLevel = value
		if espEnabled then
			reapplyFilters()
		end
	end,
})

ESPGroup:AddInput("LevelFilterInput", {
	Text = "精确输入等级",
	Default = "",
	NumericOnly = true,
	Placeholder = "输入等级数字",
	Callback = function(value)
		local n = tonumber(value)
		if n then
			n = math.floor(n)
			if n < 0 then
				n = 0
			end
			if n > maxLevelSeen then
				n = maxLevelSeen
			end
			Options.LevelFilter:SetValue(n)
		end
	end,
})

ESPGroup:AddSlider("RarityFilter", {
	Text = "品质过滤",
	Default = 1,
	Min = 1,
	Max = 7,
	Rounding = 0,
	Callback = function(value)
		filterRarity = value
		if RarityFilterLabel then
			RarityFilterLabel:SetText("当前品质: " .. RarityFilterNames[value])
		end
		if espEnabled then
			reapplyFilters()
		end
	end,
})

RarityFilterLabel = ESPGroup:AddLabel("当前品质: 白色(全部)")

local TeleportGroup = Tabs.Main:AddRightGroupbox("传送宠物")

TeleportGroup:AddDropdown("PetDropdown", {
	Text = "选定宠物",
	Values = {},
	Default = nil,
	Callback = function(value)
		selectedPetText = value
	end,
})

TeleportGroup:AddButton("刷新宠物列表", function()
	refreshPetList()
end)

TeleportGroup:AddButton("一键传送到选定宠物", function()
	if not selectedPetText then
		Library:Notify({ Title = "传送宠物", Description = "请先在选定框里选择一只宠物", Time = 3 })
		return
	end
	local model = petMap[selectedPetText]
	if not model or not model.Parent then
		Library:Notify({ Title = "传送宠物", Description = "该宠物已消失，请刷新宠物列表", Time = 3 })
		return
	end
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		Library:Notify({ Title = "传送宠物", Description = "角色未加载，无法传送", Time = 3 })
		return
	end
	local ok, pivot = pcall(function()
		return model:GetPivot()
	end)
	if ok and pivot then
		char:PivotTo(CFrame.new(pivot.Position + Vector3.new(0, 3, 4)))
		Library:Notify({ Title = "传送宠物", Description = "已传送到: " .. selectedPetText, Time = 3 })
	else
		Library:Notify({ Title = "传送宠物", Description = "传送失败，请刷新后重试", Time = 3 })
	end
end)

task.delay(3, function()
	refreshPetList()
end)
