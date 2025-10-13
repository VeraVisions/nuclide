void
InitDomination(void)
{
	ents.Create("domination_area", [-338, -123, 114] );
	ents.Create("domination_area", [618, -1290, 66] );
	ents.Create("domination_area", [942, 576, 304] );
}

void
CodeCallback_Precache(void)
{
	if (cvars.GetString("g_gametype") == "domination") {
		InitDomination();
	}
}
