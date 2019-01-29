/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

.int mp5_mag;

enum
{
	MP5_IDLE1,
	MP5_IDLE2,
	MP5_GRENADE,
	MP5_RELOAD,
	MP5_DRAW,
	MP5_FIRE1,
	MP5_FIRE2,
	MP5_FIRE3
};

void w_mp5_precache(void)
{
	precache_model("models/v_9mmar.mdl");
	precache_model("models/w_9mmar.mdl");
	precache_model("models/p_9mmar.mdl");
	precache_sound("weapons/hks1.wav");
	precache_sound("weapons/hks2.wav");
	precache_sound("weapons/glauncher.wav");
}
void w_mp5_pickup(void)
{
	player pl = (player)self;
	pl.mp5_mag = 25;
}
string w_mp5_vmodel(void)
{
	return "models/v_9mmar.mdl";
}
string w_mp5_wmodel(void)
{
	return "models/w_9mmar.mdl";
}
string w_mp5_pmodel(void)
{
	return "models/p_9mmar.mdl";
}
string w_mp5_deathmsg(void)
{
	return "";
}

void w_mp5_draw(void)
{
	Weapons_ViewAnimation(MP5_DRAW);
}
void w_mp5_holster(void)
{
	Weapons_ViewAnimation(MP5_DRAW);
}
void w_mp5_primary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next) {
		return;
	}

#ifdef CSQC
	if (random() < 0.5) {
		Weapons_ViewAnimation(MP5_FIRE1);
	} else {
		Weapons_ViewAnimation(MP5_FIRE2);
	}

	Weapons_ViewPunchAngle([random(-2, 2),0,0]);
#else
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs);

	if (random() < 0.5) {
		Weapons_PlaySound(pl, CHAN_WEAPON, "weapons/hks1.wav", 1, ATTN_NORM);
	} else {
		Weapons_PlaySound(pl, CHAN_WEAPON, "weapons/hks2.wav", 1, ATTN_NORM);
	}
#endif

	pl.w_attack_next = 0.1f;
	pl.w_idle_next = 10.0f;
}
void w_mp5_secondary(void)
{
	player pl = (player)self;
	
	if (pl.w_attack_next) {
		return;
	}

#ifdef CSQC
	Weapons_ViewAnimation(MP5_GRENADE);
	Weapons_ViewPunchAngle([-10,0,0]);
#else
	Weapons_PlaySound(pl, CHAN_WEAPON, "weapons/glauncher.wav", 1, ATTN_NORM);
#endif

	pl.w_attack_next = 1.0f;
	pl.w_idle_next = 10.0f;
}
void w_mp5_reload(void)
{
	player pl = (player)self;
	if (pl.w_attack_next) {
		return;
	}

#ifdef CSQC
	Weapons_ViewAnimation(MP5_RELOAD);
#else

#endif

	pl.w_attack_next = 1.5f;
	pl.w_idle_next = 10.0f;
}
void w_mp5_release(void)
{
#ifdef CSQC
	player pl = (player)self;
	if (pl.w_idle_next) {
		return;
	}

	if (random() < 0.5) {
		Weapons_ViewAnimation(MP5_IDLE1);
	} else {
		Weapons_ViewAnimation(MP5_IDLE2);
	}

	pl.w_idle_next = 15.0f;
#endif
}
void w_mp5_crosshair(void)
{
#ifdef CSQC
	static vector cross_pos;
	cross_pos = (video_res / 2) + [-12,-12];
	drawsubpic(cross_pos, [24,24], "sprites/crosshairs.spr_0.tga", [24/128,48/128], [0.1875, 0.1875], [1,1,1], 1, DRAWFLAG_NORMAL);
#endif
}

void w_mp5_hudpic(int s, vector pos)
{
#ifdef CSQC
	if (s) {
		drawsubpic(pos, [170,45], "sprites/640hud4.spr_0.tga", [0,135/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hud1.spr_0.tga", [0,135/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_mp5 =
{
	ITEM_MP5,
	2,
	0,
	w_mp5_draw,
	w_mp5_holster,
	w_mp5_primary,
	w_mp5_secondary,
	w_mp5_reload,
	w_mp5_release,
	w_mp5_crosshair,
	w_mp5_precache,
	w_mp5_pickup,
	w_mp5_vmodel,
	w_mp5_wmodel,
	w_mp5_pmodel,
	w_mp5_deathmsg,
	w_mp5_hudpic
};

#ifdef SSQC
void weapon_9mmAR(void) {
	Weapons_InitItem(WEAPON_MP5);
}
void weapon_mp5(void) {
	Weapons_InitItem(WEAPON_MP5);
}
#endif

