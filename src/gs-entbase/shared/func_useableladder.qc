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
/*!QUAKED func_useableladder (0 .5 .8) ?
# OVERVIEW
Ladder volume. Climb up ladders with this one simple brush.

# KEYS
- "targetname" : Name

# TRIVIA
This entity was introduced in Half-Life 2 (2004).

@ingroup sharedentity
@ingroup brushentity
*/
class
func_useableladder:ncRenderableEntity
{
public:
	void func_useableladder(void);

	virtual void SpawnKey(string, string);
	virtual void Respawn(void);

#ifdef SERVER
	virtual void Trigger(entity, triggermode_t);
#endif

private:
	vector m_vecPoint0;
	vector m_vecPoint1;
};

void
func_useableladder::func_useableladder(void)
{
}

void
func_useableladder::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "point0":
		m_vecPoint0 = ReadVector(setValue);
		break;
	case "point1":
		m_vecPoint1 = ReadVector(setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
	}
}

#ifdef SERVER
void
func_useableladder::Trigger(entity act, triggermode_t state)
{
	switch (state) {
	case TRIG_OFF:
		SetSolid(SOLID_NOT);
		break;
	case TRIG_ON:
		SetSolid(SOLID_BBOX);
		break;
	default:
		m_bEnabled = 1 - m_bEnabled;
		SetSolid((m_bEnabled) ? SOLID_BBOX : SOLID_NOT);
	}
}
#endif

void
func_useableladder::Respawn(void)
{
	float height;

	if (m_vecPoint0[2] > m_vecPoint1[2]) {
		SetOrigin(m_vecPoint1);
		height = m_vecPoint0[2] - m_vecPoint1[2];
	} else {
		SetOrigin(m_vecPoint0);
		height = m_vecPoint1[2] - m_vecPoint0[2];
	}

	/* func_useableladder specifics */
	SetSize([-16,-16, 0], [16,16, height]);
	SetMovetype(MOVETYPE_NONE);
	Hide();
	SetSolid(SOLID_BBOX);
	SetSkin(CONTENT_LADDER);
}
