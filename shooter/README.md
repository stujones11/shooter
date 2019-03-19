Minetest Mod - Shooter API [shooter]
====================================

Depends: default

Handles raycasting, blasting and audio-visual effects of dependent mods.

Configuration
-------------

Override the following default settings by adding them to your minetest.conf file.

-- Enable automatic weapons, uses globalstep to detect left mouse button

`shooter_admin_weapons = true`

-- Enable admin super weapons
-- This lets admins shoot guns automatically after 2 seconds without munition.

`shooter_admin_weapons = false`

-- Enable node destruction with explosives
shooter_enable_blasting = true

-- Enable Crafting

`shooter_enable_crafting = true`

-- Enable particle effects

`shooter_enable_particle_fx = true`

-- Enable protection mod support, requires a protection mod that utilizes
-- minetest.is_protected(), tested with TenPlus1's version of [protector]

`shooter_enable_protection = false`

-- Particle texture used when a player or entity is hit

`shooter_explosion = "shooter_hit.png"`

-- Allow node destruction

`shooter_allow_nodes = true`

-- Allow entities in multiplayer mode

`shooter_allow_entities = false`

-- Allow players in multiplayer mode

`shooter_allow_players = true`

-- How often objects are fully reloaded

`shooter_object_reload_time = 1`

-- How often object positions are updated

`shooter_object_update_time = 0.25`

-- How often rounds are processed

`shooter_rounds_update_time = 0.4`

API Documentation
-----------------

TODO

