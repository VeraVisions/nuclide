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

/*! \brief Server-Entity: Brush Model That Changes Texture */
/*!QUAKED func_wall (0 .5 .8) ?
# OVERVIEW
Brush that lets light to pass through it.

# KEYS
- "targetname" : Name

# NOTES
On idTech 2 BSPs, it will change texture variants when triggered.

# TRIVIA
This entity was introduced in Quake (1996).

@ingroup server
@ingroup brushentity
*/

#ifdef SERVER
class
func_wall:ncRenderableEntity
{
public:
	void func_wall(void);

	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);
};

void
func_wall::func_wall(void)
{

}

void
func_wall::Trigger(entity act, triggermode_t state)
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

void
func_wall::Respawn(void)
{
	/* reset the visual parameters */
	super::Respawn();

	/* func_wall specifics */
	SetMovetype(MOVETYPE_PUSH);
	SetSolid(SOLID_BSP);
	SetFrame(0);
	ClearAngles();
}
#endif

/* temporary */
CLASSEXPORT(func_reflective_glass, func_wall)