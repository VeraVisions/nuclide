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

enumflags
{
	SLIDER_HOVER,
	SLIDER_DOWN,
};

/** VGUI Widget: Slider

@ingroup vgui
*/
class VGUISlider:VGUIWidget
{
public:
	void VGUISlider(void);

	nonvirtual void SetTitle(string);

	/* overrides */
	virtual void Draw(void);
	virtual bool Input(float, float, float, float);
	virtual void Spawned(void);

private:
	float m_flAlpha;
	vector m_vecSize;
	vector m_vecColor;
};

void VGUISlider::VGUISlider(void)
{
	m_vecColor = [76,88,68] / 255;
	m_flAlpha = 1.0f;
}

void
VGUISlider::Spawned(void)
{
	SetSize([96,24]);
}

void VGUISlider::Draw(void)
{
	drawfill(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, m_vecColor, m_flAlpha);
	
	if (m_iFlags & BUTTON_DOWN) {
		drawfill(m_parent.m_vecOrigin + m_vecOrigin, [m_vecSize[0], 1], [0,0,0], 0.5f);
		drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, m_vecSize[1] - 1], [m_vecSize[0], 1], [1,1,1], 0.5f);
		drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, 1], [1, m_vecSize[1] - 2], [0,0,0], 0.5f);
		drawfill(m_parent.m_vecOrigin + m_vecOrigin + [m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], [1,1,1], 0.5f);
	} else {
		drawfill(m_parent.m_vecOrigin + m_vecOrigin, [m_vecSize[0], 1], [1,1,1], 0.5f);
		drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, m_vecSize[1] - 1], [m_vecSize[0], 1], [0,0,0], 0.5f);
		drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, 1], [1, m_vecSize[1] - 2], [1,1,1], 0.5f);
		drawfill(m_parent.m_vecOrigin + m_vecOrigin + [m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], [0,0,0], 0.5f);
	}
	
	if (m_strTitle) {
		Font_DrawText(m_parent.m_vecOrigin + m_vecOrigin + [8, 8], m_strTitle, g_fntDefault);
	}
	if (m_strIcon) {
		drawpic(m_parent.m_vecOrigin + m_vecOrigin + [2,2], m_strIcon, [16,16], [1,1,1], 1.0f);
	}
}

bool VGUISlider::Input (float flEVType, float flKey, float flChar, float flDevID)
{
	return false;
}

void VGUISlider::SetTitle (string strName)
{
	m_strTitle = strName;
}
