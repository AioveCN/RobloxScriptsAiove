-- AioveCN Hub
-- 说明：
-- 1. 使用原来的 WindUI 风格
-- 2. 本版本完全移除“圣奥里”模块及其功能
-- 3. “通用”功能来自公开通用脚本/工具项目的功能思路重新实现，不调用圣奥里源码
-- 4. 不包含 Anti-Cheat 绕过、检测规避、Aimbot、Silent Aim、Hitbox 等功能

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

-- WindUI：保持原来的 UI
local WindUI
do
    local ok, result = pcall(function()
        local source = game:HttpGet("https://raw.githubusercontent.com/LumiereSeren/UI/refs/heads/main/cyyWind.lua")
        local loader = loadstring(source)
        assert(type(loader) == "function", "WindUI loader 无效")
        return loader()
    end)
    if not ok or not result then
        warn("[AioveCN] WindUI 加载失败: " .. tostring(result))
        return
    end
    WindUI = result
end

local function getCharacter()
    local c = LocalPlayer.Character
    if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid")
    local r = c:FindFirstChild("HumanoidRootPart")
    if h and r then
        return c, h, r
    end
end

local function getHumanoid()
    local _, h = getCharacter()
    return h
end

local Window = WindUI:CreateWindow({
    Title = "欢迎您的使用",
    Icon = "zap",
    IconTransparency = 0.5,
    IconThemed = true,
    Author = "AioveCN",
    Folder = "AioveCNHub",
    Size = UDim2.fromOffset(640, 460),
    Transparent = true,
    Theme = "Dark",
    User = {
        Enabled = false,
        Callback = function() end,
        Anonymous = false
    },
    SideBarWidth = 200,
    ScrollBarEnabled = true,
    Background = "",
    BackgroundImageTransparency = 0.4
})

pcall(function()
    Window:EditOpenButton({
        Title = "AioveCN",
        Icon = "crown",
        CornerRadius = UDim.new(1, 16),
        StrokeThickness = 1.5
    })
end)

-- 时钟 + QQ：保留原来的时钟，不改动其逻辑
local TimeTag = Window:Tag({
    Title = "当前时间: 00:00:00",
    Icon = "clock",
    Color = Color3.fromHex("#FFFFFF"),
    Border = true
})

local QQTag = Window:Tag({
    Title = "QQ：3593722551",
    Color = Color3.fromHex("#FFFFFF"),
    Border = true
})

local clockLast = 0
RunService.Heartbeat:Connect(function()
    if tick() - clockLast >= 0.1 then
        pcall(function()
            TimeTag:SetTitle("当前时间: " .. os.date("!%H:%M:%S", os.time() + 28800))
        end)
        clockLast = tick()
    end
end)

-- =========================================================
-- 信息
-- =========================================================
local InfoTab = Window:Tab({
    Title = "信息",
    Icon = "info"
})

InfoTab:Paragraph({
    Title = "欢迎您的使用 Aiove HUB!",
    Desc = "本脚本仅供学习交流，请勿用于非法用途。"
})

InfoTab:Paragraph({
    Title = "反馈方式",
    Desc = "QQ：3593722551"
})

InfoTab:Paragraph({
    Title = "当前服务器",
    Desc = function()
        return tostring(game.JobId ~= "" and game.JobId or "未知")
    end
})

InfoTab:Paragraph({
    Title = "当前游戏",
    Desc = function()
        return tostring(game.PlaceId)
    end
})

InfoTab:Paragraph({
    Title = "说明",
    Desc = "本版本没有圣奥里功能；通用功能为独立通用工具。"
})

-- =========================================================
-- 通用
-- =========================================================
local GeneralTab = Window:Tab({
    Title = "通用",
    Icon = "settings"
})

GeneralTab:Paragraph({
    Title = "🏃 移动",
    Desc = "通用功能"
})
local movement = {
    speed = 16,
    speedEnabled = false,
    jumpPower = 50,
    jumpEnabled = false,
    infiniteJump = false,
    gravity = Workspace.Gravity,
    gravityEnabled = false,
    noclip = false,
    fly = false,
    flySpeed = 60,
    sprint = false,
    bhop = false,
    hipHeight = 2
}

