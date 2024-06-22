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

#define WAYPOINT_METER 52.49344f

enumflags
{
	INFWAY_CHANGED_ORIGIN,
	INFWAY_CHANGED_IMAGE,
	INFWAY_CHANGED_TEXT,
	INFWAY_CHANGED_STATE
};

/*! \brief Shared-Entity: Objective/Waypoint Hint */
/*!QUAKED info_waypoint (0 1 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
When active, will display an icon and text at its position that can be seen
by players.

# KEYS
- "targetname" : Name
- "Image" : Path of the material that the game will use for the icon.
- "Text" : A localised string to display next to it.

# INPUTS
- "Enable" : Enable the entity.
- "Disable" : Disable the entity.
- "Toggle" : Toggles between enabled/disabled states.

# TRIVIA
This entity was introduced in Obsidian Conflict (2006).

@ingroup shared
@ingroup pointentity
*/
class
info_waypoint:NSPointTrigger
{
public:
	void info_waypoint(void);

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
	PREDICTED_STRING(m_strIcon)
	PREDICTED_STRING(m_strText)
	PREDICTED_BOOL(m_bEnabled)
};

void
info_waypoint::info_waypoint(void)
{
	m_strIcon =
	m_strText = __NULL__;
}

#ifdef SERVER
void
info_waypoint::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "image":
		m_strIcon = strValue;
		break;
	case "text":
		m_strText = strValue;
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
info_waypoint::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "m_strIcon", m_strIcon);
	SaveString(handle, "m_strText", m_strText);
}

void
info_waypoint::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_strIcon":
		m_strIcon = ReadString(strValue);
		break;
	case "m_strText":
		m_strText = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
info_waypoint::Trigger(entity act, triggermode_t state)
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
info_waypoint::Input(entity eAct, string strInput, string strData)
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
info_waypoint::EvaluateEntity(void)
{
	EVALUATE_VECTOR(origin, 0, INFWAY_CHANGED_ORIGIN)
	EVALUATE_VECTOR(origin, 1, INFWAY_CHANGED_ORIGIN)
	EVALUATE_VECTOR(origin, 2, INFWAY_CHANGED_ORIGIN)
	EVALUATE_FIELD(m_strIcon, INFWAY_CHANGED_IMAGE)
	EVALUATE_FIELD(m_strText, INFWAY_CHANGED_TEXT)
	EVALUATE_FIELD(m_bEnabled, INFWAY_CHANGED_STATE)
	pvsflags = PVSF_IGNOREPVS;
}

float
info_waypoint::SendEntity(entity ePEnt, float flChanged)
{
	WriteByte(MSG_ENTITY, ENT_WAYPOINT);
	WriteFloat(MSG_ENTITY, flChanged);
	SENDENTITY_COORD(origin[0], INFWAY_CHANGED_ORIGIN)
	SENDENTITY_COORD(origin[1], INFWAY_CHANGED_ORIGIN)
	SENDENTITY_COORD(origin[2], INFWAY_CHANGED_ORIGIN)
	SENDENTITY_STRING(m_strIcon, INFWAY_CHANGED_IMAGE)
	SENDENTITY_STRING(m_strText, INFWAY_CHANGED_TEXT)
	SENDENTITY_BYTE(m_bEnabled, INFWAY_CHANGED_STATE)
	return true;
}
#endif

#ifdef CLIENT
void
info_waypoint::ReceiveEntity(float flNew, float flChanged)
{
	READENTITY_COORD(origin[0], INFWAY_CHANGED_ORIGIN)
	READENTITY_COORD(origin[1], INFWAY_CHANGED_ORIGIN)
	READENTITY_COORD(origin[2], INFWAY_CHANGED_ORIGIN)
	READENTITY_STRING(m_strIcon, INFWAY_CHANGED_IMAGE)
	READENTITY_STRING(m_strText, INFWAY_CHANGED_TEXT)
	READENTITY_BYTE(m_bEnabled, INFWAY_CHANGED_STATE)
	setorigin(this, origin);
}

void
info_waypoint::postdraw(void)
{
	static float
	drawicon_visible(vector p1) {
		vector delta;
		float fov;
		vector p2 = g_view.GetCameraOrigin();
		vector ang = g_view.GetCameraAngle();

		makevectors(ang);
		delta = normalize (p1 - p2);
		fov = delta * v_forward;

		/* within field of view... */
		if (fov > (g_view.GetAFOV()/180)) {
			traceline(p2, p1, MOVE_WORLDONLY, self);
			if (trace_fraction == 1.0) {
				return (1);
			} else {
				return (2);
			}
		}
		return (0);
	}

	float visible;

	if (!m_bEnabled)
		return;

	visible = drawicon_visible(origin);

	if (drawicon_visible(origin) != 0) {
		float textLength = Font_StringWidth(m_strText, true, FONT_CON);
		vector vecProj = project(origin) - [32, 32];
		vector projectedPos = project(origin) + [-(textLength/2), 48];
		float a = (visible == 2) ? 0.25 : 1.0f;
		float dist = vlen(origin - g_view.GetCameraOrigin()) / WAYPOINT_METER;
		string distText = sprintf("Distance: %d m", dist);

		drawpic(vecProj, m_strIcon, [64, 64], [1,1,1], a);

		Font_DrawText_RGBA(projectedPos + [1,1], distText, [0,0,0], a, FONT_CON);
		Font_DrawText_RGBA(projectedPos, distText, [1,1,1], a, FONT_CON);

		projectedPos[1] += Font_GetHeight(FONT_CON);

		Font_DrawText_RGBA(projectedPos + [1,1], m_strText, [0,0,0], a, FONT_CON);
		Font_DrawText_RGBA(projectedPos, m_strText, [1,1,1], a, FONT_CON);
	}
}
#endif