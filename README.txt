Minetest Mod - Simple Shooter [shooter]
=======================================

Mod Version: 0.5.0

Minetest Version: 0.4.9

Depends: default, wool, tnt

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
D = Diamond      [default:diamond]
R = Red Wool     [wool:red]
G = Gun Powder   [tnt:gunpowder]

Pistol: [shooter:pistol]

+---+---+
| S | S |
+---+---+
|   | M |
+---+---+

Rifle: [shooter:rifle]

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

Ammo Pack: [shooter:ammo]

+---+---+
| G | B |
+---+---+

Grappling Hook: [shooter:grapple_hook]

+---+---+---+
| S | S | D |
+---+---+---+
| S | S |   |
+---+---+---+
| D |   | S |
+---+---+---+

Grappling Hook Gun: [shooter:grapple_gun]

+---+---+
| S | S |
+---+---+
|   | D |
+---+---+

Flare: [shooter:flare]

+---+---+
| G | R |
+---+---+

Flare Gun: [shooter:flaregun]

+---+---+---+
| R | R | R |
+---+---+---+
|   |   | S |
+---+---+---+

Grenade: [shooter:grenade]

+---+---+
| G | S |
+---+---+

Flare Gun: [shooter:rocket_gun]

+---+---+---+
| B | S | S |
+---+---+---+
|   |   | D |
+---+---+---+

Rocket: [shooter:rocket]

+---+---+---+
| B | G | B |
+---+---+---+

Turret: [shooter:turret]

+---+---+---+
| B | B | S |
+---+---+---+
|   | B | S |
+---+---+---+
|   | D |   |
+---+---+---+

