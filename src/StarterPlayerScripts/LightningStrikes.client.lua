-- Services
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

-- Player vars
local player = Players.LocalPlayer
local Character = player.Character
if not Character then
    player.CharacterAdded:Wait()
    Character = player.Character
end
local humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Animator = humanoid:WaitForChild("Animator")

-- Remote Events/Replicated Storage
local PlayerStamina = ReplicatedStorage:WaitForChild("StaminasFolder"):WaitForChild(player.UserId)
local LightningRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Lightning")

-- Animation/Vfx vars
local BoltVfx = ReplicatedStorage:WaitForChild("VFX"):WaitForChild("Bolt")
local BoltRadiusVfx = ReplicatedStorage:WaitForChild("VFX"):WaitForChild("BoltRadius")
local lightningAnimationTrack = Animator:LoadAnimation(Character:WaitForChild("Animations").LightningAnimation)
lightningAnimationTrack.Priority = Enum.AnimationPriority.Action

-- Modules
local PlayerBarModule = require(script.Parent:WaitForChild("ConfigPlayerBar"))

-- Move vars
local MOVE_COST = 225
local AttackDebounce = false
local AttackCooldown = 5
local ORIGINAL_SPEED = 0
local MAX_RANGE_DISTANCE = 25
local ACTION_LIGHTNING = "Lightning"

-- Functions
local function generateLightningVfx(playerVfx: Player, Target: Model, VfxType: string)
    if VfxType == "Bolt" then
        local startPos = playerVfx.Character:FindFirstChild("HumanoidRootPart").Position + Vector3.new(0, 100, 0)
        local endPos = Target:FindFirstChild("Head").Position

        local newBolt = BoltVfx:Clone()
        newBolt.Parent = game.Workspace
        local boltDistance = (startPos - endPos).Magnitude
	    local boltCFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -boltDistance / 2)
        newBolt.CFrame = boltCFrame
        newBolt.Size = Vector3.new(0.2, 0.2, boltDistance)

        Debris:AddItem(newBolt, .25)
    end
    if VfxType == "Radius" then
        local newRadius = BoltRadiusVfx:Clone()
        newRadius.Parent = game.Workspace
        local playerHumanoid = playerVfx.Character:FindFirstChild("Humanoid")
        local playerHumanoidRootPart = playerVfx.Character:FindFirstChild("HumanoidRootPart")
        newRadius.Position = playerHumanoidRootPart.Position - Vector3.new(0, playerHumanoid.HipHeight, 0)

        Debris:AddItem(newRadius, 2)
    end
end

local function fireLightningStrike(actionName: string, inputState: Enum)
    if actionName == ACTION_LIGHTNING and inputState == Enum.UserInputState.Begin then
        if not AttackDebounce then
            if PlayerStamina.Value < MOVE_COST then
                PlayerBarModule.LessStamina(.25)
                return
            end
            local foundTarget = false
            for _, model in pairs(game.Workspace:GetChildren()) do
                if model:IsA("Model") then
                    if model ~= Character then
                        local ModelHumanoid = model:FindFirstChild("Humanoid")
                        local ModelHumanoidRootPart = model:FindFirstChild("HumanoidRootPart")

                        if ModelHumanoid and ModelHumanoidRootPart then
                            if (HumanoidRootPart.Position - ModelHumanoidRootPart.Position).Magnitude < MAX_RANGE_DISTANCE then
                                foundTarget = true
                            end
                        end
                    end
                end
            end
            if not foundTarget then
                return
            end
            AttackDebounce = true

            LightningRemote:FireServer()
            lightningAnimationTrack:Play()
            ORIGINAL_SPEED = humanoid.WalkSpeed
            humanoid.WalkSpeed = 0

            PlayerBarModule.AttackCooldown("LightningStrikes", AttackCooldown)
            AttackDebounce = false
        end
    end
    if actionName == ACTION_LIGHTNING and inputState == Enum.UserInputState.End then
        task.wait(1)
        if humanoid.WalkSpeed == 0 then
			humanoid.WalkSpeed = ORIGINAL_SPEED
		end
    end
end

-- Connections
LightningRemote.OnClientEvent:Connect(generateLightningVfx)
ContextActionService:BindAction(ACTION_LIGHTNING, fireLightningStrike, true, Enum.KeyCode.E)