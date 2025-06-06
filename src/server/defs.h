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

#include "api_func.h"
#include "../shared/api.h"
#include "../shared/entityDef.h"
#include "Output.h"
#include "GameRules.h"
#include "skill.h"
#include "logging.h"

#include "../nav/linkflags.h"
#include "../nav/nodes.h"
#include "../nav/route.h"
#include "../nav/NodeEditor.h"
#include "../nav/way_convert.h"
#include "../nav/NavInfo.h"
#include "../nav/Hint.h"

#include "spawn.h"
#include "AddonDelegate.h"
#include "MapDelegate.h"
#include "plugins.h"
#include "lament.h"
#include "vote.h"
#include "mapcycle.h"
#include "maptweaks.h"
#include "Schedule.h"
#include "SessionManager.h"

#include "CapturePoint.h"
#include "CaptureItem.h"

/* helper macros */
#define EVALUATE_FIELD(fieldname, changedflag) {\
	if (ATTR_CHANGED(fieldname)) {\
		SetSendFlags(changedflag);\
	}\
	SAVE_STATE(fieldname);\
}

#define EVALUATE_VECTOR(fieldname, idx, changedflag) {\
	if (VEC_CHANGED(fieldname, idx)) {\
		SetSendFlags(changedflag);\
	}\
	SAVE_STATE_FIELD(fieldname, idx);\
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
		WriteAngle(MSG_ENTITY, field);\
}

#define SENDENTITY_ENTITY(field, changedflag) {\
	if (flChanged & changedflag)\
		WriteEntity(MSG_ENTITY, field);\
}

#define SENDENTITY_COLOR(field, changedflag) {\
	if (flChanged & changedflag)\
		WriteByte(MSG_ENTITY, field * 255.0);\
}

#define SENDENTITY_MODELINDEX(field, changedflag) {\
	if (flChanged & changedflag)\
		WriteShort(MSG_ENTITY, field);\
}

var bool g_isloading = false;

var bool autocvar_mp_flashlight = true;

void Client_FixAngle(entity, vector);
void Client_ShakeOnce(vector, float, float, float, float);

void Mapcycle_Load(string);

ncEntity eActivator;

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

var bool g_ents_initialized = false;

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


/** When called will turn the entity 'self' into the specified classname.

This is useful for entities that are already in the game, and need to transition into a different type of entity.

@param className is the type of class to be changed to. */
ncEntity EntityDef_SpawnClassname(string className);


/** Spawns an entity of a specific class. If class doesn't exist, returns __NULL__.

@param className is the type of class to be instantiated. */
ncEntity EntityDef_CreateClassname(string className);

/** Spawns an entity of a class, guaranteed to be valid.

This is the primary, encouraged method of spawning entities.
If you don't spawn an entity class using this, it will not respond to sendInput().

If a specified class does not exist, it will create an info_notnull type entity, but with the new, desired classname.

The only time when this function returns __NULL__ is if the game is unable to allocate any more entities.

@param className is the type of class to be instantiated. */
ncEntity Entity_CreateClass(string className);

/** Checks if an entity class was defined in an EntityDef.

You can then use EntityDef_GetKeyValue() to get various key values from said EntityDef.

@param className specifies which class definition to look for. */
bool EntityDef_HasSpawnClass(string className);


/** Retrieves the value of a specific key defined within an EntityDef.

@param className specifies which class definition to look in.
@param keyName specifies the 'key' we want to know its value of. */
string EntityDef_GetKeyValue(string className, string keyName);

void
WriteEntityEvent(float to, entity targetEntity, float eventType)
{
	WriteByte(to, SVC_CGAMEPACKET);
	WriteByte(to, EV_ENTITYEVENT);
	WriteEntity(to, targetEntity);
	WriteFloat(to, eventType);
}

/** @defgroup serverentity Entities that are server-side
 *  @ingroup server
 *  @ingroup entities
 *  Entity classes that run entirely on the server.
 */
