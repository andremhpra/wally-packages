--!strict
--[[
	@param tbl The item to be picked on, its chance is written as `n` in `1/n` meaning higher number means less likely.
	@param luck The luck multiplier, `1` if not provided. e.g. 25% item with 2x luck will make it 50%. But if it reaches >= 100%, it is removed from the list.

	Asserts on invalid input.
]]
return function<T>(tbl: { [T]: { Chance: number, [any]: any } | number }, luck: number?): T
	assert(type(tbl) == "table", `tbl must be a table! Got "{type(tbl)}".`)

	luck = luck or 1
	assert(type(luck) == "number" and luck > 0, `luck must be a positive number! Got "{luck}".`)

	local weightedList = {}
	local totalWeight = 0

	local rarestKey: T? = nil
	local highestChance = -math.huge

	for key, value in tbl do
		local baseChance: number
		if type(value) == "number" then
			baseChance = value
		else
			assert(type(value.Chance) == "number", `tbl[value].Chance must be a number! Got "{type(value.Chance)}".`)
			baseChance = value.Chance
		end
		assert(baseChance > 0, `"{key}" chance must be positive!`)

		-- Track rarest item just in case
		if baseChance > highestChance then
			highestChance = baseChance
			rarestKey = key
		end

		local weight = (1 / baseChance) * luck
		if weight >= 1 then
			-- Item is too likely (100%), skip.
			continue
		end

		totalWeight += weight
		table.insert(weightedList, {
			Key = key,
			Weight = weight,
		})
	end

	if totalWeight <= 0 then
		-- All of the items became too likely, return the rarest base chance one.
		assert(rarestKey ~= nil, "No valid items to choose from and no fallback")
		return rarestKey
	end

	local roll = Random.new():NextNumber(0, totalWeight)
	local cumulative = 0

	for _, entry in weightedList do
		cumulative += entry.Weight
		if roll <= cumulative then
			return entry.Key
		end
	end

	-- Fallback in extreme floating-point edge cases
	return weightedList[#weightedList].Key
end
