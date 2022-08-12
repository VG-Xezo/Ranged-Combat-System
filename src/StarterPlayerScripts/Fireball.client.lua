local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local Character = player.Character
if not Character then
    player.CharacterAdded:Wait()
    Character = player.Character
end

local humanoid = Character:WaitForChild("Humanoid")
local Animator = humanoid:WaitForChild("Animator")

local PlayerStamina = ReplicatedStorage:WaitForChild("StaminasFolder"):WaitForChild(player.UserId)

local fireballAnimationTrack = Animator:LoadAnimation(Character:WaitForChild("Animations").FireballAnimation)
fireballAnimationTrack.Priority = Enum.AnimationPriority.Action

local FireballRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Fireball")
local FireballVfx = ReplicatedStorage:WaitForChild("VFX"):WaitForChild("Fireball")

local MouseModule = require(script.Parent:WaitForChild("Mouse"))
local PlayerBarModule = require(script.Parent:WaitForChild("ConfigPlayerBar"))

local ACTION_FIREBALL = "Fireball"
local MOVE_COST = 75
local MAX_CAST_DISTANCE = 75
local AttackDebounce = false
local AttackCooldown = 1.5
local ORIGINAL_SPEED

local function checkHumanoid(instance: Part)
	local characterModel = instance:FindFirstAncestorOfClass("Model")
	if characterModel then
		local Humanoid = characterModel:FindFirstChild("Humanoid")
		if Humanoid then
			return true
		end
	end
	return false
end

local function generateFireballVfx(startPos: Vector3, endPos: Vector3)
	local newFireballVfx = FireballVfx:Clone()
	newFireballVfx.Parent = game.Workspace
	newFireballVfx:PivotTo(CFrame.new(startPos))

	for _, part in pairs(newFireballVfx:GetChildren()) do
		TweenService:Create(part, TweenInfo.new(1), {Position = endPos}):Play()
	end

	Debris:AddItem(newFireballVfx, 1)
end

local function fireFireball(actionName: string, inputState: Enum)
    if actionName == ACTION_FIREBALL and inputState == Enum.UserInputState.Begin then
        if not AttackDebounce then
            if PlayerStamina.Value < MOVE_COST then
                PlayerBarModule.LessStamina(.25)
				return
            end
            AttackDebounce = true

            local mouseLocation = MouseModule.getWorldMousePosition()

			local targetDirection = (mouseLocation - Character:FindFirstChild("HumanoidRootPart").Position).Unit

			local directionVector = targetDirection * MAX_CAST_DISTANCE
			
			local spellRaycastParams = RaycastParams.new()
			spellRaycastParams.FilterDescendantsInstances = {Character}
			local spellRaycastResult = workspace:Raycast(Character:FindFirstChild("LeftHand").Position, directionVector, spellRaycastParams)

			local hitPosition

			if spellRaycastResult then
				hitPosition = spellRaycastResult.Position
				if spellRaycastResult.Instance then
					if checkHumanoid(spellRaycastResult.Instance) then
						hitPosition = spellRaycastResult.Instance.Position
					end
				end
			else
				hitPosition = Character:FindFirstChild("LeftHand").Position + directionVector
			end

			if (Character:FindFirstChild("HumanoidRootPart").Position - hitPosition).Magnitude < MAX_CAST_DISTANCE then
				ORIGINAL_SPEED = humanoid.WalkSpeed
				humanoid.WalkSpeed = 0
                fireballAnimationTrack:Play()
				FireballRemote:FireServer(hitPosition)
			end
			PlayerBarModule.AttackCooldown("Fireball", AttackCooldown)
            AttackDebounce = false
        end
    end
    if actionName == ACTION_FIREBALL and inputState == Enum.UserInputState.End then
        if humanoid.WalkSpeed == 0 then
            humanoid.WalkSpeed = ORIGINAL_SPEED
        end
    end
end

FireballRemote.OnClientEvent:Connect(generateFireballVfx)
ContextActionService:BindAction(ACTION_FIREBALL, fireFireball, true, Enum.KeyCode.F)