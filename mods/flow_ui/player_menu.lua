-- Player menu: "Info" (first page) + "Inventory"
-- Simple, linear style inspired by ability_ui.
-- - Tab 1: Info page with centered player image, name, HP, XP and race.
-- - Tab 2: Player inventory (main + hotbar).
-- Copy this file to mods/flow_ui/player_menu.lua

local gui = flow.widgets
local S = core.get_translator and core.get_translator("flow_ui") or function(s) return s end

local function ensure_defaults(ctx, player)
    ctx.form = ctx.form or {}

    -- Default player name is the actual player name if available.
    if ctx.form.player_name == nil and player and player.get_player_name then
        ctx.form.player_name = player:get_player_name()
    elseif ctx.form.player_name == nil then
        ctx.form.player_name = S("Unknown")
    end

    if ctx.form.hp == nil then ctx.form.hp = 20 end
    if ctx.form.hp_max == nil then ctx.form.hp_max = 20 end

    if ctx.form.xp == nil then ctx.form.xp = 0 end
    if ctx.form.xp_max == nil then ctx.form.xp_max = 100 end

    if ctx.form.race == nil then ctx.form.race = S("Dwarf") end

    -- Get player attributes from classes
    if player and player.get_player_name then
        local name = player:get_player_name()
        local class = classes and classes.class and classes.class[name]
        local properties = classes and classes.properties and class and classes.properties[class]
        
        if properties then
            ctx.form.agility = properties.agility or 1
            ctx.form.strenght = properties.strenght or 1
            ctx.form.constitution = properties.constitution or 1
            ctx.form.charisma = properties.charisma or 1
        else
            ctx.form.agility = ctx.form.agility or 1
            ctx.form.strenght = ctx.form.strenght or 1
            ctx.form.constitution = ctx.form.constitution or 1
            ctx.form.charisma = ctx.form.charisma or 1
        end
    else
        ctx.form.agility = ctx.form.agility or 1
        ctx.form.strenght = ctx.form.strenght or 1
        ctx.form.constitution = ctx.form.constitution or 1
        ctx.form.charisma = ctx.form.charisma or 1
    end
end

local player_menu = flow.make_gui(function(player, ctx)
    -- active tab index
    ctx.form._flow_ui_tab = ctx.form._flow_ui_tab or 1
    local active = ctx.form._flow_ui_tab

    -- ensure info defaults
    ensure_defaults(ctx, player)

    -- Top header (empty or minimal)
    local header = gui.Box{ h = 0.1, color = "#0000" }

    -- Tab header: Info + Inventory
    local header_tabs = gui.HBox{
        gui.Box{ w = 0.3, h = 1, color = "#0000" },
        gui.Tabheader{
            name = "_flow_ui_tab",
            items = { S("Info"), S("Inventory") },
            captions = { S("Info"), S("Inventory") },
            index = active,
            current_tab = active,
            index_event = true,
            w = 12,
            h = 1,
        },
        gui.Box{ expand = true, color = "#0000" },
    }

    -- Centered player image placeholder (replace "character.png" with a real texture/model preview)
    local player_image = gui.Image{
        texture_name = "character.png",
        w = 4,
        h = 4,
        align_h = "centre",
    }

    -- Frame for the image (background box + centered image)
    local image_frame = gui.Stack{
        gui.Box{ w = 5, h = 5, color = "#444444" },
        gui.VBox{
            gui.Box{ h = 0.3, color = "#0000" },
            gui.HBox{
                gui.Box{ expand = true, color = "#0000" },
                player_image,
                gui.Box{ expand = true, color = "#0000" },
            },
            gui.Box{ h = 0.3, color = "#0000" },
        },
    }

    -- Info page content: data on left, image in center
    local info_content = gui.VBox{
        gui.Box{ h = 0.2, color = "#0000" },
        header,
        gui.Box{ h = 0.3, color = "#0000" },
        gui.HBox{
            gui.Box{ w = 0.5, color = "#0000" },
            gui.VBox{
                gui.Label{ label = S("Name: ") .. tostring(ctx.form.player_name) },
                gui.Label{ label = S("Race: ") .. tostring(ctx.form.race) },
                gui.Label{ label = S("XP: ") .. tostring(ctx.form.xp) .. " / " .. tostring(ctx.form.xp_max) },
                gui.Label{ label = S("HP: ") .. tostring(ctx.form.hp) .. " / " .. tostring(ctx.form.hp_max) },
                gui.Box{ h = 0.2, color = "#0000" },
                gui.Label{ label = S("Strenght: ") .. tostring(ctx.form.strenght) },
                gui.Label{ label = S("Agility: ") .. tostring(ctx.form.agility) },
                gui.Label{ label = S("Constitution: ") .. tostring(ctx.form.constitution) },
                gui.Label{ label = S("Charisma: ") .. tostring(ctx.form.charisma) },
            },
            gui.Box{ w = 1, color = "#0000" },
            image_frame,
            gui.Box{ expand = true, color = "#0000" },
        },
    }

    -- Inventory page: main grid + hotbar
    local inv_grid = gui.List{
        w = 9,
        h = 3,
        inventory_location = "current_player",
        list_name = "main",
    }

    local hotbar = gui.List{
        w = 9,
        h = 1,
        inventory_location = "current_player",
        list_name = "main",
    }

    local inventory_area = gui.VBox{
        gui.Box{ h = 0.2, color = "#0000" },
        inv_grid,
        gui.Box{ h = 0.15, color = "#0000" },
        hotbar,
    }

    local content_tab1 = info_content
    local content_tab2 = gui.HBox{
        gui.Box{ expand = true, color = "#0000" },
        inventory_area,
        gui.Box{ expand = true, color = "#0000" },
    }

    local content = (ctx.form._flow_ui_tab == 1) and content_tab1 or content_tab2

    return gui.VBox{
        min_w = 14,
        min_h = 10,

        gui.Box{ h = 0.2, color = "#0000" },

        header_tabs,
        gui.Box{ h = 0.12, color = "#cccccc" },

        content,
    }
end)

return player_menu
