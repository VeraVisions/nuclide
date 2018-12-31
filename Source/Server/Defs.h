/*
	Copyright 2016-2018 Marco "eukara" Hladik
	
	MIT LICENSE

	Permission is hereby granted, free of charge, to any person 
	obtaining a copy of this software and associated documentation 
	files (the "Software"), to deal in the Software without 
	restriction, including without limitation the rights to use,
	copy, modify, merge, publish, distribute, sublicense, and/or
	sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.
*/

#define CLASSEXPORT(classname,classa) void classname ( void ) { spawnfunc_##classa(); }

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
var int autocvar_sv_voxannounce = FALSE;

// New, FreeCS exclusive variables
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

entity eActivator;

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
void Client_TriggerCamera( entity eTarget, vector vPos, vector vEndPos, float fResetTime );

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

void BaseMelee_Draw( void );
int BaseMelee_Attack( void );
void Effect_Impact( int iType, vector vPos, vector vNormal );
void Effect_CreateSmoke( vector vPos );
void Effect_CreateExplosion( vector vPos );
void Effect_CreateFlash( entity eTarget );

void TraceAttack_FireBullets( int iShots, vector vPos );
void Damage_Radius( vector vOrigin, entity eAttacker, float fDamage, float fRadius, int iCheckClip );
void Damage_Apply( entity eTarget, entity eAttacker, int iDamage, vector vHitPos, int iSkipArmor );

void Entities_UseTargets( void );
void Entities_InitRespawnable( void() vRespawnFunc );
void Entities_Respawn( void );

void Ammo_AutoFill(float fWeapon);
void Ammo_BuyPrimary(void);
void Ammo_BuySecondary(void);

void Input_Handle( void );

void Animation_PlayerTop( float fFrame );
void Animation_PlayerTopTemp( float fFrame, float fTime );
void Footsteps_Update( void );

string startspot;
string __fullspawndata;
hashtable hashMaterials;

#define NULL __NULL__
