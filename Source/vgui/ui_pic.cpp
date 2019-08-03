/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

enumflags
{
	IMAGE_VISIBLE
};

class CUIPic : CUIWidget
{
	vector m_vecSize;
	string m_strImage;
	
	void() CUIPic;
	
	virtual void( vector ) SetSize;
	virtual vector() GetSize;
	
	virtual void( string ) SetImage;
	virtual string() GetImage;
	
	virtual void() Draw;
	virtual void( float, float, float, float ) Input;
};

void CUIPic :: CUIPic ( void )
{
	m_vecSize = '16 16';
	m_iFlags = IMAGE_VISIBLE;
}

void CUIPic :: Draw ( void )
{
	if ( m_strImage ) {
		drawpic( m_parent.m_vecOrigin + m_vecOrigin, m_strImage, m_vecSize, '1 1 1', 1.0f );
	}
}

void CUIPic :: Input ( float flEVType, float flKey, float flChar, float flDevID )
{
}

void CUIPic :: SetSize ( vector vecSize )
{
	m_vecSize = vecSize;
}
vector CUIPic :: GetSize ( void )
{
	return m_vecSize;
}

void CUIPic :: SetImage ( string strName )
{
	m_strImage = strName;
}
string CUIPic :: GetImage ( void )
{
	return m_strImage;
}
