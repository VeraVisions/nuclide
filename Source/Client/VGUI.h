/*
OpenCS Project
Copyright (C) 2016, 2017 Marco "eukara" Hladik

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

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
