-- PCSHOW V2 - REAL TIME AGGRESSIVE SPOOF
-- Este script falsifica la plataforma a un nivel más bajo y agresivo para juegos como Blade Ball.

local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")

-- 1. Engañar las propiedades y llamadas a nivel bajo (Metamethods)
local oldIndex
oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
    if not checkcaller() then
        if self == UserInputService then
            if key == "TouchEnabled" then return false end
            if key == "KeyboardEnabled" then return true end
            if key == "MouseEnabled" then return true end
            if key == "GamepadEnabled" then return false end
        elseif self == GuiService then
            if key == "IsTenFootInterface" then return false end
        end
    end
    return oldIndex(self, key)
end))

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    
    if not checkcaller() then
        if self == UserInputService and method == "GetPlatform" then
            return Enum.Platform.Windows
        elseif self == GuiService and method == "IsTenFootInterface" then
            return false
        end
    end
    return oldNamecall(self, ...)
end))

-- 2. Limpieza Agresiva de UI Móvil en Tiempo Real
local player = Players.LocalPlayer

local function killMobileUI()
    if not player then return end
    local pgui = player:FindFirstChild("PlayerGui")
    if not pgui then return end
    
    -- Destruir o deshabilitar TouchGui (interfaz nativa de Roblox)
    local touch = pgui:FindFirstChild("TouchGui")
    if touch then
        touch.Enabled = false
    end
    
    -- Ocultar botones específicos de juegos como Blade Ball (Mobile UI)
    for _, v in pairs(pgui:GetDescendants()) do
        if v:IsA("ScreenGui") then
            local name = v.Name:lower()
            if name:match("mobile") or name:match("touchgui") then
                v.Enabled = false
            end
        elseif v:IsA("GuiObject") then
            local name = v.Name:lower()
            -- Busca botones de dash, block o salto diseñados para móvil
            if name:match("mobile") or name:match("touch") or name == "jumpbutton" then
                v.Visible = false
            end
        end
    end
end

-- Ejecutar la limpieza inmediatamente
task.spawn(killMobileUI)

-- Ejecutar la limpieza cada vez que el juego intente crear un nuevo botón (útil al reaparecer o cargar UI tarde)
if player then
    local pgui = player:WaitForChild("PlayerGui", 5)
    if pgui then
        pgui.DescendantAdded:Connect(function()
            task.wait() -- Esperar a que el elemento se cargue por completo
            killMobileUI()
        end)
    end
end

print("[PCSHOW V2] Spoof agresivo en tiempo real aplicado.")
