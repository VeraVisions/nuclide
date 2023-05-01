# EntityDef

## Overview

In **id Tech 4**, we have been introduced to external entity definitions. They are pretty straightforward by merely being a set of default values for an existing entity class.

This can be used in a variety of ways.

- Create new entity classes with new behaviour without any code
- Create a base class that other entityDefs can inherit from
- Create prefabs that get updated across all maps

This system can also be used in combination with [MapTweaks](Documentation/MapTweaks.md), where an entityDef is used instead of a base class depending on the parameters you decide to test.

## Syntax

Let's take a look at an example **EntityDef**:

```
entityDef item_health_small {
	"spawnclass" "item_health"
	"spawnflags" "1"
}
```

This is from the port of *Deathmatch Classic*, and will ensure that **item_health_small** from *Quake III Arena* gets spawned as an **item_health** with its *spawnflags* set to the one that will make it a small health pickup.

You can have as many key/value pairs as you like. However, you can only specify one *spawnclass* and you cannot do circular inheritance.

## Special Keys

These are reserved keys and are meant to be used by the **build_game.sh** script to generate an entities.def file for your game.

| Key                | Description                                                            |
|--------------------|------------------------------------------------------------------------|
| editor_usage       | Description text used by the editor.                                   |
| editor_model       | Model to use in the editor.                                            |
| editor_var **KEY** | Description text for the specified key.                                |
| editor_color       | Normalized color vector defining the bounding box color in the editor. |
| editor_mins        | Vector defining the mins of the entity bounding box.                   |
| editor_maxs        | Vector defining the maxs of the entity bounding box.                   |

# References

- [id.sdk  page on Entity Defs](http://icculus.org/~marco/notmine/id-dev/www.iddevnet.com/doom3/entitydefs.html)