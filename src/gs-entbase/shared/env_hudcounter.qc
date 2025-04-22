/*
 * Copyright (c) 2023 Vera Visions LLC.
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
	HUDCOUNTER_CHANGED_ORIGIN,
	HUDCOUNTER_CHANGED_IMAGE,
	HUDCOUNTER_CHANGED_MODELINDEX,
	HUDCOUNTER_CHANGED_TEXT,
	HUDCOUNTER_CHANGED_STATE,
	HUDCOUNTER_CHANGED_COUNTER,
	HUDCOUNTER_CHANGED_POSITION,
};

/*! \brief Shared-Entity: HUD Counter */
/*!QUAKED env_hudcounter (0 1 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
When active, will display an icon and text at its position that can be seen
by players.

# KEYS
- "targetname" : Name
- "Image" : Path of the material that the game will use for the icon.
- "model"	: If set, will use this (sprite) model instead.
- "Text" : A localised string to display next to it.
- "additive"	: When 1, will force the image to be drawn additive.

# INPUTS
- "Enable" : Enable the entity.
- "Disable" : Disable the entity.
- "Toggle" : Toggles between enabled/disabled states.
- "SetValue" : Overrides the current counter value.
- "Increment" : Increment by the desired amount.
- "Decrement" : Decrement by the desired amount.

# TRIVIA
This entity was introduced in Nuclide in February of 2025.

@ingroup sharedentity
@ingroup pointentity
*/
class
env_hudcounter:ncPointTrigger
{
public:
	void env_hudcounter(void);

#ifdef SERVER
	virtual void SpawnKey(string,string);
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Input(entity,string,string);
	virtual void Trigger(entity, triggermode_t);

	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
#endif

#ifdef CLIENT
	virtual void ReceiveEntity(float, float);
	virtual void postdraw(void);
#endif

private:
	PREDICTED_INT(m_counterValue)
	PREDICTED_STRING(m_strIcon)
	PREDICTED_STRING(m_strText)
	PREDICTED_BOOL(m_bEnabled)
	PREDICTED_BOOL(m_bAdditive)
	PREDICTED_VECTOR(m_vecPosXY)
};

void
env_hudcounter::env_hudcounter(void)
{
	m_strIcon =
	m_strText = __NULL__;
	m_bEnabled = true;
	m_bAdditive = false;
	m_vecPosXY = [0.0f, 0.0f, 0.0f];
}

#ifdef SERVER
void
env_hudcounter::SpawnKey(string strKey, string setValue)
{
	switch (strKey) {
	case "image":
		m_strIcon = ReadString(setValue);
		break;
	case "text":
		m_strText = ReadString(setValue);
		break;
	case "additive":
		m_bAdditive = ReadBool(setValue);
		break;
	case "x":
		m_vecPosXY[0] = ReadFloat(setValue);
		break;
	case "y":
		m_vecPosXY[1] = ReadFloat(setValue);
		break;
	default:
		super::SpawnKey(strKey, setValue);
	}
}

void
env_hudcounter::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "m_strIcon", m_strIcon);
	SaveString(handle, "m_strText", m_strText);
	SaveBool(handle, "m_bEnabled", m_bEnabled);
	SaveBool(handle, "m_bAdditive", m_bAdditive);
	SaveInt(handle, "m_counterValue", m_counterValue);
	SaveVector(handle, "m_vecPosXY", m_vecPosXY);
}

void
env_hudcounter::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_strIcon":
		m_strIcon = ReadString(setValue);
		break;
	case "m_strText":
		m_strText = ReadString(setValue);
		break;
	case "m_bAdditive":
		m_bAdditive = ReadBool(setValue);
		break;
	case "m_bEnabled":
		m_bEnabled = ReadBool(setValue);
		break;
	case "m_counterValue":
		m_counterValue = ReadInt(setValue);
		break;
	case "m_vecPosXY":
		m_vecPosXY = ReadVector(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
env_hudcounter::Trigger(entity act, triggermode_t state)
{
	switch (state) {
	case TRIG_OFF:
		m_bEnabled = false;
		break;
	case TRIG_ON:
		m_bEnabled = true;
		break;
	default:
		m_bEnabled = m_bEnabled ? false : true;
	}
}

void
env_hudcounter::Input(entity eAct, string strInput, string strData)
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
	case "SetValue":
		m_counterValue = ReadInt(strData);
		SetModel(GetSpawnString("model"));
		break;
	case "Increment":
		m_counterValue += ReadInt(strData);
		break;
	case "Decrement":
		m_counterValue -= ReadInt(strData);
		break;
	default:
		super::Input(eAct, strInput, strData);
	}
}

