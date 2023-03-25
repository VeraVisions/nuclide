/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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
CMD_testPointLight(void)
{
	makevectors(getproperty(VF_ANGLES));
	traceline(getproperty(VF_ORIGIN), getproperty(VF_ORIGIN) + v_forward * 4096, FALSE, pSeat->m_ePlayer);
	dynamiclight_spawnstatic(trace_endpos + (v_forward * -16), 1024, [1,1,1]);
}

static void
CMD_dev_modeltest(void)
{
	entity mt = spawn();
	mt.drawmask = MASK_ENGINE;
	setmodel(mt, argv(1));
	setsize(mt, [0,0,0], [0,0,0]);
	setorigin(mt, getproperty(VF_ORIGIN));
	mt.angles = getproperty(VF_ANGLES);
	mt.angles[0] = mt.angles[2] = 0;
}

static void
CMD_dev_explode(void)
{
	makevectors(getproperty(VF_ANGLES));
	traceline(getproperty(VF_ORIGIN), getproperty(VF_ORIGIN) + v_forward * 4096, FALSE, pSeat->m_ePlayer);
	FX_Explosion(trace_endpos);
}

static void
CMD_dev_sunpos(void)
{
	vector sunpos, sunang;
	vector lepos, leang;

	makevectors(getproperty(VF_ANGLES));
	sunpos = v_forward * -1;
	sunang = vectoangles(sunpos);

	makevectors(getproperty(VF_ANGLES));
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
	if (!vlen(measurepos)) {
		measurepos = getproperty(VF_ORIGIN);
		CSQC_Parse_CenterPrint(sprintf( "First marker set at\n%v", measurepos));
	} else {
		CSQC_Parse_CenterPrint(sprintf("Distance: %d\n", vlen(measurepos - getproperty(VF_ORIGIN))));
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
	print(sprintf("setpos %v;setang -%v\n", getproperty(VF_ORIGIN), getproperty(VF_ANGLES)));
}

static void
CMD_setpos(void)
{
	localcmd(sprintf("cmd setpos \"%s\"\n", argv(1)));
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
	Weapons_SetGeomset(sprintf("geomset %s %s\n", argv(1), argv(2)));
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
		decal dcl = (decal)e;
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
			print(sprintf("%i %s\n", i, tmp));
			actual_count++;
		}
	}
	print(sprintf("\t%i total models loaded\n", actual_count));
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
			print(sprintf("%i %s (%f seconds)\n", i, tmp, length));
			actual_count++;
			total_length += length;
		}
	}
	print(sprintf("\t%i total samples loaded\n", actual_count));
	print(sprintf("\t%f seconds worth of samples\n", total_length));
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
			print(sprintf("%i %s\n", i, tmp));
			actual_count++;
		}
	}
	print(sprintf("\t%i total particles loaded\n", actual_count));
}

static void
CMD_ListTitles(void)
{
	int i = 0i;

	for (i = 0; i < g_titles_count; i++) {
		print(sprintf("%s, (x: %d, y: %d)\n", 
			g_titles[i].m_strName, g_titles[i].m_flPosX, g_titles[i].m_flPosY));
		print(sprintf("\teffect: %i, fade-in: %f, fade-out: %f\n", 
			g_titles[i].m_iEffect, g_titles[i].m_flFadeIn, g_titles[i].m_flFadeOut));
		print(sprintf("\thold-time: %f, fx-time: %f\n", 
			g_titles[i].m_flHoldTime, g_titles[i].m_flFXTime));
		print(sprintf("\tcolor 1: %v, color 2: %v\n", 
			g_titles[i].m_vecColor1, g_titles[i].m_vecColor2));
	}
	print(sprintf("\t%i total titles loaded\n", g_titles_count));
}

