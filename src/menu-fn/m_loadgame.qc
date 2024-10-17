/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

CWidget fn_loadgame;
CMainButton lg_btnLoad;
CMainButton lg_btnDelete;
CMainButton lg_btnCancel;
CScrollbar lg_sbSaves;
CListBox lg_lbSaves;
CFrame lg_frSaves;
CFrame lg_frPreview;

void
lg_btnload(void)
{
	int i = lg_lbSaves.GetSelected();
	localcmd(sprintf("load %s\n", Saves_GetInfo(i, SAVEINFO_NAME)));
}

void
lg_btnunsave(void)
{
	int i = lg_lbSaves.GetSelected();
	localcmd(sprintf("unsavegame %s\n", Saves_GetInfo(i, SAVEINFO_NAME)));
}

void
lg_btncancel_start(void)
{
	static void lg_btncancel_end(void) {
		g_menupage = PAGE_MAIN;
	}
	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(45,45,70,292);
	header.SetStartEndSize(460,80,156,26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_LOAD);
	header.SetExecute(lg_btncancel_end);
}

void
lg_lbsaves_changed(int val)
{

}
void
up_sbsaves_changed(int val)
{
	lg_lbSaves.SetScroll(val);
}





void
menu_loadgame_refreshsaves(void)
{
	lg_lbSaves.Clear();

	for (int i = 0; i < Saves_GetSaveCount(); i++) {
		lg_lbSaves.AddEntry(Saves_GetInfo(i, SAVEINFO_NAME));
	}

	lg_lbSaves.SetSelected(0, TRUE);
}

void
menu_loadgame_init(void)
{
	fn_loadgame = spawn(CWidget);

	lg_btnLoad = spawn(CMainButton);
	lg_btnLoad.SetImage(BTN_LOADGAME);
	lg_btnLoad.SetExecute(lg_btnload);
	lg_btnLoad.SetPos(50,140);
	Widget_Add(fn_loadgame, lg_btnLoad);

	lg_btnDelete = spawn(CMainButton);
	lg_btnDelete.SetImage(BTN_DELETE);
	lg_btnDelete.SetExecute(lg_btnunsave);
	lg_btnDelete.SetPos(50,172);
	Widget_Add(fn_loadgame, lg_btnDelete);

	lg_btnCancel = spawn(CMainButton);
	lg_btnCancel.SetImage(BTN_CANCEL);
	lg_btnCancel.SetExecute(lg_btncancel_start);
	lg_btnCancel.SetPos(50,204);
	Widget_Add(fn_loadgame, lg_btnCancel);

	lg_frSaves = spawn(CFrame);
	lg_frSaves.SetPos(200,140);
	lg_frSaves.SetSize(100+50,250);
	Widget_Add(fn_loadgame, lg_frSaves);

	lg_lbSaves = spawn(CListBox);
	lg_lbSaves.SetPos(203,143);
	lg_lbSaves.SetSize(94+50,244);
	lg_lbSaves.SetChanged(lg_lbsaves_changed);
	Widget_Add(fn_loadgame, lg_lbSaves);

	lg_sbSaves = spawn(CScrollbar);
	lg_sbSaves.SetPos(203+94+50,140);
	lg_sbSaves.SetItemheight(15);
	lg_sbSaves.SetHeight(250);
	lg_sbSaves.SetCallback(up_sbsaves_changed);
	lg_sbSaves.SetMax(0);
	Widget_Add(fn_loadgame, lg_sbSaves);

	lg_frPreview = spawn(CFrame);
	lg_frPreview.SetPos(390,140);
	lg_frPreview.SetSize(220,165);
	Widget_Add(fn_loadgame, lg_frPreview);

	menu_loadgame_refreshsaves();
}

void
menu_loadgame_draw(void)
{
	Widget_Draw(fn_loadgame);
	Header_Draw(HEAD_LOAD);

	if (!g_savegame_count) {
		return;
	}

	int i = lg_lbSaves.GetSelected();
	drawpic([g_menuofs[0]+390,g_menuofs[1]+140], Saves_GetInfo(i, SAVEINFO_PREVIEW),[220,165], [1,1,1], 1.0f, 1);
}

void
menu_loadgame_input(float evtype, float scanx, float chary, float devid)
{
	Widget_Input(fn_loadgame, evtype, scanx, chary, devid);
}
