-- flow_ui init: hook the Flow player menu to the inventory key (press "i")
-- Copies of player_menu.lua should be in the same mod directory.
-- Behavior:
--  - When a player joins (or is newly created) the Flow player menu is set
--    as their inventory form (so pressing "i" opens the Flow menu).
--  - Provides a chat command /flow_toggle_inventory to toggle the Flow menu
--    as the player's inventory (useful for testing).
--  - Provides /flow_player_menu to open the menu as a normal Flow HUD/formspec.

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

-- Try to load the player_menu GUI created with flow.make_gui
local ok, player_menu = pcall(dofile, modpath .. "/player_menu.lua")
if not ok then
    minetest.log("error", "[" .. modname .. "] Failed to load player_menu.lua: " .. tostring(player_menu))
    player_menu = nil
end

-- Helper: set flow menu as inventory for a player (best-effort)
local function set_flow_inventory(player)
    if not player_menu then return false end
    -- Prefer the set_as_inventory_for API if present on the object
    if type(player_menu.set_as_inventory_for) == "function" then
        pcall(function() player_menu:set_as_inventory_for(player) end)
        return true
    end
    -- Fallback: if Form:render_to_formspec_string exists, try to render and call player:set_inventory_formspec
    if flow and type(player_menu.render_to_formspec_string) == "function" then
        pcall(function()
            local fs, event, public = player_menu:render_to_formspec_string(player, nil, false)
            if fs and type(player.set_inventory_formspec) == "function" then
                player:set_inventory_formspec(fs)
            end
        end)
        return true
    end
    return false
end

-- Helper: unset flow inventory for a player (restore empty/default)
local function unset_flow_inventory(player)
    if player_menu and type(player_menu.unset_as_inventory_for) == "function" then
        pcall(function() player_menu:unset_as_inventory_for(player) end)
        return true
    end
    -- Fallback: clear inventory formspec
    if type(player.set_inventory_formspec) == "function" then
        pcall(function() player:set_inventory_formspec("") end)
        return true
    end
    return false
end

-- Set the inventory form when a player joins (and for new players)
minetest.register_on_joinplayer(function(player)
    if not player then return end
    if not player_menu then
        minetest.log("warning", "[" .. modname .. "] player_menu not loaded; cannot set Flow inventory for " .. player:get_player_name())
        return
    end
    -- Best-effort, do not error if something goes wrong
    local ok = set_flow_inventory(player)
    if not ok then
        minetest.log("warning", "[" .. modname .. "] Could not set Flow inventory for " .. player:get_player_name())
    end
end)

minetest.register_on_newplayer(function(player)
    if not player then return end
    if player_menu then
        pcall(function() set_flow_inventory(player) end)
    end
end)

-- Clean up on leave (optional)
minetest.register_on_leaveplayer(function(player)
    if not player then return end
    -- Try to remove our inventory override so no stale state remains
    pcall(function() unset_flow_inventory(player) end)
end)

-- Chat command to toggle Flow as inventory for yourself (useful in testing)
minetest.register_chatcommand("flow_toggle_inventory", {
    params = "",
    description = "Toggle Flow UI as your inventory (press 'i' to open).",
    privs = {},
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Player not found" end
        local pn = name
        -- Check current: if open_inv_formspecs tracking is internal to flow we can't easily read it.
        -- We'll simply call set_as_inventory_for if possible; if already set it will reuse ctx.
        if player_menu then
            local success = pcall(function()
                set_flow_inventory(player)
            end)
            if success then
                return true, "Flow inventory enabled for you (press 'i' to open)."
            else
                return false, "Failed to enable Flow inventory; check server log."
            end
        end
        return false, "Flow player_menu not loaded on server."
    end,
})

-- Chat command to manually open the player menu (non-inventory show)
minetest.register_chatcommand("flow_player_menu", {
    params = "",
    description = "Open the Flow player menu (non-inventory mode) for testing.",
    privs = {},
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if not player then return false, "Player not found" end
        if not player_menu then return false, "player_menu not available" end
        -- Prefer the :show API if present
        if type(player_menu.show) == "function" then
            pcall(function() player_menu:show(player) end)
            return true, "Opened Flow player menu."
        end
        -- Fallback: try to use set_as_inventory_for to present it as inventory
        if pcall(function() set_flow_inventory(player) end) then
            return true, "Opened Flow player menu as inventory."
        end
        return false, "Could not open Flow player menu; check server log."
    end,
})
