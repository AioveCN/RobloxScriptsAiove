-- This file has been deobfuscated Luraph using Hurricane https://discord.com/invite/AbeurBzKXe
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
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "错误",
        Text = "UI 库加载失败，请检查网络或脚本资源",
        Duration = 5,
    })
    return
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera

getgenv().QW = getgenv().QW or {
    Speed = 16,
    SpeedEnabled = false,
    FlyEnabled = false,
    NoclipEnabled = false,
    AdminPanelEnabled = false,
    SharkESPEnabled = false,
    SuckSharkEnabled = false,
    SuckAllEnabled = false,
    ESPThread = nil,
    SuckSharkThread = nil,
    SuckAllThread = nil,
    ESPObjects = {},
}

local function getCharacter()
    local success, result = pcall(function() return LocalPlayer.Character end)
    return success and result or nil
end

local function getHumanoid()
    local success, result = pcall(function()
        local char = getCharacter()
        return char and char:FindFirstChildOfClass("Humanoid")
    end)
    return success and result or nil
end

local function getRootPart()
    local success, result = pcall(function()
        local char = getCharacter()
        return char and char:FindFirstChild("HumanoidRootPart")
    end)
    return success and result or nil
end

local function getSharkObjects()
    local sharks = {}
    pcall(function()
        local sharkFolder = Workspace:FindFirstChild("Sharks")
        if sharkFolder then
            for _, child in ipairs(sharkFolder:GetChildren()) do
                if child:IsA("Model") or child:IsA("Part") or child:IsA("MeshPart") then
                    table.insert(sharks, child)
                end
            end
        end
    end)
    return sharks
end

local function getSharkPlayers()
    local sharks = {}
    pcall(function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local team = plr.Team
                if team and tostring(team):lower():find("shark") then
                    table.insert(sharks, plr)
                end
            end
        end
    end)
    return sharks
end

local function getAllPlayers()
    local allPlayers = {}
    pcall(function()
        local sharkPlayers = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            local team = plr.Team
            if team and tostring(team):lower():find("shark") then
                sharkPlayers[plr] = true
            end
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and not sharkPlayers[plr] then
                table.insert(allPlayers, plr)
            end
        end
    end)
    return allPlayers
end

local espEnabled = false
local espBillboards = {}
local espConnections = {}

local function cleanupESP(player)
    if espConnections[player] then
        for _, conn in ipairs(espConnections[player]) do
            pcall(function() conn:Disconnect() end)
        end
        espConnections[player] = nil
    end
    local char = player.Character
    if char then
        pcall(function()
            local hl = char:FindFirstChild("EspHighlight")
            if hl then hl:Destroy() end
        end)
        pcall(function()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bb = hrp:FindFirstChild("EspBillboard")
                if bb then bb:Destroy() end
            end
        end)
    end
    espBillboards[player] = nil
end

