-- Gives player speed and jump boost
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local player = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PowerUpRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("PowerUp")
local PlayerStamina = ReplicatedStorage:WaitForChild("StaminasFolder"):WaitForChild(player.UserId)

local MOVE_COST = 250

local ACTION_POWERUP = "Power Up"

local AttackDebounce = false

local function firePowerUp(actionName: string, inputState: Enum)
    if actionName == ACTION_POWERUP and inputState == Enum.UserInputState.Begin then
        if not AttackDebounce then
            AttackDebounce = true
            if PlayerStamina.Value < MOVE_COST then return end

            PowerUpRemote:FireServer()

            task.wait(10)
            AttackDebounce = false
        end
    end
end

ContextActionService:BindAction(ACTION_POWERUP, firePowerUp, true, Enum.KeyCode.P)