--!strict
---- SERVICES ----
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

---- TYPE DEFINITIONS ----
type MouseRaycastImpl = {
	__index: MouseRaycastImpl,

	--[[
        @param input If provided, reads the mouse position based on it. Used for mobile-compability.
    ]]
	Raycast: (self: MouseRaycast, input: InputObject?) -> RaycastResult?,
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

function MouseRaycast:Raycast(input: InputObject?): RaycastResult?
	local mousePosition
	if input then
		mousePosition = Vector2.new(input.Position.X, input.Position.Y)
	else
		mousePosition = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
	end
	local ray = CurrentCamera:ScreenPointToRay(mousePosition.X, mousePosition.Y)

	return workspace:Raycast(ray.Origin, ray.Direction * self.RayLength, self.Params)
end

return table.freeze({
	new = new,
})
