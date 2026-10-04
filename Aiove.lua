-- Aiove.lua
-- Aiove HUB 极简启动诊断版
-- 本版只诊断启动链，不启动原 Aiove HUB 功能。

local function safe(v)
    return tostring(v):gsub("\n", "\\n")
end

local gui
local body
local lines = {}

local function log(msg)
    lines[#lines + 1] = tostring(msg)

    if body then
        body.Text = table.concat(lines, "\n")
    end

    warn("[Aiove诊断] " .. tostring(msg))
end

--------------------------------------------------
-- ① 第一时间创建原生诊断面板
-- 不依赖 WindUI
--------------------------------------------------

do
    local ok, err = pcall(function()

        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        local parent

        if player then
            parent =
                player:FindFirstChildOfClass("PlayerGui")
                or player:WaitForChild("PlayerGui", 5)
        end

        if not parent then
            parent = game:GetService("CoreGui")
        end

        gui = Instance.new("ScreenGui")
        gui.Name = "Aiove_Startup_Diagnostic"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.Parent = parent

        local frame = Instance.new("Frame")

        frame.Size = UDim2.fromOffset(390, 330)
        frame.Position = UDim2.new(0.5, -195, 0.5, -165)
        frame.BackgroundTransparency = 0.08
        frame.Parent = gui

        local title = Instance.new("TextLabel")

        title.Size = UDim2.new(1, -20, 0, 42)
        title.Position = UDim2.fromOffset(10, 8)
        title.BackgroundTransparency = 1
        title.Text = "Aiove.lua 启动诊断"
        title.TextSize = 21
        title.TextWrapped = true
        title.Parent = frame

        body = Instance.new("TextLabel")

        body.Size = UDim2.new(1, -20, 1, -62)
        body.Position = UDim2.fromOffset(10, 55)
        body.BackgroundTransparency = 1
        body.TextXAlignment = Enum.TextXAlignment.Left
        body.TextYAlignment = Enum.TextYAlignment.Top
        body.TextSize = 15
        body.TextWrapped = true
        body.Parent = frame

        log("① Aiove.lua 已开始执行：✅")
    end)

    if not ok then
        warn(
            "[Aiove诊断] ① 原生诊断面板创建失败："
                .. safe(err)
        )

        return
    end
end

--------------------------------------------------
-- ② Players
-- ③ LocalPlayer
--------------------------------------------------

do

    local ok, err = pcall(function()

        local Players = game:GetService("Players")

        log("② Players：✅")

        if Players.LocalPlayer then

            log(
                "③ LocalPlayer：✅ "
                    .. Players.LocalPlayer.Name
            )

        else

            log("③ LocalPlayer：❌ nil")

        end

    end)

    if not ok then

        log(
            "②/③：❌ "
                .. safe(err)
        )

    end

end

--------------------------------------------------
-- ④ PlayerGui
--------------------------------------------------

do

    local ok, err = pcall(function()

        local player =
            game:GetService("Players").LocalPlayer

        if not player then
            error("LocalPlayer 为 nil")
        end

        local playerGui =
            player:FindFirstChildOfClass("PlayerGui")
            or player:WaitForChild("PlayerGui", 5)

        if playerGui then

            log("④ PlayerGui：✅")

        else

            log("④ PlayerGui：❌ 未找到")

        end

    end)

    if not ok then

        log(
            "④ PlayerGui：❌ "
                .. safe(err)
        )

    end

end

--------------------------------------------------
-- ⑤ HttpGet
--------------------------------------------------

local source

do

    local ok, result = pcall(function()

        return game:HttpGet(
            "https://raw.githubusercontent.com/LumiereSeren/UI/refs/heads/main/cyyWind.lua"
        )

    end)

    if ok
        and type(result) == "string"
        and #result > 0
    then

        source = result

        log(
            "⑤ HttpGet：✅ "
                .. tostring(#result)
                .. " 字符"
        )

    else

        log(
            "⑤ HttpGet：❌ "
                .. safe(result)
        )

    end

end

--------------------------------------------------
-- ⑥ loadstring
--------------------------------------------------

local loader

if source then

    local ok, result = pcall(function()

        if type(loadstring) ~= "function" then

            error("loadstring 不可用")

        end

        local fn, compileErr =
            loadstring(source)

        if type(fn) ~= "function" then

            error(
                compileErr
                    or "loadstring 编译失败"
            )

        end

        return fn

    end)

    if ok
        and type(result) == "function"
    then

        loader = result

        log("⑥ loadstring：✅")

    else

        log(
            "⑥ loadstring：❌ "
                .. safe(result)
        )

    end

else

    log(
        "⑥ loadstring：⏭️ HttpGet 失败，跳过"
    )

end

--------------------------------------------------
-- ⑦ WindUI
--------------------------------------------------

local WindUI

if loader then

    local ok, result =
        xpcall(
            function()

                return loader()

            end,

            function(err)

                if debug
                    and type(debug.traceback)
                        == "function"
                then

                    return debug.traceback(
                        tostring(err),
                        2
                    )

                end

                return tostring(err)

            end
        )

    if ok and result then

        WindUI = result

        log("⑦ WindUI：✅")

    else

        log(
            "⑦ WindUI：❌ "
                .. safe(result)
        )

    end

else

    log(
        "⑦ WindUI：⏭️ 前一步失败，跳过"
    )

end

--------------------------------------------------
-- ⑧ CreateWindow
--------------------------------------------------

if WindUI
    and type(WindUI.CreateWindow)
        == "function"
then

    local ok, result =
        xpcall(

            function()

                return WindUI:CreateWindow({

                    Title = "Aiove 启动诊断",

                    Icon = "zap",

                    Author = "AioveCN",

                    Size =
                        UDim2.fromOffset(
                            640,
                            460
                        ),

                    Theme = "Dark",

                    Transparent = true,

                    ScrollBarEnabled = true,

                })

            end,

            function(err)

                if debug
                    and type(debug.traceback)
                        == "function"
                then

                    return debug.traceback(
                        tostring(err),
                        2
                    )

                end

                return tostring(err)

            end
        )

    if ok and result then

        log("⑧ CreateWindow：✅")

        log("")

        log(
            "诊断完成：WindUI 可以创建窗口。"
        )

        log(
            "原 Aiove HUB 功能本次未启动。"
        )

        log(
            "请截图此诊断页面给我。"
        )

    else

        log(
            "⑧ CreateWindow：❌ "
                .. safe(result)
        )

    end

else

    log(
        "⑧ CreateWindow：⏭️ WindUI 不可用"
    )

end

warn("[Aiove诊断] 启动诊断完成")
