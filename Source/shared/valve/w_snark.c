/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

enum
{
	SNARK_IDLE,
	SNARK_FIDGET1,
	SNARK_FIDGET2,
	SNARK_HOLSTER,
	SNARK_DRAW,
	SNARK_THROW
};

void w_snark_draw(void)
{
#ifdef CSQC
	Weapons_ViewAnimation(SNARK_DRAW);
#else
	player pl = (player)self;
	Weapons_UpdateAmmo(pl, __NULL__, pl.ammo_snark, __NULL__);
#endif
}

void w_snark_holster(void)
{
	
}
void w_snark_primary(void)
{
	
}
void w_snark_secondary(void)
{
	
}
void w_snark_reload(void)
{
	
}
void w_snark_release(void)
{
	int r;
	player pl = (player)self;
	if (pl.w_idle_next > 0.0) {
		return;
	}

	r = floor(random(0,3));

	switch (r) {
	case 0:
		Weapons_ViewAnimation(SNARK_IDLE);
		pl.w_idle_next = 1.875f;
		break;
	case 1:
		Weapons_ViewAnimation(SNARK_FIDGET1);
		pl.w_idle_next = 4.375f;
		break;
	default:
		Weapons_ViewAnimation(SNARK_FIDGET2);
		pl.w_idle_next = 5.0f;
		break;
	}
}
void w_snark_precache(void)
{
	
}
string w_snark_vmodel(void)
{
	return "models/v_squeak.mdl";
}
string w_snark_wmodel(void)
{
	return "models/w_sqknest.mdl";
}
string w_snark_pmodel(void)
{
	return "models/p_squeak.mdl";
}
string w_snark_deathmsg(void)
{
	return "";
}


float w_snark_aimanim(void)
{
#ifdef SSQC
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMSQUEAK : ANIM_AIMSQUEAK;
#endif
}

void w_snark_hudpic(int s, vector pos)
{
#ifdef CSQC
	if (s) {
		drawsubpic(pos, [170,45], "sprites/640hud6.spr_0.tga", [0,135/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hud3.spr_0.tga", [0,135/256], [170/256,45/256], g_hud_color, 1, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_snark =
{
	ITEM_SNARK,
	4,
	3,
	w_snark_draw,
	w_snark_holster,
	w_snark_primary,
	w_snark_secondary,
	w_snark_reload,
	w_snark_release,
	__NULL__,
	w_snark_precache,
	__NULL__,
	w_snark_vmodel,
	w_snark_wmodel,
	w_snark_pmodel,
	w_snark_deathmsg,
	w_snark_aimanim,
	w_snark_hudpic
};

#ifdef SSQC
void weapon_snark(void) {
	Weapons_InitItem(WEAPON_SNARK);
}
#endif
