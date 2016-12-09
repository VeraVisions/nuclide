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

void VGUI_TeamSelect_Main( vector vPos ) {
	static void TeamSelect_Main_ButtonT( void ) {
		fVGUI_Display = VGUI_TEAM_T;
	}
	static void TeamSelect_Main_ButtonCT( void ) {
		fVGUI_Display = VGUI_TEAM_CT;
	}
	static void TeamSelect_Main_ButtonAuto( void ) {
		fVGUI_Display = VGUI_NONE;
	}
	static void TeamSelect_Main_ButtonSpectate( void ) {
		sendevent( "GamePlayerSpawn", "f", 0 );
		fVGUI_Display = VGUI_NONE;
	}

	VGUI_Text( sMapString[ 0 ], vPos + '16 64 0', '16 16 0');
	
	vector vTextPos = vPos + '224 116 0';
	for ( int i = 1; i < 35; i++ ) {
		VGUI_Text( sMapString[ i ], vTextPos, '8 8 0' );
		vTextPos_y += 10;
	}

	VGUI_Button( "Terrorists", TeamSelect_Main_ButtonT, vPos + '16 116 0', '180 24 0' );
	VGUI_Button( "Counter-Terrorists", TeamSelect_Main_ButtonCT, vPos + '16 148 0', '180 24 0' );

	VGUI_Button( "Auto-Assign", TeamSelect_Main_ButtonAuto, vPos + '16 336 0', '180 24 0' );
	VGUI_Button( "Spectate", TeamSelect_Main_ButtonSpectate, vPos + '16 368 0', '180 24 0' );
}

void VGUI_TeamSelect_Back( void ) {
	fVGUI_Display = VGUI_TEAMSELECT;
}

void VGUI_TeamSelect_Button( string sLabel, string sImage, void() vFunc, vector vPos, vector vSize ) {
	
	if( VGUI_Button( sLabel, vFunc, vPos, vSize ) == TRUE ) {
		drawpic( vVGUIWindowPos + '355 174', sImage, '128 256', '1 1 1', 1 );
	}
}

void VGUI_TeamSelect_T( vector vPos ) {
	static void TeamSelect_T1( void ) {
		sendevent( "GamePlayerSpawn", "f", 1 );
		fVGUI_Display = VGUI_NONE;
	}
	static void TeamSelect_T2( void ) {
		sendevent( "GamePlayerSpawn", "f", 2 );
		fVGUI_Display = VGUI_NONE;
	}
	static void TeamSelect_T3( void ) {
		sendevent( "GamePlayerSpawn", "f", 3 );
		fVGUI_Display = VGUI_NONE;
	}
	static void TeamSelect_T4( void ) {
		sendevent( "GamePlayerSpawn", "f", 4 );
		fVGUI_Display = VGUI_NONE;
	}

	VGUI_Text( "Team Description", vPos + '16 64 0', '16 16 0');
	
	VGUI_Text( "This describes the object of your current team.", vPos + '16 116 0', '8 8 0' );
	VGUI_Text( "As a T, you will most likely watch the hostages or plant bombs.", vPos + '16 132 0', '8 8 0' );
	
	VGUI_TeamSelect_Button( "Phoenix Connexion", "gfx/vgui/640_terror", TeamSelect_T1, vPos + '16 240 0', '180 24 0' );
	VGUI_TeamSelect_Button( "L337 Krew", "gfx/vgui/640_leet", TeamSelect_T2, vPos + '16 272 0', '180 24 0' );
	VGUI_TeamSelect_Button( "Arctic Avengers", "gfx/vgui/640_arctic", TeamSelect_T3, vPos + '16 306 0', '180 24 0' );
	VGUI_TeamSelect_Button( "Guerilla Warfare", "gfx/vgui/640_guerilla", TeamSelect_T4, vPos + '16 336 0', '180 24 0' );
	VGUI_Button( "Back", VGUI_TeamSelect_Back, vPos + '16 440 0', '120 24 0' );
}

void VGUI_TeamSelect_CT ( vector vPos ) {
	static void TeamSelect_CT1( void ) {
		sendevent( "GamePlayerSpawn", "f", 5 );
		fVGUI_Display = VGUI_NONE;
	}
	static void TeamSelect_CT2( void ) {
		sendevent( "GamePlayerSpawn", "f", 6 );
		fVGUI_Display = VGUI_NONE;
	}
	static void TeamSelect_CT3( void ) {
		sendevent( "GamePlayerSpawn", "f", 7 );
		fVGUI_Display = VGUI_NONE;
	}
	static void TeamSelect_CT4( void ) {
		sendevent( "GamePlayerSpawn", "f", 8 );
		fVGUI_Display = VGUI_NONE;
	}

	VGUI_Text( "Team Description", vPos + '16 64 0', '16 16 0');
	
	VGUI_Text( "This describes the object of your current team.", vPos + '16 116 0', '8 8 0' );
	VGUI_Text( "As a CT, you will most likely rescue hostages or defuse bombs.", vPos + '16 132 0', '8 8 0' );
	
	VGUI_TeamSelect_Button( "Seal Team 6", "gfx/vgui/640_urban", TeamSelect_CT1, vPos + '16 240 0', '180 24 0' );
	VGUI_TeamSelect_Button( "German GSG9", "gfx/vgui/640_gsg9", TeamSelect_CT2, vPos + '16 272 0', '180 24 0' );
	VGUI_TeamSelect_Button( "UK SAS", "gfx/vgui/640_sas", TeamSelect_CT3, vPos + '16 306 0', '180 24 0' );
	VGUI_TeamSelect_Button( "French GIGN", "gfx/vgui/640_gign", TeamSelect_CT4, vPos + '16 336 0', '180 24 0' );
	VGUI_Button( "Back", VGUI_TeamSelect_Back, vPos + '16 440 0', '120 24 0' );
}
