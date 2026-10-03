-- This file has been deobfuscated Luraph using Hurricane https://discord.com/invite/AbeurBzKXe
local function safeLoad(url) local success, result = pcall(function() return loadstring(game:HttpGet(url))() end) if not success then warn("加载失败: " .. url) return nil end return result end local Library = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/黑曜石主库.ui") local ThemeManager = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/主题管理.ui") local SaveManager = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/配置管理.ui") if not Library then game:GetService("StarterGui"):SetCore("SendNotification", { Title = "错误", Text = "UI 库加载失败，请检查网络或脚本资源", Duration = 5, }) return end local Options = Library.Options local Toggles = Library.Toggles local Players = game:GetService("Players") local ReplicatedStorage = game:GetService("ReplicatedStorage") local RunService = game:GetService("RunService") local Workspace = game:GetService("Workspace") local player = Players.LocalPlayer local Window = Library:CreateWindow({ Title = "忍者传奇", Footer = "Aiove 制作", Icon = 131153193945220, NotifySide = "Right", ShowCustomCursor = true, }) Library:Notify({ Title = "忍者传奇", Description = "创作者：Aiove\nQQ：3999698324\n脚本已加载成功", Time = 5, }) local Tabs = { Notice = Window:AddTab("通知", "info"), Main = Window:AddTab("主要", "info"), Settings = Window:AddTab("设置", "settings"), } local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息") NoticeGroup:AddLabel('Aiove将持续更新此脚本') NoticeGroup:AddLabel('创作者：Aiove')

local function getCharacter() return player.Character or player.CharacterAdded:Wait() end
local function getRootPart() local char = getCharacter() return char and char:FindFirstChild("HumanoidRootPart") end

local FEATURE_STATE = { AutoTrainEnabled = false, AutoTrainConnection = nil, TrainCycleConnection = nil, CurrentTrainIndex = 0, TrainValues = {1, 2, 3, 4, 5, 6}, CycleDelay = 0.5, PacketDelay = 0.02 }

local function sendTrainPacket(value) local remote = ReplicatedStorage:FindFirstChild("shared") if remote then remote = remote:FindFirstChild("Remotes") if remote then remote = remote:FindFirstChild("RemoteEvent") if remote then local args = {"Train", value} pcall(function() remote:FireServer(unpack(args)) end) end end end end

