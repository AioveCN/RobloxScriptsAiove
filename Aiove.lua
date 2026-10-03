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

-- 本地配置：记录启动次数，并可记住上次的主要设置。
local UIConfigFile = "AioveCNHub_UIConfig.json"
local UIConfig = {
    launchCount = 0,
    lastLaunch = "",
    rememberSettings = true,
    backgroundEnabled = false,
    background = "",
    theme = "Dark",
    settings = {}
}

local function loadUIConfig()
    if type(isfile) ~= "function" or type(readfile) ~= "function" then
        return false
    end
    local ok, data = pcall(function()
        if not isfile(UIConfigFile) then return nil end
        return HttpService:JSONDecode(readfile(UIConfigFile))
    end)
    if ok and type(data) == "table" then
        for k, v in pairs(data) do UIConfig[k] = v end
        if type(UIConfig.settings) ~= "table" then UIConfig.settings = {} end
        return true
    end
    return false
end

local function saveUIConfig()
    if type(writefile) ~= "function" then return false end
    return pcall(function()
        writefile(UIConfigFile, HttpService:JSONEncode(UIConfig))
    end)
end

local configPersistenceAvailable = loadUIConfig()
UIConfig.launchCount = (tonumber(UIConfig.launchCount) or 0) + 1
UIConfig.lastLaunch = os.date("%Y-%m-%d %H:%M:%S")
saveUIConfig()

local function getSavedSetting(key, default)
    if UIConfig.rememberSettings and type(UIConfig.settings) == "table" and UIConfig.settings[key] ~= nil then
        return UIConfig.settings[key]
    end
    return default
end

local function rememberSetting(key, value)
    if UIConfig.rememberSettings then
        UIConfig.settings[key] = value
        saveUIConfig()
    end
end
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


