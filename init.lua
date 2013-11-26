dofile(minetest.get_modpath(minetest.get_current_modname()).."/shooter.lua")

minetest.register_tool("shooter:pistol", {
    description = "Pistol",
    inventory_image = "shooter_pistol.png",
	on_use = function(itemstack, user, pointed_thing)
		shooter:fire_weapon(user, {
			range_func = {a=-0.1, b=-1.5, c=100},
			tool_caps = {full_punch_interval=1.0, damage_groups={fleshy=3}},
			sound = "shooter_pistol",
		})
		itemstack:add_wear(328) -- 200 Rounds
		return itemstack
	end,
})

minetest.register_tool("shooter:riffle", {
    description = "Riffle",
    inventory_image = "shooter_riffle.png",
	on_use = function(itemstack, user, pointed_thing)
		shooter:fire_weapon(user, {
			range_func = {a=-0.02, b=-0.6, c=100},
			tool_caps = {full_punch_interval=1.0, damage_groups={fleshy=5}},
			sound = "shooter_riffle",
		})
		itemstack:add_wear(656) -- 100 Rounds
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

