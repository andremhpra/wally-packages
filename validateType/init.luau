--!strict
---- PUBLIC VARIABLES ----
local ValidateType = {}

---- PUBLIC FUNCTIONS ----
function ValidateType.simpleTable(tbl: { [any]: any }, keyType: string, validator: (any) -> boolean): boolean
	-- Make sure this is actually a table
	if typeof(tbl) ~= "table" then
		return false
	end

	-- Validate all keys and values
	for key, value in tbl do
		if typeof(key) ~= keyType then
			return false
		end

		if not validator(value) then
			return false
		end
	end

	return true
end

function ValidateType.vec3(vector3: Vector3): boolean
	-- Make sure this is actually a Vector3
	if typeof(vector3) ~= "Vector3" then
		return false
	end

	-- Make sure the vector3 does not contain any NaN components
	if vector3 ~= vector3 then
		return false
	end

	return true
end

function ValidateType.vec2(vector2: Vector2): boolean
	-- Make sure this is actually a Vector2
	if typeof(vector2) ~= "Vector2" then
		return false
	end

	-- Make sure the vector2 does not contain any NaN components
	if vector2 ~= vector2 then
		return false
	end

	return true
end

function ValidateType.num(number: number): boolean
	-- Make sure this is actually a number
	if typeof(number) ~= "number" then
		return false
	end

	-- Make sure the number is not NaN
	if number ~= number then
		return false
	end

	return true
end

--[[
	Ensures the instance is not an 'imposter' and is of the expected class.

	In cases where the server is expecting an instance, exploiters can pass a table with keys
	that mimic the instance's properties but set to whatever they want.

	e.g.
	local fakePart = {
		Position = Vector3.new()
	}

	remoteExpectingPart:FireServer(fakePart)

	It is unsafe for the server to blindly accept the position of this fake part without
	checking it is a valid instance first.
]]
function ValidateType.inst(instance: Instance, expectedClass: string): boolean
	if typeof(instance) ~= "Instance" then
		return false
	end

	return instance:IsA(expectedClass)
end

function ValidateType.cframe(cframe: CFrame): boolean
	-- Make sure this is actually a CFrame
	if typeof(cframe) ~= "CFrame" then
		return false
	end

	if not ValidateType.vec3(cframe.Position) then
		return false
	end

	if not ValidateType.vec3(cframe.LookVector) then
		return false
	end

	return true
end

return ValidateType
