-- GUI (Formspec) for Ability Management
-- Provides the Spellbook/Ability Menu interface

--- Get the ability menu formspec
-- @param player_name string: Name of the player
-- @return string: The formspec string
local function get_ability_menu_formspec(player_name)
	local formspec = "size[10,9]" ..
		"label[0.5,0.5;Ability Menu]"
	
	local abilities = abilityfw.get_player_abilities(player_name)
	local selected = abilityfw.get_selected_ability(player_name)
	
	if #abilities == 0 then
		formspec = formspec .. "label[1,2;You have no abilities yet.]" ..
			"label[1,2.5;Use /grantability to obtain abilities.]"
	else
		-- Create a list of abilities
		local y = 1.5
		local idx = 1
		
		for _, ability_name in ipairs(abilities) do
			local ability = abilityfw.get_ability(ability_name)
			if ability then
				local is_selected = (selected == ability_name)
				local button_prefix = is_selected and ">" or " "
				
				-- Ability type badge
				local type_color = ability.type == "active" and "#00FF00" or "#FFAA00"
				local type_text = ability.type == "active" and "[A]" or "[P]"
				
				-- Cooldown info
				local cooldown_text = ""
				if ability.type == "active" then
					if abilityfw.is_on_cooldown(player_name, ability_name) then
						local remaining = abilityfw.get_cooldown_remaining(player_name, ability_name)
						cooldown_text = " (CD: " .. remaining .. "s)"
					elseif ability.cooldown > 0 then
						cooldown_text = " (CD: " .. ability.cooldown .. "s)"
					end
				end
				
				-- Ability button
				formspec = formspec ..
					"button[0.5," .. y .. ";2,0.8;select_" .. ability_name .. ";" .. button_prefix .. " Select]"
				
				-- Ability info
				formspec = formspec ..
					"label[2.8," .. (y + 0.2) .. ";" .. minetest.formspec_escape(type_text) .. " " .. 
					minetest.formspec_escape(ability.name) .. cooldown_text .. "]"
				
				-- Costs
				if ability.type == "active" then
					local cost_text = ""
					if ability.mana_cost > 0 then
						cost_text = "Mana: " .. ability.mana_cost
					end
					if cost_text ~= "" then
						formspec = formspec ..
							"label[2.8," .. (y + 0.5) .. ";" .. cost_text .. "]"
					end
				end
				
				y = y + 1.2
				idx = idx + 1
				
				-- Add page break if too many abilities
				if idx > 5 then
					break
				end
			end
		end
		
		-- Resource display at bottom
		local mana = abilityfw.get_mana(player_name)
		local max_mana = abilityfw.get_max_mana(player_name)
		local stamina = abilityfw.get_stamina(player_name)
		local max_stamina = abilityfw.get_max_stamina(player_name)
		
		formspec = formspec ..
			"label[0.5,7.5;Current Resources:]" ..
			"label[0.5,8;Mana: " .. mana .. " / " .. max_mana .. "]" ..
			"label[3,8;Stamina: " .. stamina .. " / " .. max_stamina .. "]"
		
		-- Selected ability info
		if selected then
			local sel_ability = abilityfw.get_ability(selected)
			if sel_ability then
				formspec = formspec ..
					"label[6,7.5;Selected: " .. minetest.formspec_escape(sel_ability.name) .. "]"
			end
		end
	end
	
	-- Close button
	formspec = formspec .. "button_exit[8,8;1.5,0.8;close;Close]"
	
	return formspec
end

--- Show the ability menu to a player
-- @param player_name string: Name of the player
function abilityfw.show_ability_menu(player_name)
	local formspec = get_ability_menu_formspec(player_name)
	minetest.show_formspec(player_name, "abilityfw:ability_menu", formspec)
end

-- Handle formspec submissions
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "abilityfw:ability_menu" then
		return
	end
	
	local player_name = player:get_player_name()
	
	-- Handle ability selection
	for field_name, _ in pairs(fields) do
		if field_name:sub(1, 7) == "select_" then
			local ability_name = field_name:sub(8)
			
			-- Verify player has this ability
			if abilityfw.has_ability(player_name, ability_name) then
				local ability = abilityfw.get_ability(ability_name)
				
				-- Only active abilities can be selected
				if ability and ability.type == "active" then
					abilityfw.set_selected_ability(player_name, ability_name)
					minetest.chat_send_player(player_name, "Selected ability: " .. ability.name)
				else
					minetest.chat_send_player(player_name, "Passive abilities cannot be selected")
				end
				
				-- Refresh the formspec
				abilityfw.show_ability_menu(player_name)
			end
			return
		end
	end
end)

-- Register a chat command to open the ability menu
minetest.register_chatcommand("abilities", {
	params = "",
	description = "Open the ability menu",
	func = function(name, param)
		abilityfw.show_ability_menu(name)
		return true, "Opening ability menu..."
	end
})

-- Register keybind for ability menu
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.key_enter_field == "abilityfw:open_menu" then
		abilityfw.show_ability_menu(player:get_player_name())
	end
end)

minetest.log("action", "[abilityfw] GUI loaded")