local savedWalkSpeed = 16

local function applyMovement()
    local h = getHumanoid()
    if not h then return end
    if movement.speedEnabled then
        h.WalkSpeed = movement.speed
    elseif not movement.sprint then
        h.WalkSpeed = savedWalkSpeed
    end
    if movement.jumpEnabled then
        h.UseJumpPower = true
        h.JumpPower = movement.jumpPower
    end
    if movement.gravityEnabled then
        Workspace.Gravity = movement.gravity
    else
        Workspace.Gravity = 196.2
    end
    pcall(function()
        h.HipHeight = movement.hipHeight
    end)
end

GeneralTab:Toggle({
    Title = "WalkSpeed",
    Default = false,
    Callback = function(v)
        movement.speedEnabled = v
        local h = getHumanoid()
        if h then
            if v then
                savedWalkSpeed = h.WalkSpeed
                h.WalkSpeed = movement.speed
            else
                h.WalkSpeed = savedWalkSpeed
            end
        end
    end
})

GeneralTab:Slider({
    Title = "WalkSpeed 数值",
    Value = {Min = 16, Max = 200, Default = 16},
    Step = 1,
    Callback = function(v)
        movement.speed = tonumber(v) or 16
        if movement.speedEnabled then
            local h = getHumanoid()
            if h then h.WalkSpeed = movement.speed end
        end
    end
})

GeneralTab:Toggle({
    Title = "Sprint",
    Default = false,
    Callback = function(v)
        movement.sprint = v
        local h = getHumanoid()
        if h then
            if v then
                savedWalkSpeed = h.WalkSpeed
                h.WalkSpeed = math.max(24, movement.speed)
            else
                h.WalkSpeed = movement.speedEnabled and movement.speed or savedWalkSpeed
            end
        end
    end
})

GeneralTab:Toggle({
    Title = "跳跃控制",
    Default = false,
    Callback = function(v)
        movement.jumpEnabled = v
        applyMovement()
    end
})

GeneralTab:Slider({
    Title = "JumpPower",
    Value = {Min = 25, Max = 200, Default = 50},
    Step = 1,
    Callback = function(v)
        movement.jumpPower = tonumber(v) or 50
        applyMovement()
    end
})

GeneralTab:Toggle({
    Title = "无限跳跃",
    Default = false,
    Callback = function(v)
        movement.infiniteJump = v
    end
})

GeneralTab:Slider({
    Title = "Gravity",
    Value = {Min = 10, Max = 196, Default = 196},
    Step = 1,
    Callback = function(v)
        movement.gravity = tonumber(v) or 196
        if movement.gravityEnabled then
            Workspace.Gravity = movement.gravity
        end
    end
})

GeneralTab:Toggle({
    Title = "自定义 Gravity",
    Default = false,
    Callback = function(v)
        movement.gravityEnabled = v
        Workspace.Gravity = v and movement.gravity or 196.2
    end
})

GeneralTab:Slider({
    Title = "HipHeight",
    Value = {Min = 0, Max = 10, Default = 2},
    Step = 0.1,
    Callback = function(v)
        movement.hipHeight = tonumber(v) or 2
        applyMovement()
    end
})

GeneralTab:Toggle({
    Title = "Noclip",
    Default = false,
    Callback = function(v)
        movement.noclip = v
    end
})

GeneralTab:Toggle({
    Title = "Bhop",
    Default = false,
    Callback = function(v)
        movement.bhop = v
    end
})

GeneralTab:Paragraph({
    Title = "🕊 飞行",
    Desc = "通用功能"
})
local flyVelocity
local flyConnection

local function stopFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if flyVelocity then
        pcall(function() flyVelocity:Destroy() end)
        flyVelocity = nil
    end
end

