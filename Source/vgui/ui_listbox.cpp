/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

class CUIListBox : CUIWidget
{
	vector m_vecSize;
	string m_strTitle;
	string *m_strItems;
	int m_iItemCount;
	int m_iSelected;
	int m_iDrawOffset;
	
	void() CUIListBox;
	virtual void( vector ) SetSize;
	virtual void( int ) SetOffset;
	virtual void( string ) AddItem;
	virtual void( int ) SetItemCount;
	virtual string( int ) GetItem;
	virtual int() GetSelected;
	virtual void() Draw;
	virtual void( float, float, float, float ) Input;
};

void CUIListBox :: CUIListBox ( void )
{
	m_vecSize = '96 16';
	m_iFlags = 1;
	m_iSelected = -1;
}

void CUIListBox :: SetSize ( vector vecSize )
{
	m_vecSize = vecSize;
}
void CUIListBox :: SetItemCount ( int iCount )
{
	if ( !m_iItemCount ) {
		dprint( sprintf( "CUIListBox: Initialized with a maximum of %i entries\n", iCount ) );
		m_iItemCount = iCount;
		m_strItems = memalloc( iCount * sizeof( string ) );
	}
}
void CUIListBox :: SetOffset ( int iOffset )
{
	int iMaxDisplay = bound( 0, m_iItemCount, floor( m_vecSize[1] / 20 ) );
	m_iDrawOffset = bound( 0, iOffset, m_iItemCount - iMaxDisplay );
}

string CUIListBox :: GetItem ( int iIndex )
{
	return m_strItems[ iIndex ];
}

int CUIListBox :: GetSelected ( void )
{
	return m_iSelected;
}

void CUIListBox :: AddItem ( string strItem )
{
	if ( !m_iItemCount ) {
		dprint( "CUIListBox: Can't add item to empty list!\n" );
		return;
	}
	
	for ( int i = 0; i < m_iItemCount; i++ ) {
		if ( !m_strItems[i] ) {
			m_strItems[i] = strItem;
			dprint( "CUIListBox: Item added\n" );
			break;
		}
	}
}

void CUIListBox :: Draw ( void )
{
	int iMaxDisplay;
	if ( !m_iItemCount ) {
		return;
	}
	
	drawfill( m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, '0 0 0', 0.5f );
	drawfill( m_parent.m_vecOrigin + m_vecOrigin, [m_vecSize[0], 1], '0 0 0', 0.5f );
	drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ 0, m_vecSize[1] - 1], [m_vecSize[0], 1], '1 1 1', 0.5f );
	drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ 0, 1], [1, m_vecSize[1] - 2], '0 0 0', 0.5f );
	drawfill( m_parent.m_vecOrigin + m_vecOrigin + [ m_vecSize[0] - 1, 1], [1, m_vecSize[1] - 2], '1 1 1', 0.5f );

	vector vecOffset = '8 8';
	
	iMaxDisplay = bound( 0, m_iItemCount, floor( m_vecSize[1] / 20 ) );
	for ( int i = m_iDrawOffset; i < iMaxDisplay + m_iDrawOffset; i++ ) {
		if ( !m_strItems[i] ) {
			break;
		}
		
		if ( m_iSelected == i ) {
			drawfill( m_parent.m_vecOrigin + m_vecOrigin + vecOffset + '-7 -3', [ m_vecSize[0] - 2, 18 ], '1 1 1', 0.5f );
		}
		
		Font_DrawText( m_parent.m_vecOrigin + m_vecOrigin + vecOffset, m_strItems[i], g_fntDefault );
		vecOffset[1] += 20;
	}
}

void CUIListBox :: Input ( float flEVType, float flKey, float flChar, float flDevID )
{
	int iMaxDisplay;
	iMaxDisplay = bound( 0, m_iItemCount, floor( m_vecSize[1] / 20 ) );
	
	vector vecOffset = '8 8';
	if ( flEVType == IE_KEYDOWN ) {
		if ( flKey == K_MOUSE1 ) {
			for ( int i = m_iDrawOffset; i < iMaxDisplay + m_iDrawOffset; i++ ) {
				if ( Util_MouseAbove( getmousepos(), m_parent.m_vecOrigin + m_vecOrigin + vecOffset, [ m_vecSize[0] - 16, 20 ] ) ) {
					m_iSelected = i;
					return;
				}
				vecOffset[1] += 20;
			}
		} else if ( flKey == K_MWHEELUP ) {
			SetOffset( --m_iDrawOffset );
		} else if ( flKey == K_MWHEELDOWN ) {
			SetOffset( ++m_iDrawOffset );
		}
	}
}
