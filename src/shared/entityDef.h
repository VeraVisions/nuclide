/*
 * Copyright (c) 2023-2024 Vera Visions LLC.
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

/** @defgroup entitydef Entity Definitions
@brief Entity class declaration system.
@ingroup shared
@ingroup entities
@ingroup decl

# Introduction

An 'entityDef' is a type of @ref decl containing spawn
data. It is used for prefab entity configurations
but is also the very definitions base for designing
actors, items and weapons.

These definitions are a further abstraction from how we view
entity definitions. this system tries to be mostly compatible
with the def system in id Tech 4 [1] (Doom 3, Quake 4, Prey, etc.)
but does not guarantee to be compatible as-is.

The first references to such a system existing can be found when
Team Fortress Software was working on Team Fortress 2, 
originally on Quake II's engine. [2]

The gist is, that an entity def can set a base spawnclass (e.g. func_door)
and populate it with key/value pairs.

# Overview

Using this example definition, we can re-invent func_illusionary using an already existing entity class (func_wall) and making it non-solid:

```
entityDef func_illusionary {
	"spawnclass" "func_wall"
	"solid" "0"
}
```

We also have features exclusive to our entityDef format. In the following example, you can change the `body` key equals `1`, the switch will `skin` to id `4`. You can as many conditions as you like.

```
entityDef foobar {
	[...]

	when "body" equals 1 {
		"skin" "4"
	}
}
```

Will allow developers to configure other fields when certain
conditions are met.

This is also expanded to include model event callbacks to the tried
and true I/O system:

```
entityDef foobar {
	[...]

	events {
		1004 "SpawnDef" "foobar_projectile"
	}
}
```

# See Also

- [1] http://www.teamfortress.com/tfii/mc2mapc.html
- [2] http://icculus.org/~marco/notmine/id-dev/www.iddevnet.com/doom3/entitydefs.html

@{

*/

#ifndef ENTITYDEF_MAX
/** Can be redefined in the server its progs.src file. */
#define ENTITYDEF_MAX 256
#endif

/** Options for EntityDef checks. */
enum
{
	EDEFTWEAK_EQ = 0, /**< Equals Check */
	EDEFTWEAK_LT, /**< Less-Than Check */
	EDEFTWEAK_GT, /**< Greater-Than Check */
	EDEFTWEAK_NOT, /**< Not (Invert) Gate */
	EDEFTWEAK_CONTAINS /**< Contains Bit (&) Check */
};

/** Data holding EntityDef entries. */
typedef struct
{
	string entClass;
	string spawnClass;
	string spawnData;
	string inheritKeys;

	string tweakDefs; /* when (field) equals/greater-than/less-than/is-not (value) */
	string tweakKeys;

	string eventList; /* model events */
	int inheritID;
} entityDef_t;

void EntityDef_Init(void);
void EntityDef_DebugList(void);
string EntityDef_GetKeyValue(string, string);

int EntityDef_IDFromName(string);
string EntityDef_NameFromID(int);
string EntityDef_GetSpawnData(int);
bool EntityDef_HasSpawnClass(string className);

#ifdef SERVER
bool EntityDef_Precache(string);
NSEntity Entity_CreateClass(string className);
#endif

/** @} */ // end of entitydef
