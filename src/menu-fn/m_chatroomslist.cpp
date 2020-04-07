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

CWidget fn_chatroomslist;
CMainButton crl_btnJoin;
CMainButton crl_btnCreateRoom;
CMainButton crl_btnCancel;

var string g_crIRCchannel;

void crl_btnjoin_start(void)
{
	static void cr_btncancel_end(void) {
		g_menupage = PAGE_CHATROOMS;
	}
	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(30,70,30,70);
	header.SetStartEndSize(460,80,156,26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_ROOMS);
	header.SetExecute(cr_btncancel_end);
}

void crl_btncancel_start(void)
{
	static void crl_btncancel_end(void) {
		g_menupage = PAGE_CHATROOMS;
	}
	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(30,70,30,70);
	header.SetStartEndSize(460,80,156,26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_ROOMS);
	header.SetExecute(crl_btncancel_end);
}

void menu_chatroomslist_init(void)
{
	fn_chatroomslist = spawn(CWidget);
	crl_btnJoin = spawn(CMainButton);
	crl_btnJoin.SetImage(BTN_JOIN);
	crl_btnJoin.SetExecute(crl_btnjoin_start);
	crl_btnJoin.SetPos(50,140);
	Widget_Add(fn_chatroomslist, crl_btnJoin);

	crl_btnCreateRoom = spawn(CMainButton);
	crl_btnCreateRoom.SetImage(BTN_CREATEROOM);
	//crl_btnCreateRoom.SetExecute(cr_btncancel_start);
	crl_btnCreateRoom.SetPos(50,172);
	Widget_Add(fn_chatroomslist, crl_btnCreateRoom);

	crl_btnCancel = spawn(CMainButton);
	crl_btnCancel.SetImage(BTN_CANCEL);
	crl_btnCancel.SetExecute(crl_btncancel_start);
	crl_btnCancel.SetPos(50,204);
	Widget_Add(fn_chatroomslist, crl_btnCancel);
}

void menu_chatroomslist_draw(void)
{
	Widget_Draw(fn_chatroomslist);
	drawpic([g_menuofs[0]+45,g_menuofs[1]+45], g_bmp[HEAD_ROOMS],[460,80], [1,1,1], 1.0f, 1);
	drawpic([g_menuofs[0]+550,g_menuofs[1]+10], "gfx/shell/fragnet",[80,80], [1,1,1], 1.0f, 0);
}

void menu_chatroomslist_input(float evtype, float scanx, float chary, float devid)
{
	Widget_Input(fn_chatroomslist, evtype, scanx, chary, devid);
}
