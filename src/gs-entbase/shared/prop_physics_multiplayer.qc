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

/*! \brief Shared-Entity: Physics Prop (Networked) */
/*!QUAKED prop_physics_multiplayer (1 0 0) (-16 -16 -16) (16 16 16) PRPPHYS_ASLEEP
# OVERVIEW
Physics prop that is optimised for netplay.
It either pushes the player away, or gets pushed away by the player.
The simulation can take place on either client or server.

# KEYS
- "targetname" : Name
- "physicsmode" : Which type of push/simulation model to use. See notes.

# NOTES
'physicsmode' can be one of three things:
    1. push player away
    2. get pushed (server-side)
    3. get pushed (client-side)

# TRIVIA
This entity was introduced in Half-Life 2 (2004).

@ingroup shared
@ingroup pointentity
*/
class prop_physics_multiplayer:NSPhysicsEntity
{
};
