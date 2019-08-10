/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

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
	precache_model("models/v_tripmine.mdl");
	precache_model("models/p_tripmine.mdl");
	precache_sound("weapons/mine_deploy.wav");
	precache_sound("weapons/mine_charge.wav");
	precache_sound("weapons/mine_activate.wav");
}
string w_tripmine_vmodel(void)
{
	return "models/v_tripmine.mdl";
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

void w_tripmine_draw(void)
{
#ifdef CSQC
	Weapons_ViewAnimation(TRIPMINE_DRAW);
#else
	player pl = (player)self;
	Weapons_UpdateAmmo(pl, __NULL__, pl.ammo_tripmine, __NULL__);
#endif
}
void w_tripmine_holster(void)
{
	
}

#ifdef SSQC
void w_tripmine_trip(int unused)
{
	/* This is to prevent infinite loops in Damage_Radius */
	self.vDeath =
	self.vPain = __NULL__;
	self.takedamage = DAMAGE_NO;

	Effect_CreateExplosion(self.origin);
	Damage_Radius(self.origin, self.owner, 150, 150 * 2.5f, TRUE);
	sound(self, CHAN_WEAPON, sprintf( "weapons/explode%d.wav", floor( random() * 2 ) + 3 ), 1, ATTN_NORM);
	remove(self);
}
void w_tripmine_ready(void)
{
	makevectors(self.angles);
	traceline(self.origin, self.origin + v_forward * 2048, FALSE, self);

	if (!self.health) {
		self.health = 1;
		self.vDeath =
		self.vPain = w_tripmine_trip;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
		setsize(self, [-8,-8,-8], [8,8,8]);
		self.armor = trace_plane_dist;
		sound(self, CHAN_WEAPON, "weapons/mine_activate.wav", 1, ATTN_NORM);
	}

	if (trace_plane_dist != self.armor) {
		w_tripmine_trip(0);
	}
	self.nextthink = time;
}
#endif

void w_tripmine_primary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next > 0.0) {
		return;
	}
	
	Weapons_MakeVectors();
	traceline(Weapons_GetCameraPos(), Weapons_GetCameraPos() + v_forward * 64, FALSE, pl);

	if (trace_fraction == 1.0f) {
		return;
	}
	
#ifdef CSQC
	Weapons_ViewAnimation(TRIPMINE_FIRE2);
#else
	entity mine = spawn();
	setmodel(mine, "models/v_tripmine.mdl");
	setorigin(mine, trace_endpos);
	mine.frame = TRIPMINE_WORLD;
   	mine.angles = vectoangles( trace_plane_normal );
   	setorigin(mine, trace_endpos - (v_forward * 4));
	mine.think = w_tripmine_ready;
	mine.nextthink = time + 4.0f;
	//mine.owner = pl;
	sound(mine, CHAN_WEAPON, "weapons/mine_charge.wav", 1, ATTN_NORM);
	sound(self, CHAN_WEAPON, "weapons/mine_deploy.wav", 1, ATTN_NORM);
#endif

	pl.w_attack_next = 0.5f;
	pl.w_idle_next = 2.5f;
}
void w_tripmine_secondary(void)
{
	
}
void w_tripmine_reload(void)
{
	
}
void w_tripmine_release(void)
{
	int r;
	player pl = (player)self;
	if (pl.w_idle_next > 0.0) {
		return;
	}

	r = floor(random(0,3));

	switch (r) {
	case 0:
		Weapons_ViewAnimation(TRIPMINE_IDLE1);
		pl.w_idle_next = 3.0f;
		break;
	case 1:
		Weapons_ViewAnimation(TRIPMINE_IDLE2);
		pl.w_idle_next = 2.0f;
		break;
	default:
		Weapons_ViewAnimation(TRIPMINE_FIDGET);
		pl.w_idle_next = 3.333333f;
		break;
	}
}

float w_tripmine_aimanim(void)
{
#ifdef SSQC
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMTRIPMINE : ANIM_AIMTRIPMINE;
#endif
}

void w_tripmine_hudpic(int s, vector pos)
{
#ifdef CSQC
	if (s) {
		drawsubpic(pos, [170,45], "sprites/640hud6.spr_0.tga", [0,90/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hud3.spr_0.tga", [0,90/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_tripmine =
{
	ITEM_TRIPMINE,
	4,
	2,
	w_tripmine_draw,
	w_tripmine_holster,
	w_tripmine_primary,
	w_tripmine_secondary,
	w_tripmine_reload,
	w_tripmine_release,
	__NULL__,
	w_tripmine_precache,
	__NULL__,
	w_tripmine_vmodel,
	w_tripmine_wmodel,
	w_tripmine_pmodel,
	w_tripmine_deathmsg,
	w_tripmine_aimanim,
	w_tripmine_hudpic
};

#ifdef SSQC
void weapon_tripmine(void) {
	Weapons_InitItem(WEAPON_TRIPMINE);
}
#endif
