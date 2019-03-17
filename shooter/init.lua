/*
Simple Shooter [shooter]
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
*/

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local worldpath = minetest.get_worldpath()

dofile(modpath.."/api.lua")

if minetest.is_singleplayer() then
	shooter.config.enable_blasting = true
	shooter.config.allow_entities = true
	shooter.config.allow_players = false
end

-- Legacy Config Support

local input = io.open(modpath.."/shooter.conf", "r")
if input then
	dofile(modpath.."/shooter.conf")
	input:close()
	input = nil
end
input = io.open(worldpath.."/shooter.conf", "r")
if input then
	dofile(worldpath.."/shooter.conf")
	input:close()
	input = nil
end
for name, _ in pairs(shooter.config) do
	local global = "SHOOTER_"..name:upper()
	if minetest.global_exists(global) then
		shooter.config[name] = _G[global]
	end
end

-- Load Configuration

for name, config in pairs(shooter.config) do
	local setting = minetest.settings:get("shooter_"..name)
	if type(config) == "number" then
		setting = tonumber(setting)
	elseif type(config) == "boolean" then
		setting = minetest.settings:get_bool("shooter_"..name)
	end
	if setting ~= nil then
		shooter.config[name] = setting
	end
end

-- Legacy Entity Support

minetest.register_entity("shooter:turret_entity", {
	visual = "sprite",
	textures = {"blank.png"},
	on_activate = function(self)
		self.object:remove()
	end,
})

-- Automatic Firing

if shooter.config.automatic_weapons == true then
	minetest.register_globalstep(function(dtime)
		for _,player in pairs(minetest.get_connected_players()) do
			local name = player:get_player_name()
			if name then
				shooter.set_shooting(name,
					player:get_player_control().LMB == true)
			end
		end
	end)
end
