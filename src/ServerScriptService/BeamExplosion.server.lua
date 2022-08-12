-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remote Events/Replicated Storage
local BeamExplosionRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("BeamExplosion")
local ShakeCameraEvent = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("ShakeCamera")

-- Modules
local Sanitychecks = require(game:GetService("ServerScriptService").Sanitychecks)
local UpdateStaminas = require(game:GetService("ServerScriptService").UpdateStaminas)

-- Move vars
local Cooldown = 2.5
local MAX_CAST_DISTANCE = 50
local MOVE_COST = 100
local PlayerDebounces = {}

-- Functions
function BeamExplosion(playerFired: Player, ExplosionPosition: Vector3)
    if table.find(PlayerDebounces, playerFired.Name) == nil then
        local playerHumanoidRootPart = playerFired.Character:FindFirstChild("HumanoidRootPart")

        local inRange = Sanitychecks.checkDistance(playerFired, playerHumanoidRootPart.Position, ExplosionPosition, MAX_CAST_DISTANCE)
        local staminaEnough = UpdateStaminas.decreaseStamina(playerFired, MOVE_COST)
        if not inRange then return end
        if not staminaEnough then return end

        for _, characterModel in pairs(game.Workspace:GetChildren()) do
            if characterModel:IsA("Model") and characterModel ~= playerFired.Character then
                local HumanoidRootPart = characterModel:FindFirstChild("HumanoidRootPart", true)
                local Humanoid = characterModel:FindFirstChild("Humanoid", true)
                if HumanoidRootPart and Humanoid then
                    if (HumanoidRootPart.Position - Vector3.new(ExplosionPosition.X, 1, ExplosionPosition.Z)).Magnitude <= 20 then
                        Humanoid:TakeDamage(10)
                        local characterPlayer = Players:GetPlayerFromCharacter(characterModel)
                        if characterPlayer then
                            ShakeCameraEvent:FireClient(characterPlayer, 2.5)
                        end
                    end
                end
            end
        end

        ShakeCameraEvent:FireClient(playerFired, 2.5)
        BeamExplosionRemote:FireAllClients(Vector3.new(ExplosionPosition.X, 1, ExplosionPosition.Z))

        table.insert(PlayerDebounces, playerFired.Name)
        task.wait(Cooldown)
        PlayerDebounces[table.find(PlayerDebounces, playerFired.Name)] = nil
    end
end

-- Connections
BeamExplosionRemote.OnServerEvent:Connect(BeamExplosion)