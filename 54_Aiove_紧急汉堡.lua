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

local Options = Library.Options
local Toggles = Library.Toggles

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function destination()
    local dest = nil
    for i,v in pairs(workspace.DeliveryDestinations:GetDescendants()) do
        if v.Name == "SelectionBox" and v.Visible == true and v.Transparency ~= 1 then
            dest = v.Parent
        end
    end
    return dest
end

local function getplayer(plr)
    local player = nil
    for i,v in pairs(Players:GetPlayers()) do
        if string.find(v.Name,plr) or string.find(v.DisplayName,plr) then
            player = v.Name
            break
        end
    end
    return player
end

local function shiftfind()
    local shift = nil
    local uifind = nil
    local busdriver = getfenv().drivertype or "Rural Bus Driver"
    for i,v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
        if v.ClassName == "TextLabel" and v.Text == "Start Shift" or v.ClassName == "ImageButton" and v.Name == busdriver then
            shift = v.Parent
        end
    end
    if shift ~= nil then
        for i,v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
            if shift:IsDescendantOf(v) then
                uifind = v
            end
        end
    end
    return uifind
end

local function dealership()
    local deal = nil
    local uifind = nil
    for i,v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
        if v.ClassName == "TextLabel" and v.Text == "Stuttgart Lastkraft" or v.ClassName == "TextLabel" and v.Text == "Stuttgart Omnibus" then
            deal = v
        end
    end
    if deal ~= nil then
        for i,v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
            if deal:IsDescendantOf(v) then
                uifind = v
            end
        end
    end
    return uifind
end

local function partfind()
    local part = nil
    for i,v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
        if v.ClassName == "BillboardGui" and v.Adornee ~= nil then
            part = v.Adornee
        end
    end
    return part
end

local function findxpui()
    local xpui = nil
    local test = nil
    for i,v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
        if v.ClassName == "TextLabel" and string.find(v.Text,"XP") and v.Parent.ClassName == "ImageButton" and tonumber(v.Text:split(" ")[1]) then
            test = v
            break
        end
    end
    if test ~= nil then
        for i,v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
            if test:IsDescendantOf(v) then
                xpui = v
            end
        end
    end
    return xpui
end

local function vehicleTeleport(cf)
    workspace.Vehicles:FindFirstChild(LocalPlayer.Name).PrimaryPart = workspace.Vehicles:FindFirstChild(LocalPlayer.Name).Body.Mass
    local time = tick()
    repeat task.wait()
        if LocalPlayer.Character.Humanoid.SeatPart == nil then
            workspace.Vehicles:FindFirstChild(LocalPlayer.Name).DriveSeat:Sit(LocalPlayer.Character.Humanoid)
            time = tick()
            wait(1)
            time = tick()
        elseif LocalPlayer.Character.Humanoid.SeatPart ~= nil then
            workspace.Vehicles:FindFirstChild(LocalPlayer.Name):PivotTo(cf)
        end
    until tick()-time > 2
end

