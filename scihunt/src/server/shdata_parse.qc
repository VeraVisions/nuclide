/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

/* If only origin parameters are applied, make something up */
var int autocvar_sh_sciyaw = TRUE;

/* Limit the amount of scientists spawned */
var int autocvar_sh_scimax = 30;

void SHData_SpawnScientist(void)
{
	static int slimit = 0;
	if (autocvar_sh_scimax) {
		if (slimit >= autocvar_sh_scimax) {
			dprint("shdata: scientist limit hit. ignored\n");
			remove(self);
			return;
		}
		slimit++;
	}
	spawnfunc_monster_scientist();
}

void SHData_New(void)
{
	entity new = spawn();
	new.origin[0] = stof(argv(1));
	new.origin[1] = stof(argv(2));
	new.origin[2] = stof(argv(3));

	if (autocvar_sh_sciyaw) {
		new.angles[1] = Math_FixDelta(random(0,360));
	}

	setorigin(new, new.origin);

	entity oldself = self;
	self = new;

	if (argv(0) == "monster_scientist") {
		SHData_SpawnScientist();
	} else if (argv(0) == "info_player_team1") {
		self.classname = "info_player_deathmatch";
	} else if (argv(0) == "info_player_team2") {
		self.classname = "info_player_deathmatch";
	}
	self = oldself;
}

void SHData_NewAngles(void)
{
	entity new = spawn();
	new.origin[0] = stof(argv(1));
	new.origin[1] = stof(argv(2));
	new.origin[2] = stof(argv(3));
	new.angles[0] = stof(argv(4));
	new.angles[1] = stof(argv(5));
	new.angles[2] = stof(argv(6));
	setorigin(new, new.origin);
	
	entity oldself = self;
	self = new;
	
	if (argv(0) == "monster_scientist") {
		SHData_SpawnScientist();
	} else if (argv(0) == "info_player_team1") {
		self.classname = "info_player_deathmatch";
	} else if (argv(0) == "info_player_team2") {
		self.classname = "info_player_deathmatch";
	}
	self = oldself;
}

void SHData_GetItems(player pl)
{
	/* TODO: Parse the config files */
	pl.ammo_9mm = 68;
	pl.ammo_buckshot = 34;
	pl.ammo_bolt = 50;
	pl.ammo_357 = 36;
	pl.ammo_m203_grenade = 3;
	pl.ammo_rocket = 5;
	pl.ammo_snark = 10;
	Weapons_AddItem(pl, WEAPON_CROWBAR, -1);
	Weapons_AddItem(pl, WEAPON_GLOCK, -1);
	Weapons_AddItem(pl, WEAPON_PYTHON, -1);
	Weapons_AddItem(pl, WEAPON_MP5, -1);
	Weapons_AddItem(pl, WEAPON_SHOTGUN, -1);
	Weapons_AddItem(pl, WEAPON_CROSSBOW, -1);
	Weapons_AddItem(pl, WEAPON_RPG, -1);
	Weapons_AddItem(pl, WEAPON_GAUSS, -1);
	Weapons_AddItem(pl, WEAPON_EGON, -1);
	Weapons_AddItem(pl, WEAPON_HORNETGUN, -1);
	Weapons_AddItem(pl, WEAPON_HANDGRENADE, -1);
	Weapons_AddItem(pl, WEAPON_SATCHEL, -1);
	Weapons_AddItem(pl, WEAPON_TRIPMINE, -1);
	Weapons_AddItem(pl, WEAPON_SNARK, -1);
	Weapons_AddItem(pl, WEAPON_CANNON, -1);
	Weapons_AddItem(pl, WEAPON_CHAINSAW, -1);
	Weapons_AddItem(pl, WEAPON_HAMMER, -1);
}

void SHData_Parse(string map)
{
	int c;
	string temp;
	filestream shdfile = fopen(sprintf("SH_Data/%s.shd", map), FILE_READ);

	if (shdfile < 0) {
		dprint(sprintf("^1WARNING^7: Could not load SH_Data/%s.shd\n", map));
		return;
	}

	if (shdfile >= 0) {
		while ((temp = fgets(shdfile))) {
			c = tokenize(temp);

			if (c == 4) {
				SHData_New();
			} else if (c == 7) {
				SHData_NewAngles();
			}
		}
	}
}
