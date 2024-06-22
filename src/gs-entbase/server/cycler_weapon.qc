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

/*! \brief TODO: Server-Entity: Weapon Viewmodel Tester */
/*!QUAKED cycler_weapon (1 .5 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
A development entity. When picked up, will display the viewmodel on the activating player.

# KEYS
- "targetname" : Name
- "model" : Model to display on the player.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup server
@ingroup pointentity
*/
class
cycler_weapon:NSPointTrigger
{

};