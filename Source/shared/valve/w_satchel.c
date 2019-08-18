/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

enum
{
	SATCHEL_IDLE,
	SATCHEL_FIDGET,
	SATCHEL_DRAW,
	SATCHEL_THROW
};

enum
{
	RADIO_IDLE,
	RADIO_FIDGET,
	RADIO_DRAW,
	RADIO_USE,
	RADIO_HOLSTER
};

string w_satchel_vmodel(void)
{
	return "models/v_satchel_radio.mdl";
}
string w_satchel_wmodel(void)
{
	return "models/w_satchel.mdl";
}
string w_satchel_pmodel(void)
{
	return "models/p_satchel.mdl";
}
string w_satchel_deathmsg(void)
{
	return "";
}
void w_satchel_precache(void)
{
	precache_model("models/w_satchel.mdl");
	precache_model("models/v_satchel.mdl");
	precache_model("models/v_satchel_radio.mdl");
	precache_model("models/p_satchel.mdl");
}

void w_satchel_pickup(void)
{
#ifdef SSQC
	player pl = (player)self;
	pl.ammo_satchel = bound(0, pl.ammo_satchel + 1, 15);
#endif
}

void w_satchel_draw(void)
{
#ifdef CSQC
	Weapons_ViewAnimation(SATCHEL_DRAW);
#else
	player pl = (player)self;
	Weapons_UpdateAmmo(pl, pl.satchel_chg, pl.ammo_satchel, __NULL__);
#endif
}

void w_satchel_holster(void)
{
	
}

#ifdef SSQC
void s_satchel_drop(entity master, vector src, vector vel)
{
	entity satch;
	satch = spawn();
	satch.owner = master;
	satch.classname = "satchel";
	satch.movetype = MOVETYPE_BOUNCE;
	satch.solid = SOLID_BBOX;
	satch.frame = 1;
	satch.gravity = 0.5f;
	satch.friction = 0.8f;
	satch.velocity = vel;
	satch.avelocity = [0,400,0];
	setmodel(satch, "models/w_satchel.mdl");
	setsize(satch, [-4,-4,-4], [4,4,4]);
	setorigin(satch, src);
}
void s_satchel_detonate(entity master)
{
	for (entity b = world; (b = find(b, ::classname, "satchel"));) {
		if (b.owner == master) {
			Effect_CreateExplosion(b.origin);
			Damage_Radius(b.origin, master, 150, 150 * 2.5f, TRUE);
			sound(b, CHAN_WEAPON, sprintf( "weapons/explode%d.wav", floor( random() * 2 ) + 3 ), 1, ATTN_NORM);
			remove(b);
		}
	}
}
#endif

void w_satchel_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next) {
		return;
	}

	/* Ammo check */
#ifdef CSQC
	if (pl.a_ammo1 <= 0 && pl.a_ammo2 <= 0) {
		return;
	}
#else
	if (pl.satchel_chg <= 0 && pl.ammo_satchel <= 0) {
        return;
	}
#endif

#ifdef SSQC
	if (!pl.satchel_chg) {
		vector throw;
		
		Weapons_MakeVectors();
		throw = pl.velocity + (v_forward * 274);
		s_satchel_drop(self, pl.origin, throw);
		pl.satchel_chg++;
		pl.ammo_satchel--;
	} else {
		s_satchel_detonate(pl);
		pl.satchel_chg = 0;

		if (pl.ammo_satchel <= 0) {
			Weapons_RemoveItem(pl, WEAPON_SATCHEL);
		}
	}
	Weapons_UpdateAmmo(pl, pl.satchel_chg, pl.ammo_satchel, __NULL__);
#else
	if (!pl.a_ammo1) {
		Weapons_ViewAnimation(RADIO_DRAW);
	} else {
		Weapons_ViewAnimation(RADIO_USE);
	}
#endif

	pl.w_attack_next = 1.0f;
	pl.w_idle_next = 2.5f;
}
void w_satchel_secondary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next) {
		return;
	}

    /* Ammo check */
#ifdef CSQC
	if (pl.a_ammo2 <= 0) {
		return;
	}
#else
	if (pl.ammo_satchel <= 0) {
		return;
	}
#endif

#ifdef SSQC
	vector throw;
	Weapons_MakeVectors();
	throw = pl.velocity + (v_forward * 274);
	s_satchel_drop(self, pl.origin, throw);
	pl.satchel_chg++;
	pl.ammo_satchel--;
	Weapons_UpdateAmmo(pl, pl.satchel_chg, pl.ammo_satchel, __NULL__);
#else
	pl.a_ammo2--;
	Weapons_ViewAnimation(RADIO_DRAW);
#endif

	pl.w_attack_next = 1.0f;
	pl.w_idle_next = 2.5f;
}
void w_satchel_reload(void)
{
	
}
void w_satchel_release(void)
{
#ifdef CSQC
	player pl = (player)self;
	if (pl.w_idle_next) {
		return;
	}

	Weapons_ViewAnimation(RADIO_FIDGET);
	pl.w_idle_next = 15.0f;
#endif
}

float w_satchel_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMSQUEAK : ANIM_AIMSQUEAK;
}

void w_satchel_hud(void)
{
#ifdef CSQC
	HUD_DrawAmmo2();
#endif
}

void w_satchel_hudpic(int s, vector pos)
{
#ifdef CSQC
	if (s) {
		drawsubpic(pos, [170,45], "sprites/640hud6.spr_0.tga", [0,45/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hud3.spr_0.tga", [0,45/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_satchel =
{
	ITEM_SATCHEL,
	4,
	1,
	w_satchel_draw,
	w_satchel_holster,
	w_satchel_primary,
	w_satchel_secondary,
	w_satchel_reload,
	w_satchel_release,
	w_satchel_hud,
	w_satchel_precache,
	w_satchel_pickup,
	w_satchel_vmodel,
	w_satchel_wmodel,
	w_satchel_pmodel,
	w_satchel_deathmsg,
	w_satchel_aimanim,
	w_satchel_hudpic
};

#ifdef SSQC
void weapon_satchel(void) {
	Weapons_InitItem(WEAPON_SATCHEL);
}
#endif
