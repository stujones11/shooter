Shooter API Reference Alpha (DEV)
=================================

IMPORTANT: This WIP & unfinished file contains the definitions of current advanced_npc functions
(Some documentation is lacking, so please bear in mind that this WIP file is just to enhance it)


Summary
-------
* Introduction
* Register a Weapon
* Definition tables


Introduction
------------
An experimental first person shooter mod that uses simple vector mathematics
to produce an accurate and server-firendly method of hit detection.

By default this mod is configured to work only against other players in
multiplayer mode and against Simple Mobs [mobs] in singleplayer mode.

Default configuration can be customised by adding a shooter.conf file to
the mod's main directory, see shooter.conf.example for more details.

This is still very much a work in progress which I eventually plan to use
as the base for a 'Spades' style FPS game using the minetest engine.

Register a Weapon
-----------------
The API works with tools and items that represent a weapon, 
then you should register the weapon and another support items (like ammo).

### Methods
* `shooter.register_weapon(weapon_name, {Weapon Definitions})`: Register a weapon item
  `weapon_name` is the itemstring for a tool to be registered

Global Tables
-------------
* `shooter.registered_weapons`: Registered weapons by itemstring

Definition tables
-----------------

### Weapon Definitions (`shooter.register_weapon`)

    {
        description = "Rifle", -- Weapon description name
        
        inventory_image = "guns_rifle.png", -- Inventory imagem for the weapon item
        
        rounds = 100, --[[ Amount of shots 
            ^ Refilled only by the defined reload item ]]
        
        reload_item = "itemstring", --[[ Reload Item
            ^ If omitted, "shooter:ammo" is used ]]
        
        unloaded_item = { -- OPTIONAL | Item to be registered for unloaded weapon item
        	name = "itemstring", -- Itemstring to be registered
        	description = "Rifle (Unloaded)", -- Weapon description name
        	inventory_image = "guns_rifle_unloaded.png", -- Inventory imagem for the unloaded weapon item
        	not_in_creative_inventory = true, -- OPTIONAL | If true, does not display unloaded item in creative inventory
        },
        
        spec = { -- Weapon Aspects
        
            range = 200, -- Range (in blocks) of shot
            
            tool_caps = { -- Tool capabilities for registered item tool
            	full_punch_interval = 1.0,
            	damage_groups={fleshy=3}
            },
            
            groups = { -- Projectile destruction force 
            	snappy=3, 
            	crumbly=3, 
            	choppy=3, 
            	fleshy=2, 
            	oddly_breakable_by_hand=2
            },
            
            sounds = { -- Sound files
            	shot = "guns_rifle", -- When weapon shoots (if omitted, "guns_rifle" is used)
            	reload = "shooter_reload", -- When reload weapon (if omitted, "shooter_reload" is used)
            	fail_shot = "shooter_click", -- When the weapon fail by unloaded (if omitted, "shooter_click" is used)
            },
            
            particle = "shooter_bullet.png", -- Particle texture file name for projectile
        },
    }
