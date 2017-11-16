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

string sClassInfo[64] = {
	_("VGUI_T1_TITLE"), "gfx/vgui/640_terror",
	_("VGUI_T1_TXT1"),
	_("VGUI_T1_TXT2"),
	_("VGUI_T1_TXT3"),
	_("VGUI_T1_TXT4"),
	_("VGUI_T1_TXT5"),
	_("VGUI_T1_TXT6"),
	
	_("VGUI_T2_TITLE"), "gfx/vgui/640_leet",
	_("VGUI_T2_TXT1"),
	_("VGUI_T2_TXT2"),
	_("VGUI_T2_TXT3"),
	_("VGUI_T2_TXT4"),
	_("VGUI_T2_TXT5"),
	_("VGUI_T2_TXT6"),
	
	_("VGUI_T3_TITLE"), "gfx/vgui/640_arctic",
	_("VGUI_T3_TXT1"),
	_("VGUI_T3_TXT2"),
	_("VGUI_T3_TXT3"),
	_("VGUI_T3_TXT4"),
	_("VGUI_T3_TXT5"),
	_("VGUI_T3_TXT6"),
	
	_("VGUI_T4_TITLE"), "gfx/vgui/640_guerilla",
	_("VGUI_T4_TXT1"),
	_("VGUI_T4_TXT2"),
	_("VGUI_T4_TXT3"),
	_("VGUI_T4_TXT4"),
	_("VGUI_T4_TXT5"),
	_("VGUI_T4_TXT6"),
	
	_("VGUI_CT1_TITLE"), "gfx/vgui/640_urban",
	_("VGUI_CT1_TXT1"),
	_("VGUI_CT1_TXT2"),
	_("VGUI_CT1_TXT3"),
	_("VGUI_CT1_TXT4"),
	_("VGUI_CT1_TXT5"),
	_("VGUI_CT1_TXT6"),
	
	_("VGUI_CT2_TITLE"), "gfx/vgui/640_gsg9",
	_("VGUI_CT2_TXT1"),
	_("VGUI_CT2_TXT2"),
	_("VGUI_CT2_TXT3"),
	_("VGUI_CT2_TXT4"),
	_("VGUI_CT2_TXT5"),
	_("VGUI_CT2_TXT6"),
	
	_("VGUI_CT3_TITLE"), "gfx/vgui/640_sas",
	_("VGUI_CT3_TXT1"),
	_("VGUI_CT3_TXT2"),
	_("VGUI_CT3_TXT3"),
	_("VGUI_CT3_TXT4"),
	_("VGUI_CT3_TXT5"),
	_("VGUI_CT3_TXT6"),
	
	_("VGUI_CT4_TITLE"), "gfx/vgui/640_gign",
	_("VGUI_CT4_TXT1"),
	_("VGUI_CT4_TXT2"),
	_("VGUI_CT4_TXT3"),
	_("VGUI_CT4_TXT4"),
	_("VGUI_CT4_TXT5"),
	_("VGUI_CT4_TXT6")
};

/*
====================
VGUI_TeamSelect_Main
====================
*/
void VGUI_TeamSelect_Main( vector vPos ) {
	static void TeamSelect_Main_ButtonT( void ) {
		pSeat->fVGUI_Display = VGUI_TEAM_T;
	}
	static void TeamSelect_Main_ButtonCT( void ) {
		pSeat->fVGUI_Display = VGUI_TEAM_CT;
	}
	static void TeamSelect_Main_ButtonAuto( void ) {
		int iPlayersT = 0;
		int iPlayersCT = 0;
		
		for ( int i = 0; i < 32; i++ ) {
			if ( stof( getplayerkeyvalue( i, "*team" ) ) ==  TEAM_T ) {
				iPlayersT++;
			} else if ( stof( getplayerkeyvalue( i, "*team" ) ) ==  TEAM_CT ) {
				iPlayersCT++;
			}
		}
		
		if ( iPlayersCT > iPlayersT ) {
			pSeat->fVGUI_Display = VGUI_TEAM_T;
		} else {
			pSeat->fVGUI_Display = VGUI_TEAM_CT;
		}
	}
	static void TeamSelect_Main_ButtonSpectate( void ) {
		sendevent( "GamePlayerSpawn", "f", 0 );
		pSeat->fVGUI_Display = VGUI_NONE;
	}
	static void TeamSelect_Main_Exit( void ) {
		pSeat->fVGUI_Display = VGUI_NONE;
	}

	VGUI_Text( sMapString[ 0 ], vPos + '16 64 0', '16 16', FONT_16);
	
	vector vTextPos = vPos + '224 116 0';
	for ( int i = 1; i < 35; i++ ) {
		VGUI_Text( sMapString[ i ], vTextPos, '8 8', FONT_DEFAULT );
		vTextPos_y += 10;
	}

	VGUI_Button( _("VGUI_TEAM_T"), TeamSelect_Main_ButtonT, vPos + '16 116 0', '180 24 0' );
	VGUI_Button( _("VGUI_TEAM_CT"), TeamSelect_Main_ButtonCT, vPos + '16 148 0', '180 24 0' );

	VGUI_Button( _("VGUI_TEAM_AUTO"), TeamSelect_Main_ButtonAuto, vPos + '16 336 0', '180 24 0' );
	VGUI_Button( _("VGUI_TEAM_SPEC"), TeamSelect_Main_ButtonSpectate, vPos + '16 368 0', '180 24 0' );
	
	VGUI_Button( _("VGUI_EXIT"), TeamSelect_Main_Exit, vPos + '16 440 0', '120 24 0' );
}

