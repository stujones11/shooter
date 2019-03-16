minetest.register_craftitem("shooter_rocket:rocket", {
	description = "Rocket",
    stack_max = 1,
	inventory_image = "shooter_rocket_inv.png",
})

minetest.register_entity("shooter_rocket:rocket_entity", {
	physical = false,
	timer = 0,
	visual = "cube",
	visual_size = {x=1/8, y=1/8},
	textures = {
		"shooter_bullet.png",
		"shooter_bullet.png",
		"shooter_bullet.png",
		"shooter_bullet.png",
		"shooter_bullet.png",
		"shooter_bullet.png",
	},
	user = nil,
	collisionbox = {0,0,0, 0,0,0},
	on_activate = function(self, staticdata)
		if staticdata == "expired" then
			self.object:remove()
		end
	end,
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if self.timer > 0.2 then
			local pos = self.object:get_pos()
			local above = {x=pos.x, y=pos.y + 1, z=pos.z}
			if minetest.get_node(pos).name ~= "air" then
				if self.user then
					local player = minetest.get_player_by_name(self.user)
					if player then
						shooter:blast(above, 4, 50, 8, player)
					end
				end
				self.object:remove()
			end
			self.timer = 0
		end
	end,
	get_staticdata = function(self)
		return "expired"
	end,
})

minetest.register_tool("shooter_rocket:rocket_gun_loaded", {
	description = "Rocket Gun",
	inventory_image = "shooter_rocket_gun_loaded.png",
	groups = {not_in_creative_inventory=1},
	on_use = function(itemstack, user, pointed_thing)
		if not minetest.setting_getbool("creative_mode") then
			itemstack:add_wear(65535 / 50)
		end
		itemstack = "shooter_rocket:rocket_gun 1 "..itemstack:get_wear()
		if pointed_thing.type ~= "nothing" then
			local pointed = minetest.get_pointed_thing_position(pointed_thing)
			if vector.distance(user:get_pos(), pointed) < 8 then
				shooter:blast(pointed, 2, 50, 7)
				return itemstack
			end
		end
		local pos = user:get_pos()
		local dir = user:get_look_dir()
		local yaw = user:get_look_horizontal()
		if pos and dir and yaw then
			pos.y = pos.y + shooter.config.camera_height
			local obj = minetest.add_entity(pos, "shooter_rocket:rocket_entity")
			if obj then
				minetest.sound_play("shooter_rocket_fire", {object=obj})
				obj:set_velocity(vector.multiply(dir, 20))
				obj:set_acceleration({x=dir.x * -3, y=-10, z=dir.z * -3})
				obj:set_yaw(yaw + math.pi / 2)
				local ent = obj:get_luaentity()
				if ent then
					ent.user = user:get_player_name()
				end
			end
		end
		return itemstack
	end,
})

minetest.register_tool("shooter_rocket:rocket_gun", {
	description = "Rocket Gun",
	inventory_image = "shooter_rocket_gun.png",
	on_use = function(itemstack, user, pointed_thing)
		local inv = user:get_inventory()
		if inv:contains_item("main", "shooter_rocket:rocket") then
			minetest.sound_play("shooter_reload", {object=user})
			if not minetest.setting_getbool("creative_mode") then
				inv:remove_item("main", "shooter_rocket:rocket 1")
			end
			itemstack = "shooter_rocket:rocket_gun_loaded 1 "..itemstack:get_wear()
		else
			minetest.sound_play("shooter_click", {object=user})
		end
		return itemstack
	end,
})

if shooter.config.enable_crafting == true then
	minetest.register_craft({
		output = "shooter_rocket:rocket_gun",
		recipe = {
			{"default:bronze_ingot", "default:steel_ingot", "default:steel_ingot"},
			{"", "", "default:diamond"},
		},
	})
	minetest.register_craft({
		output = "shooter_rocket:rocket",
		recipe = {
			{"default:bronze_ingot", "tnt:gunpowder", "default:bronze_ingot"},
		},
	})
end

--Backwards compatibility
minetest.register_alias("shooter:rocket", "shooter_rocket:rocket")
minetest.register_alias("shooter:rocket_gun", "shooter_rocket:rocket_gun")
minetest.register_alias("shooter:rocket_gun_loaded", "shooter_rocket:rocket_gun_loaded")


