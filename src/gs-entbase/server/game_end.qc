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

/*!QUAKED game_end (1 .5 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
Upon being triggered, the intermission secret will commence in multiplayer games.

# KEYS
- "targetname" : Name
- "master" : Name of the multisource regulating its usage.

# TRIVIA
This entity was introduced in Half-Life (1998).
*/
class
game_end:NSEntity
{
public:
	void game_end(void);

	virtual void Trigger(entity, triggermode_t);
};

void
game_end::game_end(void)
{
}

void
game_end::Trigger(entity activatingEntity, triggermode_t triggerMode)
{
	if (GetMaster(activatingEntity) == FALSE) {
		return;
	}

	g_grMode.IntermissionStart();
}