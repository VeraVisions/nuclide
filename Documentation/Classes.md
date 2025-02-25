# System Classes

For extendability and memory reasons, Nuclide consists of a lot of classes that carry most of
the work. They are generally prefixed **NS** (**Nuclide System**) so you can immediately tell
if they're an internal component of Nuclide, or if it is part of something else.

You create the game by overriding the parts of Nuclide that you want to customize.
Want your player to move twice as fast? Then peek into the physics methods of ncPlayer
and override the virtual method responsible for that. That's how things generally work around here.

Try to avoid using private APIs. Things can and will break.
If you desire additional functionality please reach out.

## Entity Classes

These are the entity classes that you're generally encouraged to inherit to create your game:

### General purpose

Most map entities will be based off one of these. The difference can be felt in memory usage, networking and rendering speed. So if you wanted only basic entity logic without any fancy rendering or concept of hit detection an ncEntity may be enough.
However, if you want advanced rendering features, such as adjustable color, transparency and various other special effects you might want to start off with the ncRenderableEntity class as the basis for your entity.

- ncEntity
- ncRenderableEntity
- ncSurfacePropEntity
- ncPhysicsEntity

### Trigger templates

These are templates for the two trigger types we currently support.
Check their respective Init methods to initialize them properly.

- ncBrushTrigger
- ncPointTrigger

### NPCs/Monster/AI

Currently there's two types of monsters. The primitive ones that may move around and the more advanced talking ones.

- ncMonster
- ncTalkMonster

## Game-logic classes

Anything that doesn't specifically have to do with entities.

### Clients/Players

You are generally expected to implement a class named `player` in your game using [decl](@ref decl).
In most cases you will just want to specify the `spawnclass` as being ncPlayer for that decl.

- ncPlayer

### Rules

Depending on the gamemode set by you in the server's Game_InitRules function or value of `g_gametype` cvar, it should spawn a variant of ncGameRules and set the global `g_grMode` reference to that class you've initialized.

- ncGameRules

### Inventory

The inventory is fully object oriented. The base inventory item classes consist of:

- ncItem
- ncWeapon

ncItem are *dormant* objects. They usually stay in the inventory without being able to select them, unless they're instant pick-ups like *Quake-style* health or ammo boxes.
