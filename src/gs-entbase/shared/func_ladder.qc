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

/*! \brief Shared-Entity: Ladder Volume */
/*!QUAKED func_ladder (0 .5 .8) ?
# OVERVIEW
Ladder volume. Climb up ladders with this one simple brush.

# KEYS
- "targetname" : Name

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup sharedentity
@ingroup brushentity
*/
class
func_ladder:ncRenderableEntity
{
public:
	void func_ladder(void);

	virtual void Respawn(void);

#ifdef SERVER
	virtual void Trigger(entity, triggermode_t);
#endif

private:
	entity m_collisionEntity;
};

void
func_ladder::func_ladder(void)
{
	m_collisionEntity = __NULL__;
}

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
	super::Respawn();

	/* func_ladder volumes are solid. CONTENT_LADDER volumes usually aren't. */
	if (!m_collisionEntity && STRING_SET(model)) {
		m_collisionEntity = spawn();
		m_collisionEntity.solid = SOLID_BSP;
		setmodel(m_collisionEntity, model);
		setorigin(m_collisionEntity, origin);
		m_collisionEntity.effects = EF_NODRAW;
	}

	SetMovetype(MOVETYPE_NONE);
	SetFrame(0);
	Hide();
	SetSolid(SOLID_BSP);
	SetSkin(CONTENT_LADDER);
}
