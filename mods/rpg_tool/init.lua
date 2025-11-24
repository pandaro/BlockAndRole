rpg_tool={}
local timer = 0
	
rpg_tool.tool_set = function(self,stack,player,external)
print(dump(stack:to_table()))
	print(dump(player:get_player_name()))
	--local stack = player:get_wielded_item()
	local rpgTool = stack:get_definition()._rpg
	if not rpgTool then return end
 	local meta = stack:get_meta()
	local caps = stack:get_definition().tool_capabilities
	meta:set_int('palette_index',1)
	meta:set_string('owner',player:get_player_name())
	local new_uses = caps.groupcaps.cracky.uses + player:get_attribute('durability')
	local new_time_3 = caps.groupcaps.cracky.times[3] * 1 - (player:get_attribute('tool')/10)
	local new_time_2 = caps.groupcaps.cracky.times[2] * 1 - (player:get_attribute('tool')/10)
	local new_damage = caps.damage_groups.fleshy * 1 + (player:get_attribute('sword')/10)
	meta:set_tool_capabilities({
 		max_drop_level=0,
 		groupcaps={
 			cracky={times={[2]=0.1, [3]=0.1}, uses=new_uses, maxlevel=1}
 		},
 		damage_groups = {fleshy=new_damage},
 	})
		return stack
	
end


minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 1 then
		-- Send "Minetest" to all players every 5 seconds
		for i, v in pairs(minetest.get_connected_players())do
			print(' globalstep')
			local stack= v:get_wielded_item()
			if stack:get_definition()._rpg then
				local meta = stack:get_meta()
				local name = meta:get_string('owner')
				print(tostring('name '..name))
				if name ~= v:get_player_name() and name ~= '' then
					local wear = stack:get_wear()
					local stackname = stack:get_name()
					v:set_wielded_item({name = stackname, wear = wear, meta=nil})
					print(' global STOP')
				end
			end
		end
		timer = 0
	end
end)
-- minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
-- 		print('punchnode')
-- 		local stack = puncher:get_wielded_item()
-- 		local new_stack = rpg_tool:tool_set(stack,puncher)
-- 		puncher:set_wielded_item(new_stack)
-- 		
-- 	end)
-- 
-- minetest.register_on_punchplayer(function(player, hitter)
-- 	print(tostring('punchplayer'))
-- 	local stack = hitter:get_wielded_item()
-- 	local new_stack = rpg_tool:tool_set(stack,hitter)
-- 	hitter:set_wielded_item(new_stack)
-- 	
-- 
-- end)
	
minetest.register_tool("rpg_tool:1", {
	description = "rpg_tool 1",
	inventory_image = "default_tool_steelaxe.png",
	palette='m.png',
	_rpg = true,
	base_tool = 'rpg_tool:2',

	on_place = function(itemstack, placer, pointed_thing)
		print('on_placestart')
		rpg_tool:tool_set(itemstack,placer)
		return itemstack
	end,
	on_secondary_use = function(itemstack, user, pointed_thing)
		print('on_placestart')
		rpg_tool:tool_set(itemstack,user)
		return itemstack
	end,

	tool_capabilities = {
		max_drop_level=0,
		groupcaps={
			cracky={times={[2]=2.00, [3]=2.00}, uses=10, maxlevel=1}
		},
		damage_groups = {fleshy=2},
	},
})