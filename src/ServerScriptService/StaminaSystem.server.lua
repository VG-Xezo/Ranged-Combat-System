local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StaminasFolder = ReplicatedStorage:WaitForChild("StaminasFolder")

function updateStaminas()
    while true do
        for _, staminaValue in pairs(StaminasFolder:GetChildren()) do
            if staminaValue:IsA("IntValue") then
                if staminaValue.Value < 1000 then
                    staminaValue.Value += 10
                end
            end
            task.wait()
        end
        task.wait(2)
    end
end

local StaminaThread = coroutine.wrap(updateStaminas)
StaminaThread()

Players.PlayerAdded:Connect(function(player: Player)
    local playerStamina = Instance.new("IntValue", StaminasFolder)
    playerStamina.Name = player.UserId
    playerStamina.Value = 1000
end)