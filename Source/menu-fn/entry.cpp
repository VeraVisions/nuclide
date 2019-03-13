/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

var int g_initialized = FALSE;

void m_init(void)
{
	vector g_btnsize;

	registercommand("menu_customgame");
	font_console = loadfont( "font", "", "12", -1 );
	font_label = loadfont( "label", "gfx/shell/mssansserif.ttf", "10 12 14", -1 );
	font_arial = loadfont( "label", "gfx/shell/arial.ttf", "14 11", -1 );
	font_label_b = loadfont( "label_b", "gfx/shell/arialbd.ttf", "14 12", -1 );
	font_label_p = loadfont( "label_p", "gfx/shell/arialbd.ttf", "16", -1 );

	localcmd("plug_load ffmpeg\n");

	/* TODO: Shove these into defaults.cfg instead of forcing them */
	localcmd("con_textsize -12\n");
	localcmd("scr_conalpha 1\n");
	localcmd("cl_idlefps 0\n");
	localcmd("r_shadow_realtime_dlight 0\n");
	localcmd("gl_mindist 4\n"); // Thanks Valve for v_shotgun.mdl
	localcmd("_pext_infoblobs 1\n");
	
	/* Hack! */
	localcmd("gl_font 0\n");
	localcmd("gl_font CONCHARS?fmt=h\n");

	shaderforname("logo_avi", "{\n{\nvideomap av:media/logo.avi\n}\n}");

	for (int i = 0; i < g_bmp.length; i++) {
		precache_pic(g_bmp[i]);
	}

	g_btnsize = drawgetimagesize(g_bmp[BTNS_MAIN]);
	g_btnofs = 26 / g_btnsize[1];

	games_init();
	main_init();

	Colors_Init();
	Strings_Init();
	g_initialized = TRUE;
}

void m_shutdown(void)
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
	memfree(g_maps);
	memfree(games);
}

void m_draw(vector screensize)
{
	static float oldtime;	
	frametime = time - oldtime;

	if (!g_active) {
		return;
	}
	
	if (g_initialized == FALSE) {
		return;
	}

	if ((screensize[0] != g_vidsize[0]) || (screensize[1] != g_vidsize[1])) {
		g_vidsize[0] = screensize[0];
		g_vidsize[1] = screensize[1];
		g_menuofs[0] = (g_vidsize[0] / 2) - 320;
		g_menuofs[1] = (g_vidsize[1] / 2) - 240;
	}

	if (clientstate() == 2) {
		drawfill([0,0], screensize, [0,0,0], 0.75f);
	} else {
		drawfill([0,0], screensize, [0,0,0], 1.0f);
		drawpic([g_menuofs[0],g_menuofs[1]], g_bmp[SPLASH],
				[640,480], [1,1,1], 1.0f);
	}

	main_draw();
	
	oldtime = time;
}

/*void m_drawloading(vector screensize, float opaque)
{
	
}*/

float Menu_InputEvent(float evtype, float scanx, float chary, float devid)
{
	switch (evtype) {
		case IE_KEYDOWN:
			if (chary == K_ESCAPE) {
				if (clientstate() == 2) {
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

void m_display(void)
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
void m_hide(void)
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
void m_toggle(float fMode)
{
	if (fMode == FALSE) {
		m_hide();
	} else {
		m_display();
	}
}

float m_consolecommand(string cmd)
{
	tokenize(cmd);
	switch (argv(0)) {
		case "menu_customgame":
			g_menupage = PAGE_CUSTOMGAME;
			break;
		case "togglemenu":
			m_display();
			break;
		default:
			return FALSE;
	}
	return TRUE;
}
