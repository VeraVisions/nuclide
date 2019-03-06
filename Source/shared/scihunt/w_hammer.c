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
	precache_sound("weapons/ham_hitbod1.wav");
	precache_sound("weapons/ham_hitbod2.wav");
	precache_sound("weapons/ham_hitbod3.wav");
	precache_sound("weapons/ham_hitw.wav");
	precache_sound("weapons/ham_swing.wav");
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
	
	if (pl.w_attack_next) {
		return;
	}

#ifdef CSQC
	Weapons_MakeVectors();
	vector src = pl.origin + pl.view_ofs;
	traceline(src, src + (v_forward * 32), FALSE, pl);

/** Launches ents, needs release, grab from idle
    makevectors(pl.v_angle);
    trace_ent.velocity = v_forward * 1200 + v_up * 240;
**/
	int r = floor(random(0,3));
	switch (r) {
	case 0:
		Weapons_ViewAnimation(trace_fraction >= 1 ? CROWBAR_ATTACK1MISS:CROWBAR_ATTACK1HIT);
		break;
	case 1:
		Weapons_ViewAnimation(trace_fraction >= 1 ? CROWBAR_ATTACK2MISS:CROWBAR_ATTACK2HIT);
		break;
	default:
		Weapons_ViewAnimation(trace_fraction >= 1 ? CROWBAR_ATTACK3MISS:CROWBAR_ATTACK3HIT);
	}

	if (trace_fraction >= 1.0) {
		pl.w_attack_next = 0.5f;
	} else {
		pl.w_attack_next = 0.25f;
	}
#else
	Weapons_MakeVectors();
	vector src = pl.origin + pl.view_ofs;
	traceline(src, src + (v_forward * 32), FALSE, pl);

	Weapons_PlaySound(pl, CHAN_WEAPON, "weapons/cbar_miss1.wav", 1, ATTN_NORM);

	if (trace_fraction >= 1.0) {
		pl.w_attack_next = 0.5f;
	} else {
		pl.w_attack_next = 0.25f;
		Effect_Impact(IMPACT_MELEE, trace_endpos, trace_plane_normal);
		
		if (trace_ent.takedamage) {
			Damage_Apply(trace_ent, self, 10, trace_endpos, FALSE );
			
			// TODO: Better way to find if it bleeds?
			if (trace_ent.iBleeds == 1) {
				if (random() < 0.33) {
					Weapons_PlaySound(pl, 8, "weapons/cbar_hitbod1.wav", 1, ATTN_NORM);
				} else if (random() < 0.66) {
					Weapons_PlaySound(pl, 8, "weapons/cbar_hitbod2.wav", 1, ATTN_NORM);
				} else {
					Weapons_PlaySound(pl, 8, "weapons/cbar_hitbod3.wav", 1, ATTN_NORM);
				}
			}
		} else {
			if (random() < 0.5) {
				Weapons_PlaySound(pl, 8, "weapons/cbar_hit1.wav", 1, ATTN_NORM);
			} else {
				Weapons_PlaySound(pl, 8, "weapons/cbar_hit2.wav", 1, ATTN_NORM);
			}
		}
	}
#endif
	pl.w_idle_next = 2.5f;
}
void w_hammer_secondary(void)
{
	
}
void w_hammer_reload(void)
{
	
}
void w_hammer_release(void)
{
#ifdef CSQC
	player pl = (player)self;
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
	w_hammer_pmodel,
	w_hammer_deathmsg,
	w_hammer_hudpic
};
