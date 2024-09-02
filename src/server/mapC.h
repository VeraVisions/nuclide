/*
 * Copyright (c) 2024 Vera Visions LLC.
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

#pragma target fte_5768
#define QWSSQC

/* MapProgs are map specific QuakeC progs.
   Include this file with YOUR MapProgs! */

#include "../shared/fteextensions.qc"
#include "../shared/global.h"
#include "mapC_math.h"
#include "mapC_weapons.h"

.float deaths;

/** @defgroup mapc MapC
    @brief MapC/Shared Game-Logic API
    @ingroup multiprogs

APIs used by MapC progs and the server progs exclusively.

@{
*/

/** Spawns an entity of a specific class.

This is the primary, encouraged method of spawning entities in MapC.
If you don't spawn an entity class using this, it will not respond to sendInput().

If a specified class does not exist, it will create an info_notnull type entity, but with the new, desired classname.

The only time when this function returns __NULL__ is if the server is unable to allocated any more entities.

@param className is the type of class to be instantiated.
@param desiredPos is the world position at which the new entity will be placed. */
entity
spawnClass(string className, vector desiredPos)
{
	entity(string, vector) spawnFunc = externvalue(0, "spawnClass");
	return spawnFunc(className, desiredPos);
}

bool
changeClass(entity target, string newClass)
{
	bool(entity, string) spawnFunc = externvalue(0, "changeClass");
	return spawnFunc(target, newClass);
}

bool
cacheEntityDef(string className)
{
	bool(string) spawnFunc = externvalue(0, "EntityDef_Precache");
	return spawnFunc(className);
}

/** Sends an input (See NSIO::Input) to an entity.

While you're able to manipulate entities in most ways using bare MapC, you might want to change Nuclide specific attributes of them as well. This can only be done using the I/O system.

For the variety of inputs an entity supports, please look at the respective entity-specific documentation.

@param target is the entity which will receive the input
@param inputName is the name of the input. E.g. "SetOrigin"
@param dataString contains parameters for the input. E.g. "0 0 0"
@param activator references which entity is "responsible" for triggering this input. */
void
sendInput(entity target, string inputName, string dataString, entity activator)
{
	void(entity, string, string, entity) inputFunc = externvalue(0, "sendInput");
	inputFunc(target, inputName, dataString, activator);
}

/** Applies damage to a given entity.
Requires the use of damageDef/entityDef since we're run out of parameters in QuakeC.

@param targetEnt is the entity receiving the damage.
@param inflictingEnt is the entity causing the damage (e.g. a projectile, rocket)
@param attackingEnt is the entity owning up to the damage.
@param damageDef is the damageDef containing all the info, including damage points
@param weaponDef is (if not "") the name of the weapon causing the damage.
@param damageOrigin is the location where the damage comes from.
@param damageDir is the direction the damage is coming from.
@param hitLocation is the final hit location, where the damage is applied. */
void
entityDamage(entity targetEnt, entity inflictingEnt, entity attackingEnt, string damageDef, string weaponDef, vector damageOrigin, vector damageDir, vector hitLocation)
{
	void(entity,entity,entity,string,string,vector,vector,vector) checkFunc = externvalue(0, "entityDamage");
	return checkFunc(targetEnt, inflictingEnt, attackingEnt, damageDef, weaponDef, damageOrigin, damageDir, hitLocation);
}

/** Does damage to all entities within a specified radius with a linear falloff.
If a negative damageMax value is supplied, then no collision checks will be performed.
So radiusDamage calls will not be obstructed by level or entity geometry.

@param damageCenter is the location of the center, at which the wave originates.
@param damageRange is the radius (in game units) of the wave.
@param damageMax is the maximum damage that can be done by this wave.
@param damageMin is the minimum amount of damage done, at the very edge.
@param attackingEnt is the entity owning up to the damage. */
void
radiusDamage(vector damageCenter, float damageRange, int damageMin, int damageMax, entity attackingEnt)
{
	void(vector, float, int, int, entity) checkFunc = externvalue(0, "radiusDamage");
	return checkFunc(damageCenter, damageRange, damageMin, damageMax, attackingEnt);
}


/** Returns true/false depending on if the entity is an AI character.

@param entityToCheck specifies the entity to check.*/
bool
isAI(entity entityToCheck)
{
	bool(entity) checkFunc = externvalue(0, "isAI");
	return checkFunc(entityToCheck);
}

