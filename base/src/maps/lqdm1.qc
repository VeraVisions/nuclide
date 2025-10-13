void
InitDomination(void)
{
	entity area1 = ents.Create("domination_area", [542, -1206, 146] );
	entity area2 = ents.Create("domination_area", [-272, 174, 114] );
	entity area3 = ents.Create("domination_area", [1036, 424, 146] );

	area1.netname = "Podium";
	area2.netname = "Steps";
	area3.netname = "Inside";
}

void
CodeCallback_Precache(void)
{
	if (cvars.GetString("g_gametype") == "domination") {
		InitDomination();
	}
}