local function startFly()
    stopFly()
    local _, _, root = getCharacter()
    if not root then return end

    flyVelocity = Instance.new("BodyVelocity")
    flyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    flyVelocity.Velocity = Vector3.zero
    flyVelocity.Parent = root

    flyConnection = RunService.RenderStepped:Connect(function()
        if not movement.fly or not root.Parent then
            stopFly()
            return
        end

        local cam = Workspace.CurrentCamera
        if not cam then return end

        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis end

        flyVelocity.Velocity = dir.Magnitude > 0 and dir.Unit * movement.flySpeed or Vector3.zero
    end)
end

GeneralTab:Toggle({
    Title = "Fly",
    Default = false,
    Callback = function(v)
        movement.fly = v
        if v then startFly() else stopFly() end
    end
})

GeneralTab:Slider({
    Title = "Fly Speed",
    Value = {Min = 10, Max = 200, Default = 60},
    Step = 1,
    Callback = function(v)
        movement.flySpeed = tonumber(v) or 60
    end
})

GeneralTab:Paragraph({
    Title = "👁 视觉",
    Desc = "通用功能"
})
local visual = {
    fullbright = false,
    noFog = false,
    fov = 70,
    infiniteZoom = false
}

local oldLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

local function applyVisual()
    if visual.fullbright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.OutdoorAmbient = Color3.new(1,1,1)
    else
        Lighting.Brightness = oldLighting.Brightness
        Lighting.ClockTime = oldLighting.ClockTime
        Lighting.GlobalShadows = oldLighting.GlobalShadows
        Lighting.Ambient = oldLighting.Ambient
        Lighting.OutdoorAmbient = oldLighting.OutdoorAmbient
    end

    if visual.noFog then
        Lighting.FogEnd = 100000
    else
        Lighting.FogEnd = oldLighting.FogEnd
    end

    local cam = Workspace.CurrentCamera
    if cam then
        cam.FieldOfView = visual.fov
        if visual.infiniteZoom then
            LocalPlayer.CameraMaxZoomDistance = 1000
        else
            LocalPlayer.CameraMaxZoomDistance = 128
        end
    end
end

GeneralTab:Toggle({
    Title = "FullBright",
    Default = false,
    Callback = function(v)
        visual.fullbright = v
        applyVisual()
    end
})

GeneralTab:Toggle({
    Title = "No Fog",
    Default = false,
    Callback = function(v)
        visual.noFog = v
        applyVisual()
    end
})

GeneralTab:Slider({
    Title = "FOV",
    Value = {Min = 40, Max = 120, Default = 70},
    Step = 1,
    Callback = function(v)
        visual.fov = tonumber(v) or 70
        applyVisual()
    end
})

GeneralTab:Toggle({
    Title = "Infinite Zoom",
    Default = false,
    Callback = function(v)
        visual.infiniteZoom = v
        applyVisual()
    end
})

GeneralTab:Paragraph({
    Title = "🔧 实用工具",
    Desc = "通用功能"
})
local utility = {
    instantInteract = false,
    antiAfk = false,
    autoClick = false,
    fpsBoost = false
}

local function applyPromptState()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            pcall(function()
                obj.HoldDuration = utility.instantInteract and 0 or obj:GetAttribute("AioveOriginalHold") or obj.HoldDuration
            end)
        end
    end
end

GeneralTab:Toggle({
    Title = "Instant Interact",
    Default = false,
    Callback = function(v)
        utility.instantInteract = v
        if v then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    if obj:GetAttribute("AioveOriginalHold") == nil then
                        obj:SetAttribute("AioveOriginalHold", obj.HoldDuration)
                    end
                    obj.HoldDuration = 0
                end
            end
        else
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    local old = obj:GetAttribute("AioveOriginalHold")
                    if old ~= nil then obj.HoldDuration = old end
                end
            end
        end
    end
})

GeneralTab:Toggle({
    Title = "Anti-AFK",
    Default = false,
    Callback = function(v)
        utility.antiAfk = v
    end
})

GeneralTab:Toggle({
    Title = "Auto Clicker",
    Default = false,
    Callback = function(v)
        utility.autoClick = v
    end
})

