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
	VGUI_RightText( vVideoMins + [ vVideoResolution_x - 16, 23 ], sprintf( "%i:%i%i", iMinutes, iTens, iUnits ), '12 12', '0.56 0.56 0.21', FONT_CON );
	
	// Draw the money
	CSQC_DrawText( vVideoMins + [ vVideoResolution_x - 67, 6 ], "$", '12 12', '0.56 0.56 0.21', 1, 0, FONT_CON );
	VGUI_RightText( vVideoMins + [ vVideoResolution_x - 16, 6 ], sprintf( "%d", getstatf( STAT_MONEY ) ), '12 12', '0.56 0.56 0.21', FONT_CON );
	
	// Seperator
	drawfill( vVideoMins + [ vVideoResolution_x - 85, 6 ], [ 2, 28 ], '0.56 0.56 0.21', 1 );
	
	// Team Stats
	VGUI_RightText( vVideoMins + [ vVideoResolution_x - 96, 6 ], sprintf( _("VGUI_SPEC_TCOUNTER"), getstatf( STAT_WON_T ) ), '12 12', '0.56 0.56 0.21', FONT_CON );
	VGUI_RightText( vVideoMins + [ vVideoResolution_x - 96, 23 ], sprintf( _("VGUI_SPEC_CTCOUNTER"), getstatf( STAT_WON_CT ) ), '12 12', '0.56 0.56 0.21', FONT_CON );
}
