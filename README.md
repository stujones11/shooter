[modpack] - Simple Shooter [shooter]
====================================

Mod Version: 0.6.0

Minetest Version: 5.0.0 (engine & game)

A simple first person shooter mod originally developed as part of a game that
was never completed. Now distributed as a Minetest Game compatible mod-pack.

[mod] Shooter API [shooter]
---------------------------

Depends: default

Handles raycasting, blasting and audio-visual effects of dependent mods.

[mod] Shooter Guns [shooter_guns]
---------------------------------

Depends: shooter

Adds basic guns using the shooter API.

[mod] Crossbow [shooter_crossbow]
---------------------------------

Depends: shooter, wool, dye

Adds a crossbow with colored arrows.

[mod] Flare Gun [shooter_flaregun]
----------------------------------

Depends: shooter, tnt, wool

Adds a flare-gun with temporary light emitting flares.

[mod] Grenade [shooter_grenade]
-------------------------------

Depends: shooter, tnt

Adds simple hand grenades.

[mod] Rocket Launcher [shooter_rocket]
--------------------------------------

Depends: shooter, tnt

Adds rocket missiles and launching gun.

[mod] Turret Gun [shooter_turret]
---------------------------------

Depends: shooter_rocket

Adds a mountable turret gun which can also be triggered by mesecon signals.
Still WIP and experimental and may be subject to change or removal.
