-- Services
local Players = game:GetService("Players")
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")

-- Replicated Storage
local KeyframesFolder = game:GetService("ReplicatedStorage"):WaitForChild("KeyframesFolder")

-- Functions + Connections
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local AnimationsFolder = Instance.new("Folder")
        AnimationsFolder.Name = "Animations"
        for _, keyframe in pairs(KeyframesFolder:GetChildren()) do
            local newAnimation = Instance.new("Animation")
            newAnimation.Name = keyframe.Name
            newAnimation.AnimationId = KeyframeSequenceProvider:RegisterKeyframeSequence(keyframe)
            newAnimation.Parent = AnimationsFolder
        end
        AnimationsFolder.Parent = character
    end)
end)