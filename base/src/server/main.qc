void
Game_Worldspawn(void)
{

}

void
Game_InitRules(void)
{
	if (cvar("sv_playerslots") == 1 || cvar("coop") == 1) {
		g_grMode = ncGameRules::InitFromProgs("progs/singleplayer.dat");
	} else {
		g_grMode = ncGameRules::InitFromProgs("progs/deathmatch.dat");
	}
}
