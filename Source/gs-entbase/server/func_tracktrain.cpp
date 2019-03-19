/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

class func_tracktrain:CBaseTrigger
{
	float m_flSpeed;

	void() func_tracktrain;
	virtual void() Find;
	virtual void() NextPath;
	virtual void() GoToTarget;
	virtual void() Trigger;
	virtual void() Respawn;
};

void func_tracktrain::GoToTarget(void)
{
	float flTravelTime;
	vector vel_to_pos;
	entity f;

	f = find(world, CBaseTrigger::m_strTargetName, m_strTarget);

	if (!f) {
		print("^1func_tracktrain^7: Trigger-Target not found! Removing.\n");
		return;
	}

	vel_to_pos = (f.origin - origin);
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

void func_tracktrain::NextPath(void)
{
	CBaseTrigger current_target;

	print(sprintf("^2func_tracktrain^7: Talking to current target %s... ", m_strTarget));
	current_target = (CBaseTrigger)find(world, CBaseTrigger::m_strTargetName, m_strTarget);

	if (!current_target) {
		print("^1FAILED.\n");
	} else {
		print("^2SUCCESS.\n");
	}

	m_strTarget = current_target.m_strTarget;
	velocity = [0,0,0];
	GoToTarget();
}

void func_tracktrain::Trigger(void)
{
	GoToTarget();
}


void func_tracktrain::Find(void)
{
	entity f = find(world, CBaseTrigger::m_strTargetName, m_strTarget);

	if (!f) {
		print(sprintf("^1func_tracktrain^7: End-Target %s not found! Removing.\n",m_strTarget));
		remove(this);
		return;
	}

	print("^2func_tracktrain^7: Successfully found first target.\n");
	setorigin(this, f.origin);
}

void func_tracktrain::Respawn(void)
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

void func_tracktrain::func_tracktrain(void)
{
	for ( int i = 1; i < ( tokenize( __fullspawndata ) - 1 ); i += 2 ) {
		switch ( argv( i ) ) {
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
	Respawn();
}
