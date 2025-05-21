/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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

float(vector org, float radius, vector lightcolours, optional float style, optional string cubemapname, optional float pflags) dynamiclight_spawnstatic2 = #0:dynamiclight_spawnstatic;

void Commandmenu_Open(void);
void Commandmenu_Close(void);

static void
CMD_testLight(void)
{
	float p;
	string cubeTexture = argv(1);

	if (STRING_SET(cubeTexture)) {
		p = dynamiclight_spawnstatic2(g_view.GetCameraOrigin(), 512, [1,1,1], 0, cubeTexture);
		dynamiclight_set(p, LFIELD_ANGLES, g_view.GetCameraAngle());
		dynamiclight_set(p, LFIELD_FLAGS, LFLAG_NORMALMODE | LFLAG_REALTIMEMODE | LFLAG_SHADOWMAP);
		dynamiclight_set(p, LFIELD_STYLE, 64);
	} else {
		p = dynamiclight_spawnstatic2(g_view.GetCameraOrigin(), 512, [1,1,1], 0);
		dynamiclight_set(p, LFIELD_STYLE, 2);
	}


}

static void
CMD_testSpotLight(void)
{
	float p;
	string cubeTexture = argv(1);

	if (STRING_SET(cubeTexture)) {
		point_spotlight spot = spawn(point_spotlight);
		spot.SetOrigin(g_view.GetCameraOrigin());
		spot.SetAngles(g_view.GetCameraAngle());
		spot.m_iState = 1;
		spot.SetBeamLength(500.0f);
		spot.SetBeamWidth(256.0f);
		spot.SetRenderColor([255,255,255]);
		spot.SetGlowMaterial("textures/sfx/spot_flare");
		spot.SetBeamMaterial("textures/sfx/spot_cone");
		spot.drawmask = MASK_ENGINE;
		spot.m_nuclideFlags |= VFL_VIDREMOVE;
		spot.SetLightStyle(64);

		env_glow glow = spawn(env_glow);
		glow.SetOrigin(g_view.GetCameraOrigin());
		glow.SetAngles(g_view.GetCameraAngle());
		glow.m_strMaterial = "textures/sfx/flare1";
		glow.drawmask = MASK_ENGINE;
		glow.SetRenderMode(RM_GLOW);
		glow.ReloadVideoResources();
		glow.m_nuclideFlags |= VFL_VIDREMOVE;
	} else {
		p = dynamiclight_spawnstatic2(g_view.GetCameraOrigin(), 512, [1,1,1], 0);
		dynamiclight_set(p, LFIELD_STYLE, 2);
	}


}

static void
CMD_testPointLight(void)
{
	makevectors(g_view.GetCameraAngle());
	traceline(g_view.GetCameraOrigin(), g_view.GetCameraOrigin() + (v_forward * 4096.0f), MOVE_NORMAL, pSeat->m_ePlayer);
	dynamiclight_spawnstatic2(trace_endpos + (v_forward * -16.0f), 1024, [1,1,1]);
}

static void
CMD_dev_modeltest(void)
{
	string modelName = argv(1);

	if (STRING_SET(modelName)) {
		entity mt = spawn();
		mt.drawmask = MASK_ENGINE;
		setmodel(mt, argv(1));
		setsize(mt, [0,0,0], [0,0,0]);
		setorigin(mt, g_view.GetCameraOrigin());
		mt.angles = g_view.GetCameraAngle();
		mt.angles[0] = mt.angles[2] = 0;
	}
}

static void
CMD_dev_sunpos(void)
{
	vector sunpos, sunang;
	vector lepos, leang;

	makevectors(g_view.GetCameraAngle());
	sunpos = v_forward * -1;
	sunang = vectoangles(sunpos);

	makevectors(g_view.GetCameraAngle());
	lepos = v_forward * -1;
	leang = vectoangles(lepos);
	leang[1] -= 180;
	leang[0] *= -1;

	localcmd(sprintf("r_shadows_throwdirection %v\n", sunpos));
	print(sprintf("env_sun: pitch: %d; angle: %d\n", -sunang[0], sunang[1]));
	print(sprintf("light_environment: sunangle: %d; pitch: %d\n", leang[1], leang[0]));
}

