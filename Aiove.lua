-- Aiove HUB 启动诊断手机版
-- 用途：仅用于排查“执行脚本后手机屏幕完全没有反应”
-- 不加载 Aiove HUB 功能，不修改游戏功能。

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local function getParent()
    if type(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and hui then
            return hui, "gethui()"
        end
    end

    local ok, gui = pcall(function()
        return CoreGui
    end)
    if ok and gui then
        return gui, "CoreGui"
    end

    local player = Players.LocalPlayer
    if player then
        local pg = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui", 5)
        if pg then
            return pg, "PlayerGui"
        end
    end

    return nil, "无可用 GUI 容器"
end

local parent, parentName = getParent()
if not parent then
    warn("[Aiove Mobile Diagnostic] 无法创建手机诊断界面：" .. parentName)
    return
end

pcall(function()
    local old = parent:FindFirstChild("Aiove_HUB_Mobile_Diagnostic")
    if old then old:Destroy() end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "Aiove_HUB_Mobile_Diagnostic"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
pcall(function() gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling end)
gui.Parent = parent

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.new(0, 340, 0, 430)
frame.Position = UDim2.new(0.5, -170, 0.5, -215)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1.5
stroke.Color = Color3.fromRGB(90, 90, 100)
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 0, 45)
title.Position = UDim2.new(0, 15, 0, 10)
title.BackgroundTransparency = 1
title.Text = "Aiove HUB 启动诊断（手机版）"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 19
title.Font = Enum.Font.GothamBold
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -30, 1, -105)
status.Position = UDim2.new(0, 15, 0, 58)
status.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
status.BorderSizePixel = 0
status.TextColor3 = Color3.fromRGB(235, 235, 240)
status.TextSize = 15
status.Font = Enum.Font.Gotham
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextYAlignment = Enum.TextYAlignment.Top
status.TextWrapped = true
status.Text = "正在启动手机版诊断……\n"
status.Parent = frame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 10)
statusCorner.Parent = status

local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(1, -30, 0, 35)
hint.Position = UDim2.new(0, 15, 1, -45)
hint.BackgroundTransparency = 1
hint.Text = "诊断完成后，请把这个窗口截图发给我。"
hint.TextColor3 = Color3.fromRGB(180, 180, 190)
hint.TextSize = 13
hint.Font = Enum.Font.Gotham
hint.TextWrapped = true
hint.Parent = frame

local lines = {}
local function add(text)
    table.insert(lines, text)
    status.Text = table.concat(lines, "\n")
end

local function result(ok, name, detail)
    if ok then
        add("\n" .. name .. "  ✅ 正常" .. (detail and ("\n   " .. detail) or ""))
    else
        add("\n" .. name .. "  ❌ 失败" .. (detail and ("\n   " .. tostring(detail)) or ""))
    end
end

add("① 脚本执行       ✅ 已执行")
add("GUI 容器         ✅ " .. parentName)

-- loadstring 测试
local loadOk = type(loadstring) == "function"
if loadOk then
    local fn, err = loadstring("return 123", "Aiove_Mobile_Diagnostic")
    if fn then
        local ok, value = pcall(fn)
        loadOk = ok and value == 123
        result(loadOk, "② loadstring", loadOk and "编译与执行测试通过" or "执行测试失败: " .. tostring(value))
    else
        loadOk = false
        result(false, "② loadstring", err)
    end
else
    result(false, "② loadstring", "当前执行器没有提供 loadstring")
end

-- HTTP 测试：优先测试实际 WindUI 地址
local windUrl = "https://raw.githubusercontent.com/LumiereSeren/UI/refs/heads/main/cyyWind.lua"
local httpOk = false
local httpName = nil
local httpData = nil
local httpErr = nil

local function tryHttp(name, fn)
    if httpOk then return end
    local ok, data = pcall(fn)
    if ok and data ~= nil then
        if type(data) == "table" and data.Body then
            data = data.Body
        end
        local s = tostring(data)
        if #s > 0 then
            httpOk = true
            httpName = name
            httpData = s
            return
        end
    end
    httpErr = tostring(data)
end

if game and type(game.HttpGet) == "function" then
    tryHttp("game:HttpGet", function()
        return game:HttpGet(windUrl)
    end)
end

if not httpOk and game and type(game.HttpGetAsync) == "function" then
    tryHttp("game:HttpGetAsync", function()
        return game:HttpGetAsync(windUrl)
    end)
end

if not httpOk and type(request) == "function" then
    tryHttp("request", function()
        local r = request({Url = windUrl, Method = "GET"})
        if type(r) == "table" then
            return r.Body or r.body or r
        end
        return r
    end)
end

if not httpOk and type(http_request) == "function" then
    tryHttp("http_request", function()
        local r = http_request({Url = windUrl, Method = "GET"})
        if type(r) == "table" then
            return r.Body or r.body or r
        end
        return r
    end)
end

result(httpOk, "③ HTTP 请求", httpOk and (httpName .. " 可用，返回内容长度：" .. tostring(#httpData)) or (httpErr or "未检测到可用 HTTP 方法"))

-- WindUI 下载/内容检查
local windOk = false
if httpOk and httpData then
    windOk = #httpData > 100 and (string.find(httpData, "WindUI", 1, true) ~= nil or string.find(httpData, "function", 1, true) ~= nil)
    result(windOk, "④ WindUI 下载", windOk and "已成功取得 cyyWind.lua 内容" or "HTTP 有响应，但返回内容不像有效 WindUI 源码")
else
    result(false, "④ WindUI 下载", "因为 HTTP 请求失败，无法取得 cyyWind.lua")
end

-- 不真正执行 WindUI，只检查 loadstring 编译，避免诊断脚本本身被 UI 库拖死
local compileOk = false
if windOk and type(loadstring) == "function" then
    local fn, err = loadstring(httpData, "Aiove_WindUI_Diagnostic")
    compileOk = fn ~= nil
    result(compileOk, "⑤ WindUI 编译", compileOk and "源码可以通过 loadstring 编译" or err)
else
    result(false, "⑤ WindUI 编译", "前置条件未满足，跳过")
end

add("\n━━━━━━━━━━━━━━━━━━")
if compileOk then
    add("最终结果：🟢 启动环境基本正常")
    add("问题更可能出在 Aiove HUB 主程序本身。")
elseif httpOk then
    add("最终结果：🟡 HTTP 正常，但 WindUI 源码检查未通过")
    add("下一步应针对 WindUI 加载部分排查。")
else
    add("最终结果：🔴 HTTP / 执行环境存在问题")
    add("请把本窗口完整截图发给我。")
end

-- 尝试复制简短结果，但不依赖剪贴板
if type(setclipboard) == "function" then
    pcall(function()
        setclipboard(status.Text)
    end)
end
