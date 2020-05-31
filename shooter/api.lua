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
	node_drops = false,
	allow_nodes = true,
	allow_entities = false,
	allow_players = true,
	rounds_update_time = 0.4,
	damage_multiplier = 1,
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
local config = table.copy(shooter.config)
local server_step = minetest.settings:get("dedicated_server_step")
local v3d = table.copy(vector)
local PI = math.pi
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt
local phi = (math.sqrt(5) + 1) / 2 -- Golden ratio

shooter.register_weapon = function(name, def)
	-- Backwards compatibility
	if not def.spec.sounds then
		def.spec.sounds = def.sounds or {}
	end
	if not def.spec.sounds.shot and def.spec.sound then
		def.spec.sounds.shot = def.spec.sound
	end
	-- Fix definition table
	def.spec.reload_item = def.reload_item or "shooter:ammo"
	def.spec.tool_caps.full_punch_interval = math.max(server_step,
		def.spec.tool_caps.full_punch_interval)
	def.spec.wear = math.ceil(65535 / def.spec.rounds)
	def.unloaded_item = def.unloaded_item or {
		description = def.description.." (unloaded)",
		inventory_image = def.inventory_image,
	}
	def.unloaded_item.name = name
	shooter.registered_weapons[name] = table.copy(def)
	-- Register loaded item tool
	minetest.register_tool(name.."_loaded", {
		description = def.description,
		inventory_image = def.inventory_image,
		on_use = function(itemstack, user, pointed_thing)
			if type(def.on_use) == "function" then
				itemstack = def.on_use(itemstack, user, pointed_thing)
			end
			if itemstack then
				local spec = shooter.get_weapon_spec(user, name)
				if spec and shooter.fire_weapon(user, itemstack, spec) then
					itemstack:add_wear(def.spec.wear)
					if itemstack:get_count() == 0 then
						itemstack:replace(def.unloaded_item.name)
					end
				end
			end
			return itemstack
		end,
		unloaded_item = def.unloaded_item,
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
				local stack = def.spec.reload_item
				if inv:contains_item("main", stack) then
					local sound = def.spec.sounds.reload or "shooter_reload"
					minetest.sound_play(sound, {object=user})
					inv:remove_item("main", stack)
					itemstack:replace(name.."_loaded 1 1")
				else
					local sound = def.spec.sounds.fail_shot or "shooter_click"
					minetest.sound_play(sound, {object=user})
				end
			end
			return itemstack
		end,
	})
end

shooter.get_weapon_spec = function(_, name)
	local def = shooter.registered_weapons[name]
	if def then
		return table.copy(def.spec)
	end
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
	for k, v in pairs(shooter.default_particles) do
		if not particles[k] then
			particles[k] = type(v) == "table" and table.copy(v) or v
		end
	end
	particles.minpos = v3d.subtract(pos, particles.minpos)
	particles.maxpos = v3d.add(pos, particles.maxpos)
	minetest.add_particlespawner(particles)
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

shooter.punch_node = function(pos, spec)
	if config.enable_protection and minetest.is_protected(pos, spec.user) then
		return
	end
	local node = minetest.get_node(pos)
	if not node then
		return
	end
	local item = minetest.registered_items[node.name]
	if not item then
		return
	end
	if item.groups then
		for k, v in pairs(spec.groups) do
			local level = item.groups[k] or 0
			if level >= v then
				minetest.remove_node(pos)
				shooter.play_node_sound(node, pos)
				if item.tiles then
					local texture = item.tiles[1]
					texture = (type(texture) == "table") and texture.name or texture
					shooter.spawn_particles(pos, {texture=texture})
				end
				if config.node_drops then
					local object = minetest.add_item(pos, item)
					if object then
						object:set_velocity({
							x = math.random(-1, 1),
							y = 4,
							z = math.random(-1, 1)
						})
					end
				end
				return true
			end
		end
	end
end

shooter.punch_object = function(object, tool_caps, dir, on_blast, puncher)
	if type(puncher) == "string" then
		puncher = minetest.get_player_by_name(puncher)
	end

	local do_damage = true
	local groups = tool_caps.damage_groups or {}
	if on_blast and not object:is_player() then
		local ent = object:get_luaentity()
		if ent then
			local def = minetest.registered_entities[ent.name] or {}
			if def.on_blast and groups.fleshy then
				do_damage = def.on_blast(ent, groups.fleshy *
					config.damage_multiplier)
			end
		end
	end
	if do_damage then
		for k, v in pairs(groups) do
			tool_caps.damage_groups[k] = v * config.damage_multiplier
		end
		object:punch(puncher, nil, tool_caps, dir)
		return true
	end
end

local function matrix_from_quat(q)
	local m = {{}, {}, {}}
	m[1][1] = 1 - 2 * q.y * q.y - 2 * q.z * q.z
	m[1][2] = 2 * q.x * q.y + 2 * q.z * q.w
	m[1][3] = 2 * q.x * q.z - 2 * q.y * q.w
	m[2][1] = 2 * q.x * q.y - 2 * q.z * q.w
	m[2][2] = 1 - 2 * q.x * q.x - 2 * q.z * q.z
	m[2][3] = 2 * q.z * q.y + 2 * q.x * q.w
	m[3][1] = 2 * q.x * q.z + 2 * q.y * q.w
	m[3][2] = 2 * q.z * q.y - 2 * q.x * q.w
	m[3][3] = 1 - 2 * q.x * q.x - 2 * q.y * q.y
	return m
