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

/*! \brief Server-Entity: Mortar Drop Zone */
/*!QUAKED func_mortar_field (0 .5 .8) ?
# OVERVIEW
This brush volume acts as mortar drop area.
When triggered, it'll drop mortar shells straight to the ground (with a bit
of spread if specified).

# KEYS
- "targetname" : Name
- "m_flSpread" : Maximum spread in game-units
- "m_flCount" : Number of bombs dropped per strike
- "m_flControl" : Targeting type. 0 = random, 1 = activator, 2 = controlled
- "m_iszXController" : Name of the momentary_rot_button providing X-offset
- "m_iszYController" : Name of the momentary_rot_button providing Y-offset

# NOTES
It can be set to three different targeting modes, 0 will pick any
random point in the volume as a drop position. 1 will target the person or
entity activating it and 2 is a more complex mode which requires two
momentary_rot_button entities to control the X and Y offset in the volume.

GoldSrc expects some hardcoded behaviour (sounds playing, hardcoded delay
between mortar shell drops) that I haven't implemented yet.
I'll turn those into map attribute keys so people can finally control
sound, damage, delay and so on.

# TRIVIA
This entity was introduced in Half-Life (1998).

@ingroup server
@ingroup brushentity
*/
class
func_mortar_field:NSBrushTrigger
{
public:
	void func_mortar_field(void);
	
	/* overrides */
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Trigger(entity, triggermode_t);
	virtual void Respawn(void);
	virtual void SpawnKey(string,string);
	
	nonvirtual void Fire(entity, vector);
	nonvirtual void FireRandom(entity);
	nonvirtual void FireTarget(entity);
	nonvirtual void FireControlled(entity);

private:
	int m_iType;
	int m_iCount;
	float m_flSpread;
	string m_strXController;
	string m_strYController;
};

void
func_mortar_field::func_mortar_field(void)
{
	m_iType = 0i;
	m_iCount = 0i;
	m_flSpread = 0.0f;
	m_strXController = __NULL__;
	m_strYController = __NULL__;
}

void
func_mortar_field::Save(float handle)
{
	super::Save(handle);
	SaveInt(handle, "m_iType", m_iType);
	SaveInt(handle, "m_iCount", m_iCount);
	SaveFloat(handle, "m_flSpread", m_flSpread);
	SaveString(handle, "m_strXController", m_strXController);
	SaveString(handle, "m_strYController", m_strYController);
}

void
func_mortar_field::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iType":
		m_iType = ReadInt(strValue);
		break;
	case "m_iCount":
		m_iCount = ReadInt(strValue);
		break;
	case "m_flSpread":
		m_flSpread = ReadFloat(strValue);
		break;
	case "m_strXController":
		m_strXController = ReadString(strValue);
		break;
	case "m_strYController":
		m_strYController = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
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
	case "m_fControl":
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
func_mortar_field::Respawn(void)
{
	InitBrushTrigger();
	ClearAngles();
}

void
func_mortar_field::Fire(entity firingEnt, vector vecOrg)
{
	/* the spread */
	makevectors([90,0,0]);
	vecOrg[0] += random(-m_flSpread, m_flSpread);
	vecOrg[1] += random(-m_flSpread, m_flSpread);

	/* trace from the sky downwards */
	traceline(vecOrg, vecOrg + (v_forward * 4096), FALSE, this);

	int maxDamage = 200i;
	float damageRadius = (float)maxDamage * 2.5f;
	radiusDamage(trace_endpos, damageRadius, 0i, maxDamage, this);
	pointparticles(particleeffectnum("fx_explosion.main"), trace_endpos, [0,0,0], 1);
}

void
func_mortar_field::FireRandom(entity act)
{
	vector vecPos;

	/* get our center */
	vecPos = WorldSpaceCenter();

	/* now randomize the position in the volume */
	vecPos[0] += mins[0] + (random() * size[0]);
	vecPos[1] += mins[1] + (random() * size[1]);

	for (int i = 0; i < m_iCount; i++);
		Fire(act, vecPos);
}

void
func_mortar_field::FireTarget(entity act)
{
	vector vecPos;

	/* get our center */
	vecPos = WorldSpaceCenter();

	/* orient towards the nearest player pos, clamping by our bounds */
	vecPos[0] = bound(vecPos[0] + mins[0], act.origin[0], vecPos[0] + maxs[0]);
	vecPos[1] = bound(vecPos[1] + mins[1], act.origin[1], vecPos[1] + maxs[0]);

	for (int i = 0; i < m_iCount; i++);
		Fire(act, vecPos);
}

void
func_mortar_field::FireControlled(entity act)
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
	vecPos = WorldSpaceCenter();

	/* now offset the position to the rot_buttons */
	vecPos[0] += mins[0] + (mX.GetProgress() * size[0]);
	vecPos[1] += mins[1] + (mY.GetProgress() * size[1]);

	for (int i = 0; i < m_iCount; i++);
		Fire(act, vecPos);
}

void
func_mortar_field::Trigger(entity act, triggermode_t state)
{
	switch (m_iType) {
	case 0:
		FireRandom(act);
		break;
	case 1:
		FireTarget(act);
		break;
	case 2:
		FireControlled(act);
		break;
	default:
		break;
	}
}
