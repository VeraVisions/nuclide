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

var bool g_initialized = false;

#define FN_UPDATE_PKGLIST "http://www.frag-net.com/dl/%s_packages"

const string LICENSE_TEXT = "\
==============================================================================\
Copyright (c) 2016-2022 Marco Cawthorne <marco@vera-visions.com>\
\
Permission to use, copy, modify, and distribute this software for any\
purpose with or without fee is hereby granted, provided that the above\
copyright notice and this permission notice appear in all copies.\
\
THE SOFTWARE IS PROVIDED \"AS IS\" AND THE AUTHOR DISCLAIMS ALL WARRANTIES\
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF\
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR\
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES\
WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER\
IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING\
OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.\
==============================================================================";

/* r_autoscale forces vid_conautoscale to be one of 4 integer values.
 * this is due to vid_conautoscale 0 scaling with in floating point... which
 * in turns results in skipped rows/columns and shimmering. */
var int autocvar_r_autoscale = TRUE;
var int autocvar_r_pixelscale = FALSE;
void
Menu_AutoScale(void)
{
	if (autocvar_r_autoscale) {
		vector psize = getproperty(VF_SCREENPSIZE);
		if (psize[1] >= (480 * 4)) {
			cvar_set("vid_conautoscale", "4");
		} else if (psize[1] >= (480 * 3)) {
			cvar_set("vid_conautoscale", "3");
		} else if (psize[1] >= (480 * 2)) {
			cvar_set("vid_conautoscale", "2");
		} else {
			cvar_set("vid_conautoscale", "1");
		}

		if (autocvar_r_pixelscale) {
			float scale = bound(0.0, 480 / psize[1], 1.0);
			cvar_set("r_renderscale", sprintf("-%f", scale));
		}
	}
}

/* old Half-Life configs that have a completely different gamma model would
 * mess up visibility on initial launch - so we catch that and and force
 * our default to fix it */
void
Menu_GammaHack(void)
{
	if (cvar("brightness") != cvar("vid_brightness")) {
		localcmd("seta brightness 0\n");
		print("^1Menu_RendererRestarted^7: Brightness hack.\n");
	}

	if (cvar("gamma") != cvar("vid_gamma")) {
		localcmd("seta gamma 1\n");
		print("^1Menu_RendererRestarted^7: Gamma hack.\n");
	}
}

/* called upon menu init/restart */
void
m_init(void)
{
	vector g_btnsize;

	/* things that should really be default. platform_default.cfg is supposed to set
	 * them the first time - however FTE doesn't do that when switching manifests
	 * for unknown reasons. It'll be fixed */
	cvar_set("r_ignoreentpvs", "0");
	cvar_set("_pext_infoblobs", "1");
	cvar_set("_q3bsp_bihtraces", "1");
	cvar_set("sv_gameplayfix_setmodelsize_qw", "1");
	cvar_set("sv_gameplayfix_setmodelrealbox", "1");
	cvar_set("cl_bob", "0");
	cvar_set("maxpitch", "89");
	cvar_set("minpitch", "-89");
	cvar_set("r_meshpitch", "1");
	cvar_set("v_contentblend", "0");
	cvar_set("gl_mindist", "4");
	cvar_set("con_textsize", "12");
	cvar_set("scr_conalpha", "1");
	cvar_set("con_notifylines", "0");
	cvar_set("cfg_save_auto", "1");
	cvar_set("r_imageextensions", "tga bmp pcx png jpg");
	cvar_set("cl_cursor_scale", "1");

	print(LICENSE_TEXT);
	print("\n\n");

	registercommand("menu_updates");
	registercommand("menu_customgame");
	registercommand("map_background");
	registercommand("menu_musicstart");
	registercommand("richpresence_dump");

	Font_Load("fonts/fontcon.font", font_console);
	Font_Load("fonts/menu_label.font", font_label);
	Font_Load("fonts/menu_main.font", font_arial);
	Font_Load("fonts/menu_label_bold.font", font_label_b);
	Font_Load("fonts/menu_header.font", font_label_p);

	localcmd("plug_load ffmpeg\n");

	for (int i = 0; i < g_bmp.length; i++) {
		precache_pic(g_bmp[i]);
	}

	g_btnsize = drawgetimagesize(g_bmp[BTNS_MAIN]);
	g_btnofs = 26 / g_btnsize[1];

	games_init();
	main_init();

	Colors_Init();
	Strings_Init();

	if (games[gameinfo_current].gamedir != "valve" || games[gameinfo_current].steambg == 1) {
		m_intro_skip();
		Music_MenuStart();
	}

	if (games[gameinfo_current].pkgfile != "")
	if not (whichpack(games[gameinfo_current].pkgfile) || autocvar_menu_updating) {
		/* reload in case of video restarts? */
		shaderforname("logo_avi", "{\n{\nvideomap av:media/logo.avi\n}\n}");
		g_menupage = PAGE_UPDATES;
	}

	Menu_AutoScale();
	Menu_GammaHack();

	if (g_intro_stage == 0) {
		string videofile = games[gameinfo_current].introvideo;
		
		if (videofile) {
			localcmd(strcat("playvideo ", videofile, "\n"));
		}
	}

	if (games[gameinfo_current].menumap != "") {
		string mapname = games[gameinfo_current].menumap;
		localcmd(strcat("map_background ", mapname, "\n"));
	}

	g_initialized = true;
}

