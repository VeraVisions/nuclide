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

class CUITabView:CUIWidget
{
	vector m_vecSize;
	vector m_vecOutlineSize;
	vector m_vecOutlinePos;
	string m_strTitle;
	
	void(void) CUITabView;
	virtual void(void) Draw;
	virtual void(vector) SetPos;
	virtual vector() GetPos;
	virtual void(vector) SetSize;
	virtual vector() GetSize;
	virtual void(string) SetTitle;
	virtual float(float, float, float, float) Input;
};

void CUITabView::CUITabView(void)
{
	m_vecSize = [96,16];
	m_iFlags = BUTTON_VISIBLE;
}

void CUITabView::SetPos (vector vecSize)
{
	m_vecOrigin = vecSize;
	m_vecOutlinePos = m_vecOrigin + [0, 20];
}
vector CUITabView::GetPos(void)
{
	return m_vecOrigin;
}

void CUITabView::SetSize (vector vecSize)
{
	m_vecSize = vecSize;
	m_vecOutlineSize = m_vecSize - [0, 20];
}
vector CUITabView::GetSize(void)
{
	return m_vecSize;
}

void CUITabView::SetTitle (string strName)
{
	m_strTitle = strName;
	SetSize([stringwidth(m_strTitle, TRUE, [g_fntDefault.iScaleX, g_fntDefault.iScaleY]), 16]);
}
void CUITabView::Draw(void)
{
	
	//drawfill(m_parent.m_vecOrigin + m_vecOutlinePos, [m_vecOutlineSize[0], 1], [1,1,1], 0.5f);
	drawfill(m_parent.m_vecOrigin + m_vecOutlinePos + [0, m_vecOutlineSize[1] - 1], [m_vecOutlineSize[0], 1], [0,0,0], 0.5f);
	drawfill(m_parent.m_vecOrigin + m_vecOutlinePos + [0, 1], [1, m_vecOutlineSize[1] - 2], [1,1,1], 0.5f);
	drawfill(m_parent.m_vecOrigin + m_vecOutlinePos + [m_vecOutlineSize[0] - 1, 1], [1, m_vecOutlineSize[1] - 2], [0,0,0], 0.5f);
	
	//Font_DrawText(m_parent.m_vecOrigin + m_vecOrigin + [8, 8], m_strTitle, g_fntDefault);
}

bool CUITabView::Input (float flEVType, float flKey, float flChar, float flDevID)
{
	return false;
}