/*
====================
VGUI_TeamSelect_Back
====================
*/
void VGUI_TeamSelect_Back( void ) {
	pSeat->fVGUI_Display = VGUI_TEAMSELECT;
}

/*
====================
VGUI_TeamSelect_Button
====================
*/
void VGUI_TeamSelect_Button( float fNumber, void() vFunc, vector vPos, vector vSize ) {
	if( VGUI_Button( sClassInfo[ 8 * fNumber ] , vFunc, vPos, vSize ) == TRUE ) {
		drawpic( vVGUIWindowPos + '356 64', sClassInfo[ 8 * fNumber + 1 ], '128 256', '1 1 1', 1 );
		
		VGUI_Text( sClassInfo[ 8 * fNumber + 2 ], vVGUIWindowPos + '232 336', '8 8', FONT_DEFAULT );
		VGUI_Text( sClassInfo[ 8 * fNumber + 3 ], vVGUIWindowPos + '232 346', '8 8', FONT_DEFAULT );
		VGUI_Text( sClassInfo[ 8 * fNumber + 4 ], vVGUIWindowPos + '232 356', '8 8', FONT_DEFAULT );
		VGUI_Text( sClassInfo[ 8 * fNumber + 5 ], vVGUIWindowPos + '232 366', '8 8', FONT_DEFAULT );
		VGUI_Text( sClassInfo[ 8 * fNumber + 6 ], vVGUIWindowPos + '232 376', '8 8', FONT_DEFAULT );
		VGUI_Text( sClassInfo[ 8 * fNumber + 7 ], vVGUIWindowPos + '232 386', '8 8', FONT_DEFAULT );
	}
}

/*
====================
VGUI_TeamSelect_T
====================
*/
void VGUI_TeamSelect_T( vector vPos ) {
	static void TeamSelect_T1( void ) {
		sendevent( "GamePlayerSpawn", "f", 1 );
		pSeat->fVGUI_Display = VGUI_NONE;
	}
	static void TeamSelect_T2( void ) {
		sendevent( "GamePlayerSpawn", "f", 2 );
		pSeat->fVGUI_Display = VGUI_NONE;
	}
	static void TeamSelect_T3( void ) {
		sendevent( "GamePlayerSpawn", "f", 3 );
		pSeat->fVGUI_Display = VGUI_NONE;
	}
	static void TeamSelect_T4( void ) {
		sendevent( "GamePlayerSpawn", "f", 4 );
		pSeat->fVGUI_Display = VGUI_NONE;
	}
	
	VGUI_TeamSelect_Button( 0, TeamSelect_T1, vPos + '16 160 0', '180 24 0' );
	VGUI_TeamSelect_Button( 1, TeamSelect_T2, vPos + '16 192 0', '180 24 0' );
	VGUI_TeamSelect_Button( 2, TeamSelect_T3, vPos + '16 224 0', '180 24 0' );
	VGUI_TeamSelect_Button( 3, TeamSelect_T4, vPos + '16 256 0', '180 24 0' );
	VGUI_Button( _("VGUI_BACK"), VGUI_TeamSelect_Back, vPos + '16 440 0', '120 24 0' );
}

/*
====================
VGUI_TeamSelect_CT
====================
*/
void VGUI_TeamSelect_CT ( vector vPos ) {
	static void TeamSelect_CT1( void ) {
		sendevent( "GamePlayerSpawn", "f", 5 );
		pSeat->fVGUI_Display = VGUI_NONE;
	}
	static void TeamSelect_CT2( void ) {
		sendevent( "GamePlayerSpawn", "f", 6 );
		pSeat->fVGUI_Display = VGUI_NONE;
	}
	static void TeamSelect_CT3( void ) {
		sendevent( "GamePlayerSpawn", "f", 7 );
		pSeat->fVGUI_Display = VGUI_NONE;
	}
	static void TeamSelect_CT4( void ) {
		sendevent( "GamePlayerSpawn", "f", 8 );
		pSeat->fVGUI_Display = VGUI_NONE;
	}

	VGUI_TeamSelect_Button( 4, TeamSelect_CT1, vPos + '16 160 0', '180 24 0' );
	VGUI_TeamSelect_Button( 5, TeamSelect_CT2, vPos + '16 192 0', '180 24 0' );
	VGUI_TeamSelect_Button( 6, TeamSelect_CT3, vPos + '16 224 0', '180 24 0' );
	VGUI_TeamSelect_Button( 7, TeamSelect_CT4, vPos + '16 256 0', '180 24 0' );
	VGUI_Button( _("VGUI_BACK"), VGUI_TeamSelect_Back, vPos + '16 440 0', '120 24 0' );
}
