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

enumflags
{
	ENVFOGCTRL_CHANGED_ACTIVE,
	ENVFOGCTRL_CHANGED_BLEND,
	ENVFOGCTRL_CHANGED_START,
	ENVFOGCTRL_CHANGED_END,
	ENVFOGCTRL_CHANGED_MAXDENSITY,
	ENVFOGCTRL_CHANGED_FARZ,
	ENVFOGCTRL_CHANGED_COLOR,
	ENVFOGCTRL_CHANGED_COLOR2,
	ENVFOGCTRL_CHANGED_DIR
};

/*!QUAKED env_fog_controller (1 .5 0) (-8 -8 -8) (8 8 8) EVFOGCTL_MASTER
# OVERVIEW
Controls fog that affects the entire map.

# KEYS
- "targetname" : Name
- "target" : Name of an entity in the map that light will point at.
- "fogenable" : Will make the fog start active if not 0.
- "fogstart" : Distance from the camera of where the fog starts.
- "fogend" : Distance from the camera of where the fog ends.
- "fogmaxdensity" : Maximum fog density. Value between 0.00 and 1.00.
- "farz" : Clip anything after the specified distance.
- "fogcolor" : Primary color of the fog in RGB255. E.g. '255 0 0' for red.
- "fogcolor2" : Secondary color of the fog in RGB255. Only used when 'fogblend' is 1.
- "fogblend" : Whether or not to blend between fogcolor and fogcolor2.
- "fogdir" : The fog directon for the secondary color. Only used when 'fogblend' is 1.
- "use_angles" : If we should use the 'angles' key instead of 'fogdir'. Only used when 'fogblend' is 1.

# INPUTS
- "TurnOff" : Turns the entity off.
- "TurnOn" : Turns the entity on.
- "Toggle" : Toggles the entity to an on/off state.
- "SetStartDist" : Sets fogstart.
- "SetEndDist" : Sets fogend.
- "SetColor" : Sets fogcolor.
- "SetColorSecondary" : Sets fogcolor2.
- "SetFarZ" : Sets farz.

# SPAWNFLAGS
- EVFOGCTL_MASTER (1) : If specified, this one will always take priority over
                        any other active fog controllers... currently unused.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).
*/
class
env_fog_controller:NSPointTrigger
{
public:
	void env_fog_controller(void);

#ifdef CLIENT
	virtual float StartToBias(void);
	virtual float FogRender(void);
	virtual void FogUpdate(void);
	virtual void RendererRestarted(void);
	virtual void ReceiveEntity(float,float);
#endif

#ifdef SERVER
	virtual float SendEntity(entity,float);
	virtual void EvaluateEntity(void);
	virtual void Trigger(entity, triggermode_t);
	virtual void Respawn(void);
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Input(entity, string, string);
#endif

private:
#ifdef CLIENT
	/* temporary attributes */
	float m_flNextDraw;
	float m_flLastDelta;
#else
	/* main spawn attributes */
	int m_iSpawnEnable;
	int m_iSpawnBlend;
	float m_flSpawnStart;
	float m_flSpawnEnd;
	float m_flSpawnMaxDensity;
	float m_flSpawnFarZ;
	vector m_vecSpawnColor;
	vector m_vecSpawnColor2;
	vector m_vecSpawnDir;
	int m_iUseAngles;
#endif

	/* networked attributes */
	PREDICTED_INT(m_iFogActive)
	PREDICTED_INT(m_iFogBlend)
	PREDICTED_FLOAT(m_flFogStart)
	PREDICTED_FLOAT(m_flFogEnd)
	PREDICTED_FLOAT(m_flFogMaxDensity)
	PREDICTED_FLOAT(m_flFogFarZ)
	PREDICTED_VECTOR(m_vecFogColor)
	PREDICTED_VECTOR(m_vecFogColor2)
	PREDICTED_VECTOR(m_vecFogDir)
};

#ifdef CLIENT
float
env_fog_controller::StartToBias(void)
{
	/* FIXME: currently we don't convert fogstart and fogend into density and bias at all. */
	if (m_flFogStart < 256)
		return 0.2;
	else if (m_flFogStart < 512)
		return 0.1;
	else if (m_flFogStart < 1024)
		return 0.05;
	else if (m_flFogStart < 2048)
		return 0.025;
	else if (m_flFogStart < 4096)
		return 0.0175;
	else
		return 0.05;
}

