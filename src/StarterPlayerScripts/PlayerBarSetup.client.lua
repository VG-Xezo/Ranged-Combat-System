-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

-- Replicated Storage
local playerStamina = ReplicatedStorage:WaitForChild("StaminasFolder"):WaitForChild(player.UserId)

-- Player vars
local player = Players.LocalPlayer
local Character = player.Character
if not Character then
    player.CharacterAdded:Wait()
    Character = player.Character
end
local playerHeatlh = Character:WaitForChild("Humanoid")

-- Gui vars
local PlayerBarGui = player:WaitForChild("PlayerGui"):WaitForChild("PlayerBarGui")
local HealthBar = PlayerBarGui.PlayerBarsBackground.HealthBarBackground.HealthBar
local HealthValue = PlayerBarGui.PlayerBarsBackground.HealthBarBackground.HealthValue
local StaminaBar = PlayerBarGui.PlayerBarsBackground.StaminaBarBackground.StaminaBar
local StaminaValue = PlayerBarGui.PlayerBarsBackground.StaminaBarBackground.StaminaValue

-- Set Gui vars
local headshot, isReady = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
local PlayerImage = PlayerBarGui.PlayerProfileBackground.PlayerImage
PlayerImage.Image = headshot
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)

-- Update UI Loop
while true do
    -- Set Health
    HealthValue.Text = tostring(playerHeatlh.Health)
    StaminaValue.Text = tostring(playerStamina.Value)
    
    TweenService:Create(HealthBar, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new((playerHeatlh.Health/100), 0, 1, 0)}):Play()
    TweenService:Create(StaminaBar, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new((playerStamina.Value/1000), 0, 1, 0)}):Play()

    task.wait()
end