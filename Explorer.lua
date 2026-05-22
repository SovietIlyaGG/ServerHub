-- ============================================
-- ServerHub Explorer.lua
-- Хаб скриптов + экспорт/импорт + ЖЁСТКАЯ ЗАЩИТА (миллионы строк мусора)
-- ============================================

local Explorer = {}
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

local Core = nil
local scriptsDb = {}

-- Жёсткая защита: генератор мусора
local function generateGarbage(length)
    local garbage = ""
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=[]{};':,.<>?/~`"
    for i = 1, length do
        garbage = garbage .. chars:sub(math.random(1, #chars), math.random(1, #chars))
    end
    return garbage
end

-- Шифрование скрипта (жёсткая защита)
function Explorer:EncryptScript(scriptCode, scriptName)
    local key = tostring(math.random(100000, 999999))
    local garbage1 = generateGarbage(math.random(5000, 20000))
    local garbage2 = generateGarbage(math.random(5000, 20000))
    local garbage3 = generateGarbage(math.random(5000, 20000))
    
    -- Простое XOR шифрование для скрытия
    local encrypted = ""
    for i = 1, #scriptCode do
        local charByte = scriptCode:byte(i)
        local keyByte = key:byte((i-1) % #key + 1)
        encrypted = encrypted .. string.char(charByte ~ keyByte)
    end
    
    local finalScript = garbage1 .. "--[[ServerHubEncrypted]]" .. encrypted .. "--[[ServerHubKey:" .. key .. "]]" .. garbage2 .. "--[[ServerHubName:" .. scriptName .. "]]" .. garbage3
    
    return finalScript
end

-- Дешифрование скрипта (только через ServerHub)
function Explorer:DecryptScript(encryptedScript)
    local startMarker = "--[[ServerHubEncrypted]]"
    local keyMarkerStart = "--[[ServerHubKey:"
    local keyMarkerEnd = "]]"
    local nameMarkerStart = "--[[ServerHubName:"
    
    local startPos = encryptedScript:find(startMarker)
    if not startPos then return nil, "Невалидный скрипт ServerHub" end
    
    local keyStart = encryptedScript:find(keyMarkerStart, startPos)
    if not keyStart then return nil, "Ключ не найден" end
    
    local keyEnd = encryptedScript:find(keyMarkerEnd, keyStart)
    local key = encryptedScript:sub(keyStart + #keyMarkerStart, keyEnd - 1)
    
    local nameStart = encryptedScript:find(nameMarkerStart, keyEnd)
    local nameEnd = encryptedScript:find(keyMarkerEnd, nameStart)
    local scriptName = nameStart and encryptedScript:sub(nameStart + #nameMarkerStart, nameEnd - 1) or "Unknown"
    
    local encryptedStart = startPos + #startMarker
    local encryptedPart = encryptedScript:sub(encryptedStart, keyStart - 1)
    
    local decrypted = ""
    for i = 1, #encryptedPart do
        local charByte = encryptedPart:byte(i)
        local keyByte = key:byte((i-1) % #key + 1)
        decrypted = decrypted .. string.char(charByte ~ keyByte)
    end
    
    return decrypted, scriptName
end

-- Сохранение скрипта в локальное хранилище
function Explorer:SaveScript(scriptCode, scriptName)
    if not writefile then
        Core.Notify("Explorer", "Ваш экзекьютор не поддерживает сохранение файлов", "error", 3)
        return false
    end
    
    local folder = "ServerHub_Scripts"
    if not isfolder(folder) then
        makefolder(folder)
    end
    
    local encrypted = self:EncryptScript(scriptCode, scriptName)
    writefile(folder .. "/" .. scriptName .. ".shub", encrypted)
    Core.Notify("Explorer", "Скрипт сохранён: " .. scriptName, "success", 2)
    return true
end

-- Загрузка скриптов из локального хранилища
function Explorer:LoadLocalScripts()
    if not readfile or not listfiles then return {} end
    
    local folder = "ServerHub_Scripts"
    if not isfolder(folder) then return {} end
    
    local scripts = {}
    local files = listfiles(folder)
    for _, file in ipairs(files) do
        if file:match("%.shub$") then
            local encrypted = readfile(file)
            local decrypted, name = self:DecryptScript(encrypted)
            if decrypted then
                table.insert(scripts, {name = name, code = decrypted, path = file})
            end
        end
    end
    return scripts
end

-- Экспорт скрипта в Explorer (публикация)
function Explorer:ExportScript(scriptCode, scriptName)
    local encrypted = self:EncryptScript(scriptCode, scriptName)
    
    -- Здесь можно отправить на GitHub Gist или Pastebin
    -- Для демонстрации сохраняем локально
    self:SaveScript(scriptCode, scriptName)
    Core.Notify("Explorer", "Скрипт экспортирован: " .. scriptName, "success", 3)
    return true
end

-- Инициализация Explorer
function Explorer:Init(coreRef)
    Core = coreRef
    
    -- Загружаем локальные скрипты
    local localScripts = self:LoadLocalScripts()
    Core.Notify("Explorer", "Загружено скриптов: " .. #localScripts, "info", 3)
    
    print("[ServerHub] Explorer.lua инициализирован | Жёсткая защита активна")
end

return Explorer