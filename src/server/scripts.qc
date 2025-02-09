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
	mapProgs = Util_ChangeExtension(strcat("maps/", cvar_string("mapname")), "dat");

	/* No mapname.dat, exit out */
	if (fileExists(mapProgs) == false) {
		NSLog("No MapC for level %s loaded. (%s)", cvar_string("mapname"), mapProgs);
		return;
	}

	NSLog("...adding MapC progs %S",mapProgs);
	g_mapCProgs = addprogs(mapProgs);

	if (g_mapCProgs > 0) {
		void(void) mainFunction;
		mainFunction = externvalue(g_mapCProgs, "main");

		if (mainFunction) {
			externset(g_mapCProgs, world, "self");
			mainFunction();
		} else {
			NSError("%s does not have a main function.", mapProgs);
		}
	}
}

__weak string
Game_DefaultRules(void)
{
	string gameType = cvars.GetString("g_gametype");

	if (!STRING_SET(gameType)) {
		bool isCoop = cvars.GetBool("coop");
		bool isSingle = (cvars.GetInteger("sv_playerslots") <= 1) ? (true) : (false);
		gameType = (isSingle || isCoop) == (true) ? "singleplayer" : "deathmatch";
	}

	return (gameType);
}

/* Rule specific Scripting, nicknamed 'RuleC' because MapC exists. */
void
RuleC_Init(void)
{
	string gameType = g_ruleCName = Game_DefaultRules();
	string pathToProgs;
	
	pathToProgs = strcat("progs/", gameType, ".dat");

	/* No progs .dat, exit out */
	if (fileExists(pathToProgs) == false) {
		NSError("Progs at %S does not exist.", pathToProgs);
		g_ruleCProgs = 0;
		return;
	}

	g_ruleCProgs = addprogs(pathToProgs);

	if (g_ruleCProgs) {
		void(void) mainFunction;
		mainFunction = externvalue(g_ruleCProgs, "main");

		if (mainFunction) {
			externset(g_ruleCProgs, world, "self");
			mainFunction();
		} else {
			error(sprintf("RuleC %S does not have a main function.", pathToProgs));
		}
	}	
}

void
RuleC_Precache(void)
{
	void(void) mainFunction;
	mainFunction = externvalue(g_ruleCProgs, "CodeCallback_Precache");

	if (mainFunction) {
		externset(g_ruleCProgs, world, "self");
		mainFunction();
	} else {
		NSError("%s does not have a Precache function.", mapname);
	}
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
