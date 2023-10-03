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

/*!QUAKED infodecal (1 0 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
Projects a decals.wad texture onto the nearest surface.
It'll automatically figure out the surface based on distance.
The texture will be aligned along the surface texture normals.

# KEYS
- "targetname" : Name
- "texture" : Name of the texture inside decals.wad it projects onto a surface.

# NOTES
This entity currently only works on BSP version 30 levels.

If a targetname is supplied, it will have to be triggered by an entity in order
to appear. Afterwards it cannot be triggered again.

It will pick the nearest wall (currently checking a distance of 128 units,
which is probably overkill). No angle has to be supplied.

# TRIVIA
This entity was introduced in Half-Life (1998).
*/
class
infodecal:NSPointTrigger
{
public:
	void infodecal(void);
	
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Respawn(void);
	virtual void Spawned(void);
	virtual void Trigger(entity, triggermode_t);

private:
	decal m_decChild;
	string m_strTexture;
};

void
infodecal::infodecal(void)
{
	m_decChild = __NULL__;
	m_strTexture = __NULL__;
}

void
infodecal::Save(float handle)
{
	super::Save(handle);
	SaveEntity(handle, "m_decChild", m_decChild);
	SaveString(handle, "m_strTexture", m_strTexture);
}

void
infodecal::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_decChild":
		m_decChild = (decal)ReadEntity(strValue);
		break;
	case "m_strTexture":
		m_strTexture = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
infodecal::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "material":
		m_strTexture = strValue;
		break;
	case "texture":
		m_strTexture = strtolower(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
infodecal::Spawned(void)
{
	float bsp_version = serverkeyfloat("*bspversion");

	switch (bsp_version) {
	case BSPVER_HL:
	case BSPVER_RBSP:
	case BSPVER_Q3:
	case BSPVER_RTCW:
		break;
	default:
		Destroy();
		return;
	}
}

void
infodecal::Respawn(void)
{
	/* this will be invisible by default */
	if (!targetname) {
#if 0
		/* spawn automatically, remove self */
		Trigger(this, TRIG_ON);
#else
		Destroy();
#endif
	} else {
		Trigger(this, TRIG_OFF);
		m_decChild = __NULL__;
	}
}

void
infodecal::Trigger(entity act, triggermode_t state)
{
	switch (state) {
	case TRIG_OFF:
		if (m_decChild) {
			remove(m_decChild);
			m_decChild = __NULL__;
		}
		break;
	case TRIG_ON:
		if (!m_decChild) {
			m_decChild = spawn(decal);
			m_decChild.Place(origin, m_strTexture);
		}
		break;
	default:
		Trigger(act, (m_decChild == __NULL__) ? TRIG_ON : TRIG_OFF);
	}
}
