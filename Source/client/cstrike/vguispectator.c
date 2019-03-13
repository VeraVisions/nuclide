/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

/*
====================
VGUI_DrawSpectatorHUD
====================
*/
void VGUI_DrawSpectatorHUD( void ) {
	vHUDColor = autocvar_con_color * ( 1 / 255 );
	
	// Draw the borders
	drawfill( video_mins, [ video_res[0], 40 ], '0 0 0', 1 );
	drawfill( video_mins + [ 0, video_res[1] - 40], [ video_res[0], 40 ], '0 0 0', 1 );
	
	// Draw the timer
	int iMinutes, iSeconds, iTens, iUnits;
	iMinutes = getstatf( STAT_GAMETIME ) / 60;
	iSeconds = getstatf( STAT_GAMETIME ) - 60 * iMinutes;
	iTens = iSeconds / 10;
	iUnits = iSeconds - 10 * iTens;
	
	
	drawpic( video_mins + [ video_res[0] - 70, 20 ], "gfx/vgui/640_timer", '14 14', '1 1 1', 1 );
	VGUI_RightText( video_mins + [ video_res[0] - 16, 23 ], sprintf( "%i:%i%i", iMinutes, iTens, iUnits ), '12 12', '0.56 0.56 0.21', FONT_CON );
	
	// Draw the money
	CSQC_DrawText( video_mins + [ video_res[0] - 67, 6 ], "$", '12 12', '0.56 0.56 0.21', 1, 0, FONT_CON );
	VGUI_RightText( video_mins + [ video_res[0] - 16, 6 ], sprintf( "%d", getstatf( STAT_MONEY ) ), '12 12', '0.56 0.56 0.21', FONT_CON );
	
	// Seperator
	drawfill( video_mins + [ video_res[0] - 85, 6 ], [ 2, 28 ], '0.56 0.56 0.21', 1 );
	
	// Team Stats
	VGUI_RightText( video_mins + [ video_res[0] - 96, 6 ], sprintf( _("VGUI_SPEC_TCOUNTER"), getstatf( STAT_WON_T ) ), '12 12', '0.56 0.56 0.21', FONT_CON );
	VGUI_RightText( video_mins + [ video_res[0] - 96, 23 ], sprintf( _("VGUI_SPEC_CTCOUNTER"), getstatf( STAT_WON_CT ) ), '12 12', '0.56 0.56 0.21', FONT_CON );
}
