/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

enum
{
	GAUSS_IDLE1,
	GAUSS_IDLE2,
	GAUSS_FIDGET,
	GAUSS_SPINUP,
	GAUSS_SPIN,
	GAUSS_FIRE1,
	GAUSS_FIRE2,
	GAUSS_HOLSTER,
	GAUSS_DRAW
};

void w_gauss_precache(void)
{
	precache_model("models/v_gauss.mdl");
	precache_model("models/w_gauss.mdl");
	precache_model("models/p_gauss.mdl");
}
string w_gauss_vmodel(void)
{
	return "models/v_gauss.mdl";
}
string w_gauss_wmodel(void)
{
	return "models/w_gauss.mdl";
}
string w_gauss_pmodel(void)
{
	return "models/p_gauss.mdl";
}
string w_gauss_deathmsg(void)
{
	return "";
}

void w_gauss_draw(void)
{
#ifdef CSQC
	Weapons_ViewAnimation(GAUSS_DRAW);
#else
	player pl = (player)self;
	Weapons_UpdateAmmo(pl, __NULL__, pl.ammo_uranium, __NULL__);
#endif
}

void w_gauss_holster(void)
{
	Weapons_ViewAnimation(GAUSS_HOLSTER);
}
void w_gauss_primary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next > 0.0) {
		return;
	}

	Weapons_ViewAnimation(GAUSS_FIRE2);
	Weapons_PlaySound(pl, CHAN_WEAPON, "weapons/gauss2.wav", 1, ATTN_NORM);

	pl.w_attack_next = 0.2f;
	pl.w_idle_next = 2.5f;
}
void w_gauss_secondary(void)
{
	
}
void w_gauss_reload(void)
{
	
}
void w_gauss_release(void)
{
	player pl = (player)self;
	if (pl.w_idle_next > 0.0) {
		return;
	}
	
	int r = floor(random(0,3));
	
	switch (r) {
	case 0:
		Weapons_ViewAnimation(GAUSS_IDLE1);
		pl.w_idle_next = 10.0f;
		break;
	case 1:
		Weapons_ViewAnimation(GAUSS_IDLE2);
		pl.w_idle_next = 10.0f;
		break;
	case 2:
		Weapons_ViewAnimation(GAUSS_FIDGET);
		pl.w_idle_next = 3.0f;
		break;
	}

}

void w_gauss_crosshair(void)
{
#ifdef CSQC
	static vector cross_pos;
	cross_pos = (video_res / 2) + [-12,-12];
	drawsubpic(cross_pos, [24,24], "sprites/crosshairs.spr_0.tga", [48/128,48/128], [0.1875, 0.1875], [1,1,1], 1, DRAWFLAG_NORMAL);
#endif
}

void w_gauss_hudpic(int s, vector pos)
{
#ifdef CSQC
	if (s) {
		drawsubpic(pos, [170,45], "sprites/640hud5.spr_0.tga", [0,90/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hud2.spr_0.tga", [0,90/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_gauss =
{
	ITEM_GAUSS,
	3,
	1,
	w_gauss_draw,
	w_gauss_holster,
	w_gauss_primary,
	w_gauss_secondary,
	w_gauss_reload,
	w_gauss_release,
	w_gauss_crosshair,
	w_gauss_precache,
	__NULL__,
	w_gauss_vmodel,
	w_gauss_wmodel,
	w_gauss_pmodel,
	w_gauss_deathmsg,
	w_gauss_hudpic
};

#ifdef SSQC
void weapon_gauss(void) {
	Weapons_InitItem(WEAPON_GAUSS);
}
#endif
