/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#define CLASSEXPORT(classname,classa) void classname ( void ) { spawnfunc_##classa(); }

var int autocvar_mp_flashlight = TRUE;
var int g_hlbsp_materials = FALSE;

void Effect_Impact( int iType, vector vPos, vector vNormal );
void Effect_CreateExplosion( vector vPos );
void Effect_GibHuman( vector vPos);
void Footsteps_Update( void );
void Vox_Broadcast(string sMessage);
void TraceAttack_FireBullets(int , vector, int, vector, int);
void Damage_Radius( vector vOrigin, entity eAttacker, float fDamage, float fRadius, int iCheckClip );
void Damage_Apply( entity, entity, float, vector, int, int);
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
.float deaths;
.float fStepTime;

string startspot;
string __fullspawndata;
hashtable hashMaterials;
