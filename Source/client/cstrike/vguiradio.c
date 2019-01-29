/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

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
	VGUI_Text( sprintf( "%d) %s", fIndex + 1, sRadioChat[ fMessage ] ), vPos, '12 12', FONT_CON );
	
	if ( pSeat->fInputKeyCode == ( fIndex + 49 ) ) {
		sendevent( "RadioMessage", "f", fMessage );
		pSeat->fVGUI_Display = VGUI_NONE;
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
	
	if ( pSeat->fVGUI_Display == VGUI_RADIO1 ) {
		vSize_x = 312;
		vSize_y = ( 10 * VGUIRADIO_COMMANDS ) + 64;
		vPos = video_mins + [ 16, video_res_y - 148 - vSize_y ];
		
		VGUI_WindowSmall( _("RADIO_TITLE1"), vPos, vSize );
		
		vPos_y += 24;
		vPos_x += 8;
		for ( float i = 0; i < VGUIRADIO_COMMANDS; i++ ) {
			vPos_y += 10;
			VGUI_Radio_DrawCommand( i, fRadioCommands[ i ], vPos );
		}
	} else if ( pSeat->fVGUI_Display == VGUI_RADIO2 ) {
		vSize_x = 312;
		vSize_y = ( 10 * VGUIRADIO_GROUPCOMMANDS ) + 64;
		vPos = video_mins + [ 16, video_res_y - 148 - vSize_y ];
		
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
		vPos = video_mins + [ 16, video_res_y - 148 - vSize_y ];
		
		VGUI_WindowSmall( _("RADIO_TITLE3"), vPos, vSize );
		
		vPos_y += 24;
		vPos_x += 8;
		for ( float i = 0; i < VGUIRADIO_RESPONSES; i++ ) {
			vPos_y += 10;
			VGUI_Radio_DrawCommand( i, fRadioResponses[ i ], vPos );
		}
	}
	
	vPos_y += 20;
	VGUI_Text( sprintf( "0) %s", _("VGUI_BACK") ), vPos, '12 12', FONT_CON );
	
	if ( pSeat->fInputKeyCode == 48 ) {
		pSeat->fVGUI_Display = VGUI_NONE;
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
	
	if ( pSeat->fVGUI_Display == fMenu ) {
		pSeat->fVGUI_Display = VGUI_NONE;
	} else {
		pSeat->fVGUI_Display = fMenu;
	}
}
