--!strict
---- SERVICES ----
local Players = game:GetService("Players")

---- TYPE DEFINITIONS ----
type LeaderStatsImpl = {
	__index: LeaderStatsImpl,

	--[[
        Updates the value at the given key. Creates a new value in the leaderstats if not.
    ]]
	SetValue: (self: Leaderstats, key: string, value: string | number) -> (),

	--[[
		Automatically gets called when the player leaves.
	]]
	Destroy: (self: Leaderstats) -> (),
}

export type Leaderstats = typeof(setmetatable(
	{} :: {
		Player: Player,
		LeaderstatsFolder: Folder,
	},
	{} :: LeaderStatsImpl
))

---- PUBLIC VARIABLES ----
local Leaderstats = {} :: LeaderStatsImpl
Leaderstats.__index = Leaderstats

---- PRIVATE VARIABLES ----
local createdLeaderstats: { [Player]: Leaderstats } = {}

---- PUBLIC FUNCTIONS ----
--[[
	Creates a new leaderstats for the player, return an existing one if already called for the same player.
]]
local function new(player: Player): Leaderstats
	assert(player and player:IsA("Player"), `player must be a Player!`)

	local Folder = Instance.new("Folder")
	Folder.Name = "leaderstats"
	Folder.Parent = player

	return setmetatable({
		Player = player,
		LeaderstatsFolder = Folder,
	}, Leaderstats)
end

function Leaderstats:SetValue(key: string, value: number | string): ()
	assert(type(key) == "string", "key must be a string!")
	assert(
		type(value) == "number" or type(value) == "string",
		`value must be a string or a number! got "{type(value)}"`
	)

	local existing = self.LeaderstatsFolder:FindFirstChild(key)
	if typeof(value) == "number" then
		if existing and existing:IsA("IntValue") then
			existing.Value = value
		else
			if existing then
				existing:Destroy()
			end
			local newStat = Instance.new("IntValue")
			newStat.Name = key
			newStat.Value = value
			newStat.Parent = self.LeaderstatsFolder
		end

		return
	end

	if existing and existing:IsA("StringValue") then
		existing.Value = value
	else
		if existing then
			existing:Destroy()
		end
		local newStat = Instance.new("StringValue")
		newStat.Name = key
		newStat.Value = value
		newStat.Parent = self.LeaderstatsFolder
	end
end

function Leaderstats:Destroy(): ()
	-- `Parent` might be `nil` if this is called after the player has left.
	if self.LeaderstatsFolder.Parent then
		self.LeaderstatsFolder:Destroy()
	end

	createdLeaderstats[self.Player] = nil
	self = nil :: any
end

---- CONNECTIONS ----
Players.PlayerRemoving:Connect(function(player: Player): ()
	local leaderstats = createdLeaderstats[player]
	if leaderstats then
		leaderstats:Destroy()
	end
end)

return table.freeze({
	new = new,
})
