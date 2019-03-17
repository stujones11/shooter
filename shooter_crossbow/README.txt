Minetest Mod - Crossbow [shooter_crossbow]
==========================================

Depends: shooter, wool, dye

Adds a crossbow with colored arrows.

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

