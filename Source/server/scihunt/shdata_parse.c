/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

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

void SHData_GetItems(void)
{
	player pl = (player)self;

	/* TODO: Parse the config files */
	pl.ammo_9mm = 68;
	pl.ammo_buckshot = 34;
	pl.ammo_bolt = 50;
	pl.ammo_357 = 36;
	pl.ammo_m203_grenade = 3;
	pl.ammo_rocket = 5;
	pl.ammo_snark = 10;
	Weapons_AddItem(pl, WEAPON_CROWBAR);
	Weapons_AddItem(pl, WEAPON_GLOCK);
	Weapons_AddItem(pl, WEAPON_PYTHON);
	Weapons_AddItem(pl, WEAPON_MP5);
	Weapons_AddItem(pl, WEAPON_SHOTGUN);
	Weapons_AddItem(pl, WEAPON_CROSSBOW);
	Weapons_AddItem(pl, WEAPON_RPG);
	Weapons_AddItem(pl, WEAPON_GAUSS);
	Weapons_AddItem(pl, WEAPON_EGON);
	Weapons_AddItem(pl, WEAPON_HORNETGUN);
	Weapons_AddItem(pl, WEAPON_HANDGRENADE);
	Weapons_AddItem(pl, WEAPON_SATCHEL);
	Weapons_AddItem(pl, WEAPON_TRIPMINE);
	Weapons_AddItem(pl, WEAPON_SNARK);
	Weapons_AddItem(pl, WEAPON_CANNON);
	Weapons_AddItem(pl, WEAPON_CHAINSAW);
	Weapons_AddItem(pl, WEAPON_HAMMER);
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
