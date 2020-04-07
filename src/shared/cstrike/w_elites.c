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

/*QUAKED weapon_elites (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_elite.mdl"

COUNTER-STRIKE (1999) ENTITY

Dual Beretta 96G (Elites) Weapon

- Buy Menu -
Price: $1000

*/

enum {
	ELITES_IDLE,
	ELITES_IDLE_LEFTEMPTY,
	ELITES_SHOOT_LEFT1,
	ELITES_SHOOT_LEFT2,
	ELITES_SHOOT_LEFT3,
	ELITES_SHOOT_LEFT4,
	ELITES_SHOOT_LEFT5,
	ELITES_SHOOT_LEFTLAST,
	ELITES_SHOOT_RIGHT1,
	ELITES_SHOOT_RIGHT2,
	ELITES_SHOOT_RIGHT3,
	ELITES_SHOOT_RIGHT4,
	ELITES_SHOOT_RIGHT5,
	ELITES_SHOOT_RIGHTLAST,
	ELITES_RELOAD,
	ELITES_DRAW
};
void
w_elites_precache(void)
{
#ifdef SSQC
	Sound_Precache("weapon_elites.fire");
#endif
	precache_model("models/v_elite.mdl");
	precache_model("models/w_elite.mdl");
	precache_model("models/p_elite.mdl");
}

void
w_elites_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, pl.elites_mag, pl.ammo_9mm, -1);
#endif
}

string
w_elites_wmodel(void)
{
	return "models/w_elites.mdl";
}

string
w_elites_pmodel(void)
{
	return "models/p_elites.mdl";
}

string
w_elites_deathmsg(void)
{
	return "";
}

int
w_elites_pickup(int new)
{
#ifdef SSQC
	player pl = (player)self;

	if (new) {
		pl.elites_mag = 30;
	} else {
		if (pl.ammo_9mm < 90) {
			pl.ammo_9mm = bound(0, pl.ammo_9mm + 30, 90);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_elites_draw(void)
{
	player pl = (player)self;
	Weapons_SetModel("models/v_elite.mdl");
	Weapons_ViewAnimation(ELITES_DRAW);

#ifdef CSQC
	pl.cs_cross_mindist = 4;
	pl.cs_cross_deltadist = 3;
#endif
}

void
w_elites_primary(void)
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
	if (!pl.elites_mag) {
		return;
	}
#endif

	Cstrike_ShotMultiplierAdd(pl, 1);
	float accuracy = Cstrike_CalculateAccuracy(pl, 200);

#ifdef CSQC
	pl.a_ammo1--;
	View_SetMuzzleflash(MUZZLE_RIFLE);
#else
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 45, [accuracy,accuracy], WEAPON_ELITES);
	pl.elites_mag--;

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT1HAND, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CR_SHOOT1HAND, 0.45f);

	Sound_Play(pl, CHAN_WEAPON, "weapon_elites.fire");
#endif

	pl.a_ammo3 = 1 - pl.a_ammo3;

	Weapons_ViewPunchAngle([-2,0,0]);

	int r = (float)input_sequence % 5;
	if (pl.a_ammo3) {
		if (pl.a_ammo1 <= 0) {
			Weapons_ViewAnimation(ELITES_SHOOT_LEFTLAST);
		} else {
			switch (r) {
			case 0:
				Weapons_ViewAnimation(ELITES_SHOOT_LEFT1);
				break;
			case 1:
				Weapons_ViewAnimation(ELITES_SHOOT_LEFT2);
				break;
			case 2:
				Weapons_ViewAnimation(ELITES_SHOOT_LEFT3);
				break;
			case 3:
				Weapons_ViewAnimation(ELITES_SHOOT_LEFT4);
				break;
			default:
				Weapons_ViewAnimation(ELITES_SHOOT_LEFT1);
				break;
			}
		}
	} else {
		if (pl.a_ammo1 <= 0) {
			Weapons_ViewAnimation(ELITES_SHOOT_RIGHTLAST);
		} else {
			switch (r) {
			case 0:
				Weapons_ViewAnimation(ELITES_SHOOT_RIGHT1);
				break;
			case 1:
				Weapons_ViewAnimation(ELITES_SHOOT_RIGHT2);
				break;
			case 2:
				Weapons_ViewAnimation(ELITES_SHOOT_RIGHT3);
				break;
			case 3:
				Weapons_ViewAnimation(ELITES_SHOOT_RIGHT4);
				break;
			default:
				Weapons_ViewAnimation(ELITES_SHOOT_RIGHT1);
				break;
			}
		}
	}

	pl.flags |= FL_SEMI_TOGGLED;
	pl.w_attack_next = 0.15f;
	pl.w_idle_next = pl.w_attack_next;
}

void
w_elites_reload(void)
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
	if (pl.elites_mag >= 30) {
		return;
	}
	if (!pl.ammo_9mm) {
		return;
	}

	Weapons_ReloadWeapon(pl, player::elites_mag, player::ammo_9mm, 30);
	Weapons_UpdateAmmo(pl, pl.elites_mag, pl.ammo_9mm, -1);
#endif

	Weapons_ViewAnimation(ELITES_RELOAD);
	pl.w_attack_next = 4.6f;
	pl.w_idle_next = pl.w_attack_next;
}

float
w_elites_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_elites_hud(void)
{
#ifdef CSQC
	Cstrike_DrawCrosshair();
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [48/256,72/256], [24/256, 24/256], g_hud_color, pSeat->ammo2_alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_elites_hudpic(int selected, vector pos, float a)
{
#ifdef CSQC
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud15.spr_0.tga",
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
			"sprites/640hud14.spr_0.tga",
			[0,90/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_elites =
{
	ITEM_ELITES,
	1,
	4,
	"sprites/640hud1.spr_0.tga",
	[32,16],
	[192,16],
	w_elites_draw,
	__NULL__,
	w_elites_primary,
	__NULL__,
	w_elites_reload,
	w_cstrike_weaponrelease,
	w_elites_hud,
	w_elites_precache,
	w_elites_pickup,
	w_elites_updateammo,
	w_elites_wmodel,
	w_elites_pmodel,
	w_elites_deathmsg,
	w_elites_aimanim,
	w_elites_hudpic
};

#ifdef SSQC
void
weapon_elites(void)
{
	Weapons_InitItem(WEAPON_ELITES);
}
#endif
