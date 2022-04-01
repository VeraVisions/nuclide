/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

CWidget fn_configuration;
CMainButton cf_btnControls;
CMainButton cf_btnAudio;
CMainButton cf_btnVideo;
CMainButton cf_btnContentControl;
CMainButton cf_btnUpdate;
CMainButton cf_btnDone;

/* Button Callbacks */
void
btn_controls_start(void)
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

void
btn_audio_start(void)
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

void
btn_video_start(void)
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

void
btn_gore_start(void)
{
	static void btn_gore_end(void) {
		g_menupage = PAGE_CONTENTCONTROL;
	}
	localsound("../media/launch_upmenu1.wav");
	header.SetStartEndPos(50,236,45,45);
	header.SetStartEndSize(156,26,460,80);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_GORE);
	header.SetExecute(btn_gore_end);
}

void
cf_btnupdates_start(void)
{
	localsound("../media/launch_upmenu1.wav");
	g_menupage = PAGE_UPDATES;
}

void
cf_btndone_start(void)
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
void
menu_configuration_init(void)
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
	cf_btnContentControl.SetExecute(btn_gore_start);
	cf_btnContentControl.SetPos(50,236);
	Widget_Add(fn_configuration, cf_btnContentControl);
	
	cf_btnUpdate = spawn(CMainButton);
	cf_btnUpdate.SetImage(BTN_UPDATE);
	cf_btnUpdate.SetExecute(cf_btnupdates_start);
	cf_btnUpdate.SetPos(50,268);
	Widget_Add(fn_configuration, cf_btnUpdate);
	
	cf_btnDone = spawn(CMainButton);
	cf_btnDone.SetImage(BTN_DONE);
	cf_btnDone.SetExecute(cf_btndone_start);
	cf_btnDone.SetPos(50,300);
	Widget_Add(fn_configuration, cf_btnDone);	
}

/* Drawing */
void
menu_configuration_draw(void)
{
	Widget_Draw(fn_configuration);
	Header_Draw(HEAD_CONFIG);

	WLabel_Static(215, 148, m_reslbl[IDS_CFG_CONTROLHELP], HELPTXT_SIZE, HELPTXT_SIZE, col_help,
					1.0f, 0, font_label);
	WLabel_Static(215, 180, m_reslbl[IDS_CFG_AUDIOHELP], HELPTXT_SIZE, HELPTXT_SIZE, col_help,
					1.0f, 0, font_label);
	WLabel_Static(215, 212, m_reslbl[IDS_CFG_VIDHELP], HELPTXT_SIZE, HELPTXT_SIZE, col_help,
					1.0f, 0, font_label);
	WLabel_Static(215, 244, m_reslbl[IDS_CONFIGURE_GOREHELP], HELPTXT_SIZE, HELPTXT_SIZE, col_help,
					1.0f, 0, font_label);
	WLabel_Static(215, 276, m_reslbl[IDS_CONFIGURE_AUTOPATCHHELP], HELPTXT_SIZE, HELPTXT_SIZE, col_help,
					1.0f, 0, font_label);
	WLabel_Static(215, 308, m_reslbl[IDS_MULTI_DONEHELP], HELPTXT_SIZE, HELPTXT_SIZE, col_help,
					1.0f, 0, font_label);
}

void
menu_configuration_input(float evtype, float scanx, float chary, float devid)
{
	Widget_Input(fn_configuration, evtype, scanx, chary, devid);
}