/* this is mainly for the 'blended' fog. Which is more expensive. */
float
env_fog_controller::FogRender(void)
{
	vector p1, p2;

	if (!m_iFogActive)
		return (PREDRAW_NEXT);

	CSQC_UpdateSeat();

	/* get the difference between camera dir and fog dir */
	makevectors(m_vecFogDir);
	p1 = v_forward;
	makevectors(getproperty(VF_CL_VIEWANGLES));
	p2 = v_forward;
	float delta = vlen(p1 - p2) / 2.0f;

	/* cache so we don't call 'fog' every frame */
	if (delta == m_flLastDelta)
		return (PREDRAW_NEXT);

	m_flLastDelta = delta;

	/* we also only need to call this maybe once every second... */
	if (m_flNextDraw > cltime)
		return (PREDRAW_NEXT);

	m_flNextDraw = cltime + 1.0f;

	/* apply the fog. wish there was a builtin for this instead... */
	localcmd(sprintf("set r_fog_linear 1; fog %f %f %f %f %f %f\n", \
		m_flFogEnd,
		Math_Lerp(m_vecFogColor[0], m_vecFogColor2[0], delta),
		Math_Lerp(m_vecFogColor[1], m_vecFogColor2[1], delta),
		Math_Lerp(m_vecFogColor[2], m_vecFogColor2[2], delta),
		m_flFogMaxDensity,
		m_flFogStart));

	//print(sprintf("%f (%v, %v)\n", delta, p1, p2));

	return (PREDRAW_NEXT);
}

void
env_fog_controller::FogUpdate(void)
{
	if (!m_iFogActive)
		return;

	localcmd(sprintf("set r_fog_linear 1; fog %f %f %f %f %f %f\n", \
		m_flFogEnd,
		m_vecFogColor[0],
		m_vecFogColor[1],
		m_vecFogColor[2],
		m_flFogMaxDensity,
		m_flFogStart));
}

void
env_fog_controller::RendererRestarted(void)
{
	think = FogUpdate;
	nextthink = time + 0.1f;
}

void
env_fog_controller::ReceiveEntity(float flNew, float flSendFlags)
{
	if (flSendFlags & ENVFOGCTRL_CHANGED_ACTIVE)
		m_iFogActive = readbyte();
	if (flSendFlags & ENVFOGCTRL_CHANGED_BLEND)
		m_iFogBlend = readbyte();
	if (flSendFlags & ENVFOGCTRL_CHANGED_START)
		m_flFogStart = readfloat();
	if (flSendFlags & ENVFOGCTRL_CHANGED_END)
		m_flFogEnd = readfloat();
	if (flSendFlags & ENVFOGCTRL_CHANGED_MAXDENSITY)
		m_flFogMaxDensity = readfloat();
	if (flSendFlags & ENVFOGCTRL_CHANGED_FARZ)
		m_flFogFarZ = readfloat();
	if (flSendFlags & ENVFOGCTRL_CHANGED_COLOR) {
		m_vecFogColor[0] = readfloat();
		m_vecFogColor[1] = readfloat();
		m_vecFogColor[2] = readfloat();
	}
	if (flSendFlags & ENVFOGCTRL_CHANGED_COLOR2) {
		m_vecFogColor2[0] = readfloat();
		m_vecFogColor2[1] = readfloat();
		m_vecFogColor2[2] = readfloat();
	}
	if (flSendFlags & ENVFOGCTRL_CHANGED_DIR) {
		m_vecFogDir[0] = readfloat();
		m_vecFogDir[1] = readfloat();
		m_vecFogDir[2] = readfloat();
	}
	FogUpdate();

	if (m_iFogBlend) {
		predraw = FogRender;
		drawmask = MASK_ENGINE;
	} else {
		predraw = __NULL__;
		drawmask = 0;
	}
}
#else
float
env_fog_controller::SendEntity(entity ePVEnt, float flSendFlags)
{
	WriteByte(MSG_ENTITY, ENT_FOGCONTROLLER);
	WriteFloat(MSG_ENTITY, flSendFlags);

	if (flSendFlags & ENVFOGCTRL_CHANGED_ACTIVE)
		WriteByte(MSG_ENTITY, m_iFogActive);
	if (flSendFlags & ENVFOGCTRL_CHANGED_BLEND)
		WriteByte(MSG_ENTITY, m_iFogBlend);
	if (flSendFlags & ENVFOGCTRL_CHANGED_START)
		WriteFloat(MSG_ENTITY, m_flFogStart);
	if (flSendFlags & ENVFOGCTRL_CHANGED_END)
		WriteFloat(MSG_ENTITY, m_flFogEnd);
	if (flSendFlags & ENVFOGCTRL_CHANGED_MAXDENSITY)
		WriteFloat(MSG_ENTITY, m_flFogMaxDensity);
	if (flSendFlags & ENVFOGCTRL_CHANGED_FARZ)
		WriteFloat(MSG_ENTITY, m_flFogFarZ);
	if (flSendFlags & ENVFOGCTRL_CHANGED_COLOR) {
		WriteFloat(MSG_ENTITY, m_vecFogColor[0]);
		WriteFloat(MSG_ENTITY, m_vecFogColor[1]);
		WriteFloat(MSG_ENTITY, m_vecFogColor[2]);
	}
	if (flSendFlags & ENVFOGCTRL_CHANGED_COLOR2) {
		WriteFloat(MSG_ENTITY, m_vecFogColor2[0]);
		WriteFloat(MSG_ENTITY, m_vecFogColor2[1]);
		WriteFloat(MSG_ENTITY, m_vecFogColor2[2]);
	}
	if (flSendFlags & ENVFOGCTRL_CHANGED_DIR) {
		WriteFloat(MSG_ENTITY, m_vecFogDir[0]);
		WriteFloat(MSG_ENTITY, m_vecFogDir[1]);
		WriteFloat(MSG_ENTITY, m_vecFogDir[2]);
	}

	return (1);
}

