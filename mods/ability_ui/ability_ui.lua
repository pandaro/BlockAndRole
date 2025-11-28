-- Ability allocator UI using the Flow library (flow.widgets)
-- - Header: player name, total XP, used XP, available XP
-- - Scrollable list of abilities: name | current points | - / + controls | preview
-- - "+" increases preview by 1 and consumes 1 available XP (per-point cost configurable)
-- - "-" decreases preview by 1 and returns 1 XP to available (cannot go below original value)
-- - "+" button background: green when enabled
-- - "-" button background: light blue when enabled
-- - blocked control background: red (control is rendered as non-clickable)
-- - Confirm applies preview values to the current values and updates used/available
-- - Cancel reverts preview and available to snapshot taken at UI open / last confirm
--
-- English-only comments and variable names as requested.
-- No compatibility for legacy clients is implemented.

local gui = flow.widgets

-- Colors (hex)
local COLOR_INC = "#33cc33"   -- green for +
local COLOR_DEC = "#66ccff"   -- light blue for -
local COLOR_BLOCKED = "#ff6666" -- red for blocked
local BUTTON_W = 0.9
local BUTTON_H = 0.8

-- Initialize context values and snapshot on first open
local function ensure_init(ctx)
    ctx.form = ctx.form or {}

    -- Defaults (can be overridden by caller before showing the UI)
    if ctx.form.total_xp == nil then ctx.form.total_xp = 500 end
    if ctx.form.used_xp  == nil then ctx.form.used_xp  = 400 end
    if ctx.form.available_xp == nil then
        ctx.form.available_xp = ctx.form.total_xp - ctx.form.used_xp
    end

    -- Example abilities list (id, name, current value, cost per point)
    -- Caller may set ctx.form.abilities = {...} before showing the GUI to customize
    if not ctx.form.abilities then
        ctx.form.abilities = {
            { id = "a1", name = "Ability 1", value = 100, cost = 1 },
            { id = "a2", name = "Ability 2", value = 50,  cost = 1 },
            { id = "a3", name = "Ability 3", value = 200, cost = 1 },
        }
    end

    -- Snapshot (original) to prevent negative misuse and allow cancel
    if not ctx._orig then
        ctx._orig = {
            available_xp = ctx.form.available_xp,
            abilities = {},
        }
        for _, a in ipairs(ctx.form.abilities) do
            ctx._orig.abilities[a.id] = a.value
            -- initialize preview to current value
            a.preview = a.value
        end
    else
        -- Ensure any newly added abilities have preview and a snapshot value
        for _, a in ipairs(ctx.form.abilities) do
            if a.preview == nil then a.preview = a.value end
            if ctx._orig.abilities[a.id] == nil then
                ctx._orig.abilities[a.id] = a.value
            end
        end
        -- Ensure original available exists
        if ctx._orig.available_xp == nil then
            ctx._orig.available_xp = ctx.form.available_xp
        end
    end
end

-- Build a stack that shows a colored background and a clickable image_button on top,
-- or a non-clickable label on blocked state. Using stack allows overlay so the colored
-- box appears as the button background.
local function colored_button_plus(label_text, color, on_click)
    -- When on_click is nil, render a non-clickable label (blocked)
    if on_click then
        return gui.Stack{
            gui.Box{ color = color, w = BUTTON_W, h = BUTTON_H },
            gui.ImageButton{
                texture_name = "blank.png",
                drawborder = false,
                label = label_text,
                w = BUTTON_W,
                h = BUTTON_H,
                -- callback will be added by caller via on_event
                on_event = on_click,
            }
        }
    else
        -- Blocked: colored background and plain label (not clickable)
        return gui.Stack{
            gui.Box{ color = color, w = BUTTON_W, h = BUTTON_H },
            gui.Label{ label = label_text, min_w = BUTTON_W, align_h = "centre" },
        }
    end
end

