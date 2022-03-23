/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

/*QUAKED env_projectedtexture (1 0 0) (-8 -8 -8) (8 8 8) PRTEXSF_STARTON
Textured light projected. This is the type of lighting that's used for
flashlights, lamp spotlights and so on.

-------- KEYS --------
"targetname" : Name
"target" : Name of an entity in the map that light will point at.
"lightcolor" : Color of the projected texture light + intensity (unused?)
"style" : Light appearance style of the projected texture.
"texturename" : Name of the texture to be cast as a light.
"farz" : Distance to which this projected light will be cast.
"nearz" : Clipping distance for near objects that won't get lit.
"pattern" : Sets a custom pattern. The "style" key overrides this.

-------- INPUTS --------
"TurnOff" : Turns the entity off.
"TurnOn" : Turns the entity on.
"Toggle" : Toggles the entity to an on/off state.
"SpotlightTexture" : Sets the projected texture to a specified path.
"LightColor" : Sets the color of the light in RGB255 form.
"SetLightStyle" : Sets the light appearance integer.
"SetNearZ" : Sets clipping distance for near objects that won't get lit.
"SetFarZ" : Sets distance to which this projected light will be cast.
"SetPattern" : Sets the style pattern of the light to a custom one.

-------- SPAWNFLAGS --------
PRTEXSF_STARTON : Start enabled.

-------- TRIVIA --------
This entity was introduced in Half-Life 2: Episode One (2006).
*/

enumflags
{
	PRTEXFL_CHANGED_ORIGIN,
	PRTEXFL_CHANGED_ANGLES,
	PRTEXFL_CHANGED_LIGHT,
	PRTEXFL_CHANGED_INTENSITY,
	PRTEXFL_CHANGED_FARZ,
	PRTEXFL_CHANGED_NEARZ,
	PRTEXFL_CHANGED_STYLE,
	PRTEXFL_CHANGED_STATE,
	PRTEXFL_CHANGED_TEXTURE,
	PRTEXFL_CHANGED_FOV,
	PRTEXFL_CHANGED_PATTERN
};

class env_projectedtexture:NSPointTrigger
{
	vector m_vecLight;
	float m_flIntensity;
	float m_flInnerCone;
	float m_flCone;
	float m_flFarZ;
	float m_flNearZ;
	float m_flRadius;
	float m_flStyle;
	string m_strPattern;
	string m_strTextureName;
	float m_flFOV;
	int m_iState;

	void(void) env_projectedtexture;

#ifdef CLIENT
	virtual void(float,float) ReceiveEntity;
	virtual float(void) predraw;
#else
	virtual void(entity, int) Trigger;
	virtual void(void) Respawn;
	virtual float(entity, float) SendEntity;
	virtual void(string, string) SpawnKey;
	virtual void(entity, string, string) Input;
	virtual void(void) EvaluateEntity;
#endif
};

#ifdef CLIENT
float
env_projectedtexture::predraw(void)
{
	if (!m_iState) {
		return (PREDRAW_NEXT);
	}

	/* TODO: We need to handle the second cone light */
	float p = dynamiclight_add(origin, m_flFarZ, m_vecLight, m_flStyle, m_strTextureName);
	dynamiclight_set(p, LFIELD_ANGLES, angles);
	dynamiclight_set(p, LFIELD_FLAGS, LFLAG_NORMALMODE | LFLAG_REALTIMEMODE | LFLAG_SHADOWMAP);
	dynamiclight_set(p, LFIELD_NEARCLIP, m_flNearZ);
	dynamiclight_set(p, LFIELD_STYLESTRING, m_strPattern);

	return (PREDRAW_NEXT);
}

