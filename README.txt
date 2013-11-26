Minetest Mod - Simple Shooter [shooter]
=======================================

Mod Version: 0.1.0

Minetest Version: 0.4.8

Depends: default

An experimental first person shooter mod using vector mathematics instead of
physical projectile entities. This has a number of advantages along with a
number disadvantages.

Pros:

Fast and responsive
Fairly light weight
Not affected by chunk boundaries

Cons:

Only works against other players
Slightly less realistic

This is still very much a work in progress and currently not much use in a
singleplayer game. I plan to eventually use this as a base for a 'Spades' style
FPS game using the minetest engine, however, I decided to add a couple of craft
recipes and release this simple version for minetest_game.

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

