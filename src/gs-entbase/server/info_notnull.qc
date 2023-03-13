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

/*!QUAKED info_notnull (0 0.5 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
Helper entity for the game-logic its vast array of entities.
It is most commonly used to aim active in-game entities towards a specific
location.

# KEYS
- "targetname" : Name

# NOTES
For tasks such as aiming static/lightmapped light sources during the compiling
process, please use info_null instead as it'll get removed after it has served
its purpose.

# TRIVIA
This entity was introduced in Quake (1996).
*/
class
info_notnull:NSPointTrigger
{
public:
	void info_notnull(void);
};

void
info_notnull::info_notnull(void)
{
}
