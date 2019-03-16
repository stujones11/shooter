shooter.register_weapon("shooter_guns:pistol", {
	description = "Pistol",
	inventory_image = "shooter_pistol.png",
	spec = {
		rounds = 200,
		range = 160,
		step = 20,
		tool_caps = {full_punch_interval=0.5, damage_groups={fleshy=2}},
		groups = {snappy=3, fleshy=3, oddly_breakable_by_hand=3},
		sound = "shooter_pistol",
		particle = "shooter_cap.png",
	},
})

shooter.register_weapon("shooter_guns:rifle", {
	description = "Rifle",
	inventory_image = "shooter_rifle.png",
	spec = {
		rounds = 100,
		range = 240,
		step = 30,
		tool_caps = {full_punch_interval=1.0, damage_groups={fleshy=3}},
		groups = {snappy=3, crumbly=3, choppy=3, fleshy=2, oddly_breakable_by_hand=2},
		sound = "shooter_rifle",
		particle = "shooter_bullet.png",
	},
})

shooter.register_weapon("shooter_guns:shotgun", {
	description = "Shotgun",
	inventory_image = "shooter_shotgun.png",
	spec = {
		rounds = 50,
		range = 60,
		step = 15,
		tool_caps = {full_punch_interval=1.5, damage_groups={fleshy=4}},
		groups = {cracky=3, snappy=2, crumbly=2, choppy=2, fleshy=1, oddly_breakable_by_hand=1},
		sound = "shooter_shotgun",
		particle = "smoke_puff.png",
	},
})

shooter.register_weapon("shooter_guns:machine_gun", {
	description = "Sub Machine Gun",
	inventory_image = "shooter_smgun.png",
	spec = {
		automatic = true,
		rounds = 100,
		range = 160,
		step = 20,
		tool_caps = {full_punch_interval=0.1, damage_groups={fleshy=2}},
		groups = {snappy=3, fleshy=3, oddly_breakable_by_hand=3},
		sound = "shooter_pistol",
		particle = "shooter_cap.png",
	},
})

minetest.register_craftitem("shooter_guns:ammo", {
	description = "Ammo pack",
	inventory_image = "shooter_ammo.png",
})

if shooter.config.enable_crafting == true then
	minetest.register_craft({
		output = "shooter_guns:pistol 1 65535",
		recipe = {
			{"default:steel_ingot", "default:steel_ingot"},
			{"", "default:mese_crystal"},
		},
	})
	minetest.register_craft({
		output = "shooter_guns:rifle 1 65535",
		recipe = {
			{"default:steel_ingot", "", ""},
			{"", "default:bronze_ingot", ""},
			{"", "default:mese_crystal", "default:bronze_ingot"},
		},
	})
	minetest.register_craft({
		output = "shooter_guns:shotgun 1 65535",
		recipe = {
			{"default:steel_ingot", "", ""},
			{"", "default:steel_ingot", ""},
			{"", "default:mese_crystal", "default:bronze_ingot"},
		},
	})
	minetest.register_craft({
		output = "shooter_guns:machine_gun 1 65535",
		recipe = {
			{"shooter_guns:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
			{"", "default:bronze_ingot", "default:mese_crystal"},
			{"", "default:bronze_ingot", ""},
		},
	})
	minetest.register_craft({
		output = "shooter_guns:ammo",
		recipe = {
			{"tnt:gunpowder", "default:bronze_ingot"},
		},
	})
end

--Backwards compatibility
minetest.register_alias("shooter:shotgun", "shooter_guns:shotgun")
minetest.register_alias("shooter:pistol", "shooter_guns:pistol")
minetest.register_alias("shooter:machine_gun", "shooter_guns:machine_gun")
minetest.register_alias("shooter:rifle", "shooter_guns:rifle")
minetest.register_alias("shooter:ammo", "shooter_guns:ammo")
