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

class CUIList:CUIWidget
{
	vector m_vecSize;
	string m_strTitle;
	string *m_strItems;
	int m_iItemCount;
	int m_iSelected;
	int m_iDrawOffset;
	
	void(void) CUIList;
	
	virtual void(void) m_vScrollCB = 0;
	
	virtual void(vector) SetSize;
	virtual void(int, int) SetOffset;
	
	virtual void(int) SetSelected;
	virtual int(void) GetSelected;
	
	virtual int(void) GetMaxVisibleItems;
	
	virtual void(string) AddItem;
	virtual string(int) GetItem;
	
	virtual void(int) SetItemCount;
	virtual int(void) GetItemCount;
	
	virtual void(void(void)) CallOnScroll;
	
	virtual void(void) Draw;
	virtual void(float, float, float, float) Input;
};

void CUIList::CUIList(void)
{
	m_vecSize = [96,16];
	m_iFlags = 1;
	m_iSelected = -1;
}

void CUIList::Draw(void)
{
	int iMaxDisplay;
	if (!m_iItemCount) {
		return;
	}
	
#ifdef CLASSIC_VGUI
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, m_vecSize[1] - 1], [m_vecSize[0], 1], UI_MAINCOLOR, 1.0f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin, [m_vecSize[0], 1], UI_MAINCOLOR, 1.0f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, 1], [1, m_vecSize[1] - 2], UI_MAINCOLOR, 1.0f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], UI_MAINCOLOR, 1.0f);
#else
	drawfill(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, '0 0 0', 0.25f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin, [m_vecSize[0], 1], '0 0 0', 0.5f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, m_vecSize[1] - 1], [m_vecSize[0], 1], '1 1 1', 0.5f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, 1], [1, m_vecSize[1] - 2], '0 0 0', 0.5f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], '1 1 1', 0.5f);
#endif

	vector vecOffset = '8 8';
	
	iMaxDisplay = bound(0, m_iItemCount, floor(m_vecSize[1] / 20));

	drawsetcliparea(m_parent.m_vecOrigin[0] + m_vecOrigin[0],m_parent.m_vecOrigin[1] + m_vecOrigin[1], m_vecSize[0] - 1, m_vecSize[1]);
	for (int i = m_iDrawOffset; i < iMaxDisplay + m_iDrawOffset; i++) {
		if (!m_strItems[i]) {
			break;
		}
		
		if (m_iSelected == i) {
			drawfill(m_parent.m_vecOrigin + m_vecOrigin + vecOffset + '-7 -3', [m_vecSize[0] - 2, 18], '1 1 1', 0.5f);
		} else if (i & 1) {
			drawfill(m_parent.m_vecOrigin + m_vecOrigin + vecOffset + '-7 -3', [m_vecSize[0] - 2, 18], '1 1 1', 0.1f);
		}
		
		Font_DrawText(m_parent.m_vecOrigin + m_vecOrigin + vecOffset, m_strItems[i], g_fntDefault);
		vecOffset[1] += 20;
	}
	drawresetcliparea();
}

void CUIList::Input (float flEVType, float flKey, float flChar, float flDevID)
{
	int iMaxDisplay;
	int iMouseOver = Util_MouseAbove(getmousepos(), m_parent.m_vecOrigin + m_vecOrigin, m_vecSize);
	iMaxDisplay = bound(0, m_iItemCount, floor(m_vecSize[1] / 20));
	
	vector vecOffset = '8 8';
	if (flEVType == IE_KEYDOWN) {
		if (flKey == K_MOUSE1) {
			for (int i = m_iDrawOffset; i < iMaxDisplay + m_iDrawOffset; i++) {
				if (Util_MouseAbove(getmousepos(), m_parent.m_vecOrigin + m_vecOrigin + vecOffset, [m_vecSize[0] - 16, 20])) {
					m_iSelected = i;
					return;
				}
				vecOffset[1] += 20;
			}
		} else if (flKey == K_MWHEELUP && iMouseOver) {
			SetOffset(m_iDrawOffset - (iMaxDisplay / 4), TRUE);
		} else if (flKey == K_MWHEELDOWN && iMouseOver) {
			SetOffset(m_iDrawOffset + (iMaxDisplay / 4), TRUE);
		}
	}
}

void CUIList::SetSize (vector vecSize)
{
	m_vecSize = vecSize;
}
vector CUIList::GetSize(void)
{
	return m_vecSize;
}

int CUIList::GetMaxVisibleItems(void)
{
	int iMaxDisplay = bound(0, m_iItemCount, floor(m_vecSize[1] / 20));
	return m_iItemCount - iMaxDisplay;
}

void CUIList::SetOffset (int iOffset, int iCallBack)
{
	int iMaxDisplay = bound(0, m_iItemCount, floor(m_vecSize[1] / 20));
	m_iDrawOffset = bound(0, iOffset, m_iItemCount - iMaxDisplay);
	
	if (m_vScrollCB && iCallBack) {
		m_vScrollCB();
	}
}
int CUIList::GetOffset(void)
{
	return m_iDrawOffset;
}

void CUIList::SetItemCount (int iCount)
{
	if (!m_iItemCount) {
		dprint(sprintf("CUIList: Initialized with a maximum of %i entries\n", iCount));
		m_iItemCount = iCount;
		m_strItems = memalloc(iCount * sizeof(string));
	}
}
int CUIList::GetItemCount(void)
{
	return m_iItemCount;
}

string CUIList::GetItem (int iIndex)
{
	if (m_iSelected < 0 || m_iItemCount <= 0) {
		dprint("CUIList: GetItem on empty/unselected list!\n");
		return "ERROR";
	}
	return m_strItems[iIndex];
}

void CUIList::SetSelected (int iVal)
{
	m_iSelected = iVal;
}
int CUIList::GetSelected(void)
{
	return m_iSelected;
}

void CUIList::AddItem (string strItem)
{
	if (!m_iItemCount) {
		dprint("CUIList: Can't add item to empty list!\n");
		return;
	}
	
	for (int i = 0; i < m_iItemCount; i++) {
		if (!m_strItems[i]) {
			m_strItems[i] = strItem;
			dprint("CUIList: Item added\n");
			break;
		}
	}
}

void CUIList::CallOnScroll (void(void) vFunc)
{
	m_vScrollCB = vFunc;
}
