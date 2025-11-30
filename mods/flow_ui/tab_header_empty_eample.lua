-- Player menu: migliorie per Tabheader
-- - Forziamo vari campi possibili (items / captions / index / current_tab)
-- - Forziamo w/h e mettiamo il tabheader dentro HBox per evitare posizionamenti errati
-- - Log diagnostico (triesafe) della stringa formspec generata (se formspec_ast è disponibile)
--
-- Copia questo file in mods/flow_ui/player_menu.lua

local gui = flow.widgets
local S = core.get_translator and core.get_translator("flow_ui") or function(s) return s end

local function safe_log_formspec(player, gui_obj)
    -- Prova a costruire l'AST e la stringa formspec per debug; non fallire in caso di errori
    local ok, res = pcall(function()
        -- Tentativi robusti per ottenere l'AST / formspec dalla GUI:
        -- 1) Se la GUI espone _build proviamo a usarla (diverse versioni di flow ce l'hanno)
        if type(gui_obj._build) == "function" then
            -- ctx minimale
            local ctx = { form = {} }
            local tree = gui_obj._build(player, ctx) or {}
            if formspec_ast and type(formspec_ast.unparse) == "function" then
                local fs_str, err = formspec_ast.unparse(tree)
                if fs_str then
                    minetest.log("action", "[flow_ui] formspec (unparse) = " .. tostring(fs_str))
                else
                    minetest.log("warning", "[flow_ui] formspec unparse failed: " .. tostring(err))
                end
            else
                minetest.log("action", "[flow_ui] formspec AST: " .. minetest.serialize(tree))
            end
            return true
        end

        -- 2) Se la GUI è callable, proviamo a chiamarla (alcune API restituiscono direttamente stringa)
        if type(gui_obj) == "function" then
            local maybe_fs = gui_obj(player, { form = {} })
            minetest.log("action", "[flow_ui] gui_callable returned: " .. tostring(maybe_fs))
            return true
        end

        return false
    end)
    if not ok then
        minetest.log("error", "[flow_ui] safe_log_formspec error: " .. tostring(res))
    end
end

local player_menu = flow.make_gui(function(player, ctx)
    -- stato della tab (usa nome unico per evitare collisioni)
    ctx.form._flow_ui_tab = ctx.form._flow_ui_tab or 1
    local active = ctx.form._flow_ui_tab

    -- Build a robust Tabheader description: include both items and captions,
    -- set both index and current_tab, and provide index_event so flow
    -- will redraw on change. We also set explicit width/height.
    local header
    if type(gui.Tabheader) == "function" then
        header = gui.HBox{
            gui.Box{ w = 0.3, h = 1, color = "#0000" },

            gui.Tabheader{
                -- name used to store the selected tab in ctx.form
                name = "_flow_ui_tab",

                -- several possible keys: some codepaths expect `items`, others `captions`
                items = { S("Tab 1"), S("Tab 2"), S("Tab 3") },
                captions = { S("Tab 1"), S("Tab 2"), S("Tab 3") },

                -- compatibilità: alcune versioni usano 'index', altre 'current_tab'
                index = active,
                current_tab = active,

                -- chiedi a flow di notificare quando cambia l'indice
                index_event = true,

                -- dimensioni forzate: molte implementazioni layout richiedono w>0/h>0
                w = 12,
                h = 1,
            },

            gui.Box{ expand = true, color = "#0000" },
        }
    else
        -- Fallback sempre visibile (pulsanti)
        header = gui.HBox{
            gui.Box{ w = 0.3, h = 1, color = "#0000" },

            gui.Button{
                name = "flow_ui_tab1",
                label = (active == 1) and ("❮ " .. S("Tab 1") .. " ❯") or S("Tab 1"),
                on_event = function(_, c)
                    c.form._flow_ui_tab = 1
                    return true
                end,
            },

            gui.Button{
                name = "flow_ui_tab2",
                label = (active == 2) and ("❮ " .. S("Tab 2") .. " ❯") or S("Tab 2"),
                on_event = function(_, c)
                    c.form._flow_ui_tab = 2
                    return true
                end,
            },

            gui.Button{
                name = "flow_ui_tab3",
                label = (active == 3) and ("❮ " .. S("Tab 3") .. " ❯") or S("Tab 3"),
                on_event = function(_, c)
                    c.form._flow_ui_tab = 3
                    return true
                end,
            },

            gui.Box{ expand = true, color = "#0000" },
        }
    end

    -- Contenuti placeholder (una riga per vedere gli effetti)
    local content_tab1 = gui.VBox{
        gui.Label{ label = S("Contenuto Tab 1 (vuoto)") },
    }

    local content_tab2 = gui.VBox{
        gui.Label{ label = S("Contenuto Tab 2 (vuoto)") },
    }

    local content_tab3 = gui.VBox{
        gui.Label{ label = S("Contenuto Tab 3 (vuoto)") },
    }

    local content = content_tab1
    if ctx.form._flow_ui_tab == 2 then content = content_tab2
    elseif ctx.form._flow_ui_tab == 3 then content = content_tab3 end

    -- LOG diagnostico: prova a stampare il formspec AST/stringa (solo lato server)
    -- Non blocca la costruzione della GUI.
    pcall(safe_log_formspec, player, flow and flow.get_context and flow) -- try a harmless call first
    -- Try to log the GUI itself:
    pcall(safe_log_formspec, player, player_menu)

    return gui.VBox{
        min_w = 14,
        min_h = 9,

        gui.Box{ h = 0.2, color = "#0000" },

        header,
        gui.Box{ h = 0.15, color = "#cccccc" },

        content,
    }
end)

return player_menu
