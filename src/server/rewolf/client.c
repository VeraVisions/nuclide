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

var int autocvar_sv_networkeverything = FALSE;

void
Game_ClientConnect(void)
{
	entity a;
	bprint(PRINT_HIGH, sprintf("%s connected\n", self.netname));

	int playercount = 0;
	for (a = world; (a = find(a, classname, "player"));) {
		playercount++;
	}

	/* we're the first. respawn all entities? */	
	if (playercount == 0) {
		for (a = world; (a = findfloat(a, gflags, GF_CANRESPAWN));) {
			CBaseEntity caw = (CBaseEntity)a;
			caw.Respawn();
		}
	}
}

void
Game_ClientDisconnect(void)
{
	bprint(PRINT_HIGH, sprintf("%s disconnected\n", self.netname));
	
	/* Make this unusable */
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.health = 0;
	self.takedamage = 0;
	self.SendFlags = PLAYER_MODELINDEX;
}

void
Game_ClientKill(void)
{
	Damage_Apply(self, self, self.health, self.origin, TRUE);	
}

void
Game_PlayerPreThink(void)
{
	
}

void
Game_PlayerPostThink(void)
{
	player pl = (player)self;
	Animation_PlayerUpdate();

	pl.SendFlags |= PLAYER_KEEPALIVE;

	if (pl.old_modelindex != pl.modelindex) {
		pl.SendFlags |= PLAYER_MODELINDEX;
	}
	if (pl.old_origin[0] != pl.origin[0]) {
		pl.SendFlags |= PLAYER_ORIGIN;
	}
	if (pl.old_origin[1] != pl.origin[1]) {
		pl.SendFlags |= PLAYER_ORIGIN;
	}
	if (pl.old_origin[2] != pl.origin[2]) {
		pl.SendFlags |= PLAYER_ORIGIN_Z;
	}
	if (pl.old_angles[0] != pl.angles[0]) {
		pl.SendFlags |= PLAYER_ANGLES_X;
	}
	if (pl.old_angles[1] != pl.angles[1]) {
		pl.SendFlags |= PLAYER_ANGLES_Y;
	}
	if (pl.old_angles[2] != pl.angles[2]) {
		pl.SendFlags |= PLAYER_ANGLES_Z;
	}
	if (pl.old_velocity[0] != pl.velocity[0]) {
		pl.SendFlags |= PLAYER_VELOCITY;
	}
	if (pl.old_velocity[1] != pl.velocity[1]) {
		pl.SendFlags |= PLAYER_VELOCITY;
	}
	if (pl.old_velocity[2] != pl.velocity[2]) {
		pl.SendFlags |= PLAYER_VELOCITY_Z;
	}
	if (pl.old_flags != pl.flags) {
		pl.SendFlags |= PLAYER_FLAGS;
	}
	if (pl.old_activeweapon != pl.activeweapon) {
		pl.SendFlags |= PLAYER_WEAPON;
	}
	if (pl.old_items != pl.g_items) {
		pl.SendFlags |= PLAYER_ITEMS;
	}
	if (pl.old_health != pl.health) {
		pl.SendFlags |= PLAYER_HEALTH;
	}
	if (pl.old_armor != pl.armor) {
		pl.SendFlags |= PLAYER_ARMOR;
	}
	if (pl.old_movetype != pl.movetype) {
		pl.SendFlags |= PLAYER_MOVETYPE;
	}
	if (pl.old_viewofs != pl.view_ofs[2]) {
		pl.SendFlags |= PLAYER_VIEWOFS;
	}
	if (pl.old_baseframe != pl.baseframe) {
		pl.SendFlags |= PLAYER_BASEFRAME;
	}
	if (pl.old_frame != pl.frame) {
		pl.SendFlags |= PLAYER_FRAME;
	}
	if (pl.old_a_ammo1 != pl.a_ammo1) {
		pl.SendFlags |= PLAYER_AMMO1;
	}
	if (pl.old_a_ammo2 != pl.a_ammo2) {
		pl.SendFlags |= PLAYER_AMMO2;
	}
	if (pl.old_a_ammo3 != pl.a_ammo3) {
		pl.SendFlags |= PLAYER_AMMO3;
	}

	pl.old_modelindex = pl.modelindex;
	pl.old_origin = pl.origin;
	pl.old_angles = pl.angles;
	pl.old_velocity = pl.velocity;
	pl.old_flags = pl.flags;
	pl.old_activeweapon = pl.activeweapon;
	pl.old_items = pl.g_items;
	pl.old_health = pl.health;
	pl.old_armor = pl.armor;
	pl.old_movetype = pl.movetype;
	pl.old_viewofs = pl.view_ofs[2];
	pl.old_baseframe = pl.baseframe;
	pl.old_frame = pl.frame;
	pl.old_a_ammo1 = pl.a_ammo1;
	pl.old_a_ammo2 = pl.a_ammo2;
	pl.old_a_ammo3 = pl.a_ammo3;
}
void
Game_RunClientCommand(void)
{
	Footsteps_Update();
	QPhysics_Run(self);
}

