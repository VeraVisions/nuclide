class info_player_teamspawn:CBaseTrigger
{
	int m_iTeam;

	void() info_player_teamspawn;
};

void info_player_teamspawn::info_player_teamspawn(void)
{
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "team_no":
			m_iTeam = stoi(argv(i+1));
			break;
		default:
			break;
		}
	}

	switch (m_iTeam) {
	case 1:
		classname = "info_teamspawn_blue";
		break;
	case 2:
		classname = "info_teamspawn_red";
		break;
	case 3:
		classname = "info_teamspawn_yellow";
		break;
	case 4:
		classname = "info_teamspawn_green";
		break;
	}
}


