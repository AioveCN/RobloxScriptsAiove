-- This file has been deobfuscated Luraph using Hurricane https://discord.com/invite/AbeurBzKXe
game:GetService("StarterGui"):SetCore("SendNotification",{ Title = "巨剑骑士", Text = "创作者：Aiove", Icon = "rbxthumb://type=Asset&id=5107182114&w=150&h=150" })

local function safeLoad(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not success then
        warn("加载失败: " .. url)
        return nil
    end
    return result
end

local Library = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/黑曜石主库.ui")
local ThemeManager = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/主题管理.ui")
local SaveManager = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/配置管理.ui")

if not Library then
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "错误",
        Text = "UI库加载失败",
        Duration = 5
    })
    return
end

local function Notify(msg)
    Library:Notify(msg, 3)
end

local desiredWalkSpeed = 16
task.spawn(function()
    while true do
        task.wait(0.1)
        local char = game.Players.LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                humanoid.WalkSpeed = desiredWalkSpeed
            end
        end
    end
end)

local function fireDataChange(obj, amount)
    pcall(function()
        game:GetService("ReplicatedStorage").CurRemotes.DataChange_Points:FireServer("ClickPoints", {
            Points = amount or 1,
            Obj = obj
        })
    end)
end

local autoHealth = false
local autoDamage = false
local autoCritical = false
local autoSpeed = false
local autoRebirth = false
local autoSwing = false
local antiAfkEnabled = false

local customHealthTarget = ""
local customHealthAmount = ""
local customDamageTarget = ""
local customDamageAmount = ""
local customCriticalTarget = ""
local customCriticalAmount = ""
local customSpeedTarget = ""
local customSpeedAmount = ""

local autoAddSpeed = 0.5

local lastAntiAfkTime = 0
local antiAfkInterval = 1140

local customHealthCurrent = 0
local customDamageCurrent = 0
local customCriticalCurrent = 0
local customSpeedCurrent = 0

task.spawn(function()
    while true do
        if autoHealth then 
            if customHealthTarget ~= "" and customHealthAmount ~= "" then
                local target = tonumber(customHealthTarget)
                local amount = tonumber(customHealthAmount)
                if target and amount and customHealthCurrent < target then
                    fireDataChange("GHealth", amount)
                    customHealthCurrent = customHealthCurrent + amount
                    if customHealthCurrent >= target then
                        autoHealth = false
                        Notify("生命值已达到目标值: " .. tostring(target))
                    end
                end
            else
                fireDataChange("GHealth", 1)
            end
        end
        if autoDamage then 
            if customDamageTarget ~= "" and customDamageAmount ~= "" then
                local target = tonumber(customDamageTarget)
                local amount = tonumber(customDamageAmount)
                if target and amount and customDamageCurrent < target then
                    fireDataChange("GDamage", amount)
                    customDamageCurrent = customDamageCurrent + amount
                    if customDamageCurrent >= target then
                        autoDamage = false
                        Notify("攻击力已达到目标值: " .. tostring(target))
                    end
                end
            else
                fireDataChange("GDamage", 1)
            end
        end
        if autoCritical then 
            if customCriticalTarget ~= "" and customCriticalAmount ~= "" then
                local target = tonumber(customCriticalTarget)
                local amount = tonumber(customCriticalAmount)
                if target and amount and customCriticalCurrent < target then
                    fireDataChange("GCriticalHit", amount)
                    customCriticalCurrent = customCriticalCurrent + amount
                    if customCriticalCurrent >= target then
                        autoCritical = false
                        Notify("暴击已达到目标值: " .. tostring(target))
                    end
                end
            else
                fireDataChange("GCriticalHit", 1)
            end
        end
        if autoSpeed then 
            if customSpeedTarget ~= "" and customSpeedAmount ~= "" then
                local target = tonumber(customSpeedTarget)
                local amount = tonumber(customSpeedAmount)
                if target and amount and customSpeedCurrent < target then
                    fireDataChange("GSpeed", amount)
                    customSpeedCurrent = customSpeedCurrent + amount
                    if customSpeedCurrent >= target then
                        autoSpeed = false
                        Notify("移速已达到目标值: " .. tostring(target))
                    end
                end
            else
                fireDataChange("GSpeed", 1)
            end
        end
        if autoRebirth then
            pcall(function()
                game:GetService("ReplicatedStorage").CurRemotes.DataChange_Rebirth:FireServer("rebirth")
            end)
        end
        if autoSwing then
            pcall(function()
                game:GetService("ReplicatedStorage").CurRemotes.MonsterEvent:FireServer("Pslash_")
            end)
        end
        if antiAfkEnabled and (tick() - lastAntiAfkTime >= antiAfkInterval) then
            lastAntiAfkTime = tick()
            pcall(function()
                local vim = game:GetService("VirtualInputManager")
                vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                task.wait(0.1)
                vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                local remotes = game:GetService("ReplicatedStorage").CurRemotes
                remotes.MonsterEvent:FireServer("HackCheck", "GPauto")
                local pet = workspace:FindFirstChild("ForScript") and workspace.ForScript:FindFirstChild("player") and workspace.ForScript.player:FindFirstChild("4818758418")
                if pet and pet:FindFirstChild("petFol") and pet.petFol:FindFirstChild("A5") then
                    remotes.PetEvent:FireServer("Blood_", pet.petFol.A5)
                end
                remotes.MonsterEvent:FireServer("Pslash_")
            end)
        end
        task.wait(autoAddSpeed)
    end
end)

