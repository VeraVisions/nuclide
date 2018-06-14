/*
	Copyright 2016-2018 Marco "eukara" Hladik
	
	MIT LICENSE

	Permission is hereby granted, free of charge, to any person 
	obtaining a copy of this software and associated documentation 
	files (the "Software"), to deal in the Software without 
	restriction, including without limitation the rights to use,
	copy, modify, merge, publish, distribute, sublicense, and/or
	sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.
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
