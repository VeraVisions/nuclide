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
Menu_Main

The first, main screen
=================
*/
void Menu_Main( void ) {
	static void Main_ButtonConsole( void ) {
		localcmd( "toggleconsole\n" );
	}
	static void Main_ButtonConfiguration( void ) {
		iMenu = MENU_CONFIGURATION;
	}
	static void Main_ButtonMultiplayer( void ) {
		iMenu = MENU_MULTIPLAYER;
	}
	static void Main_ButtonQuit( void ) {
		iMenu = MENU_QUIT;
	}
	
	if ( iHLContent == FALSE ) {
		Object_Frame( '232 200', '400 96' );
		Object_Label( '244 212', "Warning", '12 12' );
		Object_Label( '244 248', "You have not copied over your 'valve' directory", '12 12' );
		Object_Label( '244 258', "from Half-Life. This will cause missing models,", '12 12' );
		Object_Label( '244 268', "sounds and textures. Be warned!", '12 12' );
	}
	
	Object_Button( '72 188', BTN_CONSOLE, Main_ButtonConsole, fButtonAlpha[0] );
	Object_Button( '72 272', BTN_CONFIG, Main_ButtonConfiguration, fButtonAlpha[1] );
	
	Object_Button( '72 328', BTN_MULTIPLAYER, Main_ButtonMultiplayer, fButtonAlpha[2] );
	Object_Button( '72 356', BTN_CUSTOMGAME, __NULL__, fButtonAlpha[3] );
	Object_Button( '72 384', BTN_README, __NULL__, fButtonAlpha[4] );
	Object_Button( '72 412', BTN_VISITWEB, __NULL__, fButtonAlpha[5] );
	Object_Button( '72 440', BTN_QUIT, Main_ButtonQuit, fButtonAlpha[6] );
}

/*
=================
Menu_Quit

The quit screen
=================
*/
void Menu_Quit( void ) {
	static void Quit_Cancel( void ) {
		iMenu = MENU_MAIN;
	}
	static void Quit_Exit( void ) {
		localcmd( "quit\n" );
	}
	
	Object_Frame( '192 192', '256 96' );
	Object_Label( '212 216', _("FREECS_QUITMSG"), '12 12' );
		
	Object_Button( '208 248', BTN_QUIT, Quit_Exit, fButtonAlpha[0] );
	Object_Button( '364 248', BTN_CANCEL, Quit_Cancel, fButtonAlpha[1] );
}
