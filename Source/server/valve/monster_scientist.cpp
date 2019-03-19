/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

class monster_scientist:CBaseMonster
{
	void() monster_scientist;
};

void monster_scientist::monster_scientist(void)
{
	model = "models/scientist.mdl";
	CBaseMonster::CBaseMonster();
}
