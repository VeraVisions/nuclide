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

class CLabel:CWidget
{
	string m_label;
	vector m_color;
	int m_sx;
	int m_sy;
	float m_alpha;
	int m_font;

	void CLabel(void);
	virtual void Draw(void);
	virtual void SetText(string, font_s);
	virtual void SetTextHeight(int);
};

void
CLabel::CLabel(void)
{
	m_label = "Label";
	m_color = [1,1,1];
	m_alpha = 1.0f;
	m_sx = m_sy = 8;
}

void
CLabel::SetText(string txt, font_s font)
{
	m_label = txt;
	m_font = Font_GetID(font);
	m_sx = m_sy = Font_GetHeight(font);
}

void
CLabel::SetTextHeight(int val)
{
	m_sx = m_sy = val;
}

void
CLabel::Draw(void)
{
	drawfont = m_font;
	drawstring([g_menuofs[0] + m_x, g_menuofs[1] + m_y], m_label, [m_sx,m_sy], m_color, m_alpha, 0);
}

/* Sometimes all you need is a static label */
void
WLabel_Static(int x, int y, string msg, int sx, int sy, vector col,
				float alpha, float flags, font_s font)
{
	drawfont = Font_GetID(font);
	x += g_menuofs[0];
	y += g_menuofs[1];
	drawstring([x,y], msg, [sx,sy], col, alpha, flags);
}

void
WLabel_StaticR(int x, int y, string msg, int sx, int sy, vector col,
				float alpha, float flags, font_s font)
{
	drawfont = Font_GetID(font);
	x += g_menuofs[0] - stringwidth(msg, TRUE,[sx,sy]);
	y += g_menuofs[1];
	drawstring([x,y], msg, [sx,sy], col, alpha, flags);
	drawfont = 0;
}

void
WField_Static(int x, int y, string msg, int sx, int sy, vector col,
				float alpha, float flags, font_s font)
{
	x += g_menuofs[0];
	y += g_menuofs[1];
	Font_DrawField([x,y], [sx,sy], sprintf("%s%s", Colors_RGB8_to_HEX(col), msg), font, (int)flags);
}
