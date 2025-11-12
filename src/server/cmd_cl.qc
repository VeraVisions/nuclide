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

static vector
Cmd_GetViewPoint(ncPlayer viewEnt)
{
	vector traceStart;
	vector traceEnd;

	traceStart = self.origin + self.view_ofs;
	makevectors(self.v_angle);
	traceEnd = traceStart + (v_forward * 4096);
	traceline(traceStart, traceEnd, MOVE_HITMODEL, self);
	return (trace_endpos);
}

/** Finds an entity based on targetname first, then classname. */
static ncEntity
Cmd_FindEntityByIdentifier(string identifierString)
{
	for (entity entEnum = world; (entEnum = find(entEnum, ::targetname, identifierString));) {
		return (entEnum);
	}
	for (entity entEnum = world; (entEnum = find(entEnum, ::classname, identifierString));) {
		return (entEnum);
	}

	return (__NULL__);
}

bool
Cmd_ParseClientCommand(ncClient sender, string cmd, int commandArguments)
{
	string identStr;
	string inputName;
	string dataString;
	float secondsDelay;
	vector targetOrg;

	switch (argv(0)) {
	case "say":
		if (commandArguments == 2) {
			g_grMode.ChatMessageAll(sender, argv(1));
		} else {
			g_grMode.ChatMessageAll(sender, substring(cmd, 4, -1));
		}
		break;
	case "say_team":
		if (commandArguments == 2) {
			g_grMode.ChatMessageTeam(sender, argv(1));
		} else {
			g_grMode.ChatMessageTeam(sender, substring(cmd, 9, -1));
		}
		break;
#if 0
	case "spectate":
		if (is.Player(sender)) {
			break;
		}

		ncPlayer pl = (ncPlayer)sender;
		pl.MakeSpectator();
		break;
	case "play":
		if (sender.classname != "spectator") {
			break;
		}

		EntityDef_SpawnClassname("player");
		PutClientInServer();
		break;
#endif
	case "timeleft":
		string timestring;
		float timeleft;
		timeleft = cvar("timelimit") - (time / 60);
		timestring = Util_TimeToString(timeleft);
		bprint(PRINT_CHAT, sprintf("we have %s minutes remaining", timestring));
		break;
	case "joinTeam":
		g_grMode.PlayerRequestTeam((ncPlayer)sender, (int)stoi(argv(1)));
		break;
	/* somewhat cheaty commands */
	case "setpos":
		if (!serverinfo.GetBool("cheats"))
			break;
		
		printf("%i %S\n", commandArguments, cmd);
		if (cvar("sv_cheats") == 1) {
			if (commandArguments == 2) { /* setpos "0 0 0" */
				setorigin(sender, stov(argv(1)));
			} else if (commandArguments == 3) {  /* setpos "0 0 0" "0 0 0" */
				setorigin(sender, stov(argv(1)));
			} else if (commandArguments == 4) { /* setpos 0 0 0 */
				setorigin(sender, [stof(argv(1)), stof(argv(2)), stof(argv(3))]);
			} else if (commandArguments == 7) { /* setpos 0 0 0 0 0 0 */
				setorigin(sender, [stof(argv(1)), stof(argv(2)), stof(argv(3))]);
			}
		}

		break;
	case "listInventory":
		if (!cvars.GetBool("sv_cheats"))
			break;

		ncActor_ListInventory(sender);
		break;
	case "giveInventoryItem":
		if (cvars.GetBool("sv_cheats"))
			(ncActor)sender.GiveNamedItem(argv(1));
		break;
	case "removeInventoryItem":
		if (cvars.GetBool("sv_cheats"))
			(ncActor)sender.RemoveNamedItem(argv(1));
		break;
	case "removeAllInventoryItems":
		if (cvars.GetBool("sv_cheats"))
			(ncActor)sender.RemoveAllItems(false);
		break;
	case "listAmmo":
		if (!cvars.GetBool("sv_cheats"))
			break;

		Ammo_DebugList();
		break;
	/* ent_crate <classname> [key value ...] */
	case "ent_create":
		if (!cvars.GetBool("sv_cheats"))
			break;

		__fullspawndata = "{\n";
		string spawnClass = argv(1);

		if (!STRING_SET(spawnClass)) {
			break;
		}
		
		ncEntity resultingEntity = spawn(ncEntity);

		for (int i = 2; i < commandArguments; i+=2) {
			string keyName = argv(i);
			string setValue = argv(i+1);
			__fullspawndata = sprintf("%s%S %S\n", __fullspawndata, keyName, setValue);
		}
		resultingEntity.m_rawSpawnData = __fullspawndata = sprintf("%s}\n", __fullspawndata);
		targetOrg = Cmd_GetViewPoint((ncPlayer)sender);

		ncLogAlways("spawning %S at %v with spawn data:\n%s", spawnClass, targetOrg, __fullspawndata);

		entity oldSelf = self;
		self = resultingEntity;
		EntityDef_SpawnClassname(spawnClass);
		self = oldSelf;
		resultingEntity.SetOrigin(targetOrg);
		break;
	/* ent_fire <classname_or_targetname> <input_name> [data] [delay] */
	case "ent_fire":
		if (!cvars.GetBool("sv_cheats"))
			break;

		identStr = argv(1);
		inputName = argv(2);
		dataString = argv(3);
		secondsDelay = stof(argv(4));

		if (!STRING_SET(identStr)) {
			break;
		}

		for (entity entEnum = world; (entEnum = find(entEnum, ::targetname, identStr));) {
			ents.InputDelayed(entEnum, inputName, dataString, sender, secondsDelay);
		}
		for (entity entEnum = world; (entEnum = find(entEnum, ::classname, identStr));) {
			ents.InputDelayed(entEnum, inputName, dataString, sender, secondsDelay);
		}

		break;
	/* ent_remove <classname_or_targetname> */
	case "ent_remove":
		if (!cvars.GetBool("sv_cheats"))
			break;

		identStr = argv(1);

		if (!STRING_SET(identStr)) {
			break;
		}

		ncEntity toRemove = Cmd_FindEntityByIdentifier(identStr);

		if (toRemove) {
			toRemove.Destroy();
		}
		break;
	/* ent_remove_all <classname_or_targetname> <input_name> [data] [delay] */
	case "ent_remove_all":
		if (!cvars.GetBool("sv_cheats"))
			break;

		identStr = argv(1);

		if (!STRING_SET(identStr)) {
			break;
		}

		for (ncEntity entEnum = 0; (entEnum = (ncEntity)find(entEnum, ::targetname, identStr));) {
			entEnum.Destroy();
		}
		for (ncEntity entEnum = 0; (entEnum = (ncEntity)find(entEnum, ::classname, identStr));) {
			entEnum.Destroy();
		}
		break;
	/* ent_teleport <classname_or_targetname> */
	case "ent_teleport":
		if (!cvars.GetBool("sv_cheats"))
			break;

		identStr = argv(1);

		if (!STRING_SET(identStr)) {
			break;
		}

		targetOrg = Cmd_GetViewPoint((ncPlayer)sender);
		
		for (ncEntity entEnum = 0; (entEnum = (ncEntity)find(entEnum, ::targetname, identStr));) {
			entEnum.SetOrigin(targetOrg);
		}
		for (ncEntity entEnum = 0; (entEnum = (ncEntity)find(entEnum, ::classname, identStr));) {
			entEnum.SetOrigin(targetOrg);
		}
		break;
	default:
		clientcommand(sender, cmd);
	}
}
