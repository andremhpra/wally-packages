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
	SetRaycastLength: (self: MouseRaycast, raycastLength: number) -> (),
	--[[
		Does nothing if the object doesn't have a `RaycastParams`.
	]]
	AddToParams: (self: MouseRaycast, instance: Instance | { Instance }) -> (),
	--[[
		Replaces the current raycast params.
	]]
	SetRaycastParams: (self: MouseRaycast, params: RaycastParams?) -> (),
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
	assert(typeof(params) == "RaycastParams", `params must be a RaycastParams! Got "{typeof(params)}", {params}.`)
	assert(
		type(raycastLength) == "number",
		`raycastLength must be a number! Got "{type(raycastLength)}", {raycastLength}.`
	)

	return setmetatable({
		Params = params,
		RayLength = raycastLength,
	}, MouseRaycast)
end

function MouseRaycast:Raycast(tapPosition): RaycastResult?
	assert(
		typeof(tapPosition) == "Vector2" or typeof(tapPosition) == "nil",
		`tapPosition must be a Vector2 or nil! Got "${typeof(tapPosition)}", {tapPosition}.`
	)

	local mousePosition
	if tapPosition then
		mousePosition = tapPosition
	else
		mousePosition = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
	end
	local ray = CurrentCamera:ScreenPointToRay(mousePosition.X, mousePosition.Y)

	return workspace:Raycast(ray.Origin, ray.Direction * self.RayLength, self.Params)
end

function MouseRaycast:SetRaycastLength(length)
	assert(type(length) == "number", `length must be a number! Got "{type(length)}", {length}.`)

	self.RayLength = length
end

function MouseRaycast:AddToParams(instance)
	if not self.Params then
		warn("Cannot add to params, no RaycastParams is set!")
		return
	end
	self.Params:AddToFilter(instance)
end

function MouseRaycast:SetRaycastParams(params)
	assert(typeof(params) == "RaycastParams", `params must be a RaycastParams! Got "{typeof(params)}", {params}.`)

	self.Params = params
end

return table.freeze({
	new = new,
})
