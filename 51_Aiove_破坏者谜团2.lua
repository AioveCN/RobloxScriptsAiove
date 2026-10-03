-- This file has been deobfuscated Luraph using Hurricane https://discord.com/invite/AbeurBzKXe
game:GetService("StarterGui"):SetCore("SendNotification", { Title = "破坏者谜团2脚本", Text = "创作者：Aiove\nQQ: 3999698324", Icon = "rbxthumb://type=Asset&id=5107182114&w=150&h=150" }) local function safeLoad(url) local success, result = pcall(function() return loadstring(game:HttpGet(url))() end) if not success then warn("加载失败: " .. url) return nil end return result end local Library = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/黑曜石主库.ui") local ThemeManager = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/主题管理.ui") local SaveManager = safeLoad("https://raw.githubusercontent.com/kongbaNB/ui/refs/heads/main/配置管理.ui") if not Library then game:GetService("StarterGui"):SetCore("SendNotification", { Title = "错误", Text = "UI 库加载失败，请检查网络或脚本资源", Duration = 5, }) return end
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local Notify do local _n = function() end Notify = function(m) _n(m) end end
local Window
local jobEspEnabled, jobEspLoop, autoKillLoop, autoPickGunEnabled, autoPickGunLoop, autoCollectGoldEnabled, autoCollectGoldLoop, coinTaffyV2, coinTaffyV2Loop, trackLoop, crosshairUI, currentFollowLoop, ignoreKnife = false, nil, nil, false, nil, false, nil, false, nil, nil, nil, nil, false
local killAuraLoop, TaffyAu, godModeEnabled, rangeEnabled, rangeBox, rangeSize, gunESP, trapESP, antifail = nil, false, false, false, false, 1, false, false, false
local trapHighlight, gunHighlight
trapHighlight = Instance.new("Highlight") trapHighlight.Name = "TrapESP" trapHighlight.FillColor = Color3.fromRGB(255, 112, 10) trapHighlight.OutlineColor = Color3.fromRGB(255, 112, 10) trapHighlight.FillTransparency = 0.5
gunHighlight = Instance.new("Highlight") gunHighlight.Name = "GunESP" gunHighlight.FillColor = Color3.fromRGB(255, 255, 0) gunHighlight.OutlineTransparency = 1 gunHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

local function findMurderer()
    for _, i in ipairs(Players:GetPlayers()) do if i.Backpack:FindFirstChild("Knife") then return i end end
    for _, i in ipairs(Players:GetPlayers()) do if i.Character and i.Character:FindFirstChild("Knife") then return i end end
    return nil
end
local function findSheriff()
    for _, i in ipairs(Players:GetPlayers()) do if i.Backpack:FindFirstChild("Gun") then return i end end
    for _, i in ipairs(Players:GetPlayers()) do if i.Character and i.Character:FindFirstChild("Gun") then return i end end
    return nil
end
local function findNearestPlayer()
    local nearest, minDist = nil, math.huge
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local otherRoot = p.Character:FindFirstChild("HumanoidRootPart")
            if otherRoot then
                local d = (myRoot.Position - otherRoot.Position).Magnitude
                if d < minDist then minDist = d; nearest = p end
            end
        end
    end
    return nearest
end
local function getMap()
    for _, o in ipairs(Workspace:GetChildren()) do if o:FindFirstChild("CoinContainer") and o:FindFirstChild("Spawns") then return o end end
    return nil
end
local function GetJob(p)
    local k,s = false,false
    local function c(it) if it:IsA("Tool") then local n=it.Name:lower() if n:find("knife") or n:find("刀") then k=true end if n:find("gun") or n:find("手枪") or n:find("警长") or n:find("revolver") then s=true end end end
    if p.Backpack then for _,v in pairs(p.Backpack:GetChildren()) do c(v) end end
    if p.Character then for _,v in pairs(p.Character:GetChildren()) do c(v) end end
    return k and "杀手" or s and "警长" or "平民"
end
local function GetWeapon(p, wtype)
    local char, bp = p.Character, p.Backpack
    if not char and not bp then return nil end
    local targets = wtype=="knife" and {"knife","刀"} or {"gun","手枪","警长","revolver"}
    local function check(item) if not item or not item:IsA("Tool") then return false end local n=item.Name:lower() for _,kw in ipairs(targets) do if n:find(kw) then return true end end return false end
    if char then for _,item in ipairs(char:GetChildren()) do if check(item) then return item end end end
    if bp then for _,item in ipairs(bp:GetChildren()) do if check(item) then return item end end end
    return nil
