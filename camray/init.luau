--!strict
---- SERVICES ----
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

---- TYPE DEFINITIONS ----
type MouseRaycastImpl = {
	__index: MouseRaycastImpl,

	--[[
        @param mobileMousePosition, if provided, uses that as the mouse coordinates. Used for mobile-compability.
    ]]
	Raycast: (self: MouseRaycast, tapPosition: Vector2?) -> RaycastResult?,
}

export type MouseRaycast = typeof(setmetatable(
	{} :: {
		Params: RaycastParams?,
		RayLength: number,
	},
	{} :: MouseRaycastImpl
))

---- PRIVATE VARIABLES ----
local CurrentCamera = workspace.CurrentCamera

---- PUBLIC VARIABLES ----
local MouseRaycast = {} :: MouseRaycastImpl
MouseRaycast.__index = MouseRaycast

---- PUBLIC FUNCTIONS ----
local function new(params: RaycastParams?, raycastLength: number): MouseRaycast
	return setmetatable({
		Params = params,
		RayLength = raycastLength,
	}, MouseRaycast)
end

function MouseRaycast:Raycast(tapPosition): RaycastResult?
	local mousePosition
	if tapPosition then
		mousePosition = tapPosition
	else
		mousePosition = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
	end
	local ray = CurrentCamera:ScreenPointToRay(mousePosition.X, mousePosition.Y)

	return workspace:Raycast(ray.Origin, ray.Direction * self.RayLength, self.Params)
end

return table.freeze({
	new = new,
})
