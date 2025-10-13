void
InitDomination(void)
{
	ents.Create("domination_area", [-256, 52, 434] );
	ents.Create("domination_area", [418, -432, 370] );
	ents.Create("domination_area", [540, -716, 82] );
}

void
CodeCallback_Precache(void)
{
	if (cvars.GetString("g_gametype") == "domination") {
		InitDomination();
	}
}
