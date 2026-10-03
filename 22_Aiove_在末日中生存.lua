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
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local Window = Library:CreateWindow({
    Title = "在末日中生存",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify({
    Title = "在末日中生存",
    Description = "创作者：Aiove\nQQ：3999698324\n脚本已加载成功",
    Time = 5,
})

local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Main = Window:AddTab("主要", "info"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel('Aiove将持续更新此脚本')
NoticeGroup:AddLabel('创作者：Aiove')

local function createTranslator()
    local cache = {}
    local function isEnglish(text)
        if not text or text == "" then return false end
        local ec, tc = 0, 0
        for char in text:gmatch(".") do
            local b = string.byte(char)
            if b then
                tc = tc + 1
                if (b >= 65 and b <= 90) or (b >= 97 and b <= 122) then
                    ec = ec + 1
                end
            end
        end
        if tc == 0 then return false end
        return (ec / tc) > 0.5
    end
    local function translate(text)
        if not text or text == "" or #text < 2 then return nil end
        if cache[text] then return cache[text] end
        local ok, res = pcall(function()
            local url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=zh-CN&dt=t&q=" .. HttpService:UrlEncode(text)
            local resp = game:HttpGet(url)
            local dec = HttpService:JSONDecode(resp)
            if dec and dec[1] and dec[1][1] and dec[1][1][1] then
                return dec[1][1][1]
            end
            return nil
        end)
        if ok and res then
            cache[text] = res
            return res
        end
        return nil
    end
    return {
        translate = function(text, cb)
            if not text or text == "" then
                if cb then cb(text) end
                return text
            end
            if cache[text] then
                if cb then cb(cache[text]) end
                return cache[text]
            end
            if not isEnglish(text) then
                if cb then cb(text) end
                return text
            end
            task.spawn(function()
                local r = translate(text)
                if r and cb then cb(r) end
            end)
            if cb then cb(text) end
            return text
        end,
        getCache = function() return cache end
    }
end

local translator = createTranslator()

local function initESP()
    local st = {enemyOn = false, itemOn = false, hb = nil}
    local function getHRP()
        local c = player.Character
        if not c then return nil end
        return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Head")
    end
    local function addESP(model, name, isEnemy)
        if model:FindFirstChild("ESPHighlight") then return end
        local hl = Instance.new("Highlight")
        hl.Name = "ESPHighlight"
        if isEnemy then
            hl.FillColor = Color3.fromRGB(255, 0, 0)
            hl.OutlineColor = Color3.fromRGB(255, 0, 0)
        else
            hl.FillColor = Color3.fromRGB(0, 255, 0)
            hl.OutlineColor = Color3.fromRGB(0, 255, 0)
        end
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee = model
        hl.Parent = model
        local ad = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
        local bg = Instance.new("BillboardGui")
        bg.Name = "ESPBillboard"
        bg.Size = UDim2.new(0, 200, 0, 50)
        bg.StudsOffset = Vector3.new(0, 3, 0)
        bg.AlwaysOnTop = true
        bg.MaxDistance = 1000
        bg.Adornee = ad or model
        bg.Parent = model
        local nl = Instance.new("TextLabel")
        nl.Name = "ESPName"
        nl.Size = UDim2.new(1, 0, 0.5, 0)
        nl.BackgroundTransparency = 1
        if isEnemy then
            nl.TextColor3 = Color3.fromRGB(255, 0, 0)
        else
            nl.TextColor3 = Color3.fromRGB(0, 255, 0)
        end
        nl.TextStrokeTransparency = 0.5
        nl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nl.Font = Enum.Font.GothamBold
        nl.TextSize = 14
        nl.Text = name
        nl.Parent = bg
        local dl = Instance.new("TextLabel")
        dl.Name = "ESPDistance"
        dl.Size = UDim2.new(1, 0, 0.5, 0)
        dl.Position = UDim2.new(0, 0, 0.5, 0)
        dl.BackgroundTransparency = 1
        if isEnemy then
            dl.TextColor3 = Color3.fromRGB(255, 0, 0)
        else
            dl.TextColor3 = Color3.fromRGB(0, 255, 0)
        end
        dl.TextStrokeTransparency = 0.5
        dl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        dl.Font = Enum.Font.GothamBold
        dl.TextSize = 12
        dl.Text = "[0m]"
        dl.Parent = bg
        translator.translate(name, function(res)
            if nl and nl.Parent then
                nl.Text = res
            end
        end)
    end
    local function removeESP(model)
        local h = model:FindFirstChild("ESPHighlight")
        if h then h:Destroy() end
        local b = model:FindFirstChild("ESPBillboard")
        if b then b:Destroy() end
    end
    local function isEnemy(model)
        if model == player.Character then return false end
        if model.Name == "Zombie" or model.Name == "Crawler" then return true end
        if model:FindFirstChild("MobAI") then return true end
        return false
    end
    local function update()
        local hrp = getHRP()
        if not hrp then return end
        local pos = hrp.Position
        if st.enemyOn then
            local chars = Workspace:FindFirstChild("Characters")
            if chars then
                for _, m in pairs(chars:GetChildren()) do
                    if m:IsA("Model") and isEnemy(m) then
                        if not m:FindFirstChild("ESPHighlight") then
                            addESP(m, m.Name, true)
                        end
                        local bg = m:FindFirstChild("ESPBillboard")
                        if bg then
                            local part = m:FindFirstChild("Head") or m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart")
                            if part then
                                local d = (pos - part.Position).Magnitude
                                local dl = bg:FindFirstChild("ESPDistance")
                                if dl then dl.Text = "[" .. tostring(math.floor(d)) .. "m]" end
                            end
                        end
                    end
                end
            end
        end
        if st.itemOn then
            local items = Workspace:FindFirstChild("DroppedItems")
            if items then
                for _, m in pairs(items:GetChildren()) do
                    if m:IsA("Model") then
                        if not m:FindFirstChild("ESPHighlight") then
                            addESP(m, m.Name, false)
                        end
                        local bg = m:FindFirstChild("ESPBillboard")
                        if bg then
                            local part = m:FindFirstChildWhichIsA("BasePart")
                            if part then
                                local d = (pos - part.Position).Magnitude
                                local dl = bg:FindFirstChild("ESPDistance")
                                if dl then dl.Text = "[" .. tostring(math.floor(d)) .. "m]" end
                            end
                        end
                    end
                end
            end
        end
    end
    local function cleanEnemy()
        local chars = Workspace:FindFirstChild("Characters")
        if not chars then return end
        for _, m in pairs(chars:GetChildren()) do
            if m:IsA("Model") and m:FindFirstChild("ESPHighlight") then
                removeESP(m)
            end
        end
    end
    local function cleanItem()
        local items = Workspace:FindFirstChild("DroppedItems")
        if not items then return end
        for _, m in pairs(items:GetChildren()) do
            if m:IsA("Model") and m:FindFirstChild("ESPHighlight") then
                removeESP(m)
            end
        end
    end
    local function start()
        if st.hb then return end
        st.hb = RunService.Heartbeat:Connect(function()
            if not st.enemyOn and not st.itemOn then return end
            update()
        end)
    end
    local function stop()
        if st.hb then st.hb:Disconnect() st.hb = nil end
        cleanEnemy()
        cleanItem()
    end
    return {
        setEnemy = function(v)
            st.enemyOn = v
            if v then start() else cleanEnemy() end
            if not v and not st.itemOn then stop() end
        end,
        setItem = function(v)
            st.itemOn = v
            if v then start() else cleanItem() end
            if not v and not st.enemyOn then stop() end
        end,
        stop = stop
    }
end

local esp = initESP()

local function initKillAura()
    local st = {enabled = false, range = 50, interval = 0.01, conn = nil, last = 0}
    local function getRem()
        local ch = player.Character
        if not ch then return nil, nil, nil end
        local hit, swing, auto = nil, nil, nil
        for _, c in pairs(ch:GetChildren()) do
            if c:IsA("Tool") then
                if not hit then
                    local h = c:FindFirstChild("HitTargets")
                    if h and h:IsA("RemoteEvent") then hit = h end
                end
                if not swing then
                    local s = c:FindFirstChild("Swing")
                    if s and s:IsA("RemoteEvent") then swing = s end
                end
            end
        end
        local at = ch:FindFirstChild("AutoTargetClient")
        if at then auto = at:FindFirstChild("UpdateNearbyTargets") end
        return hit, swing, auto
    end
    local function upd()
        local ch = player.Character
        if not ch then return end
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local pos = hrp.Position
        local chars = Workspace:FindFirstChild("Characters")
        if not chars then return end
        local targets = {}
        for _, m in pairs(chars:GetChildren()) do
            if m:IsA("Model") and m ~= ch then
                local isE = (m.Name == "Zombie" or m.Name == "Crawler" or m:FindFirstChild("MobAI"))
                if isE then
                    local pt = m:FindFirstChild("Head") or m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart")
                    if pt and (pos - pt.Position).Magnitude <= st.range then
                        table.insert(targets, m)
                    end
                end
            end
        end
        if #targets == 0 then return end
        local hit, swing, auto = getRem()
        for _, e in ipairs(targets) do
            if hit then
                pcall(function() hit:FireServer(e) end)
                pcall(function() hit:FireServer({[1] = e}) end)
            end
        end
        if auto then
            pcall(function()
                local a = {[1] = {}}
                for i, t in ipairs(targets) do a[1][i] = t end
                auto:FireServer(a)
            end)
        end
        if swing then
            pcall(function() swing:FireServer() end)
        end
        local fog = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Misc") and ReplicatedStorage.Remotes.Misc:FindFirstChild("FogTouched")
        if fog then
            pcall(function() fog:FireServer(1, -2) end)
            pcall(function() fog:FireServer(1, -3) end)
        end
        for _, e in ipairs(targets) do
            local hum = e:FindFirstChildOfClass("Humanoid")
            if hum then
                pcall(function() hum:TakeDamage(999) end)
                pcall(function() hum.Health = 0 end)
            end
        end
    end
    local function start()
        if st.conn then return end
        st.last = 0
        st.conn = RunService.Heartbeat:Connect(function()
            if not st.enabled then return end
            local n = tick()
            if n - st.last >= st.interval then
                st.last = n
                upd()
            end
        end)
    end
    local function stop()
        if st.conn then st.conn:Disconnect() st.conn = nil end
    end
    return {
        setEnabled = function(v) st.enabled = v if v then start() else stop() end end,
        setRange = function(v) st.range = v end,
        setInterval = function(v) st.interval = v end,
    }
end
local function initGodMode()
    local st = {enabled = false, conns = {}, oldTakeDamage = nil}
    local function blockRemote()
        local rs = ReplicatedStorage
        local net = rs:FindFirstChild("Util") and rs.Util:FindFirstChild("Net")
        if not net then return end
        local ev = net:FindFirstChild("RE/PlayerDamaged") or net:FindFirstChild("RE/TakeDamage") or net:FindFirstChild("RE/Damage")
        if ev and ev:IsA("RemoteEvent") then
            local old = ev.FireServer
            ev.FireServer = function(self, ...)
                if st.enabled then return end
                return old(self, ...)
            end
        end
    end
    local function protect()
        local ch = player.Character
        if not ch then return end
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if not st.oldTakeDamage then
            st.oldTakeDamage = hum.TakeDamage
        end
        hum.TakeDamage = function(self, amount)
            if st.enabled then return end
            return st.oldTakeDamage(self, amount)
        end
        local last = hum.Health
        local c1 = hum:GetPropertyChangedSignal("Health"):Connect(function()
            if not st.enabled then return end
            if hum.Health < last then
                hum.Health = last
            else
                last = hum.Health
            end
        end)
        table.insert(st.conns, c1)
        local c2 = hum.Died:Connect(function()
            if not st.enabled then return end
            task.wait(0.05)
            pcall(function() hum.Health = hum.MaxHealth end)
        end)
        table.insert(st.conns, c2)
    end
    local function start()
        blockRemote()
        protect()
        local c = player.CharacterAdded:Connect(function(ch)
            if not st.enabled then return end
            task.wait(0.3)
            protect()
        end)
        table.insert(st.conns, c)
    end
    local function stop()
        for _, c in ipairs(st.conns) do
            pcall(function() c:Disconnect() end)
        end
        st.conns = {}
    end
    return {
        setE = function(v) st.enabled = v if v then start() else stop() end end,
    }
end

local godMode = initGodMode()

local function initSpeed()
    local st = {enabled = false, value = 20, conn = nil, lastPos = nil, lastTime = nil, expectedPos = nil}
    local function start()
        if st.conn then return end
        st.conn = RunService.Heartbeat:Connect(function(dt)
            if not st.enabled then return end
            local ch = player.Character
            local hum = ch and ch:FindFirstChildOfClass("Humanoid")
            local root = ch and ch:FindFirstChild("HumanoidRootPart")
            if hum and root then
                pcall(function() hum.WalkSpeed = 16 end)
                if hum.MoveDirection.Magnitude > 0 then
                    root.CFrame = root.CFrame + hum.MoveDirection * st.value * dt
                    root.Velocity = Vector3.zero
                end
                if st.lastPos and st.lastTime and dt > 0 then
                    local moved = (root.Position - st.lastPos).Magnitude
                    local maxNormal = st.value * dt * 1.5
                    if moved > maxNormal then
                        root.CFrame = CFrame.new(st.expectedPos or st.lastPos) * root.CFrame.Rotation
                        root.Velocity = Vector3.zero
                        root.AssemblyLinearVelocity = Vector3.zero
                    end
                    if st.expectedPos and (root.Position - st.expectedPos).Magnitude > 5 then
                        root.CFrame = CFrame.new(st.expectedPos) * root.CFrame.Rotation
                        root.Velocity = Vector3.zero
                        root.AssemblyLinearVelocity = Vector3.zero
                    end
                end
                st.lastPos = root.Position
                st.lastTime = tick()
                st.expectedPos = root.Position + hum.MoveDirection * st.value * dt
            end
        end)
    end
    local function stop()
        if st.conn then st.conn:Disconnect() st.conn = nil end
    end
    return {
        setE = function(v) st.enabled = v if v then start() else stop() end end,
        setV = function(v) st.value = v end,
    }
end

local speedMod = initSpeed()

local function initFly()
    local st = {on = false, spd = 100, hrp = nil, hum = nil, mt = nil, ht = nil, dc = nil, tp = nil, lt = 0, an = false, hd = nil, rl = 3.5, rc = 12, vl = 3, lastPos = nil, lastTime = nil, expectedPos = nil}
    local ctrl = nil
    task.spawn(function()
        pcall(function()
            local pm = player.PlayerScripts:FindFirstChild("PlayerModule")
            if pm then ctrl = require(pm):GetControls() end
        end)
    end)
    local function refresh()
        local ch = player.Character
        if not ch then st.hrp = nil st.hum = nil st.hd = nil return end
        st.hrp = ch:FindFirstChild("HumanoidRootPart")
        st.hum = ch:FindFirstChildOfClass("Humanoid")
        st.hd = ch:FindFirstChild("Head")
    end
    local function wall()
        if not st.hrp then return false end
        local pos = st.hrp.Position
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Blacklist
        rp.FilterDescendantsInstances = { player.Character }
        for i = 1, st.rc do
            local a = (i / st.rc) * 2 * math.pi
            local dx = math.cos(a)
            local dz = math.sin(a)
            for j = -(st.vl - 1) // 2, (st.vl - 1) // 2 do
                local dir = Vector3.new(dx, j * 0.5, dz).Unit
                local r = workspace:Raycast(pos, dir * st.rl, rp)
                if r and r.Instance and r.Instance.CanCollide and r.Instance.Transparency < 0.9 then
                    return true
                end
            end
        end
        return false
    end
    local function enterA()
        if st.an then return end
        if not st.hd or not st.hrp or not st.hum then return end
        st.hd.Anchored = true
        st.hum.PlatformStand = true
        st.an = true
    end
    local function exitA()
        if not st.an then return end
        if st.hd and st.hum then
            st.hd.Anchored = false
            st.hum.PlatformStand = false
        end
        st.an = false
    end
    local function microLoop()
        st.tp = st.hrp.Position
        st.lt = tick()
        while st.on do
            local now = tick()
            local dt = now - st.lt
            st.lt = now
            if not st.hrp or not st.hrp.Parent then break end
            local inW = wall()
            if inW and not st.an then
                enterA()
            elseif not inW and st.an then
                exitA()
            end
            local mv
            if ctrl then
                local v = ctrl:GetMoveVector()
                local cf = workspace.CurrentCamera.CFrame
                mv = (cf.LookVector * -v.Z) + (cf.RightVector * v.X)
            else
                mv = (st.hum and st.hum.MoveDirection) or Vector3.zero
            end
            local vy = 0
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                vy = 1
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                vy = -1
            end
            local d = (mv + Vector3.new(0, vy, 0)) * st.spd * dt
            st.tp = st.tp + d
            local cp = st.hrp.Position
            local rem = st.tp - cp
            local dist = rem.Magnitude
            if dist > 0 then
                local steps = math.ceil(dist / 10)
                local sv = rem / steps
                for i = 1, steps do
                    if not st.on then break end
                    cp = cp + sv
                    st.hrp.CFrame = CFrame.new(cp) * st.hrp.CFrame.Rotation
                    st.hrp.Velocity = Vector3.zero
                end
            else
                st.hrp.CFrame = CFrame.new(st.tp) * st.hrp.CFrame.Rotation
                st.hrp.Velocity = Vector3.zero
            end
            if st.lastPos and st.lastTime and dt > 0 then
                local moved = (st.hrp.Position - st.lastPos).Magnitude
                local maxNormal = st.spd * dt * 1.5
                if moved > maxNormal then
                    st.hrp.CFrame = CFrame.new(st.expectedPos or st.lastPos) * st.hrp.CFrame.Rotation
                    st.hrp.Velocity = Vector3.zero
                    st.hrp.AssemblyLinearVelocity = Vector3.zero
                end
                if st.expectedPos and (st.hrp.Position - st.expectedPos).Magnitude > 5 then
                    st.hrp.CFrame = CFrame.new(st.expectedPos) * st.hrp.CFrame.Rotation
                    st.hrp.Velocity = Vector3.zero
                    st.hrp.AssemblyLinearVelocity = Vector3.zero
                end
            end
            st.lastPos = st.hrp.Position
            st.lastTime = tick()
            st.expectedPos = st.hrp.Position + (mv + Vector3.new(0, vy, 0)) * st.spd * dt
            if st.hum then
                st.hum:ChangeState(Enum.HumanoidStateType.Climbing)
            end
            task.wait(0.001)
        end
    end
    local function healthLoop()
        while st.on do
            if st.hum and st.hum.Health <= 0 then
                st.hum.Health = st.hum.MaxHealth
            end
            task.wait(0.1)
        end
    end
    local function start()
        if st.on then return end
        refresh()
        if not st.hrp or not st.hum then return end
        st.on = true
        st.hum:ChangeState(Enum.HumanoidStateType.Climbing)
        st.mt = task.spawn(microLoop)
        st.ht = task.spawn(healthLoop)
        st.dc = st.hum.Died:Connect(function()
            if st.hum and st.on then
                st.hum.Health = st.hum.MaxHealth
                st.hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end)
    end
    local function stop()
        if not st.on then return end
        st.on = false
        exitA()
        if st.mt then task.cancel(st.mt) st.mt = nil end
        if st.ht then task.cancel(st.ht) st.ht = nil end
        if st.dc then st.dc:Disconnect() st.dc = nil end
        if st.hum then st.hum:ChangeState(Enum.HumanoidStateType.Running) end
        refresh()
        if st.hrp then
            local land = st.hrp.Position
            for i = 1, 20 do
                if not st.hrp then break end
                st.hrp.CFrame = CFrame.new(land) * st.hrp.CFrame.Rotation
                st.hrp.Velocity = Vector3.zero
                st.hrp.AssemblyLinearVelocity = Vector3.zero
                task.wait(0.01)
            end
        end
    end
    player.CharacterAdded:Connect(function()
        if st.on then
            stop()
            task.wait(0.2)
            start()
        end
    end)
    return {
        setE = function(v)
            if v then start() else stop() end
        end,
        setS = function(v) st.spd = v end,
    }
end

local flyMod = initFly()

local function initNoclip()
    local st = {enabled = false, conn = nil, antiPull = nil, lastPos = nil, lastTime = nil, expectedPos = nil}
    local function setNoClip(ch, v)
        if not ch then return end
        for _, p in pairs(ch:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = not v
            end
        end
    end
    local function blockPullRemote()
        local rs = ReplicatedStorage
        local names = {"RE/PlayerPosition", "RE/Position", "RE/SetPosition", "RE/PullBack", "RE/AntiCheat", "RE/CheckPosition", "RE/SyncPosition"}
        for _, n in ipairs(names) do
            local ev = rs:FindFirstChild(n, true)
            if ev and ev:IsA("RemoteEvent") then
                local old = ev.FireServer
                ev.FireServer = function(self, ...)
                    if st.enabled then return end
                    return old(self, ...)
                end
            end
        end
    end
    local function start()
        if st.conn then return end
        blockPullRemote()
        local ch = player.Character
        if ch then setNoClip(ch, true) end
        st.lastPos = nil
        st.lastTime = nil
        st.expectedPos = nil
        st.conn = RunService.Heartbeat:Connect(function(dt)
            if not st.enabled then return end
            local ch = player.Character
            if not ch then return end
            setNoClip(ch, true)
            local hrp = ch:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local pos = hrp.Position
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if st.lastPos and st.lastTime and dt > 0 then
                local moved = (pos - st.lastPos).Magnitude
                local maxNormal = 30 * dt
                if moved > maxNormal then
                    hrp.CFrame = CFrame.new(st.expectedPos or st.lastPos) * hrp.CFrame.Rotation
                    hrp.Velocity = Vector3.zero
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    pos = hrp.Position
                end
                if st.expectedPos and (pos - st.expectedPos).Magnitude > 5 then
                    hrp.CFrame = CFrame.new(st.expectedPos) * hrp.CFrame.Rotation
                    hrp.Velocity = Vector3.zero
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    pos = hrp.Position
                end
            end
            st.lastPos = pos
            st.lastTime = tick()
            if hum then
                st.expectedPos = pos + hum.MoveDirection * 30 * dt
            else
                st.expectedPos = pos
            end
        end)
        st.antiPull = RunService.Stepped:Connect(function()
            if not st.enabled then return end
            local ch = player.Character
            if not ch then return end
            setNoClip(ch, true)
        end)
    end
    local function stop()
        if st.conn then st.conn:Disconnect() st.conn = nil end
        if st.antiPull then st.antiPull:Disconnect() st.antiPull = nil end
        local ch = player.Character
        if ch then setNoClip(ch, false) end
    end
    player.CharacterAdded:Connect(function(ch)
        if st.enabled then
            task.wait(0.2)
            setNoClip(ch, true)
        end
    end)
    return {
        setE = function(v) st.enabled = v if v then start() else stop() end end,
    }
end

local noclipMod = initNoclip()

local function initInfJump()
    local st = {enabled = false, conn = nil}
    local function start()
        if st.conn then return end
        st.conn = UserInputService.JumpRequest:Connect(function()
            if not st.enabled then return end
            local ch = player.Character
            local hum = ch and ch:FindFirstChildOfClass("Humanoid")
            if hum then
                pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
            end
        end)
    end
    local function stop()
        if st.conn then st.conn:Disconnect() st.conn = nil end
    end
    return {
        setE = function(v) st.enabled = v if v then start() else stop() end end,
    }
end

local infJump = initInfJump()

local ESPGroup = Tabs.Main:AddLeftGroupbox("透视功能")

ESPGroup:AddToggle("EnemyESP", {
    Text = "敌人透视",
    Default = false,
    Callback = function(value)
        esp.setEnemy(value)
    end
})

ESPGroup:AddToggle("ItemESP", {
    Text = "物资透视",
    Default = false,
    Callback = function(value)
        esp.setItem(value)
    end
})

local KillGroup = Tabs.Main:AddLeftGroupbox("杀戮")

KillGroup:AddToggle("KillAura", {
    Text = "杀戮光环",
    Default = false,
    Callback = function(value)
        killAura.setEnabled(value)
    end
})

KillGroup:AddSlider("KillRange", {
    Text = "攻击距离",
    Default = 50,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Callback = function(value)
        killAura.setRange(value)
    end
})

KillGroup:AddSlider("KillInterval", {
    Text = "攻击频率",
    Default = 0.01,
    Min = 0.01,
    Max = 1,
    Rounding = 2,
    Callback = function(value)
        killAura.setInterval(value)
    end
})

KillGroup:AddToggle("GodMode", {
    Text = "无敌",
    Default = false,
    Callback = function(value)
        godMode.setE(value)
    end
})

local MoveGroup = Tabs.Main:AddLeftGroupbox("移动")

MoveGroup:AddToggle("SpeedBypass", {
    Text = "移速绕过",
    Default = false,
    Callback = function(value)
        speedMod.setE(value)
    end
})

MoveGroup:AddSlider("SpeedValue", {
    Text = "移速数值",
    Default = 20,
    Min = 0,
    Max = 200,
    Rounding = 0,
    Callback = function(value)
        speedMod.setV(value)
    end
})

MoveGroup:AddToggle("FlyBypass", {
    Text = "飞行绕过",
    Default = false,
    Callback = function(value)
        flyMod.setE(value)
    end
})

MoveGroup:AddSlider("FlySpeed", {
    Text = "飞行速度",
    Default = 100,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Callback = function(value)
        flyMod.setS(value)
    end
})

MoveGroup:AddToggle("NoClip", {
    Text = "穿墙",
    Default = false,
    Callback = function(value)
        noclipMod.setE(value)
    end
})

MoveGroup:AddToggle("InfJump", {
    Text = "无限跳",
    Default = false,
    Callback = function(value)
        infJump.setE(value)
    end
})

local function getMP(m)
    local p = m:FindFirstChildWhichIsA("BasePart")
    if p then return p end
    local n = {"MainPart", "Part", "Union1", "Mesh", "FakeHandle", "Handle", "Can", "Chips", "Beans", "Box", "Lid", "Blade", "Screws", "Bloxiade", "Tray"}
    for _, v in ipairs(n) do
        local c = m:FindFirstChild(v)
        if c and c:IsA("BasePart") then return c end
    end
    return nil
end

local function getAD()
    local rs = ReplicatedStorage
    local rm = rs:FindFirstChild("Remotes")
    local tl = rm and rm:FindFirstChild("Tools")
    return tl and tl:FindFirstChild("AdjustBackpack")
end

local function reqOwn(m)
    local pt = getMP(m)
    if not pt then return end
    local rq = m:FindFirstChild("RequestNetworkOwnership", true)
    if not rq then
        local id = m:FindFirstChild("ItemDrag", true)
        if id then rq = id:FindFirstChild("RequestNetworkOwnership") end
    end
    if rq and rq:IsA("RemoteEvent") then
        pcall(function() rq:FireServer(pt) end)
    end
end

local function instantPull(filterFunc)
    local ad = getAD()
    if not ad then return end
    local ch = player.Character
    if not ch then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local pos = hrp.Position
    local it = Workspace:FindFirstChild("DroppedItems")
    if not it then return end
    for _, m in pairs(it:GetChildren()) do
        if m:IsA("Model") and filterFunc(m.Name) then
            local pt = getMP(m)
            if pt then
                reqOwn(m)
                pcall(function() pt.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0)) end)
                pcall(function() ad:FireServer(m) end)
                pcall(function() ad:FireServer(nil, CFrame.new(pos + Vector3.new(0, 5, 0))) end)
            end
        end
    end
end

local itemNameMap = {
    ["Fuel"] = "燃料",
    ["Bandage"] = "绷带",
    ["Molotov"] = "燃烧瓶",
    ["Tear Gas"] = "催泪瓦斯",
    ["Grenade"] = "手雷",
    ["Pistol Ammo"] = "手枪弹药",
    ["Long Ammo"] = "步枪弹药",
    ["Shells"] = "霰弹",
    ["Medium Ammo"] = "中号弹药",
    ["Chips"] = "薯片",
    ["Beans"] = "豆子",
    ["Bloxiade"] = "能量饮料",
    ["Bloxy Cola"] = "可乐",
    ["Battery"] = "电池",
    ["Screws"] = "螺丝",
    ["Scrap"] = "废料",
    ["Spatula"] = "锅铲",
    ["Knife"] = "刀",
    ["Crowbar"] = "撬棍",
    ["Barbed Wire"] = "铁丝网",
    ["Tray"] = "托盘",
}

local zhToEn = {}
for en, zh in pairs(itemNameMap) do
    zhToEn[zh] = en
end

local itemCategories = {
    ["燃料"] = {"Fuel"},
    ["医疗"] = {"Bandage"},
    ["物资"] = {"Molotov", "Tear Gas", "Grenade"},
    ["弹药"] = {"Pistol Ammo", "Long Ammo", "Shells", "Medium Ammo"},
    ["食物"] = {"Chips", "Beans", "Bloxiade", "Bloxy Cola"},
    ["材料"] = {"Battery", "Screws", "Scrap"},
    ["工具"] = {"Spatula", "Knife", "Crowbar", "Barbed Wire", "Tray"},
}

local autoPull = {on = false, interval = 2, conn = nil, last = 0, sel = {}, idx = 1}

local function autoFilter()
    if not autoPull.sel or next(autoPull.sel) == nil then
        return function() return true end
    end
    return function(name) return autoPull.sel[name] == true end
end

local function getAutoItems()
    local f = autoFilter()
    local it = Workspace:FindFirstChild("DroppedItems")
    if not it then return {} end
    local list = {}
    for _, m in pairs(it:GetChildren()) do
        if m:IsA("Model") and f(m.Name) then
            table.insert(list, m)
        end
    end
    return list
end

local function autoLoop()
    if not autoPull.on then return end
    local items = getAutoItems()
    if #items == 0 then return end
    local idx = autoPull.idx
    if idx > #items then idx = 1 end
    autoPull.idx = idx + 1
    local m = items[idx]
    local pt = getMP(m)
    if not pt then return end
    local ad = getAD()
    if not ad then return end
    local ch = player.Character
    if not ch then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local pos = hrp.Position
    reqOwn(m)
    pcall(function() pt.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0)) end)
    pcall(function() ad:FireServer(m) end)
    pcall(function() ad:FireServer(nil, CFrame.new(pos + Vector3.new(0, 5, 0))) end)
