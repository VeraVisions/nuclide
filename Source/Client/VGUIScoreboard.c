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

string sScoreTeams[4] = {
	_("Spectator"),
	_("Terrorists"),
	_("CT Forces"),
	_("VIP"),
};

// This is seperated from the other VGUI stuff so we can check scores while buying and whatnot
int iShowScores;

vector VGUI_Scores_DrawTeam( vector vPos, float fTeam ) {
	
	vector vColor;
	// Preserve the old vector so we can draw the amount of players per team later on
	vector vNewPos = vPos;
	
	int iPlayerCount = 0;
	
	vNewPos += '0 32';
	
	// Player loop, this one goes through ALL players but only prints the one from fTeam
	for ( int i = -1; i > -32; i-- ) {
		if ( stof( getplayerkeyvalue( i, "*team" ) ) ==  fTeam ) {
			if ( getplayerkeyvalue( i, "name" ) ) {
				vColor = HUD_GetChatColor( fTeam );
				
				if ( getplayerkeyvalue( i, "name" ) == getplayerkeyvalue( player_localnum, "name" ) ) {
					drawfill( vNewPos + '19 -2', '493 14', vColor, VGUI_WINDOW_BGALPHA, DRAWFLAG_ADDITIVE );
					vColor = '1 1 1';
				}
				
				if ( getplayerkeyvalue( i, "*dead" ) == "1" ) {
					drawstring( vNewPos + '38 0', sprintf( _("%s [DEAD]"), getplayerkeyvalue( i, "name" ) ), '8 8 0', vColor, 1, 0 );
				} else if ( getplayerkeyvalue( i, "*dead" ) == "2" ) {
					drawstring( vNewPos + '38 0', sprintf( _("%s [VIP]"), getplayerkeyvalue( i, "name" ) ), '8 8 0', vColor, 1, 0 );
				} else {
					drawstring( vNewPos + '38 0', getplayerkeyvalue( i, "name" ), '8 8 0', vColor, 1, 0 );
				}
				
				
				// Spectators don't have stats worth caring about
				if ( fTeam != TEAM_SPECTATOR ) {
					VGUI_RightText( vNewPos + '320 0', getplayerkeyvalue( i, INFOKEY_P_FRAGS ), '8 8 0', vColor );
					VGUI_RightText( vNewPos + '384 0', getplayerkeyvalue( i, "*deaths" ), '8 8 0', vColor  );
				}
				VGUI_RightText( vNewPos + '456 0', getplayerkeyvalue( i, INFOKEY_P_PING ), '8 8 0', vColor );
					
				if ( getplayerkeyvalue( i, INFOKEY_P_VOIPSPEAKING ) == "0" ) {
					VGUI_RightText( vNewPos + '508 0', "N", '8 8 0', '1 1 1' );
				} else {
					VGUI_RightText( vNewPos + '508 0', "Y", '8 8 0', '1 1 1' );
				}
				
				vNewPos += '0 14';
				iPlayerCount++;
			}
		}
	}
	
	// Reset in case it was changed
	vColor = HUD_GetChatColor( fTeam );
	
	// If we've got no spectators, don't draw them.
	if ( ( fTeam != TEAM_SPECTATOR ) || ( fTeam == TEAM_SPECTATOR && iPlayerCount > 0 ) ) {
		// The name/title of the team
		drawstring( vPos + '24 0', sScoreTeams[ fTeam ], '16 16 0', vColor, 1, 0 );
		drawline( 1.0, vPos + '19 24', vPos + '512 24 0', vColor, 1, 0 );
		
		// Draw the amount of rounds we've von
		if ( fTeam == TEAM_CT ) {
			VGUI_RightText( vPos + '320 0', sprintf( "%i", getstati( STAT_WON_CT ) ), '16 16 0', vColor );
		} else if ( fTeam == TEAM_T ) {
			VGUI_RightText( vPos + '320 0', sprintf( "%i", getstati( STAT_WON_T ) ), '16 16 0', vColor );
		}
		
		// Now we know the playercount, so let's calculate the position next to the Teamname String and print it
		vector vCountPos = vPos + '24 6';
		vCountPos_x += stringwidth( sScoreTeams[ fTeam ], FALSE, '16 16 0' ) + 8;
		drawstring( vCountPos, sprintf( _("(%i players)"), iPlayerCount ), '8 8 0', vColor, 1, 0 );
	}
	return vNewPos + '0 24';
}

void VGUI_Scores_Show( void ) {
	vector vMainPos;
	vector v1, v2, v3;
	vector vSize;
	
	vSize_x = 540;
	vSize_y = vVideoResolution_y - 112;
	
	vMainPos_x = ( vVideoResolution_x / 2 ) - (vSize_x / 2);
	vMainPos_y = 56;
		
	// Draw the background
	drawfill( vMainPos, vSize, VGUI_WINDOW_BGCOLOR, VGUI_WINDOW_BGALPHA );
	
	// Draw the outline START
	v1_x = vMainPos_x + vSize_x;
	v1_y = vMainPos_y + 1;
	drawline( 1.0, vMainPos, v1, '0.35 0.35 0.35', 1, DRAWFLAG_NORMAL );
	
	v2_x = vMainPos_x;
	v2_y = vMainPos_y + vSize_y;
	drawline( 1.0, vMainPos, v2, '0.35 0.35 0.35', 1, DRAWFLAG_NORMAL );

	v3 = vMainPos + vSize;
	drawline( 1.0, v1 - '1 0', v3 - '1 0', '0.35 0.35 0.35', 1, DRAWFLAG_NORMAL );
	drawline( 1.0, v2, v3, '0.35 0.35 0.35', 1, DRAWFLAG_NORMAL );
	// Draw the outline END
	
	// Server title
	drawstring( vMainPos + '24 13', serverkey( "hostname" ), '16 16 0', VGUI_WINDOW_FGCOLOR, 1, 0 );
	
	// Tabs like Score, Ping etc.
	drawstring( vMainPos + '280 32', _("SCORE  DEATHS  LATENCY  VOICE"), '8 8 0', VGUI_WINDOW_FGCOLOR, 1, 0 );

	vector vOffset = VGUI_Scores_DrawTeam( vMainPos + '0 50', TEAM_CT );
	vOffset = VGUI_Scores_DrawTeam( vOffset, TEAM_T );
	vOffset = VGUI_Scores_DrawTeam( vOffset, 0 );
}
