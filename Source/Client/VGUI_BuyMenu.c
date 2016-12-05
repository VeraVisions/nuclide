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

vguiweapon_t vguiWeaponTable[ CS_WEAPON_COUNT ] = {
	{ "None", "" },
	{ "Knife", "" },
	{ "H&K USP .45 Tactical", "gfx/vgui/640_usp" },
	{ "Glock18 Select Fire", "gfx/vgui/640_glock18" },
	{ "Desert Eagle .50AE", "gfx/vgui/640_deagle" },
	{ "SIG P228", "gfx/vgui/640_p228" },
	{ "Dual Beretta 96G Elite", "gfx/vgui/640_elite" },
	{ "FN Five-Seven", "gfx/vgui/640_fiveseven" },
	{ "Benelli M3 Super90", "gfx/vgui/640_m3" },
	{ "Benelli XM1014", "gfx/vgui/640_xm1014" },
	{ "H&K MP5-Navy", "gfx/vgui/640_mp5" },
	{ "FN P90", "gfx/vgui/640_p90" },
	{ "H&K UMP45", "gfx/vgui/640_ump45" },
	{ "Ingram MAC-10", "gfx/vgui/640_mac10" },
	{ "Steyr Tactical Machine Pistol", "gfx/vgui/640_tmp" },
	{ "AK-47", "gfx/vgui/640_ak47" },
	{ "Sig SG-552 Commando", "gfx/vgui/640_sg552" },
	{ "Colt M4A1 Carbine", "gfx/vgui/640_m4a1" },
	{ "Steyr Aug", "gfx/vgui/640_aug" },
	{ "Steyr Scout", "gfx/vgui/640_scout" },
	{ "AI Arctic Warfare/Magnum", "gfx/vgui/640_awp" },
	{ "H&K G3/SG-1 Sniper Rifle", "gfx/vgui/640_g3sg1" },
	{ "Sig SG-550 Sniper", "gfx/vgui/640_sg550" },
	{ "FN M249 Para", "gfx/vgui/640_m249" }
};

// TODO: Clean this up
void VGUI_BuyMenu_Main( vector vPos ) {
	static void BuyMenu_Main_1( void ) {
		fVGUI_Display = VGUI_BM_HANDGUNS;
	}
	static void BuyMenu_Main_2( void ) {
		fVGUI_Display = VGUI_BM_SHOTGUNS;
	}
	static void BuyMenu_Main_3( void ) {
		fVGUI_Display = VGUI_BM_SMG;
	}
	static void BuyMenu_Main_4( void ) {
		fVGUI_Display = VGUI_BM_RIFLES;
	}
	static void BuyMenu_Main_5( void ) {
		fVGUI_Display = VGUI_BM_MGS;
	}
	static void BuyMenu_Main_6( void ) {
		sendevent( "GamePlayerBuyAmmo", "f", 0 );
		fVGUI_Display = VGUI_NONE;
	}
	static void BuyMenu_Main_7( void ) {
		sendevent( "GamePlayerBuyAmmo", "f", 1 );
		fVGUI_Display = VGUI_NONE;
	}
	static void BuyMenu_Main_8( void ) {
		fVGUI_Display = VGUI_BM_EQUIPMENT;
	}
	
	VGUI_Button( "Handguns", BuyMenu_Main_1, vPos + '16 116 0', '180 24 0' );
	VGUI_Button( "Shotguns", BuyMenu_Main_2, vPos + '16 148 0', '180 24 0' );
	VGUI_Button( "SMGs", BuyMenu_Main_3, vPos + '16 180 0', '180 24 0' );
	VGUI_Button( "Rifles", BuyMenu_Main_4, vPos + '16 212 0', '180 24 0' );
	VGUI_Button( "Machine Gun", BuyMenu_Main_5, vPos + '16 244 0', '180 24 0' );

	VGUI_Button( "Primary Ammo", BuyMenu_Main_6, vPos + '16 308 0', '180 24 0' );
	VGUI_Button( "Secondary Ammo", BuyMenu_Main_7, vPos + '16 340 0', '180 24 0' );
	VGUI_Button( "Equipment", BuyMenu_Main_8, vPos + '16 372 0', '180 24 0' );

	VGUI_Button( "Exit", BuyMenu_Main_7, vPos + '16 440 0', '180 24 0' );
}

