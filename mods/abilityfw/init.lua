-- Ability Framework for Block & Role
-- Main initialization file

local modpath = minetest.get_modpath("abilityfw")

-- Load API first (core functionality)
dofile(modpath .. "/api.lua")

-- Load player ability management
dofile(modpath .. "/player.lua")

-- Load example abilities if enabled
dofile(modpath .. "/examples.lua")

minetest.log("action", "[abilityfw] Ability Framework initialized")
