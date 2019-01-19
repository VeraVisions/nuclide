/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

CWidget fn_chatrooms;
CMainButton cr_btnJoin;
CMainButton cr_btnCreateRoom;
CMainButton cr_btnCancel;

void cr_btncancel_start(void)
{
	static void cr_btncancel_end(void) {
		g_menupage = PAGE_MULTIPLAYER;
	}
	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(45,45,50,236);
	header.SetStartEndSize(460,80,156,26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_MULTI);
	header.SetExecute(cr_btncancel_end);
}

void menu_chatrooms_init(void)
{	
	fn_chatrooms = spawn(CWidget);
	cr_btnJoin = spawn(CMainButton);
	cr_btnJoin.SetImage(BTN_JOIN);
	//cr_btnJoin.SetExecute(cr_btncancel_start);
	cr_btnJoin.SetPos(50,140);
	Widget_Add(fn_chatrooms, cr_btnJoin);

	cr_btnCreateRoom = spawn(CMainButton);
	cr_btnCreateRoom.SetImage(BTN_CREATEROOM);
	//cr_btnCreateRoom.SetExecute(cr_btncancel_start);
	cr_btnCreateRoom.SetPos(50,172);
	Widget_Add(fn_chatrooms, cr_btnCreateRoom);

	cr_btnCancel = spawn(CMainButton);
	cr_btnCancel.SetImage(BTN_CANCEL);
	cr_btnCancel.SetExecute(cr_btncancel_start);
	cr_btnCancel.SetPos(50,204);
	Widget_Add(fn_chatrooms, cr_btnCancel);
}

void menu_chatrooms_draw(void)
{
	Widget_Draw(fn_chatrooms);
	drawpic([g_menuofs[0]+45,g_menuofs[1]+45], g_bmp[HEAD_ROOMS],[460,80], [1,1,1], 1.0f, 1);
}

void menu_chatrooms_input(float evtype, float scanx, float chary, float devid)
{
	Widget_Input(fn_chatrooms, evtype, scanx, chary, devid);
}
