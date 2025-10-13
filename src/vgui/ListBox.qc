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

A box containing a listing of items. Taking up as much space as any vguiTextBox.
When interacted with, gives you the choice of making a selection of an undefined
selection of items.

@ingroup vgui
*/
class vguiListBox:vguiWidget
{
public:
	void vguiListBox(void);

	nonvirtual void AddItem(string);
	nonvirtual void SetItemCount(int);
	nonvirtual string GetItem(void);
	nonvirtual void SelectionComplete(string);
	nonvirtual void ShowPicker(void);

	virtual void Draw(void);
	virtual bool Input(float, float, float, float);
	virtual void Spawned(void);

private:
	vector m_vecSize;
	string m_strTitle;

	vguiListPicker m_listPicker;
};

void
vguiListBox::vguiListBox(void)
{
	m_strTitle = __NULL__;
}

void
vguiListBox::SelectionComplete(string selectedString)
{
	m_strTitle = selectedString;
}

void
vguiListBox::Spawned(void)
{
	SetSize([96,16]);

	m_listPicker = spawn(vguiListPicker);
	m_listPicker.CallOnSelect(SelectionComplete);
	//Desktop_Add( m_listPicker );
	m_listPicker.Hide();
}

string
vguiListBox::GetItem(void)
{
	return (m_strTitle);
}

void
vguiListBox::SetItemCount(int itemCount)
{
	m_listPicker.SetItemCount(itemCount);
}

void
vguiListBox::AddItem(string strItem)
{
	if (!STRING_SET(m_strTitle)) {
		m_strTitle = strItem;
	}

	m_listPicker.AddItem(strItem);
}

void
vguiListBox::Draw(void)
{
	vguiTheme theme = GetTheme();
	drawfill(m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, [0,0,0], 0.5f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin, [m_vecSize[0], 1], [0,0,0], 0.5f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, m_vecSize[1] - 1], [m_vecSize[0], 1], [1,1,1], 0.5f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [0, 1], [1, m_vecSize[1] - 2], [0,0,0], 0.5f);
	drawfill(m_parent.m_vecOrigin + m_vecOrigin + [m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], [1,1,1], 0.5f);
	theme.DrawText(m_parent.m_vecOrigin + m_vecOrigin, m_strTitle, m_vecSize, g_fntDefault);
}

void
vguiListBox::ShowPicker(void)
{
	m_listPicker.Show();
	m_listPicker.Reposition();
}

bool
vguiListBox::Input (float flEVType, float flKey, float flChar, float flDevID)
{
	bool ret = false;

	if (flEVType == IE_KEYDOWN) {
		if (flKey == K_MOUSE1) {
			if (Util_MouseAbove(g_vecMousePos, m_parent.m_vecOrigin + m_vecOrigin, m_vecSize)) {
				ShowPicker();
				//ret = true;
			}
		}
	}

	return (ret);
}