static void
CMD_dev_measure(void)
{
	static vector measurepos;

	if (lengthSquared(measurepos) > 0.0f) {
		measurepos = g_view.GetCameraOrigin();
		CSQC_Parse_CenterPrint(sprintf( "First marker set at\n%v", measurepos));
	} else {
		CSQC_Parse_CenterPrint(sprintf("Distance: %d\n", vlen(measurepos - g_view.GetCameraOrigin())));
		measurepos = [0,0,0];
	}
}

static void
CMD_vote(void)
{
	if (argv(1) == "yes") {
		sendevent("VoteY", "");
	} else if (argv(1) == "no") {
		sendevent("VoteN", "");
	}
}

static void
CMD_getpos(void)
{
	printf("setpos %v;setang -%v\n", g_view.GetCameraOrigin(), g_view.GetCameraAngle());
}

static void
CMD_setang(void)
{
    g_view.SetCameraAngle(stov(argv(1)));
    g_view.SetClientAngle(stov(argv(1)));
}

static void
CMD_titles_test(void)
{
	GameMessage_Setup(argv(1), 0);
}

static void
CMD_way_menu(void)
{
	Way_Autoload();
	Textmenu_Call("WAY_MENU");
}

static void
CMD_view_geomtest(void)
{
	printf("geomset %s %s\n", argv(1), argv(2));
	//Weapons_SetGeomset(sprintf("geomset %s %s\n", argv(1), argv(2)));
}

static void
CMD_player_geomtest(void)
{
	setcustomskin(pSeat->m_ePlayer, "", sprintf("geomset %s %s\n", argv(1), argv(2)));
}

void
CMD_Cleardecals(void)
{
	for (entity e = world; (e = find(e, ::classname, "tempdecal"));) {
		ncDecal dcl = (ncDecal)e;
		dcl.m_strShader = "";
	}
}

/* Wishlist: list size and potential vmem usage */
static void
CMD_ListModels(void)
{
	string tmp;
	int i = 0i;
	int actual_count = 0i;

	for (i = -4096; i < 4096; i++) {
		tmp = modelnameforindex(i);

		if (strlen(tmp) > 1) {
			printf("%i %s\n", i, tmp);
			actual_count++;
		}
	}

	printf("\t%i total models loaded\n", actual_count);
}

/* Wishlist: list size and samplerate/bitdepth */
static void
CMD_ListSounds(void)
{
	string tmp;
	int i = 0i;
	int actual_count = 0i;
	float length;
	float total_length = 0.0f;

	for (i = 0; i < 4096; i++) {
		tmp = soundnameforindex(i);
		length = soundlength(tmp);

		if (strlen(tmp) > 1) {
			printf("%i %s (%f seconds)\n", i, tmp, length);
			actual_count++;
			total_length += length;
		}
	}
	printf("\t%i total samples loaded\n", actual_count);
	printf("\t%f seconds worth of samples\n", total_length);
}

static void
CMD_ListParticles(void)
{
	string tmp;
	int i = 0i;
	int actual_count = 0i;

	for (i = -4096; i < 4096; i++) {
		tmp = particleeffectquery(i, 0);

		if (strlen(tmp) > 1) {
			printf("%i %s\n", i, tmp);
			actual_count++;
		}
	}
	printf("\t%i total particles loaded\n", actual_count);
}

static void
CMD_ListTitles(void)
{
	int i = 0i;

	for (i = 0; i < g_titles_count; i++) {
		printf("%s, (x: %d, y: %d)\n", 
			g_titles[i].m_strName, g_titles[i].m_flPosX, g_titles[i].m_flPosY);
		printf("\teffect: %i, fade-in: %f, fade-out: %f\n", 
			g_titles[i].m_iEffect, g_titles[i].m_flFadeIn, g_titles[i].m_flFadeOut);
		printf("\thold-time: %f, fx-time: %f\n", 
			g_titles[i].m_flHoldTime, g_titles[i].m_flFXTime);
		printf("\tcolor 1: %v, color 2: %v\n", 
			g_titles[i].m_vecColor1, g_titles[i].m_vecColor2);
	}
	printf("\t%i total titles loaded\n", g_titles_count);
}

