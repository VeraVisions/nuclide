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

/*! \brief Shared-Entity: Rendertarget Surface */
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

@ingroup shared
@ingroup brushentity
*/
class func_monitor:NSRenderableEntity
{
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

private:
	/* these mirror the fields of a point_camera */
	PREDICTED_VECTOR(m_vecCamOrigin)
	PREDICTED_VECTOR(m_vecCamAngles)
	PREDICTED_FLOAT(m_flFOV)
	PREDICTED_INT(m_iUseSAR)
	PREDICTED_VECTOR(m_vecFogColor)
	PREDICTED_FLOAT(m_flFogStart)
	PREDICTED_FLOAT(m_flFogEnd)
	PREDICTED_BOOL(m_bState)
	int m_iCamValue;
	int m_iUseFog;
};

#ifdef CLIENT
void
func_monitor::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_FLOAT(modelindex, MONITORFL_CHANGED_BASE)
	READENTITY_COORD(origin[0], MONITORFL_CHANGED_BASE)
	READENTITY_COORD(origin[1], MONITORFL_CHANGED_BASE)
	READENTITY_COORD(origin[2], MONITORFL_CHANGED_BASE)
	READENTITY_COORD(m_vecCamOrigin[0], MONITORFL_CHANGED_ORIGIN)
	READENTITY_COORD(m_vecCamOrigin[1], MONITORFL_CHANGED_ORIGIN)
	READENTITY_COORD(m_vecCamOrigin[2], MONITORFL_CHANGED_ORIGIN)
	READENTITY_ANGLE(m_vecCamAngles[0], MONITORFL_CHANGED_ANGLES)
	READENTITY_ANGLE(m_vecCamAngles[1], MONITORFL_CHANGED_ANGLES)
	READENTITY_ANGLE(m_vecCamAngles[2], MONITORFL_CHANGED_ANGLES)
	READENTITY_BYTE(m_flFOV, MONITORFL_CHANGED_FOV)
	READENTITY_BYTE(m_iUseSAR, MONITORFL_CHANGED_ASPECT)
	READENTITY_BYTE(m_vecFogColor[0], MONITORFL_CHANGED_FOGCOLOR)
	READENTITY_BYTE(m_vecFogColor[1], MONITORFL_CHANGED_FOGCOLOR)
	READENTITY_BYTE(m_vecFogColor[2], MONITORFL_CHANGED_FOGCOLOR)
	READENTITY_SHORT(m_flFogStart, MONITORFL_CHANGED_FOGSTART)
	READENTITY_SHORT(m_flFogEnd, MONITORFL_CHANGED_FOGEND)
	READENTITY_BYTE(m_bState, MONITORFL_CHANGED_STATUS)

	classname = "func_monitor";

	solid = SOLID_BSP;
	movetype = MOVETYPE_NONE;
	setorigin(this, origin);
	setsize(this, mins, maxs);

	g_iRenderTargetActive = m_bState;

	if (!m_bState) {
		return;
	}

	g_flRenderTargetFOV = m_flFOV;
	g_iRenderTargetSize = [320, 240];
	g_vecRenderTargetPos = m_vecCamOrigin;
	g_vecRenderTargetAngles = m_vecCamAngles;
}
#else
float
func_monitor::SendEntity(entity ePEnt, float flChanged)
{
	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return (0);

	WriteByte(MSG_ENTITY, ENT_MONITOR);
	WriteFloat(MSG_ENTITY, flChanged);

	SENDENTITY_FLOAT(modelindex, MONITORFL_CHANGED_BASE)
	SENDENTITY_COORD(origin[0], MONITORFL_CHANGED_BASE)
	SENDENTITY_COORD(origin[1], MONITORFL_CHANGED_BASE)
	SENDENTITY_COORD(origin[2], MONITORFL_CHANGED_BASE)
	SENDENTITY_COORD(m_vecCamOrigin[0], MONITORFL_CHANGED_ORIGIN)
	SENDENTITY_COORD(m_vecCamOrigin[1], MONITORFL_CHANGED_ORIGIN)
	SENDENTITY_COORD(m_vecCamOrigin[2], MONITORFL_CHANGED_ORIGIN)
	SENDENTITY_ANGLE(m_vecCamAngles[0], MONITORFL_CHANGED_ANGLES)
	SENDENTITY_ANGLE(m_vecCamAngles[1], MONITORFL_CHANGED_ANGLES)
	SENDENTITY_ANGLE(m_vecCamAngles[2], MONITORFL_CHANGED_ANGLES)
	SENDENTITY_BYTE(m_flFOV, MONITORFL_CHANGED_FOV)
	SENDENTITY_BYTE(m_iUseSAR, MONITORFL_CHANGED_ASPECT)
	SENDENTITY_BYTE(m_vecFogColor[0], MONITORFL_CHANGED_FOGCOLOR)
	SENDENTITY_BYTE(m_vecFogColor[1], MONITORFL_CHANGED_FOGCOLOR)
	SENDENTITY_BYTE(m_vecFogColor[2], MONITORFL_CHANGED_FOGCOLOR)
	SENDENTITY_SHORT(m_flFogStart, MONITORFL_CHANGED_FOGSTART)
	SENDENTITY_SHORT(m_flFogEnd, MONITORFL_CHANGED_FOGEND)
	SENDENTITY_BYTE(m_bState, MONITORFL_CHANGED_STATUS)

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
	if (!m_bState)
		return;

	point_camera viewer;
	viewer = (point_camera)find(world, ::targetname, target);
		
	if (!viewer)
		return;

	m_vecCamOrigin = viewer.origin;
	m_vecCamAngles = viewer.angles;
	m_flFOV = viewer.m_flFOV;
	m_iUseSAR = viewer.m_iUseSAR;
	m_vecFogColor = viewer.m_vecFogColor;
	m_flFogStart = viewer.m_flFogStart;
	m_bState = viewer.m_iValue ? true : false;

	/* camera is disabled */
	if (!viewer.m_iValue)
		return;

	EVALUATE_FIELD(modelindex, MONITORFL_CHANGED_BASE)
	EVALUATE_VECTOR(origin, 0, MONITORFL_CHANGED_BASE)
	EVALUATE_VECTOR(origin, 1, MONITORFL_CHANGED_BASE)
	EVALUATE_VECTOR(origin, 2, MONITORFL_CHANGED_BASE)
	EVALUATE_VECTOR(m_vecCamOrigin, 0, MONITORFL_CHANGED_ORIGIN)
	EVALUATE_VECTOR(m_vecCamOrigin, 1, MONITORFL_CHANGED_ORIGIN)
	EVALUATE_VECTOR(m_vecCamOrigin, 2, MONITORFL_CHANGED_ORIGIN)
	EVALUATE_VECTOR(m_vecCamAngles, 0, MONITORFL_CHANGED_ANGLES)
	EVALUATE_VECTOR(m_vecCamAngles, 1, MONITORFL_CHANGED_ANGLES)
	EVALUATE_VECTOR(m_vecCamAngles, 2, MONITORFL_CHANGED_ANGLES)
	EVALUATE_FIELD(m_flFOV, MONITORFL_CHANGED_FOV)
	EVALUATE_FIELD(m_iUseSAR, MONITORFL_CHANGED_ASPECT)
	EVALUATE_VECTOR(m_vecFogColor, 0, MONITORFL_CHANGED_FOGCOLOR)
	EVALUATE_VECTOR(m_vecFogColor, 1, MONITORFL_CHANGED_FOGCOLOR)
	EVALUATE_VECTOR(m_vecFogColor, 2, MONITORFL_CHANGED_FOGCOLOR)
	EVALUATE_FIELD(m_flFogStart, MONITORFL_CHANGED_FOGSTART)
	EVALUATE_FIELD(m_flFogEnd, MONITORFL_CHANGED_FOGEND)
	EVALUATE_FIELD(m_bState, MONITORFL_CHANGED_STATUS)
}

void
func_monitor::Trigger(entity act, triggermode_t state)
{
	switch (state) {
	case TRIG_OFF:
		m_bState = 0;
		break;
	case TRIG_ON:
		m_bState = 1;
		break;
	default:
		m_bState = 1 - m_bState;
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
	super::Respawn();
	SetSolid(SOLID_BSP);
	SetMovetype(MOVETYPE_NONE);
	m_bState = true;
}
#endif

void
func_monitor::func_monitor(void)
{
#ifdef CLIENT
	drawmask = MASK_ENGINE;
#endif
}
