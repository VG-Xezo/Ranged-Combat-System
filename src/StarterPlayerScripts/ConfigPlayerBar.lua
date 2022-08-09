-- Provides abstractions for interacting with player gui
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local PlayerBarGui = player:WaitForChild("PlayerGui"):WaitForChild("PlayerBarGui").PlayerBarsBackground

local StaminaBar = PlayerBarGui.StaminaBarBackground.StaminaBar
local HealthBar = PlayerBarGui.HealthBarBackground

local ConfigPlayerBar = {}

function ConfigPlayerBar.LessStamina(displayTime: number)
    local ORIGINAL_BAR_COLOR = StaminaBar.BackgroundColor3
    StaminaBar.BackgroundColor3 = Color3.fromRGB(172, 28, 28)
    task.wait(displayTime)
    StaminaBar.BackgroundColor3 = ORIGINAL_BAR_COLOR
end

return ConfigPlayerBar