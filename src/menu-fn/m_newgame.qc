/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

CWidget fn_newgame;
CMainButton ng_btnEasy;
CMainButton ng_btnMedium;
CMainButton ng_btnDifficult;
CMainButton ng_btnCancel;

/* Button Callbacks */
void
ng_btneasy_start(void)
{
	static void ng_btneasy_end(void) {
		g_menupage = PAGE_MAIN;
		localcmd("stopmusic\n");
		localcmd("set skill 1; maxplayers 1\n");
		localcmd(games[gameinfo_current].startmap);
	}
	localsound("../media/launch_upmenu1.wav");
	header.SetStartEndPos(45,45,70,208);
	header.SetStartEndSize(460,80,156,26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_NEWGAME);
	header.SetExecute(ng_btneasy_end);
}

void
ng_btnnormal_start(void)
{
	static void ng_btnnormal_end(void) {
		g_menupage = PAGE_MAIN;
		localcmd("stopmusic\n");
		localcmd("set skill 2; maxplayers 1\n");
		localcmd(games[gameinfo_current].startmap);
	}
	localsound("../media/launch_upmenu1.wav");
	header.SetStartEndPos(45,45,70,208);
	header.SetStartEndSize(460,80,156,26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_NEWGAME);
	header.SetExecute(ng_btnnormal_end);
}

void
ng_btnhard_start(void)
{
	static void ng_btnhard_end(void) {
		g_menupage = PAGE_MAIN;
		localcmd("stopmusic\n");
		localcmd("set skill 3; maxplayers 1\n");
		localcmd(games[gameinfo_current].startmap);
	}
	localsound("../media/launch_upmenu1.wav");
	header.SetStartEndPos(45,45,70,208);
	header.SetStartEndSize(460,80,156,26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_NEWGAME);
	header.SetExecute(ng_btnhard_end);
}

void
ng_btncancel_start(void)
{
	static void ng_btncancel_end(void) {
		g_menupage = PAGE_MAIN;
	}
	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(45,45,70,208);
	header.SetStartEndSize(460,80,156,26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_NEWGAME);
	header.SetExecute(ng_btncancel_end);
}

/* Init */
void
menu_newgame_init(void)
{
	fn_newgame = spawn(CWidget);
	ng_btnEasy = spawn(CMainButton);
	ng_btnMedium = spawn(CMainButton);
	ng_btnDifficult = spawn(CMainButton);
	ng_btnCancel = spawn(CMainButton);
	
	ng_btnEasy.SetPos(50,140);
	ng_btnMedium.SetPos(50,172);
	ng_btnDifficult.SetPos(50,204);
	ng_btnCancel.SetPos(50,236);
	
	ng_btnEasy.SetImage(BTN_EASY);
	ng_btnEasy.SetExecute(ng_btneasy_start);
	ng_btnMedium.SetImage(BTN_MEDIUM);
	ng_btnMedium.SetExecute(ng_btnnormal_start);
	ng_btnDifficult.SetImage(BTN_DIFFICULT);
	ng_btnDifficult.SetExecute(ng_btnhard_start);
	ng_btnCancel.SetImage(BTN_CANCEL);
	ng_btnCancel.SetExecute(ng_btncancel_start);
	
	Widget_Add(fn_newgame, ng_btnEasy);
	Widget_Add(fn_newgame, ng_btnMedium);
	Widget_Add(fn_newgame, ng_btnDifficult);
	Widget_Add(fn_newgame, ng_btnCancel);
}

/* Drawing */
void
menu_newgame_draw(void)
{
	Widget_Draw(fn_newgame);
	Header_Draw(HEAD_NEWGAME);

	WLabel_Static(215, 148, m_reslbl[IDS_NEWGAME_EASYHELP], HELPTXT_SIZE, HELPTXT_SIZE, col_help,
					1.0f, 0, font_label);
	WLabel_Static(215, 180, m_reslbl[IDS_NEWGAME_MEDIUMHELP], HELPTXT_SIZE, HELPTXT_SIZE, col_help,
					1.0f, 0, font_label);
	WLabel_Static(215, 212, m_reslbl[IDS_NEWGAME_DIFFICULTHELP], HELPTXT_SIZE, HELPTXT_SIZE, col_help,
					1.0f, 0, font_label);
	WLabel_Static(215, 244, m_reslbl[IDS_NEWGAME_RETURNHELP], HELPTXT_SIZE, HELPTXT_SIZE, col_help,
					1.0f, 0, font_label);
}

void
menu_newgame_input(float evtype, float scanx, float chary, float devid)
{
	Widget_Input(fn_newgame, evtype, scanx, chary, devid);
}