local function loadFlightScript()
    local success, err = pcall(function()
        local main = Instance.new("ScreenGui")
        local Frame = Instance.new("Frame")
        local up = Instance.new("TextButton")
        local down = Instance.new("TextButton")
        local onof = Instance.new("TextButton")
        local TextLabel = Instance.new("TextLabel")
        local plus = Instance.new("TextButton")
        local speed = Instance.new("TextLabel")
        local mine = Instance.new("TextButton")
        local closebutton = Instance.new("TextButton")
        local mini = Instance.new("TextButton")
        local mini2 = Instance.new("TextButton")

        main.Name = "main"
        main.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        main.ResetOnSpawn = false

        Frame.Parent = main
        Frame.BackgroundColor3 = Color3.fromRGB(163,255,137)
        Frame.BorderColor3 = Color3.fromRGB(103,221,213)
        Frame.Position = UDim2.new(0.100320168,0,0.379746825,0)
        Frame.Size = UDim2.new(0,190,0,57)

        up.Name = "up"
        up.Parent = Frame
        up.BackgroundColor3 = Color3.fromRGB(79,255,152)
        up.Size = UDim2.new(0,44,0,28)
        up.Font = Enum.Font.SourceSans
        up.Text = "上升"
        up.TextColor3 = Color3.fromRGB(0,0,0)
        up.TextSize = 14

        down.Name = "down"
        down.Parent = Frame
        down.BackgroundColor3 = Color3.fromRGB(215,255,121)
        down.Position = UDim2.new(0,0,0.491228074,0)
        down.Size = UDim2.new(0,44,0,28)
        down.Font = Enum.Font.SourceSans
        down.Text = "下落"
        down.TextColor3 = Color3.fromRGB(0,0,0)
        down.TextSize = 14

        onof.Name = "onof"
        onof.Parent = Frame
        onof.BackgroundColor3 = Color3.fromRGB(255,249,74)
        onof.Position = UDim2.new(0.702823281,0,0.491228074,0)
        onof.Size = UDim2.new(0,56,0,28)
        onof.Font = Enum.Font.SourceSans
        onof.Text = "飞"
        onof.TextColor3 = Color3.fromRGB(0,0,0)
        onof.TextSize = 14

        TextLabel.Parent = Frame
        TextLabel.BackgroundColor3 = Color3.fromRGB(242,60,255)
        TextLabel.Position = UDim2.new(0.469327301,0,0,0)
        TextLabel.Size = UDim2.new(0,100,0,28)
        TextLabel.Font = Enum.Font.SourceSans
        TextLabel.Text = "Aiove"
        TextLabel.TextColor3 = Color3.fromRGB(0,0,0)
        TextLabel.TextScaled = true
        TextLabel.TextSize = 14
        TextLabel.TextWrapped = true

        plus.Name = "plus"
        plus.Parent = Frame
        plus.BackgroundColor3 = Color3.fromRGB(133,145,255)
        plus.Position = UDim2.new(0.231578946,0,0,0)
        plus.Size = UDim2.new(0,45,0,28)
        plus.Font = Enum.Font.SourceSans
        plus.Text = "+"
        plus.TextColor3 = Color3.fromRGB(0,0,0)
        plus.TextScaled = true
        plus.TextSize = 14
        plus.TextWrapped = true

        speed.Name = "speed"
        speed.Parent = Frame
        speed.BackgroundColor3 = Color3.fromRGB(255,85,0)
        speed.Position = UDim2.new(0.468421042,0,0.491228074,0)
        speed.Size = UDim2.new(0,44,0,28)
        speed.Font = Enum.Font.SourceSans
        speed.Text = "1"
        speed.TextColor3 = Color3.fromRGB(0,0,0)
        speed.TextScaled = true
        speed.TextSize = 14
        speed.TextWrapped = true

        mine.Name = "mine"
        mine.Parent = Frame
        mine.BackgroundColor3 = Color3.fromRGB(123,255,247)
        mine.Position = UDim2.new(0.231578946,0,0.491228074,0)
        mine.Size = UDim2.new(0,45,0,29)
        mine.Font = Enum.Font.SourceSans
        mine.Text = "-"
        mine.TextColor3 = Color3.fromRGB(0,0,0)
        mine.TextScaled = true
        mine.TextSize = 14
        mine.TextWrapped = true

        closebutton.Name = "Close"
        closebutton.Parent = Frame
        closebutton.BackgroundColor3 = Color3.fromRGB(225,25,0)
        closebutton.Font = Enum.Font.SourceSans
        closebutton.Size = UDim2.new(0,45,0,28)
        closebutton.Text = "X"
        closebutton.TextSize = 30
        closebutton.Position = UDim2.new(0,0,-1,27)

        mini.Name = "minimize"
        mini.Parent = Frame
        mini.BackgroundColor3 = Color3.fromRGB(192,150,230)
        mini.Font = Enum.Font.SourceSans
        mini.Size = UDim2.new(0,45,0,28)
        mini.Text = "-"
        mini.TextSize = 40
        mini.Position = UDim2.new(0,44,-1,27)

        mini2.Name = "minimize2"
        mini2.Parent = Frame
        mini2.BackgroundColor3 = Color3.fromRGB(192,150,230)
        mini2.Font = Enum.Font.SourceSans
        mini2.Size = UDim2.new(0,45,0,28)
        mini2.Text = "+"
        mini2.TextSize = 40
        mini2.Position = UDim2.new(0,44,0,30)
        mini2.Visible = false

        local speeds = 1
        local speaker = game:GetService("Players").LocalPlayer
        local chr = game.Players.LocalPlayer.Character
        local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
        local nowe = false

        Frame.Active = true
        Frame.Draggable = true

        closebutton.MouseButton1Click:Connect(function()
            main:Destroy()
        end)

        up.MouseButton1Click:Connect(function()
            if chr and chr:FindFirstChild("HumanoidRootPart") then
                chr.HumanoidRootPart.CFrame = chr.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            end
        end)

        down.MouseButton1Click:Connect(function()
            if chr and chr:FindFirstChild("HumanoidRootPart") then
                chr.HumanoidRootPart.CFrame = chr.HumanoidRootPart.CFrame + Vector3.new(0, -3, 0)
            end
        end)

        mini.MouseButton1Click:Connect(function()
            up.Visible = false
            down.Visible = false
            onof.Visible = false
            plus.Visible = false
            speed.Visible = false
            mine.Visible = false
            closebutton.Visible = false
            mini.Visible = false
            mini2.Visible = true
            Frame.Size = UDim2.new(0, 100, 0, 28)
            TextLabel.Position = UDim2.new(0, 0, 0, 0)
        end)

        mini2.MouseButton1Click:Connect(function()
            up.Visible = true
            down.Visible = true
            onof.Visible = true
            plus.Visible = true
            speed.Visible = true
            mine.Visible = true
            closebutton.Visible = true
            mini.Visible = true
            mini2.Visible = false
            Frame.Size = UDim2.new(0, 190, 0, 57)
            TextLabel.Position = UDim2.new(0.469327301, 0, 0, 0)
        end)

        plus.MouseButton1Click:Connect(function()
            speeds = speeds + 1
            speed.Text = tostring(speeds)
        end)

        mine.MouseButton1Click:Connect(function()
            if speeds > 1 then
                speeds = speeds - 1
                speed.Text = tostring(speeds)
            else
                speed.Text = "错误"
                task.wait(0.2)
                speed.Text = "1"
            end
        end)

        speaker.CharacterAdded:Connect(function(newChar)
            chr = newChar
            hum = chr:FindFirstChildOfClass("Humanoid")
        end)

        onof.MouseButton1Click:Connect(function()
            nowe = not nowe
            onof.Text = nowe and "飞" or "飞"
            if nowe then
                if hum then
                    for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
                        hum:SetStateEnabled(state, false)
                    end
                    hum:ChangeState(Enum.HumanoidStateType.Swimming)
                end
                if chr.Animate then
                    chr.Animate.Disabled = true
                end
                if hum then
                    for i,v in next,hum:GetPlayingAnimationTracks() do
                        v:AdjustSpeed(0)
                    end
                end
                task.spawn(function()
                    local runService = game:GetService("RunService")
                    while nowe and chr and hum do
                        runService.Heartbeat:Wait()
                        if hum.MoveDirection.Magnitude > 0 then
                            chr:TranslateBy(hum.MoveDirection * speeds)
                        end
                    end
                end)
                if hum.RigType == Enum.HumanoidRigType.R6 then
                    local plr = game.Players.LocalPlayer
                    local torso = plr.Character.Torso
                    local bg = Instance.new("BodyGyro", torso)
                    bg.P = 9e4
                    bg.maxTorque = Vector3.new(9e9,9e9,9e9)
                    bg.CFrame = torso.CFrame
                    local bv = Instance.new("BodyVelocity", torso)
                    bv.Velocity = Vector3.new(0,0,0)
                    bv.MaxForce = Vector3.new(9e9,9e9,9e9)
                    if nowe then
                        plr.Character.Humanoid.PlatformStand = true
                    end
                    while nowe and plr.Character.Humanoid.Health > 0 do
                        game:GetService("RunService").RenderStepped:Wait()
                        bg.CFrame = workspace.CurrentCamera.CoordinateFrame
                    end
                    bg:Destroy()
                    bv:Destroy()
                    plr.Character.Humanoid.PlatformStand = false
                    plr.Character.Animate.Disabled = false
                else
                    local plr = game.Players.LocalPlayer
                    local UpperTorso = plr.Character.UpperTorso
                    local bg = Instance.new("BodyGyro", UpperTorso)
                    bg.P = 9e4
                    bg.maxTorque = Vector3.new(9e9,9e9,9e9)
                    bg.CFrame = UpperTorso.CFrame
                    local bv = Instance.new("BodyVelocity", UpperTorso)
                    bv.Velocity = Vector3.new(0,0,0)
                    bv.MaxForce = Vector3.new(9e9,9e9,9e9)
                    if nowe then
                        plr.Character.Humanoid.PlatformStand = true
                    end
                    while nowe and plr.Character.Humanoid.Health > 0 do
                        task.wait()
                        bg.CFrame = workspace.CurrentCamera.CoordinateFrame
                    end
                    bg:Destroy()
                    bv:Destroy()
                    plr.Character.Humanoid.PlatformStand = false
                    plr.Character.Animate.Disabled = false
                end
            else
                if hum then
                    for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
                        hum:SetStateEnabled(state, true)
                    end
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end
                if chr.Animate then
                    chr.Animate.Disabled = false
                end
            end
        end)
    end)

    if success then
        Notify("飞行脚本已加载")
    else
        Notify("飞行脚本出错：" .. tostring(err))
    end
