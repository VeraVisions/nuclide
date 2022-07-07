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

#define FN_UPDATE_IMGURL "http://www.frag-net.com/dl/img/%s.jpg"

#ifndef WEBMENU
enum
{
	GPMI_NAME,		// name of the package, for use with the pkg command.
	GPMI_CATEGORY,		// category text
	GPMI_TITLE,		// name of the package, for showing the user.
	GPMI_VERSION,		// version info (may have multiple with the same name but different versions)
	GPMI_DESCRIPTION,	// some blurb
	GPMI_LICENSE,		// what license its distributed under
	GPMI_AUTHOR,		// name of the person(s) who created it
	GPMI_WEBSITE,		// where to contribute/find out more info/etc
	GPMI_INSTALLED,		// current state
	GPMI_ACTION,		// desired state
	GPMI_AVAILABLE,		// whether it may be downloaded or not.
	GPMI_FILESIZE,		// size to download.
};

string(int, int) getpackagemanagerinfo = #0;

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
	int pkgid;

	pkgid = up_lbUpdates.GetSelected();
	localcmd(sprintf("pkg add %s\n", updates[pkgid].name));
	updates[pkgid].installed = "pending";
	print(sprintf("Marking package %s for install.\n", updates[pkgid].title));
}

void
up_btnremove_start(void)
{
	int pkgid;

	pkgid = up_lbUpdates.GetSelected();
	localcmd(sprintf("pkg rem %s\n", updates[pkgid].name));
	updates[pkgid].installed = "rem";
	print(sprintf("Marking package %s for 'removal'.\n", updates[pkgid].title));
}

void
up_toggleinstall(void)
{
	int pkgid;
	pkgid = up_lbUpdates.GetSelected();

	switch (updates[pkgid].installed) {
	case "":
	case "rem":
		localcmd(sprintf("pkg add %s\n", updates[pkgid].name));
		updates[pkgid].installed = "pending";
		break;
	default:
		localcmd(sprintf("pkg rem %s\n", updates[pkgid].name));
		updates[pkgid].installed = "rem";
	}
}

void
up_btnapply_start(void)
{
	cvar_set("menu_updating", "1");
	localcmd("pkg apply\n");
	print("Applying package changes.\n");
}

void
up_lbupdates_changed(void)
{
	int pkgid;
	string newpic;

	pkgid = up_lbUpdates.GetSelected();

	if (!pkgid)
		return;

	newpic = sprintf(FN_UPDATE_IMGURL, updates[pkgid].name);
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
	int c;
	update_count = 0;

	if (updates) {
		memfree(updates);
	}

#if 0
	for (int i = 0; (getpackagemanagerinfo(i, GPMI_NAME)); i++) {
		string cat = getpackagemanagerinfo(i, GPMI_CATEGORY);
		if (cat == "Plugins/") {
			continue;
		}
		if (cat == "Mod/") {
			continue;
		}
		update_count++;
	}
#else
	/* look for the valid packages in the gameinfo pkgname */
	int pkgcount = tokenize(games[gameinfo_current].pkgname);
	for (int i = 0i; i < pkgcount; i++) {
		int id = game_getpackageid(argv(i));
		if (id == -1)
			continue;

		update_count++;
	}
#endif

	c = 0;
	updates = memalloc(sizeof(update_t) * update_count);

#if 0
	for (int i = 0; (getpackagemanagerinfo(i, GPMI_NAME)); i++) {
		string cat = getpackagemanagerinfo(i, GPMI_CATEGORY);
		if (cat == "Plugins/") {
			continue;
		}
		if (cat == "Mod/") {
			continue;
		}

		updates[c].name = getpackagemanagerinfo(i, GPMI_NAME);
		updates[c].category = getpackagemanagerinfo(i, GPMI_CATEGORY);
		updates[c].title = getpackagemanagerinfo(i, GPMI_TITLE);
		updates[c].version = getpackagemanagerinfo(i, GPMI_VERSION);
		updates[c].description = getpackagemanagerinfo(i, GPMI_DESCRIPTION);
		updates[c].license = getpackagemanagerinfo(i, GPMI_LICENSE);
		updates[c].author = getpackagemanagerinfo(i, GPMI_AUTHOR);
		updates[c].website = getpackagemanagerinfo(i, GPMI_WEBSITE);
		updates[c].installed = getpackagemanagerinfo(i, GPMI_INSTALLED);
		updates[c].size = (int)stof(getpackagemanagerinfo(i, GPMI_FILESIZE));
		updates[c].uid = i;
		precache_pic(sprintf(FN_UPDATE_IMGURL, updates[c].name));

		c++;
	}
#else
	for (int i = 0i; i < pkgcount; i++) {
		int id = game_getpackageid(argv(i));

		if (id == -1)
			continue;

		updates[c].name = getpackagemanagerinfo(id, GPMI_NAME);
		updates[c].category = getpackagemanagerinfo(id, GPMI_CATEGORY);
		updates[c].title = getpackagemanagerinfo(id, GPMI_TITLE);
		updates[c].version = getpackagemanagerinfo(id, GPMI_VERSION);
		updates[c].description = getpackagemanagerinfo(id, GPMI_DESCRIPTION);
		updates[c].license = getpackagemanagerinfo(id, GPMI_LICENSE);
		updates[c].author = getpackagemanagerinfo(id, GPMI_AUTHOR);
		updates[c].website = getpackagemanagerinfo(id, GPMI_WEBSITE);
		updates[c].installed = getpackagemanagerinfo(id, GPMI_INSTALLED);
		updates[c].size = (int)stof(getpackagemanagerinfo(id, GPMI_FILESIZE));
		updates[c].uid = id;
		precache_pic(sprintf(FN_UPDATE_IMGURL, updates[c].name));

		c++;
	}
#endif

	up_sbUpdates.SetMax(update_count);
	up_lbUpdates.SetMax(update_count);
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
		for (int i = 0; (getpackagemanagerinfo(i, GPMI_NAME)); i++) {
			string installed = getpackagemanagerinfo(i, GPMI_INSTALLED);
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