/** Returns true/false depending on if the entity is alive.

@param entityToCheck specifies the entity to check.*/
bool
isAlive(entity entityToCheck)
{
	bool(entity) checkFunc = externvalue(0, "isAlive");
	return checkFunc(entityToCheck);
}

/** Returns true/false depending on if the entity is in "god" mode.

@param entityToCheck specifies the entity to check.*/
bool
isGodMode(entity entityToCheck)
{
	bool(entity) checkFunc = externvalue(0, "isGodMode");
	return checkFunc(entityToCheck);
}

/** Returns true/false depending on if the entity is a player.

@param entityToCheck specifies the entity to check.*/
bool
isPlayer(entity entityToCheck)
{
	bool(entity) checkFunc = externvalue(0, "isPlayer");
	return checkFunc(entityToCheck);
}

/** Returns true/false depending on if the entity is either a player, or AI character.

@param entityToCheck specifies the entity to check.*/
bool
isSentient(entity entityToCheck)
{
	bool(entity) checkFunc = externvalue(0, "isSentient");
	return checkFunc(entityToCheck);
}

/** Returns true/false depending on if the entity is a bot.

@param entityToCheck specifies the entity to check.*/
bool
isBot(entity entityToCheck)
{
	bool(entity) checkFunc = externvalue(0, "isBot");
	return checkFunc(entityToCheck);
}

/* misc helper functions. */

/** Returns the current time.

@param realTime specifies the time in seconds since 01/01/1970.
@param zoneType specifies the time zone to use. 0 = UTC, 1 = Local.
@param formatString is a C-language, strftime styled string setting the output format 
@return Euler-angles generated from the input. */
string
timeToString(int realTime, int zoneType, string formatString)
{
	/* supposed to take extra (optional parameters...) */
	if (zoneType == 1i) {
		return strftime(true, formatString);
	} else {
		return strftime(true, formatString);
	}
}

/** Returns the the value of a console variable.

@param cvarName specifies the console variable to query.
@return The value in string format. */
string
getCvar(string cvarName)
{
	return cvar_string(cvarName);
}

/** Returns the the value of a console variable.

@param cvarName specifies the console variable to query.
@return The value in integer format. */
int
getCvarInt(string cvarName)
{
	return (int)cvar(cvarName);
}

/** Returns the the value of a console variable.

@param cvarName specifies the console variable to query.
@return The value in integer format. */
bool
fileExists(string fileName)
{
	bool(string) checkFunc = externvalue(0, "fileExists");
	return checkFunc(fileName);
}

/** Sets the specified serverinfo key to a set value.

@param serverKey specifies the serverinfo key to set.
@param setValue specifies the value of said key. */
void
setServerInfo(string serverKey, string setValue)
{
	void(string, string) checkFunc = externvalue(0, "setServerInfo");
	checkFunc(serverKey, setValue);
}

/** Returns the the value of a serverinfo key.

@param serverKey specifies the serverinfo key to query.
@return The value in string format. */
string
getServerInfo(string serverKey)
{
	string(string) checkFunc = externvalue(0, "getServerInfo");
	return checkFunc(serverKey);
}

/** Sets the specified userinfo key to a set value.

@param clientEntity specifies the client to poke.
@param userKey specifies the userinfo key to set.
@param setValue specifies the value of said key. */
void
setUserInfo(entity clientEntity, string userKey, string setValue)
{
	void(entity, string, string) checkFunc = externvalue(0, "setUserInfo");
	checkFunc(clientEntity, userKey, setValue);
}

/** Returns the the value of a userinfo key.

@param clientEntity specifies the client to peek at.
@param userKey specifies the userinfo key to query.
@return The value in string format. */
string
getUserInfo(entity clientEntity, string userKey)
{
	string(entity, string) checkFunc = externvalue(0, "getUserInfo");
	return checkFunc(clientEntity, userKey);
}

entity
getSpawnpoint(string className)
{
	entity(string) checkFunc = externvalue(0, "Spawn_SelectRandom");
	return checkFunc(className);
}

entity
placeSpawnpoint(entity targetEntity)
{
	entity(entity) checkFunc = externvalue(0, "placeSpawnpoint");
	return checkFunc(targetEntity);
}

void
obituary(string A, string B, string C, string D)
{
	void(string, string, string, string) checkFunc = externvalue(0, "obituary");
	checkFunc(A,B,C,D);
}

void
damage(entity targetEntity, entity inflictingEntity, entity attackingEntity, int damagePoints, int damageFlags, string meansOfDeath, string weaponDef, vector damageOrigin, vector damageDir, string hitLocation, float timeOffset)
{

}

/** @} */ // end of multiprogs