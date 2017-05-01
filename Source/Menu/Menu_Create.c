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

var int iMapSelected = 0;

/*
=================
m_mainbutton

Buttons on the main menu screen
=================
*/
void menu_mapbutton( vector vPos, int iItem ) {
	
	if ( Menu_InputCheckMouse( vPos, [ stringwidth( sMapList[ iItem ], TRUE, '16 16' ), 16 ] ) == TRUE ) {
		if ( fMouseClick == TRUE ) {
			iMapSelected = iItem;
			fMouseClick = FALSE;
			localsound( "misc/talk.wav" );
		}
	}

	if ( iMapSelected == iItem ) {
		drawmenustring( vPos, sMapList[ iItem ], '16 16', '1 0.5 0', 1.0f, 0 );
	} else {
		drawmenustring( vPos, sMapList[ iItem ], '16 16', '1 1 1', fFadeAlpha, 0 );
	}
}

void m_button_createserver_go( void ) {
	localcmd( sprintf( "map %s\n", sMapList[ iMapSelected ] ) );
}

void m_button_createserver( void ) {
	static int iMapOffset = 0;
	
	static void m_button_createserver_listless( void ) {
		if ( iMapOffset - 15 > 0 ) {
			iMapOffset -= 15;
		} else {
			iMapOffset = 0;
		}
	}
	
	static void m_button_createserver_listmore( void ) {
		if ( iMapOffset + 15 < ( iMapCount - 15 ) ) {
			iMapOffset += 15;
		} else {
			iMapOffset = iMapCount - 15;
		}
	}

	m_drawmenushadow();
	drawmenustring( '43 60 0', "CREATE SERVER", '16 16 0', '1 1 1', fMenuAlpha, FALSE );
	
	vector vPos = '75 100';
	for ( float i = iMapOffset; i < ( 15 + iMapOffset ); i++ ) {
		if ( iMapSelected == i ) {
			drawmenustring( [ vPos_x - 32, vPos_y ], ">>", '16 16 0', '1 1 1', fMenuAlpha, FALSE );
		}
		
		menu_mapbutton( vPos, i );
		vPos_y += 20;
	}
	
	menu_buttoncmd( '332 332', "<<", '16 16', m_button_createserver_listless );
	menu_buttoncmd( '332 364', ">>", '16 16', m_button_createserver_listmore );
	
	menu_buttoncmd( '232 410', "CREATE >>", '16 16', m_button_createserver_go );
};
