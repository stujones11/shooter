local function throw_hook(itemstack, user, vel)
	local inv = user:get_inventory()
	local pos = user:get_pos()
	local dir = user:get_look_dir()
	local yaw = user:get_look_horizontal()
	if pos and dir and yaw then
		if not minetest.setting_getbool("creative_mode") then
			itemstack:add_wear(65535 / 100)
		end
		pos.y = pos.y + 1.5
		local obj = minetest.add_entity(pos, "shooter_hook:hook")
		if obj then
			minetest.sound_play("shooter_throw", {object=obj})
			obj:set_velocity(vector.multiply(dir, vel))
			obj:set_acceleration({x=dir.x * -3, y=-10, z=dir.z * -3})
			obj:set_yaw(yaw + math.pi / 2)
			local ent = obj:get_luaentity()
			if ent then
				ent.user = user:get_player_name()
				ent.itemstack = itemstack
			end
		end
	end
end

minetest.register_entity("shooter_hook:hook", {
	physical = true,
	timer = 0,
	visual = "wielditem",
	visual_size = {x=1/2, y=1/2},
	textures = {"shooter_hook:grapple_hook"},
	user = nil,
	itemstack = "",
	collisionbox = {-1/4,-1/4,-1/4, 1/4,1/4,1/4},
	on_activate = function(self, staticdata)
		self.object:set_armor_groups({fleshy=0})
		if staticdata == "expired" then
			self.object:remove()
		end
	end,
	on_step = function(self, dtime)
		if not self.user then
			return
		end
		self.timer = self.timer + dtime
		if self.timer > 0.25 then
			local pos = self.object:get_pos()
			local below = {x=pos.x, y=pos.y - 1, z=pos.z}
			local node = minetest.get_node(below)
			if node.name ~= "air" then
				self.object:set_velocity({x=0, y=-10, z=0})
				self.object:set_acceleration({x=0, y=0, z=0})
				if minetest.get_item_group(node.name, "liquid") == 0 and
						minetest.get_node(pos).name == "air" then
					local player = minetest.get_player_by_name(self.user)
					if player then
						player:moveto(pos)
					end
				end
				if minetest.get_item_group(node.name, "lava") == 0 then
					minetest.add_item(pos, self.itemstack)
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

minetest.register_tool("shooter_hook:grapple_hook", {
	description = "Grappling Hook",
	inventory_image = "shooter_hook.png",
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type ~= "nothing" then
			return itemstack
		end
		throw_hook(itemstack, user, 14)
		return ""
	end,
})

minetest.register_tool("shooter_hook:grapple_gun", {
	description = "Grappling Gun",
	inventory_image = "shooter_hook_gun.png",
	on_use = function(itemstack, user, pointed_thing)
		local inv = user:get_inventory()
		if inv:contains_item("main", "shooter_hook:grapple_hook") and 
				inv:contains_item("main", "tnt:gunpowder") then
			inv:remove_item("main", "tnt:gunpowder")
			minetest.sound_play("shooter_reload", {object=user})
			local stack = inv:remove_item("main", "shooter_hook:grapple_hook")
			itemstack = "shooter_hook:grapple_gun_loaded 1 "..stack:get_wear()
		else
			minetest.sound_play("shooter_click", {object=user})
		end
		return itemstack
	end,
})

minetest.register_tool("shooter_hook:grapple_gun_loaded", {
	description = "Grappling Gun",
	inventory_image = "shooter_hook_gun_loaded.png",
	groups = {not_in_creative_inventory=1},
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type ~= "nothing" then
			return itemstack
		end
		minetest.sound_play("shooter_pistol", {object=user})
		itemstack = ItemStack("shooter_hook:grapple_hook 1 "..itemstack:get_wear())
		throw_hook(itemstack, user, 20)
		return "shooter_hook:grapple_gun"
	end,
})

if shooter.config.enable_crafting == true then
	minetest.register_craft({
		output = "shooter_hook:grapple_hook",
		recipe = {
			{"default:steel_ingot", "default:steel_ingot", "default:diamond"},
			{"default:steel_ingot", "default:steel_ingot", ""},
			{"default:diamond", "", "default:steel_ingot"},
		},
	})
	minetest.register_craft({
		output = "shooter_hook:grapple_gun",
		recipe = {
			{"", "default:steel_ingot", "default:steel_ingot"},
			{"", "", "default:diamond"},
		},
	})
end

--Backwards compatibility
minetest.register_alias("shooter:grapple_hook", "shooter_hook:grapple_hook")
minetest.register_alias("shooter:grapple_gun", "shooter_hook:grapple_gun")
minetest.register_alias("shooter:grapple_gun_loaded", "shooter_hook:grapple_gun_loaded")
