/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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

#include "gamerules.h"
#include "sentences.h"
#include "skill.h"
#include "logging.h"
#include "nodes.h"
#include "spawn.h"
#include "weapons.h"
#include "plugins.h"
#include "traceattack.h"
#include "footsteps.h"

#define AREAPORTAL_CLOSED 0
#define AREAPORTAL_OPEN 1

var int autocvar_mp_flashlight = TRUE;

void FX_Impact(impactType_t, vector, vector);
void FX_Explosion(vector);
void FX_GibHuman(vector);
void Footsteps_Update(void);

void TraceAttack_FireBullets(int, vector, int, vector, int);
#ifdef BULLETPENETRATION
void TraceAttack_SetPenetrationPower(int);
#endif

void Damage_Radius(vector, entity, float, float, int, int);
void Damage_Apply(entity, entity, float, int, damageType_t);
void Client_FixAngle(entity, vector);
void Client_ShakeOnce(vector, float, float, float, float);

void Game_ServerModelEvent(float, int, string);
void Event_ServerModelEvent(float, int, string);

void Game_Input(void);
int Rules_IsTeamPlay(void);

entity eActivator;

/* Generic entity fields */
.void(void) PlayerUse;
.int iBleeds;
.entity eUser;
.float material;
.float deaths;
.float identity;
.float botinfo;
.void(float) Save;

/* in idTech the .owner field causes collisions to fail against set entity,
 * we don't want this all of the time. so use this as a fallback */
.entity real_owner;

int trace_surfaceflagsi;
string startspot;
string __fullspawndata;
hashtable hashMaterials;

/* damage related tempglobals, like trace_* */
entity g_dmg_eAttacker;
entity g_dmg_eTarget;
int g_dmg_iDamage;
bodyType_t g_dmg_iHitBody;
int g_dmg_iFlags;
int g_dmg_iWeapon;

var int g_ents_initialized = FALSE;

/* main is a qcc leftover */
void main(void)
{
}

#define SAVE_DECIMAL(x,y,z) fputs(x, sprintf("%S \"%d\" ", y, z))
#define SAVE_INTEGER(x,y,z) fputs(x, sprintf("%S \"%i\" ", y, z))
#define SAVE_FLOAT(x,y,z) fputs(x, sprintf("%S \"%f\" ", y, z))
#define SAVE_VECTOR(x,y,z) fputs(x, sprintf("%S \"%v\" ", y, z))
#define SAVE_STRING(x,y,z) fputs(x, sprintf("%S \"%s\" ", y, z))
#define SAVE_HEX(x,y,z) fputs(x, sprintf("%S \"%x\" ", y, z))
