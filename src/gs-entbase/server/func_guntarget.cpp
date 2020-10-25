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

/*QUAKED func_guntarget (0 .5 .8) ?
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.
"health"        Health until it stops and triggers its targets.
"speed"         Speed in units per second at which it moves.

Gun targets brushes that trigger a target once they 'die'.

Trivia:
This entity was introduced in Half-Life (1998).
*/

#define SF_GUNTARGET_ON 1

class func_guntarget:CBaseTrigger
{
	float m_flSpeed;
	string m_strFire;

	void(void) func_guntarget;
	
	virtual void(void) Respawn;
	virtual void(void) NextPath;
	virtual void(void) Move;
	virtual void(void) Stop;
	virtual void(entity act, int) Trigger;
	virtual void(void) Death;
	virtual void(string, string) SpawnKey;
};

void
func_guntarget::Move(void)
{
	float flTravelTime;
	vector vel_to_pos;
	path_corner node;

	node = (path_corner)find(world, ::targetname, target);

	if (!node) {
		dprint(sprintf("^1func_guntarget::^3Move^7: Path node for %s not found!\n", targetname));
		return;
	}

	vector vecWorldPos;
	vecWorldPos[0] = absmin[0] + (0.5 * (absmax[0] - absmin[0]));
	vecWorldPos[1] = absmin[1] + (0.5 * (absmax[1] - absmin[1]));
	vecWorldPos[2] = absmin[2] + (0.5 * (absmax[2] - absmin[2]));

	vel_to_pos = (node.origin - vecWorldPos);
	flTravelTime = (vlen(vel_to_pos) / m_flSpeed);

	if (!flTravelTime) {
		NextPath();
		return;
	}

	velocity = (vel_to_pos * (1 / flTravelTime));
	think = NextPath;
	nextthink = (ltime + flTravelTime);
}

void
func_guntarget::NextPath(void)
{
	path_corner node;

	print(sprintf("^2func_guntarget::^3NextPath^7: Talking to current target %s... ", target));
	node = (path_corner)find(world, ::targetname, target);

	if (!node) {
		print("^1FAILED.\n");
	} else {
		print("^2SUCCESS.\n");
	}

	target = node.target;
	velocity = [0,0,0];

	if (target) {
		Move();
	}
}

void
func_guntarget::Death(void)
{
	entity a;
	Stop();

	if (!m_strFire) {
		return;
	}

	for (a = world; (a = find(a, ::targetname, m_strFire));) {
		CBaseTrigger trigger = (CBaseTrigger)a;
		trigger.Trigger(g_dmg_eAttacker, TRIG_TOGGLE);
	}
}

void
func_guntarget::Stop(void)
{
	takedamage = DAMAGE_NO;
	velocity = [0,0,0];
	nextthink = 0;
	think = __NULL__;
}

/* TODO: Handle state? */
void
func_guntarget::Trigger(entity act, int state)
{
	flags = (1 << FL_FROZEN) | flags;

	if (flags & FL_FROZEN) {
		takedamage = DAMAGE_NO;
		Stop();
		m_iValue = 1;
	} else {
		takedamage = DAMAGE_YES;
		NextPath();
		m_iValue = 0;
	}
}

void
func_guntarget::Respawn(void)
{
	static void ThinkWrap(void) {
		Trigger(this, TRIG_TOGGLE);
	}

	SetSolid(SOLID_BSP);
	SetMovetype(MOVETYPE_PUSH);
	SetModel(m_oldModel);
	SetOrigin(m_oldOrigin);

	if (spawnflags & SF_GUNTARGET_ON) {
		think = ThinkWrap;
		nextthink = ltime + 0.25f;
	}
}

void
func_guntarget::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "health":
		health = stof(strValue);
		break;
	case "speed":
		m_flSpeed = stof(strValue);
		break;
	case "message":
		m_strFire = strValue;
		break;
	default:
		CBaseTrigger::SpawnKey(strKey, strValue);
	}
}

void func_guntarget::func_guntarget(void)
{
	m_flSpeed = 100;
	CBaseTrigger::CBaseTrigger();
}
