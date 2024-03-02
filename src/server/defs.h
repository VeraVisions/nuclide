/*
 * Copyright (c) 2016-2021 Marco Cawthorne <marco@icculus.org>
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

#include "NSOutput.h"
#include "NSGameRules.h"
#include "skill.h"
#include "logging.h"
#include "nodes.h"
#include "spawn.h"
#include "weapons.h"
#include "plugins.h"
#include "NSTraceAttack.h"

#include "route.h"
#include "way.h"
#include "lament.h"

/* helper macros */
#define EVALUATE_FIELD(fieldname, changedflag) {\
	if (ATTR_CHANGED(fieldname)) {\
		SetSendFlags(changedflag);\
	}\
	SAVE_STATE(fieldname);\
}

#define EVALUATE_VECTOR(fieldname, id, changedflag) {\
	if (VEC_CHANGED(fieldname, id)) {\
		SetSendFlags(changedflag);\
	}\
	SAVE_STATE_FIELD(fieldname, id);\
}

#define SENDENTITY_BYTE(field, changedflag) {\
	if (flChanged & changedflag)\
		WriteByte(MSG_ENTITY, field);\
}

#define SENDENTITY_SHORT(field, changedflag) {\
	if (flChanged & changedflag)\
		WriteShort(MSG_ENTITY, field);\
}

#define SENDENTITY_INT(field, changedflag) {\
	if (flChanged & changedflag)\
		WriteInt(MSG_ENTITY, field);\
}

#define SENDENTITY_FLOAT(field, changedflag) {\
	if (flChanged & changedflag)\
		WriteFloat(MSG_ENTITY, field);\
}

#define SENDENTITY_STRING(field, changedflag) {\
	if (flChanged & changedflag)\
		WriteString(MSG_ENTITY, field);\
}

#define SENDENTITY_COORD(field, changedflag) {\
	if (flChanged & changedflag)\
		WriteCoord(MSG_ENTITY, field);\
}

#define SENDENTITY_ANGLE(field, changedflag) {\
	if (flChanged & changedflag)\
		WriteShort(MSG_ENTITY, field * 32767 / 360);\
}

#define SENDENTITY_ENTITY(field, changedflag) {\
	if (flChanged & changedflag)\
		WriteEntity(MSG_ENTITY, field);\
}

#define SENDENTITY_COLOR(field, changedflag) {\
	if (flChanged & changedflag)\
		WriteByte(MSG_ENTITY, field * 255.0);\
}

var bool g_isloading = false;

var bool autocvar_mp_flashlight = true;


void TraceAttack_FireBullets(int, vector, int, vector, int);
#ifdef BULLETPENETRATION
void TraceAttack_SetPenetrationPower(int);
void TraceAttack_SetRangeModifier(float);
#endif

void Damage_Radius(vector, entity, float, float, int, int);
void Damage_Apply(entity, entity, float, int, damageType_t);
void Client_FixAngle(entity, vector);
void Client_ShakeOnce(vector, float, float, float, float);

void Game_ServerModelEvent(float, int, string);
void Event_ServerModelEvent(float, int, string);

void Mapcycle_Load(string);

entity eActivator;

/* Generic entity fields */
.void(void) PlayerUse;
.void(void) PlayerUseUnpressed;
.bool iBleeds;
.entity eUser;
.float material;
.float deaths;
.float botinfo;

/* in idTech the .owner field causes collisions to fail against set entity,
 * we don't want this all of the time. so use this as a fallback */
.entity real_owner;

int trace_surfaceflagsi;
string startspot;
string __fullspawndata;

/* damage related tempglobals, like trace_* */
entity g_dmg_eAttacker;
entity g_dmg_eTarget;
int g_dmg_iDamage;
int g_dmg_iRealDamage;
bodyType_t g_dmg_iHitBody;
int g_dmg_iFlags;
int g_dmg_iWeapon;
vector g_dmg_vecLocation;

var bool g_ents_initialized = FALSE;

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

NSEntity EntityDef_SpawnClassname(string className);
NSEntity EntityDef_CreateClassname(string className);
NSEntity Entity_CreateClass(string className);
