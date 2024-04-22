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

var float g_mapCProgs;
void
MapC_Init(void)
{
	string mapProgs;

	/* mapname global is not set yet in init() */
	mapProgs = sprintf("maps/%s.dat", cvar_string("mapname"));

	/* No mapname.dat, exit out */
	if (FileExists(mapProgs) == false) {
		NSError("MapC for level %s at %S does not exist.", mapname, mapProgs);
		return;
	}

	NSLog("...adding MapC progs %S",mapProgs);
	g_mapCProgs = addprogs(mapProgs);
}

void
MapC_CallMainFunction(void)
{
	void(void) mainFunction;
	mainFunction = externvalue(g_mapCProgs, "main");

	if (mainFunction) {
		externset(g_mapCProgs, world, "self");
		mainFunction();
	} else {
		NSError("%s does not have a main function.", mapname);
	}
}

void
MapC_CallNamedFunction(entity functionActivator, string targetFunction)
{
	void(void) ourFunction;
	ourFunction = externvalue(g_mapCProgs, targetFunction);

	if (ourFunction) {
		externset(g_mapCProgs, functionActivator, "self");
		ourFunction();
	} else {
		NSError("%s does not have a function %s.", mapname, targetFunction);
	}
}

/* Returns a new entity. Guaranteed to be something. Never __NULL__
   unless we're seriously out of memory. */
entity
MapC_CreateEntityClass(string className, vector desiredPos)
{
	NSEntity newEntity = Entity_CreateClass(className);

	/* That class didn't exist, so let's take the base Nuclide one */
	if (!newEntity) {
		newEntity = Entity_CreateClass("NSEntity");
	}

	/* OOM. It's over. */
	if (!newEntity) {
		return __NULL__;
	}

	newEntity.classname = className;
	newEntity.Input(newEntity, "SetSpawnOrigin", vtos(desiredPos));
	newEntity.Input(newEntity, "SetOrigin", vtos(desiredPos));
	newEntity.Respawn();

	return (entity)newEntity;
}

/* Sends an input to the specified target. */
void
MapC_SendEntityInput(vector position, float radius, int maxDamage, int minDamage, optional entity attacker)
{
	
}

/* Damage Category */
void
MapC_RadiusDamage(entity target, entity activator, string inputName, string setValue)
{
	NSEntity targetEntity = (NSEntity)target;
	NSEntity theActivator = (NSEntity)activator;
	targetEntity.Input(theActivator, inputName, setValue);
}

/* Sentient Category */
bool
MapC_IsAI(entity entityToCheck)
{
	if (entityToCheck.flags & FL_MONSTER) {
		return true;
	}

	return false;
}

bool
MapC_IsAlive(entity entityToCheck)
{
	if (entityToCheck.takedamage != DAMAGE_NO) {
		NSSurfacePropEntity livingEnt = (NSSurfacePropEntity)entityToCheck;
		return livingEnt.IsAlive();
	}

	return false;
}

bool
MapC_IsGodMode(entity entityToCheck)
{
	if (entityToCheck.flags & FL_GODMODE) {
		return true;
	}

	return false;
}

bool
MapC_IsPlayer(entity entityToCheck)
{
	if (entityToCheck.flags & FL_CLIENT) {
		NSClient pl = (NSClient)entityToCheck;

		return pl.IsPlayer();
	}

	return false;
}

bool
MapC_IsSentient(entity entityToCheck)
{
	if (MapC_IsAI(entityToCheck) || MapC_IsPlayer(entityToCheck)) {
		return true;
	}

	return false;
}
