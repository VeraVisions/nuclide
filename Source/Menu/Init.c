/*
	Copyright 2016-2018 Marco "eukara" Hladik
	
	MIT LICENSE

	Permission is hereby granted, free of charge, to any person 
	obtaining a copy of this software and associated documentation 
	files (the "Software"), to deal in the Software without 
	restriction, including without limitation the rights to use,
	copy, modify, merge, publish, distribute, sublicense, and/or
	sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.
*/

string(float a, float b) getgamedirinfo = #0;

/*
=================
m_init

Precaches and loading for the menu system
=================
*/
void Menu_Configuration_Init( void );
void m_init( void ) {
	precache_pic( "gfx/shell/splash" );
	precache_pic( "gfx/shell/btns_main" );
	precache_pic( "gfx/shell/cb_empty" );
	precache_pic( "gfx/shell/cb_checked" );
	
	Menu_Configuration_Init();
	
	// Index all the maps... TODO: Filter out /valve/ to avoid useless junk from being cached.
	searchhandle shMaps = search_begin( "maps/*.bsp", TRUE, TRUE );
	iMapCount = search_getsize( shMaps );
	sMapList = memalloc( sizeof( string ) * iMapCount );
	
	for ( int i = 0; i < iMapCount; i++ ) {
		sMapList[ i ] = substring( search_getfilename( shMaps, i ), 5, strlen( search_getfilename( shMaps, i ) ) - 9 );
	}

	search_end( shMaps );
	
	vMenuButtonsSize = drawgetimagesize( "gfx/shell/btns_main" );
	
	// For those peeps who don't read or don't want to follow the instructions
	if ( whichpack( "sound/items/9mmclip1.wav" ) ) {
		iHLContent = TRUE;
	}
	
	// Initialize all the spraylogos
	searchhandle shSprays = search_begin( "*.bmp", TRUE, TRUE );
	sLogos = memalloc( sizeof( string ) * search_getsize( shSprays ) );
	for ( int i = 0; i < search_getsize( shSprays ); i++ ) {
		string sShadername;
		string sShortname = search_getfilename( shSprays, i );
		precache_pic( sShortname );
		sShortname = substring( sShortname, 0, strlen( sShortname ) - 4 );
		sLogos[ i ] = sShortname;
		sShadername = sprintf( "spray_%s", sShortname );
		if ( substring( sShortname, 0, 1 ) == "#" ) {
			shaderforname( sShadername, sprintf("{\ncull disable\npolygonOffset\n{\nmap %s\n}\n}\n", search_getfilename( shSprays, i ) ) );
		} else {
			shaderforname( sShadername, sprintf("{\ncull disable\npolygonOffset\n{\nmap %s\nblendFunc GL_ZERO GL_ONE_MINUS_SRC_COLOR\nrgbgen vertex\n}\n}\n", search_getfilename( shSprays, i ) ) );
		}
		iLogos += 1;
	}
	search_end( shSprays );
	
	drawfont = loadfont( "font", "", "12", -1 );

	string gamedirname;
	string gamedescription;
	for (int gameidx = 0; (gamedirname = getgamedirinfo(gameidx, 0)); gameidx++) {
		gamedescription = getgamedirinfo(gameidx, 1);
		print(sprintf("Gamedir %s, description %s\n", gamedirname, gamedescription));
	}
}

/*
=================
m_shutdown

I can see the curtain... the ending.
=================
*/
void m_shutdown( void ) {
	
}
