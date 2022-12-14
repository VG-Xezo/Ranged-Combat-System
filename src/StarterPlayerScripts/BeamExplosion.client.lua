-- Services
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")

-- Player vars
local Character = Players.LocalPlayer.Character
if not Character then
	Players.LocalPlayer.CharacterAdded:Wait()
	Character = Players.LocalPlayer.Character
end
local humanoid = Character:WaitForChild("Humanoid")
local Animator = humanoid:WaitForChild("Animator")

-- Remote Events/Replicated Storage
local BeamExplosionRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("BeamExplosion")
local PlayerStamina = ReplicatedStorage:WaitForChild("StaminasFolder"):WaitForChild(Players.LocalPlayer.UserId)

-- Animation/Vfx vars
local beamAnimationTrack = Animator:LoadAnimation(Character:WaitForChild("Animations").BeamExplosionAnimation)
beamAnimationTrack.Priority = Enum.AnimationPriority.Action
local BeamExplosionVfx = ReplicatedStorage:WaitForChild("VFX"):WaitForChild("BeamExplosion")

-- Modules
local MouseModule = require(script.Parent:WaitForChild("Mouse"))
local PlayerBarModule = require(script.Parent:WaitForChild("ConfigPlayerBar"))

-- Move vars
local ACTION_BEAM_EXPLOSION = "Beam Explosion"
local AttackDebounce = false
local AttackCooldown = 2.5
local MAX_CAST_DISTANCE = 50
local MOVE_COST = 100
local ORIGINAL_SPEED = 0

-- Functions
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

local function generateBeamExplosionVfx(Position: Vector3)
	local newBeamExplosion = BeamExplosionVfx:Clone()
	newBeamExplosion:PivotTo(CFrame.new(Position))
	newBeamExplosion.Parent = game.Workspace
	Debris:AddItem(newBeamExplosion, 2.5)

	for _, part in pairs(newBeamExplosion:GetChildren()) do
		local SizeGoal = part.Size + Vector3.new(15,15,15)
		local CFrameGoal = part.CFrame * CFrame.Angles(0, math.rad(180), 0)

		TweenService:Create(part, TweenInfo.new(2, Enum.EasingStyle.Exponential), {Size = SizeGoal; CFrame = CFrameGoal}):Play()
		TweenService:Create(part, TweenInfo.new(4, Enum.EasingStyle.Quad), {Transparency = 1}):Play()
		task.wait()
	end
end

local function fireBeamExplosion(actionName: string, inputState: Enum)
    if actionName == ACTION_BEAM_EXPLOSION and inputState == Enum.UserInputState.Begin then
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
				beamAnimationTrack:Play()
				ORIGINAL_SPEED = humanoid.WalkSpeed
				humanoid.WalkSpeed = 0
				BeamExplosionRemote:FireServer(hitPosition)
			end
			
			PlayerBarModule.AttackCooldown("BeamExplosion", AttackCooldown)
			AttackDebounce = false
		end
	end
	if actionName == ACTION_BEAM_EXPLOSION and inputState == Enum.UserInputState.End then
		if humanoid.WalkSpeed == 0 then
			humanoid.WalkSpeed = ORIGINAL_SPEED
		end
	end
end

-- Connections
BeamExplosionRemote.OnClientEvent:Connect(generateBeamExplosionVfx)
ContextActionService:BindAction(ACTION_BEAM_EXPLOSION, fireBeamExplosion, true, Enum.KeyCode.Q)