dofile(minetest.get_modpath(minetest.get_current_modname()).."/classes.lua")

-- Register Classes

classes:register_class("human", {
	mesh = "character_human.x",
	texture = "character_human.png",
	collisionbox = {-0.3,-1.0,-0.3, 0.3,0.8,0.3},
	physics = {speed=1.0, jump=1.0, gravity=1.0},
	armor_groups = {fleshy=100},
	agility = 1,
	strenght = 1,
	constitution = 1,
	charisma = 1,
})

classes:register_class("dwarf", {
	mesh = "character_dwarf.x",
	texture = "character_dwarf.png",
	collisionbox = {-0.3,-1.0,-0.3, 0.3,0.5,0.3},
	physics = {speed=0.8, jump=1.0, gravity=1.0},
	armor_groups = {fleshy=80},
	agility = 0.9,
	strenght = 1,
	constitution = 1.1,
	charisma = 1,
})

classes:register_class("elf", {
	mesh = "character_elf.x",
	texture = "character_elf.png",
	collisionbox = {-0.3,-1.0,-0.3, 0.3,0.9,0.3},
	physics = {speed=1.2, jump=1.0, gravity=1.0},
	armor_groups = {fleshy=120},
	agility = 1.1,
	strenght = 1,
	constitution = 0.9,
	charisma = 1,
})

--classes:load()

