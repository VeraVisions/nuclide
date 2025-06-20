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
	precache.Entity("player_mp");
}

void
CodeCallback_StartGameType(void)
{
	motd.LoadDefault();
	game.SetSpawnPoint("info_player_deathmatch");

	for (entity s = world; (s = next.NPC(s));) {
		ents.Input(s, "Kill", "20.0f", world);
	}

	for (entity s = world; (s = next.Item(s));) {
		string isWeapon = substring(s.classname, 0, 7);
		string isAmmo = substring(s.classname, 0, 5);

		if (isWeapon == "weapon_" || isAmmo == "ammo_") {
			ents.Input(s, "SetRespawnTime", "20.0f", world);
		} else {
			ents.Input(s, "SetRespawnTime", "30.0f", world);
		}
	}
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
	if (is.Player(attacker)) {
		if (playerTarget == attacker) {
			attacker.frags--;
		} else {
			attacker.frags++;
		}
	}
}
