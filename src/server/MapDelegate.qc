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

static ncEntity
SpawnEntityWithSpawnData(string entityClass, string spawnData)
{
	entity oldSelf = self;
	ncEntity newEntity = spawn();

	__fullspawndata = spawnData;
	self = newEntity;
	newEntity.classname = entityClass;
	newEntity.m_rawSpawnData = __fullspawndata;
	newEntity._mapspawned = true;
	newEntity = EntityDef_SpawnClassname(entityClass);
	__fullspawndata = __NULL__;

	if (newEntity) {
		newEntity.Spawn();
	}

	self = oldSelf;
	return (newEntity);
}

bool
ncMapDelegate::AppendEntitiesFromFile( string fileName )
{
	filestream addEntitiesFileStream;
	string temp;
	int c = 0;
	int mp = 0;
	bool isBraced = false;
	string desiredClass = __NULL__;
	string constructedSpawnData = __NULL__;
	string gameTypeFilter = __NULL__;

	addEntitiesFileStream = fopen(fileName, FILE_READ);

	if (addEntitiesFileStream < 0) {
		ncWarning("Can't append entities from %S", fileName);
		return (false);
	}

	while ((temp = fgets(addEntitiesFileStream))) {
		c = tokenize_console(temp);
		
		switch(argv(0)) {
		case "{":
			isBraced = true;
			constructedSpawnData = "{\n";
			break;
		case "}":
			/* skip broken syntax */
			if (isBraced == false) {
				break;
			}
			if (STRING_SET(desiredClass)) {
				constructedSpawnData = sprintf("%s}", constructedSpawnData);
				ncEntity newEntity = SpawnEntityWithSpawnData(desiredClass, constructedSpawnData);
				ncLog("imported %S @ %v, %v", newEntity.classname, newEntity.origin, newEntity.angles);
				constructedSpawnData = "";
				desiredClass = "";
				isBraced = false;
			}
			break;
		case "classname":
			if (isBraced == true) {
				desiredClass = argv(1);
			}
			break;
		default:
			if (isBraced == true) {
				/* append string entry after another */
				constructedSpawnData = sprintf("%s%s\n", constructedSpawnData, temp);
			}
		}
	}

	fclose(addEntitiesFileStream);
	return (true);
}

void
ncMapDelegate::InitialRespawn(void)
{
	/* append entities from external .add file */
	string appendEntitiesFile = strcat("maps/", mapname, ".add");
	if (fileExists(appendEntitiesFile)) {
		ncLog("Loading extra entities for %s from %S", mapname, appendEntitiesFile);
		ncMapDelegate::AppendEntitiesFromFile(appendEntitiesFile);
	} else {
		ncLog("No entity additions exist for %s under %S", mapname, appendEntitiesFile);
	}
}
