class monster_human_demoman:CBaseMonster
{
	void() monster_human_demoman;
};

void monster_human_demoman::monster_human_demoman(void)
{
	model = "models/demolitionman.mdl";
	CBaseMonster::CBaseMonster();
}
