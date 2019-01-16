/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

int iNightVision;

/*
=================
Nightvision_Toggle

Called by the cmd 'nightvision'
=================
*/
void Nightvision_Toggle( void ) {
	if( getplayerkeyvalue( player_localnum, "*spec" ) == "1" ) {
		return;
	}
	
	if ( !( getstatf( STAT_EQUIPMENT ) & EQUIPMENT_NIGHTVISION ) ) {
		return;
	}
	
	iNightVision = 1 - iNightVision;
	
	if ( iNightVision == TRUE ) {
		localsound( "items/nvg_on.wav", CHAN_ITEM, 1 );
	} else {
		localsound( "items/nvg_off.wav", CHAN_ITEM, 1 );
	}
}

/*
=================
Nightvision_PreDraw

Called before rendering the frame in Draw.c
=================
*/
void Nightvision_PreDraw( void ) {
	if( getplayerkeyvalue( player_localnum, "*spec" ) != "0" ) {
		iNightVision = FALSE;
		return;
	}
	
	if ( iNightVision == TRUE ) {
		dynamiclight_add( pSeat->vPlayerOrigin, 500, '0 0.45 0');
	}
}

/*
=================
Nightvision_PostDraw

Called after rendering the frame in Draw.c
=================
*/
void Nightvision_PostDraw(int x, int y, int w, int h ) {
	if ( iNightVision == TRUE ) {
		drawfill( [x,y], [w,h], '0 0.5 0', 1, DRAWFLAG_ADDITIVE );
	}
}
