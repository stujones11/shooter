Minetest Mod - Simple Shooter [shooter]
=======================================

Mod Version: 0.4.0

Minetest Version: 0.4.9

An experimental first person shooter mod that uses simple vector mathematics
to produce an accurate and server-firendly method of hit detection.

By default this mod is configured to work only against other players in
multiplayer mode and against Simple Mobs [mobs] in singleplayer mode.

Default configuration can be customised by adding a shooter.conf file to
the mod's main directory, see shooter.conf.example for more details.

This is still very much a work in progress which I eventually plan to use
as the base for a 'Spades' style FPS game using the minetest engine.

Crafting
========

S = Steel Ingot  [default:steel_ingot]
B = Bronze Ingot [default:bronze_ingot]
M = Mese Crystal [default:mese_crysytal]

Pistol: [shooter:pistol]

+---+---+
| S | S |
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

Sub Machine Gun: [shooter:machine_gun]

+---+---+---+
| S | S | S |
+---+---+---+
|   | B | M |
+---+---+---+
|   | B |   |
+---+---+---+