/* called upon vid_reload, vid_restart, but not menu init/restart */
void
Menu_RendererRestarted(string rendererdesc)
{
	Menu_AutoScale();
	Menu_GammaHack();
}

/* called, in theory, whenever the menu gets killed */
void
m_shutdown(void)
{
	g_initialized = false;

	/*int i = 0;
	for (i = 0; i < g_bmp.length; i++) {
		freepic(g_bmp[i]);
	}*/

	entity e;
	while((e=nextent(__NULL__)))
		remove(e);

	memfree(g_sprays);
	memfree(g_models);
	memfree(games);

	cr_closeconnection();
}

/* called every frame, influenced by cl_idlefps */
void
m_draw(vector screensize)
{
	static float oldtime;
	frametime = time - oldtime;

	/* don't attempt to draw unless we're done loading everything */
	if (g_initialized == false) {
		return;
	}

	/* set new scale whenever the resolution changes */
	if ((screensize[0] != g_vidsize[0]) || (screensize[1] != g_vidsize[1])) {
		g_vidsize[0] = screensize[0];
		g_vidsize[1] = screensize[1];
		g_menuofs[0] = (g_vidsize[0] / 2) - 320;
		g_menuofs[1] = (g_vidsize[1] / 2) - 240;
		Menu_AutoScale();
	}

	g_background = cvar("_background");

	/* make sure input carries over when a map background is active */
	if (g_background) {
		if (getkeydest() != KEY_MENU) {
			setkeydest(KEY_MENU);
			setmousetarget(TARGET_MENU);
			setcursormode(TRUE, "gfx/cursor");
		}
	}

	/* to prevent TCP timeouts */
	menu_chatrooms_keepalive();

	/* clear rich presence whenever the state suddenly changes */
	if (g_gamestate != clientstate()) {
		g_gamestate = clientstate();

		if (g_gamestate == 1)
			RichPresence_Clear();
	}

	/* rich presence sanity check */
	if (RichPresence_WasSet() == false) {
		if (clientstate() == 2)
			RichPresence_Set("status", "In-game (Unknown)");
		else
			RichPresence_Set("status", "Main Menu");
	}

	/* if the menu is not visible and we're no background map... */
	if (!g_active && !g_background) {
		/* make sure we're redirecting input when the background's gone */
		if (getkeydest() != KEY_GAME) {
			setkeydest(KEY_GAME);
			setmousetarget(TARGET_CLIENT);
			setcursormode(FALSE);
		}

		/* don't draw the menu below */
		return;
	}

	/* when ingame, we'll draw a slight black tint... */
	if (clientstate() == 2) {
		/* ...unless we're in background map mode. */
		if (!g_background)
			drawfill([0,0], screensize, [0,0,0], 0.75f);
	} else {
		/* clear screen */
		drawfill([0,0], screensize, [0,0,0], 1.0f);

		/* draw either WON or Steam background */
		if (games[gameinfo_current].steambg == 0)
				Background_WON();
		else
				Background_Steam();
	}

	/* water mark for version info */
	const string ver = "Nuclide (build " __DATE__ ")";
	drawfont = Font_GetID(font_console);

	WLabel_Static(640 - 8 - stringwidth(ver, TRUE, [12,12]),
				  466,
				  ver, 
				  12, 12,
				  [1.0f,1.0f,1.0f],
				  0.5f, 0, font_console);

	/* draw the actual widgets */
	main_draw();

#ifndef WEBMENU
	/* HACK! after a custom game switches .fmf files, we need to force restart
	 * our menu. I'm so, so sorry. No, RendererRestarted doesn't see fs_game
	 * fast enough either. */
	if (cvar_string("fs_game") != games[gameinfo_current].gamedir) {
		localcmd(sprintf("gameinfo_gamedir %s\nmenu_restart\n", cvar_string("fs_game")));
	}
#endif

	oldtime = time;
}

