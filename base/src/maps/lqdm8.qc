void
InitDomination(void)
{
	ents.Create("domination_area", [112, -458, 626] );
	ents.Create("domination_area", [70, -148, 242] );
	ents.Create("domination_area", [-138, 334, 434] );
}

void
CodeCallback_Precache(void)
{
	if (cvars.GetString("g_gametype") == "domination") {
		InitDomination();
	}
}
