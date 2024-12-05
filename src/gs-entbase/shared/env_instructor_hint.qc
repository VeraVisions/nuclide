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
	ENVINSTRUCTOR_CHANGED_ORIGIN,
	ENVINSTRUCTOR_CHANGED_IMAGE,
	ENVINSTRUCTOR_CHANGED_IMAGE_OFF,
	ENVINSTRUCTOR_CHANGED_TEXT,
	ENVINSTRUCTOR_CHANGED_TEXT_COLOR,
	ENVINSTRUCTOR_CHANGED_TIMEOUT,
	ENVINSTRUCTOR_CHANGED_OFFSET,
	ENVINSTRUCTOR_CHANGED_STATE
};

/*! \brief Shared-Entity: Hints/Instructions With Key Bindings */
/*!QUAKED env_instructor_hint (0 1 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
Used to display hints throughout the environment.

# KEYS
- "targetname" : Name
- "hint_caption" : Text of your hint.
- "hint_color" : Color tint of your text.
- "hint_icon_onscreen" : Icon to use when the hint is visible.
- "hint_icon_offscreen" : Icon to use when the hint is out of view.
- "hint_binding" : Name of the command that we'll display a key/button for.
- "hint_nooffscreen" : When 1, will not show an off-screen hint at all.
- "hint_target" : Hint will be displayed at the named entity.
- "hint_static" : When 0, follows the entity specified in `hint_target`. Will be displayed on the heads-up-display otherwise.
- "hint_allow_nodraw_target" : When 0, will stop rendering if the `hint_target` becomes invisible.
- "hint_forcecaption" : When 1, will show the hint even if it's obscured by a wall.
- "hint_icon_offset" : Height offset at which the hint will be displayed in-world.
- "hint_pulseoption" : Speed at which the icon pulses in size. 0 is none, 3 is very fast.
- "hint_alphaoption" : Speed at which the icon pulses in transparency. 0 is none, 3 is very fast.
- "hint_shakeoption" : Strength at which the icon shakes. 0 is none, 2 is wide.
- "hint_timeout" : Time until the hint stops showing. When 0, needs to be triggered to be disabled.
- "hint_range" : Visible range of the hint in world units.
- "hint_auto_start" : When set to 0, the entity no longer has to be triggered to show, line-of-sight will be enough.
- "hint_display_limit" : Number of times this hint can be shown.

# INPUTS
- "Enable" : Enable the entity.
- "Disable" : Disable the entity.
- "Toggle" : Toggles between enabled/disabled states.

# TRIVIA
This entity was introduced in Left 4 Dead 2 (2009).

@ingroup sharedentity
@ingroup pointentity
*/
class
env_instructor_hint:ncPointTrigger
{
public:
	void env_instructor_hint(void);

#ifdef SERVER
	virtual void Respawn(void);
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
	PREDICTED_STRING(m_strIcon)
	PREDICTED_STRING(m_strIconOff)
	PREDICTED_STRING(m_strText)
	PREDICTED_VECTOR(m_vecTextColor)
	PREDICTED_BOOL(m_bEnabled)
	NETWORKED_FLOAT(m_flTimeOut)
	NETWORKED_FLOAT(m_flOffset)

#ifdef CLIENT
	bool m_bOldHintState;
	float m_flHintTime;
#endif
};

void
env_instructor_hint::env_instructor_hint(void)
{
	m_strIcon =
	m_strIconOff =
	m_strText = __NULL__;
	m_vecTextColor = [1,1,1];
	m_flTimeOut = 0.0f;
	m_flOffset = 0.0f;
}

#ifdef SERVER
void
env_instructor_hint::Respawn(void)
{
	InitPointTrigger();
	m_bEnabled = false;
}

void
env_instructor_hint::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "hint_icon_onscreen":
		m_strIcon = strValue;
		break;
	case "hint_icon_offscreen":
		m_strIconOff = strValue;
		break;
	case "hint_caption":
		m_strText = strValue;
		break;
	case "hint_color":
		m_vecTextColor = ReadVector(strValue) / 255;
		break;
	case "hint_timeout":
		m_flTimeOut = ReadFloat(strValue);
		break;
	case "hint_icon_offset":
		m_flOffset = ReadFloat(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
env_instructor_hint::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "m_strIcon", m_strIcon);
	SaveString(handle, "m_strIconOff", m_strIconOff);
	SaveString(handle, "m_strText", m_strText);
	SaveVector(handle, "m_vecTextColor", m_vecTextColor);
	SaveFloat(handle, "m_flTimeOut", m_flTimeOut);
	SaveFloat(handle, "m_flOffset", m_flOffset);
}

