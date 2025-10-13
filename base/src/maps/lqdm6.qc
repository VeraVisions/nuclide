void
InitDomination(void)
{
	entity area1 = ents.Create("domination_area", [814, -530, 498] );
	entity area2 = ents.Create("domination_area", [-141, 612, 242] );
	entity area3 = ents.Create("domination_area", [2, -2, 626] );

	area1.netname = "Crates";
	area2.netname = "Arches";
	area3.netname = "Top";
}

void
CodeCallback_Precache(void)
{
	if (cvars.GetString("g_gametype") == "domination") {
		InitDomination();
	}
}
