local modpath = minetest.get_modpath(minetest.get_current_modname())

if SHOOTER_ENABLE_GUNS == true then
	dofile(modpath.."/guns.lua")
end
