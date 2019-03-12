/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

enum
{
	HANDGRENADE_IDLE,
	HANDGRENADE_FIDGET,
	HANDGRENADE_PULLPIN,
	HANDGRENADE_THROW1,
	HANDGRENADE_THROW2,
	HANDGRENADE_THROW3,
	HANDGRENADE_HOLSTER,
	HANDGRENADE_DRAW
};

void w_handgrenade_precache(void)
{
	precache_model("models/v_grenade.mdl");
	precache_model("models/w_grenade.mdl");
	precache_model("models/p_grenade.mdl");
}
string w_handgrenade_vmodel(void)
{
	return "models/v_grenade.mdl";
}
string w_handgrenade_wmodel(void)
{
	return "models/w_grenade.mdl";
}
string w_handgrenade_pmodel(void)
{
	return "models/p_grenade.mdl";
}
string w_handgrenade_deathmsg(void)
{
	return "";
}

void w_handgrenade_draw(void)
{
#ifdef CSQC
	Weapons_ViewAnimation(HANDGRENADE_DRAW);
#else
	player pl = (player)self;
	Weapons_UpdateAmmo(pl, __NULL__, pl.ammo_handgrenade, __NULL__);
#endif
}

void w_handgrenade_holster(void)
{
	
}
void w_handgrenade_primary(void)
{
	
}
void w_handgrenade_secondary(void)
{
	
}
void w_handgrenade_reload(void)
{
	
}
void w_handgrenade_release(void)
{
	
}
void w_handgrenade_hudpic(int s, vector pos)
{
#ifdef CSQC
	if (s) {
		drawsubpic(pos, [170,45], "sprites/640hud6.spr_0.tga", [0,0], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hud3.spr_0.tga", [0,0], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_handgrenade =
{
	ITEM_HANDGRENADE,
	4,
	0,
	w_handgrenade_draw,
	w_handgrenade_holster,
	w_handgrenade_primary,
	w_handgrenade_secondary,
	w_handgrenade_reload,
	w_handgrenade_release,
	__NULL__,
	w_handgrenade_precache,
	__NULL__,
	w_handgrenade_vmodel,
	w_handgrenade_wmodel,
	w_handgrenade_pmodel,
	w_handgrenade_deathmsg,
	w_handgrenade_hudpic
};

#ifdef SSQC
void weapon_handgrenade(void) {
	Weapons_InitItem(WEAPON_HANDGRENADE);
}
#endif
