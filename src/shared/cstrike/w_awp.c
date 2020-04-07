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

/*QUAKED weapon_awp (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_awp.mdl"

COUNTER-STRIKE (1999) ENTITY

AWP (AI Arctic Warfare/Magnum) Weapon

- Buy Menu -
Price: $4750

*/

enum {
	AWP_IDLE,
	AWP_SHOOT1,
	AWP_SHOOT2,
	AWP_SHOOT3,
	AWP_RELOAD,
	AWP_DRAW
};

void
w_awp_precache(void)
{
#ifdef SSQC
	Sound_Precache("weapon_awp.fire");
#endif
	precache_model("models/v_awp.mdl");
	precache_model("models/w_awp.mdl");
	precache_model("models/p_awp.mdl");
}

void
w_awp_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, pl.awp_mag, pl.ammo_338mag, -1);
#endif
}

string
w_awp_wmodel(void)
{
	return "models/w_awp.mdl";
}

string
w_awp_pmodel(void)
{
	return "models/p_awp.mdl";
}

string
w_awp_deathmsg(void)
{
	return "";
}

int
w_awp_pickup(int new)
{
#ifdef SSQC
	player pl = (player)self;

	if (new) {
		pl.awp_mag = 10;
	} else {
		if (pl.ammo_338mag < 20) {
			pl.ammo_338mag = bound(0, pl.ammo_338mag + 10, 20);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_awp_draw(void)
{
	player pl = (player)self;
	Weapons_SetModel("models/v_awp.mdl");
	Weapons_ViewAnimation(AWP_DRAW);

#ifdef CSQC
	pl.cs_cross_mindist = 8;
	pl.cs_cross_deltadist = 3;
#endif
}

void
w_awp_primary(void)
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
	if (!pl.awp_mag) {
		return;
	}
#endif

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, -1);

#ifdef CSQC
	pl.a_ammo1--;
	View_SetMuzzleflash(MUZZLE_RIFLE);
#else
	pl.awp_mag--;
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 115, [accuracy,accuracy], WEAPON_AWP);

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT1HAND, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CR_SHOOT1HAND, 0.45f);

	Sound_Play(pl, CHAN_WEAPON, "weapon_awp.fire");
#endif

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(AWP_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(AWP_SHOOT2);
		break;
	default:
		Weapons_ViewAnimation(AWP_SHOOT3);
		break;
	}

	pl.w_attack_next = 1.2f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_awp_secondary(void)
{
	player pl = (player)self;
	if (pl.w_attack_next) {
		return;
	}
	/* Simple toggle of fovs */
	if (pl.viewzoom == 1.0f) {
		pl.viewzoom = 0.45f;
	} else if (pl.viewzoom == 0.45f) {
		pl.viewzoom = 0.1f;
	} else {
		pl.viewzoom = 1.0f;
	}
	pl.w_attack_next = 0.5f;
}

void
w_awp_reload(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

#ifdef CSQC
	if (pl.a_ammo1 >= 10) {
		return;
	}
	if (!pl.a_ammo2) {
		return;
	}
#else
	if (pl.awp_mag >= 10) {
		return;
	}
	if (!pl.ammo_338mag) {
		return;
	}

	Weapons_ReloadWeapon(pl, player::awp_mag, player::ammo_338mag, 10);
	Weapons_UpdateAmmo(pl, pl.awp_mag, pl.ammo_338mag, -1);
#endif
	Weapons_ViewAnimation(AWP_RELOAD);

	pl.w_attack_next = 2.9f;
	pl.w_idle_next = pl.w_attack_next;
}

float
w_awp_aimanim(void)
{
	return w_ak47_aimanim();
}

void
w_awp_hud(void)
{
#ifdef CSQC
	player pl = (player)self;
	if (pl.viewzoom < 1.0f) {
		Cstrike_DrawScope();
	}
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [24/256,96/256], [24/256, 24/256], g_hud_color, pSeat->ammo2_alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_awp_hudpic(int selected, vector pos, float a)
{
#ifdef CSQC
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud5.spr_0.tga",
			[0,135/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud2.spr_0.tga",
			[0,135/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_awp =
{
	ITEM_AWP,
	0,
	12,
	"sprites/640hud1.spr_0.tga",
	[32,16],
	[192,16],
	w_awp_draw,
	__NULL__,
	w_awp_primary,
	w_awp_secondary,
	w_awp_reload,
	w_cstrike_weaponrelease,
	w_awp_hud,
	w_awp_precache,
	w_awp_pickup,
	w_awp_updateammo,
	w_awp_wmodel,
	w_awp_pmodel,
	w_awp_deathmsg,
	w_awp_aimanim,
	w_awp_hudpic
};

#ifdef SSQC
void
weapon_awp(void)
{
	Weapons_InitItem(WEAPON_AWP);
}
#endif
