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

static int g_pointMessages;

/*! \brief Client-Entity: In-world Debug Text */
/*!QUAKED point_message (0.2 1 0.2) (-8 -8 -8) (8 8 8)
# OVERVIEW
Client-side overlay/message that is projected in relation to its position
in 3D space.

# KEYS
- "message" : The message to display.
- "radius" : The radius in which it will appear.

# NOTES
Used for zoo and test maps in which less interactive overlays are desired.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).

@ingroup cliententity
@ingroup pointentity
*/
class point_message:ncEntity
{
public:
	void point_message(void);
	virtual void SpawnKey(string, string);
	virtual bool CanSpawn(bool);

private:
	float m_flRadius;
	string m_strMessage;
};

void
point_message::SpawnKey(string strField, string strKey)
{
	switch (strField) {
		case "radius":
			m_flRadius = stof(strKey);
			break;
		case "message":
			m_strMessage = strKey;
			break;
		case "origin":
			origin = stov(strKey);
			setorigin(this, origin);
			break;
		default:
			super::SpawnKey(strField, strKey);
	}
}

void
point_message::point_message(void)
{
	g_pointMessages += 1i;
	m_flRadius = 512;
	m_strMessage = "No message";
	isCSQC = true;
}

bool
point_message::CanSpawn(bool clientSide)
{
	return true;
}

bool
PointMessage_Visible(vector p1, vector p2, vector ang)
{
	vector delta;
	float fov;

	if (distance2D(p1, p2) > 512) {
		return (false);
	}

	makevectors(ang);
	delta = normalize (p1 - p2);
	fov = delta * v_forward;

	if (fov > 0.3) {
		traceline(p2, p1, MOVE_WORLDONLY, self);
		if (trace_fraction == 1.0) {
			return (true);
		}
	}
	return (false);
}

void
PointMessage_Draw(void)
{
	vector vecPlayer;

	if (g_pointMessages <= 0i) {
		return;
	}

	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];
	vecPlayer = pSeat->m_vecPredictedOrigin;

	string msg;
	float distance;
	for (entity eFind = world; (eFind = find(eFind, ::classname, "point_message"));) {
		point_message m = (point_message)eFind;
		msg = m.m_strMessage;
		distance = vlen(m.origin - vecPlayer);

		if (distance > m.m_flRadius) {
			continue;
		}

		if (PointMessage_Visible(m.origin, vecPlayer, getproperty(VF_ANGLES)) == true) {
			vector vTemp = project(m.origin) - [(stringwidth(msg, FALSE,[12,12]) / 2), 0];
			Font_DrawText(vTemp, msg, FONT_CON);
		}
	}
}

void
PointMessage_StringAtPos(vector org, string message)
{
	vector vecPlayer;

	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];
	vecPlayer = pSeat->m_vecPredictedOrigin;

	vector vTemp = project(org) - [(stringwidth(message, FALSE,[12,12]) / 2), 0];
	Font_DrawText_RGB(vTemp + [1,1], message, [0,0,0], FONT_CON);
	Font_DrawText(vTemp, message, FONT_CON);
}


void
PointMessage_FieldAtPos(vector org, string message, float width)
{
	vector vecPlayer;

	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];
	vecPlayer = pSeat->m_vecPredictedOrigin;

	vector vTemp = project(org) - [(width / 2), 0];
	Font_DrawField(vTemp + [1,1], [width, g_hudres[1]],strcat("^x000", message), FONT_CON, AF_DEFAULT);
	Font_DrawField(vTemp, [width, g_hudres[1]], message, FONT_CON, AF_DEFAULT);
}
