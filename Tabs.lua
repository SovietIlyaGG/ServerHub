-- ============================================
-- ServerHub Tabs.lua
-- Все вкладки: Settings, Guns, Vehicles, Armor, PlayerList, AboutUs, HyperTool, Soundboard, ServerInfo, RainbowName
-- ============================================

local Tabs = {}
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

local Core = nil
local Menu = nil
local Themes = nil

local activeTabs = {}

function Tabs:Load(menuRef, coreRef, themesRef)
    Menu = menuRef
    Core = coreRef
    Themes = themesRef
    
    local mainFrame, tabsContainer, contentContainer = Menu:GetContainers()
    
    local yOffset = 5
    local tabHeight = 42
    
    -- ========== ВКЛАДКА 1: SETTINGS BASE ==========
    local settingsFrame = Instance.new("ScrollingFrame")
    settingsFrame.Size = UDim2.new(1, -15, 1, -15)
    settingsFrame.Position = UDim2.new(0, 10, 0, 5)
    settingsFrame.BackgroundTransparency = 1
    settingsFrame.BorderSizePixel = 0
    settingsFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
    settingsFrame.ScrollBarThickness = 5
    settingsFrame.Visible = false
    settingsFrame.Parent = contentContainer
    
    local settingsTitle = Instance.new("TextLabel")
    settingsTitle.Size = UDim2.new(1, -20, 0, 30)
    settingsTitle.Position = UDim2.new(0, 10, 0, 5)
    settingsTitle.BackgroundTransparency = 1
    settingsTitle.Text = "⚙️ НАСТРОЙКИ БАЗЫ"
    settingsTitle.TextColor3 = Color3.fromRGB(0, 255, 0)
    settingsTitle.TextSize = 16
    settingsTitle.Font = Enum.Font.SourceSansBold
    settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
    settingsTitle.Parent = settingsFrame
    
    -- Ghost Mode
    local ghostToggle = Instance.new("TextButton")
    ghostToggle.Size = UDim2.new(0.9, 0, 0, 40)
    ghostToggle.Position = UDim2.new(0.05, 0, 0, 45)
    ghostToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ghostToggle.BorderSizePixel = 1
    ghostToggle.BorderColor3 = Color3.fromRGB(0, 200, 0)
    ghostToggle.Text = "👻 Ghost Mode: " .. (Core.Config.ghostMode and "ВКЛ" or "ВЫКЛ")
    ghostToggle.TextColor3 = Color3.fromRGB(0, 200, 0)
    ghostToggle.TextSize = 14
    ghostToggle.Font = Enum.Font.SourceSans
    ghostToggle.Parent = settingsFrame
    
    ghostToggle.MouseButton1Click:Connect(function()
        Core.Config.ghostMode = not Core.Config.ghostMode
        Core.EnableGhostMode(Core.Config.ghostMode)
        ghostToggle.Text = "👻 Ghost Mode: " .. (Core.Config.ghostMode and "ВКЛ" or "ВЫКЛ")
    end)
    
    -- Generate Fake Name
    local genNameBtn = Instance.new("TextButton")
    genNameBtn.Size = UDim2.new(0.9, 0, 0, 35)
    genNameBtn.Position = UDim2.new(0.05, 0, 0, 95)
    genNameBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    genNameBtn.BorderSizePixel = 1
    genNameBtn.BorderColor3 = Color3.fromRGB(0, 200, 0)
    genNameBtn.Text = "🎲 Сгенерировать новый ник"
    genNameBtn.TextColor3 = Color3.fromRGB(0, 200, 0)
    genNameBtn.TextSize = 13
    genNameBtn.Font = Enum.Font.SourceSans
    genNameBtn.Parent = settingsFrame
    
    genNameBtn.MouseButton1Click:Connect(function()
        local newName = Core.GenerateNewFakeName()
        Core.Notify("Ghost Mode", "Новый ник: " .. newName, "success", 2)
    end)
    
    -- Theme Selector
    local themeBtn = Instance.new("TextButton")
    themeBtn.Size = UDim2.new(0.9, 0, 0, 35)
    themeBtn.Position = UDim2.new(0.05, 0, 0, 140)
    themeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    themeBtn.BorderSizePixel = 1
    themeBtn.BorderColor3 = Color3.fromRGB(0, 200, 0)
    themeBtn.Text = "🎨 Тема: " .. (Core.Config.theme == "green" and "Зелёная" or Core.Config.theme == "red" and "Красная" or "Синяя")
    themeBtn.TextColor3 = Color3.fromRGB(0, 200, 0)
    themeBtn.TextSize = 13
    themeBtn.Font = Enum.Font.SourceSans
    themeBtn.Parent = settingsFrame
    
    themeBtn.MouseButton1Click:Connect(function()
        local themes_order = {"green", "red", "blue"}
        local currentIndex = 1
        for i, v in ipairs(themes_order) do
            if v == Core.Config.theme then currentIndex = i break end
        end
        local nextIndex = currentIndex % 3 + 1
        Core.Config.theme = themes_order[nextIndex]
        Themes.Apply(Core.Config.theme)
        Core.SaveConfig()
        themeBtn.Text = "🎨 Тема: " .. (Core.Config.theme == "green" and "Зелёная" or Core.Config.theme == "red" and "Красная" or "Синяя")
    end)
    
    -- Anti-Crash Toggle
    local antiCrashBtn = Instance.new("TextButton")
    antiCrashBtn.Size = UDim2.new(0.9, 0, 0, 35)
    antiCrashBtn.Position = UDim2.new(0.05, 0, 0, 185)
    antiCrashBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    antiCrashBtn.BorderSizePixel = 1
    antiCrashBtn.BorderColor3 = Color3.fromRGB(0, 200, 0)
    antiCrashBtn.Text = "🛡️ Anti-Crash: " .. (Core.Config.antiCrashEnabled and "ВКЛ" or "ВЫКЛ")
    antiCrashBtn.TextColor3 = Color3.fromRGB(0, 200, 0)
    antiCrashBtn.TextSize = 13
    antiCrashBtn.Font = Enum.Font.SourceSans
    antiCrashBtn.Parent = settingsFrame
    
    antiCrashBtn.MouseButton1Click:Connect(function()
        Core.Config.antiCrashEnabled = not Core.Config.antiCrashEnabled
        Core.SaveConfig()
        antiCrashBtn.Text = "🛡️ Anti-Crash: " .. (Core.Config.antiCrashEnabled and "ВКЛ" or "ВЫКЛ")
        Core.Notify("Anti-Crash", "Защита " .. (Core.Config.antiCrashEnabled and "включена" or "выключена"), "info", 2)
    end)
    
    -- Notifications Toggle
    local notifBtn = Instance.new("TextButton")
    notifBtn.Size = UDim2.new(0.9, 0, 0, 35)
    notifBtn.Position = UDim2.new(0.05, 0, 0, 230)
    notifBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    notifBtn.BorderSizePixel = 1
    notifBtn.BorderColor3 = Color3.fromRGB(0, 200, 0)
    notifBtn.Text = "🔔 Уведомления: " .. (Core.Config.notificationsEnabled and "ВКЛ" or "ВЫКЛ")
    notifBtn.TextColor3 = Color3.fromRGB(0, 200, 0)
    notifBtn.TextSize = 13
    notifBtn.Font = Enum.Font.SourceSans
    notifBtn.Parent = settingsFrame
    
    notifBtn.MouseButton1Click:Connect(function()
        Core.Config.notificationsEnabled = not Core.Config.notificationsEnabled
        Core.SaveConfig()
        notifBtn.Text = "🔔 Уведомления: " .. (Core.Config.notificationsEnabled and "ВКЛ" or "ВЫКЛ")
    end)
    
    -- Статистика
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Size = UDim2.new(0.9, 0, 0, 60)
    statsLabel.Position = UDim2.new(0.05, 0, 0, 280)
    statsLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    statsLabel.BorderSizePixel = 1
    statsLabel.BorderColor3 = Color3.fromRGB(0, 200, 0)
    statsLabel.TextColor3 = Color3.fromRGB(0, 200, 0)
    statsLabel.TextSize = 12
    statsLabel.Font = Enum.Font.SourceSans
    statsLabel.TextWrapped = true
    statsLabel.Parent = settingsFrame
    
    local function updateStats()
        local stats = Core.GetStats()
        statsLabel.Text = "📊 СТАТИСТИКА:\nПочинено скриптов: " .. stats.scriptsFixed .. "\nЗаблокировано Remote: " .. stats.remotesBlocked .. "\nВремя работы: " .. stats.uptime
    end
    updateStats()
    task.spawn(function()
        while task.wait(5) do
            if settingsFrame.Visible then updateStats() end
        end
    end)
    
    -- ========== ВКЛАДКА 2: TEST GUNS ==========
    local gunsFrame = Instance.new("ScrollingFrame")
    gunsFrame.Size = UDim2.new(1, -15, 1, -15)
    gunsFrame.Position = UDim2.new(0, 10, 0, 5)
    gunsFrame.BackgroundTransparency = 1
    gunsFrame.BorderSizePixel = 0
    gunsFrame.CanvasSize = UDim2.new(0, 0, 0, 200)
    gunsFrame.ScrollBarThickness = 5
    gunsFrame.Visible = false
    gunsFrame.Parent = contentContainer
    
    local gunsTitle = Instance.new("TextLabel")
    gunsTitle.Size = UDim2.new(1, -20, 0, 30)
    gunsTitle.Position = UDim2.new(0, 10, 0, 5)
    gunsTitle.BackgroundTransparency = 1
    gunsTitle.Text = "🔫 ТЕСТОВОЕ ОРУЖИЕ"
    gunsTitle.TextColor3 = Color3.fromRGB(0, 255, 0)
    gunsTitle.TextSize = 16
    gunsTitle.Font = Enum.Font.SourceSansBold
    gunsTitle.TextXAlignment = Enum.TextXAlignment.Left
    gunsTitle.Parent = gunsFrame
    
    local guns = {"MP5", "M16A4"}
    for i, gun in ipairs(guns) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 45)
        btn.Position = UDim2.new(0.05, 0, 0, 45 + (i-1) * 55)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(0, 200, 0)
        btn.Text = "🔫 " .. gun
        btn.TextColor3 = Color3.fromRGB(0, 200, 0)
        btn.TextSize = 14
        btn.Font = Enum.Font.SourceSans
        btn.Parent = gunsFrame
        
        btn.MouseButton1Click:Connect(function()
            Core.Notify("Test Guns", "Выбрано оружие: " .. gun, "info", 2)
        end)
    end
    
    -- ========== ВКЛАДКА 3: VEHICLES ==========
    local vehiclesFrame = Instance.new("ScrollingFrame")
    vehiclesFrame.Size = UDim2.new(1, -15, 1, -15)
    vehiclesFrame.Position = UDim2.new(0, 10, 0, 5)
    vehiclesFrame.BackgroundTransparency = 1
    vehiclesFrame.BorderSizePixel = 0
    vehiclesFrame.CanvasSize = UDim2.new(0, 0, 0, 150)
    vehiclesFrame.ScrollBarThickness = 5
    vehiclesFrame.Visible = false
    vehiclesFrame.Parent = contentContainer
    
    local vehiclesTitle = Instance.new("TextLabel")
    vehiclesTitle.Size = UDim2.new(1, -20, 0, 30)
    vehiclesTitle.Position = UDim2.new(0, 10, 0, 5)
    vehiclesTitle.BackgroundTransparency = 1
    vehiclesTitle.Text = "🚁 ТЕХНИКА"
    vehiclesTitle.TextColor3 = Color3.fromRGB(0, 255, 0)
    vehiclesTitle.TextSize = 16
    vehiclesTitle.Font = Enum.Font.SourceSansBold
    vehiclesTitle.TextXAlignment = Enum.TextXAlignment.Left
    vehiclesTitle.Parent = vehiclesFrame
    
    local mi8btn = Instance.new("TextButton")
    mi8btn.Size = UDim2.new(0.9, 0, 0, 45)
    mi8btn.Position = UDim2.new(0.05, 0, 0, 45)
    mi8btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mi8btn.BorderSizePixel = 1
    mi8btn.BorderColor3 = Color3.fromRGB(0, 200, 0)
    mi8btn.Text = "🚁 MI-8"
    mi8btn.TextColor3 = Color3.fromRGB(0, 200, 0)
    mi8btn.TextSize = 14
    mi8btn.Font = Enum.Font.SourceSans
    mi8btn.Parent = vehiclesFrame
    
    mi8btn.MouseButton1Click:Connect(function()
        Core.Notify("Vehicles", "Спавн MI-8 (локально)", "info", 2)
    end)
    
    -- ========== ВКЛАДКА 4: ARMOR ==========
    local armorFrame = Instance.new("ScrollingFrame")
    armorFrame.Size = UDim2.new(1, -15, 1, -15)
    armorFrame.Position = UDim2.new(0, 10, 0, 5)
    armorFrame.BackgroundTransparency = 1
    armorFrame.BorderSizePixel = 0
    armorFrame.CanvasSize = UDim2.new(0, 0, 0, 150)
    armorFrame.ScrollBarThickness = 5
    armorFrame.Visible = false
    armorFrame.Parent = contentContainer
    
    local armorTitle = Instance.new("TextLabel")
    armorTitle.Size = UDim2.new(1, -20, 0, 30)
    armorTitle.Position = UDim2.new(0, 10, 0, 5)
    armorTitle.BackgroundTransparency = 1
    armorTitle.Text = "🛡️ ВОЕННАЯ БРОНЯ"
    armorTitle.TextColor3 = Color3.fromRGB(0, 255, 0)
    armorTitle.TextSize = 16
    armorTitle.Font = Enum.Font.SourceSansBold
    armorTitle.TextXAlignment = Enum.TextXAlignment.Left
    armorTitle.Parent = armorFrame
    
    local armorBtn = Instance.new("TextButton")
    armorBtn.Size = UDim2.new(0.9, 0, 0, 45)
    armorBtn.Position = UDim2.new(0.05, 0, 0, 45)
    armorBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    armorBtn.BorderSizePixel = 1
    armorBtn.BorderColor3 = Color3.fromRGB(0, 200, 0)
    armorBtn.Text = "🛡️ Военная броня + шлем"
    armorBtn.TextColor3 = Color3.fromRGB(0, 200, 0)
    armorBtn.TextSize = 13
    armorBtn.Font = Enum.Font.SourceSans
    armorBtn.Parent = armorFrame
    
    armorBtn.MouseButton1Click:Connect(function()
        Core.Notify("Armor", "Военная броня экипирована (локально)", "success", 2)
    end)
    
    -- ========== ВКЛАДКА 5: PLAYER LIST ==========
    local playerListFrame = Instance.new("ScrollingFrame")
    playerListFrame.Size = UDim2.new(1, -15, 1, -15)
    playerListFrame.Position = UDim2.new(0, 10, 0, 5)
    playerListFrame.BackgroundTransparency = 1
    playerListFrame.BorderSizePixel = 0
    playerListFrame.CanvasSize = UDim2.new(0, 0, 0, 400)
    playerListFrame.ScrollBarThickness = 5
    playerListFrame.Visible = false
    playerListFrame.Parent = contentContainer
    
    local playerListTitle = Instance.new("TextLabel")
    playerListTitle.Size = UDim2.new(1, -20, 0, 30)
    playerListTitle.Position = UDim2.new(0, 10, 0, 5)
    playerListTitle.BackgroundTransparency = 1
    playerListTitle.Text = "👥 СПИСОК ИГРОКОВ"
    playerListTitle.TextColor3 = Color3.fromRGB(0, 255, 0)
    playerListTitle.TextSize = 16
    playerListTitle.Font = Enum.Font.SourceSansBold
    playerListTitle.TextXAlignment = Enum.TextXAlignment.Left
    playerListTitle.Parent = playerListFrame
    
    local playerContainer = Instance.new("Frame")
    playerContainer.Size = UDim2.new(1, -10, 0, 0)
    playerContainer.Position = UDim2.new(0, 5, 0, 40)
    playerContainer.BackgroundTransparency = 1
    playerContainer.Parent = playerListFrame
    
    local function updatePlayerList()
        for _, child in ipairs(playerContainer:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        
        local players = Players:GetPlayers()
        local yPos = 0
        
        for _, plr in ipairs(players) do
            local plrFrame = Instance.new("Frame")
            plrFrame.Size = UDim2.new(1, 0, 0, 45)
            plrFrame.Position = UDim2.new(0, 0, 0, yPos)
            plrFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            plrFrame.BorderSizePixel = 1
            plrFrame.BorderColor3 = Color3.fromRGB(0, 200, 0)
            plrFrame.Parent = playerContainer
            
            local plrCorner = Instance.new("UICorner")
            plrCorner.CornerRadius = UDim.new(0, 4)
            plrCorner.Parent = plrFrame
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0.4, 0, 1, 0)
            nameLabel.Position = UDim2.new(0, 10, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = plr.Name
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextSize = 12
            nameLabel.Font = Enum.Font.SourceSans
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = plrFrame
            
            local kickBtn = Instance.new("TextButton")
            kickBtn.Size = UDim2.new(0.15, 0, 0.7, 0)
            kickBtn.Position = UDim2.new(0.42, 0, 0.15, 0)
            kickBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
            kickBtn.BorderSizePixel = 1
            kickBtn.BorderColor3 = Color3.fromRGB(200, 50, 50)
            kickBtn.Text = "Kick"
            kickBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
            kickBtn.TextSize = 11
            kickBtn.Font = Enum.Font.SourceSans
            kickBtn.Parent = plrFrame
            
            kickBtn.MouseButton1Click:Connect(function()
                Core.Notify("Player List", "Попытка кика: " .. plr.Name, "warning", 2)
            end)
            
            local muteBtn = Instance.new("TextButton")
            muteBtn.Size = UDim2.new(0.15, 0, 0.7, 0)
            muteBtn.Position = UDim2.new(0.59, 0, 0.15, 0)
            muteBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            muteBtn.BorderSizePixel = 1
            muteBtn.BorderColor3 = Color3.fromRGB(0, 200, 0)
            muteBtn.Text = "Mute"
            muteBtn.TextColor3 = Color3.fromRGB(0, 200, 0)
            muteBtn.TextSize = 11
            muteBtn.Font = Enum.Font.SourceSans
            muteBtn.Parent = plrFrame
            
            muteBtn.MouseButton1Click:Connect(function()
                Core.Notify("Player List", "Локальный мут: " .. plr.Name, "info", 2)
            end)
            
            local freezeBtn = Instance.new("TextButton")
            freezeBtn.Size = UDim2.new(0.15, 0, 0.7, 0)
            freezeBtn.Position = UDim2.new(0.76, 0, 0.15, 0)
            freezeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
            freezeBtn.BorderSizePixel = 1
            freezeBtn.BorderColor3 = Color3.fromRGB(100, 100, 255)
            freezeBtn.Text = "Freeze"
            freezeBtn.TextColor3 = Color3.fromRGB(100, 100, 255)
            freezeBtn.TextSize = 11
            freezeBtn.Font = Enum.Font.SourceSans
            freezeBtn.Parent = plrFrame
            
            freezeBtn.MouseButton1Click:Connect(function()
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    plr.Character.Humanoid.WalkSpeed = 0
                    Core.Notify("Player List", "Заморожен: " .. plr.Name, "warning", 2)
                end
            end)
            
            yPos = yPos + 52
        end
        
        playerContainer.Size = UDim2.new(1, 0, 0, yPos)
        playerListFrame.CanvasSize = UDim2.new(0, 0, 0, yPos + 50)
    end
    
    updatePlayerList()
    Players.PlayerAdded:Connect(updatePlayerList)
    Players.PlayerRemoving:Connect(updatePlayerList)
    task.spawn(function()
        while task.wait(3) do
            if playerListFrame.Visible then updatePlayerList() end
        end
    end)
    
    -- ========== ВКЛАДКА 6: ABOUT US ==========
    local aboutFrame = Instance.new("Frame")
    aboutFrame.Size = UDim2.new(1, -15, 1, -15)
    aboutFrame.Position = UDim2.new(0, 10, 0, 5)
    aboutFrame.BackgroundTransparency = 1
    aboutFrame.Visible = false
    aboutFrame.Parent = contentContainer
    
    local aboutText = Instance.new("TextLabel")
    aboutText.Size = UDim2.new(1, -20, 1, -20)
    aboutText.Position = UDim2.new(0, 10, 0, 10)
    aboutText.BackgroundTransparency = 1
    aboutText.Text = [[
╔══════════════════════════════════════════════════════════════╗
║                     SERVERHUB BY ILYAHACKER                   ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  This base is created by IlyaHacker to bypass all           ║
║  anti-cheats and account bans + support for your own        ║
║  scripts. The most important addition is in the code lines. ║
║                                                              ║
║  Features:                                                  ║
║  • AntiCheat Bypass                                         ║
║  • Script Fixer (auto-repair non-working scripts)           ║
║  • Ghost Mode (spoof nickname)                              ║
║  • Hyper Tool (destroy buildings + fall)                    ║
║  • Rainbow Name + Themes + Crosshair                        ║
║  • Script Explorer with encryption                          ║
║                                                              ║
║  GitHub: SovietIlyaGG/ServerHub                             ║
║  Version: 3.0                                               ║
║  Status: ACTIVE                                             ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
]]
    aboutText.TextColor3 = Color3.fromRGB(0, 200, 0)
    aboutText.TextSize = 11
    aboutText.Font = Enum.Font.SourceSans
    aboutText.TextWrapped = true
    aboutText.Parent = aboutFrame
    
    -- ========== ВКЛАДКА 7: HYPER TOOL ==========
    local hyperFrame = Instance.new("Frame")
    hyperFrame.Size = UDim2.new(1, -15, 1, -15)
    hyperFrame.Position = UDim2.new(0, 10, 0, 5)
    hyperFrame.BackgroundTransparency = 1
    hyperFrame.Visible = false
    hyperFrame.Parent = contentContainer
    
    local hyperTitle = Instance.new("TextLabel")
    hyperTitle.Size = UDim2.new(1, -20, 0, 30)
    hyperTitle.Position = UDim2.new(0, 10, 0, 5)
    hyperTitle.BackgroundTransparency = 1
    hyperTitle.Text = "🔨 HYPER TOOL (Разрушитель)"
    hyperTitle.TextColor3 = Color3.fromRGB(0, 255, 0)
    hyperTitle.TextSize = 16
    hyperTitle.Font = Enum.Font.SourceSansBold
    hyperTitle.TextXAlignment = Enum.TextXAlignment.Left
    hyperTitle.Parent = hyperFrame
    
    local hyperActive = false
    local hyperBtn = Instance.new("TextButton")
    hyperBtn.Size = UDim2.new(0.8, 0, 0, 55)
    hyperBtn.Position = UDim2.new(0.1, 0, 0, 50)
    hyperBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    hyperBtn.BorderSizePixel = 2
    hyperBtn.BorderColor3 = Color3.fromRGB(0, 200, 0)
    hyperBtn.Text = "🔨 АКТИВИРОВАТЬ HYPER TOOL"
    hyperBtn.TextColor3 = Color3.fromRGB(0, 200, 0)
    hyperBtn.TextSize = 14
    hyperBtn.Font = Enum.Font.SourceSansBold
    hyperBtn.Parent = hyperFrame
    
    hyperBtn.MouseButton1Click:Connect(function()
        if hyperActive then
            Core.HyperTool:Deactivate()
            hyperActive = false
            hyperBtn.Text = "🔨 АКТИВИРОВАТЬ HYPER TOOL"
            hyperBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        else
            Core.HyperTool:Activate()
            hyperActive = true
            hyperBtn.Text = "❌ ДЕАКТИВИРОВАТЬ HYPER TOOL"
            hyperBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
        end
    end)
    
    local hyperInfo = Instance.new("TextLabel")
    hyperInfo.Size = UDim2.new(0.9, 0, 0, 60)
    hyperInfo.Position = UDim2.new(0.05, 0, 0, 120)
    hyperInfo.BackgroundTransparency = 1
    hyperInfo.Text = "Кликни по любой постройке левой кнопкой мыши\nчтобы уничтожить её. Игрок на постройке выпадет."
    hyperInfo.TextColor3 = Color3.fromRGB(150, 150, 150)
    hyperInfo.TextSize = 11
    hyperInfo.Font = Enum.Font.SourceSans
    hyperInfo.TextWrapped = true
    hyperInfo.Parent = hyperFrame
    
    -- ========== ВКЛАДКА 8: RAINBOW NAME ==========
    local rainbowFrame = Instance.new("Frame")
    rainbowFrame.Size = UDim2.new(1, -15, 1, -15)
    rainbowFrame.Position = UDim2.new(0, 10, 0, 5)
    rainbowFrame.BackgroundTransparency = 1
    rainbowFrame.Visible = false
    rainbowFrame.Parent = contentContainer
    
    local rainbowTitle = Instance.new("TextLabel")
    rainbowTitle.Size = UDim2.new(1, -20, 0, 30)
    rainbowTitle.Position = UDim2.new(0, 10, 0, 5)
    rainbowTitle.BackgroundTransparency = 1
    rainbowTitle.Text = "🌈 RAINBOW NAME"
    rainbowTitle.TextColor3 = Color3.fromRGB(0, 255, 0)
    rainbowTitle.TextSize = 16
    rainbowTitle.Font = Enum.Font.SourceSansBold
    rainbowTitle.TextXAlignment = Enum.TextXAlignment.Left
    rainbowTitle.Parent = rainbowFrame
    
    local rainbowActive = Core.Config.rainbowNameEnabled
    local rainbowBtn = Instance.new("TextButton")
    rainbowBtn.Size = UDim2.new(0.8, 0, 0, 55)
    rainbowBtn.Position = UDim2.new(0.1, 0, 0, 50)
    rainbowBtn.BackgroundColor3 = rainbowActive and Color3.fromRGB(50, 30, 30) or Color3.fromRGB(30, 30, 30)
    rainbowBtn.BorderSizePixel = 2
    rainbowBtn.BorderColor3 = Color3.fromRGB(0, 200, 0)
    rainbowBtn.Text = rainbowActive and "❌ ОТКЛЮЧИТЬ RAINBOW NAME" or "🌈 ВКЛЮЧИТЬ RAINBOW NAME"
    rainbowBtn.TextColor3 = Color3.fromRGB(0, 200, 0)
    rainbowBtn.TextSize = 14
    rainbowBtn.Font = Enum.Font.SourceSansBold
    rainbowBtn.Parent = rainbowFrame
    
    rainbowBtn.MouseButton1Click:Connect(function()
        rainbowActive = not rainbowActive
        Core.EnableRainbowName(rainbowActive)
        rainbowBtn.Text = rainbowActive and "❌ ОТКЛЮЧИТЬ RAINBOW NAME" or "🌈 ВКЛЮЧИТЬ RAINBOW NAME"
        rainbowBtn.BackgroundColor3 = rainbowActive and Color3.fromRGB(50, 30, 30) or Color3.fromRGB(30, 30, 30)
    end)
    
    -- Создание кнопок вкладок
    local tabs_data = {
        {name = "⚙️ Settings", frame = settingsFrame},
        {name = "🔫 Guns", frame = gunsFrame},
        {name = "🚁 Vehicles", frame = vehiclesFrame},
        {name = "🛡️ Armor", frame = armorFrame},
        {name = "👥 Player List", frame = playerListFrame},
        {name = "🔨 Hyper Tool", frame = hyperFrame},
        {name = "🌈 Rainbow", frame = rainbowFrame},
        {name = "ℹ️ About Us", frame = aboutFrame}
    }
    
    local yOff = 5
    for _, tab in ipairs(tabs_data) do
        local btn = Menu:AddTabButton(tab.name, tab.frame, yOff)
        yOff = yOff + tabHeight + 5
        table.insert(activeTabs, btn)
    end
    
    tabsContainer.CanvasSize = UDim2.new(0, 0, 0, yOff + 20)
    
    -- Активация первой вкладки
    Menu:SetActiveTab(settingsFrame)
    if activeTabs[1] then
        activeTabs[1].BackgroundColor3 = Color3.fromRGB(0, 80, 0)
        activeTabs[1].BackgroundTransparency = 0
    end
    
    print("[ServerHub] Tabs.lua загружен | Вкладок: " .. #tabs_data)
end

return Tabs