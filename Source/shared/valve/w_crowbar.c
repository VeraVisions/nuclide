/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

enum
{
	CROWBAR_IDLE,
	CROWBAR_DRAW,
	CROWBAR_HOLSTER,
	CROWBAR_ATTACK1HIT,
	CROWBAR_ATTACK1MISS,
	CROWBAR_ATTACK2MISS,
	CROWBAR_ATTACK2HIT,
	CROWBAR_ATTACK3MISS,
	CROWBAR_ATTACK3HIT
};

void w_crowbar_precache(void)
{
	precache_sound("weapons/cbar_miss1.wav");
	precache_sound("weapons/cbar_hit1.wav");
	precache_sound("weapons/cbar_hit2.wav");
	precache_sound("weapons/cbar_hitbod1.wav");
	precache_sound("weapons/cbar_hitbod2.wav");
	precache_sound("weapons/cbar_hitbod3.wav");
	precache_model("models/v_crowbar.mdl");
	precache_model("models/w_crowbar.mdl");
	precache_model("models/p_crowbar.mdl");
}

string w_crowbar_vmodel(void)
{
	return "models/v_crowbar.mdl";
}
string w_crowbar_wmodel(void)
{
	return "models/w_crowbar.mdl";
}
string w_crowbar_pmodel(void)
{
	return "models/p_crowbar.mdl";
}
string w_crowbar_deathmsg(void)
{
	return "%s was assaulted by %s's Crowbar.";
}

void w_crowbar_draw(void)
{
#ifdef CSQC
	Weapons_ViewAnimation(CROWBAR_DRAW);
#else
	player pl = (player)self;
	Weapons_UpdateAmmo(pl, __NULL__, __NULL__, __NULL__);
#endif
}

void w_crowbar_holster(void)
{
#ifdef CSQC
	Weapons_ViewAnimation(CROWBAR_HOLSTER);
#endif
}
void w_crowbar_primary(void)
{
	player pl = (player)self;
	
	if (pl.w_attack_next) {
		return;
	}

#ifdef CSQC
	Weapons_MakeVectors();
	vector src = pl.origin + pl.view_ofs;
	traceline(src, src + (v_forward * 32), FALSE, pl);

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
void w_crowbar_secondary(void)
{
	
}
void w_crowbar_reload(void)
{
	
}
void w_crowbar_release(void)
{
#ifdef CSQC
	player pl = (player)self;
	if (pl.w_idle_next) {
		return;
	}

	Weapons_ViewAnimation(CROWBAR_IDLE);
	pl.w_idle_next = 15.0f;
#endif
}

void w_crowbar_hudpic(int s, vector pos)
{
#ifdef CSQC
	if (s) {
		drawsubpic(pos, [170,45], "sprites/640hud4.spr_0.tga", [0,0], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hud1.spr_0.tga", [0,0], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_crowbar =
{
	ITEM_CROWBAR,
	0,
	0,
	w_crowbar_draw,
	w_crowbar_holster,
	w_crowbar_primary,
	w_crowbar_secondary,
	w_crowbar_reload,
	w_crowbar_release,
	__NULL__,
	w_crowbar_precache,
	__NULL__,
	w_crowbar_vmodel,
	w_crowbar_wmodel,
	w_crowbar_pmodel,
	w_crowbar_deathmsg,
	w_crowbar_hudpic
};

#ifdef SSQC
void weapon_crowbar(void) {
	Weapons_InitItem(WEAPON_CROWBAR);
}
#endif
