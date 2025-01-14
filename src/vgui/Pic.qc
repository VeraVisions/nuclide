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
	IMAGE_VISIBLE
};

/** VGUI Widget: Picture Frame

@ingroup vgui
*/
class
vguiPic:vguiWidget
{
public:
	void vguiPic(void);

	virtual void Draw(void);
	virtual bool Input(float, float, float, float);
	virtual void Spawned(void);

	nonvirtual void SetImage(string);
	nonvirtual string GetImage(void);
	nonvirtual void SetBorder(int);
	nonvirtual int GetBorder(void);
	nonvirtual void AdjustBounds(void);

private:
	string m_strImage;
	int m_borderThickness;
	vector m_picMins;
	vector m_picSize;
};

void
vguiPic::vguiPic(void)
{
	m_strImage = __NULL__;
}

void
vguiPic::Spawned(void)
{
	SetSize([16,16, 0]);
}

void
vguiPic::Draw(void)
{
	if (m_borderThickness <= 0) {
		if (m_strImage) {
			drawpic(m_parent.m_vecOrigin + m_vecOrigin, m_strImage, m_vecSize, [1,1,1], 1.0f, 0);
		}
	} else {
		vguiTheme ourTheme = GetTheme();
		ourTheme.DrawBorder(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, VGUI_BORDER_INSET, __NULL__);

		if (m_strImage) {
			drawpic(m_parent.m_vecOrigin + m_vecOrigin + m_picMins, m_strImage, m_picSize, [1,1,1], 1.0f, 0);
		}
	}
}

bool
vguiPic::Input (float flEVType, float flKey, float flChar, float flDevID)
{
	return false;
}

void
vguiPic::SetImage (string strName)
{
	m_strImage = strName;

	if (GetWidth() <= 0 || GetHeight() <= 0) {
		SetSize(drawgetimagesize(m_strImage));
	}

	AdjustBounds();
}

void
vguiPic::AdjustBounds(void)
{
	m_picSize[0] = m_vecSize[0] - (m_borderThickness * 2);
	m_picSize[1] = m_vecSize[1] - (m_borderThickness * 2);
	m_picSize[2] = 0;
	m_picMins = [(float)m_borderThickness, (float)m_borderThickness];
}

string
vguiPic::GetImage(void)
{
	return m_strImage;
}

void
vguiPic::SetBorder (int thickness)
{
	m_borderThickness = thickness;
	AdjustBounds();
}

int
vguiPic::GetBorder(void)
{
	return (m_borderThickness);
}
