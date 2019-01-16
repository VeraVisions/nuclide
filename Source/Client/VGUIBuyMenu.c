/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

#include "VGUI.h"

vguiweaponobject_t vguiWeaponTable[ CS_WEAPON_COUNT ] = {
	{ _("WEAPON_NONE"), "" },
	{ _("WEAPON_KNIFE"), "" },
	{ _("WEAPON_USP"), "gfx/vgui/640_usp" },
	{ _("WEAPON_GLOCK18"), "gfx/vgui/640_glock18" },
	{ _("WEAPON_DEAGLE"), "gfx/vgui/640_deagle" },
	{ _("WEAPON_P228"), "gfx/vgui/640_p228" },
	{ _("WEAPON_ELITES"), "gfx/vgui/640_elite" },
	{ _("WEAPON_FIVESEVEN"), "gfx/vgui/640_fiveseven" },
	{ _("WEAPON_M3"), "gfx/vgui/640_m3" },
	{ _("WEAPON_XM1014"), "gfx/vgui/640_xm1014" },
	{ _("WEAPON_MP5"), "gfx/vgui/640_mp5" },
	{ _("WEAPON_P90"), "gfx/vgui/640_p90" },
	{ _("WEAPON_UMP45"), "gfx/vgui/640_ump45" },
	{ _("WEAPON_MAC10"), "gfx/vgui/640_mac10" },
	{ _("WEAPON_TMP"), "gfx/vgui/640_tmp" },
	{ _("WEAPON_AK47"), "gfx/vgui/640_ak47" },
	{ _("WEAPON_SG552"), "gfx/vgui/640_sg552" },
	{ _("WEAPON_M4A1"), "gfx/vgui/640_m4a1" },
	{ _("WEAPON_AUG"), "gfx/vgui/640_aug" },
	{ _("WEAPON_SCOUT"), "gfx/vgui/640_scout" },
	{ _("WEAPON_AWP"), "gfx/vgui/640_awp" },
	{ _("WEAPON_G3SG1"), "gfx/vgui/640_g3sg1" },
	{ _("WEAPON_SG550"), "gfx/vgui/640_sg550" },
	{ _("WEAPON_PARA"), "gfx/vgui/640_m249" }
};

vguiequipobject_t vguiEquipmentTable[ 7 ] = {
	{ EQUIPMENT_KEVLAR, _("EQUIPMENT_KEVLAR"), "gfx/vgui/640_kevlar" },
	{ EQUIPMENT_HELMET, _("EQUIPMENT_HELMET"), "gfx/vgui/640_kevlar_helmet" },
	{ WEAPON_FLASHBANG, _("WEAPON_FLASHBANG"), "gfx/vgui/640_flashbang" },
	{ WEAPON_HEGRENADE, _("WEAPON_HEGRENADE"), "gfx/vgui/640_hegrenade" },
	{ WEAPON_SMOKEGRENADE, _("WEAPON_SMOKEGRENADE"), "gfx/vgui/640_smokegrenade" },
	{ EQUIPMENT_DEFUSALKIT, _("EQUIPMENT_DEFUSALKIT"), "gfx/vgui/640_defuser" },
	{ EQUIPMENT_NIGHTVISION, _("EQUIPMENT_NIGHTVISION"), "gfx/vgui/640_nightvision" },
};

// TODO: Clean this up
void VGUI_BuyMenu_Main( vector vPos ) {
	static void BuyMenu_Main_1( void ) {
		pSeat->fVGUI_Display = VGUI_BM_HANDGUNS;
	}
	static void BuyMenu_Main_2( void ) {
		pSeat->fVGUI_Display = VGUI_BM_SHOTGUNS;
	}
	static void BuyMenu_Main_3( void ) {
		pSeat->fVGUI_Display = VGUI_BM_SMG;
	}
	static void BuyMenu_Main_4( void ) {
		pSeat->fVGUI_Display = VGUI_BM_RIFLES;
	}
	static void BuyMenu_Main_5( void ) {
		pSeat->fVGUI_Display = VGUI_BM_MGS;
	}
	static void BuyMenu_Main_6( void ) {
		sendevent( "GamePlayerBuyAmmo", "f", 0 );
		pSeat->fVGUI_Display = VGUI_NONE;
	}
	static void BuyMenu_Main_7( void ) {
		sendevent( "GamePlayerBuyAmmo", "f", 1 );
		pSeat->fVGUI_Display = VGUI_NONE;
	}
	static void BuyMenu_Main_8( void ) {
		pSeat->fVGUI_Display = VGUI_BM_EQUIPMENT;
	}
	static void BuyMenu_Main_9( void ) {
		pSeat->fVGUI_Display = VGUI_NONE;
	}
	
	VGUI_Button( _("VGUI_TITLE_HANDGUN"), BuyMenu_Main_1, vPos + '16 116 0', '180 24 0' );
	VGUI_Button( _("VGUI_TITLE_SHOTGUN"), BuyMenu_Main_2, vPos + '16 148 0', '180 24 0' );
	VGUI_Button( _("VGUI_TITLE_SMG"), BuyMenu_Main_3, vPos + '16 180 0', '180 24 0' );
	VGUI_Button( _("VGUI_TITLE_RIFLE"), BuyMenu_Main_4, vPos + '16 212 0', '180 24 0' );
	VGUI_Button( _("VGUI_TITLE_MG"), BuyMenu_Main_5, vPos + '16 244 0', '180 24 0' );

	VGUI_Button( _("VGUI_TITLE_AMMO1"), BuyMenu_Main_6, vPos + '16 308 0', '180 24 0' );
	VGUI_Button( _("VGUI_TITLE_AMMO2"), BuyMenu_Main_7, vPos + '16 340 0', '180 24 0' );
	VGUI_Button( _("VGUI_TITLE_EQUIPMENT"), BuyMenu_Main_8, vPos + '16 372 0', '180 24 0' );

	VGUI_Button( _("VGUI_EXIT"), BuyMenu_Main_9, vPos + '16 440 0', '180 24 0' );
}

