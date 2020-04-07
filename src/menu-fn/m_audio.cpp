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

CWidget fn_audio;
CMainButton au_btnDone;
CSlider au_sldVolume;
CSlider au_sldSuitVolume;
CCheckBox au_cxCDMusic;
CCheckBox au_cxHQSound;
CCheckBox au_cxA3DSound;
CCheckBox au_cxEAXSound;

/* in the original WON menu, there is no music control */
#ifndef ACCURATE
CSlider au_sldMusicVolume;
#endif

/* Button Callbacks */
void au_btndone_start(void)
{
	static void au_btndone_end(void) {
		g_menupage = PAGE_CONFIGURATION;
	}
	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(45,45,50,172);
	header.SetStartEndSize(460,80,156,26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_AUDIO);
	header.SetExecute(au_btndone_end);
}
void au_sldvolume_changed(float val)
{
	cvar_set("volume", ftos(val));
}
void au_sldsuitvolume_changed(float val)
{
	cvar_set("suitvolume", ftos(val));
}

#ifndef ACCURATE
void au_sldmusicvolume_changed(float val)
{
	cvar_set("bgmvolume", ftos(val));
}
#endif

void au_cxcdmusic_changed(float val)
{
}
void au_cxhqsound_changed(float val)
{
	cvar_set("loadas8bit", ftos(1-val));
	localcmd("snd_restart");
}
void au_cxa3dsound_changed(float val)
{
	
}
void au_cxeaxsound_changed(float val)
{
	cvar_set("snd_eax", ftos(val));
}

void menu_audio_init(void)
{
	fn_audio = spawn(CWidget);
	au_btnDone = spawn(CMainButton);
	au_btnDone.SetImage(BTN_DONE);
	au_btnDone.SetExecute(au_btndone_start);
	au_btnDone.SetPos(50,140);
	Widget_Add(fn_audio, au_btnDone);
	
	au_sldVolume = spawn(CSlider);
	au_sldVolume.SetPos(206,168);
	au_sldVolume.SetValue(cvar("volume"));
	au_sldVolume.SetCallback(au_sldvolume_changed);
	Widget_Add(fn_audio, au_sldVolume);
	
	au_sldSuitVolume = spawn(CSlider);
	au_sldSuitVolume.SetPos(206,219);
	au_sldSuitVolume.SetValue(cvar("suitvolume"));
	au_sldSuitVolume.SetCallback(au_sldsuitvolume_changed);
	Widget_Add(fn_audio, au_sldSuitVolume);

#ifndef ACCURATE
	au_sldMusicVolume = spawn(CSlider);
	au_sldMusicVolume.SetPos(395,168);
	au_sldMusicVolume.SetValue(cvar("bgmvolume"));
	au_sldMusicVolume.SetCallback(au_sldmusicvolume_changed);
	Widget_Add(fn_audio, au_sldMusicVolume);
#endif
	
	au_cxCDMusic = spawn(CCheckBox);
	au_cxCDMusic.SetPos(208,244);
	au_cxCDMusic.SetCallback(au_cxcdmusic_changed);
	Widget_Add(fn_audio, au_cxCDMusic);
	
	au_cxHQSound = spawn(CCheckBox);
	au_cxHQSound.SetPos(208,276);
	au_cxHQSound.SetCallback(au_cxhqsound_changed);
	au_cxHQSound.SetValue(1-cvar("loadas8bit"));
	Widget_Add(fn_audio, au_cxHQSound);
	
	au_cxA3DSound = spawn(CCheckBox);
	au_cxA3DSound.SetPos(208,308);
	au_cxA3DSound.SetCallback(au_cxa3dsound_changed);
	Widget_Add(fn_audio, au_cxA3DSound);
	
	au_cxEAXSound = spawn(CCheckBox);
	au_cxEAXSound.SetPos(208,340);
	au_cxEAXSound.SetCallback(au_cxeaxsound_changed);
	Widget_Add(fn_audio, au_cxEAXSound);
}

void menu_audio_draw(void)
{
	Widget_Draw(fn_audio);
	drawpic([g_menuofs[0]+45,g_menuofs[1]+45], g_bmp[HEAD_AUDIO],[460,80], [1,1,1], 1.0f, 1);
	
	WLabel_Static(206, 143, m_reslbl[IDS_AUDIO_VOLUME], 14, 14, [1,1,1],
					1.0f, 0, font_label_b);
	WLabel_Static(206, 194, m_reslbl[IDS_AUDIO_SUITVOL], 14, 14, [1,1,1],
					1.0f, 0, font_label_b);

	WLabel_Static(232, 251, m_reslbl[IDS_AUDIO_USECD], 12, 12, [0.75,0.75,0.75],
					1.0f, 0, font_label_b);
	WLabel_Static(232, 283, m_reslbl[IDS_AUDIO_HIGHQUALITY], 12, 12, [0.75,0.75,0.75],
					1.0f, 0, font_label_b);
	WLabel_Static(232, 315, m_reslbl[IDS_AUDIO_A3D], 12, 12, [0.75,0.75,0.75],
					1.0f, 0, font_label_b);
	WLabel_Static(232, 347, m_reslbl[IDS_AUDIO_EAX], 12, 12, [0.75,0.75,0.75],
					1.0f, 0, font_label_b);

#ifdef ACCURATE
	WField_Static(395, 133, m_reslbl[IDS_AUDIO_CDHINT], 169, 64, col_help,
					1.0f, 1, font_label);
#else
	WLabel_Static(395, 143, "Music volume:", 14, 14, [1,1,1],
					1.0f, 0, font_label_b);
#endif
}

void menu_audio_input(float evtype, float scanx, float chary, float devid)
{
	Widget_Input(fn_audio, evtype, scanx, chary, devid);
}
