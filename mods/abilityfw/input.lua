-- Input Integration for Ability Framework
-- Handles keybinds for using abilities and showing feedback

-- Register custom controls
minetest.register_on_mods_loaded(function()
	-- Note: Custom keybinds need to be defined in the client
	-- For now we'll use aux1 which is typically the special key
end)

-- Handle aux1 (special key) to use selected ability
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.key_aux1 then
		local player_name = player:get_player_name()
		local ability_name = abilityfw.get_selected_ability(player_name)
		
		if ability_name then
			use_selected_ability(player)
		else
			minetest.chat_send_player(player_name, "No ability selected. Use /abilities to select one.")
		end
	end
end)

-- Use the selected ability
local function use_selected_ability(player)
	local player_name = player:get_player_name()
	local ability_name = abilityfw.get_selected_ability(player_name)
	
	if not ability_name then
		show_feedback(player, "No ability selected", "error")
		return
	end
	
	local success, message = abilityfw.use_ability(player, ability_name)
	
	if success then
		show_feedback(player, message or "Ability used!", "success")
	else
		show_feedback(player, message or "Failed to use ability", "error")
	end
end

-- Show visual feedback to player
local function show_feedback(player, message, feedback_type)
	local player_name = player:get_player_name()
	local color = feedback_type == "success" and "#00FF00" or "#FF0000"
	
	-- Send chat message with color
	minetest.chat_send_player(player_name, minetest.colorize(color, message))
	
	-- Add temporary HUD element for visual feedback
	local hud_id = player:hud_add({
		hud_elem_type = "text",
		position = {x = 0.5, y = 0.5},
		offset = {x = 0, y = -50},
		text = message,
		alignment = {x = 0, y = 0},
		scale = {x = 100, y = 100},
		number = feedback_type == "success" and 0x00FF00 or 0xFF0000,
	})
	
	-- Remove the HUD element after 2 seconds
	minetest.after(2, function()
		if player and player:is_player() then
			player:hud_remove(hud_id)
		end
	end)
end

-- Make the function available to other modules
abilityfw.use_selected_ability = use_selected_ability

-- Register a chat command to use the selected ability (alternative to keybind)
minetest.register_chatcommand("useselected", {
	params = "",
	description = "Use the currently selected ability",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "Player not found"
		end
		
		use_selected_ability(player)
		return true
	end
})

-- Register right-click to use ability
-- NOTE: Commented out because minetest.register_on_item_use does not exist in Minetest API
-- To implement this feature, you would need to register a specific item with on_use callback
--[[
minetest.register_on_item_use(function(itemstack, user, pointed_thing)
	-- Check if player is right-clicking without an item or with specific item
	-- This is a placeholder - in real implementation, you might want a special item
	-- or detect when not clicking on a node
	
	if not user or not user:is_player() then
		return
	end
	
	-- Only trigger if not clicking on a node and not holding a tool/item
	if pointed_thing.type == "nothing" and itemstack:is_empty() then
		use_selected_ability(user)
		return itemstack
	end
end)
--]]

-- Override use_ability to integrate mana cost checking
local original_use_ability = abilityfw.use_ability
function abilityfw.use_ability(player, ability_name)
	if not player or not player:is_player() then
		return false, "Invalid player"
	end
	
	local player_name = player:get_player_name()
	local ability = abilityfw.get_ability(ability_name)
	
	if not ability then
		return false, "Ability not found: " .. ability_name
	end
	
	-- Check mana cost
	if ability.mana_cost and ability.mana_cost > 0 then
		local current_mana = abilityfw.get_mana(player_name)
		if current_mana < ability.mana_cost then
			return false, "Not enough mana (need " .. ability.mana_cost .. ", have " .. current_mana .. ")"
		end
	end
	
	-- Use original function
	local success, message = original_use_ability(player, ability_name)
	
	-- Deduct mana if successful
	if success and ability.mana_cost and ability.mana_cost > 0 then
		abilityfw.add_mana(player_name, -ability.mana_cost)
	end
	
	return success, message
end

minetest.log("action", "[abilityfw] Input integration loaded")
