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
	MP5_IDLE,
	MP5_RELOAD,
	MP5_DRAW,
	MP5_SHOOT1,
	MP5_SHOOT2,
	MP5_SHOOT3
};

void
w_mp5_precache(void)
{
	precache_model("models/v_mp5.mdl");
	precache_model("models/w_mp5.mdl");
	precache_model("models/p_mp5.mdl");
}

void
w_mp5_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, pl.mp5_mag, pl.ammo_762mm, -1);
#endif
}

string
w_mp5_wmodel(void)
{
	return "models/w_mp5.mdl";
}

string
w_mp5_pmodel(void)
{
	return "models/p_mp5.mdl";
}

string
w_mp5_deathmsg(void)
{
	return "";
}

int
w_mp5_pickup(int new)
{
#ifdef SSQC
	player pl = (player)self;

	if (new) {
		pl.mp5_mag = 30;
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
w_mp5_draw(void)
{
#ifdef CSQC
	Weapons_SetModel("models/v_mp5.mdl");
	Weapons_ViewAnimation(MP5_DRAW);
#endif
}

void
w_mp5_primary(void)
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
		Weapons_ViewAnimation(MP5_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(MP5_SHOOT2);
		break;
	default:
		Weapons_ViewAnimation(MP5_SHOOT3);
		break;
	}
#else
	if (!pl.mp5_mag) {
		return;
	}

	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 8, [0.01,0,01], WEAPON_MP5);

	pl.mp5_mag--;

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT1HAND, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CR_SHOOT1HAND, 0.45f);

	if (random() < 0.5) {
		sound(pl, CHAN_WEAPON, "weapons/mp5-1.wav", 1.0f, ATTN_NORM);
	} else {
		sound(pl, CHAN_WEAPON, "weapons/mp5-2.wav", 1.0f, ATTN_NORM);
	}
#endif

	pl.w_attack_next = 0.0955f;
}

void
w_mp5_reload(void)
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
	if (pl.mp5_mag >= 30) {
		return;
	}
	if (!pl.ammo_762mm) {
		return;
	}

	Weapons_ReloadWeapon(pl, player::mp5_mag, player::ammo_762mm, 30);
	Weapons_UpdateAmmo(pl, pl.mp5_mag, pl.ammo_762mm, -1);
#endif

	Weapons_ViewAnimation(MP5_RELOAD);
	pl.w_attack_next = 2.0f;
}

float
w_mp5_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_mp5_hud(void)
{
#ifdef CSQC

	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = video_mins + [video_res[0] - 48, video_res[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [0,72/128], [24/256, 24/128], g_hud_color, pSeat->ammo2_alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_mp5_hudpic(int selected, vector pos, float a)
{
#ifdef CSQC
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud4.spr_0.tga",
			[0,180/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud1.spr_0.tga",
			[0,180/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_mp5 =
{
	ITEM_MP5,
	0,
	2,
	"sprites/640hud1.spr_0.tga",
	[32,16],
	[192,16],
	w_mp5_draw,
	__NULL__,
	w_mp5_primary,
	__NULL__,
	w_mp5_reload,
	__NULL__,
	w_mp5_hud,
	w_mp5_precache,
	w_mp5_pickup,
	w_mp5_updateammo,
	w_mp5_wmodel,
	w_mp5_pmodel,
	w_mp5_deathmsg,
	w_mp5_aimanim,
	w_mp5_hudpic
};

#ifdef SSQC
void
weapon_mp5(void)
{
	Weapons_InitItem(WEAPON_MP5);
}
#endif
