--[[
Shooter API [shooter]
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

shooter = {
	registered_weapons = {},
}

shooter.config = {
	automatic_weapons = true,
	admin_weapons = false,
	enable_blasting = false,
	enable_particle_fx = true,
	enable_protection = false,
	enable_crafting = true,
	explosion_texture = "shooter_hit.png",
	allow_nodes = true,
	allow_entities = false,
	allow_players = true,
	rounds_update_time = 0.4,
	camera_height = 1.5,
}

shooter.default_particles = {
	amount = 15,
	time = 0.3,
	minpos = {x=-0.1, y=-0.1, z=-0.1},
	maxpos = {x=0.1, y=0.1, z=0.1},
	minvel = {x=-1, y=1, z=-1},
	maxvel = {x=1, y=2, z=1},
	minacc = {x=-2, y=-2, z=-2},
	maxacc = {x=2, y=-2, z=2},
	minexptime = 0.1,
	maxexptime = 0.75,
	minsize = 1,
	maxsize = 2,
	collisiondetection = false,
	texture = "shooter_hit.png",
}

local shots = {}
local shooting = {}
local config = shooter.config
local server_step = minetest.settings:get("dedicated_server_step")

shooter.register_weapon = function(name, def)
	shooter.registered_weapons[name] = def
	-- Fix definition table
	def.sounds = def.sounds or {}
	def.sounds.reload = def.sounds.reload or "shooter_reload"
	def.sounds.fail_shot = def.sounds.fail_shot or "shooter_click"
	def.reload_item = def.reload_item or "shooter:ammo"
	def.spec.tool_caps.full_punch_interval = math.max(server_step,
		def.spec.tool_caps.full_punch_interval)
	def.spec.wear = math.ceil(65535 / def.spec.rounds)
	def.spec.unloaded_item = name
	def.unloaded_item = def.unloaded_item or {
		description = def.description.." (unloaded)",
		inventory_image = def.inventory_image,
	}
	-- Register loaded item tool
	minetest.register_tool(name.."_loaded", {
		description = def.description,
		inventory_image = def.inventory_image,
		on_use = function(itemstack, user, pointed_thing)
			if type(def.on_use) == "function" then
				itemstack = def.on_use(itemstack, user, pointed_thing)
			end
			local spec = table.copy(def.spec)
			if shooter.fire_weapon(user, itemstack, spec) then
				itemstack:add_wear(def.spec.wear)
				if itemstack:get_count() == 0 then
					itemstack:replace(def.unloaded_item.name)
				end
			end
			return itemstack
		end,
		on_hit = def.on_hit,
		groups = {not_in_creative_inventory=1},
	})
	-- Register unloaded item tool
	minetest.register_tool(name, {
		description = def.unloaded_item.description,
		inventory_image = def.unloaded_item.inventory_image,
		groups = def.unloaded_item.groups or {},
		on_use = function(itemstack, user)
			local inv = user:get_inventory()
			if inv then
				local stack = def.reload_item
				if inv:contains_item("main", stack) then
					minetest.sound_play(def.sounds.reload, {object=user})
					inv:remove_item("main", stack)
					itemstack:replace(name.."_loaded 1 1")
				else
					minetest.sound_play(def.sounds.fail_shot, {object=user})
				end
			end
			return itemstack
		end,
	})
end

shooter.get_configuration = function(conf)
	for k, v in pairs(conf) do
		local setting = minetest.settings:get("shooter_"..k)
		if type(v) == "number" then
			setting = tonumber(setting)
		elseif type(v) == "boolean" then
			setting = minetest.settings:get_bool("shooter_"..k)
		end
		if setting ~= nil then
			conf[k] = setting
		end
	end
	return conf
end

shooter.spawn_particles = function(pos, particles)
	particles = particles or {}
	if not config.enable_particle_fx == true or particles.amount == 0 then
		return
	end
	local copy = function(v)
		return type(v) == "table" and table.copy(v) or v
	end
	local p = {}
	for k, v in pairs(shooter.default_particles) do
		p[k] = particles[k] and copy(particles[k]) or copy(v)
	end
	p.minpos = vector.subtract(pos, p.minpos)
	p.maxpos = vector.add(pos, p.maxpos)
	minetest.add_particlespawner(p)
end

shooter.play_node_sound = function(node, pos)
	local item = minetest.registered_items[node.name]
	if item then
		if item.sounds then
			local spec = item.sounds.dug
			if spec then
				spec.pos = pos
				minetest.sound_play(spec.name, spec)
			end
		end
	end
end

shooter.punch_node = function(pos, spec)
	local node = minetest.get_node(pos)
	if not node then
		return
	end
	local item = minetest.registered_items[node.name]
	if not item then
		return
	end
	if config.enable_protection then
		if minetest.is_protected(pos, spec.user) then
			return
		end
	end
	if item.groups then
		for k, v in pairs(spec.groups) do
			local level = item.groups[k] or 0
			if level >= v then
				minetest.remove_node(pos)
				shooter.play_node_sound(node, pos)
				if item.tiles then
					if item.tiles[1] then
						shooter.spawn_particles(pos, {texture=item.tiles[1]})
					end
				end
				break
			end
		end
	end
end

shooter.is_valid_object = function(object)
	if object then
		if object:is_player() == true then
			return config.allow_players
		end
		if config.allow_entities == true then
			local luaentity = object:get_luaentity()
			if luaentity then
				return luaentity.name ~= "__builtin:item"
			end
		end
	end
end

local function process_hit(pointed_thing, spec, dir)
	local def = minetest.registered_items[spec.name] or {}
	if type(def.on_hit) == "function" then
		if def.on_hit(pointed_thing, spec, dir) == true then
			return
		end
	end
	if pointed_thing.type == "node" and config.allow_nodes == true then
		local pos = minetest.get_pointed_thing_position(pointed_thing, false)
		shooter.punch_node(pos, spec)
	elseif pointed_thing.type == "object" then
		local object = pointed_thing.ref
		if shooter.is_valid_object(object) == true then
			local player = minetest.get_player_by_name(spec.user)
			if player then
				object:punch(player, nil, spec.tool_caps, dir)
				local pos = pointed_thing.intersection_point or object:get_pos()
				local groups = object:get_armor_groups() or {}
				if groups.fleshy then
					shooter.spawn_particles(pos, spec.particles)
				end
			end
		end
	end
end

local function process_round(round)
	round.dist = round.dist + round.spec.step
	if round.dist > round.spec.range then
		return
	end
	local p1 = round.pos
	local p2 = vector.add(p1, vector.multiply(round.dir, round.spec.step))
	local ray = minetest.raycast(p1, p2, true, true)
	local pointed_thing = ray:next() or {type="nothing"}
	if pointed_thing.type ~= "nothing" then
		return process_hit(pointed_thing, round.spec, round.dir)
	end
	round.pos = p2
	minetest.after(shooter.config.rounds_update_time, function(...)
		process_round(...)
	end, round)
end

local function fire_weapon(player, itemstack, spec, extended)
	if not player then
		return
	end
	local dir = player:get_look_dir()
	local pos = player:get_pos()
	if not dir or not pos then
		return
	end
	pos.y = pos.y + config.camera_height
	spec.origin = vector.add(pos, dir)
	shots[spec.user] = minetest.get_us_time() / 1000000 +
		spec.tool_caps.full_punch_interval
	minetest.sound_play(spec.sound, {object=player})
	if spec.bullet_image then
		minetest.add_particle({
			pos = pos,
			velocity = vector.multiply(dir, 30),
			acceleration = {x=0, y=0, z=0},
			expirationtime = 0.5,
			size = 0.25,
			texture = spec.bullet_image,
		})
	end
	process_round({
		spec = spec,
		pos = vector.new(spec.origin),
		dir = dir,
		dist = 0,
	})
	if extended then
		itemstack:add_wear(spec.wear)
		if itemstack:get_count() == 0 then
			itemstack = spec.unloaded_item
			player:set_wielded_item(itemstack)
			return
		end
		player:set_wielded_item(itemstack)
	end
	if not spec.automatic or not shooting[spec.user] then
		return
	end
	minetest.after(interval, function(...)
		if shooting[spec.user] then
			local arg = {...}
			fire_weapon(arg[1], arg[2], arg[3], true)
		end
	end, player, itemstack, spec)
end

shooter.fire_weapon = function(player, itemstack, spec)
	local name = player:get_player_name()
	local time = minetest.get_us_time() / 1000000
	if shots[name] and time <= shots[name] then
		return false
	end
	if config.automatic_weapons then
		if config.admin_weapons and minetest.check_player_privs(name,
				{server=true}) then
			spec.automatic = true
		end
		shooting[name] = true
	end
	spec.user = name
	spec.name = itemstack:get_name()
	fire_weapon(player, itemstack, spec)
	return true
end

shooter.blast = function(pos, radius, fleshy, distance, user)
	if not user then
		return
	end
	pos = vector.round(pos)
	local name = user:get_player_name()
	local p1 = vector.subtract(pos, radius)
	local p2 = vector.add(pos, radius)
	minetest.sound_play("shooter_explode", {
		pos = pos,
		gain = 10,
		max_hear_distance = 100
	})
	if config.allow_nodes and config.enable_blasting then
		if not config.enable_protection or
				not minetest.is_protected(pos, name) then
			minetest.set_node(pos, {name="shooter:boom"})
		end
	end
	if config.enable_particle_fx == true then
		minetest.add_particlespawner({
			amount = 50,
			time = 0.1,
			minpos = p1,
			maxpos = p2,
			minvel = {x=0, y=0, z=0},
			maxvel = {x=0, y=0, z=0},
			minacc = {x=-0.5, y=5, z=-0.5},
			maxacc = {x=0.5, y=5, z=0.5},
			minexptime = 0.1,
			maxexptime = 1,
			minsize = 8,
			maxsize = 15,
			collisiondetection = false,
			texture = "shooter_smoke.png",
		})
	end
	local objects = minetest.get_objects_inside_radius(pos, distance)
	for _,obj in ipairs(objects) do
		if shooter.is_valid_object(obj) then
			local obj_pos = obj:get_pos()
			local dist = vector.distance(obj_pos, pos)
			local damage = (fleshy * 0.5 ^ dist) * 2
			if dist ~= 0 then
				obj_pos.y = obj_pos.y + 1
				local blast_pos = {x=pos.x, y=pos.y + 4, z=pos.z}
				if minetest.line_of_sight(obj_pos, blast_pos, 1) then
					obj:punch(user, 1.0, {
						full_punch_interval = 1.0,
						damage_groups = {fleshy=damage},
					})
				end
			end
		end
	end
	if config.allow_nodes and config.enable_blasting then
		local pr = PseudoRandom(os.time())
		local vm = VoxelManip()
		local min, max = vm:read_from_map(p1, p2)
		local area = VoxelArea:new({MinEdge=min, MaxEdge=max})
		local data = vm:get_data()
		local c_air = minetest.get_content_id("air")
		for z = -radius, radius do
			for y = -radius, radius do
				local vp = {x=pos.x - radius, y=pos.y + y, z=pos.z + z}
				local vi = area:index(vp.x, vp.y, vp.z)
				for x = -radius, radius do
					if (x * x) + (y * y) + (z * z) <=
							(radius * radius) + pr:next(-radius, radius) then
						if config.enable_protection then
							if not minetest.is_protected(vp, name) then
								data[vi] = c_air
							end
						else
							data[vi] = c_air
						end
					end
					vi = vi + 1
				end
			end
		end
		vm:set_data(data)
		vm:update_liquids()
		vm:write_to_map()
	end
end

shooter.get_shooting = function(name)
	return shooting[name]
end

shooter.set_shooting = function(name, is_shooting)
	shooting[name] = is_shooting and true or nil
end
