-- Services
local Players = game:GetService("Players")

-- Player vars
local player = Players.LocalPlayer
local Character = player.Character
if not Character then
    player.CharacterAdded:Wait()
    Character = player.Character
end
local Humanoid = Character:WaitForChild("Humanoid")

-- Remote Events
local ShakeCameraEvent = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("ShakeCamera")

-- Functions
function shakeCamera(Time: number)
    local StartTime = tick()
    
    repeat
        task.wait()
        local EndTime = tick()

        local xOffset = math.random(-100, 100) / 500
        local yOffset = math.random(-100, 100) / 500
        local zOffset = math.random(-100, 100) / 500

        Humanoid.CameraOffset = Vector3.new(xOffset, yOffset, zOffset)
    until EndTime - StartTime >= Time
    Humanoid.CameraOffset = Vector3.new(0, 0, 0)
end

-- Connections
ShakeCameraEvent.OnClientEvent:Connect(shakeCamera)