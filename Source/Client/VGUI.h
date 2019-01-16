/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

#define VGUI_WINDOW_BGCOLOR '0.0 0.0 0.0'
#define VGUI_WINDOW_FGCOLOR '1.0 0.5 0.0'
#define VGUI_WINDOW_BGALPHA 0.8
#define VGUI_WINDOW_FGALPHA 1.0

enum {
	VGUI_NONE = 0,
	VGUI_MOTD,
	VGUI_TEAMSELECT,
	VGUI_TEAM_T,
	VGUI_TEAM_CT,
	VGUI_BM_MAIN,
	VGUI_BM_HANDGUNS,
	VGUI_BM_SHOTGUNS,
	VGUI_BM_SMG,
	VGUI_BM_RIFLES,
	VGUI_BM_MGS,
	VGUI_BM_EQUIPMENT,
	VGUI_RADIO1,
	VGUI_RADIO2,
	VGUI_RADIO3
};

vector vVGUIWindowPos;
vector vVGUIButtonPos;

string sMOTDString[25];
string sMapString[35];

var int iVGUIKey;

typedef struct {
	string sTitle;
	void( vector vPos ) vDraw;
} vguiwindow_t;

typedef struct {
	string sName;
	string sImage;
} vguiweaponobject_t;

typedef struct {
	float fID;
	string sName;
	string sImage;
} vguiequipobject_t;
