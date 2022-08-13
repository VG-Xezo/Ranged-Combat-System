-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")

-- Player vars
local player = Players.LocalPlayer
local Character = Players.LocalPlayer.Character
if not Character then
	Players.LocalPlayer.CharacterAdded:Wait()
	Character = Players.LocalPlayer.Character
end
local humanoid = Character:WaitForChild("Humanoid")
local Animator = humanoid:WaitForChild("Animator")

-- Remote Events/Replicated Storage
local PlayerStamina = ReplicatedStorage:WaitForChild("StaminasFolder"):WaitForChild(player.UserId)
local LaserRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Laser")

-- Animation vars
local laserAnimationTrack = Animator:LoadAnimation(Character:WaitForChild("Animations").LaserAnimation)
laserAnimationTrack.Priority = Enum.AnimationPriority.Action
laserAnimationTrack.Looped = true

-- Modules
local MouseModule = require(script.Parent:WaitForChild("Mouse"))
local PlayerBarModule = require(script.Parent:WaitForChild("ConfigPlayerBar"))

-- Move vars
local MOVE_COST = 10
local AttackDebounce = false
local AttackCooldown = 2
local MAX_CAST_DISTANCE = 100
local ACTION_LASER_BEAM = "Laser Beam"
local isKeyDown = false
local FiredTimes = 0

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

local function generateLaserVfx(playerVfx: Player, hitPosition: Vector3)
    local startPosition = playerVfx.Character:FindFirstChild("Head").Position
	
	local laserDistance = (startPosition - hitPosition).Magnitude
	local laserCFrame = CFrame.lookAt(startPosition, hitPosition) * CFrame.new(0, 0, -laserDistance / 2)
	
	local laserPart = Instance.new("Part")
	laserPart.Size = Vector3.new(0.2, 0.2, laserDistance)
	laserPart.CFrame  = laserCFrame
	laserPart.Anchored = true
	laserPart.CanCollide = false
	laserPart.Color = Color3.fromRGB(255, 0, 0)
	laserPart.Material = Enum.Material.Neon
	laserPart.Parent = game.Workspace

    Debris:AddItem(laserPart, 0.15)
end

local function fireLaserBeams(actionName: string, inputState: Enum)
    if actionName == ACTION_LASER_BEAM and inputState == Enum.UserInputState.Begin then
        if not AttackDebounce then
            if PlayerStamina.Value < MOVE_COST then
                PlayerBarModule.LessStamina(.25)
                return 
			end
            AttackDebounce = true
            isKeyDown = true
            laserAnimationTrack:Play()

            while isKeyDown do
                if PlayerStamina.Value < MOVE_COST then
                    PlayerBarModule.LessStamina(.25)
                    return 
			    end
                FiredTimes += 1
                local mouseLocation = MouseModule.getWorldMousePosition()

                local targetDirection = (mouseLocation - Character:FindFirstChild("Head").Position).Unit

                local directionVector = targetDirection * MAX_CAST_DISTANCE
                
                local spellRaycastParams = RaycastParams.new()
                spellRaycastParams.FilterDescendantsInstances = {Character}
                local spellRaycastResult = workspace:Raycast(Character:FindFirstChild("Head").Position, directionVector, spellRaycastParams)

                local hitCharacter
                local hitPosition
                if spellRaycastResult then
                    hitPosition = spellRaycastResult.Position
                    if spellRaycastResult.Instance then
                        if checkHumanoid(spellRaycastResult.Instance) then
                            hitPosition = spellRaycastResult.Instance.Position
                            hitCharacter = spellRaycastResult.Instance:FindFirstAncestorOfClass("Model")

                        end
                    end
                else
                    hitPosition = Character:FindFirstChild("Head").Position + directionVector
                end

                LaserRemote:FireServer(hitPosition, hitCharacter)
                task.wait(.1)
                if FiredTimes >= 25 then
                    FiredTimes = 0
                    laserAnimationTrack:Stop()
                    break
                end
            end

            PlayerBarModule.AttackCooldown("Laser", AttackCooldown)
            AttackDebounce = false
        end
    end
    if actionName == ACTION_LASER_BEAM and inputState == Enum.UserInputState.End then
        isKeyDown = false
        laserAnimationTrack:Stop()
    end
end

-- Connections
LaserRemote.OnClientEvent:Connect(generateLaserVfx)
ContextActionService:BindAction(ACTION_LASER_BEAM, fireLaserBeams, true, Enum.KeyCode.R)