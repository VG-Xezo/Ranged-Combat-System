local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local FireballRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Fireball")

local UpdateStaminas = require(game:GetService("ServerScriptService"):WaitForChild("UpdateStaminas"))
local Sanitychecks = require(game:GetService("ServerScriptService"):WaitForChild("Sanitychecks"))

local MOVE_COST = 75
local MAX_CAST_DISTANCE = 75

function Fireball(playerFired: Player, hitPosition: Vector3)

    local staminaEnough = UpdateStaminas.decreaseStamina(playerFired, MOVE_COST)
    local inRange = Sanitychecks.checkDistance(playerFired, playerFired.Character:FindFirstChild("HumanoidRootPart").Position, hitPosition, MAX_CAST_DISTANCE)
    if not staminaEnough then return end
    if not inRange then return end

    local fireballHitbox = Instance.new("Part")
    fireballHitbox.CanCollide = false
    fireballHitbox.Transparency = 1
    fireballHitbox.Shape = Enum.PartType.Ball
    fireballHitbox.Size = Vector3.new(8,8,8)
    fireballHitbox.Position = playerFired.Character:FindFirstChild("HumanoidRootPart").Position
    fireballHitbox.Parent = game.Workspace

    fireballHitbox.Touched:Connect(function(hit)
        if not hit:FindFirstAncestor(playerFired.Character.Name) then
            local humanoid = hit.Parent:FindFirstChild("Humanoid")
            
            if humanoid then
                local debounce = humanoid:FindFirstChild("FireballDebounce".. playerFired.Name)
                if not debounce then
                    humanoid:TakeDamage(10)

                    local FireballDebounce = Instance.new("BoolValue")
                    FireballDebounce.Name = "FireballDebounce" .. playerFired.Name
                    FireballDebounce.Parent = humanoid
                    Debris:AddItem(FireballDebounce, 1)
                end
            end
        end
    end)

    Debris:AddItem(fireballHitbox, 1)
    FireballRemote:FireAllClients(playerFired.Character:FindFirstChild("HumanoidRootPart").Position, hitPosition)
    TweenService:Create(fireballHitbox, TweenInfo.new(1), {Position = hitPosition}):Play()
end

FireballRemote.OnServerEvent:Connect(Fireball)