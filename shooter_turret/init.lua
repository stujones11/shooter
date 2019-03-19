--[[
Shooter Turret Gun [shooter_turret]
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

local use_player_api = minetest.get_modpath("player_api")

local function get_turret_entity(pos)
	local entity = nil
	local objects = minetest.get_objects_inside_radius(pos, 1)
	for _, obj in ipairs(objects) do
		local ent = obj:get_luaentity()
		if ent then
			if ent.name == "shooter_turret:turret_entity" then
				-- Remove duplicates
				if entity then
					obj:remove()
				else
					entity = ent
				end
			end
		end
	end
	return entity
end

minetest.register_entity("shooter_turret:turret_entity", {
	physical = true,
	visual = "mesh",
	mesh = "shooter_turret.b3d",
	visual_size = {x=1, y=1},
	collisionbox = {-0.3, 0.5,-0.3, 0.3,1,0.3},
	textures = {
		"shooter_turret_uv.png",
	},
	timer = 0,
	user = nil,
	pitch = 40,
	yaw = 0,
	firing = false,
	on_activate = function(self)
		self.pos = self.object:get_pos()
		self.yaw = self.object:get_yaw()
		if minetest.get_node(self.pos).name ~= "shooter_turret:turret" then
			self.object:remove()
			return
		end
		self.object:set_animation({x=self.pitch, y=self.pitch}, 0)
		self.object:set_armor_groups({immortal=1})
		-- Remove duplicates
		get_turret_entity(self.pos)
	end,
	on_rightclick = function(self, clicker)
		if self.user then
			local player = minetest.get_player_by_name(self.user)
			if player then
				player:set_detach()
				if use_player_api then
					player_api.player_attached[self.user] = false
				end
			end
			self.user = nil
		else
			clicker:set_attach(self.object, "", {x=0,y=-5,z=-8}, {x=0,y=0,z=0})
			self.user = clicker:get_player_name()
			if use_player_api then
				player_api.player_attached[self.user] = true
			end
		end
	end,
	on_step = function(self, dtime)
		if not self.user then
			return
		end
		self.timer = self.timer + dtime
		if self.timer < 0.2 then
			return
		end
		local player = minetest.get_player_by_name(self.user)
		if player then
			local pitch = self.pitch
			local yaw = self.object:get_yaw()
			local ctrl = player:get_player_control()
			local step = 2
			if ctrl then
				if ctrl.sneak then
					step = 1
					if ctrl.jump then
						if self.firing == false then
							self:fire()
							self.firing = true
						end
					else
						self.firing = false
					end
				end
				if ctrl.down then
					pitch = pitch + 1 * step
				elseif ctrl.up then
					pitch = pitch - 1 * step
				end
				if ctrl.left then
					yaw = yaw + 0.025 * step
				elseif ctrl.right then
					yaw = yaw - 0.025 * step
				end
				if pitch < 0 then
					pitch = 0
				elseif pitch > 90 then
					pitch = 90
				end
				if self.pitch ~= pitch then
					self.object:set_animation({x=pitch, y=pitch}, 0)
					self.pitch = pitch
				end
				if self.yaw ~= yaw then
					self.object:set_yaw(yaw)
					self.yaw = yaw
				end
			end
		end
		self.timer = 0
	end,
	fire = function(self)
		if not self.user then
			return
		end
		local meta = minetest.get_meta(self.pos)
		local inv = meta:get_inventory()
		if not inv then
			return
		end
		if not inv:contains_item("main", "shooter_rocket:rocket") then
			minetest.sound_play("shooter_click", {object=self.object})
			return
		end
		inv:remove_item("main", "shooter_rocket:rocket")
		minetest.sound_play("shooter_shotgun", {object=self.object})
		local pitch = math.rad(self.pitch - 40)
		local len = math.cos(pitch)
		local dir = vector.normalize({
			x = len * math.sin(-self.yaw),
			y = math.sin(pitch),
			z = len * math.cos(self.yaw),
		})
		local pos = {x=self.pos.x, y=self.pos.y + 0.87, z=self.pos.z}
		pos = vector.add(pos, vector.multiply(dir, 1.5))
		local obj = minetest.add_entity(pos, "shooter_rocket:rocket_entity")
		if obj then
			local ent = obj:get_luaentity()
			if ent then
				minetest.sound_play("shooter_rocket_fire", {object=obj})
				ent.user = self.user
				obj:set_yaw(self.yaw)
				obj:set_velocity(vector.multiply(dir, 30))
				obj:set_acceleration({x=dir.x * -3, y=-10, z=dir.z * -3})
			end
		end
		if shooter.config.enable_particle_fx == true then
			minetest.add_particlespawner({
				amount = 10,
				time = 0.1,
				minpos = {x=pos.x - 1, y=pos.y - 1, z=pos.z - 1},
				maxpos = {x=pos.x + 1, y=pos.y + 1, z=pos.z + 1},
				minvel = {x=0, y=0, z=0},
				maxvel = {x=0, y=0, z=0},
				minacc = {x=-0.5, y=-0.5, z=-0.5},
				maxacc = {x=0.5, y=0.5, z=0.5},
				minexptime = 0.1,
				maxexptime = 1,
				minsize = 8,
				maxsize = 15,
				collisiondetection = false,
				texture = "tnt_smoke.png",
			})
		end
	end
})

minetest.register_node("shooter_turret:turret", {
	description = "Turret Gun",
	tiles = {"shooter_turret_base.png"},
	inventory_image = "shooter_turret_gun.png",
	wield_image = "shooter_turret_gun.png",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {snappy=2, choppy=2, oddly_breakable_by_hand=3},
	node_box = {
		type = "fixed",
		fixed = {
			{-1/8, 1/8, -1/8, 1/8, 1/2, 1/8},
			{-5/16, 0, -5/16, 5/16, 1/8, 5/16},
			{-3/8, -1/2, -3/8, -1/4, 0, -1/4},
			{1/4, -1/2, 1/4, 3/8, 0, 3/8},
			{1/4, -1/2, -3/8, 3/8, 0, -1/4},
			{-3/8, -1/2, 1/4, -1/4, 0, 3/8},
		},
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", "size[8,9]"..
			"list[current_name;main;2,0;4,4;]"..
			"list[current_player;main;0,5;8,4;]"..
			"listring[]"
		)
		meta:set_string("infotext", "Turret Gun")
		local inv = meta:get_inventory()
		inv:set_size("main", 16)
	end,
	after_place_node = function(pos)
		local node = minetest.get_node({x=pos.x, y=pos.y + 1, z=pos.z})
		if node.name == "air" then
			if not get_turret_entity(pos) then
				minetest.add_entity(pos, "shooter_turret:turret_entity")
			end
		end
	end,
	can_dig = function(pos)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("main")
	end,
	after_destruct = function(pos)
		local ent = get_turret_entity(pos)
		if ent then
			ent.object:remove()
		end
	end,
	mesecons = {
		effector = {
			action_on = function(pos)
				local ent = get_turret_entity(pos)
				if ent then
					if ent.firing == false then
						ent:fire()
						ent.firing = true
					end
				end
			end,
			action_off = function(pos)
				local ent = get_turret_entity(pos)
				if ent then
					ent.firing = false
				end
			end,
		},
	},
})

minetest.register_abm({
	nodenames = {"shooter_turret:turret"},
	interval = 15,
	chance = 1,
	action = function(pos)
		if not get_turret_entity(pos) then
			minetest.add_entity(pos, "shooter_turret:turret_entity")
		end
	end
})

if shooter.config.enable_crafting == true then
	minetest.register_craft({
		output = "shooter_turret:turret",
		recipe = {
			{"default:bronze_ingot", "default:bronze_ingot", "default:steel_ingot"},
			{"", "default:bronze_ingot", "default:steel_ingot"},
			{"", "default:diamond", ""},
		},
	})
end

--Backward compatibility
minetest.register_alias("shooter:turret", "shooter_turret:turret")

