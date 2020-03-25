/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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

enum {
	CLASS_SCOUT = 1,
	CLASS_SNIPER,
	CLASS_SOLDIER,
	CLASS_DEMO,
	CLASS_MEDIC,
	CLASS_HVYWEAPON,
	CLASS_PYRO,
	CLASS_SPY,
	CLASS_ENGINEER
};

string g_teammodels[] = {
	"",
	"models/player/scout/scout2.mdl",
	"models/player/sniper/sniper2.mdl",
	"models/player/soldier/soldier2.mdl",
	"models/player/demo/demo.mdl",
	"models/player/medic/medic2.mdl",
	"models/player/hvyweapon/hvyweapon2.mdl",
	"models/player/pyro/pyro2.mdl",
	"models/player/spy/spy2.mdl",
	"models/player/engineer/engineer2.mdl"
};

void
CSEv_TeamJoin_f(float f)
{
	if (self.classname != "player") {
		spawnfunc_player();
	}
	player pl = (player)self;

	entity spot;
	pl.classname = "player";
	pl.health = self.max_health = 100;

	pl.takedamage = DAMAGE_YES;
	pl.solid = SOLID_SLIDEBOX;
	pl.movetype = MOVETYPE_WALK;
	pl.flags = FL_CLIENT;
	pl.viewzoom = 1.0;

	/* mess, do it better */
	if (f < 10) {
		pl.team = 1; /* Blue */
	} else if (f < 20) {
		pl.team = 2; /* Red */
		f -= 10;
	} else if (f < 30) {
		pl.team = 3; /* Yellow */
		f -= 20;
	} else if (f < 40) {
		pl.team = 4; /* Green */
		f -= 30;
	}

	pl.model = g_teammodels[f];
	setmodel(pl, pl.model);
	setsize(pl, VEC_HULL_MIN, VEC_HULL_MAX);
	pl.view_ofs = VEC_PLAYER_VIEWPOS;
	pl.velocity = [0,0,0];
	pl.gravity = __NULL__;
	pl.frame = 1;
	pl.SendEntity = Player_SendEntity;
	pl.SendFlags = UPDATE_ALL;
	pl.armor = pl.activeweapon = pl.g_items = 0;

	pl.customphysics = Empty;
	pl.Pain = Player_Pain;
	pl.Death = Player_Death;
	pl.iBleeds = TRUE;
	forceinfokey(pl, "*spec", "0");
	forceinfokey(self, "*deaths", ftos(self.deaths));

	switch (pl.team) {
	case 1:
		spot = Spawn_SelectRandom("info_teamspawn_blue");
		break;
	case 2:
		spot = Spawn_SelectRandom("info_teamspawn_red");
		break;
	case 3:
		spot = Spawn_SelectRandom("info_teamspawn_yellow");
		break;
	case 4:
		spot = Spawn_SelectRandom("info_teamspawn_green");
		break;
	}

	setorigin(pl, spot.origin);
	pl.angles = spot.angles;
	pl.fixangle = TRUE;
	
	switch (f) {
	case CLASS_SCOUT:
		Weapons_AddItem(pl, WEAPON_CROWBAR);
		Weapons_AddItem(pl, WEAPON_SBS);
		Weapons_AddItem(pl, WEAPON_NAILGUN);
		env_message_single(pl, "HELP_SCOUT");
		break;
	case CLASS_SNIPER:
		Weapons_AddItem(pl, WEAPON_CROWBAR);
		Weapons_AddItem(pl, WEAPON_SNIPER);
		Weapons_AddItem(pl, WEAPON_AUTORIFLE);
		Weapons_AddItem(pl, WEAPON_NAILGUN);
		env_message_single(pl, "HELP_SNIPER");
		break;
	case CLASS_SOLDIER:
		Weapons_AddItem(pl, WEAPON_CROWBAR);
		Weapons_AddItem(pl, WEAPON_SBS);
		Weapons_AddItem(pl, WEAPON_DBS);
		Weapons_AddItem(pl, WEAPON_RPG);
		env_message_single(pl, "HELP_SOLDIER");
		break;
	case CLASS_DEMO:
		Weapons_AddItem(pl, WEAPON_CROWBAR);
		Weapons_AddItem(pl, WEAPON_SBS);
		Weapons_AddItem(pl, WEAPON_GLAUNCHER);
		Weapons_AddItem(pl, WEAPON_PIPEBOMB);
		env_message_single(pl, "HELP_DEMOMAN");
		break;
	case CLASS_MEDIC:
		Weapons_AddItem(pl, WEAPON_MEDKIT);
		Weapons_AddItem(pl, WEAPON_SBS);
		Weapons_AddItem(pl, WEAPON_DBS);
		Weapons_AddItem(pl, WEAPON_SUPERNAIL);
		env_message_single(pl, "HELP_MEDIC");
		break;
	case CLASS_HVYWEAPON:
		Weapons_AddItem(pl, WEAPON_CROWBAR);
		Weapons_AddItem(pl, WEAPON_SBS);
		Weapons_AddItem(pl, WEAPON_DBS);
		Weapons_AddItem(pl, WEAPON_ASSCAN);
		env_message_single(pl, "HELP_HWGUY");
		break;
	case CLASS_PYRO:
		Weapons_AddItem(pl, WEAPON_CROWBAR);
		Weapons_AddItem(pl, WEAPON_SBS);
		Weapons_AddItem(pl, WEAPON_FLAMER);
		Weapons_AddItem(pl, WEAPON_INCENDIARY);
		env_message_single(pl, "HELP_PYRO");
		break;
	case CLASS_SPY:
		Weapons_AddItem(pl, WEAPON_KNIFE);
		Weapons_AddItem(pl, WEAPON_TRANQUIL);
		Weapons_AddItem(pl, WEAPON_DBS);
		Weapons_AddItem(pl, WEAPON_NAILGUN);
		env_message_single(pl, "HELP_SPY");
		break;
	case CLASS_ENGINEER:
		Weapons_AddItem(pl, WEAPON_WRENCH);
		Weapons_AddItem(pl, WEAPON_RAILGUN);
		Weapons_AddItem(pl, WEAPON_DBS);
		env_message_single(pl, "HELP_ENGINEER");
		break;
	}

	pl.g_items |= ITEM_SUIT;
} 
