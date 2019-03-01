/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

void SHData_New(void)
{
	entity new = spawn();
	new.origin[0] = stof(argv(1));
	new.origin[1] = stof(argv(2));
	new.origin[2] = stof(argv(3));
	setorigin(new, new.origin);

	entity oldself = self;
	self = new;

	if (argv(0) == "monster_scientist") {
		spawnfunc_monster_scientist();
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
		spawnfunc_monster_scientist();
	} else if (argv(0) == "info_player_team1") {
		self.classname = "info_player_deathmatch";
	} else if (argv(0) == "info_player_team2") {
		self.classname = "info_player_deathmatch";
	}
	self = oldself;
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
