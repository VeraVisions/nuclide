/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

/*QUAKED weapon_shotgun (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_shotgun.mdl"

HALF-LIFE (1998) ENTITY

Shotgun Weapon

*/

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
#ifdef SSQC
	Sound_Precache("weapon_shotgun.single");
	Sound_Precache("weapon_shotgun.double");
	Sound_Precache("weapon_shotgun.reload");
	Sound_Precache("weapon_shotgun.cock");
#endif

	precache_model("models/v_shotgun.mdl");
	precache_model("models/w_shotgun.mdl");
	precache_model("models/p_shotgun.mdl");
}
void w_shotgun_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, pl.shotgun_mag, pl.ammo_buckshot, -1);
#endif
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

int w_shotgun_pickup(int new)
{
#ifdef SSQC
	player pl = (player)self;

	if (new) {
		pl.shotgun_mag = 8;
	} else {
		if (pl.ammo_buckshot < MAX_A_BUCKSHOT) {
			pl.ammo_buckshot = bound(0, pl.ammo_buckshot + 8, MAX_A_BUCKSHOT);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void w_shotgun_draw(void)
{
	Weapons_SetModel("models/v_shotgun.mdl");
	Weapons_ViewAnimation(SHOTGUN_DRAW);
}

void w_shotgun_holster(void)
{
	Weapons_ViewAnimation(SHOTGUN_HOLSTER);
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
		TraceAttack_FireBullets(6, pl.origin + pl.view_ofs, Skill_GetValue("plr_buckshot"), [0.08716,0.08716], WEAPON_SHOTGUN);
	} else {
		TraceAttack_FireBullets(4, pl.origin + pl.view_ofs, Skill_GetValue("plr_buckshot"), [0.08716,0.04362], WEAPON_SHOTGUN);
	}
	Sound_Play(pl, CHAN_WEAPON, "weapon_shotgun.single");
	pl.shotgun_mag--;
#else
	View_SetMuzzleflash(MUZZLE_WEIRD);
	Weapons_ViewPunchAngle([-5,0,0]);
	pl.a_ammo1--;
#endif
	Weapons_ViewAnimation(SHOTGUN_FIRE1);

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
		TraceAttack_FireBullets(12, pl.origin + pl.view_ofs, 5, [0.08716,0.08716], WEAPON_SHOTGUN);
	} else {
		TraceAttack_FireBullets(8, pl.origin + pl.view_ofs, 5, [0.17365,0.04362], WEAPON_SHOTGUN);
	}
	Sound_Play(pl, CHAN_WEAPON, "weapon_shotgun.double");
	pl.shotgun_mag -= 2;
	Weapons_UpdateAmmo(pl, pl.shotgun_mag, pl.ammo_buckshot, __NULL__);
#else
	Weapons_ViewPunchAngle([-10,0,0]);
	pl.a_ammo1 -= 2;
#endif
	Weapons_ViewAnimation(SHOTGUN_FIRE2);
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
		int r = (float)input_sequence % 3;
		switch (r) {
		case 1:
			Weapons_ViewAnimation(SHOTGUN_IDLE2);
			pl.w_idle_next = 2.222222f;
			break;
		case 2:
			Weapons_ViewAnimation(SHOTGUN_IDLE3);
			pl.w_idle_next = 5.0f;
			break;
		default:
			Weapons_ViewAnimation(SHOTGUN_IDLE1);
			pl.w_idle_next = 2.222222f;
			break;
		}
	} else if (pl.a_ammo3 == SHOTTY_RELOAD_START) {
		Weapons_ViewAnimation(SHOTGUN_START_RELOAD);
		pl.a_ammo3 = SHOTTY_RELOAD;
		pl.w_idle_next = 0.65f;
	} else if (pl.a_ammo3 == SHOTTY_RELOAD) {
		Weapons_ViewAnimation(SHOTGUN_RELOAD);
#ifdef CSQC
		pl.a_ammo1++;
		pl.a_ammo2--;

		if (pl.a_ammo2 <= 0 || pl.a_ammo1 >= 8) {
			pl.a_ammo3 = SHOTTY_RELOAD_END;
		}
#else
		pl.shotgun_mag++;
		pl.ammo_buckshot--;
		Weapons_UpdateAmmo(pl, pl.shotgun_mag, pl.ammo_buckshot, pl.a_ammo3);
		Sound_Play(pl, CHAN_WEAPON, "weapon_shotgun.reload");
		if (pl.ammo_buckshot <= 0 || pl.shotgun_mag >= 8) {
			pl.a_ammo3 = SHOTTY_RELOAD_END;
		}
#endif
		pl.w_idle_next = 0.5f;	
	} else if (pl.a_ammo3 == SHOTTY_RELOAD_END) {
		Weapons_ViewAnimation(SHOTGUN_PUMP);
#ifdef SSQC
		Sound_Play(pl, CHAN_WEAPON, "weapon_shotgun.cock");
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
	cross_pos = g_hudmins + (g_hudres / 2) + [-12,-12];
	drawsubpic(cross_pos, [24,24], "sprites/crosshairs.spr_0.tga", [48/128,24/128], [0.1875, 0.1875], [1,1,1], 1, DRAWFLAG_NORMAL);
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [72/256,72/128], [24/256, 24/128], g_hud_color, pSeat->ammo2_alpha, DRAWFLAG_ADDITIVE);
#endif
}

float w_shotgun_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMSHOTGUN : ANIM_AIMSHOTGUN;
}

void w_shotgun_hudpic(int selected, vector pos, float a)
{
#ifdef CSQC
	if (selected) {
		drawsubpic(pos, [170,45], "sprites/640hud4.spr_0.tga", [0,180/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hud1.spr_0.tga", [0,180/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_shotgun =
{
	ITEM_SHOTGUN,
	2,
	1,
	"sprites/640hud1.spr_0.tga",
	[48,16],
	[192,64],
	w_shotgun_draw,
	w_shotgun_holster,
	w_shotgun_primary,
	w_shotgun_secondary,
	w_shotgun_reload,
	w_shotgun_release,
	w_shotgun_crosshair,
	w_shotgun_precache,
	w_shotgun_pickup,
	w_shotgun_updateammo,
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
