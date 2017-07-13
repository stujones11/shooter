local modpath = minetest.get_modpath(minetest.get_current_modname())

if SHOOTER_ENABLE_TURRETS == true then
	dofile(modpath.."/turret.lua")
end