-- 启动缓冲：先显示“开始脚本”，点击后再创建完整 UI。
-- 这样 WindUI 和后续 01～65 列表有一点初始化时间，不会一上来就直接创建所有控件。
local function createMainWindow()
    task.wait(0.8)

    -- UI 随机背景图：只作用于 UI，不涉及游戏功能。
    local BackgroundPool = {
        "https://raw.githubusercontent.com/AioveCN/RobloxScriptsAiove/main/background/01.jpg",
        "https://raw.githubusercontent.com/AioveCN/RobloxScriptsAiove/main/background/02.jpg",
        "https://raw.githubusercontent.com/AioveCN/RobloxScriptsAiove/main/background/03.jpg",
        "https://raw.githubusercontent.com/AioveCN/RobloxScriptsAiove/main/background/04.jpg",
        "https://raw.githubusercontent.com/AioveCN/RobloxScriptsAiove/main/background/05.jpg",
        "https://raw.githubusercontent.com/AioveCN/RobloxScriptsAiove/main/background/06.jpg",
        "https://raw.githubusercontent.com/AioveCN/RobloxScriptsAiove/main/background/07.jpg",
        "https://raw.githubusercontent.com/AioveCN/RobloxScriptsAiove/main/background/08.png",
        "https://raw.githubusercontent.com/AioveCN/RobloxScriptsAiove/main/background/09.png"
    }

    local currentBackground = tostring(UIConfig.background or "")
    local backgroundEnabled = UIConfig.rememberSettings and UIConfig.backgroundEnabled == true

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
        WindUI:SetTheme(UIConfig.theme == "Light" and "Light" or "Dark")
    end)

    local function setRandomBackground(enabled)
        backgroundEnabled = enabled
        UIConfig.backgroundEnabled = enabled
        if not enabled then
            currentBackground = ""
            UIConfig.background = ""
            saveUIConfig()
            pcall(function()
                Window:SetBackground("")
            end)
            return
        end

        if #BackgroundPool == 0 then return end

        local nextBackground = BackgroundPool[math.random(1, #BackgroundPool)]
        if #BackgroundPool > 1 then
            local attempts = 0
            while nextBackground == currentBackground and attempts < 5 do
                nextBackground = BackgroundPool[math.random(1, #BackgroundPool)]
                attempts += 1
            end
        end

        currentBackground = nextBackground
        UIConfig.background = nextBackground
        saveUIConfig()

        pcall(function()
            Window:SetBackground(nextBackground)
        end)
    end

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
        Desc = tostring(game.JobId ~= "" and game.JobId or "未知")
    })

    InfoTab:Paragraph({
        Title = "当前游戏",
        Desc = tostring(game.PlaceId)
    })

    InfoTab:Paragraph({
        Title = "说明",
        Desc = "本版本没有圣奥里功能；通用功能为独立通用工具。"
    })

    InfoTab:Paragraph({
        Title = "🎨 UI 设置",
        Desc = "这里仅修改 Aiove HUB 的界面外观。"
    })

    InfoTab:Toggle({
        Title = "随机背景图",
        Default = false,
        Callback = function(v)
            setRandomBackground(v)
        end
    })

    InfoTab:Button({
        Title = "更换随机背景",
        Callback = function()
            if backgroundEnabled then
                setRandomBackground(true)
            else
                -- 即使开关关闭，也允许预览/切换；不会自动打开开关。
                local wasEnabled = backgroundEnabled
                setRandomBackground(true)
                backgroundEnabled = wasEnabled
            end
        end
    })

    InfoTab:Paragraph({
        Title = "📈 启动记录",
        Desc = "本地记录启动次数：" .. tostring(UIConfig.launchCount) .. " 次\n上次启动：" .. tostring(UIConfig.lastLaunch)
    })

    InfoTab:Paragraph({
        Title = "💾 设置记录",
        Desc = configPersistenceAvailable and "当前环境支持本地配置保存。开启后会记住上次的主要设置。" or "当前环境未提供文件保存接口，只能记录本次运行。"
    })

    InfoTab:Toggle({
        Title = "记住上次设置",
        Default = UIConfig.rememberSettings == true,
        Callback = function(v)
            UIConfig.rememberSettings = v
            saveUIConfig()
        end
    })

    InfoTab:Dropdown({
        Title = "UI 主题",
        Values = {"Dark", "Light"},
        Value = (UIConfig.theme == "Light" and "Light" or "Dark"),
        Callback = function(v)
            if v == "Light" or v == "Dark" then
                UIConfig.theme = v
                saveUIConfig()
                pcall(function() WindUI:SetTheme(v) end)
            end
        end
    })

    InfoTab:Button({
        Title = "保存当前设置",
        Callback = function()
            UIConfig.backgroundEnabled = backgroundEnabled
            UIConfig.background = currentBackground
            saveUIConfig()
        end
    })

    InfoTab:Button({
        Title = "恢复上次背景设置",
        Callback = function()
            if UIConfig.rememberSettings and UIConfig.backgroundEnabled and UIConfig.background ~= "" then
                backgroundEnabled = true
                currentBackground = UIConfig.background
                pcall(function() Window:SetBackground(UIConfig.background) end)
            else
                backgroundEnabled = false
                currentBackground = ""
                pcall(function() Window:SetBackground("") end)
            end
        end
    })

    InfoTab:Paragraph({
        Title = "背景说明",
        Desc = "背景图片使用公开图片 URL；如果图片地址不可用，UI 本身仍可正常运行。"
    })

    -- =========================================================
    -- 通用：使用可折叠 Section 分组，点击标题展开/收起
    -- =========================================================
    local GeneralTab = Window:Tab({
        Title = "通用",
        Icon = "settings"
    })

    GeneralTab:Paragraph({
        Title = "🧩 通用功能中心",
        Desc = "点击下面的功能块标题即可展开或收起；设置会尽量保持与原版本一致。"
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

    -- 🏃 跑步
    local RunSection = GeneralTab:Section({
        Title = "🏃 跑步",
        Icon = "person-standing",
        Opened = false,
        Box = true
    })

    RunSection:Toggle({
        Title = "WalkSpeed",
        Default = getSavedSetting("speedEnabled", false),
        Callback = function(v)
            movement.speedEnabled = v
            rememberSetting("speedEnabled", v)
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

    RunSection:Slider({
        Title = "WalkSpeed 数值",
        Value = {Min = 16, Max = 200, Default = tonumber(getSavedSetting("speed", 16)) or 16},
        Step = 1,
        Callback = function(v)
            movement.speed = tonumber(v) or 16
            rememberSetting("speed", movement.speed)
            if movement.speedEnabled then
                local h = getHumanoid()
                if h then h.WalkSpeed = movement.speed end
            end
        end
    })

    RunSection:Toggle({
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

    RunSection:Toggle({
        Title = "Noclip",
        Default = getSavedSetting("noclip", false),
        Callback = function(v)
            movement.noclip = v
            rememberSetting("noclip", v)
        end
    })

    -- 🦘 跳跃
    local JumpSection = GeneralTab:Section({
        Title = "🦘 跳跃",
        Icon = "arrow-big-up",
        Opened = false,
        Box = true
    })

    JumpSection:Toggle({
        Title = "跳跃控制",
        Default = false,
        Callback = function(v)
            movement.jumpEnabled = v
            applyMovement()
        end
    })

    JumpSection:Slider({
        Title = "JumpPower",
        Value = {Min = 25, Max = 200, Default = 50},
        Step = 1,
        Callback = function(v)
            movement.jumpPower = tonumber(v) or 50
            applyMovement()
        end
    })

    JumpSection:Toggle({
        Title = "无限跳跃",
        Default = getSavedSetting("infiniteJump", false),
        Callback = function(v)
            movement.infiniteJump = v
            rememberSetting("infiniteJump", v)
        end
    })

    JumpSection:Toggle({
        Title = "Bhop",
        Default = getSavedSetting("bhop", false),
        Callback = function(v)
            movement.bhop = v
            rememberSetting("bhop", v)
        end
    })

    JumpSection:Slider({
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

    JumpSection:Toggle({
        Title = "自定义 Gravity",
        Default = false,
        Callback = function(v)
            movement.gravityEnabled = v
            Workspace.Gravity = v and movement.gravity or 196.2
        end
    })

    -- 🕊️ 飞行
    local FlySection = GeneralTab:Section({
        Title = "🕊️ 飞行",
        Icon = "bird",
        Opened = false,
        Box = true
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

    FlySection:Toggle({
        Title = "Fly",
        Default = getSavedSetting("fly", false),
        Callback = function(v)
            movement.fly = v
            rememberSetting("fly", v)
            if v then startFly() else stopFly() end
        end
    })

    FlySection:Slider({
        Title = "Fly Speed",
        Value = {Min = 10, Max = 200, Default = 60},
        Step = 1,
        Callback = function(v)
            movement.flySpeed = tonumber(v) or 60
        end
    })

    -- 🚗 飞车：仅作用于自己当前驾驶/乘坐的 VehicleSeat
    local CarSection = GeneralTab:Section({
        Title = "🚗 飞车",
        Icon = "car",
        Opened = false,
        Box = true
    })

    local carFlight = {
        enabled = false,
        speed = 80,
        verticalSpeed = 55
    }
    local carVelocity
    local carGyro
    local carConnection

    local function getVehicleRoot()
        local character = LocalPlayer.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end

        local seat = humanoid.SeatPart
        if not seat or not seat:IsA("VehicleSeat") then return end

        local root = seat.AssemblyRootPart or seat
        return seat, root
    end

    local function stopCarFlight()
        if carConnection then
            carConnection:Disconnect()
            carConnection = nil
        end
        if carVelocity then
            pcall(function() carVelocity:Destroy() end)
            carVelocity = nil
        end
        if carGyro then
            pcall(function() carGyro:Destroy() end)
            carGyro = nil
        end
    end

    local function startCarFlight()
        stopCarFlight()

        local seat, root = getVehicleRoot()
        if not seat or not root then
            warn("[AioveCN] 飞车：请先坐进 VehicleSeat。")
            return
        end

        carVelocity = Instance.new("BodyVelocity")
        carVelocity.MaxForce = Vector3.new(1e7, 1e7, 1e7)
        carVelocity.P = 15000
        carVelocity.Velocity = Vector3.zero
        carVelocity.Parent = root

        carGyro = Instance.new("BodyGyro")
        carGyro.MaxTorque = Vector3.new(1e7, 1e7, 1e7)
        carGyro.P = 15000
        carGyro.D = 500
        carGyro.Parent = root

        carConnection = RunService.RenderStepped:Connect(function()
            if not carFlight.enabled then
                stopCarFlight()
                return
            end

            local currentSeat, currentRoot = getVehicleRoot()
            if not currentSeat or not currentRoot or currentRoot ~= root or not root.Parent then
                stopCarFlight()
                return
            end

            local cam = Workspace.CurrentCamera
            if not cam then return end

            local forward = cam.CFrame.LookVector
            local right = cam.CFrame.RightVector
            local throttle = tonumber(currentSeat.ThrottleFloat) or 0
            local steer = tonumber(currentSeat.SteerFloat) or 0

            local horizontal = forward * throttle
            if math.abs(steer) > 0.01 then
                horizontal += right * steer * 0.65
            end

            local vertical = 0
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                vertical += carFlight.verticalSpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                vertical -= carFlight.verticalSpeed
            end

            if horizontal.Magnitude > 1 then
                horizontal = horizontal.Unit * carFlight.speed
            end

            carVelocity.Velocity = Vector3.new(
                horizontal.X,
                vertical,
                horizontal.Z
            )

            local look = Vector3.new(forward.X, 0, forward.Z)
            if look.Magnitude > 0.05 then
                carGyro.CFrame = CFrame.lookAt(root.Position, root.Position + look.Unit)
            end
        end)
    end

    CarSection:Paragraph({
        Title = "使用说明",
        Desc = "先坐进 VehicleSeat，再开启飞车。W/S、方向控制由载具座椅提供；Space 上升、Shift 下降。"
    })

    CarSection:Toggle({
        Title = "飞车",
        Default = getSavedSetting("carFlight", false),
        Callback = function(v)
            carFlight.enabled = v
            rememberSetting("carFlight", v)
            if v then
                startCarFlight()
            else
                stopCarFlight()
            end
        end
    })

    CarSection:Slider({
        Title = "飞车速度",
        Value = {Min = 20, Max = 250, Default = 80},
        Step = 5,
        Callback = function(v)
            carFlight.speed = tonumber(v) or 80
        end
    })

    CarSection:Slider({
        Title = "升降速度",
        Value = {Min = 20, Max = 150, Default = 55},
        Step = 5,
        Callback = function(v)
            carFlight.verticalSpeed = tonumber(v) or 55
        end
    })

    -- 🧍 玩家功能 / 甩飞 / 黑洞 / 远离式隐身
    local PlayerSection = GeneralTab:Section({
        Title = "🧍 玩家功能",
        Icon = "user",
        Opened = false,
        Box = true
    })

    local selectedTargetName = nil
    local targetDropdown

    local function getTargetNames()
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                table.insert(list, p.Name)
            end
        end
        table.sort(list)
        return list
    end

    local function getTargetRoot(player)
        if not player or not player.Character then return end
        return player.Character:FindFirstChild("HumanoidRootPart")
    end

    targetDropdown = PlayerSection:Dropdown({
        Title = "选择目标玩家",
        Values = getTargetNames(),
        Value = getTargetNames()[1],
        Callback = function(v)
            selectedTargetName = v
        end
    })

    PlayerSection:Button({
        Title = "刷新目标列表",
        Callback = function()
            local names = getTargetNames()
            if names[1] then selectedTargetName = selectedTargetName or names[1] end
            pcall(function() targetDropdown:Refresh(names) end)
        end
    })

    local flingPower = 180
    PlayerSection:Slider({
        Title = "甩飞力度",
        Value = {Min = 50, Max = 500, Default = 180},
        Step = 10,
        Callback = function(v)
            flingPower = tonumber(v) or 180
        end
    })

    PlayerSection:Button({
        Title = "💨 甩飞选中玩家",
        Callback = function()
            if not selectedTargetName then return end
            local target = Players:FindFirstChild(selectedTargetName)
            local targetRoot = getTargetRoot(target)
            local _, _, myRoot = getCharacter()
            if not targetRoot or not myRoot then return end

            local delta = targetRoot.Position - myRoot.Position
            local dir = delta.Magnitude > 0.1 and delta.Unit or Vector3.new(0, 0, -1)
            pcall(function()
                targetRoot.AssemblyLinearVelocity = dir * flingPower + Vector3.new(0, flingPower * 0.65, 0)
                targetRoot.AssemblyAngularVelocity = Vector3.new(flingPower * 0.25, flingPower * 0.35, flingPower * 0.15)
            end)
        end
    })

    -- 🕳️ 黑洞：吸附附近未锚定物体；不会修改游戏服务端脚本或绕过检测。
    local blackHole = {
        enabled = false,
        radius = 35,
        strength = 85,
        part = nil,
        connection = nil
    }

    local function stopBlackHole()
        blackHole.enabled = false
        if blackHole.connection then
            blackHole.connection:Disconnect()
            blackHole.connection = nil
        end
        if blackHole.part then
            pcall(function() blackHole.part:Destroy() end)
            blackHole.part = nil
        end
    end

    local function startBlackHole()
        stopBlackHole()
        local _, _, root = getCharacter()
        if not root then return end

        local hole = Instance.new("Part")
        hole.Name = "AioveBlackHole"
        hole.Shape = Enum.PartType.Ball
        hole.Size = Vector3.new(3, 3, 3)
        hole.Material = Enum.Material.Neon
        hole.Transparency = 0.15
        hole.Color = Color3.fromRGB(35, 0, 55)
        hole.CanCollide = false
        hole.Anchored = true
        hole.CFrame = root.CFrame * CFrame.new(0, 0, -8)
        hole.Parent = Workspace
        blackHole.part = hole
        blackHole.enabled = true

        blackHole.connection = RunService.Heartbeat:Connect(function()
            if not blackHole.enabled or not hole.Parent then
                stopBlackHole()
                return
            end

            local _, _, currentRoot = getCharacter()
            if not currentRoot then
                stopBlackHole()
                return
            end

            hole.Position = currentRoot.Position + currentRoot.CFrame.LookVector * 8
            local center = hole.Position

            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not obj.Anchored and obj ~= hole then
                    local ownerCharacter = obj:FindFirstAncestorOfClass("Model")
                    local isSelf = ownerCharacter == LocalPlayer.Character
                    if not isSelf then
                        local offset = center - obj.Position
                        local distance = offset.Magnitude
                        if distance > 1 and distance <= blackHole.radius then
                            pcall(function()
                                local pull = offset.Unit * math.clamp(blackHole.strength * (1 - distance / blackHole.radius), 8, blackHole.strength)
                                obj.AssemblyLinearVelocity = obj.AssemblyLinearVelocity * 0.45 + pull
                            end)
                        end
                    end
                end
            end
        end)
    end

    PlayerSection:Toggle({
        Title = "🕳️ 黑洞",
        Default = false,
        Callback = function(v)
            if v then startBlackHole() else stopBlackHole() end
        end
    })

    PlayerSection:Slider({
        Title = "黑洞范围",
        Value = {Min = 10, Max = 100, Default = 35},
        Step = 5,
        Callback = function(v)
            blackHole.radius = tonumber(v) or 35
        end
    })

    PlayerSection:Slider({
        Title = "黑洞吸力",
        Value = {Min = 20, Max = 250, Default = 85},
        Step = 5,
        Callback = function(v)
            blackHole.strength = tonumber(v) or 85
        end
    })

    -- 👻 远离式隐身：把真实角色暂时移到远处，并在原地保留一个本地视觉替身。
    -- 这是实验性玩法功能，不用于绕过 Anti-Cheat / 检测系统。
    local remoteInvisible = {
        enabled = false,
        distance = 10000,
        originalCFrame = nil,
        decoy = nil,
        cameraType = nil,
        cameraSubject = nil
    }

    local function destroyInvisibleDecoy()
        if remoteInvisible.decoy then
            pcall(function() remoteInvisible.decoy:Destroy() end)
            remoteInvisible.decoy = nil
        end
    end

    local function createInvisibleDecoy(character, cframe)
        destroyInvisibleDecoy()
        local oldArchivable = character.Archivable
        local clone
        pcall(function()
            character.Archivable = true
            clone = character:Clone()
            character.Archivable = oldArchivable
        end)
        if not clone then
            pcall(function() character.Archivable = oldArchivable end)
            return
        end

        clone.Name = "AioveLocalInvisibleDecoy"
        clone.Parent = Workspace
        clone:PivotTo(cframe)

        for _, obj in ipairs(clone:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Anchored = true
                obj.CanCollide = false
                obj.CanTouch = false
                obj.CanQuery = false
            elseif obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                pcall(function() obj:Destroy() end)
            elseif obj:IsA("Humanoid") then
                obj.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            end
        end
        remoteInvisible.decoy = clone
    end

    local function stopRemoteInvisible()
        local _, _, root = getCharacter()
        if root and remoteInvisible.originalCFrame then
            pcall(function() root.CFrame = remoteInvisible.originalCFrame end)
        end
        local camera = Workspace.CurrentCamera
        if camera then
            pcall(function()
                camera.CameraType = remoteInvisible.cameraType or Enum.CameraType.Custom
                camera.CameraSubject = remoteInvisible.cameraSubject or getHumanoid()
            end)
        end
        destroyInvisibleDecoy()
        remoteInvisible.enabled = false
        remoteInvisible.originalCFrame = nil
    end

    local function startRemoteInvisible()
        stopRemoteInvisible()
        local character, humanoid, root = getCharacter()
        if not character or not humanoid or not root then return end

        remoteInvisible.originalCFrame = root.CFrame
        remoteInvisible.enabled = true
        createInvisibleDecoy(character, root.CFrame)

        local camera = Workspace.CurrentCamera
        if camera then
            remoteInvisible.cameraType = camera.CameraType
            remoteInvisible.cameraSubject = camera.CameraSubject
        end

        root.CFrame = root.CFrame + Vector3.new(remoteInvisible.distance, 0, remoteInvisible.distance)

        if remoteInvisible.decoy and camera then
            pcall(function()
                camera.CameraType = Enum.CameraType.Scriptable
                camera.CFrame = remoteInvisible.decoy:GetPivot() * CFrame.new(0, 5, 12) * CFrame.Angles(math.rad(-12), math.pi, 0)
            end)
        end
    end

    PlayerSection:Paragraph({
        Title = "👻 隐身说明",
        Desc = "远离式隐身会把真实角色暂时移到很远的位置，并尝试在原地保留一个仅本地可见的视觉替身；不同游戏可能会限制该效果。"
    })

    PlayerSection:Toggle({
        Title = "👻 远离式隐身",
        Default = false,
        Callback = function(v)
            if v then startRemoteInvisible() else stopRemoteInvisible() end
        end
    })

    PlayerSection:Slider({
        Title = "隐身距离",
        Value = {Min = 1000, Max = 30000, Default = 10000},
        Step = 500,
        Callback = function(v)
            remoteInvisible.distance = tonumber(v) or 10000
        end
    })

    -- 👁️ 视觉
    local VisualSection = GeneralTab:Section({
        Title = "👁️ 视觉",
        Icon = "eye",
        Opened = false,
        Box = true
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

    VisualSection:Toggle({
        Title = "FullBright",
        Default = getSavedSetting("fullbright", false),
        Callback = function(v)
            visual.fullbright = v
            rememberSetting("fullbright", v)
            applyVisual()
        end
    })

    VisualSection:Toggle({
        Title = "No Fog",
        Default = getSavedSetting("noFog", false),
        Callback = function(v)
            visual.noFog = v
            rememberSetting("noFog", v)
            applyVisual()
        end
    })

    VisualSection:Slider({
        Title = "FOV",
        Value = {Min = 40, Max = 120, Default = 70},
        Step = 1,
        Callback = function(v)
            visual.fov = tonumber(v) or 70
            applyVisual()
        end
    })

    VisualSection:Toggle({
        Title = "Infinite Zoom",
        Default = getSavedSetting("infiniteZoom", false),
        Callback = function(v)
            visual.infiniteZoom = v
            rememberSetting("infiniteZoom", v)
            applyVisual()
        end
    })

    -- 🛠️ 实用工具
    local UtilitySection = GeneralTab:Section({
        Title = "🛠️ 实用工具",
        Icon = "wrench",
        Opened = false,
        Box = true
    })

    local utility = {
        instantInteract = false,
        antiAfk = false,
        autoClick = false,
        fpsBoost = false
    }

    UtilitySection:Toggle({
        Title = "Instant Interact",
        Default = getSavedSetting("instantInteract", false),
        Callback = function(v)
            utility.instantInteract = v
            rememberSetting("instantInteract", v)
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

    UtilitySection:Toggle({
        Title = "Anti-AFK",
        Default = getSavedSetting("antiAfk", false),
        Callback = function(v)
            utility.antiAfk = v
            rememberSetting("antiAfk", v)
        end
    })

    UtilitySection:Toggle({
        Title = "Auto Clicker",
        Default = getSavedSetting("autoClick", false),
        Callback = function(v)
            utility.autoClick = v
            rememberSetting("autoClick", v)
        end
    })

    UtilitySection:Toggle({
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

    UtilitySection:Button({
        Title = "重置角色",
        Callback = function()
            local h = getHumanoid()
            if h then h.Health = 0 end
        end
    })

    UtilitySection:Button({
        Title = "复制 JobId",
        Callback = function()
            pcall(function()
                if setclipboard then setclipboard(game.JobId) end
            end)
        end
    })

    UtilitySection:Button({
        Title = "复制 PlaceId",
        Callback = function()
            pcall(function()
                if setclipboard then setclipboard(tostring(game.PlaceId)) end
            end)
        end
    })

    -- 🚀 传送
    local TeleportSection = GeneralTab:Section({
        Title = "🚀 传送",
        Icon = "map-pin",
        Opened = false,
        Box = true
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

    playerDropdown = TeleportSection:Dropdown({
        Title = "选择玩家",
        Values = getPlayerNames(),
        Value = getPlayerNames()[1],
        Callback = function(v)
            selectedPlayerName = v
        end
    })

    TeleportSection:Button({
        Title = "刷新玩家列表",
        Callback = function()
            pcall(function()
                playerDropdown:Refresh(getPlayerNames())
            end)
        end
    })

    TeleportSection:Button({
        Title = "传送到选中玩家",
        Callback = function()
            if not selectedPlayerName then return end
            local target = Players:FindFirstChild(selectedPlayerName)
            local _, _, root = getCharacter()
            local targetRoot

            if target and target.Character then
                targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
            end

            if root and targetRoot then
                root.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
            end
        end
    })

    local savedPosition

    TeleportSection:Button({
        Title = "保存当前位置",
        Callback = function()
            local _, _, root = getCharacter()
            if root then savedPosition = root.CFrame end
        end
    })

    TeleportSection:Button({
        Title = "返回保存位置",
        Callback = function()
            local _, _, root = getCharacter()
            if root and savedPosition then root.CFrame = savedPosition end
        end
    })

    -- 📡 网络 / 服务器
    local ServerSection = GeneralTab:Section({
        Title = "📡 网络 / 服务器",
        Icon = "radio",
        Opened = false,
        Box = true
    })

    ServerSection:Button({
        Title = "重新加入当前服务器",
        Callback = function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    })

    ServerSection:Button({
        Title = "重新加入游戏",
        Callback = function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    })

    local statsParagraph = ServerSection:Paragraph({
        Title = "运行状态",
        Desc = "FPS: --   Ping: --"
    })

    -- 📊 状态
    local StatusSection = GeneralTab:Section({
        Title = "📊 状态",
        Icon = "activity",
        Opened = false,
        Box = true
    })

    StatusSection:Paragraph({
        Title = "当前玩家",
        Desc = tostring(LocalPlayer.Name)
    })

    StatusSection:Paragraph({
        Title = "当前服务器",
        Desc = tostring(game.JobId ~= "" and game.JobId or "未知")
    })

    StatusSection:Paragraph({
        Title = "当前游戏",
        Desc = tostring(game.PlaceId)
    })

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
        local c, h = getCharacter()
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

    Players.LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        if movement.fly then
            startFly()
        end
        if carFlight.enabled then
            startCarFlight()
        end
        applyMovement()
    end)


ity.antiAfk then
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
        Icon = "sliders-h"
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
end

WindUI:Popup({
    Title = "AioveCN Hub",
    Icon = "sparkles",
    Content = "欢迎使用 AioveCN Hub\n正在准备通用功能与 01～65 脚本列表。",
    Buttons = {
        {
            Title = "开始脚本",
            Variant = "Primary",
            Callback = function()
                task.spawn(function()
                    local ok, err = pcall(createMainWindow)
                    if not ok then
                        warn("[AioveCN] 启动失败: " .. tostring(err))
                    end
                end)
            end
        }
    }
})

