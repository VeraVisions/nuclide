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

// TODO: expose these to the clients?
#define ORBITUARY_LINES 4
#define ORBITUARY_TIME 4
int iOrbituaryScroll;
float fOrbituaryTime;

typedef struct {
	string sSprite;
	vector vOrigin;
	vector vSize;
} weaponiconinfo_t;

// It's easier to just look up the info than to create it on the fly...
weaponiconinfo_t wpIconTable[ CS_WEAPON_COUNT ] = {
	{ "", '0 0', '0 0' }, //WEAPON_NONE
	{ "sprites/640hud1.spr_0.tga", '0.75 0', '0.1875 0.0625' }, //WEAPON_KNIFE
	{ "sprites/640hud1.spr_0.tga", '0.75 0.125', '0.125 0.0625' }, //WEAPON_USP45
	{ "sprites/640hud1.spr_0.tga", '0.75 0.0625', '0.125 0.0625' }, //WEAPON_GLOCK18
	{ "sprites/640hud1.spr_0.tga", '0.875 0.0625', '0.125 0.0625' }, //WEAPON_DEAGLE
	{ "sprites/640hud1.spr_0.tga", '0.875 0.125', '0.125 0.0625' }, //WEAPON_P228
	{ "sprites/640hud1.spr_0.tga", '0.203125 0.9375', '0.21875 0.0625' }, //WEAPON_ELITES
	{ "sprites/640hud16.spr_0.tga", '0.75 0', '0.125 0.0625' }, //WEAPON_FIVESEVEN
	{ "sprites/640hud1.spr_0.tga", '0.75 0.1875', '0.1875 0.0625' }, //WEAPON_M3
	{ "sprites/640hud1.spr_0.tga", '0.75 0.875', '0.1875 0.0625' }, //WEAPON_XM1014
	{ "sprites/640hud1.spr_0.tga", '0.75 0.25', '0.125 0.0625' }, //WEAPON_MP5
	{ "sprites/640hud1.spr_0.tga", '0.75 0.6875', '0.1875 0.0625' }, //WEAPON_P90
	{ "sprites/640hud16.spr_0.tga", '0.78125 0.3125', '0.125 0.0625' }, //WEAPON_UMP45
	{ "sprites/640hud1.spr_0.tga", '0.421875 0.9375', '0.125 0.0625' }, //WEAPON_MAC10
	{ "sprites/640hud1.spr_0.tga", '0.875 0.25', '0.125 0.0625' }, //WEAPON_TMP
	{ "sprites/640hud1.spr_0.tga", '0.75 0.3125', '0.1875 0.0625' }, //WEAPON_AK47
	{ "sprites/640hud1.spr_0.tga", '0.75 0.4375', '0.1875 0.0625' }, //WEAPON_SG552
	{ "sprites/640hud1.spr_0.tga", '0.75 0.375', '0.1875 0.0625' }, //WEAPON_M4A1
	{ "sprites/640hud1.spr_0.tga", '0.5625 0.9375', '-0.1875 0.0625' }, //WEAPON_AUG
	{ "sprites/640hud1.spr_0.tga", '0.75 0.8125', '0.1875 0.0625' }, //WEAPON_SCOUT
	{ "sprites/640hud1.spr_0.tga", '0.75 0.5', '0.1875 0.0625' }, //WEAPON_AWP
	{ "sprites/640hud1.spr_0.tga", '0.75 0.5625', '0.1875 0.0625' }, //WEAPON_G3SG1
	{ "sprites/640hud16.spr_0.tga", '0.75 0.1875', '0.125 0.0625' }, //WEAPON_SG550
	{ "sprites/640hud1.spr_0.tga", '0.75 0.625', '0.1875 0.0625' }, //WEAPON_PARA
	{ "", '0 0', '-1 0.0625' } //WEAPON_C4BOMB
};

typedef struct {
	string sAttacker;
	vector vColor1;
	string sVictim;
	vector vColor2;
	float fWeapon;
	float fHeadShot;
	float fOffset1;
	float fOffset2;
	float fOffset3;
} orbituaryinfo_t;

orbituaryinfo_t orbBuffer[ ORBITUARY_LINES ];

/*
=================
HUD_DrawOrbituaries

This actually displays the contents of orbBuffer
=================
*/
void HUD_DrawOrbituaries( void ) {
	vector vOrbPos = [ vVideoResolution_x - 200, 56 ];
	
	if ( fOrbituaryTime < time && iOrbituaryScroll >= 0 ) {
		// We are cheap, just clear the attacker and we're good.
		orbBuffer[ iOrbituaryScroll ].sAttacker = "";
		iOrbituaryScroll--;
		fOrbituaryTime = time + ORBITUARY_TIME;
	}
	
	for ( int i = 0; i < ORBITUARY_LINES; i++ ) {
		if ( orbBuffer[ i ].sAttacker == "" ) {
			return;
		}
		
		// Calculate the position based on the saved offsets
		vOrbPos_x = vVideoResolution_x - ( orbBuffer[ i ].fOffset1 + orbBuffer[ i ].fOffset2 + orbBuffer[ i ].fOffset3 ) - 16;
		
		// Draw the attacker's name, shadow first
		drawstring( vOrbPos + '1 1', orbBuffer[ i ].sAttacker, '8 8 0', '0 0 0', VGUI_WINDOW_FGALPHA, 0 );
		drawstring( vOrbPos, orbBuffer[ i ].sAttacker, '8 8 0', orbBuffer[ i ].vColor1, VGUI_WINDOW_FGALPHA, 0 );
		
		// Draw the weapon icon
		drawsubpic( vOrbPos + [ orbBuffer[ i ].fOffset1, 0 ], wpIconTable[ orbBuffer[ i ].fWeapon ].vSize * 256, wpIconTable[ orbBuffer[ i ].fWeapon ].sSprite, wpIconTable[ orbBuffer[ i ].fWeapon ].vOrigin, wpIconTable[ orbBuffer[ i ].fWeapon ].vSize, '1 0.5 0', 1, DRAWFLAG_ADDITIVE );
		
		// Draw the victim's name, shadow first again
		drawstring( vOrbPos + [ orbBuffer[ i ].fOffset2 + orbBuffer[ i ].fOffset1, 0 ] + '1 1', orbBuffer[ i ].sVictim, '8 8 0', '0 0', VGUI_WINDOW_FGALPHA, 0 );
		drawstring( vOrbPos + [ orbBuffer[ i ].fOffset2 + orbBuffer[ i ].fOffset1, 0 ], orbBuffer[ i ].sVictim, '8 8 0', orbBuffer[ i ].vColor2, VGUI_WINDOW_FGALPHA, 0 );
		vOrbPos_y += 18;
	}
}

