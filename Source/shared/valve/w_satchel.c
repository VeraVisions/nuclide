/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

enum
{
	SATCHEL_IDLE,
	SATCHEL_FIDGET,
	SATCHEL_DRAW,
	SATCHEL_THROW
};

enum
{
	RADIO_IDLE,
	RADIO_FIDGET,
	RADIO_DRAW,
	RADIO_USE,
	RADIO_HOLSTER
};

void w_satchel_draw(void)
{
#ifdef CSQC
	Weapons_ViewAnimation(SATCHEL_DRAW);
#else
	player pl = (player)self;
	Weapons_UpdateAmmo(pl, __NULL__, pl.ammo_satchel, __NULL__);
#endif
}

void w_satchel_holster(void)
{
	
}
void w_satchel_primary(void)
{
	
}
void w_satchel_secondary(void)
{
	
}
void w_satchel_reload(void)
{
	
}
void w_satchel_release(void)
{
	
}
void w_satchel_precache(void)
{
	
}
string w_satchel_vmodel(void)
{
	return "models/v_satchel.mdl";
}
string w_satchel_wmodel(void)
{
	return "models/w_satchel.mdl";
}
string w_satchel_pmodel(void)
{
	return "models/p_satchel.mdl";
}
string w_satchel_deathmsg(void)
{
	return "";
}

void w_satchel_hudpic(int s, vector pos)
{
#ifdef CSQC
	if (s) {
		drawsubpic(pos, [170,45], "sprites/640hud6.spr_0.tga", [0,45/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hud3.spr_0.tga", [0,45/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	}
#endif
}


weapon_t w_satchel =
{
	ITEM_SATCHEL,
	4,
	1,
	w_satchel_draw,
	w_satchel_holster,
	w_satchel_primary,
	w_satchel_secondary,
	w_satchel_reload,
	w_satchel_release,
	__NULL__,
	w_satchel_precache,
	__NULL__,
	w_satchel_vmodel,
	w_satchel_wmodel,
	w_satchel_pmodel,
	w_satchel_deathmsg,
	w_satchel_hudpic
};

#ifdef SSQC
void weapon_satchel(void) {
	Weapons_InitItem(WEAPON_SATCHEL);
}
#endif
