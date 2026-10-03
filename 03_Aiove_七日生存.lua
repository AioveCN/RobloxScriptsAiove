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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local Window = Library:CreateWindow({
    Title = "7日生存",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify({
    Title = "7日生存",
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

local translatedTexts = {}
local FakeBody = nil
local TreeAuraLoop = nil
local SingleTreeLoop = nil
local KillAuraLoop = nil
local AutoScrapLoop = nil
local FallConn = nil
local AutoInteractConn = nil
local AutoChopLoop = nil
local HomeMarker = nil

local function getChar()
    local plr = Players.LocalPlayer
    return plr and plr.Character
end

local function getRoot()
    local char = getChar()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getPos()
    local root = getRoot()
    return root and root.Position or Vector3.new(0, 0, 0)
end

local function distTo(pos)
    return (getPos() - pos).Magnitude
end

local function isEnglish(str)
    if not str or str == "" then return false end
    local letters = 0
    local total = 0
    for i = 1, #str do
        local c = str:sub(i, i)
        if c:match("%a") then
            letters = letters + 1
        end
        if c:match("%S") then
            total = total + 1
        end
    end
    if total == 0 then return false end
    return (letters / total) > 0.5
end

local function translateName(obj, callback)
    local name = obj.Name
    if translatedTexts[name] then
        if callback then callback(translatedTexts[name]) end
        return
    end
    if not isEnglish(name) then
        translatedTexts[name] = name
        if callback then callback(name) end
        return
    end
    task.spawn(function()
        local ok, result = pcall(function()
            local url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=zh-CN&dt=t&q=" .. HttpService:UrlEncode(name)
            local response = game:HttpGet(url)
            local decoded = HttpService:JSONDecode(response)
            return decoded[1][1][1]
        end)
        if ok and result and result ~= "" then
            translatedTexts[name] = result
            if callback then callback(result) end
        else
            translatedTexts[name] = name
            if callback then callback(name) end
        end
    end)
end

local function makeHighlight(parent, color)
    local hl = parent:FindFirstChild("KB_ESP")
    if hl then return hl end
    hl = Instance.new("Highlight")
    hl.Name = "KB_ESP"
    hl.FillColor = color
    hl.OutlineColor = color
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = parent
    return hl
end

local function makeBillboard(parent, text, color)
    local bg = parent:FindFirstChild("KB_Billboard")
    if bg then
        local tl = bg:FindFirstChild("KB_Text")
        if tl then tl.Text = text end
        return bg
    end
    bg = Instance.new("BillboardGui")
    bg.Name = "KB_Billboard"
    bg.Size = UDim2.new(0, 200, 0, 50)
    bg.StudsOffset = Vector3.new(0, 3, 0)
    bg.AlwaysOnTop = true
    bg.Parent = parent
    local tl = Instance.new("TextLabel")
    tl.Name = "KB_Text"
    tl.Size = UDim2.new(1, 0, 1, 0)
    tl.BackgroundTransparency = 1
    tl.TextColor3 = color
    tl.TextStrokeTransparency = 0
    tl.TextStrokeColor3 = Color3.new(0, 0, 0)
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 14
    tl.Text = text
    tl.Parent = bg
    return bg
end

local function updateBillboard(obj, color, prefix)
    local name = obj.Name
    local cached = translatedTexts[name]
    local display = cached or name
    if prefix then display = prefix end
    local dist = math.floor(distTo(obj:GetPivot().Position))
    local text = display .. "\n距离: " .. dist .. "m"
    makeBillboard(obj, text, color)
    if not cached then
        translateName(obj, function(zhName)
            local newDist = math.floor(distTo(obj:GetPivot().Position))
            local newDisplay = zhName
            if prefix then newDisplay = prefix end
            local newText = newDisplay .. "\n距离: " .. newDist .. "m"
            makeBillboard(obj, newText, color)
        end)
    end
end

local function espFolder(folderName, color, forcePrefix)
    local folder = Workspace:FindFirstChild(folderName)
    if not folder then return end
    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("Model") then
            makeHighlight(obj, color)
            updateBillboard(obj, color, forcePrefix)
        end
    end
end

local function clearFolderESP(folderName)
    local folder = Workspace:FindFirstChild(folderName)
    if not folder then return end
    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("Model") then
            if obj:FindFirstChild("KB_ESP") then obj.KB_ESP:Destroy() end
            if obj:FindFirstChild("KB_Billboard") then obj.KB_Billboard:Destroy() end
        end
    end
end

local function equipAxe()
    local char = getChar()
    if not char then return end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:find("Axe") or tool.Name:find("axe") or tool.Name:find("Pickaxe")) then
            return
        end
    end
    local backpack = player:FindFirstChild("Backpack")
    if not backpack then return end
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:find("Axe") or tool.Name:find("axe") or tool.Name:find("Pickaxe")) then
            tool.Parent = char
            return
        end
    end
end

local function doSwingAxe(targetPos)
    local remotes = ReplicatedStorage:FindFirstChild("remotes")
    if not remotes then return end
    local remote = remotes:FindFirstChild("swing_axe")
    if not remote then return end
    equipAxe()
    local args = {[1] = targetPos}
    remote:FireServer(unpack(args))
end

local function doTreeAura()
    local treesFolder = Workspace:FindFirstChild("trees")
    if not treesFolder then return end
    local maxDist = (Options.TreeAuraDist and Options.TreeAuraDist.Value) or 50
    local trees = {}
    for _, tree in ipairs(treesFolder:GetDescendants()) do
        if tree:IsA("Model") then
            local tPos = tree:GetPivot().Position
            local d = distTo(tPos)
            if d <= maxDist then
                table.insert(trees, {tree = tree, pos = tPos, dist = d})
            end
        end
    end
    table.sort(trees, function(a, b) return a.dist < b.dist end)
    for _, data in ipairs(trees) do
        task.spawn(function()
            for i = 1, 20 do
                if not data.tree.Parent then break end
                doSwingAxe(data.pos)
                if FakeBody and FakeBody.Parent then
                    pcall(function()
                        FakeBody:PivotTo(data.tree:GetPivot())
                    end)
                end
                task.wait(0.03)
            end
        end)
    end
end

local function doSingleTree()
    local treesFolder = Workspace:FindFirstChild("trees")
    if not treesFolder then return end
    local nearest = nil
    local nearDist = math.huge
    for _, tree in ipairs(treesFolder:GetDescendants()) do
        if tree:IsA("Model") then
            local tPos = tree:GetPivot().Position
            local d = distTo(tPos)
            if d < nearDist then
                nearDist = d
                nearest = tree
            end
        end
    end
    if nearest then
        doSwingAxe(nearest:GetPivot().Position)
        if FakeBody and FakeBody.Parent then
            pcall(function()
                FakeBody:PivotTo(nearest:GetPivot())
            end)
        end
    end
end

local function doKillAura()
    local remotes = ReplicatedStorage:FindFirstChild("remotes")
    if not remotes then return end
    local remote = remotes:FindFirstChild("shoot")
    if not remote then return end
    local maxDist = (Options.KillAuraDist and Options.KillAuraDist.Value) or 50
    local targets = {}
    local enemiesFolder = Workspace:FindFirstChild("enemies")
    local animalsFolder = Workspace:FindFirstChild("animals")
    if enemiesFolder then
        for _, obj in ipairs(enemiesFolder:GetDescendants()) do
            if obj:IsA("Model") then
                local head = obj:FindFirstChild("Head")
                local pos = head and head.Position or obj:GetPivot().Position
                local d = distTo(pos)
                if d <= maxDist then
                    table.insert(targets, {obj = obj, pos = pos, dist = d})
                end
            end
        end
    end
    if animalsFolder then
        for _, obj in ipairs(animalsFolder:GetDescendants()) do
            if obj:IsA("Model") then
                local head = obj:FindFirstChild("Head")
                local pos = head and head.Position or obj:GetPivot().Position
                local d = distTo(pos)
                if d <= maxDist then
                    table.insert(targets, {obj = obj, pos = pos, dist = d})
                end
            end
        end
    end
    table.sort(targets, function(a, b) return a.dist < b.dist end)
    local root = getRoot()
    if not root then return end
    if Toggles.KillAuraNearest and Toggles.KillAuraNearest.Value then
        if #targets > 0 then
            local t = targets[1]
            local args = {
                [1] = root.CFrame,
                [2] = CFrame.new(t.pos)
            }
            remote:FireServer(unpack(args))
        end
    else
        for _, t in ipairs(targets) do
            local args = {
                [1] = root.CFrame,
                [2] = CFrame.new(t.pos)
            }
            remote:FireServer(unpack(args))
        end
    end
end

local function doAutoInteract()
    local maxDist = (Options.InteractDist and Options.InteractDist.Value) or 50
    local scanRoot = Workspace:FindFirstChild("Runtime")
    if scanRoot then
        scanRoot = scanRoot:FindFirstChild("LootPoints") or scanRoot
    else
        scanRoot = Workspace
    end
    for _, obj in ipairs(scanRoot:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            if parent and parent:IsA("BasePart") then
                if distTo(parent.Position) <= maxDist then
                    pcall(function()
                        fireproximityprompt(obj)
                    end)
                end
            end
        end
    end
end

local function doInteractOnce()
    local maxDist = (Options.InteractDist and Options.InteractDist.Value) or 50
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            if parent and parent:IsA("BasePart") then
                if distTo(parent.Position) <= maxDist then
                    task.spawn(function()
                        pcall(function()
                            if obj.HoldDuration > 0 then
                                obj:InputHoldBegin()
                                task.wait(obj.HoldDuration + 0.1)
                                obj:InputHoldEnd()
                            else
                                fireproximityprompt(obj)
                            end
                        end)
                    end)
                end
            end
        end
    end
    Library:Notify({Title = "完成", Description = "全图交互已执行", Time = 3})
end

local function doAutoScrap()
    local scrapFolder = Workspace:FindFirstChild("scrap")
    if not scrapFolder then return end
    local scraps = {}
    for _, obj in ipairs(scrapFolder:GetChildren()) do
        if obj:IsA("Model") then
            table.insert(scraps, obj)
        end
    end
    if #scraps == 0 then return end
    table.sort(scraps, function(a, b)
        return distTo(a:GetPivot().Position) < distTo(b:GetPivot().Position)
    end)
    for _, scrap in ipairs(scraps) do
        if not Toggles.AutoScrap or not Toggles.AutoScrap.Value then return end
        if not scrap.Parent then continue end
        local root = getRoot()
        if not root then return end
        local sPos = scrap:GetPivot().Position
        root.CFrame = CFrame.lookAt(sPos + Vector3.new(0, 3, 0), sPos)
        task.wait(0.3)
        local prompt = nil
        for _, desc in ipairs(scrap:GetDescendants()) do
            if desc:IsA("ProximityPrompt") then
                prompt = desc
                break
            end
        end
        if prompt then
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration + 0.5)
            prompt:InputHoldEnd()
            task.wait(5)
            if scrap.Parent then
                prompt:InputHoldBegin()
                task.wait(prompt.HoldDuration + 0.5)
                prompt:InputHoldEnd()
                task.wait(2)
            end
        end
    end
end

local function applyHitbox(scale)
    local enemiesFolder = Workspace:FindFirstChild("enemies")
    if not enemiesFolder then return end
    for _, enemy in ipairs(enemiesFolder:GetDescendants()) do
        if enemy:IsA("Model") then
            local head = enemy:FindFirstChild("Head")
            if head and head:IsA("BasePart") then
                local tag = head:FindFirstChild("KB_OrigSize")
                if not tag then
                    tag = Instance.new("Vector3Value")
                    tag.Name = "KB_OrigSize"
                    tag.Value = head.Size
                    tag.Parent = head
                end
                local vis = head:FindFirstChild("KB_HitboxVis")
                if not vis then
                    vis = Instance.new("BoxHandleAdornment")
                    vis.Name = "KB_HitboxVis"
                    vis.Color3 = Color3.fromRGB(255, 0, 0)
                    vis.Transparency = 0.3
                    vis.AlwaysOnTop = true
                    vis.Adornee = head
                    vis.Parent = head
                end
                if scale > 0 then
                    head.Size = tag.Value * scale
                    vis.Size = head.Size
                    vis.Visible = true
                else
                    head.Size = tag.Value
                    vis.Visible = false
                end
            end
        end
    end
end

local function restoreHitboxes()
    local enemiesFolder = Workspace:FindFirstChild("enemies")
    if not enemiesFolder then return end
    for _, enemy in ipairs(enemiesFolder:GetDescendants()) do
        if enemy:IsA("Model") then
            local head = enemy:FindFirstChild("Head")
            if head and head:IsA("BasePart") then
                local tag = head:FindFirstChild("KB_OrigSize")
                if tag then
                    head.Size = tag.Value
                    tag:Destroy()
                end
                local vis = head:FindFirstChild("KB_HitboxVis")
                if vis then
                    vis:Destroy()
                end
            end
        end
    end
end

local function createFakeBody()
    if FakeBody and FakeBody.Parent then
        FakeBody:Destroy()
    end
    local char = getChar()
    if not char then return end
    local clone = char:Clone()
    if not clone then return end
    clone.Name = "KB_FakeBody"
    for _, obj in ipairs(clone:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CanCollide = false
            obj.Anchored = true
        end
        if obj:IsA("Humanoid") then
            obj:Destroy()
        end
        if obj:IsA("Script") or obj:IsA("LocalScript") then
            obj:Destroy()
        end
    end
    clone.Parent = Workspace
    FakeBody = clone
end

local function removeFakeBody()
    if FakeBody and FakeBody.Parent then
        FakeBody:Destroy()
    end
    FakeBody = nil
end

local function applyInfiniteAmmo()
    local char = getChar()
    if not char then return end
    local function modTool(tool)
        if not tool or not tool:IsA("Tool") then return end
        local ammo = tool:FindFirstChild("ammo")
        if ammo and ammo:IsA("NumberValue") then
            ammo.Value = 999
        end
        local mag = tool:FindFirstChild("mag")
        if mag and mag:IsA("NumberValue") then
            local magSize = tool:FindFirstChild("mag_size")
            if magSize and magSize:IsA("NumberValue") then
                mag.Value = magSize.Value
            else
                mag.Value = 999
            end
        end
    end
    for _, obj in ipairs(char:GetChildren()) do
        modTool(obj)
    end
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, obj in ipairs(backpack:GetChildren()) do
            modTool(obj)
        end
    end
end

local function applyInfiniteFireRate()
    local char = getChar()
    if not char then return end
    local function modTool(tool)
        if not tool or not tool:IsA("Tool") then return end
        local delayVal = tool:FindFirstChild("delay")
        if delayVal and delayVal:IsA("NumberValue") then
            delayVal.Value = 0
        end
        local recoilVal = tool:FindFirstChild("recoil")
        if recoilVal and recoilVal:IsA("NumberValue") then
            recoilVal.Value = 0
        end
        local spreadVal = tool:FindFirstChild("spread")
        if spreadVal and spreadVal:IsA("NumberValue") then
            spreadVal.Value = 0
        end
    end
    for _, obj in ipairs(char:GetChildren()) do
        modTool(obj)
    end
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, obj in ipairs(backpack:GetChildren()) do
            modTool(obj)
        end
    end
end

local function showHomeMarker()
    if HomeMarker and HomeMarker.Parent then
        HomeMarker:Destroy()
    end
    local part = Instance.new("Part")
    part.Name = "KB_HomeMarker"
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Size = Vector3.new(1, 1, 1)
    part.Position = Vector3.new(4506.6, 37.8, 4500.3)
    part.Parent = Workspace
    local bg = Instance.new("BillboardGui")
    bg.Name = "KB_HomeBillboard"
    bg.Size = UDim2.new(0, 200, 0, 50)
    bg.StudsOffset = Vector3.new(0, 3, 0)
    bg.AlwaysOnTop = true
    bg.Parent = part
    local tl = Instance.new("TextLabel")
    tl.Name = "KB_HomeText"
    tl.Size = UDim2.new(1, 0, 1, 0)
    tl.BackgroundTransparency = 1
    tl.TextColor3 = Color3.fromRGB(0, 255, 0)
    tl.TextStrokeTransparency = 0
    tl.TextStrokeColor3 = Color3.new(0, 0, 0)
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 18
    tl.Text = "家"
    tl.Parent = bg
    HomeMarker = part
end

local function hideHomeMarker()
    if HomeMarker and HomeMarker.Parent then
        HomeMarker:Destroy()
    end
    HomeMarker = nil
end

local function getNearestInFolder(folderName)
    local folder = Workspace:FindFirstChild(folderName)
    if not folder then return nil end
    local nearest = nil
    local nearDist = math.huge
    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("Model") then
            local pos = obj:GetPivot().Position
            local d = distTo(pos)
            if d < nearDist then
                nearDist = d
                nearest = obj
            end
        end
    end
    return nearest
end

local function doAutoChop()
    local treesFolder = Workspace:FindFirstChild("trees")
    if not treesFolder then return end
    while Toggles.AutoChop and Toggles.AutoChop.Value do
        local trees = {}
        for _, tree in ipairs(treesFolder:GetDescendants()) do
            if tree:IsA("Model") then
                table.insert(trees, tree)
            end
        end
        if #trees == 0 then
            task.wait(1)
            continue
        end
        table.sort(trees, function(a, b)
            return distTo(a:GetPivot().Position) < distTo(b:GetPivot().Position)
        end)
        local targetTree = trees[1]
        if not targetTree or not targetTree.Parent then
            task.wait(1)
            continue
        end
        local root = getRoot()
        if not root then
            task.wait(0.5)
            continue
        end
        local tPos = targetTree:GetPivot().Position
        root.CFrame = CFrame.new(tPos + Vector3.new(0, 0, 3))
        task.wait(0.3)
        local startTime = tick()
        while Toggles.AutoChop and Toggles.AutoChop.Value and targetTree and targetTree.Parent do
            doSwingAxe(tPos)
            if FakeBody and FakeBody.Parent then
                pcall(function()
                    FakeBody:PivotTo(targetTree:GetPivot())
                end)
            end
            task.wait(0.1)
            if tick() - startTime > 10 then
                break
            end
        end
        task.wait(0.5)
    end
end

local LeftGroup = Tabs.Main:AddLeftGroupbox("透视")

LeftGroup:AddToggle("ESPAnimals", {Text = "透视动物", Default = false}):OnChanged(function()
    if not Toggles.ESPAnimals.Value then
        clearFolderESP("animals")
    end
end)

LeftGroup:AddToggle("ESPEnemies", {Text = "透视怪物", Default = false}):OnChanged(function()
    if not Toggles.ESPEnemies.Value then
        clearFolderESP("enemies")
    end
end)

LeftGroup:AddToggle("ESPTrees", {Text = "透视树木", Default = false}):OnChanged(function()
    if not Toggles.ESPTrees.Value then
        clearFolderESP("trees")
    end
end)

LeftGroup:AddToggle("ESPMinerals", {Text = "透视矿物", Default = false}):OnChanged(function()
    if not Toggles.ESPMinerals.Value then
        clearFolderESP("minerals")
    end
end)

LeftGroup:AddToggle("ESPHarvest", {Text = "透视作物", Default = false}):OnChanged(function()
    if not Toggles.ESPHarvest.Value then
        clearFolderESP("harvest")
    end
end)

LeftGroup:AddToggle("ESPScrap", {Text = "透视废铁", Default = false}):OnChanged(function()
    if not Toggles.ESPScrap.Value then
        clearFolderESP("scrap")
    end
end)

local LeftGroup2 = Tabs.Main:AddLeftGroupbox("获取物品")

LeftGroup2:AddButton("获取M4A1", function()
    local peter = Workspace:FindFirstChild("enemies") and Workspace.enemies:FindFirstChild("agent_peter")
    if peter then
        local gun = peter:FindFirstChild("M4A1")
        if gun and gun:IsA("Tool") then
            local clone = gun:Clone()
            clone.Parent = player.Backpack
            Library:Notify({Title = "成功", Description = "已获取M4A1", Time = 3})
        else
            Library:Notify({Title = "失败", Description = "未找到M4A1", Time = 3})
        end
    else
        Library:Notify({Title = "失败", Description = "未找到agent_peter", Time = 3})
    end
end)

LeftGroup2:AddButton("获取火箭靴左", function()
    local boot = Workspace:FindFirstChild("interact") and Workspace.interact:FindFirstChild("Left Rocket Boot Pickup")
    if boot then
        local clone = boot:Clone()
        clone.Parent = player.Backpack
        Library:Notify({Title = "成功", Description = "已获取左火箭靴", Time = 3})
    else
        Library:Notify({Title = "失败", Description = "未找到左火箭靴", Time = 3})
    end
end)

LeftGroup2:AddButton("获取火箭靴右", function()
    local boot = Workspace:FindFirstChild("interact") and Workspace.interact:FindFirstChild("Right Rocket Boot Pickup")
    if boot then
        local clone = boot:Clone()
        clone.Parent = player.Backpack
        Library:Notify({Title = "成功", Description = "已获取右火箭靴", Time = 3})
    else
        Library:Notify({Title = "失败", Description = "未找到右火箭靴", Time = 3})
    end
end)

LeftGroup2:AddButton("获取手电筒", function()
    local found = false
    local interact = Workspace:FindFirstChild("interact")
    if interact then
        for _, obj in ipairs(interact:GetChildren()) do
            if obj.Name == "flashlight" and obj:IsA("Model") then
                local clone = obj:Clone()
                clone.Parent = player.Backpack
                found = true
                break
            end
        end
    end
    if found then
        Library:Notify({Title = "成功", Description = "已获取手电筒", Time = 3})
    else
        Library:Notify({Title = "失败", Description = "未找到手电筒", Time = 3})
    end
end)

local LeftGroup3 = Tabs.Main:AddLeftGroupbox("传送类")

LeftGroup3:AddToggle("ShowHome", {Text = "显示家在哪", Default = false}):OnChanged(function()
    if Toggles.ShowHome.Value then
        showHomeMarker()
    else
        hideHomeMarker()
    end
end)

LeftGroup3:AddButton("一键回家", function()
    local root = getRoot()
    if root then
        root.CFrame = CFrame.new(4506.6, 37.8, 4500.3)
        Library:Notify({Title = "成功", Description = "已传送到家", Time = 3})
    else
        Library:Notify({Title = "失败", Description = "未找到人物根部件", Time = 3})
    end
end)

LeftGroup3:AddButton("传送到最近的动物", function()
    local target = getNearestInFolder("animals")
    if target then
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(target:GetPivot().Position + Vector3.new(0, 3, 0))
            Library:Notify({Title = "成功", Description = "已传送到最近的动物", Time = 3})
        end
    else
        Library:Notify({Title = "失败", Description = "未找到动物", Time = 3})
    end
end)

LeftGroup3:AddButton("传送到最近的怪物", function()
    local target = getNearestInFolder("enemies")
    if target then
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(target:GetPivot().Position + Vector3.new(0, 3, 0))
            Library:Notify({Title = "成功", Description = "已传送到最近的怪物", Time = 3})
        end
    else
        Library:Notify({Title = "失败", Description = "未找到怪物", Time = 3})
    end
end)

LeftGroup3:AddButton("传送到最近的废料", function()
    local target = getNearestInFolder("scrap")
    if target then
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(target:GetPivot().Position + Vector3.new(0, 3, 0))
            Library:Notify({Title = "成功", Description = "已传送到最近的废料", Time = 3})
        end
    else
        Library:Notify({Title = "失败", Description = "未找到废料", Time = 3})
    end
end)

LeftGroup3:AddButton("传送到最近的矿物", function()
    local target = getNearestInFolder("minerals")
    if target then
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(target:GetPivot().Position + Vector3.new(0, 3, 0))
            Library:Notify({Title = "成功", Description = "已传送到最近的矿物", Time = 3})
        end
    else
        Library:Notify({Title = "失败", Description = "未找到矿物", Time = 3})
    end
end)

LeftGroup3:AddButton("传送到最近的树木", function()
    local target = getNearestInFolder("trees")
    if target then
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(target:GetPivot().Position + Vector3.new(0, 3, 0))
            Library:Notify({Title = "成功", Description = "已传送到最近的树木", Time = 3})
        end
    else
        Library:Notify({Title = "失败", Description = "未找到树木", Time = 3})
    end
end)

local RightGroup = Tabs.Main:AddRightGroupbox("砍树功能")

RightGroup:AddToggle("TreeAura", {Text = "树木光环", Default = false}):OnChanged(function()
    if Toggles.TreeAura.Value then
        createFakeBody()
        if typeof(TreeAuraLoop) == "RBXScriptConnection" then
            pcall(function() TreeAuraLoop:Disconnect() end)
        end
        TreeAuraLoop = nil
        if Toggles.TreeAuraFrameMode and Toggles.TreeAuraFrameMode.Value then
            TreeAuraLoop = RunService.Heartbeat:Connect(function()
                if Toggles.TreeAura.Value then doTreeAura() end
            end)
        else
            TreeAuraLoop = task.spawn(function()
                while Toggles.TreeAura.Value do
                    doTreeAura()
                    local freq = (Options.TreeAuraFreq and Options.TreeAuraFreq.Value) or 0.5
                    task.wait(freq)
                end
            end)
        end
    else
        if typeof(TreeAuraLoop) == "RBXScriptConnection" then
            pcall(function() TreeAuraLoop:Disconnect() end)
        end
        TreeAuraLoop = nil
        if not (Toggles.TreeAura and Toggles.TreeAura.Value) and not (Toggles.SingleTree and Toggles.SingleTree.Value) and not (Toggles.AutoChop and Toggles.AutoChop.Value) then
            removeFakeBody()
        end
    end
end)

RightGroup:AddSlider("TreeAuraDist", {Text = "光环距离", Default = 50, Min = 0, Max = 1000, Rounding = 0, Suffix = "m"})
RightGroup:AddSlider("TreeAuraFreq", {Text = "发送频率", Default = 0.5, Min = 0.05, Max = 5, Rounding = 2, Suffix = "s"})
RightGroup:AddLabel("如果你开的太快会影响正常砍树")
RightGroup:AddToggle("TreeAuraFrameMode", {Text = "每帧执行模式", Default = false}):OnChanged(function()
    if Toggles.TreeAura.Value then
        if typeof(TreeAuraLoop) == "RBXScriptConnection" then
            pcall(function() TreeAuraLoop:Disconnect() end)
        end
        TreeAuraLoop = nil
        if Toggles.TreeAuraFrameMode.Value then
            TreeAuraLoop = RunService.Heartbeat:Connect(function()
                if Toggles.TreeAura.Value then doTreeAura() end
            end)
        else
            TreeAuraLoop = task.spawn(function()
                while Toggles.TreeAura.Value do
                    doTreeAura()
                    local freq = (Options.TreeAuraFreq and Options.TreeAuraFreq.Value) or 0.5
                    task.wait(freq)
                end
            end)
        end
    end
end)
RightGroup:AddToggle("FakeBody", {Text = "绕过砍树距离检测（可能不需要开就能砍）", Default = false})
RightGroup:AddLabel("必须装备斧头，距离开越大砍的越慢")

RightGroup:AddToggle("SingleTree", {Text = "针对一个树模式（这样子砍的快）", Default = false}):OnChanged(function()
    if Toggles.SingleTree.Value then
        createFakeBody()
        if SingleTreeLoop then SingleTreeLoop = nil end
        SingleTreeLoop = task.spawn(function()
            while Toggles.SingleTree.Value do
                doSingleTree()
                task.wait(0.1)
            end
        end)
    else
        SingleTreeLoop = nil
        if not (Toggles.TreeAura and Toggles.TreeAura.Value) and not (Toggles.AutoChop and Toggles.AutoChop.Value) then
            removeFakeBody()
        end
    end
end)

RightGroup:AddToggle("AutoChop", {Text = "全自动砍树", Default = false}):OnChanged(function()
    if Toggles.AutoChop.Value then
        createFakeBody()
        if AutoChopLoop then AutoChopLoop = nil end
        AutoChopLoop = task.spawn(function()
            doAutoChop()
        end)
    else
        AutoChopLoop = nil
        if not (Toggles.TreeAura and Toggles.TreeAura.Value) and not (Toggles.SingleTree and Toggles.SingleTree.Value) then
            removeFakeBody()
        end
    end
end)

local RightGroup2 = Tabs.Main:AddRightGroupbox("功能")

RightGroup2:AddToggle("AutoInteract", {Text = "自动交互", Default = false}):OnChanged(function()
    if Toggles.AutoInteract.Value then
        if AutoInteractConn then AutoInteractConn:Disconnect() end
        AutoInteractConn = RunService.Heartbeat:Connect(function()
            if Toggles.AutoInteract.Value then
                doAutoInteract()
            end
        end)
    else
        if AutoInteractConn then
            AutoInteractConn:Disconnect()
            AutoInteractConn = nil
        end
    end
end)

RightGroup2:AddSlider("InteractDist", {Text = "交互距离", Default = 50, Min = 0, Max = 1000, Rounding = 0, Suffix = "m"})

RightGroup2:AddButton("全图交互一次", function()
    doInteractOnce()
end)

RightGroup2:AddToggle("AutoScrap", {Text = "自动收集废料", Default = false}):OnChanged(function()
    if Toggles.AutoScrap.Value then
        if AutoScrapLoop then AutoScrapLoop = nil end
        AutoScrapLoop = task.spawn(function()
            while Toggles.AutoScrap.Value do
                doAutoScrap()
                task.wait(1)
            end
        end)
    else
        AutoScrapLoop = nil
    end
end)

RightGroup2:AddButton("加载飞行", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/kongbaNB/9178/refs/heads/main/fly.lua"))()
    Library:Notify({Title = "成功", Description = "飞行脚本已加载", Time = 3})
end)

RightGroup2:AddToggle("NightVision", {Text = "夜视", Default = false}):OnChanged(function()
    if Toggles.NightVision.Value then
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end
end)

RightGroup2:AddToggle("NoFall", {Text = "无摔落", Default = false}):OnChanged(function()
    if Toggles.NoFall.Value then
        if FallConn then FallConn:Disconnect() end
        FallConn = RunService.Heartbeat:Connect(function()
            local char = getChar()
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.StateChanged:Connect(function(_, newState)
                        if newState == Enum.HumanoidStateType.FallingDown or newState == Enum.HumanoidStateType.Ragdoll then
                            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                        end
                    end)
                end
            end
        end)
    else
        if FallConn then
            FallConn:Disconnect()
            FallConn = nil
        end
    end
end)

local RightGroup3 = Tabs.Main:AddRightGroupbox("枪械")

RightGroup3:AddToggle("KillAura", {Text = "杀戮光环", Default = false}):OnChanged(function()
    if Toggles.KillAura.Value then
        if KillAuraLoop then KillAuraLoop = nil end
        if Toggles.KillAuraFrameMode and Toggles.KillAuraFrameMode.Value then
            KillAuraLoop = RunService.Heartbeat:Connect(function()
                if Toggles.KillAura.Value then doKillAura() end
            end)
        else
            KillAuraLoop = task.spawn(function()
                while Toggles.KillAura.Value do
                    doKillAura()
                    local freq = (Options.KillAuraFreq and Options.KillAuraFreq.Value) or 0.5
                    task.wait(freq)
                end
            end)
        end
    else
        if typeof(KillAuraLoop) == "RBXScriptConnection" then
            pcall(function() KillAuraLoop:Disconnect() end)
        end
        KillAuraLoop = nil
    end
end)

RightGroup3:AddToggle("KillAuraNearest", {Text = "只打最近的", Default = false})
RightGroup3:AddLabel("开启之后可能会导致攻击无法生效")

RightGroup3:AddSlider("KillAuraDist", {Text = "杀戮距离", Default = 50, Min = 0, Max = 1000, Rounding = 0, Suffix = "m"})
RightGroup3:AddSlider("KillAuraFreq", {Text = "射击频率", Default = 0.5, Min = 0.05, Max = 5, Rounding = 2, Suffix = "s"})
RightGroup3:AddLabel("如果你开的太快会影响正常伤害")
RightGroup3:AddToggle("KillAuraFrameMode", {Text = "每帧执行模式", Default = false}):OnChanged(function()
    if Toggles.KillAura.Value then
        if typeof(KillAuraLoop) == "RBXScriptConnection" then
            pcall(function() KillAuraLoop:Disconnect() end)
        end
        KillAuraLoop = nil
        if Toggles.KillAuraFrameMode.Value then
            KillAuraLoop = RunService.Heartbeat:Connect(function()
                if Toggles.KillAura.Value then doKillAura() end
            end)
        else
            KillAuraLoop = task.spawn(function()
                while Toggles.KillAura.Value do
                    doKillAura()
                    local freq = (Options.KillAuraFreq and Options.KillAuraFreq.Value) or 0.5
                    task.wait(freq)
                end
            end)
        end
    end
end)

RightGroup3:AddToggle("InfiniteAmmo", {Text = "无限子弹", Default = false})

RightGroup3:AddToggle("InfiniteFireRate", {Text = "无限射速", Default = false})

local RightGroup4 = Tabs.Main:AddRightGroupbox("碰撞箱")

RightGroup4:AddSlider("HitboxScale", {Text = "碰撞箱倍数", Default = 1, Min = 0, Max = 100, Rounding = 1})
RightGroup4:AddToggle("ExpandHitbox", {Text = "扩大怪物碰撞箱", Default = false}):OnChanged(function()
    if Toggles.ExpandHitbox.Value then
        local scale = Options.HitboxScale and Options.HitboxScale.Value or 1
        applyHitbox(scale)
    else
        restoreHitboxes()
    end
end)

RunService.Heartbeat:Connect(function()
    if Toggles.ESPAnimals and Toggles.ESPAnimals.Value then
        espFolder("animals", Color3.fromRGB(0, 255, 0))
    end
    if Toggles.ESPEnemies and Toggles.ESPEnemies.Value then
        espFolder("enemies", Color3.fromRGB(255, 0, 0))
    end
    if Toggles.ESPTrees and Toggles.ESPTrees.Value then
        espFolder("trees", Color3.fromRGB(139, 69, 19), "树木")
    end
    if Toggles.ESPMinerals and Toggles.ESPMinerals.Value then
        espFolder("minerals", Color3.fromRGB(128, 128, 128))
    end
    if Toggles.ESPHarvest and Toggles.ESPHarvest.Value then
        espFolder("harvest", Color3.fromRGB(255, 215, 0))
    end
    if Toggles.ESPScrap and Toggles.ESPScrap.Value then
        espFolder("scrap", Color3.fromRGB(192, 192, 192))
    end
    if Toggles.ExpandHitbox and Toggles.ExpandHitbox.Value then
        local scale = Options.HitboxScale and Options.HitboxScale.Value or 1
        applyHitbox(scale)
    end
    if Toggles.InfiniteAmmo and Toggles.InfiniteAmmo.Value then
        applyInfiniteAmmo()
    end
    if Toggles.InfiniteFireRate and Toggles.InfiniteFireRate.Value then
        applyInfiniteFireRate()
    end
end)

player.CharacterAdded:Connect(function()
    if Toggles.NoFall and Toggles.NoFall.Value then
        task.wait(1)
        local hum = getChar() and getChar():FindFirstChildOfClass("Humanoid")
        if hum then
            hum.StateChanged:Connect(function(_, newState)
                if newState == Enum.HumanoidStateType.FallingDown or newState == Enum.HumanoidStateType.Ragdoll then
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end)
        end
    end
end)
