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

local Window = Library:CreateWindow({
    Title = "变身躲猫猫",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify("变身躲猫猫脚本 - 创作者：Aiove", 5)

local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    General = Window:AddTab("通用", "settings"),
    Hider = Window:AddTab("躲藏者", "eye"),
    Hunter = Window:AddTab("追捕者", "sword"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel('Aiove将持续更新此脚本')
NoticeGroup:AddLabel('创作者：Aiove')

local GeneralGroup = Tabs.General:AddLeftGroupbox("核心")
GeneralGroup:AddToggle('NoGameToggle', {
    Text = '不会参加游戏',
    Default = false,
    Callback = function(Value)
        game:GetService("ReplicatedStorage").Interaction.Settings.ToggleAFK:InvokeServer()
    end
})

GeneralGroup:AddButton({ Text = '召唤飞行脚本', Func = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/kongbaNB/9178/refs/heads/main/fly.lua"))()
end })

GeneralGroup:AddButton({ Text = '传送到跑酷终点1', Func = function()
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-131.6, 106.2, -24.2)
    end
end })

GeneralGroup:AddButton({ Text = '传送到跑酷终点2', Func = function()
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(44.2, 66.8, -399.9)
    end
end })

local MainGroup = Tabs.General:AddRightGroupbox("主要")

local InfiniteJumpEnabled = false
MainGroup:AddToggle('InfiniteJumpToggle', {
    Text = '无限跳',
    Default = false,
    Callback = function(Value)
        InfiniteJumpEnabled = Value
    end
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        local char = game:GetService("Players").LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

local espEnabled = false
local espBillboards = {}

local function createESP(player)
    if player == game:GetService("Players").LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if not char:FindFirstChild("EspHighlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "EspHighlight"
        highlight.Parent = char
        highlight.FillTransparency = 0.5
        highlight.FillColor = Color3.fromRGB(255, 255, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end

    if not hrp:FindFirstChild("EspBillboard") then
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
end

local function removeESP(player)
    local char = player.Character
    if char then
        if char:FindFirstChild("EspHighlight") then
            char.EspHighlight:Destroy()
        end
        if char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart:FindFirstChild("EspBillboard") then
            char.HumanoidRootPart.EspBillboard:Destroy()
        end
    end
    espBillboards[player] = nil
end

game:GetService("RunService").RenderStepped:Connect(function()
    if not espEnabled then return end
    local localPlayer = game:GetService("Players").LocalPlayer
    local myChar = localPlayer.Character
    local myPos = myChar and myChar:FindFirstChild("HumanoidRootPart") and myChar.HumanoidRootPart.Position

    for player, billboard in pairs(espBillboards) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and billboard and billboard.Parent then
            local distLabel = billboard:FindFirstChild("DistLabel")
            if distLabel and myPos then
                local dist = (player.Character.HumanoidRootPart.Position - myPos).Magnitude
                distLabel.Text = string.format("%.0fm", dist)
            end
        end
    end
end)

MainGroup:AddToggle('ESPToggle', {
    Text = '透视',
    Default = false,
    Callback = function(Value)
        espEnabled = Value
        if Value then
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                createESP(p)
            end
        else
            for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
                removeESP(p)
            end
        end
    end
})

game:GetService("Players").PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        char:WaitForChild("HumanoidRootPart")
        if espEnabled then
            createESP(player)
        end
    end)
end)

game:GetService("Players").PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

MainGroup:AddButton({ Text = '甩飞全部玩家', Func = function()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Workspace = game:GetService("Workspace")
    local RunService = game:GetService("RunService")
    local count = 0
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= LocalPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = hum and hum.RootPart
            local tChar = targetPlayer.Character
            local tHum = tChar:FindFirstChildOfClass("Humanoid")
            local tRoot = tHum and tHum.RootPart
            local tHead = tChar:FindFirstChild("Head")
            local acc = tChar:FindFirstChildOfClass("Accessory")
            local handle = acc and acc:FindFirstChild("Handle")
            if char and hum and root then
                if root.Velocity.Magnitude < 50 then
                    getgenv().OldPos = root.CFrame
                end
                if not getgenv().FPDH then
                    getgenv().FPDH = Workspace.FallenPartsDestroyHeight
                end

                -- 关闭自己和目标的碰撞箱
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
                for _, part in ipairs(tChar:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end

                if tHead then
                    Workspace.CurrentCamera.CameraSubject = tHead
                elseif not tHead and handle then
                    Workspace.CurrentCamera.CameraSubject = handle
                elseif tHum and tRoot then
                    Workspace.CurrentCamera.CameraSubject = tHum
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
                            -- 持续关闭碰撞
                            for _, part in ipairs(char:GetDescendants()) do
                                if part:IsA("BasePart") then part.CanCollide = false end
                            end
                            for _, part in ipairs(tChar:GetDescendants()) do
                                if part:IsA("BasePart") then part.CanCollide = false end
                            end

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
                        else
                            break
                        end
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
                    if (tRoot.CFrame.p - tHead.CFrame.p).Magnitude > 5 then
                        SFBasePart(tHead)
                    else
                        SFBasePart(tRoot)
                    end
                elseif tRoot and not tHead then
                    SFBasePart(tRoot)
                elseif not tRoot and tHead then
                    SFBasePart(tHead)
                elseif not tRoot and not tHead and acc and handle then
                    SFBasePart(handle)
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
                count = count + 1
                task.wait(0.5)
            end
        end
    end
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "甩飞完成", Text = "共甩飞 " .. tostring(count) .. " 个玩家", Duration = 3})
end })

local HiderGroup = Tabs.Hider:AddLeftGroupbox("躲藏功能")
HiderGroup:AddButton({ Text = '传送到出生点（安全点）', Func = function()
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-10.8, 79.3, 34.1)
    end
end })

local AutoTransformLoop = nil
HiderGroup:AddToggle('AutoTransformToggle', {
    Text = '自动变身',
    Default = false,
    Callback = function(Value)
        if Value then
            AutoTransformLoop = game:GetService("RunService").Heartbeat:Connect(function()
                pcall(function()
                    local interaction = game:GetService("ReplicatedStorage").Modules.Interaction
                    if interaction:IsA("RemoteEvent") then
                        interaction:FireServer()
                    elseif interaction:IsA("RemoteFunction") then
                        interaction:InvokeServer()
                    elseif interaction:IsA("BindableEvent") then
                        interaction:Fire()
                    elseif interaction:IsA("BindableFunction") then
                        interaction:Invoke()
                    end
                    for _, child in ipairs(interaction:GetChildren()) do
                        if child:IsA("RemoteEvent") then
                            child:FireServer()
                        elseif child:IsA("RemoteFunction") then
                            child:InvokeServer()
                        elseif child:IsA("BindableEvent") then
                            child:Fire()
                        elseif child:IsA("BindableFunction") then
                            child:Invoke()
                        end
                    end
                end)
            end)
        else
            if AutoTransformLoop then
                AutoTransformLoop:Disconnect()
                AutoTransformLoop = nil
            end
        end
    end
})

local HunterGroup = Tabs.Hunter:AddLeftGroupbox("追捕功能")

local CrazyAttackLoop = nil
HunterGroup:AddToggle('CrazyAttackToggle', {
    Text = '疯狂向前攻击',
    Default = false,
    Callback = function(Value)
        if Value then
            CrazyAttackLoop = game:GetService("RunService").Heartbeat:Connect(function()
                pcall(function()
                    local player = game:GetService("Players").LocalPlayer
                    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local args = {
                            [1] = player.Character.HumanoidRootPart,
                            [2] = Vector3.new(1965.6953125, -10.738676071166992, 1834.8052978515625)
                        }
                        game:GetService("ReplicatedStorage").Interaction.Gameplay.Zap:FireServer(unpack(args))
                    end
                end)
            end)
        else
            if CrazyAttackLoop then
                CrazyAttackLoop:Disconnect()
                CrazyAttackLoop = nil
            end
        end
    end
})
local HunterGroup = Tabs.Hunter:AddLeftGroupbox("追捕功能")

local CrazyAttackLoop = nil
HunterGroup:AddToggle('CrazyAttackToggle', {
    Text = '疯狂向前攻击',
    Default = false,
    Callback = function(Value)
        if Value then
            CrazyAttackLoop = game:GetService("RunService").Heartbeat:Connect(function()
                local player = game:GetService("Players").LocalPlayer
                if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local args = {
                        [1] = player.Character.HumanoidRootPart,
                        [2] = Vector3.new(1965.6953125, -10.738676071166992, 1834.8052978515625)
                    }
                    game:GetService("ReplicatedStorage").Interaction.Gameplay.Zap:FireServer(unpack(args))
                end
            end)
        else
            if CrazyAttackLoop then
                CrazyAttackLoop:Disconnect()
                CrazyAttackLoop = nil
            end
        end
    end
})

local SettingsGroup = Tabs.Settings:AddLeftGroupbox("菜单")
SettingsGroup:AddButton({ Text = '卸载脚本', Func = function()
    if CrazyAttackLoop then
        CrazyAttackLoop:Disconnect()
    end
    if AutoTransformLoop then
        AutoTransformLoop:Disconnect()
    end
    Library:Unload()
end })

SettingsGroup:AddButton({ Text = '重载界面', Func = function()
    if CrazyAttackLoop then
        CrazyAttackLoop:Disconnect()
    end
    if AutoTransformLoop then
        AutoTransformLoop:Disconnect()
    end
    Library:Unload()
    loadstring(game:HttpGet(game:GetService("HttpService"):UrlEncode("https://pastebin.com/raw/你的脚本地址")))()
end })

SettingsGroup:AddLabel('菜单快捷键'):AddKeyPicker('MenuKeybind', {
    Default = 'RightShift',
    NoUI = true,
    Text = 'Menu keybind'
})
Library.ToggleKeybind = Library.Options.MenuKeybind

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
