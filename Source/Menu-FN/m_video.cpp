/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

CWidget fn_video;
CMainButton vd_btnVidOptions;
CMainButton vd_btnVidModes;
CMainButton vd_btnDone;


void vd_vidoptions_start(void)
{
	static void vd_vidoptions_end(void) {
		g_menupage = PAGE_VIDEOOPTIONS;
	}
	localsound("../media/launch_upmenu1.wav");
	header.SetStartEndPos(50,140,45,45);
	header.SetStartEndSize(156,26,460,80);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_VIDOPTIONS);
	header.SetExecute(vd_vidoptions_end);
}
void vd_vidmodes_start(void)
{
	static void vd_vidmodes_end(void) {
		g_menupage = PAGE_VIDEOMODES;
	}
	localsound("../media/launch_upmenu1.wav");
	header.SetStartEndPos(50,172,45,45);
	header.SetStartEndSize(156,26,460,80);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_VIDMODES);
	header.SetExecute(vd_vidmodes_end);
}

void vd_btndone_start(void)
{
	static void vd_btndone_end(void) {
		g_menupage = PAGE_CONFIGURATION;
	}
	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(45,45,50,204);
	header.SetStartEndSize(460,80,156,26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_VIDEO);
	header.SetExecute(vd_btndone_end);
}

void menu_video_init(void)
{
	fn_video = spawn(CWidget);

	vd_btnVidOptions = spawn(CMainButton);
	vd_btnVidOptions.SetImage(BTN_VIDEOOPTIONS);
	vd_btnVidOptions.SetExecute(vd_vidoptions_start);
	vd_btnVidOptions.SetPos(50,140);
	Widget_Add(fn_video, vd_btnVidOptions);

	vd_btnVidModes = spawn(CMainButton);
	vd_btnVidModes.SetImage(BTN_VIDEOMODES);
	vd_btnVidModes.SetExecute(vd_vidmodes_start);
	vd_btnVidModes.SetPos(50,172);
	Widget_Add(fn_video, vd_btnVidModes);

	vd_btnDone = spawn(CMainButton);
	vd_btnDone.SetImage(BTN_DONE);
	vd_btnDone.SetExecute(vd_btndone_start);
	vd_btnDone.SetPos(50,204);
	Widget_Add(fn_video, vd_btnDone);
}

void menu_video_draw(void)
{
	Widget_Draw(fn_video);
	drawpic([g_menuofs[0]+45,g_menuofs[1]+45], g_bmp[HEAD_VIDEO],[460,80], [1,1,1], 1.0f, 1);
	WLabel_Static(215, 148, m_reslbl[IDS_VIDSELECT_OPTIONSHELP], 10, 10, col_help,
					1.0f, 0, font_label);
	WLabel_Static(215, 180, m_reslbl[IDS_VIDSELECT_MODESHELP], 10, 10, col_help,
					1.0f, 0, font_label);
	WLabel_Static(215, 212, m_reslbl[IDS_VIDSELECT_RETURNHELP], 10, 10, col_help,
					1.0f, 0, font_label);
}

void menu_video_input(float evtype, float scanx, float chary, float devid)
{
	Widget_Input(fn_video, evtype, scanx, chary, devid);
}
