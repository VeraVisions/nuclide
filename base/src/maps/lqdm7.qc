void
InitDomination(void)
{
	ents.Create("domination_area", [346, -728, 162] );
	ents.Create("domination_area", [12, 448, -14] );
	ents.Create("domination_area", [385, 270, 306] );
}

void
CodeCallback_Precache(void)
{
	if (cvars.GetString("g_gametype") == "domination") {
		InitDomination();
	}
}
