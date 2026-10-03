-- Aiove HUB：真正稳定 UI 版
-- 仅恢复 UI；圣奥里与通用功能均为关闭状态。
-- 01~65 仍保持独立源码加载。
-- 未加入游戏检测、自动关闭或反检测逻辑。

local WindUI
do
    local ok, result = pcall(function()
        local src = game:HttpGet("https://raw.githubusercontent.com/LumiereSeren/UI/refs/heads/main/cyyWind.lua")
        local loader = loadstring(src)
        if type(loader) ~= "function" then error("WindUI loader 无效") end
        return loader()
    end)
    if not ok or not result then
        warn("[Aiove] WindUI 加载失败: " .. tostring(result))
        return
    end
    WindUI = result
end

local mainWindow = WindUI:CreateWindow({
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
    ScrollBarEnabled = true
})

local function disabledToggle(tab, title)
    tab:Toggle({Title = title, Value = false, Callback = function(_) end})
end

local function disabledSlider(tab, title, minValue, maxValue, defaultValue)
    tab:Slider({
        Title = title,
        Value = {Min = minValue, Max = maxValue, Default = defaultValue},
        Callback = function(_) end
    })
end

-- 信息
local InfoTab = mainWindow:Tab({Title = "信息", Icon = "info"})
local Info = InfoTab:Section({Title = "信息", Opened = true})
Info:Paragraph({Title = "欢迎您的使用 Aiove HUB!", Desc = "本脚本仅供学习交流，请勿用于非法用途。"})
Info:Paragraph({Title = "QQ反馈：3593722551", Desc = "如有问题可以通过 QQ 反馈。"})
Info:Paragraph({Title = "当前服务器", Desc = "PlaceId：" .. tostring(game.PlaceId)})

-- 通用：全部关闭
local GeneralTab = mainWindow:Tab({Title = "通用", Icon = "sliders-horizontal"})
local General = GeneralTab:Section({Title = "通用功能", Opened = true})
General:Paragraph({Title = "通用功能", Desc = "当前版本仅保留 UI，功能全部关闭。"})
disabledToggle(General, "无限体力")
disabledToggle(General, "无限饥饿")
disabledToggle(General, "无限跳跃")
disabledToggle(General, "飞行")
disabledToggle(General, "无碰撞")
disabledToggle(General, "防挂机")
disabledSlider(General, "移动速度", 16, 300, 16)
disabledSlider(General, "跳跃高度", 50, 400, 50)

-- 圣奥里：只恢复界面，不执行原功能
local SaintTab = mainWindow:Tab({Title = "圣奥里", Icon = "map"})
local SaintSection = SaintTab:Section({Title = "圣奥里功能", Opened = true})
SaintSection:Paragraph({Title = "Aiove · 圣奥里", Desc = "UI 已恢复；所有功能当前关闭。"})

local function saintGroup(title)
    SaintSection:Paragraph({Title = title, Desc = "此分组功能当前全部关闭。"})
end

saintGroup("主要功能")
for _, n in ipairs({"无限体力","无限饥饿","战斗拦截","幽灵模式","防倒地","防摔伤"}) do disabledToggle(SaintSection,n) end

saintGroup("金钱")
for _, n in ipairs({"自动赚钱","自动任务","自动破解","高尔夫循环"}) do disabledToggle(SaintSection,n) end

saintGroup("Combat")
for _, n in ipairs({"无限弹药","快速射击","范围攻击"}) do disabledToggle(SaintSection,n) end
disabledSlider(SaintSection,"攻击范围",10,500,150)

saintGroup("Aim")
for _, n in ipairs({"自瞄","显示 FOV","预测","墙壁检测"}) do disabledToggle(SaintSection,n) end
disabledSlider(SaintSection,"FOV圈大小",1,500,50)

