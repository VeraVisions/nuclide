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
	_("SCORE_TITLE_SPECTATOR"),
	_("SCORE_TITLE_T"),
	_("SCORE_TITLE_CT"),
	_("SCORE_TITLE_VIP"),
};

/*
====================
VGUI_Scores_DrawTeam
====================
*/
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
					CSQC_DrawText( vNewPos + '38 0', sprintf( _("SCORE_DEAD"), getplayerkeyvalue( i, "name" ) ), '8 8', vColor, 1.0f, 0, FONT_DEFAULT );
				} else if ( getplayerkeyvalue( i, "*dead" ) == "2" ) {
					CSQC_DrawText( vNewPos + '38 0', sprintf( _("SCORE_VIP"), getplayerkeyvalue( i, "name" ) ), '8 8', vColor, 1.0f, 0, FONT_DEFAULT );
				} else {
					CSQC_DrawText( vNewPos + '38 0', getplayerkeyvalue( i, "name" ), '8 8', vColor, 1.0f, 0, FONT_DEFAULT );
				}
				
				
				// Spectators don't have stats worth caring about
				if ( fTeam != TEAM_SPECTATOR ) {
					VGUI_RightText( vNewPos + '320 0', getplayerkeyvalue( i, INFOKEY_P_FRAGS ), '8 8', vColor, FONT_DEFAULT );
					VGUI_RightText( vNewPos + '384 0', getplayerkeyvalue( i, "*deaths" ), '8 8', vColor, FONT_DEFAULT  );
				}
				VGUI_RightText( vNewPos + '456 0', getplayerkeyvalue( i, INFOKEY_P_PING ), '8 8', vColor, FONT_DEFAULT );
					
				if ( getplayerkeyvalue( i, INFOKEY_P_VOIPSPEAKING ) == "0" ) {
					VGUI_RightText( vNewPos + '508 0', "N", '8 8', '1 1 1', FONT_DEFAULT );
				} else {
					VGUI_RightText( vNewPos + '508 0', "Y", '8 8', '1 1 1', FONT_DEFAULT );
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
		CSQC_DrawText( vPos + '24 0', sScoreTeams[ fTeam ], '16 16', vColor, 1.0f, 0, FONT_16 );
		drawfill( vPos + '19 24', '493 1', vColor, 1.0f );
		
		// Draw the amount of rounds we've von
		if ( fTeam == TEAM_CT ) {
			VGUI_RightText( vPos + '320 0', sprintf( "%i", getstati( STAT_WON_CT ) ), '16 16', vColor, FONT_16 );
		} else if ( fTeam == TEAM_T ) {
			VGUI_RightText( vPos + '320 0', sprintf( "%i", getstati( STAT_WON_T ) ), '16 16', vColor, FONT_16 );
		}
		
		// Now we know the playercount, so let's calculate the position next to the Teamname String and print it
		vector vCountPos = vPos + '24 6';
		vCountPos_x += stringwidth( sScoreTeams[ fTeam ], FALSE, '16 16' ) + 8;
		CSQC_DrawText( vCountPos, sprintf( _("SCORE_PLAYERS"), iPlayerCount ), '8 8', vColor, 1.0f, 0, FONT_DEFAULT );
	}
	return vNewPos + '0 24';
}

/*
====================
VGUI_Scores_Show
====================
*/
void VGUI_Scores_Show( void ) {
	vector vMainPos;
	vector vSize;
	
	vSize_x = 540;
	vSize_y = vVideoResolution_y - 112;
	
	vMainPos = vVideoMins;
	vMainPos_x += ( vVideoResolution_x / 2 ) - (vSize_x / 2);
	vMainPos_y += 56;
		
	// Draw the background
	drawfill( vMainPos, vSize, VGUI_WINDOW_BGCOLOR, VGUI_WINDOW_BGALPHA );
	
	// Sides
	drawfill( vMainPos, [vSize_x, 1], '0.35 0.35 0.35', 1.0f );
	drawfill( [vMainPos_x, vMainPos_y + vSize_y - 1], [vSize_x, 1], '0.35 0.35 0.35', 1.0f );
	drawfill( vMainPos, [1, vSize_y], '0.35 0.35 0.35', 1.0f );
	drawfill( [vMainPos_x + vSize_x - 1, vMainPos_y], [1, vSize_y], '0.35 0.35 0.35', 1.0f );
	
	// Server title
	CSQC_DrawText( vMainPos + '24 13', serverkey( "hostname" ), '16 16', VGUI_WINDOW_FGCOLOR, 1.0f, 0, FONT_16 );
	
	// Tabs like Score, Ping etc.
	CSQC_DrawText( vMainPos + '280 32', _("SCORE_SCORE"), '8 8', VGUI_WINDOW_FGCOLOR, 1.0f, 0, FONT_DEFAULT );
	CSQC_DrawText( vMainPos + '336 32', _("SCORE_DEATHS"), '8 8', VGUI_WINDOW_FGCOLOR, 1.0f, 0, FONT_DEFAULT );
	CSQC_DrawText( vMainPos + '400 32', _("SCORE_LATENCY"), '8 8', VGUI_WINDOW_FGCOLOR, 1.0f, 0, FONT_DEFAULT );
	CSQC_DrawText( vMainPos + '472 32', _("SCORE_VOICE"), '8 8', VGUI_WINDOW_FGCOLOR, 1.0f, 0, FONT_DEFAULT );

	vector vOffset = VGUI_Scores_DrawTeam( vMainPos + '0 50', TEAM_CT );
	vOffset = VGUI_Scores_DrawTeam( vOffset, TEAM_T );
	vOffset = VGUI_Scores_DrawTeam( vOffset, 0 );
}
