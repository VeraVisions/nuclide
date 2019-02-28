/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

enum
{
	SHOTGUN_IDLE1,
	SHOTGUN_FIRE1,
	SHOTGUN_FIRE2,
	SHOTGUN_RELOAD,
	SHOTGUN_PUMP,
	SHOTGUN_START_RELOAD,
	SHOTGUN_DRAW,
	SHOTGUN_HOLSTER,
	SHOTGUN_IDLE2,
	SHOTGUN_IDLE3
};

void w_shotgun_precache(void)
{
	precache_model("models/v_shotgun.mdl");
	precache_model("models/w_shotgun.mdl");
	precache_model("models/p_shotgun.mdl");
	precache_sound("weapons/sbarrel1.wav");
	precache_sound("weapons/dbarrel1.wav");
}
string w_shotgun_vmodel(void)
{
	return "models/v_shotgun.mdl";
}
string w_shotgun_wmodel(void)
{
	return "models/w_shotgun.mdl";
}
string w_shotgun_pmodel(void)
{
	return "models/p_shotgun.mdl";
}
string w_shotgun_deathmsg(void)
{
	return "";
}

void w_shotgun_draw(void)
{
	Weapons_ViewAnimation(SHOTGUN_DRAW);
}

void w_shotgun_holster(void)
{
	Weapons_ViewAnimation(SHOTGUN_HOLSTER);
}
void w_shotgun_primary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next > 0.0) {
		return;
	}

	Weapons_PlaySound(pl, CHAN_WEAPON, "weapons/sbarrel1.wav", 1, ATTN_NORM);
	Weapons_ViewAnimation(SHOTGUN_FIRE1);
	Weapons_ViewPunchAngle([-5,0,0]);
	pl.w_attack_next = Math_Time() + 0.75;
	pl.w_idle_next = Math_Time() + 2.5f;
}
void w_shotgun_secondary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next > 0.0) {
		return;
	}

	Weapons_PlaySound(pl, CHAN_WEAPON, "weapons/dbarrel1.wav", 1, ATTN_NORM);
	Weapons_ViewAnimation(SHOTGUN_FIRE2);
	Weapons_ViewPunchAngle([-10,0,0]);
	pl.w_attack_next = 1.5f;
	pl.w_idle_next = 2.5f;
}
void w_shotgun_reload(void)
{
	
}
void w_shotgun_release(void)
{
	player pl = (player)self;
	if (pl.w_idle_next > 0.0) {
		return;
	}

	int r = floor(random(0,3));
	switch (r) {
	case 0:
		Weapons_ViewAnimation(SHOTGUN_IDLE1);
		break;
	case 1:
		Weapons_ViewAnimation(SHOTGUN_IDLE2);
		break;
	case 2:
		Weapons_ViewAnimation(SHOTGUN_IDLE3);
		break;
	}

	pl.w_idle_next = 15.0f;
}
void w_shotgun_crosshair(void)
{
#ifdef CSQC
	static vector cross_pos;
	cross_pos = (video_res / 2) + [-12,-12];
	drawsubpic(cross_pos, [24,24], "sprites/crosshairs.spr_0.tga", [48/128,24/128], [0.1875, 0.1875], [1,1,1], 1, DRAWFLAG_NORMAL);
#endif
}

void w_shotgun_hudpic(int s, vector pos)
{
#ifdef CSQC
	if (s) {
		drawsubpic(pos, [170,45], "sprites/640hud4.spr_0.tga", [0,180/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hud1.spr_0.tga", [0,180/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_shotgun =
{
	ITEM_SHOTGUN,
	2,
	1,
	w_shotgun_draw,
	w_shotgun_holster,
	w_shotgun_primary,
	w_shotgun_secondary,
	w_shotgun_reload,
	w_shotgun_release,
	w_shotgun_crosshair,
	w_shotgun_precache,
	__NULL__,
	w_shotgun_vmodel,
	w_shotgun_wmodel,
	w_shotgun_pmodel,
	w_shotgun_deathmsg,
	w_shotgun_hudpic
};

#ifdef SSQC
void weapon_shotgun(void) {
	Weapons_InitItem(WEAPON_SHOTGUN);
}
#endif
