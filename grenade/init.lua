local modpath = minetest.get_modpath(minetest.get_current_modname())

if SHOOTER_ENABLE_GRENADES == true then
	dofile(modpath.."/grenade.lua")
end
