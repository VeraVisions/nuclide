void
InitDomination(void)
{
	ents.Create("domination_area", [-559, -560, -398] );
	ents.Create("domination_area", [-215, 312, -526] );
	ents.Create("domination_area", [226, 736, -90] );
}

void
CodeCallback_Precache(void)
{
	if (cvars.GetString("g_gametype") == "domination") {
		InitDomination();
	}
}
