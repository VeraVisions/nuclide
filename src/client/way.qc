/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

void
Way_Init(void)
{
	/* main waypoint menu */
	{
		titles_t way_menu;
		way_menu.m_strName = "WAY_MENU";
		way_menu.m_strMessage = "1.\tAdd...\n" \
								"2.\tLink/Unlink...\n" \
								"3.\tRemove...\n" \
								"4.\tLink Flags...\n" \
								"5.\tRadius Settings...\n" \
								"6.\tAuto-Link Settings...\n" \
								"7.\tMove waypoint...\n" \
								"8.\tSave/Load...\n" \
								"9.\tExit\n";
		way_menu.m_flPosX = 0;
		way_menu.m_flPosY = -1;
		Titles_AddEntry(way_menu);
	}
	/* add waypoint menu */
	{
		titles_t way_file;
		way_file.m_strName = "WAY_FILE";
		way_file.m_strMessage = "1.\tSave current file (data/mapname.way)\n" \
								"\n" \
								"\n" \
								"4.\tLoad file (data/mapname.way)\n" \
								"\n" \
								"\n" \
								"\n" \
								"\n" \
								"9.\tBack\n";
		way_file.m_flPosX = 0;
		way_file.m_flPosY = -1;
		Titles_AddEntry(way_file);
	}
	/* add waypoint menu */
	{
		titles_t way_add;
		way_add.m_strName = "WAY_ADD";
		way_add.m_strMessage = "1.\tAdd ^1Single^7 Waypoint\n" \
								"2.\tAdd ^1Chain^7 Waypoint^7 (last-to-new)\n" \
								"3.\tAdd ^1Autolink^7 Waypoint\n" \
								"4.\tAdd ^1Spawnpoint^7 Waypoints\n" \
								"\n" \
								"\n" \
								"7.\tRemove nearest\n" \
								"\n" \
								"9.\tBack\n";
		way_add.m_flPosX = 0;
		way_add.m_flPosY = -1;
		Titles_AddEntry(way_add);
	}
	/* add waypoint menu */
	{
		titles_t way_link;
		way_link.m_strName = "WAY_LINK";
		way_link.m_strMessage = "1.\tLink 2-way (2 steps)\n" \
								"2.\tLink 1-way (2 steps)\n" \
								"\n" \
								"\n" \
								"\n" \
								"\n" \
								"7.\tAutolink closest\n" \
								"\n" \
								"9.\tBack\n";
		way_link.m_flPosX = 0;
		way_link.m_flPosY = -1;
		Titles_AddEntry(way_link);
	}
	/* add waypoint menu */
	{
		titles_t way_remove;
		way_remove.m_strName = "WAY_REMOVE";
		way_remove.m_strMessage = "\n" \
								"\n" \
								"\n" \
								"\n" \
								"\n" \
								"\n" \
								"7.\t^1DANGER^7: Remove ^1ALL\n" \
								"\n" \
								"9.\tBack\n";
		way_remove.m_flPosX = 0;
		way_remove.m_flPosY = -1;
		Titles_AddEntry(way_remove);
	}
	/* add waypoint menu */
	{
		titles_t way_flags;
		way_flags.m_strName = "WAY_FLAGS";
		way_flags.m_strMessage = "1.\tFlag ^3JUMP^7 (2 steps)\n" \
								"2.\tFlag ^2CROUCH^7 (2 steps)\n" \
								"3.\tFlag ^1WALK^7 (2 steps)\n" \
								"4.\tFlag ^4AIM^7 (2 steps)\n" \
								"5.\tFlag ^4USE^7 (2 steps)\n" \
								"\n" \
								"\n" \
								"\n" \
								"9.\tBack\n";
		way_flags.m_flPosX = 0;
		way_flags.m_flPosY = -1;
		Titles_AddEntry(way_flags);
	}
	/* add waypoint menu */
	{
		titles_t way_radius;
		way_radius.m_strName = "WAY_RADIUS";
		way_radius.m_strMessage = "1.\tSet closest way-radius (0)\n" \
								"2.\tSet closest way-radius (8)\n" \
								"3.\tSet closest way-radius (16)\n" \
								"4.\tSet closest way-radius (32)\n" \
								"5.\tSet closest way-radius (48)\n" \
								"6.\tSet closest way-radius (64)\n" \
								"7.\tSet closest way-radius (128)\n" \
								"\n" \
								"9.\tBack\n";
		way_radius.m_flPosX = 0;
		way_radius.m_flPosY = -1;
		Titles_AddEntry(way_radius);
	}
	/* add waypoint menu */
	{
		titles_t way_text;
		way_text.m_strName = "WAY_AUTOLINK";
		way_text.m_strMessage = "1.\tDefault radius (256)\n" \
								"2.\t32 radius\n" \
								"3.\t64 radius\n" \
								"4.\t128 radius\n" \
								"5.\t512 radius\n" \
								"6.\t768 radius\n" \
								"7.\t1024 radius\n" \
								"\n" \
								"9.\tBack\n";
		way_text.m_flPosX = 0;
		way_text.m_flPosY = -1;
		Titles_AddEntry(way_text);
	}
	/* add waypoint menu */
	{
		titles_t way_move;
		way_move.m_strName = "WAY_MOVE";
		way_move.m_strMessage = "1.\tMove nearest +1 X-axis\n" \
								"2.\tMove nearest -1 X-axis\n" \
								"3.\tMove nearest +1 Y-axis\n" \
								"4.\tMove nearest -1 Y-axis\n" \
								"5.\tMove nearest +1 Z-axis\n" \
								"6.\tMove nearest -1 Z-axis\n" \
								"\n" \
								"8.\tMove nearest to player-position\n" \
								"9.\tBack\n";
		way_move.m_flPosX = 0;
		way_move.m_flPosY = -1;
		Titles_AddEntry(way_move);
	}
}

