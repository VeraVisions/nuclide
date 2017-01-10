/*
OpenCS Project
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

// TODO: Read motd.txt and display that instead
void VGUI_MessageOfTheDay( vector vPos ) {
	static void MessageOfTheDay_ButtonOK( void ) {
		fVGUI_Display = VGUI_TEAMSELECT;
	}

	VGUI_Text( serverkey( "hostname" ), vPos + '16 64 0', '16 16 0');
	
	vector vTextPos = vPos + '16 116 0';
	
	for ( int i = 0; i < 25; i++ ) {
		VGUI_Text( sMOTDString[ i ], vTextPos, '8 8 0' );
		vTextPos_y += 10;
	}
	
	VGUI_Button( "OK", MessageOfTheDay_ButtonOK, vPos + '16 440 0', '80 24 0' );
}