end

local teleportMenuGui = nil
local function CloseTeleportMenu()
    if teleportMenuGui then
        teleportMenuGui:Destroy()
        teleportMenuGui = nil
    end
end

local WorldConfig = {
    { Name = "皇城", CFrame = CFrame.new(0, 24.69, 167.62) },
    { Name = "前哨站", CFrame = CFrame.new(12090.74, 7.75, 125.76) },
    { Name = "部落", CFrame = CFrame.new(-12904.61, 4.27, 172.02) },
    { Name = "冰川峡谷", CFrame = CFrame.new(-26069.89, 4.34, 167.54) },
    { Name = "黑暗堡垒", CFrame = CFrame.new(23111.76, -16.92, 57.33) },
    { Name = "桃园", CFrame = CFrame.new(32178.70, 7.75, 97.84) },
    { Name = "乱葬岗", CFrame = CFrame.new(-38958.29, 4.45, 162.08) },
    { Name = "地狱", CFrame = CFrame.new(-50303.39, 5.30, 109.30) },
    { Name = "天堂", CFrame = CFrame.new(36673.71, 19.49, 147.81) },
    { Name = "沙堡", CFrame = CFrame.new(-12898.58, 5.47, 19520.76) },
}

local function CreateTeleportMenu()
    if teleportMenuGui then return end
    teleportMenuGui = Instance.new("ScreenGui")
    teleportMenuGui.Name = "TeleportMenuGui"
    teleportMenuGui.Parent = game.Players.LocalPlayer.PlayerGui
    teleportMenuGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local menuFrame = Instance.new("Frame")
    menuFrame.Parent = teleportMenuGui
    menuFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    menuFrame.BackgroundTransparency = 0.15
    menuFrame.BorderSizePixel = 0
    menuFrame.Size = UDim2.new(0, 400, 0, 500)
    menuFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    menuFrame.Active = true
    menuFrame.Draggable = true

    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, 12)
    menuCorner.Parent = menuFrame

    local menuStroke = Instance.new("UIStroke")
    menuStroke.Thickness = 2
    menuStroke.Color = Color3.fromRGB(100, 100, 100)
    menuStroke.Parent = menuFrame

    local titleBar = Instance.new("Frame")
    titleBar.Parent = menuFrame
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = titleBar
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.Text = "世界传送"
    titleLabel.TextColor3 = Color3.new(1,1,1)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.ArialBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local closeMenuBtn = Instance.new("TextButton")
    closeMenuBtn.Parent = titleBar
    closeMenuBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeMenuBtn.Size = UDim2.new(0, 30, 0, 30)
    closeMenuBtn.Position = UDim2.new(1, -40, 0, 5)
    closeMenuBtn.Text = "X"
    closeMenuBtn.TextColor3 = Color3.new(1,1,1)
    closeMenuBtn.TextSize = 18
    closeMenuBtn.Font = Enum.Font.ArialBold

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeMenuBtn
    closeMenuBtn.MouseButton1Click:Connect(CloseTeleportMenu)

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Parent = menuFrame
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.Size = UDim2.new(1, -20, 1, -60)
    scrollFrame.Position = UDim2.new(0, 10, 0, 50)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.BorderSizePixel = 0

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Parent = scrollFrame
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.Padding = UDim.new(0, 8)

    for i = 1, 20 do
        local btn = Instance.new("TextButton")
        btn.Parent = scrollFrame
        btn.Size = UDim2.new(1, -20, 0, 45)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.TextSize = 16
        btn.Font = Enum.Font.ArialBold

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn

        local config = WorldConfig[i]
        if config then
            btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            btn.Text = config.Name .. " (" .. i .. ")"
            btn.MouseButton1Click:Connect(function()
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = config.CFrame
                    Notify("已传送至 " .. config.Name)
                else
                    Notify("角色未准备好")
                end
                CloseTeleportMenu()
            end)
        else
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btn.Text = "世界 " .. i .. " (未探索)"
            btn.MouseButton1Click:Connect(function()
                Notify("该地图作者都还没到（刚回坑）")
            end)
        end
    end

    local function UpdateCanvas()
        local totalHeight = 0
        for _, btn in pairs(scrollFrame:GetChildren()) do
            if btn:IsA("TextButton") then
                totalHeight = totalHeight + btn.AbsoluteSize.Y + uiListLayout.Padding.Offset
            end
        end
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 10)
    end

    task.wait(0.1)
    UpdateCanvas()
    scrollFrame.ChildAdded:Connect(UpdateCanvas)
    scrollFrame.ChildRemoved:Connect(UpdateCanvas)
