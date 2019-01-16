/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

void m_init(void)
{
	vector g_btnsize;

	font_console = loadfont( "font", "", "12", -1 );
	font_label = loadfont( "label", "gfx/shell/mssansserif.ttf", "10 12 14", -1 );
	font_arial = loadfont( "label", "gfx/shell/arial.ttf", "14", -1 );
	font_label_b = loadfont( "label_b", "gfx/shell/arialbd.ttf", "14 12", -1 );
	font_label_p = loadfont( "label_p", "gfx/shell/arialbd.ttf", "16", -1 );

	localcmd("plug_load ffmpeg\n");
	localcmd("con_textsize -12\n");
	shaderforname("logo_avi", "{\n{\nvideomap av:media/logo.avi\n}\n}");

	for (int i = 0; i < g_bmp.length; i++) {
		precache_pic(g_bmp[i]);
	}

	g_btnsize = drawgetimagesize(g_bmp[BTNS_MAIN]);
	g_btnofs = 26 / g_btnsize[1];

	Strings_Init();
	Colors_Init();
	main_init();
}

void m_shutdown(void)
{
	
}

void m_draw(vector screensize)
{
	static float oldtime;	
	frametime = time - oldtime;

	if (!g_active) {
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
		case "togglemenu":
			m_display();
			break;
		default:
			return FALSE;
	}
	return TRUE;
}
