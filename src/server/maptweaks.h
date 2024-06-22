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

/** @defgroup maptweaks MapTweaks
    @brief Conditional map entity overrides.
    @ingroup server

# MapTweaks {#maptweaks}

## Overview {#maptweaks_overview}

This is a very customizable system that applies changes to levels/maps depending on a variable amount of parameters. It was invented specifically for Nuclide and designed to work together with [EntityDefs](Documentation/EntityDef.md).

## Syntax {#maptweaks_syntax}

All MapTweaks are defined within `scripts/maptweaks.txt`.

Let's take a look at an example **MapTweak**:

```
hldm_tweak
{
	when-cvar deathmatch equals 2
	when-serverinfo *bspversion equals 30

	replace weapon_gauss info_null
	replace weapon_egon info_null
}
```

The `hldm_tweaks` is just a user-defined name. It doesn't affect functionality.

The `when-cvar` and `when-serverinfo` lines are **checks**. each one is checked individually and only if all are positive will the `replace` lines take effect.

You can have as many lines in there as you like.

Other than `equals`, you can also use one of the following keywords when comparing values:

- **less-than**
- **greater-than**
- **is-not**

At this time, `when-cvar` and `when-serverinfo` only do comparisons on numbers. So you cannot check for strings at this time.

@{
*/

/** Data holding MapTweak entries. */
typedef struct
{
	string cvarCheck;
	string serverinfoCheck;
	string itemTable;
} mapTweak_t;

/** Called upon server init, after all [EntityDef](@ref entitydef) have been initialized. */
void MapTweaks_Init(void);

/** Will take an existing entity, and apply the currently valid map tweaks to it. */
bool MapTweak_EntitySpawn(entity);

/** @} */ // end of maptweaks