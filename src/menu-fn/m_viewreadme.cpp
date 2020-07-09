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

CWidget vr_readme;
CMainButton vr_btnDone;

CFrame vr_frReadme;
CListBox vr_lbReadme;
CScrollbar vr_sbReadme;

void
vr_btndone_start(void)
{
	static void vr_btndone_end(void) {
		g_menupage = PAGE_MAIN;
	}
	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(45,45,70,376);
	header.SetStartEndSize(460,80,156,26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_README);
	header.SetExecute(vr_btndone_end);
}

void
vr_sbreadme_changed(int val)
{
	vr_lbReadme.SetScroll(val);
}

void
menu_viewreadme_init(void)
{
	vr_readme = spawn(CWidget);

	vr_btnDone = spawn(CMainButton);
	vr_btnDone.SetImage(BTN_DONE);
	vr_btnDone.SetExecute(vr_btndone_start);
	vr_btnDone.SetPos(50,140);
	Widget_Add(vr_readme, vr_btnDone);

	vr_frReadme = spawn(CFrame);
	vr_frReadme.SetPos(225,140);
	vr_frReadme.SetSize(364,290);
	Widget_Add(vr_readme, vr_frReadme);

	vr_lbReadme = spawn(CListBox);
	vr_lbReadme.SetPos(229,143);
	vr_lbReadme.SetSize(342,284);
	Widget_Add(vr_readme, vr_lbReadme);

	vr_sbReadme = spawn(CScrollbar);
	vr_sbReadme.SetPos(571,143);
	vr_sbReadme.SetHeight(284);
	vr_sbReadme.SetCallback(vr_sbreadme_changed);
	Widget_Add(vr_readme, vr_sbReadme);

	filestream rdme;
	string lstline;
	rdme = fopen("readme.txt", FILE_READ);
	if (rdme >= 0) {
		while((lstline = fgets(rdme))) {
			vr_lbReadme.AddWrapped(lstline);
		}
		fclose(rdme);
	}
	vr_sbReadme.SetMax(vr_lbReadme.GetCount());
}

void
menu_viewreadme_draw(void)
{
	Widget_Draw(vr_readme);
	drawpic([g_menuofs[0]+45,g_menuofs[1]+45], g_bmp[HEAD_README],[460,80], [1,1,1], 1.0f, 1);
}

void
menu_viewreadme_input(float evtype, float scanx, float chary, float devid)
{
	Widget_Input(vr_readme, evtype, scanx, chary, devid);
}