-- Main GUI
local ability_gui = flow.make_gui(function(player, ctx)
    ensure_init(ctx)

    local player_name = player:get_player_name()
    local total_xp = ctx.form.total_xp or 0
    local used_xp = ctx.form.used_xp or 0
    local available_xp = ctx.form.available_xp or 0

    -- Header row: player and XP summary
    local header = gui.HBox{
        gui.Label{ label = "Player: " .. player_name, min_w = 6 },
        gui.Label{ label = ("Total XP: %d"):format(total_xp), min_w = 6 },
        gui.Label{ label = ("Used XP: %d"):format(used_xp), min_w = 6 },
        gui.Label{ label = ("Available XP: %d"):format(available_xp), min_w = 6 },
    }

    -- Instructions
    local instructions = gui.Label{
        label = "Use + / - to change previews. Press Confirm to apply changes or Cancel to revert.",
    }

    -- Build ability rows dynamically based on ctx.form.abilities
    local ability_rows = {}
    for idx, a in ipairs(ctx.form.abilities) do
        -- local copies for closures
        local ability_index = idx
        local ability = a
        local orig_value = ctx._orig.abilities[ability.id] or ability.value
        local cost = ability.cost or 1

        -- Determine whether + / - are allowed
        local can_increase = (ctx.form.available_xp or 0) >= cost
        local can_decrease = (ability.preview or ability.value) > orig_value

        -- Current and preview labels
        local current_label = tostring(ability.value)
        local preview_value = ability.preview or ability.value
        local diff = preview_value - ability.value
        local preview_label
        if diff == 0 then
            preview_label = ("Preview: %d"):format(preview_value)
        elseif diff > 0 then
            preview_label = ("Preview: %d (+%d)"):format(preview_value, diff)
        else
            preview_label = ("Preview: %d (%d)"):format(preview_value, diff)
        end

        -- Minus control
        local minus_control
        if can_decrease then
            minus_control = colored_button_plus("-", COLOR_DEC, function(player2, ctx2)
                -- validate server-side and apply
                local ab = ctx2.form.abilities[ability_index]
                local origv = ctx2._orig.abilities[ab.id] or ab.value
                if ab.preview and ab.preview > origv then
                    ab.preview = ab.preview - 1
                    ctx2.form.available_xp = (ctx2.form.available_xp or 0) + cost
                    return true -- request redraw
                end
                return false
            end)
        else
            minus_control = colored_button_plus("-", COLOR_BLOCKED, nil)
        end

        -- Plus control
        local plus_control
        if can_increase then
            plus_control = colored_button_plus("+", COLOR_INC, function(player2, ctx2)
                local ab = ctx2.form.abilities[ability_index]
                local c = ab.cost or 1
                if (ctx2.form.available_xp or 0) >= c then
                    ab.preview = (ab.preview or ab.value) + 1
                    ctx2.form.available_xp = (ctx2.form.available_xp or 0) - c
                    return true
                end
                return false
            end)
        else
            plus_control = colored_button_plus("+", COLOR_BLOCKED, nil)
        end

        -- Each row: name | current | minus | plus | preview
        ability_rows[#ability_rows + 1] = gui.HBox{
            gui.Label{ label = ability.name, min_w = 4 },
            gui.Label{ label = current_label, min_w = 2, align_h = "centre" },
            minus_control,
            plus_control,
            gui.Label{ label = preview_label, min_w = 6, align_h = "start" },
        }
    end

    -- Footer: Confirm and Cancel buttons
    local footer = gui.HBox{
        gui.Button{
            label = "Confirm",
            on_event = function(_, ctx2)
                -- Apply previews to actual values and update used/available
                local total_used = 0
                for _, ab in ipairs(ctx2.form.abilities) do
                    ab.value = ab.preview or ab.value
                    total_used = total_used + (ab.value * (ab.cost or 1))
                    -- Update snapshot so further decreases are limited to new values
                    ctx2._orig.abilities[ab.id] = ab.value
                end
                ctx2.form.used_xp = total_used
                ctx2.form.available_xp = (ctx2.form.total_xp or 0) - total_used
                ctx2._orig.available_xp = ctx2.form.available_xp
                return true
            end,
        },
        gui.Button{
            label = "Cancel",
            on_event = function(_, ctx2)
                -- Revert previews and available to snapshot
                for _, ab in ipairs(ctx2.form.abilities) do
                    ab.preview = ctx2._orig.abilities[ab.id] or ab.value
                end
                ctx2.form.available_xp = ctx2._orig.available_xp or (ctx2.form.total_xp - ctx2.form.used_xp)
                return true
            end,
        },
    }

    -- Wrap ability rows inside a ScrollableVBox
    local abilities_scroll = gui.ScrollableVBox{
        name = "abilities_scroll",
        gui.VBox(ability_rows),
    }

    return gui.VBox{
        min_w = 24, min_h = 12,
        header,
        instructions,
        abilities_scroll,
        footer,
    }
end)

-- Register chat command to show the UI: /abilities
core.register_chatcommand("abilities", {
    privs = {},
    description = "Open the abilities allocator UI",
    func = function(player_name)
        local player = core.get_player_by_name(player_name)
        if not player then
            return false, "Player not found"
        end

        -- Optionally prepare a context with custom values before showing
        local ctx = {
            form = {
                -- Example override: uncomment and change to customize initial state
                -- total_xp = 600,
                -- used_xp = 200,
                -- available_xp = 400,
                -- abilities = {
                --     { id = "a1", name = "Strength", value = 10, cost = 1 },
                --     { id = "a2", name = "Dexterity", value = 8, cost = 1 },
                -- },
            }
        }

        ability_gui:show(player, ctx)
        return true, "Abilities UI shown"
    end,
})

core.register_node("ability_ui:abilities_table", {
    description = "Abilities Table (right-click to open)",
    tiles = {"default_wood.png"},
    inventory_image = "default_wood.png",
    wield_image = "default_wood.png",
    groups = {choppy = 2, oddly_breakable_by_hand = 2},

    -- Right-click handler: open the abilities GUI for the clicking player.
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        if not clicker or not clicker:is_player() then
            return itemstack
        end

        -- Show the GUI without passing a ctx (the GUI will init defaults).
        ability_gui:show(clicker)

        return itemstack
    end,
})

-- Return the GUI so other scripts can require this file and show the UI programmatically
return ability_gui
