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
var bool g_input_received = false;

#define FN_UPDATE_PKGLIST "http://www.frag-net.com/dl/%s_packages"

CDialog main_dgDisconnect;
CMainButton main_btnRefOK;
var bool serverDisconnect = false;

/* called upon menu init/restart */
void
m_init(void)
{
	void m_init_okdisconnect(void) {
		serverDisconnect = false;
	}

	ncLog("--------- Initializing Menu ----------");
	ncLog("Built: %s %s", __DATE__, __TIME__);
	ncLog("QCC: %s", __QCCVER__);

	localcmd("plug_load ffmpeg\n");

	Platform_Init();

	Font_Load("fonts/menu_label.font", font_label);
	Font_Load("fonts/menu_main.font", font_arial);
	Font_Load("fonts/menu_label_bold.font", font_label_b);
	Font_Load("fonts/menu_header.font", font_label_p);
	Font_Load("fonts/console.font", font_console);

	/* don't precache btns_main.bmp directly any more. */
	CMainButton_InitSheets();
	Strings_Init();
	main_init();
	Colors_Init();

	/* prepare spray logo keys */
	spray_setinfokeys();

	if (GameLibrary_GetInfo(GAMEINFO_GAMEDIR) != "valve") {
		m_intro_skip();
		Music_MenuStart();
	}

	if (Platform_HasStartupVideos() == true) {
		Platform_PlayStartupVideos();
	}

	/* init the disconnect dialog */
	main_dgDisconnect = spawn(CDialog);
	main_btnRefOK = spawn(CMainButton);
	main_btnRefOK.SetImage(BTN_OK);
	main_btnRefOK.SetPos(233,291);
	main_btnRefOK.SetLength(68);
	main_btnRefOK.SetExecute(m_init_okdisconnect);
	Widget_Add(main_dgDisconnect, main_btnRefOK);

	g_initialized = true;
}

/* called upon vid_reload, vid_restart, but not menu init/restart */
void
Menu_RendererRestarted(string rendererdesc)
{
	Platform_RendererRestarted();
	CMainButton_InitSheets();
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

	if (!g_input_received) {
		return;
	}

	frametime = time - oldtime;

	/* don't attempt to draw unless we're done loading everything */
	if (g_initialized == false) {
		return;
	}

	/* to prevent TCP timeouts */
	menu_chatrooms_keepalive();

	if (Platform_Draw(screensize) == false) {
		return;
	}

	Background_Draw((g_vidsize / 2) - [320,240], [640,480]);

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

	/* did the server disconnect us?...*/
	if (Error_ServerDisconnected() == true) {
		serverDisconnect = true;
	}

	/* if that happened, throw up a panel with an OK button. */
	if (serverDisconnect == true) {
		main_dgDisconnect.Draw();
		Widget_Draw(main_dgDisconnect);
		WField_Static(162, 180, "Disconnected", 320, 260,
						col_prompt_text, 1.0f, 2, font_label_p);
		WField_Static(162, 220, Error_GetDisconnectReason(), 320, 260,
					col_prompt_title, 1.0f, 2, font_label_p);
	}

	oldtime = time;
}

void
m_drawloading(vector screensize, float opaque)
{
	vector pos;
	pos = (screensize / 2) - [32,32];

	if (opaque) {
		drawfill([0,0], screensize, [0.25,0.25,0.25], 1.0f);
	}

	drawpic(pos, "gfx/loading", [64,64], [1,1,1], 1.0f);
}

float
Menu_InputEvent(float evtype, float scanx, float chary, float devid)
{
	g_input_received = true;

	switch (evtype) {
	case IE_KEYDOWN:
		if (chary == K_ESCAPE) {
			if (clientstate() == 2 && !g_background) {
				m_toggle(0);
			}
		}
		break;
	case IE_MOUSEABS:
		g_vecMousePos[0] = scanx;
		g_vecMousePos[1] = chary;
		break;
	case IE_MOUSEDELTA:
		g_vecMousePos[0] += scanx;
		g_vecMousePos[1] += chary;
		break;
	}

	if (serverDisconnect)
		Widget_Input(main_dgDisconnect, evtype, scanx, chary, devid);
	else
		main_input(evtype, scanx, chary, devid);

	return (1);
}

void
m_display(void)
{
	g_active = TRUE;
	setkeydest(KEY_MENU);
	setmousetarget(TARGET_MENU);
	setcursormode(TRUE, "gfx/icon16/cursor");
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
	int c = (int)tokenize(cmd);
	switch (argv(0)) {
	case "menu_updates":
		g_menupage = PAGE_UPDATES;
		m_intro_skip();
		break;
	case "menu_customgame":
		g_menupage = PAGE_CUSTOMGAME;
		m_intro_skip();
		break;
	default:
		return Platform_ConsoleCommand(cmd, c);
	}
	return (1);
}
