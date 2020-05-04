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

/*QUAKED weapon_tripmine (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/v_tripmine.mdl"

HALF-LIFE (1998) ENTITY

Tripmine Weapon

*/

/* MONSTER_TRIPMINE SEGMENT 
 * 
 * Because not being able to place it around levels would be boring.
 * Some maps, such as subtransit and a few singleplayer chapters have this. */

#ifdef SERVER
class monster_tripmine:CBaseMonster
{
	void(void) monster_tripmine;

	virtual float(entity, float) SendEntity;
	virtual void(int) Trip;
	virtual void(void) Ready;
	virtual void(void) Respawn;
};

float
monster_tripmine::SendEntity(entity pvsent, float flags)
{
	WriteByte(MSG_ENTITY, ENT_TRIPMINE);
	WriteCoord(MSG_ENTITY, self.origin[0]);
	WriteCoord(MSG_ENTITY, self.origin[1]);
	WriteCoord(MSG_ENTITY, self.origin[2]);
	WriteCoord(MSG_ENTITY, self.angles[0]);
	WriteCoord(MSG_ENTITY, self.angles[1]);
	WriteCoord(MSG_ENTITY, self.angles[2]);
	WriteFloat(MSG_ENTITY, self.armor);
	WriteByte(MSG_ENTITY, self.health);
	WriteShort(MSG_ENTITY, self.modelindex);
	return TRUE;
}

void
monster_tripmine::Trip(int walkthrough)
{
	float dmg;
	if (!walkthrough) {
		real_owner = g_eAttacker;
	}

	/* This is to prevent infinite loops in Damage_Radius */
	Death =
	Pain = __NULL__;
	takedamage = DAMAGE_NO;
	dmg = Skill_GetValue("plr_tripmine");
	FX_Explosion(origin);
	Damage_Radius(origin, real_owner, dmg, dmg * 2.5f, TRUE, WEAPON_TRIPMINE);
	sound(this, CHAN_WEAPON, sprintf("weapons/explode%d.wav", floor(random() * 2) + 3), 1, ATTN_NORM);
	remove(this);
}

void
monster_tripmine::Ready(void)
{
	makevectors(angles);
	traceline(origin, origin + v_forward * 2048, FALSE, this);

	if (!health) {
		SendFlags = -1;
		health = 1;
		Death =
		Pain = Trip;
		takedamage = DAMAGE_YES;
		armor = trace_plane_dist;
		Sound_Play(this, CHAN_WEAPON, "weapon_tripmine.activate");
	}

	if (trace_plane_dist != armor) {
		Trip(1);
	}
	nextthink = time;
}

void
monster_tripmine::Respawn(void)
{
	SetModel("models/v_tripmine.mdl");
	SetSolid(SOLID_NOT);
	SetMovetype(MOVETYPE_NONE);
	SetSize([-8,-8,-8], [8,8,8]);
	SetOrigin(origin);
	SendFlags = 1; /* force update */

	/* ready in 4 seconds flat */
	think = Ready;

	/* fast beam */
	if (spawnflags & 1) {
		nextthink = time;
	} else {
		nextthink = time + 4.0f;
	}
}

void
monster_tripmine::monster_tripmine(void)
{
	Respawn();
}
#endif

/* The WEAPON_TRIPMINE code
 * 
 * Here is where the actual 'weapon' logic happens that the player itself
 * runs. It obviously won't work without MONSTER_TRIPMINE */

enum
{
	TRIPMINE_IDLE1,
	TRIPMINE_IDLE2,
	TRIPMINE_FIRE1,
	TRIPMINE_FIRE2,
	TRIPMINE_FIDGET,
	TRIPMINE_HOLSTER,
	TRIPMINE_DRAW,
	TRIPMINE_WORLD,
	TRIPMINE_GROUND,
};

void w_tripmine_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_tripmine.deploy");
	Sound_Precache("weapon_tripmine.charge");
	Sound_Precache("weapon_tripmine.activate");
	precache_model("models/v_tripmine.mdl");
#else
	precache_model("models/p_tripmine.mdl");
#endif
}
void w_tripmine_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, -1, pl.ammo_tripmine, -1);
#endif
}
string w_tripmine_wmodel(void)
{
	return "models/v_tripmine.mdl";
}
string w_tripmine_pmodel(void)
{
	return "models/p_tripmine.mdl";
}
string w_tripmine_deathmsg(void)
{
	return "";
}
int w_tripmine_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (pl.ammo_tripmine < MAX_A_TRIPMINE) {
		pl.ammo_tripmine = bound(0, pl.ammo_tripmine + 1, MAX_A_TRIPMINE);
	} else {
		return FALSE;
	}
#endif
	return TRUE;
}

