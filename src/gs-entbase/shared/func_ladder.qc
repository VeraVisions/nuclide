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

/*!QUAKED func_ladder (0 .5 .8) ?
# OVERVIEW
Ladder volume. Climb up ladders with this one simple brush.

# KEYS
- "targetname" : Name

# TRIVIA
This entity was introduced in Half-Life (1998).
*/
class
func_ladder:NSRenderableEntity
{
public:
	void func_ladder(void);

	virtual void Respawn(void);

#ifdef SERVER
	virtual void Trigger(entity, triggermode_t);
#endif

};

#ifdef SERVER
void
func_ladder::Trigger(entity act, triggermode_t state)
{
	switch (state) {
	case TRIG_OFF:
		SetFrame(0);
		break;
	case TRIG_ON:
		SetFrame(1);
		break;
	default:
		SetFrame(1 - frame);
	}
}
#endif

void
func_ladder::Respawn(void)
{
	/* func_ladder specifics */
	SetMovetype(MOVETYPE_NONE);
	SetSolid(SOLID_BSP);
	SetSkin(CONTENT_LADDER);
	SetModel(GetSpawnModel());
	SetOrigin(GetSpawnOrigin());
	SetFrame(0);
	Hide();
}

void
func_ladder::func_ladder(void)
{
}
