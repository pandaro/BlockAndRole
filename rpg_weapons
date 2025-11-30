-- mods/rpg_weapons/init.lua
-- Registrazione di 9 armi da mischia di esempio:
-- 3 spade (solo danno da taglio: 2,4,6)
-- 3 martelli (solo danno da impatto: 2,4,6)
-- 3 asce (taglio+imp: 1-1, 2-2, 3-3)
--
-- Ogni arma espone anche _rpg_weapon = {cut = X, impact = Y}
-- così puoi distinguere i tipi di danno nel tuo sistema combat personalizzato.

local modname = "rpg_weapons"

local weapons = {
    -- Swords: pure cutting
    {id = "sword_cut_2",   title = "Sword (Cut) II",    cut = 2, impact = 0, img = "rpg_sword_cut_2.png"},
    {id = "sword_cut_4",   title = "Sword (Cut) IV",    cut = 4, impact = 0, img = "rpg_sword_cut_4.png"},
    {id = "sword_cut_6",   title = "Sword (Cut) VI",    cut = 6, impact = 0, img = "rpg_sword_cut_6.png"},

    -- Hammers: pure impact
    {id = "hammer_imp_2",  title = "Hammer (Impact) II",cut = 0, impact = 2, img = "rpg_hammer_imp_2.png"},
    {id = "hammer_imp_4",  title = "Hammer (Impact) IV",cut = 0, impact = 4, img = "rpg_hammer_imp_4.png"},
    {id = "hammer_imp_6",  title = "Hammer (Impact) VI",cut = 0, impact = 6, img = "rpg_hammer_imp_6.png"},

    -- Axes: mixed cutting + impact (1-1, 2-2, 3-3)
    {id = "axe_mix_1",     title = "Axe (Mix) I",      cut = 1, impact = 1, img = "rpg_axe_mix_1.png"},
    {id = "axe_mix_2",     title = "Axe (Mix) II",     cut = 2, impact = 2, img = "rpg_axe_mix_2.png"},
    {id = "axe_mix_3",     title = "Axe (Mix) III",    cut = 3, impact = 3, img = "rpg_axe_mix_3.png"},
}

for _, w in ipairs(weapons) do
    local name = modname .. ":" .. w.id
    local total_dmg = (w.cut or 0) + (w.impact or 0)

    minetest.register_tool(name, {
        description = w.title .. " (Cut:"..(w.cut or 0)..", Imp:"..(w.impact or 0)..")",
        inventory_image = w.img,
        wield_scale = {x=1, y=1, z=1},
        -- tool_capabilities: semplice esempio; puoi adattare full_punch_interval e groupcaps
        tool_capabilities = {
            full_punch_interval = 1.0,
            max_drop_level = 0,
            groupcaps = {
                -- groupcaps non necessari per arma pura, lasciamo vuoto o minimo
            },
            damage_groups = { fleshy = total_dmg },
        },
        -- Campo personalizzato utile per distinguerne le componenti
        _rpg_weapon = { cut = w.cut or 0, impact = w.impact or 0 },
        -- Nota: puoi intercettare on_use con abilityfw/your combat code se necessario
    })
end