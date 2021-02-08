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

class CPictureSwitch:CWidget
{
	int m_value;
	string *m_pics;
	int m_max;

	int m_picsize[2];
	int m_picofs[2];
	int m_size[2];
	
	int m_hoverPrev;
	int m_hoverNext;
	virtual void(void) m_changed = 0;

	void(void) CPictureSwitch;
	virtual void(void) Draw;
	virtual void(float, float, float, float) Input;

	virtual void(string *) SetPics;
	virtual void(int) SetValue;
	virtual void(int) SetMax;
	virtual void(string) SetValueS;
	virtual void(int, int) SetSize;
	virtual void(void(void)) SetCallback;
	virtual string() GetPic;
};

void
CPictureSwitch::CPictureSwitch(void)
{
	m_size[0] = 124;
	m_size[1] = 124;
}

void
CPictureSwitch::Draw(void)
{
	drawfill([g_menuofs[0]+m_x,g_menuofs[1]+m_y], [m_size[0],m_size[1]], [0.25,0.25,0.25], 1.0f);
	drawfill([g_menuofs[0]+m_x+3,g_menuofs[1]+m_y+3], [m_size[0]-6,m_size[1]-31], [0,0,0], 1.0f);
	
	drawpic([m_picofs[0]+g_menuofs[0]+m_x+3,m_picofs[1]+g_menuofs[1]+m_y+3], m_pics[m_value],
			[m_picsize[0],m_picsize[1]], [1,1,1], 1.0f);

	WLabel_Static(m_x+3, m_y+m_size[1]-16, m_reslbl[IDS_PREVIOUS], 12, 12, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_StaticR(m_x+m_size[0]-4,
					m_y+m_size[1]-16, m_reslbl[IDS_NEXT], 12, 12,
					[1,1,1],1.0f, 0, font_arial);
}

void
CPictureSwitch::Input(float type, float x, float y, float devid)
{
	m_hoverPrev = Util_CheckMouse(m_x+3, m_y+m_size[1]-16, m_size[0]/2, 12);
	m_hoverNext = Util_CheckMouse(m_x+m_size[0]-4-(m_size[0]/2), m_y+m_size[1]-16, m_size[0]/2, 12);

	if (m_hoverPrev && type == IE_KEYDOWN && x == K_MOUSE1) {
		localsound("../media/launch_select2.wav");
		m_value--;
		m_value = bound(0, m_value, m_max-1);

		if (m_changed) {
			m_changed();
		}
	} else if (m_hoverNext && type == IE_KEYDOWN && x == K_MOUSE1) {
		localsound("../media/launch_select2.wav");
		m_value++;
		m_value = bound(0, m_value, m_max-1);

		if (m_changed) {
			m_changed();
		}
	}
}

void
CPictureSwitch::SetPics(string *m)
{
	m_pics = m;
}

void
CPictureSwitch::SetValue(int val)
{
	m_value = val;

	if (m_changed) {
		m_changed();
	}
}

void
CPictureSwitch::SetMax(int val)
{
	m_max = val;
}

void
CPictureSwitch::SetValueS(string val)
{
	for (int i = 0; i < m_max; i++) {
		if (m_pics[i] == val) {
			m_value = i;
		}
	}

	if (m_changed) {
		m_changed();
	}
}

void
CPictureSwitch::SetSize(int w, int h)
{
	m_size[0] = w;
	m_size[1] = h;
}

void
CPictureSwitch::SetPicSize(int w, int h)
{
	m_picsize[0] = w;
	m_picsize[1] = h;
}

void
CPictureSwitch::SetPicOffset(int w, int h)
{
	m_picofs[0] = w;
	m_picofs[1] = h;
}

void
CPictureSwitch::SetCallback(void(void) vFunc)
{
	m_changed = vFunc;
}

string
CPictureSwitch::GetPic(void)
{
	return m_pics[m_value];
}
