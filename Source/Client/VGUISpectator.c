/*
OpenCS Project
Copyright (C) 2015 Marco "eukara" Hladik

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

void VGUI_DrawSpectatorHUD( void ) {
	// Draw the borders
	drawfill( [ 0, 0 ], [ vVideoResolution_x, 40 ], '0 0 0', 1 );
	drawfill( [ 0, vVideoResolution_y - 40], [ vVideoResolution_x, 40 ], '0 0 0', 1 );
	
	// Draw the timer
	int iMinutes, iSeconds, iTens, iUnits;
	if( serverkey( "timelimit" ) ) {
		float fTimeLeft = ( stof( serverkey( "timelimit" ) ) * 60 ) - getstatf( STAT_GAMETIME );
		if ( fTimeLeft < 0 ) {
			iMinutes = iSeconds = iTens = iUnits = 0;
		} else {
			iMinutes = fTimeLeft / 60;
			iSeconds = fTimeLeft - 60 * iMinutes;
			iTens = iSeconds / 10;
			iUnits = iSeconds - 10 * iTens;
		}
	} else {
		iMinutes = getstatf( STAT_GAMETIME ) / 60;
		iSeconds = getstatf( STAT_GAMETIME ) - 60 * iMinutes;
		iTens = iSeconds / 10;
		iUnits = iSeconds - 10 * iTens;
	}
	
	drawpic( [ vVideoResolution_x - 70, 20 ], "gfx/vgui/640_timer", '14 14', '1 1 1', 1 );
	VGUI_RightText( [ vVideoResolution_x - 16, 23 ], sprintf( "%i:%i%i", iMinutes, iTens, iUnits ), '8 8 0', '0.56 0.56 0.21' );
	
	// Draw the money
	drawstring( [ vVideoResolution_x - 67, 6 ], "$", '8 8 0', '0.56 0.56 0.21', 1, 0 );
	VGUI_RightText( [ vVideoResolution_x - 16, 6 ], sprintf( "%d", getstatf( STAT_MONEY ) ), '8 8 0', '0.56 0.56 0.21' );
	
	// Seperator
	drawfill( [ vVideoResolution_x - 85, 6 ], [ 2, 28 ], '0.56 0.56 0.21', 1 );
	
	// Team Stats
	VGUI_RightText( [ vVideoResolution_x - 96, 6 ], sprintf( "Terrorists: %d", getstatf( STAT_WON_T ) ), '8 8 0', '0.56 0.56 0.21' );
	VGUI_RightText( [ vVideoResolution_x - 96, 23 ], sprintf( "CT Forces: %d", getstatf( STAT_WON_CT ) ), '8 8 0', '0.56 0.56 0.21' );
}
