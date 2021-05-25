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
CSlider cz_sldTopcolor;
CSlider cz_sldBottomcolor;

vector g_vecTopcolor;
vector g_vecBottomcolor;

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
	localcmd(sprintf("headmodel %s\n", argv(2)));
	localcmd(sprintf("team_model %s\n", argv(2)));
	localcmd(sprintf("team_headmodel %s\n", argv(2)));
}

void
cz_cbSprayChanged(void)
{
	string mdl = cz_psSpray.GetPic();
	localcmd(sprintf("seta _cl_playerspray %s\n", mdl));
	localcmd(sprintf("setinfoblob spray %s\n", mdl));
}

vector hsv2rgb(float h, float s, float v)
{
	float i,f,p,q,t;
	vector col = [0,0,0];

	h = max(0.0, min(360.0, h));
	s = max(0.0, min(100.0, s));
	v = max(0.0, min(100.0, v));

	s /= 100;
	v /= 100;

	if (s == 0) {
		col[0] = col[1] = col[2] = rint(v*255);
		return col;
	}

	h /= 60;
	i = floor(h);
	f = h - i;
	p = v * (1 - s);
	q = v * (1 - s * f);
	t = v * (1 - s * (1 - f));

	switch (i) {
	case 0:
		col[0] = rint(255*v);
		col[1] = rint(255*t);
		col[2] = rint(255*p);
		break;
	case 1:
		col[0] = rint(255*q);
		col[1] = rint(255*v);
		col[2] = rint(255*p);
		break;
	case 2:
		col[0] = rint(255*p);
		col[1] = rint(255*v);
		col[2] = rint(255*t);
		break;
	case 3:
		col[0] = rint(255*p);
		col[1] = rint(255*q);
		col[2] = rint(255*v);
		break;
	case 4:
		col[0] = rint(255*t);
		col[1] = rint(255*p);
		col[2] = rint(255*v);
		break;
	default:
		col[0] = rint(255*v);
		col[1] = rint(255*p);
		col[2] = rint(255*q);
	}
	return col;
}

void
cz_sldTopcolorChanged(float val)
{
	vector x = hsv2rgb(val * 360, 100, 100);
	float id = x[2] + (x[1] << 8) + (x[0] << 16);
	cvar_set("topcolor", sprintf("0x%x", id));
	localcmd(sprintf("seta _cl_topcolor %f\n", val));
	g_vecTopcolor = x / 255;
}

void
cz_sldBottomcolorChanged(float val)
{
	vector x = hsv2rgb(val * 360, 100, 100);
	float id = x[2] + (x[1] << 8) + (x[0] << 16);
	cvar_set("bottomcolor", sprintf("0x%x", id));
	localcmd(sprintf("seta _cl_bottomcolor %f\n", val));
	g_vecBottomcolor = x / 255;
}

void
menu_customize_init(void)
{
	int sid = 0;
	g_sprayscount = 0;

	/* scan and cache the sprays */
	searchhandle searchy = search_begin("*.*", SEARCH_NAMESORT, TRUE);
	for (int i = 0; i < search_getsize(searchy); i++) {
		string full = search_getfilename(searchy, i);
		string filename = substring(search_getfilename(searchy, i), 0, -5);
		string extension = substring(full, strlen(full) - 3, 3);
		if (extension == "bmp" || extension == "png" || extension == "jpg") {
			g_sprayscount++;
		}
	}

	/* only allocate what we truly need */
	g_sprays = memalloc(sizeof(string) * g_sprayscount);
	for (int i = 0; i < search_getsize(searchy); i++) {
		string full = search_getfilename(searchy, i);
		string filename = substring(full, 0, -5);
		string extension = substring(full, strlen(full) - 3, 3);

		if (extension == "bmp" || extension == "png" || extension == "jpg") {
			g_sprays[sid] = precache_pic(full);
			sid++;
		}
	}
	search_end(searchy);

	/* scan and cache the models */
	searchy = search_begin("models/player/*/*.bmp:models/player/*/*.tga:models/players/*/icon_blue.tga", SEARCH_MULTISEARCH | SEARCH_NAMESORT, TRUE);

	g_modelcount = search_getsize(searchy);
	g_models = memalloc(sizeof(string) * g_modelcount);
	for (int i = 0; i < g_modelcount; i++) {
		g_models[i] = substring(search_getfilename(searchy, i), 0, -5);
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

	if (games[gameinfo_current].nosprays == 0) {
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
	}

	if (games[gameinfo_current].nomodels == 0) {
		cz_psModel = spawn(CPictureSwitch);
		cz_psModel.SetPos(410,160);
		cz_psModel.SetSize(170,221);
		cz_psModel.SetPicSize(164,190);
		cz_psModel.SetPics(g_models);
		cz_psModel.SetMax(g_modelcount);
		cz_psModel.SetCallback(cz_cbModelChanged);
		cz_psModel.SetValueS(sprintf("models/player/%s/%s", cvar_string("_cl_playermodel"), cvar_string("_cl_playermodel")));
		Widget_Add(fn_customize, cz_psModel);
	
		cz_sldTopcolor = spawn(CSlider);
		cz_sldTopcolor.SetPos(420,400);
		cz_sldTopcolor.SetValue(cvar("_cl_topcolor"));
		cz_sldTopcolor.SetCallback(cz_sldTopcolorChanged);
		Widget_Add(fn_customize, cz_sldTopcolor);
		
		cz_sldBottomcolor = spawn(CSlider);
		cz_sldBottomcolor.SetPos(420,420);
		cz_sldBottomcolor.SetValue(cvar("_cl_bottomcolor"));
		cz_sldBottomcolor.SetCallback(cz_sldBottomcolorChanged);
		Widget_Add(fn_customize, cz_sldBottomcolor);

		g_vecTopcolor = hsv2rgb(cvar("_cl_topcolor") * 360, 100, 100) / 255;
		g_vecBottomcolor = hsv2rgb(cvar("_cl_bottomcolor") * 360, 100, 100) / 255;
	}
}

void
menu_customize_draw(void)
{
	Widget_Draw(fn_customize);
	Header_Draw(HEAD_CUSTOMIZE);
	WLabel_Static(212, 140, m_reslbl[IDS_PLAYERINFO_NAME], 14, 14, [1,1,1],
					1.0f, 0, font_arial);

	if (games[gameinfo_current].nomodels == 0) {
		WLabel_Static(410, 140, sprintf(m_reslbl[IDS_MODEL_NAME], cvar_string("_cl_playermodel")), 14, 14, [1,1,1],
						1.0f, 0, font_arial);

		drawfill([g_menuofs[0] + 414,g_menuofs[1] + 346], [64,12], g_vecTopcolor, 0.75f);
		drawfill([g_menuofs[0] + 510,g_menuofs[1] + 346], [64,12], g_vecBottomcolor, 0.75f);
	}

	if (games[gameinfo_current].nosprays == 0)
	WLabel_Static(212, 203, m_reslbl[IDS_PROFILE_LOGO], 14, 14, [1,1,1],
					1.0f, 0, font_arial);
}

void
menu_customize_input(float evtype, float scanx, float chary, float devid)
{
	Widget_Input(fn_customize, evtype, scanx, chary, devid);
}
