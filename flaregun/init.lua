local modpath = minetest.get_modpath(minetest.get_current_modname())

if SHOOTER_ENABLE_FLARES == true then
	dofile(modpath.."/flaregun.lua")
end
