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

class CUILabel:CUIWidget
{
	vector m_vecSize;
	string m_strTitle;
	
	void(void) CUILabel;
	virtual void(void) Draw;
	virtual void(vector) SetSize;
	virtual void(string) SetTitle;
	virtual void(float, float, float, float) Input;
};

void CUILabel::CUILabel(void)
{
	m_vecSize = [96,16];
	m_iFlags = BUTTON_VISIBLE;
}

void CUILabel::SetSize (vector vecSize)
{
	m_vecSize = vecSize;
}
void CUILabel::SetTitle (string strName)
{
#ifndef CLASSIC_VGUI
	m_strTitle = strName;
#else
	m_strTitle = sprintf("%s%s", Font_RGBtoHex(UI_MAINCOLOR), strName);
#endif
	drawfont = g_fntDefault.iID;

	/* hack, add 2 just to make sure it doesn't immediately wrap. bug
	 * in engines' textfield thing in combo with ttf. */
	SetSize([2 + stringwidth(m_strTitle, TRUE, [g_fntDefault.iScaleX, g_fntDefault.iScaleY]), 16]);
}
void CUILabel::Draw(void)
{
	if (m_strTitle) {
		Font_DrawField(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, m_strTitle, g_fntDefault, 0);
	}
}

void CUILabel::Input (float flEVType, float flKey, float flChar, float flDevID)
{
}
