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

class func_train:CBaseTrigger
{
	float m_flSpeed;

	void() func_train;
	virtual void() Find;
	virtual void() NextPath;
	virtual void() GoToTarget;
	virtual void() Trigger;
	virtual void() Respawn;
};

void func_train::GoToTarget(void)
{
	float flTravelTime;
	vector vel_to_pos;
	entity f;

	f = find(world, CBaseTrigger::m_strTargetName, m_strTarget);

	if (!f) {
		print("^1func_train^7: Trigger-Target not found! Removing.\n");
		return;
	}

	vector vecWorldPos;
	vecWorldPos[0] = absmin[0] + (0.5 * (absmax[0] - absmin[0]));	
	vecWorldPos[1] = absmin[1] + (0.5 * (absmax[1] - absmin[1]));	
	vecWorldPos[2] = absmin[2] + (0.5 * (absmax[2] - absmin[2]));

	vel_to_pos = (f.origin - vecWorldPos);
	flTravelTime = (vlen(vel_to_pos) / m_flSpeed);

	if (!flTravelTime) {
		NextPath();
		print(sprintf("TRAIN %s SPEED: %f\n", m_strTargetName, flTravelTime));
		return;
	}

	velocity = (vel_to_pos * (1 / flTravelTime));
	think = NextPath;
	nextthink = (time + flTravelTime);
}

void func_train::NextPath(void)
{
	CBaseTrigger current_target;

	print(sprintf("^2func_train^7: Talking to current target %s... ", m_strTarget));
	current_target = (CBaseTrigger)find(world, CBaseTrigger::m_strTargetName, m_strTarget);

	if (!current_target) {
		print("^1FAILED.\n");
	} else {
		print("^2SUCCESS.\n");
	}

	m_strTarget = current_target.m_strTarget;
	velocity = [0,0,0];

	if (m_strTarget) {
		GoToTarget();
	}
}

void func_train::Trigger(void)
{
	GoToTarget();
}


void func_train::Find(void)
{
	entity f = find(world, CBaseTrigger::m_strTargetName, m_strTarget);

	if (!f) {
		print(sprintf("^1func_train^7: End-Target %s not found! Removing.\n",m_strTarget));
		remove(this);
		return;
	}

	print("^2func_train^7: Successfully found first target.\n");
	vector vecWorldPos;
	vecWorldPos[0] = absmin[0] + (0.5 * (absmax[0] - absmin[0]));	
	vecWorldPos[1] = absmin[1] + (0.5 * (absmax[1] - absmin[1]));	
	vecWorldPos[2] = absmin[2] + (0.5 * (absmax[2] - absmin[2]));

	vecWorldPos = f.origin - vecWorldPos;
	setorigin(this, vecWorldPos);
}

void func_train::Respawn(void)
{
	solid = SOLID_BSP;
	movetype = MOVETYPE_PUSH;
	//blocked = Blocked;

	setmodel(this, m_oldModel);
	setorigin(this, m_oldOrigin);

	/* Make sure we got some time for the paths to spawn */
	nextthink = ltime + 0.1f;
	think = Find;
}

void func_train::func_train(void)
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

	if (!m_flSpeed) {
		m_flSpeed = 100;
	}

	CBaseTrigger::CBaseTrigger();
	Respawn();
}
