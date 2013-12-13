Minetest Mod - Simple Shooter [shooter]
=======================================

Mod Version: 0.3.0

Minetest Version: 0.4.8-dev d9ef072305

Depends: default

An experimental first person shooter mod using simple vector mathematics
in an effort to find a more server-firendly method of hit detection from
that which is currently being used by the firearms mod.

For the most part I think I have achieved this for straight pvp, however,
the jury is still out as to whether it is any faster against entities (mobs)

By default this mod is configured to work only against other players in
multiplayer (server) mode. This is overridden in singleplayer mode to work
against all registered entities instead.

Default configuration can be customised by adding a shooter.conf file to the
mod's main directory, see shooter.conf.example for more details.

This is still very much a work in progress which I plan to eventually use as
the base for a 'Spades' style FPS game using the minetest engine.

Crafting
========

S = Steel Ingot  [default:steel_ingot]
B = Bronze Ingot [default:bronze_ingot]
M = Mese Crystal [default:mese_crysytal]

Pistol: [shooter:pistol]

+---+---+
| S | B |
+---+---+
|   | M |
+---+---+

Riffle: [shooter:riffle]

+---+---+---+
| S |   |   |
+---+---+---+
|   | B |   |
+---+---+---+
|   | M | B |
+---+---+---+

Shotgun: [shooter:shotgun]

+---+---+---+
| S |   |   |
+---+---+---+
|   | S |   |
+---+---+---+
|   | M | B |
+---+---+---+

