-- ============================================
-- ServerHub Menu
-- Главное меню (каркас)
-- ============================================

local Menu = {}
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

local mainFrame = nil
local screenGui = nil
local tabsContainer = nil
local contentContainer = nil
local activeTab = nil
local tabButtons = {}

local menuWidth = 620
local menuHeight = 520

function Menu:Create()
    if screenGui then return mainFrame, tabsContainer, contentContainer end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ServerHubMenu"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Player:WaitForChild("PlayerGui")
    
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, menuWidth, 0, menuHeight)
    mainFrame.Position = UDim2.new(0.5, -menuWidth/2, 0.5, -menuHeight/2)
    mainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    mainFrame.BackgroundTransparency = 0.08
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(0, 200, 0)
    mainFrame.ClipsDescendants = true
    mainFrame.Visible = true
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = mainFrame
    
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1.05, 0, 1.05, 0)
    shadow.Position = UDim2.new(-0.025, 0, -0.025, 0)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ZIndex = 0
    shadow.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 45)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    title.BackgroundTransparency = 0.3
    title.BorderSizePixel = 0
    title.Text = "ServerHub By IlyaHacker | v3.0"
    title.TextColor3 = Color3.fromRGB(0, 255, 0)
    title.TextSize = 16
    title.Font = Enum.Font.SourceSans
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.PaddingLeft = UDim.new(0, 15)
    title.Parent = mainFrame
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0, 45)
    line.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    line.BorderSizePixel = 0
    line.Parent = mainFrame
    
    tabsContainer = Instance.new("ScrollingFrame")
    tabsContainer.Size = UDim2.new(0, 160, 1, -55)
    tabsContainer.Position = UDim2.new(0, 5, 0, 50)
    tabsContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    tabsContainer.BackgroundTransparency = 0.5
    tabsContainer.BorderSizePixel = 0
    tabsContainer.CanvasSize = UDim2.new(0, 0, 0, 500)
    tabsContainer.ScrollBarThickness = 4
    tabsContainer.Parent = mainFrame
    
    contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, -175, 1, -55)
    contentContainer.Position = UDim2.new(0, 170, 0, 50)
    contentContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    contentContainer.BackgroundTransparency = 0.2
    contentContainer.BorderSizePixel = 1
    contentContainer.BorderColor3 = Color3.fromRGB(0, 200, 0)
    contentContainer.Parent = mainFrame
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 6)
    contentCorner.Parent = contentContainer
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -38, 0, 8)
    closeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    closeBtn.BorderSizePixel = 1
    closeBtn.BorderColor3 = Color3.fromRGB(0, 200, 0)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(0, 200, 0)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.SourceSans
    closeBtn.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)
    
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 32, 0, 32)
    minimizeBtn.Position = UDim2.new(1, -75, 0, 8)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    minimizeBtn.BorderSizePixel = 1
    minimizeBtn.BorderColor3 = Color3.fromRGB(0, 200, 0)
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.fromRGB(0, 200, 0)
    minimizeBtn.TextSize = 18
    minimizeBtn.Font = Enum.Font.SourceSans
    minimizeBtn.Parent = mainFrame
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 6)
    minCorner.Parent = minimizeBtn
    
    minimizeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)
    
    local function makeDraggable(frame)
        local dragging = false
        local dragStart = nil
        local startPos = nil
        
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        frame.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                local delta = input.Position - dragStart
                local newX = startPos.X.Offset + delta.X
                local newY = startPos.Y.Offset + delta.Y
                frame.Position = UDim2.new(0, newX, 0, newY)
            end
        end)
    end
    
    makeDraggable(mainFrame)
    
    print("[ServerHub] Menu создано")
    
    return mainFrame, tabsContainer, contentContainer
end

function Menu:SetActiveTab(tabFrame)
    if activeTab then
        activeTab.Visible = false
    end
    if tabFrame then
        tabFrame.Visible = true
        activeTab = tabFrame
    end
end

function Menu:GetContainers()
    return mainFrame, tabsContainer, contentContainer
end

function Menu:Show()
    if mainFrame then
        mainFrame.Visible = true
    end
end

function Menu:Hide()
    if mainFrame then
        mainFrame.Visible = false
    end
end

function Menu:Toggle()
    if mainFrame then
        mainFrame.Visible = not mainFrame.Visible
    end
end

function Menu:AddTabButton(name, tabFrame, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 38)
    btn.Position = UDim2.new(0, 5, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.BackgroundTransparency = 0.4
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(0, 200, 0)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(0, 200, 0)
    btn.TextSize = 13
    btn.Font = Enum.Font.SourceSans
    btn.Parent = tabsContainer
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        for _, b in pairs(tabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            b.BackgroundTransparency = 0.4
        end
        self:SetActiveTab(tabFrame)
        btn.BackgroundColor3 = Color3.fromRGB(0, 80, 0)
        btn.BackgroundTransparency = 0
    end)
    
    table.insert(tabButtons, btn)
    return btn
end

return Menu