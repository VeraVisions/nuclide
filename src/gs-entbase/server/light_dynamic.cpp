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

/*QUAKED light_dynamic (1 0 0) (-8 -8 -8) (8 8 8)
"targetname"        Name
"target"            Name of an entity in the map that light will point at.
"_light"            Color of the spotlight in RGB255 format.
"brightness"        Intensity of the spotlight.
"_inner_cone"       Angles of the inner spotlight beam. 0 = omnidirectional.
"_cone"             Angles of the outer spotlight beam. 0 = omnidirectional.
"distance"          Distance that light is allowed to cast, in inches.
"spotlight_radius"  Radius of the resulting spotlight that's cast at a wall.
"style"             Select one of the hard-coded lightstyles.

Dynamic light entity. Can be parented to things, it even has some inputs that
may be interesting.

Trivia:
This entity was introduced in Half-Life 2 (2004).
*/

/* this has to match gs-entbase/client/light_dynamic.cpp! */
enumflags
{
	DLIGHTFL_CHANGED_ORIGIN,
	DLIGHTFL_CHANGED_ANGLES,
	DLIGHTFL_CHANGED_LIGHT,
	DLIGHTFL_CHANGED_INTENSITY,
	DLIGHTFL_CHANGED_INNERCONE,
	DLIGHTFL_CHANGED_CONE,
	DLIGHTFL_CHANGED_DISTANCE,
	DLIGHTFL_CHANGED_RADIUS,
	DLIGHTFL_CHANGED_STYLE,
	DLIGHTFL_CHANGED_STATE
};

class light_dynamic:CBaseTrigger
{
	vector m_vecLight;
	float m_flIntensity;
	float m_flInnerCone;
	float m_flCone;
	float m_flDistance;
	float m_flRadius;
	float m_flStyle;
	int m_iState;

	void(void) light_dynamic;
	virtual void(entity, int) Trigger;
	virtual void(void) Respawn;
	virtual float(entity, float) SendEntity;
	virtual void(string, string) SpawnKey;
	virtual void(entity, string, string) Input;
	virtual void(void) ParentUpdate;
};

void
light_dynamic::ParentUpdate(void)
{
	if (net_origin != origin) {
		net_origin = origin;
		SendFlags |= DLIGHTFL_CHANGED_ORIGIN;
	}
	if (net_angles != angles) {
		net_angles = angles;
		SendFlags |= DLIGHTFL_CHANGED_ANGLES;
	}

	if (m_parent) {
		entity p = find(world, ::targetname, m_parent);

		if (!p) {
			return;
		}

		SetOrigin(p.origin);
	}
}

void
light_dynamic::Trigger(entity act, int state)
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

	SendFlags |= DLIGHTFL_CHANGED_STATE;
}

void
light_dynamic::Respawn(void)
{
	SetSolid(SOLID_NOT);
	SetSize([-16,-16,-16], [16,16,16]);
	SetOrigin(m_oldOrigin);
	SetAngles(m_oldAngle);
	m_iState = 1;

	SendFlags = DLIGHTFL_CHANGED_ORIGIN | \
		DLIGHTFL_CHANGED_ANGLES | \
		DLIGHTFL_CHANGED_LIGHT | \
		DLIGHTFL_CHANGED_INTENSITY | \
		DLIGHTFL_CHANGED_INNERCONE | \
		DLIGHTFL_CHANGED_CONE | \
		DLIGHTFL_CHANGED_DISTANCE | \
		DLIGHTFL_CHANGED_RADIUS | \
		DLIGHTFL_CHANGED_STYLE | \
		DLIGHTFL_CHANGED_STATE;
}

float
light_dynamic::SendEntity(entity ePVSEnt, float flFlags)
{
	WriteByte(MSG_ENTITY, ENT_DLIGHT);
	WriteFloat(MSG_ENTITY, flFlags);

	if (flFlags & DLIGHTFL_CHANGED_ORIGIN) {
		WriteCoord(MSG_ENTITY, origin[0]);
		WriteCoord(MSG_ENTITY, origin[1]);
		WriteCoord(MSG_ENTITY, origin[2]);
	}

	if (flFlags & DLIGHTFL_CHANGED_ANGLES) {
		WriteCoord(MSG_ENTITY, angles[0]);
		WriteCoord(MSG_ENTITY, angles[1]);
		WriteCoord(MSG_ENTITY, angles[2]);
	}

	if (flFlags & DLIGHTFL_CHANGED_LIGHT) {
		WriteByte(MSG_ENTITY, m_vecLight[0]);
		WriteByte(MSG_ENTITY, m_vecLight[1]);
		WriteByte(MSG_ENTITY, m_vecLight[2]);
	}

	if (flFlags & DLIGHTFL_CHANGED_INTENSITY)
		WriteFloat(MSG_ENTITY, m_flIntensity);
	if (flFlags & DLIGHTFL_CHANGED_INNERCONE)
		WriteFloat(MSG_ENTITY, m_flInnerCone);
	if (flFlags & DLIGHTFL_CHANGED_CONE)
		WriteFloat(MSG_ENTITY, m_flCone);
	if (flFlags & DLIGHTFL_CHANGED_DISTANCE)
		WriteFloat(MSG_ENTITY, m_flDistance);
	if (flFlags & DLIGHTFL_CHANGED_RADIUS)
		WriteFloat(MSG_ENTITY, m_flRadius);
	if (flFlags & DLIGHTFL_CHANGED_STYLE)
		WriteByte(MSG_ENTITY, m_flStyle);
	if (flFlags & DLIGHTFL_CHANGED_STATE)
		WriteByte(MSG_ENTITY, m_iState);

	return TRUE;
}

void
light_dynamic::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "Color":
		m_vecLight = stov(strData);
		SendFlags |= DLIGHTFL_CHANGED_LIGHT;
		break;
	case "brightness":
		m_flIntensity = stof(strData);
		SendFlags |= DLIGHTFL_CHANGED_INTENSITY;
		break;
	case "distance":
		m_flDistance = stof(strData);
		SendFlags |= DLIGHTFL_CHANGED_DISTANCE;
		break;
	case "_inner_cone":
		m_flInnerCone = stof(strData);
		SendFlags |= DLIGHTFL_CHANGED_INNERCONE;
		break;
	case "_cone":
		m_flCone = stof(strData);
		SendFlags |= DLIGHTFL_CHANGED_CONE;
		break;
	case "spotlight_radius":
		m_flRadius = stof(strData);
		SendFlags |= DLIGHTFL_CHANGED_RADIUS;
		break;
	case "style":
		m_flStyle = stof(strData);
		SendFlags |= DLIGHTFL_CHANGED_STYLE;
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
light_dynamic::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "_light":
		m_vecLight = stov(strValue);
		break;
	case "light":
	case "brightness":
		m_flIntensity = stof(strValue);
		break;
	case "_inner_cone":
		m_flInnerCone = stof(strValue);
		break;
	case "_cone":
		m_flCone = stof(strValue);
		break;
	case "distance":
		m_flDistance = stof(strValue);
		break;
	case "spotlight_radius":
		m_flRadius = stof(strValue);
		break;
	case "style":
		m_flStyle = stof(strValue);
		break;
	default:
		CBaseTrigger::SpawnKey(strKey, strValue);
	}
}

void
light_dynamic::light_dynamic(void)
{
	m_iState = 1;
	m_vecLight = [255,255,255];
	m_flDistance = 256;
	CBaseTrigger::CBaseTrigger();
}

CLASSEXPORT(dynamic_light, light_dynamic)
