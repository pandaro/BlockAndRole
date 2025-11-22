#!/usr/bin/env lua5.1

-- Simple test script for the ability framework
-- This simulates the Minetest API to test our logic

print("=== Ability Framework Test Suite ===\n")

-- Mock Minetest API
minetest = {
	log = function(level, msg)
		print("[" .. level .. "] " .. msg)
	end,
	serialize = function(data)
		-- Simple serialization for testing
		return table.concat(data, ",")
	end,
	deserialize = function(str)
		-- Simple deserialization for testing
		local result = {}
		for item in string.gmatch(str, "[^,]+") do
			table.insert(result, item)
		end
		return result
	end,
	get_modpath = function(modname)
		return "."
	end,
	register_on_joinplayer = function(func) end,
	register_on_leaveplayer = function(func) end,
	register_chatcommand = function(name, def) end,
	get_player_by_name = function(name)
		return nil -- Simulate offline player for basic tests
	end,
	chat_send_player = function(name, msg)
		print("[CHAT to " .. name .. "] " .. msg)
	end
}

-- Factory function to create mock players
local function create_mock_player(name)
	return {
		_name = name,
		_hp = 15,
		_pos = {x=0, y=0, z=0},
		_meta = {},
		
		is_player = function(self)
			return true
		end,
		
		get_player_name = function(self)
			return self._name
		end,
		
		get_hp = function(self)
			return self._hp
		end,
		
		set_hp = function(self, hp)
			self._hp = hp
		end,
		
		get_pos = function(self)
			return self._pos
		end,
		
		set_pos = function(self, pos)
			self._pos = pos
		end,
		
		get_look_dir = function(self)
			return {x=1, y=0, z=0}
		end,
		
		get_meta = function(self)
			return {
				get_string = function(_, key)
					return self._meta[key] or ""
				end,
				set_string = function(_, key, value)
					self._meta[key] = value
				end
			}
		end
	}
end

-- Mock player object
local mock_player = create_mock_player("test_player")

-- Load the ability framework
dofile("api.lua")
dofile("player.lua")

-- Test 1: Ability Registration
print("\n--- Test 1: Ability Registration ---")
local success = abilityfw.register_ability("test_fireball", {
	name = "Test Fireball",
	type = "active",
	cooldown = 5,
	mana_cost = 20,
	on_use = function(player, ability_def)
		return "Test fireball used!"
	end
})
print("Register active ability: " .. (success and "PASS" or "FAIL"))

success = abilityfw.register_ability("test_passive", {
	name = "Test Passive",
	type = "passive"
})
print("Register passive ability: " .. (success and "PASS" or "FAIL"))

-- Test invalid registration
success = abilityfw.register_ability("invalid", {
	name = "Invalid",
	type = "active"
	-- Missing on_use callback
})
print("Reject invalid ability: " .. (not success and "PASS" or "FAIL"))

-- Test 2: Get Ability
print("\n--- Test 2: Get Ability ---")
local ability = abilityfw.get_ability("test_fireball")
print("Get registered ability: " .. (ability ~= nil and "PASS" or "FAIL"))
print("Ability name: " .. (ability and ability.name or "N/A"))
print("Ability cooldown: " .. (ability and ability.cooldown or "N/A"))

-- Test 3: Player Ability Management
print("\n--- Test 3: Player Ability Management ---")
local player_name = "test_player"

-- Grant ability
success = abilityfw.grant_ability(player_name, "test_fireball")
print("Grant ability: " .. (success and "PASS" or "FAIL"))

-- Check has ability
local has = abilityfw.has_ability(player_name, "test_fireball")
print("Has ability: " .. (has and "PASS" or "FAIL"))

-- Check doesn't have ungranted ability
has = abilityfw.has_ability(player_name, "test_passive")
print("Doesn't have ungranted ability: " .. (not has and "PASS" or "FAIL"))

