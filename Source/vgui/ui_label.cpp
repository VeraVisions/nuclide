/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

class CUILabel : CUIWidget
{
	vector m_vecSize;
	string m_strTitle;
	
	void() CUILabel;
	virtual void() Draw;
	virtual void( vector ) SetSize;
	virtual void( string ) SetTitle;
	virtual void( float, float, float, float ) Input;
};

void CUILabel :: CUILabel ( void )
{
	m_vecSize = '96 16';
	m_iFlags = BUTTON_VISIBLE;
}

void CUILabel :: SetSize ( vector vecSize )
{
	m_vecSize = vecSize;
}
void CUILabel :: SetTitle ( string strName )
{
	m_strTitle = strName;
	SetSize( [ stringwidth( m_strTitle, TRUE, [ g_fntDefault.iScale, g_fntDefault.iScale ] ), 16 ] );
}
void CUILabel :: Draw ( void )
{
	if ( m_strTitle ) {
		Font_DrawField( m_parent.m_vecOrigin + m_vecOrigin, m_vecSize, m_strTitle, g_fntDefault, 0 );
	}
}

void CUILabel :: Input ( float flEVType, float flKey, float flChar, float flDevID )
{
}
