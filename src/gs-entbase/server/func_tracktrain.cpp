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

/*QUAKED func_tracktrain (0 .5 .8) ?
"targetname"    Name
"target"        Target when triggered.
"killtarget"    Target to kill when triggered.

Moving platform following along path_* entities that's fully user controlled.
Very unfinished.
*/

class func_tracktrain:CBaseTrigger
{
	float m_flSpeed;

	void(void) func_tracktrain;
	virtual void(void) Find;
	virtual void(void) NextPath;
	virtual void(void) GoToTarget;
	virtual void(int) Trigger;
	virtual void(void) Respawn;
};

void func_tracktrain::GoToTarget(void)
{
	float flTravelTime;
	vector vel_to_pos;
	entity f;

	f = find(world, CBaseTrigger::m_strTargetName, m_strTarget);

	if (!f) {
		dprint(sprintf("^1func_tracktrain::^3GoToTarget^7: Trigger-Target for %s not found! Removing.\n", m_strTargetName));
		return;
	}

	vel_to_pos = (f.origin - origin);
	flTravelTime = (vlen(vel_to_pos) / m_flSpeed);

	if (!flTravelTime) {
		NextPath();
		return;
	}

	velocity = (vel_to_pos * (1 / flTravelTime));
	think = NextPath;
	nextthink = (time + flTravelTime);
}

void func_tracktrain::NextPath(void)
{
	CBaseTrigger current_target;

	current_target = (CBaseTrigger)find(world, CBaseTrigger::m_strTargetName, m_strTarget);

	m_strTarget = current_target.m_strTarget;
	velocity = [0,0,0];
	GoToTarget();
}

void func_tracktrain::Trigger(int state)
{
	GoToTarget();
}


void func_tracktrain::Find(void)
{
	entity f = find(world, CBaseTrigger::m_strTargetName, m_strTarget);

	if (!f) {
		dprint(sprintf("^1func_tracktrain::^3GoToTarget^7: Trigger-Target %s for %s not found! Removing.\n", m_strTarget, m_strTargetName));
		remove(this);
		return;
	}

	SetOrigin(f.origin);
}

void func_tracktrain::Respawn(void)
{
	SetSolid(SOLID_BSP);
	SetMovetype(MOVETYPE_PUSH);
	//blocked = Blocked;

	SetModel(m_oldModel);
	SetOrigin(m_oldOrigin);

	/* Make sure we got some time for the paths to spawn */
	nextthink = ltime + 0.1f;
	think = Find;
}

void func_tracktrain::func_tracktrain(void)
{
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "speed":
			m_flSpeed = stof(argv(i+1));
			break;
		default:
			break;
		}
	}

	//if (!m_flSpeed) {
		m_flSpeed = 50;
	//}

	CBaseTrigger::CBaseTrigger();
}
