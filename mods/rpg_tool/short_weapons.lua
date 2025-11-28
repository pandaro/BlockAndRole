local weapons = {
	{id = 'sword1',name = 'sword1',cut= 2 },
	{id = 'sword2',name = 'sword2',cut= 4 },
	{id = 'sword3',name = 'sword3',cut= 6 },
	{id = 'axe1',name = 'axe1',cut= 1, impact = 1 },
	{id = 'axe2',name = 'axe2',cut= 2, impact = 2 },
	{id = 'axe3',name = 'axe3',cut= 3, impact = 3 },
	{id = 'hammer1',name = 'hammer1',impact= 2 },
	{id = 'hammer2',name = 'hammer2',impact= 4 },
	{id = 'hammer3',name = 'hammer3',impact= 6 },
}


rpg_tool.short_weapons_set = function(self,stack,player,external)
print(dump(stack:to_table()))
	print(dump(player:get_player_name()))
	--local stack = player:get_wielded_item()
	local rpgTool = stack:get_definition()._rpg
	if not rpgTool then return end
 	local meta = stack:get_meta()
	local caps = stack:get_definition().tool_capabilities
	meta:set_int('palette_index',1)
	meta:set_string('owner',player:get_player_name())
	local newcut = caps.damage_groups.cut or 0 * player:get_attribute('cut') or 0
	local newimpact = caps.damage_groups.impact or 0 * player:get_attribute('impact') or 0
	meta:set_tool_capabilities({
 		max_drop_level=0,
 		groupcaps = caps.groupcaps,
 		damage_groups = {cut = newcut, impact = newimpact},
 	})
		return stack

end

local function create_rpg_short_weapons()
	for index, params in pairs(weapons) do
		minetest.register_tool('rpg_tool:'..params.name,{
			description = params.description or params.name,
			inventory_image = params.inventory_image,
			_rpg = true,
			palette='green.png',

			wield_scale = {x = 1,y = 1, z = 1},
			on_place = function(itemstack, placer, pointed_thing)
				print('on_placestart')
				rpg_tool:short_weapons_set(itemstack,placer)
				return itemstack
			end,
			on_secondary_use = function(itemstack, user, pointed_thing)
				print('on_placestart')
				rpg_tool:short_weapons_set(itemstack,user)
				return itemstack
			end,
			tool_capabilities = {
            full_punch_interval = params.tool_capabilities or 1.0,
            max_drop_level = params.max_drop_level or 0,
            groupcaps = {
                -- groupcaps non necessari per arma pura, lasciamo vuoto o minimo
            },
			damage_groups = { cut = params.cut or 0,impact = params.impact or 0 },


        },

		})
	end
end

create_rpg_short_weapons()
