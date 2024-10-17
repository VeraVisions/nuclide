void
Game_Worldspawn(void)
{

}

void
Game_InitRules(void)
{
	if (cvar("sv_playerslots") == 1 || cvar("coop") == 1) {
		g_grMode = NSGameRules::InitFromProgs("progs/singleplayer.dat");
	} else {
		g_grMode = NSGameRules::InitFromProgs("progs/deathmatch.dat");
	}
}
