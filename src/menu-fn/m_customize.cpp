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

void
cz_btndone_start(void)
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

void
cz_btnadvanced_start(void)
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

void
cz_cbModelChanged(void)
{
	string mdl = cz_psModel.GetPic();
	tokenizebyseparator(mdl, "/");
	localcmd(sprintf("seta _cl_playermodel %s\n", argv(2)));
	localcmd(sprintf("setinfo model %s\n", argv(2)));
}

void
cz_cbSprayChanged(void)
{
	string mdl = cz_psSpray.GetPic();
	localcmd(sprintf("seta _cl_playerspray %s\n", mdl));
	localcmd(sprintf("setinfoblob spray %s\n", mdl));
}

void
menu_customize_init(void)
{
	int sid = 0;
	g_sprayscount = 0;

	/* scan and cache the sprays */
	searchhandle searchy = search_begin("*.*", SEARCH_NAMESORT, TRUE);
	for (int i = 0; i < search_getsize(searchy); i++) {
		string filename = search_getfilename(searchy, i);
		string extension = substring(filename, strlen(filename) - 3, 3);

		if (extension == "bmp" || extension == "png" || extension == "jpg") {
			g_sprayscount++;
		}
	}

	/* only allocate what we truly need */
	g_sprays = memalloc(sizeof(string) * g_sprayscount);
	for (int i = 0; i < search_getsize(searchy); i++) {
		string filename = search_getfilename(searchy, i);
		string extension = substring(filename, strlen(filename) - 3, 3);
		
		if (extension == "bmp" || extension == "png" || extension == "jpg") {
			g_sprays[sid] = filename;
			precache_pic(g_sprays[sid]);
			sid++;
		}
	}
	search_end(searchy);

	/* scan and cache the models */
	searchy = search_begin("models/player/*/*.bmp:models/player/*/*.tga", SEARCH_MULTISEARCH | SEARCH_NAMESORT, TRUE);

	g_modelcount = search_getsize(searchy);
	g_models = memalloc(sizeof(string) * g_modelcount);
	for (int i = 0; i < g_modelcount; i++) {
		g_models[i] = search_getfilename(searchy, i);
		precache_pic(g_models[i]);
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
	cz_psSpray.SetPics(g_sprays);
	cz_psSpray.SetMax(g_sprayscount);
	cz_psSpray.SetCallback(cz_cbSprayChanged);
	cz_psSpray.SetValueS(cvar_string("_cl_playerspray"));
	Widget_Add(fn_customize, cz_psSpray);

	if (games[gameinfo_current].nomodels == 1) {
		return;
	}

	cz_psModel = spawn(CPictureSwitch);
	cz_psModel.SetPos(410,160);
	cz_psModel.SetSize(170,221);
	cz_psModel.SetPicSize(164,190);
	cz_psModel.SetPics(g_models);
	cz_psModel.SetMax(g_modelcount);
	cz_psModel.SetCallback(cz_cbModelChanged);
	cz_psModel.SetValueS(sprintf("models/player/%s/%s", cvar_string("_cl_playermodel"), cvar_string("_cl_playermodel")));
	Widget_Add(fn_customize, cz_psModel);
}

void
menu_customize_draw(void)
{
	Widget_Draw(fn_customize);
	drawpic([g_menuofs[0]+45,g_menuofs[1]+45], g_bmp[HEAD_CUSTOMIZE],[460,80], [1,1,1], 1.0f, 1);
	WLabel_Static(212, 140, m_reslbl[IDS_PLAYERINFO_NAME], 14, 14, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(410, 140, sprintf(m_reslbl[IDS_MODEL_NAME], cvar_string("_cl_playermodel")), 14, 14, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_Static(212, 203, m_reslbl[IDS_PROFILE_LOGO], 14, 14, [1,1,1],
					1.0f, 0, font_arial);
}

void
menu_customize_input(float evtype, float scanx, float chary, float devid)
{
	Widget_Input(fn_customize, evtype, scanx, chary, devid);
}
