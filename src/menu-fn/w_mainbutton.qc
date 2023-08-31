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

int g_mainbutton_imgcount;

enum
{
	BTN_NEWGAME,
	BTN_RESUMEGAME,
	BTN_TRAINING,
	BTN_CONFIG,
	BTN_LOADGAME,
	BTN_SAVELOAD,
	BTN_README,
	BTN_QUIT,
	BTN_MULTIPLAYER,
	BTN_EASY,
	BTN_MEDIUM,
	BTN_DIFFICULT,
	BTN_SAVEGAME,
	BTN_LOADGAME2,
	BTN_CANCEL,
	BTN_OPTIONS,
	BTN_VIDEO,
	BTN_AUDIO,
	BTN_CONTROLS,
	BTN_DONE,
	BTN_QUICKSTART,
	BTN_DEFAULTS,
	BTN_OK,
	BTN_VIDEOOPTIONS,
	BTN_VIDEOMODES,
	BTN_ADVCONTROLS,
	BTN_ORDER,
	BTN_DELETE,
	BTN_INTERNET,
	BTN_IRCCHAT,
	BTN_LAN,
	BTN_CUSTOMIZE,
	BTN_SKIP,
	BTN_EXIT,
	BTN_CONNECT,
	BTN_REFRESH,
	BTN_FILTER1,
	BTN_FILTER2,
	BTN_CREATE,
	BTN_CREATEGAME,
	BTN_CHATROOMS,
	BTN_LISTROOMS,
	BTN_SEARCH,
	BTN_SERVERS,
	BTN_JOIN,
	BTN_FIND,
	BTN_CREATEROOM,
	BTN_JOINGAME,
	BTN_SEARCHGAMES,
	BTN_FINDGAME,
	BTN_STARTGAME,
	BTN_GAMEINFO,
	BTN_UPDATELIST,
	BTN_ADDSERVER,
	BTN_DISCONNECT,
	BTN_CONSOLE,
	BTN_CONTENTCONTROL,
	BTN_UPDATE,
	BTN_VISITFRAGNET,
	BTN_PREVIEWS,
	BTN_ADVOPTIONS,
	BTN_3DINFO,
	BTN_CUSTOMGAME,
	BTN_ACTIVATE,
	BTN_INSTALL,
	BTN_VISITWEB,
	BTN_REFRESHLIST,
	BTN_DEACTIVATE,
	BTN_SPECTATEGAME,
	BTN_SPECTATEGAMES
};

#define MAIN_BUTTONS 71
string g_mainbtn_sheets[MAIN_BUTTONS];

string g_mainbtn_text[MAIN_BUTTONS] = {
	"NEW GAME",
	"RESUME GAME",
	"TRAINING",
	"CONFIG",
	"LOAD GAME",
	"SAVE LOAD",
	"README",
	"QUIT",
	"MULTIPLAYER",
	"EASY",
	"MEDIUM",
	"DIFFICULT",
	"SAVE GAME",
	"LOAD GAME",
	"CANCEL",
	"OPTIONS",
	"VIDEO",
	"AUDIO",
	"CONTROLS",
	"DONE",
	"QUICK START",
	"DEFAULTS",
	"OK",
	"VIDEO OPTIONS",
	"VIDEO MODES",
	"ADV. CONTROLS",
	"ORDER",
	"DELETE",
	"INTERNET GAME",
	"IRC CHAT",
	"LAN GAME",
	"CUSTOMIZE",
	"SKIP",
	"EXIT",
	"CONNECT",
	"REFRESH",
	"FILTER1",
	"FILTER2",
	"CREATE",
	"CREATE GAME",
	"CHAT ROOMS",
	"LIST ROOMS",
	"SEARCH",
	"SERVERS",
	"JOIN",
	"FIND",
	"CREATE ROOM",
	"JOIN GAME",
	"SEARCH GAMES",
	"FIND GAME",
	"START GAME",
	"GAME INFO",
	"UPDATE LIST",
	"ADD SERVER",
	"DISCONNECT",
	"CONSOLE",
	"CONTENT CONTROL",
	"UPDATE",
	"VISIT FRAG-NET",
	"PREVIEWS",
	"ADV. OPTIONS",
	"3D INFO",
	"CUSTOM GAME",
	"ACTIVATE",
	"INSTALL",
	"VISITWEB",
	"REFRESH LIST",
	"DEACTIVATE",
	"SPECTATE GAME",
	"SPECTATE GAMES"
};

class CMainButton:CWidget
{
	int m_bitmap;
	float m_alpha;
	int m_hover;
	int m_click;
	virtual void(void) m_execute = 0;
	
	int m_length;

	void(void) CMainButton;
	virtual void(void) Draw;
	virtual void(float, float, float, float) Input;

	virtual void(int) SetImage;
	virtual void(int) SetLength;
	virtual void(void(void)) SetExecute;
};

void
CMainButton::CMainButton(void)
{
	m_alpha = 1.0f;
	m_length = 156;
}

#define BUTTON_OFFSET (1.0f / 3.0f)

