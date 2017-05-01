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

void m_button_quit( void ) {
	static void m_button_quit_yes( void ) {
		localcmd( "quit\n" );
	}
	static void m_button_quit_no( void ) {
		iMenu = 0;
	}
	
	m_drawmenushadow();
	
	drawmenustring( '43 60 0', "QUIT GAME", '16 16 0', '1 1 1', fMenuAlpha, FALSE );
	drawmenustring( '88 211 0', "Are you sure you want to quit?", '8 8 0', '1 1 1', fMenuAlpha, FALSE );
	menu_buttoncmd( '112 235 0', "Yes", '8 8', m_button_quit_yes );
	menu_buttoncmd( '283 235 0', "No", '8 8', m_button_quit_no );
};


void m_button_disconnect( void ) {
	static void m_button_disconnect_yes( void ) {
		iMenu = 0;
		localcmd( "disconnect\n" );
	}
	static void m_button_disconnect_no( void ) {
		iMenu = 0;
	}
	
	m_drawmenushadow();
	
	drawmenustring( '43 60 0', "DISCONNECT", '16 16 0', '1 1 1', fMenuAlpha, FALSE );
	drawmenustring( '88 211 0', "Close connection to the server?", '8 8 0', '1 1 1', fMenuAlpha, FALSE );
	menu_buttoncmd( '112 235 0', "Yes", '8 8', m_button_disconnect_yes );
	menu_buttoncmd( '283 235 0', "No", '8 8', m_button_disconnect_no );
};
