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


#ifndef WEBMENU
var int g_updates_initialized = FALSE;
var int autocvar_menu_updating = FALSE;

CWidget fn_updates;
CMainButton up_btnDone;
CMainButton up_btnApply;
CMainButton up_btnInstall;
CMainButton up_btnDelete;
CUpdateList up_lbUpdates;
CFrame up_frUpdates;
CFrame up_frPreview;
CScrollbar up_sbUpdates;

var string g_updates_previewpic;

/* Button Callbacks */
void
up_btndone_start(void)
{
	cvar_set("menu_updating", "0");
	localsound("../media/launch_dnmenu1.wav");
	g_menupage = PAGE_CONFIGURATION;
	localcmd("pkg revert;seta menu_installedpackages 1;cfg_save\n");
}

void
up_btninstall_start(void)
{
	Updates_Install(up_lbUpdates.GetSelected());
}

void
up_btnremove_start(void)
{
	Updates_Destroy(up_lbUpdates.GetSelected());
}

void
up_toggleinstall(void)
{
	Updates_Toggle(up_lbUpdates.GetSelected());
}

void
up_btnapply_start(void)
{
	Updates_ApplyPendingChanges();
}

void
up_lbupdates_changed(void)
{
	int pkgid;
	string newpic;

	pkgid = up_lbUpdates.GetSelected();

	if (pkgid == -1)
		return;

	newpic = Updates_GetInfo(pkgid, UPDATE_PREVIEWIMAGE);

	if not (newpic)
		return;

	g_updates_previewpic = newpic;
	precache_pic(g_updates_previewpic);
}

void
up_sbupdates_changed(int val)
{
	up_lbUpdates.SetScroll(val);
}

void
menu_updates_refresh(void)
{
	int updateCount = Updates_GetPackageCount();

	up_sbUpdates.SetMax(updateCount);
	up_lbUpdates.SetMax(updateCount);
	up_lbUpdates.SetSelected(0);
}
#endif

/* Init */
void
menu_updates_init(void)
{
#ifndef WEBMENU
	fn_updates = spawn(CWidget);

	up_btnDone = spawn(CMainButton);
	up_btnDone.SetImage(BTN_DONE);
	up_btnDone.SetExecute(up_btndone_start);
	up_btnDone.SetPos(50,420+13);
	Widget_Add(fn_updates, up_btnDone);

	up_btnApply = spawn(CMainButton);
	up_btnApply.SetImage(BTN_UPDATE);
	up_btnApply.SetExecute(up_btnapply_start);
	up_btnApply.SetPos(50 + 160,420+13);
	Widget_Add(fn_updates, up_btnApply);

	up_btnInstall = spawn(CMainButton);
	up_btnInstall.SetImage(BTN_INSTALL);
	up_btnInstall.SetExecute(up_btninstall_start);
	up_btnInstall.SetPos(380,400);
	Widget_Add(fn_updates, up_btnInstall);

	up_btnDelete = spawn(CMainButton);
	up_btnDelete.SetImage(BTN_DELETE);
	up_btnDelete.SetExecute(up_btnremove_start);
	up_btnDelete.SetPos(380,400+30);
	Widget_Add(fn_updates, up_btnDelete);

	up_frUpdates = spawn(CFrame);
	up_frUpdates.SetPos(50,160);
	up_frUpdates.SetSize(200+50,250);
	Widget_Add(fn_updates, up_frUpdates);
	
	up_lbUpdates = spawn(CUpdateList);
	up_lbUpdates.SetPos(53,163);
	up_lbUpdates.SetSize(194+50,244);
	up_lbUpdates.SetChanged(up_lbupdates_changed);
	up_lbUpdates.SetDClicked(up_toggleinstall);
	Widget_Add(fn_updates, up_lbUpdates);
	
	up_sbUpdates = spawn(CScrollbar);
	up_sbUpdates.SetPos(53+194+50,160);
	up_sbUpdates.SetItemheight(18);
	up_sbUpdates.SetHeight(250);
	up_sbUpdates.SetCallback(up_sbupdates_changed);
	up_sbUpdates.SetMax(0);
	Widget_Add(fn_updates, up_sbUpdates);

	up_frPreview = spawn(CFrame);
	up_frPreview.SetPos(350,160);
	up_frPreview.SetSize(256+6,128+6);
	Widget_Add(fn_updates, up_frPreview);
#endif
}


void
menu_updates_draw(void)
{
#ifndef WEBMENU
	float fl = 0;

	/* first draw run */
	if (g_updates_initialized == 0) {
		Updates_Init();
		g_updates_initialized = 2;
		return;
	}

	updaterStatus_t status = Updates_GetUpdaterStatus();

	Header_Draw(HEAD_CONFIG);

	/* we're still initializing... */
	if (g_updates_initialized == 2) {
		if (status == UPDATER_PENDING) {
			customgame_dlgWait.Draw();
			WField_Static(162, 180, "Contacting update server...", 320, 260,
						col_prompt_text, 1.0f, 2, font_label_p);
			return;
		} else if (status == UPDATER_INITIALIZED) {
			menu_updates_refresh();
			g_updates_initialized = 1;
		}
	}

	Widget_Draw(fn_updates);
	drawpic([g_menuofs[0]+550,g_menuofs[1]+10], g_bmp[FN_LOGO],[80,80], [1,1,1], 1.0f, 0);

	WLabel_Static(50, 143, "Data files:", 11, 11, [1,1,1],
					1.0f, 0, font_arial);

	fl = 310;
	WLabel_Static(350,fl, "Author:", 11, 11, [1,1,1],
					1.0f, 0, font_arial);
	fl += 18;
	WLabel_Static(350,fl, "Status:", 11, 11, [1,1,1],
					1.0f, 0, font_arial);
	fl += 18;
	WLabel_Static(350,fl, "License:", 11, 11, [1,1,1],
					1.0f, 0, font_arial);
	fl += 18;
	WLabel_Static(350,fl, "Website:", 11, 11, [1,1,1],
					1.0f, 0, font_arial);
	fl += 18;
	WLabel_Static(350,fl, "Version:", 11, 11, [1,1,1],
					1.0f, 0, font_arial);

	int i = up_lbUpdates.GetSelected();

	fl = 310;
	WLabel_Static(420,fl, Updates_GetInfo(i, UPDATE_AUTHOR), 11, 11, [1,1,1],
					1.0f, 0, font_arial); fl += 18;
	WLabel_Static(420,fl, Updates_GetInfo(i, UPDATE_STATUSSTRING), 11, 11, [1,1,1],
					1.0f, 0, font_arial); fl += 18;
	WLabel_Static(420,fl, Updates_GetInfo(i, UPDATE_LICENSE), 11, 11, [1,1,1],
					1.0f, 0, font_arial); fl += 18;
	WLabel_Static(420,fl, Updates_GetInfo(i, UPDATE_WEBSITE), 11, 11, [1,1,1],
					1.0f, 0, font_arial); fl += 18;
	WLabel_Static(420,fl, Updates_GetInfo(i, UPDATE_VERSION), 11, 11, [1,1,1],
					1.0f, 0, font_arial);

	WLabel_Static(350, 143, "Preview:", 11, 11, [1,1,1],
					1.0f, 0, font_arial);

	if (g_updates_previewpic)
	drawpic([g_menuofs[0]+350+3,g_menuofs[1]+160+3], g_updates_previewpic, [256,128], [1,1,1], 1.0f);
#endif
}

void
menu_updates_input(float evtype, float scanx, float chary, float devid)
{
#ifndef WEBMENU
	Widget_Input(fn_updates, evtype, scanx, chary, devid);
#endif
}
