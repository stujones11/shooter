local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath.."/api.lua")

minetest.register_entity("shooter:turret_entity", {
	visual = "sprite",
	textures = {"blank.png"},
	on_activate = function(self)
		self.object:remove()
	end,
})
