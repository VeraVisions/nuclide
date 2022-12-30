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

/* Emscripten builds and mods? Forgetaboutit! */
#ifndef WEBMENU

/** uri_get callback id for mod-list retrieval */
#define MODSERVER_REQ_LIST 100
/** uri_get callback id for mod-item retrieval */
#define MODSERVER_REQ_ITEM 101
/** uri_get callback id for mod package name retrieval */
#define MODSERVER_REQ_PKGNAMES 102

#define ModServer_URI_Callback URI_Get_Callback

var int g_iModServerLoading;
var int g_iModServerReqCount;

int game_getpackageid(string pkgname);

/** Call this to initiate a lengthy process of updating the list of mods
we can install in the custom game menu. */
void ModServer_Refresh(void);

/** Function that interprets a mod-list.
ModServer_URI_Callback calls this when retrieving a MODSERVER_REQ_ITEM description.
Will in return call uri_get with code MODSERVER_REQ_ITEM on every game dir we don't
have installed locally. Thus filling the mod list with entries we can install.

@param data White-space separated list of unique mod game directory names. */
void ModServer_ParseList(string data);

/** Function that interprets a mod-item entry.
ModServer_URI_Callback calls this when retrieving a MODSERVER_REQ_ITEM description.
We then allocate a new mod entry in our mod-list and fill it with the data supplied.

@param data The data string that will fill up a newly allocated entry. */
void ModServer_ParseItem(string data);

/** Called as an eventual result of the uri_get builtin. */
void ModServer_URI_Callback(float id, float code, string data, int resourcebytes);
#endif
