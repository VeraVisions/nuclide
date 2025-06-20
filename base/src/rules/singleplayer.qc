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
	precache.Entity("player");
}

void
CodeCallback_StartGameType(void)
{
}

void
CodeCallback_PlayerSpawn(entity playerTarget)
{
	ents.ChangeToClass(playerTarget, "player");
	game.TeleportToSpawn(playerTarget);
}

bool
CodeCallback_PlayerRequestRespawn(entity playerTarget)
{
	localcmd("load quick\n");
	return (true);
}


bool
CodeCallback_ImpulseCommand(entity playerTarget, float impulseNum)
{
	switch (impulseNum) {
	case 100:
		ents.Input(playerTarget, "UseItem", "item_suit", playerTarget);
		break;
	case 101:
		ents.Input(playerTarget, "SetHealth", "100", playerTarget);
		ents.Input(playerTarget, "SetArmor", "100", playerTarget);
		ents.Input(playerTarget, "GiveItem", "item_suit", playerTarget);
		ents.Input(playerTarget, "GiveItem", "weapon_357", playerTarget);
		ents.Input(playerTarget, "GiveItem", "weapon_9mmAR", playerTarget);
		ents.Input(playerTarget, "GiveItem", "weapon_9mmhandgun", playerTarget);
		ents.Input(playerTarget, "GiveItem", "weapon_crossbow", playerTarget);
		ents.Input(playerTarget, "GiveItem", "weapon_crowbar", playerTarget);
		ents.Input(playerTarget, "GiveItem", "weapon_egon", playerTarget);
		ents.Input(playerTarget, "GiveItem", "weapon_gauss", playerTarget);
		ents.Input(playerTarget, "GiveItem", "weapon_handgrenade", playerTarget);
		ents.Input(playerTarget, "GiveItem", "weapon_hornetgun", playerTarget);
		ents.Input(playerTarget, "GiveItem", "weapon_rpg", playerTarget);
		ents.Input(playerTarget, "GiveItem", "weapon_satchel", playerTarget);
		ents.Input(playerTarget, "GiveItem", "weapon_shotgun", playerTarget);
		ents.Input(playerTarget, "GiveItem", "weapon_snark", playerTarget);
		ents.Input(playerTarget, "GiveItem", "weapon_tripmine", playerTarget);
		ents.Input(playerTarget, "GiveAmmo", "ammo_9mm 255", playerTarget);
		ents.Input(playerTarget, "GiveAmmo", "ammo_357 255", playerTarget);
		ents.Input(playerTarget, "GiveAmmo", "ammo_buckshot 255", playerTarget);
		ents.Input(playerTarget, "GiveAmmo", "ammo_bolt 255", playerTarget);
		ents.Input(playerTarget, "GiveAmmo", "ammo_rocket 255", playerTarget);
		ents.Input(playerTarget, "GiveAmmo", "ammo_uranium 255", playerTarget);
		ents.Input(playerTarget, "GiveAmmo", "ammo_handgrenade 255", playerTarget);
		ents.Input(playerTarget, "GiveAmmo", "ammo_satchel 255", playerTarget);
		ents.Input(playerTarget, "GiveAmmo", "ammo_tripmine 255", playerTarget);
		ents.Input(playerTarget, "GiveAmmo", "ammo_snark 255", playerTarget);
		ents.Input(playerTarget, "GiveAmmo", "ammo_hornet 255", playerTarget);
		ents.Input(playerTarget, "GiveAmmo", "ammo_m203_grenade 255", playerTarget);
		break;
	default:
		return (false);
	}

	return (true);
}