void
CMainButton::Draw(void)
{
	bool btnPresent = false;

	/* we may not have a button image */
	if (m_bitmap < g_mainbutton_imgcount) {
		btnPresent = true;
	}

	/* if we have btns_main */
	if (btnPresent == true) {
		if (!m_execute) {
			drawsubpic([g_menuofs[0]+m_x,g_menuofs[1]+m_y], [156,26], g_mainbtn_sheets[m_bitmap], 
					[0,0], [1, BUTTON_OFFSET], [1,1,1] * 0.75f, 1.0f, 0);
					return;
		}
		if (m_click) {
			drawsubpic([g_menuofs[0]+m_x,g_menuofs[1]+m_y], [156,26], g_mainbtn_sheets[m_bitmap],
					[0,0 + (2/3)], [1, BUTTON_OFFSET], [1,1,1], 1.0f, 0);
			return;
		}

		drawsubpic([g_menuofs[0]+m_x,g_menuofs[1]+m_y], [156,26], g_mainbtn_sheets[m_bitmap], 
					[0,0], [1, BUTTON_OFFSET], [1,1,1], 1.0f, 0);
					
		drawsubpic([g_menuofs[0]+m_x,g_menuofs[1]+m_y], [156,26], g_mainbtn_sheets[m_bitmap],
					[0,0 + BUTTON_OFFSET], [1, BUTTON_OFFSET], [1,1,1] * (1 - m_alpha), 1.0f, 0);
	} else {
		drawfont = Font_GetID(font_label_p);
		if (!m_execute) {
			drawstring([g_menuofs[0]+m_x,g_menuofs[1]+m_y], g_mainbtn_text[m_bitmap], [16,16], col_button_disabled, 1.0, 0);
			return;
		}
		if (m_click) {
			drawstring([g_menuofs[0]+m_x,g_menuofs[1]+m_y], g_mainbtn_text[m_bitmap], [16,16], col_button_click, 1.0, 0);
			return;
		}

		drawstring([g_menuofs[0]+m_x,g_menuofs[1]+m_y], g_mainbtn_text[m_bitmap], [16,16], col_button_bg, 1.0, 0);
		drawstring([g_menuofs[0]+m_x,g_menuofs[1]+m_y], g_mainbtn_text[m_bitmap], [16,16], col_button_select, 1 - m_alpha, 0);
	}

	if (m_hover) {
		m_alpha -= frametime * 16;
	} else {
		m_alpha += frametime * 2;
	}

	m_alpha = bound(0.0f, m_alpha, 1.0f);
}

void
CMainButton::Input(float type, float x, float y, float devid)
{
	m_hover = Util_CheckMouse(m_x, m_y, m_length, 26);

	if (m_hover && type == IE_KEYDOWN && x == K_MOUSE1) {
		localsound("../media/launch_select2.wav");
		m_click = TRUE;
	}

	if (type == IE_KEYUP && x == K_MOUSE1) {
		if (m_click) {
			if (m_execute) {
				m_execute();
			}
			m_click = FALSE;
		}
	}
}

void
CMainButton::SetImage(int i)
{
	m_bitmap = i;
}
void
CMainButton::SetLength(int i)
{
	m_length = i;
}

void
CMainButton::SetExecute(void(void) vFunc)
{
	m_execute = vFunc;
}

/** Old GPUs are limited in their texture size, so split 'em up! */
#define MAINBUTTON_WIDTH 156i
#define MAINBUTTON_HEIGHT 78i
#define MAINBUTTON_PIXELS (MAINBUTTON_WIDTH * MAINBUTTON_HEIGHT)
void
CMainButton_InitSheets( void )
{
	int *img;
	int width, height;
	int format;

	img = r_readimage("gfx/shell/btns_main.bmp", width, height, format);

	if (img == __NULL__) {
		return;
	}

	/* only load in as meny segments as the menu bitmap provides,
	   which will also deal as a cut-off point and provide fallback
	   text for versions of the game data that does not have all
	   the images required */
	g_mainbutton_imgcount = (height / MAINBUTTON_HEIGHT);

	for (int i = 0i; i < g_mainbutton_imgcount; i++ ) {
		string sheetName = sprintf("btns_main_%i", i);
		string materialPath = sprintf("gfx/shell/btns_main_%i", i);
		int *imgBuffer;
		int bufferOffset = (MAINBUTTON_WIDTH * MAINBUTTON_HEIGHT) * i; /* advance the img buffer */

		imgBuffer = memalloc(sizeof(int) * MAINBUTTON_PIXELS);

		for (int x = 0i; x < MAINBUTTON_PIXELS; x++) {
			imgBuffer[x] = img[x + bufferOffset];
		}

		/* upload the image, then generate a material pointing to it for us to display later. */
		r_uploadimage(sheetName, MAINBUTTON_WIDTH, MAINBUTTON_HEIGHT, (void *)imgBuffer);
		shaderforname(materialPath, sprintf("{\n{\n\tclampmap %s\n\trgbGen vertex\n\tblendFunc add\n}\n}", sheetName));

		/* lut */
		g_mainbtn_sheets[i] = materialPath;

		memfree(imgBuffer);
	}
	memfree(img);

	for (int i = 1; i < g_bmp.length; i++) {
		precache_pic(g_bmp[i]);
	}
}
