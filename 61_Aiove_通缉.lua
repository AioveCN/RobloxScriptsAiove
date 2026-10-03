-- This file has been deobfuscated Luraph using Hurricane https://discord.com/invite/AbeurBzKXe
local function safeLoad(url) local success, result = pcall(function() return loadstring(game:HttpGet(url))() end) if not success then warn("加载失败: " .. url) return nil end return result end
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
local Options = Library.Options
local Toggles = Library.Toggles
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local ObsWindow = Library:CreateWindow({
    Title = "通缉",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})
Library:Notify({
    Title = "通缉",
    Description = "创作者：Aiove\nQQ：3999698324\n脚本已加载成功",
    Time = 5,
})
local WindUI = {}
function WindUI:Notify(data)
    Library:Notify({
        Title = data.Title or "提示",
        Description = data.Content or data.Description or "",
        Time = data.Duration or data.Time or 3,
    })
end
local uiCounter = 0
local function nextKey(prefix)
    uiCounter = uiCounter + 1
    return prefix .. tostring(uiCounter)
end
local function createElementAPI(getBox)
    local api = {}
    function api:Toggle(data)
        local key = nextKey("Toggle_")
        getBox():AddToggle(key, {
            Text = data.Title or "开关",
            Default = data.Default or data.Value or false,
            Callback = function(v)
                if data.Callback then
                    data.Callback(v)
                end
            end,
        })
    end
    function api:Slider(data)
        local key = nextKey("Slider_")
        local v = data.Value or {}
        getBox():AddSlider(key, {
            Text = data.Title or "滑块",
            Min = v.Min or data.Min or 0,
            Max = v.Max or data.Max or 100,
            Default = v.Default or data.Default or 0,
            Rounding = 0,
            Callback = function(val)
                if data.Callback then
                    data.Callback(val)
                end
            end,
        })
    end
    function api:Button(data)
        getBox():AddButton(data.Title or "按钮", function()
            if data.Callback then
                data.Callback()
            end
        end)
    end
    function api:Dropdown(data)
        local key = nextKey("Dropdown_")
        local values = data.Values or {}
        local def = data.Default
        if def == nil then def = data.Value end
        if type(def) == "string" then
            for i, item in ipairs(values) do
                if item == def then
                    def = i
                    break
                end
            end
            if type(def) == "string" then def = nil end
        end
        getBox():AddDropdown(key, {
            Text = data.Title or "下拉菜单",
            Values = values,
            Default = def,
            Callback = function(v)
                if data.Callback then
                    data.Callback(v)
                end
            end,
        })
    end
    function api:Input(data)
        local key = nextKey("Input_")
        getBox():AddInput(key, {
            Text = data.Title or "输入",
            Default = data.Default or data.Value or "",
            Placeholder = data.Placeholder or "",
            Callback = function(v)
                if data.Callback then
                    data.Callback(v)
                end
            end,
        })
    end
    function api:Paragraph(data)
        local text = data.Title or ""
        if data.Desc and data.Desc ~= "" then
            text = text .. "\n" .. data.Desc
        end
        getBox():AddLabel(text)
    end
    function api:Label(data)
        if type(data) == "table" then
            api:Paragraph(data)
        else
            getBox():AddLabel(tostring(data))
        end
    end
    function api:Divider() end
    return api
end
local Window = {}
function Window:Tab(data)
    local title = type(data) == "table" and data.Title or tostring(data)
    local tab = ObsWindow:AddTab(title, "info")
    local holder = { box = tab:AddLeftGroupbox(title) }
    local api = createElementAPI(function() return holder.box end)
    function api:Section(secData)
        local st = type(secData) == "table" and secData.Title or tostring(secData)
        holder.box = tab:AddLeftGroupbox(st)
        return createElementAPI(function() return holder.box end)
    end
    return api
end
function Window:Section()
    local dummy = {}
    local function noop() return dummy end
    dummy.Toggle = noop
    dummy.Slider = noop
    dummy.Button = noop
    dummy.Dropdown = noop
    dummy.Input = noop
    dummy.Paragraph = noop
    dummy.Label = noop
    dummy.Divider = noop
    dummy.Section = noop
    return dummy
end
function Window:OnClose() end
function Window:OnDestroy() end
function Window:EditOpenButton() end
function Window:Tag() end
local infoTab = Window:Tab({ Title = "通知" })
local infoSection = infoTab:Section({ Title = "作者消息" })
infoSection:Paragraph({ Title = "Aiove将持续更新此脚本" })
infoSection:Paragraph({ Title = "创作者：Aiove" })
infoSection:Paragraph({ Title = "QQ：3999698324" })
local FlightControl = Window:Tab({Title = "人物功能", Icon = "gift"})
local FlyingEnabled = false
local SpinningEnabled = false
local FlightSpeed = 50
local SpinSpeed = 5
local CurrentAO, CurrentLV, CurrentMoverAttachment
local FlightConnection
local Control = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
local LastControl = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
local function getControlModule()
local LocalPlayer = game:GetService("Players").LocalPlayer
local PlayerModule = LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")
return require(PlayerModule:WaitForChild("ControlModule"))
end
local function setupBodyMovers(character)
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local moverParent = workspace:FindFirstChildOfClass("Terrain") or workspace
local moverAttachment = Instance.new("Attachment", hrp)
moverAttachment.Name = "FlightAttachment"
local alignOrientation = Instance.new('AlignOrientation')
alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
alignOrientation.RigidityEnabled = true
alignOrientation.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
alignOrientation.CFrame = hrp.CFrame
alignOrientation.Attachment0 = moverAttachment
alignOrientation.Parent = moverParent
local linearVelocity = Instance.new('LinearVelocity')
linearVelocity.VectorVelocity = Vector3.new(0, 0, 0)
linearVelocity.MaxForce = 9e9
linearVelocity.Attachment0 = moverAttachment
linearVelocity.Parent = moverParent
return alignOrientation, linearVelocity, humanoid, moverAttachment
end
local function getFlightVector(controlModule)
local moveVector = controlModule:GetMoveVector()
local camera = workspace.CurrentCamera
Control.F = -moveVector.Z
Control.B = moveVector.Z
Control.L = -moveVector.X
Control.R = moveVector.X
Control.Q = moveVector.Y
Control.E = -moveVector.Y
local UserInputService = game:GetService("UserInputService")
if UserInputService:IsKeyDown(Enum.KeyCode.W) then Control.F = 1 end
if UserInputService:IsKeyDown(Enum.KeyCode.S) then Control.B = 1 end
if UserInputService:IsKeyDown(Enum.KeyCode.A) then Control.L = 1 end
if UserInputService:IsKeyDown(Enum.KeyCode.D) then Control.R = 1 end
if UserInputService:IsKeyDown(Enum.KeyCode.Space) then Control.Q = 1 end
if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then Control.E = 1 end
local flightVector = (camera.CFrame.LookVector * (Control.F - Control.B) +
camera.CFrame.RightVector * (Control.R - Control.L) +
Vector3.new(0, 1, 0) * (Control.Q - Control.E))
return flightVector.Magnitude > 0 and flightVector.Unit or flightVector
end
local function startFlying()
if FlyingEnabled then return end
local LocalPlayer = game:GetService("Players").LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
if not character then
WindUI:Notify({
Title = "飞行失败",
Content = "无法获取角色",
Duration = 2,
Icon = "x"
})
return
end
FlyingEnabled = true
SpinningEnabled = false
if CurrentAO then CurrentAO:Destroy() end
if CurrentLV then CurrentLV:Destroy() end
if CurrentMoverAttachment then CurrentMoverAttachment:Destroy() end
CurrentAO, CurrentLV, humanoid, CurrentMoverAttachment = setupBodyMovers(character)
WindUI:Notify({
Title = "飞行开启",
Content = "速度: " .. FlightSpeed,
Duration = 2,
Icon = "check"
})
local controlModule = getControlModule()
FlightConnection = game:GetService("RunService").Heartbeat:Connect(function()
if not FlyingEnabled or not CurrentLV or not CurrentAO then
if FlightConnection then
FlightConnection:Disconnect()
FlightConnection = nil
end
return
end
local flightVector = getFlightVector(controlModule)
if flightVector.Magnitude > 0 then
CurrentLV.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
CurrentLV.VectorVelocity = flightVector * FlightSpeed
else
CurrentLV.VectorVelocity = Vector3.new(0, 0, 0)
end
if SpinningEnabled then
local targetPart = character.Humanoid.SeatPart or character.HumanoidRootPart
local spinCFrame = targetPart.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0)
CurrentAO.CFrame = spinCFrame
else
CurrentAO.CFrame = workspace.CurrentCamera.CFrame
end
if character.HumanoidRootPart then
character.Humanoid.PlatformStand = true
end
end)
character.AncestryChanged:Connect(function(_, parent)
if not parent and FlyingEnabled then
stopFlying()
end
end)
end
local function stopFlying()
if not FlyingEnabled then return end
FlyingEnabled = false
SpinningEnabled = false
Control = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
LastControl = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
if FlightConnection then
FlightConnection:Disconnect()
FlightConnection = nil
end
local LocalPlayer = game:GetService("Players").LocalPlayer
local character = LocalPlayer.Character
if character and character:FindFirstChild("Humanoid") then
character.Humanoid.PlatformStand = false
end
if CurrentAO then
CurrentAO:Destroy()
CurrentAO = nil
end
if CurrentLV then
CurrentLV:Destroy()
CurrentLV = nil
end
if CurrentMoverAttachment then
CurrentMoverAttachment:Destroy()
CurrentMoverAttachment = nil
end
WindUI:Notify({
Title = "飞行关闭",
Content = "飞行功能已禁用",
Duration = 2,
Icon = "x"
})
end
local function toggleSpinning()
if not FlyingEnabled then
WindUI:Notify({
Title = "提示",
Content = "请先开启飞行功能",
Duration = 2,
Icon = "info"
})
return
end
SpinningEnabled = not SpinningEnabled
if SpinningEnabled then
WindUI:Notify({
Title = "旋转开启",
Content = "旋转速度: " .. SpinSpeed,
Duration = 2,
Icon = "refresh-cw"
})
else
WindUI:Notify({
Title = "旋转关闭",
Content = "旋转功能已禁用",
Duration = 2,
Icon = "x"
})
end
end
FlightControl:Toggle({
Title = "飞行模式",
Default = FlyingEnabled,
Callback = function(v)
if v then
startFlying()
else
stopFlying()
end
end
})
FlightControl:Toggle({
Title = "旋转模式",
Default = SpinningEnabled,
Callback = function(v)
if v then
SpinningEnabled = true
else
SpinningEnabled = false
end
end
})
FlightControl:Slider({
Title = "飞行速度",
Value = {
Min = 1,
Max = 200,
Default = 50
},
Callback = function(value)
FlightSpeed = value
if FlyingEnabled then
WindUI:Notify({
Title = "速度已更新",
Content = "飞行速度: " .. value,
Duration = 1,
Icon = "zap"
})
end
end
})
FlightControl:Slider({
Title = "旋转速度",
Value = {
Min = 1,
Max = 50,
Default = 5
},
Callback = function(value)
SpinSpeed = value
if SpinningEnabled then
WindUI:Notify({
Title = "旋转速度已更新",
Content = "旋转速度: " .. value,
Duration = 1,
Icon = "refresh-cw"
})
end
end
})
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
LocalPlayer.CharacterAdded:Connect(function()
if FlyingEnabled then
task.wait(0.5)
stopFlying()
task.wait(0.1)
startFlying()
end
end)
game:GetService("CoreGui").ChildRemoved:Connect(function(child)
if child.Name == "CloudHub" and FlyingEnabled then
stopFlying()
end
end)
FlightControl:Divider()
local SpeedHack = false
local SpeedValue = 16
FlightControl:Toggle({
Title = "速度增加",
Default = SpeedHack,
Callback = function(v)
SpeedHack = v
if v then
task.spawn(function()
local sudu = game:GetService("RunService").Heartbeat:Connect(function()
if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
local hum = game.Players.LocalPlayer.Character.Humanoid
if hum.MoveDirection.Magnitude > 0 then
game.Players.LocalPlayer.Character:TranslateBy(hum.MoveDirection * SpeedValue / 10)
end
end
end)
while SpeedHack do
task.wait()
end
sudu:Disconnect()
end)
else
print("速度：关闭")
end
end
})
FlightControl:Slider({
Title = "速度设置",
Value = {
Min = 1,
Max = 150,
Default = 16
},
Callback = function(v)
SpeedValue = v
end
})
FlightControl:Toggle({
    Title = "扩大视野",
    Default = false,
    Callback = function(v)
        if v == true then
            fovConnection = game:GetService("RunService").Heartbeat:Connect(function()
                workspace.CurrentCamera.FieldOfView = 120
            end)
        elseif not v and fovConnection then
            fovConnection:Disconnect()
            fovConnection = nil
        end
    end
})
FlightControl:Divider()
FlightControl:Toggle({
    Title = "无限跳",
    Default = false,
    Callback = function(Value)
        local jumpConn
        if Value then
            jumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
                local humanoid = game:GetService("Players").LocalPlayer.Character and
                                 game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if jumpConn then
                jumpConn:Disconnect()
                jumpConn = nil
            end
        end
    end
})

