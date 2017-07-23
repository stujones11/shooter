local modpath = minetest.get_modpath(minetest.get_current_modname())

if SHOOTER_ENABLE_HOOK == true then
	dofile(modpath.."/grapple.lua")
end

