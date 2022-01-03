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

/*QUAKED func_mortar_field (0 .5 .8) ?
This brush volume acts as mortar drop area.
When triggered, it'll drop mortar shells straight to the ground (with a bit
of spread if specified).

-------- KEYS --------
"targetname" : Name
"m_flSpread" : Maximum spread in game-units
"m_flCount" : Number of bombs dropped per strike
"m_flControl" : Targeting type. 0 = random, 1 = activator, 2 = controlled
"m_iszXController" : Name of the momentary_rot_button providing X-offset
"m_iszYController" : Name of the momentary_rot_button providing Y-offset

-------- NOTES --------
It can be set to three different targeting modes, 0 will pick any
random point in the volume as a drop position. 1 will target the person or
entity activating it and 2 is a more complex mode which requires two
momentary_rot_button entities to control the X and Y offset in the volume.

GoldSrc expects some hardcoded behaviour (sounds playing, hardcoded delay
between mortar shell drops) that I haven't implemented yet.
I'll turn those into map attribute keys so people can finally control
sound, damage, delay and so on.

-------- TRIVIA --------
This entity was introduced in Half-Life (1998).
*/

class func_mortar_field:NSBrushTrigger
{
	int m_iType;
	int m_iCount;
	float m_flSpread;
	string m_strXController;
	string m_strYController;

	void(void) func_mortar_field;

	virtual void(vector) Fire;
	virtual void(void) FireRandom;
	virtual void(entity) FireTarget;
	virtual void(void) FireControlled;
	virtual void(entity,int) Trigger;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
};

void
func_mortar_field::Fire(vector vecOrg)
{
	/* the spread */
	makevectors([90,0,0]);
	vecOrg[0] += random(-m_flSpread, m_flSpread);
	vecOrg[1] += random(-m_flSpread, m_flSpread);

	/* trace from the sky downwards */
	traceline(vecOrg, vecOrg + (v_forward * 4096), FALSE, this);

	float dmg = 200.0f;
	Damage_Radius(trace_endpos, this, dmg, dmg * 2.5f, TRUE, 0);
	FX_Explosion(trace_endpos);
}

void
func_mortar_field::FireRandom(void)
{
	vector vecPos;

	/* get our center */
	vecPos[0] = absmin[0] + (0.5f * (absmax[0] - absmin[0]));
	vecPos[1] = absmin[1] + (0.5f * (absmax[1] - absmin[1]));
	vecPos[2] = absmin[2] + (0.5f * (absmax[2] - absmin[2]));

	/* now randomize the position in the volume */
	vecPos[0] += mins[0] + (random() * size[0]);
	vecPos[1] += mins[1] + (random() * size[1]);

	for (int i = 0; i < m_iCount; i++);
		Fire(vecPos);
}

void
func_mortar_field::FireTarget(entity act)
{
	vector vecPos;

	/* get our center */
	vecPos[0] = absmin[0] + (0.5f * (absmax[0] - absmin[0]));
	vecPos[1] = absmin[1] + (0.5f * (absmax[1] - absmin[1]));
	vecPos[2] = absmin[2] + (0.5f * (absmax[2] - absmin[2]));

	/* orient towards the nearest player pos, clamping by our bounds */
	vecPos[0] = bound(vecPos[0] + mins[0], act.origin[0], vecPos[0] + maxs[0]);
	vecPos[1] = bound(vecPos[1] + mins[1], act.origin[1], vecPos[1] + maxs[0]);

	for (int i = 0; i < m_iCount; i++);
		Fire(vecPos);
}

void
func_mortar_field::FireControlled(void)
{
	momentary_rot_button mX;
	momentary_rot_button mY;
	vector vecPos;
	entity f;

	mX = mY = __NULL__;

	for (f = world; (f = find(f, ::classname, "momentary_rot_button"));) {
		momentary_rot_button l = (momentary_rot_button) f;

		if (l.targetname == m_strXController) {
			mX = l;
		}

		if (l.targetname == m_strYController) {
			mY = l;
		}
	}

	if (!mX || !mY)
		return;

	/* find our center */
	vecPos[0] = absmin[0] + (0.5f * (absmax[0] - absmin[0]));
	vecPos[1] = absmin[1] + (0.5f * (absmax[1] - absmin[1]));
	vecPos[2] = absmin[2] + (0.5f * (absmax[2] - absmin[2]));

	/* now offset the position to the rot_buttons */
	vecPos[0] += mins[0] + (mX.m_flProgress * size[0]);
	vecPos[1] += mins[1] + (mY.m_flProgress * size[1]);

	for (int i = 0; i < m_iCount; i++);
		Fire(vecPos);
}

void
func_mortar_field::Trigger(entity act, int state)
{
	switch (m_iType) {
	case 0:
		FireRandom();
		break;
	case 1:
		FireTarget(act);
		break;
	case 2:
		FireControlled();
		break;
	default:
		break;
	}
}

void
func_mortar_field::Respawn(void)
{
	InitBrushTrigger();
	ClearAngles();
}

void
func_mortar_field::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iszXController":
		m_strXController = strValue;
		break;
	case "m_iszYController":
		m_strYController = strValue;
		break;
	case "m_flControl":
		m_iType = stoi(strValue);
		break;
	case "m_flCount":
		m_iCount = stoi(strValue);
		break;
	case "m_flSpread":
		m_flSpread = stof(strValue) / 2;
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
func_mortar_field::func_mortar_field(void)
{
	super::NSBrushTrigger();
}
