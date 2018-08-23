shooter = {
	time = 0,
	objects = {},
	rounds = {},
	shots = {},
	update_time = 0,
	reload_time = 0,
	player_offset = {x=0, y=1, z=0},
	entity_offset = {x=0, y=0, z=0},
}

shooter.config = {
	admin_weapons = false,
	enable_blasting = false,
	enable_particle_fx = true,
	enable_protection = false,
	enable_crafting = true,
	explosion_texture = "shooter_hit.png",
	allow_nodes = true,
	allow_entities = false,
	allow_players = true,
	object_reload_time = 1,
	object_update_time = 0.25,
	rounds_update_time = 0.4,
}

local config = shooter.config
local singleplayer = minetest.is_singleplayer()
local allowed_entities = {}

local function get_dot_product(v1, v2)
	return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
end

local function get_particle_pos(p, v, d)
	return vector.add(p, vector.multiply(v, {x=d, y=d, z=d}))
end

function shooter:set_shootable_entity(name)
	allowed_entities[name] = 1
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

function shooter:punch_node(pos, def)
	local node = minetest.get_node(pos)
	if not node then
		return
	end
	local item = minetest.registered_items[node.name]
	if not item then
		return
	end
	if config.enable_protection then
		if minetest.is_protected(pos, def.name) then
			return
		end
	end
	if item.groups then
		for k, v in pairs(def.groups) do
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
				if luaentity.name then
					if allowed_entities[luaentity.name] then
						return true
					end
				end
			end
		end
	end
end

function shooter:get_intersect_pos(ray, plane, collisionbox)
	local v = vector.subtract(ray.pos, plane.pos)
	local r1 = get_dot_product(v, plane.normal)
	local r2 = get_dot_product(ray.dir, plane.normal)
	if r2 ~= 0 then
		local t = -(r1 / r2)
		local td = vector.multiply(ray.dir, {x=t, y=t, z=t})
		local pt = vector.add(ray.pos, td)
		local pd = vector.subtract(pt, plane.pos)
		if math.abs(pd.x) < collisionbox[4] and
				math.abs(pd.y) < collisionbox[5] and
				math.abs(pd.z) < collisionbox[6] then
			return pt
		end
	end
end

function shooter:process_round(round)
	local target = {object=nil, distance=10000}
	local p1 = round.pos
	local v1 = round.ray
	for _,ref in ipairs(shooter.objects) do
		local p2 = vector.add(ref.pos, ref.offset)
		if p1 and p2 and ref.name ~= round.name then
			local d = vector.distance(p1, p2)
			if d < round.def.step and d < target.distance then
				local ray = {pos=p1, dir=v1}
				local plane = {pos=p2, normal={x=-1, y=0, z=-1}}
				local pos = shooter:get_intersect_pos(ray, plane, ref.collisionbox)
				if pos then
					target.object = ref.object
					target.pos = pos
					target.distance = d
				end
			end
		end
	end
	if target.object and target.pos then
		local success, pos = minetest.line_of_sight(p1, target.pos, 1)
		if success then
			local user = minetest.get_player_by_name(round.name)
			if user then
				target.object:punch(user, nil, round.def.tool_caps, v1)
				shooter:spawn_particles(target.pos, config.explosion_texture)
			end
			return 1
		elseif pos and config.allow_nodes == true then
			shooter:punch_node(pos, round.def)
			return 1
		end
	elseif config.allow_nodes == true then
		local d = round.def.step
		local p2 = vector.add(p1, vector.multiply(v1, {x=d, y=d, z=d}))
		local success, pos = minetest.line_of_sight(p1, p2, 1)
		if pos then
			shooter:punch_node(pos, round.def)
			return 1
		end
	end
end

shooter.registered_weapons = shooter.registered_weapons or {}
function shooter:register_weapon(name, def)
	shooter.registered_weapons[name] = def
	local shots = def.shots or 1
	local wear = math.ceil(65534 / def.rounds)
	local max_wear = (def.rounds - 1) * wear
	-- Fix sounds table
	def.sounds = def.sounds or {}
	-- Default sounds
	def.sounds.reload = def.sounds.reload or "shooter_reload"
	def.sounds.fail_shot = def.sounds.fail_shot or "shooter_click"
	-- Assert reload item
	def.reload_item = def.reload_item or "shooter:ammo"
	minetest.register_tool(name, {
		description = def.description,
		inventory_image = def.inventory_image,
		on_use = function(itemstack, user, pointed_thing)
			if itemstack:get_wear() < max_wear then
				def.spec.name = user:get_player_name()
				if shots > 1 then
					local step = def.spec.tool_caps.full_punch_interval
					for i = 0, step * shots, step do
						minetest.after(i, function()
							shooter:fire_weapon(user, pointed_thing, def.spec)
						end)
					end
				else
					shooter:fire_weapon(user, pointed_thing, def.spec)
				end
				itemstack:add_wear(wear)
			else
				local inv = user:get_inventory()
				if inv then
					local stack = def.reload_item .. " 1"
					if inv:contains_item("main", stack) then
						minetest.sound_play((def.sounds.reload), {object=user})
						inv:remove_item("main", stack)
						if def.unloaded_item then
							itemstack:replace(def.unloaded_item.name.." 1 1")
						else
							itemstack:replace(name.." 1 1")
						end
					else
						minetest.sound_play((def.sounds.fail_shot), {object=user})
					end
				end
			end
			-- Replace to unloaded item
			if def.unloaded_item and (itemstack:get_wear() + wear) > 65534 then
				itemstack:set_name(def.unloaded_item.name)
			end
			return itemstack
		end,
	})
	-- Register unloaded item tool
	if def.unloaded_item then
		local groups = {}
		if def.unloaded_item.not_in_creative_inventory == true then
			groups = {not_in_creative_inventory=1}
		end
		minetest.register_tool(def.unloaded_item.name, {
			description = def.unloaded_item.description,
			inventory_image = def.unloaded_item.inventory_image,
			groups = groups,
			on_use = function(itemstack, user, pointed_thing)
				local inv = user:get_inventory()
				if inv then
					local stack = def.reload_item .. " 1"
					if inv:contains_item("main", stack) then
						minetest.sound_play((def.sounds.reload), {object=user})
						inv:remove_item("main", stack)
						itemstack:replace(name.." 1 1")
					else
						minetest.sound_play((def.sounds.fail_shot), {object=user})
					end
				end
				return itemstack
			end,
		})
	end