end
local function powerfulFling(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then Notify("目标玩家无效") return end
    local char = LocalPlayer.Character local hum = char and char:FindFirstChildOfClass("Humanoid") local root = hum and hum.RootPart
    local tChar = targetPlayer.Character local tHum = tChar:FindFirstChildOfClass("Humanoid") local tRoot = tHum and tHum.RootPart
    local tHead = tChar:FindFirstChild("Head") local acc = tChar:FindFirstChildOfClass("Accessory") local handle = acc and acc:FindFirstChild("Handle")
    if not char or not hum or not root then Notify("你的角色无效") return end
    if root.Velocity.Magnitude < 50 then getgenv().OldPos = root.CFrame end
    if not getgenv().FPDH then getgenv().FPDH = Workspace.FallenPartsDestroyHeight end
    if tHead then Workspace.CurrentCamera.CameraSubject = tHead elseif not tHead and handle then Workspace.CurrentCamera.CameraSubject = handle elseif tHum and tRoot then Workspace.CurrentCamera.CameraSubject = tHum end
    if not tChar:FindFirstChildWhichIsA("BasePart") then Notify("目标没有有效部位") return end
    local FPos = function(bp, pos, ang) root.CFrame = CFrame.new(bp.Position) * pos * ang char:SetPrimaryPartCFrame(CFrame.new(bp.Position) * pos * ang) root.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7) root.RotVelocity = Vector3.new(9e8, 9e8, 9e8) end
    local SFBasePart = function(bp)
        local timeout = tick() + 2 local angle = 0
        repeat
            if root and tHum then
                if bp.Velocity.Magnitude < 50 then
                    angle = angle + 100
                    FPos(bp, CFrame.new(0,1.5,0) + tHum.MoveDirection * bp.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(angle),0,0)) task.wait()
                    FPos(bp, CFrame.new(0,-1.5,0) + tHum.MoveDirection * bp.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(angle),0,0)) task.wait()
                    FPos(bp, CFrame.new(2.25,1.5,-2.25) + tHum.MoveDirection * bp.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(angle),0,0)) task.wait()
                    FPos(bp, CFrame.new(-2.25,-1.5,2.25) + tHum.MoveDirection * bp.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(angle),0,0)) task.wait()
                    FPos(bp, CFrame.new(0,1.5,0) + tHum.MoveDirection, CFrame.Angles(math.rad(angle),0,0)) task.wait()
                    FPos(bp, CFrame.new(0,-1.5,0) + tHum.MoveDirection, CFrame.Angles(math.rad(angle),0,0)) task.wait()
                else
                    FPos(bp, CFrame.new(0,1.5,tHum.WalkSpeed), CFrame.Angles(math.rad(90),0,0)) task.wait()
                    FPos(bp, CFrame.new(0,-1.5,-tHum.WalkSpeed), CFrame.Angles(0,0,0)) task.wait()
                    FPos(bp, CFrame.new(0,1.5,tHum.WalkSpeed), CFrame.Angles(math.rad(90),0,0)) task.wait()
                    FPos(bp, CFrame.new(0,1.5,tRoot.Velocity.Magnitude/1.25), CFrame.Angles(math.rad(90),0,0)) task.wait()
                    FPos(bp, CFrame.new(0,-1.5,-tRoot.Velocity.Magnitude/1.25), CFrame.Angles(0,0,0)) task.wait()
                    FPos(bp, CFrame.new(0,1.5,tRoot.Velocity.Magnitude/1.25), CFrame.Angles(math.rad(90),0,0)) task.wait()
                    FPos(bp, CFrame.new(0,-1.5,0), CFrame.Angles(math.rad(90),0,0)) task.wait()
                    FPos(bp, CFrame.new(0,-1.5,0), CFrame.Angles(0,0,0)) task.wait()
                    FPos(bp, CFrame.new(0,-1.5,0), CFrame.Angles(math.rad(-90),0,0)) task.wait()
                    FPos(bp, CFrame.new(0,-1.5,0), CFrame.Angles(0,0,0)) task.wait()
                end
            else break end
        until bp.Velocity.Magnitude > 500 or bp.Parent ~= targetPlayer.Character or targetPlayer.Parent ~= Players or targetPlayer.Character ~= tChar or (tHum and tHum.Sit) or hum.Health <= 0 or tick() > timeout
    end
    Workspace.FallenPartsDestroyHeight = 0/0
    local bv = Instance.new("BodyVelocity") bv.Name="EpixVel" bv.Parent=root bv.Velocity=Vector3.new(9e8,9e8,9e8) bv.MaxForce=Vector3.new(1/0,1/0,1/0)
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    if tRoot and tHead then if (tRoot.CFrame.p - tHead.CFrame.p).Magnitude>5 then SFBasePart(tHead) else SFBasePart(tRoot) end
    elseif tRoot and not tHead then SFBasePart(tRoot)
    elseif not tRoot and tHead then SFBasePart(tHead)
    elseif not tRoot and not tHead and acc and handle then SFBasePart(handle)
    else Notify("找不到合适的甩飞部位") bv:Destroy() return end
    bv:Destroy()
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    Workspace.CurrentCamera.CameraSubject = hum
    repeat
        root.CFrame = getgenv().OldPos * CFrame.new(0,0.5,0)
        char:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0,0.5,0))
        hum:ChangeState("GettingUp")
        for _, x in pairs(char:GetChildren()) do if x:IsA("BasePart") then x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new() end end
        task.wait()
    until (root.Position - getgenv().OldPos.p).Magnitude < 25
    Workspace.FallenPartsDestroyHeight = getgenv().FPDH
end
local function getClosestModel(models)
    local closest, minDist = nil, math.huge
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    for _, model in ipairs(models) do
        local pos = model:GetPivot().Position
        local dist = (myRoot.Position - pos).Magnitude
        if dist < minDist then minDist = dist; closest = model end
    end
    return closest
end
local function enableCoinV2()
    coinTaffyV2 = true
    coinTaffyV2Loop = task.spawn(function()
        while task.wait(0.01) and coinTaffyV2 do
            local map = getMap()
            if map and map:FindFirstChild("CoinContainer") then
                local coins = map.CoinContainer:GetChildren()
                if #coins > 1 then
                    local closest = getClosestModel(coins)
                    if closest and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - closest:GetPivot().Position).Magnitude
                        local tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart, TweenInfo.new(dist*0.05), {CFrame = closest:GetPivot()})
                        tween:Play() tween.Completed:Wait()
                        task.wait(0.01)
                        closest:Destroy()
                    end
                end
            end
        end
    end)
end
local function disableCoinV2()
    coinTaffyV2 = false
    if coinTaffyV2Loop then task.cancel(coinTaffyV2Loop) end
