-- ============================================
-- ServerHub Themes
-- Зелёная / Красная / Синяя тема
-- ============================================

local Themes = {}

local themes = {
    green = {
        name = "Green",
        primary = Color3.fromRGB(0, 200, 0),
        secondary = Color3.fromRGB(0, 100, 0),
        background = Color3.fromRGB(8, 8, 8),
        text = Color3.fromRGB(0, 255, 0),
        border = Color3.fromRGB(0, 200, 0),
        button = Color3.fromRGB(25, 25, 25),
        buttonHover = Color3.fromRGB(0, 80, 0)
    },
    red = {
        name = "Red",
        primary = Color3.fromRGB(200, 0, 0),
        secondary = Color3.fromRGB(100, 0, 0),
        background = Color3.fromRGB(8, 8, 8),
        text = Color3.fromRGB(255, 0, 0),
        border = Color3.fromRGB(200, 0, 0),
        button = Color3.fromRGB(25, 25, 25),
        buttonHover = Color3.fromRGB(80, 0, 0)
    },
    blue = {
        name = "Blue",
        primary = Color3.fromRGB(0, 100, 255),
        secondary = Color3.fromRGB(0, 50, 128),
        background = Color3.fromRGB(8, 8, 8),
        text = Color3.fromRGB(0, 150, 255),
        border = Color3.fromRGB(0, 100, 255),
        button = Color3.fromRGB(25, 25, 25),
        buttonHover = Color3.fromRGB(0, 50, 128)
    }
}

local currentTheme = "green"
local guiElements = {}

function Themes.Apply(themeName)
    local theme = themes[themeName]
    if not theme then return end
    
    currentTheme = themeName
    
    for _, element in ipairs(guiElements) do
        if element.type == "frame" and element.frame then
            if element.isMain then
                element.frame.BorderColor3 = theme.border
            end
        elseif element.type == "text" and element.label then
            if element.isTitle then
                element.label.TextColor3 = theme.text
            end
        elseif element.type == "button" and element.button then
            element.button.BorderColor3 = theme.border
            element.button.TextColor3 = theme.text
        end
    end
    
    print("[ServerHub] Применена тема: " .. theme.name)
end

function Themes.RegisterFrame(frame, isMain)
    table.insert(guiElements, {type = "frame", frame = frame, isMain = isMain})
end

function Themes.RegisterText(label, isTitle)
    table.insert(guiElements, {type = "text", label = label, isTitle = isTitle})
end

function Themes.RegisterButton(button)
    table.insert(guiElements, {type = "button", button = button})
end

function Themes.GetCurrent()
    return themes[currentTheme]
end

function Themes.GetAll()
    return themes
end

function Themes.GetThemeNames()
    local names = {}
    for name, _ in pairs(themes) do
        table.insert(names, name)
    end
    return names
end

return Themes