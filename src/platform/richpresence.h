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

/**
@defgroup richpresence Rich Presence
@ingroup menu
@brief Sharing of game state/info for social purposes.

This is the internal rich presence handler.
Rich presence is when the platform outside of the game communicates
to other users what game it is we are playing and how to connect to it.

An example would be a friends-list where you see that a player
is in game "Example Game" playing a multiplayer game on "Example map".

In addition it will expose a way for the game to supply a connect
command to the command-line, so that those players can join via the
platform interface.

The console command `richpresence_dump` will output the current set
of key/value pairs that will be shared with the platform.

@{
*/

/** Sets a rich-presence key to the desired value.
You keys currently available are: "status", "connect"

Setting the "status" key is meant to be visible to other
players on the platform/network you're playing on.
This may show up to other people on your friends-list, or some equivalent.

Meanwhile the "connect" key should have the address of
a game servers others players can reach you under. */
void RichPresence_Set(string strKey, string strValue);

/** Clears the current rich-presence status. */
void RichPresence_Clear(void);

/** Returns if we've got an active rich-presence status. */
bool RichPresence_WasSet(void);

/** Debug function that prints the currently active rich-presence keys to console. */
void RichPresence_DumpInfo(void);

/** @} */ // end of richpresence
