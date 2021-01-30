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

/* these are the key mapping for a SEGA Saturn controller in X360 mode */
#define K_SATURN_DPAD_UP 251
#define K_SATURN_DPAD_DOWN 252
#define K_SATURN_DPAD_LEFT 253
#define K_SATURN_DPAD_RIGHT 254

#define K_SATURN_A 190
#define K_SATURN_B 191
#define K_SATURN_C 197

#define K_SATURN_X 192
#define K_SATURN_Y 193
#define K_SATURN_Z 196

#define K_SATURN_LSHOULDER 194
#define K_SATURN_RSHOULDER 195

#define K_SATURN_START 199

var int autocvar_in_saturnmode = FALSE;

vector dots[12] = {
	[0, 32],
	[32, 32],
	[32, 0],
	[64, 0],
	[64, 32],
	[96, 32],
	[96, 64],
	[64, 64],
	[64, 96],
	[32, 96],
	[32, 64],
	[0, 64]
}

void
IN_Saturn_DrawMenu(void)
{
	if (!pSeat->m_iSaturnMenu)
		return;

	vector col = autocvar_con_color / 255;
	vector center;
	center = (g_hudmins + (g_hudres / 2)) - [48, 48];
	drawline(2, center + dots[0], center + dots[1], col, 1.0f);
	drawline(2, center + dots[1], center + dots[2], col, 1.0f);
	drawline(2, center + dots[2], center + dots[3], col, 1.0f);
	drawline(2, center + dots[3], center + dots[4], col, 1.0f);
	drawline(2, center + dots[4], center + dots[5], col, 1.0f);
	drawline(2, center + dots[5], center + dots[6], col, 1.0f);
	drawline(2, center + dots[6], center + dots[7], col, 1.0f);
	drawline(2, center + dots[7], center + dots[8], col, 1.0f);
	drawline(2, center + dots[8], center + dots[9], col, 1.0f);
	drawline(2, center + dots[9], center + dots[10], col, 1.0f);
	drawline(2, center + dots[10], center + dots[11], col, 1.0f);
	drawline(2, center + dots[11], center + dots[0], col, 1.0f);

	string textup = "RELOAD";
	string textdown = "FLASHLIGHT";
	string textleft = "PREVIOUS ITEM";
	string textright = "NEXT ITEM";
	drawfont = FONT_CON;
	center = (g_hudmins + (g_hudres / 2));
	drawstring(center + [0, -64] - [(stringwidth(textup, FALSE, [12,12]) / 2), 0], textup, [12,12], col, 1.0f, 0);
	drawstring(center + [0, 64] - [(stringwidth(textdown, FALSE, [12,12]) / 2), 0], textdown, [12,12], col, 1.0f, 0);
	drawstring(center + [-64, 0] - [stringwidth(textleft, FALSE, [12,12]), 0], textleft, [12,12], col, 1.0f, 0);
	drawstring(center + [64, 0], textright, [12,12], col, 1.0f, 0);
}

void
IN_Saturn_InputFrame(void)
{
	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];

	if (!autocvar_in_saturnmode)
		return;

	if (pSeat->m_iSaturnMenu) {
		if (input_movevalues[0] > 0) {
			localcmd("+reload;wait;wait;wait;-reload\n");
			pSeat->m_iSaturnMenu = FALSE;
		} else if (input_movevalues[0] < 0) {
			localcmd("impulse 100\n");
			pSeat->m_iSaturnMenu = FALSE;
		} else if (input_movevalues[1] > 0) {
			localcmd("invnext\n");
			pSeat->m_iSaturnMenu = FALSE;
		} else if (input_movevalues[1] < 0) {
			localcmd("invprev\n");
			pSeat->m_iSaturnMenu = FALSE;
		}
		input_movevalues = [0,0,0];
	}

	if (input_buttons & INPUT_BUTTON5) {
		vector dir = input_movevalues;
		dir[0] *= -0.5f;
		dir[1] *= -0.5f;
		input_angles += clframetime * dir;
		input_movevalues = [0,0,0];
		setproperty(VF_CL_VIEWANGLES, input_angles);
	}
}
