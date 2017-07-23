local modpath = minetest.get_modpath(minetest.get_current_modname())

if SHOOTER_ENABLE_ROCKETS == true then
	dofile(modpath.."/rocket.lua")
end

