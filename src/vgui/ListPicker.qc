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

.void(string) tmpvguiPickerCB;

class
vguiListPicker:vguiWindow
{
	void vguiListPicker(void);

	virtual void Spawned(void);
	virtual void Reposition(void);

	
	nonvirtual void ListPicker_ScrollUpdate(void);
	nonvirtual void ListPicker_ListUpdate(void);
	nonvirtual void ListPicker_Select(void);
	nonvirtual void AddItem(string);
	nonvirtual void SetItemCount(int);
	nonvirtual void CallOnSelect(void(string) func);

private:
	vguiList m_lsbEntries;
	vguiScrollBar m_scrlEntries;
	vguiButton m_btnSelect;

};

void
vguiListPicker::vguiListPicker(void)
{
	m_lsbEntries = __NULL__;
	m_scrlEntries = __NULL__;
	m_btnSelect = __NULL__;
	tmpvguiPickerCB = 0;
}

void
vguiListPicker::AddItem(string addedItem)
{
	m_lsbEntries.AddItem( addedItem );
}

void
vguiListPicker::SetItemCount(int itemCount)
{
	m_lsbEntries.SetItemCount( itemCount );
	m_scrlEntries.SetMax( m_lsbEntries.GetMaxVisibleItems() );
}

void
vguiListPicker::Reposition(void)
{
	SetPos( ( g_vidsize / 2 ) - ( GetSize() / 2 ) );
}

void
vguiListPicker::ListPicker_ScrollUpdate(void)
{
	m_lsbEntries.SetOffset( m_scrlEntries.GetValue(), FALSE );
}

void
vguiListPicker::ListPicker_ListUpdate(void)
{
	m_scrlEntries.SetValue( m_lsbEntries.GetOffset() );
}

void
vguiListPicker::ListPicker_Select(void)
{
	if (tmpvguiPickerCB) {
		tmpvguiPickerCB(m_lsbEntries.GetItem( m_lsbEntries.GetSelected() ));
	}
	Hide();
}

void
vguiListPicker::CallOnSelect(void(string) func)
{
	tmpvguiPickerCB = func;
}

void
vguiListPicker::Spawned(void)
{
	super::Spawned();

	SetSize( [256,180] );
	SetTitle( "List Picker" );
	SetStyleMask(vguiWindowTitled);

	m_lsbEntries = spawn( vguiList );
	m_lsbEntries.SetSize( [192, 96] );
	m_lsbEntries.SetPos( [8, 32] );
	m_lsbEntries.CallOnScroll( ListPicker_ScrollUpdate );

	m_scrlEntries = spawn( vguiScrollBar );
	m_scrlEntries.SetLength( 96 );
	m_scrlEntries.SetPos( [201,32] );
	m_scrlEntries.SetMin( 0 );
	m_scrlEntries.SetStep( 1 );
	m_scrlEntries.CallOnChange( ListPicker_ListUpdate );

	m_btnSelect = spawn( vguiButton );
	m_btnSelect.SetTitle( "Select" );
	m_btnSelect.SetPos( [8,132] );
	m_btnSelect.SetSize( [64,24] );
	m_btnSelect.SetFunc( ListPicker_Select );

	Add( m_lsbEntries );
	Add( m_scrlEntries );
	Add( m_btnSelect );

	Reposition();
}