end
local function enableCoinV1()
    if autoCollectGoldLoop then task.cancel(autoCollectGoldLoop) end
    autoCollectGoldLoop = task.spawn(function()
        while autoCollectGoldEnabled do
            task.wait(0.3)
            pcall(function()
                local myChar = LocalPlayer.Character local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart") local myHum = myChar and myChar:FindFirstChild("Humanoid")
                if not myChar or not myRoot or not myHum or myHum.Health<=0 then return end
                local golds = {}
                for _, desc in ipairs(Workspace:GetDescendants()) do
                    local nl = desc.Name:lower() local isGold = false
                    for _, kw in ipairs({"coin","金币","gold","money","cash","钱"}) do if nl:find(kw) then isGold=true break end end
                    if isGold and (desc:IsA("Tool") or desc:IsA("BasePart") or desc:IsA("Model")) then table.insert(golds, desc) end
                end
                for _, gold in ipairs(golds) do
                    if not autoCollectGoldEnabled then break end
                    if not myChar or not myChar.Parent or not myRoot or not myRoot.Parent then break end
                    if gold:IsA("Tool") then
                        if gold.Parent~=LocalPlayer.Backpack and gold.Parent~=myChar then gold.Parent = LocalPlayer.Backpack task.wait(0.3) end
                    elseif gold:IsA("BasePart") or gold:IsA("Model") then
                        local pos = gold:IsA("Model") and gold:FindFirstChild("HumanoidRootPart") and gold.HumanoidRootPart.Position or (gold:IsA("BasePart") and gold.Position or nil)
                        if pos then local orig = myRoot.CFrame myRoot.CFrame = CFrame.new(pos+Vector3.new(0,2,0)) task.wait(0.05) myRoot.CFrame = orig task.wait(0.3) end
                    end
                end
            end)
        end
    end)
end
local function disableCoinV1()
    autoCollectGoldEnabled = false
    if autoCollectGoldLoop then task.cancel(autoCollectGoldLoop) end
end
local function ClearHighlights()
    for _, v in ipairs(Workspace:GetDescendants()) do if v:IsA("Highlight") and v.Name=="JobHighlight" then v:Destroy() end end
end
local function UpdateHighlights()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr==LocalPlayer then continue end
        local char = plr.Character if not char then continue end
        local hum = char:FindFirstChild("Humanoid") if not hum or hum.Health<=0 then continue end
        local hl = char:FindFirstChild("JobHighlight")
        if not hl then hl = Instance.new("Highlight") hl.Name="JobHighlight" hl.Parent=char hl.FillTransparency=0.6 hl.OutlineTransparency=0 hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop end
        local job = GetJob(plr)
        if job=="杀手" then hl.FillColor=Color3.new(1,0,0) hl.OutlineColor=Color3.new(1,0,0)
        elseif job=="警长" then hl.FillColor=Color3.new(0,0.5,1) hl.OutlineColor=Color3.new(0,0.5,1)
        else hl.FillColor=Color3.new(1,1,1) hl.OutlineColor=Color3.new(1,1,1) end
    end
end
local function enableJobESP()
    jobEspEnabled = true
    if jobEspLoop then task.cancel(jobEspLoop) end
    jobEspLoop = task.spawn(function()
        while jobEspEnabled do
            pcall(function()
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr.Character and plr.Character:FindFirstChild("Head") then
                        local head = plr.Character.Head local label = head:FindFirstChild("JobLabel")
                        if not label then
                            label = Instance.new("BillboardGui") label.Name="JobLabel" label.Parent=head label.Size=UDim2.new(0,100,0,30) label.StudsOffset=Vector3.new(0,2.5,0) label.AlwaysOnTop=true
                            local txt = Instance.new("TextLabel") txt.Parent=label txt.BackgroundTransparency=1 txt.Size=UDim2.new(1,0,1,0) txt.TextSize=15 txt.Font=Enum.Font.ArialBold label.TextLabel=txt
                        end
                        local txt = label.TextLabel local job = GetJob(plr) txt.Text=job
                        if job=="杀手" then txt.TextColor3=Color3.new(1,0,0)
                        elseif job=="警长" then txt.TextColor3=Color3.new(0,0.5,1)
                        else txt.TextColor3=Color3.new(1,1,1) end
                    end
                end
                UpdateHighlights()
            end)
            task.wait(0.3)
        end
    end)
end
local function disableJobESP()
    jobEspEnabled = false
    if jobEspLoop then task.cancel(jobEspLoop) end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("Head") then
            local label = plr.Character.Head:FindFirstChild("JobLabel") if label then label:Destroy() end
        end
    end
    ClearHighlights()
end
local function enableAutoPickGun()
    autoPickGunEnabled = true
    autoPickGunLoop = task.spawn(function()
        while autoPickGunEnabled do
            task.wait(0.3)
            local myChar = LocalPlayer.Character local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart") local myHum = myChar and myChar:FindFirstChild("Humanoid")
            if not myChar or not myRoot or not myHum or myHum.Health<=0 then continue end
            if GetWeapon(LocalPlayer,"gun") then continue end
            local target
            for _, desc in ipairs(Workspace:GetDescendants()) do
                if desc:IsA("Tool") then
                    local nl = desc.Name:lower() local isGun = false
                    for _,kw in ipairs({"gun","手枪","警长","revolver"}) do if nl:find(kw) then isGun=true break end end
                    if not isGun then continue end
                    if desc:IsDescendantOf(Workspace) and not desc:IsDescendantOf(LocalPlayer) then target=desc break end
                end
            end
            if target then
                local orig = myRoot.CFrame local pos = target:IsA("BasePart") and target.Position or (target:FindFirstChild("Handle") and target.Handle.Position) or nil
                if pos then myRoot.CFrame = CFrame.new(pos+Vector3.new(0,2,0)) task.wait(0.3) pcall(function() target.Parent = LocalPlayer.Backpack end) myRoot.CFrame = orig Notify("已拾取一把警长枪械") end
            end
        end
    end)
end
local function disableAutoPickGun()
    autoPickGunEnabled = false
    if autoPickGunLoop then task.cancel(autoPickGunLoop) end