end

function shooter:fire_weapon(user, pointed_thing, def)
	if shooter.shots[def.name] then
		if shooter.time < shooter.shots[def.name] then
			return
		end
	end
	shooter.shots[def.name] = shooter.time + def.tool_caps.full_punch_interval
	minetest.sound_play(def.sound, {object=user})
	local v1 = user:get_look_dir()
	local p1 = user:getpos()
	if not v1 or not p1 then
		return
	end
	minetest.add_particle({x=p1.x, y=p1.y + 1.6, z=p1.z},
		vector.multiply(v1, {x=30, y=30, z=30}),
		{x=0, y=0, z=0}, 0.5, 0.25,
		false, def.particle
	)
	if pointed_thing.type == "node" and config.allow_nodes == true then
		local pos = minetest.get_pointed_thing_position(pointed_thing, false)
		shooter:punch_node(pos, def)
	elseif pointed_thing.type == "object" then
		local object = pointed_thing.ref
		if shooter:is_valid_object(object) == true then
			object:punch(user, nil, def.tool_caps, v1)
			local p2 = object:getpos()
			local pp = get_particle_pos(p1, v1, vector.distance(p1, p2))
			pp.y = pp.y + 1.75
			shooter:spawn_particles(pp, config.explosion_texture)
		end
	else
		shooter:update_objects()
		table.insert(shooter.rounds, {
			name = def.name,
			pos = vector.add(p1, {x=0, y=1.75, z=0}),
			ray = v1,
			dist = 0,
			def = def,
		})
	end
end

function shooter:load_objects()
	local objects = {}
	if config.allow_players == true then
		local players = minetest.get_connected_players()
		for _,player in ipairs(players) do
			local pos = player:getpos()
			local name = player:get_player_name()
			local hp = player:get_hp() or 0
			if pos and name and hp > 0 then
				table.insert(objects, {
					name = name,
					object = player,
					pos = pos,
					collisionbox = {-0.25,-1.0,-0.25, 0.25,0.8,0.25},
					offset = shooter.player_offset,
				})
			end
		end
	end
	if config.allow_entities == true then
		for _,ref in pairs(minetest.luaentities) do
			if ref.object and ref.name then
				if allowed_entities[ref.name] then
					local pos = ref.object:getpos()
					local hp = ref.object:get_hp() or 0
					if pos and hp > 0 then
						local def = minetest.registered_entities[ref.name]
						table.insert(objects, {
							name = ref.name,
							object = ref.object,
							pos = pos,
							collisionbox = def.collisionbox or {0,0,0, 0,0,0},
							offset = shooter.entity_offset,
						})
					end
				end
			end
		end
	end
	shooter.reload_time = shooter.time
	shooter.update_time = shooter.time
	shooter.objects = {}
	for _,v in ipairs(objects) do
		table.insert(shooter.objects, v)
	end
end

function shooter:update_objects()
	if shooter.time - shooter.reload_time > config.object_reload_time then
		shooter:load_objects()
	elseif shooter.time - shooter.update_time > config.object_update_time then
		for i, ref in ipairs(shooter.objects) do
			if ref.object then
				local pos = ref.object:getpos()
				if pos then
					shooter.objects[i].pos = pos
				end
			else
				table.remove(shooter.objects, i)
			end
		end
		shooter.update_time = shooter.time
	end
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
		if (obj:is_player() and config.allow_players == true) or
				(obj:get_luaentity() and config.allow_entities == true and
				obj:get_luaentity().name ~= "__builtin:item") then
			local obj_pos = obj:getpos()
			local dist = vector.distance(obj_pos, pos)
			local damage = (fleshy * 0.5 ^ dist) * 2
			if dist ~= 0 then
				obj_pos.y = obj_pos.y + 1.7
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

if not singleplayer and config.admin_weapons then
	local timer = 0
	local shooting = false
	minetest.register_globalstep(function(dtime)
		if not shooting then
			timer = timer+dtime
			if timer < 2 then
				return
			end
			timer = 0
		end
		shooting = false
		for _,player in pairs(minetest.get_connected_players()) do
			if player:get_player_control().LMB then
				local name = player:get_player_name()
				if minetest.check_player_privs(name, {server=true}) then
					local spec = shooter.registered_weapons[player:get_wielded_item():get_name()]
					if spec then
						spec = spec.spec
						shooter.shots[name] = false
						spec.name = name
						shooter:fire_weapon(player, {}, spec)
						shooting = true
					end
				end
			end
		end
	end)
end
