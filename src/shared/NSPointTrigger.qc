/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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

void
NSPointTrigger::NSPointTrigger(void)
{
}

void
NSPointTrigger::Respawn(void)
{
	InitPointTrigger();
}

void
NSPointTrigger::InitPointTrigger(void)
{
	SetOrigin(GetSpawnVector("origin"));
	SetSize(VEC_HULL_MIN, VEC_HULL_MAX);
	SetSolid(SOLID_NOT);
	SetMovetype(MOVETYPE_NONE);

#ifdef SERVER
	RestoreAngles();
	m_bEnabled = (m_bStartDisabled) ? false : true;
#endif
}

void
NSPointTrigger::DebugDraw(void)
{
#ifdef SERVER
	if (!STRING_SET(m_strEditorIcon)) {
		return;
	}

	vector centerPos = WorldSpaceCenter();
	super::DebugDraw();
	R_BeginPolygon(m_strEditorIcon, 0, 0);
		R_PolygonVertex(centerPos + v_right * 8 - v_up * 8, [1,1], [1,1,1], 1.0f);
		R_PolygonVertex(centerPos - v_right * 8 - v_up * 8, [0,1], [1,1,1], 1.0f);
		R_PolygonVertex(centerPos - v_right * 8 + v_up * 8, [0,0], [1,1,1], 1.0f);
		R_PolygonVertex(centerPos + v_right * 8 + v_up * 8, [1,0], [1,1,1], 1.0f);
	R_EndPolygon();
#endif
}

#ifdef SERVER

void
NSPointTrigger::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	default:
		super::SpawnKey(strKey, strValue);
		break;
	}
}

void
NSPointTrigger::Save(float handle)
{
	super::Save(handle);
}

void
NSPointTrigger::Restore(string strKey, string strValue)
{
	switch (strKey) {
	default:
		super::Restore(strKey, strValue);
		break;
	}
}
#endif
