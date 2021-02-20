/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

var int g_initialized = FALSE;

#define FN_UPDATE_PKGLIST "http://www.frag-net.com/dl/%s_packages"

const string LICENSE_TEXT = "\
==============================================================================\
Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>\
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
	}
}

/* old Half-Life configs that have a completely different gamma model would
 * mess up visibility on initial launch - so we catch that and and force
 * our default to fix it */
void
Menu_GammaHack(void)
{
	if (cvar("brightness") != cvar("vid_brightness")) {
		cvar_set("brightness", "0");
		print("^1Menu_RendererRestarted^7: Brightness hack.\n");
	}

	if (cvar("gamma") != cvar("vid_gamma")) {
		cvar_set("gamma", "1");
		print("^1Menu_RendererRestarted^7: Gamma hack.\n");
	}
}

/* called upon menu init/restart */
void
m_init(void)
{
	vector g_btnsize;

	print(LICENSE_TEXT);
	print("\n\n");

	registercommand("menu_updates");
	registercommand("menu_customgame");
	registercommand("map_background");
	registercommand("menu_musicstart");

	font_console = loadfont("font", "", "12", -1);
	font_label = loadfont("label", "gfx/shell/mssansserif.ttf", "10 12 14", -1);
	font_arial = loadfont("label", "gfx/shell/arial.ttf", "14 11 12", -1);
	font_label_b = loadfont("label_b", "gfx/shell/arialbd.ttf", "14 12", -1);
	font_label_p = loadfont("label_p", "gfx/shell/arialbd.ttf", "16 21", -1);

	localcmd("plug_load ffmpeg\n");

	shaderforname("logo_avi", "{\n{\nvideomap av:media/logo.avi\n}\n}");

	for (int i = 0; i < g_bmp.length; i++) {
		precache_pic(g_bmp[i]);
	}

	g_btnsize = drawgetimagesize(g_bmp[BTNS_MAIN]);
	g_btnofs = 26 / g_btnsize[1];
	precache_pic("gfx/shell/fragnet");

	games_init();
	main_init();

	Colors_Init();
	Strings_Init();
	g_initialized = TRUE;

	if (cvar_string("gameinfo_gamedir") != "valve") {
		m_intro_skip();
		Music_MenuStart();
	}

	if (!whichpack(cvar_string("gameinfo_pkgfile")) || autocvar_menu_updating) {
		/* reload in case of video restarts? */
		shaderforname("logo_avi", "{\n{\nvideomap av:media/logo.avi\n}\n}");
		g_menupage = PAGE_UPDATES;
	}

	Menu_AutoScale();
	Menu_GammaHack();

	if (g_intro_stage == 0) {
		string videofile = cvar_string("gameinfo_introvideo");
		
		if (videofile) {
			localcmd(strcat("playvideo ", videofile, "\n"));
		}
	}
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
	g_initialized = FALSE;
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
}

/* called every frame, influenced by cl_idlefps */
void
m_draw(vector screensize)
{
	static float oldtime;
	frametime = time - oldtime;
	
	if (g_initialized == FALSE) {
		return;
	}

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

	if (!g_active && !g_background) {
		/* make sure we're redirecting input when the background's gone */
		if (getkeydest() != KEY_GAME) {
			setkeydest(KEY_GAME);
			setmousetarget(TARGET_CLIENT);
			setcursormode(FALSE);
		}
		return;
	}

	if (clientstate() == 2) {
		if (!g_background)
			drawfill([0,0], screensize, [0,0,0], 0.75f);
	} else {
		drawfill([0,0], screensize, [0,0,0], 1.0f);
		drawpic([g_menuofs[0],g_menuofs[1]], g_bmp[SPLASH],
				[640,480], [1,1,1], 1.0f);
	}

	const string ver = "Nuclide (build " __DATE__ ")";
	drawfont = font_console;

	WLabel_Static(640 - 8 - stringwidth(ver, TRUE, [12,12]),
				  466,
				  ver, 
				  12, 12,
				  [1.0f,1.0f,1.0f],
				  0.5f, 0, font_console);

	main_draw();

	/* HACK! after a custom game switches .fmf files, we need to force restart
	 * our menu. I'm so, so sorry. No, RendererRestarted doesn't see fs_game
	 * fast enough either. */
	if (cvar_string("fs_game") != games[gameinfo_current].gamedir) {
		localcmd(sprintf("gameinfo_gamedir %s\nmenu_restart\n", cvar_string("fs_game")));
	}
	
	oldtime = time;
}

void
m_drawloading(vector screensize, float opaque)
{
	vector pos;
	pos = (screensize / 2) - [32,32];
	drawfill([0,0], screensize, [0.5,0.5,0.5], 1.0f);
	drawpic(pos, "gfx/lambda64", [64,64], [1,1,1], 1.0f);
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
	return TRUE;
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
		return FALSE;
	}
	return TRUE;
}