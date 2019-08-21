/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

void Player_Pain(int hit)
{
	
}

void weaponbox_spawn(player);
void Player_Death(int hit)
{
	player pl = (player)self;
	weaponbox_spawn(pl);
	pl.movetype = MOVETYPE_NONE;
	pl.solid = SOLID_NOT;
	pl.takedamage = DAMAGE_NO;
	pl.flags &= ~FL_FLASHLIGHT;
	pl.health = pl.armor = pl.activeweapon = pl.g_items = 0;
	
	pl.think = PutClientInServer;
	pl.nextthink = time + 4.0f;
	sound(pl, CHAN_AUTO, "fvox/flatline.wav", 1.0, ATTN_NORM);

	/* Let's handle corpses on the clientside */
	entity corpse = spawn();
	setorigin(corpse, pl.origin + [0,0,32]);
	setmodel(corpse, pl.model);
	setsize(corpse, VEC_HULL_MIN, VEC_HULL_MAX);
	corpse.movetype = MOVETYPE_TOSS;
	corpse.solid = SOLID_TRIGGER;
	corpse.modelindex = pl.modelindex;
	corpse.frame = ANIM_DIESIMPLE;
	corpse.angles = pl.angles;
	corpse.velocity = pl.velocity;
}

/*
====================
UseWorkaround
====================
*/
void UseWorkaround(entity eTarget)
{
	eActivator = self;
	entity eOldSelf = self;
	self = eTarget;
	self.PlayerUse();
	self = eOldSelf;
}

/*
====================
Player_UseDown
====================
*/
void Player_UseDown(void)
{
	if (self.health <= 0) {
		return;
	} else if (!(self.gflags & GF_USE_RELEASED)) {
		return;
	}
	
	vector vSource;

	makevectors(self.v_angle);
	vSource = self.origin + self.view_ofs;
	traceline (vSource, vSource + (v_forward * 64), FALSE, self);

	if (trace_ent.PlayerUse) {
		self.gflags &= ~GF_USE_RELEASED;
		
		UseWorkaround(trace_ent);

		/* Some entities want to support Use spamming */
		if (!(self.gflags & GF_USE_RELEASED)) {
			sound(self, CHAN_ITEM, "common/wpn_select.wav", 0.25, ATTN_IDLE);
		}
	} else {
		sound(self, CHAN_ITEM, "common/wpn_denyselect.wav", 0.25, ATTN_IDLE);
		self.gflags &= ~GF_USE_RELEASED;
	}
}

/*
====================
Player_UseUp
====================
*/
void Player_UseUp(void) {
	if (!(self.gflags & GF_USE_RELEASED)) {
		self.gflags |= GF_USE_RELEASED;
	}
}

/*
=================
Player_SendEntity
=================
*/
float Player_SendEntity(entity ePEnt, float fChanged)
{
	player pl = (player)self;
	if (pl.health <= 0 && ePEnt != pl) {
		return FALSE;
	}

	WriteByte(MSG_ENTITY, ENT_PLAYER);
	WriteShort(MSG_ENTITY, pl.modelindex);
	WriteCoord(MSG_ENTITY, pl.origin[0]);
	WriteCoord(MSG_ENTITY, pl.origin[1]);
	WriteCoord(MSG_ENTITY, pl.origin[2]);
	WriteFloat(MSG_ENTITY, pl.v_angle[0]);
	WriteFloat(MSG_ENTITY, pl.angles[1]);
	WriteFloat(MSG_ENTITY, pl.angles[2]);
	WriteCoord(MSG_ENTITY, pl.velocity[0]);
	WriteCoord(MSG_ENTITY, pl.velocity[1]);
	WriteCoord(MSG_ENTITY, pl.velocity[2]);
	WriteFloat(MSG_ENTITY, pl.flags);
	WriteByte(MSG_ENTITY, pl.activeweapon);
	WriteFloat(MSG_ENTITY, pl.weapontime);
	WriteFloat(MSG_ENTITY, pl.g_items);
	WriteByte(MSG_ENTITY, pl.health);
	WriteByte(MSG_ENTITY, pl.armor);
	WriteByte(MSG_ENTITY, pl.movetype);
	WriteFloat(MSG_ENTITY, pl.view_ofs[2]);
	WriteFloat(MSG_ENTITY, pl.viewzoom);
	WriteFloat(MSG_ENTITY, pl.jumptime);
	WriteFloat(MSG_ENTITY, pl.teleport_time);

	WriteByte(MSG_ENTITY, pl.baseframe);
	WriteByte(MSG_ENTITY, pl.frame);

	WriteByte(MSG_ENTITY, pl.a_ammo1);
	WriteByte(MSG_ENTITY, pl.a_ammo2);
	WriteByte(MSG_ENTITY, pl.a_ammo3);
	WriteFloat(MSG_ENTITY, pl.w_attack_next);
	WriteFloat(MSG_ENTITY, pl.w_idle_next);
	return TRUE;
}

void Weapons_Draw(void);
void CSEv_PlayerSwitchWeapon_f(float w)
{
	player pl = (player)self;
	pl.activeweapon = (int)w;
	Weapons_Draw();
}
