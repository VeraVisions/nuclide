/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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
#include "vox.h"
#include "nodes.h"
#include "spawn.h"
#include "weapons.h"
#include "plugins.h"
#include "vehicles.h"
#include "traceattack.h"
#include "footsteps.h"

#define AREAPORTAL_CLOSED 0
#define AREAPORTAL_OPEN 1

var int autocvar_mp_flashlight = TRUE;

void FX_Impact(int, vector, vector);
void FX_Explosion(vector);
void FX_GibHuman(vector);
void Footsteps_Update(void);
void Vox_Broadcast(string sMessage);

void TraceAttack_FireBullets(int, vector, int, vector, int);
#ifdef BULLETPENETRATION
void TraceAttack_SetPenetrationPower(int);
#endif

void Damage_Radius(vector, entity, float, float, int, int);
void Damage_Apply(entity, entity, float, int, int);
void Client_TriggerCamera(entity, vector, vector, float);
void Client_FixAngle(entity, vector);
void Game_Input(void);
int Rules_IsTeamPlay(void);

entity eActivator;
entity g_eAttacker;

/* Generic entity fields */
.void(void) PlayerUse;
.int iBleeds;
.entity eUser;
.float material;
.float deaths;
.float identity;

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
int g_dmg_iHitBody;
int g_dmg_iFlags;
int g_dmg_iWeapon;
