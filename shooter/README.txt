Minetest Mod - Simple Shooter [shooter]
=======================================

Mod Version: 0.5.3

Minetest Version: 0.4.9, 0.4.10, 0.4.11

Depends: default, dye, tnt, wool

An experimental first person shooter mod that uses simple vector mathematics
to produce an accurate and server-firendly method of hit detection.

By default this mod is configured to work only against other players in
multiplayer mode and against Simple Mobs [mobs] in singleplayer mode.

Configuration
=============

Override the following default settings by adding them to your minetest.conf file.

-- Enable admin super weapons
-- This lets admins shoot guns automatically after 2 seconds without munition.
shooter_admin_weapons = false

-- Enable node destruction with explosives
shooter_enable_blasting = true

-- Enable Crafting
shooter_enable_crafting = true

-- Enable particle effects
shooter_enable_particle_fx = true

-- Enable protection mod support, requires a protection mod that utilizes
-- minetest.is_protected(), tested with TenPlus1's version of [protector]
shooter_enable_protection = false

-- Particle texture used when a player or entity is hit
shooter_explosion = "shooter_hit.png"

-- Allow node destruction
shooter_allow_nodes = true

-- Allow entities in multiplayer mode
shooter_allow_entities = false

-- Allow players in multiplayer mode
shooter_allow_players = true

-- How often objects are fully reloaded
shooter_object_reload_time = 1

-- How often object positions are updated
shooter_object_update_time = 0.25

-- How often rounds are processed
shooter_rounds_update_time = 0.4

Crafting
========

<color> = grey, black, red, yellow, green, cyan, blue, magenta

A = Arrow        [shooter:arrow_white]
C = Color Dye    [dye:<color>]
W = Wooden Stick [default:stick]
P = Paper        [default:paper]
S = Steel Ingot  [default:steel_ingot]
B = Bronze Ingot [default:bronze_ingot]
M = Mese Crystal [default:mese_crysytal]
D = Diamond      [default:diamond]
R = Red Wool     [wool:red]
G = Gun Powder   [tnt:gunpowder]

Crossbow: [shooter:crossbow]

+---+---+---+
| W | W | W |
+---+---+---+
| W | W |   |
+---+---+---+
| W |   | B |
+---+---+---+

White Arrow: [shooter:arrow_white]

+---+---+---+
| S |   |   |
+---+---+---+
|   | W | P |
+---+---+---+
|   | P | W |
+---+---+---+

Coloured Arrow: [shooter:arrow_<color>]

+---+---+
| C | A |
+---+---+

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

