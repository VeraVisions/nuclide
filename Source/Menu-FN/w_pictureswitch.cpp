/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class CPictureSwitch:CWidget
{
	int m_value;
	string *m_pics;
	int m_max;

	int m_picsize[2];
	int m_picofs[2];
	int m_size[2];

	void() CPictureSwitch;
	virtual void() Draw;
	virtual void(float type, float x, float y, float devid) Input;

	virtual void(string *m) SetPics;
	virtual void(int val) SetValue;
	virtual void(int val) SetMax;
	virtual void(string val) SetValueS;
	virtual void(int w, int h) SetSize;
};

void CPictureSwitch::CPictureSwitch(void)
{
	m_size[0] = 124;
	m_size[1] = 124;
}

void CPictureSwitch::Draw(void)
{
	drawfill([g_menuofs[0]+m_x,g_menuofs[1]+m_y], [m_size[0],m_size[1]], [0.25,0.25,0.25], 1.0f);
	drawfill([g_menuofs[0]+m_x+3,g_menuofs[1]+m_y+3], [m_size[0]-6,m_size[1]-31], [0,0,0], 1.0f);
	
	drawpic([m_picofs[0]+g_menuofs[0]+m_x+3,m_picofs[1]+g_menuofs[1]+m_y+3], m_pics[m_value],
			[m_picsize[0],m_picsize[1]], [1,1,1], 1.0f);

	WLabel_Static(g_menuofs[0]+m_x+3, g_menuofs[1]+m_y+m_size[1]-16, m_reslbl[IDS_PREVIOUS], 12, 12, [1,1,1],
					1.0f, 0, font_arial);
	WLabel_StaticR(g_menuofs[0]+m_x+m_size[0]-4,
					g_menuofs[1]+m_y+m_size[1]-16, m_reslbl[IDS_NEXT], 12, 12,
					[1,1,1],1.0f, 0, font_arial);
}

void CPictureSwitch::Input(float type, float x, float y, float devid)
{
	
}

void CPictureSwitch::SetPics(string *m)
{
	m_pics = m;
}

void CPictureSwitch::SetValue(int val)
{
	m_value = val;
}

void CPictureSwitch::SetMax(int val)
{
	m_max = val;
}

void CPictureSwitch::SetValueS(string val)
{
	for (int i = 0; i < m_max; i++) {
		if (m_pics[i] == val) {
			m_value = i;
		}
	}
}

void CPictureSwitch::SetSize(int w, int h)
{
	m_size[0] = w;
	m_size[1] = h;
}

void CPictureSwitch::SetPicSize(int w, int h)
{
	m_picsize[0] = w;
	m_picsize[1] = h;
}

void CPictureSwitch::SetPicOffset(int w, int h)
{
	m_picofs[0] = w;
	m_picofs[1] = h;
}
