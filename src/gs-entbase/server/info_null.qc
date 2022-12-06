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

/*QUAKED info_null (1 0 0) (-8 -8 -8) (8 8 8)
Helper entity for the map creation process only.
It is supposed to be removed after compilation of a .bsp file.

-------- KEYS --------
"targetname" : Name

-------- NOTES --------
If you're pointing any active game-logic entities to this entity,
prepare to crash.

-------- TRIVIA --------
This entity was introduced in Quake (1996).
*/

class
info_null:NSPointTrigger
{
public:
	void info_null(void);
	
#ifdef DEBUG_INFONULL
	virtual void WarnDeveloper(void);
	virtual void Respawn(void);
#endif

};

void
info_null::info_null(void)
{
#ifndef DEBUG_INFONULL
	remove(self);
#endif
}

#ifdef DEBUG_INFONULL
void
info_null::WarnDeveloper(void)
{	
	if (!targetname)
		return;

	for (entity f = world; (f = find(f, ::target, targetname));) {
		NSEntity enty = (NSEntity)f;
		if (enty.identity)
		if (enty.target == targetname) {
			print(sprintf("^1info_null::WarnDeveloper^7: " \
			      "%s (%s) is targetting an info_null called %s\n",
			      enty.targetname, enty.classname, targetname));
		}
	}
}

void
info_null::Respawn(void)
{
	ScheduleThink(WarnDeveloper, 0.0f);
}
#endif