end
local function KillerAutoKillAll()
    if GetJob(LocalPlayer)~="杀手" then Notify("仅杀手可使用此功能") return end
    if autoKillLoop then task.cancel(autoKillLoop) autoKillLoop=nil Notify("自动清场已停止") return end
    local targets = {}
    for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health>0 then if GetJob(p)=="警长" then table.insert(targets,1,p) else table.insert(targets,p) end end end
    if #targets==0 then Notify("未找到存活目标") return end
    local knife = GetWeapon(LocalPlayer,"knife") if not knife then Notify("未找到你的刀，无法执行") return end
    Notify("开始清场，共"..#targets.."个目标")
    autoKillLoop = task.spawn(function()
        local kills = 0
        for _, target in ipairs(targets) do
            local myChar = LocalPlayer.Character local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart") local myHum = myChar and myChar:FindFirstChild("Humanoid") local curKnife = GetWeapon(LocalPlayer,"knife")
            if not myChar or not myRoot or not myHum or myHum.Health<=0 or not curKnife then autoKillLoop=nil Notify("你已死亡或武器丢失，清场停止") return end
            if not target or not target:IsDescendantOf(Players) or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") or not target.Character:FindFirstChild("Humanoid") or target.Character.Humanoid.Health<=0 then Notify("目标"..target.Name.."已死亡") continue end
            local tRoot = target.Character.HumanoidRootPart myRoot.CFrame = tRoot.CFrame * CFrame.new(0,0,2) task.wait(0.1)
            curKnife:Equip() task.wait(0.05) curKnife:Activate()
            local start = os.clock() local died = false
            while os.clock()-start < 5 do
                task.wait(0.1)
                local tHum = target.Character and target.Character:FindFirstChild("Humanoid") if not tHum or tHum.Health<=0 then died=true break end
                local mHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") if not mHum or mHum.Health<=0 then autoKillLoop=nil Notify("你已死亡，清场停止") return end
                local nKnife = GetWeapon(LocalPlayer,"knife") if not nKnife then autoKillLoop=nil Notify("武器丢失，清场停止") return end
                local ntRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart") local nmRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if ntRoot and nmRoot then nmRoot.CFrame = ntRoot.CFrame*CFrame.new(0,0,2) nKnife:Equip() task.wait(0.05) nKnife:Activate() end
            end
            if died then kills=kills+1 Notify("已击杀 "..target.Name.." ("..kills.."/"..#targets..")") else Notify("超时，跳过 "..target.Name) end
        end
        autoKillLoop=nil Notify("清场完成，共击杀"..kills.."个目标")
    end)
end
local function KillAllV2()
    if GetJob(LocalPlayer)~="杀手" then Notify("仅杀手可使用此功能") return end
    if not LocalPlayer.Character:FindFirstChild("Knife") then if LocalPlayer.Backpack:FindFirstChild("Knife") then LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack.Knife) else Notify("你没有刀") return end end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.Anchored = true
            p.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector * 1
        end
    end
    LocalPlayer.Character.Knife.Stab:FireServer("Slash")
    Notify("已尝试杀死所有人")
end
local function HostageAll()
    if GetJob(LocalPlayer)~="杀手" then Notify("仅杀手可使用此功能") return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.Anchored = true
            p.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector * 5
        end
    end
    Notify("已把所有人扣为人质")
end
local function enableKillAura()
    TaffyAu = true
    if killAuraLoop then killAuraLoop:Disconnect() end
    killAuraLoop = RunService.Heartbeat:Connect(function()
        if GetJob(LocalPlayer)~="杀手" then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local tr = p.Character.HumanoidRootPart
                local mr = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if mr and (tr.Position - mr.Position).Magnitude < 7 then
                    tr.Anchored = true
                    tr.CFrame = mr.CFrame + mr.CFrame.LookVector * 2
                    task.wait(0.1)
                    local knife = LocalPlayer.Character:FindFirstChild("Knife")
                    if knife then knife.Stab:FireServer("Slash")
                    elseif LocalPlayer.Backpack:FindFirstChild("Knife") then
                        LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack.Knife)
                        task.wait(0.2)
                        LocalPlayer.Character.Knife.Stab:FireServer("Slash")
                    end
                    return
                end
            end
        end
    end)
end
local function disableKillAura()
    TaffyAu = false
    if killAuraLoop then killAuraLoop:Disconnect() end
end
local function throwKillNearest()
    if GetJob(LocalPlayer)~="杀手" then Notify("你不是杀手") return end
    local nearest = findNearestPlayer()
    if not nearest or not nearest.Character then Notify("找不到玩家") return end
    local lpknife = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
    if not lpknife then Notify("你没有刀") return end
    if LocalPlayer.Backpack:FindFirstChild("Knife") then LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack.Knife) task.wait(0.1) end
    local rp = RaycastParams.new() rp.FilterType = Enum.RaycastFilterType.Exclude rp.FilterDescendantsInstances = {LocalPlayer.Character}
    LocalPlayer.Character.Knife.Throw:FireServer(lpknife:GetPivot(), nearest.Character.HumanoidRootPart.Position)
    Notify("飞刀已掷向最近玩家")
end
local function GodMode()
    local char = LocalPlayer.Character local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then Notify("找不到角色") return end
    local nHum = hum:Clone() nHum.Parent = char
    LocalPlayer.Character = nil
    nHum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    nHum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    nHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    nHum.BreakJointsOnDeath = false
    hum:Destroy()
    LocalPlayer.Character = char
    Camera.CameraSubject = nHum
    nHum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    local anim = char:FindFirstChild("Animate") if anim then anim.Disabled = true task.wait(0.1) anim.Disabled = false end
    nHum.Health = nHum.MaxHealth
    Notify("上帝模式已开启")
end
local function enableRange()
    rangeEnabled = true
    task.spawn(function()
        while rangeEnabled do
            for _, v in ipairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    local sz = Vector3.new(rangeSize, rangeSize, rangeSize)
                    if rangeBox then
                        for _, part in ipairs(v.Character:GetChildren()) do if part:IsA("BasePart") then part.Size = sz part.Transparency = 0.2 end end
                    else
                        local root = v.Character.HumanoidRootPart
                        root.Size = sz root.Transparency = 0.2 root.CanCollide = false
                    end
                end
            end
            task.wait(0.2)
        end
    end)
