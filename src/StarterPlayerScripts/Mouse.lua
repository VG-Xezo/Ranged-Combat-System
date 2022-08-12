-- Services
local UserInputService = game:GetService("UserInputService")

-- Mouse vars
local MAX_MOUSE_DISTANCE = 1000

-- Module functions
local Mouse = {}

function Mouse.getWorldMousePosition()
	local mouseLocation = UserInputService:GetMouseLocation()

	local screenToWorldRay = workspace.CurrentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	local directionVector = screenToWorldRay.Direction * MAX_MOUSE_DISTANCE
	local raycastResult = workspace:Raycast(screenToWorldRay.Origin, directionVector)
	
	if raycastResult then
		return raycastResult.Position
	else
		return screenToWorldRay.Origin + directionVector
	end
end

return Mouse