void VGUI_BuyMenu_Back( void ) {
	pSeat->fVGUI_Display = VGUI_BM_MAIN;
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
		sendevent( "PlayerBuyWeapon", "f", iLastSelected );
		pSeat->fVGUI_Display = VGUI_NONE;
	}
}

/*
====================
VGUI_BuyMenu_BuyEquipment
====================
*/
void VGUI_BuyMenu_BuyEquipment( void ) {
	sendevent( "PlayerBuyEquipment", "f", iLastSelected );
	pSeat->fVGUI_Display = VGUI_NONE;
}

/*
====================
VGUI_BuyMenu_WeaponButton

Draws a button that displays whether or not you can purchase said weapon etc.
====================
*/
void VGUI_BuyMenu_WeaponButton( float fWeapon ) {
	iLastSelected = fWeapon;
	
	if ( wptTable[ fWeapon ].iPrice <= getstatf( STAT_MONEY ) ) {
		if ( VGUI_Button( vguiWeaponTable[ fWeapon ].sName, VGUI_BuyMenu_BuyWeapon, vVGUIButtonPos, '264 24 0' ) == TRUE ) {
			drawpic( vVGUIWindowPos + '328 116', vguiWeaponTable[ fWeapon ].sImage, '256 64', '1 1 1', 1 );
			VGUI_Text( sprintf( _("BUY_PRICETAG"), wptTable[ fWeapon ].iPrice ), vVGUIWindowPos + '328 250', '12 12', FONT_CON );
			VGUI_Text( sprintf( _("BUY_CALIBER"), wptTable[ fWeapon ].iCaliber ), vVGUIWindowPos + '328 260', '12 12', FONT_CON );
			VGUI_Text( sprintf( _("BUY_RPM"), ( wptTable[ fWeapon ].fAttackFinished) * 3600 ),  vVGUIWindowPos + '328 270', '12 12', FONT_CON );
		}
	} else {
		VGUI_FakeButton( vguiWeaponTable[ fWeapon ].sName, vVGUIButtonPos, '264 24 0' );
	}

	vVGUIButtonPos_y += 32;
}

