/*
 * Copyright (c) 2023 Vera Visions LLC.
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

/**
@defgroup maplibrary Map Library
@brief Locally installed maps/levels control functions
@ingroup menu

Menus need to be aware of what levels aka maps are available for modes like
multiplayer. The MapLibrary is by configured to only parse levels from the
current game directory (much like GoldSrc) and optionally can blacklist
maps based on a variety of criteria which may be configurable at some point
in time.

The menu needs to call MapLibrary_Init() at least once, after which you can
query the total amount of maps that are available via MapLibrary_GetMapCount().

You can then iterate over the individual entries with MapLibrary_GetInfo().

@{
*/

/** Options querying Map Library entries using `MapLibrary_GetInfo()`. */
typedef enum
{
	MAPINFO_NAME,		/**< (string) Name of the map. E.g. e1m1 */
	MAPINFO_TITLE,		/**< (string) Title of the map. E.g. "Abyss of Cake" */
	MAPINFO_AUTHOR,		/**< (string) Author of the map. E.g. "John Doe" */
	MAPINFO_TYPE,		/**< (string) Type of map.*/
	MAPINFO_PREVIEW		/**< (string) URL to a preview of the map. __NULL__ if not available. Will look for level previews inside levelshots/ and maps/ with any file extensions supported by the engine and whitelisted within the cvar 'r_imageextensions'.*/
} mapType_t;

/** Data holding Map Library entries. */
typedef struct
{
	string name;
	string title;
	string author;
	string type;
	string preview;
} mapLibrary_t;

/** Initialize the map library, MapLibrary_GetMapCount() will return the amount of maps available. */
void MapLibrary_Init(void);

/** Returns the total amount of maps available. */
int MapLibrary_GetMapCount(void);

/** Retrieve information about a given mapID. See mapType_t for which fields you can query. */
__variant MapLibrary_GetInfo(int, mapType_t);

/** @} */ // end of maplibrary