end

local function startAuto()
    if autoPull.conn then return end
    autoPull.last = 0
    autoPull.idx = 1
    autoPull.conn = RunService.Heartbeat:Connect(function()
        if not autoPull.on then return end
        local n = tick()
        if n - autoPull.last >= autoPull.interval then
            autoPull.last = n
            autoLoop()
        end
    end)
end

local function stopAuto()
    if autoPull.conn then
        autoPull.conn:Disconnect()
        autoPull.conn = nil
    end
    autoPull.on = false
end

local PullGroup = Tabs.Main:AddRightGroupbox("拉取物资")

PullGroup:AddToggle("AutoPull", {
    Text = "自动拉取",
    Default = false,
    Callback = function(v)
        autoPull.on = v
        if v then startAuto() else stopAuto() end
    end
})

PullGroup:AddSlider("AutoInterval", {
    Text = "拉取间隔",
    Default = 2,
    Min = 0.5,
    Max = 5,
    Rounding = 1,
    Callback = function(v)
        autoPull.interval = v
    end
})

PullGroup:AddButton("瞬间收放所有", function()
    instantPull(function() return true end)
end)

for catName, items in pairs(itemCategories) do
    local g = Tabs.Main:AddRightGroupbox(catName)
    local zhList = {}
    for _, en in ipairs(items) do
        table.insert(zhList, itemNameMap[en] or en)
    end
    local selected = {}

    g:AddDropdown(catName .. "Dropdown", {
        Text = catName .. " 选定",
        Values = zhList,
        Multi = true,
        Default = {},
        Callback = function(values)
            selected = {}
            autoPull.sel = {}
            for zh, _ in pairs(values) do
                local en = zhToEn[zh]
                if en then
                    selected[en] = true
                    autoPull.sel[en] = true
                end
            end
        end,
    })

    g:AddButton("瞬间收放选定", function()
        instantPull(function(name) return selected[name] == true end)
    end)

    g:AddButton("瞬间收放所有", function()
        local set = {}
        for _, n in ipairs(items) do set[n] = true end
        instantPull(function(name) return set[name] == true end)
    end)
end

local UnloadGroup = Tabs.Settings:AddLeftGroupbox("脚本管理")
UnloadGroup:AddButton("卸载脚本", function()
    esp.stop()
    killAura.setEnabled(false)
    godMode.setE(false)
    speedMod.setE(false)
    flyMod.setE(false)
    noclipMod.setE(false)
    infJump.setE(false)
    stopAuto()
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