void VGUI_BuyMenu_Back( void ) {
	fVGUI_Display = VGUI_BM_MAIN;
}

/*
====================
VGUI_BuyMenu_BuyWeapon

This is kinda ugly, but it will work for now
====================
*/
float iLastSelected;
void VGUI_BuyMenu_BuyWeapon( void ) {
	if( iLastSelected ) {
		sendevent( "GamePlayerBuy", "f", iLastSelected );
		fVGUI_Display = VGUI_NONE;
	}
}

/*
====================
VGUI_BuyMenu_Button

Draws a button that displays whether or not you can purchase said weapon etc.
====================
*/
void VGUI_BuyMenu_Button( float fWeapon ) {
	iLastSelected = fWeapon;
	
	if ( wptTable[ fWeapon ].iPrice <= getstatf( STAT_MONEY ) ) {
		if ( VGUI_Button( vguiWeaponTable[ fWeapon ].sName, VGUI_BuyMenu_BuyWeapon, vVGUIButtonPos, '180 24 0' ) == TRUE ) {
			drawpic( vVGUIWindowPos + '290 116', vguiWeaponTable[ fWeapon ].sImage, '256 64', '1 1 1', 1 );
			VGUI_Text( sprintf( "Price: %d", (float)wptTable[ fWeapon ].iPrice ) , vVGUIWindowPos + '256 250', '8 8 0' );
			VGUI_Text( sprintf( "Caliber: %d", (float)wptTable[ fWeapon ].iCaliber ) , vVGUIWindowPos + '256 260', '8 8 0' );
			VGUI_Text( sprintf( "Rounds Per Minute: %d", ( wptTable[ fWeapon ].fAttackFinished) * 3600 ) ,  vVGUIWindowPos + '256 270', '8 8 0' );
		}
	} else {
		VGUI_FakeButton( vguiWeaponTable[ fWeapon ].sName, vVGUIButtonPos, '180 24 0' );
	}

	vVGUIButtonPos_y += 32;
}

/*
====================
VGUI_BuyMenu_Handguns
====================
*/
void VGUI_BuyMenu_Handguns( vector vPos ) {
	vVGUIButtonPos = vPos + '16 116 0';
	
	VGUI_BuyMenu_Button( WEAPON_USP45 );
	VGUI_BuyMenu_Button( WEAPON_GLOCK18 );
	VGUI_BuyMenu_Button( WEAPON_DEAGLE );
	VGUI_BuyMenu_Button( WEAPON_P228 );
	
	vVGUIButtonPos_y += 32;

	if ( getplayerkeyvalue( player_localnum, "team" ) == "t" ) {
		VGUI_BuyMenu_Button( WEAPON_ELITES );
	}
	
	if ( getplayerkeyvalue( player_localnum, "team" ) == "ct" ) {
		VGUI_BuyMenu_Button( WEAPON_FIVESEVEN );
	}
	VGUI_Button( "Back", VGUI_BuyMenu_Back, vPos + '16 440 0', '180 24 0' );
}

/*
====================
VGUI_BuyMenu_Shotguns
====================
*/
void VGUI_BuyMenu_Shotguns( vector vPos ) {
	vVGUIButtonPos = vPos + '16 116 0';
	
	VGUI_BuyMenu_Button( WEAPON_M3 );
	VGUI_BuyMenu_Button( WEAPON_XM1014 );

	VGUI_Button( "Back", VGUI_BuyMenu_Back, vPos + '16 440 0', '180 24 0' );
}

