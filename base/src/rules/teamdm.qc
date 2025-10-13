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

	/* from shared.qc */
	Util_RemoveAllMonsters();
	Util_SetItemRespawnTimers();
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
		game.TeleportToSpawn(playerEntity);
		music.PlayOnceOnClient(precache.Music("music/track05.ogg"), playerEntity);
	}

	return (true);
}

bool
CodeCallback_CallRequestTeam(entity playerEntity, int teamNum)
{
	/* they want to spectate */
	if (teamNum == TEAM_SPECTATOR) {
		if (is.Alive(playerEntity) == true) {
			ents.Input(playerEntity, "Damage", "1000", playerEntity);
		}

		ents.Input(playerEntity, "SetTeam", itos(TEAM_SPECTATOR), playerEntity);
		ents.ChangeToClass(playerEntity, "spectator");
		userinfo.SetString(playerEntity, "topcolor", "0xffffff");
		userinfo.SetString(playerEntity, "bottomcolor", "0xffffff");
		game.TeleportToSpawn(playerEntity);
		return (true);
	}

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
