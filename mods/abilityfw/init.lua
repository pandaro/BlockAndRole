-- Ability Framework for Block & Role
-- Main initialization file

local modpath = minetest.get_modpath("abilityfw")

-- Load API first (core functionality)
dofile(modpath .. "/api.lua")

-- Load player ability management
dofile(modpath .. "/player.lua")

-- Load resource management (mana, stamina)
dofile(modpath .. "/resources.lua")

-- Load HUD management
dofile(modpath .. "/hud.lua")

-- Load GUI/formspec
dofile(modpath .. "/gui.lua")

-- Load input integration
dofile(modpath .. "/input.lua")

-- Load example abilities if enabled
dofile(modpath .. "/examples.lua")

minetest.log("action", "[abilityfw] Ability Framework initialized")
