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

string g_header_text[] = {
	"ADVANCED",
	"ADV. OPTIONS",
	"AUDIO",
	"CONFIGURATION",
	"CONTROLS",
	"CREATE GAME",
	"CREATE ROOM",
	"CUSTOM GAME",
	"CUSTOMIZE",
	"FILTER",
	"GAME OPTIONS",
	"GORE",
	"INTERNET GAMES",
	"KEYBOARD",
	"LAN",
	"LOAD GAME",
	"MULTIPLAYER",
	"NEW GAME",
	"README",
	"ROOM",
	"ROOMS",
	"SAVE",
	"SAVE & LOAD",
	"SINGLEPLAYER",
	"SPECTATE GAMES",
	"VIDEO",
	"VIDEO MODES",
	"VIDEO OPTIONS"
};

class CHeader:CWidget
{
	int m_header;
	float m_lerp;
	int m_start_x;
	int m_start_y;
	int m_end_x;
	int m_end_y;
	int m_start_w;
	int m_start_h;
	int m_end_w;
	int m_end_h;
	int m_visible;

	virtual void(void) m_execute = 0;

	virtual void(void) Draw;
	virtual void(int, int, int, int) SetStartEndPos;
	virtual void(int, int, int, int) SetStartEndSize;
	virtual void(int) SetHeader;
};

void
CHeader::Draw(void)
{
	int pos[2];
	int size[2];

	if (m_visible == FALSE) {
		return;
	}

	pos[0] = g_menuofs[0] + lerp(m_start_x, m_end_x, m_lerp);
	pos[1] = g_menuofs[1] + lerp(m_start_y, m_end_y, m_lerp);
	
	size[0] = lerp(m_start_w, m_end_w, m_lerp);
	size[1] = lerp(m_start_h, m_end_h, m_lerp);

	if (whichpack(strcat(g_bmp[m_header],".bmp"))) {
		drawpic([pos[0],pos[1]], g_bmp[m_header],[size[0],size[1]], [1,1,1], 1.0f, 1);
	} else {
		drawstring([pos[0],pos[1]], g_header_text[m_header-HEAD_ADVANCED], [32,32], [1,1,1], 1.0f, 1);
	}

#if 0
	m_lerp += frametime * 0.25;
#else
	m_lerp += frametime * 8;
#endif

	m_lerp = bound(0.0f, m_lerp, 1.0f);

	if (m_lerp == 1.0f) {
		if (m_visible == TRUE) {
			m_visible = FALSE;
			
			if (m_execute) {
				m_execute();
			}
		}
	}
}

void
CHeader::SetHeader(int i)
{
	m_header = i;
}

void
CHeader::SetExecute(void(void) vFunc)
{
	m_execute = vFunc;
}

void
CHeader::SetStartEndPos(int x1, int y1, int x2, int y2)
{
	m_start_x = x1;
	m_start_y = y1;
	m_end_x = x2;
	m_end_y = y2;
}

void
CHeader::SetStartEndSize(int x1, int y1, int x2, int y2)
{
	m_start_w = x1;
	m_start_h = y1;
	m_end_w = x2;
	m_end_h = y2;
}

void
Header_Draw(int id)
{
	if (whichpack(strcat(g_bmp[id],".bmp"))) {
		drawpic([g_menuofs[0]+45,g_menuofs[1]+45], g_bmp[id],[460,80], [1,1,1], 1.0f, 1);
	} else {
		drawfont = font_label_p;
		drawstring([g_menuofs[0]+45,g_menuofs[1]+45], g_header_text[id-HEAD_ADVANCED], [32,32], [1,1,1], 1.0f, 1);
	}
}

CHeader header;
