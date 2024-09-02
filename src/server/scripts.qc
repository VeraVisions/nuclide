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

/* Map specific Scripting, nicknamed 'MapC' after TF2's cancelled system */
var float g_mapCProgs;
void
MapC_Init(void)
{
	string mapProgs;

	/* mapname global is not set yet in init() */
	mapProgs = sprintf("maps/%s.dat", cvar_string("mapname"));

	/* No mapname.dat, exit out */
	if (fileExists(mapProgs) == false) {
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

/* Gamerule specific Scripting, nicknamed 'RuleC'. */
bool
RuleC_CallFunc(float progsNum, entity pl, string funcName)
{
	if (progsNum) {
		void(void) mainFunction;
		mainFunction = externvalue(progsNum, funcName);

		if (mainFunction) {
			entity oldSelf = self;
			//externset(progsNum, pl, "self");
			self = pl;
			mainFunction();
			self = oldSelf;
			return (true);
		}
	}

	return (false);
}

bool
RuleC_CallDamage(float progsNum, entity target, entity inflictor, entity attacker, string weapon, string funcName)
{
	if (progsNum) {
		void(entity inflictor, entity attacker, string weapon) mainFunction;
		mainFunction = externvalue(progsNum, funcName);

		if (mainFunction) {
			entity oldSelf = self;
			externset(progsNum, target, "self");
			self = target;
			mainFunction(inflictor, attacker, weapon);
			self = oldSelf;
			forceinfokey(target, "*deaths", ftos(target.deaths));
			return (true);
		}
	}

	return (false);
}

bool
RuleC_CallRequestSpawn(float progsNum, entity pl, string funcName)
{
	bool returnValue = false;

	if (progsNum) {
		bool(void) mainFunction;
		mainFunction = externvalue(progsNum, funcName);

		if (mainFunction) {
			entity oldSelf = self;
			externset(progsNum, pl, "self");
			self = pl;
			returnValue = mainFunction();
			self = oldSelf;
			return (returnValue);
		}
	}

	return (returnValue);
}

bool
RuleC_CallString(float progsNum, entity pl, string targetString, string funcName)
{
	bool returnValue = false;

	if (progsNum) {
		bool(string) mainFunction;
		mainFunction = externvalue(progsNum, funcName);

		if (mainFunction) {
			entity oldSelf = self;
			externset(progsNum, pl, "self");
			self = pl;
			returnValue = mainFunction(targetString);
			self = oldSelf;
			return (returnValue);
		}
	}

	return (returnValue);
}

bool
RuleC_CallFloat(float progsNum, entity pl, float targetFloat, string funcName)
{
	bool returnValue = false;

	if (progsNum) {
		bool(float) mainFunction;
		mainFunction = externvalue(progsNum, funcName);

		if (mainFunction) {
			entity oldSelf = self;
			externset(progsNum, pl, "self");
			self = pl;
			returnValue = mainFunction(targetFloat);
			self = oldSelf;
			return (returnValue);
		}
	}

	return (returnValue);
}
