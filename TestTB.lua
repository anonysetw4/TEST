-- PCSHOW.lua
-- Script para hacer que un dispositivo móvil aparezca como PC en Blade Ball (y otros juegos de Roblox)

local UserInputService = game:GetService("UserInputService")

-- 1. Engañar al juego cambiando las propiedades de UserInputService
local oldIndex
oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
    if not checkcaller() then
        if self == UserInputService then
            if key == "TouchEnabled" then
                return false -- Finge que no tiene pantalla táctil
            elseif key == "KeyboardEnabled" then
                return true  -- Finge que tiene teclado
            elseif key == "MouseEnabled" then
                return true  -- Finge que tiene ratón
            elseif key == "GamepadEnabled" then
                return false -- Finge que no es consola
            end
        end
    end
    return oldIndex(self, key)
end))

-- 2. Engañar a los métodos (por si el juego usa GetPlatform)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    
    if not checkcaller() then
        if self == UserInputService then
            if method == "GetPlatform" then
                return Enum.Platform.Windows -- Responde que es Windows
            end
        end
    end
    
    return oldNamecall(self, ...)
end))

-- 3. Ocultar la interfaz táctil por defecto de Roblox
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function hideTouchGui()
    if LocalPlayer then
        local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
        if PlayerGui then
            local TouchGui = PlayerGui:FindFirstChild("TouchGui")
            if TouchGui then
                TouchGui.Enabled = false
            end
            
            -- Asegurarse de ocultarlo si se carga después
            PlayerGui.ChildAdded:Connect(function(child)
                if child.Name == "TouchGui" then
                    task.wait()
                    child.Enabled = false
                end
            end)
        end
    end
end

task.spawn(hideTouchGui)

print("[PCSHOW] Sistema camuflado. El juego ahora piensa que estás en PC.")
