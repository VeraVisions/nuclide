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

/* Last Man Standing
   In this Classic version of LMS, every player starts with
   a server-controlled number of lives (cvar: lms_lifeCounter)
   which when fully reached 0, will prevent the player from
   spawning again on that map.
   
   When only one player is left 'standing', the intermission/scores
   pop up and the match is over.
*/
var int autocvar_lms_lifeCounter = 3;

entity lms_outMessage;
entity lms_endMessage;
bool lms_gameOver;

void
LMS_SpawnPlayer(entity playerTarget)
{
	ents.ChangeToClass(playerTarget, "player_mp");
	game.TeleportToSpawn(playerTarget);
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
	game.SetSpawnPoint("info_player_deathmatch");

	/* from shared.qc */
	Util_RemoveAllMonsters();
	Util_SetItemRespawnTimers();

	lms_outMessage = ents.Create("lms_outmessage", [0, 0, 0] );
	lms_endMessage = ents.Create("lms_endmessage", [0, 0, 0] );
	lms_gameOver = false;
}

void
CodeCallback_PlayerSpawn(entity playerTarget)
{
	bool inProgress = false;
	int bustedPlayers = 0;

	/* gotta see if anyones left */
	for (entity playerChain = world; (playerChain = next.Player(playerChain));) {
		/* yep, game already in progress since more than one player doesn't have full health */
		if (playerChain.frags > 0 && playerChain.frags < autocvar_lms_lifeCounter) {
			bustedPlayers++;

			if (bustedPlayers >= 2) {
				inProgress = true;
				break;
			}
		}
	}

	/* don't allow player spawn any more */
	if (inProgress == true) {
		ents.ChangeToClass(playerTarget, "spectator");
		return;
	}

	LMS_SpawnPlayer(playerTarget);
}

void
CodeCallback_PlayerConnect(entity playerTarget)
{
	/* restore our life counter */
	playerTarget.frags = autocvar_lms_lifeCounter;
}

bool
CodeCallback_PlayerRequestRespawn(entity playerTarget)
{
	/* out of lives */
	if (playerTarget.frags <= 0) {
		return (false);
	}

	LMS_SpawnPlayer(playerTarget);
	return (true);
}

void
CodeCallback_PlayerKilled(entity playerTarget, entity inflictor, entity attacker, string weapon)
{
	int alivePlayers = 0;
	entity lastPlayer = world;

	if (playerTarget == attacker)
		combat.Obituary(playerTarget.netname, attacker.netname, weapon, "self");
	else
		combat.Obituary(playerTarget.netname, attacker.netname, weapon, "");

	/* no longer allow state changes */
	if (lms_gameOver == true) {
		return;
	}

	playerTarget.deaths++;
	playerTarget.frags--;

	/* gotta see if anyones left */
	for (entity playerChain = world; (playerChain = next.Player(playerChain));) {
		if (playerChain.frags > 0) {
			alivePlayers++;
			lastPlayer = playerChain;
		}
	}

	if (playerTarget.frags == 0) {
		printf("%s ^7is OUT!\n", playerTarget.netname);
		ents.Input(lms_outMessage, "SetText", sprintf("%s ^7is OUT!\n", playerTarget.netname), world);
		ents.Input(lms_outMessage, "Display", "", world);
		ents.ChangeToClass(playerTarget, "spectator");
	}

	if (alivePlayers == 1) {
		printf("%s ^7WINS!\n", lastPlayer.netname);
		ents.Input(lms_endMessage, "SetText", sprintf("%s ^7WINS!\n", lastPlayer.netname), world);
		ents.Input(lms_endMessage, "Display", "", world);
		game.EndMapDelayed(5.0f);
		lms_gameOver = true;
	}
}