end
local function disableRange()
    rangeEnabled = false
end
local function teleportToGunDrop()
    local map = getMap() if not map or not map:FindFirstChild("GunDrop") then Notify("没有掉落枪支") return end
    local gun = map.GunDrop
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local prev = LocalPlayer.Character.HumanoidRootPart.CFrame
        LocalPlayer.Character.HumanoidRootPart.CFrame = gun:GetPivot()
        local conn conn = LocalPlayer.Backpack.ChildAdded:Connect(function(child)
            if child.Name == "Gun" then conn:Disconnect() task.wait(0.5) LocalPlayer.Character.HumanoidRootPart.CFrame = prev end
        end)
        task.delay(5, function() if conn then conn:Disconnect() LocalPlayer.Character.HumanoidRootPart.CFrame = prev end end)
    end
end

local function loadFlightScript()
    local ok, err = pcall(function()
        local main = Instance.new("ScreenGui") main.Name="main" main.Parent=LocalPlayer:WaitForChild("PlayerGui") main.ZIndexBehavior=Enum.ZIndexBehavior.Sibling main.ResetOnSpawn=false
        local Frame = Instance.new("Frame") Frame.Parent=main Frame.BackgroundColor3=Color3.fromRGB(163,255,137) Frame.BorderColor3=Color3.fromRGB(103,221,213) Frame.Position=UDim2.new(0.1,0,0.38,0) Frame.Size=UDim2.new(0,190,0,57)
        local up = Instance.new("TextButton") up.Parent=Frame up.BackgroundColor3=Color3.fromRGB(79,255,152) up.Size=UDim2.new(0,44,0,28) up.Font=Enum.Font.SourceSans up.Text="上升" up.TextColor3=Color3.new(0,0,0) up.TextSize=14
        local down = Instance.new("TextButton") down.Parent=Frame down.BackgroundColor3=Color3.fromRGB(215,255,121) down.Position=UDim2.new(0,0,0.49,0) down.Size=UDim2.new(0,44,0,28) down.Font=Enum.Font.SourceSans down.Text="下落" down.TextColor3=Color3.new(0,0,0) down.TextSize=14
        local onof = Instance.new("TextButton") onof.Parent=Frame onof.BackgroundColor3=Color3.fromRGB(255,249,74) onof.Position=UDim2.new(0.7,0,0.49,0) onof.Size=UDim2.new(0,56,0,28) onof.Font=Enum.Font.SourceSans onof.Text="飞" onof.TextColor3=Color3.new(0,0,0) onof.TextSize=14
        local TextLabel = Instance.new("TextLabel") TextLabel.Parent=Frame TextLabel.BackgroundColor3=Color3.fromRGB(242,60,255) TextLabel.Position=UDim2.new(0.47,0,0,0) TextLabel.Size=UDim2.new(0,100,0,28) TextLabel.Font=Enum.Font.SourceSans TextLabel.Text="Aiove" TextLabel.TextColor3=Color3.new(0,0,0) TextLabel.TextScaled=true TextLabel.TextSize=14 TextLabel.TextWrapped=true
        local plus = Instance.new("TextButton") plus.Parent=Frame plus.BackgroundColor3=Color3.fromRGB(133,145,255) plus.Position=UDim2.new(0.23,0,0,0) plus.Size=UDim2.new(0,45,0,28) plus.Font=Enum.Font.SourceSans plus.Text="+" plus.TextColor3=Color3.new(0,0,0) plus.TextScaled=true plus.TextSize=14 plus.TextWrapped=true
        local speed = Instance.new("TextLabel") speed.Parent=Frame speed.BackgroundColor3=Color3.fromRGB(255,85,0) speed.Position=UDim2.new(0.47,0,0.49,0) speed.Size=UDim2.new(0,44,0,28) speed.Font=Enum.Font.SourceSans speed.Text="1" speed.TextColor3=Color3.new(0,0,0) speed.TextScaled=true speed.TextSize=14 speed.TextWrapped=true
        local mine = Instance.new("TextButton") mine.Parent=Frame mine.BackgroundColor3=Color3.fromRGB(123,255,247) mine.Position=UDim2.new(0.23,0,0.49,0) mine.Size=UDim2.new(0,45,0,29) mine.Font=Enum.Font.SourceSans mine.Text="-" mine.TextColor3=Color3.new(0,0,0) mine.TextScaled=true mine.TextSize=14 mine.TextWrapped=true
        local closebutton = Instance.new("TextButton") closebutton.Parent=Frame closebutton.BackgroundColor3=Color3.fromRGB(225,25,0) closebutton.Font=Enum.Font.SourceSans closebutton.Size=UDim2.new(0,45,0,28) closebutton.Text="X" closebutton.TextSize=30 closebutton.Position=UDim2.new(0,0,-1,27)
        local mini = Instance.new("TextButton") mini.Parent=Frame mini.BackgroundColor3=Color3.fromRGB(192,150,230) mini.Font=Enum.Font.SourceSans mini.Size=UDim2.new(0,45,0,28) mini.Text="-" mini.TextSize=40 mini.Position=UDim2.new(0,44,-1,27)
        local mini2 = Instance.new("TextButton") mini2.Parent=Frame mini2.BackgroundColor3=Color3.fromRGB(192,150,230) mini2.Font=Enum.Font.SourceSans mini2.Size=UDim2.new(0,45,0,28) mini2.Text="+" mini2.TextSize=40 mini2.Position=UDim2.new(0,44,0,30) mini2.Visible=false
        Frame.Active=true Frame.Draggable=true
        local flySpeeds = 1 local flyingNow = false
        local chr = LocalPlayer.Character local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
        closebutton.MouseButton1Click:Connect(function() main:Destroy() end)
        up.MouseButton1Click:Connect(function() if chr and chr:FindFirstChild("HumanoidRootPart") then chr.HumanoidRootPart.CFrame = chr.HumanoidRootPart.CFrame + Vector3.new(0,3,0) end end)
        down.MouseButton1Click:Connect(function() if chr and chr:FindFirstChild("HumanoidRootPart") then chr.HumanoidRootPart.CFrame = chr.HumanoidRootPart.CFrame + Vector3.new(0,-3,0) end end)
        mini.MouseButton1Click:Connect(function() up.Visible=false down.Visible=false onof.Visible=false plus.Visible=false speed.Visible=false mine.Visible=false closebutton.Visible=false mini.Visible=false mini2.Visible=true Frame.Size=UDim2.new(0,100,0,28) TextLabel.Position=UDim2.new(0,0,0,0) end)
        mini2.MouseButton1Click:Connect(function() up.Visible=true down.Visible=true onof.Visible=true plus.Visible=true speed.Visible=true mine.Visible=true closebutton.Visible=true mini.Visible=true mini2.Visible=false Frame.Size=UDim2.new(0,190,0,57) TextLabel.Position=UDim2.new(0.47,0,0,0) end)
        plus.MouseButton1Click:Connect(function() flySpeeds = flySpeeds + 1 speed.Text = tostring(flySpeeds) end)
        mine.MouseButton1Click:Connect(function() if flySpeeds>1 then flySpeeds = flySpeeds - 1 speed.Text = tostring(flySpeeds) else speed.Text="错误" task.wait(0.2) speed.Text="1" end end)
        LocalPlayer.CharacterAdded:Connect(function(newChar) chr = newChar hum = chr:FindFirstChildOfClass("Humanoid") end)
        onof.MouseButton1Click:Connect(function()
            flyingNow = not flyingNow onof.Text = flyingNow and "飞" or "飞"
            if flyingNow then
                if hum then for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do hum:SetStateEnabled(state, false) end hum:ChangeState(Enum.HumanoidStateType.Swimming) end
                if chr.Animate then chr.Animate.Disabled = true end
                if hum then for _, track in next, hum:GetPlayingAnimationTracks() do track:AdjustSpeed(0) end end
                task.spawn(function() while flyingNow and chr and hum do RunService.Heartbeat:Wait() if hum.MoveDirection.Magnitude>0 then chr:TranslateBy(hum.MoveDirection * flySpeeds) end end end)
                if hum.RigType == Enum.HumanoidRigType.R6 then
                    local torso = chr.Torso local bg = Instance.new("BodyGyro", torso) bg.P=9e4 bg.MaxTorque=Vector3.new(9e9,9e9,9e9) bg.CFrame=torso.CFrame local bv = Instance.new("BodyVelocity", torso) bv.Velocity=Vector3.new() bv.MaxForce=Vector3.new(9e9,9e9,9e9)
                    if flyingNow then chr.Humanoid.PlatformStand=true end
                    while flyingNow and chr.Humanoid.Health>0 do RunService.RenderStepped:Wait() bg.CFrame = Workspace.CurrentCamera.CoordinateFrame end
                    bg:Destroy() bv:Destroy() chr.Humanoid.PlatformStand=false chr.Animate.Disabled=false
                else
                    local upper = chr.UpperTorso local bg = Instance.new("BodyGyro", upper) bg.P=9e4 bg.MaxTorque=Vector3.new(9e9,9e9,9e9) bg.CFrame=upper.CFrame local bv = Instance.new("BodyVelocity", upper) bv.Velocity=Vector3.new() bv.MaxForce=Vector3.new(9e9,9e9,9e9)
                    if flyingNow then chr.Humanoid.PlatformStand=true end
                    while flyingNow and chr.Humanoid.Health>0 do wait() bg.CFrame = Workspace.CurrentCamera.CoordinateFrame end
                    bg:Destroy() bv:Destroy() chr.Humanoid.PlatformStand=false chr.Animate.Disabled=false
                end
            else
                if hum then for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do hum:SetStateEnabled(state, true) end hum:ChangeState(Enum.HumanoidStateType.Running) end
                if chr.Animate then chr.Animate.Disabled = false end
            end
        end)
    end)
    if ok then Notify("飞行脚本已加载") else Notify("飞行脚本加载失败: "..tostring(err)) end
