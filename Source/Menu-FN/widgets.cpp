/***
*
*   Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
* 
* 	See the file LICENSE attached with the sources for usage details.
*
****/

class CWidget
{
	int m_x;
	int m_y;
	CWidget m_next;
	CWidget m_parent;

	void() CWidget;
	virtual void() Draw;
	virtual void(float type, float x, float y, float devid) Input;

	virtual void(int x, int y) SetPos;
};

void CWidget::CWidget(void)
{
	m_x = g_menuofs[0];
	m_y = g_menuofs[1];
}

void CWidget::Draw(void)
{
}

void CWidget::Input(float type, float x, float y, float devid)
{
}

void CWidget::SetPos(int x, int y)
{
	m_x = x;
	m_y = y;
}

void Widget_Add(CWidget parent, CWidget item)
{
	CWidget wNext = parent;
	CWidget wParent;
	do {
		wParent = wNext;
		wNext = wNext.m_next;
	} while (wNext);
	wParent.m_next = item;
	item.m_parent = parent;
}

void Widget_Draw(CWidget start)
{
	CWidget wNext = start;
	do {
		wNext = wNext.m_next;
		if (wNext) {
			wNext.Draw();
		}
	} while (wNext);
}

void Widget_Input(CWidget start, float type, float x, float y, float devid)
{
	CWidget wNext = start;
	do {
		wNext = wNext.m_next;
		if (wNext) {
			wNext.Input(type, x, y, devid);
		}
	} while (wNext);
}

CWidget g_focuswidget;