saintGroup("Ragebot")
for _, n in ipairs({"Ragebot","职业检测","墙壁检测","活体检测","锁定警察","锁定平民"}) do disabledToggle(SaintSection,n) end
disabledSlider(SaintSection,"攻击距离",10,500,150)

saintGroup("范围")
for _, n in ipairs({"开启/关闭范围","NPC范围","队伍检测","显示轮廓","发光效果"}) do disabledToggle(SaintSection,n) end
disabledSlider(SaintSection,"范围大小",1,100,10)

saintGroup("玩家")
for _, n in ipairs({"开启/关闭跳跃","无限跳跃","飞行"}) do disabledToggle(SaintSection,n) end
disabledSlider(SaintSection,"设置跳跃高度",50,400,50)
disabledSlider(SaintSection,"飞行速度",10,200,50)

saintGroup("警察功能")
for _, n in ipairs({"自动铐","自动传送","战斗检测"}) do disabledToggle(SaintSection,n) end
disabledSlider(SaintSection,"范围",10,500,200)
disabledSlider(SaintSection,"间隔",0.1,3,0.5)

saintGroup("ESP")
for _, n in ipairs({"玩家透视总开关","显示名字","显示距离","显示血量","显示高亮","显示追踪线"}) do disabledToggle(SaintSection,n) end

saintGroup("其他")
for _, n in ipairs({"自动铐","自动任务","隐身"}) do disabledToggle(SaintSection,n) end

-- 其他服务器脚本：独立加载
local OtherTab = mainWindow:Tab({Title = "其他服务器脚本", Icon = "gamepad-2"})
local OtherSection = OtherTab:Section({Title = "其他服务器脚本", Opened = true})
local BASE = "https://raw.githubusercontent.com/AioveCN/RobloxScriptsAiove/main/"

local function encodePath(s)
    return tostring(s):gsub("[^%w%._%-]", function(c)
        return string.format("%%%02X", string.byte(c))
    end)
end

local function runModule(fileName, displayName)
    local ok, source = pcall(function()
        return game:HttpGet(BASE .. encodePath(fileName))
    end)
    if not ok or type(source) ~= "string" or source == "" then
        warn("[Aiove] 无法读取：" .. displayName)
        return
    end
    local fn, err = loadstring(source)
    if type(fn) ~= "function" then
        warn("[Aiove] 编译失败：" .. displayName .. " / " .. tostring(err))
        return
    end
    local okRun, runErr = pcall(fn)
    if not okRun then
        warn("[Aiove] 运行失败：" .. displayName .. " / " .. tostring(runErr))
    end
end

local function addScript(fileName, displayName)
    OtherSection:Button({
        Title = displayName,
        Desc = "Aiove · 独立源码：" .. fileName,
        Icon = "play",
        Callback = function()
            runModule(fileName, displayName)
        end
    })
end

