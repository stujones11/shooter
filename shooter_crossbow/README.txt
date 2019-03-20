Minetest Mod - Crossbow [shooter_crossbow]
==========================================

Depends: shooter, wool, dye

Adds a crossbow with colored arrows.

Configuration
=============

Override the following default settings by adding them to your minetest.conf file

* `shooter_crossbow_uses = 50`: Number of crossbow uses
* `shooter_arrow_lifetime = 180`: Arrow exipiry time in seconds
* `shooter_arrow_fleshy = 2`: Arrow 'fleshy' damage level
* `shooter_arrow_object_attach = false`: Attach arrows to objects when hit
	* Experimental, currently does not work well with oversized selection boxes!


Crafting
========

<color> = grey, black, red, yellow, green, cyan, blue, magenta

A = Arrow        [shooter:arrow_white]
C = Color Dye    [dye:<color>]
W = Wooden Stick [default:stick]
P = Paper        [default:paper]
S = Steel Ingot  [default:steel_ingot]
B = Bronze Ingot [default:bronze_ingot]

Crossbow: [shooter_crossbow:crossbow]

+---+---+---+
| W | W | W |
+---+---+---+
| W | W |   |
+---+---+---+
| W |   | B |
+---+---+---+

White Arrow: [shooter_crossbow:arrow_white]

+---+---+---+
| S |   |   |
+---+---+---+
|   | W | P |
+---+---+---+
|   | P | W |
+---+---+---+

Coloured Arrow: [shooter_crossbow:arrow_<color>]

+---+---+
| C | A |
+---+---+

