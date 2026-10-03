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
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Camera = Workspace.CurrentCamera
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local Window = Library:CreateWindow({
    Title = "极速传奇",
    Footer = "Aiove 制作",
    Icon = 131153193945220,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

Library:Notify({
    Title = "极速传奇",
    Description = "创作者：Aiove\nQQ：3999698324\n极速传奇已加载成功",
    Time = 5,
})

local Tabs = {
    Notice = Window:AddTab("通知", "info"),
    Main = Window:AddTab("主要", "info"),
    Farm = Window:AddTab("刷取", "info"),
    Pet = Window:AddTab("宠物", "info"),
    Teleport = Window:AddTab("传送", "info"),
    Settings = Window:AddTab("设置", "settings"),
}

local NoticeGroup = Tabs.Notice:AddLeftGroupbox("作者消息")
NoticeGroup:AddLabel('Aiove将持续更新此脚本')
NoticeGroup:AddLabel('创作者：Aiove')

getgenv().CollectAllChests = getgenv().CollectAllChests or false
getgenv().UnlockAllPasses = getgenv().UnlockAllPasses or false
getgenv().SuckHoops = getgenv().SuckHoops or false
getgenv().AutoRace = getgenv().AutoRace or false
getgenv().AutoRaceWin = getgenv().AutoRaceWin or false
getgenv().AutoRebirth1 = getgenv().AutoRebirth1 or false
getgenv().AutoRebirth2 = getgenv().AutoRebirth2 or false
getgenv().TargetRebirths = getgenv().TargetRebirths or 0
getgenv().FlyEnabled = getgenv().FlyEnabled or false
getgenv().NoclipEnabled = getgenv().NoclipEnabled or false
getgenv().NoFog = getgenv().NoFog or false
getgenv().NightVision = getgenv().NightVision or false
getgenv().AutoEvolve = getgenv().AutoEvolve or false
getgenv().AutoBuyPet = getgenv().AutoBuyPet or false
getgenv().SelectedPet = getgenv().SelectedPet or ""
getgenv().SelectedMap = getgenv().SelectedMap or ""
getgenv().PetFarmPurple = getgenv().PetFarmPurple or false
getgenv().PetFarmRed = getgenv().PetFarmRed or false
getgenv().PetFarmBlue = getgenv().PetFarmBlue or false
getgenv().PetFarmOrange = getgenv().PetFarmOrange or false
getgenv().PetFarmYellow = getgenv().PetFarmYellow or false
getgenv().PetFarmMode2 = getgenv().PetFarmMode2 or false
getgenv().Gem_City = getgenv().Gem_City or false
getgenv().Gem_SnowCity = getgenv().Gem_SnowCity or false
getgenv().Gem_MagmaCity = getgenv().Gem_MagmaCity or false
getgenv().Gem_LegendsHighway = getgenv().Gem_LegendsHighway or false
getgenv().Gem_SpeedJungle = getgenv().Gem_SpeedJungle or false

getgenv().AutoXP = getgenv().AutoXP or false
getgenv().AutoSpeedCity = getgenv().AutoSpeedCity or false
getgenv().AutoSpeedSnow = getgenv().AutoSpeedSnow or false
getgenv().AutoSpeedMagma = getgenv().AutoSpeedMagma or false
getgenv().AutoSpeedHighway = getgenv().AutoSpeedHighway or false
getgenv().AutoGemCity = getgenv().AutoGemCity or false
getgenv().AutoGemSnow = getgenv().AutoGemSnow or false
getgenv().AutoGemMagma = getgenv().AutoGemMagma or false
getgenv().AutoGemHighway = getgenv().AutoGemHighway or false
getgenv().AutoLoopTeleport = getgenv().AutoLoopTeleport or false
getgenv().AutoSpeedV2 = getgenv().AutoSpeedV2 or false
getgenv().AutoBuyPetCrystal = getgenv().AutoBuyPetCrystal or false
getgenv().AutoBuyTrail = getgenv().AutoBuyTrail or false

getgenv().chestThread = nil
getgenv().passThread = nil
getgenv().hoopThread = nil
getgenv().raceThread = nil
getgenv().raceWinThread = nil
getgenv().rebirth1Thread = nil
getgenv().rebirth2Thread = nil
getgenv().evolveThread = nil
getgenv().buyPetThread = nil
getgenv().flyThread = nil
getgenv().noclipThread = nil

getgenv().xpThread = nil
getgenv().speedCityThread = nil
getgenv().speedSnowThread = nil
getgenv().speedMagmaThread = nil
getgenv().speedHighwayThread = nil
getgenv().gemCityThread = nil
getgenv().gemSnowThread = nil
getgenv().gemMagmaThread = nil
getgenv().gemHighwayThread = nil
getgenv().loopTeleportThread = nil
getgenv().speedV2Thread = nil
getgenv().buyPetCrystalThread = nil
getgenv().buyTrailThread = nil

local PetFarmState = {
    area = "City",
    orbType = "Yellow Orb",
    multiplier = 1,
    isMaxLevel = false
}

local areaOptions = {"City", "Snow City", "Magma City", "Desert", "Space", "Legends Highway", "Speed Jungle"}
local areaDisplayNames = {"城市", "雪城", "熔岩城", "沙漠", "太空", "传奇公路", "丛林"}

local orbOptions = {"Ethereal Orb", "Red Orb", "Blue Orb", "Orange Orb", "Yellow Orb"}
local orbDisplayNames = {"紫球", "红球", "蓝球", "橙球", "经验球"}

local petOptions = {"Swift Samurai", "Hyperblast", "Flaming Hedgehog", "Rainbow Steps", "Electro Golem"}
local petDisplayNames = {"斯威夫特武士", "金色尾巴", "火焰刺猬", "彩虹尾巴", "电光雷宠"}

local gemAreas = {
    City = "City",
    SnowCity = "Snow City",
    MagmaCity = "Magma City",
    LegendsHighway = "Legends Highway",
    SpeedJungle = "Speed Jungle"
}

local function getCharacter()
    return Player.Character or Player.CharacterAdded:Wait()
end

local function getRootPart()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function checkMaxLevel()
    PetFarmState.isMaxLevel = Player:GetAttribute("IsMaxLevel") == true
end
RunService.Heartbeat:Connect(checkMaxLevel)

Player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
end)

local function startCollectChests()
    if getgenv().chestThread then
        task.cancel(getgenv().chestThread)
        getgenv().chestThread = nil
    end
    getgenv().chestThread = task.spawn(function()
        while getgenv().CollectAllChests do
            pcall(function()
                local chestRewards = ReplicatedStorage:FindFirstChild("chestRewards")
                if chestRewards then
                    for _, v in pairs(chestRewards:GetChildren()) do
                        local remote = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("checkChestRemote")
                        if remote then
                            remote:InvokeServer(v.Name)
                        end
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end

local function startUnlockPasses()
    if getgenv().passThread then
        task.cancel(getgenv().passThread)
        getgenv().passThread = nil
    end
    getgenv().passThread = task.spawn(function()
        while getgenv().UnlockAllPasses do
            pcall(function()
                local gamepassIds = ReplicatedStorage:FindFirstChild("gamepassIds")
                local ownedGamepasses = Player:FindFirstChild("ownedGamepasses")
                if gamepassIds and ownedGamepasses then
                    for _, v in ipairs(gamepassIds:GetChildren()) do
                        v.Parent = ownedGamepasses
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end

local function startSuckHoops()
    if getgenv().hoopThread then
        task.cancel(getgenv().hoopThread)
        getgenv().hoopThread = nil
    end
    getgenv().hoopThread = task.spawn(function()
        while getgenv().SuckHoops do
            pcall(function()
                local hrp = getRootPart()
                local hoops = Workspace:FindFirstChild("Hoops")
                if hrp and hoops then
                    for _, hoop in ipairs(hoops:GetChildren()) do
                        if hoop.Name == "Hoop" then
                            hoop.CFrame = hrp.CFrame
                        end
                    end
                end
            end)
            task.wait()
        end
    end)
end

local function startPetFarmMode1(orbType, flag)
    getgenv()[flag] = true
    task.spawn(function()
        while getgenv()[flag] do
            if PetFarmState.isMaxLevel then
                getgenv()[flag] = false
                break
            end
            pcall(function()
                for i = 1, 10 do
                    local orbEvent = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("orbEvent")
                    if orbEvent then
                        orbEvent:FireServer("collectOrb", orbType, PetFarmState.area)
                    end
                end
            end)
            task.wait(0.05)
        end
    end)
end

local function startPetFarmMode2()
    getgenv().PetFarmMode2 = true
    task.spawn(function()
        while getgenv().PetFarmMode2 do
            if PetFarmState.isMaxLevel then
                getgenv().PetFarmMode2 = false
                break
            end
            pcall(function()
                local total = math.max(1, PetFarmState.multiplier or 1)
                for i = 1, total do
                    local orbEvent = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("orbEvent")
                    if orbEvent then
                        orbEvent:FireServer("collectOrb", PetFarmState.orbType, PetFarmState.area)
                    end
                end
            end)
            task.wait()
        end
    end)
end

local function startGemMode(areaName, flag)
    getgenv()[flag] = true
    task.spawn(function()
        while getgenv()[flag] do
            pcall(function()
                for i = 1, 5 do
                    local orbEvent = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("orbEvent")
                    if orbEvent then
                        orbEvent:FireServer("collectOrb", "Gem", areaName)
                    end
                end
            end)
            task.wait()
        end
    end)
end

local function startAutoRace()
    if getgenv().raceThread then
        task.cancel(getgenv().raceThread)
        getgenv().raceThread = nil
    end
    getgenv().raceThread = task.spawn(function()
        while getgenv().AutoRace do
            pcall(function()
                local raceEvent = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("raceEvent")
                if raceEvent then
                    raceEvent:FireServer("joinRace")
                end
            end)
            task.wait()
        end
    end)
end
local function startAutoRaceWin()
    if getgenv().raceWinThread then
        task.cancel(getgenv().raceWinThread)
        getgenv().raceWinThread = nil
    end
    getgenv().raceWinThread = task.spawn(function()
        while getgenv().AutoRaceWin do
            pcall(function()
                local raceEvent = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("raceEvent")
                if raceEvent then
                    raceEvent:FireServer("joinRace")
                end
                local hrp = getRootPart()
                local raceMaps = Workspace:FindFirstChild("raceMaps")
                if hrp and raceMaps then
                    if game.PlaceId == 3101667897 then
                        if raceMaps:FindFirstChild("Grassland") and raceMaps.Grassland:FindFirstChild("finishPart") then
                            hrp.CFrame = raceMaps.Grassland.finishPart.CFrame
                        end
                        task.wait(0.1)
                        if raceMaps:FindFirstChild("Magma") and raceMaps.Magma:FindFirstChild("finishPart") then
                            hrp.CFrame = raceMaps.Magma.finishPart.CFrame
                        end
                        task.wait(0.1)
                        if raceMaps:FindFirstChild("Desert") and raceMaps.Desert:FindFirstChild("finishPart") then
                            hrp.CFrame = raceMaps.Desert.finishPart.CFrame
                        end
                    elseif game.PlaceId == 3276265788 then
                        if raceMaps:FindFirstChild("Speedway") and raceMaps.Speedway:FindFirstChild("finishPart") then
                            hrp.CFrame = raceMaps.Speedway.finishPart.CFrame
                        end
                    elseif game.PlaceId == 3232996272 then
                        if raceMaps:FindFirstChild("Starway") and raceMaps.Starway:FindFirstChild("finishPart") then
                            hrp.CFrame = raceMaps.Starway.finishPart.CFrame
                        end
                    end
                end
            end)
            task.wait(0.3)
        end
    end)
end

local function startAutoRebirth1()
    if getgenv().rebirth1Thread then
        task.cancel(getgenv().rebirth1Thread)
        getgenv().rebirth1Thread = nil
    end
    getgenv().rebirth1Thread = task.spawn(function()
        while getgenv().AutoRebirth1 do
            pcall(function()
                local rebirthEvent = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("rebirthEvent")
                if rebirthEvent then
                    rebirthEvent:FireServer("rebirthRequest")
                end
            end)
            task.wait()
        end
    end)
end

local function startAutoRebirth2()
    if getgenv().rebirth2Thread then
        task.cancel(getgenv().rebirth2Thread)
        getgenv().rebirth2Thread = nil
    end
    getgenv().rebirth2Thread = task.spawn(function()
        while getgenv().AutoRebirth2 do
            local rebirths = Player.leaderstats and Player.leaderstats:FindFirstChild("Rebirths")
            if rebirths and rebirths.Value >= getgenv().TargetRebirths then
                getgenv().AutoRebirth2 = false
                break
            else
                pcall(function()
                    local rebirthEvent = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("rebirthEvent")
                    if rebirthEvent then
                        rebirthEvent:FireServer("rebirthRequest")
                    end
                end)
            end
            task.wait(0.1)
        end
    end)
end

local function startAutoEvolve()
    if getgenv().evolveThread then
        task.cancel(getgenv().evolveThread)
        getgenv().evolveThread = nil
    end
    getgenv().evolveThread = task.spawn(function()
        while getgenv().AutoEvolve do
            pcall(function()
                local ownedPets = Player:FindFirstChild("ownedPets")
                local petEvolveEvent = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("petEvolveEvent")
                if ownedPets and petEvolveEvent then
                    local pets = ownedPets:GetChildren()
                    if #pets > 0 then
                        local randomPet = pets[math.random(#pets)]
                        petEvolveEvent:FireServer("evolvePet", randomPet.Name)
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
end

local function startAutoBuyPet()
    if getgenv().buyPetThread then
        task.cancel(getgenv().buyPetThread)
        getgenv().buyPetThread = nil
    end
    getgenv().buyPetThread = task.spawn(function()
        while getgenv().AutoBuyPet and getgenv().SelectedPet ~= "" do
            pcall(function()
                local petShopFolder = ReplicatedStorage:FindFirstChild("cPetShopFolder")
                local petShopRemote = ReplicatedStorage:FindFirstChild("cPetShopRemote")
                if petShopFolder and petShopRemote then
                    local pet = petShopFolder:FindFirstChild(getgenv().SelectedPet)
                    if pet then
                        petShopRemote:InvokeServer(pet)
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end

local noclipConnection = nil
local function toggleNoclip(state)
    getgenv().NoclipEnabled = state
    if state then
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Stepped:Connect(function()
            local char = getCharacter()
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        local char = getCharacter()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

local flySpeed = 150
local flyMultiplier = 5
local flyConnection = nil

local function toggleFly(state)
    getgenv().FlyEnabled = state
    if state then
        local controlModule = Player.PlayerScripts and Player.PlayerScripts:FindFirstChild('PlayerModule')
        if not controlModule then return end
        controlModule = require(controlModule:WaitForChild("ControlModule"))
        local char = getCharacter()
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hrp = char.HumanoidRootPart
        if hrp:FindFirstChild("VelocityHandler") then hrp.VelocityHandler:Destroy() end
        if hrp:FindFirstChild("GyroHandler") then hrp.GyroHandler:Destroy() end
        local bv = Instance.new("BodyVelocity")
        bv.Name = "VelocityHandler"
        bv.Parent = hrp
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.new(0, 0, 0)
        local bg = Instance.new("BodyGyro")
        bg.Name = "GyroHandler"
        bg.Parent = hrp
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.P = 1000
        bg.D = 50
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = true
        end
        flyConnection = RunService.RenderStepped:Connect(function()
            local currentChar = getCharacter()
            local currentHrp = currentChar and currentChar:FindFirstChild("HumanoidRootPart")
            if currentChar and currentHrp and currentHrp:FindFirstChild("VelocityHandler") and currentHrp:FindFirstChild("GyroHandler") and getgenv().FlyEnabled then
                currentHrp.GyroHandler.CFrame = Camera.CFrame
                local direction = controlModule:GetMoveVector()
                local actualSpeed = flySpeed * flyMultiplier
                currentHrp.VelocityHandler.Velocity = Vector3.new()
                if direction.X ~= 0 then
                    currentHrp.VelocityHandler.Velocity = currentHrp.VelocityHandler.Velocity + Camera.CFrame.RightVector * (direction.X * actualSpeed)
                end
                if direction.Z ~= 0 then
                    currentHrp.VelocityHandler.Velocity = currentHrp.VelocityHandler.Velocity - Camera.CFrame.LookVector * (direction.Z * actualSpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    currentHrp.VelocityHandler.Velocity = currentHrp.VelocityHandler.Velocity + Vector3.new(0, actualSpeed/2, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    currentHrp.VelocityHandler.Velocity = currentHrp.VelocityHandler.Velocity - Vector3.new(0, actualSpeed/2, 0)
                end
            end
        end)
    else
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        local char = getCharacter()
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            if hrp:FindFirstChild("VelocityHandler") then hrp.VelocityHandler:Destroy() end
            if hrp:FindFirstChild("GyroHandler") then hrp.GyroHandler:Destroy() end
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.PlatformStand = false
            end
        end
    end
end

local function teleportTo(pos)
    local hrp = getRootPart()
    if hrp then
        hrp.CFrame = CFrame.new(pos)
        Library:Notify({
            Title = "传送",
            Description = "已传送",
            Time = 1
        })
    end
end

local function startAutoXP()
    if getgenv().xpThread then
        task.cancel(getgenv().xpThread)
        getgenv().xpThread = nil
    end
    getgenv().xpThread = task.spawn(function()
        while getgenv().AutoXP do
            pcall(function()
                for i = 1, 17 do
                    ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("orbEvent"):FireServer("collectOrb", "Orange Orb", "City")
                end
            end)
            task.wait()
        end
    end)
end

local function startAutoSpeedCity()
    if getgenv().speedCityThread then
        task.cancel(getgenv().speedCityThread)
        getgenv().speedCityThread = nil
    end
    getgenv().speedCityThread = task.spawn(function()
        while getgenv().AutoSpeedCity do
            pcall(function()
                for i = 1, 18 do
                    ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("orbEvent"):FireServer("collectOrb", "Red Orb", "City")
                end
            end)
            task.wait()
        end
    end)
end

local function startAutoSpeedSnow()
    if getgenv().speedSnowThread then
        task.cancel(getgenv().speedSnowThread)
        getgenv().speedSnowThread = nil
    end
    getgenv().speedSnowThread = task.spawn(function()
        while getgenv().AutoSpeedSnow do
            pcall(function()
                for i = 1, 18 do
                    ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("orbEvent"):FireServer("collectOrb", "Red Orb", "Snow City")
                end
            end)
            task.wait()
        end
    end)
end

local function startAutoSpeedMagma()
    if getgenv().speedMagmaThread then
        task.cancel(getgenv().speedMagmaThread)
        getgenv().speedMagmaThread = nil
    end
    getgenv().speedMagmaThread = task.spawn(function()
        while getgenv().AutoSpeedMagma do
            pcall(function()
                for i = 1, 16 do
                    ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("orbEvent"):FireServer("collectOrb", "Red Orb", "Magma City")
                end
            end)
            task.wait()
        end
    end)
end

local function startAutoSpeedHighway()
    if getgenv().speedHighwayThread then
        task.cancel(getgenv().speedHighwayThread)
        getgenv().speedHighwayThread = nil
    end
    getgenv().speedHighwayThread = task.spawn(function()
        while getgenv().AutoSpeedHighway do
            pcall(function()
                for i = 1, 16 do
                    ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("orbEvent"):FireServer("collectOrb", "Red Orb", "Legends Highway")
                end
            end)
            task.wait()
        end
    end)
end

local function startAutoGemCity()
    if getgenv().gemCityThread then
        task.cancel(getgenv().gemCityThread)
        getgenv().gemCityThread = nil
    end
    getgenv().gemCityThread = task.spawn(function()
        while getgenv().AutoGemCity do
            pcall(function()
                for i = 1, 20 do
                    ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("orbEvent"):FireServer("collectOrb", "Gem", "City")
                end
            end)
            task.wait()
        end
    end)
end

local function startAutoGemSnow()
    if getgenv().gemSnowThread then
        task.cancel(getgenv().gemSnowThread)
        getgenv().gemSnowThread = nil
    end
    getgenv().gemSnowThread = task.spawn(function()
        while getgenv().AutoGemSnow do
            pcall(function()
                for i = 1, 20 do
                    ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("orbEvent"):FireServer("collectOrb", "Gem", "Snow City")
                end
            end)
            task.wait()
        end
    end)
end

local function startAutoGemMagma()
    if getgenv().gemMagmaThread then
        task.cancel(getgenv().gemMagmaThread)
        getgenv().gemMagmaThread = nil
    end
    getgenv().gemMagmaThread = task.spawn(function()
        while getgenv().AutoGemMagma do
            pcall(function()
                for i = 1, 20 do
                    ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("orbEvent"):FireServer("collectOrb", "Gem", "Magma City")
                end
            end)
            task.wait()
        end
    end)
end

local function startAutoGemHighway()
    if getgenv().gemHighwayThread then
        task.cancel(getgenv().gemHighwayThread)
        getgenv().gemHighwayThread = nil
    end
    getgenv().gemHighwayThread = task.spawn(function()
        while getgenv().AutoGemHighway do
            pcall(function()
                for i = 1, 20 do
                    ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("orbEvent"):FireServer("collectOrb", "Gem", "Legends Highway")
                end
            end)
            task.wait()
        end
    end)
end
local q = {
    CFrame.new(-278.8976135253906, 66.09315490722656, -10946.564453125),
    CFrame.new(3980.05029296875, 159.91925048828125, 5589.21533203125),
    CFrame.new(137.6853485107422, 75.40111541748047, -5972.4873046875),
    CFrame.new(-15376.439453125, 412.2984619140625, 4475.322265625),
    CFrame.new(-489.440673828125, 98.277099609375, 2502.03564453125),
    CFrame.new(-15167.5068359375, 382.1965026855469, 4888.2900390625),
    CFrame.new(2094.217041015625, 251.98931884765625, 12877.951171875),
    CFrame.new(-1645.1728515625, 69.02545928955078, 5337.923828125),
    CFrame.new(-13254.447265625, 222.44158935546875, 4891.56005859375),
    CFrame.new(-533.439208984375, 58.4377326965332, 209.794921875),
    CFrame.new(473.2319641113281, 66.08084106445312, -10867.8388671875),
    CFrame.new(2333.369873046875, 161.6602325439453, 13369.1240234375),
    CFrame.new(5392.5322265625, 297.8348388671875, 5885.2138671875),
    CFrame.new(3806.247802734375, 299.41748046875, 7225.6806640625),
    CFrame.new(1664.3343505859375, 80.900390625, 12589.7109375),
    CFrame.new(1769.7236328125, 80.90105438232422, 12879.7958984375),
    CFrame.new(-11097.05859375, 200.84193420410156, 4465.34375),
    CFrame.new(-13140.974609375, 200.84193420410156, 4465.39599609375),
    CFrame.new(-536.3781127929688, 58.43798065185547, -133.1399688720703),
    CFrame.new(2485.461181640625, 135.55299377441406, 12384.6455078125),
    CFrame.new(1173.287109375, 92.03070831298828, -6024.24365234375),
    CFrame.new(-85.52466583251953, 115.9759750366211, -107.73560333251953),
    CFrame.new(1805.7076416015625, 90.94168853759766, 4617.30712890625),
    CFrame.new(-350.6163330078125, 66.06715393066406, -8732.2490234375),
    CFrame.new(5666.32861328125, 326.5240478515625, 6494.826171875),
    CFrame.new(4516.66845703125, 221.20545959472656, 7181.7421875),
    CFrame.new(-1746.5504150390625, 150.5835418701172, 5372.54248046875),
    CFrame.new(5361.96826171875, 297.8207092285156, 7025.44482421875),
    CFrame.new(4650.1669921875, 221.213134765625, 5608.54345703125),
    CFrame.new(-12993.1826171875, 200.82785034179688, 5222.71337890625),
    CFrame.new(355.5094299316406, 111.75679779052734, -10924.6923828125),
    CFrame.new(1942.0057373046875, 93.18344116210938, -2047.2164306640625),
    CFrame.new(-15156.52734375, 355.08978271484375, 4141.91357421875),
    CFrame.new(2062.114990234375, 159.88404846191406, 4374.28076171875),
    CFrame.new(230.04505920410156, 94.17676544189453, 80.71623229980469),
}

local function startAutoLoopTeleport()
    if getgenv().loopTeleportThread then
        task.cancel(getgenv().loopTeleportThread)
        getgenv().loopTeleportThread = nil
    end
    getgenv().loopTeleportThread = task.spawn(function()
        while getgenv().AutoLoopTeleport do
            pcall(function()
                for _, zdsq in ipairs(q) do
                    if not getgenv().AutoLoopTeleport then break end
                    local hrp = getRootPart()
                    if hrp then
                        hrp.CFrame = zdsq
                    end
                    task.wait()
                end
            end)
            task.wait()
        end
        local hrp = getRootPart()
        if hrp then
            hrp.CFrame = CFrame.new(-568.6292114257812, 3.1723721027374268, 412.86492919921875)
        end
    end)
end

local function startAutoSpeedV2()
    if getgenv().speedV2Thread then
        task.cancel(getgenv().speedV2Thread)
        getgenv().speedV2Thread = nil
    end
    getgenv().speedV2Thread = task.spawn(function()
        while getgenv().AutoSpeedV2 do
            pcall(function()
                for i = 1, 20 do
                    ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("questsEvent"):FireServer("collectQuest", Instance.new("Folder", nil))
                end
            end)
            task.wait()
        end
    end)
end

local function startAutoBuyPetCrystal()
    if getgenv().buyPetCrystalThread then
        task.cancel(getgenv().buyPetCrystalThread)
        getgenv().buyPetCrystalThread = nil
    end
    getgenv().buyPetCrystalThread = task.spawn(function()
        while getgenv().AutoBuyPetCrystal do
            pcall(function()
                ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("openCrystalRemote"):InvokeServer("openCrystal", "Jungle Crystal")
            end)
            task.wait()
        end
    end)
end

local function startAutoBuyTrail()
    if getgenv().buyTrailThread then
        task.cancel(getgenv().buyTrailThread)
        getgenv().buyTrailThread = nil
    end
    getgenv().buyTrailThread = task.spawn(function()
        while getgenv().AutoBuyTrail do
            pcall(function()
                ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("openCrystalRemote"):InvokeServer("openCrystal", "Inferno Crystal")
            end)
            task.wait()
        end
    end)
end

local MainLeft = Tabs.Main:AddLeftGroupbox("基础功能")
MainLeft:AddToggle("CollectAllChests", { Text = "收集全部宝箱", Default = false, Callback = function(Value)
    getgenv().CollectAllChests = Value
    if Value then startCollectChests() else
        if getgenv().chestThread then task.cancel(getgenv().chestThread) getgenv().chestThread = nil end
    end
end })
MainLeft:AddToggle("UnlockAllPasses", { Text = "解锁全部通行证", Default = false, Callback = function(Value)
    getgenv().UnlockAllPasses = Value
    if Value then startUnlockPasses() else
        if getgenv().passThread then task.cancel(getgenv().passThread) getgenv().passThread = nil end
    end
end })
MainLeft:AddToggle("SuckHoops", { Text = "吸全部环", Default = false, Callback = function(Value)
    getgenv().SuckHoops = Value
    if Value then startSuckHoops() else
        if getgenv().hoopThread then task.cancel(getgenv().hoopThread) getgenv().hoopThread = nil end
    end
end })

local PetFarmLeft = Tabs.Main:AddLeftGroupbox("卡宠模式1")
PetFarmLeft:AddDropdown("AreaSelect", { Text = "选择地区", Values = areaDisplayNames, Default = 1, Multi = false, Callback = function(Value)
    local idx = table.find(areaDisplayNames, Value)
    if idx then PetFarmState.area = areaOptions[idx] end
end })
PetFarmLeft:AddToggle("PetFarmPurple", { Text = "紫球", Default = false, Callback = function(Value)
    if Value then
        if getgenv().PetFarmRed or getgenv().PetFarmBlue or getgenv().PetFarmOrange or getgenv().PetFarmYellow then
            getgenv().PetFarmPurple = false
            Library:Notify({ Title = "提示", Description = "只能同时开启一个球类型", Time = 2 })
        else
            getgenv().PetFarmPurple = true
            startPetFarmMode1("Ethereal Orb", "PetFarmPurple")
        end
    else
        getgenv().PetFarmPurple = false
    end
end })
PetFarmLeft:AddToggle("PetFarmRed", { Text = "红球", Default = false, Callback = function(Value)
    if Value then
        if getgenv().PetFarmPurple or getgenv().PetFarmBlue or getgenv().PetFarmOrange or getgenv().PetFarmYellow then
            getgenv().PetFarmRed = false
            Library:Notify({ Title = "提示", Description = "只能同时开启一个球类型", Time = 2 })
        else
            getgenv().PetFarmRed = true
            startPetFarmMode1("Red Orb", "PetFarmRed")
        end
    else
        getgenv().PetFarmRed = false
    end
end })
PetFarmLeft:AddToggle("PetFarmBlue", { Text = "蓝球", Default = false, Callback = function(Value)
    if Value then
        if getgenv().PetFarmPurple or getgenv().PetFarmRed or getgenv().PetFarmOrange or getgenv().PetFarmYellow then
            getgenv().PetFarmBlue = false
            Library:Notify({ Title = "提示", Description = "只能同时开启一个球类型", Time = 2 })
        else
            getgenv().PetFarmBlue = true
            startPetFarmMode1("Blue Orb", "PetFarmBlue")
        end
    else
        getgenv().PetFarmBlue = false
    end
end })
PetFarmLeft:AddToggle("PetFarmOrange", { Text = "橙球", Default = false, Callback = function(Value)
    if Value then
        if getgenv().PetFarmPurple or getgenv().PetFarmRed or getgenv().PetFarmBlue or getgenv().PetFarmYellow then
            getgenv().PetFarmOrange = false
            Library:Notify({ Title = "提示", Description = "只能同时开启一个球类型", Time = 2 })
        else
            getgenv().PetFarmOrange = true
            startPetFarmMode1("Orange Orb", "PetFarmOrange")
        end
    else
        getgenv().PetFarmOrange = false
    end
end })
PetFarmLeft:AddToggle("PetFarmYellow", { Text = "经验球", Default = false, Callback = function(Value)
    if Value then
        if getgenv().PetFarmPurple or getgenv().PetFarmRed or getgenv().PetFarmBlue or getgenv().PetFarmOrange then
            getgenv().PetFarmYellow = false
            Library:Notify({ Title = "提示", Description = "只能同时开启一个球类型", Time = 2 })
        else
            getgenv().PetFarmYellow = true
            startPetFarmMode1("Yellow Orb", "PetFarmYellow")
        end
    else
        getgenv().PetFarmYellow = false
    end
end })

local PetFarmRight = Tabs.Main:AddRightGroupbox("卡宠模式2")
PetFarmRight:AddDropdown("OrbTypeSelect", { Text = "球类型", Values = orbDisplayNames, Default = 5, Multi = false, Callback = function(Value)
    local idx = table.find(orbDisplayNames, Value)
    if idx then PetFarmState.orbType = orbOptions[idx] end
end })
PetFarmRight:AddSlider("OrbMultiplier", { Text = "倍率", Default = 1, Min = 1, Max = 100, Rounding = 0, Callback = function(Value)
    PetFarmState.multiplier = Value
end })
PetFarmRight:AddToggle("PetFarmMode2", { Text = "卡宠模式2", Default = false, Callback = function(Value)
    getgenv().PetFarmMode2 = Value
    if Value then startPetFarmMode2() end
end })

local GemsRight = Tabs.Main:AddRightGroupbox("宝石模式")
GemsRight:AddToggle("Gem_City", { Text = "城市宝石", Default = false, Callback = function(Value)
    getgenv().Gem_City = Value
    if Value then startGemMode("City", "Gem_City") end
end })
GemsRight:AddToggle("Gem_SnowCity", { Text = "雪城宝石", Default = false, Callback = function(Value)
    getgenv().Gem_SnowCity = Value
    if Value then startGemMode("Snow City", "Gem_SnowCity") end
end })
GemsRight:AddToggle("Gem_MagmaCity", { Text = "熔岩城宝石", Default = false, Callback = function(Value)
    getgenv().Gem_MagmaCity = Value
    if Value then startGemMode("Magma City", "Gem_MagmaCity") end
end })
GemsRight:AddToggle("Gem_LegendsHighway", { Text = "传奇公路宝石", Default = false, Callback = function(Value)
    getgenv().Gem_LegendsHighway = Value
    if Value then startGemMode("Legends Highway", "Gem_LegendsHighway") end
end })
GemsRight:AddToggle("Gem_SpeedJungle", { Text = "丛林宝石", Default = false, Callback = function(Value)
    getgenv().Gem_SpeedJungle = Value
    if Value then startGemMode("Speed Jungle", "Gem_SpeedJungle") end
end })

local RaceLeft = Tabs.Main:AddLeftGroupbox("比赛功能")
RaceLeft:AddToggle("AutoRace", { Text = "自动比赛", Default = false, Callback = function(Value)
    getgenv().AutoRace = Value
    if Value then startAutoRace() else
        if getgenv().raceThread then task.cancel(getgenv().raceThread) getgenv().raceThread = nil end
    end
end })
RaceLeft:AddToggle("AutoRaceWin", { Text = "自动比赛胜利", Default = false, Callback = function(Value)
    getgenv().AutoRaceWin = Value
    if Value then startAutoRaceWin() else
        if getgenv().raceWinThread then task.cancel(getgenv().raceWinThread) getgenv().raceWinThread = nil end
    end
end })

local RebirthRight = Tabs.Main:AddRightGroupbox("重生功能")
RebirthRight:AddToggle("AutoRebirth1", { Text = "自动重生", Default = false, Callback = function(Value)
    getgenv().AutoRebirth1 = Value
    if Value then startAutoRebirth1() else
        if getgenv().rebirth1Thread then task.cancel(getgenv().rebirth1Thread) getgenv().rebirth1Thread = nil end
    end
end })
RebirthRight:AddSlider("TargetRebirths", { Text = "目标重生次数", Default = 100, Min = 0, Max = 1000, Rounding = 0, Callback = function(Value)
    getgenv().TargetRebirths = Value
end })
RebirthRight:AddToggle("AutoRebirth2", { Text = "重生到指定次数", Default = false, Callback = function(Value)
    getgenv().AutoRebirth2 = Value
    if Value then startAutoRebirth2() else
        if getgenv().rebirth2Thread then task.cancel(getgenv().rebirth2Thread) getgenv().rebirth2Thread = nil end
    end
end })
local FarmLeft = Tabs.Farm:AddLeftGroupbox("自动刷取")
FarmLeft:AddToggle("AutoXP", { Text = "自动刷经验 150", Default = false, Callback = function(Value)
    getgenv().AutoXP = Value
    if Value then startAutoXP() else
        if getgenv().xpThread then task.cancel(getgenv().xpThread) getgenv().xpThread = nil end
    end
end })
FarmLeft:AddToggle("AutoSpeedCity", { Text = "自动刷速度(城市)", Default = false, Callback = function(Value)
    getgenv().AutoSpeedCity = Value
    if Value then startAutoSpeedCity() else
        if getgenv().speedCityThread then task.cancel(getgenv().speedCityThread) getgenv().speedCityThread = nil end
    end
end })
FarmLeft:AddToggle("AutoSpeedSnow", { Text = "自动刷速度(雪城)", Default = false, Callback = function(Value)
    getgenv().AutoSpeedSnow = Value
    if Value then startAutoSpeedSnow() else
        if getgenv().speedSnowThread then task.cancel(getgenv().speedSnowThread) getgenv().speedSnowThread = nil end
    end
end })
FarmLeft:AddToggle("AutoSpeedMagma", { Text = "自动刷速度(熔岩城)", Default = false, Callback = function(Value)
    getgenv().AutoSpeedMagma = Value
    if Value then startAutoSpeedMagma() else
        if getgenv().speedMagmaThread then task.cancel(getgenv().speedMagmaThread) getgenv().speedMagmaThread = nil end
    end
end })
FarmLeft:AddToggle("AutoSpeedHighway", { Text = "自动刷速度(传奇公路)", Default = false, Callback = function(Value)
    getgenv().AutoSpeedHighway = Value
    if Value then startAutoSpeedHighway() else
        if getgenv().speedHighwayThread then task.cancel(getgenv().speedHighwayThread) getgenv().speedHighwayThread = nil end
    end
end })

local FarmRight = Tabs.Farm:AddRightGroupbox("刷钻石")
FarmRight:AddToggle("AutoGemCity", { Text = "自动刷钻石(城市)", Default = false, Callback = function(Value)
    getgenv().AutoGemCity = Value
    if Value then startAutoGemCity() else
        if getgenv().gemCityThread then task.cancel(getgenv().gemCityThread) getgenv().gemCityThread = nil end
    end
end })
FarmRight:AddToggle("AutoGemSnow", { Text = "自动刷钻石(雪城)", Default = false, Callback = function(Value)
    getgenv().AutoGemSnow = Value
    if Value then startAutoGemSnow() else
        if getgenv().gemSnowThread then task.cancel(getgenv().gemSnowThread) getgenv().gemSnowThread = nil end
    end
end })
FarmRight:AddToggle("AutoGemMagma", { Text = "自动刷钻石(熔岩城)", Default = false, Callback = function(Value)
    getgenv().AutoGemMagma = Value
    if Value then startAutoGemMagma() else
        if getgenv().gemMagmaThread then task.cancel(getgenv().gemMagmaThread) getgenv().gemMagmaThread = nil end
    end
end })
FarmRight:AddToggle("AutoGemHighway", { Text = "自动刷钻石(传奇公路)", Default = false, Callback = function(Value)
    getgenv().AutoGemHighway = Value
    if Value then startAutoGemHighway() else
        if getgenv().gemHighwayThread then task.cancel(getgenv().gemHighwayThread) getgenv().gemHighwayThread = nil end
    end
end })

local FarmRight2 = Tabs.Farm:AddRightGroupbox("其他刷取")
FarmRight2:AddToggle("AutoLoopTeleport", { Text = "自动刷圈", Default = false, Callback = function(Value)
    getgenv().AutoLoopTeleport = Value
    if Value then startAutoLoopTeleport() else
        if getgenv().loopTeleportThread then task.cancel(getgenv().loopTeleportThread) getgenv().loopTeleportThread = nil end
    end
end })
FarmRight2:AddToggle("AutoSpeedV2", { Text = "自动刷速度V2", Default = false, Callback = function(Value)
    getgenv().AutoSpeedV2 = Value
    if Value then startAutoSpeedV2() else
        if getgenv().speedV2Thread then task.cancel(getgenv().speedV2Thread) getgenv().speedV2Thread = nil end
    end
end })

local PetLeft = Tabs.Pet:AddLeftGroupbox("宠物商店")
PetLeft:AddDropdown("SelectedPet", { Text = "选择宠物", Values = petDisplayNames, Default = 1, Multi = false, Callback = function(Value)
    local idx = table.find(petDisplayNames, Value)
    if idx then getgenv().SelectedPet = petOptions[idx] end
end })
PetLeft:AddButton("购买一次", function()
    if getgenv().SelectedPet ~= "" then
        pcall(function()
            local petShopFolder = ReplicatedStorage:FindFirstChild("cPetShopFolder")
            local petShopRemote = ReplicatedStorage:FindFirstChild("cPetShopRemote")
            if petShopFolder and petShopRemote then
                local pet = petShopFolder:FindFirstChild(getgenv().SelectedPet)
                if pet then
                    petShopRemote:InvokeServer(pet)
                    Library:Notify({ Title = "购买宠物", Description = "购买成功", Time = 2 })
                end
            end
        end)
    end
end)
PetLeft:AddToggle("AutoBuyPet", { Text = "自动购买", Default = false, Callback = function(Value)
    getgenv().AutoBuyPet = Value
    if Value then
        if getgenv().SelectedPet ~= "" then
            startAutoBuyPet()
        else
            getgenv().AutoBuyPet = false
            Library:Notify({ Title = "提示", Description = "请先选择宠物", Time = 2 })
        end
    else
        if getgenv().buyPetThread then task.cancel(getgenv().buyPetThread) getgenv().buyPetThread = nil end
    end
end })

local PetRight = Tabs.Pet:AddRightGroupbox("进化")
PetRight:AddButton("进化一次", function()
    pcall(function()
        local ownedPets = Player:FindFirstChild("ownedPets")
        local petEvolveEvent = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("petEvolveEvent")
        if ownedPets and petEvolveEvent then
            local pets = ownedPets:GetChildren()
            if #pets > 0 then
                local randomPet = pets[math.random(#pets)]
                petEvolveEvent:FireServer("evolvePet", randomPet.Name)
                Library:Notify({ Title = "进化", Description = "进化成功", Time = 2 })
            end
        end
    end)
end)
PetRight:AddToggle("AutoEvolve", { Text = "自动进化", Default = false, Callback = function(Value)
    getgenv().AutoEvolve = Value
    if Value then startAutoEvolve() else
        if getgenv().evolveThread then task.cancel(getgenv().evolveThread) getgenv().evolveThread = nil end
    end
end })

local PetRight2 = Tabs.Pet:AddRightGroupbox("水晶购买")
PetRight2:AddToggle("AutoBuyPetCrystal", { Text = "自动买宠物(丛林水晶)", Default = false, Callback = function(Value)
    getgenv().AutoBuyPetCrystal = Value
    if Value then startAutoBuyPetCrystal() else
        if getgenv().buyPetCrystalThread then task.cancel(getgenv().buyPetCrystalThread) getgenv().buyPetCrystalThread = nil end
    end
end })
PetRight2:AddToggle("AutoBuyTrail", { Text = "自动买尾迹(地狱水晶)", Default = false, Callback = function(Value)
    getgenv().AutoBuyTrail = Value
    if Value then startAutoBuyTrail() else
        if getgenv().buyTrailThread then task.cancel(getgenv().buyTrailThread) getgenv().buyTrailThread = nil end
    end
end })

local TeleportLeft = Tabs.Teleport:AddLeftGroupbox("快速传送")
TeleportLeft:AddButton("城市", function()
    teleportTo(Vector3.new(2002.0133056640625, 1.2624330520629883, 985.2265625))
end)
TeleportLeft:AddButton("雪城", function()
    teleportTo(Vector3.new(-9675.25, 59.63568115234375, 3783.50146484375))
end)
TeleportLeft:AddButton("熔岩城", function()
    teleportTo(Vector3.new(-11052.4189453125, 217.59571838378906, 4898.76416015625))
end)
TeleportLeft:AddButton("传奇公路", function()
    teleportTo(Vector3.new(-13095.255859375, 217.59567260742188, 5905.240234375))
end)
TeleportLeft:AddButton("丛林", function()
    teleportTo(Vector3.new(-15267.9, 399.0, 5575.7))
end)

local TeleportRight = Tabs.Teleport:AddRightGroupbox("Yttrium传送")
TeleportRight:AddButton("传送至城市(出生点)", function()
    local hrp = getRootPart()
    if hrp then
        hrp.CFrame = CFrame.new(-568.6292114257812, 3.1723721027374268, 412.86492919921875)
        Library:Notify({ Title = "传送", Description = "传送成功", Time = 2 })
    end
end)
TeleportRight:AddButton("传送至神秘洞穴", function()
    local hrp = getRootPart()
    if hrp then
        hrp.CFrame = CFrame.new(-9683.048828125, 58.352359771728516, 3136.626953125)
        Library:Notify({ Title = "传送", Description = "传送成功", Time = 2 })
    end
end)
TeleportRight:AddButton("传送至白雪城市", function()
    local hrp = getRootPart()
    if hrp then
        hrp.CFrame = CFrame.new(-866.3868408203125, 3.222372055053711, 2165.70654296875)
        Library:Notify({ Title = "传送", Description = "传送成功", Time = 2 })
    end
end)
TeleportRight:AddButton("传送至地狱洞穴", function()
    local hrp = getRootPart()
    if hrp then
        hrp.CFrame = CFrame.new(-11041.357421875, 58.352359771728516, 4111.8251953125)
        Library:Notify({ Title = "传送", Description = "传送成功", Time = 2 })
    end
end)
TeleportRight:AddButton("传送至熔岩城市", function()
    local hrp = getRootPart()
    if hrp then
        hrp.CFrame = CFrame.new(1616.8270263671875, 3.2723801136016846, 4330.65234375)
        Library:Notify({ Title = "传送", Description = "传送成功", Time = 2 })
    end
end)
TeleportRight:AddButton("传送至水手路线", function()
    local hrp = getRootPart()
    if hrp then
        hrp.CFrame = CFrame.new(-1618.4071044921875, 8.759234428405762, 4892.44091796875)
        Library:Notify({ Title = "传送", Description = "传送成功", Time = 2 })
    end
end)
TeleportRight:AddButton("传送至电光洞穴", function()
    local hrp = getRootPart()
    if hrp then
        hrp.CFrame = CFrame.new(-13107.9892578125, 58.352359771728516, 4099.099609375)
        Library:Notify({ Title = "传送", Description = "传送成功", Time = 2 })
    end
end)
TeleportRight:AddButton("传送至传奇公路", function()
    local hrp = getRootPart()
    if hrp then
        hrp.CFrame = CFrame.new(3673.601318359375, 70.75231170654297, 5588.7958984375)
        Library:Notify({ Title = "传送", Description = "传送成功", Time = 2 })
    end
end)
TeleportRight:AddButton("传送至丛林洞穴", function()
    local hrp = getRootPart()
    if hrp then
        hrp.CFrame = CFrame.new(-15266.7880859375, 239.7072296142578, 3769.77490234375)
        Library:Notify({ Title = "传送", Description = "传送成功", Time = 2 })
    end
end)

local SettingsLeft = Tabs.Settings:AddLeftGroupbox("画质设置")
SettingsLeft:AddToggle("NoFog", { Text = "去雾", Default = false, Callback = function(Value)
    getgenv().NoFog = Value
    if Value then
        Lighting.FogStart = 100000
        Lighting.FogEnd = 200000
    else
        Lighting.FogStart = 0
        Lighting.FogEnd = 100000
    end
end })
SettingsLeft:AddToggle("NightVision", { Text = "夜视", Default = false, Callback = function(Value)
    getgenv().NightVision = Value
    if Value then
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.new(0.4, 0.6, 0.4)
        Lighting.ColorShift_Top = Color3.new(0.3, 0.5, 0.3)
    else
        Lighting.Brightness = 1
        Lighting.Ambient = Color3.new(0, 0, 0)
        Lighting.ColorShift_Top = Color3.new(0, 0, 0)
    end
end })

local SettingsRight = Tabs.Settings:AddRightGroupbox("通用功能")
SettingsRight:AddToggle("Noclip", { Text = "穿墙", Default = false, Callback = function(Value)
    toggleNoclip(Value)
end })
SettingsRight:AddSlider("FlyMultiplier", { Text = "飞行倍率", Default = 5, Min = 1, Max = 20, Rounding = 0, Callback = function(Value)
    flyMultiplier = Value
end })
SettingsRight:AddToggle("Fly", { Text = "飞行开关", Default = false, Callback = function(Value)
    toggleFly(Value)
end })

local AboutGroup = Tabs.Settings:AddLeftGroupbox("关于")
AboutGroup:AddLabel("极速传奇")
AboutGroup:AddLabel("版本: 1.0.0")
AboutGroup:AddLabel("作者: Aiove")
AboutGroup:AddLabel("QQ: 3999698324")

local UnloadGroup = Tabs.Settings:AddRightGroupbox("脚本管理")
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

if Library.OnUnload then
    Library:OnUnload(function()
        getgenv().CollectAllChests = false
        getgenv().UnlockAllPasses = false
        getgenv().SuckHoops = false
        getgenv().AutoRace = false
        getgenv().AutoRaceWin = false
        getgenv().AutoRebirth1 = false
        getgenv().AutoRebirth2 = false
        getgenv().FlyEnabled = false
        getgenv().NoclipEnabled = false
        getgenv().AutoEvolve = false
        getgenv().AutoBuyPet = false
        getgenv().PetFarmPurple = false
        getgenv().PetFarmRed = false
        getgenv().PetFarmBlue = false
        getgenv().PetFarmOrange = false
        getgenv().PetFarmYellow = false
        getgenv().PetFarmMode2 = false
        getgenv().Gem_City = false
        getgenv().Gem_SnowCity = false
        getgenv().Gem_MagmaCity = false
        getgenv().Gem_LegendsHighway = false
        getgenv().Gem_SpeedJungle = false
        getgenv().AutoXP = false
        getgenv().AutoSpeedCity = false
        getgenv().AutoSpeedSnow = false
        getgenv().AutoSpeedMagma = false
        getgenv().AutoSpeedHighway = false
        getgenv().AutoGemCity = false
        getgenv().AutoGemSnow = false
        getgenv().AutoGemMagma = false
        getgenv().AutoGemHighway = false
        getgenv().AutoLoopTeleport = false
        getgenv().AutoSpeedV2 = false
        getgenv().AutoBuyPetCrystal = false
        getgenv().AutoBuyTrail = false
        if getgenv().chestThread then task.cancel(getgenv().chestThread) end
        if getgenv().passThread then task.cancel(getgenv().passThread) end
        if getgenv().hoopThread then task.cancel(getgenv().hoopThread) end
        if getgenv().raceThread then task.cancel(getgenv().raceThread) end
        if getgenv().raceWinThread then task.cancel(getgenv().raceWinThread) end
        if getgenv().rebirth1Thread then task.cancel(getgenv().rebirth1Thread) end
        if getgenv().rebirth2Thread then task.cancel(getgenv().rebirth2Thread) end
        if getgenv().evolveThread then task.cancel(getgenv().evolveThread) end
        if getgenv().buyPetThread then task.cancel(getgenv().buyPetThread) end
        if getgenv().xpThread then task.cancel(getgenv().xpThread) end
        if getgenv().speedCityThread then task.cancel(getgenv().speedCityThread) end
        if getgenv().speedSnowThread then task.cancel(getgenv().speedSnowThread) end
        if getgenv().speedMagmaThread then task.cancel(getgenv().speedMagmaThread) end
        if getgenv().speedHighwayThread then task.cancel(getgenv().speedHighwayThread) end
        if getgenv().gemCityThread then task.cancel(getgenv().gemCityThread) end
        if getgenv().gemSnowThread then task.cancel(getgenv().gemSnowThread) end
        if getgenv().gemMagmaThread then task.cancel(getgenv().gemMagmaThread) end
        if getgenv().gemHighwayThread then task.cancel(getgenv().gemHighwayThread) end
        if getgenv().loopTeleportThread then task.cancel(getgenv().loopTeleportThread) end
        if getgenv().speedV2Thread then task.cancel(getgenv().speedV2Thread) end
        if getgenv().buyPetCrystalThread then task.cancel(getgenv().buyPetCrystalThread) end
        if getgenv().buyTrailThread then task.cancel(getgenv().buyTrailThread) end
        toggleFly(false)
        toggleNoclip(false)
    end)
end