addScript("01_Aiove_DOORS.lua", "DOORS")
addScript("02_Aiove_GB.lua", "GB")
addScript("03_Aiove_七日生存.lua", "七日生存")
addScript("04_Aiove_不要离开圈子.lua", "不要离开圈子")
addScript("05_Aiove_中国人能飞.lua", "中国人能飞")
addScript("06_Aiove_亡命速递.lua", "亡命速递")
addScript("07_Aiove_伐木大亨2.lua", "伐木大亨2")
addScript("08_Aiove_俄亥俄州.lua", "俄亥俄州")
addScript("09_Aiove_偷一个蛋.lua", "偷一个蛋")
addScript("10_Aiove_决斗场.lua", "决斗场")
addScript("11_Aiove_出售柠檬.lua", "出售柠檬")
addScript("12_Aiove_力量传奇.lua", "力量传奇")
addScript("13_Aiove_动物医院.lua", "动物医院")
addScript("14_Aiove_南极探险队.lua", "南极探险队")
addScript("15_Aiove_变形升级.lua", "变形升级")
addScript("16_Aiove_变身躲猫猫.lua", "变身躲猫猫")
addScript("17_Aiove_吃吃世界.lua", "吃吃世界")
addScript("18_Aiove_吃掉其他人来成长.lua", "吃掉其他人来成长")
addScript("19_Aiove_合成一个核弹.lua", "合成一个核弹")
addScript("20_Aiove_国人电梯.lua", "国人电梯")
addScript("21_Aiove_圣地亚哥边境.lua", "圣地亚哥边境")
addScript("22_Aiove_在末日中生存.lua", "在末日中生存")
addScript("23_Aiove_在超市生活一周.lua", "在超市生活一周")
addScript("24_Aiove_地铁冲浪.lua", "地铁冲浪")
addScript("25_Aiove_墨水游戏.lua", "墨水游戏")
addScript("26_Aiove_巨剑骑士.lua", "巨剑骑士")
addScript("27_Aiove_忍者传奇.lua", "忍者传奇")
addScript("28_Aiove_恶魔学.lua", "恶魔学")
addScript("29_Aiove_戒网瘾中心.lua", "戒网瘾中心")
addScript("30_Aiove_战斗砖块.lua", "战斗砖块")
addScript("31_Aiove_手枪竞技场.lua", "手枪竞技场")
addScript("32_Aiove_找出谁打了一巴掌.lua", "找出谁打了一巴掌")
addScript("33_Aiove_找到按钮.lua", "找到按钮")
addScript("34_Aiove_找到菜鸟的变形形态.lua", "找到菜鸟的变形形态")
addScript("35_Aiove_捕捉并驯服吧.lua", "捕捉并驯服吧")
addScript("36_Aiove_最强战场.lua", "最强战场")
addScript("37_Aiove_最终战场.lua", "最终战场")
addScript("38_Aiove_木筏101天生存.lua", "木筏101天生存")
addScript("39_Aiove_极速传奇.lua", "极速传奇")
addScript("40_Aiove_森林中的99夜.lua", "森林中的99夜")
addScript("41_Aiove_模仿者.lua", "模仿者")
addScript("42_Aiove_死亡避难所.lua", "死亡避难所")
addScript("43_Aiove_死铁轨.lua", "死铁轨")
addScript("44_Aiove_沉默的刺客.lua", "沉默的刺客")
addScript("45_Aiove_泰坦钓鱼.lua", "泰坦钓鱼")
addScript("46_Aiove_烤或死.lua", "烤或死")
addScript("47_Aiove_生存与杀手.lua", "生存与杀手")
addScript("48_Aiove_画我.lua", "画我")
addScript("49_Aiove_疯狂电梯.lua", "疯狂电梯")
addScript("50_Aiove_盲射.lua", "盲射")
addScript("51_Aiove_破坏者谜团2.lua", "破坏者谜团2")
addScript("52_Aiove_种植花园.lua", "种植花园")
addScript("53_Aiove_种植花园2.lua", "种植花园2")
addScript("54_Aiove_紧急汉堡.lua", "紧急汉堡")
addScript("55_Aiove_能量爆炸幸运方块.lua", "能量爆炸幸运方块")
addScript("56_Aiove_自然灾害.lua", "自然灾害")
addScript("57_Aiove_血腥的游乐场.lua", "血腥的游乐场")
addScript("58_Aiove_被遗弃.lua", "被遗弃")
addScript("59_Aiove_踢出幸运方块.lua", "踢出幸运方块")
addScript("60_Aiove_通用血布娃娃战斗.lua", "通用血布娃娃战斗")
addScript("61_Aiove_通缉.lua", "通缉")
addScript("62_Aiove_造船寻宝.lua", "造船寻宝")
addScript("63_Aiove_键盘速度逃脱.lua", "键盘速度逃脱")
addScript("64_Aiove_闪光.lua", "闪光")
addScript("65_Aiove_鲨口求生.lua", "鲨口求生")

WindUI:Notify({
    Title = "Aiove HUB",
    Content = "UI 已加载完成",
    Duration = 3
})
