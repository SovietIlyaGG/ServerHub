-- ============================================
-- ServerHub Core.lua
-- Ядро: античит обход, фиксер, уведомления, сохранение, Hyper Tool, Ghost Mode, Rainbow Name, статистика
-- ============================================

local Core = {}
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- ========== СТАТИСТИКА ==========
Core.Stats = {
    scriptsFixed = 0,
    remotesBlocked = 0,
    bypassAttempts = 0,
    scriptsLoaded = 0,
    startTime = os.time(),
    lastFix = {}
}

-- ========== КОНФИГ ==========
local ConfigFile = "ServerHub_Config.json"

Core.Config = {
    theme = "green",
    ghostMode = false,
    fakeName = "Player_" .. math.random(1000, 9999),
    fakeNameList = {"Ghost", "Shadow", "Phantom", "Rogue", "Soviet", "Warrior", "Hunter", "Eagle", "Viper", "Reaper", "Wraith", "Specter", "Demon", "Angel", "Crimson"},
    spoofTab = true,
    spoofChat = true,
    hyperToolActive = false,
    crosshairEnabled = false,
    crosshairColor = "green",
    crosshairStyle = "cross",
    notificationsEnabled = true,
    quickActionsBar = true,
    antiCrashEnabled = true,
    autoUpdater = true,
    rainbowNameEnabled = false,
    rainbowNameSpeed = 0.1,
    soundboardEnabled = true,
    soundboardVolume = 0.5
}

-- Сохранение конфига
local function saveConfig()
    if writefile then
        pcall(function()
            writefile(ConfigFile, HttpService:JSONEncode(Core.Config))
        end)
    end
end

-- Загрузка конфига
local function loadConfig()
    if readfile and isfile and isfile(ConfigFile) then
        pcall(function()
            local data = HttpService:JSONDecode(readfile(ConfigFile))
            for k, v in pairs(data) do
                Core.Config[k] = v
            end
        end)
    end
end

-- ========== СИСТЕМА УВЕДОМЛЕНИЙ ==========
local notificationContainer = nil
local notificationList = {}

local function createNotificationContainer()
    if notificationContainer then return end
    notificationContainer = Instance.new("ScreenGui")
    notificationContainer.Name = "ServerHubNotifications"
    notificationContainer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    notificationContainer.ResetOnSpawn = false
    notificationContainer.Parent = Player:WaitForChild("PlayerGui")
    
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 340, 0, 0)
    container.Position = UDim2.new(1, -350, 0, 10)
    container.BackgroundTransparency = 1
    container.Parent = notificationContainer
end

function Core.Notify(title, message, notifType, duration)
    if not Core.Config.notificationsEnabled then return end
    duration = duration or 5
    notifType = notifType or "info"
    
    local colors = {
        info = {50, 150, 255},
        success = {0, 255, 0},
        error = {255, 50, 50},
        warning = {255, 150, 0},
        fix = {255, 200, 0}
    }
    
    local color = colors[notifType] or colors.info
    
    createNotificationContainer()
    
    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 320, 0, 60)
    notifFrame.Position = UDim2.new(1, -10, 1, -70)
    notifFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    notifFrame.BackgroundTransparency = 0.1
    notifFrame.BorderSizePixel = 1
    notifFrame.BorderColor3 = Color3.fromRGB(color[1], color[2], color[3])
    notifFrame.ClipsDescendants = true
    notifFrame.Parent = notificationContainer.Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = notifFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 0, 20)
    titleLabel.Position = UDim2.new(0, 5, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(color[1], color[2], color[3])
    titleLabel.TextSize = 13
    titleLabel.Font = Enum.Font.SourceSans
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextWrapped = true
    titleLabel.Parent = notifFrame
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -10, 0, 30)
    messageLabel.Position = UDim2.new(0, 5, 0, 25)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    messageLabel.TextSize = 11
    messageLabel.Font = Enum.Font.SourceSans
    messageLabel.TextWrapped = true
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.Parent = notifFrame
    
    notifFrame:TweenPosition(UDim2.new(1, -330, 1, -70), "Out", "Quad", 0.3, true)
    
    table.insert(notificationList, notifFrame)
    
    task.spawn(function()
        task.wait(duration)
        if notifFrame and notifFrame.Parent then
            notifFrame:TweenPosition(UDim2.new(1, 10, 1, -70), "Out", "Quad", 0.3, true)
            task.wait(0.3)
            notifFrame:Destroy()
        end
        for i, v in ipairs(notificationList) do
            if v == notifFrame then table.remove(notificationList, i) break end
        end
    end)
    
    print(string.format("[ServerHub] [%s] %s: %s", string.upper(notifType), title, message))
