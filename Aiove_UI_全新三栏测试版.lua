-- Aiove HUB：全新原生 UI 测试版
-- 三栏：信息 / 通用 / 其他服务器脚本
-- 已彻底移除：圣奥里、语言设置、WindUI 依赖
-- 01~65 保持独立文件，通过 GitHub Raw 单独加载

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local GUI_NAME = "AioveHUB_Custom"

pcall(function()
    local old = CoreGui:FindFirstChild(GUI_NAME)
    if old then old:Destroy() end
end)
pcall(function()
    local old = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild(GUI_NAME)
    if old then old:Destroy() end
end)

local function getParent()
    local ok, result = pcall(function()
        return CoreGui
    end)
    if ok and result then return result end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local gui = Instance.new("ScreenGui")
gui.Name = GUI_NAME
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = getParent()

local C = {
    bg = Color3.fromRGB(5, 8, 24),
    panel = Color3.fromRGB(10, 15, 35),
    card = Color3.fromRGB(14, 21, 47),
    card2 = Color3.fromRGB(18, 25, 54),
    line = Color3.fromRGB(42, 51, 91),
    purple = Color3.fromRGB(137, 62, 255),
    purple2 = Color3.fromRGB(91, 45, 220),
    white = Color3.fromRGB(242, 240, 255),
    sub = Color3.fromRGB(177, 181, 210),
    green = Color3.fromRGB(91, 235, 174),
}

local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = obj
    return c
end

local function stroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or C.line
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = obj
    return s
end

local function gradient(obj, a, b, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(a, b)
    g.Rotation = rotation or 0
    g.Parent = obj
    return g
end

local function label(parent, text, size, color, font, align)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextSize = size or 16
    l.TextColor3 = color or C.white
    l.Font = font or Enum.Font.Gotham
    l.TextXAlignment = align or Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.Parent = parent
    return l
end

local function button(parent, text)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = false
    b.Text = text
    b.TextColor3 = C.white
    b.TextSize = 16
    b.Font = Enum.Font.GothamBold
    b.BackgroundColor3 = C.card
    b.BorderSizePixel = 0
    b.Parent = parent
    corner(b, 12)
    stroke(b, C.line, 1, 0.15)
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(.12), {BackgroundColor3 = C.card2}):Play()
    end)
    b.MouseLeave:Connect(function()
        if b:GetAttribute("Selected") then return end
        TweenService:Create(b, TweenInfo.new(.12), {BackgroundColor3 = C.card}):Play()
    end)
    return b
end

local root = Instance.new("Frame")
root.AnchorPoint = Vector2.new(.5, .5)
root.Position = UDim2.fromScale(.5, .5)
root.Size = UDim2.new(0, 1000, 0, 650)
root.BackgroundColor3 = C.bg
root.BorderSizePixel = 0
root.ClipsDescendants = true
root.Parent = gui
corner(root, 14)
stroke(root, Color3.fromRGB(55, 44, 120), 2, .1)
gradient(root, Color3.fromRGB(6, 9, 25), Color3.fromRGB(10, 13, 32), 45)

local scale = Instance.new("UIScale")
scale.Scale = 1
scale.Parent = root

-- 顶部
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 118)
header.BackgroundTransparency = 1
header.Parent = root

local logo = label(header, "Aiove", 62, C.white, Enum.Font.GothamBlack)
logo.Position = UDim2.new(0, 28, 0, 13)
logo.Size = UDim2.new(0, 245, 0, 62)
logo.TextStrokeTransparency = .75

local crown = label(header, "♛", 35, C.purple, Enum.Font.GothamBold)
crown.Position = UDim2.new(0, 119, 0, 0)
crown.Size = UDim2.new(0, 48, 0, 38)

local hubTitle = label(header, "Aiove HUB", 25, C.purple, Enum.Font.GothamBold)
hubTitle.Position = UDim2.new(0, 294, 0, 43)
hubTitle.Size = UDim2.new(0, 200, 0, 30)

