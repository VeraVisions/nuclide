/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

enum
{
	EGON_IDLE1,
	EGON_FIDGET1,
	EGON_ALTFIREON,
	EGON_ALTFIRECYCLE,
	EGON_ALTFIREOFF,
	EGON_FIRE1,
	EGON_FIRE2,
	EGON_FIRE3,
	EGON_FIRE4,
	EGON_DRAW,
	EGON_HOLSTER
};

void w_egon_precache(void)
{
	precache_model("models/v_egon.mdl");
	precache_model("models/w_egon.mdl");
	precache_model("models/p_egon.mdl");
}
string w_egon_vmodel(void)
{
	return "models/v_egon.mdl";
}
string w_egon_wmodel(void)
{
	return "models/w_egon.mdl";
}
string w_egon_pmodel(void)
{
	return "models/p_egon.mdl";
}
string w_egon_deathmsg(void)
{
	return "";
}

void w_egon_draw(void)
{
	Weapons_ViewAnimation(EGON_DRAW);
}

void w_egon_holster(void)
{
	Weapons_ViewAnimation(EGON_HOLSTER);
}
void w_egon_primary(void)
{
	
}
void w_egon_secondary(void)
{
	
}
void w_egon_reload(void)
{
	
}
void w_egon_release(void)
{
	
}
void w_egon_crosshair(void)
{
#ifdef CSQC
	static vector cross_pos;
	cross_pos = (video_res / 2) + [-12,-12];
	drawsubpic(cross_pos, [24,24], "sprites/crosshairs.spr_0.tga", [72/128,48/128], [0.1875, 0.1875], [1,1,1], 1, DRAWFLAG_NORMAL);
#endif
}

void w_egon_hudpic(int s, vector pos)
{
#ifdef CSQC
	if (s) {
		drawsubpic(pos, [170,45], "sprites/640hud5.spr_0.tga", [0,135/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hud2.spr_0.tga", [0,135/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_egon =
{
	ITEM_EGON,
	3,
	2,
	w_egon_draw,
	w_egon_holster,
	w_egon_primary,
	w_egon_secondary,
	w_egon_reload,
	w_egon_release,
	w_egon_crosshair,
	w_egon_precache,
	__NULL__,
	w_egon_vmodel,
	w_egon_wmodel,
	w_egon_pmodel,
	w_egon_deathmsg,
	w_egon_hudpic
};

#ifdef SSQC
void weapon_egon(void) {
	Weapons_InitItem(WEAPON_EGON);
}
#endif