local Window = Library:CreateWindow({
    Title = "紧急汉堡",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify({
    Title = "紧急汉堡",
    Description = "创作者：Aiove\nQQ：3999698324\n脚本已加载成功",
    Time = 5,
})

local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    System = Window:AddTab("系统", "info"),
    AutoWork = Window:AddTab("自动工作", "info"),
    Player = Window:AddTab("玩家设置", "info"),
    Aimbot = Window:AddTab("自动瞄准", "info"),
    Teleport = Window:AddTab("传送", "info"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel("Aiove将持续更新此脚本")
NoticeGroup:AddLabel("创作者：Aiove")

local SystemGroup = Tabs.System:AddLeftGroupbox("系统")
SystemGroup:AddLabel("两个都开")

SystemGroup:AddButton("饶过检测", function()
    local function funcnil()
        local func = nil
        for i,v in pairs(getgc(true)) do
            if type(v) == "function" and getfenv(v).script == Players.LocalPlayer.PlayerScripts.Code.controllers.antiCheatController and tostring(getinfo(v).name) ~= nil and tostring(getinfo(v).name) ~= "" then
                func = v
            end
        end
        return func
    end

    repeat task.wait()
        for i,v in pairs(getgc(true)) do
            if type(v) == "function" and getfenv(v).script == Players.LocalPlayer.PlayerScripts.Code.controllers.antiCheatController then
                warn(getinfo(v).name)
                hookfunction(v,function()
                    return
                end)
            end
        end
        wait(1)
        print(funcnil())
    until funcnil() == nil
    wait(2)
    warn("反检测已禁用")
end)

SystemGroup:AddToggle("AntiAFK", {
    Text = "防挂机",
    Default = false,
    Callback = function(Value)
        if Value then
            warn("防挂机运行中")
            LocalPlayer.Idled:connect(function()
                warn("触发防挂机")
                game:GetService("VirtualUser"):CaptureController()
                game:GetService("VirtualUser"):ClickButton2(Vector2.new())
            end)
        end
    end,
})

local AutoWorkGroup = Tabs.AutoWork:AddLeftGroupbox("自动工作")

AutoWorkGroup:AddToggle("BusDriver", {
    Text = "自动公交车司机",
    Default = false,
    Callback = function(Value)
        getfenv().busman = Value
        if Value then
            spawn(function()
                while getfenv().busman do
                    task.wait()
                    pcall(function()
                        local plr = LocalPlayer
                        local car = workspace.Vehicles:FindFirstChild(plr.Name)
                        if workspace.Vehicles:FindFirstChild(plr.Name) and string.find(tostring(car:GetAttribute("Model")),"Bus Driver") and partfind() ~= nil and LocalPlayer.Character.Humanoid.SeatPart == nil then
                            car.DriveSeat:Sit(LocalPlayer.Character.Humanoid)
                        end
                    end)
                end
            end)

            spawn(function()
                while getfenv().busman do
                    task.wait()
                    pcall(function()
                        if LocalPlayer.Character.Humanoid.Health < 60 and LocalPlayer.Character.Humanoid.SeatPart == nil then
                            LocalPlayer.Character:BreakJoints()
                            warn("角色血量过低，已重置")
                        end
                    end)
                end
            end)

            task.spawn(function()
                while getfenv().busman do
                    wait()
                    pcall(function()
                        workspace.Gravity = 196
                        local plr = LocalPlayer
                        local car = workspace.Vehicles[plr.Name]
                        if workspace.Vehicles:FindFirstChild(plr.Name) and LocalPlayer.Team ~= game:GetService("Teams").BusCompany then
                            repeat wait()
                                workspace.Vehicles:FindFirstChild(LocalPlayer.Name).DriveSeat:Sit(LocalPlayer.Character.Humanoid)
                            until LocalPlayer.Character.Humanoid.SeatPart ~= nil
                            wait()
                            workspace.Vehicles:FindFirstChild(LocalPlayer.Name):PivotTo(CFrame.new(-1683.09375, 15.630923271179199, -1286.167236328125))
                            wait(5)
                            LocalPlayer.Character.Humanoid.Sit = false
                            wait(2)

                            if LocalPlayer:DistanceFromCharacter(Vector3.new(-1683.09375, 5.630923271179199, -1286.167236328125)) < 50 then

                                LocalPlayer.Character.Humanoid:MoveTo(Vector3.new(-1708.8741455078125, 5.616213321685791, -1281.946044921875))
                                LocalPlayer.Character.Humanoid.MoveToFinished:wait()
                                LocalPlayer.Character.Humanoid:MoveTo(Vector3.new(-1730.544677734375, 5.683385848999023, -1280.9140625))
                                LocalPlayer.Character.Humanoid.MoveToFinished:wait()

                                repeat wait()
                                    game:GetService("VirtualInputManager"):SendKeyEvent(true,"E",false,game)
                                    game:GetService("VirtualInputManager"):SendKeyEvent(false,"E",false,game)
                                until shiftfind() ~= nil

                                wait(3)
                                local busdriver = getfenv().drivertype or "Rural Bus Driver"
                                for i,v in pairs(shiftfind():GetDescendants()) do
                                    if v.ClassName == "ImageButton" and v.Name == busdriver then
                                        if v.Parent ~= nil then
                                            firesignal(v.MouseButton1Click)
                                        end
                                    end
                                end

                                wait(3)
                                for i,v in pairs(shiftfind():GetDescendants()) do
                                    if v.ClassName == "ImageButton" and v.ImageColor3 == Color3.fromRGB(142, 68, 173) then
                                        if v.Parent ~= nil then
                                            firesignal(v.MouseButton1Click)
                                        end
                                    end
                                end

                                wait(2)

                                LocalPlayer.Character.Humanoid:MoveTo(Vector3.new(-1722.3858642578125, 5.645286560058594, -1264.3126220703125))
                                LocalPlayer.Character.Humanoid.MoveToFinished:wait()

                                repeat wait()
                                    game:GetService("VirtualInputManager"):SendKeyEvent(true,"E",false,game)
                                    game:GetService("VirtualInputManager"):SendKeyEvent(false,"E",false,game)
                                until dealership() ~= nil and dealership().Enabled == true or partfind() ~= nil

                                wait(2)
                                for i,v in pairs(dealership():GetDescendants()) do
                                    if v.ClassName == "TextLabel" and v.Text == "Stuttgart Omnibus" then
                                        local plr = LocalPlayer
                                        repeat wait()
                                            if v.Parent ~= nil then
                                                firesignal(v.Parent.MouseButton1Click)
                                                for a,b in pairs(dealership():GetDescendants()) do
                                                    if b.ClassName == "ImageButton" and b:FindFirstChildOfClass("TextLabel").Text == "Spawn Vehicle" or b.ClassName == "ImageButton" and b:FindFirstChildOfClass("TextLabel").Text == "Unlock Vehicle" then
                                                        firesignal(b.MouseButton1Click)
                                                    end
                                                end
                                            end
                                        until workspace.Vehicles:FindFirstChild(plr.Name) and partfind() ~= nil or partfind() ~= nil
                                    end
                                end
                            end
                        elseif partfind() ~= nil and LocalPlayer.Character.Humanoid.SeatPart ~= nil then

                            workspace.Gravity = 0
                            local plr = LocalPlayer
                            local chr = plr.Character
                            local car = workspace.Vehicles[plr.Name]
                            car.PrimaryPart = car.Body.Mass
                            local pos = destination() or partfind()

                            if (car.WorldPivot.Position-Vector3.new(pos.Position.X,car.PrimaryPart.Position.Y,pos.Position.Z)).magnitude > 100 then
                                local TweenService = game:GetService("TweenService")
                                local TweenInfoToUse = TweenInfo.new(0, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)
                                local TweenValue = Instance.new("CFrameValue")
                                TweenValue.Value = car.WorldPivot
                                TweenValue.Changed:Connect(function()
                                    car:PivotTo(TweenValue.Value)
                                end)
                                getfenv().tween = TweenService:Create(TweenValue, TweenInfoToUse, {Value=car.WorldPivot+Vector3.new(0,1000,0)})
                                getfenv().tween:Play()
                                repeat task.wait()
                                until getfenv().tween.PlaybackState == Enum.PlaybackState.Cancelled or getfenv().tween.PlaybackState == Enum.PlaybackState.Completed or getfenv().tween.PlaybackState == Enum.PlaybackState.Paused
                            end

                            local plr = LocalPlayer
                            local pos = destination() or partfind()
                            local car = workspace.Vehicles[plr.Name]
                            if (car.WorldPivot.Position-Vector3.new(pos.Position.X,car.PrimaryPart.Position.Y,pos.Position.Z)).magnitude < 100 then
                                car:PivotTo(pos.CFrame)
                                workspace.Gravity = 196
                                for i,v in pairs(workspace.BusStops:GetDescendants()) do
                                    if v.Name == "SelectionBox" and v.Visible == true then
                                        car:PivotTo(v.Parent.CFrame+Vector3.new(0,5,0))
                                    end
                                end
                                local time = tick()
                                repeat task.wait()
                                until partfind() == nil or LocalPlayer:DistanceFromCharacter(partfind().Position) > 70 or tick() - time >= 5
                            end
                        end
                    end)
                end
            end)
        end
    end,
})

AutoWorkGroup:AddToggle("TruckDriver", {
    Text = "自动卡车司机",
    Default = false,
    Callback = function(Value)
        getfenv().trucker = Value
        if Value then
            spawn(function()
                while getfenv().trucker do
                    task.wait()
                    pcall(function()
                        if workspace.Vehicles:FindFirstChild(LocalPlayer.Name) and workspace.Vehicles[LocalPlayer.Name].Body:FindFirstChild("Trailer") and LocalPlayer.Character.Humanoid.SeatPart == nil then
                            local plr = LocalPlayer
                            local car = workspace.Vehicles[plr.Name]
                            if getfenv().tween ~= nil then
                                getfenv().tween:Cancel()
                                print("Tween Cancelled")
                            end
                            car.DriveSeat:Sit(LocalPlayer.Character.Humanoid)
                        end
                    end)
                end
            end)

            spawn(function()
                while getfenv().trucker do
                    task.wait()
                    pcall(function()
                        if LocalPlayer.Character.Humanoid.Health < 60 and LocalPlayer.Character.Humanoid.SeatPart == nil then
                            LocalPlayer.Character:BreakJoints()
                            warn("角色血量过低，已重置")
                        end
                    end)
                end
            end)

            spawn(function()
                while getfenv().trucker do
                    task.wait()
                    pcall(function()
                        for i,v in pairs(workspace.Vehicles:FindFirstChild(LocalPlayer.Name):GetDescendants()) do
                            pcall(function()
                                v.Velocity = Vector3.new(0,0,0)
                            end)
                        end
                    end)
                end
            end)

            task.spawn(function()
                while getfenv().trucker do
                    wait()
                    pcall(function()
                        workspace.Gravity = 196
                        if workspace.Vehicles:FindFirstChild(LocalPlayer.Name) and not workspace.Vehicles[LocalPlayer.Name].Body:FindFirstChild("Trailer") then
                            repeat wait()
                                workspace.Vehicles:FindFirstChild(LocalPlayer.Name).DriveSeat:Sit(LocalPlayer.Character.Humanoid)
                            until LocalPlayer.Character.Humanoid.SeatPart ~= nil
                            wait()
                            workspace.Vehicles:FindFirstChild(LocalPlayer.Name):PivotTo(CFrame.new(717.53125, 15.626567840576172, 1462.559814453125))
                            wait(1)
                            LocalPlayer.Character.Humanoid.Sit = false
                            wait(2)

                            if LocalPlayer:DistanceFromCharacter(Vector3.new(717.53125, 15.626567840576172, 1462.559814453125)) < 50 then
                                LocalPlayer.Character.Humanoid:MoveTo(Vector3.new(712.7074584960938, 5.587162017822266, 1437.5025634765625))
                                LocalPlayer.Character.Humanoid.MoveToFinished:wait()
                                LocalPlayer.Character.Humanoid:MoveTo(Vector3.new(707.704345703125, 5.657994270324707, 1426.1021728515625))
                                LocalPlayer.Character.Humanoid.MoveToFinished:wait()

                                repeat wait()
                                    game:GetService("VirtualInputManager"):SendKeyEvent(true,"E",false,game)
                                    game:GetService("VirtualInputManager"):SendKeyEvent(false,"E",false,game)
                                until shiftfind() ~= nil

                                wait(3)
                                local timestried = 0
                                repeat wait()
                                    if LocalPlayer.Team ~= game:GetService("Teams").TruckCompany then
                                        repeat wait()
                                            game:GetService("VirtualInputManager"):SendKeyEvent(true,"E",false,game)
                                            game:GetService("VirtualInputManager"):SendKeyEvent(false,"E",false,game)
                                        until shiftfind() ~= nil
                                        task.wait(1)
                                        if LocalPlayer.Team ~= game:GetService("Teams").TruckCompany and timestried > 10 then
                                            for i,v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                                                if v.ClassName == "TextLabel" and v.Text == "Start Shift" then
                                                    firesignal(v.Parent.MouseButton1Click)
                                                end
                                            end
                                            timestried = 0
                                        end
                                        for i,v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                                            if v.ClassName == "ImageButton" and v.ImageColor3 == Color3.fromRGB(39, 174, 96) then
                                                if v.Parent ~= nil then
                                                    pcall(function()
                                                        firesignal(v.MouseButton1Down)
                                                    end)
                                                end
                                            end
                                        end
                                        timestried=timestried+1
                                        task.wait(1)
                                    end
                                until findxpui() ~= nil

                                repeat wait()
                                until findxpui() ~= nil and findxpui().Enabled == true
                                _G.rat = nil
                                local num = 0
                                for i,v in pairs(findxpui():GetDescendants()) do
                                    if v.ClassName == "TextLabel" and string.find(v.Text,"XP") then
                                        local Val = tonumber(v.Text:split(" ")[1])
                                        if Val > num then
                                            num = Val
                                            print(Val)
                                            _G.rat = v.Parent
                                        end
                                    end
                                end
                                if _G.rat ~= nil then
                                    firesignal(_G.rat.MouseButton1Click)
                                end

                                LocalPlayer.Character.Humanoid:MoveTo(Vector3.new(699.1327514648438, 5.645294189453125, 1407.9368896484375))
                                LocalPlayer.Character.Humanoid.MoveToFinished:wait()
                                LocalPlayer.Character.Humanoid:MoveTo(Vector3.new(700.1976318359375, 5.645294189453125, 1408.7381591796875))
                                LocalPlayer.Character.Humanoid.MoveToFinished:wait()

                                repeat wait()
                                    game:GetService("VirtualInputManager"):SendKeyEvent(true,"E",false,game)
                                    game:GetService("VirtualInputManager"):SendKeyEvent(false,"E",false,game)
                                until dealership()~= nil and dealership().Enabled == true

                                for i,v in pairs(dealership():GetDescendants()) do
                                    if v.ClassName == "TextLabel" and v.Text == "Stuttgart Lastkraft" then
                                        repeat wait()
                                            if v.Parent ~= nil then
                                                firesignal(v.Parent.MouseButton1Click)
                                                wait(1)
                                                for a,b in pairs(dealership():GetDescendants()) do
                                                    if b.ClassName == "TextLabel" and b.Text == "Spawn Vehicle" or b.ClassName == "TextLabel" and b.Text == "Unlock Vehicle" then
                                                        firesignal(b.Parent.MouseButton1Click)
                                                    end
                                                end
                                            end
                                        until workspace.Vehicles:FindFirstChild(LocalPlayer.Name) and workspace.Vehicles[LocalPlayer.Name].Body:FindFirstChild("Trailer")
                                    end
                                end
                            end
                        elseif workspace.Vehicles:FindFirstChild(LocalPlayer.Name) and workspace.Vehicles[LocalPlayer.Name].Body:FindFirstChild("Trailer") and LocalPlayer.Character.Humanoid.SeatPart ~= nil then
                            workspace.Gravity = 0
                            local plr = LocalPlayer
                            local chr = plr.Character
                            local car = workspace.Vehicles[plr.Name]
                            local pos = destination() or partfind()
                            car.PrimaryPart = car.Body.Mass

                            if (car.WorldPivot.Position-Vector3.new(pos.Position.X,car.PrimaryPart.Position.Y,pos.Position.Z)).magnitude > 100 then
                                car:PivotTo(car.WorldPivot+Vector3.new(0,500,0))
                            end

                            local plr = LocalPlayer
                            local pos = destination() or partfind()
                            local car = workspace.Vehicles[plr.Name]
                            if (car.WorldPivot.Position-Vector3.new(pos.Position.X,car.PrimaryPart.Position.Y,pos.Position.Z)).magnitude > 100 then
                                local TweenService = game:GetService("TweenService")
                                local TweenInfoToUse = TweenInfo.new(dist/80, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)
                                local TweenValue = Instance.new("CFrameValue")
                                TweenValue.Value = car.WorldPivot
                                TweenValue.Changed:Connect(function()
                                    car:PivotTo(TweenValue.Value)
                                end)
                                getfenv().tween = TweenService:Create(TweenValue, TweenInfoToUse, {Value=pos.CFrame+Vector3.new(0,500,0)})
                                getfenv().tween:Play()
                                repeat task.wait()
                                until getfenv().tween.PlaybackState == Enum.PlaybackState.Cancelled or getfenv().tween.PlaybackState == Enum.PlaybackState.Completed or getfenv().tween.PlaybackState == Enum.PlaybackState.Paused
                            end

                            local plr = LocalPlayer
                            local pos = destination() or partfind()
                            local car = workspace.Vehicles[plr.Name]
                            if (car.WorldPivot.Position-Vector3.new(pos.Position.X,car.PrimaryPart.Position.Y,pos.Position.Z)).magnitude < 100 then
                                car:PivotTo(pos.CFrame)
                                workspace.Gravity = 196
                                for i,v in pairs(workspace.DeliveryDestinations:GetDescendants()) do
                                    if v.Name == "SelectionBox" and v.Visible == true then
                                        car:PivotTo(v.Parent.CFrame+Vector3.new(0,5,0))
                                    end
                                end
                                local time = tick()
                                repeat task.wait()
                                until partfind() == nil or LocalPlayer:DistanceFromCharacter(partfind().Position) > 70 or tick() - time > 40
                            end
                        end
                    end)
                end
            end)
        end
    end,
})

local PlayerGroup = Tabs.Player:AddLeftGroupbox("玩家设置")

PlayerGroup:AddToggle("AntiFall", {
    Text = "防坠落伤害",
    Default = false,
    Callback = function(Value)
        getfenv().ANTIFALL = Value
        if getfenv().ANTIFALL then
            getfenv().nofall = game:GetService("RunService").RenderStepped:Connect(function()
                if workspace:Raycast(LocalPlayer.Character.HumanoidRootPart.Position, Vector3.new(0, -20, 0)).Instance ~= nil and
                   LocalPlayer.Character.HumanoidRootPart.Velocity.Y < -30 then
                    LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
                end
            end)
        else
            getfenv().nofall:Disconnect()
        end
    end,
})

PlayerGroup:AddToggle("AntiDown", {
    Text = "防倒地",
    Default = false,
    Callback = function(Value)
        getfenv().downed = Value
        if getfenv().downed == true then
            getfenv().antichanged1 = LocalPlayer.Character.Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                LocalPlayer.Character.Humanoid.Health = 100
            end)
        else
            getfenv().antichanged1:Disconnect()
        end
    end,
})

PlayerGroup:AddButton("重置角色", function()
    LocalPlayer.Character:BreakJoints()
end)

PlayerGroup:AddButton("无限耐力", function()
    if getfenv().firsttime == nil then
        getfenv().firsttime = true
        local func
        for i,v in pairs(getgc(true)) do
            if type(v) == "function" and getinfo(v).name == "setStamina" then
                warn(getinfo(v).name)
                func = v
            end
        end
        hookfunction(func,function(...)
            local args = {...}
            return args[1],math.huge
        end)
    end
end)

local AimbotGroup = Tabs.Aimbot:AddLeftGroupbox("自动瞄准")

local function teams()
    local teams = {"选择敌方队伍"}
    for i,v in pairs(game:GetService("Teams"):GetChildren()) do
        table.insert(teams,v.Name)
    end
    return teams
end

AimbotGroup:AddDropdown("EnemyTeam", {
    Values = teams(),
    Default = 1,
    Multi = false,
    Text = "选择敌方队伍",
    Callback = function(Value)
        if Value ~= "选择敌方队伍" then
            getfenv().enemy = Value
        end
    end,
})

AimbotGroup:AddToggle("Aimbot", {
    Text = "自动瞄准",
    Default = false,
    Callback = function(Value)
        getfenv().aimbot = Value
        task.spawn(function()
            local function canaim(ye)
                return LocalPlayer:DistanceFromCharacter(ye) < 3
            end

            while getfenv().aimbot do
                task.wait()
                if LocalPlayer.Character:FindFirstChildOfClass("Tool") and canaim(workspace.Camera.CFrame.Position) then
                    local plr = nil
                    local distance = math.huge
                    for a,b in pairs(Players:GetPlayers()) do
                        if b.Team.Name == getfenv().enemy then
                            pcall(function()
                                local Dist = (LocalPlayer.Character.HumanoidRootPart.Position - b.Character.Head.Position).magnitude
                                if Dist < distance then
                                    distance = Dist
                                    plr = b
                                end
                            end)
                        end
                    end
                    if plr ~= nil then
                        workspace.Camera.CameraType = "Follow"
                        workspace.Camera.CFrame = CFrame.new(workspace.Camera.CFrame.Position,plr.Character.Head.Position)
                    end
                end
            end
        end)
    end,
})

AimbotGroup:AddToggle("HighlightEnemy", {
    Text = "高亮敌人",
    Default = false,
    Callback = function(Value)
        getfenv().highlight = Value
        task.spawn(function()
            if getfenv().highlight == false then
                for i,v in pairs(Players:GetChildren()) do
                    if v.ClassName == "Player" and v.Team.Name == getfenv().enemy and v.Character ~= nil and v.Character:FindFirstChild("Highlight") then
                        v.Character:FindFirstChild("Highlight"):Destroy()
                        task.wait()
                    end
                end
            end
            while getfenv().highlight do
                task.wait()
                for i,v in pairs(Players:GetChildren()) do
                    if v.ClassName == "Player" and v.Team.Name == getfenv().enemy and v.Character ~= nil and not v.Character:FindFirstChild("Highlight") then
                        Instance.new("Highlight",v.Character)
                        task.wait()
                    end
                end
            end
        end)
    end,
})

local TeleportGroup = Tabs.Teleport:AddLeftGroupbox("传送点1")

TeleportGroup:AddDropdown("Teleport1", {
    Values = {"传送点","警察局","银行","停车场","珠宝店","监狱","公交公司","卡车公司","医院"},
    Default = 1,
    Multi = false,
    Text = "选择传送点",
    Callback = function(Value)
        print(Value)
        if Value == "警察局" then
            task.spawn(vehicleTeleport, CFrame.new(-1549.2081298828125, 5.615050315856934, 2935.314697265625))
        elseif Value == "银行" then
            task.spawn(vehicleTeleport, CFrame.new(-1174.68115234375, 5.874685287475586, 3209.03271484375))
        elseif Value == "停车场" then
            task.spawn(vehicleTeleport, CFrame.new(-993.5323486328125, -11.622750282287598, 3705.0126953125))
        elseif Value == "珠宝店" then
            task.spawn(vehicleTeleport, CFrame.new(-396.0776062011719, 5.6145405769348145, 3508.26318359375))
        elseif Value == "监狱" then
            task.spawn(vehicleTeleport, CFrame.new(-548.9014282226562, 5.6149725914001465, 2832.7587890625))
        elseif Value == "卡车公司" then
            task.spawn(vehicleTeleport, CFrame.new(717.53125, 15.626567840576172, 1462.559814453125))
        elseif Value == "公交公司" then
            task.spawn(vehicleTeleport, CFrame.new(-1683.09375, 15.630923271179199, -1286.167236328125))
        elseif Value == "医院" then
            task.spawn(vehicleTeleport, CFrame.new(-304.7102966308594, 5.623022079467773, 1018.22119140625))
        end
    end,
})

local TeleportGroup2 = Tabs.Teleport:AddRightGroupbox("传送点2")

TeleportGroup2:AddDropdown("Teleport2", {
    Values = {"传送点","工具店","汽车经销商","农场商店","Ares加油站","Osso加油站","Gas-N-Go加油站"},
    Default = 1,
    Multi = false,
    Text = "选择传送点",
    Callback = function(Value)
        print(Value)
        if Value == "工具店" then
            task.spawn(vehicleTeleport, CFrame.new(-733.7286376953125, 5.614245414733887, 677.4180908203125))
        elseif Value == "汽车经销商" then
            task.spawn(vehicleTeleport, CFrame.new(-1422.2327880859375, 5.624246120452881, 939.8997802734375))
        elseif Value == "农场商店" then
            task.spawn(vehicleTeleport, CFrame.new(-840.9263305664062, 5.378037929534912, -1179.6783447265625))
        elseif Value == "Ares加油站" then
            task.spawn(vehicleTeleport, CFrame.new(-873.4227294921875, 5.614551067352295, 1500.887451171875))
        elseif Value == "Osso加油站" then
            task.spawn(vehicleTeleport, CFrame.new(-26.49447250366211, 5.615009307861328, -766.71630859375))
        elseif Value == "Gas-N-Go加油站" then
            task.spawn(vehicleTeleport, CFrame.new(-1544.445556640625, 5.628605842590332, 3811.127685546875))
        end
    end,
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

getfenv().jump = LocalPlayer.Character.Humanoid.JumpHeight