GeneralTab:Toggle({
    Title = "FPS Boost",
    Default = false,
    Callback = function(v)
        utility.fpsBoost = v
        if v then
            pcall(function()
                for _, obj in ipairs(Lighting:GetDescendants()) do
                    if obj:IsA("PostEffect") then
                        obj.Enabled = false
                    end
                end
                Workspace.Terrain.WaterWaveSize = 0
                Workspace.Terrain.WaterWaveSpeed = 0
                Workspace.Terrain.WaterReflectance = 0
                Workspace.Terrain.WaterTransparency = 1
            end)
        end
    end
})

GeneralTab:Button({
    Title = "重置角色",
    Callback = function()
        local h = getHumanoid()
        if h then h.Health = 0 end
    end
})

GeneralTab:Button({
    Title = "重新加入当前服务器",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
})

GeneralTab:Button({
    Title = "重新加入游戏",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})

GeneralTab:Button({
    Title = "复制 JobId",
    Callback = function()
        pcall(function()
            if setclipboard then setclipboard(game.JobId) end
        end)
    end
})

GeneralTab:Button({
    Title = "复制 PlaceId",
    Callback = function()
        pcall(function()
            if setclipboard then setclipboard(tostring(game.PlaceId)) end
        end)
    end
})

GeneralTab:Paragraph({
    Title = "📍 传送",
    Desc = "通用功能"
})
local selectedPlayerName = nil
local playerDropdown

local function getPlayerNames()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.Name)
        end
    end
    table.sort(list)
    return list
end

playerDropdown = GeneralTab:Dropdown({
    Title = "选择玩家",
    Values = getPlayerNames(),
    Value = getPlayerNames()[1],
    Callback = function(v)
        selectedPlayerName = v
    end
})

GeneralTab:Button({
    Title = "刷新玩家列表",
    Callback = function()
        pcall(function()
            playerDropdown:Refresh(getPlayerNames())
        end)
    end
})

GeneralTab:Button({
    Title = "传送到选中玩家",
    Callback = function()
        if not selectedPlayerName then return end
        local target = Players:FindFirstChild(selectedPlayerName)
        local _, _, root = getCharacter()
        local _, _, targetRoot = target and (function()
            local c = target.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            local r = c and c:FindFirstChild("HumanoidRootPart")
            return c, h, r
        end)() or nil
        if root and targetRoot then
            root.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
        end
    end
})

local savedPosition

GeneralTab:Button({
    Title = "保存当前位置",
    Callback = function()
        local _, _, root = getCharacter()
        if root then savedPosition = root.CFrame end
    end
})

GeneralTab:Button({
    Title = "返回保存位置",
    Callback = function()
        local _, _, root = getCharacter()
        if root and savedPosition then root.CFrame = savedPosition end
    end
})

GeneralTab:Paragraph({
    Title = "📊 状态",
    Desc = "通用功能"
})
local statsParagraph = GeneralTab:Paragraph({
    Title = "运行状态",
    Desc = "FPS: --   Ping: --"
})

local frames = 0
local lastFps = tick()
local fpsValue = 0

RunService.RenderStepped:Connect(function()
    frames += 1
    local now = tick()
    if now - lastFps >= 1 then
        fpsValue = frames
        frames = 0
        lastFps = now
    end
end)

task.spawn(function()
    while task.wait(1) do
        local ping = "--"
        pcall(function()
            ping = math.floor(LocalPlayer:GetNetworkPing() * 1000) .. " ms"
        end)
        pcall(function()
            statsParagraph:SetDesc("FPS: " .. tostring(fpsValue) .. "   Ping: " .. tostring(ping))
        end)
    end
end)

