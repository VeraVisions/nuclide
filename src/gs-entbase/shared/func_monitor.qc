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

#ifdef CLIENT
int g_iRenderTargetActive;
float g_flRenderTargetFOV;
vector g_iRenderTargetSize;
vector g_vecRenderTargetPos;
vector g_vecRenderTargetAngles;

void
RenderTarget_Monitor_Update(void)
{
	if (!g_iRenderTargetActive) {
		return;
	}

	clearscene();
	setviewprop(VF_RT_DESTCOLOUR, "base", (float)1, g_iRenderTargetSize);
	setviewprop(VF_SIZE, g_iRenderTargetSize);
	setviewprop(VF_DRAWENGINESBAR, (float)0);
	setviewprop(VF_ORIGIN, g_vecRenderTargetPos);
	setviewprop(VF_ANGLES, g_vecRenderTargetAngles);
	setviewprop(VF_AFOV, g_flRenderTargetFOV);

	/* TODO: This is ideally where fog parms should be set... :/ */
	addentities(MASK_ENGINE);
	renderscene();
	setviewprop(VF_RT_DESTCOLOUR, "");
}
#endif

enumflags
{
	MONITORFL_CHANGED_BASE,
	MONITORFL_CHANGED_ORIGIN,
	MONITORFL_CHANGED_ANGLES,
	MONITORFL_CHANGED_FOV,
	MONITORFL_CHANGED_ASPECT,
	MONITORFL_CHANGED_FOGCOLOR,
	MONITORFL_CHANGED_FOGSTART,
	MONITORFL_CHANGED_FOGEND,
	MONITORFL_CHANGED_STATUS
};

/*!QUAKED func_monitor (0 .5 .8) ?
# OVERVIEW
A monitor that renders the view of a linked point_camera entity.

# KEYS
- "targetname" : Name
- "target" : Camera it's linked to.

# INPUTS
- "Enable" : Turns the monitor on
- "Disable" : Turns the monitor on.
- "Toggle" : Toggles the state of the monitor between on and off.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).
*/
class func_monitor:NSRenderableEntity
{
#ifdef CLIENT
	int m_iValue;
#endif
	/* these mirror the fields of a point_camera */
	vector m_vecCamOrigin;
	vector m_vecCamAngles;
	int m_iCamValue;
	float m_flFOV;
	int m_iUseSAR;
	int m_iUseFog;
	vector m_vecFogColor;
	float m_flFogStart;
	float m_flFogEnd;

public:
	void func_monitor(void);

#ifdef CLIENT
	virtual void ReceiveEntity(float,float);

#else
	virtual void Respawn(void);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
	virtual void SpawnKey(string,string);
	virtual void Trigger(entity, triggermode_t);
	virtual void Input(entity, string, string);
#endif
};

#ifdef CLIENT
void
func_monitor::ReceiveEntity(float flNew, float flFlags)
{
	if (flFlags & MONITORFL_CHANGED_ORIGIN) {
		modelindex = readfloat();
		origin[0] = readcoord();
		origin[1] = readcoord();
		origin[2] = readcoord();
	}

	if (flFlags & MONITORFL_CHANGED_ORIGIN) {
		m_vecCamOrigin[0] = readcoord();
		m_vecCamOrigin[1] = readcoord();
		m_vecCamOrigin[2] = readcoord();
	}

	if (flFlags & MONITORFL_CHANGED_ANGLES) {
		m_vecCamAngles[0] = readfloat();
		m_vecCamAngles[1] = readfloat();
		m_vecCamAngles[2] = readfloat();
	}

	if (flFlags & MONITORFL_CHANGED_FOV)
		m_flFOV = readbyte();

	if (flFlags & MONITORFL_CHANGED_ASPECT)
		m_iUseSAR = readbyte();

	if (flFlags & MONITORFL_CHANGED_FOGCOLOR) {
		m_vecFogColor[0] = readbyte();
		m_vecFogColor[1] = readbyte();
		m_vecFogColor[2] = readbyte();
	}

	if (flFlags & MONITORFL_CHANGED_FOGSTART)
		m_flFogStart = readshort();

	if (flFlags & MONITORFL_CHANGED_FOGEND)
		m_flFogEnd = readshort();

	if (flFlags & MONITORFL_CHANGED_STATUS)
		m_iValue = readbyte();

	classname = "func_monitor";

	solid = SOLID_BSP;
	movetype = MOVETYPE_NONE;
	setorigin(this, origin);
	setsize(this, mins, maxs);

	g_iRenderTargetActive = m_iValue;

	if (!m_iValue) {
		return;
	}

	g_flRenderTargetFOV = m_flFOV;
	g_iRenderTargetSize = [320, 240];
	g_vecRenderTargetPos = m_vecCamOrigin;
	g_vecRenderTargetAngles = m_vecCamAngles;
}
#else
float
func_monitor::SendEntity(entity ePEnt, float flFlags)
{
	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return (0);

	WriteByte(MSG_ENTITY, ENT_MONITOR);
	WriteFloat(MSG_ENTITY, flFlags);

	if (flFlags & MONITORFL_CHANGED_BASE) {
		WriteFloat(MSG_ENTITY, modelindex);
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[0]);
	}

	if (flFlags & MONITORFL_CHANGED_ORIGIN) {
		WriteCoord(MSG_ENTITY, m_vecCamOrigin[0]);
		WriteCoord(MSG_ENTITY, m_vecCamOrigin[1]);
		WriteCoord(MSG_ENTITY, m_vecCamOrigin[2]);
	}

	if (flFlags & MONITORFL_CHANGED_ANGLES) {
		WriteFloat(MSG_ENTITY, m_vecCamAngles[0]);
		WriteFloat(MSG_ENTITY, m_vecCamAngles[1]);
		WriteFloat(MSG_ENTITY, m_vecCamAngles[2]);
	}

	if (flFlags & MONITORFL_CHANGED_FOV)
		WriteByte(MSG_ENTITY, m_flFOV);

	if (flFlags & MONITORFL_CHANGED_ASPECT)
		WriteByte(MSG_ENTITY, m_iUseSAR);

	if (flFlags & MONITORFL_CHANGED_FOGCOLOR) {
		WriteByte(MSG_ENTITY, m_vecFogColor[0]);
		WriteByte(MSG_ENTITY, m_vecFogColor[1]);
		WriteByte(MSG_ENTITY, m_vecFogColor[2]);
	}

	if (flFlags & MONITORFL_CHANGED_FOGSTART)
		WriteShort(MSG_ENTITY, m_flFogStart);

	if (flFlags & MONITORFL_CHANGED_FOGEND)
		WriteShort(MSG_ENTITY, m_flFogEnd);

	if (flFlags & MONITORFL_CHANGED_STATUS)
		WriteByte(MSG_ENTITY, m_iValue);

	return (1);
}