/*
=================
HUD_UpdateOrbituaries

Update the buffer for orbituaries with infos and whatnot
=================
*/
void HUD_AddOrbituaries( float fAttacker, float fAttackerTeam, float fVictim, float fVictimTeam, float fWeapon, float fHeadshot ) {

	if ( iOrbituaryScroll < ( ORBITUARY_LINES - 1 ) ) {
		// Fill up the buffer
		orbBuffer[ iOrbituaryScroll + 1 ].sAttacker = getplayerkeyvalue( fAttacker, "name" );
		orbBuffer[ iOrbituaryScroll + 1 ].vColor1 = HUD_GetChatColor( fAttackerTeam );
		orbBuffer[ iOrbituaryScroll + 1 ].sVictim = getplayerkeyvalue( fVictim, "name" );
		orbBuffer[ iOrbituaryScroll + 1 ].vColor2 = HUD_GetChatColor( fVictimTeam );
		orbBuffer[ iOrbituaryScroll + 1 ].fWeapon = fWeapon;
		orbBuffer[ iOrbituaryScroll + 1 ].fHeadShot = fHeadshot;
											
		orbBuffer[ iOrbituaryScroll + 1 ].fOffset1 = stringwidth( orbBuffer[ iOrbituaryScroll + 1 ].sAttacker, TRUE ) + 8;
		orbBuffer[ iOrbituaryScroll + 1 ].fOffset2 = ( wpIconTable[ fWeapon ].vSize[0] * 256 ) + 8;
		orbBuffer[ iOrbituaryScroll + 1 ].fOffset3 = stringwidth( orbBuffer[ iOrbituaryScroll + 1 ].sVictim, TRUE ) + 8;
		iOrbituaryScroll++;
	} else {
		for ( int i = 0; i < ( ORBITUARY_LINES - 1 ); i++ ) {
			// Rearrange the order, clear the oldest
			orbBuffer[ i ].sAttacker = orbBuffer[ i + 1 ].sAttacker;
			orbBuffer[ i ].vColor1 = orbBuffer[ i + 1 ].vColor1;
			orbBuffer[ i ].sVictim = orbBuffer[ i + 1 ].sVictim;
			orbBuffer[ i ].vColor2 = orbBuffer[ i + 1 ].vColor2;
			orbBuffer[ i ].fWeapon = orbBuffer[ i + 1 ].fWeapon;
			orbBuffer[ i ].fHeadShot = orbBuffer[ i + 1 ].fHeadShot;
			orbBuffer[ i ].fOffset1 = orbBuffer[ i + 1 ].fOffset1;
			orbBuffer[ i ].fOffset2 = orbBuffer[ i + 1 ].fOffset2;
			orbBuffer[ i ].fOffset3 = orbBuffer[ i + 1 ].fOffset3;
		}
		// After rearranging, add the newest to the bottom.
		orbBuffer[ ORBITUARY_LINES - 1 ].sAttacker = getplayerkeyvalue( fAttacker, "name" );
		orbBuffer[ ORBITUARY_LINES - 1 ].vColor1 = HUD_GetChatColor( fAttackerTeam );
		orbBuffer[ ORBITUARY_LINES - 1 ].sVictim = getplayerkeyvalue( fVictim, "name" );
		orbBuffer[ ORBITUARY_LINES - 1 ].vColor2 = HUD_GetChatColor( fVictimTeam );
		orbBuffer[ ORBITUARY_LINES - 1 ].fWeapon = fWeapon;
		orbBuffer[ ORBITUARY_LINES - 1 ].fHeadShot = fHeadshot;
		orbBuffer[ ORBITUARY_LINES - 1 ].fOffset1 = stringwidth( orbBuffer[ ORBITUARY_LINES - 1 ].sAttacker, TRUE ) + 8;
		orbBuffer[ ORBITUARY_LINES - 1 ].fOffset2 = ( wpIconTable[ fWeapon ].vSize[0] * 256 ) + 8;
		orbBuffer[ ORBITUARY_LINES - 1 ].fOffset3 =  stringwidth( orbBuffer[ ORBITUARY_LINES - 1 ].sVictim, TRUE ) + 8;
	}
		
	fOrbituaryTime = time + ORBITUARY_TIME;
}