/*
====================
VGUI_BuyMenu_SMGs
====================
*/
void VGUI_BuyMenu_SMGs( vector vPos ) {
	vVGUIButtonPos = vPos + '16 116 0';
	
	
	VGUI_BuyMenu_Button( WEAPON_MP5 );
	VGUI_BuyMenu_Button( WEAPON_P90 );
	VGUI_BuyMenu_Button( WEAPON_UMP45 );
	
	vVGUIButtonPos_y += 32;

	if ( getplayerkeyvalue( player_localnum, "team" ) == "t" ) {
		VGUI_BuyMenu_Button( WEAPON_MAC10 );
	}
	
	if ( getplayerkeyvalue( player_localnum, "team" ) == "ct" ) {
		VGUI_BuyMenu_Button( WEAPON_TMP );
	}
	
	VGUI_Button( "Back", VGUI_BuyMenu_Back, vPos + '16 440 0', '180 24 0' );
}

/*
====================
VGUI_BuyMenu_Rifles
====================
*/
void VGUI_BuyMenu_Rifles( vector vPos ) {
	vVGUIButtonPos = vPos + '16 116 0';
	
	if ( getstati( STAT_TEAM ) == TEAM_T ) {
		VGUI_BuyMenu_Button( WEAPON_AK47 );
		VGUI_BuyMenu_Button( WEAPON_SG552 );
	
		VGUI_BuyMenu_Button( WEAPON_SCOUT );
		VGUI_BuyMenu_Button( WEAPON_AWP );
	
		VGUI_BuyMenu_Button( WEAPON_G3SG1 );
	}

	if ( getstati( STAT_TEAM ) == TEAM_CT ) {
		VGUI_BuyMenu_Button( WEAPON_M4A1 );
		VGUI_BuyMenu_Button( WEAPON_AUG );
	
		VGUI_BuyMenu_Button( WEAPON_SCOUT );
		VGUI_BuyMenu_Button( WEAPON_AWP );
	
		VGUI_BuyMenu_Button( WEAPON_SG550 );
	}
	
	VGUI_Button( "Back", VGUI_BuyMenu_Back, vPos + '16 440 0', '180 24 0' );
}

/*
====================
VGUI_BuyMenu_Machineguns
====================
*/
void VGUI_BuyMenu_Machineguns( vector vPos ) {
	vVGUIButtonPos = vPos + '16 116 0';
	
	VGUI_BuyMenu_Button( WEAPON_PARA );

	VGUI_Button( "Back", VGUI_BuyMenu_Back, vPos + '16 440 0', '180 24 0' );
}

/*
====================
VGUI_BuyMenu_Equipment
====================
*/
void VGUI_BuyMenu_Equipment( vector vPos ) {

	/*VGUI_BuyMenu_Button( "Kevlar Vest", "", BuyMenu_Equipment_1, vPos + '16 116 0', '180 24 0' );
	VGUI_BuyMenu_Button( "Kevlar Vest & Helmet", "", BuyMenu_Equipment_1, vPos + '16 148 0', '180 24 0' );
	VGUI_BuyMenu_Button( "Flashbang", "gfx/vgui/640_flashbang", BuyMenu_Equipment_1, vPos + '16 180 0', '180 24 0' );
	VGUI_BuyMenu_Button( "HE Grenade", "gfx/vgui/640_hegrenade", BuyMenu_Equipment_1, vPos + '16 212 0', '180 24 0' );
	VGUI_BuyMenu_Button( "Smoke Grenade", "gfx/vgui/640_smokegrenade", BuyMenu_Equipment_1, vPos + '16 244 0', '180 24 0' );
	VGUI_BuyMenu_Button( "NightVision Goggles", "", BuyMenu_Equipment_1, vPos + '16 276 0', '180 24 0' );*/
	
	if ( getplayerkeyvalue( player_localnum, "team" ) == "ct" ) {
		//VGUI_BuyMenu_Button( "Defuse Kit", "", BuyMenu_Equipment_1, vPos + '16 308 0', '180 24 0' );
	}

	VGUI_Button( "Back", VGUI_BuyMenu_Back, vPos + '16 440 0', '180 24 0' );
}
