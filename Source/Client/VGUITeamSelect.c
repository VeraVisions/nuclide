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

string sClassInfo[40] = {
	"Phoenix Connexion", "gfx/vgui/640_terror",
	"The Phoenix Faction was formed shortly after the breakup of the USSR.",
	"Having established a reputation for killing anyone that gets in their way,",
	"the Phoenix Faction is one of the most feared terrorist groups in Eastern Europe.",
	
	"L337 Krew", "gfx/vgui/640_leet",
	"Middle Eastern fundamentalist group bent on world domination and various other evil deeds",
	"",
	"",
	
	"Arctic Avengers", "gfx/vgui/640_arctic",
	"Swedish terrorist faction founded in 1977.",
	"Famous for their bombing of the Canadian embassy in 1990.",
	"",
	
	"Guerilla Warfare", "gfx/vgui/640_guerilla",
	"A terrorist faction founded in the Middle East, Guerilla Warfare,",
	"has a reputation for ruthlessness. Their disgust for the American lifestyle was",
	"demonstrated in their 1982 bombing of a school bus full of Rock and Roll musicians.",
	
	"Seal Team 6", "gfx/vgui/640_urban",
	"Seal Team 6 (to be known later as DEVGRU) was founded in 1980 under the command of ",
	"Lieutenant-Commander Richard Marcincko. ST-6 was placed on permanent alert to ",
	"respond to terrorist attacks against American targets worldwide.",
	
	"German GSG9", "gfx/vgui/640_gsg9",
	"GSG-9 was born out of the tragic events that led to the death of several",
	"Israeli athletes during the 1972 Olympic games in Munich, Germany.",
	"",
	
	"UK SAS", "gfx/vgui/640_sas",
	"The world-renowned British SAS was founded in the Second World War",
	"by a man named David Stirling. Their role during WW2 involved gathering intelligence",
	"behind enemy lines and executing sabotage strikes and assassinations against key targets.",
	
	"French GIGN", "gfx/vgui/640_gign",
	"France's elite Counter-Terrorist unit, the GIGN, was designed to be a fast response force ",
	"that could decisively react to any large-scale terrorist incident. Consisting of no more",
	"than 100 men, the GIGN has earned its reputation through a history of successful ops."
};

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
	static void TeamSelect_Main_Exit( void ) {
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
	
	VGUI_Button( "Exit", TeamSelect_Main_Exit, vPos + '16 440 0', '120 24 0' );
}

void VGUI_TeamSelect_Back( void ) {
	fVGUI_Display = VGUI_TEAMSELECT;
}

void VGUI_TeamSelect_Button( float fNumber, void() vFunc, vector vPos, vector vSize ) {
	if( VGUI_Button( sClassInfo[ 5 * fNumber ] , vFunc, vPos, vSize ) == TRUE ) {
		drawpic( vVGUIWindowPos + '355 116', sClassInfo[ 5 * fNumber + 1 ], '128 256', '1 1 1', 1 );
		
		VGUI_Text( sClassInfo[ 5 * fNumber + 2 ], vVGUIWindowPos + '16 372', '6 8 0' );
		VGUI_Text( sClassInfo[ 5 * fNumber + 3 ], vVGUIWindowPos + '16 390', '6 8 0' );
		VGUI_Text( sClassInfo[ 5 * fNumber + 4 ], vVGUIWindowPos + '16 406', '6 8 0' );
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
	
	VGUI_TeamSelect_Button( 0, TeamSelect_T1, vPos + '16 116 0', '180 24 0' );
	VGUI_TeamSelect_Button( 1, TeamSelect_T2, vPos + '16 148 0', '180 24 0' );
	VGUI_TeamSelect_Button( 2, TeamSelect_T3, vPos + '16 180 0', '180 24 0' );
	VGUI_TeamSelect_Button( 3, TeamSelect_T4, vPos + '16 212 0', '180 24 0' );
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

	VGUI_TeamSelect_Button( 4, TeamSelect_CT1, vPos + '16 116 0', '180 24 0' );
	VGUI_TeamSelect_Button( 5, TeamSelect_CT2, vPos + '16 148 0', '180 24 0' );
	VGUI_TeamSelect_Button( 6, TeamSelect_CT3, vPos + '16 180 0', '180 24 0' );
	VGUI_TeamSelect_Button( 7, TeamSelect_CT4, vPos + '16 212 0', '180 24 0' );
	VGUI_Button( "Back", VGUI_TeamSelect_Back, vPos + '16 440 0', '120 24 0' );
}
