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

.void(void) tmpVGUIList1;

/** VGUI Widget: List

@ingroup vgui
*/
class VGUIList:VGUIWidget
{
public:
	void VGUIList(void);

	nonvirtual void SetOffset(int,int);

	nonvirtual void SetSelected(int);
	nonvirtual int GetSelected(void);

	nonvirtual int GetMaxVisibleItems(void);

	nonvirtual void AddItem(string);
	nonvirtual string GetItem(int);

	nonvirtual void SetItemCount(int);
	nonvirtual int GetItemCount(void);

	nonvirtual int GetOffset(void);

	nonvirtual void CallOnScroll(void(void));

	virtual void Draw(void);
	virtual bool Input(float, float, float, float);
	virtual void Spawned(void);

private:
	string m_strTitle;
	string *m_strItems;
	int m_iItemCount;
	int m_iSelected;
	int m_iDrawOffset;
};

void VGUIList::VGUIList(void)
{
	m_iSelected = -1;
}

void VGUIList::Spawned(void)
{
	SetSize([96,16]);
}

void VGUIList::Draw(void)
{
	VGUITheme theme = GetTheme();
	int iMaxDisplay;
	if (!m_iItemCount) {
		return;
	}
	
	drawfill(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, [0,0,0], 0.25f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin, [m_vecSize[0], 1], [0,0,0], 0.5f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, m_vecSize[1] - 1], [m_vecSize[0], 1], [1,1,1], 0.5f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, 1], [1, m_vecSize[1] - 2], [0,0,0], 0.5f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], [1,1,1], 0.5f);

	vector vecOffset = [8,8];
	
	iMaxDisplay = bound(0, m_iItemCount, floor(m_vecSize[1] / 20));

	drawsetcliparea(m_parent.m_vecOrigin[0] + m_vecOrigin[0],m_parent.m_vecOrigin[1] + m_vecOrigin[1], m_vecSize[0] - 1, m_vecSize[1]);
	for (int i = m_iDrawOffset; i < iMaxDisplay + m_iDrawOffset; i++) {
		if (!m_strItems[i]) {
			break;
		}
		
		if (m_iSelected == i) {
			drawfill(m_parent.m_vecOrigin + m_vecOrigin + vecOffset + [-7,-3], [m_vecSize[0] - 2, 18], [1,1,1], 0.5f);
		} else if (i & 1) {
			drawfill(m_parent.m_vecOrigin + m_vecOrigin + vecOffset + [-7,-3], [m_vecSize[0] - 2, 18], [1,1,1], 0.1f);
		}
		
		theme.DrawText(m_parent.m_vecOrigin + m_vecOrigin + vecOffset, m_strItems[i], m_vecSize, g_fntDefault);
		vecOffset[1] += 20;
	}
	drawresetcliparea();
}

bool VGUIList::Input (float flEVType, float flKey, float flChar, float flDevID)
{
	bool ret = false;
	int iMaxDisplay;
	int iMouseOver = Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin, m_vecSize);
	iMaxDisplay = bound(0, m_iItemCount, floor(m_vecSize[1] / 20));
	
	vector vecOffset = [8,8];
	if (flEVType == IE_KEYDOWN) {
		if (flKey == K_MOUSE1) {
			for (int i = m_iDrawOffset; i < iMaxDisplay + m_iDrawOffset; i++) {
				if (Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin + vecOffset, [m_vecSize[0] - 16, 20])) {
					m_iSelected = i;
					ret = true;
				}
				vecOffset[1] += 20;
			}
		} else if (flKey == K_MWHEELUP && iMouseOver) {
			SetOffset(m_iDrawOffset - (iMaxDisplay / 4), TRUE);
			ret = true;
		} else if (flKey == K_MWHEELDOWN && iMouseOver) {
			SetOffset(m_iDrawOffset + (iMaxDisplay / 4), TRUE);
			ret = true;
		}
	}
	return (ret);
}

int VGUIList::GetMaxVisibleItems(void)
{
	int iMaxDisplay = bound(0, m_iItemCount, floor(m_vecSize[1] / 20));
	return m_iItemCount - iMaxDisplay;
}

void VGUIList::SetOffset (int iOffset, int iCallBack)
{
	int iMaxDisplay = bound(0, m_iItemCount, floor(m_vecSize[1] / 20));
	m_iDrawOffset = bound(0, iOffset, m_iItemCount - iMaxDisplay);
	
	if (tmpVGUIList1 && iCallBack) {
		tmpVGUIList1();
	}
}
int VGUIList::GetOffset(void)
{
	return m_iDrawOffset;
}

void VGUIList::SetItemCount (int iCount)
{
	if (!m_iItemCount) {
		NSLog("VGUIList: Initialized with a maximum of %i entries", iCount);
		m_iItemCount = iCount;
		m_strItems = memalloc(iCount * sizeof(string));
	}
}
int VGUIList::GetItemCount(void)
{
	return m_iItemCount;
}

string VGUIList::GetItem (int iIndex)
{
	if (m_iSelected < 0 || m_iItemCount <= 0) {
		dprint("VGUIList: GetItem on empty/unselected list!\n");
		return "ERROR";
	}
	return m_strItems[iIndex];
}

void VGUIList::SetSelected (int iVal)
{
	m_iSelected = iVal;
}
int VGUIList::GetSelected(void)
{
	return m_iSelected;
}

void VGUIList::AddItem (string strItem)
{
	if (!m_iItemCount) {
		dprint("VGUIList: Can't add item to empty list!\n");
		return;
	}
	
	for (int i = 0; i < m_iItemCount; i++) {
		if (!m_strItems[i]) {
			m_strItems[i] = strItem;
			dprint("VGUIList: Item added\n");
			break;
		}
	}
}

void VGUIList::CallOnScroll (void(void) vFunc)
{
	tmpVGUIList1 = vFunc;
}
