-- Provides abstractions for the Player Mouse
local UserInputService = game:GetService("UserInputService")

local Mouse = {}

local MAX_MOUSE_DISTANCE = 1000

function Mouse.getWorldMousePosition()
	local mouseLocation = UserInputService:GetMouseLocation()
	
	-- Create a ray from the 2D mouse location
	local screenToWorldRay = workspace.CurrentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	
	-- The unit direction vector of the ray multiplied by a maxiumum distance
	local directionVector = screenToWorldRay.Direction * MAX_MOUSE_DISTANCE
	
	-- Raycast from the roy's origin towards its direction
	local raycastResult = workspace:Raycast(screenToWorldRay.Origin, directionVector)
	
	if raycastResult then
		-- Return the 3D point of intersection
		return raycastResult.Position
	else
		-- No object was hit so calculate the position at the end of the ray
		return screenToWorldRay.Origin + directionVector
	end
end

return Mouse