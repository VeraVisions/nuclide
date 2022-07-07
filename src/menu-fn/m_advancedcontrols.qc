/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

CWidget fn_advcontrols;
CCheckBox acn_cbCrosshair;
CCheckBox acn_cbReverseMouse;
CCheckBox acn_cbMouseLook;
CCheckBox acn_cbLookSpring;
CCheckBox acn_cbLookStrafe;
CCheckBox acn_cbMouseFilter;
CCheckBox acn_cbJoystick;
CCheckBox acn_cbJoystickLook;
CCheckBox acn_cbAutoAim;
CSlider acn_sldMouseSpeed;
CMainButton acn_btnDone;

/* Button Callbacks */
void
acn_btndone_start(void)
{
	static void acn_btndone_end(void) {
		g_menupage = PAGE_CONTROLS;
	}
	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(45,45,50,172);
	header.SetStartEndSize(460,80,156,26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_ADVANCED);
	header.SetExecute(acn_btndone_end);
}

void
acn_cbcrosshair_changed(float val)
{
	cvar_set("crosshair", ftos(1-val));
}

void
acn_cbreversemouse_changed(float val)
{
	float pitch;

	if (val) {
		/* make sure it'll be negative */
		pitch = fabs(cvar("m_pitch")) * -1;
	} else {
		pitch = fabs(cvar("m_pitch"));
	}

	cvar_set("m_pitch", ftos(pitch));
}

void
acn_cbmlook_changed(float val)
{
	acn_cbMouseLook.SetValue(1);
}

void
acn_cblookspring_changed(float val)
{
	cvar_set("lookspring", ftos(val));
}

void
acn_cblookstrafe_changed(float val)
{
	cvar_set("lookstrafe", ftos(val));
}

void
acn_cbmfilter_changed(float val)
{
	cvar_set("m_filter", ftos(val));
}

void
acn_cbjoystick_changed(float val)
{
	acn_cbJoystick.SetValue(0);
}

void
acn_cbjoylook_changed(float val)
{
	acn_cbJoystickLook.SetValue(0);
}

void
acn_cbautoaim_changed(float val)
{
	cvar_set("sv_aim", ftos(1 - val));
}

void
acn_sldsensitivity_changed(float val)
{
	cvar_set("sensitivity", ftos(val * 10));
}

void
menu_advancedcontrols_init(void)
{
	fn_advcontrols = spawn(CWidget);

	acn_cbCrosshair = spawn(CCheckBox);
	acn_cbCrosshair.SetPos(52,142);
	acn_cbCrosshair.SetCallback(acn_cbcrosshair_changed);
	acn_cbCrosshair.SetValue(cvar("crosshair"));
	Widget_Add(fn_advcontrols, acn_cbCrosshair);

	acn_cbReverseMouse = spawn(CCheckBox);
	acn_cbReverseMouse.SetPos(52,172);
	acn_cbReverseMouse.SetCallback(acn_cbreversemouse_changed);
	acn_cbReverseMouse.SetValue(cvar("m_pitch") < 0.0 ? TRUE : FALSE);
	Widget_Add(fn_advcontrols, acn_cbReverseMouse);

	acn_cbMouseLook = spawn(CCheckBox);
	acn_cbMouseLook.SetPos(52,202);
	acn_cbMouseLook.SetValue(1);
	acn_cbMouseLook.SetCallback(acn_cbmlook_changed);
	Widget_Add(fn_advcontrols, acn_cbMouseLook);

	acn_cbLookSpring = spawn(CCheckBox);
	acn_cbLookSpring.SetPos(52,232);
	acn_cbLookSpring.SetCallback(acn_cblookspring_changed);
	acn_cbLookSpring.SetValue(cvar("lookspring"));
	Widget_Add(fn_advcontrols, acn_cbLookSpring);

	acn_cbLookStrafe = spawn(CCheckBox);
	acn_cbLookStrafe.SetPos(52,262);
	acn_cbLookStrafe.SetCallback(acn_cblookstrafe_changed);
	acn_cbLookStrafe.SetValue(cvar("lookstrafe"));
	Widget_Add(fn_advcontrols, acn_cbLookStrafe);

	acn_cbMouseFilter = spawn(CCheckBox);
	acn_cbMouseFilter.SetPos(52,292);
	acn_cbMouseFilter.SetCallback(acn_cbmfilter_changed);
	acn_cbMouseFilter.SetValue(cvar("m_filter"));
	Widget_Add(fn_advcontrols, acn_cbMouseFilter);

	acn_cbJoystick = spawn(CCheckBox);
	acn_cbJoystick.SetPos(52,322);
	acn_cbJoystick.SetValue(0);
	acn_cbJoystick.SetCallback(acn_cbjoystick_changed);
	Widget_Add(fn_advcontrols, acn_cbJoystick);

	acn_cbJoystickLook = spawn(CCheckBox);
	acn_cbJoystickLook.SetPos(52,352);
	acn_cbJoystickLook.SetValue(0);
	acn_cbJoystickLook.SetCallback(acn_cbjoylook_changed);
	Widget_Add(fn_advcontrols, acn_cbJoystickLook);

	acn_cbAutoAim = spawn(CCheckBox);
	acn_cbAutoAim.SetPos(52,382);
	acn_cbAutoAim.SetCallback(acn_cbautoaim_changed);
	acn_cbAutoAim.SetValue(1 - cvar("sv_aim"));
	Widget_Add(fn_advcontrols, acn_cbAutoAim);
	
	acn_sldMouseSpeed = spawn(CSlider);
	acn_sldMouseSpeed.SetPos(50,419);
	acn_sldMouseSpeed.SetValue((cvar("sensitivity") / 10));
	acn_sldMouseSpeed.SetCallback(acn_sldsensitivity_changed);
	Widget_Add(fn_advcontrols, acn_sldMouseSpeed);

	acn_btnDone = spawn(CMainButton);
	acn_btnDone.SetImage(BTN_DONE);
	acn_btnDone.SetExecute(acn_btndone_start);
	acn_btnDone.SetPos(50,440);
	Widget_Add(fn_advcontrols, acn_btnDone);
}

