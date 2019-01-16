/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

CWidget fn_configuration;
CMainButton cf_btnControls;
CMainButton cf_btnAudio;
CMainButton cf_btnVideo;
CMainButton cf_btnContentControl;
CMainButton cf_btnUpdate;
CMainButton cf_btnDone;

/* Button Callbacks */
void btn_controls_start(void)
{
	static void btn_controls_end(void) {
		g_menupage = PAGE_CONTROLS;
	}
	localsound("../media/launch_upmenu1.wav");
	header.SetStartEndPos(50,140,45,45);
	header.SetStartEndSize(156,26,460,80);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_CONTROLS);
	header.SetExecute(btn_controls_end);
}
void btn_audio_start(void)
{
	static void btn_audio_end(void) {
		g_menupage = PAGE_AUDIO;
	}
	localsound("../media/launch_upmenu1.wav");
	header.SetStartEndPos(50,172,45,45);
	header.SetStartEndSize(156,26,460,80);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_AUDIO);
	header.SetExecute(btn_audio_end);
}
void btn_video_start(void)
{
	static void btn_video_end(void) {
		g_menupage = PAGE_VIDEO;
	}
	localsound("../media/launch_upmenu1.wav");
	header.SetStartEndPos(50,204,45,45);
	header.SetStartEndSize(156,26,460,80);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_VIDEO);
	header.SetExecute(btn_video_end);
}
void cf_btndone_start(void)
{
	static void cf_btndone_end(void) {
		g_menupage = PAGE_MAIN;
	}
	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(45,45,70,264);
	header.SetStartEndSize(460,80,156,26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_CONFIG);
	header.SetExecute(cf_btndone_end);
}

/* Init */
void menu_configuration_init(void)
{
	fn_configuration = spawn(CWidget);
	cf_btnControls = spawn(CMainButton);
	cf_btnControls.SetImage(BTN_CONTROLS);
	cf_btnControls.SetExecute(btn_controls_start);
	cf_btnControls.SetPos(50,140);
	Widget_Add(fn_configuration, cf_btnControls);
	
	cf_btnAudio = spawn(CMainButton);
	cf_btnAudio.SetImage(BTN_AUDIO);
	cf_btnAudio.SetExecute(btn_audio_start);
	cf_btnAudio.SetPos(50,172);
	Widget_Add(fn_configuration, cf_btnAudio);
	
	cf_btnVideo = spawn(CMainButton);
	cf_btnVideo.SetImage(BTN_VIDEO);
	cf_btnVideo.SetExecute(btn_video_start);
	cf_btnVideo.SetPos(50,204);
	Widget_Add(fn_configuration, cf_btnVideo);
	
	cf_btnContentControl = spawn(CMainButton);
	cf_btnContentControl.SetImage(BTN_CONTENTCONTROL);
	//cf_btnContentControl.SetExecute(btn_console);
	cf_btnContentControl.SetPos(50,236);
	Widget_Add(fn_configuration, cf_btnContentControl);
	
	cf_btnUpdate = spawn(CMainButton);
	cf_btnUpdate.SetImage(BTN_UPDATE);
	//cf_btnUpdate.SetExecute(btn_console);
	cf_btnUpdate.SetPos(50,268);
	Widget_Add(fn_configuration, cf_btnUpdate);
	
	cf_btnDone = spawn(CMainButton);
	cf_btnDone.SetImage(BTN_DONE);
	cf_btnDone.SetExecute(cf_btndone_start);
	cf_btnDone.SetPos(50,300);
	Widget_Add(fn_configuration, cf_btnDone);	
}

/* Drawing */
void menu_configuration_draw(void)
{
	Widget_Draw(fn_configuration);
	drawpic([g_menuofs[0]+45,g_menuofs[1]+45], g_bmp[HEAD_CONFIG],[460,80], [1,1,1], 1.0f, 1);

	WLabel_Static(215, 148, m_reslbl[IDS_CFG_CONTROLHELP], 10, 10, col_help,
					1.0f, 0, font_label);
	WLabel_Static(215, 180, m_reslbl[IDS_CFG_AUDIOHELP], 10, 10, col_help,
					1.0f, 0, font_label);
	WLabel_Static(215, 212, m_reslbl[IDS_CFG_VIDHELP], 10, 10, col_help,
					1.0f, 0, font_label);
	WLabel_Static(215, 244, m_reslbl[IDS_CONFIGURE_GOREHELP], 10, 10, col_help,
					1.0f, 0, font_label);
	WLabel_Static(215, 276, m_reslbl[IDS_CONFIGURE_AUTOPATCHHELP], 10, 10, col_help,
					1.0f, 0, font_label);
	WLabel_Static(215, 308, m_reslbl[IDS_MULTI_DONEHELP], 10, 10, col_help,
					1.0f, 0, font_label);
}

void menu_configuration_input(float evtype, float scanx, float chary, float devid)
{
	Widget_Input(fn_configuration, evtype, scanx, chary, devid);
}
