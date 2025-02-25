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

/** @defgroup clientutils Utilities
    @brief Client Utility API Reference
    @ingroup client

    @{

 */

/** Returns if the specified client is a ncSpectator, doesn't matter if real or fake */
bool Client_IsSpectator(ncPlayer);

/** Returns if we're a permanent ncSpectator, USE THIS if you want to access ncSpectator class attributes */
bool Client_IsRealSpectator(ncClient cl);

/** Returns if we're a fake ncSpectator, in case you need to be certain */
bool Client_IsFakeSpectator(ncClient cl);

/** Return if the specified client is dead. If they're a ncSpectator they're always alive. */
bool Client_IsDead(ncClient);

/** Returns if the specified client is a playable client class */
bool Client_IsPlayer(ncClient cl);

/** Are we in an intermission? (Match ending screen) */
bool Client_InIntermission(void);

/** Returns the name of the key that a given command is bound to.

@param strBind the command in question. E.g. "+forward" */
string Util_GetKeyString(string strBind);

/** Returns if the currently active client-seat is in a vehicle. */
bool Client_InVehicle(void);

/** @} */ // end of client
