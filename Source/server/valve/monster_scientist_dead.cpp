/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

enum {
	DSCIA_LYING1 = 37,
	DSCIA_LYING2,
	DSCIA_DEADSIT,
	DSCIA_DEADTABLE1,
	DSCIA_DEADTABLE2,
	DSCIA_DEADTABLE3,
	DSCIA_DEADHANG
};

class monster_scientist_dead:CBaseEntity
{
	int m_iPose;
	void() monster_scientist_dead;

	virtual void() Hide;
	virtual void() Respawn;
	virtual void(int) vPain;
	virtual void(int) vDeath;
	virtual void() Gib;
};

void monster_scientist_dead::Gib(void)
{
	takedamage = DAMAGE_NO;
	Effect_GibHuman(this.origin);
	Hide();
}

void monster_scientist_dead::vPain(int iHitBody)
{

}

void monster_scientist_dead::vDeath(int iHitBody)
{
	if (health < -50) {
		Gib();
		return;
	}
}

void monster_scientist_dead::Hide(void)
{
	setmodel(this, "");
	solid = SOLID_NOT;
	movetype = MOVETYPE_NONE;
}

void monster_scientist_dead::Respawn(void)
{
	v_angle[0] = Math_FixDelta(m_oldAngle[0]);
	v_angle[1] = Math_FixDelta(m_oldAngle[1]);
	v_angle[2] = Math_FixDelta(m_oldAngle[2]);

	setorigin(this, m_oldOrigin);
	angles = v_angle;
	solid = SOLID_CORPSE;
	movetype = MOVETYPE_NONE;
	setmodel(this, m_oldModel);
	setsize(this, VEC_HULL_MIN + [0,0,36], VEC_HULL_MAX + [0,0,36]);
	takedamage = DAMAGE_YES;
	health = 0;
	velocity = [0,0,0];
	iBleeds = TRUE;
	
	switch (m_iPose) {
	case 1:
		frame = DSCIA_LYING2;
		break;
	case 2:
		frame = DSCIA_DEADSIT;
		break;
	case 3:
		frame = DSCIA_DEADHANG;
		break;
	case 4:
		frame = DSCIA_DEADTABLE1;
		break;
	case 5:
		frame = DSCIA_DEADTABLE2;
		break;
	case 6:
		frame = DSCIA_DEADTABLE3;
		break;
	default:
		frame = DSCIA_LYING1;
	}
}

void monster_scientist_dead::monster_scientist_dead(void)
{
	model = "models/scientist.mdl";
	
	for (int i = 1; i < (tokenize(__fullspawndata)-1); i += 2) {
		switch (argv(i)) {
		case "pose":
			m_iPose = stoi(argv(i+1));
		default:
			break;
		}
	}
	
	CBaseEntity::CBaseEntity();
	precache_model(m_oldModel);
	Respawn();
}
