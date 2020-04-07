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

CWidget fn_advcustomize;
CMainButton ac_btnDone;
CMainButton ac_btnCancel;

void ac_btndone_start(void)
{
	static void ac_btndone_end(void) {
		g_menupage = PAGE_CUSTOMIZE;
	}
	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(45,45,50,172);
	header.SetStartEndSize(460,80,156,26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_ADVANCED);
	header.SetExecute(ac_btndone_end);
}
void ac_btncancel_start(void)
{
	static void ac_btncancel_end(void) {
		g_menupage = PAGE_CUSTOMIZE;
	}
	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(45,45,50,172);
	header.SetStartEndSize(460,80,156,26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_ADVANCED);
	header.SetExecute(ac_btncancel_end);
}

void menu_advancedcustomize_init(void)
{
	fn_advcustomize = spawn(CWidget);
	ac_btnDone = spawn(CMainButton);
	ac_btnDone.SetImage(BTN_DONE);
	ac_btnDone.SetExecute(ac_btndone_start);
	ac_btnDone.SetPos(50,140);
	Widget_Add(fn_advcustomize, ac_btnDone);

	ac_btnCancel = spawn(CMainButton);
	ac_btnCancel.SetImage(BTN_CANCEL);
	ac_btnCancel.SetExecute(ac_btncancel_start);
	ac_btnCancel.SetPos(50,172);
	Widget_Add(fn_advcustomize, ac_btnCancel);
}

void menu_advancedcustomize_draw(void)
{
	Widget_Draw(fn_advcustomize);
	drawpic([g_menuofs[0]+45,g_menuofs[1]+45], g_bmp[HEAD_ADVOPTIONS],[460,80], [1,1,1], 1.0f, 1);
}

void menu_advancedcustomize_input(float evtype, float scanx, float chary, float devid)
{
	Widget_Input(fn_advcustomize, evtype, scanx, chary, devid);
}