void
WAY_MENU(int n)
{
	switch (n) {
	case 1:
		Textmenu_Call("WAY_ADD");
		break;
	case 2:
		Textmenu_Call("WAY_LINK");
		break;
	case 3:
		Textmenu_Call("WAY_REMOVE");
		break;
	case 4:
		Textmenu_Call("WAY_FLAGS");
		break;
	case 5:
		Textmenu_Call("WAY_RADIUS");
		break;
	case 6:
		Textmenu_Call("WAY_AUTOLINK");
		break;
	case 7:
		Textmenu_Call("WAY_MOVE");
		break;
	case 8:
		Textmenu_Call("WAY_FILE");
		break;
	case 9:
		Textmenu_Call("");
		break;
	}
}

var int g_waymenu_opened = 0;
void
Way_Autoload(void)
{
	if (!g_waymenu_opened && autocvar(way_autoload, 1))
		localcmd(sprintf("sv way load %s.way\n", mapname));
	g_waymenu_opened = 1;
}

void
WAY_FILE(int n)
{
	switch (n) {
	case 1:
		localcmd(sprintf("sv way save %s.way\n", mapname));
		Textmenu_Call("WAY_MENU");
		break;
	case 4:
		localcmd(sprintf("sv way load %s.way\n", mapname));
		Textmenu_Call("WAY_MENU");
		break;
	case 9:
		Textmenu_Call("WAY_MENU");
		break;
	}
}


void
WAY_ADD(int n)
{
	switch (n) {
	case 1:
		localcmd("sv way addsingle\n");
		break;
	case 2:
		localcmd("sv way addchain\n");
		break;
	case 3:
		localcmd("sv way add\n");
		break;
	case 4:
		localcmd("sv way addspawns\n");
		break;
	case 7:
		localcmd("sv way delete\n");
		break;
	case 9:
		Textmenu_Call("WAY_MENU");
		break;
	}
}

void
WAY_LINK(int n)
{
	switch (n) {
	case 1:
		localcmd("sv way connect2\n");
		break;
	case 2:
		localcmd("sv way connect1\n");
		break;
	case 7:
		localcmd("sv way autolink\n");
		break;
	case 9:
		Textmenu_Call("WAY_MENU");
		break;
	}
}

void
WAY_FLAGS(int n)
{
	switch (n) {
	case 1:
		localcmd("sv way linkjump\n");
		break;
	case 2:
		localcmd("sv way linkcrouch\n");
		break;
	case 3:
		localcmd("sv way linkwalk\n");
		break;
	case 4:
		localcmd("sv way linkaim\n");
		break;
	case 5:
		localcmd("sv way linkuse\n");
		break;
	case 9:
		Textmenu_Call("WAY_MENU");
		break;
	}
}

void
WAY_REMOVE(int n)
{
	switch (n) {
	case 7:
		localcmd("sv way purge\n");
		Textmenu_Call("WAY_MENU");
		break;
	case 9:
		Textmenu_Call("WAY_MENU");
		break;
	}
}

void
WAY_AUTOLINK(int n)
{
	switch (n) {
	case 1:
		localcmd("nav_linksize 256\n");
		break;
	case 2:
		localcmd("nav_linksize 32\n");
		break;
	case 3:
		localcmd("nav_linksize 48\n");
		break;
	case 4:
		localcmd("nav_linksize 64\n");
		break;
	case 5:
		localcmd("nav_linksize 512\n");
		break;
	case 6:
		localcmd("nav_linksize 768\n");
		break;
	case 7:
		localcmd("nav_linksize 1024\n");
		break;
	case 9:
		Textmenu_Call("WAY_MENU");
		break;
	}
}

void
WAY_RADIUS(int n)
{
	switch (n) {
	case 1:
		localcmd("sv way radius 0\n");
		break;
	case 2:
		localcmd("sv way radius 8\n");
		break;
	case 3:
		localcmd("sv way radius 16\n");
		break;
	case 4:
		localcmd("sv way radius 32\n");
		break;
	case 5:
		localcmd("sv way radius 48\n");
		break;
	case 6:
		localcmd("sv way radius 64\n");
		break;
	case 7:
		localcmd("sv way radius 128\n");
		break;
	case 9:
		Textmenu_Call("WAY_MENU");
		break;
	}
}

void
WAY_MOVE(int n)
{
	switch (n) {
	case 1:
		localcmd("sv way move 1 0 0\n");
		break;
	case 2:
		localcmd("sv way move -1 0 0\n");
		break;
	case 3:
		localcmd("sv way move 0 1 0\n");
		break;
	case 4:
		localcmd("sv way move 0 -1 0\n");
		break;
	case 5:
		localcmd("sv way move 0 0 1\n");
		break;
	case 6:
		localcmd("sv way move 0 0 -1\n");
		break;
	case 8:
		localcmd("sv way movetopos\n");
		break;
	case 9:
		Textmenu_Call("WAY_MENU");
		break;
	}
}
