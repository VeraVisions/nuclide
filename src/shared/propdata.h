/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/

/** @defgroup propdata Prop Data
    @brief Moving, interactive object properties.
    @ingroup shared

## Prop data {#propdata}

The prop data system was introduced in **Source Engine
2004**, it's been integrated into Nuclide and supported in a few different ways.

## Overview {#propdata_overview}

It allows you to easily create, without any programming knowledge,
breakable props and entities.

That way, when you place prop_dynamic
entities into the world for example, they will all have the same
material, health and behavior when being interacted with.

Other entities, such as func_breakable can
also take advantage of them.

## Specs {#propdata_specs}

According to Source SDK's propdata.txt we've got
a kinda sorta hacky definition table for this stuff:

```
"PropData.txt"
	{

	"sometype"
	{
		// .. key/field attributes
		// e.g.
		"health" "10"
		"breakable_model" "somematerial"
	}

	"BreakableModels"
	{
		// completely unrelated to types defined in propdata.txt
		// but somehow still part of it?

		"somematerial"
		{
			// model path / fadeout time pair
			// e.g.
			"foo.vvm" "2.5"

			// but I also added
			"foo.mdl#submodels=9" "5.0"
			// where the # symbol notes that >9< submodels of the first
			// submodel group will be chosen at random to represent 1 unit
			// of the breakmodel collective
		}
	}
}
```

The idea is that props specify the type of prop they are ("sometype") and it defines
a set of sensible defaults.

However, props can override any parts of this inside the model data itself.
Currently no model format FTEQW supports allows for reading of said propdata.
However we'll be loading "foobar.vvm.propdata" to remedy this for those.

## Usage {#propdata_usage}

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

## Commands {#propdata_commands}

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
-   **surfaceprop <string>**: Surfaceprop override for the object.

## Physics Object Commands {#propdata_physcommands}

These are only relevant for when you want to use a phyics object, or rather an object that's handled by NSPhysicsEntity, such as prop_physics.

-   **mass <float>**: Mass of the object, in kilograms.
-   **volume <float>**: Volume of the object, in cubic meters.
-   **inertia <float>**: Inertia multiplier.
-   **damping <float>**: Linear movement damping multiplier.
-   **rotdamping <float>**: Angular movement damping multiplier.

@{

*/

var string g_curPropData;

typedef enumflags
{
	PDFL_BLOCKLOS,		/* Does this block an AIs light of sight? */
	PDFL_AIWALKABLE,	/* can AI walk on this? */
	PDFL_ALLOWSTATIC	/* static simulation possible? */
} propdataFlag_t;

/** Data holding PropData entries. */
typedef struct
{
	string name;
	string base;
	float health;		/* health until break */
	propdataFlag_t flags;
	float damage_bullets;	/* dmg multipliers */
	float damage_melee;
	float damage_explosive;
	float explosive_damage;	/* once the damage/radius keys are set, make explosion upon break */
	float explosive_radius;
	string breakable_particle;	/* name of BreakableModels entry in PropData.txt */
	string breakable_model;	/* name of BreakableModels entry in PropData.txt */
	int breakable_count;
	float breakable_skin;
	float mass;
	float damping_linear;
	float damping_angular;
	float inertia;
	float volume;
	string surfaceprop;
} propdata_t;

/* entity will have to have a .propdata field pointing to a propdata id */
propdata_t *g_propdata;
int g_propdata_count;
var hashtable g_hashpropdata;

/* necessary API functions */
void PropData_Init(void);
void PropData_Shutdown(void);

int PropData_Load(string);	/* called when we read entity data, returns -1 when not found */
int PropData_ForModel(string);	/* called when we set a model, returns -1 when not found */
//int PropData_Read(string);	/* this just handles the contents of a prop_data model string */

void PropData_SetStage(string);
int PropData_Finish(void);

/* querying API */
typedef enum
{
	PROPINFO_HEALTH,
	PROPINFO_FLAGS,
	PROPINFO_DMG_BULLET,
	PROPINFO_DMG_MELEE,
	PROPINFO_DMG_EXPLOSIVE,
	PROPINFO_EXPLOSIVE_DMG,
	PROPINFO_EXPLOSIVE_RADIUS,
	PROPINFO_BREAKMODEL,
	PROPINFO_BREAKCOUNT,
	PROPINFO_SKIN,
	/* physics related variables. */
	PROPINFO_MASS,
	PROPINFO_DAMPING_LINEAR,
	PROPINFO_DAMPING_ANGULAR,
	PROPINFO_INERTIA,
	PROPINFO_VOLUME,
	PROPINFO_SURFACEPROP
} propinfo_t;
__variant Prop_GetInfo(int, int);

/** Data holding BreakModel entries. */
typedef struct
{
	string name;
	string data;
	float modelindex; /* only used for networking */
	bool physics; /* differentiate between Source and GS */
} breakModel_t;

/* entity will have a .breakmodel field pointing to a breakmodel id */
breakModel_t *g_breakmodel;
int g_breakmodel_count;
int g_breakmodel_end;
var hashtable g_hashbreakmodel;


#ifdef CLIENT
void BreakModel_SpawnID(vector smins, vector smaxs, vector dir, float speed, int count, int index);
void BreakModel_Receive(void);
void BreakModel_ReceiveClientData(void);
#else
void BreakModel_Spawn(vector pos, vector dir, vector spread, float speed, int count, string type);
void BreakModel_Entity(NSSurfacePropEntity target, vector dir, float speed);
void BreakModel_SendClientData(entity);
#endif


/** @} */ // end of propdata

/* necessary API functions */
//void BreakModel_Init(void);
//void BreakModel_Shutdown(void);

//int BreakModel_Load(string);	/* called when we precache a model, returns -1 when not found */
//int BreakModel_Read(string);	/* this just handles the contents of a prop_data model string */
