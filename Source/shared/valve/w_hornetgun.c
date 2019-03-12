/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

enum
{
	HORNETGUN_IDLE,
	HORNETGUN_FIDGET1,
	HORNETGUN_FIDGET2,
	HORNETGUN_HOLSTER,
	HORNETGUN_DRAW,
	HORNETGUN_SHOOT
};

void w_hornetgun_precache(void)
{
	precache_model("models/v_hgun.mdl");
	precache_model("models/w_hgun.mdl");
	precache_model("models/p_hgun.mdl");
	
	precache_sound("agrunt/ag_fire1.wav");
	precache_sound("agrunt/ag_fire2.wav");
	precache_sound("agrunt/ag_fire3.wav");
}
void w_hornetgun_pickup(void)
{
#ifdef SSQC
	player pl = (player)self;
	pl.ammo_hornet = 8;
#endif
}
string w_hornetgun_vmodel(void)
{
	return "models/v_hgun.mdl";
}
string w_hornetgun_wmodel(void)
{
	return "models/w_hgun.mdl";
}
string w_hornetgun_pmodel(void)
{
	return "models/p_hgun.mdl";
}
string w_hornetgun_deathmsg(void)
{
	return "";
}

void w_hornetgun_draw(void)
{
#ifdef CSQC
	Weapons_ViewAnimation(HORNETGUN_DRAW);
#else
	player pl = (player)self;
	Weapons_UpdateAmmo(pl, __NULL__, pl.ammo_hornet, __NULL__);
#endif
}
void w_hornetgun_holster(void)
{
	
}
void w_hornetgun_primary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next > 0.0) {
		return;
	}
	
	Weapons_PlaySound(pl, CHAN_WEAPON, sprintf("agrunt/ag_fire%d.wav", floor(random(1,4))), 1, ATTN_NORM);
	Weapons_ViewAnimation(HORNETGUN_SHOOT);
	pl.w_attack_next = 0.25;
	pl.w_idle_next = 2.5f;
}
void w_hornetgun_secondary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next > 0.0) {
		return;
	}
	
	Weapons_PlaySound(pl, CHAN_WEAPON, sprintf("agrunt/ag_fire%d.wav", floor(random(1,4))), 1, ATTN_NORM);
	Weapons_ViewAnimation(HORNETGUN_SHOOT);
	pl.w_attack_next = 0.1;
	pl.w_idle_next = 2.5f;
}
void w_hornetgun_reload(void)
{
	
}
void w_hornetgun_release(void)
{
	int r;
	player pl = (player)self;
	if (pl.w_idle_next > 0.0) {
		return;
	}

	r = floor(random(0,3));

	switch (r) {
	case 0:
		Weapons_ViewAnimation(HORNETGUN_IDLE);
		pl.w_idle_next = 0.95f;
		break;
	case 1:
		Weapons_ViewAnimation(HORNETGUN_FIDGET1);
		pl.w_idle_next = 2.5f;
		break;
	default:
		Weapons_ViewAnimation(HORNETGUN_FIDGET2);
		pl.w_idle_next = 2.2f;
		break;
	}
}
void w_hornetgun_crosshair(void)
{
#ifdef CSQC
	static vector cross_pos;
	cross_pos = (video_res / 2) + [-12,-12];
	drawsubpic(cross_pos, [24,24], "sprites/crosshairs.spr_0.tga", [72/128,24/128], [0.1875, 0.1875], [1,1,1], 1, DRAWFLAG_NORMAL);
#endif
}

void w_hornetgun_hudpic(int s, vector pos)
{
#ifdef CSQC
	if (s) {
		drawsubpic(pos, [170,45], "sprites/640hud5.spr_0.tga", [0,180/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hud2.spr_0.tga", [0,180/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_hornetgun =
{
	ITEM_HORNETGUN,
	3,
	3,
	w_hornetgun_draw,
	w_hornetgun_holster,
	w_hornetgun_primary,
	w_hornetgun_secondary,
	w_hornetgun_reload,
	w_hornetgun_release,
	w_hornetgun_crosshair,
	w_hornetgun_precache,
	w_hornetgun_pickup,
	w_hornetgun_vmodel,
	w_hornetgun_wmodel,
	w_hornetgun_pmodel,
	w_hornetgun_deathmsg,
	w_hornetgun_hudpic
};

#ifdef SSQC
void weapon_hornetgun(void) {
	Weapons_InitItem(WEAPON_HORNETGUN);
}
#endif
