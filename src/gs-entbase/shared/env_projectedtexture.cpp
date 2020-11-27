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

/*QUAKED env_projectedtexture (1 0 0) (-8 -8 -8) (8 8 8)
"targetname"        Name
"target"            Name of an entity in the map that light will point at.
"_light"            Color of the spotlight in RGB255 format.
"brightness"        Intensity of the spotlight.
"_inner_cone"       Angles of the inner spotlight beam. 0 = omnidirectional.
"_cone"             Angles of the outer spotlight beam. 0 = omnidirectional.
"distance"          Distance that light is allowed to cast, in inches.
"spotlight_radius"  Radius of the resulting spotlight that's cast at a wall.
"style"             Select one of the hard-coded lightstyles.
"start_active"      Override for if the entity should start on or off.

Dynamic light entity. Can be parented to things, it even has some inputs that
may be interesting.

The 'start_active' is a Nuclide specific one. There is no way in Source engine
games to tell the entity to start inactive as far as I can tell.

Trivia:
This entity was introduced in Half-Life 2 (2004).
*/

enumflags
{
	PRTEXFL_CHANGED_ORIGIN,
	PRTEXFL_CHANGED_ANGLES,
	PRTEXFL_CHANGED_LIGHT,
	PRTEXFL_CHANGED_INTENSITY,
	PRTEXFL_CHANGED_STYLE,
	PRTEXFL_CHANGED_STATE,
	PRTEXFL_CHANGED_TEXTURE,
	PRTEXFL_CHANGED_FOV
};

#ifdef CLIENT
class env_projectedtexture
#else
class env_projectedtexture:CBaseTrigger
#endif
{
	vector m_vecLight;
	float m_flIntensity;
	float m_flInnerCone;
	float m_flCone;
	float m_flDistance;
	float m_flRadius;
	float m_flStyle;
	string m_strTextureName;
	float m_flFOV;
	int m_iState;

	void(void) env_projectedtexture;

#ifdef CLIENT
	virtual void(float) ReceiveEntity;
	virtual float(void) predraw;
#else
	int m_iStartActive;

	virtual void(entity, int) Trigger;
	virtual void(void) Respawn;
	virtual float(entity, float) SendEntity;
	virtual void(string, string) SpawnKey;
	virtual void(entity, string, string) Input;
	virtual void(void) ParentUpdate;
#endif
};

#ifdef CLIENT
float
env_projectedtexture::predraw(void)
{
	if (!m_iState) {
		return PREDRAW_NEXT;
	}

	/* TODO: We need to handle the second cone light */
	float p = dynamiclight_add(origin, 512, m_vecLight, m_flStyle, m_strTextureName);
	dynamiclight_set(p, LFIELD_ANGLES, angles);
	dynamiclight_set(p, LFIELD_FLAGS, LFLAG_NORMALMODE | LFLAG_REALTIMEMODE | LFLAG_SHADOWMAP);

	if (!m_flStyle)
		dynamiclight_set(p, LFIELD_STYLESTRING, "z");

	addentity(this);
	return PREDRAW_NEXT;
}

void
env_projectedtexture::ReceiveEntity(float flFlags)
{
	if (flFlags & PRTEXFL_CHANGED_ORIGIN) {
		origin[0] = readcoord();
		origin[1] = readcoord();
		origin[2] = readcoord();
		setorigin(this, origin);
	}

	if (flFlags & PRTEXFL_CHANGED_ANGLES) {
		angles[0] = readfloat();
		angles[1] = readfloat();
		angles[2] = readfloat();
	}

	if (flFlags & PRTEXFL_CHANGED_LIGHT) {
		m_vecLight[0] = readbyte() / 255;
		m_vecLight[1] = readbyte() / 255;
		m_vecLight[2] = readbyte() / 255;
	}

	if (flFlags & PRTEXFL_CHANGED_INTENSITY)
		m_flIntensity = readfloat();
	if (flFlags & PRTEXFL_CHANGED_STYLE)
		m_flStyle = readbyte();
	if (flFlags & PRTEXFL_CHANGED_STATE)
		m_iState = readbyte();
	if (flFlags & PRTEXFL_CHANGED_TEXTURE)
		m_strTextureName = readstring();
	if (flFlags & PRTEXFL_CHANGED_FOV)
		m_flFOV = readfloat();

	classname = "env_projectedtexture";
}
#else
void
env_projectedtexture::ParentUpdate(void)
{
	if (net_origin != origin) {
		net_origin = origin;
		SendFlags |= PRTEXFL_CHANGED_ORIGIN;
	}
	if (net_angles != angles) {
		net_angles = angles;
		SendFlags |= PRTEXFL_CHANGED_ANGLES;
	}

	if (m_parent) {
		entity p = find(world, ::targetname, m_parent);

		if (p) {
			CBaseEntity t = (CBaseEntity)p;
			vector ofs = m_oldOrigin - t.m_oldOrigin;
			SetOrigin(p.origin + ofs);
		}
	}
}

