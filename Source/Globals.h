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

// Stuff that applies to all codebases
enum {
	TEAM_SPECTATOR,
	TEAM_T,
	TEAM_CT,
	TEAM_VIP
};

enum { 
	STAT_BUYZONE = 34,
	STAT_HOSTAGEZONE,
	STAT_BOMBZONE,
	STAT_MONEY,
	STAT_GAMETIME,
	STAT_SLOT_MELEE,
	STAT_SLOT_PRIMARY,
	STAT_SLOT_SECONDARY,
	STAT_SLOT_GRENADE,
	STAT_CURRENT_CLIP,
	STAT_CURRENT_CALIBER,
	STAT_TEAM,
	STAT_WON_T,
	STAT_WON_CT
};

enum {
	ENT_AMBIENTSOUND = 1,
	ENT_SPRITE
};

enum {
	GAME_INACTIVE,
	GAME_COMMENCING,
	GAME_FREEZE,
	GAME_ACTIVE,
	GAME_END
};

#define CS_WEAPON_COUNT 25
enum {
	WEAPON_NONE = 0,
	WEAPON_KNIFE,
	WEAPON_USP45,
	WEAPON_GLOCK18,
	WEAPON_DEAGLE,
	WEAPON_P228,
	WEAPON_ELITES,
	WEAPON_FIVESEVEN,
	WEAPON_M3,
	WEAPON_XM1014,
	WEAPON_MP5,
	WEAPON_P90,
	WEAPON_UMP45,
	WEAPON_MAC10,
	WEAPON_TMP,
	WEAPON_AK47,
	WEAPON_SG552,
	WEAPON_M4A1,
	WEAPON_AUG,
	WEAPON_SCOUT,
	WEAPON_AWP,
	WEAPON_G3SG1,
	WEAPON_SG550,
	WEAPON_PARA,
	WEAPON_C4BOMB
};

enum {
	CALIBER_50AE = 1,
	CALIBER_762MM,
	CALIBER_556MM,
	CALIBER_556MMBOX,
	CALIBER_338MAG,
	CALIBER_9MM,
	CALIBER_BUCKSHOT,
	CALIBER_45ACP,
	CALIBER_357SIG,
	CALIBER_57MM
};

.int iAmmo_50AE;
.int iAmmo_762MM;
.int iAmmo_556MM;
.int iAmmo_556MMBOX;
.int iAmmo_338MAG;
.int iAmmo_9MM;
.int iAmmo_BUCKSHOT;
.int iAmmo_45ACP;
.int iAmmo_357SIG;
.int iAmmo_57MM;

// Weapon types
enum {
	TYPE_SEMI,
	TYPE_AUTO
};

// Slot types
enum { 
	SLOT_MELEE,
	SLOT_SECONDARY,
	SLOT_PRIMARY,
	SLOT_GRENADE
};

// These values are taken from CS:S' .ctx script files
typedef struct {
	int iWeaponID; 	// Identifier
	int iSlot;
	int iPrice;		
	int iCaliber;
	float fSpeedM;
	
	int iBullets;	// How many bullets does it shoot?
	int iClipSize;	// How big is the clip/magazine?
	
	int iDamage;	// How much damage is done by a single bullet?
	int iPenetration;	// Penetration multiplier
	
	float fRange;	// Max distance of the bullet trace
	float fRangeModifier;	// ???
	
	float fWeaponType;
	float fAttackFinished; // When is the gone done firing
	float fReloadFinished; // When is the gone done firing
	
	.int iCaliberfld;	// Pointer towards the caliberfield of the gun
	.int iClipfld;		// Pointer towards the clip of the gun
	
	float fAccuracyDivisor;
	float fAccuracyOffset;
	float fMaxInaccuracy;
} weaponinfo_t;

typedef struct {
	int iSize;
	int iMaxAmount;
	int iPrice;
} ammoinfo_t;

typedef struct {
	void() vDraw;
	void() vPrimary;
	void() vSecondary;
	void() vReload;
} weaponfunc_t;

// Network Events
enum {
	EV_WEAPON_DRAW,
	EV_WEAPON_PRIMARYATTACK,
	EV_WEAPON_SECONDARYATTACK,
	EV_WEAPON_RELOAD,
	EV_MODELGIB,
	EV_CAMERATRIGGER,
	EV_RADIOMSG,
	EV_ORBITUARY
};

// Submodel materials
enum { 
	MATERIAL_GLASS = 0, 
	MATERIAL_WOOD, 
	MATERIAL_METAL, 
	MATERIAL_FLESH, 
	MATERIAL_CINDER, 
	MATERIAL_TILE, 
	MATERIAL_COMPUTER, 
	MATERIAL_GLASS_UNBREAKABLE, 
	MATERIAL_ROCK, 
	MATERIAL_NONE	
};

float clamp(float d, float imin, float imax) {
	float t;

  if(d < imin)
	  t = imin;
  else
	  t = d;

  if(t > imax)
	  return imax;
  else
	  return t;
}
