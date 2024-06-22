# Modules {#modules}

## MapC Scripting

**Notice: This is an uncomitted document and is subject to change.**

Powered by the engine's multi-progs capability, maps can run their own isolated logic.
This is inspired by the original MapC effort by [Team Fortress Software/Valve](https://web.archive.org/web/19990221213004/http://www.teamfortress.com:80/tfii/mc2.html) that never got off the ground.

Ritual's ÜberTools for Quake III also had a scripting system for each map, this is comparable to that also. The same extends to the **GSC** scripts found in Call of Duty that each map has.

If you're curious about use-cases, you should make yourself familar with what those games do.

### MapC versus QuakeC

MapC is basically a superset of QuakeC.
You essentially write valid SSQC, but there's extra helper functions that you can use to communicate with entities from the server-side progs. Concepts that are alien to regular QuakeC code.

If a `mapscript.dat` is next to the map of the same name (`mapscript.bsp`), it will be included into the game.

An example source file from Nuclide's `base/test_maps.pk3dir/maps/mapscript.mapC`:

```cpp
#pragma PROGS_DAT  "mapscript.dat"

#include "../../../src/server/mapC.h"

void main()
{
	entity spawnPoint = spawnClass("info_player_start", [0, 0, 128]);
	spawnPoint.angles = [0, random(-180, 180), 0];
	spawnPoint.targetname = "SPSpawn";

	spawnPoint = spawnClass("info_player_deathmatch", [0, 0, 128]);
	spawnPoint.angles = [0, random(-180, 180), 0];
	spawnPoint.targetname = "MPSpawn";
}
```

Here you can see that while we stick to the `entity` base type, we do get to use a new function to spawn entities: `spawnclass(string className, desiredPosition)`.

This ensures that the server-side progs gets to load all available [EntityDef](EntityDef.md) based entities, as well as all internal, available, class-based entities - and sends those to our map-specific progs.

If you don't use spawnClass(), expect to not be able to use the I/O system with the entity.

To have access to all features, make sure to include `mapC.h` from Nuclide's `src/server` directory. That file will continously be updated to add more functionality.

You can compile the MapC file with fteqcc (`fteqcc mapscript.mapC`) to receive `mapscript.dat`.

Like with regular QuakeC progs, you only have to include the resulting .dat with your game - although we encourage you to release the sources to all progs for modders and tinkerers to enjoy. It's also a way for users to support the game themselves in case you're no longer able to support it.

### Use cases, benefits

When it comes to managing the complexity of events in games like the Call of Duty series, this is a desired substitute to hundreds (sometimes thousands) of entities.

Boxing the map-specific logic also aids portability. With less dependence on Nuclide or other internal functions to organize and schedule most of its logic, forward compatibility is easily achieved.

The design has been proven across dozens of games within the Call of Duty series, with little to no changes - serving for both single and multiplayer logic. Managing waves of enemies, or writing entire game-modes using this type of set-up has been proven.

### Extra features over Vanilla SSQC

These extra functions are available to MapC programs:

#### spawnClass(className, desiredPos)

Spawns the specified entity class name at the desired position. If the classname does not exist, it will return a new info_notnull type entity with no model or collision for you to modify.

#### sendInput(targetEntity, inputName, dataString, targetActivator)

Sends an input event to an NSEntity and with a specific activator. While that can be __NULL__, this, or world most of the time - some inputs very much depend on the activator being valid within their respective contexts.

### Map-specific entities

You can bundle an [EntityDef](EntityDef.md) file with your level, like with MapC progs they have to have the same filename as the map, but with the extension ending in '**def**' (e.g. `maps/mapscript.def`).

The entities within that EntityDef file will be exclusive to that map. No other map can spawn them. If you want to make an EntityDef available to all maps, move it into the `def/` directory of your game directory.
