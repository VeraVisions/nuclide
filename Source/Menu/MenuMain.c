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
		Object_Label( '244 212', "Warning", FONTSIZE );
		Object_Label( '244 248', "You have not copied over your 'valve' directory", FONTSIZE );
		Object_Label( '244 258', "from Half-Life. This will cause missing models,", FONTSIZE );
		Object_Label( '244 268', "sounds and textures. Be warned!", FONTSIZE );
	}
	
	Object_Button( '72 188', BTN_CONSOLE, Main_ButtonConsole, fButtonAlpha[0] );
	Object_Button( '72 272', BTN_CONFIG, Main_ButtonConfiguration, fButtonAlpha[1] );
	
	Object_Button( '72 328', BTN_MULTIPLAYER, Main_ButtonMultiplayer, fButtonAlpha[2] );
	Object_Button( '72 356', BTN_CUSTOMGAME, __NULL__, fButtonAlpha[3] );
	Object_Button( '72 384', BTN_README, __NULL__, fButtonAlpha[4] );
	Object_Button( '72 412', BTN_VISITWEB, __NULL__, fButtonAlpha[5] );
	Object_Button( '72 440', BTN_QUIT, Main_ButtonQuit, fButtonAlpha[6] );
	
	Object_Desc( '244 282', "Change Counter-Strike's video, audio and control settings.", FONTSIZE );
	Object_Desc( '244 338', "Get online and play Counter-Strike with others around the world.", FONTSIZE );
	Object_Desc( '244 366', "Play/download other mods, or go back to Counter-Strike.", FONTSIZE );
	Object_Desc( '244 394', "Read Counter-Strike's readme.txt.", FONTSIZE );
	Object_Desc( '244 422', "Read the official Counter-Strike manual, learn how to play.", FONTSIZE );
	Object_Desc( '244 450', "Quit Counter-Strike.", FONTSIZE );
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
	Object_Label( '212 216', _("FREECS_QUITMSG"), FONTSIZE );
		
	Object_Button( '208 248', BTN_QUIT, Quit_Exit, fButtonAlpha[0] );
	Object_Button( '364 248', BTN_CANCEL, Quit_Cancel, fButtonAlpha[1] );
}