void
env_hudcounter::EvaluateEntity(void)
{
	EVALUATE_VECTOR(origin, 0, HUDCOUNTER_CHANGED_ORIGIN)
	EVALUATE_VECTOR(origin, 1, HUDCOUNTER_CHANGED_ORIGIN)
	EVALUATE_VECTOR(origin, 2, HUDCOUNTER_CHANGED_ORIGIN)
	EVALUATE_FIELD(modelindex, HUDCOUNTER_CHANGED_MODELINDEX)
	EVALUATE_FIELD(m_bAdditive, HUDCOUNTER_CHANGED_MODELINDEX)
	EVALUATE_FIELD(m_strIcon, HUDCOUNTER_CHANGED_IMAGE)
	EVALUATE_FIELD(m_strText, HUDCOUNTER_CHANGED_TEXT)
	EVALUATE_FIELD(m_bEnabled, HUDCOUNTER_CHANGED_STATE)
	EVALUATE_FIELD(m_counterValue, HUDCOUNTER_CHANGED_COUNTER)
	EVALUATE_FIELD(m_vecPosXY, HUDCOUNTER_CHANGED_POSITION)

	pvsflags = PVSF_IGNOREPVS;
}

float
env_hudcounter::SendEntity(entity ePEnt, float flChanged)
{
	WriteByte(MSG_ENTITY, ENT_HUDCOUNTER);
	WriteFloat(MSG_ENTITY, flChanged);
	SENDENTITY_COORD(origin[0], HUDCOUNTER_CHANGED_ORIGIN)
	SENDENTITY_COORD(origin[1], HUDCOUNTER_CHANGED_ORIGIN)
	SENDENTITY_COORD(origin[2], HUDCOUNTER_CHANGED_ORIGIN)
	SENDENTITY_FLOAT(modelindex, HUDCOUNTER_CHANGED_MODELINDEX)
	SENDENTITY_FLOAT(m_bAdditive, HUDCOUNTER_CHANGED_MODELINDEX)
	SENDENTITY_STRING(m_strIcon, HUDCOUNTER_CHANGED_IMAGE)
	SENDENTITY_STRING(m_strText, HUDCOUNTER_CHANGED_TEXT)
	SENDENTITY_BYTE(m_bEnabled, HUDCOUNTER_CHANGED_STATE)
	SENDENTITY_INT(m_counterValue, HUDCOUNTER_CHANGED_COUNTER)
	SENDENTITY_FLOAT(m_vecPosXY[0], HUDCOUNTER_CHANGED_POSITION)
	SENDENTITY_FLOAT(m_vecPosXY[1], HUDCOUNTER_CHANGED_POSITION)
	return true;
}
#endif

#ifdef CLIENT
void
env_hudcounter::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], HUDCOUNTER_CHANGED_ORIGIN)
	READENTITY_COORD(origin[1], HUDCOUNTER_CHANGED_ORIGIN)
	READENTITY_COORD(origin[2], HUDCOUNTER_CHANGED_ORIGIN)
	READENTITY_FLOAT(modelindex, HUDCOUNTER_CHANGED_MODELINDEX)
	READENTITY_FLOAT(m_bAdditive, HUDCOUNTER_CHANGED_MODELINDEX)
	READENTITY_STRING(m_strIcon, HUDCOUNTER_CHANGED_IMAGE)
	READENTITY_STRING(m_strText, HUDCOUNTER_CHANGED_TEXT)
	READENTITY_BYTE(m_bEnabled, HUDCOUNTER_CHANGED_STATE)
	READENTITY_INT(m_counterValue, HUDCOUNTER_CHANGED_COUNTER)
	READENTITY_FLOAT(m_vecPosXY[0], HUDCOUNTER_CHANGED_POSITION)
	READENTITY_FLOAT(m_vecPosXY[1], HUDCOUNTER_CHANGED_POSITION)
	setorigin(this, origin);

	if (modelindex) {
		m_strIcon = spriteframe(modelnameforindex(modelindex), 0, 0.0f);
	}
}

void
env_hudcounter::postdraw(void)
{
	if (!m_bEnabled)
		return;

	float textLength = Font_StringWidth(m_strText, true, FONT_CON);
	vector vecProj = g_vec_null;
	vector projectedPos = g_vec_null;
	float a = 1.0f;
	string distText = sprintf("%i", m_counterValue);

	if (m_vecPosXY[0] == -1) {
		vecProj[0] = g_hudmins[0] + (g_hudres[0] / 2) - 32;
	} else {
		vecProj[0] = g_hudmins[0] + ((g_hudres[0] - 64) * m_vecPosXY[0]);
	}

	if (m_vecPosXY[1] == -1) {
		vecProj[1] = g_hudmins[1] + (g_hudres[1] / 2) - 32;
	} else {
		vecProj[1] = g_hudmins[1] + ((g_hudres[1] - 64) * m_vecPosXY[1]);
	}

	if (!m_bAdditive) {
		drawpic(vecProj, m_strIcon, [64, 64], [1,1,1], a);
	} else {
		drawpic(vecProj, m_strIcon, [64, 64], [1,1,1], a, DRAWFLAG_ADDITIVE);
	}


	/* counter */
	projectedPos = vecProj + [64, 32];
	Font_DrawText_RGBA(projectedPos + [1,1], distText, [0,0,0], a, FONT_CON);
	Font_DrawText_RGBA(projectedPos, distText, [1,1,1], a, FONT_CON);

	projectedPos = vecProj + [-(textLength/2), 48];
	projectedPos[1] += Font_GetHeight(FONT_CON);

	Font_DrawText_RGBA(projectedPos + [1,1], m_strText, [0,0,0], a, FONT_CON);
	Font_DrawText_RGBA(projectedPos, m_strText, [1,1,1], a, FONT_CON);
}
#endif