-- Remote Events/Replicated Storage
local StaminasFolder = game:GetService("ReplicatedStorage"):WaitForChild("StaminasFolder")

-- Module functions
local UpdateStaminas = {}

function UpdateStaminas.decreaseStamina(player: Player, amount: number)
    local playerStamina = StaminasFolder:FindFirstChild(player.UserId)

    if playerStamina and playerStamina.Value >= amount then
        playerStamina.Value -= amount
        return true
    else
        return false
    end
end

return UpdateStaminas