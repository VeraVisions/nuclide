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