end

-- ========== АНТИЧИТ ОБХОД ==========
local oldNamecall = nil
local oldIndex = nil

local function setupAntiCheatBypass()
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        
        if method == "FireServer" then
            local selfStr = tostring(self):lower()
            local blockedKeywords = {"anticheat", "antihack", "byfron", "exploit", "cheat", "hack", "detect", "ban", "report"}
            for _, keyword in ipairs(blockedKeywords) do
                if selfStr:find(keyword) then
                    Core.Stats.remotesBlocked = Core.Stats.remotesBlocked + 1
                    return nil
                end
            end
        end
        
        if method == "InvokeServer" then
            local selfStr = tostring(self):lower()
            if selfStr:find("anticheat") or selfStr:find("ban") then
                return nil
            end
        end
        
        return oldNamecall(self, ...)
    end)
    
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        local blockedKeys = {"HasAntiCheat", "IsCheater", "IsExploiter", "AntiCheat", "CheatDetected"}
        for _, k in ipairs(blockedKeys) do
            if key == k then
                return false
            end
        end
        return oldIndex(self, key)
    end)
    
    Core.Notify("AntiCheat Bypass", "Обход античита активирован | Заблокировано: 0", "success", 4)
end

-- ========== УНИВЕРСАЛЬНЫЙ ФИКСЕР СКРИПТОВ ==========
function Core.FixScript(originalScript)
    if not originalScript or type(originalScript) ~= "string" then
        return nil, "Неверный формат скрипта"
    end
    
    local fixed = originalScript
    local fixes = {}
    
    -- Фикс 1: быстрый wait
    local function fixWait(match)
        local num = tonumber(match) or 0
        if num < 0.1 then
            fixes[#fixes+1] = "Задержка " .. num .. "с → 0.15с"
            return "wait(0.15)"
        end
        return "wait(" .. match .. ")"
    end
    fixed = fixed:gsub("wait%(([0-9.]+)%)", fixWait)
    
    -- Фикс 2: добавление pcall для FireServer
    if fixed:match(":FireServer%(") and not fixed:match("pcall") then
        fixed = fixed:gsub("(.-):FireServer%(([^)]+)%)", function(prefix, args)
            fixes[#fixes+1] = "Добавлен pcall для защиты от ошибок"
            return "pcall(function() " .. prefix .. ":FireServer(" .. args .. ") end)"
        end)
    end
    
    -- Фикс 3: замена getrenv
    if fixed:match("getrenv") then
        fixed = fixed:gsub("getrenv%(%)", "getfenv()")
        fixes[#fixes+1] = "getrenv() → getfenv()"
    end
    
    if fixed:match("getgenv") and not getgenv then
        fixed = fixed:gsub("getgenv%(%)", "getfenv()")
        fixes[#fixes+1] = "getgenv() → getfenv()"
    end
    
    -- Фикс 4: рандомные задержки для дюперов
    if fixed:match("while") and (fixed:match("FireServer") or fixed:match(":Fire")) then
        fixed = fixed:gsub("wait%(([0-9.]+)%)", function()
            local rand = math.random(8, 25) / 100
            fixes[#fixes+1] = "Рандомная задержка " .. rand .. "с (анти-антиспам)"
            return "wait(" .. rand .. ")"
        end)
    end
    
    -- Фикс 5: защита HttpGet
    if fixed:match("game:HttpGet") then
        fixed = fixed:gsub("game:HttpGet%(\"([^\"]+)\"%)", function(url)
            fixes[#fixes+1] = "Добавлена защита HttpGet"
            return "pcall(function() return game:HttpGet('" .. url .. "') end) or ''"
        end)
    end
    
    -- Фикс 6: исправление loadstring
    if fixed:match('loadstring%("%-%-")') then
        fixed = fixed:gsub('loadstring%("%-%-.-%"%)', 'loadstring(game:HttpGet("https://raw.githubusercontent.com/SovietIlyaGG/ServerHub/main/script.lua"))()')
        fixes[#fixes+1] = "Восстановлен loadstring"
    end
    
    Core.Stats.scriptsFixed = Core.Stats.scriptsFixed + 1
    Core.Stats.lastFix = fixes
    
    if #fixes > 0 then
        Core.Notify("Script Fixer", "Применено фиксов: " .. #fixes, "fix", 4)
        for i, fix in ipairs(fixes) do
            print("[ServerHub] Фикс " .. i .. ": " .. fix)
        end
    else
        Core.Notify("Script Fixer", "Скрипт не нуждается в исправлении", "info", 2)
    end
    
    return fixed, fixes
end

-- ========== GHOST MODE ==========
local originalDisplayName = nil
local ghostActive = false
local nameChangeConnection = nil

function Core.EnableGhostMode(enabled)
    ghostActive = enabled
    Core.Config.ghostMode = enabled
    saveConfig()
    
    if not enabled then
        if originalDisplayName and Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.DisplayName = originalDisplayName
        end
        Core.Notify("Ghost Mode", "Режим скрытности отключён", "info", 2)
        return
    end
    
    local function generateRandomName()
        local prefixes = Core.Config.fakeNameList
        local prefix = prefixes[math.random(#prefixes)]
        local num = math.random(100, 999)
        return prefix .. "_" .. num
    end
    
    local newName = Core.Config.fakeName or generateRandomName()
    
    if Core.Config.spoofTab then
        local function applyName()
            if Player.Character and Player.Character:FindFirstChild("Humanoid") then
                local humanoid = Player.Character.Humanoid
                if not originalDisplayName then
                    originalDisplayName = humanoid.DisplayName
                end
                humanoid.DisplayName = newName
            end
        end
        
        applyName()
        
        if nameChangeConnection then nameChangeConnection:Disconnect() end
        nameChangeConnection = Player.CharacterAdded:Connect(applyName)
    end
    
    Core.Notify("Ghost Mode", "Теперь вы: " .. newName, "success", 3)
end

function Core.GenerateNewFakeName()
    local prefixes = Core.Config.fakeNameList
    local newName = prefixes[math.random(#prefixes)] .. "_" .. math.random(100, 999)
    Core.Config.fakeName = newName
    saveConfig()
    
    if Core.Config.ghostMode then
        Core.EnableGhostMode(true)
    end
    
    Core.Notify("Ghost Mode", "Сгенерирован новый ник: " .. newName, "success", 2)
    return newName
end

-- ========== ANTI-CRASH ЗАЩИТА ==========
local function setupAntiCrash()
    if not Core.Config.antiCrashEnabled then return end
    
    local oldKick = Player.Kick
    Player.Kick = function(...)
        Core.Notify("Anti-Crash", "Попытка кика заблокирована!", "success", 3)
        return nil
    end
    
    local oldHttpGet = game.HttpGet
    game.HttpGet = function(url)
        if url and #url > 10000 then
            Core.Notify("Anti-Crash", "Заблокирован вредоносный запрос", "warning", 2)
            return nil
        end
        return oldHttpGet(url)
    end
    
    Core.Notify("Anti-Crash", "Защита от вылетов и киков активирована", "success", 3)
end

-- ========== RAINBOW NAME ==========
local rainbowCoroutine = nil

function Core.EnableRainbowName(enabled)
    Core.Config.rainbowNameEnabled = enabled
    saveConfig()
    
    if rainbowCoroutine then
        task.cancel(rainbowCoroutine)
        rainbowCoroutine = nil
    end
    
    if not enabled then
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.NameColor3 = Color3.fromRGB(255, 255, 255)
        end
        Core.Notify("Rainbow Name", "Переливающийся ник отключён", "info", 2)
        return
    end
    
    rainbowCoroutine = task.spawn(function()
        local hue = 0
        while Core.Config.rainbowNameEnabled and task.wait(Core.Config.rainbowNameSpeed) do
            if Player.Character and Player.Character:FindFirstChild("Humanoid") then
                local color = Color3.fromHSV(hue, 1, 1)
                Player.Character.Humanoid.NameColor3 = color
                hue = hue + 0.02
                if hue > 1 then hue = 0 end
            end
        end
    end)
    
    Core.Notify("Rainbow Name", "Переливающийся ник активирован", "success", 2)
end

-- ========== HYPER TOOL (Wrecker) ==========
Core.HyperTool = {
    active = false,
    connection = nil,
    mouse = nil
}

function Core.HyperTool:Activate()
    if self.active then return end
    self.active = true
    
    self.mouse = Player:GetMouse()
    self.connection = self.mouse.Button1Down:Connect(function()
        local target = self.mouse.Target
        if target and target:IsA("BasePart") and target ~= Player.Character and not target:IsDescendantOf(Player.Character) then
            -- Сохраняем позицию для выпадения игрока
            local occupants = {}
            for _, otherPlayer in ipairs(Players:GetPlayers()) do
                if otherPlayer ~= Player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local rootPart = otherPlayer.Character.HumanoidRootPart
                    if rootPart and (rootPart.Position - target.Position).Magnitude < 10 then
                        table.insert(occupants, otherPlayer)
                    end
                end
            end
            
            target:Destroy()
            Core.Notify("Hyper Tool", "Уничтожено: " .. target.Name, "warning", 2)
            
            -- Выпадение игроков, стоявших на объекте
            for _, victim in ipairs(occupants) do
                if victim.Character and victim.Character:FindFirstChild("HumanoidRootPart") then
                    victim.Character.HumanoidRootPart.CFrame = victim.Character.HumanoidRootPart.CFrame + Vector3.new(0, -15, 0)
                    Core.Notify("Hyper Tool", victim.Name .. " выпал из разрушенной постройки", "warning", 2)
                end
            end
        end
    end)
    
    Core.Notify("Hyper Tool", "Инструмент разрушителя активирован", "success", 2)
end

function Core.HyperTool:Deactivate()
    if not self.active then return end
    if self.connection then
        self.connection:Disconnect()
        self.connection = nil
    end
    self.active = false
    Core.Notify("Hyper Tool", "Инструмент разрушителя деактивирован", "info", 2)
end

function Core.HyperTool:Toggle()
    if self.active then
        self:Deactivate()
    else
        self:Activate()
    end
end

-- ========== СТАТИСТИКА ==========
function Core.GetStats()
    local uptime = os.time() - Core.Stats.startTime
    local hours = math.floor(uptime / 3600)
    local minutes = math.floor((uptime % 3600) / 60)
    local seconds = uptime % 60
    
    return {
        scriptsFixed = Core.Stats.scriptsFixed,
        remotesBlocked = Core.Stats.remotesBlocked,
        bypassAttempts = Core.Stats.bypassAttempts,
        scriptsLoaded = Core.Stats.scriptsLoaded,
        uptime = string.format("%02d:%02d:%02d", hours, minutes, seconds)
    }
end

-- ========== ИНИЦИАЛИЗАЦИЯ ==========
function Core.Init()
    loadConfig()
    pcall(setupAntiCheatBypass)
    pcall(setupAntiCrash)
    
    if Core.Config.ghostMode then
        Core.EnableGhostMode(true)
    end
    
    if Core.Config.rainbowNameEnabled then
        Core.EnableRainbowName(true)
    end
    
    Core.Notify("ServerHub", "Core ядро загружено | Версия 3.0", "success", 3)
    
    print("========================================")
    print("[ServerHub] Core.lua инициализирован")
    print("[ServerHub] Тема: " .. Core.Config.theme)
    print("[ServerHub] Ghost Mode: " .. tostring(Core.Config.ghostMode))
    print("[ServerHub] Rainbow Name: " .. tostring(Core.Config.rainbowNameEnabled))
    print("[ServerHub] Hyper Tool: " .. tostring(Core.Config.hyperToolActive))
    print("========================================")
end

return Core