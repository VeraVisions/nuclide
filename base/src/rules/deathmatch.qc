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

#pragma PROGS_DAT  "../../progs/deathmatch.dat"

#include "../../../src/server/api.h"

void
CodeCallback_StartGameType(void)
{
	motd.LoadDefault();
}

void
CodeCallback_PlayerSpawn(entity playerTarget)
{
	ents.ChangeToClass(playerTarget, "player_mp");
	game.TeleportToSpawn(playerTarget);
}

void
CodeCallback_PlayerDisconnect(entity playerTarget)
{

}

bool
CodeCallback_PlayerRequestRespawn(entity playerTarget)
{
	CodeCallback_PlayerSpawn(playerTarget);
	return (true);
}

void
CodeCallback_PlayerDamage(entity playerTarget, entity inflictor, entity attacker)
{

}

void
CodeCallback_PlayerKilled(entity playerTarget, entity inflictor, entity attacker, string weapon)
{
	combat.Obituary(playerTarget.netname, attacker.netname, weapon, "");

	/* death-counter */
	playerTarget.deaths++;

	/* update score-counter */
	if (ents.isPlayer(attacker)) {
		if (playerTarget == attacker) {
			attacker.frags--;
		} else {
			attacker.frags++;
		}
	}
}
