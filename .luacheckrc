allow_defined_top = true

read_globals = {
	"ItemStack",
	"VoxelArea",
	"VoxelManip",
	"PseudoRandom",

	table  = {fields = {"copy"}},
}

globals = {
	"vector",
	"minetest",
}

files["shooter/init.lua"] = {
	globals = {"shooter"}
}

files["shooter_crossbow/init.lua"] = {
	globals = {"shooter", "SHOOTER_ARROW_TOOL_CAPS", "dye"}
}

files["shooter_flaregun/init.lua"] = {
	globals = {"shooter"}
}

files["shooter_grenade/init.lua"] = {
	globals = {"shooter"}
}

files["shooter_guns/init.lua"] = {
	globals = {"shooter"}
}

files["shooter_hook/init.lua"] = {
	globals = {"shooter"}
}

files["shooter_rocket/init.lua"] = {
	globals = {"shooter"}
}

files["shooter_turret/init.lua"] = {
	globals = {"shooter", "player_api"}
}
