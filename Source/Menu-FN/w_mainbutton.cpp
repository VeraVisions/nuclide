/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

enum {
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

class CMainButton:CWidget
{
	int m_bitmap;
	float m_alpha;
	int m_hover;
	int m_click;
	virtual void() m_execute = 0;
	
	int m_length;

	void() CMainButton;
	virtual void() Draw;
	virtual void(float type, float x, float y, float devid) Input;

	virtual void(int i) SetImage;
	virtual void(int i) SetLength;
	virtual void(void() vFunc) SetExecute;
};

void CMainButton::CMainButton(void)
{
	m_alpha = 1.0f;
	m_length = 156;
}

void CMainButton::Draw(void)
{
	if (!m_execute) {
		drawsubpic([g_menuofs[0]+m_x,g_menuofs[1]+m_y], [156,26], g_bmp[0], 
				[0,(m_bitmap * 3) * g_btnofs], [1,g_btnofs], [1,1,1], 0.75f, 1);
				return;
	}
	if (m_click) {
		drawsubpic([g_menuofs[0]+m_x,g_menuofs[1]+m_y], [156,26], g_bmp[0],
				[0,((m_bitmap * 3)+2) * g_btnofs], [1,g_btnofs],
				[1,1,1], 1.0f, 1);
		return;
	}
	drawsubpic([g_menuofs[0]+m_x,g_menuofs[1]+m_y], [156,26], g_bmp[0], 
				[0,(m_bitmap * 3) * g_btnofs], [1,g_btnofs], [1,1,1], 1.0f, 1);
				
	drawsubpic([g_menuofs[0]+m_x,g_menuofs[1]+m_y], [156,26], g_bmp[0],
				[0,((m_bitmap * 3)+1) * g_btnofs], [1,g_btnofs],
				[1,1,1], 1 - m_alpha, 1);

	if (m_hover) {
		m_alpha -= frametime * 16;
	} else {
		m_alpha += frametime * 2;
	}

	m_alpha = bound(0.0f, m_alpha, 1.0f);
}

void CMainButton::Input(float type, float x, float y, float devid)
{
	if (Util_CheckMouse(m_x, m_y, m_length, 26) == TRUE) {
		m_hover = TRUE;
	} else {
		m_hover = FALSE;
	}

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

void CMainButton::SetImage(int i)
{
	m_bitmap = i;
}
void CMainButton::SetLength(int i)
{
	m_length = i;
}

void CMainButton::SetExecute(void() vFunc)
{
	m_execute = vFunc;
}
