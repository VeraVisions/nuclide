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

/* Old style Counter-Strike/TFC menus */

int
Textmenu_IsActive(void)
{
    return STRING_SET(g_textmenu);
}

void
Textmenu_Hide(void)
{
	g_textmenu = "";
	g_textchannels[5].m_flTime = 0.0f;
	g_textmenucheck = 0.0f;
}

void
Textmenu_Call(string menu)
{
	g_textmenu = menu;
	g_textchannels[5].m_flTime = 0.0f;
	g_textmenucheck = 0.0f;
}
void
Textmenu_Toggle(string menu)
{
	if (Textmenu_IsActive())
		Textmenu_Hide();
	else
		Textmenu_Call(menu);
}

void
Textmenu_Draw(void)
{
	if (g_textmenucheck > cltime) {
		return;
	}

	if (STRING_SET(g_textmenu)) {
		GameMessage_Setup(g_textmenu, 5);
		g_textchannels[5].m_flTime = 0.0f;
		g_textchannels[5].m_flPosX = 0.1;
		g_textchannels[5].m_flPosY = -1;
		g_textchannels[5].m_flFadeIn =
		g_textchannels[5].m_flFadeOut = 0.0f;
		g_textchannels[5].m_flHoldTime = 0.5;
		g_textchannels[5].m_vecColor1 = [1,1,1];
		g_textchannels[5].m_vecColor2 = [0,0,0];
		g_textchannels[5].m_iEffect = 0;
		g_textmenucheck = cltime + 0.25;
	}
}

void
Textmenu_Input(int nr)
{
	if (!STRING_SET(g_textmenu)) {
		return;
	}

	void(int) vFunc = externvalue(-1, g_textmenu);

	if (vFunc) {
		vFunc(nr+1);
		return;
	}

	print(sprintf("Warning! %s not implemented!\n", g_textmenu));
}
