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

/*! \brief Server-Entity: Rendertarget Camera Viewpoint */
/*!QUAKED point_camera (1 0 0) (-8 -8 -8) (8 8 8) PCAMFL_STARTOFF
# OVERVIEW
A virtual camera of which its output can be displayed on a rendertarget.
This plays well with the func_monitor entity.

# KEYS
- "targetname" : Name
- "FOV" : Field of view in degrees
- "UseScreenAspectRatio" : Forces the aspect ratio to be the same as the game's.
- "fogEnable" : Enable fog in the camera's view.
- "fogColor" : Color of the fog in RGB255.
- "fogStart" : Near fog plane.
- "fogEnd" : Far fog plane.

# INPUTS
- "ChangeFOV" : Change the camera's field of view.
- "SetOnAndTurnOthersOff" : Turn this camera on while deactivating all others.
- "SetOn" : Turn this camera on.
- "SetOff" : Turn this camera off.

# SPAWNFLAGS
- PCAMFL_STARTOFF (1) : Start with the camera turned off, outputting no signal.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).

@ingroup serverentity
@ingroup pointentity
*/
class
point_camera:ncPointTrigger
{
public:
	void point_camera(void);
	
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Input(entity,string,string);
	virtual void Respawn(void);

private:
	int m_iUseSAR;
	int m_iUseFog;
	vector m_vecFogColor;
	float m_flFogStart;
	float m_flFogEnd;
	float m_flFOV;
};

void
point_camera::point_camera(void)
{
	m_iUseSAR = 0i;
	m_iUseFog = 0i;
	m_vecFogColor = [0.0f, 0.0f, 0.0f];
	m_flFogStart = 0.0f;
	m_flFogEnd = 0.0f;
	m_flFOV = 90.0f;
}

void
point_camera::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iUseSAR", m_iUseSAR);
	SaveInt(handle, "m_iUseFog", m_iUseFog);
	SaveVector(handle, "m_vecFogColor", m_vecFogColor);
	SaveFloat(handle, "m_flFogStart", m_flFogStart);
	SaveFloat(handle, "m_flFogEnd", m_flFogEnd);
	SaveFloat(handle, "m_flFOV", m_flFOV);
}

void
point_camera::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_iUseSAR":
		m_iUseSAR = ReadInt(setValue);
		break;
	case "m_iUseFog":
		m_iUseFog = ReadInt(setValue);
		break;
	case "m_vecFogColor":
		m_vecFogColor = ReadVector(setValue);
		break;
	case "m_flFogStart":
		m_flFogStart = ReadFloat(setValue);
		break;
	case "m_flFogEnd":
		m_flFogEnd = ReadFloat(setValue);
		break;
	case "m_flFOV":
		m_flFOV = ReadFloat(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
point_camera::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "FOV":
		m_flFOV = stof(setValue);
		break;
	case "UseScreenAspectRatio":
		m_iUseSAR = stoi(setValue);
		break;
	case "fogEnable":
		m_iUseFog = stoi(setValue);
		break;
	case "fogColor":
		m_vecFogColor = stov(setValue);
		break;
	case "fogStart":
		m_flFogStart = stof(setValue);
		break;
	case "fogEnd":
		m_flFogEnd = stof(setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
point_camera::Respawn(void)
{
	if (HasSpawnFlags(1)) {
		SetValue(0i);
	} else {
		SetValue(1i);
	}
}

void
point_camera::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "ChangeFOV":
		m_flFOV = stof(strInput);
		break;
	case "SetOnAndTurnOthersOff":
		for (entity e = world; (e = find(e, ::classname, "point_camera"));) {
			point_camera p = (point_camera)e;
			p.SetValue(0i);
		}

		SetValue(1i);
		break;
	case "SetOn":
		SetValue(1i);
		break;
	case "SetOff":
		SetValue(0i);
		break;
	default:
		super::Input(eAct, strInput, strData);
	}
}
