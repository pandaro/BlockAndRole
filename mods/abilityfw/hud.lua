-- HUD Management for Ability Framework
-- Displays selected ability, cooldowns, and resource bars

-- Storage for player HUD elements
-- Structure: player_huds[player_name] = {ability_text = id, cooldown_bar = id, mana_bar = id, stamina_bar = id}
local player_huds = {}

-- Storage for selected abilities
-- Structure: selected_abilities[player_name] = ability_name
local selected_abilities = {}

-- HUD position constants
local HUD_ABILITY_POS = {x = 0.5, y = 0.95}
local HUD_COOLDOWN_POS = {x = 0.5, y = 0.90}
local HUD_MANA_POS = {x = 0.02, y = 0.95}
local HUD_STAMINA_POS = {x = 0.02, y = 0.90}

--- Initialize HUD for a player
-- @param player ObjectRef: The player object
local function init_hud(player)
	if not player or not player:is_player() then
		return
	end
	
	local player_name = player:get_player_name()
	
	if player_huds[player_name] then
		return -- Already initialized
	end
	
	player_huds[player_name] = {}
	
	-- Ability display
	player_huds[player_name].ability_text = player:hud_add({
		hud_elem_type = "text",
		position = HUD_ABILITY_POS,
		offset = {x = 0, y = 0},
		text = "No Ability Selected",
		alignment = {x = 0, y = 0},
		scale = {x = 100, y = 100},
		number = 0xFFFFFF,
	})
	
	-- Cooldown bar
	player_huds[player_name].cooldown_bar = player:hud_add({
		hud_elem_type = "statbar",
		position = HUD_COOLDOWN_POS,
		offset = {x = 0, y = 0},
		text = "default_cloud.png^[colorize:#00FF00:180",
		number = 0,
		direction = 0,
		size = {x = 24, y = 24},
		alignment = {x = 0, y = 0},
	})
	
	-- Mana bar
	player_huds[player_name].mana_bar = player:hud_add({
		hud_elem_type = "statbar",
		position = HUD_MANA_POS,
		offset = {x = 0, y = 0},
		text = "default_cloud.png^[colorize:#0088FF:180",
		number = 20,
		direction = 0,
		size = {x = 24, y = 24},
		alignment = {x = 1, y = 0},
	})
	
	-- Mana label
	player_huds[player_name].mana_text = player:hud_add({
		hud_elem_type = "text",
		position = HUD_MANA_POS,
		offset = {x = 30, y = 0},
		text = "Mana",
		alignment = {x = 1, y = 0},
		scale = {x = 100, y = 100},
		number = 0x0088FF,
	})
	
	-- Stamina bar
	player_huds[player_name].stamina_bar = player:hud_add({
		hud_elem_type = "statbar",
		position = HUD_STAMINA_POS,
		offset = {x = 0, y = 0},
		text = "default_cloud.png^[colorize:#FFAA00:180",
		number = 20,
		direction = 0,
		size = {x = 24, y = 24},
		alignment = {x = 1, y = 0},
	})
	
	-- Stamina label
	player_huds[player_name].stamina_text = player:hud_add({
		hud_elem_type = "text",
		position = HUD_STAMINA_POS,
		offset = {x = 30, y = 0},
		text = "Stamina",
		alignment = {x = 1, y = 0},
		scale = {x = 100, y = 100},
		number = 0xFFAA00,
	})
end

--- Remove HUD elements for a player
-- @param player ObjectRef: The player object
local function remove_hud(player)
	if not player or not player:is_player() then
		return
	end
	
	local player_name = player:get_player_name()
	
	if not player_huds[player_name] then
		return
	end
	
	for _, hud_id in pairs(player_huds[player_name]) do
		player:hud_remove(hud_id)
	end
	
	player_huds[player_name] = nil
end

--- Update ability display on HUD
-- @param player ObjectRef: The player object
local function update_ability_display(player)
	if not player or not player:is_player() then
		return
	end
	
	local player_name = player:get_player_name()
	
	if not player_huds[player_name] then
		return
	end
	
	local ability_name = selected_abilities[player_name]
	local text = "No Ability Selected"
	local cooldown_number = 0
	
	if ability_name then
		local ability = abilityfw.get_ability(ability_name)
		if ability then
			text = "Selected: " .. ability.name
			
			-- Update cooldown bar
			if abilityfw.is_on_cooldown(player_name, ability_name) then
				local remaining = abilityfw.get_cooldown_remaining(player_name, ability_name)
				local progress = (ability.cooldown - remaining) / ability.cooldown
				cooldown_number = math.floor(progress * 20)
			else
				cooldown_number = 20
			end
		end
	end
	
	player:hud_change(player_huds[player_name].ability_text, "text", text)
	player:hud_change(player_huds[player_name].cooldown_bar, "number", cooldown_number)
end

--- Update resource bars on HUD
-- @param player ObjectRef: The player object
local function update_resource_bars(player)
	if not player or not player:is_player() then
		return
	end
	
	local player_name = player:get_player_name()
	
	if not player_huds[player_name] then
		return
	end
	
	local mana = abilityfw.get_mana(player_name)
	local max_mana = abilityfw.get_max_mana(player_name)
	local stamina = abilityfw.get_stamina(player_name)
	local max_stamina = abilityfw.get_max_stamina(player_name)
	
	local mana_number = math.floor((mana / max_mana) * 20)
	local stamina_number = math.floor((stamina / max_stamina) * 20)
	
	player:hud_change(player_huds[player_name].mana_bar, "number", mana_number)
	player:hud_change(player_huds[player_name].stamina_bar, "number", stamina_number)
end

--- Set the selected ability for a player
-- @param player_name string: Name of the player
-- @param ability_name string: Name of the ability to select (or nil to deselect)
function abilityfw.set_selected_ability(player_name, ability_name)
	selected_abilities[player_name] = ability_name
	
	-- Save to metadata
	local player = minetest.get_player_by_name(player_name)
	if player then
		local meta = player:get_meta()
		meta:set_string("abilityfw:selected_ability", ability_name or "")
		update_ability_display(player)
	end
end

--- Get the selected ability for a player
-- @param player_name string: Name of the player
-- @return string|nil: Name of the selected ability or nil
function abilityfw.get_selected_ability(player_name)
	return selected_abilities[player_name]
end

--- Load selected ability from metadata
-- @param player ObjectRef: The player object
local function load_selected_ability(player)
	if not player or not player:is_player() then
		return
	end
	
	local player_name = player:get_player_name()
	local meta = player:get_meta()
	local ability_name = meta:get_string("abilityfw:selected_ability")
	
	if ability_name ~= "" then
		selected_abilities[player_name] = ability_name
	end
end

-- Initialize HUD when player joins
minetest.register_on_joinplayer(function(player)
	load_selected_ability(player)
	minetest.after(0.5, function()
		init_hud(player)
		update_ability_display(player)
		update_resource_bars(player)
	end)
end)

-- Remove HUD when player leaves
minetest.register_on_leaveplayer(function(player)
	remove_hud(player)
	local player_name = player:get_player_name()
	selected_abilities[player_name] = nil
end)

-- Update HUD periodically
local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	
	if timer >= 0.5 then
		timer = 0
		
		for _, player in ipairs(minetest.get_connected_players()) do
			update_ability_display(player)
			update_resource_bars(player)
		end
	end
end)

minetest.log("action", "[abilityfw] HUD management loaded")
