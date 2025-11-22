-- Resource Management for Ability Framework
-- Handles mana and stamina for players

-- Storage for player resources
-- Structure: resources[player_name] = {mana = number, stamina = number, max_mana = number, max_stamina = number}
local player_resources = {}

-- Default resource values
local DEFAULT_MAX_MANA = 100
local DEFAULT_MAX_STAMINA = 100

--- Initialize resources for a player
-- @param player_name string: Name of the player
local function init_resources(player_name)
	if not player_resources[player_name] then
		player_resources[player_name] = {
			mana = DEFAULT_MAX_MANA,
			stamina = DEFAULT_MAX_STAMINA,
			max_mana = DEFAULT_MAX_MANA,
			max_stamina = DEFAULT_MAX_STAMINA
		}
	end
end

--- Get player mana
-- @param player_name string: Name of the player
-- @return number: Current mana value
function abilityfw.get_mana(player_name)
	init_resources(player_name)
	return player_resources[player_name].mana
end

--- Get player max mana
-- @param player_name string: Name of the player
-- @return number: Maximum mana value
function abilityfw.get_max_mana(player_name)
	init_resources(player_name)
	return player_resources[player_name].max_mana
end

--- Set player mana
-- @param player_name string: Name of the player
-- @param value number: New mana value
function abilityfw.set_mana(player_name, value)
	init_resources(player_name)
	player_resources[player_name].mana = math.max(0, math.min(value, player_resources[player_name].max_mana))
	
	-- Save to metadata
	local player = minetest.get_player_by_name(player_name)
	if player then
		abilityfw.save_player_resources(player)
	end
end

--- Add mana to player
-- @param player_name string: Name of the player
-- @param amount number: Amount to add
function abilityfw.add_mana(player_name, amount)
	local current = abilityfw.get_mana(player_name)
	abilityfw.set_mana(player_name, current + amount)
end

--- Get player stamina
-- @param player_name string: Name of the player
-- @return number: Current stamina value
function abilityfw.get_stamina(player_name)
	init_resources(player_name)
	return player_resources[player_name].stamina
end

--- Get player max stamina
-- @param player_name string: Name of the player
-- @return number: Maximum stamina value
function abilityfw.get_max_stamina(player_name)
	init_resources(player_name)
	return player_resources[player_name].max_stamina
end

--- Set player stamina
-- @param player_name string: Name of the player
-- @param value number: New stamina value
function abilityfw.set_stamina(player_name, value)
	init_resources(player_name)
	player_resources[player_name].stamina = math.max(0, math.min(value, player_resources[player_name].max_stamina))
	
	-- Save to metadata
	local player = minetest.get_player_by_name(player_name)
	if player then
		abilityfw.save_player_resources(player)
	end
end

--- Add stamina to player
-- @param player_name string: Name of the player
-- @param amount number: Amount to add
function abilityfw.add_stamina(player_name, amount)
	local current = abilityfw.get_stamina(player_name)
	abilityfw.set_stamina(player_name, current + amount)
end

--- Save player resources to metadata
-- @param player ObjectRef: The player object
function abilityfw.save_player_resources(player)
	if not player or not player:is_player() then
		return
	end
	
	local player_name = player:get_player_name()
	init_resources(player_name)
	
	local res = player_resources[player_name]
	local meta = player:get_meta()
	
	meta:set_int("abilityfw:mana", res.mana)
	meta:set_int("abilityfw:stamina", res.stamina)
	meta:set_int("abilityfw:max_mana", res.max_mana)
	meta:set_int("abilityfw:max_stamina", res.max_stamina)
end

--- Load player resources from metadata
-- @param player ObjectRef: The player object
function abilityfw.load_player_resources(player)
	if not player or not player:is_player() then
		return
	end
	
	local player_name = player:get_player_name()
	local meta = player:get_meta()
	
	local mana = meta:get_int("abilityfw:mana")
	local stamina = meta:get_int("abilityfw:stamina")
	local max_mana = meta:get_int("abilityfw:max_mana")
	local max_stamina = meta:get_int("abilityfw:max_stamina")
	
	-- Initialize with defaults if not set
	if max_mana == 0 then
		max_mana = DEFAULT_MAX_MANA
		mana = DEFAULT_MAX_MANA
	end
	if max_stamina == 0 then
		max_stamina = DEFAULT_MAX_STAMINA
		stamina = DEFAULT_MAX_STAMINA
	end
	
	player_resources[player_name] = {
		mana = mana,
		stamina = stamina,
		max_mana = max_mana,
		max_stamina = max_stamina
	}
	
	minetest.log("action", "[abilityfw] Loaded resources for player '" .. player_name .. 
		"': Mana " .. mana .. "/" .. max_mana .. ", Stamina " .. stamina .. "/" .. max_stamina)
end

-- Load resources when player joins
minetest.register_on_joinplayer(function(player)
	abilityfw.load_player_resources(player)
end)

-- Save resources when player leaves
minetest.register_on_leaveplayer(function(player)
	abilityfw.save_player_resources(player)
	local player_name = player:get_player_name()
	player_resources[player_name] = nil
end)

minetest.log("action", "[abilityfw] Resource management loaded")
