-- Example abilities for Block & Role
-- These demonstrate the ability framework in action

-- Example Active Ability: Fireball
abilityfw.register_ability("fireball", {
	name = "Fireball",
	type = "active",
	cooldown = 10,
	mana_cost = 25,
	on_use = function(player, ability_def)
		local player_name = player:get_player_name()
		minetest.chat_send_player(player_name, "You cast Fireball! (Cooldown: " .. ability_def.cooldown .. "s)")
		
		-- In a full implementation, this would:
		-- 1. Get player's look direction
		-- 2. Spawn a fireball entity
		-- 3. Deal damage to targets
		-- For now, just a placeholder message
		
		return "Fireball launched!"
	end
})

-- Example Active Ability: Heal
abilityfw.register_ability("heal", {
	name = "Heal",
	type = "active",
	cooldown = 30,
	mana_cost = 40,
	on_use = function(player, ability_def)
		local player_name = player:get_player_name()
		local hp = player:get_hp()
		local max_hp = 20  -- Default max HP in Minetest
		
		if hp >= max_hp then
			return "Already at full health!"
		end
		
		local heal_amount = 10
		local new_hp = math.min(hp + heal_amount, max_hp)
		player:set_hp(new_hp)
		
		minetest.chat_send_player(player_name, "You heal yourself for " .. (new_hp - hp) .. " HP!")
		return "Healed for " .. (new_hp - hp) .. " HP"
	end
})

-- Example Active Ability: Teleport
abilityfw.register_ability("teleport", {
	name = "Teleport",
	type = "active",
	cooldown = 60,
	mana_cost = 50,
	on_use = function(player, ability_def)
		local player_name = player:get_player_name()
		local pos = player:get_pos()
		local dir = player:get_look_dir()
		
		-- Teleport 10 nodes in look direction
		local new_pos = {
			x = pos.x + dir.x * 10,
			y = pos.y + dir.y * 10,
			z = pos.z + dir.z * 10
		}
		
		player:set_pos(new_pos)
		minetest.chat_send_player(player_name, "You teleport forward!")
		
		return "Teleported!"
	end
})

-- Example Passive Ability: Swift Feet
abilityfw.register_ability("swift_feet", {
	name = "Swift Feet",
	type = "passive",
})

-- Example Passive Ability: Mana Regeneration
abilityfw.register_ability("mana_regen", {
	name = "Mana Regeneration",
	type = "passive",
})

-- Register a chat command to test abilities
minetest.register_chatcommand("useability", {
	params = "<ability_name>",
	description = "Use an ability (for testing)",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "Player not found"
		end
		
		if param == "" then
			return false, "Usage: /useability <ability_name>"
		end
		
		local success, message = abilityfw.use_ability(player, param)
		return success, message or "Ability used"
	end
})

-- Register a chat command to grant abilities (for testing)
minetest.register_chatcommand("grantability", {
	params = "<ability_name>",
	description = "Grant yourself an ability (for testing)",
	func = function(name, param)
		if param == "" then
			return false, "Usage: /grantability <ability_name>"
		end
		
		local success = abilityfw.grant_ability(name, param)
		if success then
			return true, "Granted ability: " .. param
		else
			return false, "Failed to grant ability: " .. param
		end
	end
})

-- Register a chat command to list abilities
minetest.register_chatcommand("listabilities", {
	params = "",
	description = "List all your abilities",
	func = function(name, param)
		local abilities = abilityfw.get_player_abilities(name)
		
		if #abilities == 0 then
			return true, "You have no abilities. Use /grantability to get some!"
		end
		
		local ability_list = "Your abilities:\n"
		for _, ability_name in ipairs(abilities) do
			local ability = abilityfw.get_ability(ability_name)
			if ability then
				local cooldown_text = ""
				if abilityfw.is_on_cooldown(name, ability_name) then
					local remaining = abilityfw.get_cooldown_remaining(name, ability_name)
					cooldown_text = " (cooldown: " .. remaining .. "s)"
				end
				ability_list = ability_list .. "- " .. ability.name .. 
					" (" .. ability.type .. ")" .. cooldown_text .. "\n"
			end
		end
		
		return true, ability_list
	end
})

-- Register a chat command to list all registered abilities
minetest.register_chatcommand("allabilities", {
	params = "",
	description = "List all registered abilities in the game",
	func = function(name, param)
		local all_abilities = abilityfw.get_all_abilities()
		
		local count = 0
		for _ in pairs(all_abilities) do
			count = count + 1
		end
		
		if count == 0 then
			return true, "No abilities registered"
		end
		
		local ability_list = "All registered abilities:\n"
		for ability_name, ability in pairs(all_abilities) do
			ability_list = ability_list .. "- " .. ability_name .. 
				": " .. ability.name .. 
				" (" .. ability.type .. 
				", CD: " .. ability.cooldown .. "s" ..
				", Mana: " .. ability.mana_cost .. ")\n"
		end
		
		return true, ability_list
	end
})

minetest.log("action", "[abilityfw] Example abilities and commands loaded")
