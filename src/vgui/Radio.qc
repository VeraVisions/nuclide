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
	RADIO_HOVER,
	RADIO_DOWN,
	RADIO_ACTIVE
};

.void(void) tmpvguiRadio1;

/** VGUI Widget: Radio Button

@ingroup vgui
*/
class vguiRadio:vguiWidget
{
public:
	void vguiRadio(void);

	nonvirtual void SetTitle(string);
	nonvirtual int GetValue(void);
	nonvirtual void SetValue(int);
	nonvirtual void SetFunc(void(void));

	virtual void Draw(void);
	virtual bool Input(float, float, float, float);
	virtual void Spawned(void);

private:
	vector m_vecColor;
	float m_flAlpha;
	vector m_vecSize;
	string m_strTitle;
};

void vguiRadio::vguiRadio(void)
{
	m_vecColor = UI_MAINCOLOR;
	m_flAlpha = 1.0f;
}

void
vguiRadio::Spawned(void)
{
	SetSize([96,24]);
}


void vguiRadio::SetTitle (string strName)
{
	m_strTitle = strName;
}
int vguiRadio::GetValue(void)
{
	if (m_iFlags & RADIO_ACTIVE) {
		return (1);
	} else {
		return (0);
	}
}
void vguiRadio::SetValue (int iValue)
{
	if (iValue == TRUE) {
		m_iFlags |= RADIO_ACTIVE;
	} else {
		m_iFlags -= (m_iFlags & RADIO_ACTIVE);
	}
}
void vguiRadio::SetFunc (void(void) vFunc)
{
	tmpvguiRadio1 = vFunc;
}

void vguiRadio::Draw(void)
{
	vguiTheme theme = GetTheme();

	theme.DrawControlBackground(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, VGUI_STATE_ACTIVE);
	
	if (m_iFlags & RADIO_DOWN) {
		theme.DrawBorder(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, VGUI_BORDER_INSET, __NULL__);
	}
	if (m_iFlags & RADIO_ACTIVE) {
		drawpic(m_parent.m_vecOrigin + m_vecOrigin, "gfx/icon16/bullet_white", [16,16], [1,1,1], 1.0f, 0);
	} else {
		drawpic(m_parent.m_vecOrigin + m_vecOrigin, "gfx/icon16/bullet_black", [16,16], [1,1,1], 1.0f, 0);
	}

	if (m_strTitle) {
		theme.DrawText(m_parent.m_vecOrigin + m_vecOrigin + [24, 3], m_strTitle, m_vecSize, g_fntDefault);
	}
}

bool vguiRadio::Input (float flEVType, float flKey, float flChar, float flDevID)
{
	bool ret = false;

	if (flEVType == IE_KEYDOWN) {
		if (flKey == K_MOUSE1) {
			if (Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin, m_vecSize)) {
				m_iFlags |= RADIO_DOWN;
				ret = true;
			}
		}
	} else if (flEVType == IE_KEYUP) {
		if (flKey == K_MOUSE1) {
			if (m_iFlags & RADIO_DOWN && Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin, m_vecSize)) {
				if (tmpvguiRadio1) {
					tmpvguiRadio1();
				}
				SetValue(TRUE);
				ret = true;
			}
			m_iFlags -= (m_iFlags & RADIO_DOWN);
		}
	}
	return (ret);
}
