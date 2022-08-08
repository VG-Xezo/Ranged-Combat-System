local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PowerUpRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("PowerUp")

local Cooldown = 10
local MOVE_COST = 250
local PlayerDebounces = {}

local DEFAULT_SPEED = 16
local DEFAULT_HEIGHT = 7.2

local UpdateStaminas = require(game:GetService("ServerScriptService").UpdateStaminas)

function PowerUp(playerFired: Player)
    if table.find(PlayerDebounces, playerFired.Name) == nil then
        
        local staminaEnough = UpdateStaminas.decreaseStamina(playerFired, MOVE_COST)

        if not staminaEnough then return end

        local Character = playerFired.Character
        if not Character then
            playerFired.CharacterAdded:Wait()
            Character = playerFired.Character
        end

        local Humanoid = Character:FindFirstChild("Humanoid")

        Humanoid.WalkSpeed = DEFAULT_SPEED * 4
        Humanoid.JumpHeight = DEFAULT_HEIGHT * 4

        table.insert(PlayerDebounces, playerFired.Name)
        task.wait(Cooldown)
        Humanoid.WalkSpeed = DEFAULT_SPEED
        Humanoid.JumpHeight = DEFAULT_HEIGHT
        PlayerDebounces[table.find(PlayerDebounces, playerFired.Name)] = nil
    end
end

PowerUpRemote.OnServerEvent:Connect(PowerUp)