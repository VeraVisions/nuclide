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
	_("Phoenix Connexion"), "gfx/vgui/640_terror",
	_("The Phoenix Faction was formed shortly"),
	_("after the breakup of the USSR. Having"),
	_("established a reputation for killing "),
	_("anyone that gets in their way, the"),
	_("the Phoenix Faction is one of the most"),
	_("feared terrorist groups in Eastern Europe."),
	
	_("L337 Krew"), "gfx/vgui/640_leet",
	_("Middle Eastern fundamentalist group bent"),
	_("on world domination and various other"),
	_("evil deeds"),
	_(""),
	_(""),
	_(""),
	
	_("Arctic Avengers"), "gfx/vgui/640_arctic",
	_("Swedish terrorist faction founded in 1977."),
	_("Famous for their bombing of the Canadian"),
	_("embassy in 1990."),
	_(""),
	_(""),
	_(""),
	
	_("Guerilla Warfare"), "gfx/vgui/640_guerilla",
	_("A terrorist faction founded in the"),
	_("Middle East, Guerilla Warfare, has a"),
	_("reputation for ruthlessness. Their disgust"),
	_("for the American lifestyle was demonstrated"),
	_("in their 1982 bombing of a school bus full"),
	_("of Rock and Roll musicians."),
	
	_("Seal Team 6"), "gfx/vgui/640_urban",
	_("Seal Team 6 (to be known later as DEVGRU)"),
	_("was founded in 1980 under the command of"),
	_("Lieutenant-Commander Richard Marcincko."),
	_("ST-6 was placed on permanent alert to"),
	_("respond to terrorist attacks against"),
	_("American targets worldwide."),
	
	_("German GSG9"), "gfx/vgui/640_gsg9",
	_("GSG-9 was born out of the tragic events"),
	_("that led to the death of several"),
	_("Israeli athletes during the 1972 Olympic"),
	_("games in Munich, Germany."),
	_(""),
	_(""),
	
	_("UK SAS"), "gfx/vgui/640_sas",
	_("The world-renowned British SAS was founded"),
	_("in the Second World War by a man named"),
	_("David Stirling. Their role during WW2"),
	_("involved gathering intelligence behind enemy"),
	_("lines and executing sabotage strikes and"),
	_("assassinations against key targets."),
	
	_("French GIGN"), "gfx/vgui/640_gign",
	_("France's elite Counter-Terrorist unit was"),
	_("designed to be a fast response force"),
	_("that could decisively react to any large-"),
	_("scale terrorist incident. Consisting of no"),
	_("more than 100 men, the GIGN has earned its"),
	_("reputation through a history of successful ops.")
};

void VGUI_TeamSelect_Main( vector vPos ) {
	static void TeamSelect_Main_ButtonT( void ) {
		fVGUI_Display = VGUI_TEAM_T;
	}
	static void TeamSelect_Main_ButtonCT( void ) {
		fVGUI_Display = VGUI_TEAM_CT;
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
			fVGUI_Display = VGUI_TEAM_T;
		} else {
			fVGUI_Display = VGUI_TEAM_CT;
		}
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

	VGUI_Button( _("Terrorists"), TeamSelect_Main_ButtonT, vPos + '16 116 0', '180 24 0' );
	VGUI_Button( _("Counter-Terrorists"), TeamSelect_Main_ButtonCT, vPos + '16 148 0', '180 24 0' );

	VGUI_Button( _("Auto-Assign"), TeamSelect_Main_ButtonAuto, vPos + '16 336 0', '180 24 0' );
	VGUI_Button( _("Spectate"), TeamSelect_Main_ButtonSpectate, vPos + '16 368 0', '180 24 0' );
	
	VGUI_Button( _("Exit"), TeamSelect_Main_Exit, vPos + '16 440 0', '120 24 0' );
}

void VGUI_TeamSelect_Back( void ) {
	fVGUI_Display = VGUI_TEAMSELECT;
}

void VGUI_TeamSelect_Button( float fNumber, void() vFunc, vector vPos, vector vSize ) {
	if( VGUI_Button( sClassInfo[ 8 * fNumber ] , vFunc, vPos, vSize ) == TRUE ) {
		drawpic( vVGUIWindowPos + '356 64', sClassInfo[ 8 * fNumber + 1 ], '128 256', '1 1 1', 1 );
		
		VGUI_Text( sClassInfo[ 8 * fNumber + 2 ], vVGUIWindowPos + '232 336', '8 8 0' );
		VGUI_Text( sClassInfo[ 8 * fNumber + 3 ], vVGUIWindowPos + '232 346', '8 8 0' );
		VGUI_Text( sClassInfo[ 8 * fNumber + 4 ], vVGUIWindowPos + '232 356', '8 8 0' );
		VGUI_Text( sClassInfo[ 8 * fNumber + 5 ], vVGUIWindowPos + '232 366', '8 8 0' );
		VGUI_Text( sClassInfo[ 8 * fNumber + 6 ], vVGUIWindowPos + '232 376', '8 8 0' );
		VGUI_Text( sClassInfo[ 8 * fNumber + 7 ], vVGUIWindowPos + '232 386', '8 8 0' );
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
	
	VGUI_TeamSelect_Button( 0, TeamSelect_T1, vPos + '16 160 0', '180 24 0' );
	VGUI_TeamSelect_Button( 1, TeamSelect_T2, vPos + '16 192 0', '180 24 0' );
	VGUI_TeamSelect_Button( 2, TeamSelect_T3, vPos + '16 224 0', '180 24 0' );
	VGUI_TeamSelect_Button( 3, TeamSelect_T4, vPos + '16 256 0', '180 24 0' );
	VGUI_Button( _("Back"), VGUI_TeamSelect_Back, vPos + '16 440 0', '120 24 0' );
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

	VGUI_TeamSelect_Button( 4, TeamSelect_CT1, vPos + '16 160 0', '180 24 0' );
	VGUI_TeamSelect_Button( 5, TeamSelect_CT2, vPos + '16 192 0', '180 24 0' );
	VGUI_TeamSelect_Button( 6, TeamSelect_CT3, vPos + '16 224 0', '180 24 0' );
	VGUI_TeamSelect_Button( 7, TeamSelect_CT4, vPos + '16 256 0', '180 24 0' );
	VGUI_Button( _("Back"), VGUI_TeamSelect_Back, vPos + '16 440 0', '120 24 0' );
}
