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
void m_init( void ) {
	precache_pic( "gfx/shell/splash" );
	precache_pic( "gfx/shell/btns_main" );
	
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
}

/*
=================
m_shutdown

I can see the curtain... the ending.
=================
*/
void m_shutdown( void ) {
	
}
