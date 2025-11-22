# Ability Framework API Documentation

## Overview

The Ability Framework provides a modular system for defining and managing abilities in Block & Role. It supports both active abilities (spells, skills) and passive abilities (traits, buffs), with server-side cooldown management and player ability tracking.

## Core API Functions

### Ability Registration

#### `abilityfw.register_ability(name, def)`

Register a new ability definition.

**Parameters:**
- `name` (string): Unique identifier for the ability
- `def` (table): Ability definition with the following fields:
  - `id` (string, optional): Defaults to `name`
  - `name` (string): Display name for the ability
  - `type` (string): Either "active" or "passive"
  - `cooldown` (number, optional): Cooldown in seconds (default: 0)
  - `mana_cost` (number, optional): Mana cost to use (default: 0)
  - `on_use` (function, required for active abilities): Callback function with signature `function(player, ability_def)`

**Returns:** `boolean` - true if registered successfully, false otherwise

**Example:**
```lua
abilityfw.register_ability("fireball", {
    name = "Fireball",
    type = "active",
    cooldown = 10,
    mana_cost = 25,
    on_use = function(player, ability_def)
        -- Your ability logic here
        return "Fireball launched!"
    end
})
```

#### `abilityfw.get_ability(name)`

Get a registered ability definition.

**Parameters:**
- `name` (string): Unique identifier for the ability

**Returns:** `table|nil` - The ability definition or nil if not found

**Example:**
```lua
local fireball = abilityfw.get_ability("fireball")
if fireball then
    print(fireball.name)  -- "Fireball"
    print(fireball.cooldown)  -- 10
end
```

#### `abilityfw.get_all_abilities()`

Get all registered abilities.

**Returns:** `table` - A copy of all registered abilities (key-value pairs)

**Example:**
```lua
local all_abilities = abilityfw.get_all_abilities()
for ability_name, ability_def in pairs(all_abilities) do
    print(ability_name, ability_def.name)
end
```

### Player Ability Management

#### `abilityfw.grant_ability(player_name, ability_name)`

Grant an ability to a player.

**Parameters:**
- `player_name` (string): Name of the player
- `ability_name` (string): Name of the ability to grant

**Returns:** `boolean` - true if granted successfully, false otherwise

**Example:**
```lua
abilityfw.grant_ability("player1", "fireball")
```

#### `abilityfw.revoke_ability(player_name, ability_name)`

Revoke an ability from a player.

**Parameters:**
- `player_name` (string): Name of the player
- `ability_name` (string): Name of the ability to revoke

**Returns:** `boolean` - true if revoked successfully, false otherwise

**Example:**
```lua
abilityfw.revoke_ability("player1", "fireball")
```

#### `abilityfw.has_ability(player_name, ability_name)`

Check if a player has an ability.

**Parameters:**
- `player_name` (string): Name of the player
- `ability_name` (string): Name of the ability to check

**Returns:** `boolean` - true if player has the ability, false otherwise

**Example:**
```lua
if abilityfw.has_ability("player1", "fireball") then
    print("Player has fireball ability")
end
```

#### `abilityfw.get_player_abilities(player_name)`

Get all abilities for a player.

**Parameters:**
- `player_name` (string): Name of the player

**Returns:** `table` - List of ability names the player has

**Example:**
```lua
local abilities = abilityfw.get_player_abilities("player1")
for _, ability_name in ipairs(abilities) do
    print(ability_name)
end
```

### Cooldown Management

#### `abilityfw.is_on_cooldown(player_name, ability_name)`

Check if a player's ability is on cooldown.

**Parameters:**
- `player_name` (string): Name of the player
- `ability_name` (string): Name of the ability

**Returns:** `boolean` - true if on cooldown, false otherwise

**Example:**
```lua
if abilityfw.is_on_cooldown("player1", "fireball") then
    print("Fireball is on cooldown")
end
```

#### `abilityfw.get_cooldown_remaining(player_name, ability_name)`

Get remaining cooldown time for an ability.

**Parameters:**
- `player_name` (string): Name of the player
- `ability_name` (string): Name of the ability

**Returns:** `number` - Remaining cooldown time in seconds (0 if not on cooldown)

**Example:**
```lua
local remaining = abilityfw.get_cooldown_remaining("player1", "fireball")
if remaining > 0 then
    print("Cooldown: " .. remaining .. " seconds")
end
```

#### `abilityfw.set_cooldown(player_name, ability_name)`

Set cooldown for a player's ability. This is typically called automatically by `use_ability()`.

**Parameters:**
- `player_name` (string): Name of the player
- `ability_name` (string): Name of the ability

**Example:**
```lua
abilityfw.set_cooldown("player1", "fireball")
```

### Using Abilities

#### `abilityfw.use_ability(player, ability_name)`

Use an ability.

**Parameters:**
- `player` (ObjectRef): The player using the ability
- `ability_name` (string): Name of the ability to use

**Returns:** 
- `boolean` - true if ability was used successfully, false otherwise
- `string|nil` - Result message or error message if unsuccessful

**Example:**
```lua
local player = minetest.get_player_by_name("player1")
local success, message = abilityfw.use_ability(player, "fireball")
if success then
    print("Ability used: " .. message)
else
    print("Failed: " .. message)
end
```

## Chat Commands (for testing)

The framework includes several chat commands for testing:

- `/useability <ability_name>` - Use an ability
- `/grantability <ability_name>` - Grant yourself an ability
- `/listabilities` - List all your abilities
- `/allabilities` - List all registered abilities in the game

## Example Abilities

The framework includes several example abilities:

### Active Abilities

1. **Fireball** (`fireball`)
   - Cooldown: 10 seconds
   - Mana Cost: 25
   - Effect: Placeholder for launching a fireball

2. **Heal** (`heal`)
   - Cooldown: 30 seconds
   - Mana Cost: 40
   - Effect: Heals the player for 10 HP

3. **Teleport** (`teleport`)
   - Cooldown: 60 seconds
   - Mana Cost: 50
   - Effect: Teleports the player 10 nodes forward

### Passive Abilities

1. **Swift Feet** (`swift_feet`)
   - Effect: Placeholder for movement speed bonus

2. **Mana Regeneration** (`mana_regen`)
   - Effect: Placeholder for mana regeneration

## Integration with Skill Trees

The ability framework is designed to integrate with skill tree systems. When implementing skill trees:

1. Use `abilityfw.grant_ability()` when a player unlocks an ability in their skill tree
2. Use `abilityfw.revoke_ability()` if abilities can be unlearned or reset
3. Check `abilityfw.has_ability()` to verify prerequisites

## Persistence

Player abilities are automatically saved to player metadata and persisted across sessions. The framework handles:

- Loading abilities when a player joins
- Saving abilities when a player leaves
- Saving abilities immediately when granted/revoked

## Future Integration Points

The framework includes placeholder comments for future integration with:

- **Mana System**: Check and deduct mana costs when using abilities
- **Combat System**: Integration with damage dealing and effects
- **Entity System**: Spawning projectiles and effects
- **Skill Tree**: Automatic ability unlocking based on skill progression

## Notes

- All cooldowns are server-side to prevent client-side manipulation
- Player abilities persist across server restarts
- The framework is designed to be modular and extensible
- Passive abilities don't have `on_use` callbacks - their effects should be implemented separately (e.g., in a buff system or physics modifier)
