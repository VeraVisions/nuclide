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

static void
CMD_TraceMaterial(void)
{
	vector traceStart;
	vector traceEnd;
	string textureName;

	traceStart = self.origin + self.view_ofs;
	makevectors(self.v_angle);
	traceEnd = traceStart + (v_forward * 4096);
	traceline(traceStart, traceEnd, MOVE_HITMODEL, self);

	trace_surface_id = getsurfacenearpoint(trace_ent, trace_endpos);
	trace_surfacename = getsurfacetexture(trace_ent, trace_surface_id);

	printf("trace_allsolid: %g\n", trace_allsolid);
	printf("trace_startsolid: %g\n", trace_startsolid);
	printf("trace_fraction: %f\n", trace_fraction);
	printf("trace_endpos: %v\n", trace_endpos);
	printf("trace_plane_normal: %v\n", trace_plane_normal);
	printf("trace_plane_dist: %f\n", trace_plane_dist);
	printf("trace_inopen: %g\n", trace_inopen);
	printf("trace_inwater: %g\n", trace_inwater);
	printf("trace_endcontents: %i\n",  trace_endcontentsi);
	printf("trace_surfaceflags: %i\n",  trace_surfaceflagsi);
	printf("trace_brush_id: %i\n",  trace_brush_id);
	printf("trace_brush_faceid: %i\n",  trace_brush_faceid);
	printf("trace_surface_id: %i\n",  trace_surface_id);
	printf("trace_bone_id: %i\n",  trace_bone_id);
	printf("trace_triangle_id: %i\n",  trace_triangle_id);
	printf("trace_surfacename: %S\n",  trace_surfacename);

	if (trace_surface_id == 0) {
		printf("Unable to trace against a valid surface.\n");
		return;
	}

	textureName = getsurfacetexture(trace_ent, trace_surface_id);
	localcmd(sprintf("r_showshader %S\n", textureName));
}

static void
CMD_AddBot(void)
{
	string botProfile = strtolower(argv(1));
	float teamValue = stof(argv(2));
	float spawnDelay = stof(argv(3));
	string newName = argv(4);
	Bot_AddBot_f(botProfile, teamValue, spawnDelay, newName);
}

static void
CMD_KillClass(void)
{
	string targetClass;
	targetClass = argv(1);

	if (targetClass)
	for (entity a = world; (a = find(a, ::classname, targetClass));) {
		ncEntity t = (ncEntity)a;
		t.Destroy();
	}
}

static void
CMD_KillMovables(void)
{
		for (entity a = world; (a = findfloat(a, ::movetype, MOVETYPE_PHYSICS));) {
			ncEntity t = (ncEntity)a;
			t.Destroy();
		}
}

static void
CMD_Trigger(void)
{
	string targ;
	targ = argv(1);

	if (!STRING_SET(targ)) {
		printf("No target to 'trigger' specified. Try names listed in ^3]listTargets^7\n");
		return;
	}

	for (entity a = world; (a = find(a, ::targetname, targ));) {
		ncEntity t = (ncEntity)a;

		if (t.Trigger)
			t.Trigger(self, TRIG_TOGGLE);
	}
}

static void
CMD_Input(void)
{
	float entNum = stof(argv(1));
	string inputName = argv(2);
	string inputData = argv(3);
	ncEntity inputTarget = (ncEntity)edict_num(entNum);

	if (inputTarget) {
		inputTarget.Input(self, inputName, inputData);
		printf("Sending input to %d, %S: %S\n", entNum, inputName, inputData);
	}
}

static void
CMD_ListTargets(void)
{
	for (entity a = world; (a = findfloat(a, ::identity, 1));) {
		if (a.targetname) {
			printf("%d: %s (%s)\n", num_for_edict(a), a.targetname, a.classname);
		}
	}
}

static void
CMD_Teleport(void)
{
	static entity targetFinder;
	targetFinder = find(targetFinder, ::targetname, argv(1));

	/* try at least one more time to skip world */
	if (!targetFinder)
		targetFinder = find(targetFinder, ::targetname, argv(1));

	if (targetFinder)
		setorigin(self, targetFinder.origin);
}

static void
CMD_TeleportToClass(void)
{
	static entity finder;
	finder = find(finder, ::classname, argv(1));

	/* try at least one more time to skip world */
	if (!finder)
		finder = find(finder, ::classname, argv(1));

	if (finder)
		setorigin(self, finder.origin);
}

static void
CMD_RenetworkEntities(void)
{
	for (entity a = world; (a = findfloat(a, ::identity, 1));) {
		ncEntity ent = (ncEntity)a;
		ent.SendFlags = -1;
	}
}

static void
CMD_RespawnEntities(void)
{
	for (entity a = world; (a = findfloat(a, ::_mapspawned, true));) {
		ncEntity ent = (ncEntity)a;
		ent.Respawn();
	}
}

static void
CMD_Spawn(void)
{
	ncEntity unit = EntityDef_CreateClassname(argv(1));
	makevectors(self.v_angle);
	traceline(self.origin, self.origin + (v_forward * 1024), MOVE_NORMAL, self);
	setorigin(unit, trace_endpos);
}

