void
InitDomination(void)
{
	entity area1 = ents.Create("domination_area", [443, -935, 210] );
	entity area2 = ents.Create("domination_area", [-27, 288, 50] );
	entity area3 = ents.Create("domination_area", [1084, -442, 18] );

	area1.netname = "High";
	area2.netname = "Pillars";
	area3.netname = "Crates";
}

void
CodeCallback_Precache(void)
{
	if (cvars.GetString("g_gametype") == "domination") {
		InitDomination();
	}
}
