-- Provides abstractions for interacting with player gui
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local PlayerBarGui = player:WaitForChild("PlayerGui"):WaitForChild("PlayerBarGui").PlayerBarsBackground

local StaminaBar = PlayerBarGui.StaminaBarBackground.StaminaBar
local HealthBar = PlayerBarGui.HealthBarBackground

local MoveIcons = player:WaitForChild("PlayerGui"):WaitForChild("PlayerBarGui"):WaitForChild("MoveIcons")

local ConfigPlayerBar = {}

function ConfigPlayerBar.LessStamina(displayTime: number)
    StaminaBar.BackgroundColor3 = Color3.fromRGB(172, 28, 28)
    task.wait(displayTime)
    StaminaBar.BackgroundColor3 = Color3.fromRGB(0, 149, 223)
end

function ConfigPlayerBar.AttackCooldown(attackType: string, cooldown: number)
    local FireballMove = MoveIcons:WaitForChild(attackType .. "Move")

    FireballMove.CooldownFrame.Size = UDim2.new(1,0,1,0)
    for i = 10, 0, -1 do
        local TargetSize = UDim2.new(1, 0, i/10, 0)
        TweenService:Create(FireballMove.CooldownFrame, TweenInfo.new(cooldown/10), {Size = TargetSize}):Play()
        task.wait(cooldown/10)
    end
end

return ConfigPlayerBar