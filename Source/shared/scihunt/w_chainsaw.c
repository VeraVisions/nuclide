/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

enum
{
	CHAINSAW_STARTFIRE,
	CHAINSAW_CONTINUEFIRE,
	CHAINSAW_STOPFIRE,
	CHAINSAW_DEPLOY,
	CHAINSAW_HOLSTER,
	CHAINSAW_IDLE1,
	CHAINSAW_IDLE2,
};

void w_chainsaw_precache(void)
{
	precache_sound("sh/chainsaw_cutinto.wav");
	precache_sound("sh/chainsaw_cutintoflesh.wav");
	precache_sound("sh/chainsaw_idle.wav");
	precache_sound("sh/chainsaw_idle2.wav");
	precache_sound("sh/chainsaw_pullout.wav");
	precache_sound("sh/chainsaw_startup.wav");
	precache_model("models/v_chainsaw.mdl");
	precache_model("models/p_saw.mdl");
}

string w_chainsaw_vmodel(void)
{
	return "models/v_chainsaw.mdl";
}
string w_chainsaw_pmodel(void)
{
	return "models/p_saw.mdl";
}
string w_chainsaw_deathmsg(void)
{
	return "%s killed %s with chainsaw.";
}

void w_chainsaw_draw(void)
{
#ifdef CSQC
	Weapons_ViewAnimation(CHAINSAW_DEPLOY);
#else
	player pl = (player)self;
	Weapons_UpdateAmmo(pl, __NULL__, __NULL__, __NULL__);
#endif
}

void w_chainsaw_holster(void)
{
#ifdef CSQC
	Weapons_ViewAnimation(CHAINSAW_HOLSTER);
#endif
}
void w_chainsaw_primary(void)
{
	player pl = (player)self;
	
	if (pl.w_attack_next) {
		return;
	}

#ifdef CSQC
	if (pSeat->eViewModel.frame == CHAINSAW_STARTFIRE || pSeat->eViewModel.frame == CHAINSAW_CONTINUEFIRE) {
		Weapons_ViewAnimation(CHAINSAW_CONTINUEFIRE);
	} else {
		Weapons_ViewAnimation(CHAINSAW_STARTFIRE);
	}
#else
	Weapons_MakeVectors();
	vector src = pl.origin + pl.view_ofs;
	traceline(src, src + (v_forward * 32), FALSE, pl);
	
	if (trace_fraction >= 1.0) {
		Weapons_PlaySound(pl, CHAN_WEAPON, "sh/chainsaw_idle2.wav", 1, ATTN_NORM);
		pl.w_attack_next = 0.16f;
	} else {
		Effect_Impact(IMPACT_MELEE, trace_endpos, trace_plane_normal);
		
		if (trace_ent.takedamage) {
			if (trace_ent.iBleeds) {
				/* Push the player towards the victim */
				pl.velocity = normalize(trace_ent.origin - pl.origin) * 240;
			}

			Damage_Apply(trace_ent, self, 10, trace_endpos, FALSE );
			Weapons_PlaySound(pl, CHAN_WEAPON, "sh/chainsaw_cutintoflesh.wav", 1, ATTN_NORM);
		} else {
			Effect_CreateSpark(trace_endpos, trace_plane_normal);
			Weapons_PlaySound(pl, CHAN_WEAPON, "sh/chainsaw_cutinto.wav", 1, ATTN_NORM);
		}
		pl.w_attack_next = 0.1f;
	}
#endif

	pl.w_idle_next = 0.2f;
}
void w_chainsaw_secondary(void)
{
	
}
void w_chainsaw_reload(void)
{
	
}
void w_chainsaw_release(void)
{
#ifdef CSQC
	player pl = (player)self;

	if (pl.w_idle_next) {
		return;
	}

	if (pSeat->eViewModel.frame == CHAINSAW_CONTINUEFIRE) {
		Weapons_ViewAnimation(CHAINSAW_STOPFIRE);
		pl.w_idle_next = 1.0f;
	} else {
		pl.w_idle_next = 10.0f;
	}

	int r = floor(random(0,2));
	switch (r) {
	case 0:
		Weapons_ViewAnimation(CHAINSAW_IDLE1);
		break;
	case 1:
		Weapons_ViewAnimation(CHAINSAW_IDLE2);
		break;
	}
#endif
}

float w_chainsaw_aimanim(void)
{
#ifdef SSQC
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMSQUEAK : ANIM_AIMSQUEAK;
#endif
}

void w_chainsaw_hudpic(int s, vector pos)
{
#ifdef CSQC
	if (s) {
		drawsubpic(pos, [170,45], "sprites/chainsaw.spr_0.tga", [0,48/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/chainsaw.spr_0.tga", [0,0], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_chainsaw =
{
	ITEM_CHAINSAW,
	0,
	2,
	w_chainsaw_draw,
	w_chainsaw_holster,
	w_chainsaw_primary,
	w_chainsaw_secondary,
	w_chainsaw_reload,
	w_chainsaw_release,
	__NULL__,
	w_chainsaw_precache,
	__NULL__,
	w_chainsaw_vmodel,
	__NULL__,
	w_chainsaw_pmodel,
	w_chainsaw_deathmsg,
	w_chainsaw_aimanim,
	w_chainsaw_hudpic
};