void
env_projectedtexture::ReceiveEntity(float flNew, float flFlags)
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
	if (flFlags & PRTEXFL_CHANGED_FARZ)
		m_flFarZ = readfloat();
	if (flFlags & PRTEXFL_CHANGED_NEARZ)
		m_flNearZ = readfloat();
	if (flFlags & PRTEXFL_CHANGED_STYLE)
		m_flStyle = readbyte();
	if (flFlags & PRTEXFL_CHANGED_STATE)
		m_iState = readbyte();
	if (flFlags & PRTEXFL_CHANGED_TEXTURE)
		m_strTextureName = readstring();
	if (flFlags & PRTEXFL_CHANGED_FOV)
		m_flFOV = readfloat();
	if (flFlags & PRTEXFL_CHANGED_PATTERN)
		m_strPattern = readstring();

	classname = "env_projectedtexture";
}
#else
void
env_projectedtexture::EvaluateEntity(void)
{
	if (ATTR_CHANGED(origin)) {
		SetSendFlags(PRTEXFL_CHANGED_ORIGIN);
	}
	if (ATTR_CHANGED(angles)) {
		angles[0] = Math_FixDelta(angles[0]);
		angles[1] = Math_FixDelta(angles[1]);
		angles[2] = Math_FixDelta(angles[2]);

		SetSendFlags(PRTEXFL_CHANGED_ANGLES);
	}
	SAVE_STATE(origin);
	SAVE_STATE(angles);
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
env_projectedtexture::SendEntity(entity ePEnt, float flFlags)
{
	if (clienttype(ePEnt) != CLIENTTYPE_REAL)
		return (0);

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
	if (flFlags & PRTEXFL_CHANGED_FARZ)
		WriteFloat(MSG_ENTITY, m_flFarZ);
	if (flFlags & PRTEXFL_CHANGED_NEARZ)
		WriteFloat(MSG_ENTITY, m_flNearZ);
	if (flFlags & PRTEXFL_CHANGED_STYLE)
		WriteByte(MSG_ENTITY, m_flStyle);
	if (flFlags & PRTEXFL_CHANGED_STATE)
		WriteByte(MSG_ENTITY, m_iState);
	if (flFlags & PRTEXFL_CHANGED_TEXTURE)
		WriteString(MSG_ENTITY, m_strTextureName);
	if (flFlags & PRTEXFL_CHANGED_FOV)
		WriteFloat(MSG_ENTITY, m_flFOV);
	if (flFlags & PRTEXFL_CHANGED_PATTERN)
		WriteString(MSG_ENTITY, m_strPattern);

	return (1);
}

void
env_projectedtexture::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "LightColor":
		m_vecLight = stov(strData);
		SetSendFlags(PRTEXFL_CHANGED_LIGHT);
		break;
	case "SetNearZ":
		m_flNearZ = stof(strData);
		SetSendFlags(PRTEXFL_CHANGED_NEARZ);
		break;
	case "SetFarZ":
		m_flFarZ = stof(strData);
		SetSendFlags(PRTEXFL_CHANGED_FARZ);
		break;
	case "SetLightStyle":
		m_flStyle = stof(strData);
		SetSendFlags(PRTEXFL_CHANGED_STYLE);
		break;
	case "SpotlightTexture":
		m_strTextureName = strData;
		SetSendFlags(PRTEXFL_CHANGED_TEXTURE);
		break;
	case "SetPattern":
		m_strPattern = strData;
		SetSendFlags(PRTEXFL_CHANGED_PATTERN);
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
		super::Input(eAct, strInput, strData);
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
	case "farz":
		m_flFarZ = stof(strValue);
		break;
	case "nearz":
		m_flNearZ = stof(strValue);
		break;
	case "pattern":
		m_strPattern = strValue;
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
env_projectedtexture::Respawn(void)
{
	SetSolid(SOLID_NOT);
	SetSize([-16,-16,-16], [16,16,16]);
	SetOrigin(GetSpawnOrigin());
	SetAngles(GetSpawnAngles());

	m_iState = (spawnflags & 1) ? 1 : 0;
}
#endif

void
env_projectedtexture::env_projectedtexture(void)
{
#ifdef CLIENT
	drawmask = MASK_ENGINE;
#else
	m_strPattern = "z";
	m_vecLight = [255,255,255];
	m_flIntensity = 512;
	m_flFarZ = 512;
	m_flNearZ = 0;
	m_strTextureName = "textures/flashlight";
	m_flFOV = 90;

	super::NSPointTrigger();

	if (m_flStyle > 0 && m_flStyle < 12)
		m_strPattern = getlightstyle(m_flStyle);
#endif
}