static void
CMD_ListModelFramegroups(void)
{
	string modelName = argv(1);
	float modelIndex = getmodelindex(modelName);
	string temp = "";

	printf("// model: %S\n", modelName);

	print("typedef enum {\n");
	for (int i = 0; i < modelframecount(modelIndex); i++) {
		temp = frametoname(modelIndex, i);
		printf("\t%s = %i,\n", strtoupper(temp), i);
	}
	print("} framegroups_e;\n");
}

void
ncWeapon_SelectWeapon(ncWeapon nextWeapon)
{
	if (!nextWeapon) {
		pSeat->m_iHUDWeaponSelected = 0i;
		return;
	}

	/* this gets passed in ncPlayer::ClientInputFrame() to the server */
	pSeat->m_iHUDWeaponSelected = nextWeapon.GetSharedID();
	pSeat->m_flHUDWeaponSelectTime = time + 0.5f;
}

bool
Cmd_Parse(string sCMD)
{
	ncClient localPlayer = (ncClient)pSeat->m_ePlayer;
	switch (argv(0)) {

	case "slot1":
		Textmenu_Input(0);
		break;
	case "slot2":
		Textmenu_Input(1);
		break;
	case "slot3":
		Textmenu_Input(2);
		break;
	case "slot4":
		Textmenu_Input(3);
		break;
	case "slot5":
		Textmenu_Input(4);
		break;
	case "slot6":
		Textmenu_Input(5);
		break;
	case "slot7":
		Textmenu_Input(6);
		break;
	case "slot8":
		Textmenu_Input(7);
		break;
	case "slot9":
		Textmenu_Input(8);
		break;
	case "slot10":
		Textmenu_Input(9);
		break;

	case "listFramegroups":
		CMD_ListModelFramegroups();
		break;
	case "listTitles":
		CMD_ListTitles();
		break;
	case "listModels":
		CMD_ListModels();
		break;
	case "listSounds":
		CMD_ListSounds();
		break;
	case "listParticles":
		CMD_ListParticles();
		break;
	case "listClientSoundDef":
		SoundDef_DebugList();
		break;
	case "listServerSoundDef":
		localcmd("sv listSoundDef\n");
		break;
	case "clearDecals":
		CMD_Cleardecals();
		break;
	case "testLight":
		CMD_testLight();
		break;
	case "testPointLight":
		CMD_testPointLight();
		break;
	case "dev_modeltest":
		CMD_dev_modeltest();
		break;
	case "dev_sunpos":
		CMD_dev_sunpos();
		break;
	case "dev_measure":
		CMD_dev_measure();
		break;
	case "vote":
		CMD_vote();
		break;
	case "getpos":
		CMD_getpos();
		break;
	case "setang":
		CMD_setang();
		break;
	case "callvote":
		sendevent("CallVote", "s", substring(sCMD, 9, strlen(sCMD)-9));
		break;
	case "+zoomin":
		pSeat->m_iZoomed = true;
		break;
	case "-zoomin":
		pSeat->m_iZoomed = false;
		break;
	case "buildcubemaps":
		CMap_Build();
		break;
	case "titles_test":
		CMD_titles_test();
		break;
	case "+attack2":
		pSeat->m_iInputAttack2 = true;
		break;
	case "-attack2":
		pSeat->m_iInputAttack2 = false;
		break;
	case "+reload":
		pSeat->m_iInputReload = true;
		break;
	case "-reload":
		pSeat->m_iInputReload = false;
		break;
	case "+activate":
	case "+use":
		pSeat->m_iInputUse = true;
		break;
	case "-activate":
	case "-use":
		pSeat->m_iInputUse = false;
		break;
	case "+duck":
		if (autocvar_pm_crouchToggle == true)
			pSeat->m_iInputDuck = 1 - pSeat->m_iInputDuck;
		else
			pSeat->m_iInputDuck = TRUE;

		pSeat->m_bSpecInput = true;
		break;
	case "-duck":
		if (autocvar_pm_crouchToggle == false)
			pSeat->m_iInputDuck = FALSE;

		pSeat->m_bSpecInput = false;
		break;
	case "+prone":
		pSeat->m_iInputProne = true;
		break;
	case "-prone":
		pSeat->m_iInputProne = false;
		break;
	case "+sprint":
		pSeat->m_iSprinting = true;
		break;
	case "-sprint":
		pSeat->m_iSprinting = false;
		break;
	case "+leanleft":
		pSeat->m_iLeanDir = -1;
		break;
	case "-leanleft":
		pSeat->m_iLeanDir = 0;
		break;
	case "+leanright":
		pSeat->m_iLeanDir = 1;
		break;
	case "-leanright":
		pSeat->m_iLeanDir = 0;
		break;
	case "goprone":
		pSeat->m_dForceStance = STANCE_PRONE;
		break;
	case "gocrouch":
		pSeat->m_dForceStance = STANCE_CROUCH;
		break;
	case "+gostand":
		if (pSeat->m_dForceStance != STANCE_DEFAULT) {
			pSeat->m_dForceStance = STANCE_DEFAULT;
		} else {
			pSeat->m_iInputJump = true;
		}
		break;
	case "-gostand":
		pSeat->m_iInputJump = false;
		break;
	case "weapnext":
		ncWeapon_SelectWeapon(localPlayer.GetNextWeapon());
		break;
	case "weapprev":
		ncWeapon_SelectWeapon(localPlayer.GetPreviousWeapon());
		break;
	case "weaplast":
		ncWeapon_SelectWeapon(localPlayer.GetLastWeapon());
		break;
	case "+showscores":
		pSeat->m_iScoresVisible = TRUE;
		break;
	case "-showscores":
		pSeat->m_iScoresVisible = FALSE;
		break;
	case "way_menu":
		CMD_way_menu();
		break;
	case "addChatLine":
		CSQC_Parse_Print(argv(1), PRINT_CHAT);
		break;
	case "view_geomtest":
		CMD_view_geomtest();
		break;
	case "player_geomtest":
		CMD_player_geomtest();
		break;
	case "motd":
		print(MOTD_GetTextBody());
		break;

	/* XR binds, engine binds them currently */
	case "+attack_left":
		pSeat->m_bMoveForward = true;
		break;
	case "-attack_left":
		pSeat->m_bMoveForward = false;
		break;
	case "+menu_left":
		break;
	case "-menu_left":
		break;
	case "+attack_right":
		pSeat->m_iInputAttack = true;
		break;
	case "-attack_right":
		pSeat->m_iInputAttack = false;
		break;

	case "+menu_right":
		pSeat->m_iInputReload = true;
		break;
	case "-menu_right":
		pSeat->m_iInputReload = false;
		break;

	/* client aliases for server commands */
	case "addBot":
	case "killAllBots":
	case "resetAllBotsGoals":
	case "killClass":
	case "killMovables":
	case "trigger":
	case "input":
	case "listBotProfiles":
	case "listMapTweaks":
	case "listTargets":
	case "teleport":
	case "teleportToClass":
	case "respawnEntities":
	case "spawnDef":
	case "nodeAdd":
	case "nodeDel":
	case "nodeFlags":
	case "nodeLink":
	case "nodeRadius":
	case "nodeOffset":
	case "nodeUnlink":
	case "traceMaterial":
	case "listEntitySpawnData":
	case "listEntitiesByClass":
	case "listEntityData":
	case "listEntitiesByTarget":
	case "addon":
		localcmd(sprintf("sv %s\n", sCMD));
		break;
	/* client aliases for client commands */
	case "setpos":
	case "listInventory":
	case "giveInventoryItem":
	case "removeInventoryItem":
	case "removeAllInventoryItems":
	case "listAmmo":
	case "joinTeam":
		localcmd(sprintf("cmd %s\n", sCMD));
		break;

	case "listClientEntityDef":
		EntityDef_DebugList();
		break;
	case "listEntityDef":
	case "listServerEntityDef":
		localcmd("sv listEntityDef\n");
		break;

	case "bobup":
		break;
	case "bobdn":
		break;

	case "+commandmenu":
		Commandmenu_Open();
		break;
	case "-commandmenu":
		Commandmenu_Close();
		break;
	case "ragdollCreate":
		ncRagdoll_Create(argv(1));
		break;
	default:
		return HUD_ConsoleCommand(sCMD);
	}
	return (true);
}

