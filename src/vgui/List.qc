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

.void(void) tmpvguiList1;
.void(void) tmpvguiList3;

/** VGUI Widget: List

@ingroup vgui
*/
class vguiList:vguiWidget
{
public:
	void vguiList(void);

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
	nonvirtual void CallOnDoubleClick(void(vguiList, int));
	nonvirtual void CallOnSelectionChanged(void(void));

	virtual void Draw(void);
	virtual bool Input(float, float, float, float);
	virtual void Spawned(void);

private:
	string m_strTitle;
	string *m_strItems;
	int m_iItemCount;
	int m_iSelected;
	int m_iDrawOffset;
	float m_flClickTimer;
};

.void(vguiList, int) tmpvguiList2;

void vguiList::vguiList(void)
{
	m_iSelected = -1;
	m_iDrawOffset = 0;
	tmpvguiList1 = __NULL__;
	tmpvguiList2 = __NULL__;
	tmpvguiList3 = __NULL__;
}

void vguiList::Spawned(void)
{
	SetSize([96,16]);
}

void vguiList::Draw(void)
{
	vguiTheme theme = GetTheme();
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

bool vguiList::Input (float flEVType, float flKey, float flChar, float flDevID)
{
	bool ret = false;
	int iMaxDisplay;
	int iMouseOver = Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin, m_vecSize);
	iMaxDisplay = bound(0, m_iItemCount, floor(m_vecSize[1] / 20));

	if (!m_iItemCount) {
		return (false);
	}

	vector vecOffset = [8,8];
	if (flEVType == IE_KEYDOWN) {
		if (flKey == K_MOUSE1) {
			for (int i = m_iDrawOffset; i < iMaxDisplay + m_iDrawOffset; i++) {
				if (Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin + vecOffset, [m_vecSize[0] - 16, 20])) {
					/* last item as last time */
					if (m_iSelected == i) {
						/* double click timer */
						if (m_flClickTimer > time) {
							if (tmpvguiList2)
								tmpvguiList2(this, i);
						}
					}
					m_iSelected = i;

					if (tmpvguiList3) {
						tmpvguiList3();
					}

					m_flClickTimer = time + 0.5f;
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

int vguiList::GetMaxVisibleItems(void)
{
	int iMaxDisplay = bound(0, m_iItemCount, floor(m_vecSize[1] / 20));
	return m_iItemCount - iMaxDisplay;
}

void vguiList::SetOffset (int iOffset, int iCallBack)
{
	int iMaxDisplay = bound(0, m_iItemCount, floor(m_vecSize[1] / 20));
	m_iDrawOffset = bound(0, iOffset, m_iItemCount - iMaxDisplay);

	if (tmpvguiList1 && iCallBack) {
		tmpvguiList1();
	}
}
int vguiList::GetOffset(void)
{
	return m_iDrawOffset;
}

void vguiList::SetItemCount (int iCount)
{
	if (!m_iItemCount) {
		ncLog("vguiList: Initialized with a maximum of %i entries", iCount);
		m_iItemCount = iCount;
		m_strItems = memalloc(iCount * sizeof(string));
	}
}
int vguiList::GetItemCount(void)
{
	return m_iItemCount;
}

string vguiList::GetItem (int iIndex)
{
	if (iIndex < 0i || m_iItemCount <= 0i) {
		ncError("vguiList: GetItem on empty/unselected list! %i/%i\n", iIndex, m_iItemCount);
		return "ERROR";
	}
	return m_strItems[iIndex];
}

void vguiList::SetSelected (int iVal)
{
	m_iSelected = iVal;
}
int vguiList::GetSelected(void)
{
	return m_iSelected;
}

void vguiList::AddItem (string strItem)
{
	if (!m_iItemCount) {
		dprint("vguiList: Can't add item to empty list!\n");
		return;
	}

	for (int i = 0; i < m_iItemCount; i++) {
		if (!m_strItems[i]) {
			m_strItems[i] = strItem;
			dprint("vguiList: Item added\n");
			break;
		}
	}
}

void vguiList::CallOnScroll (void(void) vFunc)
{
	tmpvguiList1 = vFunc;
}

void vguiList::CallOnSelectionChanged (void(void) vFunc)
{
	tmpvguiList3 = vFunc;
}

void vguiList::CallOnDoubleClick (void(vguiList, int) vFunc)
{
	tmpvguiList2 = vFunc;
}
