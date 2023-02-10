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

CWidget fn_customize;
CMainButton cz_btnDone;
CMainButton cz_btnAdvanced;
CTextBox cz_tbNetname;
CPictureSwitch cz_psSpray;
CSlider cz_sldTopcolor;
CSlider cz_sldBottomcolor;
CCheckBox cz_cxHQModels;
CCheckBox cz_cxEnableVoice;
CCheckBox cz_cxEnableMic;
CSlider cz_sldTransmitVol;
CSlider cz_sldReceiveVol;

#ifdef MODEL_PREVIEW
CUI3DView cz_3dModel;
var int g_iModel;
entity g_ePreviewModel;
static int g_iPreviewmodelSubUpdate;
#else
CPictureSwitch cz_psModel;
#endif

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
#ifdef MODEL_PREVIEW
	string mdl = g_models[g_iModel];
#else
	string mdl = cz_psModel.GetPic();
#endif
	tokenizebyseparator(mdl, "/");
	localcmd(sprintf("seta _cl_playermodel %s\n", argv(2)));
	localcmd(sprintf("setinfo model %s\n", argv(2)));
	localcmd(sprintf("headmodel %s\n", argv(2)));
	localcmd(sprintf("team_model %s\n", argv(2)));
	localcmd(sprintf("team_headmodel %s\n", argv(2)));
}

void
spray_setinfokeys(void)
{
	string strSpray = cvar_string("_cl_playerspray");
	string strExt = substring(strSpray, strlen(strSpray) - 3, 3);
	int iType = 0i;

	/* bmp are always monochrome */
	if (strExt == "bmp")
		iType = 1i;
	else
		iType = 0i;

	localcmd(sprintf("setinfoblob spray %s\n", strSpray));
	localcmd(sprintf("setinfo spraycolor \"%v\"\n", [1,1,1]));
	localcmd(sprintf("setinfo spraytype %i\n", iType));
}

