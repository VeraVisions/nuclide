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

void Menu_Main( void ) {
	static void Main_ButtonConsole( void ) {
		localcmd( "toggleconsole\n" );
	}
	static void Main_ButtonQuit( void ) {
		iMenu = MENU_QUIT;
	}
	
	Object_Button( '72 188', BTN_CONSOLE, Main_ButtonConsole, fButtonAlpha[0] );
	Object_Button( '72 272', BTN_CONFIG, __NULL__, fButtonAlpha[1] );
	
	Object_Button( '72 328', BTN_MULTIPLAYER, __NULL__, fButtonAlpha[2] );
	Object_Button( '72 356', BTN_CUSTOMGAME, __NULL__, fButtonAlpha[3] );
	Object_Button( '72 384', BTN_README, __NULL__, fButtonAlpha[4] );
	Object_Button( '72 412', BTN_VISITWEB, __NULL__, fButtonAlpha[5] );
	Object_Button( '72 440', BTN_QUIT, Main_ButtonQuit, fButtonAlpha[6] );
	
}

void Menu_Quit( void ) {
	static void Quit_Cancel( void ) {
		iMenu = MENU_MAIN;
	}
	static void Quit_Exit( void ) {
		localcmd( "quit\n" );
	}
	
	Object_Frame( '192 192', '256 96' );
	drawstring( vMenuOffset + '200 216', "FREECS_QUITMSG", '8 8', MENU_FGCOLOR, 1.0f, 0 );
		
	Object_Button( '200 248', BTN_QUIT, Quit_Exit, fButtonAlpha[0] );
	Object_Button_Right( '440 248', BTN_CANCEL, Quit_Cancel, fButtonAlpha[1] );
}