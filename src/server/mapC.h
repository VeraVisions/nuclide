#pragma target fte_5768
#define QWSSQC

/* MapProgs are map specific QuakeC progs.
   Include this file with YOUR MapProgs! */

#include "../shared/fteextensions.qc"
#include "../shared/global.h"
#include "../shared/math.h"
#include "../shared/math_vector.h"

#define entity_def(x, ...) const string x[] = { __VA_ARGS__ }

/** Calls a function (with parameters) in a new thread. */
#define thread(x) if (fork()) { x; abort(); }

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
	entity(string, vector) spawnFunc = externvalue(0, "MapC_CreateEntityClass");
	return spawnFunc(className, desiredPos);
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
	void(entity, entity, string, string) inputFunc = externvalue(0, "MapC_SendEntityInput");
	inputFunc(target, activator, inputName, setValue);
}

/** Does damage to all entities within a specified radius with a linear falloff.

@param position specifies the position at which the damage event occurs.
@param radius specifies the radius in game units.
@param maxDamage the maximum amount of damage this event can do.
@param minDamage the damage done to the entities on the outer-most rim of the radius.
@param attacker (optional) the source of the attack, defaults to world */
void
radiusDamage(vector position, float radius, int maxDamage, int minDamage, optional entity attacker)
{
	void(vector, float, int, int, entity) damageFunc = externvalue(0, "MapC_RadiusDamage");
	damageFunc(position, radius, maxDamage, minDamage, attacker);
}

/** Returns true/false depending on if the entity is an AI character.

@param entityToCheck specifies the entity to check.*/
bool
isAI(entity entityToCheck)
{
	bool(entity) checkFunc = externvalue(0, "MapC_IsAI");
	return checkFunc(entityToCheck);
}

/** Returns true/false depending on if the entity is alive.

@param entityToCheck specifies the entity to check.*/
bool
isAlive(entity entityToCheck)
{
	bool(entity) checkFunc = externvalue(0, "MapC_IsAlive");
	return checkFunc(entityToCheck);
}

/** Returns true/false depending on if the entity is in "god" mode.

@param entityToCheck specifies the entity to check.*/
bool
isGodMode(entity entityToCheck)
{
	bool(entity) checkFunc = externvalue(0, "MapC_IsGodMode");
	return checkFunc(entityToCheck);
}

/** Returns true/false depending on if the entity is a player.

@param entityToCheck specifies the entity to check.*/
bool
isPlayer(entity entityToCheck)
{
	bool(entity) checkFunc = externvalue(0, "MapC_IsPlayer");
	return checkFunc(entityToCheck);
}

/** Returns true/false depending on if the entity is either a player, or AI character.

@param entityToCheck specifies the entity to check.*/
bool
isSentient(entity entityToCheck)
{
	bool(entity) checkFunc = externvalue(0, "MapC_IsSentient");
	return checkFunc(entityToCheck);
}
