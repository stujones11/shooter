shooter:register_weapon("guns:pistol", {
	description = "Pistol",
	inventory_image = "guns_pistol.png",
	rounds = 200,
	spec = {
		range = 100,
		step = 20,
		tool_caps = {full_punch_interval=0.5, damage_groups={fleshy=2}},
		groups = {snappy=3, fleshy=3, oddly_breakable_by_hand=3},
		sound = "guns_pistol",
		particle = "shooter_cap.png",
	},
})

shooter:register_weapon("guns:rifle", {
	description = "Rifle",
	inventory_image = "guns_rifle.png",
	rounds = 100,
	spec = {
		range = 200,
		step = 30,
		tool_caps = {full_punch_interval=1.0, damage_groups={fleshy=3}},
		groups = {snappy=3, crumbly=3, choppy=3, fleshy=2, oddly_breakable_by_hand=2},
		sound = "guns_rifle",
		particle = "shooter_bullet.png",
	},
})

shooter:register_weapon("guns:shotgun", {
	description = "Shotgun",
	inventory_image = "guns_shotgun.png",
	rounds = 50,
	spec = {
		range = 50,
		step = 15,
		tool_caps = {full_punch_interval=1.5, damage_groups={fleshy=4}},
		groups = {cracky=3, snappy=2, crumbly=2, choppy=2, fleshy=1, oddly_breakable_by_hand=1},
		sound = "guns_shotgun",
		particle = "smoke_puff.png",
	},
})

shooter:register_weapon("guns:machine_gun", {
	description = "Sub Machine Gun",
	inventory_image = "guns_smgun.png",
	rounds = 50,
	shots = 4,
	spec = {
		range = 100,
		step = 20,
		tool_caps = {full_punch_interval=0.125, damage_groups={fleshy=2}},
		groups = {snappy=3, fleshy=3, oddly_breakable_by_hand=3},
		sound = "guns_pistol",
		particle = "shooter_cap.png",
	},
})

minetest.register_craftitem("guns:ammo", {
	description = "Ammo pack",
	inventory_image = "guns_ammo.png",
})

if SHOOTER_ENABLE_CRAFTING == true then
	minetest.register_craft({
		output = "guns:pistol 1 65535",
		recipe = {
			{"default:steel_ingot", "default:steel_ingot"},
			{"", "default:mese_crystal"},
		},
	})
	minetest.register_craft({
		output = "guns:rifle 1 65535",
		recipe = {
			{"default:steel_ingot", "", ""},
			{"", "default:bronze_ingot", ""},
			{"", "default:mese_crystal", "default:bronze_ingot"},
		},
	})
	minetest.register_craft({
		output = "guns:shotgun 1 65535",
		recipe = {
			{"default:steel_ingot", "", ""},
			{"", "default:steel_ingot", ""},
			{"", "default:mese_crystal", "default:bronze_ingot"},
		},
	})
	minetest.register_craft({
		output = "guns:machine_gun 1 65535",
		recipe = {
			{"guns:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
			{"", "default:bronze_ingot", "default:mese_crystal"},
			{"", "default:bronze_ingot", ""},
		},
	})
	minetest.register_craft({
		output = "guns:ammo",
		recipe = {
			{"tnt:gunpowder", "default:bronze_ingot"},
		},
	})
end

local rounds_update_time = 0

minetest.register_globalstep(function(dtime)
	shooter.time = shooter.time + dtime
	if shooter.time - rounds_update_time > SHOOTER_ROUNDS_UPDATE_TIME then
		for i, round in ipairs(shooter.rounds) do
			if shooter:process_round(round) or round.dist > round.def.range then
				table.remove(shooter.rounds, i)
			else
				local v = vector.multiply(round.ray, round.def.step)
				shooter.rounds[i].pos = vector.add(round.pos, v)
				shooter.rounds[i].dist = round.dist + round.def.step
			end
		end
		rounds_update_time = shooter.time
	end
	if shooter.time > 100000 then
		shooter.shots = {}
		rounds_update_time = 0
		shooter.reload_time = 0
		shooter.update_time = 0
		shooter.time = 0
	end
end)


--Backwards compatibility
minetest.register_alias("shooter:shotgun", "guns:shotgun")
minetest.register_alias("shooter:pistol", "guns:pistol")
minetest.register_alias("shooter:machine_gun", "guns:machine_gun")
minetest.register_alias("shooter:rifle", "guns:rifle")
minetest.register_alias("shooter:ammo", "guns:ammo")
