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

CFrame crl_frRooms;
CListBox crl_lbRooms;
CScrollbar crl_sbRooms;

var int crl_iLoading;

void
crl_addroom(string room)
{
	/* skip this thing. */
	if (room == "&SERVER")
		return;

	crl_lbRooms.AddEntry(room);
	crl_sbRooms.SetMax(crl_lbRooms.GetCount());
}

void
crl_clearrooms(void)
{
	crl_lbRooms.Clear();
	crl_sbRooms.SetMax(0);
	crl_iLoading = TRUE;
}

void
crl_roomsdone(void)
{
	crl_iLoading = FALSE;
}

void crl_btnjoin_start(void)
{
	static void cr_btncancel_end(void) {
		/* part the current channel, clear textbuffer and user list */
		irc_send(sprintf("PART %s\n", g_ircroom.m_strChannel));
		irc_clear();

		/* set the new current channel, attempt to join */
		g_ircroom.m_strChannel = crl_lbRooms.GetSelectedItem();
		irc_send(sprintf("JOIN %s\n", g_ircroom.m_strChannel));
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

void crl_rooms_changed(int val)
{
	crl_lbRooms.SetScroll(val);
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
	
	crl_frRooms = spawn(CFrame);
	crl_frRooms.SetPos(382,172);
	crl_frRooms.SetSize(208,288);
	Widget_Add(fn_chatroomslist, crl_frRooms);

	crl_lbRooms = spawn(CListBox);
	crl_lbRooms.SetPos(384,175);
	crl_lbRooms.SetSize(202-16,282);
	Widget_Add(fn_chatroomslist, crl_lbRooms);
	
	crl_sbRooms = spawn(CScrollbar);
	crl_sbRooms.SetPos(571,175);
	crl_sbRooms.SetHeight(282);
	crl_sbRooms.SetCallback(crl_rooms_changed);
	Widget_Add(fn_chatroomslist, crl_sbRooms);

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

	if (crl_iLoading) {
		cr_dgConnect.Draw();
		WField_Static(162, 180, "Connected to Frag-Net", 320, 260,
						col_prompt_text, 1.0f, 2, font_label_p);
		WField_Static(162, 280, "Retrieving Room List...", 320, 260,
						col_prompt_title, 1.0f, 2, font_label_p);
	}
}

void menu_chatroomslist_input(float evtype, float scanx, float chary, float devid)
{
	Widget_Input(fn_chatroomslist, evtype, scanx, chary, devid);
}