void
env_fog_controller::EvaluateEntity(void)
{
	if (ATTR_CHANGED(m_iFogActive))
		SetSendFlags(ENVFOGCTRL_CHANGED_ACTIVE);
	if (ATTR_CHANGED(m_iFogBlend))
		SetSendFlags(ENVFOGCTRL_CHANGED_BLEND);
	if (ATTR_CHANGED(m_flFogStart))
		SetSendFlags(ENVFOGCTRL_CHANGED_START);
	if (ATTR_CHANGED(m_flFogEnd))
		SetSendFlags(ENVFOGCTRL_CHANGED_END);
	if (ATTR_CHANGED(m_flFogMaxDensity))
		SetSendFlags(ENVFOGCTRL_CHANGED_MAXDENSITY);
	if (ATTR_CHANGED(m_flFogFarZ))
		SetSendFlags(ENVFOGCTRL_CHANGED_FARZ);
	if (ATTR_CHANGED(m_vecFogColor))
		SetSendFlags(ENVFOGCTRL_CHANGED_COLOR);
	if (ATTR_CHANGED(m_vecFogColor2))
		SetSendFlags(ENVFOGCTRL_CHANGED_COLOR2);
	if (ATTR_CHANGED(m_vecFogDir))
		SetSendFlags(ENVFOGCTRL_CHANGED_DIR);

	SAVE_STATE(m_iFogActive)
	SAVE_STATE(m_iFogBlend)
	SAVE_STATE(m_flFogStart)
	SAVE_STATE(m_flFogEnd)
	SAVE_STATE(m_flFogMaxDensity)
	SAVE_STATE(m_flFogFarZ)
	SAVE_STATE(m_vecFogColor)
	SAVE_STATE(m_vecFogColor2)
	SAVE_STATE(m_vecFogDir)
}

void
env_fog_controller::Trigger(entity eAct, triggermode_t iState)
{
	switch (iState) {
	case TRIG_OFF:
		m_iFogActive = (0);
		break;
	case TRIG_ON:
		m_iFogActive = (1);
		break;
	default:
		m_iFogActive = (1-m_iFogActive);
	}
}

void
env_fog_controller::Respawn(void)
{
	SetSolid(SOLID_NOT);
	SetMovetype(MOVETYPE_PUSH);
	SetModel(GetSpawnModel());
	SetOrigin(GetSpawnOrigin());
	pvsflags = PVSF_IGNOREPVS;

	m_iFogActive = m_iSpawnEnable;
	m_iFogBlend = m_iSpawnBlend;
	m_flFogStart = m_flSpawnStart;
	m_flFogEnd = m_flSpawnEnd;
	m_flFogMaxDensity = m_flSpawnMaxDensity;
	m_flFogFarZ = m_flSpawnFarZ;
	m_vecFogColor = m_vecSpawnColor;
	m_vecFogColor2 = m_vecSpawnColor2;

	if (m_iUseAngles)
		m_vecFogDir = GetSpawnAngles();
	else
		m_vecFogDir = m_vecSpawnDir;
}

