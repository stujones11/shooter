Minetest Mod - Shooter Guns [shooter_guns]
==========================================

Depends: shooter

Adds basic guns using the shooter API.

Crafting
========

S = Steel Ingot  [default:steel_ingot]
B = Bronze Ingot [default:bronze_ingot]
M = Mese Crystal [default:mese_crysytal]
G = Gun Powder   [tnt:gunpowder]

Pistol: [shooter_guns:pistol]

+---+---+
| S | S |
+---+---+
|   | M |
+---+---+

Rifle: [shooter_guns:rifle]

+---+---+---+
| S |   |   |
+---+---+---+
|   | B |   |
+---+---+---+
|   | M | B |
+---+---+---+

Shotgun: [shooter_guns:shotgun]

+---+---+---+
| S |   |   |
+---+---+---+
|   | S |   |
+---+---+---+
|   | M | B |
+---+---+---+

Sub Machine Gun: [shooter_guns:machine_gun]

+---+---+---+
| S | S | S |
+---+---+---+
|   | B | M |
+---+---+---+
|   | B |   |
+---+---+---+

Ammo Pack: [shooter_guns:ammo]

+---+---+
| G | B |
+---+---+

