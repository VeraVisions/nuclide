/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

CWidget fn_vidmodes;
CMainButton vm_btnOk;
CMainButton vm_btnCancel;
CCheckBox vm_cbWindowed;

CFrame vm_frRes;
CListBox vm_lbRes;
CScrollbar vm_sbRes;

static string g_resolutions[] = {
	"640x480 (4:3)",
	"800x600 (4:3)",
	"960x720 (4:3)",
	"1024x768 (4:3)",
	"1152x864 (4:3)",
	"1280x960 (4:3)",
	"1440x1080 (4:3)",
	"1600x1200 (4:3)",
	"1920x1440 (4:3)",
	"2048x1536 (4:3)",
	"1280x1024 (5:4)",
	"1800x1440 (5:4)",
	"2560x2048 (5:4)",
	"856x480 (16:9)",
	"1024x576 (16:9)",
	"1280x720 (16:9)",
	"1366x768 (16:9)",
	"1600x900 (16:9)",
	"1920x1080 (16:9)",
	"2048x1152 (16:9)",
	"2560x1440 (16:9)",
	"3840x2160 (16:9)",
	"4096x2304 (16:9)",
	"1024x640 (16x10)",
	"1152x720 (16x10)",
	"1280x800 (16x10)",
	"1440x900 (16x10)",
	"1680x1050 (16x10)",
	"1920x1200 (16x10)",
	"2304x1440 (16x10)",
	"2560x1600 (16x10)"
};

/* Button Callbacks */
void
vm_btnok_start(void)
{
	static void vm_btnok_end(void) {
		g_menupage = PAGE_VIDEO;
	}

	string res = vm_lbRes.GetSelectedItem();
	print("Switching resolution to ");
	print(res);
	print("\n");

	if (res) {
		tokenizebyseparator(res, "x");
		localcmd(sprintf("vid_width %s\n", argv(0)));
		localcmd(sprintf("vid_height %s\n", argv(1)));
		localcmd("vid_restart\n");
	}

	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(45, 45, 50, 172);
	header.SetStartEndSize(460, 80, 156, 26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_VIDMODES);
	header.SetExecute(vm_btnok_end);
}

void
vm_btncancel_start(void)
{
	static void vm_btncancel_end(void) {
		g_menupage = PAGE_VIDEO;
	}
	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(45, 45, 50, 172);
	header.SetStartEndSize(460, 80, 156, 26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_VIDMODES);
	header.SetExecute(vm_btncancel_end);
}

void
vm_cbwindowed_changed(float val)
{
	if (val) {
		cvar_set("vid_fullscreen", "0");
	} else {
		cvar_set("vid_fullscreen", "2");
	}
}
void
vm_sbres_changed(int val)
{
	vm_lbRes.SetScroll(val);
}

/* Init */
void
menu_videomodes_init(void)
{
	fn_vidmodes = spawn(CWidget);

	vm_btnOk = spawn(CMainButton);
	vm_btnOk.SetImage(BTN_OK);
	vm_btnOk.SetExecute(vm_btnok_start);
	vm_btnOk.SetPos(50, 140);
	Widget_Add(fn_vidmodes, vm_btnOk);

	vm_btnCancel = spawn(CMainButton);
	vm_btnCancel.SetImage(BTN_CANCEL);
	vm_btnCancel.SetExecute(vm_btncancel_start);
	vm_btnCancel.SetPos(50, 172);
	Widget_Add(fn_vidmodes, vm_btnCancel);

	vm_cbWindowed = spawn(CCheckBox);
	vm_cbWindowed.SetPos(248,386);
	if (cvar("vid_fullscreen") > 0) {
		vm_cbWindowed.SetValue(0);
	} else {
		vm_cbWindowed.SetValue(1);
	}
	vm_cbWindowed.SetCallback(vm_cbwindowed_changed);
	Widget_Add(fn_vidmodes, vm_cbWindowed);

	vm_frRes = spawn(CFrame);
	vm_frRes.SetPos(246,188);
	vm_frRes.SetSize(344,186);
	Widget_Add(fn_vidmodes, vm_frRes);

	vm_lbRes = spawn(CListBox);
	vm_lbRes.SetPos(249,191);
	vm_lbRes.SetSize(338,180);
	Widget_Add(fn_vidmodes, vm_lbRes);

	vm_sbRes = spawn(CScrollbar);
	vm_sbRes.SetPos(574,188);
	vm_sbRes.SetHeight(186);
	vm_sbRes.SetCallback(vm_sbres_changed);
	vm_sbRes.SetMax(g_resolutions.length);
	Widget_Add(fn_vidmodes, vm_sbRes);
	
	vector physres = getviewprop(VF_SCREENPSIZE);
	
	for (int i = 0; i < g_resolutions.length; i++) {
		tokenizebyseparator(g_resolutions[i], "x");
		if (stof(argv(0)) == physres[0] && stof(argv(1)) == physres[1]) {
			vm_lbRes.SetSelected(i, FALSE);
		}
		vm_lbRes.AddEntry(g_resolutions[i]);
	}
}

/* Draw */
void
menu_videomodes_draw(void)
{
	Widget_Draw(fn_vidmodes);
	Header_Draw(HEAD_VIDMODES);

	WLabel_Static(270, 393, m_reslbl[IDS_VIDMODE_WINDOWED], 12, 12, [0.75,0.75,0.75],
					1.0f, 0, font_arial);
	
	WField_Static(55, 333, m_reslbl[IDS_VID_HINT], 175, 117, col_help,
					1.0f, 1, font_arial);
}

/* Input */
void
menu_videomodes_input(float evtype, float x, float y, float devid)
{
	Widget_Input(fn_vidmodes, evtype, x, y, devid);
}
