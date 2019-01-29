/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

class monster_rat:CBaseEntity
{
	void() monster_rat;
};

void monster_rat::monster_rat(void)
{
	CBaseEntity::CBaseEntity();
	precache_model("models/bigrat.mdl");
	solid = SOLID_SLIDEBOX;
	movetype = MOVETYPE_WALK;
	setmodel(this, "models/bigrat.mdl");
	setorigin(this, origin);
}