void
func_monitor::EvaluateEntity(void)
{
	if (ATTR_CHANGED(origin)) {
		SetSendFlags(MONITORFL_CHANGED_BASE);
	}
	SAVE_STATE(origin)

	/* this monitor is disabled */
	if (!m_iValue)
		return;

	point_camera viewer;
	viewer = (point_camera)find(world, ::targetname, target);
		
	if (!viewer)
		return;

	/* camera is disabled */
	if (!viewer.m_iValue)
		return;

	if (m_vecCamOrigin != viewer.origin) {
		m_vecCamOrigin = viewer.origin;
		SetSendFlags(MONITORFL_CHANGED_ORIGIN);
	}
	if (m_vecCamAngles != viewer.angles) {
		m_vecCamAngles = viewer.angles;
		SetSendFlags(MONITORFL_CHANGED_ANGLES);
	}
	if (m_flFOV != viewer.m_flFOV) {
		m_flFOV = viewer.m_flFOV;
		SetSendFlags(MONITORFL_CHANGED_FOV);
	}
	if (m_iUseSAR != viewer.m_iUseSAR) {
		m_iUseSAR = viewer.m_iUseSAR;
		SetSendFlags(MONITORFL_CHANGED_ASPECT);
	}
	if (m_vecFogColor != viewer.m_vecFogColor) {
		m_vecFogColor = viewer.m_vecFogColor;
		SetSendFlags(MONITORFL_CHANGED_FOGCOLOR);
	}
	if (m_flFogStart != viewer.m_flFogStart) {
		m_flFogStart = viewer.m_flFogStart;
		SetSendFlags(MONITORFL_CHANGED_FOGSTART);
	}
	if (m_flFogEnd != viewer.m_flFogEnd) {
		m_flFogEnd = viewer.m_flFogEnd;
		SetSendFlags(MONITORFL_CHANGED_FOGEND);
	}
	if (m_flFogEnd != viewer.m_flFogEnd) {
		m_flFogEnd = viewer.m_flFogEnd;
		SetSendFlags(MONITORFL_CHANGED_STATUS);
	}
}

void
func_monitor::Trigger(entity act, triggermode_t state)
{
	switch (state) {
	case TRIG_OFF:
		m_iValue = 0;
		break;
	case TRIG_ON:
		m_iValue = 1;
		break;
	default:
		m_iValue = 1 - m_iValue;
	}

	SetSendFlags(MONITORFL_CHANGED_STATUS);
}

void
func_monitor::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "Enable":
		Trigger(eAct, TRIG_ON);
		break;
	case "Disable":
		Trigger(eAct, TRIG_OFF);
		break;
	case "Toggle":
		Trigger(eAct, TRIG_TOGGLE);
		break;
	default:
		super::Input(eAct, strInput, strData);
	}
}

void
func_monitor::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
func_monitor::Respawn(void)
{
	SetSolid(SOLID_BSP);
	SetMovetype(MOVETYPE_NONE);
	SetOrigin(GetSpawnOrigin());
	SetAngles(GetSpawnAngles());
	SetModel(GetSpawnModel());
	m_iValue = TRUE;
}
#endif

void
func_monitor::func_monitor(void)
{
#ifdef CLIENT
	drawmask = MASK_ENGINE;
#endif
}