local welcome = label(header, "欢迎您的使用", 18, C.sub, Enum.Font.Gotham)
welcome.Position = UDim2.new(0, 294, 0, 72)
welcome.Size = UDim2.new(0, 200, 0, 28)

local feedback = Instance.new("TextButton")
feedback.Size = UDim2.new(0, 285, 0, 50)
feedback.Position = UDim2.new(1, -365, 0, 38)
feedback.BackgroundColor3 = C.card
feedback.BorderSizePixel = 0
feedback.Text = "●   反馈：QQ：3593722551"
feedback.TextColor3 = C.white
feedback.TextSize = 16
feedback.Font = Enum.Font.GothamBold
feedback.AutoButtonColor = false
feedback.Parent = header
corner(feedback, 18)
stroke(feedback, C.line, 1)
feedback.MouseButton1Click:Connect(function()
    pcall(function()
        if setclipboard then setclipboard("3593722551") end
    end)
end)

local minimize = button(header, "—")
minimize.Size = UDim2.new(0, 44, 0, 44)
minimize.Position = UDim2.new(1, -78, 0, 41)
minimize.TextSize = 24
local close = button(header, "×")
close.Size = UDim2.new(0, 44, 0, 44)
close.Position = UDim2.new(1, -30, 0, 41)
close.TextSize = 27

local divider = Instance.new("Frame")
divider.Position = UDim2.new(0, 0, 0, 117)
divider.Size = UDim2.new(1, 0, 0, 1)
divider.BackgroundColor3 = C.line
divider.BorderSizePixel = 0
divider.Parent = root

-- 左侧导航
local sidebar = Instance.new("Frame")
sidebar.Position = UDim2.new(0, 0, 0, 118)
sidebar.Size = UDim2.new(0, 320, 1, -118)
sidebar.BackgroundTransparency = 1
sidebar.Parent = root

local sidePad = Instance.new("UIPadding")
sidePad.PaddingTop = UDim.new(0, 14)
sidePad.PaddingLeft = UDim.new(0, 18)
sidePad.PaddingRight = UDim.new(0, 14)
sidePad.Parent = sidebar

local sideList = Instance.new("UIListLayout")
sideList.Padding = UDim.new(0, 12)
sideList.SortOrder = Enum.SortOrder.LayoutOrder
sideList.Parent = sidebar

local content = Instance.new("Frame")
content.Position = UDim2.new(0, 320, 0, 118)
content.Size = UDim2.new(1, -320, 1, -118)
content.BackgroundTransparency = 1
content.Parent = root

local pages = {}
local navs = {}

local function makePage()
    local p = Instance.new("Frame")
    p.Size = UDim2.fromScale(1, 1)
    p.BackgroundTransparency = 1
    p.Visible = false
    p.Parent = content
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 14)
    pad.PaddingBottom = UDim.new(0, 18)
    pad.PaddingLeft = UDim.new(0, 20)
    pad.PaddingRight = UDim.new(0, 20)
    pad.Parent = p
    return p
end

local infoPage = makePage()
local generalPage = makePage()
local otherPage = makePage()
pages.info = infoPage
pages.general = generalPage
pages.other = otherPage

