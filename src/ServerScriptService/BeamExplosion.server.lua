local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local BeamExplosionRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("BeamExplosion")

local Cooldown = 2.5
local MAX_CAST_DISTANCE = 50
local MOVE_COST = 100
local PlayerDebounces = {}

local Sanitychecks = require(game:GetService("ServerScriptService").Sanitychecks)
local UpdateStaminas = require(game:GetService("ServerScriptService").UpdateStaminas)

function BeamExplosion(playerFired: Player, ExplosionPosition: Vector3)
    if table.find(PlayerDebounces, playerFired.Name) == nil then
        
        local playerHumanoidRootPart = playerFired.Character:FindFirstChild("HumanoidRootPart")

        local inRange = Sanitychecks.checkDistance(playerFired, playerHumanoidRootPart.Position, ExplosionPosition, MAX_CAST_DISTANCE)
        local staminaEnough = UpdateStaminas.decreaseStamina(playerFired, MOVE_COST)


        if not inRange then return end
        if not staminaEnough then return end

        -- Create Hitbox
        for _, characterModel in pairs(game.Workspace:GetChildren()) do
            if characterModel:IsA("Model") and characterModel ~= playerFired.Character then
                local HumanoidRootPart = characterModel:FindFirstChild("HumanoidRootPart", true)
                local Humanoid = characterModel:FindFirstChild("Humanoid", true)
                if HumanoidRootPart and Humanoid then
                    if (HumanoidRootPart.Position - Vector3.new(ExplosionPosition.X, 1, ExplosionPosition.Z)).Magnitude <= 20 then
                        Humanoid:TakeDamage(10)
                    end
                end
            end
        end


        BeamExplosionRemote:FireAllClients(Vector3.new(ExplosionPosition.X, 1, ExplosionPosition.Z))

        table.insert(PlayerDebounces, playerFired.Name)
        task.wait(Cooldown)
        PlayerDebounces[table.find(PlayerDebounces, playerFired.Name)] = nil
    end
end

BeamExplosionRemote.OnServerEvent:Connect(BeamExplosion)