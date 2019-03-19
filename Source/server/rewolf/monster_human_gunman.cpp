class monster_human_gunman:CBaseMonster
{
	void() monster_human_gunman;
};

void monster_human_gunman::monster_human_gunman(void)
{
	model = "models/gunmantrooper.mdl";
	CBaseMonster::CBaseMonster();
}
