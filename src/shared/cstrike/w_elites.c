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
	ELITES_IDLE,
	ELITES_RELOAD,
	ELITES_DRAW,
	ELITES_SHOOT1,
	ELITES_SHOOT2,
	ELITES_SHOOT3
};

void
w_elites_precache(void)
{
	precache_model("models/v_elites.mdl");
	precache_model("models/w_elites.mdl");
	precache_model("models/p_elites.mdl");
	precache_sound("weapons/elites-1.wav");
	precache_sound("weapons/elites-2.wav");
}

void
w_elites_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, pl.elites_mag, pl.ammo_762mm, -1);
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
w_elites_draw(void)
{
#ifdef CSQC
	Weapons_SetModel("models/v_elites.mdl");
	Weapons_ViewAnimation(ELITES_DRAW);
#endif
}

void
w_elites_primary(void)
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
		Weapons_ViewAnimation(ELITES_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(ELITES_SHOOT2);
		break;
	default:
		Weapons_ViewAnimation(ELITES_SHOOT3);
		break;
	}
#else
	if (!pl.elites_mag) {
		return;
	}

	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 8, [0.01,0,01], WEAPON_ELITES);

	pl.elites_mag--;

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT1HAND, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CR_SHOOT1HAND, 0.45f);

	if (random() < 0.5) {
		sound(pl, CHAN_WEAPON, "weapons/elites-1.wav", 1.0f, ATTN_NORM);
	} else {
		sound(pl, CHAN_WEAPON, "weapons/elites-2.wav", 1.0f, ATTN_NORM);
	}
#endif

	pl.w_attack_next = 0.0955f;
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
	if (!pl.ammo_762mm) {
		return;
	}

	Weapons_ReloadWeapon(pl, player::elites_mag, player::ammo_762mm, 30);
	Weapons_UpdateAmmo(pl, pl.elites_mag, pl.ammo_762mm, -1);
#endif

	Weapons_ViewAnimation(ELITES_RELOAD);
	pl.w_attack_next = 2.0f;
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

	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = video_mins + [video_res[0] - 48, video_res[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [0,72/128], [24/256, 24/128], g_hud_color, pSeat->ammo2_alpha, DRAWFLAG_ADDITIVE);
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
	__NULL__,
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