void
cz_cbSprayChanged(void)
{
	string mdl = cz_psSpray.GetPic();
	localcmd(sprintf("seta _cl_playerspray %s\n", mdl));
	spray_setinfokeys();
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
cz_sldTransmitVolChanged(float val)
{
	localcmd(sprintf("seta cl_voip_capturingvol %f\n", val));
}

void
cz_sldReceiveVolChanged(float val)
{
	localcmd(sprintf("seta cl_voip_play %f\n", val));

	/* this is not a FTE cvar... */
	localcmd(sprintf("seta _ugly_cl_voip_volume %f\n", val));
}

void
cz_cxHQModelsChanged(float val)
{
	localcmd(sprintf("seta cl_himodels %f\n", val));

	if (val)
			setcustomskin(g_ePreviewModel, "", "geomset 0 2\n");
		else
			setcustomskin(g_ePreviewModel, "", "geomset 0 1\n");
}
void
cz_cxEnableVoiceChanged(float val)
{
	if (val) {
		/* restore the original volume if present */
		if (cvar("_ugly_cl_voip_volume"))
			localcmd(sprintf("seta cl_voip_play %f\n", cvar("_ugly_cl_voip_volume")));
		else
			localcmd("seta cl_voip_play 1\n"); /* else assume full volume */
	} else {
		/* save the old value, whatever that may have been */
		localcmd(sprintf("seta _ugly_cl_voip_volume %f\n", cvar("cl_voip_play")));
		localcmd("seta cl_voip_play 0\n");
	}
}
void
cz_cxEnableMicChanged(float val)
{
	/* engine won't allow us to use localcmd() for this because
	   it falsely believes the menu is the server...
	   but guess what, cvar_set won't work either. so if your console
	   complains about this, this either has not yet been fixed or you are
	   using a really old engine. sorry for this inconvenience. */
	if (val)
		localcmd("seta cl_voip_send 1\n");
	else
		localcmd("seta cl_voip_send 4\n"); /* hack: disables to anything other than rtp */
}

void
menu_customize_init(void)
{
	int sid = 0;
	g_sprayscount = 0;

	/* scan and cache the sprays */
	searchhandle searchy = search_begin("logos/*.*", SEARCH_NAMESORT, TRUE);
	for (int i = 0; i < search_getsize(searchy); i++) {
		string full = search_getfilename(searchy, i);
		string filename = substring(search_getfilename(searchy, i), 0, -5);
		string extension = substring(full, strlen(full) - 3, 3);
		
		/*if (extension == "bmp" || extension == "png" || extension == "jpg")*/ {
			g_sprayscount++;
		}
	}

	if (g_sprayscount >= 1) {
		/* only allocate what we truly need */
		g_sprays = memalloc(sizeof(string) * g_sprayscount);
		for (int i = 0; i < search_getsize(searchy); i++) {
			string full = search_getfilename(searchy, i);
			string filename = substring(full, 0, -5);
			string extension = substring(full, strlen(full) - 3, 3);

			/*if (extension == "bmp" || extension == "png" || extension == "jpg")*/ {
				g_sprays[sid] = precache_pic(full);
				sid++;
			}
		}
		search_end(searchy);
	} else {
		games[gameinfo_current].nosprays = 1;
	}

	/* scan and cache the models */
	searchy = search_begin("models/player/*/*.bmp:models/player/*/*.tga:models/players/*/icon_blue.tga", SEARCH_MULTISEARCH | SEARCH_NAMESORT, TRUE);

	g_modelcount = search_getsize(searchy);

	if (g_modelcount >= 1) {
		g_models = memalloc(sizeof(string) * g_modelcount);
		for (int i = 0; i < g_modelcount; i++) {
			g_models[i] = substring(search_getfilename(searchy, i), 0, -5);
			precache_pic(g_models[i]);
		}
		search_end(searchy);
	} else {
		games[gameinfo_current].nomodels = 1;
	}
	
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

	cz_cxHQModels = spawn(CCheckBox);
	cz_cxHQModels.SetPos(52,223);
	cz_cxHQModels.SetValue(cvar("cl_himodels"));
	cz_cxHQModels.SetCallback(cz_cxHQModelsChanged);
	Widget_Add(fn_customize, cz_cxHQModels);

	cz_cxEnableVoice = spawn(CCheckBox);
	cz_cxEnableVoice.SetPos(52,351);
	cz_cxEnableVoice.SetValue(cvar("cl_voip_play"));
	if (cvar("cl_voip_play") > 0)
		cz_cxEnableVoice.SetValue(1);
	else
		cz_cxEnableVoice.SetValue(0);
	cz_cxEnableVoice.SetCallback(cz_cxEnableVoiceChanged);
	Widget_Add(fn_customize, cz_cxEnableVoice);

	cz_cxEnableMic = spawn(CCheckBox);
	cz_cxEnableMic.SetPos(52,391);
	cz_cxEnableMic.SetCallback(cz_cxEnableMicChanged);
	if (cvar("cl_voip_send") == 4)
		cz_cxEnableMic.SetValue(0);
	else
		cz_cxEnableMic.SetValue(1);
	Widget_Add(fn_customize, cz_cxEnableMic);

	cz_sldTransmitVol = spawn(CSlider);
	cz_sldTransmitVol.SetPos(213,377);
	cz_sldTransmitVol.SetValue(cvar("cl_voip_capturingvol"));
	cz_sldTransmitVol.SetCallback(cz_sldTransmitVolChanged);
	Widget_Add(fn_customize, cz_sldTransmitVol);
		
	cz_sldReceiveVol = spawn(CSlider);
	cz_sldReceiveVol.SetPos(213,428);
	cz_sldReceiveVol.SetValue(cvar("cl_voip_play"));
	cz_sldReceiveVol.SetCallback(cz_sldReceiveVolChanged);
	Widget_Add(fn_customize, cz_sldReceiveVol);

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
#ifdef MODEL_PREVIEW
		static vector vecDistance = [ 45, 0, 0 ];
		static void ModelPreview_SetModel( string strModel ) {
			setmodel( g_ePreviewModel, strModel );
			AngleVectors( cz_3dModel.Get3DAngles() );
			cz_3dModel.Set3DPos( v_forward * -vecDistance[0] + v_right * vecDistance[1] + v_up * vecDistance[2] );

			/* TODO: ideally we'd like to update the submodel here according to
			   the cl_himodels cvar, but FTE doesn't like us doing that
			   apparently as skinobjects are not available directly upon
			   init. eventually I'll have to stage a sub-model update for
			   later. or maybe the engine should just get its stuff sorted.
			   for the time being, enjoy this message that I can point
			   to for when someone inexplicably points out the bug. */
				g_iPreviewmodelSubUpdate = 0;
		}
		static void ModelPreview_Draw ( void ) {
			static int initialized = FALSE;
			if ( !initialized ) {
				initialized = TRUE;
				g_ePreviewModel = spawn();
				g_ePreviewModel.angles[1] -= 180;
				ModelPreview_SetModel(sprintf("models/player/%s/%s.mdl", cvar_string("_cl_playermodel"), cvar_string("_cl_playermodel")));
			}
			addentity( g_ePreviewModel );
			g_ePreviewModel.frame1time += frametime;
			g_ePreviewModel.colormod = [cz_sldTopcolor.m_value, cz_sldBottomcolor.m_value, 2.0];
		}
		static void ModelPreview_Input ( float type, float x, float y, float flDevID ) {
			if (type == IE_KEYUP && x == K_MOUSE1 && Util_CheckMouse(414, 360, 64, 24) == TRUE) {
				g_iModel--;
				if (g_iModel < 0)
					g_iModel = g_modelcount - 1;

				cz_cbModelChanged();
				ModelPreview_SetModel(sprintf("%s.mdl", g_models[g_iModel]));
			}
			if (type == IE_KEYUP && x == K_MOUSE1 && Util_CheckMouse(510, 360, 64, 24) == TRUE) {
				g_iModel++;
				if (g_iModel >= g_modelcount)
					g_iModel = 0;

				cz_cbModelChanged();
				ModelPreview_SetModel(sprintf("%s.mdl", g_models[g_iModel]));
			}
			/*static int iMouseDrag = FALSE;
			static int iShiftDrag = FALSE;
			static vector vecDragOfs;
			vector vecDifference;

			int iMouseOver =  Util_MouseAbove( getmousepos(), cz_3dModel.m_parent.GetPos() + cz_3dModel.GetPos(), cz_3dModel.GetSize() );
			if ( flEVType == IE_KEYDOWN ) {
				if ( flKey == K_MOUSE1 && iMouseOver == TRUE ) {
					iMouseDrag = TRUE;
					vecDragOfs = getmousepos();
				} else if ( flKey == K_MWHEELUP && iMouseOver == TRUE ) {
					vecDistance[0] = bound( 0, --vecDistance[0], 512 );
					AngleVectors( cz_3dModel.Get3DAngles() );
					cz_3dModel.Set3DPos( v_forward * -vecDistance[0] + v_right * vecDistance[1] + v_up * vecDistance[2] );
				} else if ( flKey == K_MWHEELDOWN && iMouseOver == TRUE ) {
					vecDistance[0] = bound( 0, ++vecDistance[0], 512 );
					AngleVectors( cz_3dModel.Get3DAngles() );
					cz_3dModel.Set3DPos( v_forward * -vecDistance[0] + v_right * vecDistance[1] + v_up * vecDistance[2] );
				} else if ( flKey == K_LSHIFT && iMouseOver == TRUE ) {
					iShiftDrag = TRUE;
				}
			} else if ( flEVType == IE_KEYUP ) {
				if ( flKey == K_MOUSE1 ) {
					iMouseDrag = FALSE;
				} else if ( flKey == K_LSHIFT ) {
					iShiftDrag = FALSE;
				}
			}

			if ( iMouseDrag == TRUE && iShiftDrag == FALSE ) {
				if ( flEVType == IE_MOUSEABS ) {
					vecDifference = [ flChar, flKey ] - [ vecDragOfs[1], vecDragOfs[0] ];
					cz_3dModel.Set3DAngles( cz_3dModel.Get3DAngles() + vecDifference );
					AngleVectors( cz_3dModel.Get3DAngles() );
					cz_3dModel.Set3DPos( v_forward * -vecDistance[0] + v_right * vecDistance[1] + v_up * vecDistance[2] );
					vecDragOfs = getmousepos();
				}
			} else if ( iMouseDrag == TRUE && iShiftDrag == TRUE ) {
				if ( flEVType == IE_MOUSEABS ) {
					vecDifference = [ flChar, flKey ] - [ vecDragOfs[1], vecDragOfs[0] ];
					vecDistance[1] -= vecDifference[1];
					vecDistance[2] += vecDifference[0];
					cz_3dModel.Set3DPos( v_forward * -vecDistance[0] + v_right * vecDistance[1] + v_up * vecDistance[2] );
					vecDragOfs = getmousepos();
				}
			}*/
		}

		cz_3dModel = spawn(CUI3DView);
		cz_3dModel.SetPos(413,163);
		cz_3dModel.SetSize([164,190]);
		cz_3dModel.SetDrawFunc(ModelPreview_Draw);
		cz_3dModel.SetInputFunc(ModelPreview_Input);
		Widget_Add(fn_customize, cz_3dModel);
#else
		cz_psModel = spawn(CPictureSwitch);
		cz_psModel.SetPos(410,160);
		cz_psModel.SetSize(170,221);
		cz_psModel.SetPicSize(164,190);
		cz_psModel.SetPics(g_models);
		cz_psModel.SetMax(g_modelcount);
		cz_psModel.SetCallback(cz_cbModelChanged);
		cz_psModel.SetValueS(sprintf("models/player/%s/%s", cvar_string("_cl_playermodel"), cvar_string("_cl_playermodel")));
		Widget_Add(fn_customize, cz_psModel);
#endif

		cz_sldTopcolor = spawn(CSlider);
		cz_sldTopcolor.SetPos(410,410);
		cz_sldTopcolor.SetLength(170);
		cz_sldTopcolor.SetValue(cvar("_cl_topcolor"));
		cz_sldTopcolor.SetCallback(cz_sldTopcolorChanged);
		Widget_Add(fn_customize, cz_sldTopcolor);
		
		cz_sldBottomcolor = spawn(CSlider);
		cz_sldBottomcolor.SetPos(410,430);
		cz_sldBottomcolor.SetLength(170);
		cz_sldBottomcolor.SetValue(cvar("_cl_bottomcolor"));
		cz_sldBottomcolor.SetCallback(cz_sldBottomcolorChanged);
		Widget_Add(fn_customize, cz_sldBottomcolor);

		g_vecTopcolor = hsv2rgb(cvar("_cl_topcolor") * 360, 100, 100) / 255;
		g_vecBottomcolor = hsv2rgb(cvar("_cl_bottomcolor") * 360, 100, 100) / 255;
	}
}