void
Game_DecodeChangeParms(void)
{
	player pl = (player)self;
	g_landmarkpos[0] = parm1;
	g_landmarkpos[1] = parm2;
	g_landmarkpos[2] = parm3;
	pl.angles[0] = parm4;
	pl.angles[1] = parm5;
	pl.angles[2] = parm6;
	pl.velocity[0] = parm7;
	pl.velocity[1] = parm8;
	pl.velocity[2] = parm9;
	pl.g_items = parm10;
	pl.activeweapon = parm11;
}

void
Game_SetChangeParms(void)
{
	player pl = (player)self;
	parm1 = g_landmarkpos[0];
	parm2 = g_landmarkpos[1];
	parm3 = g_landmarkpos[2];
	parm4 = pl.angles[0];
	parm5 = pl.angles[1];
	parm6 = pl.angles[2];
	parm7 = pl.velocity[0];
	parm8 = pl.velocity[1];
	parm9 = pl.velocity[2];
	parm10 = pl.g_items;
	parm11 = pl.activeweapon;
}

void
Game_PutClientInServer(void)
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
	pl.model = "models/player.mdl";
	
	string mymodel = infokey(pl, "model");

	if (mymodel) {
		mymodel = sprintf("models/player/%s/%s.mdl", mymodel, mymodel);
		if (whichpack(mymodel)) {
			pl.model = mymodel;
		}
	} 
	setmodel(pl, pl.model);

	setsize(pl, VEC_HULL_MIN, VEC_HULL_MAX);
	pl.view_ofs = VEC_PLAYER_VIEWPOS;
	pl.velocity = [0,0,0];
	pl.gravity = __NULL__;
	pl.frame = 1;
	pl.SendEntity = Player_SendEntity;
	pl.SendFlags = UPDATE_ALL;

	pl.customphysics = Empty;
	pl.vPain = Player_Pain;
	pl.vDeath = Player_Death;
	pl.iBleeds = TRUE;
	forceinfokey(pl, "*spec", "0");
	forceinfokey(self, "*deaths", ftos(self.deaths));

	if (cvar("sv_playerslots") == 1) {
		Game_DecodeChangeParms();

		if (startspot != "") {
			setorigin(pl, Landmark_GetSpot());
		} else {
			spot = find(world, classname, "info_player_start");
			setorigin(pl, spot.origin);
			pl.angles = spot.angles;
			pl.fixangle = TRUE;
		}
	} else {
		spot = Spawn_SelectRandom("info_player_deathmatch");
		setorigin(pl, spot.origin);
		pl.angles = spot.angles;
		pl.fixangle = TRUE;
		pl.g_items |= ITEM_SUIT;
	}
}

void
SV_SendChat(entity sender, string msg, entity eEnt, float fType)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, fType == 0 ? EV_CHAT:EV_CHAT_TEAM);
	WriteByte(MSG_MULTICAST, num_for_edict(sender) - 1); 
	WriteByte(MSG_MULTICAST, sender.team); 
	WriteString(MSG_MULTICAST, msg);
	if (eEnt) {
		msg_entity = eEnt;
		multicast([0,0,0], MULTICAST_ONE);
	} else {
		multicast([0,0,0], MULTICAST_ALL);
	}

	localcmd(sprintf("echo [SERVER] %s: %s\n", sender.netname, msg));
}

void
Game_ParseClientCommand(string cmd)
{
	tokenize(cmd);

	if (argv(1) == "timeleft") {
		string msg;
		string timestring;
		float timeleft;
		timeleft = cvar("mp_timelimit") - (time / 60);
		timestring = Vox_TimeToString(timeleft);
		msg = sprintf("we have %s minutes remaining", timestring);
		Vox_Singlecast(self, msg);
		return;
	}

	if (argv(0) == "say") {
		SV_SendChat(self, argv(1), world, 0);
		return;
	} else if (argv(0) == "say_team") {
		entity a;
		for (a = world; (a = find(a, classname, "player"));) { 
			if (a.team == self.team) {
				SV_SendChat(self, argv(1), a, 1);
			}
		}
		return;
	}

	clientcommand(self, cmd);
}

void
Game_SetNewParms(void)
{

}