local LockSection = Window:Section({
    Title = "主要功能区域",
    Icon = "crown",
    Opened = true,
})

local Main = Window:Tab({Title = "战斗功能", Icon = "swords"})
    local ForceLoadAll = false
    Main:Toggle({
        Title = "强制加载所有数据",
        Default = ForceLoadAll,
        Callback = function(v)
            ForceLoadAll = v
            if v then
                task.spawn(function()
                    local devv = require(game:GetService("ReplicatedStorage").Devv)
                    local Network = devv.load("Network")
                    local Players = game:GetService("Players")
                    local RunService = game:GetService("RunService")
                    local LocalPlayer = Players.LocalPlayer

                    local function loadArea(position, radius)
                        if RunService:IsClient() then
                            pcall(function()
                                Network.InvokeServer("requestStreamAround", position, radius)
                            end)
                            pcall(function()
                                Network.FireServer("setReplicationFocus", position)
                            end)
                        end
                    end

                    local function loadAllGizmos()
                        local White = Workspace:FindFirstChild("Local") and Workspace.Local:FindFirstChild("Gizmos") and Workspace.Local.Gizmos:FindFirstChild("White")
                        if White then
                            for _,gizmo in ipairs(White:GetChildren()) do
                                if gizmo.PrimaryPart then
                                    loadArea(gizmo.PrimaryPart.Position, 50)
                                    task.wait(0.1)
                                end
                            end
                        end
                    end

                    local function loadAllPlayers()
                        for _,player in ipairs(Players:GetPlayers()) do
                            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                loadArea(player.Character.HumanoidRootPart.Position, 50)
                                task.wait(0.1)
                            end
                        end
                    end

                    while ForceLoadAll do
                        loadAllGizmos()
                        loadAllPlayers()
                        loadArea(Vector3.new(0,0,0), 1000)
                        loadArea(Vector3.new(1000,0,1000), 1000)
                        loadArea(Vector3.new(-1000,0,-1000), 1000)
                        loadArea(Vector3.new(1000,0,-1000), 1000)
                        loadArea(Vector3.new(-1000,0,1000), 1000)
                        task.wait(5)
                    end
                end)
            else
                print("强制加载：关闭")
            end
        end
    })

    local AutoShoot = false
    local OriginalShoot = nil
    local ShooterModule = nil

    Main:Toggle({
        Title = "愤怒机器人[全枪]",
        Default = AutoShoot,
        Callback = function(v)
            AutoShoot = v
            if v then
                task.spawn(function()
                    ShooterModule = require(game:GetService("ReplicatedStorage").Client.Wanted.Objects.ClientTool.Components.Guns.Shooter)
                    OriginalShoot = ShooterModule._shoot

                    local trailColors = {
                        primary = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
                            ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 0, 255)),
                            ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 255, 0)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                        }
                    }

                    local function createBezierCurve(p0, p1, p2, t)
                        return (1-t)^2 * p0 + 2*(1-t)*t * p1 + t^2 * p2
                    end

                    local function createBeautifulTrail(origin, targetPos)
                        local trailContainer = Instance.new("Folder")
                        trailContainer.Name = "MagicTrail"
                        trailContainer.Parent = Workspace

                        local midPoint = (origin + targetPos) / 2
                        local direction = (targetPos - origin).Unit
                        local perpendicular = Vector3.new(-direction.Z, direction.Y, direction.X) * 3
                        local controlPoint = midPoint + perpendicular + Vector3.new(0, math.random(-3, 3), 0)

                        local curvePoints = {}
                        local numSegments = 20

                        for i = 0, numSegments do
                            local t = i / numSegments
                            local point = createBezierCurve(origin, controlPoint, targetPos, t)
                            table.insert(curvePoints, point)
                        end

                        for i = 1, #curvePoints - 1 do
                            local startPoint = curvePoints[i]
                            local endPoint = curvePoints[i + 1]
                            local distance = (endPoint - startPoint).Magnitude

                            local beamPart = Instance.new("Part")
                            beamPart.Size = Vector3.new(0.15, 0.15, distance)
                            beamPart.Anchored = true
                            beamPart.CanCollide = false
                            beamPart.Material = Enum.Material.Neon
                            beamPart.Transparency = getgenv().TrailTransparency or 0.3
                            beamPart.CFrame = CFrame.new(startPoint, endPoint) * CFrame.new(0, 0, -distance/2)
                            beamPart.Parent = trailContainer

                            local tParam = i / (#curvePoints - 1)
                            local color
                            if tParam < 0.3 then
                                color = getgenv().TrailColors and getgenv().TrailColors.StartColor or Color3.fromRGB(0, 170, 255)
                            elseif tParam < 0.6 then
                                color = getgenv().TrailColors and getgenv().TrailColors.MiddleColor1 or Color3.fromRGB(255, 0, 255)
                            elseif tParam < 0.9 then
                                color = getgenv().TrailColors and getgenv().TrailColors.MiddleColor2 or Color3.fromRGB(255, 255, 0)
                            else
                                color = getgenv().TrailColors and getgenv().TrailColors.EndColor or Color3.fromRGB(255, 0, 0)
                            end
                            beamPart.Color = color

                            local pointLight = Instance.new("PointLight")
                            pointLight.Brightness = 5
                            pointLight.Range = 3
                            pointLight.Color = color
                            pointLight.Parent = beamPart

                            local particles = Instance.new("ParticleEmitter")
                            particles.Size = NumberSequence.new(0.1, 0.3)
                            particles.Transparency = NumberSequence.new(0.3, 0.8)
                            particles.Lifetime = NumberRange.new(0.5, 1)
                            particles.Rate = 50
                            particles.Speed = NumberRange.new(1, 2)
                            particles.VelocitySpread = 180
                            particles.Color = ColorSequence.new(color)
                            particles.Parent = beamPart
                        end

                        task.spawn(function()
                            task.wait(1.5)
                            if trailContainer and trailContainer.Parent then
                                trailContainer:Destroy()
                            end
                        end)

                        return trailContainer
                    end

                    local function hasLineOfSight(shooterPos, targetPos)
                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                        raycastParams.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
                        raycastParams.IgnoreWater = true

                        local direction = (targetPos - shooterPos).Unit
                        local distance = (targetPos - shooterPos).Magnitude
                        local raycastResult = Workspace:Raycast(shooterPos, direction * distance, raycastParams)

                        if raycastResult then
                            local hitPart = raycastResult.Instance
                            if hitPart then
                                local hitCharacter = hitPart:FindFirstAncestorOfClass("Model")
                                if hitCharacter and hitCharacter:FindFirstChild("Humanoid") then
                                    return true
                                else
                                    return false
                                end
                            end
                        end
                        return true
                    end

                    ShooterModule._shoot = function(self)
                        if not self or not self.tool then
                            return OriginalShoot(self)
                        end

                        local Players = game:GetService("Players")
                        local LocalPlayer = game.Players.LocalPlayer
                        local LocalCharacter = LocalPlayer.Character

                        if not LocalCharacter then
                            return OriginalShoot(self)
                        end

                        local shooterPos = LocalCharacter.HumanoidRootPart and LocalCharacter.HumanoidRootPart.Position or LocalCharacter.PrimaryPart.Position
                        local nearestPlayer = nil
                        local nearestDistance = math.huge

                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                local targetPos = player.Character.HumanoidRootPart.Position
                                local distance = (shooterPos - targetPos).Magnitude

                                if hasLineOfSight(shooterPos, targetPos) and distance < nearestDistance then
                                    nearestDistance = distance
                                    nearestPlayer = player
                                end
                            end
                        end

                        if nearestPlayer and nearestPlayer.Character and nearestPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local targetPos = nearestPlayer.Character.HumanoidRootPart.Position
                            self.aimpoint = targetPos
                            self.aimpoint2 = targetPos

                            if self.tool.model and self.tool.model.PrimaryPart then
                                local muzzlePos = self.tool.model.PrimaryPart.Position
                                createBeautifulTrail(muzzlePos, targetPos)
                            else
                                createBeautifulTrail(shooterPos, targetPos)
                            end

                            if self.tool then
                                self.tool.shooting = true
                                self.tool.fireDebounce = 0
                                self.tool.fireMode = "auto"
                            end
                        else
                            if self.tool then
                                self.tool.shooting = false
                            end
                        end

                        return OriginalShoot(self)
                    end

                    while AutoShoot do
                        if ShooterModule and ShooterModule._shoot then
                            local tool = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
                            if tool then
                                local shooter = tool:FindFirstChild("Shooter")
                                if not shooter then
                                    shooter = {tool = tool}
                                end
                                pcall(function()
                                    ShooterModule._shoot(shooter)
                                end)
                            end
                        end
                        task.wait(getgenv().ShootInterval or 0.2)
                    end

                    if OriginalShoot then
                        ShooterModule._shoot = OriginalShoot
                    end
                end)
            else
                print("自动射击：关闭")
                if ShooterModule and OriginalShoot then
                    ShooterModule._shoot = OriginalShoot
                end
            end
        end
    })

    local AutoSell = false

    Main:Toggle({
        Title = "出售物品光环",
        Default = AutoSell,
        Callback = function(v)
            AutoSell = v
            if v then
                task.spawn(function()
                    while AutoSell do
                        for _, a in ipairs(game:GetService("ReplicatedStorage").Shared.Core.Network:GetChildren()) do
                            if a:IsA("RemoteFunction") or a:IsA("RemoteEvent") then
                                if not a.Name:find("moveHouse") and not a.Name:find("House") then
                                    pcall(function()
                                        a:InvokeServer()
                                    end)
                                end
                            end
                            if not AutoSell then
                                break
                            end
                        end
                        task.wait(0.5)
                    end
                end)
            else
                print("自动出售：关闭")
            end
        end
    })

    local BulletSection = Main:Section({ Title = "弹道设置" })

    getgenv().TrailColors = getgenv().TrailColors or {
        StartColor = Color3.fromRGB(0, 170, 255),
        EndColor = Color3.fromRGB(255, 0, 0),
        MiddleColor1 = Color3.fromRGB(255, 0, 255),
        MiddleColor2 = Color3.fromRGB(255, 255, 0)
    }
    getgenv().TrailTransparency = getgenv().TrailTransparency or 0.3
    getgenv().ShootInterval = getgenv().ShootInterval or 0.2

    local TrailColorNames = {"蓝色", "紫色", "黄色", "红色", "绿色", "青色", "白色", "橙色"}
    local TrailColorValues = {
        ["蓝色"] = Color3.fromRGB(0, 170, 255),
        ["紫色"] = Color3.fromRGB(255, 0, 255),
        ["黄色"] = Color3.fromRGB(255, 255, 0),
        ["红色"] = Color3.fromRGB(255, 0, 0),
        ["绿色"] = Color3.fromRGB(0, 255, 0),
        ["青色"] = Color3.fromRGB(0, 255, 255),
        ["白色"] = Color3.fromRGB(255, 255, 255),
        ["橙色"] = Color3.fromRGB(255, 170, 0)
    }

    BulletSection:Dropdown({
        Title = "弹道起始颜色",
        Values = TrailColorNames,
        Value = "蓝色",
        Callback = function(v)
            getgenv().TrailColors.StartColor = TrailColorValues[v]
        end
    })

    BulletSection:Dropdown({
        Title = "弹道中间颜色1",
        Values = TrailColorNames,
        Value = "紫色",
        Callback = function(v)
            getgenv().TrailColors.MiddleColor1 = TrailColorValues[v]
        end
    })

    BulletSection:Dropdown({
        Title = "弹道中间颜色2",
        Values = TrailColorNames,
        Value = "黄色",
        Callback = function(v)
            getgenv().TrailColors.MiddleColor2 = TrailColorValues[v]
        end
    })

    BulletSection:Dropdown({
        Title = "弹道结束颜色",
        Values = TrailColorNames,
        Value = "红色",
        Callback = function(v)
            getgenv().TrailColors.EndColor = TrailColorValues[v]
        end
    })

    BulletSection:Button({
        Title = "测试弹道效果",
        Callback = function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local startPos = LocalPlayer.Character.HumanoidRootPart.Position
                local endPos = startPos + Vector3.new(0, 0, -20)

                local trailContainer = Instance.new("Folder")
                trailContainer.Name = "TestTrail"
                trailContainer.Parent = workspace

                local beam = Instance.new("Part")
                beam.Size = Vector3.new(0.2, 0.2, 20)
                beam.Anchored = true
                beam.CanCollide = false
                beam.Material = Enum.Material.Neon
                beam.Transparency = getgenv().TrailTransparency or 0.3
                beam.CFrame = CFrame.new(startPos, endPos) * CFrame.new(0, 0, -10)
                beam.Color = getgenv().TrailColors.StartColor or Color3.fromRGB(0, 170, 255)
                beam.Parent = trailContainer

                local pointLight = Instance.new("PointLight")
                pointLight.Brightness = 5
                pointLight.Range = 5
                pointLight.Color = beam.Color
                pointLight.Parent = beam

                local particles = Instance.new("ParticleEmitter")
                particles.Size = NumberSequence.new(0.1, 0.3)
                particles.Transparency = NumberSequence.new(0.3, 0.8)
                particles.Lifetime = NumberRange.new(0.5, 1)
                particles.Rate = 50
                particles.Speed = NumberRange.new(1, 2)
                particles.VelocitySpread = 180
                particles.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, getgenv().TrailColors.StartColor or Color3.fromRGB(0, 170, 255)),
                    ColorSequenceKeypoint.new(0.3, getgenv().TrailColors.MiddleColor1 or Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(0.6, getgenv().TrailColors.MiddleColor2 or Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(1, getgenv().TrailColors.EndColor or Color3.fromRGB(255, 0, 0))
                })
                particles.Parent = beam

                task.delay(3, function()
                    if trailContainer and trailContainer.Parent then
                        trailContainer:Destroy()
                    end
                end)

                Library:Notify({ Title = "测试成功", Description = "弹道颜色预览已生成", Time = 3 })
            else
                Library:Notify({ Title = "错误", Description = "无法找到角色位置", Time = 3 })
            end
        end
    })

    BulletSection:Button({
        Title = "重置颜色设置",
        Callback = function()
            getgenv().TrailColors = {
                StartColor = Color3.fromRGB(0, 170, 255),
                EndColor = Color3.fromRGB(255, 0, 0),
                MiddleColor1 = Color3.fromRGB(255, 0, 255),
                MiddleColor2 = Color3.fromRGB(255, 255, 0)
            }
            Library:Notify({ Title = "重置完成", Description = "所有颜色已恢复为默认值", Time = 3 })
        end
    })

    BulletSection:Slider({
        Title = "弹道透明度",
        Value = { Min = 0, Max = 100, Default = 30 },
        Callback = function(v)
            getgenv().TrailTransparency = v / 100
        end
    })

    BulletSection:Slider({
        Title = "射击间隔",
        Value = { Min = 1, Max = 10, Default = 2 },
        Callback = function(v)
            getgenv().ShootInterval = v / 10
        end
    })

    local HitboxHeadSize = 20
    local HitboxDisabled = true
    local HitboxTransparency = 0.7
    local HitboxColor = Color3.fromRGB(255, 255, 255)
    local HitboxRainbow = false
    local HitboxTargetedUser = ""

    local function GenerateRainbowColor()
        local HueValue = tick() % 5 / 5
        return Color3.fromHSV(HueValue, 1, 1)
    end

    local function IsTargetedUser(PlayerName)
        local TargetLower = HitboxTargetedUser:lower()
        return PlayerName:lower():find(TargetLower, 1, true) ~= nil
    end

    game:GetService("RunService").RenderStepped:Connect(function()
        pcall(function()
            if HitboxDisabled then
                for _, NextPlayer in pairs(Players:GetPlayers()) do
                    if NextPlayer ~= LocalPlayer then
                        pcall(function()
                            local Character = NextPlayer.Character
                            local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
                            if HRP then
                                HRP.Size = Vector3.new(2, 2, 1)
                                HRP.Transparency = 1
                                HRP.BrickColor = BrickColor.new("Medium stone grey")
                                HRP.Material = Enum.Material.Plastic
                                HRP.CanCollide = true
                            end
                        end)
                    end
                end
            else
                for _, NextPlayer in pairs(Players:GetPlayers()) do
                    if NextPlayer ~= LocalPlayer then
                        pcall(function()
                            local Character = NextPlayer.Character
                            local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
                            if HRP then
                                if HitboxTargetedUser == "" or IsTargetedUser(NextPlayer.Name) then
                                    HRP.Size = Vector3.new(HitboxHeadSize, HitboxHeadSize, HitboxHeadSize)
                                    HRP.Transparency = HitboxTransparency
                                    HRP.BrickColor = HitboxRainbow and BrickColor.new(GenerateRainbowColor()) or BrickColor.new(HitboxColor)
                                    HRP.Material = Enum.Material.Neon
                                    HRP.CanCollide = false
                                else
                                    HRP.Size = Vector3.new(2, 2, 1)
                                    HRP.Transparency = 1
                                    HRP.BrickColor = BrickColor.new("Medium stone grey")
                                    HRP.Material = Enum.Material.Plastic
                                    HRP.CanCollide = true
                                end
                            end
                        end)
                    end
                end
            end
        end)
    end)

    local HitboxSection = Main:Section({ Title = "Hitbox" })
    HitboxSection:Paragraph({ Title = "注意: 范围固定 但是要记得演戏 小心被挂DC" })
    HitboxSection:Toggle({
        Title = "启用 Hitbox Extender",
        Default = false,
        Callback = function(state)
            HitboxDisabled = not state
        end
    })

    local MoneyFarmTab = Window:Tab({Title = "刷钱功能", Icon = "dollar-sign"})

    local AutoBankCash = false

    MoneyFarmTab:Toggle({
        Title = "自动抢银行",

        Default = AutoBankCash,
        Callback = function(v)
            AutoBankCash = v
            if v then
                task.spawn(function()
                    local function GetRootPart()
                        local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
                        return Character:WaitForChild("HumanoidRootPart", 5)
                    end

                    while AutoBankCash do
                        local RootPart = GetRootPart()
                        local White = Workspace:FindFirstChild("Local") and Workspace.Local:FindFirstChild("Gizmos") and Workspace.Local.Gizmos:FindFirstChild("White")

                        if White and RootPart and White:FindFirstChild("MainBankCash") and AutoBankCash then
                            local Item = White.MainBankCash
                            local Target = Item.PrimaryPart or Item:FindFirstChildWhichIsA("BasePart", true)

                            if Target then
                                RootPart.CFrame = Target.CFrame * CFrame.new(0, 0, -2.5)
                                task.wait(0.2)

                                while AutoBankCash and White:FindFirstChild("MainBankCash") do
                                    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                    task.wait(0.05)
                                    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                    task.wait(0.5)
                                end
                            end
                        end
                        task.wait(0.5)
                    end
                end)
            else
                print("银行钱堆：关闭")
            end
        end
    })

    local HitATMAura = false

    MoneyFarmTab:Toggle({
        Title = "摧毁ATM光环",

        Default = HitATMAura,
        Callback = function(Value)
            HitATMAura = Value
            if Value then
                local devv = require(game:GetService("ReplicatedStorage").Devv)
                local Get = devv.GetModule("Network")
                local Players = game:GetService("Players")
                local localPlayer = Players.LocalPlayer
                local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
                local humanoid = character:WaitForChild("Humanoid")
                local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

                local gizmoColors = {
                    "White", "Green", "Blue", "Purple", "Orange", "Red", "Yellow"
                }

                local isAttacking = false
                local cooldown = false

                local function attackATM(gizmo)
                    if not gizmo or not gizmo:FindFirstChild("Metal") then
                        return false
                    end
                    local metalPart = gizmo.Metal
                    local guid = gizmo:GetAttribute("objectId")
                    if not guid then
                        return false
                    end

                    Get.FireServer("registerMeleeHits", {{
                        normal = Vector3.new(0, 0, 0),
                        direction = Vector3.new(0, 0, 0),
                        source = "Melee",
                        id = guid,
                        material = Enum.Material.Metal,
                        position = metalPart.Position,
                        gizmoType = "ATM",
                        processedPlayerId = localPlayer.UserId,
                        hit = metalPart,
                        speed = 50,
                        collisionPoint = metalPart.Position,
                        hitName = "Metal",
                        hitType = "gizmo"
                    }})
                    return true
                end

                local function isATMAlive(gizmo)
                    if not gizmo or not gizmo.Parent then
                        return false
                    end
                    if not gizmo:FindFirstChild("Metal") then
                        return false
                    end
                    return true
                end

                local function findAllATMs()
                    local allATMs = {}
                    for _, color in ipairs(gizmoColors) do
                        local colorFolder = Workspace.Local.Gizmos:FindFirstChild(color)
                        if colorFolder then
                            local atm = colorFolder:FindFirstChild("ATM")
                            if atm then
                                table.insert(allATMs, atm)
                            end
                        end
                    end
                    return allATMs
                end

                local function attackLoop()
                    while HitATMAura do
                        if cooldown then
                            task.wait(0.1)
                            continue
                        end

                        local allATMs = findAllATMs()

                        if #allATMs == 0 then
                            task.wait(1)
                            continue
                        end

                        for _, atm in ipairs(allATMs) do
                            if not HitATMAura then break end

                            local attackCount = 0

                            while HitATMAura and isATMAlive(atm) and attackCount < 50 do
                                attackATM(atm)
                                attackCount += 1
                                task.wait(0.05)
                            end

                            if HitATMAura then
                                task.wait(0.5)
                            end
                        end

                        task.wait(0.1)
                    end
                end

                local function onCharacterDied()
                    if HitATMAura then
                        cooldown = true
                        task.wait(3)
                        cooldown = false
                    end
                end

                local function setupCharacterListeners()
                    if character:FindFirstChild("Humanoid") then
                        character.Humanoid.Died:Connect(onCharacterDied)
                    end

                    localPlayer.CharacterAdded:Connect(function(newChar)
                        character = newChar
                        humanoid = newChar:WaitForChild("Humanoid")
                        humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
                        humanoid.Died:Connect(onCharacterDied)
                    end)
                end

                setupCharacterListeners()
                task.spawn(attackLoop)
            end
        end
    })

    local AutoATM = false

    MoneyFarmTab:Toggle({
        Title = "自动ATM",

        Default = AutoATM,
        Callback = function(Value)
            AutoATM = Value
            if Value then
                local TimeElapsedATM = 0
                local TimeoutThresholdATM = 30
                local RootPart = (game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
                local GizmoFolder = Workspace.Local.Gizmos.White

                local ATMPatrolPoints = {
                    Vector3.new(-1137, 78, -1953),
                    Vector3.new(-44, 63, -2083),
                    Vector3.new(194, 60, -2884),
                    Vector3.new(-412, 106, -1301),
                    Vector3.new(-377, 410, -741),
                    Vector3.new(-985, 380, -1145),
                    Vector3.new(-854, 406, -1505)
                }

                local function GetBasePart(instance)
                    if instance:IsA("BasePart") then
                        return instance
                    end
                    for _, descendant in ipairs(instance:GetDescendants()) do
                        if descendant:IsA("BasePart") then
                            return descendant
                        end
                    end
                end

                local function IsValidATMTarget(instance)
                    local typeAttr = instance:GetAttribute("gizmoType")
                    return typeAttr == "ATM"
                end

                local function FindClosestATMTarget()
                    local minDistance = math.huge
                    local closestPart = nil
                    for _, item in ipairs(GizmoFolder:GetChildren()) do
                        if IsValidATMTarget(item) then
                            local part = GetBasePart(item)
                            if part then
                                local dist = (RootPart.Position - part.Position).Magnitude
                                if dist < minDistance then
                                    closestPart = part
                                    minDistance = dist
                                end
                            end
                        end
                    end
                    return closestPart
                end

                local function TeleportTo(target)
                    if typeof(target) ~= "Instance" then
                        if typeof(target) == "Vector3" then
                            RootPart.CFrame = CFrame.new(target)
                        end
                    else
                        RootPart.CFrame = target.CFrame * CFrame.new(0, 5, 0)
                    end
                end

                local function SpamInteract(duration)
                    local start = tick()
                    while tick() - start < duration do
                        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        task.wait(0.05)
                    end
                end

                local function ProcessATMCollection(targetPart)
                    local start = tick()
                    local maxWait = 3
                    while tick() - start < maxWait and (targetPart.Parent and not targetPart:GetAttribute("Collected")) do
                        task.wait(0.1)
                    end
                    SpamInteract(1.5)
                end

                task.spawn(function()
                    while AutoATM do
                        local target = FindClosestATMTarget()
                        if target then
                            TeleportTo(target)
                            task.wait(0.3)
                            SpamInteract(1.5)
                            ProcessATMCollection(target)
                            TimeElapsedATM = 0
                        else
                            TimeElapsedATM = TimeElapsedATM + 0.7
                            TeleportTo(ATMPatrolPoints[math.random(1, #ATMPatrolPoints)])
                            if TimeoutThresholdATM <= TimeElapsedATM then
                                TimeElapsedATM = 0
                            end
                        end
                        task.wait(0.7)
                    end
                end)
            end
        end
    })

    local AutoRegister = false

    MoneyFarmTab:Toggle({
        Title = "自动收银机",
        Default = AutoRegister,
        Callback = function(Value)
            AutoRegister = Value
            if Value then
                local TimeElapsedRegister = 0
                local TimeoutThresholdRegister = 30
                local RootPart = (game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
                local GizmoFolder = Workspace.Local.Gizmos.White

                local RegisterPatrolPoints = {
                    Vector3.new(-1000, 100, -2000),
                    Vector3.new(-500, 100, -2200),
                    Vector3.new(100, 100, -2500)
                }

                local function GetBasePart(instance)
                    if instance:IsA("BasePart") then
                        return instance
                    end
                    for _, descendant in ipairs(instance:GetDescendants()) do
                        if descendant:IsA("BasePart") then
                            return descendant
                        end
                    end
                end

                local function IsValidRegisterTarget(instance)
                    local typeAttr = instance:GetAttribute("gizmoType")
                    return typeAttr == "Register"
                end

                local function FindClosestRegisterTarget()
                    local minDistance = math.huge
                    local closestPart = nil
                    for _, item in ipairs(GizmoFolder:GetChildren()) do
                        if IsValidRegisterTarget(item) then
                            local part = GetBasePart(item)
                            if part then
                                local dist = (RootPart.Position - part.Position).Magnitude
                                if dist < minDistance then
                                    closestPart = part
                                    minDistance = dist
                                end
                            end
                        end
                    end
                    return closestPart
                end

                local function TeleportTo(target)
                    if typeof(target) ~= "Instance" then
                        if typeof(target) == "Vector3" then
                            RootPart.CFrame = CFrame.new(target)
                        end
                    else
                        RootPart.CFrame = target.CFrame * CFrame.new(0, 5, 0)
                    end
                end

                local function SpamInteract(duration)
                    local start = tick()
                    while tick() - start < duration do
                        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        task.wait(0.05)
                    end
                end

                local function ProcessRegisterCollection(targetPart)
                    local start = tick()
                    local maxWait = 2
                    while tick() - start < maxWait and (targetPart.Parent and not targetPart:GetAttribute("Collected")) do
                        task.wait(0.1)
                    end
                    SpamInteract(1.2)
                end

                task.spawn(function()
                    while AutoRegister do
                        local target = FindClosestRegisterTarget()
                        if target then
                            TeleportTo(target)
                            task.wait(0.3)
                            SpamInteract(1.2)
                            ProcessRegisterCollection(target)
                            TimeElapsedRegister = 0
                        else
                            TimeElapsedRegister = TimeElapsedRegister + 0.7
                            TeleportTo(RegisterPatrolPoints[math.random(1, #RegisterPatrolPoints)])
                            if TimeoutThresholdRegister <= TimeElapsedRegister then
                                TimeElapsedRegister = 0
                            end
                        end
                        task.wait(0.7)
                    end
                end)
            end
        end
    })


    local YGAutoFarmRunning = false
    local YGAutoFarmThread = nil
    local YGFarmRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    player.CharacterAdded:Connect(function(char)
        YGFarmRoot = char:WaitForChild("HumanoidRootPart", 5)
    end)

    local YGPatrolPoints = {
        Vector3.new(-1137, 78, -1953),
        Vector3.new(-44, 63, -2083),
        Vector3.new(194, 60, -2884),
        Vector3.new(-412, 106, -1301),
        Vector3.new(-377, 410, -741),
        Vector3.new(-985, 380, -1145),
        Vector3.new(-854, 406, -1505)
    }

    local function YGGetBasePart(instance)
        if not instance then return nil end
        if instance:IsA("BasePart") then return instance end
        for _, descendant in ipairs(instance:GetDescendants()) do
            if descendant:IsA("BasePart") then return descendant end
        end
        return nil
    end

    local function YGFindClosestTarget()
        local folder = workspace:FindFirstChild("Local") and workspace.Local:FindFirstChild("Gizmos") and workspace.Local.Gizmos:FindFirstChild("White")
        if not folder or not YGFarmRoot then return nil end
        local minDistance = math.huge
        local closestPart = nil
        for _, item in ipairs(folder:GetChildren()) do
            local typeAttr = item:GetAttribute("gizmoType")
            if typeAttr == "ATM" or typeAttr == "Register" then
                local part = YGGetBasePart(item)
                if part then
                    local dist = (YGFarmRoot.Position - part.Position).Magnitude
                    if dist < minDistance then
                        closestPart = part
                        minDistance = dist
                    end
                end
            end
        end
        return closestPart
    end

    local function YGTeleportToTarget(target)
        if not YGFarmRoot then return end
        if typeof(target) ~= "Instance" then
            if typeof(target) == "Vector3" then YGFarmRoot.CFrame = CFrame.new(target) end
        else
            YGFarmRoot.CFrame = target.CFrame * CFrame.new(0, 1, 0)
        end
    end

    local function YGSpamInteract(duration)
        local start = tick()
        while tick() - start < duration do
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
            task.wait(0.01)
        end
    end

    MoneyFarmTab:Toggle({
        Title = "自动全图刷钱",
        Default = false,
        Callback = function(state)
            YGAutoFarmRunning = state
            if state then
                if YGAutoFarmThread then task.cancel(YGAutoFarmThread) YGAutoFarmThread = nil end
                YGAutoFarmThread = task.spawn(function()
                    while YGAutoFarmRunning do
                        pcall(function()
                            local target = YGFindClosestTarget()
                            if target then
                                YGTeleportToTarget(target)
                                YGSpamInteract(1.5)
                            else
                                YGTeleportToTarget(YGPatrolPoints[math.random(1, #YGPatrolPoints)])
                            end
                            task.wait(1.5)
                        end)
                    end
                end)
            else
                if YGAutoFarmThread then task.cancel(YGAutoFarmThread) YGAutoFarmThread = nil end
            end
        end
    })

    local AutoPickupTab = Window:Tab({Title = "自动拾取", Icon = "box"})

    local AutoGold = false

    AutoPickupTab:Toggle({
        Title = "自动拾取金条",
        Default = AutoGold,
        Callback = function(v)
            AutoGold = v
            if v then
                task.spawn(function()
                    local function GetRootPart()
                        local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
                        return Character:WaitForChild("HumanoidRootPart", 5)
                    end

                    while AutoGold do
                        local RootPart = GetRootPart()
                        local White = Workspace:FindFirstChild("Local") and Workspace.Local:FindFirstChild("Gizmos") and Workspace.Local.Gizmos:FindFirstChild("White")

                        if White and RootPart then
                            for _, Item in ipairs(White:GetChildren()) do
                                if Item.Name == "Gold Bar" and AutoGold then
                                    local Target = Item.PrimaryPart or Item:FindFirstChildWhichIsA("BasePart", true)

                                    if Target then
                                        RootPart.CFrame = Target.CFrame * CFrame.new(0, 0, -2.5)
                                        task.wait(0.2)
                                        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                        task.wait(0.05)
                                        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)

                                        repeat
                                            task.wait(0.1)
                                        until not Item.Parent or not AutoGold
                                    end
                                end

                                if not AutoGold then
                                    break
                                end
                            end
                        end
                        task.wait(0.5)
                    end
                end)
            end
        end
    })

    local AutoWorldItem = false

    AutoPickupTab:Toggle({
        Title = "自动拾取全部礼物盒",
        Default = AutoWorldItem,
        Callback = function(v)
            AutoWorldItem = v
            if v then
                task.spawn(function()
                    local function GetRootPart()
                        local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
                        return Character:WaitForChild("HumanoidRootPart", 5)
                    end

                    while AutoWorldItem do
                        local RootPart = GetRootPart()
                        local White = Workspace:FindFirstChild("Local") and Workspace.Local:FindFirstChild("Gizmos") and Workspace.Local.Gizmos:FindFirstChild("White")

                        if White and RootPart then
                            for _, Item in ipairs(White:GetChildren()) do
                                if Item.Name == "WorldItem" and AutoWorldItem then
                                    local Target = Item.PrimaryPart or Item:FindFirstChildWhichIsA("BasePart", true)

                                    if Target then
                                        RootPart.CFrame = Target.CFrame * CFrame.new(0, 0, -2.5)
                                        task.wait(0.2)
                                        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                        task.wait(0.05)
                                        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)

                                        repeat
                                            task.wait(0.1)
                                        until not Item.Parent or not AutoWorldItem
                                    end
                                end

                                if not AutoWorldItem then
                                    break
                                end
                            end
                        end
                        task.wait(0.5)
                    end
                end)
            else
                print("礼物盒：关闭")
            end
        end
    })

    local AutoSilverBar = false

    AutoPickupTab:Toggle({
        Title = "自动拾取银条",
        Default = AutoSilverBar,
        Callback = function(v)
            AutoSilverBar = v
            if v then
                task.spawn(function()
                    local function GetRootPart()
                        local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
                        return Character:WaitForChild("HumanoidRootPart", 5)
                    end

                    while AutoSilverBar do
                        local RootPart = GetRootPart()
                        local White = Workspace:FindFirstChild("Local") and Workspace.Local:FindFirstChild("Gizmos") and Workspace.Local.Gizmos:FindFirstChild("White")

                        if White and RootPart then
                            for _, Item in ipairs(White:GetChildren()) do
                                if Item.Name == "Silver Bar" and AutoSilverBar then
                                    local Target = Item.PrimaryPart or Item:FindFirstChildWhichIsA("BasePart", true)

                                    if Target then
                                        RootPart.CFrame = Target.CFrame * CFrame.new(0, 0, -2.5)
                                        task.wait(0.2)
                                        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                        task.wait(0.05)
                                        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)

                                        repeat
                                            task.wait(0.1)
                                        until not Item.Parent or not AutoSilverBar
                                    end
                                end

                                if not AutoSilverBar then
                                    break
                                end
                            end
                        end
                        task.wait(0.5)
                    end
                end)
            else
                print("银条：关闭")
            end
        end
    })

    local AutoSapphire = false

    AutoPickupTab:Toggle({
        Title = "自动拾取蓝宝石",
        Default = AutoSapphire,
        Callback = function(v)
            AutoSapphire = v
            if v then
                task.spawn(function()
                    local function GetRootPart()
                        local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
                        return Character:WaitForChild("HumanoidRootPart", 5)
                    end

                    while AutoSapphire do
                        local RootPart = GetRootPart()
                        local White = Workspace:FindFirstChild("Local") and Workspace.Local:FindFirstChild("Gizmos") and Workspace.Local.Gizmos:FindFirstChild("White")

                        if White and RootPart and White:FindFirstChild("Sapphire") and AutoSapphire then
                            local Item = White.Sapphire
                            local Target = Item.PrimaryPart or Item:FindFirstChildWhichIsA("BasePart", true)

                            if Target then
                                RootPart.CFrame = Target.CFrame * CFrame.new(0, 0, -2.5)
                                task.wait(0.2)
                                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                task.wait(0.05)
                                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)

                                repeat
                                    task.wait(0.1)
                                until not White:FindFirstChild("Sapphire") or not AutoSapphire
                            end
                        end
                        task.wait(0.5)
                    end
                end)
            else
                print("蓝宝石：关闭")
            end
        end
    })
local Main = Window:Tab({Title = "绕过类", Icon = "wind"})
local ImmuneTurret = false

Main:Toggle({
    Title = "绕过炮塔伤害",
    Default = ImmuneTurret,
    Callback = function(v)
        ImmuneTurret = v
        if v then
            local oldFireServer = game:GetService("ReplicatedStorage").Shared.Core.Network.FireServer
            game:GetService("ReplicatedStorage").Shared.Core.Network.FireServer = function(self, event, ...)
                if event == "registerLocalHit" and ... == "Turret" then
                    return nil
                end
                return oldFireServer(self, event, ...)
            end
        else
            game:GetService("ReplicatedStorage").Shared.Core.Network.FireServer = oldFireServer
        end
    end
})


    local WeaponTab = Window:Tab({Title = "武器修改", Icon = "target"})

    WeaponTab:Button({
        Title = "无限子弹",
        Callback = function()
            local Shooter = require(game:GetService("ReplicatedStorage").Client.Wanted.Objects.ClientTool.Components.Guns.Shooter)
            local originalShoot = Shooter._shoot
            Shooter._shoot = function(self)
                self.ammo = 9999
                self.totalAmmo = 9999
                return originalShoot(self)
            end
        end
    })

    WeaponTab:Button({
        Title = "无后坐力",
        Callback = function()
            local Shooter = require(game:GetService("ReplicatedStorage").Client.Wanted.Objects.ClientTool.Components.Guns.Shooter)
            local originalShoot = Shooter._shoot
            Shooter._shoot = function(self)
                self.recoil = {firstShotKick = 0, climb = 0, spread = 0}
                return originalShoot(self)
            end
        end
    })

    WeaponTab:Button({
        Title = "无扩散",
        Callback = function()
            local Shooter = require(game:GetService("ReplicatedStorage").Client.Wanted.Objects.ClientTool.Components.Guns.Shooter)
            local originalShoot = Shooter._shoot
            Shooter._shoot = function(self)
                self.aim = {spreadAngle = 0, zeroing = 1000}
                return originalShoot(self)
            end
        end
    })

    WeaponTab:Button({
        Title = "快速射击",
        Callback = function()
            local Shooter = require(game:GetService("ReplicatedStorage").Client.Wanted.Objects.ClientTool.Components.Guns.Shooter)
            local originalShoot = Shooter._shoot
            Shooter._shoot = function(self)
                self.tool.fireDebounce = 0
                self.tool.fireMode = "auto"
                return originalShoot(self)
            end
        end
    })

    WeaponTab:Button({
        Title = "无装弹",
        Callback = function()
            local Shooter = require(game:GetService("ReplicatedStorage").Client.Wanted.Objects.ClientTool.Components.Guns.Shooter)
            local originalShoot = Shooter._shoot
            Shooter._shoot = function(self)
                self.ammoData = {reloadTime = 0, magSize = 9999}
                return originalShoot(self)
            end
        end
    })

local Main = Window:Tab({Title = "自瞄", Icon = "crosshair"})
Main:Button({
    Title = "从外部加载自瞄",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/kongbaNB/9178/refs/heads/main/自瞄"))()
    end
})

local Main = Window:Tab({Title = "透视", Icon = "user"})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESPConfig = {
    ESPEnabled = false,
    ShowBox = false,
    ShowHealth = false,
    ShowName = false,
    ShowDistance = false,
    ShowTracer = false,
    TeamCheck = false,
    ShowSkeleton = false,
    ShowRadar = false,
    ShowPlayerCount = false,
    ShowWeapon = false,
    ShowFOV = false,
    OutOfViewArrows = false,
    Chams = false,

    TracerColor = Color3.new(1, 0, 0),
    SkeletonColor = Color3.new(0.2, 0.8, 1),
    BoxColor = Color3.new(1, 1, 1),
    HealthBarColor = Color3.new(0, 1, 0),
    HealthTextColor = Color3.new(1, 1, 1),
    NameColor = Color3.new(1, 1, 1),
    DistanceColor = Color3.new(1, 1, 0),
    WeaponColor = Color3.new(1, 0.5, 0),
    ArrowColor = Color3.new(1, 0, 0),
    FOVColor = Color3.new(1, 1, 1),
    ChamsColor = Color3.new(1, 0, 0),

    BoxThickness = 1,
    TracerThickness = 1,
    SkeletonThickness = 2,
    FOVRadius = 100,
    ArrowSize = 15
}

local function getGradientColor(time)
    local r = math.sin(time * 2) * 0.5 + 0.5
    local g = math.sin(time * 3) * 0.5 + 0.5
    local b = math.sin(time * 4) * 0.5 + 0.5
    return Color3.new(r, g, b)
end

local playerCountText = Drawing.new("Text")
playerCountText.Visible = false
playerCountText.Color = Color3.new(1, 1, 1)
playerCountText.Size = 20
playerCountText.Font = Drawing.Fonts.Monospace
playerCountText.Outline = true
playerCountText.OutlineColor = Color3.new(0, 0, 0)
playerCountText.Position = Vector2.new(Camera.ViewportSize.X / 2, 10)

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Color = ESPConfig.FOVColor
fovCircle.Thickness = 1
fovCircle.Filled = false
fovCircle.Radius = ESPConfig.FOVRadius
fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

local function updatePlayerCount()
    local playerCount = #Players:GetPlayers()
    playerCountText.Text = "在线玩家: " .. playerCount
    playerCountText.Visible = ESPConfig.ESPEnabled and ESPConfig.ShowPlayerCount

    local time = tick()
    playerCountText.Color = getGradientColor(time)
end

local function updateFOV()
    fovCircle.Visible = ESPConfig.ShowFOV
    fovCircle.Color = ESPConfig.FOVColor
    fovCircle.Radius = ESPConfig.FOVRadius
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

local ESPComponents = {}

local function createESP(player)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = ESPConfig.BoxColor
    box.Thickness = ESPConfig.BoxThickness
    box.Filled = false

    local healthBar = Drawing.new("Square")
    healthBar.Visible = false
    healthBar.Color = ESPConfig.HealthBarColor
    healthBar.Thickness = 1
    healthBar.Filled = true

    local healthBarBackground = Drawing.new("Square")
    healthBarBackground.Visible = false
    healthBarBackground.Color = Color3.new(0, 0, 0)
    healthBarBackground.Transparency = 0.5
    healthBarBackground.Thickness = 1
    healthBarBackground.Filled = true

    local healthBarBorder = Drawing.new("Square")
    healthBarBorder.Visible = false
    healthBarBorder.Color = Color3.new(1, 1, 1)
    healthBarBorder.Thickness = 1
    healthBarBorder.Filled = false

    local healthText = Drawing.new("Text")
    healthText.Visible = false
    healthText.Color = ESPConfig.HealthTextColor
    healthText.Size = 14
    healthText.Font = Drawing.Fonts.Monospace
    healthText.Outline = true
    healthText.OutlineColor = Color3.new(0, 0, 0)

    local nameText = Drawing.new("Text")
    nameText.Visible = false
    nameText.Color = ESPConfig.NameColor
    nameText.Size = 16
    nameText.Font = Drawing.Fonts.Monospace
    nameText.Outline = true
    nameText.OutlineColor = Color3.new(0, 0, 0)

    local distanceText = Drawing.new("Text")
    distanceText.Visible = false
    distanceText.Color = ESPConfig.DistanceColor
    distanceText.Size = 14
    distanceText.Font = Drawing.Fonts.Monospace
    distanceText.Outline = true
    distanceText.OutlineColor = Color3.new(0, 0, 0)

    local weaponText = Drawing.new("Text")
    weaponText.Visible = false
    weaponText.Color = ESPConfig.WeaponColor
    weaponText.Size = 14
    weaponText.Font = Drawing.Fonts.Monospace
    weaponText.Outline = true
    weaponText.OutlineColor = Color3.new(0, 0, 0)

    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = ESPConfig.TracerColor
    tracer.Thickness = ESPConfig.TracerThickness

    local arrow = Drawing.new("Triangle")
    arrow.Visible = false
    arrow.Color = ESPConfig.ArrowColor
    arrow.Filled = true
    arrow.Thickness = 1

    local skeletonLines = {}
    local skeletonPoints = {}

    local function createSkeleton()
        for i = 1, 15 do
            skeletonLines[i] = Drawing.new("Line")
            skeletonLines[i].Visible = false
            skeletonLines[i].Color = ESPConfig.SkeletonColor
            skeletonLines[i].Thickness = ESPConfig.SkeletonThickness
        end

        skeletonPoints["Head"] = Drawing.new("Circle")
        skeletonPoints["Head"].Visible = false
        skeletonPoints["Head"].Color = Color3.new(1, 0.5, 0)
        skeletonPoints["Head"].Thickness = 2
        skeletonPoints["Head"].Filled = true
        skeletonPoints["Head"].Radius = 4
    end

    createSkeleton()

    local lastHealth = 100
    local healthChangeTime = 0
    local smoothHealth = 100

    ESPComponents[player] = {
        box = box,
        healthBar = healthBar,
        healthBarBackground = healthBarBackground,
        healthBarBorder = healthBarBorder,
        healthText = healthText,
        nameText = nameText,
        distanceText = distanceText,
        weaponText = weaponText,
        tracer = tracer,
        arrow = arrow,
        skeletonLines = skeletonLines,
        skeletonPoints = skeletonPoints
    }

    RunService.RenderStepped:Connect(function()
        if not ESPConfig.ESPEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChild("Humanoid") or player == LocalPlayer then
            box.Visible = false
            healthBar.Visible = false
            healthBarBackground.Visible = false
            healthBarBorder.Visible = false
            healthText.Visible = false
            nameText.Visible = false
            distanceText.Visible = false
            weaponText.Visible = false
            tracer.Visible = false
            arrow.Visible = false
            for _, line in pairs(skeletonLines) do
                line.Visible = false
            end
            for _, point in pairs(skeletonPoints) do
                point.Visible = false
            end
            return
        end

        if ESPConfig.TeamCheck and player.Team == LocalPlayer.Team then
            box.Visible = false
            healthBar.Visible = false
            healthBarBackground.Visible = false
            healthBarBorder.Visible = false
            healthText.Visible = false
            nameText.Visible = false
            distanceText.Visible = false
            weaponText.Visible = false
            tracer.Visible = false
            arrow.Visible = false
            for _, line in pairs(skeletonLines) do
                line.Visible = false
            end
            for _, point in pairs(skeletonPoints) do
                point.Visible = false
            end
            return
        end

        local character = player.Character
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")

        if rootPart and humanoid and humanoid.Health > 0 then
            local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            local headPos, _ = Camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 3, 0))
            local legPos, _ = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))

            local weaponName = "无武器"
            for _, tool in ipairs(character:GetChildren()) do
                if tool:IsA("Tool") then
                    weaponName = tool.Name
                    break
                end
            end

            if ESPConfig.ShowBox and onScreen then
                box.Size = Vector2.new(1000 / rootPos.Z, headPos.Y - legPos.Y)
                box.Position = Vector2.new(rootPos.X - box.Size.X / 2, rootPos.Y - box.Size.Y / 2)
                box.Visible = true
                box.Color = ESPConfig.BoxColor
                box.Thickness = ESPConfig.BoxThickness
            else
                box.Visible = false
            end

            if ESPConfig.ShowHealth and onScreen then
                local healthPercentage = humanoid.Health / humanoid.MaxHealth
                local barWidth = 50
                local barHeight = 5
                local barX = headPos.X - barWidth / 2
                local barY = headPos.Y - 20

                healthBarBackground.Size = Vector2.new(barWidth, barHeight)
                healthBarBackground.Position = Vector2.new(barX, barY)
                healthBarBackground.Visible = true

                healthBarBorder.Size = Vector2.new(barWidth, barHeight)
                healthBarBorder.Position = Vector2.new(barX, barY)
                healthBarBorder.Visible = true

                smoothHealth = smoothHealth + (humanoid.Health - smoothHealth) * 0.1
                local smoothHealthPercentage = smoothHealth / humanoid.MaxHealth

                healthBar.Size = Vector2.new(barWidth * smoothHealthPercentage, barHeight)
                healthBar.Position = Vector2.new(barX, barY)

                if smoothHealthPercentage >= 0.8 then
                    healthBar.Color = Color3.new(0, 1, 0)
                elseif smoothHealthPercentage >= 0.5 then
                    healthBar.Color = Color3.new(1, 1, 0)
                elseif smoothHealthPercentage >= 0.2 then
                    healthBar.Color = Color3.new(1, 0.5, 0)
                else
                    healthBar.Color = Color3.new(1, 0, 0)
                end

                healthBar.Visible = true

                if humanoid.Health ~= lastHealth then
                    healthChangeTime = tick()
                    lastHealth = humanoid.Health
                end

                if tick() - healthChangeTime < 0.5 then
                    healthBar.Color = Color3.new(1, 0, 0)
                end

                healthText.Position = Vector2.new(barX + barWidth + 5, barY - 5)
                healthText.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                healthText.Visible = true
            else
                healthBar.Visible = false
                healthBarBackground.Visible = false
                healthBarBorder.Visible = false
                healthText.Visible = false
            end

            if ESPConfig.ShowName and onScreen then
                nameText.Position = Vector2.new(headPos.X, headPos.Y - 35)
                nameText.Text = player.Name
                nameText.Visible = true

                if ESPConfig.ShowDistance then
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                    distanceText.Position = Vector2.new(headPos.X, headPos.Y + 10)
                    distanceText.Text = math.floor(distance) .. "m"
                    distanceText.Visible = true
                else
                    distanceText.Visible = false
                end

                if ESPConfig.ShowWeapon then
                    weaponText.Position = Vector2.new(headPos.X, headPos.Y - 50)
                    weaponText.Text = weaponName
                    weaponText.Visible = true
                else
                    weaponText.Visible = false
                end
            else
                nameText.Visible = false
                distanceText.Visible = false
                weaponText.Visible = false
            end

            if ESPConfig.ShowTracer then
                local head = character:FindFirstChild("Head")
                if head then
                    local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        tracer.To = Vector2.new(headPos.X, headPos.Y)
                        tracer.Visible = true
                        tracer.Color = ESPConfig.TracerColor
                        tracer.Thickness = ESPConfig.TracerThickness


                        local distance = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                        if distance < 20 then
                            tracer.Color = Color3.new(0, 1, 0)
                        elseif distance < 50 then
                            tracer.Color = Color3.new(1, 1, 0)
                        else
                            tracer.Color = ESPConfig.TracerColor
                        end
                    else
                        tracer.Visible = false
                    end
                else
                    tracer.Visible = false
                end
            else
                tracer.Visible = false
            end


            if ESPConfig.OutOfViewArrows and not onScreen then
                local direction = (rootPart.Position - Camera.CFrame.Position).Unit
                local dotProduct = Camera.CFrame.RightVector:Dot(direction)
                local crossProduct = Camera.CFrame.RightVector:Cross(direction)

                local screenPosition = Vector2.new(
                    Camera.ViewportSize.X / 2 + dotProduct * Camera.ViewportSize.X / 3,
                    Camera.ViewportSize.Y / 2 - crossProduct.Y * Camera.ViewportSize.Y / 3
                )

                screenPosition = Vector2.new(
                    math.clamp(screenPosition.X, ESPConfig.ArrowSize, Camera.ViewportSize.X - ESPConfig.ArrowSize),
                    math.clamp(screenPosition.Y, ESPConfig.ArrowSize, Camera.ViewportSize.Y - ESPConfig.ArrowSize)
                )

                local angle = math.atan2(screenPosition.Y - Camera.ViewportSize.Y / 2, screenPosition.X - Camera.ViewportSize.X / 2)

                arrow.PointA = screenPosition
                arrow.PointB = Vector2.new(
                    screenPosition.X - ESPConfig.ArrowSize * math.cos(angle - 0.5),
                    screenPosition.Y - ESPConfig.ArrowSize * math.sin(angle - 0.5)
                )
                arrow.PointC = Vector2.new(
                    screenPosition.X - ESPConfig.ArrowSize * math.cos(angle + 0.5),
                    screenPosition.Y - ESPConfig.ArrowSize * math.sin(angle + 0.5)
                )

                arrow.Color = ESPConfig.ArrowColor
                arrow.Visible = true
            else
                arrow.Visible = false
            end


            if ESPConfig.ShowSkeleton and onScreen then
                local head = character:FindFirstChild("Head")
                local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
                local leftArm = character:FindFirstChild("Left Arm") or character:FindFirstChild("LeftUpperArm")
                local rightArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightUpperArm")
                local leftLeg = character:FindFirstChild("Left Leg") or character:FindFirstChild("LeftUpperLeg")
                local rightLeg = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightUpperLeg")

                if head and torso and leftArm and rightArm and leftLeg and rightLeg then
                    local headPos = Camera:WorldToViewportPoint(head.Position)
                    local torsoPos = Camera:WorldToViewportPoint(torso.Position)
                    local leftArmPos = Camera:WorldToViewportPoint(leftArm.Position)
                    local rightArmPos = Camera:WorldToViewportPoint(rightArm.Position)
                    local leftLegPos = Camera:WorldToViewportPoint(leftLeg.Position)
                    local rightLegPos = Camera:WorldToViewportPoint(rightLeg.Position)

                    skeletonPoints["Head"].Position = Vector2.new(headPos.X, headPos.Y)
                    skeletonPoints["Head"].Visible = true


                    skeletonLines[1].From = Vector2.new(headPos.X, headPos.Y)
                    skeletonLines[1].To = Vector2.new(torsoPos.X, torsoPos.Y)
                    skeletonLines[1].Visible = true

                    skeletonLines[2].From = Vector2.new(torsoPos.X, torsoPos.Y)
                    skeletonLines[2].To = Vector2.new(leftArmPos.X, leftArmPos.Y)
                    skeletonLines[2].Visible = true

                    skeletonLines[3].From = Vector2.new(torsoPos.X, torsoPos.Y)
                    skeletonLines[3].To = Vector2.new(rightArmPos.X, rightArmPos.Y)
                    skeletonLines[3].Visible = true

                    skeletonLines[4].From = Vector2.new(torsoPos.X, torsoPos.Y)
                    skeletonLines[4].To = Vector2.new(leftLegPos.X, leftLegPos.Y)
                    skeletonLines[4].Visible = true

                    skeletonLines[5].From = Vector2.new(torsoPos.X, torsoPos.Y)
                    skeletonLines[5].To = Vector2.new(rightLegPos.X, rightLegPos.Y)
                    skeletonLines[5].Visible = true


                    if character:FindFirstChild("LeftLowerArm") then
                        local leftLowerArmPos = Camera:WorldToViewportPoint(character.LeftLowerArm.Position)
                        skeletonLines[6].From = Vector2.new(leftArmPos.X, leftArmPos.Y)
                        skeletonLines[6].To = Vector2.new(leftLowerArmPos.X, leftLowerArmPos.Y)
                        skeletonLines[6].Visible = true
                    end

                    if character:FindFirstChild("RightLowerArm") then
                        local rightLowerArmPos = Camera:WorldToViewportPoint(character.RightLowerArm.Position)
                        skeletonLines[7].From = Vector2.new(rightArmPos.X, rightArmPos.Y)
                        skeletonLines[7].To = Vector2.new(rightLowerArmPos.X, rightLowerArmPos.Y)
                        skeletonLines[7].Visible = true
                    end

                    if character:FindFirstChild("LeftLowerLeg") then
                        local leftLowerLegPos = Camera:WorldToViewportPoint(character.LeftLowerLeg.Position)
                        skeletonLines[8].From = Vector2.new(leftLegPos.X, leftLegPos.Y)
                        skeletonLines[8].To = Vector2.new(leftLowerLegPos.X, leftLowerLegPos.Y)
                        skeletonLines[8].Visible = true
                    end

                    if character:FindFirstChild("RightLowerLeg") then
                        local rightLowerLegPos = Camera:WorldToViewportPoint(character.RightLowerLeg.Position)
                        skeletonLines[9].From = Vector2.new(rightLegPos.X, rightLegPos.Y)
                        skeletonLines[9].To = Vector2.new(rightLowerLegPos.X, rightLowerLegPos.Y)
                        skeletonLines[9].Visible = true
                    end
                else
                    for _, line in pairs(skeletonLines) do
                        line.Visible = false
                    end
                    for _, point in pairs(skeletonPoints) do
                        point.Visible = false
                    end
                end
            else
                for _, line in pairs(skeletonLines) do
                    line.Visible = false
                end
                for _, point in pairs(skeletonPoints) do
                    point.Visible = false
                end
            end
        else
            box.Visible = false
            healthBar.Visible = false
            healthBarBackground.Visible = false
            healthBarBorder.Visible = false
            healthText.Visible = false
            nameText.Visible = false
            distanceText.Visible = false
            weaponText.Visible = false
            tracer.Visible = false
            arrow.Visible = false
            for _, line in pairs(skeletonLines) do
                line.Visible = false
            end
            for _, point in pairs(skeletonPoints) do
                point.Visible = false
            end
        end
    end)
end
local radar = Drawing.new("Circle")
radar.Visible = false
radar.Color = Color3.new(1, 1, 1)
radar.Thickness = 2
radar.Filled = false
radar.Radius = 100
radar.Position = Vector2.new(Camera.ViewportSize.X - 120, 120)

local radarCenter = Drawing.new("Circle")
radarCenter.Visible = false
radarCenter.Color = Color3.new(1, 1, 1)
radarCenter.Thickness = 2
radarCenter.Filled = true
radarCenter.Radius = 3
radarCenter.Position = radar.Position

local radarDirection = Drawing.new("Line")
radarDirection.Visible = false
radarDirection.Color = Color3.new(1, 1, 1)
radarDirection.Thickness = 2

local radarGridLines = {}
for i = 1, 4 do
    radarGridLines[i] = Drawing.new("Line")
    radarGridLines[i].Visible = false
    radarGridLines[i].Color = Color3.new(0.5, 0.5, 0.5)
    radarGridLines[i].Thickness = 1
end

local radarRangeText = Drawing.new("Text")
radarRangeText.Visible = false
radarRangeText.Color = Color3.new(1, 1, 1)
radarRangeText.Size = 14
radarRangeText.Font = Drawing.Fonts.Monospace
radarRangeText.Outline = true
radarRangeText.OutlineColor = Color3.new(0, 0, 0)
radarRangeText.Text = "100m"

local radarPlayers = {}

local function updateRadar()
    if not ESPConfig.ShowRadar then
        radar.Visible = false
        radarCenter.Visible = false
        radarDirection.Visible = false
        radarRangeText.Visible = false

        for _, line in pairs(radarGridLines) do
            line.Visible = false
        end

        for _, player in pairs(radarPlayers) do
            if player.dot then player.dot.Visible = false end
            if player.direction then player.direction.Visible = false end
            if player.name then player.name.Visible = false end
        end
        return
    end

    radar.Visible = true
    radarCenter.Visible = true
    radarDirection.Visible = true
    radarRangeText.Visible = true

    radarRangeText.Position = Vector2.new(radar.Position.X, radar.Position.Y + radar.Radius + 5)


    for i = 1, 4 do
        local angle = (i-1) * math.pi / 2
        radarGridLines[i].From = radar.Position
        radarGridLines[i].To = Vector2.new(
            radar.Position.X + math.cos(angle) * radar.Radius,
            radar.Position.Y + math.sin(angle) * radar.Radius
        )
        radarGridLines[i].Visible = true
    end

    radarDirection.From = radar.Position
    radarDirection.To = Vector2.new(radar.Position.X, radar.Position.Y - radar.Radius)


    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= LocalPlayer then
            local rootPart = player.Character.HumanoidRootPart
            local relativePosition = rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position

            local radarX = radar.Position.X + (relativePosition.X / 10)
            local radarY = radar.Position.Y + (relativePosition.Z / 10)

            local distanceFromCenter = math.sqrt((radarX - radar.Position.X)^2 + (radarY - radar.Position.Y)^2)

            if distanceFromCenter > radar.Radius then
                local angle = math.atan2(radarY - radar.Position.Y, radarX - radar.Position.X)
                radarX = radar.Position.X + math.cos(angle) * radar.Radius
                radarY = radar.Position.Y + math.sin(angle) * radar.Radius
            end

            if not radarPlayers[player] then
                radarPlayers[player] = {
                    dot = Drawing.new("Circle"),
                    direction = Drawing.new("Line"),
                    name = Drawing.new("Text")
                }

                radarPlayers[player].dot.Thickness = 1
                radarPlayers[player].dot.Filled = true
                radarPlayers[player].dot.Radius = 4

                radarPlayers[player].direction.Thickness = 2
                radarPlayers[player].direction.Visible = true

                radarPlayers[player].name.Size = 12
                radarPlayers[player].name.Font = Drawing.Fonts.Monospace
                radarPlayers[player].name.Outline = true
                radarPlayers[player].name.OutlineColor = Color3.new(0, 0, 0)
            end


            if player.Team == LocalPlayer.Team then
                radarPlayers[player].dot.Color = Color3.new(0, 1, 0)
                radarPlayers[player].direction.Color = Color3.new(0, 0.8, 0)
                radarPlayers[player].name.Color = Color3.new(0, 1, 0)
            else
                radarPlayers[player].dot.Color = Color3.new(1, 0, 0)
                radarPlayers[player].direction.Color = Color3.new(1, 0, 0)
                radarPlayers[player].name.Color = Color3.new(1, 0, 0)
            end

            radarPlayers[player].dot.Position = Vector2.new(radarX, radarY)
            radarPlayers[player].dot.Visible = true


            local lookVector = rootPart.CFrame.LookVector
            local directionLength = 10
            radarPlayers[player].direction.From = Vector2.new(radarX, radarY)
            radarPlayers[player].direction.To = Vector2.new(
                radarX + lookVector.X * directionLength,
                radarY + lookVector.Z * directionLength
            )

            radarPlayers[player].name.Position = Vector2.new(radarX, radarY - 15)
            radarPlayers[player].name.Text = player.Name
            radarPlayers[player].name.Visible = distanceFromCenter <= radar.Radius
        elseif radarPlayers[player] then
            radarPlayers[player].dot.Visible = false
            radarPlayers[player].direction.Visible = false
            radarPlayers[player].name.Visible = false
        end
    end
    for player, components in pairs(radarPlayers) do
        if not Players:FindFirstChild(player.Name) then
            components.dot.Visible = false
            components.direction.Visible = false
            components.name.Visible = false
            radarPlayers[player] = nil
        end
    end
end
RunService.RenderStepped:Connect(updateRadar)
RunService.RenderStepped:Connect(updatePlayerCount)
RunService.RenderStepped:Connect(updateFOV)
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createESP(player)
    end
end)
Players.PlayerRemoving:Connect(function(player)
    if ESPComponents[player] then
        for _, component in pairs(ESPComponents[player]) do
            if typeof(component) == "table" then
                for _, drawing in pairs(component) do
                    drawing:Remove()
                end
            else
                component:Remove()
            end
        end
        ESPComponents[player] = nil
    end
end)

Main:Toggle({
    Title = "ESP总开关",
    Value = false,
    Callback = function(value)
        ESPConfig.ESPEnabled = value
    end
})

Main:Toggle({
    Title = "显示方框",
    Value = false,
    Callback = function(value)
        ESPConfig.ShowBox = value
    end
})

Main:Toggle({
    Title = "显示血量",
    Value = false,
    Callback = function(value)
        ESPConfig.ShowHealth = value
    end
})

Main:Toggle({
    Title = "显示名称",
    Value = false,
    Callback = function(value)
        ESPConfig.ShowName = value
    end
})

Main:Toggle({
    Title = "显示距离",
    Value = false,
    Callback = function(value)
        ESPConfig.ShowDistance = value
    end
})

Main:Toggle({
    Title = "显示射线",
    Value = false,
    Callback = function(value)
        ESPConfig.ShowTracer = value
    end
})

Main:Toggle({
    Title = "队伍检查",
    Value = false,
    Callback = function(value)
        ESPConfig.TeamCheck = value
    end
})

Main:Toggle({
    Title = "显示骨骼",
    Value = false,
    Callback = function(value)
        ESPConfig.ShowSkeleton = value
    end
})

Main:Toggle({
    Title = "显示雷达",
    Value = false,
    Callback = function(value)
        ESPConfig.ShowRadar = value
    end
})

Main:Toggle({
    Title = "显示玩家计数",
    Value = false,
    Callback = function(value)
        ESPConfig.ShowPlayerCount = value
    end
})

Main:Toggle({
    Title = "显示武器",
    Value = false,
    Callback = function(value)
        ESPConfig.ShowWeapon = value
    end
})

Main:Toggle({
    Title = "屏幕外箭头",
    Value = false,
    Callback = function(value)
        ESPConfig.OutOfViewArrows = value
    end
})

Main:Toggle({
    Title = "显示 Chams",
    Value = false,
    Callback = function(value)
        ESPConfig.Chams = value
    end
})
Main:Slider({
    Title = "方框粗细",
    Desc = "滑动调整",
    Value = {
        Min = 1,
        Max = 5,
        Default = ESPConfig.BoxThickness,
    },
    Callback = function(Value)
        ESPConfig.BoxThickness = Value
    end
})

Main:Slider({
    Title = "射线粗细",
    Desc = "滑动调整",
    Value = {
        Min = 1,
        Max = 5,
        Default = ESPConfig.TracerThickness,
    },
    Callback = function(Value)
        ESPConfig.TracerThickness = Value
    end
})

Main:Slider({
    Title = "骨骼粗细",
    Desc = "滑动调整",
    Value = {
        Min = 1,
        Max = 5,
        Default = ESPConfig.SkeletonThickness,
    },
    Callback = function(Value)
        ESPConfig.SkeletonThickness = Value
    end
})

Main:Slider({
    Title = "箭头大小",
    Desc = "滑动调整",
    Value = {
        Min = 5,
        Max = 30,
        Default = ESPConfig.ArrowSize,
    },
    Callback = function(Value)
        ESPConfig.ArrowSize = Value
    end
})
    local TeleportPlayerTab = Window:Tab({Title = "玩家传送", Icon = "user"})

    local TargetPlayerName = ""
    local TeleportPosition = "前方"

    TeleportPlayerTab:Input({
        Title = "输入玩家用户名",
        Placeholder = "输入玩家名称",
        Callback = function(v)
            TargetPlayerName = v
        end
    })

    TeleportPlayerTab:Dropdown({
        Title = "传送部位",
        Values = {"前方", "后方", "头顶", "左侧", "右侧"},
        Value = TeleportPosition,
        Callback = function(v)
            TeleportPosition = v
        end
    })

    TeleportPlayerTab:Button({
        Title = "传送一次",
        Callback = function()
            if TargetPlayerName and TeleportPosition then
                local targetPlayer = game.Players:FindFirstChild(TargetPlayerName)

                if targetPlayer and targetPlayer ~= game.Players.LocalPlayer then
                    if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local p = game.Players.LocalPlayer
                        local c = p.Character or p.CharacterAdded:Wait()
                        local h = c:WaitForChild("HumanoidRootPart")
                        local targetCFrame = targetPlayer.Character.HumanoidRootPart.CFrame

                        if TeleportPosition == "前方" then
                            h.CFrame = targetCFrame * CFrame.new(0, 0, -5)
                        elseif TeleportPosition == "后方" then
                            h.CFrame = targetCFrame * CFrame.new(0, 0, 5)
                        elseif TeleportPosition == "头顶" then
                            h.CFrame = targetCFrame * CFrame.new(0, 5, 0)
                        elseif TeleportPosition == "左侧" then
                            h.CFrame = targetCFrame * CFrame.new(-5, 0, 0)
                        elseif TeleportPosition == "右侧" then
                            h.CFrame = targetCFrame * CFrame.new(5, 0, 0)
                        end
                    end
                end
            end
        end
    })

    local FixedTeleport = false

    TeleportPlayerTab:Toggle({
        Title = "固定传送",
        Default = FixedTeleport,
        Callback = function(v)
            FixedTeleport = v
            if v then
                task.spawn(function()
                    while FixedTeleport do
                        if TargetPlayerName and TeleportPosition then
                            local targetPlayer = game.Players:FindFirstChild(TargetPlayerName)

                            if targetPlayer and targetPlayer ~= game.Players.LocalPlayer then
                                if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                    local p = game.Players.LocalPlayer
                                    local c = p.Character or p.CharacterAdded:Wait()
                                    local h = c:WaitForChild("HumanoidRootPart")
                                    local targetCFrame = targetPlayer.Character.HumanoidRootPart.CFrame

                                    if TeleportPosition == "前方" then
                                        h.CFrame = targetCFrame * CFrame.new(0, 0, -5)
                                    elseif TeleportPosition == "后方" then
                                        h.CFrame = targetCFrame * CFrame.new(0, 0, 5)
                                    elseif TeleportPosition == "头顶" then
                                        h.CFrame = targetCFrame * CFrame.new(0, 5, 0)
                                    elseif TeleportPosition == "左侧" then
                                        h.CFrame = targetCFrame * CFrame.new(-5, 0, 0)
                                    elseif TeleportPosition == "右侧" then
                                        h.CFrame = targetCFrame * CFrame.new(5, 0, 0)
                                    end
                                end
                            end
                        end
                        task.wait(0.1)
                    end
                end)
            end
        end
    })

    local TeleportSection = Window:Tab({Title = "地点传送", Icon = "map-pin"})

    TeleportSection:Button({
        Title = "传送到奥菲的价值兑换",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(-2907.68848, 37.1002731, 1444.74817, 0.848566413, 3.9380446e-8, -0.529088855, -1.774107e-8, 1, 4.5977092e-8, 0.529088855, -2.962804e-8, 0.848566413)
        end
    })

    TeleportSection:Button({
        Title = "传送到绿洲银行",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(-431.537354, 39.6113892, -1400.08313, -0.901108384, -1.61008e-8, -0.433593899, -5.2681104e-9, 1, -2.618487e-8, 0.433593899, -2.1311186e-8, -0.901108384)
        end
    })

    TeleportSection:Button({
        Title = "传送到绿洲城警察",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(2578.02393, 119.169289, -718.579773, -0.395326763, -5.9598324e-8, -0.918540537, -9.65633e-9, 1, -5.232432e-8, 0.918540537, 7.947669e-8, -0.395326763)
        end
    })

    TeleportSection:Button({
        Title = "传送到金库",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(-400.492279, 163.151733, -1242.72632, -0.912052214, -1.09039995e-8, -0.410074085, 1.4650267e-8, 1, -5.9174205e-8, 0.410074085, -5.997766e-8, -0.912052214)
        end
    })

    TeleportSection:Button({
        Title = "传送到犯罪基地",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(-5981.50586, 37.2680244, 1245.22046, -0.733384013, -3.6538985e-8, -0.679814577, -1.7351333e-8, 1, -3.502984e-8, 0.679814577, -1.38946366e-8, -0.733384013)
        end
    })

    TeleportSection:Button({
        Title = "传送到烈焰要塞",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(-1494.58496, 41.16481, 3364.56055, 0.961387396, 1.07588015e-7, 0.275198698, -9.5233396e-8, 1, -5.8255473e-8, -0.275198698, 2.97983e-8, 0.961387396)
        end
    })

    TeleportSection:Button({
        Title = "传送到枪店",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(-180.77, 43.13, -2805.05)
        end
    })

    TeleportSection:Button({
        Title = "传送到手机店",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(-905.70, 42.98, -1563.35)
        end
    })

    TeleportSection:Button({
        Title = "传送到黑市",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(-2907.39, 37.58, 1652.25)
        end
    })

    TeleportSection:Button({
        Title = "传送到犯罪窝点",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(-7939.26, 21.74, 1073.52)
        end
    })

    TeleportSection:Button({
        Title = "传送到小银行",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(-6852.36, 42.61, 965.86)
        end
    })

    TeleportSection:Button({
        Title = "传送到银行内部",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(-399.28, 617.63, -1245.29)
        end
    })

    TeleportSection:Button({
        Title = "传送到警察局",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(1583.31, 119.86, -716.63)
        end
    })

    local GunsTab = Window:Tab({Title = "武器传送", Icon = "target"})

    GunsTab:Button({
        Title = "AWP狙击枪",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(-822.97, 326.09, -506.58)
            task.wait(0.5)
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end
    })

    GunsTab:Button({
        Title = "自动瞄准器",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(-822.973816, 179.617432, -290.576813, -0.829824746, 4.1572e-8, 0.558024108, -1.7091425e-8, 1, -9.991484e-8, -0.558024108, -9.24494e-8, -0.829824746)
            task.wait(0.5)
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end
    })

    GunsTab:Button({
        Title = "UMP 45",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(1358.20264, 143.366074, -1218.008301, -0.711087286, 7.777568e-9, -0.703103721, 0.0004326, 1, 1.0624305e-8, 0.703103721, 7.2505e-9, -0.711087286)
            task.wait(0.5)
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end
    })

    GunsTab:Button({
        Title = "贝内利M1014",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(1345.20422, 141.041168, -4809.10693, -0.879722357, 4.0964014e-8, -0.475487679, 7.8684534e-9, 1, 7.159378e-8, 0.475487679, 5.92413e-8, -0.879722357)
            task.wait(0.5)
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end
    })

    GunsTab:Button({
        Title = "M4A1",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(-6342.43115, 134.380051, -1328.82861, -0.984255195, 1.02914e-8, 0.176753372, 1.648925e-8, 1, 3.359626e-8, -0.176753372, 3.59818e-8, -0.984255195)
            task.wait(0.5)
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end
    })

    GunsTab:Button({
        Title = "AK-47",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(-4825.20752, 21.3648071, 1192.14551, -0.907641709, 3.2050632e-8, -0.419745833, 5.61627e-8, 1, -4.508672e-8, 0.419745833, -6.44966e-8, -0.907641709)
            task.wait(0.5)
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end
    })

    GunsTab:Button({
        Title = "RPG-7",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(-1392.19739, 275.933319, 2199.5188, -0.999439657, -4.083614e-8, -0.0334718302, -4.136207e-8, 1, 1.50201e-8, 0.0334718302, 1.6396225e-8, -0.999439657)
            task.wait(0.5)
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end
    })

    GunsTab:Button({
        Title = "乌兹",
        Callback = function()
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local h = c:WaitForChild("HumanoidRootPart")
            h.CFrame = CFrame.new(-1348.55493, 1109.2014694, 2033.73645, -0.322550327, 6.191085e-8, -0.946552336, 8.2431725e-8, 1, 3.731697e-8, 0.946552336, -6.598934e-8, -0.322550327)
            task.wait(0.5)
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end
    })
local SettingsTab = ObsWindow:AddTab("设置", "settings")
local UnloadGroup = SettingsTab:AddLeftGroupbox("脚本管理")
UnloadGroup:AddButton("卸载脚本", function() Library:Unload() end)
if ThemeManager then
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("MyScriptTheme")
    ThemeManager:ApplyToTab(SettingsTab)
end
if SaveManager then
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetFolder("MyScriptConfig")
    SaveManager:BuildConfigSection(SettingsTab)
end
