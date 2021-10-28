/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

class CBaseMomentary:NSRenderableEntity
{
	entity m_eUser;
	vector m_vecMoveDir;
	vector m_vecPos1;
	vector m_vecPos2;

	/* map keys */
	float m_flDistance;
	float m_flProgress;
	float m_flSpeed;
	float m_flReturnspeed;

	void(void) CBaseMomentary;

	/* overrides */
	virtual void(float) Save;
	virtual void(string, string) Restore;
};

void
CBaseMomentary::Save(float handle)
{
	SaveFloat(handle, "user", num_for_edict(m_eUser));
	SaveVector(handle, "move_dir", m_vecMoveDir);
	SaveVector(handle, "pos1", m_vecPos1);
	SaveVector(handle, "pos2", m_vecPos2);
	SaveFloat(handle, "distance", m_flDistance);
	SaveFloat(handle, "progress", m_flProgress);
	SaveFloat(handle, "speed", m_flSpeed);
	SaveFloat(handle, "returnspeed", m_flReturnspeed);

	super::Save(handle);
}

void
CBaseMomentary::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "user":
		m_eUser = edict_num(ReadFloat(strValue));
		break;
	case "move_dir":
		m_vecMoveDir = ReadVector(strValue);
		break;
	case "pos1":
		m_vecPos1 = ReadVector(strValue);
		break;
	case "pos2":
		m_vecPos2 = ReadVector(strValue);
		break;
	case "distance":
		m_flProgress = ReadFloat(strValue);
		break;
	case "progress":
		m_flProgress = ReadFloat(strValue);
		break;
	case "speed":
		m_flSpeed = ReadFloat(strValue);
		break;
	case "returnspeed":
		m_flReturnspeed = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
CBaseMomentary::CBaseMomentary(void)
{
	super::NSRenderableEntity();
}
