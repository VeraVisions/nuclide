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
	SMOKEGRENADE_IDLE,
	SMOKEGRENADE_RELOAD,
	SMOKEGRENADE_DRAW,
	SMOKEGRENADE_SHOOT1,
	SMOKEGRENADE_SHOOT2,
	SMOKEGRENADE_SHOOT3
};

void
w_smokegrenade_precache(void)
{
#ifdef SSQC
	Sound_Precache("weapon_smokegrenade.explode");
#endif
	precache_model("models/v_smokegrenade.mdl");
	precache_model("models/w_smokegrenade.mdl");
	precache_model("models/p_smokegrenade.mdl");
}

void
w_smokegrenade_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, -1, -1, -1);
#endif
}

string
w_smokegrenade_wmodel(void)
{
	return "models/w_smokegrenade.mdl";
}

string
w_smokegrenade_pmodel(void)
{
	return "models/p_smokegrenade.mdl";
}

string
w_smokegrenade_deathmsg(void)
{
	return "";
}

void
w_smokegrenade_draw(void)
{
#ifdef CSQC
	Weapons_SetModel("models/v_smokegrenade.mdl");
	Weapons_ViewAnimation(SMOKEGRENADE_DRAW);
#endif
}

void
w_smokegrenade_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

#ifdef CSQC
	View_SetMuzzleflash(MUZZLE_RIFLE);
	Weapons_ViewPunchAngle([-2,0,0]);

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(SMOKEGRENADE_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(SMOKEGRENADE_SHOOT2);
		break;
	default:
		Weapons_ViewAnimation(SMOKEGRENADE_SHOOT3);
		break;
	}
#endif

	pl.w_attack_next = 0.0955f;
}

float
w_smokegrenade_aimanim(void)
{
	return w_flashbang_aimanim();
}

void
w_smokegrenade_hud(void)
{
#ifdef CSQC
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [144/256,96/256], [24/256, 24/256], g_hud_color, pSeat->ammo2_alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_smokegrenade_hudpic(int selected, vector pos, float a)
{
#ifdef CSQC
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud6.spr_0.tga",
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
			"sprites/640hud3.spr_0.tga",
			[0,135/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_smokegrenade =
{
	ITEM_SMOKEGRENADE,
	3,
	2,
	"sprites/640hud1.spr_0.tga",
	[32,16],
	[192,16],
	w_smokegrenade_draw,
	__NULL__,
	w_smokegrenade_primary,
	__NULL__,
	__NULL__,
	__NULL__,
	w_smokegrenade_hud,
	w_smokegrenade_precache,
	__NULL__,
	w_smokegrenade_updateammo,
	w_smokegrenade_wmodel,
	w_smokegrenade_pmodel,
	w_smokegrenade_deathmsg,
	w_smokegrenade_aimanim,
	w_smokegrenade_hudpic
};

#ifdef SSQC
void
weapon_smokegrenade(void)
{
	Weapons_InitItem(WEAPON_SMOKEGRENADE);
}
#endif
