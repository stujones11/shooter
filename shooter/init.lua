local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath.."/api.lua")

if SHOOTER_ENABLE_FLARES == true then
	dofile(modpath.."/flaregun.lua")
end
if SHOOTER_ENABLE_HOOK == true then
	dofile(modpath.."/grapple.lua")
end