static void
CMD_PropSpawn(void)
{
	string newModel = argv(1);
	makevectors(self.v_angle);
	traceline(self.origin, self.origin + (v_forward * 1024), MOVE_NORMAL, self);

	prop_physics newProp = spawn(prop_physics);
	newProp.SetModel(newModel);
	newProp.SetOriginUnstick(trace_endpos + [0,0,32]);
	newProp.Spawn();
	newProp.SetModel(newModel);
	newProp.SetOriginUnstick(trace_endpos + [0,0,32]);
	newProp.ClearVelocity();
	newProp.Wake();
}

static void
CMD_SetLightStyle(void)
{
	lightstyle(stof(argv(1)), argv(2));
}

static void
CMD_ListSpawnData(void)
{
	string entString = argv(1);
	float entNum = stof(entString);
	ncEntity foundEnt = (ncEntity)edict_num(entNum);

	if (!STRING_SET(entString)) {
		makevectors(self.v_angle);
		traceline(self.origin + self.view_ofs, self.origin + self.view_ofs + (v_forward * 4096.0f), MOVE_NORMAL, self);

		if (trace_ent) {
			foundEnt = (ncEntity)trace_ent;
		} else {
			printf("Entity neither specified nor in-front.\n");
		}
	}

	if (foundEnt) {
		printf("Spawn data for %s (%d):\n{\n", foundEnt.classname, entNum);

		for (int i = 1; i < (tokenize(foundEnt.m_rawSpawnData) - 1); i += 2) {
			printf("\t%S\t\t%S\n", argv(i), argv(i+1));
		}

		printf("}\n");
	} else
		printf("Unable to find entity with ID %S\n", entString);
}

static void
CMD_ListEntityData(void)
{
	string entString = argv(1);
	float entNum = stof(entString);
	ncEntity foundEnt = (ncEntity)edict_num(entNum);

	if (!STRING_SET(entString)) {
		makevectors(self.v_angle);
		traceline(self.origin + self.view_ofs, self.origin + self.view_ofs + (v_forward * 4096.0f), MOVE_NORMAL, self);

		if (trace_ent) {
			foundEnt = (ncEntity)trace_ent;
		} else {
			printf("Entity neither specified nor in-front.\n");
		}
	}

	if (foundEnt) {
		printf("Entity data for %s (%d):\n{\n", foundEnt.classname, entNum);
		eprint(foundEnt);
	} else
		printf("Unable to find entity with ID %S\n", entString);
}



static void
CMD_ListEntitiesByClass(void)
{
	string entString = argv(1);
	float entNum = stof(entString);

	if (!STRING_SET(entString)) {
		printf("Specify a classname. E.g. func_wall\n");
	}

	for (entity e = world; (e = find(e, ::classname, entString));) {
		printf("\t(%d) %v (mins: %v; maxs: %v)\n", num_for_edict(e), e.origin, e.mins, e.maxs);
	}
}

bool
Cmd_ParseServerCommand(void)
{
	switch (argv(0)) {
	case "addon":
		CMD_Addon_f();
		break;
	case "addBot":
		CMD_AddBot();
		break;
	case "killAllBots":
		Bot_KillAllBots();
		break;
	case "resetAllBotsGoals":
		Bot_ResetAllBotsGoals();
		break;
	case "listBotProfiles":
		Bot_ListBotProfiles_f();
		break;
	case "killClass":
		CMD_KillClass();
		break;
	case "killMovables":
		CMD_KillMovables();
		break;
	case "trigger":
		CMD_Trigger();
		break;
	case "input":
		CMD_Input();
		break;
	case "listTargets":
		CMD_ListTargets();
		break;
	case "teleport":
		CMD_Teleport();
		break;
	case "teleportToClass":
		CMD_TeleportToClass();
		break;
	case "renetworkEntities":
		CMD_RenetworkEntities();
		break;
	case "respawnEntities":
		CMD_RespawnEntities();
		break;
	case "spawnDef":
		CMD_Spawn();
		break;
	case "propSpawn":
		CMD_PropSpawn();
		break;
#ifdef BOT_INCLUDED
	case "way":
		ncNodeEditor::Cmd();
		break;
#endif
	case "listEntityDef":
		EntityDef_DebugList();
		break;
	case "listSoundDef":
		SoundDef_DebugList();
		break;
	case "listMapTweaks":
		MapTweak_ListActive();
		break;
	case "traceMaterial":
		CMD_TraceMaterial();
		break;
	case "setLightStyle":
		CMD_SetLightStyle();
		break;
	case "listEntitySpawnData":
		CMD_ListSpawnData();
		break;
	case "listEntityData":
		CMD_ListEntityData();
		break;
	case "listEntitiesByClass":
		CMD_ListEntitiesByClass();
		break;
	case "setGlobal":
		ncSessionManager::SetGlobal(argv(1), argv(2));
		break;
	case "listGlobals":
		ncSessionManager::ListGlobals();
		break;
	default:
		return (false);
	}
	return (true);
}
