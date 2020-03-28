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
	SCOUT_IDLE,
	SCOUT_RELOAD,
	SCOUT_DRAW,
	SCOUT_SHOOT1,
	SCOUT_SHOOT2,
	SCOUT_SHOOT3
};

void
w_scout_precache(void)
{
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
		pl.scout_mag = 30;
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
w_scout_draw(void)
{
#ifdef CSQC
	Weapons_SetModel("models/v_scout.mdl");
	Weapons_ViewAnimation(SCOUT_DRAW);
#endif
}

void
w_scout_primary(void)
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
		Weapons_ViewAnimation(SCOUT_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(SCOUT_SHOOT2);
		break;
	default:
		Weapons_ViewAnimation(SCOUT_SHOOT3);
		break;
	}
#else
	if (!pl.scout_mag) {
		return;
	}

	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 8, [0.01,0,01], WEAPON_SCOUT);

	pl.scout_mag--;

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT1HAND, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CR_SHOOT1HAND, 0.45f);

	if (random() < 0.5) {
		sound(pl, CHAN_WEAPON, "weapons/scout-1.wav", 1.0f, ATTN_NORM);
	} else {
		sound(pl, CHAN_WEAPON, "weapons/scout-2.wav", 1.0f, ATTN_NORM);
	}
#endif

	pl.w_attack_next = 0.0955f;
}

void
w_scout_reload(void)
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
	if (pl.scout_mag >= 30) {
		return;
	}
	if (!pl.ammo_762mm) {
		return;
	}

	Weapons_ReloadWeapon(pl, player::scout_mag, player::ammo_762mm, 30);
	Weapons_UpdateAmmo(pl, pl.scout_mag, pl.ammo_762mm, -1);
#endif

	Weapons_ViewAnimation(SCOUT_RELOAD);
	pl.w_attack_next = 2.0f;
}

float
w_scout_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_scout_hud(void)
{
#ifdef CSQC

	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = video_mins + [video_res[0] - 48, video_res[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [0,72/128], [24/256, 24/128], g_hud_color, pSeat->ammo2_alpha, DRAWFLAG_ADDITIVE);
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
	__NULL__,
	w_scout_reload,
	__NULL__,
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
