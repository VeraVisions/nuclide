# System Classes

For extendability and memory reasons, Nuclide consists of a lot of classes that carry most of
the work. They are generally prefixed **NS** (**Nuclide System**) so you can immediately tell
if they're an internal component of Nuclide, or if it is part of something else.

You create the game by overriding the parts of Nuclide that you want to customize.
Want your player to move twice as fast? Then peek into the physics methods of NSClientPlayer
and override the virtual method responsible for that. That's how things generally work around here.

Try to avoid using private APIs. Things can and will break.
If you desire additional functionality please reach out.

## Entity Classes

These are the entity classes that you're generally encouraged to inherit to create your game:

### General purpose
Most map entities will be based off one of these. The difference can be felt in memory usage, networking and rendering speed. So if you wanted only basic entity logic without any fancy rendering or concept of hit detection an NSEntity may be enough.
However, if you want advanced rendering features, such as adjustable color, transparency and various other special effects you might want to start off with the NSRenderableEntity class as the basis for your entity.

- NSEntity
- NSRenderableEntity
- NSSurfacePropEntity
- NSPhysicsEntity

### Trigger templates
These are templates for the two trigger types we currently support.
Check their respective Init methods to initialize them properly.

- NSBrushTrigger
- NSPointTrigger

### NPCs/Monster/AI
Currently there's two types of monsters. The primitive ones that may move around and the more advanced talking ones.
- NSMonster
- NSTalkMonster

## Game-logic classes

Anything that doesn't specifically have to do with entities.

### Clients/Players
You are generally expected to implement a class named `player` in your game.
In most cases you will just want to inherit NSClientPlayer for that class.

- NSClientPlayer

### Rules
Depending on the gamemode set by you in the server's Game_InitRules function, it should spawn a variant of NSGameRules and set the global `g_grMode` reference to that class you've initialized.

- NSGameRules

### Inventory
This needs to be completed.
- NSWeapon (incomplete)

### World Materials
This needs to be completed.
- NSMaterial (incomplete)