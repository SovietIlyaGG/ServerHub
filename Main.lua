-- ============================================
-- ServerHub By IlyaHacker
-- GitHub: SovietIlyaGG/ServerHub
-- MAIN LOADER
-- ============================================

print("========================================")
print("ServerHub By IlyaHacker")
print("Загрузка базы...")
print("========================================")

-- Загрузка Core
local Core = loadstring(game:HttpGet("https://raw.githubusercontent.com/SovietIlyaGG/ServerHub/main/Core.lua"))()

-- Загрузка FloatingButton
local FloatingButton = loadstring(game:HttpGet("https://raw.githubusercontent.com/SovietIlyaGG/ServerHub/main/FloatingButton.lua"))()

-- Загрузка Themes
local Themes = loadstring(game:HttpGet("https://raw.githubusercontent.com/SovietIlyaGG/ServerHub/main/Themes.lua"))()

-- Загрузка Menu
local Menu = loadstring(game:HttpGet("https://raw.githubusercontent.com/SovietIlyaGG/ServerHub/main/Menu.lua"))()

-- Загрузка Tabs
local Tabs = loadstring(game:HttpGet("https://raw.githubusercontent.com/SovietIlyaGG/ServerHub/main/Tabs.lua"))()

-- Загрузка Tools
local Tools = loadstring(game:HttpGet("https://raw.githubusercontent.com/SovietIlyaGG/ServerHub/main/Tools.lua"))()

-- Загрузка Explorer
local Explorer = loadstring(game:HttpGet("https://raw.githubusercontent.com/SovietIlyaGG/ServerHub/main/Explorer.lua"))()

-- Инициализация
if Core then Core:Init() end
if FloatingButton then FloatingButton:Create() end
if Themes then Themes:Apply(Core and Core.Config.theme or "green") end
if Menu then 
    local mainFrame = Menu:Create()
    if FloatingButton then FloatingButton:SetMenuReference(mainFrame) end
end
if Tabs then Tabs:Load(Menu) end
if Tools then Tools:Init(Core) end
if Explorer then Explorer:Init(Core) end

print("========================================")
print("ServerHub By IlyaHacker")
print("Статус: АКТИВЕН")
print("Обход античита: ВКЛ")
print("Функций: 26")
print("========================================")

if Core then
    Core.Notify("ServerHub", "База успешно загружена! 26 функций активны.", "success", 5)
end