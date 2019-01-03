/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

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
