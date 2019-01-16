/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

#include "VGUI.h"

/*
====================
VGUI_MessageOfTheDay

The MOTD screen. 

TODO: Networking still needs to be done.
You can't store motds in infokey strings because
newline chars are not supported. You could hack it to use
an array of infokeys, but that'll clutter things up
====================
*/
void VGUI_MessageOfTheDay( vector vPos ) {
	static void MessageOfTheDay_ButtonOK( void ) {
		pSeat->fVGUI_Display = VGUI_TEAMSELECT;
	}

	VGUI_Text( serverkey( "hostname" ), vPos + '16 64 0', '12 12', FONT_CON );
	
	vector vTextPos = vPos + '16 116 0';
	
	for ( int i = 0; i < 25; i++ ) {
		if ( sMOTDString[ i ] != "/" ) {
			VGUI_Text( sMOTDString[ i ], vTextPos, '12 12', FONT_CON );
		}
		vTextPos_y += 14;
	}
	
	VGUI_Button( _("VGUI_OK"), MessageOfTheDay_ButtonOK, vPos + '16 440 0', '80 24 0' );
}
