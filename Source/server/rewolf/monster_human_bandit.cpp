class monster_human_bandit:CBaseMonster
{
	void() monster_human_bandit;
};

void monster_human_bandit::monster_human_bandit(void)
{
	model = "models/bandit.mdl";
	CBaseMonster::CBaseMonster();
}