void
env_instructor_hint::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_strIcon":
		m_strIcon = ReadString(strValue);
		break;
	case "m_strIconOff":
		m_strIconOff = ReadString(strValue);
		break;
	case "m_strText":
		m_strText = ReadString(strValue);
		break;
	case "m_vecTextColor":
		m_vecTextColor = ReadVector(strValue);
		break;
	case "m_flTimeOut":
		m_flTimeOut = ReadFloat(strValue);
		break;
	case "m_flOffset":
		m_flOffset = ReadFloat(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
env_instructor_hint::Trigger(entity act, triggermode_t state)
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
env_instructor_hint::Input(entity eAct, string strInput, string strData)
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
env_instructor_hint::EvaluateEntity(void)
{
	EVALUATE_VECTOR(origin, 0, ENVINSTRUCTOR_CHANGED_ORIGIN)
	EVALUATE_VECTOR(origin, 1, ENVINSTRUCTOR_CHANGED_ORIGIN)
	EVALUATE_VECTOR(origin, 2, ENVINSTRUCTOR_CHANGED_ORIGIN)
	EVALUATE_FIELD(m_strIcon, ENVINSTRUCTOR_CHANGED_IMAGE)
	EVALUATE_FIELD(m_strIconOff, ENVINSTRUCTOR_CHANGED_IMAGE_OFF)
	EVALUATE_FIELD(m_strText, ENVINSTRUCTOR_CHANGED_TEXT)
	EVALUATE_VECTOR(m_vecTextColor, 0, ENVINSTRUCTOR_CHANGED_TEXT_COLOR)
	EVALUATE_VECTOR(m_vecTextColor, 1, ENVINSTRUCTOR_CHANGED_TEXT_COLOR)
	EVALUATE_VECTOR(m_vecTextColor, 2, ENVINSTRUCTOR_CHANGED_TEXT_COLOR)
	EVALUATE_FIELD(m_flTimeOut, ENVINSTRUCTOR_CHANGED_TIMEOUT)
	EVALUATE_FIELD(m_flOffset, ENVINSTRUCTOR_CHANGED_OFFSET)
	EVALUATE_FIELD(m_bEnabled, ENVINSTRUCTOR_CHANGED_STATE)
	pvsflags = PVSF_IGNOREPVS;
}

float
env_instructor_hint::SendEntity(entity ePEnt, float flChanged)
{
	WriteByte(MSG_ENTITY, ENT_INSTRUCTOR);
	WriteFloat(MSG_ENTITY, flChanged);
	SENDENTITY_COORD(origin[0], ENVINSTRUCTOR_CHANGED_ORIGIN)
	SENDENTITY_COORD(origin[1], ENVINSTRUCTOR_CHANGED_ORIGIN)
	SENDENTITY_COORD(origin[2], ENVINSTRUCTOR_CHANGED_ORIGIN)
	SENDENTITY_STRING(m_strIcon, ENVINSTRUCTOR_CHANGED_IMAGE)
	SENDENTITY_STRING(m_strIconOff, ENVINSTRUCTOR_CHANGED_IMAGE_OFF)
	SENDENTITY_STRING(m_strText, ENVINSTRUCTOR_CHANGED_TEXT)
	SENDENTITY_COORD(m_vecTextColor[0], ENVINSTRUCTOR_CHANGED_TEXT_COLOR)
	SENDENTITY_COORD(m_vecTextColor[1], ENVINSTRUCTOR_CHANGED_TEXT_COLOR)
	SENDENTITY_COORD(m_vecTextColor[2], ENVINSTRUCTOR_CHANGED_TEXT_COLOR)
	SENDENTITY_FLOAT(m_flTimeOut, ENVINSTRUCTOR_CHANGED_TIMEOUT)
	SENDENTITY_FLOAT(m_flOffset, ENVINSTRUCTOR_CHANGED_OFFSET)
	SENDENTITY_BYTE(m_bEnabled, ENVINSTRUCTOR_CHANGED_STATE)
	return true;
}
#endif

#ifdef CLIENT
void
env_instructor_hint::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], ENVINSTRUCTOR_CHANGED_ORIGIN)
	READENTITY_COORD(origin[1], ENVINSTRUCTOR_CHANGED_ORIGIN)
	READENTITY_COORD(origin[2], ENVINSTRUCTOR_CHANGED_ORIGIN)
	READENTITY_STRING(m_strIcon, ENVINSTRUCTOR_CHANGED_IMAGE)
	READENTITY_STRING(m_strIconOff, ENVINSTRUCTOR_CHANGED_IMAGE_OFF)
	READENTITY_STRING(m_strText, ENVINSTRUCTOR_CHANGED_TEXT)
	READENTITY_COORD(m_vecTextColor[0], ENVINSTRUCTOR_CHANGED_TEXT_COLOR)
	READENTITY_COORD(m_vecTextColor[1], ENVINSTRUCTOR_CHANGED_TEXT_COLOR)
	READENTITY_COORD(m_vecTextColor[2], ENVINSTRUCTOR_CHANGED_TEXT_COLOR)
	READENTITY_FLOAT(m_flTimeOut, ENVINSTRUCTOR_CHANGED_TIMEOUT)
	READENTITY_FLOAT(m_flOffset, ENVINSTRUCTOR_CHANGED_OFFSET)
	READENTITY_BYTE(m_bEnabled, ENVINSTRUCTOR_CHANGED_STATE)
	setorigin(this, origin);

	if (m_bEnabled != m_bOldHintState) {
		m_flHintTime = m_flTimeOut;
	}
	m_bOldHintState = m_bEnabled;
}

