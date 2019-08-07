/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

enum
{
	RPG_IDLE,
	RPG_FIDGET,
	RPG_RELOAD,
	RPG_FIRE2,
	RPG_HOLSTER1,
	RPG_DRAW1,
	RPG_HOLSTER2,
	RPG_DRAW_UL,
	RPG_IDLE_UL,
	RPG_FIDGET_UL,
};

void w_rpg_precache(void)
{
	precache_model("models/v_rpg.mdl");
	precache_model("models/w_rpg.mdl");
	precache_model("models/p_rpg.mdl");
}
string w_rpg_vmodel(void)
{
	return "models/v_rpg.mdl";
}
string w_rpg_wmodel(void)
{
	return "models/w_rpg.mdl";
}
string w_rpg_pmodel(void)
{
	return "models/p_rpg.mdl";
}
string w_rpg_deathmsg(void)
{
	return "";
}

void w_rpg_draw(void)
{
#ifdef CSQC
	Weapons_ViewAnimation(RPG_DRAW1);
#else
	player pl = (player)self;
	Weapons_UpdateAmmo(pl, pl.rpg_mag, pl.ammo_rocket, __NULL__);
#endif
}

void w_rpg_holster(void)
{
	
}
void w_rpg_primary(void)
{
	
}
void w_rpg_secondary(void)
{
	
}
void w_rpg_reload(void)
{
	
}
void w_rpg_release(void)
{
	
}

float w_rpg_aimanim(void)
{
#ifdef SSQC
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMRPG : ANIM_AIMRPG;
#endif
}

void w_rpg_hudpic(int s, vector pos)
{
#ifdef CSQC
	if (s) {
		drawsubpic(pos, [170,45], "sprites/640hud5.spr_0.tga", [0,45/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hud2.spr_0.tga", [0,45/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	}
#endif
}

void w_rpg_laser(void)
{
	player pl = (player)self;

	Weapons_MakeVectors();
	vector src = pl.origin + pl.view_ofs;
	traceline(src, src + (v_forward * 8192), FALSE, pl);
#ifdef CSQC
	// Draw laser at laserpos
#endif
}

weapon_t w_rpg =
{
	ITEM_RPG,
	3,
	0,
	w_rpg_draw,
	w_rpg_holster,
	w_rpg_primary,
	w_rpg_secondary,
	w_rpg_reload,
	w_rpg_release,
	w_rpg_laser,
	w_rpg_precache,
	__NULL__,
	w_rpg_vmodel,
	w_rpg_wmodel,
	w_rpg_pmodel,
	w_rpg_deathmsg,
	w_rpg_aimanim,
	w_rpg_hudpic
};

#ifdef SSQC
void weapon_rpg(void) {
	Weapons_InitItem(WEAPON_RPG);
}
#endif

