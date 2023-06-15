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

/** Returns if the specified client is a NSClientSpectator, doesn't matter if real or fake */
bool Client_IsSpectator(NSClient);

/** Returns if we're a permanent NSClientSpectator, USE THIS if you want to access NSClientSpectator class attributes */
bool Client_IsRealSpectator(NSClient cl);

/** Returns if we're a fake NSClientSpectator, in case you need to be certain */
bool Client_IsFakeSpectator(NSClient cl);

/** Return if the specified client is dead. If they're a NSClientSpectator they're always alive. */
bool Client_IsDead(NSClient);

/** Returns if the specified client is a playable client class */
bool Client_IsPlayer(NSClient cl);

/** Are we in an intermission? (Match ending screen) */
bool Client_InIntermission(void);

/** Returns the name of the key that a given command is bound to.

@param strBind the command in question. E.g. "+forward" */
string Util_GetKeyString(string strBind);

/** Returns if the currently active client-seat is in a vehicle. */
bool Client_InVehicle(void);

string Util_GetTime(void);
float Util_GetTimeLeft(void);
string Util_GetAddress(void);