void
env_fog_controller::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iSpawnEnable", m_iSpawnEnable);
	SaveInt(handle, "m_iSpawnBlend", m_iSpawnBlend);
	SaveFloat(handle, "m_flSpawnStart", m_flSpawnStart);
	SaveFloat(handle, "m_flSpawnEnd", m_flSpawnEnd);
	SaveFloat(handle, "m_flSpawnMaxDensity", m_flSpawnMaxDensity);
	SaveFloat(handle, "m_flSpawnFarZ", m_flSpawnFarZ);
	SaveVector(handle, "m_vecSpawnColor", m_vecSpawnColor);
	SaveVector(handle, "m_vecSpawnColor2", m_vecSpawnColor2);
	SaveVector(handle, "m_vecSpawnDir", m_vecSpawnDir);
	SaveInt(handle, "m_iUseAngles", m_iUseAngles);
	SaveInt(handle, "m_iFogActive", m_iFogActive);
	SaveInt(handle, "m_iFogBlend", m_iFogBlend);
	SaveFloat(handle, "m_flFogStart", m_flFogStart);
	SaveFloat(handle, "m_flFogEnd", m_flFogEnd);
	SaveFloat(handle, "m_flFogMaxDensity", m_flFogMaxDensity);
	SaveFloat(handle, "m_flFogFarZ", m_flFogFarZ);
	SaveVector(handle, "m_vecFogColor", m_vecFogColor);
	SaveVector(handle, "m_vecFogColor2", m_vecFogColor2);
	SaveVector(handle, "m_vecFogDir", m_vecFogDir);
}

void
env_fog_controller::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iFogActive":
		m_iFogActive = stoi(strValue);
		break;
	case "m_iFogBlend":
		m_iFogBlend = stoi(strValue);
		break;
	case "m_flFogStart":
		m_flFogStart = stof(strValue);
		break;
	case "m_flFogEnd":
		m_flFogEnd = stof(strValue);
		break;
	case "m_flFogMaxDensity":
		m_flFogMaxDensity = stof(strValue);
		break;
	case "m_flFogFarZ":
		m_flFogFarZ = stof(strValue);
		break;
	case "m_vecFogColor":
		m_vecFogColor = stov(strValue);
		break;
	case "m_vecFogColor2":
		m_vecFogColor2 = stov(strValue);
		break;
	case "m_vecFogDir":
		m_vecFogDir = stov(strValue);
		break;
	case "m_iSpawnEnable":
		m_iSpawnEnable = stoi(strValue);
		break;
	case "m_iSpawnBlend":
		m_iSpawnBlend = stoi(strValue);
		break;
	case "m_flSpawnStart":
		m_flSpawnStart = stof(strValue);
		break;
	case "m_flSpawnEnd":
		m_flSpawnEnd = stof(strValue);
		break;
	case "m_flSpawnMaxDensity":
		m_flSpawnMaxDensity = stof(strValue);
		break;
	case "m_flSpawnFarZ":
		m_flSpawnFarZ = stof(strValue);
		break;
	case "m_vecSpawnColor":
		m_vecSpawnColor = stov(strValue);
		break;
	case "m_vecSpawnColor2":
		m_vecSpawnColor2 = stov(strValue);
		break;
	case "m_vecSpawnDir":
		m_vecSpawnDir = stov(strValue);
		break;
	case "m_iUseAngles":
		m_iUseAngles = stoi(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
env_fog_controller::Input(entity eAct, string strKey, string strValue)
{
	switch (strKey) {
	case "TurnOn":
		m_iFogActive = (0);
		break;
	case "TurnOff":
		m_iFogActive = (1);
		break;
	case "Toggle":
		m_iFogActive = (1-m_iFogActive);
		break;
	case "SetStartDist":
		m_flFogStart = stof(strValue);
		break;
	case "SetEndDist":
		m_flFogEnd = stof(strValue);
		break;
	case "SetMaxDensity":
		m_flFogMaxDensity = stof(strValue);
		break;
	case "SetFarZ":
		m_flFogFarZ = stof(strValue);
		break;
	case "SetColor":
		m_vecFogColor = stov(strValue);
		break;
	case "SetColorSecondary":
		m_vecFogColor2 = stov(strValue);
		break;
	default:
		super::Input(eAct, strKey, strValue);
	}
}

void
env_fog_controller::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "fogenable":
		m_iSpawnEnable = stoi(strValue);
		break;
	case "fogstart":
		m_flSpawnStart = stof(strValue);
		break;
	case "fogend":
		m_flSpawnEnd = stof(strValue);
		break;
	case "fogblend":
		m_iSpawnBlend = stoi(strValue);
		break;
	case "fogmaxdensity":
		m_flSpawnMaxDensity = stof(strValue);
		break;
	case "farz":
		m_flSpawnFarZ = stof(strValue);
		break;
	case "fogcolor":
		m_vecSpawnColor = stov(strValue) / 255;
		break;
	case "fogcolor2":
		m_vecSpawnColor2 = stov(strValue) / 255;
		break;
	case "fogdir":
		m_vecSpawnDir = stov(strValue);
		break;
	/* because these entities aren't complicated enough */
	case "use_angles":
		m_iUseAngles = stoi(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}
#endif

void
env_fog_controller::env_fog_controller(void)
{
#ifdef SERVER
	m_vecSpawnColor = [1.0, 1.0, 1.0];
	m_flSpawnMaxDensity = 1.0f;
#endif
}