/*
 * Copyright (c) 2024 Marco Cawthorne <marco@icculus.org>
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

var int g_team1_scoring = 0;
var int g_team2_scoring = 0;
var int autocvar_dom_scoreLimit = 100;
var float autocvar_dom_pointInterval = 5.0f;
entity dom_team1WinMessage;
entity dom_team2WinMessage;

static string g_tfPlayerColor[5] = {
	"0xffffff",
	"0xff1800"
	"0x9aff"
};


void
InitDomination(void)
{
	g_team1_scoring = 0;
	g_team2_scoring = 0;

	for (entity s = world; (s = find(s, ::classname, "domination_area"));) {
		entity newIcon = ents.Create("domination_icon", s.origin);

		if (STRING_SET(s.netname)) {
			ents.Input(newIcon, "SetText", s.netname, world);
		}

		ents.Input(newIcon, "Trigger", "", world);
	}
}

void
CodeCallback_Precaches(void)
{
	Util_SharedPrecaches();
}

void
CodeCallback_StartGameType(void)
{
	motd.LoadDefault();
	game.SetSpawnPoint("info_intermission");

	teams.SetUp(1, "Enforcers", [255, 64, 64], true);
	teams.SetUp(2, "Rangers", [155, 205, 255], true);

	teams.SetSpawnPoint(1, "info_player_deathmatch");
	teams.SetSpawnPoint(2, "info_player_deathmatch");

	dom_team1WinMessage = ents.Create("domination_team1win", [0, 0, 0] );
	dom_team2WinMessage = ents.Create("domination_team2win", [0, 0, 0] );

	/* from shared.qc */
	Util_RemoveAllMonsters();
	Util_SetItemRespawnTimers();

	InitDomination();
}

void
CodeCallback_FrameStart(void)
{
	static float nextPointDistribution = 0.0f;

	if (nextPointDistribution == -1 || nextPointDistribution > time) {
		return;
	}

	g_team1_scoring = 0;
	g_team2_scoring = 0;

	for (entity s = world; (s = find(s, ::classname, "domination_area"));) {
		if (s.team_info == 1i) {
			g_team1_scoring++;
		}
		if (s.team_info == 2i) {
			g_team2_scoring++;
		}
	}

	nextPointDistribution = time + autocvar_dom_pointInterval;

	if (g_team1_scoring > 0i) {
		teams.AddScore(1, 5 * g_team1_scoring);

		if (autocvar_dom_scoreLimit > 0) {
			if (teams.Score(1) >= autocvar_dom_scoreLimit) {
				nextPointDistribution = -1;
				game.EndMapDelayed(5.0);
				ents.Input(dom_team1WinMessage, "Display", "", world);
			}
		}
	} 

	if (g_team2_scoring > 0) {
		teams.AddScore(2, 5 * g_team2_scoring);

		if (autocvar_dom_scoreLimit > 0) {
			if (teams.Score(2) >= autocvar_dom_scoreLimit) {
				nextPointDistribution = -1;
				game.EndMapDelayed(5.0f);
				ents.Input(dom_team2WinMessage, "Display", "", world);
			}
		}
	}
}

void
CodeCallback_PlayerSpawn(entity playerEntity)
{
	ents.ChangeToClass(playerEntity, "spectator");
	game.TeleportToSpawn(playerEntity);
	music.PlayOnceOnClient(precache.Music("music/track06.ogg"), playerEntity);
}

bool
CodeCallback_PlayerRequestRespawn(entity playerEntity)
{
	if (is.Alive(playerEntity) == false) {
		ents.ChangeToClass(playerEntity, playerEntity.classname);
		userinfo.SetString(playerEntity, "topcolor", g_tfPlayerColor[playerEntity.team]);
		userinfo.SetString(playerEntity, "bottomcolor", g_tfPlayerColor[playerEntity.team]);
		game.TeleportToSpawn(playerEntity);
		music.PlayOnceOnClient(precache.Music("music/track05.ogg"), playerEntity);
	}

	return (true);
}

bool
CodeCallback_CallRequestTeam(entity playerEntity, int teamNum)
{
	ents.Input(playerEntity, "SetTeam", itos(teamNum), playerEntity);

	if (is.Alive(playerEntity) == false) {
		if (playerEntity.team == 1) {
			ents.ChangeToClass(playerEntity, "player_enforcer");
			userinfo.SetString(playerEntity, "topcolor", "0xff1800");
			userinfo.SetString(playerEntity, "bottomcolor", "0xff1800");
		} else {
			ents.ChangeToClass(playerEntity, "player_mp");
			userinfo.SetString(playerEntity, "topcolor", "0x9aff");
			userinfo.SetString(playerEntity, "bottomcolor", "0x9aff");
		}

		game.TeleportToSpawn(playerEntity);
		music.PlayOnceOnClient(precache.Music("music/track05.ogg"), playerEntity);
	} else {
		ents.Input(playerEntity, "Damage", "1000", playerEntity);
	}

	return (true);
}


void
CodeCallback_PlayerKilled(entity playerTarget, entity inflictor, entity attacker, string weapon)
{
	combat.Obituary(playerTarget.netname, attacker.netname, weapon, "");

	/* death-counter */
	playerTarget.deaths++;

	/* update score-counter */
	if (is.Player(attacker)) {
		if (playerTarget == attacker) {
			attacker.frags--;
		} else {
			attacker.frags++;
		}
	}
}

bool
CodeCallback_ClientCommand(entity playerEntity, string command)
{
	float commandArgs = tokenize(command);

	switch (argv(0)) {
	default:
		return (false);
	}

	return (true);
}

entity FindClosestIcon(vector testPos)
{
	float bestDist = 9999.0f;
	entity bestIconMatch = world;

	for (entity s = world; (s = find(s, ::classname, "domination_icon"));) {
		float testDistance = vlen(s.origin - testPos);

		if (testDistance < bestDist) {
			bestDist = testDistance;
			bestIconMatch = s;
		}
	}

	return (bestIconMatch);
}

void
CodeCallback_Input(entity activator, string inputName, string dataString)
{
	switch (inputName) {
	case "Capture":
		entity closestIcon = FindClosestIcon(activator.origin);

		if (dataString == "1") {
			if (closestIcon) {
				ents.Input(closestIcon, "Color", "255 0 0", world);
			}
		} else if (dataString == "2") {

			if (closestIcon) {
				ents.Input(closestIcon, "Color", "0 0 255", world);
			}
		}
		break;
	case "Break":
		entity closestIcon2 = FindClosestIcon(activator.origin);
		ents.Input(closestIcon2, "Color", "255 255 255", world);
		//music.PlayOnce(precache.Music("music/mp_yield.wav"));

		break;
	}
}
