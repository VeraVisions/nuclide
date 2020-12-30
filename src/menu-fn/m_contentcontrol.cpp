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

CWidget cc_gore;
CMainButton cc_btnDone;
CCheckBox cc_cxHBlood;
CCheckBox cc_cxHGibs;
CCheckBox cc_cxABlood;
CCheckBox cc_cxAGibs;

var int autocvar_violence_hblood = 1;
var int autocvar_violence_ablood = 1;
var int autocvar_violence_hgibs = 1;
var int autocvar_violence_agibs = 1;

void
cc_btndone_start(void)
{
	static void cc_btndone_end(void) {
		g_menupage = PAGE_CONFIGURATION;
	}
	localsound("../media/launch_dnmenu1.wav");
	header.SetStartEndPos(45,45,50,236);
	header.SetStartEndSize(460,80,156,26);
	header.m_lerp = 0.0f;
	header.m_visible = TRUE;
	header.SetHeader(HEAD_GORE);
	header.SetExecute(cc_btndone_end);
}

void
cc_cxhblood_changed(float val)
{
	cvar_set("violence_hblood", ftos(val));
}

void
cc_cxhgibs_changed(float val)
{
	cvar_set("violence_hgibs", ftos(val));
}

void
cc_cxablood_changed(float val)
{
	cvar_set("violence_ablood", ftos(val));
}

void
cc_cxagibs_changed(float val)
{
	cvar_set("violence_agibs", ftos(val));
}

void
menu_contentcontrol_init(void)
{
	cc_gore = spawn(CWidget);
	cc_btnDone = spawn(CMainButton);
	cc_btnDone.SetImage(BTN_DONE);
	cc_btnDone.SetExecute(cc_btndone_start);
	cc_btnDone.SetPos(50,140);
	Widget_Add(cc_gore, cc_btnDone);

	cc_cxHBlood = spawn(CCheckBox);
	cc_cxHBlood.SetPos(208,244);
	cc_cxHBlood.SetCallback(cc_cxhblood_changed);
	cc_cxHBlood.SetValue(cvar("violence_hblood"));
	Widget_Add(cc_gore, cc_cxHBlood);

	cc_cxHGibs = spawn(CCheckBox);
	cc_cxHGibs.SetPos(208,276);
	cc_cxHGibs.SetCallback(cc_cxhgibs_changed);
	cc_cxHGibs.SetValue(cvar("violence_hgibs"));
	Widget_Add(cc_gore, cc_cxHGibs);

	cc_cxABlood = spawn(CCheckBox);
	cc_cxABlood.SetPos(208,308);
	cc_cxABlood.SetCallback(cc_cxablood_changed);
	cc_cxABlood.SetValue(cvar("violence_ablood"));
	Widget_Add(cc_gore, cc_cxABlood);

	cc_cxAGibs = spawn(CCheckBox);
	cc_cxAGibs.SetPos(208,340);
	cc_cxAGibs.SetCallback(cc_cxagibs_changed);
	cc_cxAGibs.SetValue(cvar("violence_agibs"));
	Widget_Add(cc_gore, cc_cxAGibs);
}

const string g_cc_descr =
	"You can control the level of violence present in the " \
	"game using the ceckboxes below. They will take affect " \
	"immediately but existing effects will still show up " \
	"regardless. So turn these off before starting a game.";

void
menu_contentcontrol_draw(void)
{
	Widget_Draw(cc_gore);
	Header_Draw(HEAD_GORE);

	WField_Static(208, 140, g_cc_descr, 256, 64, col_help,
					1.0f, 1, font_label);

	WLabel_Static(232, 251, "Human blood", 12, 12, [0.75,0.75,0.75],
					1.0f, 0, font_label_b);
	WLabel_Static(232, 283, "Human gibs", 12, 12, [0.75,0.75,0.75],
					1.0f, 0, font_label_b);
	WLabel_Static(232, 315, "Alien blood", 12, 12, [0.75,0.75,0.75],
					1.0f, 0, font_label_b);
	WLabel_Static(232, 347, "Alien gibs", 12, 12, [0.75,0.75,0.75],
					1.0f, 0, font_label_b);
}

void
menu_contentcontrol_input(float evtype, float scanx, float chary, float devid)
{
	Widget_Input(cc_gore, evtype, scanx, chary, devid);
}
