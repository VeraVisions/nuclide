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

var float autocvar_vid_brightness = 0.0f;
var float autocvar_vid_gamma = 1.0f;

CWidget fn_vidoptions;
CMainButton vo_btnDone;
CSlider vo_sldScreensize;
CSlider vo_sldGamma;
CSlider vo_sldGlare;

/* Button Callbacks */
void
vo_btndone_start(void)
{
	static void vo_btndone_end(void) {
		g_menupage = PAGE_VIDEO;
		localcmd("cfg_save\n");
	}
	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(45, 45, 50, 140);
	header.SetStartEndSize(460, 80, 156, 26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_VIDOPTIONS);
	header.SetExecute(vo_btndone_end);
}

void
vo_sldscreensize_changed(float val)
{
	cvar_set("viewsize", ftos(floor(val * 120)));
}

void
vo_sldgamma_changed(float val)
{
	localcmd(sprintf("seta gamma %f; seta vid_gamma %f\n", val, val));
}

void
vo_sldglare_changed(float val)
{
	localcmd(sprintf("seta brightness %f; seta vid_brightness %f\n", val, val));
}

/* Init */
void
menu_videooptions_init(void)
{
	fn_vidoptions = spawn(CWidget);
	vo_btnDone = spawn(CMainButton);
	vo_btnDone.SetImage(BTN_DONE);
	vo_btnDone.SetExecute(vo_btndone_start);
	vo_btnDone.SetPos(50, 293);
	Widget_Add(fn_vidoptions, vo_btnDone);
	
	vo_sldScreensize = spawn(CSlider);
	vo_sldScreensize.SetPos(50,168);
	vo_sldScreensize.SetValue(cvar("viewsize") / 120);
	vo_sldScreensize.SetCallback(vo_sldscreensize_changed);
	Widget_Add(fn_vidoptions, vo_sldScreensize);
	
	vo_sldGamma = spawn(CSlider);
	vo_sldGamma.SetPos(50,219);
	vo_sldGamma.SetValue(cvar("gamma"));
	vo_sldGamma.SetCallback(vo_sldgamma_changed);
	Widget_Add(fn_vidoptions, vo_sldGamma);
	
	vo_sldGlare = spawn(CSlider);
	vo_sldGlare.SetPos(50,270);
	vo_sldGlare.SetValue(cvar("brightness") * 0.5);
	vo_sldGlare.SetCallback(vo_sldglare_changed);
	Widget_Add(fn_vidoptions, vo_sldGlare);
}

/* Drawing */
void
menu_videooptions_draw(void)
{
	Widget_Draw(fn_vidoptions);
	Header_Draw(HEAD_VIDOPTIONS);

	drawfill([g_menuofs[0] + 246, g_menuofs[1] + 140], [288, 280], 
			 [1,0,0], 1.0f);
	drawfill([g_menuofs[0] + 247, g_menuofs[1] + 141], [286, 278], 
			 [0.25,0.25,0.25], 1.0f);
	drawpic([g_menuofs[0] + 250, g_menuofs[1] + 141], g_bmp[GAMMA],
			[280,278], [1,1,1], 1.0f, 0);
			
	WLabel_Static(50, 143, m_reslbl[IDS_VIDEO_SCREENSIZE], 14, 14, [1,1,1],
					1.0f, 0, font_label_b);
	WLabel_Static(50, 193, m_reslbl[IDS_VIDEO_GAMMA], 14, 14, [1,1,1],
					1.0f, 0, font_label_b);
	WLabel_Static(50, 245, m_reslbl[IDS_VIDEO_GLARE], 14, 14, [1,1,1],
					1.0f, 0, font_label_b);
}

/* Input */
void
menu_videooptions_input(float evtype, float x, float y, float devid)
{
	Widget_Input(fn_vidoptions, evtype, x, y, devid);
}