void
m_drawloading(vector screensize, float opaque)
{
	vector pos;
	pos = (screensize / 2) - [32,32];
	drawfill([0,0], screensize, [0.5,0.5,0.5], 1.0f);
	drawpic(pos, "gfx/loading", [64,64], [1,1,1], 1.0f);
}

float
Menu_InputEvent(float evtype, float scanx, float chary, float devid)
{
	switch (evtype) {
	case IE_KEYDOWN:
		if (chary == K_ESCAPE) {
			if (clientstate() == 2 && !g_background) {
				m_toggle(0);
			}
		}
		break;
	case IE_MOUSEABS:
		g_mousepos[0] = scanx;
		g_mousepos[1] = chary;
		break;
	case IE_MOUSEDELTA:
		g_mousepos[0] += scanx;
		g_mousepos[1] += chary;
		break;
	}

	main_input(evtype, scanx, chary, devid);
	return (1);
}

void
m_display(void)
{
	g_active = TRUE;
	setkeydest(KEY_MENU);
	setmousetarget(TARGET_MENU);
	setcursormode(TRUE, "gfx/cursor");
}

/*
=================
m_hide
=================
*/
void
m_hide(void)
{
	g_active = FALSE;
	setkeydest(KEY_GAME);
	setmousetarget(TARGET_CLIENT);
	setcursormode(FALSE);
}

/*
=================
m_toggle
=================
*/
void
m_toggle(float fMode)
{
	if (fMode == FALSE) {
		m_hide();
	} else {
		m_display();
	}
}

float
m_consolecommand(string cmd)
{
	tokenize(cmd);
	switch (argv(0)) {
	case "richpresence_dump":
		RichPresence_DumpInfo();
		break;
	case "menu_musicstart":
		Music_MenuStart();
		break;
	case "menu_musictrack":
		Music_ParseTrack(argv(1));
		break;
	case "menu_musicloop":
		Music_ParseLoop(argv(1));
		break;
	case "menu_updates":
		g_menupage = PAGE_UPDATES;
		m_intro_skip();
		break;
	case "menu_customgame":
		g_menupage = PAGE_CUSTOMGAME;
		m_intro_skip();
		break;
	case "togglemenu":
		m_display();
		break;
	case "map_background":
		localcmd(sprintf("maxplayers 2\nset coop 1\nset sv_background 1\nmap %s\n",
			argv(1)));
		break;
	default:
		return (0);
	}
	return (1);
}
