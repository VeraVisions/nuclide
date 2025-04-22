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

/*! \brief Server-Entity: Decorative Animated Entity */
/*!QUAKED item_generic (1 0 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
A 'generic' decorative entity which uses an animation sequence.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "killtarget" : Target to kill when triggered.
- "sequencename" : Animation sequence to play, by name.
- "body" : Which bodygroup to use.
- "skin" : Which skin to use.

# TRIVIA
This entity was introduced in Half-Life: Opposing Force (1999).

@ingroup serverentity
@ingroup pointentity
*/
class
item_generic:ncRenderableEntity
{
public:
	void item_generic(void);

	virtual void Respawn(void);
	virtual void SpawnKey(string, string);
	virtual void Save(float);
	virtual void Restore(string, string);

private:
	string m_strSequenceName;
};

void
item_generic::item_generic(void)
{
	m_strSequenceName = "";
}

void
item_generic::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "m_strSequenceName", m_strSequenceName);
}

void
item_generic::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_strSequenceName":
		m_strSequenceName = ReadString(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
item_generic::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "sequencename":
		m_strSequenceName = setValue;
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
item_generic::Respawn(void)
{
	super::Respawn();

	SetSize([0,0,0], [0,0,0]);
	SetSolid(SOLID_NOT);
	SetMovetype(MOVETYPE_NONE);

	if (m_strSequenceName) {
		SetFrame(frameforname(GetModelindex(), m_strSequenceName));
	}
}