local default_class = core.setting_get("classes_default_class")
if not default_class then
	default_class = "human"
	core.setting_set("classes_default_class", default_class)
end
local has_skin_changer = core.get_modpath("player_textures") or core.get_modpath("skins")
local has_3d_armor = core.get_modpath("3d_armor")

classes = {
	properties = {},
}

classes.register_class = function(self, class, properties)
	self.properties[class] = properties
end

-- Get player class from meta
classes.get_class = function(self, player)
	if not player then
		return default_class
	end
	local class = player:get_meta():get_string('class')
	if class == "" then
		return default_class
	end
	return class
end

-- Set player class in meta
classes.set_class = function(self, player, class)
	if not player then
		return false
	end
	player:get_meta():set_string('class', class)
	return true
end

classes.update_player_visuals = function(self, player)
	if not player then
		return
	end
	local class = classes:get_class(player)
	local properties = classes.properties[class]
	local mesh = ""
	local texture = properties.texture
--[[
	if has_3d_armor	then
		mesh = "3d_armor_"
	end
--]]
	mesh = mesh..properties.mesh
	player:set_properties({
		visual = "mesh",
		mesh = mesh,
		collisionbox = properties.collisionbox,
		visual_size = {x=1, y=1},
	})
	if not has_skin_changer then
		player:set_properties({textures={texture}})
--[[
		if has_3d_armor	then
			uniskins:update_player_visuals(player)
		end
]]--
	end
	local physics = properties.physics
	--player:set_physics_override(physics.speed, physics.jump, physics.gravity)
	player:set_armor_groups(properties.armor_groups)
end

core.register_privilege("class", "Player can change class.")

core.register_chatcommand("class", {
	params = "[class]",
	description = "Change or view character class.",
	func = function(name, class)
		local player = core.get_player_by_name(name)
		if not player then
			return false, "Player not found"
		end
		
		if class == "" then
			local current_class = classes:get_class(player)
			core.chat_send_player(name, "Current character class: "..current_class)
			return
		end
		if not core.check_player_privs(name, {class=true}) then
			core.chat_send_player(name, "Changing class requires the 'class' privilege!")
			return
		end
		if not classes.properties[class] then
			local valid = ""
			for k,_ in pairs(classes.properties) do
				valid = valid.." "..k
			end
			core.chat_send_player(name, "Invalid class '"..class.."', choose from:"..valid)
			return
		end
		local current_class = classes:get_class(player)
		if current_class == class then
			return
		end
		classes:set_class(player, class)
		classes:update_player_visuals(player)
	end,
})

core.register_on_joinplayer(function(player)
	if not player then
		return
	end
	local class = classes:get_class(player)
	if class == default_class and player:get_meta():get_string('class') == "" then
		classes:set_class(player, default_class)
	end
	core.after(1, function(player)
		classes:update_player_visuals(player)
	end, player)
end)

