/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/


#define VEC_PLAYER_VIEWPOS '0 0 20'
#define VEC_PLAYER_CVIEWPOS '0 0 12'

// Server cvars
var int autocvar_mp_winlimit = 0;
var int autocvar_mp_halftime = 0;
var int autocvar_mp_startmoney = 800;
var float autocvar_mp_buytime = 90;
var float autocvar_mp_freezetime = 6;
var float autocvar_mp_c4timer = 45;
var float autocvar_mp_roundtime = 5;
var float autocvar_mp_timelimit = 60;
var string autocvar_motdfile = "motd.txt";
var int autocvar_mp_friendlyfire = FALSE;

// New, FreeCS exclusive variables
var int autocvar_fcs_voxannounce = FALSE;
var int autocvar_fcs_knifeonly = FALSE; // Disallows buying and spawning with weps
var int autocvar_fcs_swapteams = FALSE; // Swaps spawnpoints
var int autocvar_fcs_nopickups = FALSE; // Disable weapon items
var int autocvar_fcs_reward_kill = 300;
var int autocvar_fcs_penalty_pain = -150;
var int autocvar_fcs_penalty_kill = -1500;
var int autocvar_fcs_maxmoney = 16000;
var int autocvar_fcs_fillweapons = FALSE; // This will automatically get ammo for the weapon you buy
var int autocvar_fcs_fix_bombtimer = FALSE;

// Mapcycle features
var string autocvar_mapcyclefile = "mapcycle.txt";
var int iMapCycleCount;
string *sMapCycle;

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

// Grenade states
enum {
	GRENADE_UNREADY,
	GRENADE_PULLING,
	GRENADE_READY
};

// Match specific fields
int iRounds;
int iWon_T;
int iWon_CT;
int iAlivePlayers_T;
int iAlivePlayers_CT;

float fGameState;
float fGameTime;

// Game specific fields
int iHostagesMax;
int iBombZones;
int iRescueZones;
int iBuyZones;
int iVIPZones;
int iEscapeZones;
int iBuyRestriction; // For info_map_parameters
int iBombRadius; // For info_map_parameters

int iHostagesRescued;
int iBombPlanted;

void Rules_RoundOver( int iTeamWon, int iMoneyReward, float fSilent );
float Rules_BuyingPossible( void );
void Timer_Begin( float fTime, float fMode);
void Spawn_RespawnClient( float fTeam );
void Spawn_CreateClient( float fTeam );
void Spawn_MakeSpectator( void );
void Client_SendEvent( entity eClient, float fEVType );

void Weapon_Draw( float fWeapon );
void Weapon_SwitchBest( void );
void Weapon_UpdateCurrents( void );
void Weapon_DropWeapon( int iSlot );
float Weapon_GetAnimType( float fWeapon );
float Weapon_GetFireRate( float fWeapon );
float Weapon_GetReloadTime( float fWeapon );
void Weapon_Reload( float fWeapon );

void BaseGun_AccuracyCalc( void );
void BaseGun_Draw( void );
float BaseGun_PrimaryFire( void );
float BaseGun_Reload( void );
void Effect_CreateFlash(entity targ);
void BaseMelee_Draw( void );
int BaseMelee_Attack( void );

void TraceAttack_FireBullets( int iShots, vector vPos );

void Ammo_AutoFill(float fWeapon);
void Ammo_BuyPrimary(void);
void Ammo_BuySecondary(void);

void Input_Handle( void );

void Animation_PlayerTop( float fFrame );
void Animation_PlayerTopTemp( float fFrame, float fTime );

#define NULL __NULL__