-- =========================================================
-- 通用循环
-- =========================================================
UserInputService.JumpRequest:Connect(function()
    if movement.infiniteJump then
        local h = getHumanoid()
        if h then
            h:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

RunService.Stepped:Connect(function()
    local c, h, root = getCharacter()
    if not c or not h then return end

    if movement.noclip then
        for _, obj in ipairs(c:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.CanCollide = false
            end
        end
    end

    if movement.bhop and h.MoveDirection.Magnitude > 0 then
        h.Jump = true
    end

    if movement.speedEnabled or movement.jumpEnabled or movement.gravityEnabled or movement.sprint then
        applyMovement()
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if utility.autoClick and input.UserInputType == Enum.UserInputType.MouseButton1 then
        -- 开启后由下面循环处理
    end
end)

task.spawn(function()
    while task.wait(0.08) do
        if utility.autoClick then
            pcall(function()
                if mouse1click then mouse1click() end
            end)
        end
    end
end)

LocalPlayer.Idled:Connect(function()
    if utility.antiAfk then
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
            task.wait(0.1)
            VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        end)
    end
end)

Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if movement.fly then
        startFly()
    end
    applyMovement()
end)

-- =========================================================
-- 其他服务器脚本：只加载 01～65，不加载 99 圣奥里
-- =========================================================
local OtherTab = Window:Tab({
    Title = "其他服务器脚本",
    Icon = "gamepad-2"
})

OtherTab:Paragraph({
    Title = "01～65 独立游戏脚本",
    Desc = "只读取 AioveCN/RobloxScriptsAiove 中 01～65 文件；99_Aiove_圣奥里.lua 不会加载。"
})

local scriptMap = {}
local selectedScript

local scriptDropdown = OtherTab:Dropdown({
    Title = "选择游戏脚本",
    Values = {"正在获取 01～65 文件..."},
    Value = "正在获取 01～65 文件...",
    Callback = function(v)
        selectedScript = scriptMap[v]
    end
})

local function fetchScriptList()
    local ok, body = pcall(function()
        return game:HttpGet("https://api.github.com/repos/AioveCN/RobloxScriptsAiove/git/trees/main?recursive=1")
    end)
    if not ok or not body then
        pcall(function()
            scriptDropdown:Refresh({"获取失败，请重试"})
        end)
        return
    end

    local decoded
    local okJson = pcall(function()
        decoded = HttpService:JSONDecode(body)
    end)
    if not okJson or type(decoded) ~= "table" or type(decoded.tree) ~= "table" then
        pcall(function()
            scriptDropdown:Refresh({"仓库列表解析失败"})
        end)
        return
    end

    local items = {}
    for _, item in ipairs(decoded.tree) do
        local path = tostring(item.path or "")
        local num = tonumber(path:match("^(%d+)_Aiove_"))
        if num and num >= 1 and num <= 65 and path:sub(-4) == ".lua" then
            local display = path:gsub("%.lua$", "")
            table.insert(items, {num = num, path = path, display = display})
        end
    end

    table.sort(items, function(a, b) return a.num < b.num end)

    local values = {}
    scriptMap = {}
    for _, item in ipairs(items) do
        table.insert(values, item.display)
        scriptMap[item.display] = item.path
    end

    if #values == 0 then
        values = {"没有找到 01～65 文件"}
    end

    pcall(function()
        scriptDropdown:Refresh(values)
    end)

    selectedScript = scriptMap[values[1]]
end

OtherTab:Button({
    Title = "刷新 01～65 脚本列表",
    Callback = function()
        task.spawn(fetchScriptList)
    end
})

OtherTab:Button({
    Title = "加载选中的脚本",
    Callback = function()
        if not selectedScript then return end
        local rawUrl = "https://raw.githubusercontent.com/AioveCN/RobloxScriptsAiove/main/" .. selectedScript
        local ok, err = pcall(function()
            local source = game:HttpGet(rawUrl)
            local fn = loadstring(source)
            assert(type(fn) == "function", "脚本不是有效 Lua")
            task.spawn(fn)
        end)
        if not ok then
            warn("[AioveCN] 加载失败: " .. tostring(err))
        end
    end
})

task.spawn(fetchScriptList)

-- 不检测游戏、不自动关闭、不加载圣奥里
print("[AioveCN] Hub 已启动：信息 / 通用 / 其他服务器脚本")
