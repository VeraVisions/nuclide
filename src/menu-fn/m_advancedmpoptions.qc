/*
 * Copyright (c) 2016-2023 Vera Visions LLC.
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

CWidget fn_advmpoptions;
CMainButton advmpopt_btnDone;
CMainButton advmpopt_btnCancel;

void
advmpopt_btndone_start(void)
{
	static void advmpopt_btndone_end(void) {
		g_menupage = PAGE_CREATEGAME;
	}
	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(45,45,50,172);
	header.SetStartEndSize(460,80,156,26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_ADVANCED);
	header.SetExecute(advmpopt_btndone_end);
}

void
advmpopt_btncancel_start(void)
{
	static void advmpopt_btncancel_end(void) {
		g_menupage = PAGE_CREATEGAME;
	}
	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(45,45,50,172);
	header.SetStartEndSize(460,80,156,26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_ADVANCED);
	header.SetExecute(advmpopt_btncancel_end);
}

void
menu_advancedmpoptions_init(void)
{
	fn_advmpoptions = spawn(CWidget);
	advmpopt_btnDone = spawn(CMainButton);
	advmpopt_btnDone.SetImage(BTN_DONE);
	advmpopt_btnDone.SetExecute(advmpopt_btndone_start);
	advmpopt_btnDone.SetPos(50,140);
	Widget_Add(fn_advmpoptions, advmpopt_btnDone);

	advmpopt_btnCancel = spawn(CMainButton);
	advmpopt_btnCancel.SetImage(BTN_CANCEL);
	advmpopt_btnCancel.SetExecute(advmpopt_btncancel_start);
	advmpopt_btnCancel.SetPos(50,172);
	Widget_Add(fn_advmpoptions, advmpopt_btnCancel);

	Layout_FromFile("settings.scr", fn_advmpoptions);
}

void
menu_advancedmpoptions_draw(void)
{
	Widget_Draw(fn_advmpoptions);
	Header_Draw(HEAD_ADVOPTIONS);
}

void
menu_advancedmpoptions_input(float evtype, float scanx, float chary, float devid)
{
	Widget_Input(fn_advmpoptions, evtype, scanx, chary, devid);
}
