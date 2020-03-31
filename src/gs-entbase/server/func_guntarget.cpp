/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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
*/

#define SF_GUNTARGET_ON 1

class func_guntarget:CBaseTrigger
{
	float m_flSpeed;
	string m_strFire;

	void() func_guntarget;
	
	virtual void() Respawn;
	virtual void() NextPath;
	virtual void() Move;
	virtual void() Stop;
	virtual void() Trigger;
	virtual void(int) Death;
	virtual int() GetValue;
};

int func_guntarget::GetValue(void)
{
	if (health <= 0) {
		return TRUE;
	} else {
		return FALSE;
	}
}

void func_guntarget::Move(void)
{
	float flTravelTime;
	vector vel_to_pos;
	path_corner node;

	node = (path_corner)find(world, CBaseTrigger::m_strTargetName, m_strTarget);

	if (!node) {
		dprint(sprintf("^1func_guntarget::^3Move^7: Path node for %s not found!\n", m_strTargetName));
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

void func_guntarget::NextPath(void)
{
	path_corner node;

	print(sprintf("^2func_guntarget::^3NextPath^7: Talking to current target %s... ", m_strTarget));
	node = (path_corner)find(world, path_corner::m_strTargetName, m_strTarget);

	if (!node) {
		print("^1FAILED.\n");
	} else {
		print("^2SUCCESS.\n");
	}

	m_strTarget = node.m_strTarget;
	velocity = [0,0,0];

	if (m_strTarget) {
		Move();
	}
}

void func_guntarget::Death(int iHitBody)
{
	entity a;
	Stop();

	if (!m_strFire) {
		return;
	}

	for (a = world; (a = find(a, CBaseTrigger::m_strTargetName, m_strFire));) {
		CBaseTrigger trigger = (CBaseTrigger)a;
		trigger.Trigger();
	}
}

void func_guntarget::Stop(void)
{
	takedamage = DAMAGE_NO;
	velocity = [0,0,0];
	nextthink = 0;
	think = __NULL__;
}

void func_guntarget::Trigger(void)
{
	flags = (1<<FL_FROZEN) | flags;

	if (flags & FL_FROZEN) {
		takedamage = DAMAGE_NO;
		Stop();
	} else {
		takedamage = DAMAGE_YES;
		NextPath();
	}
}

void func_guntarget::Respawn(void)
{
	solid = SOLID_BSP;
	movetype = MOVETYPE_PUSH;
	setmodel(this, m_oldModel);
	setorigin(this, m_oldOrigin);

	if (spawnflags & SF_GUNTARGET_ON) {
		think = Trigger;
		nextthink = ltime + 0.25f;
	}
}

void func_guntarget::func_guntarget(void)
{
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "health":
			health = stof(argv(i+1));
			break;
		case "speed":
			m_flSpeed = stof(argv(i+1));
			break;
		case "message":
			m_strFire = argv(i+1);
			break;
		default:
			break;
		}
	}

	if (!m_flSpeed) {
		m_flSpeed = 100;
	}

	CBaseTrigger::CBaseTrigger();
}
