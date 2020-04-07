/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

/*QUAKED weapon_deagle (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_deagle.mdl"

COUNTER-STRIKE (1999) ENTITY

Desert Eagle .50 AE Weapon

- Buy Menu -
Price: $650

*/

enum {
	DEAGLE_IDLE,
	DEAGLE_SHOOT1,
	DEAGLE_SHOOT2,
	DEAGLE_SHOOT_EMPTY,
	DEAGLE_RELOAD,
	DEAGLE_DRAW
};

void
w_deagle_precache(void)
{
#ifdef SSQC
	Sound_Precache("weapon_deagle.fire");
#endif
	precache_model("models/v_deagle.mdl");
	precache_model("models/w_deagle.mdl");
	precache_model("models/p_deagle.mdl");
}

void
w_deagle_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, pl.deagle_mag, pl.ammo_50ae, -1);
#endif
}

string
w_deagle_wmodel(void)
{
	return "models/w_deagle.mdl";
}

string
w_deagle_pmodel(void)
{
	return "models/p_deagle.mdl";
}

string
w_deagle_deathmsg(void)
{
	return "";
}

int
w_deagle_pickup(int new)
{
#ifdef SSQC
	player pl = (player)self;

	if (new) {
		pl.deagle_mag = 7;
	} else {
		if (pl.ammo_50ae < AMMO_MAX_50AE) {
			pl.ammo_50ae = bound(0, pl.ammo_50ae + 7, AMMO_MAX_50AE);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_deagle_draw(void)
{
	player pl = (player)self;
	Weapons_SetModel("models/v_deagle.mdl");
	Weapons_ViewAnimation(DEAGLE_DRAW);

#ifdef CSQC
	pl.cs_cross_mindist = 8;
	pl.cs_cross_deltadist = 3;
#endif
}

void
w_deagle_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

	if (pl.flags & FL_SEMI_TOGGLED) {
		return;
	}

#ifdef CSQC
	if (!pl.a_ammo1) {
		return;
	}
#else
	if (!pl.deagle_mag) {
		return;
	}
#endif

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, 200);

#ifdef CSQC
	pl.a_ammo1--;
	View_SetMuzzleflash(MUZZLE_RIFLE);
#else
	pl.deagle_mag--;
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 54, [accuracy,accuracy], WEAPON_DEAGLE);

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT1HAND, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CR_SHOOT1HAND, 0.45f);

	Sound_Play(pl, CHAN_WEAPON, "weapon_deagle.fire");
#endif


	if (pl.a_ammo1 <= 0) {
		Weapons_ViewAnimation(DEAGLE_SHOOT_EMPTY);
	} else {
		int r = (float)input_sequence % 2;
		switch (r) {
		case 0:
			Weapons_ViewAnimation(DEAGLE_SHOOT1);
			break;
		default:
			Weapons_ViewAnimation(DEAGLE_SHOOT2);
			break;
		}
	}

	pl.flags |= FL_SEMI_TOGGLED;
	pl.w_attack_next = 0.15f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_deagle_reload(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

#ifdef CSQC
	if (pl.a_ammo1 >= 7) {
		return;
	}
	if (!pl.a_ammo2) {
		return;
	}
#else
	if (pl.deagle_mag >= 7) {
		return;
	}
	if (!pl.ammo_50ae) {
		return;
	}

	Weapons_ReloadWeapon(pl, player::deagle_mag, player::ammo_50ae, 7);
	Weapons_UpdateAmmo(pl, pl.deagle_mag, pl.ammo_50ae, -1);
#endif

	Weapons_ViewAnimation(DEAGLE_RELOAD);
	pl.w_attack_next = 2.1f;
	pl.w_idle_next = pl.w_attack_next;
}

float
w_deagle_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_deagle_hud(void)
{
#ifdef CSQC
	Cstrike_DrawCrosshair();
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [24/256,72/256], [24/256, 24/256], g_hud_color, pSeat->ammo2_alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_deagle_hudpic(int selected, vector pos, float a)
{
#ifdef CSQC
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud11.spr_0.tga",
			[0,90/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud10.spr_0.tga",
			[0,90/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_deagle =
{
	ITEM_DEAGLE,
	1,
	2,
	"sprites/640hud1.spr_0.tga",
	[32,16],
	[192,16],
	w_deagle_draw,
	__NULL__,
	w_deagle_primary,
	__NULL__,
	w_deagle_reload,
	w_cstrike_weaponrelease,
	w_deagle_hud,
	w_deagle_precache,
	w_deagle_pickup,
	w_deagle_updateammo,
	w_deagle_wmodel,
	w_deagle_pmodel,
	w_deagle_deathmsg,
	w_deagle_aimanim,
	w_deagle_hudpic
};

#ifdef SSQC
void
weapon_deagle(void)
{
	Weapons_InitItem(WEAPON_DEAGLE);
}
#endif
