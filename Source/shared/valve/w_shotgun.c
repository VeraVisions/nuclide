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

enum
{
	SHOTTY_IDLE,
	SHOTTY_RELOAD_START,
	SHOTTY_RELOAD,
	SHOTTY_RELOAD_END
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

void w_shotgun_pickup(void)
{
#ifdef SSQC
	player pl = (player)self;
	pl.shotgun_mag = bound(0, pl.shotgun_mag + 8, 8);
#endif
}

void w_shotgun_draw(void)
{
#ifdef CSQC
	Weapons_ViewAnimation(SHOTGUN_DRAW);
#else
	player pl = (player)self;
	Weapons_UpdateAmmo(pl, pl.shotgun_mag, pl.ammo_buckshot, __NULL__);
#endif
}

void w_shotgun_holster(void)
{
#ifdef CSQC
	Weapons_ViewAnimation(SHOTGUN_HOLSTER);
#endif
}
void w_shotgun_primary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next) {
		return;
	}

	if (pl.a_ammo3 > SHOTTY_IDLE) {
		return;
	}

	/* Ammo check */
#ifdef SSQC
	if (pl.shotgun_mag <= 0) {
		return;
	}
#else
	if (pl.a_ammo1 <= 0) {
		return;
	}
#endif

#ifdef SSQC
	/* Singleplayer is more accurate */
	if (cvar("sv_playerslots") == 1) {
		TraceAttack_FireBullets(6, pl.origin + pl.view_ofs, 5, [0.08716,0.08716]);
	} else {
		TraceAttack_FireBullets(4, pl.origin + pl.view_ofs, 5, [0.08716,0.04362]);
	}
	Weapons_PlaySound(pl, CHAN_WEAPON, "weapons/sbarrel1.wav", 1, ATTN_NORM);
	pl.shotgun_mag--;
	Weapons_UpdateAmmo(pl, pl.shotgun_mag, pl.ammo_buckshot, __NULL__);
#else
	Weapons_ViewAnimation(SHOTGUN_FIRE1);
	Weapons_ViewPunchAngle([-5,0,0]);
	pl.a_ammo1--;
#endif

	pl.w_attack_next = 0.75;
	pl.w_idle_next = 2.5f;
}
void w_shotgun_secondary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next) {
		return;
	}

	if (pl.a_ammo3 > SHOTTY_IDLE) {
		return;
	}

	/* Ammo check */
#ifdef CSQC
	if (pl.a_ammo1 <= 1) {
		return;
	}
#else
	if (pl.shotgun_mag <= 1) {
		return;
	}
#endif

#ifdef SSQC
	/* Singleplayer is more accurate */
	if (cvar("sv_playerslots") == 1) {
		TraceAttack_FireBullets(12, pl.origin + pl.view_ofs, 5, [0.08716,0.08716]);
	} else {
		TraceAttack_FireBullets(8, pl.origin + pl.view_ofs, 5, [0.17365,0.04362]);
	}
	Weapons_PlaySound(pl, CHAN_WEAPON, "weapons/dbarrel1.wav", 1, ATTN_NORM);
	pl.shotgun_mag -= 2;
	Weapons_UpdateAmmo(pl, pl.shotgun_mag, pl.ammo_buckshot, __NULL__);
#else
	Weapons_ViewAnimation(SHOTGUN_FIRE2);
	Weapons_ViewPunchAngle([-10,0,0]);
	pl.a_ammo1 -= 2;
#endif

	pl.w_attack_next = 1.5f;
	pl.w_idle_next = 2.5f;
}
void w_shotgun_reload(void)
{
	player pl = (player)self;
#ifdef CSQC
	if (pl.a_ammo1 >= 8) {
		return;
	}
	if (pl.a_ammo2 <= 0) { 
		return;
	}
#else
	if (pl.shotgun_mag >= 8) {
		return;
	}
	if (pl.ammo_buckshot <= 0) {
		return;
	}
#endif
	
	if (pl.a_ammo3 > SHOTTY_IDLE) {
		return;
	}
	pl.a_ammo3 = SHOTTY_RELOAD_START;
	pl.w_idle_next = 0.0f;
}
void w_shotgun_release(void)
{
	player pl = (player)self;

	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.a_ammo3 == SHOTTY_IDLE) {
#ifdef CSQC
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
#endif
		pl.w_idle_next = 15.0f;
	} else if (pl.a_ammo3 == SHOTTY_RELOAD_START) {
#ifdef CSQC
		Weapons_ViewAnimation(SHOTGUN_START_RELOAD);
#endif
		pl.a_ammo3 = SHOTTY_RELOAD;
		pl.w_idle_next = 0.5f;
	} else if (pl.a_ammo3 == SHOTTY_RELOAD) {
#ifdef CSQC
		Weapons_ViewAnimation(SHOTGUN_RELOAD);
		pl.a_ammo1++;
		pl.a_ammo2--;

		if (pl.a_ammo2 <= 0 || pl.a_ammo1 >= 8) {
			pl.a_ammo3 = SHOTTY_RELOAD_END;
		}
#else
		pl.shotgun_mag++;
		pl.ammo_buckshot--;
		Weapons_UpdateAmmo(pl, pl.shotgun_mag, pl.ammo_buckshot, pl.a_ammo3);
	
		if (pl.ammo_buckshot <= 0 || pl.shotgun_mag >= 8) {
			pl.a_ammo3 = SHOTTY_RELOAD_END;
		}
#endif
		pl.w_idle_next = 0.5f;	
	} else if (pl.a_ammo3 == SHOTTY_RELOAD_END) {
#ifdef CSQC
		Weapons_ViewAnimation(SHOTGUN_PUMP);
#endif
		pl.a_ammo3 = SHOTTY_IDLE;
		pl.w_idle_next = 10.0f;
		pl.w_attack_next = 0.5f;
	}
}
void w_shotgun_crosshair(void)
{
#ifdef CSQC
	static vector cross_pos;
	cross_pos = (video_res / 2) + [-12,-12];
	drawsubpic(cross_pos, [24,24], "sprites/crosshairs.spr_0.tga", [48/128,24/128], [0.1875, 0.1875], [1,1,1], 1, DRAWFLAG_NORMAL);
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
#endif
}

float w_shotgun_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMSHOTGUN : ANIM_AIMSHOTGUN;
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
	w_shotgun_pickup,
	w_shotgun_vmodel,
	w_shotgun_wmodel,
	w_shotgun_pmodel,
	w_shotgun_deathmsg,
	w_shotgun_aimanim,
	w_shotgun_hudpic
};

#ifdef SSQC
void weapon_shotgun(void) {
	Weapons_InitItem(WEAPON_SHOTGUN);
}
#endif
