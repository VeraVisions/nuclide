/*
FreeCS Project
Copyright (C) 2016, 2017 Marco "eukara" Hladik

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

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
	
	Menu_Configuration_Init();
	
	// Index all the maps... TODO: Filter out /valve/ to avoid useless junk from being cached.
	searchhandle shMaps = search_begin( "maps/*.bsp", TRUE, TRUE );
	iMapCount = search_getsize( shMaps );
	sMapList = memalloc( sizeof( string ) * iMapCount );
	
	for ( int i = 0; i < iMapCount; i++ ) {
		sMapList[ i ] = substring( search_getfilename( shMaps, i ), 5, strlen( search_getfilename( shMaps, i ) ) - 9 );
	}

	search_end( shMaps );
	FONT_MENU = loadfont( "menu", "gfx/menuchars", "32", -1 );
	
	vMenuButtonsSize = drawgetimagesize( "gfx/shell/btns_main" );
	
	// For those peeps who don't read or don't want to follow the instructions
	if ( whichpack( "sound/items/9mmclip1.wav" ) ) {
		iHLContent = TRUE;
	}
	
	// Initialize all the spraylogos
	searchhandle shSprays = search_begin( "logos/*.bmp", TRUE, TRUE );
	sLogos = memalloc( sizeof( string ) * search_getsize( shSprays ) );
	for ( int i = 0; i < search_getsize( shSprays ); i++ ) {
		string sShadername;
		string sShortname = search_getfilename( shSprays, i );
		precache_pic( sShortname );
		sShortname = substring( sShortname, 6, strlen( sShortname ) - 10 );
		sLogos[ i ] = sShortname;
		sShadername = sprintf( "spray_%s", sShortname );
		if ( substring( sShortname, 0, 1 ) == "#" ) {
			shaderforname( sShadername, sprintf("{\ncull disable\npolygonOffset\n{\nmap %s\n}\n}\n", search_getfilename( shSprays, i ) ) );
		} else {
			shaderforname( sShadername, sprintf("{\ncull disable\npolygonOffset\n{\nmap %s\nblendFunc GL_ZERO GL_ONE_MINUS_SRC_COLOR\n\nrgbgen vertex\n}\n}\n", search_getfilename( shSprays, i ) ) );
		}
		iLogos += 1;
	}
	search_end( shSprays );
}

/*
=================
m_shutdown

I can see the curtain... the ending.
=================
*/
void m_shutdown( void ) {
	
}
