--[[
Shooter Guns [shooter_guns]
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

shooter.register_weapon("shooter_guns:pistol", {
	description = "Pistol",
	inventory_image = "shooter_pistol.png",
	spec = {
		rounds = 200,
		range = 160,
		step = 20,
		tool_caps = {full_punch_interval=0.5, damage_groups={fleshy=2, ranged=1}},
		groups = {snappy=3, fleshy=3, oddly_breakable_by_hand=3},
		sounds = {
			shot = "shooter_pistol",
		},
		bullet_image = "shooter_cap.png",
		particles = {
			amount = 8,
			minsize = 0.25,
			maxsize = 0.75,
		},
	},
})

shooter.register_weapon("shooter_guns:rifle", {
	description = "Rifle",
	inventory_image = "shooter_rifle.png",
	spec = {
		rounds = 100,
		range = 240,
		step = 30,
		tool_caps = {full_punch_interval=1.0, damage_groups={fleshy=3, ranged=1}},
		groups = {snappy=3, crumbly=3, choppy=3, fleshy=2, oddly_breakable_by_hand=2},
		sounds = {
			shot = "shooter_rifle",
		},
		bullet_image = "shooter_bullet.png",
		particles = {
			amount = 12,
			minsize = 0.75,
			maxsize = 1.5,
		},
	},
})

shooter.register_weapon("shooter_guns:shotgun", {
	description = "Shotgun",
	inventory_image = "shooter_shotgun.png",
	spec = {
		rounds = 12,
		range = 30,
		step = 15,
		shots = 15,
		spread = 10,
		tool_caps = {full_punch_interval=1, damage_groups={fleshy=2, ranged=1}},
		groups = {snappy=3, fleshy=3, oddly_breakable_by_hand=3},
		sounds = {
			shot = "shooter_shotgun",
		},
		bullet_image = "shooter_cap.png",
		particles = {
			amount = 8,
			minsize = 0.25,
			maxsize = 0.75,
		},
	},
})

shooter.register_weapon("shooter_guns:machine_gun", {
	description = "Sub Machine Gun",
	inventory_image = "shooter_smgun.png",
	spec = {
		automatic = true,
		rounds = 32,
		range = 160,
		step = 20,
		tool_caps = {full_punch_interval=0.1, damage_groups={fleshy=2, ranged=1}},
		groups = {snappy=3, fleshy=3, oddly_breakable_by_hand=3},
		sounds = {
			shot = "shooter_pistol",
		},
		bullet_image = "shooter_cap.png",
		particles = {
			amount = 4,
			minsize = 0.25,
			maxsize = 0.75,
		},
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
			{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
			{"", "default:bronze_ingot", "default:mese_crystal"},
			{"", "default:bronze_ingot", ""},
		},
	})
	minetest.register_craft({
		output = "shooter_guns:ammo",
		type = "shapeless",
		recipe = {"shooter:gunpowder", "default:bronze_ingot"},
	})
end

--Backwards compatibility
minetest.register_alias("shooter:shotgun", "shooter_guns:shotgun_loaded")
minetest.register_alias("shooter:pistol", "shooter_guns:pistol_loaded")
minetest.register_alias("shooter:machine_gun", "shooter_guns:machine_gun_loaded")
minetest.register_alias("shooter:rifle", "shooter_guns:rifle_loaded")
minetest.register_alias("shooter:ammo", "shooter_guns:ammo")
