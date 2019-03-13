shooter = {
	registered_weapons = {},
}

shooter.config = {
	admin_weapons = true,
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

local rounds = {}
local shots = {}
local shooting = {}
local config = shooter.config
local server_step = minetest.settings:get("dedicated_server_step")

function shooter:register_weapon(name, def)
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
		on_use = function(itemstack, user)
			if shooter:fire_weapon(user, itemstack, def.spec) then
				itemstack:add_wear(def.spec.wear)
				if itemstack:get_count() == 0 then
					itemstack = def.unloaded_item.name
				end
			end
			return itemstack
		end,
		groups = {not_in_creative_inventory=1},
	})
	-- Register unloaded item tool
	minetest.register_tool(name, {
		description = def.unloaded_item.description,
		inventory_image = def.unloaded_item.inventory_image,
		groups = def.unloaded_item.groups or {},
		on_use = function(itemstack, user, pointed_thing)
			local inv = user:get_inventory()
			if inv then
				local stack = def.reload_item
				if inv:contains_item("main", stack) then
					minetest.sound_play((def.sounds.reload), {object=user})
					inv:remove_item("main", stack)
					itemstack:replace(name.."_loaded 1 1")
				else
					minetest.sound_play((def.sounds.fail_shot), {object=user})
				end
			end
			return itemstack
		end,
	})
end

function shooter:spawn_particles(pos, texture)
	if config.enable_particle_fx == true then
		if type(texture) ~= "string" then
			texture = config.explosion_texture
		end
		local spread = {x=0.1, y=0.1, z=0.1}
		minetest.add_particlespawner(15, 0.3,
			vector.subtract(pos, spread), vector.add(pos, spread),
			{x=-1, y=1, z=-1}, {x=1, y=2, z=1},
			{x=-2, y=-2, z=-2}, {x=2, y=-2, z=2},
			0.1, 0.75, 1, 2, false, texture
		)
	end
end

function shooter:play_node_sound(node, pos)
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

function shooter:punch_node(pos, spec)
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
				shooter:play_node_sound(node, pos)
				if item.tiles then
					if item.tiles[1] then
						shooter:spawn_particles(pos, item.tiles[1])
					end
				end
				break
			end
		end
	end
end

function shooter:is_valid_object(object)
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

local function process_round(round)
	round.dist = round.dist + round.spec.step
	if round.dist > round.spec.range then
		return
	end
	local p1 = round.pos
	local p2 = vector.add(p1, vector.multiply(round.dir, round.spec.step))
	local ray = minetest.raycast(p1, p2, true, true)
	local pointed_thing = ray:next() or {}
	if pointed_thing.type == "node" then
		if config.allow_nodes == true then
			local pos = minetest.get_pointed_thing_position(pointed_thing, false)
			shooter:punch_node(pos, round.spec)
		end
		return
	elseif pointed_thing.type == "object" then
		local object = pointed_thing.ref
		if shooter:is_valid_object(object) == true then
			local player = minetest.get_player_by_name(round.spec.user)
			if player then
				object:punch(player, nil, round.spec.tool_caps, round.dir)
				local pos = pointed_thing.intersection_point or object:get_pos()
				shooter:spawn_particles(pos, config.explosion_texture)
			end
		end
		return
	end
	round.pos = p2
	minetest.after(shooter.config.rounds_update_time, function(round)
		process_round(round)
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
	minetest.sound_play(spec.sound, {object=player})
	minetest.add_particle({
		pos = pos,
		velocity = vector.multiply(dir, 30),
		acceleration = {x=0, y=0, z=0},
		expirationtime = 0.5,
		size = 0.25,
		texture = spec.particle,
	})
	process_round({
		spec = spec,
		pos = vector.add(pos, dir),
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
	local interval = spec.tool_caps.full_punch_interval
	shots[spec.user] = minetest.get_us_time() / 1000000 + interval
	minetest.after(interval, function(player, itemstack, spec)
		if shooting[spec.user] then
			fire_weapon(player, itemstack, spec, true)
		end
	end, player, itemstack, spec)
end

function shooter:fire_weapon(player, itemstack, spec)
	local name = player:get_player_name()
	local time = minetest.get_us_time() / 1000000
	if shots[name] and time <= shots[name] then
		return false
	end
	if config.admin_weapons and	minetest.check_player_privs(name,
			{server=true}) then
		spec.automatic = true
	end
	shooting[name] = true
	spec.user = name
	fire_weapon(player, itemstack, spec)
	return true
end

function shooter:blast(pos, radius, fleshy, distance, user)
	if not user then
		return
	end
	local name = user:get_player_name()
	local pos = vector.round(pos)
	local p1 = vector.subtract(pos, radius)
	local p2 = vector.add(pos, radius)
	minetest.sound_play("tnt_explode", {pos=pos, gain=1})
	if config.allow_nodes and config.enable_blasting then
		if config.enable_protection then
			if not minetest.is_protected(pos, name) then
				minetest.set_node(pos, {name="tnt:boom"})
			end
		else
			minetest.set_node(pos, {name="tnt:boom"})
		end
	end
	if config.enable_particle_fx == true then
		minetest.add_particlespawner(50, 0.1,
			p1, p2, {x=-0, y=-0, z=-0}, {x=0, y=0, z=0},
			{x=-0.5, y=5, z=-0.5}, {x=0.5, y=5, z=0.5},
			0.1, 1, 8, 15, false, "tnt_smoke.png"
		)
	end
	local objects = minetest.get_objects_inside_radius(pos, distance)
	for _,obj in ipairs(objects) do
		if shooter:is_valid_object(obj) then
			local obj_pos = obj:getpos()
			local dist = vector.distance(obj_pos, pos)
			local damage = (fleshy * 0.5 ^ dist) * 2
			if dist ~= 0 then
				obj_pos.y = obj_pos.y + 1
				blast_pos = {x=pos.x, y=pos.y + 4, z=pos.z}
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
		vm:update_map()
	end
end

minetest.register_globalstep(function(dtime)
	for _,player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		if name then
			shooting[name] = player:get_player_control().LMB == true
		end
	end
end)
