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
	GLOCK18_IDLE,
	GLOCK18_RELOAD,
	GLOCK18_DRAW,
	GLOCK18_SHOOT1,
	GLOCK18_SHOOT2,
	GLOCK18_SHOOT3
};

void
w_glock18_precache(void)
{
#ifdef SSQC
	Sound_Precache("weapon_glock18.fire");
#endif
	precache_model("models/v_glock18.mdl");
	precache_model("models/w_glock18.mdl");
	precache_model("models/p_glock18.mdl");
}

void
w_glock18_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, pl.glock18_mag, pl.ammo_762mm, -1);
#endif
}

string
w_glock18_wmodel(void)
{
	return "models/w_glock18.mdl";
}

string
w_glock18_pmodel(void)
{
	return "models/p_glock18.mdl";
}

string
w_glock18_deathmsg(void)
{
	return "";
}

int
w_glock18_pickup(int new)
{
#ifdef SSQC
	player pl = (player)self;

	if (new) {
		pl.glock18_mag = 20;
	} else {
		if (pl.ammo_762mm < 40) {
			pl.ammo_762mm = bound(0, pl.ammo_762mm + 20, 40);
		} else {
			return FALSE;
		}
	}
#endif
	return TRUE;
}

void
w_glock18_draw(void)
{
#ifdef CSQC
	Weapons_SetModel("models/v_glock18.mdl");
	Weapons_ViewAnimation(GLOCK18_DRAW);
#endif
}

void
w_glock18_primary(void)
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
		Weapons_ViewAnimation(GLOCK18_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(GLOCK18_SHOOT2);
		break;
	default:
		Weapons_ViewAnimation(GLOCK18_SHOOT3);
		break;
	}
#else
	if (!pl.glock18_mag) {
		return;
	}

	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 25, [0.01,0,01], WEAPON_GLOCK18);

	pl.glock18_mag--;

	if (self.flags & FL_CROUCHING)
		Animation_PlayerTopTemp(ANIM_SHOOT1HAND, 0.45f);
	else
		Animation_PlayerTopTemp(ANIM_CR_SHOOT1HAND, 0.45f);

	Sound_Play(pl, CHAN_WEAPON, "weapon_glock18.fire");
#endif

	pl.w_attack_next = 0.15f;
}

void
w_glock18_reload(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

#ifdef CSQC
	if (pl.a_ammo1 >= 20) {
		return;
	}
	if (!pl.a_ammo2) {
		return;
	}
#else
	if (pl.glock18_mag >= 20) {
		return;
	}
	if (!pl.ammo_762mm) {
		return;
	}

	Weapons_ReloadWeapon(pl, player::glock18_mag, player::ammo_762mm, 20);
	Weapons_UpdateAmmo(pl, pl.glock18_mag, pl.ammo_762mm, -1);
#endif

	Weapons_ViewAnimation(GLOCK18_RELOAD);
	pl.w_attack_next = 2.1f;
}

float
w_glock18_aimanim(void)
{
	return w_deagle_aimanim();
}

void
w_glock18_hud(void)
{
#ifdef CSQC

	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [0,72/128], [24/256, 24/128], g_hud_color, pSeat->ammo2_alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_glock18_hudpic(int selected, vector pos, float a)
{
#ifdef CSQC
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud4.spr_0.tga",
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
			"sprites/640hud1.spr_0.tga",
			[0,45/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_glock18 =
{
	ITEM_GLOCK18,
	1,
	1,
	"sprites/640hud1.spr_0.tga",
	[32,16],
	[192,16],
	w_glock18_draw,
	__NULL__,
	w_glock18_primary,
	__NULL__,
	w_glock18_reload,
	__NULL__,
	w_glock18_hud,
	w_glock18_precache,
	w_glock18_pickup,
	w_glock18_updateammo,
	w_glock18_wmodel,
	w_glock18_pmodel,
	w_glock18_deathmsg,
	w_glock18_aimanim,
	w_glock18_hudpic
};

#ifdef SSQC
void
weapon_glock18(void)
{
	Weapons_InitItem(WEAPON_GLOCK18);
}
#endif
