-- Ability Framework for Block & Role
-- Supports skill-based gameplay and modular ability definitions

abilityfw = {}

-- Internal storage for registered abilities
local registered_abilities = {}

-- Internal storage for player cooldowns
-- Structure: cooldowns[player_name][ability_name] = timestamp
local cooldowns = {}

--- Register a new ability definition
-- @param name string: Unique identifier for the ability
-- @param def table: Ability definition with the following fields:
--   - id: string (optional, defaults to name)
--   - name: string (display name)
--   - type: string ("active" or "passive")
--   - cooldown: number (seconds, optional, default 0)
--   - mana_cost: number (optional, default 0)
--   - on_use: function(player, ability_def) (required for active abilities)
-- @return boolean: true if registered successfully, false otherwise
function abilityfw.register_ability(name, def)
	if not name or type(name) ~= "string" then
		minetest.log("error", "[abilityfw] register_ability: name must be a string")
		return false
	end
	
	if not def or type(def) ~= "table" then
		minetest.log("error", "[abilityfw] register_ability: def must be a table")
		return false
	end
	
	if registered_abilities[name] then
		minetest.log("warning", "[abilityfw] Ability '" .. name .. "' is already registered, overwriting")
	end
	
	-- Set defaults
	local ability = {
		id = def.id or name,
		name = def.name or name,
		type = def.type or "active",
		cooldown = def.cooldown or 0,
		mana_cost = def.mana_cost or 0,
		on_use = def.on_use,
	}
	
	-- Validate type
	if ability.type ~= "active" and ability.type ~= "passive" then
		minetest.log("error", "[abilityfw] register_ability: type must be 'active' or 'passive'")
		return false
	end
	
	-- Validate on_use callback for active abilities
	if ability.type == "active" and type(ability.on_use) ~= "function" then
		minetest.log("error", "[abilityfw] register_ability: active abilities require an on_use callback function")
		return false
	end
	
	registered_abilities[name] = ability
	minetest.log("action", "[abilityfw] Registered ability: " .. name)
	return true
end

--- Get a registered ability definition
-- @param name string: Unique identifier for the ability
-- @return table|nil: The ability definition or nil if not found
function abilityfw.get_ability(name)
	return registered_abilities[name]
end

--- Get all registered abilities
-- @return table: A copy of all registered abilities
function abilityfw.get_all_abilities()
	local abilities = {}
	for name, def in pairs(registered_abilities) do
		abilities[name] = def
	end
	return abilities
end

--- Check if a player's ability is on cooldown
-- @param player_name string: Name of the player
-- @param ability_name string: Name of the ability
-- @return boolean: true if on cooldown, false otherwise
function abilityfw.is_on_cooldown(player_name, ability_name)
	if not cooldowns[player_name] or not cooldowns[player_name][ability_name] then
		return false
	end
	
	local ability = registered_abilities[ability_name]
	if not ability or ability.cooldown <= 0 then
		return false
	end
	
	local last_use = cooldowns[player_name][ability_name]
	local current_time = os.time()
	
	return (current_time - last_use) < ability.cooldown
end

--- Get remaining cooldown time for an ability
-- @param player_name string: Name of the player
-- @param ability_name string: Name of the ability
-- @return number: Remaining cooldown time in seconds (0 if not on cooldown)
function abilityfw.get_cooldown_remaining(player_name, ability_name)
	if not abilityfw.is_on_cooldown(player_name, ability_name) then
		return 0
	end
	
	local ability = registered_abilities[ability_name]
	local last_use = cooldowns[player_name][ability_name]
	local current_time = os.time()
	local elapsed = current_time - last_use
	
	return math.max(0, ability.cooldown - elapsed)
end

--- Set cooldown for a player's ability
-- @param player_name string: Name of the player
-- @param ability_name string: Name of the ability
function abilityfw.set_cooldown(player_name, ability_name)
	if not cooldowns[player_name] then
		cooldowns[player_name] = {}
	end
	
	cooldowns[player_name][ability_name] = os.time()
end

--- Use an ability
-- @param player ObjectRef: The player using the ability
-- @param ability_name string: Name of the ability to use
-- @return boolean: true if ability was used successfully, false otherwise
-- @return string|nil: Error message if unsuccessful
function abilityfw.use_ability(player, ability_name)
	if not player or not player:is_player() then
		return false, "Invalid player"
	end
	
	local player_name = player:get_player_name()
	local ability = abilityfw.get_ability(ability_name)
	
	if not ability then
		return false, "Ability not found: " .. ability_name
	end
	
	if ability.type ~= "active" then
		return false, "Cannot use passive ability: " .. ability_name
	end
	
	-- Check if player has the ability (will be implemented in player module)
	if abilityfw.player_has_ability and not abilityfw.player_has_ability(player_name, ability_name) then
		return false, "Player does not have ability: " .. ability_name
	end
	
	-- Check cooldown
	if abilityfw.is_on_cooldown(player_name, ability_name) then
		local remaining = abilityfw.get_cooldown_remaining(player_name, ability_name)
		return false, "Ability on cooldown: " .. remaining .. "s remaining"
	end
	
	-- TODO: Check mana cost when mana system is implemented
	-- if player_mana < ability.mana_cost then
	--     return false, "Not enough mana"
	-- end
	
	-- Execute ability callback
	local success, result = pcall(ability.on_use, player, ability)
	
	if not success then
		minetest.log("error", "[abilityfw] Error using ability '" .. ability_name .. "': " .. tostring(result))
		return false, "Ability execution failed: " .. tostring(result)
	end
	
	-- Set cooldown
	abilityfw.set_cooldown(player_name, ability_name)
	
	-- TODO: Deduct mana cost when mana system is implemented
	
	return true, result
end

-- Clean up cooldowns when player leaves
minetest.register_on_leaveplayer(function(player)
	local player_name = player:get_player_name()
	cooldowns[player_name] = nil
end)

minetest.log("action", "[abilityfw] Ability Framework loaded")
