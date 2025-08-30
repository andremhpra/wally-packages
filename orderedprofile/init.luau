--!strict
--[[
    Used for leaderboards.
]]
---- SERVICES ----
local DataStoreService = game:GetService("DataStoreService")

---- TYPE DEFINITIONS ----
type OrderedProfileImpl = {
	__index: OrderedProfileImpl,

	Set: (self: OrderedProfile, key: Player | string, value: number) -> (),
	GetTop: (self: OrderedProfile, pageSize: number) -> DataStorePages,
}

export type OrderedProfile = typeof(setmetatable(
	{} :: {
		Name: string,
		DataStore: OrderedDataStore,
	},
	{} :: OrderedProfileImpl
))

---- PUBLIC VARIABLES ----
local OrderedProfile = {} :: OrderedProfileImpl
OrderedProfile.__index = OrderedProfile

---- PUBLIC FUNCTIONS ----
local function new(key: string): OrderedProfile
	return setmetatable({
		Name = key,
		DataStore = DataStoreService:GetOrderedDataStore(key),
	}, OrderedProfile)
end

function OrderedProfile:Set(key: Player | string, value: number): ()
	assert(type(value) == "number", "value must be a positive number!")
	assert(value >= 0, "value must be positive!")

	if typeof(key) == "Player" and key.UserId <= 0 then
		warn(`Player "{key}" UserId is <= 0! Not writing to the "{self.Name}" OrderedDataStore.`)
		return
	end

	local realKey = if type(key) ~= "string" then tostring(key.UserId) else key
	self.DataStore:SetAsync(realKey, value)
end

function OrderedProfile:GetTop(pageSize: number): DataStorePages
	return self.DataStore:GetSortedAsync(false, pageSize)
end

return table.freeze({
	new = new,
})
