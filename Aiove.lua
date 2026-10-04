-- 1. 先测基础 API
print("loadstring:", type(loadstring))
print("gethui:", type(gethui))
print("hookmetamethod:", type(hookmetamethod))
print("getgc:", type(getgc))

-- 2. 模拟执行 Aiove.lua 并抓取所有报错
local url = "https://raw.githubusercontent.com/AioveCN/RobloxScriptsAiove/main/Aiove.lua"
local ok, err = pcall(function()
    local source = game:HttpGet(url)
    print("源码下载成功，长度:", #source)
    local fn = loadstring(source)
    if not fn then
        print("❌ loadstring 编译失败！代码有语法错误。")
        return
    end
    print("✅ loadstring 编译成功，准备执行")
    fn()
    print("✅ 脚本执行完毕")
end)
if not ok then
    print("❌ 运行时报错:", err)
end
