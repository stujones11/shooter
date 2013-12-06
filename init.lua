dofile(minetest.get_modpath(minetest.get_current_modname()).."/shooter.lua")

minetest.register_tool("shooter:pistol", {
	description = "Pistol",
	inventory_image = "shooter_pistol.png",
	on_use = function(itemstack, user, pointed_thing)
		shooter:fire_weapon(user, pointed_thing, {
			range = 30,
			tool_caps = {full_punch_interval=0.5, damage_groups={fleshy=1}},
			groups = {snappy=3, oddly_breakable_by_hand=3},
			sound = "shooter_pistol",
			particle = "default_obsidian.png",
		})
		itemstack:add_wear(328) -- 200 Rounds
		return itemstack
	end,
})

minetest.register_tool("shooter:riffle", {
	description = "Riffle",
	inventory_image = "shooter_riffle.png",
	on_use = function(itemstack, user, pointed_thing)
		shooter:fire_weapon(user, pointed_thing, {
			range = 80,
			tool_caps = {full_punch_interval=1.0, damage_groups={fleshy=2}},
			groups = {snappy=3, crumbly=3, choppy=3, oddly_breakable_by_hand=2},
			sound = "shooter_riffle",
			particle = "default_gold_block.png",
		})
		itemstack:add_wear(656) -- 100 Rounds
		return itemstack
	end,
})

minetest.register_tool("shooter:shotgun", {
	description = "Shotgun",
	inventory_image = "shooter_shotgun.png",
	on_use = function(itemstack, user, pointed_thing)
		shooter:fire_weapon(user, pointed_thing, {
			range = 15,
			tool_caps = {full_punch_interval=1.5, damage_groups={fleshy=4}},
			groups = {cracky=3, snappy=2, crumbly=2, choppy=2, oddly_breakable_by_hand=1},
			sound = "shooter_shotgun",
			particle = "smoke_puff.png",
		})
		itemstack:add_wear(1311) -- 50 Rounds
		return itemstack
	end,
})

minetest.register_craft({
	output = "shooter:pistol",
	recipe = {
		{"default:steel_ingot", "default:bronze_ingot"},
		{"", "default:mese_crystal"},
	},
})

minetest.register_craft({
	output = "shooter:riffle",
	recipe = {
		{"default:steel_ingot", "", ""},
		{"", "default:bronze_ingot", ""},
		{"", "default:mese_crystal", "default:bronze_ingot"},
	},
})

minetest.register_craft({
	output = "shooter:shotgun",
	recipe = {
		{"default:steel_ingot", "", ""},
		{"", "default:steel_ingot", ""},
		{"", "default:mese_crystal", "default:bronze_ingot"},
	},
})