void
env_instructor_hint::postdraw(void)
{
	bool visible = false;
	bool inView = false;
	vector positionValues;

	if (!m_bEnabled)
		return;

	if (m_flHintTime <= 0.0f)
		return;

	/* calculation for the edge positions */
	{
		vector delta;
		vector p2 = g_view.GetCameraOrigin();
		vector ang = g_view.GetCameraAngle();
		float leftValue;
		float upValue;

		makevectors(ang);
		delta = normalize (origin - p2);

		leftValue = delta * v_right;
		upValue = delta * -v_up;

		positionValues[0] = (delta * v_forward);
		positionValues[1] = (leftValue + 1.0f) * 0.5f;
		positionValues[2] = (upValue + 1.0f) * 0.5f;

		if (fabs(leftValue) > fabs(upValue)) {
			/* clamp leftvalue */
			if (positionValues[1] > 0.5)
				positionValues[1] = 1.0f;
			else
				positionValues[1] = 0.0f;
		} else {
			/* clamp upvalue */
			if (positionValues[2] > 0.5)
				positionValues[2] = 1.0f;
			else
				positionValues[2] = 0.0f;
		}

		/* within field of view... */
		if (positionValues[0] > (g_view.GetAFOV()/180)) {
			traceline(p2, origin, MOVE_WORLDONLY, self);

			/* totally visible */
			if (trace_fraction == 1.0) {
				visible = true;
			}

			inView = true;
		}
	}

	vector iconPos;
	vector textPos;
	vector hintPos;
	float textLength = Font_StringWidth(m_strText, true, FONT_CON);
	float sideOffset = textLength + 64.0f;
	float a = (visible == false) ? 0.25 : 1.0f;
	a = 1.0f;

	/* in-world position of the center */
	hintPos = project(origin + [0, m_flOffset]) - [(textLength * 0.5f), 0];

	if (inView == false) {
		hintPos[0] = lerp(32.0f, g_vidsize[0] - sideOffset, positionValues[1]);
		hintPos[1] = lerp(32.0f, g_vidsize[1] - 32.0f, positionValues[2]);
	}

	/* draw the thing */
	iconPos = hintPos - [32, 32];
	textPos = hintPos + [48.0f, 0];
	drawpic(iconPos, m_strIcon, [64, 64], [1,1,1], a);
	Font_DrawText_RGBA(textPos + [1,1], m_strText, [0,0,0], a, FONT_CON);
	Font_DrawText_RGBA(textPos, m_strText, m_vecTextColor, a, FONT_CON);

	m_flHintTime -= clframetime;
}
#endif