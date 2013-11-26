shooter = {}

local function in_range(r, x)
	local chance = r.a * (x * x) + r.b * x + r.c
	if math.random(100) < chance then
		return true
	end
	return false
end

function shooter:fire_weapon(user, def)
	minetest.sound_play(def.sound, {object=user})
	local target = {player=nil, distance=50}
	local p1 = user:getpos()
	for _,player in ipairs(minetest.get_connected_players()) do
		local p2 = player:getpos()
		if p1 and p2 then
			local x = vector.distance(p1, p2)
			p2.y = p2.y - 0.75
			if x > 0 and x < target.distance and x < 50 then
				if in_range(def.range_func, x) == true then
					local v1 = user:get_look_dir()
					local v2 = vector.normalize(vector.direction(p1, p2))
					local vd = vector.subtract(v1, v2)
					local yx = 0.00002 * (x * x) - 0.002 * x + 0.05
					local yy = yx * 3
					if math.abs(vd.x) < yx and
					   math.abs(vd.z) < yx and
					   math.abs(vd.y) < yy then
						target = {
							player = player,
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
	if target.player then
		if minetest.line_of_sight(target.pos1, target.pos2, 1) then
			target.player:punch(user, nil, def.tool_caps, target.direction)
		end
	end
end

minetest.register_on_joinplayer(function(player)
	player:hud_set_flags({crosshair = true})
end)

