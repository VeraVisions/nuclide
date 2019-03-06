/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

enum
{
	HAMMER_IDLE1,
	HAMMER_DRAW,
	HAMMER_HOLSTER,
	HAMMER_ATTACK1,
	HAMMER_ATTACK2,
	HAMMER_IDLE2,
	HAMMER_IDLE3,
	HAMMER_HOLSTER2,
	HAMMER_HOLSTER3
};

void w_hammer_precache(void)
{
	precache_sound("sh/ham_hitbod1.wav");
	precache_sound("sh/ham_hitbod2.wav");
	precache_sound("sh/ham_hitbod3.wav");
	precache_sound("sh/ham_hitw.wav");
	precache_sound("sh/ham_swing.wav");
	precache_model("models/p_hammer.mdl");
	precache_model("models/v_hammer.mdl");
}

string w_hammer_vmodel(void)
{
	return "models/v_hammer.mdl";
}
string w_hammer_pmodel(void)
{
	return "models/p_hammer.mdl";
}
string w_hammer_deathmsg(void)
{
	return "%s killed %s with hammer.";
}

void w_hammer_draw(void)
{
#ifdef CSQC
	Weapons_ViewAnimation(HAMMER_DRAW);
#else
	player pl = (player)self;
	Weapons_UpdateAmmo(pl, __NULL__, __NULL__, __NULL__);
#endif
}

void w_hammer_holster(void)
{
#ifdef CSQC
	Weapons_ViewAnimation(HAMMER_HOLSTER);
#endif
}
void w_hammer_primary(void)
{
	player pl = (player)self;

#ifdef CSQC
	if (!pl.w_attack_next) {
		if (pSeat->eViewModel.frame != HAMMER_HOLSTER2) {
			Weapons_ViewAnimation(HAMMER_HOLSTER2);
			pl.w_attack_next = 0.5f;
		}
	}
#else
	if (!pl.w_attack_next) {
		/* Hack */
		if (pl.a_ammo1 != 1) {
			pl.a_ammo1 = 1;
			pl.w_attack_next = 0.5f;
		}
	}
#endif
	pl.w_idle_next = 2.5f;
}
void w_hammer_secondary(void)
{
	player pl = (player)self;

#ifdef CSQC
	if (!pl.w_attack_next) {
		if (pSeat->eViewModel.frame != HAMMER_HOLSTER3) {
			Weapons_ViewAnimation(HAMMER_HOLSTER3);
			pl.w_attack_next = 0.5f;
		}
	}
#else
	if (!pl.w_attack_next) {
		/* Hack */
		if (pl.a_ammo1 != 2) {
			pl.a_ammo1 = 2;
			pl.w_attack_next = 0.5f;
		}
	}
#endif
	pl.w_idle_next = 2.5f;
}
void w_hammer_reload(void)
{
	
}
void w_hammer_release(void)
{
	player pl = (player)self;

	if (pl.w_attack_next) {
		return;
	}

#ifdef CSQC
	if (pSeat->eViewModel.frame == HAMMER_HOLSTER2) {
		Weapons_ViewAnimation(HAMMER_ATTACK1);
		pl.w_attack_next = 1.0f;
	} else if (pSeat->eViewModel.frame == HAMMER_HOLSTER3) {
		Weapons_ViewAnimation(HAMMER_ATTACK2);
		pl.w_attack_next = 0.75f;
	}

	/* Pure cosmetics start here */
	if (pl.w_idle_next) {
		return;
	}

	int r = floor(random(0,3));
	switch (r) {
	case 0:
		Weapons_ViewAnimation(HAMMER_IDLE1);
		break;
	case 1:
		Weapons_ViewAnimation(HAMMER_IDLE2);
		break;
	case 2:
		Weapons_ViewAnimation(HAMMER_IDLE3);
		break;
	}
	pl.w_idle_next = 10.0f;
#else
	int hitsound = 0;
	vector src = pl.origin + pl.view_ofs;
	makevectors(pl.v_angle);
	traceline(src, src + v_forward * 64, FALSE, self);

	/* Standard attack */
	if (pl.a_ammo1 == 1) {
		if (trace_ent.takedamage) {
			hitsound = floor(random(1, 4));
			Damage_Apply(trace_ent, self, 100, trace_endpos, FALSE);

			if (trace_ent.classname == "monster_scientist") {
				trace_ent.movetype = MOVETYPE_TOSS;
				trace_ent.velocity = v_forward * 768 + v_up * 256;
			}
		} else {
			if (trace_fraction < 1.0) {
				hitsound = 4;
			} 
		}
	} else if (pl.a_ammo1 == 2) {
		if (trace_ent.takedamage) {
			hitsound = floor(random(1, 4));
			Damage_Apply(trace_ent, self, 200, trace_endpos, FALSE);
		} else {
			if (trace_fraction < 1.0) {
				hitsound = 4;
			} 
		}
	} else {
		return;
	}

	switch (hitsound) {
	case 1:
		Weapons_PlaySound(pl, CHAN_WEAPON, "sh/ham_hitbod1.wav", 1, ATTN_NORM);
		break;
	case 2:
		Weapons_PlaySound(pl, CHAN_WEAPON, "sh/ham_hitbod2.wav", 1, ATTN_NORM);
		break;
	case 3:
		Weapons_PlaySound(pl, CHAN_WEAPON, "sh/ham_hitbod3.wav", 1, ATTN_NORM);
		break;
	case 4:
		Weapons_PlaySound(pl, CHAN_WEAPON, "sh/ham_hitw.wav", 1, ATTN_NORM);
		break;
	default:
		Weapons_PlaySound(pl, CHAN_WEAPON, "sh/ham_swing.wav", 1, ATTN_NORM);
	}

	/* Reset the hack */
	pl.a_ammo1 = 0;
#endif
}

void w_hammer_hudpic(int s, vector pos)
{
#ifdef CSQC
	if (s) {
		drawsubpic(pos, [170,45], "sprites/hammer.spr_0.tga", [0,48/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/hammer.spr_0.tga", [0,0], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_hammer =
{
	ITEM_HAMMER,
	0,
	1,
	w_hammer_draw,
	w_hammer_holster,
	w_hammer_primary,
	w_hammer_secondary,
	w_hammer_reload,
	w_hammer_release,
	__NULL__,
	w_hammer_precache,
	__NULL__,
	w_hammer_vmodel,
	__NULL__,
	w_hammer_pmodel,
	w_hammer_deathmsg,
	w_hammer_hudpic
};
