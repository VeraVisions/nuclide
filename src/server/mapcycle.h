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

/** @defgroup mapcycle Mapcycle
    @brief Map cycle/rotation related APIs.
    @ingroup server

# Map Rotation (Cycle) System {#mapcycle}

The **MapCycle** system decides the next map to play on.

By default, we read from `<gamedir>/mapcycle.txt` a list of sorted levels, like this:

```
tw_grime
cs_duty
mp/pines
dw_woosh
```

If the map we're currently on is present, we will choose the map sorted after in the map cycle as the next map.

The server can forcefully change the map using the `nextmap` console command. Players can [vote for it instead](@ref voting).

If no valid mapcycle is present, it will keep restarting the map instead.

If the server starts with a map that is not present in the mapcycle, it will always pick the first entry in the list as the next level.

@{

*/

/** Can be called by the server game to override the current mapcycle with that of a custom mapcycle file. */
void Mapcycle_Load(string);

/** Called by Nuclide in `initents()`. */
void Mapcycle_Init(void);

/** @} */ // end of mapcycle
