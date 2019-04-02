--[[
Shooter Crossbow [shooter_crossbow]
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

local config = {
	crossbow_uses = 50,
	arrow_lifetime = 180,
	arrow_fleshy = 2,
	arrow_object_attach = false,
}

-- Legacy Config Support

for name, _ in pairs(config) do
	local global = "SHOOTER_"..name:upper()
	if minetest.global_exists(global) then
		config[name] = _G[global]
	end
end

-- Load configuration

config = shooter.get_configuration(config)

local arrow_tool_caps = {damage_groups={fleshy=config.arrow_fleshy}}
if minetest.global_exists("SHOOTER_ARROW_TOOL_CAPS") then
	arrow_tool_caps = table.copy(SHOOTER_ARROW_TOOL_CAPS)
end

local dye_basecolors = (dye and dye.basecolors) or
	{"white", "grey", "black", "red", "yellow", "green", "cyan", "blue", "magenta"}

-- name is the overlay texture name, colour is used to select the wool texture
local function get_texture(name, colour)
	return "wool_"..colour..".png^shooter_"..name..".png^[makealpha:255,126,126"
end

local function get_animation_frame(dir)
	local angle = math.atan(dir.y)
	local frame = 90 - math.floor(angle * 360 / math.pi)
	if frame < 1 then
		frame = 1
	elseif frame > 180 then
		frame = 180
	end
	return frame
end

local function get_pointed_thing(pos, dir, dist)
	local p1 = vector.add(pos, dir)
	local p2 = vector.add(pos, vector.multiply(dir, dist))
	local ray = minetest.raycast(p1, p2, true, true)
	return ray:next()
end

local function strike(arrow, pointed_thing, name)
	local puncher = minetest.get_player_by_name(name)
	if not puncher then
		return
	end
	local object = arrow.object
	local hit_pos = pointed_thing.intersection_point or object:get_pos()
	local dir = vector.normalize(object:get_velocity())
	if pointed_thing.type == "object" then
		local target = pointed_thing.ref
		if shooter.is_valid_object(target) then
			if puncher and puncher ~= target then
				local groups = target:get_armor_groups() or {}
				if groups.fleshy then
					shooter.spawn_particles(hit_pos)
				end
				target:punch(object, nil, arrow_tool_caps, dir)
				if config.arrow_object_attach then
					local pos = vector.multiply(vector.subtract(target:get_pos(),
						hit_pos), -10)
					local rot = vector.new()
					rot.y = (target:get_yaw() - object:get_yaw()) * 57.2958
					object:set_attach(target, "", pos, rot)
					arrow.state = "stuck"
				else
					arrow.state = "dropped"
				end
			end
		end
	elseif pointed_thing.type == "node" then
		local pos = minetest.get_pointed_thing_position(pointed_thing, false)
		local node = minetest.get_node(pos)
		hit_pos = vector.subtract(hit_pos, vector.multiply(dir, 0.25))
		arrow.node_pos = pos
		arrow.state = "stuck"
		shooter.play_node_sound(node, pos)
	else
		return
	end
	arrow:stop(hit_pos)
end

minetest.register_entity("shooter_crossbow:arrow_entity", {
	physical = false,
	visual = "mesh",
	mesh = "shooter_arrow.b3d",
	visual_size = {x=1, y=1},
	textures = {
		get_texture("arrow_uv", "white"),
	},
	color = "white",
	timer = 0,
	lifetime = config.arrow_lifetime,
	user = nil,
	state = "init",
	node_pos = nil,
	collisionbox = {0,0,0, 0,0,0},
	stop = function(self, pos)
		local acceleration = {x=0, y=-10, z=0}
		if self.state == "stuck" then
			pos = pos or self.object:get_pos()
			acceleration = {x=0, y=0, z=0}
		end
		if pos then
			self.object:move_to(pos)
		end
		self.object:set_properties({
			physical = true,
			collisionbox = {-1/8,-1/8,-1/8, 1/8,1/8,1/8},
		})
		self.object:set_velocity({x=0, y=0, z=0})
		self.object:set_acceleration(acceleration)
	end,
	on_activate = function(self, staticdata)
		self.object:set_armor_groups({immortal=1})
		if staticdata == "expired" then
			self.object:remove()
		end
	end,
	on_punch = function(self, puncher)
		if puncher then
			if puncher:is_player() then
				local stack = "shooter_crossbow:arrow_"..self.color
				local inv = puncher:get_inventory()
				if inv:room_for_item("main", stack) then
					inv:add_item("main", stack)
					self.object:remove()
				end
			end
		end
	end,
	on_step = function(self, dtime)
		if self.state == "init" then
			return
		end
		self.timer = self.timer + dtime
		self.lifetime = self.lifetime - dtime
		if self.lifetime < 0 then
			self.object:remove()
			return
		elseif self.state == "dropped" then
			return
		elseif self.state == "stuck" then
			if self.timer > 1 then
				if self.node_pos then
					local node = minetest.get_node(self.node_pos)
					if node.name then
						local item = minetest.registered_items[node.name]
						if item then
							if not item.walkable then
								self.state = "dropped"
								self:stop()
								return
							end
						end
					end
				end
				self.timer = 0
			end
			return
		end
		if self.timer > 0.2 then
			local dir = vector.normalize(self.object:get_velocity())
			local frame = get_animation_frame(dir)
			local pos = self.object:get_pos()
			local pointed_thing = get_pointed_thing(pos, dir, 5)
			if pointed_thing then
				strike(self, pointed_thing, self.user)
			end
			self.object:set_animation({x=frame, y=frame}, 0)
			self.timer = 0
		end
	end,
	get_staticdata = function()
		return "expired"
	end,
})

for _, color in pairs(dye_basecolors) do
	minetest.register_craftitem("shooter_crossbow:arrow_"..color, {
		description = color:gsub("%a", string.upper, 1).." Arrow",
		inventory_image = get_texture("arrow_inv", color),
	})
	minetest.register_tool("shooter_crossbow:crossbow_loaded_"..color, {
		description = "Crossbow",
		inventory_image = get_texture("crossbow_loaded", color),
		groups = {not_in_creative_inventory=1},
		on_use = function(itemstack, user)
			minetest.sound_play("shooter_click", {object=user})
			if not minetest.setting_getbool("creative_mode") then
				itemstack:add_wear(65535 / config.crossbow_uses)
			end
			itemstack = "shooter_crossbow:crossbow 1 "..itemstack:get_wear()
			local pos = user:get_pos()
			local dir = user:get_look_dir()
			local yaw = user:get_look_horizontal()
			if pos and dir and yaw then
				pos.y = pos.y + user:get_properties().eye_height
				local obj = minetest.add_entity(pos,
					"shooter_crossbow:arrow_entity")
				local ent = nil
				if obj then
					ent = obj:get_luaentity()
				end
				if ent then
					ent.user = user:get_player_name()
					ent.state = "flight"
					ent.color = color
					obj:set_properties({
						textures = {get_texture("arrow_uv", color)}
					})
					minetest.sound_play("shooter_throw", {object=obj})
					local frame = get_animation_frame(dir)
					obj:set_yaw(yaw - math.pi / 2)
					obj:set_animation({x=frame, y=frame}, 0)
					obj:set_velocity({x=dir.x * 14, y=dir.y * 14, z=dir.z * 14})
					obj:set_acceleration({x=dir.x * -3, y=-5, z=dir.z * -3})
					local pointed_thing = get_pointed_thing(pos, dir, 5)
					if pointed_thing then
						strike(ent, pointed_thing, ent.user)
					end
				end
			end
			return itemstack
		end,
	})
end

minetest.register_tool("shooter_crossbow:crossbow", {
	description = "Crossbow",
	inventory_image = "shooter_crossbow.png",
	on_use = function(itemstack, user)
		local inv = user:get_inventory()
		local stack = inv:get_stack("main", user:get_wield_index() + 1)
		local color = string.match(stack:get_name(), "shooter_crossbow:arrow_(%a+)")
		if color then
			minetest.sound_play("shooter_reload", {object=user})
			if not minetest.setting_getbool("creative_mode") then
				inv:remove_item("main", "shooter_crossbow:arrow_"..color.." 1")
			end
			return "shooter_crossbow:crossbow_loaded_"..color.." 1 "..itemstack:get_wear()
		end
		for _, clr in pairs(dye_basecolors) do
			if inv:contains_item("main", "shooter_crossbow:arrow_"..clr) then
				minetest.sound_play("shooter_reload", {object=user})
				if not minetest.setting_getbool("creative_mode") then
					inv:remove_item("main", "shooter_crossbow:arrow_"..clr.." 1")
				end
				return "shooter_crossbow:crossbow_loaded_"..clr.." 1 "..itemstack:get_wear()
			end
		end
		minetest.sound_play("shooter_click", {object=user})
	end,
})

if shooter.config.enable_crafting == true then
	minetest.register_craft({
		output = "shooter_crossbow:crossbow",
		recipe = {
			{"default:stick", "default:stick", "default:stick"},
			{"default:stick", "default:stick", ""},
			{"default:stick", "", "default:bronze_ingot"},
		},
	})
	minetest.register_craft({
		output = "shooter_crossbow:arrow_white",
		recipe = {
			{"default:steel_ingot", "", ""},
			{"", "default:stick", "default:paper"},
			{"", "default:paper", "default:stick"},
		},
	})
	if minetest.get_modpath("dye") then
		for _, color in pairs(dye_basecolors) do
			if color ~= "white" then
				minetest.register_craft({
					output = "shooter_crossbow:arrow_"..color,
					recipe = {
						{"", "dye:"..color, "shooter_crossbow:arrow_white"},
					},
				})
			end
		end
	end
end

--Backwards compatibility
minetest.register_alias("shooter:crossbow", "shooter_crossbow:crossbow")
for _, color in pairs(dye_basecolors) do
	minetest.register_alias("shooter:arrow_"..color, "shooter_crossbow:arrow_"..color)
	minetest.register_alias("shooter:crossbow_loaded_"..color, "shooter_crossbow:crossbow_loaded_"..color)
end
