# Ability Framework

The foundational ability system for Block & Role, supporting skill-based gameplay and modular ability definitions.

## Features

- **Flexible Ability Definition**: Define abilities with names, types (active/passive), cooldowns, and mana costs
- **Registration API**: Simple `register_ability()` and `get_ability()` functions
- **Player Management**: Grant, revoke, and check abilities per player
- **Server-Side Cooldowns**: Prevent client-side manipulation with server-authoritative cooldown tracking
- **Persistence**: Player abilities automatically saved to metadata
- **Extensible**: Ready for integration with skill trees, mana systems, and combat
- **HUD Overlay**: Displays selected ability, cooldown indicator, and resource bars for mana and stamina
- **Ability Menu GUI**: Interactive formspec-based menu for viewing and selecting abilities
- **Resource System**: Full mana and stamina management with persistence
- **Input Integration**: Keybinds and commands for using abilities with visual feedback

## Usage

### Ability Menu and HUD

Players can access their abilities through:

1. **Ability Menu** - Use `/abilities` command to open the graphical ability menu
2. **HUD Display** - See your selected ability, cooldown status, and resource bars on-screen
3. **Using Abilities** - Use `/useselected` command or right-click with empty hand to use the selected ability

### Registering an Ability

```lua
abilityfw.register_ability("fireball", {
    name = "Fireball",
    type = "active",
    cooldown = 10,
    mana_cost = 25,
    on_use = function(player, ability_def)
        -- Your ability implementation
        return "Fireball launched!"
    end
})
```

### Granting Abilities to Players

```lua
-- Grant an ability to a player
abilityfw.grant_ability("player_name", "fireball")

-- Check if player has an ability
if abilityfw.has_ability("player_name", "fireball") then
    print("Player has fireball!")
end

-- Revoke an ability
abilityfw.revoke_ability("player_name", "fireball")
```

### Using Abilities

```lua
local player = minetest.get_player_by_name("player_name")
local success, message = abilityfw.use_ability(player, "fireball")

if success then
    print("Success: " .. message)
else
    print("Failed: " .. message)
end
```

## API Documentation

See [API.md](API.md) for complete API documentation.

## Testing

The mod includes example abilities and chat commands for testing:

1. `/allabilities` - List all registered abilities
2. `/grantability <ability_name>` - Grant yourself an ability
3. `/listabilities` - List your current abilities
4. `/useability <ability_name>` - Use an ability directly
5. `/abilities` - Open the ability menu GUI
6. `/useselected` - Use the currently selected ability

### Example Test Flow

```
/allabilities
/grantability fireball
/listabilities
/abilities          # Opens GUI to select ability
/useselected        # Uses the selected ability
```

### HUD Elements

The HUD displays:
- **Top Center**: Currently selected ability name
- **Below Ability**: Cooldown indicator bar (green progress bar)
- **Top Left**: Mana bar (blue) and Stamina bar (orange)

### Resource Management

Players start with 100 mana and 100 stamina. Using abilities consumes mana based on the ability's `mana_cost`. Resources are persisted across sessions.

## Integration

### With Skill Trees

```lua
-- When player unlocks an ability in skill tree
abilityfw.grant_ability(player_name, "fireball")
```

### With Mana Systems

The framework now includes a full mana and stamina system:

```lua
-- Get player's current mana
local mana = abilityfw.get_mana(player_name)

-- Set mana
abilityfw.set_mana(player_name, 50)

-- Add mana
abilityfw.add_mana(player_name, 25)

-- Abilities automatically deduct mana when used
```

### With Combat Systems

Ability callbacks receive the player object and ability definition:

```lua
on_use = function(player, ability_def)
    -- Get player position and direction
    local pos = player:get_pos()
    local dir = player:get_look_dir()
    
    -- Spawn projectile, deal damage, etc.
    
    return "Effect description"
end
```

## Architecture

The mod is organized into:

- `api.lua` - Core ability registration and cooldown management
- `player.lua` - Player ability management and persistence
- `resources.lua` - Mana and stamina resource management
- `hud.lua` - HUD overlay for abilities and resource bars
- `gui.lua` - Formspec-based ability menu
- `input.lua` - Keybind and input handling for using abilities
- `examples.lua` - Example abilities and testing commands
- `init.lua` - Module initialization

## Future Work

This framework is designed to evolve with the game. Future enhancements may include:

- Integration with skill tree system (Issue #5)
- Mana system integration
- Ability visual effects and particles
- Advanced cooldown UI
- Ability combos and synergies
- Passive ability buff system

## License

Part of the Block & Role project. See repository for license details.
