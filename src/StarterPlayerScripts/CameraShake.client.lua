local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Character = player.Character

local ShakeCameraEvent = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("ShakeCamera")

if not Character then
    player.CharacterAdded:Wait()
    Character = player.Character
end

local Humanoid = Character:WaitForChild("Humanoid")

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

ShakeCameraEvent.OnClientEvent:Connect(shakeCamera)