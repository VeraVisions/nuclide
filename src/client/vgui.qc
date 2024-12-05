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

vguiWidget g_uiDesktop;

void
VGUI_Init(void)
{
	UISystem_Init();
	g_uiDesktop = spawn(vguiWidget);
	g_uiDesktop.FlagAdd(1);
}

int
VGUI_Draw(void)
{
	g_uiDesktop.Draw();
	return (1);
}

bool
VGUI_Input(float flEvType, float flScanX, float flCharY, float flDevID)
{
	return g_uiDesktop.Input(flEvType, flScanX, flCharY, flDevID);
}

void
VGUI_Reposition(void)
{
	vguiWidget wNext = g_uiDesktop;
	do {
		wNext = wNext.m_next;
		if (wNext && wNext.Reposition) {
			wNext.Reposition();
		}
	} while (wNext);
}
