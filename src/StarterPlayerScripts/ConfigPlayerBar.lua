-- Provides abstractions for interacting with player gui
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local PlayerBarGui = player:WaitForChild("PlayerGui"):WaitForChild("PlayerBarGui").PlayerBarsBackground

local StaminaBar = PlayerBarGui.StaminaBarBackground.StaminaBar
local HealthBar = PlayerBarGui.HealthBarBackground

local ConfigPlayerBar = {}

function ConfigPlayerBar.LessStamina(displayTime: number)
    StaminaBar.BackgroundColor3 = Color3.fromRGB(172, 28, 28)
    task.wait(displayTime)
    StaminaBar.BackgroundColor3 = Color3.fromRGB(0, 149, 223)
end

return ConfigPlayerBar