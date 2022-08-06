local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local Character = player.Character
if not Character then
    player.CharacterAdded:Wait()
    Character = player.Character
end

local StarterGui = game:GetService("StarterGui")
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)

local playerStamina = game:GetService("ReplicatedStorage"):WaitForChild("StaminasFolder"):WaitForChild(player.UserId)
local playerHeatlh = Character:WaitForChild("Humanoid")
local PlayerBarGui = player:WaitForChild("PlayerGui"):WaitForChild("PlayerBarGui")

local headshot, isReady = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
local PlayerImage = PlayerBarGui.PlayerProfileBackground.PlayerImage
PlayerImage.Image = headshot

local HealthBar = PlayerBarGui.PlayerBarsBackground.HealthBarBackground.HealthBar
local HealthValue = PlayerBarGui.PlayerBarsBackground.HealthBarBackground.HealthValue

local StaminaBar = PlayerBarGui.PlayerBarsBackground.StaminaBarBackground.StaminaBar
local StaminaValue = PlayerBarGui.PlayerBarsBackground.StaminaBarBackground.StaminaValue

while true do
    -- Set Health
    HealthValue.Text = tostring(playerHeatlh.Health)
    StaminaValue.Text = tostring(playerStamina.Value)
    
    TweenService:Create(HealthBar, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new((playerHeatlh.Health/100), 0, 1, 0)}):Play()
    TweenService:Create(StaminaBar, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new((playerStamina.Value/1000), 0, 1, 0)}):Play()

    task.wait()
end