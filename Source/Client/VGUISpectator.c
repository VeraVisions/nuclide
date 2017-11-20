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
VGUI_DrawSpectatorHUD
====================
*/
void VGUI_DrawSpectatorHUD( void ) {
	vHUDColor = autocvar_con_color * ( 1 / 255 );
	
	// Draw the borders
	drawfill( vVideoMins, [ vVideoResolution_x, 40 ], '0 0 0', 1 );
	drawfill( vVideoMins + [ 0, vVideoResolution_y - 40], [ vVideoResolution_x, 40 ], '0 0 0', 1 );
	
	// Draw the timer
	int iMinutes, iSeconds, iTens, iUnits;
	iMinutes = getstatf( STAT_GAMETIME ) / 60;
	iSeconds = getstatf( STAT_GAMETIME ) - 60 * iMinutes;
	iTens = iSeconds / 10;
	iUnits = iSeconds - 10 * iTens;
	
	
	drawpic( vVideoMins + [ vVideoResolution_x - 70, 20 ], "gfx/vgui/640_timer", '14 14', '1 1 1', 1 );
	VGUI_RightText( vVideoMins + [ vVideoResolution_x - 16, 23 ], sprintf( "%i:%i%i", iMinutes, iTens, iUnits ), '8 8', '0.56 0.56 0.21', FONT_DEFAULT );
	
	// Draw the money
	CSQC_DrawText( vVideoMins + [ vVideoResolution_x - 67, 6 ], "$", '8 8', '0.56 0.56 0.21', 1, 0, FONT_DEFAULT );
	VGUI_RightText( vVideoMins + [ vVideoResolution_x - 16, 6 ], sprintf( "%d", getstatf( STAT_MONEY ) ), '8 8', '0.56 0.56 0.21', FONT_DEFAULT );
	
	// Seperator
	drawfill( vVideoMins + [ vVideoResolution_x - 85, 6 ], [ 2, 28 ], '0.56 0.56 0.21', 1 );
	
	// Team Stats
	VGUI_RightText( vVideoMins + [ vVideoResolution_x - 96, 6 ], sprintf( _("VGUI_SPEC_TCOUNTER"), getstatf( STAT_WON_T ) ), '8 8', '0.56 0.56 0.21', FONT_DEFAULT );
	VGUI_RightText( vVideoMins + [ vVideoResolution_x - 96, 23 ], sprintf( _("VGUI_SPEC_CTCOUNTER"), getstatf( STAT_WON_CT ) ), '8 8', '0.56 0.56 0.21', FONT_DEFAULT );
}
