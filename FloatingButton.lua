-- ============================================
-- ServerHub Floating Button
-- Круглая кнопка открытия/закрытия меню
-- ============================================

local FloatingButton = {}
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local menuOpen = false
local button = nil
local menuRef = nil
local screenGui = nil

local buttonSize = 55
local buttonColor = Color3.fromRGB(0, 200, 0)
local buttonSymbol = "⚡"

function FloatingButton:Create()
    if screenGui then return end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ServerHubButton"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Player:WaitForChild("PlayerGui")
    
    button = Instance.new("ImageButton")
    button.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    button.Position = UDim2.new(0, 15, 0, 100)
    button.BackgroundColor3 = buttonColor
    button.BackgroundTransparency = 0.15
    button.BorderSizePixel = 2
    button.BorderColor3 = buttonColor
    button.Image = "rbxassetid://0"
    button.ClipsDescendants = true
    button.Parent = screenGui
    
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1.2, 0, 1.2, 0)
    shadow.Position = UDim2.new(-0.1, 0, -0.1, 0)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ZIndex = 0
    shadow.Parent = button
    
    local corners = Instance.new("UICorner")
    corners.CornerRadius = UDim.new(1, 0)
    corners.Parent = button
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = buttonSymbol
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextSize = 28
    text.Font = Enum.Font.SourceSansBold
    text.TextScaled = true
    text.TextWrapped = true
    text.Parent = button
    
    button.MouseEnter:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, buttonSize + 5, 0, buttonSize + 5)})
        tween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, buttonSize, 0, buttonSize)})
        tween:Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        if menuOpen then
            self:CloseMenu()
        else
            self:OpenMenu()
        end
    end)
    
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = button.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    button.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            local newX = math.clamp(startPos.X.Offset + delta.X, 0, screenGui.AbsoluteSize.X - buttonSize)
            local newY = math.clamp(startPos.Y.Offset + delta.Y, 0, screenGui.AbsoluteSize.Y - buttonSize)
            button.Position = UDim2.new(0, newX, 0, newY)
        end
    end)
    
    print("[ServerHub] FloatingButton создана")
end

function FloatingButton:OpenMenu()
    if menuRef then
        menuRef.Visible = true
        menuOpen = true
        
        local tween = TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(0, 150, 0)})
        tween:Play()
        
        if button and button.TextLabel then
            button.TextLabel.Text = "✕"
        end
    end
end

function FloatingButton:CloseMenu()
    if menuRef then
        menuRef.Visible = false
        menuOpen = false
        
        local tween = TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = buttonColor})
        tween:Play()
        
        if button and button.TextLabel then
            button.TextLabel.Text = buttonSymbol
        end
    end
end

function FloatingButton:SetMenuReference(menu)
    menuRef = menu
end

function FloatingButton:SetSymbol(symbol)
    buttonSymbol = symbol
    if button and button.TextLabel then
        button.TextLabel.Text = symbol
    end
end

function FloatingButton:SetColor(color)
    buttonColor = color
    if button then
        button.BackgroundColor3 = color
        button.BorderColor3 = color
    end
end

function FloatingButton:Toggle()
    if menuOpen then
        self:CloseMenu()
    else
        self:OpenMenu()
    end
end

return FloatingButton