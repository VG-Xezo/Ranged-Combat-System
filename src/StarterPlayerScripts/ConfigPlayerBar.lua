-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Player vars
local player = Players.LocalPlayer

-- Gui vars
local PlayerBarGui = player:WaitForChild("PlayerGui"):WaitForChild("PlayerBarGui").PlayerBarsBackground
local StaminaBar = PlayerBarGui.StaminaBarBackground.StaminaBar
local HealthBar = PlayerBarGui.HealthBarBackground
local MoveIcons = player:WaitForChild("PlayerGui"):WaitForChild("PlayerBarGui"):WaitForChild("MoveIcons")

-- Module functions
local ConfigPlayerBar = {}

function ConfigPlayerBar.LessStamina(displayTime: number)
    StaminaBar.BackgroundColor3 = Color3.fromRGB(172, 28, 28)
    task.wait(displayTime)
    StaminaBar.BackgroundColor3 = Color3.fromRGB(0, 149, 223)
end

function ConfigPlayerBar.AttackCooldown(attackType: string, cooldown: number)
    local MoveFrame = MoveIcons:WaitForChild(attackType .. "Move")
    MoveFrame.CooldownFrame.Size = UDim2.new(1,0,1,0)
    
    for i = 10, 0, -1 do
        local TargetSize = UDim2.new(1, 0, i/10, 0)
        TweenService:Create(MoveFrame.CooldownFrame, TweenInfo.new(cooldown/10), {Size = TargetSize}):Play()
        task.wait(cooldown/10)
    end
end

return ConfigPlayerBar