end

Window = Library:CreateWindow({ Title = "破坏者谜团2", Footer = "By Aiove | QQ:3999698324", Icon = 131153193945220, NotifySide = "Right", ShowCustomCursor = true })
Notify = function(msg) Library:Notify(msg, 3) end
local Tabs = { Notice = Window:AddTab("通知", "info"), Main = Window:AddTab("主要", "zap"), Teleport = Window:AddTab("传送与跟随", "map"), Settings = Window:AddTab("设置", "settings") }

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel('Aiove将持续更新此脚本')
NoticeGroup:AddLabel('创作者：Aiove')
NoticeGroup:AddLabel('QQ：3999698324')
local selectedTexture = "Aiove"
local function ApplyWindowIcon()
    local id = (selectedTexture=="Aiove" and "rbxassetid://113517588654522") or (selectedTexture=="巨魔" and "rbxassetid://131153193945220") or nil
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            for _, obj in ipairs(gui:GetDescendants()) do
                if obj:IsA("ImageLabel") and obj.Image=="rbxassetid://113517588654522" then
                    if selectedTexture=="删除" then obj.Image="" obj.ImageTransparency=1 else obj.Image=id obj.ImageTransparency=0 end
                    Notify("窗口图标已更新") return
                end
            end
        end
    end
    Notify("未找到图标元素")
