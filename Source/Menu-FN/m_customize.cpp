/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

CWidget fn_customize;
CMainButton cz_btnDone;
CMainButton cz_btnAdvanced;
CTextBox cz_tbNetname;
CPictureSwitch cz_psSpray;
CPictureSwitch cz_psModel;

string *g_models;
int g_modelcount;
string *g_sprays;
int g_sprayscount;

void cz_btndone_start(void)
{
	static void cz_btndone_end(void) {
		g_menupage = PAGE_MULTIPLAYER;
	}
	cvar_set("name", cz_tbNetname.m_text);
	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(45,45,50,300);
	header.SetStartEndSize(460,80,156,26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_CUSTOMIZE);
	header.SetExecute(cz_btndone_end);
}
void cz_btnadvanced_start(void)
{
	static void cz_btnadvanced_end(void) {
		g_menupage = PAGE_ADVANCEDCUSTOMIZE;
	}
	localsound("../media/launch_upmenu1.wav");
	header.SetStartEndPos(50,172,45,45);
	header.SetStartEndSize(156,26,460,80);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_ADVANCED);
	header.SetExecute(cz_btnadvanced_end);
}

void menu_customize_init(void)
{
	searchhandle searchy = search_begin("*.bmp", TRUE, TRUE);
	g_sprays = memalloc(sizeof(string) * search_getsize(searchy));
	for (int i = 0; i < search_getsize(searchy); i++) {
		precache_pic(search_getfilename(searchy, i));
		g_sprays[i] = search_getfilename(searchy, i);
		//g_sprays[i] = substring(search_getfilename(searchy, i), 0, -5);
	}
	search_end(searchy);
	
	searchy = search_begin("models/player/*/*.bmp", TRUE, TRUE);
	g_models = memalloc(sizeof(string) * search_getsize(searchy));
	for (int i = 0; i < search_getsize(searchy); i++) {
		g_models[i] = search_getfilename(searchy, i);
		//tokenizebyseparator(search_getfilename(searchy, i),"/");
		//precache_pic(argv(2));
		//g_models[i] = argv(2);
	}
	search_end(searchy);
	
	fn_customize = spawn(CWidget);
	cz_btnDone = spawn(CMainButton);
	cz_btnDone.SetImage(BTN_DONE);
	cz_btnDone.SetExecute(cz_btndone_start);
	cz_btnDone.SetPos(50,140);
	Widget_Add(fn_customize, cz_btnDone);

	cz_btnAdvanced = spawn(CMainButton);
	cz_btnAdvanced.SetImage(BTN_ADVOPTIONS);
	cz_btnAdvanced.SetExecute(cz_btnadvanced_start);
	cz_btnAdvanced.SetPos(50,172);
	Widget_Add(fn_customize, cz_btnAdvanced);
	
	cz_tbNetname = spawn(CTextBox);
	cz_tbNetname.SetPos(212,160);
	cz_tbNetname.SetText(cvar_string("name"));
	Widget_Add(fn_customize, cz_tbNetname);
	
	cz_psSpray = spawn(CPictureSwitch);
	cz_psSpray.SetPos(212,226);
	cz_psSpray.SetSize(99,124);
	cz_psSpray.SetPicSize(64,64);
	cz_psSpray.SetPicOffset(14,14);
	cz_psSpray.SetMax(g_sprayscount);
	cz_psSpray.SetPics(g_sprays);
	cz_psSpray.SetValueS("logo");
	//Widget_Add(fn_customize, cz_psSpray);
	
	cz_psModel = spawn(CPictureSwitch);
	cz_psModel.SetPos(410,160);
	cz_psModel.SetSize(170,221);
	cz_psModel.SetPicSize(164,190);
	cz_psModel.SetPics(g_models);
	cz_psModel.SetMax(g_modelcount);
	cz_psSpray.SetValueS("model");
	//Widget_Add(fn_customize, cz_psModel);
}

void menu_customize_draw(void)
{
	Widget_Draw(fn_customize);
	drawpic([g_menuofs[0]+45,g_menuofs[1]+45], g_bmp[HEAD_CUSTOMIZE],[460,80], [1,1,1], 1.0f, 1);
	WLabel_Static(212, 140, m_reslbl[IDS_PLAYERINFO_NAME], 14, 14, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(410, 140, sprintf(m_reslbl[IDS_MODEL_NAME], "barney"), 14, 14, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(212, 203, m_reslbl[IDS_PROFILE_LOGO], 14, 14, [1,1,1],
					1.0f, 0, font_arial);
}

void menu_customize_input(float evtype, float scanx, float chary, float devid)
{
	Widget_Input(fn_customize, evtype, scanx, chary, devid);
}
