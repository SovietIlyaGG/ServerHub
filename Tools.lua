-- ============================================
-- ServerHub Tools.lua
-- Дополнительные инструменты: Crosshair Customizer, Anti-Crash, Quick Actions, Macro Recorder, Friend/Foe System
-- ============================================

local Tools = {}
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Core = nil
local crosshairEnabled = false
local crosshairGui = nil
local crosshairFrame = nil

function Tools:Init(coreRef)
    Core = coreRef
    
    -- Crosshair Customizer
    if Core.Config.crosshairEnabled then
        self:EnableCrosshair(true)
    end
    
    print("[ServerHub] Tools.lua инициализирован")
end

function Tools:EnableCrosshair(enabled)
    crosshairEnabled = enabled
    
    if not enabled and crosshairGui then
        crosshairGui:Destroy()
        crosshairGui = nil
        return
    end
    
    if not crosshairGui then
        crosshairGui = Instance.new("ScreenGui")
        crosshairGui.Name = "ServerHubCrosshair"
        crosshairGui.ResetOnSpawn = false
        crosshairGui.Parent = Player:WaitForChild("PlayerGui")
        
        local size = 20
        local color = Core.Config.crosshairColor == "green" and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(0, 200, 0)
        
        crosshairFrame = Instance.new("Frame")
        crosshairFrame.Size = UDim2.new(0, size, 0, size)
        crosshairFrame.Position = UDim2.new(0.5, -size/2, 0.5, -size/2)
        crosshairFrame.BackgroundTransparency = 1
        crosshairFrame.Parent = crosshairGui
        
        local lineH = Instance.new("Frame")
        lineH.Size = UDim2.new(0, size, 0, 2)
        lineH.Position = UDim2.new(0, 0, 0.5, -1)
        lineH.BackgroundColor3 = color
        lineH.BorderSizePixel = 0
        lineH.Parent = crosshairFrame
        
        local lineV = Instance.new("Frame")
        lineV.Size = UDim2.new(0, 2, 0, size)
        lineV.Position = UDim2.new(0.5, -1, 0, 0)
        lineV.BackgroundColor3 = color
        lineV.BorderSizePixel = 0
        lineV.Parent = crosshairFrame
    end
end

function Tools:SetCrosshairColor(color)
    if crosshairFrame then
        for _, child in ipairs(crosshairFrame:GetChildren()) do
            if child:IsA("Frame") then
                child.BackgroundColor3 = color
            end
        end
    end
end

-- Quick Actions Bar (плавающая панель)
local quickBar = nil
local quickBarOpen = true

function Tools:CreateQuickActionsBar()
    if quickBar then return end
    
    local barGui = Instance.new("ScreenGui")
    barGui.Name = "ServerHubQuickBar"
    barGui.ResetOnSpawn = false
    barGui.Parent = Player:WaitForChild("PlayerGui")
    
    quickBar = Instance.new("Frame")
    quickBar.Size = UDim2.new(0, 200, 0, 45)
    quickBar.Position = UDim2.new(0.5, -100, 1, -55)
    quickBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    quickBar.BackgroundTransparency = 0.15
    quickBar.BorderSizePixel = 1
    quickBar.BorderColor3 = Color3.fromRGB(0, 200, 0)
    quickBar.Parent = barGui
    
    local actions = {
        {name = "🔨", tooltip = "Hyper Tool", action = function() Core.HyperTool:Toggle() end},
        {name = "👻", tooltip = "Ghost Mode", action = function() Core.EnableGhostMode(not Core.Config.ghostMode) end},
        {name = "🎨", tooltip = "Theme", action = function() end},
        {name = "✕", tooltip = "Close", action = function() quickBar.Visible = false end}
    }
    
    local btnWidth = 40
    for i, action in ipairs(actions) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, btnWidth, 0, 35)
        btn.Position = UDim2.new(0, 5 + (i-1) * (btnWidth + 5), 0, 5)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(0, 200, 0)
        btn.Text = action.name
        btn.TextColor3 = Color3.fromRGB(0, 200, 0)
        btn.TextSize = 18
        btn.Font = Enum.Font.SourceSans
        btn.Parent = quickBar
        
        btn.MouseButton1Click:Connect(action.action)
    end
end

-- Macro Recorder
local macroRecording = false
local macroActions = {}
local macroPlaying = false

function Tools:StartMacroRecording()
    macroRecording = true
    macroActions = {}
    Core.Notify("Macro Recorder", "Запись макроса начата", "info", 2)
end

function Tools:StopMacroRecording()
    macroRecording = false
    Core.Notify("Macro Recorder", "Запись остановлена. Действий: " .. #macroActions, "success", 2)
end

function Tools:PlayMacro()
    if #macroActions == 0 then
        Core.Notify("Macro Recorder", "Нет записанных действий", "warning", 2)
        return
    end
    
    macroPlaying = true
    Core.Notify("Macro Recorder", "Воспроизведение макроса...", "info", 2)
    
    task.spawn(function()
        for _, action in ipairs(macroActions) do
            if not macroPlaying then break end
            task.wait(action.delay)
            pcall(action.func)
        end
        macroPlaying = false
        Core.Notify("Macro Recorder", "Воспроизведение завершено", "success", 2)
    end)
end

function Tools:StopMacro()
    macroPlaying = false
    Core.Notify("Macro Recorder", "Воспроизведение остановлено", "info", 2)
end

return Tools