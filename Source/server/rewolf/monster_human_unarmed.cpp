class monster_human_unarmed:CBaseMonster
{
	void() monster_human_unarmed;
};

void monster_human_unarmed::monster_human_unarmed(void)
{
	model = "models/gunmantrooper.mdl";
	CBaseMonster::CBaseMonster();
}