void w_tripmine_draw(void)
{
#ifdef CLIENT
	Weapons_SetModel("models/v_tripmine.mdl");
	Weapons_ViewAnimation(TRIPMINE_DRAW);
#endif
}
void w_tripmine_holster(void)
{
	
}

#ifdef CLIENT
.float health;
.float armor;
float w_tripmine_predraw(void)
{
	if (self.health) {
		makevectors(self.angles);
		traceline(self.origin, self.origin + v_forward * 8196, FALSE, self);
		trailparticles(BEAM_TRIPMINE, self, self.origin, trace_endpos);
	}
	addentity(self);
	return PREDRAW_NEXT;
}
void w_tripmine_parse(void)
{
	self.origin[0] = readcoord();
	self.origin[1] = readcoord();
	self.origin[2] = readcoord();
	self.angles[0] = readcoord();
	self.angles[1] = readcoord();
	self.angles[2] = readcoord();
	self.armor = readfloat();
	self.health = readbyte();
	self.modelindex = readshort();
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_NONE;
	self.predraw = w_tripmine_predraw;
	self.drawmask = MASK_ENGINE;
	self.frame = TRIPMINE_WORLD;
	setcustomskin(self, "", "geomset 0 2\ngeomset 1 2\n");
	setorigin(self, self.origin);
}
#endif

void w_tripmine_primary(void)
{
	player pl = (player)self;
	vector src;

	if (pl.w_attack_next > 0.0) {
		return;
	}

#ifdef CLIENT
	if (pl.a_ammo2 <= 0) {
		return;
	}
#else
	if (pl.ammo_tripmine <= 0) {
		return;
	}
#endif

	src = Weapons_GetCameraPos();
	Weapons_MakeVectors();
	traceline(src, src + v_forward * 64, FALSE, pl);

	if (trace_fraction >= 1.0) {
		return;
	}

#ifdef CLIENT
	pl.a_ammo2--;
	Weapons_ViewAnimation(TRIPMINE_FIRE2);
#else
	pl.ammo_tripmine--;
	vector ang = vectoangles(trace_plane_normal);
	monster_tripmine mine = spawn(monster_tripmine, real_owner: self, angles: ang);
	mine.SetOrigin(trace_endpos - (v_forward * 8));

	Sound_Play(self, CHAN_WEAPON, "weapon_tripmine.deploy");
	Sound_Play(mine, CHAN_WEAPON, "weapon_tripmine.charge");
#endif

	pl.a_ammo3 = 1;
	pl.w_attack_next =
	pl.w_idle_next = 0.5f;
}

void w_tripmine_release(void)
{
	player pl = (player)self;

	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.a_ammo3 == 1) {
		Weapons_ViewAnimation(TRIPMINE_DRAW);
#ifdef SERVER
		if (pl.ammo_tripmine <= 0) {
			Weapons_RemoveItem(pl, WEAPON_TRIPMINE);
		}
#endif
		pl.a_ammo3 = 0;
		pl.w_attack_next = 0.5f;
		pl.w_idle_next = 3.0f;
		return;
	}

	int r = (float)input_sequence % 3;
	switch (r) {
	case 1:
		Weapons_ViewAnimation(TRIPMINE_IDLE1);
		pl.w_idle_next = 3.0f;
		break;
	case 2:
		Weapons_ViewAnimation(TRIPMINE_IDLE2);
		pl.w_idle_next = 2.0f;
		break;
	default:
		Weapons_ViewAnimation(TRIPMINE_FIDGET);
		pl.w_idle_next = 3.34f;
		break;
	}
}

float w_tripmine_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMTRIPMINE : ANIM_AIMTRIPMINE;
}

void w_tripmine_hud(void)
{
#ifdef CLIENT
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [120/256,96/128], [24/256, 24/128], g_hud_color, pSeat->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void w_tripmine_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(pos, [170,45], "sprites/640hud6.spr_0.tga", [0,90/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hud3.spr_0.tga", [0,90/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_tripmine =
{
	.name		= "tripmine",
	.id			= ITEM_TRIPMINE,
	.slot		= 4,
	.slot_pos	= 2,
	.draw		= w_tripmine_draw,
	.holster	= w_tripmine_holster,
	.primary	= w_tripmine_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= w_tripmine_release,
	.crosshair	= w_tripmine_hud,
	.precache	= w_tripmine_precache,
	.pickup		= w_tripmine_pickup,
	.updateammo	= w_tripmine_updateammo,
	.wmodel		= w_tripmine_wmodel,
	.pmodel		= w_tripmine_pmodel,
	.deathmsg	= w_tripmine_deathmsg,
	.aimanim	= w_tripmine_aimanim,
	.hudpic		= w_tripmine_hudpic
};

#ifdef SERVER
void weapon_tripmine(void) {
	Weapons_InitItem(WEAPON_TRIPMINE);
}
#endif
