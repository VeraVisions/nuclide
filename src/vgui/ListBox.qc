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

/** VGUI Widget: List Box

@ingroup vgui
*/
class vguiListBox:vguiWidget
{
public:
	void vguiListBox(void);

	nonvirtual void SetOffset(int);
	nonvirtual void AddItem(string);
	nonvirtual void SetItemCount(int);
	nonvirtual string GetItem(int);
	nonvirtual int GetSelected(void);

	virtual void Draw(void);
	virtual bool Input(float, float, float, float);
	virtual void Spawned(void);

private:
	vector m_vecSize;
	string m_strTitle;
	string *m_strItems;
	int m_iItemCount;
	int m_iSelected;
	int m_iDrawOffset;
};

void vguiListBox::vguiListBox(void)
{
	m_iSelected = -1;
}

void vguiListBox::Spawned(void)
{
	SetSize([96,16]);
}

void vguiListBox::SetItemCount (int iCount)
{
	if (!m_iItemCount) {
		ncLog("vguiListBox: Initialized with a maximum of %i entries", iCount);
		m_iItemCount = iCount;
		m_strItems = memalloc(iCount * sizeof(string));
	}
}
void vguiListBox::SetOffset (int iOffset)
{
	int iMaxDisplay = bound(0, m_iItemCount, floor(m_vecSize[1] / 20));
	m_iDrawOffset = bound(0, iOffset, m_iItemCount - iMaxDisplay);
}

string vguiListBox::GetItem (int iIndex)
{
	return m_strItems[iIndex];
}

int vguiListBox::GetSelected(void)
{
	return m_iSelected;
}

void vguiListBox::AddItem (string strItem)
{
	if (!m_iItemCount) {
		dprint("vguiListBox: Can't add item to empty list!\n");
		return;
	}

	for (int i = 0; i < m_iItemCount; i++) {
		if (!m_strItems[i]) {
			m_strItems[i] = strItem;
			dprint("vguiListBox: Item added\n");
			break;
		}
	}
}

void vguiListBox::Draw(void)
{
	vguiTheme theme = GetTheme();

	int iMaxDisplay;
	if (!m_iItemCount) {
		return;
	}

	drawfill(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, [0,0,0], 0.5f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin, [m_vecSize[0], 1], [0,0,0], 0.5f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, m_vecSize[1] - 1], [m_vecSize[0], 1], [1,1,1], 0.5f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, 1], [1, m_vecSize[1] - 2], [0,0,0], 0.5f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], [1,1,1], 0.5f);

	vector vecOffset = [8,8];

	iMaxDisplay = bound(0, m_iItemCount, floor(m_vecSize[1] / 20));
	for (int i = m_iDrawOffset; i < iMaxDisplay + m_iDrawOffset; i++) {
		if (!m_strItems[i]) {
			break;
		}

		if (m_iSelected == i) {
			drawfill(m_parent.m_vecOrigin + m_vecOrigin + vecOffset + [-7,-3], [m_vecSize[0] - 2, 18], [1,1,1], 0.5f);
		}

		theme.DrawText(m_parent.m_vecOrigin + m_vecOrigin + vecOffset, m_strItems[i], m_vecSize, g_fntDefault);
		vecOffset[1] += 20;
	}
}

bool vguiListBox::Input (float flEVType, float flKey, float flChar, float flDevID)
{
	bool ret = false;
	int iMaxDisplay;
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
		} else if (flKey == K_MWHEELUP) {
			SetOffset(--m_iDrawOffset);
			ret = true;
		} else if (flKey == K_MWHEELDOWN) {
			SetOffset(++m_iDrawOffset);
			ret = true;
		}
	}
	return (ret);
}
