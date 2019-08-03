/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

class CUITabView : CUIWidget
{
	vector m_vecSize;
	vector m_vecOutlineSize;
	vector m_vecOutlinePos;
	string m_strTitle;
	
	void() CUITabView;
	virtual void() Draw;
	virtual void( vector ) SetPos;
	virtual vector() GetPos;
	virtual void( vector ) SetSize;
	virtual vector() GetSize;
	virtual void( string ) SetTitle;
	virtual void( float, float, float, float ) Input;
};

void CUITabView :: CUITabView ( void )
{
	m_vecSize = '96 16';
	m_iFlags = BUTTON_VISIBLE;
}

void CUITabView :: SetPos ( vector vecSize )
{
	m_vecOrigin = vecSize;
	m_vecOutlinePos = m_vecOrigin + [ 0, 20 ];
}
vector CUITabView :: GetPos ( void )
{
	return m_vecOrigin;
}

void CUITabView :: SetSize ( vector vecSize )
{
	m_vecSize = vecSize;
	m_vecOutlineSize = m_vecSize - [ 0, 20 ];
}
vector CUITabView :: GetSize ( void )
{
	return m_vecSize;
}

void CUITabView :: SetTitle ( string strName )
{
	m_strTitle = strName;
	SetSize( [ stringwidth( m_strTitle, TRUE, [ g_fntDefault.iScale, g_fntDefault.iScale ] ), 16 ] );
}
void CUITabView :: Draw ( void )
{
	
	//drawfill( m_parent.m_vecOrigin + m_vecOutlinePos, [m_vecOutlineSize[0], 1], '1 1 1', 0.5f );
	drawfill( m_parent.m_vecOrigin + m_vecOutlinePos + [ 0, m_vecOutlineSize[1] - 1], [m_vecOutlineSize[0], 1], '0 0 0', 0.5f );
	drawfill( m_parent.m_vecOrigin + m_vecOutlinePos + [ 0, 1], [1, m_vecOutlineSize[1] - 2], '1 1 1', 0.5f );
	drawfill( m_parent.m_vecOrigin + m_vecOutlinePos + [ m_vecOutlineSize[0] - 1, 1], [1, m_vecOutlineSize[1] - 2], '0 0 0', 0.5f );
	
	//Font_DrawText( m_parent.m_vecOrigin + m_vecOrigin + [ 8, 8 ], m_strTitle, g_fntDefault );
}

void CUITabView :: Input ( float flEVType, float flKey, float flChar, float flDevID )
{
}