end
local SettingsLeft = Tabs.Settings:AddLeftGroupbox("选图案")
SettingsLeft:AddDropdown('WindowIconSelector', { Values = {"Aiove图案", "巨魔图案", "删除图案"}, Default = 1, Text = '窗口图标', Callback = function(Value) selectedTexture = Value end })
SettingsLeft:AddButton({ Text = '应用图标', Func = ApplyWindowIcon, DoubleClick = false })
SettingsLeft:AddButton({ Text = '卸载脚本', Func = function() Library:Unload() end })
local MainLeft = Tabs.Main:AddLeftGroupbox("功能开关")
local MainRight = Tabs.Main:AddRightGroupbox("快捷操作")
MainLeft:AddToggle('JobESP', { Text = '职业透视', Default = false, Callback = function(v) if v then enableJobESP() else disableJobESP() end end })
MainLeft:AddToggle('CoinV1', { Text = '自动捡金币 v1', Default = false, Callback = function(v) autoCollectGoldEnabled = v if v then enableCoinV1() else disableCoinV1() end end })
MainLeft:AddToggle('CoinV2', { Text = '自动捡金币 v2', Default = false, Callback = function(v) if v then enableCoinV2() else disableCoinV2() end end })
MainLeft:AddToggle('AutoPickGun', { Text = '自动捡警长枪', Default = false, Callback = function(v) if v then enableAutoPickGun() else disableAutoPickGun() end end })
MainLeft:AddToggle('IgnoreKnife', { Text = '忽略飞刀', Default = false, Callback = function(v) ignoreKnife = v end })
MainLeft:AddToggle('GunESP', { Text = '高亮地上枪支', Default = false, Callback = function(v) gunESP = v if v then else if Workspace:FindFirstChild("GunESP") then Workspace:FindFirstChild("GunESP"):Destroy() end end end })
MainLeft:AddToggle('TrapESP', { Text = '高亮杀手陷阱', Default = false, Callback = function(v) trapESP = v if v then for _, d in ipairs(Workspace:GetDescendants()) do if d.Name=="Trap" and d.Parent:IsDescendantOf(Workspace) then d.Transparency=0 local e = trapHighlight:Clone() e.Parent=Workspace e.Adornee=d end end else for _, c in ipairs(Workspace:GetChildren()) do if c.Name=="TrapESP" then c:Destroy() end end end end })
MainLeft:AddToggle('Antifail', { Text = '防失败', Default = false, Callback = function(v) antifail = v end })
MainLeft:AddToggle('Range', { Text = '范围修改', Default = false, Callback = function(v) if v then enableRange() else disableRange() end end })
MainLeft:AddToggle('RangeBox', { Text = '范围所有部位', Default = false, Callback = function(v) rangeBox = v end })
MainLeft:AddSlider({ Title = "范围尺寸", Step = 1, Value = {Min = 1, Max = 10, Default = 1}, Callback = function(v) rangeSize = v end })
MainRight:AddButton({ Text = '飞行脚本', Func = loadFlightScript })
MainRight:AddButton({ Text = '上帝模式', Func = GodMode })
MainRight:AddButton({ Text = '甩飞杀手', Func = function() local m = findMurderer() if not m then Notify("找不到杀手") elseif m == LocalPlayer then Notify("不能甩飞自己") else powerfulFling(m) end end })
MainRight:AddButton({ Text = '甩飞警长', Func = function() local s = findSheriff() if not s then Notify("找不到警长") elseif s == LocalPlayer then Notify("不能甩飞自己") else powerfulFling(s) end end })
MainRight:AddButton({ Text = '杀戮光环', Func = function() if TaffyAu then disableKillAura() Notify("杀戮光环已关闭") else enableKillAura() Notify("杀戮光环已开启") end end })
MainRight:AddButton({ Text = '杀死所有人 v2', Func = KillAllV2 })
MainRight:AddButton({ Text = '扣为人质', Func = HostageAll })
MainRight:AddButton({ Text = '飞刀击杀最近玩家', Func = throwKillNearest })
MainRight:AddButton({ Text = '自动清场 (v1)', Func = KillerAutoKillAll })
MainRight:AddButton({ Text = '发送身份到聊天', Func = function()
    local channels = game:GetService("TextChatService"):WaitForChild("TextChannels"):GetChildren()
    for _, ch in ipairs(channels) do
        if ch.Name == "RBXSystem" then continue end
        local murd = findMurderer() local sher = findSheriff()
        local mn = murd and murd.Name or "[未检测到]" local sn = sher and sher.Name or "[未检测到]"
        ch:SendAsync("警长:"..sn.." | 杀手:"..mn)
    end
    Notify("已发送")
end })
MainRight:AddButton({ Text = '传送到掉落的枪', Func = teleportToGunDrop })
local TeleLeft = Tabs.Teleport:AddLeftGroupbox("瞬间传送")
local TeleRight = Tabs.Teleport:AddRightGroupbox("视角与跟随")
TeleLeft:AddButton({ Text = '传送到最近平民', Func = TPC })
TeleLeft:AddButton({ Text = '传送到警长', Func = TPS })
TeleLeft:AddButton({ Text = '传送到杀手', Func = TPK })
TeleLeft:AddLabel('跟随目标（持续传送身后）')
TeleLeft:AddButton({ Text = '跟随平民', Func = function() FollowTargetByJob("平民") end })
TeleLeft:AddButton({ Text = '跟随警长', Func = function() FollowTargetByJob("警长") end })
TeleLeft:AddButton({ Text = '跟随杀手', Func = function() FollowTargetByJob("杀手") end })
TeleRight:AddButton({ Text = '自瞄（锁定杀手视角）', Func = function() if trackLoop then StopTracking() else StartTracking("杀手") end end })
TeleRight:AddButton({ Text = '自瞄（锁定警长视角）', Func = function() if trackLoop then StopTracking() else StartTracking("警长") end end })
TeleRight:AddButton({ Text = '强制取消跟随', Func = ForceStopFollow })
TeleRight:AddButton({ Text = '将杀手传送到出生点', Func = function()
    local found = false
    for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer and GetJob(p)=="杀手" then local char = p.Character if char and char:FindFirstChild("HumanoidRootPart") then char.HumanoidRootPart.CFrame = CFrame.new(352.42,522.05,-8.30) found=true Notify("已将杀手 "..p.Name.." 传送到出生点") end end end
    if not found then Notify("未找到存活的杀手") end
end })

