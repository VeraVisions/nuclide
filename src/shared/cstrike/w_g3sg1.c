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
	G3SG1_IDLE,
	G3SG1_RELOAD,
	G3SG1_DRAW,
	G3SG1_SHOOT1,
	G3SG1_SHOOT2,
	G3SG1_SHOOT3
};

void
w_g3sg1_precache(void)
{
	precache_model("models/v_g3sg1.mdl");
	precache_model("models/w_g3sg1.mdl");
	precache_model("models/p_g3sg1.mdl");
}

void
w_g3sg1_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, pl.g3sg1_mag, pl.ammo_762mm, -1);
#endif
}

string
w_g3sg1_wmodel(void)
{
	return "models/w_g3sg1.mdl";
}

string
w_g3sg1_pmodel(void)
{
	return "models/p_g3sg1.mdl";
}

string
w_g3sg1_deathmsg(void)
{
	return "";
}

int
w_g3sg1_pickup(int new)
{
#ifdef SSQC
	player pl = (player)self;

	if (new) {
		pl.g3sg1_mag = 30;
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
w_g3sg1_draw(void)
{
#ifdef CSQC
	Weapons_SetModel("models/v_g3sg1.mdl");
	Weapons_ViewAnimation(G3SG1_DRAW);
#endif
}

void
w_g3sg1_primary(void)
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
		Weapons_ViewAnimation(G3SG1_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(G3SG1_SHOOT2);
		break;
	default:
		Weapons_ViewAnimation(G3SG1_SHOOT3);
		break;
	}
#else
	if (!pl.g3sg1_mag) {
		return;
	}

	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 8, [0.01,0,01], WEAPON_G3SG1);

	pl.g3sg1_mag--;

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT1HAND, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CR_SHOOT1HAND, 0.45f);

	if (random() < 0.5) {
		sound(pl, CHAN_WEAPON, "weapons/g3sg1-1.wav", 1.0f, ATTN_NORM);
	} else {
		sound(pl, CHAN_WEAPON, "weapons/g3sg1-2.wav", 1.0f, ATTN_NORM);
	}
#endif

	pl.w_attack_next = 0.0955f;
}

void
w_g3sg1_reload(void)
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
	if (pl.g3sg1_mag >= 30) {
		return;
	}
	if (!pl.ammo_762mm) {
		return;
	}

	Weapons_ReloadWeapon(pl, player::g3sg1_mag, player::ammo_762mm, 30);
	Weapons_UpdateAmmo(pl, pl.g3sg1_mag, pl.ammo_762mm, -1);
#endif

	Weapons_ViewAnimation(G3SG1_RELOAD);
	pl.w_attack_next = 2.0f;
}

float
w_g3sg1_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_g3sg1_hud(void)
{
#ifdef CSQC

	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [0,72/128], [24/256, 24/128], g_hud_color, pSeat->ammo2_alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_g3sg1_hudpic(int selected, vector pos, float a)
{
#ifdef CSQC
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud5.spr_0.tga",
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
			"sprites/640hud2.spr_0.tga",
			[0,180/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_g3sg1 =
{
	ITEM_G3SG1,
	0,
	13,
	"sprites/640hud1.spr_0.tga",
	[32,16],
	[192,16],
	w_g3sg1_draw,
	__NULL__,
	w_g3sg1_primary,
	__NULL__,
	w_g3sg1_reload,
	__NULL__,
	w_g3sg1_hud,
	w_g3sg1_precache,
	w_g3sg1_pickup,
	w_g3sg1_updateammo,
	w_g3sg1_wmodel,
	w_g3sg1_pmodel,
	w_g3sg1_deathmsg,
	w_g3sg1_aimanim,
	w_g3sg1_hudpic
};

#ifdef SSQC
void
weapon_g3sg1(void)
{
	Weapons_InitItem(WEAPON_G3SG1);
}
#endif