end

local teleportToggleBtn = nil
local function CreateTeleportToggleButton()
    if teleportToggleBtn and teleportToggleBtn.Parent then
        teleportToggleBtn:Destroy()
    end
    local toggleScreenGui = Instance.new("ScreenGui")
    toggleScreenGui.Name = "TeleportToggleGui"
    toggleScreenGui.Parent = game.Players.LocalPlayer.PlayerGui
    toggleScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    teleportToggleBtn = Instance.new("TextButton")
    teleportToggleBtn.Parent = toggleScreenGui
    teleportToggleBtn.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
    teleportToggleBtn.Size = UDim2.new(0, 140, 0, 50)
    teleportToggleBtn.Position = UDim2.new(0.85, 0, 0.5, 0)
    teleportToggleBtn.Text = "传送到指定的地图"
    teleportToggleBtn.TextColor3 = Color3.new(1,1,1)
    teleportToggleBtn.TextSize = 18
    teleportToggleBtn.Font = Enum.Font.ArialBold

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = teleportToggleBtn

    local dragging = false
    local dragInput = nil
    local dragStartPos = nil
    local btnStartPos = nil

    teleportToggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if not dragging and not dragInput then
                dragging = true
                dragInput = input
                dragStartPos = input.Position
                btnStartPos = teleportToggleBtn.Position
            end
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStartPos
            teleportToggleBtn.Position = UDim2.new(
                btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X,
                btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y
            )
        end
    end)

    teleportToggleBtn.InputEnded:Connect(function(input)
        if input == dragInput then
            dragging = false
            dragInput = nil
        end
    end)

    teleportToggleBtn.MouseButton1Click:Connect(function()
        if teleportMenuGui then
            CloseTeleportMenu()
        else
            CreateTeleportMenu()
        end
    end)
