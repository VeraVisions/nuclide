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

// Radio Commands
#define VGUIRADIO_COMMANDS 6
float fRadioCommands[ VGUIRADIO_COMMANDS ] = {
	RADIO_CT_COVERME,
	RADIO_CT_POINT,
	RADIO_POSITION,
	RADIO_REGROUP,
	RADIO_FOLLOWME,
	RADIO_FIREASSIS
};

// Group Radio Commands
#define VGUIRADIO_GROUPCOMMANDS 6
float fRadioGroupCommands[ VGUIRADIO_GROUPCOMMANDS ] = {
	RADIO_GO,
	RADIO_FALLBACK,
	RADIO_STICKTOG,
	RADIO_CT_INPOS,
	RADIO_STORMFRONT,
	RADIO_COM_REPORTIN
};

// Radio Responses
#define VGUIRADIO_RESPONSES 9
float fRadioResponses[ VGUIRADIO_RESPONSES ] = {
	RADIO_CT_AFFIRM,
	RADIO_CT_ENEMYS,
	RADIO_CT_BACKUP,
	RADIO_CLEAR,
	RADIO_CT_INPOS,
	RADIO_CT_REPORTINGIN,
	RADIO_BLOW,
	RADIO_NEGATIVE,
	RADIO_ENEMYDOWN
};

/*
====================
VGUI_Radio_DrawCommand

Prints and acts as an input check for a single command
====================
*/
void VGUI_Radio_DrawCommand( float fIndex, float fMessage, vector vPos ) {
	VGUI_Text( sprintf( "%d) %s", fIndex + 1, sRadioChat[ fMessage ] ), vPos, '8 8', FONT_DEFAULT );
	
	if ( fInputKeyCode == ( fIndex + 49 ) ) {
		sendevent( "RadioMessage", "f", fMessage );
		fVGUI_Display = VGUI_NONE;
	}
}

/*
====================
VGUI_Radio_Draw

Main drawing routine for the radio menus
====================
*/
void VGUI_Radio_Draw( void ) {
	vector vSize, vPos;
	
	if ( fVGUI_Display == VGUI_RADIO1 ) {
		vSize_x = 312;
		vSize_y = ( 10 * VGUIRADIO_COMMANDS ) + 64;
		vPos = [ 16, vVideoResolution_y - 148 - vSize_y ];
		
		VGUI_WindowSmall( _("RADIO_TITLE1"), vPos, vSize );
		
		vPos_y += 24;
		vPos_x += 8;
		for ( float i = 0; i < VGUIRADIO_COMMANDS; i++ ) {
			vPos_y += 10;
			VGUI_Radio_DrawCommand( i, fRadioCommands[ i ], vPos );
		}
	} else if ( fVGUI_Display == VGUI_RADIO2 ) {
		vSize_x = 312;
		vSize_y = ( 10 * VGUIRADIO_GROUPCOMMANDS ) + 64;
		vPos = [ 16, vVideoResolution_y - 148 - vSize_y ];
		
		VGUI_WindowSmall( _("RADIO_TITLE2"), vPos, vSize );
		
		vPos_y += 24;
		vPos_x += 8;
		for ( float i = 0; i < VGUIRADIO_GROUPCOMMANDS; i++ ) {
			vPos_y += 10;
			VGUI_Radio_DrawCommand( i, fRadioGroupCommands[ i ], vPos );
		}
	} else {
		vSize_x = 312;
		vSize_y = ( 10 * VGUIRADIO_RESPONSES ) + 64;
		vPos = [ 16, vVideoResolution_y - 148 - vSize_y ];
		
		VGUI_WindowSmall( _("RADIO_TITLE3"), vPos, vSize );
		
		vPos_y += 24;
		vPos_x += 8;
		for ( float i = 0; i < VGUIRADIO_RESPONSES; i++ ) {
			vPos_y += 10;
			VGUI_Radio_DrawCommand( i, fRadioResponses[ i ], vPos );
		}
	}
	
	vPos_y += 20;
	VGUI_Text( sprintf( "0) %s", _("VGUI_BACK") ), vPos, '8 8', FONT_DEFAULT );
	
	if ( fInputKeyCode == 48 ) {
		fVGUI_Display = VGUI_NONE;
	}
}

/*
====================
VGUI_Radio_Toggle
====================
*/
void VGUI_Radio_Toggle( float fMenu ) {
	if ( getstatf( STAT_HEALTH ) <= 0 ) {
		return;
	}
	
	if ( fVGUI_Display == fMenu ) {
		fVGUI_Display = VGUI_NONE;
	} else {
		fVGUI_Display = fMenu;
	}
}
