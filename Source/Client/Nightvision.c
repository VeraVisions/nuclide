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

int iNightVision;

/*
=================
Nightvision_Toggle

Called by the cmd 'nightvision'
=================
*/
void Nightvision_Toggle( void ) {
	if( getplayerkeyvalue( player_localnum, "*spectator" ) == "1" ) {
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
	if( getplayerkeyvalue( player_localnum, "*spectator" ) == "1" ) {
		iNightVision = FALSE;
		return;
	}
	
	if ( iNightVision == TRUE ) {
		dynamiclight_add( getproperty( VF_ORIGIN ), 500, '0 0.45 0');
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
