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

void m_init( void ) {
	precache_pic( "gfx/menu/freecs" );
	precache_pic( "gfx/menu/back1" );
	precache_pic( "gfx/menu/back2" );
	precache_pic( "menu_static" );
	
	// Index all the maps... TODO: Filter out /valve/ to avoid useless junk from being cached.
	searchhandle shMaps = search_begin( "maps/*.bsp", TRUE, TRUE );
	iMapCount = search_getsize( shMaps );
	sMapList = memalloc( sizeof( string ) * iMapCount );
	
	for ( int i = 0; i < iMapCount; i++ ) {
		sMapList[ i ] = substring( search_getfilename( shMaps, i ), 5, strlen( search_getfilename( shMaps, i ) ) - 9 );
	}

	search_end( shMaps );
}

void m_shutdown( void ) {
	
}
