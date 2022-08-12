local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LaserRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Laser")
local ShakeCameraEvent = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("ShakeCamera")

local MOVE_COST = 10
local MAX_CAST_DISTANCE = 100
local Cooldown = 0.1
local PlayerDebounces = {}

local UpdateStaminas = require(game:GetService("ServerScriptService"):WaitForChild("UpdateStaminas"))
local Sanitychecks = require(game:GetService("ServerScriptService").Sanitychecks)

function LaserBeam(playerFired: Player, hitPosition: Vector3, hitCharacter: Model)
    if table.find(PlayerDebounces, playerFired.Name) == nil then
        local staminaEnough = UpdateStaminas.decreaseStamina(playerFired, MOVE_COST)
        local inRange = Sanitychecks.checkDistance(playerFired, playerFired.Character:FindFirstChild("HumanoidRootPart").Position, hitPosition, MAX_CAST_DISTANCE)

        if not staminaEnough then return end
        if not inRange then return end

        if hitCharacter then
            local hitCharacterHumanoid = hitCharacter:FindFirstChild("Humanoid")
            local characterPlayer = Players:GetPlayerFromCharacter(hitCharacter)
            if characterPlayer then
                ShakeCameraEvent:FireClient(characterPlayer, 2.5)
            end
            hitCharacterHumanoid:TakeDamage(2)
        end

        LaserRemote:FireAllClients(playerFired, hitPosition)
        ShakeCameraEvent:FireClient(playerFired, 0.1)

        table.insert(PlayerDebounces, playerFired.Name)
        task.wait(Cooldown)
        PlayerDebounces[table.find(PlayerDebounces, playerFired.Name)] = nil
    end
end

LaserRemote.OnServerEvent:Connect(LaserBeam)