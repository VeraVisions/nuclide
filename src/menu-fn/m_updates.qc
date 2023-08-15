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
	localcmd("seta menu_installedpackages 1;cfg_save\n");
}

void
up_btninstall_start(void)
{
	Updates_Remove(up_lbUpdates.GetSelected());
}

void
up_btnremove_start(void)
{
	Updates_Install(up_lbUpdates.GetSelected());
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

	newpic = sprintf(FN_UPDATE_IMGURL, updates[pkgid].name);

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
	Updates_Refresh();
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
	up_btnApply.SetPos(350+96,420+30);
	Widget_Add(fn_updates, up_btnApply);

	up_btnInstall = spawn(CMainButton);
	up_btnInstall.SetImage(BTN_INSTALL);
	up_btnInstall.SetExecute(up_btninstall_start);
	up_btnInstall.SetPos(350,420);
	Widget_Add(fn_updates, up_btnInstall);

	up_btnDelete = spawn(CMainButton);
	up_btnDelete.SetImage(BTN_DELETE);
	up_btnDelete.SetExecute(up_btnremove_start);
	up_btnDelete.SetPos(350+200,420);
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

	Updates_Refresh();
#endif
}


/* Drawing */
int g_pkgname_updating;
void
menu_updates_draw(void)
{
#ifndef WEBMENU
	static int old_enabled;

	float fl = 0;

	if (!g_updates_initialized) {
		int pkg_ready = 0;

		/* we have no hard-coded list of supported packages, so query frag-net.com */
		if (!games[gameinfo_current].pkgname && !g_pkgname_updating) {
			string gamedir = games[gameinfo_current].gamedir;
			print(sprintf("Querying package names for %s\n", gamedir));
			uri_get(sprintf("http://www.frag-net.com/dl/packages_%s", uri_escape(gamedir)), MODSERVER_REQ_PKGNAMES);
			g_pkgname_updating = 1;
		}

		/* don't query packages YET until we get a response */
		if (g_pkgname_updating == 1) {
			return;
		}

		/* query until 1 package is ready */
		for (int i = 0; (Updates_GetInfo(i, GPMI_NAME)); i++) {
			string installed = Updates_GetInfo(i, GPMI_INSTALLED);
			/* increment to keep track */
			if (installed == "enabled")
				old_enabled++;

			pkg_ready = 1;
		}

		if (pkg_ready == 1) {
			menu_updates_refresh();
			g_updates_initialized = TRUE;
		}
		return;
	}

	Widget_Draw(fn_updates);
	Header_Draw(HEAD_CONFIG);

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
	i = updates[i].uid;
	fl = 310;
	WLabel_Static(420,fl, getpackagemanagerinfo(i, GPMI_AUTHOR), 11, 11, [1,1,1],
					1.0f, 0, font_arial); fl += 18;
	WLabel_Static(420,fl, getpackagemanagerinfo(i, GPMI_INSTALLED), 11, 11, [1,1,1],
					1.0f, 0, font_arial); fl += 18;
	WLabel_Static(420,fl, getpackagemanagerinfo(i, GPMI_LICENSE), 11, 11, [1,1,1],
					1.0f, 0, font_arial); fl += 18;
	WLabel_Static(420,fl, getpackagemanagerinfo(i, GPMI_WEBSITE), 11, 11, [1,1,1],
					1.0f, 0, font_arial); fl += 18;
	WLabel_Static(420,fl, getpackagemanagerinfo(i, GPMI_VERSION), 11, 11, [1,1,1],
					1.0f, 0, font_arial);

	WLabel_Static(350, 143, "Preview:", 11, 11, [1,1,1],
					1.0f, 0, font_arial);

	/* check if we've got any more packages than upon init */
	int new_packages = 0;
	for (int b = 0; (getpackagemanagerinfo(b, GPMI_NAME)); b++) {
		string installed = getpackagemanagerinfo(b, GPMI_INSTALLED);

		/* increment to keep track */
		if (installed == "enabled")
			new_packages++;
	}

	if (old_enabled != new_packages) {
		old_enabled = new_packages;
		localcmd("menu_restart\nmenu_updates\n");
	}

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
