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

CWidget fn_controls;
CMainButton ctrl_btnDefaults;
CMainButton ctrl_btnAdvanced;
CMainButton ctrl_btnOk;
CMainButton ctrl_btnCancel;
CFrame ctrl_frAct;

CListBox ctrl_lbActDesc;
CListBox ctrl_lbActBind1;
CListBox ctrl_lbActBind2;
CListBox ctrl_lbActBind3;
CScrollbar ctrl_sbControls;

CDialog mp_dgBind;

var int g_controlquery = -1;

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
	static float clicked_last;
	static int val_last;
	ctrl_lbActDesc.SetSelected(val);
	ctrl_lbActBind1.SetSelected(val);
	ctrl_lbActBind2.SetSelected(val);

	if (ctrl_lbActBind3.GetItem(val) == "blank") {
		return;
	}

	/* last item as last time */
	if (val_last == val) {
		/* double click timer */
		if (clicked_last > time) {
			g_controlquery = val;
		}
	}
	val_last = val;
	clicked_last = time + 0.5f;
}

void menu_controls_update(void)
{
	int c, j, k, i;

	c = ctrl_lbActBind3.GetCount();

	for (i = 0; i < c; i++) {
		string cmd = ctrl_lbActBind3.GetItem(i);

		if (cmd == " ") {
			continue;
		}

		tokenize(findkeysforcommand(cmd));

		/* clear */
		ctrl_lbActBind1.SetItem(i, " ");
		ctrl_lbActBind2.SetItem(i, " ");

		/* we only support the first two bindings */
		for (j = 0; j < 2; ++j) {
			k = stof(argv(j));

			if (k == -1) {
				continue;
			}

			if (j) {
				ctrl_lbActBind2.SetItem(i, keynumtostring(k));
			} else {
				ctrl_lbActBind1.SetItem(i, keynumtostring(k));
			}
		}
	}
}

void menu_controls_init(void)
{
	fn_controls = spawn(CWidget);
	mp_dgBind = spawn(CDialog);

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

	ctrl_lbActBind3 = spawn(CListBox);

	ctrl_sbControls = spawn(CScrollbar);
	ctrl_sbControls.SetPos(589,156);
	ctrl_sbControls.SetHeight(258+6);
	ctrl_sbControls.SetCallback(ctrl_sbcontrols_changed);
	Widget_Add(fn_controls, ctrl_sbControls);

	/* Parse the action list */
	int count = 0;
	string sTemp;
	filestream fs_actlst = fopen("gfx/shell/kb_act.lst", FILE_READ);

	/* count the valid entries */
	if (fs_actlst >= 0) {
		while ((sTemp = fgets(fs_actlst))) {
			/* anything but 2 keywords == invalid */
			if (tokenize_console(sTemp) == 2) {
				/* in FTE that command is different */
				if (argv(0) == "+voicerecord") {
					ctrl_lbActBind3.AddEntry("+voip");
				} else {
					ctrl_lbActBind3.AddEntry(argv(0));
				}

				ctrl_lbActDesc.AddEntry(argv(1));
				ctrl_lbActBind1.AddEntry(" ");
				ctrl_lbActBind2.AddEntry(" ");
				count++;
			}
		}
		fclose(fs_actlst);
	} else {
		error("Cannot parse gfx/shell/kb_act.lst!");
	}

	menu_controls_update();
	ctrl_sbControls.SetMax(count);
}

float g_ctrl_refresh;
void menu_controls_draw(void)
{

	Widget_Draw(fn_controls);
	drawpic([g_menuofs[0]+45,g_menuofs[1]+45], g_bmp[HEAD_CONTROLS],[460,80], [1,1,1], 1.0f, 1);

	WField_Static(50,236+32, m_reslbl[IDS_CONTROLS_KEYHELP], 169, 64, col_help,
					1.0f, 1, font_label);

	if (g_controlquery >= 0) {
		mp_dgBind.Draw();
		WField_Static(162, 180, m_reslbl[IDS_BINDING_PROMPT], 320, 260,
						col_prompt_text, 1.0f, 2, font_label_p);
		WField_Static(162, 280, ctrl_lbActDesc.GetItem(g_controlquery), 320, 260,
						col_prompt_title, 1.0f, 2, font_label);
	}

	if (g_ctrl_refresh < time) {
		menu_controls_update();
		g_ctrl_refresh = time + 0.5f;
	}
}

void menu_controls_input(float evtype, float scanx, float chary, float devid)
{
	/* this comes first, or else the dialog will skip immediately */
	if (g_controlquery >= 0) {
		switch (evtype) {
		case IE_KEYDOWN:
			if (scanx == K_ESCAPE) {
				g_controlquery = -1;
			} else if (scanx == K_BACKSPACE) {
				localcmd(sprintf("unbind %s\n", ctrl_lbActBind1.GetItem(g_controlquery)));
				localcmd(sprintf("unbind %s\n", ctrl_lbActBind2.GetItem(g_controlquery)));
				g_controlquery = -1;
				g_ctrl_refresh = time + 0.1f;
			} else if (scanx > 0) {
				localcmd(sprintf("bind %s %s\n", keynumtostring(scanx), ctrl_lbActBind3.GetItem(g_controlquery)));
				g_controlquery = -1;
				g_ctrl_refresh = time + 0.1f;
			}
			break;
		}
	}

	Widget_Input(fn_controls, evtype, scanx, chary, devid);
}
