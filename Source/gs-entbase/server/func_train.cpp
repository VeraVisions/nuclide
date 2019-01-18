/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

class func_train:CBaseTrigger
{
	float m_flSpeed;

	void() func_train;
	virtual void() Find;
	virtual void() MoveEnd;
	virtual void() Trigger;
};

void func_train::Find(void)
{
	entity f = find(world, CBaseTrigger::m_strTargetName, m_strTarget);

	if (!f) {
		print("^1func_train^7: End-Target not found! Removing.\n");
		remove(this);
		return;
	}

	print("^2func_train^7: Successfully found first target.\n");

	vector vecWorldPos;
	vecWorldPos[0] = absmin[0] + ( 0.5 * ( absmax[0] - absmin[0] ) );	
	vecWorldPos[1] = absmin[1] + ( 0.5 * ( absmax[1] - absmin[1] ) );	
	vecWorldPos[2] = absmin[2] + ( 0.5 * ( absmax[2] - absmin[2] ) );

	vecWorldPos = f.origin - vecWorldPos;
	setorigin(this, vecWorldPos);
}

void func_train::MoveEnd(void)
{
	CBaseTrigger f = (CBaseTrigger)find(world, CBaseTrigger::m_strTargetName, m_strTarget);
	m_strTarget = f.m_strTargetName;

	velocity = [0,0,0];
}

void func_train::Trigger(void)
{

	entity f = find(world, CBaseTrigger::m_strTargetName, m_strTarget);

	if (!f) {
		print("^1func_train^7: Trigger-Target not found! Removing.\n");
		return;
	}
	
	vector vecWorldPos;
	vecWorldPos[0] = absmin[0] + ( 0.5 * ( absmax[0] - absmin[0] ) );	
	vecWorldPos[1] = absmin[1] + ( 0.5 * ( absmax[1] - absmin[1] ) );	
	vecWorldPos[2] = absmin[2] + ( 0.5 * ( absmax[2] - absmin[2] ) );
	
	vector vecDifference = (f.origin - vecWorldPos);
	float flTravel = vlen(vecDifference);
	float flTravelTime = (flTravel / m_flSpeed);

	think = MoveEnd;
	nextthink = (time + flTravelTime);

	print(sprintf("TRAIN %s SPEED: %v\n", this.classname, (vecDifference * (1 / flTravelTime))));
	
	//velocity = (vecDifference * (1 / flTravelTime));
}

void func_train::func_train(void)
{
	CBaseTrigger::CBaseTrigger();

	for ( int i = 1; i < ( tokenize( __fullspawndata ) - 1 ); i += 2 ) {
		switch ( argv( i ) ) {
		case "speed":
			m_flSpeed = stof(argv(i+1));
			break;
		default:
			break;
		}
	}

	solid = SOLID_BSP;
	movetype = MOVETYPE_PUSH;
	//blocked = Blocked;

	setmodel(this, m_oldModel);
	setorigin(this, m_oldOrigin);

	// start trains on the second frame, to make sure their targets have had
	// a chance to spawn
	nextthink = time + 0.25f;
	think = Find;
}