local function makeNav(title, sub, icon, key)
    local b = button(sidebar, "")
    b.Size = UDim2.new(1, 0, 0, 92)
    b.LayoutOrder = #navs + 1

    local ico = label(b, icon, 34, C.white, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    ico.Size = UDim2.new(0, 55, 0, 50)
    ico.Position = UDim2.new(0, 14, 0, 12)

    local t = label(b, title, 20, C.white, Enum.Font.GothamBold)
    t.Position = UDim2.new(0, 78, 0, 17)
    t.Size = UDim2.new(1, -110, 0, 28)

    local s = label(b, sub, 13, C.sub, Enum.Font.Gotham)
    s.Position = UDim2.new(0, 78, 0, 48)
    s.Size = UDim2.new(1, -110, 0, 24)

    local arrow = label(b, "›", 29, C.white, Enum.Font.Gotham)
    arrow.Position = UDim2.new(1, -36, 0, 30)
    arrow.Size = UDim2.new(0, 25, 0, 30)
    arrow.TextXAlignment = Enum.TextXAlignment.Center

    navs[key] = b
    b.MouseButton1Click:Connect(function()
        for k, p in pairs(pages) do
            p.Visible = (k == key)
        end
        for k, n in pairs(navs) do
            n:SetAttribute("Selected", k == key)
            n.BackgroundColor3 = k == key and C.purple2 or C.card
            if k == key then
                gradient(n, C.purple2, C.purple, 0)
            else
                local g = n:FindFirstChildOfClass("UIGradient")
                if g then g:Destroy() end
            end
        end
    end)
    return b
end

makeNav("信息", "欢迎 / 服务器 / 设置", "⌂", "info")
makeNav("通用", "通用功能脚本", "⚙", "general")
makeNav("其他服务器脚本", "65个小游戏脚本", "✦", "other")

local footer = label(sidebar, "♛\nAiove制作\n只为更好的游戏体验！", 16, C.purple, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
footer.AnchorPoint = Vector2.new(.5, 1)
footer.Position = UDim2.new(.5, 0, 1, -20)
footer.Size = UDim2.new(1, -25, 0, 95)

-- 信息页
local infoCard = Instance.new("Frame")
infoCard.Size = UDim2.new(1, 0, 0, 416)
infoCard.BackgroundColor3 = C.panel
infoCard.BorderSizePixel = 0
infoCard.Parent = infoPage
corner(infoCard, 14)
stroke(infoCard, C.line, 1)

local infoCrown = label(infoCard, "♛", 50, C.purple, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
infoCrown.Position = UDim2.new(0, 18, 0, 17)
infoCrown.Size = UDim2.new(0, 75, 0, 65)

local infoTitle = label(infoCard, "信息", 30, C.white, Enum.Font.GothamBold)
infoTitle.Position = UDim2.new(0, 96, 0, 18)
infoTitle.Size = UDim2.new(0, 200, 0, 38)

local infoSub = label(infoCard, "欢迎使用 Aiove HUB", 18, C.sub)
infoSub.Position = UDim2.new(0, 96, 0, 55)
infoSub.Size = UDim2.new(0, 300, 0, 30)

local welcomeBox = Instance.new("Frame")
welcomeBox.Position = UDim2.new(0, 18, 0, 102)
welcomeBox.Size = UDim2.new(0.62, -10, 0, 190)
welcomeBox.BackgroundColor3 = C.bg
welcomeBox.BorderSizePixel = 0
welcomeBox.Parent = infoCard
corner(welcomeBox, 12)
stroke(welcomeBox, C.line, 1)

local infoText = label(welcomeBox,
    "♛   欢迎您的使用 Aiove HUB!\n\n" ..
    "♣   本脚本仅供学习交流，请勿用于非法用途。\n\n" ..
    "●   QQ反馈：3593722551\n\n" ..
    "▣   当前服务器：" .. tostring(game.JobId ~= "" and "个人服务器" or "未知") .. "\n\n" ..
    "◷   当前时间：" .. os.date("%Y-%m-%d %H:%M:%S"),
    16, C.white, Enum.Font.Gotham)
infoText.Position = UDim2.new(0, 18, 0, 12)
infoText.Size = UDim2.new(1, -36, 1, -24)
infoText.TextYAlignment = Enum.TextYAlignment.Top

local promo = Instance.new("Frame")
promo.Position = UDim2.new(0.65, 0, 0, 102)
promo.Size = UDim2.new(0.35, -18, 0, 190)
promo.BackgroundColor3 = C.card2
promo.BorderSizePixel = 0
promo.Parent = infoCard
corner(promo, 12)
stroke(promo, C.line, 1)
gradient(promo, Color3.fromRGB(35, 13, 75), Color3.fromRGB(9, 14, 37), 135)

local promoLogo = label(promo, "Aiove", 44, C.white, Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
promoLogo.Size = UDim2.new(1, 0, 0, 65)
promoLogo.Position = UDim2.new(0, 0, 0, 38)
local promoCrown = label(promo, "♛", 27, C.purple, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
promoCrown.Size = UDim2.new(1, 0, 0, 32)
promoCrown.Position = UDim2.new(0, 0, 0, 16)
local promoSub = label(promo, "— 让游戏更简单 —", 15, C.white, Enum.Font.Gotham, Enum.TextXAlignment.Center)
promoSub.Size = UDim2.new(1, 0, 0, 28)
promoSub.Position = UDim2.new(0, 0, 0, 108)

local settingsBar = Instance.new("Frame")
settingsBar.Position = UDim2.new(0, 18, 0, 305)
settingsBar.Size = UDim2.new(1, -36, 0, 78)
settingsBar.BackgroundTransparency = 1
settingsBar.Parent = infoCard

local uiSetting = button(settingsBar, "⚙  UI设置")
uiSetting.Size = UDim2.new(0, 125, 1, 0)

local roundToggle = button(settingsBar, "◉  圆角风格     ●")
roundToggle.Position = UDim2.new(0, 137, 0, 0)
roundToggle.Size = UDim2.new(0, 185, 1, 0)

local opacity = label(settingsBar, "透明度   ━━━━━━━  70%", 15, C.white)
opacity.Position = UDim2.new(0, 335, 0, 0)
opacity.Size = UDim2.new(1, -335, 1, 0)

local detailsTitle = label(infoPage, "信息内容", 24, C.white, Enum.Font.GothamBold)
detailsTitle.Position = UDim2.new(0, 8, 0, 432)
detailsTitle.Size = UDim2.new(1, 0, 0, 34)

local detailScroll = Instance.new("ScrollingFrame")
detailScroll.Position = UDim2.new(0, 0, 0, 472)
detailScroll.Size = UDim2.new(1, 0, 1, -472)
detailScroll.BackgroundTransparency = 1
detailScroll.BorderSizePixel = 0
detailScroll.ScrollBarThickness = 4
detailScroll.CanvasSize = UDim2.new()
detailScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
detailScroll.Parent = infoPage

local detailLayout = Instance.new("UIListLayout")
detailLayout.Padding = UDim.new(0, 8)
detailLayout.Parent = detailScroll

local function detailCard(title, desc, icon)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, -5, 0, 78)
    c.BackgroundColor3 = C.card
    c.BorderSizePixel = 0
    c.Parent = detailScroll
    corner(c, 12)
    stroke(c, C.line, 1)
    local i = label(c, icon, 27, C.purple, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    i.Size = UDim2.new(0, 58, 1, 0)
    local t = label(c, title, 17, C.purple, Enum.Font.GothamBold)
    t.Position = UDim2.new(0, 68, 0, 14)
    t.Size = UDim2.new(1, -100, 0, 25)
    local d = label(c, desc, 13, C.sub)
    d.Position = UDim2.new(0, 68, 0, 40)
    d.Size = UDim2.new(1, -100, 0, 24)
    local a = label(c, "›", 28, C.purple, Enum.Font.Gotham)
    a.Position = UDim2.new(1, -40, 0, 23)
    a.Size = UDim2.new(0, 25, 0, 30)
end

detailCard("欢迎信息", "感谢你使用 Aiove HUB，希望你玩得开心！", "●")
detailCard("服务器信息", "服务器名称：个人服务器    人数：" .. #Players:GetPlayers(), "▤")
detailCard("反馈方式", "QQ：3593722551    有问题或建议请联系我！", "♧")
detailCard("UI设置", "调整界面风格、透明度、圆角等", "⚙")

-- 通用页：先保留 UI，不加载旧的圣奥里功能
local generalTitle = label(generalPage, "通用", 30, C.white, Enum.Font.GothamBold)
generalTitle.Size = UDim2.new(1, 0, 0, 42)

local generalCard = Instance.new("Frame")
generalCard.Position = UDim2.new(0, 0, 0, 55)
generalCard.Size = UDim2.new(1, 0, 0, 155)
generalCard.BackgroundColor3 = C.panel
generalCard.BorderSizePixel = 0
generalCard.Parent = generalPage
corner(generalCard, 14)
stroke(generalCard, C.line, 1)

local gt = label(generalCard, "通用功能脚本", 21, C.purple, Enum.Font.GothamBold)
gt.Position = UDim2.new(0, 22, 0, 20)
gt.Size = UDim2.new(1, -44, 0, 30)
local gd = label(generalCard, "此版本先完成全新 UI，通用功能暂不自动执行。", 15, C.sub)
gd.Position = UDim2.new(0, 22, 0, 58)
gd.Size = UDim2.new(1, -44, 0, 30)
local status = label(generalCard, "●  功能状态：关闭", 15, C.green, Enum.Font.GothamBold)
status.Position = UDim2.new(0, 22, 0, 100)
status.Size = UDim2.new(1, -44, 0, 28)

-- 其他脚本页
local otherTitle = label(otherPage, "其他服务器脚本", 28, C.white, Enum.Font.GothamBold)
otherTitle.Size = UDim2.new(1, 0, 0, 40)
local otherSub = label(otherPage, "65 个独立小游戏脚本 · 点击按钮单独加载", 14, C.sub)
otherSub.Position = UDim2.new(0, 0, 0, 38)
otherSub.Size = UDim2.new(1, 0, 0, 26)

local otherScroll = Instance.new("ScrollingFrame")
otherScroll.Position = UDim2.new(0, 0, 0, 72)
otherScroll.Size = UDim2.new(1, 0, 1, -72)
otherScroll.BackgroundTransparency = 1
otherScroll.BorderSizePixel = 0
otherScroll.ScrollBarThickness = 5
otherScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
otherScroll.CanvasSize = UDim2.new()
otherScroll.Parent = otherPage

local otherLayout = Instance.new("UIGridLayout")
otherLayout.CellSize = UDim2.new(0.5, -8, 0, 58)
otherLayout.CellPadding = UDim2.new(0, 10, 0, 10)
otherLayout.SortOrder = Enum.SortOrder.LayoutOrder
otherLayout.Parent = otherScroll

local statusLabel = label(otherPage, "", 13, C.sub)
statusLabel.Position = UDim2.new(0, 0, 1, -20)
statusLabel.Size = UDim2.new(1, 0, 0, 20)

local RAW_BASE = "https://raw.githubusercontent.com/AioveCN/RobloxScriptsAiove/main/"

local function addScriptButton(parent, title, filename)
    local b = button(parent, title)
    b.LayoutOrder = tonumber(filename:sub(1,2)) or 99
    b.MouseButton1Click:Connect(function()
        statusLabel.Text = "正在加载：" .. title
        local ok, err = pcall(function()
            local source = game:HttpGet(RAW_BASE .. filename)
            local fn = loadstring(source)
            if type(fn) ~= "function" then
                error("脚本返回内容无法执行")
            end
            fn()
        end)
        if ok then
            statusLabel.Text = "已执行：" .. title
        else
            statusLabel.Text = "加载失败：" .. title .. "  |  " .. tostring(err)
            warn("[Aiove HUB] " .. title .. " 加载失败: " .. tostring(err))
        end
    end)
    return b
end

    addScriptButton(otherScroll, "01  DOORS", "01_Aiove_DOORS.lua")
    addScriptButton(otherScroll, "02  GB", "02_Aiove_GB.lua")
    addScriptButton(otherScroll, "03  七日生存", "03_Aiove_七日生存.lua")
    addScriptButton(otherScroll, "04  不要离开圈子", "04_Aiove_不要离开圈子.lua")
    addScriptButton(otherScroll, "05  中国人能飞", "05_Aiove_中国人能飞.lua")
    addScriptButton(otherScroll, "06  亡命速递", "06_Aiove_亡命速递.lua")
    addScriptButton(otherScroll, "07  伐木大亨2", "07_Aiove_伐木大亨2.lua")
    addScriptButton(otherScroll, "08  俄亥俄州", "08_Aiove_俄亥俄州.lua")
    addScriptButton(otherScroll, "09  偷一个蛋", "09_Aiove_偷一个蛋.lua")
    addScriptButton(otherScroll, "10  决斗场", "10_Aiove_决斗场.lua")
    addScriptButton(otherScroll, "11  出售柠檬", "11_Aiove_出售柠檬.lua")
    addScriptButton(otherScroll, "12  力量传奇", "12_Aiove_力量传奇.lua")
    addScriptButton(otherScroll, "13  动物医院", "13_Aiove_动物医院.lua")
    addScriptButton(otherScroll, "14  南极探险队", "14_Aiove_南极探险队.lua")
    addScriptButton(otherScroll, "15  变形升级", "15_Aiove_变形升级.lua")
    addScriptButton(otherScroll, "16  变身躲猫猫", "16_Aiove_变身躲猫猫.lua")
    addScriptButton(otherScroll, "17  吃吃世界", "17_Aiove_吃吃世界.lua")
    addScriptButton(otherScroll, "18  吃掉其他人来成长", "18_Aiove_吃掉其他人来成长.lua")
    addScriptButton(otherScroll, "19  合成一个核弹", "19_Aiove_合成一个核弹.lua")
    addScriptButton(otherScroll, "20  国人电梯", "20_Aiove_国人电梯.lua")
    addScriptButton(otherScroll, "21  圣地亚哥边境", "21_Aiove_圣地亚哥边境.lua")
    addScriptButton(otherScroll, "22  在末日中生存", "22_Aiove_在末日中生存.lua")
    addScriptButton(otherScroll, "23  在超市生活一周", "23_Aiove_在超市生活一周.lua")
    addScriptButton(otherScroll, "24  地铁冲浪", "24_Aiove_地铁冲浪.lua")
    addScriptButton(otherScroll, "25  墨水游戏", "25_Aiove_墨水游戏.lua")
    addScriptButton(otherScroll, "26  巨剑骑士", "26_Aiove_巨剑骑士.lua")
    addScriptButton(otherScroll, "27  忍者传奇", "27_Aiove_忍者传奇.lua")
    addScriptButton(otherScroll, "28  恶魔学", "28_Aiove_恶魔学.lua")
    addScriptButton(otherScroll, "29  戒网瘾中心", "29_Aiove_戒网瘾中心.lua")
    addScriptButton(otherScroll, "30  战斗砖块", "30_Aiove_战斗砖块.lua")
    addScriptButton(otherScroll, "31  手枪竞技场", "31_Aiove_手枪竞技场.lua")
    addScriptButton(otherScroll, "32  找出谁打了一巴掌", "32_Aiove_找出谁打了一巴掌.lua")
    addScriptButton(otherScroll, "33  找到按钮", "33_Aiove_找到按钮.lua")
    addScriptButton(otherScroll, "34  找到菜鸟的变形形态", "34_Aiove_找到菜鸟的变形形态.lua")
    addScriptButton(otherScroll, "35  捕捉并驯服吧", "35_Aiove_捕捉并驯服吧.lua")
    addScriptButton(otherScroll, "36  最强战场", "36_Aiove_最强战场.lua")
    addScriptButton(otherScroll, "37  最终战场", "37_Aiove_最终战场.lua")
    addScriptButton(otherScroll, "38  木筏101天生存", "38_Aiove_木筏101天生存.lua")
    addScriptButton(otherScroll, "39  极速传奇", "39_Aiove_极速传奇.lua")
    addScriptButton(otherScroll, "40  森林中的99夜", "40_Aiove_森林中的99夜.lua")
    addScriptButton(otherScroll, "41  模仿者", "41_Aiove_模仿者.lua")
    addScriptButton(otherScroll, "42  死亡避难所", "42_Aiove_死亡避难所.lua")
    addScriptButton(otherScroll, "43  死铁轨", "43_Aiove_死铁轨.lua")
    addScriptButton(otherScroll, "44  沉默的刺客", "44_Aiove_沉默的刺客.lua")
    addScriptButton(otherScroll, "45  泰坦钓鱼", "45_Aiove_泰坦钓鱼.lua")
    addScriptButton(otherScroll, "46  烤或死", "46_Aiove_烤或死.lua")
    addScriptButton(otherScroll, "47  生存与杀手", "47_Aiove_生存与杀手.lua")
    addScriptButton(otherScroll, "48  画我", "48_Aiove_画我.lua")
    addScriptButton(otherScroll, "49  疯狂电梯", "49_Aiove_疯狂电梯.lua")
    addScriptButton(otherScroll, "50  盲射", "50_Aiove_盲射.lua")
    addScriptButton(otherScroll, "51  破坏者谜团2", "51_Aiove_破坏者谜团2.lua")
    addScriptButton(otherScroll, "52  种植花园", "52_Aiove_种植花园.lua")
    addScriptButton(otherScroll, "53  种植花园2", "53_Aiove_种植花园2.lua")
    addScriptButton(otherScroll, "54  紧急汉堡", "54_Aiove_紧急汉堡.lua")
    addScriptButton(otherScroll, "55  能量爆炸幸运方块", "55_Aiove_能量爆炸幸运方块.lua")
    addScriptButton(otherScroll, "56  自然灾害", "56_Aiove_自然灾害.lua")
    addScriptButton(otherScroll, "57  血腥的游乐场", "57_Aiove_血腥的游乐场.lua")
    addScriptButton(otherScroll, "58  被遗弃", "58_Aiove_被遗弃.lua")
    addScriptButton(otherScroll, "59  踢出幸运方块", "59_Aiove_踢出幸运方块.lua")
    addScriptButton(otherScroll, "60  通用血布娃娃战斗", "60_Aiove_通用血布娃娃战斗.lua")
    addScriptButton(otherScroll, "61  通缉", "61_Aiove_通缉.lua")
    addScriptButton(otherScroll, "62  造船寻宝", "62_Aiove_造船寻宝.lua")
    addScriptButton(otherScroll, "63  键盘速度逃脱", "63_Aiove_键盘速度逃脱.lua")
    addScriptButton(otherScroll, "64  闪光", "64_Aiove_闪光.lua")
    addScriptButton(otherScroll, "65  鲨口求生", "65_Aiove_鲨口求生.lua")

-- 默认显示信息页
navs.info:SetAttribute("Selected", true)
navs.info.BackgroundColor3 = C.purple2
gradient(navs.info, C.purple2, C.purple, 0)
infoPage.Visible = true

-- 拖动窗口
do
    local dragging = false
    local dragStart
    local startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = root.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            root.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local minimized = false
local oldSize = root.Size
minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        oldSize = root.Size
        TweenService:Create(root, TweenInfo.new(.2), {
            Size = UDim2.new(0, 1000, 0, 118)
        }):Play()
    else
        TweenService:Create(root, TweenInfo.new(.2), {
            Size = oldSize
        }):Play()
    end
end)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- 移动端/小屏适配
local function fit()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local v = cam.ViewportSize
    local sx = math.clamp(v.X / 1000, .62, 1)
    local sy = math.clamp(v.Y / 650, .62, 1)
    scale.Scale = math.min(sx, sy)
end
fit()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)
end