/*
	cz_sldTransmitVol.SetPos(213,377);
	cz_sldTransmitVol.SetValue(cvar("cl_voip_capturingvol"));
	cz_sldTransmitVol.SetCallback(cz_sldTransmitVolChanged);
	Widget_Add(fn_customize, cz_sldTransmitVol);
		
	cz_sldReceiveVol = spawn(CSlider);
	cz_sldReceiveVol.SetPos(213,428);
*/

#define TEXTBTN_COLOR [1.0, 0.74, 0.22]
#define FRAME_COLOR [0.224, 0.224, 0.224]
void
menu_customize_draw(void)
{

	drawfill([g_menuofs[0] + 410,g_menuofs[1] + 160], [170, 221], FRAME_COLOR, 1.0f);
	drawfill([g_menuofs[0] + 413,g_menuofs[1] + 163], [164,190], [0,0,0], 1.0f);

	Widget_Draw(fn_customize);
	Header_Draw(HEAD_CUSTOMIZE);
	WLabel_Static(212, 140, m_reslbl[IDS_PLAYERINFO_NAME], 14, 14, [1,1,1],
					1.0f, 0, font_label);

	WField_Static(52 + 26, 225, "High quality models", 115, 64, [0.75, 0.75, 0.75],
					1.0f, 3, font_label_b);
	WField_Static(52 + 26, 353, "Enable voice in this mod.", 115, 64, [0.75, 0.75, 0.75],
					1.0f, 3, font_label_b);
	WField_Static(52 + 26, 393, "Use microphone for voice input.", 115, 64, [0.75, 0.75, 0.75],
					1.0f, 3, font_label_b);

	WLabel_Static(410, 140, "", HELPTXT_SIZE, HELPTXT_SIZE, [1,1,1],
						1.0f, 0, font_label);

	if (cvar("cl_voip_codec") == 2)
	WField_Static(52, 393+40, "* Uses Opus sound codec. Copyright © 2012-2023 by Xiph.Org Foundation.", 128, 64, [0.75, 0.75, 0.75],
					1.0f, 3, font_label);

	WLabel_Static(213, 377 - 16, "Voice Transmit Volume *", 14, 14, [1,1,1],
						1.0f, 0, font_label);
	WLabel_Static(213, 428 - 16, "Voice Receive Volume *", 14, 14, [1,1,1],
						1.0f, 0, font_label);


	WLabel_Static(410, 390, "Colors", 14, 14, [1,1,1],
						1.0f, 0, font_label);

	if (games[gameinfo_current].nomodels == 0) {
		WLabel_Static(410, 140, sprintf(m_reslbl[IDS_MODEL_NAME], cvar_string("_cl_playermodel")), 14, 14, [1,1,1],
						1.0f, 0, font_arial);
#ifdef MODEL_PREVIEW
		//drawfill([g_menuofs[0] + 414,g_menuofs[1] + 166], [64,12], g_vecTopcolor, 0.75f);
		//drawfill([g_menuofs[0] + 510,g_menuofs[1] + 166], [64,12], g_vecBottomcolor, 0.75f);

		/* fake buttons */
		WLabel_Static(414, 360, m_reslbl[IDS_PREVIOUS], 14, 14, col_prompt_text,
							1.0f, 0, font_arial);
		WLabel_StaticR(575, 360, m_reslbl[IDS_NEXT], 14, 14, col_prompt_text,
							1.0f, 0, font_arial);
#else
		drawfill([g_menuofs[0] + 414,g_menuofs[1] + 346], [64,12], g_vecTopcolor, 0.75f);
		drawfill([g_menuofs[0] + 510,g_menuofs[1] + 346], [64,12], g_vecBottomcolor, 0.75f);
#endif
	}

#ifdef MODEL_PREVIEW
	if (g_iPreviewmodelSubUpdate == 0) {
		cz_cxHQModelsChanged(cvar("cl_himodels"));
		g_iPreviewmodelSubUpdate = 1;
	}
#endif

	if (games[gameinfo_current].nosprays == 0)
	WLabel_Static(212, 203, m_reslbl[IDS_PROFILE_LOGO], 14, 14, [1,1,1],
					1.0f, 0, font_arial);

}

void
menu_customize_input(float evtype, float scanx, float chary, float devid)
{
	Widget_Input(fn_customize, evtype, scanx, chary, devid);
}
