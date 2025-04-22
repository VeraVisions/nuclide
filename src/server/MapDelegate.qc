/*
 * Copyright (c) 2023-2025 Vera Visions LLC.
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

void
ncMapDelegate::ncMapDelegate(void)
{
}

void
ncMapDelegate::Input(entity eAct, string strInput, string strData)
{
}

void
ncMapDelegate::Precache(void)
{
}

void
ncMapDelegate::FrameStart(void)
{

}

void
ncMapDelegate::PlayerConnect(ncPlayer pl)
{

}
void
ncMapDelegate::PlayerDisconnect(ncPlayer pl)
{
}

void
ncMapDelegate::NPCDeath(ncActor npc, ncEntity attacker, ncEntity inflictor)
{
}

void
ncMapDelegate::PlayerDeath(ncPlayer deadPlayer, ncEntity inflictor, ncEntity attacker, string weaponDef)
{
}

void
ncMapDelegate::PlayerPain(ncPlayer pl, ncActor attacker, ncDict damageDecl)
{
}

void
ncMapDelegate::PlayerSpawn(ncPlayer pl)
{
}


ncMapDelegate
ncMapDelegate::ActiveInstance(void)
{
	return (g_grMap);
}

void
ncMapDelegate::LinkProgs(void)
{
	ncMapDelegate newRule = spawn(ncMapDelegate);

	if (g_mapCProgs) {
		MAPLINK(newRule, Input, "CodeCallback_Input")
		MAPLINK(newRule, Precache, "CodeCallback_Precache")
		MAPLINK(newRule, FrameStart, "CodeCallback_FrameStart")
		MAPLINK(newRule, PlayerConnect, "CodeCallback_PlayerConnect")
		MAPLINK(newRule, PlayerDisconnect, "CodeCallback_PlayerDisconnect")
		MAPLINK(newRule, PlayerDeath, "CodeCallback_PlayerKilled")
		MAPLINK(newRule, NPCDeath, "CodeCallback_NPCKilled")
		MAPLINK(newRule, PlayerPain, "CodeCallback_PlayerDamage")
		MAPLINK(newRule, PlayerSpawn, "CodeCallback_PlayerSpawn")
	}

	g_grMap = newRule;
}

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
		ncLog("No MapC for level %s loaded. (%s)", cvar_string("mapname"), mapProgs);
		return;
	}

	ncLog("...adding MapC progs %S", mapProgs);
	g_mapCProgs = addprogs(mapProgs);

	if (g_mapCProgs > 0) {
		void(void) mainFunction;
		mainFunction = externvalue(g_mapCProgs, "main");

		if (mainFunction) {
			mainFunction();
		} else {
			ncError("%s does not have a main function.", mapProgs);
		}
	}
}