/*
=================
Cmd_Parse

Called from CSQC_ConsoleCommand to handle any builtin
commands from the Nuclide SDK.
Returns 0 if the command isn't handled and the engine is expected
to handle it from there.
=================
*/
bool
Cmd_Parse(string sCMD)
{
	switch (argv(0)) {
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
	case "cleardecals":
		CMD_Cleardecals();
		break;
	case "testPointLight":
		CMD_testPointLight();
		break;
	case "dev_modeltest":
		CMD_dev_modeltest();
		break;
	case "dev_explode":
		CMD_dev_explode();
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
	case "setpos":
		CMD_setpos();
		break;
	case "setang":
		CMD_setang();
		break;
	case "callvote":
		sendevent("CallVote", "s", substring(sCMD, 9, strlen(sCMD)-9));
		break;
	case "+zoomin":
		pSeat->m_iZoomed = TRUE;
		break;
	case "-zoomin":
		pSeat->m_iZoomed = FALSE;
		break;
	case "buildcubemaps":
		CMap_Build();
		break;
	case "titles_test":
		CMD_titles_test();
		break;
	case "+attack2":
		pSeat->m_iInputAttack2 = TRUE;
		break;
	case "-attack2":
		pSeat->m_iInputAttack2 = FALSE;
		break;
	case "+reload":
		pSeat->m_iInputReload = TRUE;
		break;
	case "-reload":
		pSeat->m_iInputReload = FALSE;
		break;
	case "+use":
		pSeat->m_iInputUse = TRUE;
		break;
	case "-use":
		pSeat->m_iInputUse = FALSE;
		break;
	case "+duck":
		if (autocvar_pm_crouchToggle == true)
			pSeat->m_iInputDuck = 1 - pSeat->m_iInputDuck;
		else
			pSeat->m_iInputDuck = TRUE;
		break;
	case "-duck":
		if (autocvar_pm_crouchToggle == false)
			pSeat->m_iInputDuck = FALSE;
		break;
	case "invnext":
		HUD_DrawWeaponSelect_Back();
		break;
	case "invprev":
		HUD_DrawWeaponSelect_Forward();
		break;
	case "lastinv":
		HUD_DrawWeaponSelect_Last();
		break;
	case "+showscores":
		pSeat->m_iScoresVisible = TRUE;
		break;
	case "-showscores":
		pSeat->m_iScoresVisible = FALSE;
		break;
	case "slot1":
		HUD_SlotSelect(0);
		break;
	case "slot2":
		HUD_SlotSelect(1);
		break;
	case "slot3":
		HUD_SlotSelect(2);
		break;
	case "slot4":
		HUD_SlotSelect(3);
		break;
	case "slot5":
		HUD_SlotSelect(4);
		break;
	case "slot6":
		HUD_SlotSelect(5);
		break;
	case "slot7":
		HUD_SlotSelect(6);
		break;
	case "slot8":
		HUD_SlotSelect(7);
		break;
	case "slot9":
		HUD_SlotSelect(8);
		break;
	case "slot10":
		HUD_SlotSelect(9);
		break;
	case "way_menu":
		CMD_way_menu();
		break;
	case "_fnchat_msg":
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
		pSeat->m_iInputReload = TRUE;
		break;
	case "-menu_right":
		pSeat->m_iInputReload = FALSE;
		break;
	default:
		return (false);
	}
	return (true);
}

/*
=================
Cmd_Init

Register our commands for Nuclide
=================
*/
void
Cmd_Init(void)
{
	print("--------- Initializing Cmds ----------\n");

	/* developer/debug commands */
	registercommand("listModels");
	registercommand("listSounds");
	registercommand("listParticles");
	registercommand("listTitles");

	registercommand("cleardecals");
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
	registercommand("+use");
	registercommand("-use");
	registercommand("+duck");
	registercommand("-duck");

	/* voting */
	registercommand("vote");
	registercommand("callvote");

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
	registercommand("lastinv");
	registercommand("invnext");
	registercommand("invprev");

	/* scoreboard */
	registercommand("+showscores");
	registercommand("-showscores");

	/* meant to be hidden */
	registercommand("_fnchat_msg");

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
}
