-- Simple player menu with 2 tabs implemented using buttons (Flow)
-- - Provides the chat command /playermenu to open the menu (uses flow.make_gui)
-- - Tab switching is done via server-handled buttons to ensure reliable events
--   inside the inventory formspec (set_as_inventory_for).
-- - Comments and variable names are English-only as requested.

local gui = flow.widgets

local player_menu = flow.make_gui(function(player, ctx)
    ctx = ctx or {}
    ctx.form = ctx.form or {}

    -- store selected tab index in ctx.form.player_tab (1 or 2)
    if ctx.form.player_tab == nil then
        ctx.form.player_tab = 1
    end

    -- Header with two buttons acting as tabs
    local tab_buttons = gui.HBox{
        -- Button "Tab 1" sets player_tab = 1
        gui.Button{
            label = "Tab 1",
            on_event = function(_, ctx2)
                if ctx2.form.player_tab ~= 1 then
                    ctx2.form.player_tab = 1
                    return true -- force redraw
                end
                return false
            end,
        },
        -- Button "Tab 2" sets player_tab = 2
        gui.Button{
            label = "Tab 2",
            on_event = function(_, ctx2)
                if ctx2.form.player_tab ~= 2 then
                    ctx2.form.player_tab = 2
                    return true -- force redraw
                end
                return false
            end,
        },
    }

    -- Empty content placeholders for each tab (can be filled later)
    local content
    if ctx.form.player_tab == 1 then
        content = gui.VBox{
            gui.Label{ label = " " }, -- placeholder for Tab 1
        }
    else
        content = gui.VBox{
            gui.Label{ label = " " }, -- placeholder for Tab 2
        }
    end

    return gui.VBox{
        min_w = 12, min_h = 8,
        tab_buttons,
        content,
    }
end)

-- Chat command to open the menu: /playermenu
core.register_chatcommand("playermenu", {
    privs = {},
    description = "Open simple player menu (2 tabs via buttons)",
    func = function(name)
        local player = core.get_player_by_name(name)
        if not player then
            return false, "Player not found"
        end
        player_menu:show(player)
        return true, "Player menu opened"
    end,
})

-- Return the GUI object for reuse by other mods/scripts
return player_menu
