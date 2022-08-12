-- Gives player speed and jump boost
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")
local player = Players.LocalPlayer
local Character = player.Character
if not Character then
    player.CharacterAdded:Wait()
    Character = player.Character
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PowerUpRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("PowerUp")
local PlayerStamina = ReplicatedStorage:WaitForChild("StaminasFolder"):WaitForChild(player.UserId)

local humanoid = Character:WaitForChild("Humanoid")
local Animator = humanoid:WaitForChild("Animator")

local PlayerBarModule = require(script.Parent:WaitForChild("ConfigPlayerBar"))

local powerupAnimationTrack = Animator:LoadAnimation(Character:WaitForChild("Animations").PowerupAnimation)
powerupAnimationTrack.Priority = Enum.AnimationPriority.Action

local MOVE_COST = 250

local ACTION_POWERUP = "Power Up"

local ORIGINAL_SPEED = 0

local AttackDebounce = false
local AttackCooldown = 10

local function generatePowerupVfx(playerFired: Player)
    local powerUpAura = ReplicatedStorage:WaitForChild("VFX"):WaitForChild("PowerupAura").PowerupVfx:Clone()
    powerUpAura.Parent = playerFired.Character:FindFirstChild("HumanoidRootPart")
    Debris:AddItem(powerUpAura, 10)
end

local function firePowerUp(actionName: string, inputState: Enum)
    if actionName == ACTION_POWERUP and inputState == Enum.UserInputState.Begin then
        if not AttackDebounce then
            if PlayerStamina.Value < MOVE_COST then
                PlayerBarModule.LessStamina(.25)
                return
            end
            AttackDebounce = true

            powerupAnimationTrack:Play()
            humanoid.WalkSpeed = 0
            PowerUpRemote:FireServer()

            ORIGINAL_SPEED = humanoid.WalkSpeed
			humanoid.WalkSpeed = 0

            PlayerBarModule.AttackCooldown("PowerUp", AttackCooldown)
            AttackDebounce = false
        end
    end
    if actionName == ACTION_POWERUP and inputState == Enum.UserInputState.End then
        if humanoid.WalkSpeed == 0 then
			humanoid.WalkSpeed = ORIGINAL_SPEED
		end
    end
end

PowerUpRemote.OnClientEvent:Connect(generatePowerupVfx)
ContextActionService:BindAction(ACTION_POWERUP, firePowerUp, true, Enum.KeyCode.P)