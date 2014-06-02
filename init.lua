dofile(minetest.get_modpath(minetest.get_current_modname()).."/shooter.lua")

minetest.register_tool("shooter:pistol", {
	description = "Pistol",
	inventory_image = "shooter_pistol.png",
	on_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		shooter:fire_weapon(user, pointed_thing, {
			name = name,
			range = 100,
			step = 20,
			tool_caps = {full_punch_interval=0.5, damage_groups={fleshy=2}},
			groups = {snappy=3, fleshy=3, oddly_breakable_by_hand=3},
			sound = "shooter_pistol",
			particle = "shooter_cap.png",
		})
		itemstack:add_wear(328) -- 200 Rounds
		return itemstack
	end,
})

minetest.register_tool("shooter:riffle", {
	description = "Riffle",
	inventory_image = "shooter_riffle.png",
	on_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		shooter:fire_weapon(user, pointed_thing, {
			name = name,
			range = 200,
			step = 30,
			tool_caps = {full_punch_interval=1.0, damage_groups={fleshy=3}},
			groups = {snappy=3, crumbly=3, choppy=3, fleshy=2, oddly_breakable_by_hand=2},
			sound = "shooter_riffle",
			particle = "shooter_bullet.png",
		})
		itemstack:add_wear(656) -- 100 Rounds
		return itemstack
	end,
})

minetest.register_tool("shooter:shotgun", {
	description = "Shotgun",
	inventory_image = "shooter_shotgun.png",
	on_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		shooter:fire_weapon(user, pointed_thing, {
			name = name,
			range = 50,
			step = 15,
			tool_caps = {full_punch_interval=1.5, damage_groups={fleshy=4}},
			groups = {cracky=3, snappy=2, crumbly=2, choppy=2, fleshy=1, oddly_breakable_by_hand=1},
			sound = "shooter_shotgun",
			particle = "smoke_puff.png",
		})
		itemstack:add_wear(1311) -- 50 Rounds
		return itemstack
	end,
})

minetest.register_tool("shooter:machine_gun", {
	description = "Sub Machine Gun",
	inventory_image = "shooter_smgun.png",
	on_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		for i = 0, 0.45, 0.15 do
			minetest.after(i, function()
				shooter:fire_weapon(user, pointed_thing, {
					name = name,
					range = 100,
					step = 20,
					tool_caps = {full_punch_interval=0.1, damage_groups={fleshy=2}},
					groups = {snappy=3, fleshy=3, oddly_breakable_by_hand=3},
					sound = "shooter_pistol",
					particle = "shooter_cap.png",
				})
			end)
		end
		itemstack:add_wear(328) -- 4 x 200 Rounds
		return itemstack
	end,
})

minetest.register_craft({
	output = "shooter:pistol",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot"},
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

minetest.register_craft({
	output = "shooter:machine_gun",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"", "default:bronze_ingot", "default:mese_crystal"},
		{"", "default:bronze_ingot", ""},
	},
})

