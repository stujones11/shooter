[modpack] Simple Shooter [shooter]
====================================

![screenshot](https://raw.githubusercontent.com/stujones11/shooter/master/screenshot.png)

**Mod Version:** 0.6.1

**Minetest Version:** 5.0.0 (engine & game)

A simple first person shooter mod originally developed as part of a game that
was never completed. Now distributed as a Minetest Game compatible mod-pack.

[mod] Shooter API [shooter]
---------------------------

**Depends:** default

<img align="left" width="32" height="32" src="https://raw.githubusercontent.com/stujones11/shooter/master/shooter/textures/shooter_powder.png">
Handles raycasting, blasting and audio-visual effects of dependent mods.

[mod] Shooter Guns [shooter_guns]
---------------------------------

**Depends:** shooter

<img align="left" width="32" height="32" src="https://raw.githubusercontent.com/stujones11/shooter/master/shooter_guns/textures/shooter_rifle.png">
Adds basic guns using the shooter API.

[mod] Crossbow [shooter_crossbow]
---------------------------------

**Depends:** shooter

**Optional Depends:** dye (required for colored arrows)

<img align="left" width="32" height="32" src="https://raw.githubusercontent.com/stujones11/shooter/master/shooter_crossbow/textures/shooter_crossbow.png">
Adds a crossbow with colored arrows.

[mod] Flare Gun [shooter_flaregun]
----------------------------------

**Depends:** shooter

<img align="left" width="32" height="32" src="https://raw.githubusercontent.com/stujones11/shooter/master/shooter_flaregun/textures/shooter_flaregun.png">
Adds a flare-gun with temporary light emitting flares.

[mod] Grenade [shooter_grenade]
-------------------------------

**Depends:** shooter

<img align="left" width="32" height="32" src="https://raw.githubusercontent.com/stujones11/shooter/master/shooter_grenade/textures/shooter_hand_grenade.png">
Adds simple hand grenades.

[mod] Rocket Launcher [shooter_rocket]
--------------------------------------

**Depends:** shooter

<img align="left" width="32" height="32" src="https://raw.githubusercontent.com/stujones11/shooter/master/shooter_rocket/textures/shooter_rocket_gun_loaded.png">
Adds rocket missiles and launching gun.

[mod] Grapple Hook [shooter_hook]
---------------------------------

**Depends:** shooter

<img align="left" width="32" height="32" src="https://raw.githubusercontent.com/stujones11/shooter/master/shooter_hook/textures/shooter_hook_gun_loaded.png">
Adds a teleporting grapple hook which can be thrown or launched
further from a grapple hook gun.

[mod] Turret Gun [shooter_turret]
---------------------------------

**Depends:** shooter_rocket

<img align="left" width="32" height="32" src="https://raw.githubusercontent.com/stujones11/shooter/master/shooter_turret/textures/shooter_turret_gun.png">
Adds a mountable turret gun which can also be triggered by mesecon signals.
Still WIP and experimental and may be subject to change or removal.