local function createESP(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    pcall(function()
        local hl = char:FindFirstChild("EspHighlight")
        if hl then hl:Destroy() end
    end)
    pcall(function()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bb = hrp:FindFirstChild("EspBillboard")
            if bb then bb:Destroy() end
        end
    end)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        task.spawn(function()
            local success = pcall(function() char:WaitForChild("HumanoidRootPart", 5) end)
            if success and espEnabled and player.Parent then
                createESP(player)
            end
        end)
        return
    end
    local highlight = Instance.new("Highlight")
    highlight.Name = "EspHighlight"
    highlight.Parent = char
    highlight.FillTransparency = 0.5
    highlight.FillColor = Color3.fromRGB(255, 255, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "EspBillboard"
    billboard.Parent = hrp
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Parent = billboard
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.SourceSansBold
    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "DistLabel"
    distLabel.Parent = billboard
    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0m"
    distLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    distLabel.TextStrokeTransparency = 0
    distLabel.TextSize = 12
    distLabel.Font = Enum.Font.SourceSans
    espBillboards[player] = billboard
end

local function setupPlayerESP(player)
    if player == LocalPlayer then return end
    if espConnections[player] then
        for _, conn in ipairs(espConnections[player]) do
            pcall(function() conn:Disconnect() end)
        end
    end
    espConnections[player] = {}
    table.insert(espConnections[player], player.CharacterAdded:Connect(function(char)
        task.spawn(function()
            pcall(function() char:WaitForChild("HumanoidRootPart", 5) end)
            if espEnabled then
                task.wait(0.1)
                createESP(player)
            end
        end)
    end))
    table.insert(espConnections[player], player.CharacterRemoving:Connect(function()
        cleanupESP(player)
    end))
    if player.Character and espEnabled then
        createESP(player)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayerESP(player)
end

Players.PlayerAdded:Connect(function(player)
    setupPlayerESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    cleanupESP(player)
end)

RunService.RenderStepped:Connect(function()
    if not espEnabled then return end
    local myChar = LocalPlayer.Character
    local myPos = myChar and myChar:FindFirstChild("HumanoidRootPart") and myChar.HumanoidRootPart.Position
    for player, billboard in pairs(espBillboards) do
        if player.Parent and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and billboard and billboard.Parent then
            local distLabel = billboard:FindFirstChild("DistLabel")
            if distLabel and myPos then
                local dist = (player.Character.HumanoidRootPart.Position - myPos).Magnitude
                distLabel.Text = string.format("%.0fm", dist)
            end
        else
            espBillboards[player] = nil
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if not espEnabled then continue end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local char = player.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hasHighlight = char:FindFirstChild("EspHighlight")
                local hasBillboard = hrp and hrp:FindFirstChild("EspBillboard")
                if not hasHighlight or not hasBillboard then
                    pcall(function() createESP(player) end)
                end
            end
        end
    end
end)

local function clearSharkESP()
    for obj, instances in pairs(getgenv().QW.ESPObjects) do
        pcall(function()
            for _, inst in ipairs(instances) do
                if inst and inst.Parent then inst:Destroy() end
            end
        end)
    end
    getgenv().QW.ESPObjects = {}
end

local function createSharkESP(obj, text)
    if not obj or getgenv().QW.ESPObjects[obj] then return end
    local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
    if not hrp then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "EspHighlight"
    highlight.Adornee = obj
    highlight.FillTransparency = 0.5
    highlight.FillColor = Color3.fromRGB(255, 255, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = obj
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "EspBillboard"
    billboard.Parent = hrp
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Parent = billboard
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = text
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.SourceSansBold
    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "DistLabel"
    distLabel.Parent = billboard
    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0m"
    distLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    distLabel.TextStrokeTransparency = 0
    distLabel.TextSize = 12
    distLabel.Font = Enum.Font.SourceSans
    getgenv().QW.ESPObjects[obj] = {highlight, billboard}
end

local function sharkESPLoop()
    pcall(function()
        for obj in pairs(getgenv().QW.ESPObjects) do
            if not obj or not obj.Parent then
                getgenv().QW.ESPObjects[obj] = nil
            end
        end
        local sharkPlayers = getSharkPlayers()
        for _, plr in ipairs(sharkPlayers) do
            if plr.Character then
                createSharkESP(plr.Character, "🦈 " .. plr.Name)
            end
        end
        local sharkObjects = getSharkObjects()
        for _, shark in ipairs(sharkObjects) do
            createSharkESP(shark, "🦈 鲨鱼")
        end
    end)
end

RunService.RenderStepped:Connect(function()
    if not getgenv().QW.SharkESPEnabled then return end
    local myChar = LocalPlayer.Character
    local myPos = myChar and myChar:FindFirstChild("HumanoidRootPart") and myChar.HumanoidRootPart.Position
    for obj, instances in pairs(getgenv().QW.ESPObjects) do
        if obj and obj.Parent then
            local billboard = instances[2]
            if billboard and billboard.Parent then
                local distLabel = billboard:FindFirstChild("DistLabel")
                if distLabel and myPos then
                    local objPos = nil
                    if obj:IsA("Model") then
                        local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
                        if hrp then objPos = hrp.Position end
                    elseif obj:IsA("BasePart") then
                        objPos = obj.Position
                    end
                    if objPos then
                        local dist = (objPos - myPos).Magnitude
                        distLabel.Text = string.format("%.0fm", dist)
                    end
                end
            end
        end
    end
end)

local speedAntiPull = nil

local function startSpeedAntiPull()
    if speedAntiPull then speedAntiPull:Disconnect() end
    speedAntiPull = RunService.Heartbeat:Connect(function()
        local hum = getHumanoid()
        if hum and getgenv().QW.SpeedEnabled then
            if hum.WalkSpeed ~= getgenv().QW.Speed then
                hum.WalkSpeed = getgenv().QW.Speed
            end
        end
    end)
end

local function stopSpeedAntiPull()
    if speedAntiPull then speedAntiPull:Disconnect() end
    speedAntiPull = nil
end

local flyActive = false
local flyConn, rotConn
local flyBodyVel

local function startFlyInternal()
    local root = getRootPart()
    if not root then return end
    flyBodyVel = Instance.new("BodyVelocity")
    flyBodyVel.Name = "QW_FlyVelocity"
    flyBodyVel.Velocity = Vector3.zero
    flyBodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    flyBodyVel.P = 1250
    flyBodyVel.Parent = root
    flyConn = RunService.RenderStepped:Connect(function()
        local cam = Workspace.CurrentCamera
        if not cam then return end
        local camLook = cam.CFrame.LookVector
        flyBodyVel.Velocity = camLook * 50
    end)
    rotConn = RunService.RenderStepped:Connect(function()
        if root and root.Parent then
            local cam = Workspace.CurrentCamera
            if not cam then return end
            root.CFrame = CFrame.new(root.Position, root.Position + cam.CFrame.LookVector)
        end
    end)
end

local function stopFlyInternal()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if rotConn then rotConn:Disconnect(); rotConn = nil end
    if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
end

LocalPlayer.CharacterAdded:Connect(function()
    if flyActive then
        task.wait(1)
        startFlyInternal()
    end
end)

local noclipConnection = nil

local function startNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    noclipConnection = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function stopNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    noclipConnection = nil
end

local InfiniteJumpEnabled = false

UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        local char = LocalPlayer.Character
        if char then
            local HRP = char:FindFirstChild("HumanoidRootPart")
            if HRP then
                HRP.Velocity = Vector3.new(HRP.Velocity.X, 50, HRP.Velocity.Z)
            end
        end
    end
end)

local function powerfulFling(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then
        Library:Notify({ Title = "提示", Description = "目标玩家无效", Time = 3 })
        return
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = hum and hum.RootPart
    local tChar = targetPlayer.Character
    local tHum = tChar:FindFirstChildOfClass("Humanoid")
    local tRoot = tHum and tHum.RootPart
    local tHead = tChar:FindFirstChild("Head")
    local acc = tChar:FindFirstChildOfClass("Accessory")
    local handle = acc and acc:FindFirstChild("Handle")
    if not char or not hum or not root then
        Library:Notify({ Title = "提示", Description = "你的角色无效", Time = 3 })
        return
    end
    if root.Velocity.Magnitude < 50 then getgenv().OldPos = root.CFrame end
    if not getgenv().FPDH then getgenv().FPDH = Workspace.FallenPartsDestroyHeight end
    if tHead then Workspace.CurrentCamera.CameraSubject = tHead
    elseif not tHead and handle then Workspace.CurrentCamera.CameraSubject = handle
    elseif tHum and tRoot then Workspace.CurrentCamera.CameraSubject = tHum
    end
    if not tChar:FindFirstChildWhichIsA("BasePart") then
        Library:Notify({ Title = "提示", Description = "目标没有有效部位", Time = 3 })
        return
    end
    local FPos = function(bp, pos, ang)
        root.CFrame = CFrame.new(bp.Position) * pos * ang
        char:SetPrimaryPartCFrame(CFrame.new(bp.Position) * pos * ang)
        root.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
        root.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
    end
    local SFBasePart = function(bp)
        local timeout = tick() + 2
        local angle = 0
        repeat
            if root and tHum then
                if bp.Velocity.Magnitude < 50 then
                    angle = angle + 100
                    FPos(bp, CFrame.new(0, 1.5, 0) + tHum.MoveDirection * bp.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(angle), 0, 0))
                    task.wait()
                    FPos(bp, CFrame.new(0, -1.5, 0) + tHum.MoveDirection * bp.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(angle), 0, 0))
                    task.wait()
                    FPos(bp, CFrame.new(2.25, 1.5, -2.25) + tHum.MoveDirection * bp.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(angle), 0, 0))
                    task.wait()
                    FPos(bp, CFrame.new(-2.25, -1.5, 2.25) + tHum.MoveDirection * bp.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(angle), 0, 0))
                    task.wait()
                    FPos(bp, CFrame.new(0, 1.5, 0) + tHum.MoveDirection, CFrame.Angles(math.rad(angle), 0, 0))
                    task.wait()
                    FPos(bp, CFrame.new(0, -1.5, 0) + tHum.MoveDirection, CFrame.Angles(math.rad(angle), 0, 0))
                    task.wait()
                else
                    FPos(bp, CFrame.new(0, 1.5, tHum.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(bp, CFrame.new(0, -1.5, -tHum.WalkSpeed), CFrame.Angles(0, 0, 0))
                    task.wait()
                    FPos(bp, CFrame.new(0, 1.5, tHum.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(bp, CFrame.new(0, 1.5, tRoot.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(bp, CFrame.new(0, -1.5, -tRoot.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                    task.wait()
                    FPos(bp, CFrame.new(0, 1.5, tRoot.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(bp, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(bp, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                    task.wait()
                    FPos(bp, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0))
                    task.wait()
                    FPos(bp, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                    task.wait()
                end
            else break end
        until bp.Velocity.Magnitude > 500 or bp.Parent ~= targetPlayer.Character or targetPlayer.Parent ~= Players or targetPlayer.Character ~= tChar or (tHum and tHum.Sit) or hum.Health <= 0 or tick() > timeout
    end
    Workspace.FallenPartsDestroyHeight = 0 / 0
    local bv = Instance.new("BodyVelocity")
    bv.Name = "EpixVel"
    bv.Parent = root
    bv.Velocity = Vector3.new(9e8, 9e8, 9e8)
    bv.MaxForce = Vector3.new(1 / 0, 1 / 0, 1 / 0)
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    if tRoot and tHead then
        if (tRoot.CFrame.p - tHead.CFrame.p).Magnitude > 5 then SFBasePart(tHead) else SFBasePart(tRoot) end
    elseif tRoot and not tHead then SFBasePart(tRoot)
    elseif not tRoot and tHead then SFBasePart(tHead)
    elseif not tRoot and not tHead and acc and handle then SFBasePart(handle)
    else
        Library:Notify({ Title = "提示", Description = "找不到合适的甩飞部位", Time = 3 })
        bv:Destroy()
        return
    end
    bv:Destroy()
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    Workspace.CurrentCamera.CameraSubject = hum
    repeat
        root.CFrame = getgenv().OldPos * CFrame.new(0, 0.5, 0)
        char:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, 0.5, 0))
        hum:ChangeState("GettingUp")
        for _, x in pairs(char:GetChildren()) do
            if x:IsA("BasePart") then
                x.Velocity = Vector3.new()
                x.RotVelocity = Vector3.new()
            end
        end
        task.wait()
    until (root.Position - getgenv().OldPos.p).Magnitude < 25
    Workspace.FallenPartsDestroyHeight = getgenv().FPDH
    Library:Notify({ Title = "甩飞完成", Description = "已完成对 " .. targetPlayer.Name .. " 的甩飞", Time = 3 })
end

local function showPlayerSelect(callback, titleText)
    local selectGui = Instance.new("ScreenGui")
    selectGui.Name = "PlayerSelect"
    selectGui.Parent = LocalPlayer.PlayerGui
    selectGui.IgnoreGuiInset = true
    selectGui.ResetOnSpawn = false
    selectGui.DisplayOrder = 999
    local blocker = Instance.new("Frame")
    blocker.Name = "Blocker"
    blocker.Parent = selectGui
    blocker.Size = UDim2.new(1, 0, 1, 0)
    blocker.BackgroundTransparency = 1
    blocker.Active = true
    blocker.ZIndex = 0
    local bg = Instance.new("Frame")
    bg.Parent = selectGui
    bg.Size = UDim2.new(0, 200, 0, 250)
    bg.Position = UDim2.new(0.5, -100, 0.5, -125)
    bg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    bg.ZIndex = 1
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 12); corner.Parent = bg
    local title = Instance.new("TextLabel")
    title.Parent = bg
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = titleText or "选择玩家"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 16
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Parent = bg
    scrollFrame.Size = UDim2.new(1, -10, 1, -40)
    scrollFrame.Position = UDim2.new(0, 5, 0, 35)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.ScrollBarThickness = 4
    local playersList = Players:GetPlayers()
    local y = 0
    for _, p in ipairs(playersList) do
        if p ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Parent = scrollFrame
            btn.Size = UDim2.new(1, -10, 0, 30)
            btn.Position = UDim2.new(0, 5, 0, y)
            btn.Text = p.Name
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 14
            local btnCorner = Instance.new("UICorner"); btnCorner.CornerRadius = UDim.new(0, 6); btnCorner.Parent = btn
            btn.MouseButton1Click:Connect(function()
                callback(p); selectGui:Destroy()
            end)
            y = y + 35
        end
    end
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, y)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Parent = bg
    closeBtn.Size = UDim2.new(0, 30, 0, 20)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextSize = 14
    local closeCorner = Instance.new("UICorner"); closeCorner.CornerRadius = UDim.new(0, 4); closeCorner.Parent = closeBtn
    closeBtn.MouseButton1Click:Connect(function() selectGui:Destroy() end)
end

local function suckSharkLoop()
    pcall(function()
        local hrp = getRootPart()
        if not hrp then return end
        local sharks = getSharkObjects()
        for _, shark in ipairs(sharks) do
            local primaryPart = shark.PrimaryPart or shark:FindFirstChildWhichIsA("BasePart")
            if primaryPart then
                if shark:IsA("Model") then
                    shark:SetPrimaryPartCFrame(hrp.CFrame * CFrame.new(0, 15, -20))
                else
                    shark.CFrame = hrp.CFrame * CFrame.new(0, 15, -20)
                end
            end
        end
    end)
end

local function suckAllLoop()
    pcall(function()
        local hrp = getRootPart()
        if not hrp then return end
        local all = getAllPlayers()
        for _, plr in ipairs(all) do
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local playerHRP = plr.Character.HumanoidRootPart
                playerHRP.CFrame = hrp.CFrame * CFrame.new(0, 15, -20)
            end
        end
    end)
end

local function getSharkBlaster()
    pcall(function()
        local sharkBlaster = ReplicatedStorage:FindFirstChild("ClientViewportObjects")
        if sharkBlaster then
            sharkBlaster = sharkBlaster:FindFirstChild("Weapons")
            if sharkBlaster then
                sharkBlaster = sharkBlaster:FindFirstChild("SharkBlaster")
                if sharkBlaster then
                    local backpack = LocalPlayer:FindFirstChild("Backpack")
                    if backpack and not backpack:FindFirstChild("SharkBlaster") then
                        sharkBlaster:Clone().Parent = backpack
                        Library:Notify({ Title = "获取成功", Description = "鲨鱼冲击波已添加到背包", Time = 2 })
                    else
                        Library:Notify({ Title = "提示", Description = "背包中已有鲨鱼冲击波", Time = 2 })
                    end
                else
                    Library:Notify({ Title = "获取失败", Description = "未找到鲨鱼冲击波", Time = 2 })
                end
            end
        end
    end)
end

local function flingSharkTargets()
    local sharkPlayers = getSharkPlayers()
    local sharkObjects = getSharkObjects()
    local count = 0
    for _, plr in ipairs(sharkPlayers) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            task.spawn(function()
                powerfulFling(plr)
            end)
            count = count + 1
            task.wait(0.5)
        end
    end
    for _, shark in ipairs(sharkObjects) do
        pcall(function()
            local primaryPart = shark.PrimaryPart or shark:FindFirstChildWhichIsA("BasePart")
            if primaryPart then
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                bv.Velocity = Vector3.new(9e7, 9e7, 9e7)
                bv.Parent = primaryPart
                task.wait(0.3)
                bv:Destroy()
                count = count + 1
            end
        end)
        task.wait(0.1)
    end
    Library:Notify({ Title = "甩飞完成", Description = "共甩飞 " .. tostring(count) .. " 个鲨鱼目标", Time = 3 })
end

local Window = Library:CreateWindow({
    Title = "鲨口求生",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify({
    Title = "鲨口求生",
    Description = "创作者：Aiove\nQQ：3999698324\n脚本已加载成功",
    Time = 5,
})

local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Main = Window:AddTab("主要", "zap"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel('Aiove将持续更新此脚本')
NoticeGroup:AddLabel('创作者：Aiove')

local MainLeft = Tabs.Main:AddLeftGroupbox("角色功能")

MainLeft:AddToggle("SpeedToggle", {
    Text = "加速",
    Default = false,
    Callback = function(state)
        getgenv().QW.SpeedEnabled = state
        if state then
            startSpeedAntiPull()
            Library:Notify({ Title = "加速", Description = "已开启", Time = 1.5 })
        else
            stopSpeedAntiPull()
            local hum = getHumanoid()
            if hum then hum.WalkSpeed = 16 end
            Library:Notify({ Title = "加速", Description = "已关闭", Time = 1.5 })
        end
    end
})

MainLeft:AddSlider("SpeedSlider", {
    Text = "速度",
    Default = 16,
    Min = 5,
    Max = 1000,
    Rounding = 0,
    Callback = function(value)
        getgenv().QW.Speed = value
    end
})

MainLeft:AddToggle("FlyToggle", {
    Text = "飞行",
    Default = false,
    Callback = function(state)
        flyActive = state
        if state then
            local root = getRootPart()
            if not root then
                Library:Notify({ Title = "飞行", Description = "角色未加载", Time = 2 })
                flyActive = false
                return
            end
            startFlyInternal()
            Library:Notify({ Title = "飞行", Description = "已开启", Time = 1.5 })
        else
            stopFlyInternal()
            Library:Notify({ Title = "飞行", Description = "已关闭", Time = 1.5 })
        end
    end
})

MainLeft:AddToggle("NoclipToggle", {
    Text = "穿墙",
    Default = false,
    Callback = function(state)
        getgenv().QW.NoclipEnabled = state
        if state then
            startNoclip()
            Library:Notify({ Title = "穿墙", Description = "已开启", Time = 1.5 })
        else
            stopNoclip()
            Library:Notify({ Title = "穿墙", Description = "已关闭", Time = 1.5 })
        end
    end
})

MainLeft:AddToggle("InfiniteJumpToggle", {
    Text = "无限跳",
    Default = false,
    Callback = function(state)
        InfiniteJumpEnabled = state
        Library:Notify({ Title = "无限跳", Description = state and "已开启" or "已关闭", Time = 1.5 })
    end
})

MainLeft:AddDivider()

MainLeft:AddToggle("ESPToggle", {
    Text = "透视",
    Default = false,
    Callback = function(state)
        espEnabled = state
        if state then
            for _, p in ipairs(Players:GetPlayers()) do setupPlayerESP(p) end
            Library:Notify({ Title = "透视", Description = "已开启", Time = 1.5 })
        else
            for _, p in ipairs(Players:GetPlayers()) do cleanupESP(p) end
            Library:Notify({ Title = "透视", Description = "已关闭", Time = 1.5 })
        end
    end
})

MainLeft:AddButton("甩飞全部人", function()
    Library:Notify({ Title = "甩飞", Description = "开始甩飞所有玩家...", Time = 3 })
    task.spawn(function()
        local count = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                powerfulFling(p)
                count = count + 1
                task.wait(0.5)
            end
        end
        Library:Notify({ Title = "甩飞完成", Description = "共甩飞 " .. tostring(count) .. " 个玩家", Time = 3 })
    end)
end)

MainLeft:AddButton("甩飞最近的人", function()
    local nearest = nil
    local minDist = math.huge
    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
    if not myPos then
        Library:Notify({ Title = "甩飞", Description = "你的角色未加载", Time = 3 })
        return
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
            if dist < minDist then minDist = dist; nearest = p end
        end
    end
    if nearest then
        Library:Notify({ Title = "甩飞", Description = "正在甩飞 " .. nearest.Name, Time = 3 })
        task.spawn(function() powerfulFling(nearest) end)
    else
        Library:Notify({ Title = "甩飞", Description = "未找到其他玩家", Time = 3 })
    end
end)

MainLeft:AddButton("甩飞选定的人", function()
    showPlayerSelect(function(p)
        Library:Notify({ Title = "甩飞", Description = "正在甩飞 " .. p.Name, Time = 3 })
        task.spawn(function() powerfulFling(p) end)
    end, "选择要甩飞的玩家")
end)

MainLeft:AddButton("传送回家", function()
    local char = getCharacter()
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(-110.4, 99.1, 34.2)
        Library:Notify({ Title = "传送", Description = "已传送回家", Time = 2 })
    else
        Library:Notify({ Title = "传送", Description = "角色未加载", Time = 2 })
    end
end)

local MainRight = Tabs.Main:AddRightGroupbox("鲨鱼功能")

MainRight:AddToggle("SharkESPToggle", {
    Text = "鲨鱼透视",
    Default = false,
    Callback = function(state)
        getgenv().QW.SharkESPEnabled = state
        if state then
            if getgenv().QW.ESPThread then task.cancel(getgenv().QW.ESPThread) end
            getgenv().QW.ESPThread = task.spawn(function()
                while getgenv().QW.SharkESPEnabled do
                    sharkESPLoop()
                    task.wait(0.5)
                end
            end)
            Library:Notify({ Title = "鲨鱼透视", Description = "已开启", Time = 1.5 })
        else
            if getgenv().QW.ESPThread then
                task.cancel(getgenv().QW.ESPThread)
                getgenv().QW.ESPThread = nil
            end
            clearSharkESP()
            Library:Notify({ Title = "鲨鱼透视", Description = "已关闭", Time = 1.5 })
        end
    end
})

MainRight:AddButton("甩飞鲨鱼", function()
    flingSharkTargets()
end)

MainRight:AddToggle("SuckSharkToggle", {
    Text = "循环吸鲨鱼",
    Default = false,
    Callback = function(state)
        getgenv().QW.SuckSharkEnabled = state
        if state then
            if getgenv().QW.SuckSharkThread then task.cancel(getgenv().QW.SuckSharkThread) end
            getgenv().QW.SuckSharkThread = task.spawn(function()
                while getgenv().QW.SuckSharkEnabled do
                    suckSharkLoop()
                    task.wait(0.1)
                end
            end)
            Library:Notify({ Title = "循环吸鲨鱼", Description = "已开启", Time = 1.5 })
        else
            if getgenv().QW.SuckSharkThread then
                task.cancel(getgenv().QW.SuckSharkThread)
                getgenv().QW.SuckSharkThread = nil
            end
            Library:Notify({ Title = "循环吸鲨鱼", Description = "已关闭", Time = 1.5 })
        end
    end
})

MainRight:AddToggle("SuckAllToggle", {
    Text = "吸全部玩家",
    Default = false,
    Callback = function(state)
        getgenv().QW.SuckAllEnabled = state
        if state then
            if getgenv().QW.SuckAllThread then task.cancel(getgenv().QW.SuckAllThread) end
            getgenv().QW.SuckAllThread = task.spawn(function()
                while getgenv().QW.SuckAllEnabled do
                    suckAllLoop()
                    task.wait(0.1)
                end
            end)
            Library:Notify({ Title = "吸全部玩家", Description = "已开启", Time = 1.5 })
        else
            if getgenv().QW.SuckAllThread then
                task.cancel(getgenv().QW.SuckAllThread)
                getgenv().QW.SuckAllThread = nil
            end
            Library:Notify({ Title = "吸全部玩家", Description = "已关闭", Time = 1.5 })
        end
    end
})

MainRight:AddButton("获取鲨鱼冲击波", function()
    getSharkBlaster()
end)

MainRight:AddToggle("AdminPanelToggle", {
    Text = "管理员面板",
    Default = false,
    Callback = function(state)
        getgenv().QW.AdminPanelEnabled = state
        pcall(function()
            local panel = LocalPlayer.PlayerGui:FindFirstChild("AdminPanel")
            if panel then
                panel.Enabled = state
            end
        end)
        Library:Notify({
            Title = "管理员面板",
            Description = state and "已开启" or "已关闭",
            Time = 1.5,
        })
    end
})

local UnloadGroup = Tabs.Settings:AddLeftGroupbox("脚本管理")
UnloadGroup:AddButton("卸载脚本", function()
    Library:Unload()
end)

if ThemeManager then
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("MyScriptTheme")
    ThemeManager:ApplyToTab(Tabs.Settings)
end

if SaveManager then
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetFolder("MyScriptConfig")
    SaveManager:BuildConfigSection(Tabs.Settings)
end

Window:OnClose(function()
    print("界面已关闭。")
end)
