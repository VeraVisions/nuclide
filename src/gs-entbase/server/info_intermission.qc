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

/*! \brief Server-Entity: Intermission Camera */
/*!QUAKED info_intermission (1 0 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
An entity that's used to create an 'Intermission' camera.

# KEYS
- "targetname" : Name

# NOTES
Some mods use this while displaying the final scores, once a timelimit
is hit etc.

When Intermission is active, the players camera will be teleported here
and angles towards the aim target.

# TRIVIA
This entity was introduced in Quake (1996).

@ingroup serverentity
@ingroup pointentity
*/
class
info_intermission:ncPointTrigger
{
public:
	void info_intermission(void);
};

void
info_intermission::info_intermission(void)
{
}