/*
CCheckBox acn_cbCrosshair;
CCheckBox acn_cbReverseMouse;
CCheckBox acn_cbMouseLook;
CCheckBox acn_cbLookSpring;
CCheckBox acn_cbLookStrafe;
CCheckBox acn_cbMouseFilter;
CCheckBox acn_cbJoystick;
CCheckBox acn_cbJoystickLook;
CCheckBox acn_cbAutoAim;
CSlider acn_sldMouseSpeed;
*/

void
menu_advancedcontrols_draw(void)
{
	Widget_Draw(fn_advcontrols);
	Header_Draw(HEAD_ADVANCED);

	/* now come the checkbox / slider labels */
	WLabel_Static(80, 148,
	              m_reslbl[IDS_OPTS_CROSSHAIR], 12, 12,
	              [0.75,0.75,0.75], 1.0f, 0, font_label_b);
	WField_Static(220, 148,
	              m_reslbl[IDS_OPTS_CROSSHAIRHELP], 410, 30,
	              [0.75,0.75,0.75], 1.0f, 3, font_label);

	WLabel_Static(80, 178,
	              m_reslbl[IDS_OPTS_REVERSE], 12, 12,
	              [0.75,0.75,0.75], 1.0f, 0, font_label_b);
	WField_Static(220, 178,
	              m_reslbl[IDS_OPTS_REVERSEHELP], 410, 30,
	              [0.75,0.75,0.75], 1.0f, 3, font_label);

	WLabel_Static(80, 208,
	              m_reslbl[IDS_OPTS_MLOOK], 12, 12,
	              [0.75,0.75,0.75], 1.0f, 0, font_label_b);
	WField_Static(220, 208,
	              m_reslbl[IDS_OPTS_MLOOKHELP], 410, 30,
	              [0.75,0.75,0.75], 1.0f, 3, font_label);

	WLabel_Static(80, 238,
	              m_reslbl[IDS_OPTS_LOOKSPRING], 12, 12,
	              [0.75,0.75,0.75], 1.0f, 0, font_label_b);
	WField_Static(220, 238,
	              m_reslbl[IDS_OPTS_LOOKSPRINGHELP], 410, 30,
	              [0.75,0.75,0.75], 1.0f, 3, font_label);

	WLabel_Static(80, 268,
	              m_reslbl[IDS_OPTS_LOOKSTRAFE], 12, 12,
	              [0.75,0.75,0.75], 1.0f, 0, font_label);
	WField_Static(220, 268,
	              m_reslbl[IDS_OPTS_LOOKSTRAFEHELP], 410, 30,
	              [0.75,0.75,0.75], 1.0f, 3, font_label);

	WLabel_Static(80, 298,
	              m_reslbl[IDS_OPTS_MFILTER], 12, 12,
	              [0.75,0.75,0.75], 1.0f, 0, font_label_b);
	WField_Static(220, 298,
	              m_reslbl[IDS_OPTS_MFILTERHELP], 410, 30,
	              [0.75,0.75,0.75], 1.0f, 3, font_label);

	WLabel_Static(80, 328,
	              m_reslbl[IDS_OPTS_JOYSTICK], 12, 12,
	              [0.75,0.75,0.75], 1.0f, 0, font_label_b);
	WField_Static(220, 328,
	              m_reslbl[IDS_OPTS_JOYSTICKHELP], 410, 30,
	              [0.75,0.75,0.75], 1.0f, 3, font_label);

	WLabel_Static(80, 358,
	              m_reslbl[IDS_OPTS_JLOOK], 12, 12,
	              [0.75,0.75,0.75], 1.0f, 0, font_label_b);
	WField_Static(220, 358,
	              m_reslbl[IDS_OPTS_JLOOKHELP], 410, 30,
	              [0.75,0.75,0.75], 1.0f, 3, font_label);

	WLabel_Static(80, 388,
	              m_reslbl[IDS_OPTS_AUTOAIM], 12, 12,
	              [0.75,0.75,0.75], 1.0f, 0, font_label_b);
	WField_Static(220, 388,
	              m_reslbl[IDS_OPTS_AUTOAIMHELP], 410, 30,
	              [0.75,0.75,0.75], 1.0f, 3, font_label);

	WField_Static(220, 419,
	              m_reslbl[IDS_OPTS_SENSITIVITYHELP], 410, 30,
	              [0.75,0.75,0.75], 1.0f, 3, font_label);
}

void
menu_advancedcontrols_input(float evtype, float scanx, float chary, float devid)
{
	Widget_Input(fn_advcontrols, evtype, scanx, chary, devid);
}
