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

class VGUITabView:VGUIWidget
{
public:
	void VGUITabView(void);

	/** Sets the title of the tab view. */
	nonvirtual void SetTitle(string);

	/* overrides */
	virtual void PositionChanged(vector, vector);
	virtual void SizeChanged(vector, vector);
	virtual void Draw(void);
	virtual bool Input(float, float, float, float);
	virtual void Spawned(void);

private:
	vector m_vecOutlineSize;
	vector m_vecOutlinePos;
	string m_strTitle;
};

void VGUITabView::VGUITabView(void)
{
	m_vecOutlinePos = m_vecOutlineSize = g_vec_null;
	m_strTitle = __NULL__;
}

void VGUITabView::Spawned(void)
{
	SetSize([96,16]);
}

void VGUITabView:: PositionChanged (vector vecOld, vector vecNew)
{
	m_vecOutlinePos = vecNew + [0, 20];
}

void VGUITabView::SizeChanged (vector vecOld, vector vecNew)
{
	m_vecOutlineSize = vecNew - [0, 20];
}

void VGUITabView::SetTitle (string strName)
{
	m_strTitle = strName;
	SetSize([stringwidth(m_strTitle, TRUE, [g_fntDefault.iScaleX, g_fntDefault.iScaleY]), 16]);
}
void VGUITabView::Draw(void)
{
	
	//drawfill(m_parent.m_vecOrigin + m_vecOutlinePos, [m_vecOutlineSize[0], 1], [1,1,1], 0.5f);
	drawfill(m_parent.m_vecOrigin + m_vecOutlinePos + [0, m_vecOutlineSize[1] - 1], [m_vecOutlineSize[0], 1], [0,0,0], 0.5f);
	drawfill(m_parent.m_vecOrigin + m_vecOutlinePos + [0, 1], [1, m_vecOutlineSize[1] - 2], [1,1,1], 0.5f);
	drawfill(m_parent.m_vecOrigin + m_vecOutlinePos + [m_vecOutlineSize[0] - 1, 1], [1, m_vecOutlineSize[1] - 2], [0,0,0], 0.5f);
	
	//Font_DrawText(m_parent.m_vecOrigin + m_vecOrigin + [8, 8], m_strTitle, g_fntDefault);
}

bool VGUITabView::Input (float flEVType, float flKey, float flChar, float flDevID)
{
	return false;
}
