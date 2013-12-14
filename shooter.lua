shooter = {}

SHOOTER_EXPLOSION_TEXTURE = "shooter_hit.png"
SHOOTER_ALLOW_ENTITIES = false
SHOOTER_OBJECT_RANGE = 50

local modpath = minetest.get_modpath(minetest.get_current_modname())
local input = io.open(modpath.."/shooter.conf", "r")
if input then
	dofile(modpath.."/shooter.conf")
	input:close()
	input = nil
end
if minetest.is_singleplayer() == true then
	SHOOTER_ALLOW_ENTITIES = true
end
local timer = 0
local shots = {}

local function spawn_particles(p, v, d, texture)
	if texture.type ~= "string" then
		texture = SHOOTER_EXPLOSION_TEXTURE
	end
	local pos = vector.add(p, vector.multiply(v, {x=d, y=d, z=d}))
	pos.y = pos.y + 0.75
	local spread = {x=0.1, y=0.1, z=0.1}
	minetest.add_particlespawner(15, 0.3,
		vector.subtract(pos, spread), vector.add(pos, spread),
		{x=-1, y=1, z=-1}, {x=1, y=2, z=1},
		{x=-2, y=-2, z=-2}, {x=2, y=-2, z=2},
		0.1, 0.75, 1, 2, false, texture
	)
end

local function is_valid_object(object)
	if object:is_player() == true then
		return true
	end
	if SHOOTER_ALLOW_ENTITIES == true then
		local luaentity = object:get_luaentity()
		if luaentity then
			if minetest.registered_entities[luaentity.name] then
				return true
			end
		end
	end
	return false
end

function shooter:fire_weapon(user, pointed_thing, def)
	local name = user:get_player_name()
	if shots[name] then
		if timer < shots[name] then
			return
		end
	end
	shots[name] = timer + def.tool_caps.full_punch_interval
	minetest.sound_play(def.sound, {object=user})
	local v1 = user:get_look_dir()
	local p1 = user:getpos()
	minetest.add_particle({x=p1.x, y=p1.y + 1.6, z=p1.z},
		vector.multiply(v1, {x=30, y=30, z=30}),
		{x=0, y=0, z=0}, 0.5, 0.25,
		false, def.particle
	)
	if pointed_thing.type == "node" then
		local pos = minetest.get_pointed_thing_position(pointed_thing, false)
		local node = minetest.get_node(pos)
		if not node then
			return
		end
		local item = minetest.registered_items[node.name]
		if not item.groups then
			return
		end
		for k, v in pairs(def.groups) do
			local level = item.groups[k] or 0
			if level >= v then
				minetest.remove_node(pos)
				local sounds = item.sounds
				if sounds then
					local soundspec = sounds.dug
					if soundspec then
						soundspec.pos = pos
						minetest.sound_play(soundspec.name, soundspec)
					end
				end
				local tiles = item.tiles
				if tiles then
					if tiles[1] then
						spawn_particles({x=p1.x, y=p1.y + 0.75, z=p1.z},
						v1, vector.distance(p1, pos), tiles[1])
					end
				end
				break
			end
		end
		return
	elseif pointed_thing.type == "object" then
		local object = pointed_thing.ref
		if is_valid_object(object) == true then
			object:punch(user, nil, def.tool_caps, v1)
			local p2 = object:getpos()
			spawn_particles({x=p1.x, y=p1.y + 0.75, z=p1.z}, v1,
			vector.distance(p1, p2), SHOOTER_EXPLOSION_TEXTURE)
			return
		end
	end
	if def.range > 100 then
		def.range = 100
	end
	local target = {object=nil, distance=100}
	local objects = {}
	if SHOOTER_ALLOW_ENTITIES == true then
		local range = def.range
		if range > SHOOTER_OBJECT_RANGE then
			range = SHOOTER_OBJECT_RANGE
		end
		local r = math.ceil(range * 0.5)
		local p = vector.add(p1, vector.multiply(v1, {x=r, y=r, z=r}))
		objects = minetest.get_objects_inside_radius(p, r)
	else
		objects = minetest.get_connected_players()
	end
	for _,object in ipairs(objects) do
		if is_valid_object(object) == true then
			local p2 = object:getpos()
			if p1 and p2 then
				local x = vector.distance(p1, p2)
				p2.y = p2.y - 0.75
				if x > 0 and x < target.distance and x < def.range then
					local yx = 0
					if x > 30 then
						yx = 0.001 * (10 - x * 0.1)
					else
						yx = 0.00002 * (x * x) - 0.002 * x + 0.05
					end
					local yy = yx * 3
					local v2 = vector.normalize(vector.direction(p1, p2))
					local vd = vector.subtract(v1, v2)
					if math.abs(vd.x) < yx and
					math.abs(vd.z) < yx and
					math.abs(vd.y) < yy then
						target = {
							object = object,
							distance = x,
							direction = v1,
							pos1 = {x=p1.x, z=p1.z, y=p1.y+1},
							pos2 = {x=p2.x, z=p2.z, y=p2.y+1.75},
						}
					end
				end
			end
		end
	end
	if target.object then
		if minetest.line_of_sight(target.pos1, target.pos2, 1) then
			target.object:punch(user, nil, def.tool_caps, target.direction)
			spawn_particles(target.pos1, target.direction,
			target.distance, SHOOTER_EXPLOSION_TEXTURE)
		end
	end
end

minetest.register_on_joinplayer(function(player)
	player:hud_set_flags({crosshair = true})
end)

minetest.register_globalstep(function(dtime)
	timer = timer + dtime
end)

