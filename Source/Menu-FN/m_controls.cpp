/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

CWidget fn_controls;
CMainButton ctrl_btnDefaults;
CMainButton ctrl_btnAdvanced;
CMainButton ctrl_btnOk;
CMainButton ctrl_btnCancel;
CFrame ctrl_frAct;

CListBox ctrl_lbActDesc;
CListBox ctrl_lbActBind1;
CListBox ctrl_lbActBind2;
CScrollbar ctrl_sbControls;

void ctrl_btnok_start(void)
{
	static void ctrl_btnok_end(void) {
		g_menupage = PAGE_CONFIGURATION;
	}

	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(45, 45, 50, 140);
	header.SetStartEndSize(460, 80, 156, 26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_CONTROLS);
	header.SetExecute(ctrl_btnok_end);
}
void ctrl_btncancel_start(void)
{
	static void ctrl_btnok_end(void) {
		g_menupage = PAGE_CONFIGURATION;
	}

	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(45, 45, 50, 172);
	header.SetStartEndSize(460, 80, 156, 26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_CONTROLS);
	header.SetExecute(ctrl_btnok_end);
}
void ctrl_sbcontrols_changed(int val)
{
	ctrl_lbActDesc.SetScroll(val);
	ctrl_lbActBind1.SetScroll(val);
	ctrl_lbActBind2.SetScroll(val);
}
void ctrl_lb_clicked(int val)
{
	ctrl_lbActDesc.SetSelected(val);
	ctrl_lbActBind1.SetSelected(val);
	ctrl_lbActBind2.SetSelected(val);
}

void menu_controls_init(void)
{
	fn_controls = spawn(CWidget);

	ctrl_btnDefaults = spawn(CMainButton);
	ctrl_btnDefaults.SetImage(BTN_DEFAULTS);
	//ctrl_btnDefaults.SetExecute(ctrl_btnok_start);
	ctrl_btnDefaults.SetPos(50,140);
	Widget_Add(fn_controls, ctrl_btnDefaults);

	ctrl_btnAdvanced = spawn(CMainButton);
	ctrl_btnAdvanced.SetImage(BTN_ADVCONTROLS);
	//ctrl_btnAdvanced.SetExecute(ctrl_btnok_start);
	ctrl_btnAdvanced.SetPos(50,172);
	Widget_Add(fn_controls, ctrl_btnAdvanced);

	ctrl_btnOk = spawn(CMainButton);
	ctrl_btnOk.SetImage(BTN_OK);
	ctrl_btnOk.SetExecute(ctrl_btnok_start);
	ctrl_btnOk.SetPos(50,204);
	Widget_Add(fn_controls, ctrl_btnOk);

	ctrl_btnCancel = spawn(CMainButton);
	ctrl_btnCancel.SetImage(BTN_CANCEL);
	ctrl_btnCancel.SetExecute(ctrl_btncancel_start);
	ctrl_btnCancel.SetPos(50,236);
	Widget_Add(fn_controls, ctrl_btnCancel);

	ctrl_frAct = spawn(CFrame);
	ctrl_frAct.SetPos(226,156);
	ctrl_frAct.SetSize(363,264);
	Widget_Add(fn_controls, ctrl_frAct);

	ctrl_lbActDesc = spawn(CListBox);
	ctrl_lbActDesc.SetPos(229,159);
	ctrl_lbActDesc.SetSize(165,258);
	ctrl_lbActDesc.SetChanged(ctrl_lb_clicked);
	Widget_Add(fn_controls, ctrl_lbActDesc);

	ctrl_lbActBind1 = spawn(CListBox);
	ctrl_lbActBind1.SetPos(399,159);
	ctrl_lbActBind1.SetSize(99,258);
	ctrl_lbActBind1.SetChanged(ctrl_lb_clicked);
	Widget_Add(fn_controls, ctrl_lbActBind1);

	ctrl_lbActBind2 = spawn(CListBox);
	ctrl_lbActBind2.SetPos(503,159);
	ctrl_lbActBind2.SetSize(83,258);
	ctrl_lbActBind2.SetChanged(ctrl_lb_clicked);
	Widget_Add(fn_controls, ctrl_lbActBind2);

	ctrl_sbControls = spawn(CScrollbar);
	ctrl_sbControls.SetPos(589,156);
	ctrl_sbControls.SetHeight(258+6);
	ctrl_sbControls.SetCallback(ctrl_sbcontrols_changed);
	Widget_Add(fn_controls, ctrl_sbControls);

	/* Parse the action list */
	int count = 0;
	string sTemp;
	filestream fs_actlst = fopen("gfx/shell/kb_act.lst", FILE_READ);

	/* Count the valid entries */
	if (fs_actlst >= 0) {
		while ((sTemp = fgets(fs_actlst))) {
			if (tokenize_console(sTemp) == 2) {
				if (argv(0) == "blank") {
					ctrl_lbActBind1.AddEntry(" ");
				} else if (argv(0) != "+voicerecord") {
					ctrl_lbActBind1.AddEntry(argv(0));
				} else {
					ctrl_lbActBind1.AddEntry("+voip");
				}
				ctrl_lbActDesc.AddEntry(argv(1));
				count++;
			}
		}
		fclose(fs_actlst);
	} else {
		error("Cannot parse gfx/shell/kb_act.lst!");
	}

	ctrl_sbControls.SetMax(count);
}

void menu_controls_draw(void)
{
	Widget_Draw(fn_controls);
	drawpic([g_menuofs[0]+45,g_menuofs[1]+45], g_bmp[HEAD_CONTROLS],[460,80], [1,1,1], 1.0f, 1);
}

void menu_controls_input(float evtype, float scanx, float chary, float devid)
{
	Widget_Input(fn_controls, evtype, scanx, chary, devid);
}