local function startTrainCycle() if FEATURE_STATE.TrainCycleConnection then FEATURE_STATE.TrainCycleConnection:Disconnect() end FEATURE_STATE.TrainCycleConnection = RunService.Heartbeat:Connect(function() if not FEATURE_STATE.AutoTrainEnabled then return end for i, value in ipairs(FEATURE_STATE.TrainValues) do if not FEATURE_STATE.AutoTrainEnabled then break end task.spawn(function() sendTrainPacket(value) end) if i < #FEATURE_STATE.TrainValues then task.wait(FEATURE_STATE.PacketDelay) end end end) end

local function stopTrainCycle() if FEATURE_STATE.TrainCycleConnection then FEATURE_STATE.TrainCycleConnection:Disconnect() FEATURE_STATE.TrainCycleConnection = nil end FEATURE_STATE.CurrentTrainIndex = 0 end

local function startAutoTrain() if FEATURE_STATE.AutoTrainEnabled then stopTrainCycle() FEATURE_STATE.AutoTrainEnabled = false else FEATURE_STATE.AutoTrainEnabled = true startTrainCycle() end end

local _G = {}
_G.Sword = false
_G.Belt = false
_G.Rank = false
_G.Skill = false
_G.Shurikens = false
_G.Swing = false
_G.Sell = false
_G.Chi = false
_G.Boss = false
_G.EBoss = false
_G.ABoss = false
_G.SBoss = false
_G.AllBosses = false
_G.L = false
_G.GK = false
_G.BK = false
_G.TEgg = false
_G.Evolve = false
_G.Eternalise = false
_G.Immortalize = false
_G.Legend = false
_G.Elemental = false
_G.SBasic = false
_G.SAdvanced = false
_G.SRare = false
_G.SEpic = false
_G.SUnique = false
_G.SOmega = false
_G.SElite = false
_G.SInfinity = false
_G.S1 = false
_G.S2 = false
_G.S3 = false
_G.S4 = false
_G.S5 = false
_G.Fast = false
_G.Slow = false
_G.Invis = false
_G.JumpLoop = false
_G.Crystal = "水晶1"

spawn(function() while task.wait() do if _G.Swing then local ninjaEvent = player:FindFirstChild("ninjaEvent") if ninjaEvent then ninjaEvent:FireServer("swingKatana") end end end end)

spawn(function() while task.wait(0.1) do if _G.Sell then local hrp = getRootPart() if hrp then local sellCircle = Workspace:FindFirstChild("sellAreaCircles") and Workspace.sellAreaCircles:FindFirstChild("sellAreaCircle7") if sellCircle and sellCircle:FindFirstChild("circleInner") then sellCircle.circleInner.CFrame = hrp.CFrame task.wait(0.1) if Workspace:FindFirstChild("Part") then sellCircle.circleInner.CFrame = Workspace.Part.CFrame end end end end end end)

spawn(function() while task.wait(0.1) do if _G.Chi then local hrp = getRootPart() if hrp then hrp.CFrame = CFrame.new(299.758484, 30383.0957, -90.1542206) local ninjaEvent = player:FindFirstChild("ninjaEvent") if ninjaEvent then ninjaEvent:FireServer("swingKatana") end end end end end)

spawn(function() while task.wait(0.1) do if _G.Boss then local hrp = getRootPart() local boss = Workspace:FindFirstChild("bossFolder") and Workspace.bossFolder:FindFirstChild("RobotBoss") if hrp and boss and boss:FindFirstChild("HumanoidRootPart") then hrp.CFrame = boss.HumanoidRootPart.CFrame local ninjaEvent = player:FindFirstChild("ninjaEvent") if ninjaEvent then ninjaEvent:FireServer("swingKatana") end end end end end)

spawn(function() while task.wait(0.1) do if _G.EBoss then local hrp = getRootPart() local boss = Workspace:FindFirstChild("bossFolder") and Workspace.bossFolder:FindFirstChild("EternalBoss") if hrp and boss and boss:FindFirstChild("HumanoidRootPart") then hrp.CFrame = boss.HumanoidRootPart.CFrame local ninjaEvent = player:FindFirstChild("ninjaEvent") if ninjaEvent then ninjaEvent:FireServer("swingKatana") end end end end end)

spawn(function() while task.wait(0.1) do if _G.ABoss then local hrp = getRootPart() local boss = Workspace:FindFirstChild("bossFolder") and Workspace.bossFolder:FindFirstChild("AncientMagmaBoss") if hrp and boss and boss:FindFirstChild("HumanoidRootPart") then hrp.CFrame = boss.HumanoidRootPart.CFrame local ninjaEvent = player:FindFirstChild("ninjaEvent") if ninjaEvent then ninjaEvent:FireServer("swingKatana") end end end end end)

spawn(function() while task.wait(0.1) do if _G.SBoss then local hrp = getRootPart() local boss = Workspace:FindFirstChild("bossFolder") and Workspace.bossFolder:FindFirstChild("SantaBoss") if hrp and boss and boss:FindFirstChild("HumanoidRootPart") then hrp.CFrame = boss.HumanoidRootPart.CFrame local ninjaEvent = player:FindFirstChild("ninjaEvent") if ninjaEvent then ninjaEvent:FireServer("swingKatana") end end end end end)

spawn(function() while task.wait(0.1) do if _G.AllBosses then local hrp = getRootPart() local bossFolder = Workspace:FindFirstChild("bossFolder") if hrp and bossFolder then for _, boss in ipairs(bossFolder:GetChildren()) do if boss:FindFirstChild("HumanoidRootPart") then hrp.CFrame = boss.HumanoidRootPart.CFrame local ninjaEvent = player:FindFirstChild("ninjaEvent") if ninjaEvent then ninjaEvent:FireServer("swingKatana") end task.wait(0.5) end end end end end end)

spawn(function() while task.wait(0.1) do if _G.L then local hrp = getRootPart() if hrp then for _, v in ipairs(Workspace:GetDescendants()) do if v.Name == "Hoops" or v:FindFirstChild("touchPart") then local touch = v:FindFirstChild("touchPart") or v if touch:IsA("BasePart") then touch.CFrame = hrp.CFrame end end end end end end end)

spawn(function() while task.wait(0.1) do if _G.TEgg then local remote = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("openCrystalRemote") if remote then pcall(function() remote:InvokeServer("openCrystal", _G.Crystal) end) end end end end)

spawn(function() while task.wait(0.5) do if _G.Rank then local remote = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("buyRank") if remote then pcall(function() remote:FireServer() end) end end end end)

spawn(function() while task.wait(0.5) do if _G.Sword then local remote = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("buySword") if remote then pcall(function() remote:FireServer() end) end end end end)

spawn(function() while task.wait(0.5) do if _G.Belt then local remote = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("buyBelt") if remote then pcall(function() remote:FireServer() end) end end end end)

spawn(function() while task.wait(0.5) do if _G.Skill then local remote = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("buySkill") if remote then pcall(function() remote:FireServer() end) end end end end)

spawn(function() while task.wait(0.5) do if _G.Shurikens then local remote = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("buyShuriken") if remote then pcall(function() remote:FireServer() end) end end end end)

spawn(function() while task.wait(2) do if _G.GK then local success, result = pcall(function() loadstring(game:HttpGet(('https://pastebin.com/raw/AaqHqPyw'), true))() end) if not success then warn("善良业报加载失败，尝试备用链接") pcall(function() loadstring(game:HttpGet(('https://raw.githubusercontent.com/User/Scripts/main/goodkarma.lua'), true))() end) end end if _G.BK then local success, result = pcall(function() loadstring(game:HttpGet(('https://pastebin.com/raw/wEEB3nQt'), true))() end) if not success then warn("邪恶业报加载失败，尝试备用链接") pcall(function() loadstring(game:HttpGet(('https://raw.githubusercontent.com/User/Scripts/main/badkarma.lua'), true))() end) end end end end)

spawn(function() while task.wait(0.1) do if _G.Invis then local ninjaEvent = player:FindFirstChild("ninjaEvent") if ninjaEvent then ninjaEvent:FireServer("goInvisible") end end end end)

RunService.Heartbeat:Connect(function() local hrp = getRootPart() if not hrp then return end if _G.JumpLoop then player.multiJumpCount.Value = "50" end end)

local TrainGroup = Tabs.Main:AddLeftGroupbox("自动训练")
TrainGroup:AddToggle("AutoTrain", { Text = "自动训练", Default = false, Callback = function(value) FEATURE_STATE.AutoTrainEnabled = value if value then startTrainCycle() else stopTrainCycle() end end })

local MoneyGroup = Tabs.Main:AddLeftGroupbox("自动刷钱")
MoneyGroup:AddToggle("Swing", { Text = "自动挥刀", Default = false, Callback = function(value) _G.Swing = value end })
MoneyGroup:AddToggle("Sell", { Text = "自动出售", Default = false, Callback = function(value) _G.Sell = value end })

local ChiGroup = Tabs.Main:AddLeftGroupbox("自动芝加哥")
ChiGroup:AddToggle("Chi", { Text = "自动芝加哥", Default = false, Callback = function(value) _G.Chi = value end })

local BossGroup = Tabs.Main:AddLeftGroupbox("自动Boss")
BossGroup:AddToggle("Boss", { Text = "自动机器人Boss", Default = false, Callback = function(value) _G.Boss = value end })
BossGroup:AddToggle("EBoss", { Text = "自动不朽Boss", Default = false, Callback = function(value) _G.EBoss = value end })
BossGroup:AddToggle("ABoss", { Text = "自动古代Boss", Default = false, Callback = function(value) _G.ABoss = value end })
BossGroup:AddToggle("SBoss", { Text = "自动圣诞老人Boss", Default = false, Callback = function(value) _G.SBoss = value end })
BossGroup:AddToggle("AllBosses", { Text = "自动全部Boss", Default = false, Callback = function(value) _G.AllBosses = value end })

local BuyGroup = Tabs.Main:AddRightGroupbox("自动购买")
BuyGroup:AddToggle("Rank", { Text = "自动买等级", Default = false, Callback = function(value) _G.Rank = value end })
BuyGroup:AddToggle("Sword", { Text = "自动买剑", Default = false, Callback = function(value) _G.Sword = value end })
BuyGroup:AddToggle("Belt", { Text = "自动买腰带", Default = false, Callback = function(value) _G.Belt = value end })
BuyGroup:AddToggle("Skill", { Text = "自动买技能", Default = false, Callback = function(value) _G.Skill = value end })
BuyGroup:AddToggle("Shurikens", { Text = "自动买飞镖", Default = false, Callback = function(value) _G.Shurikens = value end })

local PetGroup = Tabs.Main:AddRightGroupbox("宠物功能")
PetGroup:AddToggle("TEgg", { Text = "打开蛋", Default = false, Callback = function(value) _G.TEgg = value end })
PetGroup:AddToggle("L", { Text = "自动宠物升级", Default = false, Callback = function(value) _G.L = value end })
PetGroup:AddToggle("Evolve", { Text = "自动进化", Default = false, Callback = function(value) _G.Evolve = value end })
PetGroup:AddToggle("Eternalise", { Text = "自动永恒", Default = false, Callback = function(value) _G.Eternalise = value end })
PetGroup:AddToggle("Immortalize", { Text = "自动永生", Default = false, Callback = function(value) _G.Immortalize = value end })
PetGroup:AddToggle("Legend", { Text = "自动传奇", Default = false, Callback = function(value) _G.Legend = value end })
PetGroup:AddToggle("Elemental", { Text = "自动元素", Default = false, Callback = function(value) _G.Elemental = value end })

local SellPetGroup = Tabs.Main:AddRightGroupbox("出售宠物")
SellPetGroup:AddToggle("SBasic", { Text = "出售基本", Default = false, Callback = function(value) _G.SBasic = value end })
SellPetGroup:AddToggle("SAdvanced", { Text = "出售高级", Default = false, Callback = function(value) _G.SAdvanced = value end })
SellPetGroup:AddToggle("SRare", { Text = "出售稀有", Default = false, Callback = function(value) _G.SRare = value end })
SellPetGroup:AddToggle("SEpic", { Text = "出售史诗", Default = false, Callback = function(value) _G.SEpic = value end })
SellPetGroup:AddToggle("SUnique", { Text = "出售独特", Default = false, Callback = function(value) _G.SUnique = value end })
SellPetGroup:AddToggle("SOmega", { Text = "出售欧米茄", Default = false, Callback = function(value) _G.SOmega = value end })
SellPetGroup:AddToggle("SElite", { Text = "出售精英", Default = false, Callback = function(value) _G.SElite = value end })
SellPetGroup:AddToggle("SInfinity", { Text = "出售无限", Default = false, Callback = function(value) _G.SInfinity = value end })

local SpecialPetGroup = Tabs.Main:AddRightGroupbox("特殊宠物出售")
SpecialPetGroup:AddToggle("S1", { Text = "出售冬季小猫", Default = false, Callback = function(value) _G.S1 = value end })
SpecialPetGroup:AddToggle("S2", { Text = "出售北极熊", Default = false, Callback = function(value) _G.S2 = value end })
SpecialPetGroup:AddToggle("S3", { Text = "出售驯鹿", Default = false, Callback = function(value) _G.S3 = value end })
SpecialPetGroup:AddToggle("S4", { Text = "出售黑企鹅", Default = false, Callback = function(value) _G.S4 = value end })
SpecialPetGroup:AddToggle("S5", { Text = "出售雪橇高手", Default = false, Callback = function(value) _G.S5 = value end })

local KarmaGroup = Tabs.Main:AddLeftGroupbox("自动业报")
KarmaGroup:AddToggle("GK", { Text = "自动善良业报", Default = false, Callback = function(value) _G.GK = value end })
KarmaGroup:AddToggle("BK", { Text = "自动邪恶业报", Default = false, Callback = function(value) _G.BK = value end })

local MiscGroup = Tabs.Main:AddLeftGroupbox("其他功能")
MiscGroup:AddToggle("Fast", { Text = "快速手里剑", Default = false, Callback = function(value) _G.Fast = value end })
MiscGroup:AddToggle("Slow", { Text = "慢速手里剑", Default = false, Callback = function(value) _G.Slow = value end })
MiscGroup:AddToggle("Invis", { Text = "隐身", Default = false, Callback = function(value) _G.Invis = value end })
MiscGroup:AddToggle("JumpLoop", { Text = "最高跳", Default = false, Callback = function(value) _G.JumpLoop = value end })

MiscGroup:AddButton("收集所有宝箱", function() local hrp = getRootPart() if not hrp then return end local chests = { "mythicalChest", "goldenChest", "enchantedChest", "magmaChest", "legendsChest", "eternalChest", "saharaChest", "thunderChest", "ancientChest", "midnightShadowChest", "groupRewardsCircle", "Daily Chest", "wonderChest" } for _, chest in ipairs(chests) do local obj = Workspace:FindFirstChild(chest) if obj and obj:FindFirstChild("circleInner") then obj.circleInner.CFrame = hrp.CFrame task.wait(3.5) if Workspace:FindFirstChild("Part") then obj.circleInner.CFrame = Workspace.Part.CFrame end end end end)

MiscGroup:AddButton("收集光明宝箱", function() local hrp = getRootPart() if hrp and Workspace:FindFirstChild("lightKarmaChest") then Workspace.lightKarmaChest.circleInner.CFrame = hrp.CFrame task.wait(5) if Workspace:FindFirstChild("Part") then Workspace.lightKarmaChest.circleInner.CFrame = Workspace.Part.CFrame end end end)

MiscGroup:AddButton("收集黑暗宝箱", function() local hrp = getRootPart() if hrp and Workspace:FindFirstChild("evilKarmaChest") then Workspace.evilKarmaChest.circleInner.CFrame = hrp.CFrame task.wait(5) if Workspace:FindFirstChild("Part") then Workspace.evilKarmaChest.circleInner.CFrame = Workspace.Part.CFrame end end end)

MiscGroup:AddButton("解锁岛屿", function() for _, v in ipairs(Workspace:FindFirstChild("islandUnlockParts"):GetChildren()) do if v and v:FindFirstChild("islandSignPart") then local hrp = getRootPart() if hrp then hrp.CFrame = v.islandSignPart.CFrame task.wait(0.5) end end end end)

MiscGroup:AddButton("隐藏名称", function() local char = getCharacter() if char and char.Head and char.Head:FindFirstChild("nameGui") then char.Head.nameGui:Destroy() end end)

MiscGroup:AddButton("切换弹出窗口", function() local gui = player.PlayerGui if gui then if gui:FindFirstChild("statEffectsGui") then gui.statEffectsGui.Enabled = not gui.statEffectsGui.Enabled end if gui:FindFirstChild("hoopGui") then gui.hoopGui.Enabled = not gui.hoopGui.Enabled end end end)

local TeleportGroup = Tabs.Main:AddLeftGroupbox("传送")
TeleportGroup:AddButton("商店", function() local hrp = getRootPart() if hrp and Workspace:FindFirstChild("shopAreaCircles") then local circle = Workspace.shopAreaCircles:FindFirstChild("shopAreaCircle11") if circle and circle:FindFirstChild("circleInner") then hrp.CFrame = circle.circleInner.CFrame end end end)
TeleportGroup:AddButton("技能商店", function() local hrp = getRootPart() if hrp and Workspace:FindFirstChild("skillAreaCircles") then local circle = Workspace.skillAreaCircles:FindFirstChild("skillsAreaCircle11") if circle and circle:FindFirstChild("circleInner") then hrp.CFrame = circle.circleInner.CFrame end end end)
TeleportGroup:AddButton("光明技能", function() local hrp = getRootPart() if hrp then hrp.CFrame = CFrame.new(-116.49514, 3.24800324, 0.0838552266) end end)
TeleportGroup:AddButton("黑暗技能", function() local hrp = getRootPart() if hrp then hrp.CFrame = CFrame.new(-116.549767, 3.24800324, 58.087841) end end)
TeleportGroup:AddButton("KOTH", function() local hrp = getRootPart() if hrp and Workspace:FindFirstChild("kingOfTheHillPart") then hrp.CFrame = Workspace.kingOfTheHillPart.CFrame end end)
TeleportGroup:AddButton("神秘水域(善)", function() local hrp = getRootPart() if hrp then hrp.CFrame = CFrame.new(347.74881, 8824.53809, 114.271019) end end)
TeleportGroup:AddButton("传奇之剑(善)", function() local hrp = getRootPart() if hrp then hrp.CFrame = CFrame.new(1834.15967, 38.704483, -141.375641) end end)
TeleportGroup:AddButton("元素龙卷(善)", function() local hrp = getRootPart() if hrp then hrp.CFrame = CFrame.new(299.758484, 30383.0957, -90.1542206) end end)
TeleportGroup:AddButton("岩浆坑(恶)", function() local hrp = getRootPart() if hrp then hrp.CFrame = CFrame.new(-116.631485, 12952.5381, 271.14624) end end)
TeleportGroup:AddButton("龙卷风(恶)", function() local hrp = getRootPart() if hrp then hrp.CFrame = CFrame.new(325.641174, 16872.0938, -9.9906435) end end)
TeleportGroup:AddButton("远古之剑(恶)", function() local hrp = getRootPart() if hrp then hrp.CFrame = CFrame.new(648.365662, 38.704483, 2409.72266) end end)

local IslandTeleportGroup = Tabs.Main:AddLeftGroupbox("岛屿传送")
for _, v in ipairs(Workspace:FindFirstChild("islandUnlockParts"):GetChildren()) do if v then IslandTeleportGroup:AddButton(v.Name, function() local hrp = getRootPart() if hrp and v:FindFirstChild("islandSignPart") then hrp.CFrame = v.islandSignPart.CFrame end end) end end

local UnloadGroup = Tabs.Settings:AddLeftGroupbox("脚本管理")
UnloadGroup:AddButton("卸载脚本", function() Library:Unload() end)
if ThemeManager then ThemeManager:SetLibrary(Library) ThemeManager:SetFolder("MyScriptTheme") ThemeManager:ApplyToTab(Tabs.Settings) end
if SaveManager then SaveManager:SetLibrary(Library) SaveManager:IgnoreThemeSettings() SaveManager:SetFolder("MyScriptConfig") SaveManager:BuildConfigSection(Tabs.Settings) end
