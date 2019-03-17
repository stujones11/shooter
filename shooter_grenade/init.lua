--[[
Shooter Grenade [shooter_grenade]
Copyright (C) 2013-2019 stujones11, Stuart Jones

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation; either version 2.1 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
]]--

minetest.register_entity("shooter_grenade:grenade_entity", {
	physical = false,
	timer = 0,
	visual = "cube",
	visual_size = {x=1/8, y=1/8},
	textures = {
		"shooter_grenade.png",
		"shooter_grenade.png",
		"shooter_grenade.png",
		"shooter_grenade.png",
		"shooter_grenade.png",
		"shooter_grenade.png",
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
						shooter.blast(above, 2, 25, 5, player)
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

minetest.register_tool("shooter_grenade:grenade", {
	description = "Grenade",
	inventory_image = "shooter_hand_grenade.png",
	on_use = function(itemstack, user, pointed_thing)
		if not minetest.setting_getbool("creative_mode") then
			itemstack:clear()
		end
		if pointed_thing.type ~= "nothing" then
			local pointed = minetest.get_pointed_thing_position(pointed_thing)
			if vector.distance(user:get_pos(), pointed) < 8 then
				shooter.blast(pointed, 1, 25, 5)
				return
			end
		end
		local pos = user:get_pos()
		local dir = user:get_look_dir()
		local yaw = user:get_look_horizontal()
		if pos and dir then
			pos.y = pos.y + shooter.config.camera_height
			local obj = minetest.add_entity(pos, "shooter_grenade:grenade_entity")
			if obj then
				minetest.sound_play("shooter_throw", {object=obj})
				obj:set_velocity(vector.multiply(dir, 15))
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

if shooter.config.enable_crafting == true then
	minetest.register_craft({
		output = "shooter_grenade:grenade",
		recipe = {
			{"tnt:gunpowder", "default:steel_ingot"},
		},
	})
end

--Backwards compatibility
minetest.register_alias("shooter:grenade", "shooter_grenade:grenade")
