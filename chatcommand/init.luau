--!strict
---- SERVICES ----
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

---- TYPE DEFINITIONS ----
type CommandFunction = (player: Player, ...string?) -> ()

---- PRIVATE VARIABLES ----
local allowedUserIds: { [number]: true? } = {
	[game.CreatorId] = true,
}
-- [groupId][roleName] = true
local allowedGroupRoles: { [number]: { [string]: true? } } = {}

---- PRIVATE FUNCTIONS ----
local function isPlayerAllowed(player: Player): boolean
	if allowedUserIds[player.UserId] then
		-- Player has been inserted through `insertPlayer()` or is the game creator.
		return true
	end

	for groupId, allowedRoles in allowedGroupRoles do
		if not player:IsInGroup(groupId) then
			continue
		end

		if allowedRoles[player:GetRoleInGroup(groupId)] then
			-- The player has the allowed group role in the group.
			return true
		end
	end

	return false
end

local function onChatCommandTriggered(player: Player, message: string, func: CommandFunction): ()
	if not isPlayerAllowed(player) then
		return
	end

	local args = message:split(" ")
	table.remove(args, 1)

	func(player, table.unpack(args))
end

---- PUBLIC VARIABLES ----
local ChatCommand = {}

---- PUBLIC FUNCTIONS ----
--[[
	Allows the provided UserId to use commands.
]]
function ChatCommand.insertUserId(userId: number): ()
	assert(type(userId) == "number", `userId must be a number! Got "{type(userId)}".`)

	allowedUserIds[userId] = true
end

--[[
	Should be called when the player should no longer has access in run-time.
	Does nothing if the player doesn't have access in the first place.

	**DO NOT** call on player leave, since this module already does it.
]]
function ChatCommand.removeUserId(userId: number): ()
	assert(type(userId) == "number", `userId must be a number! Got "{type(userId)}".`)

	allowedUserIds[userId] = nil
end

function ChatCommand.insertGroupRoles(groupId: number, roleNames: { string }): ()
	assert(type(groupId) == "number", `groupId must be a number! Got "{type(groupId)}".`)
	assert(type(roleNames) == "table", `roleNames must be a table! Got "{type(roleNames)}".`)

	allowedGroupRoles[groupId] = allowedGroupRoles[groupId] or {}

	for _, roleName in roleNames do
		assert(type(roleName) == "string", `roleName must be a string! Got "{type(roleName)}".`)
		allowedGroupRoles[groupId][roleName] = true
	end
end

function ChatCommand.removeGroupRoles(groupId: number, roleNames: { string }): ()
	assert(type(groupId) == "number", `groupId must be a number! Got "{type(groupId)}".`)
	assert(type(roleNames) == "table", `roleNames must be a table! Got "{type(roleNames)}".`)

	local groupRoles = allowedGroupRoles[groupId]
	if not groupRoles then
		return
	end

	for _, roleName in roleNames do
		assert(type(roleName) == "string", `roleName must be a string! Got "{type(roleName)}".`)
		groupRoles[roleName] = nil
	end

	-- If group has no more allowed roles, remove the group entirely
	if next(groupRoles) == nil then
		allowedGroupRoles[groupId] = nil
	end
end

function ChatCommand.insertFunction(
	primaryAlias: string,
	secondaryAlias: string,
	autoCompleteVisible: boolean,
	func: CommandFunction
): ()
	assert(type(primaryAlias) == "string", `primaryAlias must be a string! Got "{type(primaryAlias)}".`)
	assert(type(secondaryAlias) == "string", `secondaryAlias must be a string! Got "{type(secondaryAlias)}".`)
	assert(type(func) == "function", `func must be a function! Got "{type(func)}".`)

	local command = Instance.new("TextChatCommand")
	command.Name = primaryAlias
	command.PrimaryAlias = "/" .. primaryAlias
	command.AutocompleteVisible = autoCompleteVisible
	command.SecondaryAlias = secondaryAlias ~= "" and "/" .. secondaryAlias or ""
	command.Triggered:Connect(function(textSource: TextSource, message: string): ()
		local player = Players:GetPlayerByUserId(textSource.UserId)
		if not player then
			return
		end

		onChatCommandTriggered(player, message, func)
	end)
	command.Parent = TextChatService
end

---- CONNECTIONS ----
-- Remove the player on leave to avoid memory leak.
Players.PlayerRemoving:Connect(function(player: Player): ()
	ChatCommand.removeUserId(player.UserId)
end)

return ChatCommand
