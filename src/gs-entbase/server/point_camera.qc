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
*/
class
point_camera:NSPointTrigger
{
public:
	void point_camera(void);
	
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string,string);
	virtual void Respawn(void);
	virtual void Input(entity,string,string);

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
point_camera::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iUseSAR":
		m_iUseSAR = ReadInt(strValue);
		break;
	case "m_iUseFog":
		m_iUseFog = ReadInt(strValue);
		break;
	case "m_vecFogColor":
		m_vecFogColor = ReadVector(strValue);
		break;
	case "m_flFogStart":
		m_flFogStart = ReadFloat(strValue);
		break;
	case "m_flFogEnd":
		m_flFogEnd = ReadFloat(strValue);
		break;
	case "m_flFOV":
		m_flFOV = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
point_camera::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "FOV":
		m_flFOV = stof(strValue);
		break;
	case "UseScreenAspectRatio":
		m_iUseSAR = stoi(strValue);
		break;
	case "fogEnable":
		m_iUseFog = stoi(strValue);
		break;
	case "fogColor":
		m_vecFogColor = stov(strValue);
		break;
	case "fogStart":
		m_flFogStart = stof(strValue);
		break;
	case "fogEnd":
		m_flFogEnd = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
point_camera::Respawn(void)
{
	InitPointTrigger();

	SetModelindex(0);
	SetSolid(SOLID_NOT);
	SetSize([-16,-16,-16], [16,16,16]);
	SetOrigin(GetSpawnOrigin());
	SetAngles(GetSpawnAngles());
	m_iValue = TRUE;
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
			p.m_iValue = FALSE;
		}

		m_iValue = TRUE;
		break;
	case "SetOn":
		m_iValue = TRUE;
		break;
	case "SetOff":
		m_iValue = FALSE;
		break;
	default:
		super::Input(eAct, strInput, strData);
	}
}
