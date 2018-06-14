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
void Nightvision_PostDraw( void ) {
	if ( iNightVision == TRUE ) {
		drawfill( '0 0', vVideoResolution, '0 0.5 0', 1, DRAWFLAG_ADDITIVE );
	}
}