void
Cmd_Init(void)
{
	InitStart();

	/* developer/debug commands */
	registercommand("killAllBots");
	registercommand("killClass");
	registercommand("killMovables");
	registercommand("listAmmo");
	registercommand("listBotProfiles");
	registercommand("listClientEntityDef");
	registercommand("listClientSoundDef");
	registercommand("listEntityData");
	registercommand("listEntityDef");
	registercommand("listEntitiesByClass");
	registercommand("listEntitySpawnData");
	registercommand("listFramegroups");
	registercommand("listInventory");
	registercommand("listMapTweaks");
	registercommand("listModels");
	registercommand("listParticles");
	registercommand("listServerEntityDef");
	registercommand("listServerSoundDef");
	registercommand("listEntitiesByTarget");
	registercommand("listSounds");
	registercommand("listTargets");
	registercommand("listTitles");
	registercommand("ragdollCreate");
	registercommand("traceMaterial");

	/* server commands */
	registercommand("addBot");
	registercommand("addon");
	registercommand("input");
	registercommand("resetAllBotsGoals");
	registercommand("respawnEntities");
	registercommand("spawnDef");
	registercommand("teleport");
	registercommand("teleportToClass");
	registercommand("trigger");

	/* nav editing */
	registercommand("nodeAdd");
	registercommand("nodeDel");
	registercommand("nodeFlags");
	registercommand("nodeLink");
	registercommand("nodeRadius");
	registercommand("nodeOffset");
	registercommand("nodeUnlink");

	registercommand("clearDecals");
	registercommand("testLight");
	registercommand("testPointLight");
	registercommand("getpos");
	registercommand("setpos");
	registercommand("setang");
	registercommand("dev_sentence");
	registercommand("titles_test");
	registercommand("buildcubemaps");
	registercommand("dev_sunpos");
	registercommand("dev_measure");
	registercommand("view_geomtest");
	registercommand("player_geomtest");
	registercommand("way_menu");
	registercommand("dev_explode");
	registercommand("dev_modeltest");

	/* basic actions */
	registercommand("+attack");
	registercommand("-attack");
	registercommand("+attack2");
	registercommand("-attack2");
	registercommand("+reload");
	registercommand("-reload");
	registercommand("+activate");
	registercommand("-activate");
	registercommand("+use");
	registercommand("-use");
	registercommand("+duck");
	registercommand("-duck");
	registercommand("+prone");
	registercommand("-prone");
	registercommand("goprone");
	registercommand("gocrouch");
	registercommand("+gostand");
	registercommand("-gostand");
	registercommand("+sprint");
	registercommand("-sprint");
	registercommand("+leanleft");
	registercommand("-leanleft");
	registercommand("+leanright");
	registercommand("-leanright");
	registercommand("weapnext");
	registercommand("weapprev");

	registercommand("giveInventoryItem");
	registercommand("removeInventoryItem");
	registercommand("removeAllInventoryItems");

	/* voting */
	registercommand("vote");
	registercommand("callvote");

	/* teamplay */
	registercommand("joinTeam");

	/* motd */
	registercommand("motd");

	/* hud weapon selection system */
	registercommand("slot1");
	registercommand("slot2");
	registercommand("slot3");
	registercommand("slot4");
	registercommand("slot5");
	registercommand("slot6");
	registercommand("slot7");
	registercommand("slot8");
	registercommand("slot9");
	registercommand("slot10");

	/* commandmenu */
	registercommand("+commandmenu");
	registercommand("-commandmenu");

	/* scoreboard */
	registercommand("+showscores");
	registercommand("-showscores");

	/* meant to be hidden */
	registercommand("addChatLine");

	/* Requested by Slacer */
	registercommand("+zoomin");
	registercommand("-zoomin");

	/* XR binds, temporady until the engine standardizes things */
	registercommand("+attack_left");
	registercommand("-attack_left");
	registercommand("+attack_right");
	registercommand("-attack_right");
	registercommand("+menu_left");
	registercommand("-menu_left");
	registercommand("+menu_right");
	registercommand("-menu_right");

	InitEnd();
}
