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

/*QUAKED point_camera (1 0 0) (-8 -8 -8) (8 8 8) PCAMFL_STARTOFF
"targetname"            Name
"FOV"                   Field of view in degrees
"UseScreenAspectRatio"  Forces the aspect ratio to be the same as the game (?)
"fogEnable"             Enable fog in the camera's view
"fogColor"              Color of the fog in RGB255
"fogStart"              Near fog plane
"fogEnd"                Far fog plane

Inputs:
"ChangeFOV"             Change the camera's field of view
"SetOnAndTurnOthersOff" Turn this camera on while deactivating all others
"SetOn"                 Turn this camera on
"SetOff"                Turn this camera off

A virtual camera of which its output can be displayed on a rendertarget.
This plays well with the func_monitor entity.

Trivia:
This entity was introduced in Half-Life 2 (2004).
*/

class point_camera:CBaseTrigger
{
	float m_flFOV;
	int m_iUseSAR;
	int m_iUseFog;
	vector m_vecFogColor;
	float m_flFogStart;
	float m_flFogEnd;

	void(void) point_camera;

	virtual void(entity,string,string) Input;
	virtual void(string,string) SpawnKey;
	virtual void(void) Respawn;
};

void
point_camera::Input(entity eAct, string strInput, string strData)
{
	switch (strInput) {
	case "ChangeFOV":
		m_flFOV = stof(strInput);
		break;
	case "SetOnAndTurnOthersOff":
		for (point_camera e = world; e = find(e, ::classname, "point_camera");)
			e.m_iValue = FALSE;

		m_iValue = TRUE;
		break;
	case "SetOn":
		m_iValue = TRUE;
		break;
	case "SetOff":
		m_iValue = FALSE;
		break;
	default:
		CBaseTrigger::Input(eAct, strInput, strData);
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
		CBaseTrigger::SpawnKey(strKey, strValue);
	}
}

void
point_camera::Respawn(void)
{
	SetModelindex(0);
	SetSolid(SOLID_NOT);
	SetSize([-16,-16,-16], [16,16,16]);
	SetOrigin(m_oldOrigin);
	SetAngles(m_oldAngle);
	m_iValue = TRUE;
}

void
point_camera::point_camera(void)
{
	m_flFOV = 90;

	CBaseTrigger::CBaseTrigger();
}
