/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

enumflags
{
	AF_RIGHT,
	AF_TOP,
	AF_LEFT,
	AF_BOTTOM
};

typedef struct
{
	int iID;
	int iScale;
	vector vecColor;
	float flAlpha;
	int iFlags;
} font_s;

void Font_Load ( string strFile, font_s &fntNew )
{
	string strTemp;
	string strFontPath;
	filestream fileFont = fopen( strFile, FILE_READ );

	fntNew.iID = FONT_DEFAULT;
	fntNew.iScale = 8;
	fntNew.vecColor = '1 1 1';
	fntNew.flAlpha = 1.0f;
	fntNew.iFlags = 0;

	if ( fileFont >= 0 ) {
		while ( ( strTemp = fgets( fileFont ) ) ) {
			if ( tokenizebyseparator( strTemp, "=" ) == 2 ) {
				switch ( argv( 0 ) ) {
					case "COLOR":
						fntNew.vecColor = stov( argv( 1 ) ) / 255;
						break;
					case "ALPHA":
						fntNew.flAlpha = stof( argv( 1 ) ) / 255;
						break;
					case "SIZE":
						fntNew.iScale = (int)stof( argv( 1 ) );
						break;
					case "PATH":
						strFontPath = argv( 1 );
						break;
					case "FLAGS":
						fntNew.iFlags = (int)stof( argv( 1 ) );
						break;
					default:
						break;
				}
			}
		}
		fclose( fileFont );
	} else {
		error( sprintf( "[MENU] Cannot load font file %s!", strFile ) );
	}

	fntNew.iID = (int)loadfont( "", strFontPath, ftos( (float)fntNew.iScale ), -1, 0, 0 );
}

void Font_DrawText ( vector vecOrigin, string strText, font_s fnt )
{
	drawfont = (float)fnt.iID;
	drawstring( vecOrigin, strText, [ fnt.iScale, fnt.iScale ], fnt.vecColor, fnt.flAlpha, (float)fnt.iFlags );
}

void Font_DrawField ( vector vecOrigin, vector vecSize, string strText, font_s fnt, int iAlignFlags )
{
	drawfont = (float)fnt.iID;
	drawtextfield( vecOrigin, vecSize, (float)iAlignFlags, strText );
}
