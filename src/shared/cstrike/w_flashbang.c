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

/*QUAKED weapon_flashbang (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_flashbang.mdl"

COUNTER-STRIKE (1999) ENTITY

Concussion (Flashbang) Grenade Weapon

When thrown, nearby players become blinded temporarily from the blast.

- Buy Menu -
Price: $200

*/

enum {
	FLASHBANG_IDLE,
	FLASHBANG_RELOAD,
	FLASHBANG_DRAW,
	FLASHBANG_SHOOT1,
	FLASHBANG_SHOOT2,
	FLASHBANG_SHOOT3
};

void
w_flashbang_precache(void)
{
#ifdef SSQC
	Sound_Precache("weapon_flashbang.explode");
#endif
	precache_model("models/v_flashbang.mdl");
	precache_model("models/w_flashbang.mdl");
	precache_model("models/p_flashbang.mdl");
}

void
w_flashbang_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, -1, -1, -1);
#endif
}

string
w_flashbang_wmodel(void)
{
	return "models/w_flashbang.mdl";
}

string
w_flashbang_pmodel(void)
{
	return "models/p_flashbang.mdl";
}

string
w_flashbang_deathmsg(void)
{
	return "";
}

void
w_flashbang_draw(void)
{
#ifdef CSQC
	Weapons_SetModel("models/v_flashbang.mdl");
	Weapons_ViewAnimation(FLASHBANG_DRAW);
#endif
}

void
w_flashbang_primary(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return;
	}

#ifdef CSQC
	View_SetMuzzleflash(MUZZLE_RIFLE);

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(FLASHBANG_SHOOT1);
		break;
	case 1:
		Weapons_ViewAnimation(FLASHBANG_SHOOT2);
		break;
	default:
		Weapons_ViewAnimation(FLASHBANG_SHOOT3);
		break;
	}
#endif

	pl.w_attack_next = 0.0955f;
}

float
w_flashbang_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_flashbang_hud(void)
{
#ifdef CSQC

	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [48/256,96/256], [24/256, 24/256], g_hud_color, pSeat->ammo2_alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_flashbang_hudpic(int selected, vector pos, float a)
{
#ifdef CSQC
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud6.spr_0.tga",
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
			"sprites/640hud3.spr_0.tga",
			[0,90/256],
			[170/256,45/256],
			g_hud_color,
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_flashbang =
{
	ITEM_FLASHBANG,
	3,
	1,
	"sprites/640hud1.spr_0.tga",
	[32,16],
	[192,16],
	w_flashbang_draw,
	__NULL__,
	w_flashbang_primary,
	__NULL__,
	__NULL__,
	__NULL__,
	w_flashbang_hud,
	w_flashbang_precache,
	__NULL__,
	w_flashbang_updateammo,
	w_flashbang_wmodel,
	w_flashbang_pmodel,
	w_flashbang_deathmsg,
	w_flashbang_aimanim,
	w_flashbang_hudpic
};

#ifdef SSQC
void
weapon_flashbang(void)
{
	Weapons_InitItem(WEAPON_FLASHBANG);
}
#endif
