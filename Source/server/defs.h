/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

#define CLASSEXPORT(classname,classa) void classname ( void ) { spawnfunc_##classa(); }

var int autocvar_mp_flashlight = TRUE;

void Effect_Impact( int iType, vector vPos, vector vNormal );
void Effect_CreateExplosion( vector vPos );
void Footsteps_Update( void );

void TraceAttack_FireBullets( int iShots, vector vPos, int iDamage, vector vecAccuracy);
void Damage_Radius( vector vOrigin, entity eAttacker, float fDamage, float fRadius, int iCheckClip );
void Damage_Apply( entity eTarget, entity eAttacker, float fDamage, vector vHitPos, int iSkipArmor );
void Client_TriggerCamera( entity eTarget, vector vPos, vector vEndPos, float fResetTime );
void Game_Input(void);

entity eActivator;

// Generic entity fields
.void() PlayerUse;
.int iBleeds;
.void(int iHitBody) vPain;
.void(int iHitBody) vDeath;
.entity eUser;
.float material;
.float armor;
.float fStepTime;

string startspot;
string __fullspawndata;
hashtable hashMaterials;

int g_initialized;
