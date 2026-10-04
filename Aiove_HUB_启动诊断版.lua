-- Aiove HUB 启动诊断版
-- 仅用于定位“执行后完全没反应”的问题
-- 不加载 Aiove HUB，不执行任何游戏功能

local function report(title, message)
    local line = "[Aiove Diagnostic] " .. tostring(title) .. ": " .. tostring(message)
    print(line)
    warn(line)
end

report("TEST", "脚本已经开始执行")

-- 1. 检查关键函数
report("loadstring", type(loadstring))
report("pcall", type(pcall))

-- 2. 测试 loadstring
if type(loadstring) == "function" then
    local fn, err = loadstring("return 123", "Aiove_Diagnostic_Test")
    if fn then
        local ok, result = pcall(fn)
        if ok and result == 123 then
            report("LOADSTRING", "正常")
        else
            report("LOADSTRING", "编译成功，但执行测试失败: " .. tostring(result))
        end
    else
        report("LOADSTRING", "编译失败: " .. tostring(err))
    end
else
    report("LOADSTRING", "当前执行环境没有提供 loadstring")
end

-- 3. 检查 HTTP
local httpWorked = false

local function testHttp(name, fn)
    local ok, result = pcall(fn)
    if ok and result ~= nil then
        httpWorked = true
        if type(result) == "table" then
            report("HTTP", name .. " 可用，返回 table")
        else
            local s = tostring(result)
            report("HTTP", name .. " 可用，返回 " .. type(result) .. "，长度 " .. tostring(#s))
        end
        return true
    end
    report("HTTP", name .. " 失败: " .. tostring(result))
    return false
end

if game and type(game.HttpGet) == "function" then
    testHttp("game:HttpGet", function()
        return game:HttpGet("https://raw.githubusercontent.com/Roblox/creator-docs/main/README.md")
    end)
else
    report("HTTP", "game:HttpGet 不可用")
end

if not httpWorked and type(request) == "function" then
    testHttp("request", function()
        return request({
            Url = "https://raw.githubusercontent.com/Roblox/creator-docs/main/README.md",
            Method = "GET"
        })
    end)
end

if not httpWorked and type(http_request) == "function" then
    testHttp("http_request", function()
        return http_request({
            Url = "https://raw.githubusercontent.com/Roblox/creator-docs/main/README.md",
            Method = "GET"
        })
    end)
end

if not httpWorked then
    report("HTTP", "未检测到可用的 HTTP 请求方式")
end

report("RESULT", "诊断脚本已经执行结束")
print("========== Aiove HUB DIAGNOSTIC END ==========")

if type(setclipboard) == "function" then
    pcall(function()
        setclipboard("Aiove HUB 诊断脚本已执行，请查看执行器 Console / F9 输出。")
    end)
end
