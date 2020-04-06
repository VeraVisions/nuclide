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
	P228_IDLE,
	P228_RELOAD,
	P228_DRAW,
	P228_SHOOT1,
	P228_SHOOT2,
	P228_SHOOT3
};

void
w_p228_precache(void)
{
#ifdef SSQC
	Sound_Precache("weapon_p228.fire");
#endif
	precache_model("models/v_p228.mdl");
	precache_model("models/w_p228.mdl");
	precache_model("models/p_p228.mdl");
	precache_sound("weapons/p228-1.wav");
	precache_sound("weapons/p228-2.wav");
}

void
w_p228_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, pl.p228_mag, pl.ammo_762mm, -1);
#endif
}

string
w_p228_wmodel(void)
{
	return "models/w_p228.mdl";
}

string
w_p228_pmodel(void)
{
	return "models/p_p228.mdl";
}

string
w_p228_deathmsg(void)
{
	return "";
}

int
w_p228_pickup(int new)
{
#ifdef SSQC
	player pl = (player)self;

	if (new) {
		pl.p228_mag = 13;
	} else {
		if (pl.ammo_762mm < 26) {
			pl.ammo_762mm = bound(0, pl.ammo_762mm + 13, 26);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_p228_draw(void)
{
#ifdef CSQC
	Weapons_SetModel("models/v_p228.mdl");
	Weapons_ViewAnimation(P228_DRAW);
#endif
}

void
w_p228_primary(void)
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

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(P228_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(P228_SHOOT2);
		break;
	default:
		Weapons_ViewAnimation(P228_SHOOT3);
		break;
	}
#else
	if (!pl.p228_mag) {
		return;
	}

	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 40, [0.01,0,01], WEAPON_P228);

	pl.p228_mag--;

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT1HAND, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CR_SHOOT1HAND, 0.45f);

	Sound_Play(pl, CHAN_WEAPON, "weapon_p228.fire");
#endif

	pl.w_attack_next = 0.15f;
}

void
w_p228_reload(void)
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
	if (pl.p228_mag >= 30) {
		return;
	}
	if (!pl.ammo_762mm) {
		return;
	}

	Weapons_ReloadWeapon(pl, player::p228_mag, player::ammo_762mm, 30);
	Weapons_UpdateAmmo(pl, pl.p228_mag, pl.ammo_762mm, -1);
#endif

	Weapons_ViewAnimation(P228_RELOAD);
	pl.w_attack_next = 2.0f;
}

float
w_p228_aimanim(void)
{
	return w_deagle_aimanim();
}

void
w_p228_hud(void)
{
#ifdef CSQC

	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [0,72/128], [24/256, 24/128], g_hud_color, pSeat->ammo2_alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_p228_hudpic(int selected, vector pos, float a)
{
#ifdef CSQC
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud13.spr_0.tga",
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
			"sprites/640hud12.spr_0.tga",
			[0,90/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_p228 =
{
	ITEM_P228,
	1,
	3,
	"sprites/640hud1.spr_0.tga",
	[32,16],
	[192,16],
	w_p228_draw,
	__NULL__,
	w_p228_primary,
	__NULL__,
	w_p228_reload,
	__NULL__,
	w_p228_hud,
	w_p228_precache,
	w_p228_pickup,
	w_p228_updateammo,
	w_p228_wmodel,
	w_p228_pmodel,
	w_p228_deathmsg,
	w_p228_aimanim,
	w_p228_hudpic
};

#ifdef SSQC
void
weapon_p228(void)
{
	Weapons_InitItem(WEAPON_P228);
}
#endif
