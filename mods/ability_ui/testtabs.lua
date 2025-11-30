-- Temporary test: show a raw formspec with a tabheader
-- Usage: in-game run /testtabs
-- Purpose: verify whether the client's formspec renders a tabheader at all.

core.register_chatcommand("testtabs", {
    privs = {},
    description = "Show a raw formspec with a tabheader (debug)",
    func = function(name)
        local player = core.get_player_by_name(name)
        if not player then
            return false, "Player not found"
        end

        -- formspec: size, tabheader and a label below to show content area
        -- Note: tabheader syntax: tabheader[X,Y;name;caption1,caption2;current_index]
        -- current_index is zero-based for the raw formspec.
        local fs = table.concat({
            "size[8,6]",
            "tabheader[0,0;player_tab;Player,Inventory;0]",
            "label[0,1;This is tab 1 content placeholder]",
        }, "")

        core.show_formspec(name, "ability_ui:testtabs", fs)
        return true, "Test formspec shown"
    end,
})