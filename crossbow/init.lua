local modpath = minetest.get_modpath(minetest.get_current_modname())

if SHOOTER_ENABLE_CROSSBOW == true then
	dofile(modpath.."/crossbow.lua")
end

