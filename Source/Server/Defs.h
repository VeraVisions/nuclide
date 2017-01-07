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

#define VEC_HULL_MIN '-16 -16 -36'
#define VEC_HULL_MAX '16 16 36'
#define VEC_PLAYER_VIEWPOS '0 0 20'

#define VEC_CHULL_MIN '-16 -16 -18'
#define VEC_CHULL_MAX '16 16 18'
#define VEC_PLAYER_CVIEWPOS '0 0 12'

// Server cvars
var float autocvar_mp_startmoney = 800;
var float autocvar_mp_buytime = 90;
var float autocvar_mp_freezetime = 6;
var float autocvar_mp_c4timer = 45;
var float autocvar_mp_roundtime = 5;
var float autocvar_mp_fillweapons = 0;

// Hit Group standards
enum {
	BODY_DEFAULT,
	BODY_HEAD,
	BODY_CHEST,
	BODY_STOMACH,
	BODY_ARMLEFT,
	BODY_ARMRIGHT,
	BODY_LEGLEFT,
	BODY_LEGRIGHT
};

// Player specific fields
.float fInBuyZone;
.float fInHostageZone;
.float fInBombZone;
.float fMoney;
.float fStepTime;
.int iInGame;
.float fCharModel;
.int iCrouchAttempt;
.int iHasBomb;
.float fDeaths;
.int iEquipment;
.float armor;
.float fProgressBar;

// Match specific fields
int iWon_T;
int iWon_CT;
int iAlivePlayers_T;
int iAlivePlayers_CT;

float fGameState;
float fGameTime;

// Weapon specific fields
.int iCurrentMag;
.int iCurrentCaliber;
.float fSlotMelee, fSlotPrimary, fSlotSecondary, fSlotGrenade;
.float fAttackFinished;
.float fAccuracy;
.float fFallVelocity;

// Game specific fields
int iHostagesMax;
int iBombZones;
int iRescueZones;
int iBuyZones;
int iVIPZones;
int iBuyRestriction; // For info_map_parameters

int iHostagesRescued;
int iBombPlanted;

// Generic entity fields
.int iUsable;
.int iBleeds;
.void() vPain;
.void() vDeath;
.float fRespawns;
.entity eUser;

// All about +use
entity eActivator;
.void() vUse;
.int iUsable;

// GoldSrc-Rendermode Fields
.vector rendercolor;
.float rendermode;
.float renderamt;
.float alpha;

string sCSPlayers[9] = {
	"",
	"models/player/terror/terror.mdl",
	"models/player/leet/leet.mdl",
	"models/player/arctic/arctic.mdl",
	"models/player/guerilla/guerilla.mdl",
	"models/player/urban/urban.mdl",
	"models/player/gsg9/gsg9.mdl",
	"models/player/sas/sas.mdl",
	"models/player/gign/gign.mdl"
};

void Rules_RoundOver( int iTeamWon, int iMoneyReward, float fSilent );
float Rules_BuyingPossible( void );
void Timer_Begin( float fTime, float fMode);
void Spawn_RespawnClient( float fTeam );
void Spawn_CreateClient( float fTeam );
void Spawn_MakeSpectator( void );
void Client_SendEvent( entity eClient, float fEVType );
void Client_TriggerCamera( entity eTarget, vector vPos, vector vEndPos, float fResetTime );
void Weapon_SwitchBest( void );
void Weapon_UpdateCurrents( void );

void OpenCSGunBase_AccuracyCalc( void );
void OpenCSGunBase_Draw( void );
float OpenCSGunBase_PrimaryFire( void );
float OpenCSGunBase_Reload( void );

void BaseMelee_Draw( void );
void BaseMelee_Attack( void );
	
float Player_GetMaxSpeed( float fWeapon );

void Effect_Impact( int iType, vector vPos, vector vNormal );
void TraceAttack_FireBullets( int iShots, vector vPos );
void Damage_Radius( vector vOrigin, entity eAttacker, float fDamage, float fRadius );
void Damage_Apply( entity eTarget, entity eAttacker, int iDamage, vector vHitPos );

void Entities_InitRespawnable( void() vRespawnFunc );
void Entities_Respawn( void );

void Ammo_BuyPrimary( float fFree );
void Ammo_BuySecondary( float fFree );

void Input_Handle( void );

// WIP
string __fullspawndata;
hashtable hashMaterials;

#define NULL __NULL__
