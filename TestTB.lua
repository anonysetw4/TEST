-- PCSHOW V3 - ULTIMATE PC SPOOFER
-- Creado para Blade Ball y juegos con detección avanzada.

local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- 1. Engañar TODAS las propiedades de dispositivos
local oldIndex
oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
    if not checkcaller() then
        if self == UserInputService then
            if key == "TouchEnabled" then return false end
            if key == "KeyboardEnabled" then return true end
            if key == "MouseEnabled" then return true end
            if key == "GamepadEnabled" then return false end
            if key == "VREnabled" then return false end
        elseif self == GuiService then
            if key == "IsTenFootInterface" then return false end
        end
    end
    return oldIndex(self, key)
end))

-- 2. Engañar métodos clave (GetLastInputType y ocultar TouchGui a otros scripts)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() then
        if self == UserInputService then
            if method == "GetPlatform" then
                return Enum.Platform.Windows
            elseif method == "GetLastInputType" then
                -- Muchos juegos modernos usan esto para saber tu dispositivo real
                return Enum.UserInputType.Keyboard 
            end
        elseif self == GuiService then
            if method == "IsTenFootInterface" then
                return false
            end
        end
        
        -- Si el juego intenta buscar "TouchGui" para saber si estás en móvil, le devolvemos nil (como si no existiera)
        if method == "FindFirstChild" or method == "WaitForChild" then
            if type(args[1]) == "string" and (args[1] == "TouchGui" or args[1]:lower():match("mobile")) then
                return nil
            end
        end
    end
    
    return oldNamecall(self, ...)
end))

-- 3. Forzar el cursor del ratón en pantalla
UserInputService.MouseIconEnabled = true

-- 4. Bucle infinito e indestructible para ocultar la UI táctil
-- Esto soluciona el problema de que los botones reaparezcan al morir o respawnear
task.spawn(function()
    while task.wait(0.1) do -- Revisa 10 veces por segundo
        local player = Players.LocalPlayer
        if player then
            local pgui = player:FindFirstChild("PlayerGui")
            if pgui then
                -- Ocultar UI nativa de Roblox
                local touch = pgui:FindFirstChild("TouchGui")
                if touch then 
                    touch.Enabled = false 
                end
                
                -- Ocultar botones específicos de Blade Ball
                for _, v in pairs(pgui:GetDescendants()) do
                    if v:IsA("ScreenGui") and v.Name:lower():match("mobile") then
                        v.Enabled = false
                    elseif v:IsA("GuiObject") then
                        local name = v.Name:lower()
                        if name == "mobilejump" or name == "mobiledash" or name == "mobileblock" or name == "jumpbutton" then
                            v.Visible = false
                        end
                    end
                end
            end
        end
    end
end)

print("[PCSHOW V3] Spoof definitivo aplicado. Cursor forzado y TouchGui erradicado.")