void
env_projectedtexture::Trigger(entity act, int state)
{
	switch (state) {
	case TRIG_OFF:
		m_iState = 0;
		break;
	case TRIG_ON:
		m_iState = 1;
		break;
	default:
		m_iState = 1 - m_iState;
	}

	SendFlags |= PRTEXFL_CHANGED_STATE;
}

float
env_projectedtexture::SendEntity(entity ePVSEnt, float flFlags)
{
	WriteByte(MSG_ENTITY, ENT_PROJECTEDTEXTURE);
	WriteFloat(MSG_ENTITY, flFlags);

	if (flFlags & PRTEXFL_CHANGED_ORIGIN) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
		WriteCoord(MSG_ENTITY, origin[2]);
	}

	if (flFlags & PRTEXFL_CHANGED_ANGLES) {
		WriteFloat(MSG_ENTITY, angles[0]);
		WriteFloat(MSG_ENTITY, angles[1]);
		WriteFloat(MSG_ENTITY, angles[2]);
	}

	if (flFlags & PRTEXFL_CHANGED_LIGHT) {
		WriteByte(MSG_ENTITY, m_vecLight[0]);
		WriteByte(MSG_ENTITY, m_vecLight[1]);
		WriteByte(MSG_ENTITY, m_vecLight[2]);
	}

	if (flFlags & PRTEXFL_CHANGED_INTENSITY)
		WriteFloat(MSG_ENTITY, m_flIntensity);
	if (flFlags & PRTEXFL_CHANGED_STYLE)
		WriteByte(MSG_ENTITY, m_flStyle);
	if (flFlags & PRTEXFL_CHANGED_STATE)
		WriteByte(MSG_ENTITY, m_iState);
	if (flFlags & PRTEXFL_CHANGED_TEXTURE)
		WriteString(MSG_ENTITY, m_strTextureName);
	if (flFlags & PRTEXFL_CHANGED_FOV)
		WriteFloat(MSG_ENTITY, m_flFOV);

	return TRUE;
}

void
env_projectedtexture::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "Color":
		m_vecLight = stov(strData);
		SendFlags |= PRTEXFL_CHANGED_LIGHT;
		break;
	case "brightness":
		m_flIntensity = stof(strData);
		SendFlags |= PRTEXFL_CHANGED_INTENSITY;
		break;
	case "style":
		m_flStyle = stof(strData);
		SendFlags |= PRTEXFL_CHANGED_STYLE;
		break;
	case "TurnOn":
		Trigger(eAct, TRIG_ON);
		break;
	case "TurnOff":
		Trigger(eAct, TRIG_OFF);
		break;
	case "Toggle":
		Trigger(eAct, TRIG_TOGGLE);
		break;
	default:
		CBaseTrigger::Input(eAct, strInput, strData);
	}
}

void
env_projectedtexture::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "lightcolor":
		tokenize(strValue);
		m_vecLight[0] = stof(argv(0));
		m_vecLight[1] = stof(argv(1));
		m_vecLight[2] = stof(argv(2));
		m_flIntensity = stof(argv(3));
		break;
	case "style":
		m_flStyle = stof(strValue);
		break;
	case "texturename":
		m_strTextureName = strValue;
		break;
	case "lightfov":
		m_flFOV = stof(strValue);
		break;
	/* out-of-spec */
	case "start_active":
		m_iStartActive = stoi(strValue);
		break;
	default:
		CBaseTrigger::SpawnKey(strKey, strValue);
	}
}

void
env_projectedtexture::Respawn(void)
{
	SetSolid(SOLID_NOT);
	SetSize([-16,-16,-16], [16,16,16]);
	SetOrigin(m_oldOrigin);
	SetAngles(m_oldAngle);

	m_iState = (m_iStartActive == 1) ? 1 : 0;
}
#endif

void
env_projectedtexture::env_projectedtexture(void)
{
#ifdef CLIENT
	drawmask = MASK_ENGINE;
#else
	m_vecLight = [255,255,255];
	m_flIntensity = 512;
	m_iStartActive = 1;
	m_strTextureName = "textures/flashlight";
	m_flFOV = 90;

	CBaseTrigger::CBaseTrigger();
#endif
}