end

local Window = Library:CreateWindow({
    Title = "巨剑骑士",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

local Tabs = {
    Notify = Window:AddTab("通知", "info"),
    Main = Window:AddTab("主要", "sword"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notify:AddLeftGroupbox("公告")
NoticeGroup:AddLabel("Aiove持续更新此脚本")
NoticeGroup:AddLabel("QQ3999698324")

local LeftGroup = Tabs.Main:AddLeftGroupbox("功能")
LeftGroup:AddSlider("WalkSpeed", {
    Text = "移动速度 (防回拉)",
    Default = 16,
    Min = 16,
    Max = 100,
    Rounding = 0,
    Suffix = " studs",
    Callback = function(val)
        desiredWalkSpeed = val
        local char = game.Players.LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = val
            end
        end
    end
})

LeftGroup:AddButton({
    Text = "召唤飞行脚本",
    Func = loadFlightScript,
    DoubleClick = false
})

LeftGroup:AddButton({
    Text = "召唤传送按钮",
    Func = function()
        CreateTeleportToggleButton()
        Notify("紫色传送按钮已出现在屏幕右中央")
    end,
    DoubleClick = false
})

LeftGroup:AddToggle("AutoSwing", {
    Text = "自动挥剑",
    Default = false,
    Callback = function(v)
        autoSwing = v
    end
})

LeftGroup:AddToggle("AutoRebirth", {
    Text = "自动重生",
    Default = false,
    Callback = function(v)
        autoRebirth = v
    end
})

LeftGroup:AddSlider("AutoAddSpeed", {
    Text = "自动增加速度 (秒)",
    Default = 0.5,
    Min = 0.1,
    Max = 5,
    Rounding = 1,
    Suffix = " 秒",
    Callback = function(val)
        autoAddSpeed = val
    end
})

local RightGroup = Tabs.Main:AddRightGroupbox("属性自动化")

RightGroup:AddToggle("AutoHealth", {
    Text = "自动生命",
    Default = false,
    Callback = function(v)
        autoHealth = v
        if v then
            customHealthCurrent = 0
        end
    end
})

RightGroup:AddInput("HealthTarget", {
    Text = "生命目标值 (留空=默认+1)",
    Default = "",
    Numeric = true,
    Finished = true,
    Placeholder = "输入目标值...",
    Callback = function(val)
        customHealthTarget = val
    end
})

RightGroup:AddInput("HealthAmount", {
    Text = "生命每次增加值 (留空=默认+1)",
    Default = "",
    Numeric = true,
    Finished = true,
    Placeholder = "输入每次增加量...",
    Callback = function(val)
        customHealthAmount = val
    end
})

RightGroup:AddToggle("AutoDamage", {
    Text = "自动攻击",
    Default = false,
    Callback = function(v)
        autoDamage = v
        if v then
            customDamageCurrent = 0
        end
    end
})

RightGroup:AddInput("DamageTarget", {
    Text = "攻击目标值 (留空=默认+1)",
    Default = "",
    Numeric = true,
    Finished = true,
    Placeholder = "输入目标值...",
    Callback = function(val)
        customDamageTarget = val
    end
})

RightGroup:AddInput("DamageAmount", {
    Text = "攻击每次增加值 (留空=默认+1)",
    Default = "",
    Numeric = true,
    Finished = true,
    Placeholder = "输入每次增加量...",
    Callback = function(val)
        customDamageAmount = val
    end
})

RightGroup:AddToggle("AutoCritical", {
    Text = "自动暴击",
    Default = false,
    Callback = function(v)
        autoCritical = v
        if v then
            customCriticalCurrent = 0
        end
    end
})

RightGroup:AddInput("CriticalTarget", {
    Text = "暴击目标值 (留空=默认+1)",
    Default = "",
    Numeric = true,
    Finished = true,
    Placeholder = "输入目标值...",
    Callback = function(val)
        customCriticalTarget = val
    end
})

RightGroup:AddInput("CriticalAmount", {
    Text = "暴击每次增加值 (留空=默认+1)",
    Default = "",
    Numeric = true,
    Finished = true,
    Placeholder = "输入每次增加量...",
    Callback = function(val)
        customCriticalAmount = val
    end
})

RightGroup:AddToggle("AutoSpeed", {
    Text = "自动移速",
    Default = false,
    Callback = function(v)
        autoSpeed = v
        if v then
            customSpeedCurrent = 0
        end
    end
})

RightGroup:AddInput("SpeedTarget", {
    Text = "移速目标值 (留空=默认+1)",
    Default = "",
    Numeric = true,
    Finished = true,
    Placeholder = "输入目标值...",
    Callback = function(val)
        customSpeedTarget = val
    end
})

RightGroup:AddInput("SpeedAmount", {
    Text = "移速每次增加值 (留空=默认+1)",
    Default = "",
    Numeric = true,
    Finished = true,
    Placeholder = "输入每次增加量...",
    Callback = function(val)
        customSpeedAmount = val
    end
})

RightGroup:AddToggle("AntiAfk", {
    Text = "防挂机 (19分钟)",
    Default = false,
    Callback = function(v)
        antiAfkEnabled = v
        if v then
            lastAntiAfkTime = 0
        end
    end
})

RightGroup:AddButton({
    Text = "一键启动所有",
    Func = function()
        autoHealth = true
        autoDamage = true
        autoCritical = true
        autoSpeed = true
        customHealthCurrent = 0
        customDamageCurrent = 0
        customCriticalCurrent = 0
        customSpeedCurrent = 0
        Notify("所有功能已启动")
    end,
    DoubleClick = false
})

RightGroup:AddButton({
    Text = "一键关闭所有",
    Func = function()
        autoHealth = false
        autoDamage = false
        autoCritical = false
        autoSpeed = false
        Notify("所有功能已关闭")
    end,
    DoubleClick = false
})

local SettingsGroup = Tabs.Settings:AddLeftGroupbox("菜单")
SettingsGroup:AddButton("卸载脚本", function()
    Library:Unload()
end)

SettingsGroup:AddLabel("菜单快捷键"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift",
    NoUI = true,
    Text = "Menu keybind"
})

Library.ToggleKeybind = Library.Options.MenuKeybind

if ThemeManager then
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("GiantSwordKnight")
    ThemeManager:ApplyToTab(Tabs.Settings)
end

if SaveManager then
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetFolder("GiantSwordKnight")
    SaveManager:BuildConfigSection(Tabs.Settings)
end

Notify("巨剑骑士脚本已就绪")
