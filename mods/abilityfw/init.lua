abilityfw={}
abilityfw.ability_list={
	pick = 0,
	sword = 0,
	durability = 0,
	tool = 0,
	
}
abilityfw.base=[[  
size[10,10]
bgcolor[#5A5A5A;false]
label[0,0;XP points]

label[1,1;ABILITY]
label[1,3;Pick]
label[1,4;Sword]
label[1,5;Tool]
label[1,6;Durability]

label[0,1;CURRENT]

label[3,1;ADD]


button[3,2.5;1,1;pick;+]
button[3,3.5;1,1;sword;+]
button[3,4.5;1,1;tool;+]
button[3,5.5;1,1;durability;+]

background[0,3;1,1;aaa]
background[0,4;1,1;aaa]
background[0,5;1,1;aaa]
background[0,6;1,1;aaa]
]]	

minetest.register_on_newplayer(function(obj)
	print(dump(obj))
	for name, value in pairs( abilityfw.ability_list )do
		obj:set_attribute(name,value)
	end

print('join')
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	
	print('field received')
	print(tostring(formname))
	print(dump(fields))
	if formname == 'abilityfw' and not fields.quit then 
		for name, value in pairs(fields) do
			if tonumber(player:get_attribute('xpPoints')) < 1 then break end
			print(tostring(player:get_attribute(name))) 
			
			player:set_attribute(name,player:get_attribute(name)+1)
			player:set_attribute('xpPoints',player:get_attribute('xpPoints')-1)
			print(tostring(player:get_attribute(name))) 
			
		end
		abilityfw.redraw(player)
		minetest.show_formspec(player:get_player_name(), 'abilityfw', player:get_attribute('ability_layout'))
		
	end
end)
abilityfw.redraw = function(player)
			player:set_attribute('ability_layout',abilityfw.base .. 
				
			'label[2,0;'..player:get_attribute('xpPoints')..']'..
			'label[0,3;'..player:get_attribute('pick')..']'..
			'label[0,4;'..player:get_attribute('sword')..']'..
			'label[0,5;'..player:get_attribute('tool')..']'..
			'label[0,6;'..player:get_attribute('durability')..']')
end
	
minetest.register_node('abilityfw:table',{
	description = "test 1",
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		print(tostring(clicker:get_attribute('xpPoints')))
		abilityfw.redraw(clicker)
		minetest.show_formspec(clicker:get_player_name(), 'abilityfw', clicker:get_attribute('ability_layout'))
	end,
	
})