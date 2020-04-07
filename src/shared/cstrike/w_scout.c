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

/*QUAKED weapon_scout (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_scout.mdl"

COUNTER-STRIKE (1999) ENTITY

Steyr Scout Weapon

- Buy Menu -
Price: $1250

*/

enum {
	SCOUT_IDLE,
	SCOUT_SHOOT1,
	SCOUT_SHOOT2,
	SCOUT_RELOAD,
	SCOUT_DRAW
};

void
w_scout_precache(void)
{
#ifdef SSQC
	Sound_Precache("weapon_scout.fire");
#endif
	precache_model("models/v_scout.mdl");
	precache_model("models/w_scout.mdl");
	precache_model("models/p_scout.mdl");
}

void
w_scout_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, pl.scout_mag, pl.ammo_762mm, -1);
#endif
}

string
w_scout_wmodel(void)
{
	return "models/w_scout.mdl";
}

string
w_scout_pmodel(void)
{
	return "models/p_scout.mdl";
}

string
w_scout_deathmsg(void)
{
	return "";
}

int
w_scout_pickup(int new)
{
#ifdef SSQC
	player pl = (player)self;

	if (new) {
		pl.scout_mag = 10;
	} else {
		if (pl.ammo_762mm < 30) {
			pl.ammo_762mm = bound(0, pl.ammo_762mm + 10, 30);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_scout_draw(void)
{
	player pl = (player)self;
	Weapons_SetModel("models/v_scout.mdl");
	Weapons_ViewAnimation(SCOUT_DRAW);

#ifdef CSQC
	pl.cs_cross_mindist = 5;
	pl.cs_cross_deltadist = 3;
#endif
}

void
w_scout_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* ammo check */
#ifdef CSQC
	if (!pl.a_ammo1) {
		return;
	}
#else
	if (!pl.scout_mag) {
		return;
	}
#endif

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, 200);

#ifdef CSQC
	pl.a_ammo1--;
	View_SetMuzzleflash(MUZZLE_RIFLE);
#else
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 75, [accuracy,accuracy], WEAPON_SCOUT);
	pl.scout_mag--;

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT1HAND, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CR_SHOOT1HAND, 0.45f);

	Sound_Play(pl, CHAN_WEAPON, "weapon_scout.fire");
#endif

	Weapons_ViewPunchAngle([-2,0,0]);

	int r = (float)input_sequence % 2;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(SCOUT_SHOOT1);
		break;
	default:
		Weapons_ViewAnimation(SCOUT_SHOOT2);
		break;
	}

	pl.w_attack_next = 1.25f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_scout_secondary(void)
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
w_scout_reload(void)
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
	if (pl.scout_mag >= 10) {
		return;
	}
	if (!pl.ammo_762mm) {
		return;
	}

	Weapons_ReloadWeapon(pl, player::scout_mag, player::ammo_762mm, 10);
	Weapons_UpdateAmmo(pl, pl.scout_mag, pl.ammo_762mm, -1);
#endif

	Weapons_ViewAnimation(SCOUT_RELOAD);
	pl.w_attack_next = 2.0f;
	pl.w_idle_next = pl.w_attack_next;
}

float
w_scout_aimanim(void)
{
	return w_ak47_aimanim();
}

void
w_scout_hud(void)
{
#ifdef CSQC
	player pl = (player)self;
	if (pl.viewzoom < 1.0f) {
		Cstrike_DrawScope();
	}
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [72/256,72/256], [24/256, 24/256], g_hud_color, pSeat->ammo2_alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_scout_hudpic(int selected, vector pos, float a)
{
#ifdef CSQC
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud13.spr_0.tga",
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
			"sprites/640hud12.spr_0.tga",
			[0,45/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_scout =
{
	ITEM_SCOUT,
	0,
	11,
	"sprites/640hud1.spr_0.tga",
	[32,16],
	[192,16],
	w_scout_draw,
	__NULL__,
	w_scout_primary,
	w_scout_secondary,
	w_scout_reload,
	w_cstrike_weaponrelease,
	w_scout_hud,
	w_scout_precache,
	w_scout_pickup,
	w_scout_updateammo,
	w_scout_wmodel,
	w_scout_pmodel,
	w_scout_deathmsg,
	w_scout_aimanim,
	w_scout_hudpic
};

#ifdef SSQC
void
weapon_scout(void)
{
	Weapons_InitItem(WEAPON_SCOUT);
}
#endif
