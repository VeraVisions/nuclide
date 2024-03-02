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

/*! @file cloader.h
    @brief Constants macro loader

Scripters and level designers are able to define parameters through the use
of name-based lookups, so they can change them later in one convenient place.

In the game directory, they are defined within `scripts/constants.txt`.
An example file looks like this:

```
// weapon constants
WEAPON_NONE 0
WEAPON_KNIFE 1
WEAPON_POTATO 2
```

Within [EntityDefs](Documentation/EntityDef.md) files, you will then be able to set a given key to the value
of one of the defined constants by prefixing the name with a `$` symbol.
That would look something like this:

```
"weapon" "$WEAPON_POTATO"
```

The same applies to data read within level files and most routines related to parsing key/value pairs, so it is not limited to usage within EntityDef.
*/

/** Called upon game init internally to populate our look-up table.
*/
void Constants_Init(void);

/** Look up a name and retrieve its value.

@param constName Name of the constant to look up.
@param returnValue The value to return if constName is not defined.
@return The value of the named constant. Will return returnValue if it does not exist. */
string Constants_LookUp(string constName, string returnValue);

var hashtable g_hashConstants;
