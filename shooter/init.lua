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
