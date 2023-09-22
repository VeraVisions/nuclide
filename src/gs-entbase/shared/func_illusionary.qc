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

/*!QUAKED func_illusionary (0 .5 .8) ?
# OVERVIEW
Brush that lets light to pass through it and is non-solid.

# KEYS
- "targetname" : Name

# NOTES
On idTech 2 BSPs, it will change texture variants when triggered.

# TRIVIA
This entity was introduced in Quake (1996).
*/
#ifdef SERVER
class
func_illusionary:NSRenderableEntity
{
public:
	void func_illusionary(void);

	virtual void Respawn(void);
	virtual void Trigger(entity, triggermode_t);
};

void
func_illusionary::func_illusionary(void)
{
}

void
func_illusionary::Trigger(entity act, triggermode_t state)
{
	switch (state) {
	case TRIG_OFF:
		SetSkin(0);
		break;
	case TRIG_ON:
		SetSkin(1);
		break;
	default:
		SetSkin(1-skin);
	}
}

void
func_illusionary::Respawn(void)
{
	/* reset the visual parameters */
	super::Respawn();

	/* func_illusionary specifics */
	SetMovetype(MOVETYPE_NONE);
	SetSolid(SOLID_NOT);
	SetModel(GetSpawnModel());
	SetOrigin(GetSpawnOrigin());
	SetSkin(0);
	ClearAngles();

	// TODO: Add support for (skin) -1 = Empty, -7 = Volumetric light
	if (GetSkin() < 0) {
		SetSkin(0);
	}
}
#endif
