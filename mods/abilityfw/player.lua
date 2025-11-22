-- Player ability management for Block & Role
-- Handles granting, revoking, and checking player abilities

-- Storage for player abilities
-- Structure: player_abilities[player_name] = {ability_name = true, ...}
local player_abilities = {}

--- Grant an ability to a player
-- @param player_name string: Name of the player
-- @param ability_name string: Name of the ability to grant
-- @return boolean: true if granted successfully, false otherwise
function abilityfw.grant_ability(player_name, ability_name)
	if not player_name or type(player_name) ~= "string" then
		minetest.log("error", "[abilityfw] grant_ability: player_name must be a string")
		return false
	end
	
	local ability = abilityfw.get_ability(ability_name)
	if not ability then
		minetest.log("error", "[abilityfw] grant_ability: ability '" .. ability_name .. "' not found")
		return false
	end
	
	if not player_abilities[player_name] then
		player_abilities[player_name] = {}
	end
	
	if player_abilities[player_name][ability_name] then
		minetest.log("info", "[abilityfw] Player '" .. player_name .. "' already has ability '" .. ability_name .. "'")
		return true
	end
	
	player_abilities[player_name][ability_name] = true
	minetest.log("action", "[abilityfw] Granted ability '" .. ability_name .. "' to player '" .. player_name .. "'")
	
	-- Save to player metadata for persistence
	local player = minetest.get_player_by_name(player_name)
	if player then
		abilityfw.save_player_abilities(player)
	end
	
	return true
end

--- Revoke an ability from a player
-- @param player_name string: Name of the player
-- @param ability_name string: Name of the ability to revoke
-- @return boolean: true if revoked successfully, false otherwise
function abilityfw.revoke_ability(player_name, ability_name)
	if not player_name or type(player_name) ~= "string" then
		minetest.log("error", "[abilityfw] revoke_ability: player_name must be a string")
		return false
	end
	
	if not player_abilities[player_name] or not player_abilities[player_name][ability_name] then
		minetest.log("info", "[abilityfw] Player '" .. player_name .. "' does not have ability '" .. ability_name .. "'")
		return true
	end
	
	player_abilities[player_name][ability_name] = nil
	minetest.log("action", "[abilityfw] Revoked ability '" .. ability_name .. "' from player '" .. player_name .. "'")
	
	-- Save to player metadata for persistence
	local player = minetest.get_player_by_name(player_name)
	if player then
		abilityfw.save_player_abilities(player)
	end
	
	return true
end

--- Check if a player has an ability
-- @param player_name string: Name of the player
-- @param ability_name string: Name of the ability to check
-- @return boolean: true if player has the ability, false otherwise
function abilityfw.has_ability(player_name, ability_name)
	if not player_abilities[player_name] then
		return false
	end
	
	return player_abilities[player_name][ability_name] == true
end

-- Alias for consistency with other APIs
abilityfw.player_has_ability = abilityfw.has_ability

--- Get all abilities for a player
-- @param player_name string: Name of the player
-- @return table: List of ability names the player has
function abilityfw.get_player_abilities(player_name)
	if not player_abilities[player_name] then
		return {}
	end
	
	local abilities = {}
	for ability_name, _ in pairs(player_abilities[player_name]) do
		table.insert(abilities, ability_name)
	end
	
	return abilities
end

--- Save player abilities to metadata
-- @param player ObjectRef: The player object
function abilityfw.save_player_abilities(player)
	if not player or not player:is_player() then
		return
	end
	
	local player_name = player:get_player_name()
	local abilities = player_abilities[player_name] or {}
	
	-- Convert abilities table to serializable format
	local ability_list = {}
	for ability_name, _ in pairs(abilities) do
		table.insert(ability_list, ability_name)
	end
	
	local meta = player:get_meta()
	meta:set_string("abilityfw:abilities", minetest.serialize(ability_list))
end

--- Load player abilities from metadata
-- @param player ObjectRef: The player object
function abilityfw.load_player_abilities(player)
	if not player or not player:is_player() then
		return
	end
	
	local player_name = player:get_player_name()
	local meta = player:get_meta()
	local serialized = meta:get_string("abilityfw:abilities")
	
	if serialized == "" then
		player_abilities[player_name] = {}
		return
	end
	
	local ability_list = minetest.deserialize(serialized)
	if not ability_list or type(ability_list) ~= "table" then
		minetest.log("warning", "[abilityfw] Failed to deserialize abilities for player '" .. player_name .. "'")
		player_abilities[player_name] = {}
		return
	end
	
	-- Convert list back to lookup table
	player_abilities[player_name] = {}
	for _, ability_name in ipairs(ability_list) do
		player_abilities[player_name][ability_name] = true
	end
	
	minetest.log("action", "[abilityfw] Loaded " .. #ability_list .. " abilities for player '" .. player_name .. "'")
end

-- Load player abilities when they join
minetest.register_on_joinplayer(function(player)
	abilityfw.load_player_abilities(player)
end)

-- Save player abilities when they leave
minetest.register_on_leaveplayer(function(player)
	abilityfw.save_player_abilities(player)
	local player_name = player:get_player_name()
	player_abilities[player_name] = nil
end)

minetest.log("action", "[abilityfw] Player ability management loaded")