/*
====================
VGUI_BuyMenu_EquipmentButton

Draws a button that displays whether or not you can purchase said equipment
====================
*/
void VGUI_BuyMenu_EquipmentButton( float fID ) {
	iLastSelected = fID;
	
	if ( eqptTable[ fID ].iPrice <= getstatf( STAT_MONEY ) ) {
		if ( VGUI_Button( vguiEquipmentTable[ fID ].sName, VGUI_BuyMenu_BuyEquipment, vVGUIButtonPos, '180 24 0' ) == TRUE ) {
			drawpic( vVGUIWindowPos + '290 116', vguiEquipmentTable[ fID ].sImage, '256 64', '1 1 1', 1 );
			VGUI_Text( sprintf( _("BUY_PRICETAG"), eqptTable[ fID ].iPrice ) , vVGUIWindowPos + '256 250', '12 12', FONT_CON );
		}
	} else {
		VGUI_FakeButton( vguiEquipmentTable[ fID ].sName, vVGUIButtonPos, '180 24 0' );
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
	
	VGUI_BuyMenu_WeaponButton( WEAPON_USP45 );
	VGUI_BuyMenu_WeaponButton( WEAPON_GLOCK18 );
	VGUI_BuyMenu_WeaponButton( WEAPON_DEAGLE );
	VGUI_BuyMenu_WeaponButton( WEAPON_P228 );
	
	vVGUIButtonPos_y += 32;

	if ( stof( getplayerkeyvalue( player_localnum, "*team" ) ) ==  TEAM_T ) {
		VGUI_BuyMenu_WeaponButton( WEAPON_ELITES );
	} else if ( stof( getplayerkeyvalue( player_localnum, "*team" ) ) ==  TEAM_CT ) {
		VGUI_BuyMenu_WeaponButton( WEAPON_FIVESEVEN );
	}
	
	VGUI_Button( _("VGUI_BACK"), VGUI_BuyMenu_Back, vPos + '16 440 0', '180 24 0' );
}

/*
====================
VGUI_BuyMenu_Shotguns
====================
*/
void VGUI_BuyMenu_Shotguns( vector vPos ) {
	vVGUIButtonPos = vPos + '16 116 0';
	
	VGUI_BuyMenu_WeaponButton( WEAPON_M3 );
	VGUI_BuyMenu_WeaponButton( WEAPON_XM1014 );

	VGUI_Button( _("VGUI_BACK"), VGUI_BuyMenu_Back, vPos + '16 440 0', '180 24 0' );
}

/*
====================
VGUI_BuyMenu_SMGs
====================
*/
void VGUI_BuyMenu_SMGs( vector vPos ) {
	vVGUIButtonPos = vPos + '16 116 0';
	
	
	VGUI_BuyMenu_WeaponButton( WEAPON_MP5 );
	VGUI_BuyMenu_WeaponButton( WEAPON_P90 );
	VGUI_BuyMenu_WeaponButton( WEAPON_UMP45 );
	
	vVGUIButtonPos_y += 32;

	if ( stof( getplayerkeyvalue( player_localnum, "*team" ) ) ==  TEAM_T ) {
		VGUI_BuyMenu_WeaponButton( WEAPON_MAC10 );
	} else if ( stof( getplayerkeyvalue( player_localnum, "*team" ) ) ==  TEAM_CT ) {
		VGUI_BuyMenu_WeaponButton( WEAPON_TMP );
	}
	
	VGUI_Button( _("VGUI_BACK"), VGUI_BuyMenu_Back, vPos + '16 440 0', '180 24 0' );
}

/*
====================
VGUI_BuyMenu_Rifles
====================
*/
void VGUI_BuyMenu_Rifles( vector vPos ) {
	vVGUIButtonPos = vPos + '16 116 0';

	if ( stof( getplayerkeyvalue( player_localnum, "*team" ) ) == TEAM_T ) {
		VGUI_BuyMenu_WeaponButton( WEAPON_AK47 );
		VGUI_BuyMenu_WeaponButton( WEAPON_SG552 );
	
		VGUI_BuyMenu_WeaponButton( WEAPON_SCOUT );
		VGUI_BuyMenu_WeaponButton( WEAPON_AWP );
	
		VGUI_BuyMenu_WeaponButton( WEAPON_G3SG1 );
	}

	if ( stof( getplayerkeyvalue( player_localnum, "*team" ) ) == TEAM_CT ) {
		VGUI_BuyMenu_WeaponButton( WEAPON_M4A1 );
		VGUI_BuyMenu_WeaponButton( WEAPON_AUG );
	
		VGUI_BuyMenu_WeaponButton( WEAPON_SCOUT );
		VGUI_BuyMenu_WeaponButton( WEAPON_AWP );
	
		VGUI_BuyMenu_WeaponButton( WEAPON_SG550 );
	}

	VGUI_Button( _("VGUI_BACK"), VGUI_BuyMenu_Back, vPos + '16 440 0', '180 24 0' );
}

/*
====================
VGUI_BuyMenu_Machineguns
====================
*/
void VGUI_BuyMenu_Machineguns( vector vPos ) {
	vVGUIButtonPos = vPos + '16 116 0';
	
	VGUI_BuyMenu_WeaponButton( WEAPON_PARA );

	VGUI_Button( _("VGUI_BACK"), VGUI_BuyMenu_Back, vPos + '16 440 0', '180 24 0' );
}

/*
====================
VGUI_BuyMenu_Equipment
====================
*/
void VGUI_BuyMenu_Equipment( vector vPos ) {
	vVGUIButtonPos = vPos + '16 116 0';

	VGUI_BuyMenu_EquipmentButton( 0 );
	VGUI_BuyMenu_EquipmentButton( 1 );
	VGUI_BuyMenu_EquipmentButton( 2 );
	VGUI_BuyMenu_EquipmentButton( 3 );
	VGUI_BuyMenu_EquipmentButton( 4 );

	if ( stof( getplayerkeyvalue( player_localnum, "*team" ) ) ==  TEAM_CT ) {
		VGUI_BuyMenu_EquipmentButton( 5 );
	}

	VGUI_BuyMenu_EquipmentButton( 6 );

	VGUI_Button( _("VGUI_BACK"), VGUI_BuyMenu_Back, vPos + '16 440 0', '180 24 0' );
}
