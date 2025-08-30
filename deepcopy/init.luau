local function deepCopy<T>(tbl: T): T
	assert(type(tbl) == "table", "Provided table must be a table!")

	local copy = {}
	for key, value in tbl :: { [any]: any } do
		if type(value) == "table" then
			copy[key] = deepCopy(value)
		else
			copy[key] = value
		end
	end
	return copy :: any
end

return deepCopy