-- Get player abilities
local abilities = abilityfw.get_player_abilities(player_name)
print("Get player abilities count: " .. (#abilities == 1 and "PASS" or "FAIL (" .. #abilities .. ")"))

-- Revoke ability
success = abilityfw.revoke_ability(player_name, "test_fireball")
print("Revoke ability: " .. (success and "PASS" or "FAIL"))

-- Verify revoked
has = abilityfw.has_ability(player_name, "test_fireball")
print("Ability revoked: " .. (not has and "PASS" or "FAIL"))

-- Test 4: Cooldown Management
print("\n--- Test 4: Cooldown Management ---")
abilityfw.grant_ability(player_name, "test_fireball")

-- Check not on cooldown initially
local on_cooldown = abilityfw.is_on_cooldown(player_name, "test_fireball")
print("Not on cooldown initially: " .. (not on_cooldown and "PASS" or "FAIL"))

-- Set cooldown
abilityfw.set_cooldown(player_name, "test_fireball")

-- Check is on cooldown
on_cooldown = abilityfw.is_on_cooldown(player_name, "test_fireball")
print("On cooldown after set: " .. (on_cooldown and "PASS" or "FAIL"))

-- Check remaining time
local remaining = abilityfw.get_cooldown_remaining(player_name, "test_fireball")
print("Cooldown remaining: " .. remaining .. "s (should be ~5)")
print("Cooldown remaining valid: " .. (remaining > 0 and remaining <= 5 and "PASS" or "FAIL"))

-- Test 5: Use Ability
print("\n--- Test 5: Use Ability ---")

-- Clear cooldown from previous test by using a new ability
abilityfw.revoke_ability(player_name, "test_fireball")
abilityfw.register_ability("test_nocooldown", {
	name = "Test No Cooldown",
	type = "active",
	cooldown = 0,
	on_use = function(player, ability_def)
		return "No cooldown ability used!"
	end
})
abilityfw.grant_ability(player_name, "test_nocooldown")

-- Override minetest.get_player_by_name to return our mock player
minetest.get_player_by_name = function(name)
	if name == player_name then
		return mock_player
	end
	return nil
end

-- Use ability
success, message = abilityfw.use_ability(mock_player, "test_nocooldown")
print("Use ability: " .. (success and "PASS" or "FAIL"))
print("Return message: " .. (message or "N/A"))

-- Now test with cooldown ability (use a fresh player to avoid cooldown from Test 4)
local cooldown_test_player = create_mock_player("cooldown_test")
abilityfw.grant_ability("cooldown_test", "test_fireball")
success, message = abilityfw.use_ability(cooldown_test_player, "test_fireball")
print("Use ability with cooldown: " .. (success and "PASS" or "FAIL"))

-- Try to use again (should fail due to cooldown)
success, message = abilityfw.use_ability(cooldown_test_player, "test_fireball")
print("Cooldown prevents use: " .. (not success and "PASS" or "FAIL"))
print("Error message: " .. (message or "N/A"))

-- Try to use ability player doesn't have
success, message = abilityfw.use_ability(mock_player, "test_passive")
print("Can't use ability not owned: " .. (not success and "PASS" or "FAIL"))

-- Test 6: Persistence
print("\n--- Test 6: Persistence ---")

-- Use a fresh player name for this test
local persist_player = create_mock_player("persist_test")
local persist_player_name = persist_player:get_player_name()

abilityfw.grant_ability(persist_player_name, "test_fireball")
abilityfw.grant_ability(persist_player_name, "test_passive")

-- Save abilities
abilityfw.save_player_abilities(persist_player)
local saved_data = persist_player._meta["abilityfw:abilities"]
print("Save player abilities: " .. (saved_data ~= "" and "PASS" or "FAIL"))
print("Saved data: " .. saved_data)

-- Clear and reload
abilityfw.revoke_ability(persist_player_name, "test_fireball")
abilityfw.revoke_ability(persist_player_name, "test_passive")
abilities = abilityfw.get_player_abilities(persist_player_name)
print("Abilities cleared: " .. (#abilities == 0 and "PASS" or "FAIL"))

-- Load from metadata
abilityfw.load_player_abilities(persist_player)
abilities = abilityfw.get_player_abilities(persist_player_name)
print("Load player abilities: " .. (#abilities == 2 and "PASS" or "FAIL"))
print("Loaded abilities count: " .. #abilities)

-- Test 7: Get All Abilities
print("\n--- Test 7: Get All Abilities ---")
local all_abilities = abilityfw.get_all_abilities()
local count = 0
for _ in pairs(all_abilities) do
	count = count + 1
end
print("Get all abilities: " .. (count >= 2 and "PASS" or "FAIL"))
print("Total abilities registered: " .. count)

print("\n=== Test Suite Complete ===")
