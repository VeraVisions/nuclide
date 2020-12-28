
void
Way_Init(void)
{
	/* main waypoint menu */
	{
		titles_t way_text;
		way_text.m_strName = "WAY_MENU";
		way_text.m_strMessage = "1.\tAdd Waypoint\n" \
								"2.\tAdd Chain Waypoint\n" \
								"3.\tAdd Spawnpoint Waypoints\n" \
								"4.\tDelete Closest Waypoint\n" \
								"5.\tConnect Two Waypoints\n" \
								"6.\tAdd One-Way Last-To-New\n" \
								"7.\tSave File\n" \
								"8.\tLoad File\n" \
								"9.\tExit\n";
		way_text.m_flPosX = 0;
		way_text.m_flPosY = -1;
		Titles_AddEntry(way_text);
	}
}

void
WAY_MENU(int n)
{
	switch (n) {
	case 1:
		localcmd("sv way add\n");
		break;
	case 2:
		localcmd("sv way addchain\n");
		break;
	case 3:
		localcmd("sv way addspawns\n");
		break;
	case 4:
		localcmd("sv way delete\n");
		break;
	case 5:
		localcmd("sv way connect\n");
		break;
	case 6:
		localcmd("sv way addltn\n");
		break;
	case 7:
		localcmd(sprintf("sv way save %s.way\n", mapname));
		Textmenu_Call("");
		break;
	case 8:
		localcmd(sprintf("sv way load %s.way\n", mapname));
		Textmenu_Call("");
		break;
	case 9:
		Textmenu_Call("");
		break;
	}
} 
