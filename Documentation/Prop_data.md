# Prop data

The prop data system was introduced in **Source Engine
2004**, it's been integrated into Nuclide and supported in a few different ways.

## Overview {#overview}

It allows you to easily create, without any programming knowledge,
breakable props and entities.

That way, when you place prop_dynamic
entities into the world for example, they will all have the same
material, health and behavior when being interacted with.

Other entities, such as func_breakable can
also take advantage of them.

## Specs {#specs}

A global propdata definition file can be found at `scripts/propdata.txt`
and it contains structures for types and a separate section titled
**BreakableModels**. You can ignore the latter for now.

An example propdata.txt looks like this:

```
 "PropData.txt"
 {
 
   "sometype"
   {
     // .. key/field attributes
     // e.g.
     "health" "10"
     "breakable_model" "somematerial"
   }
 
   "BreakableModels"
   {
     // completely unrelated to types defined in propdata.txt
     // but somehow still part of it?
 
     "somematerial"
     {
       // model path / fadeout time pair
       // e.g.
       "foo.vvm" "2.5"
     }
   }
 }
```

The idea is that props specify the type of prop they are ("sometype")
and it defines a set of sensible defaults.

However, props can override any parts of this inside the model data
itself. Currently no model format FTEQW supports allows for reading of
said propdata. However we'll be loading "foobar.vvm.propdata" to remedy
this for those.

## Usage {#usage}

Any entity in Nuclide that inherits NSSurfacePropEntity can take advantage
of the propdata features.

Either the entity inside the map defines which propdata definition it
wants to use (via the .propdata string field), or the model file has a
text definition alongside as mentioned above.

### Map entity key {#map_entity_key}

An example for the example specification listed above would be a
propdata key/value pair as part of the entity definition:

```
 {
   "classname" "func_wall"
   "model"     "*42"
   "propdata"  "sometype"
 }
```

### Model propdata definition {#model_propdata_definition}

If you had a model, e.g. located at `models/foobar.vvm` then if you were
to place a file named `models/foobar.vvm.propdata` alongside it with the
following contents:

```
 PropData.txt
 {
   prop_data
   {
     "health" "30"
     "breakable_model" "somematerial"
     "breakable_count" "10"
   }
 }
```

This registers an internal propdata definition with the name
**models/foobar.vvm.propdata** that would correspond to the above
contents. You have to absolutely make sure that the model's .propdata
file calls the data structure **prop_data** however, like described
above.

You don't have to do anything else in the entity, the prop model will
now have health of 30 and break into 'somematerial' upon its
destruction.

## Commands {#commands}

-   **base <string>**: Which propdata fields to inherit.
-   **blockLOS <bool>**: Will this prop break the line-of-sight of NPCs?
-   **AIWalkable <bool>**: Can AI walk over this?
-   **allow_static <bool>**: Will static props use this definition?
-   **dmg.bullets <float>**: Damage multiplier for bullets.
-   **dmg.club <float>**: Damage multiplier for melee weapons.
-   **dmg.explosive <float>**: Damage multiplier for explosive weapons.
-   **health <int>**: Absolute amount of health on spawn.
-   **explosive_damage <int>**: Makes the entity explosive, with <int>
    specifying the max amount of damage.
-   **explosive_radius <float>**: Sets the explosion radius in q units.
    Is 2.5 times the damage by default.
-   **breakable_particle <string>**: Which particle effect to play when
    this entity breaks.
-   **breakable_model <string>**: Which models to spawn when it breaks.
-   **breakable_count <int>**: The amount of models it'll spawn upon
    breaking.