end

local function quat_from_angle_axis(angle, axis)
	local t = angle / 2
	local s = sin(t)
	return {
		x = s * axis.x,
		y = s * axis.y,
		z = s * axis.z,
		w = cos(t),
	}
end

v3d.cross = function(v1, v2)
	return {
		x = v1.y * v2.z - v2.y * v1.z,
		y = v1.z * v2.x - v2.z * v1.x,
		z = v1.x * v2.y - v2.x * v1.y,
	}
end

v3d.mult_matrix = function(v, m)
	return {
		x = m[1][1] * v.x + m[1][2] * v.y + m[1][3] * v.z,
		y = m[2][1] * v.x + m[2][2] * v.y + m[2][3] * v.z,
		z = m[3][1] * v.x + m[3][2] * v.y + m[3][3] * v.z,
	}
end

v3d.rotate = function(v, angle, axis)
	local q = quat_from_angle_axis(angle, axis)
	local m = matrix_from_quat(q)
	return v3d.mult_matrix(v, m)
end

local function get_directions(dir, spec)
	local directions = {dir}
	local n = spec.shots or 1
	if n > 1 then
		local right = v3d.normalize(v3d.cross(dir, {x=0, y=1, z=0}))
		local up = v3d.normalize(v3d.cross(dir, right))
		local s = spec.spread or 10
		s = s * 0.017453 -- Convert to radians
		for k = 1, n - 1 do
			-- Sunflower seed arrangement
			local r = sqrt(k - 0.5) / sqrt(n - 0.5)
			local theta = 2 * PI * k / (phi * phi)
			local x = r * cos(theta) * s
			local y = r * sin(theta) * s
			local d = v3d.rotate(dir, y, up)
			directions[k + 1] = v3d.rotate(d, x, right)
		end
	end
	return directions
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
		if shooter.is_valid_object(object) and
				shooter.punch_object(object, spec.tool_caps, dir, nil, spec.user) then
			local pos = pointed_thing.intersection_point or object:get_pos()
			local groups = object:get_armor_groups() or {}
			if groups.fleshy then
				shooter.spawn_particles(pos, spec.particles)
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
	local p2 = v3d.add(p1, v3d.multiply(round.dir, round.spec.step))
	local ray = minetest.raycast(p1, p2, true, true)
	local pointed_thing = ray:next()
	if pointed_thing then
		-- Iterate over ray again if pointed object == shooter
		local ref = pointed_thing.ref
		if ref and ref:is_player() and ref:get_player_name() == round.spec.user then
			pointed_thing = ray:next()
		end

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
	pos.y = pos.y + player:get_properties().eye_height
	spec.origin = pos
	local interval = spec.tool_caps.full_punch_interval
	shots[spec.user] = minetest.get_us_time() / 1000000 + interval
	local sound = spec.sounds.shot or "shooter_pistol"
	minetest.sound_play(sound, {object=player})
	local speed = spec.step / (config.rounds_update_time * 2)
	local time = spec.range / speed
	local directions = get_directions(dir, spec)
	for _, d in pairs(directions) do
		if spec.bullet_image then
			minetest.add_particle({
				pos = pos,
				velocity = v3d.multiply(d, speed),
				acceleration = {x=0, y=0, z=0},
				expirationtime = time,
				size = 0.25,
				texture = spec.bullet_image,
			})
		end
		process_round({
			spec = spec,
			pos = v3d.new(spec.origin),
			dir = d,
			dist = 0,
		})
	end
	if extended then
		itemstack:add_wear(spec.wear)
		if itemstack:get_count() == 0 then
			local def = minetest.registered_items[spec.name] or {}
			if def.unloaded_item then
				itemstack = def.unloaded_item.name or ""
			end
			player:set_wielded_item(itemstack)
			return
		end
		player:set_wielded_item(itemstack)
	end
	if not spec.automatic or not shooting[spec.user] then
		return
	end
	minetest.after(interval, function(...)
		if shooting[spec.user] and player:get_wield_index() == spec.wield_idx then
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
	spec.wield_idx = player:get_wield_index()
	fire_weapon(player, itemstack, spec)
	return true
end

shooter.blast = function(pos, radius, fleshy, distance, user)
	if not user then
		return
	end
	pos = v3d.round(pos)
	local name = user:get_player_name()
	local p1 = v3d.subtract(pos, radius)
	local p2 = v3d.add(pos, radius)
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
			local dist = v3d.distance(obj_pos, pos)
			local damage = (fleshy * 0.5 ^ dist) * 2 * config.damage_multiplier
			if dist ~= 0 then
				obj_pos.y = obj_pos.y + 1
				local blast_pos = {x=pos.x, y=pos.y + 4, z=pos.z}
				if shooter.is_valid_object(obj) and
						minetest.line_of_sight(obj_pos, blast_pos, 1) then
					shooter.punch_object(obj, {
						full_punch_interval = 1.0,
						damage_groups = {fleshy=damage},
					}, nil, true, user)
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
