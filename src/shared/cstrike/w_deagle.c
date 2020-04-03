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

enum {
	DEAGLE_IDLE,
	DEAGLE_RELOAD,
	DEAGLE_DRAW,
	DEAGLE_SHOOT1,
	DEAGLE_SHOOT2,
	DEAGLE_SHOOT3
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
	Weapons_UpdateAmmo(pl, pl.deagle_mag, pl.ammo_762mm, -1);
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
		pl.deagle_mag = 30;
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
w_deagle_draw(void)
{
#ifdef CSQC
	Weapons_SetModel("models/v_deagle.mdl");
	Weapons_ViewAnimation(DEAGLE_DRAW);
#endif
}

void
w_deagle_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

#ifdef CSQC
	if (!pl.a_ammo1) {
		return;
	}

	View_SetMuzzleflash(MUZZLE_RIFLE);
	Weapons_ViewPunchAngle([-2,0,0]);

	int r = floor(random(0,3));
	switch (r) {
	case 0:
		Weapons_ViewAnimation(DEAGLE_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(DEAGLE_SHOOT2);
		break;
	default:
		Weapons_ViewAnimation(DEAGLE_SHOOT3);
		break;
	}
#else
	if (!pl.deagle_mag) {
		return;
	}

	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 8, [0.01,0,01], WEAPON_DEAGLE);

	pl.deagle_mag--;

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT1HAND, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CR_SHOOT1HAND, 0.45f);

	Sound_Play(pl, CHAN_WEAPON, "weapon_deagle.fire");
#endif

	pl.w_attack_next = 0.0955f;
}

void
w_deagle_reload(void)
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
	if (pl.deagle_mag >= 30) {
		return;
	}
	if (!pl.ammo_762mm) {
		return;
	}

	Weapons_ReloadWeapon(pl, player::deagle_mag, player::ammo_762mm, 30);
	Weapons_UpdateAmmo(pl, pl.deagle_mag, pl.ammo_762mm, -1);
#endif

	Weapons_ViewAnimation(DEAGLE_RELOAD);
	pl.w_attack_next = 2.0f;
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

	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [0,72/128], [24/256, 24/128], g_hud_color, pSeat->ammo2_alpha, DRAWFLAG_ADDITIVE);
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
	__NULL__,
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