Workspace.DescendantAdded:Connect(function(ch)
    if gunESP and ch.Name=="GunDrop" then
        if not Workspace:FindFirstChild("GunESP") then
            local hl = gunHighlight:Clone() hl.Parent = Workspace hl.Adornee = ch hl.Enabled = true
        else Workspace:FindFirstChild("GunESP").Adornee = ch end
    end
    if trapESP and ch.Name=="Trap" and ch.Parent:IsDescendantOf(Workspace) then
        ch.Transparency = 0
        local e = trapHighlight:Clone() e.Parent = Workspace e.Adornee = ch
    end
end)
Workspace.DescendantRemoving:Connect(function(ch)
    if gunESP and ch.Name=="GunDrop" and Workspace:FindFirstChild("GunESP") then Workspace:FindFirstChild("GunESP"):Destroy() end
end)
game.Workspace.ChildAdded:Connect(function(chi) if chi.Name=="ThrowingKnife" and ignoreKnife then chi:Destroy() end end)
task.spawn(function()
    if RunService:IsStudio() then return end
    local OldNameCall
    OldNameCall = hookmetamethod(game, "__namecall", function(Self, ...)
        local Args = {...}
        if antifail and getnamecallmethod() == "FireServer" and Args[1] == "SetPlayerMinigameResult" then
            Args[2] = true
        end
        return OldNameCall(Self, unpack(Args))
    end)
end)

local function CreateCrosshair()
    if crosshairUI then return end
    crosshairUI = Instance.new("ScreenGui") crosshairUI.Name="CrosshairUI" crosshairUI.Parent=PlayerGui crosshairUI.IgnoreGuiInset=true
    local dot = Instance.new("Frame") dot.Parent=crosshairUI dot.Size=UDim2.new(0,4,0,4) dot.Position=UDim2.new(0.5,-2,0.5,-2) dot.BackgroundColor3=Color3.new(1,1,1) dot.BorderSizePixel=0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
    local outer = Instance.new("Frame") outer.Parent=crosshairUI outer.Size=UDim2.new(0,20,0,20) outer.Position=UDim2.new(0.5,-10,0.5,-10) outer.BackgroundTransparency=1 outer.BorderSizePixel=0
    for i=1,4 do
        local line = Instance.new("Frame") line.Parent=outer line.BackgroundColor3=Color3.new(1,1,1) line.BorderSizePixel=0
        if i<=2 then line.Size=UDim2.new(0,8,0,2) line.Position=i==1 and UDim2.new(0,-8,0.5,-1) or UDim2.new(1,0,0.5,-1)
        else line.Size=UDim2.new(0,2,0,8) line.Position=i==3 and UDim2.new(0.5,-1,0,-8) or UDim2.new(0.5,-1,1,0) end
    end
end
local function RemoveCrosshair()
    if crosshairUI then crosshairUI:Destroy() crosshairUI=nil end
end
local function StartTracking(job)
    if trackLoop then trackLoop:Disconnect() end RemoveCrosshair()
    local target
    for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health>0 then if GetJob(p)==job then target=p break end end end
    if not target then Notify("未找到存活的"..job) return end
    Notify("自瞄已锁定 "..target.Name)
    CreateCrosshair()
    trackLoop = RunService.RenderStepped:Connect(function()
        if not target or not target:IsDescendantOf(Players) or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
            trackLoop:Disconnect() RemoveCrosshair() Notify("自瞄已停止") return
        end
        local myChar = LocalPlayer.Character if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
        local tRoot = target.Character.HumanoidRootPart
        Camera.CameraSubject = tRoot Camera.CameraType = Enum.CameraType.Scriptable
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, tRoot.Position)
    end)
end
local function StopTracking()
    if trackLoop then trackLoop:Disconnect() end RemoveCrosshair()
    Camera.CameraSubject = LocalPlayer.Character Camera.CameraType = Enum.CameraType.Custom Notify("自瞄已停止")
end
local function TP(p)
    local r = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") local tr = p.Character:FindFirstChild("HumanoidRootPart")
    if r and tr then r.CFrame = tr.CFrame*CFrame.new(0,0,2) Notify("已传送到 "..p.Name) end
end
local function TPC()
    local l = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if not l then return end
    local minDist, t = math.huge, nil
    for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer and GetJob(p)=="平民" and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then local d = (p.Character.HumanoidRootPart.Position - l.Position).Magnitude if d<minDist then minDist=d; t=p end end end
    if t then TP(t) else Notify("未找到平民") end
end
local function TPS()
    for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer and GetJob(p)=="警长" and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then TP(p) return end end
    Notify("未找到警长")
end
local function TPK()
    for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer and GetJob(p)=="杀手" and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then TP(p) return end end
    Notify("未找到杀手")
end
local function FollowTargetByJob(job)
    if currentFollowLoop then currentFollowLoop:Disconnect() end
    local target
    for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health>0 then if GetJob(p)==job then target=p break end end end
    if not target then Notify("未找到存活的"..job.."目标") return end
    Notify("跟随已开启，锁定 "..target.Name)
    currentFollowLoop = RunService.Heartbeat:Connect(function()
        if not target or not target:IsDescendantOf(Players) or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") or not target.Character:FindFirstChild("Humanoid") or target.Character.Humanoid.Health<=0 or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            currentFollowLoop:Disconnect() Notify("跟随已停止") return
        end
        LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,2)
    end)
end
local function ForceStopFollow()
    if currentFollowLoop then currentFollowLoop:Disconnect() Notify("跟随已强制取消") else Notify("当前没有跟随目标") end
end
if ThemeManager then ThemeManager:SetLibrary(Library) ThemeManager:SetFolder("DestroyerMystery2") ThemeManager:ApplyToTab(Tabs.Settings) end
if SaveManager then SaveManager:SetLibrary(Library) SaveManager:IgnoreThemeSettings() SaveManager:SetFolder("DestroyerMystery2") SaveManager:BuildConfigSection(Tabs.Settings) end
