local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LightningRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Lightning")
local ShakeCameraEvent = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("ShakeCamera")

local UpdateStaminas = require(game:GetService("ServerScriptService"):WaitForChild("UpdateStaminas"))

local PlayerDebounces = {}

local MOVE_COST = 225
local MAX_RANGE_DISTANCE = 25
local Cooldown = 5

function LightningStrikes(playerFired: Player)
    if table.find(PlayerDebounces, playerFired.Name) == nil then
        local staminaEnough = UpdateStaminas.decreaseStamina(playerFired, MOVE_COST)
        if not staminaEnough then return end

        local playerHumanoidRootPart = playerFired.Character:FindFirstChild("HumanoidRootPart")

        LightningRemote:FireAllClients(playerFired, nil, "Radius")
        ShakeCameraEvent:FireClient(playerFired, 2.5)

        for _, model in pairs(game.Workspace:GetChildren()) do
            if model:IsA("Model") then
                if model ~= playerFired.Character then
                    local ModelHumanoid = model:FindFirstChild("Humanoid")
                    local ModelHumanoidRootPart = model:FindFirstChild("HumanoidRootPart")

                    if ModelHumanoid and ModelHumanoidRootPart then
                        if (playerHumanoidRootPart.Position - ModelHumanoidRootPart.Position).Magnitude < MAX_RANGE_DISTANCE then
                            LightningRemote:FireAllClients(playerFired, model, "Bolt")
                            ModelHumanoid:TakeDamage(15)
                            local characterPlayer = Players:GetPlayerFromCharacter(model)
                            if characterPlayer then
                                ShakeCameraEvent:FireClient(characterPlayer, 2.5)
                            end
                        end
                    end
                end
            end
        end

        
        table.insert(PlayerDebounces, playerFired.Name)
        task.wait(Cooldown)
        PlayerDebounces[table.find(PlayerDebounces, playerFired.Name)] = nil
    end
end

LightningRemote.OnServerEvent:Connect(LightningStrikes)