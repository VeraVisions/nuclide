/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

class monster_human_chopper:CBaseEntity
{
	void() monster_human_chopper;
};

void monster_human_chopper::monster_human_chopper(void)
{
	model = "models/chopper.mdl";
	CBaseEntity::CBaseEntity();
	setmodel(this, m_oldModel);
	setorigin(this, origin);
}
