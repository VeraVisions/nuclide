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

#ifdef MENU
/** VGUI Widget: Menu Title

@ingroup vgui
*/
class vguiMenuTitle:vguiLabel
{
public:
	void vguiMenuTitle(void);

	virtual void Draw(void);
	virtual void Reposition(void);
	virtual float Input(float, float, float, float);

	bool m_bIsImage;
	bool m_hover;
	string m_imagePath;
	string m_imagePathHover;
};

void
vguiMenuTitle::vguiMenuTitle(void)
{
	m_bIsImage = false;
}

void
vguiMenuTitle::Reposition(void)
{
	string title = GameLibrary_GetInfo(GAMEINFO_TITLE);
	string subTitle = GameLibrary_GetInfo(GAMEINFO_SUBTITLE);
	super::Reposition();
	vector newPosition = g_vec_null;

	if (!STRING_SET(title)) {
		if (fileExists("gfx/title.mat")) {
			newPosition = [g_vidsize[0] / 16, g_vidsize[1] / 2 - 64];
			newPosition[1] -= 32;
			m_bIsImage = true;
			SetSize([196,32]);
			m_imagePath = "gfx/title";
			m_imagePathHover = "gfx/title";
		} else if (fileExists("resource/game_menu_mouseover.tga")) {
			newPosition = [g_vidsize[0] / 16, g_vidsize[1] / 2 - 64];
			newPosition[1] -= 32;
			m_bIsImage = true;
			SetSize([196,32]);
			m_imagePath = "resource/game_menu.tga";
			m_imagePathHover = "resource/game_menu_mouseover.tga";
		}
	} else {
		newPosition = [g_vidsize[0] / 16, g_vidsize[1] / 2 - 64];
		newPosition[1] -= 32;
		SetSize([Font_StringWidth(title, true, g_fntTitle), 32]);
	}

	SetPos(newPosition);
}

tcpstate_t FragNet_Status(void);

void
vguiMenuTitle::Draw(void)
{
#if 1
	switch (FragNet_Status()) {
	case STATE_SIGNON:
		drawfill( [g_vidsize[0] - 170, g_vidsize[1] - 48], [6,6], [1.0,0.0,0.0], 1.0f);
		drawfill( [g_vidsize[0] - 170 + 16, g_vidsize[1] - 48], [6,6], [0.25,0.25,0.25], 1.0f);
		drawfill( [g_vidsize[0] - 170 + 16 + 16, g_vidsize[1] - 48], [6,6], [0.25,0.25,0.25], 1.0f);
		Font_DrawText_RGB([g_vidsize[0] - 100, g_vidsize[1] - 50], "Sign-on...", [0.75,0.75,0.75], g_fntMenuButton);
		break;
	case STATE_AUTHORIZING:
		drawfill( [g_vidsize[0] - 170, g_vidsize[1] - 48], [6,6], [1.0,1.0,0.0], 1.0f);
		drawfill( [g_vidsize[0] - 170 + 16, g_vidsize[1] - 48], [6,6], [1.0,1.0,0.0], 1.0f);
		drawfill( [g_vidsize[0] - 170 + 16 + 16, g_vidsize[1] - 48], [6,6], [0.25,0.25,0.25], 1.0f);
		Font_DrawText_RGB([g_vidsize[0] - 100, g_vidsize[1] - 50], "Auth...", [0.75,0.75,0.75], g_fntMenuButton);
		break;
	case STATE_ONLINE:
		drawfill( [g_vidsize[0] - 170, g_vidsize[1] - 48], [6,6], [0,1,0], 1.0f);
		drawfill( [g_vidsize[0] - 170 + 16, g_vidsize[1] - 48], [6,6], [0,1,0], 1.0f);
		drawfill( [g_vidsize[0] - 170 + 16 + 16, g_vidsize[1] - 48], [6,6], [0,1,0], 1.0f);
		Font_DrawText_RGB([g_vidsize[0] - 100, g_vidsize[1] - 50], "Online", [0.75,0.75,0.75], g_fntMenuButton);
		break;
	case STATE_OFFLINE:
	default:
		drawfill( [g_vidsize[0] - 170, g_vidsize[1] - 48], [6,6], [0.5,0.5,0.5], 1.0f);
		drawfill( [g_vidsize[0] - 170 + 16, g_vidsize[1] - 48], [6,6], [0.5,0.5,0.5], 1.0f);
		drawfill( [g_vidsize[0] - 170 + 16 + 16, g_vidsize[1] - 48], [6,6], [0.5,0.5,0.5], 1.0f);
		Font_DrawText_RGB([g_vidsize[0] - 100, g_vidsize[1] - 50], "Offline", [0.5,0.5,0.5], g_fntMenuButton);
	}

#endif

	if (m_bIsImage) {
		if (m_hover)
			drawpic(m_parent.m_vecOrigin + m_vecOrigin, m_imagePathHover, m_vecSize, [1,1,1], 1.0f, 0);
		else
			drawpic(m_parent.m_vecOrigin + m_vecOrigin, m_imagePath, m_vecSize, [1,1,1], 1.0f, 0);
		return;
	}

	string title = 	GameLibrary_GetInfo(GAMEINFO_TITLE);
	string subTitle = GameLibrary_GetInfo(GAMEINFO_SUBTITLE);

	vector pos;
	vector size;

	pos = m_parent.m_vecOrigin + m_vecOrigin;
	size = m_vecSize;

	if (STRING_SET(title))
		Font_DrawField(pos, size + [64,0], title, g_fntTitle, m_labelFlags);

	if (STRING_SET(subTitle))
		Font_DrawField(pos + [0, 32], size + [64,0], subTitle, g_fntSubTitle, AF_RIGHT | AF_TOP);
}

bool
vguiMenuTitle::Input(float flEVType, float flKey, float flChar, float flDevID)
{
	bool ret = false;

	if (Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin, m_vecSize)) {
		m_hover = true;
	} else {
		m_hover = false;
	}

	return (ret);
}

#endif
