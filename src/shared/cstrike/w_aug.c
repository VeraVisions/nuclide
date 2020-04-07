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

/*QUAKED weapon_aug (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_aug.mdl"

COUNTER-STRIKE (1999) ENTITY

Steyr AUG Weapon

- Buy Menu -
Price: $3500
Counter-Terrorists only weapon

*/

enum {
	AUG_IDLE,
	AUG_RELOAD,
	AUG_DRAW,
	AUG_SHOOT1,
	AUG_SHOOT2,
	AUG_SHOOT3
};

void
w_aug_precache(void)
{
#ifdef SSQC
	Sound_Precache("weapon_aug.fire");
#endif
	precache_model("models/v_aug.mdl");
	precache_model("models/w_aug.mdl");
	precache_model("models/p_aug.mdl");
}

void
w_aug_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, pl.aug_mag, pl.ammo_762mm, -1);
#endif
}

string
w_aug_wmodel(void)
{
	return "models/w_aug.mdl";
}

string
w_aug_pmodel(void)
{
	return "models/p_aug.mdl";
}

string
w_aug_deathmsg(void)
{
	return "";
}

int
w_aug_pickup(int new)
{
#ifdef SSQC
	player pl = (player)self;

	if (new) {
		pl.aug_mag = 30;
	} else {
		if (pl.ammo_762mm < 90) {
			pl.ammo_762mm = bound(0, pl.ammo_762mm + 30, 90);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_aug_draw(void)
{
	player pl = (player)self;
	Weapons_SetModel("models/v_aug.mdl");
	Weapons_ViewAnimation(AUG_DRAW);

#ifdef CSQC
	pl.cs_cross_mindist = 3;
	pl.cs_cross_deltadist = 3;
#endif
}

void
w_aug_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

#ifdef CSQC
	if (!pl.a_ammo1) {
		return;
	}
#else
	if (!pl.aug_mag) {
		return;
	}
#endif

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, 215);

#ifdef CSQC
	pl.a_ammo1--;
	View_SetMuzzleflash(MUZZLE_RIFLE);
#else
	pl.aug_mag--;
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 32, [accuracy,accuracy], WEAPON_AUG);

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT1HAND, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CR_SHOOT1HAND, 0.45f);

	Sound_Play(pl, CHAN_WEAPON, "weapon_aug.fire");
#endif

	Weapons_ViewPunchAngle([-2,0,0]);

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(AUG_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(AUG_SHOOT2);
		break;
	default:
		Weapons_ViewAnimation(AUG_SHOOT3);
		break;
	}

	if (pl.viewzoom == 1.0f) {
		pl.w_attack_next = 0.0825f;
	} else {
		pl.w_attack_next = 0.15f;
	}
	pl.w_idle_next = pl.w_attack_next;
}

void
w_aug_secondary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next) {
		return;
	}
	/* Simple toggle of fovs */
	if (pl.viewzoom == 1.0f) {
		pl.viewzoom = 0.2f;
	} else {
		pl.viewzoom = 1.0f;
	}
	pl.w_attack_next = 0.5f;
}

void
w_aug_reload(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

#ifdef CSQC
	if (pl.a_ammo1 >= 30) {
		return;
	}
	if (!pl.a_ammo2) {
		return;
	}
#else
	if (pl.aug_mag >= 30) {
		return;
	}
	if (!pl.ammo_762mm) {
		return;
	}

	Weapons_ReloadWeapon(pl, player::aug_mag, player::ammo_762mm, 30);
	Weapons_UpdateAmmo(pl, pl.aug_mag, pl.ammo_762mm, -1);
#endif
	Weapons_ViewAnimation(AUG_RELOAD);

	pl.w_attack_next = 3.3f;
	pl.w_idle_next = pl.w_attack_next;
}

float
w_aug_aimanim(void)
{
	return w_ak47_aimanim();
}

void
w_aug_hud(void)
{
#ifdef CSQC
	player pl = (player)self;
	if (pl.viewzoom == 1.0f) {
		Cstrike_DrawCrosshair();
	} else {
		Cstrike_DrawSimpleCrosshair();
	}
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [72/256,72/256], [24/256, 24/256], g_hud_color, pSeat->ammo2_alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_aug_hudpic(int selected, vector pos, float a)
{
#ifdef CSQC
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud15.spr_0.tga",
			[0,45/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud14.spr_0.tga",
			[0,45/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_aug =
{
	ITEM_AUG,
	0,
	10,
	"sprites/640hud1.spr_0.tga",
	[32,16],
	[192,16],
	w_aug_draw,
	__NULL__,
	w_aug_primary,
	w_aug_secondary,
	w_aug_reload,
	w_cstrike_weaponrelease,
	w_aug_hud,
	w_aug_precache,
	w_aug_pickup,
	w_aug_updateammo,
	w_aug_wmodel,
	w_aug_pmodel,
	w_aug_deathmsg,
	w_aug_aimanim,
	w_aug_hudpic
};

#ifdef SSQC
void
weapon_aug(void)
{
	Weapons_InitItem(WEAPON_AUG);
}
#endif
